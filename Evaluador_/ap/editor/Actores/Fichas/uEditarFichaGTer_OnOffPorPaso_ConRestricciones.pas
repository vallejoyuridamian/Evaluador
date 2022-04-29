unit uEditarFichaGTer_OnOffPorPaso_ConRestricciones;


interface

uses
   {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichasGeneradores, StdCtrls, ExtCtrls, Grids,
  ugter_onoffporpaso_conrestricciones, uFuentesAleatorias, uCosaConNombre,
  ufichasLPD, usalasdejuego, xMatDefs, uverdoc, utilidades, uconstantesSimSEE,
  uOpcionesSimSEEEdit;

resourcestring
  rsPotenciaMinima = 'Potencia mínima[MW]';
  rsPotenciaMaxima = 'Potencia maxima[MW]';
  rsCostoVariablePotenciaMinima = 'Costo variable a potencia mínima[USD/MWh]';
  rsCostoVariable = 'Costo variable[USD/MWh]';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';
  rsCostoDeArranque = 'Costo de arranque[USD]';
  rsCostoDeParada = 'Costo de parada[USD]';
  rsCostoPorPasoOn = 'Costo por paso-On[USD]';
  rsCostoPorPasoOff = 'Costo por paso-Off[USD]';

type
  TEditarFichaGTer_OnOffPorPaso_ConRestricciones = class(TBaseEditoresFichasGeneradores)
    LFIni: TLabel;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    EFIni: TEdit;
    sgFicha: TStringGrid;
    BGuardar: TButton;
    BCancelar: TButton;
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
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    lMinNPasosOn: TLabel;
    lMinNPasosOff: TLabel;
    eMinNPasosOn: TEdit;
    eMinNPasosOff: TEdit;
    CBDecisionOnOff_PorCiclo: TCheckBox;
    CBDecisionOffOn_PorCiclo: TCheckBox;
    procedure EditEnter(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
  protected
    function validarFormulario(): boolean; override;
  private
    Generador: TGTer_OnOffPorPaso_ConRestricciones;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TGTer_OnOffPorPaso_ConRestricciones);
end;

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.BCancelarClick(
  Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.BGuardarClick(
  Sender: TObject);
var
  periodicidad: TPeriodicidad;
  restrEMax: NReal;
begin
  if validarFormulario then
  begin
  {  fAux := TFichaGenSencillo(Generador.lpd.ficha(StrToInt(self.IntAnio.text), StrToInt(self.IntSemana.text)));
  if (fAux = NIL) or (fAux = ficha2) then
     begin          }

    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
    restrEMax := inherited rest(CBRestrEMax, ERestrEMax, MaxNReal);

    ficha := TFichaGTer_OnOffPorPaso_ConRestricciones.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
      StrToFloat(
      self.sgFicha.cells[1, 0]),
      StrToFloat(self.sgFicha.cells[1, 1]),
      StrToFloat(
      self.sgFicha.cells[1, 2]),
      StrToFloat(self.sgFicha.cells[1, 3]),
      valorCBFuente(
      CBFuenteIndicePreciosPorCombustible),
      valorCBString(
      CBBorneIndicePreciosCombustible),
      StrToFloat(self.sgFicha.cells[1, 4]),
      StrToFloat(
      self.sgFicha.Cells[1, 5]),
      CBRestrEMax.Checked, restrEMax,
      StrToInt(eMinNPasosOn.Text),
      StrToInt(eMinNPasosOff.Text),
      CBDecisionOnOff_PorCiclo.Checked,
      CBDecisionOffOn_PorCiclo.Checked,
      StrToFloat(
      self.sgFicha.Cells[1, 6]),
      StrToFloat(self.sgFicha.Cells[1, 7]),
      StrToFloat(
      self.sgFicha.Cells[1, 8]),
      StrToFloat(self.sgFicha.Cells[1, 9]));
    ModalResult := mrOk;
   {     end
  else
       begin
       ShowMessage(mesYaExisteFichaEnFecha);
       end     }
  end;
end;

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.
CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.CBPeriodicidadClick(
  Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.CBRestrEMaxClick(
  Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

constructor TEditarFichaGTer_OnOffPorPaso_ConRestricciones.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaGTer_OnOffPorPaso_ConRestricciones;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TGTer_OnOffPorPaso_ConRestricciones;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaGTer_OnOffPorPaso_ConRestricciones;

    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    self.sgFicha.cells[1, 0] := FloatToStr(fichaAux.PMin);
    self.sgFicha.cells[1, 1] := FloatToStr(fichaAux.PMax);
    self.sgFicha.cells[1, 2] := FloatToStr(fichaAux.cv_min);
    self.sgFicha.cells[1, 3] := FloatToStr(fichaAux.cv);
    self.sgFicha.cells[1, 4] := FloatToStr(fichaAux.disp);
    self.sgFicha.cells[1, 5] := FloatToStr(fichaAux.tRepHoras);
    self.sgFicha.cells[1, 6] := FloatToStr(fichaAux.costoArranque);
    self.sgFicha.cells[1, 7] := FloatToStr(fichaAux.costoParada);
    self.sgFicha.cells[1, 8] := FloatToStr(fichaAux.costoPorPasoOn);
    self.sgFicha.cells[1, 9] := FloatToStr(fichaAux.costoPorPasoOff);

    Self.eMinNPasosOn.Text := IntToStr(fichaAux.minimoNPasosOn);
    Self.eMinNPasosOff.Text := IntToStr(fichaAux.minimoNPasosOff);

    CBDecisionOnOff_PorCiclo.Checked := fichaAux.decisionOnOff_PorCiclo;
    CBDecisionOffOn_PorCiclo.Checked := fichaAux.decisionOffOn_PorCiclo;

    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited setCBFuente(CBFuenteIndicePreciosPorCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.indicePreciosPorCombustible,
      fichaAux.bornePreciosPorCombustible);
  end
  else
  begin
    self.EFIni.Text := '';
    for i := 0 to self.sgFicha.RowCount - 1 do
      self.sgFicha.cells[1, i] := '';
    self.eMinNPasosOn.Text := '1';
    self.eMinNPasosOff.Text := '1';
    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);
  end;
end;

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.FormCloseQuery(
  Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);

  self.sgFicha.cells[0, 0] := rsPotenciaMinima;
  self.sgFicha.cells[0, 1] := rsPotenciaMaxima;
  self.sgFicha.cells[0, 2] := rsCostoVariablePotenciaMinima;
  self.sgFicha.cells[0, 3] := rsCostoVariable;
  self.sgFicha.cells[0, 4] := rsCoeficienteDisponibilidadFortuita;
  self.sgFicha.cells[0, 5] := rsTiempoDeReparacionH;
  self.sgFicha.cells[0, 6] := rsCostoDeArranque;
  self.sgFicha.cells[0, 7] := rsCostoDeParada;
  self.sgFicha.cells[0, 8] := rsCostoPorPasoOn;
  self.sgFicha.cells[0, 9] := rsCostoPorPasoOff;

  utilidades.AutoSizeCol(sgFicha, 0);
end;

procedure TEditarFichaGTer_OnOffPorPaso_ConRestricciones.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

function TEditarFichaGTer_OnOffPorPaso_ConRestricciones.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := inherited validarEditFecha(EFIni) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    inherited validarTablaNReals_(sgFicha) and
    inherited validarEditInt(eMinNPasosOn, 1, MaxInt) and
    inherited validarEditInt(eMinNPasosOff, 1, MaxInt) and
    inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0);
end;

end.
