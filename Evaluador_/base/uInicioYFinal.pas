unit uInicioYFinal;

{ Registro de clases centralizado }
interface

uses
  Classes,
  uCosa,
  uCosaConNombre,
  uActores,
  uunidades,
  uforzamientos,
  uActorNodal,
  uGlobs,
  uFuncionesReales,
  uSalasDeJuego,
{$IFDEF MONITORES}
  uEventosOptSim,
  uManejadoresDeMonitores,
  uReferenciaMonitor,
  uReferenciaMonitorConsola,
  uReferenciaMonArchivo,
  uReferenciaMonHistograma,
  uReferenciaMonSimRes,
  uMonitorArchivo,
  {$IFDEF MODOGRAFICO}
  uReferenciaMonitorGraficoSimple,
  {$ENDIF}
  {$ENDIF}
{$IFDEF INFOTIPOS}
  uInfoCosa,
{$ENDIF}
  uGeneradores,
  uGTer_Basico,
  ugter_basico_trep,
  ugter_basico_PyCVariable,
  uGTer_OnOffPorPoste,
  ugter_combinado,
  uGTer_OnOffPorPaso,
  ugter_onoffporpaso_conrestricciones,
  uGTer_ArranqueParada,
  usolartermico,
  usolarPV,
  ubiomasaembalsable,
  uParqueEolico,
  uParqueEolico_vxy,
  uDemandas,
  uDemandas01, uDemandaDetallada, uDemandaAnioBaseEIndices,
  uArcos, uNodos,
  uHidroConEmbalse,
  uHidroConEmbalseBinacional,
  uHidroDePasada,
  uHidroConBombeo,
  uMercadoSpot,
  uMercadoSpot_postizado,
  uMercadoSpotConDetalleHorarioSemanal,
  ucontratomodalidaddevolucion,
  ubancodebaterias01,
  uarcoconsalidaprogramable,
  uUsoGestionable_postizado,
  uFuentesAleatorias,
  uFuenteWeibull,
  uFuenteGaussiana,
  uFuenteConstante,
  uFuenteUniforme,
  uFuenteSintetizador,
  uFuenteCombinacion,
  uFuenteProducto,
  uFuenteSelector,
  ufuentemaxmin,
  ufuentetiempo,
  ufuentesinusoide,
  ufichasLPD,
  upronostico,
  ufichasdeterminismos_obsoleta, // obsoleta, solo para leer salas viejas
  uEstados,
  ulistaplantillassr3,
  ufuenteselector_horario,

  {PROYECTO ANII - AGENDA GNL}
  uCombustible,
  unodocombustible,
  uActorNodalCombustible,
  uArcoCombustible,
  uDemandaCombustibleAnioBaseEIndices,
  ugsimple_bicombustible,
  ugsimple_monocombustible,
  uTSumComb,
  uRegasificadora,
  uAgendaGNL,
  uescenarios;

procedure AlInicio;
procedure AlFinal;

implementation

var
  cnt_llamadas: integer;

type
  TProcSP = procedure();


procedure Call_Inicio_o_Final(flg_Inicio: boolean);

  procedure csp(procAlInicio, procAlFinal: TProcSP );
  begin
    if flg_Inicio then
      procAlInicio
    else
      procAlFinal;
  end;

begin
  csp(uCosa.AlInicio, uCosa.AlFinal); // tiene que ser la primera
  csp(uCosaConNombre.AlInicio, uCosaConNombre.AlFinal); //tiene que ser la segunda
  csp(uGlobs.AlInicio, uGlobs.AlFinal);
  csp(uFuncionesReales.AlInicio, uFuncionesReales.AlFinal);
  csp(uSalasDeJuego.AlInicio, uSalasDeJuego.AlFinal);
{$IFDEF INFOTIPOS}
  csp( uInfoCosa.AlInicio, uInfoCosa.AlFinal);
{$ENDIF}

