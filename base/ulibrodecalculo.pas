unit ulibrodecalculo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms,
  LCLType,
  Controls, Graphics, Dialogs,
  Grids, Buttons, ComCtrls, ExtCtrls, StdCtrls, Menus,
  ugraficador, ufechas,
  clipbrd,
{$IFDEF EVALUADOR_EXPRESIONES}
  fpexprpars_x_grids,
{$ENDIF}
  utiposbasicosplanilla;

type
  TLibroDeCalculo = class;

  TLibroStringGrid = class(TStringGrid)
    procedure SelectionSetText_LIBRO_(TheText: string);
    procedure DoPasteFromClipboard; override;
  public
    aLibro: TLibroDeCalculo;
  end;

  { TLibroDeCalculo }

  TLibroDeCalculo = class(TForm)
    Copiar1: TMenuItem;
    editorTextoSimple: TEdit;
    GuardarJPG1: TMenuItem;
    OpenDialog1: TOpenDialog;
    PanelGrafico: TPaintBox;
    Panel1: TPanel;
    Panel2: TPanel;
    PanelGrid: TPanel;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    SaveDialog_JPG: TSaveDialog;
    tab_hojas: TTabControl;
    ToolBar1: TToolBar;
    SaveButton: TToolButton;
    LoadButton: TToolButton;
    procedure Copiar1Click(Sender: TObject);
    procedure editorTextoSimpleEditingDone(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure gridBeforeSelection(Sender: TObject; aCol, aRow: integer);
    procedure gridDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure gridGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure gridPrepareCanvas(Sender: TObject; aCol, aRow: integer;
      aState: TGridDrawState);
    procedure gridSetEditText(Sender: TObject; ACol, ARow: integer;
      const Value: string);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: integer;
      var Editor: TWinControl);

    procedure gridKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);

    procedure GuardarJPG1Click(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
    procedure PanelGraficoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure PanelGraficoPaint(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure tab_hojasChange(Sender: TObject);
  private
    { private declarations }
    function IndexToAlphaIndex(AIndex: integer): string;
  public
    { public declarations }
    pdatos: pointer;
    aHoja: THoja;
    aGrafico: TGrafico;
    grid_: TLibroStringGrid;
    {$IFDEF EVALUADOR_EXPRESIONES}
    FParser: TFPExpressionParser;
    {$ENDIF}
    procedure AddHoja(nombreHoja: string);
    procedure AddGrafico(nombreHoja: string);
    procedure Inicializar;

    {$IFDEF EVALUADOR_EXPRESIONES}
    function EvalExpresion( expr_str: string ): double;
    {$ENDIF}
  end;

var
  LibroDeCalculo: TLibroDeCalculo;

implementation

{$R *.lfm}
uses
  uExcelFile;



procedure TLibroStringGrid.SelectionSetText_LIBRO_(TheText: string);
var
  L, SubL: TStringList;
  i, j, StartCol, StartRow: integer;

  procedure CollectCols(const S: string);
  var
    P, Ini: PChar;
    St: string;
  begin
    Subl.Clear;
    P := PChar(S);
    if P <> nil then
      while P^ <> #0 do
      begin
        ini := P;
        while (P^ <> #0) and (P^ <> #9) do
          Inc(P);
        SetLength(St, P - Ini);
        Move(Ini^, St[1], P - Ini);
        SubL.Add(St);
        if P^ <> #0 then
          Inc(P);
      end;
  end;

begin
  L := TStringList.Create;
  SubL := TStringList.Create;
  StartCol := Selection.left;
  StartRow := Selection.Top;
  try
    L.Text := TheText;
    for j := 0 to L.Count - 1 do
    begin
      if j + StartRow >= RowCount then
        break;
      CollectCols(L[j]);
      for i := 0 to SubL.Count - 1 do
        if (i + StartCol < ColCount) and (not GetColumnReadonly(i + StartCol)) then
          if aLibro.aHoja <> nil then
          begin
            aLibro.aHoja.WriteEvalStr(j + StartRow, i + StartCol, SubL[i]);
            Cells[i + StartCol, j + StartRow] :=
              aLibro.aHoja.ReadEvalStr(j + StartRow, i + StartCol);
          end
          else
            Cells[i + StartCol, j + StartRow] := SubL[i];
    end;
  finally
    SubL.Free;
    L.Free;
  end;
end;

procedure TLibroStringGrid.DoPasteFromClipboard;
begin
  // Unpredictable results when a multiple selection is pasted back in.
  // Therefore we inhibit this here.
  //if HasMultiSelection then
  //  exit;

  if EditingAllowed(Col) and Clipboard.HasFormat(CF_TEXT) then
    SelectionSetText_LIBRO_(Clipboard.AsText);
end;


{ TLibroDeCalculo }

procedure TLibroDeCalculo.gridBeforeSelection(Sender: TObject; aCol, aRow: integer);
begin
  if Grid_.Col <> aCol then
  begin
    grid_.InvalidateCell(grid_.Col, 0);
    grid_.InvalidateCell(aCol, 0);
  end;

  if Grid_.Row <> aRow then
  begin
    grid_.InvalidateCell(0, grid_.Row);
    grid_.InvalidateCell(0, aRow);
  end;

end;

procedure TLibroDeCalculo.FormCreate(Sender: TObject);
begin
  pdatos := nil;
  aGrafico := nil;
  aHoja := nil;
end;


procedure TLibroDeCalculo.Inicializar;
begin
  {$IFDEF EVALUADOR_EXPRESIONES}
  FParser := TFPExpressionParser.Create(nil);
  FParser.Builtins:= [bcStrings, bcDateTime, bcMath, bcBoolean, bcConversion, bcData, bcVaria, bcUser];
  {$ENDIF}
  grid_ := TLibroStringGrid.Create(PanelGrid);
  grid_.RowCount := 200;
  grid_.ColCount := 1000;
  grid_.AutoAdvance:= aaRight;
  grid_.Width := PanelGrid.Width;
  grid_.Height := PanelGrid.Height;
  grid_.Parent := PanelGrid;
  grid_.Top := 0;
  grid_.Left := 0;
  grid_.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
    goRangeSelect, goEditing];
  grid_.Align := alClient;
  grid_.OnBeforeSelection := @gridBeforeSelection;
  grid_.OnDrawCell := @gridDrawCell;
  grid_.OnGetEditText := @gridGetEditText;
  grid_.OnPrepareCanvas := @gridPrepareCanvas;
  grid_.OnSetEditText := @gridSetEditText;
  grid_.OnSelectEditor := @StringGrid1SelectEditor;
  grid_.OnKeyDown := @gridKeyDown;

  grid_.Show;
  grid_.aLibro := Self;
  grid_.Invalidate;
end;

{$IFDEF EVALUADOR_EXPRESIONES}
function TLibroDeCalculo.EvalExpresion( expr_str: string ): double;
var
  parserResult: TFPExpressionResult;
  res: double;
begin
   FParser.Expression := expr_str;
   parserResult := FParser.Evaluate;
   res:= ArgToFloat(parserResult);
   result:= res;
end;
{$ENDIF}

procedure TLibroDeCalculo.Copiar1Click(Sender: TObject);
var
  b: TBitmap; // para copiar temporalmente la pantallita.
begin
  //first copy
  b := TBitmap.Create;
  try
    b.Width := PanelGrafico.Width;
    b.Height := PanelGrafico.Height;
    b.canvas.CopyRect(Rect(0, 0, b.Width, b.Height),
      PanelGrafico.Canvas, Rect(0, 0, b.Width, b.Height));
    Clipboard.Assign(b)
  finally
    b.Free
  end;
end;

procedure TLibroDeCalculo.editorTextoSimpleEditingDone(Sender: TObject);
begin
  aHoja.WriteEvalStr(grid_.Row, grid_.Col, editorTextoSimple.Text);
  grid_.Cells[grid_.Col, grid_.Row] := aHoja.ReadEvalStr(grid_.Row, grid_.Col);
end;

procedure TLibroDeCalculo.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  {$IFDEF EVALUADOR_EXPRESIONES}
  FParser.Free;
  {$ENDIF}
end;



procedure TLibroDeCalculo.gridDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);

  procedure HorizontalCenter;
  var
    aTextStyle: TTextStyle;
  begin
    aTextStyle := grid_.Canvas.TextStyle;
    aTextStyle.Alignment := taCenter;
    grid_.Canvas.TextStyle := aTextStyle;
  end;

begin

  if gdFixed in aState then
  begin
    if (aCol = 0) and (aRow >= Grid_.FixedRows) then
    begin
      HorizontalCenter;
      grid_.Canvas.TextRect(aRect, aRect.Left, aRect.Top, IntToStr(aRow));
      exit;
    end
    else
    if (aRow = 0) and (aCol >= Grid_.FixedCols) then
    begin
      HorizontalCenter;
      grid_.Canvas.TextRect(aRect, aRect.Left, aRect.Top,
        IndexToAlphaIndex(aCol - Grid_.FixedCols));
      exit;
    end;
  end;

  grid_.DefaultDrawCell(aCol, aRow, aRect, aState);
end;


procedure TLibroDeCalculo.gridPrepareCanvas(Sender: TObject;
  aCol, aRow: integer; aState: TGridDrawState);
begin
  if gdFixed in aState then
  begin
    if (aCol = grid_.Col) or (aRow = grid_.Row) then
      grid_.Canvas.Brush.Color := clInactiveCaption;
  end;
end;


procedure TLibroDeCalculo.gridGetEditText(Sender: TObject; ACol, ARow: integer;
  var Value: string);
var
  hoja: THoja;
begin
  hoja := THoja(TExcelFile(pdatos).hojas[TExcelFile(pdatos).kHojaActiva - 1]);
  Value := hoja.ReadEvalStr(aRow, aCol);
end;


procedure TLibroDeCalculo.gridSetEditText(Sender: TObject; ACol, ARow: integer;
  const Value: string);
var
  hoja: THoja;
begin
  hoja := THoja(TExcelFile(pdatos).hojas[TExcelFile(pdatos).kHojaActiva - 1]);
  hoja.WriteEvalStr(aRow, aCol, Value);
end;




procedure TLibroDeCalculo.StringGrid1SelectEditor(Sender: TObject;
  aCol, aRow: integer; var Editor: TWinControl);
begin
  //  if (aCol=3) and (aRow>0) then
  begin
    editorTextoSimple.BoundsRect := grid_.CellRect(aCol, aRow);
    editorTextoSimple.Text := grid_.Cells[aCol, aRow];
    Editor := editorTextoSimple;
  end;
end;


procedure TLibroDeCalculo.gridKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);

