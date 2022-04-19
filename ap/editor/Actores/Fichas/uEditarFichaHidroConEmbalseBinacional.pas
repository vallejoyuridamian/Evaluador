unit uEditarFichaHidroConEmbalseBinacional;

interface

uses
   {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, uBaseEditoresFichas,
  uBaseEditoresFichasGeneradores,
  utilidades, xMatDefs, uFichasLPD, uHidroConEmbalseBinacional, uFechas,
  uconstantesSimSEE,
  uCosaConNombre, usalasdejuego, uSalasDeJuegoParaEditor, uFuentesAleatorias,
  uEditarCentralesEncadenadas, uGeneradores, uverdoc, uOpcionesSimSEEEdit,
  uopencalcexportimport,
  uopencalc,
  uEditarGeneracionDelOtroPaisHidroBinacional;

resourcestring
  mesEditarGeneracionDelOtroPais =
    'Debe editar la generación del otro país antes de continuar';
  rsCotaMinimaOperacionM = 'Cota mínima operación[m]';
  rsCotaMaximaOperacionM = 'Cota máxima operación[m]';
  rsPuntosCotaVolumenM = 'Puntos cota-volumen h[m]';
  rsPuntosCotaVolumenHm3 = 'Puntos cota-volumen V[Hm^3]';
  rsCotaDeLaDescargaSaltoM = 'Cota de la descarga para cálculo del salto[m]';
  rsCoeficientesCaudalArogadoCAQE =
    'Coeficientes de afectación del salto por caudal erogado(caQE)';
  rsCoeficientesCaudalArogadoCBQE =
    'Coeficientes de afectación del salto por caudal erogado(cbQE)';
  rsRendimientoPU = 'Rendimiento[p.u.]';
  rsPotenciaMaximaGenerableMW = 'Potencia máxima generable[MW]';
  rsCaudalMaximoTurbinableM3S = 'Caudal máximo turbinable[m^3/s]';
  rsFactorDeDisponibilidadPU = 'Factor de disponibilidad[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';
  rsCaFiltracionM3S = 'Ca filtración[m^3/s]';
  rsCbFiltracionM2S = 'Cb filtración[m^2/s]';
  rsQaMuySecoM3S = 'Qa muy seco[m^3/s]';
  rsCotaMinimaVertimientoM = 'Cota mínima para vertimiento[m]';
  rsCotaMaximaVertimientoM = 'Cota máxima para vertimiento[m]';
  rsCaudalVertidoCotaMaximaM3S = 'Caudal vertido con la cota máxima[m^3/s]';

type

  { TEditarFichaHidroConEmbalseBinacional }

  TEditarFichaHidroConEmbalseBinacional = class(TBaseEditoresFichasGeneradores)
    CBActivarCtrlCrecida: TCheckBox;
    cbCalcularEvaporacionDelLago: TCheckBox;
    cbCalcularFiltracionLago: TCheckBox;
    cbActivar_ControlCrecidaCotaAportes: TCheckBox;
    eControlCrecidasCotaAportes_QA: TLabeledEdit;
    eControlDeCrecidaCaudalApleno: TEdit;
    eControlDeCrecidaCaudalInicio: TEdit;
    eControlDeCrecidaCaudalMedio: TEdit;
    ecotaControlCrecida_Medio: TEdit;
    ePagoPorDisponibilidad: TEdit;
    ePagoPorEnergia: TEdit;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    eControlCrecidasCotaAportes_h: TLabeledEdit;
    eRestrQTMinUY: TLabeledEdit;
    lCotaActivacionControlCrecida: TLabel;
    lCotaActivacionControlCrecida1: TLabel;
    LFIni: TLabel;
    lPenalidadControlCrecida2: TLabel;
    sgFicha: TStringGrid;
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
    BEditarCentralesAguasArriba: TButton;
    CBRestrEMax: TCheckBox;
    CBRestrQTMin: TCheckBox;
    BAyuda: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    ehObjetivo: TEdit;
    eDeltaCVA: TEdit;
    cb_controlarCotaPorDebajoDelObjetivo: TCheckBox;
    cb_ControlarCotaPorEncimaDelObjetivo: TCheckBox;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    ecvl_USD_Hm3_ValorizadoManual: TEdit;
    ERestrEMax: TEdit;
    ERestrQTMin: TEdit;
    cbImponerQTMinPorPoste: TCheckBox;
    lQE_CEE: TLabel;
    eQE_CEE: TEdit;
    eHVistaMin_: TEdit;
    lHVistaMin: TLabel;
    BEditarGeneracionDelOtroPais: TButton;
    eCotaControlCrecida_inicio: TEdit;
    eCotaControlCrecida_pleno: TEdit;
    Label4: TLabel;
    eSaltoMinimoOperativo: TEdit;
    procedure cbCalcularEvaporacionDelLagoChange(Sender: TObject);
    procedure cbCalcularFiltracionLagoChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure GroupBox2Click(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BCancelarClick(Sender: TObject);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure CBRestrQTMinClick(Sender: TObject);
    procedure BEditarCentralesAguasArribaClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure BEditarGeneracionDelOtroPaisClick(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
    function validarGeneracionDelOtroPais: boolean;
  private
    Generador: THidroConEmbalseBinacional;
    centralesAguasArriba: TListaCentralesAguasArriba;
    centralDescarga: TGeneradorHidraulico;
    generacionOtroPais: TDAofNReal;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

procedure TEditarFichaHidroConEmbalseBinacional.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(Self, THidroConEmbalseBinacional);
end;

procedure TEditarFichaHidroConEmbalseBinacional.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaHidroConEmbalseBinacional.BEditarCentralesAguasArribaClick(
  Sender: TObject);
var
  form: TEditarCentralesAguasArriba;
begin
  form := TEditarCentralesAguasArriba.Create(self, Generador,
    centralDescarga, centralesAguasArriba, sala);
  if form.ShowModal = mrOk then
  begin
    centralesAguasArriba.Free;
    self.centralDescarga := form.DarCentralDescarga;
    centralesAguasArriba := form.darCentralesAguasArriba;
  end;
  form.Free;
end;

procedure TEditarFichaHidroConEmbalseBinacional.BEditarGeneracionDelOtroPaisClick(
  Sender: TObject);
var
  formEditarGeneracion: TEditarGeneracionDelOtroPaisHidroBinacional;
begin
  formEditarGeneracion := TEditarGeneracionDelOtroPaisHidroBinacional.Create(self,
    generacionOtroPais);
  if formEditarGeneracion.ShowModal = mrOk then
  begin
    generacionOtroPais := formEditarGeneracion.getGeneracion;
  end;
  formEditarGeneracion.Free;
end;

procedure TEditarFichaHidroConEmbalseBinacional.BGuardarClick(Sender: TObject);
var
  periodo: TPeriodicidad;
  restrEmax, restrQTMin: NReal;
begin
  if validarFormulario then
  begin
    {  fAux := TFichaGenSencillo(Generador.lpd.ficha(StrToInt(self.IntAnio.text), StrToInt(self.IntSemana.text)));
    if (fAux = NIL) or (fAux = ficha2) then
    begin          }
    if not CBPeriodicidad.Checked then
      periodo := nil
    else
      periodo := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
        EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

    restrEmax := inherited rest(CBRestrEMax, ERestrEMax, MaxNReal);
    restrQTMin := inherited rest(CBRestrQTMin, ERestrQTMin, 0);

    ficha := TFichaHidroConEmbalseBinacional.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodo,
      StrToFloat(self.sgFicha.cells[1, 0]), StrToFloat(self.sgFicha.cells[1, 1]),
      strToDAOfNReal_(self.sgFicha.cells[1, 2], ';'), strToDAOfNReal_(
      self.sgFicha.cells[1, 3], ';'), STRToFloat(self.sgFicha.cells[1, 4]),
      centralDescarga, centralesAguasArriba, StrToFloat(self.sgFicha.cells[1, 5]),
      StrToFloat(self.sgFicha.cells[1, 6]), StrToFloat(self.sgFicha.cells[1, 7]),
      StrToFloat(self.sgFicha.cells[1, 8]), StrToFloat(self.sgFicha.cells[1, 9]),
      StrToFloat(self.sgFicha.cells[1, 10]), StrToFloat(self.sgFicha.Cells[1, 11]),
      StrToFloat(self.sgFicha.cells[1, 12]), StrToFloat(self.sgFicha.cells[1, 13]),
      StrToFloat(self.sgFicha.cells[1, 14]), StrToFloat(self.sgFicha.cells[1, 15]),
      StrToFloat(self.sgFicha.cells[1, 16]), StrToFloat(self.sgFicha.cells[1, 17]),
      CBRestrEMax.Checked, restrEmax, CBRestrQTMin.Checked, restrQTMin,
      cbImponerQTMinPorPoste.Checked,
      self.cb_controlarCotaPorDebajoDelObjetivo.Checked,
      self.cb_ControlarCotaPorEncimaDelObjetivo.Checked,
      StrToFloat(self.ehObjetivo.Text), StrToFloat(self.eDeltaCVA.Text),
      StrToFloat(self.ecvl_USD_Hm3_ValorizadoManual.Text), generacionOtroPais,
      StrToFloat(eQE_CEE.Text), StrToFloat(eHVistaMin_.Text),
      StrToFloat(eSaltoMinimoOperativo.Text),
      StrToFloat(eCotaControlCrecida_inicio.Text),StrToFloat(ecotaControlCrecida_Medio.Text),
      StrToFloat(eCotaControlCrecida_pleno.Text),
      StrToFloat(eControlDeCrecidaCaudalInicio.Text),StrToFloat(eControlDeCrecidaCaudalMedio.Text),
      StrToFloat(eControlDeCrecidaCaudalApleno.Text),
      cbCalcularEvaporacionDelLago.Checked, cbCalcularFiltracionLago.Checked,
      StrToFloat(self.ePagoPorDisponibilidad.Text),
      StrToFloat(self.ePagoPorEnergia.Text),strToDAOfNReal_( self.eControlCrecidasCotaAportes_h.Text, ';'),
      strToDAOfNReal_( self.eControlCrecidasCotaAportes_QA.Text, ';'),
      self.cbActivar_ControlCrecidaCotaAportes.Checked,self.CBActivarCtrlCrecida.Checked,StrToFloat(eRestrQTMinUY.Text));

    ModalResult := mrOk;
    {     end
    else
         begin
         ShowMessage(mesYaExisteFichaEnFecha);
         end     }
  end;
end;

procedure TEditarFichaHidroConEmbalseBinacional.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarFichaHidroConEmbalseBinacional.GroupBox2Click(Sender: TObject);
begin

end;

procedure TEditarFichaHidroConEmbalseBinacional.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaHidroConEmbalseBinacional.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichaHidroConEmbalseBinacional.CBRestrQTMinClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrQTMin, ERestrQTMin);
  cbImponerQTMinPorPoste.Enabled := CBRestrQTMin.Checked;
end;

constructor TEditarFichaHidroConEmbalseBinacional.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaHidroConEmbalseBinacional;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as THidroConEmbalseBinacional;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);


  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaHidroConEmbalseBinacional;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    self.sgFicha.cells[1, 0] := FloatToStr(fichaAux.hmin);
    self.sgFicha.cells[1, 1] := FloatToStr(fichaAux.hmax);
    self.sgFicha.cells[1, 2] := DAOfNRealToStr_(fichaAux.PuntosCotaVolumen_h, 6, 2, ';');
    self.sgFicha.cells[1, 3] := DAOfNRealToStr_(fichaAux.PuntosCotaVolumen_V, 6, 2, ';');
    self.sgFicha.cells[1, 4] := FloatToStr(fichaAux.hDescarga);
    self.sgFicha.cells[1, 5] := FloatToStr(fichaAux.caQE);
    self.sgFicha.cells[1, 6] := FloatToStr(fichaAux.cbQE);
    self.sgFicha.cells[1, 7] := FloatToStr(fichaAux.ren);
    self.sgFicha.cells[1, 8] := FloatToStr(fichaAux.Pmax_Gen);
    self.sgFicha.cells[1, 9] := FloatToStr(fichaAux.QMax_Turb);
    self.sgFicha.cells[1, 10] := FloatToStr(fichaAux.fDispo);
    self.sgFicha.cells[1, 11] := FloatToStr(fichaAux.tRepHoras);
    self.sgFicha.cells[1, 12] := FloatToStr(fichaAux.filtracion_Ca);
    self.sgFicha.cells[1, 13] := FloatToStr(fichaAux.filtracion_Cb);
    self.sgFicha.cells[1, 14] := FloatToStr(fichaAux.QaMuySeco);
    self.sgFicha.cells[1, 15] := FloatToStr(fichaAux.cotaMV0);
    self.sgFicha.cells[1, 16] := FloatToStr(fichaAux.cotaMV1);
    self.sgFicha.cells[1, 17] := FloatToStr(fichaAux.QMV1);

    self.eControlCrecidasCotaAportes_h.Text:= DAOfNRealToStr_( fichaAux.PuntosControlCrecidaPorCotaYAportes_h, 6, 2, ';');
    self.eControlCrecidasCotaAportes_QA.Text:= DAOfNRealToStr_( fichaAux.PuntosControlCrecidaPorCotaYAportes_QA, 6, 2, ';');
    self.cbActivar_ControlCrecidaCotaAportes.Checked:= fichaAux.flg_ControlCrecidaPOrCotaYAportes;

    centralDescarga := fichaAux.central_lagoDescarga;
    centralesAguasArriba := rbtEditorSala.Clonar_Y_ResolverReferencias(fichaAux.centralesAguasArriba) as TListaCentralesAguasArriba;

    self.cb_controlarCotaPorDebajoDelObjetivo.Checked :=
      fichaAux.flg_controlCotaObjetivoInferior;
    self.cb_ControlarCotaPorEncimaDelObjetivo.Checked :=
      fichaAux.flg_controlCotaObjetivoSuperior;
    self.ehObjetivo.Text := FloatToStr(fichaAux.hObjetivo);
    self.eDeltaCVA.Text := FloatToStr(fichaAux.delta_cva_ParaControlDeCota);
    self.ecvl_USD_Hm3_ValorizadoManual.Text :=
      FloatToStr(fichaAux.cv_USD_Hm3_ValorizadoManual);
    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited initCBRestriccion(fichaAux.HayRestriccionQTmin, CBRestrQTMin,
      fichaAux.QTmin, ERestrQTMin);
    cbImponerQTMinPorPoste.Checked := fichaAux.ImponerQminPorPoste;
    cbImponerQTMinPorPoste.Enabled := CBRestrQTMin.Checked;

    Self.eQE_CEE.Text := FloatToStr(fichaAux.QE_CEE);
    Self.eHVistaMin_.Text := FloatToStr(fichaAux.hVistaMin);

    self.generacionOtroPais := copy(fichaAux.P_AG, 0, length(fichaAux.P_AG));

    self.eSaltoMinimoOperativo.Text := FloatToStr(fichaAux.saltoMinimoOperativo);

    self.ecotaControlCrecida_inicio.Text :=FloatToStr(fichaAux.cotaControlCrecida_inicio);
    self.ecotaControlCrecida_Medio.Text :=FloatToStr(fichaAux.cotaControlCrecida_Medio);
    self.ecotaControlCrecida_pleno.Text := FloatToStr(fichaAux.cotaControlCrecida_pleno);

    self.eControlDeCrecidaCaudalInicio.Text:=FloatToStr(fichaAux.QE_ControlDeCrecidaInicio);
    self.eControlDeCrecidaCaudalMedio.Text:=FloatToStr(fichaAux.QE_ControlDeCrecidaMedio);
    self.eControlDeCrecidaCaudalApleno.Text:=FloatToStr(fichaAux.QE_ControlDeCrecidaAPleno);

    self.cbCalcularEvaporacionDelLago.Checked := fichaAux.flg_CalcularEvaporacionDelLago;
    self.cbCalcularFiltracionLago.Checked := fichaAux.flg_CalcularFiltracionDelLago;
    self.ePagoPorDisponibilidad.Text :=
      FloatToStr(fichaAux.PagoPorDisponibilidad_USD_MWh);
    self.ePagoPorEnergia.Text := FloatToStr(fichaAux.PagoPorEnergia_USD_MWh);
    self.eRestrQTMinUY.Text:=FloatToStr(fichaAux.QTMinUY);
    self.CBActivarCtrlCrecida.Checked:=fichaAux.flg_ControlCrecidaPorCota;
  end
  else
  begin
    self.EFIni.Text := '';
    centralDescarga := nil;
    for i := 0 to self.sgFicha.RowCount - 1 do
      self.sgFicha.cells[1, i] := '';
    centralesAguasArriba := TListaCentralesAguasArriba.Create(0);

    self.cb_controlarCotaPorDebajoDelObjetivo.Checked := False;
    self.cb_ControlarCotaPorEncimaDelObjetivo.Checked := False;
    self.ehObjetivo.Text := '0.00';
    self.eDeltaCVA.Text := '0.00';
    self.ecvl_USD_Hm3_ValorizadoManual.Text := '0.00';
    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);
    inherited initCBRestriccion(False, CBRestrQTMin, 0, ERestrQTMin);
    cbImponerQTMinPorPoste.Checked := False;
    cbImponerQTMinPorPoste.Enabled := False;
    Self.eQE_CEE.Text := '';
    Self.eHVistaMin_.Text := '';
    generacionOtroPais := nil;
    self.eSaltoMinimoOperativo.Text := '0.1';
    self.ecotaControlCrecida_inicio.Text := '';
    self.ecotaControlCrecida_Medio.Text := '';
    self.ecotaControlCrecida_pleno.Text := '';
    self.eControlDeCrecidaCaudalInicio.Text:='';
    self.eControlDeCrecidaCaudalMedio.Text:='';
    self.eControlDeCrecidaCaudalApleno.Text:='';
    self.cbCalcularEvaporacionDelLago.Checked := True;
    self.cbCalcularFiltracionLago.Checked := True;

    self.ePagoPorDisponibilidad.Text := FloatToStr(0.0);
    self.ePagoPorEnergia.Text := FloatToStr(0.0);

    self.eControlCrecidasCotaAportes_h.Text:= FloatToStr(35.5)+'; '+FloatToStr(35.39)+'; '+FloatToStr(35.04) ;
    self.eControlCrecidasCotaAportes_QA.Text:= '1000; 4000; 8000';
    self.cbActivar_ControlCrecidaCotaAportes.Checked:= false;
    self.eRestrQTMinUY.Text:=FloatToStr(300);
    self.CBActivarCtrlCrecida.Checked:=false;
  end;
  guardado := True;
