program VozView;

uses
  Forms,
  uVozView in 'uVozView.pas' {Form1},
  WavIO in '..\..\..\vasen\0900\v54\utilidades\wavox\Wavio.pas',
  ufiltrosf in '..\..\..\vasen\0900\v54\utilidades\wavox\ufiltrosf.pas',
  WRFFTI01 in '..\mat\Wrffti01.pas',
  WRFFTF01 in '..\mat\Wrfftf01.pas',
  xMatDefs in '..\mat\Xmatdefs.pas',
  wRfftb01 in '..\mat\wRfftb01.pas',
  AutoCo in '..\mat\autoco.pas',
  Horrores in 'Horrores.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
