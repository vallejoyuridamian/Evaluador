unit uAltaEdicionTPostOper_potenciaFirmeHidraulica;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, xMatDefs, uHistoVarsOps, utilidades,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers, uOpcionesSimSEEEdit;

type
  TAltaEdicionTPostOper_potenciaFirmeHidraulica = class(TBaseAltaEdicionPostOpers)
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

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.CBCronVarParam1Change(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, false);
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, true);
end;

Constructor TAltaEdicionTPostOper_potenciaFirmeHidraulica.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarSGCronVar(sgParams, tiposColsSGParams, cbParam1, BAgregar);

  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_potenciaFirmeHidraulica(postOper).res);
    setSGCronVar(sgParams,
                     TPostOper_potenciaFirmeHidraulica(postOper).params,
                     cbParam1, BAgregar);
  end;
  utilidades.AutoSizeTypedColsAndTable(sgParams, tiposColsSGParams, FSimSEEEdit.iconos,
                                       self.ClientWidth, self.ClientHeight, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

function TAltaEdicionTPostOper_potenciaFirmeHidraulica.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarSGCronVar(sgParams, cbParam1);
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.BAgregarClick(
  Sender: TObject);
begin
  inherited addSGCronVar_(sgParams, cbParam1, BAgregar);
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.BAyudaClick(
  Sender: TObject);
begin
  verdoc(Self, TPostOper_potenciaFirmeHidraulica);
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.bGuardarClick(
  Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      postOper:= TPostOper_potenciaFirmeHidraulica.Create(valorCBCronVar(cbRes),
                                                          valorSGCronVar(sgParams));
    end
    else
    begin
      TPostOper_potenciaFirmeHidraulica(postOper).res:= valorCBCronVar(cbRes);
      TPostOper_potenciaFirmeHidraulica(postOper).params:= valorSGCronVar(sgParams);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.sgParamsDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGParams[Acol], NIL, FSimSEEEdit.iconos);  
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.sgParamsMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.sgParamsMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGParams);
end;

procedure TAltaEdicionTPostOper_potenciaFirmeHidraulica.sgParamsMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  res: TTipoColumna;
begin
  res:= utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGParams);
  case res of
    TC_btEliminar: eliminarSGCronVar(sgParams, utilidades.filaListado, cbParam1, BAgregar);
  end;
end;

end.
