program test01;
uses
	xMatDefs,
	tridia2;

type
	vr4 = array[1..4] of NReal;
	vb4 = array[1..4] of boolean;

const

	t1:vr4 = (0,3,6,9);
	t2:vr4 = (1,4,7,10);
	t3:vr4 = (2,5,8,0);
	t4:vr4 = (0,0,0,0);
	b:vr4 = (-3,10,-23,-13);


var
	result:integer;
	pivot:vb4;



begin
	factor(t1,t2,t3,t4,4,pivot,Result);
	Solve(t1,t2,t3,t4,b,4,pivot);
end.

