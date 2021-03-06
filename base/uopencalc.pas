unit uopencalc;

{$mode delphi}

interface

uses
  {$IFDEF OPEN_ODS}
  lclintf,
  {$ENDIF}
  {$IFDEF LCL}
  Dialogs,
  {$ENDIF}
  Classes, SysUtils,
  //uConstantesSimSEE,
  xmatdefs,
  matreal,
  fpstypes, fpspreadsheet, fpsallformats;


type

  { TLibroOpenCalc }

  TLibroOpenCalc = class(TsWorkbook)
    fil, col: integer;
    hoja: TsWorksheet;
    archi: string;
    flgForWrite: boolean;
    flgAutoGuardar: boolean;

    // Atención este es un constructor específico de SimSEE crea por defecto
    // Si archi = '' lo asocia por defecto a uno creado en el directorio temporal
    // de SimSEE con el nombre 'opendocxlt.ods'
    // si flgForWrite = false, el archivo se abre y se lee
    // el flgAutoGuardar opera si flgForWrite=TRUE, al hacer FREE guarda
    constructor Create(flgForWrite: boolean; archi: string=''; flgAutoGuardar: boolean =TRUE );

    // Escribe el archivo
    procedure Guardar;

    procedure go(NombreHoja: string; fila, columna: integer);
    procedure Write(val: shortString); overload;
    procedure Write(val: extended); overload;
    procedure WriteDateTime(val: TDateTime; Formato: string = 'yyyy-mm-dd hh'); overload;
    procedure Write(val: integer); overload;
    procedure Write(val: boolean); overload;
    procedure writeln(val: shortstring); overload;
    procedure writeln(val: extended); overload;
    procedure writeln(val: integer); overload;
    procedure writeln; overload;
    procedure Free;
    procedure VisibleOn;
    procedure VisibleOff;
    procedure SelRango(fil1, col1, fil2, col2: integer);
    procedure CambiarFormato(nuevoFormato: string);
    procedure ir(fila, columna: integer);
    procedure autoFitCells;
    procedure agregoHoja(nombreHoja: string);

    procedure ActivoHoja( nombre: string );
    procedure ActivoHoja_numero(numeroHoja: integer);

    // Escribe la tira de datos con el titulo en fila, columna, empieza los datos
    // en fila+1, columna y los escribe para abajo, deja el cursor en fila,columna+1
    procedure WriteTiraDeDatos(titulo:string; valores: TVectR; var fila, columna:integer;esFecha:boolean = false;DatosNoValidos: TStringList = nil;valorInvalido:string = '');

    // leen un valor incrementando la posición del cursor
    function ReadV_Str: shortstring;
    function ReadV_Float: double;
    function ReadV_Int: integer;
    function ReadV_Bool: boolean;
    function ReadStr: string; overload;
    function ReadStr(k, j: integer ): string; overload;
    function ReadInt(k, j: integer ): integer;
    function ReadFloat(k, j: integer ): double;
    procedure readln;overload;
    procedure readln(out s:string;blancos_consecutivos:integer = 3);overload;

    // Determina la cantidad de números realies en la hoja indicada
    // a partir de la posición (filaIni, colIni) en la dirección determinada
    // por flg_Horizontal
    function Count_NReals( hoja: string; filaini, colini: integer; flg_Horizontal: boolean ): integer;


    // Lee un vector desde el casillero (filaIni, ColIni) de la hoja indicada.
    // Si N < 0 se determina la dimensión buscando el primer casillero que no contenga un Real.
    // el flg_Horizontal indica si se busca en la fila (TRUE) o en la columna.
    function CreateRead_VectR( hoja: string; filaIni, ColINi: integer; N: integer; flg_Horizontal: boolean ): TVectR; overload;

    // rengo_str por ej: A1:A100 o A1:M1
    function CreateRead_VectR( hoja: string; rango_str: String): TVectR; overload;

    // Escribe el vector en la hoja indicada a partir de la posición (filaIni, ColIni) y en la dirección indicada por flg_Horizontal
    procedure Write_VectR(valores: TVectR; hoja: string; filaIni, ColIni: integer;
      flg_Horizontal: boolean); overload;

    procedure Write_VectR(valores: TVectR; hoja: string; celda_str: String;
      flg_Horizontal: boolean); overload;


    // Lee una matriz de la hoja indicada a partir de la posición (filaIni, ColIni)
    // de NFilas por NColumnas. Si NFilas < 0 y/o NColumnas < 0 se explora la primer
    // fila y/o la primer columna para determinar las correspondientes dimensiones.
    function CreateRead_MatR( hoja: string; filaIni, ColINi: integer; NFilas, NColumnas: integer ): TMatR; overload;

    // rango_str por ej: A1:C3 o simplemente solo el casillero superior izquierdo por ej: A1
    function CreateRead_MatR( hoja: string; rango_str: String): TMatR; overload;

    // Escribe la matriz en la hoja indicada a partir de la posición (filaIni, ColIni) y en la dirección indicada por flg_Horizontal
    procedure Write_MatR(m: TMatR; hoja: string; filaIni, ColIni: integer); overload;
    procedure Write_MatR(m: TMatR; hoja: string; celda_str: string ); overload;


    procedure RangoToCeldas( var celda1, celda2: string; rango: string );
    procedure CeldaStrToFilCol(var fil, col: integer; celda: string);
    function FilColToCeldaStr(fil, col: integer): string;
    function NroColToStrCol(nroCol: cardinal): string;
