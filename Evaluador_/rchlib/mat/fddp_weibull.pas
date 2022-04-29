unit fddp_weibull;

{$mode delphi}

interface

uses
  Classes, SysUtils, math, xmatdefs, fddp, matreal;

type

  Tf_ddp_Weibull = class(Tf_ddp)
  public
    k, lambda: NReal;
    constructor Create(ValorMedio, Constante_k: NReal; madreUniforme: TMadreUniforme;
      semilla: integer);

    // estima a partir del vector de muestras los valores de
    // k y lambda que mejor ajustan
    // OJO!, se supone que los datos tienen que venir ordenados en forma creciente
    // si no lo están usar vdatos.sort(true) antes de llamar este constructor.
    constructor Create_vmuestras(
      vdatos: TVectR;
      madreUniforme: TMadreUniforme; semilla: integer);

    procedure setNuevosParams(ValorMedio, Constante_k: NReal);
    function densidad(x: NReal): NReal; override;
    function distribucion(x: NReal): NReal; override;
    function area_t(t: NReal): NReal; override;
    function area_t_rapida(t: NReal): NReal; override;
    function t_area(area: NReal): NReal; override;

  private
    kSobreLambda: NReal;
    unoSobreK: NReal;
  end;

implementation


{ m‚todos de la funci¢n de probabilidad de Weibool }
constructor Tf_ddp_Weibull.Create(ValorMedio, Constante_k: NReal;
  madreUniforme: TMadreUniforme; semilla: integer);
begin
  inherited Create(0, 0, ValorMedio * 1000, 1, madreUniforme, semilla);
  setNuevosParams(ValorMedio, Constante_k);
end;


// estima a partir del vector de muestras los valores de
// k y lambda que mejor ajustan
constructor Tf_ddp_Weibull.Create_vmuestras(
  vdatos: TVectR;
  madreUniforme: TMadreUniforme; semilla: integer);

(***

u = 1 - exp( - (x/ lambda )^k )
Ln( x ) k - k L(lambda) = ln( ln( 1/(1-u) )

por mínimo cuadrados identifico
k y beta = (k L(lambda) )
luego
  lambda = exp( beta/k )
**)
var
  LLu, Lx: TVectR;
  k: integer;
  u: NReal;
  A, B: TMatR;
  res_inv: boolean;
  res_exp10: Integer;
  beta: NReal;
  z: NReal;


begin
  LLu:= TVectR.Create_Init( vdatos.n );
  Lx:= TVectR.Create_Init( vdatos.n );
  for k:= 1 to vdatos.n do
  begin
    u:= ( k - 0.5 ) /vdatos.n;
    z:=   1/(1- u);
    z:= Ln(z );
    z:= Ln( z );
    LLu.pon_e( k, z );
    Lx.pon_e( k, Ln( vdatos.e( k ) ) );
  end;
  A:= TMatR.Create_Init( 2, 2 );
  B:= TMatR.Create_INit( 2, 1 );
  a.pon_e(1,1, Lx.PEV( Lx )/vdatos.n);
  a.pon_e(1,2, - Lx.promedio);
  b.pon_e(1,1, Lx.PEV( LLu )/vdatos.n);
  a.pon_e(2,1, a.e(1,2) );
  a.pon_e(2,2, 1 );
  b.pon_e(2,1, -LLu.promedio );

  A.Escaler( B, res_inv, res_exp10);
  if not res_inv then
    raise Exception.Create('Imposible invertir sistema Tf_ddp_Weibull.Create_vmuetras en fddp.pas');

  inherited Create(0, 0, vdatos.promedio * 1000, 1, madreUniforme, semilla);

  self.k:= B.e(1,1);
  beta:= B.e(2,1);

  A.Free;
  B.Free;

  self.lambda:= exp( beta/self.k );
  self.unoSobreK:= 1/ self.k;
  self.kSobreLambda:= self.k/self.lambda;
end;

procedure Tf_ddp_Weibull.setNuevosParams(ValorMedio, Constante_k: NReal);
var
  gamaaprox: NReal;
begin
  k := Constante_k;
  unoSobreK := 1.0 / Constante_k;
  //  gamaaprox:= 0.2869/k + 0.688*exp(-0.1*ln(k));
  gamaaprox := LanczosGammaAprox(1 + unoSobreK);
  lambda:= ValorMedio / gamaaprox;
  kSobreLambda := k / lambda;
end;

function Tf_ddp_Weibull.densidad(x: NReal): NReal;
var
  x_ala_k, x_sobre_lambda: NReal;
begin
  if x <= AsumaCero then
    densidad := 0
  else
  begin
    // pdf( X ) = (k/lambda) * (x/lambda)^(k-1) * exp( - (x/lambda)^k )
    x_sobre_lambda:= x / lambda;
    x_ala_k := power( x_sobre_lambda, k);
    densidad := kSobrelambda * (x_ala_k / x_sobre_lambda) * exp(-x_ala_k);
  end;
end;

function Tf_ddp_Weibull.distribucion(x: NReal): NReal;
var
  x_ala_k, x_sobre_lambda: NReal;

begin
  if x <= 0 then
    distribucion := 0
  else
  begin
    // cdf( X ) = 1 - exp( -1 (x/lambda)^k )
    x_sobre_lambda := x / lambda;
    x_ala_k := power(x_sobre_lambda, k);
    distribucion := 1 - exp(-x_ala_k);
  end;
end;

function Tf_ddp_Weibull.area_t(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function Tf_ddp_Weibull.area_t_rapida(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function Tf_ddp_Weibull.t_area(area: NReal): NReal;
var
  x_ala_k: NReal;
begin
  if area <= AsumaCero then
    Result := 0
  else
  begin
    x_ala_k := -ln(1 - area);
    Result := power(x_ala_k, unoSobreK) * lambda;
  end;
end;



end.

