{ Definiciones Corrientes para uso en matem ticas }
unit xmatdefs;

{$MODE Delphi}

interface

uses
  SysUtils,
  uevaluador,
  Math;

resourcestring
  rs_viguales_RangeCheckError = 'viguales, no coinciden los largos.';

type
  NReal = double;
  PNReal = ^NReal;
  NInt = integer;
  PNInt = ^NInt;

const
  MaxNReal = Math.MaxDouble;

type
  NComplex = record
    r, i: NReal
  end;
  PNComplex = ^NComplex;

const
  Complex_UNO: NComplex = (r: 1; i: 0);


type
  // solo para typecast
  TLAOfNReal = array[0..1024 * 1024 * 200] of NReal;
  PLAOfNReal = ^TLAOfNReal;

type
  TSetOfByte = set of byte;
  TDAofNCardinal = array of cardinal;
  TDAofNInt = array of integer;
  PDAofNInt = ^TDAofNInt;
  TDAofNReal = array of NReal;
  PDAOfNReal = ^TDAOfNReal;
  TDAOfDateTime = array of TDateTime;
  TDAofNComplex = array of NComplex;
  TDAofString = array of string;
  TDAOfBoolean = array of boolean;
  TDAOfPtr = array of Pointer;
  TDAOfNRealPtr = array of PNReal;

  TMatOfBoolean = array of TDAOfBoolean;

  TMatOfNInt = array of TDAofNInt;
  TDAOfDAOfNInt = TMatOfNInt;

  TMatOfNReal = array of TDAofNReal;

  TDAOfDAofNReal = TMatOfNReal;

  TDAOfMatOfNReal = array of TMatOfNReal;
  TMatOfString = array of TDAofString;
  TDAofDAofString = TMatOfString;


type
  TFdeX = function(x: NReal): NReal;


type
  NEntero = NInt;
  PNEntero = ^NInt;

type
  TSetOfChar = set of char;

{ Redefinicion de los timpos estandar para que el compilador detecte
como un error el uso indebido de los mismos }
  //  extended = boolean;
  real = boolean;


{ Las siguientes constantes son calculadas en el auto-arranque de
la unidad por lo que no es aconsejable utilizarlas en los procedimientos
de auto-arranque de otras unidades pues de hacerlo habrá que tener
}
var
  AsumaCero: NReal; {EPSILON de la maquina en cuentas con NReal }
  DosPi: NReal;    { 2*Pi }


{ abs(x) < AsumaCero }
function EsCero(x: NReal): boolean; overload;
function EsCero(z: NComplex): boolean; overload;


{ Casi0:= Abs(x)< xCero.
  xCero debe ser un numero positivo }
function Casi0(x: NReal; xCero: NReal): boolean;

function SignoNR(x: NReal): integer;

function vsum(const a: TDAOfBoolean): integer; overload;
function vsum(const a: TDAofNReal): NReal; overload;
function vsum(const a: TDAofNInt): integer; overload;

// suman N Reales a partir de la posición de memoria apuntada por pv
function vsum(pv: PNReal; N: integer): NReal; overload;

function vprom(const a: TDAofNReal): NReal; overload;

// Prmedia N Reales a partir de la posición de memoria apuntada por pv
function vprom(pv: PNReal; N: integer): NReal; overload;

function vprom(const a: TDAofNInt): NReal; overload;


(*+doc
  result:= ( a[i] = b[i] ) para todo i
-doc*)
function viguales(const a, b: TDAOfNReal): boolean;


(*+doc
  result:= sumatoria( a[i]*b[i] )
-doc*)
function vsumaproducto(const a, b: TDAOfNReal): NReal; overload;
function vsumaproducto(const a, b: TDAOfNInt): NReal; overload;

(*+doc
  a[i]:= b[i] ; i:= 0... high(b)
-doc*)
procedure vcopy(var a: TDAOfNReal; const b: TDAOfNReal); overload;

(*+doc
  pa[i]:= pb[i] ; i:= 0... N-1
-doc*)
procedure vcopy(pa, pb: PLAOfNReal; N: integer); overload;

(*+doc
  a[i]:= b[i] ; i:= 0... high(b)
-doc*)
procedure vcopy(var a: TDAofNInt; const b: TDAofNInt); overload;
(*+doc
  destino[ i+ jDesde]:= origen[ i + jDesde] ; i:= 0 ... N-1
-doc*)
procedure vcopyTramo(var destino: TDAofNReal; const origen: TDAofNReal;
  jDesde, N: integer);

(*+doc
  destino[ i+ jDesdeDestino]:= origen[ i + jDesdeOrigen] ; i:= 0 ... N-1
-doc*)


procedure vcopyTramoDesplazando(var destino: TDAofNReal; jDesdeDestino: integer;
  const origen: TDAofNReal; jDesdeOrigen: integer; N: integer); overload;

