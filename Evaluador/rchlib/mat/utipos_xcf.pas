unit utipos_xcf;
{ utipos_xcf   rch@20170221
Esta unidad define las clases necesarias para soporte de información del tipo
ramilletes de crónicas de evaluación de una función CF(X, k) con k el índice del
tipempo.


}

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, matreal, usigmoide;

 type
  { TRecXCF
  Información de un punto
  }
  TRecXCF = class
    X: TVectR;
    CF: NReal;
    constructor Create( dimX: integer );
    constructor Create_LoadFromFile(var f: file);
    procedure StoreInFile( var f: file );
    procedure Free;
    function Clonar: TRecXCF;
  end;


  TDAOfRecXCF = array of TRecXCF;

  { TCronicaXCF
  Información de una crónica de puntos
  }

  TCronicaXCF = class
    semilla: integer;
    XCF: TDAOfRecXCF;
    constructor Create( dimX, nPasosT, semilla: integer );
    constructor Create_LoadFromFile(var f: file);
    procedure StoreInFile( var f: file );
    procedure Free;
  end;

  { TRamilleteCronicasXCF

  Información de un conjunto de cróncias}

  TRamilleteCronicasXCF = class( TList )
    kiter: integer; // 1 ... número de iteración.
    constructor Create( kiter: integer );
    constructor Create_LoadFromFile(var f: file);
    procedure StoreInFile( var f: file );
    procedure Free;
  end;

  { TRamilletes
  Lista de ramilletes
  }

  TRamilletes = class( TList )
    constructor Create;
    constructor Create_LoadFromFile(var f: file);
    procedure StoreInFile( var f: file );
    procedure Free;
  end;


    // busca el costo mínimo y dc=(c_max - c_min) y escala todos los costos
    // c_i =  ( (c_i-c_min)/dc -0.5) * alfa + 0.5
    procedure Normalizar_conjuntoXCF( var c_min, dc: NReal; var conj_XCF: TDAOfRecXCF; alfa: NReal );

    // busca parámetros de neuronas de normalización de las entradas para que
    // las mismas varíen entre -0.5 y 0.5 para que puedean ser usado como los páremtos
    // de una neurona y la señal quede centrada.
    // Tranforma los datos de forma que la serie es la de la salida de la neurona
    // cuyos parámetros se calculan.
    procedure Escalas_Entrada_j_conjuntoXCF(
       var ro_x, bias_x: NReal; j: integer;
       var conj_XCF: TDAOfRecXCF );


    // "mejor_neurona" retorna el vector de pesos de la neurona que mejor
    // aproxima el conjunto de puntos normalizado.
    // En el conjunto de puntos se retornan los residuos de la aproximación
    // como para ser usados en otra llamada al mismo método para calcular así
    // la siguiente "mejor_neurona"

    // El vector alfa se instancia dentro del procedimiento.
    // La neurona se calcula para aproximar CF_i por y_i donde:
    // y_i = sigmoide( alfa.escalar( X_i ) + xo )
    // El resultado de la función es la varianza de lo no explicado
    // calculada como: prom((CF_i - y_i)^2)

    function MejorNeurona(
      var alfa: TVectR; var x0: NReal;
      var c_min, dc: NReal;
      var conj_XCF: TDAOfRecXCF; var pesos: TVectR ): NReal;



function clonar( const data: TDAOfRecXCF ):  TDAOfRecXCF;
procedure free_data( var data: TDAOfRecXCF );

// Crea el conjunto de test del tipo CF(x) = exp(- (sum_k( k * x_k ) ) )
// dimX es la dimensión de X y nPuntos es la cantidad de muestras a generar
// tomando valores al azar de los x_k en el rango [0,1)
function Crear_XCF_Test01( dimX, nPuntos: integer; semilla: cardinal ): TDAOfRecXCF;


implementation


procedure Normalizar_conjuntoXCF(var c_min, dc: NReal;
  var conj_XCF: TDAOfRecXCF; alfa: NReal);
