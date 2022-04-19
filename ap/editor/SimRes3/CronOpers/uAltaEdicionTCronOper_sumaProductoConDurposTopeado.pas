unit uAltaEdicionTCronOper_sumaProductoConDurposTopeado;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, stdCtrls, xMatDefs,
  uBaseAltaEdicionCronOpers, uLectorSimRes3Defs, uVerDoc,
  uHistoVarsOps;

type
  TAltaEdicionTCronOper_sumaProductoConDurposTopeado = class(TBaseAltaEdicionCronOpers)
    lResultado: TLabel;
    lIndice: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    lRecorte: TLabel;
    cbRecorte: TComboBox;
    eTopeDe1: TEdit;
    lTopeDe1: TLabel;
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBIndiceChange(Sender: TObject);
    procedure CBCronVarResChange(Sender: TObject);
    procedure CBCronVarRecorteChange(Sender: TObject);
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

procedure TAltaEdicionTCronOper_sumaProductoConDurposTopeado.CBCronVarRecorteChange(
  Sender: TObject);
begin
  inherited cbCronVarLinkeadoChange(Sender, cbRes);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposTopeado.CBCronVarResChange(
  Sender: TObject);
begin
  inherited cbCronVarLinkeadoChange(Sender, cbRecorte);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposTopeado.CBIndiceChange(
  Sender: TObject);
begin
  inherited CBIndiceChange(Sender, true);
end;

Constructor TAltaEdicionTCronOper_sumaProductoConDurposTopeado.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBCronVars(cbRecorte, True);
  inicializarCBIndices(cbParam1, false);

  if cronOper <> NIL then
  begin
    setCBCronVarLinkeado(cbRes, cbRecorte, TCronOper_sumaProductoConDurposTopeado(cronOper).res, TCronOper_sumaProductoConDurposTopeado(cronOper).resRecorte);
    setCBIndice(cbParam1, TCronOper_sumaProductoConDurposTopeado(cronOper).param1);
    eTopeDe1.Text:= FloatToStrF(TCronOper_sumaProductoConDurposTopeado(cronOper).TopeDe1, ffGeneral, 16, 10);
  end;
end;

function TAltaEdicionTCronOper_sumaProductoConDurposTopeado.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBCronVars(cbRecorte) and
           validarCBIndices(cbParam1) and
           validarEditFloat(eTopeDe1, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposTopeado.BAyudaClick(
  Sender: TObject);
begin
  verdoc(Self, TCronOper_sumaProductoConDurposTopeado);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposTopeado.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposTopeado.bGuardarClick(
  Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
      cronOper:= TCronOper_sumaProductoConDurposTopeado.Create(valorCBCronVar(cbRes),
                                                               valorCBCronVar(cbRecorte),
                                                               valorCBIndice(cbParam1),
                                                               StrToFloat(eTopeDe1.Text))
    else
    begin
      TCronOper_sumaProductoConDurposTopeado(cronOper).res:= valorCBCronVar(cbRes);
      TCronOper_sumaProductoConDurposTopeado(cronOper).resRecorte:= valorCBCronVar(cbRecorte);
      TCronOper_sumaProductoConDurposTopeado(cronOper).param1:= valorCBIndice(cbParam1);
      TCronOper_sumaProductoConDurposTopeado(cronOper).TopeDe1:= StrToFloat(eTopeDe1.Text)
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposTopeado.EditEnter(
  Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposTopeado.EditFloatExit(
  Sender: TObject);
begin
  inherited EditFloatExit(eTopeDe1, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposTopeado.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.