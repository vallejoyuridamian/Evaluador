unit ualtaediciontpostoper_monotonizar;

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xMatDefs, uHistoVarsOps, utilidades,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers, uOpcionesSimSEEEdit, Grids, StdCtrls, ExtCtrls;

type

  { TAltaEdicionTPostOper_Monotonizar }

  TAltaEdicionTPostOper_Monotonizar = class(TBaseAltaEdicionPostOpers)
    cb_Decreciente: TCheckBox;
    eNPasos: TLabeledEdit;
    lbl_Monotonizante: TLabel;
    lCronVar: TLabel;
    cbMonotonizante: TComboBox;
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
{$R *.lfm}

Constructor TAltaEdicionTPostOper_Monotonizar.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
var
  apo: TPostOper_MonotonizarCronVars;
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbMonotonizante, false);
  inicializarSGCronVar(sgParams, tiposColsSGParams, cbParam1, BAgregar);
  
  if postOper <> NIL then
  begin
    apo:= postOper as TPostOper_MonotonizarCronVars;
    setCBCronVar(cbMonotonizante, apo.res);
    setSGCronVar(sgParams, apo.params, cbParam1, BAgregar);
    eNPasos.Text:= IntToStr( apo.NPasosDelCajon );
    cb_Decreciente.Checked:= apo.flg_Decreciente;
  end;

  utilidades.AutoSizeTypedColsAndTable(
                                       sgParams, tiposColsSGParams, FSimSEEEdit.iconos,
                                       self.ClientWidth, self.ClientHeight, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

function TAltaEdicionTPostOper_Monotonizar.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbMonotonizante) and
           validarSGCronVar(sgParams, cbParam1)
           and validarEditInt( eNPasos  );
end;

procedure TAltaEdicionTPostOper_Monotonizar.BAgregarClick(Sender: TObject);
begin
  inherited addSGCronVar_(sgParams, cbParam1, BAgregar);
end;

procedure TAltaEdicionTPostOper_Monotonizar.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_MonotonizarCronVars);
end;

procedure TAltaEdicionTPostOper_Monotonizar.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_Monotonizar.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      postOper:= TPostOper_MonotonizarCronVars.Create(
                 valorCBCronVar(cbMonotonizante),
                 valorSGCronVar(sgParams),
                 StrToInt( eNPasos.Text ),
                 cb_Decreciente.Checked );
    end
    else
    begin
      TPostOper_MonotonizarCronVars(postOper).res:= valorCBCronVar(cbMonotonizante);
      TPostOper_MonotonizarCronVars(postOper).params:= valorSGCronVar(sgParams);
      TPostOper_MonotonizarCronVars(postOper).NPasosDelCajon:= StrToInt( eNPasos.Text );
      TPostOper_MonotonizarCronVars(postOper).flg_Decreciente:= cb_Decreciente.Checked;
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_Monotonizar.CBCronVarParam1Change(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, false);
end;

procedure TAltaEdicionTPostOper_Monotonizar.CBCronVarResChange(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, True);
end;

procedure TAltaEdicionTPostOper_Monotonizar.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaEdicionTPostOper_Monotonizar.sgParamsDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGParams[Acol], NIL, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionTPostOper_Monotonizar.sgParamsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionTPostOper_Monotonizar.sgParamsMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGParams);
end;

procedure TAltaEdicionTPostOper_Monotonizar.sgParamsMouseUp(Sender: TObject; Button: TMouseButton;
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
