unit uevaluadormatches;

{$mode delphi}
{x$DEFINE VERBOSO}

interface

uses
  Classes, SysUtils, uopencalc, LazUTF8, fpspreadsheet, fpsTypes, fpsUtils, xlsxml,
  strutils, xmatdefs, umemoryusage, Math;

procedure evaluar(metodo: integer);
function getPartidos(): TStringList;
function getEstado(str: string): string;
function getMarcador(str: string): string;
function getTiempo(str: string): string;
function contarColumnas(hoja: TsWorksheet): integer;
function getGolesLocal(resultado: string): integer;
function getGolesVisitante(resultado: string): integer;
function getMinuto(tiempo, estado: string): integer;
function getSegundo(tiempo: string): integer;


procedure crearSiNoExiste(dirName:String);

const
  // Perillas
  APUESTAMINIMA = 15;
  SIDUMBRAL = 0.6;
  UMBRALENMINUTOS = 10;
  PODERFAVORITOMAX = 3; // 5
  UMBRALSUMADEAPUESTASMAXIMA = 500; // 200
  SIDUMBRALINICIALMIN = 99999;

type

  { TApuesta }
  TApuesta = class
    monto, dividendo, pago: NReal;
    minuto, paso: integer;
    resultado: string;
    constructor Create(xmonto, xdividendo: NReal; xresultado: string;
      xminuto, xpaso: integer);
    procedure Free;

  end;

  TDAOfTApuesta = array of TApuesta;

  { TDividendo }

  TDividendo = class
    resultado: string;
    dividendo: NReal;
    esOtro: boolean;
    golesAdicionalesLocal, golesAdicionalesVisitante, golesAdicionalesTotales: integer;
    texto: string;
    constructor Create(linea: string; marcador: string);
    procedure Free;
  end;

  { TColumna }
  TColumna = class
    estado: string;
    tiempo: string;
    minuto: integer;
    segundo: integer;
    marcador: string;
    dividendos: array of TDividendo;
    constructor Create(hoja: TsWorksheet; kColumna: integer);
    procedure Free;
  end;

  { TMarcador }

  TMarcador = class
    golesLocal, golesVisitante: integer;
    resultado: string;
    apuesta: NReal;
    procedure actualizarResultado;
    procedure golLocal;
    procedure golVisitante;
    constructor Create();
    procedure Free;
  end;

  TDAOFDividendo = array of TDividendo;
  PDividendos = ^TDAOFDividendo;

  { TMinuto }

  TMinuto = class
    minuto: integer;
    marcador: string;
    marcadores: array of string;
    golesLocal, golesVisitante, cantidadDeGoles, columnaAnterior,
    columnaSiguiente: integer;
    dividendos: PDividendos;
    distanciaAColumnaAnterior, distanciaAColumnaSiguiente,
    sumaDeLasInversasDeLosDividendos, sumaDeLasInversasDeLosDividendos2,
    sumaDeLasInversasDeLosDividendos3: NReal;
    dividendoDelMarcadorActual, dividendoGolLocal, dividendoGolVisitante,
    dividendoDosGolesLocal, dividendoDosGolesVisitante, dividendoUnGolCadaUno,
    dividendoTresGolesLocal, dividendoTresGolesVisitante,
    dividendoUnGolLocalDosVisitante, dividendoDosGolesLocalUnoVisitante: ^TDividendo;
    constructor Create(columnas: array of TColumna; kMinuto: integer);
    procedure Free;

  end;

  { TPartido }

  TPartido = class
    local, visitante: string;
    id: integer;
    resultadoParcial, resultadoFinal: string;
    estado, tiempo: string;
    golesLocal, golesVisitante, cantidadDeGoles: integer;
    minutos: array of TMinuto;
    dividendos: array of TDividendo;
    eventos: array of string;
    distanciaMaxima: NReal;
    minutoDelPrimerGol: integer;
    minutoEnQueLaSIDSuperaElUmbral, minutoEnQueLaSIDSuperaElUmbral2,
    minutoEnQueLaSIDSuperaElUmbral3: integer;
    SIDInicial, SID2Inicial, SID3Inicial: NReal;
    poderDelFavorito: NReal;
    constructor Create(archi: string);
    procedure Free;
    procedure tratarColumna(hoja: TsWorksheet; kColumna: integer);
    procedure getGoles;
    procedure writeToArchi;
    procedure getDistanciaMaxima;
    procedure registrarGol(kMinuto: integer);
    function esFactible: boolean;
  end;


  { TApostador }

  TApostador = class
    apuestas: array of TApuesta;
    apuestaMinima, umbralSumaInversas, gananciaFinal, totalApostado,
    perdido, ganado, neto: NReal;
    partido: TPartido;
    metodo: integer;
    sidUmbralInicial: NReal;
    constructor Create(xapuestaMinima, xumbralSumaInversas: NReal;
      xpartido: TPartido; xmetodo: integer; xsidUmbralInicialmin: NReal);
    procedure Free;
    procedure apostar;
    procedure writeToArchi;
    procedure calcularNetos;
    // devuelve True si hay que parar porque se paso el umbral
    function calcularParcialYSacarSiNecesario: boolean;

  end;

  { TEstadistica }

  TEstadistica = class
    resultadosFinales: array of string;
    ids, cantidadDeGoles, minutoDelPrimerGol, minutoEnQueLaSIDSuperaElUmbral,
    minutoEnQueLaSIDSuperaElUmbral2, minutoEnQueLaSIDSuperaElUmbral3: array of integer;
    SIDInicial, SID2Inicial, SID3Inicial: array of NReal;
    resultadosApuestas, totalesApostados: array of NReal;
    poderDelFavorito: array of NReal;
    constructor Create;
    procedure Free;
    procedure writeToArchi;
    procedure agregarEstadistica(partido: TPartido;
      resultadoApuesta, totalApostado: NReal);

  end;



// Devuelve el indice de la columna anterior o -1 si no la encontro
function buscarTiempoAnterior(columnas: array of TColumna; kMinuto: integer): integer;
// Devuelve el indice de la columna siguiente o -1 si no la encontro
function buscarTiempoSiguiente(columnas: array of TColumna; kMinuto: integer): integer;
//  Devuelve el mayor dividendo segun el metodo
function getMayorDividendo(minuto: TMinuto; metodo: integer): NReal;

procedure fijarseSiYaSeApostoEnEsePaso(apuestas: array of TApuesta;
  minuto: TMinuto; var marcadoresYaApostados: array of boolean; paso: integer);
// devuelve true si esta todo bien
function condicionUmbral(minuto: TMinuto; metodo: integer;
  umbralSumaInversas: NReal): boolean;

procedure apostarPaso0(marcadoresYaApostados: array of boolean;
  var apuestas: TDAOfTApuesta; apuestaMinima, mayorDividendo: NReal;
  minuto: TMinuto; kMinuto, paso, metodo: integer);

procedure apostarPasoNo0(marcadoresYaApostados: array of boolean;
  var apuestas: TDAOfTApuesta; minuto: TMinuto; kMinuto, paso, metodo: integer;
  pagoDelPasoAnterior, sumaDeLasInversasDeLosDividendosSinLosApostados,
  sumaDeLasInversasDeLosDividendos: NReal);


procedure getSumaDeLasInversasDeLosDividendos(minuto: TMinuto;
  var sumaDeLasInversasDeLosDividendos: NReal;
  var sumaDeLasInversasDeLosDividendosSinLosApostados: NReal; metodo: integer);


implementation

procedure evaluar(metodo: integer);
var
  nombres: TStringList;
  kNombre: integer;
  partido: TPartido;
  apostador: Tapostador;
  estadistica: TEstadistica;
begin

  nombres := getPartidos();
  estadistica := TEstadistica.Create;

  for kNombre := 0 to nombres.Count - 1 do
  begin
    {$IFDEF VERBOSO}
    writeln('Evaluando ', nombres[kNombre]);
    {$ENDIF}
    partido := TPartido.Create(nombres[kNombre]);
    partido.writeToArchi;
    apostador := TApostador.Create(APUESTAMINIMA, SIDUMBRAL, partido,
      metodo, SIDUMBRALINICIALMIN);
    if partido.esFactible then
    begin
      apostador.apostar;
      apostador.writeToArchi;
      estadistica.agregarEstadistica(partido, apostador.neto, apostador.totalApostado);
    end
    else
    begin
     {$IFDEF VERBOSO}
      writeln('El partido ID =  ', partido.id, ' es infactible, TMAX = ',
        partido.distanciaMaxima: 2: 0);
     {$ENDIF}
    end;
    apostador.Free;
    partido.Free;
  end;
  FreeAndNil(nombres);
  estadistica.writeToArchi;
  estadistica.Free;
