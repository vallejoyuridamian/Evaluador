unit uuniformizadores;

{$DEFINE PERMITIR_DEFORMADORES_NULOS}

{$mode delphi}

interface

uses
  Classes, SysUtils, Math, xmatdefs, matreal, fddp, fddp_conmatr;



(*+doc
Esta función recibe como parámetros una serie de datos y la cantidad de puntos
de la serie que forman un ciclo.
La cantidad de puntos de un ciclo, define ciclos dentro de la serie. Los primeros
NPPorCiclo puntos de la serie pertenecen al primer ciclo, los segundos NPPorCiclo
puntos de la serie pertenecen al segundo ciclo y así sucesivamente.
Dentro de cada ciclo, los puntos se pueden indexar de 1 a NPPorciclo y diremos
que el punto es el primer paso del ciclo, el segundo y así hasta el NPPorCiclo paso
del ciclo. Todo punto de la serie entonces se clasifica dentro de un ciclo y dentro
de ese ciclo le corresponde un paso.
La idea es agrupar todos los puntos, de diferentes ciclos que tienen
el mismo paso y con ellos crear una fuente aleatoria capaz de generar números
con igual histograma que el grupo de puntos de la serie de datos que corresponden
a ese paso.
El resultado es entonces NPPorCiclo fuentes aleatorias que tienen
igual función de densidad de probabilidad que la serie original para cada punto
de un ciclo.

Si overlaping= 0 cada muestra aporta solamente al uniformizador del paso que
le corresonde dentro del sitio. Si overlapping es 1 cada muestra aporta a su
propio paso al anterior y al siguiente.

Para explicarlo en palabras, en el caso de los aportes hidráulicos, si ponemos
overlapping= 0 y poniendo NPPorCiclo=52, se crean 52 funciones uniformizantes
una para cada semana del año considerando solamente los aportes de esa semana.
Por ejemplo, para la primer semana del año, se consideran las muestras solamente
de la primer semana de cada año en la construcción de la función. Como la cantidad
de años de aportes es del orden de 100, el usar estrictamente el aporte de cada
semana en la construcción de las funciones desformantes, puede introducir un
comportamiento adicional basado en los datos. Parece más adecuado indicar que
las características de la primer semana en realidad es compartida con las semanas
de su entorno y por lo tanto se podrían usar las muestras de una semana y las
de su entorno. Poniendo overlapping=1 estaremos considerando como entorno
la semana anterior y la siguiente. Con overlapping=2 consideramos las dos
anteriores y las dos siguientes.

La posición de una muestra en el ciclo se calcula como:
r:= (kMuestra -1)/ nPPorCiclo + rOffsetCiclo


-doc*)
function uniformizadores_(serie: TVectR; rNPPorCiclo: NReal;
  rOffsetCiclo: NReal; overlapping: integer; traslapping: integer;
  nPuntosPorMiniciclo: integer; filtrar: boolean; umbralFiltro: NReal;
  NPuntosResultado: integer; NCronicasRuido: integer;
  precisionMedida_pu: NReal): TDAOf_ddp_VectDeMuestras;



(*
rch@20140618

EN DESARROLLO, SIN PROBAR. Tendría que sustituir al de arriba.

Esta versión intenta tener en cuenta los tiempos reales entre muestras,
periodo del mi-ciclo y del ciclo itentando liverar la obligaciónd e que los
periodos tengan que ser un múltiplo exacto del intervalo entre meustras.


*)
function uniformizadores_dt(serie: TVectR; NPPorCiclo: integer;
  overlapping: integer; traslapping: integer; filtrar: boolean;
  umbralFiltro: NReal; NPuntosResultado: integer;
  dt_Muestreo, dt_MiniCiclo, dt_Ciclo: double): TDAOf_ddp_VectDeMuestras;

implementation

const
  UMBRAL_TOCADOS = -14.14E14; // un numero muy negativo


function uniformizadores_(serie: TVectR; rNPPorCiclo: NReal;
  rOffsetCiclo: NReal; overlapping: integer; traslapping: integer;
  nPuntosPorMiniciclo: integer; filtrar: boolean; umbralFiltro: NReal;
  NPuntosResultado: integer; NCronicasRuido: integer;
  precisionMedida_pu: NReal): TDAOf_ddp_VectDeMuestras;

var
  kPaso, kMuestra: integer;
  NPPorCiclo_: integer;
  nCiclos: integer;
  VectorDeMuestras: array of TVectR;
  res: TDAOf_ddp_VectDeMuestras;
  jCiclo, jOverlap, jTraslap: integer;
  vaux, va: TVectR;
  valor_Original, valor: NReal;
  nNoFiltrados: integer;
  cnt_Filtrados: integer;
  k: integer;
  ipos: integer;

  jrd: NReal;

  kRealizacionDeRuido: integer;
  ruido: Tf_ddp_GaussianaNormal;
  kMinVal, kMaxVal: integer;
  MinVal, MaxVal, rangoVal: NReal;

  dv: NReal;
