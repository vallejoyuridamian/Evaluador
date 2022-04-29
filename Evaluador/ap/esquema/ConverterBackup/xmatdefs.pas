{$IFDEF DOS}
{$O+,F+,D-,L-}
{$ENDIF}

{ Definiciones Corrientes para uso en matem ticas }
unit xMatDefs;
interface
uses
   Sysutils,
   uevaluador,
   Math;

type

(* Con la siguiente definición, ganamos ademas de precisión
velocidad cuando estemos usando un coprocesador numérico.
	Si se estan utilizando las rutinas de emulación, se aumenta
la precisión pero obiamente la velocidaddecrece.
	!!!OJO: no utilizar el tipo Real mezclado con estas cosas,
	supongamos que salvamos un archivo un número real, pasa a ser
	una complicación leerlo ya que podemos haber cambiado las
	opciones de compilación.

	Los programas que esten pensados para uso general deberán
poder reconocer con que estado se salvó un archivo, para lo
cual se deberá salvar también un indicativo.

	LO MÁS SANO ES DEJAR LAS OPCIONES DE COMPILACIÓN SIEMPRE
CON N+, E+  AUNQUE SE PIERDA VELOCIDAD CUANDO NO SE TENGA
COPROCESADOR.

	EL problema del aumento de tamaño de los vectores de reales
es solo un corriemiento del límite que ya teniamos cuando
usabamos reales solamente. La solución al problema pasa por
el uso de espacios de memoria virtual, para lo que hemos
desarrollado los Vectores Gigantes Paginads (VGP) *)

	NReal= double;
	PNReal = ^NReal;
	NInt= integer;
	PNInt= ^NInt;

const
   MaxNReal= Math.MaxDouble;

type

  NComplex = Record
					r, i  :NReal
				 end;
  PNComplex= ^NComplex;

const
	Complex_UNO: NComplex= (r:1; i:0);


type
	TDAofNCardinal= array of Cardinal;
	TDAofNInt= array of integer;
  PDAofNInt= ^TDAofNInt;
	TDAofNReal= array of NReal;
	TDAofNComplex= array of NComplex;
	TDAofString= array of string;
	TDAOfBoolean= array of boolean;
	TDAOfPtr= array of Pointer;

  TMatOfBoolean = array of TDAOfBoolean;
  TMatOfNInt= array of TDAofNInt;
  TMatOfNReal = array of TDAofNReal;
  TDAOfMatOfNReal = array of TMatOfNReal;
  TMatOfString = array of TDAofString;

type
	TFdeX=function(x:NReal):NReal;

type
	NEntero = NInt;
	PNEntero = ^NInt;

type
	TDAofI= array of NInt;
  TSetOfChar = set of char;

{ Redefinicion de los timpos estandar para que el compilador detecte
como un error el uso indebido de los mismos }
	extended = boolean;
	real = boolean;


{ Las siguientes constantes son calculadas en el auto-arranque de
la unidad por lo que no es aconsejable utilizarlas en los procedimientos
de auto-arranque de otras unidades pues de hacerlo habrá que tener
}
var
	AsumaCero: NReal; {EPSILON de la maquina en cuentas con NReal }
	DosPi: NReal;		{ 2*Pi }


{ abs(x) < AsumaCero }
function EsCero( x: NReal ): boolean;

{ Casi0:= Abs(x)< xCero.
	xCero debe ser un numero positivo }
function Casi0( x: NReal; xCero: NReal): boolean;

function SignoNR( x: NReal ): integer;

function vsum( a: TDAofNReal ): NReal; overload;
function vsum( a: TDAofNInt ): integer; overload;
function vprom( a: TDAofNReal ): NReal; overload;
function vprom( a: TDAofNInt ): NReal; overload;

(*+doc
  result:= sumatoria( a[i]*b[i] )
-doc*)
function vsumaproducto( a, b: TDAOfNReal ): NReal; overload;

(*+doc
  a[i]:= b[i] ; i:= 0... high(b)
-doc*)
procedure vcopy( var a: TDAOfNReal; const b: TDAOfNReal ); overload;

(*+doc
  destino[ i+ jDesde]:= origen[ i + jDesde] ; i:= 0 ... N-1
-doc*)
procedure vcopyTramo(
  var destino: TDAofNReal;
  const origen: TDAofNReal;
  jDesde, N : Integer );

