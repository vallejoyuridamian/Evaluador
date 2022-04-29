unit uEditarFichaGTer_ArranqueParada;


interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas,
  uGTer_ArranqueParada, uCosaConNombre, uFichasLPD, StdCtrls, Grids, utilidades,
  ExtCtrls, uconstantesSimSEE, xMatDefs, uBaseEditoresFichasGeneradores,
  usalasdejuego, uverdoc, uOpcionesSimSEEEdit;

resourcestring
  rsPotenciaMinima = 'Potencia mínima[MW]';
  rsPotenciaMaxima = 'Potencia máxima[MW]';
  rsCostoVariablePotenciaMinima = 'Costo variable a potencia mínima[USD/MWh]';
  rsCostoVariable = 'Costo variable[USD/MWh]';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';

  rsCostoDeArranque = 'Costo de arranque[USD]';
  rsCostoDeParada = 'Costo de parada[USD]';

type

  { TEditarFichaGTer_ArranqueParada }

  TEditarFichaGTer_ArranqueParada = class(TBaseEditoresFichasGeneradores)
    eCV: TLabeledEdit;
    eCVmin: TLabeledEdit;
    eCV_NoCombustible: TLabeledEdit;
    eCostoArranque: TLabeledEdit;
    eCostoParada: TLabeledEdit;
    eFD: TLabeledEdit;
    ePagoPorEnergia: TEdit;
    ePagoPorPotencia: TEdit;
    ePenalidad: TEdit;
    eMinHorasON: TEdit;
    eMinHorasOFF: TEdit;
    EFIni: TEdit;
    ePMax: TLabeledEdit;
    ePMin: TLabeledEdit;
    eTMR: TLabeledEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
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
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
  protected
    function validarFormulario(): boolean; override;
    procedure validarCambioTabla(tabla: TStringGrid); override;
  private
    Generador: TGTer_ArranqueParada;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichaGTer_ArranqueParada.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaGTer_ArranqueParada;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TGTer_ArranqueParada;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaGTer_ArranqueParada;

    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);


    ePMin.Text := FloatToStr(fichaAux.PMin);
     ePMax.Text := FloatToStr(fichaAux.PMax);
     eCVmin.Text := FloatToStr(fichaAux.cv_min);
     eCV.Text := FloatToStr(fichaAux.cv);
     eCV_NoCombustible.Text:= FloatToStr( fichaAux.cv_NoCombustible );
     eFD.Text := FloatToStr(fichaAux.disp);
     eTMR.Text := FloatToStr(fichaAux.tRepHoras);
     eCostoArranque.Text := FloatToStr(fichaAux.costo_arranque);
     eCostoParada.Text := FloatToStr(fichaAux.costo_parada);


    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited setCBFuente(CBFuenteIndicePreciosPorCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.indicePreciosPorCombustible,
      fichaAux.bornePreciosPorCombustible);

    self.eMinHorasON.Text := IntToStr(fichaAux.MinHorasON);
    self.eMinHorasOFF.Text := IntToStr(fichaAux.MinHorasOFF);
    self.ePenalidad.Text := FloatToStr(fichaAux.PenalidadONOFF);
    ePagoPorPotencia.Text:= FloatToStr( fichaAux.PagoPorDisponibilidad_USD_MWh );
    ePagoPorEnergia.Text:= FloatToStr( fichaAux.PagoPorEnergia_USD_MWh );
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
    eCostoArranque.Text:= '';
    eCostoParada.Text:= '';
    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);
    self.eMinHorasON.Text := '0';
    self.eMinHorasOFF.Text := '0';
    ePagoPorPotencia.Text:= FloatToStr( 0.0 );
    ePagoPorEnergia.Text:= FloatToStr( 0.0 );
  end;
end;

function TEditarFichaGTer_ArranqueParada.validarFormulario(): boolean;
begin
  Result :=  inherited validarFormulario and
    validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad)

    and validarEditFloat(ePMin)
    and validarEditFloat(ePMax)
    and validarEditFloat(eCVmin)
    and validarEditFloat(eCV)
    and validarEditFloat(eCV_NoCombustible)
    and validarEditFloat(eFD)
    and validarEditFloat(eTMR)
    and validarEditFloat(eCostoArranque)
    and validarEditFloat(eCostoParada)

    and inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0)
    and validarEditFloat( ePagoPorPotencia)
    and validarEditFloat( ePagoPorEnergia );
end;

procedure TEditarFichaGTer_ArranqueParada.validarCambioTabla(tabla: TStringGrid);
begin
  inherited validarCambioTablaNReals(tabla);
end;

procedure TEditarFichaGTer_ArranqueParada.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaGTer_ArranqueParada.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaGTer_ArranqueParada.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaGTer_ArranqueParada.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaGTer_ArranqueParada.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaGTer_ArranqueParada.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaGTer_ArranqueParada.BGuardarClick(Sender: TObject);
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

    ficha := TFichaGTer_ArranqueParada.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad,
      StrToFloat( ePMin.Text ),
      StrToFloat( ePMax.Text ),
      StrToFloat( eCVmin.Text),
      StrToFloat( eCV.Text),
      StrToFloat( eCV_NoCombustible.Text),
      valorCBFuente(CBFuenteIndicePreciosPorCombustible),
      valorCBString(CBBorneIndicePreciosCombustible),
      StrToFloat( eFD.Text ),
      StrToFloat( eTMR.Text),
      StrToFloat( eCostoArranque.Text),
      StrToFloat( eCostoParada.Text ),
      CBRestrEMax.Checked, restrEMax, StrToInt(self.eMinHorasON.Text),
      StrToInt(Self.eMinHorasOFF.Text), StrToFloat(self.ePenalidad.Text),
      StrToFloat( ePagoPorPotencia.text ), StrToFloat( ePagoPorEnergia.text ));
    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaGTer_ArranqueParada.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaGTer_ArranqueParada.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaGTer_ArranqueParada.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaGTer_ArranqueParada.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichaGTer_ArranqueParada.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TGTer_ArranqueParada);
end;

end.
