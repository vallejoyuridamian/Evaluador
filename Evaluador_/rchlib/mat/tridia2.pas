{+doc
+NOMBRE:tridia2
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Ampliacion de los servicios de manejo de sistemas TRI-DIAGONALES
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit tridia2;
interface
uses
	xMatDefs;
{=====================================================}

{ LU factorization  of a tridiagonal matrix using partial pivoting }
{ n is the number of rows and columns of the input matrix }
{ The posible Error is the singularity of the sistem, and it's
signals returnig ErrNo = 1. If no Error is detected then ErrNo = 0 is
returned  }
{ The result is returned in the vectors t1,t2,t3,t4, and in the boolean
array pivot }
{ The tridiagonal input matrix is t1,t2,t3 where t1 is the lower diagonal
t2 is the true diagonal and t3 is the upper diagonal }
{t1[1],t3[n],t4[n-1] and t4[n] has not meaning}

procedure Factor(var t1,t2,t3,t4; n:integer; var pivot; var ErrNo: integer);

{====================================================}

{
(Solve) comments:

Inputs:
	the LU factorization for a system of equations performed with the
procedure  (Factor), and stored in the arrays t1,t2,t3,t4.
	The array of boolean (pivot), has the information about the row-changes
needed when running (Factor).
	The array (b) is the right side hand in the system of equations.
	(n) The number of equations.

Outputs:
	(b) reodered taking into acount the row-interchanges made by (Factor)
}


procedure Solve(var t1,t2,t3,t4,b; n:integer; var pivot);

{======================================================}
implementation


type
	LVR = array[1..6000] of NReal;
	LVB = array[1..6000] of boolean;



procedure SwapVars(var x,y:NReal);
var
	z:NReal;
begin
	z:=x;
	x:=y;
	y:=z
end;



{ LU factorization  of a tridiagonal matrix using partial pivoting }
{ n is the number of rows and columns of the input matrix }
{ The posible Error is the singularity of the sistem, and it's
signals returnig ErrNo = 1. If no Error is detected then ErrNo = 0 is
returned  }
{ The result is returned in the vectors t1,t2,t3,t4, and in the boolean
array pivot }
{ The tridiagonal input matrix is t1,t2,t3 where t1 is the lower diagonal
t2 is the true diagonal and t3 is the upper diagonal }
{t1[1],t3[n],t4[n-1] and t4[n] has not meaning}

procedure Factor(var t1,t2,t3,t4; n:integer; var pivot; var ErrNo: integer);
label
	ExitLabel;

var
	k:integer;
	m:NReal;

begin
	LVR(t4)[n]:=0;
	LVR(t3)[n]:=0;
	LVR(t1)[1]:=0;
	LVB(pivot)[1]:=true;
	for k:= 1 to n-1 do
	begin
		ErrNo:=0;
		LVR(t4)[k]:=0;
		LVB(pivot)[k+1]:=true;
		if abs(LVR(t1)[k+1])>abs(LVR(t2)[k]) then
		begin {pivoting take place}

			{interchanges rows k and k+1}
			SwapVars(LVR(t1)[k+1],LVR(t2)[k]);
			SwapVars(LVR(t2)[k+1],LVR(t3)[k]);
			LVR(t4)[k]:=LVR(t3)[k+1];
			{LVR(t3)[k+1] := 0 , not needed }

			{notificates the interchange performed}
			LVB(pivot)[k]:=false;

			{LVB(pivot)[k+1]:=false;}

			if LVR(t2)[k]=0 then
			begin
				{The system is singular, Error No 1 take place }
				ErrNo :=1;
				goto ExitLabel;
			end;

			{perform the elimination}
			m:= LVR(t1)[k+1]/LVR(t2)[k];
			LVR(t1)[k+1]:=m; {Store the multiplier for this step }
			LVR(t2)[k+1]:=LVR(t2)[k+1]-m*LVR(t3)[k];
			LVR(t3)[k+1]:=-m*LVR(t4)[k];
		end

		else { row-change is not necessary in this step}
		begin
			if LVR(t2)[k]=0 then
			begin
				{The system is singular, Error No 1 take place }
				ErrNo :=1;
				goto ExitLabel;
			end;

			{perform the elimination}
			m:= LVR(t1)[k+1]/LVR(t2)[k];
			LVR(t1)[k+1]:=m; {Store the multiplier for this step }
			LVR(t2)[k+1]:=LVR(t2)[k+1]-m*LVR(t3)[k];
		end;
	end;
	ExitLabel:
end;


{
(Solve) comments:

Inputs:
	the LU factorization for a system of equations performed with the
procedure  (Factor), and stored in the arrays t1,t2,t3,t4.
	The array of boolean (pivot), has the information about the row-changes
needed when running (Factor).
	The array (b) is the right side hand in the system of equations.
	(n) The number of equations.

Outputs:
	(b) reodered taking into acount the row-interchanges made by (Factor)
}


procedure Solve(var t1,t2,t3,t4,b; n:integer; var pivot);
var
	k,j:integer;
	acum:NReal;

function ExtractLkj( k,j:integer):boolean;
var
	h:integer;
	ab:boolean;
begin
	if (j<k) and LVB(pivot)[k] then
	begin
		ab:=false;
		for h:= j to k-1 do ab:=ab or LVB(pivot)[h];
		if ab then ExtractLkj:=false
		else
			ExtractLkj:=true
	end
	else ExtractLkj:=false
end;

begin

	{ reordering (b) }
	for k:= 1 to n-1 do
		if LVB(pivot)[k]=false then
			SwapVars(LVR(b)[k],LVR(b)[k+1]);


	{ solving L y = b }
	{ the solution (y)  is stored in (b) }

	for k:=2 to n do
	begin
		acum:=0;
		for j:=1 to k do
			if ExtractLkj(k,j) then
				acum:=acum+LVR(t1)[j+1]*LVR(b)[j];
		LVR(b)[k]:=LVR(b)[k]-acum;
	end;



	{ solving U x = y }
	{ the solution (x) is stored in (b) }

	LVR(b)[n]:=LVR(b)[n]/LVR(t2)[n];
	for k:= n-1 downto 1 do
		if LVR(t4)[k] <> 0 then
			LVR(b)[k]:=(LVR(b)[k]-LVR(t3)[k]*LVR(b)[k+1]
				-LVR(t4)[k]*LVR(b)[k+2])/LVR(t2)[k]
		else
			LVR(b)[k]:=(LVR(b)[k]-LVR(t3)[k]*LVR(b)[k+1])/LVR(t2)[k]
end;








end.