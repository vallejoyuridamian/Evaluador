unit uglobs;

interface

uses
  //comctrls,

  xmatdefs, SysUtils, ucosaConNombre, uActualizadorLPD, ufechas,
  uauxiliares,
  uEstados,
  uCosa,
  Math,
  uconstantesSimSEE,
  umadresuniformes,
  Classes,
  uescenarios;

// Este multiplicador se utiliza para separar las semillas de la simulación
// el valor 10000 nos dio problemas de desborde numérico.
const
  CMultiplicadorSemillasSim = 10000;

type

  // hasta que  se implemente un calendario, los Domingos son feriados
  // los sábados son semi-feriados y el resto son hábiles
  TTipoDeDia = (DIA_HABIL, DIA_SEMI_FERIADO, DIA_FERIADO);

  TProcNotificacion = procedure;
  TProcAlerta = procedure(const s: string);

  TEstadoDeLaSala = (
    CES_SIN_PREPARAR,
    CES_OPTIMIZANDO,
    CES_OPTIMIZACION_TERMINADA,
    CES_OPTIMIZACION_ABORTADA,
    CES_SIMULANDO,
    CES_SIMULACION_TERMINADA,
    CES_SIMULACION_ABORTADA);


  { TGlobs }

  TGlobs = class(TCosaConNombre)
  private

    procAlerta: TProcAlerta;

    fechaIni_old, fechaFin_old: TFecha;

    demandaPrincipal: TCosa; // actor principal de demanda ESTE POSTIZA
  public
    procAlertaHabilitado: boolean;

    SorteadorUniforme: TMadreUniformeEtiquetada;

    DurPos: TDAOfNReal;
    {Si está a TRUE se agregan en la salida la generación de los LowCostMustRun
     y de los NO_LowCostMustRun y la generación de toneladas de CO2
     de cada Grupo. }
    Calcular_EmisionesCO2: boolean;
    {Coeficiente de Aversión al Riesgo. [ 0 , 1 ] Este coeficiente modula entre}
    CAR: NReal;
    { Por defecto es true. Si es false usa VaR en lugar de CVaR. }
    CAR_CVaR: boolean;
    {Especifica si la sala debe ser tratada como determinística. }
    Deterministico: boolean;
    NPostes: integer;
    {Duración del paso en minutos.
     TRUE Minutal en ese caso se usa DurPaso_minutos para
     definir un único poste con duración DurPaso_minutos/60.0
     al momento de preparar la Sala.}
    DurPaso_minutos: NReal;
    FactorEmisiones_MargenOperativoTipo: integer;
    {0: Promedio; 1: Simple; 2: Simple Ajustado}
    FactorEmisiones_ProyectoEolicoSolar: boolean;
    fechaIniOpt: TFecha;
    fechaFinOpt: TFecha; // Horizonte de Optimización
    fechaIniSim: TFecha;
    fechaFinSim: TFecha; // Horizonte de Simulación
    fechaGuardaSim: TFecha; // Si esta fecha es > fechaIniSim todo lo que pase
    // antes de esta fecha NO se escribe en los archivos de resultados.
    // en particular NO se tienen en cuenta en los calculos para SimCosto.
    iteracion_flucar_Archivo_Flucar: string;
    iteracion_flucar_modificar_rendimiento: boolean;
    iteracion_flucar_modificar_capacidad: boolean;
    iteracion_flucar_modificar_peaje: boolean;
    NCronicasSim: integer; // cantidad de historias a sortear en el simulador
    NCronicasOpt: integer;
    // el valor esperado del costo futuro de operación.
    NDiscHistoCF: integer;
    NMAX_ITERACIONESDELPASO_OPT: integer;
    NMAX_ITERACIONESDELPASO_SIM: integer;

    // Por defecto a False, si se pone a true, no se consideran las disponibilidades
    ObligarDisponibilidad_1_Sim: boolean;
    ObligarDisponibilidad_1_Opt: boolean;

    // Por defecto a FALSE. Si se marca, se obliga a tratar la disponibilidad de
    // todas las unidades como inciertas al inicio de cada crónica.
    ObligarInicioCronicaIncierto_1_Sim: boolean;

    PostesMonotonos: boolean; // TRUE por defecto.
    // cantidad de puntos usados para el mantenimienot del histograma de Costo Futuro.
    probLimiteRiesgo: NReal; // Probabilidad de Excedencia para cálculo de riesgo
    //Para reducir el peso de los archivos de resultados de simulación
    //solo se imprimiran las variables usadas en la plantilla de simres3
    publicarSoloVariablesUsadasEnSimRes3: boolean;
    restarUtilidadesDelCostoFuturo: boolean; // determina
    // Semillas iniciales para Opt y Sim
    semilla_inicial_sim, semilla_inicial_opt: integer;
    // Por defecto a TRUE, si se pone a FALSE no usa sorteos en la optimización y pone
    // los valores esperados de las cosas
    SortearOpt: boolean;
    TasaDeActualizacion: NReal; // tasa de descuento anual
    usar_CAR: boolean; // si está a false optimiza con el criterio clásico de minmizar
    flg_ReservaRotante: boolean;
    SalaMinutal: boolean; // FALSE Horario con durpos.

    invDurPos: TDAOfNReal; //Duración en horas de los postes y sus inversos

    husoHorario_UTC: NReal; // -3 para Uruguay.  Universal Time Coordinated

    {$IFDEF CALC_MMEE}
    mmee_TopeDelSpot: NReal;
    mmee_PrecioSpot: TDAOfNReal;
    mmee_SeguimientoDeLaDemanda_USD: TDAOfNReal;
    {$ENDIF}

    // para cada hora del paso tiene el índice del poste
    // esta clasificación la hace la Demanda NETA.
    kPosteHorasDelPaso: TDAOfNInt;

    {$IFDEF CALC_DEMANDA_NETA}
    Suma_PHorarias: TDAOfNReal;

    // Tiene la aproximación entera de las duraciones de los postes.
    NHorasDelPoste: TDAOfNInt;

    // tiene en forma ordenada del poste 1 al último el índice de las
    // horas que resultó del postizado del paso. Este es el índice inverso
    // del mantenido en kPostesHorasDelPaso.
    idxHorasPostizadas: TDAOfNInt;

    // almacena el inicio de cada poste en idxHorasPostizadas
    kBasePoste_idxHorasPostizadas: TDAOfNInt;
    {$ENDIF}

    fActPaso: NReal;

    idHilo: Integer; // Identificador del hilo de ejecución.


    invNCronicasSim, invNCronicasOpt: NReal; //1 / NCronicas...

    ActualizadorLPD: TActualizadorFichasLPD;
    abortarSim: boolean;

    // esta variable puesta a TRUE obliga la disponibilidad a 1 en SorteosDelPaso
    // La simulación la debe carcar con ObligarDisponibilidad_1_Sim y la optimización
    // la debe cargar ObligarDispnibilidad_1_Opt.
    ObligarDisponibilidad_1_: boolean;

    // la minimización en valor esperad CAR= 0 y la minimización del VaR( probLimiteRiesgo ) si CAR = 1
    // en los valores intermedios se utiliza la combinación lineal convexa de ambos criterios.

    NPasos: integer;

    // variables del simulador
    FechaInicioDelpaso: TFecha;
    FechaFinDelPaso: TFecha;
    kPaso_Sim,
    kPaso_Opt,
    offsetPasos_Opt: integer;

    // variable auxiliar que utilizan las fuentes submuestreadas para
    // saber el subpaso en que están cuando realizan los sorteosDelPaso
    kSubPaso_: integer;

    //Utilizada por los hilos para saber que vuelta de sorteos del paso
    //estoy realizando sobre el paso en preparar paso ps
    iTareaEjecutando: integer;

    AnioInicioDelPaso: word;
    SemanaInicioDelPaso: word;
    //[1..52] La semana del año por la que va la simulacion
    HoraDeInicioDelPaso: word;    // [0..23]

    MesInicioDelPaso: word;    //el mes del año por el que va la simulación.
    DiaDelMesInicioDelPaso: word;
    DiaDeLaSemanaInicioDelPaso: word;
    DiaDelAnioInicioDelPaso: word;
    HoraDelAnioInicioDelPaso: word;
    FechaInicioDelAnio: TDateTime;
    TipoDeDiaInicioDelPaso: TTipoDeDia;

    dt_DelPaso: NReal; // duración del paso de tiempo en días punto flontante

    HorasDelPaso: NReal;

    SegundosDelPaso: integer;
    invHorasDelPaso, invSegundosDelPaso: NReal;

    ultimaSemillaFijada: integer;
    // 1 / HorasDelPaso, 1 / SegundosDelPaso
    kCronica: integer;

    cntIteracionesDelPaso: integer;


    // Resultado de la optimización del paso.
    CostoDelPaso: NReal;

    // Soporte de estados y costos futuros
    CF: TAdminEstados;
    flg_CF_parasito: boolean; // Normalmente a FALSE, a TRUE implica no se libera CF en el FREE.



    liberarAuxs: boolean;
    Auxs_r0, Auxs_r1: TDAOfDAOfNReal;
    Auxs_i0, Auxs_i1: TDAOfDAOfNInt;

    {$IFDEF PDE_RIESGO}
    HistoCF0: TDAofDAofNReal;
    // Histograma del costo Futuro Al Inicio de la etapa durante OPT
    // La dimensión es NEstrellas x NSorteosOpt x NPuntosHistoCF
    // HistoCF0[ kEstrella ][ kCronOpt * NDiscHistoCF + j ] con j: 0.. NDiscHistoCF - 1

    HistoCF1_: TDAofDAofNReal;
    // Histograma del Costo Futuro al Fin de la etapa durante OPT.
    // La dimsensión es NEstrellas x NPuntosHistoCF
    HistoCF1_s: TDAofDAofNReal; // este es auxiliar para cálculo para que no se
    // mezclen en el caso de los multi-hilo
    {$ENDIF}

    // se para que los actores que actualizan el estado se fijen
    // si se debe usar la reducción de estados auxiliar (si es que tiene)
    CFauxActivo: boolean;

    {$IFDEF GLOBS_LOG}
    flog: textfile;
    flg_flog_open: boolean;
    {$ENDIF}


    procNot_InicioSimulacion: TProcNotificacion;
    procNot_InicioCronica: TProcNotificacion;
    procNot_InicioPaso: TProcNotificacion;
    procNot_FinPaso: TProcNotificacion;
    procNot_FinCronica: TProcNotificacion;
    procNot_FinSimulacion: TProcNotificacion;

    procNot_opt_InicioOptimizacion: TProcNotificacion;
    procNot_opt_InicioCronicaSorteos: TProcNotificacion;
    procNot_opt_PrepararPaso_ps: TProcNotificacion;
    procNot_opt_InicioCalculosDeEtapa: TProcNotificacion;
    procNot_opt_FinCalculosDeEtapa: TProcNotificacion;
    procNot_opt_FinCronicaSorteos: TProcNotificacion;
    procNot_opt_FinOptimizacion: TProcNotificacion;

    EstadoDeLaSala: TEstadoDeLaSala;

    MadresUniformes: TMadresUniformes;

    EscenarioActivo: TEscenario_rec; // apunta al de la sala si esta activó un escenario


   // Valores sorteados para resumen de MaximaVarianza
   jRnd_Paso_globs: integer;
   jRnd_Poste_globs: TDAofNInt;


    //{$IFDEF DBG}
    //      fdbgAbierto: Boolean;
    //      fdbg: TextFile; //Es un archivo que se mantiene abierto durante toda la
    //                      //simulación para escribirle valores si se desea
    //{$ENDIF}
  constructor Create(nombre: string; idHilo: integer; fechaIniSim, fechaFinSim,
      fechaGuardaSim: TFecha; fechaIniOpt, fechaFinOpt: TFecha;
  const DurPos: TDAOfNReal); reintroduce;
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    function calcNPasosSim: integer;
    function calcNPasosOpt: integer;
    function fechaToPasoSim(fecha: TFecha): integer;
    function pasoToFechaSim(paso: integer): TFecha;
    function fechaToPasoOpt(fecha: TFecha): integer;
    function pasoToFechaOpt(paso: integer): TFecha;

    // fija el kPaso, el kSem y el kMes
    procedure Fijar_kPaso(nuevo_kPaso: integer);
    procedure Fijar_FechaInicioDelPaso(fecha: TFecha);
    procedure fijarSemillaAleatoria_(semilla: integer);

    procedure CalcularConstantesBasicasDelPaso;
    procedure Free; override;

    procedure CambioFichaPD; override;
    //Abstracto lanza Excepcion

    // pone todos los procedimientos de notificación a NIL.
    procedure ClearProcNots;

    // si xproc es <> nil lo ejecuta
    procedure procNot(xproc: TProcNotificacion);
    procedure deshabilitarAlertas;
    procedure habilitarAlertas;
    procedure setProcAlerta(xprocAlerta: TProcAlerta);
    procedure Alerta(const s: string);

    procedure PubliVars; override;
    procedure SorteosDelPaso;

    procedure ClearAuxs1(kIniEstrella, kFinEstrella: integer); // limpia los auxs1
    procedure SwapAuxs;   // conmuta los frames auxilieares 0<->1
    procedure MultAuxs1(mmult: NReal);
    // Los enteros los multiplica y redondea al entero más proximo

   {$IFDEF CALC_DEMANDA_NETA}
    procedure InicializarNeteadorDeDemanda;
    procedure borrarSumaPHorarias;
    procedure sumarPHoraria(const PHoraria: TDAOfNReal);
    procedure restarPHoraria(const PHoraria: TDAOfNReal);
    procedure postizarPHoraria;
    {$ELSE}
    procedure SetDemandaPrincipal(aDemanda: TCosa);
    function GetDemandaPrincipal: TCosa;
    {$ENDIF}

   {$IFDEF BOSTA}
    procedure AfterInstantiation; override;
   {$ENDIF}

    function Validate: boolean; override;


    {$IFDEF GLOBS_LOG}
    procedure log_OpenCreate;
    procedure log_Close;
    procedure log_Writeln_( s: string  );
    {$ENDIF}

    function InfoAd_: string; override;
  end;

