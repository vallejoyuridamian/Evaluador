unit uEditarFichaCombustible;
interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas,
  uCombustible, uCosaConNombre,
  uFichasLPD, StdCtrls, Grids, utilidades, uFechas,
  ExtCtrls, uconstantesSimSEE,
  usalasdejuego,
  uSalasDeJuegoParaEditor,
  xMatDefs, uverdoc, uOpcionesSimSEEEdit;

type

  { TEditarFichaCombustible }

  TEditarFichaCombustible = class(TBaseEditoresFichas)
    btvt_GasNatural: TButton;
    btvt_Gasoil: TButton;
    btvt_Fueloil: TButton;
    e_ro: TEdit;
    EditPCI: TEdit;
    EditPCS: TEdit;
    EFIni: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    LabelPCI: TLabel;
    LabelPCS: TLabel;
    LFIni: TLabel;
    BGuardar: TButton;
    BCancelarFicha: TButton;
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
    procedure btvt_GasNaturalClick(Sender: TObject);
    procedure btvt_GasoilClick(Sender: TObject);
    procedure btvt_FueloilClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure EditEnter(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarFormulario(): boolean; override;
  private
    combustible: TCombustible;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaCombustible: TEditarFichaCombustible;

implementation

uses SimSEEEditMain, uBaseAltasEditores;
  {$R *.lfm}

constructor TEditarFichaCombustible.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaCombustible;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  combustible := cosaConNombre as TCombustible;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);


  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaCombustible;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);

    e_ro.Text := FloatToStr(fichaAux.ro);
    EditPCI.Text := FloatToStr(fichaAux.PCI);
    EditPCS.Text := FloatToStr(fichaAux.PCS);

  end
  else
  begin
    self.EFIni.Text := '';
  end;
end;

function TEditarFichaCombustible.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    validarEditFloat(e_ro, 0, 100000) and
    validarEditFloat(EditPCI, 0, 100000000) and
    validarEditFloat(EditPCS, 0, 100000000);
end;

procedure TEditarFichaCombustible.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaCombustible.btvt_GasNaturalClick(Sender: TObject);
begin
  e_ro.Text:= FloatToStr( 0.62 {kg/m3} );
  editPCI.Text:= FloatToStr( 8300 {kcal/m3} / 0.62 {kg/m3} * J_por_kcal );
  editPCS.Text:= FloatToStr( 9300 {kcal/m3} / 0.62 {kg/m3} * J_por_kcal );
end;


procedure TEditarFichaCombustible.btvt_GasoilClick(Sender: TObject);
begin
  e_ro.Text:= FloatToStr( 0.8405 {kg/lt} * lt_por_m3 );
  editPCI.Text:= FloatToStr( 8546 {kcal/lt} / 0.8405 {kg/lt} * J_por_kcal );
  editPCS.Text:= FloatToStr( 9146 {kcal/lt} / 0.8405 {kg/lt} * J_por_kcal );
end;

procedure TEditarFichaCombustible.btvt_FueloilClick(Sender: TObject);
begin
  e_ro.Text:= FloatToStr( 0.9774 {kg/lt} * lt_por_m3 );
  editPCI.Text:= FloatToStr( 8851 {kcal/lt} / 0.9774 {kg/lt} * J_por_kcal );
  editPCS.Text:= FloatToStr( 10128 {kcal/lt}/ 0.9774 {kg/lt} * J_por_kcal );
end;

procedure TEditarFichaCombustible.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaCombustible.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaCombustible.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaCombustible.sgChequearCambios(Sender: TObject);
begin

end;

procedure TEditarFichaCombustible.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaCombustible.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  restrEmax: NReal;
begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo,
        EFFinPeriodo,
        sgPeriodicidad);


    ficha := TFichaCombustible.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
      StrToFloat(e_ro.Text), StrToFloat(EditPCI.Text),
      StrToFloat(EditPCS.Text));

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaCombustible.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;


procedure TEditarFichaCombustible.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TCombustible);
end;

end.

