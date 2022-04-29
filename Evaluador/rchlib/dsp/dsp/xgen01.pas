program xgen01;

var
	f: file of real;
	k: longInt;
	v,w:real;

const
	Ndatos = 24 * 365;

begin
	randomize;
	assign(f, 'gen01.dat');
	rewrite(f);
	w:= 2* pi/ ( 24 );
	for k:= 1 to Ndatos do
	begin
		v:= 50 + 6* sin( w* k) + 30 * random + k/36;
		write(f,v);
	end;

	close(f);
end.