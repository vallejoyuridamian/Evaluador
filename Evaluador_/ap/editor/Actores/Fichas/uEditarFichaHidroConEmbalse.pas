unit uEditarFichaHidroConEmbalse;

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
  utilidades, xMatDefs, uFichasLPD, uHidroConEmbalse, uFechas,
  uConstantesSimSEE, uCosaConNombre,
  usalasdejuego, uSalasDeJuegoParaEditor, uFuentesAleatorias,
  uEditarCentralesEncadenadas, uGeneradores, uverdoc, uOpcionesSimSEEEdit;

resourcestring
  rsCotaMinimaOperacionM = 'Cota mínima operación[m]';
  rsCotaMaximaOperacionM = 'Cota máxima operación[m]';
  rsPuntosCotaVolumenM = 'Puntos cota-volumen h[m]';
  rsPuntosCotaVolumenHm3 = 'Puntos cota-volumen V[Hm3]';
  rsAreaCuenca_ha = 'Área de la cuenca[ha]';
  rsCotaDeLaDescargaSaltoM = 'Cota de la descarga para cálculo del salto[m]';
  rsCoeficientesCaudalArogadoCAQE =
    'Coeficientes de afectación del salto por caudal erogado(caQE)';
  rsCoeficientesCaudalArogadoCBQE =
    'Coeficientes de afectación del salto por caudal erogado(cbQE)';
  rsRendimientoPU = 'Rendimiento[p.u.]';
  rsPotenciaMaximaGenerableMW = 'Potencia máxima generable[MW]';
  rsCaudalMaximoTurbinableM3S = 'Caudal máximo turbinable[m3/s]';
  rsFactorDeDisponibilidadPU = 'Factor de disponibilidad[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';
  rsCaFiltracionM3S = 'Ca filtración[m3/s]';
  rsCbFiltracionM2S = 'Cb filtración[m2/s]';
  rsQaMuySecoM3S = 'Qa muy seco[m3/s]';
  rsCotaMinimaVertimientoM = 'Cota mínima para vertimiento[m]';
  rsCotaMaximaVertimientoM = 'Cota máxima para vertimiento[m]';
  rsCaudalVertidoCotaMaximaM3S = 'Caudal vertido con la cota máxima[m3/s]';

