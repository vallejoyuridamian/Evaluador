unit ueditarfichafuentemaxmin;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, Grids, ExtCtrls, EditBtn,
  uCosaConNombre, uFuentesAleatorias, ufuentemaxmin, uFichasLPD, uSalasDeJuego,
  uverdoc, utilidades, uFechas, xMatDefs;

type

  { TEditarFichaFuenteMaxMin }

  TEditarFichaFuenteMaxMin = class(TBaseEditoresFichas)
    ComboBorne: TComboBox;
    ComboFuente: TComboBox;
    ComboMaxMin: TComboBox;
    EditMaxMin: TEdit;
    LBorne: TLabel;
    LFuente: TLabel;
    LMaxMin: TLabel;
    LFIni: TLabel;
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
    procedure ComboFuenteChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CBLargoPeriodoChange(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer; var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure CambiosForm(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
  private
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

  {$R *.lfm}

constructor TEditarFichaFuenteMaxMin.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  inicializarCBFuente(ComboFuente, ComboBorne, False);

  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;
    inherited setCBFuente(ComboFuente, ComboBorne, TFichaFuenteMaxMin(ficha).fuente,
      TFichaFuenteMaxMin(ficha).borne);
    EditMaxMin.Text := FloatToStr(TFichaFuenteMaxMin(ficha).valorBase);
    if not (TFichaFuenteMaxMin(ficha).esMaximo) then
      ComboMaxMin.ItemIndex := 1;
  end;
end;

function TEditarFichaFuenteMaxMin.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    validarCBFuente(ComboFuente, ComboBorne, 0) and
    validarEditFloat(EditMaxMin, -32000, 32000) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
end;

procedure TEditarFichaFuenteMaxMin.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteMaxMin);
end;

procedure TEditarFichaFuenteMaxMin.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteMaxMin.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  esMaximo: boolean;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := nil;

    if (ComboMaxMin.ItemIndex = 0) then
      esMaximo := True
    else
      esMaximo := False;

    ficha := TFichaFuenteMaxMin.Create(capa, TFecha.Create_Str(EFIni.Text),
      periodicidad, StrToFloat(EditMaxMin.Text), esMaximo,
      valorCBFuente(ComboFuente), valorCBString(ComboBorne));
    modalResult := mrOk;
  end;
end;

procedure TEditarFichaFuenteMaxMin.CambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaFuenteMaxMin.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaFuenteMaxMin.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteMaxMin.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteMaxMin.ComboFuenteChange(Sender: TObject);
begin
  inherited cbFuenteChange(ComboFuente, ComboBorne);
end;

procedure TEditarFichaFuenteMaxMin.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteMaxMin.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteMaxMin.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteMaxMin.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteMaxMin.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaFuenteMaxMin.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(sgPeriodicidad);
end;

end.