program deltabyt;

uses
	Objects, dos, horrores;

var
	fin, fout: TBufStream;
	dant, dact, delta: byte;
	xdact: integer;
	long, k: LongInt;


procedure help;
begin
	writeln(' AtledByt ::> (c) rch93  ');
	writeln(' Sint xis: ');
	writeln(' atledbyt entrada salida ');
	writeln(' Se produce el archivo "salida" con la decodificaci¢n delta de');
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
		fin.read(delta,1);
		xdact:= dant + delta;
		if xdact > 256 then
			xdact:= xdact - 256;
		dact := lo(xdact);
		dant:= dact;
		fout.write( dact,1);
	end;
	fout.done;
	fin.done;
end.

