program esquema;

uses
  Forms,
  ufesquema in 'ufesquema.pas' {Form1},
  upoligonal in 'upoligonal.pas',
  urectangle in 'urectangle.pas',
  ucampos in 'ucampos.pas',
  ufEditorCampo in 'ufEditorCampo.pas' {Form2},
  utog2d in 'utog2d.pas',
  uTOGPropsForm in 'uTOGPropsForm.pas' {TOGPropForm},
  uesquema in 'uesquema.pas',
  IntPoint in 'C:\simsee\SimSEE_src\src\rchlib\mat\IntPoint.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TTOGPropForm, TOGPropForm);
  Application.Run;
end.
