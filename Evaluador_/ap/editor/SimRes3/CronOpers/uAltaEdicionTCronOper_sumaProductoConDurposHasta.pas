unit uAltaEdicionTCronOper_sumaProductoConDurposHasta;

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
  TAltaEdicionTCronOper_sumaProductoConDurposHasta = class(TBaseAltaEdicionCronOpers)
    lResultado: TLabel;
    lIndice: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    lkPosteHasta: TLabel;
    eKPosteHasta: TEdit;
    procedure EditEnter(Sender: TObject);
    procedure EditIntExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarChange(Sender: TObject);
    procedure CBIndiceChange(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper); override;
  end;

var
  AltaEdicionTCronOper_sumaProductoConDurposHasta: TAltaEdicionTCronOper_sumaProductoConDurposHasta;

implementation
uses
  SimSEEEditMain;

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTCronOper_sumaProductoConDurposHasta.BAyudaClick(
  Sender: TObject);
begin
  verdoc(Self, TCronOper_sumaProductoConDurposHasta);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposHasta.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposHasta.bGuardarClick(
  Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
      cronOper:= TCronOper_sumaProductoConDurposHasta.Create(valorCBCronVar(cbRes),
                                                        valorCBIndice(cbParam1),
                                                        StrToInt(eKPosteHasta.Text))
    else
    begin
      TCronOper_sumaProductoConDurposHasta(cronOper).res:= valorCBCronVar(cbRes);
      TCronOper_sumaProductoConDurposHasta(cronOper).param1:= valorCBIndice(cbParam1);
      TCronOper_sumaProductoConDurposHasta(cronOper).kposteHasta:= StrToInt(eKPosteHasta.Text);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposHasta.CBCronVarChange(
  Sender: TObject);
begin
  inherited CBCronVarChange(Sender, true);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposHasta.CBIndiceChange(
  Sender: TObject);
begin
  inherited CBIndiceChange(Sender, true);
end;

Constructor TAltaEdicionTCronOper_sumaProductoConDurposHasta.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBIndices(cbParam1, false);

  if cronOper <> NIL then
  begin
    setCBCronVar(cbRes, TCronOper_sumaProductoConDurposHasta(cronOper).res);
    setCBIndice(cbParam1, TCronOper_sumaProductoConDurposHasta(cronOper).param1);
    eKPosteHasta.Text:= IntToStr(TCronOper_sumaProductoConDurposHasta(cronOper).kposteHasta)
  end;
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposHasta.EditEnter(
  Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposHasta.EditIntExit(
  Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, FSimSEEEdit.sala.globs.NPostes);
end;

procedure TAltaEdicionTCronOper_sumaProductoConDurposHasta.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

function TAltaEdicionTCronOper_sumaProductoConDurposHasta.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBIndices(cbParam1) and
           validarEditInt(eKPosteHasta, 1, FSimSEEEdit.sala.globs.NPostes);
end;

end.