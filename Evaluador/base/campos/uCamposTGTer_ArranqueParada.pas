unit uCamposTGTer_ArranqueParada;

interface

uses
  uCampo, ugter_arranqueparada, uFechas, Math, urscampos;

procedure crearCamposTGTer_ArranqueParada;
procedure liberarCamposTGTer_ArranqueParada;

var
  camposGTer_ArranqueParada, camposFichaGTer_ArranqueParada: TDAOfTCampo;

implementation

procedure crearCamposTGTer_ArranqueParada;
var
  actor: TGTer_ArranqueParada;
  ficha: TFichaGTer_ArranqueParada;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_ArranqueParada.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL,
    NIL, NIL, false, TFecha.Create_Dt(0) );

  SetLength(camposGTer_ArranqueParada, 2);
  a := camposGTer_ArranqueParada;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  addCampo(rsEncendidoAlInicioQ, rsEncendidoIniQ, rsVacio, actor, actor.encendidoAlInicio, a,
    i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_ArranqueParada,
      camposGTer_ArranqueParada));
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
  ficha := TFichaGTer_ArranqueParada.Create(TFecha.Create_Dt(0), NIL, 0, 0, 0, 0, NIL, '', 0,
    0, 0, 0, false, 0, 0, 0, 30E6 );

  SetLength(camposFichaGTer_ArranqueParada, 14);
  a := camposFichaGTer_ArranqueParada;
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

  addCampo( rsMinHorasON, rsMinHorasON, rsUhoras, ficha, ficha.MinHorasON, -8760*1000, 8760*1000, a, i );
  addCampo( rsMinHorasOFF, rsMinHorasOFF, rsUhoras, ficha, ficha.MinHorasOFF, -8760*1000, 8760*1000, a, i );
  addCampo( rsMinHorasOFF, rsPenalidadONOFF, rsUUSD, ficha, ficha.PenalidadONOFF, 0.0, 1000E6, a, i );


  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_ArranqueParada,
      camposFichaGTer_ArranqueParada));
  ficha.Free;
end;

procedure liberarCamposTGTer_ArranqueParada;
begin
  listaCamposDeClases.quitarClase(TGTer_ArranqueParada, True);
  listaCamposDeClases.quitarClase(TFichaGTer_ArranqueParada, True);
end;

initialization

crearCamposTGTer_ArranqueParada;

finalization

liberarCamposTGTer_ArranqueParada;

end.
