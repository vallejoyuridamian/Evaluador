(* Oct.2005, rch@todo.com.uy *)
unit uregresion;

interface

uses
  SysUtils, Classes, xmatdefs,  matent, matreal, Math, fddp;

(******
retorna un filtro recursivo que explica el vector y con la mínima
varianza de la entrada
yk = sum( bj y(k-j) ; j= 1..orden ) + uk

siendo bj el elemento j del resultado

si filtrar = true, solo se tienen en cuenta las muestras con valor
mayor que umbralFiltro. Esto es útil, para filtrar las muestras dudosas
para lo cual se les pone un valor negativo, menor que cualquier valor
que pueda tomar el proceso real y se fija el filtro para que no considere
esas muestras.

*******)
function calcmincuad_rh(y: TVectR; orden: integer; filtrar: boolean;
  umbralFiltro: NReal): TVectR;

(***********
Cálculo de las matrices MTM y MTY del sistema MTM . A = MTY para
el racimo de vectores (series) pasado como parámetros.
El el orden del filtro es la cantidad de pasos del pasado considerado
para cada serie. La matriz A es de [orden*nseries x orden*nseries]

si filtrar = true, solo se tienen en cuenta las muestras con valor
mayor que umbralFiltro. Esto es útil, para filtrar las muestras dudosas
para lo cual se les pone un valor negativo, menor que cualquier valor
que pueda tomar el proceso real y se fija el filtro para que no considere
esas muestras.

***********)
procedure calc_sistema(var XXt, XYt, YYt: TMatR; series: array of TVectR;
  orden: integer; filtrar: boolean; umbralFiltro: NReal; Normalizar: boolean);

(* rch 201602051826
Lo mismo que el anterior, pero cuando tiene huecos en la información en lugar de elminar
todo el paso de tiempo, calcula las correlaciones en donde puede y las agrega a las matrices
incrementando la cuenta de elementos considerados en cada producto inerior. *)
procedure calc_sistema_InfoParcial_(var XXt, XYt, YYt: TMatR;
  series: array of TVectR; orden: integer; filtrar: boolean;
  umbralFiltro: NReal; Normalizar: boolean);




// rch 201607071056
// Calcula las matrices XXt, XYt, YYt corresponidentes para la resolución del
// problema lineal Y[k] = sum( h= 0 to NRetardos; A[h] X[k-h]+ B Rk )
procedure calc_sistema_Y_AX_B_InfoParcial_(var XXt, XYt, YYt: TMatR;
  seriesY, seriesX: array of TVectR; nRetardos: integer; filtrar: boolean;
  umbralFiltro: NReal; Normalizar: boolean);




