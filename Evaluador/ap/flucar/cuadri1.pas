{+doc
+NOMBRE: Cuadri1
+CREACION: 8/97
+AUTORES: MARIO VIGNOLO
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  Definici¢n del objeto Cuadripolo.
+PROYECTO: FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit cuadri1;

interface
uses
	Horrores, xMatDefs, Lexemas32, AlgebraC,
  uTCompFC, TDEfs0,Barrs2,Links;


{ Implementacion de los cuadripolos PI.

		Nodo1  ---_ZZZZZZ_--- Nodo2
					 Y      Y
  S(1)->        Y      Y          <-S(2)
					 Y      Y
		Nodo3 --------------- Nodo3
}



type
	TCuadripoloPi = class( TCompFC )
		Nombre: TStr8;
		Nodo1, Nodo2, Nodo3: integer;
		Y13, Z12, Y23: NComplex;
		Imax: NReal;
		constructor Create_Init(
			xNombre: string;
			xNod1, xNod2, xNod3: integer;
			xY13, xZ12, xY23: NComplex;xImax: NReal);
		constructor LeerDeFljLetras(
			var a: TFlujoLetras;
			var r: string);
		destructor done; virtual;
		function PerteneceBarra(
			kBarra: integer): boolean;
		procedure TransfS(var S12,S21,Scon,I: NComplex);
		{S12: potencia aparente entrante por el nodo 1, S21: potencia
		aparente entrante por el nodo 2, Scon: potencia aparente consumida
		por el cuadripolo, I: m ximo de los m¢dulos de I12 e I21 siendo
		I12: corriente entrante por el nodo 1 e I21 corriente entrante por
		el nodo 2}
	end;


implementation


constructor TCuadripoloPi.Create_Init(
			xNombre: string;
			xNod1, xNod2, xNod3: integer;
			xY13, xZ12, xY23: NComplex; xImax: NReal);

begin
  inherited Create;
	Nombre:= Copy(xNombre,1,8);
	Nodo1:= xNod1;
	Nodo2:= xNod2;
	Nodo3:= xNod3;
	Y13:= xY13;
	Z12:= xZ12;
	Y23:= xY23;
	Imax:=xImax;
end;

function TCuadripoloPi.PerteneceBarra( kBarra: integer): boolean;
begin
	PerteneceBarra:=kBarra in [Nodo1, Nodo2, Nodo3];
end;

procedure TCuadripoloPi.TransfS(var S12,S21,Scon,I: NComplex);

var
	I1,I2,I12,I21: NComplex;

begin
		I12:= pc(rc(TBarra(Func_BarraPtr(Nodo1-1)).V, TBarra(Func_BarraPtr(Nodo2-1)).V)^,invc(Z12)^)^;{(V1-V2)/Z12}
		I1:=pc(TBarra(Func_BarraPtr(Nodo1-1)).V,Y13)^;
		I12:=sc(I12,I1)^;
		S12:=pc(TBarra(Func_BarraPtr(Nodo1-1)).V,cc(I12)^)^;
		I21:= pc(rc(TBarra(Func_BarraPtr(Nodo2-1)).V, TBarra(Func_BarraPtr(Nodo1-1)).V)^,invc(Z12)^)^;{(V1-V2)/Z12}
		I2:=pc(TBarra(Func_BarraPtr(Nodo2-1)).V,Y23)^;
		I21:=sc(I21,I2)^;
		S21:=pc(TBarra(Func_BarraPtr(Nodo2-1)).V,cc(I21)^)^;

		Scon:=sc(S12,S21)^; {C lculo de la potencia consumida
									en el cuadripolo}
		if mod1(I12)>mod1(I21) then I:=I12 else I:=I21;
end;

constructor TCuadripoloPi.LeerDeFljLetras( var a: TFlujoLetras; var r: string);
var
	res: integer;

begin
	{ Nombre ID de la Impedancia }
	if length(r) > 8 then Nombre := Copy(r, 1,8)
	else Nombre:=r;

	{ Datos }
	getlexema(r,a);
	Nodo1:= Func_IndiceDeNodo(r,res);
	if res <> 0 then error(r+'  nombre no valido');
	getlexema(r,a);
	Nodo2:= Func_IndiceDeNodo(r,res);
	if res <> 0 then error(r+'  nombre no valido');
	getlexema(r,a);
	Nodo3:= Func_IndiceDeNodo(r,res);
	if res <> 0 then error(r+'  nombre no valido');

	res:= LeerNComplex(a, Y13);
	res:= LeerNComplex(a, Z12);
	res:= LeerNComplex(a, Y23);
	res:= LeerNReal(a,Imax);
end;

destructor TCuadripoloPi.Done;
begin
{ por ahora nada}
end;

end.
