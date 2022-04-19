unit umadresuniformes;
{$mode delphi}

(**** rch@20121013
Proyecto SimSEE.

La clase TMadresUniformes representa una lista de fuentes aleatorias
condistribución uniforme que pueden ser usadas directamente o como MADRE
para otras fuentes aleatorias.

La idea es que en un entorno de simulación, los diferentes actores
utilizan fuentes aletarias para modelas sus procesos estocásticos y por
motivos de mejora en la comparación de diferentes simulaciones para analizar
el efecto de "pequeños cambios" es importante que el comportamiento estocástico
de la parte "no cambiada" permanezca incambiado. Para ello es fundamental que
cada actor tenga "independencia" en la generación de números aleatorios.

A su vez es importante poder mantener la condición de que se pueda inicializar
el comportamietno aleatorio a partir de una Semilla que haga en defnitiva
repetible las simulaciones. Otro aspecto importante es que para la resolución
en ambiente distribuido de las simulaciones es necesario poder FIJAR el estado
del conjunto de fuente aleatorias.


***)

interface

uses
  xmatdefs, Classes, SysUtils, fddp;

type
  TEstadoMadresUniformes = array of TEstadoMadreUniforme;

TMadreUniformeEtiquetada = class( TMadreUniforme )
  etiqueta: integer;
  constructor Create( etiqueta: integer );
end;

TMadresUniformes = class( TList )
private
  MultiplicadorDeSemillas: integer;
  semilla_ultimo_reincio: integer;
  function getFuente( index: integer ): TMadreUniformeEtiquetada;

public
  // El MultiplicadorDeSemillas se utiliza para multiplicar la
  //  "NuevaSemilla" en un reiniciar y hacer un xor con la etiqueta
  // para obtener la semilla con que se reinica cada madre uniforme
  constructor Create( MultiplicadorDeSemillas_: integer );

  // Crea un nuevo sorteador uniforme, con la etiqueta pasada como parámetro
  // y lo agrega a la lista.
  // La etiqueta se utiliza par fijar la semilla de reinicialización
  // como semilla = etiqueta xor ( MultiplicadorDeSemillas * NuevaSemilla )
  function Get_NuevaMadreUniforme( etiqueta: integer ): TMadreUniformeEtiquetada;

  // Reinicializa todas las fuentes
  procedure Reiniciar( NuevaSemilla: integer );

  // Obtiene el estado del conjunto de fuentes.
  procedure getEstado( var estado: TEstadoMadresUniformes );

  // Fija el estado de todas las fuentes.
  procedure setEstado( const estado: TEstadoMadresUniformes );

  // Retorna la última semilla usada para inicializar
  function get_UltimaSemilla: integer;


  // Libera el conjunto de fuentes.
  procedure Free;


  property fuente[ index: integer ]: TMadreUniformeEtiquetada
           read getFuente; Default;
end;


implementation


constructor TMadreUniformeEtiquetada.Create( etiqueta: integer );
begin
  inherited Create( 0 );
  self.etiqueta:= etiqueta;
end;


function TMadresUniformes.getFuente( index: integer ): TMadreUniformeEtiquetada;
begin
  result:= items[ index ];
end;


constructor TMadresUniformes.Create( MultiplicadorDeSemillas_: integer );
begin
  inherited Create;
  MultiplicadorDeSemillas:= MultiplicadorDeSemillas_;
end;

function TMadresUniformes.Get_NuevaMadreUniforme( etiqueta: integer ): TMadreUniformeEtiquetada;
var
  a: TMadreUniformeEtiquetada;
begin
  a:= TMadreUniformeEtiquetada.Create( etiqueta );
  add( a );
  result:= a;
end;


procedure TMadresUniformes.Reiniciar( NuevaSemilla: integer );
var
  k: integer;
  a: TMadreUniformeEtiquetada;
  semilla: integer;
  mascara: int64;
begin
  semilla_ultimo_reincio:= NuevaSemilla;
  mascara:= ( NuevaSemilla* MultiplicadorDeSemillas ) mod $FFFFFFFF;
  for k:= 0 to count -1 do
  begin
    a:= fuente[k];
    semilla:= a.etiqueta xor mascara;
    a.Reiniciar( semilla );
  end;
end;

procedure TMadresUniformes.getEstado( var estado: TEstadoMadresUniformes );
var
  k: integer;
begin
  setlength( estado, count );
  for k:= 0 to count - 1 do
    fuente[k].getEstado( estado[k] );
end;

procedure TMadresUniformes.setEstado( const estado: TEstadoMadresUniformes );
var
  k: integer;
begin
  for k:= 0 to count -1 do
    fuente[k].setEstado( estado[k] );
end;

// Retorna la última semilla usada para inicializar
function TMadresUniformes.get_UltimaSemilla: integer;
begin
  result:= semilla_ultimo_reincio;
end;

procedure TMadresUniformes.Free;
var
  k: integer;
begin
  for k:= 0 to count -1 do
    fuente[k].Free;
  inherited Free;
end;


end.

