unit uBaseAltaEdicionPrintCronVars;

{$MODE Delphi}
interface

uses
{$IFDEF FPC-LCL}
  LResources,
{$ENDIF}

  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls, Math,
  uBaseFormulariosEditorSimRes3,
  uLectorSimRes3Defs,
  uPrint, uPrintCronVars, uHistoVarsOps, uBaseFormularios,
  utilidades, uconstantesSimSEE, uOpcionesSimSEEEdit;

resourcestring
  mesYaExisteHojaDeNombre = 'Ya existe una hoja de nombre ';
  mesEnPrintCronVarTitulo = ' en la PrintCronVar de título ';
  mesNombreNoSerVacio = 'El campo nombre no puede ser vacio';
  rsVariableCronica = 'Variable crónica';
  rsTipoDeGrafico = 'Tipo de Grafico';
  rsEje = 'Eje';

type
  TClaseAltaEdicionPrintCronVars = class of TBaseAltaEdicionPrintCronVars;

  TBaseAltaEdicionPrintCronVars = class(TBaseFormulariosEditorSimRes3)
  protected
    printCronVar: TPrintCronVar;
    tipoPrintCronVar: TClaseDePrintCronVar;

    function validarNombreHoja(eNombreHoja: TEdit): boolean;


    procedure cbChartMatClick(Sender: TObject;
      cbChartMat, cbMinEjeYAuto, cbMaxEjeYAuto: TCheckBox;
      lMinEjeY, lMaxEjeY: TLabel; eMinEjey, eMaxEjey: TEdit);

    procedure inicializarSGCronVarTipoGraficoEjeColor(sg: TStringGrid;
      var tiposCols, tiposColSGColor: TDAOfTTipoColumna; cbCronVar: TComboBox; cbCronVarEjex: TComboBox;
      RGTipoGrafico, RGTipoEje: TRadioGroup; sgColor: TStringGrid;
      colorDialog: TColorDialog; bColorAuto: TButton;
      var coloresAgregar: TDAOfColores; bAgregar: TButton);
    procedure setSGCronVarTipoGraficoEjeColor(sg: TStringGrid;
      cronVars: TDAOfCronVar; tiposGraficos: TDAOfTTipoGrafico;
      ejes: TDAOfTTipoEje; coloresOrig: TDAOfTColor; cbCronVar: TComboBox;
      RGTipoGrafico, RGTipoEje: TRadioGroup; sgColor: TStringGrid;
      colorDialog: TColorDialog; bColorAuto: TButton; bAgregar: TButton;
      var coloresSG: TDAOfColores);
    procedure valorSGCronVarTipoGraficoEjeColor(sg: TStringGrid;
      var cronVars: TDAOfCronVar; var tiposGraficos: TDAOfTTipoGrafico;
      var ejes: TDAOfTTipoEje; var colores: TDAOfTColor; const coloresSG: TDAOfColores);


    procedure inicializarSGCronVar(sg: TStringGrid;
      var tiposCols: TDAOfTTipoColumna; cbCronVar: TComboBox; bAgregar: TButton);


    procedure setSGCronVar(sg: TStringGrid; cronVars: TDAOfCronVar;
      cbCronVar: TComboBox; bAgregar: TButton);


    procedure addSGCronVar(sg: TStringGrid; cbCronVar: TComboBox;
      bAgregar: TButton; var coloresSG: TDAOfColores);
    procedure eliminarSGCronVa(sg: TStringGrid; fila: integer;
      cbCronVar: TComboBox; bAgregar: TButton);


    procedure addSGCronVarTipoGraficoEjeColor(sg: TStringGrid;
      cbCronVar: TComboBox; RGTipoGrafico, RGTipoEje: TRadioGroup;
      sgColor: TStringGrid; colorDialog: TColorDialog; bColorAuto: TButton;
      bAgregar: TButton; var coloresSG: TDAOfColores);

    procedure eliminarSGCronVarTipoGraficoEjeColor(sg: TStringGrid;
      fila: integer; cbCronVar: TComboBox; RGTipoGrafico, RGTipoEje: TRadioGroup;
      sgColor: TStringGrid; colorDialog: TColorDialog; bColorAuto: TButton;
      bAgregar: TButton; var coloresSG, coloresSGAgregar: TDAOfColores);
    procedure bColorAutoClick(bColorAuto: TButton; sgAgregarColor: TStringGrid;
      colorDialog: TColorDialog; var coloresSGAgregar: TDAOfColores);

  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs;
      printCronVar: TPrintCronVar; tipoPrintCronVar: TClaseDePrintCronVar);
      reintroduce; virtual;
    function darPrintCronVar: TPrintCronVar;
  end;

