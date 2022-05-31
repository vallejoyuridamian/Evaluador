{+doc
+NOMBRE: Promedio
+CREACION: 6/8/93
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:   Calcula el promedio de un archivo de reales.
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}


program promedio;

uses
	xMatDefs, horrores;

var
	fin: file of NReal;
	suma, prom, v: NReal;
	n: longInt;

begin

	assign( fin, ParamStr(1));
	{$I-}
	reset(fin);
	{$I+}
	if ioresult <> 0 then error(' Abriendo archivo: '+ParamStr(1));
	n:=0;
	suma:= 0;
	while not EOF(fin) do
	begin
		read( fin, v);
		inc(n);
		suma:= suma+v;
	end;
	prom:= suma/n;
	close(fin);
	writeln(' El Promedio es: ', prom);
end.