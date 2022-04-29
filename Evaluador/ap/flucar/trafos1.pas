{+doc
+NOMBRE: Trafos1
+CREACION: 8/97
+AUTORES: MARIO VIGNOLO
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  Definici¢n de la clase Trafo.
+PROYECTO: FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit Trafos1;

interface
uses
	Horrores, xMatDefs, Lexemas32, AlgebraC,
  uTCompFC,
  TDEfs0,Barrs2,Links;

type
	TTrafo = class( TCOmpFC )
		Nombre: TStr8;
		Nodo1, Nodo2: integer;
		n: NReal;
		Zcc: NComplex;
		Imax: NReal;
		constructor Create_Init(
			xNombre: string;
			xNod1, xNod2: integer;
			xn: NReal; xZcc: NComplex; xImax: NReal);
		constructor LeerDeFljLetras( var a: TFlujoLetras; var r: string);
		destructor done; virtual;
		procedure  TransfS(var S12,S21,Scon,I: NComplex);
	end;

	  {
									 1:n
								  -  -   -  -        Zcc
			  Nodo1  ----- -      -      - ----/////---- Nodo2
								  -  -   -  -

	  }




implementation


constructor TTrafo.Create_Init(
			xNombre: string;
			xNod1, xNod2: integer;
			xn: NReal; xZcc: NComplex; xImax: NReal);

begin
  inherited Create;
	Nombre:= Copy(xNombre,1,8);
	Nodo1:= xNod1;
	Nodo2:= xNod2;
	n:=xn;
	Zcc:= xZcc;
	Imax:=xImax;
end;

procedure TTrafo.TransfS(var S12,S21,Scon,I: NComplex);

var
	I1_2,I1,I2: NComplex;

begin
	I1_2:=dc(rc(prc(n, TBarra(func_BarraPtr(Nodo1-1)).V)^,   {(nV1-V2)/Zcc}
				TBarra(func_BarraPtr(Nodo2-1)).V)^,Zcc)^;
	I1:=prc(n,I1_2)^;
	S12:=pc(TBarra(func_BarraPtr(Nodo1-1)).V,cc(I1)^)^;
	I2:=prc(-1,I1_2)^;
	S21:=pc(TBarra(func_BarraPtr(Nodo2-1)).V,cc(I2)^)^;
	I:=I2;
	Scon:=sc(S12,S21)^; {Potencia aparente consumida}
	
end;


constructor TTrafo.LeerDeFljLetras( var a: TFlujoLetras; var r: string);
var
	res: integer;

begin
	{ Nombre ID del Trafo}
	if length(r) > 8 then Nombre := Copy(r, 1,8)
	else Nombre:=r;

	{ Datos }
	getlexema(r,a);
	Nodo1:= Func_IndiceDeNodo(r,res);
	if res <> 0 then error(r+'  nombre no valido');
	getlexema(r,a);
	Nodo2:= Func_IndiceDeNodo(r,res);
	if res <> 0 then error(r+'  nombre no valido');
	res:= LeerNReal(a,n);
	res:= LeerNComplex(a, Zcc);
	res:= LeerNReal(a,Imax);

end;

destructor TTrafo.Done;
begin
{ por ahora nada}
end;

end.
