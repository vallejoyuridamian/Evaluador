unit uauxiliares;
{$MODE DELPHI}

{$IFDEF LINUX}
{xDEFINE REDEFINIR_RDLN}
{$ENDIF}

interface

uses
{$IFDEF LINUX}
  BaseUnix, Unix,
  errors,
{$ELSE}
  Windows,

{$ENDIF}
 SysUtils,
 process,
 syncobjs,
 uzipper,
 xmatdefs, Classes;


{***********************************}
{ Constantes y Funciones auxiliares }
{-----------------------------------}
const
  { valor mínimo admisible }
  potEpsilon = 0.1;
  cpEpsilon = 0.01;

{$IFNDEF LCL}
  //Constantes para resultados de MessageBox
  idOk = 1;
  idCancel = 2;
  idAbort = 3;
  idRetry = 4;
  idIgnore = 5;
  idYes = 6;
  idNo = 7;
  IDCLOSE = 8;
  IDHELP = 9;
  IDTRYAGAIN = 10;
  IDCONTINUE = 11;
{$ENDIF}

{$IFDEF FPC-LCL}
{$IFDEF WINDOWS}
  ID_OK = idOk;
  ID_CANCEL = idCancel;
  ID_ABORT = idAbort;
  ID_RETRY = idRetry;
  ID_IGNORE = idIgnore;
  ID_YES = idYes;
  ID_NO = idNo;
  ID_CLOSE = IDCLOSE;
  ID_HELP = IDHELP;
{$ENDIF}
{$ENDIF}

type
  TEstacion = (verano, otonio, invierno, primavera);

resourcestring
  rs_ArrayErrorDeFormato_DebeComenzarCon =
    'Formato de array inválido debe comenzar con';
  rs_ArrayErrorDeFormato_CantidadDeElementos =
    'Formato de array inválido debe tener la cantidad de elementos seguida de';
  rs_ArrayErrorDeFormato_CantidadDeElementosNoEntera =
    'Formato de array inválido. La cantidad de elementos tienen que ser un entero.';
  rs_ElValorEspecificadoEs = 'El valor ingresado es';
  rs_CaracteresEntreParentesisRectos = 'Caractéres entre paréntesis rectos';
  rs_SI = 'SI';
  rs_NO = 'NO';

// Esta genérica para trancar y destrancar todo lo que precisemos.
var
  SeccionCriticaGenerica: TCriticalSection;

function boolToSiNo(b: boolean): string;
function MesOfSem(isem: integer): integer;
function EstacionOfSem(isem: integer): TEstacion;
function EstacionOfMes(imes: integer): TEstacion;

{ si x < cpEpsilon; result:= cpEpsilon sino result:= x }
procedure cpSupEpsilon(var x: NReal);

{ si x < potEpsilon; result:= potEpsilon sino result:= x }
procedure potSupEpsilon(var x: NReal);

{ retorna TRUE si paso esta en [paso1, paso2] }
function PasoEnRango(paso1, paso, paso2: integer): boolean;

{ retorna el paso correspondiente al par (ano,sem).
result:= ano*52+sem }
function AnoSemToPaso(ano, sem: integer): integer;

{$IFDEF REDEFINIR_RDLN}
procedure readln(var f: Text; var r: string);
{$ENDIF}

// Lee líneas hasta encontrar la proxima no vacía y la devuelve.
// Si llega el fin del archivo retorna ''
function ProximaLineaNoVacia(var f: Text): string;

{
 retorna la palabra hasta el separador. Si no encuentra el separador
 retonra FALSE y en sres el string vacío.
 si lo encuentra retorna TRUE y en sres la palabra y en s borra
 el prinicio del string hasta el separador "sep" inclusive.
 OJO, si no encuentra "sep" retorna "sres" y "s" vacío y result=false.
}
function getPalHastaSep(var sres, s: string; const sep: string): boolean;

{
 Retorna la próxima palabra hasta "sep" o el fin del string si no encuentra sep
 de "s" se quita la palabra y el separador.
}
function getNextPalSep(var s: string; const sep: string): string;

{
 Parsea el string s en palabras separadas por el string "sep"
 Retorna una lista con las palabras encontradas.
 Por defecto el separador es un blanco.
}
function getPalabras_lst( s: string; const sep: string = ' '): TStringList;

{
 Parsea el string s en palabras separadas por el string "sep"
 Retorna un array con las palabras encontradas.
 Por defecto el separador es un blanco.
}
function getPalabras_arr( s: string; const sep: string = ' '): TDAofString;


function NextBool(var s: string): boolean;
function NextFloat(var s: string): NReal;
function NextInt(var s: string): integer;
function NextPal(var s: string): string; overload;
function NextPalSinEspacio(var s: string): string;
//Busca igual que NextPal, pero ignora los espacios, ',' y ';'
function NextStr(var s: string): string;


// quita la primer linea de la lista y la devuelve
function NextLine( var sl: TStringList ): string; overload;

// busca hasta el #10 y retorna el comienzo quitandolo de s.
// si el comienzo termina con #13 se lo quita.
function NextLine( var s: string ): string; overload;

// elimina las primeras NSkip palabras de línea y retorna la siguiente
// palabra.
function NextPal_SkipN(var linea: string; NSkip: integer): string;

function NextStrParam(var s: string; Nombre: string): string; overload;
function NextFloatParam(var s: string; Nombre: string): NReal; overload;
function NextIntParam(var s: string; Nombre: string): integer; overload;

// estas funciones leen una línea y esperan Nombre [separador] valor
function ReadlnStrParam(var f: textfile; Nombre: string): string; overload;
function ReadlnFloatParam(var f: textfile; Nombre: string): NReal; overload;
function ReadlnIntParam(var f: textfile; Nombre: string): integer; overload;

function TextToDArrOfNReal(s: string; sepDec: char): TDAOfNReal;
function TextToTMatOfNReal(lineas: TStrings; sepDec: char): TMatOfNReal;

function InsertionSort_Creciente(const A: TDAOfNReal): TDAofNReal; overload;
function InsertionSort_Decreciente(const A: TDAOfNReal): TDAofNReal; overload;

procedure QuickSort_Creciente(var A: array of integer); overload;
procedure QuickSort_Creciente(var A: TDAOfNReal); overload;

// ordena el vecto A en forma creciente y hace los mismos cambios sobre el
// vector idxs.
procedure QuickSort_Creciente(var A: TDAOfNReal; var idxs: TDAOfNInt); overload;

procedure QuickSort_Decreciente(var A: array of integer); overload;

procedure QuickSort_Decreciente(var A: TDAOfNReal); overload;
procedure QuickSort_Decreciente( pA: pNReal; N: integer ); overload;


// ordena el vecto A en forma decreciente y hace los mismos cambios sobre el
// vector idxs.
procedure QuickSort_Decreciente(var A: TDAOfNReal; var idxs: TDAOfNInt); overload;



// Retorna A + (B-A)*alfa
function ponder(A, B, alfa: NReal): NReal;

// Interpola en un vector entre dos valores extremos.
function interpolar(valores: TDAOfNReal; xmin, xmax: NReal; x: Nreal): NReal;

function pertenece(valor: cardinal; const arreglo: TDAofNCardinal): boolean; overload;
function pertenece(valor: integer; const arreglo: TDAofNInt): boolean; overload;
function pertenece(valor: NReal; const arreglo: TDAofNReal): boolean; overload;
function pertenece(valor: cardinal; const arreglo: TDAofNCardinal;
  var posicion: integer): boolean; overload;
function pertenece(valor: integer; const arreglo: TDAofNInt;
  var posicion: integer): boolean; overload;
function pertenece(valor: NReal; const arreglo: TDAofNReal;
  var posicion: integer): boolean; overload;

//Convierten un arreglo a string separando los valores con separador con el formato
//[length(arreglo); valor0  valor1  ... valorn]
//Si no se especifica separador se usa #9. Si no se especifica precision se
//usa 8 y decimales 3
function TDAOfNRealToString(const arreglo: TDAOfNReal): string; overload;
function TDAOfNRealToString(const arreglo: TDAOfNReal;
  precision, decimales: integer): string; overload;
