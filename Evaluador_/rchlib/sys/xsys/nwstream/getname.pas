{$M 8192,0,0}
program GetName;
uses Dos;

const
	PNStr = 'You are logged in as ';
var
	r:string;

var
	Command: string[79];
	nombre:string;

begin
	Command := '/C ' + 'c:\nfs\net name>getname.tmp';

	SwapVectors;
	Exec(GetEnv('COMSPEC'), Command);
	SwapVectors;
	if DosError <> 0 then
		WriteLn('Could not execute COMMAND.COM');

	assign(input,'getname.tmp');

	reset(input);

	while not eof(input) do
	begin
		readln(input,r);
		if pos(PNStr,r) = 1 then
		begin
			delete(r,1,Length(PNStr));
			nombre:=copy(r,1,pos(',',r)-1);
		end;
	end;
	close(input);


	assign(output,'getname.tmp');
	rewrite(output);
	writeln(nombre);
	close(output);
end.

