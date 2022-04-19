{$N+,E+}
program txt_NR;
uses
	Objects, horrores, CRT, params;

var
	fout, fin: TBufStream;
	ts: string;
	campo, racionales: integer;


procedure help;
begin
		ClrScr;
		writeln('NR_txt............................rch93');
		writeln;
		writeln(' Sint xis:');
		writeln;
		writeln(' NR_txt ArchivoFuente ArchivoDestino [tipo [campo racionales]]');
		writeln;
		writeln(' Donde (ArchivoFuente) es un archivo de n£meros reales ');
		writeln(' del cual se leen n£meros en el formato especificado po-');
		writeln(' el par metro 3. Por defecto se intenta leer (extended),');
		writeln(' Los valores posibles de tipo son:');
		writeln('        real      ( 6 byte), ....( solo PASCAL )');
		writeln('        single    ( 4 byte), ....( float en C)');
		writeln('        double    ( 8 byte), y...( double en C)');
		writeln('        extended  (10 byte).  ...( long double en C)');
		writeln(' Para la identificaci¢n del tipo se tiene en cuenta s¢lo');
		writeln(' la primera letra y se ignora si es may£scula o min£scula.' );
		writeln('  Campo y Racionales especifican la cantidad de caracteres a');
		writeln(' utilizar por n£mero y la cantidad de cifras racionales a ');
		writeln(' incluir.');
		writeln(' Los valores por defecto son: campo = 12, racionales = -1');
		halt(1);
end;


procedure AbrirCrearArchivos;
begin
	fout.init(ParamStr(2), stCreate, 1024*10);
	if fout.status <>stOk then error(' creando archivo: '+ParamStr(2));

	fin.Init(ParamStr(1), stOpenRead, 1024* 10);
	if fin.status <> stOk then error(' Abriendo archivo: '+ParamStr(1));
end;


procedure leer_real;
var
	m: real;
	ndat: longInt;
	k:longint;
begin
	ndat:= fin.GetSize;
	if ndat mod SizeOf(m) <> 0 then
		error('integridad de datos, posiblemente especific¢ mal el tipo');

	ndat:= ndat div SizeOf(m);
	for k:=1 to Ndat do
	begin
		fin.read(fin, SizeOf(m));
		fout.writestr(@ts);
	end;
end;


procedure leer_single;
var
	m: single;
	ndat: longInt;
	k:longint;

begin
	ndat:= fin.GetSize;
	if ndat mod SizeOf(m) <> 0 then
		error('integridad de datos, posiblemente especific¢ mal el tipo');

	ndat:= ndat div SizeOf(m);

	for k:=1 to Ndat do
	begin
		fin.read(fin, SizeOf(m));
		fout.writestr(@ts);
	end;
end;



procedure leer_double;
var
	m: double;
	ndat: longInt;
	k:longint;

begin
	ndat:= fin.GetSize;
	if ndat mod SizeOf(m) <> 0 then
		error('integridad de datos, posiblemente especific¢ mal el tipo');

	ndat:= ndat div SizeOf(m);

	for k:=1 to Ndat do
	begin
		fin.read(fin, SizeOf(m));
		fout.writestr(@ts);
	end;
end;


procedure leer_extended;
var
	m: extended;
	ndat: longInt;
	k:longint;

begin
	ndat:= fin.GetSize;
	if ndat mod SizeOf(m) <> 0 then
		error('integridad de datos, posiblemente especific¢ mal el tipo');

	ndat:= ndat div SizeOf(m);

	for k:=1 to Ndat do
	begin
		fin.read(fin, SizeOf(m));
		fout.writestr(@ts);
	end;
end;

var
	tipo: string;

begin
	campo:=12;
	racionales:=-1;

	if (ParamCount<2)or(ParamCount>5) then help;

	if ParamCount > 2 then tipo:= ParamStr(3)
	else tipo:='EXTENDED';

	if ParamCount > 3 then
		if ParamCount <> 5 then
			error(' Debe especificarse CAMPO y RACIONALES (los dos) ')
		else
		begin
			Campo:= ParamInteger(4);
			Racionales:= ParamInteger(5);
		end;

	
	AbrirCrearArchivos;
	case UpCase(tipo[1]) of
	'R': leer_real;
	'S': leer_single;
	'D': leer_double;
	'E': leer_extended;
	else error(' especificaci¢n de tipo NO VALIDA: '+tipo );
	end; {case}
	fout.done;
	fin.done;
end.