unit uAltaEdicionTPrintCronVar_Histograma_text;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls,
  uBaseAltaEdicionPrintCronVars, uLectorSimRes3Defs, uverdoc, uPrintCronVars,
  xMatDefs, utilidades, uConstantesSimSEE, uOpcionesSimSEEEdit;

type

  { TAltaEdicionPrintCronVar_histograma_text }

  TAltaEdicionPrintCronVar_histograma_text = class(TBaseAltaEdicionPrintCronVars)
    cbPreOrdenar: TCheckBox;
    lTitulo: TLabel;
    lCronVar: TLabel;
    lNombreHoja: TLabel;
    lUnidades: TLabel;
    lDigitos: TLabel;
    lDecimales: TLabel;
    eTitulo: TEdit;
    cbCronVar: TComboBox;
    rbg_TipoImpresion: TRadioGroup;
    sgPrintProbsAisladas: TStringGrid;
    eArchi: TEdit;
    eUnidades: TEdit;
    eDigitos: TEdit;
    eDecimales: TEdit;
    cbPrintPromedio: TCheckBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    lPrintProbsAisladas: TLabel;
    lCantidad: TLabel;
    eNroProbsAisladas: TEdit;
    cbPrintTodas: TCheckBox;
    lProbs: TLabel;
    procedure cambiosForm(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditStringExit(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
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
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar); override;
  end;

implementation
  {$R *.lfm}

Constructor TAltaEdicionPrintCronVar_histograma_text.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar);
var
  printCronVarCast: TPrintCronVar_histograma_text;
begin
  inherited Create(AOwner, lector, printCronVar, tipoPrintCronVar);

  inicializarCBCronVars(cbCronVar, False);

  if printCronVar <> NIL then
  begin
    printCronVarCast:= TPrintCronVar_histograma_text(printCronVar);
    setCBCronVar(cbCronVar, printCronVarCast.cronVar);
    eArchi.Text:= printCronVarCast.nombreHoja;
    eTitulo.Text:= printCronVarCast.titulo;
    eUnidades.Text:= printCronVarCast.unidades;

    setSGVectorDeReales(sgPrintProbsAisladas, eNroProbsAisladas, printCronVarCast.Print_probAisladas);

    eDigitos.Text:= IntToStr(printCronVarCast.digitos);
    eDecimales.Text:= IntToStr(printCronVarCast.decimales);
    cbPrintTodas.Checked:= printCronVarCast.Print_Todas;
    cbPrintPromedio.Checked:= printCronVarCast.Print_promedio;
    cbPreOrdenar.Checked:= printCronVarCast.Pre_Ordenar;
    if printCronVarCast.TipoImpresion_PE then
      rbg_TipoImpresion.ItemIndex:= 0
    else
      rbg_TipoImpresion.ItemIndex:= 1;
  end
  else
    setSGVectorDeReales(sgPrintProbsAisladas, eNroProbsAisladas, NIL);
  guardado:= true;
end;

procedure TAltaEdicionPrintCronVar_histograma_text.eDecimalesExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 0, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.EditTamExit(Sender: TObject);
begin
  inherited cambioTamanioSGVectorDeReales(sgPrintProbsAisladas, eNroProbsAisladas, 0, MaxInt, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.eNroProbsAisladasKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
    EditTamExit(Sender);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.eTamSGVectorDeRealesChange(
  Sender: TObject);
begin
  inherited eTamSGVectorDeRealesChange(sgPrintProbsAisladas, eNroProbsAisladas, 0, MaxInt, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

function TAltaEdicionPrintCronVar_histograma_text.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbCronVar) and
           validarNombreHoja(eArchi) and
           validarEditString(eTitulo, 'Titulo') and
           validarEditString(eUnidades, 'Unidades') and
           validarEditInt(eDigitos, 1, MaxInt) and
           validarEditInt(eDecimales, 0, MaxInt) and
           validarSGVectorDeRealesOrdenado(sgPrintProbsAisladas, true);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPrintCronVar_histograma_text);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.bGuardarClick(Sender: TObject);
var
  printCronVarCast: TPrintCronVar_histograma_text;

begin
  if validarFormulario then
  begin

    if printCronVar = NIL then
      printCronVar:= TPrintCronVar_histograma_text.Create(valorCBCronVar(cbCronVar),
                                                     eArchi.Text, eTitulo.Text,
                                                     eUnidades.Text,
                                                     StrToInt(eDigitos.Text), StrToInt(eDecimales.Text),
                                                     cbPrintTodas.Checked,
                                                     cbPrintPromedio.Checked,
                                                     cbPreOrdenar.Checked,
                                                     rbg_TipoImpresion.ItemIndex = 0,
                                                     valorSGVectorDeReales(sgPrintProbsAisladas)
                                                     )
    else
    begin
      printCronVarCast:= TPrintCronVar_histograma_text(printCronVar);
      printCronVarCast.cronVar:= valorCBCronVar(cbCronVar);
      printCronVarCast.nombreHoja:= eArchi.Text;
      printCronVarCast.titulo:= eTitulo.Text;
      printCronVarCast.unidades:= eUnidades.Text;
      printCronVarCast.Print_probAisladas:= valorSGVectorDeReales(sgPrintProbsAisladas);
      printCronVarCast.digitos:= StrToInt(eDigitos.Text);
      printCronVarCast.decimales:= StrToInt(eDecimales.Text);
      printCronVarCast.Print_Todas:= cbPrintTodas.Checked;
      printCronVarCast.Print_promedio:= cbPrintPromedio.Checked;
      printCronVarCast.Pre_Ordenar:= cbPreOrdenar.checked;
      printCronVarCast.TipoImpresion_PE:= rbg_TipoImpresion.ItemIndex = 0;
    end;

    modalResult:= mrOk;
  end;
end;

procedure TAltaEdicionPrintCronVar_histograma_text.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;


procedure TAltaEdicionPrintCronVar_histograma_text.cbCronVarChange(Sender: TObject);
begin
  inherited cbCronVarChange(Sender, true);
  if (eTitulo.Text = loQueHabia) or
     (eTitulo.Text = '')  then
    eTitulo.Text:= valorCBString(TComboBox(Sender));
  if (eArchi.Text = loQueHabia) or
     (eArchi.Text = '') then
    eArchi.Text:= valorCBString(TComboBox(Sender));
  loQueHabia:= valorCBString(TComboBox(Sender));
end;

procedure TAltaEdicionPrintCronVar_histograma_text.cbCronVarEnter(Sender: TObject);
begin
  inherited CBEnter(Sender);
end;


procedure TAltaEdicionPrintCronVar_histograma_text.EditDigitosExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.EditStringExit(Sender: TObject);
begin
  inherited EditStringExit(Sender, True);
end;

procedure TAltaEdicionPrintCronVar_histograma_text.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
