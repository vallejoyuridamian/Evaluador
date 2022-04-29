unit uAltaEdicionTCronOper_promedio;

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
  TAltaEdicionTCronOper_promedio = class(TBaseAltaEdicionCronOpers)
    lResultado: TLabel;
    lIndice: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    procedure BAyudaClick(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure cbCronVarChange(Sender: TObject);
    procedure cbIndiceChange(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper); override;
  end;

var
  AltaEdicionTCronOper_promedio: TAltaEdicionTCronOper_promedio;

implementation

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTCronOper_promedio.cbIndiceChange(Sender: TObject);
begin
  inherited cbIndiceChange(Sender, true);
end;

Constructor TAltaEdicionTCronOper_promedio.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBIndices(cbParam1, false);

  if cronOper <> NIL then
  begin
    setCBCronVar(cbRes, TCronOper_promedio(cronOper).res);
    setCBIndice(cbParam1, TCronOper_promedio(cronOper).param1);
  end;
end;

function TAltaEdicionTCronOper_promedio.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBIndices(cbParam1);
end;

procedure TAltaEdicionTCronOper_promedio.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TCronOper_promedio);
end;

procedure TAltaEdicionTCronOper_promedio.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_promedio.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
      cronOper:= TCronOper_promedio.Create(valorCBCronVar(cbRes),
                                           valorCBIndice(cbParam1))
    else
    begin
      TCronOper_promedio(cronOper).res:= valorCBCronVar(cbRes);
      TCronOper_promedio(cronOper).param1:= valorCBIndice(cbParam1);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_promedio.cbCronVarChange(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, true);
end;

procedure TAltaEdicionTCronOper_promedio.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.