function TDAOfNRealToString(const arreglo: array of double; precision, decimales: integer;  separador: string; wall:char=';'): string; overload;

//Convierten un arreglo a string separando los valores con separador con el formato
//[valor0  valor1  ... valorn]
function TDAOfNRealToStringSinTamanio(const arreglo: TDAOfNReal;
  precision, decimales: integer; separador: string): string; overload;

//Convierte un arreglo a string con el formato
//valor0  valor1  ... valorn
//arreglo debe tener al menos 1 elemento
function TDAOfNRealToTabbedString(const arreglo: TDAOfNReal;
  precision, decimales: integer): string;

//Convierte un arreglo a string con el formato
//Length(arreglo) valor0  valor1  ... valorn
function TDAOfNRealToTabbedStringConTamanio(const arreglo: TDAOfNReal;
  precision, decimales: integer): string;

//Convierten un arreglo a string separando los valores con separador con el formato
//[length(arreglo); valor0  valor1  ... valorn]
function TDAOfNIntToString(const arreglo: array of Integer; separador: string; wall:char=';'): string;

function TDAOfNIntToStringSinTamanio(const arreglo: TDAofNInt;
  separador: string): string;
//Convierte un arreglo a string con el formato
//valor0  valor1  ... valorn
//arreglo debe tener al menos 1 elemento
function TDAOfNIntToTabbedString(const arreglo: TDAofNInt): string;

//Convierte un arreglo a string con el formato
//Length(arreglo) valor0  valor1  ... valorn
function TDAOfNIntToTabbedStringConTamanio(const arreglo: TDAofNInt): string;

//Convierten un arreglo a string separando los valores con separador con el formato
//[length(arreglo); valor0  valor1  ... valorn]
function TDAOfBooleanToString(const arreglo: array of boolean; separador: string;
  useBoolStrs: boolean; wall:char=';'): string;

//Convierte una TStringList a string separando los valores con separador con el formato
//[stringList.Count; valor0  valor1  ... valorn]
function TStringListToString(const stringList: TStringList; separador: string; wall:char=';'): string;

//Convierte un TDAOfString a string separando los valores con separador con el formato
//[length(TDAOfString); valor0  valor1  ... valorn]
function TDAOfStringToString(const DAOfString: array of string; separador: string; wall:char=';'): string;

function nroOcurrencias(subCadena, cadena: string): integer;

function quitarElementoTDAOfNCardinal(const arreglo: TDAofNCardinal;
  elem: cardinal): TDAofNCardinal;

function clonarTList(original: TList): TList;

//Parsean un arreglo escrito con TDAOfXXXToString
procedure parseDAOfNreal(var A: TDAOfNreal; const xval: string);
procedure parseDAOfNInt(var A: TDAOfNInt; const xval: string);
procedure parseDAOfBoolean(var A: TDAOfBoolean; const xval: string);
procedure parseDAOfString(var A: TDAOfString; const xval: string);
procedure parseStringList(var A: TStringList; const xval: string);
procedure parsearReferencia(r: string; var claseDelReferido, nombreDelReferido: string);

// elimina del array los elementos con trim( ) = ''
procedure clear_vacias(var palabras: TDAOfString);


{$IFNDEF LCL}
procedure ShowMessage(s: string);
function MessageBox(msg: PAnsiChar; Caption: PAnsiChar): integer;
{$ENDIF}

function TextFileToStr(const filename: string): string;


// para leer o salvar la sala hay que poner los globales
// esto es solo para arreglar un problema con las versiones <= 45
// que se salvan con fecha a la dd/MM/yyyy en lugar de ISO.
procedure setSeparadoresGlobales_FechaUruguaya_V45_;

// para leer o salvar la sala hay que poner los globales
procedure setSeparadoresGlobales;

// para trabajar en el editor usamos los locales
procedure setSeparadoresLocales;

// Pone comillas al texto si hay espacios o tabuladores o si es el string vacío
function encomille(s: string): string;

function RunChild(apl: string; params: array of string;
  EsperarFinDelHijo: boolean): boolean;

function RunChildAndWAIT(apl: string; params: array of string): boolean;

