program evaluador;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  uevaluadormatches;

const
  metodo = 1;
begin
  evaluar(metodo);
end.
