{xDEFINE CHEQUEOMEM}
{$DEFINE SPXMEJORCAMINO}
unit umh_distribuidor_optsim;

{
rch@291310050943

Me propongo reescribir el MultiHilo haciendo que se creen tanttos workers
como hilos de cálculo se quiera y que el hilo principal se encarge de
administrar las tareas.

}
{$MODE Delphi}
interface

uses
{$IFDEF CHEQUEOMEM}
  udbgutil,
{$ENDIF}
  Classes, SysUtils,
  uglobs, Math,
  uconstantesSimSEE,
  xmatdefs,
 {$IFDEF SPXMEJORCAMINO}
  umipsimplex_mejorcamino,
 {$ELSE}
  umipsimplex,
 {$ENDIF}
  winLinuxUtils,
  uAuxiliares,
  usalasdejuego,
  uacumuladores_sim,
  uInterpreteDeParametros,
  uversiones, umh_sincrodata;

type
  {
  TGestorSalaMH esta clase es utilizada para dar "multiplicidad" a una sala para el procesamiento
  en paralelo en varios hilos.
  }
  TGestorSalaMH = class
  private
  public
    sala: TSalaDeJuego;
    sincrodata_mh: TSincroData_mh;

    nCores: integer;                    //cantidad de Nucleos en el equipo.
    //Por defecto es 1

    nHilosForzados: integer;
    //-1 significa libre, otro valor la cantidad de hilos a usar

    nTareasForzadas: integer;
    //-1 significa libre, otro valor la cantidad de tareas a calcular por paso


    nTareas: integer;                   //Número de particiones del frame
    nHilos: integer;                    //Número de hilos realizando los cálculos

    constructor Create(sala: TSalaDeJuego); { Guarda el puntero a la sala y obtiene la cantidad de núcles en el sistema.
      Pero no hace más nada }

    procedure sim_inicializarVariablesMultiCore(NCronicas: integer);
    procedure sim_CrearTareas(kCronicaIni, kCronicaFin: integer);

    // Retorna el valor esperado del costo.
    function sim_SimularMultiCore(nHilosForzados: integer ): NReal;

    procedure opt_darPaso;
    procedure opt_inicializarVariablesMultiCore;
    procedure opt_CrearTareas(estrellaIni, estrellaFin: integer);

    // poner nHilosForzados = -1 si se quiere igual cantidad de hilos que CORES del PC
    procedure opt_OptimizarMultiCore(nHilosForzados: integer);
    procedure opt_guardarResultadosOpt(dir: string);

    procedure liberarVariablesMultiCore;

    procedure AplicarParametros(aInterpreteDeParametros: TInterpreteParametros);
  end;

implementation

uses
  umh_worker_opt, umh_worker_sim;

constructor TGestorSalaMH.Create(sala: TSalaDeJuego);
begin
  inherited Create;
  self.sala := sala;
  self.nCores :=  winLinuxUtils.GetSystemCoreCount;
  self.nHilosForzados := -1;
  self.nHilos := 1;
  self.nTareasForzadas := -1;
  self.nTareas := 1;
end;



procedure TGestorSalaMH.opt_darPaso;
begin
  sala.globs.SwapAuxs;
  sala.globs.Fijar_kPaso(sala.globs.kPaso_Opt - 1);
end;

procedure TGestorSalaMH.opt_inicializarVariablesMultiCore;
var
  i: integer;
  robot: TRobotOptRangoEstrellas;
  flg_Habilitado: boolean;

begin

  if nHilosForzados = -1 then
    nHilos := nCores
  else
    nHilos := nHilosForzados;

  if nTareasForzadas <> -1 then
    nTareas := nTareasForzadas
  else
    nTareas := nHilos;

  sincrodata_mh := TSincroData_mh.Create(nTareas, nHilos);

  sala.globs.Alerta('Optimización multihilo, Nucleos: ' + IntToStr(
    nCores) + ', Hilos: ' + IntToStr(nHilos));

  if sala.globs.procAlertaHabilitado then
  begin
    sala.globs.deshabilitarAlertas;
    flg_Habilitado:= true;
  end
  else
    flg_Habilitado:= false;

  sincrodata_mh.paso := sala.globs.NPasos + 1;

  for i := 0 to high(sincrodata_mh.robots) do
  begin
    robot := TRobotOptRangoEstrellas.Create(i, sincrodata_mh, sala);
    if Assigned(Robot.FatalException) then
      raise Robot.FatalException;
    sincrodata_mh.robots[i] := robot;
  end;


  if flg_Habilitado then
    sala.globs.habilitarAlertas;
