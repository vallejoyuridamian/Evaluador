unit uAltaEdicionTPostOper_3CronVars;

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
  TAltaEdicionTPostOper_3CronVars = class(TBaseAltaEdicionPostOpers)
    lResultado: TLabel;
    lCronVar1: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    lCronVar2: TLabel;
    cbParam2: TComboBox;
    procedure BAyudaClick(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarResultadoChange(Sender: TObject);
    procedure CBCronVarParam2Change(Sender: TObject);
    procedure cbCronVarParam1Change(Sender: TObject);
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

procedure TAltaEdicionTPostOper_3CronVars.CBCronVarParam2Change(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange3(Sender, cbRes, cbParam1, true);
end;

procedure TAltaEdicionTPostOper_3CronVars.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange3(Sender, cbParam1, cbParam2, true);
end;

procedure TAltaEdicionTPostOper_3CronVars.cbCronVarParam1Change(Sender: TObject);
begin
  inherited cbCronVarComplementarioChange3(Sender, cbRes, cbParam2, true);
end;

Constructor TAltaEdicionTPostOper_3CronVars.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
var
  cv1, cv2, cv3: TCronVar;
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBCronVars(cbParam1, false);
  inicializarCBCronVars(cbParam2, false);

  if postOper <> NIL then
  begin
    lector.paramsPostOper3CronVars(postOper, cv1, cv2, cv3);

    setCBCronVar(cbRes, cv1);
    setCBCronVar(cbParam1, cv2);
    setCBCronVar(cbParam2, cv3);
  end;
end;

function TAltaEdicionTPostOper_3CronVars.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBCronVars(cbParam1) and
           validarCBCronVars(cbParam2);
end;

procedure TAltaEdicionTPostOper_3CronVars.BAyudaClick(Sender: TObject);
begin
  verdoc(self, tipoPostOper);
end;

procedure TAltaEdicionTPostOper_3CronVars.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_3CronVars.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    lector.altaEdicionPostOper3CronVars(tipoPostOper,
                                        postOper,
                                        valorCBCronVar(cbRes),
                                        valorCBCronVar(cbParam1),
                                        valorCBCronVar(cbParam2));
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_3CronVars.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.