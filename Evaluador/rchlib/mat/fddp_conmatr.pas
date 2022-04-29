unit fddp_conmatr;
{$mode delphi}
{$DEFINE DBUG_CAMBIAR_HISTOGRAMA}

interface

uses
  Classes, SysUtils, xmatdefs, math, matreal, fddp;

type
  Tf_ddp_VectDeMuestras = class( Tf_ddp)
  public
    a: TVectR;

    constructor Create;  // usar uno de los dos siguientes

    // esta versión hace una copia del vector muestras.
    constructor Create_ClonandoMuestras(muestras: TVectR;
      madreUniforme: TMadreUniforme;   semilla: integer);

    // esta versión no copia el vector de muestras sino que lo apunta OJO.
    // cualquier modificación externa modifica la fuente.
    constructor Create_SinClonarMuestras(muestras: TVectR; madreUniforme: TMadreUniforme; semilla: integer);

    procedure Free; override;

(* retorna el k tal que a.e(k) <= t <= a.e(k+1)
  si retorna 0 significa que t < a.e(1)
*)
    function k_inf_t(t: NReal): integer;
    function densidad(x: NReal): NReal; override;
    function area_t(t: NReal): NReal; override;
    function t_area(area: NReal): NReal; override;
  end;

  TDAOf_ddp_VectDeMuestras = array of Tf_ddp_VectDeMuestras;
  TMatOf_ddp_VectDeMuestras = array of TDAOf_ddp_VectDeMuestras;


  Tf_ddp_VectFPAcum = class(Tf_ddp)
  public
    a: TVectR;
    dt: NReal;
    constructor Create(
    // el primer casillero es el de xt0, y el último elde xt1
    // el primer casillero debiera tener valor 0 y el último 1 para
    // que xt1, xt2 comprenda al rango posible de la variable
      FAcum: TVectR; xt0, xt1: NReal; madreUniforme: TMadreUniforme;
      semilla: integer);
    procedure Free; override;

(* retorna el k tal que a.e(k) <= u <= a.e(k+1)
  si retorna 0 significa que u < a.e(1)

  u debe estar entre [0, 1]
*)
    function k_inf_u(u: NReal): integer;
    function densidad(x: NReal): NReal; override;
    function area_t(t: NReal): NReal; override;
    function t_area(area: NReal): NReal; override;
  end;

  (*
    Donde pol(t) es un polinimo de t
     La función de probabilidad acumulada del tipo F(t) = 1 - exp( pol(t) )
     La función es válida en el rango xt0, xt1
  *)
    Tf_ddp_F1mExpPol = class(Tf_ddp)
    public
      pol, mdpol: TVectR;
      constructor Create(xpol: TVectR; xt0, xt1: NReal;
        madreUniforme: TMadreUniforme; semilla: integer);
      procedure Free; override;

      function densidad(x: NReal): NReal; override;
      function area_t(t: NReal): NReal; override;
    end;