implementation

{$R *.lfm}

constructor TBaseAltaEdicionPrintCronVars.Create(AOwner: TComponent;
  lector: TLectorSimRes3Defs; printCronVar: TPrintCronVar;
  tipoPrintCronVar: TClaseDePrintCronVar);
begin
  inherited Create(AOwner, lector);
  self.printCronVar := printCronVar;
  if printCronVar = nil then
    self.Caption := rs_Alta_de + ' ' + tipoPrintCronVar.tipo
  else
    self.Caption := rs_Edicion_de + ' ' + tipoPrintCronVar.tipo;
  self.tipoPrintCronVar := tipoPrintCronVar;
end;

function TBaseAltaEdicionPrintCronVars.darPrintCronVar: TPrintCronVar;
begin
  Result := self.printCronVar;
end;

function TBaseAltaEdicionPrintCronVars.validarNombreHoja(eNombreHoja: TEdit): boolean;
var
  otraPrintCronVar: TPrintCronVar;
begin
  if eNombreHoja.Text <> '' then
  begin
    if not lector.nombreHojaPrintCronVarRepetido(printCronVar,
      eNombreHoja.Text, otraPrintCronVar) then
      Result := True
    else
    begin
      if otraPrintCronVar = nil then
        ShowMessage(mesYaExisteHojaDeNombre + eNombreHoja.Text)
      else
        ShowMessage(mesYaExisteHojaDeNombre + eNombreHoja.Text +
          mesEnPrintCronVarTitulo + otraPrintCronVar.titulo);
      Result := False;
    end;
  end
  else
  begin
    ShowMessage(mesNombreNoSerVacio);
    Result := False;
  end;
end;


procedure TBaseAltaEdicionPrintCronVars.cbChartMatClick(Sender: TObject;
  cbChartMat, cbMinEjeYAuto, cbMaxEjeYAuto: TCheckBox; lMinEjeY, lMaxEjeY: TLabel;
  eMinEjey, eMaxEjey: TEdit);
begin
  cbMinEjeYAuto.Enabled := cbChartMat.Checked;
  lMinEjeY.Enabled := cbMinEjeYAuto.Enabled and not cbMinEjeYAuto.Checked;
  eMinEjeY.Enabled := lMinEjeY.Enabled;

  cbMaxEjeYAuto.Enabled := cbMinEjeYAuto.Enabled;
  lMaxEjeY.Enabled := cbMaxEjeYAuto.Enabled and not cbMaxEjeYAuto.Checked;
  eMaxEjeY.Enabled := lMaxEjeY.Enabled;
  if Sender <> nil then //Inicializacion
    guardado := False;
end;

procedure TBaseAltaEdicionPrintCronVars.inicializarSGCronVarTipoGraficoEjeColor(
  sg: TStringGrid; var tiposCols, tiposColSGColor: TDAOfTTipoColumna;
  cbCronVar: TComboBox; cbCronVarEjex: TComboBox;  RGTipoGrafico, RGTipoEje: TRadioGroup;
  sgColor: TStringGrid; colorDialog: TColorDialog; bColorAuto: TButton;
  var coloresAgregar: TDAOfColores; bAgregar: TButton);
var
  i: TTipoGrafico;
  j: TTipoEje;
