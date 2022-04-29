unit unube;
(*
rch@2012-07-27 Proyecto ANII-FSE-18-2009 - IIE-FING-UDELAR.

La nube es un conjunto de puntos sobre los que se evaluó una función del tipo
C( X, k )
Siendo X un vector de RN y k un ordinal que en la aplicación para la que se desarrolla
este módulo está asociado con el tiempo en un algoritmo de programación dinámica estocástica.

La Nube está formada por los puntos X1, ....., Xm sobre los que se calculó C(X ,k )
siendo lso valores C1, ....., Cm.

Suponemos que los puntos X1, ... Xm estan distribuiodos en forma desordenada.
y que pueden cambiar para cada valor de k. Esto diferencia la definición de Nube
de este módulo con el Constelación definido en la unidad uodt_types.

Este es un intento de luchar contra la maldición de la dimensionalidad de Bellman.
La idea es que en lugar de representar la función de costo futuro sobre un producto
cartesiano de las discretizaciones sobre cada dimensión del espacio de estado, se
tenga una representación más flexible que permita seleccionar en forma dinámica
la cantidad de puntos que se utilizará para representar C(X, k ) para cada etapa
de tiempo k.

*)
{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, matreal, uodt_types;


type
  TPuntoDeNube = class
    val: NReal;
    Norm: TDAofNReal; // gradiente
    X: TEstado;
  end;

  TNube = class;

  TNube_Frame_k = class
    MiNube: TNube;
    Puntos: TList; // Lista de los puntos de evaluación
    procedure eval( var pX: TPuntoDeNube ); // recibe X y calcula val y Norm
    constructor Create( MiNube_: TNube );
    procedure Free;
    function distancia_entre_puntosDeNube( const Punto_A, Punto_B: TPuntoDeNube ): NReal;
  end;

  TNube_Frames= array of TNube_Frame_k;

  TNube = class
  public
    // descripción del espacio de estado
    rX: TDAOfDefVarContinua;
    dX: TDAOfDefVarDiscreta;
    escalas_r: TDAOfNReal;
    escalas_d: TDAOfNReal;
    costoFuturo: TNube_Frames;

    NContinuas, NDiscretas, nPuntosT: Integer;

    constructor Create(
      rX_: TDAOfDefVarContinua; dX_: TDAOfDefVarDiscreta;
      nPuntosT_: integer;
      const costoFuturo: TNube_Frames );
  end;

implementation


constructor TNube_Frame_k.Create( MiNube_: TNube );
begin
  inherited Create;
  MiNube:= MiNube_;
  Puntos:= TList.Create;
end;

procedure TNube_Frame_k.Free;
var
  k: integer;
begin
  if Puntos <> nil then
  begin
    for k:= 0 to Puntos.count - 1 do
      TPuntoDeNube( Puntos.items[k] ).Free;
    Puntos.Free;
  end;
  inherited Free;
end;

function TNube_Frame_k.distancia_entre_puntosDeNube( const Punto_A, Punto_B: TPuntoDeNube ): NReal;
var
  res: NReal;
  k: integer;
  r: NReal;
begin
  res:= 0;
  for k:= 0 to MiNube.NContinuas-1 do
    res:= res + sqr( ( Punto_A.X.vc[k] - Punto_B.X.vc[k] )* MiNube.escalas_r[k] );
  for k:= 0 to MiNube.NDiscretas-1 do
    res:= res + sqr( ( Punto_A.X.vd[k] - Punto_B.X.vd[k] )* MiNube.escalas_d[k] );
  result:= res;
end;

procedure TNube_Frame_k.eval( var pX: TPuntoDeNube ); // recibe X y calcula val y Norm
var
  d2: TVectR;
  k: integer;
  aP: TPuntoDeNube;
  idxs: TDAOfNInt;
begin

// Lo primero que hacemos es buscar "los mas cercanos".
  d2:= TVectR.Create_init( Puntos.Count );
  setlength( idxs, Puntos.Count+1 );
  for k:= 1 to Puntos.Count do
  begin
    aP:= Puntos.items[k-1];
    d2.pv[k]:= distancia_entre_puntosDeNube( aP, pX );
    idxs[k]:= k;
  end;
  d2.Sort_idx( true, idxs );


end;


constructor TNube.Create(
  rX_: TDAOfDefVarContinua; dX_: TDAOfDefVarDiscreta;
  nPuntosT_: integer;
  const costoFuturo: TNube_Frames );
var
  k, ndim: integer;
begin
  inherited Create;
  self.rX := rX_;
  self.dX := dX_;

  nContinuas := length(rX);
  nDiscretas := length(dX);
  nPuntosT   := nPuntosT_;

end;



end.