begin

  if NCronicasRuido > 1 then
    ruido := Tf_ddp_GaussianaNormal.Create(nil, 31);

  serie.MinMax(kMinVal, kMaxVal, MinVal, MaxVal);
  rangoVal := MaxVal - MinVal;

  // Calculamos la cantidad de ciclos enteros que caben en la serie
  nCiclos := trunc(Serie.n / rNPPorCiclo);
  NPPorCiclo_ := trunc(rNPPorCiclo);

  // Vamos a hacer un Vector de Muestras para cada paso dentro de un ciclo
  setlength(VectorDeMuestras, NPPorCiclo_);

  // Vector auxiliar para soporte del conjunto ampliado de muestras
  vaux := TVectR.Create_Init(nCiclos * (1 + 2 * overlapping) *
    (1 + 2 * traslapping) * NCronicasRuido);

  for kPaso := 1 to NPPorCiclo_ do
  begin
    vaux.FillVal(UMBRAL_TOCADOS); // esto es para detectar puntos NO TOCADOS

    // Bien, ahora construimos los Vectores de Muestras agregando las muestras de la
    // serie que corresponden al paso de tiempo dentro del ciclo que asociamos
    // a cada vector.
    ipos := 1;

    for jCiclo := 1 to nCiclos do
      for jTraslap := -Traslapping to Traslapping do
        for jOverlap := -Overlapping to Overlapping do
        begin
          kMuestra := round(kPaso + (jCiclo - 1 - rOffsetCiclo) *
            rNPPorCiclo + jTraslap * NPuntosPorMiniciclo + jOverlap);
          while kMuestra < 1 do
            kMuestra := kMuestra + NPPorCiclo_;
          while kMuestra > serie.n do
            kMuestra := kMuestra - NPPorCiclo_;

          // Procesamos la crónica original
          valor_Original := Serie.e(kMuestra);
          vaux.pon_e(ipos, valor_Original);
          Inc(ipos);

          // Si se solicitaron más realizaciones del ruido de medición las generamos.
          for kRealizacionDeRuido := 2 to NCronicasRuido do
          begin
            dv:= rangoVal * ruido.rnd * precisionMedida_pu;
            valor := valor_Original + dv;

            if valor < MinVal then
              valor := minVal
            else if valor > MaxVal then
              valor := MaxVal;

            vaux.pon_e(ipos, valor);
            Inc(ipos);
          end;

        end;


    // al ordenar creciente quedan los FILTRADOS al inicio.
    // la primer muestra no filtrada queda en la posición cnt_Filtrados+1
    vaux.Sort(True);


    cnt_Filtrados := 0;

    for k := 1 to vaux.n do
    begin
      if vaux.e(k) <= UMBRAL_TOCADOS then
        Inc(cnt_Filtrados);
    end;

    if (umbralFiltro > UMBRAL_TOCADOS) and Filtrar then
    begin
      for k := 1 to vaux.n do
      begin
        if vaux.e(k) <= umbralFiltro then
          Inc(cnt_Filtrados);
      end;
    end;

    nNoFiltrados := vaux.n - cnt_Filtrados;

{$IFNDEF PERMITIR_DEFORMADORES_NULOS}
    if nNoFiltrados = 0 then
      raise Exception.Create('Imposible continuar, demasiados huecos!!');
    va := TVectR.Create_Init(NPuntosResultado);
    for k := 1 to va.n do
    begin

      jrd := max(k / nPuntosResultado * nNoFiltrados, 1);

      //    jrd := ( k -1 ) / (nPuntosResultado-1) * (nNoFiltrados-1) + 1;
      va.pv[k] := vaux.interpol(jrd + cnt_Filtrados);
    end;
 {$ELSE}
    if nNoFiltrados > 0 then
    begin
      va := TVectR.Create_Init(NPuntosResultado);
      for k := 1 to va.n do
      begin
        jrd := max(k / nPuntosResultado * nNoFiltrados, 1);
        //    jrd := ( k -1 ) / (nPuntosResultado-1) * (nNoFiltrados-1) + 1;
        va.pv[k] := vaux.interpol(jrd + cnt_Filtrados);
      end;
    end
    else
    begin
      va := TVectR.Create_Init(NPuntosResultado);
      for k := 1 to va.n do
      begin
        va.pv[k] := -111333; // con esto indicamos que el deformador NO EXISTE.
      end;
    end;

 {$ENDIF}
    VectorDeMuestras[kPaso - 1] := va;
  end;

  if NCronicasRuido > 1 then
    ruido.Free;

  // Bien, ahora con los vectores de muestras vamos a construir las fuentes
  // aleatorias que generan valores con igual función de densidad de probabilidad
  // que la del vector de muestras.
  setlength(res, NPPorCiclo_);
  for kPaso := 1 to NPPorCiclo_ do
    res[kPaso - 1] := Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(
      VectorDeMuestras[kPaso - 1], nil, 31);
  Result := res;
