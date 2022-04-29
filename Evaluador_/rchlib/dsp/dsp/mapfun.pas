{$M  14048,0,14048}
program MapFun;

uses
	xMatDefs, Horrores, DOS, Params;
var
	x1, x2, dx, y1, y2, dy, m: NReal;
	x, y: NReal;
	k, j: integer;
	sal: text;
	fun: string;
	nx, ny: integer;

function fxy( x, y: NReal): NReal;
var
	Command: string;
	f, g: file of NReal;
	res: NReal;

begin


	{ Escribir par metros }
	assign(f, fun+'.ent');
	rewrite(f);
	write(f, x);
	write(f, y);
	close(f);

	Command:= '/C ' + fun;
	SwapVectors;
	Exec(GetEnv('COMSPEC'), Command);
	SwapVectors;
	if DosError <> 0 then
	error(' no puedo executar COMMAND.COM');

	{ Leer resultado }
	assign( f, fun+'.sal');
	reset(f);
	read(f, res);
	close(f);

	fxy:= res;
end;

procedure Help;
begin
	writeln(' (c) RCh 95 ');
	writeln(' Sintaxis: ');
	writeln('      mapfun  fun x1 x2 nx y1 y2 ny ');
	writeln;
	writeln(' Produce el archivo de salida (mapfun.xlt) el cual contiene');
	writeln(' la matriz de resultados de evaluar la funcion (fun) en una');
	writeln(' grilla de (nx) por (ny) puntos segun las x y los y respec..');
	writeln(' El archivo de salida esta en formato para excel. La primera');
	writeln(' fila contiene los valores de las (y) de la grilla como encabe-');
	writeln(' zamiento de las columnas. ');
	writeln(' Cada una de las filas comienza encabezada por el valore de la (x)');
	writeln(' a que corresponden.');
	writeln;
	writeln(' (fun) debe ser el nombre de un ejecutable que lee los parametros');
	writeln(' del archivo (fun.ent) y escribe el resultado en el archivo (fun.sal).');
	halt(1);
end;




begin
	if ParamCount<> 7 then help;

	fun:= ParamStr(1);
	x1:= ParamNReal(2);
	x2:= ParamNReal(3);
	nx:= ParamInteger(4);
	y1:= ParamNReal(5);
	y2:= ParamNReal(6);
	ny:= ParamInteger(7);

	dx:= (x2-x1)/(nx-1);
	dy:= (y2-y1)/(ny-1);

	assign( sal, 'mapfun.xlt');
	rewrite(sal);

	write(sal,' x');
	for j:= 1 to ny do
	begin
		y:= y1+dx*(j-1);
		write(sal, #9, y);
	end;
	writeln(sal);

	for k:= 1 to nx do
	begin
		x:= x1+(1-k)*dx;
		write( sal, x);
		for j:= 1 to ny do
		begin
			y:= y1+dx*(j-1);
			m:= fxy( x, y);
			write( sal, #9, m);
		end;
		writeln( sal );
	end;

	close(sal);
end.