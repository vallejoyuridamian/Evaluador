unit uAltaEdicionTPrintCronVar_CompararValoresMultiplesCronVars;
{$MODE Delphi}
interface
uses
(*
  LResources,
  {$IFNDEF LINUX}
  Windows,
  {$ENDIF}
  Messages,
  *)
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseFormularios, uBaseAltaEdicionPrintCronVars, StdCtrls,
  Grids, uPrintCronVars,
  uLectorSimRes3Defs,
  utilidades,
  uConstantesSimSEE, uOpcionesSimSEEEdit,
  xMatDefs, uverdoc, ExtCtrls, uPrint, uHistoVarsOps, Menus;

type
  { TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars }
  TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars =
    class(TBaseAltaEdicionPrintCronVars)
    BAgregar: TButton;
    BAuto: TButton;
    BAyuda: TButton;
    bCancelar: TButton;
    bGuardar: TButton;
    cbCronVar: TRadioButton;
    cbCronVars: TComboBox;
    cbCronVarsEjex: TComboBox;
    cbGraficar: TCheckBox;
    cbMaxEjeYAuto: TCheckBox;
    cbMinEjeYAuto: TCheckBox;
    cbPE: TRadioButton;
    cbPreOrdenar: TCheckBox;
    cbTiempo: TRadioButton;
    cbTodasLasCronicas: TCheckBox;
    eDecimales: TEdit;
    eDigitos: TEdit;
    eMaxEjeY: TEdit;
    eMinEjeY: TEdit;
    eNombreHoja: TEdit;
    ePE: TEdit;
    ePE1: TEdit;
    eTitulo: TEdit;
    eUnidades: TEdit;
    lColor: TLabel;
    lCronVar: TLabel;
    lCronVars: TLabel;
    lDecimales: TLabel;
    lDigitos: TLabel;
    lMaxEjeY: TLabel;
    lMinEjeY: TLabel;
    lNombreHoja: TLabel;
    lPE: TLabel;
    lPE1: TLabel;
    lTitulo: TLabel;
    lUnidades: TLabel;
    Panel1: TPanel;
    RGEje: TRadioGroup;
    RGEjex: TGroupBox;
    RGTipoGrafico: TRadioGroup;
    RGValoresAComparar: TRadioGroup;
    sgColor: TStringGrid;
    sgCronVars: TStringGrid;
    ColorDialog1: TColorDialog;
    procedure cbCronVarChange(Sender: TObject);
    procedure cbCronVarsEjexChange(Sender: TObject);
    procedure cbTodasLasCronicasChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditStringExit(Sender: TObject);
    procedure eDigitosExit(Sender: TObject);
    procedure eDecimalesExit(Sender: TObject);
    procedure cbCronVarsChange(Sender: TObject);
    procedure BAgregarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RGTodasCronicasClick(Sender: TObject);

    procedure RGEjexClick(Sender: TObject);

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
    procedure cbMinEjeYAutoClick(Sender: TObject);
    procedure cbMaxEjeYAutoClick(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure cbGraficarClick(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure RGValoresACompararClick(Sender: TObject);

    procedure sgCronVarsDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgColorDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgColorMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure sgColorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAutoClick(Sender: TObject);
  private
    coloresAgregar: TDAOfColores;
    tiposColsColoresAgregar: TDAOfTTipoColumna;

    coloresSGCronVars: TDAOfColores;

    tiposColsSGCronVars: TDAOfTTipoColumna;
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs;
      printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar); override;
  end;

  function setEjex(var cb:TRadioButton; ejex : TEje):TEje;


implementation

uses SimSEEEditMain;

  {$R *.lfm}

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.BAgregarClick(
  Sender: TObject);
begin
  inherited addSGCronVarTipoGraficoEjeColor(sgCronVars, cbCronVars,
    RGTipoGrafico, RGEje, sgColor, ColorDialog1, BAuto, BAgregar, coloresSGCronVars);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.FormCreate(
  Sender: TObject);
begin
  inherited;
  self.cambiosForm(Sender);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.RGTodasCronicasClick
  (Sender: TObject);
begin

end;


procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.RGEjexClick(
  Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;


procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.BAutoClick(
  Sender: TObject);
begin
  inherited bColorAutoClick(BAuto, sgColor, ColorDialog1, coloresAgregar);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.BAyudaClick(
  Sender: TObject);
begin
  uverdoc.verdoc(Self, TPrintCronVar_compararValoresMultiplesCronVars);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.bGuardarClick(
  Sender: TObject);
var
  i:Integer;
  printCronVarCast: TPrintCronVar_compararValoresMultiplesCronVars;
  minEjeYAuto, maxEjeYAuto: boolean;
  minEjeY, maxEjeY: NReal;
  tipoValoresAComparar: TTipoValoresAComparar;
  probExcedencia: NReal;
  pre_Ordenar: boolean;
  probExcedencia_Sup: NReal;
  cb:TRadioButton;
  ejex:TEje;
  cronVarsEjex:TCronVar;
  cronVars: TDAOfCronVar;
  tiposGraficos: TDAOfTTipoGrafico;
  tiposEjes: TDAOfTTipoEje;
  colores: TDAOfTColor;
begin
  if validarFormulario then
  begin

    valoresEditFloatCondicional(cbMinEjeYAuto, eMinEjeY, False, minEjeYAuto, minEjeY);
    valoresEditFloatCondicional(cbMaxEjeYAuto, eMaxEjeY, False, maxEjeYAuto, maxEjeY);

    tipoValoresAComparar := TTipoValoresAComparar(RGValoresAComparar.ItemIndex);

    if cbTiempo.Checked then
    begin
       ejex:=tiempo;
       cronVarsEjex:=TCronVar(lector.lstCronVars[0]);//CUALQUIER COSA PARA QUE NO SE ROMPA
    end
    else if cbPE.Checked then
          begin
            ejex:=PE;
            cronVarsEjex:=TCronVar(lector.lstCronVars[0]); //CUALQUIER COSA PARA QUE NO SE ROMPA
          end
         else if cbCronVar.Checked then
               begin
                 ejex:=CronVar;
                 for i := 0 to lector.lstCronVars.Count - 1 do
                    if TCronVar(lector.lstCronVars[i]).nombre = valorCBString(cbCronVarsEjex) then
                        cronVarsEjex:=TCronVar(lector.lstCronVars[i])

               end;


    probExcedencia := StrToFloat(ePE.Text);
    probExcedencia_Sup := StrToFloat(ePE1.Text);
    pre_Ordenar := cbPreOrdenar.Checked;

    valorSGCronVarTipoGraficoEjeColor(sgCronVars, cronVars, tiposGraficos,
      tiposEjes, colores, coloresSGCronVars);

    if printCronVar = nil then
      printCronVar := TPrintCronVar_compararValoresMultiplesCronVars.Create(
        valorSGCronVar(sgCronVars), eNombreHoja.Text,
        eTitulo.Text, eUnidades.Text, StrToInt(eDigitos.Text),
        StrToInt(eDecimales.Text), tipoValoresAComparar,
        probExcedencia,ejex,cronVarsEjex,cbTodasLasCronicas.Checked, Pre_Ordenar, ProbExcedencia_Sup, cbGraficar.Checked,
        tiposGraficos, tiposEjes, colores, minEjeYAuto,
        maxEjeYAuto, minEjeY, maxEjey)
    else
    begin
      printCronVarCast := TPrintCronVar_compararValoresMultiplesCronVars(printCronVar);
      printCronVarCast.nombreHoja := eNombreHoja.Text;
      printCronVarCast.titulo := eTitulo.Text;
      printCronVarCast.unidades := eUnidades.Text;
      printCronVarCast.digitos := StrToInt(eDigitos.Text);
      printCronVarCast.decimales := StrToInt(eDecimales.Text);
      printCronVarCast.cronVars := valorSGCronVar(sgCronVars);
      printCronVarCast.tipoValorAComparar := tipoValoresAComparar;
      printCronVarCast.probExcedencia := probExcedencia;
      printCronVarCast.ejex:=ejex;
      printCronVarCast.TodasLasCronicas:=cbTodasLasCronicas.Checked;
      printCronVarCast.cronVarsEjex:=cronVarsEjex;
      printCronVarCast.Pre_Ordenar := pre_Ordenar;
      printCronVarCast.ProbExcedencia_Sup := probExcedencia_Sup;
      printCronVarCast.graficar := cbGraficar.Checked;
      printCronVarCast.tiposGraficos := tiposGraficos;
      printCronVarCast.ejes := tiposEjes;
      printCronVarCast.colores := colores;
      printCronVarCast.minEjeYAuto := minEjeYAuto;
      printCronVarCast.minEjeY := minEjeY;
      printCronVarCast.maxEjeYAuto := maxEjeYAuto;
      printCronVarCast.MaxEjeY := maxEjeY;

    end;

    modalResult := mrOk;
  end;
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.cambiosForm(
  Sender: TObject);
begin
  inherited cambiosForm(Sender);

  if self.RGTipoGrafico.ItemIndex = 0 then
  begin
    self.RGEje.ItemIndex := 0;
    self.RGEje.Enabled := False;
  end
  else
    self.RGEje.Enabled := True;

end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.cbCronVarsChange(
  Sender: TObject);
begin
  inherited cbCronVarChange(Sender, False);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.cbGraficarClick(
  Sender: TObject);
begin
  inherited cbChartMatClick(Sender, cbGraficar, cbMinEjeYAuto, cbMaxEjeYAuto, lMinEjeY,
    lMaxEjeY, eMinEjeY, eMaxEjeY);
  RGTipoGrafico.Enabled := cbGraficar.Checked;
  RGEje.Enabled := cbGraficar.Checked;
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.cbMaxEjeYAutoClick(
  Sender: TObject);
begin
  inherited CBEditFloatCondicionalClick(cbMaxEjeYAuto, lMaxEjeY, eMaxEjeY, False);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.cbMinEjeYAutoClick(
  Sender: TObject);
begin
  inherited CBEditFloatCondicionalClick(cbMinEjeYAuto, lMinEjeY, eMinEjeY, False);
end;

constructor TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.Create(
  AOwner: TComponent; lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar;
  tipoPrintCronVar: TClaseDePrintCronVar);
var
  printCronVarCast: TPrintCronVar_compararValoresMultiplesCronVars;
begin
  inherited Create(AOwner, lector, printCronVar, tipoPrintCronVar);

  inicializarSGCronVarTipoGraficoEjeColor(
    sgCronVars, tiposColsSGCronVars, tiposColsColoresAgregar, cbCronVars,cbCronVarsEjex,
    RGTipoGrafico, RGEje, sgColor,
    ColorDialog1, BAuto, coloresAgregar, BAgregar);


  if printCronVar <> nil then
  begin
    printCronVarCast := TPrintCronVar_compararValoresMultiplesCronVars(printCronVar);
    eNombreHoja.Text := printCronVarCast.nombreHoja;
    eTitulo.Text := printCronVarCast.titulo;
    eUnidades.Text := printCronVarCast.unidades;

    eDigitos.Text := IntToStr(printCronVarCast.digitos);
    eDecimales.Text := IntToStr(printCronVarCast.decimales);

    setSGCronVarTipoGraficoEjeColor(sgCronVars, printCronVarCast.cronVars,
      printCronVarCast.tiposGraficos, printCronVarCast.ejes,
      printCronVarCast.colores, cbCronVars,
      RGTipoGrafico, RGEje, sgColor, ColorDialog1, BAuto,
      BAgregar, coloresSGCronVars);

    //    setRGString(RGValoresAComparar, TTipoValoresACompararToString(printCronVarCast.tipoValorAComparar));
    RGValoresAComparar.ItemIndex := Ord(printCronVarCast.tipoValorAComparar);
    ePE.Text := FloatToStr(printCronVarCast.probExcedencia);
    ePE1.Text := FloatToStr(printCronVarCast.ProbExcedencia_Sup);
    cbPreOrdenar.Checked := printCronVarCast.Pre_Ordenar;

    RGValoresACompararClick(nil);

    case  printCronVarCast.ejex of
      tiempo: cbTiempo.Checked:=true;
      PE:  cbPE.Checked:=true;
      CronVar:
        begin
          cbCronVar.Checked:=true;
          cbCronVarsEjex.ItemIndex:=cbCronVarsEjex.Items.IndexOf(printCronVarCast.cronVarsEjex.nombre);
        end;
    end;

    cbTodasLasCronicas.Checked:=printCronVarCast.TodasLasCronicas;

    cbGraficar.Checked := printCronVarCast.graficar;
    cbGraficarClick(nil);
    setSGCronVarTipoGraficoEjeColor(sgCronVars,
      printCronVarCast.cronVars,
      printCronVarCast.tiposGraficos, printCronVarCast.ejes, printCronVarCast.colores,
      cbCronVars, RGTipoGrafico, RGEje,
      sgColor, ColorDialog1, BAuto, BAgregar, coloresSGCronVars);

    cbMinEjeYAuto.Checked := printCronVarCast.minEjeYAuto;
    if cbGraficar.Checked then
      cbMinEjeYAutoClick(nil);
    eMinEjeY.Text := FloatToStrF(printCronVarCast.minEjeY, ffGeneral, 16, 10);

    cbMaxEjeYAuto.Checked := printCronVarCast.maxEjeYAuto;
    if cbGraficar.Checked then
      cbMaxEjeYAutoClick(nil);
    eMaxEjeY.Text := FloatToStrF(printCronVarCast.MaxEjeY, ffGeneral, 16, 10);
  end;
  utilidades.AutoSizeTypedColsAndTable(
    sgCronVars, tiposColsSGCronVars, FSimSEEEdit.iconos,
    self.ClientWidth, self.ClientHeight,
    TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados
    );
  guardado := True;
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.eDecimalesExit(
  Sender: TObject);
begin
  inherited EditIntExit(Sender, 0, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.eDigitosExit(
  Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.EditEnter(
  Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.cbCronVarsEjexChange
  (Sender: TObject);
begin
  inherited cbCronVarChange(Sender, False);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.cbCronVarChange
  (Sender: TObject);
begin
 if Self.cbCronVar.Checked then
    self.cbCronVarsEjex.Enabled := true
 else
    self.cbCronVarsEjex.Enabled := false;

end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.cbTodasLasCronicasChange
  (Sender: TObject);
begin
if  cbTodasLasCronicas.Checked then
  begin
    self.RGValoresAComparar.ItemIndex := 0;
    self.RGValoresAComparar.Enabled := False;
  end
  else
    self.RGValoresAComparar.Enabled := True;
end;


procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.EditFloatExit(
  Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.EditStringExit(
  Sender: TObject);
begin
  inherited EditStringExit(Sender, True);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.FormCloseQuery(
  Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.
RGValoresACompararClick(Sender: TObject);
begin



  ePE.Enabled := ((TTipoValoresAComparar(RGValoresAComparar.ItemIndex) =
    ProbabilidadesDeExcedencia) or
    (TTipoValoresAComparar(RGValoresAComparar.ItemIndex) = ValoresEnRiesgo));

  lPE.Enabled := ePE.Enabled;
  cbPreOrdenar.Enabled := ePE.Enabled;

  if (TTipoValoresAComparar(RGValoresAComparar.ItemIndex) = ValoresEnRiesgo) then
  begin
    ePE1.Enabled := True;
    lPE1.Enabled := True;
  end
  else
  begin
    ePE1.Enabled := False;
    lPE1.Enabled := False;
  end;

  if Sender <> nil then
    guardado := False;
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.sgColorDrawCell(
  Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColsColoresAgregar[Acol], coloresAgregar, FSimSEEEdit.iconos);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.sgColorMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.sgColorMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsColoresAgregar);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.sgColorMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsColoresAgregar);
  case res of
    TC_Color: cambiarColor(sgColor, utilidades.filaListado,
        ColorDialog1, coloresAgregar);
  end;
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.sgCronVarsDrawCell(
  Sender: TObject; ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColsSGCronVars[ACol], coloresSGCronVars, iconos);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.sgCronVarsMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.sgCronVarsMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsSGCronVars);
end;

procedure TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.sgCronVarsMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGCronVars);
  case res of
    TC_Color: cambiarColor(sgCronVars, utilidades.filaListado,
        ColorDialog1, coloresSGCronVars);
    TC_btEliminar: eliminarSGCronVarTipoGraficoEjeColor(sgCronVars,
        utilidades.filaListado, cbCronVars, RGTipoGrafico, RGEje,
        sgColor, ColorDialog1, BAuto,
        BAgregar,
        coloresSGCronVars, coloresAgregar);

    TC_btUp: utilidades.listadoClickUp_(
        sgCronVars, utilidades.filaListado,
        nil, Shift, nil, Modificado, coloresSGCronVars  );
    TC_btDown: utilidades.listadoClickDown_(sgCronVars,
        utilidades.filaListado, nil, Shift, nil, Modificado, coloresSGCronVars );

  end;
end;

function TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars.
validarFormulario: boolean;
var
  cbEjex: TRadioButton;
begin

  Result := validarNombreHoja(eNombreHoja) and
    validarEditString(eTitulo, RS_TITULO) and validarEditString(
    eUnidades, RS_UNIDADES) and validarEditInt(eDigitos, 1, MaxInt) and
    validarEditInt(eDecimales, 0, MaxInt) and validarSGCronVar(
    sgCronVars, cbCronVars) and validarCronVarEjex(cbCronVarsEjex,cbCronVar) and
    ((TTipoValoresAComparar(RGValoresAComparar.ItemIndex) <
    ProbabilidadesDeExcedencia) or (validarEditFloat(ePE, 0, 1) and
    (validarEditFloat(ePE1, 0, 1)))) and (not cbGraficar.Checked or
    (validarEditFloatCondicional(cbMinEjeYAuto, eMinEjeY, -MaxNReal,
    MaxNReal, False) and validarEditFloatCondicional(cbMaxEjeYAuto,
    eMinEjeY, -MaxNReal, MaxNReal, False)));
end;

function setEjex(var cb:TRadioButton; ejex : TEje): TEje;
begin
  cb.Checked := true;
  result:=ejex;
end;

initialization
end.
