unit uAltaEdicionTCronOper_sumaProductoConDurpos;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  uBaseAltaEdicionCronOpers, uLectorSimRes3Defs, uVerDoc,
  uHistoVarsOps, StdCtrls;

type
  TAltaEdicionTCronOper_sumaProductoConDurpos = class(TBaseAltaEdicionCronOpers)
    lResultado: TLabel;
    lIndice: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    procedure BAyudaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
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

procedure TAltaEdicionTCronOper_sumaProductoConDurpos.BAyudaClick(
  Sender: TObject);
begin
  verdoc(self, TCronOper_sumaProductoConDurpos);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurpos.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurpos.bGuardarClick(
  Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
      cronOper:= TCronOper_sumaProductoConDurpos.Create(valorCBCronVar(cbRes),
                                                        valorCBIndice(cbParam1))
    else
    begin
      TCronOper_sumaProductoConDurpos(cronOper).res:= valorCBCronVar(cbRes);
      TCronOper_sumaProductoConDurpos(cronOper).param1:= valorCBIndice(cbParam1);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurpos.CBCronVarChange(
  Sender: TObject);
begin
  inherited CBCronVarChange(Sender, true);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurpos.CBIndiceChange(
  Sender: TObject);
begin
  inherited CBIndiceChange(Sender, true);
end;

Constructor TAltaEdicionTCronOper_sumaProductoConDurpos.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBIndices(cbParam1, false);

  if cronOper <> NIL then
  begin
    setCBCronVar(cbRes, TCronOper_sumaProductoConDurpos(cronOper).res);
    setCBIndice(cbParam1, TCronOper_sumaProductoConDurpos(cronOper).param1);
  end;
end;

function TAltaEdicionTCronOper_sumaProductoConDurpos.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBIndices(cbParam1);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurpos.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.