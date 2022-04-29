{$DEFINE NO_USAR_RND_COMPILADOR}
{$MODE DELPHI}
unit fddp;

{+doc
+NOMBRE: fddp
+CREACION: 18.3.1992 ..
+AUTOR: Ruben Chaer.
+REVISION:
+AUTOR:
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Funciones de densidad de probabilidad.
+PROYECTO: rchlib
+DESCRIPCION:
  Implementaci¢n de un conjunto de funciones £tiles para estad¡sticas.
  2.9.2005 le agrego   Tf_ddp_VectDeMuestras = class( Tf_ddp )
  y paso a class (salve el código viego como old_fddp.pas.
-doc}
interface

uses
  SysUtils,
  xMatDefs,
  Math,
  math01,
  udisnormcan;

const
  gamma_EULER = 0.57721566490153286060651209008240243104215933593992;

type
  {$IFDEF NO_USAR_RND_COMPILADOR}
  {$IFDEF RAND3_REAL}// si la máquine tiene enteros de menos de 4 bytes
  T_glma_data = array [1..55] of real;
  {$ELSE}
  T_glma_data = array [1..55] of integer;
  {$ENDIF}
  {$ENDIF}


  TMadreUniforme = class; // la defino más adelante

  // Almacena el estado de la fuente aleatoria.
  // Como las fuentes son generadas a partir de una MADRE_UNIFORME
  // el estado es el de la madre uniforme.
  TEstadoMadreUniforme = record
    semilla_base: integer;
{$IFDEF NO_USAR_RND_COMPILADOR}
    glma: T_glma_data;
    glinext, glinextp: integer;
{$ELSE}
    semilla: integer;
{$ENDIF}
  end;
  PEstadoMadreUniforme = ^TEstadoMadreUniforme;


  { Tf_ddp }

  Tf_ddp = class
  private
    semilla_base: integer;
    // semilla Es solo para inicializar. Luego no representa el estado
    flg_BorrarMadreUnif: boolean;
  public
    madreUnif: TMadreUniforme;
    dtmax: NReal;
    area_t0, t0, area_t1, t1: NReal;
    area_u_t, u_t: NReal;
    g0: NReal;

    //Este constructor solo lo debe llamar TMadreUniforme o una
    //fuente que no precise de un generador de sorteos uniformes como
    //Tf_ddp_VectDeMuestras
    constructor Create(xt0, xarea_t0, xt1, xarea_t1: NReal; semilla: integer); overload;

    // Atención, madreUniforme <> nil implica que se usará la semilla global
    // se ignora el valor de la semilla.
    // si madreUniforme = nil implica esta fuente usa su propia semilla y por lo tanto
    // es independiente de las demas y se crea una madreUniforme con la semilla pasada
    constructor Create(xt0, xarea_t0, xt1, xarea_t1: NReal;
      madreUniforme: TMadreUniforme; semilla: integer); overload;

    procedure Free; virtual;
    function densidad(x: NReal): NReal; virtual;
    function distribucion(x: NReal): NReal; virtual;
    function area_t(t: NReal): NReal; virtual;
    function area_t_rapida(t: NReal): NReal; virtual;
    function t_area(area: NReal): NReal; virtual;
    function rnd: NReal; virtual;

    // reinicia el generador de números aleatorios.
    procedure Reiniciar(nueva_semilla_base: integer); virtual;
    function get_semilla_base: integer;
  end;


(*+doc TMadreUniforme
Esta fuente es especial. Las fuentes de este tipo son independientes en el uso
de las semillas.
Hay una instancia de este tipo global de la unidad que es la que usan las demás
fuentes cuando especifican semilla=0 al inicializarse.
-doc*)
  TMadreUniforme = class(Tf_ddp)
  public
    {$IFDEF NO_USAR_RND_COMPILADOR}
    glinext, glinextp: integer;
    glma: T_glma_data;
    {$ELSE}
    semilla: integer;
    {$ENDIF}
    constructor Create(semilla: integer);
    procedure Free; override;
    function densidad(x: NReal): NReal; override;
    function distribucion(x: NReal): NReal; override;
    function area_t(t: NReal): NReal; override;
    function area_t_rapida(t: NReal): NReal; override;
    function t_area(area: NReal): NReal; override;
    function rnd: NReal; override;

    //Retorna un entero en todo el rango posible [-MaxInt-1, MaxInt]
    function randomInt: integer;

    //Los extremos del rango son inclusive
    function randomIntRange(const minRango, maxRango: integer): integer;

    //fija la semilla aleatoria para la fuente, dos fuentes inicializadas con
    //la misma semilla generaran la misma secuencia de números, pero una fuente
    //inicializada con la misma semilla que otra puede no generar los mismos
    //valores pues su glinext y glinextp se inicializan en valores arbirtrarios
    //no necesariamente iguales a los de la fuente original
    procedure Reiniciar(semilla: integer); override;

    //Fija el estado de la fuente, si a una fuente se le fija el estado de otra
    //generaran la misma secuencia de numeros
    procedure setEstado(const estado: TEstadoMadreUniforme); overload;
    procedure setEstado(const otraFuente: TMadreUniforme); overload;
    procedure getEstado(var estado: TEstadoMadreUniforme);
  end;

  Pf_ddpMadreUniformeRand3 = ^TMadreUniforme;



(*+doc Fuente uniforme en el rango 0-1 puede
  Es para usar en los lugares dónde se quiera tener una uniforme en el que
  el manejo de las semillas pueda ser el global.
-doc*)
  Tf_ddpUniformeRand3 = class(Tf_ddp)
  public
    constructor Create(madreUniforme: TMadreUniforme; semilla: integer);
    function densidad(x: NReal): NReal; override;
    function distribucion(x: NReal): NReal; override;
    function area_t(t: NReal): NReal; override;
    function area_t_rapida(t: NReal): NReal; override;
    function t_area(area: NReal): NReal; override;
    function rnd: NReal; override;
  end;

  Tf_ddp_GaussianaNormal = class(Tf_ddp)
  public
    gliset: integer;
    glgset: NReal;
    constructor Create(madreUniforme: TMadreUniforme; semilla: integer);
    function densidad(x: NReal): NReal; override;
    function distribucion(x: NReal): NReal; override;
    function area_t(t: NReal): NReal; override;
    function area_t_rapida(t: NReal): NReal; override;
    function t_area(area: NReal): NReal; override;
    function rnd: NReal; override;
    procedure Reiniciar(semilla: integer); override;
  end;

  Tf_ddp_Student = class(Tf_ddp)
  public
    nu, y0: NReal;
    constructor Create(N: integer; madreUniforme: TMadreUniforme; semilla: integer);
    function densidad(x: NReal): NReal; override;
  end;

  Tf_ddp_ChiCuadrado = class(Tf_ddp)
  public
    nu, y0: NReal;
    constructor Create(N: integer; madreUniforme: TMadreUniforme; semilla: integer);
    function densidad(x: NReal): NReal; override;
  end;



//PA 28-01-2008
//Aproximación de la función Gamma (extensión de factorial para los complejos)
//El valor z debe ser > 0
//El error en esta aproximación esta acotado por
//|e| < 2 * 10^-10
//http://www.rskey.org/gamma.htm
function LanczosGammaAprox(z: NReal): NReal;




implementation


//PA 28-01-2008
//Aproximación de la función Gamma (extensión de factorial para los complejos)
//El valor z debe ser > 0
//El error en esta aproximación esta acotado por
//|e| < 2 * 10^-10
//http://www.rskey.org/gamma.htm
function LanczosGammaAprox(z: NReal): NReal;
const
  raizDeDosPi = 2.506628274631000502415765284811;
  ps: array [0..6] of NReal =
    (1.000000000190015, 76.18009172947146, -86.50532032941677,
    24.01409824083091, -1.231739572450155, 1.208650973866179E-3, -5.395239384953E-6);
var
  acum: NReal;
  n: integer;
begin
  //p0 + sum(n=1..6) (pn / z + n)
  acum := ps[0];
  for n := 1 to 6 do
    acum := acum + ps[n] / (z + n);
  Result := (raizDeDosPi / z) * acum * power((z + 5.5), z + 0.5) * exp(-(z + 5.5));
end;

// la fddpActiva es para apuntar el objeto cuando llamamos
// el método de Romberg o dicot para el cálculo de area_t o t_area
var
  fddpActiva: Tf_ddp;

function fd(x: NReal): NReal;
begin
  fd := fddpActiva.densidad(x);
end;

function g(t: NReal): NReal;
begin
  g := fddpActiva.area_t(t) - fddpActiva.g0;
end;

// Procedimientos generales de acceso a la madreUniforme
function random: NReal;
begin
  raise Exception.Create('Llamaron a fddp.random. Se debe crear una TMadreUniforme' +
    ' y utilizar el método rnd');
  //    result:= madreUniforme.rnd;
  Result := 0;
end;

procedure FijarSemilla(NuevaSemilla: integer);
begin
  raise Exception.Create('Llamaron a fddp.FijarSemilla. Se debe crear una TMadreUniforme'
    + ' y utilizar el método reiniciar');
  //  madreUniforme.Reiniciar(NuevaSemilla);
end;

function semillaAleatoria: integer;
begin
  raise Exception.Create(
    'Llamaron a fddp.semillaAleatoria. Se debe crear una TMadreUniforme' +
    ' y consultar el valor de semilla');
  Result := 0;
  //result:= -madreUniforme.semilla;
end;

procedure randomize;
begin
  raise Exception.Create('Llamaron a fddp.randomize. Se debe crear una TMadreUniforme' +
    ' y consultar el valor de semilla');
  //    system.randomize;
  //    madreUniforme.Reiniciar( RandSeed );
end;

{ m‚todos de las Tf_ddp }

constructor Tf_ddp.Create(xt0, xarea_t0, xt1, xarea_t1: NReal; semilla: integer);
begin
  inherited Create;
  t0 := xt0;
  area_t0 := xarea_t0;
  t1 := xt1;
  area_t1 := xarea_t1;
  area_u_t := area_t0;
  u_t := t0;
  self.semilla_base := semilla;
  madreUnif := nil;
  flg_BorrarMadreUnif := False;
end;

constructor Tf_ddp.Create(xt0, xarea_t0, xt1, xarea_t1: NReal;
  madreUniforme: TMadreUniforme; semilla: integer);
begin
  inherited Create;
  t0 := xt0;
  area_t0 := xarea_t0;
  t1 := xt1;
  area_t1 := xarea_t1;
  area_u_t := area_t0;
  u_t := t0;
  if madreUniforme <> nil then
  begin
    madreUnif := madreUniforme;
    flg_BorrarMadreUnif := False;
  end
  else
  begin
    madreUnif := TMadreUniforme.Create(semilla);
    flg_BorrarMadreUnif := True;
  end;
end;

procedure Tf_ddp.Free;
begin
  if flg_BorrarMadreUnif then
    madreUnif.Free;
  inherited Free;
end;

function Tf_ddp.distribucion(x: NReal): NReal;
begin
  distribucion := area_t_rapida(x);
end;

function Tf_ddp.densidad(x: NReal): NReal;
begin
  densidad := 0;
end;

function Tf_ddp.area_t(t: NReal): NReal;
var
  sum: NReal;
  res: boolean;
begin
  fddpActiva := Self;
  Romberg(
    fd,
    t0, t, AsumaCero,
    sum,
    res);

  Result := sum + area_t0;
end;

function Tf_ddp.area_t_rapida(t: NReal): NReal;
{
  Calcula la integral en a partir del £ltimo punto calculado
esto aumenta la velocidad cuando se calculan puntos sercanos. }
var
  sum: NReal;
  res: boolean;
  ts: NReal;
begin
  fddpActiva := Self;
  if t > u_t then
  begin
    ts := u_t + dtmax;
    while ts < t do
    begin
      Romberg(
        fd,
        u_t, ts, 1e-4,
        sum,
        res);
      area_u_t := sum + area_u_t;
      u_t := ts;
      ts := ts + dtmax;
    end;

    Romberg(
      fd,
      u_t, t, 1e-4,
      sum,
      res);
    area_u_t := sum + area_u_t;
    u_t := t;
    area_t_rapida := area_u_t;
  end
  else
  begin
    ts := u_t - dtmax;
    while ts > t do
    begin
      Romberg(
        fd,
        u_t, ts, 1e-4,
        sum,
        res);
      area_u_t := sum + area_u_t;
      u_t := ts;
      ts := ts - dtmax;
    end;

    Romberg(
      fd,
      u_t, t, 1e-4,
      sum,
      res);
    area_u_t := sum + area_u_t;
    u_t := t;
    area_t_rapida := area_u_t;
  end;
end;

procedure Tf_ddp.Reiniciar(nueva_semilla_base: integer);
begin
  if nueva_semilla_base > 0 then
    semilla_base := -nueva_semilla_base
  else
    semilla_base := nueva_semilla_base;
end;

function Tf_ddp.get_semilla_base: integer;
begin
  if semilla_base < 0 then
    Result := -semilla_base
  else
    Result := semilla_base;
end;



function Tf_ddp.t_area(area: NReal): NReal;
var
  t, gt: NReal;
  NoOfIts: word;
  converged: boolean;
begin
  if area <= area_t0 then
  begin
    Result := t0;
    exit;
  end;

  if area >= area_t1 then
  begin
    Result := t1;
    exit;
  end;

  fddpActiva := Self;
  g0 := area;

  Dicot(
    g,                    {funcion a anular}
    t0, t1, 1e-4,         {extremos y tolerancia}
    1000,                  {numero maximo de iteraciones}
    t, gt,                {raiz y f(raiz)}
    NoOfIts,              {numero de iteraciones realizadas}
    converged);            {validez del resultado}

  if not converged then
    raise Exception.Create(' Problema de convergencia , area: ' + FloatToStr(area));
  t_area := t;
end;

function Tf_ddp.rnd: NReal;
var
  u: NReal;
  tmps: integer;
begin
  u := self.madreUnif.rnd;
  Result := t_area(u);
end;


constructor Tf_ddp_GaussianaNormal.Create(madreUniforme: TMadreUniforme;
  semilla: integer);
begin
  inherited Create(-5, distribucion(-5), 5, distribucion(5), madreUniforme, semilla);
  gliset := 0;
  glgset := 0;
  dtmax := 1;
end;


function Tf_ddp_GaussianaNormal.densidad(x: NReal): NReal;
begin
  Result := fddp_NormalCanonica(x);
end;

function Tf_ddp_GaussianaNormal.distribucion(x: NReal): NReal;
begin
  Result := DistribucionNormalCanonica(x);
end;


function Tf_ddp_GaussianaNormal.area_t(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function Tf_ddp_GaussianaNormal.area_t_rapida(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function Tf_ddp_GaussianaNormal.t_area(area: NReal): NReal;
begin
  Result := Inv_DistribucionNormalCanonica(area);
end;

function Tf_ddp_GaussianaNormal.rnd: NReal;
begin
  Result := Inv_DistribucionNormalCanonica(madreUnif.rnd);
end;

(*** saco esto porque no se reiniciaba bien con la semilla
VAR
  fac,r,v1,v2: NReal;
BEGIN
  IF  (gliset = 0)  THEN
  BEGIN
    REPEAT
      v1 := 2.0*madreUnif.rnd-1.0;
      v2 := 2.0*madreUnif.rnd-1.0;
      r := sqr(v1)+sqr(v2);
    UNTIL (r < 1.0);
    fac := sqrt(-2.0*ln(r)/r);
    glgset := v1*fac;
    result := v2*fac;
    gliset := 1
  END
  ELSE
  BEGIN
    result := glgset;
    gliset := 0
  END
END;
*)

procedure Tf_ddp_GaussianaNormal.Reiniciar(semilla: integer);
begin
  gliset := 0;
  inherited Reiniciar(semilla);
end;

{ Metedos de f_student }

constructor Tf_ddp_Student.Create(N: integer; madreUniforme: TMadreUniforme;
  semilla: integer);
var
  s: NReal;
begin
  inherited Create(0, 0.5, 100, 1, madreUniforme, semilla);
  dtmax := 1;
  nu := N - 1;
  y0 := 1;
  s := area_t_rapida(100);
  u_t := 0;
  area_u_t := 0.5;
  y0 := 1 / ((s - 0.5) * 2);
end;

function pot(x, y: NReal): NReal;
begin
  if x < 1e-12 then
    pot := 0
  else
    pot := exp(y * ln(x));
end;

function Tf_ddp_Student.densidad(x: NReal): NReal;
begin
  densidad := Y0 / pot(1 + x * x / nu, (nu + 1) / 2);
end;

{ metodos de f_ChiCuadrado = class(Tf_ddp) }

constructor Tf_ddp_ChiCuadrado.Create(N: integer; madreUniforme: TMadreUniforme;
  semilla: integer);
var
  s: NReal;
begin
  inherited Create(0, 0, 100, 1, madreUniforme, semilla);
  dtmax := 1;
  nu := N - 1;
  y0 := 1;

  s := area_t_rapida(300);
  u_t := 0;
  area_u_t := 0;
  y0 := 1 / s;
end;

function Tf_ddp_ChiCuadrado.densidad(x: NReal): NReal;
begin
  densidad := Y0 * pot(x, (nu - 2) / 2) * exp(-x / 2);
end;




// Métodos de tf_dppMadreUniformeRand3
constructor TMadreUniforme.Create(semilla: integer);
{$IFDEF NO_USAR_RND_COMPILADOR}
var
  k: integer;
{$ENDIF}
begin
  inherited Create(0, 0, 1, 1, semilla);
  {$IFDEF NO_USAR_RND_COMPILADOR}
  glinext := 0;
  glinextp := 0;
  for k := 1 to 55 do
    glma[k] := 0;
  {$ENDIF}
  Reiniciar(semilla);
end;

procedure TMadreUniforme.Free;
begin
  inherited Free;
end;

function TMadreUniforme.densidad(x: NReal): NReal;
begin
  if x < 0 then
    Result := 0
  else if x >= 1 then
    Result := 0
  else
    Result := 1;
end;

function TMadreUniforme.distribucion(x: NReal): NReal;
begin
  if x < 0 then
    Result := 0
  else if x >= 1 then
    Result := 1
  else
    Result := x;
end;

function TMadreUniforme.area_t(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function TMadreUniforme.area_t_rapida(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function TMadreUniforme.t_area(area: NReal): NReal;
begin
  if area < 0 then
    Result := 0
  else if area >= 1 then
    Result := 1
  else
    Result := area;
end;

//La función da overflow si se reinicia la semilla aunque después
//funciona correctamente, probablemente alguna de las cuentas que hace al entrar
//por IF (semilla < 0) THEN ... debiera ser cíclica.
{$OverflowChecks Off}
function TMadreUniforme.rnd: NReal;
{$IFDEF NO_USAR_RND_COMPILADOR}

{$IFNDEF NO_OPTIM_UNIF_PRECALC}
const
  //iis[i] = (21 * i) mod 55
  iis: array [1..54] of integer = (21, 42, 8, 29, 50, 16, 37, 3, 24, 45, 11, 32,
    53, 19, 40, 6, 27, 48, 14, 35, 1, 22, 43, 9,
    30, 51, 17, 38, 4, 25, 46, 12, 33, 54, 20,
    41, 7, 28, 49, 15, 36, 2, 23, 44, 10, 31, 52,
    18, 39, 5, 26, 47, 13, 34);

  //iaux[i] = 1+((i+30) MOD 55)
  iaux: array [1..55] of integer = (32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
    43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53,
    54, 55, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
    23, 24, 25, 26, 27, 28, 29, 30, 31);

{$ENDIF}

{$IFDEF RAND3_REAL}// si la máquine tiene enteros de menos de 4 bytes
const
  mbig = 4.0e6;
  mseed = 1618033.0;
  mz = 0.0;
  fac = 2.5e-7; (* 1/mbig *)
var
  i, ii, k: integer;
  mj, mk: real;
{$ELSE}
const
  mbig = 1000000000;
  mseed = 161803398;
  mz = 0;
  fac = 1.0e-9;
var
  i, ii, k, mj, mk: integer;
{$ENDIF}
{$ENDIF}
begin

{$IFDEF NO_USAR_RND_COMPILADOR}
  if (semilla_base < 0) then
  begin
    mj := mseed + semilla_base;
{$IFDEF RAND3_REAL}// si la máquine tiene enteros de menos de 4 bytes
    (* The following IF block is mj := mj MOD mbig; for real variables. *)
    if mj >= 0.0 then
      mj := mj - mbig * trunc(mj / mbig)
    else
      mj := mbig - abs(mj) + mbig * trunc(abs(mj) / mbig);
{$ELSE}
    while mj < 0 do
      mj := mj + mbig;
    mj := mj mod mbig;
{$ENDIF}
    glma[55] := mj;
    mk := 1;
    for i := 1 to 54 do
    begin
{$IFDEF NO_OPTIM_UNIF_PRECALC}
      ii := 21 * i mod 55;
{$ELSE}
      ii := iis[i];
{$ENDIF}
      glma[ii] := mk;
      mk := mj - mk;
      if (mk < mz) then
        mk := mk + mbig;
      mj := glma[ii];
    end;

    for k := 1 to 4 do
    begin
      for i := 1 to 55 do
      begin
       {$IFDEF NO_OPTIM_UNIF_PRECALC}
        glma[i] := glma[i] - glma[1 + ((i + 30) mod 55)];
       {$ELSE}
        glma[i] := glma[i] - glma[iaux[i]];
       {$ENDIF}
        if (glma[i] < mz) then
          glma[i] := glma[i] + mbig;
      end;
    end;
    glinext := 0;
    glinextp := 31;
    semilla_base := -semilla_base;
  end;

  glinext := glinext + 1;
  if (glinext = 56) then
    glinext := 1;
  glinextp := glinextp + 1;
  if (glinextp = 56) then
    glinextp := 1;
  mj := glma[glinext] - glma[glinextp];

  if (mj < mz) then
    mj := mj + mbig;

  glma[glinext] := mj;
  Result := mj * fac;

{$ELSE}
  Result := system.random;
{$ENDIF}
end;

function TMadreUniforme.randomInt: integer;
const
  largoRango: int64 = 4294967295;
var
  randomCeroUno: NReal;
begin
  randomCeroUno := rnd;
  Result := (-MaxInt - 1) + trunc(randomCeroUno * largoRango + 0.5);
end;

function TMadreUniforme.randomIntRange(const minRango, maxRango: integer): integer;
var
  randomCeroUno: NReal;
  largoRango: int64;
begin
  randomCeroUno := rnd;
  (*
  largoRango := maxRango - minRango;
  Result := minRango + trunc(randomCeroUno * largoRango + 0.5);
  *)
  largoRango := maxRango - minRango + 1;
  Result := min(  minRango + trunc( randomCeroUno * largoRango), maxRango );

end;

procedure TMadreUniforme.Reiniciar(semilla: integer);
begin
{$IFDEF NO_USAR_RND_COMPILADOR}
  if semilla > 0 then
    Self.semilla_base := -semilla
  else
    Self.semilla_base := semilla;
{$ELSE}
  self.semilla_base := semilla;
  self.semilla := semilla;
{$ENDIF}
end;

procedure TMadreUniforme.setEstado(const estado: TEstadoMadreUniforme);
{$IFDEF NO_USAR_RND_COMPILADOR}
var
  i: integer;
{$ENDIF}
begin
  semilla_base := estado.semilla_base;
 {$IFDEF NO_USAR_RND_COMPILADOR}
  for i := low(glma) to High(glma) do
    glma[i] := estado.glma[i];
  glinext := estado.glinext;
  glinextp := estado.glinextp;
{$ELSE}
  Reiniciar(estado.semilla);
{$ENDIF}
end;

procedure TMadreUniforme.setEstado(const otraFuente: TMadreUniforme);
{$IFDEF NO_USAR_RND_COMPILADOR}
var
  i: integer;
{$ENDIF}
begin
  semilla_base := otraFuente.semilla_base;
 {$IFDEF NO_USAR_RND_COMPILADOR}
  for i := low(glma) to High(glma) do
    glma[i] := otraFuente.glma[i];
  glinext := otraFuente.glinext;
  glinextp := otraFuente.glinextp;
{$ELSE}
  Reiniciar(otraFuente.semilla);
{$ENDIF}
end;

procedure TMadreUniforme.getEstado(var estado: TEstadoMadreUniforme);
{$IFDEF NO_USAR_RND_COMPILADOR}
var
  i: integer;
{$ENDIF}
begin
  estado.semilla_base := Self.semilla_base;
  {$IFDEF NO_USAR_RND_COMPILADOR}
  for i := low(glma) to High(glma) do
    estado.glma[i] := glma[i];
  estado.glinext := glinext;
  estado.glinextp := glinextp;
{$ELSE}
  estado.semilla_base := semilla_base;
  estado.semilla := semilla;
{$ENDIF}
end;

// Métodos de tf_dppUniformeRand3
constructor Tf_ddpUniformeRand3.Create(madreUniforme: TMadreUniforme; semilla: integer);

begin
  inherited Create(0, 0, 1, 1, madreUniforme, semilla);
end;

function Tf_ddpUniformeRand3.densidad(x: NReal): NReal;
begin
  if x < 0 then
    Result := 0
  else if x >= 1 then
    Result := 0
  else
    Result := 1;
end;

function Tf_ddpUniformeRand3.distribucion(x: NReal): NReal;
begin
  if x < 0 then
    Result := 0
  else if x >= 1 then
    Result := 1
  else
    Result := x;
end;

function Tf_ddpUniformeRand3.area_t(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function Tf_ddpUniformeRand3.area_t_rapida(t: NReal): NReal;
begin
  Result := distribucion(t);
end;

function Tf_ddpUniformeRand3.t_area(area: NReal): NReal;
begin
  if area < 0 then
    Result := 0
  else if area >= 1 then
    Result := 1
  else
    Result := area;
end;

function Tf_ddpUniformeRand3.rnd: NReal;
begin
  Result := madreUnif.rnd;
end;

end.
