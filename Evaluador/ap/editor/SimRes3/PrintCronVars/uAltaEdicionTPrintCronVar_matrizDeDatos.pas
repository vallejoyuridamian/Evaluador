unit uAltaEdicionTPrintCronVar_matrizDeDatos;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,
  uBaseFormularios,
  uBaseAltaEdicionPrintCronVars, uLectorSimRes3Defs, uverdoc, uPrintCronVars,
  xMatDefs, utilidades, uOpcionesSimSEEEdit;

type
  TAltaEdicionPrintCronVar_matrizDeDatos = class(TBaseAltaEdicionPrintCronVars)
    lTitulo: TLabel;
    eTitulo: TEdit;
    cbCronVar: TComboBox;
    sgTitulosCols: TStringGrid;
    lCronVar: TLabel;
    lNombreHoja: TLabel;
    eNombreHoja: TEdit;
    lUnidades: TLabel;
    eUnidades: TEdit;
    lTituloCol: TLabel;
    eTituloCol: TEdit;
    bAgregar: TButton;
    lDigitos: TLabel;
    eDigitos: TEdit;
    lDecimales: TLabel;
    eDecimales: TEdit;
    cbPrintPromedio: TCheckBox;
    cbChartMat: TCheckBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    cbMinEjeYAuto: TCheckBox;
    cbMaxEjeYAuto: TCheckBox;
    eMaxEjeY: TEdit;
    lMaxEjeY: TLabel;
    lMinEjeY: TLabel;
    eMinEjeY: TEdit;
    procedure BAyudaClick(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditStringExit(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure cbChartMatClick(Sender: TObject);
    procedure cbMinEjeYAutoClick(Sender: TObject);
    procedure cbMaxEjeYAutoClick(Sender: TObject);
    procedure bAgregarClick(Sender: TObject);
    procedure sgTitulosColsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgTitulosColsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgTitulosColsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sgTitulosColsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure eDecimalesExit(Sender: TObject);
    procedure eDigitosExit(Sender: TObject);
    procedure CBCronVarChange(Sender: TObject);
    procedure cbCronVarEnter(Sender: TObject);
    procedure eTituloColKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    tiposColsSGTitulosCols: TDAOfTTipoColumna;
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar); override;
  end;

implementation

uses SimSEEEditMain;

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionPrintCronVar_matrizDeDatos.cbCronVarEnter(
  Sender: TObject);
begin
  inherited CBEnter(Sender);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.cbMaxEjeYAutoClick(
  Sender: TObject);
begin
  inherited CBEditFloatCondicionalClick(cbMaxEjeYAuto, lMaxEjeY, eMaxEjeY, false);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.cbMinEjeYAutoClick(
  Sender: TObject);
begin
  inherited CBEditFloatCondicionalClick(cbMinEjeYAuto, lMinEjeY, eMinEjeY, false);
end;

Constructor TAltaEdicionPrintCronVar_matrizDeDatos.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar);
begin
  inherited Create(AOwner, lector, printCronVar, tipoPrintCronVar);

  inicializarCBCronVars(cbCronVar, False);
  inicializarSGString(sgTitulosCols, [ RS_TITULO , encabezadoBTEliminar, encabezadoBTUp, encabezadoBTDown], tiposColsSGTitulosCols, eTitulo, lTitulo, bAgregar);

  if printCronVar <> NIL then
  begin
    setCBCronVar(cbCronVar, TPrintCronVar_matrizDeDatos(printCronVar).cronVar);
    eNombreHoja.Text:= TPrintCronVar_matrizDeDatos(printCronVar).nombreHoja;
    eTitulo.Text:= TPrintCronVar_matrizDeDatos(printCronVar).titulo;
    eUnidades.Text:= TPrintCronVar_matrizDeDatos(printCronVar).unidades;
    setSGString(sgTitulosCols, TPrintCronVar_matrizDeDatos(printCronVar).titulosCols);
    eDigitos.Text:= IntToStr(TPrintCronVar_matrizDeDatos(printCronVar).digitos);
    eDecimales.Text:= IntToStr(TPrintCronVar_matrizDeDatos(printCronVar).decimales);
    cbPrintPromedio.Checked:= TPrintCronVar_matrizDeDatos(printCronVar).Print_promedio;
    cbChartMat.Checked:= TPrintCronVar_matrizDeDatos(printCronVar).chart_Mat;
    cbChartMatClick(Self);

    cbMinEjeYAuto.Checked:= TPrintCronVar_matrizDeDatos(printCronVar).minEjeYAuto;
    cbMinEjeYAutoClick(Self);
    eMinEjeY.Text:= FloatToStrF(TPrintCronVar_matrizDeDatos(printCronVar).minEjeY, ffGeneral, 16, 10);

    cbMaxEjeYAuto.Checked:= TPrintCronVar_matrizDeDatos(printCronVar).maxEjeYAuto;
    cbMaxEjeYAutoClick(Self);
    eMaxEjeY.Text:= FloatToStrF(TPrintCronVar_matrizDeDatos(printCronVar).MaxEjeY, ffGeneral, 16, 10);

    guardado:= true;
  end;

  utilidades.AutoSizeTypedColsAndTable(
  sgTitulosCols, tiposColsSGTitulosCols, FSimSEEEdit.iconos,
  self.ClientWidth, self.ClientHeight, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.eDecimalesExit(
  Sender: TObject);
begin
  inherited EditIntExit(Sender, 0, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.eDigitosExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, MaxInt);
end;

function TAltaEdicionPrintCronVar_matrizDeDatos.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbCronVar) and
           validarNombreHoja(eNombreHoja) and
           validarEditString(eTitulo, RS_TITULO ) and
           validarEditString(eUnidades, RS_UNIDADES ) and
           validarEditInt(eDigitos, 1, MaxInt) and
           validarEditInt(eDecimales, 0, MaxInt) and
           (not cbChartMat.Checked or
           (validarEditFloatCondicional(cbMinEjeYAuto, eMinEjeY, -MaxNReal, MaxNReal, false) and
           validarEditFloatCondicional(cbMaxEjeYAuto, eMinEjeY, -MaxNReal, MaxNReal, false)));
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.bAgregarClick(Sender: TObject);
begin
  inherited addSGString(sgTitulosCols, eTituloCol, RS_TITULO_DE_COLUMNA, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TPrintCronVar_matrizDeDatos);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.bGuardarClick(Sender: TObject);
