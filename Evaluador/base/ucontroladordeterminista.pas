unit ucontroladordeterminista;{+doc

!!!EN DESARROLLO!!!

+NOMBRE: ucontroldeterminista
+CREACION: 2013-08-18
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Soporte de política de operación de sistema dinámico determinístico
+PROYECTO: SimSEE

+REVISION:
+AUTOR:
+DESCRIPCION:
  Dado un sistema dinámico x_k+1 = f( x_k, u_k, k )
se trata de crear el soporte para la definición de una Politica de Operación
en formato compatible con la descripción de la función CF(X,k) de los sistemas
dinámicos estocásticos.
  Por determinístico se entiende que la serie u_k es conocida y por tanto,
hay una trayectoria x_k que será la del camino óptimo.
  Suponemos que el OPERADOR es capaz de usar la informaicón de las derivadas
de dCF/dX para resolver la transición de cada paso durante la simulación.


-doc}

interface

uses
  Classes, SysUtils, xMatDefs;

type
  TGradInfo = class
    CF: NReal;
    Xr: TDAOfNReal;
    Xd: TDAofNInt;
    Grad_Xr, Grad_Xd: TDAOfNReal;
    constructor Create( nr, nd: integer );
    procedure Free;
    procedure Clear;

    // copia valores
    procedure igual( const a: TGradInfo );
    constructor Create_LoadFromFile(var f: file);
    procedure StoreInFile(var f: file);
  end;

  TDAOfGradInfo = array of TGradInfo;

  TControladorDeterministico = class
    GradInfos: TDAOfGradInfo;
    constructor Create(nr, nd, nPasosT: integer );
    function clone: TControladorDeterministico;
    function create_vect_u: TDAOfNReal;
    procedure set_vect_u( const u: TDAOfNReal );
    procedure clear;
    procedure Free;
    constructor Create_LoadFromFile(var f: file);
    constructor Create_LoadFromArchi( archi: string );
    procedure StoreInFile(var f: file);
    function nPasosT: integer;
    function nVarsX: integer;
  end;

implementation

constructor TGradInfo.Create( nr, nd: integer );
begin
  inherited Create;
  setlength( XR, nr  );
  setlength( Xd, nd );
  setlength( Grad_Xr, nr );
  setlength( Grad_Xd, nd );
end;

procedure TGradInfo.Free;
begin
  setlength( XR, 0  );
  setlength( Xd, 0 );
  setlength( Grad_Xr, 0 );
  setlength( Grad_Xd, 0 );
  inherited Free;
end;


procedure TGradInfo.Clear;
begin
  CF:= 0;
  vclear( XR );
  vclear( Xd );
  vclear( Grad_Xr );
  vclear( Grad_Xd );
end;

procedure TGradInfo.igual( const a: TGradInfo );
begin
  CF:= a.CF;
  Xr:= a.Xr;
  Xd:= a.Xd;
  Grad_Xr:= a.Grad_Xr;
  Grad_Xd:= a.Grad_Xd;
end;

constructor TGradInfo.Create_LoadFromFile(var f: file);
begin
  inherited Create;
  blockread(f, CF, sizeOf(CF));
  LoadFromFile_DAOfNReal( f, Xr );
  LoadFromFile_DAOfNInt( f, Xd );
  LoadFromFile_DAOfNReal( f, Grad_Xr );
  LoadFromFile_DAOfNReal( f, Grad_Xd );
end;

procedure TGradInfo.StoreInFile(var f: file);
begin
  BlockWrite(f, CF, sizeof(CF));
  StoreInFile_DAOfNReal(f, Xr);
  StoreInFile_DAOfNInt(f, Xd);
  StoreInFile_DAOfNReal(f, Grad_Xr);
  StoreInFile_DAOfNReal(f, Grad_Xd);
end;

constructor TControladorDeterministico.Create(nr, nd, nPasosT: integer );
var
  kPasoT: integer;
