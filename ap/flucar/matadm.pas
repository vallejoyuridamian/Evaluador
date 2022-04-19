{+doc
+NOMBRE:  MATADM
+CREACION:
+MODIFICACION:  8/97
+AUTORES:  MARIO VIGNOLO
+REGISTRO:
+TIPO:  Unidad Pascal
+PROPOSITO:  Procedimientos para construir la matriz de admitancias
+PROYECTO: FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:

-doc}

unit matadm;

interface
uses
	XMatDefs,AlgebraC,Barrs2, Impds1, Cuadri1, Trafos1,
	Regulado, TyVs2;

procedure FormarSistema;
{Crea la matriz de admitancias Yki del flujo de carga. Recordar
que Yki=-yki; Ykk=yk+sum(yki), con sum variando i de 1 a NBarras
y i<>k}

procedure PonT( n1, n2: integer; xy: NComplex; n: NReal);
{Agrega un transformador en la matriz de admitancias}

procedure SacarT( n1, n2: integer; xy: NComplex; n: NReal);
{Sumo todas las constantes a la matriz de admitancias cambiandoles
el signo. De esta forma si repito consecutivamente con los mismos
par metros PonT y SacarT el resultado final en no haber colocado
ning£n transformador}
procedure Pon(nEc, nVar: integer; XY: NComplex );
procedure PonY( n1, n2: integer; xy: NComplex);

implementation

procedure Pon(nEc, nVar: integer; XY: NComplex );
begin
	if (nEc<> 0)and(nVar<>0) then mAdmitancias.acumular_(nEc,nVar,XY);
end;

procedure PonY( n1, n2: integer; xy: NComplex);
var
	menosy: NComplex;
begin
	menosy:= prc(-1,xy)^;
	pon(n1,n1,xy);
	pon(n1,n2, menosy);
	pon(n2,n1, menosy);
	pon(n2,n2, xy);
end;

procedure PonT( n1, n2: integer; xy: NComplex; n: NReal);
var
	xyt,menosy, menosyt: NComplex;
begin
	menosy:= prc(-1,xy)^;
	xyt:= prc(sqr(n),xy)^;
	menosyt:= prc(n,menosy)^;
	pon(n1,n1,xyt);
	pon(n1,n2, menosyt);
	pon(n2,n1, menosyt);
	pon(n2,n2, xy);
end;

procedure SacarT( n1, n2: integer; xy: NComplex; n: NReal);

var
	xyt,menosy, menosyt: NComplex;
begin
	menosy:= prc(-1,xy)^;
	xyt:= prc(sqr(n),xy)^;
	menosyt:= prc(n,menosy)^;
	pon(n1,n1, prc(-1,xyt)^);
	pon(n1,n2, prc(-1,menosyt)^);
	pon(n2,n1, prc(-1,menosyt)^);
	pon(n2,n2, prc(-1,xy)^);
end;



procedure FormarSistema;

var
	k: integer;
	n: NReal;
	N1, N2: TIndice;
	y, z: NComplex;
	xy: NComplex;

begin
	{ Colocar Impedancias }
	for k:= 1 to NImpedancias do
	begin
		z:= TImpedancia(Impedancias[k-1]).z;
		y:= prc( 1/mod2(z), cc(z)^)^;
		N1:= TImpedancia(Impedancias[k-1]).Nodo1;
		N2:= TImpedancia(Impedancias[k-1]).Nodo2;
		ponY(N1, N2, y);

	end;

	{ Colocar CuadripolosPi }
	for k:= 1 to NCuadripolosPi do
	begin
		y:= TCuadripoloPi(Cuadripolos[k-1]).Y13;
		N1:=TCuadripoloPi(Cuadripolos[k-1]).Nodo1;
		N2:=TCuadripolopi(Cuadripolos[k-1]).Nodo3;
		pony(N1, N2, y);
		z:= TCuadripoloPi(Cuadripolos[k-1]).Z12;
		y:= prc( 1/mod2(z), cc(z)^)^;
		N1:= TCuadripoloPi(Cuadripolos[k-1]).Nodo1;
		N2:= TCuadripoloPi(Cuadripolos[k-1]).Nodo2;
		pony(N1, N2, y);
		y:= TCuadripoloPi(Cuadripolos[k-1]).Y23;
		N1:= TCuadripoloPi(Cuadripolos[k-1]).Nodo2;
		N2:= TCuadripoloPi(Cuadripolos[k-1]).Nodo3;
		pony(N1, N2, y);

	end;

	{ Colocar Trafos }
	for k:= 1 to NTrafos do
	begin
		z:= TTrafo(Trafos[k-1]).Zcc;
		y:= prc( 1/mod2(z), cc(z)^)^;
		N1:= TTrafo(Trafos[k-1]).Nodo1;
		N2:= TTrafo(Trafos[k-1]).Nodo2;
		n:= TTrafo(Trafos[k-1]).n;
		ponT(N1, N2, y, n);
	end;

	{ Colocar Reguladores }
	for k:= 1 to NReguladores do
	begin
		z:= TRegulador(Reguladores[k-1]).Zcc;
		y:= prc( 1/mod2(z), cc(z)^)^;
		N1:= TRegulador(Reguladores[k-1]).Nodo1;
		N2:= TRegulador(Reguladores[k-1]).Nodo2;
		n:= TRegulador(Reguladores[k-1]).n;
		ponT(N1, N2, y, n);
	end;

end;

end.
