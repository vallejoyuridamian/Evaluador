unit uEditarTHidroConEmbalseBinacional;

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
  uHidroConEmbalseBinacional;

type

  { TEditarTHidroConEmbalseBinacional }

  TEditarTHidroConEmbalseBinacional = class(TEditarActorConFichas)
    CBBorneFuenteComprasDelOtroPais: TComboBox;
    cbCleanDevelopmentMechanism: TCheckBox;
    CBFuenteComprasDelOtroPais: TComboBox;
    cbLowCostMustRun: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    eTonCO2xMWh: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LVEstado: TLabel;
    LFichas: TLabel;
    LFuenteDeAportes: TLabel;
    LBorne: TLabel;
    LNDisc: TLabel;
    LHIni: TLabel;
    lNDiscDE: TLabel;
    lDEEIni: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    Panel2: TPanel;
    BAgregarFicha: TButton;
    Panel1: TPanel;
    BVerExpandida: TButton;
    CBFuente: TComboBox;
    CBBorne: TComboBox;
    BAyuda: TButton;
    cb_ValorizadoManual: TCheckBox;
    EHIni: TEdit;
    ENDiscH: TEdit;
    eDEEIni: TEdit;
    eNDiscDE: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    BEditorDeUnidades: TButton;
    sgFichas: TStringGrid;
    procedure CBBorneFuenteComprasDelOtroPaisChange(Sender: TObject);
    procedure CBFuenteComprasDelOtroPaisChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
    procedure CBBorneChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
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

constructor TEditarTHidroConEmbalseBinacional.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: THidroConEmbalseBinacional;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  inicializarCBFuente(CBFuente, CBBorne, False);

  inicializarCBFuente(CBFuenteComprasDelOtroPais, CBBorneFuenteComprasDelOtroPais, False);

  if cosaConNombre <> nil then
  begin
    actor := THidroConEmbalseBinacional(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaHidroConEmbalseBinacional, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    setCBFuente(CBFuente, CBBorne, actor.fuenteDeAportes, actor.nombreBorne);
    setCBFuente(CBFuenteComprasDelOtroPais, CBBorneFuenteComprasDelOtroPais, actor.fuenteDeComprasDeArgentina, actor.nombreBorne_fuenteDeComprasDeArgentina);

    EHIni.Text := FloatToStrF(actor.hini, ffGeneral, CF_PRECISION, CF_DECIMALES);
    ENDiscH.Text := IntToStr(actor.NDiscH);
    eDEEIni.Text := FloatToStrF(actor.dEEini, ffGeneral, CF_PRECISION, CF_DECIMALES);
    eNDiscDE.Text := IntToStr(actor.nDiscDE);

    cb_ValorizadoManual.Checked := actor.flg_ValorizadoManual;


    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaHidroConEmbalseBinacional, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
    cb_CalcularGradienteDeInversion.Checked:= False;

  end;
end;

function TEditarTHidroConEmbalseBinacional.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited validarEditFecha(EFMuerte) and
    inherited validarCBFuente(CBFuente, CBBorne, 0) and
    inherited validarEditFloat(EHIni, 0, MaxNReal) and
    inherited validarEditInt(ENDiscH, 2, MaxInt) and
    inherited validarEditFloat(eDEEIni, -MaxNReal, MaxNReal) and
    inherited validarEditInt(eNDiscDE, 2, MaxInt) and
    validarEditFloat(eTonCO2xMWh, -1000, 1000000) and
    inherited validarCBFuente(CBFuenteComprasDelOtroPais, CBBorneFuenteComprasDelOtroPais, 0);
end;

procedure TEditarTHidroConEmbalseBinacional.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTHidroConEmbalseBinacional.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTHidroConEmbalseBinacional.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTHidroConEmbalseBinacional.BGuardarClick(Sender: TObject);
var
  actor: THidroConEmbalseBinacional;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := THidroConEmbalseBinacional.Create(
        capa,
        EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        StrToFloat(EHIni.Text), StrToFloat(eDEEIni.Text),
        StrToInt(ENDiscH.Text), StrToInt(eNDiscDE.Text), valorCBFuente(CBFuente),
        valorCBString(CBBorne), cb_ValorizadoManual.Checked,
        StrToFloat(eTonCO2xMWh.Text), cbLowCostMustRun.Checked,
        cbCleanDevelopmentMechanism.Checked,valorCBFuente(CBFuenteComprasDelOtroPais),valorCBString(CBBorneFuenteComprasDelOtroPais));

      actor := THidroConEmbalseBinacional(cosaConNombre);
    end
    else
    begin
      actor := THidroConEmbalseBinacional(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.hini := StrToFloat(EHIni.Text);
      actor.NDiscH := StrToInt(ENDiscH.Text);
      actor.dEEini := StrToFloat(eDEEIni.Text);
      actor.nDiscDE := StrToInt(eNDiscDE.Text);
      actor.fuenteDeAportes := valorCBFuente(CBFuente);
      actor.nombreBorne := valorCBString(CBBorne);
      actor.flg_ValorizadoManual := cb_ValorizadoManual.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
      actor.fuenteDeComprasDeArgentina:=valorCBFuente(CBFuenteComprasDelOtroPais);
      actor.nombreBorne_fuenteDeComprasDeArgentina:=valorCBString(CBBorneFuenteComprasDelOtroPais);
    end;
    actor.lpdForzamientos := lpdForzamientos_;

    ModalResult := mrOk;
  end;
end;

procedure TEditarTHidroConEmbalseBinacional.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTHidroConEmbalseBinacional.CBBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne);
end;

procedure TEditarTHidroConEmbalseBinacional.CBFuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

procedure TEditarTHidroConEmbalseBinacional.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTHidroConEmbalseBinacional.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTHidroConEmbalseBinacional.CBFuenteComprasDelOtroPaisChange(
  Sender: TObject);
begin
   inherited CBFuenteChange(Sender, CBBorneFuenteComprasDelOtroPais);
end;

procedure TEditarTHidroConEmbalseBinacional.CBBorneFuenteComprasDelOtroPaisChange
  (Sender: TObject);
begin
   inherited CBBorneChange(CBFuenteComprasDelOtroPais, CBBorneFuenteComprasDelOtroPais);
end;

procedure TEditarTHidroConEmbalseBinacional.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTHidroConEmbalseBinacional.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