type

  { TEditarFichaHidroConEmbalse }

  TEditarFichaHidroConEmbalse = class(TBaseEditoresFichasGeneradores)
    cbActivar_ControlCrecidaCotaAportes: TCheckBox;
    cbCalcularEvaporacionDelLago: TCheckBox;
    cbCalcularFiltracionLago: TCheckBox;
    CBRestrQTMinFalla: TCheckBox;
    cb_controlarCotaPorDebajoDelObjetivo_opt: TCheckBox;
    cb_ControlarCotaPorEncimaDelObjetivo_opt: TCheckBox;
    cbActivarValorAguaExacto_hObjetivo: TCheckBox;
    CBActivarCtrlCrecida: TCheckBox;
    eControlCrecidasCotaAportes_h: TLabeledEdit;
    eControlCrecidasCotaAportes_QA: TLabeledEdit;
    eControlDeCrecidaCaudalAPleno: TEdit;
    eControlDeCrecidaCaudalInicio: TEdit;
    eControlDeCrecidaCaudalMedio: TEdit;
    ecotaControlCrecida_Medio: TEdit;
    P_Filt: TLabel;
    Porc_Filtrado: TEdit;
    ePagoPorDisponibilidad: TEdit;
    ePagoPorEnergia: TEdit;
    ERestrQTMinFalla: TEdit;
    EUSD_hm3_falla: TEdit;
    GroupBox3: TGroupBox;
    GroupBox5: TGroupBox;
    Label10: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lCotaActivacionControlCrecida1: TLabel;
    LFIni: TLabel;
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
    ERestrEMax: TEdit;
    ERestrQTMin: TEdit;
    BAyuda: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ehObjetivo: TEdit;
    Label2: TLabel;
    eDeltaCVA: TEdit;
    cb_controlarCotaPorDebajoDelObjetivo_sim: TCheckBox;
    cb_ControlarCotaPorEncimaDelObjetivo_sim: TCheckBox;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    ecvl_USD_Hm3_ValorizadoManual: TEdit;
    gbManejoCotaReal: TGroupBox;
    cbTomarDeLaFuente: TCheckBox;
    cbFuente: TComboBox;
    lFuente: TLabel;
    lBorne: TLabel;
    cbBorne: TComboBox;
    cbImponerQTMinPorPoste: TCheckBox;
    lCotaActivacionControlCrecida: TLabel;
    lPenalidadControlCrecida: TLabel;
    ecotaControlCrecida_inicio: TEdit;
    ecotaControlCrecida_pleno: TEdit;
    Label4: TLabel;
    eSaltoMinimoOperativo: TEdit;
    procedure cbCalcularEvaporacionDelLagoChange(Sender: TObject);
    procedure cbCalcularFiltracionLagoChange(Sender: TObject);
    procedure CBActivarCtrlCrecidaClick(Sender: TObject);
    procedure CBRestrQTMinChange(Sender: TObject);
    procedure CBRestrQTMinFallaChange(Sender: TObject);
    procedure CBRestrQTMinFallaClick(Sender: TObject);
    procedure ePagoPorEnergiaChange(Sender: TObject);
    procedure ERestrQTMinFallaChange(Sender: TObject);
    procedure Porc_FiltradoChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure lCotaActivacionControlCrecidaClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure sgFichaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BEditarCentralesAguasArribaClick(Sender: TObject);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure CBRestrQTMinClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure cbTomarDeLaFuenteClick(Sender: TObject);
    procedure cbFuenteChange(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  private
    Generador: THidroConEmbalse;
    centralesAguasArriba: TListaCentralesAguasArriba;
    centralDescarga: TGeneradorHidraulico;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses uBaseAltasEditores, SimSEEEditMain;

{$R *.lfm}

constructor TEditarFichaHidroConEmbalse.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaHidroConEmbalse;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as THidroConEmbalse;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuenteCondicional(cbTomarDeLaFuente, lFuente,
    lBorne, cbFuente, cbBorne, True, False);

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaHidroConEmbalse;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    self.sgFicha.cells[1, 0] := FloatToStr(fichaAux.hmin);
    self.sgFicha.cells[1, 1] := FloatToStr(fichaAux.hmax);
    self.sgFicha.cells[1, 2] := DAOfNRealToStr_(fichaAux.PuntosCotaVolumen_h, 6, 2, ';');
    self.sgFicha.cells[1, 3] := DAOfNRealToStr_(fichaAux.PuntosCotaVolumen_V, 6, 2, ';');
    self.sgFicha.cells[1, 4] := FloatToStr(fichaAux.AreaCuenca_Ha);
    self.sgFicha.cells[1, 5] := FloatToStr(fichaAux.hDescarga);
    self.sgFicha.cells[1, 6] := FloatToStr(fichaAux.caQE);
    self.sgFicha.cells[1, 7] := FloatToStr(fichaAux.cbQE);
    self.sgFicha.cells[1, 8] := FloatToStr(fichaAux.ren);
    self.sgFicha.cells[1, 9] := FloatToStr(fichaAux.Pmax_Gen);
    self.sgFicha.cells[1, 10] := FloatToStr(fichaAux.QMax_Turb);
    self.sgFicha.cells[1, 11] := FloatToStr(fichaAux.fDispo);
    self.sgFicha.cells[1, 12] := FloatToStr(fichaAux.tRepHoras);
    self.sgFicha.cells[1, 13] := FloatToStr(fichaAux.filtracion_Ca);
    self.sgFicha.cells[1, 14] := FloatToStr(fichaAux.filtracion_Cb);
    self.sgFicha.cells[1, 15] := FloatToStr(fichaAux.QaMuySeco);
    self.sgFicha.cells[1, 16] := FloatToStr(fichaAux.cotaMV0);
    self.sgFicha.cells[1, 17] := FloatToStr(fichaAux.cotaMV1);
    self.sgFicha.cells[1, 18] := FloatToStr(fichaAux.QMV1);

    self.eControlCrecidasCotaAportes_h.Text:= DAOfNRealToStr_( fichaAux.PuntosControlCrecidaPorCotaYAportes_h, 6, 2, ';');
    self.eControlCrecidasCotaAportes_QA.Text:= DAOfNRealToStr_( fichaAux.PuntosControlCrecidaPorCotaYAportes_QA, 6, 2, ';');
    self.cbActivar_ControlCrecidaCotaAportes.Checked:= fichaAux.flg_ControlCrecidaPOrCotaYAportes;


    centralDescarga := fichaAux.central_lagoDescarga;
    centralesAguasArriba := rbtEditorSala.Clonar_Y_ResolverReferencias(
      fichaAux.centralesAguasArriba) as TListaCentralesAguasArriba;

    self.cb_controlarCotaPorDebajoDelObjetivo_sim.Checked :=
      fichaAux.flg_controlCotaObjetivoInferior_sim;
    self.cb_ControlarCotaPorEncimaDelObjetivo_sim.Checked :=
      fichaAux.flg_controlCotaObjetivoSuperior_sim;
    self.cb_controlarCotaPorDebajoDelObjetivo_opt.Checked :=
      fichaAux.flg_controlCotaObjetivoInferior_opt;
    self.cb_ControlarCotaPorEncimaDelObjetivo_opt.Checked :=
      fichaAux.flg_controlCotaObjetivoSuperior_opt;

    self.ehObjetivo.Text := FloatToStr(fichaAux.hObjetivo);
    self.eDeltaCVA.Text := FloatToStr(fichaAux.delta_cva_ParaControlDeCota);
    self.cbActivarValorAguaExacto_hObjetivo.Checked:=fichaAux.flg_ValorAguaExacto_hObjetivo;
    self.ecvl_USD_Hm3_ValorizadoManual.Text :=
      FloatToStr(fichaAux.cv_USD_Hm3_ValorizadoManual);
    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited initCBRestriccion(fichaAux.HayRestriccionQTmin, CBRestrQTMin,
      fichaAux.QTmin, ERestrQTMin);
    inherited initCBRestriccion(fichaAux.flg_ErogadoMin_Falla, CBRestrQTMinFalla,
      fichaAux.QErogadoMin_Falla, ERestrQTMinFalla);
    inherited initCBRestriccion(fichaAux.flg_ErogadoMin_Falla, CBRestrQTMinFalla,
      fichaAux.cv_USD_hm3_falla_ErogadoMin, EUSD_hm3_falla);
    cbImponerQTMinPorPoste.Checked := fichaAux.ImponerQminPorPoste;

    cbImponerQTMinPorPoste.Enabled := CBRestrQTMin.Checked or CBRestrQTMinFalla.Checked;

    inherited setCBFuenteCondicional(cbTomarDeLaFuente, lFuente,
      lBorne, cbFuente, cbBorne, True, fichaAux.tomarCotaDeLaFuente,
      fichaAux.fuenteCota, fichaAux.borneCota);
    self.eSaltoMinimoOperativo.Text := FloatToStr(fichaAux.SaltoMinimoOperativo);


    self.CBActivarCtrlCrecida.Checked:= fichaAux.flg_ControlCrecidaPorCota;
    self.ecotaControlCrecida_inicio.Text := FloatToStr(fichaAux.cotaControlCrecida_Inicio);
    self.ecotaControlCrecida_Medio.Text := FloatToStr(fichaAux.cotaControlCrecida_Medio);
    self.ecotaControlCrecida_pleno.Text := FloatToStr(fichaAux.cotaControlCrecida_Pleno);

    self.eControlDeCrecidaCaudalInicio.Text:= FloatToStr( fichaAux.QE_ControlDeCrecidaInicio );
    self.eControlDeCrecidaCaudalMedio.Text:= FloatToStr( fichaAux.QE_ControlDeCrecidaMedio );
    self.eControlDeCrecidaCaudalAPleno.Text:= FloatToStr( fichaAux.QE_ControlDeCrecidaAPleno );

    if CBActivarCtrlCrecida.Checked=false then
    begin
      ecotaControlCrecida_inicio.Enabled:=false;
      ecotaControlCrecida_Medio.Enabled:=false;
      ecotaControlCrecida_pleno.Enabled:=false;
      eControlDeCrecidaCaudalInicio.Enabled:=false;
      eControlDeCrecidaCaudalMedio.Enabled:=false;
      eControlDeCrecidaCaudalAPleno.Enabled:=false;
    end;

    self.cbCalcularEvaporacionDelLago.Checked:= fichaAux.flg_CalcularEvaporacionDelLago;
    self.cbCalcularFiltracionLago.Checked:= fichaAux.flg_CalcularFiltracionDelLago;
    self.Porc_Filtrado.Text:= FloatToStr(fichaAux.PorcentajeFiltracion);

    if cbCalcularFiltracionLago.Checked = false then
    Porc_Filtrado.Enabled:=false;

    self.ePagoPorDisponibilidad.Text :=
      FloatToStr(fichaAux.PagoPorDisponibilidad_USD_MWh);
    self.ePagoPorEnergia.Text := FloatToStr(fichaAux.PagoPorEnergia_USD_MWh);

  end
  else
  begin
    self.EFIni.Text := '';
    centralDescarga := nil;
    for i := 0 to self.sgFicha.RowCount - 1 do
      self.sgFicha.cells[1, i] := '';
    centralesAguasArriba := TListaCentralesAguasArriba.Create( capa );

    self.cb_controlarCotaPorDebajoDelObjetivo_sim.Checked := False;
    self.cb_ControlarCotaPorEncimaDelObjetivo_sim.Checked := False;
    self.cb_controlarCotaPorDebajoDelObjetivo_opt.Checked := False;
    self.cb_ControlarCotaPorEncimaDelObjetivo_opt.Checked := False;

    self.ehObjetivo.Text := FloatToStr(0.00);
    self.eDeltaCVA.Text := FloatToStr(0.00);
    self.ecvl_USD_Hm3_ValorizadoManual.Text := FloatToStr(0.00);
    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);
    inherited initCBRestriccion(False, CBRestrQTMin, 0, ERestrQTMin);
    inherited initCBRestriccion(False, CBRestrQTMinFalla, 0, ERestrQTMinFalla);

    self.eControlCrecidasCotaAportes_h.Text:= FloatToStr(35.5)+'; '+FloatToStr(35.39)+'; '+FloatToStr(35.04) ;
    self.eControlCrecidasCotaAportes_QA.Text:= '1000; 4000; 8000';
    self.cbActivar_ControlCrecidaCotaAportes.Checked:= false;
    self.cbActivarValorAguaExacto_hObjetivo.Checked:=false;

    cbImponerQTMinPorPoste.Checked := False;
    cbImponerQTMinPorPoste.Enabled := False;
    self.esaltoMinimoOperativo.Text := FloatToStr(0.1);


    inherited initCBRestriccion(False, CBActivarCtrlCrecida, 0, ecotaControlCrecida_inicio);
    inherited initCBRestriccion(False, CBActivarCtrlCrecida, 0, ecotaControlCrecida_Medio);
    inherited initCBRestriccion(False, CBActivarCtrlCrecida, 0, ecotaControlCrecida_pleno);
    inherited initCBRestriccion(False, CBActivarCtrlCrecida, 0, eControlDeCrecidaCaudalInicio);
    inherited initCBRestriccion(False, CBActivarCtrlCrecida, 0, eControlDeCrecidaCaudalMedio);
    inherited initCBRestriccion(False, CBActivarCtrlCrecida, 0, eControlDeCrecidaCaudalAPleno);

    self.cbCalcularEvaporacionDelLago.Checked:= true;
    self.cbCalcularFiltracionLago.Checked:= true;

    self.ePagoPorDisponibilidad.Text := FloatToStr(0.0);
    self.ePagoPorEnergia.Text := FloatToStr(0.0);
    self.EUSD_hm3_falla.Text:=FloatToStr(0.0);
    self.Porc_Filtrado.Text:=FloatToStr(0.0);
    self.CBRestrQTMinFalla.Checked:=false;

  end;
  guardado := True;
