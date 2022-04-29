unit uCamposTGTer_ArranqueParadaV2;

interface

uses
  uCampo, ugter_arranqueparadaV2, uFechas, Math, urscampos;

procedure crearCamposTGTer_ArranqueParadaV2;
procedure liberarCamposTGTer_ArranqueParadaV2;

var
  camposGTer_ArranqueParadaV2, camposFichaGTer_ArranqueParadaV2: TDAOfTCampo;

implementation

procedure crearCamposTGTer_ArranqueParadaV2;
var
  actor: TGTer_ArranqueParadaV2;
  ficha: TFichaGTer_ArranqueParadaV2;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_ArranqueParadaV2.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL,
    NIL, NIL, false, TFecha.Create_Dt(0) );

  SetLength(camposGTer_ArranqueParadaV2, 2);
  a := camposGTer_ArranqueParadaV2;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  addCampo(rsEncendidoAlInicioQ, rsEncendidoIniQ, rsVacio, actor, actor.encendidoAlInicio, a,
    i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_ArranqueParadaV2,
      camposGTer_ArranqueParadaV2));
  actor.Free;

  ficha := TFichaGTer_ArranqueParadaV2.Create(TFecha.Create_Dt(0), NIL, 0, 0, NIL, '', 0,
    0, 0, 0, false, 0, 0, 0, 30E6 );

  SetLength(camposFichaGTer_ArranqueParadaV2, 12);
  a := camposFichaGTer_ArranqueParadaV2;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
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


  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_ArranqueParadaV2,
      camposFichaGTer_ArranqueParadaV2));
  ficha.Free;
end;

procedure liberarCamposTGTer_ArranqueParadaV2;
begin
  listaCamposDeClases.quitarClase(TGTer_ArranqueParadaV2, True);
  listaCamposDeClases.quitarClase(TFichaGTer_ArranqueParadaV2, True);
end;

initialization

crearCamposTGTer_ArranqueParadaV2;

finalization

liberarCamposTGTer_ArranqueParadaV2;

end.
