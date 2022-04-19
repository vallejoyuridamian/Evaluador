unit ueditarfichafuentesinusoide;

{$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, Grids, ExtCtrls, EditBtn,
  uCosaConNombre, uFuentesAleatorias, ufuentesinusoide, uFichasLPD, uSalasDeJuego,
  uverdoc, utilidades, uFechas, xMatDefs;

type

  { TEditarFichaFuenteSinusoide }

  TEditarFichaFuenteSinusoide = class(TBaseEditoresFichas)
    ComboBorne: TComboBox;
    ComboFuente: TComboBox;
    ComboSinusoide: TComboBox;
    EditA: TEdit;
    Editw: TEdit;
    Editphi: TEdit;
    LA: TLabel;
    LBorne: TLabel;
    LFuente: TLabel;
    Lw: TLabel;
    Lphi: TLabel;
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

{$IFNDEF FPC}
  {$R *.dfm}

{$ELSE}
  {$R *.lfm}
{$ENDIF}

constructor TEditarFichaFuenteSinusoide.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
  prueba: string;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  inicializarCBFuente(ComboFuente, ComboBorne, False);

  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;
    inherited setCBFuente(ComboFuente, ComboBorne, TFichaFuenteSinusoide(ficha).fuente,
      TFichaFuenteSinusoide(ficha).borne);
    EditA.Text := FloatToStr(TFichaFuenteSinusoide(ficha).parametroA);
    Editw.Text := FloatToStr(TFichaFuenteSinusoide(ficha).parametroW);
    Editphi.Text := FloatToStr(TFichaFuenteSinusoide(ficha).parametroPhi);
    if not (TFichaFuenteSinusoide(ficha).esCoseno) then
      ComboSinusoide.ItemIndex := 1;
  end;
end;

function TEditarFichaFuenteSinusoide.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    inherited validarCBFuente(ComboFuente, ComboBorne, 0) and
    validarEditFloat(EditA, -50000, 50000) and validarEditFloat(Editw, -50000, 50000) and
    validarEditFloat(Editphi, -50000, 50000) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
end;

procedure TEditarFichaFuenteSinusoide.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteSinusoide);
end;

procedure TEditarFichaFuenteSinusoide.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteSinusoide.BGuardarClick(Sender: TObject);
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

    if (ComboSinusoide.ItemIndex = 0) then
      esMaximo := True
    else
      esMaximo := False;

    ficha := TFichaFuenteSinusoide.Create(capa, TFecha.Create_Str(EFIni.Text),
      periodicidad, StrToFloat(EditA.Text), StrToFloat(Editw.Text),
      StrToFloat(Editphi.Text), esMaximo, valorCBFuente(ComboFuente),

      valorCBString(ComboBorne));
    modalResult := mrOk;
  end;
end;

procedure TEditarFichaFuenteSinusoide.CambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaFuenteSinusoide.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaFuenteSinusoide.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteSinusoide.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteSinusoide.ComboFuenteChange(Sender: TObject);
begin
  inherited cbFuenteChange(ComboFuente, ComboBorne);
end;

procedure TEditarFichaFuenteSinusoide.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteSinusoide.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteSinusoide.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteSinusoide.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteSinusoide.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaFuenteSinusoide.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(sgPeriodicidad);
end;

end.