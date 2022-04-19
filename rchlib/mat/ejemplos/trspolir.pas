{+doc
+NOMBRE: trspolir
+CREACION: 19.02.95
+AUTORES: rch
+REGISTRO:
+TIPO: programa Pascal.
+PROPOSITO: test de (BuscarRaiz) de un polinomio.
+PROYECTO:
	rchlib.

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

program trspolir;

uses
	{$I xCrt}, compol, xMatDefs;


var
	a, r, d: TPoliR;
	res: integer;
	raiz: complex;

begin
	d.Gr:= 3;
	d.c[0]:= +1.0;
	d.c[1]:= -2.0;
	d.c[2]:= +3.0;
	d.c[3]:= -4.0;

	r.Gr:= 2;
	r.c[0]:= 2;
	r.c[1]:= -2;
	r.c[2]:= 1;

	MultPoliR( a, d, r );
	writeln(' -------------------------');

	while a.Gr > 0 do
	begin
		res:= BuscarRaiz(	a,   raiz, 1e-10, 10000 );
		case res of
			-1:
			begin
				writeln(' ERROR ');
				readln;
				halt(1);
			end;
			1: writeln( '1RR : ', raiz.r:12:4, '                      resto.Gr: ', BajarRaizReal( a, raiz.r) );
			2: writeln( 'PRC : ', raiz.r:12:4,'+j', raiz.i:12:4,'        resto.Gr: ', BajarRaizCompleja( a, raiz ))
		end;
	end;


end.
