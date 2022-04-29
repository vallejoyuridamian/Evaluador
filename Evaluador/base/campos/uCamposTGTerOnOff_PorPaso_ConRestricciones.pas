unit uCamposTGTerOnOff_PorPaso_ConRestricciones;

interface

uses
  uCampo, ugter_onoffporpaso_conrestricciones, uFechas, Math, urscampos;

procedure crearCamposTGTer_OnOffPorPaso_ConRestricciones;
procedure liberarCamposTGTer_OnOffPorPaso_ConRestricciones;

var
  camposGTer_OnOffPorPaso_ConRestricciones,
    camposFichaGTer_OnOffPorPaso_ConRestricciones: TDAOfTCampo;

implementation

procedure crearCamposTGTer_OnOffPorPaso_ConRestricciones;
var
  actor: TGTer_OnOffPorPaso_ConRestricciones;
  ficha: TFichaGTer_OnOffPorPaso_ConRestricciones;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_OnOffPorPaso_ConRestricciones.Create('aux', TFecha.Create_Dt(0),
    TFecha.Create_Dt(0), NIL, NIL, NIL, false, 0);

  SetLength(camposGTer_OnOffPorPaso_ConRestricciones, 1);
  a := camposGTer_OnOffPorPaso_ConRestricciones;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_OnOffPorPaso_ConRestricciones,
      camposGTer_OnOffPorPaso_ConRestricciones));
  actor.Free;

  {
    PMin, PMax: NReal; // [MW] Potencias Mínima y Máxima Por maquina
    cv_min, cv: NReal; // Costo:= cv_min* Pmin+ cv* (P-Pmin)
    indicePreciosPorCombustible: TFuenteAleatoria;
    bornePreciosPorCombustible: String; nroBornePreciosPorCombustible: Integer;
    disp: NReal; // disponibilidad (fortuita)
    tRepHoras: NReal;
    HayRestriccionEmaxPasoDeTiempo: boolean; // indica si se aplica la restricción
    EmaxPasoDeTiempo: NReal; // Energía maxima generable en un paso de tiempo

    minimoNPasosOn, minimoNPasosOff: Integer;
    decisionOnOff_PorCiclo, decisionOffOn_PorCiclo: boolean;
    costoArranque, costoParada, costoPorPasoOn, costoPorPasoOff: NReal;
    }
  ficha := TFichaGTer_OnOffPorPaso_ConRestricciones.Create(TFecha.Create_Dt(0), NIL, 0, 0, 0,
    0, NIL, '', 0, 0, false, 0, 0, 0, false, false, 0, 0, 0, 0);
  SetLength(camposFichaGTer_OnOffPorPaso_ConRestricciones, 13);
  a := camposFichaGTer_OnOffPorPaso_ConRestricciones;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsCostoVariableEnElMinimoTecnico, rsCVmin, rsUUSDPorMWh, ficha, ficha.cv_min, 0,
    MaxDouble, a, i);
  addCampo(rsCostoVariable, rsCV, rsUUSDPorMWh, ficha, ficha.cv, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMinima, rsPMin, rsUMW, ficha, ficha.PMin, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaxima, rsPMax, rsUMW, ficha, ficha.PMax, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUPU, ficha, ficha.disp, 0, 1, a, i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxDouble, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);
  addCampo(rsMinimoNumeroDePasosOn, rsMinNPasosOn, rsVacio, ficha, ficha.minimoNPasosOn, 1,
    MaxInt, a, i);
  addCampo(rsMinimoNumeroDePasosOff, rsMinNPasosOff, rsVacio, ficha, ficha.minimoNPasosOff, 1,
    MaxInt, a, i);
  addCampo(rsDecidirOnOffPorCiclosQ, rsOnOffPorCiclosQ, rsVacio, ficha,
    ficha.decisionOnOff_PorCiclo, a, i);
  addCampo(rsDecidirOffOnPorCiclosQ, rsOffOnPorCiclosQ, rsVacio, ficha,
    ficha.decisionOffOn_PorCiclo, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_OnOffPorPaso_ConRestricciones,
      camposFichaGTer_OnOffPorPaso_ConRestricciones));
  ficha.Free;
end;

procedure liberarCamposTGTer_OnOffPorPaso_ConRestricciones;
begin
  listaCamposDeClases.quitarClase(TGTer_OnOffPorPaso_ConRestricciones, True);
  listaCamposDeClases.quitarClase(TFichaGTer_OnOffPorPaso_ConRestricciones, True);
end;

initialization

crearCamposTGTer_OnOffPorPaso_ConRestricciones;

finalization

liberarCamposTGTer_OnOffPorPaso_ConRestricciones;

end.
