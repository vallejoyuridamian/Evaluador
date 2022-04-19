unit ueditartgsimple_bicombustible;

interface
uses
{$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids,
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
  ugsimple_bicombustible;

type

  { TEditarTGsimple_biCombustible }

  TEditarTGsimple_biCombustible = class(TEditarActorConFichas)
    btEditarForzamientos: TButton;
    cbCleanDevelopmentMechanism: TCheckBox;
    cbLowCostMustRun: TCheckBox;
    cbNodoCombA: TComboBox;
    cbNodoCombB: TComboBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    eTonCO2xMWh: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    lbNodoCombA: TLabel;
    lbNodoCombB: TLabel;
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
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure LEficienciaAClick(Sender: TObject);
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

constructor TEditarTGsimple_biCombustible.Create(AOwner: TComponent; sala: TSalaDeJuego;
  tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TGSimple_BiCombustible;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  inicializarCBNodos(CBNodo, False);

  inicializarCBNodosCombustibleLinkeados(
     cbNodoCombA, cbNodoCombB);


  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);

  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := TGSimple_BiCombustible( cosaConNombre );
    inicializarComponentesLPD(actor.lpd,
      TFichaGSimple_BiCombustible, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);


    EditNombre.Text := actor.nombre;

    setCBNodo(CBNodo, actor.Nodo);

    setCBNodoCombustibleLinkeado(
     cbNodoCombA,
     cbNodoCombB,
      actor.NodoCombA,
      actor.NodoCombB);


    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;


    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
  end
  else
  begin

    inicializarComponentesLPD(nil, TFichaGSimple_BiCombustible, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    cb_CalcularGradienteDeInversion.Checked:= False;

    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
  end;
end;

function TEditarTGsimple_biCombustible.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and validarEditFloat(
    eTonCO2xMWh, -1000, 1000000)   ;
end;

procedure TEditarTGsimple_biCombustible.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTGsimple_biCombustible.LEficienciaAClick(Sender: TObject);
begin

end;

procedure TEditarTGsimple_biCombustible.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTGsimple_biCombustible.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTGsimple_biCombustible.BGuardarClick(Sender: TObject);
var
  actor: TGSimple_BiCombustible;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TGSimple_BiCombustible.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades,
        lpd, valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        valorCBNodoCombustible(cbNodoCombA), valorCBNodoCombustible(cbNodoCombB),
        StrToFloat(eTonCO2xMWh.Text),
        cbLowCostMustRun.Checked, cbCleanDevelopmentMechanism.Checked);
      actor := TGSimple_BiCombustible(cosaConNombre);
    end
    else
    begin
      actor := TGSimple_BiCombustible(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.NodoCombA := valorCBNodoCombustible(cbNodoCombA);
      actor.NodoCombB := valorCBNodoCombustible(cbNodoCombB);
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTGsimple_biCombustible.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTGsimple_biCombustible.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTGsimple_biCombustible.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;

procedure TEditarTGsimple_biCombustible.BAgregarFichaClick(Sender: TObject);
begin
  inherited BAgregarFichaClick(Sender);
end;

procedure TEditarTGsimple_biCombustible.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTGsimple_biCombustible.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
