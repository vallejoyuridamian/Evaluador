unit utablafichaslpd;
interface
uses
  uvisordetabla, ufichaslpd;

type
  TListadoFichasMultiplicadores = class ( TTabla )
    public
      lpd: TFichasLPD;
      constructor Create(AOwner: TComponent; Name: string); reintroduce;
      procedure Borrar_OnClick( nidRec: string; kFila: integer ); override;
      procedure Editar_OnClick( nidRec: string; kFila: integer ); override;
      procedure Clonar_OnClick( nidRec: string; kFila: integer ); override;
      procedure Populate;
  end;

implementation



constructor TListadoFichasMultiplicadores.Create(AOwner: TComponent; Name: string);
begin
  inherited Create(AOwner, Name, 4, 1, 0);
end;

procedure TListadoFichasMultiplicadores.Borrar_OnClick( nidRec: string; kFila: integer );
begin
  if eliminar_Usuario( nidRec ) then Populate;

end;

procedure TListadoFichasMultiplicadores.Populate;
var
  k: Integer;
  r: TDataRecord;
  snid: string;
  ds: TResultadoQuery;
begin
  ds:= TResultadoQuery.CreateQuery('SELECT nid, email, tipo FROM usuarios_adme');
  if ds = nil then
    raise Exception.Create( uros.ultimoError );

  ClearRedim( ds.nrows + 1, ds.nfields );
  // fila encabezado
  wrTexto('', 0, 0, 'Email');
  wrTexto('', 0, 1, 'Tipo');

  AlinearCelda(0, 0, CAH_Izquierda, CAV_Centro );
  AlinearCelda(0, 1, CAH_Izquierda, CAV_Centro );

  Self.SetBgColorFila(0, clFondoFixedCells );
  Self.SetFontColorFila( 0, clFontFixedCells );

  k:= 1;
  r:= ds.first;
  while not ds.eof do
  begin
    snid:= r.GetByIdAsString(0);
    wrTexto('', k, 0, r.GetByNameAsString('email'));
    wrTexto('', k, 1, r.GetByNameAsString('tipo'));
    AlinearCelda(k, 0, CAH_Izquierda, CAV_Centro );
    AlinearCelda(k, 1, CAH_Izquierda, CAV_Centro );

    // ahora la botonera en la última columna
    wrBotonera( snid, k, 2,
                [ iid_Editar, iid_borrar],
                [hintPorDefecto(iid_Editar), hintPorDefecto(iid_Borrar)]);

    if (k mod 2) = 0 then
      SetBgColorFila(k, clFondoFilaPar )
    else
      SetBgColorFila(k, clFondoFilaImpar );

    inc( k );
    r:= ds.next;
  end;
  reposicionar;
end;




end.
