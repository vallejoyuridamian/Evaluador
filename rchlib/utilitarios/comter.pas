{$M $800,$800,$800 }
program trs232;
uses
	xrs232, crt, runchild, horrores;

var
	terminar: boolean;
	local: boolean;
	scomando: string;

function SGetChar: char;
var
	res: integer;
	C: char;
begin
	repeat
		res:= GetChar(C);
		if res < 0 then writeln('GetChar: ', res);
	until res =0;
	SGetChar:= C;
end;


procedure SPutChar( C: char );
var
	res: integer;
begin
	repeat
		res:=PutChar(c);
		if res < 0 then writeln('PutChar: ',res);
	until res >=0;
end;


function SRB( var Buf; n: integer ): integer;
type
	laob = array[1..MaxInt] of char;
var
	c1, c0: byte;
	c: char;
	k: integer;
begin
	c1:=0;
	for k:= 1 to n do
	begin
		c:= SGetChar;
		c1:= c1 xor byte(c);
		laob(Buf)[k]:= C;
	end;
	c0:= byte(SGetChar);
	if c1 = c0 then SRB := 0
	else SRB:=-1;
end;

procedure SWB( var Buf; n: integer );
type
	laob = array[1..MaxInt] of char;

var
	c0: byte;
	c: char;
	k: integer;
begin
	c0:=0;
	for k:= 1 to n do
	begin
		C:=laob(Buf)[k];
		c0:= c0 xor byte(C);
		SPutChar(C);
	end;
	SPutChar( char( c0 ));
end;




function ReadStr( var s: string ): integer;
var
	C: char;
	res: integer;
begin
	res:= GetChar(C);
	if res >= 0 then
	begin
		s[0]:=C;
		if SRB(s[1], length(s)) <> 0 then error(' readstr ');
	end;
	ReadStr:= res;
end;

procedure WriteStr( s: string );
begin
	SPutChar(s[0]);
	SWB( s[1], length(s));
end;


procedure sendfile( s: string );
var
	f: file of char;
	res: integer;
	st: string;
	c: char;
	NOB: longint;
begin
	assign( f, s );
	{$I-}
	system.reset(f);
	{$I+}
	res:= ioresult;
	if res = 0 then
	begin
		NOB:=FileSize(f);
		SWB(NOB, SizeOf(NOB));
		while not eof(f) do
		begin
			read(f, c);
			sputchar(c);
		end;
		close(f);
	end
	else
	begin
		str(res, st);
		WriteStr( 'I/O err: '+st+' , abriendo archivo '+s);
	end;
end;


procedure getfile( s: string );
var
	f: file of char;
	res: integer;
	st: string;
	c: char;
	NOB: longint;
	k: longint;

begin
	assign( f, s );
	{$I-}
	system.rewrite(f);
	{$I+}
	res:= ioresult;
	if res = 0 then
	begin
		res:=SRB(NOB, SizeOf(NOB));
		for k:= 1 to NOB do
		begin
			C:=SGetChar;
			write(f, c);
		end;
		close(f);
	end
	else
	begin
		str(res, st);
		WriteStr( 'I/O err: '+st+' , creando archivo archivo '+s);
	end;
end;

procedure ProcesarComando( comando: string );
var
	C: char;
begin
	if pos('/', comando ) <> 1 then WriteStr('/wErr, los comandos deben empesar con / ')
	else
	begin
		delete(comando, 1, 1);
		if length(comando)=0 then WriteStr('/w la barra sola no es un comando')
		else
		begin
			C:= comando[1];
			delete(comando,1,1);
			Case C of
				'w': writeln( comando );
				's': SendFile( comando );
				'g': GetFile( comando );
				'c': RC( comando );
				'x': halt(0); { finaliza el programa }
				'h':
					begin
						WriteStr('/w .');
						WriteStr('/w Ayuda ComTer remoto. Ver. 1.0. RCh prod. 1995');
						WriteStr('/w ...');
						writeStr('/w Cualquier l¡nea que ingrese por el teclado que');
						writeStr('/w comienze con el caracter ''/'' ser  enviada como');
						writeStr('/w comando al ComTer remoto.');
						writeStr('/w Si las l¡neas no comienzan con ''/'' se interpretar n');
						writeStr('/w por el ComTer local.');
						writeStr('/w ...');
						writeStr('/w El  siguiente caracter de la l¡nea identifica el comnado.');
						writeStr('/w ...');
						writeStr('/w LISTA DE COMANDOS DE ComTer (remoto)');
						writeStr('/w w  Escribir en pantalla el resto de la l¡nea.');
						writeStr('/w s  Enviar el archivo con nombre el resto de la l¡nea.');
						writeStr('/w g  Recibir archivo con nombre resto de la l¡nea.');
						writeStr('/w c  Ejecuta como comando DOS el resto de la l¡nea.');
						writeStr('/w x  Termina el programa ComTer');
					end
			else { Case }
				WriteStr('/w '+C+'  no es un comando.');
			end { Case }
		end;
	end;
end;

function  readkeyln( var s: string ): integer;
begin
	if keypressed then
	begin
		readln(s);
		readkeyln:= 0
	end
	else
		readkeyln:=-1
end;



begin
	ClrScr;
	Install( 9600, modo1, hilos1, 400, 400 );
	reset;
	terminar:= false;

	while not terminar do
	begin
		if readkeyln( scomando ) >= 0 then
		begin
			if pos('/', scomando )= 1 then
			begin
				local:= false;
				writeStr(scomando);
			end
			else
			begin
				local:= true;
				scomando:= '/'+scomando;
				ProcesarComando(scomando);
			end;
		end;
		if readStr(scomando) >=0 then
		begin
			local:= false;
			procesarcomando(scomando)
		end;
	end;
end.