procedure vcopyTramoDesplazando(var destino: TDAofNInt; jDesdeDestino: integer;
  const origen: TDAofNInt; jDesdeOrigen: integer; N: integer); overload;


procedure vmultr(var a: TDAofNReal; r: NReal); overload;
procedure vmultr(var a: TDAofNInt; r: NReal); overload;

procedure vclear(var a: TDAofNInt); overload;
procedure vclear(var a: TDAofNReal); overload;
procedure vclear(var a: TDAOfBoolean; ClearVal: boolean = False); overload;

procedure vclear(var a: TDAofNInt; kIni, kFin: integer); overload;
procedure vclear(var a: TDAofNReal; kIni, kFin: integer); overload;

procedure vswap(var a, b: NReal); overload;

procedure vswap(var a, b: TDAOfNReal); overload;

// Hace esl swap copiando valores casillero a casillero.
// es menos eficiente que el anterior, pero puede ser necesario si hay varios
// punteros tomando información de los vectores.
procedure vCopySwap(var a, b: TDAOfNReal); overload;


procedure vswap(var a, b: TDAOfNInt); overload;
procedure vswap(var a, b: integer); overload;
procedure vswap(var a, b: TDAOfBoolean); overload;

function vmax(const a: TDAofNReal): NReal; overload;
function vmax(const a: TDAofNInt): integer; overload;
function vmin(const a: TDAofNReal): NReal; overload;
function vmin(const a: TDAofNInt): integer; overload;

procedure vminmax(var min, max: NReal; const a: TDAOfNReal); overload;
procedure vminmax(var min, max: integer; const a: TDAOfNInt); overload;

//Suma a acum los valores de source
//source y acum deben tener el mismo tamaño
procedure vacum(var acum: TDAofNReal; const Source: TDAofNReal); overload;
//Suma a acum count valores de source desde jIni
procedure vacum(jIni: integer; var acum: TDAofNReal; const Source: TDAofNReal;
  Count: integer); overload;
//Suma a acum desede jIniAcum count valores de source desde jIniSource
procedure vacum(var acum: TDAofNReal; jIniAcum: integer; const Source: TDAofNReal;
  jIniSource: integer; Count: integer); overload;

//Suma a acum los valores de source ponderados por ponder
//source y acum deben tener el mismo tamaño
procedure vacumPonderado(var acum: TDAofNReal; const Source: TDAofNReal;
  ponder: NReal); overload;
//Suma a acum count valores de source desde jIni multipicados por ponder
procedure vacumPonderado(jIni: integer; var acum: TDAofNReal;
  const Source: TDAofNReal; Count: integer; ponder: NReal); overload;
//Suma a acum desede jIniAcum count valores de source desde jIniSource multipicados por ponder
procedure vacumPonderado(var acum: TDAofNReal; jIniAcum: integer;
  const Source: TDAofNReal; jIniSource: integer; Count: integer;
  ponder: NReal); overload;

// libera la memoria y lo pone a nil
procedure liberarVector(var a: TDAofNReal);

function create_clone(mat: TMatOfNReal): TMatOfNReal;
function create_MatOfNreal(nf, nc: integer): TMatOfNReal;
procedure liberarMatriz(var mat: TMatOfNReal);

// llama a liberarMatriz
procedure Free_MatOfNreal(var a: TMatOfNReal);

function moduloCiclico(dividendo, divisor: integer): cardinal;
//Retorna el resto de la división entera de dividendo / divisor
function moduloRealEntero(dividendo: NReal; divisor: integer): NReal;

// redefino esta función de sysutils para hacerla pasar primero
// por un evaluador de expresiones.
// para que esto funcione al incluir esta unidad en la clausula uses
// de otra tener la precausion de ponerla despues de SysUtils (si es que aparece).
function StrToFloat(const s: string): NReal;

function DAOfNRealToStr_(const valor: array of double; precision: integer;
  decimales: integer; sep: char): string; overload;
function DAOfNRealToStr_(const valor: array of double; sep: char): string; overload;


function StrToDAOfNReal_(s: string; sep: char): TDAOfNReal;

function DAOfNIntToStr(const valor: TDAOfNInt; sep: char): string;
function StrToDAOfNInt(s: string; sep: char): TDAOfNInt;


// Procesa el string cadena byte a byte res = ( res xor cadena[k] ) rot_left_32 1 ; k = 1 to length( cadena )
procedure crc32_in_res(var res: integer; const cadena: string);


procedure StoreInFile_DAOfNReal(var f: file; var a: TDAOfNReal);
procedure LoadFromFile_DAOfNReal(var f: file; var a: TDAOfNReal);
procedure StoreInFile_DAOfNInt(var f: file; var a: TDAOfNInt);
procedure LoadFromFile_DAOfNInt(var f: file; var a: TDAOfNInt);

