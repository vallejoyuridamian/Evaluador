unit uauxiliares;
{$IFDEF LINUX}
{$DEFINE REDEFINIR_RDLN}
{$ENDIF}

interface
uses

{$IFDEF LINUX}
   BaseUnix, Unix,
   errors,
{$ELSE}
   Windows,
   ShellApi,
{$IFNDEF FPC}
   Dialogs,
{$ENDIF}

{$ENDIF}
   SysUtils, xmatdefs, Classes, StrUtils;


{***********************************}
{ Constantes y Funciones auxiliares }
{-----------------------------------}
const
{ valor mínimo admisible }
	potEpsilon= 0.1;
  cpEpsilon= 0.01;

{$IFNDEF WINDOWS}
  //Constantes para resultados de MessageBox
  IDOK = 1;          ID_OK = IDOK;
  IDCANCEL = 2;      ID_CANCEL = IDCANCEL;
  IDABORT = 3;       ID_ABORT = IDABORT;
  IDRETRY = 4;       ID_RETRY = IDRETRY;
  IDIGNORE = 5;      ID_IGNORE = IDIGNORE;
  IDYES = 6;         ID_YES = IDYES;
  IDNO = 7;          ID_NO = IDNO;
  IDCLOSE = 8;       ID_CLOSE = IDCLOSE;
  IDHELP = 9;        ID_HELP = IDHELP;
  IDTRYAGAIN = 10;
  IDCONTINUE = 11;
{$ENDIF}

type
	TEstacion = ( verano, otonio, invierno, primavera );


function boolToSiNo(b: boolean): String;
function MesOfSem( isem: integer ): integer;
function EstacionOfSem( isem: integer ): TEstacion;
function EstacionOfMes( imes: integer ): TEstacion;

{ si x < cpEpsilon; result:= cpEpsilon sino result:= x }
procedure cpSupEpsilon( var x: NReal );

{ si x < potEpsilon; result:= potEpsilon sino result:= x }
procedure potSupEpsilon( var x: NReal );

{ retorna TRUE si paso esta en [paso1, paso2] }
function PasoEnRango( paso1, paso, paso2: integer ): boolean;

{ retorna el paso correspondiente al par (ano,sem).
result:= ano*52+sem }
function AnoSemToPaso( ano, sem: integer ): integer;

{$IFDEF REDEFINIR_RDLN}
procedure readln( var f: text; var r: string );
{$ENDIF}

// Lee líneas hasta encontrar la proxima no vacía y la devuelve.
// Si llega el fin del archivo retorna ''
function ProximaLineaNoVacia( var f: text ): String;

function getnextpal( var sres, s: string; const sep: string ): boolean;
function NextBool(var s: string ): boolean;
function NextFloat( var s: string ): NReal;
function NextInt( var s: string ): integer;
function NextPal(var s: string ): string; overload;

//Busca igual que NextPal, pero ignora los espacios, ',' y ';'
function NextStr(var s: string ): string;

// elimina las primeras NSkip palabras de línea y retorna la siguiente
// palabra.
function NextPal_SkipN( var linea: string; NSkip: integer): string;

function NextStrParam( var s: string; Nombre: string  ): string; overload;
function NextFloatParam( var s: string; Nombre: string ): NReal; overload;
function NextIntParam( var s: string; Nombre: string ): integer; overload;

// estas funciones leen una línea y esperan Nombre [separador] valor
function ReadlnStrParam( var f: textfile; Nombre: string  ): string; overload;
function ReadlnFloatParam( var f: textfile; Nombre: string ): NReal; overload;
function ReadlnIntParam( var f: textfile; Nombre: string ): integer; overload;

function TextToDArrOfNReal( s: string; sepDec: char ): TDAOfNReal;
function TextToTMatOfNReal( lineas: TStrings; sepDec: char ): TMatOfNReal;

function InsertionSort_Creciente(const A: TDAOfNReal): TDAofNReal; overload;
function InsertionSort_Decreciente(const A: TDAOfNReal): TDAofNReal; overload;

procedure QuickSort_Creciente(var A: array of Integer ); overload;
procedure QuickSort_Creciente(var A: TDAOfNReal  ); overload;

// ordena el vecto A en forma creciente y hace los mismos cambios sobre el
// vector idxs.
procedure QuickSort_Creciente(var A: TDAOfNReal; var idxs: TDAOfNInt   ); overload;

procedure QuickSort_Decreciente(var A: array of Integer ); overload;
procedure QuickSort_Decreciente(var A: TDAOfNReal  ); overload;

// ordena el vecto A en forma decreciente y hace los mismos cambios sobre el
// vector idxs.
procedure QuickSort_Decreciente(var A: TDAOfNReal; var idxs: TDAOfNInt ); overload;

// Retorna A + (B-A)*alfa
function ponder( A, B, alfa: NReal ): NReal;

// Interpola en un vector entre dos valores extremos.
function interpolar( valores: TDAOfNReal; xmin, xmax: NReal; x: Nreal ): NReal;

function pertenece(valor: Cardinal ; const arreglo : TDAofNCardinal) : boolean; overload;
function pertenece(valor: Integer ; const arreglo : TDAofNInt) : boolean; overload;
function pertenece(valor: NReal ; const arreglo : TDAofNReal) : boolean; overload;
function pertenece(valor: Cardinal ; const arreglo : TDAofNCardinal; var posicion : Integer) : boolean; overload;
function pertenece(valor: Integer ; const arreglo : TDAofNInt; var posicion : Integer) : boolean; overload;
function pertenece(valor: NReal ; const arreglo : TDAofNReal; var posicion : Integer) : boolean; overload;

//Convierten un arreglo a string separando los valores con separador con el formato
//[length(arreglo); valor0  valor1  ... valorn]
//Si no se especifica separador se usa #9. Si no se especifica precision se
//usa 8 y decimales 3
function TDAOfNRealToString(const arreglo: TDAOfNReal) : String; overload;
function TDAOfNRealToString(const arreglo: TDAOfNReal; precision, decimales: Integer) : String; overload;
function TDAOfNRealToString(const arreglo: TDAOfNReal; precision, decimales: Integer; separador: String) : String; overload;

