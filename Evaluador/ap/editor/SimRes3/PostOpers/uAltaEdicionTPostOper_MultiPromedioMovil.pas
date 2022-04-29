unit uAltaEdicionTPostOper_MultiPromedioMovil;

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

  { TAltaEdicionTPostOper_MultiPromedioMovil }

  TAltaEdicionTPostOper_MultiPromedioMovil = class(TBaseAltaEdicionPostOpers)
    eNPasosPM: TEdit;
    Label1: TLabel;
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

Constructor TAltaEdicionTPostOper_MultiPromedioMovil.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarSGCronVar(sgParams, tiposColsSGParams, cbParam1, BAgregar);
  
  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_MultiPromedioMovil(postOper).res);
    setSGCronVar(sgParams,
                 TPostOper_MultiPromedioMovil(postOper).params,
                 cbParam1, BAgregar);
    eNPasosPM.Text:= intToStr( TPostOper_MultiPromedioMovil( postOper ).NPasosPM );
  end;
  utilidades.AutoSizeTypedColsAndTable(sgParams, tiposColsSGParams, FSimSEEEdit.iconos,
                                          self.ClientWidth, self.ClientHeight, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

function TAltaEdicionTPostOper_MultiPromedioMovil.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarSGCronVar(sgParams, cbParam1);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.BAgregarClick(Sender: TObject);
begin
  inherited addSGCronVar_(sgParams, cbParam1, BAgregar);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_MultiPromedioMovil);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.bGuardarClick(Sender: TObject);
var
  nPasosPM: integer;
  res: boolean;

begin
  if validarFormulario then
  begin
    res:=  validarEditInt( eNPasosPM, 1, MaxInt);
    nPasosPM:= StrToInt( eNPasosPM.text );
    if postOper = NIL then
    begin
      postOper:= TPostOper_MultiPromedioMovil.Create(valorCBCronVar(cbRes),
                                                        valorSGCronVar(sgParams), NPasosPM );
    end
    else
    begin
      TPostOper_MultiPromedioMovil(postOper).res:= valorCBCronVar(cbRes);
      TPostOper_MultiPromedioMovil(postOper).params:= valorSGCronVar(sgParams);
      TPostOper_MultiPromedioMovil(postOper).NPasosPM:= nPasosPM;
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.CBCronVarParam1Change(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, false);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.CBCronVarResChange(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, True);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.sgParamsDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGParams[Acol], NIL, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.sgParamsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.sgParamsMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGParams);
end;

procedure TAltaEdicionTPostOper_MultiPromedioMovil.sgParamsMouseUp(Sender: TObject; Button: TMouseButton;
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
