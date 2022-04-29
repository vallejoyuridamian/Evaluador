{+doc
+NOMBRE: compol
+CREACION: 1.1.89
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Definicion de Polinomios y Numero Complejo y sus operaciones
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION: La implementacion de numero complejo de esta unidad difiere
de la implementada en AlgebraC. De alguna manera hay una duplicacion de los
servicios entre ambas unidades.

/// Sera motivo de unificacion algun dia //
-doc}

{rem $DEFINE BuscaRaiz_LOG} {Crea (o agrega) el archivo br_log.xlt con la historia}


(* Algebra de Complejos y de Polinomios /RCH89 *)

unit ComPol;
interface
uses
	xMatDefs;




 const

  MaxGr = 32;

 Type

	PPoliR = ^TPoliR;
	TPoliR = Record
				 c:array[0..MaxGr] of NReal;
             Gr:integer
           end;

   Complex = Record
							i,r:NReal
             end;

 { Procedimientos de entrada salida por la consola. Las entradas son
 iterativas con el usuario }
 procedure WritelnComp( c:complex);
 procedure WriteComp( c:complex);
 procedure ReadComp( var c:complex);
 procedure ReadPol( var p:TPoliR);
 procedure WritePol( p:TPoliR);


 { Procedimientos de lectura escritura en un archivo de texto }
 procedure WritePolTxt( var f: text; var P:TPoliR);

 procedure Sum(var a:complex;b,c:complex);
 (* a := b+c *)

 procedure Resta(var a:complex;b,c:complex);
 (* a := b-c *)

 procedure Pro(var a:complex;b,c:complex);
 (* a := b*c *)

 procedure Divi(var a:complex;b,c:complex);
 (* a := b/c *)

 procedure Cnj(var p:complex;c:complex);
 (* p := comjugado(c) *)

 function Mod2(c:complex):NReal;
 (* modulo al cuadrado de c *)

 function Modulo(c:complex):NReal;
 (* modulo de c *)

 procedure ValPR(var c:complex;p:TPoliR;s:complex);
 (* c := p(s) *)

 procedure derive(var p:TPoliR);
 (* p(s) := p'(s) *)

 function RouthHurwitz(a:TPoliR):integer;
 (* devuelve el numero de raices en el semiplano derecho *)
 (* si el algoritmo no es aplicable devuelve -1               *)

 function Jury(p:TPoliR):integer;
 (* devuelve el mumero de raices exteriores al circulo unidad *)
 (* si el algoritmo no es aplicable devuelve -1               *)

 procedure CambioVar(var a:TPoliR;b:NReal);
 (*  a(s):=a(s+b) *)

 procedure Homotecia(var q:TPoliR; b:NReal);
 {q(s) := b^q.gr * q(s/b)}

 function RaicesDerecha(p:TPoliR;a:NReal):integer;
 (* numero de raices de p(x) a la derecha  x = a *)

 function PRR(p:TPoliR;n:integer;error:NReal):NReal;
 (* parte NReal de la raiz numero n *)

{ Decrementa el grado hasta hacerlo cero o hasta que el coeficiente de
mayor grado sea distinto de cero. Lo que suceda primero }
procedure AjusteGrado( var r: TPoliR);

{ Lleva el coeficiente de mayor grado a 1}
procedure NormalizePoliR( var P: TPoliR);


{ Calcula el cociente y el resto de realizar la división Numerador/Divisor }
procedure CocienteResto( var Cociente, Resto, Numerador, Divisor: TPoliR );


{ Calcula el producto de dos polinomios.
OJO, el mismo polinomio que se utiliza para (res) no debe usarse como
uno de los términos del producto o el resultado será impredecible.
Operación:   res:= p1*p2 }
procedure MultPoliR( var res, p1, p2: TPoliR);


{ Calcula la suma de polinomios }
procedure SumaPoliR( var res, p1, p2: TPoliR);

{ Copia un polinomio en otro }
procedure CopiePoliR( var des, org: TPoliR);

{ Calcula el polinomio maximo comun divisor de otros dos.
	res = MCD(P1, P2) }
procedure PoliRMaximoComunDivisor(
	var res, P1, P2: TPolir );




{ Busca una raiz por el metodo de Newton partiendo del punto (1,1)
el resultado de la funcion es -1 si salio por superar el numero maximo
de iteraciones especificado en maxnit, 1 si la raiz es una raiz real
y 2 si la raiz es un par de complejos conjugados.

Parametro ( P ) contiene el polinomio. Esta pasado por variable
para economizar memoria pero NO se afecta por el algoritmo.

Parametro ( raiz ) es utilizado para devolver el valor de la raiz.
Si el resultado de la funcion es positivo (1 o 2) el valor devuelto
en (raiz) tiene sentido. Si el resultado es negativo el valor
devuelto carece de sentido.

Parametro (NIT). Se utiliza para devolver el numero de iteraciones
realizadas para alcanzar el resultado.

Parametros (ERPR y ERPI). Fijan la precision relativa exigida a
la dterminacion de la raiz tanto en la parte real (ERPR) como en la
imaginaria (ERPI).

Parametro ( MaxNIter )
Si es mayor que 0 se controlara el numero de iteraciones
para no superar este maximo, si es cero o negativo no
se realizara ningun control sobre el numero de iteraciones }

function BuscarRaiz_Newton(
	var P: TPoliR;
	var raiz: complex;
	var NIT: integer;
	ERPR, ERPI: NReal;
	MaxNIter: integer
	): integer;

(******************* EN DESARROLLO
{ Busqueda dicotomica. Primero se ajusta la parte real y luego la
imaginaria. Este metodo esta pensado para afinar las raices multiples
pues no necesita calcular la derivada del polinomio }
function BuscarRaiz_Chaer(
	var P: TPoliR;
	var raiz: complex;
	var NIT: integer;
	r1, r2, i1, i2: NReal; { rectangulo de busqueda }
	ERPR, ERPI: NReal;
	MaxNIter: integer
	): integer;
***********************************)

{ Divide el polinomio P por el Polinomio (s-raiz) lo que equivale
a "bajar" el polinomio por la raiz. El resultado de la funcion es
el grado del resto de la division. Si (raiz) es realmente una raiz
del polinomio el resultado es 0. Si el resultado es <> 0 se debe
interpretar que (raiz) o no es una raiz del polinomio o es una
mala aproximacion a una raiz }
function BajarRaizReal(	var P: TPoliR; raiz: NReal ): integer;

{ Divide el polinomio P por el polinomio (s^2-2*raiz.r+mod2(raiz))
El resultado de la funcion es el grado del resto de la division.
El resultado sera 0 si raiz es una buena aproximacion a una raiz
del polinomio P. }
function BajarRaizCompleja(	var P: TPoliR; raiz: complex ): integer;



implementation



procedure Homotecia(var q:TPoliR; b:NReal);
{ q(s) :=  q(s/b) } {q(s):= b^q.gr q(s/b)}
var
	temp:NReal;
	k,j:integer;
begin
temp:=1;
if b<> 0 then
	for k:=1 to q.gr do     {for k:=q.gr-1 downto 0 do }
		begin
			temp:=temp/b;        {temp:=temp*b}
			q.c[k]:=q.c[k]*temp;
		end
else
	begin
	q.c[0]:=q.c[q.gr];
	q.gr:=0;
	end;

k:=0;
while q.c[k]=0 do   k:=k+1;

if k>0 then
	begin
	q.gr:=q.gr-k;
	for j:=0 to q.gr do q.c[j]:=q.c[j+k];
	end;
end; {Homotecia}


procedure ReadPol;
var k:integer;
begin
writeln('Grado del Polinomio?');
read(p.Gr);
for k:=p.gr downto 0 do
           write('C',k,'?  ');
writeln;
for k:=p.Gr downto 0 do
         read(p.c[k])
end; (* ReadPol *)

procedure WritePol;
var k:integer;
begin
writeln( 'Grado = ',p.Gr:4);
writeln( 'coeficientes:');
for k:=p.gr downto 0 do
	  writeln( '[',k:3,'] = ',p.c[k]);
end; (* WritePol *)

procedure WritePolTxt( var f: text; var P: TPoliR);
var k:integer;
begin
writeln(f,  'Grado = ', p.Gr:4);
writeln(f,  'coeficientes:');
for k:=p.gr downto 0 do
	  writeln(f,  '[',k:3,'] = ',p.c[k]);
end; (* WritePol *)


 procedure WriteComp;
  begin
   write(c.r,' +j ',c.i)
  end; (* WriteComp *)

  procedure WritelnComp;
   begin
	 WriteComp( c);
    writeln
   end; (* WritelnComp *)

 procedure ReadComp;
  begin
   writeln('Re?         Imag?');
   read(c.r,c.i)
  end; (* ReadComp *)

 procedure Sum;
  begin
   a.r :=b.r+c.r;
   a.i:=b.i+c.i
  end; (* Sum *)

 procedure Resta(var a:complex;b,c:complex);
 begin
	a.r:=b.r-c.r;
	a.i:=b.i-c.i
 end;

 procedure Pro;
  begin
   a.r:=b.r*c.r-b.i*c.i;
   a.i:=b.r*c.i+b.i*c.r

  end; (* Pro *)

 procedure Divi;
  var
   p:complex;
	 m:NReal;
  begin
   Cnj(p,c);
   m:=Mod2(c);
   Pro(a,b,p);
   a.r:=a.r/m;
   a.i:=a.i/m
  end; (* Divi *)

 procedure Cnj;
  begin
   p.r:=c.r;
   p.i:=-c.i
  end; (* Cnj *)

 function Mod2;
  begin
   Mod2:=c.r*c.r+c.i*c.i
  end; (* Mod2 *)

 function Modulo;
  begin
   Modulo:=Sqrt(Mod2(c))
  end; (* Modulo *)


 procedure ValPR;
  var
   k:integer;
  begin
   c.r:=p.c[p.gr];
   c.i:=0;
   for k:=p.gr-1 downto 0 do
     begin
      pro(c,c,s);
      c.r:=c.r+p.c[k]
     end
  end; (* ValPR *)



procedure derive(var p:TPoliR);
var k: word;
begin
p.gr:=p.gr-1;
for k:=0 to p.gr do
	p.c[k]:=(k+1)*p.c[k+1];
end;

 function RouthHurwitz;
  var
   Rh,k,p:integer;
	 m:NReal;
   res:boolean;
  begin
   res:=true;
   for p:=a.gr downto 3 do
     if a.c[p-1]=0
          then
             res:=false
          else
             begin
             m:=a.c[p]/a.c[p-1];
             k:=p-2;
             while k>=1 do
               begin
                a.c[k]:=a.c[k]-m*a.c[k-1];
                k:=k-2
               end
             end;
     if res then begin
                   RH:=0;
                   res:=a.c[0]>0;
                   for p:=1 to a.gr do
                            if res xor(a.c[p]>0) then
                                                  begin
                                                    res:=not(res);
                                                    Rh:=Rh+1
                                                  end;
                   RouthHurwitz:=Rh
                 end
              else
                RouthHurwitz:=-1

  end; (* RouthHurwitz *)



  procedure CambioVar;
  var
   k,j:integer;

  begin
   for k:= 0 to a.gr-1 do
       for j:=a.gr-1 downto k do
                     a.c[j]:=a.c[j]+b*a.c[j+1]
  end; (* CambioVar *)


  function RaicesDerecha;
  begin
  CambioVar(p,a);
  RaicesDerecha:=RouthHurwitz(p)
  end;  (* RaicesDerecha *)




  function PRR;

	function f(x:NReal):boolean;
  begin
   f:=RaicesDerecha(p,x)>n
  end;

  var
	x,paso:NReal;
  sentido:boolean;

  begin
  if (n>0)and(n<=p.gr) then
   begin
    n:=n-1;
    paso:=1.8182;
    if f(0) then
             begin
             sentido:=true;
             x:=paso;
             while f(x) do   (* busca cota derecha *)
                begin
                  paso:= paso*2;
                  x:=x+paso
                end
             end
           else
             begin
             sentido:=false;
             x:=-paso;
             while not f(x) do   (* busca cota izquierda *)
                begin
                  paso:=paso*2;
                  x:=x-paso
                end;
             x:=x+paso  (* me paro a la derecha *)
             end ;

   while paso>error do
           begin
           paso:=paso/2;
            if f(x-paso) then (* me paso *)
                  else x:=x-paso
           end;
   PRR:=x;
  end
  else
  begin
   writeln('*ERROR*(PRR/ComPol) ->numero de raiz fuera de rango');
   while true do
  end
 end; (* PRR *)



function Jury(p:TPoliR):integer;
label
	fin;

var
   k,j:integer;
	 a,z:NReal;
   res:boolean;

begin
 for j:= p.gr downto 1 do
	  begin
	  { OJO! NO VERIFICAMOS SE p.c[j] = 0. SE ME TRANCO UNA VEZ }
		if p.c[j] = 0 then begin jury:=-1; goto fin end; {!!!!!!!!}
			 a:=p.c[0]/p.c[j];
          p.c[0]:=p.c[j]-a*p.c[0];
          if j <> 1 then
           begin
             for k:= 1 to j div 2 do
                 begin
                  z:=p.c[j-k];
                  p.c[j-k]:=p.c[k]-a*z;
                  if k <> j-k then p.c[k]:=z-a*p.c[k]
                 end;
             for k:=0 to (j-1) div 2 do
                 begin
                  z:=p.c[k];
                  p.c[k]:=p.c[j-1-k];
                  p.c[j-1-k]:=z
                 end
			  end


     end;

 j:=0; res:=true;

 for k:=0 to p.gr do
     begin
      if p.c[k]< 0 then j:=j+1
      else if p.c[k] = 0 then res:=false
     end;

 if res then Jury := j
	 else Jury := -1;
 fin:
 end; (* Jury *) (* 19/9/89 *)






procedure AjusteGrado( var r: TPoliR);
begin
	while (EsCero( r.c[r.Gr] ) and (r.Gr >0)) do r.Gr:= r.Gr-1;
end;

{ Lleva el coeficiente de mayor grado a 1}
procedure NormalizePoliR( var P: TPoliR);
var
	k: integer;
	m: NReal;
begin
	m:= P.c[P.Gr];
	for k:= 0 to P.Gr do P.c[k]:= P.c[k]/ m;
end;



procedure CocienteResto( var Cociente, Resto, Numerador, Divisor: TPoliR );
var
	GradoDelResto, k, j: integer;
   cmgd, cm: NReal;

begin

   { Por precaución ajustamos los grados }
	AjusteGrado( Numerador );
	AjusteGrado( Divisor );

	if Divisor.Gr > Numerador.Gr then
	begin
      { El cociente es nulo }
		Cociente.Gr:= 0;
		Cociente.c[0]:=0;

		{ El resto es el dividendo }
		Resto.Gr:= Numerador.Gr;
		for j:= 0 to Numerador.Gr do
			Resto.c[j]:=Numerador.c[j];
	end
	else
   begin

		Cociente.Gr:= Numerador.Gr- Divisor.Gr;
		GradoDelResto:= Divisor.Gr-1; { o inferior, a ajustar al final }

      Resto.Gr:=Numerador.Gr;  { temporalmente }
      { Copiamos todo el polinomio como resto inicial }
		for j:= 0 to Numerador.Gr do
			Resto.c[j]:= Numerador.c[j];

		{ determinamos uno a uno los ceficientes del cociente y vamos
		actualizando el resto }
      cmgd:= Divisor.c[Divisor.Gr]; {coeficiente de mayor grado del divisor}
		for k:= Cociente.Gr downto 0 do
		begin
			cm:= Resto.c[resto.Gr]/cmgd;
			Cociente.c[k]:= cm;
			for j:= 0 to Divisor.Gr-1 do
				Resto.c[resto.Gr-Divisor.Gr+j]:=
					Resto.c[resto.Gr-Divisor.Gr+j]- Divisor.c[j]*cm;
			Resto.Gr:= Resto.Gr-1;
      end;

		{ ajustamos el grado del resto }
		AjusteGrado( Resto );
	end;
end;


{ Calcula el producto de dos polinomios }
procedure MultPoliR( var res, p1, p2: TPoliR);
var
	k, j: integer;
begin
	for k:= 0 to p1.gr+p2.gr do res.c[k]:=0;
	for k:= 0 to p1.gr do
		for j:= 0 to p2.gr do
			res.c[k+j]:= res.c[k+j]+p1.c[k]*p2.c[j];
	res.gr:= p1.gr+p2.gr;
end;


{ Calcula la suma de polinomios }
procedure SumaPoliR( var res, p1, p2: TPoliR);
var
	k: integer;
begin
	if p1.Gr > p2.Gr then
	begin
		res.Gr:= p1.Gr;
		for k:= 0 to p2.Gr do res.c[k]:= p1.c[k]+p2.c[k];
		for k:= p2.Gr+1 to p1.Gr do res.c[k]:= p1.c[k];
	end
	else
	if p2.Gr > p1.Gr then
	begin
		res.Gr:= p2.Gr;
		for k:= 0 to p1.Gr do res.c[k]:= p2.c[k]+p1.c[k];
		for k:= p1.Gr+1 to p2.Gr do res.c[k]:= p2.c[k];
	end
	else
	begin
		res.Gr:= p2.Gr;
		for k:= 0 to p1.Gr do res.c[k]:= p2.c[k]+p1.c[k];
		AjusteGrado(res);
	end;
end;


procedure CopiePoliR( var des, org: TPoliR);
begin
	des.gr:= org.gr;
	move( org.c[0], des.c[0], (org.gr+1)*SizeOf(NReal));
end;



procedure PoliRMaximoComunDivisor(
	var res, P1, P2: TPolir );
var
	r1, r2, r, c, tmp: PPoliR;

begin

	new(r1);
	new(r2);
	new(r);
	new(c);

	if P1.Gr >= P2.Gr then
	begin
		CopiePoliR( r1^, P1);
		CopiePoliR( r2^, P2);
	end
	else
	begin
		CopiePoliR( r1^, P2);
		CopiePoliR( r2^, P1);
	end;
	repeat
		CocienteResto( c^, r^, r1^, r2^);
		if r^.Gr >0 then
		begin
			tmp:=r1;
			r1:= r2;
			r2:= r;
			r:=tmp;
		end;
	until r^.Gr = 0;

   CopiePoliR( res, r2^);
	dispose(r1);
   dispose(r2);
	dispose(r);
	dispose(c);
end;



function BuscarRaiz_Newton(
	var P: TPoliR;
	var raiz: complex;
	var NIT: integer;
	ERPR, ERPI: NReal;
	MaxNIter: integer
	): integer;


var
	dp: TPoliR;
	z, zs: complex;
	mpz2, d2, errx, erry: NReal;
	pz, dpz: complex;
	PrecisionAlcanzada, MaximoDeIteracionesSuperado,
	FinDeIteraciones: boolean;
	ControlarNumeroDeIteraciones: boolean;
	{$IFDEF BuscaRaiz_LOG }
	flog: text;
	{$ENDIF}

begin

	{$IFDEF BuscaRaiz_LOG }
	assign( flog, 'br_log.xlt');
	{$I-}
	append( flog );
	{$I+}
	if	ioresult <> 0 then rewrite( flog );
	writeln( flog );
	writeln( flog, '.................');
	WritePolTxt( flog, P);
	writeln( flog );
	{$ENDIF}

	CopiePoliR( dp, P);
	derive(dp);

	{ Punto inicial de la iteraccion }
	z.r:= 1;
	z.i:= 1;
	nit:= 0;
	PrecisionAlcanzada:= false;
	MaximoDeITeracionesSuperado:= false;
	FinDeIteraciones:= false;
	ControlarNumeroDeIteraciones:= MaxInt > 0;
	{ Bucle de iteraccion }
	repeat

		ValPr( pz, p, z);
		mpz2:= Mod2( pz );

		{$IFDEF BuscaRaiz_LOG }
		writeln( flog, z.r,#9,z.i,#9,mpz2);
		{$ENDIF}

		ValPr( dpz, dp, z);

		{ deteccion de cero en la derivada }
		if EsCero( mod2(dpz) ) then { iteracion imposible o raiz multiple }
		begin
			if EsCero(mpz2) then
			begin
				PrecisionAlcanzada:= true;
				zs.r:=0; zs.i:=0;
			end
			else
				if Abs(z.i)>1 then
					zs.i:= zs.i+z.i/10.0*random
				else
					zs.i:= zs.i+1.0/10.0*random;
		end
		else  { Iteracion posible }
		begin 
			Divi( zs, pz, dpz);
			Resta( z, z, zs );
			PrecisionAlcanzada:=
				( abs(zs.r)<= ERPR*abs(z.r))and
				( abs(zs.i)<= ERPI*abs(z.i));
		end;

		inc(nit);

		if ControlarNumeroDeIteraciones then
		begin
			MaximoDeIteracionesSuperado:= nit > MaxNIter;
			FinDeIteraciones:= PrecisionAlcanzada or MaximoDeIteracionesSuperado;
		end
		else
			FinDeIteraciones:= PrecisionAlcanzada;
	until PrecisionAlcanzada or MaximoDeIteracionesSuperado;
	if not PrecisionAlcanzada  then BuscarRaiz_Newton:= -1
	else
	begin
		{ Probamos si anulando la parte imaginaria
		se obtiene una mejor aproximaci¢n a una ra¡z, en ese caso
		la ra¡z es real }
		zs:= z;
		zs.i:=0;
		ValPr( dpz, p, zs);
		if EsCero( z.i ) or (mod2(dpz) <= mod2(pz)) then
		begin
			BuscarRaiz_Newton:=1; { ra¡z real }
			raiz:= zs;
		end
		else
		begin
			BuscarRaiz_Newton:=2; { par de complejos conjugados }
			raiz:= z;
		end;
	end;

	{$IFDEF BuscaRaiz_LOG }
	close(flog);
	{$ENDIF}

end;


function BajarRaizReal(	var P: TPoliR; raiz: NReal ): integer;
var
	c, r, d: TPoliR;
begin
	d.Gr:=1;
	d.c[0]:= -raiz;
	d.c[1]:= 1;
	CocienteResto( c, r, P, d );
	CopiePoliR( P, c );
	BajarRaizReal:= r.Gr; { si es ra¡z tiene que ser 0 }
end;

function BajarRaizCompleja(	var P: TPoliR; raiz: complex ): integer;
var
	c, r, d: TPoliR;
begin
	d.Gr:=2;
	d.c[0]:= mod2(raiz);
	d.c[1]:= -2*raiz.r;
	d.c[2]:= 1;
	CocienteResto( c, r, P, d );
	CopiePoliR( P, c );
	BajarRaizCompleja:= r.Gr; { si es ra¡z tiene que ser 0 }
end;


(*********************** EN DESARROLLO
{ Busqueda dicotomica de par de raices complejas.
( SOLO PARA RAICES COMPLEJAS )
Primero se ajusta la parte real y luego la
imaginaria. Este metodo esta pensado para afinar las raices multiples
pues no necesita calcular la derivada del polinomi.
}
function BuscarRaiz_Chaer(
	var P: TPoliR;
	var raiz: complex;
	var NIT: integer;
	r1, r2, i1, i2: NReal; { rectangulo de busqueda }
	ERPR, ERPI: NReal;
	MaxNIter: integer
	): integer;

var
	rdr1, rdr2: integer;
	xr, xi: NReal;
	p1, p2: TPolir;
var
	signo: integer;

begin
	signo:= true;
	rdr1:= RaicesDerecha(p, r1);
	rdr2:= RaicesDerecha(p, r2);
	if not (rdr1 > rdr2) then BuscarRaiz_Chaer:= -1
	else
	begin
		xr:= PRR( p, rdr1, ERPR*(r1+r2)/2);
		CambioVar(p, xr);

		for k:= 0 to P.Gr do
		begin
			if ( k mod 2 ) = 0 then
			begin
				if signo then p1.c[k div 2 ]:= P.c[k]
				else p1.c[k div 2 ]:= -P.c[k]
			end
			else
			begin
				if signo then p2.c[k div 2]:= p.c[k]
				else p2.c[k div 2]:= -p.c[k];
				signo:= not signo;
			end;
		end;
		if (p.gr mod 2) = 0 then
		begin
			p1.gr := p.gr div 2;
			p2.gr := (p.gr-1) div 2;
		end
		else
		begin
			p1.gr := (p.gr-1) div 2;
			p2.gr := p.gr div 2;
		end;


********************************************)




 begin
 (*
 writeln;
 writeln;
 writeln('********* Unidad ComPol ******* RCh/12/7/89');
 *)

 {$UNDEF BuscaRaiz_LOG}
 end. (* ComPol *)


