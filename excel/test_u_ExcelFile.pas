unit test_u_ExcelFile;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, u_ExcelFile, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    f: T_ExcelFile;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.Button1Click(Sender: TObject);
var
   inter: variant;
   s: variant;
begin
  f:= T_ExcelFile.Create('h1', true, true, true );
  inter:= f.v.International[ 3 ];
  f.Write('1.1');
end;

end.