end;

function getPartidos(): TStringList;
var
  nombres: TStringList;
  busqueda: string;
  archivos: TSearchRec;
  res: integer;
begin
  nombres := TStringList.Create;
  chdir('partidos_raw');
  busqueda := GetCurrentDir + DirectorySeparator + '*.xlsx';
  res := FindFirst(busqueda, faAnyFile, archivos);
  if res = 0 then
    nombres.Add(archivos.Name);
  while FindNext(archivos) = 0 do
    nombres.Add(archivos.Name);
  FindClose(archivos);
  Result := nombres;
end;

function getEstado(str: string): string;
begin
  if Pos('prematch', str) <> 0 then
    Result := 'No iniciado'
  else
  if Pos('Descanso', str) <> 0 then
    Result := 'Descanso'
  else
  if Pos('Finalizado', str) <> 0 then
    Result := 'Finalizado'
  else
  if Pos('abandoned', str) <> 0 then
    Result := 'Finalizado'
  else
    Result := 'En Juego';
end;

function getMarcador(str: string): string;
var
  res: string;
begin
  res := RightStr(str, 3);
  if res = '-:-' then
    res := '0:0';
  Result := res;
end;

function getTiempo(str: string): string;
var
  xlinea: string;
begin
  xlinea := StringReplace(str, 'Tiempo: ', '', [rfReplaceAll]);
  Result := xlinea;
end;

function contarColumnas(hoja: TsWorksheet): integer;
var
  celda: string;
  hayDatos: boolean;
  kColumna, NColumnas: integer;
begin
  kColumna := 0;
  NColumnas := 0;
  hayDatos := True;

  while hayDatos do
  begin
    celda := hoja.ReadAsText(0, kColumna);
    if celda <> '' then
      Inc(NColumnas)
    else
      hayDatos := False;
    Inc(kColumna);
  end;
  Result := NColumnas;
end;

function buscarTiempoAnterior(columnas: array of TColumna; kMinuto: integer): integer;
var
  kColumna, minutoColumna: integer;
  buscando: boolean;
  res: integer;

begin
  kColumna := 0;
  buscando := True;
  res := -1;

  while buscando and (kColumna < Length(columnas)) do
  begin
    minutoColumna := getMinuto(columnas[kColumna].tiempo, columnas[kColumna].estado);
    if kMinuto = 0 then
    begin
      if minutoColumna = 0 then
      begin
        res := kColumna;
        buscando := False;
      end;
    end
    else
    begin
      if minutoColumna < kMinuto then
        res := kColumna;
      if minutoColumna >= kMinuto then
        buscando := False;
    end;
    Inc(kColumna);
  end;
  Result := res;
end;

function buscarTiempoSiguiente(columnas: array of TColumna; kMinuto: integer): integer;
var
  kColumna, minutoColumna: integer;
  buscando: boolean;
  res: integer;

begin
  kColumna := 0;
  buscando := True;
  res := -1;

  while buscando and (kColumna < Length(columnas)) do
  begin
    minutoColumna := getMinuto(columnas[kColumna].tiempo, columnas[kColumna].estado);
    if kMinuto = 90 then
      buscando := False
    else
    begin
      if minutoColumna >= kMinuto then
      begin
        res := kColumna;
        buscando := False;
      end;
    end;
    Inc(kColumna);
  end;
  Result := res;
end;

function getMayorDividendo(minuto: TMinuto; metodo: integer): NReal;
var
  res: NReal;
begin
  res := 0;
  case metodo of
    1:
    begin
      res := MaxValue([minuto.dividendoDelMarcadorActual.dividendo,
        minuto.dividendoGolLocal.dividendo, minuto.dividendoGolVisitante.dividendo]);
    end;
    2:
    begin
      res := MaxValue([minuto.dividendoDelMarcadorActual.dividendo,
        minuto.dividendoGolLocal.dividendo, minuto.dividendoGolVisitante.dividendo,
        minuto.dividendoDosGolesLocal.dividendo,
        minuto.dividendoUnGolCadaUno.dividendo,
        minuto.dividendoDosGolesVisitante.dividendo]);
    end;
    3:
    begin
      res := MaxValue([minuto.dividendoDelMarcadorActual.dividendo,
        minuto.dividendoGolLocal.dividendo, minuto.dividendoGolVisitante.dividendo,
        minuto.dividendoDosGolesLocal.dividendo,
        minuto.dividendoUnGolCadaUno.dividendo,
        minuto.dividendoDosGolesVisitante.dividendo,
        minuto.dividendoTresGolesLocal.dividendo,
        minuto.dividendoDosGolesLocalUnoVisitante.dividendo,
        minuto.dividendoUnGolLocalDosVisitante.dividendo,
        minuto.dividendoTresGolesVisitante.dividendo]);
    end;
    else
      res := -1;
  end;
  Result := res;
end;

procedure fijarseSiYaSeApostoEnEsePaso(apuestas: array of TApuesta;
  minuto: TMinuto; var marcadoresYaApostados: array of boolean; paso: integer);
var
  NApuestas, kApuesta, NMarcadores, kMarcador: integer;
  apuesta: TApuesta;
begin
  NApuestas := Length(apuestas);
  NMarcadores := Length(marcadoresYaApostados);
  for kMarcador := 0 to NMarcadores - 1 do
    marcadoresYaApostados[kMarcador] := False;
  for kApuesta:=0 to NApuestas - 1 do
  begin
    apuesta:=apuestas[kApuesta];
    for kMarcador := 0 to NMarcadores - 1 do
    begin
      if (apuesta.resultado = minuto.marcadores[kMarcador]) and (apuesta.paso = paso) then
        marcadoresYaApostados[kMarcador] := True;
    end;
  end;
end;

function condicionUmbral(minuto: TMinuto; metodo: integer;
  umbralSumaInversas: NReal): boolean;
var
  res: boolean;
begin
  res := False;
  case metodo of
    1:
    begin
      res := (minuto.sumaDeLasInversasDeLosDividendos < umbralSumaInversas) and
        (minuto.sumaDeLasInversasDeLosDividendos > 0);
    end;
    2:
    begin
      res := (minuto.sumaDeLasInversasDeLosDividendos2 < umbralSumaInversas) and
        (minuto.sumaDeLasInversasDeLosDividendos2 > 0);
    end;
    3:
    begin
      res := (minuto.sumaDeLasInversasDeLosDividendos3 < umbralSumaInversas) and
        (minuto.sumaDeLasInversasDeLosDividendos3 > 0);
    end;
    else
      res := False;
  end;
  Result := res;
end;



procedure apostarPaso0(marcadoresYaApostados: array of boolean;
  var apuestas: TDAOfTApuesta; apuestaMinima, mayorDividendo: NReal;
  minuto: TMinuto; kMinuto, paso, metodo: integer);
