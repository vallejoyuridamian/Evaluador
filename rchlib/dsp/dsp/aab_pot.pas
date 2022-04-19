program aab_pot;

uses
	xMatDefs;
type

	tvr = array[1..6000] of NReal;
	tpvr = ^tvr;


var
	a0:NReal;
	pa,pb: tpvr;
	pp: tpvr;

	DosNMasUno, N:word;

	fin, fout:file;
	k:word;

procedure OutHelp;

begin
	writeln;
	writeln('AAB_POT..............................rch92');
	writeln(' sintaxis: aab_POT Fuente Destino ');
	writeln;
	writeln(' Fuente y Destino son archivos de Reales PASCAL');
	writeln(' Convierte de descripci¢n de una serie de Fourirer');
	writeln(' en senos y cosenos al espectro en potencia en barras');
	writeln(' En el archivo destino, se almacenan los datos con');
	writeln(' el siguiente formato: p0, p1, .., pN ');
	writeln('   Donde: ');
	writeln('  p0  = a0 * a0;   pk = ( ak*ak + bk*bk )/2 ');
	writeln;
	halt(1);
end;

procedure Error( x:string);
begin
	writeln;
	writeln('AAB_POT.......>ERROR: ');
	writeln;
	writeln(x);
	halt(1)
end;

begin
	if ParamCount<> 2 then OutHelp;
	assign(fin, ParamStr(1));
	{$I-}
	reset(fin,SizeOf(NReal));
	{$I+}

	if IOResult <> 0 then
		error(' No puedo abrir el archivo: '+ParamStr(1));

	DosNMasUno:=FileSize(fin);
	N:=(DosNMasUno - 1) div 2;

	if 2*N + 1 <> DosNMasUno then
		error('El n£mero de reales en el archivo fuente es incorrecto');

	GetMem(pa,N*SizeOf(NReal));
	GetMem(pb,N*SizeOf(NReal));
	BlockRead(fin,a0,1);
	BlockRead(fin,pa^,N);
	BlockRead(fin,pb^,N);
	close(fin);

	GetMem(pp,(N+1)*SizeOf(NReal));

	pp^[1]:=sqr(a0);

	for k:= 1 to N do
		pp^[k+1]:= (sqr(pa^[k]) + sqr(pb^[k]))/2;

	assign(fout,ParamStr(2));
	rewrite(fout, SizeOf(NReal));
	BlockWrite(fout,pp^, N+1);
	close(fout);

	FreeMem(pp,(N+1)*SizeOf(NReal));
	FreeMem(pb,N*SizeOf(NReal));
	FreeMem(pa,N*SizeOf(NReal));

end.