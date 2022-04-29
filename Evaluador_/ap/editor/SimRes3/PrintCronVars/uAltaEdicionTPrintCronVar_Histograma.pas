unit uAltaEdicionTPrintCronVar_Histograma;
  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  {$IFDEF LCL}
  LCLType,
  {$ENDIF}
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls,
  uBaseFormularios,
  uBaseAltaEdicionPrintCronVars, uLectorSimRes3Defs, uverdoc, uPrintCronVars,
  xMatDefs, utilidades, uconstantesSimSEE, uOpcionesSimSEEEdit;

type

  { TAltaEdicionPrintCronVar_histograma }

  TAltaEdicionPrintCronVar_histograma = class(TBaseAltaEdicionPrintCronVars)
    BAyuda: TButton;
    bCancelar: TButton;
    bGuardar: TButton;
    cbChartMat: TCheckBox;
    cbCronVar: TComboBox;
    cbMaxEjeYAuto: TCheckBox;
    cbMinEjeYAuto: TCheckBox;
    cbPreOrdenar: TCheckBox;
    cbPrintPromedio: TCheckBox;
    cbPrintTodas: TCheckBox;
    eDecimales: TEdit;
    eDigitos: TEdit;
    eMaxEjeY: TEdit;
    eMinEjeY: TEdit;
    eNombreHoja: TEdit;
    eNroProbsAisladas: TEdit;
    eTitulo: TEdit;
    eUnidades: TEdit;
    GroupBox1: TGroupBox;
    lCantidad: TLabel;
    lCronVar: TLabel;
    lDecimales: TLabel;
    lDigitos: TLabel;
    lMaxEjeY: TLabel;
    lMinEjeY: TLabel;
    lNombreHoja: TLabel;
    lPrintProbsAisladas: TLabel;
    lTitulo: TLabel;
    lUnidades: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    rbg_TipoImpresion: TRadioGroup;
    sgPrintProbsAisladas: TStringGrid;
    procedure cambiosForm(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditStringExit(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure cbChartMatClick(Sender: TObject);
    procedure cbMinEjeYAutoClick(Sender: TObject);
    procedure cbMaxEjeYAutoClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bCancelarClick(Sender: TObject);
    procedure EditTamExit(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure eNroProbsAisladasKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditDigitosExit(Sender: TObject);
    procedure eDecimalesExit(Sender: TObject);
    procedure cbCronVarChange(Sender: TObject);
    procedure cbCronVarEnter(Sender: TObject);
    procedure eTamSGVectorDeRealesChange(Sender: TObject);
    procedure rbg_TipoImpresionClick(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar); override;
  end;



implementation

  {$R *.lfm}


Constructor TAltaEdicionPrintCronVar_histograma.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar);
var
  printCronVarCast: TPrintCronVar_histograma;
begin
  inherited Create(AOwner, lector, printCronVar, tipoPrintCronVar);

  inicializarCBCronVars(cbCronVar, False);

  if printCronVar <> NIL then
  begin
    printCronVarCast:= TPrintCronVar_histograma(printCronVar);
    setCBCronVar(cbCronVar, printCronVarCast.cronVar);
    eNombreHoja.Text:= printCronVarCast.nombreHoja;
    eTitulo.Text:= printCronVarCast.titulo;
    eUnidades.Text:= printCronVarCast.unidades;

    setSGVectorDeReales(sgPrintProbsAisladas, eNroProbsAisladas, printCronVarCast.Print_probAisladas);

    eDigitos.Text:= IntToStr(printCronVarCast.digitos);
    eDecimales.Text:= IntToStr(printCronVarCast.decimales);
    cbPrintTodas.Checked:= printCronVarCast.Print_Todas;
    cbPrintPromedio.Checked:= printCronVarCast.Print_promedio;
    cbPreOrdenar.Checked:= printCronVarCast.Pre_Ordenar;
    if  printCronVarCast.TipoImpresion_PE then
      rbg_TipoImpresion.ItemIndex:= 0
    else
      rbg_TipoImpresion.ItemIndex:= 1;

    cbChartMat.Checked:= printCronVarCast.chart_Mat;
    cbChartMatClick(NIL);

    cbMinEjeYAuto.Checked:= printCronVarCast.minEjeYAuto;
    if cbChartMat.Checked then
      cbMinEjeYAutoClick(NIL);
    eMinEjeY.Text:= FloatToStrF(printCronVarCast.minEjeY, ffGeneral, 16, 10);

    cbMaxEjeYAuto.Checked:= printCronVarCast.maxEjeYAuto;
    if cbChartMat.Checked then
      cbMaxEjeYAutoClick(NIL);
    eMaxEjeY.Text:= FloatToStrF(printCronVarCast.MaxEjeY, ffGeneral, 16, 10);
  end
  else
    setSGVectorDeReales(sgPrintProbsAisladas, eNroProbsAisladas, NIL);
  guardado:= true;    
end;

procedure TAltaEdicionPrintCronVar_histograma.eDecimalesExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 0, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_histograma.EditTamExit(Sender: TObject);
begin
  inherited cambioTamanioSGVectorDeReales(sgPrintProbsAisladas, eNroProbsAisladas, 0, MaxInt, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

procedure TAltaEdicionPrintCronVar_histograma.eNroProbsAisladasKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
    EditTamExit(Sender);
end;

procedure TAltaEdicionPrintCronVar_histograma.eTamSGVectorDeRealesChange(
  Sender: TObject);
begin
  inherited eTamSGVectorDeRealesChange(sgPrintProbsAisladas, eNroProbsAisladas, 0, MaxInt, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

procedure TAltaEdicionPrintCronVar_histograma.rbg_TipoImpresionClick(
  Sender: TObject);
begin

end;

function TAltaEdicionPrintCronVar_histograma.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbCronVar) and
           validarNombreHoja(eNombreHoja) and
           validarEditString(eTitulo, RS_TITULO ) and
           validarEditString(eUnidades, RS_UNIDADES ) and
           validarEditInt(eDigitos, 1, MaxInt) and
           validarEditInt(eDecimales, 0, MaxInt) and
           validarSGVectorDeRealesOrdenado(sgPrintProbsAisladas, true) and
           (not cbChartMat.Checked or
           (validarEditFloatCondicional(cbMinEjeYAuto, eMinEjeY, -MaxNReal, MaxNReal, false) and
           validarEditFloatCondicional(cbMaxEjeYAuto, eMinEjeY, -MaxNReal, MaxNReal, false)));
end;

procedure TAltaEdicionPrintCronVar_histograma.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPrintCronVar_histograma);
end;

procedure TAltaEdicionPrintCronVar_histograma.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionPrintCronVar_histograma.bGuardarClick(Sender: TObject);
var
  printCronVarCast: TPrintCronVar_histograma;
  minEjeYAuto, maxEjeYAuto: boolean;
  minEjeY, maxEjeY: NReal;
begin
  if validarFormulario then
  begin
    valoresEditFloatCondicional(cbMinEjeYAuto, eMinEjeY, False, minEjeYAuto, minEjeY);
    valoresEditFloatCondicional(cbMaxEjeYAuto, eMaxEjeY, False, maxEjeYAuto, maxEjeY);

    if printCronVar = NIL then
      printCronVar:= TPrintCronVar_histograma.Create(valorCBCronVar(cbCronVar),
                                                     eNombreHoja.Text, eTitulo.Text,
                                                     eUnidades.Text,
                                                     StrToInt(eDigitos.Text), StrToInt(eDecimales.Text),
                                                     cbPrintTodas.Checked,
                                                     cbPrintPromedio.Checked,
                                                     cbPreOrdenar.Checked,
                                                     rbg_TipoImpresion.ItemIndex= 0,
                                                     valorSGVectorDeReales(sgPrintProbsAisladas),
                                                     cbChartMat.Checked,
                                                     minEjeYAuto, maxEjeYAuto,
                                                     minEjeY, maxEjey)
    else
    begin
      printCronVarCast:= TPrintCronVar_histograma(printCronVar);
      printCronVarCast.cronVar:= valorCBCronVar(cbCronVar);
      printCronVarCast.nombreHoja:= eNombreHoja.Text;
      printCronVarCast.titulo:= eTitulo.Text;
      printCronVarCast.unidades:= eUnidades.Text;
      printCronVarCast.Print_probAisladas:= valorSGVectorDeReales(sgPrintProbsAisladas);
      printCronVarCast.digitos:= StrToInt(eDigitos.Text);
      printCronVarCast.decimales:= StrToInt(eDecimales.Text);
      printCronVarCast.Print_Todas:= cbPrintTodas.Checked;
      printCronVarCast.Print_promedio:= cbPrintPromedio.Checked;
      printCronVarCast.Pre_Ordenar:= cbPreOrdenar.Checked;
      printCronVarCast.TipoImpresion_PE:= rbg_TipoImpresion.ItemIndex= 0;

      printCronVarCast.chart_Mat:= cbChartMat.Checked;
      printCronVarCast.minEjeYAuto:= minEjeYAuto;
      printCronVarCast.minEjeY:= minEjeY;
      printCronVarCast.maxEjeYAuto:= maxEjeYAuto;
      printCronVarCast.MaxEjeY:= maxEjeY;
    end;

    modalResult:= mrOk;
  end;
end;

procedure TAltaEdicionPrintCronVar_histograma.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TAltaEdicionPrintCronVar_histograma.cbChartMatClick(Sender: TObject);
begin
  inherited cbChartMatClick(Sender, cbChartMat, cbMinEjeYAuto, cbMaxEjeYAuto, lMinEjeY,
                            lMaxEjeY, eMinEjeY, eMaxEjeY);
end;

procedure TAltaEdicionPrintCronVar_histograma.cbCronVarChange(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, true);
  if (eTitulo.Text = loQueHabia) or
     (eTitulo.Text = '')  then
    eTitulo.Text:= valorCBString(TComboBox(Sender));
  if (eNombreHoja.Text = loQueHabia) or
     (eNombreHoja.Text = '') then
    eNombreHoja.Text:= valorCBString(TComboBox(Sender));
  loQueHabia:= valorCBString(TComboBox(Sender));
end;

procedure TAltaEdicionPrintCronVar_histograma.cbCronVarEnter(Sender: TObject);
begin
  inherited CBEnter(Sender);
end;

procedure TAltaEdicionPrintCronVar_histograma.cbMaxEjeYAutoClick(
  Sender: TObject);
begin
  inherited CBEditFloatCondicionalClick(cbMaxEjeYAuto, lMaxEjeY, eMaxEjeY, false);
end;

procedure TAltaEdicionPrintCronVar_histograma.cbMinEjeYAutoClick(
  Sender: TObject);
begin
  inherited CBEditFloatCondicionalClick(cbMinEjeYAuto, lMinEjeY, eMinEjeY, false);
end;

procedure TAltaEdicionPrintCronVar_histograma.EditDigitosExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_histograma.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionPrintCronVar_histograma.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionPrintCronVar_histograma.EditStringExit(Sender: TObject);
begin
  inherited EditStringExit(Sender, True);
end;

procedure TAltaEdicionPrintCronVar_histograma.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
