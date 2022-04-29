unit uEditarFichaArcoConSalidaProgramable;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, xMatDefs, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, uBaseEditoresFichas, StdCtrls, ExtCtrls, Grids,
  Menus, uArcoConSalidaProgramable,
  uCosaConNombre, uFichasLPD, uSalasDeJuego, utilidades, uconstantesSimSEE,
  uFechas, uverdoc, uOpcionesSimSEEEdit;

type

  { TEditarFichaArcoConSalidaProgramable }

  TEditarFichaArcoConSalidaProgramable = class(TBaseEditoresFichas)
    eNPasosAntesNuevaProg: TEdit;
    ePagoPorDisponibilidad: TEdit;
    eRendimiento_pp: TEdit;
    ePeaje_pp: TEdit;
    eNPasosDePreAviso: TEdit;
    eCostoPorDesconexion: TEdit;
    eNPasosDeDesconectado: TEdit;
    ePMax_pp: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
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
    arco: TArcoConSalidaProgramable;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaArcoConSalidaProgramable: TEditarFichaArcoConSalidaProgramable;

implementation

uses uBaseAltasEditores, SimSEEEditMain;
  {$R *.lfm}

constructor TEditarFichaArcoConSalidaProgramable.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaArcoConSalidaProgramable;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  arco := cosaConNombre as TArcoConSalidaProgramable;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if (ficha <> nil) then
  begin

    fichaAux := ficha as TFichaArcoConSalidaProgramable;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);


    self.eRendimiento_pp.Text := DAOfNRealToStr_(fichaAux.rendimiento, 12, 2, ';');
    self.ePeaje_pp.Text := DAOfNRealToStr_(fichaAux.peaje, 12, 2, ';');
    self.ePMax_pp.Text := DAOfNRealToStr_(fichaAux.PMAx, 12, 1, ';');

    self.eNPasosDePreAviso.Text := IntToStr(fichaAux.NPasosDePreAviso);
    self.eNPasosDeDesconectado.Text := IntToStr(fichaAux.NPasosDeDesconexion);
    self.eNPasosAntesNuevaProg.Text := IntToStr(fichaAux.NPasosAntesNuevaProg);
    self.eCostoPorDesconexion.Text := FloatToStr(fichaAux.CostoPorDesconexion);
    ePagoPorDisponibilidad.Text:= FloatToStr( fichaAux.PagoPorDisponibilidad_USD_MWh );
  end
  else
  begin
    self.EFIni.Text := '';

    self.eRendimiento_pp.Text := '';
    self.ePeaje_pp.Text := '';
    self.ePMax_pp.Text := '';
    self.eNPasosDePreAviso.Text := '';
    self.eNPasosDeDesconectado.Text := '';
    self.eNPasosAntesNuevaProg.Text := '';
    self.eCostoPorDesconexion.Text := '';
    ePagoPorDisponibilidad.Text:= FloatToStr( 0.0 );
  end;
end;

function TEditarFichaArcoConSalidaProgramable.validarFormulario: boolean;
var
  res: boolean;
begin
  res:= inherited validarFormulario;
  res:= res and validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo,
    sgPeriodicidad)
    and inherited validarEditInt(
    eNPasosDePreaviso, -10000, 10000) and inherited validarEditInt(
    eNPasosDeDesconectado, -100000, 100000) and inherited validarEditInt(
    eNPasosAntesNuevaProg, -100000, 100000) and
    validarEditFloat( ePagoPorDisponibilidad ) and
    inherited validarEditFloat(eCostoPorDesconexion, -1e20, 1e20);

  Result := res;
end;

procedure TEditarFichaArcoConSalidaProgramable.validarCambioTabla(tabla: TStringGrid);
begin
  inherited validarCambioTablaNReals(tabla);
end;

procedure TEditarFichaArcoConSalidaProgramable.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;



procedure TEditarFichaArcoConSalidaProgramable.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaArcoConSalidaProgramable.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaArcoConSalidaProgramable.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaArcoConSalidaProgramable.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaArcoConSalidaProgramable.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, key, Shift);
end;

procedure TEditarFichaArcoConSalidaProgramable.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaArcoConSalidaProgramable.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaArcoConSalidaProgramable.BGuardarClick(Sender: TObject);
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

    ficha := TFichaArcoConSalidaProgramable.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
      StrToDAOfNReal_(eRendimiento_pp.Text, ';'), StrToDAOfNReal_(
      ePeaje_pp.Text, ';'), StrToDAOfNReal_(ePMax_pp.Text, ';'),
      StrToInt(eNPasosDePreaviso.Text), StrToInt(
      eNPasosDeDesconectado.Text), StrToInt(eNPasosAntesNuevaProg.Text),
      StrToFloat(eCostoPorDesconexion.Text), StrToFloat( ePagoPorDisponibilidad.text ) );

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaArcoConSalidaProgramable.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TArcoConSalidaProgramable);
end;

end.
