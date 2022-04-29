unit Main;

interface

uses
  variants,
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    XLApp: Variant;
    procedure InsertData;
    procedure ChangeColumns;
    procedure HandleRange;
  public
  end;

var
  Form1: TForm1;

implementation

uses
  ComObj, XLConst;

{$R *.DFM}

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if not VarIsEmpty(XLApp) then begin
    XLApp.DisplayAlerts := False;  // Discard unsaved files....
    XLApp.Quit;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  XLApp:= CreateOleObject('Excel.Application');
  XLApp.Visible := True;
  XLApp.Workbooks.Add(xlWBatWorkSheet);
  XLApp.Workbooks[1].WorkSheets[1].Name := 'Delphi Data';
  InsertData;
  HandleRange;
  ChangeColumns;
end;

procedure TForm1.InsertData;
var
  i: Integer;
  Sheet: Variant;
begin
  Sheet := XLApp.Workbooks[1].WorkSheets['Delphi Data'];
  for i := 1 to 10 do
    Sheet.Cells[i, 1] := i;

  Sheet.Cells[i, 1] := '=Sum(A1:A10)';
end;

procedure TForm1.HandleRange;
var
  Range: Variant;
begin
  Range := XLApp.Workbooks[1].WorkSheets['Delphi Data'].Range['C1:F25'];

  Range.Formula := '=RAND()';
  Range.Columns.Interior.ColorIndex := 3;
  Range.Borders.LineStyle := xlContinuous;
end;

procedure TForm1.ChangeColumns;
var
  ColumnRange: Variant;
begin
  ColumnRange := XLApp.Workbooks[1].WorkSheets['Delphi Data'].Columns;
  ColumnRange.Columns[1].ColumnWidth := 5;
  ColumnRange.Columns.Item[1].Font.Bold := True;
  ColumnRange.Columns[1].Font.Color := clBlue;
	ColumnRange.Columns[1].NumberFormat := '0.00';
end;

end.
