program evaluador;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, uevaluadormatches;

begin
  evaluar;
end.
{
TODO:
Terminar el constructor de TMinuto
Hay que ver como manejar el tema del entretiempo y los descuentos.
Al final de todo el TPartido tiene que tener un array de 90 TMinutos y una
forma de validar si es viable o no.
}
