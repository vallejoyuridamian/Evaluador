program tstslvtd;
uses
	slvtrd;
type
	v4 = array[1..4] of real;
const
	d1:v4 = (-12000,1,1,-7800);
	d2:v4 = (2,2,2,-89000);
	d3:v4 = (1,1, -132312,-1243);
	cn:v4 = (5,5,5,0);
	rn:v4 = (1,1,1,-13415);
	it:v4 = (13,12,7,5);
	sol: v4 = (3,2,0,1);

begin
	SolveSpecialTriDia(d1,d2,d3,rn,cn,it,4);
end.