end;

procedure TGestorSalaMH.sim_inicializarVariablesMultiCore( NCronicas: integer );
var
  i: integer;
  robot: TRobotSimRangoCronicas;
begin
  if nHilosForzados = -1 then
    nHilos := nCores
  else
    nHilos := nHilosForzados;

  if nTareasForzadas <> -1 then
    nTareas := nTareasForzadas
  else
    nTareas := nHilos;

  nTareas:= min( NCronicas, nTareas );
  nHilos:= min( nHilos, nTareas );

  writeln('sim_inicializarVariablesMultiCore');
  writeln('nTareas: ', nTareas, ', nHilos: ', nHilos);

  sincrodata_mh := TSincroData_mh.Create(nTareas, nHilos);

  sala.globs.Alerta('Simulación multihilo, Nucleos: ' + IntToStr(
    nCores) + ', Hilos: ' + IntToStr(nHilos));
  sala.globs.deshabilitarAlertas;

  sincrodata_mh.paso := 1 + 1;

  for i := 0 to high(sincrodata_mh.robots) do
  begin
    robot := TRobotSimRangoCronicas.Create(i, sincrodata_mh, sala);
    if Assigned(Robot.FatalException) then
      raise Robot.FatalException;
    sincrodata_mh.robots[i] := robot;
  end;
  sala.globs.habilitarAlertas;
end;


procedure TGestorSalaMH.liberarVariablesMultiCore;
begin
  sincrodata_mh.Free;
end;

procedure TGestorSalaMH.AplicarParametros(
  aInterpreteDeParametros: TInterpreteParametros);
begin
  // si no está definido vamos a monohilo
  nHilosForzados := aInterpreteDeParametros.valInt('nhilos', 1);
  nTareasForzadas := aInterpreteDeParametros.valInt('ntareas', 1);
end;

procedure TGestorSalaMH.opt_CrearTareas(estrellaIni, estrellaFin: integer);
var
  i, iEstrIni, iEstrFin: integer;
  nEstrellas, nEstrellasPorTarea, nTareasConUnaEstrellaMas: integer;
begin
  nEstrellas := estrellaFin - estrellaIni + 1;

  nEstrellasPorTarea := nEstrellas div nTareas;
  nTareasConUnaEstrellaMas := nEstrellas mod nTareas;

  setlength(sincrodata_mh.tareas, nTareas);
  iEstrIni := estrellaIni;
  for i := 0 to nTareasConUnaEstrellaMas - 1 do
  begin
    iEstrFin := iEstrIni + nEstrellasPorTarea;
    sincrodata_mh.tareas[i] :=
      TTareaCalcularRangoEstrellas.Create(i, iEstrIni, iEstrFin);
    iEstrIni := iEstrFin + 1;
  end;

  for i := nTareasConUnaEstrellaMas to nTareas - 1 do
  begin
    iEstrFin := iEstrIni + nEstrellasPorTarea - 1;
    sincrodata_mh.tareas[i] :=
      TTareaCalcularRangoEstrellas.Create(i, iEstrIni, iEstrFin);
    iEstrIni := iEstrFin + 1;
  end;

end;

procedure TGestorSalaMH.sim_CrearTareas(kCronicaIni, kCronicaFin: integer);
var
  i, iCronIni, iCronFin: integer;
  nCronicas, nCronicasPorTarea, nTareasConUnaCronicaMas: integer;
