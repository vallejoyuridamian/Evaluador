unit uCamposTFuenteUniforme;

interface

uses
  uCampo, uFuenteUniforme, uFechas, Math, urscampos;

procedure crearCamposTFuenteUniforme;
procedure liberarCamposTFuenteUniforme;

var
  camposFuenteUniforme, camposFichaFuenteUniforme: TDAOfTCampo;

implementation

procedure crearCamposTFuenteUniforme;
var
  actor: TFuenteUniforme;
  ficha: TFichaFuenteUniforme;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TFuenteUniforme.Create('aux', 0, False, NIL);

  SetLength(camposFuenteUniforme, 1);
  a := camposFuenteUniforme;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TFuenteUniforme, camposFuenteUniforme));
  actor.Free;

  ficha := TFichaFuenteUniforme.Create(TFecha.Create_Dt(0), NIL, 0, 0);
  SetLength(camposFichaFuenteUniforme, 6);
  a := camposFichaFuenteUniforme;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsMinimo, rsMin, rsVacio, ficha, ficha.minimo, -MaxDouble, MaxDouble, a, i);
  addCampo(rsMaximo, rsMax, rsVacio, ficha, ficha.maximo, -MaxDouble, MaxDouble, a, i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaFuenteUniforme,
      camposFichaFuenteUniforme));
  ficha.Free;
end;

procedure liberarCamposTFuenteUniforme;
begin
  listaCamposDeClases.quitarClase(TFuenteUniforme, True);
  listaCamposDeClases.quitarClase(TFichaFuenteUniforme, True);
end;

initialization

crearCamposTFuenteUniforme;

finalization

liberarCamposTFuenteUniforme;

end.
