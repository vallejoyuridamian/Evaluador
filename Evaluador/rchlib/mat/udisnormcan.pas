{xDEFINE DISTPORFORMULA}
unit udisnormcan;
interface

uses
  xmatdefs;

(* retorna la distribución de una gaussiana normal
es la integral que aparece en la página 653 del tomo II de Calculus

1/sqrt(2*pi) * Integral( u= -inf ; u= x ; exp( -sqr(u) /2 ) * du )

*)
function DistribucionNormalCanonica(x: NReal): NReal;
function Inv_DistribucionNormalCanonica(x: NReal): NReal;

(* Función densiad de probabilidad Distribución Normal
  1/sqrt( 2*pi) * exp( - 0.5 sqr( x ) )
*)
function fddp_NormalCanonica(x: NReal): NReal;

(*Genera el archivo: 'gamma.txt' con la tabla que figura en el libro
CALCULUS de TOM APOSTOL para verificación de que está OK.*)
procedure Test_DistribucionNormalCanonica;

// Logaritmo Natural de la función GAMMA ( en Excel es GAMMA.LN )
function gammln(xx: NReal): NReal;



implementation

{$IFNDEF DISTPORFORMULA}
const // Es la integral desde x=0 a x=j/100, con j= 0..369 de la gaussiana
  tabla_DistribucionNormalCanonica: array[0..370 - 1] of NReal = (
    0.500000, 0.503989, 0.507978, 0.511966, 0.515953, 0.519939, 0.523922,
    0.527903, 0.531881, 0.535856,
    0.539828, 0.543795, 0.547758, 0.551717, 0.555670, 0.559618, 0.563559,
    0.567495, 0.571424, 0.575345,
    0.579260, 0.583166, 0.587064, 0.590954, 0.594835, 0.598706, 0.602568,
    0.606420, 0.610261, 0.614092,
    0.617911, 0.621720, 0.625516, 0.629300, 0.633072, 0.636831, 0.640576,
    0.644309, 0.648027, 0.651732,
    0.655422, 0.659097, 0.662757, 0.666402, 0.670031, 0.673645, 0.677242,
    0.680822, 0.684386, 0.687933,
    0.691462, 0.694974, 0.698468, 0.701944, 0.705401, 0.708840, 0.712260,
    0.715661, 0.719043, 0.722405,
    0.725747, 0.729069, 0.732371, 0.735653, 0.738914, 0.742154, 0.745373,
    0.748571, 0.751748, 0.754903,
    0.758036, 0.761148, 0.764238, 0.767305, 0.770350, 0.773373, 0.776373,
    0.779350, 0.782305, 0.785236,
    0.788145, 0.791030, 0.793892, 0.796731, 0.799546, 0.802337, 0.805105,
    0.807850, 0.810570, 0.813267,
    0.815940, 0.818589, 0.821214, 0.823814, 0.826391, 0.828944, 0.831472,
    0.833977, 0.836457, 0.838913,
    0.841345, 0.843752, 0.846136, 0.848495, 0.850830, 0.853141, 0.855428,
    0.857690, 0.859929, 0.862143,
    0.864334, 0.866500, 0.868643, 0.870762, 0.872857, 0.874928, 0.876976,
    0.879000, 0.881000, 0.882977,
    0.884930, 0.886861, 0.888768, 0.890651, 0.892512, 0.894350, 0.896165,
    0.897958, 0.899727, 0.901475,
    0.903200, 0.904902, 0.906582, 0.908241, 0.909877, 0.911492, 0.913085,
    0.914657, 0.916207, 0.917736,
    0.919243, 0.920730, 0.922196, 0.923641, 0.925066, 0.926471, 0.927855,
    0.929219, 0.930563, 0.931888,
    0.933193, 0.934478, 0.935745, 0.936992, 0.938220, 0.939429, 0.940620,
    0.941792, 0.942947, 0.944083,
    0.945201, 0.946301, 0.947384, 0.948449, 0.949497, 0.950529, 0.951543,
    0.952540, 0.953521, 0.954486,
    0.955435, 0.956367, 0.957284, 0.958185, 0.959070, 0.959941, 0.960796,
    0.961636, 0.962462, 0.963273,
    0.964070, 0.964852, 0.965620, 0.966375, 0.967116, 0.967843, 0.968557,
    0.969258, 0.969946, 0.970621,
    0.971283, 0.971933, 0.972571, 0.973197, 0.973810, 0.974412, 0.975002,
    0.975581, 0.976148, 0.976705,
    0.977250, 0.977784, 0.978308, 0.978822, 0.979325, 0.979818, 0.980301,
    0.980774, 0.981237, 0.981691,
    0.982136, 0.982571, 0.982997, 0.983414, 0.983823, 0.984222, 0.984614,
    0.984997, 0.985371, 0.985738,
    0.986097, 0.986447, 0.986791, 0.987126, 0.987455, 0.987776, 0.988089,
    0.988396, 0.988696, 0.988989,
    0.989276, 0.989556, 0.989830, 0.990097, 0.990358, 0.990613, 0.990863,
    0.991106, 0.991344, 0.991576,
    0.991802, 0.992024, 0.992240, 0.992451, 0.992656, 0.992857, 0.993053,
    0.993244, 0.993431, 0.993613,
    0.993790, 0.993963, 0.994132, 0.994297, 0.994457, 0.994614, 0.994766,
    0.994915, 0.995060, 0.995201,
    0.995339, 0.995473, 0.995604, 0.995731, 0.995855, 0.995975, 0.996093,
    0.996207, 0.996319, 0.996427,
    0.996533, 0.996636, 0.996736, 0.996833, 0.996928, 0.997020, 0.997110,
    0.997197, 0.997282, 0.997365,
    0.997445, 0.997523, 0.997599, 0.997673, 0.997744, 0.997814, 0.997882,
    0.997948, 0.998012, 0.998074,
    0.998134, 0.998193, 0.998250, 0.998305, 0.998359, 0.998411, 0.998462,
    0.998511, 0.998559, 0.998605,
    0.998650, 0.998694, 0.998736, 0.998777, 0.998817, 0.998856, 0.998893,
    0.998930, 0.998965, 0.998999,
    0.999032, 0.999065, 0.999096, 0.999126, 0.999155, 0.999184, 0.999211,
    0.999238, 0.999264, 0.999289,
    0.999313, 0.999336, 0.999359, 0.999381, 0.999402, 0.999423, 0.999443,
    0.999462, 0.999481, 0.999499,
    0.999517, 0.999534, 0.999550, 0.999566, 0.999581, 0.999596, 0.999610,
    0.999624, 0.999638, 0.999651,
    0.999663, 0.999675, 0.999687, 0.999698, 0.999709, 0.999720, 0.999730,
    0.999740, 0.999749, 0.999758,
    0.999767, 0.999776, 0.999784, 0.999792, 0.999800, 0.999807, 0.999815,
    0.999822, 0.999828, 0.999835,
    0.999841, 0.999847, 0.999853, 0.999858, 0.999864, 0.999869, 0.999874,
    0.999879, 0.999883, 0.999888
    );

 {$ENDIF}