(***** rch 201607071056

retorna un filtro recursivo multi-variable que explica los vectores
"seriesY" como la combinación lineal los vectores "seriesX" y sus pasados
más un vector de mínima varianza

si filtrar = true, solo se tienen en cuenta las muestras con valor
mayor que umbralFiltro. Esto es útil, para filtrar las muestras dudosas
para lo cual se les pone un valor negativo, menor que cualquier valor
que pueda tomar el proceso real y se fija el filtro para que no considere
esas muestras.

Retorna la Matriz A' del filtro lineal que explica
Y[k] = A [X[k]; X[k-1] ; ...;  X[k-NRetardos] + B R

X = [X[k]; X[k-1] ; ...;  X[k-NRetardos]

Y = A X + B R


Donde R / < R * R' > = I


***)
function calcmincuad_mrh_Y_AX_B(const seriesY, SeriesX: array of TVectR;
  nretardos: integer; filtrar: boolean; umbralFiltro: NReal; var BBt: TMatR): TMatR;


(*****
retorna un filtro recursivo multi-variable que explica los vectores
"series" como la combinación lineal de sus pasados  más un
vector de mínima varianza

si filtrar = true, solo se tienen en cuenta las muestras con valor
mayor que umbralFiltro. Esto es útil, para filtrar las muestras dudosas
para lo cual se les pone un valor negativo, menor que cualquier valor
que pueda tomar el proceso real y se fija el filtro para que no considere
esas muestras.

Retorna la Matriz A' del filtro lineal que explica
X[k+1] = A [X[k]; X[k-1] ; ...;  X[k- (orden-1)] + B R

Y = X[k+1]
X = [X[k]; X[k-1] ; ...;  X[k- (orden-1)]

Y = A X + B R


Donde R / < R * R' > = I


***)
function calcmincuad_mrh(series: array of TVectR; orden: integer;
  filtrar: boolean; umbralFiltro: NReal;  flg_InfoParcial: boolean; var BBt: TMatR): TMatR;


(*****
retorna un filtro recursivo multi-ciclo y  multi-variable que explica los vectores
my como la combinación lineal de sus pasados (de 1 a orden) más un
vector de mínima varianza.

si filtrar = true, solo se tienen en cuenta las muestras con valor
mayor que umbralFiltro. Esto es útil, para filtrar las muestras dudosas
para lo cual se les pone un valor negativo, menor que cualquier valor
que pueda tomar el proceso real y se fija el filtro para que no considere
esas muestras.

El parámetro overlapping indica en cuantos pasos anteriores y posteriores
debe ser considerado una muestra en la determinación del filtro. Por ejemplo
si overlapping=3 una muestra será considerada en el paso de tiempo que corresponde
y en los tres pasos anteriores y los tres posteriores.

El resultado es dos array de las nPasosPorCiclo matrices del filtro.
Una matriz A y una B para cada paso de ciclo.

El resultado es la cantidad de FALLOS en la resolución del problema de mínimos
cuadrados. Si todo anduvo OK, es CERO. Para los sitemas que no pudo resolver,
 mcA[k] y mcB[k] son NIL.

Si parámetro Normalizar = TRUE , se supone que las series son de Norma 1 y
como el tratamiento multi-ciclo puede romper con esa característica se inenta
volver a recomponer sobre los coeficientes de correlación con que se calculan
las matrices de aproximación por mínimos cuadrados.

El parámetro series_Nombres sirve para etiquetar la impresión a archivo
de la matriz de covarianzas. Poner NIL si no corresponde
***)

function calcmincuad_mrh_mc(series_X: array of TVectR; orden: integer;
  filtrar: boolean; umbralFiltro: NReal; r_nPasosPorCiclo, r_OffesetCiclo: NReal;
  overlapping, traslapping, nPasosPorMiniCiclo: integer;
  var mcA, mcB: TDAOfMatR; Normalizar: boolean;
  series_Nombres: TStringList;
  flg_InfoParcial: boolean;
  flg_CompletarHuecosConRuidoBlanco: boolean;
  var VarNoExplicado: NReal  // variaza de lo no explicado promedio
  ): TVectR;




implementation



function calcmincuad_rh(y: TVectR; orden: integer; filtrar: boolean;
  umbralFiltro: NReal): TVectR;

var
  m, i: TMatR;
  k, j: integer;
  a: NReal;
  invertible: boolean;
  e10: integer;

begin
  m := TMatR.Create_Init(orden, orden);
  i := TMatR.Create_Init(orden, 1);

  for k := 1 to orden do
  begin
    for j := k to orden do
    begin
      a := y.coefcorr(y, j - k, filtrar, umbralFiltro);
      m.pon_e(k, j, a);
      if k <> j then
        m.pon_e(j, k, a);
    end;
    a := y.coefcorr(y, k, filtrar, umbralFiltro);
    i.pon_e(k, 1, a);
  end;

  m.Escaler(i, invertible, e10);
  Result := i.crear_columna(1);
end;


(***********
Cálculo de las matrices MTM y MTY del sistema MTM . A = MTY para
el racimo de vectores (series) pasado como parámetros.
El el orden del filtro es la cantidad de pasos del pasado considerado
para cada serie.si p es el número de series,
dim= orden* p La matriz MTM es de [dim x dim ]
Las matrices A  y MTY son de [dim x p]
***********)

(*
procedure calc_sistema(var MTM: TMatR; var MTY: TMatR; series: array of TVectR;
  orden: integer; filtrar: boolean; umbralFiltro: NReal);
var
  k, j: integer;
  p:    integer;
  ks, kcof: integer;
  js, jcof: integer;
  dim:  integer;
  jj:   integer;
begin

  p   := length(series);
  dim := p * orden;

  MTM := TMatR.Create_Init(dim, dim);
  MTY := TMatR.Create_Init(dim, p);

  k := 0; // inicializo el índice de fila

  for kcof := 1 to orden do
    for ks := 1 to p do
    begin

      k := k + 1; // índice de fila
      // cálculo del coeficiente de MTM
      j := 0; //inicializo el índice de columna

      for jcof := 1 to orden do
        for js := 1 to p do

        begin
          j := j + 1; // incremento el índice de columna de MTM
          MTM.pon_e(k, j, series[ks - 1].coefcorr(series[js - 1],
            kcof - jcof, filtrar, umbralFiltro));
        end;

      // ahora calculamos el coeficiente de MTY
      for jj := 1 to p do
        MTY.pon_e(k, jj, series[ks - 1].coefcorr(series[jj - 1], kcof,
          filtrar, umbralFiltro));

    end;
end;
*)

procedure calc_sistema_InfoParcial_(var XXt, XYt, YYt: TMatR;
  series: array of TVectR; orden: integer; filtrar: boolean;
  umbralFiltro: NReal; Normalizar: boolean);

var
  Y, X: TVectR; // una muestra
  NDatos: integer; // cantidad de puntos donde es posible calcular el filtro.
  NSeries: integer;
  dim: integer;
  cnt_muestras, cnt_filtrados: integer;
  kMuestra: integer;
  kFil, jCol: integer;
  a: NReal;
  cnt_XXt, cnt_XYt, cnt_YYt: TMatE;

  procedure LlenarMuestra(kMuestra: integer);
  var
    jserie: integer;
    kretardo: integer;
    m: nreal;
  begin
    for kretardo := 1 to orden do
      for jserie := 1 to NSeries do
      begin
        m := series[jserie - 1].pv[kMuestra + orden - kretardo];
        X.pon_e((kretardo - 1) * NSeries + jserie, m);
      end;

    for jserie := 1 to NSeries do
    begin
      m := series[jserie - 1].pv[kMuestra + orden];
      Y.pon_e(jserie, m);
    end;
  end;

  procedure acum_filt_cnt(k, j: integer; var cntM: TMatE;
    v: TMatR; a, b: NReal);
  begin
    if (not filtrar) or ((a > umbralFiltro) and (b > umbralFiltro)) then
    begin
      cntM.acum_e(k, j, 1);
      v.acum_e(k, j, a * b);
    end;
  end;

begin
  NSeries := length(series);
  NDatos := series[0].n - orden; // largo de las series de datos
  dim := NSeries * orden;
  X := TVectR.Create_init(dim);
  Y := TVectR.Create_init(NSeries);

  XXt := TMatR.Create_Init(dim, dim);
  XYt := TMatR.Create_Init(dim, NSeries);
  YYt := TMatR.Create_Init(NSeries, NSeries);

  cnt_XXt := TMatE.Create_Init(dim, dim);
  cnt_XYt := TMatE.Create_init(dim, NSeries);
  cnt_YYt := TMatE.Create_init(NSeries, NSeries);

  cnt_muestras := 0;
  cnt_filtrados := 0;

  for kMuestra := 1 to NDatos do
  begin
    LlenarMuestra(kMuestra);
    Inc(cnt_muestras);
    for kFil := 1 to Dim do
    begin
      a := X.e(kFil);
      if (not filtrar) or (a > umbralFiltro) then
      begin
        for jCol := kFil to Dim do
          acum_filt_cnt(kFil, jCol, cnt_XXt, XXt, a, X.e(jCol));
        for jCol := 1 to NSeries do
          acum_filt_cnt(kFil, jCol, cnt_XYt, XYt, a, Y.e(jCol));
      end;
    end;

    // llenamos YYt
    for kFil := 1 to NSeries do
    begin
      a := Y.e(kFil);
      if (not filtrar) or (a > umbralFiltro) then
        for jCol := kFil to NSeries do
          acum_filt_cnt(kFil, jCOl, cnt_YYt, YYt, a, Y.e(jCol));
    end;
  end;

  // promedios
  for kFil := 1 to Dim do
  begin
    for jCol := kFil to Dim do
      XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / cnt_XXt.e(kFil, jCol));
    for jCol := 1 to NSeries do
      XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / cnt_XYt.e(kFil, jCol));
  end;
  for kFil := 1 to NSeries do
    for jCol := kFil to NSeries do
      YYt.pon_e(kFil, jCOl, YYt.e(kFil, jCol) / cnt_YYt.e(kFil, jCol));

  if Normalizar then
  begin
    // bueno si está marcado NORMALIZAR, las diagonales de XXt e YYt tienen que
    // ser 1s (unos )
    // Calculo en X e Y las respectivas desviaciones estándar.
    for kFil := 1 to Dim do
      X.pon_e(kFil, sqrt(XXt.e(kFil, kFil)));
    for kFil := 1 to NSeries do
      Y.pon_e(kFil, sqrt(YYt.e(kFil, kFil)));

    // ahora dividimos por las desviaciones estándar.
    for kFil := 1 to Dim do
    begin
      for jCol := kFil to Dim do
        XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / (X.e(kFil) * X.e(jCol)));
      for jCol := 1 to NSeries do
        XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / (X.e(kFil) * Y.e(jCOl)));
    end;

    for kFil := 1 to NSeries do
      for jCol := kFil to NSeries do
        YYt.pon_e(kFil, jCol, YYt.e(kFil, jCol) / (Y.e(kFil) * Y.e(jCol)));
  end;

  // completamos los triángulos inferiores de XXt e YYt
  for kFil := 2 to Dim do
    for jCol := 1 to kFil - 1 do
      XXt.pon_e(kFil, jCol, XXt.e(jCol, kFil));

  for kFil := 2 to NSeries do
    for jCol := 1 to kFil - 1 do
      YYt.pon_e(kFil, jCol, YYt.e(jCol, kFil));


  Y.Free;
  X.Free;

  cnt_XXt.Free;
  cnt_XYt.Free;
  cnt_YYt.Free;
end;

procedure calc_sistema(var XXt, XYt, YYt: TMatR; series: array of TVectR;
  orden: integer; filtrar: boolean; umbralFiltro: NReal; Normalizar: boolean);

var
  Y, X: TVectR; // una muestra
  NDatos: integer; // cantidad de puntos donde es posible calcular el filtro.
  NSeries: integer;
  dim: integer;
  cnt_muestras, cnt_filtrados: integer;
  kMuestra: integer;
  kFil, jCol: integer;


  function LlenarMuestra(kMuestra: integer): boolean;
  var
    jserie: integer;
    kretardo: integer;
    m: NReal;
    res: boolean;
  begin
    res := True;
    for kretardo := 1 to orden do
      for jserie := 1 to NSeries do
      begin
        m := series[jserie - 1].pv[kMuestra + orden - kretardo];
        if filtrar then
          res := res and (m > umbralFiltro);
        X.pon_e((kretardo - 1) * NSeries + jserie, m);
      end;

    for jserie := 1 to NSeries do
    begin
      m := series[jserie - 1].pv[kMuestra + orden];
      if filtrar then
        res := res and (m > umbralFiltro);
      Y.pon_e(jserie, m);
    end;
    Result := res;
  end;

