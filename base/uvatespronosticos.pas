unit uvatespronosticos;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, uauxiliares,
  uSLRW,
  uRobotHttpPost;


type
// Ficha Consulta del pronóstico de una variable
TFCVarPronostico = class
 Nombre: String; // nombre de la variable
 dt_Presente: TDateTIme; // dt (UTC) Presente
 Ts_Segundos: NReal; // Tiempo entre muestra en segundos
 NRetardos: integer; // Cantidad de retardos
 NFuturos: integer; // cantidad de futuros.

 procedure slrw( var sl: TSLRW );

 constructor Create(
    xNombre: String; // nombre de la variable
    xdt_Presente: TDateTime; // instante a considerar com PRESENTE
    xTs_Segundos: NReal; // Tiempo entre muestra en segundos
    xNRetardos: integer; // Cantidad de retardos
    xNFuturos: integer // cantidad de futuros.
   );
end;

TList_FCVarPronostico = class( TList )
 function GetFicha( i: longint ): TFCVarPronostico;
 property fichas[i : Longint]: TFCVarPronostico Read GetFicha; Default;
 procedure Free;

 procedure slrw( var sl: TSLRW );
end;


// Ficha Respuesta del pronóstico de una variable
TFRVarPronostico = class
  nombre: string; // identificador de la variable
  dtPrimerMuestra: TDateTime; // Fecha de la primera muestra.
  guia_p50: TDAOfNReal; // Guía central (PE = 50%) del cono de pronóstico .
  guia_pA: TDAOfNReal; // Guía central (PE = pA) del cono de pronóstico .
  guia_pB: TDAOfNReal; // Guía central (PE = pB) del cono de pronóstico .
  cronica_historica: TDAOfNReal; // Si hay datos de la realización se retorna en este vector.
  pA, pB: NReal; // Probabilidades de excedencia para las guiías extremas. Valores en por unidad.
  NPCC: integer; // Número de Pasos de Control del Cono
  NPLC: integer; // Número de Pasos de Liberación del Cono
  NPSA: integer; // Número de pasos Sin Apertura del Cono (determinista).
  NPAC: integer; // Número de Pasos de Apertura del Cono
  Modo: integer; // Modo de pronostico 0: GUia P50 y parámetros de cono (NPCC, NPLC, NPSA). 1: Guias p50, pA, pB.
  constructor Create;
  procedure slrw( var sl: TSLRW );
  procedure Free;
end;

TList_FRVarPronostico = class( TList )
 function GetFicha( i: longint ): TFRVarPronostico;
 property fichas[i : Longint]: TFRVarPronostico Read GetFicha; Default;
 procedure Free;
 procedure slrw( var sl: TSLRW );

 // retorna un string con todo
 function Text: string;
end;


// Esta función es solo para devoler una Ficha respuesta que indique
// que no encontró el manejador del pronóstico.
// se retorna el mismo nombre de la variable,
// NPCC = -1 (con esto indicamos DESCONOCIDO)
// y todo todo lo demás en CERO.
function get_pronostico_DESCONOCIDO( aFC: TFCVarPronostico ): TFRVarPronostico;


implementation


function get_pronostico_DESCONOCIDO( aFC: TFCVarPronostico ): TFRVarPronostico;
var
  aR: TFRVarPronostico;
  k: integer;
  dt: TDateTime;
  rescod: integer;

begin
  aR:= TFRVarPronostico.Create;
  aR.nombre:= aFC.Nombre;
  aR.pA:= 0;
  aR.pB:= 0;
  aR.NPCC:=-1; // Número de Pasos de Control del Cono
  aR.NPLC:=0; // Número de Pasos de Liberación del Cono
  aR.NPSA:=0; // Número de pasos Sin Apertura del Cono (determinista).
  aR.NPAC:=0; // Número de Pasos de Apertura del Cono
  aR.Modo:=0; // Modo de pronostico 0: GUia P50 y parámetros de cono (NPCC, NPLC, NPSA). 1: Guias p50, pA, pB.
  aR.dtPrimerMuestra:= 0.0;
  setlength( aR.guia_p50, 0 );
  setlength( aR.guia_pA, 0 );
  setlength( aR.guia_pB, 0 );
  setlength( aR.cronica_historica, 0 ); // ????? Si hay datos de la realización se retorna en este vector.
  result:= aR;
