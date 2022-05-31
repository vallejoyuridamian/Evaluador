
{+doc
+NOMBRE:mengr
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Def. objeto Menu. Servicios de menues en modo grafico (DOS)
+PROYECTO:GrafCrt

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit MenGr;


interface

uses Horrores,RCHFOnts,GrafCrt;

Const
	MaxLongLeyenda = 40;
	Nulo:pointer=nil;
	AutoClose:boolean = true;

type

	MenuProc = procedure(var x);

	Menu = object(Ventana)
		marco:boolean;
		inscriptos,marcado:integer;
		titulo:string[MaxLongLeyenda];

		IndexKeys:array[1..10] of byte;
		procs:array[1..10] of MenuProc;

		leyendas:array[1..10] of string[MaxLongLeyenda];

		param:array[1..10] of pointer;

		ProcAux: MenuProc;
		ParProcAux:Pointer;

		constructor Init(x0,y0,marcInit:integer);
		procedure DefinaProcAux(nProcAux: MenuProc; var nParProcAux);
		procedure DefinaTitulo(x:string);
		procedure DefinaX0Y0(SetX0,SetY0:integer);
		procedure add(keyIndex:integer; Leyenda:string; ProcExec:MenuProc; var Parametro);
		procedure Seleccion;
		procedure Cerrar;virtual;
		procedure Show;virtual;
		procedure hide;virtual;
		destructor Done;virtual;
	end;

	MenuPtr = ^menu;

	procedure Abrir(var m);
	procedure CerrarMenues;

implementation

type
	nodePtr=^node;
	node = record
		next:nodePtr;
		item:menuPtr;
	end;

const
	ListaDeAbiertos : nodePtr = nil;

procedure NotificarApertura(var m:menu);
var
	t:nodePtr;
begin
	new(t);
	t^.item:=@m;
	t^.next:=ListaDeAbiertos;
	ListaDeAbiertos:=t;
end;

procedure NotificarCerrada(var m:menu);
var
	p,t:nodePtr;
begin
	t:=ListaDeAbiertos;
	p:=t;
	while (t<> nil)and(t^.item <> @m) do
	begin
		p:=t;
		t:=t^.next;
	end;
	if t = nil then RunError(211)
	else
	begin
		if p = ListaDeAbiertos then
			ListaDeAbiertos:=t^.next
		else p^.next:=t^.next;
		dispose(t);
	end;
end;



procedure Abrir(var M);
begin
	menu(m).seleccion;
end;


procedure cerrarMenues;
begin
	while ListaDeAbiertos <> nil do
		ListaDeAbiertos^.item^.Hide;
end;

procedure menu.DefinaProcAux(nProcAux: MenuProc; var nParProcAux);
begin
	ProcAux:=nProcAux;
	ParProcAux:=@nParProcAux;
end;

destructor Menu.Done;
begin
	Hide;
	ventana.Done;
end;

constructor Menu.Init(x0,y0,MarcInit:integer);
begin
	Ventana.Init(x0,y0,5,5,1);
	visible:=false;
	inscriptos:=0;
	@ProcAux:=nil;
	marcado:=MarcInit;
	titulo:='';
end;

procedure Menu.Cerrar;
begin
	Marco:=false;
	if visible then
	begin
		visible:=false;
		NotificarCerrada(Self);
		ventana.cerrar;
	end
end;


procedure Menu.add(keyIndex:integer; Leyenda:string; ProcExec:MenuProc; var Parametro);
begin
	inc(inscriptos);
	IndexKeys[inscriptos]:=keyIndex;
	Procs[inscriptos]:=ProcExec;
	Leyendas[inscriptos]:=Leyenda;
	Param[inscriptos]:=@Parametro;
end;


procedure Menu.DefinaTitulo(x:string);
begin
	titulo:=x;
end;


procedure Menu.DefinaX0Y0(SetX0,SetY0:integer);
begin
 P.x:=SetX0; P.y:=SetY0
end;


procedure Menu.Hide;
begin
	Cerrar;
end;

procedure Menu.Show;
var
	k:integer;


procedure ShowMarco;
var
	k:integer;
	x:string;

function MaxLL:integer;
var
	m,k:integer;
begin
	m:=Length(Titulo)+6;
	for k:= 1 to inscriptos do
		if Length(Leyendas[k])>m then m:=length(Leyendas[k]);
	MaxLL:=m;
end;


begin
SetCursor(Apagado);
Ventana.Init(p.x,p.y,MaxLL+4+8,inscriptos+6,1);
abrir;
NotificarApertura(Self);
marco:=true;
	gotoXY(8,1);
	writeln('{ '+titulo+' }');
	for k:=1 to inscriptos do
		begin
		gotoXY(6,k+3);
		write(leyendas[k]);
		if indexkeys[k] <>0 then
			begin
				SetColorTinta(Rojo);
				SetTextStyle(BoldFont,0,1);
				gotoXY(5+indexkeys[k],k+3);
				write(leyendas[k][indexkeys[k]]);
				SetTextStyle(StandardFont,0,1);
				SetColorTinta(COlorTinta);
			end;
		end;
if @ProcAux <> nil then
		ProcAux(parProcAux^); { Luego de abierta la ventana, corremos el ProcAux }
active;
end;


begin
	if not visible then
	begin
		visible:=true;
		if not(marco) then ShowMarco;
	end;
	Active;
	for k:=1 to inscriptos do
		begin
			gotoXY(3,k+3);
			write('  ');
		end;
	if marcado<>0 then
		begin
			gotoXY(3,marcado+3);
			write('&>');
		end;
	gotoXY(1,1);
end;



procedure Menu.Seleccion;

var
	letra:char;
	Esc:boolean;
	maux, OrgMarc:integer;





procedure Call(n:integer);

	procedure Ejecute(var x:menuproc; p:pointer);
		begin
			x(p^);
	end;
begin
	Ejecute(procs[n],Param[n]);
end;

function Index(c:char):integer;
var
	k:integer;
	encontre,buscando:boolean;
begin
	buscando:=true;
	encontre:=false;
	k:=1;
	while buscando do
		begin
		  if UpCase(leyendas[k][IndexKeys[k]])=c then
				begin
					buscando:=false;
					encontre:=true;
				end
		  else
			begin
			 inc(k);
			 if k> inscriptos then buscando:=false;
			end;
		  end;
	if encontre then index:=k
	else index:=0;
end;



begin
OrgMarc:=Marcado;
Marco:=False;
Esc:=false;
 repeat
	if KeyPressed then begin
		letra:=UpCase(ReadKey);
		if letra <> #27 then Show
	end
	else begin
		Show;
		Repeat Until KeyPressed;
		letra:=UpCase(ReadKey);
	end;

	case letra of
		#0: 	begin
					letra:=UpCase(readKey);
					case letra of
						'H':	begin
									dec(marcado);
									if marcado<1 then marcado:=1;
								end;
						'P': 	begin
									inc(marcado);
									if marcado > inscriptos then
										marcado:= inscriptos;
								end
					else beep
					end;
				end;
		#13:	if marcado <>0 then
						begin
						OrgMarc:=Marcado;
						if autoCLose then Hide;
						Call(marcado);
						active;
						end
				else Beep;
		#27:  Esc:=true
	else
			begin
				maux:=index(letra);
				if maux<>0 then
					begin
						marcado:=maux;
						OrgMarc:=Marcado;
						if autoClose then hide;
						Call(marcado);
						active;
					end
				else beep;
			end;
	end;
 until Esc;
 Marcado:=OrgMarc;
 Cerrar;
end;


end.
