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
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    XLApplication: Variant;
  public
  end;

var
  Form1: TForm1;

implementation

uses
  ComObj;
  
{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
const
{ XlSheetType }
  xlChart = -4109;
  xlDialogSheet = -4116;
  xlExcel4IntlMacroSheet = 4;
  xlExcel4MacroSheet = 3;
  xlWorksheet = -4167;

{ XlWBATemplate }
  xlWBATChart = -4109;
  xlWBATExcel4IntlMacroSheet = 4;
  xlWBATExcel4MacroSheet = 3;
  xlWBATWorksheet = -4167;
var
  i, j: Integer;
  Sheets: Variant;
begin
  XLApplication := CreateOleObject('Excel.Application');
  XLApplication.Visible := True;
  XLApplication.Workbooks.Add;
  XLApplication.Workbooks.Add(xlWBatChart);
  XLApplication.Workbooks.Add(xlWBatWorkSheet);
  XLApplication.Workbooks[2].Sheets.Add(,,1,xlChart);
  XLApplication.Workbooks[3].Sheets.Add(,,1,xlWorkSheet);
  for i := 1 to XLApplication.Workbooks.Count do begin
    ListBox1.Items.Add('Workbook: ' + XLApplication.Workbooks[i].Name);
    for j := 1 to XLApplication.Workbooks[i].Sheets.Count do
      ListBox1.Items.Add('  Sheet: ' + XLApplication.Workbooks[i].Sheets[j].Name);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if not VarIsEmpty(XLApplication) then begin
    XLApplication.DisplayAlerts := False;  // Discard unsaved files....
    XLApplication.Quit;
  end;
end;

end.
