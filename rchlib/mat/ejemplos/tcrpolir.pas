{+doc
+NOMBRE: tcrpolir
+CREACION: 19.02.95
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:
	test de los procedimientos
	( PoliRMaximoComunDivisor ) , ( MultPoliR ) y ( CocienteResto )
	agregados a compol.

+PROYECTO:  rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}



program test;

uses
	{$I xCrt}, Compol;



var
	c, r, n, d: TPoliR;


begin
	d.Gr:= 3;
	d.c[0]:= +1.0;
	d.c[1]:= -2.0;
	d.c[2]:= +3.0;
	d.c[3]:= -4.0;

	r.Gr:= 2;
	r.c[0]:= -10.1;
	r.c[1]:= +20.1;
	r.c[2]:= +30.1;

	MultPoliR( c, d, r);
	writePol(c);
	readln;


	r.Gr:= 2;
	r.c[0]:= -0.1;
	r.c[1]:= +22.1;
	r.c[2]:= +322.1;

	MultPolir(n, d, r);
	WritePol(n);
	readln;


	PoliRMaximoComunDivisor( r, c, n );
	NormalizePoliR(r);
	writeln( ' MCD: ');
	WritePol(r);
   readln;

	NormalizePoliR(d);
	writePol(d);
	readln;
end. 
