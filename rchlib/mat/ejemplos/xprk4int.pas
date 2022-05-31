program xprk4int;
uses
	{$I xCRT},
  xMatDefs,
  rk4int;

var
	xs,x:array[1..4] of Nreal;
	ts,t:Nreal;
	n:integer;


{$F+}
procedure Tito(var yp,y:LVR; x:Nreal);
{$F-}
begin
	yp[1]:=exp(2*x)+y[1];
end;


begin
	ClrScr;
	x[1]:=1;
	t:=0;
	init( X,Xs,Tito,1);
	while t<2 do
	begin
		writeln('x: ',t:6:3,' y(x): ',x[1]:6:3);
		DarPaso(t,ts,0.1);
		x:=xs;
		t:=ts;
	end;

	done;
end.

