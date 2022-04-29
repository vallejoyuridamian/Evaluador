unit ueditarTSolarPV;

{$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids,
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
  usolarPV;

type

  { TEditarTSolarPV }

  TEditarTSolarPV = class(TEditarActorConFichas)
    btEditarForzamientos: TButton;
    CBBorneFuenteIndiceClaridad: TComboBox;
    cbCleanDevelopmentMechanism: TCheckBox;
    CBFuenteIndiceClaridad: TComboBox;
    cbLowCostMustRun: TCheckBox;
    cbRestarParaPostizar: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    eTonCO2xMWh: TEdit;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label11: TLabel;
    LBorneFuenteKt: TLabel;
    LFuenteKt: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFichas: TLabel;
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
    procedure BAgregarFichaClick(Sender: TObject);
    procedure btEditarForzamientosClick(Sender: TObject);
    procedure BVerExpandidaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBFuenteIndiceClaridadChange(Sender: TObject);
    procedure CBBorneFuenteIndiceClaridadChange(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  private

  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;

  end;

implementation

uses SimSEEEditMain;

{$R *.lfm}

constructor TEditarTSolarPV.Create(AOwner: TComponent; sala: TSalaDeJuego;
  tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TSolarPV;

begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  inherited inicializarCBFuenteHorarias_MonoBorne(CBFuenteIndiceClaridad,
    CBBorneFuenteIndiceClaridad);

  if cosaConNombre <> nil then
  begin
    actor := TSolarPV(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaSolarPV, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);

    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    cbRestarParaPostizar.Checked:= actor.flg_RestarParaPostizado;

    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;

    inherited setCBFuente(CBFuenteIndiceClaridad,
      CBBorneFuenteIndiceClaridad, actor.fuente_IndiceClaridad,
      actor.borneIndiceClaridad);

  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaSolarPV, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    cbRestarParaPostizar.Checked:= true;
    cb_CalcularGradienteDeInversion.Checked:= False;
    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
  end;
end;

function TEditarTSolarPV.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and validarEditFloat(eTonCO2xMWh,
    -1000, 1000000) and inherited validarCBFuente(CBFuenteIndiceClaridad,
    CBBorneFuenteIndiceClaridad, 0);
end;

procedure TEditarTSolarPV.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTSolarPV.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTSolarPV.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTSolarPV.BGuardarClick(Sender: TObject);
var
  actor: TSolarPV;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TSolarPV.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text), FSimSEEEdit.StringToFecha(EFMuerte.Text),
        lpdUnidades, lpd, valorCBNodo(CBNodo),
        cbRestarParaPostizar.Checked,
        cb_CalcularGradienteDeInversion.Checked,
        StrToFloat(eTonCO2xMWh.Text),
        cbLowCostMustRun.Checked, cbCleanDevelopmentMechanism.Checked,
        valorCBFuente(CBFuenteIndiceClaridad), valorCBString(CBBorneFuenteIndiceClaridad));
      actor := TSolarPV(cosaConNombre);
    end
    else
    begin
      actor := TSolarPV(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      if actor.lpd <> nil then
        actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_RestarParaPostizado:= cbRestarParaPostizar.Checked;
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
      actor.fuente_IndiceClaridad := valorCBFuente(CBFuenteIndiceClaridad);
      actor.borneIndiceClaridad := valorCBString(CBBorneFuenteIndiceClaridad);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTSolarPV.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTSolarPV.CBBorneFuenteIndiceClaridadChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuenteIndiceClaridad, CBBorneFuenteIndiceClaridad);
end;

procedure TEditarTSolarPV.CBFuenteIndiceClaridadChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndiceClaridad,
    CBBorneFuenteIndiceClaridad);
end;

procedure TEditarTSolarPV.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTSolarPV.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTSolarPV.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;

procedure TEditarTSolarPV.BAgregarFichaClick(Sender: TObject);
begin
  inherited BAgregarFichaClick(Sender);
end;

procedure TEditarTSolarPV.BVerExpandidaClick(Sender: TObject);
begin
  inherited BVerExpandidaClick(Sender);
end;


procedure TEditarTSolarPV.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTSolarPV.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