// Escribe en el archivo de texto el vector encabezando con NElementos:
// y escribiendo NElementosPorLinea. Como separador usa #9 (tabulador).
procedure printvect(var f: textfile; const a: TDAOfNReal; NElementosPorLinea: integer);


{
 y(u) = a * u^2 + b * u + c
y0 = y(0); y1 = y(1); y2 = y(2)
}
function interpolacion_parabolica_012(const y0, y1, y2: NReal; u: NReal): NReal;

{
BUsca el valor k en el array y si lo encuentra retorna la posición.
Si no lo encuentra retorna -1
}
function kInArray(const v: TDAOfNInt; k: integer): integer;

{
Primero se fija si k está en v, si está retorna la posición
si no está lo agrega y retonra la posición.
}
function addToArray(var v: TDAofNInt; k: integer): integer;

{
Si k está en v lo quita y retorna la posición de donde fue quitado.
Si k no está en retorna -1
}
function delFromArray(var v: TDAOfNInt; k: integer): integer;


function boolToInt(a: boolean): integer;
function IntToBool(i: integer): boolean;

(* Verifica si el punto es interior al Poligono X *)
function InternalPoint(Q: NComplex; X: TDAOfNComplex): boolean;

(* Area  vista "Con signo" de un Poligono. Retorna el área del poligono positiva
si el orden del polígono es Anti-horario y negativa en casao contrario. *)
function AreaDeUnPoligono(puntos: TDAofNComplex): NReal;

// Retorna un entero entre 1 y trunc( r_NMustrasPorCiclo )
// corresponiente a la posición de la muestra en un ciclo de trunc( r_NMuestrasPorCiclo ) considerando
// un Offset r_Offset dentro del ciclo (r_Offset tiene que ser un número entre 0 y 1 e
// indica la posición de la primera muestra (kMuestra = 1) dentro del ciclo como facción del mismo
function kPasoCiclico(kMuestra: integer;
  r_NMuestrasPorCiclo, r_OffsetCiclo: NReal): integer;


// dados a y b en un ciclo retorna min( abs(a-b), ciclo - abs(a-b) )
// asume a y b en [0, ciclo)
function DistanciaCircular( a, b, ciclo: NReal ): NReal;

function ContarCaracter( const s: string; letra: char ): integer;


// retorna el trim() del estring entre s_open y s_close y elimina de s
// sede el inicio hasta s_close inclusive.
function nextPalEntre(var s: string; s_open, s_close: string ): string;

// igual que la anterior, pero si no encuentra s_open o s_clos retorna false
function nextPalEntreEstricto(out res: string; var s: string; s_open, s_close: string ): boolean;


implementation

uses
  matcpx, algebrac;

function kPasoCiclico(kMuestra: integer;
  r_NMuestrasPorCiclo, r_OffsetCiclo: NReal): integer;
var
  ir: NReal;
  res: integer;
begin
  ir := frac((kMuestra - 1) / r_NMuestrasPorCiclo + r_OffsetCiclo) *
    r_NMuestrasPorCiclo + 1;
  res := round(ir);
  if res > trunc(r_NMuestrasPorCiclo) then
    res := 1;
  Result := res;
end;

function DistanciaCircular(a, b, ciclo: NReal): NReal;
var
  d: NReal;
begin
  d:= abs( a - b );
  result:= min( d, ciclo - d );
end;


function ContarCaracter( const s: string; letra: char ): integer;
var
  k, cnt: integer;
begin
 cnt:= 0;
 for k:= 1 to length( s ) do
   if s[k] = letra then inc( cnt );
 result:= cnt;
end;




function nextPalEntre(var s: string; s_open, s_close: string): string;
var
  i1, i2: integer;
  res: string;
begin
  i1:= pos( s_open, s );
  if (i1 = 0 ) then
  begin
    result:= trim( s );
    s:= '';
    exit;
  end;

  delete( s, 1, i1 -1 + length( s_open )  );
  i2:= pos( s_close, s );

  if i2 = 0 then
  begin
    result:= trim(s );
    s:= '';
    exit;
  end;

  res:= copy( s, 1, i2-1 );
  result:= trim( res );
  delete( s, 1, i2-1 + length( s_close ) );
end;

function nextPalEntreEstricto(out res: string; var s: string; s_open,
  s_close: string): boolean;
var
  i1, i2: integer;
begin
  i1:= pos( s_open, s );
  if (i1 = 0 ) then
  begin
    res:= trim( s );
    s:= '';
    result:= false;
    exit;
  end;

  delete( s, 1, i1 -1 + length( s_open )  );
  i2:= pos( s_close, s );

  if i2 = 0 then
  begin
    res:= trim(s );
    s:= '';
    result:= false;
    exit;
  end;

  res:= copy( s, 1, i2-1 );
  delete( s, 1, i2-1 + length( s_close ) );
  result:= true;
end;