var
  r1, r2, c1, c2: integer;
  r, c: integer;
  buscando: boolean;
  flg_mover: boolean;
  flg_buscaEnDatos: boolean;
begin
  r1 := grid_.Selection.Top;
  r2 := grid_.Selection.Bottom;
  c1 := grid_.Selection.Left;
  c2 := grid_.Selection.Right;
  flg_mover := False;

//  writeln('key: ', key, ', R: ', r1, ',', r2, ',', c1, ',', c2);
  if ssCtrl in Shift then
  begin
    // Buscamos destino
    buscando := True;
    r := grid_.Row;
    c := grid_.Col;
    flg_buscaEnDatos := grid_.Cells[c, r] <> '';

    if flg_buscaEnDatos then
      case key of
        VK_LEFT:
        begin
          c := c1;
          while buscando and (c > grid_.FixedCols) do
            if grid_.Cells[c - 1, r] <> '' then
              Dec(c)
            else
              buscando := False;
          flg_mover := c <> c1;
          c1 := c;
        end;
        VK_RIGHT:
        begin
          c := c2;
          while buscando and (c < grid_.ColCount) do
            if grid_.Cells[c + 1, r] <> '' then
              Inc(c)
            else
              buscando := False;
          flg_mover := c <> c2;
          c2 := c;
        end;
        VK_UP:
        begin
          r := r1;
          while buscando and (r > grid_.FixedRows) do
            if grid_.Cells[c, r - 1] <> '' then
              Dec(r)
            else
              buscando := False;
          flg_mover := r <> r1;
          r1 := r;
        end;
        VK_DOWN:
        begin
          r := r2;
          while buscando and (r < grid_.RowCount) do
            if grid_.Cells[c, r + 1] <> '' then
              Inc(r)
            else
              buscando := False;
          flg_mover := r2 <> r;
          r2 := r;
        end;
      end
    else
      case key of
        VK_LEFT:
        begin
          c := c1;
          while buscando and (c > (grid_.FixedCols)) do
            if grid_.Cells[c, r] = '' then
              Dec(c)
            else
              buscando := False;
          flg_mover := c <> c1;
          c1 := c;
        end;
        VK_RIGHT:
        begin
          c := c2;
          while buscando and (c < (grid_.ColCount - 1)) do
            if grid_.Cells[c, r] = '' then
              Inc(c)
            else
              buscando := False;
          flg_mover := c <> c2;
          c2 := c;
        end;
        VK_UP:
        begin
          r := r1;
          while buscando and (r > (grid_.FixedRows)) do
            if grid_.Cells[c, r] = '' then
              Dec(r)
            else
              buscando := False;
          flg_mover := r <> r1;
          r1 := r;
        end;
        VK_DOWN:
        begin
          r := r2;
          while buscando and (r < (grid_.RowCount - 1)) do
            if grid_.Cells[c, r] = '' then
              Inc(r)
            else
              buscando := False;
          flg_mover := r2 <> r;
          r2 := r;
        end;
      end;

    if flg_mover then
    begin
      grid_.Col := c;
      grid_.Row := r;
      if ssShift in Shift then
        Grid_.Selection := TGridRect(Rect(c1, r1, c2, r2))
      else
        Grid_.Selection := TGridRect(Rect(c, r, c, r));
      key := 0;
    end;
  end;

