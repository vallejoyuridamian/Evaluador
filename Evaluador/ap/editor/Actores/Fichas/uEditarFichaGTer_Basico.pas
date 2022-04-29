unit uEditarFichaGTer_Basico;

interface

uses

{$IFDEF WINDOWS}
 Windows,
 {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ugter_basico, CheckLst, uglobs, ufichasLPD, uBaseEditoresFichas,
  utilidades, uFechas, uBaseAltasEditores, uCosaConNombre, ExtCtrls, uconstantesSimSEE,
  usalasdejuego, uBaseEditoresFichasGeneradores, xMatDefs,
  uSalasDeJuegoParaEditor, uverdoc, uFuentesAleatorias, uOpcionesSimSEEEdit;


type

  { TEditarFichaGTer_Basico }

  TEditarFichaGTer_Basico = class(TBaseEditoresFichasGeneradores)
    BGuardar: TButton;
    BCancelar: TButton;
    eCV: TLabeledEdit;
    eCV_NoCombustible: TLabeledEdit;
    eFactorReserva: TLabeledEdit;
    eFD: TLabeledEdit;
    ePMax: TLabeledEdit;
    eTMR: TLabeledEdit;
    LFIni: TLabel;
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
    CBRestrEMax: TCheckBox;
    ERestrEMax: TEdit;
    BAyuda: TButton;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    Label1: TLabel;
    ePagoPorPotencia: TEdit;
    Label2: TLabel;
    ePagoPorEnergia: TEdit;
    Label3: TLabel;
    procedure eFactorReservaChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer; var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
  protected
    function validarFormulario(): boolean; override;
  private
    Generador: TGter_Basico;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichaGTer_Basico.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaGTer_Basico;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TGTer_Basico;
  guardado := True;

  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  inherited inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaGTer_Basico;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);

    (**** para cuando se modernize
    ePMax.Text := fichaAux.GetValStr('PMax' );
    eFactorReserva.Text:= fichaAux.GetValStr( 'fReserva' );
    eCV.Text := fichaAux.GetValStr( 'cv' );
    eCV_NoCombustible.Text:= fichaAux.GetValStr( 'cv_NoCombustible' );
    eFD.Text := fichaAux.GetValStr( 'disp' );
    eTMR.Text := fichaAux.GetValStr( 'tRepHoras');
    self.ePagoPorPotencia.Text := fichaAux.GetValStr( 'PagoPorDisponibilidad_USD_MWh' );
    self.ePagoPorEnergia.Text := fichaAux.GetValStr( 'PagoPorEnergia_USD_MWh');
    ***)

    ePMax.Text := FloatToStr( fichaAux.PMax );
    eFactorReserva.Text:= FloatToStr( fichaAux.fReserva );
    eCV.Text := FloatToStr( fichaAux.cv );
    eCV_NoCombustible.Text:= FloatToStr( fichaAux.cv_NoCombustible );
    eFD.Text := FloatToSTr( fichaAux.disp );
    eTMR.Text := FloatToStr( fichaAux.tRepHoras );
    self.ePagoPorPotencia.Text := FloatToStr( fichaAux.PagoPorDisponibilidad_USD_MWh );
    self.ePagoPorEnergia.Text := FloatToStr( fichaAux.PagoPorEnergia_USD_MWh );


    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited setCBFuente(CBFuenteIndicePreciosPorCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.indicePreciosPorCombustible,
      fichaAux.bornePreciosPorCombustible);

  end
  else
  begin
    self.EFIni.Text := '';

    ePMax.Text := '';
    eFactorReserva.Text:= FloatToStr( 0.0 );
    eCV.Text := '';
    eCV_NoCombustible.Text:= '';
    eFD.Text := '';
    eTMR.Text := '';

    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);
    self.ePagoPorPotencia.Text := '0';
    self.ePagoPorEnergia.Text := '0';
  end;
end;

function TEditarFichaGTer_Basico.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad)
    and validarEditFloat(ePMax)
    and validarEditFloat( eFactorReserva )
    and validarEditFloat(eCV)
    and validarEditFloat(eCV_NoCombustible)
    and validarEditFloat(eFD)
    and validarEditFloat(eTMR)
    and inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0);
end;

procedure TEditarFichaGTer_Basico.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaGTer_Basico.eFactorReservaChange(Sender: TObject);
begin

end;

procedure TEditarFichaGTer_Basico.BGuardarClick(Sender: TObject);
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

    ficha := TFichaGTer_Basico.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad, StrToFloat( ePMax.Text),
      StrToFloat( eCV.Text), StrToFloat( eCV_NoCombustible.Text),valorCBFuente(
      CBFuenteIndicePreciosPorCombustible), valorCBString(
      CBBorneIndicePreciosCombustible),
      StrToFloat( eFD.Text ),
      StrToFloat( eTMR.Text ), CBRestrEMax.Checked,
      restrEMax, StrToFloat(self.ePagoPorPotencia.Text),
      StrToFloat(self.ePagoPorEnergia.Text),
      StrToFloat( eFactorReserva.Text ));


    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaGTer_Basico.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaGTer_Basico.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaGTer_Basico.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaGTer_Basico.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaGTer_Basico.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaGTer_Basico.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaGTer_Basico.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaGTer_Basico.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaGTer_Basico.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaGTer_Basico.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichaGTer_Basico.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TGTer_Basico);
end;

initialization
end.
