unit umaxdiff_cdf_fddp;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, matreal, matbool, fddp;


{
Mide la máxima diferencia entre la CDF empírica del vector X y
la propia.
Como ambas CDF van de 0 a 1 el result in [0,1]
}
function max_diff_CDF( fddp: Tf_ddp; X: TVectR ): NReal;



{
Dada la dirección u (vector de igual dimensión que la cantidad de series)
proyecta todas las muestras sobre esa dirección y calcula la máxima diferencia
entre la CDF de las mustras en esa dirección y la de la Gaussiana N(m,s)
Atención, no se verifica si u es un versor o no por lo cual tenga en cuenta
que el test es sobre las muestras d_i =  X_i . u

El vector huecos puede ser NIL en cuyo caso se supone que todas las muestras
son válidas.
Si huevos <> nil, debe tener FALSE en los casilleros correspondientes a muestras
válidas y TRUE en los casilleros corresopndientes a un HUECO de la medida.
Los Huevos no son procesados.
}
function MaxDiff_CDF_Nms_u(
  series: TDAOFVectR;
  huecos: TVectBool; // tiene TRUE en donde hay un hueco e las medidas
  u: TVectR;
  m, s: NReal ): NReal;



implementation


function max_diff_CDF( fddp: Tf_ddp; X: TVectR): NReal;
var
  CDF_X, CDF_: NReal;
  y: TDAOfNReal;
  k: Integer;
  diff, max_diff: NReal;

begin
  y:= x.toTDAOfNReal;
  QuickSortInc( y, 0, high( y ) );
  CDF_X:= 1/x.n;
  CDF_:= fddp.area_t( y[0] );
  diff:= abs( CDF_X - CDF_ );
  max_diff:= diff;
  for k:= 1 to high( y ) do
  begin
    CDF_X:= (k+1)/x.n;
    CDF_:= fddp.area_t( y[k] );
    diff:= abs( CDF_X - CDF_ );
    if diff > max_diff then
      max_diff:= diff;
  end;
  setlength( y, 0 );
  result:= max_diff;
end;



function MaxDiff_CDF_Nms_u(series: TDAOFVectR; huecos: TVectBool; u: TVectR; m,
  s: NReal): NReal;
var
  d: TVectR;
  kSerie, kPaso: integer;
  NPuntos, NSeries: integer;
  X: TVectR;
  ad: NReal;
  cnt: integer;
  res: NReal;
begin
  cnt:= 0;
  NPUntos:= series[0].n;
  NSeries:= length( series );
  X:= TVectR.Create_Init( NSeries );
  d:= TVectR.Create_Init( NPuntos );
  for kPaso:= 1 to NPuntos do
  begin
    if ( huecos = nil ) or ( not huecos.pv[kPaso] ) then
    begin
     for kSerie:= 0 to NSeries - 1 do
        X.pv[kSerie+1]:= series[kSerie].pv[kPaso];
     inc( cnt );
     ad:= (u.PEV( X ) - m )/s;
     d.pv[cnt]:= ad;
   end;
  end;
  X.Free;
  d.resize( cnt );
  res:= d.MaxDiff_CDF_N01;
  d.Free;
  result:= res;
end;


end.

