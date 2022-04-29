unit uTestSorteos;

interface

uses
  ucmdoptsim;

const
  cantidadesDeSorteos : Array [0..24] of integer =(1, 2, 3, 4, 5, 8, 10, 15, 20,
                                                   25, 30, 35, 40, 45, 50, 55,
                                                   60, 65, 70, 75, 80, 85, 90,
                                                   95, 100);

  semillas : Array [0..9] of integer = (31, 41, 51, 61, 71, 81, 91 , 101, 111, 121);

//Realiza una optimizacion con cada cantidad de sorteos en cantidadesDeSorteos
procedure testCantidadesDeSorteos;

procedure testSemillas;

implementation

procedure testCantidadesDeSorteos;
var
  i: Integer;
begin
  for i:= low(cantidadesDeSorteos) to High(cantidadesDeSorteos) do
  begin
    Writeln(cantidadesDeSorteos[i], ' sorteos');
    ucmdoptsim.RunOptimizar(31, cantiDadesDeSorteos[i]);
  end;
end;

procedure testSemillas;
var
  i: Integer;
begin
  for i:= low(semillas) to High(semillas) do
  begin
    Writeln('Semilla = ', semillas[i]);
    ucmdoptsim.RunOptimizar(semillas[i], 10);
  end;
end;

end.