function estadoSalaToString(estado: TEstadoDeLaSala): string;

procedure AlInicio;
procedure AlFinal;

implementation

function estadoSalaToString(estado: TEstadoDeLaSala): string;
begin
  case estado of
    CES_SIN_PREPARAR: Result := 'CES_SIN_PREPARAR';
    CES_OPTIMIZANDO: Result := 'CES_OPTIMIZANDO';
    CES_OPTIMIZACION_TERMINADA: Result := 'CES_OPTIMIZACION_TERMINADA';
    CES_OPTIMIZACION_ABORTADA: Result := 'CES_OPTIMIZACION_ABORTADA';
    CES_SIMULANDO: Result := 'CES_SIMULANDO';
    CES_SIMULACION_TERMINADA: Result := 'CES_SIMULACION_TERMINADA';
    CES_SIMULACION_ABORTADA: Result := 'CES_SIMULACION_ABORTADA';
    else
      raise Exception.Create('uglobs.estadoSalaToString, estado desconocido');
  end;
end;

procedure TGlobs.deshabilitarAlertas;
begin
  procAlertaHabilitado := False;
end;

procedure TGlobs.habilitarAlertas;
begin
  procAlertaHabilitado := True;
end;

procedure TGlobs.setProcAlerta(xprocAlerta: TProcAlerta);
begin
  procAlerta := xprocAlerta;
  procAlertaHabilitado := Assigned(xprocAlerta);
