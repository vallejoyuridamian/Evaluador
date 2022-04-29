unit uAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xMatDefs,
  uBaseAltaEdicionCronOpers, uLectorSimRes3Defs, uVerDoc,
  uHistoVarsOps;

type

  { TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado }

  TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado = class(TBaseAltaEdicionCronOpers)
    cbModoComp: TCheckBox;
    cb_AcumProducto: TCheckBox;
    lResultado: TLabel;
    lIndice: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    lRecorte: TLabel;
    cbRecorte: TComboBox;
    eTopeDe2: TEdit;
    lTopeDe2: TLabel;
    lIndice2: TLabel;
    cbParam2: TComboBox;
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarResChange(Sender: TObject);
    procedure CBCronVarRecorteChange(Sender: TObject);
    procedure CBIndice2Change(Sender: TObject);
    procedure CBIndice1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.CBCronVarRecorteChange(
  Sender: TObject);
begin
  inherited cbCronVarLinkeadoChange(Sender, cbRes);
end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.CBCronVarResChange(
  Sender: TObject);
begin
  inherited cbCronVarLinkeadoChange(Sender, cbRecorte);
end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.CBIndice1Change(
  Sender: TObject);
begin
  inherited cbIndiceLinkeadoChange(Sender, cbParam2);
end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.FormCreate(
  Sender: TObject);
begin

end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.CBIndice2Change(
  Sender: TObject);
begin
  inherited cbIndiceLinkeadoChange(Sender, cbParam1);
end;

Constructor TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBCronVars(cbRecorte, True);
  inicializarCBIndices(cbParam1, false);
  inicializarCBIndices(cbParam2, False);

  if cronOper <> NIL then
  begin
    setCBCronVarLinkeado(cbRes, cbRecorte, TCronOper_sumaDobleProductoConDurposTopeado(cronOper).res, TCronOper_sumaDobleProductoConDurposTopeado(cronOper).resRecorte);
    setCBIndiceLinkeado(cbParam1, cbParam2, TCronOper_sumaDobleProductoConDurposTopeado(cronOper).param1, TCronOper_sumaDobleProductoConDurposTopeado(cronOper).param2);
    eTopeDe2.Text:= FloatToStrF(TCronOper_sumaDobleProductoConDurposTopeado(cronOper).TopeDe2, ffGeneral, 16, 10);
    cbModoComp.Checked := TCronOper_sumaDobleProductoConDurposTopeado(cronOper).modoComparativo_;
    cb_AcumProducto.Checked := TCronOper_sumaDobleProductoConDurposTopeado(cronOper).flg_acumProducto;
  end;
end;

function TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBCronVars(cbRecorte) and
           validarCBIndices(cbParam1) and
           validarCBIndices(cbParam2) and
           validarEditFloat(eTopeDe2, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TCronOper_sumaDobleProductoConDurposTopeado);
end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.bGuardarClick(
  Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
      cronOper:= TCronOper_sumaDobleProductoConDurposTopeado.Create(valorCBCronVar(cbRes),
                                                               valorCBCronVar(cbRecorte),
                                                               valorCBIndice(cbParam1),
                                                               valorCBIndice(cbParam2),
                                                               StrToFloat(eTopeDe2.Text),
                                                               cbModoComp.Checked, cb_AcumProducto.Checked)
    else
    begin
      TCronOper_sumaDobleProductoConDurposTopeado(cronOper).res:= valorCBCronVar(cbRes);
      TCronOper_sumaDobleProductoConDurposTopeado(cronOper).resRecorte:= valorCBCronVar(cbRecorte);
      TCronOper_sumaDobleProductoConDurposTopeado(cronOper).param1:= valorCBIndice(cbParam1);
      TCronOper_sumaDobleProductoConDurposTopeado(cronOper).param2:= valorCBIndice(cbParam2);
      TCronOper_sumaDobleProductoConDurposTopeado(cronOper).TopeDe2:= StrToFloat(eTopeDe2.Text);
      TCronOper_sumaDobleProductoConDurposTopeado(cronOper).modoComparativo_:= cbModoComp.Checked;
      TCronOper_sumaDobleProductoConDurposTopeado(cronOper).flg_acumProducto:= cb_AcumProducto.Checked;
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
