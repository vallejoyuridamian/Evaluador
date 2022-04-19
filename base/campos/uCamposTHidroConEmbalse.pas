unit uCamposTHidroConEmbalse;

interface

uses
  uCampo, uHidroConEmbalse, uFechas, Math, urscampos;

procedure crearCamposTHidroConEmbalse;
procedure liberarCamposTHidroConEmbalse;

var
  camposHidroConEmbalse, camposFichaHidroConEmbalse: TDAOfTCampo;

implementation

procedure crearCamposTHidroConEmbalse;
var
  actor: THidroConEmbalse;
  ficha: TFichaHidroConEmbalse;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := THidroConEmbalse.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL, NIL,
    NIL, 0, 0, NIL, '', false);

  SetLength(camposHidroConEmbalse, 3);
  a := camposHidroConEmbalse;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  addCampo(rsAlturaInicial, rsHIni, rsUm, actor, actor.hini, a, i);
  addCampo(rsNumeroDePuntosDeDiscretizacionDeLaAltura, rsNPuntosDicsH, rsVacio, actor,
    actor.NDisc, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(THidroConEmbalse, camposHidroConEmbalse));
  actor.Free;

  {
    //Faltan
    PuntosCotaVolumen_h: TDAOfNReal;
    PuntosCotaVolumen_V: TDAOfNReal;

    centralesAguasArriba : TListaCentralesAguasArriba;
    central_lagoDescarga: TGeneradorHidraulico;

    tomarCotaDeLaFuente: boolean;
    fuenteCota: TFuenteAleatoria;
    borneCota: String;

    //Están
    hmax: NReal; //[m] cota maxima  de operación
    hmin: NReal; //[m] cota minima  de operación
    saltoMinimoOperativo: NReal; // [m] salto mínimo operativo de las turbinas
    hDescarga: NReal; //[m] cota de la descarga para cálculo del salto
    cotaMV0, cotaMV1 : NReal;
    QMV1 : NReal;
    ren: NReal;       //[pu] rendimiento complexivo de turbina y generador
    Pmax_Gen: NReal;  //[MW] Potencia maxima hidraulica
    Qmax_Turb: NReal; //[m3/s]
    fDispo: NReal;    //[pu] factor de disponibilidad fortuita
    tRepHoras: NReal;
    caQE: NReal;
    cbQE: NReal;
    filtracion_Ca: NReal; //[m3/s]
    filtracion_Cb: NReal; //[m2/s]
    QaMuySeco: NReal; //[m3/s]
    HayRestriccionEmaxPasoDeTiempo: boolean; // indica si se aplica la restricción
    EmaxPasoDeTiempo: NReal; // Energía maxima generable en un paso de tiempo
    HayRestriccionQTmin: boolean; // indica si se aplica la restricción
    QTmin: NReal; // caudal mínimo para asegurar navegabilidad
    ImponerQminPorPoste: boolean;
    flg_controlCotaObjetivoInferior: boolean;
    flg_controlCotaObjetivoSuperior: boolean;
    hObjetivo: NReal; // [m] cota objetivo
    delta_cva_ParaControlDeCota: NReal; // USD/Hm3 aplicable para control de cota
    cv_USD_Hm3_ValorizadoManual: NReal;
    cotaControlCrecida_Inicio: NReal; //Altura a la cual se activa el control de crecida en m
    cotaControlCrecida_Pleno: NReal;  //a esta altura se tiene ErogadoMínimo = maximo del vertedero
    }

  // To Do
  ficha := TFichaHidroConEmbalse.Create(TFecha.Create_Dt(0), NIL, 0, 0, NIL, NIL, 0, NIL, NIL,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, false, 0, false, 0, false, false, false, 0, 0, 0,
    false, NIL, '', 0, 0, 0);
  SetLength(camposFichaHidroConEmbalse, 30);
  a := camposFichaHidroConEmbalse;
  i := 0;

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
  addCampo(rsTiempoDeReparacion, rsTrep, rsUhoras, ficha, ficha.tRepHoras, 0, MaxDouble, a, i);
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

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaHidroConEmbalse,
      camposFichaHidroConEmbalse));
  ficha.Free;
end;

procedure liberarCamposTHidroConEmbalse;
begin
  listaCamposDeClases.quitarClase(THidroConEmbalse, True);
  listaCamposDeClases.quitarClase(TFichaHidroConEmbalse, True);
end;

initialization

crearCamposTHidroConEmbalse;

finalization

liberarCamposTHidroConEmbalse;

end.
