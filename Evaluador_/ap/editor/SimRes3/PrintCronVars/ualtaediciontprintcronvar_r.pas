unit ualtaediciontprintcronvar_R;

{$MODE Delphi}

interface

uses
//  Windows,
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseFormularios,
  uBaseAltaEdicionPrintCronVars, StdCtrls, Grids, uPrintCronVars,
  uLectorSimRes3Defs,
  utilidades,
  uConstantesSimSEE, uOpcionesSimSEEEdit,
  xMatDefs, uverdoc, ExtCtrls, uPrint, uHistoVarsOps, Menus;

resourcestring
  RS_R_Archi = 'Archivo de script';


type

  { TAltaEdicionPrintCronVar_R }

  TAltaEdicionPrintCronVar_R = class(TBaseAltaEdicionPrintCronVars)
    BAgregar: TButton;
    BAyuda: TButton;
    bCancelar: TButton;
    bGuardar: TButton;
    cbCronVars: TComboBox;
    cbEjecutar: TCheckBox;
    cbSalirAlFinal: TCheckBox;
    e_R_archi: TLabeledEdit;
    gb_variables_cronicas: TGroupBox;
    e_R_script: TMemo;
    ColorDialog1: TColorDialog;
    lCronVar: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    rgTipoScript: TRadioGroup;
    sgCronVars: TStringGrid;
    Splitter2: TSplitter;
    procedure EditEnter(Sender: TObject);
    procedure EditStringExit(Sender: TObject);
    procedure eDigitosExit(Sender: TObject);
    procedure eDecimalesExit(Sender: TObject);
    procedure cbCronVarsChange(Sender: TObject);
    procedure BAgregarClick(Sender: TObject);
    procedure sgCronVarsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgCronVarsMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure sgCronVarsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure cambiosForm(Sender: TObject);

    procedure sgCronVarsDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
  private
    tiposColsSGCronVars: TDAOfTTipoColumna;
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs;
      printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

procedure TAltaEdicionPrintCronVar_R.BAgregarClick(Sender: TObject);
begin
  addSGCronVar_(sgCronVars, cbCronVars, BAgregar);
end;

procedure TAltaEdicionPrintCronVar_R.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(Self, TPrintCronVar_R);
end;

procedure TAltaEdicionPrintCronVar_R.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionPrintCronVar_R.bGuardarClick(Sender: TObject);
var
  printCronVarCast: TPrintCronVar_R;
  strTipo: string;

begin
  if validarFormulario then
  begin
    case rgTipoScript.ItemIndex of
      0: strTipo:= 'R';
      1: strTipo:= 'Octave';
      2: strTipo:= 'Matlab';
    end;


    if printCronVar = nil then
      printCronVar := TPrintCronVar_R.Create(
        valorSGCronVar(sgCronVars), '',
        e_R_archi.Text, e_R_script.Text,
        strTipo, cbEjecutar.Checked, cbSalirAlFinal.Checked )
    else
    begin
      printCronVarCast := TPrintCronVar_R(printCronVar);
      printCronVarCast.cronVars := valorSGCronVar(sgCronVars);
      printCronVarCast.R_archi := e_R_archi.Text;
      printCronVarCast.R_script := e_R_script.Text;
      printCronVarCast.TipoScript:= strTipo;
      printCronVarCast.flg_ejecutar:= cbEjecutar.Checked;
      printCronVarCast.flg_quit_al_final:= cbSalirAlFinal.Checked;
    end;

    modalResult := mrOk;
  end;
end;

procedure TAltaEdicionPrintCronVar_R.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TAltaEdicionPrintCronVar_R.cbCronVarsChange(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, False);
end;



constructor TAltaEdicionPrintCronVar_R.Create(AOwner: TComponent;
  lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar;
  tipoPrintCronVar: TClaseDePrintCronVar);
var
  printCronVarCast: TPrintCronVar_R;
begin
  inherited Create(AOwner, lector, printCronVar, tipoPrintCronVar);


  inicializarSGCronVar(
    sgCronVars,
    tiposColsSGCronVars,
    cbCronVars, BAgregar);


  if printCronVar <> nil then
  begin
    printCronVarCast := TPrintCronVar_R(printCronVar);
    e_R_archi.Text := printCronVarCast.R_archi;
    e_R_script.Text := printCronVarCast.R_script;

    setSGCronVar(sgCronVars,
      printCronVarCast.cronVars, cbCronVars, BAgregar);


    if printCronVarCast.TipoScript = 'R' then
     rgTipoScript.ItemIndex:= 0
    else if printCronVarCast.TipoScript = 'Octave' then
     rgTipoScript.ItemIndex:= 1
    else if printCronVarCast.TipoScript = 'Matlab' then
     rgTipoScript.ItemIndex:= 2
    else
     rgTipoScript.ItemIndex:= 0;
  //    raise Exception.Create('Tipo de script desconocido: '+ printCronVarCast.TipoScript );

    cbEjecutar.Checked:= printCronVarCast.flg_ejecutar;
    cbSalirAlFinal.Checked:= printCronVarCast.flg_quit_al_final;

  end
  else
  begin
    rgTipoScript.ItemIndex:= 0;
    cbEjecutar.Checked:= true;
    cbSalirAlFinal.Checked:= false;
  end;
  utilidades.AutoSizeTypedColsAndTable(
    sgCronVars, tiposColsSGCronVars, FSimSEEEdit.iconos,
    self.ClientWidth, self.ClientHeight,
    TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados
    );
  guardado := True;
end;

procedure TAltaEdicionPrintCronVar_R.eDecimalesExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 0, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_R.eDigitosExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_R.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionPrintCronVar_R.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionPrintCronVar_R.EditStringExit(Sender: TObject);
begin
  inherited EditStringExit(Sender, True);
end;

procedure TAltaEdicionPrintCronVar_R.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TAltaEdicionPrintCronVar_R.sgCronVarsDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColsSGCronVars[ACol], nil, iconos);
end;

procedure TAltaEdicionPrintCronVar_R.sgCronVarsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionPrintCronVar_R.sgCronVarsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGCronVars);
end;

procedure TAltaEdicionPrintCronVar_R.sgCronVarsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGCronVars);
  case res of
    TC_btEliminar: eliminarSGCronVar(sgCronVars, utilidades.filaListado, cbCronVars,
        BAgregar);
    TC_btUp: utilidades.listadoClickUp_(sgCronVars, utilidades.filaListado,
        nil, Shift, nil, Modificado);
    TC_btDown: utilidades.listadoClickDown_(sgCronVars,
        utilidades.filaListado, nil, Shift, nil, Modificado);
  end;
end;

function TAltaEdicionPrintCronVar_R.validarFormulario: boolean;
begin
  Result := validarEditString(e_R_archi, RS_R_Archi) and
    validarSGCronVar(sgCronVars, cbCronVars);
end;

initialization
end.
