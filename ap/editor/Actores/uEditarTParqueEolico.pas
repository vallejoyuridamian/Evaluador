unit uEditarTParqueEolico;

{$MODE Delphi}

interface

uses
{$IFDEF FPC-LCL}
  LResources,
{$ENDIF}
{$IFDEF WINDOWS}
Windows,
{$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uopencalcexportimport,
  uEditarFVectR,
  uFuncionesReales,
  uConstantesSimSEE,
  xMatDefs,
  uParqueEolico;

resourcestring
  mesDebeEditarLaCurvaDeVelP =
    'Debe editar la curva Velocidad-Potencia para poder guardar el generador';
  mesDebeIngresarUnaVelocidadMinV =
    'Debe ingresar una velocidad mínima de viento para generación para continuar';
  mesDebeIngresarUnaVelocidadMaxV =
    'Debe ingresar una Velocidad máxima de viento para generación para continuar';

type

  { TEditarTParqueEolico }

  TEditarTParqueEolico = class(TBaseEditoresActores)
    cbCleanDevelopmentMechanism: TCheckBox;
    cbLowCostMustRun: TCheckBox;
    cbRestarParaPostizar: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    eTMR: TLabeledEdit;
    ePagoPorEnergiaDisponible: TEdit;
    eFacInterferencias: TLabeledEdit;
    eVelMin: TLabeledEdit;
    eVelMax: TLabeledEdit;
    eTonCO2xMWh: TEdit;
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    Label11: TLabel;
    eFD: TLabeledEdit;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFuenteDeViento: TLabel;
    LBorne: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    Panel1: TPanel;
    CBFuente: TComboBox;
    CBBorne: TComboBox;
    BEditarCurvaVP: TButton;
    BEditorDeUnidades: TButton;
    BAyuda: TButton;
    sgFSpeedUp: TStringGrid;
    BImportar_ods: TButton;
    BExportar_ods: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ePagoPorEnergiaEntregada: TEdit;
    Label3: TLabel;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure BExportar_odsClick(Sender: TObject);
    procedure BImportar_odsClick(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
    procedure CBBorneChange(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BEditarCurvaVPClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
  private
    curva: TFVectR;

    function validarCurva: boolean;
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;

{$R *.lfm}

constructor TEditarTParqueEolico.Create(AOwner: TComponent; sala: TSalaDeJuego;
  tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TParqueEolico;
  i: integer;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);
  inherited inicializarCBFuenteHorarias_MonoBorne(CBFuente, CBBorne);


  sgFSpeedUp.Cells[0, 0] := 'Mes';
  sgFSpeedUp.Cells[0, 1] := 'Fac.Vel.';
  for i := 1 to 12 do
    sgFSpeedUp.Cells[i, 0] := ShortMonthNames[i];

  curva := nil;

  if cosaConNombre <> nil then
  begin
    actor := TParqueEolico(cosaConNombre);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);

    eFD.text := FloatToStrF(actor.fdisp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    eTMR.text := FloatToStrF(actor.tRepHoras, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    eFacInterferencias.text := FloatToStrF(actor.fPerdidasInterferencias,
      ffGeneral, CF_PRECISION, CF_DECIMALES);

    eVelMin.Text := FloatToStrF(actor.CurvaVP.xmin, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    eVelMax.Text := FloatToStrF(actor.CurvaVP.xmax, ffGeneral,
      CF_PRECISION, CF_DECIMALES);

    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    for i := 1 to 12 do
      sgFSpeedUp.Cells[i, 1] :=
        FloatToStrF(actor.fSpeedUpMes[i - 1], ffGeneral, CF_PRECISION, CF_DECIMALES);
    setCBFuente(CBFuente, CBBorne, actor.fuenteDeViento, actor.nombreBorne);
    self.curva := actor.CurvaVP.Create_Clone( nil, 0 ) as TFVectR;
    self.ePagoPorEnergiaEntregada.Text :=
      FloatToStrF(actor.PagoPorEnergiaEntregada_USD_MWh, ffGeneral, CF_PRECISION, CF_DECIMALES);
    self.ePagoPorEnergiaDisponible.Text :=
      FloatToStrF(actor.PagoPorEnergiaDisponible_USD_MWh, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    cbRestarParaPostizar.checked:= actor.flg_RestarParaPostizado;
    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
  end
  else
  begin
    cb_CalcularGradienteDeInversion.Checked:= False;
    cbRestarParaPostizar.checked:= true;
    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
  end;
end;

function TEditarTParqueEolico.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited validarEditFecha(EFMuerte) and
    inherited validarEditFloat(eFD) and
    inherited validarEditFloat(eTMR) and
    inherited validarEditFloat(eFacInterferencias) and
    inherited validarEditFloat(eVelMin) and
    inherited validarEditFloat(eVelMax) and
    inherited validarTablaNReals_(sgFSpeedUp) and
    inherited validarCBFuenteEolico(CBFuente, CBBorne) and
    inherited validarEditFloat(ePagoPorEnergiaEntregada, 0, 10000) and
    inherited validarEditFloat(ePagoPorEnergiaDisponible, 0, 10000) and
    validarCurva and validarEditFloat(eTonCO2xMWh, -1000, 1000000);
end;

function TEditarTParqueEolico.validarCurva: boolean;
begin
  if curva <> nil then
    Result := True
  else
  begin
    ShowMessage(mesDebeEditarLaCurvaDeVelP);
    Result := False;
  end;
end;

procedure TEditarTParqueEolico.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTParqueEolico.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTParqueEolico.BEditarCurvaVPClick(Sender: TObject);
var
  form: TEditarFVectR;
  xxMin, xxMax: NReal;
begin
  try
    xxMin := StrToFloat( eVelMin.text );
  except
    on EConvertError do
    begin
      ShowMessage(mesDebeIngresarUnaVelocidadMinV);
      raise;
    end
  end;
  try
    xxMax := StrToFloat( eVelMax.text );
  except
    on EConvertError do
    begin
      ShowMessage(mesDebeIngresarUnaVelocidadMaxV);
      raise;
    end
  end;
  if self.curva = nil then
    form := TEditarFVectR.Create_CrearCurva(self, capa, xxMin, xxMax,
      14, 'Velocidad Viento[m/s]', 'Potencia Generada[MW]')
  else
    form := TEditarFVectR.Create(self, xxMin, xxMax, curva,
      'Velocidad Viento[m/s]', 'Potencia Generada[MW]');
  if form.ShowModal = mrOk then
  begin
    if curva <> nil then
      curva.Free;
    curva := form.darCurva;
  end;
  form.Free;
end;

procedure TEditarTParqueEolico.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTParqueEolico.BExportar_odsClick(Sender: TObject);
begin
  exportarTablaAODS_2( sgFSpeedUp, BImportar_ods, nil);
end;

procedure TEditarTParqueEolico.BGuardarClick(Sender: TObject);
var
  actor: TParqueEolico;
begin
  if validarFormulario then
  begin

    (*
 cambio los límites de la curva por si fueron cambiados
 en el formulario.
 Después de editar la curva.

  *)
    curva.xmin:= StrToFloat( eVelMin.text );
    curva.xmax:= StrToFloat( eVelMax.text );

    if cosaConNombre = nil then
    begin
      cosaConNombre := TParqueEolico.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades,
        valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        valorCBFuente(CBFuente), valorCBString(CBBorne),
        StrToFloat( eFD.Text ),
        StrToFloat( eTMR.Text ),
        filaTablaNReals(sgFSpeedUp, 1),
        StrToFloat( eFacInterferencias.text ),
        curva, StrToFloat(ePagoPorEnergiaEntregada.Text), StrToFloat(ePagoPorEnergiaDisponible.Text),
        cbRestarParaPostizar.checked,
        StrToFloat(eTonCO2xMWh.Text), cbLowCostMustRun.Checked,
        cbCleanDevelopmentMechanism.Checked);
      actor := TParqueEolico(cosaConNombre);

    end
    else
    begin
      actor := TParqueEolico(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.Nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.fuenteDeViento := valorCBFuente(CBFuente);
      actor.nombreBorne := valorCBString(CBBorne);
      actor.fdisp := StrToFloat( eFD.Text );
      actor.tRepHoras := StrToFloat( eTMR.Text );
      actor.fSpeedUpMes := filaTablaNReals(sgFSpeedUp, 1);
      actor.fPerdidasInterferencias := StrToFloat( eFacInterferencias.Text );
      actor.CurvaVP.Free;
      actor.CurvaVP := curva;
      actor.PagoPorEnergiaEntregada_USD_MWh := StrToFloat(ePagoPorEnergiaEntregada.Text);
      actor.PagoPorEnergiaDisponible_USD_MWh := StrToFloat(ePagoPorEnergiaDisponible.Text);
      actor.flg_RestarParaPostizado:= cbRestarParaPostizar.checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTParqueEolico.BImportar_odsClick(Sender: TObject);
begin
  importarTablaDesdeODS_2( sgFSpeedUp,
    BImportar_ods, nil, True, True);
end;

procedure TEditarTParqueEolico.CBBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne);
end;

procedure TEditarTParqueEolico.CBFuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

procedure TEditarTParqueEolico.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTParqueEolico.GroupBox1Click(Sender: TObject);
begin

end;


procedure TEditarTParqueEolico.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTParqueEolico.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTParqueEolico.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TEditarTParqueEolico.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarTParqueEolico.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarTParqueEolico.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

initialization
end.
