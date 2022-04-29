program rddir;
uses
	Dos,ShareDos;
var
	f: file of Char;
begin
	FileMode:= Share_DenyBoth;
	assign(f,ParamStr(1));
	reset(f);
end.