begin
  NSeries := length(series);
  NDatos := series[0].n - orden; // largo de las series de datos
  dim := NSeries * orden;
  X := TVectR.Create_init(dim);
  Y := TVectR.Create_init(NSeries);

  XXt := TMatR.Create_Init(dim, dim);
  XYt := TMatR.Create_Init(dim, NSeries);
  YYt := TMatR.Create_Init(NSeries, NSeries);

  cnt_muestras := 0;
  cnt_filtrados := 0;

  for kMuestra := 1 to NDatos do
  begin
    if LlenarMuestra(kMuestra) then
    begin
      Inc(cnt_muestras);
      for kFil := 1 to Dim do
      begin
        for jCol := kFil to Dim do
          XXt.acum_e(kFil, jCol, X.e(kFil) * X.e(jCol));
        for jCol := 1 to NSeries do
          XYt.acum_e(kFil, jCol, X.e(kFil) * Y.e(jCol));
      end;

      // llenamos YYt
      for kFil := 1 to NSeries do
        for jCol := kFil to NSeries do
          YYt.acum_e(kFil, jCol, Y.e(kFil) * Y.e(jCol));
    end
    else
      Inc(cnt_filtrados);
  end;

  // promedios
  for kFil := 1 to Dim do
  begin
    for jCol := kFil to Dim do
      XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / cnt_Muestras);
    for jCol := 1 to NSeries do
      XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / cnt_Muestras);
  end;
  for kFil := 1 to NSeries do
    for jCol := kFil to NSeries do
      YYt.pon_e(kFil, jCOl, YYt.e(kFil, jCol) / cnt_Muestras);

  if Normalizar then
  begin
    // bueno si está marcado NORMALIZAR, las diagonales de XXt e YYt tienen que
    // ser 1s (unos )
    // Calculo en X e Y las respectivas desviaciones estándar.
    for kFil := 1 to Dim do
      X.pon_e(kFil, sqrt(XXt.e(kFil, kFil)));
    for kFil := 1 to NSeries do
      Y.pon_e(kFil, sqrt(YYt.e(kFil, kFil)));

    // ahora dividimos por las desviaciones estándar.
    for kFil := 1 to Dim do
    begin
      for jCol := kFil to Dim do
        XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / (X.e(kFil) * X.e(jCol)));
      for jCol := 1 to NSeries do
        XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / (X.e(kFil) * Y.e(jCOl)));
    end;

    for kFil := 1 to NSeries do
      for jCol := kFil to NSeries do
        YYt.pon_e(kFil, jCol, YYt.e(kFil, jCol) / (Y.e(kFil) * Y.e(jCol)));
  end;

  // completamos los triángulos inferiores de XXt e YYt
  for kFil := 2 to Dim do
    for jCol := 1 to kFil - 1 do
      XXt.pon_e(kFil, jCol, XXt.e(jCol, kFil));

  for kFil := 2 to NSeries do
    for jCol := 1 to kFil - 1 do
      YYt.pon_e(kFil, jCol, YYt.e(jCol, kFil));


  Y.Free;
  X.Free;

end;



// Calcula las matrices XXt, XYt, YYt corresponidentes para la resolución del
// problema lineal Y[k] = sum( h= 0 to NRetardos; A[h] X[k-h]+ B Rk )
procedure calc_sistema_Y_AX_B_InfoParcial_(var XXt, XYt, YYt: TMatR;
  seriesY, seriesX: array of TVectR; nRetardos: integer; filtrar: boolean;
  umbralFiltro: NReal; Normalizar: boolean);

var
  Y, X: TVectR; // una muestra
  NDatos: integer; // cantidad de puntos donde es posible calcular el filtro.
  NSeriesX, NSeriesY: integer;
  dim: integer;
  cnt_muestras, cnt_filtrados: integer;
  kMuestra: integer;
  kFil, jCol: integer;
  a: NReal;
  orden: integer;
  cnt_XXt, cnt_XYt, cnt_YYt: TMatE;

  procedure LlenarMuestra(kMuestra: integer);
  var
    jserie: integer;
    kretardo: integer;
    m: nreal;
  begin

    for kretardo := 0 to nRetardos do
      for jserie := 1 to NSeriesX do
      begin
        m := seriesX[jserie - 1].pv[kMuestra + nRetardos - kretardo];
        X.pon_e(kretardo * NSeriesX + jserie, m);
      end;

    for jserie := 1 to NSeriesY do
    begin
      m := seriesY[jserie - 1].pv[kMuestra + nRetardos];
      Y.pon_e(jserie, m);
    end;
  end;

  procedure acum_filt_cnt(k, j: integer; var cntM: TMatE;
    v: TMatR; a, b: NReal);
  begin
    if (not filtrar) or ((a > umbralFiltro) and (b > umbralFiltro)) then
    begin
      cntM.acum_e(k, j, 1);
      v.acum_e(k, j, a * b);
    end;
  end;

begin
  orden := NRetardos + 1;
  NSeriesX := length(seriesX);
  NseriesY := length(SeriesY);
  NDatos := seriesX[0].n - nRetardos; // largo de las series de datos
  dim := NSeriesX * orden;
  X := TVectR.Create_init(dim);
  Y := TVectR.Create_init(NSeriesY);

  XXt := TMatR.Create_Init(dim, dim);
  XYt := TMatR.Create_Init(dim, NSeriesY);
  YYt := TMatR.Create_Init(NSeriesY, NSeriesY);

  cnt_XXt := TMatE.Create_Init(dim, dim);
  cnt_XYt := TMatE.Create_init(dim, NSeriesY);
  cnt_YYt := TMatE.Create_init(NSeriesY, NSeriesY);

  cnt_muestras := 0;
  cnt_filtrados := 0;

  for kMuestra := 1 to NDatos do
  begin
    LlenarMuestra(kMuestra);
    Inc(cnt_muestras);
    for kFil := 1 to Dim do
    begin
      a := X.e(kFil);
      if (not filtrar) or (a > umbralFiltro) then
      begin
        for jCol := kFil to Dim do
          acum_filt_cnt(kFil, jCol, cnt_XXt, XXt, a, X.e(jCol));
        for jCol := 1 to NSeriesY do
          acum_filt_cnt(kFil, jCol, cnt_XYt, XYt, a, Y.e(jCol));
      end;
    end;

    // llenamos YYt
    for kFil := 1 to NSeriesY do
    begin
      a := Y.e(kFil);
      if (not filtrar) or (a > umbralFiltro) then
        for jCol := kFil to NSeriesY do
          acum_filt_cnt(kFil, jCOl, cnt_YYt, YYt, a, Y.e(jCol));
    end;
  end;

  // promedios
  for kFil := 1 to Dim do
  begin
    for jCol := kFil to Dim do
      XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / cnt_XXt.e(kFil, jCol));
    for jCol := 1 to NSeriesY do
      XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / cnt_XYt.e(kFil, jCol));
  end;
  for kFil := 1 to NSeriesY do
    for jCol := kFil to NSeriesY do
      YYt.pon_e(kFil, jCOl, YYt.e(kFil, jCol) / cnt_YYt.e(kFil, jCol));

  if Normalizar then
  begin
    // bueno si está marcado NORMALIZAR, las diagonales de XXt e YYt tienen que
    // ser 1s (unos )
    // Calculo en X e Y las respectivas desviaciones estándar.
    for kFil := 1 to Dim do
      X.pon_e(kFil, sqrt(XXt.e(kFil, kFil)));
    for kFil := 1 to NSeriesY do
      Y.pon_e(kFil, sqrt(YYt.e(kFil, kFil)));

    // ahora dividimos por las desviaciones estándar.
    for kFil := 1 to Dim do
    begin
      for jCol := kFil to Dim do
        XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / (X.e(kFil) * X.e(jCol)));
      for jCol := 1 to NSeriesY do
        XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / (X.e(kFil) * Y.e(jCOl)));
    end;

    for kFil := 1 to NSeriesY do
      for jCol := kFil to NSeriesY do
        YYt.pon_e(kFil, jCol, YYt.e(kFil, jCol) / (Y.e(kFil) * Y.e(jCol)));
  end;

  // completamos los triángulos inferiores de XXt e YYt
  for kFil := 2 to Dim do
    for jCol := 1 to kFil - 1 do
      XXt.pon_e(kFil, jCol, XXt.e(jCol, kFil));

  for kFil := 2 to NSeriesY do
    for jCol := 1 to kFil - 1 do
      YYt.pon_e(kFil, jCol, YYt.e(jCol, kFil));


  Y.Free;
  X.Free;

  cnt_XXt.Free;
  cnt_XYt.Free;
  cnt_YYt.Free;
