{+doc
+NOMBRE: algebrac
+CREACION: 15.08.89
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Implementacion de Numero complejo y su algebra
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
	Se implementa el tipo complex y el conjunto de funciones
para su manejo. Las operaciones se realizan utilizando un area de
trabajo interna al modulo, lo que permite la realizacion de multiples
operaciones por linea de programa.
-doc}

(***********************************************************************)
(*  Unidad de complejos                              15/08/89/MEEP/RCH *)
(***********************************************************************)

unit   AlgebraC;

interface
uses
	xMatDefs;

type
	TAspectos = ( CA_Rectangulares, CA_GradosDecimales,
								CA_Radianes, CA_GradosMinutos );
const
	CA_Campo_Defecto= 11;
	CA_Campo:integer= CA_Campo_Defecto;
	CA_Decs:integer= CA_Campo_Defecto-4;
	CA_ASPECTO: TAspectos = CA_Rectangulares;


Type
{ La siguiente definici¢n es solo para hacer TypeCast NO PARA definir
variables. }
	VGComplex = array[1..3000] of NComplex;
	PVGComplex = ^VGComplex;

const {Constantes complejas m s usadas }
	complex_NULO: NComplex = (r:0; i:0);
	complex_UNO: NComplex = (r:1; i:0);
	complex_j: NComplex = (r:0; i:1);


	function   sc  (x,y:NComplex)     	:PNComplex; (* suma							*)
	function   rc  (x,y:NComplex)     	:PNComplex; (* resta            *)
	function   pc  (x,y:NComplex)     	:PNComplex; (* producto			    *)
	function   dc  (x,y:NComplex)     	:PNComplex;	(* divicion   x/y  *)
	function   ppc (x,y:NComplex)     	:PNComplex; (* paralelo         *)
	function   cc  (x  :NComplex)     	:PNComplex; (* conjugado        *)
	function   prc (a:NReal;x:NComplex):PNComplex; (* NReal * complejo *)
	function   numc( a , b:NReal)     :PNComplex; (* numc:=^(a+j b)   *)
  function numc_rofi( ro, fi: NReal ): PNComplex;  (*numc_rofi= ro exp( j fi ) *)
	function	invc( x: NComplex)				:PNComplex; (* inverso					*)

	{ funcion raiz cuadrada (PRINCIPAL) }
	function raizc( x: NComplex):  PNComplex;

	{ funciones Hiperbolicas }
	function chc( x: NComplex):  PNComplex;
	function shc( x: NComplex):  PNComplex;



	function	mod1(x: NComplex)     :NReal;(* modulo           *)

(* fase en Radianes en el rango [-pi.. pi] *)
	function  fase(x: NComplex):	NReal;

(* fase en Radianes en el rango [0.. 2*pi] *)
	function fase_2pi( x: NComplex): NReal;


	function   mod2( x :NComplex)     :NReal;(* modulo^2        	*)


	(* Escriben el complejo en la salida estnadar segun CA_ASPECTO *)
	procedure wc(x:NComplex);                (* write(complex)  	*)
	procedure wcln(x:NComplex);              (* writeln(complex)	*)

	(* Escriben el complejo en un archivo de texto
	 segun el ASPECTO especificado*)
	procedure wtxtc(var f: text; x: NComplex; Aspecto: TAspectos);
	procedure wtxtcln(var f: text; x:NComplex; Aspecto: TAspectos);              (* writeln(complex)	*)

implementation

const

		 LongADT = 50;

var
	DOSPI: NREAL;
	ADT : array[0..LongADT] of NComplex;
	count : 0..LongADT;



function NewPCX :PNComplex;
begin
	NewPCX:=@ADT[ count ];
	count := succ( count ) mod ( LongADT +1 );
end; (* NewPcomplex *)


function sc;
var
	temp:PNComplex;
begin
	temp:= NewPCX;
	temp^.r:=x.r+y.r;
	temp^.i:=x.i+y.i;
	sc:=temp
end; (* sc *)

function raizc( x: NComplex):  PNComplex;
var
	temp:PNComplex;
	ro, fi: NReal;

begin

	temp:= NewPCX;
	ro:= sqrt(mod1(x));
	fi:= fase(x)/2;
	temp^.r:=ro*cos(fi);
	temp^.i:=ro*sin(fi);
	raizc:=temp
end; (* raizc *)

function chc( x: NComplex):  PNComplex;
var
	temp:PNComplex;
	ea, ema, cha, sha, cosb, sinb: NReal;
begin
	ea:= exp(x.r); ema:=0.5/ea;
	ea:= ea/2;
	cha:= ea+ema; sha:=ea-ema;
	cosb:= cos(x.i);
	sinb:= sin(x.i);

	temp:= NewPCX;
	temp^.r:=cha * cosb;
	temp^.i:=sha * sinb;
	chc:=temp