var
  k: integer;
  aRec: TRecXCF;
  cmin, cmax, c: NReal;
begin
  aRec:= conj_XCF[0];
  cmin:= aRec.CF;
  cmax:= cmin;
  for k:= 1 to high( conj_XCF ) do
  begin
    c:= conj_XCF[k].Cf;
    if c < cmin then
      cmin:= c
    else if c > cmax then
      cmax:= c;
  end;
  c_min:= cmin;
  dc:= (cmax - cmin);
  if EsCero( dc ) then
    for k:= 0 to high( conj_XCF ) do
    begin
      aRec:= conj_XCF[k];
      aRec.CF:= aRec.CF -cmin;
    end
  else
    for k:= 0 to high( conj_XCF ) do
    begin
      aRec:= conj_XCF[k];
      aRec.Cf:= ((aRec.CF - cmin )/dc - 0.5 ) * alfa + 0.5;
    end;
end;

procedure Escalas_Entrada_j_conjuntoXCF(
  var ro_x, bias_x: NReal; j: integer;
  var conj_XCF: TDAOfRecXCF);

var
  k: integer;
  aRec: TRecXCF;
  xmin, xmax, x, y, dx: NReal;

begin
   aRec:= conj_XCF[0];
   xmin:= aRec.X.e(j);
   xmax:= xmin;
   for k:= 1 to high( conj_XCF ) do
   begin
     x:= conj_XCF[k].X.e(j);
     if x < xmin then
       xmin:= x
     else if x > xmax then
       xmax:= x;
   end;

   dx:= ( xmax - xmin);
   if abs( dx ) > 1e-10 then
   begin
     ro_x:= 1/dx;
     bias_x:= 0.5 - xmax/dx ;
   end
   else
   begin
     ro_x:= 1;
     bias_x:= -xmax;
   end;

   for k:= 0 to high( conj_XCF ) do
   begin
     x:= conj_XCF[k].X.e(j);
     y:= sigmoide( x * ro_x + bias_x );
     conj_XCF[k].X.pon_e(j, y );
   end;
end;


function MejorNeurona(
  var alfa: TVectR; var x0: NReal; var c_min, dc: NReal;
  var conj_XCF: TDAOfRecXCF; var pesos: TVectR ): NReal;
var
  N: integer;
  res: NREal;
  MA, MB: TMatR;
  k, j, h: integer;
  z, ax: NReal;
  X: TVectR;
  NPuntos: integer;
  res_det: NReal;
  res_exp10: integer;
  res_invertible: boolean;
  cf: NReal;
  z_x: NReal;
  peso: NReal;
  cf_aprox: NReal;
  dev_sigmoide: NReal;

