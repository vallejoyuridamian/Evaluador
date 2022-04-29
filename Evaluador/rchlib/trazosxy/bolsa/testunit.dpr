program testunit;

uses
  Forms,
  utestunit in 'utestunit.pas' {Form1},
  DllForm in 'DllForm.pas' {frmDllForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmDllForm, frmDllForm);
  Application.Run;
end.
