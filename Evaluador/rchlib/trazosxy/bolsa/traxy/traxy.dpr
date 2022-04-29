program traxy;

uses
  Forms,
  utraxy in 'utraxy.pas' {Form1},
  upropiedades in 'upropiedades.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