begin
//  Normalizar_conjuntoXCF( c_min, dc, conj_XCF );
  res:= 0;
  N:= conj_XCF[0].X.n;
  alfa:= TVectR.Create_Init( N );
  NPuntos:= length( conj_XCF );

  if EsCero( dc ) then
  begin
    alfa.Ceros;
    x0:= inv_sigmoide( c_min );
    for k:= 0 to NPuntos-1 do
      conj_XCF[k].CF:= 0;
  end
  else
  begin

   // Armado de problema de mínimos cuadrados
   // z_i = alfa.escalar( X_i ) - xo
   MA:= TMatR.Create_Init( N+1, N+1 );
   MB:= TMatR.Create_init( N+1, 1 );
   for k:= 0 to NPuntos-1 do
   begin
      X:= conj_XCF[k].X;
      cf:= conj_XCF[k].CF;
      dev_sigmoide:= cf * ( 1-cf );
      peso:= dev_sigmoide* pesos.e( k+1 );
      if dev_sigmoide > 25.0E-08 then
      begin
        z:= inv_sigmoide( cf );
        for h:= 1 to N do
        begin
          ax:= X.pv[h]*peso;
          for j:= h to N do
            MA.acum_e( h, j, ax * X.pv[j] );
          MA.acum_e(h, N+1, ax );
          MB.acum_e(h, 1, ax * z );
        end;
        h:= N+1;
        ax:= peso;
        for j:= h to N do
          MA.acum_e( h, j, ax * X.pv[j] );
        MA.acum_e(h, N+1, ax );
        MB.acum_e(h, 1, ax * z );
      end;
   end;

   // Completo el triángulo inferior de MA
   for h:= 1 to N+1 do
     for j:= h+1 to N+1 do
       MA.pon_e( j, h , MA.e( h, j ));

   res_det:= MA.Escaler( MB, res_invertible, res_exp10);
   if not res_invertible then
     raise Exception.Create('No Invertible MINCUAD en MejorNeurona ... hay que pensar ');

   for k:= 1 to Alfa.n do
     Alfa.pon_e( k, MB.e(k,1));
   x0:= MB.e( MB.nf, 1 );

   MB.Free;
   MA.Free;


   // Ahora calculamos los residuos
   for k:= 0 to NPuntos -1 do
   begin
    X:= conj_XCF[k].X;
    cf:=conj_XCF[k].CF;
    z:= inv_sigmoide( cf );
    z_x:= alfa.PEV( X ) - x0;
    conj_XCF[k].CF:= z - z_x; // guardamos el residuo para la próxima Neurona
    cf_aprox:= sigmoide( z_x );

    peso:= sqr(cf - cf_aprox );
    pesos.pon_e( k+1, peso );

    res:= res + peso; // Acumulamos el residuo de esta explicación para devolver
   end;
   res:= res / (NPuntos-1); //
  end;
  result:= res;
end;

function clonar(const data: TDAOfRecXCF): TDAOfRecXCF;
var
  res: TDAOfRecXCF;
  k: integer;
begin
  setlength( res, Length( data ) );
  for k:= 0 to high( res ) do
   res[k]:= data[k].Clonar;
  result:= res;
end;

procedure free_data(var data: TDAOfRecXCF);
var
  k: integer;
begin
  for k:= 0 to high( data ) do
   data[k].Free;
  setlength( data, 0 );
end;


// Crea el conjunto de test del tipo CF(x) = exp(- (sum_k( k * x_k ) ) )
// dimX es la dimensión de X y nPuntos es la cantidad de muestras a generar
// tomando valores al azar de los x_k en el rango [0,1)
function Crear_XCF_Test01( dimX, nPuntos: integer; semilla: cardinal ): TDAOfRecXCF;
var
  res: TDAofRecXCF;
  k: integer;
  punto: integer;
  aRec: TRecXCF;
  alfa, x: NReal;
begin
  RandSeed:= semilla;
  setlength( res, nPuntos );
  alfa:= 0;
  for punto := 0 to nPuntos - 1 do
  begin
   aRec:= TRecXCF.Create( dimX );
    for k:= 1 to dimX  do
    begin
      x:= random;
      alfa:= alfa + k * x;
      aRec.X.pon_e( k, x );
    end;
    aRec.CF:= exp( -alfa );
    res[punto]:= aRec;
  end;
  result:= res;
end;

{ TRamilletes }

constructor TRamilletes.Create;
begin
  inherited Create;
end;

constructor TRamilletes.Create_LoadFromFile(var f: file);
var
  n, k: integer;
  aRamillete: TRamilleteCronicasXCF;
begin
  blockread(f, n, sizeOf(n));
  for k:= 0 to n-1 do
  begin
    aRamillete:= TRamilleteCronicasXCF.Create_LoadFromFile( f );
    add( aRamillete );
  end;
end;

procedure TRamilletes.StoreInFile(var f: file);
var
  n, k: integer;
  aRamillete: TRamilleteCronicasXCF;
begin
  n:= count;
  blockwrite(f, n, sizeof(n) );
  for k:= 0 to n-1 do
  begin
    aRamillete:= items[k];
    aRamillete.StoreInFile( f );
  end;
