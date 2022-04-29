unit uAltaEdicionTPostOper_2CronVarsUnReal;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
   {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xMatDefs, uHistoVarsOps,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers;

type
  TAltaEdicionTPostOper_2CronVarsUnReal = class(TBaseAltaEdicionPostOpers)
    lResultado: TLabel;
    lCronVar: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    eReal: TEdit;
    lReal: TLabel;
    procedure BAyudaClick(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarResultadoChange(Sender: TObject);
    procedure CBCronVarParam1Change(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper); override;
  end;

implementation

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTPostOper_2CronVarsUnReal.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    lector.altaEdicionPostOper2CronVarsUnReal(tipoPostOper,
                                              postOper,
                                              valorCBCronVar(cbRes),
                                              valorCBCronVar(cbParam1),
                                              StrToFloat(eReal.Text));
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_2CronVarsUnReal.CBCronVarParam1Change(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, true);
end;

procedure TAltaEdicionTPostOper_2CronVarsUnReal.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, true);
end;

Constructor TAltaEdicionTPostOper_2CronVarsUnReal.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
var
  cv1, cv2: TCronVar;
  real: NReal;
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBCronVars(cbParam1, false);

  if postOper <> NIL then
  begin
    lector.paramsPostOper2CronVarsUnReal(postOper, cv1, cv2, real);
    
    setCBCronVar(cbRes, cv1);
    setCBCronVar(cbParam1, cv2);
    eReal.Text:= FloatToStrF(real, ffGeneral, 16, 10);
  end;
end;

function TAltaEdicionTPostOper_2CronVarsUnReal.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBCronVars(cbParam1) and
           validarEditFloat(eReal, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTPostOper_2CronVarsUnReal.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, tipoPostOper);
end;

procedure TAltaEdicionTPostOper_2CronVarsUnReal.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_2CronVarsUnReal.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TAltaEdicionTPostOper_2CronVarsUnReal.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTPostOper_2CronVarsUnReal.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTPostOper_2CronVarsUnReal.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.