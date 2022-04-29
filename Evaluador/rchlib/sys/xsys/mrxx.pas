{$M 1024,0,1024}
program mrxx;
uses
	dos;
var
	r:string;
	f:text;

begin
	if ParamCount<>1 then
	begin
		writeln('mrxx> Lea el archivo mrxx.doc');
		halt(1)
	end;
	assign(f,ParamStr(1));
	{$I-}
	reset(f);
	{$I+}
	if ioresult <> 0 then
	begin
		writeln('mrxx> No encuentro el archivo: ',ParamStr(1));
		halt(1)
	end;
	while not eof(f) do
	begin
		readln(f,r);
		while pos(' ',r)<>0 do delete(r,1,pos(' ',r));
		SwapVectors;
		Exec('\command.com','/C MovRen '+r);
		SwapVectors;
		if DOSError<> 0 then writeln('error, ',r,' no fue procesado');
	end;
end.