end;

procedure TRamilletes.Free;
var
  k: integer;
  aRamillete: TRamilleteCronicasXCF;
begin
  for k:= 0 to count -1 do
  begin
    aRamillete:= items[k];
    aRamillete.Free;
  end;
  inherited Free;
end;

{ TRamilleteCronicasXCF }

constructor TRamilleteCronicasXCF.Create(kiter: integer);
begin
  inherited Create;
  self.kiter:= kiter;
end;

constructor TRamilleteCronicasXCF.Create_LoadFromFile(var f: file);
var
  n, k: integer;
  aCron: TCronicaXCF;
begin
  inherited Create;
  blockread( f, kiter, sizeof(kiter) );
  n:= count;
  blockread( f, n, sizeof(n) );
  for k:= 0 to n-1 do
  begin
    aCron:= TCronicaXCF.Create_LoadFromFile( f );
    add( aCron );
  end;
end;

procedure TRamilleteCronicasXCF.StoreInFile(var f: file);
var
  n, k: integer;
  aCron: TCronicaXCF;
begin
  blockwrite( f, kiter, sizeof(kiter) );
  n:= count;
  blockwrite( f, n, sizeof(n) );
  for k:= 0 to n-1 do
  begin
    aCron:= items[k];
    aCron.StoreInFile( f );
  end;
end;

procedure TRamilleteCronicasXCF.Free;
var
  k: integer;
  aCronicaXCF: TCronicaXCF;
begin
  for k:= 0 to count -1 do
  begin
    aCronicaXCF:= items[k];
    aCronicaXCF.Free;
  end;
  inherited Free;
end;



{ TCronicaXCF }

constructor TCronicaXCF.Create(dimX, nPasosT, semilla: integer);
var
  k: integer;
begin
  inherited create;
  self.semilla:= semilla;
  setlength( XCF, nPasosT );
  for k:= 0 to High( XCF ) do
   XCF[k]:= TRecXCF.Create( dimX );
end;

constructor TCronicaXCF.Create_LoadFromFile(var f: file);
var
  k: integer;
  nPasosT: integer;
begin
  inherited Create;
  blockread( f, semilla, sizeof(semilla) );
  blockread( f, nPasosT, sizeof(nPasosT) );
  setlength( XCF, nPasosT );
  for k:= 0 to High( XCF ) do
    XCF[k]:= TRecXCF.Create_LoadFromFile( f );
end;

procedure TCronicaXCF.StoreInFile(var f: file);
var
  n: integer;
  k: integer;
begin
  blockwrite( f, semilla, sizeof( semilla) );
  n:= length( XCF );
  blockwrite( f, n, sizeof( n ) );
  for k:= 0 to high( XCF ) do
    XCF[k].StoreInFile( f );
end;

procedure TCronicaXCF.Free;
var
  k: integer;
begin
  for k:= 0 to High( XCF ) do
   XCF[k].Free;
  setlength( XCF, 0 );
  inherited create;
end;


{ TRecXCF }

constructor TRecXCF.Create(dimX: integer);
begin
  inherited Create;
  X:= TVectR.Create_init( dimX );
end;

constructor TRecXCF.Create_LoadFromFile(var f: file);
begin
  inherited Create;
  X:= TVectR.CreateLoadFromBinaryFile( f );
  blockRead( f, CF, sizeof(CF));
end;

procedure TRecXCF.StoreInFile(var f: file);
begin
  X.StoreInBinaryFile(f);
  BLockWrite( f, CF, sizeof( CF ) );
end;

procedure TRecXCF.Free;
begin
  X.Free;
  inherited free;
end;

function TRecXCF.Clonar: TRecXCF;
var
  res: TRecXCF;
begin
  res:= TRecXCF.Create( X.n );
  res.X.Copy( X );
  res.CF:= CF;
  result:= res;
end;

end.

