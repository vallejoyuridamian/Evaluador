unit uEditarTHidroDePasada;

  {$MODE Delphi}

interface

uses
    {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids,
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
  uHidroDePasada;

type

  { TEditarTHidroDePasada }

  TEditarTHidroDePasada = class(TEditarActorConFichas)
    btEditarForzamientos: TButton;
    cbCleanDevelopmentMechanism: TCheckBox;
    cbLowCostMustRun: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    cb_ImponerIgualPotenciaEnTodosLosPostes: TCheckBox;
    eTonCO2xMWh: TEdit;
    GroupBox3: TGroupBox;
    Label11: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LVEstado: TLabel;
    LFichas: TLabel;
    LFuenteDeAportes: TLabel;
    LBorne: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    rgTipoFuente: TRadioGroup;
    sgFichas: TStringGrid;
    BAgregarFicha: TButton;
    BGuardar: TButton;
    BCancelar: TButton;
    Panel1: TPanel;
    BVerExpandida: TButton;
    BEditorDeUnidades: TButton;
    CBFuente: TComboBox;
    CBBorne: TComboBox;
    BAyuda: TButton;
    procedure btEditarForzamientosClick(Sender: TObject);
    procedure cb_ImponerIgualPotenciaEnTodosLosPostesClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
    procedure CBBorneChange(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure rgTipoFuenteClick(Sender: TObject);
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

constructor TEditarTHidroDePasada.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: THidroDePasada;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);
  inicializarCBFuente(CBFuente, CBBorne, False);

  if cosaConNombre <> nil then
  begin
    actor := THidroDePasada(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaHidroDePasada, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    setCBFuente(CBFuente, CBBorne, actor.fuenteDeAportes, actor.nombreBorne);
    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    if actor.flg_FuenteDeEscurrimientos then
      rgTipoFuente.ItemIndex := 1
    else
      rgTipoFuente.ItemIndex := 0;
    cb_ImponerIgualPotenciaEnTodosLosPostes.Checked:= actor.flg_IgualPotenciaEnTodosLosPostes;
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    guardado:= true;
  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaHidroDePasada, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    eTonCO2xMWh.Text := FloatToStr(0.0);
    rgTipoFuente.ItemIndex := 0;
    cb_ImponerIgualPotenciaEnTodosLosPostes.Checked:= false;
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
    cb_CalcularGradienteDeInversion.Checked:= false;

    guardado:= false;
  end;
end;

function TEditarTHidroDePasada.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and inherited validarCBFuente(
    CBFuente, CBBorne, 0) and validarEditFloat(eTonCO2xMWh, -1000, 1000000);
end;

procedure TEditarTHidroDePasada.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTHidroDePasada.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTHidroDePasada.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTHidroDePasada.BGuardarClick(Sender: TObject);
var
  actor: THidroDePasada;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := THidroDePasada.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        valorCBFuente(CBFuente), valorCBString(CBBorne),
        (rgTipoFuente.ItemIndex = 1), cb_ImponerIgualPotenciaEnTodosLosPostes.checked,
         StrToFloat(eTonCO2xMWh.Text),
        cbLowCostMustRun.Checked, cbCleanDevelopmentMechanism.Checked);
      actor := THidroDePasada(cosaConNombre);
    end
    else
    begin
      actor := THidroDePasada(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.fuenteDeAportes := valorCBFuente(CBFuente);
      actor.nombreBorne := valorCBString(CBBorne);
      actor.flg_FuenteDeEscurrimientos := (rgTipoFuente.ItemIndex = 1);
      actor.flg_IgualPotenciaEnTodosLosPostes:= cb_ImponerIgualPotenciaEnTodosLosPostes.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTHidroDePasada.rgTipoFuenteClick(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTHidroDePasada.CBBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne);
end;

procedure TEditarTHidroDePasada.CBFuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

procedure TEditarTHidroDePasada.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTHidroDePasada.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTHidroDePasada.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;


procedure TEditarTHidroDePasada.cb_ImponerIgualPotenciaEnTodosLosPostesClick(
  Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTHidroDePasada.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTHidroDePasada.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
