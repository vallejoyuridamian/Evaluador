unit uEditarFichaGTer_combinado;
interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas,
  uGTer_combinado, uCosaConNombre, uFichasLPD, StdCtrls, Grids, utilidades, uFechas,
  ExtCtrls, uconstantesSimSEE, uBaseEditoresFichasGeneradores,
  usalasdejuego,
  uSalasDeJuegoParaEditor,
  xMatDefs, uverdoc, uFuentesAleatorias, uOpcionesSimSEEEdit;

resourcestring
  rsPotenciaMinima = 'Potencia mínima[MW]';
  rsPotenciaMaxima = 'Potencia maxima[MW]';
  rsCostoVariablePotenciaMinima = 'Costo variable a potencia mínima[USD/MWh]';
  rsCostoVariable = 'Costo variable[USD/MWh]';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';

type

  { TEditarFichaGTer_combinado }

  TEditarFichaGTer_combinado = class(TBaseEditoresFichasGeneradores)
    eTG_CV: TLabeledEdit;
    eTV_CV: TLabeledEdit;
    eTG_CVmin: TLabeledEdit;
    eTV_CVmin: TLabeledEdit;
    eTG_CV_NoCombustible: TLabeledEdit;
    eTV_CV_NoCombustible: TLabeledEdit;
    eTG_FD: TLabeledEdit;
    ePagoPorEnergia: TEdit;
    ePagoPorPotencia: TEdit;
    eTV_FD: TLabeledEdit;
    eTG_PMax: TLabeledEdit;
    eTV_PMax: TLabeledEdit;
    eTG_PMin: TLabeledEdit;
    EPotTVdivTG: TEdit;
    EFIni: TEdit;
    eTV_PMin: TLabeledEdit;
    eTG_TMR: TLabeledEdit;
    eTV_TMR: TLabeledEdit;
    gbDatosTV: TGroupBox;
    GroupBox1: TGroupBox;
    gbDatosTG: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LFIni: TLabel;
    LTGdivTG: TLabel;
    LFactorPotenciaCC: TLabel;
    LabelCC: TLabel;
    BGuardar: TButton;
    BCancelarFicha: TButton;
    CBPeriodicidad: TCheckBox;
    PPeriodicidad: TPanel;
    LFinPeriodo: TLabel;
    LIniPeriodo: TLabel;
    LLargoPeriodo: TLabel;
    EFFinPeriodo: TEdit;
    EFIniPeriodo: TEdit;
    rbOnOffPorPoste: TRadioButton;
    rbOnOffPorPaso: TRadioButton;
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
    procedure eTV_CV_NoCombustibleChange(Sender: TObject);
    procedure eTV_TMRChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure EditEnter(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
  protected
    function validarFormulario(): boolean; override;
  private
    Generador: TGTer_combinado;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaGTer_combinado: TEditarFichaGTer_combinado;

implementation

uses SimSEEEditMain, uBaseAltasEditores;

{$IFNDEF FPC}
  {$R *.dfm}

{$ELSE}
  {$R *.lfm}
{$ENDIF}

constructor TEditarFichaGTer_combinado.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaGTer_combinado;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TGTer_combinado;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaGTer_combinado;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);

    //Cargo la tabla de TG con los valores de la ficha
    eTG_PMin.Text := FloatToStr(fichaAux.PMin_TG);
    eTG_PMax.Text := FloatToStr(fichaAux.PMax_TG);
    eTG_CVmin.Text := FloatToStr(fichaAux.cv_min_TG);
    eTG_CV.Text := FloatToStr(fichaAux.cv_TG);
    eTG_CV_NoCombustible.Text:= FloatToStr( fichaAux.cv_NoCombustible_TG );
    eTG_FD.Text := FloatToStr(fichaAux.disp_TG);
    eTG_TMR.Text := FloatToStr(fichaAux.tRepHoras_TG);


    //Cargo la tabla de CC con los valores de la ficha
    eTV_PMin.Text := FloatToStr(fichaAux.PMin_TV);
    eTV_PMax.Text := FloatToStr(fichaAux.PMax_TV);
    eTV_CVmin.Text := FloatToStr(fichaAux.cv_min_TV);
    eTV_CV.Text := FloatToStr(fichaAux.cv_TV);
    eTV_CV_NoCombustible.Text:= FloatToStr( fichaAux.cv_NoCombustible_TV );
    eTV_FD.Text := FloatToStr(fichaAux.disp_TV);
    eTV_TMR.Text := FloatToStr(fichaAux.tRepHoras_TV);
    rbOnOffPorPaso.Checked:= fichaAux.flg_TV_OnOffPorPaso;
    rbOnOffPorPoste.Checked:= not rbOnOffPorPaso.Checked;

    EPotTVdivTG.Text := FloatToStr(fichaAux.factorPotenciaTVdivTG);

    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited setCBFuente(CBFuenteIndicePreciosPorCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.indicePreciosPorCombustible,
      fichaAux.bornePreciosPorCombustible);

    ePagoPorPotencia.Text:= FloatToStr( fichaAux.PagoPorDisponibilidad_USD_MWh );
    ePagoPorEnergia.Text:= FloatToStr( fichaAux.PagoPorEnergia_USD_MWh );
  end
  else
  begin
    self.EFIni.Text := '';
    //Cargo la tabla de TG con los valores de la ficha
    eTG_PMin.Text := '';
    eTG_PMax.Text := '';
    eTG_CVmin.Text := '';
    eTG_CV.Text := '';
    eTG_CV_NoCombustible.Text:= '';
    eTG_FD.Text := '';
    eTG_TMR.Text := '';


    //Cargo la tabla de CC con los valores de la ficha
    eTV_PMin.Text := '';
    eTV_PMax.Text := '';
    eTV_CVmin.Text := '';
    eTV_CV.Text := '';
    eTV_CV_NoCombustible.Text:= '';
    eTV_FD.Text := '';
    eTV_TMR.Text := '';
    rbOnOffPorPaso.Checked:= true;
    rbOnOffPorPoste.Checked:= false;

    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);
    ePagoPorPotencia.Text:= FloatToStr( 0.0 );
    ePagoPorEnergia.Text:= FloatToStr( 0.0 );

  end;
