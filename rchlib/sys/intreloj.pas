{+doc
+NOMBRE: IntReloj
+CREACION: 11.2.91
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:	Implementaci¢n de un despachador de procedimientos
	utilizando la interrupci¢n Clock.

+PROYECTO: rchlib

+REVISION: 12.11.91
+AUTOR: rch
+DESCRIPCION:
	El motivo principal para la creaci¢n de esta unidad,
es para poder hacer cursores en modo gr fico, que
parpadeen, sin necesidad de sobrecargar las rutinas
que lo utilizan con el trabajo de prender y apagar el
cursor. Ademas si el parpadeo del cursor se hace por
programaci¢n, es dificil hacer la frecuencia independiente
de la frecuencia del micro, perdiendose portabilidad.
-doc}


Unit IntReloj;
interface
	uses DOS;
type
	FarObjectMethod = procedure(var XSelf);
	FarProc = procedure;


function AddMethod(
		x, { direcci¢n del m‚todo de exitaci¢n del objeto }
		y  { puntero al objeto a exitar }
		:pointer):
		Integer; { N£mero identificador asignado por el despachador }

procedure SetTimes(
		id,	  { Identificador de la ficha de despacho a afectar }
		Ntimes  { El objeto se exitar  1 de cada Ntimes (tics) del reloj }
		:integer);

procedure DelMethod(id:integer); { Elimina la ficha (id) del despachador }
procedure StopMethod(id:integer); { Para de despachar la ficha (id) }
procedure StartMethod(id:integer); { Comienza a despachar la ficha (id) }
procedure StartClockDispatcher; { Inicia la acci¢n ( despachar )
											del despachador }
procedure StopClockDispatcher;  { Para la acci¢n ( despachar )
											del despachador }

implementation
type
	ficha = record
		FullState,StopState,Running:boolean;
		frec,count:integer;
		proc:FarObjectMethod;
		ObjSelfPtr:pointer;
	end;

const
	manf=5;
var
	mf:array[1..manf] of ficha;


{  Exchange: intercambia dos booleanas
	Implementar en ASM, para prevenir conflicto
de competencia por una ficha.
	Mientras los m‚todos atenci¢n a las interrupcones
no manejen los pedidos y liberaciones de fichas no hay
problemas con la implementaci¢n siguiente. }

procedure Exchange(var b1,b2:boolean);
var
	temp:boolean;
begin
	temp:=b1;
	b1:=b2;
	b2:=temp;
end;

function AddMethod;
var
	k:integer;
	buscando,flag:boolean;
begin
	k :=1;
	buscando:=true;
	flag:=true;
	while buscando do
	begin
		exchange(flag,mf[k].FullState);
		if not flag then buscando:=false
		else
			if k = manf then
			begin
				k:=0;
				buscando:=false;
			end
			else inc(k);
	end;

	if k =0  then RunError(211)
	else
	with mf[k] do
		begin
			frec:=0;
			count:=0;
			StopState:=True;
			@Proc:=x;
			ObjSelfPtr:=y;
			AddMethod:=k
		end;
end;


procedure SetTimes(id,Ntimes:integer);
begin
	mf[id].frec:=NTimes;
	mf[id].count:=NTimes;
end;

procedure DelMethod(id:integer);
begin
	with mf[id] do
		begin
			frec:=0;
			ObjSelfPtr:=nil;
			StopState:=true;
			FullState:=false
		end;
end;

procedure StopMethod(id:integer);
begin
	mf[id].StopState:=true;
end;

procedure StartMethod(id:integer);
begin
	mf[id].Running:=false;
	mf[Id].StopState:=False;
end;





{-------------------------}

procedure CLI; inline($fa);
procedure STI; inline($fb);

procedure CallOldInt(sub:Pointer);
begin
 inline(	$9c/				{PUSHHF ; push status flags to simulate INT}
			$ff/$5e/$06);  {CALL DWORD PTR [BP+6]}
end;



const
	TimerInt = $1C;

var
	chau, runningDispatcher:boolean;
	TimerVect:pointer;
	IntrInstalada:boolean;
	OldExitProc:pointer;


procedure RunDispatcher;
var
	k:integer;
begin
	for k:= 1 to manf do
	if mf[k].FullState
			and not(mf[k].StopState)
				and not(mf[k].running) then
		begin
			dec(mf[k].count);
			if mf[k].count <=0 then
				begin
					mf[k].count:=mf[k].frec;
					mf[k].running:=true;
					mf[k].proc(mf[k].ObjSelfPtr^);
					mf[k].running:=false;
				end;
		end;
end;

{$F+}
procedure Clock (flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word);
 interrupt;
 {$F-}
begin
CLI;
if runningDispatcher then chau:=true
else chau:=false;
runningDispatcher:=true;
STI;
CallOldInt(TimerVect);
if not chau then
	begin
		RunDispatcher;
		RunningDispatcher:=False;
	end;
end;


procedure StartClockDispatcher;
begin
	RunningDispatcher:=false;
	GetIntVec(TimerInt,TimerVect);
	SetIntVec(TimerInt,@Clock);
	IntrInstalada:= True;
end;

procedure StopClockDispatcher;
begin
	SetIntVec(TimerInt,TimerVect);
	IntrInstalada:=False;
end;

procedure AlFinal; far;
begin
	ExitProc:= OldExitProc;
	if IntrInstalada then StopClockDispatcher;
end;

procedure initUnit;
var
	k:integer;
begin
	for k:= 1 to manf do DelMethod(k);
	IntrInstalada:= false;
	OldExitProc:= ExitProc;
	ExitProc:= @AlFinal;
end;

begin
	InitUnit;
end.