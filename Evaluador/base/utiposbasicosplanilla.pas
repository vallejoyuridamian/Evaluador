{xDEFINE FORM_LIBRO_SIMSEE}

unit utiposbasicosplanilla;

{$mode delphi}

interface

uses
  Classes,
  {$IFDEF FORM_LIBRO_SIMSEE}
  Grids,
  {$ENDIF}
  ufechas,
  SysUtils;
type
  TRangoRec = record
    fila1, columna1, fila2, columna2: integer;
  end;

  TCelda = class
    valor_str: string;
    formato_str: string;
    constructor Create;
    procedure Free;
  end;

  TFila = class
    Celdas: TList;
    constructor Create;
    function GetCelda( columna: integer ): TCelda;
    procedure Free;
  end;

  THoja = class
    nombre:string;
    Filas_: TList;
    kTabEnLibro: integer;

    constructor Create( xNombre: string );
    function NColumnas: integer;
    function NFilas: integer;



    // Formatea evalua y devuelve el valor a mostrar
    function ReadEvalStr(fila, columna: integer): shortstring;
    procedure WriteEvalStr(fila, columna: integer; nuevoValor: shortstring );

    function ReadStr(fila, columna: integer): shortstring;
    function ReadFloat(fila, columna: integer): extended;
    function ReadInt(fila, columna: integer): integer;

    function GetFila( fila: integer ): TFila;
    function GetCelda( fila, columna: integer ): TCelda;

    function ReadFormato( fila, columna: integer ): string;
    procedure WriteFormato( fila, columna: integer; nuevoFormato: string ); overload;
    procedure WriteFormato( rango: TRangoRec; nuevoFormato: string ); overload;

    procedure Write(fila, columna: integer; val: shortString); overload;
    procedure Write(fila, columna: integer; val: extended); overload;
    procedure Write(fila, columna: integer; val: integer); overload;
    procedure Free;
    {$IFDEF FORM_LIBRO_SIMSEE}
    procedure ShowOnStringGrid( grid: TStringGrid );
    {$ENDIF}
  end;


implementation



(***** Métodos de THoja ******)

constructor THoja.Create( xNombre: string );
begin
  inherited Create;
  self.nombre:= xNombre;
  self.filas_:= TList.Create;
  kTabEnLibro:= -1; // si es agregada a un libro se setea.
end;

function THoja.NColumnas: integer;
var
  maxcnt: integer;
  k: integer;
  aFila: TFila;
begin
  maxcnt:= 0;
  for k:= 0 to filas_.Count-1 do
  begin
    aFila:= filas_[k];
    if aFila.Celdas.Count > maxcnt then maxcnt:= aFila.Celdas.count;
  end;
  result:= maxcnt;
end;

function THoja.NFilas: integer;
begin
  result:= filas_.Count;
end;

function THoja.ReadStr(fila, columna: integer): shortstring;
var
  aFila: TFila;
  aCelda: TCelda;
begin
  if fila > filas_.Count then
    result:= ''
  else
  begin
   aFila:= filas_[ fila - 1 ];
   if columna > aFila.Celdas.Count then
      result:= ''
   else
   begin
      aCelda:= aFila.Celdas[ columna-1 ];
      result:= aCelda.valor_str;
   end;
  end;
end;




procedure THoja.WriteEvalStr(fila, columna: integer; NuevoValor: shortstring );
var
  aCelda: TCelda;
  d: double;
begin
  aCelda:= GetCelda(fila, columna);
  if aCelda.formato_str <> '' then
  begin
    if ( pos('/', aCelda.formato_str ) > 0 ) or ( pos('-', aCelda.formato_str ) > 0 ) then
    begin
       d:= IsoStrToDateTime( NuevoValor );
       aCelda.valor_str:= FloatToStrF( d, ffFixed, 30, 8 );
    end
    else
       aCelda.valor_str:= NuevoValor;
  end
  else
      aCelda.valor_str:= NuevoValor;
end;


function THoja.ReadEvalStr(fila, columna: integer): shortstring;
var
  aFila: TFila;
  aCelda: TCelda;
  s: string;
