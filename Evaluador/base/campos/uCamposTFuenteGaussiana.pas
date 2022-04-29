unit uCamposTFuenteGaussiana;

interface

uses
  uCampo, uFuenteGaussiana, uFechas, Math, urscampos;

procedure crearCamposTFuenteGaussiana;
procedure liberarCamposTFuenteGaussiana;

var
  camposFuenteGaussiana, camposFichaFuenteGaussiana: TDAOfTCampo;

implementation

procedure crearCamposTFuenteGaussiana;
var
  actor: TFuenteGaussiana;
  ficha: TFichaFuenteGaussiana;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TFuenteGaussiana.Create('aux', 0, False, NIL);

  SetLength(camposFuenteGaussiana, 1);
  a := camposFuenteGaussiana;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TFuenteGaussiana, camposFuenteGaussiana));
  actor.Free;

  ficha := TFichaFuenteGaussiana.Create(TFecha.Create_Dt(0), NIL, 0, 0);
  SetLength(camposFichaFuenteGaussiana, 6);
  a := camposFichaFuenteGaussiana;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsValorEsperado, rsVE, rsVacio, ficha, ficha.valorEsperado, -MaxDouble, MaxDouble, a, i);
  addCampo(rsVarianza, rsVar, rsVacio, ficha, ficha.varianza, -MaxDouble, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaFuenteGaussiana,
      camposFichaFuenteGaussiana));
  ficha.Free;
end;

procedure liberarCamposTFuenteGaussiana;
begin
  listaCamposDeClases.quitarClase(TFuenteGaussiana, True);
  listaCamposDeClases.quitarClase(TFichaFuenteGaussiana, True);
end;

initialization

crearCamposTFuenteGaussiana;

finalization

liberarCamposTFuenteGaussiana;

end.
