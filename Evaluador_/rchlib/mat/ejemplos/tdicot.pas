program test;

uses
	xMatDefs, Math01, {$I xCRT};

const
	s1= 13.7;
	s2= 5.5;
	pt=13.4;
	qt=4.9;

function f1( fi2: NReal ): NReal; far;
var
	seno, tang: NReal;
begin
	seno:= (qt -s2 *sin ( fi2))/s1;
	tang:= seno/sqrt(1-seno*seno);
	f1:= s1*cos( arctan( tang ) )+s2 *cos(fi2)-pt;
{
	f1:= s1*(1-seno*seno)+s2 *cos(fi2)-pt;     }
end;


var
	Root, fAtRoot: Nreal;
  NoOfIts: word;
  Converged: boolean;
	fi: NReal;
  k: integer;

begin

{
for k:= -50 to 100 do
begin
	fi:= pi/100*k;
	writeln( fi/pi*180:10:3, f1(fi));
end;
readlN;
 }

	Dicot(
		f1,							{funci¢n a anular}
		-PI/2, PI/4, 0.0001,          {extremos y tolerancia}
		1000,					{n£mero m ximo de iteraciones}
		Root,fAtRoot,    {ra¡z y f(ra¡z)}
		NoOfIts,          {n£mero de iteraciones realizadas}
		converged);		{valid‚s del resultado}

	if converged then writeln('OK');
	writeln( root/pi*180: 12:3, fatroot: 12:3, noofits: 5 );
	writeln( 'fpot: ', cos(root): 12:3 );




end.