begin
  case metodo of
    1:
    begin
      if not marcadoresYaApostados[0] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta del resultado actual
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoDelMarcadorActual.dividendo,
          minuto.dividendoDelMarcadorActual.dividendo, minuto.marcadores[0], kMinuto, paso);
      end;
      if not marcadoresYaApostados[1] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoGolLocal.dividendo, minuto.dividendoGolLocal.dividendo,
          minuto.marcadores[1], kMinuto, paso);
      end;
      if not marcadoresYaApostados[2] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoGolVisitante.dividendo,
          minuto.dividendoGolVisitante.dividendo, minuto.marcadores[2], kMinuto, paso);
      end;
    end;
    2:
    begin
      // si no lo hicimos lo hacemos
      if not marcadoresYaApostados[0] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta del resultado actual
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoDelMarcadorActual.dividendo,
          minuto.dividendoDelMarcadorActual.dividendo, minuto.marcadores[0], kMinuto, paso);
      end;
      if not marcadoresYaApostados[1] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoGolLocal.dividendo, minuto.dividendoGolLocal.dividendo,
          minuto.marcadores[1], kMinuto, paso);
      end;
      if not marcadoresYaApostados[2] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoGolVisitante.dividendo,
          minuto.dividendoGolVisitante.dividendo,minuto.marcadores[2], kMinuto, paso);
      end;
      // tres mas
      if not marcadoresYaApostados[3] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de dos mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoDosGolesLocal.dividendo,
          minuto.dividendoDosGolesLocal.dividendo,minuto.marcadores[3], kMinuto, paso);
      end;
      if not marcadoresYaApostados[4] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas a cada uno
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoUnGolCadaUno.dividendo,
          minuto.dividendoUnGolCadaUno.dividendo,minuto.marcadores[4], kMinuto, paso);
      end;
      if not marcadoresYaApostados[5] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de dos mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoDosGolesVisitante.dividendo,
          minuto.dividendoDosGolesVisitante.dividendo,
          minuto.marcadores[5],
          kMinuto, paso);
      end;
    end;
    3:
    begin
      if not marcadoresYaApostados[0] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta del resultado actual
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoDelMarcadorActual.dividendo,
          minuto.dividendoDelMarcadorActual.dividendo, minuto.marcadores[0], kMinuto, paso);
      end;
      if not marcadoresYaApostados[1] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoGolLocal.dividendo, minuto.dividendoGolLocal.dividendo,
          minuto.marcadores[1], kMinuto, paso);
      end;
      if not marcadoresYaApostados[2] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoGolVisitante.dividendo,
          minuto.dividendoGolVisitante.dividendo, minuto.marcadores[2], kMinuto, paso);
      end;
      if not marcadoresYaApostados[3] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de dos mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoDosGolesLocal.dividendo,
          minuto.dividendoDosGolesLocal.dividendo, minuto.marcadores[3], kMinuto, paso);
      end;
      if not marcadoresYaApostados[4] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas a cada uno
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoUnGolCadaUno.dividendo,
          minuto.dividendoUnGolCadaUno.dividendo, minuto.marcadores[4], kMinuto, paso);
      end;
      if not marcadoresYaApostados[5] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de dos mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoDosGolesVisitante.dividendo,
          minuto.dividendoDosGolesVisitante.dividendo,
          minuto.marcadores[5],
          kMinuto, paso);
      end;
      if not marcadoresYaApostados[6] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de tres mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoTresGolesLocal.dividendo,
          minuto.dividendoTresGolesLocal.dividendo,
          minuto.marcadores[6], kMinuto,paso);
      end;
      if not marcadoresYaApostados[7] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de uno mas al visitante y dos al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoDosGolesLocalUnoVisitante.dividendo,
          minuto.dividendoDosGolesLocalUnoVisitante.dividendo,
          minuto.marcadores[7], kMinuto, paso);
      end;
      if not marcadoresYaApostados[8] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de uno mas al local y dos al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoUnGolLocalDosVisitante.dividendo,
          minuto.dividendoUnGolLocalDosVisitante.dividendo,
          minuto.marcadores[8], kMinuto, paso);
      end;
      if not marcadoresYaApostados[9] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de tres mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(apuestaMinima * mayorDividendo /
          minuto.dividendoTresGolesVisitante.dividendo,
          minuto.dividendoTresGolesVisitante.dividendo,
          minuto.marcadores[9],
          kMinuto, paso);
      end;
    end;
    else
  end;
end;

procedure apostarPasoNo0(marcadoresYaApostados: array of boolean;
  var apuestas: TDAOfTApuesta; minuto: TMinuto; kMinuto, paso, metodo: integer;
  pagoDelPasoAnterior, sumaDeLasInversasDeLosDividendosSinLosApostados,
  sumaDeLasInversasDeLosDividendos: NReal);
begin
  case metodo of
    1:
    begin
      if not marcadoresYaApostados[0] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta del resultado actual
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          (1 / minuto.dividendoGolLocal.dividendo + 1 /
          minuto.dividendoGolVisitante.dividendo) /
          (minuto.dividendoDelMarcadorActual.dividendo *
          (1 - 1 / minuto.dividendoDelMarcadorActual.dividendo -
          1 / minuto.dividendoGolLocal.dividendo - 1 /
          minuto.dividendoGolVisitante.dividendo)),
          minuto.dividendoDelMarcadorActual.dividendo, minuto.marcador, kMinuto, paso);
      end;
      if not marcadoresYaApostados[1] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          (1 / minuto.dividendoGolLocal.dividendo + 1 /
          minuto.dividendoGolVisitante.dividendo) /
          (minuto.dividendoGolLocal.dividendo * (1 - 1 /
          minuto.dividendoDelMarcadorActual.dividendo - 1 /
          minuto.dividendoGolLocal.dividendo - 1 /
          minuto.dividendoGolVisitante.dividendo)) + pagoDelPasoAnterior /
          minuto.dividendoGolLocal.dividendo, minuto.dividendoGolLocal.dividendo,
          IntToStr(minuto.golesLocal + 1) + ':' +
          IntToStr(minuto.golesVisitante), kMinuto, paso);
      end;
      if not marcadoresYaApostados[2] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          (1 / minuto.dividendoGolLocal.dividendo + 1 /
          minuto.dividendoGolVisitante.dividendo) /
          (minuto.dividendoGolVisitante.dividendo *
          (1 - 1 / minuto.dividendoDelMarcadorActual.dividendo -
          1 / minuto.dividendoGolLocal.dividendo - 1 /
          minuto.dividendoGolVisitante.dividendo)) + pagoDelPasoAnterior /
          minuto.dividendoGolVisitante.dividendo,
          minuto.dividendoGolVisitante.dividendo, IntToStr(minuto.golesLocal) +
          ':' + IntToStr(minuto.golesVisitante + 1), kMinuto, paso);
      end;
    end;
    2:
    begin
      if not marcadoresYaApostados[0] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta del resultado actual
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoDelMarcadorActual.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)),
          minuto.dividendoDelMarcadorActual.dividendo, minuto.marcador, kMinuto, paso);
      end;
      if not marcadoresYaApostados[1] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoGolLocal.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)), minuto.dividendoGolLocal.dividendo,
          IntToStr(minuto.golesLocal + 1) + ':' +
          IntToStr(minuto.golesVisitante), kMinuto, paso);
      end;
      if not marcadoresYaApostados[2] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoGolVisitante.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)),
          minuto.dividendoGolVisitante.dividendo, IntToStr(minuto.golesLocal) +
          ':' + IntToStr(minuto.golesVisitante + 1), kMinuto, paso);
      end;
      if not marcadoresYaApostados[3] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de dos mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoDosGolesLocal.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)) + pagoDelPasoAnterior /
          minuto.dividendoDosGolesLocal.dividendo,
          minuto.dividendoDosGolesLocal.dividendo, IntToStr(minuto.golesLocal + 2) +
          ':' + IntToStr(minuto.golesVisitante), kMinuto, paso);
      end;
      if not marcadoresYaApostados[4] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas a cada uno
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoUnGolCadaUno.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)) + pagoDelPasoAnterior /
          minuto.dividendoUnGolCadaUno.dividendo,
          minuto.dividendoUnGolCadaUno.dividendo, IntToStr(minuto.golesLocal + 1) +
          ':' + IntToStr(minuto.golesVisitante + 1), kMinuto, paso);
      end;
      if not marcadoresYaApostados[5] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de dos mas al vistante
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoDosGolesVisitante.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)) + pagoDelPasoAnterior /
          minuto.dividendoDosGolesVisitante.dividendo,
          minuto.dividendoDosGolesVisitante.dividendo,
          IntToStr(minuto.golesLocal) + ':' + IntToStr(minuto.golesVisitante + 2),
          kMinuto, paso);
      end;
    end;
    3:
    begin
      if not marcadoresYaApostados[0] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta del resultado actual
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoDelMarcadorActual.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)),
          minuto.dividendoDelMarcadorActual.dividendo, minuto.marcador, kMinuto, paso);
      end;
      if not marcadoresYaApostados[1] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoGolLocal.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos))
          , minuto.dividendoGolLocal.dividendo, IntToStr(minuto.golesLocal + 1) +
          ':' + IntToStr(minuto.golesVisitante), kMinuto, paso);
      end;
      if not marcadoresYaApostados[2] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoGolVisitante.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos))
          , minuto.dividendoGolVisitante.dividendo, IntToStr(minuto.golesLocal) +
          ':' + IntToStr(minuto.golesVisitante + 1), kMinuto, paso);
      end;
      if not marcadoresYaApostados[3] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de dos mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoDosGolesLocal.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos))
          , minuto.dividendoDosGolesLocal.dividendo,
          IntToStr(minuto.golesLocal + 2) + ':' + IntToStr(minuto.golesVisitante),
          kMinuto, paso);
      end;
      if not marcadoresYaApostados[4] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas a cada uno
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoUnGolCadaUno.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos))
          , minuto.dividendoUnGolCadaUno.dividendo, IntToStr(minuto.golesLocal + 1) +
          ':' + IntToStr(minuto.golesVisitante + 1), kMinuto, paso);
      end;
      if not marcadoresYaApostados[5] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de dos mas al vistante
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoDosGolesVisitante.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos))
          , minuto.dividendoDosGolesVisitante.dividendo,
          IntToStr(minuto.golesLocal) + ':' + IntToStr(minuto.golesVisitante + 2),
          kMinuto, paso);
      end;
      if not marcadoresYaApostados[6] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de tres goles mas al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoTresGolesLocal.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)) + pagoDelPasoAnterior /
          minuto.dividendoTresGolesLocal.dividendo,
          minuto.dividendoTresGolesLocal.dividendo, IntToStr(minuto.golesLocal + 3) +
          ':' + IntToStr(minuto.golesVisitante), kMinuto, paso);
      end;
      if not marcadoresYaApostados[7] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al vistante y dos al local
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoDosGolesLocalUnoVisitante.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)) + pagoDelPasoAnterior /
          minuto.dividendoDosGolesLocalUnoVisitante.dividendo,
          minuto.dividendoDosGolesLocalUnoVisitante.dividendo,
          IntToStr(minuto.golesLocal + 2) + ':' + IntToStr(minuto.golesVisitante + 1),
          kMinuto, paso);
      end;
      if not marcadoresYaApostados[8] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de un gol mas al local y dos al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoUnGolLocalDosVisitante.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)) + pagoDelPasoAnterior /
          minuto.dividendoUnGolLocalDosVisitante.dividendo,
          minuto.dividendoUnGolLocalDosVisitante.dividendo,
          IntToStr(minuto.golesLocal + 1) + ':' + IntToStr(minuto.golesVisitante + 2),
          kMinuto, paso);
      end;
      if not marcadoresYaApostados[9] then
      begin
        SetLength(apuestas, Length(apuestas) + 1);
        // apuesta de tres goles mas al visitante
        apuestas[High(apuestas)] :=
          TApuesta.Create(pagoDelPasoAnterior *
          sumaDeLasInversasDeLosDividendosSinLosApostados /
          (minuto.dividendoTresGolesVisitante.dividendo *
          (1 - sumaDeLasInversasDeLosDividendos)) + pagoDelPasoAnterior /
          minuto.dividendoTresGolesVisitante.dividendo,
          minuto.dividendoTresGolesVisitante.dividendo,
          IntToStr(minuto.golesLocal) + ':' + IntToStr(minuto.golesVisitante + 3),
          kMinuto, paso);
      end;

    end;
    else
  end;