end;



function calcmincuad_mrh(series: array of TVectR; orden: integer;
  filtrar: boolean; umbralFiltro: NReal; flg_InfoParcial: boolean; var BBt: TMatR): TMatR;
var
  XXt, XYt, YYt, YXt: TMatR;
  invertible: boolean;
  k, j, h, jRet: integer;
  e10: integer;

begin
  if flg_InfoParcial then
    calc_sistema_InfoParcial_(XXt, XYt, YYt, series, orden, filtrar, umbralFiltro, True)
  else
    calc_sistema(XXt, XYt, YYt, series, orden, filtrar, umbralFiltro, True);

  XXt.WriteArchiXLT('Matriz_XXt.xlt');

  YXt := XYt.crear_transpuesta;

  XXt.Escaler(XYt, invertible, e10); // At
  if not invertible then
  begin
    raise Exception.Create('CalcMinCuad ... error. el sistema no es invertible.');
  end;
  BBt := TMatR.Create_Init(length(series), length(series));
  // Y = AX + B R
  // YYt = A XXt At + BBt => BBt = YYt - A XXt At
  // YXt = A XXt => BBt = YYt - YXt * At

  BBt.Mult(YXt, XYt);
  BBt.PorReal(-1);
  BBt.suma(BBt, YYt);

  YYt.Free;
  YXt.Free;
  XXt.Free;
  Result := XYt;
end;



function calcmincuad_mrh_Y_AX_B(const seriesY, SeriesX: array of TVectR;
  nretardos: integer; filtrar: boolean; umbralFiltro: NReal; var BBt: TMatR): TMatR;
var
  XXt, XYt, YYt, YXt: TMatR;
  invertible: boolean;
  k, j, h, jRet: integer;
  e10: integer;

begin
  calc_sistema_Y_AX_B_InfoParcial_(
    XXt, XYt, YYt, seriesY, seriesX, nRetardos, filtrar, umbralFiltro,
    True);

  XXt.WriteArchiXLT('Matriz_XXt.xlt');
  XYt.WriteArchiXLT('Matriz_XYt.xlt');

  YXt := XYt.crear_transpuesta;


  XXt.Escaler(XYt, invertible, e10); // At
  if not invertible then
  begin
    raise Exception.Create('CalcMinCuad ... error. el sistema no es invertible.');
  end;
  BBt := TMatR.Create_Init(length(seriesY), length(seriesY));
  // Y = AX + B R
  // YYt = A XXt At + BBt => BBt = YYt - A XXt At
  // YXt = A XXt => BBt = YYt - YXt * At

  BBt.Mult(YXt, XYt);
  BBt.PorReal(-1);
  BBt.suma(BBt, YYt);

  YYt.Free;
  YXt.Free;
  XXt.Free;
  Result := XYt;
end;



(***********
Cálculo de las matrices MTM y MTY del sistema MTM . A = MTY para
el paso kPaso del racimo de vectores (series) pasado como parámetros,
considerando que dichas series forman ciclos de nPasosPorCiclo.
kPaso puede tomar valores en [0..nPasosPorCiclo-1]

Para la formación de las matrices se considera el perámetro overlapping

El el orden del filtro es la cantidad de pasos del pasado considerado
para cada serie.
si p es el número de series,
dim= orden* p
La matriz MTM es de [dim x dim ]
Las matrices A  y MTY son de [dim x p]

Y = A X * B R

YYt es la matriz
 MTM = XXt

Si el parámetro Normalizar es true se está indicando que las series
se suponen ergodizadas y de norma 1 y como el Multi-Ciclo puede hacer
que se "rompa la normalidad" se debe recomponer sobre las matrices de cálculo.
***********)

(*
procedure calc_sistema_MultiCiclo(
  var MTM: TMatR; var MTY: TMatR;
  var YYt: TMatR;
  series: array of TVectR; orden: integer; filtrar: boolean;
  umbralFiltro: NReal;
  kPaso: integer; nPasosPorCiclo: integer;
  overlapping: integer; Normalizar: boolean);
var
  k, j: integer;
  NSeries:    integer;
  k_serie, k_retardo: integer;
  j_serie, j_retardo: integer;
  dim:  integer;
  jj:   integer;
  cnt_muestras: integer;
begin

  NSeries  := length(series);
  dim := NSeries * orden;

  MTM := TMatR.Create_Init(dim, dim);
  MTY := TMatR.Create_Init(dim, NSeries );
  YYt := TMatR.Create_Init( NSeries, NSeries );

  k := 0; // inicializo el índice de fila
  for k_retardo := 1 to orden do
  begin
    for k_serie := 1 to NSeries do
    begin
      k := k + 1; // índice de fila

      // cálculo del coeficiente de MTM
      j := 0; //inicializo el índice de columna
      for j_retardo := 1 to orden do
        for j_serie := 1 to NSeries do
        begin
          j := j + 1; // incremento el índice de columna de MTM
          MTM.pon_e(k, j,
            series[k_serie - 1].coefcorr_MultiCiclo(
            series[j_serie - 1],
            k_retardo - j_retardo,
            filtrar, umbralFiltro,
            kPaso, nPasosPorCiclo, overlapping, cnt_muestras, Normalizar,
            'mtm_x'+IntToStr(k_Serie)+'_x'+IntToStr(j_serie)+'_'+IntToSTr( k_retardo-j_retardo)+'_'+IntToStr( kPaso )+'.xlt' ));
          if cnt_muestras = 0 then
            raise Exception.Create(
              'OJO, uregresion.calc_sistema_MultiCiclo; MTM_ cnt_muestras = 0 ');
        end;

      // ahora calculamos el coeficiente de MTY
      for jj := 1 to NSeries do
        MTY.pon_e(k, jj,
          series[k_serie - 1].coefcorr_MultiCiclo(series[jj - 1], k_retardo,
          filtrar, umbralFiltro, kPaso, nPasosPorCiclo, overlapping,
          cnt_muestras, Normalizar,
           'mty_x'+IntToStr(k_Serie)+'_y'+IntToStr(jj)+'_'+IntToSTr( k_retardo )+'_'+IntToStr( kPaso )+'.xlt' ));


        if cnt_muestras = 0 then
        raise Exception.Create(
          'OJO, uregresion.calc_sistema_MultiCiclo; MTY_ cnt_muestras = 0 ');

    end;
  end;

  // ahora calculamos YYt
  for k:= 1 to NSeries do
    for jj := k to NSeries do
    begin
        YYt.pon_e(k, jj,
          series[k - 1].coefcorr_MultiCiclo(
            series[jj - 1],
            0, // kretardo
            filtrar,
            umbralFiltro,
            kPaso +1 ,  // el paso siguiente.
            nPasosPorCiclo,
            overlapping,
            cnt_muestras,
            Normalizar,
           'mty_x'+IntToStr(k_Serie)+'_y'+IntToStr(jj)+'_'+IntToSTr( k_retardo )+'_'+IntToStr( kPaso )+'.xlt' ));

        if jj > k then
          YYt.pon_e( jj, k, YYt.e( k, jj ) );
    end;

end;

*)


