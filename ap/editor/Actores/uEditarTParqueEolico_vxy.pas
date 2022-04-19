unit uEditarTParqueEolico_vxy;

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
  uEditarArrayOfFVectR,
  uFuncionesReales,
  uConstantesSimSEE,
  xMatDefs,
  uParqueEolico_vxy;

resourcestring
  mesDebeEditarLaCurvaDeVelP =
    'Debe editar la curva Velocidad-Potencia para poder guardar el generador';
  mesDebeIngresarUnaVelocidadMinV =
    'Debe ingresar una velocidad mínima de viento para generación para continuar';
  mesDebeIngresarUnaVelocidadMaxV =
    'Debe ingresar una Velocidad máxima de viento para generación para continuar';

type

  { TEditarTParqueEolico_vxy }

  TEditarTParqueEolico_vxy = class(TBaseEditoresActores)
    CBBorne_vx: TComboBox;
    CBBorne_vy: TComboBox;
    cbCleanDevelopmentMechanism: TCheckBox;
    CBFuente: TComboBox;
    cbLowCostMustRun: TCheckBox;
    cbRestarParaPostizar: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    ePagoPorEnergiaDisponible: TEdit;
    eTonCO2xMWh: TEdit;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label7: TLabel;
    LBorne: TLabel;
    LFuenteDeViento: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    Panel1: TPanel;
    BEditorDeUnidades: TButton;
    BAyuda: TButton;
    BImportar_ods: TButton;
    BExportar_ods: TButton;
    Label2: TLabel;
    ePagoPorEnergiaEntregada: TEdit;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    eFactorDiponibilidad: TEdit;
    Label4: TLabel;
    eTMR: TEdit;
    Label5: TLabel;
    eVmin: TEdit;
    Label6: TLabel;
    eVmax: TEdit;
    BEditarCurvaVP: TButton;
    Label8: TLabel;
    sgFPerdidasAerodinamicas: TStringGrid;
    Label9: TLabel;
    eMultV: TEdit;
    Label10: TLabel;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure BExportar_odsClick(Sender: TObject);
    procedure BImportar_odsClick(Sender: TObject);
    procedure CBBorne_vxChange(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BEditarCurvaVPClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBBorne_vyChange(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
  private
    curva: TArrayOfFVectR;

    function validarCurva: boolean;
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;

{$R *.lfm}

constructor TEditarTParqueEolico_vxy.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);

var
  actor: TParqueEolico_vxy;
  i: integer;
  potencias: TDAofNReal;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);
  inherited inicializarCBFuenteHorarias_biborne(CBFuente, CBBorne_vx, CBBorne_vy);

  sgFPerdidasAerodinamicas.Cells[0, 0] := 'Dirección';
  sgFPerdidasAerodinamicas.Cells[0, 1] := 'factores de pérdidas[p.u.]';

  sgFPerdidasAerodinamicas.Cells[1, 0] := 'N';
  sgFPerdidasAerodinamicas.Cells[2, 0] := 'NNE';
  sgFPerdidasAerodinamicas.Cells[3, 0] := 'NE';
  sgFPerdidasAerodinamicas.Cells[4, 0] := 'ENE';

  sgFPerdidasAerodinamicas.Cells[5, 0] := 'E';
  sgFPerdidasAerodinamicas.Cells[6, 0] := 'ESE';
  sgFPerdidasAerodinamicas.Cells[7, 0] := 'SE';
  sgFPerdidasAerodinamicas.Cells[8, 0] := 'SSE';

  sgFPerdidasAerodinamicas.Cells[9, 0] := 'S';
  sgFPerdidasAerodinamicas.Cells[10, 0] := 'SSO';
  sgFPerdidasAerodinamicas.Cells[11, 0] := 'SO';
  sgFPerdidasAerodinamicas.Cells[12, 0] := 'OSO';

  sgFPerdidasAerodinamicas.Cells[13, 0] := 'O';
  sgFPerdidasAerodinamicas.Cells[14, 0] := 'ONO';
  sgFPerdidasAerodinamicas.Cells[15, 0] := 'NO';
  sgFPerdidasAerodinamicas.Cells[16, 0] := 'NNO';

  if cosaConNombre <> nil then
  begin
    actor := TParqueEolico_vxy(cosaConNombre);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);

    eFactorDiponibilidad.Text :=
      FloatToStrF(actor.fdisp, ffGeneral, CF_PRECISION, CF_DECIMALES);
    eTMR.Text := FloatToStrF(actor.tRepHoras, ffGeneral, CF_PRECISION, CF_DECIMALES);
    eVmin.Text := FloatToStrF(actor.CurvaVP[0].xmin, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    eVmax.Text := FloatToStrF(actor.CurvaVP[0].xmax, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    eMultV.Text := FloatToStrF(actor.fMultV, ffGeneral, CF_PRECISION, CF_DECIMALES);

    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    for i := 1 to 16 do
      sgFPerdidasAerodinamicas.Cells[i, 1] :=
        FloatToStrF(actor.fPerdidasAerodinamicas[i - 1], ffGeneral,
        CF_PRECISION, CF_DECIMALES);

    setCBFuente_biborne(
      CBFuente, CBBorne_vx, CBBorne_vy,
      actor.fuenteDeViento, actor.nombreBorne_vx, actor.nombreBorne_vy);

    SetLength(self.curva, 16);
    for i := 0 to 15 do
      self.curva[i] := actor.CurvaVP[i].Create_Clone( nil, 0 ) as TFVectR;



    self.ePagoPorEnergiaDisponible.Text :=
      FloatToStrF(actor.PagoPorEnergiaDisponible_USD_MWh, ffGeneral,
      CF_PRECISION, CF_DECIMALES);

    self.ePagoPorEnergiaEntregada.Text :=
      FloatToStrF(actor.PagoPorEnergiaEntregada_USD_MWh, ffGeneral,
      CF_PRECISION, CF_DECIMALES);

    cbRestarParaPostizar.Checked:= actor.flg_RestarParaPostizado;
    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
  end
  else
  begin

    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;

    eFactorDiponibilidad.Text := FloatToStrF(0.9, ffGeneral, 3, 1);
    eTMR.Text := '96';
    eVmin.Text := '3';
    eVmax.Text := '25';
    eMultV.Text := FloatToStrF(1.0, ffGeneral, 3, 1);
    ePagoPorEnergiaDisponible.Text := FloatToStrF(0.0, ffGeneral, 3, 1);
    ePagoPorEnergiaEntregada.Text := FloatToStrF(0.0, ffGeneral, 3, 1);
    cbRestarParaPostizar.Checked:= true;

    cb_CalcularGradienteDeInversion.Checked:= False;


    for i := 1 to 16 do
      sgFPerdidasAerodinamicas.cells[i, 1] := FloatToStrF(1, ffGeneral, 3, 1);

    setlength(curva, 16);
    for i := 0 to 15 do
    begin
      SetLength(potencias, 23);
      potencias[0] := 0;
      potencias[1] := 0.88;
      potencias[2] := 0.204;
      potencias[3] := 0.371;
      potencias[4] := 0.602;
      potencias[5] := 0.901;
      potencias[6] := 1.243;
      potencias[7] := 1.57;
      potencias[8] := 1.759;
      potencias[9] := 1.793;
      potencias[10] := 1.8;
      potencias[11] := 1.8;
      potencias[12] := 1.8;
      potencias[13] := 1.8;
      potencias[14] := 1.8;
      potencias[15] := 1.8;
      potencias[16] := 1.8;
      potencias[17] := 1.8;
      potencias[18] := 1.8;
      potencias[19] := 1.8;
      potencias[20] := 1.8;
      potencias[21] := 1.8;
      potencias[22] := 1.8;
      curva[i] := TFVectR.Create(capa, potencias, 3, 25);
    end;
  end;

  utilidades.AutoSizeCol(sgFPerdidasAerodinamicas, 0);
end;

function TEditarTParqueEolico_vxy.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited validarEditFecha(EFMuerte) and inherited validarTablaNReals_(
    sgFPerdidasAerodinamicas) and inherited validarCBFuenteEolico(CBFuente,
    CBBorne_vx) and inherited validarCBFuenteEolico(CBFuente, CBBorne_vy) and
    validarEditFloat(ePagoPorEnergiaDisponible) and
    validarEditFloat(ePagoPorEnergiaEntregada) and validarCurva and
    validarEditFloat(eTonCO2xMWh, -1000, 1000000);
end;


function TEditarTParqueEolico_vxy.validarCurva: boolean;
begin
  if curva[0] <> nil then
    Result := True
  else
  begin
    ShowMessage(mesDebeEditarLaCurvaDeVelP);
    Result := False;
  end;
end;

procedure TEditarTParqueEolico_vxy.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTParqueEolico_vxy.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTParqueEolico_vxy.BEditarCurvaVPClick(Sender: TObject);
var
  form: TEditarArrayOfFVectR;
  xxMin, xxMax: NReal;
  k: integer;
begin
  try
    xxMin := StrToFloat(self.eVmin.Text);
  except
    on EConvertError do
    begin
      ShowMessage(mesDebeIngresarUnaVelocidadMinV);
      raise;
    end
  end;
  try
    xxMax := StrToFloat(self.eVmax.Text);
  except
    on EConvertError do
    begin
      ShowMessage(mesDebeIngresarUnaVelocidadMaxV);
      raise;
    end
  end;

  if self.curva = nil then
    form := TEditarArrayOfFVectR.Create(self, xxMin, xxMax, 14,
      'Velocidad Viento[m/s]', ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE',
      'SE', 'SSE', 'S', 'SSO', 'SO', 'OSO', 'O', 'ONO', 'NO', 'NNO'])
  else
    form := TEditarArrayOfFVectR.Create(self, xxMin, xxMax, curva,
      'Velocidad Viento[m/s]', ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE',
      'SE', 'SSE', 'S', 'SSO', 'SO', 'OSO', 'O', 'ONO', 'NO', 'NNO']);


  if form.ShowModal = mrOk then
  begin
    for k := 0 to high(curva) do
    begin
      if curva[k] <> nil then
        curva[k].Free;
      curva[k] := form.darCurva(k);
    end;
  end;
  form.Free;
