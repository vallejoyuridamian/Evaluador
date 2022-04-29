unit uAltaEdicionTPrintCronVar_HistogramaGlobal;
{$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  uBaseAltaEdicionPrintCronVars, uLectorSimRes3Defs, uverdoc, uPrintCronVars,
  xMatDefs, utilidades, uconstantesSimSEE;

type
  TAltaEdicionPrintCronVar_HistogramaGlobal = class(TBaseAltaEdicionPrintCronVars)
    lTitulo: TLabel;
    lCronVar: TLabel;
    lNombreHoja: TLabel;
    lUnidades: TLabel;
    lDigitos: TLabel;
    lDecimales: TLabel;
    eTitulo: TEdit;
    cbCronVar: TComboBox;
    eNombreHoja: TEdit;
    eUnidades: TEdit;
    eDigitos: TEdit;
    eDecimales: TEdit;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    lMinX: TLabel;
    eMinX: TEdit;
    eMaxX: TEdit;
    eNPuntosHistograma: TEdit;
    lMaxX: TLabel;
    lNPuntosHistograma: TLabel;
    procedure cbCronVarChange(Sender: TObject);
    procedure cbCronVarEnter(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditStringExit(Sender: TObject);
    procedure eDigitosExit(Sender: TObject);
    procedure eDecimalesExit(Sender: TObject);
{    procedure cbChartMatClick(Sender: TObject);
    procedure cbMinEjeYAutoClick(Sender: TObject);
    procedure cbMaxEjeYAutoClick(Sender: TObject);}
    procedure EditFloatExit(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar); override;
  end;

implementation
  {$R *.lfm}

Constructor TAltaEdicionPrintCronVar_HistogramaGlobal.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar);
begin
  inherited Create(AOwner, lector, printCronVar, tipoPrintCronVar);

  inicializarCBCronVars(cbCronVar, False);

  if printCronVar <> NIL then
  begin
    setCBCronVar(cbCronVar, TPrintCronVar_HistogramaGlobal(printCronVar).cronVar);
    eNombreHoja.Text:= TPrintCronVar_HistogramaGlobal(printCronVar).nombreHoja;
    eTitulo.Text:= TPrintCronVar_HistogramaGlobal(printCronVar).titulo;
    eUnidades.Text:= TPrintCronVar_HistogramaGlobal(printCronVar).unidades;

    eDigitos.Text:= IntToStr(TPrintCronVar_HistogramaGlobal(printCronVar).digitos);
    eDecimales.Text:= IntToStr(TPrintCronVar_HistogramaGlobal(printCronVar).decimales);
    eMinX.Text:= FloatToStrF(TPrintCronVar_HistogramaGlobal(printCronVar).minX, ffGeneral, 16, 10);
    eMaxX.Text:= FloatToStrF(TPrintCronVar_HistogramaGlobal(printCronVar).maxX, ffGeneral, 16, 10);
    eNPuntosHistograma.Text:= IntToStr(TPrintCronVar_HistogramaGlobal(printCronVar).nPuntosHistograma);
{    cbChartMat.Checked:= TPrintCronVar_HistogramaGlobal(printCronVar).chart_Mat;
    cbChartMatClick(NIL);

    cbMinEjeYAuto.Checked:= TPrintCronVar_HistogramaGlobal(printCronVar).minEjeYAuto;
    if cbChartMat.Checked then
      cbMinEjeYAutoClick(NIL);
    eMinEjeY.Text:= FloatToStrF(TPrintCronVar_HistogramaGlobal(printCronVar).minEjeY, ffGeneral, 16, 10);

    cbMaxEjeYAuto.Checked:= TPrintCronVar_HistogramaGlobal(printCronVar).maxEjeYAuto;
    if cbChartMat.Checked then
      cbMaxEjeYAutoClick(NIL);
    eMaxEjeY.Text:= FloatToStrF(TPrintCronVar_HistogramaGlobal(printCronVar).MaxEjeY, ffGeneral, 16, 10);}

    guardado:= true;
  end;
end;

function TAltaEdicionPrintCronVar_HistogramaGlobal.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbCronVar) and
           validarNombreHoja(eNombreHoja) and
           validarEditString(eTitulo, 'Titulo') and
           validarEditString(eUnidades, 'Unidades') and
           validarEditInt(eDigitos, 1, MaxInt) and
           validarEditInt(eDecimales, 0, MaxInt) and
           validarEditFloat(eMinX, -MaxNReal, MaxNReal) and
           validarEditFloat(eMaxX, -MaxNReal, MaxNReal) and
           validarEditInt(eNPuntosHistograma, 2, MaxInt);
{           (not cbChartMat.Checked or
           (validarEditFloatCondicional(cbMinEjeYAuto, eMinEjeY, -MaxNReal, MaxNReal, false) and
           validarEditFloatCondicional(cbMaxEjeYAuto, eMinEjeY, -MaxNReal, MaxNReal, false)))};
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.BAyudaClick(
  Sender: TObject);
