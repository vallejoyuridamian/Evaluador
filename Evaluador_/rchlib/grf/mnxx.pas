{+doc
+NOMBRE:mnxx
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Definicion de menues en modo grafico(DOS) para el programa MenGen.
+PROYECTO:GrafCrt

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit mnxx;
interface
uses
	Graph,ancestor,GR,
	cursores, archivos,
	BSPoint,listas, GrafCrt, cmps,cmps02,Field;

const
	Nulo:pointer = nil;
	AutoClose: boolean = true;


type

	menuxx = object(ventana)
		marco:boolean;
		LC:lista;   {Lista de Campos}
		ProcAux: MenuXXProc;
		ParProcAux:Pointer;
		Marcado:NodoPtr; {Campo Activo}
		Constructor Load(var f:archivo);
		procedure Save(var f:archivo);virtual;
		destructor Done; virtual;
		procedure seleccion;
		constructor Init;
		procedure DefinaProcAux(nProcAux: MenuXXProc; var nParProcAux);
		procedure Cerrar;virtual;
		procedure Show;virtual;
		procedure hide;virtual;
		procedure Edit;virtual;
	end;



	MenuXXPtr = ^menuXX;

	procedure Abrir(var m);
	procedure CerrarMenues;
	procedure RegistrarTipos(var f:archivo);


	Procedure SetCampoRealPtr(Kmenu,Kcampo:integer;var x:real;var Ap:Lista);
	Procedure SetCampoEnteroPtr(Kmenu,Kcampo:integer;var x:integer;var Ap:Lista);
	Procedure SetCampoTextoPtr(Kmenu,Kcampo:integer;var x:String;var Ap:Lista);
	Procedure SetCampoEjecutable(Kmenu,Kcampo:integer;
								 x:MenuXXProc; var y;
								 var Ap:Lista);
implementation

type
	nodePtr=^node;
	node = record
		next:nodePtr;
		item:menuXXPtr;
	end;

const
	ListaDeAbiertos : nodePtr = nil;


procedure RegistrarTipos(var f:archivo);
begin
	f.RegisterType(TypeOf(MenuXX),@MenuXX.Save,@MenuXX.Load);
	f.RegisterType(TypeOf(ValorReal),@ValorReal.Save,@ValorReal.Load);
	f.RegisterType(TypeOf(ValorEntero),@ValorEntero.Save,@ValorEntero.Load);
   f.RegisterType(TypeOf(ValorTexto),@ValorTexto.Save,@ValorTexto.Load);
	f.RegisterType(TypeOf(Leyenda),@Leyenda.Save,@Leyenda.Load);
	f.RegisterType(TypeOf(Ejecutable),@Ejecutable.Save,@Ejecutable.Load);
	f.RegisterType(TypeOf(BasePoint),@BasePoint.Save,@BasePoint.Load);
	f.RegisterType(TypeOf(ventana),@Ventana.Save,@Ventana.Load);
	f.RegisterType(TypeOf(campo),@Campo.Save,@Campo.Load);
end;

procedure NotificarApertura(var m:menuxx);
var
	t:nodePtr;
begin
	new(t);
	t^.item:=@m;
	t^.next:=ListaDeAbiertos;
	ListaDeAbiertos:=t;
end;

procedure NotificarCerrada(var m:menuxx);
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
	if t = nil then RunError(555)
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
	menuXX(m).seleccion;
end;


procedure cerrarMenues;
begin
	while ListaDeAbiertos <> nil do
		ListaDeAbiertos^.item^.Hide;
end;

procedure MenuXX.DefinaProcAux(nProcAux: MenuXXProc; var nParProcAux);
begin
	ProcAux:=nProcAux;
	ParProcAux:=@nParProcAux;
end;

destructor MenuXX.Done;
begin
	Hide;
	ventana.Done;
end;

constructor MenuXX.Init;
begin
	Ventana.Init(0,0,30,10,1);
	DefaultColors;
	LC.Init;
	marcado:=nil;
	visible:=false;
	marco:=false;
	@ProcAux:=nil;
end;

procedure MenuXX.Cerrar;
begin
	Marco:=false;
	if visible then
	begin
		active;
		visible:=false;
		LC.Hide;
		NotificarCerrada(Self);
		ventana.cerrar;
	end
end;



procedure MenuXX.Hide;
begin
	Cerrar;
end;

procedure MenuXX.Show;
var
	k:integer;
	ptemp:CampoPtr;

procedure ShowMarco;
begin
	SetCursor(Apagado);
	Ventana.active;
	abrir;
	NotificarApertura(Self);
	marco:=true;
	LC.Show;
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
	if marcado<>nil then
	begin
		ptemp:=addr(Marcado^.item^);
		ptemp^.marcar
	end
end;



procedure MenuXX.Seleccion;

var
	letra:char;
	Esc:boolean;
	maux, OrgMarc:NodoPtr;
	auxPtr:CampoPtr;



procedure DetectePrimeroMarcable;
begin
	maux:={LC.anterior(marcado);}marcado;
	auxPtr:=addr(maux^.item^);
	while TypeOf(auxPtr^)=TypeOf(Leyenda) do
		begin
			maux:=LC.Anterior(maux);
			auxPtr:=addr(maux^.item^);
		end;
	if maux = nil then
		begin
			maux:=LC.primero;
			auxPtr:=addr(maux^.item^);
			while TypeOf(auxPtr^)=TypeOf(Leyenda) do
			begin
				maux:=LC.siguiente(maux);
				auxPtr:=addr(maux^.item^);
			end
		end;
	if marcado <> maux then
	begin
		marcado:=maux
	end;
end;


procedure Call(n:NodoPtr; var m:MenuXX);
begin
	Campo(addr(n^.item^)^).run;
end;

function Index(c:char):nodoPtr;
var
	np:nodoPtr;
	encontre,buscando:boolean;
begin
	buscando:=true;
	encontre:=false;
	np:=LC.ultimo;

	while buscando do
		begin
		  if UpCase(campo(addr(np^.item^)^).HotKey)=c then
				begin
					buscando:=false;
					encontre:=true;
				end
		  else
			begin
			 np:=LC.anterior(np);
			 if np=nil then buscando:=false;
			end;
		  end;
	if encontre then index:=np
	else index:=nil;
end;



begin
OrgMarc:=Marcado;
Marco:=False;
Esc:=false;
DetectePrimeroMarcable;
OrgMarc:=Marcado;
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
									maux:=LC.anterior(marcado);
									auxPtr:=addr(maux^.item^);
									while TypeOf(auxPtr^)=TypeOf(Leyenda) do
										begin
											maux:=LC.Anterior(maux);
											auxPtr:=addr(maux^.item^);
										end;
									if maux = nil then
										begin
											maux:=LC.primero;
											auxPtr:=addr(maux^.item^);
											while TypeOf(auxPtr^)=TypeOf(Leyenda) do
											begin
												maux:=LC.siguiente(maux);
												auxPtr:=addr(maux^.item^);
											end
										end;
									if marcado <> maux then
									begin
										campo(addr(marcado^.item^)^).Desmarcar;
										marcado:=maux
									end;
								end;
						'P': 	begin
									maux:=LC.siguiente(marcado);
									auxPtr:=addr(maux^.item^);

									while TypeOf(auxPtr^)=TypeOf(Leyenda) do
									begin
										maux:=LC.siguiente(maux);
										auxPtr:=addr(maux^.item^);
									end;
									if maux = nil then
									begin
										maux:=LC.ultimo;
										auxPtr:=addr(maux^.item^);
										while TypeOf(auxPtr^)=TypeOf(Leyenda) do
											begin
												maux:=LC.anterior(maux);
												auxPtr:=addr(maux^.item^);
											end;
									end;
									if marcado <> maux then
									begin
										campo(addr(marcado^.item^)^).Desmarcar;
										marcado:=maux
									end;
								end
					else beep
					end;
				end;
		#13:	if marcado <> nil then
				begin
					OrgMarc:=Marcado;
					if autoCLose then Hide;
					Call(marcado,Self);
					active;
				end
				else Beep;
		#27:  Esc:=true
	else
			begin
				maux:=index(letra);
				if maux<>nil then
					begin
						marcado:=maux;
						OrgMarc:=Marcado;
						if autoClose then hide;
						Call(marcado,Self);
						active;
					end
				else beep;
			end;
	end;
 until Esc;
 Marcado:=OrgMarc;
 Cerrar;
end;

procedure MenuXX.Edit;
var
	c1:cursor;
	res:boolean;
	p1,p2:point;

begin
	SetViewPort(0,0,GetMaxX,GetMaxY,true);
	c1.init(p.x,p.y,1);
	if c1.edit then p1 :=c1.p
	else p1:=p;
   Hide;
	ventana.Init(p1.x,p1.y,(dp.x div anch),(dP.y div alt), TamChar);
	Show;
	SetViewPort(0,0,GetMaxX,GetMaxY,true);
	P2.x:=P1.x+dP.x;
	P2.y:=P1.y+dP.y;
	c1.P:= P2;
	if c1.edit then P2:= c1.P;
	c1.Done;
	dP.x:=P2.x-P1.x;
	dP.y:=p2.y-P1.y;
	Hide;
	ventana.Init(p1.x,p1.y,(dp.x div anch),(dP.y div alt), TamChar);
	Show;
end;




constructor MenuXX.Load(var f:archivo);
begin
	MenuXX.Init;
	ventana.Load(f);
	LC.Load(f);
	marcado:=LC.ultimo
end;

procedure MenuXX.Save(var f:archivo);
begin
	Ventana.Save(f);
	LC.Save(f);
end;

Procedure SetCampoRealPtr(Kmenu,Kcampo:integer;var x:real;var Ap:Lista);
var
	t:NodoPtr;

begin
	t:=Ap.Dro(Kmenu);
	t:=menuXX(Addr(t^.item^)^).LC.Dro(Kcampo);
	ValorReal(Addr(t^.item^)^).SetVarReal(x);
end;

Procedure SetCampoEnteroPtr(Kmenu,Kcampo:integer;var x:integer;var Ap:Lista);
var
	t:NodoPtr;

begin
	t:=Ap.Dro(Kmenu);
	t:=menuXX(Addr(t^.item^)^).LC.Dro(Kcampo);
	ValorEntero(Addr(t^.item^)^).SetVarInteger(x);
end;

Procedure SetCampoTextoPtr(Kmenu,Kcampo:integer;var x:String;var Ap:Lista);
var
	t:NodoPtr;

begin
	t:=Ap.Dro(Kmenu);
	t:=menuXX(Addr(t^.item^)^).LC.Dro(Kcampo);
	ValorTexto(Addr(t^.item^)^).SetVarString(x);
end;

Procedure SetCampoEjecutable(Kmenu,Kcampo:integer;x:MenuXXProc;var y;var Ap:Lista);
var
	t:NodoPtr;

begin
	t:=Ap.Dro(Kmenu);
	t:=menuXX(Addr(t^.item^)^).LC.Dro(Kcampo);
	Ejecutable(Addr(t^.item^)^).SetProcToRun(x,y);
end;





end.