end;

procedure TEditarTParqueEolico_vxy.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTParqueEolico_vxy.BExportar_odsClick(Sender: TObject);
begin
  exportarTablaAODS_2( sgFPerdidasAerodinamicas,
    BImportar_ods, nil);
end;

procedure TEditarTParqueEolico_vxy.BGuardarClick(Sender: TObject);
var
  actor: TParqueEolico_vxy;
  k: integer;

begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TParqueEolico_vxy.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades,
        valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        valorCBFuente(CBFuente), valorCBString(CBBorne_vx),
        valorCBString(CBBorne_vy), StrToFloat(self.eFactorDiponibilidad.Text),
        StrToFloat(self.eTMR.Text), filaTablaNReals(self.sgFPerdidasAerodinamicas, 1),
        StrToFloat(self.eMultV.Text), curva, StrToFloat(
        ePagoPorEnergiaDisponible.Text), StrToFloat(ePagoPorEnergiaEntregada.Text),
        cbRestarParaPostizar.Checked,
        StrToFloat(eTonCO2xMWh.Text), cbLowCostMustRun.Checked,
        cbCleanDevelopmentMechanism.Checked);
      actor := TParqueEolico_vxy(cosaConNombre);
    end
    else
    begin
      actor := TParqueEolico_vxy(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.Nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.fuenteDeViento := valorCBFuente(CBFuente);
      actor.nombreBorne_vx := valorCBString(CBBorne_vx);
      actor.nombreBorne_vy := valorCBString(CBBorne_vy);
      actor.fdisp := StrToFloat(self.eFactorDiponibilidad.Text);
      actor.tRepHoras := StrToFloat(self.eTMR.Text);
      actor.fPerdidasAerodinamicas := filaTablaNReals(self.sgFPerdidasAerodinamicas, 1);
      actor.fMultV := StrToFloat(self.eMultV.Text);
      for k := 0 to high(actor.CurvaVP) do
      begin
        if actor.CurvaVP[k] <> nil then
          actor.CurvaVP[k].Free;
      end;
      setlength(actor.CurvaVP, 0);
      actor.CurvaVP := curva;
      actor.PagoPorEnergiaDisponible_USD_MWh :=
        StrToFloat(ePagoPorEnergiaDisponible.Text);
      actor.PagoPorEnergiaEntregada_USD_MWh :=
        StrToFloat(ePagoPorEnergiaEntregada.Text);
      actor.flg_RestarParaPostizado:= cbRestarParaPostizar.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTParqueEolico_vxy.BImportar_odsClick(Sender: TObject);
begin
  importarTablaDesdeODS_2( sgFPerdidasAerodinamicas,
    BImportar_ods, nil, True, True);
end;

procedure TEditarTParqueEolico_vxy.CBBorne_vxChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne_vx);
end;


procedure TEditarTParqueEolico_vxy.CBBorne_vyChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne_vy);
end;

procedure TEditarTParqueEolico_vxy.CBFuenteChange(Sender: TObject);
begin
  inherited cbFuenteChange_biborne(Sender, CBBorne_vx, CBBorne_vy);
end;

procedure TEditarTParqueEolico_vxy.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTParqueEolico_vxy.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTParqueEolico_vxy.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTParqueEolico_vxy.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
var
  i: integer;
begin
  inherited FormCloseQuery(Sender, CanClose);
  if CanClose and (ModalResult <> mrOk) then
  begin
    for i := 0 to high(curva) do
      curva[i].Free;
    curva := nil;
  end;
end;

procedure TEditarTParqueEolico_vxy.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarTParqueEolico_vxy.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarTParqueEolico_vxy.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

initialization
end.