begin
  sg.Options := sg.Options + [goRowSelect];
  inicializarCBCronVars(cbCronVar, False);
  inicializarCBCronVarsEjex(cbCronVarEjex,False);


  if RGTipoGrafico.Items.Count = 0 then
    for i := low(TTipoGrafico) to high(TTipoGrafico) do
      RGTipoGrafico.Items.Add(TTipoGraficoToString(i));
  RGTipoGrafico.ItemIndex := 0;

  if RGTipoEje.Items.Count = 0 then
    for j := low(TTipoEje) to high(TTipoEje) do
      RGTipoEje.Items.Add(TTipoEjeToString(j));
  RGTipoEje.ItemIndex := 0;

  SetLength(coloresAgregar, 1);
  coloresAgregar[0] := colorDialog.Color;
  initListado(sgColor, [encabezadoColor], tiposColSGColor, False);
  sgColor.Options := sgColor.Options - [goDrawFocusSelected];
  sgColor.RowCount := 1;
  sgColor.ScrollBars := ssNone;
  //  sgColor.DefaultColWidth:= sgColor.ClientWidth;
  //  sgColor.ColWidths[0]:= sgColor.ClientWidth;

  initListado(sg,
    [rsVariableCronica, rsTipoDeGrafico, rsEje, encabezadoColor,
    encabezadoBTEliminar, encabezadoBTUp, encabezadoBTDown],
    tiposCols, True);
end;



procedure TBaseAltaEdicionPrintCronVars.setSGCronVarTipoGraficoEjeColor(sg: TStringGrid;
  cronVars: TDAOfCronVar; tiposGraficos: TDAOfTTipoGrafico;
  ejes: TDAOfTTipoEje; coloresOrig: TDAOfTColor; cbCronVar: TComboBox;
  RGTipoGrafico, RGTipoEje: TRadioGroup; sgColor: TStringGrid;
  colorDialog: TColorDialog; bColorAuto: TButton; bAgregar: TButton;
  var coloresSG: TDAOfColores);
var
  i, iCronVar: integer;
begin
  sg.RowCount := Length(cronVars) + 1;
  if sg.RowCount > 1 then
    sg.FixedRows := 1;

  SetLength(coloresSG, length(coloresOrig));
  for i := 0 to high(cronVars) do
  begin
    sg.Cells[0, i + 1] := cronVars[i].nombre;
    sg.Cells[1, i + 1] := TTipoGraficoToString(tiposGraficos[i]);
    sg.Cells[2, i + 1] := TTipoEjeToString(ejes[i]);
    sg.Cells[3, i + 1] := '';
    coloresSG[i] := coloresOrig[i];

    iCronVar := cbCronVar.Items.IndexOf(cronVars[i].nombre);
    if iCronVar >= 0 then
      cbCronVar.Items.Delete(iCronVar);
  end;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
  RGTipoGrafico.Enabled := bAgregar.Enabled;
  RGTipoEje.Enabled := bAgregar.Enabled;
  sgColor.Enabled := bAgregar.Enabled;
  bColorAuto.Enabled := bAgregar.Enabled;
end;

procedure TBaseAltaEdicionPrintCronVars.valorSGCronVarTipoGraficoEjeColor(
  sg: TStringGrid; var cronVars: TDAOfCronVar; var tiposGraficos: TDAOfTTipoGrafico;
  var ejes: TDAOfTTipoEje; var colores: TDAOfTColor; const coloresSG: TDAOfColores);
var
  i: integer;
begin
  SetLength(cronVars, sg.RowCount - 1);
  SetLength(tiposGraficos, sg.RowCount - 1);
  SetLength(ejes, sg.RowCount - 1);
  SetLength(colores, sg.RowCount - 1);
  for i := 0 to High(cronVars) do
  begin
    cronVars[i] := lector.getCronVarByName(sg.Cells[0, i + 1]);
    tiposGraficos[i] := StringToTTipoGrafico(sg.Cells[1, i + 1]);
    ejes[i] := StringToTTipoEje(sg.Cells[2, i + 1]);
    colores[i] := coloresSG[i];
  end;
end;




procedure TBaseAltaEdicionPrintCronVars.inicializarSGCronVar(sg: TStringGrid;
  var tiposCols: TDAOfTTipoColumna; cbCronVar: TComboBox;  bAgregar: TButton);