end;

var
  tmp_rundir: string;



function getDir_Tmp: string;
function getDir_Bin: string;
procedure subirDirectorio(var path: string);

  // forma el string de formato numérico
function xf_formatoStr(ndecimales: integer): shortstring;

// Crea el versor cos( 2pi * N * k / NPuntos )
function create_cos_n( n, NPuntos: integer ): TVectR;
// Crea el versor cos( 2pi * N * k / NPuntos )
function create_sin_n( n, NPuntos: integer ): TVectR;

implementation
// forma el string de formato numérico
function xf_formatoStr(ndecimales: integer): shortstring;
var
  res: string;
  k:   integer;
begin
  if ndecimales <= 0 then
    Result := '0'
  else
  begin
    res := '';
    for k := 1 to ndecimales do
      res  := res + '0';
    res    := '0' + SysUtils.decimalseparator + res;
    Result := res;
  end;
end;

function create_cos_n(n, NPuntos: integer): TVectR;
var
  res: TVectR;
  cs, w: NReal;
  k: integer;
begin
  res:= TVectR.Create_init( NPuntos );
  w:= 2 * pi / n;
  for k:= 1 to NPuntos do
  begin
    cs:=  cos( (k-1)*w );
    res.pon_e( k, cs );
  end;
  res.HacerUnitario;
  result:= res;
end;


function create_sin_n(n, NPuntos: integer): TVectR;
var
  res: TVectR;
  cs, w: NReal;
  k: integer;
begin
  res:= TVectR.Create_init( NPuntos );
  w:= 2 * pi / n;
  for k:= 1 to NPuntos do
  begin
    cs:=  sin( (k-1)*w );
    res.pon_e( k, cs );
  end;
  res.HacerUnitario;
  result:= res;
end;

{ TLibroOpenCalc }

constructor TLibroOpenCalc.Create(flgForWrite: boolean; archi: string;
  flgAutoGuardar: boolean);
begin
  inherited Create;
  if archi = '' then
  begin
    {$IFDEF LCL}
    if not flgForWrite then
      showmessage( 'ATENCIÓN!! para que la importación funcione debe asegurarse de haber GUARDADO los cambios en el archivo primero. Si no lo hizo, GUARDE ahora y después de aceptar a este mensaje.' );
    {$ENDIF}
    archi:= getDir_Tmp + 'opendocxlt.ods';
  end;
  self.archi:= archi;

  self.flgForWrite:= flgForWrite;
  self.flgAutoGuardar:= flgAutoGuardar;
  if flgForWrite then
    hoja := AddWorksheet('x' )
  else
  begin
    ReadFromFile( archi, sfOpenDocument);
    hoja:= GetFirstWorksheet;
  end;

  fil:= 0;
  col:= 0;
end;

procedure TLibroOpenCalc.Guardar;
begin
  WriteToFile( archi );
end;

procedure TLibroOpenCalc.go(NombreHoja: string; fila, columna: integer);
begin
  if Hoja.Name <> NombreHoja then
    ActivoHoja( NombreHoja );
  ir( fila, columna );
end;

procedure TLibroOpenCalc.Write(val: shortString);
begin
  Hoja.WriteText( fil, col, val );
  inc( col );

end;

procedure TLibroOpenCalc.Write(val: extended);
begin
  hoja.WriteNumber( fil, col, val, nfGeneral);
  inc( col );
end;

procedure TLibroOpenCalc.WriteDateTime(val: TDateTime; Formato: string);
begin
  hoja.WriteDateTime(fil, col, val, Formato );
  inc(col );
end;

