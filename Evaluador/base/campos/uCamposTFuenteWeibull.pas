unit uCamposTFuenteWeibull;

interface

uses
  uCampo, uFuenteWeibull, uFechas, Math, urscampos;

procedure crearCamposTFuenteWeibull;
procedure liberarCamposTFuenteWeibull;

var
  camposFuenteWeibull, camposFichaFuenteWeibull: TDAOfTCampo;

implementation

procedure crearCamposTFuenteWeibull;
var
  actor: TFuenteWeibull;
  ficha: TFichaFuenteWeibull;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TFuenteWeibull.Create('aux', 0, False, NIL);

  SetLength(camposFuenteWeibull, 1);
  a := camposFuenteWeibull;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TFuenteWeibull, camposFuenteWeibull));
  actor.Free;

  ficha := TFichaFuenteWeibull.Create(TFecha.Create_Dt(0), NIL, 0, 0);
  SetLength(camposFichaFuenteWeibull, 6);
  a := camposFichaFuenteWeibull;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsValorEsperado, rsVE, rsVacio, ficha, ficha.valorEsperado, -MaxDouble, MaxDouble, a,
    i);
  addCampo(rsConstanteK, rsK, rsVacio, ficha, ficha.constanteK, -MaxDouble, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaFuenteWeibull,
      camposFichaFuenteWeibull));
  ficha.Free;
end;

procedure liberarCamposTFuenteWeibull;
begin
  listaCamposDeClases.quitarClase(TFuenteWeibull, True);
  listaCamposDeClases.quitarClase(TFichaFuenteWeibull, True);
end;

initialization

crearCamposTFuenteWeibull;

finalization

liberarCamposTFuenteWeibull;

end.
