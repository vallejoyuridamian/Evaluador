unit uneuron;
{$mode delphi}
(***
  rch@20150319 definición de clases básicas para menejo de RedesNeuronales

***)
interface

uses
  Classes, SysUtils, xmatdefs, ucosa;

type
  TNeurona = class( TCosa )
    entradas: array of TNeurona;
    pesos: TDAOfNReal;
    salida: NReal;
    constructor Create( xSalida: NReal );
    procedure evaluar; virtual;

    // busca si neurona está entre las entradas y retorna el índice
    // en el array de entradas. Si no encuentra retorna -1
    function locateNeurona( neurona: TNeurona ): integer;
    procedure SetPeso( neurona: TNeurona; peso: NReal );

    // función no lineal (por defecto SIGMA)
    function g( x: NReal ): NReal; virtual;
  end;

         (**
  TCapa_RedNeuronal = class( TCosa )
      neuronas: array of TNeurona;
      // recorre las neuronas de la capa y llama su evaluar
      procedure evaluar;
  end;

  TRedNeuronal = class( TCosa )
      capas: array of TCapa_RedNeuronal;
      constructor Create( DimCapas: TDAOfNInt);
      procedure evaluar;
  end;
            **)

implementation

constructor TNeurona.Create( xsalida: NReal );
begin
// la creamos aislada del mundo
// y con un valor fijo a su salida.
  setlength( entradas, 0 );
  setlength( pesos, 0 );
  salida:= xSalida;
end;

procedure TNeurona.evaluar;
var
  k: integer;
  a: NReal;
begin
  if length( entradas ) = 0 then exit;

  a:= 0;
  for k:= 0 to high( entradas ) do
     a:= a + pesos[k]* entradas[k].salida;
  salida:= g( a );
end;

function TNeurona.locateNeurona( neurona: TNeurona ): integer;
var
  k: integer;
  res: integer;
begin
  res:= -1;
  for k:= 0 to high( entradas ) do
     if entradas[k] = neurona then
     begin
       res:= k;
       break;
     end;
  result:= res;
end;


procedure TNeurona.SetPeso( neurona: TNeurona; peso: NReal );
var
  k: integer;
begin
  k:= locateNeurona( neurona );
  if k >= 0 then
    pesos[k]:= peso
  else
  begin
    k:= length( entradas );
    setlength( entradas, k+1 );
    setlength( pesos, k+1 );
    entradas[k]:= neurona;
    pesos[k]:= peso;
  end;
end;

// función no lineal (por defecto SIGMA)
function TNeurona.g( x: NReal ): NReal;
var
  a: NReal;
begin
  a:= exp( -x );
  result:= ( 1 - a )/( 1 + a );
end;

end.

