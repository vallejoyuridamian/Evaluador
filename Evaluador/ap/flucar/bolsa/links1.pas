{+doc
+NOMBRE:  LINKS1
+CREACION: 8/97
+AUTORES:  MARIO VIGNOLO
+MODIFICACION:
+REGISTRO:
+TIPO:  Unidad Pascal
+PROPOSITO: Esta unidad es un parche para permitir llamadas a
				unidades no referenciadas para evitar referencias circulares
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit Links1;
interface
uses
	AlgebraC, Lexemas32, xMatDefs, Horrores;

type

	TIndice = Integer;

	TFunc_Indice= function(var r: string; var rescod: integer):TIndice;
	TFunc_BarraPtr = function ( k: TIndice): pointer;
   


var
	{ Esta funcion se define el la unidad TYVS2, la cual se encarga de
	hacer el LINK en la inicializacion. }
	Func_IndiceDeNodo: TFunc_Indice;
	Func_BarraPtr: TFunc_BarraPtr;


function LeerNReal(var a: TFlujoLetras; var resultado: NReal):integer;
function LeerNInteger( var a: TFLujoLetras; var resultado: integer): integer;
function LeerNComplex( var a: TFLujoLetras; var resultado: complex): integer;

implementation




function LeerNReal(var a: TFlujoLetras; var resultado: NReal):integer;
label Check1;
var
	negativo:boolean;
	res: integer;
	r: string;
begin
	negativo:= false;
check1:
	getlexema(r,a);
	if r='N' then
	begin
		LeerNReal:= 114;
		exit;
	end;

	
	if r='-' then
	begin
		negativo:= true;
		goto check1;
	end;

	if r='+' then goto check1;
	val(r, resultado, res);
	if res <> 0 then error('convirtiendo a real');
	if negativo then resultado := -resultado;
	LeerNReal:= res;
end;

function LeerNInteger( var a: TFLujoLetras; var resultado: integer): integer;
label Check1;
var
	negativo:boolean;
	res: integer;
	r: string;
begin
	negativo:= false;
check1:
	getlexema(r,a);

	if r='-' then
	begin
		negativo:= true;
		goto check1;
	end;

	if r='+' then goto check1;
	val(r, resultado, res);
	if res <> 0 then error('convirtiendo a integer');
	if negativo then resultado := -resultado;
	LeerNInteger:= res;
end;

function LeerNComplex( var a: TFLujoLetras; var resultado: complex): integer;
label Check1;
var
	cs: string;
	negativo:boolean;
	res: integer;
	LeyendoParteReal: boolean;
	r: string;
begin
	negativo:= false;
	LeyendoParteReal:= true;
	cs:='';
check1:

	getlexema(r,a);

	if r='-' then
	begin
		negativo:= true;
		cs:=cs+' '+r;
		goto check1;
	end;

	if r='+' then
	begin
		cs:=cs+' '+r;
		goto check1;
	end;

	if leyendoParteReal then
	begin
		{ Parte Real }
		val(r, resultado.r, res);
		if negativo then resultado.r:= -resultado.r;
		if res <> 0 then error('convirtiendo a ParteReal');
		leyendoParteReal:= false;
		negativo:= false;
		cs:='';
		goto check1;
	end
	else { Parte Imaginaria }
	if res = 0 then
	begin
		if (pos('j',r)=1)or (pos('i',r)=1) then
		begin
			delete(r,1,1);
			if length(r) = 0 then getlexema(r,a);
			val(r, resultado.i, res);
			if negativo then resultado.i:= -resultado.i;
			if res <> 0 then error('convirtiendo a ParteImaginaria');
			cs:='';
		end
		else
		begin
			r:= cs+' '+r;
			PutLexema(r, a);
			resultado.i:=0;
		end;
	end;
	LeerNComplex:= res;
end;

end.