(*+doc
  destino[ i+ jDesdeDestino]:= origen[ i + jDesdeOrigen] ; i:= 0 ... N-1
-doc*)
procedure vcopyTramoDesplazando(
  var destino: TDAofNReal;
  jDesdeDestino: Integer;
  const origen: TDAofNReal;
  jDesdeOrigen : Integer;
  N : Integer );

procedure vmultr( var a: TDAofNReal; r: NReal ); overload;
procedure vmultr( var a: TDAofNInt; r: NReal ); overload;

procedure vclear( var a: TDAofNInt ); overload;
procedure vclear( var a: TDAofNReal ); overload;

procedure vswap( var a, b: TDAOfNReal ); overload;
procedure vswap( var a, b: TDAOfNInt ); overload;
procedure vswap( var a, b: NReal ); overload;
procedure vswap( var a, b: integer ); overload;

function vmax( a: TDAofNReal ) : NReal; overload;
function vmax( a: TDAofNInt ) : Integer; overload;

//Suma a acum los valores de source
//source y acum deben tener el mismo tamaño
procedure vacum( var acum: TDAofNReal; const source: TDAofNReal); overload;
//Suma a acum count valores de source desde jIni
procedure vacum( jIni: Integer ; var acum: TDAofNReal; const source: TDAofNReal; count : Integer ); overload;
//Suma a acum desede jIniAcum count valores de source desde jIniSource
procedure vacum( var acum: TDAofNReal; jIniAcum: Integer; const source: TDAofNReal; jIniSource : Integer; count : Integer ); overload;

//Suma a acum los valores de source ponderados por ponder
//source y acum deben tener el mismo tamaño
procedure vacumPonderado(var acum: TDAofNReal; const source: TDAofNReal ; ponder :NReal ); overload;
//Suma a acum count valores de source desde jIni multipicados por ponder
procedure vacumPonderado( jIni: Integer ; var acum: TDAofNReal; const source: TDAofNReal; count : Integer ; ponder :NReal ); overload;
//Suma a acum desede jIniAcum count valores de source desde jIniSource multipicados por ponder
procedure vacumPonderado( var acum: TDAofNReal; jIniAcum: Integer; const source: TDAofNReal; jIniSource : Integer; count : Integer ; ponder :NReal); overload;

procedure liberarMatriz(var mat: TMatOfNReal);

function moduloCiclico(dividendo, divisor: Integer): Cardinal;

// redefino esta función de sysutils para hacerla pasar primero
// por un evaluador de expresiones.
// para que esto funcione al incluir esta unidad en la clausula uses
// de otra tener la precausion de ponerla despues de SysUtils (si es que aparece).
function StrToFloat( s: string ): NReal;

function DAOfNRealToStr_( valor: TDAOfNReal; precision : integer; decimales : integer; sep: char ): string;
function StrToDAOfNReal_( s: string; sep: char ): TDAOfNReal;

implementation

function NextPal(var s: string; sep: char ): string;
var
	k1, k2: integer;
	ts: string;
  separadores: TSetOfChar;
begin
  separadores:= [ sep, ' '];
	k1:= 1;
	while (k1<= Length(s)) and (s[k1] in Separadores ) do inc(k1);
  k2:= k1;
	while (k2<= Length(s)) and not(s[k2] in Separadores) do inc(k2);
  ts:= copy(s, k1, k2-k1);
  delete(s, 1, k2);
	result:= ts;
end;


function DAOfNRealToStr_( valor: TDAOfNReal; precision : integer; decimales : integer; sep: char ): string;
var
  k: integer;
  res: string;
  seps: shortstring;
begin
  res:= '';
  
  if sep <> ' ' then 
	  seps:= sep+' '
  else
 	  seps:= ' ';

	if length( valor ) > 0 then
  begin
    res:= FloatToStrF(valor[0], ffFixed, precision, decimales );
    for k:= 1 to high( valor ) do
       res:= res+seps+FloatToStrF(valor[k], ffFixed, precision, decimales );
  end;
  result:= res;
end;

function StrToDAOfNReal_( s: string; sep: char ): TDAOfNReal;
var
  res: TDAOfNReal;
  cnt: integer;
  maxcnt: integer;
  v: NReal;
  pal: string;

begin
  setlength( res, 100 );
  maxcnt:= 100;
  cnt:= 0;
  while s <> '' do
  begin
    pal:= nextpal( s, sep );
    if pal <> '' then
    begin
      v:= StrToFloat( pal );
      if cnt = maxcnt then
      begin
        inc( maxcnt, 10 );
        setlength( res, maxcnt );
      end;
      res[cnt]:= v;
      inc( cnt );
    end;
  end;
  setlength( res, cnt );
  result:= res;