begin
  inherited Create;
  setlength( GradInfos, nPasosT );
  for kPasoT:= 0 to high( GradInfos ) do
      GradInfos[kPasoT]:= TGradInfo.Create( nr, nd );
end;

function TControladorDeterministico.clone: TControladorDeterministico;
var
  res: TControladorDeterministico;
  kPasoT: integer;

begin
  res:= TControladorDeterministico.Create( length( GradInfos[0].Xr), length( GradInfos[0].Xd) , length( GradInfos ) );
  for kPasoT:= 0 to high( GradInfos ) do
      res.GradInfos[kPasoT].igual( GradInfos[kPasoT] );
  result:= res;
end;


function TControladorDeterministico.create_vect_u: TDAOfNReal;
var
  res: TDAOfNReal;
  kPasoT: integer;
  N: integer;
  kx, j: integer;
begin
  N:= ( length( GradInfos[0].Xr ) + length( GradInfos[0].Xd)  )* length( GradInfos );
  setlength( res, N-1 );
  j:= 0;

  // la Posición kPasoT= 0 no se usa
  for kPasoT:= 1 to high( GradInfos ) do
  begin
    for kx:= 0 to high( GradInfos[0].Xr ) do
    begin
      res[j]:= GradInfos[kPasoT].Grad_Xr[kx];
      inc( j );
    end;
    for kx:= 0 to high( GradInfos[0].Xd ) do
    begin
      res[j]:= GradInfos[kPasoT].Grad_Xd[kx];
      inc( j );
    end;
  end;
  result:= res;
end;

procedure TControladorDeterministico.set_vect_u( const u: TDAOfNReal );
var
  kPasoT: integer;
  N: integer;
  kx, j: integer;
begin
  j:= 0;
  for kPasoT:= 1 to high( GradInfos ) do
  begin
    for kx:= 0 to high( GradInfos[0].Xr ) do
    begin
      GradInfos[kPasoT].Grad_Xr[kx]:= u[j];
      inc( j );
    end;
    for kx:= 0 to high( GradInfos[0].Xd ) do
    begin
      GradInfos[kPasoT].Grad_Xd[kx]:= u[j];
      inc( j );
    end;
  end;
end;



constructor TControladorDeterministico.Create_LoadFromFile(var f: file);
var
  n, k: integer;
begin
  inherited create;
  blockread( f, n, sizeof( n ) );
  setlength( GradInfos, n );
  for k:= 0 to high( GradInfos ) do
      GradInfos[k]:= TGradInfo.Create_LoadFromFile( f );
end;


constructor TControladorDeterministico.Create_LoadFromArchi( archi: string );
var
  f: file;
begin
  assignfile( f, archi );
  reset( f );
  Create_LoadFromFile( f );
  closefile( f );
end;


function TControladorDeterministico.nPasosT: integer;
begin
  result:= length( GradInfos );
end;

function TControladorDeterministico.nVarsX: integer;
begin
  if nPasosT > 0 then
    result:= length( GradInfos[0].Grad_Xd ) + length( GradInfos[0].Grad_Xr )
  else
    result:= 0;
end;

procedure TControladorDeterministico.StoreInFile(var f: file);
var
   n, k: integer;
begin
  n:= length( GradInfos );
  blockwrite( f, n, sizeof( n ) );
  for k:= 0 to high( GradInfos ) do
      GradInfos[k].StoreInFile( f );
end;

procedure TControladorDeterministico.clear;
var
  kPasoT: integer;

begin
  for kPasoT:= 0 to high( GradInfos ) do
      GradInfos[kPasoT].clear;
end;


procedure TControladorDeterministico.Free;
var
  kPasoT: integer;
begin
  for kPasoT:= 0 to high( GradInfos ) do
      GradInfos[kPasoT].Free;
  setlength( GradInfos, 0 );
  inherited Free;
end;



end.