begin
  nCronicas := kCronicaFin - kCronicaIni + 1;

  nCronicasPorTarea := nCronicas div nTareas;
  nTareasConUnaCronicaMas := nCronicas mod nTareas;

  setlength(sincrodata_mh.tareas, nTareas);
  iCronIni := kCronicaIni;
  for i := 0 to nTareasConUnaCronicaMas - 1 do
  begin
    iCronFin := iCronIni + nCronicasPorTarea;
    sincrodata_mh.tareas[i] :=
      TTareaSimRangoCronicas.Create(i, iCronIni, iCronFin);
    iCronIni := iCronFin + 1;
  end;

  for i := nTareasConUnaCronicaMas to nTareas - 1 do
  begin
    iCronFin := iCronIni + nCronicasPorTarea - 1;
    sincrodata_mh.tareas[i] :=
      TTareaSimRangoCronicas.Create(i, iCronIni, iCronFin);
    iCronIni := iCronFin + 1;
  end;
end;


procedure TGestorSalaMH.opt_OptimizarMultiCore(nHilosForzados: integer);
var
  dtIni, dtPaso: TDateTime;
  kPasoIni: integer;
  segundos_transcurridos, segundos_restantes: NReal;
begin
  dtIni := now;
  self.nHilosForzados := nHilosForzados;
  try
    if sala.inicializarOptimizacion(nil, nil) = 0 then
      exit; // No hay variables de estado = no hay optimización

    if sala.globs.EstadoDeLaSala = CES_OPTIMIZANDO then
    begin
      // inicializa las variables y crea un robot por thread
      opt_inicializarVariablesMultiCore;
      sala.globs.procNot(sala.globs.procNot_opt_InicioOptimizacion);
      opt_crearTareas(0, sala.globs.CF.nEstrellasPorPuntoT - 1);
      sincrodata_mh.Paso := sala.globs.kPaso_Opt;
      sincrodata_mh.start_workers;

      kPasoIni := sala.globs.kPaso_Opt;

      while (sala.globs.kPaso_Opt > 0) and (not sala.globs.abortarSim) and
        (not sincrodata_mh.abortarSim) do
      begin
        if sala.globs.kPaso_Opt < kPasoIni then
        begin
          dtPaso := now;
          segundos_transcurridos := (dtPaso - dtIni) * 3600 * 24;
          segundos_restantes :=
            segundos_transcurridos / (kPasoIni - sala.globs.kPaso_Opt) * sala.globs.kPaso_Opt;

          sincrodata_mh.wrln('paso: ' + IntToStr(sala.globs.kPaso_Opt) +
            ', st: ' + IntToStr(trunc(segundos_transcurridos)) + ', sr: ' +
            IntToStr(trunc(segundos_restantes)));
        end;
        sincrodata_mh.dst_HacerTareas(True, sala.globs.kPaso_Opt, -1);
        opt_darPaso;
        sala.globs.procNot(sala.globs.procNot_opt_FinCalculosDeEtapa);
      end;
      // con esto le pido a todos los robots que se mueran
      sincrodata_mh.wrln('SalaMH.opt_OptimizarMulticore->Free_Workers BEGIN');
      sincrodata_mh.Free_workers;
      sincrodata_mh.wrln('SalaMH.opt_OptimizarMulticore->Free_Workers END');
      sala.FinOptimizacion;
    end;

    if not sala.globs.abortarSim then
    begin
      opt_guardarResultadosOpt(sala.dirResultadosCorrida);
      sala.globs.EstadoDeLaSala := CES_OPTIMIZACION_TERMINADA;
    end
    else
      sala.globs.EstadoDeLaSala := CES_OPTIMIZACION_ABORTADA;
    liberarVariablesMultiCore;
  except
    sala.globs.EstadoDeLaSala := CES_OPTIMIZACION_ABORTADA;
    sala.globs.abortarSim := True;
    liberarVariablesMultiCore;
    raise;
  end;
end;

function TGestorSalaMH.sim_SimularMultiCore(nHilosForzados: integer): NReal;
var
  aRobotSim: TRobotSimRangoCronicas;
  flg_OK: boolean;
  k: integer;

