program test_dll;

uses
  Forms,
  utest_dll in 'utest_dll.pas' {Form1},
  uimptraxpdll in 'uimptraxpdll.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
