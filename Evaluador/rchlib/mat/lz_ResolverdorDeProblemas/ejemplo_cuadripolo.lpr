program ejemplo_cuadripolo;

{$MODE Delphi}

uses
  Forms, Interfaces,
  uejemplo_cuadripolo in 'uejemplo_cuadripolo.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
