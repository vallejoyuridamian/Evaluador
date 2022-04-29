{+doc
+NOMBRE: srchuses
+CREACION: 7.05.96
+AUTORES: rch
+REGISTRO:
+TIPO: programa pascal.
+PROPOSITO: listar dependencias de un módulo pascal.-
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
	Busca las cláusulas "uses".-
-doc}

program srchuses;


uses
	{$I xCrt},
	{$I xObjects},
	lexemas, horrores;





procedure procesarProgram( NombArch: string );
label
	fin;
var
	a: TFlujoLetras;
	lex: string;
	res: boolean;
	buscopuntoycoma: boolean;
	s: TBufStream;
	BuscoPrimerUses, BuscoSegundoUses, EsUnit: boolean;
	BuscoImplementation: boolean;
begin
	{$IFDEF WINDOWS}
  NombArch:= NombArch+#0;
	s.init(@NombArch[1], stOpenRead, 1024 );
	{$ELSE}
	s.init(NombArch, stOpenRead, 1024 );
	{$ENDIF}

	if s.status <> stok then error('No encuentro: '+nombArch);
	a.init(s);
  writeln(NombArch, ' ->');

	EsUnit:= false;

	Lexemas.EliminarComentariosLlaves:= true;
  BuscoPrimerUses:= true;
	while BuscoPrimerUses do
	begin
		GetLexema( lex, a);
		if not a.ok then goto fin;
		lex:= upstr(lex);
		if lex='INTERFACE' then EsUnit:= true
		else if lex='USES' then BuscoPrimerUses:= false;
  end;

  buscopuntoycoma:= true;
	Lexemas.EliminarComentariosLlaves:= false;
	if EsUnit then write('interface: ')
  else write('proguses: ');
	while buscopuntoycoma do
	begin
		GetLexema(lex, a);
		if not a.ok then goto fin;
    if (lex <> ';') then
		begin
			write(lex);
		end
		else
    begin
			buscopuntoycoma:= false;
			writeln(';');
    end;
	end;

	if not EsUnit then goto fin;

	Lexemas.EliminarComentariosLlaves:= true;

	BuscoImplementation:= true;
	while BuscoSegundoUses do
	begin
		GetLexema( lex, a);
		if not a.ok then goto fin;
		lex:= upstr(lex);
		if lex='IMPLEMENTATION' then BuscoImplementation:= false;
  end;
	write('implementation: ');

	BuscoSegundoUses:= true;
	while BuscoSegundoUses do
	begin
		GetLexema( lex, a);
		if not a.ok then goto fin;
		lex:= upstr(lex);
		if lex='USES' then BuscoSegundoUses:= false;
  end;

  buscopuntoycoma:= true;
	Lexemas.EliminarComentariosLlaves:= false;


	while buscopuntoycoma do
	begin
		if not a.ok then goto fin;
		GetLexema(lex, a);
		if (lex <> ';') then
		begin
			write(lex);
		end
		else
    begin
			buscopuntoycoma:= false;
			writeln(';');
    end;
	end;

fin:
	s.done;
end;
  

procedure lxErrFilt( codigo: byte); far;
var
	errstr: string;
begin
	if codigo <> 3 then
	begin
		str(codigo, errstr);
		error(errstr);
	end;
end;

begin
	lx_error:= lxErrFilt;
	assign( output, '');
	rewrite(output);
	procesarProgram(ParamStr(1));
	close(output);
end.

	





