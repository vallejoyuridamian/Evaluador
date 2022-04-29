program flu40;

uses
  Forms,
  uflu40 in 'uflu40.pas' {Form1},
  uTCompFC in 'uTCompFC.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
