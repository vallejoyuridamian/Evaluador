program esquema;

{$MODE Delphi}

uses
  Forms, Interfaces,
  ufesquema in 'ufesquema.pas' {Form1},
  upoligonal in 'upoligonal.pas',
  urectangle in 'urectangle.pas',
  ucampos in 'ucampos.pas',
  ufEditorCampo in 'ufEditorCampo.pas' {Form2},
  utog2d in 'utog2d.pas',
  uTOGPropsForm in 'uTOGPropsForm.pas' {TOGPropForm},
  uesquema in 'uesquema.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TTOGPropForm, TOGPropForm);
  Application.Run;
end.