begin
  verdoc(Self, TPrintCronVar_HistogramaGlobal );
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.bGuardarClick(
  Sender: TObject);
{var
  minEjeYAuto, maxEjeYAuto: boolean;
  minEjeY, maxEjeY: NReal;}
begin
  if validarFormulario then
  begin
{    if cbChartMat.Checked then
    begin
      valoresEditFloatCondicional(cbMinEjeYAuto, eMinEjeY, False, minEjeYAuto, minEjeY);
      valoresEditFloatCondicional(cbMaxEjeYAuto, eMaxEjeY, False, maxEjeYAuto, maxEjeY);
    end
    else
    begin
      minEjeYAuto:= false;
      minEjeY:= 0;
      maxEjeYAuto:= false;
      maxEjeY:= 0;
    end;}

    if printCronVar = NIL then
      printCronVar:= TPrintCronVar_HistogramaGlobal.Create(valorCBCronVar(cbCronVar),
                                                           eNombreHoja.Text, eTitulo.Text,
                                                           eUnidades.Text,
                                                           StrToInt(eDigitos.Text), StrToInt(eDecimales.Text),
                                                           StrToFloat(eMinX.Text), StrToFloat(eMaxX.Text),
                                                           StrToInt(eNPuntosHistograma.Text)
                                                           {cbChartMat.Checked,
                                                           minEjeYAuto, maxEjeYAuto,
                                                           minEjeY, maxEjey})
    else
    begin
      TPrintCronVar_HistogramaGlobal(printCronVar).cronVar:= valorCBCronVar(cbCronVar);
      TPrintCronVar_HistogramaGlobal(printCronVar).nombreHoja:= eNombreHoja.Text;
      TPrintCronVar_HistogramaGlobal(printCronVar).titulo:= eTitulo.Text;
      TPrintCronVar_HistogramaGlobal(printCronVar).unidades:= eUnidades.Text;
      TPrintCronVar_HistogramaGlobal(printCronVar).digitos:= StrToInt(eDigitos.Text);
      TPrintCronVar_HistogramaGlobal(printCronVar).decimales:= StrToInt(eDecimales.Text);
      TPrintCronVar_HistogramaGlobal(printCronVar).minX:= StrToFloat(eMinX.Text);
      TPrintCronVar_HistogramaGlobal(printCronVar).maxX:= StrToFloat(eMaxX.Text);
      TPrintCronVar_HistogramaGlobal(printCronVar).nPuntosHistograma:= StrToInt(eNPuntosHistograma.Text);
{      TPrintCronVar_HistogramaGlobal(printCronVar).chart_Mat:= cbChartMat.Checked;
      TPrintCronVar_HistogramaGlobal(printCronVar).minEjeYAuto:= minEjeYAuto;
      TPrintCronVar_HistogramaGlobal(printCronVar).minEjeY:= minEjeY;
      TPrintCronVar_HistogramaGlobal(printCronVar).maxEjeYAuto:= maxEjeYAuto;
      TPrintCronVar_HistogramaGlobal(printCronVar).MaxEjeY:= maxEjeY;}
    end;

    modalResult:= mrOk;
  end;
end;

{procedure TAltaEdicionPrintCronVar_HistogramaGlobal.cbChartMatClick(
  Sender: TObject);
begin
  cbMinEjeYAuto.Enabled:= cbChartMat.Checked;
  lMinEjeY.Enabled:= cbMinEjeYAuto.Enabled;
  eMinEjeY.Enabled:= cbMinEjeYAuto.Enabled;

  cbMaxEjeYAuto.Enabled:= cbMinEjeYAuto.Enabled;
  lMaxEjeY.Enabled:= cbMinEjeYAuto.Enabled;
  eMaxEjeY.Enabled:= cbMinEjeYAuto.Enabled;
  if Sender <> NIL then //Inicializacion
    guardado:= false;
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.cbMaxEjeYAutoClick(
  Sender: TObject);
begin
  inherited CBEditFloatCondicionalClick(cbMaxEjeYAuto, lMaxEjeY, eMaxEjeY, false);
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.cbMinEjeYAutoClick(
  Sender: TObject);
begin
  inherited CBEditFloatCondicionalClick(cbMinEjeYAuto, lMinEjeY, eMinEjeY, false);
end;}

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.cbCronVarChange(
  Sender: TObject);
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

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.cbCronVarEnter(
  Sender: TObject);
begin
  inherited CBEnter(Sender);
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.eDecimalesExit(
  Sender: TObject);
begin
  inherited EditIntExit(Sender, 0, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.eDigitosExit(
  Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, MaxInt);
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.EditFloatExit(
  Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.EditStringExit(
  Sender: TObject);
begin
  inherited EditStringExit(Sender, true);
end;

procedure TAltaEdicionPrintCronVar_HistogramaGlobal.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.