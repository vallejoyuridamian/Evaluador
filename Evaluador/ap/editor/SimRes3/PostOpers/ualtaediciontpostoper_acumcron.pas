unit uAltaEdicionTPostOper_AcumCron;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, xMatDefs, uHistoVarsOps,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers;

type

  { TAltaEdicionTPostOper_AcumCron }

  TAltaEdicionTPostOper_AcumCron = class(TBaseAltaEdicionPostOpers)
    cbPromediar: TCheckBox;
    GroupBox1: TGroupBox;
    lResultado: TLabel;
    lCronVar: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    rbDeIzquierdaADerecha: TRadioButton;
    rbDeDerechaAIzquierda: TRadioButton;
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarResultadoChange(Sender: TObject);
    procedure CBCronVarCronVarChange(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs;
      postOper: TPostOper; tipoPostOper: TClaseDePostOper); override;
  end;

implementation

{$IFNDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTPostOper_AcumCron.CBCronVarCronVarChange(Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, True);
end;

procedure TAltaEdicionTPostOper_AcumCron.CBCronVarResultadoChange(Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, True);
end;

constructor TAltaEdicionTPostOper_AcumCron.Create(AOwner: TComponent;
  lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, False);
  inicializarCBCronVars(cbParam1, False);

  if postOper <> nil then
  begin
    setCBCronVar(cbRes, TPostOper_AcumCron(postOper).res);
    setCBCronVar(cbParam1, TPostOper_AcumCron(postOper).param1);
    cbPromediar.Checked := TPostOper_AcumCron(postOper).flgPromediar;
    if TPostOper_AcumCron(postOper).sentido = SAC_DeDerechaAIzquierda then
      rbDeDerechaAIzquierda.Checked:=True
    else
      rbDeIzquierdaADerecha.Checked:=True;
  end;
end;

function TAltaEdicionTPostOper_AcumCron.validarFormulario: boolean;
begin
  Result := validarCBCronVars(cbRes) and validarCBCronVars(cbParam1);
end;

procedure TAltaEdicionTPostOper_AcumCron.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_AcumCron);
end;

procedure TAltaEdicionTPostOper_AcumCron.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_AcumCron.bGuardarClick(Sender: TObject);
var
  sentido: TSentidoAcumCron;
begin
  if validarFormulario then
  begin
    if rbDeDerechaAIzquierda.Checked then
      sentido := SAC_DeDerechaAIzquierda
    else
      sentido := SAC_DeIzquierdaADerecha;

    if postOper = nil then
    begin
      postOper := TPostOper_AcumCron.Create(valorCBCronVar(cbRes),
        valorCBCronVar(cbParam1),
        cbPromediar.Checked,
        sentido);
    end
    else
    begin
      TPostOper_AcumCron(postOper).res := valorCBCronVar(cbRes);
      TPostOper_AcumCron(postOper).param1 := valorCBCronVar(cbParam1);
      TPostOper_AcumCron(postOper).flgPromediar := cbPromediar.Checked;
      TPostOper_AcumCron(postOper).sentido := sentido;
    end;
    ModalResult := mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_AcumCron.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTPostOper_AcumCron.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTPostOper_AcumCron.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
