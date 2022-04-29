(* Oct.2005 creo esta unidad juntando las funciones
desarrolladas en otros módulos (especialmente el editor de caminos en mapas)
para manejo de interpolaciones de hermit sobre un
conjunto de puntos


*)
unit uhermitaprox;

interface
uses
	SysUtils, Math, xmatdefs;

type
	TPuntoXY= record
		x, y: NReal;
	end;

	TTabla_xy= array of TPuntoXY;

(* dado dos puntos PA y PB y sus respectivas derivadas ta y tb
calcula el punto P y su derivada v para el valor de (u) pasado
como parámetro. (u) debe estar en [0,1] si u=0 estamos en el
extremo PA del segmento de curva y si u=1 en el extremo PB. *)
procedure hermit( const PA, ta, PB, tb: TPuntoXY;
		var P, v: TPuntoXY; u: NReal );


(* Estima la tabla de velocidades para los puntos interiores poniendo
la pendiente de la recta que une los puntos adyacentes al que se estima.
El valor tipoAprox indica el tipo de aproximación que se desea para los
extremos de la tabla.
  tipoAprox= 0 => se pone como velocidad en cabezal la diferencia entre
		el punto cabezal y el punto interior inmediato adyacente.
		Es realmente una mala solución en la mayoría de los casos es mejor
		usar alguna de las tipoAprox > 0;
  tipoAprox= 1 => se pone la velocidad del cabezal de forma que en la
		estimación resulte la derivada segunda constante en el cabezal.
		Es recomendable cuando la tabla representa una curva que continúa
		mas hallá de la tabla.
  tipoAprox= 2 => se pone la velocidad del cabezal de forma que la derivada
		segunada de la estimación tenga valor CERO en el cabezal.
		Esta aproximación es la recomendable cuando la curva termina donde
		termina la tabla (no continua mas halla de los extremos).
*)
function EstimarVelocidades_simple(
	camino: TTabla_xy; tipoAprox: integer ): TTabla_xy;


(* Estima la tabla de velocidades para los puntos interiores de forma de
manener continuidad de la derivada segunda (de la aproximación) en los puntos.

El valor tipoAprox indica el tipo de aproximación que se desea para los
extremos de la tabla.
  tipoAprox= 0 => se pone como velocidad en cabezal la diferencia entre
		el punto cabezal y el punto interior inmediato adyacente.
		Es realmente una mala solución en la mayoría de los casos es mejor
		usar alguna de las tipoAprox > 0;
  tipoAprox= 1 => se pone la velocidad del cabezal de forma que en la
		estimación resulte la derivada segunda constante en el cabezal.
		Es recomendable cuando la tabla representa una curva que continúa
		mas hallá de la tabla.
  tipoAprox= 2 => se pone la velocidad del cabezal de forma que la derivada
		segunada de la estimación tenga valor CERO en el cabezal.
		Esta aproximación es la recomendable cuando la curva termina donde
		termina la tabla (no continua mas halla de los extremos).
*)
function EstimarVelocidades(
	camino: TTabla_xy; tipoAprox: integer;
	MaxNIters: integer;
	tolerancia: NReal;
	var convergio: boolean;
	var niters: integer	 ): TTabla_xy;



implementation


procedure hermit( const PA, ta, PB, tb: TPuntoXY;
		var P, v: TPuntoXY; u: NReal );

var
	a, b, ac, bc, z: NReal;
begin
	a:= u*u*(2*u-3)+1;
	ac:= 1-a;

	z:= (1-u)*u;
	b:= z*(1-u);
	bc:= -z*u;
	P.x:= a* PA.x + b* ta.x + ac * PB.x + bc * tb.x +0.5;
	P.y:= a* PA.y + b* ta.y + ac * PB.y + bc * tb.y +0.5;

// cálculo de la derivada
	 a:= 6*u*(1-u);
	 b:= (1-3*u)*(1-u);
	 z:= u*(3*u-2);
	 v.x:= (PB.x-PA.x)*a+ ta.x *b + tb.x*z;
	 v.y:= (PB.y-PA.y)*a+ ta.y *b + tb.y*z;

end;




function EstimarVelocidades_simple(
	camino: TTabla_xy; tipoAprox: integer): TTabla_xy;

var
	k: integer;
	nsels: integer;
	vel: TTabla_xy;
begin
	nsels:= length( camino );
	setlength( vel, nsels );

// derivadas interiores
	for k:= 1 to nSels-2 do
	begin
		vel[k].x:= (camino[k+1].x-camino[k-1].x)/2;
		vel[k].y:= (camino[k+1].y-camino[k-1].y)/2;
	end;


	case tipoAprox of
	0:
(* Estimación grosera de la derivada en el cabezal como
 la recta que une los puntos del segmento cabezal, es sólo para
 interés académico. Equivale a decir que el nodo cabezal ejerce
 fuerzas de torción sobre la curva. *)
		begin
			vel[0].x:= camino[1].x-camino[0].x;
			vel[0].y:= camino[1].y-camino[0].y;
			vel[nSels-1].x:= camino[nSels-1].x-camino[nSels-2].x;
			vel[nSels-1].y:= camino[nSels-1].y-camino[nSels-2].y;
		end;
	1:
(** derivada segunda constante en los tramos cabezales *)
		begin
			vel[0].x:= 2*(camino[1].x-camino[0].x)-vel[1].x;
			vel[0].y:= 2*(camino[1].y-camino[0].y)-vel[1].y;
			vel[nSels-1].x:= 2*(camino[nSels-1].x-camino[nSels-2].x)-vel[nSels-2].x;
			vel[nSels-1].y:= 2*(camino[nSels-1].y-camino[nSels-2].y)-vel[nSels-2].y;
		end;
	2:
(** derivada segunda nula en los nodos cabezales **)
		begin
			vel[0].x:= (6*(camino[1].x-camino[0].x)-2*vel[1].x)/4;
			vel[0].y:= (6*(camino[1].y-camino[0].y)-2*vel[1].y)/4;
			vel[nSels-1].x:= (6*(camino[nSels-1].x-camino[nSels-2].x)-2*vel[nSels-2].x)/4;
			vel[nSels-1].y:= (6*(camino[nSels-1].y-camino[nSels-2].y)-2*vel[nSels-2].y)/4;
		end;
	else
		raise Exception.Create('No es válido tipoAprox: '+IntToStr(tipoAprox ) );
	end;
end;


function calcErrorYAsigno( var vnuevo, vviejo: TPuntoXY; errorActual: NReal ): NReal;
var
	ea: NReal;
begin
	ea:= max( abs( vnuevo.x - vviejo.x), abs( vnuevo.y-vviejo.y ) );
	vviejo:= vnuevo;
	result:= max( errorActual, ea );
end;


function EstimarVelocidades(
	camino: TTabla_xy; tipoAprox: integer;
	MaxNIters: integer;
	tolerancia: NReal;
	var convergio: boolean;
	var niters: integer	 ): TTabla_xy;

var
	nSels, k: integer;
	e: NReal;
	vel: TTabla_xy;
	vs: TPuntoXY;
	ToleranciaNoAlcanzada: boolean;


begin
	nsels:= length( camino );
	if nSels < 2 then exit;

// primera aproximación por la simple
	vel:=EstimarVelocidades_simple( camino, tipoAprox);

	niters:= 0;
	ToleranciaNoAlcanzada:= true;
	while ToleranciaNoAlcanzada and (niters < MaxNIters ) do
	begin
		e:= 0;

	// derivadas interiores
		for k:= 1 to nSels-2 do
		begin
      vs.x := (6 * (camino[k + 1].x - camino[k - 1].x) - 2 * (vel[k - 1].x + vel[k + 1].x)) / 8;
      vs.y := (6 * (camino[k + 1].y - camino[k - 1].y) - 2 * (vel[k - 1].y + vel[k + 1].y)) / 8;
			e:= calcErrorYAsigno( vs, vel[k], e );
		end;


		case tipoAprox of
		0:
	(* Estimación grosera de la derivada en el cabezal como
	 la recta que une los puntos del segmento cabezal, es sólo para
	 interés académico. Equivale a decir que el nodo cabezal ejerce
	 fuerzas de torción sobre la curva. *)
			begin
				vs.x:= camino[1].x-camino[0].x;
				vs.y:= camino[1].y-camino[0].y;
				e:= calcErrorYAsigno( vs, vel[0], e );
				vs.x:= camino[nSels-1].x-camino[nSels-2].x;
				vs.y:= camino[nSels-1].y-camino[nSels-2].y;
				e:= calcErrorYAsigno( vs, vel[nSels-1], e );
			end;
		1:
	(** derivada segunda constante en los tramos cabezales *)
			begin
				vs.x:= 2*(camino[1].x-camino[0].x)-vel[1].x;
				vs.y:= 2*(camino[1].y-camino[0].y)-vel[1].y;
				e:= calcErrorYAsigno( vs, vel[0], e );
				vs.x:= 2*(camino[nSels-1].x-camino[nSels-2].x)-vel[nSels-2].x;
				vs.y:= 2*(camino[nSels-1].y-camino[nSels-2].y)-vel[nSels-2].y;
				e:= calcErrorYAsigno( vs, vel[nSels-1], e );
			end;
		2:
	(** derivada segunda nula en los nodos cabezales **)
			begin
				vs.x:= (6*(camino[1].x-camino[0].x)-2*vel[1].x)/4;
				vs.y:= (6*(camino[1].y-camino[0].y)-2*vel[1].y)/4;
				e:= calcErrorYAsigno( vs, vel[0], e );
				vs.x:= (6*(camino[nSels-1].x-camino[nSels-2].x)-2*vel[nSels-2].x)/4;
				vs.y:= (6*(camino[nSels-1].y-camino[nSels-2].y)-2*vel[nSels-2].y)/4;
				e:= calcErrorYAsigno( vs, vel[nSels-1], e );
			end;
		else
			raise Exception.Create('No es válido tipoAprox: '+IntToStr(tipoAprox ) );
		end; // del case

		if e < tolerancia then
			ToleranciaNoAlcanzada:= false
		else
			inc( NIters );
	end; // del while

	Convergio:= not ToleranciaNoAlcanzada;

   result:= vel;
end;

end.