end;

procedure getSumaDeLasInversasDeLosDividendos(minuto: TMinuto;
  var sumaDeLasInversasDeLosDividendos: NReal;
  var sumaDeLasInversasDeLosDividendosSinLosApostados: NReal; metodo: integer);
begin
  case metodo of
    2:
    begin
      sumaDeLasInversasDeLosDividendos :=
        1 / minuto.dividendoDelMarcadorActual.dividendo + 1 /
        minuto.dividendoGolLocal.dividendo + 1 /
        minuto.dividendoGolVisitante.dividendo + 1 /
        minuto.dividendoDosGolesLocal.dividendo + 1 /
        minuto.dividendoDosGolesVisitante.dividendo + 1 /
        minuto.dividendoUnGolCadaUno.dividendo;
      sumaDeLasInversasDeLosDividendosSinLosApostados :=
        sumaDeLasInversasDeLosDividendos - 1 /
        minuto.dividendoDelMarcadorActual.dividendo - 1 /
        minuto.dividendoGolLocal.dividendo - 1 /
        minuto.dividendoGolVisitante.dividendo;
    end;

    3:
    begin
      sumaDeLasInversasDeLosDividendos :=
        1 / minuto.dividendoDelMarcadorActual.dividendo + 1 /
        minuto.dividendoGolLocal.dividendo + 1 /
        minuto.dividendoGolVisitante.dividendo + 1 /
        minuto.dividendoDosGolesLocal.dividendo + 1 /
        minuto.dividendoDosGolesVisitante.dividendo + 1 /
        minuto.dividendoUnGolCadaUno.dividendo + 1 /
        minuto.dividendoTresGolesLocal.dividendo + 1 /
        minuto.dividendoTresGolesVisitante.dividendo + 1 /
        minuto.dividendoUnGolLocalDosVisitante.dividendo + 1 /
        minuto.dividendoDosGolesLocalUnoVisitante.dividendo;

      sumaDeLasInversasDeLosDividendosSinLosApostados :=
        sumaDeLasInversasDeLosDividendos - 1 /
        minuto.dividendoDelMarcadorActual.dividendo - 1 /
        minuto.dividendoGolLocal.dividendo - 1 /
        minuto.dividendoGolVisitante.dividendo - 1 /
        minuto.dividendoDosGolesLocal.dividendo - 1 /
        minuto.dividendoDosGolesVisitante.dividendo - 1 /
        minuto.dividendoUnGolCadaUno.dividendo;
    end;
    else
  end;
end;



function getGolesLocal(resultado: string): integer;
var
  str: string;
begin
  str := LeftStr(resultado, 1);
  if str = '-' then
    Result := 0
  else
    Result := StrToInt(str);
end;

function getGolesVisitante(resultado: string): integer;
var
  str: string;
begin
  str := RightStr(resultado, 1);
  if str = '-' then
    Result := 0
  else
    Result := StrToInt(str);
end;

function getMinuto(tiempo, estado: string): integer;
var
  partes: array of string;
begin
  if tiempo = '' then
  begin
    if estado = 'No iniciado' then
      Result := 0
    else
    if estado = 'Descanso' then
      Result := 45
    else
    if estado = 'Finalizado' then
      Result := 90;
  end
  else
  begin
    partes := tiempo.split(':');
    Result := StrToInt(partes[0]);
  end;
end;

function getSegundo(tiempo: string): integer;
var
  partes: array of string;
begin
  if tiempo = '' then
    Result := 0
  else
  begin
    partes := tiempo.split(':');
    Result := StrToInt(LeftStr(partes[1], 2));
  end;
end;

procedure crearSiNoExiste(dirName: String);
begin
  if not DirectoryExists(dirName) then
    MkDir(dirName);
end;

{ TEstadistica }

constructor TEstadistica.Create;
begin
  inherited Create;
end;

procedure TEstadistica.Free;
begin
    SetLength(resultadosFinales,0);
    SetLength(ids,0);
    SetLength(cantidadDeGoles,0);
    SetLength(minutoDelPrimerGol,0);
    SetLength(minutoEnQueLaSIDSuperaElUmbral,0);
    SetLength(minutoEnQueLaSIDSuperaElUmbral2,0);
    SetLength(minutoEnQueLaSIDSuperaElUmbral3,0);
    SetLength(SIDInicial,0);
    SetLength(SID2Inicial,0);
    SetLength(SID3Inicial,0);
    SetLength(resultadosApuestas,0);
    SetLength(totalesApostados,0);
    SetLength(poderDelFavorito,0);
    inherited Free;
end;

procedure TEstadistica.writeToArchi;
var
  xls: TLibroOpenCalc;
  archi: string;
  kPartido, NPartidos: integer;
begin
  archi := 'C:\basura\resumenEstadistica.xlsx';
  xls := TLibroOpenCalc.Create(True, archi);
  xls.ActiveWorksheet.Name := 'Resumen';
  xls.Write('ID');
  xls.Write('Resultado');
  xls.Write('Cantidad de goles');
  xls.Write('Minuto del primer gol');
  xls.Write('Minuto en que la SID supera el umbral ' + FloatToStr(SIDUMBRAL));
  xls.Write('Minuto en que la SID supera el umbral 2 ' + FloatToStr(SIDUMBRAL));
  xls.Write('Minuto en que la SID supera el umbral 3 ' + FloatToStr(SIDUMBRAL));
  xls.Write('SID inicial');
  xls.Write('SID2 inicial');
  xls.Write('SID3 inicial');
  xls.Write('Resultado apuesta');
  xls.Write('Total apostado');
  xls.Write('Poder del favorito');
  xls.writeln();


  NPartidos := length(ids);

  for kPartido := 0 to NPartidos - 1 do
  begin
    xls.Write(ids[kPartido]);
    xls.Write(resultadosFinales[kPartido]);
    xls.Write(cantidadDeGoles[kPartido]);
    xls.Write(minutoDelPrimerGol[kPartido]);
    xls.Write(minutoEnQueLaSIDSuperaElUmbral[kPartido]);
    xls.Write(minutoEnQueLaSIDSuperaElUmbral2[kPartido]);
    xls.Write(minutoEnQueLaSIDSuperaElUmbral3[kPartido]);
    xls.Write(SIDInicial[kPartido]);
    xls.Write(SID2Inicial[kPartido]);
    xls.Write(SID3Inicial[kPartido]);
    xls.Write(resultadosApuestas[kPartido]);
    xls.Write(totalesApostados[kPartido]);
    xls.Write(poderDelFavorito[kPartido]);
    xls.writeln();
    xls.Guardar;
  end;
  xls.Free;