end;

procedure TGlobs.Alerta(const s: string);
begin
  if procAlertaHabilitado then
    procAlerta(s);
end;

{$IFDEF CALC_DEMANDA_NETA}
procedure TGlobs.InicializarNeteadorDeDemanda;
var
  iposte: integer;
  nHorasDelPoste_: integer;
  kBasePoste: integer;

begin
  setlength(Suma_PHorarias, max(round(HorasDelPaso), 1));
  setlength(idxHorasPostizadas, max(round(HorasDelPaso), 1));
  setlength(kBasePoste_idxHorasPostizadas, NPostes + 1);
  setlength(NHorasDelPoste, NPostes);

  kBasePoste := 0;
  for iposte := 0 to NPostes - 1 do
  begin
    nHorasDelPoste_ := round(Durpos[iposte]);
    nHorasDelPoste[iposte] := nHorasDelPoste_;
    kBasePoste := kBasePoste + nHorasDelPoste_;
    kBasePoste_idxHorasPostizadas[iposte + 1] := kBasePoste;
  end;
end;

procedure TGlobs.borrarSumaPHorarias;
begin
  vclear(Suma_PHorarias);
end;

procedure TGlobs.restarPHoraria(const PHoraria: TDAOfNReal);
var
  k: integer;
begin
  for k := 0 to high(PHoraria) do
    Suma_PHorarias[k] := Suma_PHorarias[k] - PHoraria[k];
end;


procedure TGlobs.sumarPHoraria(const PHoraria: TDAOfNReal);
var
  k: integer;
begin
  for k := 0 to high(PHoraria) do
    Suma_PHorarias[k] := Suma_PHorarias[k] + PHoraria[k];
end;

procedure TGlobs.postizarPHoraria;
var
  k: integer;
  hora, jhora: integer;
  iposte: integer;