begin
  sg.Options := sg.Options + [goRowSelect];
  inicializarCBCronVars(cbCronVar, False);
  initListado(sg,
    [rsVariableCronica, encabezadoColor,
    encabezadoBTEliminar, encabezadoBTUp, encabezadoBTDown],
    tiposCols, True);
end;


procedure TBaseAltaEdicionPrintCronVars.setSGCronVar(sg: TStringGrid;
  cronVars: TDAOfCronVar; cbCronVar: TComboBox; bAgregar: TButton);
var
  i, iCronVar: integer;
begin
  sg.RowCount := Length(cronVars) + 1;
  if sg.RowCount > 1 then
    sg.FixedRows := 1;

  for i := 0 to high(cronVars) do
  begin
    sg.Cells[0, i + 1] := cronVars[i].nombre;

    iCronVar := cbCronVar.Items.IndexOf(cronVars[i].nombre);
    if iCronVar >= 0 then
      cbCronVar.Items.Delete(iCronVar);
  end;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
end;



procedure TBaseAltaEdicionPrintCronVars.addSGCronVarTipoGraficoEjeColor(sg: TStringGrid;
  cbCronVar: TComboBox; RGTipoGrafico, RGTipoEje: TRadioGroup;
  sgColor: TStringGrid; colorDialog: TColorDialog; bColorAuto: TButton;
  bAgregar: TButton; var coloresSG: TDAOfColores);
var
  i: integer;
  oldItemIndex: integer;
begin
  if validarCBCronVars(cbCronVar) then
  begin
    sg.RowCount := sg.RowCount + 1;
    if sg.RowCount > 1 then
      sg.FixedRows := 1;
    sg.Cells[0, sg.RowCount - 1] := cbCronVar.Items[cbCronVar.ItemIndex];
    sg.Cells[1, sg.RowCount - 1] :=
      TTipoGraficoToString(TTipoGrafico(RGTipoGrafico.ItemIndex));
    sg.Cells[2, sg.RowCount - 1] := TTipoEjeToString(TTipoEje(RGTipoEje.ItemIndex));
    SetLength(coloresSG, length(coloresSG) + 1);
    coloresSG[sg.RowCount - 2] := colorDialog.Color;

    oldItemIndex := cbCronVar.ItemIndex;
    cbCronVar.Items.Delete(cbCronVar.ItemIndex);
    if cbCronVar.Items.Count > 0 then
    begin
      cbCronVar.ItemIndex := min(oldItemIndex, cbCronVar.Items.Count - 1);
      cbCronVar.Text := cbCronVar.Items[cbCronVar.ItemIndex];
    end
    else
    begin
      cbCronVar.ItemIndex := -1;
      cbCronVar.Text := '';
    end;

    for i := 0 to 2 do
      utilidades.AutoSizeCol(sg, i);
    sg.Row := sg.RowCount - 1;

    guardado := False;
    bAgregar.Enabled := cbCronVar.Items.Count > 0;
    cbCronVar.Enabled := bAgregar.Enabled;
    RGTipoGrafico.Enabled := bAgregar.Enabled;
    RGTipoEje.Enabled := bAgregar.Enabled;
    sgColor.Enabled := bAgregar.Enabled;
    bColorAuto.Enabled := bAgregar.Enabled;
  end;
end;

procedure TBaseAltaEdicionPrintCronVars.eliminarSGCronVarTipoGraficoEjeColor(
  sg: TStringGrid; fila: integer; cbCronVar: TComboBox;
  RGTipoGrafico, RGTipoEje: TRadioGroup; sgColor: TStringGrid;
  colorDialog: TColorDialog; bColorAuto: TButton; bAgregar: TButton;
  var coloresSG, coloresSGAgregar: TDAOfColores);
var
  i: integer;
  posCronVarCB: integer;
