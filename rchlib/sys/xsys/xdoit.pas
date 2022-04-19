{$M 5000,0,0}
program xdoit;
uses
	Dos;


var
	r:string;
	f,g:text;
	LineCount:integer;

function rc( Command:string):integer;
begin
	writeln('------------------------------------');
	writeln(' Procesando Linea N§: ',LineCount);
	writeln(' Command: ',Command);
	Command := '/C ' + Command;
	SwapVectors;
	Exec(GetEnv('COMSPEC'), Command);
	SwapVectors;
	rc:= DosError;
	if DosError = 0 then writeln(' Resultado: OK')
	else writeln(' Resultado: ERROR(',DosError,')');
end;

begin
	LineCount:=0;
	assign(f,ParamStr(1));
	assign(g,'xdoit.tmp');
	reset(f);
	rewrite(g);
	while Not EOF(f) do
	begin
		readln(f,r);
		inc(LineCount);
		if (length(r)>2)and(r[1] = '.') then
				if rc(copy(r,2,length(r))) = 0 then
					r[1]:='*'; { Lo marco como hecho }
		writeln(g,r);
	end;
	close(g);
	erase(f);
	rename(g,ParamStr(1));
end.