begin
  // inicializamos el índice
  for k := 0 to high(idxHorasPostizadas) do
    idxHorasPostizadas[k] := k;

  if PostesMonotonos then
    QuickSort_Decreciente(Suma_PHorarias, idxHorasPostizadas);

  hora := 0;
  kBasePoste_idxHorasPostizadas[0] := 0;
  for iposte := 0 to NPostes - 1 do
  begin
    for jhora := 0 to nHorasDelPoste[iposte] - 1 do
    begin
      kPosteHorasDelPaso[idxHorasPostizadas[hora]] := iposte;
      Inc(hora);
    end;
  end;
end;

{$ELSE}


procedure TGlobs.SetDemandaPrincipal(aDemanda: TCosa);
begin
  DemandaPrincipal := aDemanda;
end;

function TGlobs.GetDemandaPrincipal: TCosa;
begin
  Result := DemandaPrincipal;
end;

{$ENDIF}


constructor TGlobs.Create(
  nombre: string; idHilo: integer;
  fechaIniSim, fechaFinSim, fechaGuardaSim: TFecha;
  fechaIniOpt, fechaFinOpt: TFecha;
  const DurPos: TDAOfNReal);
var
  i: integer;
  acumr: NReal;
begin
  inherited Create(0, nombre);
  flg_CF_parasito:= false;
  husoHorario_UTC:= -3;

  self.idHilo:= idHilo;
  {$IFDEF GLOBS_LOG}
  flg_flog_open:= false;
  {$ENDIF}

  EscenarioActivo := nil;

  EstadoDeLaSala := CES_SIN_PREPARAR;
  ActualizadorLPD := TActualizadorFichasLPD.Create( idHilo );
  abortarSim := False;
  self.fechaIniSim := fechaIniSim;
  self.fechaFinSim := fechaFinSim;
  self.fechaGuardaSim := fechaGuardaSim;
  self.fechaIniOpt := fechaIniOpt;
  self.fechaFinOpt := fechaFinOpt;
  Self.NPostes := length(DurPos);
  self.DurPos := copy(DurPos, 0, NPostes);
  SetLength(invDurPos, NPostes);
  setlength( jRnd_Poste_globs, NPostes );

  MadresUniformes := TMadresUniformes.Create( CMultiplicadorSemillasSim );
  SorteadorUniforme := madresUniformes.Get_NuevaMadreUniforme(get_hash_nombre);

    {$IFDEF CALC_MMEE}
  mmee_TopeDelSpot := 250.0; // ojo esto es para sobreescribir al leer
  setlength(mmee_PrecioSpot, NPostes);
  setlength(mmee_SeguimientoDeLaDemanda_USD, NPostes);
    {$ENDIF}

  for i := 0 to high(DurPos) do
    invDurPos[i] := 1 / durPos[i];

  acumr := vsum(DurPos);
  dt_DelPaso := acumr / 24.0;
  HorasDelPaso := acumr;
  invHorasDelPaso := 1 / HorasDelPaso;

  offsetPasos_Opt:= trunc( (fechaIniSim.dt - FechaIniOpt.dt )/ (HorasDelPaso / 24.0) + 0.5 );
  if offsetPasos_Opt < 0 then
    raise Exception.Create( 'Error, FechaIniSim < FechaIniOpt' );

  setLength(kPosteHorasDelPaso, ceil(HorasDelPaso));
  demandaPrincipal := nil;

  SegundosDelPaso := trunc(HorasDelPaso * 3600 + 0.1);
  invSegundosDelPaso := 1 / SegundosDelPaso;
  FechaInicioDelpaso := TFecha.Create_Clone(fechaIniOpt);
  FechaFinDelPaso := TFecha.Create_OffsetDT(FechaInicioDelpaso, dt_DelPaso);

  PostesMonotonos := True;
  SalaMinutal := False;
  DurPaso_minutos := 10.0;

  self.SortearOpt := True;
  ObligarDisponibilidad_1_Sim := False;
  ObligarDisponibilidad_1_Opt := False;
  ObligarInicioCronicaIncierto_1_Sim := False;
  Deterministico := False;
  self.semilla_inicial_sim := 31;
  self.semilla_inicial_opt := 31;

  CF := nil;
  setlength(Auxs_r0, 0);
  setlength(Auxs_i0, 0);
  setlength(Auxs_r1, 0);
  setlength(Auxs_i1, 0);

  self.usar_CAR := False;
  self.restarUtilidadesDelCostoFuturo := True;
  NDiscHistoCF := 0;
  probLimiteRiesgo := 0.0;
  CAR := 0.0;
  CAR_CVaR := True;

  {$IFDEF PDE_RIESGO}
  setlength(HistoCF0, 0);
  setlength(HistoCF1_, 0);
  setlength(HistoCF1_s, 0);
  {$ENDIF}

  Fijar_kPaso(1); // solo para que inicialmente esté algo definido
  //{$IFDEF DBG}
  //  AssignFile(fdbg, uconstantes.getDir_Dbg + 'debug.txt');
  //  rewrite(fdbg);
  //  fdbgAbierto:= true;
  //{$ENDIF}
  procAlertaHabilitado := False;


  NMAX_ITERACIONESDELPASO_OPT := 0;
  NMAX_ITERACIONESDELPASO_SIM := 4;

  {$IFDEF CALC_DEMANDA_NETA}
  setlength(Suma_PHorarias, 0);
  setlength(idxHorasPostizadas, 0);
  setlength(kBasePoste_idxHorasPostizadas, 0);
  setlength(NHorasDelPoste, 0);
  {$ENDIF}

  publicarSoloVariablesUsadasEnSimRes3 := True;
  flg_ReservaRotante := False;



end;


