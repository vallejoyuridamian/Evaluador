{$F+}
program rrex29;

uses

	xMatDefs,
	Math01,Math02,MatReal,
	{$I xtraxp};



{ Electronic plasma }

type
	vr5 = array[1..5] of NReal;


var
	amortiguador:NReal;
	epsilon,alfa2:NReal;
	alfa2eps:NReal;

	xe,xes,xe0:TVectr;
	x,xs,dx:NReal;
	delta:NReal;

function power(x,y:NReal):NReal;
begin
	power:=exp(y*ln (x))
end;

procedure fsyst(var fp,xe:TVectR; x:NReal);
var
	y,z,zed,u,I:NReal;
	y2,z2,temp,w:NReal;

begin
	y:=xe.e(1);
	z:=xe.e(2)/x;
	zed:=xe.e(3);
	u:=xe.e(4);
	I:=xe.e(5);

	y2:=y*y;
	z2:=z*z;

	delta:= 4*alfa2eps*z/x/y2/sqrt(1-z2/y2);

{	if abs(delta)>3 then
		writeln('warning, delta = ',delta:6:2);}

	temp:=power((y2-z2),1.5);
	w:= (y*( temp +alfa2*y) - alfa2eps*z2*z/x)/(temp+alfa2*(y2-z2));

	vr5(fp.pv^)[1]:=-z*w/y/epsilon*(1-delta/4);
	vr5(fp.pv^)[2]:=x*(1-w)/epsilon;
	vr5(fp.pv^)[3]:=x*w;

	vr5(fp.pv^)[4]:=(2*y-u)/x;
	vr5(fp.pv^)[5]:= y2;
end;




procedure InitValues(b:NReal);

var
	x0,y0:NReal;

begin

	epsilon:=0.1;
	alfa2:=0.1;
	alfa2eps:=alfa2*epsilon;

	y0:=100; { y0 = y(x1) };

	x0 := 1e-4;
	x:=x0;

	{ xe0 := initials values }
	vr5(xe0.pv^)[1] := b; { guess fo y(x0)}
	vr5(xe0.pv^)[2] := (x0/2/epsilon*(1-(sqr(b)+alfa2)/(b+alfa2)))*x0; {x0*z(x0)}
	vr5(xe0.pv^)[3]:=((sqr(b)+alfa2)/(b+alfa2)*x0*x0-1)/2; {zed(0)}
	vr5(xe0.pv^)[4]:=0; {u(0)}
	vr5(xe0.pv^)[5]:=0; {I(0)}
end;


function GetY1(yAtInit:NReal):NReal;
label
	searchingEnd;
var
	dxp:NReal;

begin

	desligue(0);
	desligue(1);
	desligue(2);
	desligue(3);
	desligue(4);
	desligue(5);

	InitValues(yAtInit);


	Xe.igual(xe0);

	dxp:=dx;

	while (x<tfinal) and (xe.e(3)<0) do
	begin
	searchingEnd:
		RK4(Xe,Xes,x,xs,fsyst,dxp,1,5);
		if (xes.e(3) >0) and (dxp>1e-6) then
		begin
			dxp:= dxp/2;
			goto searchingEnd
		end;
{		writeln(Xes.e(1),Xes.e(2),xes.e(3),xes.e(4));}
		Xe.igual(Xes);
		x:=xs;
		{plot}
    {$IFDEF WINDOWS}
		traxpW
		{$ELSE}
		traxp
		{$ENDIF}.t:=x;
		trazo(0,xe.e(1));
		trazo(1,xe.e(2));
		trazo(2,xe.e(3));
		trazo(3,xe.e(4));
		trazo(4,xe.e(5));
		trazo(5,delta);
	end;


getY1:=xe.e(1)-100;
end;





var
	r,fr:NReal;
	ni:word;
	res:boolean;


begin
	amortiguador:=0;

	gridy:=10;
	dx:= 0.01; { step }

	xe.init(5);
	xes.init(5);
	xe0.init(5);

	InicieGr;
	tinicial:=0;
	tfinal:=0.2;
	subplot(3,2);
	definaY(0,0,20);
	titulo('0: y');
	ylabel('20/div');
	linea0;grid;

	definaY(1,-10,1);
	titulo('1: x*z');
	linea0;grid;

	definaY(2,-0.5,0.1);
	titulo('2: int( x*w )- 1/2');
	linea0;grid;

	definaY(3,0,20);
	titulo('3: u');
	linea0;grid;

	definaY(4,0,100);
	titulo('4: I');
	linea0;grid;

	definaY(5,-0.01,0.01);
	titulo('5: delta');
	ylabel('0.01/div');
	linea0;grid;


	Dicot(gety1,
			8,100,0.001,
			1000,r,fr,ni,res);

	readln;
	termineGr;
	writeln(' y(x0) = ',r);
	writeln(' x1 = ',x);
	writeln(' z1 = ',xe.e(2)/x,'  mustbe: ',(x-1/x)/2/epsilon);

	xe.done;
	xes.done;
	xe0.done;


end.

