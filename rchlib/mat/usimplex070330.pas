unit usimplex;
interface
uses
	matreal, matent, xMatDefs,
	SysUtils;

(*
	rch.2006 implementación del método simplex de acuerdo
 con el libro: Lectures on Numerical Mathematics ( Heinz Rutishauser 1990 )

El algoritmo trabaja sobre una matriz ( a ) de ( m x n )
La cantidad de variables de optimizacion (x ) es ( n-1 )
y la cantidad de restricciones es ( m-1 ).

El problema está planteado como de maximizar la funcion
	z= sum( a(m,j)* x(j); j=1..n-1 )
sujeto a (m-1) restricciones del tipo:
	y= sum( a(k,j)*x(j); j=1..n-1 ) + a(k, n) >= 0 ; k=1..m-1


Esta versión está mejorada respecto de la del libro en los siguientes
aspectos:
1) Busca de una solución factible inicial. Para eso se ordenan las
	 restricciones dejando para el final las que no son satisfechas
	 y se elige la primera insastifecha tal como si se tratase de la función
	 a maximizar. Se intenta entonces resolver el problema con esa función
	 objetivo hasta que la misma se vuelva positiva (pasó a factible). Luego
	 se continúa con la siguiente restricción insatisfecha y así hasta que están
	 todas satisfechas o no se puede continuar (problema infactible).
2) Tratamiento de cotas inferiores no nulas. Se introdujo el método
		procedure cota_inf_set( ivar: integer; vxinf: NReal );

		que permite fijar una cota inferior no nula para la variable de índice ivar.
		Tener en cuenta que este procedimiento tiene que ser llamado durante el
		armado del problema, luego de haber cargado todas las restricciones, pues
		realiza un cambio de variables sobre las mismas.

3) Manejo de cotas superiores en forma inteligente. En lugar de tener que
		incluir una restricción para cada cota superior, las mismas se tratan en
		forma inteligente observando que con un cambio de variable adecuado es posible
		representar la restricción de cota superior como una de x >= 0 y que no
		es necesario entonces incluir la restricción como una fila más en la matriz.

4) Los cambios de variables para el manejo de las "restricciones de caja"
		impone que al leer los resultado deben deshacerse dichos cambios, para eso
		incluímos las funciones:
		xval( ivar )  : retorna el resutaldo de la variable x
		yval( irest ) : retorna el valor que toma la restricicón
		fval : retorna el valor de la función objetivo
		xmult( ivar ): retorna el multiplicador de Lagrange asociado a la variable
									será 0 (nulo) si la variable x no está en sus valores extremos
									o será un valor no nulo si está activa una de las dos restricciones
									en cuyo caso es el multiplicador asociado a la restriccion
									activa.
		ymult(irest): retorna el multiplicador asociado a la restricción irest
									será 0 (nulo) si la restricción no está activa y negativo
									en caso contrario.
5) Posibilidad de FIJAR VARIABLES. Esto permite fijar un valor para una
variable (es decir que deja de ser variable). Es para facilitar el planteo
del problema.
**************************
Nota.
-----
Este simplex, MAXIMIZA la función objetivo f(x) y las restricciones son del
tipo y(x) >= 0 .
Esto lleva a que si lo que estamos es minimizando una función de costo(x)
la función objetivo sea f(x) = - costo(x)

Esto puede confundir un poco en la interpretación de los multiplicadores de Lagrange.
Por ejemplo, si una restricción represanta la necesidad de cubrir determinada demanda (D)
con diferentes fuentes (x). La variación del costo frente a un aumento del valor de (D) será
positiva por lo que la variación correspondiente de f(x) será negativa.

*)


const
(*
Esta constante se utiliza en el proceso de selección del mejor_pivte, para
no elegir pivotes casi nulos que sean el resultado de redondeos numéricos.
Cuando un coeficiente es comparado con CasiCero_Simplex para saber si es
candidato a pivote, colateralmente se lo impone CERO si es inferior en valor
absoluto a CasiCero_Simplex.
*)
	CasiCero_Simplex= 1.0E-10;

type
	TArrayOfStrings= array of String;

	TSimplex = class( TMatR )
		mensajeDeError: string;
		// contadores para debug
		cnt_resolver, cnt_paso: integer;
{$IFDEF SPXCONLOG}
		dbg_on: boolean; // llave para debug
		sdbg: string; // buffer para el log
		nombreVars, nombreRest: TArrayOfStrings;
{$ENDIF}

		top, left: array of smallint;
		iix, iiy: array of smallint;

		cnt_infactibles: integer;
		cnt_igualdades: integer; // canidad de restricciones de igualdad (al inicio de A ).
		cnt_varfijas: integer; // cantidad de variables fijadas

		cnt_cotas_inf, cnt_cotas_sup: integer;
		x_inf, x_sup: TVectR; // restricciones de caja
		flg_x: array of shortint; // es 0 si no hay cota superior,
													// es -1 si hay cota superior, pero es la inferior la considerada actualemnte
													// es 1 si hay cotas superior y es la considerada actualmente en el sistema.
													// es 2 si esta variable fue fijada.

		flg_y: array of shortint; // 0 para restricciones de >=0, 2 si es una =0 , -2 si es una =0 a la que le cambié el signo
{$IFDEF GATILLOS_CAMBIOVAR}

		cnt_Gatillos: integer;
		gatillos_CambioVar: array of smallint;
      gatillos_no_procesados: boolean;

{$ENDIF}
		constructor Create_init( m, n: integer);
			constructor Create_clone( spx: TSimplex );
(*
realiza la combinacion lineal: fila(kdest,j):= fila(kdest,j) + m*fila(korg,j)
afectando solamente las celdas con j:= jini to jfin
*)
		procedure combinax( kdest, korg, jini, jfin: integer; m :NReal );
		procedure intercambiar( kfil, jcol : integer );
		procedure Free; override;
(*
buscamos una columna en que en la ultima fila (fila z ) el valor es negativo
retorna el indice  si lo encontro, -1 si son todos >= 0
*)
		function locate_zpos(kfila_z : integer; jini: integer): integer;

(*
dada una columna q candidata busca la fila k para intercambiar
el resultado es el idice (p) de fila o -1 si no hay ningun candidato
a pivote a(p,q) que sea negativo.
La búsqueda se realiza entre las filas 1 y kmax.

Si el resultado es -3, quiere decir que en la coluna q hay una variable x
con manejo de cota superior y que el mejor pivote corresponde a cambiar en la
misma columna la representación de la variable.
Si el resultado es > 0 pero la fantasma se devuelve con TRUE quiere decir
que el resultado identifica un fila para intercambiar con q, pero que la fila
a intercambiar es la "fantasma" asociada a la fila identificada. Es decir la
de su cota superior.
*)
		function mejorpivote( q, kmax: integer; var fantasma: boolean ): integer;

(*
Suponiendo que se ha encontrado un estado FACTIBLE ( a(k, n) >=0 ,k=1..m-1 )
El resultado es:
	1 si el paso fue dado exitosamente
	0 si ya no hay más pasos para dar (ya es óptimo)
	-1 no se encontró un pivote bueno para dar el paso, PROBLEMA NO ACOTADO
*)
		function darpaso: integer;

