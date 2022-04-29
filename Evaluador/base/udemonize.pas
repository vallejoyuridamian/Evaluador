unit udemonize;

{$mode delphi}

interface

uses
  Classes, SysUtils;

procedure Demonize;

// Crea un proceso Hijo con la aplicación.
procedure DoProcesoHijo(apl: ansistring; params: array of string);

// Ejecuta una aplicación como un demonio independiente
function RunAsDaemon(apl: string; params: array of string): boolean;


implementation

procedure Demonize;
begin
  Close(input);  { close standard in }
  Close(output); { close standard out }
  Assign(output, '/dev/null');
  ReWrite(output);
  Close(stderr); { close standard error }
  Assign(stderr, '/dev/null');
  ReWrite(stderr);
end;


  procedure DoProcesoHijo(apl: ansistring; params: array of string);
  var
    i, error: integer;
    paramsPChar, iter: PPChar;
  begin
    // OJO!!! no se que pasa que a la aplicación destino no le llegan los parámetros
    writeln('DoProcesoHijo, Apl: ', Apl);
    for i := 0 to high(params) do
      writeln('i: ', i, ' val: ', params[i]);

    Apl := Apl + #0;
    GetMem(paramsPChar, (length(params) + 2) * SizeOf(PChar));
    iter := paramsPChar;
    iter^ := @(Apl[1]);
    Inc(iter);
    for i := 0 to High(params) do
    begin
      params[i] := params[i] + #0;
      iter^ := @(params[i][1]);
      Inc(iter);
    end;
    iter^ := nil;
    fpexecv(Apl, paramsPChar);

    //si vuelvo de fpexecv hubo error
    error := fpgeterrno;
    writeln('DoProcesoHijo: error= ', error);

    //  writeln(' *********** ERROR:::: el resultado de exec fue: ', res );

    freemem(paramsPChar, (length(params) + 2) * SizeOf(PChar));
    fpexit(0); // halt;
  end;


  function RunAsDaemon(apl: string; params: array of string): boolean;
  var
    pid: integer;
    status: integer;
    aplx: ansistring;
  begin
    // init child process
    pid := fpfork();
    Result := pid >= 0;
    if pid = -1 then
      exit;

    if pid = 0 then
    begin
      // in child process - init grandchild
      aplx := apl;
      Close(input);  { close standard in }
      Close(output); { close standard out }
      Assign(output, '/dev/null');
      ReWrite(output);
      Close(stderr); { close standard error }
      Assign(stderr, '/dev/null');
      ReWrite(stderr);
      doProcesoHijo(aplx, params);
    end
    else
      // in parent process - use waitpit to query for child process
      writeln('jeje');
  end;

end.

