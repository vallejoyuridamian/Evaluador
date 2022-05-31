program t_fddps;

uses
	{$I xCRT},
  xMatDefs,
	fddp;


var
	k: integer;
	a:f_normal;

	b:f_student;

	c:f_chiCuadrado;
	t:NReal;

begin
 a.init(
		0,0.5,
		10,
		0,1); 

 {
	b.init(6);
  }
 {c.init(11);
 }

	writeln(a.area_t(1.65));
	readln;
	readln;
	while true do
	begin 

      write(' area?: ');readln(t);
		writeln(' x : ',a.t_area(t));
	end;

end.