{
BUsca el valor k en el array y si lo encuentra retorna la posición.
Si no lo encuentra retorna -1
}
function kInArray(const v: TDAOfNInt; k: integer): integer;
var
  j: integer;
  buscando: boolean;
begin
  buscando := True;
  for j := 0 to high(v) do
    if v[j] = k then
    begin
      buscando := False;
      break;
    end;
  if buscando then
    Result := -1
  else
    Result := j;
end;

{
Primero se fija si k está en v, si está retorna la posición
si no está lo agrega y retonra la posición.
}
function addToArray(var v: TDAofNInt; k: integer): integer;
var
  j: integer;
begin
  j := kInArray(v, k);
  if j < 0 then
  begin
    setlength(v, length(v) + 1);
    v[high(v)] := k;
    Result := high(v);
  end
  else
    Result := j;
end;

{
Si k está en v lo quita y retorna la posición de donde fue quitado.
Si k no está en retorna -1
}
function delFromArray(var v: TDAOfNInt; k: integer): integer;
var
  j, h: integer;
  res: TDAOfNInt;
begin
  j := kInArray(v, k);
  if j >= 0 then
  begin
    setlength(res, length(v) - 1);
    for h := 0 to j - 1 do
      res[h] := v[h];
    for h := j + 1 to high(v) do
      res[h - 1] := v[h];
    setlength(v, 0);
    v := res;
  end;
  Result := j;
end;

function interpolacion_parabolica_012(const y0, y1, y2: NReal; u: NReal): NReal;
{
y = a u^2 + b u + c
con u = ( x - x0 ) / dx

y0 =   c
y1 = a  + b + c
y2 = 4 a + 2 b + c

-2a - c = y2 - 2 y1
a = ( y2 - 2 * y1 + c ) / 2
b = y1 - a - c
}
var
  a, b, c: NREal;
begin
  c := y0;
  a := (y2 - 2 * y1 + c) / 2;
  b := y1 - a - c;
  Result := (a * u + b) * u + c;
end;



procedure crc32_in_res(var res: integer; const cadena: string);
var
  k: integer;
  i: integer;
begin
  for k := 1 to length(cadena) do
  begin
    i := Ord(cadena[k]);
    res := res xor i;
    if (res and $80000000) = 0 then
      res := res shl 1
    else
      res := (res shl 1) or 1;
  end;
end;



function NextPal(var s: string; sep: char): string;
var
  k1, k2: integer;
  ts: string;
  separadores: TSetOfChar;
begin
  separadores := [sep, ' '];
  k1 := 1;
  while (k1 <= Length(s)) and (s[k1] in Separadores) do
    Inc(k1);
  k2 := k1;
  while (k2 <= Length(s)) and not (s[k2] in Separadores) do
    Inc(k2);
  ts := copy(s, k1, k2 - k1);
  Delete(s, 1, k2);
  Result := ts;
end;



function DAOfNRealToStr_(const valor: array of double; precision: integer;
  decimales: integer; sep: char): string;
var
  k: integer;
  res: string;
  seps: shortstring;
begin
  res := '';
  if sep <> ' ' then
    seps := sep + ' '
  else
    seps := ' ';

  if length(valor) > 0 then
  begin
    res := FloatToStrF(valor[0], ffFixed, precision, decimales);
    for k := 1 to high(valor) do
      res := res + seps + FloatToStrF(valor[k], ffFixed, precision, decimales);
  end;
  Result := res;
end;


function DAOfNRealToStr_(const valor: array of double; sep: char): string;
var
  k: integer;
  res: string;
  seps: shortstring;
begin
  res := '';
  if sep <> ' ' then
    seps := sep + ' '
  else
    seps := ' ';

  if length(valor) > 0 then
  begin
    res := FloatToStr(valor[0]);
    for k := 1 to high(valor) do
      res := res + seps + FloatToStr(valor[k]);
  end;
  Result := res;
end;



function StrToDAOfNReal_(s: string; sep: char): TDAOfNReal;
var
  res: TDAOfNReal;
  cnt: integer;
  maxcnt: integer;
  v: NReal;
  pal: string;

begin
  setlength(res, 100);
  maxcnt := 100;
  cnt := 0;
  while s <> '' do
  begin
    pal := nextpal(s, sep);
    if pal <> '' then
    begin
      v := StrToFloat(pal);
      if cnt = maxcnt then
      begin
        Inc(maxcnt, 10);
        setlength(res, maxcnt);
      end;
      res[cnt] := v;
      Inc(cnt);
    end;
  end;
  setlength(res, cnt);
  Result := res;
end;


function DAOfNIntToStr(const valor: TDAOfNInt; sep: char): string;
var
  k: integer;
  res: string;
  seps: shortstring;
begin
  res := '';

  if sep <> ' ' then
    seps := sep + ' '
  else
    seps := ' ';

  if length(valor) > 0 then
  begin
    res := IntToStr(valor[0]);
    for k := 1 to high(valor) do
      res := res + seps + IntToStr(valor[k]);
  end;
  Result := res;
