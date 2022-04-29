{+doc
+NOMBRE: autovals
+CREACION: 22.02.95
+AUTORES: rch
+REGISTRO:
+TIPO: Programa Pascal.
+PROPOSITO: ejemplo de c lculo de autovectores y autovalores de
	una matriz de reales.

+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

uses
	xMatDefs, MatReal, Compol,
	{$I xCRT};



const
	dim= 5;
var
	a, as, BSEN: TMatR;
	p: TPoliR;
	res: integer;
	raiz: complex;

procedure RandomMatR( var a: TMatR; NFilas, NColumnas: integer );
var
	k,j: integer;
begin
	a.init( NFilas, NColumnas );
	RandSeed:=31;
	for k:= 1 to a.nf do
		for j:= 1 to a.nc do
			a.pon_e(k,j, random );
end;

{ Ej1. pag 450 de HR.
 Los Autovalores de A son: (5.28799)(-1.42107)(0.13307)

 }
procedure MatHRpag450( var a: TMatR );
begin
	a.init(3,3);
	{ fila 1 }
	a.pon_e(1,1, 1.0);
	a.pon_e(1,2, 1.0);
	a.pon_e(1,3, 1.0);
	{ fila 2 }
	a.pon_e(2,1, 3.0);
	a.pon_e(2,2, 2.0);
	a.pon_e(2,3, 1.0);
	{ fila 3 }
	a.pon_e(3,1, 6.0);
	a.pon_e(3,2, 3.0);
	a.pon_e(3,3, 1.0);
end;

procedure MAT3AR( var a: TMatR );
begin
	a.init(3,3);
	{ fila 1 }
	a.pon_e(1,1, 1.0);
	a.pon_e(1,2, 0.0);
	a.pon_e(1,3, 0.0);
	{ fila 2 }    
	a.pon_e(2,1, 0.0);
	a.pon_e(2,2, 1.0);
	a.pon_e(2,3, 0.0);
	{ fila 3 }
	a.pon_e(3,1, 0.0);
	a.pon_e(3,2, 0.0);
	a.pon_e(3,3, 1.0);
end;

procedure MCMPX( var a: TMatR );
begin
	a.init(3,3);
	{ fila 1 }
	a.pon_e(1,1, 0.0);
	a.pon_e(1,2, -1.0);
	a.pon_e(1,3, 0.0);
	{ fila 2 }    
	a.pon_e(2,1, 1.0);
	a.pon_e(2,2, 0.0);
	a.pon_e(2,3, 0.0);
	{ fila 3 }
	a.pon_e(3,1, 0.0);
	a.pon_e(3,2, 0.0);
	a.pon_e(3,3, 1.0);
end;


var

	k, j:integer;
	tsen, resec: TMatR;
	NIT: integer;
	MR: TMatR;
	imr: integer;



begin
	Writeln
	('EPSILON DE ESTA MAQUINA: ', AsumaCero);
{	MCMPX(a); }
	RandomMatR( a, 26, 26 );
{	MatHRpag450(a);}
  { Mat3AR( a ); }
	as.Init( 3, 3 );

   MR.Init( 3, 3 ); { cambio de base }
	imr:= 1;


   {
	as.Init( dim, dim );
	RandomMatR(a, dim, dim );
	}

	a.WriteM;

	{ guardamos en as la matriz original }
	as.igual(a);
	a.PolinomioCaracteristico(p);
	while p.gr >0 do
	begin
	{	WritePol(p); }
		res:= BuscarRaiz_Newton(p, raiz, NIT,10*AsumaCero, 10*AsumaCero, 1000 );
		write(' BR: ', res ,' NIT: ', NIT, '///');
		case res of
			-1:
			begin
				writeln(' ERROR, no ecuentro ninguna raiz');
				halt(1);
			end;
			1:
			begin
				write(' 1RR: ', raiz.r:6:3,'//');
				writeln('resto: ', BajarRaizReal(	 P,  raiz.r ));
				(*
				writeln( 'La dimensi¢n del subespacio asociado es: ', a.CalcBSE_R(BSEN, raiz.r));
				BSEN.writeM;
				readln;
				writeln(BSEN.Ortonormal);

            { Copia de los vectores de la base en MR (pasa las filas a clumnas) }
				for k:= imr to imr-1+BSEN.nf do
				 for j:= 1 to BSEN.nc do MR.pon_e(k, j, BSEN.e(j, k-imr+1));
				inc(imr, BSEN.nf);

				BSEN.writeM;
				tsen.init(BSEN.nf, BSEN.nc);
				tsen.igual(BSEN);
				resec.init(BSEN.nf, BSEN.nf);
				readln;
				{ Verificacion }
				BSEN.Trasponer;
				BSEN.Mult(as, BSEN);
				resec.Mult(tsen, BSEN);
				writeln('BSEN*A*BSEN''', ' autovalor: ', raiz.r);
				resec.WriteM;
				readln;

				{ reacondicionamiento de datos y estructuras }
				BSEN.done;
				resec.done;
				tsen.done;
				a.igual(as);
				  *)
			end;
			2:
			begin
				write(' pCC: ', raiz.r:6:3, ' +j',raiz.i:6:3, ' // ');
				writeln('resto: ', BajarRaizCompleja( P, raiz ));
			end;
		end;
	end;
	writeln( 'fin de busquedas');
	readln;
	a.done;
	as.done;
   MR.done;
end.
