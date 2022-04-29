{+doc
+NOMBRE:mgprocs
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:procedimientos del programa MenGen.
+PROYECTO:GrafCrt

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

Unit MGProcs;
interface
uses
	BSPoint,Archivos,mnXX,MenGr,Field,GrafCrt,Cmps,CMPS02,Listas;
var
	f:archivo;

procedure TraerDeDisco(var alp);
procedure SalvarADisco(var alp);
procedure EditarMenues(var x);
procedure MenuSiguiente(var alp);
procedure MenuAnterior(var alp);
procedure AgregarMenu(var alp);
procedure BorrarMenu(var alp);
procedure EditarOrigenMenu(var mx);
procedure EditarAltoBorde(var alp);
procedure EditarAnchoBorde(var alp);
procedure CampoSiguiente(var alp);
procedure CampoAnterior(var alp);
procedure BorrarCampo(var alp);
procedure EditarCampo(var alp);
procedure AgregarLeyenda(var alp);
procedure AgregarVarReal(var alp);
procedure AgregarVarInteger(var alp);
procedure AgregarVarTexto(var alp);
procedure AgregarEjecutable(var alp);
procedure WriteEstadoAplicacion(var v);
procedure WriteEstadoListaCampos(var v);

implementation


var
	Aplicacion : Lista;
	mp: nodoPtr;



var
	FileName:string;

procedure noimplementado;
begin
end;

procedure WriteEstadoAplicacion(var v);
var
	sx:string[16];
begin
	ventana(v).GotoXY(1,1);
	str(aplicacion.NNodos:6,sx);
	ventana(v).write(sx);
	if mp <> nil then
	begin
		str(Aplicacion.Ord(mp):3,sx);
		sx:='selMenu = '+sx;
		ventana(v).WriteStrXY(3,2,sx)
	end
end;

procedure WriteEstadoListaCampos(var v);
var
	t:MenuXXPtr;
	sx:string[6];
begin
	t:=Addr(mp^.item^);
	t^.GotoXY(1,1);
	str(t^.LC.NNodos:6,sx);
	t^.write(sx);
end;


procedure TraerDeDisco(var alp);
var
	v:ventana;
begin
	v.Init(50,50,20,5,1);
	v.DefaultColors;
	v.abrir;
	v.Writeln('Nombre del archivo?');
	v.readln(FileName);
	v.cerrar;
{	if (pos('*',FileName)<>0) then
		begin
			WSetFile(FileName);
			FileName:=p;
		end;}
	f.assign(fileName);
	f.Reset;
	if IOResult <>0 then Aplicacion.CLear {archivo nuevo}
	else {trae aplicaci¢n}
	begin
		Aplicacion.Load(f);
		f.Close;
		mp:=Aplicacion.Ultimo
	end;
end;

procedure SalvarADisco(var alp);
var
	v:ventana;
begin
	v.Init(50,50,20,5,1);
	v.DefaultColors;
	v.abrir;
	v.Writeln('Nombre del archivo?');
	v.readln(FileName);
	v.cerrar;
	f.assign(filename);
	f.Rewrite;
	Aplicacion.Save(f);
	f.close;
end;



procedure HideMenu;
begin
	if mp <> nil then mp^.item^.Hide;
end;

procedure ShowMenu;
var
	sx:string[3];
begin
	if mp<> nil then mp^.item^.Show;

end;

procedure EditarMenues(var x);
var
	c:char;
begin
	repeat
		MenGR.CerrarMenues;
		MnXX.CerrarMenues;
		if mp<>nil then ShowMenu
		else
			begin
				abrir(x);
				if mp<>nil then ShowMenu
			end;
		c:=WaitEscEnter;
		if c = #13 then abrir(x);
	until c = #27;
end;

procedure MenuSiguiente(var alp);
begin
	if mp<> nil then mp:=APlicacion.Siguiente(mp);
	if mp = nil then mp:=Aplicacion.Ultimo;
	if WriteKey(#27) then
end;

procedure MenuAnterior(var alp);
begin
	if mp<> nil then mp:=aplicacion.Anterior(mp);
	if mp = nil then mp:= Aplicacion.ultimo;
	if WriteKey(#27) then
end;

procedure AgregarMenu(var alp);
var
	tmp:MenuXXPtr;
begin
	new(tmp,Init);
	tmp^.DefaultColors;
	aplicacion.insertar(tmp^,mp);
	if WriteKey(#27) then
end;

procedure BorrarMenu(var alp);
begin
	aplicacion.borrar(mp);
	if WriteKey(#27) then
end;

procedure EditarOrigenMenu(var mx);
begin
	MenuXX(addr(mp^.item^)^).Edit;
end;

procedure CampoSiguiente(var alp);
var
	t:NodoPtr;
	m:MenuXXPtr;
begin
	if mp <> nil then
	begin
		m:=addr(mp^.item^);
		if m^.marcado<>nil then
		begin
			t:=m^.LC.siguiente(m^.marcado);
			if t<> nil then
			begin
         	m^.active;
				Campo(addr(m^.marcado^.item^)^).desmarcar;
				Campo(addr(t^.item^)^).marcar;
				m^.marcado:=t;
			end;
		end;
	end;
end;

procedure CampoAnterior(var alp);
var
	t:NodoPtr;
	m:MenuXXPtr;
begin
	if mp <> nil then
	begin
		m:=addr(mp^.item^);
		if m^.marcado <> nil then
		begin
			t:=m^.LC.anterior(m^.marcado);
			if t<> nil then
			begin
				m^.active;
				Campo(addr(m^.marcado^.item^)^).desmarcar;
				Campo(addr(t^.item^)^).marcar;
				m^.marcado:=t;
			end
		end
	end;
end;


procedure BorrarCampo(var alp);
var
	t:NodoPtr;
	m:MenuXXPtr;
begin
	m:=addr(mp^.item^);
	t:=m^.marcado;
	if t<> nil then
	begin
		m^.active;
		t^.item^.Hide;
		m^.LC.borrar(t);
		m^.marcado:=t;
		m^.Hide;
		m^.Show
	end;
end;

procedure EditarCampo(var alp);
var
	c:char;
	t:menuXXPtr;
begin
	t:=addr(mp^.item^);
	t^.active;
	t^.SetCursor(Chico);
	if t^.marcado<>nil then
			t^.marcado^.item^.Edit;
	t^.Hide;
	t^.Show;
end;


procedure AgregarLeyenda(var alp);
var
	t:MenuXXPtr;
	pcamp:^Leyenda;

begin
	t:=addr(mp^.item^);
	New(pcamp,Init(1,1,'Default Text'));
	t^.LC.insertar(pcamp^,t^.marcado);
	if writeKey(#27) then
	if writeKey('E') then
end;

procedure AgregarVarReal(var alp);
var
	t:MenuXXPtr;
	pcamp:^ValorReal;

begin
	t:=Addr(mp^.item^);
	New(pcamp,InitDefault(1,1));
	t^.LC.insertar(pcamp^,t^.marcado);
	if writeKey(#27) then
	if writeKey('E') then
end;

procedure AgregarVarInteger(var alp);
var
	t:MenuXXPtr;
	pcamp:^ValorEntero;

begin
	t:=Addr(mp^.item^);
	New(pcamp,InitDefault(1,1));
	t^.LC.insertar(pcamp^,t^.marcado);
	if writeKey(#27) then
	if writeKey('E') then
end;
procedure AgregarVarTexto(var alp);
var
	t:MenuXXPtr;
	pcamp:^ValorTexto;

begin
	t:=Addr(mp^.item^);
	New(pcamp,Init(1,1));
	t^.LC.insertar(pcamp^,t^.marcado);
	if writeKey(#27) then
	if writeKey('E') then
end;
procedure AgregarEjecutable(var alp);
var
	t:MenuXXPtr;
	pcamp:^Ejecutable;

begin
	t:=addr(mp^.item^);
	New(pcamp,Init(1,1,'EjecuteProc'));
	t^.LC.insertar(pcamp^,t^.marcado);
	if writeKey(#27) then
	if writeKey('E') then
end;


procedure EditeEntero(var v:ventana;var xm:integer);
var
	sx:string;
	code:integer;
begin
	Str(xm:6,sx);
	v.Active;
	repeat
		v.Page;
		v.Readln(sx);
		while pos(' ',sx)<>0 do delete(sx,pos(' ',sx),1);
		val(sx,xm,code);
	until code = 0;
end;

procedure EditarAltoBorde(var alp);
var
	v:ventana;
	sx:string[3];
	m:integer;
begin
	v.Init(100,100,10,4,1);
	v.defaultColors;
	v.abrir;
	EditeEntero(v,m);
	v.cerrar;
end;

procedure EditarAnchoBorde(var alp);
begin
	NoImplementado;
end;



begin
	FileName:='*.MGR';
	aplicacion.Init;
	mp:=nil;
end.


procedure EntrarReal(var alp);
var
	sx:String;
	code:integer;
	xr:real;
	v:ventana;
	x0,y0:integer;
begin
	m02.PCOCXYABS(x0,y0,length(m02.leyendas[m02.marcado])+9,m02.marcado+3);
	v.init(x0,y0,14,1,1);
	v.papel(GrisClaro);
	v.tinta(Rojo);
	xr:=Real(x);
	Str(xr:6:2,sx);

	v.Active;
	repeat
		v.Page;
      sx:=sx+ ' [m]';
		v.Readln(sx);
		while pos(' ',sx)<>0 do delete(sx,pos(' ',sx),1);
		if pos('[m]',sx)<>0 then delete(sx,pos('[m]',sx),3);
		val(sx,xr,code);
	until code = 0;
	real(x):=xr;
end;

procedure WriteValores(var alp);
var
	sx:String;
	code:integer;
	xr:real;
	v:ventana;
	x0,y0:integer;
	k:integer;
begin
for k:= 1 to 5 do
if k<> 3 then
begin
	case k of
	1:xr:=x;
	2:xr:=y;
	4:xr:=dx;
	5:xr:=dy;
	end;{case}
	m02.PCOCXYABS(x0,y0,length(m02.leyendas[k])+9,k+3);
	v.init(x0,y0,14,1,1);
	v.papel(GrisClaro);
	v.tinta(Rojo);
	Str(xr:6:2,sx);
	sx:=sx+' [m]';
	v.Active;
	v.Page;
	v.Write(sx);
end;
end;

