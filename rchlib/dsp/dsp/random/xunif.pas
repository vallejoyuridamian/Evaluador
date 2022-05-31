program xunif;
uses
	Uniform;

var
	k: integer;
	f: text;

begin
	assign(f , 'tmp.xlt');
  rewrite(f);
	for k:= 1 to 1000 do writeln(f, Call_uni);
	close(f);
end.
