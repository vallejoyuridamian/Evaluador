unit uAltaEdicionTPostOper_combinarDespCronVars;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFDEF FPC-LCL}
  LResources,
{$ENDIF}

   {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, xMatDefs, uHistoVarsOps, utilidades,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers, uOpcionesSimSEEEdit;

type
  TAltaEdicionTPostOper_combinarDespCronVars = class(TBaseAltaEdicionPostOpers)
    lResultado: TLabel;
    lCronVar: TLabel;
    lCoeficiente: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    sgParams: TStringGrid;
    BAgregar: TButton;
    eCoef: TEdit;
    lDesp: TLabel;
    eDesp: TEdit;
    procedure BAyudaClick(Sender: TObject);
    procedure BAgregarClick(Sender: TObject);
    procedure sgParamsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgParamsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgParamsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sgParamsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarResultadoChange(Sender: TObject);
    procedure CBCronVarParam1Change(Sender: TObject);
  private
    tiposColsSGParams: TDAOfTTipoColumna;
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper); override;

  end;

implementation

uses SimSEEEditMain;
{$IFNDEF FPC-LCL}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTPostOper_combinarDespCronVars.CBCronVarParam1Change(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, false);
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, true);
end;

Constructor TAltaEdicionTPostOper_combinarDespCronVars.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarSGCronVarCoefDesp(sgParams, tiposColsSGParams, cbParam1, eCoef, eDesp, BAgregar);

  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_combinarCronVars(postOper).res);
    setSGCronVarCoefDesp(sgParams,
                         TPostOper_combinarDespCronVars(postOper).params,
                         TPostOper_combinarDespCronVars(postOper).coeficientes,
                         TPostOper_combinarDespCronVars(postOper).desplazamientos,
                         cbParam1, eCoef, eDesp, BAgregar);
  end;
  utilidades.AutoSizeTypedColsAndTable(sgParams, tiposColsSGParams, FSimSEEEdit.iconos,
                                       self.ClientWidth, self.ClientHeight, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

function TAltaEdicionTPostOper_combinarDespCronVars.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarSGCronVar(sgParams, cbParam1);
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.BAgregarClick(
  Sender: TObject);
begin
  addSGCronVarCoefDesp(sgParams, cbParam1, eCoef, -MaxNReal, MaxNReal, eDesp, -MaxInt, MaxInt, BAgregar);
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.BAyudaClick(
  Sender: TObject);
begin
  verdoc(Self, TPostOper_combinarDespCronVars);
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.bGuardarClick(
  Sender: TObject);
var
  cronVars: TDAOfCronVar;
  coefs: TDAofNReal;
  desplazamientos: TDAofNInt;
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      valorSGCronVarCoefDesp(sgParams, cronVars, coefs, desplazamientos);
      postOper:= TPostOper_combinarDespCronVars.Create(valorCBCronVar(cbRes),
                                                       cronVars,
                                                       coefs,
                                                       desplazamientos);
    end
    else
    begin
      TPostOper_combinarDespCronVars(postOper).res:= valorCBCronVar(cbRes);
      valorSGCronVarCoefDesp(sgParams,
                             TPostOper_combinarDespCronVars(postOper).params,
                             TPostOper_combinarDespCronVars(postOper).coeficientes,
                             TPostOper_combinarDespCronVars(postOper).desplazamientos);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.sgParamsDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGParams[Acol], NIL, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.sgParamsMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.sgParamsMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGParams);
end;

procedure TAltaEdicionTPostOper_combinarDespCronVars.sgParamsMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  res: TTipoColumna;
begin
  res:= utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGParams);
  case res of
    TC_btEliminar: eliminarSGCronVarCoefDesp(sgParams, utilidades.filaListado, cbParam1, eCoef, eDesp, BAgregar);
  end;
end;

initialization
end.