function kPos_EnRango( kPos, kPaso, overlapping, traslapping, nPasosPorMiniciclo, NPasosPorCiclo: integer ): boolean;
var
  res: boolean;
  j: integer;
  iPaso: integer;
  dd, dc: integer;
begin
  res:= false;
  for j:= -traslapping to traslapping do
  begin
    iPaso:= kPos + j * nPasosPorMiniciclo;

    while iPaso < 0 do
      iPaso:= iPaso + NPasosPorCiclo;
    while iPaso >= NPasosPorCiclo do
      iPaso:= iPaso - NPasosPorCiclo;

    dd:= abs( iPaso - kPaso );
    dc:= NPasosPorCiclo - dd;
    if  min( dd, dc ) <= overlapping then
    begin
      res:= true;
      break;
    end;
  end;
  result:= res;
end;

procedure calc_sistema_MultiCiclo_InfoParcial(
  var XXt, XYt, YYt: TMatR;
  series: array of TVectR; orden: integer; filtrar: boolean;
  umbralFiltro: NReal; kPaso: integer; r_nPasosPorCiclo, r_OffsetCiclo: NReal;
  overlapping, traslapping, r_nPasosPorMiniCiclo: integer; Normalizar: boolean);

var
  Y, X: TVectR; // una muestra
  NDatos: integer; // cantidad de puntos donde es posible calcular el filtro.
  NSeries: integer;
  dim: integer;
  cnt_muestras, cnt_filtrados: integer;
  kMuestra, kPos: integer;
  kFil, jCol: integer;
  cnt_XXt, cnt_XYt, cnt_YYt: TMatE;
  a: NReal;
  NPasosPorCiclo: integer;

  function LlenarMuestra(kMuestra: integer): boolean;
  var
    jserie: integer;
    kretardo: integer;
    m: NReal;
    res: boolean;
  begin
    res := True;
    for kretardo := 1 to orden do
      for jserie := 1 to NSeries do
      begin
        m := series[jserie - 1].pv[kMuestra + orden - kretardo];
        X.pon_e((kretardo - 1) * NSeries + jserie, m);
      end;

    for jserie := 1 to NSeries do
    begin
      m := series[jserie - 1].pv[kMuestra + orden];
      Y.pon_e(jserie, m);
    end;
  end;


  procedure acum_filt_cnt(k, j: integer; var cntM: TMatE;
    v: TMatR; a, b: NReal);
  begin
    if (not filtrar) or ((a > umbralFiltro) and (b > umbralFiltro)) then
    begin
      cntM.acum_e(k, j, 1);
      v.acum_e(k, j, a * b);
    end;
  end;

begin
  NSeries := length(series);
  NDatos := series[0].n - orden; // largo de las series de datos
  dim := NSeries * orden;
  X := TVectR.Create_init(dim);
  Y := TVectR.Create_init(NSeries);

  XXt := TMatR.Create_Init(dim, dim);
  XYt := TMatR.Create_Init(dim, NSeries);
  YYt := TMatR.Create_Init(NSeries, NSeries);

  cnt_muestras := 0;
  cnt_filtrados := 0;

  cnt_XXt := TMatE.Create_Init(dim, dim);
  cnt_XYt := TMatE.Create_init(dim, NSeries);
  cnt_YYt := TMatE.Create_init(NSeries, NSeries);

  NPasosPorCiclo:= trunc( r_nPasosPorCiclo );

  for kMuestra := 1 to NDatos do
  begin
    kPos := kPasoCiclico(kMuestra, r_nPasosPorCiclo, r_OffsetCiclo) - 1;
    if kPos_EnRango(kPos, kPaso, overlapping, traslapping, r_nPasosPorMiniCiclo, NPasosPorCiclo ) then
    begin
      LlenarMuestra(kMuestra);
      Inc(cnt_muestras);
      for kFil := 1 to Dim do
      begin
        a := X.e(kFil);
        if (not filtrar) or (a > umbralFiltro) then
        begin
          for jCol := kFil to Dim do
            acum_filt_cnt(kfil, jcol, cnt_XXt, XXt, a, X.e(jCol));
          for jCol := 1 to NSeries do
            acum_filt_cnt(kfil, jcol, cnt_XYt, XYt, a, Y.e(jCol));
        end;
      end;

      // llenamos YYt
      for kFil := 1 to NSeries do
      begin
        a := Y.e(kFil);
        for jCol := kFil to NSeries do
          acum_filt_cnt(kfil, jcol, cnt_YYt, YYt, a, Y.e(jCol));
      end;
    end;
  end;


  // promedios
  for kFil := 1 to Dim do
  begin
    for jCol := kFil to Dim do
      XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / cnt_XXt.e(kFil, jCol));
    for jCol := 1 to NSeries do
      XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / cnt_XYt.e(kFil, jCol));
  end;
  for kFil := 1 to NSeries do
    for jCol := kFil to NSeries do
      YYt.pon_e(kFil, jCOl, YYt.e(kFil, jCol) / cnt_YYt.e(kfil, jcol));

  if Normalizar then
  begin
    // bueno si está marcado NORMALIZAR, las diagonales de XXt e YYt tienen que
    // ser 1s (unos )
    // Calculo en X e Y las respectivas desviaciones estándar.
    for kFil := 1 to Dim do
      X.pon_e(kFil, sqrt(XXt.e(kFil, kFil)));
    for kFil := 1 to NSeries do
      Y.pon_e(kFil, sqrt(YYt.e(kFil, kFil)));

    // ahora dividimos por las desviaciones estándar.
    for kFil := 1 to Dim do
    begin
      for jCol := kFil to Dim do
        XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / (X.e(kFil) * X.e(jCol)));
      for jCol := 1 to NSeries do
        XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / (X.e(kFil) * Y.e(jCOl)));
    end;

    for kFil := 1 to NSeries do
      for jCol := kFil to NSeries do
        YYt.pon_e(kFil, jCol, YYt.e(kFil, jCol) / (Y.e(kFil) * Y.e(jCol)));
  end;

  // completamos los triángulos inferiores de XXt e YYt
  for kFil := 2 to Dim do
    for jCol := 1 to kFil - 1 do
      XXt.pon_e(kFil, jCol, XXt.e(jCol, kFil));

  for kFil := 2 to NSeries do
    for jCol := 1 to kFil - 1 do
      YYt.pon_e(kFil, jCol, YYt.e(jCol, kFil));

  cnt_XXt.Free;
  cnt_XYt.Free;
  cnt_YYt.Free;

  Y.Free;
  X.Free;

end;


