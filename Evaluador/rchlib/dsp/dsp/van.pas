program VAN;
uses
	Objects, dos, horrores, xMatDefs;

var
	fin, fout: TBufStream;
	actacum, Actualizador, acumVAN, x, tasa: NReal;
	N, long, k: LongInt;
	res: integer;


procedure help;
begin
	writeln(' VAN ::> (c) rch94  ');
	writeln(' Sintaxis: ');
	writeln(' VAN ingresos tasa salida ');
	writeln(' Se produce el archivo "salida" con el Valor Actual Neto');
	writeln(' de los ingresos del "ingresos" y tasa de descuento "tasa" ');
	writeln(' tasa = 0.1 significa 10%.');
	writeln(' Los valores del archivo de ingresos se consideraran en orden');
	writeln(' cronol¢gico. Si Ik es el k-‚simo n£mero del archivo, el VAN es:');
	writeln(' I1+I2/(1+tasa)+I3/(1+tasa)^2+....+In/(1+tasa)^(n-1)');
	halt(1);
end;

begin
	if paramCOunt<> 3 then help;

	fin.Init(ParamStr(1), stOpenRead, 40*1024);
	if fin.status <> stOk then error(' abriendo archivo: '+ParamStr(1));
	val( ParamStr(2), tasa, res);
	if res <> 0 then error(' "tasa" invalida');
	fout.Init(ParamStr(3), stCreate, 40*1024);
	if fout.status <> stOk then error(' abriendo archivo: '+ParamStr(3));
	long:= fin.GetSize;
	N:= long div SizeOf(NReal);
	if long mod SizeOf(NReal) <> 0 then error(' error de formato');
	acumVan:=0;
	actualizador:=1/(1+tasa);
	actacum:=1;
	for k:= 1 to N do
	begin
		fin.Read(x, SizeOf(NReal));
		acumVan:= acumVan+x*actacum;
		actacum:= actacum*actualizador;
	end;
	fout.write( acumVAN,SizeOf(NReal));
	fout.done;
	fin.done;
end.