procedure TGlobs.Fijar_kPaso(nuevo_kPaso: integer);
begin
  if EstadoDeLaSala = CES_OPTIMIZANDO then
  begin
    FechaInicioDelpaso.PonerIgualAMasOffsetDT(
      fechaIniOpt, dt_DelPaso * (nuevo_kPaso - 1));
    kPaso_Opt:= nuevo_kPaso;
    kPaso_Sim:= kPaso_Opt;
  end
  else
  begin
    FechaInicioDelpaso.PonerIgualAMasOffsetDT(
      fechaIniSim, dt_DelPaso * (nuevo_kPaso - 1));
    kPaso_Sim:= nuevo_kPaso;
    kPaso_Opt:= kPaso_Sim + OffsetPasos_Opt;
  end;
  Fijar_FechaInicioDelPaso(FechaInicioDelpaso);
end;

procedure TGlobs.Fijar_FechaInicioDelPaso(fecha: TFecha);
var
  anio: word;
begin
  FechaInicioDelpaso.PonerIgualA(fecha);

  //  FechaFinDelPaso.PonerIgualAMasOffsetDT(FechaInicioDelpaso, dt_DelPaso - 1);   //rch@201501222003 ... ??? OJO me parece que el -1 es un bolazo!!!
  FechaFinDelPaso.PonerIgualAMasOffsetDT(FechaInicioDelpaso, dt_DelPaso);
  DecodeDate(FechaInicioDelPaso.dt, anio, mesInicioDelPaso, diaDelMesInicioDelPaso);
  if anio <> anioInicioDelPaso then
  begin
    fechaInicioDelAnio := encodeDate(anio, 1, 1);
    anioInicioDelPaso := anio;
  end;
  //  SemanaInicioDelPaso:= trunc(( FechaInicioDelPaso.dt-fechaInicioDelAnio )/7)+1;
  SemanaInicioDelPaso := trunc((FechaInicioDelPaso.dt - fechaInicioDelAnio) /
    7.038461538) + 1;
  DiaDelAnioInicioDelPaso := trunc(FechaInicioDelPaso.dt - fechaInicioDelAnio) + 1;
  DiaDeLaSemanaInicioDelPaso := DayOfWeek(FechaInicioDelpaso.dt);

  if DiaDeLaSemanaInicioDelPaso = 1 then // domingo
    TipoDeDiaInicioDelPaso := DIA_FERIADO
  else if DiaDeLaSemanaInicioDelPaso = 7 then // sábado
    TipoDeDiaInicioDelPaso := DIA_SEMI_FERIADO
  else
    TipoDeDiaInicioDelPaso := DIA_HABIL;

  if SemanaInicioDelPaso > 52 then
    SemanaInicioDelPaso := 52;

  HoraDeInicioDelPaso := FechaInicioDelPaso.hora;

  HoraDelAnioInicioDelPaso := trunc((FechaInicioDelPaso.dt - FechaInicioDelAnio) * 24);
end;

procedure TGlobs.fijarSemillaAleatoria_(semilla: integer);
begin
  self.ultimaSemillaFijada := semilla;
  MadresUniformes.Reiniciar(semilla);
end;


procedure TGlobs.CalcularConstantesBasicasDelPaso;
var
  acumr: NReal;
begin
  if SalaMinutal then
  begin
    NPostes := 1;
    setlength(self.DurPos, 1);
    DurPos[0] := DurPaso_minutos / 60.0;
  end;
  acumr := vsum(self.DurPos);
  dt_DelPaso := acumr / 24.0;
  HorasDelPaso := acumr;
end;

procedure TGlobs.SorteosDelPaso;
var
  kPoste: integer;
  k1, k2: integer;
begin
  {$IFDEF CALC_DEMANDA_NETA}
    jRnd_Paso_globs:= sorteadorUniforme.randomIntRange(0, round(HorasDelPaso) - 1);
    k1:= 0;
    for kPoste:= 0 to high( jRnd_Poste_globs ) do
    begin
      k2:= k1 + NHorasDelPoste[kPoste] - 1;
      jRnd_Poste_globs[kPoste]:= sorteadorUniforme.randomIntRange( k1, k2 );
      k1:= k2;
    end;
  {$ENDIF}
end;