(*
  dada la matriz A del filtro, calcula BBt pasando las muestras válidas
  por el filtro BBt =  <( Y - A X ) ( Y - A X )t >
*)
function calc_BBt_MultiCiclo_InfoParcial(
  A: TMatR;
  series: array of TVectR; orden: integer; filtrar: boolean;
  umbralFiltro: NReal; kPaso: integer; r_nPasosPorCiclo, r_OffsetCiclo: NReal;
  overlapping, traslapping, r_nPasosPorMiniCiclo: integer ): TMatR;

var
  Y, X, R: TVectR; // una muestra
  NDatos: integer; // cantidad de puntos donde es posible calcular el filtro.
  NSeries: integer;
  dim: integer;
  cnt_muestras, cnt_filtrados: integer;
  kMuestra, kPos: integer;
  kFil, jCol: integer;
  cnt_XXt, cnt_XYt, cnt_YYt: TMatE;
  NPasosPorCiclo: integer;
  BBt: TMatR;
  m: NReal;

  function LlenarMuestra(kMuestra: integer): boolean;
  var
    jserie: integer;
    kretardo: integer;
    m: NReal;
    res: boolean;
  begin
    res := true;
    for kretardo := 1 to orden do
      for jserie := 1 to NSeries do
      begin
        m := series[jserie - 1].pv[kMuestra + orden - kretardo];
        if m < umbralFiltro then
        begin
          res:= false;
          break;
        end;
        X.pon_e((kretardo - 1) * NSeries + jserie, m);
      end;

    if res then
    for jserie := 1 to NSeries do
    begin
      m := series[jserie - 1].pv[kMuestra + orden];
      if m < umbralFiltro then
      begin
        res:= false;
        break;
      end;
      Y.pon_e(jserie, m);
    end;
    result:= res;
  end;


begin
  NSeries := length(series);
  NDatos := series[0].n - orden; // largo de las series de datos
  dim := NSeries * orden;
  X := TVectR.Create_init( dim );
  Y := TVectR.Create_init( NSeries );
  R := TVectR.Create_Init( NSeries );
  BBt := TMatR.Create_Init( NSeries, NSeries );
  cnt_muestras := 0;
  cnt_filtrados := 0;
  BBt.Ceros;

  NPasosPorCiclo:= trunc( r_nPasosPorCiclo );

  for kMuestra := 1 to NDatos do
  begin
    kPos := kPasoCiclico(kMuestra, r_nPasosPorCiclo, r_OffsetCiclo) - 1;
    if kPos_EnRango(kPos, kPaso, overlapping, traslapping, r_nPasosPorMiniCiclo, NPasosPorCiclo ) then
    begin
      if LlenarMuestra(kMuestra) then
      begin
        Inc(cnt_muestras);
        A.Transformar( R, X );
        R.res( Y );
        for kFil := 1 to NSeries do
          for jCol := kFil to NSeries do
            BBt.acum_e( kFil, jCol, R.e(kFil) * R.e(jCol ) );
      end
      else
        inc( cnt_filtrados );
    end;
  end;

  if cnt_Muestras > 0 then
    for kFil := 1 to NSeries do
    begin
      BBt.pon_e( kFil, kFil, BBt.e( kFil, kFil ) / cnt_muestras );
      for jCol := kFil to NSeries do
      begin
        m:= BBt.e( kFil, jCol ) / cnt_muestras;
        BBt.pon_e( kFil, jCol, m );
        BBt.pon_e( jCol, kFil, m );
      end;
    end;

  R.Free;
  Y.Free;
  X.Free;
  result:= BBt;
end;




procedure calc_sistema_MultiCiclo_completarHuecosConRuidoBlanco(var XXt, XYt, YYt: TMatR;
  series: array of TVectR; orden: integer; filtrar: boolean;
  umbralFiltro: NReal; kPaso: integer; r_nPasosPorCiclo, r_OffsetCiclo: NReal;
  overlapping, traslapping, r_nPasosPorMiniCiclo: integer; Normalizar: boolean );

var
  hueco_X, hueco_Y: TVectE;
  Y, X: TVectR; // una muestra
  NDatos: integer; // cantidad de puntos donde es posible calcular el filtro.
  NSeries: integer;
  dim: integer;
  cnt_muestras: integer;
  kMuestra, kPos: integer;
  kFil, jCol: integer;
  iserie: integer;
  {$IFDEF SISMC_DUMP_MUESTRAS}
  f: textfile;
  {$ENDIF}
  NPasosPorCiclo: integer;

  procedure LlenarMuestra(kMuestra: integer);
  var
    jserie: integer;
    kretardo: integer;
    m: NReal;
  begin
    hueco_x.Ceros; hueco_y.Ceros;

    for kretardo := 1 to orden do
      for jserie := 1 to NSeries do
      begin
        m := series[jserie - 1].pv[kMuestra + orden - kretardo];
        if filtrar and (m <= umbralFiltro) then
           hueco_x.pon_e((kretardo - 1) * NSeries + jserie, 1);
        X.pon_e((kretardo - 1) * NSeries + jserie, m);
      end;

    for jserie := 1 to NSeries do
    begin
      m := series[jserie - 1].pv[kMuestra + orden];
      if filtrar and (m <= umbralFiltro) then hueco_y.pon_e( jserie, 1 );
      Y.pon_e(jserie, m);
    end;
  end;

