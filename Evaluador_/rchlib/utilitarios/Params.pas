{+doc
+NOMBRE:params
+CREACION: 27/7/93
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: facilidad para lectura de par metros en la l¡nea de comandos
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}
unit Params;

interface
uses
	SysUtils, xMatDefs, horrores, lexemas32;


const
	ModoIgnorarMayusculasMinusculas: boolean = true;

function ParamInteger( npar: word): Integer;
function ParamLongInt( npar: word): LongInt;
function ParamNReal( npar: word ): NReal;

{ Busca el índice del modificador en la línea de parámetros.
Si el modificador no se encuentra como un parámetro el resultado
es -1.
Ej.   si la líne de parámetros es: "par1 -a lleno -f archi"
Si preguntamos por el indice de "-a" la respuesta será 2.
Si preguntamos por el indice de lleno la respuesta será 3.}
function IndiceParamModif( Modificador: string ): integer;

function ModifStr( s: string; var param: string): boolean;
function ModifInteger( s: string; var param: integer ):boolean;
function ModifLongInt( s: string; var param: longint ):boolean;
function ModifNReal( s: string; var param: NReal ):boolean;

implementation

function IndiceParamModif( Modificador: string ): integer;
var
	k: integer;
	ModificadorPresente: boolean;
	s, ts: string;
begin
	if ModoIgnorarMayusculasMinusculas then s:= UpStr(Modificador);
	ModificadorPresente:= false;
	k:= 1;
	while (k<= ParamCount)and( not ModificadorPresente ) do
	begin
		ts:= ParamStr(k);
		if ModoIgnorarMayusculasMinusculas then ts:=UpStr(ts);
		if pos(s,ts)<>0 then ModificadorPresente:= true
		else inc(k);
	end;
	if ModificadorPresente then result:=k
	else result:= -1;
end;

function ModifStr( s: string; var param: string): boolean;
var
	k: integer;
	ts: string;
	letra: char;
begin
	k:= IndiceParamModif(s);
	if k<0 then
	begin
		ModifStr:= false;
	end
	else
	begin
		if ModoIgnorarMayusculasMinusculas then s:= UpStr(s);
		ts:= ParamStr(k);
		if ModoIgnorarMayusculasMinusculas then ts:=UpStr(ts);
		k:= pos(s,ts)+length(s);
		if k = 0 then error(' ModifStr: incoherencia ');
		param:='';
		if k<=length(ts) then letra:= ts[k]
		else letra:='/';
		while (k<=length(ts))and(not (letra in ({Cualificadores+}Operadores)))do
		begin
			param:=param+letra;
			inc(k);
			if k<=length(ts) then letra:= ts[k]
			else letra:='/';
		end;
		ModifStr:= true;
	end;
end;



function ModifInteger( s: string; var param: integer ):boolean;
var
	ts: string;
	r: integer;
	res:integer;
begin
	if ModifStr(s, ts) then
	begin
		val(ts,r,res);
		if res <> 0 then error( 'ParamInteger, par: '+s);
		param:= r;
		ModifInteger:= true;
	end
	else
		ModifInteger:= false;
end;

function ModifNReal( s: string; var param: NReal ):boolean;
var
	ts: string;
	r: NReal;
	res:integer;
begin
	if ModifStr(s, ts) then
	begin
		val(ts,r,res);
		if res <> 0 then error( 'ModifNReal, par: '+ts);
		param:= r;
		ModifNReal:= true;
	end
	else
		ModifNReal:= false;
end;




function ModifLongInt( s: string; var param: longint ):boolean;
var
	ts: string;
	r: LongInt;
	res:integer;
begin
	if ModifStr(s, ts) then
	begin
		val(ts,r,res);
		if res <> 0 then error( 'ParamInteger, par: '+s);
		param:= r;
		ModifLongInt:= true;
	end
	else
		ModifLongInt:= false;
end;



function ParamInteger( npar: word): Integer;
var
	s: string;
	r: integer;
	res:integer;
begin
	s:= ParamStr(npar);
	val(s,r,res);
	if res <> 0 then error( 'ParamInteger, par: '+s);
	ParamInteger:= r;
end;

function ParamLongInt( npar: word): LongInt;
var
	s: string;
	r: LongInt;
	res:integer;
begin
	s:= ParamStr(npar);
	val(s,r,res);
	if res <> 0 then error( 'ParamLongInt, par: '+s);
	ParamLongInt:= r;
end;

function ParamNReal( npar: word ): NReal;
var
	s: string;
	r: NReal;
	res:integer;
begin
	s:= ParamStr(npar);
	val(s,r,res);
	if res <> 0 then error( 'ParamNReal, par: '+s);
	ParamNReal:= r;
end;



end.