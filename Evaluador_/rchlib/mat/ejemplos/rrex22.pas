program rrex22;
uses
	xMatDefs;
type
	v3=array[1..3]of NReal;
	m3x3=array[1..3,1..3]of NReal;
var
	P,x,xs:v3;
	mj:m3x3;
	a1,a2:NReal;
	IterationCount:Integer;
	SquareLongStep:NReal;

procedure WrV3(x:v3);
begin
	writeln;
	writeln('( ', x[1]:14:-4,x[2]:14:-4,x[3]:14:-4,')T');
	writeln;
end;

procedure Minus(var x,y:v3);
var k:integer;
begin
	for k:=1 to 3 do x[k]:=x[k]-y[k]
end;

function L2(x:v3):NReal;
begin
	l2:=sqr(x[1])+sqr(x[2])+sqr(x[3]);
end;

function power(x,y:NReal):NReal;
begin
	if x = 0 then power:=0
	else
		power:= exp(y*ln(x))
end;

function f(x,y,n:NReal):NReal;
begin
	if x>=y then f:=power(x-y,n)
	else f:=-power(y-x,n)
end;

function fx(x,y,n:NReal):NReal;
begin
	fx:=n*power(abs(x-y),n-1)
end;

function fy(x,y,n:NReal):NReal;
begin
	fy:=-n*power(abs(x-y),n-1)
end;

procedure residuals(P:v3; var res:v3);
var
	t1,t2:NReal;
begin
	t1:=0.036*f(p[2],p[1],0.8);
	res[1]:=0.019*f(p[1],a1,0.9)-t1;
	t2:=0.039*f(p[3],p[2],0.95);
	res[2]:=t1-t2;
	res[3]:=t2-0.035*f(a2,p[3],0.75);
end;

procedure J(P:v3; var J:m3x3);
var
	a,b,c,d:NReal;
begin
	a:=0.019*fx(p[1],a1,0.9);
	b:=0.036*fx(p[2],p[1],0.8);
	c:=0.039*fx(p[3],p[2],0.95);
	d:=-0.035*fy(a2,p[3],0.75);

	{It easy to show that a,b,c,d>=0 and then the matrix
	J is a DIAGONALLY DOMINANT one, thus, Gaussian elimination can
	be carried out without row or column interchanges.}
	{

			| a+b    -b       0   |
			|                     |
	J =   | -b     b+c      -c  |
			|                     |
			| 0       -c      c+d |


	}

	J[1,1]:=a+b;
	J[1,2]:=-b;J[2,1]:=J[1,2];
	J[1,3]:=0; J[3,1]:=0;
	J[2,2]:=b+c;
	J[2,3]:=-c; J[3,2]:=-c;
	J[3,3]:=c+d;
end;

procedure SolveJB(var mJ:m3x3; var b:v3);
var
	k,j:integer;
	m:NReal;
begin
	for k:= 1 to 2 do
		for j:= k+1 to 3 do
		begin
			m:=-mj[j,k]/mj[k,k];
			mj[j,j]:=mj[j,j]+m*mj[k,j];
			b[j]:=b[j]+m*b[k];
		end;
	b[3]:=b[3]/mj[3,3];
	b[2]:=(b[2]-mj[2,3]*b[3])/mj[2,2];
	b[1]:=(b[1]-mj[1,2]*b[2])/mj[1,1]
end;



begin
	assign(output,'rrex22.out');
	append(output);
	IterationCount:=0;
	a1:=100;
	p[1]:=a1+(a2-a1)/4;
	p[2]:=50+(a2-a1)*2/4;
	p[3]:=50+(a2-a1)*3/4;
	a2:=100.01;
	residuals(p,x);
	writeln('=====================================');
	writeln('running with a1 = ', a1:8:3,' and a2 = ',a2:8:3);
	writeln('The initial value is P =');
	wrv3(p);
	writeln('The residuals for the initial P are:');
	wrv3(x);

{NR iteration }
repeat
	j(p,mj);    { compute the Jacobian }
	residuals(p,x);  { compute the residuals = f(p) }
	SOlveJB(mj,x);   { x:= inv(J)*residuals }
	minus(p,x);      { p:=p- inv(J)*f(p) }
	inc(IterationCount);
	SquareLongStep:=l2(x);
until SquareLongStep<1e-12;
	residuals(p,x);
	writeln('Number of Iteration: ',IterationCount);
	writeln('L2Norm of the residuals: ',sqrt(l2(x)):14:-4);
	writeln('The iteration was stopped when the L2norm of the step was: ',
		sqrt(squareLongStep):14:-4);
	writeln(' !!The result is: ');
	writeln('p1       p2          p3');
	wrv3(p);
	writeln('============================================');

	close(output);
end.






