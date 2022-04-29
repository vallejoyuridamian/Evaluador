program sumtot;


type

	tvr = array[1..10922] of real;
	tpvr = ^tvr;


var
	pp: tpvr;

	N:word;
	Suma:real;
	fin, fout:file;
	k:word;

procedure OutHelp;

begin
	writeln;
	writeln('SumTot..............................rch92');
	writeln(' sintaxis: SumTot Fuente [Destino] ');
	writeln;
	writeln(' Fuente y Destino son archivos de Reales PASCAL');
	writeln('  SumTot, realiza la suma de todos los reales del ');
	writeln(' archivo fuente y guarda el resultado en el archivo ');
	writeln(' destino.  En caso de omitirse el Destino, el resultado');
	writeln(' es enviado a la consola. En caso de especificar un Destino');
	writeln(' el resultado es escrito en el mismo como un n£mero real');
	writeln(' , cuando el resultado se env¡a a la consola, est  en formato');
	writeln(' ASCII.');
	writeln;
	halt(1);
end;

procedure Error( x:string);
begin
	writeln;
	writeln('SumTot.......>ERROR: ');
	writeln;
	writeln(x);
	halt(1)
end;

begin
	if (ParamCount< 1)or (ParamCOunt>2) then OutHelp;
	assign(fin, ParamStr(1));
	{$I-}
	reset(fin,SizeOf(Real));
	{$I+}

	if IOResult <> 0 then
		error(' No puedo abrir el archivo: '+ParamStr(1));

	N:=FileSize(fin);

	GetMem(pp,N*SizeOf(Real));
	BlockRead(fin,pp^,N);
	close(fin);
	Suma:=0;
	for k:= 1 to N do
		Suma:=Suma+pp^[k];
	if ParamCount = 2 then
	begin
		assign(fout,ParamStr(2));
		rewrite(fout, SizeOf(real));
		BlockWrite(fout,Suma,1);
		close(fout)
	end
	else
	begin
		assign(output,'');
		rewrite(output);
		writeln(Suma);
		close(output);
	end;

	FreeMem(pp,N*SizeOf(Real));
end.