procedure TLibroOpenCalc.Write(val: integer);
begin
  hoja.WriteNumber( fil, col, val, nfFixed, 0);
  inc( col );
end;

procedure TLibroOpenCalc.Write(val: boolean);
var
  i: integer;
begin
  if val then
    i:= 1
  else
    i:= 0;
  write( i );
end;

procedure TLibroOpenCalc.writeln(val: shortstring);
begin
  write( val );
  writeln;
end;

procedure TLibroOpenCalc.writeln( val: extended );
begin
  write( val );
  writeln;
end;

procedure TLibroOpenCalc.writeln(val: integer);
begin
  write( val );
  writeln;
end;

procedure TLibroOpenCalc.writeln;
begin
  inc( fil );
  col:= 0;
end;

procedure TLibroOpenCalc.Free;
begin
  if flgForWrite and flgAutoGuardar then  WriteToFile( archi );
  inherited Free;
end;

procedure TLibroOpenCalc.VisibleOn;
begin
  WriteToFile( archi );
{$IFDEF OPEN_ODS}
  opendocument( archi );
{$ENDIF}
end;

procedure TLibroOpenCalc.VisibleOff;
begin
  // nada
end;


procedure TLibroOpenCalc.SelRango(fil1, col1, fil2, col2: integer);
var
  aSelArr: TsCellRangeArray;
begin
  setlength( aSelArr, 1 );
  aSelArr[0].Col1:= col1-1;
  aSelArr[0].Row1:= Fil1-1;
  aSelArr[0].Col2:= col2-1;
  aSelArr[0].Row2:= Fil2-1;
  hoja.SetSelection( aSelArr );
end;

procedure TLibroOpenCalc.CambiarFormato(nuevoFormato: string);
begin

end;

procedure TLibroOpenCalc.ir(fila, columna: integer);
begin
  fil:= fila-1;
  col:= columna-1;
end;

procedure TLibroOpenCalc.autoFitCells;
begin

end;

procedure TLibroOpenCalc.agregoHoja(nombreHoja: string);
begin
  hoja:= AddWorksheet( NombreHoja );
end;

procedure TLibroOpenCalc.ActivoHoja(nombre: string);
begin
  hoja:= GetWorksheetByName( nombre );
  if hoja = nil then
    raise Exception.Create('Hoja no encontrada: "'+nombre+'"' );
end;

procedure TLibroOpenCalc.ActivoHoja_numero(numeroHoja: integer);
begin
  hoja:= GetWorksheetByIndex( numeroHoja-1 );
end;

procedure TLibroOpenCalc.WriteTiraDeDatos(titulo: string; valores: TVectR;
  var fila, columna: integer;esFecha: boolean=false;DatosNoValidos: TStringList = nil; valorInvalido:string = '');
var
  i:integer;
begin
  ir(fila,columna);
  write(titulo);
  fila:=fila+1;
  ir(fila,columna);
  for i:=1 to valores.n do
  begin

    if ((DatosNoValidos <> nil) and ((DatosNoValidos.IndexOf(IntToStr(trunc(valores.pv[i])))) <> -1)) then
       write(valorInvalido)
    else
    begin
      if esFecha then
        WriteDateTime(valores.pv[i])
      else
        write(valores.pv[i]);
    end;
    fila:=fila+1;
    ir(fila,columna);
  end;
  columna:=columna+1;
  fila:=fila - i - 1;
  if fila = 0 then
   fila := 1;
end;

function TLibroOpenCalc.ReadV_Str: shortstring;
begin
  result:= hoja.ReadAsText( fil, col );
  inc( col );
end;

function TLibroOpenCalc.ReadV_Float: double;
begin
  result:= hoja.ReadAsNumber(fil, col );
  inc( col );
end;

function TLibroOpenCalc.ReadV_Int: integer;
begin
   result:= round( hoja.ReadAsNumber(fil, col) );
   inc( col );
end;

function TLibroOpenCalc.ReadV_Bool: boolean;
var
  s: string;
begin
  s:= trim( hoja.ReadAsText( fil, col ) );
  if s = '' then
    result:= false
  else
    result:= s[1] in ['1', 'v', 'V', 'S', 's', 'T', 't' ] ;
  inc( col );
end;

function TLibroOpenCalc.ReadStr: string;
begin
  result:= hoja.ReadAsText( fil, col );
  inc( col );
end;

function TLibroOpenCalc.ReadStr(k, j: integer): string;
begin
  ir( k, j );
  result:= ReadStr;
end;