begin
  if fila > filas_.Count then
  begin
    result:= '';
    exit;
  end;

  aFila:= filas_[ fila - 1 ];
  if columna > aFila.Celdas.Count then
  begin
    result:= '';
    exit;
  end;

  aCelda:= aFila.Celdas[ columna-1 ];
  s:= aCelda.valor_str;

  // aquí habría que evaluar s

  if aCelda.formato_str <> '' then
  begin
    if ( pos('/', aCelda.formato_str ) > 0 ) or ( pos('-', aCelda.formato_str ) > 0 ) then
      s:= DateTimeToIsoStr( StrToFloat( s ) );
  end;
  result:= s;
end;






function THoja.ReadFloat(fila, columna: integer): extended;
var
  s: string;
begin
  s:= ReadStr( fila, columna );
  result:= StrToFloat( s );
end;

function THoja.ReadInt(fila, columna: integer): integer;
var
  s: string;
begin
  s:= ReadStr( fila, columna );
  result:= StrToInt( s );
end;

function THoja.GetFila( fila: integer ): TFila;
var
  aFila: TFila;
begin
  while fila > filas_.Count do
  begin
    aFila:= TFila.Create;
    filas_.Add( aFila );
  end;
  aFila:= filas_[ fila - 1 ];
  result:= aFila;
end;


function THoja.GetCelda( fila, columna: integer ): TCelda;
var
  aFila: TFila;
begin
  aFila:= GetFila( fila );
  result:= aFila.GetCelda( columna );
end;


function THoja.ReadFormato( fila, columna: integer ): string;
var
  aCelda: TCelda;
begin
  aCelda:= GetCelda( fila, columna );
  result:= aCelda.formato_str;
end;


procedure THoja.WriteFormato( fila, columna: integer; nuevoFormato: string );
var
  aCelda: TCelda;
begin
  aCelda:= GetCelda( fila, columna );
  aCelda.formato_str:= NuevoFormato;
end;

procedure THoja.WriteFormato( rango: TRangoRec; nuevoFormato: string );
var
  k, j: integer;
  aFila: TFila;
  aCelda: TCelda;
begin
  for k:= rango.fila1 to rango.fila2 do
  begin
    aFila:= GetFila( k );
    for j:= rango.columna1 to rango.columna2 do
    begin
        aCelda:= aFila.GetCelda( j );
        aCelda.formato_str:= nuevoFormato;
    end;
  end;
end;

procedure THoja.Write(fila, columna: integer; val: shortString);
var
  aCelda: TCelda;
begin
  aCelda:= GetCelda( fila, columna );
  aCelda.valor_str:= val;
end;


procedure THoja.Write(fila, columna: integer; val: extended);
var
  s: string;
begin
  s:= FloatToStr( val );
  write( fila, columna, s );
end;

procedure THoja.Write(fila, columna: integer; val: integer);
var
  s: string;
begin
  s:= IntToStr( val );
  write( fila, columna, s );
end;

{$IFDEF FORM_LIBRO_SIMSEE}
procedure THoja.ShowOnStringGrid( grid: TStringGrid );
var
  k, j: integer;
begin
  grid.Clean;
  for k := 1 to nFilas do
    for j := 1 to nCOlumnas do
    begin
      grid.Cells[j, k] := ReadEvalStr(k, j);
    end;
end;
{$ENDIF}

procedure THoja.Free;
var
  k: integer;
  aFila: TFila;
begin
  for k:= 0 to filas_.count-1 do
  begin
    aFila:= filas_[k];
    aFila.Free;
  end;
  filas_.Free;
  inherited Free;
end;


constructor TFila.Create;
begin
  inherited Create;
  Celdas:= TList.Create;
end;

function TFila.GetCelda( columna: integer ): TCelda;
var
  aCelda: TCelda;
begin
  while columna > Celdas.Count do
  begin
    aCelda:= TCelda.Create;
    Celdas.Add( aCelda );
  end;
  aCelda:= Celdas[ columna-1 ];
  result:= aCelda;
end;

procedure TFila.Free;
var
  k: integer;
  aCelda: TCelda;
begin
  for k:= 0 to celdas.count -1 do
  begin
    aCelda:= celdas[k];
    aCelda.Free;
  end;
  celdas.Free;
  inherited Free;
end;

constructor TCelda.Create;
begin
  inherited Create;
  valor_str:= '';
end;

procedure TCelda.Free;
begin
  inherited Free;
end;


end.

