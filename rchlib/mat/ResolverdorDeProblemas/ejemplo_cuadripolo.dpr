program ejemplo_cuadripolo;

uses
  Forms,
  uejemplo_cuadripolo in 'uejemplo_cuadripolo.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