function TLibroOpenCalc.ReadInt(k, j: integer): integer;
begin
  ir( k, j );
  result:= ReadV_int;
end;

function TLibroOpenCalc.ReadFloat(k, j: integer): double;
begin
  ir( k, j );
  result:= ReadV_Float;
end;

procedure TLibroOpenCalc.readln;
begin
  inc( fil );
  col:= 0;
end;

procedure TLibroOpenCalc.readln(out s: string; blancos_consecutivos: integer);
var
  st:string;
  cont:integer;
begin
  s:='';
  cont:=0;

  while (cont < blancos_consecutivos) do
  begin
    st:=ReadStr;
    if st='' then
      inc( cont )
    else
      cont:=0;
    s:=s+#9+st;
  end;
  readln;
end;

function TLibroOpenCalc.Count_NReals(hoja: string; filaini, colini: integer;
  flg_Horizontal: boolean): integer;

var
  s: string;
  rescod: integer;
  r: NReal;
  cnt: integer;
  buscando: boolean;
begin
  ActivoHoja( hoja );
  ir(filaIni,colIni);
  cnt:= 0;
  buscando:= true;
  if flg_Horizontal then
  begin
    while buscando do
    begin
      s:= ReadStr;
      val( s, r, rescod );
      if rescod <> 0 then
        buscando:= false
      else
        inc( cnt );
    end;
  end
  else
  begin
    while buscando do
    begin
      s:= ReadStr;
      val( s, r, rescod );
      if rescod <> 0 then
        buscando:= false
      else
        inc( cnt );
      ir(fil+1, col-1);
    end;
  end;
  result:= cnt;
end;



//Retorna la letra de la columna nroCol
function TLibroOpenCalc.NroColToStrCol(nroCol: cardinal): string;
var
  res: string;
  digito, resto: integer;
  letraDigito: char;
begin
  resto:= nroCol-1;
  res:= '';
  repeat
    digito:= resto  mod 26;
    letraDigito:= Chr( Ord('A')+ digito );
    res:= letraDigito + res;
    resto:= resto div 26
  until resto = 0;
  result:= res;
end;



function TLibroOpenCalc.FilColToCeldaStr( fil, col: integer ): string;
begin
  result:= NroColToStrCol( col )+IntToStr( fil );
end;

procedure TLibroOpenCalc.CeldaStrToFilCol( var fil, col: integer; celda: string );
var
  k, N: integer;
  c: char;
  buscando: boolean;
  mmult: integer;
  pal: string;

begin
  col:= 0;
  buscando:= true;
  k:= 1;
  N:= length( celda );
  mmult:= ORD( 'Z' ) - ORD( 'A' ) +1;
  while buscando and ( k <= N ) do
  begin
    c:= upcase( celda[k] );
    if (c >= 'A') and (c<= 'Z') then
    begin
      col:= col* mmult + ORD( c ) - ORD( 'A' ) + 1;
      inc( k );
    end
    else
      buscando:= false;
  end;

  if buscando then
    raise Exception.Create('Falta definir el número de fila' );
  pal:= copy( celda, k, N-k + 1 );
  fil:= StrToInt( pal );
end;




function TLibroOpenCalc.CreateRead_VectR(hoja: string; filaIni,
  ColINi: integer; N: integer; flg_Horizontal: boolean): TVectR;
var
  res: TVectR;
  i: integer;
begin

  if N < 0 then
   N:= Count_NReals( hoja, filaini, colini, flg_Horizontal );

  ActivoHoja( hoja );
  ir(filaIni,colIni);
  res:= TVectR.Create_Init( N );
  if flg_Horizontal then
  begin
    for i:=1 to res.n do
      res.pv[i]:= ReadV_Float;
  end
  else
  begin
    for i:=1 to res.n do
    begin
      res.pv[i]:= ReadV_Float;
      ir(fil+1, col-1);
    end;
  end;
  result:= res;
end;

function TLibroOpenCalc.CreateRead_VectR(hoja: string; rango_str: String
  ): TVectR;
var
  celda1, celda2: string;
  N: integer;
  fil1, col1, fil2, col2: integer;
  flg_Horizontal: boolean;

begin
  RangoToCeldas( celda1, celda2, rango_str );
  CeldaStrToFilCol( fil1, col1, celda1 );
  CeldaStrToFilCol( fil2, col2, celda2 );
  if fil1 = fil2 then
  begin
    flg_Horizontal:= true;
    N:= Col2 - Col1 + 1;
  end
  else
  begin
    flg_Horizontal:= false;
    N:= Fil2 - Fil1 + 1;
  end;
  result:= CreateRead_VectR( hoja, fil1, col1, N, flg_Horizontal );