end;



(*
rch@20140618
EN DESARROLLO, SIN PROBAR. Tendría que sustituir al de arriba.

*)
function uniformizadores_dt(serie: TVectR; NPPorCiclo: integer;
  overlapping: integer; traslapping: integer; filtrar: boolean;
  umbralFiltro: NReal; NPuntosResultado: integer;
  dt_Muestreo, dt_MiniCiclo, dt_Ciclo: double): TDAOf_ddp_VectDeMuestras;

var
  kPaso, kMuestra: integer;
  nCiclos: integer;
  VectorDeMuestras: array of TVectR;
  res: TDAOf_ddp_VectDeMuestras;
  jOverlap, jTraslap: integer;
  vaux: TDAOfVectR;
  cntTocados: TDAOfNInt;
  va: TVectR;
  valor: NReal;
  cnt_Filtrados: integer;
  k: integer;

  jrd: NReal;
  kDeformador: integer;

  MaxNMuestras: integer;

begin
  // Calculamos la cantidad de ciclos enteros que caben en la serie
  nCiclos := Serie.n div NPPorCiclo;

  // Vamos a hacer un Vector de Muestras para cada paso dentro de un ciclo
  setlength(VectorDeMuestras, NPPorCiclo);

  // Vectores auxiliares para soporte del conjunto ampliado de muestras
  setlength(vaux, NPPorCiclo);

  // para llevar la cantidad de muestras agregada a cada lente
  setlength(cntTocados, NPPorCiclo);

  MaxNMuestras := (nCiclos + 1) * (1 + 2 * overlapping) * (1 + 2 * traslapping);

  // inicializamos los vectores y los contadores de muestras usadas.
  for kPaso := 0 to NPPorCiclo - 1 do
  begin
    // creamos vectores con el máximo de muestras que pueden tener los deformadores
    vaux[kPaso] := TVectR.Create_Init(MaxNMuestras);
    cntTocados[kPaso] := 0;
  end;


  cnt_filtrados := 0;


  // Ahora recorremos las muestras y según los tiempos, el overlapin y traslaping
  // colocamos cada muestra en los deformadores que correspondan

  for kMuestra := 1 to serie.n do
  begin

    valor := Serie.e(kMuestra);

    if filtrar and (valor <= umbralFiltro) then
    begin
      Inc(cnt_Filtrados);
    end
    else
    begin
      for jTraslap := -Traslapping to Traslapping do
        for jOverlap := -Overlapping to Overlapping do
        begin
          kDeformador := trunc(
            frac(((kMuestra - 1 + jOverlap) * dt_Muestreo + jTraslap * dt_MiniCiclo) /
            dt_Ciclo) * (NPPorCiclo - 1) + 0.5);

          if kDeformador < 0 then
            kDeformador :=
              trunc(((frac((kMuestra - 1 + jOverlap) * dt_Muestreo +
              jTraslap * dt_MiniCiclo) / dt_Ciclo) + 1) * (NPPorCiclo - 1) + 0.5);

          if kDeformador > high(vaux) then
            kDeformador :=
              trunc(((frac((kMuestra - 1 + jOverlap) * dt_Muestreo +
              jTraslap * dt_MiniCiclo) / dt_Ciclo) - 1) * (NPPorCiclo - 1) + 0.5);

          if (kDeformador > 0) and (kDeformador > high(vaux)) and
            (cntTocados[kDeformador] < MaxNMuestras) then
          begin
            Inc(cntTocados[kDeformador]);
            vaux[kDeformador].pon_e(cntTocados[kDeformador], valor);
          end;
        end;
    end;
  end;


  for kDeformador := 0 to NPPorCiclo - 1 do
  begin
    vaux[kDeformador].resize(cntTocados[kDeformador]);
    if vaux[kDeformador].n = 0 then
      raise Exception.Create('Imposible continuar, demasiados huecos!!');
    vaux[kDeformador].Sort(True);

    va := TVectR.Create_Init(NPuntosResultado);
    for k := 1 to NPuntosResultado do
    begin
      jrd := (k - 1) / nPuntosResultado * vaux[kDeformador].n + 1;
      va.pv[k] := vaux[kDeformador].interpol(jrd);
    end;

    VectorDeMuestras[kDeformador] := va;
    vaux[kDeformador].Free;
  end;
  setlength(vaux, 0);
  setlength(cntTocados, 0);

  // Bien, ahora con los vectores de muestras vamos a construir las fuentes
  // aleatorias que generan valores con igual función de densidad de probabilidad
  // que la del vector de muestras.
  setlength(res, NPPorCiclo);
  for kDeformador := 0 to NPPorCiclo - 1 do
    res[kDeformador] := Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(
      VectorDeMuestras[kDeformador], nil, 31);
  Result := res;
end;



end.


