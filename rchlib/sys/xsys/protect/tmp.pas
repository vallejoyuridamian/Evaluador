program absdskxp;
uses
	absdsk;

var
	DInf: T_DskInfo;
	Buffer:array[0..511] of byte;
	sector:word;
	res:byte;
	k:integer;

begin

	res:= AbsoluteDiskwRITE(
						A,
						Buffer,
						1{Leer un sector},
						0{sector a leer});
	writeln(res);
	readln;
end.

