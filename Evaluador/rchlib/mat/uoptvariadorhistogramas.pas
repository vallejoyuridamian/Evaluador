unit uoptvariadorhistogramas;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, matreal,
  uresfxgx, ufxgx, uproblema;

(*************

dados dos vectores de muestras x_i
y un vectores de pesos probabilísticos q_i de cada muestra
( q_i >= 0 ; sum_i q_i = 1  )

se trata de buscar un nuevo vector p_i de pesos de probabilidad
tal que el valor esperado y la varianza de las muestras con los nuevos
pesos sean dos valores my e sy2 dados.

min sum_i( p_i - q_i )^2
p_i

@_restricciones
  sum_i p_i = 1;
  sum_i p_i * x_i = my
  sum_i p_i * ( x_i - my )^2 = sy2

@_restricciones de caja
  0<= p_i <= 1  ; i = 1 ... N

*********)

// Si encuentra solución retorna el vector p.
// Si no encuentra solución retorna NIL
function VariarHistograma(
  x, q: TVectR;
  my, sy2: NReal ): TVectR;


implementation

type

  // Retorna la distancia al punto q al cuadrado
  // res = sum_i ( x_i - q_i )^2
  Tfx_Distancia2 = class(Tfx)
    q: TVectR;
    constructor Create( q_: TVectR );
    function f(const X: TVectR): NReal; override;
    procedure acum_g(var grad: TVectR; const X: TVectR); override;
    procedure Free; override;
  end;

  // Retorna la distancia a un imperplano
  // res =  sum_i a_i * x_i - alfa
  Tfx_Hiperplano = class(Tfx)
    a: TVectR;
    alfa: NReal;
    constructor Create( a_: TVectR; alfa_: NReal );
    function f(const X: TVectR): NReal; override;
    procedure acum_g(var grad: TVectR; const X: TVectR); override;
    procedure Free; override;
  end;



constructor Tfx_Distancia2.Create( q_: TVectR );
begin
  inherited Create;
  q:= q_;
end;

function Tfx_Distancia2.f(const X: TVectR): NReal;
var
  k: Integer;
  res: NReal;
begin
  res:= 0;
  for k:= 1 to X.n do
      res:= res + sqr( x.e(k) - q.e( k ) );
  result:= res;
end;

procedure Tfx_Distancia2.acum_g(var grad: TVectR; const X: TVectR);
var
  k: integer;
begin
  for k:= 1 to x.n do
      grad.acum_e( k , 2* ( x.e( k ) - q.e( k ) ) );
end;

procedure Tfx_Distancia2.Free;
begin
  q.Free;
end;

constructor Tfx_Hiperplano.Create( a_: TVectR; alfa_: NReal );
begin
  inherited Create;
  a:= a_;
  alfa:= alfa_;
end;

function Tfx_Hiperplano.f(const X: TVectR): NReal;
var
  k: integer;
  res: NReal;
begin
  res:= 0;
  for k:= 1 to x.n do
      res:= res + a.e( k ) * x.e( k );
  res:= res - alfa;
  result:= res;
end;



procedure Tfx_Hiperplano.acum_g(var grad: TVectR; const X: TVectR);
var
  k: integer;
begin
  for k:= 1 to x.n do
      grad.acum_e(k,  a.e( k ));
end;

procedure Tfx_Hiperplano.Free;
begin
  a.Free;
end;




function VariarHistograma(
  x, q: TVectR;
  my, sy2: NReal ): TVectR;

var
  problema: TProblema_m01;
  p: TVectR;
  lambda: TVectR;
  k: integer;
  aR: TResfx;
  av: TVectR;
  cnt_iters: integer;
  ValCosto, ValLagrangiana, dFrontera2: NReal;
  convergio: boolean;
  df2: NReal;

begin
   p:= TVectR.Create_Clone( q );

  problema := TProblema_m01.Create_init( 3+1, p.n+1, 0, nil, nil);
  problema.f:= Tfx_Distancia2.Create( TVectR.Create_Clone( q ) );

  for k:= 1 to p.n do
  begin
       problema.cota_inf_set(k, 0);
       problema.cota_sup_set(k, 1);
  end;


  //
  // sum_i p_i - 1  = 0

  av:= TVectR.Create_Init( p.n );
  for k:= 1 to av.n do av.pon_e( k ,  1.0 );

  aR := problema.restricciones[0];
  aR.tipo := TR_Igualdad;
  aR.fx := Tfx_Hiperplano.Create( av, 1.0 );


  //
  // sum_i p_i * x_i - my  = 0

  av:= TVectR.Create_Init( p.n );
  for k:= 1 to av.n do av.pon_e( k ,  x.e( k ) );

  aR := problema.restricciones[1];
  aR.tipo := TR_Igualdad;
  aR.fx := Tfx_Hiperplano.Create( av, my );

  //
  // sum_i p_i * ( x_i - my )^2 - sy2  = 0

  av:= TVectR.Create_Init( p.n );
  for k:= 1 to av.n do av.pon_e( k ,  sqr( x.e( k ) - my ) );

  aR := problema.restricciones[2];
  aR.tipo := TR_Igualdad;
  aR.fx := Tfx_Hiperplano.Create( av, sy2 );

  //
  // Resolver
  lambda:= TVectR.Create_init( 3 );
  lambda.Ceros;
  df2:= Problema.MaxInBox_Dual(
    Lambda, p, 1, 1E-50, 1000,
    cnt_iters, ValCosto, ValLagrangiana, dFrontera2, convergio, false);

  Problema.Free;
  Lambda.Free;

  writeln( 'df2: ', df2 );
  result:= p;
  system.readln;
  (*
  if convergio then
  begin
    result:= p;
  end
  else
  begin
    p.Free;
    result:= nil;
  end;
    *)

end;


end.
