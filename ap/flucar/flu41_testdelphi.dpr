program flu41_testdelphi;

uses
  Forms,
  uflu41_testdelphi in 'uflu41_testdelphi.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
