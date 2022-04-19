unit ugigavects;

{$mode delphi}

interface

uses
  Classes, SysUtils;

const
  C_VERSION_GIGAVECT = 1;

type
  // solo para typecast
  TLAOfDouble = packed array[0..1024*1024*200] of Double;
  PLAOfDouble = ^TLAOfDouble;

  TDAOfDouble = array of double;

  (* una página debe verse como una ventana en el vector.
  Para acceder a un vector hay que activar la página *)
  TPaginaVector = class
    N: integer;
    pv: array of double;
    cnt_modificaciones: integer;

    f: THandle;
    kPag, data_offset: integer;


    constructor Create( f: THandle; data_offset, MaxN: integer );
    procedure Free;

    procedure LoadFromFile( kPag, N: integer );
    procedure WriteToFile;
  end;


  TDAOfdouble_Paginado = class
    ventanas: array of TPaginaVector;
    f: THandle;
    N: integer;
    NVentanas: integer;
    MaxDimVentana: integer;
    data_offset: integer;
    version: integer;

    constructor CreateInit( archi: string; N, NVentanas, MaxDimVentana: integer );
    constructor CreateOpen( archi: string );
    procedure Free;
    function kPagOfk( k: integer ): integer;
    function VentanaOfkPag( kPag: integer ): TPaginaVector;
    procedure WriteToFile;

    procedure CreateEncabezado; virtual;
    procedure LoadEncabezado; virtual;

    function get_ek( k: integer ): double;
    procedure set_ek( k: integer; v: double );

    property valores[k: integer ]: double
      read get_ek write set_ek; default;


 end;


  { TMatOfdouble_paginado }

  TMatOfdouble_paginado = class( TDAOfdouble_Paginado )
    nFilas, nColumnas: integer;
    constructor CreateInit( archi: string; nFilas, nColumnas, nVentanas, nFilasPorPagina: integer );
    constructor CreateOpen( archi: string );
    function get_ekj( k, j: integer ): double;
    procedure set_ekj( k, j: integer; v: double );

    property valores[k, j: integer]: double
      read get_ekj write set_ekj; default;

    function ptr_kj( k, j: integer ): pdouble;
    function copyFila(kFila: integer): TDAOfDouble;
    function pFila( kFila: integer; flg_ParaModificar: boolean ): PLAOfDouble;

    procedure CreateEncabezado; override;
    procedure LoadEncabezado; override;

  end;


implementation

procedure ExpandFile( f: THandle; aVal: double; N: integer );
var
  k: integer;
begin
  for k:= 1 to N do
    filewrite( f, aVal, SizeOf( aVal ) );
end;


constructor TPaginaVector.Create( f: THandle; data_offset, MaxN: integer );
begin
  kPag:= -1;
  Self.N:= 0;
  self.f:= f;
  self.data_offset:= data_offset;
  cnt_modificaciones:= 0;
  setlength( pv, MaxN * SizeOf( double ) );
end;

procedure TPaginaVector.Free;
begin
  setlength( pv, 0 );
end;

procedure TPaginaVector.LoadFromFile( kPag, N: integer );
var
  k: integer;
  res: integer;
  pos_to_go: integer;
begin
  self.kPag:= kPag;
  self.N:= N;
  pos_to_go:= data_offset+ kPag * SizeOf(double ) * length( pv );
  if FileSeek( f, pos_to_go, fsFromBeginning ) = pos_to_go then
  begin
    res:= fileRead( f, pv[0], N * SizeOF( double ));
    if res < 0 then raise Exception.Create( 'TPaginaVector.LoadFromFile' );
    res:= res div SizeOf(double);
    if res < N then
    for k:= res to N-1 do
         pv[k]:= 0;
  end
  else
    for k:= 0 to N-1 do
       pv[k]:= 0;
end;


procedure TPaginaVector.WriteToFile;
var
  fPos, diff: integer;
begin
  if cnt_modificaciones > 0 then
  begin
    fPos:= data_offset + kPag * SizeOf(double ) * length( pv );

    if fPos <> FileSeek( f, fPos, fsFromBeginning ) then
    begin
      diff:= FileSeek( f, 0, fsFromEnd ) - fPos;
      if diff > 0 then
            ExpandFile( f, -111111, diff div( SizeOf( double ) ) );
    end;

    fileWrite( f, pv[0], N * SizeOF( double ));
    cnt_modificaciones:= 0;
  end;
end;


procedure TDAOfdouble_Paginado.LoadEncabezado;
begin
  fileRead( f, version, SiZeOf( version ) );
  fileRead( f, N, sizeOf( N ) );
  fileRead( f, NVentanas, sizeOf( NVentanas ) );
  fileRead( f, MaxDimVentana, sizeOf( MaxDimVentana ) );
end;

constructor TDAOfdouble_Paginado.CreateOpen( archi: string );
var
  k: integer;
begin
  inherited Create;
  f:= fileOpen( archi, fmOpenReadWrite);
  LoadEncabezado;
  data_offset:= fileseek( f, 0, fsFromCurrent );
  setlength( ventanas, NVentanas );
  for k:= 0 to high( ventanas ) do
    ventanas[k]:= TPaginaVector.Create(f, data_offset, MaxDimVentana );
end;


procedure TDAOfdouble_Paginado.CreateEncabezado;
begin
  fileWrite( f, version, SiZeOf( version ) );
  fileWrite( f, N, sizeOf( N ) );
  fileWrite( f, NVentanas, sizeOf( NVentanas ) );
  fileWrite( f, MaxDimVentana, sizeOf( MaxDimVentana ) );
end;


constructor TDAOfdouble_Paginado.CreateInit( archi: string; N, NVentanas, MaxDimVentana: integer );
var
  k, version: integer;
