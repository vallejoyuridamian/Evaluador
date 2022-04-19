unit uEditarFichaHidroDePasada;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, ExtCtrls, Grids, uFichasLPD, uCosaConNombre,
  usalasdejuego, uBaseEditoresFichasGeneradores,
  uSalasDeJuegoParaEditor, uHidroDePasada, uGeneradores,
  uEditarCentralesEncadenadas, utilidades,
  uconstantesSimSEE, uFechas, xMatDefs, uverdoc, uOpcionesSimSEEEdit;

resourcestring
  rsAreaCuenca_ha = 'Area de la cuenca [há]';
  rsCotaDeDescarga = 'Cota de descarga[m]';
  rsCotaDeToma = 'Cota de toma[m]';
  rsCostoVariableAgua = 'Costo variable del agua[USD/Hm3]';
  rsCoeficientesCaudalArogadoCAQE =
    'Coeficientes de afectación del salto por caudal erogado(caQE)';
  rsCoeficientesCaudalArogadoCBQE =
    'Coeficientes de afectación del salto por caudal erogado(cbQE)';
  rsRendimientoPU = 'Rendimiento[p.u.]';
  rsPotenciaMaximaGenerableMW = 'Potencia máxima generable[MW]';
  rsCaudalMaximoTurbinableM3S = 'Caudal máximo turbinable[m3/s]';
  rsFactorDeDisponibilidadPU = 'Factor de disponibilidad[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';

type

  { TEditarFichaHidroDePasada }

  TEditarFichaHidroDePasada = class(TBaseEditoresFichasGeneradores)
    ePagoPorDisponibilidad: TEdit;
    ePagoPorEnergia: TEdit;
    GroupBox4: TGroupBox;
    Label10: TLabel;
    Label9: TLabel;
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
    ERestrEMax_: TEdit;
    BAyuda: TButton;
    Label1: TLabel;
    eSaltoMinimoOperativo: TEdit;
    procedure EditEnter(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BEditarCentralesAguasArribaClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  private
    Generador: THidroDePasada;
    centralesAguasArriba: TListaCentralesAguasArriba;
    centralDescarga: TGeneradorHidraulico;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaHidroDePasada: TEditarFichaHidroDePasada;

implementation

uses SimSEEEditMain, uBaseAltasEditores;

  {$R *.lfm}

constructor TEditarFichaHidroDePasada.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaHidroDePasada;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as THidroDePasada;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaHidroDePasada;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    self.sgFicha.cells[1, 0] := FloatToStr(fichaAux.AreaCuenca_Ha);
    self.sgFicha.cells[1, 1] := FloatToStr(fichaAux.hDescarga);
    self.sgFicha.cells[1, 2] := FloatToStr(fichaAux.hToma);
    self.sgFicha.cells[1, 3] := FloatToStr(fichaAux.cv_agua_USD_Hm3);
    self.sgFicha.cells[1, 4] := FloatToStr(fichaAux.caQE);
    self.sgFicha.cells[1, 5] := FloatToStr(fichaAux.cbQE);
    self.sgFicha.cells[1, 6] := FloatToStr(fichaAux.ren);
    self.sgFicha.cells[1, 7] := FloatToStr(fichaAux.Pmax_Gen);
    self.sgFicha.cells[1, 8] := FloatToStr(fichaAux.QMax_Turb);
    self.sgFicha.cells[1, 9] := FloatToStr(fichaAux.fDispo);
    self.sgFicha.cells[1, 10] := FloatToStr(fichaAux.tRepHoras);

    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax_);
    self.eSaltoMinimoOperativo.Text := FloatToStr(fichaAux.SaltoMinimoOperativo);
    centralDescarga := fichaAux.central_lagoDescarga;
    centralesAguasArriba := rbtEditorSala.Clonar_Y_ResolverReferencias(
      fichaAux.centralesAguasArriba) as TListaCentralesAguasArriba;
    self.ePagoPorDisponibilidad.Text :=
      FloatToStr(fichaAux.PagoPorDisponibilidad_USD_MWh);
    self.ePagoPorEnergia.Text := FloatToStr(fichaAux.PagoPorEnergia_USD_MWh);
    guardado := True;
  end
  else
  begin
    self.EFIni.Text := '';
    centralDescarga := nil;
    for i := 0 to self.sgFicha.RowCount - 1 do
      self.sgFicha.cells[1, i] := '';
    centralesAguasArriba := TListaCentralesAguasArriba.Create(0);
    self.eSaltoMinimoOperativo.Text := '0.1';
    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax_);

    self.ePagoPorDisponibilidad.Text := FloatToStr(0.0);
    self.ePagoPorEnergia.Text := FloatToStr(0.0);
    guardado := False;
  end;
