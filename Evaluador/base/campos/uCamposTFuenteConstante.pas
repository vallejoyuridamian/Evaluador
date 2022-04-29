unit uCamposTFuenteConstante;

interface

uses
  uCampo, uFuenteConstante, uFechas, Math, urscampos;

procedure crearCamposTFuenteConstante;
procedure liberarCamposTFuenteConstante;

var
  camposFuenteConstante, camposFichaFuenteConstante: TDAOfTCampo;

implementation

procedure crearCamposTFuenteConstante;
var
  actor: TFuenteConstante;
  ficha: TFichaFuenteConstante;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TFuenteConstante.Create('aux', 0, False, NIL);

  SetLength(camposFuenteConstante, 1);
  a := camposFuenteConstante;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TFuenteConstante, camposFuenteConstante));
  actor.Free;

  ficha := TFichaFuenteConstante.Create(TFecha.Create_Dt(0), NIL, 0);
  SetLength(camposFichaFuenteConstante, 6);
  a := camposFichaFuenteConstante;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsValor, rsValor, rsVacio, ficha, ficha.valor, -MaxDouble, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaFuenteConstante,
      camposFichaFuenteConstante));
  ficha.Free;
end;

procedure liberarCamposTFuenteConstante;
begin
  listaCamposDeClases.quitarClase(TFuenteConstante, True);
  listaCamposDeClases.quitarClase(TFichaFuenteConstante, True);
end;

initialization

crearCamposTFuenteConstante;

finalization

liberarCamposTFuenteConstante;

end.