end;

function TEditarFichaHidroConEmbalse.validarFormulario(): boolean;
var
  res: boolean;
begin
  res := inherited validarFormulario;
  if res and (
  self.cb_controlarCotaPorDebajoDelObjetivo_sim.Checked
  or self.cb_ControlarCotaPorEncimaDelObjetivo_sim.Checked
  or self.cb_controlarCotaPorDebajoDelObjetivo_opt.Checked
  or self.cb_ControlarCotaPorEncimaDelObjetivo_opt.Checked

    ) then
  begin
    res := validarEditFloat(self.ehObjetivo, 0, 1000)// and
      //validarEditFloat(self.eDeltaCVA, 0, 10000000); LD y JFP: Sacamos esta validación  para probar valores de agua negativos
  end;

  if res then
    res := validarEditFloat(self.ecvl_USD_Hm3_ValorizadoManual, -10000000, 10000000);

  if res then
    res := validarEditFecha(EFIni) and
      //validarTablaNReals(sgFicha) and
      inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
      ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
      inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
      inherited validarRestriccion(CBRestrQTMin, ERestrQTMin, 1, MaxNReal) and
      inherited validarCBFuenteCondicional(cbTomarDeLaFuente,
      cbFuente, cbBorne, True) and inherited validarEditFloat(
      eSaltoMinimoOperativo, 0, MaxNReal) and inherited validarEditFloat(
      ecotaControlCrecida_inicio, 0, MaxNReal) and
      validarEditFloat( ePagoPorDisponibilidad ) and validarEditFloat( ePagoPorEnergia) and
      validarEditFloat (Porc_Filtrado) and
      inherited  validarEditFloat(ecotaControlCrecida_pleno, 0, MaxNReal);
  Result := res;
