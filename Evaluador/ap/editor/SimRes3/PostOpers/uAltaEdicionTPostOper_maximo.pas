unit uAltaEdicionTPostOper_maximo;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xMatDefs, uHistoVarsOps, utilidades,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers, uOpcionesSimSEEEdit, Grids, StdCtrls;

type
  TAltaEdicionTPostOper_maximo = class(TBaseAltaEdicionPostOpers)
    lResultado: TLabel;
    lCronVar: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    sgParams: TStringGrid;
    BAgregar: TButton;
    procedure BAyudaClick(Sender: TObject);
    procedure CBCronVarResChange(Sender: TObject);
    procedure CBCronVarParam1Change(Sender: TObject);
    procedure BAgregarClick(Sender: TObject);
    procedure sgParamsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgParamsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgParamsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sgParamsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
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

Constructor TAltaEdicionTPostOper_maximo.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarSGCronVar(sgParams, tiposColsSGParams, cbParam1, BAgregar);
  
  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_maximo(postOper).res);
    setSGCronVar(sgParams,
                 TPostOper_maximo(postOper).params,
                 cbParam1, BAgregar);
  end;
  utilidades.AutoSizeTypedColsAndTable(sgParams, tiposColsSGParams, FSimSEEEdit.iconos,
                                       self.ClientWidth, self.ClientHeight, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

function TAltaEdicionTPostOper_maximo.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarSGCronVar(sgParams, cbParam1);
end;

procedure TAltaEdicionTPostOper_maximo.BAgregarClick(Sender: TObject);
begin
  inherited addSGCronVar_(sgParams, cbParam1, BAgregar);
end;

procedure TAltaEdicionTPostOper_maximo.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_maximo);
end;

procedure TAltaEdicionTPostOper_maximo.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_maximo.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      postOper:= TPostOper_maximo.Create(valorCBCronVar(cbRes),
                                                        valorSGCronVar(sgParams));
    end
    else
    begin
      TPostOper_maximo(postOper).res:= valorCBCronVar(cbRes);
      TPostOper_maximo(postOper).params:= valorSGCronVar(sgParams);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_maximo.CBCronVarParam1Change(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, false);
end;

procedure TAltaEdicionTPostOper_maximo.CBCronVarResChange(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, True);
end;

procedure TAltaEdicionTPostOper_maximo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaEdicionTPostOper_maximo.sgParamsDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGParams[Acol], NIL, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionTPostOper_maximo.sgParamsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionTPostOper_maximo.sgParamsMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGParams);
end;

procedure TAltaEdicionTPostOper_maximo.sgParamsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  res: TTipoColumna;
begin
  res:= utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGParams);
  case res of
    TC_btEliminar: eliminarSGCronVar(sgParams, utilidades.filaListado, cbParam1, BAgregar);
  end;
end;

end.
