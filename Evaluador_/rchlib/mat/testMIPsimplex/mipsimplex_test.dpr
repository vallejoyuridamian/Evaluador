program mipsimplex_test;

uses
  Forms,
  umipsimplex_test in 'umipsimplex_test.pas' {Form1},
  umipsimplex in 'umipsimplex.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
