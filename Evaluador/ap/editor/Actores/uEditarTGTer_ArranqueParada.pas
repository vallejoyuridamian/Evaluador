unit uEditarTGTer_ArranqueParada;

  {$MODE Delphi}

interface

uses
    {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls,
  uEditarActorConFichas,
  uFichasLPD,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uConstantesSimSEE,
  xMatDefs,
  ugter_arranqueparada;

type

  { TEditarTGter_ArranqueParada }

  TEditarTGter_ArranqueParada = class(TEditarActorConFichas)
    BAgregarFicha: TButton;
    BCancelar: TButton;
    BEditorDeUnidades: TButton;
    BGuardar: TButton;
    btEditarForzamientos: TButton;
    BVerExpandida: TButton;
    cbCleanDevelopmentMechanism: TCheckBox;
    CBEstadoIni: TComboBox;
    cbLowCostMustRun: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    eFechaCambioEstado: TEdit;
    eTonCO2xMWh: TEdit;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label11: TLabel;
    LEstadoIni: TLabel;
    panel_botones_deabajo: TPanel;
    panel_EstadoInicial: TGroupBox;
    panel_ParametrosDinamicos: TGroupBox;
    LFichas: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BAyuda: TButton;
    sgFichas: TStringGrid;
    procedure btEditarForzamientosClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

const
  STR_APAGADO = 'OFF';
  STR_ENCENDIDO = 'ON';



constructor TEditarTGter_ArranqueParada.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TGTer_ArranqueParada;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);
  CBEstadoIni.Items.Add(STR_APAGADO);
  CBEstadoIni.Items.Add(STR_ENCENDIDO);

  if cosaConNombre <> nil then
  begin
    actor := TGTer_ArranqueParada(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaGTer_ArranqueParada, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);

    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);

    if actor.encendidoAlInicio then
      CBEstadoIni.ItemIndex := CBEstadoIni.Items.IndexOf(STR_ENCENDIDO)
    else
      CBEstadoIni.ItemIndex := CBEstadoIni.Items.IndexOf(STR_APAGADO);


    eFechaCambioEstado.Text := actor.FechaCambioEstado_ini.AsStr;

    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaGTer_ArranqueParada, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    CBEstadoIni.ItemIndex := 1;
    eFechaCambioEstado.Text := '0';

    cb_CalcularGradienteDeInversion.Checked:= False;

    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
  end;
end;

function TEditarTGter_ArranqueParada.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and validarEditFloat(eTonCO2xMWh,
    -1000, 1000000);
end;

procedure TEditarTGter_ArranqueParada.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTGter_ArranqueParada.FormCreate(Sender: TObject);
begin

end;

procedure TEditarTGter_ArranqueParada.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTGter_ArranqueParada.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTGter_ArranqueParada.BGuardarClick(Sender: TObject);
var
  actor: TGTer_ArranqueParada;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TGTer_ArranqueParada.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        valorCBString(CBEstadoIni) <> STR_APAGADO,
        FSimSEEEdit.StringToFecha(eFechaCambioEstado.Text),
        StrToFloat(eTonCO2xMWh.Text), cbLowCostMustRun.Checked,
        cbCleanDevelopmentMechanism.Checked);
      actor := TGTer_ArranqueParada(cosaConNombre);
    end
    else
    begin
      actor := TGTer_ArranqueParada(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.encendidoAlInicio := valorCBString(CBEstadoIni) <> STR_APAGADO;
      actor.FechaCambioEstado_ini := FSimSEEEdit.StringToFecha(eFechaCambioEstado.Text);
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTGter_ArranqueParada.CambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarTGter_ArranqueParada.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTGter_ArranqueParada.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTGter_ArranqueParada.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;

procedure TEditarTGter_ArranqueParada.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTGter_ArranqueParada.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