function TGlobs.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  result.addCampoDef('NPostes', self.NPostes);
  result.addCampoDef('fechaIni', self.fechaIni_old, 0, 25);
  result.addCampoDef('fechaFin', self.fechaFin_old, 0, 25);
  result.addCampoDef('fechaIniSim', self.fechaIniSim, 25);
  result.addCampoDef('fechaFinSim', self.fechaFinSim, 25);
  result.addCampoDef('fechaGuardaSim', self.fechaGuardaSim, 102);
  result.addCampoDef('fechaIniOpt', self.fechaIniOpt);
  result.addCampoDef('fechaFinOpt', self.fechaFinOpt);
  result.addCampoDef('durpos', self.durpos );
  result.addCampoDef('SalaMinutal', self.SalaMinutal, 104);
  result.addCampoDef('DurPaso_minutos', self.DurPaso_minutos, 104 );
  result.addCampoDef('tasaDeActualizacion', self.TasaDeActualizacion);
  result.addCampoDef('NCronicasSim', self.NCronicasSim);
  result.addCampoDef('NCronicasOpt', self.NCronicasOpt);
  result.addCampoDef('semilla_inicial_sim', self.semilla_inicial_sim, 99, 0, '31');
  result.addCampoDef('semilla_inicial_opt', self.semilla_inicial_opt, 99, 0, '31');

  // Observar el orden. esto es un RENAME de un campo
  result.addCampoDef('ObligarDisponibilidad_1_Sim', self.ObligarDisponibilidad_1_Sim, 87 );
  result.addCampoDef('ObligarDisponibilidad_1', self.ObligarDisponibilidad_1_Sim, 0, 87 );

  result.addCampoDef('ObligarDisponibilidad_1_Opt', self.ObligarDisponibilidad_1_Opt);
  result.addCampoDef('ObligarInicioCronicaIncierto_1_Sim', self.ObligarInicioCronicaIncierto_1_Sim, 101);
  result.addCampoDef('Deterministico', self.Deterministico, 88 );
  result.addCampoDef('SortearOpt', self.SortearOpt);
  result.addCampoDef('PostesMonotonos', self.PostesMonotonos);
  result.addCampoDef('NMAX_ITERACIONESDELPASO_OPT', self.NMAX_ITERACIONESDELPASO_OPT);
  result.addCampoDef('NMAX_ITERACIONESDELPASO_SIM', self.NMAX_ITERACIONESDELPASO_SIM);
  result.addCampoDef('usar_CAR', self.usar_CAR, 99, 0, 'F' );
  result.addCampoDef('NDiscHistoCF', self.NDiscHistoCF, 99, 0 );
  result.addCampoDef('probLimiteRiesgo', self.probLimiteRiesgo, 99, 0 );
  result.addCampoDef('CAR', self.CAR, 99, 0 );
  result.addCampoDef('CAR_CVaR', self.CAR_CVaR, 97 );
  result.addCampoDef('Calcular_EmisionesCO2', self.Calcular_EmisionesCO2, 63);
  result.addCampoDef('FactorEmisiones_MargenOperativoTipo', self.FactorEmisiones_MargenOperativoTipo, 68);
  result.addCampoDef('FactorEmisiones_ProyectoEolicoSolar', self.FactorEmisiones_ProyectoEolicoSolar, 68);
  result.addCampoDef('iteracion_flucar_Archivo_Flucar', self.iteracion_flucar_Archivo_Flucar, 74);
  result.addCampoDef('iteracion_flucar_modificar_rendimiento', self.iteracion_flucar_modificar_rendimiento, 74);
  result.addCampoDef('iteracion_flucar_modificar_capacidad', self.iteracion_flucar_modificar_capacidad, 74);
  result.addCampoDef('iteracion_flucar_modificar_peaje', self.iteracion_flucar_modificar_peaje, 74);
  result.addCampoDef('RestarUtilidadesDelCostoFuturo', self.restarUtilidadesDelCostoFuturo, 64);
  result.addCampoDef('publicarSoloVariablesUsadasEnSimRes3', self.publicarSoloVariablesUsadasEnSimRes3, 108);
  result.addCampoDef('flg_ReservaRotante', self.flg_ReservaRotante, 130 );
  result.addCampoDef('husoHorario_UTC', husoHorario_UTC, 148, 0, '-3' );
end;

procedure TGlobs.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo );
  idHilo:= 0;
  flg_CF_parasito:= false;

  {$IFDEF GLOBS_LOG}
  flg_flog_open:= false;
  {$ENDIF}

  {$IFDEF CALC_DEMANDA_NETA}
  setlength(Suma_PHorarias, 0);
  setlength(idxHorasPostizadas, 0);
  setlength(kBasePoste_idxHorasPostizadas, 0);
  setlength(NHorasDelPoste, 0);
  {$ENDIF}

  EscenarioActivo := nil;

  Calcular_EmisionesCO2 := False;
  self.restarUtilidadesDelCostoFuturo := False;

  //iteracion_flucar_Archivo_Flucar:= '';
  self.iteracion_flucar_modificar_rendimiento := True;
  self.iteracion_flucar_modificar_capacidad := True;
  self.iteracion_flucar_modificar_peaje := False;

  self.FactorEmisiones_MargenOperativoTipo := 0;
  self.FactorEmisiones_ProyectoEolicoSolar := True;
  self.CAR_CVaR := True;

  self.ObligarInicioCronicaIncierto_1_Sim := False;

  fechaGuardaSim := nil;

  SalaMinutal := False;
  DurPaso_minutos := 10.0;
  fechaIni_old := nil;
  fechaFin_old := nil;
  fechaIniSim := nil;
  fechaFinSim := nil;
  fechaIniOpt := nil;
  fechaFinOpt := nil;

end;

procedure TGlobs.AfterRead(version, id_hilo: integer);
var
  i: integer;
begin
  inherited AfterRead(version, id_hilo );

   if (Version < 102) then
      fechaGuardaSim := TFecha.Create_Dt(0);

  if version < 25 then
  begin
     if (fechaIniSim = nil) or (fechaIniSim.dt = 0) then
      fechaIniSim := fechaIni_old;
    if (fechaFinSim = nil) or (fechaFinSim.dt = 0) then
      fechaFinSim := fechaFin_old;

    if (fechaIniOpt = nil) or (fechaIniOpt.dt = 0) then
      fechaIniOpt := fechaIni_old;
    if (fechaFinOpt = nil) or (fechaFinOpt.dt = 0) then
      fechaFinOpt := fechaFin_old;

    NMAX_ITERACIONESDELPASO_OPT := 0;
    NMAX_ITERACIONESDELPASO_SIM := 4;

    self.usar_CAR := False;
    self.NDiscHistoCF := 0;
    self.probLimiteRiesgo := 0.0;
    self.CAR := 0.0;
    procAlertaHabilitado := False;

  end
  else
  begin
    {$IFDEF PDE_RIESGO}
    setlength(HistoCF0, 0);
    setlength(HistoCF1_, 0);
    setlength(HistoCF1_s, 0);
    {$ENDIF}


    if (fechaIniSim = nil) or (fechaIniSim.dt = 0) then
      fechaIniSim := fechaIni_old;
    if (fechaFinSim = nil) or (fechaFinSim.dt = 0) then
      fechaFinSim := fechaFin_old;

    if (fechaIniOpt = nil) or (fechaIniOpt.dt = 0) then
      fechaIniOpt := fechaIni_old;
    if (fechaFinOpt = nil) or (fechaFinOpt.dt = 0) then
      fechaFinOpt := fechaFin_old;

    //{$IFDEF DBG}
    //  AssignFile(fdbg, uconstantes.getDir_Dbg + 'debug.txt');
    //  rewrite(fdbg);
    //{$ENDIF}
    procAlertaHabilitado := False;
  end;
  calcularConstantesBasicasDelPaso;


  setLength(kPosteHorasDelPaso, ceil(HorasDelPaso));
  demandaPrincipal := nil;

  {$IFDEF CALC_MMEE}
  mmee_TopeDelSpot := 250.0; // ojo esto es para sobreescribir al leer
  setlength(mmee_PrecioSpot, NPostes);
  setlength(mmee_SeguimientoDeLaDemanda_USD, NPostes);
  {$ENDIF}


  SetLength(invDurPos, length(DurPos));
  for i := 0 to high(DurPos) do
    invDurPos[i] := 1 / durPos[i];

  invHorasDelPaso := 1 / HorasDelPaso;
  SegundosDelPaso := trunc(HorasDelPaso * 3600 + 0.1);
  invSegundosDelPaso := 1 / SegundosDelPaso;
  EstadoDeLaSala := CES_SIN_PREPARAR;

  offsetPasos_Opt:= trunc( (fechaIniSim.dt - FechaIniOpt.dt )/ (HorasDelPaso / 24.0) + 0.5 );
  if offsetPasos_Opt < 0 then
    raise Exception.Create( 'Error, FechaIniSim < FechaIniOpt' );

  self.idHilo:= id_hilo;
  ActualizadorLPD := TActualizadorFichasLPD.Create( id_hilo );
  FechaInicioDelpaso := TFecha.Create_Clone(fechaIniOpt);
  FechaFinDelPaso := TFecha.Create_OffsetHoras(FechaInicioDelpaso, HorasDelPaso);
  CF := nil;
  clearProcNots;
  MadresUniformes := TMadresUniformes.Create( CMultiplicadorSemillasSim );
  setlength( jRnd_Poste_globs, NPostes );
  SorteadorUniforme := madresUniformes.Get_NuevaMadreUniforme(get_hash_nombre);
  Fijar_kPaso(1); // solo para que inicialmente esté algo definido