function gammln(xx: NReal): NReal;
const
  stp = 2.50662827465;
  half = 0.5;
  one = 1.0;
  fpf = 5.5;
var
  x, tmp, ser: double;
  j: integer;
  cof: array [1..6] of double;
begin
  cof[1] := 76.18009173;
  cof[2] := -86.50532033;
  cof[3] := 24.01409822;
  cof[4] := -1.231739516;
  cof[5] := 0.120858003e-2;
  cof[6] := -0.536382e-5;
  x := xx - one;
  tmp := x + fpf;
  tmp := (x + half) * ln(tmp) - tmp;
  ser := one;
  for j := 1 to 6 do
  begin
    x := x + one;
    ser := ser + cof[j] / x;
  end;
  gammln := tmp + ln(stp * ser);
end;

procedure gser(a, x: NReal; var gamser, gln: NReal);
label
  1;
const
  itmax = 100;
  eps = 3.0e-7;
var
  n: integer;
  sum, del, ap: NReal;
begin
  gln := gammln(a);
  if (x <= 0.0) then
  begin
    if (x < 0.0) then
    begin
      writeln('pause in GSER - x less than 0');
      readln;
    end;
    gamser := 0.0;
  end
  else
  begin
    ap := a;
    sum := 1.0 / a;
    del := sum;
    for n := 1 to itmax do
    begin
      ap := ap + 1.0;
      del := del * x / ap;
      sum := sum + del;
      if (abs(del) < abs(sum) * eps) then
        goto 1;
    end;
    writeln('pause in GSER - a too large, itmax too small');
    readln;
    1:
      gamser := sum * exp(-x + a * ln(x) - gln);
  end;
end;

procedure gcf(a, x: NReal; var gammcf, gln: NReal);
label
  1;
const
  itmax = 100;
  eps = 3.0e-7;
var
  n: integer;
  gold, g, fac, b1, b0, anf, ana, an, a1, a0: NReal;
