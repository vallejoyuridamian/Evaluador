program xpmnmx;
uses
	Detectar, WinCRT;

const
	v:array[1..12] of real =
					(1, 2, 3, 4,
					-1, -2, -3, -4,
					2, 2, 2, 15);

var
	PosMax, PosMin:integer;
	yMin, yMax:real;

begin
	ClrScr;
	ScanMaxMin(
	v,		{ Inicio del  rea de memoria donde est n los reales }
	12, 	{ N£mero de reales a considerar }
	yMin, yMax, 	{ Valores m¡nimo y m ximo encontrados }
	PosMin, PosMax { Posici¢n del m¡nimo y del m ximo encontrados
							en el vector }
	);


	writeln('M ximo: ',yMax:12:3,' en la posici¢n: ',PosMax);
	writeln('M¡nimo: ',yMin:12:3,' en la posici¢n: ',PosMin);
	if (yMax = 15)and(yMin = -4)and
		(PosMin = 8)and(PosMax = 12) then
		writeln(' CORRECTO!!')
	else
		writeln(' ERROR ¦¦!¦¦');
	readln;
end.