end;



procedure TGlobs.ClearProcNots;
begin
  procNot_InicioSimulacion := nil;
  procNot_InicioCronica := nil;
  procNot_InicioPaso := nil;
  procNot_FinPaso := nil;
  procNot_FinCronica := nil;
  procNot_FinSimulacion := nil;

  procNot_opt_InicioOptimizacion := nil;
  procNot_opt_InicioCalculosDeEtapa := nil;
  procNot_opt_InicioCronicaSorteos := nil;
  procNot_opt_PrepararPaso_ps := nil;
  procNot_opt_FinCronicaSorteos := nil;
  procNot_opt_FinCalculosDeEtapa := nil;
  procNot_opt_FinOptimizacion := nil;

  procAlerta := nil;
  procAlertaHabilitado := False;
end;

procedure TGlobs.procNot(xproc: TProcNotificacion);
begin
  if assigned(xproc) then
    xproc;
end;

function TGlobs.calcNPasosSim: integer;
var
  rn: NReal;
begin
  rn := (fechaFinSim.dt - fechaIniSim.dt) / dt_DelPaso;
  Result := trunc(rn);
end;

function TGlobs.calcNPasosOpt: integer;
begin
  Result := trunc((fechaFinOpt.dt - fechaIniOpt.dt) / dt_DelPaso);

end;

//Retorna el paso de la simulación comenzando de 1
function TGlobs.fechaToPasoSim(fecha: TFecha): integer;
begin
  Result := trunc((fecha.dt - fechaIniSim.dt) / dt_DelPaso) + 1;
end;

function TGlobs.pasoToFechaSim(paso: integer): TFecha;
begin
  Result := TFecha.Create_Dt(fechaIniSim.dt + (paso - 1) * dt_DelPaso);
end;

function TGlobs.fechaToPasoOpt(fecha: TFecha): integer;
begin
  Result := trunc((fecha.dt - fechaIniOpt.dt) / dt_DelPaso) + 1;
end;

function TGlobs.pasoToFechaOpt(paso: integer): TFecha;
begin
  Result := TFecha.Create_Dt(fechaIniOpt.dt + (paso - 1) * dt_DelPaso);
end;


procedure TGlobs.ClearAuxs1(kIniEstrella, kFinEstrella: integer); // limpia los auxs1
var
  k: integer;
begin
  for k := 0 to high(Auxs_r1) do
    vclear(Auxs_r1[k], kIniEstrella, kFinEstrella);
  for k := 0 to high(Auxs_i1) do
    vclear(Auxs_i1[k], kIniEstrella, kFinEstrella);
end;

procedure TGlobs.MultAuxs1(mmult: NReal);
var
  k: integer;
begin
  for k := 0 to high(Auxs_r1) do
    vmultr(Auxs_r1[k], mmult);
  for k := 0 to high(Auxs_i1) do
    vmultr(Auxs_i1[k], mmult);
end;

procedure TGlobs.SwapAuxs; // conmuta los frames auxilieares 0<->1
var
  tvr: TDAOfDAOfNReal;
  tvi: TDAOfDAOFNint;
begin
  tvr := Auxs_r0;
  Auxs_r0 := Auxs_r1;
  Auxs_r1 := tvr;

  tvi := Auxs_i0;
  Auxs_i0 := Auxs_i1;
  Auxs_i1 := tvi;

  {$IFDEF PDE_RIESGO}
  tvr := HistoCF1_;
  HistoCF1_ := HistoCF1_s;
  HistoCF1_s := tvr;
  {$ENDIF}
end;

procedure TGlobs.Free;
var
  k: integer;
