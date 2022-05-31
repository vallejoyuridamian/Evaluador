program numserxp;

uses
	NumSer, CRT, AbsDsk, Int2Hexa;
var
	xns:LongInt;

begin
	ClrScr;
	writeln( LongInt2HexaStr(Get_NS(A)));
	while true do
	begin
		write(' NS: ');readln(xns);
		if Check_NS(A,xns) then  writeln('Correcto')
		else writeln('P?NTVAC');
	end;
end.
