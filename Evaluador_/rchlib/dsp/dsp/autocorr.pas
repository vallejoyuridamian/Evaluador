program autocorr;
uses
	CRT,AUTOCO, xMatDefs;

type
	LVR1Ptr= ^LVR1;
	LVR1 = array[1..6000] of NReal;

var
	NData:word;
	datos:LVR1Ptr; { NData }
	ac,bc:LVR1Ptr;   { NData div 2 }
	a0:NReal;

var
	fin,fout:file;

procedure WriteHelp;
begin
	ClrScr;
	writeln('Autocorr ..............................rch92');
	writeln('sint xis: ');
	writeln('       Autocorr archivoEntrada archivoSalida ');
	writeln;
	writeln('archivoEntrada y archivoSalida son archivos de n£meros reales');
	writeln;
	writeln('El n£mero de muestras es el del archivo de entrada,');
	writeln(' en el archivo de salida se escriben los valores corr-');
	writeln(' spondientes a la se¤al de entrada con sigo misma.');
	halt(1)
end;


begin
	assign(Input,'');reset(Input);
	assign(Output,'');rewrite(Output);
	if ParamCount <> 2 then WriteHelp;

	assign(fin,ParamStr(1));
	{$I-}
	reset(fin,SizeOf(NReal));
	{$I+}
	if IOResult <> 0 then
	begin
		writeln('ERROR: no puedo abrir archivo de entrada');
		halt(1)
	end;
	NData:=FileSize(fin);

	GetMem(datos, NData*SizeOf(NReal));
	blockRead(fin,datos^,NData);
	close(fin);

	Autocorrelacion(NData, datos^, false);

	assign(fout,ParamStr(2));
	rewrite(fout,SizeOf(NReal));

	BlockWrite(fout,datos^,NData);
	Close(fout);

	FreeMem(datos, NData*SizeOf(NReal));
end.