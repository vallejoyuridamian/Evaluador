{$M 1024,0,1024}
program xexec;
uses
	dos,CRT;
var
	r:string;
	f:text;

begin
	if ParamCount<>2 then
	begin
		writeln('====================================================');
		writeln('rch91');
		writeln('.......');
		writeln('...............');
		Writeln('..........................');
		writeln('........ XEXEC .................');
		writeln;
      writeln('-----------------------');
		writeln('Sintaxis:');
		writeln('xexec comando archivo.ext');
		writeln('--------------------------');
		writeln('  El comando ser  llamado, pas ndole como par metro');
		writeln('cada una de las l¡neas del archivo par metro.');
		writeln('  Antes de ser pasadas las l¡neas, son procesadas de');
		writeln('manera tal que se les quita el primer caracter mientras');
		writeln('queda alg£n blanco en la l¡nea.');
		halt(1)
	end;
	assign(f,ParamStr(2));
	{$I-}
	reset(f);
	{$I+}
	if ioresult <> 0 then
	begin
		writeln('xexec> No encuentro el archivo: ',ParamStr(1));
		halt(1)
	end;
	while not eof(f) do
	begin
		readln(f,r);
		while pos(' ',r)<>0 do delete(r,1,pos(' ',r));
		SwapVectors;
		Exec('\command.com','/C' +ParamStr(1)+' '+r);
		SwapVectors;
		if DOSError<> 0 then
			writeln('error, ',DosError,'  ',r,' no fue procesado');

	end;
end.

