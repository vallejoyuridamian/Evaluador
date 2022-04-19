unit RK4Int;
{-------------------------------
+PROPOSITO: Integrador de sistemas de ecuaciones diferenciales
				ordinarias, utilizando m‚todo de Runge-Kutta de
				4to. orden.
+FECHA: 7-1990
+AUTOR: R. Chaer.
+TEST
	FECHA:12-1991.
	PROGRAMA:xpRK4Int.
+DOCUMENTACION:
	Manual del usuario: Escrito a continuaci¢n.
	Referencias:
		(1)
				"an introduction to
				NUMERICAL METHODS
					WITH PASCAL.",
							L.V. ATKINSON.
							  P.J. HARLEY.

			 (pag. 277, de aqu¡ se extrajo el ejemplo )


{********************************************
	Manual:                    ......RCh91.
 --------------------------------------------

	Para usar RK4Int, debe escribir un procedimiento, del tipo
fode, que se define m s abajo, en el cual usted define el sistema
de equaciones diferenciales ordinarias a integrar.
	Por ejemplo, para resolver

		y'= exp(2*x)+y, y(0) = 1

	Usted puede escribir en su programa el procedimiento:
....
...
$F+
procedure Tito(var yprima,y:LVR;x:NReal);
$F-
begin
	yprima[1]:=exp(2*x)+yprima[1];
end;
.....
...

	Antes de comenzar la integraci¢n, usted debe inicializar RK4Int
para comunicarle los par metros que permaneceran constantes durante
la integraci¢n, y para que se cree  rea de memoria para trabajar.
	La inicializaci¢n se lleva a cabo con el procedimiento
	procedure Init(var X,Xs;
					xfcal: fODE;
					xn:integer);
	,donde (X) y (XS), son vectores reales externos de dimenci¢n mayor o igual
a xn. En estos vectores se guarda las variables de estado del sistema
X es tratado como una entrada, de donde se lee el estado actual.
Xs es tratado como una salida (de cada paso de integraci¢n) y es donde se
devuelve el estado luego del paso.
(xfcal) es la definici¢n del sistema de ecuaciones. En el ejemplo es Tito.
(xn) es la dimenci¢n del problema. En el ejemplo xn =1.
	Para llevar a cabo la integraci¢n, se debe llamar al procedimiento

	procedure DarPaso(var t,ts,h:NReal);

	done t es el tiempo actual, h es el paso a dar y ts es devuelto
con el valor del tiempo del estado calculado en Xs (ts = t + h).
	Cuando se termina la integraci¢n, se debe llamar al procedimento

	procedure Done;

	para que la memoria de trabajo se devuelta al sistema.

El programa xpRk4Int, muestra un ejemplo, usado como test de la Unidad.


	************************}



interface
uses
	xMatDefs;
type
	LVR = array[1..1000] of NReal;
	LVRPtr=^LVR;
	fode = procedure(var XPrima, X:LVR; t:NReal);
	fdeX = function(x:NReal):NReal;


procedure Init(var X,Xs; {vectores reales de n elementos}
					xfcal: fODE;
					xn:integer);

procedure SetDim(xn:integer);
procedure DarPaso(t:NReal;var ts:NReal;h:NReal);
procedure Done;


implementation
var
	xp,xsp,k1,k2,k3,k4:LVRPtr;
	tmp:LVRPtr;
	fcal:fODE;
	n:integer;


procedure Init;
begin
	n:=xn;
	GetMem(tmp,SizeOf(NReal)*n);
	GetMem(k1,SizeOf(NReal)*n);
	GetMem(k2,SizeOf(NReal)*n);
	GetMem(k3,SizeOf(NReal)*n);
	GetMem(k4,SizeOf(NReal)*n);
	xp:=addr(x);
	xsp:=addr(xs);
	fcal:=xfcal;
end;
procedure SetDim(xn:integer);
begin
	n:=xn;
end;
procedure Done;
begin
	FreeMem(tmp,SizeOf(NReal)*n);
	FreeMem(k1,SizeOf(NReal)*n);
	FreeMem(k2,SizeOf(NReal)*n);
	FreeMem(k3,SizeOf(NReal)*n);
	FreeMem(k4,SizeOf(NReal)*n);
end;

procedure DarPaso;
var
	hd2:NReal;
	k:integer;
begin
	hd2:=h/2;
	ts:=t+h;
	fcal(k1^,xp^,t);
	for k:= 1 to n do
		tmp^[k]:=k1^[k]*hd2+xp^[k];
	fcal(k2^,tmp^,t+hd2);
   for k:= 1 to n do
		tmp^[k]:=k2^[k]*hd2+xp^[k];
	fcal(k3^,tmp^,t+hd2);
   for k:= 1 to n do
		tmp^[k]:=k3^[k]*h+xp^[k];
	fcal(k4^,tmp^,ts);
	for k:=1 to n do
		xsp^[k]:=(k1^[k]+(k2^[k]+k3^[k])*2{0.5?}+k4^[k])*(h/6)+xp^[k];
end;
end.