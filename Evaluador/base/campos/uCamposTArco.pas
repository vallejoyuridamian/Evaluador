unit uCamposTArco;

interface

uses
  uCampo, uArcos, uFechas, Math, urscampos;

procedure crearCamposTArco;
procedure liberarCamposTArco;

var
  camposArco, camposFichaArco: TDAOfTCampo;

implementation

procedure crearCamposTArco;
var
  actor: TArco;
  ficha: TFichaArco;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TArco.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL, NIL, NIL, NIL);

  SetLength(camposArco, 1);
  a := camposArco;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TArco, camposArco));
  actor.Free;

  ficha := TFichaArco.Create(TFecha.Create_Dt(0), NIL, 0, 0, 0, 0, 0);
  SetLength(camposFichaArco, 6);
  a := camposFichaArco;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsPeaje, rsPeaje, rsUUSDPorMWh, ficha, ficha.peaje, 0, MaxDouble, a, i);
  addCampo(rsPotenciaMaxima, rsPMax, rsUMW, ficha, ficha.PMax, 0, MaxDouble, a, i);
  addCampo(rsRendimiento, rsRend, rsUPU, ficha, ficha.rendimiento, 0, 1, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUPU, ficha, ficha.fd, 0, 1,
    a, i);
  addCampo(rsTiempoDeReparacion, rsTrep, rsUHoras, ficha, ficha.tRepHoras, 0, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaArco, camposFichaArco));
  ficha.Free;
end;

procedure liberarCamposTArco;
begin
  listaCamposDeClases.quitarClase(TArco, True);
  listaCamposDeClases.quitarClase(TFichaArco, True);
end;

initialization

crearCamposTArco;

finalization

liberarCamposTArco;

end.
