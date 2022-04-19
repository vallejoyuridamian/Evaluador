unit uCamposTHidroConBombeo;

interface

uses
  uCampo, uHidroConBombeo, uFechas, Math, urscampos;

procedure crearCamposTHidroConBombeo;
procedure liberarCamposTHidroConBombeo;

var
  camposHidroConBombeo, camposFichaHidroConBombeo: TDAOfTCampo;

implementation

procedure crearCamposTHidroConBombeo;
var
  actor: THidroConBombeo;
  ficha: TFichaHidroConBombeo;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := THidroConBombeo.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL, NIL,
    NIL, 0, 0, NIL, '', false);

  SetLength(camposHidroConBombeo, 1);
  a := camposHidroConBombeo;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(THidroConBombeo, camposHidroConBombeo));
  actor.Free;

  ficha := TFichaHidroConBombeo.Create(TFecha.Create_Dt(0), NIL, 0, 0, NIL, NIL, 0, NIL, NIL,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, false, 0, false, 0, false, false, false, 0, 0, 0,
    false, NIL, '', 0, 0, 0, 0, 0, 0);
  SetLength(camposFichaHidroConBombeo, 33);
  a := camposFichaHidroConBombeo;
  i := 0;

  {
    PMaxBombeo: NReal;
    QMaxBombeo: NReal;
    renBombeo: NReal;
    }

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsCotaMinimaDeOperacion, rsCotaMinOp, rsUm, ficha, ficha.hmin, 0, MaxDouble, a, i);
  addCampo(rsCotaMaximaDeOperacion, rsCotaMaxOp, rsUm, ficha, ficha.hmax, 0, MaxDouble, a, i);
  addCampo(rsSaltoMinimoOperativo, rsSaltoMinOp, rsUm, ficha, ficha.saltoMinimoOperativo, 0,
    MaxDouble, a, i);
  addCampo(rsCotaDeDescargaParaCalculoDelSalto, rsCotaDescargaCalcSalto, rsUm, ficha,
    ficha.hDescarga, 0, MaxDouble, a, i);
  addCampo(rsCotaMinimaParaVertimiento, rsCotaMinVert, rsUm, ficha, ficha.cotaMV0, 0,
    MaxDouble, a, i);
  addCampo(rsCotaMaximaParaVertimiento, rsCotaMaxVert, rsUm, ficha, ficha.cotaMV1, 0,
    MaxDouble, a, i);
  addCampo(rsCaudalVertidoCotaMaxima, rsQVertCotaMax, rsUm3Pors, ficha, ficha.QMV1, 0,
    MaxDouble, a, i);
  addCampo(rsRendimiento, rsRend, rsUpu, ficha, ficha.ren, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaximaGenerable, rsPMaxGen, rsUMW, ficha, ficha.Pmax_Gen, 0, MaxDouble,
    a, i);
  addCampo(rsCaudalMaximoTurbinable, rsQMaxTurb, rsUm3Pors, ficha, ficha.Qmax_Turb, 0,
    MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUpu, ficha, ficha.fDispo, 0, 1, a,
    i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeAfectacionDelSaltoPorCaudalErogadoCAQE, rsCAQE, rsVacio, ficha,
    ficha.caQE, a, i);
  addCampo(rsCoeficienteDeAfectacionDelSaltoPorCaudalErogadoCBQE, rsCBQE, rsVacio, ficha,
    ficha.cbQE, a, i);
  addCampo(rsCaFiltracion, rsCaFilt, rsUm3Pors, ficha, ficha.filtracion_Ca, 0, MaxDouble, a,
    i);
  addCampo(rsCbFiltracion, rsCbFilt, rsUm2Pors, ficha, ficha.filtracion_Cb, 0, MaxDouble, a,
    i);
  addCampo(rsQaMuySeco, rsQaMuySeco, rsUm3Pors, ficha, ficha.QaMuySeco, 0, MaxDouble, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);
  addCampo(rsHayRestriccionDeCaudalTurbinadoMinimoQ, rsRestrQTMinQ, rsVacio, ficha,
    ficha.HayRestriccionQTmin, a, i);
  addCampo(rsCaudalTurbinadoMinimo, rsQTMin, rsUm3Pors, ficha, ficha.QTmin, 0, MaxDouble, a,
    i);
  addCampo(rsImponerCaudalTurbinadoMinimoPorPosteQ, rsQTMinPPosteQ, rsVacio, ficha,
    ficha.ImponerQminPorPoste, a, i);
  addCampo(rsControlarSiEstaPorDebajoDelObjetivoQ, rsControlDebajoObjQ, rsVacio, ficha,
    ficha.ImponerQminPorPoste, a, i);
  addCampo(rsControlarSiEstaPorEncimaDelObjetivoQ, rsControlEncimaObjQ, rsVacio, ficha,
    ficha.ImponerQminPorPoste, a, i);
  addCampo(rsCotaObjetivo, rsCotaObj, rsUm, ficha, ficha.hObjetivo, 0, MaxDouble, a, i);
  addCampo(rsVariacionDeCostoVariableDelAguaParaControlDeCota, rsVariacCVAguaPControlCota,
    rsUUSDPorHm3, ficha, ficha.delta_cva_ParaControlDeCota, a, i);
  addCampo(rsCostoVariableValorizadoManual, rsCVValManual, rsUUSDPorMWh, ficha,
    ficha.cv_USD_Hm3_ValorizadoManual, a, i);
  addCampo(rsControlDeCrecidaCotaDeInicio, rsControlCrecidaCotaIni, rsUm, ficha,
    ficha.cotaControlCrecida_Inicio, 0, MaxDouble, a, i);
  addCampo(rsControlDeCrecidaCotaDeErogadoAPleno, rsControlCrecidaCotaErogadoPleno, rsUm,
    ficha, ficha.cotaControlCrecida_Pleno, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaximaDeBombeo, rsPMaxBombeo, rsUMW, ficha, ficha.PMaxBombeo, 0,
    MaxDouble, a, i);
  addCampo(rsCaudalMaximoDeBombeo, rsQMaxBombeo, rsUm3Pors, ficha, ficha.QMaxBombeo, 0,
    MaxDouble, a, i);
  addCampo(rsRendimientoDeBombeo, rsRendBombeo, rsUpu, ficha, ficha.renBombeo, 0, 1, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaHidroConBombeo,
      camposFichaHidroConBombeo));
  ficha.Free;
end;

procedure liberarCamposTHidroConBombeo;
begin
  listaCamposDeClases.quitarClase(THidroConBombeo, True);
  listaCamposDeClases.quitarClase(TFichaHidroConBombeo, True);
end;

initialization

crearCamposTHidroConBombeo;

finalization

liberarCamposTHidroConBombeo;

end.
