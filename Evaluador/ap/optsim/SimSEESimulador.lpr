program SimSEESimulador;
//{$DEFINE TRANSLATOR}
{$MODE Delphi}
uses {$IFDEF LINUX}
  cthreads, {$ENDIF}
  Interfaces,
  Forms,
  xmatdefs,
  uSimSEE,
  uverdoc,
  upreprocesador,
  uglobs,
  uInicioYFinal,
  uComercioInternacional,
  umodelosintcegh,
  utilidades,
  uFuenteProducto,
  ugter_arranqueparada,
  uDatosHistoricos,
  uMercadoSpotConDetalleHorarioSemanal,
  uBaseMercadoSpot,
  ugter_onoffporpaso_conrestricciones,
  uversiones,
  uMonitorSimRes,
  uReferenciaMonSimRes,
  uHidroConEmbalseBinacional,
  ugter_arranqueparada_noopt,
  ugter_basico_PyCVariable,
  uArcos,
  uusogestionable_postizado,
  uActores,
  uActorNodal,
  uMercadoSpot_postizado,
  uHidroConEmbalse,
  ugter_basico,
  uGTer,
  uHidroDePasada,
  usolartermico,
  ugter_basico_trep,
  uParqueEolico_vxy,
  ugter_onoffporpaso,
  usolarpv,
  winLinuxUtils,
  umh_distribuidor_optsim,
  uMIPSimplexIteradorNoLineal,
  TVectors,
  utrazosxy,
  SysUtils,
  unube,
  umatriz_ruida,
  uiteradoressimsee,
  umadresuniformes,
  ucosaparticipedemercado,
  uFuenteSintetizador,
  usalasdejuego,
  uodt_types,
  uEstados,
  ucosa,
  ufechas,
  uFuentesAleatorias,
  ufuenteselector_horario,
  ucalibrarconopronosticos,
  uSustituirVariablesPlantilla,
  uresfxgx,
  uproblema,
  matreal,
  algebrac,
  fddp,
  udisnormcan,
  umipsimplex_mejorcamino,
  usimplex,
  uforzamientos,
  ucontroladordeterminista,
  umh_sincrodata,
  umh_worker_sim,
  uacumuladores_sim,
  udatoshorariosdetallados,
  uRobotHttpPost,
  uFuncionesReales,
  ufichasLPD,
  uEsclavizadorSubMuestreado,
  httpsend,
  uauxiliares,
  uversion_architexto,
  upronostico,
  uEsclavizadorSobreMuestreado,
  ubiomasaembalsable,
  ugsimple_monocombustible,
  uRegasificadora,
  uExcelFile,
  uAgendaGNL,
  uTSumComb,
  uGeneradores,
  uParqueEolico,
  uDemandas,
  ugter_combinado,
  udemandaCombustibleAnioBaseEIndices,
  uDemandaAnioBaseEIndices,
  unodocombustible,
  uCombustible,
  udemandaCombustible,
  uActorNodalCombustible,
  uArcoCombustible,
  ubancodebaterias01,
  uHidroConBombeo, {$IFDEF TRANSLATOR}
  LResources,
  DefaultTranslator,
  LCLTranslator,
  Translations, {$ENDIF} {$IFDEF MISION_IMPOSIBLE}
  uVirtualTablesDefs,
  Unit2, {$ENDIF}
  ugsimple_bicombustible,
  udemandadetallada,
  udemandas01,
  uestados_aproximador_cf01, uFuenteConstante, uunidades;

{$IFDEF TRANSLATOR}
var
  LanguageFileName: string;

{$ENDIF}

{$R *.res}


{$IFDEF HEAP_TRC}
const
  HEAPT = 'c:\basura\cmdopt_heap.trc';
{$ENDIF}
begin

  {$IFDEF HEAP_TRC}
  if FileExists(HEAPT) then
    DeleteFile(HEAPT);
  SetHeapTraceOutput(HEAPT);
  {$ENDIF}

  try
    begin
      {$IFDEF TRANSLATOR}
      //Si hay un archivo de traducciones para ese idioma uso ese
      //sino, uso el idioma por defecto
      LanguageFileName := 'language\SimSEESimulador.po';
      if FileExists(LanguageFileName) then
        // ATENCION: si recibe un error al compilar lea lo siguiente:
        // Si no encuentra TPoTranslator actualice la versión de Lazarus a 1.4.0 o superior.
        // Si no encuentra LRSTranslator, verifique que esté la unidad: "LResources" en la claúsula
        // uses más arriba. En ocasiones, si en Opciones del Proyecto se habilita Temas de Window Vista
        // el IDE elimina dicha unidad en forma automática.
        if LRSTranslator <> nil then
          LRSTranslator := TPoTranslator.Create(LanguageFileName);
      {$ENDIF}
      uInicioYFinal.AlInicio;
      Application.Initialize;
      Application.Title := 'SimSEE';
      Application.CreateForm(TfSimSEE, fSimSEE);
      Application.Run;
    end
  finally
    uInicioYFinal.AlFinal;
  end;
end.
