program test_unit;

{$MODE Delphi}

uses
  Forms, Interfaces,
  utest_unit in 'utest_unit.pas' {Form1},
  utrazosxy in 'utrazosxy.pas' {frmDllForm};

{.$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
