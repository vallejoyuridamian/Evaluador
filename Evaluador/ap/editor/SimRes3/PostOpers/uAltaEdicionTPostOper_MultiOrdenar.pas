unit uAltaEdicionTPostOper_MultiOrdenar;

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

  { TAltaEdicionTPostOper_MultiOrdenar }

  TAltaEdicionTPostOper_MultiOrdenar = class(TBaseAltaEdicionPostOpers)
    lResultado: TLabel;
    lCronVar: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    BAgregar: TButton;
    sgParams: TStringGrid;
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

Constructor TAltaEdicionTPostOper_MultiOrdenar.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarSGCronVar(sgParams, tiposColsSGParams, cbParam1, BAgregar);
  
  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_MultiOrdenar(postOper).res);
    setSGCronVar(sgParams,
                 TPostOper_MultiOrdenar(postOper).params,
                 cbParam1, BAgregar);
  end;
  utilidades.AutoSizeTypedColsAndTable(sgParams, tiposColsSGParams, FSimSEEEdit.iconos,
                                       self.ClientWidth, self.ClientHeight, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);

  maxAlturaTablaMediana:=240;

end;

function TAltaEdicionTPostOper_MultiOrdenar.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarSGCronVar(sgParams, cbParam1);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.BAgregarClick(Sender: TObject);
begin

  if cbRes.Items[cbRes.ItemIndex]=cbParam1.Items[cbParam1.ItemIndex] then
    ShowMessage('La ORDENADORA no puede ser agregada.')
  else
    inherited addSGCronVar_(sgParams, cbParam1, BAgregar);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_MultiOrdenar);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.bGuardarClick(Sender: TObject);
var
  Ordenadora: TCronVar;
  CronVars: TDAOfCronVar;
  i: Integer;
begin
  Ordenadora:=valorCBCronVar(cbRes);
  CronVars:=valorSGCronVar(sgParams);
  for i:=0 to Length(CronVars)-1 do
    if Ordenadora.nombre=CronVars[i].nombre then
    begin
      ShowMessage('La ORDENADORA no puede pertenecer a la lista');
      Exit;
    end;

  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      postOper:= TPostOper_MultiOrdenar.Create(valorCBCronVar(cbRes),
                                                        valorSGCronVar(sgParams));
    end
    else
    begin
      TPostOper_MultiOrdenar(postOper).res:= valorCBCronVar(cbRes);
      TPostOper_MultiOrdenar(postOper).params:= valorSGCronVar(sgParams);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.CBCronVarParam1Change(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, false);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.CBCronVarResChange(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, True);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.sgParamsDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGParams[Acol], NIL, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.sgParamsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.sgParamsMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGParams);
end;

procedure TAltaEdicionTPostOper_MultiOrdenar.sgParamsMouseUp(Sender: TObject; Button: TMouseButton;
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
