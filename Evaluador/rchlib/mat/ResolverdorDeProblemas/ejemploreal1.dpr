program ejemploreal1;

uses
  Forms,
  uejemploreal1 in 'uejemploreal1.pas' {Form1},
  uresolvecuacs in '..\uresolvecuacs.pas',
  xmatdefs in '..\xmatdefs.pas',
  matReal in '..\matReal.pas',
  compol in '..\compol.pas',
  fddp in '..\fddp.pas',
  math01 in '..\math01.pas',
  math02 in '..\math02.pas',
  udisnormcan in '..\udisnormcan.pas',
  ucpxresolvecuacs in '..\ucpxresolvecuacs.pas',
  Matcpx in '..\Matcpx.pas',
  Algebrac in '..\Algebrac.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
