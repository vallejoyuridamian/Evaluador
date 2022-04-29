program fun_p1;
uses
	xMatDefs, ComPol;

const
	cofs: array[0..10] of NReal = (
			-1.76924760887331E-0003,
			+6.60481763638927E-0002,
			+1.66494595923155E-0002,
			-5.06349803999910E-0001,
			+9.01640871638847E-0001,
			-1.95472038406297E+0000,
			-1.15779935877799E+0000,
			+6.06625335148419E+0000,
			-1.66265902423038E+0000,
			-4.92955786688253E+0000,
			+1.00000000000000E+0000
			);

var
	f: file of NReal;
	P: TPoliR;
	c, z: complex;
	m: NReal;
	k: integer;
	res: integer;
	raiz: complex;
	nit: integer;

begin
	P.Gr:= 10;
	for k:= 0 to P.Gr do P.C[k]:= cofs[k];
{
	WritePol(p);
	res:= BuscarRaiz(p, raiz, NIT, AsumaCero*10, AsumaCero*10, MaxInt );
	writeln(' BuscarRaiz: ', res ,' NIT: ', NIT);
	writelnComp( raiz );
	readln;
 }

	assign( f, 'fun_p1.ent');
	reset(f);
	read(f, z.r);
	read(f, z.i);
	close(f);

	ValPR( c, P, z);
	m:= modulo(c);
	assign( f, 'fun_p1.sal');
	rewrite(f);
	write(f, m);
	close(f);

end.