end;

procedure TEstadistica.agregarEstadistica(partido: TPartido;
  resultadoApuesta, totalApostado: NReal);
begin

  Setlength(ids, Length(ids) + 1);
  Setlength(resultadosFinales, Length(resultadosFinales) + 1);
  Setlength(cantidadDeGoles, Length(cantidadDeGoles) + 1);
  Setlength(minutoDelPrimerGol, Length(minutoDelPrimerGol) + 1);
  Setlength(minutoEnQueLaSIDSuperaElUmbral, Length(minutoEnQueLaSIDSuperaElUmbral) + 1);
  Setlength(minutoEnQueLaSIDSuperaElUmbral2,
    Length(minutoEnQueLaSIDSuperaElUmbral2) + 1);
  Setlength(minutoEnQueLaSIDSuperaElUmbral3,
    Length(minutoEnQueLaSIDSuperaElUmbral3) + 1);
  Setlength(SIDInicial, Length(SIDInicial) + 1);
  Setlength(resultadosApuestas, Length(resultadosApuestas) + 1);
  Setlength(totalesApostados, Length(totalesApostados) + 1);
  Setlength(poderDelFavorito, Length(poderDelFavorito) + 1);
  Setlength(SID2Inicial, Length(SID2Inicial) + 1);
  Setlength(SID3Inicial, Length(SID3Inicial) + 1);

  ids[High(ids)] := partido.id;
  resultadosFinales[High(resultadosFinales)] := partido.resultadoFinal;
  cantidadDeGoles[High(cantidadDeGoles)] := partido.cantidadDeGoles;
  minutoDelPrimerGol[High(minutoDelPrimerGol)] := partido.minutoDelPrimerGol;
  minutoEnQueLaSIDSuperaElUmbral[High(minutoEnQueLaSIDSuperaElUmbral)] :=
    partido.minutoEnQueLaSIDSuperaElUmbral;
  minutoEnQueLaSIDSuperaElUmbral2[High(minutoEnQueLaSIDSuperaElUmbral2)] :=
    partido.minutoEnQueLaSIDSuperaElUmbral2;
  minutoEnQueLaSIDSuperaElUmbral3[High(minutoEnQueLaSIDSuperaElUmbral3)] :=
    partido.minutoEnQueLaSIDSuperaElUmbral3;
  SIDInicial[High(SIDInicial)] := partido.SIDInicial;
  resultadosApuestas[High(resultadosApuestas)] := resultadoApuesta;
  totalesApostados[High(totalesApostados)] := totalApostado;
  poderDelFavorito[High(poderDelFavorito)] := partido.poderDelFavorito;
  SID2Inicial[High(SID2Inicial)] := partido.SID2Inicial;
  SID3Inicial[High(SID3Inicial)] := partido.SID3Inicial;
end;

{ TApuesta }

constructor TApuesta.Create(xmonto, xdividendo: NReal; xresultado: string;
  xminuto, xpaso: integer);
begin
  inherited Create;
  monto := xmonto;
  dividendo := xdividendo;
  resultado := xresultado;
  pago := monto * dividendo;
  minuto := xminuto;
  paso := xpaso;
end;

procedure TApuesta.Free;
begin
  inherited Free;
end;

{ TApostador }

constructor TApostador.Create(xapuestaMinima, xumbralSumaInversas: NReal;
  xpartido: TPartido; xmetodo: integer; xsidUmbralInicialmin: NReal);
begin
  inherited Create;
  apuestaMinima := xapuestaMinima;
  umbralSumaInversas := xumbralSumaInversas;
  partido := xpartido;
  metodo := xmetodo;
  sidUmbralInicial := xsidUmbralInicialmin;
end;

procedure TApostador.Free;
var
  kApuesta, NApuestas: integer;
begin
  NApuestas := Length(apuestas);
  for kApuesta := 0 to NApuestas - 1 do
    apuestas[kApuesta].Free;
  SetLength(apuestas, 0);
  inherited Free;
end;

procedure TApostador.apostar;
var
  kMinuto, NMinutos, NMarcadores, kMarcador: integer;
  minuto: TMinuto;
  mayorDividendo: NReal;
  paso: integer;
  pagoDelPasoAnterior: NReal;
  marcadoresYaApostados: array of boolean;
  sumaDeLasInversasDeLosDividendosSinLosApostados,
  sumaDeLasInversasDeLosDividendos: NReal;
begin
  NMinutos := Length(partido.minutos);
  paso := 0;
  NMarcadores := trunc(0.5 * sqr(metodo) + 1.5 * metodo + 1);
  SetLength(marcadoresYaApostados, NMarcadores);
  sumaDeLasInversasDeLosDividendosSinLosApostados := 0;
  sumaDeLasInversasDeLosDividendos := 0;
  for kMinuto := 0 to NMinutos - 1 do
  begin
    for kMarcador := 0 to NMarcadores - 1 do
    begin
      marcadoresYaApostados[kMarcador] := False;
    end;
    minuto := partido.minutos[kMinuto];
    if (kMinuto > 0) and (minuto.marcador <> partido.minutos[kMinuto - 1].marcador) then
      Inc(paso);
    if condicionUmbral(minuto, metodo, umbralSumaInversas) then
    begin
      if paso = 0 then
      begin
        mayorDividendo := getMayorDividendo(minuto, metodo);
        if (not (condicionUmbral(minuto, metodo, sidUmbralInicial))) and
          (Length(apuestas) = 0) and (mayorDividendo > 0 )then
          break;
        fijarseSiYaSeApostoEnEsePaso(apuestas, minuto, marcadoresYaApostados,
          paso);
        apostarPaso0(marcadoresYaApostados, apuestas, apuestaMinima, mayorDividendo,
          minuto, kMinuto, paso, metodo);
        pagoDelPasoAnterior := apuestas[High(apuestas)].pago;
      end
      else
      begin
        sumaDeLasInversasDeLosDividendos := 0;
        sumaDeLasInversasDeLosDividendosSinLosApostados := 0;
        fijarseSiYaSeApostoEnEsePaso(apuestas, minuto, marcadoresYaApostados,
           paso);
        getSumaDeLasInversasDeLosDividendos(minuto, sumaDeLasInversasDeLosDividendos,
          sumaDeLasInversasDeLosDividendosSinLosApostados, metodo);
        apostarPasoNo0(marcadoresYaApostados, apuestas,
          minuto, kMinuto, paso, metodo, pagoDelPasoAnterior,
          sumaDeLasInversasDeLosDividendosSinLosApostados,
          sumaDeLasInversasDeLosDividendos);
        pagoDelPasoAnterior := apuestas[High(apuestas)].pago;
      end;
    end;
    if calcularParcialYSacarSiNecesario then
      break;
  end;
  calcularNetos;
end;

procedure TApostador.writeToArchi;
var
  xls: TLibroOpenCalc;
  kApuesta, NApuestas: integer;
  apuesta: TApuesta;

