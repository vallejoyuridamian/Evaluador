program esquema;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uesquema, LResources
  { you can add units after this };

{$IFDEF WINDOWS}{$R esquema.rc}{$ENDIF}

begin
  {$I esquema.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