begin
  self.nHilosForzados := nHilosForzados;
  // inicializa las variables y crea un robot por thread

  sim_inicializarVariablesMultiCore( sala.globs.NCronicasSim );

  sala.globs.procNot(sala.globs.procNot_InicioSimulacion);

  sim_crearTareas(1, sala.globs.NCronicasSim);
  sincrodata_mh.Paso := 1;

  writeln('Creando acumuladores' );
  sala.Acumuladores := TAcumuladores_sim.Create(sala.globs, sala.globs.NCronicasSim);

  writeln( '... llamo start_workers ...' );
  sincrodata_mh.start_workers;

  writeln( 'dst_HacerTareas(True, 1, -1)');
  sincrodata_mh.dst_HacerTareas(True, 1, -1);


  flg_OK:= true;
  for k:= 0 to high( sincrodata_mh.robots ) do
  begin
   aRobotSim:= sincrodata_mh.robots[k] as TRobotSimRangoCronicas;
   if aRobotSim.sala.globs.EstadoDeLaSala <> CES_SIMULACION_TERMINADA then
   begin
     flg_OK:= false;
     break;
   end;
  end;

  if flg_OK then
    sala.globs.EstadoDeLaSala:= CES_SIMULACION_TERMINADA
  else
    sala.globs.EstadoDeLaSala:= CES_SIMULACION_ABORTADA;

  // con esto le pido a todos los robots que se mueran
  writeln( 'Free_workers');
  sincrodata_mh.Free_workers;

  writeln( 'PrinArchi');
  Result := Sala.Acumuladores.PrinArchi(sala.Archi_SimCosto);
  Sala.Acumuladores.GetResumen(  sala.ve_CF, sala.VaR05_CF, sala.CVaR05_CF );
  writeln( 'Acumuladores.Free');
  sala.Acumuladores.Free;

  writeln( 'LiberarVariablesMulticore' );
  liberarVariablesMultiCore;
end;


procedure TGestorSalaMH.opt_guardarResultadosOpt(dir: string);
var
  camino, archi: string;
  fsal: TextFile;
  costosFuturosDelPaso: TDAofNReal;
  i, k: integer;
  nPasos: integer;
  linea: string;
begin
  if dir[Length(dir)] = DirectorySeparator then
    camino := dir
  else
    camino := dir + DirectorySeparator;

  if sala.globs.SortearOpt then
    archi := camino + 'optres_' + IntToStr(sala.globs.semilla_inicial_opt) +
      'x' + IntToStr(sala.globs.NCronicasOpt) + '_' +
      sala.EscenarioActivo.nombre + '.xlt'
  else
    archi := camino + 'optres_VE_' + sala.EscenarioActivo.nombre + '.xlt';


  sala.globs.Alerta('Escribiendo resultados en: ' + archi);
  assignfile(fsal, archi);
  rewrite(fsal);
  try
    writeln(fsal, 'Versión del simulador:'#9, vSimSEESimulador_);
    writeln(fsal, 'fActPaso:', #9, FloatToStrF(sala.globs.fActPaso,
      ffGeneral, 12, 10));
    sala.globs.CF.constelacion.PrintDefsToText(fsal, True);
    nPasos := sala.globs.calcNPasosOpt;

    Write(fsal, 'paso\estado'#9'Fecha');
    for k := 1 to sala.globs.CF.nEstrellasPorPuntoT do
      Write(fsal, #9, k);
    writeln(fsal);

    for i := 0 to nPasos do
    begin
      sala.globs.Fijar_kPaso(nPasos - (i - 1));
      costosFuturosDelPaso := sala.globs.CF.constelacion.fCosto[nPasos - (i - 1)];
      linea := IntToStr(sala.globs.kpaso_Opt) + #9 +
        sala.globs.FechaInicioDelpaso.AsISOStr + #9 +
        FloatToStrF(costosFuturosDelPaso[0], ffGeneral, 6, 2);
      for k := 1 to high(costosFuturosDelPaso) do
        linea := linea + #9 + FloatToStrF(costosFuturosDelPaso[k], ffGeneral, 6, 2);
      writeln(fsal, linea);
    end;
    // esto se hace en otro lado
    // sala.globs.CF.StoreInArchi(dir + DirectorySeparator + 'CF_'+sala.EscenarioActivo.nombre +'.bin');
  finally
    CloseFile(fsal);
  end;
end;

end.
