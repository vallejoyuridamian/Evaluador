unit uEditarTGTer_OnOffPorPaso_ConRestricciones;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids,
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
  ugter_onoffporpaso_conrestricciones;

type

  { TEditarTGTer_OnOffPorPaso_ConRestricciones }

  TEditarTGTer_OnOffPorPaso_ConRestricciones = class(TEditarActorConFichas)
    btEditarForzamientos: TButton;
    cbCleanDevelopmentMechanism: TCheckBox;
    cbLowCostMustRun: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    eTonCO2xMWh: TEdit;
    GroupBox3: TGroupBox;
    Label11: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFichas: TLabel;
    lNPasosEstadoIni: TLabel;
    CBNodo: TComboBox;
    sgFichas: TStringGrid;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BAgregarFicha: TButton;
    BGuardar: TButton;
    BCancelar: TButton;
    BEditorDeUnidades: TButton;
    BVerExpandida: TButton;
    BAyuda: TButton;
    eNPasosEIni: TEdit;
    RGOnOff: TRadioGroup;
    procedure BAyudaClick(Sender: TObject);
    procedure btEditarForzamientosClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
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

constructor TEditarTGTer_OnOffPorPaso_ConRestricciones.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TGTer_OnOffPorPaso_ConRestricciones;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := TGTer_OnOffPorPaso_ConRestricciones(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaGTer_OnOffPorPaso_ConRestricciones,
      sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);

    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);

    if actor.xOnOff_AlInicio <= 0 then
    begin
      RGOnOff.ItemIndex := RGOnOff.Items.IndexOf('Apagado');
      eNPasosEIni.Text := IntToStr(1 - actor.xOnOff_AlInicio);
    end
    else
    begin
      RGOnOff.ItemIndex := RGOnOff.Items.IndexOf('Encendido');
      eNPasosEIni.Text := IntToStr(actor.xOnOff_AlInicio);
    end;

    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaGTer_OnOffPorPaso_ConRestricciones, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    cb_CalcularGradienteDeInversion.Checked:= False;

    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
  end;
  guardado := True;
end;

function TEditarTGTer_OnOffPorPaso_ConRestricciones.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and inherited validarEditInt(
    eNPasosEIni, 0, MaxInt) and validarEditFloat(eTonCO2xMWh, -1000, 1000000);
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.btEditarForzamientosClick(
  Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.BEditorDeUnidadesClick(
  Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.BGuardarClick(Sender: TObject);
var
  actor: TGTer_OnOffPorPaso_ConRestricciones;
  estadoInicialEncendido: boolean;
  xOnOff_AlInicio: integer;
begin
  if validarFormulario then
  begin
    estadoInicialEncendido := RGOnOff.Items[RGOnOff.ItemIndex] = 'Encendido';
    if estadoInicialEncendido then
      xOnOff_AlInicio := StrToInt(eNPasosEIni.Text)
    else
      xOnOff_AlInicio := 1 - StrToInt(eNPasosEIni.Text);

    if cosaConNombre = nil then
    begin
      cosaConNombre := TGTer_OnOffPorPaso_ConRestricciones.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        estadoInicialEncendido, xOnOff_AlInicio,
        StrToFloat(eTonCO2xMWh.Text), cbLowCostMustRun.Checked,
        cbCleanDevelopmentMechanism.Checked);
      actor := TGTer_OnOffPorPaso_ConRestricciones(cosaConNombre);
    end
    else
    begin
      actor := TGTer_OnOffPorPaso_ConRestricciones(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;

      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.xOnOff_AlInicio := xOnOff_AlInicio;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTGTer_OnOffPorPaso_ConRestricciones.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
