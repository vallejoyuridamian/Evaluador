program fft;
uses
	{$I xCRT},
	RFFTF01,RFFTI01, xMatDefs;

type
	LVR1Ptr= ^LVR1;
	LVR1 = array[1..10922] of real;

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
	writeln('fft_f ..............................rch92');
	writeln('sint�xis: ');
	writeln('       fft_f archivoEntrada archivoSalida ');
	writeln;
	writeln('archivoEntrada y archivoSalida son archivos de n�meros reales');
	writeln;
	writeln('El n�mero de muestras es el del archivo de entrada,');
	writeln(' en el archivo de salida se escriben los coeficientes');
	writeln(' de la serie de senos y cosenos de Fourier correspondiente');
	writeln(' a una se�al periodica siendo un per�odo de la misma las ');
	writeln(' muestras del archivo de entrada.');
	writeln('  Los coeficientes se escriben en el siguiente orden: ');
	writeln(' a0, a1..a(ndata div 2), b1.. b(ndata div 2) ');
	writeln;
	writeln(' Si dispone de los datos en formato ASCII, use ASCII->R y');
	writeln(' R->ASCII para convertir los datos');
	halt(1)
end;


begin
{
	assign(Input,'');reset(Input);
	assign(Output,'');rewrite(Output);
	}
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
	GetMem(ac, (NData div 2) * SizeOf(NReal));
	GetMem(bc, (NData div 2) * SIzeOf(NReal));

	RFFTI01.Init(NData);
	FFTF(datos^,a0,ac^,bc^);

	assign(fout,ParamStr(2));
	rewrite(fout,SizeOf(NReal));
	BlockWrite(fout,a0,1);
	BlockWrite(fout,ac^,NData div 2);
	BlockWrite(fout,bc^,NData div 2);
	Close(fout);
	FreeMem(bc, (NData div 2) * SIzeOf(NReal));
	FreeMem(ac, (NData div 2) * SizeOf(NReal));
	FreeMem(datos, NData*SizeOf(NReal));

	RFFTI01.done;
end.