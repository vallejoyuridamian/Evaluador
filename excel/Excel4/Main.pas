unit Main;
{
  Main.pas
  Copyright (c) 1997 by Charlie Calvert
  Creating data and a chart in Excel and copying both to Word.
}

interface

uses
  variants,
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    SendMailBtn: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SendMailBtnClick(Sender: TObject);
  private
    XLApp: Variant;
    WordApp: Variant;
  public
    procedure HandleData;
    procedure ChartData;
    procedure CopyData;
    procedure CopyChartToWord;
    procedure CopyCellsToWord;
  end;

var
  Form1: TForm1;

implementation

uses
  ComObj, XLConst, WordConst,
  ActiveX;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  XLApp := CreateOleObject('Excel.Application');
  XLApp.Visible := True;
  XLApp.Workbooks.Add[XLWBatWorksheet];
  XLApp.Workbooks[1].Worksheets[1].Name := 'Delphi Data';
  HandleData;
  ChartData;
  CopyData;
  SendMailBtn.Enabled := True;
end;

procedure TForm1.HandleData;
var
  Sheet: Variant;
  i: Integer;
begin
  Sheet := XLApp.Workbooks[1].Worksheets['Delphi Data'];
  for i := 1 to 10 do
    Sheet.Cells[i, 1] := i;
end;

procedure TForm1.ChartData;
var
  ARange: Variant;
  Sheets: Variant;
begin
  XLApp.Workbooks[1].Sheets.Add(,,1,xlChart);
  Sheets := XLApp.Sheets;
  ARange := Sheets.Item['Delphi Data'].Range['A1:A10'];
  Sheets.Item[1{'Chart1'}].SeriesCollection.Item[1].Values := ARange;
  Sheets.Item[1].ChartType := xl3DPie;
  Sheets.Item[1].SeriesCollection.Item[1].HasDataLabels := True;

  XLApp.Workbooks[1].Sheets.Add(,,1,xlChart);
  Sheets.Item[2].SeriesCollection.Item[1].Values := ARange;
  Sheets.Item[2].SeriesCollection.Add(ARange);
  Sheets.Item[2].SeriesCollection.NewSeries;
  Sheets.Item[2].SeriesCollection.Item[1].Values :=
    VarArrayOf([1,2,3,4,5, 6,7,8,9,10]);
  Sheets.Item[2].ChartType := xl3DColumn;
end;

procedure TForm1.CopyData;
var
  Sheets: Variant;
begin
  SetFocus;

  Sheets := XLApp.Sheets;

  Sheets.Item['Delphi Data'].Activate;
  Sheets.Item['Delphi Data'].Range['A1:A10'].Select;
  Sheets.Item['Delphi Data'].UsedRange.Copy;
  CopyCellsToWord;
  XLApp.CutCopyMode:= false;

    Sheets.Item[1].Select;
    XLApp.ActiveChart.ChartArea.Select;
    XLApp.ActiveChart.ChartArea.Copy;
          (*
  Sheets.Item[1{'Chart1'}].Select;
  XLApp.Selection.Copy;
  *)
  CopyChartToWord;
end;

procedure TForm1.CopyChartToWord;
var
  Range: Variant;
  i, NumPars: Integer;
begin
  NumPars := WordApp.Documents.Item(1).Paragraphs.Count;

  Range := WordApp.Documents.Item(1).Range(
    WordApp.Documents.Item(1).Paragraphs.Item(NumPars).Range.Start,
    WordApp.Documents.Item(1).Paragraphs.Item(NumPars).Range.End);
  Range.Text := 'This is graph: ';

  for i := 1 to 3 do WordApp.Documents.Item(1).Paragraphs.Add;

  Range := WordApp.Documents.Item(1).Range(
    WordApp.Documents.Item(1).Paragraphs.Item(NumPars + 1).Range.Start,
    WordApp.Documents.Item(1).Paragraphs.Item(NumPars + 1).Range.End);

//  Range.PasteSpecial(,,,,wdPasteOleObject);
  Range.Paste; //Special(,,,,wdPasteOleObject);
end;

procedure TForm1.CopyCellsToWord;
var
  Range: Variant;
  i: Integer;
begin
  WordApp := CreateOleObject('Word.Application');
  WordApp.Visible := True;
  WordApp.Documents.Add;
  Range := WordApp.Documents.Item(1).Range;
  Range.Text := 'This is a column from a spreadsheet: ';
  for i := 1 to 3 do WordApp.Documents.Item(1).Paragraphs.Add;
  Range := WordApp.Documents.Item(1).Range(WordApp.Documents.Item(1).Paragraphs.Item(3).Range.Start);
  Range.Paste;
  for i := 1 to 3 do WordApp.Documents.Item(1).Paragraphs.Add;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if not VarIsEmpty(XLApp) then begin
    XLApp.DisplayAlerts := False;  // Discard unsaved files....
    XLApp.Quit;
  end;

  if not VarIsEmpty(WordApp)then begin
    WordApp.Documents.Item(1).Close(wdDoNotSaveChanges);
    WordApp.Quit;
  end;
end;

procedure TForm1.SendMailBtnClick(Sender: TObject);
begin
  WordApp.Documents.Item(1).SaveAs('d:\basura\foo.doc');
  WordApp.Options.SendMailAttach := True;
  WordApp.Documents.Item(1).SendMail;
end;

end.
