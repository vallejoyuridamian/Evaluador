unit uCamposTGTerBasico;

interface

uses
  uCampo, ugter_basico, uFechas, Math, urscampos;

procedure crearCamposTGTer_basico;
procedure liberarCamposTGTer_basico;

var
  camposGTer_basico, camposFichaGTer_basico: TDAOfTCampo;

implementation

procedure crearCamposTGTer_basico;
var
  actor: TGTer_Basico;
  ficha: TFichaGTer_Basico;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_Basico.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL, NIL, NIL);

  SetLength(camposGTer_basico, 1);
  a := camposGTer_basico;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_Basico, camposGTer_basico));
  actor.Free;

  {
    cv: NReal; // Costo:= cv* P
    PMax: NReal; // [MW] Potencia Máxima Por maquina
    disp: NReal; // disponibilidad (fortuita)
    tRepHoras: NReal;

    PagoPorPotencia: NReal; // [USD/MWh] Pago por Potencia
    PagoPorEnergia: NReal; // [USD/MWh] Pago por Potencia
    HayRestriccionEmaxPasoDeTiempo: boolean; // indica si se aplica la restricción
    EmaxPasoDeTiempo: NReal; // Energía maxima generable en un paso de tiempo
    indicePreciosPorCombustible: TFuenteAleatoria;
    bornePreciosPorCombustible: String; nroBornePreciosPorCombustible: Integer;
    }
  ficha := TFichaGTer_Basico.Create(TFecha.Create_Dt(0), NIL, 0, 0, NIL, '', 0, 0, false, 0,
    0, 0);
  SetLength(camposFichaGTer_basico, 9);
  a := camposFichaGTer_basico;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsCostoVariable, rsCV, rsUUSDPorMWh, ficha, ficha.cv, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaxima, rsPMax, rsUMW, ficha, ficha.PMax, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUPU, ficha, ficha.disp, 0, 1, a, i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxDouble, a, i);
  addCampo(rsPagoPorPotencia, rsPagoPot, rsUUSDPorMWh, ficha, ficha.PagoPorPotencia, 0,
    MaxDouble, a, i);
  addCampo(rsPagoPorEnergia, rsPagoEnerg, rsUUSDPorMWh, ficha, ficha.PagoPorEnergia, 0,
    MaxDouble, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_Basico, camposFichaGTer_basico));
  ficha.Free;
end;

procedure liberarCamposTGTer_basico;
begin
  listaCamposDeClases.quitarClase(TGTer_Basico, True);
  listaCamposDeClases.quitarClase(TFichaGTer_Basico, True);
end;

initialization

crearCamposTGTer_basico;

finalization

liberarCamposTGTer_basico;

end.
