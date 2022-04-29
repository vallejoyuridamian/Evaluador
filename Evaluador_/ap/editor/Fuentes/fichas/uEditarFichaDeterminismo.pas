unit uEditarFichaDeterminismo;

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, uFuenteSintetizador, uBaseFormularios, utilidades,
  uConstantesSimSEE, xMatDefs, uverdoc, uOpcionesSimSEEEdit, uimpvnreal;

type
  TEditarFichaDeterminismo = class(TBaseFormularios)
    ENPasos: TEdit;
    sgValores: TStringGrid;
    LNPasos: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    BAyuda: TButton;
    bImportar: TButton;
    procedure EditTamTablaExit(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure ENPasosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BAyudaClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure bImportarClick(Sender: TObject);
  private
    determinismo: TFichaDeterminismo;
  protected
    procedure validarCambioTabla(tabla: TStringGrid); override;

    function validarFormulario: Boolean; override;
  public
    Constructor Create(AOwner: TComponent; nombreBorne: String; determinismo: TFichaDeterminismo); reintroduce;
    function darDeterminismo: TFichaDeterminismo;
  end;

var
  EditarFichaDeterminismo: TEditarFichaDeterminismo;

implementation

{$IFNDEF FPC}
{$R *.dfm}
{$ELSE}
{$R *.lfm}
{$ENDIF}

procedure TEditarFichaDeterminismo.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFichaDeterminismo);
end;

procedure TEditarFichaDeterminismo.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaDeterminismo.BGuardarClick(Sender: TObject);
var
  valores: TDAofNReal;
  i: Integer;
begin
  if validarFormulario then
  begin
    SetLength(valores, StrToInt(ENPasos.Text));
    for i := 0 to high(valores) do
      valores[i] := StrToFloat(trim(sgValores.Cells[i + 1, 1]));
    determinismo := TFichaDeterminismo.Create(valores);
    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaDeterminismo.bImportarClick(Sender: TObject);
var
  datos: TDAofNReal;
  i: Integer;
begin
  datos := uimpvnreal.importarDatos;
  if datos <> NIL then
  begin
    ENPasos.Text := IntToStr(length(datos));
    sgValores.ColCount := length(datos) + 1;
    for i := 0 to high(datos) do
    begin
      sgValores.Cells[i + 1, 0] := IntToStr(i + 1);
      sgValores.Cells[i + 1, 1] := FloatToStrF(datos[i], ffFixed, 12, 3);
    end;
    utilidades.AutoSizeTable(self, sgValores, maxAnchoTablaEnorme,
      maxAlturaTablaChica, false);
  end;
end;

Constructor TEditarFichaDeterminismo.Create(AOwner: TComponent;
  nombreBorne: String; determinismo: TFichaDeterminismo);
var
  i: Integer;
begin
  inherited Create(AOwner);
  self.Caption := 'Editar Valores Determinísticos del Borne ' + nombreBorne;
  ENPasos.Text := IntToStr(length(determinismo.valores));
  sgValores.ColCount := length(determinismo.valores) + 1;
  sgValores.Cells[0, 0] := 'Paso';
  sgValores.Cells[0, 1] := 'Valor';
  for i := 0 to high(determinismo.valores) do
  begin
    sgValores.Cells[i + 1, 0] := IntToStr(i + 1);
    sgValores.Cells[i + 1, 1] := FloatToStrF(determinismo.valores[i], ffFixed,
      12, 3);
  end;
  utilidades.AutoSizeTable(self, sgValores, maxAnchoTablaEnorme,
    maxAlturaTablaChica, false);
end;

function TEditarFichaDeterminismo.darDeterminismo: TFichaDeterminismo;
begin
  result := determinismo;
end;

procedure TEditarFichaDeterminismo.EditTamTablaExit(Sender: TObject);
var
  i, nAnt: Integer;
  lastVal: String;
begin
  if validarEditInt(TEdit(Sender), 1, MAXINT) then
  begin
    nAnt := sgValores.ColCount;
    lastVal := sgValores.Cells[nAnt - 1, 1];
    sgValores.ColCount := StrToInt(TEdit(Sender).Text) + 1;
    for i := nAnt to sgValores.ColCount - 1 do
    begin
      sgValores.Cells[i, 0] := IntToStr(i);
      sgValores.Cells[i, 1] := lastVal;
    end;
    utilidades.AutoSizeTable(self, sgValores, maxAnchoTablaEnorme,
      maxAlturaTablaChica, false);
  end;
end;

procedure TEditarFichaDeterminismo.ENPasosKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    if validarEditInt(TEdit(Sender), 1, MAXINT) then
      loQueHabia := TEdit(Sender).Text;
    EditTamTablaExit(Sender);
  end;
end;

procedure TEditarFichaDeterminismo.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaDeterminismo.FormResize(Sender: TObject);
begin
  utilidades.centrar2Botones(self, BGuardar, BCancelar);
end;

procedure TEditarFichaDeterminismo.validarCambioTabla(tabla: TStringGrid);
begin
  inherited validarCambioTablaNReals(tabla);
end;

function TEditarFichaDeterminismo.validarFormulario: Boolean;
begin
  result := inherited validarFormulario and inherited validarEditInt(ENPasos,
    1, MAXINT) and inherited validarTablaNReals_(sgValores);
end;

end.