//Convierten un arreglo a string separando los valores con separador con el formato
//[valor0  valor1  ... valorn]
function TDAOfNRealToStringSinTamanio(const arreglo: TDAOfNReal; precision, decimales: Integer; separador: String) : String; overload;

//Convierte un arreglo a string con el formato
//valor0  valor1  ... valorn
//arreglo debe tener al menos 1 elemento
function TDAOfNRealToTabbedString(const arreglo: TDAOfNReal; precision, decimales: Integer): String;

//Convierte un arreglo a string con el formato
//Length(arreglo) valor0  valor1  ... valorn
function TDAOfNRealToTabbedStringConTamanio(const arreglo: TDAOfNReal; precision, decimales: Integer): String;

//Convierten un arreglo a string separando los valores con separador con el formato
//[length(arreglo); valor0  valor1  ... valorn]
function TDAOfNIntToString(const arreglo: TDAofNInt; separador: String): String;

function TDAOfNIntToStringSinTamanio(const arreglo: TDAofNInt; separador: String): String;
//Convierte un arreglo a string con el formato
//valor0  valor1  ... valorn
//arreglo debe tener al menos 1 elemento
function TDAOfNIntToTabbedString(const arreglo: TDAofNInt): String;

//Convierte un arreglo a string con el formato
//Length(arreglo) valor0  valor1  ... valorn
function TDAOfNIntToTabbedStringConTamanio(const arreglo: TDAofNInt): String;

//Convierten un arreglo a string separando los valores con separador con el formato
//[length(arreglo); valor0  valor1  ... valorn]
function TDAOfBooleanToString(const arreglo: TDAOfBoolean; separador: String; useBoolStrs: boolean): String;

//Convierte una TStringList a string separando los valores con separador con el formato
//[stringList.Count; valor0  valor1  ... valorn]
function TStringListToString(const stringList: TStringList; separador: String): String;

function nroOcurrencias(subCadena, cadena: String): Integer;

function quitarElementoTDAOfNCardinal(const arreglo: TDAofNCardinal; elem: Cardinal): TDAofNCardinal;

function clonarTList(original: TList): TList;

//Parsean un arreglo escrito con TDAOfXXXToString
procedure parseDAOfNreal( var A: TDAOfNreal; const xval: string );
procedure parseDAOfNInt( var A: TDAOfNInt; const xval: string );
procedure parseDAOfBoolean( var A: TDAOfBoolean; const xval: string );
procedure parseStringList( var A: TStringList; const xval: string );

procedure parsearReferencia(r : String; var claseDelReferido, nombreDelReferido: String );

{$IFDEF FPC}
procedure showmessage( s: string );
function MessageBox(msg: PAnsiChar; Caption: PAnsiChar): Integer;
{$ENDIF}

function TextFileToStr(const filename: String): String;

// para leer o salvar la sala hay que poner los globales
procedure setSeparadoresGlobales;
// para trabajar en el editor o exportar/importar de excel usamos los locales
procedure setSeparadoresLocales;

// Pone comillas al texto si hay espacios o tabuladores
function encomille(s: String): String;


function RunChildAndWAIT( apl: string;   params: array of String ):boolean;

// copia un archivo
function cp( archivoOrigen, archivoDestino: string ): boolean;

implementation

