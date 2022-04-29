program t_matcer;

uses
	{$I xCrt}, MatReal;



var
	a: TMatR;
  k,j: integer;


begin
	ClrScr;
	a.init(2,2);
	for k:= 1 to 2 do
		for j:= 1 to 2 do a.pon_e(k,j, k+j);
	a.WriteM;
	a.Inv;
  a.writeM;
	a.ceros;
	a.WriteM;
  a.done;
end.