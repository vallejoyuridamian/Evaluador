program SimSEESimulador;

uses
  Forms,
  uSimSEE in 'uSimSEE.PAS' {fSimSEE},
  uInicioYFinal in '..\..\fc\base\uInicioYFinal.pas',
  uCosa in '..\..\fc\base\uCosa.pas',
  udbgutil in '..\..\fc\base\udbgutil.pas',
  ufechas in '..\..\fc\base\ufechas.pas',
  uconstantesSimSEE in '..\..\fc\base\uconstantesSimSEE.pas',
  uCosaConNombre in '..\..\fc\base\uCosaConNombre.pas',
  uVarDefs in '..\..\fc\base\uVarDefs.pas',
  uActores in '..\..\fc\actores\uActores.pas',
  uglobs in '..\..\fc\base\uglobs.pas',
  ufichasLPD in '..\..\fc\base\ufichasLPD.pas',
  uActualizadorLPD in '..\..\fc\base\uActualizadorLPD.pas',
  uEstados in '..\..\fc\base\uEstados.pas',
  uodt_types in '..\..\fc\base\uodt_types.pas',
  uActorNodal in '..\..\fc\actores\uActorNodal.pas',
  unodos in '..\..\fc\actores\unodos.pas',
  uFuncionesReales in '..\..\fc\base\uFuncionesReales.pas',
  usalasdejuego in '..\..\fc\base\usalasdejuego.pas',
  uranddispos in '..\..\fc\base\uranddispos.pas',
  uauxiliares in '..\..\fc\base\uauxiliares.pas',
  uDemandas in '..\..\fc\actores\uDemandas.pas',
  uGeneradores in '..\..\fc\actores\uGeneradores.pas',
  uMercadoSpot in '..\..\fc\actores\uMercadoSpot.pas',
  uFuentesAleatorias in '..\..\fc\base\uFuentesAleatorias.pas',
  uevapUruguay in '..\..\fc\base\uevapUruguay.pas',
  ucronometros in '..\..\fc\base\ucronometros.pas',
  uParqueEolico in '..\..\fc\actores\uParqueEolico.pas',
  ugter_basico in '..\..\fc\actores\ugter_basico.pas',
  uGTer in '..\..\fc\actores\uGTer.pas',
  ugter_onoffporposte in '..\..\fc\actores\ugter_onoffporposte.pas',
  ugter_onoffporpaso in '..\..\fc\actores\ugter_onoffporpaso.pas',
  udemandas01 in '..\..\fc\actores\udemandas01.pas',
  udemandadetallada in '..\..\fc\actores\udemandadetallada.pas',
  udatoshorariosdetallados in '..\..\fc\base\udatoshorariosdetallados.pas',
  uHidroDePasada in '..\..\fc\actores\uHidroDePasada.pas',
  uManejadoresDeMonitores in '..\..\fc\monitores\uManejadoresDeMonitores.pas',
  uReferenciaMonitor in '..\..\fc\monitores\uReferenciaMonitor.pas',
  uMonitores in '..\..\fc\monitores\uMonitores.pas',
  uEventosOptSim in '..\..\fc\monitores\uEventosOptSim.pas',
  uFuenteSintetizador in '..\..\fc\base\uFuenteSintetizador.pas',
  uReferenciaMonitorConsola in '..\..\fc\monitores\uReferenciaMonitorConsola.pas',
  uMonitorConsola in '..\..\fc\monitores\uMonitorConsola.pas',
  uReferenciaMonArchivo in '..\..\fc\monitores\uReferenciaMonArchivo.pas',
  uMonitorArchivo in '..\..\fc\monitores\uMonitorArchivo.pas',
  uReferenciaMonitorGraficoSimple in '..\..\fc\monitores\uReferenciaMonitorGraficoSimple.pas',
  uMonitorGraficoSimple in '..\..\fc\monitores\uMonitorGraficoSimple.pas',
  uReferenciaMonHistograma in '..\..\fc\monitores\uReferenciaMonHistograma.pas',
  uMonitorHistograma in '..\..\fc\monitores\uMonitorHistograma.pas',
  uFuenteCombinacion in '..\..\fc\base\uFuenteCombinacion.pas',
  uFuenteUniforme in '..\..\fc\base\uFuenteUniforme.pas',
  uFuenteConstante in '..\..\fc\base\uFuenteConstante.pas',
  uFuenteGaussiana in '..\..\fc\base\uFuenteGaussiana.pas',
  uFuenteWeibull in '..\..\fc\base\uFuenteWeibull.pas',
  uEsclavizadorSobreMuestreado in '..\..\fc\base\uEsclavizadorSobreMuestreado.pas',
  uEsclavizador in '..\..\fc\base\uEsclavizador.pas',
  uDemandaAnioBaseEIndices in '..\..\fc\actores\uDemandaAnioBaseEIndices.pas',
  uEsclavizadorSubMuestreado in '..\..\fc\base\uEsclavizadorSubMuestreado.pas',
  ugter_basico_trep in '..\..\fc\actores\ugter_basico_trep.pas',
  upreprocesador in '..\..\fc\base\upreprocesador.pas',
  uverdoc in '..\..\fc\base\uverdoc.pas' {formVerDoc},
  ucontratomodalidaddevolucion in '..\..\fc\actores\ucontratomodalidaddevolucion.pas',
  uHidroConEmbalse in '..\..\fc\actores\uHidroConEmbalse.pas',
  uComercioInternacional in '..\..\fc\actores\uComercioInternacional.pas',
  umodelosintcegh in '..\..\fc\base\umodelosintcegh.pas',
  utilidades in '..\..\fc\PA10\utilidades.pas',
  uFuenteProducto in '..\..\fc\base\uFuenteProducto.pas',
  ugter_arranqueparada in '..\..\fc\actores\ugter_arranqueparada.pas',
  uDatosHistoricos in '..\..\fc\base\uDatosHistoricos.pas',
  uMercadoSpotConDetalleHorarioSemanal in '..\..\fc\actores\uMercadoSpotConDetalleHorarioSemanal.pas',
  uBaseMercadoSpot in '..\..\fc\actores\uBaseMercadoSpot.pas',
  uSustituirVariablesPlantilla in '..\..\fc\simres\uSustituirVariablesPlantilla.pas',
  ugter_onoffporpaso_conrestricciones in '..\..\fc\actores\ugter_onoffporpaso_conrestricciones.pas',
  uversiones in '..\..\fc\base\uversiones.pas',
  uMonitorSimRes in '..\..\fc\monitores\uMonitorSimRes.pas',
  uReferenciaMonSimRes in '..\..\fc\monitores\uReferenciaMonSimRes.pas',
  uHidroConEmbalseBinacional in '..\..\fc\actores\uHidroConEmbalseBinacional.pas',
  ugter_arranqueparada_noopt in '..\..\fc\actores\ugter_arranqueparada_noopt.pas',
  uArcos in '..\..\fc\actores\uArcos.pas',
  ugestorsalasmh in '..\..\fc\base\ugestorsalasmh.pas',
  uRobotCalculoOptimizadorMulticore in '..\..\fc\base\uRobotCalculoOptimizadorMulticore.pas',
  uRobotEscritorOptimizadorMulticore in '..\..\fc\base\uRobotEscritorOptimizadorMulticore.pas',
  TVectors in '..\..\fc\PA10\TVectors.pas',
  winLinuxUtils in '..\..\fc\PA10\winLinuxUtils.pas',
  uHidroConBombeo in '..\..\fc\actores\uHidroConBombeo.pas',
  uParqueEolico_vxy in '..\..\fc\actores\uParqueEolico_vxy.pas',
  ugter_basico_PyCVariable in '..\..\fc\actores\ugter_basico_PyCVariable.pas',
  ipcthrd in '..\..\src_nettopos\src_libnettopos\fctopos\IPC\Win32\ipcthrd.pas',
  uMercadoSpot_postizado in '..\..\fc\actores\uMercadoSpot_postizado.pas',
  ufuentetiempo in '..\..\fc\base\ufuentetiempo.pas';

{$R *.RES}

begin
  try
    begin
    //  Set8087CW($1332);//Hace que la FPU use precisión extended en las cuentas internas
                         //Ver http://qc.borland.com/wc/qcmain.aspx?d=8399
      uInicioYFinal.AlInicio;
      Application.MainFormOnTaskbar := True;
      Application.Title := 'Simulador';
      Application.CreateForm(TfSimSEE, fSimSEE);
  Application.Run;
    end
  finally
    uInicioYFinal.AlFinal;
  end
end.