begin

  {$IFDEF SISMC_DUMP_MUESTRAS}
      end;
  begin
    assignfile( f, 'fmuestras_kPaso_'+IntToStr(kPaso)+'.xlt' );
    rewrite( f );
    writeln( f, 'kMuestra', 'Valor', 'Usada' );
  end;
  {$ENDIF}

  NSeries := length(series);
  NDatos := series[0].n - orden; // largo de las series de datos
  dim := NSeries * orden;
  X := TVectR.Create_init(dim);
  Y := TVectR.Create_init(NSeries);

  hueco_X:= TVectE.Create_init( X.n );
  hueco_Y:= TVectE.Create_init( Y.n );


  XXt := TMatR.Create_Init(dim, dim);
  XYt := TMatR.Create_Init(dim, NSeries);
  YYt := TMatR.Create_Init(NSeries, NSeries);

  cnt_muestras := 0;

  for kMuestra := 1 to NDatos do
  begin
    kPos := kPasoCiclico(kMuestra, r_nPasosPorCiclo, r_OffsetCiclo) - 1;

    NPasosPorCiclo:= trunc( r_nPasosPorCiclo );
    if kPos_EnRango(kPos, kPaso, overlapping, traslapping, r_nPasosPorMiniCiclo, NPasosPorCiclo ) then
    begin
      {$IFDEF SISMC_DUMP_MUESTRAS}
      if flg_dump_muestras then
      begin
        write( f, kMuestra, #9, 1, #9, kPos );
        for iserie:= 0 to high( series )  do
           write( f, #9, series[iserie].e( kMuestra ) );
        writeln(f);
      end;
      {$ENDIF}

       LlenarMuestra(kMuestra);
       Inc(cnt_muestras);

        for kFil := 1 to Dim do
        begin
          if hueco_x.e( kFil ) = 1 then
            XXt.acum_e(kFil, kFil, 1)
          else
          begin
            for jCol := kFil to Dim do
              if hueco_x.e( jCol ) = 0 then
                XXt.acum_e(kFil, jCol, X.e(kFil) * X.e(jCol));

            for jCol := 1 to NSeries do
              if hueco_y.e( jCol ) = 0 then
                XYt.acum_e(kFil, jCol, X.e(kFil) * Y.e(jCol));
          end;
        end;

        // llenamos YYt
        for kFil := 1 to NSeries do
         begin
           if hueco_y.e( kfil ) = 1 then
             YYt.acum_e( kfil, kfil, 1 )
          else
          for jCol := kFil to NSeries do
             if hueco_y.e( jCol ) = 0 then
               YYt.acum_e(kFil, jCol, Y.e(kFil) * Y.e(jCol));
         end;
    end
    else
    {$IFDEF SISMC_DUMP_MUESTRAS}
      if flg_dump_muestras then
      begin
        write( f, kMuestra, #9, 0, #9, kPos );
        for iserie:= 0 to high( series )  do
           write( f, #9, series[iserie].e( kMuestra ) );
        writeln( f );
      end
     {$ENDIF}
     ;
  end;

  if cnt_Muestras < 1 then
    raise Exception.Create( 'No hay muestras suficientes para calcular el paso: '+INtTOStr( kPaso ) );

  // promedios
  for kFil := 1 to Dim do
  begin
    for jCol := kFil to Dim do
      XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / cnt_Muestras);
    for jCol := 1 to NSeries do
      XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / cnt_Muestras);
  end;
  for kFil := 1 to NSeries do
    for jCol := kFil to NSeries do
      YYt.pon_e(kFil, jCOl, YYt.e(kFil, jCol) / cnt_Muestras);


  if Normalizar then
  begin
    // bueno si está marcado NORMALIZAR, las diagonales de XXt e YYt tienen que
    // ser 1s (unos )
    // Calculo en X e Y las respectivas desviaciones estándar.
    for kFil := 1 to Dim do
      X.pon_e(kFil, sqrt(XXt.e(kFil, kFil)));
    for kFil := 1 to NSeries do
      Y.pon_e(kFil, sqrt(YYt.e(kFil, kFil)));

    // ahora dividimos por las desviaciones estándar.
    for kFil := 1 to Dim do
    begin
      for jCol := kFil to Dim do
        XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / (X.e(kFil) * X.e(jCol)));
      for jCol := 1 to NSeries do
        XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / (X.e(kFil) * Y.e(jCOl)));
    end;

    for kFil := 1 to NSeries do
      for jCol := kFil to NSeries do
        YYt.pon_e(kFil, jCol, YYt.e(kFil, jCol) / (Y.e(kFil) * Y.e(jCol)));
  end;


  // completamos los triángulos inferiores de XXt e YYt
  for kFil := 2 to Dim do
    for jCol := 1 to kFil - 1 do
      XXt.pon_e(kFil, jCol, XXt.e(jCol, kFil));

  for kFil := 2 to NSeries do
    for jCol := 1 to kFil - 1 do
      YYt.pon_e(kFil, jCol, YYt.e(jCol, kFil));

  Y.Free;
  X.Free;

  hueco_x.Free;
  hueco_y.Free;
  {$IFDEF SISMC_DUMP_MUESTRAS}
  if flg_dump_muestras then
     CloseFile(f );
  {$ENDIF}

end;




procedure calc_sistema_MultiCiclo(var XXt, XYt, YYt: TMatR;
  series: array of TVectR; orden: integer; filtrar: boolean;
  umbralFiltro: NReal; kPaso: integer; r_nPasosPorCiclo, r_OffsetCiclo: NReal;
  overlapping, traslapping, r_nPasosPorMiniCiclo: integer; Normalizar: boolean );

var
  Y, X: TVectR; // una muestra
  NDatos: integer; // cantidad de puntos donde es posible calcular el filtro.
  NSeries: integer;
  dim: integer;
  cnt_muestras, cnt_filtrados: integer;
  kMuestra, kPos: integer;
  kFil, jCol: integer;
  iserie: integer;
  {$IFDEF SISMC_DUMP_MUESTRAS}
  f: textfile;
  {$ENDIF}
  NPasosPorCiclo: integer;

  function LlenarMuestra(kMuestra: integer): boolean;
  var
    jserie: integer;
    kretardo: integer;
    m: NReal;
    res: boolean;
  begin
    res := True;
    for kretardo := 1 to orden do
      for jserie := 1 to NSeries do
      begin
        m := series[jserie - 1].pv[kMuestra + orden - kretardo];
        if filtrar then
          res := res and (m > umbralFiltro);
        X.pon_e((kretardo - 1) * NSeries + jserie, m);
      end;

    for jserie := 1 to NSeries do
    begin
      m := series[jserie - 1].pv[kMuestra + orden];
      if filtrar then
        res := res and (m > umbralFiltro);
      Y.pon_e(jserie, m);
    end;
    Result := res;
  end;

