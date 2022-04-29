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
	k, j:integer;
	x: NReal;
	re, min_re, max_re: NReal;
	fsal: text;

begin
	min_re:= 1;
	max_re:= -1;

	assign( fsal, 'cepsx.xlt');
	rewrite(fsal);
	for k:= 0 to 1 do
	begin
		write(k:12);
		x:= exp(-k/10);
		re:=Calcular_EPSILONx(x);
		if re < min_re then min_re:= re
		else if re > max_re then max_re:= re;
		for j:= 1 to 12 do write(#8);
		writeln( fsal, x,#9, re );
	end;
	close(fsal);
	writeln( min_re, max_re );
	writeln( AsumaCero );
	readln;
end.