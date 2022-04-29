program deltabyt;

uses
	Objects, Horrores;


var
	fin, fout: TBufStream;
	dant, dact: byte;
	delta: integer;
	long, k: LongInt;


procedure help;
begin
	writeln(' DeltaByt ::> (c) rch93  ');
	writeln(' Sint xis: ');
	writeln(' deltabyt entrada salida ');
	writeln(' Se produce el archivo "salida" con la codificaci¢n delta de');
	writeln(' los bytes del archivo "entrada" ');
	halt(1);
end;

begin
	if paramCOunt<> 2 then help;

	fin.Init(ParamStr(1), stOpenRead, 40*1024);
	if fin.status <> stOk then error(' abriendo archivo: '+ParamStr(1));
	fout.Init(ParamStr(2), stOpenWrite, 40*1024);
	if fout.status <> stOk then error(' abriendo archivo: '+ParamStr(2));
	long:= fin.GetSize;

	fin.read(dant, 1);
	fout.write(dant, 1);

	for k:= 1 to long-1 do
	begin
		fin.read(dact, 1);
		delta:= dact - dant;
		dant:= dact;
		if delta < 0 then
			delta:= delta + 256;
		dact:= lo(delta);
		fout.write(dact, 1);
	end;
	fout.done;
	fin.done;
end.

