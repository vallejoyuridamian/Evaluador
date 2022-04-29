unit uCamposTHidroDePasada;

interface

uses
  uCampo, uHidroDePasada, uFechas, Math, urscampos;

procedure crearCamposTHidroDePasada;
procedure liberarCamposTHidroDePasada;

var
  camposHidroDePasada, camposFichaHidroDePasada: TDAOfTCampo;

implementation

procedure crearCamposTHidroDePasada;
var
  actor: THidroDePasada;
  ficha: TFichaHidroDePasada;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := THidroDePasada.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL, NIL,
    NIL, NIL, '');

  SetLength(camposHidroDePasada, 1);
  a := camposHidroDePasada;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(THidroDePasada, camposHidroDePasada));
  actor.Free;

  {
    //Faltan
    centralesAguasArriba : TListaCentralesAguasArriba;
    central_lagoDescarga: TGeneradorHidraulico;

    //Estan
    SaltoMinimoOperativo: NReal; // salto mínimo para funcionamiento de las turbinas
    hDescarga: NReal; //[m] cota de la descarga para cálculo del salto
    hToma: NReal; //[m] cota de la toma, la alutra efectiva sera hToma - hDescarga
    ren: NReal; //[pu]= 0.95; // rendimiento complexivo de turbina y generador
    Pmax_Gen: NReal; //[MW]= 240; // Potencia maxima hidraulica
    Qmax_Turb: NReal; //[m3/s]
    fDispo: NReal; //[pu]  factor de disponibilidad fortuito
    tRepHoras: NReal;
    caQE: NReal;
    cbQE: NReal;
    cv_agua_USD_Hm3: NReal; // valor del agua en USD/Hm3
    HayRestriccionEmaxPasoDeTiempo: boolean; // indica si se aplica la restricción
    EmaxPasoDeTiempo: NReal; // Energía maxima generable en un paso de tiempo
    }

  // To Do
  ficha := TFichaHidroDePasada.Create(TFecha.Create_Dt(0), NIL, 0, 0, 0, NIL, NIL, 0, 0, 0, 0,
    0, 0, 0, 0, false, 0);
  SetLength(camposFichaHidroDePasada, 14);
  a := camposFichaHidroDePasada;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsSaltoMinimoOperativo, rsSaltoMinOp, rsUm, ficha, ficha.saltoMinimoOperativo, 0,
    MaxDouble, a, i);
  addCampo(rsCotaDeDescarga, rsCotaDescarga, rsUm, ficha, ficha.hDescarga, 0, MaxDouble, a, i);
  addCampo(rsCotaDeToma, rsCotaToma, rsUm, ficha, ficha.hToma, 0, MaxDouble, a, i);
  addCampo(rsRendimiento, rsRend, rsUpu, ficha, ficha.ren, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaximaGenerable, rsPMaxGen, rsUMW, ficha, ficha.Pmax_Gen, 0, MaxDouble,
    a, i);
  addCampo(rsCaudalMaximoTurbinable, rsQMaxTurb, rsUm3Pors, ficha, ficha.Qmax_Turb, 0,
    MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUpu, ficha, ficha.fDispo, 0, 1, a,
    i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUhoras, ficha, ficha.tRepHoras, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeAfectacionDelSaltoPorCaudalErogadoCAQE, rsCAQE, rsVacio, ficha,
    ficha.caQE, a, i);
  addCampo(rsCoeficienteDeAfectacionDelSaltoPorCaudalErogadoCBQE, rsCBQE, rsVacio, ficha,
    ficha.cbQE, a, i);
  addCampo(rsCostoVariableDelAgua, rsCVAgua, rsUUSDPorHm3, ficha, ficha.cv_agua_USD_Hm3, a, i);
  addCampo(rsHayRestriccionEmaxPorPasoDeTiempoQ, rsRestrEmaxPasoTQ, rsVacio, ficha,
    ficha.HayRestriccionEmaxPasoDeTiempo, a, i);
  addCampo(rsEnergiaMaximaPorPasoDeTiempo, rsEmaxPasoT, rsUMWh, ficha, ficha.EmaxPasoDeTiempo,
    0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaHidroDePasada,
      camposFichaHidroDePasada));
  ficha.Free;
end;

procedure liberarCamposTHidroDePasada;
begin
  listaCamposDeClases.quitarClase(THidroDePasada, True);
  listaCamposDeClases.quitarClase(TFichaHidroDePasada, True);
end;

initialization

crearCamposTHidroDePasada;

finalization

liberarCamposTHidroDePasada;

end.
