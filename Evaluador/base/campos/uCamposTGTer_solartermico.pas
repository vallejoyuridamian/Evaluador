unit uCamposTGTer_solartermico;

interface

uses
  uCampo, ugter_solartermico, uFechas, Math, urscampos;

procedure crearCamposTGTer_solartermico;
procedure liberarCamposTGTer_solartermico;

var
  camposGTer_solartermico, camposFichaGTer_solartermico: TDAOfTCampo;

implementation

procedure crearCamposTGTer_solartermico;
var
  actor: TGTer_solartermico;
  ficha: TFichaGTer_solartermico;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_solartermico.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL,
    NIL, NIL);

  SetLength(camposGTer_solartermico, 1);
  a := camposGTer_solartermico;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_solartermico, camposGTer_solartermico));
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
  ficha := TFichaGTer_Osolartermico.Create(TFecha.Create_Dt(0), NIL, 0, 0, 0, 0, NIL, '', 0, 0,
    false, 0);
  SetLength(camposFichaGTer_solartermico, 9);
  a := camposFichaGTer_solartermico;
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

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_solartermico,
      camposFichaGTer_solartermico));
  ficha.Free;
end;

procedure liberarCamposTGTer_solartermico;
begin
  listaCamposDeClases.quitarClase(TGTer_solartermico, True);
  listaCamposDeClases.quitarClase(TFichaGTer_solartermico, True);
end;

initialization

crearCamposTGTer_solartermico;

finalization

liberarCamposTGTer_solartermico;

end.
