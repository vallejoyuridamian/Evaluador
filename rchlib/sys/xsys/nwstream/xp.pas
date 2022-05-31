{$M 10000,0,3000}
program xp;
uses
	Dos,ShareDos,Objects;

procedure RunChild( command:string);
begin
  if Command <> '' then
    Command := '/C ' + Command;
  SwapVectors;
  Exec(GetEnv('COMSPEC'), Command);
  SwapVectors;
  if DosError <> 0 then
    WriteLn('Could not execute COMMAND.COM');
end;

var
	f,g:TDosStream;
	ps,qs:PString;
begin
	getMem(ps,100);
	ps^:='Hola que tal';
	f.Init('toto.tmp', stOpen +Share_DenyWrite);
	writeln(f.errorInfo);
	f. writestr(ps);
	writeln(ps^);
	f.Seek(0);
	qs:=f.readstr ;
	writeln(qs^);

	g.Init('toto.tmp', stOpenRead);
	IF g.errorInfo<>0 THEN RunError(g.ErrorInfo);
	g.Seek(0);
	qs:=g.readstr ;
	writeln(qs^);


	f.done;
	g.done;
end.