unit uEditarTBancoDeBaterias01;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls,
  uEditarActorConFichas,
  ufichasLPD,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uConstantesSimSEE,
  xMatDefs,
  uEditarFichaBancodeBaterias01,
  ubancodebaterias01;

type

  { TEditarTBancoDeBaterias01 }

  TEditarTBancoDeBaterias01 = class(TEditarActorConFichas)
    btEditarUnidades: TButton;
    cbLowCostMustRun: TCheckBox;
    cbCleanDevelopmentMechanism: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    cb_ValorizadoManual: TCheckBox;
    eTonCO2xMWh: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFichas: TLabel;
    LVEstado: TLabel;
    LNDisc: TLabel;
    LEImp_Ini_: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    sgFichas: TStringGrid;
    BAgregarFicha: TButton;
    BVerExpandida: TButton;
    BAyuda: TButton;
    eE_Carga_Ini_: TEdit;
    ENDisc: TEdit;
    Panel1: TPanel;
    procedure btEditarUnidadesClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
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

constructor TEditarTBancoDeBaterias01.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TBancoDeBaterias01;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := TBancoDeBaterias01(cosaConNombre);
    inicializarComponentesLPD(
      actor.lpd, TFichaBancoDeBaterias01, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    eE_Carga_Ini_.Text := FloatToStrF(actor.Carga_ini, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    ENDisc.Text := IntToStr(actor.NDisc);
    cb_ValorizadoManual.Checked:= actor.flg_ValorizadoManual;
    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;

    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaBancoDeBaterias01, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cb_ValorizadoManual.Checked:= false;
    cbCleanDevelopmentMechanism.Checked := False;
    cb_CalcularGradienteDeInversion.Checked:= False;
  end;
end;

function TEditarTBancoDeBaterias01.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited validarEditFecha(EFMuerte) and
    inherited validarEditFloat(eE_Carga_Ini_, -MaxNReal, MaxNReal) and
    inherited validarEditInt(ENDisc, 2, MaxInt) and validarEditFloat(
    eTonCO2xMWh, -1000, 1000000);
end;

procedure TEditarTBancoDeBaterias01.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, TBancoDeBaterias01);
end;

procedure TEditarTBancoDeBaterias01.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTBancoDeBaterias01.BGuardarClick(Sender: TObject);
var
  actor: TBancoDeBaterias01;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TBancoDeBaterias01.Create(
        capa,
        EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo), cb_CalcularGradienteDeInversion.Checked, StrToFloat(eE_Carga_Ini_.Text),
        StrToInt(ENDisc.Text),
        cb_ValorizadoManual.Checked,
        StrToFloat(eTonCO2xMWh.Text),
        cbLowCostMustRun.Checked, cbCleanDevelopmentMechanism.Checked);
      actor := TBancoDeBaterias01(cosaConNombre);
    end
    else
    begin
      actor := TBancoDeBaterias01(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.Carga_ini := StrToFloat(eE_Carga_Ini_.Text);
      actor.NDisc := StrToInt(ENDisc.Text);
      actor.flg_ValorizadoManual:= cb_ValorizadoManual.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTBancoDeBaterias01.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTBancoDeBaterias01.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTBancoDeBaterias01.btEditarUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTBancoDeBaterias01.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTBancoDeBaterias01.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.




