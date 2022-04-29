program aab_cn;


type
	tcx = record
		r,i:real
	end;

	tvr = array[1..10922] of real;
	tpvr = ^tvr;

	tvc = array[0..5460] of tcx;
	tpvc = ^tvc;


var
	a0:real;
	pa,pb: tpvr;
	pc: tpvc;

	DosNMasUno, N:word;

	fin, fout:file;
	k:word;

procedure OutHelp;
begin
	writeln;
	writeln('AAB_CN..............................rch92');
	writeln(' sintaxis: aab_cn Fuente Destino ');
	writeln;
	writeln(' Fuente y Destino son archivos de Reales PASCAL');
	writeln(' El Destino, puede ser leido tambi‚n como complejos');
	writeln(' Convierte de descripci¢n de una serie de Fourirer');
	writeln(' en senos y cosenos a la serie exponencial');
	writeln(' En el archivo destino, se almacenan los datos con');
	writeln(' el siguiente formato: c0, c1, .., cN ');
	writeln;
	writeln(' Como la se¤al se supone real, c[-k] = c[k].conjugado ');
	halt(1);
end;

procedure Error( x:string);
begin
	writeln;
	writeln('AAB_CN.......>ERROR: ');
	writeln;
	writeln(x);
	halt(1)
end;

begin
	if ParamCount<> 2 then OutHelp;
	assign(fin, ParamStr(1));
	{$I-}
	reset(fin,SizeOf(Real));
	{$I+}

	if IOResult <> 0 then
		error(' No puedo abrir el archivo: '+ParamStr(1));

	DosNMasUno:=FileSize(fin);
	N:=(DosNMasUno - 1) div 2;

	if 2*N + 1 <> DosNMasUno then
		error('El n£mero de reales en el archivo fuente es incorrecto');

	GetMem(pa,N*SizeOf(Real));
	GetMem(pb,N*SizeOf(real));
	BlockRead(fin,a0,1);
	BlockRead(fin,pa^,N);
	BlockRead(fin,pb^,N);
	close(fin);
	GetMem(pc,(N+1)*SizeOf(tcx));

	pc^[0].i:=0;
	pc^[0].r:=a0;

	for k:= 1 to N do
	begin
		pc^[k].r:= pa^[k]/2;
		pc^[k].i:= -pb^[k]/2;
	end;

	assign(fout,ParamStr(2));
	rewrite(fout, SizeOf(tcx));
	BlockWrite(fout,pc^, N+1);
	close(fout);

	FreeMem(pc,(N+1)*SizeOf(tcx));
	FreeMem(pb,N*SizeOf(real));
	FreeMem(pa,N*SizeOf(Real));

end.