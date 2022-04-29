program testgaussiana;

uses
  Forms,
  utestgaussiana in 'utestgaussiana.pas' {Form1},
  fddp in '..\..\fddp.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
