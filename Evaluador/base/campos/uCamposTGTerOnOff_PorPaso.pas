unit uCamposTGTerOnOff_PorPaso;

interface

uses
  uCampo, ugter_onoffporpaso, uFechas, Math, urscampos;

procedure crearCamposTGTer_OnOffPorPaso;
procedure liberarCamposTGTer_OnOffPorPaso;

var
  camposGTer_OnOffPorPaso, camposFichaGTer_OnOffPorPaso: TDAOfTCampo;

implementation

procedure crearCamposTGTer_OnOffPorPaso;
var
  actor: TGTer_OnOffPorPaso;
  ficha: TFichaGTer_OnOffPorPaso;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_OnOffPorPaso.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL,
    NIL, NIL);

  SetLength(camposGTer_OnOffPorPaso, 1);
  a := camposGTer_OnOffPorPaso;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_OnOffPorPaso, camposGTer_OnOffPorPaso));
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
    }
  ficha := TFichaGTer_OnOffPorPaso.Create(TFecha.Create_Dt(0), NIL, 0, 0, 0, 0, NIL, '', 0, 0,
    false, 0);
  SetLength(camposFichaGTer_OnOffPorPaso, 9);
  a := camposFichaGTer_OnOffPorPaso;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsCostoVariableEnElMinimoTecnico, rsCVmin, rsUUSDPorMWh, ficha, ficha.cv_min, 0,
    MaxDouble, a, i);
  addCampo(rsCostoVariable, rsCV, rsUUSDPorMWh, ficha, ficha.cv, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMinima, rsPMin, rsUMW, ficha, ficha.PMin, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaxima, rsPMax, rsUMW, ficha, ficha.PMax, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUPU, ficha, ficha.disp, 0, 1, a, i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxInt, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_OnOffPorPaso,
      camposFichaGTer_OnOffPorPaso));
  ficha.Free;
end;

procedure liberarCamposTGTer_OnOffPorPaso;
begin
  listaCamposDeClases.quitarClase(TGTer_OnOffPorPaso, True);
  listaCamposDeClases.quitarClase(TFichaGTer_OnOffPorPaso, True);
end;

initialization

crearCamposTGTer_OnOffPorPaso;

finalization

liberarCamposTGTer_OnOffPorPaso;

end.
