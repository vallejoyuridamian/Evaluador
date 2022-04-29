program trs232;
uses
	xrs232, crt;

var
	res: integer;
	c: char;
	res0, res1: byte;
	ts: string;

function bs( x: boolean): string;
begin
	if x then bs:='1'
	else bs:='0';
end;
var
	f: text;

begin
	ClrScr;
	assign( f, 'trs232.pas');
	system.reset(f);

	RandSeed:=31;

	Install( 9600, modo1, hilos1, 400, 400 );
	reset;

	while not eof(f) do
	begin
		read(f, c);
		repeat
			res:=PutChar(c);
			if res <> 0 then write('/',res);
		until res >=0;
	end;
	close(f);

	while true do
	begin

		if keypressed then
		repeat
			c:= readkey;
			repeat
			until	PutChar(c)>=0;
		until not KeyPressed;

		repeat
			res:= GetChar(C);
			if res =0 then write(C);
		until res <0;
	end;
end.

