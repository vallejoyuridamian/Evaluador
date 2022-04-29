program fft_B;
uses
	CRT,RFFTB01,RFFTI01, xMatDefs;

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
	writeln('fft_f ..............................rch92');
	writeln('sint xis: ');
	writeln('       fft_b archivoEntrada archivoSalida ');
	writeln;
	writeln('archivoEntrada y archivoSalida son archivos de n£meros reales');
	writeln;
	writeln('En el archivo de entrada deben eswtan los coeficientes ');
	writeln(' de la serie de fourier de la se¤al a invertir en el siguiente');
	writeln(' orden: ');
	writeln(' a0, a1..a(n ), b1.. b(n) ');
	writeln(' el archivo de salida tendra 2 * n n£meros reales ');
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
	NData:=FileSize(fin) -1;
	GetMem(ac, (NData div 2) * SizeOf(NReal));
	GetMem(bc, (NData div 2) * SIzeOf(NReal));
	blockRead(fin,a0,1);
	blockRead(fin, ac^, NData div 2);
	blockRead( fin, bc^, NData div 2);
	close(fin);


	GetMem(datos, NData*SizeOf(NReal));

	RFFTI01.Init(NData);
	FFTB(datos^,a0,ac^,bc^);

	assign(fout,ParamStr(2));
	rewrite(fout,SizeOf(NReal));
	BlockWrite(fout,Datos^,NData);
	Close(fout);
	FreeMem(bc, (NData div 2) * SIzeOf(NReal));
	FreeMem(ac, (NData div 2) * SizeOf(NReal));
	FreeMem(datos, NData*SizeOf(NReal));

	RFFTI01.done;
end.