end;

function TEditarFichaHidroDePasada.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := inherited validarEditFecha(EFIni) and
    inherited validarTablaNReals_(sgFicha) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    inherited validarRestriccion(CBRestrEMax, ERestrEMax_, 1, MaxNReal) and
    validarEditFloat(ePagoPorDisponibilidad) and validarEditFloat(ePagoPorEnergia);
end;

procedure TEditarFichaHidroDePasada.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaHidroDePasada.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaHidroDePasada.CambiosForm(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaHidroDePasada.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaHidroDePasada.BEditarCentralesAguasArribaClick(Sender: TObject);
var
  form: TEditarCentralesAguasArriba;
begin
  form := TEditarCentralesAguasArriba.Create(self, Generador,
    centralDescarga, centralesAguasArriba, sala);
  if form.ShowModal = mrOk then
  begin
    centralesAguasArriba.Free;
    centralDescarga := form.DarCentralDescarga;
    centralesAguasArriba := form.darCentralesAguasArriba;
  end;
  form.Free;
end;

procedure TEditarFichaHidroDePasada.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaHidroDePasada.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaHidroDePasada.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);

  self.sgFicha.cells[0, 0] := rsAreaCuenca_ha;
  self.sgFicha.cells[0, 1] := rsCotaDeDescarga;
  self.sgFicha.cells[0, 2] := rsCotaDeToma;
  self.sgFicha.cells[0, 3] := rsCostoVariableAgua;
  self.sgFicha.cells[0, 4] := rsCoeficientesCaudalArogadoCAQE;
  self.sgFicha.cells[0, 5] := rsCoeficientesCaudalArogadoCBQE;
  self.sgFicha.cells[0, 6] := rsRendimientoPU;
  self.sgFicha.cells[0, 7] := rsPotenciaMaximaGenerableMW;
  self.sgFicha.cells[0, 8] := rsCaudalMaximoTurbinableM3S;
  self.sgFicha.cells[0, 9] := rsFactorDeDisponibilidadPU;
  self.sgFicha.cells[0, 10] := rsTiempoDeReparacionH;

  utilidades.AutoSizeCol(sgFicha, 0);
end;


procedure TEditarFichaHidroDePasada.BGuardarClick(Sender: TObject);
var
  periodo: TPeriodicidad;
  restrEMax: NReal;
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

    restrEMax := inherited rest(CBRestrEMax, ERestrEMax_, MaxNReal);

    ficha := TFichaHidroDePasada.Create(
      capa, FSimSEEEdit.StringToFecha(EFIni.Text), periodo,
      StrToFloat(self.sgFicha.cells[1, 0]), // AreaCuenca_ha
      StrToFloat(self.sgFicha.cells[1, 1]), StrToFloat(self.sgFicha.cells[1, 2]),
      StrToFloat(self.sgFicha.cells[1, 3]), centralDescarga,
      centralesAguasArriba, StrToFloat(self.sgFicha.cells[1, 4]),
      StrToFloat(self.sgFicha.cells[1, 5]), StrToFloat(self.sgFicha.cells[1, 6]),
      StrToFloat(self.sgFicha.cells[1, 7]), StrToFloat(self.sgFicha.cells[1, 8]),
      StrToFloat(self.eSaltoMinimoOperativo.Text),
      StrToFloat(self.sgFicha.cells[1, 9]), StrToFloat(self.sgFicha.cells[1, 10]),
      CBRestrEMax.Checked, restrEmax, StrToFloat(self.ePagoPorDisponibilidad.Text),

      StrToFloat(self.ePagoPorEnergia.Text));

    ModalResult := mrOk;
  {     end
  else
       begin
       ShowMessage(mesYaExisteFichaEnFecha);
       end     }
  end;
end;

procedure TEditarFichaHidroDePasada.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax_);
end;

procedure TEditarFichaHidroDePasada.BAyudaClick(Sender: TObject);
begin
  verdoc(self, THidroDePasada);
end;

initialization
end.