// corre el comando apl con los parametros pasados
// y le escribe la entrada en su entrada standar.
// Se captura la salida y se retorna como un TStringList
function RunPipe( apl: string; paramsLst: TStrings; entrada: TStringList; finDeLinea: string = #10 ): TStringList;


// copia un archivo
function cp(archivoOrigen, archivoDestino: string): boolean;

// elimina la BOM (Byte Order Mask) si existe al inicio de la línea.
// por seguridad siempre que leemos un archivo de texto debería
// llamar esto sobre la primera línea para sacarnos los problemas.
procedure eliminar_BOM(var linea: string);

// Retorna true si el primer caracter de pal no es '0' ni 'F' ni  'f'
function StrToBool(pal: string): boolean;


// Codifica una cadena para su transmisión vía HTTP
function HTTPEncode(const AStr: string): string;

// Decodifica una cadena codificada con HTTPEncode
function HTTPDecode(const AStr: string): string;

// Busca los archivos que cumplen el pattern dentro del path.
function getFileList ( path:String; pattern: string ):TStringList;



// Zipea una lista de archivos.
// 1  - Zippeo correctamente
// 0  - El nombre del zip ya existe y flg_override = false
// -1 - Lista vacia
// -2 - No encontro algun archivos
// -3 - No pudo zipear algun archivos
// Si zipName no tiene ".zip" se lo agrega al final.
function zipearListaDeArchivos(lst: TStringList; zipName: string; flg_override: boolean = false): integer;

// descomprime el contenido en la carpeta con mismo nombre que el archivo, sin
// la extensión.
procedure Unzip(archi_zip: string);


implementation

const
  Separadores = [' ', ',', ';', #9, #10, #13];
  SeparadoresSinEspacio = [',', ';', #9, #10, #13];
  SeparadoresDeLineaYTab = [#9, #10, #13];


var
  cnt_GlobsSet: integer;
  cnt_GlobsSet_UY45: integer;
  local_ThousandSeparator: char;
  local_DecimalSeparator: char;
  local_DateSeparator: char;
  local_ShortDateFormat: string;
  local_LongDateFormat: string;




  function zipearListaDeArchivos(lst: TStringList; zipName: string; flg_override: boolean = false ): integer;
  var
    fzip: TZipper;
    r: string;
    i: integer;

  begin

    Result := 1;

    fzip := TZipper.Create;
    if pos( '.zip' , zipname ) = 0 then
      fzip.FileName := zipname + '.zip'
    else
      fzip.FileName := zipname;

    if FileExists(fzip.FileName) then
    begin
      if flg_override then
        deletefile( fzip.FileName )
      else
      begin
        fzip.Free;
        Result := 0;
        Exit;
      end;
    end;

    if lst.Count = 0 then
    begin
      fzip.Free;
      Result := -1;
      Exit;
    end;

    for i := 0 to lst.Count - 1 do
    begin
      if not FileExists(lst.Strings[i]) then
      begin
        Result := -2;
        Break;
        fzip.Free;
        Exit;
      end
      else
      begin
        r := ExtractFileName(lst.Strings[i]);
        fzip.Entries.AddFileEntry(lst.Strings[i], r);
      end;
    end;

    try
      fzip.ZipAllFiles;
    except
      Result := -3;
    end;
    fzip.Free;
  end;


  procedure Unzip(archi_zip: string);
  var
    funzip: TUnZipper;
    carpeta: string;

  begin
    funzip := TUnZipper.Create;
    carpeta := ExtractFilePath(archi_zip);
    //  carpeta:= copy( archi_zip, 1, length( archi_zip ) - 4 );
    funzip.OutputPath := carpeta;
    funzip.UnZipAllFiles(archi_zip);
    funzip.Free;
  end;


function StrToBool(pal: string): boolean;
var
  c: char;
begin
  if length( pal ) = 0 then
  begin
    result:= false;
    exit;
  end;
  c := UpCase(pal[1]);
  Result := not ((c = '0') or (c = 'F') or (c = 'f'));
end;


// para leer o salvar la sala hay que poner los globales
procedure setSeparadoresGlobales_FechaUruguaya_V45_;
begin
  Inc(cnt_GlobsSet_UY45);
  SysUtils.DefaultFormatSettings.DateSeparator := '/';
  SysUtils.DefaultFormatSettings.ShortDateFormat := 'dd/MM/yyyy';
  SysUtils.DefaultFormatSettings.LongDateFormat := 'dd/MM/yyyy HH:mm:ss';
end;

procedure setSeparadoresGlobales;
begin
  SeccionCriticaGenerica.Enter;
  Inc(cnt_GlobsSet);
  SysUtils.DefaultFormatSettings.ThousandSeparator := ' ';
  SysUtils.DefaultFormatSettings.DecimalSeparator := '.';
  if (cnt_GlobsSet_UY45 = 0) then
  begin
    SysUtils.DefaultFormatSettings.DateSeparator := '-';
    SysUtils.DefaultFormatSettings.ShortDateFormat := 'yyyy-MM-dd';
    SysUtils.DefaultFormatSettings.LongDateFormat := 'yyyy-MM-dd HH:mm:ss';
  end;
  SeccionCriticaGenerica.Leave;
end;

procedure setSeparadoresLocales;
begin
  SeccionCriticaGenerica.Enter;
  Dec(cnt_GlobsSet);
  if cnt_GlobsSet = 0 then
  begin
    cnt_GlobsSet_UY45 := 0;
    SysUtils.DefaultFormatSettings.ThousandSeparator := local_ThousandSeparator;
    SysUtils.DefaultFormatSettings.DecimalSeparator := local_DecimalSeparator;
    SysUtils.DefaultFormatSettings.DateSeparator := local_DateSeparator;
    SysUtils.DefaultFormatSettings.ShortDateFormat := local_ShortDateFormat;
    SysUtils.DefaultFormatSettings.LongDateFormat := local_LongDateFormat;
  end;
  SeccionCriticaGenerica.Leave;
end;


function cp(archivoOrigen, archivoDestino: string): boolean;
var
  f, fs: file;
  buff: array[0..102410 - 1] of byte;
  // ojo no pasarse de rosca que esto está en el stack.
  n: integer;
  res: integer;
  oldFileMode: integer;
begin
  oldFileMode := filemode;
  filemode := 0; // readonl
  Assign(f, archivoOrigen);
  reset(f, 1);
  filemode := 1;
  Assign(fs, archivoDestino);
  rewrite(fs, 1);
  filemode := OldFileMode;
  n := 0;
  res := 0;
  repeat
    blockread(f, buff{%H-}, 102410, n);
    blockwrite(fs, buff, n, res);
  until (n = 0) or (n <> res);
  Close(fs);
  Close(f);
  Result := n = res;
end;




function encomille(s: string): string;
begin
  if (pos(' ', s) <> 0) or (pos(#9, s) <> 0) or ( length( s ) = 0) then
    Result := '"' + s + '"'
  else
    Result := s;
end;

function boolToSiNo(b: boolean): string;
begin
  if b then
    Result := rs_SI
  else
    Result := rs_NO;
end;

{$IFNDEF LCL}
procedure ShowMessage(s: string);
begin
  writeln;
  writeln('**********ATENCION *********');
  writeln(s);
  writeln('----------------------------');
  writeln('Presione ENTER para continuar ... ');
  system.readln;
end;

function MessageBox(msg: PAnsiChar; Caption: PAnsiChar): integer;
var
  i: integer;
  input: char;
begin
  writeln;
  Write('**********');
  Write(Caption);
  writeln('*********');
  writeln(msg);
  Write('----------');
  for i := 0 to length(Caption) - 1 do
    Write('-');
  writeln('---------');
  input := #0;
  while (input <> 's') and (input <> 'n') do
  begin
    writeln('(S)i/(N)o: > ');
    Read(input);
    input := LowerCase(input);
  end;
  if input = 's' then
    Result := idYes
  else
    Result := idNo;
end;

{$ENDIF}

function TextFileToStr(const filename: string): string;
var
  lineas: TStringList;
  s: string;
begin
  lineas := TStringList.Create;
  lineas.LoadFromFile(filename);
  s := lineas.Text;
  lineas.Free;
  Result := s;
end;

function ponder(A, B, alfa: NReal): NReal;
begin
  Result := A + (B - A) * alfa;
end;

function InsertionSort_Creciente(const A: TDAOfNReal): TDAofNReal;
var
  i, j, tope, posNuevoElem: integer;
  valor: NReal;
  res: TDAofNReal;
begin
  SetLength(res, length(A));
  tope := 0;
  for i := 0 to high(A) do
  begin
    posNuevoElem := tope;
    valor := A[i];
    for j := 0 to tope - 1 do
    begin
      if res[j] > valor then
      begin
        posNuevoElem := j;
        break;
      end;
    end;

    for j := tope downto posNuevoElem + 1 do
      res[j] := res[j - 1];
    res[posNuevoElem] := valor;
    Inc(tope);
  end;
  Result := res;
end;

function InsertionSort_Decreciente(const A: TDAOfNReal): TDAofNReal;
var
  i, j, tope, posNuevoElem: integer;
  valor: NReal;
  res: TDAofNReal;
begin
  SetLength(res, length(A));
  tope := 0;
  for i := 0 to high(A) do
  begin
    posNuevoElem := tope;
    valor := A[i];
    for j := 0 to tope - 1 do
    begin
      if res[j] < valor then
      begin
        posNuevoElem := j;
        break;
      end;
    end;

    for j := tope downto posNuevoElem + 1 do
      res[j] := res[j - 1];
    res[posNuevoElem] := valor;
    Inc(tope);
  end;
  Result := res;
end;

procedure QuickSort_Creciente(var A: array of integer);
  procedure Quick_Sort(var A: array of integer; iLo, iHi: integer);
  var
    Lo, Hi, Mid, T: integer;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo] < Mid do
        Inc(Lo);
      while A[Hi] > Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      Quick_Sort(A, iLo, Hi);
    if Lo < iHi then
      Quick_Sort(A, Lo, iHi);
  end;

begin
  if (length(A) > 0) then
    Quick_Sort(A, Low(A), High(A));
end;

// ordena el vecto A en forma creciente y hace los mismos cambios sobre el
// vector idxs.
procedure QuickSort_Creciente(var A: TDAOfNReal; var idxs: TDAOfNInt); overload;

  procedure Quick_Sort(var A: TDAOfNReal; var idxs: array of integer; iLo, iHi: integer);
  var
    Lo, Hi: integer;
    T, Mid: NReal;
    Tidx: integer;

  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo] < Mid do
        Inc(Lo);
      while A[Hi] > Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;

        Tidx := idxs[Lo];
        idxs[Lo] := idxs[Hi];
        idxs[Hi] := Tidx;

        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      Quick_Sort(A, idxs, iLo, Hi);
    if Lo < iHi then
      Quick_Sort(A, idxs, Lo, iHi);
  end;

begin
  Quick_Sort(A, idxs, Low(A), High(A));
end;

procedure QuickSort_Creciente(var A: TDAOfNReal);

  procedure Quick_Sort(var A: TDAOfNReal; iLo, iHi: integer);
  var
    Lo, Hi: integer;
    T, Mid: NReal;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo] < Mid do
        Inc(Lo);
      while A[Hi] > Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      Quick_Sort(A, iLo, Hi);
    if Lo < iHi then
      Quick_Sort(A, Lo, iHi);
  end;

begin
  Quick_Sort(A, Low(A), High(A));
end;

//**************** DECRECIENTES
procedure QuickSort_Decreciente(var A: array of integer);

  procedure Quick_Sort(var A: array of integer; iLo, iHi: integer);
  var
    Lo, Hi, Mid, T: integer;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo] > Mid do
        Inc(Lo);
      while A[Hi] < Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      Quick_Sort(A, iLo, Hi);
    if Lo < iHi then
      Quick_Sort(A, Lo, iHi);
  end;

begin
  Quick_Sort(A, Low(A), High(A));
end;


procedure QuickSort_Decreciente(var A: TDAOfNReal);
  procedure Quick_Sort(var A: TDAOfNReal; iLo, iHi: integer);
  var
    Lo, Hi: integer;
    T, Mid: NReal;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo] > Mid do
        Inc(Lo);
      while A[Hi] < Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      Quick_Sort(A, iLo, Hi);
    if Lo < iHi then
      Quick_Sort(A, Lo, iHi);
  end;

begin
  Quick_Sort(A, Low(A), High(A));
end;



// Ordena N Reales en forma decreciente comenzando por la posición
// de A[0]
procedure QuickSort_Decreciente( pA: pNReal; N: integer );
  procedure Quick_Sort(var A: TLAOfNReal; iLo, iHi: integer);
  var
    Lo, Hi: integer;
    T, Mid: NReal;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo] > Mid do
        Inc(Lo);
      while A[Hi] < Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      Quick_Sort(A, iLo, Hi);
    if Lo < iHi then
      Quick_Sort(A, Lo, iHi);
  end;