end;

procedure TEditarFichaHidroConEmbalse.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaHidroConEmbalse.cbCalcularFiltracionLagoChange(Sender: TObject);
begin
  inherited CBRestrClick(cbCalcularFiltracionLago, Porc_Filtrado);
  guardado := False;
end;

procedure TEditarFichaHidroConEmbalse.CBActivarCtrlCrecidaClick(Sender: TObject);
begin
  inherited CBRestrClick(CBActivarCtrlCrecida, ecotaControlCrecida_inicio);
  inherited CBRestrClick(CBActivarCtrlCrecida, ecotaControlCrecida_Medio);
  inherited CBRestrClick(CBActivarCtrlCrecida, ecotaControlCrecida_pleno);

  inherited CBRestrClick(CBActivarCtrlCrecida, eControlDeCrecidaCaudalInicio);
  inherited CBRestrClick(CBActivarCtrlCrecida, eControlDeCrecidaCaudalMedio);
  inherited CBRestrClick(CBActivarCtrlCrecida, eControlDeCrecidaCaudalAPleno);
end;

procedure TEditarFichaHidroConEmbalse.CBRestrQTMinChange(Sender: TObject);
begin

end;

procedure TEditarFichaHidroConEmbalse.CBRestrQTMinFallaChange(Sender: TObject);
begin

