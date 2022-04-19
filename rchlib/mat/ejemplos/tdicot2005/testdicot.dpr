program testdicot;

uses
  Forms,
  utestdicot in 'utestdicot.pas' {Form1},
  xMatDefs in '..\..\Xmatdefs.pas',
  Matreal in '..\..\Matreal.pas',
  math01 in '..\..\MATH01.PAS',
  ComPol in '..\..\COMPOL.PAS';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
