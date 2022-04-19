program lcbxp;
uses
	lcb;

var
	f:text;


begin
	assign(f, 'LCB.pas');
	writeln(GetProposito(f));
end.