begin
  Quick_Sort( TLAOfNReal( pointer(pA)^ ), 0, N-1);
end;



procedure QuickSort_Decreciente(var A: TDAOfNReal; var idxs: TDAOfNInt);

  procedure Quick_Sort(var A: TDAOfNReal; var idxs: TDAOfNInt; iLo, iHi: integer);
  var
    Lo, Hi: integer;
    T, Mid: NReal;
    Tidx: integer;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo] > Mid do
        Inc(Lo);
      while A[Hi] < Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;

        Tidx := idxs[Lo];
        idxs[Lo] := idxs[Hi];
        idxs[Hi] := Tidx;

        Inc(Lo);
        Dec(Hi);

      end;
    until Lo > Hi;
    if Hi > iLo then
      Quick_Sort(A, idxs, iLo, Hi);
    if Lo < iHi then
      Quick_Sort(A, idxs, Lo, iHi);
  end;

begin
  Quick_Sort(A, idxs, Low(A), High(A));
end;

function TextToDArrOfNReal(s: string; sepDec: char): TDAOfNReal;
var
  i: integer;
  tmpArr, tmpArr2: TDAOfNReal;
  cnt: integer;
  pal: string;
  r: NReal;
begin
  if sepDec <> '.' then
  begin
    i := pos('.', s);
    while i > 0 do
    begin
      Delete(s, i, 1);
      i := pos('.', s);
    end;

    for i := 1 to length(s) do
      if s[i] = sepDec then
        s[i] := '.';
  end;

  setlength(tmpArr, 100);

  cnt := 0;

  pal := nextpal(s);
  while pal <> '' do
  begin
    try
      r := StrToFloat(pal);
    except
      raise Exception.Create('OJO, no logré interpretar : (' + pal +
        ') como un número.');
    end;

    if cnt >= length(tmpArr) then
    begin
      setlength(tmpArr2, length(tmpArr) + 100);
      for i := 0 to high(tmpArr) do
        tmpArr2[i] := tmpArr[i];
      setlength(tmpArr, 0);
      tmpArr := tmpArr2;
    end;
    tmpArr[cnt] := r;
    Inc(cnt);
    pal := nextpal(s);
  end;
  Result := copy(tmpArr, 0, cnt);
  setlength(tmpArr, 0);
end;

function TextToTMatOfNReal(lineas: TStrings; sepDec: char): TMatOfNReal;
var
  i, nNoVacias: integer;
  res: TMatOfNReal;
begin
  SetLength(res, lineas.Count);
  nNoVacias := 0;
  for i := 0 to lineas.Count - 1 do
  begin
    if lineas[i] <> '' then
    begin
      res[nNoVacias] := TextToDArrOfNReal(lineas[i], sepDec);
      nNoVacias := nNoVacias + 1;
    end;
  end;
  if nNoVacias <> lineas.Count then
    res := copy(res, 0, nNoVacias - 1);
  Result := res;
end;

{$IFDEF REDEFINIR_RDLN}
{ Lee una l¡nea sin importar si es UNIX o DOS }
procedure readln(var f: Text; var r: string);
var
  c: char;
