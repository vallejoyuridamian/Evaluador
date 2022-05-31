program xpfftf;

{
prueba de xpfftf
}

const
	NP = 6000;
var
	f:file of real;
	k:integer;
	w,m:real;

begin
	assign(f,'xfreal.dat');
	w:=2*pi/NP;
	rewrite(f);
	for k:=1 to NP do
	begin
		m:=sin(w*k);
		if m> 0 then m:=1
		else m:= -1;
		write(f,m);
	end;
	close(f);
end.