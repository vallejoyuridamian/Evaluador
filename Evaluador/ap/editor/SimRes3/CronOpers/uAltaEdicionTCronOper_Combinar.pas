unit uAltaEdicionTCronOper_Combinar;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, uBaseAltaEdicionCronOpers, uLectorSimRes3Defs, uverdoc,
  uHistoVarsOps, utilidades, xmatdefs, uConstantesSimSEE, uOpcionesSimSEEEdit;

type
  TAltaEdicionTCronOper_Combinar = class(TBaseAltaEdicionCronOpers)
    lResultado: TLabel;
    lIndice: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    sgParams: TStringGrid;
    BAgregar: TButton;
    lCoeficiente: TLabel;
    eCoef: TEdit;
    procedure BAgregarClick(Sender: TObject);
    procedure sgParamsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sgParamsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgParamsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgParamsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BAyudaClick(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarChange(Sender: TObject);
    procedure CBIndiceChange(Sender: TObject);
  private
    tiposColsSGParams: TDAOfTTipoColumna;
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);  override;
  end;

implementation

uses SimSEEEditMain;

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTCronOper_Combinar.BAgregarClick(Sender: TObject);
begin
  addSGIndiceCoef(sgParams, cbParam1, eCoef, -MaxNReal, MaxNReal, BAgregar);
end;

procedure TAltaEdicionTCronOper_Combinar.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TCronOper_Combinar);
end;

procedure TAltaEdicionTCronOper_Combinar.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_Combinar.bGuardarClick(Sender: TObject);
var
  indices: TDAOfTVarIdxs;
  coefs: TDAofNReal;
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
    begin
      valorSGIndiceCoef(sgParams, indices, coefs);
      cronOper:= TCronOper_Combinar.Create(valorCBCronVar(cbRes),
                                           indices,
                                           coefs);
    end
    else
    begin
      TCronOper_Combinar(cronOper).res:= valorCBCronVar(cbRes);
      valorSGIndiceCoef(sgParams,
                        TCronOper_Combinar(cronOper).params,
                        TCronOper_Combinar(cronOper).coefs);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_Combinar.CBCronVarChange(Sender: TObject);
begin
  inherited CBCronVarChange(Sender, True);
end;

procedure TAltaEdicionTCronOper_Combinar.CBIndiceChange(Sender: TObject);
begin
  inherited CBIndiceChange(Sender, false);
end;

Constructor TAltaEdicionTCronOper_Combinar.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, false);
  inicializarSGIndiceCoef(sgParams, tiposColsSGParams, eCoef, cbParam1, BAgregar);

  if cronOper <> NIL then
  begin
    setCBCronVar(cbRes, TCronOper_Combinar(cronOper).res);
    setSGIndiceCoef(sgParams, TCronOper_Combinar(cronOper).params, TCronOper_Combinar(cronOper).coefs, cbParam1, eCoef, BAgregar);
  end;
  utilidades.AutoSizeTypedColsAndTable(sgParams, tiposColsSGParams, FSimSEEEdit.iconos,
                                       maxAnchoTablaGrande, maxAlturaTablaMediana, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

procedure TAltaEdicionTCronOper_Combinar.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaEdicionTCronOper_Combinar.sgParamsDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGParams[Acol], NIL, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionTCronOper_Combinar.sgParamsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionTCronOper_Combinar.sgParamsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGParams);
end;

procedure TAltaEdicionTCronOper_Combinar.sgParamsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  res: TTipoColumna;
begin
  res:= utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGParams);
  case res of
    TC_btEliminar: eliminarSGIndiceCoef(sgParams, utilidades.filaListado, cbParam1, eCoef, BAgregar);
  end;
end;

function TAltaEdicionTCronOper_Combinar.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarSGIndice(sgParams, cbParam1);
end;

end.
