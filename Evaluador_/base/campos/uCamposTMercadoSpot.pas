unit uCamposTMercadoSpot;

interface

uses
  uCampo, uMercadoSpot, uFechas, Math, urscampos;

procedure crearCamposTMercadoSpot;
procedure liberarCamposTMercadoSpot;

var
  camposMercadoSpot, camposFichaMercadoSpot: TDAOfTCampo;

implementation

procedure crearCamposTMercadoSpot;
var
  actor: TMercadoSpot;
  ficha: TFichaMercadoSpot;
  a: TDAOfTCampo;
  i: Integer;
begin
  actor := TMercadoSpot.Create('aux', TFecha.Create_Dt(0), TFecha.Create_Dt(0), NIL, NIL, NIL,
    NIL, '');

  SetLength(camposMercadoSpot, 1);
  a := camposMercadoSpot;
  i := 0;

  addCampo(rsNombre, rsNombre, rsVacio, actor, actor.nombre, a, i);
  listaCamposDeClases.Add(TParClaseCampos.Create(TMercadoSpot, camposMercadoSpot));
  actor.Free;

  {
    //Faltan

    //Estan
    Pmin, Pmax : NReal;
    fdisp: NReal;
    }

  // To Do
  ficha := TFichaMercadoSpot.Create(TFecha.Create_Dt(0), NIL, 0, 0, 0);
  SetLength(camposFichaMercadoSpot, 4);
  a := camposFichaMercadoSpot;
  i := 0;

  addCampo(rsFecha, rsFecha, rsVacio, ficha, ficha.fecha, a, i);
  addCampo(rsPotenciaMinima, rsPMin, rsUMW, ficha, ficha.Pmin, a, i);
  addCampo(rsPotenciaMaxima, rsPMax, rsUMW, ficha, ficha.Pmax, 0, MaxDouble, a, i);
  addCampo(rsCoeficienteDeDisponibildadFortuita, rsDisp, rsUpu, ficha, ficha.fdisp, 0, 1, a,
    i);

  listaCamposDeClases.Add(TParClaseCampos.Create(TFichaMercadoSpot, camposFichaMercadoSpot));
  ficha.Free;
end;

procedure liberarCamposTMercadoSpot;
begin
  listaCamposDeClases.quitarClase(TMercadoSpot, True);
  listaCamposDeClases.quitarClase(TFichaMercadoSpot, True);
end;

initialization

crearCamposTMercadoSpot;

finalization

liberarCamposTMercadoSpot;

end.