(*
Chequeo de factibiblidad, retorna true si el estado actual es factible,
false en caso contrario.
*)
		function primerainfactible: integer;

(*
Reordenar para poner las factibles primero´
retorna el número de infactibles
*)
		function reordenarPorFactibilidad: integer;


(*
Intercambia las filas y los indices de left
*)
		procedure IntercambioFilas( k1, k2: integer );

(*
Intercambia las columnas y los indices de top
*)
		procedure IntercambioColumnas( j1, j2: integer );


(*
Búsqueda de punto factible
*)
	function pasoBuscarFactible: integer;

(*
	Búsqueda de punto factible intentando resolver la restricción de igualdad ifila
*)
	function pasoBuscarFactibleIgualdad( ifila: integer ): integer;

(*
	Busca un pivote bueno entre las columnas [1..jhasta]
	para solucionar la funcion objetivo de la fila p siendo jti la columna
	de los términos independientes. Esta función se utiliza en la búsqueda
	de la factibilidad donde la función objetivo es la primer restricción violada
 *)
	function locate_qOK( p, jhasta, jti : integer ): integer;


	function test_qOK( p, q, jti: integer ; var apq: NReal ): boolean;



(*
	Fija las variables declaradas como constantes.
*)
	procedure FijarVariables;

(*
	Reordena el sistema poniendo las filas correspondientes a restricciones de
	igualdad encima de todo.
	Busca volverlas factibles de a una y en la medida en que logra que una
	restricción de igualdad quede en una columna reordena las columnas para fijar
	esa columna.
*)
	function ResolverIgualdades: integer;


(*
	Busca el indice de la celda de mayor valor absoluto.
	La búsqueda se realiza entre j= 1 y j=jmax
	Si ningun valor supera en valor abosoluto a AsumaCero el resultado
	es -1.
*)
	function locate_maxabs( p, jmax: integer ): integer;



(*
	Busca la fila correspondiente a una x cuya restricción de cota superior
	es violada.
	Retorna -1 si no encuentra ninguna en esas condiciones, sino retorna el
	índice de la fila.
*)
function primer_cota_sup_violada: integer;

