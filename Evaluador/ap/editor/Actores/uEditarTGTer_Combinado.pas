unit uEditarTGTer_Combinado;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls,
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
  xMatDefs, ugter_combinado;

resourcestring
  rsTurbinaGas = 'Turbo-Gas';
  rsTurboVapor = 'Turbo-Vapor';
  rsTurboGas_P = 'Turbo-Gas_P';
  rsTurboVapor_P = 'Turbo-Gas_P';

type

  { TEditarTGTer_Combinado }

  TEditarTGTer_Combinado = class(TEditarActorConFichas)
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
    procedure btEditarForzamientosClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
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

constructor TEditarTGTer_Combinado.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TGTer_combinado;
  etiquetasUnidades: TDAofString;
  etiequetasForzamientos: TDAOfString;
begin
  SetLength(etiquetasUnidades, 2);
  etiquetasUnidades[0] := rsTurbinaGas;
  etiquetasUnidades[1] := rsTurboVapor;

  SetLength(etiquetasForzamientos, 2);
  etiquetasForzamientos[0] := rsTurboGas_P;
  etiquetasForzamientos[1] := rsTurboVapor_P;

  inherited Create(AOwner, sala, tipoCosa, cosaConNombre, etiquetasUnidades,
    etiquetasForzamientos);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := cosaConNombre as TGTer_Combinado;
    inicializarComponentesLPD(actor.lpd, TFichaGTer_combinado, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;
    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;
  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaGTer_combinado, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    cb_CalcularGradienteDeInversion.Checked:= False;

    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
  end;
end;

function TEditarTGTer_Combinado.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and validarEditFloat(eTonCO2xMWh,
    -1000, 1000000);
end;

procedure TEditarTGTer_Combinado.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTGTer_Combinado.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTGTer_Combinado.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTGTer_Combinado.BGuardarClick(Sender: TObject);
var
  actor: TGTer_combinado;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TGTer_combinado.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        StrToFloat(eTonCO2xMWh.Text),
        cbLowCostMustRun.Checked, cbCleanDevelopmentMechanism.Checked);
      actor := cosaConNombre as TGTer_combinado;
    end
    else
    begin
      actor := cosaConNombre as TGTer_combinado;
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;

end;

procedure TEditarTGTer_Combinado.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTGTer_Combinado.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTGTer_Combinado.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;

procedure TEditarTGTer_Combinado.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTGTer_Combinado.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
