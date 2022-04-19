unit uAltaEdicionTPostOper_CVaR;
interface

uses
{$IFDEF WINDOWS}
  Windows,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xMatDefs, uHistoVarsOps,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers, ExtCtrls;

type

  { TAltaEdicionTPostOper_CVaR }

  TAltaEdicionTPostOper_CVaR = class(TBaseAltaEdicionPostOpers)
    ep1: TLabeledEdit;
    ep2: TLabeledEdit;
    lResultado: TLabel;
    lCronVar: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    BAyuda: TButton;
    Panel1: TPanel;
    bGuardar: TButton;
    bCancelar: TButton;
    rbg_PreOrdenar: TRadioGroup;
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
  {$R *.lfm}

procedure TAltaEdicionTPostOper_CVaR.CBCronVarCronVarChange(Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, True);
end;

procedure TAltaEdicionTPostOper_CVaR.CBCronVarResultadoChange(Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, True);
end;

constructor TAltaEdicionTPostOper_CVaR.Create(AOwner: TComponent;
  lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, False);
  inicializarCBCronVars(cbParam1, False);

  if postOper <> nil then
  begin
    setCBCronVar(cbRes, TPostOper_CVaR(postOper).res);
    setCBCronVar(cbParam1, TPostOper_CVaR(postOper).param1);
    ep1.Text:= FloatToStrF(TPostOper_CVaR(postOper).p1, ffGeneral, 12, 6);
    ep2.Text:= FloatToStrF(TPostOper_CVaR(postOper).p2, ffGeneral, 12, 6);
    rbg_PreOrdenar.ItemIndex:= 1 - TPostOper_CVaR(postOper).PreOrdenar;
  end;
end;

function TAltaEdicionTPostOper_CVaR.validarFormulario: boolean;
begin
  Result := validarCBCronVars(cbRes) and validarCBCronVars(cbParam1) and
    validarEditFloat(eP1, 0, 1) and validarEditFloat(eP2, 0, 1);
end;

procedure TAltaEdicionTPostOper_CVaR.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_CVaR);
end;

procedure TAltaEdicionTPostOper_CVaR.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_CVaR.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = nil then
    begin
      postOper := TPostOper_CVaR.Create(valorCBCronVar(cbRes),
        valorCBCronVar(cbParam1),
        StrToFloat(eP1.Text),
        StrToFloat(eP2.Text),
        1- rbg_PreOrdenar.ItemIndex );
    end
    else
    begin
      TPostOper_CVaR(postOper).res := valorCBCronVar(cbRes);
      TPostOper_CVaR(postOper).param1 := valorCBCronVar(cbParam1);
      TPostOper_CVaR(postOper).p1 := StrToFloat(ep1.Text);
      TPostOper_CVaR(postOper).p2 := StrToFloat(ep2.Text);
      TPostOper_CVaR(postOper).PreOrdenar := 1- rbg_PreOrdenar.ItemIndex;
    end;
    ModalResult := mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_CVaR.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTPostOper_CVaR.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, 0.01, MaxNReal);
end;

procedure TAltaEdicionTPostOper_CVaR.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);

begin
  inherited FormCloseQuery(Sender, CanClose);
end;

initialization
end.
