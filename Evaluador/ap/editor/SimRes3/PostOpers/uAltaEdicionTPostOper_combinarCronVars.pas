unit uAltaEdicionTPostOper_combinarCronVars;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
   {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, xMatDefs, uHistoVarsOps, utilidades,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers, uOpcionesSimSEEEdit;

type
  TAltaEdicionTPostOper_combinarCronVars = class(TBaseAltaEdicionPostOpers)
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

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTPostOper_combinarCronVars.CBCronVarParam1Change(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, false);
end;

procedure TAltaEdicionTPostOper_combinarCronVars.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, true);
end;

Constructor TAltaEdicionTPostOper_combinarCronVars.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarSGCronVarCoef(sgParams, tiposColsSGParams, cbParam1, eCoef, BAgregar);

  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_combinarCronVars(postOper).res);
    setSGCronVarCoef(sgParams,
                     TPostOper_combinarCronVars(postOper).params,
                     TPostOper_combinarCronVars(postOper).coeficientes,
                     cbParam1, eCoef, BAgregar);
  end;
  utilidades.AutoSizeTypedColsAndTable(sgParams, tiposColsSGParams, FSimSEEEdit.iconos,
                                       self.ClientWidth, self.ClientHeight, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

function TAltaEdicionTPostOper_combinarCronVars.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarSGCronVar(sgParams, cbParam1);
end;

procedure TAltaEdicionTPostOper_combinarCronVars.BAgregarClick(Sender: TObject);
begin
  inherited addSGCronVarCoef(sgParams, cbParam1, eCoef, -MaxNReal, MaxNReal, BAgregar);
end;

procedure TAltaEdicionTPostOper_combinarCronVars.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TPostOper_combinarCronVars);
end;

procedure TAltaEdicionTPostOper_combinarCronVars.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_combinarCronVars.bGuardarClick(Sender: TObject);
var
  cronVars: TDAOfCronVar;
  coefs: TDAofNReal;
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      valorSGCronVarCoef(sgParams, cronVars, coefs);
      postOper:= TPostOper_combinarCronVars.Create(valorCBCronVar(cbRes),
                                                   cronVars,
                                                   coefs);
    end
    else
    begin
      TPostOper_combinarCronVars(postOper).res:= valorCBCronVar(cbRes);
      valorSGCronVarCoef(sgParams,
                         TPostOper_combinarCronVars(postOper).params,
                         TPostOper_combinarCronVars(postOper).coeficientes);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_combinarCronVars.sgParamsDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGParams[Acol], NIL, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionTPostOper_combinarCronVars.sgParamsMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionTPostOper_combinarCronVars.sgParamsMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGParams);
end;

procedure TAltaEdicionTPostOper_combinarCronVars.sgParamsMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  res: TTipoColumna;
begin
  res:= utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGParams);
  case res of
    TC_btEliminar: eliminarSGCronVarCoef(sgParams, utilidades.filaListado, cbParam1, eCoef, BAgregar);
  end;
end;

end.
