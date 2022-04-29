unit uEditarTBiomasaEmbalsable;

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
  uBiomasaEmbalsable;

type

  { TEditarTBiomasaEmbalsable }

  TEditarTBiomasaEmbalsable = class(TEditarActorConFichas)
    btEditarForzamientos: TButton;
    cbCleanDevelopmentMechanism: TCheckBox;
    cbLowCostMustRun: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    cb_imponer_cvea: TCheckBox;
    cmb_ixA_borne: TComboBox;
    cmb_ixB_borne: TComboBox;
    cmb_ixA_fuente: TComboBox;
    cmb_ixC_borne: TComboBox;
    cmb_ixD_borne: TComboBox;
    cmb_ixB_fuente: TComboBox;
    cmb_ixC_fuente: TComboBox;
    cmb_ixD_fuente: TComboBox;
    eMeses_TOP: TEdit;
    eNPuntos_EA: TEdit;
    eECA_DOPTOP: TEdit;
    eX_EA_inicial: TEdit;
    eTonCO2xMWh: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbl_ixC: TLabel;
    lbl_ixD: TLabel;
    lbl_meses_TOP: TLabel;
    lbl_ECA_DOP: TLabel;
    lbl_X_EA_inicial: TLabel;
    Label11: TLabel;
    lbl_ixA: TLabel;
    lbl_ixB_fuente: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFichas: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    sgFichas: TStringGrid;
    BAgregarFicha: TButton;
    BGuardar: TButton;
    BCancelar: TButton;
    Panel1: TPanel;
    BVerExpandida: TButton;
    BEditorDeUnidades: TButton;
    BAyuda: TButton;
    procedure btEditarForzamientosClick(Sender: TObject);
    procedure cb_imponer_cveaChange(Sender: TObject);
    procedure cmb_ixB_borneChange(Sender: TObject);
    procedure cmb_ixB_fuenteChange(Sender: TObject);
    procedure cmb_ixC_borneChange(Sender: TObject);
    procedure cmb_ixC_fuenteChange(Sender: TObject);
    procedure cmb_ixD_borneChange(Sender: TObject);
    procedure cmb_ixD_fuenteChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure cmb_ixA_fuenteChange(Sender: TObject);
    procedure cmb_ixA_borneChange(Sender: TObject);
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

constructor TEditarTBiomasaEmbalsable.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TBiomasaEmbalsable;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);

  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  inicializarCBFuente(cmb_ixA_fuente, cmb_ixA_borne, True);
  inicializarCBFuente(cmb_ixB_fuente, cmb_ixB_borne, True);
  inicializarCBFuente(cmb_ixC_fuente, cmb_ixC_borne, True);
  inicializarCBFuente(cmb_ixD_fuente, cmb_ixD_borne, True);

  if cosaConNombre <> nil then
  begin
    actor := TBiomasaEmbalsable(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaBiomasaEmbalsable, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);

    self.eX_EA_inicial.Text := FloatToStr(actor.X_EA_inicial);
    self.eECA_DOPTOP.Text := FloatToStr(actor.ECA_DOPTOP);

    self.eMeses_TOP.Text:= IntToStr( actor.meses_TOP );
    self.eNPuntos_EA.Text := IntToStr(actor.NPuntos_EA);

    setCBFuente(cmb_ixA_fuente, cmb_ixA_borne, actor.ixA_fuente,
      actor.ixA_Borne_nombre);
    setCBFuente(cmb_ixB_fuente, cmb_ixB_borne, actor.ixB_fuente,
      actor.ixB_Borne_nombre);
    setCBFuente(cmb_ixC_fuente, cmb_ixC_borne, actor.ixC_fuente,
      actor.ixC_Borne_nombre);
    setCBFuente(cmb_ixD_fuente, cmb_ixD_borne, actor.ixD_fuente,
      actor.ixD_Borne_nombre);

    cb_imponer_cvea.Checked:= actor.flg_imponer_cvea;

    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;

    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);



    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
    guardado := True;
  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaBiomasaEmbalsable, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    self.eX_EA_inicial.Text := '';
    self.eECA_DOPTOP.Text := '';
    self.eMeses_TOP.Text:= IntToStr( 12 );
    self.eNPuntos_EA.Text := '';
    cb_imponer_cvea.Checked:= false;

    cb_CalcularGradienteDeInversion.Checked:= False;

    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
    guardado := False;
  end;
end;

