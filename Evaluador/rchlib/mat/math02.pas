{+doc
+NOMBRE: Math02
+CREACION: 1990
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  definici¢n de m‚todos de integraci¢n de ecuaciones diferenciales
  de primer orden.
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
  Se implement¢ el m‚todo de Runge Kutta de orden 4, el m‚todo BackwardEuler
y el m‚todo de ROmberg. Este £ltimo es un algoritmo para realizar integrales
definidas ( est  realmente bueno ).
  El m‚todo de Euler hacia atras, tal como est  implementado no es estable
con muchos sistemas comunes ( no est  suficientemente probado ).
  El servicio Int01, es un m‚todo de cuadratura basado en la regla del
trapezio.
-doc}

unit math02;
{$MODE Delphi}

interface

uses
  xMatDefs,
  MatReal;

type
  fode = procedure(var fout, x: TVectR; t: NReal);


procedure BkEulerMethod(var X, (* condiciones iniciales *)
  Xs: TVectR; var t, ts: NReal;   (* tinicial *)
  fcal: fode; (* calcula fout = f(X,t) *)
  h, eps2: NReal; n: integer); (* dimenci¢n del problema *)


procedure RK4(var X, Xs: TVectR; var t, ts: NReal; fcal: fODE;
  h, eps2: NReal; { eps2 no se usa}
  n: integer);

function int01(f: TfdeX; x0, x1: NReal; Divisiones: integer; var residuo: NReal): NReal;


implementation


function Int01(f: TfdeX; x0, x1: NReal; Divisiones: integer; var residuo: NReal): NReal;
var
  acum, step, f0, fs, stepdiv2: NReal;
  k: integer;
  f0r: NReal;
  bf: boolean;
begin
  acum := 0;
  residuo := 0;
  bf := False;
  step := (x1 - x0) / Divisiones;
  f0 := f(x0);
  stepdiv2 := step / 2;
  f0r := f0;
  for k := 1 to Divisiones do
  begin
    fs := f(k * step + x0);
    acum := acum + (fs + f0) * stepdiv2;
    f0 := fs;
    if bf then
    begin
      residuo := residuo + (fs + f0r) * step;
      f0r := fs;
    end;
    bf := not bf;
  end;
  residuo := 4 / 3 * abs(acum - residuo);
  Int01 := acum;
end;




procedure BkEulerMethod(var X, (* condiciones iniciales *)
  Xs: TVectR; var t, ts: NReal;   (* tinicial *)
  fcal: fode; (* calcula fout = f(X,t) *)
  h, eps2: NReal; n: integer); (* dimensi¢n del problema *)
var
  tmp, fval: TVectR;
  a1, a2: NReal;
begin

  tmp := TVectR.create_init(n);
  fval := TVectR.create_init(n);
  xs.igual(x);
  ts := t + h;

  a2 := -1001;
  a1 := 1 / (1 + a2);

  fcal(fval, xs, ts);
  fval.porReal(h);
  tmp.igual(xs);
  tmp.porReal(a2);
  fval.sum(tmp);

  while fval.ne2 > eps2 do
  begin
    fval.sum(tmp);
    xs.sum(fval);
    xs.porReal(a1);
    fcal(fval, xs, ts);
    fval.porReal(h);
    tmp.igual(xs);
    tmp.porReal(a2);
  end;
  tmp.Free;
  fval.Free;
end;


procedure RK4(var X, Xs: TVectR; var t, ts: NReal; fcal: fODE; h, eps2: NReal; n: integer);
var
  k1, k2, k3, k4: TvectR;
  tmp: TvectR;
  hd2: NReal;
begin
  tmp := TVectR.create_init(n);
  k1 := TVectR.create_init(n);
  k2 := TVectR.create_init(n);
  k3 := TVectR.create_init(n);
  k4 := TVectR.create_init(n);
  hd2 := h / 2;
  ts := t + h;
  fcal(k1, X, t);
  tmp.igual(k1);
  tmp.porReal(hd2);
  tmp.sum(X);
  fcal(k2, tmp, t + hd2);
  tmp.igual(k2);
  tmp.porReal(hd2);
  tmp.sum(X);
  fcal(k3, tmp, t + hd2);
  tmp.igual(k3);
  tmp.porReal(h);
  tmp.sum(X);
  fcal(k4, tmp, ts);
  tmp.igual(k2);
  tmp.sum(k3);
  tmp.porReal(0.5);
  tmp.sum(k1);
  tmp.sum(k4);
  tmp.porReal(h / 6);
  tmp.sum(x);

  xs.igual(tmp);

  tmp.Free;
  k1.Free;
  k2.Free;
  k3.Free;
  k4.Free;
end;

end.


