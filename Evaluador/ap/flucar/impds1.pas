{+doc
+NOMBRE: Impds1
+CREACION: 8/97
+AUTORES: MARIO VIGNOLO
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  Definici¢n del objeto Impedancia.
+PROYECTO: FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit Impds1;

interface
uses
	Horrores, xMatDefs,
  Lexemas32, AlgebraC,
  TDEfs0,
  uTCompFC,
  Barrs2,
  links;

type
	TImpedancia = Class(TCompFC)
		Nombre: TStr8;
		Nodo1, Nodo2: integer;
		Z: NComplex;
		Smax: NReal;
    Imax: NReal;
		constructor Create_Init(
			xNombre: string;
			xNod1, xNod2: integer;
			xZ: NComplex; xImax: NReal);
		constructor LeerDeFljLetras( var a: TFlujoLetras; var r: string);
		destructor done; virtual;
		procedure TransfS(var S12,S21,Scon,I: NComplex); virtual;
	end;


implementation


constructor TImpedancia.Create_Init(
			xNombre: string;
			xNod1, xNod2: integer;
			xZ: NComplex; xImax: NReal);

begin
  inherited Create;

	Nombre:= Copy(xNombre,1,8);
	Nodo1:= xNod1;
	Nodo2:= xNod2;
	Z:= xZ;
	Imax:= xImax;
end;

procedure TImpedancia.TransfS(var S12,S21,Scon,I: NComplex);

var
	I12,I21: NComplex;

begin
	if (nodo1<>0) and (nodo2<>0) then
	begin
		I12:=dc(rc(TBarra(func_BarraPtr(Nodo1-1)).V, TBarra(func_BarraPtr(Nodo2-1)).V)^,Z)^;
		S12:=pc(TBarra(func_BarraPtr(Nodo1-1)).V,cc(I12)^)^;
		I21:=dc(rc(TBarra(func_BarraPtr(Nodo2-1)).V, TBarra(func_BarraPtr(Nodo1-1)).V)^,Z)^;
		S21:=pc(TBarra(func_BarraPtr(Nodo2-1)).V,cc(I21)^)^;
		I:=I12;
	end
	else
	begin
		if nodo1=0 then
		begin
			S12:=complex_nulo;
			I21:=dc(TBarra(func_BarraPtr(Nodo2-1)).V,Z)^;
			S21:=pc(TBarra(func_BarraPtr(Nodo2-1)).V,cc(I21)^)^;
			I:=I21;
		end
		else
		begin
			S21:=complex_nulo;
			I12:=dc(TBarra(func_BarraPtr(Nodo1-1)).V,Z)^;
			S12:=pc(TBarra(func_BarraPtr(Nodo1-1)).V,cc(I12)^)^;
			I:=I12;
		end;
	end;
	Scon:=sc(S12,S21)^; {Potencia aparente consumida}
end;



constructor TImpedancia.LeerDeFljLetras( var a: TFlujoLetras; var r: string);
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
	res:= LeerNComplex(a, Z);
	res:= LeerNReal(a, Imax);
end;

destructor TImpedancia.Done;
begin
{ por ahora nada}
end;

end.
