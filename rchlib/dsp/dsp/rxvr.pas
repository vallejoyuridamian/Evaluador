{+doc
+NOMBRE: RxVR
+CREACION: 12.1993
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  Multiplicacion de un archivo de NReals por un NReal
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
	Sint xis:
		RxVR  NR Entrada Salida

	(NR) N£mero real por el que se multiplica.
	(Entrada) Archivo de NReals con los datos a multiplicar.
	(Salida) Archivo de NReals donde se guarda el resultado.
-doc}


program RxVR;
uses
	xMatDefs, Objects, horrores;

var
	sent, ssal: TBufStream;
	Ndats: LongInt;
	dato: NREal;
	k: longint;


procedure OJO(var s: TStream); far;
begin
	error('ERROR de STREAM');
end;

begin

	if ParamCount<> 3 then
	begin
		writeln('Sint xis:');
		writeln('		RxVR  NR Entrada Salida');
		halt(1);
	end;

	sent.init(ParamStr(2), StOpenRead, 1024*4);
	if sent.status<> stOk then error('Abriendo: '+ParamStr(2));
	ssal.init(ParamStr(3), StCreate, 1024*4);
	if ssal.status<> stOk then error('Abriendo: '+ParamStr(3));
	StreamError:=@OJO;

	NDats:= sent.GetSize div SizeOf(NReal);
	if sent.GetSize<>( NDats*SizeOf(NReal)) then error('OJO, La entrada no es un archivo de NReals');
	for k:= 1 to NDats do
	begin
		sent.read(dato, SizeOf(NReal));
		ssal.write(dato, SizeOf(NReal));
	end;
	ssal.done;
	sent.done;

end.