const
	 Separadores= [' ', ',', ';', #9, #10, #13];
   SeparadoresDeLineaYTab= [#9, #10, #13];


var
  cnt_GlobsSet: integer;
  local_ThousandSeparator: Char;
  local_DecimalSeparator: Char;
  local_DateSeparator: Char;
  local_ShortDateFormat: string;
  local_LongDateFormat: string;

procedure setSeparadoresGlobales;
begin
  inc( cnt_GlobsSet );
  sysutils.ThousandSeparator:= ' ';
  sysutils.DecimalSeparator:= '.';
  sysutils.DateSeparator:='/';
  sysutils.ShortDateFormat:= 'dd/MM/yyyy';
end;

procedure setSeparadoresLocales;
begin
  dec( cnt_GlobsSet );
  if cnt_GlobsSet = 0 then
  begin
    sysutils.ThousandSeparator:= local_ThousandSeparator;
    sysutils.DecimalSeparator:= local_DecimalSeparator;
    sysutils.DateSeparator:=local_DateSeparator;
    sysutils.ShortDateFormat:=  local_ShortDateFormat;
  end;
end;


function cp( archivoOrigen, archivoDestino: string ): boolean;
var
  f, fs: file;
  buff: array[0..102410-1] of byte; // ojo no pasarse de rosca que esto está en el stack.
  n: integer;
  res: integer;
  oldFileMode: integer;
begin
  oldFileMode:= filemode;
  filemode:= 0; // readonl
  assign( f, archivoOrigen );
  reset( f, 1 );
  filemode:= 1;
  assign( fs, archivoDestino );
  rewrite( fs, 1  );
  filemode:= OldFileMode;
  n:= 0; res:= 0;
  repeat
    blockread( f, buff, 102410, n );
    blockwrite( fs, buff, n, res );
  until ( n = 0 ) or ( n <> res );
  close( fs );
  close( f );
  result:= n= res;
end;

function encomille(s: String): String;
begin
  if (pos(' ', s) <> 0) or
     (pos(#9, s) <> 0) then
    result:= '"' + s + '"'
  else
    result:= s;
end;

function boolToSiNo(b: boolean): String;
begin
  if b then
    result:= 'si'
  else
    result:= 'no';
end;

{$IFDEF FPC}
procedure showmessage( s: string );
begin
   writeln;
   writeln('**********ATENCION *********');
   writeln(s );
   writeln('----------------------------');
   writeln('Presione ENTER para continuar ... ' );
   system.readln;
end;

function MessageBox(msg: PAnsiChar; Caption: PAnsiChar): Integer;
var
  i: Integer;
  input: Char;
begin
  writeln;
  write('**********');
  write(Caption);
  writeln('*********');
  writeln(msg);
  write('----------');
  for i:= 0 to length(Caption) -1 do
    write('-');
  writeln('---------');
  input:= #0;
  while (input <> 's') and (input <> 'n') do
  begin
    writeln('(S)i/(N)o: > ');
    Read(input);
    input:= LowerCase(input);
  end;
  if input = 's' then
    result:= IDYES
  else
    result:= IDNO;
end;
{$ENDIF}

function TextfileToStr(const filename: String): String;
var
  lineas: TStringList;
  s: String;
begin
  lineas:= TStringList.Create;
  lineas.LoadFromFile(filename);
  s:= lineas.Text;
  lineas.Free;
  result:= s;
end;


function ponder( A, B, alfa: NReal ): NReal;
begin
	result:= A + (B-A)*alfa;
end;

function InsertionSort_Creciente(const A: TDAOfNReal): TDAofNReal;
var
  i, j, tope, posNuevoElem: Integer;
  valor: NReal;
  res: TDAofNReal;
begin
  SetLength(res, length(A));
  tope:= 0;
  for i:= 0 to high(A) do
  begin
    posNuevoElem:= tope;
    valor:= A[i];
    for j:= 0 to tope -1 do
    begin
      if res[j] > valor then
      begin
        posNuevoElem:= j;
        break;
      end;
    end;

    for j:= tope downto posNuevoElem + 1 do
      res[j]:= res[j - 1];
    res[posNuevoElem]:= valor;
    inc(tope);
  end;
  result:= res;  
end;

function InsertionSort_Decreciente(const A: TDAOfNReal): TDAofNReal;
var
  i, j, tope, posNuevoElem: Integer;
  valor: NReal;
  res: TDAofNReal;
begin
  SetLength(res, length(A));
  tope:= 0;
  for i:= 0 to high(A) do
  begin
    posNuevoElem:= tope;
    valor:= A[i];
    for j:= 0 to tope -1 do
    begin
      if res[j] < valor then
      begin
        posNuevoElem:= j;
        break;
      end;
    end;

    for j:= tope downto posNuevoElem + 1 do
      res[j]:= res[j - 1];
    res[posNuevoElem]:= valor;
    inc(tope);
  end;
  result:= res;
end;

procedure QuickSort_creciente(var A: array of Integer);

	procedure Quick_Sort(var A: array of Integer; iLo, iHi: Integer);
	var
		Lo, Hi, Mid, T: Integer;
	begin
		Lo := iLo;
		Hi := iHi;
		Mid := A[(Lo + Hi) div 2];
		repeat
			while A[Lo] < Mid do Inc(Lo);
			while A[Hi] > Mid do Dec(Hi);
			if Lo <= Hi then
			begin
				T := A[Lo];
				A[Lo] := A[Hi];
				A[Hi] := T;
				Inc(Lo);
				Dec(Hi);
			end;
		until Lo > Hi;
		if Hi > iLo then Quick_Sort(A, iLo, Hi);
		if Lo < iHi then Quick_Sort(A, Lo, iHi);
	end;

begin
	Quick_Sort(A, Low(A), High(A));
end;



// ordena el vecto A en forma creciente y hace los mismos cambios sobre el
// vector idxs.
procedure QuickSort_Creciente(var A: TDAOfNReal; var idxs: TDAOfNInt   ); overload;
	procedure Quick_Sort(var A: TDAOfNReal; var idxs: array of Integer ; iLo, iHi: Integer);
	var
		Lo, Hi: Integer;
		T, Mid: NReal;
    Tidx: integer;

	begin
		Lo := iLo;
		Hi := iHi;
		Mid := A[(Lo + Hi) div 2];
		repeat
			while A[Lo] < Mid do Inc(Lo);
			while A[Hi] > Mid do Dec(Hi);
			if Lo <= Hi then
			begin
				T := A[Lo];
				A[Lo] := A[Hi];
				A[Hi] := T;

        Tidx:= idxs[Lo];
        idxs[Lo]:= idxs[Hi];
        idxs[Hi]:= Tidx;

				Inc(Lo);
				Dec(Hi);
			end;
		until Lo > Hi;
		if Hi > iLo then Quick_Sort(A, idxs, iLo, Hi);
		if Lo < iHi then Quick_Sort(A, idxs, Lo, iHi);
	end;

begin
	Quick_Sort(A, idxs, Low(A), High(A));
end;


procedure QuickSort_Creciente(var A: TDAOfNReal );

	procedure Quick_Sort(var A: TDAOfNReal ; iLo, iHi: Integer);
	var
		Lo, Hi: Integer;
		T, Mid: NReal;
	begin
		Lo := iLo;
		Hi := iHi;
		Mid := A[(Lo + Hi) div 2];
		repeat
			while A[Lo] < Mid do Inc(Lo);
			while A[Hi] > Mid do Dec(Hi);
			if Lo <= Hi then
			begin
				T := A[Lo];
				A[Lo] := A[Hi];
				A[Hi] := T;
				Inc(Lo);
				Dec(Hi);
			end;
		until Lo > Hi;
		if Hi > iLo then Quick_Sort(A, iLo, Hi);
		if Lo < iHi then Quick_Sort(A, Lo, iHi);
	end;

begin
	Quick_Sort(A, Low(A), High(A));
end;

//**************** DECRECIENTES
procedure QuickSort_Decreciente(var A: array of Integer);
	procedure Quick_Sort(var A: array of Integer; iLo, iHi: Integer);
	var
		Lo, Hi, Mid, T: Integer;
	begin
		Lo := iLo;
		Hi := iHi;
		Mid := A[(Lo + Hi) div 2];
		repeat
			while A[Lo] > Mid do Inc(Lo);
			while A[Hi] < Mid do Dec(Hi);
			if Lo <= Hi then
			begin
				T := A[Lo];
				A[Lo] := A[Hi];
				A[Hi] := T;
				Inc(Lo);
				Dec(Hi);
			end;
		until Lo > Hi;
		if Hi > iLo then Quick_Sort(A, iLo, Hi);
		if Lo < iHi then Quick_Sort(A, Lo, iHi);
	end;

begin
	Quick_Sort(A, Low(A), High(A));
end;

procedure QuickSort_Decreciente(var A: TDAOfNReal );

  procedure Quick_Sort(var A: TDAOfNReal ; iLo, iHi: Integer);
	var
		Lo, Hi: Integer;
		T, Mid: NReal;
	begin
		Lo := iLo;
		Hi := iHi;
		Mid := A[(Lo + Hi) div 2];
		repeat
			while A[Lo] > Mid do Inc(Lo);
			while A[Hi] < Mid do Dec(Hi);
			if Lo <= Hi then
			begin
				T := A[Lo];
				A[Lo] := A[Hi];
				A[Hi] := T;
				Inc(Lo);
				Dec(Hi);
			end;
		until Lo > Hi;
		if Hi > iLo then Quick_Sort(A, iLo, Hi);
		if Lo < iHi then Quick_Sort(A, Lo, iHi);
	end;

begin
	Quick_Sort(A, Low(A), High(A));
end;




procedure QuickSort_Decreciente(var A: TDAOfNReal; var idxs: TDAOfNInt );

  procedure Quick_Sort(var A: TDAOfNReal; var idxs: TDAOfNInt ; iLo, iHi: Integer);
	var
		Lo, Hi: Integer;
		T, Mid: NReal;
    Tidx: integer;
	begin
		Lo := iLo;
		Hi := iHi;
		Mid := A[(Lo + Hi) div 2];
		repeat
			while A[Lo] > Mid do Inc(Lo);
			while A[Hi] < Mid do Dec(Hi);
			if Lo <= Hi then
			begin
				T := A[Lo];
				A[Lo] := A[Hi];
				A[Hi] := T;

        Tidx:= idxs[Lo];
        idxs[Lo]:= idxs[Hi];
        idxs[Hi]:= Tidx;

				Inc(Lo);
				Dec(Hi);

			end;
		until Lo > Hi;
		if Hi > iLo then Quick_Sort(A, idxs, iLo, Hi);
		if Lo < iHi then Quick_Sort(A, idxs, Lo, iHi);
	end;

begin
	Quick_Sort(A, idxs, Low(A), High(A));
end;

function TextToDArrOfNReal( s: string; sepDec: char ): TDAOfNReal;
var
	i: integer;
	tmpArr, tmpArr2: TDAOfNReal;
	cnt: integer;
	pal: string;
	r: NReal;
begin
	if sepDec <> '.' then
	begin
		i:= pos( '.', s );
		while i > 0 do
		begin
			delete( s, i, 1 );
			i:= pos( '.', s );
		end;

		for i:= 1 to length( s ) do
			if s[i]=sepDec then s[i]:= '.';
	end;

	setlength( tmpArr, 100 );

	cnt:= 0;

	pal:= nextpal( s );
	while pal <> '' do
	begin
		try
			r:= StrToFloat( pal );
			if cnt >= length( tmpArr ) then
			begin
				setlength( tmpArr2, length( tmpArr )+ 100 );
				for i:= 0 to high( tmpArr ) do
					tmpArr2[i]:= tmpArr[i];
				setlength( tmpArr, 0 );
				tmpArr:= tmpArr2;
			end;
			tmpArr[cnt]:= r ;
			inc( cnt );
		except
			showmessage('OJO, no logré interpretar : ('+pal+') como un número.' );
		end;
    pal:= nextpal( s );
	end;
	result:= copy( tmpArr, 0, cnt );
	setlength( tmpArr, 0 );
end;

function TextToTMatOfNReal( lineas: TStrings; sepDec: char ): TMatOfNReal;
var
  i, nNoVacias: Integer;
  res: TMatOfNReal;
begin
  SetLength(res, lineas.Count);
  nNoVacias:= 0;
  for i:= 0 to lineas.Count - 1 do
  begin
    if lineas[i] <> '' then
    begin
      res[nNoVacias]:= TextToDArrOfNReal(lineas[i], sepDec);
      nNoVacias:= nNoVacias + 1;
    end;
  end;
  if nNoVacias <> lineas.Count then
    res:= copy(res, 0, nNoVacias - 1);
  result:= res;
end;

{$IFDEF REDEFINIR_RDLN}
{ Lee una l¡nea sin importar si es UNIX o DOS }
procedure readln( var f: text; var r: string );
var
  c: char;
begin
  r:= '';
  c:='m';
  while not eof(f) and (c<> #10) do
	begin
	  read(f, c);
		r:= r+c;
	end;
  if length( r ) > 0 then
	if c=#10 then delete(r, length(r), 1 );
  if length( r ) > 0 then
		if r[length(r)]=#13 then delete(r, length(r), 1 );
end;
{$ENDIF}

// Lee líneas hasta encontrar la proxima no vacía y la devuelve.
// Si llega el fin del archivo retorna ''
function ProximaLineaNoVacia( var f: text ): String;
var
  linea: string;
begin
	Readln(f, linea);
	linea:= trim(linea);
	while not EOF(f) and (linea = '') do
	begin
		Readln(f, linea);
		linea:= trim(linea);
	end;
	result:= linea;
end;


{ saca la primer palabra del string s}
function NextPal(var s: string ):string;
var
	k1, k2: integer;
	ts: string;
begin
	k1:= 1;
	while (k1<= Length(s)) and (s[k1] in Separadores ) do inc(k1);
  k2:= k1;
	while (k2<= Length(s)) and not(s[k2] in Separadores) do inc(k2);
  ts:= copy(s, k1, k2-k1);
  delete(s, 1, k2);
	result:= ts;
end;

function NextStr(var s: string ): string;
var
	k1, k2: integer;
	ts: string;
begin
	k1:= 1;
	while (k1<= Length(s)) and (s[k1] in SeparadoresDeLineaYTab ) do inc(k1);
  k2:= k1;
	while (k2<= Length(s)) and not(s[k2] in SeparadoresDeLineaYTab) do inc(k2);
  ts:= copy(s, k1, k2-k1);
  delete(s, 1, k2);
	result:= ts;
end;

function getnextpal( var sres, s: string; const sep: string ): boolean;
var
	i: integer;
begin
	s:= trim( s );
  i:= pos( sep, s );
  if i > 0 then
	begin
		sres:= copy( s, 1, i-1);
		delete( s, 1, i-1+ length( sep ));
		result:= true;
  end
	else
	begin
		sres:= '';
		result:= false;
	end;
end;

function NextPal_SkipN( var linea: string; NSkip: integer): string;
var
  i: integer;
begin
  for i := 1 to NSkip do
      nextpal( linea );
  result:= nextpal( linea );
end;


function NextInt( var s: string ): integer;
begin
	result:= StrToInt( NextPal(s) );
end;

function NextBool(var s: string ): boolean;
begin
  result:= StrToBool(NextPal(s));
end;

function NextFloat( var s: string ): NReal;
begin
	result:= StrToFloat( NextPal(s));
end;

function NextStrParam( var s: string; Nombre: string ): string;
var
  ts: string;
begin
  ts:= nextPal( s );
  if pos( Nombre, ts ) > 0 then
    result:= nextPal( s )
  else
    raise Exception.Create('NextParam( '+Nombre+' ) Leí: '+ts+' y s:'+s );
end;

function NextFloatParam( var s: string; Nombre: string ): NReal;
var
  sval: string;
begin
  sval:= NextStrParam( s, nombre );
  result:= StrToFloat( sval )
end;

function NextIntParam( var s: string; Nombre: string ): integer; overload;
var
  sval: string;
begin
  sval:= NextStrParam( s, nombre );
  result:= StrToInt( sval )
end;

function ReadlnStrParam( var f: textfile; Nombre: string  ): string;
var
  r: string;
begin
  readln( f, r );
  result:= nextStrParam( r, Nombre );
end;

function ReadlnFloatParam( var f: textfile; Nombre: string ): NReal;
var
  r: string;
begin
  readln( f, r );
  result:= nextFloatParam( r, Nombre );
end;

function ReadlnIntParam( var f: textfile; Nombre: string ): integer;
var
  r: string;
begin
  readln( f, r );
  result:= nextIntParam( r, Nombre );
end;


function MesOfSem( isem: integer ): integer;
var
	m: integer;
begin
	m:= trunc(isem/52.0*12.0)+1;
	if m > 12 then
		MesOfSem:= 12
	else
		MesOfSem:= m;
end;


function EstacionOfMes( imes: integer ): TEstacion;
var
	r: TEstacion;
begin
	case imes of
		12,1,2: r:= verano;
		3,4,5: r:= otonio;
		6,7,8: r:= invierno;
		9,10,11: r:= primavera;
   else
      raise Exception.Create('auxiliares.pas, EstacionOfMes (imes fuera de rango )' );
	end;
	EstacionOfMes:= r;
end;

function EstacionOfSem( isem: integer ): TEstacion;
begin
	EstacionOfSem:= EstacionOfMes( MesOfSem( isem ));
end;

procedure cpSupEpsilon( var x: NReal );
begin
	if x < cpEpsilon then x:= cpEpsilon;
end;

procedure potSupEpsilon( var x: NReal );
begin
	if x < potEpsilon then x:= potEpsilon;
end;

{ retorna TRUE si paso está en [paso1, paso2] }
function PasoEnRango( paso1, paso, paso2: integer ): boolean;
begin
	PasoEnRango:= (paso1 <= paso) and (paso <= paso2);
end;

{ retorna el paso correspondiente al par ano,sem. }
function AnoSemToPaso( ano, sem: integer ): integer;
begin
	AnoSemToPaso:= ano* 52 +sem;
end;

function interpolar( valores: TDAOfNReal; xmin, xmax: NReal; x: Nreal ): NReal;
var
	rix: NReal;
	ix: integer;
	dx: NReal;
begin
	dx:= xmax- xmin;
	if dx <= AsumaCero then
		raise Exception.Create('ERROR, interpolar rango absurdo, xmin: '+FloatToStr(xmin)+' xmax: '+FloatToStr( xmax ));
	rix:= (x-xmin)/dx * high( valores );
	ix:= trunc( rix );
	if ix >= high( valores ) then
		result:= valores[ high( valores ) ]
	else
	begin
		rix:= frac( rix );
		result:= valores[ix]*( 1- rix )+ valores[ix+1] * rix;
	end;
end;

function pertenece(valor: Cardinal ; const arreglo : TDAofNCardinal) : boolean;
var
  i: Integer;
  res: boolean;
begin
  res:= false;
  for i:= 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      res:= true;
      break;
    end;
  result:= res;
end;

function pertenece(valor: Integer ; const arreglo : TDAofNInt) : boolean;
var
  i: Integer;
  res: boolean;
begin
  res:= false;
  for i:= 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      res:= true;
      break;
    end;
  result:= res;
end;

function pertenece(valor: NReal ; const arreglo : TDAofNReal) : boolean;
var
  i: Integer;
  res: boolean;
begin
  res:= false;
  for i:= 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      res:= true;
      break;
    end;
  result:= res;
end;

function pertenece(valor: Cardinal ; const arreglo : TDAofNCardinal; var posicion : Integer) : boolean;
var
  i: Integer;
begin
  posicion:= -1;
  for i:= 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      posicion:= i;
      break;
    end;
  result:= posicion <> -1;
end;

function pertenece(valor: Integer ; const arreglo : TDAofNInt; var posicion : Integer) : boolean;
var
  i: Integer;
begin
  posicion:= -1;
  for i:= 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      posicion:= i;
      break;
    end;
  result:= posicion <> -1;
end;

function pertenece(valor: NReal ; const arreglo : TDAofNReal; var posicion : Integer) : boolean;
var
  i: Integer;
begin
  posicion:= -1;
  for i:= 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      posicion:= i;
      break;
    end;
  result:= posicion <> -1;
end;

function TDAOfNRealToString(const arreglo: TDAOfNReal) : String;
begin
  result:= TDAOfNRealToString(arreglo, 12, 3, #9);
end;

function TDAOfNRealToString(const arreglo: TDAOfNReal; precision, decimales: Integer) : String;
begin
  result:= TDAOfNRealToString(arreglo, precision, decimales, #9);
end;

function TDAOfNRealToString(const arreglo: TDAOfNReal; precision, decimales: Integer; separador: String) : String;
var
  k: integer;
  res: String;
begin
  res:= '[' + IntToStr(length( arreglo )) +'; ';
  if length( arreglo ) > 0 then
  begin
    res:= res + FloatToStrF(arreglo[0], ffGeneral, precision, decimales);
    for k:= 1 to high(arreglo) do
      res:= res + separador + FloatToStrF(arreglo[k], ffGeneral, precision, decimales );
  end;
  res:= res + ']';
  result:= res;
end;

function TDAOfNRealToStringSinTamanio(const arreglo: TDAOfNReal; precision, decimales: Integer; separador: String) : String; overload;
var
  k: integer;
  res: String;
begin
  res:= '[';
  if length( arreglo ) > 0 then
  begin
    res:= res + FloatToStrF(arreglo[0], ffGeneral, precision, decimales);
    for k:= 1 to high(arreglo) do
      res:= res + separador + FloatToStrF(arreglo[k], ffGeneral, precision, decimales );
  end;
  res:= res + ']';
  result:= res;
end;

function TDAOfNRealToTabbedString(const arreglo: TDAOfNReal; precision, decimales: Integer): String;
var
  i: Integer;
  res: String;
begin
  res:= FloatToStrF(arreglo[0], ffGeneral, precision, decimales);
  for i:= 1 to high(arreglo) do
    res:= res + #9 + FloatToStrF(arreglo[i], ffGeneral, precision, decimales);
  result:= res;
end;

function TDAOfNRealToTabbedStringConTamanio(const arreglo: TDAOfNReal; precision, decimales: Integer): String;
var
  i: Integer;
  res: String;
begin
  res:= IntToStr(Length(arreglo));
  for i:= 0 to High(arreglo) do
    res:= res + #9 + FloatToStrF(arreglo[i], ffGeneral, precision, decimales);
  result:= res;
end;

function TDAOfNIntToString(const arreglo: TDAofNInt; separador: String): String;
var
  k: integer;
  res: String;
begin
  res:= '[' + IntToStr(length( arreglo )) +'; ';
  if length( arreglo ) > 0 then
  begin
    res:= res + IntToStr(arreglo[0]);
    for k:= 1 to high(arreglo) do
      res:= res + separador + IntToStr(arreglo[k]);
  end;
  res:= res + ']';
  result:= res;
end;

function TDAOfNIntToStringSinTamanio(const arreglo: TDAofNInt; separador: String): String;
var
  k: integer;
  res: String;
begin
  res:= '[';
  if length( arreglo ) > 0 then
  begin
    res:= res + IntToStr(arreglo[0]);
    for k:= 1 to high(arreglo) do
      res:= res + separador + IntToStr(arreglo[k]);
  end;
  res:= res + ']';
  result:= res;
end;

function TDAOfNIntToTabbedString(const arreglo: TDAofNInt): String;
var
  i: Integer;
  res: String;
begin
  res:= IntToStr(arreglo[0]);
  for i:= 1 to high(arreglo) do
    res:= res + #9 + IntToStr(arreglo[i]);
  result:= res;
end;

function TDAOfNIntToTabbedStringConTamanio(const arreglo: TDAofNInt): String;
var
  i: Integer;
  res: String;
begin
  res:= IntToStr(Length(arreglo));
  for i:= 0 to High(arreglo) do
    res:= res + #9 + IntToStr(arreglo[i]);
  result:= res;
end;

function TDAOfBooleanToString(const arreglo: TDAOfBoolean; separador: String; useBoolStrs: boolean): String;
var
  k: integer;
  res: String;
begin
  res:= '[' + IntToStr(length( arreglo )) +'; ';
  if length( arreglo ) > 0 then
  begin
    res:= res + BoolToStr(arreglo[0], useBoolStrs);
    for k:= 1 to high(arreglo) do
      res:= res + separador + BoolToStr(arreglo[k], useBoolStrs);
  end;
  res:= res + ']';
  result:= res;
end;

function TStringListToString(const stringList: TStringList; separador: String): String;
var
  k: integer;
  res: String;
begin
  res:= '[' + IntToStr(stringList.Count) + '; ';
  if stringList.Count > 0 then
  begin
    res:= res + stringList[0];
    for k:= 1 to stringList.Count - 1 do
      res:= res + separador + stringList[k];
  end;
  res:= res + ']';
  result:= res;
end;

function nroOcurrencias(subCadena, cadena: String): Integer;
var
  i, j, res: Integer;
begin
  res:= 0;
  i:= 1;
  while i < Length(cadena) - Length(subCadena) do
  begin
    j:= 1;
    while (j < Length(subCadena)) and (subCadena[j] = cadena[i + j]) do
      j:= j + 1;

    if j = Length(subCadena) then
    begin
      res:= res + 1;
      i:= i + j;
    end
    else
      i:= i + 1;
  end;
  result:= res;
end;

function quitarElementoTDAOfNCardinal(const arreglo: TDAofNCardinal; elem: Cardinal): TDAofNCardinal;
var
  res: TDAofNCardinal;
  i, iRes, n: Integer;
begin
  n:= Length(arreglo);
  if n > 0 then
  begin
    iRes:= 0;
    SetLength(res, n - 1);
    for i:= 0 to high(arreglo) do
      if arreglo[i] <> elem then
      begin
        res[iRes]:= arreglo[i];
        iRes:= iRes + 1;
      end;
  end
  else
    res:= NIL;
  result:= res;  
end;

function clonarTList(original: TList): TList;
var
  res: TList;
  i: Integer;
begin
  res:= TList.Create;
  res.Capacity:= original.Capacity;
  for i:= 0 to original.Count - 1 do
    res.Add(original[i]);
  result:= res;
end;

procedure parseDAOfNreal( var A: TDAOfNreal; const xval: string );
var
	k: integer;
	s: string;
	pal: string;
	N: integer;
begin
	s:= xval;
  if not getnextpal( pal, s, '[' ) then raise Exception.Create('Formato de array inválido debe comenzar con [ . ');
  if (not getnextpal( pal, s, '|' ) and
      not getnextpal( pal, s, ';')) then raise Exception.Create('Formato de array inválido debe tener la cantidad de elementos seguida de | o ; : [n|, [n; ');
	try
		N:=  StrToInt( pal );
	except
		raise Exception.Create( 'Formato de array inválido. La cantidad de elementos tienen que ser un entero. Es: ['+pal+'] (lo que está entre paréntesis rectos)');
	end; // try
  if N > 0 then
  begin
    setlength( A, N );
	  for k:= 0 to N-2 do
    begin
      if not getnextpal( pal, s, ',' ) then
	  	  raise Exception.Create('Formato de array inválido. Imposible encontrar la coma que marca el fin del elemento número: '+IntToStr( k+1 ));
      try
        A[k]:= StrToFloat( pal );
      except
        raise Exception.Create('Formato de array inválido. No pude convertir: ['+pal+'] a un número real procesando el elemento número: '+IntToStr( k+1));
		  end; // try
    end;
	  k:= N-1; // el último elemento lo procesamos aparte pues finaliza con ]
	  if not getnextpal( pal, s, ']' ) then
      raise Exception.Create('Formato de array inválido. Imposible encontrar la coma que marca el fin del último elemento del array.');
  	try
	    A[k]:= StrToFloat( pal );
  	except
	  	raise Exception.Create('Formato de array inválido. No pude convertir: ['+pal+'] a un número real procesando el elemento número: '+IntToStr( k+1));
  	end; // try
  end
  else
  begin
    if not getnextpal( pal, s, ']' ) then
      raise Exception.Create('Formato de array inválido. Imposible encontrar la coma que marca el fin del último elemento del array.');
    A := NIL;
  end
end;

procedure parseDAOfNInt( var A: TDAOfNInt; const xval: string );
var
	 k: integer;
	 s: string;
	 pal: string;
   N: integer;
begin
	 s:= xval;
	 if not getnextpal( pal, s, '[' ) then raise Exception.Create('Formato de array inválido debe comenzar con [ . ');
  if (not getnextpal( pal, s, '|' ) and
      not getnextpal( pal, s, ';')) then raise Exception.Create('Formato de array inválido debe tener la cantidad de elementos seguida de | o ; : [n|, [n; ');
	 try
			N:=  StrToInt( pal );
	 except
			raise Exception.Create( 'Formato de array inválido. La cantidad de elementos tienen que ser un entero. Es: ['+pal+'] (lo que está entre paréntesis rectos)');
	 end; // try
   setlength( A, N );
	 for k:= 0 to N-2 do
   begin
			if not getnextpal( pal, s, ',' ) then
				 raise Exception.Create('Formato de array inválido. Imposible encontrar la coma que marca el fin del elemento número: '+IntToStr( k+1 ));
      try
				 A[k]:= StrToInt( pal );
      except
				 raise Exception.Create('Formato de array inválido. No pude convertir: ['+pal+'] a un número entero procesando el elemento número: '+IntToStr( k+1));
			end; // try
	 end;
	 k:= N-1; // el último elemento lo procesamos aparte pues finaliza con ]
	 if not getnextpal( pal, s, ']' ) then
		 raise Exception.Create('Formato de array inválido. Imposible encontrar el ] que marca el fin del ultimo elemento del array.');
	 try
		 A[k]:= StrToInt( pal );
	 except
		 raise Exception.Create('Formato de array inválido. No pude convertir: ['+pal+'] a un número entero procesando el elemento número: '+IntToStr( k+1));
   end; // try
end;

procedure parseDAOfBoolean( var A: TDAOfBoolean; const xval: string );
var
	 k: integer;
	 s: string;
	 pal: string;
   N: integer;
begin
	 s:= xval;
	 if not getnextpal( pal, s, '[' ) then raise Exception.Create('Formato de array inválido debe comenzar con [ . ');
  if (not getnextpal( pal, s, '|' ) and
      not getnextpal( pal, s, ';')) then raise Exception.Create('Formato de array inválido debe tener la cantidad de elementos seguida de | o ; : [n|, [n; ');
	 try
			N:=  StrToInt( pal );
	 except
			raise Exception.Create( 'Formato de array inválido. La cantidad de elementos tienen que ser un entero. Es: ['+pal+'] (lo que está entre paréntesis rectos)');
	 end; // try
   setlength( A, N );
	 for k:= 0 to N-2 do
   begin
			if not getnextpal( pal, s, ',' ) then
				 raise Exception.Create('Formato de array inválido. Imposible encontrar la coma que marca el fin del elemento número: '+IntToStr( k+1 ));
      try
				 A[k]:= StrToBool( pal );
      except
				 raise Exception.Create('Formato de array inválido. No pude convertir: ['+pal+'] a un número entero procesando el elemento número: '+IntToStr( k+1));
			end; // try
	 end;
	 k:= N-1; // el último elemento lo procesamos aparte pues finaliza con ]
	 if not getnextpal( pal, s, ']' ) then
		 raise Exception.Create('Formato de array inválido. Imposible encontrar el ] que marca el fin del ultimo elemento del array.');
	 try
		 A[k]:= StrToBool( pal );
	 except
		 raise Exception.Create('Formato de array inválido. No pude convertir: ['+pal+'] a un número entero procesando el elemento número: '+IntToStr( k+1));
   end; // try
end;

procedure parseStringList( var A: TStringList; const xval: string );
var
	 k: integer;
	 s: string;
	 pal: string;
   N: integer;
begin
	 s:= xval;
	 if not getnextpal( pal, s, '[' ) then raise Exception.Create('Formato de array inválido debe comenzar con [ . ');
  if (not getnextpal( pal, s, '|' ) and
      not getnextpal( pal, s, ';')) then raise Exception.Create('Formato de array inválido debe tener la cantidad de elementos seguida de | o ; : [n|, [n; ');
	 try
			N:=  StrToInt( pal );
	 except
			raise Exception.Create( 'Formato de array inválido. La cantidad de elementos tienen que ser un entero. Es: ['+pal+'] (lo que está entre paréntesis rectos)');
	 end; // try

   A:= TStringList.Create;
   A.Capacity:= N;

	 for k:= 0 to N-2 do
   begin
			if not getnextpal( pal, s, ',' ) then
				 raise Exception.Create('Formato de array inválido. Imposible encontrar la coma que marca el fin del elemento número: '+IntToStr( k+1 ));
      A.add( pal );
	 end;
//	 k:= N-1; // el último elemento lo procesamos aparte pues finaliza con ]
	 if not getnextpal( pal, s, ']' ) then
		 raise Exception.Create('Formato de array inválido. Imposible encontrar el ] que marca el fin del ultimo elemento del array.');
	 A.add( pal );
end;

procedure parsearReferencia(r : String; var claseDelReferido, nombreDelReferido: String );
var
  i: Integer;
begin
  if pos( '<', r ) <> 1 then
		raise Exception.Create('ReadRefToCosa, Error(falta:<): Formato inválido: '+r+'.'{ Procesando línea: '+IntToStr( klinea )});
	System.delete( r, 1, 1); // borramos el < de apertura
	i:= pos( '>', r );
	if i = 0 then
		raise Exception.Create('ReadRefToCosa, Error(falta:>): Formato inválido: '+r+'.'{ Procesando línea: '+IntToStr( klinea )});
	if i < length( r ) then
		raise Exception.Create('ReadRefToCosa, Error( Hay caracteres después del > )'+r+'.'{ Procesando línea: '+IntToStr( klinea )});

  System.delete( r, i, 1 ); // borramos el > de cierre
	i:= pos('.', r );
	if i = 0 then
		raise Exception.Create('ReadRefToCosa, Error(falta:.): Formato inválido: '+r+'.'{ Procesando línea: '+IntToStr( klinea )});
	claseDelReferido:= copy(r, 1, i-1 );
  nombreDelReferido:= copy(r, i + 1, Length(r) - (i))
end;


{$IFDEF WINDOWS}
function RunChildAndWAIT( apl: string;   params: array of String ):boolean;
var
  proc_info: TProcessInformation;
  startinfo: TStartupInfo;
  ExitCode: longword;
  aplic, cmdline: string;
  k: integer;
begin
  aplic:= apl+#0;

  cmdline:= apl;
  if length( params ) > 0 then
    for k:= 0 to high( params ) do
      cmdline:= cmdline +' '+params[k];
  cmdline:= cmdline+#0;

  // Inicializamos las estructuras
  FillChar(proc_info, sizeof(TProcessInformation), 0);
  FillChar(startinfo, sizeof(TStartupInfo), 0);
  startinfo.cb := sizeof(TStartupInfo);

  // Intentamos crear el proceso
  if CreateProcess( @aplic[1], @cmdline[1], nil,
                    nil, false, NORMAL_PRIORITY_CLASS, nil, nil,
                    startinfo, proc_info) <> False then
  begin
    // El proceso se creó exitosamente
    // Ahora esperemos a que termine...
    while WaitForSingleObject(proc_info.hProcess, 10000) = WAIT_TIMEOUT do
      writeln( '.' );

    // Proceso finalizado. Ahora debemos cerrarlo.
    GetExitCodeProcess(proc_info.hProcess, ExitCode);  // Opcional
    CloseHandle(proc_info.hThread);
    CloseHandle(proc_info.hProcess);
    result:= true;
  end
  else
  begin
    result:= false;
  end;//if
end;
{$ELSE}

procedure DoProcesoHijo(apl: AnsiString;   params: array of String);
var
  i, error: Integer;
  paramsPChar, iter: PPChar;
begin
// OJO!!! no se que pasa que a la aplicación destino no le llegan los parámetros
  writeln('DoProcesoHijo, Apl: ', Apl );
  for i:= 0 to high( params ) do
    writeln( 'i: ', i , ' val: ', params[i] );

  Apl:= Apl + #0;
  GetMem(paramsPChar, (length(params) + 2) * SizeOf(PChar));
  iter:= paramsPChar;
  iter^:= @( Apl[1] );
  inc(iter);
  for i:= 0 to High(params) do
  begin
    params[i]:= params[i] + #0;
    iter^:= @(params[i][1]);
    inc(iter);
  end;
  iter^:= NIL;
  fpexecv( Apl, paramsPChar);

  //si vuelvo de fpexecv hubo error
  error:= fpgeterrno;
  writeln('uEmuladorWinIPC.DoProcesoHijo: error= ', error, ', ', strError( error ));

//	writeln(' *********** ERROR:::: el resultado de exec fue: ', res );

  freemem( paramsPChar, (length(params) + 2) * SizeOf(PChar) );
  fpexit( 0 ); // halt;
end;


function RunChildAndWAIT( apl: string;   params: array of String ):boolean;
var
	pid : Integer;
	status : Integer;
  aplx: AnsiString;
begin
	// init child process
	pid := fpfork();
	result:= pid >= 0;
	if pid = -1 then exit;

	if pid = 0 then
	begin
		// in child process - init grandchild
    aplx:= apl;
		doProcesoHijo( aplx, params )
	end
	else
	// in parent process - use waitpit to query for child process
		fpwaitpid(pid,@status,0);
end;
{$ENDIF}



initialization

  local_ThousandSeparator:= sysutils.ThousandSeparator;
  local_DecimalSeparator:= sysutils.DecimalSeparator;
  local_DateSeparator:= sysutils.DateSeparator;
  local_ShortDateFormat:= sysutils.ShortDateFormat;

  cnt_GlobsSet:= 0;

end.
