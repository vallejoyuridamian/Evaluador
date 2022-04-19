{rch92}
program Pon_yk;



var

	N:word;
	Suma:real;
	fin:file;
	k:word;
	y:real;
	z:string;
	res:integer;


procedure OutHelp;

begin
	writeln;
	writeln('Pon_Yk..............................rch92');
	writeln(' sintaxis: Pon_Yk Y k Destino ');
	writeln;
	writeln(' Donde Y es un n£mero que se considera real, ');
	writeln(' k es el indice dentro del archivo destino. ');
	writeln('   k = indica el primer real de Destino ');
	writeln(' La operaci¢n simb¢lica es: Destino[k] := y');
	writeln;
	halt(1);
end;

procedure Error( x:string);
begin
	writeln;
	writeln('Pon_Yk.......>ERROR: ');
	writeln;
	writeln(x);
	halt(1)
end;

begin
	if (ParamCount<> 3) then OutHelp;

	z:=ParamStr(1);
	Val(z,y,res);
	if res <> 0 then
		error(' Convirtiendo a real: '+ParamStr(1));
	z:=ParamStr(2);
	Val(z,k,res);
	if res <> 0 then
		error(' Convirtiendo a entero: '+ParamStr(2));


	assign(fin, ParamStr(3));
	{$I-}
	reset(fin,SizeOf(Real));
	{$I+}

	if IOResult <> 0 then
		error(' No puedo abrir el archivo: '+ParamStr(3));

	N:=FileSize(fin);

	if (k>N)or(k<1) then
	begin
		str(N,z);
		error(' Indice Fuera de rango ( rango v lido: [1..'+z+'])');
	end;

	Seek(fin, k-1);
	BlockWrite(fin, Y, 1);
	close(fin);
end.