end;

function StrToDAOfNInt(s: string; sep: char): TDAOfNInt;
var
  res: TDAOfNInt;
  cnt: integer;
  maxcnt: integer;
  v: NInt;
  pal: string;
begin
  setlength(res, 100);
  maxcnt := 100;
  cnt := 0;
  while s <> '' do
  begin
    pal := nextpal(s, sep);
    if pal <> '' then
    begin
      v := StrToInt(pal);
      if cnt = maxcnt then
      begin
        Inc(maxcnt, 10);
        setlength(res, maxcnt);
      end;
      res[cnt] := v;
      Inc(cnt);
    end;
  end;
  setlength(res, cnt);
  Result := res;
end;



procedure StoreInFile_DAOfNReal(var f: file; var a: TDAOfNReal);
var
  n: integer;
begin
  n := length(a);
  blockwrite(f, n, sizeof(n));
  blockwrite(f, a[0], sizeof(NReal) * n);
end;

procedure LoadFromFile_DAOfNReal(var f: file; var a: TDAOfNReal);
var
  n: integer;
begin
  blockread(f, n{%H-}, sizeOf(integer));
  setlength(a, n);
  blockread(f, a[0], SizeOf(NReal) * n);
end;

procedure StoreInFile_DAOfNInt(var f: file; var a: TDAOfNInt);
var
  n: integer;
begin
  n := length(a);
  blockwrite(f, n, sizeof(n));
  blockwrite(f, a[0], sizeof(NInt) * n);
end;

procedure LoadFromFile_DAOfNInt(var f: file; var a: TDAOfNInt);
var
  n: integer;
begin
  blockread(f, n{%H-}, sizeOf(n));
  setlength(a, n);
  blockread(f, a[0], SizeOf(NInt) * n);
end;


procedure printvect(var f: textfile; const a: TDAOfNReal; NElementosPorLinea: integer);
var
  k, cnt: integer;
