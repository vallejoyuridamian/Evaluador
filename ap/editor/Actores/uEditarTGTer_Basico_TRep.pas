unit uEditarTGTer_Basico_TRep;

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
  ugter_basico_trep;

type

  { TEditarTGTer_Basico_TRep }

  TEditarTGTer_Basico_TRep = class(TEditarActorConFichas)
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
    LEstadoIni: TLabel;
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
    CBEstadoIni: TComboBox;
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

constructor TEditarTGTer_Basico_TRep.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TGTer_Basico_TRep;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);
  CBEstadoIni.Items.Add('0');
  CBEstadoIni.Items.Add('1');

  if cosaConNombre <> nil then
  begin
    actor := TGTer_Basico_TRep(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaGTer_Basico_TRep, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);

    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);

    setCBString(CBEstadoIni, IntToStr(actor.estadoInicial));
    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaGTer_Basico_TRep, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    CBEstadoIni.ItemIndex := 1;

    cb_CalcularGradienteDeInversion.Checked:= False;

    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
  end;
end;

function TEditarTGTer_Basico_TRep.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and validarEditFloat(eTonCO2xMWh,
    -1000, 1000000);
end;

procedure TEditarTGTer_Basico_TRep.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTGTer_Basico_TRep.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTGTer_Basico_TRep.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTGTer_Basico_TRep.BGuardarClick(Sender: TObject);
var
  actor: TGTer_Basico_TRep;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TGTer_Basico_TRep.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo), StrToInt(valorCBString(CBEstadoIni)),
        cb_CalcularGradienteDeInversion.Checked,
        StrToFloat(eTonCO2xMWh.Text), cbLowCostMustRun.Checked,
        cbCleanDevelopmentMechanism.Checked);
      actor := TGTer_Basico_TRep(cosaConNombre);
    end
    else
    begin
      actor := TGTer_Basico_TRep(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.estadoInicial := StrToInt(valorCBString(CBEstadoIni));
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTGTer_Basico_TRep.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTGTer_Basico_TRep.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTGTer_Basico_TRep.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTGTer_Basico_TRep.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;

procedure TEditarTGTer_Basico_TRep.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTGTer_Basico_TRep.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
