unit uEditarFichaFuenteUniforme;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, uBaseEditoresFichas, uCosaConNombre, ufichasLPD,
  uFuenteUniforme,
  uConstantesSimSEE, utilidades, uFechas,
  usalasdejuego, uOpcionesSimSEEEdit,
  usalasdejuegoParaEditor, uverdoc, xMatDefs;

resourcestring
  mesValorIntroducidoDebeNum = 'El valor introducido debe ser numérico';

type
  TEditarFichaFuenteUniforme = class(TBaseEditoresFichas)
    LFIni: TLabel;
    sgFicha: TStringGrid;
    BGuardar: TButton;
    BCancelar: TButton;
    EFIni: TEdit;
    CBPeriodicidad: TCheckBox;
    PPeriodicidad: TPanel;
    LFinPeriodo: TLabel;
    LIniPeriodo: TLabel;
    LLargoPeriodo: TLabel;
    EFFinPeriodo: TEdit;
    EFIniPeriodo: TEdit;
    sgPeriodicidad: TStringGrid;
    ELargoPeriodo: TEdit;
    CBLargoPeriodo: TComboBox;
    BAyuda: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure sgChequearCambios(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure BAyudaClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function validarSgFichas: boolean;

    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaFuenteUniforme: TEditarFichaFuenteUniforme;

implementation

  {$R *.lfm}

constructor TEditarFichaFuenteUniforme.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;
    sgFicha.Cells[1, 0] := FloatToStrF(TFichaFuenteUniforme(ficha).minimo,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 1] := FloatToStrF(TFichaFuenteUniforme(ficha).maximo,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
  end;
end;

function TEditarFichaFuenteUniforme.validarSgFichas: boolean;
var
  i: integer;
begin
  try
    for i := 0 to sgFicha.RowCount - 1 do
      StrToFloat(sgFicha.cells[1, i]);
    Result := True;
  except
    on EConvertError do
    begin
      ShowMessage(mesValorIntroducidoDebeNum);
      sgFicha.SetFocus;
      Result := False;
    end
  end;
end;

function TEditarFichaFuenteUniforme.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    validarSgFichas;
end;

procedure TEditarFichaFuenteUniforme.FormCreate(Sender: TObject);
begin
  sgFicha.Cells[0, 0] := 'Mínimo';
  sgFicha.Cells[0, 1] := 'Máximo';
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteUniforme.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteUniforme.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteUniforme.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteUniforme.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteUniforme.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteUniforme.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteUniforme.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
        EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := nil;
    ficha := TFichaFuenteUniforme.Create(capa, TFecha.Create_Str(EFIni.Text),
      periodicidad, StrToFloat(sgFicha.Cells[1, 0]), StrToFloat(sgFicha.Cells[1, 1]));
    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaFuenteUniforme.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaFuenteUniforme.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, key, Shift);
end;

procedure TEditarFichaFuenteUniforme.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteUniforme);
end;

end.
