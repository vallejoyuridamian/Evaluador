unit uVisorFichasExpandidas;
{$MODE Delphi}
interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ufichasLPD, utilidades, uCosaConNombre, uConstantesSimSEE,
  usalasdejuegoParaEditor,
  usalasdejuego,
  uOpcionesSimSEEEdit, uBaseFormularios;

resourcestring
  rsFechaDeInicio = 'Fecha de Inicio';
  rsInformacioNAdicional = 'Información adicional';

type

  { TVisorFichasExpandidas }

  TVisorFichasExpandidas = class( TBaseFormularios )
    sgFichasExpandidas: TStringGrid;
    BCerrar: TButton;
    procedure BCerrarClick(Sender: TObject);
  private
    tiposColsVisor: array of TTipoColumna;
  public

    constructor Create(AOwner: TControl; sala: TSalaDeJuego; nombreCosa: string;
      lista: TFichasLPD); reintroduce; overload;
    constructor Create(AOwner: TControl; sala: TSalaDeJuego; cosaConNombre: TCosaConNombre; lista: TFichasLPD);
      reintroduce; overload;
  end;

var
  VisorFichasExpandidas: TVisorFichasExpandidas;

implementation
  {$R *.lfm}

uses
  SimSEEEditMain;

constructor TVisorFichasExpandidas.Create(AOwner: TControl;
  sala: TSalaDeJuego; nombreCosa: string; lista: TFichasLPD);
var
  i, j, cantActivas: integer;
begin
  inherited Create_conSalaYEditor_(  AOwner, sala );


  if nombreCosa <> '' then
    self.Caption := 'Visor de Fichas de ' + nombreCosa
  else
    self.Caption := 'Visor de Fichas Expandidas';
  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;
  SetLength(tiposColsVisor, sgFichasExpandidas.ColCount);
  for i := 0 to high(tiposColsVisor) do
    tiposColsVisor[i] := TC_Texto;

  lista.expandirFichas( rbtEditorSala.CatalogoReferencias, FSimSEEEdit.Sala.globs);

  cantActivas := 0;
  for i := 0 to lista.Count - 1 do
    if TFichaLPD(lista[i]).activa then
      cantActivas := cantActivas + 1;

  sgFichasExpandidas.RowCount := cantActivas + 1;
  sgFichasExpandidas.Cells[0, 0] := rsFechaDeInicio;
  sgFichasExpandidas.Cells[1, 0] := rsInformacioNAdicional;

  j := 0;
  for i := 0 to lista.Count - 1 do
  begin
    if TFichaLPD(lista[i]).activa then
    begin
      sgFichasExpandidas.Cells[0, j + 1] := TFichaLPD(lista[i]).fecha.AsStr;
      sgFichasExpandidas.Cells[1, j + 1] := TFichaLPD(lista[i]).infoAd_20;
      j := j + 1;
    end;
  end;

  for i := 0 to sgFichasExpandidas.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgFichasExpandidas, i, tiposColsVisor[i], nil);

  BCerrar.Top := sgFichasExpandidas.Top + sgFichasExpandidas.Height + 5;
  BCerrar.Left := (sgFichasExpandidas.Width - BCerrar.Width) div 2;
  lista.clearExpanded;
end;

constructor TVisorFichasExpandidas.Create(AOwner: TControl; sala: TSalaDeJuego;
  cosaConNombre: TCosaConNombre; lista: TFichasLPD);
begin
  if cosaConNombre <> nil then
    Create(AOwner, sala, cosaConNombre.nombre, lista)
  else
    Create(AOwner, sala, '', lista);
end;

procedure TVisorFichasExpandidas.BCerrarClick(Sender: TObject);
begin
  self.Close;
end;

end.
