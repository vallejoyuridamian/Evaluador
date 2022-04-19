unit fddp;
{+doc
+NOMBRE: fddp
+CREACION: 18.3.1992
+AUTOR: Ruben Chaer.
+REVISION:
+AUTOR:
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Funciones de densidad de probabilidad.
+PROYECTO: rchlib
+DESCRIPCION:
	Implementaci¢n de un conjunto de funciones £tiles para estad¡sticas.
-doc}

interface
uses
	xMatDefs,
	math01,math02;


type
	p_fddp = ^f_ddp;

	f_ddp = object
		dtmax:NReal;
		area_t0,t0,t1:NReal;
		area_u_t, u_t:NReal;
		g0:NReal;
		constructor Init(xt0,xarea_t0,xt1:NReal);
		destructor done; virtual;
		function densidad(x:NReal):NReal; virtual;
		function distribucion(x: NReal): NReal; virtual;

		function area_t( t:NReal ):NReal;
		function area_t_rapida( t:NReal):NReal;
		function t_area( area:NReal):NReal;
	end;


	f_Normal = object(f_ddp)
		m,sigma:NReal;
		constructor Init(
			xt0,xarea_t0,xt1:NReal;
			valorMedio, xsigma :NReal );
		function densidad(x:NReal):NReal;virtual;
	end;


	f_Student = object(f_ddp)
		nu, y0:NReal;
		constructor Init(N: integer );
		function densidad(x:NReal):NReal;virtual;
	end;


	f_ChiCuadrado = object(f_ddp)
		nu, y0:NReal;
		constructor Init(N:integer );
		function densidad(x:NReal):NReal;virtual;
	end;

{??? A confirmar con Eduardo Penza }
	f_Weibool = object(f_ddp)
		k, C:NReal;
		constructor Init( ValorMedio, Constante_k: NReal );
		function densidad( x: NReal ):NReal; virtual;
		function distribucion(x: NReal): NReal; virtual;
	private
		kSobreC: NReal;
	end;


implementation

var
	p_fddpActiva: p_fddp;


{$F+}
function fd(x:NReal):NReal;
{$F-}
begin
	fd:= p_fddpActiva^.densidad(x)
end;



{$F+}
function g(t:NReal):NReal;
{$F-}
begin
	g:=p_fddpActiva^.area_t(t)-p_fddpActiva^.g0
end;


{ m‚todos de las f_ddp }


constructor f_ddp.Init(xt0,xarea_t0,xt1:NReal);
begin
	t0:=xt0;
	area_t0:=xarea_t0;
	t1:=xt1;
	area_u_t:=area_t0;
	u_t:=t0;
end;

destructor f_ddp.done;
begin
end;

function f_ddp.distribucion( x: NReal):NReal;
begin
	distribucion:= area_t_rapida(x);
end;


function f_ddp.densidad(x:NReal):NReal;
begin
	densidad:=0;
end;

function f_ddp.area_t( t:NReal ):NReal;
var
	sum:NReal;
	res:boolean;
begin
	p_fddpActiva:= @Self;
	Romberg(
		fd,
		t0,t,AsumaCero,
		sum,
		res);
	area_t:=sum + area_t0;
end;

function f_ddp.area_t_rapida( t:NReal):NReal;
{
	Calcula la integral en a partir del £ltimo punto calculado
esto aumenta la velocidad cuando se calculan puntos sercanos. }
var
	sum:NReal;
	res:boolean;
	ts:NReal;
