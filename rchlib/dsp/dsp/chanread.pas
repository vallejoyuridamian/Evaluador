program xp01;

var
	m:array[1..512] of integer;

procedure readChanel(f:string);
var
	arch:text;
	r:string[255];
	PosCurve:integer;
	letra:char;
	k:integer;
	code:integer;

begin
	assign(arch,f);
	reset(arch);
	read(arch,r);
	PosCurve:=pos('CURVE',r);
	reset(arch);
	for k:= 1 to PosCurve+Length('CURVE') do
		read( arch,letra);
for k:= 1 to 512 do
begin
	r:='';
	letra:=' ';
	repeat
      r:=r+letra;
		read(arch,letra);
	until (letra = ',')or(letra = ';');
	val(r,m[k],code);

end;
end;

begin
	readChanel('canal2r1');
end.











