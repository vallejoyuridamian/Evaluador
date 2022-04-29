unit uAltaEdicionTPostOper_acumularCronVar;

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
  TAltaEdicionTPostOper_acumularCronVar = class(TBaseAltaEdicionPostOpers)
    lResultado: TLabel;
    lCronVar: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    procedure BAyudaClick(Sender: TObject);
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
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTPostOper_acumularCronVar.CBCronVarCronVarChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, true);
end;

procedure TAltaEdicionTPostOper_acumularCronVar.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, true);
end;

Constructor TAltaEdicionTPostOper_acumularCronVar.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBCronVars(cbParam1, false);

  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_acumularCronVar(postOper).res);
    setCBCronVar(cbParam1, TPostOper_acumularCronVar(postOper).param1);
  end;
end;

function TAltaEdicionTPostOper_acumularCronVar.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBCronVars(cbParam1);
end;

procedure TAltaEdicionTPostOper_acumularCronVar.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_acumularCronVar);
end;

procedure TAltaEdicionTPostOper_acumularCronVar.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_acumularCronVar.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      postOper:= TPostOper_acumularCronVar.Create(valorCBCronVar(cbRes),
                                                      valorCBCronVar(cbParam1));
    end
    else
    begin
      TPostOper_acumularCronVar(postOper).res:= valorCBCronVar(cbRes);
      TPostOper_acumularCronVar(postOper).param1:= valorCBCronVar(cbParam1);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_acumularCronVar.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.