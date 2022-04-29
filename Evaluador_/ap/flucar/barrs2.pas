{+doc
+NOMBRE: BARRS2
+CREACION: 9/97
+MODIFICACION:
+AUTORES: MARIO VIGNOLO
+REGISTRO:
+TIPO: Unidad Pascal
+PROPOSITO: Definicion del objeto Barra
+PROYECTO: FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}


unit barrs2;

interface

uses
  Horrores, xMatDefs, Lexemas32, AlgebraC,
  uTCompFC,
  Links;

type

	TStr8 = string[8];
	TPosiblesRestriccionesDeNodo = ( cf_P, cf_Q, cf_V, cf_delta );
	TRestriccionDeNodo = Set Of TPosiblesRestriccionesDeNodo;

	TBarra = class( TCompFC )
		Nombre: TStr8;
		Nro: integer;
		Restriccion: TRestriccionDeNodo;
		S, V: NComplex;
		Limitemin, Limitemax: char;
		Rmin,Rmax: NReal;
		constructor Create_Init(xNombre: string;
							xtipo: TRestriccionDeNodo; xP, xQ, xV,
							xDelta: NReal );
		constructor LeerDeFljLetras( var a: TFlujoLetras; var r: string;
						 var tipodeBarra: TRestriccionDeNodo);
		procedure WriteTXT( var f: text);
	end;


	{ (vk-vj)^2 }
	function ModV2( k,j:integer):Nreal;



implementation

function ModV2( k,j:integer):Nreal;
begin
	ModV2:= mod2(rc(TBarra(func_BarraPtr(k-1)).V, TBarra(func_BarraPtr(j-1)).V)^);
end;

procedure TBarra.WriteTXT( var f: text);
begin
	write(f,'b: ',Nombre,'  S:  ');
	wtxtc(f,S,CA_Rectangulares);
	write(f,'  V: ');
	wtxtc(f,V,CA_GradosDecimales);
end;

constructor TBarra.Create_Init(
			xNombre: string;
			xtipo: TRestriccionDeNodo;
			xP, xQ, xV, xDelta: NReal ); { los que no tengan sentido 0 }
begin
  inherited Create;
	Nombre:= Copy(xNombre,1,8);
	Restriccion:= xtipo;
	S:= numc( xP, xQ)^;
	V:= numc( xV*cos(xDelta), xV*sin(xDelta))^;
end;


constructor TBarra.LeerDeFljLetras( var a: TFlujoLetras; var r: string; var tipodeBarra: TRestriccionDeNodo);

var
	P, Q, xV, Delta: NReal;
	res,T: integer;

begin
	{ Nombre ID de la Barra }
	if length(r) > 8 then Nombre := Copy(r, 1,8)
	else Nombre:=r;
	{ Restriccion y Datos }
	restriccion := [];
	res:=LeerNInteger(a,T);
	if T=1 {Barra flotante} then restriccion:=restriccion + [cf_V,cf_delta]
	else
	if T=2 {Barra de carga} then restriccion:=restriccion + [cf_P,cf_Q]
	else
	if T=3 {Barra de g y v cont.} then restriccion:=restriccion + [cf_P,cf_V]
	else
	if T=4 {Barra con regulador} then restriccion:=restriccion + [cf_P,cf_Q,cf_V]
	else
	horrores.error('Los tipos de barra solo pueden ser 1, 2 o 3');
	res:=LeerNReal(a, P);
	res:=LeerNReal(a, Q);
	res:=LeerNReal(a, xV);
	res:=LeerNReal(a, delta);
	res:=LeerNReal(a,Rmin);
	if res=115 then limitemin:='N'
	else limitemin:='S';
	res:=LeerNReal(a,Rmax);
	if res=115 then limitemax:='N'
	else limitemax:='S';
	TipodeBarra:=restriccion;
	Create_Init(Nombre,restriccion,P,Q,xV,Delta);
end;



end.
