unit uAltaEdicionTCronOper_promedioPonderadoPorDurpos;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  uBaseAltaEdicionCronOpers, uHistoVarsOps, uverdoc, uLectorSimRes3Defs;

type
  TAltaEdicionTCronOper_promedioPonderadoPorDurPos = class(TBaseAltaEdicionCronOpers)
    lResultado: TLabel;
    lIndice: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BAyudaClick(Sender: TObject);
    procedure cbIndiceChange(Sender: TObject);
    procedure CBCronVarChange(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper); override;
  end;

implementation

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

Constructor TAltaEdicionTCronOper_promedioPonderadoPorDurPos.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBIndices(cbParam1, false);

  if cronOper <> NIL then
  begin
    setCBCronVar(cbRes, TCronOper_promedioPonderadoPorDurpos(cronOper).res);
    setCBIndice(cbParam1, TCronOper_promedioPonderadoPorDurpos(cronOper).param1);
  end;
end;

function TAltaEdicionTCronOper_promedioPonderadoPorDurPos.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBIndices(cbParam1);
end;

procedure TAltaEdicionTCronOper_promedioPonderadoPorDurPos.BAyudaClick(
  Sender: TObject);
begin
  verdoc(self, TCronOper_promedioPonderadoPorDurpos);
end;

procedure TAltaEdicionTCronOper_promedioPonderadoPorDurPos.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_promedioPonderadoPorDurPos.bGuardarClick(
  Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
      cronOper:= TCronOper_promedioPonderadoPorDurpos.Create(valorCBCronVar(cbRes),
                                                             valorCBIndice(cbParam1))
    else
    begin
      TCronOper_promedioPonderadoPorDurpos(cronOper).res:= valorCBCronVar(cbRes);
      TCronOper_promedioPonderadoPorDurpos(cronOper).param1:= valorCBIndice(cbParam1);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_promedioPonderadoPorDurPos.CBCronVarChange(
  Sender: TObject);
begin
  inherited CBCronVarChange(Sender, true);
end;

procedure TAltaEdicionTCronOper_promedioPonderadoPorDurPos.cbIndiceChange(
  Sender: TObject);
begin
  inherited CBIndiceChange(Sender, true);
end;

procedure TAltaEdicionTCronOper_promedioPonderadoPorDurPos.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.