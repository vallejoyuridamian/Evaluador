{+doc
+NOMBRE: lexemas
+CREACION:1.1.92
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:FLujo de Letras y Lexemas.
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit Lexemas;
interface

uses
	ubstream;

const
	EliminarComentariosLlaves:boolean = true;

	err_FinArchivo = 1;
	err_BULLleno = 2;
  err_LetraNoAutorizada = 3;

	ESC = #27;
	CEOF = chr(27);
	LF = chr(10);
	CR = chr(13);
	TAB = chr(9);


	Transparentes = [' ', LF, CR, TAB];
  {$IFDEF WINDOWS}
	Letras = ['a'..'z','A'..'Z','0'..'9','_','''','á','é','í','ó','ú','ñ','Ñ','?','$'];
  {$ELSE}
	Letras = ['a'..'z','A'..'Z','0'..'9','_','''',' ','‚','¡','¢','£','¤','¥','?','$'];
  {$ENDIF}


	Cualificadores = ['.','\','^','@','#'];
	Separadores = ['(',')', ',' , ';','[',']',':','|','{','}' ];
	Operadores = ['+','-','*','=','/','<','>'];


const
	LongKeyBuffer = 150;



type

	TFlujoLetras = object
		pf: PStream;
		KeyBuffer : array[0..LongKeyBuffer-1]of char;
    BufferReadIndex,BufferWriteIndex:integer;

    constructor Init( var XF: TStream ); 
		procedure TomoLetra( var c: char);
		procedure DevuelvoLetra( c: char);
		procedure EsperarLetra(xc:char);
		function ok: boolean;
	end;




procedure GetLexema( var lexema: string; var FlujoLetras: TFlujoLetras );
procedure PutLexema( var lexema: string; var FlujoLetras: TFlujoLetras );

function BuscarLexema( 	lexema: string; var FlujoLetras: TFlujoLetras;
								IgnorarMaMi: boolean): boolean;
function UpStr( s: string ):string;
function UpCase( c: char ):char;

var
	lx_Error : procedure ( codigo: byte);

procedure DefErrProc( codigo: byte);


implementation





function UpStr( s: string ):string;
var
	k:integer;

begin
	for k:= 1 to length(s) do s[k]:= UpCase(s[k]);
	UpStr:= s;
end;


function UpCase( c: char ):char;
begin
	case c of
		{$IFDEF WINDOWS}
		'á': UpCase:= 'A';
		'é': UpCase:= 'E';
		'í': UpCase:= 'I';
		'ó': UpCase:= 'O';
		'ú': UpCase:= 'U';
		'ñ': UpCase:= 'Ñ';
		{$ELSE}
		' ': UpCase:= 'A';
		'‚': UpCase:= 'E';
		'¡': UpCase:= 'I';
		'¢': UpCase:= 'O';
		'£': UpCase:= 'U';
		'¤': UpCase:= '¥';
		{$ENDIF}
	else
			UpCase:= system.UpCase(c);
	end; {case}
end;



procedure DefErrProc( codigo: byte);
begin
	writeln(' OJO, Error en unidad Lexemas, err_nº: ', codigo);
end;



function BuscarLexema( 	lexema: string; var FlujoLetras: TFlujoLetras;
								IgnorarMaMi: boolean): boolean;
var
	encontrado: boolean;
	lex: string;
begin
	Encontrado:= false;
	if IgnorarMaMi then lexema:= UpStr(lexema);
	while (not encontrado) and (FlujoLetras.pf^.status=stOk) do
	begin
		GetLexema(lex, FlujoLetras);
		if IgnorarMaMi then lex:= UpStr(lex);
		if lex= Lexema then encontrado:= true;
	end;
	BuscarLexema:= encontrado;
end;





{ métodos de	TFlujoLetras }

function TFlujoLetras.ok: boolean;
begin
	ok:= pf^.status=stOk;
end;

procedure TFlujoLetras.TomoLetra(var c:char);
begin
	if BufferReadIndex <> BufferWriteIndex then
		begin
			BufferReadIndex:=(BufferReadIndex + 1) mod LongKeyBuffer;
         c:=KeyBuffer[BufferReadIndex];
		end
	else pf^.Read(c,1);
end;

procedure TFlujoLetras.DevuelvoLetra(c:char);
begin
	BufferWriteIndex:=(BufferWriteIndex + 1) mod LongKeyBuffer;
	if BufferWriteIndex = BufferReadIndex then
		begin
			dec(BufferWriteIndex);
			if BufferWriteIndex <0 then BufferWriteIndex:=LongKeyBuffer-1;
			lx_Error(err_BULLleno);
		end
	else
		KeyBuffer[BufferWriteIndex]:=c;
end;


procedure TFlujoLetras.EsperarLetra(xc:char);
var
	c:char;
begin
	c:=#0;
	repeat
		TomoLetra(c);
	until c = xc;
end;


constructor TFlujoLetras.Init( var XF: TStream);
begin
	pF:= @XF;
	BufferWriteIndex:=0;
	BufferReadIndex:=0;
end;



procedure GetLexema( var lexema: string; var FlujoLetras: TFlujoLetras );
label
	lbl1;
var
	OrgFPos: LongInt;
	c:char;
  fin: boolean;
begin
	lexema:='';
	fin:= false;

lbl1:
  { Salta transparentes }
	repeat FlujoLetras.TomoLetra(c) until not ( c in Transparentes );

	{ Eliminacion de comentarios }
	if EliminarComentariosLlaves then
		if c ='{' then
		begin
			repeat
				FlujoLetras.TomoLetra(c);
				{write(c)}
			until c = '}';
			goto Lbl1;
		end;

	if c in (Separadores + Operadores) then lexema := c
	else
  	if c in ( letras + cualificadores) then 
		begin
      repeat
				lexema:= lexema+c;
				FlujoLetras.TomoLetra(c);
			until not (c in (Letras + cualificadores ));
			FlujoLetras.DevuelvoLetra(c);
		end
		else
		begin
			{writeln('Letra No interpretada: ',c);}
			lx_Error(err_LetraNOAutorizada);
    end;
end;

procedure PutLexema( var lexema: string; var FlujoLetras: TFlujoLetras );
var
	c: char;
	k: integer;
begin

{ Este blanco está de más pero no daña }
	c:= ' ';
	FlujoLetras.DevuelvoLetra(c);

	{ Devolvemos el lexema propiamente }
 {	for k:= 1 to length(lexema) do ???
 me parece que estaba mal pero no lo verifique, cambio de acuerdo
 a lo que me parece.}
	
	for k:= length(lexema) downto 1 do
			FlujoLetras.DevuelvoLetra(lexema[k]);
	c:= ' ';
	FlujoLetras.DevuelvoLetra(c);

end;

begin
	lx_Error:= DefErrProc;
end.