begin
  g := 0; // 070409 agrego para evitar warning del compilador
  gln := gammln(a);
  gold := 0.0;
  a0 := 1.0;
  a1 := x;
  b0 := 0.0;
  b1 := 1.0;
  fac := 1.0;
  for n := 1 to itmax do
  begin
    an := 1.0 * n;
    ana := an - a;
    a0 := (a1 + a0 * ana) * fac;
    b0 := (b1 + b0 * ana) * fac;
    anf := an * fac;
    a1 := x * a0 + anf * a1;
    b1 := x * b0 + anf * b1;
    if (a1 <> 0.0) then
    begin
      fac := 1.0 / a1;
      g := b1 * fac;
      if (abs((g - gold) / g) < eps) then
        goto 1;
      gold := g;
    end;
  end;
  writeln('pause in GCF - a too large, itmax too small');
  readln;
  1:
    gammcf := exp(-x + a * ln(x) - gln) * g;
end;

function gammp(a, x: NReal): NReal;
var
  gammcf, gln: NReal;
begin
  if ((x < 0.0) or (a <= 0.0)) then
  begin
    writeln('pause in GAMMP - invalid arguments');
    readln;
  end;
  if (x < (a + 1.0)) then
  begin
    gser(a, x, gammcf, gln);
    gammp := gammcf;
  end
  else
  begin
    gcf(a, x, gammcf, gln);
    gammp := 1.0 - gammcf;
  end;
end;

function erf(x: NReal): NReal;
begin
  if (x < 0.0) then
  begin
    erf := -gammp(0.5, sqr(x));
  end
  else
  begin
    erf := gammp(0.5, sqr(x));
  end;
end;

function DistribucionNormalCanonica(x: NReal): NReal;
var
  i1: integer;
  rx, y: NReal;
  flg_xpos: boolean;
begin
{$IFDEF DISTPORFORMULA}
  if (x < 0.0) then
  begin
    Result := 0.5 - gammp(0.5, sqr(x) / 2.0) / 2.0;
  end
  else
  begin
    Result := 0.5 + gammp(0.5, sqr(x) / 2.0) / 2.0;
  end;
{$ELSE}
  if x > 0.0 then
  begin
    flg_xpos := True;
    rx := x * 100;
  end
  else
  begin
    flg_xpos := False;
    rx := -x * 100;
  end;

  if rx >= 369 then
  begin
    if flg_xpos then
      Result := 1.0
    else
      Result := 0.0;
    exit;
  end;

  i1 := trunc(rx);
  rx := frac(rx);
  y := tabla_DistribucionNormalCanonica[i1] *
    (1 - rx) + tabla_DistribucionNormalCanonica[i1 + 1] * rx;
  if flg_xpos then
    Result := y
  else
    Result := 1 - y;
  {$ENDIF}
end;

function Inv_DistribucionNormalCanonica(x: NReal): NReal;
var
  k: integer;
  buscando: boolean;
  complemento: boolean;
  res, alfa: NReal;
begin
  if x < 0.5 then
  begin
    complemento := True;
    x := 1 - x;
  end
  else
    complemento := False;

  buscando := True;
  k := low(tabla_DistribucionNormalCanonica);
  while buscando and (k < high(tabla_DistribucionNormalCanonica)) do
  begin
    if tabla_DistribucionNormalCanonica[k + 1] >= x then
      buscando := False
    else
      Inc(k);
  end;

  if buscando then
    res := 3.69 // valor muy grande
  else
  begin
    alfa := (x - tabla_DistribucionNormalCanonica[k]) /
      (tabla_DistribucionNormalCanonica[k + 1] - tabla_DistribucionNormalCanonica[k]);
    //    res:= k/100.0 + alfa * 0.01;
    res := (k + alfa) * 0.01;
  end;

  if complemento then
    Result := -res
  else
    Result := res;
end;

function fddp_NormalCanonica(x: NReal): NReal;
const
  usr2p =  0.398942280401433;  // 1/sqrt( 2* pi )
begin
  result := usr2p * exp( -0.5* sqr(x) );
end;


procedure Test_DistribucionNormalCanonica;
var
  k, j: integer;
  sal: textfile;
  x, g: NReal;
begin
  assignfile(sal, 'gamma.txt');
  rewrite(sal);
  Write(sal, '       ');
  for j := 1 to 10 do
    Write(sal, (j - 1) * 0.01: 8: 2);
  writeln(sal);
  for k := 1 to 37 do
  begin
    if ((k - 1) mod 5) = 0 then
      writeln(sal);
    Write(sal, 0.1 * (k - 1): 8: 1);
    for j := 1 to 10 do
    begin
      x := ((k - 1) * 0.1 + (j - 1) * 0.01);
      g := DistribucionNormalCanonica(x);
      Write(sal, g: 9: 6, ',');
    end;
    writeln(sal);
  end;
  closefile(sal);

  assignfile( sal, 'serie_gaussiana_test.xlt' );
  rewrite( sal );
  for k:= 1 to 20000 do
  begin
    x:= system.Random;
    x:= Inv_DistribucionNormalCanonica( x );
    writeln( sal, x );
  end;
  closefile( sal );
end;



end.
