unit uCamposTGTerBasico_TRep;

interface

uses
  uCampo, ugter_basico_trep, uFechas, Math, urscampos;

procedure crearCamposTGTer_basico_TRep;
procedure liberarCamposTGTer_basico_TRep;

var
  camposGTer_basico_TRep, camposFichaGTer_basico_TRep: TDAOfTCampo;

implementation

procedure crearCamposTGTer_basico_TRep;
var
  actor: TGTer_Basico_TRep;
  ficha: TFichaGTer_Basico_TRep;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_Basico_TRep.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL, NIL,
    NIL, 0);

  SetLength(camposGTer_basico_TRep, 2);
  a := camposGTer_basico_TRep;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  addCampo(rsMaquinasDisponiblesAlInicio, rsMaqsDispInicio, rsVacio, actor,
    actor.estadoInicial, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_Basico_TRep, camposGTer_basico_TRep));
  actor.Free;

  {
    PMax: NReal; // [MW] Potencia Máxima Por maquina
    cv: NReal; // Costo:= cv* P
    indicePreciosPorCombustible: TFuenteAleatoria;
    bornePreciosPorCombustible: String; nroBornePreciosPorCombustible: Integer;
    disp: NReal; //Probabilidad de estar en el estado disponible
    HayRestriccionEmaxPasoDeTiempo: boolean; // indica si se aplica la restricción
    EmaxPasoDeTiempo: NReal; // Energía maxima generable en un paso de tiempo

    tRepHoras: NReal;   //tiempo promedio de reparación en horas
    }
  ficha := TFichaGTer_Basico_TRep.Create(TFecha.Create_Dt(0), NIL, 0, 0, NIL, '', 0, false, 0,
    0);
  SetLength(camposFichaGTer_basico_TRep, 7);
  a := camposFichaGTer_basico_TRep;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsCostoVariable, rsCV, rsUUSDPorMWh, ficha, ficha.cv, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaxima, rsPMax, rsUMW, ficha, ficha.PMax, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUPU, ficha, ficha.disp, 0, 1, a, i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxInt, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_Basico_TRep,
      camposFichaGTer_basico_TRep));
  ficha.Free;
end;

procedure liberarCamposTGTer_basico_TRep;
begin
  listaCamposDeClases.quitarClase(TGTer_Basico_TRep, True);
  listaCamposDeClases.quitarClase(TFichaGTer_Basico_TRep, True);
end;

initialization

crearCamposTGTer_basico_TRep;

finalization

liberarCamposTGTer_basico_TRep;

end.
