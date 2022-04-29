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
  public
    V: Variant;
  end;

var
  Form1: TForm1;

implementation

uses
  ComObj;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  V := CreateOleObject('Excel.Application');
  V.Visible := True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if not VarIsEmpty(V) then
    V.Quit;
end;

end.
