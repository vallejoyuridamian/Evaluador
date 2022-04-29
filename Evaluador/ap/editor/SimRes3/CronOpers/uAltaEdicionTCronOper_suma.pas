unit uAltaEdicionTCronOper_suma;

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
  uBaseAltaEdicionCronOpers, uLectorSimRes3Defs, uVerDoc,
  uHistoVarsOps;

type
  TAltaEdicionTCronOper_suma = class(TBaseAltaEdicionCronOpers)
    lResultado: TLabel;
    lIndice: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure CBCronVarChange(Sender: TObject);
    procedure CBIndiceChange(Sender: TObject);
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

procedure TAltaEdicionTCronOper_suma.BGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
      cronOper:= TCronOper_suma.Create(valorCBCronVar(cbRes),
                                       valorCBIndice(cbParam1))
    else
    begin
      TCronOper_suma(cronOper).res:= valorCBCronVar(cbRes);
      TCronOper_suma(cronOper).param1:= valorCBIndice(cbParam1);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_suma.CBCronVarChange(Sender: TObject);
begin
  inherited CBCronVarChange(Sender, true);
end;

procedure TAltaEdicionTCronOper_suma.CBIndiceChange(Sender: TObject);
begin
  inherited CBIndiceChange(Sender, true);
end;

Constructor TAltaEdicionTCronOper_suma.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBIndices(cbParam1, false);

  if cronOper <> NIL then
  begin
    setCBCronVar(cbRes, TCronOper_suma(cronOper).res);
    setCBIndice(cbParam1, TCronOper_suma(cronOper).param1);
  end;
end;

function TAltaEdicionTCronOper_suma.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBIndices(cbParam1);
end;

procedure TAltaEdicionTCronOper_suma.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TCronOper_suma);
end;

procedure TAltaEdicionTCronOper_suma.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_suma.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.