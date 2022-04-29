unit uCamposTGTerOnOff_PorPoste;

interface

uses
  uCampo, ugter_onoffporposte, uFechas, Math, urscampos;

procedure crearCamposTGTer_OnOffPorPoste;
procedure liberarCamposTGTer_OnOffPorPoste;

var
  camposGTer_OnOffPorPoste, camposFichaGTer_OnOffPorPoste: TDAOfTCampo;

implementation

procedure crearCamposTGTer_OnOffPorPoste;
var
  actor: TGTer_OnOffPorPoste;
  ficha: TFichaGTer_OnOffPorPoste;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_OnOffPorPoste.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL,
    NIL, NIL);

  SetLength(camposGTer_OnOffPorPoste, 1);
  a := camposGTer_OnOffPorPoste;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_OnOffPorPoste,
      camposGTer_OnOffPorPoste));
  actor.Free;

  {
    PMin, PMax: NReal; // [MW] Potencias Mínima y Máxima Por maquina
    cv_min, cv: NReal; // Costo:= cv_min* Pmin+ cv* (P-Pmin)ç
    indicePreciosPorCombustible: TFuenteAleatoria;
    bornePreciosPorCombustible: String; nroBornePreciosPorCombustible: Integer;
    disp: NReal; // disponibilidad (fortuita)
    tRepHoras: NReal;
    HayRestriccionEmaxPasoDeTiempo: boolean; // indica si se aplica la restricción
    EmaxPasoDeTiempo: NReal; // Energía maxima generable en un paso de tiempo
    }
  ficha := TFichaGTer_OnOffPorPoste.Create(TFecha.Create_Dt(0), NIL, 0, 0, 0, 0, NIL, '', 0,
    0, false, 0);
  SetLength(camposFichaGTer_OnOffPorPoste, 9);
  a := camposFichaGTer_OnOffPorPoste;
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

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_OnOffPorPoste,
      camposFichaGTer_OnOffPorPoste));
  ficha.Free;
end;

procedure liberarCamposTGTer_OnOffPorPoste;
begin
  listaCamposDeClases.quitarClase(TGTer_OnOffPorPoste, True);
  listaCamposDeClases.quitarClase(TFichaGTer_OnOffPorPoste, True);
end;

initialization

crearCamposTGTer_OnOffPorPoste;

finalization

liberarCamposTGTer_OnOffPorPoste;

end.
