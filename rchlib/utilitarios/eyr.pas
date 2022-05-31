{+doc
+NOMBRE: eyr
+CREACION: 12.10.95
+AUTORES: rch
+REGISTRO:
+TIPO: program
+PROPOSITO: Encontrar y Remplazar un string por otro
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
	sintaxis: eyr str_buscada str_sust archent archsal
-doc}

program eyr;
uses
	{$I xCRT};

var
	ent, sal: text;
	e: string;
	r: string;
	l: string;

procedure Ayuda;
begin
	writeln(' eyr. (c)RCh.12.10.1995 ');
	writeln;
	writeln(' Encontrar Y Remplazar');
	writeln(' Sintaxis: ');
	writeln('       eyr str_enc archent str_rem archsal');
	writeln;
	writeln(' Se creara el archivo (archasal) igual al archivo (archin)');
	writeln(' pero sustituyendo las ocurrencias de (str_enc) con (str_rem)');
	halt(1);
end;

procedure strRemp(var linea, Enco, Remp: string);
var
	ne, ipos: integer;
begin
	ne:= length(enco);
	repeat
		ipos:= pos(enco, linea);
		if ipos > 0 then
		begin
			delete(linea, ipos, ne );
			insert(Remp, linea, ipos );
		end;
	until ipos = 0;
end;





begin
  if ParamCount <> 4 then Ayuda;
	e:= ParamStr(1);
	assign( ent, ParamStr(2));
  {$I-}
	reset(ent);
	{$I+}
	if ioresult <> 0 then
	begin
		writeln(' NO encuentro archivo de entrada: ', ParamStr(2) );
		halt(1)
	end;

  r:= ParamStr(3);
	assign( sal, ParamStr(4));
  {$I-}
	rewrite( sal );
	{$I+}
	if ioresult <> 0 then
	begin
		writeln(' No puedo crear el archivo de salida: ', ParamStr(4));
    halt(1)
	end;
	while not eof( ent ) do
	begin
		readln( ent, l);
		strRemp(l, e, r);
		writeln( sal, l);
	end;
	close(sal);
	close(ent);
end.

	 