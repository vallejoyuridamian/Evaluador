unit uAltaEdicionTPostOper_Enventanar;
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

  { TAltaEdicionTPostOper_Enventanar }

  TAltaEdicionTPostOper_Enventanar = class(TBaseAltaEdicionPostOpers)
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

procedure TAltaEdicionTPostOper_Enventanar.CBCronVarCronVarChange(Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, True);
end;

procedure TAltaEdicionTPostOper_Enventanar.CBCronVarResultadoChange(Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, True);
end;

constructor TAltaEdicionTPostOper_Enventanar.Create(AOwner: TComponent;
  lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, False);
  inicializarCBCronVars(cbParam1, False);

  if postOper <> nil then
  begin
    setCBCronVar(cbRes, TPostOper_Enventanar(postOper).res);
    setCBCronVar(cbParam1, TPostOper_Enventanar(postOper).param1);
    ep1.Text:= FloatToStrF(TPostOper_Enventanar(postOper).pIni, ffGeneral, 12, 6);
    ep2.Text:= FloatToStrF(TPostOper_Enventanar(postOper).pFin, ffGeneral, 12, 6);
  end;
end;

function TAltaEdicionTPostOper_Enventanar.validarFormulario: boolean;
begin
  Result := validarCBCronVars(cbRes) and validarCBCronVars(cbParam1) and
    validarEditFloat(eP1, 0, 1) and validarEditFloat(eP2, 0, 1);
end;

procedure TAltaEdicionTPostOper_Enventanar.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_Enventanar);
end;

procedure TAltaEdicionTPostOper_Enventanar.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_Enventanar.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = nil then
    begin
      postOper := TPostOper_Enventanar.Create(valorCBCronVar(cbRes),
        valorCBCronVar(cbParam1),
        StrToFloat(eP1.Text),
        StrToFloat(eP2.Text));
    end
    else
    begin
      TPostOper_Enventanar(postOper).res := valorCBCronVar(cbRes);
      TPostOper_Enventanar(postOper).param1 := valorCBCronVar(cbParam1);
      TPostOper_Enventanar(postOper).pIni := StrToFloat(ep1.Text);
      TPostOper_Enventanar(postOper).pFin := StrToFloat(ep2.Text);
    end;
    ModalResult := mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_Enventanar.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTPostOper_Enventanar.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, 0.01, MaxNReal);
end;

procedure TAltaEdicionTPostOper_Enventanar.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);

begin
  inherited FormCloseQuery(Sender, CanClose);
end;

initialization
end.