end;

procedure TEditarFichaHidroConEmbalse.CBRestrQTMinFallaClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrQTMinFalla, ERestrQTMinFalla);
  inherited CBRestrClick(CBRestrQTMinFalla, EUSD_hm3_falla);
  cbImponerQTMinPorPoste.Enabled := CBRestrQTMin.Checked or CBRestrQTMinFalla.Checked;
end;

procedure TEditarFichaHidroConEmbalse.ePagoPorEnergiaChange(Sender: TObject);
begin

end;

procedure TEditarFichaHidroConEmbalse.ERestrQTMinFallaChange(Sender: TObject);
begin

end;

procedure TEditarFichaHidroConEmbalse.Porc_FiltradoChange(Sender: TObject);
begin

end;

procedure TEditarFichaHidroConEmbalse.cbCalcularEvaporacionDelLagoChange(
  Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaHidroConEmbalse.CambiosForm(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaHidroConEmbalse.cbFuenteChange(Sender: TObject);
begin
  inherited cbFuenteChange(Sender, cbBorne);
end;

procedure TEditarFichaHidroConEmbalse.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaHidroConEmbalse.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);

  self.sgFicha.cells[0, 0] := rsCotaMinimaOperacionM;
  self.sgFicha.cells[0, 1] := rsCotaMaximaOperacionM;
  self.sgFicha.cells[0, 2] := rsPuntosCotaVolumenM;
  self.sgFicha.cells[0, 3] := rsPuntosCotaVolumenHm3;
  self.sgFicha.cells[0, 4] := rsAreaCuenca_ha;
  self.sgFicha.cells[0, 5] := rsCotaDeLaDescargaSaltoM;
  self.sgFicha.cells[0, 6] := rsCoeficientesCaudalArogadoCAQE;
  self.sgFicha.cells[0, 7] := rsCoeficientesCaudalArogadoCBQE;
  self.sgFicha.cells[0, 8] := rsRendimientoPU;
  self.sgFicha.cells[0, 9] := rsPotenciaMaximaGenerableMW;
  self.sgFicha.cells[0, 10] := rsCaudalMaximoTurbinableM3S;
  self.sgFicha.cells[0, 11] := rsFactorDeDisponibilidadPU;
  self.sgFicha.cells[0, 12] := rsTiempoDeReparacionH;
  self.sgFicha.cells[0, 13] := rsCaFiltracionM3S;
  self.sgFicha.cells[0, 14] := rsCbFiltracionM2S;
  self.sgFicha.cells[0, 15] := rsQaMuySecoM3S;
  self.sgFicha.cells[0, 16] := rsCotaMinimaVertimientoM;
  self.sgFicha.cells[0, 17] := rsCotaMaximaVertimientoM;
  self.sgFicha.cells[0, 18] := rsCaudalVertidoCotaMaximaM3S;

  utilidades.AutoSizeCol(sgFicha, 0);
  sgFicha.ColWidths[1]:= 90;
  sgFicha.Width:=sgFicha.ColWidths[0]+sgFicha.ColWidths[1]+10 ;
  (*
  utilidades.AutosizeTable(self, sgFicha, maxAnchoTablaEnorme,
    maxAlturaTablaMuyGrande, TSimSEEEditOptions.getInstance.
    deshabilitarScrollHorizontalEnListados);
    *)
end;

procedure TEditarFichaHidroConEmbalse.lCotaActivacionControlCrecidaClick(
  Sender: TObject);
begin

end;


procedure TEditarFichaHidroConEmbalse.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, Acol, ARow, Value);
end;