(*+doc CambiarHistograma
 rch@jueves 3 de setiembre del 2009.

 cambiarHistograma, dado un vector de muestras x con su vector de pesos q
 busca el vector de pesos p tal que la serie x con los pesos p tenga
 el valor esperado my y la desviación estándar stdy.

 El resultado dela función es
   0 si logró el objetivo.
  -1 la varianza no es alcanzable. Ver ratio para información de la máxima varianza alcanzable
  -2 el valor my es superior a x(N)
  -3 el valor my es inferior a x(1)
  -4 superé las N itereaciones en búsqueda del objetivo.

 El resultado -4 se da cuando la varianza exigida es muy pequeña y no logra
 conseguir un su
 conjunto de muestras que combinadas del el valor medio objetivo
 con la varianza requeirda

 Si logra el objetivo crea y retorna el vector de pesos p, si no
 logra el objetivo p se retorna a nil.
 También devuelve en cnt_Iteraciones la cantidad de iteraciones que tuvo
 que hacer para resolver el problema.

 En la variable "ratio" se devuelve la relación entre la desviación estandar
 objetivo y la desviación estándar  máxima alcanzable con el rango del vector
 de muestras para el valor esperado objetivo.
 Si ratio > 1 no es posible encontra solución.
 Para valores de 0<= ratio < 1 el algoritmo debiera encontrar la solución.

 Para la búsqueda de la solución se resuelve el siguiente problema de optimización.

 min  ( sum( ( p[i] - q[i] )^2 ) ;
 p[i]

 sujeto a:
   sum( p[i] ) = 1 ;
   < p[i] * x[i] > = my
   < p[i] * ( x[i] - my )^2 > = stdy^2
   p[i] >= 0 ;

 El resultado es por tanto un vector de pesos lo más cercano posible al original
 que cumpla que con ese vector de pesos las muestras x[i] tienen valor esperado
 y desviación estándar dados.
 -doc*)


function cambiarHistograma(
  const x: TVectR; // vector de muestras
  const q: TVectR; // vector de pesos de las muestras NIL = equiprobables.

  my: NReal; // valor esperado objetivo
  stdy: NReal; // valor de la desviación estandar objetivo

  var p: TVectR; // vector con los nuevos pesos
  var ratio: NReal; // relación entre la stdy máxima alcanzable y la objetivo
  var cnt_Iteraciones: integer // cantidad de iteraciones
  ): integer;




(*+doc muestrasEquiprobables

Recibe un histograma descripto como un vector de muestras (x) y un vector de pesos (p)
y retorna un vector N, muestras equi-probables que representa el mismo histograma.

-doc*)
function muestrasEquiprobables(const x: TVectR;
  const p: TVectR;
  n: integer): TVectR;


(* factorial *)
function factorial( n: integer ): integer;

(* CombinacionesNP - Cominaciones de N tomadas de a P *)
function combinaciones_mn( m, n : integer ): integer;


(*
Retorna un vector con la CDF de la distribución Binomial de
m elementos con probabilidad p.

La variable aletaoria es la cantidad de elementos en estado 1
en una población de m elmentos de los que cada uno en forma
independiente puede estar en estado 1 con probablilidad p y en
estado 0 con probabilidad 1-p

El resultado tiene m+1 elementos.
v[k] es la probabilidad acumulada de tener j < k elementos en estado 1.

Así, el primer casillero v[1] tiene la probabilidad de tener 0 elementos
en estado 1. El primier elemento tiene el valor (1-p)^m

El casillero v[m+1] tiene la probabilidad de tener m o menos elementos en
estado 1. Como siempre se tendrá del conjunto de m elemetos j <=m <(m+1)
elementos en estado 1, v[m+1] = 1.
*)
function binomial_cdf( m: integer; p: NReal ): TVectR;

(*
Retorna un vector con la PDF de la función Densidad de Probabilidad Binomial
de m elementos con probabilidad p.

La variable aletaoria es la cantidad de elementos en estado 1
en una población de m elmentos de los que cada uno en forma
independiente puede estar en estado 1 con probablilidad p y en
estado 0 con probabilidad 1-p

El resultado tiene m+1 elementos.
v[k] es la probabilidad acumulada de tener  k-1 elementos en estado 1.

Así, el primer casillero v[1] tiene la probabilidad de tener 0 elementos
en estado 1. El primier elemento tiene el valor (1-p)^m

El casillero v[m+1] tiene la probabilidad de tener m elementos en
estado 1.  v[m+1] = p^m.

El casillero v[k+1] tienen la probabilidad de tener k elementos
en estado 1 y m-k elementos en estado 0.
  v[k+1] = C(m,n) p^k (1-p)^(m-k)

*)
function binomial_pdf( m: integer; p: NReal ): TVectR;

implementation


(* factorial *)
function factorial( n: integer ): integer;
var
  res: integer;
  k: integer;
begin
  if n > 0 then
  begin
    res:= 1;
    for k:= 2 to n do
      res:= res * k;
    result:= res;
  end
  else
   if n = 0 then
     result:= 1
   else
   begin
     res:= - n;
     if (res mod 2) = 0 then
        result:= factorial( res )
     else
        result:= - factorial( res );
   end;
end;

(* Combinaciones_mn - Cominaciones de m tomadas de a n *)
function combinaciones_mn( m, n : integer ): integer;
var
  r: NReal;
  k: integer;
begin
  if (m-n) < n then // busco calcular con el n más chico para reducir el for
    result:= combinaciones_mn( m, m-n )
  else
  begin
    r:= 1.0;
    for k:= 1 to n do
      r:= r * (m-n+k)/k;
    result:= trunc( r+0.5 );
  end;
end;

(*
Usamos que C(m, n ) = C(m, n -1) * (m-(n-1))/n
para calcular la distribución Binomial
*)
function binomial_pdf( m: integer; p: NReal ): TVectR;
var
  c: NReal;
  k: integer;
  res: TVectR;
  q, psq: NReal;
begin
  q:= 1-p;
  c:= 1;
  res:= TVectR.Create_Init( m + 1);
  psq:= p/q;
  c:= power( q, m );
  for k:= 1 to m+1 do
  begin
   res.pv[k]:= c;
   c:= c * (m - (k-1) )/ k*psq;
  end;
  result:= res;
end;


(*
Ca y la acumulamos
para tener la CDF
*)
function binomial_cdf( m: integer; p: NReal ): TVectR;
var
  k: integer;
  cdf: TVectR;
begin
  cdf:= binomial_pdf( m, p );
  for k:= 2 to cdf.n do
   cdf.pv[k]:= cdf.pv[k-1] + cdf.pv[k];
  result:= cdf;
end;


function cambiarHistograma(const x: TVectR; // vector de muestras
  const q: TVectR; // vector de pesos de las muestras NIL = equiprobables.

  my: NReal; // valor esperado objetivo
  stdy: NReal; // valor de la varianza objetivo

  var p: TVectR; // verctor con los nuevos pesos
  var ratio: NReal; // relación entre la stdy máxima alcanzable y la objetivo
  var cnt_Iteraciones: integer // cantidad de iteraciones
  ): integer;

label
  lbl_Iterar, lbl_finiter;

var
  k: integer;
  N: integer;
  mx, varx: NReal;
  vary: NReal;
  m, landa: TMatR;
  a: NReal;

  activa: array of boolean;
  beta: TVectR;
  {  cntActivas, }cntVioladas: integer;
  //  j: integer;

  amp, mpu, varpu: NReal;
  invertible: boolean;
  c: array[1..3] of NReal;
  jFil, jCol: integer;

  qaux: TVectR;
  buscando: boolean;
  flg_SupereNiteraciones: boolean;
  e10: integer;

{$IFDEF DBUG_CAMBIAR_HISTOGRAMA}
var
  fdbg: textfile;
{$ENDIF}

begin
  {$IFDEF DBUG_CAMBIAR_HISTOGRAMA}
  assignfile( fdbg, 'cambiarHistograma.xlt' );
  rewrite( fdbg );
  writeln( fdbg, 'x: ' );
  x.WriteXLTSimple( fdbg );

  if q <> nil then
  begin
    writeln( fdbg, 'q: ' );
    q.WriteXLTSimple( fdbg );
  end
  else
    writeln( fdbg, 'q: NIL' );

  writeln( fdbg, 'my: ', my );
  writeln( fdbg, 'stdy: ', stdy );
  closefile( fdbg );
  {$ENDIF}


  p := nil;
  flg_SupereNIteraciones := False;

  N := x.n;

  if (my < x.e(1)) then
  begin
    Result := -3;
    exit;
  end;

  if (my > x.e(N)) then
  begin
    Result := -2;
    exit;
  end;


  vary := sqr(stdy);
  if q = nil then
  begin
    qaux := TVectR.Create_Init(N);
    a := 1.0 / N;
    for k := 1 to N do
      qaux.pon_e(k, a);
  end
  else
    qaux := q;

  x.promedioVarianza(mx, varx{, false} );
{  mx:= x.promedio;
  varx:= x.varianza;}

  amp := x.e(N) - x.e(1);
  mpu := (my - x.e(1)) / amp;
  varpu := vary / sqr(amp);

  ratio := sqrt(varpu / (mpu * (1 - mpu)));

  if ratio > 1 then
  begin
    Result := -1;
    exit;
  end;

  p := TVectR.Create_init(x.n);
  beta := TVectR.Create_init(x.n);
  setlength(activa, N + 1);
  landa := TMatR.Create_Init(3, 1);
  m := TMatR.Create_Init(3, 3);

  for k := 1 to N do
    activa[k] := False;
  //  cntVioladas:= 0;
  //  cntActivas:= 0;
  cnt_Iteraciones := 0;
  buscando := True;

  lbl_iterar:
    Inc(cnt_Iteraciones);

  if (cnt_Iteraciones > N) then
  begin
    //    da warning, en el if despues de lbl_finiter se asigna el valor de result en todas las ramas
    //    result:= -4;
    buscando := False;
    flg_SupereNIteraciones := True;
    goto lbl_finiter;
  end;

  // cargo el término independiente
  landa.pon_e(1, 1, 0);
  landa.pon_e(2, 1, 2 * mx - 2 * my);
  a := 2 * (varx + sqr(mx - my)) - 2 * vary;
  landa.pon_e(3, 1, a);

  m.Ceros;

  // cargo la matriz
  for k := 1 to N do
  begin
    c[1] := 1;
    c[2] := x.e(k);
    c[3] := sqr(x.e(k) - my);

    if not activa[k] then
    begin
      for jFil := 1 to 3 do
        for jCol := jFil to 3 do
          m.acum_e(jFil, jCol, c[jFil] * c[jCol]);
    end
    else
    begin
      landa.acum_e(1, 1, -2 * qaux.e(k) * c[1]);
      landa.acum_e(2, 1, -2 * qaux.e(k) * c[2]);
      landa.acum_e(3, 1, -2 * qaux.e(k) * c[3]);
    end;
  end;

  // simetrizo la matriz
  for jFil := 2 to 3 do
    for jCol := 1 to jFil - 1 do
      m.pon_e(jFil, jCol, m.e(jCol, jFil));


  // resolvemos el problema
  {  a:=  }m.Escaler(landa, invertible, e10);
  if not invertible then
    goto lbl_finiter;

  // calculamos los betas ; si alguno da menor que cero tengo que
  // desactivar la restricción. pi >= 0 correspondiente.
  for k := 1 to N do
  begin
    if activa[k] then
    begin
      a := landa.e(1, 1) + x.e(k) * landa.e(2, 1) + sqr(x.e(k) - my) *
        landa.e(3, 1) - 2.0 * qaux.e(k);
      beta.pon_e(k, a);
      if a < -0.000000000001 then
      begin
        activa[k] := False;
        //        dec( cntActivas );
        goto lbl_iterar;
      end;
    end;
  end;


  // bien, si todos los betas son positivos calculo pos pi y veo si tengo nuevas
  // violaciones.


  cntVioladas := 0;
  for k := 1 to N do
  begin
    if not activa[k] then
    begin
      a := qaux.e(k) - 0.5 * (landa.e(1, 1) + landa.e(2, 1) * x.e(k) +
        landa.e(3, 1) * sqr(x.e(k) - my));
      p.pon_e(k, a);
      if a < -0.00000000001 then
      begin
        Inc(cntVioladas);
        activa[k] := True;
      end;
    end
    else
      p.pon_e(k, 0);
  end;

  if (cntVioladas > 0) then
  begin
    //    cntActivas:= cntActivas + cntVioladas;
    goto lbl_iterar;
  end;

  buscando := False;

  lbl_finiter:

    if q = nil then
      qaux.Free;

  beta.Free;
  setlength(activa, 0);
  landa.Free;
  m.Free;

  if buscando then
  begin
    p.Free;
    p := nil;
    Result := -1;
  end
  else if flg_SupereNIteraciones then
  begin
    Result := -4;
  end
  else
    Result := 0;
end;



function muestrasEquiprobables(const x: TVectR;
  const p: TVectR;
  n: integer): TVectR;
var
  FdpAcum: TVectR;
  k: integer;
  Np: integer;
  res: TVectR;
  //  buscando: boolean;
  ir: NReal;
  x0, x1: NReal;
  jBuscando: integer;
  pAcum_j, pAcum_k: NReal;
  pAcum_jm1, delta_pAcum_j: NReal;
  y: NReal;
begin
  Np := p.n;
  FdpAcum := TVectR.Create_Init(Np);
  FdpAcum.pon_e(1, p.e(1));
  for k := 2 to Np do
    FdpAcum.pon_e(k, FdpAcum.e(k - 1) + p.e(k));

  res := TVectR.Create_Init(N);
  jBuscando := 1;
  pAcum_j := fdpAcum.e(1);
  delta_pAcum_j := 0; // lo asigno para eliminar warning.
  pAcum_jm1 := 0; // lo asigno para eliminar warning.
  x0 := x.e(1);
  x1 := x0;

  k := 1;
  pAcum_k := k * 1.0 / N;

  while k <= N do
  begin
    if pAcum_k <= pAcum_j then
    begin
      if (jBuscando > 1) and (delta_pAcum_j > AsumaCero) then
      begin
        ir := (pAcum_k - pAcum_jm1) / delta_pAcum_j;
        y := x0 + (x1 - x0) * ir;
      end
      else
        y := x1;
      res.pon_e(k, y);
      Inc(k);
      pAcum_k := k * 1.0 / N;
    end
    else
    begin
      if jBuscando < Np then
      begin
        x0 := x1;
        pAcum_jm1 := pAcum_j;
        Inc(jBuscando);
        x1 := x.e(jBuscando);
        pAcum_j := fdpAcum.e(jBuscando);
        delta_pAcum_j := pAcum_j - pAcum_jm1;
      end
      else
      begin
        y := x1;
        res.pon_e(k, y);
        Inc(k);
        pAcum_k := k * 1.0 / N;
      end;
    end;
  end;

  fdpAcum.Free;
  Result := res;

end;

constructor Tf_ddp_VectDeMuestras.Create;  // usar uno de los dos siguientes
begin
  raise Exception.Create('Tf_dpp_VectDeMuestras.Create --- Usar la versión Clonando');
end;
// esta versión hace una copia del vector muestras.

constructor Tf_ddp_VectDeMuestras.Create_ClonandoMuestras(muestras: TVectR;
  madreUniforme: TMadreUniforme; semilla: integer);
begin
  inherited Create(0, 0, 1, 1, madreUniforme, semilla); // arreglamos t0  y t1 después
  a := TVectR.Create_Init(muestras.n);
  a.Copy(muestras);
  a.Sort(True);
  Self.t0 := a.e(1);
  Self.t1 := a.e(a.n);
end;


constructor Tf_ddp_VectDeMuestras.Create_sinClonarMuestras(muestras: TVectR;
  madreUniforme: TMadreUniforme; semilla: integer);
begin
  inherited Create(0, 0, 1, 1, madreUniforme, semilla); // arreglamos t0  y t1 después
  self.a := muestras;
  a.Sort(True);
  Self.t0 := a.e(1);
  Self.t1 := a.e(a.n);
end;

procedure Tf_ddp_VectDeMuestras.Free;
begin
  a.Free;
  inherited Free;
end;

function Tf_ddp_VectDeMuestras.k_inf_t(t: NReal): integer;
var
  k: integer;
  j: integer;
begin
  if (t < a.pv[1]) then
  begin
    Result := 0;
    exit;
  end;

{
  if (t >= a.pv[a.n]) then
  begin
    Result := a.n;
    exit;
  end;
 }

  k := ubicar_creciente_der(a.pv, 1, a.n, t);
  j:= k;
  while (j>2) and (a.pv[j-1] = t ) do dec( j );

  if j <> k then
  {$IFDEF RND_PROBABILIDAD_ACUMULADA}
   result:= trunc( self.rnd * ( k - j ) + j - 0.5)
   {$ELSE}
   result:= trunc( ( k + j ) / 2.0 - 0.5 )
   {$ENDIF}
  else
   result := k - 1;

end;

function Tf_ddp_VectDeMuestras.densidad(x: NReal): NReal;
var
  k1, k2: integer;
  t1, t2: NReal;
  dt: NReal;
  uk: NReal;
begin
  k1 := k_inf_t(x);
  if (k1 >= a.n) then
  begin
    Result := 0;
    exit;
  end;

  if (k1 < 1) then
  begin
    Result := 0;
    exit;
  end;

  t1 := a.e(k1);
  k2 := k1 + 1;
  t2 := a.e(k2);
  dt := t2 - t1;
  if dt > AsumaCero then
    uk := 1 / dt / (a.n - 1)
  else
    uk := 1e6; //ojo no está bien definido

  Result := uk;
end;

function Tf_ddp_VectDeMuestras.area_t(t: NReal): NReal;
var
  k1: integer;
  t1, t2: NReal;
  dt: NReal;
  uk: NReal;
begin
  k1 := k_inf_t(t);
  if (k1 >= a.n) then
  begin
    Result := 1;
    exit;
  end;

  if (k1 < 1) then
  begin
    t1 := a.pv[k1];
    Result := 0;
    exit;
  end;


  t1 := a.pv[k1];
  t2 := a.pv[k1+1];

  dt := t2 - t1;

{$IFDEF REVISAR_rch20110731}
  // así es como estaba
  if dt > AsumaCero then
    uk := (k1 + (t - t1) / dt - 1) / (a.n - 1)
  else
    uk := (k1 - 1) / (a.n - 1);
{$ELSE}
  // así es como me parece tendría que ser
  if dt > AsumaCero then
    uk := (k1 + (t - t1) / dt ) / a.n
  else
    uk := (k1 ) / a.n;
{$ENDIF}

  Result := uk;
end;

function Tf_ddp_VectDeMuestras.t_area(area: NReal): NReal;
var
  uk: NReal;
  k: integer;
begin

  uk := area * (a.n - 1);
  k := trunc(uk) + 1;

  (** ¿cuál será?
  // así es como me parece tiene que ser
  uk := area * a.n;
  k := trunc(uk);
  **)

  if (k < 1) then
  begin
    Result := a.e(1);
    exit;
  end;

  if (k >= a.n) then
  begin
    Result := a.e(a.n);
    exit;
  end;

  uk := frac(uk);
  Result := a.pv[k] + uk * (a.pv[k + 1] - a.pv[k]);

end;

constructor Tf_ddp_VectFPAcum.Create(
  // el primer casillero es el de xt0, y el último elde xt1
  // el primer casillero debiera tener valor 0 y el último 1 para
  // que xt1, xt2 comprenda al rango posible de la variable
  FAcum: TVectR; xt0, xt1: NReal; madreUniforme: TMadreUniforme;
  semilla: integer);
begin
  inherited Create(xt0, FAcum.e(1), xt1, 1, madreUniforme, semilla);
  a := TVectR.Create_Init(FAcum.n);
  a.Copy(FAcum);

  dt := (t1 - t0) / (a.n - 1);
end;

procedure Tf_ddp_VectFPAcum.Free;
begin
  a.Free;
  inherited Free;
end;

(* retorna el k tal que a.e(k) <= u <= a.e(k+1)
  si retorna 0 significa que u < a.e(1)

  u debe estar entre [0, 1]
*)
function Tf_ddp_VectFPAcum.k_inf_u(u: NReal): integer;
var
  buscando: boolean;
  k: integer;
begin
  if u <= a.e(1) then
  begin
    Result := 1;
    exit;
  end;

  if u > a.e(a.n) then
  begin
    Result := a.n;
    exit;
  end;

  buscando := True;
  k := 1;
  while buscando and (k < a.n) do
  begin
    if a.e(k + 1) > u then
      buscando := False
    else
      Inc(k);
  end;

  Result := k;
end;

function Tf_ddp_VectFPAcum.densidad(x: NReal): NReal;
var
  uk: NReal;
  k: integer;
  F1, F2: NReal;
begin
  uk := (x - t0) / dt;
  k := trunc(uk) + 1;

  if k < 1 then
  begin
    Result := 0;
    exit;
  end;

  if k >= a.n then
  begin
    Result := 0;
    exit;
  end;

  F1 := a.pv[k];
  F2 := a.pv[k + 1];

  Result := (F2 - F1) / dt;
end;

function Tf_ddp_VectFPAcum.area_t(t: NReal): NReal;
var
  uk: NReal;
  k: integer;
  F1, F2: NReal;
begin
  uk := (t - t0) / dt;
  k := trunc(uk) + 1;

  if k < 1 then
  begin
    Result := 0;
    exit;
  end;

  if k >= a.n then
  begin
    Result := 1;
    exit;
  end;

  F1 := a.pv[k];
  F2 := a.pv[k + 1];

  uk := frac(uk);
  Result := F1 + (F2 - F1) * uk;
end;

function Tf_ddp_VectFPAcum.t_area(area: NReal): NReal;
var
  k: integer;
  F1, F2: NReal;
  dF: NReal;
begin
  k := k_inf_u(area);
  if k <= 1 then
  begin
    Result := t0;
    exit;
  end;

  if k >= a.n then
  begin
    Result := t1;
    exit;
  end;

  F1 := a.pv[k];
  F2 := a.pv[k + 1];

  dF := F2 - F1;
  if dF < AsumaCero then
  begin
    Result := t0 + (k - 1) * dt;
    exit;
  end;

  Result := t0 + (k - 1) * dt + (area - F1) / dF * dt;
end;

(********
Métodos de Tf_ddp_F1mExpPol
*******)

constructor Tf_ddp_F1mExpPol.Create(xpol: TVectR; xt0, xt1: NReal;
  madreUniforme: TMadreUniforme; semilla: integer);
var
  k: integer;
begin
  inherited Create(xt0, 0, xt1, 1, madreUniforme, semilla);
  pol := xpol;
  mdpol := TVectR.Create_Init(pol.n - 1);
  for k := 1 to mdpol.n do
    mdpol.pon_e(k, -(k + 1) * pol.e(k + 1));
end;

procedure Tf_ddp_F1mExpPol.Free;
begin
  pol.Free;
  mdpol.Free;
  inherited Free;
end;

function Tf_ddp_F1mExpPol.densidad(x: NReal): NReal;
begin
  if (x < t0) or (x > t1) then
  begin
    Result := 0;
    exit;
  end;

  Result := pol.rpoly(x) * mdpol.rpoly(x);
end;

function Tf_ddp_F1mExpPol.area_t(t: NReal): NReal;
begin
  if (t < t0) then
  begin
    Result := 0;
    exit;
  end;

  if (t >= t1) then
  begin
    Result := 1;
    exit;
  end;

  Result := 1 - exp(pol.rpoly(t));
end;


end.