end;

function TEditarFichaHidroConEmbalseBinacional.validarFormulario: boolean;
var
  res: boolean;
begin
  res := inherited validarFormulario;
  if res and ((self.cb_controlarCotaPorDebajoDelObjetivo.Checked) or
    (self.cb_ControlarCotaPorEncimaDelObjetivo.Checked)) then
  begin
    res := validarEditFloat(self.ehObjetivo, 0, 1000) and
      validarEditFloat(self.eDeltaCVA, 0, 1000000);
  end;

  if res then
    res := validarEditFloat(self.ecvl_USD_Hm3_ValorizadoManual, -1000000, 1000000);

  if res then
    res := validarEditFecha(EFIni) and
      //            validarTablaNReals(sgFicha) and
      inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
      ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
      inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
      inherited validarRestriccion(CBRestrQTMin, ERestrQTMin, 1, MaxNReal) and
      inherited validarEditFloat(eQE_CEE, 0.01, MaxNReal) and
      inherited validarEditFloat(eHVistaMin_, 0, MaxNReal) and
      validarGeneracionDelOtroPais and inherited validarEditFloat(
      self.eSaltoMinimoOperativo, 0, MaxNReal) and
      inherited  validarEditFloat(ecotaControlCrecida_inicio, 0, MaxNReal) and
      inherited validarEditFloat(ecotaControlCrecida_pleno, 0, MaxNReal)
      and  validarEditFloat( ePagoPorDisponibilidad ) and validarEditFloat( ePagoPorEnergia);
  Result := res;
