unit uAltaEdicionTPostOper_aplicarActualizador;

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
  TAltaEdicionTPostOper_aplicarActualizador = class(TBaseAltaEdicionPostOpers)
    lResultado: TLabel;
    lCronVar: TLabel;
    lActualizador: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    eActualizador: TEdit;
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
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTPostOper_aplicarActualizador.CBCronVarCronVarChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, true);
end;

procedure TAltaEdicionTPostOper_aplicarActualizador.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, true);
end;

Constructor TAltaEdicionTPostOper_aplicarActualizador.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBCronVars(cbParam1, false);

  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_aplicarActualizador(postOper).res);
    setCBCronVar(cbParam1, TPostOper_aplicarActualizador(postOper).param1);
    eActualizador.Text:= FloatToStrF(TPostOper_aplicarActualizador(postOper).aReal, ffGeneral, 16, 10);
  end;
end;

function TAltaEdicionTPostOper_aplicarActualizador.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBCronVars(cbParam1) and
           validarEditFloat(eActualizador, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTPostOper_aplicarActualizador.BAyudaClick(
  Sender: TObject);
begin
  verdoc(Self, TPostOper_aplicarActualizador);
end;

procedure TAltaEdicionTPostOper_aplicarActualizador.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_aplicarActualizador.bGuardarClick(
  Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      postOper:= TPostOper_aplicarActualizador.Create(valorCBCronVar(cbRes),
                                                      valorCBCronVar(cbParam1),
                                                      StrToFloat(eActualizador.Text));
    end
    else
    begin
      TPostOper_aplicarActualizador(postOper).res:= valorCBCronVar(cbRes);
      TPostOper_aplicarActualizador(postOper).param1:= valorCBCronVar(cbParam1);
      TPostOper_aplicarActualizador(postOper).aReal:= StrToFloat(eActualizador.Text);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_aplicarActualizador.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTPostOper_aplicarActualizador.EditFloatExit(
  Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTPostOper_aplicarActualizador.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
