program xpgigavr;
{
PROPOSITO: Probar la posibilidad de manejar vectores de m s de 64k
	de memoria.
}

uses
	DOS, GigaVect;
var
	x,y: VectorGigante;

	a,b:real;

	NE: LongInt;
	k: LongInt;
	indice: LongInt;
	HI,MI,SI, decseg:word;


begin

	x.init(SizeOf(real));
	y.init(SizeOf(real));
	x.assign('vg_x.dat');
	y.assign('vg_y.dat');
{
	x.rewrite;
	y.rewrite;
	a:=0;
	for k:= 1 to 64*1024 do
	begin
		a:=k/10000;
		x.agregar(a);
		y.agregar(a);
		writeln(k);
	end;
	x.close;
	y.close;
	}
	x.reset;
	y.reset;

	GetTime(HI,MI,SI,decseg);
	writeln(HI,MI,SI);
	for k:= 1 to 10000 do
	begin
		indice:= random(64535)+1;
		x.getElemento(a,indice);
	end;
	GetTime(HI,MI,SI,decseg);
	writeln(HI,MI,SI);

	readln;
	{
	while true do
	begin
		write(' Indice ?: '); readln(k);
		x.getElemento(a,k); y.getElemento(b,k);
		writeln('xval: ',a:12:3,' yval: ',b:12:3);
	end;
	}
end.

