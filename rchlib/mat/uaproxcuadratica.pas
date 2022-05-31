unit uaproxcuadratica;

interface

uses
  Classes, SysUtils, xmatdefs, matreal;

type

(*
  Aproxima un conjunto de puntos dados Y = f( X ) por una expresión de la forma
  Y = X´A X + B X + C
*)
  TAproxCuadratica = class
    // Dimensión del espacio del vector X
    N: integer;

    // matrices resultado
    A: TMatR;
    B: TVectR;
    C: NReal;

    // matrices del sistema
    NPuntos: integer;
    Nxx:     integer;
    XX, XY:  TMatR;

    // vector auxiliar para el agregado de puntos.
    v:      TVectR;
    det_XX: NReal;

    constructor Create(N_dimX: integer);
    procedure Clear; // borra toda la información
    procedure AgregarPunto(X: TVectR; y: NReal; peso: integer);
    // resuelve el sistema y calcula A, B y C. Luego de resolver
    function Resolver( var f: textfile ): boolean; // calcula A, B y C
    procedure Free;
  end;

implementation


constructor TAproxCuadratica.Create(N_dimX: integer);
begin
  inherited Create;
  N   := N_dimX;
  Nxx := ((N * (N + 1)) div 2) + N + 1; // dimensión de la matriz XX
  XX  := TMatR.Create_Init(Nxx, Nxx);
  XY  := TMatR.Create_Init(Nxx, 1);
  v   := TVectR.Create_Init(Nxx);
  A   := TMatR.Create_Init(N, N);
  B   := TVectR.Create_init(N);
end;

procedure TAproxCuadratica.Clear; // borra toda la información
begin
  NPuntos := 0;
  XX.Ceros;
  XY.Ceros;
end;

procedure TAproxCuadratica.AgregarPunto(X: TVectR; y: NReal; peso: integer);
var
  h, k, j: integer;
  a: NReal;
begin

  // llenado del vector auxiliar v
  h := 1;

  for j := 1 to N do
  begin
    v.pv[h] := x.pv[j] * x.pv[j];
    Inc(h);
  end;

  for k := 1 to N-1 do
    for j := k + 1 to N do
    begin
      v.pv[h] := x.pv[k] * x.pv[j];
      Inc(h);
    end;

  for k := 1 to N do
  begin
    v.pv[h] := x.pv[k];
    Inc(h);
  end;
  v.pv[h] := 1;

  // agregado al sistema
  for h := 1 to Nxx do
  begin
    for j := h to Nxx do
    begin
      a := v.pv[h] * v.pv[j] * peso;
      XX.acum_e(h, j, a);
    end;
    XY.acum_e(h, 1, v.pv[h] * y * peso);
  end;
  NPuntos := NPuntos + peso;

end;

function TAproxCuadratica.Resolver( var f: textfile ): boolean; // calcula A, B y C
var
  h, k, j: integer;
  aval:    NReal;
  res:     boolean;
begin
  // primero completo XX por simetría.

  for h := 2 to Nxx do
    for j := 1 to h - 1 do
      XX.pon_e(h, j, XX.e(j, h));

  (*
  XX.PorReal(1 / NPuntos);
  XY.PorReal(1 / NPuntos);
    *)
    
  writeln( f, 'XX_solv' );
  XX.WriteXLT(f);
  writeln( f, 'XY_solv' );
  XY.WriteXLT( f );

  det_XX := XX.Escaler(XY, res);

  if res then
  begin
    // si logró resolver leemos la solución
    h := 1;
    // lectura de la matriz A
    for k := 1 to N do
    begin
      A.pon_e(k, k, XY.e(h, 1));
      Inc(h);
    end;

    for k := 1 to N-1 do
      for j := k + 1 to N do
      begin
        aval := XY.e(h, 1) / 2.0;
        A.pon_e(k, j, aval);
        A.pon_e(j, k, aval);
        Inc(h);
      end;

    // lectura del vector B
    for k := 1 to N do
    begin
      B.pv[k] := XY.e(h, 1);
      Inc(h);
    end;

    // lectura de la constante C
    c := XY.e(h, 1);
  end;
  Result := res;
end;

procedure TAproxCuadratica.Free;

begin
  XX.Free;
  XY.Free;
  v.Free;
  A.Free;
  B.Free;
  inherited Free;
end;


end.

