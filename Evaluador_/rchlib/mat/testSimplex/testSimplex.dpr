program testSimplex;

uses
  Forms,
  uTestSimplex in 'uTestSimplex.pas' {Form1},
  uExcelFile in 'uExcelFile.pas',
  XLConst in 'XLConst.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
