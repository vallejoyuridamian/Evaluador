unit uEditarFichaArcoCombustible;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, xMatDefs, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, ExtCtrls, Grids,
  uArcoCombustible,
  uCosaConNombre, uFichasLPD,
  uSalasDeJuego, utilidades, uconstantesSimSEE, uFechas, uverdoc,
  uOpcionesSimSEEEdit;

type

  { TEditarFichaArco }

  TEditarFichaArcoCombustible = class(TBaseEditoresFichas)
    cbConsiderarPeajeEnElDespacho: TCheckBox;
    cbSumarPeajeAl_CDP: TCheckBox;
    eFactorPeaje_CDP: TEdit;
    ePagoPorDisponibilidad: TEdit;
    eTMR: TEdit;
    eFD: TEdit;
    ePeaje_pp: TEdit;
    eRendimiento_pp: TEdit;
    eQMax_pp: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
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
    procedure FormCreate(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
    procedure validarCambioTabla(tabla: TStringGrid); override;
  private
    arcoComb: TArcoCombustible;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaArcoCombustible: TEditarFichaArcoCombustible;

implementation

uses uBaseAltasEditores, SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichaArcoCombustible.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaArcoCombustible;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  arcoComb := cosaConNombre as TArcoCombustible;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaArcoCombustible;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    self.eRendimiento_pp.Text := DAOfNRealToStr_(fichaAux.ren, 12, 2, ';');
    self.ePeaje_pp.Text := DAOfNRealToStr_(fichaAux.peaje_USD_por_MWh, 12, 2, ';');
    self.eQMax_pp.Text := DAOfNRealToStr_(fichaAux.QMAx, 12, 1, ';');
    self.eFD.Text := FloatToStr(fichaAux.fd);
    self.eTMR.Text := FloatToStr(fichaAux.TMR);
    self.cbConsiderarPeajeEnElDespacho.Checked := fichaAux.flg_ConsiderarPeajeEnElDespacho;
    self.cbSumarPeajeAl_CDP.Checked := fichaAux.flg_SumarPeajeAlCDP;
    self.eFactorPeaje_CDP.Text := FloatToStr(fichaAux.factorPeajeCDP);
    self.ePagoPorDisponibilidad.text:= FloatToStr( fichaAux.PagoPorCapacidad_USD_por_MWh );
  end
  else
  begin
    self.EFIni.Text := '';
    self.eRendimiento_pp.Text := '';
    self.ePeaje_pp.Text := '';
    self.eQMax_pp.Text := '';
    self.eFD.Text := '';
    self.eTMR.Text := '';
    self.cbConsiderarPeajeEnElDespacho.Checked := True;
    self.cbSumarPeajeAl_CDP.Checked := True;
    self.eFactorPeaje_CDP.Text := FloatToStr(1.0);
    self.ePagoPorDisponibilidad.text:= FloatToStr( 0.0 );
  end;
end;

function TEditarFichaArcoCombustible.validarFormulario: boolean;
var
  res: boolean;
begin

  res :=inherited validarFormulario and
    validarEditFecha(EFIni) and validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad) and validarEditFloat(eFD, 0, 1) and
    validarEditFloat(eTMR, 0, 10000) and validarEditDAOfNReal(
    eRendimiento_pp, -100, 100, ';') and validarEditDAOfNReal(
    eQMax_pp, -100000, 100000, ';') and validarEditDAOfNReal(
    ePeaje_pp, -100000, 100000, ';')
    and validarEditFloat( ePagoPorDisponibilidad );

  if cbSumarPeajeAl_CDP.Checked then
    res := res and validarEditFloat(eFactorPeaje_CDP, -1E20, 1E20);
  Result := res;
end;

procedure TEditarFichaArcoCombustible.validarCambioTabla(tabla: TStringGrid);
begin
  inherited validarCambioTablaNReals(tabla);
end;

procedure TEditarFichaArcoCombustible.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaArcoCombustible.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaArcoCombustible.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaArcoCombustible.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaArcoCombustible.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaArcoCombustible.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaArcoCombustible.sgGetEditText(Sender: TObject; ACol, ARow: integer;
  var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaArcoCombustible.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, key, Shift);
end;

procedure TEditarFichaArcoCombustible.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaArcoCombustible.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaArcoCombustible.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

    ficha := TFichaArcoCombustible.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad, StrToDAOfNReal_(eRendimiento_pp.Text, ';'),
      StrToDAOfNReal_(ePeaje_pp.Text, ';'), StrToDAOfNReal_(
      eQMax_pp.Text, ';'), StrToFloat(eFD.Text), StrToFloat(eTMR.Text),
      cbConsiderarPeajeEnElDespacho.Checked, cbSumarPeajeAl_CDP.Checked,
      StrToFloat(eFactorPeaje_CDP.Text), StrToFloat( ePagoPorDisponibilidad.text ) );

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaArcoCombustible.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TArcoCombustible);
end;

end.
