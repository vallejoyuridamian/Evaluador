unit uSimCalc;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  xmatdefs;

type

  { TFormSimCalc }

  TFormSimCalc = class(TForm)
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    { private declarations }
  public
    { public declarations }
    flg_editando: boolean;
    celda_sel_col, celda_sel_row: integer;
    celda_edit_col, celda_edit_row: integer;
  end;

var
  FormSimCalc: TFormSimCalc;

implementation

{$R *.lfm}

{ TFormSimCalc }

function evaluar( s: string ): string;
begin
  result:= '8';
end;

function ColToStr( aCol: integer ): string;
var
  resto: integer;
  s: string;

begin
  resto:= aCol-1;
  s:= '';
  repeat
    s:= s+ Char( Ord( 'A' )+( resto mod 27 ) );
    resto:= resto div 27;
  until resto = 0;

  result:= s;

end;

function celdaRef( acol, arow: integer ): string;
begin
  result:= ColToStr( aCol ) +IntToStr( arow );
end;

procedure TFormSimCalc.StringGrid1DrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  s: string;
begin
  if (gdSelected in aState) then exit;
  If (gdFixed in aState) then
  begin
    if ( aCol > 0 ) then
    begin
      s:= ColToStr( aCol );
    end
    else if aRow > 0 then
      s:= IntToSTr( aRow )
    else
      s:= '';
    StringGrid1.Canvas.TextOut(aRect.Left + 2, aRect.Top + 2, s);
    exit;
  end;

  s:=  stringgrid1.cells[aCol,aRow];
  if (length( s ) > 0) and ( s[1] in [ '=', '+' ] ) then
  begin
    s:= evaluar( s );
    stringgrid1.canvas.Brush.Color:=clRed;
    stringgrid1.canvas.FillRect(arect);
    //stringgrid1.canvas.textRect(rect,Rect.left+2,rect.top+2,'ZZZZ'{stringgrid1.cells[Col,Row]});
     StringGrid1.Canvas.TextOut(aRect.Left + 2, aRect.Top + 2, s);
  end;
end;

procedure TFormSimCalc.StringGrid1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  aCol, aRow: integer;
begin
  StringGrid1.MouseToCell( X, Y, aCol, aRow );
  celda_sel_col:= aCol;
  celda_sel_row:= aRow;
  if flg_editando then
  begin
    if (aCol <> celda_edit_col) or
    (aRow <> celda_edit_row) then
    StringGrid1.Cells[ celda_edit_col, celda_edit_row]:=
      StringGrid1.Cells[ celda_edit_col, celda_edit_row]+CeldaRef( aCol, aRow );
  end;
end;


procedure TFormSimCalc.FormCreate(Sender: TObject);
begin
  flg_editando:= false;
end;

procedure TFormSimCalc.StringGrid1DblClick(Sender: TObject);
begin
  if flg_editando then
  begin
    flg_editando:= false;
  end
  else
  begin
    flg_editando:= true;
    celda_edit_col:= celda_sel_col;
    celda_edit_row:= celda_sel_row;
  end;
end;

procedure TFormSimCalc.StringGrid1SelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
begin
  celda_sel_col:= aCol;
  celda_sel_row:= aRow;
end;



end.