end;


(*

procedure TLibroDeCalculo.gridValidateEntry(Sender: TObject;
  aCol, aRow: integer; const OldValue: string; var NewValue: string);
var
  hoja: THoja;
begin
  hoja := THoja(TExcelFile(pdatos).hojas[TExcelFile(pdatos).kHojaActiva - 1]);
  hoja.Write(aRow, aCol, NewValue);
end;

  *)


procedure SaveJPG(fn: string; b: TBitmap);
var
  jp: TJPEGImage;

begin
  jp := TJPEGImage.Create;
  try
    jp.Assign(b);
    jp.SaveToFile(fn);
  finally
    jp.Free;
  end;
end;



procedure TLibroDeCalculo.GuardarJPG1Click(Sender: TObject);
var
  b: TBitmap; // para copiar temporalmente la pantallita.

begin

  //first copy
  b := TBitmap.Create;
  try
    b.Width := PanelGrafico.Width;
    b.Height := PanelGrafico.Height;
    b.canvas.CopyRect(Rect(0, 0, b.Width, b.Height),
      PanelGrafico.Canvas, Rect(0, 0, b.Width, b.Height));

    if SaveDialog_JPG.Execute then
      SaveJPG(SaveDialog_JPG.filename, b);

  finally
    b.Free
  end;
