program xchns;
uses
	CRT, NUMSER, AbsDsk, Int2Hexa;
var
	New_NS: string;
	NNS: LongInt;

begin
	ClrScr;
	writeln(' N£mero de serie del disco      (A): ',LongInt2HexaStr(Get_NS(A)));
	write(  ' Cambiar N§  de serie del disco (A): ');readln(New_NS);
	NNS:= HexaStr2LongInt( New_NS );
	Change_NS(A, NNS);
	writeln(' N£mero de serie del dsico      (A): ',LongInt2HexaStr(Get_NS(A)));
end.
