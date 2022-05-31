program txt_NR;
uses
	Objects, horrores, CRT;

var
	fin:text;
	fout: TBufStream;


procedure help;
begin
		ClrScr;
		writeln('txt_NR............................rch93');
		writeln;
		writeln(' Sint xis:');
		writeln;
		writeln(' txt_NR ArchivoFuente ArchivoDestino [tipo]');
		writeln;
		writeln(' Donde (ArchivoFuente) es un archivo de texto del c£al,');
		writeln(' se lee un n£mero real de cada l¡nea y se lo escribe en');
		writeln(' el archivo destino que es un archivo de n£mero reales,');
		writeln(' el tipo exacto que se utiliza para escribir el archivo');
		writeln(' de salida es "extended" (10 bytes) salvo que se especi-');
		writeln(' fique alg£n otro. Los valores posibles de tipo son:');
		writeln('        real      ( 6 byte), ....( solo PASCAL )');
		writeln('        sigle     ( 4 byte), ....( float en C)');
		writeln('        double    ( 8 byte), y...( double en C)');
		writeln('        extended  (10 byte).  ...( long double en C)');
		writeln(' Para la identificaci¢n del tipo se tiene en cuenta s¢lo');
		writeln(' la primera letra y se ignora si es may£scula o min£scula.' );
		halt(1);
end;

procedure AbrirCrearArchivos;
begin
	assign(fin,ParamStr(1));
	{$I-}
	reset(fin);
	{$I+}
	if IOREsult <>0 then error(' abriendo archivo: '+ParamStr(1));

	fout.Init(ParamStr(2), stCreate, 1024* 10);
	if fout.status <> stOk then error(' Creando archivo: '+ParamStr(2));
end;


procedure sacar_real;
var
	m: real;
begin
	while Not Eof(fin) do
	begin
		readln(fin,m);
		fout.write(m,SizeOf(m));
	end;
end;


procedure sacar_single;
var
	m: single;
begin
	while Not Eof(fin) do
	begin
		readln(fin,m);
		fout.write(m,SizeOf(m));
	end;
end;



procedure sacar_double;
var
	m: double;
begin
	while Not Eof(fin) do
	begin
		readln(fin,m);
		fout.write(m,SizeOf(m));
	end;
end;


procedure sacar_extended;
var
	m: extended;
begin
	while Not Eof(fin) do
	begin
		readln(fin,m);
		fout.write(m,SizeOf(m));
	end;
end;

var
	tipo: string;

begin
	if (ParamCount< 2) or(ParamCount>3) then help;
	if ParamCount = 3 then tipo:= ParamStr(3)
	else tipo:='EXTENDED';
	AbrirCrearArchivos;
	case UpCase(tipo[1]) of
	'R': sacar_real;
	'S': sacar_single;
	'D': sacar_double;
	'E': sacar_extended;
	else error(' especificaci¢n de tipo NO VALIDA: '+tipo );
	end; {case}
	fout.done;
	close(fin);
end.