begin


  {$IFDEF SISMC_DUMP_MUESTRAS}
  begin
    assignfile( f, 'fmuestras_kPaso_'+IntToStr(kPaso)+'.xlt' );
    rewrite( f );
    writeln( f, 'kMuestra', 'Valor', 'Usada' );
  end;
  {$ENDIF}

  NSeries := length(series);
  NDatos := series[0].n - orden; // largo de las series de datos
  dim := NSeries * orden;
  X := TVectR.Create_init(dim);
  Y := TVectR.Create_init(NSeries);

  XXt := TMatR.Create_Init(dim, dim);
  XYt := TMatR.Create_Init(dim, NSeries);
  YYt := TMatR.Create_Init(NSeries, NSeries);

  cnt_muestras := 0;
  cnt_filtrados := 0;

  for kMuestra := 1 to NDatos do
  begin
    kPos := kPasoCiclico(kMuestra, r_nPasosPorCiclo, r_OffsetCiclo) - 1;

    NPasosPorCiclo:= trunc( r_nPasosPorCiclo );
    if kPos_EnRango(kPos, kPaso, overlapping, traslapping, r_nPasosPorMiniCiclo, NPasosPorCiclo ) then
    begin
      {$IFDEF SISMC_DUMP_MUESTRAS}
      if flg_dump_muestras then
      begin
        write( f, kMuestra, #9, 1, #9, kPos );
        for iserie:= 0 to high( series )  do
           write( f, #9, series[iserie].e( kMuestra ) );
        writeln(f);
      end;
      {$ENDIF}
      if LlenarMuestra(kMuestra) then
      begin
        Inc(cnt_muestras);
        for kFil := 1 to Dim do
        begin
          for jCol := kFil to Dim do
            XXt.acum_e(kFil, jCol, X.e(kFil) * X.e(jCol));
          for jCol := 1 to NSeries do
            XYt.acum_e(kFil, jCol, X.e(kFil) * Y.e(jCol));
        end;

        // llenamos YYt
        for kFil := 1 to NSeries do
          for jCol := kFil to NSeries do
            YYt.acum_e(kFil, jCol, Y.e(kFil) * Y.e(jCol));
      end
      else
        Inc(cnt_filtrados);
    end
    else
    {$IFDEF SISMC_DUMP_MUESTRAS}
      if flg_dump_muestras then
      begin
        write( f, kMuestra, #9, 0, #9, kPos );
        for iserie:= 0 to high( series )  do
           write( f, #9, series[iserie].e( kMuestra ) );
        writeln( f );
      end
     {$ENDIF}
     ;
  end;

  if cnt_Muestras < 1 then
    raise Exception.Create( 'No hay muestras suficientes para calcular el paso: '+INtTOStr( kPaso ) );

  // promedios
  for kFil := 1 to Dim do
  begin
    for jCol := kFil to Dim do
      XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / cnt_Muestras);
    for jCol := 1 to NSeries do
      XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / cnt_Muestras);
  end;
  for kFil := 1 to NSeries do
    for jCol := kFil to NSeries do
      YYt.pon_e(kFil, jCOl, YYt.e(kFil, jCol) / cnt_Muestras);

  if Normalizar then
  begin
    // bueno si está marcado NORMALIZAR, las diagonales de XXt e YYt tienen que
    // ser 1s (unos )
    // Calculo en X e Y las respectivas desviaciones estándar.
    for kFil := 1 to Dim do
      X.pon_e(kFil, sqrt(XXt.e(kFil, kFil)));
    for kFil := 1 to NSeries do
      Y.pon_e(kFil, sqrt(YYt.e(kFil, kFil)));

    // ahora dividimos por las desviaciones estándar.
    for kFil := 1 to Dim do
    begin
      for jCol := kFil to Dim do
        XXt.pon_e(kFil, jCol, XXt.e(kFil, jCol) / (X.e(kFil) * X.e(jCol)));
      for jCol := 1 to NSeries do
        XYt.pon_e(kFil, jCol, XYt.e(kFil, jCol) / (X.e(kFil) * Y.e(jCOl)));
    end;

    for kFil := 1 to NSeries do
      for jCol := kFil to NSeries do
        YYt.pon_e(kFil, jCol, YYt.e(kFil, jCol) / (Y.e(kFil) * Y.e(jCol)));
  end;

  // completamos los triángulos inferiores de XXt e YYt
  for kFil := 2 to Dim do
    for jCol := 1 to kFil - 1 do
      XXt.pon_e(kFil, jCol, XXt.e(jCol, kFil));

  for kFil := 2 to NSeries do
    for jCol := 1 to kFil - 1 do
      YYt.pon_e(kFil, jCol, YYt.e(jCol, kFil));

  Y.Free;
  X.Free;

  {$IFDEF SISMC_DUMP_MUESTRAS}
  if flg_dump_muestras then
     CloseFile(f );
  {$ENDIF}
end;


function calcmincuad_mrh_mc(series_X: array of TVectR; orden: integer;
  filtrar: boolean; umbralFiltro: NReal; r_nPasosPorCiclo,
  r_OffesetCiclo: NReal; overlapping, traslapping, nPasosPorMiniCiclo: integer;
  var mcA, mcB: TDAOfMatR; Normalizar: boolean; series_Nombres: TStringList;
  flg_InfoParcial: boolean; flg_CompletarHuecosConRuidoBlanco: boolean;
  var VarNoExplicado: NReal): TVectR;

var
  //  mXX0,
  mYXt, mBBt, mYYt: TMatR;
  mXXt, mXYt: TMatR;

  kPaso: integer;
  invertible: boolean;
  cnt_fallos: integer;
  k, j: integer;

  sal: TextFile;
  kFil, jCol: integer;
  e10: integer;
  nPasosPorCiclo_: integer;
  res: TVectR;
  NPasos: integer;
  kSerie: integer;
  dimRes: integer;
begin

  nPasosPorCiclo_ := trunc(r_nPasosPorCiclo);
  setlength(mcA, nPasosPorCiclo_);
  setlength(mcB, nPasosPorCiclo_);

  cnt_fallos := 0;
  VarNoExplicado := 0;

  NPasos:= length( mcA );

  assignfile(sal, 'covarianzas_XX0.xlt');
  rewrite(sal);

  Write(sal, '-');
  if series_Nombres <> nil then
  begin
    for k := 0 to Series_NOmbres.Count - 1 do
      for j := 0 to Series_NOmbres.Count - 1 do
        if j >= k then
          Write(sal, #9, Series_Nombres[k] + '-' + Series_Nombres[j]);
    writeln(sal);
  end;

  res := TVectR.Create_INit( length( series_X ) );
  res.Ceros;

  for kPaso := 0 to NPasos-1  do
  begin
    if flg_CompletarHuecosConRuidoBlanco then
    calc_sistema_MultiCiclo_completarHuecosConRuidoBlanco(
      mXXt, mXYt, mYYt,
      series_X, orden, filtrar, umbralFiltro,
      kPaso, r_nPasosPorCiclo, r_OffesetCiclo, overlapping, traslapping, nPasosPorMiniCiclo, Normalizar)
    else if flg_InfoParcial then
    calc_sistema_MultiCiclo_InfoParcial(
      mXXt, mXYt, mYYt,
      series_X, orden, filtrar, umbralFiltro,
      kPaso, r_nPasosPorCiclo, r_OffesetCiclo, overlapping, traslapping, nPasosPorMiniCiclo, Normalizar)
    else
    calc_sistema_MultiCiclo(
      mXXt, mXYt, mYYt,
      series_X, orden, filtrar, umbralFiltro,
      kPaso, r_nPasosPorCiclo, r_OffesetCiclo, overlapping, traslapping, nPasosPorMiniCiclo, Normalizar );

    writeln( 'kPaso: ', kPaso );
    Write(sal, kPaso);
    for kFil := 1 to mXXt.nf do
      for jCol := kFil to mXXt.nc do
        Write(sal, #9, mXXt.e(kFil, jCol));
    writeln(sal);

    (*
    mXXt.WriteArchiXLT('mxxt_' + IntToStr(kPaso) + '.xlt');
    mXYt.WriteArchiXLT('mxyt_' + IntToStr(kPaso) + '.xlt');
    mYYt.WriteArchiXLT('myyt_' + IntToStr(kPaso) + '.xlt');
      *)

    mYXt := mXYt.crear_transpuesta;

    mXXt.Escaler(mXYt, invertible, e10);
    if not invertible then
    begin
      Inc(cnt_fallos);
      mcA[kPaso] := nil;
      mcB[kPaso] := nil;
      mYYt.Free;
      mYXt.Free;
      mXYt.Free;
      mXXt.Free;
    end
    else
    begin

      if ( not flg_CompletarHuecosConRuidoBlanco ) and flg_InfoParcial then
      begin
        mXYt.transponer;
        mcA[kPaso] := mXYt;
        mBBt:= calc_BBt_MultiCiclo_InfoParcial(  mcA[kPaso],
      series_X, orden, filtrar, umbralFiltro,
      kPaso, r_nPasosPorCiclo, r_OffesetCiclo, overlapping, traslapping, nPasosPorMiniCiclo )
      end
      else
      begin
        mBBt := TMatR.Create_Init(length(Series_X), length(Series_X));
        // Y = AX + B R
        // YYt = A XXt At + BBt => BBt = YYt - A XXt At
        // YXt = A XXt => BBt = YYt - YXt * At
        mBBt.Mult(mYXt, mXYt);
        mBBt.PorReal(-1);
        mBBt.suma(mBBt, mYYt);
        mXYt.transponer;
        mcA[kPaso] := mXYt;
      end;


      for kSerie := 1 to res.n do
          res.acum_e( kSerie, mBBt.e(kSerie, kSerie));

      VarNoExplicado := VarNoExplicado + mBBt.Traza;

      mcB[kPaso] := mBBt.raiz_Cholesky;
      if mcB[kPaso] = nil then
      begin
        mcB[kPaso] := mBBt.RaizPorPotenciaIterada( dimRes, false );
        if dimRes < 0 then
        begin
           mBBt.WriteArchiXLT('bbt_autovalneg_'+IntToStr( kPaso )+'.xlt' );
           writeln( 'Ojo ... imposiblre raíz de bbt en paso: '+IntToStr( kPaso ) );
        end;
        mBBt.Free;
      end;

      if mcB[kPaso] = nil then
        Inc(cnt_fallos);
      mXXt.Free;
    end;
  end;
  closefile(sal);

  if cnt_fallos = 0 then
  begin
    VarNoExplicado := VarNoExplicado / length(Series_X) / NPasos;
    res.PorReal( 1/ NPasos);
  end
  else
  begin
    VarNoExplicado := -1;
    res.Free;
    res:= nil;
  end;
  Result := res;
end;


end.



















