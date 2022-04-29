{+doc
+NOMBRE: autoesca
+CREACION: 1.1.1990
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Sevicios de calculo de escalas automaticas
+PROYECTO:rchlib

+REVISION: mayo 2017 rch, le agrego EscalaFechaN para graficos con eje
  fecha.

Busca la mejor aproximación del rango a un múltiplo
de  Año, dia, h, min, s

+AUTOR:
+DESCRIPCION:
-doc}

unit AutoEsca;

interface

uses
  xMatDefs, Math;

type

  Escala = object
    grid, n, a: integer;
    xm1, xm2:   NReal;
    constructor Init(x1, x2: NReal);
  end;


procedure Escala125N(var x1, x2, dx: NReal; var N: integer; MODO: integer);
{
  Entradas:
    x1,x2 = rango  de valores que se desea cubrir.
    N = número de divisiones aprox. que se desea.
    MODO = modo en que se aproximará  el intervalo.
     MODO = 0, aproximar por adentro.
     MODO = 1, aproximar por afuera.
  Salidas:
    x1,x2 = rango que se cubrir . Calculado en la grilla de salida.
    Si Modo:=1 se el rango de salida aproxima al de entrada
    incluyendolo, por el contrario si Modo=0 lo aproxima sin
    incluir los extremos originales.(Lo aproxima por adentro).
    dx = ancho de una divisi¢n. Se cumple que:
      dx = an * exp10(a), donde an =(1,2,5) y a:integer.
    N = n£mero de divisiones que se tendr n.
}

procedure EscalaFechaN(var x1, x2, dx: NReal; var N: integer; MODO: integer);


function IntInf(x: NReal): int64;
{ IntInf <= x < IntInf + 1 }

function IntSup(x: NReal): int64;
{ IntSup - 1 < x <= IntSup }

function Log(x: NReal): NReal;
{ Logaritmo en base 10 }

function Exp10(x: NReal): NReal;
{ 10 elevado al la x }



implementation

var
  ln10: NReal;


function IntInf(x: NReal): int64;
var
  temp: int64;
begin
  temp := trunc(x);
  if temp = x then
    IntInf := temp
  else
  if x > 0 then
    IntInf := temp
  else
    IntInf := temp - 1;
end;

function IntSup(x: NReal): int64;
var
  temp: int64;
begin
  temp := trunc(x);
  if temp = x then
    IntSup := temp
  else
  if x > 0 then
    IntSup := temp + 1
  else
    IntSup := temp;
end;


function Log(x: NReal): NReal;
begin
  Log := ln(x) / ln10;
end;

function Exp10(x: NReal): NReal;
begin
  exp10 := exp(x * ln10);
end;

constructor Escala.Init(x1, x2: NReal);
var
  dx:   NReal;
  temp: integer;

  procedure v(gridx, nx: integer);
  begin
    n    := nx;
    grid := gridx;
  end;

begin
  dx   := x2 - x1;
  a    := IntSup(log(dx / 50));
  temp := IntSup(dx * exp10(-a));
  case temp of
    5: v(5, 1);
    6..8: v(8, 1);
    9..10: v(10, 1);
    11..16: v(8, 2);
    17..20: v(10, 2);
    21..25: v(5, 5);
    26..40: v(8, 5);
    41..50: v(10, 5);
  end;
  temp := IntInf(x1 / exp10(a) / n);
  xm1  := temp * exp10(a) * n;
  xm2  := (temp + grid) * exp10(a) * n;
end;

procedure Escala125N(var x1, x2, dx: NReal; var N: integer; MODO: integer);
var
  m, aux: NReal;
  n1, n2: int64;
  k, j: integer;
  temp:   array[1..3] of NReal;
  a:      array[1..3] of integer;
  expo:   NReal;
begin
  if x1 > x2 then
  begin // hay que ayudar a los tontos
    aux:= x1;
    x1:= x2;
    x2:= aux;
  end;


  if ( x2 - x1 ) < 1E-32 then
  begin
    if abs( x1 ) > 1E-10 then
      x2:= x1 * 1.1
    else
      x2:= 1E-10;
    if x1 > x2 then
    begin
      aux:= x1;
      x1:= x2;
      x2:= aux;
    end;
  end;

  aux:= log( x2 - x1 );

  temp[1] := log(N);
  temp[2] := log(2 * N);
  temp[3] := log(5 * N);
  if MODO = 1 then
  begin
    m := 1e30;
    j := 0;
    for k := 1 to 3 do
    begin
      a[k] := IntSup(aux - temp[k]);
      if temp[k] + a[k] < m then
      begin
        m := temp[k] + a[k];
        j := k;
      end;
    end;
  end
  else
  begin
    m := -1e30;
    j := 0;
    for k := 1 to 3 do
    begin
      a[k] := IntInf(aux - temp[k]);
      if temp[k] + a[k] > m then
      begin
        m := temp[k] + a[k];
        j := k;
      end;
    end;
  end;

  if j = 3 then
    dx := 5
  else
    dx := j;

  expo := a[j];
  aux  := exp10(expo) * dx;
  if MODO = 1 then
  begin
    n1 := IntInf{Sup}(x1 / aux);
    n2 := IntSup{Inf}(x2 / aux);
  end
  else
  begin
    n1 := IntSup(x1 / aux);
    n2 := IntInf(x2 / aux);
  end;
  n  := n2 - n1;
  x1 := n1 * aux;
  x2 := n2 * aux;
  dx := aux;
end;

function EnRango20( x: NReal ): boolean;
begin
  result:= ( x > 0.8 ) and ( x < 1.2 );
end;



const
  dtAnio = (97.0 * 366.0 + (400.0 - 97.0) * 365) / 400.0;
  dtMes = dtAnio  / 12;

  divisores_dia: array[0..10] of NReal = (
1.0/24.0/60.0 , // 0
1.0/24.0 ,      // 1
3.0/24.0 ,      // 2
4.0/24.0 ,      // 3
6.0/24.0 ,      // 4
12.0/24.0 ,      // 5
1.0,            // 6
7.0,            // 7
15.0,           // 8
dtMes,           // 9
dtAnio );        // 10


procedure EscalaFechaN(var x1, x2, dx: NReal; var N: integer; MODO: integer);
var
  sobra: NReal;
  nDivisores: integer;
  a_q, best_q: NReal;
  d1, d1_best: NReal;
  k_best_q: integer;
  k: integer;

begin
  if x2 < x1 then vswap( x1, x2 );
  dx:= ( x2-x1 ) / N;

  nDivisores:= length( divisores_dia );
  k_best_q:= 0;
  best_q:= dx/divisores_dia[0];
  d1_best:= abs( 1 - best_q );
  for k:= 1 to NDivisores - 1 do
  begin
    a_q:= dx/divisores_dia[k];
    d1:= abs( 1 - a_q );
    if d1 < d1_best then
    begin
      k_best_q:= k;
      d1_best:= d1;
      best_q:= a_q;
    end;
  end;


  dx:= divisores_dia[ k_best_q ];
  if best_q > 1 then
    dx:= dx * round( best_q );
  if k_best_q >= 6 then
    dx:= round( dx );

  if modo = 0 then
  begin // por dentro
    x1:= IntSup( x1 / dx )* dx;
    x2:= IntInf( x2 / dx )* dx;
  end
  else
  begin // por fuera
    x1:= IntInf( x1 / dx )* dx;
    x2:= IntSup( x2 / dx )* dx;
  end;
  N:= Round( ( x2 - x1 ) / dx );

end;

begin
  ln10 := ln(10);
end.

