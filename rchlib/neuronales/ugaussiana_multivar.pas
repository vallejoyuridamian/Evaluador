unit ugaussiana_multivar;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, matbool, matreal, fddp, udisnormcan, umaxdiff_cdf_fddp;



{
 Mide la distancia entre la distribución empírica de una serie de datos  la
 de la función de densidad de probabilidad del proceso conjunto gaussiano
 de valor medio nulo y matriz de covarianzas Sigma
 P(X) = 1/( (2 pi)^(n/2) Abs( Det( SIGMA ) )^(1/2))  * exp( -1/2*  (Xt Inv(Sigma) X ))


 Para hacer la medida se eligen nDirecciones al Azar y se mide en cada dirección
 la diferencia entra la CDF Empírica y estimada de P(X)


}

function MaxDiff_CDF_N_Sigma(
  Sigma: TMatR; // matriz del proceso gaussiano que se supone representan los datos
  series: TDAOFVectR;
  huecos: TVectBool; // tiene TRUE en donde hay un hueco e las medidas
  semilla: integer;
  nDirecciones: integer
  ): NReal;


{
Hace lo mismo que MaxDiff_CDF_N_Sigma suponiendo Sigma = I
Es decir pide la diferencia entra la CDF Empírica y la CDF de un proceso
gaussiano con matrz de covarianza igual a la Identidad.
}
function MaxDiff_CDF_N_I(
  series: TDAOFVectR;
  huecos: TVectBool; // tiene TRUE en donde hay un hueco e las medidas
  semilla: integer;
  nDirecciones: integer
  ): NReal;


implementation

function MaxDiff_CDF_N_Sigma(
  Sigma: TMatR; // matriz del proceso gaussiano que se supone representan los datos
  series: TDAOFVectR;
  huecos: TVectBool; // tiene TRUE en donde hay un hueco e las medidas
  semilla: integer;
  nDirecciones: integer
  ): NReal;
var
  ran: Tf_ddpUniformeRand3;
  u: TVectR;
  kDir: integer;
  err, maxerr: NReal;
  std: NReal;
begin
  ran:= Tf_ddpUniformeRand3.Create(nil, semilla );
  u:= TVectR.Create_Init( length( series ) );
  maxErr:= 0;
  for kDir:= 1 to nDirecciones do
  begin
    u.versor_randomico( ran );
    std:= sqrt( Sigma.FormaCuadratica( u ) );
    // buscamos solo en el subespacio positivo de la coordenad 1
    if u.e(1) < 0 then u.pon_e(1, -u.e(1));
    err:= MaxDiff_CDF_Nms_u( series, huecos, u, 0, std );
    if err > maxErr then maxErr:= err;
  end;
  u.Free;
  ran.Free;
  result:= maxErr;
end;

function MaxDiff_CDF_N_I(series: TDAOFVectR; huecos: TVectBool;
  semilla: integer; nDirecciones: integer): NReal;
var
  ran: Tf_ddpUniformeRand3;
  u: TVectR;
  kDir: integer;
  err, maxerr: NReal;
  std: NReal;
begin
  ran:= Tf_ddpUniformeRand3.Create(nil, semilla );
  u:= TVectR.Create_Init( length( series ) );
  maxErr:= 0;
  for kDir:= 1 to nDirecciones do
  begin
    u.versor_randomico( ran );
    // buscamos solo en el subespacio positivo de la coordenad 1
    if u.e(1) < 0 then u.pon_e(1, -u.e(1));
    err:= MaxDiff_CDF_Nms_u( series, huecos, u, 0, 1 );
    if err > maxErr then maxErr:= err;
  end;
  u.Free;
  ran.Free;
  result:= maxErr;
end;

end.


{
Crea la nube de vectores de dimensión DimX correspondiente a Niveles
de afinamiento de la discretización.
El afinamiento se puede imaginar organizado como un árblo en niveles.
Cada nodo del árbol se abre en DimX nodos al bajar de nivel
En cada Nodo del árbol hay un X de la nube de puntos retornada.
El Nivel 1 tiene los versores de la base
}
function NubeCuadrantePositivo( DimX, Niveles: Integer ): TDAOfVectR,


type
  { TNodoExplorador }

  TDAOfNodoExplorador = array of TNodoExplorador;

  TNodoExplorador = class
    puntos_padres: TDAOfTVectR; // apunta a los puntos base
    puntos_hijos: TDAOFTVectR; // apunta a los puntos hijos
    hijos: TDAOfNodoExplorador;
    constructor Create(puntos_padres_: TDOfTVectR; NivelesHijos: integer );
    procedure CrearHijos( NivelesHijos: integer );
  end;

  { TPuntosExplorador }
  TPuntosExplorador = class
    puntos: TDAOfTVectR;

    constructor Create(DimX, NNiveles: integer);
    procedure Free;
  end;


{ TNodoExplorador }

constructor TNodoExplorador.Create(puntos_padres_: TDOfTVectR;
  NivelesHijos: integer);
var
  kHijo: integer;
  X: TVectR;
  m: NReal;
begin
  puntos_Padres:= copy( puntos_padres_ );
  setlength( puntos_hijos, length( puntos_padres ) );
  m:= 1.0/(length( puntos_padres ) - 1 );
  for kHijo := 0 to high( puntos_hijos ) do
  begin
    X:= TVectR.Create_Init( pntos_padres_[0].n );
    X.Ceros;
    for jPadre:= 0 to high( puntos_padres ) do
    begin
      if jPadre <> kHijo then
        X.sum( puntos_padres[kPadre]);
    end;
    X.PorReal( m );
    puntos_hijos[ kHijo ]:= X;
  end;
  setlength( hijos, 0 );
  if NivelesHijos > 0 then
    CrearHijo( NivelesHijos );

end;

procedure TNodoExplorador.CrearHijos(NivelesHijos: integer);
var
  aPadres: TDAOfTVectR;
  kHijo, kPadre: integer;
  aHijo: TNodoExplorador;

begin
  setlength( hijos, length( puntos_hijos ) );
  setlength( aPadres, length( puntos_padres ) );
  for kHijo:= 0 to high( puntos_hijos ) do
  begin
    for kPadre:= 0 to high( puntos_padres ) do
    begin
      if kPadre <> kHijo then
        aPadres[kPadre]:= puntos_padres[ kPadre ]
      else
        aPadres[kPadre]:= puntos_hijos[kPadre];
    end;
    aHijo:= TNodoExplorador.Create( aPadres, NivelesHijos-1 );
    hijos[kHijo]:= aHijo;
  end;
end;


{ TPuntosExplorador }

constructor TPuntosExplorador.Create(DimX, NNiveles: integer);
var
  nPuntos: integer;
  k: integer;
  v: TVectR;
begin
  nPuntos := 1;
  for k := 1 to NNiveles do
    nPuntos := nPuntos * DimX;
  setlength(puntos, nPUntos);

  // LLenamos el NIVEL 1 con los versores de la base
  for k := 1 to DimX do
  begin
    v := TVectR.Create_Init(DimX);
    v.ceros;
    v.pon_e(k, 1);
    puntos[k - 1] := v;
  end;

end;

procedure TPuntosExplorador.Free;
begin

end;

end.

