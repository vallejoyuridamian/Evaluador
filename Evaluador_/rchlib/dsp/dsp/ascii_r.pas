program ascii_r;
uses
	{$I xCRT};

var
	fin:text;
	fout:file of real;
	m:real;

begin
	if ParamCount<> 2 then
	begin
		ClrScr;
		writeln('ASCII_R............................rch92');
		writeln;
		writeln(' Sintaxis:');
		writeln;
		writeln(' ascii_r ArchivoFuente ArchivoDestino');
		writeln;
		writeln(' Donde (ArchivoFuente) es un archivo de texto del cual,');
		writeln(' se lee un numero real de cada linea y se lo escribe en');
		writeln(' el archivo destino que es un archivo de numero reales,');
		writeln(' de 6 bytes, (PASCAL) ');
		halt(1);
	end;
	assign(fin,ParamStr(1));
	{$I-}
	reset(fin);
	{$I+}
	if IOREsult <>0 then
	begin
		writeln;
		writeln('ASCII_R......>ERROR:');
		writeln(' No puedo abrir el archivo: ',ParamStr(1));
		halt(1);
	end;
	assign(fout,ParamStr(2));
	rewrite(fout);
	while Not Eof(fin) do
	begin
		readln(fin,m);
		write(fout,m);
	end;
	close(fout);
	close(fin);
end.