{$IFDEF MONITORES}
  csp( uEventosOptSim.alInicio, uEventosOptSim.AlFinal);
  csp( uManejadoresDeMonitores.AlInicio, uManejadoresDeMonitores.AlFinal);
  csp( uReferenciaMonitor.AlInicio, uReferenciaMonitor.AlFinal);
  csp( uReferenciaMonitorConsola.AlInicio, uReferenciaMonitorConsola.AlFinal);
  csp( uReferenciaMonArchivo.AlInicio, uReferenciaMonArchivo.AlFinal);
  csp( uReferenciaMonHistograma.AlInicio, uReferenciaMonHistograma.AlFinal);
  csp( uReferenciaMonSimRes.AlInicio, uReferenciaMonSimRes.AlFinal);
  csp( uMonitorArchivo.AlInicio, uMonitorArchivo.AlFinal);
{$IFDEF MODOGRAFICO}
  csp( uReferenciaMonitorGraficoSimple.AlInicio, uReferenciaMonitorGraficoSimple.AlFinal);
{$ENDIF}
{$ENDIF}

  csp( uunidades.AlInicio, uunidades.AlFinal);
  csp( uforzamientos.AlInicio, uforzamientos.AlFinal);

  // Actores ============================
  csp( uActores.AlInicio, uActores.AlFinal);
  csp( uActorNodal.AlInicio, uActorNodal.AlFinal);
  csp( uNodos.AlInicio, uNodos.AlFinal);
  csp( uArcos.AlInicio, uArcos.AlFinal);
  csp( uArcoConSalidaProgramable.AlInicio, uArcoConSalidaProgramable.AlFinal);
  csp( uDemandas01.AlInicio, uDemandas01.AlFinal);
  csp( uDemandas.AlInicio, uDemandas.AlFinal);
  csp( uDemandaDetallada.AlInicio, uDemandaDetallada.AlFinal);
  csp( uDemandaAnioBaseEIndices.AlInicio, uDemandaAnioBaseEIndices.AlFinal);
  csp( uGeneradores.AlInicio, uGeneradores.AlFinal);
  csp( uGTer_Basico.AlInicio, uGTer_Basico.AlFinal);
  csp( ugter_basico_trep.AlInicio, ugter_basico_trep.AlFinal);
  csp( ugter_basico_PyCVariable.AlInicio, ugter_basico_PyCVariable.AlFinal);
  csp( uGTer_OnOffPorPoste.AlInicio, uGTer_OnOffPorPoste.AlFinal);
  csp( ugter_combinado.AlInicio, ugter_combinado.AlFinal);
  csp( uGTer_OnOffPorPaso.AlInicio, uGTer_OnOffPorPaso.AlFinal);
  csp( ugter_onoffporpaso_conrestricciones.AlInicio, ugter_onoffporpaso_conrestricciones.AlFinal);
  csp( uGTer_ArranqueParada.AlInicio, uGTer_ArranqueParada.AlFinal);
  csp( ucombustible.AlInicio, ucombustible.AlFinal);
  csp( uActorNodalCombustible.AlInicio, uActorNodalCombustible.AlFinal);
  csp( uArcoCombustible.AlInicio, uArcoCombustible.AlFinal);
  csp( unodocombustible.AlInicio, unodocombustible.AlFinal);
  csp( uDemandaCombustibleAnioBaseEIndices.AlInicio, uDemandaCombustibleAnioBaseEIndices.AlFinal);
  csp( uTSumComb.AlInicio, uTSumComb.AlFinal);
  csp( ugsimple_bicombustible.AlInicio, ugsimple_bicombustible.AlFinal);
  csp( ugsimple_MonoCombustible.AlInicio, ugsimple_MonoCombustible.AlFinal);
  csp( uRegasificadora.AlInicio, uRegasificadora.AlFinal);
  csp( uAgendaGNL.AlInicio, uAgendaGNL.AlFinal);
  csp( uParqueEolico.AlInicio, uParqueEolico.AlFinal);
  csp( uParqueEolico_vxy.AlInicio, uParqueEolico_vxy.AlFinal );
  csp( usolarPV.AlInicio, usolarPV.AlFinal );
  csp( usolartermico.AlInicio, usolartermico.AlFinal );
  csp( ubiomasaembalsable.AlInicio, ubiomasaembalsable.AlFinal );
  csp( uHidroConEmbalse.AlInicio, uHidroConEmbalse.AlFinal );
  csp( uHidroConBombeo.AlInicio, uHidroConBombeo.AlFinal );
  csp( uHidroConEmbalseBinacional.AlInicio, uHidroConEmbalseBinacional.AlFinal );
  csp( uHidroDePasada.AlInicio, uHidroDePasada.AlFinal );
  csp( uMercadoSpot.AlInicio, uMercadoSpot.AlFinal );
  csp( uMercadoSpot_postizado.AlInicio, uMercadoSpot_postizado.AlFinal );
  csp( uMercadoSpotConDetalleHorarioSemanal.AlInicio, uMercadoSpotConDetalleHorarioSemanal.AlFinal );
  csp( ucontratomodalidaddevolucion.AlInicio, ucontratomodalidaddevolucion.AlFinal );
  csp( ubancodebaterias01.AlInicio, ubancodebaterias01.AlFinal );
  csp( uUsoGestionable_postizado.AlInicio, uUsoGestionable_postizado.AlFinal );

  //Fuentes=============================================
  csp( uFuentesAleatorias.AlInicio, uFuentesAleatorias.AlFinal );
  csp( uFuenteWeibull.AlInicio, uFuenteWeibull.AlFinal );
  csp( uFuenteGaussiana.AlInicio, uFuenteGaussiana.AlFinal );
  csp( uFuenteConstante.AlInicio, uFuenteConstante.AlFinal );
  csp( uFuenteUniforme.AlInicio, uFuenteUniforme.AlFinal );
  csp( uFuenteSintetizador.AlInicio, uFuenteSintetizador.AlFinal );
  csp( uFuenteCombinacion.AlInicio, uFuenteCombinacion.AlFinal );
  csp( uFuenteProducto.AlInicio, uFuenteProducto.AlFinal );
  csp( uFuenteSelector.AlInicio, uFuenteSelector.AlFinal );
  csp( ufuentetiempo.AlInicio, ufuentetiempo.AlFinal );
  csp( ufuentesinusoide.AlInicio, ufuentesinusoide.AlFinal );
  csp( ufuentemaxmin.AlInicio, ufuentemaxmin.AlFinal );
  csp( ufuenteselector_horario.AlInicio, ufuenteselector_horario.AlFinal );
  csp( uFichasLPD.AlInicio, uFichasLPD.AlFinal );
  csp( uEstados.AlInicio, uEstados.AlFinal );
  csp( upronostico.AlInicio, upronostico.AlFinal );
  csp( ufichasdeterminismos_obsoleta.AlInicio, ufichasdeterminismos_obsoleta.AlFinal );
  csp( ulistaplantillassr3.AlInicio, ulistaplantillassr3.AlFinal );
  csp( uescenarios.AlInicio, uescenarios.AlFinal );
end;

procedure AlInicio;
begin
  Inc(cnt_llamadas);
  if (cnt_llamadas > 1) then
    exit;
  Call_Inicio_o_Final(True);
end;

procedure AlFinal;
begin
  Dec(cnt_llamadas);
  if (cnt_llamadas <> 0) then
    exit;
  Call_Inicio_o_Final(False);
end;

begin
  cnt_llamadas := 0;
end.