end;


constructor TFCVarPronostico.Create(
   xNombre: String; // nombre de la variable
   xdt_Presente: TDateTime; // instante a considerar com PRESENTE
   xTs_Segundos: NReal; // Tiempo entre muestra en segundos
   xNRetardos: integer; // Cantidad de retardos
   xNFuturos: integer // cantidad de futuros.
  );
begin
  Nombre:= xNombre;
  dt_Presente:= xdt_Presente;
  Ts_Segundos:= xTs_Segundos;
  NRetardos:= xNRetardos;
  NFuturos:= xNFuturos;
end;

procedure TFCVarPronostico.slrw( var sl: TSLRW );
begin
  sl.rw( Nombre );
  sl.rw( dt_Presente );
  sl.rw( Ts_Segundos );
  sl.rw( NRetardos );
  sl.rw( NFuturos );
end;



function TList_FCVarPronostico.GetFicha( i: longint ): TFCVarPronostico;
begin
  result:= TFCVarPRonostico( items[i] );
end;

procedure TList_FCVarPronostico.Free;
var
  k: integer;
begin
  for k:= 0 to count-1 do
    TFCVarPRonostico( items[k] ).Free;
  inherited Free;
end;


procedure TList_FCVarPronostico.slrw( var sl: TSLRW );
var
  k, N: integer;
  aFCVarPronostico: TFCVarPronostico;
begin
  if sl.modo_lectura then
  begin
    clear;
    if not sl.EOF then
      sl.rw( N )
    else
      N:= 0;
    for k:= 0 to N-1 do
    begin
      aFCVarPronostico:= TFCVarPronostico.Create('', now(), 0, 0, 1);
      aFCVarPronostico.slrw( sl );
      add( aFCVarPronostico );
    end;
  end
  else
  begin
    N:= count;
    sl.rw( N );
    for k:= 0 to N-1 do
      TFCVarPRonostico( items[k] ).slrw( sl );
  end;
end;


function TList_FRVarPronostico.GetFicha( i: longint ): TFRVarPronostico;
begin
  result:= TFRVarPRonostico( items[i] );
end;

procedure TList_FRVarPronostico.Free;
var
  k: integer;
begin
  for k:= 0 to count-1 do
    TFRVarPRonostico( items[k] ).Free;
  inherited Free;
end;


procedure TList_FRVarPronostico.slrw( var sl: TSLRW );
var
  k, N: integer;
  aFRVarPronostico: TFRVarPronostico;
begin
  if sl.modo_lectura then
  begin
    clear;
    if not sl.EOF then
      sl.rw( N )
    else
      N:= 0;
    for k:= 0 to N-1 do
    begin
      aFRVarPronostico:= TFRVarPronostico.Create;
      aFRVarPronostico.slrw( sl );
      add( aFRVarPronostico );
    end;
  end
  else
  begin
    N:= count;
    sl.rw( N );
    for k:= 0 to N-1 do
      TFRVarPRonostico( items[k] ).slrw( sl );
  end;
end;




// retorna un string con todo
function TList_FRVarPronostico.Text: String;
var
  xslrw: TSLRW;
begin
  xslrw:= TSLRW.CreateForWrite;
  self.slrw( xslrw );
  result:= xslrw.Text;
  xslrw.Free;
end;

constructor TFRVarPronostico.Create;
begin
  inherited Create;
end;

procedure TFRVarPronostico.slrw( var sl: TSLRW );
begin
  setSeparadoresGlobales;
  sl.rw( nombre );
  sl.rw( dtPrimerMuestra );
  sl.rw( guia_p50 );
  sl.rw( guia_pA );
  sl.rw( guia_pB );
  sl.rw( cronica_historica );
  sl.rw( pA );
  sl.rw( pB );
  sl.rw( NPCC );
  sl.rw( NPLC );
  sl.rw( NPSA );
  sl.rw( NPAC );
  sl.rw( Modo );
end;


procedure TFRVarPronostico.Free;
begin
  setlength( guia_p50, 0 );
  setlength( guia_pA, 0 );
  setlength( guia_pB, 0 );
  setlength( cronica_historica, 0 );
  inherited Free;
end;

end.