end;


procedure TLibroDeCalculo.LoadButtonClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    grid_.LoadFromFile(OpenDialog1.FileName);
end;

procedure TLibroDeCalculo.PanelGraficoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
  begin
    PopUpMenu1.Popup(self.left + PanelGrafico.left + x, self.top + PanelGrafico.top + y);
  end;
end;

procedure TLibroDeCalculo.PanelGraficoPaint(Sender: TObject);
begin
  if aGrafico <> nil then
    aGrafico.Draw(PanelGrafico.Canvas, PanelGrafico.Width, PanelGrafico.Height);
end;

procedure TLibroDeCalculo.SaveButtonClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    grid_.SaveToFile(SaveDialog1.FileName);
end;



procedure TLibroDeCalculo.tab_hojasChange(Sender: TObject);
var
  aExcel: TExcelFile;
  nombreHojaActiva: string;
  nFilas, nColumnas, k, j: integer;
begin
  if pdatos <> nil then
  begin
    aExcel := TExcelFile(pdatos);
    if tab_hojas.TabIndex >= 0 then
    begin
      panelGrafico.hide;
      PanelGrid.hide;
      nombreHojaActiva := tab_hojas.Tabs[tab_hojas.TabIndex];
      aHoja := aExcel.GetHojaByName(nombreHojaActiva);
      if aHoja <> nil then
      begin
        aHoja.ShowOnStringGrid(grid_);
        PanelGrid.Show;
      end
      else
      begin
        aGrafico := aExcel.GetGraficoByName(nombreHojaActiva);
        if aGrafico <> nil then
          panelGrafico.Show;
      end;
    end;
  end;
end;

function TLibroDeCalculo.IndexToAlphaIndex(AIndex: integer): string;
var
  i: integer;
begin
  Result := chr((AIndex mod 26) + Ord('A'));
  i := (AIndex div 26) - 1;
  if i > 25 then
    Result := '[' + IntToStr(AIndex) + ']'
  else
  if i >= 0 then
    Result := chr(i + Ord('A')) + Result;
end;



procedure TLibroDeCalculo.AddHoja(nombreHoja: string);
begin
  tab_hojas.tabs.Add(nombreHoja);
end;

procedure TLibroDeCalculo.AddGrafico(nombreHoja: string);
begin
  tab_hojas.tabs.Add(nombreHoja);
end;

end.