end;

procedure vcopy( var a: TDAOfNReal; const b: TDAOfNReal );
var
  i: integer;
begin
  {$IFOPT R+}
  if  length(a) <>  length(b) then
    raise Exception.Create('vcopy, no coinciden los largos.');
  {$ENDIF}
  for i:= 0 to high( b ) do
      a[i]:= b[i];
end;

procedure vcopyTramo( var destino: TDAofNReal; const origen: TDAofNReal; jDesde, N : Integer );
var
  i: Integer;
begin
  {$IFOPT R+}
  if length( Destino ) < ( jDesde + N ) then
    raise Exception.Create('vcopyTramo, (jDesde+N) = '+ IntToStr( jDesde+N )
                  + ' > length(Destino) = '+IntToStr(length( destino )) );

  if length( Origen ) < ( jDesde + N ) then
    raise Exception.Create('vcopyTramo, (jDesde+N) = '+ IntToStr( jDesde+N )
                  + ' > length(Origen) = '+IntToStr(length( destino )) );

  {$ENDIF}

  for i:= 0 to N - 1 do
    destino[i + jDesde]:= origen[i + jDesde];
end;


procedure vcopyTramoDesplazando(
  var destino: TDAofNReal;
  jDesdeDestino: Integer;
  const origen: TDAofNReal;
  jDesdeOrigen : Integer;
  N : Integer );

var
  i: Integer;
begin

  {$IFOPT R+}
  if length( Destino ) < ( jDesdeDestino + N ) then
    raise Exception.Create('vcopyTramo2, (jDesdeDestino+N) = '+ IntToStr( jDesdeDestino+N )
                  + ' > length(Destino) = '+IntToStr(length( destino )) );

  if length( Origen ) < ( jDesdeOrigen + N ) then
    raise Exception.Create('vcopyTramo, (jDesdeOrigen+N) = '+ IntToStr( jDesdeOrigen+N )
                  + ' > length(Origen) = '+IntToStr(length( destino )) );

  {$ENDIF}

  for i:= 0 to N - 1 do
    destino[ i + jDesdeDestino ]:= origen[ i + jDesdeOrigen ];
end;


function vsumaproducto( a, b: TDAOfNReal): NReal;
var
  i: integer;
  acum: NReal;
begin
  acum:= 0;
  {$IFOPT R+}
  if  length(a) <>  length(b) then
    raise Exception.Create('vsumaproducto, no coinciden los largos.');
  {$ENDIF}

  for i:= 0 to high( a ) do
    acum:= acum + a[i]*b[i];
  result:= acum;
end;

function vmax( a: TDAofNReal ) : NReal;
var
	i : Integer;
	res : NReal;
begin
	res := a[0];
	for i := 1 to high(a) do
		if a[i] > res then
			res := a[i];
	result := res
end;

function vmax( a: TDAofNInt ) : Integer; overload;
var
	i, res : Integer;
begin
	res := a[0];
	for i := 1 to high(a) do
		if a[i] > res then
			res := a[i];
	result := res
end;

procedure vacum( var acum: TDAofNReal; const source: TDAofNReal);
var
  i: Integer;
begin
  for i:= 0 to high(acum) do
    acum[i]:= acum[i] + source[i];
end;

procedure vacum( jIni: Integer ; var acum: TDAofNReal; const source: TDAofNReal; count : Integer ); overload;
var
  i: Integer;
begin
  for i:= 0 to Count - 1 do
    acum[jIni + i]:= acum[jIni + i] + source[jIni + i];
end;

procedure vacum( var acum: TDAofNReal; jIniAcum: Integer; const source: TDAofNReal; jIniSource : Integer; count : Integer ); overload;
var
  i: Integer;
begin
  for i:= 0 to Count - 1 do
    acum[jIniAcum + i]:= acum[jIniAcum + i] + source[jIniSource + i];
end;

procedure vacumPonderado(var acum: TDAofNReal; const source: TDAofNReal ; ponder :NReal ); overload;
var
  i: Integer;
begin
  for i:= 0 to high(acum) do
    acum[i]:= acum[i] + source[i] * ponder;
end;

procedure vacumPonderado( jIni: Integer ; var acum: TDAofNReal; const source: TDAofNReal; count : Integer ; ponder :NReal ); overload;
var
  i: Integer;