procedure TEditarFichaHidroConEmbalse.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaHidroConEmbalse.sgFichaMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
var
  col, fila: integer;
begin
  TStringGrid(Sender).MouseToCell(x, y, col, fila);
  if (fila = 5) or (fila = 6) then
  begin
    TStringGrid(Sender).Hint := 'dh(QE) = caQE* QE + cbQE* QE^2';
    TStringGrid(Sender).ShowHint := True;
  end
  else if (fila = 12) or (fila = 13) then
  begin
    TStringGrid(Sender).Hint :=
      'Filtración(h)[m^3/s] = Ca_Filtración + Cb_Filtración * h';
    TStringGrid(Sender).ShowHint := True;
  end
  else
    TStringGrid(Sender).ShowHint := False;
end;

procedure TEditarFichaHidroConEmbalse.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaHidroConEmbalse.BGuardarClick(Sender: TObject);
var
  periodo: TPeriodicidad;
  restrEmax, restrQTMin,restrQTMinFalla,restrQTMinFalla_USD_hm3: NReal;
  tomarCotaDeLaFuente: boolean;
  fuente: TFuenteAleatoria;
  borne: string;
begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodo := nil
    else
      periodo := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
        EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

    restrEmax := inherited rest(CBRestrEMax, ERestrEMax, MaxNReal);
    restrQTMin := inherited rest(CBRestrQTMin, ERestrQTMin, 0);
    restrQTMinFalla := inherited rest(CBRestrQTMinFalla, ERestrQTMinFalla, 0);
    restrQTMinFalla_USD_hm3 := inherited rest(CBRestrQTMinFalla, EUSD_hm3_falla, 0);

    valoresCBFuenteCondicional(cbTomarDeLaFuente, cbFuente, cbBorne,
      True, tomarCotaDeLaFuente, fuente, borne);



    ficha := TFichaHidroConEmbalse.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodo,
      StrToFloat(self.sgFicha.cells[1, 0]), StrToFloat(self.sgFicha.cells[1, 1]),
      strToDAOfNReal_(self.sgFicha.cells[1, 2], ';'), strToDAOfNReal_(
      self.sgFicha.cells[1, 3], ';'),
      STRToFloat(self.sgFicha.cells[1, 4]), // AreaCuenca_ha
      STRToFloat(self.sgFicha.cells[1, 5]),
      centralDescarga, centralesAguasArriba,
      StrToFloat(self.sgFicha.cells[1, 6]),
      StrToFloat(self.sgFicha.cells[1, 7]),
      StrToFloat(self.sgFicha.cells[1, 8]),
      StrToFloat(self.sgFicha.cells[1, 9]),
      StrToFloat(self.sgFicha.cells[1, 10]),
      StrToFloat(self.sgFicha.cells[1, 11]),
      StrToFloat(self.sgFicha.Cells[1, 12]),
      StrToFloat(self.sgFicha.cells[1, 13]),
      StrToFloat(self.sgFicha.cells[1, 14]),
      StrToFloat(self.sgFicha.cells[1, 15]),
      StrToFloat(self.sgFicha.cells[1, 16]),
      StrToFloat(self.sgFicha.cells[1, 17]),
      StrToFloat(self.sgFicha.cells[1, 18]),
      StrToFloat( self.eControlDeCrecidaCaudalInicio.Text ),
      StrToFloat( self.eControlDeCrecidaCaudalMedio.Text ),
      StrToFloat( self.eControlDeCrecidaCaudalAPleno.Text ),
      CBRestrEMax.Checked, restrEmax, CBRestrQTMin.Checked, restrQTMin,

      strToDAOfNReal_( self.eControlCrecidasCotaAportes_h.Text, ';'),
      strToDAOfNReal_( self.eControlCrecidasCotaAportes_QA.Text, ';'),
      self.cbActivar_ControlCrecidaCotaAportes.Checked,

      self.CBActivarCtrlCrecida.Checked,

      cbImponerQTMinPorPoste.Checked,
      self.cb_controlarCotaPorDebajoDelObjetivo_sim.Checked,
      self.cb_ControlarCotaPorEncimaDelObjetivo_sim.Checked,
      self.cb_controlarCotaPorDebajoDelObjetivo_opt.Checked,
      self.cb_ControlarCotaPorEncimaDelObjetivo_opt.Checked,
      self.cbActivarValorAguaExacto_hObjetivo.Checked,
      StrToFloat(self.ehObjetivo.Text), StrToFloat(self.eDeltaCVA.Text),
      StrToFloat(self.ecvl_USD_Hm3_ValorizadoManual.Text),
      tomarCotaDeLaFuente, fuente, borne, StrToFloat(eSaltoMinimoOperativo.Text),
      StrToFloat(ecotaControlCrecida_inicio.Text),
      StrToFloat(ecotaControlCrecida_Medio.Text),
      StrToFloat(ecotaControlCrecida_pleno.Text),
      cbCalcularEvaporacionDelLago.Checked,
      cbCalcularFiltracionLago.Checked,
      StrToFloat(self.Porc_Filtrado.Text),
      StrToFloat(self.ePagoPorDisponibilidad.Text),
      StrToFloat(self.ePagoPorEnergia.Text),
      restrQTMinFalla,
      restrQTMinFalla_USD_hm3,CBRestrQTMinFalla.Checked);

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaHidroConEmbalse.BEditarCentralesAguasArribaClick(
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

procedure TEditarFichaHidroConEmbalse.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichaHidroConEmbalse.CBRestrQTMinClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrQTMin, ERestrQTMin);
  cbImponerQTMinPorPoste.Enabled := CBRestrQTMin.Checked or CBRestrQTMinFalla.Checked;
end;

procedure TEditarFichaHidroConEmbalse.cbTomarDeLaFuenteClick(Sender: TObject);
begin
  inherited cbFuenteCondicionalClick(cbTomarDeLaFuente, lFuente,
    lBorne, cbFuente, cbBorne, True);
end;

procedure TEditarFichaHidroConEmbalse.BAyudaClick(Sender: TObject);
begin
  verdoc(self, THidroConEmbalse);
end;

initialization
end.