begin
  inherited Create;
  f:= fileCreate( archi, fmOpenWrite);
  self.N:= N;
  self.NVentanas:= NVentanas;
  self.MaxDimVentana:= MaxDimVentana;
  version:= C_VERSION_GIGAVECT;
  CreateEncabezado;
  data_offset:= fileseek( f, 0, fsFromCurrent );
  FileTruncate( f, data_offset );
  setlength( ventanas, NVentanas );
  for k:= 0 to high( ventanas ) do
    ventanas[k]:= TPaginaVector.Create(f, data_offset, MaxDimVentana );
end;


procedure TDAOfdouble_Paginado.WriteToFile;
var
  k: integer;
begin
  for k:= 0 to high( ventanas ) do
    ventanas[k].WriteToFile;
end;

procedure TDAOfdouble_Paginado.Free;
var
  k: integer;
begin
  WriteToFile;
  for k:= 0 to high( ventanas ) do
    ventanas[k].Free;
  setlength( ventanas, 0 );
  fileclose( f );
  inherited Free;
end;

function TDAOfdouble_Paginado.kPagOfk( k: integer ): integer;
begin
  result:= k div self.MaxDimVentana;
end;

// búsca si la página está en memoria, si la encuentra retorna
// el índice en
function TDAOfdouble_Paginado.VentanaOfkPag( kPag: integer ): TPaginaVector;
var
  k: integer;
  res: TPaginaVector;
begin
  res:= nil;
  for k:= 0 to high( Ventanas ) do
  begin
    if Ventanas[k].kPag = kPag then
    begin
      res:= ventanas[k];
      break;
    end;
  end;
  if res = nil then
  begin
    res:= ventanas[ high( ventanas ) ];
    for k:= high( ventanas ) downto 1 do
      ventanas[k]:= ventanas[k-1];
    ventanas[0]:= res;
    res.WriteToFile;
    res.LoadFromFile( kPag, MaxDimVentana );
  end;
  result:= res;
end;




function TDAOfdouble_Paginado.get_ek( k: integer ): double;
var
  kPag, jPos: integer;
  vp: TPaginaVector;
begin
  kPag:= kPagOfk( k );
  jPos:= k mod self.MaxDimVentana;
  vp:= VentanaOfkPag( kPag );
  result:= vp.pv[jPos ];
end;

procedure TDAOfdouble_Paginado.set_ek( k: integer; v: double );
var
  kPag, jPos: integer;
  vp: TPaginaVector;
begin
  kPag:= kPagOfk( k );
  jPos:= k mod self.MaxDimVentana;
  vp:= VentanaOfkPag( kPag );
  inc(vp.cnt_modificaciones);
  vp.pv[jPos]:= v;
end;


procedure TMatOfdouble_paginado.CreateEncabezado;
begin
  inherited CreateEncabezado;
  filewrite( f, nFilas, sizeOf(nfilas ) );
  filewrite( f, nColumnas, sizeOf (NColumnas ));
end;


constructor TMatOfdouble_paginado.CreateInit( archi: string; nFilas, nColumnas, NVentanas, nFilasPorPagina: integer );
var
  N: integer;
begin
  self.nFilas:= nFilas;
  self.nCOlumnas:= nColumnas;
  N:= nFilas * nColumnas;
  inherited CreateInit( archi, N, nVentanas, nColumnas * nFilasPorPagina );
end;

procedure TMatOfdouble_paginado.LoadEncabezado;
begin
  inherited LoadEncabezado;
  fileread( f, nFilas, sizeOf(nfilas ) );
  fileread( f, nColumnas, sizeOf (NColumnas ));
end;

constructor TMatOfdouble_paginado.CreateOpen( archi: string );
begin
  inherited CreateOpen( archi );
end;


function TMatOfdouble_paginado.get_ekj( k, j: integer ): double;
begin
  result:= get_ek( k* nColumnas + j );
end;

procedure TMatOfdouble_paginado.set_ekj( k, j: integer; v: double );
begin
  set_ek( k * nColumnas + j, v );
end;


function TMatOfdouble_paginado.ptr_kj( k, j: integer ): pdouble;
var
  kPag, jPos: integer;
  vp: TPaginaVector;
  kLin: integer;
begin
  kLin:= k * nColumnas + j;
  kPag:= kPagOfk( kLin  );
  jPos:= kLin mod self.MaxDimVentana;
  vp:= VentanaOfkPag( kPag );
  result:= @vp.pv[jPos ];
end;

function TMatOfdouble_paginado.copyFila( kFila: integer ): TDAOfDouble;
var
  res: TDAOfDouble;
  kPag, jPos, k: integer;
  vp: TPaginaVector;
  kLin: integer;
begin
  setlength( res, nColumnas );
  kLin:= kFila * nColumnas;
  kPag:= kPagOfk( kLin );
  jPos:= kLin mod self.MaxDimVentana;
  vp:= VentanaOfkPag( kPag );
  for k:= 0 to nColumnas - 1 do
    res[k]:= vp.pv[jPos + k];
  result:= res;
end;

function TMatOfdouble_paginado.pFila(kFila: integer; flg_ParaModificar: boolean
  ): PLAOfDouble;
var
  kPag, jPos, k: integer;
  vp: TPaginaVector;
  kLin: integer;
begin
  kLin:= kFila * nColumnas;
  kPag:= kPagOfk( kLin );
  jPos:= kLin mod self.MaxDimVentana;
  vp:= VentanaOfkPag( kPag );
  if flg_ParaModificar then
    inc( vp.cnt_modificaciones );
  result:= @vp.pv[jPos];
end;


end.