begin

  {$IFDEF GLOBS_LOG}
   if flg_flog_open then
     log_Close;
  {$ENDIF}

  setlength(self.DurPos, 0);
  SetLength(invDurPos, 0);
  setlength( jRnd_Poste_globs, 0 );

  {$IFDEF CALC_MMEE}
  setlength(mmee_PrecioSpot, 0);
  setlength(mmee_SeguimientoDeLaDemanda_USD, 0);
  {$ENDIF}

  ActualizadorLPD.Free;
  if FechaInicioDelpaso <> nil then
    FechaInicioDelPaso.Free;
  if FechaFinDelPaso <> nil then
    FechaFinDelPaso.Free;

  if ( CF <> nil ) and not flg_CF_parasito then
    CF.Free;

  if liberarAuxs then
  begin
    for k := 0 to high(Auxs_r0) do
    begin
      setlength(Auxs_r0[k], 0);
      setlength(Auxs_r1[k], 0);
    end;
    setlength(Auxs_r0, 0);
    setlength(Auxs_r1, 0);

    for k := 0 to high(Auxs_i0) do
    begin
      setlength(Auxs_i0[k], 0);
      setlength(Auxs_i1[k], 0);
    end;
    setlength(Auxs_i0, 0);
    setlength(Auxs_i1, 0);
  end;


  {$IFDEF CALC_DEMANDA_NETA}
  setlength(Suma_PHorarias, 0);
  setlength(idxHorasPostizadas, 0);
  setlength(kBasePoste_idxHorasPostizadas, 0);
  setlength(NHorasDelPoste, 0);
  {$ENDIF}


  //{$IFDEF DBG}
  //  CloseFile(fdbg);
  //{$ENDIF}
  inherited Free;
end;

procedure TGlobs.CambioFichaPD;
begin
  raise Exception.Create('Metodo abstracto cambioFichaPD en ' + self.ClassName);
end;

procedure TGlobs.PubliVars;
begin
  inherited PubliVars;
  PublicarVariableFecha('FechaInicioDelPaso', FechaInicioDelPaso);
  PublicarVariableFecha('FechaFinDelPaso', FechaFinDelPaso);
  PublicarVariableNI('kPaso', '-', kPaso_Sim);
  PublicarVariableNI('kCronica', '-', kCronica);
end;























































































{$IFDEF BOSTA}
procedure TGlobs.AfterInstantiation;
var
  i: integer;
begin
  inherited AfterInstantiation;
  {$IFDEF CALC_DEMANDA_NETA}
  setlength(Suma_PHorarias, 0);
  setlength(idxHorasPostizadas, 0);
  setlength(kBasePoste_idxHorasPostizadas, 0);
  setlength(NHorasDelPoste, 0);
  {$ENDIF}
  EscenarioActivo := nil;
  {$IFDEF PDE_RIESGO}
  setlength(HistoCF0, 0);
  setlength(HistoCF1_, 0);
  setlength(HistoCF1_s, 0);
  {$ENDIF}
  procAlertaHabilitado := False;
  calcularConstantesBasicasDelPaso;
  setLength(kPosteHorasDelPaso, ceil(HorasDelPaso));
  demandaPrincipal := nil;
  {$IFDEF CALC_MMEE}
  mmee_TopeDelSpot := 250.0; // ojo esto es para sobreescribir al leer
  setlength(mmee_PrecioSpot, NPostes);
  setlength(mmee_SeguimientoDeLaDemanda_USD, NPostes);
  {$ENDIF}
  SetLength(invDurPos, length(DurPos));

  for i := 0 to high(DurPos) do
    invDurPos[i] := 1 / durPos[i];

  SetLength(invDurPos, length(DurPos));

  for i := 0 to high(DurPos) do
    invDurPos[i] := 1 / durPos[i];

  invHorasDelPaso := 1 / HorasDelPaso;
  SegundosDelPaso := trunc(HorasDelPaso * 3600 + 0.1);
  invSegundosDelPaso := 1 / SegundosDelPaso;
  EstadoDeLaSala := CES_SIN_PREPARAR;
  ActualizadorLPD := TActualizadorFichasLPD.Create( idHilo );
  FechaInicioDelpaso := TFecha.Create_Clone(fechaIniOpt);
  FechaFinDelPaso := TFecha.Create_OffsetHoras(FechaInicioDelpaso, HorasDelPaso);
  CF := nil;
  clearProcNots;
  MadresUniformes := TMadresUniformes.Create(CMultiplicadorSemillasSim);
  Fijar_kPaso(1); // solo para que inicialmente esté algo definido
end;
{$ENDIF}


function TGlobs.Validate: boolean;
var
  isValid: boolean;
begin
  isValid := False;

  // fIniOpt <= fIniSim <= fFinSim <= fFinOpt
  if (self.FechaIniOpt.dt <= self.FechaIniSim.dt) and
    (self.FechaIniSim.dt <= self.FechaFinSim.dt) and
    (self.FechaFinSim.dt <= self.FechaFinOpt.dt) then
    isValid := True;

  Result := (inherited Validate) and isValid;
end;

function TGlobs.InfoAd_: string;
begin
  Result:=inherited InfoAd_+fechaIniSim.AsAAAAMMDDhhmmtr;
end;



{$IFDEF GLOBS_LOG}
procedure TGLobs.log_OpenCreate;
begin
  if flg_flog_open then exit;
  assignfile( flog, getDir_Dbg+ DirectorySeparator +'globs'+IntToStr( idHilo )+'.log' );
  rewrite( flog );
  flg_flog_open:= true;
end;

procedure TGLobs.log_Close;
begin
  if flg_flog_open then
  begin
    closefile( flog );
    flg_flog_open:= false;
  end;
end;

procedure TGLobs.log_Writeln_( s: string  );
begin
  if not flg_flog_open then log_OpenCreate;
  writeln( flog, DateTimeToStr( now ),
         #9 + IntToStr( kPaso_Sim )
        +#9+ IntToStr( kCronica )
        +#9+ IntToStr( CF.ordinalEstrellaActual )
        +#9+IntToStr( cntIteracionesDelPaso )
        +#9, s );
end;

{$ENDIF}


procedure AlInicio;
begin
  registrarClaseDeCosa(TGlobs.ClassName, TGlobs);
end;

procedure AlFinal;
begin
end;

end.
