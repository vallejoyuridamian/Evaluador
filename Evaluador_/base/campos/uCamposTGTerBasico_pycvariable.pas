unit uCamposTGTerBasico_pycvariable;

interface

uses
  uCampo, ugter_basico_pycvariable, uFechas, Math, urscampos;

procedure crearCamposTGTer_basico_PyCVariable;
procedure liberarCamposTGTer_basico_PyCVariable;

var
  camposGTer_basico_PyCVariable, camposFichaGTer_basico_PyCVariable: TDAOfTCampo;

implementation

procedure crearCamposTGTer_basico_PyCVariable;
var
  actor: TGTer_Basico_PyCVariable;
  ficha: TFichaGTer_Basico_PyCVariable;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TGTer_Basico_PyCVariable.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0),
    NIL, NIL, NIL);

  SetLength(camposGTer_basico_PyCVariable, 1);
  a := camposGTer_basico_PyCVariable;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TGTer_Basico_PyCVariable,
      camposGTer_basico_PyCVariable));
  actor.Free;

  {
    indicePreciosPorCombustible: TFuenteAleatoria;
    bornePreciosPorCombustible: String; nroBornePreciosPorCombustible: Integer;
    disp: NReal; //Probabilidad de estar en el estado disponible
    HayRestriccionEmaxPasoDeTiempo: boolean; // indica si se aplica la restricción
    EmaxPasoDeTiempo: NReal; // Energía maxima generable en un paso de tiempo

    tRepHoras: NReal;   //tiempo promedio de reparación en horas

    fuentesAleatoriasPotenciasPorPoste : TListaDeCosas; //Array de fuentes aleatorias de potencias
    fuentesAleatoriasCostosVariablesPorPoste : TListaDeCosas; //Array de fuentes aleatorias de costos variables
    }
  ficha := TFichaGTer_Basico_PyCVariable.Create(TFecha.Create_Dt(0), NIL, NIL, '', 0, false,
    0, 0, NIL, NIL);
  SetLength(camposFichaGTer_basico_PyCVariable, 5);
  a := camposFichaGTer_basico_PyCVariable;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUPU, ficha, ficha.disp, 0, 1, a, i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxInt, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaGTer_Basico_PyCVariable,
      camposFichaGTer_basico_PyCVariable));
  ficha.Free;
end;

procedure liberarCamposTGTer_basico_PyCVariable;
begin
  listaCamposDeClases.quitarClase(TGTer_Basico_PyCVariable, True);
  listaCamposDeClases.quitarClase(TFichaGTer_Basico_PyCVariable, True);
end;

initialization

crearCamposTGTer_basico_PyCVariable;

finalization

liberarCamposTGTer_basico_PyCVariable;

end.
