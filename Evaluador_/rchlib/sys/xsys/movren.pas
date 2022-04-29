{29/11/1991,rch}
program movren;
uses Dos,CRT;

procedure triangulito;
begin
	writeln('====================================================');
	writeln('rch91');
	writeln('.......');
	writeln('...............');
	Writeln('..........................');
	writeln('........ MOVREN .................');
	writeln;
end;

procedure Ayuda;
begin
	triangulito;
	writeln('Prop¢sito:');
	writeln('      Mover el archivo pasado como par metro');
	writeln('al directorio actual. Si y  existe en el directorio');
	writeln('actual un archivo con igual nobre, renombrar  el');
	writeln('archivo a mover con la extenci¢n .001, si y  existe');
	writeln('un archivo con el nuevo nombre incrementa en 1  la ');
	writeln('nueva extensi¢n y as¡ hasta encontrar un nombre libre');
	writeln;
	writeln('Sintaxis:');
	writeln('    MovRen path\nombre.ext  ');
	writeln;
	writeln('====================================================');
	writeln(' Presione ENTER para continuar');
	readln;
	halt(1)
end;

var
    P: PathStr;
    D: DirStr;
    N: NameStr;
	 E: ExtStr;
	 f: file;
	 NP:PathStr;
	 cont:integer;

begin
	assign(input,'');
	reset(input);
	assign(output,'');
	rewrite(output);

	if paramCount<> 1 then ayuda;
	P:=ParamStr(1);
	assign(f,P);
	{$I-}
	reset(f);
	{$I+}
	if IOResult<>0 then
	begin
		triangulito;
		writeln('NO ENCUENTRO EL ARCHIVO: ',P);
		writeln;
		writeln('====================================================');
		halt(1)
	end;
	close(f);
	FSplit(P,D,N,E);
	NP:=N+E;
	assign(f,NP);
	{$I-}
	reset(f);
	{$I+}
	if IOResult = 0 then
	begin
		cont:=0;
		repeat
			close(f);
			inc(cont);
			Str(cont:3,E);
			while pos(' ',E)<>0 do E[pos(' ',E)]:='0';
			NP:=N+'.'+E;
			assign(f,NP);
			{$I-}
			reset(f);
			{$I+}
		until IOResult<>0;
	end;
	assign(f,p);
	rename(f,np);
end.