begin

  xls := TLibroOpenCalc.Create(True, 'C:\basura\' + IntToStr(partido.id) + '_RES.xlsx');

  xls.ActiveWorksheet.Name := 'Resumen';

  xls.Write('Resultado');
  xls.Write('Dividendo');
  xls.Write('Apuesta');
  xls.Write('Pago');
  xls.Write('Minuto');
  xls.Write('Paso');
  xls.writeln();

  NApuestas := Length(apuestas);

  for kApuesta := 0 to NApuestas - 1 do
  begin
    apuesta := apuestas[kApuesta];
    xls.Write(apuesta.resultado);
    xls.Write(apuesta.dividendo);
    xls.Write(apuesta.monto);
    xls.Write(apuesta.pago);
    xls.Write(apuesta.minuto);
    xls.Write(apuesta.paso);
    xls.writeln();
  end;

  xls.writeln();
  xls.Writeln('Resultado Final');
  xls.writeln(partido.resultadoFinal);
  xls.Writeln('Total Apostado');
  xls.writeln(totalApostado);
  xls.Writeln('Neto');
  xls.writeln(neto);

  xls.Guardar;

  xls.Free;
end;

procedure TApostador.calcularNetos;
var
  NApuestas, kApuesta: integer;
  apuesta: TApuesta;
begin
  NApuestas := Length(apuestas);
  perdido := 0;
  ganado := 0;
  totalApostado := 0;

  for kApuesta := 0 to NApuestas - 1 do
  begin
    apuesta := apuestas[kApuesta];
    if partido.resultadoFinal <> apuesta.resultado then
      perdido := perdido + apuesta.monto
    else
      ganado := ganado + apuesta.pago - apuesta.monto;
    totalApostado := totalApostado + apuesta.monto;
  end;

  neto := ganado - perdido;

  if neto > 0 then
    Write('Se ganaron ', neto: 2: 0, ' pesos ')
  else
    Write('Se perdieron ', -1 * neto: 2: 0, ' pesos ');

  WriteLn('en el partido ID= ', partido.id);
end;

function TApostador.calcularParcialYSacarSiNecesario: boolean;
var
  NApuestas, kApuesta: integer;
  apuesta: TApuesta;
  parcialApostado: NReal;
  res: boolean;
begin
  res := False;
  NApuestas := Length(apuestas);
  parcialApostado := 0;
  for kApuesta := 0 to NApuestas - 1 do
  begin
    apuesta := apuestas[kApuesta];
    parcialApostado := parcialApostado + apuesta.monto;
  end;
  if parcialApostado > UMBRALSUMADEAPUESTASMAXIMA then
  begin
    for kApuesta := NApuestas - 1 downto NApuestas - 3 do
      apuestas[kApuesta].Free;
    SetLength(apuestas, Length(apuestas) - 3);
    res := True;
  end;
  Result := res;
end;

{ TColumna }

constructor TColumna.Create(hoja: TsWorksheet; kColumna: integer);
var
  kFila: integer;
  hayDatos: boolean;
  str: string;
begin
  kFila := 0;
  hayDatos := True;
  str := hoja.ReadAsText(0, kColumna);
  if str = '' then
    estado := 'Finalizado'
  else
  begin
    while hayDatos do
    begin
      str := hoja.ReadAsText(kFila, kColumna);
      if str = '' then
        hayDatos := False;
      if Pos('Estado', str) <> 0 then
        estado := getEstado(str);
      if Pos('Marcador:', str) <> 0 then
      begin
        marcador := getMarcador(str);
      end;
      if Pos('Marcador Exacto', str) <> 0 then
      begin
        if marcador <> '' then
        begin
          SetLength(dividendos, Length(dividendos) + 1);
          dividendos[High(dividendos)] := TDividendo.Create(str, marcador);
        end;
      end;
      if Pos('Tiempo', str) <> 0 then
        tiempo := getTiempo(str);
      Inc(kFila);
    end;
    minuto := getMinuto(tiempo, estado);
    segundo := getSegundo(tiempo);
    {$IFDEF VERBOSO}
    writeln('Estado: ', estado, '; Marcador: ', marcador,
      ' Tiempo: ', tiempo);
    for kDividendo := 0 to high(dividendos) do
      writeln('Dividendo: ', dividendos[kDividendo].resultado, '; ',
        dividendos[kDividendo].dividendo: 0: 2);
    {$ENDIF}
  end;
end;

procedure TColumna.Free;
var
  kDividendo, NDividendos: integer;

begin
  inherited Free;

  NDividendos := Length(dividendos);

  for kDividendo := 0 to NDividendos - 1 do
    dividendos[kDividendo].Free;
  SetLength(dividendos, 0);

end;


{ TMinuto }

constructor TMinuto.Create(columnas: array of TColumna; kMinuto: integer);
var
  kDividendo, NDividendos: integer;
  buscando: boolean;
  //marcadorAux: string;
begin
  inherited Create;
  minuto := kMinuto;

  // busco las columnas anterior y siguiente al minuto, trae -1 si no encuentra
  columnaAnterior := buscarTiempoAnterior(columnas, kMinuto);
  columnaSiguiente := buscarTiempoSiguiente(columnas, kMinuto);

  // calculo las distancias en minutos a ellas
  if columnaAnterior >= 0 then
    distanciaAColumnaAnterior :=
      abs(columnas[ColumnaAnterior].minuto + columnas[ColumnaAnterior].segundo /
      60.0 - kMinuto)
  else
    distanciaAColumnaAnterior := -1;
  if columnaSiguiente >= 0 then
    distanciaAColumnaSiguiente :=
      abs(columnas[columnaSiguiente].minuto + columnas[columnaSiguiente].segundo /
      60.0 - kMinuto)
  else
    distanciaAColumnaSiguiente := -1;

  // me quedo con el marcador y los dividendos de la mas cercana
  if (distanciaAColumnaSiguiente <> -1) and (distanciaAColumnaAnterior <> -1) then
  begin
    if distanciaAColumnaAnterior < distanciaAColumnaSiguiente then
    begin
      marcador := columnas[columnaAnterior].marcador;
      dividendos := @columnas[columnaAnterior].dividendos;
    end
    else
    begin
      marcador := columnas[columnaSiguiente].marcador;
      dividendos := @columnas[columnaSiguiente].dividendos;
    end;
  end
  else
  begin
    if distanciaAColumnaSiguiente = -1 then
    begin
      if distanciaAColumnaAnterior <> -1 then
      begin
        marcador := columnas[columnaAnterior].marcador;
        dividendos := @columnas[columnaAnterior].dividendos;
      end;
    end
    else
    begin
      marcador := columnas[columnaSiguiente].marcador;
      dividendos := @columnas[columnaSiguiente].dividendos;
    end;
  end;

  // traigo los dividendos del marcador actual y los siguientes
  if marcador <> '' then
  begin
    golesLocal := getGolesLocal(marcador);
    golesVisitante := getGolesVisitante(marcador);
    cantidadDeGoles := golesLocal + golesVisitante;
    SetLength(marcadores,10);
    marcadores[0]:=marcador;
    marcadores[1]:=IntToStr(golesLocal + 1) + ':' + IntToStr(golesVisitante);
    marcadores[2]:=IntToStr(golesLocal) + ':' + IntToStr(golesVisitante + 1);
    marcadores[3]:=IntToStr(golesLocal + 2) + ':' + IntToStr(golesVisitante);
    marcadores[4]:=IntToStr(golesLocal + 1) + ':' + IntToStr(golesVisitante + 1);
    marcadores[5]:=IntToStr(golesLocal) + ':' + IntToStr(golesVisitante + 2);
    marcadores[6]:=IntToStr(golesLocal + 3) + ':' + IntToStr(golesVisitante);
    marcadores[7]:=IntToStr(golesLocal + 2) + ':' + IntToStr(golesVisitante + 1);
    marcadores[8]:=IntToStr(golesLocal + 1) + ':' + IntToStr(golesVisitante + 2);
    marcadores[9]:=IntToStr(golesLocal) + ':' + IntToStr(golesVisitante + 3);
  end;

  NDividendos := 0;
  if dividendos <> nil then
    NDividendos := Length(dividendos^);

  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcador then
    begin
      dividendoDelMarcadorActual := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;

  // creo un marcador con un gol mas para el local
  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcadores[1] then
    begin
      dividendoGolLocal := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;

  // lo mismo pero para un gol mas del visitante
  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcadores[2] then
    begin
      dividendoGolVisitante := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;

  // mas dos local
  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcadores[3] then
    begin
      dividendoDosGolesLocal := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;

  // mas uno cada uno
  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcadores[4] then
    begin
      dividendoUnGolCadaUno := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;

  // mas dos visitante
  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcadores[5] then
    begin
      dividendoDosGolesVisitante := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;

  // mas tres local
  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcadores[6] then
    begin
      dividendoTresGolesLocal := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;
  // mas uno visitante dos local
  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcadores[7] then
    begin
      dividendoDosGolesLocalUnoVisitante := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;

  // mas uno local dos visitante
  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcadores[8] then
    begin
      dividendoUnGolLocalDosVisitante := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;

  // mas tres visitante
  buscando := True;
  kDividendo := 0;
  while buscando and (kDividendo < NDividendos) do
  begin
    if dividendos[kDividendo].resultado = marcadores[9] then
    begin
      dividendoTresGolesVisitante := @dividendos[kDividendo];
      buscando := False;
    end;
    Inc(kDividendo);
  end;





  // Calculo de los SIDs
  sumaDeLasInversasDeLosDividendos := 0;
  sumaDeLasInversasDeLosDividendos2 := 0;
  sumaDeLasInversasDeLosDividendos3 := 0;

  if (dividendoDelMarcadorActual <> nil) and (dividendoGolLocal <> nil) and
    (dividendoGolVisitante <> nil) then
    sumaDeLasInversasDeLosDividendos :=
      1 / dividendoDelMarcadorActual.dividendo + 1 / dividendoGolLocal.dividendo +
      1 / dividendoGolVisitante.dividendo;


  if (dividendoDosGolesVisitante <> nil) and (dividendoDosGolesLocal <> nil) and
    (dividendoUnGolCadaUno <> nil) and (sumaDeLasInversasDeLosDividendos <> 0) then
    sumaDeLasInversasDeLosDividendos2 :=
      sumaDeLasInversasDeLosDividendos + 1 / dividendoDosGolesLocal.dividendo +
      1 / dividendoDosGolesVisitante.dividendo + 1 / dividendoUnGolCadaUno.dividendo;


  if (dividendoTresGolesLocal <> nil) and (dividendoTresGolesVisitante <> nil) and
    (dividendoUnGolLocalDosVisitante <> nil) and
    (dividendoDosGolesLocalUnoVisitante <> nil) and
    (sumaDeLasInversasDeLosDividendos <> 0) then
    sumaDeLasInversasDeLosDividendos3 :=
      sumaDeLasInversasDeLosDividendos2 + 1 / dividendoTresGolesLocal.dividendo +
      1 / dividendoTresGolesVisitante.dividendo + 1 /
      dividendoUnGolLocalDosVisitante.dividendo + 1 /
      dividendoDosGolesLocalUnoVisitante.dividendo;












end;

procedure TMinuto.Free;
begin
  inherited Free;
end;


{ TMarcador }

procedure TMarcador.actualizarResultado;
begin
  resultado := IntToStr(golesLocal) + ':' + IntToStr(golesVisitante);
end;

procedure TMarcador.golLocal;
begin
  Inc(golesLocal);
end;

procedure TMarcador.golVisitante;
begin
  Inc(golesVisitante);
end;

constructor TMarcador.Create();
begin
  inherited Create;
end;

procedure TMarcador.Free;
begin
  inherited Free;
end;

{ TDividendo }

constructor TDividendo.Create(linea: string; marcador: string);
var
  xlinea: string;
  partes: TStringArray;
begin
  inherited Create;
  xlinea := StringReplace(linea, 'Marcador Exacto ', '', [rfReplaceAll]);

  xlinea := StringReplace(xlinea, ',', '.', [rfReplaceAll]);
  FormatSettings.DecimalSeparator := '.';
  partes := SplitStr(xlinea, ';');

  dividendo := StrToFloat(partes[1]);

  resultado := partes[0];

  if resultado = 'otro' then
    esOtro := True
  else
  begin
    esOtro := False;
    golesAdicionalesLocal := getGolesLocal(resultado) - getGolesLocal(marcador);
    golesAdicionalesVisitante := getGolesVisitante(resultado) - getGolesLocal(marcador);
    golesAdicionalesTotales := golesAdicionalesVisitante + golesAdicionalesLocal;
  end;

  texto := resultado + ';' + FloatToStr(dividendo);
end;

procedure TDividendo.Free;
begin
  inherited Free;
end;

{ TPartido }

constructor TPartido.Create(archi: string);
var
  partes: TStringArray;
  kMinuto, kColumna, NColumnas, NMinutos: integer;
  libro: TsWorkbook;
  hoja: TsWorksheet;
  str: string;
  columnas: array of TColumna;
  columna: TColumna;
  hayColumnas: boolean;
  buscandoMinutoSIDUmbral, buscandoMinutoSIDUmbral2, buscandoMinutoSIDUmbral3: boolean;

begin
  inherited Create;

  kColumna := 0;
  NColumnas := 1;
  SetLength(columnas, 1);
  hayColumnas := True;

  libro := TsWorkbook.Create;
  libro.ReadFromFile(archi, sfOOXML);
  hoja := libro.GetFirstWorksheet;

  str := hoja.ReadAsText(0, kColumna);

  partes := str.split(['VS']);
  local := trim(partes[0]);
  partes := partes[1].Split('(');
  visitante := trim(partes[0]);
  id := StrToInt(RightStr(LeftStr(partes[1], Length(partes[1]) - 1),
    Length(partes[1]) - 4));

  {$IFDEF VERBOSO}
  writeln('Local: ', local);
  writeln('Visitante: ', visitante);
  writeln('ID: ', id);
  {$ENDIF}

  // creo un array con todas las columnas
  while hayColumnas do
  begin
    columna := TColumna.Create(hoja, kColumna);
    columnas[kColumna] := columna;
    Inc(kColumna);
    str := hoja.ReadAsText(0, kColumna);
    if str = '' then
      hayColumnas := False
    else
    begin
      Inc(NColumnas);
      SetLength(columnas, Length(columnas) + 1);
    end;
  end;

  // inicializacion de las variables
  minutoDelPrimerGol := -1;
  SIDInicial := 0;
  SID2Inicial := 0;
  minutoEnQueLaSIDSuperaElUmbral := -1;
  minutoEnQueLaSIDSuperaElUmbral2 := -1;
  minutoEnQueLaSIDSuperaElUmbral3 := -1;
  buscandoMinutoSIDUmbral := True;
  buscandoMinutoSIDUmbral2 := True;
  buscandoMinutoSIDUmbral3 := True;

  SetLength(minutos, 91);
  NMinutos := Length(minutos);
  for kMinuto := 0 to NMinutos - 1 do
  begin
    minutos[kMinuto] := TMinuto.Create(columnas, kMinuto);
    if (kMinuto > 0) and (minutos[kMinuto].cantidadDeGoles = 1) and
      (minutos[kMinuto - 1].cantidadDeGoles = 0) then
    begin
      minutoDelPrimerGol := kMinuto;
    end;

    // Minuto en que el SID supera el umbral, aca hay que tener cuidado porque
    if (kMinuto > 0) and (minutos[kMinuto].sumaDeLasInversasDeLosDividendos >=
      SIDUMBRAL) and buscandoMinutoSIDUmbral then
    begin
      minutoEnQueLaSIDSuperaElUmbral := kMinuto;
      buscandoMinutoSIDUmbral := False;
    end;

    if (kMinuto > 0) and (minutos[kMinuto].sumaDeLasInversasDeLosDividendos2 >=
      SIDUMBRAL) and buscandoMinutoSIDUmbral2 then
    begin
      minutoEnQueLaSIDSuperaElUmbral2 := kMinuto;
      buscandoMinutoSIDUmbral2 := False;
    end;

    if (kMinuto > 0) and (minutos[kMinuto].sumaDeLasInversasDeLosDividendos3 >=
      SIDUMBRAL) and buscandoMinutoSIDUmbral3 then
    begin
      minutoEnQueLaSIDSuperaElUmbral3 := kMinuto;
      buscandoMinutoSIDUmbral3 := False;
    end;

    // SIDs iniciales
    if (SIDInicial = 0) then
      SIDInicial := minutos[kMinuto].sumaDeLasInversasDeLosDividendos;

    if (SID2Inicial = 0) then
      SID2Inicial := minutos[kMinuto].sumaDeLasInversasDeLosDividendos2;

    if (SID3Inicial = 0) then
      SID3Inicial := minutos[kMinuto].sumaDeLasInversasDeLosDividendos3;

  end;

  // resultado final y cantidad de goles
  resultadoFinal := minutos[high(minutos)].marcador;
  cantidadDeGoles := minutos[high(minutos)].golesVisitante +
    minutos[high(minutos)].golesLocal;

  // poder del favorito
  kMinuto := 0;
  while ((minutos[kMinuto].dividendoGolLocal = nil) or
      (minutos[kMinuto].dividendoGolVisitante = nil)) and (kMinuto < NMinutos - 1) do
    Inc(kMinuto);
  if kMinuto < NMinutos - 1 then
    poderDelFavorito := max(minutos[kMinuto].dividendoGolLocal.dividendo,
      minutos[kMinuto].dividendoGolVisitante.dividendo) /
      min(minutos[kMinuto].dividendoGolLocal.dividendo,
      minutos[kMinuto].dividendoGolVisitante.dividendo);

end;

procedure TPartido.Free;
var
  kMinuto, NMinutos, kDividendo, NDividendos: integer;
begin
  NMinutos := Length(minutos);
  for kMinuto := 0 to NMinutos - 1 do
    minutos[kMinuto].Free;
  SetLength(minutos, 0);
  NDividendos := Length(dividendos);
  for kDividendo := 0 to NDividendos - 1 do
    dividendos[kDividendo].Free;
  SetLength(dividendos, 0);
  NMinutos := Length(minutos);
  for kMinuto := 0 to NMinutos - 1 do
    minutos[kMinuto].Free;
  SetLength(minutos, 0);
  SetLength(eventos, 0);
  inherited Free;
end;

procedure TPartido.tratarColumna(hoja: TsWorksheet; kColumna: integer);
var
  str: string;
  kDividendo, kFila: integer;
  hayDatos: boolean;
begin
  kFila := 0;
  hayDatos := True;
  str := hoja.ReadAsText(0, kColumna);
  if str = '' then
    estado := 'Finalizado'
  else
  begin
    while hayDatos do
    begin
      // leo toda la columna hasta que haya una celda en blanco
      str := hoja.ReadAsText(kFila, kColumna);
      if str = '' then
        hayDatos := False;
      if Pos('Estado', str) <> 0 then
        estado := getEstado(str);
      if Pos('Marcador:', str) <> 0 then
      begin
        resultadoParcial := getMarcador(str);
        getGoles;
      end;
      if Pos('Marcador Exacto', str) <> 0 then
      begin
        SetLength(dividendos, Length(dividendos) + 1);
        dividendos[High(dividendos)] := TDividendo.Create(str, resultadoParcial);
      end;
      if Pos('Tiempo', str) <> 0 then
        tiempo := getTiempo(str);


      Inc(kFila);
    end;
    writeln('Estado: ', estado, '; Marcador: ', golesLocal, ':', golesVisitante,
      ' Tiempo: ', tiempo);
    for kDividendo := 0 to high(dividendos) do
      writeln('Dividendo: ', dividendos[kDividendo].resultado, '; ',
        dividendos[kDividendo].dividendo: 0: 2);


    for kDividendo := 0 to high(dividendos) do
      dividendos[kDividendo].Free;
    SetLength(dividendos, 0);

    WriteHeapStatus('Memoria: ');
    if estado = 'Finalizado' then
    begin
      resultadoFinal := resultadoParcial;
      writeln('Marcador Final: ', resultadoFinal);
    end;
  end;
end;

procedure TPartido.getGoles;
begin
  golesLocal := StrToInt(LeftStr(resultadoParcial, 1));
  golesVisitante := StrToInt(RightStr(resultadoParcial, 1));
  cantidadDeGoles := golesLocal + golesVisitante;
end;

procedure TPartido.writeToArchi;
var
  xls: TLibroOpenCalc;
  kMinuto, NMinutos, kEvento, NEventos, kDividendo, NDividendos: integer;

begin

  crearSiNoExiste('C:\basura\');

  xls := TLibroOpenCalc.Create(True, 'C:\basura\' + IntToStr(id) + '.xlsx');

  xls.ActiveWorksheet.Name := 'MinutoAMinuto';

  NMinutos := Length(minutos);

  xls.Write('Minuto');
  xls.Write('Columna Anterior');
  xls.Write('Columna Siguiente');
  xls.Write('Distancia a Columna Anterior');
  xls.Write('Distancia a columna Siguiente');
  xls.Write('Marcador');

  xls.Write('Dividendo del marcador actual');
  xls.Write('Dividendo del marcador gol local');
  xls.Write('Dividendo del marcador gol visitante');


  xls.Write('Dividendo dos goles local');
  xls.Write('Dividendo dos goles visitante');
  xls.Write('Dividendo un gol cada uno');

  xls.Write('Dividendo tres goles local');
  xls.Write('Dividendo tres goles visitante');
  xls.Write('Dividendo un gol local dos visitante');
  xls.Write('Dividendo un gol visitante dos local');

  xls.Write('Suma de los inversos de los dividendos');
  xls.Write('Suma de los inversos de los dividendos 2');
  xls.Write('Suma de los inversos de los dividendos 3');

  xls.Write('Dividendos');


  xls.writeln();

  for kMinuto := 0 to NMinutos - 1 do
  begin
    xls.Write(kMinuto);
    xls.Write(minutos[kMinuto].columnaAnterior);
    xls.Write(minutos[kMinuto].columnaSiguiente);
    xls.Write(minutos[kMinuto].distanciaAColumnaAnterior);
    xls.Write(minutos[kMinuto].distanciaAColumnaSiguiente);
    xls.Write(minutos[kMinuto].marcador);

    // marcador actual
    if minutos[kMinuto].dividendoDelMarcadorActual <> nil then
      xls.Write(minutos[kMinuto].dividendoDelMarcadorActual.dividendo)
    else
      xls.Write('');
    // gol local
    if minutos[kMinuto].dividendoGolLocal <> nil then
      xls.Write(minutos[kMinuto].dividendoGolLocal.dividendo)
    else
      xls.Write('');
    // gol visitante
    if minutos[kMinuto].dividendoGolVisitante <> nil then
      xls.Write(minutos[kMinuto].dividendoGolVisitante.dividendo)
    else
      xls.Write('');

    // dos goles local
    if minutos[kMinuto].dividendoDosGolesLocal <> nil then
      xls.Write(minutos[kMinuto].dividendoDosGolesLocal.dividendo)
    else
      xls.Write('');
    // dos goles visitante
    if minutos[kMinuto].dividendoDosGolesVisitante <> nil then
      xls.Write(minutos[kMinuto].dividendoDosGolesVisitante.dividendo)
    else
      xls.Write('');
    // un gol cada uno
    if minutos[kMinuto].dividendoUnGolCadaUno <> nil then
      xls.Write(minutos[kMinuto].dividendoUnGolCadaUno.dividendo)
    else
      xls.Write('');
    // tres goles local
    if minutos[kMinuto].dividendoTresGolesLocal <> nil then
      xls.Write(minutos[kMinuto].dividendoTresGolesLocal.dividendo)
    else
      xls.Write('');
    // tres goles visitante
    if minutos[kMinuto].dividendoTresGolesVisitante <> nil then
      xls.Write(minutos[kMinuto].dividendoTresGolesVisitante.dividendo)
    else
      xls.Write('');
    // un gol local dos visitante
    if minutos[kMinuto].dividendoUnGolLocalDosVisitante <> nil then
      xls.Write(minutos[kMinuto].dividendoUnGolLocalDosVisitante.dividendo)
    else
      xls.Write('');
    // un gol visitante dos local
    if minutos[kMinuto].dividendoDosGolesLocalUnoVisitante <> nil then
      xls.Write(minutos[kMinuto].dividendoDosGolesLocalUnoVisitante.dividendo)
    else
      xls.Write('');

    // suma de los inversos de los dividendos
    if minutos[kMinuto].sumaDeLasInversasDeLosDividendos > 0 then
      xls.Write(minutos[kMinuto].sumaDeLasInversasDeLosDividendos)
    else
      xls.Write('');

    // suma de los inversos de los dividendos 2
    if minutos[kMinuto].sumaDeLasInversasDeLosDividendos2 > 0 then
      xls.Write(minutos[kMinuto].sumaDeLasInversasDeLosDividendos2)
    else
      xls.Write('');

    // suma de los inversos de los dividendos 3
    if minutos[kMinuto].sumaDeLasInversasDeLosDividendos3 > 0 then
      xls.Write(minutos[kMinuto].sumaDeLasInversasDeLosDividendos3)
    else
      xls.Write('');

    // todos los dividendos
    NDividendos := 0;
    if minutos[kMinuto].dividendos <> nil then
      NDividendos := Length(minutos[kMinuto].dividendos^);
    for kDividendo := 0 to NDividendos - 1 do
      xls.Write(minutos[kMinuto].dividendos[kDividendo].texto);

    xls.writeln();

    if (kMinuto > 0) and (minutos[kMinuto].marcador <>
      minutos[kMinuto - 1].marcador) then
    begin
      registrarGol(kMinuto);
    end;
  end;

  getDistanciaMaxima;
  xls.agregoHoja('Eventos');
  xls.go('Eventos', 1, 1);
  NEventos := Length(eventos);
  for kEvento := 0 to NEventos - 1 do
    xls.writeln(eventos[kEvento]);

  xls.Guardar;

  xls.Free;
end;

procedure TPartido.getDistanciaMaxima;
var
  kMinuto, NMinutos: integer;
begin
  NMinutos := Length(minutos);
  distanciaMaxima := 0;

  for kMinuto := 0 to NMinutos - 1 do
  begin
    if minutos[kMinuto].distanciaAColumnaAnterior >= distanciaMaxima then
      distanciaMaxima := minutos[kMinuto].distanciaAColumnaAnterior;
    if minutos[kMinuto].distanciaAColumnaSiguiente >= distanciaMaxima then
      distanciaMaxima := minutos[kMinuto].distanciaAColumnaSiguiente;
  end;

  SetLength(eventos, Length(eventos) + 1);
  eventos[High(eventos)] := 'Distancia Maxima: ' + FloatToStr(distanciaMaxima) +
    ' minutos';

end;

procedure TPartido.registrarGol(kMinuto: integer);
begin
  SetLength(eventos, Length(eventos) + 1);
  eventos[High(eventos)] := 'Gol en ' + IntToStr(kMinuto);
end;

function TPartido.esFactible: boolean;
begin
  if (distanciaMaxima < UMBRALENMINUTOS) and (SIDInicial < SIDUMBRAL) and
    (poderDelFavorito < PODERFAVORITOMAX) then
    Result := True
  else
    Result := False;
end;

end.