end;

function TEditarFichaHidroConEmbalseBinacional.validarGeneracionDelOtroPais: boolean;
begin
  if generacionOtroPais <> nil then
    Result := True
  else
  begin
    ShowMessage(mesEditarGeneracionDelOtroPais);
    BEditarGeneracionDelOtroPais.SetFocus;
    Result := False;
  end;
end;

procedure TEditarFichaHidroConEmbalseBinacional.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaHidroConEmbalseBinacional.cbCalcularEvaporacionDelLagoChange
  (Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaHidroConEmbalseBinacional.cbCalcularFiltracionLagoChange(
  Sender: TObject);
begin
  guardado := False;
end;


procedure TEditarFichaHidroConEmbalseBinacional.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaHidroConEmbalseBinacional.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);

  self.sgFicha.cells[0, 0] := rsCotaMinimaOperacionM;
  self.sgFicha.cells[0, 1] := rsCotaMaximaOperacionM;
  self.sgFicha.cells[0, 2] := rsPuntosCotaVolumenM;
  self.sgFicha.cells[0, 3] := rsPuntosCotaVolumenHm3;
  self.sgFicha.cells[0, 4] := rsCotaDeLaDescargaSaltoM;
  self.sgFicha.cells[0, 5] := rsCoeficientesCaudalArogadoCAQE;
  self.sgFicha.cells[0, 6] := rsCoeficientesCaudalArogadoCBQE;
  self.sgFicha.cells[0, 7] := rsRendimientoPU;
  self.sgFicha.cells[0, 8] := rsPotenciaMaximaGenerableMW;
  self.sgFicha.cells[0, 9] := rsCaudalMaximoTurbinableM3S;
  self.sgFicha.cells[0, 10] := rsFactorDeDisponibilidadPU;
  self.sgFicha.cells[0, 11] := rsTiempoDeReparacionH;
  self.sgFicha.cells[0, 12] := rsCaFiltracionM3S;
  self.sgFicha.cells[0, 13] := rsCbFiltracionM2S;
  self.sgFicha.cells[0, 14] := rsQaMuySecoM3S;
  self.sgFicha.cells[0, 15] := rsCotaMinimaVertimientoM;
  self.sgFicha.cells[0, 16] := rsCotaMaximaVertimientoM;
  self.sgFicha.cells[0, 17] := rsCaudalVertidoCotaMaximaM3S;

  utilidades.AutoSizeCol(sgFicha, 0);
end;


procedure TEditarFichaHidroConEmbalseBinacional.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, Acol, ARow, Value);
end;

initialization
end.