end;

procedure TLibroOpenCalc.Write_VectR( valores: TVectR; hoja: string; filaIni, ColIni: integer;
  flg_Horizontal: boolean);
var
  i:integer;
begin
  ActivoHoja( hoja );
  ir(filaIni,colIni);
  if flg_Horizontal then
  begin
    for i:=1 to valores.n do
      write(valores.pv[i]);
  end
  else
  begin
    for i:=1 to valores.n do
    begin
      write(valores.pv[i]);
      ir(fil+1, col-1);
    end;
  end;
end;

procedure TLibroOpenCalc.Write_VectR(valores: TVectR; hoja: string;
  celda_str: String; flg_Horizontal: boolean);
var
  fil1, col1: integer;
begin
  CeldaStrToFilCol( fil1, col1, celda_str);
  Write_VectR( valores, hoja, fil1, col1, flg_Horizontal );
end;


function TLibroOpenCalc.CreateRead_MatR(hoja: string; filaIni,
  ColINi: integer; NFilas, NColumnas: integer): TMatR;

var
  iFila: integer;
  res: TMatR;
begin
  if NFilas < 0 then
    NFilas:= Count_NReals( hoja, filaIni, ColIni, false )
  else
    NFilas:= NFilas;

  if NColumnas < 0 then
    NColumnas:= Count_NReals( hoja, FilaIni, ColIni, true )
  else
    NColumnas:= NColumnas;

  res:= TMatR.Create_Init_pm( NFilas, NColumnas );
  for iFila:= 1 to NFilas do
    res.pm[iFila]:= CreateRead_VectR( hoja, FilaIni+ (iFila-1), ColIni, NColumnas, true );
   result:= res;
end;

function TLibroOpenCalc.CreateRead_MatR(hoja: string; rango_str: String
  ): TMatR;
var
  celda1, celda2: string;
  filIni, ColIni, NFilas, NColumnas: integer;

begin
  RangoToCeldas( celda1, celda2, rango_str );
  CeldaStrToFilCol( filIni, ColIni, celda1 );
  CeldaStrToFilCol( NFilas, NColumnas, celda2 );
  NFilas:= NFilas - filIni +1;
  NColumnas:= NColumnas - ColIni + 1;
  result:= CreateRead_MatR( hoja, filIni, ColINi, NFilas, NColumnas );
end;

procedure TLibroOpenCalc.Write_MatR( m: TMatR; hoja: string; filaIni, ColIni: integer);
var
  iFila:integer;
begin
  for iFila:= 1 to m.nf do
    Write_VectR( m.fila( iFila ), hoja, filaIni+(ifila-1), ColIni, true );
end;

procedure TLibroOpenCalc.Write_MatR(m: TMatR; hoja: string; celda_str: string);
var
  fil1, col1: integer;
begin
  CeldaStrToFilCol( fil1, col1, celda_str );
  Write_MatR( m, hoja, Fil1, Col1 );
end;

procedure TLibroOpenCalc.RangoToCeldas(var celda1, celda2: string; rango: string
  );
var
  i: integer;
begin
  i:= pos( ':', rango );
  celda1:= copy(rango, 1, i-1 );
  celda2:= copy(rango, i+1, length( rango ) - i );
end;

function getDir_Tmp: string;
var
  res: string;
begin
  if tmp_rundir = '' then
  begin
    res := getDir_Bin;
    subirDirectorio(res);
    res := res + 'tmp' + DirectorySeparator;
  end
  else
  if tmp_rundir[length(tmp_rundir)] = DirectorySeparator then
    res := tmp_rundir
  else
    res := tmp_rundir + DirectorySeparator;

  Result := res;
end;


function getDir_Bin: string;
begin
  Result := ExtractFileDir(ParamStr(0)) + DirectorySeparator;
end;



procedure subirDirectorio(var path: string);
var
  i, N: integer;
  buscando: boolean;
begin
  N := length(path);
  if N < 1 then
  begin
    path := DirectorySeparator; // cubre el caso path=''  y path='x'
    exit;
  end;

  buscando := True;
  i := N - 1; // me salteo el último caracter pues si es una barra quiero ignorarla

  while buscando and (i > 0) do
    if path[i] = DirectorySeparator then
      buscando := False
    else
      Dec(i);
  if buscando then
    path := DirectorySeparator
  else
    Delete(path, i + 1, N - i);
end;




end.

