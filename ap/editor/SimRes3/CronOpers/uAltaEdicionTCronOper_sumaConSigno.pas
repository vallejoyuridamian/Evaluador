unit uAltaEdicionTCronOper_sumaConSigno;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseAltaEdicionCronOpers, StdCtrls, uLectorSimRes3Defs, uverdoc,
   uHistoVarsOps;

type
  TAltaEdicionTCronOper_sumaConSigno = class(TBaseAltaEdicionCronOpers)
    lResultadoPos: TLabel;
    lIndice: TLabel;
    cbResPos: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    lResultadoNeg: TLabel;
    cbResNeg: TComboBox;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bCancelarClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBIndiceChange(Sender: TObject);
    procedure CBCronVarResPosChange(Sender: TObject);
    procedure CBCronVarResNegChange(Sender: TObject);
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

procedure TAltaEdicionTCronOper_sumaConSigno.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TCronOper_sumaConSigno);
end;

procedure TAltaEdicionTCronOper_sumaConSigno.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_sumaConSigno.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
      cronOper:= TCronOper_sumaConSigno.Create(valorCBCronVar(cbResPos),
                                               valorCBCronVar(cbResNeg),
                                               valorCBIndice(cbParam1))
    else
    begin
      TCronOper_sumaConSigno(cronOper).res:= valorCBCronVar(cbResPos);
      TCronOper_sumaConSigno(cronOper).resNeg:= valorCBCronVar(cbResNeg);
      TCronOper_sumaConSigno(cronOper).param1:= valorCBIndice(cbParam1);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_sumaConSigno.CBCronVarResNegChange(
  Sender: TObject);
begin
  inherited cbCronVarLinkeadoChange(Sender, cbResPos);
end;

procedure TAltaEdicionTCronOper_sumaConSigno.CBCronVarResPosChange(
  Sender: TObject);
begin
  inherited cbCronVarLinkeadoChange(Sender, cbResNeg);
end;

procedure TAltaEdicionTCronOper_sumaConSigno.CBIndiceChange(Sender: TObject);
begin
  inherited CBIndiceChange(Sender, true);
end;

Constructor TAltaEdicionTCronOper_sumaConSigno.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbResPos, false);
  inicializarCBCronVars(cbResNeg, true);
  inicializarCBIndices(cbParam1, false);

  if cronOper <> NIL then
  begin
    setCBCronVarLinkeado(cbResPos, cbResNeg, TCronOper_sumaConSigno(cronOper).res, TCronOper_sumaConSigno(cronOper).resNeg);
    setCBIndice(cbParam1, TCronOper_sumaConSigno(cronOper).param1);
  end;
end;

procedure TAltaEdicionTCronOper_sumaConSigno.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

function TAltaEdicionTCronOper_sumaConSigno.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbResPos) and
           validarCBCronVars(cbResNeg) and
           validarCBIndices(cbParam1);
end;

end.