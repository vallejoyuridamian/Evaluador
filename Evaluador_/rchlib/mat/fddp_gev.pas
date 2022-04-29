unit fddp_gev;

{$mode delphi}

interface

uses
  Classes, SysUtils, math, xmatdefs, fddp, matreal;

type
  { Tf_ddp_GEV Gerenalized Extreme Distribution

  https://en.wikipedia.org/wiki/Generalized_extreme_value_distribution

  }

  Tf_ddp_GEV = class(Tf_ddp)
  private
    constructor Create_vmuestras(vdatos: TVectR; madreUniforme: TMadreUniforme;
      semilla: integer);

  public
    // Parámetros
    mu: NReal; // Location   Ubicación
    sigma: NReal; // Scale  Escala
    xi: NReal; // Shape  Forma

    constructor Create(
      mu, sigma, xi: NReal; madreUniforme: TMadreUniforme;
      semilla: integer);

    procedure SetNuevosParmetros( mu, sigma, xi: NReal );

    function densidad(x: NReal): NReal; override;
    function distribucion(x: NReal): NReal; override;
    function area_t(t: NReal): NReal; override;
    function area_t_rapida(t: NReal): NReal; override;
    function t_area(area: NReal): NReal; override;

    // Valor esperado
    function mean: NReal;

    // Valor del máximo de la densidad
    function mode: NReal;

    // Varianza
    function variance: NReal;

  private
    function aux_tOfx( x: NReal ): NReal;
    function aux_xOft(t: NReal): NReal;
    function g( k: integer ): NReal;

  end;

implementation


{ m‚todos de la funci¢n de probabilidad de Weibool }
constructor Tf_ddp_GEV.Create(mu, sigma, xi: NReal;
  madreUniforme: TMadreUniforme; semilla: integer);
begin
  inherited Create( -1e30, 0,1e30, 1, madreUniforme, semilla);
  setNuevosParametros( mu, sigma, xi );
end;

procedure Tf_ddp_GEV.SetNuevosParmetros(mu, sigma, xi: NReal);
begin
  if xi > AsumaCero then
    self.t0:= mu - sigma/ xi
  else if epsion < -AsumaCero then
    self.t1:= mu - sigma/ xi;

  self.mu:= mu;
  self.sigma:= sigma;
  self.xi:= xi;
end;

function Tf_ddp_GEV.aux_tOfx(x: NReal): NReal;
var
  z: NReal;
begin
  z:= ( x - mu )/ sigma;
  if not EsCero( epsion ) then
    result:= power( 1 + z * xi , - 1.0/xi )
  else
    result:= exp( -z );
end;

function Tf_ddp_GEV.aux_xOft(t: NReal): NReal;
var
  z: NReal;
begin
  if not EsCero( epsion ) then
    z:= ( power( t , -xi ) - 1 ) / xi
  else
    z:= -ln( x );
  x:=  mu + z* sigma;
end;

function Tf_ddp_GEV.g(k: integer): NReal;
begin
  result:= LanczosGammaAprox( 1 - k * xi );
end;




// estima a partir del vector de muestras los valores de
// k y lambda que mejor ajustan
constructor Tf_ddp_GEV.Create_vmuestras(
  vdatos: TVectR;
  madreUniforme: TMadreUniforme; semilla: integer);

var
  v_mean: NReal;
  v_var: NReal;
  v_median: NReal;
  v_m1, v_m2: NReal;
  n: integer;

begin
  // Como estos valores son FINITOS, xi < 0.5
  vdatos.PromedioVarianza( v_mean, v_var );
  vdatos.Sort;
  v_median:= vdatos.interpol( vdatos.n/2 );

  ( v_mean - v_median) / sqrt( v_var )   = f( xi )

  sigma := sqrt( v_var / (( g(2) - sqr( g(1) )) / sqr( xi ) )
  inherited Create(0, 0, 1, 1, madreUniforme, semilla);
  setNuevosParametros( mu, sigma, xi )
end;


function Tf_ddp_GEV.densidad(x: NReal): NReal;
var
  t_val: NReal;
begin
  if ( x < t0 ) or ( x > t1 ) then
    result := 0
  else
  begin
    t_val:= aux_t( x );
    result:= power( t_val, xi + 1 ) * exp( -t_val ) / sigma;
  end;
end;

function Tf_ddp_GEV.distribucion(x: NReal): NReal;
var
  t_val: NReal;
begin
  if ( x < t0 ) then
    result:= 0
  else if ( x > t1 ) then
    result := 1.0
  else
  begin
    t_val:= aux_t( x );
    result:=  exp( -t_val );
  end;
end;

function Tf_ddp_GEV.area_t(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function Tf_ddp_GEV.area_t_rapida(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function Tf_ddp_GEV.t_area(area: NReal): NReal;
var
  t_val: NReal;
begin
  if area <= AsumaCero then
    Result := t0
  else if ( area + AsumaCero ) > 1 then
    result := t1
  else
  begin
    t_val:= -ln( area );
    result:= aux_xOft( t_val );
  end;
end;

function Tf_ddp_GEV.mean: NReal;
begin
  if not EsCero( xi ) then
    if xi < 1 then
      result:= mu +  sigma * ( LanczosGammaAprox( 1- xi ) - 1 ) / xi )
    else
      result:= Infinity
  else
      result:= mu + sigma * gamma_EULER;
end;

function Tf_ddp_GEV.mode: NReal;
begin
  if EsCero( xi ) then
    result:= mu
  else
    result:= mu + sigma * ( power( 1 + xi, -xi )-1 ) / xi;
end;

function Tf_ddp_GEV.variance: NReal;
begin
  if not EsCero( xi ) then
    if xi < 0.5 then
      result:= sqr( sigma ) * ( g(2) - sqr( g(1) )) / sqr( xi )
    else
      result:= infinity
  else
    result:= sqr( sigma * pi ) / 6.0;

end;



end.

