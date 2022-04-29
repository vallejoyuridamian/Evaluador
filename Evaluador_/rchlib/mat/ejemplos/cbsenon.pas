{+doc
+NOMBRE: CBSENON
+CREACION: 22.02.95
+AUTORES: rch
+REGISTRO:
+TIPO: program Pascal.
+PROPOSITO: ejemplo de los métodos
	CalcBSEN y Ortonormal;


+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}


program CBSENON;
uses
	{$I xCRT}, MatReal, xMatDefs;

var
	as, a, b, inv_b, BSEN: TMatR;
	DimSEN: integer;


procedure Inicializar;
var
	fila, columna: integer;
	m: NReal;

begin

	a.init( 4, 4);
	as.init(4,4);
	b.init( 4, 4);
	inv_b.init(4,4);

   { Col1 }
	a.pon_e(1,1,1);
	a.pon_e(1,2,0);
	a.pon_e(1,3,0);
	a.pon_e(1,4,0);

	{ Col2 }
	a.pon_e(2,1,0);
	a.pon_e(2,2,1);
	a.pon_e(2,3,0);
	a.pon_e(2,4,0);

	{ Col3 }
	a.pon_e(3,1,10);
	a.pon_e(3,2,11);
	a.pon_e(3,3,0);
	a.pon_e(3,4,0);

	{ Col4 }
	a.pon_e(4,1,100);
	a.pon_e(4,2,110);
	a.pon_e(4,3,0);
	a.pon_e(4,4,0);

	randSeed:= 31;
	for fila:= 1 to 4 do
		for columna:= 1 to 4 do
		begin
			m:= random;
         writeln(m);
			b.pon_e(fila, columna, m);
		end;

	inv_b.igual(b);
	inv_b.inv;

	a.Mult(a, b);
	a.Mult(inv_b, a);

end;


procedure finalizar;
begin
	a.done;
	as.done;
	b.done;
	inv_b.done;
	BSEN.done;

end;




begin
	Inicializar;
	writeln(' La matriz siguiente tiene un subespacio nulo de dimensi¢n 2');
	a.WriteM;
	writeln(' Pulse ENTER para calcular BSEN');
	readln;
	as.igual(a);
	as.writeM;
	readln;

	DimSEN:= a.CalcBSEN( BSEN );

	writeln( 'La dimensi¢n de BSEN es:', DimSEN );
	writeln;
	writeln(' A continuaci¢n se imprime la matriz original para mostrar');
	writeln(' que CalcBSEN la DESTROZA ');
	a.WriteM;
	readln;



	writeln(' BSEN: ');
	BSEN.WriteM;
	readln;

	Writeln('BSEN.Ortonormal: ', BSEN.Ortonormal);
	BSEN.writeM;
	readln;

	writeln( 'BSEN.Trasponer ');
	BSEN.Trasponer;
	BSEN.WriteM;
	readln;


	writeln(' as * BSEN.Trasponer = 0 ');
	BSEN.Mult(as, BSEN);
	BSEN.writeM;
	readln;


	finalizar;

end.