begin
	p_fddpActiva:= @Self;
	if t>u_t then
	begin
		ts:=u_t+dtmax;
		while ts <t do
		begin
			Romberg(
				fd,
				u_t,ts,1e-4,
				sum,
				res);
			area_u_t:=sum + area_u_t;
			u_t:=ts;
			ts:=ts+dtmax;
		end;


		Romberg(
			fd,
			u_t,t,1e-4,
			sum,
			res);
		area_u_t:=sum + area_u_t;
		u_t:=t;
		area_t_rapida:=area_u_t;
	end
	else
   begin
		ts:=u_t-dtmax;
		while ts >t do
		begin
			Romberg(
				fd,
				u_t,ts,1e-4,
				sum,
				res);
			area_u_t:=sum + area_u_t;
			u_t:=ts;
			ts:=ts-dtmax;
		end;

		Romberg(
			fd,
			u_t,t,1e-4,
			sum,
			res);
		area_u_t:=sum + area_u_t;
		u_t:=t;
		area_t_rapida:=area_u_t;
	end

end;

function f_ddp.t_area( area:NReal):NReal;

var
	t,gt:NReal;
	NoOfIts: word;
	converged: boolean;

begin

	p_fddpActiva:=@Self;
	g0:=area;


	Dicot(
		g,							{funci¢n a anular}
		t0,t1,1e-4,          	{extremos y tolerancia}
		1000,					{n£mero m ximo de iteraciones}
		t,gt,     {ra¡z y f(ra¡z)}
		NoOfIts,          {n£mero de iteraciones realizadas}
		converged);		{valid‚s del resultado}

	if not converged then
	begin
		writeln(' Problema de convergencia ');
		halt(1)
	end;
	t_area:=t;
end;


constructor f_Normal.Init(
			xt0,xarea_t0,xt1:NReal;
			valorMedio, xsigma :NReal );
begin
	dtmax:=1;
	f_ddp.init(xt0,xarea_t0,xt1);
	m:=valorMedio;
	sigma:= xsigma;
end;


function f_Normal.densidad(x:NReal):NReal;
const
	usr2p = 0.3989422804;
var
	r: NReal;
begin
	r:=(x-m)/sigma/2;
	densidad:=usr2p * exp(-r*r) /sigma;
end;


{ Metedos de f_student }

constructor f_Student.Init( N: integer );
var
	s:NReal;
begin
	dtmax:=1;
	nu:= N-1;
	y0:=1;
	f_ddp.Init(0,0.5,100);
	s:= area_t_rapida(100);
	u_t:=0;
	area_u_t:=0.5;
	y0:=1/((s-0.5)*2);
end;


function pot( x,y:NReal):NReal;
begin
	if x < 1e-12 then pot := 0
	else
		pot:=exp( y * ln(x) );
end;


function f_Student.densidad(x:NReal):NReal;
begin
	densidad:= Y0/pot( 1 + x*x/nu , (nu +1 )/2 );
end;

{ metodos de f_ChiCuadrado = object(f_ddp) }

constructor f_ChiCuadrado.Init(N:integer );
var
	s:NReal;
begin
	dtmax:=1;
	nu:= N-1;
	y0:=1;
	f_ddp.Init(0,0,100);
	s:= area_t_rapida(300);
	u_t:=0;
	area_u_t:=0;
	y0:=1/s;
end;

function f_ChiCuadrado.densidad(x:NReal):NReal;
begin
	densidad:=Y0* pot(x, (nu-2)/2)*exp(-x/2)
end;

{ m‚todos de la funci¢n de probabilidad de Weibool }
constructor f_Weibool.Init( ValorMedio, Constante_k: NReal );
var
	gamaaprox: NReal;
begin
	k:= Constante_k;
	gamaaprox:= 0.2869/k+ 0.688*exp(-0.1*ln(k));
	C:= ValorMedio / gamaaprox;
	kSobreC:= k/C;
end;

function f_Weibool.densidad( x: NReal ):NReal;
var
	x_ala_k: NReal;
begin
	if x <= 0 then densidad:= 0
	else
	begin
		x:= x/C;
		x_ala_k:= exp(k*ln(x));
		densidad:= kSobreC*(x_ala_k/x)*exp(-x_ala_k);
	end;
end;

function f_Weibool.distribucion(x: NReal): NReal;
begin
	if x<= 0 then distribucion:=0
	else
		distribucion:= 1- exp( - exp(k*ln(x)));
end;


end.



