{rch92}
program r_ascii;
uses
	xMatDefs;

var
	Campo, Racionales: integer;
	fin: file of NReal;
	fout: text;
	m:NReal;
	res:integer;


procedure OutHelp;
begin
	writeln(' r_ascii..........................rch92');
	writeln;
	writeln(' Sint xis:');
	writeln(' r_ascii ArchivoFuente  ArchivoDestino [Campo Racionales] ');
	writeln;
	writeln(' donde (ArchivoFuente) es  un archivo de n£meros reales PASCAL ');
	writeln(' y (ArchivoDestino) es el archivo que se crear  con los mismos');
	writeln(' n£meros en ASCII, con formato (:Campo:Racionales) y uno por rengl¢n');
	halt(1);
end;


begin
	campo:=12;
	racionales:=-1;

	if (ParamCount<2)or(ParamCount>4) then OutHelp;

	assign(fin,ParamStr(1));
	{$I-}
	reset(fin);
	{$I+}
	if ioresult <> 0 then
	begin
		writeln;
		writeln('R_ASCII.................>ERROR:');
		writeln(' No puedo abrir el archivo: ',ParamStr(1));
		halt(1)
	end;
	assign(fout,ParamStr(2));
	rewrite(fout);

	res:=0;
	if ParamCount>2 then val(ParamStr(3),Campo,res);
	if res <> 0 then
	begin
		writeln;
		writeln('R_ASCII.......>ERROR:');
		writeln(' No me es posible interpretar: ,',paramStr(3),',');
		writeln(' como un n£mero entero para CAMPO');
		halt(1);
	end;

	res:=0;
	if ParamCount>3 then val(ParamStr(4),Racionales,res);
	if res <> 0 then
	begin
		writeln;
		writeln('R_ASCII.......>ERROR:');
		writeln(' No me es posible interpretar: ,',paramStr(4),',');
		writeln(' como un n£mero entero para RACIONALES');
		halt(1);
	end;

	while not eof(fin) do
	begin
		read(fin,m);
		writeln(fout,m:Campo:Racionales);
	end;
	close(fout);
	close(fin);
end.