begin
  posCronVarCB := findPosCronVarCB(sg.Cells[0, fila], cbCronVar);
  cbCronVar.Items.Insert(posCronVarCB, sg.Cells[0, fila]);
  if cbCronVar.ItemIndex = -1 then
  begin
    cbCronVar.ItemIndex := posCronVarCB;
    RGTipoGrafico.ItemIndex := Ord(StringToTTipoGrafico(sg.Cells[1, fila]));
    RGTipoEje.ItemIndex := Ord(StringToTTipoEje(sg.Cells[2, fila]));
    colorDialog.Color := coloresSG[fila - sg.FixedRows];
    coloresSGAgregar[0] := coloresSG[fila - sg.FixedRows];
    sgColor.Invalidate;
  end;
  for i := fila to sg.RowCount - 2 do
  begin
    sg.Cells[0, i] := sg.Cells[0, i + 1];
    sg.Cells[1, i] := sg.Cells[1, i + 1];
    sg.Cells[2, i] := sg.Cells[2, i + 1];
    coloresSG[i - sg.FixedRows] := coloresSG[i - sg.FixedRows + 1];
  end;

  sg.RowCount := sg.RowCount - 1;
  SetLength(coloresSG, length(coloresSG) - 1);

  for i := 0 to 2 do
    utilidades.AutoSizeCol(sg, i);

  guardado := False;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
  RGTipoGrafico.Enabled := bAgregar.Enabled;
  RGTipoEje.Enabled := bAgregar.Enabled;
  sgColor.Enabled := bAgregar.Enabled;
  bColorAuto.Enabled := bAgregar.Enabled;
end;


procedure TBaseAltaEdicionPrintCronVars.addSGCronVar(sg: TStringGrid;
  cbCronVar: TComboBox; bAgregar: TButton; var coloresSG: TDAOfColores);
var
  i: integer;
  oldItemIndex: integer;
begin
  if validarCBCronVars(cbCronVar) then
  begin
    sg.RowCount := sg.RowCount + 1;
    if sg.RowCount > 1 then
      sg.FixedRows := 1;
    sg.Cells[0, sg.RowCount - 1] := cbCronVar.Items[cbCronVar.ItemIndex];

    oldItemIndex := cbCronVar.ItemIndex;
    cbCronVar.Items.Delete(cbCronVar.ItemIndex);
    if cbCronVar.Items.Count > 0 then
    begin
      cbCronVar.ItemIndex := min(oldItemIndex, cbCronVar.Items.Count - 1);
      cbCronVar.Text := cbCronVar.Items[cbCronVar.ItemIndex];
    end
    else
    begin
      cbCronVar.ItemIndex := -1;
      cbCronVar.Text := '';
    end;

    for i := 0 to 2 do
      utilidades.AutoSizeCol(sg, i);
    sg.Row := sg.RowCount - 1;

    guardado := False;
    bAgregar.Enabled := cbCronVar.Items.Count > 0;
    cbCronVar.Enabled := bAgregar.Enabled;
  end;
end;



procedure TBaseAltaEdicionPrintCronVars.eliminarSGCronVa(sg: TStringGrid;
  fila: integer; cbCronVar: TComboBox; bAgregar: TButton);
var
  i: integer;
  posCronVarCB: integer;
begin
  posCronVarCB := findPosCronVarCB(sg.Cells[0, fila], cbCronVar);
  cbCronVar.Items.Insert(posCronVarCB, sg.Cells[0, fila]);
  if cbCronVar.ItemIndex = -1 then
  begin
    cbCronVar.ItemIndex := posCronVarCB;
  end;
  for i := fila to sg.RowCount - 2 do
  begin
    sg.Cells[0, i] := sg.Cells[0, i + 1];
  end;
  sg.RowCount := sg.RowCount - 1;

  for i := 0 to 2 do
    utilidades.AutoSizeCol(sg, i);

  guardado := False;
  bAgregar.Enabled := cbCronVar.Items.Count > 0;
  cbCronVar.Enabled := bAgregar.Enabled;
end;


procedure TBaseAltaEdicionPrintCronVars.bColorAutoClick(bColorAuto: TButton;
  sgAgregarColor: TStringGrid; colorDialog: TColorDialog;
  var coloresSGAgregar: TDAOfColores);
begin
  colorDialog.Color := clDefault;
  coloresSGAgregar[0] := colorDialog.Color;
  sgAgregarColor.Invalidate;
end;

initialization
end.