(*
	Realiza el cambio de cota (superio <-> inferior) considerada para la
	variable x asociada a la fila k_fila del sistema y cuya cota superior
	está siendo violada. Se supone que k_fila es el resultado a una
	llamada a "primer_cota_sup_violada" y que por lo tanto realmente identifica
	una fila que está representando una variable x (o x'= x_sup-x ) cuya cota
	superior está siendo violada.
*)
procedure cambiar_borde_de_caja( k_fila: integer);



(*
	Estas funciones actualizan los índices directos en función del contenido
	de los indices inversos left y top
*)
procedure Actualizo_iileft( k : integer );
procedure Actualizo_iitop( k : integer );


(*
	Si q es el índice de una columna que está asociada a una variable del
	tipo x , y esa variable tiene cota superior, realiza el cambio de variable
	en la columna.
*)
function cambio_var_cota_sup_en_columna( q: integer ): boolean;



(* Fijamos que la restricción kfila es de igualdad *)
	procedure FijarRestriccionIgualdad( kfila: integer );

(*
	Fija el valor de una variable. Esto permite escribir las ecuaciones
	considerando la variable pero luego imponerle un valor
*)
	procedure FijarVariable( ivar: integer; valor: NReal );

// método para menejo de las restricciones de caja
(*
	Fija el valor de la cota inferior
*)
	procedure cota_inf_set( ivar: integer; vxinf: NReal );

(*
	Fija el valor de la cota superior
*)
	procedure cota_sup_set( ivar: integer; vxsup: NReal );


(*
Gatilla un cambio de variable de cota superior para se ejecutado
antes de comenzar a resolver el problema.
Esto se previó para poder indicar que se realicen algunos cambios de variables
antes de comenzar la búsqueda de factibilidad y permitir que si el usuario
sabe que mejora la búsqueda un determinado cambio lo gatille antes de comenzar.
*){$IFDEF GATILLOS_CAMBIOVAR}
procedure GatillarCambioVarCotaSup( q: integer );
{$ENDIF}

(*
	Funciones auxiliares para leer los resultados
*)
function xval( ix: integer ): NReal; virtual;
function yval( iy: integer ): NReal; virtual;
function xmult( ix: integer ): NReal;virtual;
function ymult( iy: integer ): NReal;virtual;
function fval: NReal;virtual;


{$IFDEF SPXCONLOG}
(*
	Funciones para debug
*)
	procedure clearlog;
	procedure writelog( s: string );
	procedure set_NombreVar( ivar: integer; xnombre: string );
	procedure set_NombreRest( irest: integer; xnombre: string );
	// escribe el sistema entero para poder hacer dbug
	procedure appendWriteXLT( texto: string; var cnt_llamadas: integer; reescribir: boolean );
{$ENDIF}

	procedure DumpSistemaToXLT( archi: string; InfoAdicional: string );


(*
	Busca un punto de arranque factible y si lo encuentra maximiza la función fval
	El resultado es 0 si logró encontrar un punto factible y realizar la maximización
	si no se puede resolver el resultado es <> 0 y se guarda en la variable
	"MensajeDeError" del objeto la causa encontrada.
	*)
	function resolver: integer; virtual;

(*
	Limpia todo el sistema y lo preprara para recibir un nuevo problema.
*)
	procedure limpiar;


(*
	Esta función se define, pero no se implementa en este simplex.
	Se implementa en TMIPSimplex, aquí se introduce por comodidad de escritura
	del código.
	*)
	procedure set_entera( ivae, ivar: integer; CotaSup: integer ); virtual; abstract;
end;


var
	cnt_debug: integer;

implementation


procedure TSimplex.DumpSistemaToXLT( archi: string; InfoAdicional: string );
var
	f: textfile;
	kvar: integer;
	k, j: integer;

begin
	archi:= DateTimeToStr( now ())+archi;
	while pos( '/', archi ) > 0 do
		archi[pos('/', archi )]:= '-';
	while pos( ':', archi ) > 0 do
		archi[pos(':', archi )]:= '-';

	assign( f, archi );
	rewrite( f );
	writeln( f, 'InfoAdicional: ', InfoAdicional );

{$IFDEF SPXCONLOG}
	writeln( f, '*****************************' );
	write( f, 'x: ' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, nombreVars[kvar] );
	writeln( f );

	write( f, 'x_inf:' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, x_inf.pv[kvar]:8:2 );
	writeln( f );

	write( f, 'x_sup:' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, x_sup.pv[kvar]:8:2 );
	writeln( f );

	write( f, 'flg_x:' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, flg_x[kvar] );
	writeln( f );

	write( f, 'flg_y:' );
	for kvar:= 1 to nf - 1 do
		write( f, #9, flg_y[kvar] );
	writeln( f );

	writeln( f, '----------------------' );
	writeln( f, 'sistema --------------');
	writeln( f, '......................');

	// encabesados de las columnas
	write( f, '-' );
	for j:= 1 to nc -1 do
		if top[j] < 0 then
			write( f, #9, nombreVars[-top[j] ] )
		else
			write( f, #9, nombreRest[top[j] ] );
	writeln( f, #9, 'ti' );

	// filas ecuaciones >= 0
	for k:= 1 to nf -1 do
	begin
		if left[k] > 0 then
			write( f, nombreRest[left[k]] )
		else
			write( f , nombreVars[-left[k]] );
		for j:= 1 to nc do
			write( f, #9, e(k, j):8:2 );
		write( f, #9, '>= 0' );
		if left[k] < 0 then
			if flg_x[ -left[k] ] <> 0 then
				write( f, #9,' <= ', x_sup.pv[-left[k]]:8:2 );
		writeln( f );
	end;
{$ELSE}
	writeln( f, '*****************************' );
	write( f, 'x: ' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, 'x'+IntToStr(kvar) );
	writeln( f );

	write( f, 'x_inf:' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, x_inf.pv[kvar]:8:2 );
	writeln( f );

	write( f, 'x_sup:' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, x_sup.pv[kvar]:8:2 );
	writeln( f );

	write( f, 'flg_x:' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, flg_x[kvar] );
	writeln( f );

	write( f, 'flg_y:' );
	for kvar:= 1 to nf - 1 do
		write( f, #9, flg_y[kvar] );
	writeln( f );

	writeln( f, '----------------------' );
	writeln( f, 'sistema --------------');
	writeln( f, '......................');

	// encabesados de las columnas
	write( f, '-' );
	for j:= 1 to nc -1 do
		if top[j] < 0 then
			write( f, #9, 'x'+IntToStr(-top[j]) )
		else
			write( f, #9, 'y'+IntToStr(top[j] ));
	writeln( f, #9, 'ti' );

	// filas ecuaciones >= 0
	for k:= 1 to nf -1 do
	begin
		if left[k] > 0 then
			write( f, 'y'+IntToStr(left[k]) )
		else
			write( f , 'x'+IntToStr(-left[k]) );
		for j:= 1 to nc do
			write( f, #9, e(k, j):8:2 );
		write( f, #9, '>= 0' );
		if left[k] < 0 then
			if flg_x[ -left[k] ] <> 0 then
				write( f, #9,' <= ', x_sup.pv[-left[k]]:8:2 );
		writeln( f );
	end;

{$ENDIF}
	// ultima fila (función a maximizar )
	write( f, 'max:' );
	for j:= 1 to nc do
			write( f, #9, e(nf,j):8:2 );
	writeln( f );

	closefile( f );
end;

{$IFDEF SPXCONLOG}
procedure TSimplex.appendWriteXLT( texto: string; var cnt_llamadas: integer;  reescribir: boolean );
var
	f: textfile;
	kvar: integer;
	k, j: integer;

begin
	assign( f, 'simplex.xlt' );
	if reescribir then
		rewrite( f)
	else
	begin
		{$I-}
		append( f );
		{$I+}
		if ioresult <> 0 then
			rewrite(f );
	end;

	writeln( f, '*****************************' );
	writeln( f, texto,#9,'cnt_llamadas:', cnt_llamadas );
	inc( cnt_llamadas );
	write( f, 'x: ' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, nombreVars[kvar] );
	writeln( f );

	write( f, 'x_inf:' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, x_inf.pv[kvar]:8:2 );
	writeln( f );

	write( f, 'x_sup:' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, x_sup.pv[kvar]:8:2 );
	writeln( f );

	write( f, 'flg_x:' );
	for kvar:= 1 to nc - 1 do
		write( f, #9, flg_x[kvar] );
	writeln( f );

	write( f, 'flg_y:' );
	for kvar:= 1 to nf - 1 do
		write( f, #9, flg_y[kvar] );
	writeln( f );

	writeln( f, '----------------------' );
	writeln( f, 'sistema --------------');
	writeln( f, '......................');

	// encabesados de las columnas
	write( f, '-' );
	for j:= 1 to nc -1 do
		if top[j] < 0 then
			write( f, #9, nombreVars[-top[j] ] )
		else
			write( f, #9, nombreRest[top[j] ] );
	writeln( f, #9, 'ti' );

	// filas ecuaciones >= 0
	for k:= 1 to nf -1 do
	begin
		if left[k] > 0 then
			write( f, nombreRest[left[k]] )
		else
			write( f , nombreVars[-left[k]] );
		for j:= 1 to nc do
			write( f, #9, e(k, j):8:2 );
		write( f, #9, '>= 0' );
		if left[k] < 0 then
			if flg_x[ -left[k] ] <> 0 then
				write( f, #9,' <= ', x_sup.pv[-left[k]]:8:2 );
		writeln( f );
	end;

	// ultima fila (función a maximizar )
	write( f, 'max:' );
	for j:= 1 to nc do
			write( f, #9, e(nf,j):8:2 );
	writeln( f );

	closefile( f );
end;
procedure TSimplex.clearlog;
var
	f: textfile;
begin
	assignfile( f, 'simplex.xlt' );
	rewrite(f );
	closefile(f );
end;


procedure TSimplex.writelog( s: string );
var
	f: textfile;
begin
	assignfile( f, 'simplex.xlt' );
	{$I-}
	append( f );
	{$I+}
	if ioresult <> 0 then
		rewrite(f );
	writeln(f, s );
	closefile( f );
end;



procedure TSimplex.set_nombreVar( ivar: integer; xnombre: string );
begin
	nombreVars[ivar]:= xnombre;
end;

procedure TSimplex.set_nombreRest( irest: integer;  xnombre: string );
begin
	nombreRest[irest]:= xnombre;
end;

{$ENDIF}

function TSimplex.xval( ix: integer ): NReal;
var
	k: integer;
	res: NReal;
begin
	k:= iix[ix];
	if k > 0 then
	begin
		if flg_x[ix] >= 0 then
			res:= 0
		else
			res:= x_sup.pv[ix];
	end
	else
	begin
		if flg_x[ix] >= 0 then
			res:= e( -k, nc )
		else
			res:= x_sup.pv[ix]-e( -k, nc );
	end;

	if x_inf.pv[ix] <> 0 then
		res:= res + x_inf.pv[ix];
	result:= res;
end;

function TSimplex.yval( iy: integer ): NReal;
var
	k: integer;
	res: NReal;
begin
	k:= iiy[iy];
	if k < 0 then
		res:= 0
	else
		res:= e( k, nc );
	result:= res;
end;

function TSimplex.xmult( ix: integer ): NReal;
var
	k: integer;
	res: NReal;
begin
	k:= iix[ix];
	if k > 0 then
		if flg_x[ix] >= 0 then
			res:= e( nf, k )
		else
			res:= -e( nf, k )
	else
		res:= 0;
	result:= res;
end;


function TSimplex.ymult( iy: integer ): NReal;
var
	k: integer;
	res: NReal;
begin
	k:= -iiy[iy];
	if k > 0 then
		if flg_y[iy] >= 0 then
			res:= pm[ nf].pv[ k ]
		else
			res:= -pm[ nf].pv[ k ]
	else
		res:= 0;
	result:= res;
end;

function TSimplex.fval: NReal;
begin
	result:= pm[nf].pv[nc];
end;



procedure TSimplex.IntercambioColumnas( j1, j2: integer );
var
	k: integer;
	m: NReal;
	fila: TVectR;
begin
	for k:= 1 to nf do
	begin
		fila:= pm[k];
		m:= fila.pv[ j1 ];
		fila.pv[j1]:= fila.pv[j2];
		fila.pv[j2]:= m;
	end;

	k:= top[j1];
	top[j1]:= top[j2];
	top[j2]:= k;

	Actualizo_iitop( j1 );
	Actualizo_iitop( j2 );

end;


function TSimplex.locate_maxabs( p, jmax: integer ): integer;
var
	fila: TDAOfNReal;
	m, maxabs: NReal;
	j, jdelmax: integer;
begin
	fila:= pm[p].pv;
	maxabs:= AsumaCero;
	jdelmax:= -1;
	for j:= 1 to jmax do
	begin
		m:= abs( fila[j] );
		if m > maxabs then
		begin
			maxabs:= m;
			jdelmax:= j;
		end;
	end;
	result:= jdelmax;
end;


(*
procedure TSimplex.FijarNIgualdades( cnt_Igualdades: integer );
begin
	if cnt_igualdades > (nf-1) then
		raise Exception.Create('Intentó fijar la cantidad de igualdades mayor al número total de restricciones.');
	Self.cnt_igualdades:= cnt_Igualdades;
end;
	*)

procedure TSimplex.FijarRestriccionIgualdad( kfila: integer );
begin
	inc( cnt_igualdades );
	flg_y[kfila]:= 2;
end;



procedure TSimplex.FijarVariables;
var
	k: integer;
{	q: integer;
	res: integer;   }
	buscando: boolean;
	cnt_fijadas: integer;
 {	cnt_acomodadas: integer;
	ifila: integer;  }
   kPrimeraLibre: integer;

begin


	if ( cnt_varfijas > 0 ) then
	begin
		cnt_fijadas:= 0;
		kPrimeraLibre:= nc-1;
			k:= 1;

      while ( cnt_fijadas < cnt_varfijas ) do
      begin
		   while ( cnt_fijadas < cnt_varfijas ) and (flg_x[kPrimeraLibre] = 2) do
         begin
            inc( cnt_fijadas );
            dec( kPrimeraLibre );
         end;
         if (cnt_fijadas < cnt_varfijas ) then
         begin
            buscando:= true;
			   while buscando and ( k < kPrimeraLibre ) do
				   if	flg_x[k]= 2 then
						 buscando:= false
				   else
					   inc( k );
			   if buscando then
               raise Exception.Create('Error del simplex, fijando variables ABSURDO');
			   inc( cnt_fijadas );
			   intercambioColumnas( k, kPrimeraLibre );
            dec(kPrimeraLibre);
            inc( k );
         end;
		end;
	end;




(***
	if ( cnt_varfijas > 0 ) then
	begin
		cnt_fijadas:= 0;
		k:= 1;
		while ( cnt_fijadas < cnt_varfijas ) do
		begin
			buscando:= true;
			while buscando and ( k < (nc-cnt_fijadas) ) do
				if 	flg_x[k]= 2 then
					buscando:= false
				else
					inc( k );
			if buscando then raise Exception.Create('Error del simplex, fijando variables ABSURDO');
			inc( cnt_fijadas );
			intercambioColumnas( k, (nc-cnt_fijadas ));
		end;
	end;
	 ***)
end;




function TSimplex.ResolverIgualdades: integer;
var
	k: integer;
//	q: integer;
	res: integer;
	buscando: boolean;
//	cnt_fijadas: integer;
	cnt_acomodadas: integer;
	ifila: integer;

begin
	// ahora reordeno las igualdades y las pongo al inicio
	cnt_acomodadas:= 0;

	while cnt_acomodadas < cnt_Igualdades do
	begin
		if abs(flg_y[1+cnt_acomodadas])= 2 then
			inc( cnt_acomodadas )
		else
		begin
			buscando:= true;
			for k:= 2+cnt_acomodadas to nf-1 do
				if abs(flg_y[k])= 2 then
				begin
					ifila:= k;
					buscando:= false;
					break;
				end;
			Assert(not buscando, 'Simplex.ResolverIgualdades - Absurdo reordenando igualdades');
			intercambioFilas(1+cnt_acomodadas, ifila );
			inc( cnt_acomodadas );
		end;
	end;


	ifila:= 1;
	res:= 1;
	while ifila <= cnt_igualdades  do
	begin
		res:= pasoBuscarFactibleIgualdad( ifila );
		case res of
			0: begin
					mensajeDeError:= 'PROBLEMA INFACTIBLE - Resolviendo igualdades.';
					result:= -10;
					exit;
				end;
			-1: begin
					mensajeDeError:= 'NO encontramos pivote bueno - Resolviendo igualdades.';
					result:= -11;
					exit;
					end;
			-2: begin
				mensajeDeError:= '???cnt_infactibles= 0 - Resolviendo igualdades.';
				result:= -12;
				exit;
				end;
			1: inc( ifila );
		else
			raise Exception.Create('OJOResolverIgualdades: pasoBuscarFactibleIgualdad retorno algo no espeardo, res:'+IntToStr(res ));
		end;
	end;
	result:= res;
end;


procedure TSimplex.limpiar;
var
	k : integer;
begin
{$IFDEF GATILLOS_CAMBIOVAR}
      gatillos_no_procesados:= true;
{$ENDIF}
		cnt_paso:= 0;

		mensajeDeError:= '???';
{$IFDEF SPXCONLOG}
		Self.dbg_on:= true;
		if dbg_on then
		begin
			for k:= 1 to nc-1 do
				nombreVars[k]:= 'x'+IntToStr( k );
			for k:= 1 to nf-1 do
				nombreRest[k]:= 'y'+IntToStr( k );
		end;
{$ENDIF}
		for k:= 1 to nc-1 do
		begin
			top[k]:= -k;
			iix[k]:= k;
			flg_x[k]:= 0;
		end;
{$IFDEF GATILLOS_CAMBIOVAR}
		cnt_Gatillos:= 0;
{$ENDIF}

		for k:= 1 to nf-1 do
		begin
			left[k]:= k;
			iiy[k]:= k;
			flg_y[k]:= 0;
		end;
		x_inf.Ceros;
		x_sup.Ceros; // creo que no es necesario
		cnt_infactibles:= 0;
		cnt_igualdades:= 0;
		cnt_cotas_inf:= 0;
		cnt_cotas_sup:= 0;
		cnt_varfijas:= 0;
		self.Ceros;
end;


constructor TSimplex.Create_init( m, n : integer );
{var
	k: integer;     }
begin
		inherited Create_init( m, n );
		cnt_resolver:= 0;


{$IFDEF SPXCONLOG}
		setlength( nombreVars, 0 );
		setlength( nombreRest, 0 );
		Self.dbg_on:= true;
{$ENDIF}

		x_inf:= TVectR.Create_Init( n -1 );
		x_sup:= TVectR.Create_Init( n -1 );

		setlength(flg_x, n );
		setlength(flg_y, m );

		setlength(top, n+1 );
		setlength( left, m+1 );
		setlength( iix, n+1 );
		setlength( iiy, m+1 );
{$IFDEF GATILLOS_CAMBIOVAR}
		setlength( gatillos_CambioVar, n );
{$ENDIF}

{$IFDEF SPXCONLOG}
		if dbg_on then
		begin
			setlength( nombreVars, n );
			setlength( nombreRest, m );
		end;
{$ENDIF}

	limpiar;
end;


constructor TSimplex.Create_clone( spx: TSimplex );
begin
		inherited Create_Clone( spx );
		mensajeDeError:= '';
		cnt_resolver:= 0;
      cnt_paso:= 0;
{$IFDEF SPXCONLOG}
		dbg_on:= spx.dbg_on;
		sdbg:= '';
		nombreVars:= copy(spx.nombreVars);
			nombreRest:= copy(spx.nombreRest);
{$ENDIF}
		top:= copy(spx.top);
      left:= copy( spx.left);
		iix:= copy( spx.iix);
		iiy:= copy( spx.iiy );

		cnt_infactibles:= spx.cnt_infactibles;
		cnt_igualdades:= spx.cnt_igualdades;
		cnt_varfijas:= spx.cnt_varfijas;

		cnt_cotas_inf:= spx.cnt_cotas_inf;
      cnt_cotas_sup:= spx.cnt_cotas_sup;

			x_inf:=  TVectR.Create_clone( spx.x_inf );
      x_sup:= TVectR.Create_clone( spx.x_sup );
		flg_x:= copy( spx.flg_x );
      flg_y:= copy( spx.flg_y );
{$IFDEF GATILLOS_CAMBIOVAR}
		cnt_Gatillos:= spx.cnt_Gatillos;
		gatillos_CambioVar:= copy( spx.gatillos_CambioVar );
      gatillos_no_procesados:= spx.Gatillos_no_procesados;
{$ENDIF}

end;

procedure TSimplex.cota_inf_set( ivar: integer; vxinf: NReal );
var
	kfila: integer;
	 old_cotainf: NReal;
begin
   old_cotainf:= x_inf.pv[ivar];
	x_inf.pv[ivar]:= vxinf;
   if ( old_cotainf <> 0 ) then
   begin
      // si ya había impuesto una cota y la estoy cambiando
      // deshago el cambio
      if vxinf= 0 then
				 dec( cnt_cotas_inf );
      vxinf:= vxinf - old_cotainf;
   end
   else
   	inc( cnt_cotas_inf );

	// hacemos el cambio de variables
	for kfila:= 1 to nf do
		acum_e( kfila, nc, e(kfila, ivar )* vxinf);

	// me fijo si ya fue fijada una cota superior para esta variable
	// la cambio para reflejar la nueva cota para la nueva variable
	if ( flg_x[ivar] <> 0 ) then
		x_sup.pv[ivar]:= x_sup.pv[ivar] - vxinf;

end;


procedure TSimplex.cota_sup_set( ivar: integer; vxsup: NReal );
begin
   if flg_x[ivar] = 0 then
	 begin
   	x_sup.pv[ivar]:= vxsup;
	   inc( cnt_cotas_sup );
		flg_x[ivar]:= 1;
   	if ( x_inf.pv[ivar] <> 0 ) then // si fue fijada una cota inferior no nula la tengo en cuenta
	   	x_sup.pv[ivar]:= x_sup.pv[ivar] - x_inf.pv[ivar];
   end
   else
   begin // ya tiene fijada cota sup la cambio
   	x_sup.pv[ivar]:= vxsup;
   	if ( x_inf.pv[ivar] <> 0 ) then // si fue fijada una cota inferior no nula la tengo en cuenta
	   	x_sup.pv[ivar]:= x_sup.pv[ivar] - x_inf.pv[ivar];
   end;
end;


procedure TSimplex.FijarVariable( ivar: integer; valor: NReal );
begin
   if flg_x[ivar] <> 2 then
   begin
		cota_inf_set( ivar, valor );
	   inc( cnt_varfijas );
   	flg_x[ivar]:= 2;
      x_sup.pv[ivar]:= 0;
   end
	 else
   	cota_inf_set( ivar, valor );
end;


{$IFDEF GATILLOS_CAMBIOVAR}
procedure TSimplex.GatillarCambioVarCotaSup( q: integer );
begin
	inc( cnt_Gatillos );
	gatillos_CambioVar[cnt_Gatillos]:= q;
end;
{$ENDIF}

procedure TSimplex.Free;
begin
		setlength( top, 0 );
		setlength( left, 0 );
		setlength( iix, 0 );
		setlength( iiy, 0 );

		x_inf.Free;
		x_sup.Free;
		setlength(flg_x, 0 );
		setlength(flg_y, 0 );
{$IFDEF GATILLOS_CAMBIOVAR}
		setlength( gatillos_cambioVar, 0 );
{$ENDIF}

{$IFDEF SPXCONLOG}
		setlength( nombreVars, 0 );
		setlength( nombreRest, 0 );
{$ENDIF}

		inherited Free;
end;



procedure TSimplex.combinax( kdest, korg, jini, jfin: integer; m :NReal );
var
	j: Integer;
	forg, fdest: TVectR;
begin
	if abs(m) > AsumaCero then
	begin
		forg:= pm[korg];
		fdest:= pm[kdest];

		for j:= jini to jfin do
			fdest.pv[j]:= fdest.pv[j] + m * forg.pv[j];
	end;
end;

procedure TSimplex.intercambiar( kfil, jcol: integer );
var
	 m: NReal;
	 k, j: integer;
	filak: TVectR;
begin

		for k:= 1 to kfil -1 do
		 begin
					m:= e( k, jcol ) / e(kfil, jcol );
			 combinax( k, kfil, 1, jcol-1, -m );
					pon_e( k, jcol, m);
			 combinax( k, kfil, jcol+1, nc, -m );
		end;

		for k:= kfil +1 to nf do
		begin
			 m:= e( k, jcol ) / e(kfil, jcol );
					combinax( k, kfil, 1, jcol-1, -m );
			 pon_e( k, jcol, m);
					combinax( k, kfil, jcol+1, nc, -m );
		end;

		filak:= pm[ kfil ];
		m:= -1 / e(kfil, jcol );
		 for j:= 1 to jcol -1 do
			filak.pv[j]:= filak.pv[j]*m;
		 pon_e(kfil, jcol, -m);
		for j:= jcol +1 to nc do
				 filak.pv[j]:= filak.pv[j]*m;

{$IFDEF SPXCONLOG}
		if dbg_on then
		begin
			sdbg:= 'Intecambio fila: '+IntToStr( kfil) ;
			if left[kfil] > 0 then
				sdbg:= sdbg+'y('+nombreRest[left[kfil]]+')'
			else
				sdbg:= sdbg+'x('+nombreVars[-left[kfil]]+')';

			sdbg:= sdbg+' con columna: '+IntToStr( jcol );

			if top[jcol] > 0 then
				sdbg:= sdbg+'y('+nombreRest[top[jcol]]+')'
			else
				sdbg:= sdbg+'x('+nombreVars[-top[jcol]]+')';
			writelog( sdbg );
		end;
{$ENDIF}

		k:= top[jcol];
		top[jcol]:= left[kfil];
		left[kfil]:= k;

		Actualizo_iitop( jcol );
		Actualizo_iileft( kfil );

end;


(*
buscamos una columna en que en la ultima fila (fila z ) el valor es positivo
retorna el número de columna si lo encontro, -1 si son todos < 0
*)
function TSimplex.locate_zpos( kfila_z : integer; jini: integer): integer;
var
	j: integer;
	ires: integer;
	filaz: TDAOfNReal;

	maxval: NReal;
begin
		filaz:= pm[kfila_z].pv; // apunto a la ultima fila
		ires:= -1;

		maxval:= 0;
//rch 6/12/2006 le agrego restar las fijas e igualdades ??? ojo hay que pensar
//rch y pa 070329 agregamos lo de maxval

		for j:=jini to nc-1 -(cnt_varfijas+cnt_igualdades) do
			if filaz[j] > maxval then
			begin
				maxval:= filaz[j];
				ires:= j;
			end;
		result:= ires;
end;




function TSimplex.mejorpivote( q, kmax: integer; var fantasma: boolean ): integer;
var
	i, p: integer;
	aiq, b_: NReal;
	a_max, b_max: NReal;
	ix: integer;
	xfantasma: boolean;
//	max_ccp, ccp: NReal;
begin
//		i:= 1;
//		max_ccp:= 0;
(*
11/9/2006 le voy a agregar para que si la q corresponde a una x con manejo
de cota superior considere la existencia de una fila adicional correspondiente
a la cota superior.
Dicha fila tiene un -1 en la coluna q y el valor x_sup como término independiente
*)

(* rch.30/3/2007 Agrego el manejo del CasiCero_Simplex *)

		ix:= -top[q];
		if (ix > 0) and ( flg_x[ix] <> 0 ) then
		begin  // en la columna q hay una x con manejo de cota superior
			p:= kmax+1;
			a_max:= -1;
			b_max:= x_sup.pv[ix];
			fantasma:= true;
		end
		else
		begin
			p:= -1;
			b_max:= 0;
			a_max:= 1;
			fantasma:= false;
		end;

		for i:= 1 to kmax do
		begin
			 aiq:= e( i, q );

			 if aiq > CasiCero_Simplex then
			 begin
					ix:= -left[i];
					if (ix > 0) and ( flg_x[ix] <> 0 ) then //aiq tiene cota superior, hay que hacer el cambio de variable
					begin
						aiq:= -aiq;
						b_:= x_sup.pv[ix]- e(i, nc );
						xfantasma:= true;
					end;
			 end
			 else
				if aiq < -CasiCero_Simplex  then
				begin
						b_:=e( i, nc );
						xfantasma:= false;
				end
					else
						pon_e(i, q, 0); // imponemos el cero para que no ande haciendo macanas
					//	pon_e(i,nc,0); // imponemos el cero para que no ande haciendo macanas

			 if aiq < -CasiCero_Simplex then //considero el coeficiente para elegir el pivote
			 begin
					if (p < 0 ) or ((b_* a_max) > (b_max* aiq )) then
					begin
						a_max:= aiq;
						b_max:= b_;
						p:= i;
						fantasma:= xfantasma;
					end
			 end;
		 end;

		if p > kmax then p:= -3; // indicamos que es virtual
		result:= p;
end;

function TSimplex.pasoBuscarFactibleIgualdad( ifila: integer ): integer;
var
	p, q: integer;
	res: integer;
	 rval: NReal;
//	 ix: integer;
	fantasma: boolean;
	ultimaColumnaAConsiderar: integer;
begin
	res:= 1;
	p:= ifila;

	rval:=e(p, nc );
	if ( rval > 0 ) then // le cambiamos el signo
	begin
		fila(ifila).PorReal(-1 );
		flg_y[ left[ifila] ]:= - flg_y[left[ifila]];
	end;

(*
	 Primero probamos si solucionamos la infactibildad con un intercambio
	 de la infactible con una de las Activas.
*)
	ultimaColumnaAConsiderar:= nc -(cnt_varfijas+ifila-1) -1;
	q:=locate_qOK( p, ultimaColumnaAConsiderar, nc  );
	if q > 0 then
	begin
		intercambiar( p, q );
		if q < ultimaColumnaAConsiderar then
			IntercambioColumnas( q, ultimaColumnaAConsiderar );
		result:= 1;
		exit;
	end;


(*
	Si no se solucionó cambiando la misma fila infactible,
	nos planteamos el problema de optimización con objetivo el
	valor de la restricción violada.
*)
	q:= locate_zpos(ifila, 1);
	if q > 0 then
	begin
		p:= mejorpivote( q, ifila-1, fantasma );
		if p > 0 then
		begin
			intercambiar( p, q );
			if fantasma then	cambio_var_cota_sup_en_columna( q );
		end
		else
		begin
			if p=-3 then
			begin
				cambio_var_cota_sup_en_columna( q );
				res:= 1;
			end
			else res:= -1; //ShowMessage('No encontre pivote bueno ');
		end;
	end
	else
		res:= 0; //	ShowMessage('No encontre z - positivo ' );

	result:= res;
end;

function TSimplex.pasoBuscarFactible: integer;
var
	p, q: integer;
	res: integer;
   rval: NReal;
   ix: integer;
	fantasma: boolean;
begin
	res:= 1;
	p:=nf-cnt_infactibles;

	rval:=e(p, nc );

(* OJO LE AGREGO ESTE CHEQUEO PARA PROBAR **)
   // si parece satisfecha verifico que no se esté vilándo la  fantasma
	if (rval > 0 ) and (left[p] < 0) then
	begin
		ix:= -left[p];
		if flg_x[ix] <> 0 then
			if x_sup.pv[ix] < rval then
			begin
				cambiar_borde_de_caja(  p );
				rval:=e(p, nc );
			end
	end;

	if ( rval >= 0 ) then
	begin
		// ya es factible, probablemente se arregló con algún cambio anterior.
		dec( cnt_infactibles );
		result:= 1;
		exit;
	end;


(*
	Nos planteamos el problema de optimización con objetivo el
	valor de la restricción violada.
*)
	if cnt_infactibles > 0  then
	begin
		q:= locate_zpos(nf-cnt_infactibles, 1);
		if q > 0 then
		begin
		 p:= mejorpivote( q, nf-cnt_infactibles-1, fantasma );
		 if p > 0 then
		 begin
				intercambiar( p, q );
				if fantasma then	cambio_var_cota_sup_en_columna( q );
				if ( e( nf-cnt_infactibles, nc) >= 0 ) then
					dec( cnt_infactibles );
		 end
		 else
		 begin
				if p=-3 then
				begin
					cambio_var_cota_sup_en_columna( q );
					res:= 1;
				end
				else res:= -1; //ShowMessage('No encontre pivote bueno ');
		 end;
		end
		else
			res:= 0; //	ShowMessage('No encontre z - positivo ' );
	end
	else
		res:= -2;

	if res= -1 then
	begin
		(*
	 Pruebo si soluciono la infactibildad con un intercambio
	 de la infactible con una de las Activas.
		*)
//rch 6/12/2004 agrego la resta de las cnt_varfijas+cnt_igualdades ???? ojo revisar
		q:=locate_qOK( p, nc -(cnt_varfijas+cnt_igualdades) -1, nc  );
		if q > 0 then
		begin
			intercambiar( p, q );
			dec( cnt_infactibles );
			res:= 1;
		end;
	end;

	result:= res;
end;

function TSimplex.cambio_var_cota_sup_en_columna( q: integer ): boolean;
var
	ix: integer;
	res: boolean;
	kfil: integer;
	xsup: NReal;
begin
	res:= false;
	ix:= -top[q];
	if ( ix > 0 ) then // corresponde a una x, me fijo si tiene cota sup
	begin
		if flg_x[ix] <> 0 then
		begin // cambio de variable en la misma columna
			flg_x[ix]:= -flg_x[ix];
			xsup:= x_sup.pv[ix];
			for kfil := 1 to nf do
			begin
				pm[kfil].pv[nc] := pm[kfil].pv[nc] + pm[kfil].pv[q] * xsup;
				pm[kfil].pv[q] := -pm[kfil].pv[q];
			end;
			res:= true;

{$IFDEF SPXCONLOG}
			if dbg_on then
			begin
				sdbg:= 'cambio_cota_sup_en_columna x: '+nombreVars[ix]+' flg_x: '+IntToStr( flg_x[ix] );
				writelog( sdbg );
			end;
{$ENDIF}
		end;
	end;
	result:= res;
end;

(*
Esta función retorna true si la columna q soluciona la infactibilidad
de la fila p. Se supone que (jti) es la columna de los términos constantes
(generalmente la nc ) la dejamos como parámetro por si es necesario

El valor retornado apq, es e(p,q) y puede usarse para
elegir el q que devuelva el valor más grande para disminuir los
errores numéricos.

*)
function TSimplex.test_qOK( p, q, jti: integer ; var apq: NReal ): boolean;
var
	resOK: boolean;
	k: integer;
	alfa_p, akq: NReal;
	nuevo_ti: NReal;
	ix: integer;
begin
	resOK:= true;
	apq:= e(p,q);
	if ( apq <= AsumaCero ) then
	begin
		result:= false;
		exit;
	end;
	alfa_p:= -e( p, jti ) / apq;
	ix:=-top[ q ];
	if  ix > 0 then // la col q es una x
		if flg_x[ix] <> 0 then	// tiene manejo de cotasup
			if alfa_p > x_sup.pv[ix] then
			begin // de intercambiar esta columna se violaría la cotas superior
				result:= false;
				exit;
			end;


	for k:= 1 to p-1 do
	begin
		akq:=e(k,q );
		nuevo_ti:= e(k,jti) + akq * alfa_p;
		if nuevo_ti < 0 then
		begin
			resOK:= false;
			break;
		end
		else
		begin
			ix:= -left[k];
			if ( ix > 0 ) and ( flg_x[ix] <> 0 ) then
				if nuevo_ti > x_sup.pv[ix] then
				begin
					resOK:= false;
					break;
				end;
		end;
	end;

	result:= resOK;
end;


function TSimplex.locate_qOK( p, jhasta, jti : integer ): integer;
var
	mejorq, q: integer;
	max_apq, apq: NReal;
begin
	mejorq:= -1;
	max_apq:= -1;
	for q:= 1 to jhasta do
		if	test_qOK( p, q, jti, apq ) then
			if ( mejorq < 0 ) or ( apq > max_apq ) then
				begin
					mejorq:= q;
					max_apq:= apq;
				end;
	result:= mejorq;
end;

function TSimplex.primer_cota_sup_violada: integer;
var
	ix: integer;
	k: integer;
	buscando: boolean;
begin
	k:= 1;
	buscando:= true;
	while (k < (nf-1)) and buscando do
	begin
		if left[k] < 0 then // es una x que fue puesta como fila
		begin
			ix:= -left[k];
			if flg_x[ix] <> 0 then // hay cota sup verifico
				if e( k, nc ) > x_sup.pv[ix] then
					buscando:= false;
		end;
		if buscando then inc( k );
	end;
	if buscando then
		result:= -1
	else
		result:= k;
end;


procedure TSimplex.cambiar_borde_de_caja( k_fila: integer);
var
	ix: integer;
	xpv: TVectR;
	k: integer;
begin
	(*
		Realizamos el cambio de variable x'= x_sup - x para que la restricción
		violada sea representada por x' >= 0
		Observar que para la nueva variable la restricción x >= 0 se transforma
		en x' <= x_sup. Es decir que la cota superior de x' es también x_sup.
	*)

	ix:= -left[ k_fila ]; // se supone que esto da positivo , sino no es una x
	xpv:= pm[k_fila];
	for k:= 1 to nc do
		xpv.pv[k]:= -xpv.pv[k];
	xpv.pv[nc]:= xpv.pv[nc] + x_sup.pv[ix];
	flg_x[ix]:= - flg_x[ix];

{$IFDEF SPXCONLOG}
	if dbg_on then
	begin
		sdbg:= 'Cambiar_borde_de_caja('+IntToStr( k_fila )+') x: '+nombreVars[ix]+' flg_x: '+IntToStr( flg_x[ix] );
		writelog( sdbg );
	end;
{$ENDIF}
	
end;

function TSimplex.darpaso: integer;
var
	p, q: integer;
	res: integer;
	k_cota_sup_violada: integer;
	fantasma: boolean;
begin
	inc( cnt_paso );
	res:= 1;
	q:= locate_zpos(nf, 1);
	if q > 0 then
	begin
		 p:= mejorpivote( q, nf-1, fantasma );
		 if p > 0 then
		 begin
				intercambiar( p, q );
				if fantasma then cambio_var_cota_sup_en_columna( q );

				(*** ME PARECE QUE ESTO NO DEBE PASAR NUNCA PERO POR LAS DUDAS LO PONEMOS ***)
				k_cota_sup_violada:= primer_cota_sup_violada;
				if k_cota_sup_violada > 0 then
				begin
					{$IFDEF SPXCONLOG}
					writelog('DUMP VIOLO FACTIVILIDAD COTA SUPERIOR, kcota_sup_violada:'+IntToStr( k_cota_sup_violada ) );
					appendWriteXLT( 'Después del cambio', cnt_paso, false );

					// invierto los cambios
					if fantasma then cambio_var_cota_sup_en_columna( q );
					intercambiar( p, q );
					writelog('---- sin el último cambio --- ( p: '+IntToStr(p)+' q: '+IntToStr(q )+' )' );
					appendWriteXLT( 'Después del cambio', cnt_paso, false );


					{$ENDIF}

					raise Exception.Create('Se violó la factibilidad de una cota superior dando un paso' );
					cambiar_borde_de_caja( k_cota_sup_violada);
					res:= 2; // con esto indicamos que es posible que halla que rechequear
				end;
				(****************************************************************************)

		 end
		 else
		 begin
				if p=-3 then
				begin
					cambio_var_cota_sup_en_columna( q );
					res:= 1;
				end
				else res:= -1; //ShowMessage('No encontre pivote bueno ');
		 end;
	end
	else
		res:= 0; //	ShowMessage('No encontre z - positivo ' );
	result:= res;
end;


function TSimplex.primerainfactible: integer;
var
	k: integer;
	res: integer;
begin
	res:= -1;
	for k:= 1 to nf-1 do
		if e(k, nc ) < 0 then
		begin
			res:= k;
			break;
		end;
	result:= res;
end;


procedure TSimplex.Actualizo_iileft( k : integer );
begin
// actualizo los indices iix e iiy
	if left[k] > 0 then
		iiy[left[k]]:= k
	else
		iix[-left[k]]:= -k;
end;

procedure TSimplex.Actualizo_iitop( k : integer );
begin
// actualizo los indices iix e iiy
	if top[k] < 0 then
		iix[-top[k]]:= k
	else
		iiy[top[k]]:= -k;
end;



procedure TSimplex.IntercambioFilas( k1, k2: integer );
var
	p: TVectR;
	ks: integer;
begin
	p:= pm[k1];
	pm[k1]:= pm[k2];
	pm[k2]:= p;

	ks:= left[k1];
	left[k1]:= left[k2];
	left[k2]:= ks;

	Actualizo_iileft( k1 );
	Actualizo_iileft( k2 );
end;

function TSimplex.reordenarPorFactibilidad: integer;
var
	kfil: integer;
	rval: NReal;
	ix: integer;

begin


(*
	Primero recorremos las restricciones y´
	si la restricción no está violada me fijo si corresponde a una variable
	con restricción de cota superior y si es así verificamos que tampoco esté
	violada la restricción fantasma, si la fantasma se viola hacemos el cambio
	de variable para volverla explícita *)
	for kfil:= 1 to nf -1 do
	begin
		rval:=e(kfil, nc );
		if (rval > 0 ) and (left[kfil] < 0) then
		begin
			ix:= -left[kfil];
			if flg_x[ix] <> 0 then
				if x_sup.pv[ix] < rval then
				begin
					cambiar_borde_de_caja(  kfil );
					rval:=e(kfil, nc );
				end
		end;
	end;


// Ahora sabemos que las violadas están explícitas
	kfil:= 1;
	cnt_infactibles:= 0;
	while (kfil <= (nf-1-cnt_infactibles) ) do
	begin
		rval:=e(kfil, nc );
		if  rval < 0 then
		begin
			inc( cnt_infactibles );
			while ( e(nf-cnt_infactibles, nc ) < 0 )
					and ( kfil < (nf-cnt_infactibles )) do
				inc( cnt_infactibles );
			if kfil < (nf-cnt_infactibles ) then
				IntercambioFilas( kfil, nf- cnt_infactibles );
		end
		else
			inc(kfil);
	end;
	result:= cnt_infactibles;
end;

function TSimplex.resolver: integer;
label
	lbl_inicio, lbl_buscofact;

var
	res: integer;
//	k: integer;
begin
	inc( cnt_debug );
	inc( cnt_resolver );

{$IFDEF SPXCONLOG}
	appendWriteXLT( 'INICIO CntResolver: '+IntToStr(cnt_resolver), cnt_paso , true );
{$ENDIF}

{$IFDEF GATILLOS_CAMBIOVAR}
if ( cnt_Gatillos > 0  ) and (gatillos_no_procesados) then
begin
	for k:= 1 to cnt_Gatillos do
		cambio_var_cota_sup_en_columna( gatillos_CambioVar[k] );

	 gatillos_no_procesados:= true;
{$IFDEF SPXCONLOG}
	appendWriteXLT( 'GATILLOS_CAMBIOVAR Cnt_Gatillos: '+IntToStr(cnt_Gatillos), cnt_paso , false );
{$ENDIF}
end;
{$ENDIF}

// Fijamos las variables que se hllan declarado como constantes.
FijarVariables;

//system.writeln( cnt_resolver );
if ResolverIgualdades <> 1 then
begin
	mensajeDeError:= 'PROBLEMA INFACTIBLE - No logré resolver las restricciones de igualdad.';
	result:= -31;
	exit;
end;

{$IFDEF SPXCONLOG}
	appendWriteXLT( 'INICIO CntResolver: '+IntToStr(cnt_resolver), cnt_paso , false );
{$ENDIF}


lbl_inicio:

{$IFDEF SPXCONLOG}
		writelog('Buscando factibilidad+++++++++++++++++++++++' );
{$ENDIF}
	reordenarPorFactibilidad;

lbl_buscofact:
	res:= 1;
	while cnt_infactibles > 0 do
	begin
(*
{$IFDEF SPXCONLOG}
		writelog('BUscandoFactible: cnt_infactibles: '+IntToStr( cnt_infactibles ) );
{$ENDIF}
*)
		res:= pasoBuscarFactible;
(*
{$IFDEF SPXCONLOG}
		writelog('BUscandoFactible: res: '+IntToStr( res ) );
		appendWriteXLT( 'A', cnt_paso, false );
{$ENDIF}
*)
		case res of
			0: if cnt_infactibles > 0 then
				begin
					mensajeDeError:= 'PROBLEMA INFACTIBLE - Buscando factibilidad';
					result:= -10;
					exit;
				end;
			-1: begin
					mensajeDeError:= 'NO encontramos pivote bueno - Buscando Factibilidad';
					result:= -11;
					exit;
					end;
			-2: begin
				mensajeDeError:= '???cnt_infactibles= 0 - Buscando Factibilidad';
				result:= -12;
				exit;
				end;
		end;
	end;

{$IFDEF SPXCONLOG}
		writelog('Maximizando por pasos+++++++++++++++++++++++' );
{$ENDIF}

	while res= 1 do
	begin
(*
{$IFDEF SPXCONLOG}
		writelog('DarPaso: cnt_infactibles: '+IntToStr( cnt_infactibles ) );
{$ENDIF}
*)

		res:= darpaso;
(*
{$IFDEF SPXCONLOG}
		writelog('DarPaso: res: '+IntToStr( res ) );
		appendWriteXLT( 'B', cnt_paso, false );
{$ENDIF}
*)
		case res of
	//		0: showmessage('FIN');
			-1: begin
				mensajeDeError:= 'Error -- NO encontramos pivote bueno dando paso';
				result:= -21;
{$IFDEF SPXCONLOG}
				writelog('Error -- NO encontramos pivote bueno dando paso: cnt_dbug:'+IntToStr( cnt_debug ) );
				appendWriteXLT( 'ERROR!, cnt_paso', cnt_paso, false );
{$ENDIF}
				exit;
			end;
		end;
	end;
	if res = 2 then	goto lbl_inicio;
	result:= res;


end;

initialization

	cnt_debug:=0;

end.

