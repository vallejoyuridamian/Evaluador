unit uCamposTGTerOnOff_PorPasoV2;

interface

uses
  uCampos,
  ugter_onoffporpasoV2, uFechas, Math, urscampos;

procedure crearCamposTGTer_OnOffPorPasoV2;
procedure liberarCamposTGTer_OnOffPorPasoV2;

var
  camposGTer_OnOffPorPasoV2, camposFichaGTer_OnOffPorPasoV2: TDAOfTCampo;

implementation

procedure crearCamposTGTer_OnOffPorPasoV2;
var
  actor: TGTer_OnOffPorPasoV2;
  ficha: TFichaGTer_OnOffPorPasoV2;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_OnOffPorPasoV2.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL,
    NIL, NIL);

  SetLength(camposGTer_OnOffPorPasoV2, 1);
  a := camposGTer_OnOffPorPasoV2;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_OnOffPorPasoV2, camposGTer_OnOffPorPasoV2));
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
  ficha := TFichaGTer_OnOffPorPasoV2.Create(TFecha.Create_Dt(0), NIL, 0, 0, NIL, '', 0, 0,
    false, 0);
  SetLength(camposFichaGTer_OnOffPorPasoV2, 7);
  a := camposFichaGTer_OnOffPorPasoV2;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsPotenciaMinima, rsPMin, rsUMW, ficha, ficha.PMin, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaxima, rsPMax, rsUMW, ficha, ficha.PMax, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUPU, ficha, ficha.disp, 0, 1, a, i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxInt, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_OnOffPorPasoV2,
      camposFichaGTer_OnOffPorPasoV2));
  ficha.Free;
end;

procedure liberarCamposTGTer_OnOffPorPasoV2;
begin
  listaCamposDeClases.quitarClase(TGTer_OnOffPorPasoV2, True);
  listaCamposDeClases.quitarClase(TFichaGTer_OnOffPorPasoV2, True);
end;

initialization

crearCamposTGTer_OnOffPorPasoV2;

finalization

liberarCamposTGTer_OnOffPorPasoV2;

end.
