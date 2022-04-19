unit uEditarFichaGTer_OnOffPorPaso;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas,
  uGTer_OnOffPorPaso, uCosaConNombre, uFichasLPD, StdCtrls, Grids, utilidades, uFechas,
  ExtCtrls, uconstantesSimSEE, uBaseEditoresFichasGeneradores, xMatDefs,
  usalasdejuego, uBaseAltasEditores,
  uSalasDeJuegoParaEditor, uverdoc,
  uFuentesAleatorias, uOpcionesSimSEEEdit;


type

  { TEditarFichaGTer_OnOffPorPaso }

  TEditarFichaGTer_OnOffPorPaso = class(TBaseEditoresFichasGeneradores)
    eCV: TLabeledEdit;
    eCVmin: TLabeledEdit;
    eCV_NoCombustible: TLabeledEdit;
    eFD: TLabeledEdit;
    ePagoPorEnergia: TEdit;
    ePagoPorPotencia: TEdit;
    ePMax: TLabeledEdit;
    ePMin: TLabeledEdit;
    eTMR: TLabeledEdit;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LFIni: TLabel;
    EFIni: TEdit;
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
    CBRestrEMax: TCheckBox;
    ERestrEMax: TEdit;
    BAyuda: TButton;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure EditEnter(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer; var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
  protected
    procedure validarCambioTabla(tabla: TStringGrid); override;
    function validarFormulario(): boolean; override;
  private
    Generador: TGTer_OnOffPorPaso;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;
  {$R *.lfm}

constructor TEditarFichaGTer_OnOffPorPaso.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaGTer_OnOffPorPaso;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TGTer_OnOffPorPaso;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaGTer_OnOffPorPaso;

    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);

    ePMin.Text := FloatToStr(fichaAux.PMin);
    ePMax.Text := FloatToStr(fichaAux.PMax);
    eCVmin.Text := FloatToStr(fichaAux.cv_min);
    eCV.Text := FloatToStr(fichaAux.cv);
    eCV_NoCombustible.Text:= FloatToStr( fichaAux.cv_NoCombustible );
    eFD.Text := FloatToStr(fichaAux.disp);
    eTMR.Text := FloatToStr(fichaAux.tRepHoras);


    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited setCBFuente(CBFuenteIndicePreciosPorCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.indicePreciosPorCombustible,
      fichaAux.bornePreciosPorCombustible);
    self.ePagoPorPotencia.Text := FloatToStr(fichaAux.PagoPorDisponibilidad_USD_MWh);
    self.ePagoPorEnergia.Text := FloatToStr(fichaAux.PagoPorEnergia_USD_MWh);

  end
  else
  begin
    self.EFIni.Text := '';

    ePMin.Text := '';
    ePMax.Text := '';
    eCVmin.Text := '';
    eCV.Text := '';
    eCV_NoCombustible.Text:= '';
    eFD.Text := '';
    eTMR.Text := '';

    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);
    self.ePagoPorPotencia.Text := FloatToStr(0);
    self.ePagoPorEnergia.Text := FloatToStr(0);

  end;
end;

procedure TEditarFichaGTer_OnOffPorPaso.validarCambioTabla(tabla: TStringGrid);
begin
  inherited validarCambioTablaNReals(tabla);
end;

function TEditarFichaGTer_OnOffPorPaso.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo,
    sgPeriodicidad)
    and validarEditFloat(ePMin)
    and validarEditFloat(ePMax)
    and validarEditFloat(eCVmin)
    and validarEditFloat(eCV)
    and validarEditFloat(eCV_NoCombustible)
    and validarEditFloat(eFD)
    and validarEditFloat(eTMR)
    and inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0);
end;

procedure TEditarFichaGTer_OnOffPorPaso.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaGTer_OnOffPorPaso.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaGTer_OnOffPorPaso.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaGTer_OnOffPorPaso.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaGTer_OnOffPorPaso.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaGTer_OnOffPorPaso.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  restrEMax: NReal;
begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
    restrEMax := inherited rest(CBRestrEMax, ERestrEMax, MaxNReal);

    ficha := TFichaGTer_OnOffPorPaso.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
      StrToFloat( ePMin.Text),
      StrToFloat( ePMax.Text),
      StrToFloat( eCVmin.Text),
      StrToFloat( eCV.Text ),
      StrToFloat( eCV_NoCombustible.Text ),
      valorCBFuente(CBFuenteIndicePreciosPorCombustible), valorCBString(
      CBBorneIndicePreciosCombustible),
      StrToFloat( eFD.Text ),
      StrToFloat( eTMR.Text ),
      CBRestrEMax.Checked, restrEMax,
      StrToFloat(ePagoPorPotencia.Text),
      StrToFloat(ePagoPorEnergia.Text));
    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaGTer_OnOffPorPaso.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaGTer_OnOffPorPaso.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarFichaGTer_OnOffPorPaso.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaGTer_OnOffPorPaso.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichaGTer_OnOffPorPaso.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TGTer_OnOffPorPaso);
end;

end.
