uses
	netwks, WinCrt, fechhora;

var
	n:string;
	res: integer;
	f: text;

begin
	assign( f, 'c:\basura\blog.txt');
	{$I-}
	append(f);
	{$I+}
	if ioresult <> 0 then
		rewrite(f);
	res:= GetMachineName(n);
	writeln(f,  Fecha,',', Hora, ',' ,n );
	close(f);
end.