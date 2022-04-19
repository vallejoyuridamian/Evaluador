program dprtest_u_ExcelFile;

uses
  Forms,
  test_u_ExcelFile in 'test_u_ExcelFile.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
