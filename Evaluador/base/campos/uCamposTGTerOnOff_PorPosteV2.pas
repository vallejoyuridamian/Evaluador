unit uCamposTGTerOnOff_PorPosteV2;

interface

uses
  uCampo, ugter_onoffporposteV2, uFechas, Math, urscampos;

procedure crearCamposTGTer_OnOffPorPosteV2;
procedure liberarCamposTGTer_OnOffPorPosteV2;

var
  camposGTer_OnOffPorPosteV2, camposFichaGTer_OnOffPorPosteV2: TDAOfTCampo;

implementation

procedure crearCamposTGTer_OnOffPorPosteV2;
var
  actor: TGTer_OnOffPorPosteV2;
  ficha: TFichaGTer_OnOffPorPosteV2;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_OnOffPorPosteV2.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL,
    NIL, NIL);

  SetLength(camposGTer_OnOffPorPosteV2, 1);
  a := camposGTer_OnOffPorPosteV2;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_OnOffPorPosteV2,
      camposGTer_OnOffPorPosteV2));
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
  ficha := TFichaGTer_OnOffPorPosteV2.Create(TFecha.Create_Dt(0), NIL, 0, 0, NIL, '', 0,
    0, false, 0);
  SetLength(camposFichaGTer_OnOffPorPosteV2, 7);
  a := camposFichaGTer_OnOffPorPosteV2;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsPotenciaMinima, rsPMin, rsUMW, ficha, ficha.PMin, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaxima, rsPMax, rsUMW, ficha, ficha.PMax, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUPU, ficha, ficha.disp, 0, 1, a, i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxDouble, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_OnOffPorPosteV2,
      camposFichaGTer_OnOffPorPosteV2));
  ficha.Free;
end;

procedure liberarCamposTGTer_OnOffPorPosteV2;
begin
  listaCamposDeClases.quitarClase(TGTer_OnOffPorPosteV2, True);
  listaCamposDeClases.quitarClase(TFichaGTer_OnOffPorPosteV2, True);
end;

initialization

crearCamposTGTer_OnOffPorPosteV2;

finalization

liberarCamposTGTer_OnOffPorPosteV2;

end.
