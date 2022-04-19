unit umensajesretardados;

interface
uses
{$IFDEF LINUX}
  Libc,
  uEmuladorWinIPC,
  uConstantes,
 Impdgdll;
{$ELSE}
  uEmuladorLinuxSignals,
	Windows, uNombresLlaves, IPCThrd;
{$ENDIF}

var
  NSegundosEntreBarridos: integer= 10;

(* Arma un timer para ser disparado en nTicks *)
procedure Gatillar( hwin: THandle; msg, wParam: word; lParam: longint; nticks: integer );


(* busca en la cola de Timers programados aquellos que tienen hwin y wParam coincidentes
con los pasados como parámetros y los elimina *)
procedure EliminarGatillos( hwin: THandle; wParam: word );


procedure PararBarridos;

procedure IniciarBarridos;

// debe ser llamado por la atención de SIG_ALARM
// al final del barrido rearma la alarma.
procedure tic_Barrer;

implementation

const
	GATILLOS_SMF_KEY = 'GATILLOS_SMF_KEY';

type
	TMensaje= class
		siguiente, anterior: TMensaje;
		nticks: integer;
		hwin: THandle;
		msg: word;
		wParam: word;
		lParam: longint;
		constructor Create( hwin: THandle; msg, wParam: word; lParam: longint; nticks: integer );
	end;

	TColaMensajes = class
		primero: TMensaje;
		parado: boolean;
		procedure Agregar(mensaje: TMensaje );
		procedure BarrerTick;
		constructor Create( parado: boolean );
		procedure Eliminar( m: TMensaje );
		procedure Cancelar( hwin: THandle; wParam: word );
	end;



var
	Mensajes: TColaMensajes;




procedure Gatillar( hwin: THandle; msg, wParam: word; lParam: longint; nticks: integer );
var
	m: TMensaje;
begin
m:= TMensaje.Create( ??? );

Mensajes.Agregar(m);
end;

procedure EliminarGatillos( hwin: THandle; wParam: word );
begin
	Mensajes.Cancelar(hwin, wParam );
end;

procedure PararBarridos;
var
	smf: TMutex;
begin
{$IFDEF LINUX}
	smf:= TMutex.Create(keyGatillos, 0);
{$ELSE}
  smf:= TMutex.Create(keyGatillos);
{$ENDIF}
	if smf.Get( 2000 ) then
	try
		Mensajes.parado:= true;
	finally
		smf.release;
	end;
end;

procedure IniciarBarridos;
var
	smf: TMutex;
begin
{$IFDEF LINUX}
	smf:= TMutex.Create(keyGatillos, 0);
{$ELSE}
  smf:= TMutex.Create(keyGatillos);
{$ENDIF}
	if smf.Get( 2000 ) then
	try
		Mensajes.parado:= false;
    if nSegundosEntreBarridos > 0 then
    {$IFDEF LINUX}
        libc.alarm( nSegundosEntreBarridos );
    {$ELSE}
        uEmuladorLinuxSignals.alarm( nSegundosEntreBarridos );
    {$ENDIF}
	finally
		smf.release;
	end;
end;

procedure tic_Barrer;
begin

  Mensajes.BarrerTick;

  if not Mensajes.Parado and ( nSegundosEntreBarridos > 0) then
  {$IFDEF LINUX}
    libc.alarm( nSegundosEntreBarridos );
  {$ELSE}
    uEmuladorLinuxSignals.Alarm( nSegundosEntreBarridos );
  {$ENDIF}
end;




constructor TMensaje.Create(
	hwin: THandle; msg, wParam: word; lParam: longint; nticks: integer );
begin
	self.hwin:= hwin;
	self.msg:= msg;
	self.wParam:= wParam;
	self.lParam:= lParam;
	self.nticks:= nticks;
	siguiente:= nil;
	anterior:= nil;
end;

procedure TColaMensajes.Eliminar( m: TMensaje );
begin
	if m.siguiente <> nil then
		m.siguiente.anterior:= m.anterior;
	if m= primero then
		primero:= m.siguiente;
	m.Free;
end;

constructor TColaMensajes.Create( parado: boolean );
var
	smf: TMutex;
begin
{$IFDEF LINUX}
	smf:= TMutex.Create(keyGatillos, 0);
{$ELSE}
	smf:= TMutex.Create(keyGatillos );
{$ENDIF}
	if smf.Get( 2000 ) then
	try
		inherited Create;
		primero:= nil;
		self.parado:= parado;
	finally
		smf.release;
	end;

end;

procedure TColaMensajes.Agregar(mensaje: TMensaje );
var
	smf: TMutex;
begin
  {$IFDEF LINUX}
	smf:= TMutex.Create(keyGatillos, 0);
  {$ELSE}
  smf:= TMutex.Create(keyGatillos);
  {$ENDIF}
	if smf.Get( 2000 ) then
	try
		if primero= nil then
			primero:= mensaje
		else
		begin
			mensaje.Siguiente:= primero;
			primero.anterior:= mensaje;
			primero:= mensaje;
		end;
	finally
		smf.release;
	end;
end;



procedure TColaMensajes.Barrertick;
var
	m, s: TMensaje;
  smf: TMutex;
begin
{$IFDEF LINUX}
	smf:= TMutex.Create( keyGatillos, 0);
{$ELSE}
  smf:= TMutex.Create(keyGatillos);
{$ENDIF}
	if smf.Get( 2000 ) then
	try
		if parado then exit;
		s:= primero;
		while s <> nil do
		begin
			with s do
			begin
				dec( nticks );
				if nticks < 0 then
				begin
          {$IFDEF LINUX}
          if not xPostMessage( hWin, Msg, wParam, lParam )=0 then;
          {$ELSE}
					if not PostMessage( hWin, Msg, wParam, lParam ) then;
          {$ENDIF}
					m:= s;
					s:= s.siguiente;
					eliminar( m );
				end
				else
					s:= s.siguiente;
			end;
		end;
	finally
		smf.release;
	end;
end;


procedure TColaMensajes.Cancelar( hwin: THandle; wParam: word );
var
	m, s: TMensaje;
	smf: TMutex;
begin
{$IFDEF LINUX}
	smf:= TMutex.Create( keyGatillos, 0);
{$ELSE}
	smf:= TMutex.Create( keyGatillos);
{$ENDIF}

	if smf.Get( 2000 ) then
	try
		s:= primero;
		while s <> nil do
		begin
			if (s.hwin= hwin) and (s.wParam= wParam ) then
			begin
				m:= s;
				s:= s.siguiente;
				eliminar( m );
			end
			else
				s:= s.siguiente;
		end;
	finally
		smf.release;
	end;
end;


begin
  Mensajes:= TColaMensajes.Create(false);


end.