function TEditarTBiomasaEmbalsable.validarFormulario: boolean;
begin
  Result :=
    inherited validarFormulario and validarNombre(EditNombre) and
    validarCBNodo(CBNodo) and validarEditFecha(EFNac) and
    validarEditFecha(EFMuerte) and validarEditFloat(
    eX_EA_inicial) and validarEditFloat(eECA_DOPTOP) and validarEditInt( eMeses_TOP ) and
    validarEditInt(eNPuntos_EA)
    and validarCBFuente( cmb_ixA_fuente, cmb_ixA_borne, 0)
    and validarCBFuente( cmb_ixB_fuente, cmb_ixB_borne, 0)
    and validarCBFuente( cmb_ixC_fuente, cmb_ixC_borne, 0)
    and validarCBFuente( cmb_ixD_fuente, cmb_ixD_borne, 0)
    and validarEditFloat(eTonCO2xMWh, -1000, 1000000);
end;

procedure TEditarTBiomasaEmbalsable.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTBiomasaEmbalsable.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTBiomasaEmbalsable.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTBiomasaEmbalsable.BGuardarClick(Sender: TObject);
var
  actor: TBiomasaEmbalsable;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TBiomasaEmbalsable.Create(
        capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text),
        lpdUnidades, lpd,
        valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        StrToFloat(eECA_DOPTOP.Text),
        StrToInt( eMeses_TOP.text ),
        StrToInt(eNPuntos_EA.Text),
        strToFloat(eX_EA_inicial.Text),
        valorCBFuente(cmb_ixA_fuente),
        valorCBString(cmb_ixA_borne),
        valorCBFuente(cmb_ixB_fuente),
        valorCBString(cmb_ixB_borne),
        valorCBFuente(cmb_ixC_fuente),
        valorCBString(cmb_ixC_borne),
        valorCBFuente(cmb_ixD_fuente),
        valorCBString(cmb_ixD_borne),
        cb_imponer_cvea.checked,
        StrToFloat(eTonCO2xMWh.Text),
        cbLowCostMustRun.Checked,
        cbCleanDevelopmentMechanism.Checked);
      actor := TBiomasaEmbalsable(cosaConNombre);
    end
    else
    begin
      actor := TBiomasaEmbalsable(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.ECA_DOPTOP := StrToFloat(eECA_DOPTOP.Text);
      actor.meses_TOP:= StrToInt( eMeses_TOP.text );
      actor.NPuntos_EA := StrToInt(eNPuntos_EA.Text);
      actor.X_EA_inicial := StrToFloat(eX_EA_inicial.Text);
      actor.ixA_fuente := valorCBFuente(cmb_ixA_fuente);
      actor.ixA_Borne_nombre := valorCBString(cmb_ixA_borne);
      actor.ixB_fuente := valorCBFuente(cmb_ixB_fuente);
      actor.ixB_Borne_nombre := valorCBString(cmb_ixB_borne);
      actor.ixC_fuente := valorCBFuente(cmb_ixC_fuente);
      actor.ixC_Borne_nombre := valorCBString(cmb_ixC_borne);
      actor.ixD_fuente := valorCBFuente(cmb_ixD_fuente);
      actor.ixD_Borne_nombre := valorCBString(cmb_ixD_borne);
      actor.flg_imponer_cvea:= cb_imponer_cvea.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTBiomasaEmbalsable.rgTipoFuenteClick(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTBiomasaEmbalsable.cmb_ixA_borneChange(Sender: TObject);
begin
  inherited CBBorneChange(cmb_ixA_fuente, cmb_ixA_borne);
end;

procedure TEditarTBiomasaEmbalsable.cmb_ixA_fuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, cmb_ixA_borne);
end;

procedure TEditarTBiomasaEmbalsable.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTBiomasaEmbalsable.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTBiomasaEmbalsable.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;

procedure TEditarTBiomasaEmbalsable.cb_imponer_cveaChange(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTBiomasaEmbalsable.cmb_ixB_borneChange(Sender: TObject);
begin
    inherited CBBorneChange(cmb_ixB_fuente, cmb_ixB_borne);
end;


procedure TEditarTBiomasaEmbalsable.cmb_ixB_fuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, cmb_ixB_borne);
end;

procedure TEditarTBiomasaEmbalsable.cmb_ixC_borneChange(Sender: TObject);
begin
    inherited CBBorneChange(cmb_ixC_fuente, cmb_ixC_borne);
end;

procedure TEditarTBiomasaEmbalsable.cmb_ixC_fuenteChange(Sender: TObject);
begin
    inherited CBFuenteChange(Sender, cmb_ixC_borne);
end;

procedure TEditarTBiomasaEmbalsable.cmb_ixD_borneChange(Sender: TObject);
begin
    inherited CBBorneChange(cmb_ixD_fuente, cmb_ixD_borne);
end;

procedure TEditarTBiomasaEmbalsable.cmb_ixD_fuenteChange(Sender: TObject);
begin
    inherited CBFuenteChange(Sender, cmb_ixD_borne);
end;


procedure TEditarTBiomasaEmbalsable.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTBiomasaEmbalsable.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