end;

function TEditarFichaGTer_combinado.validarFormulario(): boolean;
begin

  Result := inherited validarFormulario and validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad)

    and validarEditFloat(eTG_PMin)
    and validarEditFloat(eTG_PMax)
    and validarEditFloat(eTG_CVmin)
    and validarEditFloat(eTG_CV)
    and validarEditFloat(eTG_CV_NoCombustible)
    and validarEditFloat(eTG_FD)
    and validarEditFloat(eTG_TMR)

    and validarEditFloat(eTV_PMin)
    and validarEditFloat(eTV_PMax)
    and validarEditFloat(eTV_CVmin)
    and validarEditFloat(eTV_CV)
    and validarEditFloat(eTV_CV_NoCombustible)
    and validarEditFloat(eTV_FD)
    and validarEditFloat(eTV_TMR)

    and
    inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0) and validarEditFloat(EPotTVdivTG, 0, 100000)
    and validarEditFloat( ePagoPorPotencia ) and validarEditFloat( ePagoPorEnergia );
end;

procedure TEditarFichaGTer_combinado.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaGTer_combinado.eTV_TMRChange(Sender: TObject);
begin

end;

procedure TEditarFichaGTer_combinado.eTV_CV_NoCombustibleChange(Sender: TObject
  );
begin

end;

procedure TEditarFichaGTer_combinado.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaGTer_combinado.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaGTer_combinado.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaGTer_combinado.sgChequearCambios(Sender: TObject);
begin

end;

procedure TEditarFichaGTer_combinado.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaGTer_combinado.BGuardarClick(Sender: TObject);
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
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

    restrEMax := inherited rest(CBRestrEMax, ERestrEMax, MaxNReal);

    ficha := TFichaGTer_combinado.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,

      //Valores de TG
      StrToFloat( eTG_PMin.Text),
      StrToFloat( eTG_PMax.Text),
      StrToFloat( eTG_CVmin.Text),
      StrToFloat( eTG_CV.Text ),
      StrToFloat( eTG_CV_NoCombustible.Text ),
      StrToFloat( eTG_FD.Text ),
      StrToFloat( eTG_TMR.Text ),

      //Valores de TV
      StrToFloat( eTV_PMin.Text),
      StrToFloat( eTV_PMax.Text),
      StrToFloat( eTV_CVmin.Text),
      StrToFloat( eTV_CV.Text ),
      StrToFloat( eTV_CV_NoCombustible.Text ),
      StrToFloat( eTV_FD.Text ),
      StrToFloat( eTV_TMR.Text ),
      rbOnOffPorPaso.Checked,
      StrToFloat(EPotTVdivTG.Text),
      valorCBFuente(CBFuenteIndicePreciosPorCombustible), valorCBString(
      CBBorneIndicePreciosCombustible), CBRestrEMax.Checked, restrEmax,
      StrToFloat( ePagoPorPotencia.text ), strToFloat( ePagoPorEnergia.text ));
    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaGTer_combinado.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaGTer_combinado.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaGTer_combinado.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichaGTer_combinado.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TGTer_combinado);
end;

end.