begin
  r := '';
  c := 'm';
  while not EOF(f) and (c <> #10) do
  begin
    Read(f, c);
    r := r + c;
  end;
  if length(r) > 0 then
    if c = #10 then
      Delete(r, length(r), 1);
  if length(r) > 0 then
    if r[length(r)] = #13 then
      Delete(r, length(r), 1);
end;

{$ENDIF}

// Lee líneas hasta encontrar la proxima no vacía y la devuelve.
// Si llega el fin del archivo retorna ''
function ProximaLineaNoVacia(var f: Text): string;
var
  linea: string;
begin
  Readln(f, linea);
  linea := trim(linea);
  while not EOF(f) and (linea = '') do
  begin
    Readln(f, linea);
    linea := trim(linea);
  end;
  Result := linea;
end;


{ saca la primer palabra del string s}
function NextPal(var s: string): string;
var
  k1, k2: integer;
  ts: string;
begin
  k1 := 1;
  while (k1 <= Length(s)) and (s[k1] in Separadores) do
    Inc(k1);
  k2 := k1;
  while (k2 <= Length(s)) and not (s[k2] in Separadores) do
    Inc(k2);

  if k1 <= length(s) then
  begin
    ts := copy(s, k1, k2 - k1);
    if k2 < length(s) then
      Delete(s, 1, k2)
    else
      s := '';
  end
  else
  begin
    ts := '';
    s := '';
  end;

  Result := ts;
end;

{ saca la primer palabra del string s no considera el espacio como separador}
function NextPalSinEspacio(var s: string): string;
var
  k1, k2: integer;
  ts: string;
begin
  k1 := 1;
  while (k1 <= Length(s)) and (s[k1] in SeparadoresSinEspacio) do
    Inc(k1);
  k2 := k1;
  while (k2 <= Length(s)) and not (s[k2] in SeparadoresSinEspacio) do
    Inc(k2);

  if k1 <= length(s) then
  begin
    ts := copy(s, k1, k2 - k1);
    if k2 < length(s) then
      Delete(s, 1, k2)
    else
      s := '';
  end
  else
  begin
    ts := '';
    s := '';
  end;

  Result := ts;
end;

function NextStr(var s: string): string;
var
  k1, k2: integer;
  ts: string;
begin
  k1 := 1;
  while (k1 <= Length(s)) and (s[k1] in SeparadoresDeLineaYTab) do
    Inc(k1);
  k2 := k1;
  while (k2 <= Length(s)) and not (s[k2] in SeparadoresDeLineaYTab) do
    Inc(k2);

  if k1 <= length(s) then
  begin
    ts := copy(s, k1, k2 - k1);
    if k2 < length(s) then
      Delete(s, 1, k2)
    else
      s := '';
  end
  else
  begin
    ts := '';
    s := '';
  end;

  Result := ts;
end;


// quita la primer linea de la lista y la devuelve
function NextLine( var sl: TStringList ): string;
begin
  if sl.count > 0 then
  begin
    result:= sl[0];
    sl.Delete(0);
  end
  else
    result:= '';
end;

function getPalHastaSep(var sres, s: string; const sep: string): boolean;
var
  i: integer;
begin
  s := trim(s);
  i := pos(sep, s);
  if i > 0 then
  begin
    sres := copy(s, 1, i - 1);
    sres := trim(sres);
    Delete(s, 1, i - 1 + length(sep));
    Result := True;
  end
  else
  begin
    sres := s;
    s:= '';
    Result := False;
  end;
end;

function getNextPalSep(var s: string; const sep: string): string;
var
  i: integer;
  sres: string;
begin
  s:= trim( s );
  i := pos(sep, s);
  if i > 0 then
  begin
    sres := copy(s, 1, i - 1);
    Delete(s, 1, i - 1 + length(sep));
  end
  else
  begin
    sres := s;
    s:= '';
  end;
  result:= trim( sres );
end;



function getPalabras_lst( s: string; const sep: string = ' '
  ): TStringList;
var
  res: TStringList;
  ss: string;
  pal: string;
begin
  res:= TStringList.Create;
  ss:= s;
  while (ss <> '') do
  begin
    pal:= getNextPalSep( ss, sep );
    if ( pal <> '' ) or ( sep <> ' ') then
      res.add( pal );
  end;
  result:= res;
end;

function getPalabras_arr(s: string; const sep: string = ' '
  ): TDAofString;
var
  ls: TStringList;
  res: TDAOfString;
  k: integer;
begin
  ls:= getPalabras_lst( s, sep );
  setlength( res, ls.count );
  for k:= 0 to ls.count-1 do
    res[k]:= ls[k];
  ls.Free;
  result:= res;
end;



function NextLine( var s: string ): string;
var
  res: string;
begin
  if not getPalHastaSep( res, s, #10 ) then
  begin
    res:= s;
    s:= '';
  end;
  if length( res ) > 0 then
    if res[length(res)]= #13 then
      delete( res, length(res), 1 );

  result:= res;
end;


function NextPal_SkipN(var linea: string; NSkip: integer): string;
var
  i: integer;
begin
  for i := 1 to NSkip do
    nextpal(linea);
  Result := nextpal(linea);
end;

function NextInt(var s: string): integer;
begin
  Result := StrToInt(NextPal(s));
end;

function NextBool(var s: string): boolean;
begin
  Result := StrToBool(NextPal(s));
end;

function NextFloat(var s: string): NReal;
begin
  Result := StrToFloat(NextPal(s));
end;

function NextStrParam(var s: string; Nombre: string): string;
var
  ts: string;
begin
  ts := nextPal(s);
  if pos(Nombre, ts) > 0 then
    Result := nextPal(s)
  else
    raise Exception.Create('NextParam( ' + Nombre + ' ) Leí: ' + ts + ' y s:' + s);
end;

function NextFloatParam(var s: string; Nombre: string): NReal;
var
  sval: string;
begin
  sval := NextStrParam(s, nombre);
  Result := StrToFloat(sval);
end;

function NextIntParam(var s: string; Nombre: string): integer; overload;
var
  sval: string;
begin
  sval := NextStrParam(s, nombre);
  Result := StrToInt(sval);
end;

function ReadlnStrParam(var f: textfile; Nombre: string): string;
var
  r: string;
begin
  readln(f, r);
  Result := nextStrParam(r, Nombre);
end;

function ReadlnFloatParam(var f: textfile; Nombre: string): NReal;
var
  r: string;
begin
  readln(f, r);
  Result := nextFloatParam(r, Nombre);
end;

function ReadlnIntParam(var f: textfile; Nombre: string): integer;
var
  r: string;
begin
  readln(f, r);
  Result := nextIntParam(r, Nombre);
end;


function MesOfSem(isem: integer): integer;
var
  m: integer;
begin
  m := trunc(isem / 52.0 * 12.0) + 1;
  if m > 12 then
    MesOfSem := 12
  else
    MesOfSem := m;
end;


function EstacionOfMes(imes: integer): TEstacion;
var
  r: TEstacion;
begin
  case imes of
    12, 1, 2: r := verano;
    3, 4, 5: r := otonio;
    6, 7, 8: r := invierno;
    9, 10, 11: r := primavera;
    else
      raise Exception.Create('auxiliares.pas, EstacionOfMes (imes fuera de rango )');
  end;
  EstacionOfMes := r;
end;

function EstacionOfSem(isem: integer): TEstacion;
begin
  EstacionOfSem := EstacionOfMes(MesOfSem(isem));
end;

procedure cpSupEpsilon(var x: NReal);
begin
  if x < cpEpsilon then
    x := cpEpsilon;
end;

procedure potSupEpsilon(var x: NReal);
begin
  if x < potEpsilon then
    x := potEpsilon;
end;

{ retorna TRUE si paso está en [paso1, paso2] }
function PasoEnRango(paso1, paso, paso2: integer): boolean;
begin
  PasoEnRango := (paso1 <= paso) and (paso <= paso2);
end;

{ retorna el paso correspondiente al par ano,sem. }
function AnoSemToPaso(ano, sem: integer): integer;
begin
  AnoSemToPaso := ano * 52 + sem;
end;

function interpolar(valores: TDAOfNReal; xmin, xmax: NReal; x: Nreal): NReal;
var
  rix: NReal;
  ix: integer;
  dx: NReal;
begin
  dx := xmax - xmin;
  if dx <= AsumaCero then
    raise Exception.Create('ERROR, interpolar rango absurdo, xmin: ' +
      FloatToStr(xmin) + ' xmax: ' + FloatToStr(xmax));
  rix := (x - xmin) / dx * high(valores);
  ix := trunc(rix);
  if ix >= high(valores) then
    Result := valores[high(valores)]
  else
  begin
    rix := frac(rix);
    Result := valores[ix] * (1 - rix) + valores[ix + 1] * rix;
  end;
end;

function pertenece(valor: cardinal; const arreglo: TDAofNCardinal): boolean;
var
  i: integer;
  res: boolean;
begin
  res := False;
  for i := 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      res := True;
      break;
    end;
  Result := res;
end;

function pertenece(valor: integer; const arreglo: TDAofNInt): boolean;
var
  i: integer;
  res: boolean;
begin
  res := False;
  for i := 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      res := True;
      break;
    end;
  Result := res;
end;

function pertenece(valor: NReal; const arreglo: TDAofNReal): boolean;
var
  i: integer;
  res: boolean;
begin
  res := False;
  for i := 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      res := True;
      break;
    end;
  Result := res;
end;

function pertenece(valor: cardinal; const arreglo: TDAofNCardinal;
  var posicion: integer): boolean;
var
  i: integer;
begin
  posicion := -1;
  for i := 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      posicion := i;
      break;
    end;
  Result := posicion <> -1;
end;

function pertenece(valor: integer; const arreglo: TDAofNInt;
  var posicion: integer): boolean;
var
  i: integer;
begin
  posicion := -1;
  for i := 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      posicion := i;
      break;
    end;
  Result := posicion <> -1;
end;

function pertenece(valor: NReal; const arreglo: TDAofNReal;
  var posicion: integer): boolean;
var
  i: integer;
begin
  posicion := -1;
  for i := 0 to high(arreglo) do
    if arreglo[i] = valor then
    begin
      posicion := i;
      break;
    end;
  Result := posicion <> -1;
end;

function TDAOfNRealToString(const arreglo: TDAOfNReal): string;
begin
  Result := TDAOfNRealToString(arreglo, 12, 3, #9);
end;

function TDAOfNRealToString(const arreglo: TDAOfNReal;
  precision, decimales: integer): string;
begin
  Result := TDAOfNRealToString(arreglo, precision, decimales, #9);
end;

function TDAOfNRealToString(const arreglo: array of double; precision,
  decimales: integer; separador: string; wall: char): string;
var
  k: integer;
  res: string;
begin
  res := '[' + IntToStr(length(arreglo)) + wall + ' ';
  if length(arreglo) > 0 then
  begin
    res := res + FloatToStrF(arreglo[0], ffGeneral, precision, decimales);
    for k := 1 to high(arreglo) do
      res := res + separador + FloatToStrF(arreglo[k], ffGeneral, precision, decimales);
  end;
  res := res + ']';
  Result := res;
end;

function TDAOfNRealToStringSinTamanio(const arreglo: TDAOfNReal;
  precision, decimales: integer; separador: string): string; overload;
var
  k: integer;
  res: string;
begin
  res := '[';
  if length(arreglo) > 0 then
  begin
    res := res + FloatToStrF(arreglo[0], ffGeneral, precision, decimales);
    for k := 1 to high(arreglo) do
      res := res + separador + FloatToStrF(arreglo[k], ffGeneral, precision, decimales);
  end;
  res := res + ']';
  Result := res;
end;

function TDAOfNRealToTabbedString(const arreglo: TDAOfNReal;
  precision, decimales: integer): string;
var
  i: integer;
  res: string;
begin
  res := FloatToStrF(arreglo[0], ffGeneral, precision, decimales);
  for i := 1 to high(arreglo) do
    res := res + #9 + FloatToStrF(arreglo[i], ffGeneral, precision, decimales);
  Result := res;
end;

function TDAOfNRealToTabbedStringConTamanio(const arreglo: TDAOfNReal;
  precision, decimales: integer): string;
var
  i: integer;
  res: string;
begin
  res := IntToStr(Length(arreglo));
  for i := 0 to High(arreglo) do
    res := res + #9 + FloatToStrF(arreglo[i], ffGeneral, precision, decimales);
  Result := res;
end;

function TDAOfNIntToString(const arreglo: array of Integer; separador: string;
  wall: char): string;
var
  k: integer;
  res: string;
begin
  res := '[' + IntToStr(length(arreglo)) + wall + ' ';
  if length(arreglo) > 0 then
  begin
    res := res + IntToStr(arreglo[0]);
    for k := 1 to high(arreglo) do
      res := res + separador + IntToStr(arreglo[k]);
  end;
  res := res + ']';
  Result := res;
end;

function TDAOfNIntToStringSinTamanio(const arreglo: TDAofNInt;
  separador: string): string;
var
  k: integer;
  res: string;
begin
  res := '[';
  if length(arreglo) > 0 then
  begin
    res := res + IntToStr(arreglo[0]);
    for k := 1 to high(arreglo) do
      res := res + separador + IntToStr(arreglo[k]);
  end;
  res := res + ']';
  Result := res;
end;

function TDAOfNIntToTabbedString(const arreglo: TDAofNInt): string;
var
  i: integer;
  res: string;
begin
  res := IntToStr(arreglo[0]);
  for i := 1 to high(arreglo) do
    res := res + #9 + IntToStr(arreglo[i]);
  Result := res;
end;

function TDAOfNIntToTabbedStringConTamanio(const arreglo: TDAofNInt): string;
var
  i: integer;
  res: string;
begin
  res := IntToStr(Length(arreglo));
  for i := 0 to High(arreglo) do
    res := res + #9 + IntToStr(arreglo[i]);
  Result := res;
end;

function TDAOfBooleanToString(const arreglo: array of boolean;
  separador: string; useBoolStrs: boolean; wall: char): string;
var
  k: integer;
  res: string;
begin
  res := '[' + IntToStr(length(arreglo)) + wall + ' ';
  if length(arreglo) > 0 then
  begin
    res := res + BoolToStr(arreglo[0], useBoolStrs);
    for k := 1 to high(arreglo) do
      res := res + separador + BoolToStr(arreglo[k], useBoolStrs);
  end;
  res := res + ']';
  Result := res;
end;

function TStringListToString(const stringList: TStringList; separador: string;
  wall:char): string;
var
  k: integer;
  res: string;
begin
  res := '[' + IntToStr(stringList.Count) + wall + ' ';
  if stringList.Count > 0 then
  begin
    res := res + stringList[0];
    for k := 1 to stringList.Count - 1 do
      res := res + separador + stringList[k];
  end;
  res := res + ']';
  Result := res;
end;

function TDAOfStringToString(const DAOfString: array of string;
  separador: string; wall: char): string;
var
  k: integer;
  res: string;
  len: Integer;
begin
  len := Length(DAOfString);
  res := '[' + IntToStr(Len) + wall + ' ';
  if Len > 0 then
  begin
    res := res + DAOfString[0];
    for k := 1 to len - 1 do
      res := res + separador + DAOfString[k];
  end;
  res := res + ']';
  Result := res;
end;

function nroOcurrencias(subCadena, cadena: string): integer;
var
  i, j, res: integer;
begin
  res := 0;
  i := 1;
  while i < Length(cadena) - Length(subCadena) do
  begin
    j := 1;
    while (j < Length(subCadena)) and (subCadena[j] = cadena[i + j]) do
      j := j + 1;

    if j = Length(subCadena) then
    begin
      res := res + 1;
      i := i + j;
    end
    else
      i := i + 1;
  end;
  Result := res;
end;

function quitarElementoTDAOfNCardinal(const arreglo: TDAofNCardinal;
  elem: cardinal): TDAofNCardinal;
var
  res: TDAofNCardinal;
  i, iRes, n: integer;
begin
  n := Length(arreglo);
  if n > 0 then
  begin
    iRes := 0;
    SetLength(res, n - 1);
    for i := 0 to high(arreglo) do
      if arreglo[i] <> elem then
      begin
        res[iRes] := arreglo[i];
        iRes := iRes + 1;
      end;
  end
  else
    res := nil;
  Result := res;
end;

function clonarTList(original: TList): TList;
var
  res: TList;
  i: integer;
begin
  res := TList.Create;
  res.Capacity := original.Capacity;
  for i := 0 to original.Count - 1 do
    res.Add(original[i]);
  Result := res;
end;


procedure parseDAOfNreal(var A: TDAOfNreal; const xval: string);
var
  k: integer;
  s: string;
  pal: string='';
  N: integer;
begin
  s := xval;
  if not getPalHastaSep(pal, s, '[') then
    raise Exception.Create(rs_ArrayErrorDeFormato_DebeComenzarCon + ' [ . ');
  if (not getPalHastaSep(pal, s, '|') and not getPalHastaSep(pal, s, ';')) then
    raise Exception.Create(rs_ArrayErrorDeFormato_CantidadDeElementos +
      ' | o ; : [n|, [n; ');
  try
    N := StrToInt(trim(pal));
  except
    raise Exception.Create(rs_ArrayErrorDeFormato_CantidadDeElementosNoEntera +
      ' ' + rs_ElValorEspecificadoEs + ': [' + pal + '] (' +
      rs_CaracteresEntreParentesisRectos + ')');
  end; // try
  if N > 0 then
  begin
    setlength(A, N);
    for k := 0 to N - 2 do
    begin
      if not getPalHastaSep(pal, s, ',') then
        raise Exception.Create(
          'Formato de array inválido. Imposible encontrar la coma que marca el fin del elemento número: '
          + IntToStr(k + 1));
      try
        A[k] := StrToFloat(pal);
      except
        raise Exception.Create('Formato de array inválido. No pude convertir: [' +
          pal + '] a un número real procesando el elemento número: ' + IntToStr(k + 1));
      end; // try
    end;
    k := N - 1; // el último elemento lo procesamos aparte pues finaliza con ]
    if not getPalHastaSep(pal, s, ']') then
      raise Exception.Create(
        'Formato de array inválido. Imposible encontrar la coma que marca el fin del último elemento del array.');
    try
      A[k] := StrToFloat(pal);
    except
      raise Exception.Create('Formato de array inválido. No pude convertir: [' +
        pal + '] a un número real procesando el elemento número: ' + IntToStr(k + 1));
    end; // try
  end
  else
  begin
    if not getPalHastaSep(pal, s, ']') then
      raise Exception.Create(
        'Formato de array inválido. Imposible encontrar la coma que marca el fin del último elemento del array.');
    A := nil;
  end;
end;

procedure parseDAOfNInt(var A: TDAOfNInt; const xval: string);
var
  k: integer;
  s: string;
  pal: string='';
  N: integer;
begin
  s := xval;
  if not getPalHastaSep(pal, s, '[') then
    raise Exception.Create('Formato de array inválido debe comenzar con [ . ');
  if (not getPalHastaSep(pal, s, '|') and not getPalHastaSep(pal, s, ';')) then
    raise Exception.Create(
      'Formato de array inválido debe tener la cantidad de elementos seguida de | o ; : [n|, [n; ');
  try
    N := StrToInt(pal);
  except
    raise Exception.Create(
      'Formato de array inválido. La cantidad de elementos tienen que ser un entero. Es: ['
      + pal + '] (lo que está entre paréntesis rectos)');
  end; // try
  setlength(A, N);
  for k := 0 to N - 2 do
  begin
    if not getPalHastaSep(pal, s, ',') then
      raise Exception.Create(
        'Formato de array inválido. Imposible encontrar la coma que marca el fin del elemento número: '
        + IntToStr(k + 1));
    try
      A[k] := StrToInt(pal);
    except
      raise Exception.Create('Formato de array inválido. No pude convertir: [' +
        pal + '] a un número entero procesando el elemento número: ' + IntToStr(k + 1));
    end; // try
  end;
  k := N - 1; // el último elemento lo procesamos aparte pues finaliza con ]
  if not getPalHastaSep(pal, s, ']') then
    raise Exception.Create(
      'Formato de array inválido. Imposible encontrar el ] que marca el fin del ultimo elemento del array.');
  if N > 0 then
  begin
    try
      A[k] := StrToInt(pal);
    except
      raise Exception.Create('Formato de array inválido. No pude convertir: [' +
        pal + '] a un número entero procesando el elemento número: ' + IntToStr(k + 1));
    end; // try
  end;
end;

procedure parseDAOfBoolean(var A: TDAOfBoolean; const xval: string);
var
  k: integer;
  s: string;
  pal: string='';
  N: integer;


begin
  s := xval;
  if not getPalHastaSep(pal, s, '[') then
    raise Exception.Create('Formato de array inválido debe comenzar con [ . ');
  if (not getPalHastaSep(pal, s, '|') and not getPalHastaSep(pal, s, ';')) then
    raise Exception.Create(
      'Formato de array inválido debe tener la cantidad de elementos seguida de | o ; : [n|, [n; ');
  try
    N := StrToInt(pal);
  except
    raise Exception.Create(
      'Formato de array inválido. La cantidad de elementos tienen que ser un entero. Es: ['
      + pal + '] (lo que está entre paréntesis rectos)');
  end; // try
  setlength(A, N);
  if N > 0 then
  begin
    for k := 0 to N - 2 do
    begin
      if not getPalHastaSep(pal, s, ',') then
        raise Exception.Create(
          'Formato de array inválido. Imposible encontrar la coma que marca el fin del elemento número: '
          + IntToStr(k + 1));
      try
        A[k] := StrToBool(pal);
      except
        raise Exception.Create('Formato de array inválido. No pude convertir: [' +
          pal + '] a un número entero procesando el elemento número: ' +
          IntToStr(k + 1));
      end; // try
    end;
    k := N - 1; // el último elemento lo procesamos aparte pues finaliza con ]
    if not getPalHastaSep(pal, s, ']') then
      raise Exception.Create(
        'Formato de array inválido. Imposible encontrar el ] que marca el fin del ultimo elemento del array.');
    try
      A[k] := StrToBool(pal);
    except
      raise Exception.Create('Formato de array inválido. No pude convertir: [' +
        pal + '] a un número entero procesando el elemento número: ' + IntToStr(k + 1));
    end; // try
  end;
end;




procedure parseStringList(var A: TStringList; const xval: string);
var
  k: integer;
  s: string;
  pal: string='';
  N: integer;
begin
  s := xval;
  if not getPalHastaSep(pal, s, '[') then
    raise Exception.Create('Formato de array inválido debe comenzar con [ . ');
  if (not getPalHastaSep(pal, s, '|') and not getPalHastaSep(pal, s, ';')) then
    raise Exception.Create(
      'Formato de array inválido debe tener la cantidad de elementos seguida de | o ; : [n|, [n; ');
  try
    N := StrToInt(pal);
  except
    raise Exception.Create(
      'Formato de array inválido. La cantidad de elementos tienen que ser un entero. Es: ['
      + pal + '] (lo que está entre paréntesis rectos)');
  end; // try

  A := TStringList.Create;
  A.Capacity := N;

  { dfusco@20150612
    Se agrega el filtro de N>0 para que no se retorne el StringList con un
    elemento vacío. }
  if N>0 then
  begin
    for k := 0 to N - 2 do
    begin
      if not getPalHastaSep(pal, s, ',') then
        raise Exception.Create(
          'Formato de array inválido. Imposible encontrar la coma que marca el fin del elemento número: '
          + IntToStr(k + 1));
      A.add(pal);
    end;
    //   k:= N-1; // el último elemento lo procesamos aparte pues finaliza con ]
    if not getPalHastaSep(pal, s, ']') then
      raise Exception.Create(
        'Formato de array inválido. Imposible encontrar el ] que marca el fin del ultimo elemento del array.');
    A.add(pal);
  end;
end;

procedure parseDAOfString(var A: TDAOfString; const xval: string);
var
  l: TStringList;
  k: integer;
begin
  l := nil;
  parseStringList(l, xval);
  if l <> nil then
  begin
    setlength(A, l.Count);
    for k := 0 to l.Count - 1 do
      a[k] := l[k];
    l.Free;
  end
  else
    setlength(a, 0);
end;


procedure clear_vacias(var palabras: TDAOfString);
var
  k, j: integer;
  pal: string;
begin
  if palabras = nil then
    setlength(palabras, 0);

  k := 0;
  j := 0;
  for k := 0 to length(palabras) - 1 do
  begin
    pal := trim(palabras[k]);
    if pal <> '' then
    begin
      palabras[j] := pal;
      Inc(j);
    end;
  end;
  if j < length(palabras) then
    setlength(palabras, j);
end;


procedure parsearReferencia(r: string; var claseDelReferido, nombreDelReferido: string);
var
  i: integer;
begin
  if pos('<', r) <> 1 then
    raise Exception.Create('ReadRefToCosa, Error(falta:<): Formato inválido: ' +
      r + '.'{ Procesando línea: '+IntToStr( klinea )});
  System.Delete(r, 1, 1); // borramos el < de apertura
  i := pos('>', r);
  if i = 0 then
    raise Exception.Create('ReadRefToCosa, Error(falta:>): Formato inválido: ' +
      r + '.'{ Procesando línea: '+IntToStr( klinea )});
  if i < length(r) then
    raise Exception.Create('ReadRefToCosa, Error( Hay caracteres después del > )' +
      r + '.'{ Procesando línea: '+IntToStr( klinea )});

  System.Delete(r, i, 1); // borramos el > de cierre
  i := pos('.', r);
  if i = 0 then
    raise Exception.Create('ReadRefToCosa, Error(falta:.): Formato inválido: ' +
      r + '.'{ Procesando línea: '+IntToStr( klinea )});
  claseDelReferido := copy(r, 1, i - 1);
  nombreDelReferido := copy(r, i + 1, Length(r) - (i));
end;


{$IFDEF WINDOWS}
function RunChild(apl: string; params: array of string;
  EsperarFinDelHijo: boolean): boolean;
var
  proc_info: TProcessInformation;
  startinfo: TStartupInfo;
  ExitCode: longword=0;
  aplic, cmdline: string;
  k: integer;
  ext: string;
begin
  ext:=  LowerCase( ExtractFileExt( apl ));
  if ext = '.exe' then
    aplic := apl + #0
  else
    aplic := apl +'.exe'#0;

  cmdline := apl;
  if length(params) > 0 then
    for k := 0 to high(params) do
      cmdline := cmdline + ' ' + params[k];
  cmdline := cmdline + #0;

  // Inicializamos las estructuras
  FillChar(proc_info{%H-}, sizeof(TProcessInformation), 0);
  FillChar(startinfo{%H-}, sizeof(TStartupInfo), 0);
  startinfo.cb := sizeof(TStartupInfo);

  // Intentamos crear el proceso
  if CreateProcess(@aplic[1], @cmdline[1], nil, nil, False,
    NORMAL_PRIORITY_CLASS, nil, nil, startinfo, proc_info) <> False then
  begin
    if EsperarFinDelHijo then
    begin
      // El proceso se creó exitosamente
      // Ahora esperemos a que termine...
      while WaitForSingleObject(proc_info.hProcess, 10000) = WAIT_TIMEOUT do
        writeln('.');

      // Proceso finalizado. Ahora debemos cerrarlo.
      GetExitCodeProcess(proc_info.hProcess, ExitCode);  // Opcional
      FileClose(proc_info.hThread); { *Converted from CloseHandle*  }
      FileClose(proc_info.hProcess); { *Converted from CloseHandle*  }
    end;
    Result := True;
  end
  else
  begin
    Result := False;
  end;//if
end;

function RunChildAndWAIT(apl: string; params: array of string): boolean;
begin
  Result := RunChild(apl, params, True);
end;

{$ELSE}

procedure DoProcesoHijo(apl: ansistring; params: array of string);
var
  i, error: integer;
  paramsPChar, iter: PPChar;
begin
  writeln('DoProcesoHijo, Apl: ', Apl);
  for i := 0 to high(params) do
    writeln('i: ', i, ' val: ', params[i]);

  Apl := Apl + #0;
  GetMem(paramsPChar, (length(params) + 2) * SizeOf(PChar));
  iter := paramsPChar;
  iter^ := @(Apl[1]);
  Inc(iter);
  for i := 0 to High(params) do
  begin
    params[i] := params[i] + #0;
    iter^ := @(params[i][1]);
    Inc(iter);
  end;
  iter^ := nil;
  fpexecv(Apl, paramsPChar);

  //si vuelvo de fpexecv hubo error
  error := fpgeterrno;
  writeln('uEmuladorWinIPC.DoProcesoHijo: error= ', error, ', ', strError(error));

  freemem(paramsPChar, (length(params) + 2) * SizeOf(PChar));
  fpexit(0); // halt;
end;

function RunChild(apl: string; params: array of string;
  EsperarFinDelHijo: boolean): boolean;
var
  pid: integer;
  status: integer;
  aplx: ansistring;
begin
  // init child process
  pid := fpfork();
  Result := pid >= 0;
  if pid = -1 then
    exit;

  if pid = 0 then
  begin
    // in child process - init grandchild
    aplx := apl;
    doProcesoHijo(aplx, params);
  end
  else
  // in parent process - use waitpit to query for child process
  if EsperarFinDelHijo then
    fpwaitpid(pid, @status, 0);
end;


function RunChildAndWAIT(apl: string; params: array of string): boolean;
begin
  Result := RunChild(apl, params, True);
end;

{$ENDIF}



// corre el comando apl con los parametros pasados
// y le escribe la entrada en su entrada standar.
// Se captura la salida y se retorna como un TStringList
function RunPipe(
  apl: string; paramslst: TStrings; entrada: TStringList; finDeLinea: string = #10 ): TStringList;
var
  ap: TProcess;
  Buffer: array[0..1024] of char;
  ReadCount: Integer;
  ReadSize: Integer;
  i: integer;
  s: string;
  res: TStringList;
  directorioPrograma: string;

begin

  directorioPrograma:= ExtractFileDir( apl );

  ap  := TProcess.Create(nil);
  ap.Options := [poUsePipes,poStderrToOutPut];
  ap.Executable := apl;
  ap.Parameters := paramsLst;
  ap.CurrentDirectory:= directorioPrograma;

  ap.Execute;

  for i:= 0 to entrada.count - 1 do
  begin
    s:= entrada[i]+finDeLinea;
    ap.Input.Write( s[1], length( s ) );
  end;

  res:= TStringList.Create;

  while ap.Running or (ap.Output.NumBytesAvailable > 0) do
  begin
    if ap.Output.NumBytesAvailable > 0 then
    begin
      // make sure that we don't read more data than we have allocated
      // in the buffer
      ReadSize := ap.Output.NumBytesAvailable;
      if ReadSize > SizeOf(Buffer) then
        ReadSize := SizeOf(Buffer);
      // now read the output into the buffer
      ReadCount := ap.Output.Read({%H-}Buffer[0], ReadSize);
      setlength( s , ReadCount );
      s:= copy( Buffer, 0, ReadCount );
      res.add( s );
    end;
  end;
  result:= res;

  // Close the input on the SecondProcess
  // so it finishes processing it's data
  ap.CloseInput;

  // and wait for it to complete
  // be carefull what command you run because it may not exit when
  // it's input is closed and the following line may loop forever
  while ap.Running do
    Sleep(1);

  // free our process objects
  ap.Free;
end;

procedure DeleteDir(const DirName: string);
var
  Path: string;
  F: TSearchRec;

begin
  Path := DirName + '\*.*';
  if FindFirst(Path, faAnyFile, F) = 0 then
  begin
    try
      repeat
        if (F.Attr and faDirectory <> 0) then
        begin
          if (F.Name <> '.') and (F.Name <> '..') then
          begin
            DeleteDir(DirName + '\' + F.Name);
          end;
        end
        else
          DeleteFile(DirName + '\' + F.Name);
      until FindNext(F) <> 0;
    finally
      FindClose(F);
    end;
  end;
  RemoveDir(DirName);
end;



procedure eliminar_BOM(var linea: string);
var
  i: integer;
  n: integer;
  buscando: boolean;
  c: integer;
begin
  buscando := True;
  i := 1;
  n := length(linea);
  while (buscando and (i <= n)) do
  begin
    c := Ord(linea[i]);
    if (c >= 32) and (c <= 126) then
      buscando := False
    else
      Inc(i);
  end;
  if not buscando then
  begin
    if (i > 1) then
      Delete(linea, 1, i - 1);
  end
  else
    linea := '';
end;




function HTTPDecode(const AStr: string): string;

var
  S, SS, R: PChar;
  H: string[3];
  L, C: integer;

begin
  L := Length(Astr);
  SetLength(Result, L);
  if (L = 0) then
    exit;
  S := PChar(AStr);
  SS := S;
  R := PChar(Result);
  while (S - SS) < L do
  begin
    case S^ of
      '+': R^ := ' ';
      '%':
      begin
        Inc(S);
        if ((S - SS) < L) then
        begin
          if (S^ = '%') then
            R^ := '%'
          else
          begin
            H := '$00';
            H[2] := S^;
            Inc(S);
            if (S - SS) < L then
            begin
              H[3] := S^;
              Val(H, PByte(R)^, C);
              if (C <> 0) then
                R^ := ' ';
            end;
          end;
        end;
      end;
      else
        R^ := S^;
    end;
    Inc(R);
    Inc(S);
  end;
  SetLength(Result, R - PChar(Result));
end;

function getFileList(path: String; pattern: string): TStringList;
var
  oldDir: String;
  Info : TSearchRec;
begin
  try
    if DirectoryExists(path) then
    begin
      oldDir:=GetCurrentDir;
      ChDir(path);
      chDir( oldDir );
    end
    else
      Exit;
  except
    raise Exception.Create('No se pudo acceder al directorio: '+path);
  end;

  Result:= TStringList.Create;
  if FindFirst (pattern, faAnyFile,Info)=0 then
  begin
    repeat
      Result.Add(info.Name);
    until FindNext(info)<>0;
  end;
  FindClose(Info);

end;

function HTTPEncode(const AStr: string): string;

const
  HTTPAllowed = ['A'..'Z', 'a'..'z', '*', '@', '.', '_', '-',
    '0'..'9', '$', '!', '''', '(', ')'];

var
  SS, S, R: PChar;
  H: string[2];
  L: integer;

begin
  L := Length(AStr);
  SetLength(Result, L * 3); // Worst case scenario
  if (L = 0) then
    exit;
  R := PChar(Result);
  S := PChar(AStr);
  SS := S; // Avoid #0 limit !!
  while ((S - SS) < L) do
  begin
    if S^ in HTTPAllowed then
      R^ := S^
    else if (S^ = ' ') then
      R^ := '+'
    else
    begin
      R^ := '%';
      H := HexStr(Ord(S^), 2);
      Inc(R);
      R^ := H[1];
      Inc(R);
      R^ := H[2];
    end;
    Inc(R);
    Inc(S);
  end;
  SetLength(Result, R - PChar(Result));
end;

procedure load_localsettings;
begin
  local_ThousandSeparator := SysUtils.DefaultFormatSettings.ThousandSeparator;
  local_DecimalSeparator := SysUtils.DefaultFormatSettings.DecimalSeparator;
  local_DateSeparator := SysUtils.DefaultFormatSettings.DateSeparator;
  local_ShortDateFormat := SysUtils.DefaultFormatSettings.ShortDateFormat;
  local_LongDateFormat := SysUtils.DefaultFormatSettings.LongDateFormat;

  if pos( '/', local_ShortDateFormat ) > 0 then
    local_DateSeparator:= '/'
  else if pos( '-', local_ShortDateFormat  ) > 0 then
    local_DateSeparator:= '-';
end;

initialization
  SeccionCriticaGenerica:= TCriticalSection.Create;
  load_localsettings;

  cnt_GlobsSet := 0;
  cnt_GlobsSet_UY45 := 0;
finalization
  SeccionCriticaGenerica.Free;

end.