var
  minEjeYAuto, maxEjeYAuto: boolean;
  minEjeY, maxEjeY: NReal;
begin
  if validarFormulario then
  begin
    valoresEditFloatCondicional(cbMinEjeYAuto, eMinEjeY, False, minEjeYAuto, minEjeY);
    valoresEditFloatCondicional(cbMaxEjeYAuto, eMaxEjeY, False, maxEjeYAuto, maxEjeY);

    if printCronVar = NIL then
      printCronVar:= TPrintCronVar_matrizDeDatos.Create(valorCBCronVar(cbCronVar),
                                                        eNombreHoja.Text, eTitulo.Text,
                                                        eUnidades.Text, valorSGString(sgTitulosCols),
                                                        StrToInt(eDigitos.Text), StrToInt(eDecimales.Text),
                                                        cbPrintPromedio.Checked, cbChartMat.Checked,
                                                        minEjeYAuto, maxEjeYAuto,
                                                        minEjeY, maxEjey)
    else
    begin
      TPrintCronVar_matrizDeDatos(printCronVar).cronVar:= valorCBCronVar(cbCronVar);
      TPrintCronVar_matrizDeDatos(printCronVar).nombreHoja:= eNombreHoja.Text;
      TPrintCronVar_matrizDeDatos(printCronVar).titulo:= eTitulo.Text;
      TPrintCronVar_matrizDeDatos(printCronVar).unidades:= eUnidades.Text;
      TPrintCronVar_matrizDeDatos(printCronVar).titulosCols:= valorSGString(sgTitulosCols);
      TPrintCronVar_matrizDeDatos(printCronVar).digitos:= StrToInt(eDigitos.Text);
      TPrintCronVar_matrizDeDatos(printCronVar).decimales:= StrToInt(eDecimales.Text);
      TPrintCronVar_matrizDeDatos(printCronVar).Print_promedio:= cbPrintPromedio.Checked;
      TPrintCronVar_matrizDeDatos(printCronVar).chart_Mat:= cbChartMat.Checked;
      TPrintCronVar_matrizDeDatos(printCronVar).minEjeYAuto:= minEjeYAuto;
      TPrintCronVar_matrizDeDatos(printCronVar).minEjeY:= minEjeY;
      TPrintCronVar_matrizDeDatos(printCronVar).maxEjeYAuto:= maxEjeYAuto;
      TPrintCronVar_matrizDeDatos(printCronVar).MaxEjeY:= maxEjeY;
    end;

    modalResult:= mrOk;
  end;
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.cbChartMatClick(
  Sender: TObject);
begin
  inherited cbChartMatClick(Sender, cbChartMat, cbMinEjeYAuto, cbMaxEjeYAuto, lMinEjeY,
                            lMaxEjeY, eMinEjeY, eMaxEjeY);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.CBCronVarChange(
  Sender: TObject);
begin
  inherited CBCronVarChange(Sender, true);
  if (eTitulo.Text = loQueHabia) or
     (eTitulo.Text = '') then
    eTitulo.Text:= valorCBString(TComboBox(Sender));
  if (eNombreHoja.Text = loQueHabia) or
     (eNombreHoja.Text = '')  then
    eNombreHoja.Text:= valorCBString(TComboBox(Sender));
  loQueHabia:= valorCBString(TComboBox(Sender));
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.EditStringExit(
  Sender: TObject);
begin
  inherited EditStringExit(Sender, True);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.eTituloColKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited eStringKeyDown(sgTitulosCols, eTituloCol, lTituloCol.Caption, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados, Key, Shift);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.sgTitulosColsDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsSGTitulosCols[Acol], NIL, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.sgTitulosColsMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.sgTitulosColsMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGTitulosCols);
end;

procedure TAltaEdicionPrintCronVar_matrizDeDatos.sgTitulosColsMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  res: TTipoColumna;
begin
  res:= utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGTitulosCols);
  case res of
    TC_btEliminar : eliminarSGString(sgTitulosCols, utilidades.filaListado, eTituloCol, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
    TC_btUp       : listadoClickUp_(sgTitulosCols, utilidades.filaListado, NIL, Shift, NIL, Modificado );
    TC_btDown     : listadoClickDown_(sgTitulosCols, utilidades.filaListado, NIL, Shift, NIL, Modificado );
  end;
end;

end.
