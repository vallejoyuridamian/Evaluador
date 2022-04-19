unit uflu40;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,

   uprincipal,
  ExtDlgs;



type
  TForm1 = class(TForm)
    Button1: TButton;
    OpenTextFileDialog1: TOpenTextFileDialog;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;


implementation
{$R *.dfm}


procedure TForm1.Button1Click(Sender: TObject);
begin
  if ( OpenTextFileDialog1.Execute ) then
    Principal( OpenTextFileDialog1.FileName );
end;
end.
