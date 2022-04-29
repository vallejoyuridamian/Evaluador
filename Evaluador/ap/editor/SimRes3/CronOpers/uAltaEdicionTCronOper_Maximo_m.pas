unit uAltaEdicionTCronOper_Maximo_m;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
   {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseAltaEdicionCronOpers, uLectorSimRes3Defs, uverdoc,
  uHistoVarsOps, utilidades, uconstantesSimSEE, uOpcionesSimSEEEdit, Grids,
  StdCtrls;

type
  TAltaEdicionTCronOper_Maximo_m = class(TBaseAltaEdicionCronOpers)
    lResultado: TLabel;
    lIndice: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    sgParams: TStringGrid;
    BAgregar: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbCronVarChange(Sender: TObject);
    procedure CBIndiceChange(Sender: TObject);
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
    procedure BAyudaClick(Sender: TObject);
  private
    tiposColsSGParams: TDAOfTTipoColumna;
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper); override;
  end;

implementation

uses SimSEEEditMain;

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

Constructor TAltaEdicionTCronOper_Maximo_m.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, false);
  inicializarSGIndice(sgParams, tiposColsSGParams, cbParam1, BAgregar);

  if cronOper <> NIL then
  begin
    setCBCronVar(cbRes, TCronOper_Maximo_m(cronOper).res);
    setSGIndice(sgParams, TCronOper_Maximo_m(cronOper).params, cbParam1, BAgregar);
  end;
  utilidades.AutoSizeTypedColsAndTable(sgParams, tiposColsSGParams, FSimSEEEdit.iconos,
                                        maxAnchoTablaGrande, maxAlturaTablaMediana, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;


function TAltaEdicionTCronOper_Maximo_m.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarSGIndice(sgParams, cbParam1);
end;

procedure TAltaEdicionTCronOper_Maximo_m.BAgregarClick(Sender: TObject);
begin
  inherited addSGIndice(sgParams, cbParam1, BAgregar);
end;

procedure TAltaEdicionTCronOper_Maximo_m.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TCronOper_Maximo_m);
end;

procedure TAltaEdicionTCronOper_Maximo_m.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_Maximo_m.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = NIL then
    begin
      cronOper:= TCronOper_Maximo_m.Create(valorCBCronVar(cbRes),
                                           valorSGIndice(sgParams));
    end
    else
    begin
      TCronOper_Maximo_m(cronOper).res:= valorCBCronVar(cbRes);
      TCronOper_Maximo_m(cronOper).params:= valorSGIndice(sgParams);
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_Maximo_m.cbCronVarChange(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, true);
end;

procedure TAltaEdicionTCronOper_Maximo_m.CBIndiceChange(Sender: TObject);
begin
  inherited CBIndiceChange(Sender, false);
end;

procedure TAltaEdicionTCronOper_Maximo_m.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaEdicionTCronOper_Maximo_m.sgParamsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGParams[Acol], NIL, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionTCronOper_Maximo_m.sgParamsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionTCronOper_Maximo_m.sgParamsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGParams);
end;

procedure TAltaEdicionTCronOper_Maximo_m.sgParamsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  res: TTipoColumna;
begin
  res:= utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGParams);
  case res of
    TC_btEliminar: eliminarSGIndice(sgParams, utilidades.filaListado, cbParam1, BAgregar);
  end;
end;

end.