begin
  writeln(f, 'NElementos:', #9, length(a));
  cnt := 0;
  for k := 0 to high(a) do
  begin
    if cnt > 0 then
      Write(f, #9);
    Write(f, a[k]);
    Inc(cnt);
    if cnt = NElementosPorLinea then
    begin
      cnt := 0;
      writeln(f);
    end;
  end;
  if cnt > 0 then
    writeln(f);
end;

procedure vcopy(var a: TDAOfNReal; const b: TDAOfNReal);
var
  i: integer;
begin
  {$IFOPT R+}
  if length(a) <> length(b) then
    raise Exception.Create('vcopy, no coinciden los largos.');
  {$ENDIF}
  for i := 0 to high(b) do
    a[i] := b[i];
end;

procedure vcopy(pa, pb: PLAOfNReal; N: integer); overload;
var
  i: integer;
begin
  for i := 0 to N - 1 do
    pa[i] := pb[i];
end;


procedure vcopy(var a: TDAofNInt; const b: TDAofNInt);
var
  i: integer;
begin
  {$IFOPT R+}
  if length(a) <> length(b) then
    raise Exception.Create('vcopy, no coinciden los largos.');
  {$ENDIF}
  for i := 0 to high(b) do
    a[i] := b[i];
end;

procedure vcopyTramo(var destino: TDAofNReal; const origen: TDAofNReal;
  jDesde, N: integer);
var
  i: integer;
begin
  {$IFOPT R+}
  if length(Destino) < (jDesde + N) then
    raise Exception.Create('vcopyTramo, (jDesde+N) = ' + IntToStr(
      jDesde + N) + ' > length(Destino) = ' + IntToStr(length(destino)));

  if length(Origen) < (jDesde + N) then
    raise Exception.Create('vcopyTramo, (jDesde+N) = ' + IntToStr(
      jDesde + N) + ' > length(Origen) = ' + IntToStr(length(destino)));

  {$ENDIF}

  for i := 0 to N - 1 do
    destino[i + jDesde] := origen[i + jDesde];
end;


procedure vcopyTramoDesplazando(var destino: TDAofNReal; jDesdeDestino: integer;
  const origen: TDAofNReal; jDesdeOrigen: integer; N: integer);

var
  i: integer;
begin

  {$IFOPT R+}
  if length(Destino) < (jDesdeDestino + N) then
    raise Exception.Create('vcopyTramo2, (jDesdeDestino+N) = ' +
      IntToStr(jDesdeDestino + N) + ' > length(Destino) = ' +
      IntToStr(length(destino)));

  if length(Origen) < (jDesdeOrigen + N) then
    raise Exception.Create('vcopyTramo, (jDesdeOrigen+N) = ' + IntToStr(
      jDesdeOrigen + N) + ' > length(Origen) = ' + IntToStr(length(destino)));

  {$ENDIF}

  for i := 0 to N - 1 do
    destino[i + jDesdeDestino] := origen[i + jDesdeOrigen];
end;

procedure vcopyTramoDesplazando(var destino: TDAofNInt; jDesdeDestino: integer;
  const origen: TDAofNInt; jDesdeOrigen: integer; N: integer);
var
  i: integer;
begin

  {$IFOPT R+}
  if length(Destino) < (jDesdeDestino + N) then
    raise Exception.Create('vcopyTramo2, (jDesdeDestino+N) = ' +
      IntToStr(jDesdeDestino + N) + ' > length(Destino) = ' +
      IntToStr(length(destino)));

  if length(Origen) < (jDesdeOrigen + N) then
    raise Exception.Create('vcopyTramo, (jDesdeOrigen+N) = ' + IntToStr(
      jDesdeOrigen + N) + ' > length(Origen) = ' + IntToStr(length(destino)));

  {$ENDIF}

  for i := 0 to N - 1 do
    destino[i + jDesdeDestino] := origen[i + jDesdeOrigen];
end;

function vsumaproducto(const a, b: TDAOfNReal): NReal;
var
  i: integer;
  acum: NReal;
begin
  acum := 0;
  {$IFOPT R+}
  if length(a) <> length(b) then
    raise Exception.Create('vsumaproducto, no coinciden los largos.');
  {$ENDIF}

  for i := 0 to high(a) do
    acum := acum + a[i] * b[i];
  Result := acum;
end;


function vsumaproducto(const a, b: TDAOfNInt): NReal;
var
  i: integer;
  acum: NReal;
begin
  acum := 0;
  {$IFOPT R+}
  if length(a) <> length(b) then
    raise Exception.Create('vsumaproducto, no coinciden los largos.');
  {$ENDIF}

  for i := 0 to high(a) do
    acum := acum + a[i] * b[i];
  Result := acum;
end;




function viguales(const a, b: TDAOfNReal): boolean;
var
  i: integer;
  res: boolean;
begin
  if length(a) <> length(b) then
  begin
    Result := False;
    exit;
  end;

  res := True;
  for i := 0 to high(a) do
    if a[i] <> b[i] then
    begin
      res := False;
      break;
    end;
  Result := res;
end;

function vmin(const a: TDAofNReal): NReal;
var
  i: integer;
  res: NReal;
begin
  res := a[0];
  for i := 1 to high(a) do
    if a[i] < res then
      res := a[i];
  Result := res;
end;

function vmin(const a: TDAofNInt): integer;
var
  i: integer;
  res: integer;
begin
  res := a[0];
  for i := 1 to high(a) do
    if a[i] < res then
      res := a[i];
  Result := res;
end;


function vmax(const a: TDAofNReal): NReal;
var
  i: integer;
  res: NReal;
begin
  res := a[0];
  for i := 1 to high(a) do
    if a[i] > res then
      res := a[i];
  Result := res;
end;

function vmax(const a: TDAofNInt): integer; overload;
var
  i, res: integer;
begin
  res := a[0];
  for i := 1 to high(a) do
    if a[i] > res then
      res := a[i];
  Result := res;
end;

procedure vminmax(var min, max: integer; const a: TDAOfNInt);
var
  i: integer;
begin
  min := a[0];
  max := a[0];
  for i := 1 to high(a) do
    if a[i] > max then
      max := a[i]
    else if a[i] < min then
      min := a[i];
end;

procedure vminmax(var min, max: NReal; const a: TDAOfNReal);
var
  i: integer;
begin
  min := a[0];
  max := a[0];
  for i := 1 to high(a) do
    if a[i] > max then
      max := a[i]
    else if a[i] < min then
      min := a[i];
end;


procedure vacum(var acum: TDAofNReal; const Source: TDAofNReal);
var
  i: integer;
begin
  for i := 0 to high(acum) do
    acum[i] := acum[i] + Source[i];
end;

procedure vacum(jIni: integer; var acum: TDAofNReal; const Source: TDAofNReal;
  Count: integer); overload;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    acum[jIni + i] := acum[jIni + i] + Source[jIni + i];
end;

procedure vacum(var acum: TDAofNReal; jIniAcum: integer; const Source: TDAofNReal;
  jIniSource: integer; Count: integer); overload;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    acum[jIniAcum + i] := acum[jIniAcum + i] + Source[jIniSource + i];
end;

procedure vacumPonderado(var acum: TDAofNReal; const Source: TDAofNReal;
  ponder: NReal); overload;
var
  i: integer;
begin
  for i := 0 to high(acum) do
    acum[i] := acum[i] + Source[i] * ponder;
end;

procedure vacumPonderado(jIni: integer; var acum: TDAofNReal;
  const Source: TDAofNReal; Count: integer; ponder: NReal); overload;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    acum[jIni + i] := acum[jIni + i] + Source[jIni + i] * ponder;
end;

procedure vacumPonderado(var acum: TDAofNReal; jIniAcum: integer;
  const Source: TDAofNReal; jIniSource: integer; Count: integer;
  ponder: NReal); overload;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    acum[jIniAcum + i] := acum[jIniAcum + i] + Source[jIniSource + i] * ponder;
end;


procedure liberarVector(var a: TDAofNReal);
begin
  if a <> nil then
  begin
    setlength(a, 0);
    a := nil;
  end;
end;

procedure liberarMatriz(var mat: TMatOfNReal);
var
  i: integer;
begin
  if mat <> nil then
  begin
    for i := 0 to high(mat) do
      SetLength(mat[i], 0);
    SetLength(mat, 0);
    mat := nil;
  end;
end;

procedure Free_MatOfNreal(var a: TMatOfNReal);
begin
  liberarMatriz(a);
end;


function create_clone(mat: TMatOfNReal): TMatOfNReal;
var
  i: integer;
  res: TMatOfNReal;

begin
  setlength(res, length(mat));
  for i := 0 to high(mat) do
    res[i] := copy(mat[i]);
  Result := res;
end;


function create_MatOfNreal(nf, nc: integer): TMatOfNReal;
var
  k: integer;
  res: TMatOfNReal;
begin
  setlength(res, nf);
  for k := 0 to nf - 1 do
    setlength(res[k], nc);
  Result := res;
end;




function moduloCiclico(dividendo, divisor: integer): cardinal;
var
  res: integer;
begin
  res := dividendo mod divisor;
  if res >= 0 then
    Result := res
  else
    Result := res + divisor;
end;

function moduloRealEntero(dividendo: NReal; divisor: integer): NReal;
begin
  Result := frac(dividendo / divisor) * divisor;
end;

function StrToFloat(const s: string): NReal;
begin
  Result := uevaluador.evalStrToFloat(s);
end;




procedure vswap(var a, b: integer);
var
  tv: integer;
begin
  tv := a;
  a := b;
  b := tv;
end;

procedure vswap(var a, b: NReal);
var
  tv: NReal;
begin
  tv := a;
  a := b;
  b := tv;
end;

procedure vswap(var a, b: TDAOfNReal);
var
  tv: TDAOfNReal;
begin
  tv := a;
  a := b;
  b := tv;
end;


procedure vCopySwap(var a, b: TDAOfNReal);
var
  v: NReal;
  k: integer;
begin
  for k := 0 to high(a) do
  begin
    v := a[k];
    a[k] := b[k];
    b[k] := v;
  end;
end;

procedure vswap(var a, b: TDAOfNInt);
var
  tv: TDAOfNInt;
begin
  tv := a;
  a := b;
  b := tv;
end;

procedure vswap(var a, b: TDAOfBoolean);
var
  tv: TDAOfBoolean;
begin
  tv := a;
  a := b;
  b := tv;
end;



procedure vclear(var a: TDAofNInt; kIni, kFin: integer);
var
  k: integer;
begin
  for k := kIni to kFin do
    a[k] := 0;
end;

procedure vclear(var a: TDAofNReal; kIni, kFin: integer);
var
  k: integer;
begin
  for k := kIni to kFin do
    a[k] := 0;
end;


procedure vclear(var a: TDAofNReal);
var
  k: integer;
begin
  for k := 0 to high(a) do
    a[k] := 0;
end;

procedure vclear(var a: TDAOfBoolean; ClearVal: boolean = False);
var
  k: integer;
begin
  for k := 0 to high(a) do
    a[k] := ClearVal;
end;

function vsum(const a: TDAOfBoolean): integer;
var
  res: integer;
  k: integer;
begin
  res := 0;
  for k := 0 to high(a) do
    if a[k] then
      Inc(res);
  Result := res;
end;



function vsum(const a: TDAofNReal): NReal;
var
  res: NReal;
  k: integer;
begin
  res := 0;
  for k := 0 to high(a) do
    res := res + a[k];
  Result := res;
end;


function vsum(pv: PNReal; N: integer): NReal;
var
  res: NReal;
  k: integer;
begin
  res := 0;
  for k := 0 to N - 1 do
    res := res + TLAOfNReal(pointer(pv)^)[k];
  Result := res;
end;


function vprom(const a: TDAofNReal): NReal;
begin
  Result := vsum(a) / length(a);
end;


function vprom(pv: PNReal; N: integer): NReal;
begin
  Result := vsum(pv, N) / N;
end;

procedure vmultr(var a: TDAofNReal; r: NReal);
var
  k: integer;
begin
  for k := 0 to high(a) do
    a[k] := a[k] * r;
end;

procedure vmultr(var a: TDAofNInt; r: NReal);
var
  m: NReal;
  k: integer;
begin
  for k := 0 to high(a) do
  begin
    m := a[k] * r;
    a[k] := trunc(m + 0.5);
  end;
end;


procedure vclear(var a: TDAofNInt);
var
  k: integer;
begin
  for k := 0 to high(a) do
    a[k] := 0;

end;

function vsum(const a: TDAofNInt): integer;
var
  res: integer;
  k: integer;
begin
  res := 0;
  for k := 0 to high(a) do
    res := res + a[k];
  Result := res;
end;



function vprom(const a: TDAofNInt): NReal;
begin
  Result := vsum(a) / length(a);
end;


function SignoNR(x: NReal): integer;
begin
  if x < 0 then
    signoNR := -1
  else if x = 0 then
    signoNR := 0
  else
    signoNR := 1;
end;


function EsCero(x: NReal): boolean;
begin
  EsCero := Abs(x) < AsumaCero;
end;

function EsCero(z: NComplex): boolean;
begin
  Result := EsCero(z.r) and EsCero(z.i);
end;

function Casi0(x: NReal; xCero: NReal): boolean;
begin
  Casi0 := abs(x) < xCero;
end;


function calceps: NReal;
{calceps
  This function returns the machine EPSILON or floating point tolerance,
  the smallest positive real number such that 1.0 + EPSILON > 1.0.
  EPSILON is needed to set various tolerances for different algorithms.
  While it could be entered as a constant, I prefer to calculate it, since
  users tend to move software between machines without paying attention to
  the computing environment. Note that more complete routines exist.
}
var
  e, e0: NReal;
  i: integer;
begin {calculate machine epsilon}
  e0 := 1;
  i := 0;
  repeat
    e0 := e0 / 2;
    e := 1 + e0;
    i := i + 1;
  until (e = 1.0) or (i = 500000); {note safety check}
  e0 := e0 * 2;
  { Writeln('Machine EPSILON =',e0);}
  calceps := e0;
end; {calceps}



function boolToInt(a: boolean): integer;
begin
  if a then
    Result := 1
  else
    Result := 0;
end;

function IntToBool(i: integer): boolean;
begin
  Result := i <> 0;
end;




(* Area "con signo" de un triangulo especificado por tres complejos
Si es >= indica que  c1, c2, c3 están ordenados en sentido anti-horario *)
function AreaTriangulo(c1, c2, c3: NComplex): NReal;
var
  a: NREal;
begin       // a = (c3-c1) X (c2 - c1 )
  (*
  a := (c2.r * c3.i - c2.i * c3.r) - (c1.r * c3.i - c1.i * c3.r) +
    (c1.r * c2.i - c1.i * c2.r);
  *)
  a := (c2.r - c1.r) * (c3.i - c1.i) - (c2.i - c1.i) * (c3.r - c1.r);
  Result := 0.5 * a;
end;


(* Area "Con signo" de un Poligono. Retorna el área del poligono positiva
si el orden del polígono es Anti-horario y negativa en casao contrario *)
function AreaDeUnPoligono(puntos: TDAofNComplex): NReal;
var
  a: NREal;
  j: integer;
begin
  a := 0;
  for j := 0 to High(puntos) - 1 do
    a := a + AreaTriangulo(puntos[0], puntos[j], puntos[j + 1]);
  a := a + AreaTriangulo(puntos[0], puntos[high(puntos)], puntos[0]);
  Result := a;
end;

function PointVectMult(const u, v: NComplex): NReal;
begin
  Result := u.r * v.i - u.i * v.r;
end;

function InternalPoint(Q: NComplex; X: TDAOfNComplex): boolean;
var
  par: boolean;
  k: integer;
  amb1, amb2: integer;

  function intersec(var A, B: NComplex): integer;
  var
    QA, QB: NComplex;
    t1, t2: NReal;
  begin
    QA := rc(A, Q)^;
    QB := rc(B, Q)^;
    t1 := QA.r;
    t2 := QB.r;
    if PointVectMult(QA, QB) > 0 then
      if (t1 < 0) and (t2 > 0) then
        intersec := 1
      else if (t1 = 0) or (t2 = 0) then
        if (t1 < 0) or (t2 > 0) then
          intersec := 2
        else
          intersec := 0
      else
        intersec := 0
    else
    if (t1 > 0) and (t2 < 0) then
      intersec := 1
    else if (t1 = 0) or (t2 = 0) then
      if (t1 > 0) or (t2 < 0) then
        intersec := -2
      else
        intersec := 0
    else
      intersec := 0;
  end;

  procedure proc1(k, j: integer);
  begin
    case intersec(x[k], x[j]) of
      1: par := par xor True;
      2: Inc(amb1);
      -2: Inc(amb2);
      else {nada}
    end;
  end;

begin
  par := False;
  amb1 := 0;
  amb2 := 0;
  for k := 0 to high(X) - 1 do
    proc1(k, k + 1);
  proc1(high(X), 0);
  amb1 := amb1 - amb2;
  internalPoint := par xor (amb1 <> 0);
end;


begin
  AsumaCero := CalcEps;
  DosPi := 2 * Pi;
end.