begin
  for i:= 0 to Count - 1 do
    acum[jIni + i]:= acum[jIni + i] + source[jIni + i] * ponder;
end;

procedure vacumPonderado( var acum: TDAofNReal; jIniAcum: Integer; const source: TDAofNReal; jIniSource : Integer; count : Integer ; ponder :NReal); overload;
var
  i: Integer;
begin
  for i:= 0 to Count - 1 do
    acum[jIniAcum + i]:= acum[jIniAcum + i] + source[jIniSource + i] * ponder;
end;

procedure liberarMatriz(var mat: TMatOfNReal);
var
  i: Integer;
begin
  for i:= 0 to high(mat) do
    SetLength(mat[i], 0);
  SetLength(mat, 0);
  mat:= NIL;
end;

function moduloCiclico(dividendo, divisor: Integer): Cardinal;
var
  res: Integer;
begin
  res:= dividendo mod divisor;
  if res >= 0 then
    result:= res
  else
    result:= res + divisor;
end;

function StrToFloat( s: string ): NReal;
begin
  result:= uevaluador.evalStrToFloat( s );
end;

procedure vswap( var a, b: integer );
var
	tv: integer;
begin
	tv:= a;
	a:= b;
	b:= tv;
end;

procedure vswap( var a, b: NReal );
var
	tv: NReal;
begin
	tv:= a;
	a:= b;
	b:= tv;
end;

procedure vswap( var a, b: TDAOfNReal );
var
	tv: TDAOfNReal;
begin
	tv:= a;
	a:= b;
	b:= tv;
end;

procedure vswap( var a, b: TDAOfNInt );
var
	tv: TDAOfNInt;
begin
	tv:= a;
	a:= b;
	b:= tv;
end;

procedure vclear( var a: TDAofNReal );
var
	k: integer;
begin
	for k:= 0 to high( a ) do
		a[k]:= 0;
end;

function vsum( a: TDAofNReal ): NReal;
var
	res: NReal;
	k: integer;
begin
	res:= 0;
	for k:= 0 to high( a ) do
		res:= res + a[k];
	result:= res;
end;

function vprom( a: TDAofNReal ): NReal;
begin
	result:= vsum( a ) / length( a );
end;

procedure vmultr( var a: TDAofNReal; r: NReal );
var
	k: integer;
begin
	for k:= 0 to high( a ) do
		a[k]:= a[k]* r;
end;

procedure vmultr( var a: TDAofNInt; r: NReal );
var
	m: NReal;
	k: integer;
begin
	for k:= 0 to high( a ) do
	begin
		m:= a[k]*r;
		a[k]:= trunc( m+0.5);
	end;
end;

procedure vclear( var a: TDAofNInt );
var
	k: integer;
begin
	for k:= 0 to high( a ) do
		a[k]:= 0;
end;

function vsum( a: TDAofNInt ): integer;
var
	res: integer;
	k: integer;
begin
	res:= 0;
	for k:= 0 to high( a ) do
		res:= res + a[k];
	result:= res;
end;

function vprom( a: TDAofNInt ): NReal;
begin
	result:= vsum( a ) / length( a );
end;

function SignoNR( x: NReal ): integer;
begin
	if x < 0 then signoNR:= -1
	else if x= 0 then signoNR:= 0
	else signoNR:= 1;
end;

function EsCero( x: NReal ): boolean;
begin
	EsCero := Abs(x) < AsumaCero;
end;

function Casi0( x: NReal; xCero: NReal): boolean;
begin
	Casi0:= abs(x) < xCero;
end;

function calceps:NReal;
{calceps
	This function returns the machine EPSILON or floating point tolerance,
	the smallest positive real number such that 1.0 + EPSILON > 1.0.
	EPSILON is needed to set various tolerances for different algorithms.
	While it could be entered as a constant, I prefer to calculate it, since
	users tend to move software between machines without paying attention to
	the computing environment. Note that more complete routines exist.
}
var
	e,e0: NReal;
	i: integer;
begin {calculate machine epsilon}
	e0 := 1; i:=0;
	repeat
		e0 := e0/2; e := 1+e0;  i := i+1;
	until (e=1.0) or (i=50000); {note safety check}
	e0 := e0*2;
{ Writeln('Machine EPSILON =',e0);}
	calceps:=e0;
end; {calceps}

begin
	AsumaCero:= CalcEps;
	DosPi:= 2*Pi;
end.







































