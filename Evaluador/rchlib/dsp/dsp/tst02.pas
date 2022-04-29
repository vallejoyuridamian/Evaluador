program tst02;
{ test de adquidef }
uses adquidef,traxp;

type

	filt01 = object
		s:real;
		procedure Init(x:real);
		procedure Ent(x:real);
		function Sal:real;
		function EntSal(x:real):real;
	end;

	filt02 = object
		m1,s:real;
		procedure Init(x:real);
		procedure Ent(x:real);
		function Sal:real;
		function EntSal(x:real):real;
	end;

procedure filt01.Init(x:real);
begin
	s:=x;
end;

procedure filt01.Ent(x:real);
begin
	s:=(s+x)/2;
end;

function filt01.Sal:real;
begin
	Sal:=s;
end;

function filt01.EntSal(x:real):real;
begin
	Ent(x);
	EntSal:=Sal
end;

procedure filt02.Init(x:real);
begin
	m1:=x;
end;

procedure filt02.Ent(x:real);
begin
	s:=x-m1;
	m1:=x
end;

function filt02.Sal:real;
begin
	Sal:=s
end;

function filt02.EntSal(x:real):real;
begin
	Ent(x);
	EntSal:=s
end;


var
	a,b:adqui;
	k:integer;
	g,pbdg,pb3:filt01;
	dg:filt02;

begin
	a.readFrom('canal1r2');
	b.readFrom('canal2r2');
	g.init(0);
	dg.init(0);
	pbdg.init(0);
	pb3.init(0);
	InicieGR;
	subplot(2,1);
	definaX(0,1,(a.NR_PT-1)/10);
	DefinaY(0,0,51.2);
	superponga(3,0);
	grid;
	linea0;
	definaX(1,1,(a.NR_PT-1)/10);
	DefinaY(1,-40,10);
	grid;
	linea0;
	for k:= 1 to a.NR_PT do
	begin
		g.ent((LVI(a.CURVE^)[k]));
		dg.ent(g.sal);
		pbdg.ent(dg.sal);
		pb3.ent(pbdg.sal);
		trazoXY(0,k,g.sal);
		trazoXY(1,k,pb3.sal*4);
		trazoXY(3,k,LVI(B.CURVE^)[k]);
	end;
	readln;
	TermineGr;
end.