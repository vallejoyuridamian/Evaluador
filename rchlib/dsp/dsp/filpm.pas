{rch92}
program filpm;
label chau;

var
	NMuestras: integer;
	fin: file of real;
	fout: file of real;
	sm,m:real;
	res, k:integer;


procedure OutHelp;
begin
	writeln(' filpm..........................rch92');
	writeln;
	writeln(' Sint xis:');
	writeln(' filpm ArchivoFuente  ArchivoDestino NMuestras');
	writeln;
	writeln(' donde (ArchivoFuente) es  un archivo de n£meros reales PASCAL ');
	writeln(' y (ArchivoDestino) es el archivo que se crear  con los mismos');
	writeln(' elegidos de a NMuestras y promediados. El archivo de salida ');
	writeln(' tendr  DatosDeEntrada div NMuestras  valores reales');
	halt(1);
end;


begin
	if (ParamCount<>3) then OutHelp;

	assign(fin,ParamStr(1));
	{$I-}
	reset(fin);
	{$I+}
	if ioresult <> 0 then
	begin
		writeln;
		writeln('FilPM.................>ERROR:');
		writeln(' No puedo abrir el archivo: ',ParamStr(1));
		halt(1)
	end;
	assign(fout,ParamStr(2));
	rewrite(fout);

	res:=0;
	if ParamCount>2 then val(ParamStr(3),NMuestras,res);
	if res <> 0 then
	begin
		writeln;
		writeln('FilPM.......>ERROR:');
		writeln(' No me es posible interpretar: ,',paramStr(3),',');
		writeln(' como un n£mero entero para CAMPO');
		halt(1);
	end;

	res:=0;
	val(ParamStr(3),NMUestras,res);
	if res <> 0 then
	begin
		writeln;
		writeln('FilPm.......>ERROR:');
		writeln(' No me es posible interpretar: ,',paramStr(3),',');
		writeln(' como un n£mero entero');
		halt(1);
	end;

	while not eof(fin) do
	begin
		sm:=0;
		for k:= 1 to NMuestras do
		begin
			if eof(fin) then goto Chau;
			read(fin,m);
			sm:=sm+m;
		end;
		sm:=sm/NMuestras;
{		writeln(sm); }
		write(fout,sm);
	end;

chau:
	close(fout);
	close(fin);
end.