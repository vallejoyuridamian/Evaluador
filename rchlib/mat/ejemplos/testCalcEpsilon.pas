program test;

uses
	xMatDefs;

function Calcular_EPSILONx( x:NReal):NReal;
{  Esta funcion calcula el EPSILONx (o toleracia de punto flotante)
  de la maquina. EPSILONx es el menor real positivo tal que
	x + EPSILONx > x.}
var
  e,e0: NReal;
  i: integer;
begin
  e0 := 1; i:=0;
  repeat
	 e0 := e0/2; e := x+e0;  i := i+1;
  until (e=x) or (i=500000);
  e0 := e0*2;
  Calcular_EPSILONx:=e0;
end;

var
	k:integer;
	x: NReal;

begin
	for k:= 1 to 100 do
	begin
		x:= 1/k;
		writeln('x: ',x:12,' EPSILONx: ', Calcular_EPSILONx(x)/x:12);
	end;
	readln;
end.