end;

function shc( x: NComplex):  PNComplex;
var
	temp:PNComplex;
	ea, ema, cha, sha, cosb, sinb: NReal;
begin
	ea:= exp(x.r); ema:=0.5/ea;
	ea:= ea/2;
	cha:= ea+ema; sha:=ea-ema;
	cosb:= cos(x.i);
	sinb:= sin(x.i);

	temp:= NewPCX;
	temp^.r:=sha * cosb;
	temp^.i:=cha * sinb;
	shc:=temp
end;



function invc( x: NComplex):PNComplex;
var
	temp:PNComplex;
begin
	temp:= NewPCX;
	temp^:= prc(1/mod2(x),cc(x)^)^;
	invc:=temp
end; (* sc *)


function rc;
var temp:PNComplex;
begin
	temp:=NewPCX;
	temp^.r:=x.r-y.r;
	temp^.i:=x.i-y.i;
	rc:=temp
end; (* rc *)

function pc;
var temp:PNComplex;
begin
	temp:=NewPCX;
	temp^.r:=x.r*y.r-x.i*y.i;
	temp^.i:=x.r*y.i+x.i*y.r;
	pc:=temp
end; (* pc *)

function cc;
var temp:PNComplex;
begin
	temp:=NewPCX;
	temp^.r:=x.r;
	temp^.i:=-x.i;
	cc:=temp
end; (* cc *)

function prc;
var temp:PNComplex;
begin
	temp:=NewPCX;
	temp^.r:=x.r*a;
	temp^.i:=x.i*a;
	prc:=temp
end; (* prc *)

function mod2;
begin
	mod2:=sqr(x.r)+sqr(x.i)
end; (* mod2 *)

function mod1;
begin
	mod1 := sqrt(mod2(x))
end; (* mod1 *)

function fase( x: NComplex): NReal;
var
	res: NReal;

begin
	if x.i = 0 then
		if x.r >= 0 then fase:= 0
		else fase:= pi
	else if x.r = 0 then
		if x.i > 0 then fase:= pi/2
		else fase:= -pi/2
	else
	begin { **Cambio, 25/8/93 }
		res:= ArcTan(x.i/x.r);
		if x.r<0 then
			if x.i> 0 then res:= pi+res
			else res:= -pi+res;
		fase:=res;
	end;
end;

function fase_2pi( x: NComplex): NReal;
var
	a: NReal;
begin
	a:= fase( x );
	if a < 0 then
		a:= a+ 2*pi;
	result:= a;
end;


function dc;
begin
	dc:=prc(1/mod2(y),pc(x,cc(y)^)^);
end; (* dc *)

function PPC;
begin
	PPC := dc(pc(x,y)^,sc(x,y)^)
end; (* PPC *)

function NumC;
var temp:PNComplex;
begin
	temp:= NewPCX;
	temp^.r:=a;
	temp^.i:=b;
	NumC := temp
end; (* NumC *)

function numc_rofi( ro, fi: NReal ): PNComplex;
begin
  result:= numc( ro* cos( fi ), ro * sin( fi ) );
end;

procedure wc(x:NComplex);
begin
	wtxtc( output, x, CA_ASPECTO);
end;

procedure wcln(x:NComplex);
begin
	wc(x);writeln;
end;


procedure wtxtc(var f: text; x: NComplex; Aspecto: TAspectos);
var
	grados, minutos, segundos:integer;
	m: NReal;
	 
begin
	case ASPECTO of
  	CA_Rectangulares:
			write(f, x.r:CA_Campo:CA_Decs,' + j ',x.i:CA_Campo:CA_Decs);
  	CA_Radianes:
			write(f, mod1(x):CA_Campo:CA_Decs,
					'(',fase(x):CA_Campo:CA_Decs,'rad)');
		CA_GradosDecimales:
			write(f, mod1(x):CA_Campo:CA_Decs,
					'(',fase(x)/pi*180:CA_Campo:CA_Decs,
					{$IFDEF WINDOWS}'°)'{$ELSE} 'ø)'{$ENDIF});
		CA_GradosMinutos:
		begin
			write(f, mod1(x):CA_Campo:CA_Decs,'(');
			m:=fase(x)/pi*180;
			Grados:= trunc(m);
			m:= frac(m)*100/60;
			Minutos:=trunc(m);
			m:= frac(m)*100/60;
    	Segundos:= trunc(m);
    	write(f, Grados:4,'º',Minutos:4,'''',Segundos:4,'''''');
		end;          
  end; {Case}
end;

procedure wtxtcln(var f: text; x: NComplex; Aspecto: TAspectos);
begin
	wtxtc(f, x, Aspecto);writeln(f);
end;

begin (* inicializacion de la Unit *)
	count := 0 ;
	DOSPI:= 2*PI;
end.







