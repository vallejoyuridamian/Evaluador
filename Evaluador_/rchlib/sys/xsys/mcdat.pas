{29/11/1991,rch}
{$M 5000,0,2000}

{ Preparado para mantener los datos de adquisiciones de AUTONOMA }

program movren;
uses Dos,CRT;

procedure triangulito;
begin
	writeln('====================================================');
	writeln('rch92');
	writeln('.......');
	writeln('...............');
	Writeln('..........................');
	writeln('........ MCDat .................');
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
	writeln(' El nuevo archivo es copiado tambien en el lugar indicado');
	writeln(' por el par metro 2 ');
	writeln;
	writeln('Sintaxis:');
	writeln('    MCDat path\nombre.ext [pathDondeHacerCopia] ');
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
	 Command: string[79];

begin
	assign(input,'');
	reset(input);
	assign(output,'');
	rewrite(output);

	if paramCount< 1 then ayuda;
	if paramCount> 2 then ayuda;
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

  Command := 'xcopy '+np;
  if ParamCount = 2 then Command:=Command+' '+ParamStr(2);
  Command := '/C ' + Command;
  SwapVectors;
  Exec(GetEnv('COMSPEC'), Command);
  SwapVectors;
  if DosError <> 0 then
	 WriteLn('No pude cargar archivo COMMAND.COM')
  else writeln('Todo OK');
end.





