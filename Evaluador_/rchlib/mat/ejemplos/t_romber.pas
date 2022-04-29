program t_romberg;

{ 18.3.92,rch
test del procedure Romberg de la Math02 }

uses
	{$I xCRT},
	xMatDefs,
	math01,
	math02;

{$F+}
function Normal(x:NReal):NReal;
{$F-}
begin
	Normal:=exp(-sqr(x));
end;

function Fi(t:NReal):NReal;
var
	x,sum:NReal;
	res:boolean;
begin
	x:=t/sqrt(2);
	Romberg(
		Normal,
		0,x,1e-4,
		sum,
		res);
	Fi:=sum / sqrt(pi) + 0.5;
end;

function rap_Fi(t:NReal):NReal;
{
	Calcula la integral en a partir del £ltimo punto calculado
esto aumenta la velocidad cuando se calculan puntos sercanos. }
const
	ult_x:NReal=0;
	ult_Fi:NReal=0.5;
var
	x,sum:NReal;
	res:boolean;
begin
	x:=t/sqrt(2);
	Romberg(
		Normal,
		ult_x,x,1e-4,
		sum,
		res);
	ult_Fi:=sum / sqrt(pi) + ult_fi;
	ult_x:=x;
	rap_fi:=ult_fi;
end;


var
	g0:NReal;

{$F+}
function g(t:NReal):NReal;
{$F-}
begin
	g:=rap_fi(t)-g0
end;


var
	t,gt:NReal;
	NoOfIts: word;
	converged: boolean;


begin

	while true do
	begin
		write(' t?: ');readln(t);
		writeln(' fi : ',fi(t));

		g0:= rap_fi(t);
		writeln(' rap: ',g0);


		Secant(
			g, 							{funci¢n a anular}
			0,1,1e-4,           {valores iniciales de x y tolerancia}
			1000,					{n£mero m ximo de iteraciones}
			t, gt,	{ra¡z y f(ra¡z)}
			NoOfIts,			{n£mero de iteraciones realizadas}
			converged);	{valid‚s del resultado}

		writeln(t, ' NoOfIter: ',NoOfIts);

	end;

end.



