unit uEditarTHidroConBombeo;

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
  uHidroConBombeo;

type

  { TEditarTHidroConBombeo }

  TEditarTHidroConBombeo = class(TEditarActorConFichas)
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
    LVEstado: TLabel;
    LNDisc: TLabel;
    LHIni: TLabel;
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
    EHIni: TEdit;
    ENDisc: TEdit;
    Panel1: TPanel;
    BVerExpandida: TButton;
    BEditorDeUnidades: TButton;
    CBFuente: TComboBox;
    CBBorne: TComboBox;
    BAyuda: TButton;
    cb_ValorizadoManual: TCheckBox;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
    procedure CBBorneChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
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

constructor TEditarTHidroConBombeo.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: THidroConBombeo;
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
    actor := THidroConBombeo(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaHidroConBombeo, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    setCBFuente(CBFuente, CBBorne, actor.fuenteDeAportes, actor.nombreBorne);



    EHIni.Text := FloatToStrF(actor.hini, ffGeneral, CF_PRECISION, CF_DECIMALES);
    ENDisc.Text := IntToStr(actor.NDisc);

    if actor.flg_FuenteDeEscurrimientos then
      rgTipoFuente.ItemIndex := 1
    else
      rgTipoFuente.ItemIndex := 0;


    cb_ValorizadoManual.Checked := actor.flg_ValorizadoManual;

    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;

  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaHidroConBombeo, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    eTonCO2xMWh.Text := FloatToStr(0.0);
    rgTipoFuente.ItemIndex := 0;
    cbLowCostMustRun.Checked := True;
    cb_CalcularGradienteDeInversion.Checked:= False;
    cbCleanDevelopmentMechanism.Checked := False;

  end;
end;

function TEditarTHidroConBombeo.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and inherited validarCBFuente(
    CBFuente, CBBorne, 0) and inherited validarEditFloat(EHIni, 0, MaxNReal) and
    inherited validarEditInt(ENDisc, 2, MaxInt) and
    validarEditFloat(eTonCO2xMWh, -1000, 1000000);
end;

procedure TEditarTHidroConBombeo.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, THidroConBombeo);
end;

procedure TEditarTHidroConBombeo.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTHidroConBombeo.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTHidroConBombeo.BGuardarClick(Sender: TObject);
var
  actor: THidroConBombeo;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := THidroConBombeo.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo),

        StrToFloat(EHIni.Text), StrToInt(ENDisc.Text),
        valorCBFuente(CBFuente), valorCBString(CBBorne),
        (rgTipoFuente.ItemIndex = 1), cb_ValorizadoManual.Checked,
        cb_CalcularGradienteDeInversion.Checked,
        StrToFloat(eTonCO2xMWh.Text), cbLowCostMustRun.Checked,
        cbCleanDevelopmentMechanism.Checked);

      actor := THidroConBombeo(cosaConNombre);
    end
    else
    begin
      actor := THidroConBombeo(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.hini := StrToFloat(EHIni.Text);
      actor.NDisc := StrToInt(ENDisc.Text);
      actor.fuenteDeAportes := valorCBFuente(CBFuente);
      actor.nombreBorne := valorCBString(CBBorne);
      actor.flg_FuenteDeEscurrimientos := (rgTipoFuente.ItemIndex = 1);
      actor.flg_ValorizadoManual := cb_ValorizadoManual.Checked;
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;

    ModalResult := mrOk;
  end;
end;

procedure TEditarTHidroConBombeo.rgTipoFuenteClick(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTHidroConBombeo.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTHidroConBombeo.CBBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne);
end;

procedure TEditarTHidroConBombeo.CBFuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

procedure TEditarTHidroConBombeo.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTHidroConBombeo.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTHidroConBombeo.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTHidroConBombeo.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


initialization
end.
