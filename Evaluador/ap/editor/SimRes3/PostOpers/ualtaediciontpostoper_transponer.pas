unit uAltaEdicionTPostOper_Transponer;

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
  TAltaEdicionTPostOper_Transponer = class(TBaseAltaEdicionPostOpers)
    lResultado: TLabel;
    lCronVar: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarResultadoChange(Sender: TObject);
    procedure CBCronVarCronVarChange(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper); override;
  end;

implementation

{$IFNDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTPostOper_Transponer.CBCronVarCronVarChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, true);
end;

procedure TAltaEdicionTPostOper_Transponer.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, true);
end;

Constructor TAltaEdicionTPostOper_Transponer.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBCronVars(cbParam1, false);

  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_Transponer(postOper).res);
    setCBCronVar(cbParam1, TPostOper_Transponer(postOper).param1);
  end;
end;

function TAltaEdicionTPostOper_Transponer.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBCronVars(cbParam1);
end;

procedure TAltaEdicionTPostOper_Transponer.BAyudaClick(
  Sender: TObject);
begin
  verdoc(Self, TPostOper_Transponer);
end;

procedure TAltaEdicionTPostOper_Transponer.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_Transponer.bGuardarClick(
  Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      postOper:= TPostOper_Transponer.Create(valorCBCronVar(cbRes),
                                                      valorCBCronVar(cbParam1));
    end
    else
    begin
      TPostOper_Transponer(postOper).res:= valorCBCronVar(cbRes);
      TPostOper_Transponer(postOper).param1:= valorCBCronVar(cbParam1);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_Transponer.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTPostOper_Transponer.EditFloatExit(
  Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTPostOper_Transponer.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
