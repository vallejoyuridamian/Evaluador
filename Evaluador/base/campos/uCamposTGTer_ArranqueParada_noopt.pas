unit uCamposTGTer_ArranqueParada_noopt;

interface

uses
  uCampo, ugter_arranqueparada_noopt, uFechas, Math, urscampos;

procedure crearCamposTGTer_ArranqueParada_noopt;
procedure liberarCamposTGTer_ArranqueParada_noopt;

var
  camposGTer_ArranqueParada_noopt, camposFichaGTer_ArranqueParada_noopt: TDAOfTCampo;

implementation

procedure crearCamposTGTer_ArranqueParada_noopt;
var
  actor: TGTer_ArranqueParada_noopt;
  ficha: TFichaGTer_ArranqueParada_noopt;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_ArranqueParada_noopt.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0),
    NIL, NIL, false);

  SetLength(camposGTer_ArranqueParada_noopt, 2);
  a := camposGTer_ArranqueParada_noopt;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  addCampo(rsEncendidoAlInicioQ, rsEncendidoIniQ, rsVacio, actor, actor.encendidoAlInicio, a,
    i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_ArranqueParada_noopt,
      camposGTer_ArranqueParada_noopt));
  actor.Free;

  {
    cv_min, cv: NReal; // Costo:= cv_min* Pmin+ cv* (P-Pmin)
    PMin, PMax: NReal; // [MW] Potencias Mínima y Máxima Por maquina
    disp: NReal; // disponibilidad (fortuita)
    tRepHoras: NReal;
    costo_arranque, costo_parada : NReal;
    HayRestriccionEmaxPasoDeTiempo: boolean; // indica si se aplica la restricción
    EmaxPasoDeTiempo: NReal; // Energía maxima generable en un paso de tiempo

    indicePreciosPorCombustible: TFuenteAleatoria;
    bornePreciosPorCombustible: String; nroBornePreciosPorCombustible: Integer;
    }
  ficha := TFichaGTer_ArranqueParada_noopt.Create(TFecha.Create_Dt(0), NIL, 0, 0, 0, 0, NIL,
    '', 0, 0, 0, 0, false, 0);

  SetLength(camposFichaGTer_ArranqueParada_noopt, 11);
  a := camposFichaGTer_ArranqueParada_noopt;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsCostoVariableEnElMinimoTecnico, rsCVmin, rsUUSDPorMWh, ficha, ficha.cv_min, 0,
    MaxDouble, a, i);
  addCampo(rsCostoVariable, rsCV, rsUUSDPorMWh, ficha, ficha.cv, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMinima, rsPMin, rsUMW, ficha, ficha.PMin, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaxima, rsPMax, rsUMW, ficha, ficha.PMax, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUPU, ficha, ficha.disp, 0, 1, a, i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxInt, a, i);
  addCampo(rsCostoDeArranque, rsCArranque, rsUUSD, ficha, ficha.costo_arranque, 0, MaxDouble,
    a, i);
  addCampo(rsCostoDeParada, rsCParada, rsUUSD, ficha, ficha.costo_parada, 0, MaxDouble, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_ArranqueParada_noopt,
      camposFichaGTer_ArranqueParada_noopt));
  ficha.Free;
end;

procedure liberarCamposTGTer_ArranqueParada_noopt;
begin
  listaCamposDeClases.quitarClase(TGTer_ArranqueParada_noopt, True);
  listaCamposDeClases.quitarClase(TFichaGTer_ArranqueParada_noopt, True);
end;

initialization

crearCamposTGTer_ArranqueParada_noopt;

finalization

liberarCamposTGTer_ArranqueParada_noopt;

end.
