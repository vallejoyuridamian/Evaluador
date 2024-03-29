{+doc
+NOMBRE: MatReal
+CREACION: 1990
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: definicion del objeto matriz de reales.
+PROYECTO: rchlib
+REVISION:
+AUTOR:
+DESCRIPCION:
  Todas las tareas implementadas en esta biblioteca, tienen como
filosofia que los datos estan bien definidos, y para mejorar la
velocidad no verifican la coherencia. Tampoco se encargan de
inicializar matrices. Supongamos que vamos a multiplicar las
matrices A y B , y queremos el resultado en C, la sentecia es
C.MultM(A,B); pero se debe cuidar que los rangos sean los adecuados
y se debe inicializar C antes del llamado a MultMatR.
  Las unicas tareas que inicializan  datos del objeto son las de
lectura. Ej: a.readM; inicialliza a.

-doc}
unit matreal;

{$MODE Delphi}

interface

uses
  Classes,
  SysUtils,
  Math,
  fddp,
  matcpx,
  {$IFDEF ALGLIB}
  Ap, evd, svd,
  {$ENDIF}

  xMatDefs,
  algebrac,
  COMPOL;

type
  TMatR = class;

  { TVectR }

  TVectR = class
    n: integer;
    pv: TDAofNReal;

  public
    // resta el vector y
    procedure res(y: TVectR);
    // resta el vector y si los elementos del z estan entre MaxZ y tolerancia*MaxZ
    procedure resConConsigna(y: TVectR; z: TVectR; tolerancia: NReal = 0.95);
    // resta si lo datos son no validos
    procedure resConDatosNoValidos(y: TVectR; DatNoValidos: TStringList;rellenarCon:NReal = -888888);
    procedure Igual(x: TVectR);
    function trim_fin: TvectR;

    constructor Create_Init(ne: integer );
    constructor Create_InitVal(ne: integer; valIni: NREal = 0.0 );

    //constructor CreateFromPlanillaConEncabezados(enc:string;xls:TLibroOpenCalc);
    constructor Create_FromDAofR(a: TDAofNReal; init: integer = 1);
    constructor Create_Clone(vrx: TVectR);

    procedure Free; virtual;
    {           constructor Create_Ventana( ne: integer; var x );}
    constructor Create_Load(var S: TStream);
    procedure Store(var S: TStream);

    // recorre el vector y completa los huecos con una inerpolaci�n c�bica
    // Detecta como huecos los valores menores que umbral_filtro
    // retonra la cantidad de muestras que fueron completadas.
    function RellenarHuecos(umbral_Filtro: NReal = -11111): integer;


    //Filtra el vector si no se ajusta a la curva te�rica con una tolerancia.
    procedure FiltrarV(pp, X: TVectR; DatNoValidos: TStringList);

    // si n_ >= 0 se utiliza ese valor para establecer la cantidad de elementos
    // en lugar de leerla desde el archivo. Es �til si por alguna raz�n se ley�
    // previamente la l�nea con la cantidad de elementos.
    constructor CreateLoadFromFile(var f: textfile; n_: integer = -1);
    procedure StoreInFile(var f: textfile);

    constructor CreateLoadFromBinaryFile(var f: file; n_: integer = -1);
    procedure StoreInBinaryFile(var f: file);


    function e(k: integer): NReal;
    procedure pon_e(k: integer; x: NReal);
    procedure acum_e(k: integer; x: NReal);

    procedure IntercambiarElementos(k1, k2: integer);

    //JFP:Suma los elementos del array desde i_izq a i_der (ambos inclusive)
    function SumaDesdeHasta(i_izq, i_der: integer): NReal;

    // copia los valores del vector xv a partir del kini  for k= 0 to high( xv ) do pon_e(ini+k, xv[k] ) ;
    procedure pon_ev(kini: integer; xv: array of NReal);

    // Copia x desde kIniOrigen hasta kFinOrigen en self desde la posici�n kIniDestino
    procedure CopyFromTo (kIniOrigen,kFinOrigen,kIniDestino:integer;x:TVectR);

    // producto escalar
    function PEV(y: TVectR): NReal; overload;

    // result = sum e(k) * y.e(k) from k = k1 to k2
    function PEV(y: TVectR; k1, k2: integer): NReal; overload;

    // producto escalar con un vector de reales dado por un puntero a un conjunto
    // de reales que asume del mismo largo.
    function PEV(const pv: PNReal): NReal; overload;

    // result = sum e(k) * pv^[k] from k = k1 to k2
    function PEV(const pv: PNReal; k1, k2: integer): NReal; overload;


    // result = sum ( e(i) * y.e( n - (i-1) )
    function PEVRFLX_(y: TVectR): NReal;

    // norma euclidea al cuadrado de la diferencia
    function distancia2(y: TVectR): NReal;

    // norma eucl�dea de la diferencia
    function distancia(y: TVectR): NReal;

    //Coeficiente de correlaci�n < x[k] * y[k-kdesp] >
    // si filtrar=TRUE, solo considera valores > umbralFiltro
    function coefcorr(y: TVectR; kdesp: integer; filtrar: boolean;
      umbralFiltro: NReal): NReal;

    //Coeficiente de correlaci�n de Pearson :< (x[k]-x_med) * (y[k-kdesp]-y_med)> /(Sigma_x*Sigma_y)
    // si filtrar=TRUE, solo considera valores > umbralFiltro
    function coefcorr_Pearson(y: TVectR; kdesp: integer; filtrar: boolean;
      umbralFiltro: NReal): NReal;



{  rch0904230858
Calcula el coeficiente entre los vectores, para el paso kPaso suponiendo
que en el vector existen ciclos.
kPaso puede tomar valores en [0..nPasosPorCiclo]
overlapping indica la cantidad de casillero adyacentes a la izquierda y a la
derecha el casillero de la muestra en quela muetra ser� considerada.
Por ejemplo overlapping= 3 indica que cada muestra debe considerarse como v�lida
en el casillero v�lido, en los tres anteriores y en los tres siguientes.
Por lo tanto si overlapping=3, dado un kPaso el coeficiente de correlaci�n
ser� calculado considerando las muestras correspondiente al kPaso (en cada cilclo
del vectror) m�s overlapping meustras posteriores y anteriores a ese kPaso.

En cnt_muestras retorna la cantidad de muestras que componene el c�lculo
SI cnt_Muestras = 0, el c�lculo no tiene sentido y el resultado de la funci�n es CERO.

EL par�metro Normalizar si es TRUE indica que se debe normalizar el coeficiente
dividendo por la norma de los vectores asegurando as� que el resultado es 1 (o -1)
si los vectores son coolineales y menor que 1 en caso contrario.
}
    function coefcorr_multiciclo(y: TVectR; kdesp: integer;
      filtrar: boolean; umbralFiltro: NReal; kPaso: integer;
      nPasosPorCiclo: integer; overlapping: integer; var cnt_muestras: integer;
      Normalizar: boolean; archi_dbg: string): NReal;

    // supone que el vector contiene los coeficientes de senos y cosenos
    // de una serie de fourier y la eval�a para el �ngulo pasado como par�metro
    // en radianes. Se asume que los coeficientes son a0, a1 ... an, b1 .. bn
    // siendo a0 el t�rmino constante, a1 ... an los coeficientes de COS y
    // los b1 .. bn los coeficintes de SIN
    function FourierEval(angRad: NReal): NReal;
    /// Operaciones Escalares///

    procedure PorReal(r: NReal; kDesde: integer = 1);
    procedure MasReal(r: NReal);
    procedure porRMasB(r, b: NReal); //x[i] := x[i] * r + b
    procedure sumXVectSiYDiferenteConConsignaYFiltrado(x: TVectR;
      y: TVectR; h: TStringList; z: TVectR; tolerancia: NReal = 0.95);
    procedure sumXVectSiYDiferenteConConsignaYFiltrado2(x: TVectR;
      y: TVectR; w: TVectR; h: TStringList; z: TVectR; tolerancia: NReal = 0.95);


    //res[i]:= self[i] * y[i]
    function porVectorElementoAElemento(y: TVectR): TVectR;

    //res[i]:= self[i] / y[i]
    procedure divVectorElementoAElemento(y: TVectR);


    // self = a+b
    procedure suma(a, b: TVectR);
    procedure sum0(y: TVectR);
    procedure sum(y: TVectR);
    procedure sumSiDiferente(y: TVectR; Cero: Nreal);
    procedure resSiDiferente(y: TVectR; Cero: Nreal);
    // suma x (vector) al vector si el elemento en y es disitinto de Cero
    procedure sumXVectSiYDiferente(x: TVectR; y: TVectR; Cero: Nreal);
    // suma x (escalar) al vector si el elemento en y es disitinto de Cero
    procedure sumXEscSiYDiferente(x: Nreal; y: TVectR; Cero: Nreal);

    procedure sumXEscSiYDiferenteConConsignaYFiltrado(x: Nreal;
      y: TVectR; h: TStringList; z: TVectR; tolerancia: NReal = 0.95);
    procedure resXVectSiYDiferenteConConsignaYFiltrado(x: TVectR;
      y: TVectR; h: TStringList; z: TVectR; tolerancia: NReal = 0.95);


    procedure sumAbs(y: TVectR);
    procedure sumRPV(r: NReal; x: TVectR);
    function sumatotal: NReal; {suma todos los elementos del vector}
    function ne2: NReal; {norma euclideana al cuadrado }

    { Calcula el promedio de los valores = Sum( v ) / N }
    function promedio: NReal;

    { Calcula el promedio desde kDesde de NElementos }
    function promedioVentana(kDesde, NElementos: integer): NReal;

    { Calcula el m�ximo desde kDesde de NElementos }
    function maxVentana(kDesde, NElementos: integer): NReal;

    { Calcula el m�nimo desde kDesde de NElementos }
    function minVentana(kDesde, NElementos: integer): NReal;

    { Calcula el Promedio y la Varianza Sum v^2 / (N-1)
    la variable flg_vrz_nm1 indica si el promedio de la varianza se realiza
    dividiendo po (N-1) o por N seg�n sea TRUE o FALSE respectivamente }
    procedure PromedioVarianza(var prom, vrz: NReal; flg_vrz_nm1: boolean = True);

    { Llama a promedioVarianza y retorna la varianza}
    function varianza(flg_vrz_nm1: boolean = True): NReal;

    { Calcula el Promedio y el Desv�o estandar. Llama a PromedioVarianza }
    procedure promedioDesvEst(var prom, desvEst: NReal; flg_vrz_nm1: boolean = True);

    function desviacionEstandar: NReal;     { sqrt( varianza( false ) }
    function desviacionEstandar_nm1: NReal; { sqrt( varianza( true ) }


    // ignora los valores <= umbralFiltro
    function Promedio_filtrando(umbralFiltro: NReal): NReal;

    // retorna la cantidad de muestras consideradas para el promedio
    function  PromedioVarianza_filtrando( out Prom, vrz: NReal;
      umbralFiltro: NReal; flg_vrz_nm1: boolean = True): integer;


    function Varianza_filtrando(umbralFiltro: NReal;
      flg_vrz_nm1: boolean = True): NReal;

    procedure PorReal_filtrando(umbralFiltro, r: NReal);
    { if pv[k] > umbralFiltro then pv[k]:= pv[k]*r }
    procedure MasReal_filtrando(umbralFiltro, r: NReal);
    { if pv[k] > umbralFiltro then pv[k]:= pv[k] + r }


    function normEuclid: NReal;
    function normMaxAbs: NReal;
    function normSumAbs(init: integer = 1): NReal;
    function normSum(init: integer = 1): NReal;
    function normSumSI(vacio: NReal): NReal;
    function normSumxReal(f: NReal): NReal;
    function Vector_filter: TVectR;

    // Copia los valores desde el vector x pasado como par�metro
    procedure Copy( const x: TVectR); overload;
    procedure Copy( const x: TDAOfNReal); overload;

    // CopyTo copia los valores al vector x pasado como par�metro.
    procedure CopyTo( var x: TVectR); overload;
    procedure CopyTo( var x: TDAOfNReal); overload;

    procedure Ceros;
    procedure Unos;  {inicializa el vector con unos}

    procedure FillVal( val: NREal );

    procedure MinMax(var kMin, kMax: integer; var Min, Max: NReal);
    function minVal: NReal;
    function maxVal: NReal;
    procedure Print(var s: string); virtual; overload;
    procedure Print; virtual; overload;

    { Divide las componetes por la norma obligando al vector a
    tener norma ecuclidea = 1.
    Retorna la NormaEuclidea, del vector antes de hacerlo unitario.
    En el caso de el vector NULO, retonra CERO y como vector unitario
    pone uno de 1 en la primer coordenada y cero en el resto.}
    function HacerUnitario: NReal;

    (*
    function EstimFrec(
            nivel,          {nivel de compoaracion}
            histeresis: NReal;  {histeresis del cruce }
            AbajoArriba: boolean  {sentido del cruce}
            ): NReal;        {cantidad de cruces}
    *)

    procedure Sort(creciente: boolean);

    // ordena el vector, pero tambi�n aplica el mismo orden sobre
    // el vector de enteros idx. Si inicialmente se carga idx con
    // los ordinales del 1 a n, luego es posible saber la posici�n
    // original de cada valor.
    // ATENCION, idx debe estar creado con igual criterio que el pv del
    // TVectR o sea que va de 0..N aunque solo se usen de 1..N.
    // Solo se ordenan los �dices en el rango 1..N.
    procedure Sort_idx(creciente: boolean; idx: TDAOfNInt);

    // Reordena el vector de acuerdo a los indices de idx
    // se supone idx de igual larg que el vector y con la secuencia
    // 1..n desordenada.   Atenci�n la posici�n 0 (Cero) de idx no se usa
    // idx tiene que ser como podr�a ser devuelto por Sort_idx
    // Si idx se obtuvo con la operaci�n Sort_idx este m�todo sirve para
    // imponer el mismo orden sobre otros vectores.
    procedure SortByIdx(idx: TDAOfNInt);

    // Recomopone el orde original de un vector de acuerdo a los indices de idx
    // se supone idx de igual larg que el vector y con la secuencia
    // 1..n desordenada.   Atenci�n la posici�n 0 (Cero) de idx no se usa
    // idx tiene que ser como podr�a ser devuelto por Sort_idx
    // Si a un vector ordenado con Sort_idx aplicamos esta operaci�n se recompone
    // el orden original.
    procedure UnSortByIdx(idx: TDAOfNInt);


    // evalua sum( ak * x^(k-1) ; k= 1 a n );
    function rpoly(x: NReal): NReal;

    // evalua sum( ak * x^(k-1) ; k= 1 a n );
    procedure cpoly(var resc: NComplex; xc: NComplex);


    // genera un vector rand�mico con cada posici�n uniforme en [0, 1)
    procedure random(madreUniforme: Tf_ddpUniformeRand3 = nil);

    // carga un vector aleatorio de norma eucl�dea 1.
    procedure versor_randomico(madreUniforme: Tf_ddpUniformeRand3 = nil);

    // el indice kr es real y si esta en el rango 1..n el valor devuelto
    // es la interpolaci�n lineal entre los valores del vector correspondiente
    // a los casilleros trunc(kr) y trunc(kr)+1
    // si kr < 1 el valor devuelto es el correspondiente a kr= 1
    // si kr > n el valor devuelto es el correspondiente a kr= n
    function interpol(kr: NReal): NReal;

    // inversa de la funci�n interpol. El valor devuelto es un n�mero
    // real. Si res < 1 quiere decir que x es menor que el primer elemento
    // de la tabla. Si res > n quiere decir que x es mayor que el �ltimo elemento
    // del vector. Se supone que los elementos del vector est�n ordenados
    // en forma creciente.
    function inv_interpol(x: NReal): NReal;

    ///procedimiento que invierte el orden de los elementos del vector
    ///el primero ser� el final
    procedure invertir_orden;
    // Integral, etren dos reales asignando la parte de los intervaloes extremos
    // de acuerdo a los n�meros reales.
    function integral(kr1, kr2: NReal): NReal;

    // modifica el vector imponiendo en el casillero k, el promedio
    // de los nPM casilleros on ordinal <= que k
    // para los primeros nPM-1 casilleros el c�lculo se realiza con menos elementos
    procedure PromedioMovil(nPM: integer);

    // Lo mismo que PromedioMovil pero si alguna de las muestras es < umbralFiltro
    // como resultado del promedio m�vil del casillero correspondiente se coloca
    // el valor (umbralFiltro - 1212) para indicar que no fuel posible calcular
    procedure PromedioMovil_Filtrado(nPM: integer; umbralFiltro: NReal);


    // retorna la recta que a*k+b que mejor aproxima al conjunto
    // de puntos del vector en el sentido de m�nimos cuadrados
    procedure AproximacionLineal(var a, b: NReal); overload;

    // lo mismo que la anterior pero solo considera las muestras > umbralFiltro
    procedure AproximacionLinealFiltrada(var a, b: NReal; umbralFiltro: NReal); overload;


    // retorna la recta que e(k) = a*vx(k)+b que mejor aproxima al conjunto
    // de puntos del vector en el sentido de m�nimos cuadrados
    // retonra el error cuadr�tico medio = Suma( ( e(k) -  a*vx(k)+b )^2 )/N
    function AproximacionLineal(var a, b: NReal; vx: TVectR): NReal; overload;

    // Lo mismo que la AproximacionLineal, pero solo considera las muestras en
    // las que x1 <= vx[k] < x2. En CntMuestras retorna la cantidad de muestras
    // que resultaron consideradas.
    function AproximacionLinealFiltrada(var a, b: NReal; vx: TVectR;
      x1, x2: NReal; var cntMuestras: integer): NReal; overload;

    //Retorna una copia del vector en formato TDAOfNReal
    //ATENCI�N, la copia es indexada desde 0
    function toTDAOfNReal(kDesde: integer = 1;
      kHasta: integer = -1 // -1 = hasta el final
      ): TDAofNReal;

    // funciones espectrales

    // aplica funci�n de Hanning al vector
    procedure Aplicar_Hanning;  // 0.5 * ( 1 - cos ( (k-1) / N ) )



    procedure WriteXLTSimple(var f: textfile);
    procedure WriteXLTSimple_archi(archi: string);
    procedure WriteConsola;

    // Crea una matriz copiando por columna los valores del vector
    // ver tambi�n la funci�n "vec" de TMatR
    function reshape(nf, nc: integer): TMatR;

    // Value At Risk. Supone que el vector representa un conjunto de valores
    // de Costo equiprobables y que est�n ordenados en forma creciente.
    // pe es la probabilidad de excedencia.
    function pe_VaR(pe: NReal): NReal;

    // Conditioned Value At Risk. Es el valor esperado de los costos m�s altos
    // con probabilidad del conjunto pe.
    // Se supone que el vector est� ordenado en forma creciente.
    function pe_CVaR(pe: NReal): NReal; overload;

    // retorna el valor esperado de las muestras en la banda de probabilidad [pe2, pe2)
    // Se supone que el vector est� ordenado en forma creciente.
    function pe_CVaR(pe1, pe2: NReal): NReal; overload;


    // retorna un string con [ n | v1, v2, .... vn ]
    function serialize: string;
    // se crea a partir de un string como el devuelto por serialize
    constructor Create_unserialize(s: string);

    // retorna un string con { v1, v2, v3 .... vn } como para ser cargado en un campo de PostGreSQL
    function serialize_pg: string;

    // se crea a partir de un string como el devuelto por serialize_pg
    constructor Create_unserialize_pg( s: string; c_open: char = '{'; c_close: char = '}' );


    function clonar: TVectR;

    // cambia el largo del vector truncando o alargando seg�n corresponda.
    // Si se alarga completa con CEROS los nuevos elementos.
    procedure resize(nuevo_n: integer);

    // recorre los elementos del vector y si el elemento es igual a alguno
    // de los valores del par�metro huecos entonces lo sustituye por DefVal
    procedure limpiar_huecos(huecos: TDAofNReal; DefVal: Nreal);

    {SKEWNESS
    In statistics, skewness is a measure of the asymmetry of the probability
    distribution of a random variable about its mean. In other words, skewness
    tells you the amount and direction of skew (departure from horizontal symmetry).
    The skewness value can be positive or negative, or even undefined.
    If skewness is 0, the data are perfectly symmetrical, although it is quite
    unlikely for real-world data. As a general rule of thumb:
    If skewness is less than -1 or greater than 1, the distribution is highly skewed.
    If skewness is between -1 and -0.5 or between 0.5 and 1, the distribution is moderately skewed.
    If skewness is between -0.5 and 0.5, the distribution is approximately symmetric.
    }
    function skewness(X: TVectR): NReal;

    {
    KURTOSIS
    In statistics, kurtosis is any measure of the "peakedness" of the
    probability distribution of a random variable.
    Kurtosis tells you the height and sharpness of the central peak,
    relative to that of a standard bell curve.
    }
    function kurtosis(X: TVectR): NReal;

    {
    CDF_MaxDiff_N01
    Calcula la m�xima diferencia entre la CDF Emp�rica del vector de muestra
    y la CDF de una N(0,1)
    Lo primero que hace la funci�n es ordenar el vector en forma creciente.
    Tenga en cuenta entonces que un efecto COLATERAL de llamar esta funci�n
    es que se ordena el vector.
    Por construcci�n el resultado es� en [0,1]
    }
    function MaxDiff_CDF_N01: NReal;

  end;


  TDAOfVectR = array of TVectR;
  TRamillete = TDAOfVectR;

  { TMatR }

  TMatR = class
  public
    pm: TDAOfVectR;
    nf, nc: integer;

    procedure Igual(x: TMatR);
    procedure Free; virtual;

    // No inicializa las filas. Es para llamar si otro procedimiento
    // crear� los TVectR de pm
    constructor Create_Init_pm(filas, columnas: integer);

    // Este es el constructor m�s usado, inicializa todo.
    constructor Create_Init(filas, columnas: integer);
    constructor Create_InitVal(filas, columnas: integer; valIni: NReal );

    constructor Create_FromMatOfNReal(a: TMatofNReal);

    constructor Create_Load(var S: TStream);
    procedure Store(var s: TStream);

    constructor Create_Load_COMPRESS(var S: TStream);
    procedure Store_COMPRESS(var s: TStream; const nBytesPerValue: byte);

    constructor CreateLoadFromFile(var f: textfile);
    procedure StoreInFile(var f: textfile);

    constructor Create_Clone(mrx: TMatR);

    function serialize: string;
    constructor Create_unserialize(s: string);

    // retorna un string con {{ v11, v12 },{ v21, v22 }} como para ser cargado
    // en un campo de PostGreSQL
    function serialize_pg: string;

    // se crea a partir de un string como el devuelto por serialize_pg
    constructor Create_unserialize_pg(s: string; c_open: char='{'; c_close: char='}'
      );


    function e(k, j: integer): NReal; virtual;
    procedure pon_e(k, j: integer; x: NReal); virtual;
    procedure acum_e(k, j: integer; x: NReal); virtual;

    procedure pon_fila(kfil, jcol: integer; xv: array of NReal);
    procedure pon_columna(kfil, jcol: integer; xv: array of NReal);


    procedure PorReal(r: NReal);

    // Self:= a * b
    procedure Mult(a, b: TMatR);

    //JFP: self[i]:= self[i] * y[i]
    procedure porMatrizElementoAElemento(y: TMatR);

    //JFP: self[i]:= self[i]^Pot
    procedure PotenciaElementoAElemento(Pot: Nreal);

    //JFP: self[i]:= Max(self[i],Valmin)
    procedure MaximizarElementoAElemento(ValMin: Nreal);

    //JFP: Res = Sum(self[i]). El resultado es la suma de todos los elementos de la Matriz.
    function SumarTodosLosElementos: NReal;

    // Self:= a + b
    procedure Suma(a, b: TMatR);

    procedure Transformar(var y: TVectR; x: TVectR);

    // retorna X^t * Self * X
    function FormaCuadratica(x: TVectR): NReal;

    procedure WriteM;
    constructor Create_ReadM; (* a debe estar sin inicializar *)

    function Traza: NReal;
    function Deter: NReal;

    // se auto-escaleriza actuando a la vez sobre la matriz de t�rminos
    // independientes i. Si el sistem es invertible retonra invertible = true
    // el resultado de la funci�n es el determinante dividodo por  10 elevado al
    // valor retornado en exp10. Es decir que el determinante es rDet* 10^exp10
    // la introducci�n del factor fpow10 es porque en matrices muy grandes
    // de problemas no escalados, el c�lculo del determinante directo puede
    // causar desborde num�rico.
    function Escaler(var i: TMatR; var invertible: boolean; var exp10: integer): NReal;
    procedure PolinomioCaracteristico(var P: TPoliR);

    // Copia la Columna J en el vector Y (que ya debe esta inicializado9
    procedure CopyColVect(var Y: TVectR; J: integer);

    // Copia el vecto Y en la Columan J
    procedure CopyVectCol(const Y: TVectR; j: integer);

    function Inv(var det: NReal): boolean; overload;
    function Inv: boolean; overload;

    procedure Ceros; virtual;
    procedure CerosFila(kfil: integer);

    // busca el m�nimo y m�ximo de la matriz
    procedure MinMax(var kMin, jMin: integer; var kMax, jMax: integer;
      var Min, Max: NReal); overload;

    // Si no interesan los �ndices usar esta
    procedure MinMax(var Min, Max: NReal); overload;


    // busca el m�nimo y maximo en una columna
    procedure Columna_MinMax(jCol: integer; var kmin, kmax: integer;
      var minimumVal, maximumVal: NReal);

    // retorna el m�ximo
    function MaxVal: NReal;

    // retorna el m�nimo
    function MinVal: NReal;

    function NormMaxAbs: NReal;

      {
      rch@201305172050
      retorna la dimensi�n del subespacio NULO.
      El resultado es la matriz Base, en la cual el conjunto de filas
      forman una base del subespacio nulo de la matriz SELF.
      Si se quiere una base  Ortonormal invocar el m�todo
      Ortonormal en la matriz resultado (base).
      Como ejemplo: CBSENON.PAS.
      LAS FILAS DE Base SON LOS VECTORES DE LA BASE }
    function CalcBSEN(var Base: TMatR): integer;

      { Hace que el conjunto de filas sea una base OROTORMAL,
      el resultado de la funci�n es la dimensi�n del espacio generado
      por las filas.
      Como ejemplo: CBSENON.PAS
      ORTOGONALIZA LAS FILAS DE LA MATRIZ COMO SI FUERA UNA BASE }
    function OrtoNormal: integer;

      { Calcula una base del subespacio invariante asociado a un autovalor
      real dado
      LAS FILAS DE Base SON LOS VECTORES DE LA BASE }
    function CalcBSE_R(var Base: TMatR; av: NReal): integer;

      { Calcula una base del subespacio invariate asociado a un par de
      autovalores complejos conjugados
      LAS FILAS DE Base SON LOS VECTORES DE LA BASE }
    function CalcBSE_PCC(var Base: TMatR; av: NComplex): integer;

    procedure IntercambieFilas(k1, k2: integer);

    // retorna un puntero a la fila k dentro de la matriz (no crea una instancia)
    function Fila(k: integer): TVectR;

    // retorna el puntero a la fila y la quita de la matriz moviendo el resto
    // y cambiando la dimensi�n
    function QuitarFila( k: integer ): TVectR;

    // crea una instancia con la columna y la devuelve
    function Crear_Columna(k: integer): TVectR;

    // Crea una instancia con la transpuesta de la matriz y la retorna.
    function Crear_Transpuesta: TMatR;
    procedure Transponer; // transpone la mamtriz actual

    procedure WriteXLT(var f: textfile);
    procedure WriteArchiXLT(const archi: string);

    constructor CreateFromXLT(var f: textfile);
    constructor CreateFromArchiXLT(const archi: string);


    // asume que la matriz es sim�trica y trabaja solamente
    // usando el triangulo superior. Devuelve como resultado
    // una matriz triangula inferior que al ser multiplicada
    // por su traspuesta da la matriz actual. B / B * B.traspuesta = Self.
    // Atenci�n, la funci�n "chol" de Matlab retonra el traspuesto de B.
    // Si no logra factorizar la matriz retorna NIL.
    function raiz_Cholesky: TMatR;

    (*
    rch@201305172050
    Suponemos que Self es sim�trica y buscamos una raiz W tal que W.Wt = Self

    En dimRes retorna la cantidad idependiente de columnas del resultado.
    Las primeroas dimRes columnas del resultado son una base ortonormal
    de autovectores de Self, asociados a los autovalores en orden decreciente.
    La primer columna es el autorversor asociado al mayor autovalor.

    Si dimRes < 0 implica que apareci� un autovalor < 0 y no fue posible continuar
    Las columnas calculadas correctamente ser�n las primeras (-dimRes -1 ).
    Si flg_RaiseException = TRUE, dispara una excepci�n si encuentra un autovalor
    negativo.
    *)
    function RaizPorPotenciaIterada(var dimRes: integer;
      flg_RaiseException: boolean): TMatR;

    // PotenciaIterada
    // Hace una iteraci�n.
    // Transforma el vector pasado como par�metro y lo lleva a norma 1.
    // El resultado es la norma al cuadrado de la variaci�n.
    // en Lambda retorna el autovalor correspondiente.
    function PotenciaIterada(var v: TVectR; var lambda: NReal): NReal;


    (* Busca por el m�todo de la potencia iterada los autovalores y auto-vectores
    devuelve en D retorna los autovalores y en las columnsas de W los autovectores
    correspondientes.
    El resultado es TRUE si logra el objetivo y FALSE en caso contrario. *)
    function Descomp_DW_PotenciaIterada(var D: TVectR; var W: TMatR): boolean;

    function Interpol2D(f, c: NReal): NReal;

    function InterpolCircularSectores(NSectores: integer;f, c: NReal): NReal;

    procedure unos; virtual;
    procedure fillVal( val: NReal );
    procedure Print; virtual;

    {$IFDEF ALGLIB}
    (*************************************************************************
    Singular value decomposition of a rectangular matrix.

    The algorithm calculates the singular value decomposition of a matrix of
    size MxN: A = U * S * V^T

    The algorithm finds the singular values and, optionally, matrices U and V^T.
    The algorithm can find both first min(M,N) columns of matrix U and rows of
    matrix V^T (singular vectors), and matrices U and V^T wholly (of sizes MxM
    and NxN respectively).

    Take into account that the subroutine does not return matrix V but V^T.
    Input parameters:
        UNeeded     -   0, 1 or 2. See the description of the parameter U.
        VTNeeded    -   0, 1 or 2. See the description of the parameter VT.
        AdditionalMemory -
                        If the parameter:
                         * equals 0, the algorithm doesn�t use additional
                           memory (lower requirements, lower performance).
                         * equals 1, the algorithm uses additional
                           memory of size min(M,N)*min(M,N) of real numbers.
                           It often speeds up the algorithm.
                         * equals 2, the algorithm uses additional
                           memory of size M*min(M,N) of real numbers.
                           It allows to get a maximum performance.
                        The recommended value of the parameter is 2.

    Output parameters:
        W           -   contains singular values in descending order.
        U           -   if UNeeded=0, U isn't changed, the left singular vectors
                        are not calculated.
                        if Uneeded=1, U contains left singular vectors (first
                        min(M,N) columns of matrix U).
                        if UNeeded=2, U contains matrix U wholly.
        VT          -   if VTNeeded=0, VT isn�t changed, the right singular vectors
                        are not calculated.
                        if VTNeeded=1, VT contains right singular vectors (first
                        min(M,N) rows of matrix V^T).
                        if VTNeeded=2, VT contains matrix V^T wholly.
      (call to -- ALGLIB --)
    *************************************************************************)
    function RMatrixSVD(UNeeded: integer; VTNeeded: integer;
      AdditionalMemory: integer; var res_W: TVectR; var res_U: TMatR;
      var res_VT: TMatR): boolean;



    (*************************************************************************
    Finding eigenvalues and eigenvectors of a general matrix

    The algorithm finds eigenvalues and eigenvectors of a general matrix by
    using the QR algorithm with multiple shifts. The algorithm can find
    eigenvalues and both left and right eigenvectors.

    A = Self;  dim( N, N )

    The right eigenvector is a vector x such that A*x = w*x, and the left
    eigenvector is a vector y such that y'*A = w*y' (here y' implies a complex
    conjugate transposition of vector y).

    Input parameters:
        VNeeded -   flag controlling whether eigenvectors are needed or not.
                    If VNeeded is equal to:
                     * 0, eigenvectors are not returned;
                     * 1, right eigenvectors are returned;
                     * 2, left eigenvectors are returned;
                     * 3, both left and right eigenvectors are returned.

    Output parameters:
        WR      -   real parts of eigenvalues. (dim N )
        WI      -   imaginary parts of eigenvalues.
        VL, VR  -   arrays of left and right eigenvectors (if they are needed).
                    If WI[i]=0, the respective eigenvalue is a real number,
                    and it corresponds to the column number I of matrices VL/VR.
                    If WI[i]>0, we have a pair of complex conjugate numbers with
                    positive and negative imaginary parts:
                        the first eigenvalue WR[i] + sqrt(-1)*WI[i];
                        the second eigenvalue WR[i+1] + sqrt(-1)*WI[i+1];
                        WI[i]>0
                        WI[i+1] = -WI[i] < 0
                    In that case, the eigenvector  corresponding to the first
                    eigenvalue is located in i and i+1 columns of matrices
                    VL/VR (the column number i contains the real part, and the
                    column number i+1 contains the imaginary part), and the vector
                    corresponding to the second eigenvalue is a complex conjugate to
                    the first vector.           ( dim NxN )

    Result:
        True, if the algorithm has converged.
        False, if the algorithm has not converged.

    Note 1:
        Some users may ask the following question: what if WI[N-1]>0?
        WI[N] must contain an eigenvalue which is complex conjugate to the
        N-th eigenvalue, but the array has only size N?
        The answer is as follows: such a situation cannot occur because the
        algorithm finds a pairs of eigenvalues, therefore, if WI[i]>0, I is
        strictly less than N-1.

    Note 2:
        The algorithm performance depends on the value of the internal parameter
        NS of the InternalSchurDecomposition subroutine which defines the number
        of shifts in the QR algorithm (similarly to the block width in block-matrix
        algorithms of linear algebra). If you require maximum performance
        on your machine, it is recommended to adjust this parameter manually.


    See also the InternalTREVC subroutine.

    The algorithm is based on the LAPACK 3.0 library.
    *************************************************************************)
    function RMatrixEVD(VNeeded: integer; var res_WR: TVectR;
      var res_WI: TVectR; var res_VL: TMatR; var res_VR: TMatR): boolean;



    // retorna (Self)^r tiene �xito y nil en caso contrario.
    // Diagonaliza la matriz, aplica el power( ) sobre los coeficientes diaglonales
    // y luego desdiagonaliza
    function power_r(r: NReal): TMatR;
   {$ENDIF}

    // Eleva la potencia de una matriz a un exponente n entero
    procedure power_n(n: integer);

    // Calcula la potencia de una matriz a un exponente n entero
    // Crea una instancia y la devuelve.
    function Create_power_n(n: integer): TMatR;


    // El producto de Kronecke es �til para resolver por vectorizaci�n
    // un sistema lineal de matrices A, X, B y C (todas de N x N )
    //  Dado el sistem lineal A X B = C,
    //  La vectorizaci�n del sistema es:
    //    (B^T (x) A ) vec( x ) = vec( C )


    // result = A (x) B
    class function Create_Kron(A, B: TMatR): TMatR;

    // result = alfa * A + beta * B
    class function Create_Combinar(alfa: NReal; A: TMatR; beta: NReal;
      B: TMatR): TMatR;

    // crea un vector con las columnas concatenadas.
    // ver tambi�n la funci�n "reshape" de TVectR
    function vec: TVectR;


    // Calcula el menor complementario de una matriz
    function menor_complementario(fila, columna: integer): NReal;

    // Matriz adjunta
    function Crear_adjunta: TMatR;


    procedure identidad; // convierte la matriz a la identidad.

    // Crea la matriz Identidad
    class function Create_identidad(n: integer): TMatR;


  end;

  TDAofMatR = array of TMatR;


function sumaproducto(const v1, v2: TVectR): NReal;
function sumaproducto_ventana(const v1, v2: TVectR; kDesde, kHasta: integer): NReal;

procedure vswap(var v1, v2: TVectR); overload;

// devuelve un vector que aproxima F(X) como
// F(X.e(k)) = sum( result.e(k)* power(X.e(k), k-1 ) )
// en err devuelve la norma de la diferencia
// F(X.e(k)) - sum( result.e(k)* power(X.e(k), k-1 )
// Atenci�n, (n) es la cantidad de coeficientes del polinomio
// contando el t�rmino constante por lo que el grado del polinimo
// es (n-1).
function polAprox(X, F: TVectR; n: integer; var err: NReal): TVectR;


procedure QuickSortInc(var List: TDAofNReal; First, Last: integer);
procedure MonsterSortInc(var pv: TDAofNReal; k1, k2: integer; LargoTramo: integer);


(* se supone que los valores de a estan odenados entre los �ndices i1 e i2 en
forma creciente y buscamos la posici�n en que tendr�a que ir x en ese vector
si se agregara, de forma tal que sea inferior estricto a todos los de mayor o igual posici�n
y mayor o igual que los de posici�n inferior.
El resultado de la funci�n es la posici�n iRes donde ir�a el valor x.
Si iRes > i2 quiere decir que x es mayor o igual que todos los elementos de a en el rango
[i1..i2]. Si iRes=i1, quiere decir que x es menor que todos los elementos de a en el rango
[i1..i2]

La funci�n ubicar_creciente_der retorna la posici�n del array en la que ir�a
el valor x si se lo ubica a la derecha de todos los que son menores o iguales
que �l.
La funci�n ubicar_creciente_izq retorna la posici�n del array en la que ir�a
el valor x si se lo ubica a la izquierda de todos los que son mayores o iguales
que el.
*)
function ubicar_creciente_der(const a: TDAofNReal; i1, i2: integer; x: NReal): integer;
function ubicar_creciente_izq(const a: TDAofNReal; i1, i2: integer; x: NReal): integer;


(*
Calcula el promedio de un ramillete de realizaciones
*)
function Promedio_filtrando( cronicas_series: TDAofVectR; umbralFiltro: NReal): NReal;


(*
Calcula promedio y varianza de un ramillete de realizaciones.
*)
function PromedioVarianza_filtrando(
  out Prom, vrz: NReal;
  cronicas_series: TDAOfVectR;
  umbralFiltro: NReal;
  flg_vrz_nm1: boolean = True): integer;



implementation

uses
  udisnormcan; // aqu� para permitir referencia circular



function sumaproducto_ventana(const v1, v2: TVectR; kDesde, kHasta: integer): NReal;
var
  a: NReal;
  k: integer;
begin
  a := 0;
  for k := kDesde to kHasta do
    a := a + v1.e(k) * v2.e(k);
  Result := a;
end;

function sumaproducto(const v1, v2: TVectR): NReal;
begin
  Result := sumaproducto_ventana(v1, v2, 1, v1.n);
end;




function polAprox(X, F: TVectR; n: integer; var err: NReal): TVectR;
var
  XtX: TMatR;
  XtF: TMatR;
  k, j: integer;
  jpi: integer;
  xjck, xjcj: NReal;
  res: TVectR;

  fatx: NReal;
  invertible: boolean;
  e10: integer;

begin

  XtX := TMatR.Create_Init(n, n);
  XtF := TMatR.Create_init(n, 1);

  for k := 1 to n do
  begin
    // limpiamos la fila k
    XtF.pon_e(k, 1, 0);
    for j := 1 to n do
      XtX.pon_e(k, j, 0);


    for jpi := 1 to X.n do // indice de los productos interiores
    begin
      xjck := intpower(X.e(jpi), (k - 1));
      XtF.acum_e(k, 1, xjck * F.e(jpi));
      for j := k to n do
      begin
        xjcj := intpower(X.e(jpi), (j - 1));
        XtX.acum_e(k, j, xjck * xjcj);
      end;
    end;

    // simetrizamos
    for j := 1 to k - 1 do
      XtX.pon_e(k, j, XtX.e(j, k));
  end;

  // Eliminaci�n gaussiana sobre el sistema
  XtX.Escaler(XtF, invertible, e10);

  if not invertible then
    raise Exception.Create('matreal.polAprox - sistema no invertible');

  res := TVectR.Create_Init(n);
  for k := 1 to n do
    res.pon_e(k, XtF.e(k, 1));

  // c�lculo del error
  err := 0;
  for j := 1 to X.n do
  begin
    fatx := X.e(n);
    for k := n - 1 downto 1 do
    begin
      fatx := fatx * X.e(j) + res.e(k);
    end;
    err := err + sqr(fatx - F.e(j));
  end;
  err := sqrt(err);
  Result := res;
end;

procedure vswap(var v1, v2: TVectR);
var
  tv: TVectR;
begin
  tv := v1;
  v1 := v2;
  v2 := tv;
end;




function nextpal(var r: string; sep: string = #9): string;
var
  s: string;
  i: integer;
begin
  i := pos(sep, r);
  if i = 0 then
  begin
    s := trim(r);
    r := '';
  end
  else
  begin
    s := trim(copy(r, 1, i - 1));
    Delete(r, 1, i + length(sep) - 1);
  end;
  Result := s;
end;

/////////////////////////
procedure SectorOfAng_(ang: NReal; NSectores: integer; var kAng1, kAng2: integer;
  var peso1, peso2: NReal);
var
  rAng: NReal;
begin

  rAng := ang * NSectores / 360;
  kang1 := (trunc(rAng) mod NSectores) + 1;
  peso2 := frac(rAng);
  peso1 := 1 - peso2;
  kang2 := (kang1 mod NSectores) + 1;

end;
//////////////////////////////


function TMatR.Descomp_DW_PotenciaIterada(var D: TVectR; var W: TMatR): boolean;
var
  u: TVectR;
  raiz_lambda, lambda: NReal;
  A: TMatR;
  m, md: NReal;
  k, j, mk: integer;
  fin_iteracion: boolean;
  jColW: integer;
  flg_error: boolean;
  cnt_iters: integer;

begin
  A := TMatR.Create_Init(Self.nf, Self.nc);
  u := TVectR.Create_Init(Self.nc);
  A.Igual(Self);

  D := TVectR.Create_Init(nf);
  W := TMatR.Create_Init(Self.nf, Self.nc);
  W.Ceros;

  jColW := 0; // fila de W completada

  fin_iteracion := False;
  flg_error := False;

  while (not fin_iteracion) and (jColW < W.nc) and (not flg_error) do
  begin

    // busco la fila de m�xima norma, pues es un buen vector para
    // comenzar la iteraci�n
    md := A.Fila(1).ne2;
    mk := 1;
    for k := 2 to A.nf do
    begin
      m := A.Fila(k).ne2;
      if m > md then
      begin
        mk := k;
        md := m;
      end;
    end;

    if md <= 1e-12 then
    begin
      fin_iteracion := True;
      break;
    end;

    // bien me quedo con el vector inicial
    u.Igual(A.Fila(mk));
    u.HacerUnitario;

    // ahora iteramos hasta que converja
    cnt_iters := 0;
    repeat
      m := A.PotenciaIterada(u, lambda);
      Inc(cnt_iters)
    until (m < 1e-12) or (abs(lambda) < 1e-12) or (cnt_iters > 1000);

    if cnt_iters > 1000 then
      flg_error := True;

    if abs(lambda) < 1e-12 then
    begin
      fin_iteracion := True;
      break;
    end;

    // bien si llegu� hasta aqu� tengo un nuevo vector para W
    Inc(jColW);
    D.pon_e(jColW, lambda);
    for k := 1 to W.nf do
      W.pon_e(k, jColW, u.e(k));

    // A = A -  lambda * u.ut
    for k := 1 to A.nf do
    begin
      A.acum_e(k, k, -lambda * u.e(k) * u.e(k));
      for j := k + 1 to A.nc do
      begin
        m := lambda * u.e(k) * u.e(j);
        A.acum_e(k, j, -m);
        A.acum_e(j, k, -m);
      end;
    end;
  end;

  // si es necesario acorto las filas de W
  if (jColW > 0) and (not flg_error) then
  begin
    if jColW < W.nc then
    begin
      for k := 1 to W.nf do
        setlength(W.pm[k].pv, jColW + 1);
      W.nc := jColW;
    end;
  end
  else
  begin
    W.Free;
    W := nil;
    D.Free;
    D := nil;
  end;

  A.Free;
  u.Free;
  Result := not flg_error;
end;




(*
rch@201305172050
Suponemos que Self es sim�trica y buscamos una raiz W tal que W.Wt = Self

Las columnas del resultado pueden ser NULAS si la matriz Self tiene autovalores
nulos.

En la variable DimRes se retorna la cantidad de columnas no nulas del resultado
si fue posible completar el c�lculo o -1 si no fue posible.
*)
function TMatR.RaizPorPotenciaIterada(var dimRes: integer;
  flg_RaiseException: boolean): TMatR;
var
  u: TVectR;
  raiz_lambda, lambda: NReal;
  A, W: TMatR;
  m, md: NReal;
  k, j, mk: integer;
  fin_iteracion: boolean;
  jColW: integer;

begin
  A := TMatR.Create_Init(Self.nf, Self.nc);
  u := TVectR.Create_Init(Self.nc);
  A.Igual(Self);

  W := TMatR.Create_Init(Self.nf, Self.nc);
  W.Ceros;
  jColW := 0; // fila de W completada

  fin_iteracion := False;

  while (not fin_iteracion) and (jColW < W.nc) do
  begin

    // busco la fila de m�xima norma, pues es un buen vector para
    // comenzar la iteraci�n
    md := A.Fila(1).ne2;
    mk := 1;
    for k := 2 to A.nf do
    begin
      m := A.Fila(k).ne2;
      if m > md then
      begin
        mk := k;
        md := m;
      end;
    end;

    if md <= 1e-12 then
    begin
      fin_iteracion := True;
      break;
    end;

    // bien me quedo con el vector inicial
    u.Igual(A.Fila(mk));
    u.HacerUnitario;

    // ahora iteramos hasta que converja
    repeat
      m := A.PotenciaIterada(u, lambda);
    until (m < 1e-12) or (abs(lambda) < 1e-12);

    if abs(lambda) < 1e-12 then
    begin
      fin_iteracion := True;
      break;
    end;

    if lambda < 0 then
    begin
      fin_iteracion := True;
      jColW := -jColW - 1;
      if flg_RaiseException then
        raise Exception.Create('RaizPotenciaIterada ... tiene un autovalor NEGATIVO!');
      break;
    end;

    raiz_lambda := sqrt(lambda);

    // bien si llegu� hasta aqu� tengo un nuevo vector para W
    Inc(jColW);
    for k := 1 to W.nf do
      W.pon_e(k, jColW, raiz_lambda * u.e(k));

    // A = A -  lambda * u.ut
    for k := 1 to A.nf do
    begin
      A.acum_e(k, k, -lambda * u.e(k) * u.e(k));
      for j := k + 1 to A.nc do
      begin
        m := lambda * u.e(k) * u.e(j);
        A.acum_e(k, j, -m);
        A.acum_e(j, k, -m);
      end;
    end;

  end;


  DimRes := jColW;

  A.Free;
  u.Free;
  Result := W;
end;




constructor TMatR.CreateFromXLT(var f: textfile);
var
  k, j: integer;
  r: string;
  pal: string;
  a: NReal;
begin
  readln(f, r);
  pal := nextpal(r);
  nf := StrToInt(nextpal(r));
  pal := nextpal(r);
  nc := StrToInt(nextpal(r));
  Create_init(nf, nc);

  readln(f, r);

  for k := 1 to nf do
  begin
    readln(f, r);
    pal := nextpal(r);
    for j := 1 to nc do
    begin
      a := StrToFloat(nextpal(r));
      pon_e(k, j, a);
    end;
  end;
end;

constructor TMatR.CreateFromArchiXLT(const archi: string);
var
  f: textfile;
begin
  assignfile(f, archi);
  reset(f);
  createFromXLT(f);
  closefile(f);
end;

procedure TMatR.WriteXLT(var f: textfile);
var
  k, j: integer;
begin
  writeln(f, 'NFilas: '#9, nf, #9, 'NColumnas: '#9, nc);
  Write(f, ' ');
  for j := 1 to nc do
    Write(f, #9, j);
  writeln(f);

  for k := 1 to nf do
  begin
    Write(f, k);
    for j := 1 to nc do
      Write(f, #9, e(k, j));
    writeln(f);
  end;
end;

procedure TMatR.WriteArchiXLT(const archi: string);
var
  f: textfile;
begin
  assignfile(f, archi);
  rewrite(f);
  WriteXLT(f);
  closefile(f);
end;



function TMatR.Fila(k: integer): TVectR;
begin
  Fila := pm[k];
end;

function TMatR.QuitarFila(k: integer): TVectR;
var j: integer;
begin
  result:= pm[ k ];
  for j:= k to high(pm) - 1 do
    pm[j]:= pm[ j+1 ];
  nf:= nf-1;
end;

function TMatR.Crear_Columna(k: integer): TVectR;
var
  v: TVectR;
  kf: integer;
begin
  v := TVectR.Create_Init(nf);
  for kf := 1 to nf do
    v.pon_e(kf, e(kf, k));
  Result := v;
end;

procedure TMatR.Columna_MinMax(jCol: integer; var kmin, kmax: integer;
  var minimumVal, maximumVal: NReal);
var
  k: integer;
  m: NReal;

begin
  kmin := 1;
  kmax := 1;
  minimumVal := e(1, jCol);
  maximumVal := minimumVal;

  for k := 1 to nf do
  begin
    m := e(k, jCol);
    if m < minimumVal then
    begin
      minimumVal := m;
      kmin := k;
    end
    else
    if m > maximumVal then
    begin
      maximumVal := m;
      kmax := k;
    end;
  end;
end;


constructor TMatR.Create_Init_pm(filas, columnas: integer);
var
  k: integer;
begin
  inherited Create;
  setlength(pm, filas + 1); // la fila 1 la desperdicio
  nf := filas;
  nc := columnas;
end;


constructor TMatR.Create_Init(filas, columnas: integer);
var
  k: integer;
begin
  Create_Init_pm(filas, columnas);
  for k := 1 to filas do
    pm[k] := TVectR.Create_Init(columnas);
end;

constructor TMatR.Create_InitVal(filas, columnas: integer; valIni: NReal);
begin
  create_init( filas, columnas );
  fillval( valini );
end;


constructor TMatR.Create_FromMatOfNReal(a: TMatofNReal);
var
  k, j: integer;
begin
  Create_init(length(a), length(a[0]));
  for k := 1 to nf do
    for j := 1 to nc do
      pon_e(k, j, a[k - 1][j - 1]);
end;

constructor TMatR.Create_Clone(mrx: TMatR);
var
  k: integer;
begin
  inherited Create;
  setlength(pm, mrx.nf + 1); // la fila 1 la desperdicio
  nf := mrx.nf;
  nc := mrx.nc;
  for k := 1 to nf do
    pm[k] := TVectR.Create_Clone(mrx.pm[k]);
end;



procedure TMatR.Igual(x: TMatR);
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].Igual(x.pm[k]);
end;

procedure TMatR.IntercambieFilas(k1, k2: integer);
var
  t: TVectR;
begin
  t := pm[k1];
  pm[k1] := pm[k2];
  pm[k2] := t;
end;

procedure TMatR.Free;
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].Free;
  setlength(pm, 0);
  inherited Free;
end;

constructor TMatR.Create_Load(var S: TStream);
var
  k: integer;
begin
  inherited Create;
  S.Read(nf, sizeOf(nf));
  S.Read(nc, sizeOf(nc));
  setlength(pm, nf + 1);
  for k := 1 to nf do
    pm[k] := TVectR.Create_Load(s);
end;

constructor TMatR.CreateLoadFromFile(var f: textfile);
var
  k: integer;
begin
  inherited Create;
  readln(f, nf);
  readln(f, nc);
  setlength(pm, nf + 1);
  for k := 1 to nf do
    pm[k] := TVectR.CreateLoadFromFile(f);
end;

procedure TMatR.StoreInFile(var f: textfile);
var
  k: integer;
begin
  writeln(f, nf);
  writeln(f, nc);
  for k := 1 to nf do
    pm[k].StoreInFile(f);
end;



procedure TMatR.Store(var s: TStream);
var
  k: integer;
begin
  S.Write(nf, sizeOf(nf));
  S.Write(nc, sizeOf(nc));
  for k := 1 to nf do
    pm[k].Store(s);
end;

constructor TMatR.Create_Load_COMPRESS(var S: TStream);
var
  vmin, vmax, deltav: NReal;
  vdata: packed array of byte;
  a1: byte;
  a2: word;
  a4: cardinal;
  a8: qword;
  pvv: TDAofNReal;
  k, j: integer;
  flg_Constante: boolean;
  p1: ^byte;
  p2: ^word;
  p4: ^cardinal;
  p8: ^qword;
  nbytesPerValue: byte;

begin
  S.Read(nf, sizeOf(nf));
  S.Read(nc, sizeOf(nc));
  Create_Init( nf, nc );

  s.Read( nbytesPerValue, 1 );
  s.Read( vmin, SizeOF( vmin ) );
  s.Read( vmax, sizeOf( vmax ) );

  deltav:= vmax - vmin;

  flg_Constante:= deltav < 1e-30;

  if flg_Constante then
    vmax:= vmin;

  if flg_constante then exit;


  setlength( vdata, nf * nc * nbytesPerValue );

  s.Read( vdata, length( vdata ) );

  p1:= @vdata[0];
  p2:= @vdata[0];
  p4:= @vdata[0];
  p8:= @vdata[0];

  case nbytesPerValue of
  1:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         pvv[j]:= ( p1^ * deltav ) / $FF;
         inc( p1 );
       end;
     end;

  2:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         pvv[j]:= ( p2^ * deltav ) / $FFFF;
         inc( p2 );
       end;
     end;
  4:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         pvv[j]:= ( p4^ * deltav ) / $FFFFFFFF;
         inc( p4 );
       end;
     end;
  8:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         pvv[j]:= ( p8^ * deltav ) / $FFFFFFFFFFFFFFFF;
         inc( p8 );
       end;
     end;
  else
    raise exception.Create('TMatR.Create_Load_COMPRESS: nBytesPerValue=[1|2|4|8]' );
  end;
  setlength( vdata, 0 );

end;


procedure TMatR.Store_COMPRESS(var s: TStream; const nBytesPerValue: byte );
var
  vmin, vmax, deltav: NReal;
  vdata: packed array of byte;
  a1: byte;
  a2: word;
  a4: cardinal;
  a8: qword;
  pvv: TDAofNReal;
  k, j: integer;
  flg_Constante: boolean;
  p1: ^byte;
  p2: ^word;
  p4: ^cardinal;
  p8: ^qword;

begin
  self.MinMax( vmin, vmax );
  deltav:= vmax - vmin;

  s.write( nf, sizeof( nf ) );
  s.write( nc, sizeOf( nc ) );
  flg_Constante:= deltav < 1e-30;

  if flg_Constante then
    vmax:= vmin;
  s.Write( nbytesPerValue, 1 );
  s.write( vmin, SizeOF( vmin ) );
  s.write( vmax, sizeOf( vmax ) );

  if flg_constante then exit;


  setlength( vdata, nf * nc * nbytesPerValue );
  p1:= @vdata[0];
  p2:= @vdata[0];
  p4:= @vdata[0];
  p8:= @vdata[0];

  case nbytesPerValue of
  1:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         a1:= round( ( pvv[j] - vmin ) / deltav * $FF );
         p1^:= a1;
         inc( p1 );
       end;
     end;

  2:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         a2:= round( ( pvv[j] - vmin ) / deltav  * $FFFF );
         p2^:= a2;
         inc( p2 );
       end;
     end;
  4:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         a4:= round( ( pvv[j] - vmin ) / deltav  * $FFFFFFFF );
         p4^:= a4;
         inc( p4 );
       end;
     end;
  8:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         a8:= round( ( pvv[j] - vmin ) / deltav * $FFFFFFFFFFFFFFFF );
         p8^:= a8;
         inc( p8 );
       end;
     end;
  else
    raise exception.Create('TMatR.Store_COMPRESS: nBytesPerValue=[1|2|4|8]' );
  end;

 s.Write( vdata, length( vdata ) );
 setlength( vdata, 0 );
end;

function TMatR.e(k, j: integer): NReal;
begin
  e := pm[k].pv[j];
end;

procedure TMatR.pon_e(k, j: integer; x: NReal);
begin
  //writeln( 'TMatR.pon_e( ',k,', ', j ,', ', x, ' ) ');
  pm[k].pv[j] := x;
end;

procedure TMatR.acum_e(k, j: integer; x: NReal);
begin
  //writeln( 'TMatR.acum_e( ',k,', ', j , ', ', x, ' ) ');
  pm[k].pv[j] := +pm[k].pv[j] + x;
end;

procedure TMatR.pon_fila(kfil, jcol: integer; xv: array of NReal);
begin
  pm[kfil].pon_ev(jcol, xv);
end;

procedure TMatR.pon_columna(kfil, jcol: integer; xv: array of NReal);
var
  k: integer;
begin
  for k := 0 to high(xv) do
    pon_e(kfil + k, jcol, xv[k]);
end;

procedure TMatR.Transponer; // transpone la mamtriz actual
var
  k, j: integer;
  a: NReal;
  tpm: TDAOfVectR;
begin
  if nf = nc then
  begin
    for k := 1 to nf do
      for j := k + 1 to nc do
      begin
        a := e(k, j);
        pon_e(k, j, e(j, k));
        pon_e(j, k, a);
      end;
  end
  else
  begin
    tpm := pm;
    setlength(pm, nc + 1);
    for k := 1 to nc do
      pm[k] := TVectR.Create_Init(nf);

    for k := 1 to nf do
    begin
      for j := 1 to nc do
        pm[j].pon_e(k, tpm[k].e(j));
      tpm[k].Free;
    end;
    setlength(tpm, 0);
    k := nc;
    nc := nf;
    nf := k;
  end;
end;

function TMatR.Crear_Transpuesta: TMatR;
var
  m: TMatR;
  k, j: integer;
begin
  m := TMatR.Create_Init(nc, nf);
  for k := 1 to nf do
    for j := 1 to nc do
      m.pon_e(j, k, e(k, j));
  Result := m;
end;

function TMatR.Interpol2D(f, c: NReal): NReal;
var
  a1, a2, b1, b2: integer;
  s1, s2: NReal;
begin
  a1 := trunc(f);

  b1 := trunc(c);


  //condiciones de borde, si el elemento a interpolar (f,c) est� fuera de la matriz
  //se le asigna el valor del borde

  if a1 < 1 then
  begin
    a1 := 1;
    f := 1;
  end;
  if a1 >= self.nf then
  begin
    a1 := self.nf - 1;
    f := self.nf;
  end;
  if b1 < 1 then
  begin
    b1 := 1;
    c := 1;
  end;
  if b1 >= self.nc then
  begin
    b1 := self.nc - 1;
    c := self.nc;
  end;

  a2 := a1 + 1;
  b2 := b1 + 1;
  //interpolacion 2d
  //pm[a1].Print;
  //pm[a2].print;
  //s1:= pm[a1].interpol(c);
  //s2:= pm[a2].interpol(c);


  Result := (pm[a1].interpol(c)) * (a2 - f) + (pm[a2].interpol(c)) * (f - a1);
end;




function TMatR.InterpolCircularSectores(NSectores: integer;f, c: NReal): NReal;

var

  indf1, indf2: NReal;
  auxif1, auxif2: integer;
  auxiP1, auxiP2: NReal;

begin

  SectorOfAng_(f, NSectores, auxif1, auxif2, auxiP1, auxiP2);

  if c > self.nc then
    c := self.nc;
  if c < 1 then
    c := 1;

  Result := (pm[auxif1].interpol(c)) * auxiP1 +
    (pm[auxif2].interpol(c)) * auxiP2;
end;



function TMatR.serialize: string;
var
  k, j: integer;
  s: string;
begin
  //el vector es [nf|nc] [N11;N12;...N1nc][N21;...N2nc]...[Nnf1;Nnf2;...Nnfnc] //
  s := '[' + IntToStr(nf) + '|' + IntToStr(nc) + ']';
  for j := 1 to nf do
    for k := 1 to nc do
    begin
      s := s + '[';
      s := s + FloatToStrF(e(j, k), ffGeneral, 3, 4);
      s := s + ']'; //SysUtils.ListSeparator;
    end;

  Result := s;
end;

constructor TMatR.Create_unserialize(s: string);
var
  pal: string;
  i, j, nf, nc: integer;

begin

  pal := nextpal(s, '[');
  pal := nextpal(s, '|');
  nf := StrToInt(pal);
  pal := nextpal(s, ']');
  nc := StrToInt(pal);
  pal := nextpal(s, '[');

  self.Create_Init(nf, nc);

  for i := 1 to nf do
  begin

    //self.Print;
    // writeln(s);

    for j := 1 to nc do
    begin

      if j < nc then
      begin
        pal := nextpal(s, ']');
        //sysutils.ListSeparator );    No es confiable el listSeparator
        self.pon_e(i, j, StrToFloat(pal));
        pal := nextpal(s, '[');
      end

      else
      begin
        pal := nextpal(s, ']');
        self.pon_e(i, j, StrToFloat(pal));
        if i < nf then
          pal := nextpal(s, '[');
      end;

    end;
  end;
  // self.Print;
end;

function TMatR.serialize_pg: string;
var
  res: string;
  k: integer;

begin
  res:= '{';
  if nf > 0 then
  begin
    res:= res+ pm[1].serialize_pg;
    for k:= 2 to nf do
      res:= res +', '+ pm[k].serialize_pg;
  end;
  res:= res + '}';
  result:= res;
end;

constructor TMatR.Create_unserialize_pg(s: string; c_open: char = '{'; c_close: char = '}');
var
  cnt_Aperturas, cnt_Comas: integer;
  nfilas, ncolumnas: integer;
  k: integer;
  c: char;
  sfila: string;
   // { { 1, 2, 3}, { 3, 4, 5 } }
   // nComas:= ( nColumnas  - 1 ) * nFilas + ( nFilas - 1)
   // nColumnas = ( nComas - nFilas + 1 ) / nFilas + 1
begin
  cnt_Aperturas:= 0;
  cnt_Comas:= 0;
  for k:= 1 to length( s ) do
  begin
    c:= s[k];
    if c = c_open then inc( cnt_Aperturas )
    else if c = ',' then inc( cnt_Comas );
  end;
  nFilas:= cnt_Aperturas - 1;
  if nFilas > 0 then
    nColumnas:= ( cnt_Comas - nFilas + 1 ) div nFilas + 1
  else
    nFilas:= 0;

  Create_Init_pm( nFilas, nColumnas );

  nextpal( s, c_open );
  for k:= 1 to nFilas do
  begin
    sfila:=  c_open+nextPalEntre( s, c_open, c_close )+c_close;
    pm[k]:= TVectR.Create_unserialize_pg( sfila, c_open, c_close );
  end;
end;


procedure TMatR.unos;
var
  k: integer;
begin
  for k := 1 to self.nf do
    pm[k].unos;

end;

procedure TMatR.fillVal(val: NReal);
var
  k: integer;
begin
  for k := 1 to self.nf do
    pm[k].fillval( val );

end;

procedure TMatR.Print;
var
  k, j: integer;
begin
  writeln(' TVectR.print.inicio');
  writeln(nf: 6, ' filas ', nc: 6, ' columnas: ');
  for k := 1 to nf do
  begin

    for j := 1 to nc do

      Write(' ', e(k, j): 12: 3);
    writeln();
  end;
  writeln(' TVectR.print.fin');
end;

constructor TVectR.Create_Init(ne: integer );
var
  k: integer;
begin
  inherited Create;
  self.n := ne;
  setlength(pv, ne + 1);
end;

constructor TVectR.Create_InitVal(ne: integer; valIni: NREal );
var
  k: integer;
begin
  Create_init( ne );
  fillVal( valIni );
end;

(*constructor TVectR.CreateFromPlanillaConEncabezados(enc: string;
  xls: TLibroOpenCalc);
var
  fila,columna,ne:integer;
  buscando,seEncontro,hayDatos: boolean;
  datoAux:NReal;
  auxstr:string;
begin
  inherited Create;
  buscando:=true;
  hayDatos:=false;
  seEncontro:=false;
  ne:=0;

  while buscando do
  begin
    auxstr:=xls.ReadStr(fila,columna);//incrementa la columna
    if CompareStr(auxstr,enc) then
    begin
      writeln('se encontro el string');
      buscando:=false;
      seEncontro:=true;
    end;
    if CompareStr(auxstr,'') then
    begin
      writeln('no se encontro el string');
      buscando:=false;
      seEncontro:=false;
      hayDatos:=true;
    end;

   if seEncontro then
   begin
     //hay que levantar los valores
     while hayDatos do
     begin
      datoAux:=xls.ReadFloat(fila,columna); // ojo que te incrementa la columa este

       self.n := ne;
       setlength(pv, ne + 1);
       ne:=ne+1;
     end;
   end;

  end;
end; *)

constructor TVectR.Create_FromDAofR(a: TDAofNReal; init: integer);
var
  k: integer;
begin
  Create_init(length(a));
  for k := init to n - 1 + init do
    pv[k] := a[k - init];
end;

constructor TVectR.Create_Clone(vrx: TVectR);
var
  k: integer;
begin
  Create_init(vrx.n);
  for k := 0 to high(pv) do
    pv[k] := vrx.pv[k];
end;

procedure TVectR.Free;
begin
  setlength(pv, 0);
  inherited Free;
end;

constructor TVectR.Create_Load(var S: TStream);
begin
  inherited Create;
  S.Read(n, sizeOf(n));
  setlength(pv, n + 1);
  S.Read(pv[1], n * SizeOf(NReal));
end;

procedure TVectR.Store(var S: TStream);
begin
  S.Write(n, sizeOf(n));
  S.Write(pv[1], n * SizeOf(NReal));
end;


// Retorna la aproxiamaci�n de Hermite correspondiente a interpolar
// entre el punto (y_a, x_a) y (y_b, x_b) para la posici�n x siendo dydx_a y dydx_b
// la derivada de dy/dx en a y b respectivamente.
function hermit_yx(const x_a, y_a, dydx_a, x_b, y_b, dydx_b, x: NReal ): NReal;
var
  d, a, b, ac, bc, h, dydu_a, dydu_b: NReal;
  u, y: NReal;
begin
  d := (x_b - x_a);
  u := (x - x_a) / d;
  dydu_a := dydx_a * d;
  dydu_b := dydx_b * d;

  h := (1 - u) * u;

  a := u * u * (2 * u - 3) + 1;
  ac := 1 - a;

  b := h * (1 - u);
  bc := -h * u;

  y := a * y_a + b * dydu_a + ac * y_b + bc * dydu_b;

  Result := y;
end;




function TVectR.RellenarHuecos(umbral_Filtro: NReal): integer;
var
  idx: TDAOfNInt;
  cnt_iter, k, i: integer;
  cnt: integer;
  max_var, e_var: NReal;
  derivadas: TDAOfNReal;
  buscando: boolean;

  procedure calc_der(i: integer);
  begin
    if i > 0 then
    if i = 1 then
      derivadas[1] := 0 //pv[2] - pv[1]
    else if i < high(pv) then
      derivadas[i] := ( pv[i + 1] - pv[i-1] )/2.0
    else if i = high(pv) then
      derivadas[i] := 0; //pv[cnt] - pv[cnt - 1];
  end;


  function calc_hermit(i: integer): NReal;
  var
    y, y_ant, dd: NReal;
    ia, ib: integer;
  begin
    if i <= 1 then
    begin
      ia:= 2;
      ib:= 3;
    end
    else if i < N then
    begin
      ia:= i-1;
      ib:= i+1;
    end
    else
    begin
      ia:= N-1;
      ib:= N;
    end;
    y_ant := pv[i];
    y := hermit_yx( ia, pv[ia], derivadas[ia], ib, pv[ib], derivadas[ib], i );
    pv[i] := y;
    result := abs(y - y_ant);
  end;

begin
  setlength(idx, n);
  setlength(derivadas, n + 1);
  cnt := 0;
  for k := 1 to n do
    if pv[k] < umbral_Filtro then
    begin
      idx[cnt] := k;
      pv[k] := 0;
      Inc(cnt);
    end;


  if cnt > 0 then
  begin
    cnt_iter := 1;
    buscando := True;

    while buscando and (cnt_iter < 1000) do
    begin
      // recalculamos derivadas
      for k := 0 to cnt - 1 do
      begin
        i := idx[k];
        calc_der(i - 1);
        calc_der(i);
        calc_der(i + 1);
      end;
      max_var := 0;
      // Ahora calculamos la interpolaci�n
      for k := 0 to cnt - 1 do
      begin
        i := idx[k];
        e_var := calc_hermit(i);
        if e_var > max_var then
          max_var := e_var;
      end;

      if max_var < 1e-10 then
        buscando := False
      else
        inc( cnt_iter );
    end;
  end;
  result:= cnt;
end;

procedure TVectR.FiltrarV(pp, X: TVectR; DatNoValidos: TStringList);
var
  k: integer;
  p_t, error, Pmax: NReal;
begin
  Pmax := pp.MaxVal;
  if Pmax = 0 then
    exit;
  for k := 1 to pp.n do
  begin
    if ((DatNoValidos.IndexOf(IntToStr(trunc(pp.e(k)))) = -1) and
      ((DatNoValidos.IndexOf(IntToStr(trunc(e(k)))) = -1))) then
      p_t := x.e(1) / (1 + exp(-x.e(2) * (e(k) - x.e(3))));
    error := sqr(p_t - pp.e(k)) / Pmax;
    if (error > 3) then
      pon_e(k, -777777);
    writeln(k);
  end;
end;


constructor TVectR.CreateLoadFromFile(var f: textfile; n_: integer = -1);
var
  k: integer;
begin
  inherited Create;
  if n_ < 0 then
    readln(f, n)
  else
    n := n_;
  setlength(pv, n + 1);
  for k := 1 to n do
    readln(f, pv[k]);
end;


procedure TVectR.StoreInFile(var f: textfile);
var
  k: integer;
begin
  Writeln(f, n);
  for k := 1 to n do
    writeln(f, pv[k]);
end;

constructor TVectR.CreateLoadFromBinaryFile(var f: file; n_: integer);
var
  k: integer;
begin
  inherited Create;
  if n_ < 0 then
    blockread(f, n, sizeof(n))
  else
    n := n_;
  setlength(pv, n + 1);
  for k := 1 to n do
    blockread(f, pv[k], sizeOf(NReal));
end;

procedure TVectR.StoreInBinaryFile(var f: file);
var
  k: integer;

begin
  blockwrite(f, n, sizeOf(n));
  for k := 1 to n do
    blockwrite(f, pv[k], sizeof(NReal));
end;


procedure TVectR.Print(var s: string);
var
  k: integer;

begin
  s := '';
  writeln(' TVectR.print.inicio');
  for k := 1 to n do

  begin
    writeln(' N: ', k: 6, ' : ', e(k): 12: 4);
    s := s + '#9' + floattostr(e(k));
  end;
  writeln(' TVectR.print.fin');
end;

procedure TVectR.Print;
var
  k: integer;

begin

  //writeln(' TVectR.print.inicio');
  for k := 1 to n do
  begin
    Write(' ', e(k): 12: 3);
  end;
  writeln;
end;



function TVectR.interpol(kr: NReal): NReal;
var
  k1: integer;
begin
  k1 := trunc(kr);
  if k1 < 1 then
  begin
    Result := pv[1];
    exit;
  end;
  if k1 >= n then
  begin
    Result := pv[n];
    exit;
  end;
  Result := (pv[k1 + 1] - pv[k1]) * (kr - k1) + pv[k1];
end;

// inversa de la funci�n interpol. El valor devuelto es un n�mero
// real. Si res < 1 quiere decir que x es menor que el primer elemento
// de la tabla. Si res > n quiere decir que x es mayor que el �ltimo elemento
// del vector. Se supone que los elementos del vector est�n ordenados
// en forma creciente.
function TVectR.inv_interpol(x: NReal): NReal;
var
  i: integer;
  buscando: boolean;
  res: NReal;
  dy: NReal;
begin
  if n < 2 then
  begin
    if n = 0 then
      Result := -1
    else
    if x < pv[1] then
      Result := -1
    else if x > pv[1] then
      Result := 2
    else
      Result := 1;
    exit;
  end;

  i := 1;
  buscando := True;
  while buscando and (i < n) do
  begin
    if x <= pv[i] then
      buscando := False
    else
      Inc(i);
  end;

  if i = 1 then
  begin
    dy := (pv[2] - pv[1]);
    if abs(dy) > AsumaCero then
      res := 1 + (x - pv[1]) / dy
    else
    if x = pv[1] then
      res := 1
    else
      res := -1;
  end
  else
  begin
    dy := (pv[i] - pv[i - 1]);

    if abs(dy) > AsumaCero then
      res := i - 1 + (x - pv[i - 1]) / dy
    else
    if x = pv[n] then
      res := n
    else
      res := n + 1;
  end;

  Result := res;
end;

procedure TVectR.invertir_orden;
var
  aux: NReal;
  k: integer;
begin
  for k := 1 to (n div 2) do
  begin
    aux := pv[k];
    pv[k] := pv[n - k + 1];
    pv[n - k + 1] := aux;
  end;
end;

// Integral, etren dos reales asignando la parte de los intervaloes extremos
// de acuerdo a los n�meros reales.
function TVectR.integral(kr1, kr2: NReal): NReal;
var
  res: NReal;
  k1, k2: integer; // rango entero
  f1, f2: NReal;
  k: integer;

begin

  if kr2 < kr1 then
    raise Exception.Create('Error: TVectR.integral, kr2 <kr1 ');

  k1 := trunc(kr1);
  k2 := trunc(kr2);
  f1 := frac(kr1);
  f2 := frac(kr2);

  if (k1 < 1) then
  begin
    k1 := 1;
    f1 := 0;
  end;
  if (k2 > N) then
  begin
    k2 := N;
    f2 := 0;
    if k1 >= k2 then
    begin
      k1 := k2;
      f1 := 0;
    end;
  end;

  if (k2 > k1) then
  begin // no est�n en el mimso casillero
    if (f1 > 0) then // el primer casillero partido
      res := pv[k1] * (1 - f1)
    else
      res := pv[k1];
    for k := k1 + 1 to k2 - 1 do
      res := res + pv[k];
    if f2 > 0 then // el �ltimo casillero partido
      res := res + f2 * pv[k2]
    else
      res := res + pv[k2];
  end
  else
  begin // est�n los dos extremos dentro del mismo casillero
    res := pv[k1] * (f2 - f1);
  end;
  Result := res;
end;


// modifica el vector imponiendo en el casillero k, el promedio
// de los nPM casilleros on ordinal <= que k
// para los primeros nPM-1 casilleros el c�lculo se realiza con menos elementos
procedure TVectR.PromedioMovil(nPM: integer);
var
  a: NReal;
  k, j: integer;
  res, tres: TDAofNReal;
begin
  setlength(res, length(pv));

  for k := 1 to nPM do
  begin
    a := 0;
    for j := 1 to k do
      a := a + pv[j];
    a := a / k;
    res[k] := a;
  end;

  for k := nPM + 1 to N do
  begin
    a := a + (pv[k] - pv[k - nPM]) / nPM;
    res[k] := a;
  end;

  tres := pv;
  pv := res;
  setlength(tres, 0);

end;



procedure TVectR.PromedioMovil_Filtrado(nPM: integer; umbralFiltro: NReal);
var
  a, m: NReal;
  k, j: integer;
  res, tres: TDAofNReal;
  flg_Filtrado: boolean;
  valorFiltrado: NReal;

begin
  valorFiltrado := umbralFiltro - 1212.0;
  setlength(res, length(pv));

  for k := 1 to nPM - 1 do
  begin
    a := 0;
    flg_Filtrado := False;
    for j := 1 to k do
    begin
      m := pv[j];
      if m <= umbralFiltro then
      begin
        flg_Filtrado := True;
        break;
      end;
      a := a + m;
    end;
    if not flg_Filtrado then
    begin
      a := a / k;
      res[k] := a;
    end
    else
      res[k] := valorFiltrado;
  end;

  for k := nPM to N do
  begin
    a := 0;
    flg_Filtrado := False;
    for j := (k - nPM + 1) to k do
    begin
      m := pv[j];
      if m <= umbralFiltro then
      begin
        flg_Filtrado := True;
        break;
      end;
      a := a + m;
    end;
    if not flg_Filtrado then
    begin
      a := a / nPM;
      res[k] := a;
    end
    else
      res[k] := valorFiltrado;
  end;

  tres := pv;
  pv := res;
  setlength(tres, 0);
end;

// retorna la recta  a*k+b que mejor aproxima al conjunto
// de puntos del vector en el sentido de m�nimos cuadrados
procedure TVectR.AproximacionLineal(var a, b: NReal);
var
  ma, mb: TMatR;
  k: integer;
  prom_k2, prom_k, prom_uno, prom_k_yk, prom_yk: NReal;
  yk: NReal;
  invertible: boolean;
  e10: integer;

begin
  //  prom_k2:= 0;
  prom_k := (n + 1) / 2;
  prom_uno := 1;
  prom_k_yk := 0;
  prom_yk := 0;

  for k := 1 to n do
  begin
    yk := pv[k];
    prom_k_yk := prom_k_yk + k * yk;
    prom_yk := prom_yk + yk;
    //    prom_k2:= prom_k2 + k*k; // sustituir por resultado matem�tico sum(k2)
  end;
  prom_k_yk := prom_k_yk / n;
  prom_yk := prom_yk / n;
  prom_k2 := (((n) * (n + 1) * (2 * n + 1)) / (6 * n)) / n;

  ma := TMatR.Create_Init(2, 2);
  mb := TMatR.Create_Init(2, 1);

  ma.pon_e(1, 1, prom_k2);
  ma.pon_e(1, 2, prom_k);
  ma.pon_e(2, 1, prom_k);
  ma.pon_e(2, 2, prom_uno);

  mb.pon_e(1, 1, prom_k_yk);
  mb.pon_e(2, 1, prom_yk);

  ma.Escaler(mb, invertible, e10);
  if (not invertible) then
    raise Exception.Create('TVectR.AproximacionLineal res= 0');

  a := mb.e(1, 1);
  b := mb.e(2, 1);
end;




// retorna la recta  a*k+b que mejor aproxima al conjunto
// de puntos del vector en el sentido de m�nimos cuadrados
procedure TVectR.AproximacionLinealFiltrada(var a, b: NReal; umbralFiltro: NReal);
var
  ma, mb: TMatR;
  k: integer;
  prom_k2, prom_k, prom_uno, prom_k_yk, prom_yk: NReal;
  yk: NReal;
  invertible: boolean;
  e10: integer;
  cnt_Muestras: integer;

begin
  prom_k2 := 0;
  prom_k := 0;
  prom_uno := 1;
  prom_k_yk := 0;
  prom_yk := 0;

  ReadLn;

  cnt_Muestras := 0;
  for k := 1 to n do
  begin
    yk := pv[k];
    if yk > umbralFiltro then
    begin
      prom_k := prom_k + k;
      prom_k_yk := prom_k_yk + k * yk;
      prom_yk := prom_yk + yk;
      prom_k2 := prom_k2 + k * k;
      Inc(cnt_Muestras);
    end;
  end;

  prom_k := prom_k / cnt_Muestras;
  prom_k_yk := prom_k_yk / cnt_Muestras;
  prom_yk := prom_yk / cnt_Muestras;
  prom_k2 := prom_k2 / cnt_Muestras;

  ma := TMatR.Create_Init(2, 2);
  mb := TMatR.Create_Init(2, 1);

  ma.pon_e(1, 1, prom_k2);
  ma.pon_e(1, 2, prom_k);
  ma.pon_e(2, 1, prom_k);
  ma.pon_e(2, 2, prom_uno);

  mb.pon_e(1, 1, prom_k_yk);
  mb.pon_e(2, 1, prom_yk);

  ma.Escaler(mb, invertible, e10);
  if (not invertible) then
    raise Exception.Create('TVectR.AproximacionLineal res= 0');

  a := mb.e(1, 1);
  b := mb.e(2, 1);
end;



function TVectR.AproximacionLineal(var a, b: NReal; vx: TVectR): NReal;
var
  ma, mb: TMatR;
  k: integer;

  p_v_v, p_vx_vx, p_vx_1, p_vx_v, p_1_1, p_1_v: NReal;
  //  yk: NReal;
  invertible: boolean;
  e10: integer;
  errc: NReal;
begin
  //    vx * a+  1* b = v
  //   ( vx.vx )   ( vx. 1 ) = ( vx . v )
  //   ( 1 . vx )   ( 1. 1 ) =  ( 1 . v )

  p_vx_vx := 0;
  p_v_v := 0;
  p_vx_1 := 0;
  p_vx_v := 0;
  p_1_1 := 1;
  p_1_v := 0;
  for k := 1 to n do
  begin
    p_vx_vx := p_vx_vx + sqr(vx.pv[k]);
    p_v_v := p_v_v + sqr(pv[k]);
    p_vx_1 := p_vx_1 + vx.pv[k];
    p_vx_v := p_vx_v + vx.pv[k] * pv[k];
    p_1_v := p_1_v + pv[k];
  end;
  p_v_v := p_v_v / N;
  p_vx_vx := p_vx_vx / N;
  p_vx_1 := p_vx_1 / N;
  p_vx_v := p_vx_v / N;
  p_1_v := p_1_v / N;

  ma := TMatR.Create_Init(2, 2);
  mb := TMatR.Create_Init(2, 1);

  ma.pon_e(1, 1, p_vx_vx);
  ma.pon_e(1, 2, p_vx_1);
  ma.pon_e(2, 1, p_vx_1);
  ma.pon_e(2, 2, p_1_1);

  mb.pon_e(1, 1, p_vx_v);
  mb.pon_e(2, 1, p_1_v);

  ma.Escaler(mb, invertible, e10);
  if (not invertible) then
    raise Exception.Create('TVectR.AproximacionLineal res= 0');

  a := mb.e(1, 1);
  b := mb.e(2, 1);

  ma.Free;
  mb.Free;

  errc := (p_v_v - (sqr(a) * p_vx_vx + 2 * a * b * p_vx_1 + sqr(b) * P_1_1));
  Result := errc;
end;


function TVectR.AproximacionLinealFiltrada(var a, b: NReal; vx: TVectR;
  x1, x2: NReal; var cntMuestras: integer): NReal;
var
  ma, mb: TMatR;
  k: integer;
  errc: NReal;
  p_v_v, p_vx_vx, p_vx_1, p_vx_v, p_1_1, p_1_v: NReal;
  //  yk: NReal;
  invertible: boolean;
  e10: integer;

begin
  //    vx * a+  1* b = v
  //   ( vx.vx )   ( vx. 1 ) = ( vx . v )
  //   ( 1 . vx )   ( 1. 1 ) =  ( 1 . v )
  cntMuestras := 0;
  p_vx_vx := 0;
  p_v_v := 0;
  p_vx_1 := 0;
  p_vx_v := 0;
  p_1_1 := 1;
  p_1_v := 0;
  for k := 1 to n do
  begin
    if (x1 <= vx.pv[k]) and (vx.pv[k] < x2) then
    begin
      p_vx_vx := p_vx_vx + sqr(vx.pv[k]);
      p_v_v := p_v_v + sqr(pv[k]);
      p_vx_1 := p_vx_1 + vx.pv[k];
      p_vx_v := p_vx_v + vx.pv[k] * pv[k];
      p_1_v := p_1_v + pv[k];
      Inc(cntMuestras);
    end;
  end;

  if cntMuestras = 0 then
  begin
    a := 0;
    b := 0;
    Result := -1;
    exit;
  end;

  p_v_v := p_v_v / cntMuestras;
  p_vx_vx := p_vx_vx / cntMuestras;
  p_vx_1 := p_vx_1 / cntMuestras;
  p_vx_v := p_vx_v / cntMuestras;
  p_1_v := p_1_v / cntMuestras;

  ma := TMatR.Create_Init(2, 2);
  mb := TMatR.Create_Init(2, 1);

  ma.pon_e(1, 1, p_vx_vx);
  ma.pon_e(1, 2, p_vx_1);
  ma.pon_e(2, 1, p_vx_1);
  ma.pon_e(2, 2, p_1_1);

  mb.pon_e(1, 1, p_vx_v);
  mb.pon_e(2, 1, p_1_v);

  ma.Escaler(mb, invertible, e10);
  if (not invertible) then
    raise Exception.Create('TVectR.AproximacionLineal res= 0');

  a := mb.e(1, 1);
  b := mb.e(2, 1);

  ma.Free;
  mb.Free;

  errc := (p_v_v - (sqr(a) * p_vx_vx + 2 * a * b * p_vx_1 + sqr(b) * P_1_1));
  Result := errc;
end;


//Retorna una copia del vector en formato TDAOfNReal
//ATENCI�N, la copia es indexada desde 0
function TVectR.toTDAOfNReal(kDesde: integer = 1;
  kHasta: integer = -1 // -1 = hasta el final
  ): TDAofNReal;
var
  i: integer;
  res: TDAofNReal;
begin
  {$IFOPT R+}
  if kDesde < 1 then
    raise ERangeError.Create('TVectR.toTDAOfNReal kDesde < 1 ');
  if kHasta > n then
    raise ERangeError.Create('TVectR.toTDAOfNReal kHasta > ' + IntToStr(n));
  {$ENDIF}
  if kHasta < kDesde then
    SetLength(res, n)
  else
    setlength(res, kHasta - kDesde + 1);

  for i := 0 to high(res) do
    res[i] := pv[kDesde + i];
  Result := res;
end;

{
constructor TVectR.Ventana( ne: integer; var x );
begin
  TVect.Ventana( ne, SizeOf(NReal), x);
end;
 }


procedure TVectR.WriteXLTSimple(var f: textfile);
var
  j: integer;
begin
  //writeln(f, 'N: '#9, N);
  for j := 1 to N do
    Writeln(f, #9, e(j));
  writeln(f);
end;

procedure TVectR.WriteXLTSimple_archi(archi: string);
var
  f: textfile;
begin
  assignfile(f, archi);
  rewrite(f);
  WriteXLTSimple(f);
  closefile(f);

end;

procedure TVectR.WriteConsola;
var
  j: integer;
begin
  writeln('N: '#9, N);
  for j := 0 to N do
    Write(#9, e(j): 2: 0);
  writeln();
end;

// aplica funci�n de Hanning al vector
procedure TVectR.Aplicar_Hanning;  // 0.5 * ( 1 - cos ( (k-1) / N *2pi) )
var
  k: integer;
  w: NReal;
begin
  w := 2 * pi / N;
  for k := 1 to n do
    pv[k] := 0.5 * (1 - cos((k - 1) * w)) * pv[k];
end;


// Crea una matriz copiando por columna los valores del vector
function TVectR.reshape(nf, nc: integer): TMatR;
var
  res: TMatR;
  k, j, h: integer;
begin
  res := TMatR.Create_init(nf, nc);
  if (nf * nc) <> self.n then
    raise Exception.Create('TVect.reshape nf*nc <> n');
  h := 1;
  for j := 1 to nc do
    for k := 1 to nf do
    begin
      res.pon_e(k, j, self.e(h));
      Inc(h);
    end;
  Result := res;
end;


// Value At Risk. Supone que el vector representa un conjunto de valores
// de Costo equiprobables y que est�n ordenados en forma creciente.
// pe es la probabilidad de excedencia.
function TVectR.pe_VaR(pe: NReal): NReal;
var
  j: integer;
begin
  j := trunc((1 - pe) * n + 0.5);
  if j < 1 then
    j := 1
  else
  if j > n then
    j := n;
  Result := e(j);
end;

// Conditioned Value At Risk. Es el valor esperado de los costos m�s altos
// con probabilidad del conjunto pe.
// Se supone que el vector est� ordenado en forma creciente.
function TVectR.pe_CVaR(pe: NReal): NReal;
var
  j: integer;
  a: NReal;
  k: integer;
begin
  j := trunc((1 - pe) * n + 0.5);
  if j < 1 then
    j := 1
  else
  if j > n then
    j := n;
  a := e(j);
  for k := j + 1 to n do
    a := a + e(k);
  a := a / (n - j + 1);
  Result := a;
end;


function TVectR.pe_CVaR(pe1, pe2: NReal): NReal;
var
  ja, jb: integer;
  a: NReal;
  k: integer;
begin
  ja := trunc(pe1 * n + 0.5);
  if ja < 1 then
    ja := 1
  else
  if ja > n then
    ja := n;

  jb := trunc(pe2 * n + 0.5);
  if jb < 1 then
    jb := 1
  else
  if jb > n then
    jb := n;

  a := e(ja);
  for k := ja + 1 to jb do
    a := a + e(k);
  a := a / (jb - ja + 1);
  Result := a;
end;


function TVectR.serialize: string;
var
  k: integer;
  s: string;
begin
  s := '[ ' + IntToStr(n) + '|';
  for k := 1 to n do
  begin
    if k > 1 then
      s := s + '; '; //SysUtils.ListSeparator;
    s := s + ' ' + FloatToStr(pv[k]);
  end;
  Result := s + ']';
end;

constructor TVectR.Create_unserialize(s: string);
var
  pal: string;
  k: integer;

begin
  pal := nextpal(s, '[');
  pal := nextpal(s, '|');
  if s = '' then // no ven�a la dimensi�n separada
  begin
    s:= pal;

  end;
  n := StrToInt(pal);
  Create_init(n);
  for k := 1 to n - 1 do
  begin
    pal := nextpal(s, ';');
    //sysutils.ListSeparator );    No es confiable el listSeparator
    pon_e(k, StrToFloat(pal));
  end;
  pal := nextpal(s, ']');
  pon_e(n, StrToFloat(pal));
end;

function TVectR.serialize_pg: string;
var
  k: integer;
  res: string;
begin
  res:= '{';
  if  n > 0 then
  begin
    res:= res + FloatToStr( e(1 ) );
    for k:= 2 to n do
      res:= res+', ' + FloatToStr( e( k ) );
  end;
  res:= res +' }';
  result:= res;
end;

constructor TVectR.Create_unserialize_pg(s: string; c_open: char; c_close: char
  );
var
  k: integer;
  cnt: integer;
  pal: string;
begin
  cnt:= 0;
  for k:= 1 to length( s ) do
    if s[k] = ',' then inc( cnt );

  Create_init( cnt + 1 );

  pal:= nextpal(s, c_open );
  for k:= 1 to n-1 do
  begin
    pal:= nextpal( s, ',' );
    pv[k]:= StrToFloat( pal );
  end;
  pal:= nextpal( s, c_close );
  pv[n]:= StrToFloat( pal );
end;

function TVectR.clonar: TVectR;
var
  res: TVectR;
begin
  res := TVectR.Create_Clone(Self);
  Result := res;
end;

procedure TVectR.resize(nuevo_n: integer);
var
  k: integer;
begin
  setlength(pv, nuevo_n + 1);
  if nuevo_n > n then
    for k := n + 1 to nuevo_n do
      pv[k] := 0;
  n := nuevo_n;
end;

procedure TVectR.limpiar_huecos(huecos: TDAofNReal; DefVal: Nreal);
var
  Nhueco: integer;
  k: integer;
  j: integer;
begin
  Nhueco := High(huecos);
  for k := 0 to n do
    for j := 0 to Nhueco do
      if pv[k] = huecos[j] then
      begin
        pv[k] := defval;
        break;
      end;
end;

function TVectR.skewness(X: TVectR): NReal;
var
  k: integer;
  anom, aden: NReal;
  vm: NReal;
  d, d2: NReal;
begin
  anom := 0;
  aden := 0;
  vm := promedio;
  for k := 1 to X.n do
  begin
    d := x.pv[k] - vm;
    d2 := sqr(d);
    anom := anom + d2 * d;
    aden := aden + d2;
  end;
  anom := anom / X.n;
  aden := power(aden / X.n, 3.0 / 2.0);
  Result := anom / aden;
end;

function TVectR.kurtosis(X: TVectR): NReal;
var
  k: integer;
  anom, aden: NReal;
  vm: NReal;
  d, d2: NReal;
begin
  anom := 0;
  aden := 0;
  vm := promedio;
  for k := 1 to X.n do
  begin
    d := sqr(x.pv[k] - vm);
    d2 := sqr(d);
    anom := anom + d2;
    aden := aden + d;
  end;
  anom := anom / X.n;
  aden := sqr(aden / X.n);
  Result := anom / aden - 3;
end;

function TVectR.MaxDiff_CDF_N01: NReal;
var
  k: integer;
  diff, max_diff: NReal;
  CDF_Empirica, CDF_N01: NReal;
begin
  sort(True);
  // Error antes de la primera muestra.
  CDF_Empirica := 0;
  CDF_N01 := DistribucionNormalCanonica(pv[1]);
  diff := abs(CDF_N01 - CDF_Empirica);
  max_diff := diff;
  for k := 1 to N do
  begin
    CDF_Empirica := k / N;
    CDF_N01 := DistribucionNormalCanonica(pv[k]);
    diff := abs(CDF_N01 - CDF_Empirica);
    if diff > max_diff then
      max_diff := diff;
  end;
  Result := max_diff;
end;

function TVectR.e(k: integer): NReal;
begin
  e := pv[k];
end;

procedure TVectR.pon_e(k: integer; x: NReal);
begin
  pv[k] := x;
end;

procedure TVectR.acum_e(k: integer; x: NReal);
begin
  pv[k] := pv[k] + x;
end;

procedure TVectR.IntercambiarElementos(k1, k2: integer);
var
  x: NReal;
begin
  x := e(k1);
  pon_e(k1, e(k2));
  pon_e(k2, x);
end;


function TVectR.SumaDesdeHasta(i_izq, i_der: integer): NReal;
var
  k: integer;
  res: NReal;
begin
  res := 0;
  for k := i_izq to i_der do
    res := res + pv[k];
  Result := res;
end;

// copia los valores del vector xv a partir del kini  for k= 0 to high( xv ) do pon_e(ini+k, xv[k] ) ;
procedure TVectR.pon_ev(kini: integer; xv: array of NReal);
var
  k: integer;
begin
  for k := 0 to high(xv) do
    pv[kini + k] := xv[k]; //pon_e(kini+k, xv[k] )
end;

procedure TVectR.CopyFromTo(kIniOrigen, kFinOrigen, kIniDestino: integer;
  x: TVectR);
var
  k:integer;
begin
  for k:=kIniOrigen to kFinOrigen do
    pon_e(kIniDestino + k - kIniOrigen,x.e(k));
end;

(* se supone que los valores de a estan odenados entre los �ndices i1 e i2 en
forma creciente y buscamos la posici�n en que tendr�a que ir x en ese vector
si se agregara de forma tal que sea inferior estricto a todos los de mayor o iugal posici�n
y mayor o igual que los de posici�n inferior.
El resultado de la funci�n es la posici�n iRes donde ir�a el valor x.
Si iRes > i2 quiere decir que x es mayor o igual que todos los elementos de a en el rango
[i1..i2]. Si iRes=i1, quiere decir que x es menor que todos los elementos de a en el rango
[i1..i2]
*)
function ubicar_creciente_der(const a: TDAofNReal; i1, i2: integer; x: NReal): integer;
var
{$IFDEF UBICAR_CRECIENTE_RUSTICO}
  k: integer;
{$ELSE}
  buscando: boolean;
{$ENDIF}
  ix: integer;

begin
  { TODO : Testar UBICAR_CRECIENTE_RUSTICO y que de lo mismo que el otro. Tambi�n medir TIEMPOs. }
 {$IFDEF UBICAR_CRECIENTE_RUSTICO}
  ix := i2 + 1;
  for k := i1 to i2 do
  begin
    if x < a[k] then
    begin
      ix := k;
      break;
    end;
  end;
  Result := ix;
  {$ELSE}
  buscando := True;
  while buscando do
  begin
    ix := (i1 + i2) div 2;
    if a[ix] <= x then
      i1 := ix + 1
    else
      i2 := ix - 1;
    if i2 < i1 then
      buscando := False;
  end;
  Result := i1;
  {$ENDIF}
end;


function ubicar_creciente_izq(const a: TDAofNReal; i1, i2: integer; x: NReal): integer;
var
  {$IFDEF UBICAR_CRECIENTE_RUSTICO}
  k: integer;
  {$ELSE}
  buscando: boolean;
  {$ENDIF}
  ix: integer;
begin
  { TODO : Testear UBICAR_CRECIENTE_RUSTICO y medir tiempos con el otro }
  {$IFDEF UBICAR_CRECIENTE_RUSTICO}
  ix := i1;
  for k := i2 downto i1 do
  begin
    if a[k] < x then
    begin
      ix := k;
      break;
    end;
  end;
  Result := ix;
   {$ELSE}

  buscando := True;
  while buscando do
  begin
    ix := (i1 + i2) div 2;
    if a[ix] < x then
      i1 := ix + 1
    else
      i2 := ix - 1;
    if i2 < i1 then
      buscando := False;
  end;
  Result := i2;
  {$ENDIF}
end;



procedure OrdenarAgregandoDeAUno(var a: TDAofNReal; j1, j2: integer);
var
  k, j: integer;
  ix: integer;
  m: NReal;
begin
  for k := j1 + 1 to j2 do
  begin
    m := a[k];
    ix := ubicar_creciente_der(a, 1, k - 1, m);
    if ix < k then
    begin
      for j := k downto ix + 1 do
        a[j] := a[j - 1];
      a[ix] := m;
    end;
  end;
end;




(*-------------------------- Q U I C K   S O R T ---------------------*)
procedure Partition_QuickSortInc_idx(var A: TDAofNReal; var idx: TDAOfNInt;
  First, Last: integer);
var
  Right, Left: integer;
  V, z: NReal;
  ival: integer;
begin
  V := A[(First + Last) div 2];
  Right := First;
  Left := Last;
  repeat
    while (A[Right] < V) do
      Right := Right + 1;
    while (A[Left] > V) do
      Left := Left - 1;
    if (Right <= Left) then
    begin
      z := A[Right];
      A[Right] := A[Left];
      A[Left] := z;

      ival := idx[Right];
      idx[Right] := idx[Left];
      idx[Left] := ival;

      Right := Right + 1;
      Left := Left - 1;
    end;
  until Right > Left;
  if (First < Left) then
    Partition_QuickSortInc_idx(A, idx, First, Left);
  if (Right < Last) then
    Partition_QuickSortInc_idx(A, idx, Right, Last);
end;

procedure Partition_QuickSortInc(var A: TDAofNReal; First, Last: integer);
var
  Right, Left: integer;
  V, z: NReal;
begin
  V := A[(First + Last) div 2];
  Right := First;
  Left := Last;
  repeat
    while (A[Right] < V) do
      Right := Right + 1;
    while (A[Left] > V) do
      Left := Left - 1;
    if (Right <= Left) then
    begin
      z := A[Right];
      A[Right] := A[Left];
      A[Left] := z;
      Right := Right + 1;
      Left := Left - 1;
    end;
  until Right > Left;
  if (First < Left) then
    Partition_QuickSortInc(A, First, Left);
  if (Right < Last) then
    Partition_QuickSortInc(A, Right, Last);
end;


procedure Partition_QuickSortDec_idx(var A: TDAofNReal; var idx: TDAOfNInt;
  First, Last: integer);
var
  Right, Left: integer;
  V, z: NReal;
  ival: integer;
begin
  V := A[(First + Last) div 2];
  Right := First;
  Left := Last;
  repeat
    while (A[Right] > V) do
      Right := Right + 1;
    while (A[Left] < V) do
      Left := Left - 1;
    if (Right <= Left) then
    begin
      z := A[Right];
      A[Right] := A[Left];
      A[Left] := z;

      ival := idx[Right];
      idx[Right] := idx[Left];
      idx[Left] := ival;

      Right := Right + 1;
      Left := Left - 1;
    end;
  until Right > Left;
  if (First < Left) then
    Partition_QuickSortDec_idx(A, idx, First, Left);
  if (Right < Last) then
    Partition_QuickSortDec_idx(A, idx, Right, Last);
end;


procedure Partition_QuickSortDec(var A: TDAofNReal; First, Last: integer);
var
  Right, Left: integer;
  V, z: NReal;
begin
  V := A[(First + Last) div 2];
  Right := First;
  Left := Last;
  repeat
    while (A[Right] > V) do
      Right := Right + 1;
    while (A[Left] < V) do
      Left := Left - 1;
    if (Right <= Left) then
    begin
      z := A[Right];
      A[Right] := A[Left];
      A[Left] := z;
      Right := Right + 1;
      Left := Left - 1;
    end;
  until Right > Left;
  if (First < Left) then
    Partition_QuickSortDec(A, First, Left);
  if (Right < Last) then
    Partition_QuickSortDec(A, Right, Last);
end;


procedure QuickSortInc(var List: TDAofNReal; First, Last: integer);
begin
  if (First < Last) then
    Partition_QuickSortInc(List, First, Last);
end;


procedure QuickSortDec(var List: TDAofNReal; First, Last: integer);
begin
  if (First < Last) then
    Partition_QuickSortDec(List, First, Last);
end;



procedure QuickSortInc_idx(var List: TDAofNReal; var idx: TDAOfNInt;
  First, Last: integer);
begin
  if (First < Last) then
    Partition_QuickSortInc_idx(List, idx, First, Last);
end;


procedure QuickSortDec_idx(var List: TDAofNReal; var idx: TDAOfNInt;
  First, Last: integer);
begin
  if (First < Last) then
    Partition_QuickSortDec_idx(List, idx, First, Last);
end;



(*************** MONSTER_SORT *************)
procedure MonsterSortInc(var pv: TDAofNReal; k1, k2: integer; LargoTramo: integer);

var
  n: integer;
  jtramo: integer;
  nTramos: integer;
  ict: array of integer; // indice al comienzo del tramo
  net: array of integer; // n�mero de elementos en el tramo

  kini, kfin: integer;
  pv2: TDAOfNReal;
  ic: integer;
  jtmin, jt1: integer;
  xmin: NReal;
  buscando: boolean;
begin
  n := k2 - k1 + 1; // cantidad de elementos a ordenar
  nTramos := ((n - 1) div LargoTramo) + 1; // cantidad de tramos
  setlength(ict, nTramos + 1); // desperdicio el primer elemento
  setlength(net, nTramos + 1);

  for jtramo := 1 to nTramos - 1 do
  begin
    kini := (jtramo - 1) * LargoTramo + k1;
    ict[jtramo] := kini;
    kfin := kini + LargoTramo;
    net[jtramo] := LargoTramo;
    //    OrdenarAgregandoDeAUno( pv, kini, kfin );
    quicksortInc(pv, kini, kfin);
  end;

  kini := (nTramos - 1) * LargoTramo + k1;
  ict[nTramos] := kini;
  kfin := k2;

  net[nTramos] := kfin - kini + 1;
  quicksortInc(pv, kini, kfin);

  setlength(pv2, n);

  jt1 := 1;

  for ic := 1 to n do
  begin
    xmin := pv[ict[jt1]];
    jtmin := jt1;
    for jTramo := jt1 to NTramos do
    begin
      if (net[jtramo] > 0) then
      begin
        if pv[ict[jtramo]] < xmin then
        begin
          xmin := pv[ict[jtramo]];
          jtmin := jtramo;
        end;
      end;
    end;
    pv2[ic] := xmin;
    Inc(ict[jtmin]);
    Dec(net[jtmin]);

    if (net[jtmin] = 0) then
    begin
      if (jtmin = jt1) and (ic < n) then
      begin
        buscando := True;
        while buscando and (jt1 <= ntramos) do
          if net[jt1] > 0 then
            buscando := False
          else
            Inc(jt1);
      end;

    end;

  end;

  //copiamos el resultado
  for ic := 1 to n do
    pv[k1 + ic - 1] := pv2[ic];

  setlength(pv2, 0);
  setlength(ict, 0);
  setlength(net, 0);
end;


procedure TVectR.Sort(creciente: boolean);
begin
  if creciente then
    QuickSortInc(pv, 1, n)
  else
    QuickSortDec(pv, 1, n);
end;


procedure TVectR.Sort_idx(creciente: boolean; idx: TDAOfNInt);
begin
  if creciente then
    QuickSortInc_idx(pv, idx, 1, n)
  else
    QuickSortDec_idx(pv, idx, 1, n);
end;


// 1..n desordenada.
procedure TVectR.SortByIdx(idx: TDAOfNInt);
var
  pvaux: TDAofNReal;
  k: integer;
begin
  setlength(pvaux, length(pv));
  for k := 1 to n do
    pvaux[k] := pv[idx[k]];
  setlength(pv, 0);
  pv := pvaux;
end;

procedure TVectR.UnSortByIdx(idx: TDAOfNInt);
var
  pvaux: TDAofNReal;
  k: integer;
begin
  setlength(pvaux, length(pv));
  for k := 1 to n do
    pvaux[idx[k]] := pv[k];
  setlength(pv, 0);
  pv := pvaux;
end;


procedure TMatR.Ceros;
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].Ceros;
end;

procedure TMatR.MinMax(var kMin, jMin: integer; var kMax, jMax: integer;
  var Min, Max: NReal);
var
  k, j: integer;
  nuevo_min, nuevo_max: NReal;
  nuevo_jmin, nuevo_jmax: integer;
begin
  kmin := 1;
  kmax := 1;
  fila(1).MinMax(jMin, jMax, Min, Max);
  for k := 2 to nf do
  begin
    fila(k).MinMax(nuevo_jMin, nuevo_jMax, nuevo_min, nuevo_max);
    if nuevo_min < min then
    begin
      jmin := nuevo_jmin;
      kmin := k;
      min := nuevo_min;
    end;
    if nuevo_max > max then
    begin
      jmax := nuevo_jmax;
      kmax := k;
      max := nuevo_max;
    end;
  end;
end;

procedure TMatR.MinMax(var Min, Max: NReal);
var
  kmin, jmin, kmax, jmax: integer;
begin
  MinMax(kmin, jmin, kmax, jmax, Min, Max);
end;


// retorna el m�ximo
function TMatR.MaxVal: NReal;
var
  k: integer;
  res, m: NReal;
begin
  res := fila(1).maxVal;
  for k := 2 to nf do
  begin
    m := fila(k).MaxVal;
    if m > res then
      res := m;
  end;
  Result := res;
end;

// retorna el m�nimo
function TMatR.MinVal: NReal;
var
  k: integer;
  res, m: NReal;
begin
  res := fila(1).MinVal;
  for k := 2 to nf do
  begin
    m := fila(k).MinVal;
    if m < res then
      res := m;
  end;
  Result := res;
end;


procedure TMatR.CerosFila(kfil: integer);
var
  k: integer;
begin
  for k := 1 to nc do
    pm[kfil].Ceros;
end;

procedure TVectR.Ceros;
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := 0;
end;

procedure TVectR.Unos;
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := 1;
end;

procedure TVectR.FillVal(val: NREal);
var
  k: integer;
begin
  for k:= 1 to n do
    pv[k]:= val;

end;

procedure TVectR.MinMax(var kMin, kMax: integer; var Min, Max: NReal);
var
  m: NReal;
  k: integer;
begin
  Min := e(1);
  kMin := 1;
  Max := e(1);
  kMax := 1;

  for k := 2 to n do
  begin
    m := e(k);
    if m < min then
    begin
      Min := m;
      kMin := k;
    end
    else if m > max then
    begin
      Max := m;
      kMax := k;
    end;
  end;
end;


function TVectR.minVal: NReal;
var
  m: NReal;
  k: integer;
  res: NReal;
begin
  res := e(1);
  for k := 2 to n do
  begin
    m := e(k);
    if m < res then
      res := m;
  end;
  Result := res;
end;

function TVectR.maxVal: NReal;
var
  m: NReal;
  k: integer;
  res: NReal;
begin
  res := e(1);
  for k := 2 to n do
  begin
    m := e(k);
    if m > res then
      res := m;
  end;
  Result := res;
end;


(*

function TVectR.EstimFrec(
        var frecuencia: NReal;   { Estimacion de la frecuencia }
        nivel,            { Nivel de compoaracion }
        histeresis: NReal     { Histeresis del cruce }
        ): integer;         { Cantidad de cruces }

var
  Gatillado: integer;
  Periodos: LongInt;
  SumaDePeriodos: NReal;
  n1,n2: NReal;

function dknextcruce(var k, gatillo: integer): integer;
var
  k1, g1: integer;
begin
    k1:=k;
    g1:=gatillo;
    { Busqueda del cambio de signo de gatillo }
    while (Gatillo =g1)and(k<=N) do
      if e(k) > n1 then Gatillo:=1
      else if e(k)<n2 then Gatillo:= -1
      else inc(k);
    if Gatillo=g1 then dknextcruce:=-1
    else
    begin
      g1:=gatillo;
      { Busqueda del cambio de signo de gatillo }
      while (Gatillo =g1)and(k<=N) do
        if e(k) > n1 then Gatillo:=1
        else if e(k)<n2 then Gatillo:= -1
        else inc(k);
      if Gatillo=g1 then dknextcruce:=-1
      else dknextcruce:= k-k1;
    end;
end;

begin
  n1:=Nivel-Histeresis/2;
  n2:= n1+Histeresis;

  SumaDePeriodos:= 0;
  Periodos:= 0;
  k:=1;

  while (Gatillo = 0)and(k<=N) do
    if e(k) > n1 then Gatillo:=1
    else if e(k)<n2 then Gatillo:= -1
    else inc(k);
  if Gatillo = 0 then EstimFrec:=-1{ No podemos estimar con la histeresis }
  else
  begin
    Buscando:= true;
    while Buscando do
    begin
      dk:= dknextcruce( k, gatillo);
      if dk<0 then Buscando:=false
      else
      begin
        Periodos:= Periodos+1;
        SumaDePeriodos:= SumaDePeriodos+

*)



function TVectR.PEV(y: TVectR): NReal;
var
  k: integer;
  temp: NReal;
begin
  temp := 0;
  for k := 1 to n do
    temp := temp + pv[k] * y.pv[k];
  PEV := temp;
end;  (* PEV *)

function TVectR.PEV(y: TVectR; k1, k2: integer): NReal;
var
  k: integer;
  temp: NReal;
begin
  temp := 0;
  for k := k1 to k2 do
    temp := temp + pv[k] * y.pv[k];
  PEV := temp;
end;  (* PEV *)

function TVectR.PEV(const pv: PNReal): NReal;
var
  k: integer;
  temp: NReal;
  py: PNReal;
begin
  temp := 0;
  py := pv;
  for k := 1 to n do
  begin
    temp := temp + self.pv[k] * py^;
    Inc(py);
  end;
  PEV := temp;
end;  (* PEV *)

function TVectR.PEV(const pv: PNReal; k1, k2: integer): NReal;
var
  k: integer;
  temp: NReal;
  py: PNReal;
begin
  temp := 0;
  py := pv;
  Inc(py, k1 - 1);
  for k := 1 to n do
  begin
    temp := temp + self.pv[k] * py^;
    Inc(py);
  end;
  PEV := temp;
end;  (* PEV *)

function TVectR.PEVRFLX_(y: TVectR): NReal;
var
  k: integer;
  temp: NReal;
begin
  temp := 0;
  for k := 1 to n do
  begin
    temp := temp + e(k) * y.e(n - (k - 1));
  end;
  Result := temp;
end;  (* PEVRFLX *)

// norma euclidea al cuadrado de la diferencia
function TVectR.distancia2(y: TVectR): NReal;
var
  k: integer;
  temp: NReal;
begin
  temp := 0;
  for k := 1 to n do
  begin
    temp := temp + sqr(e(k) - y.e(k));
  end;
  Result := temp;
end;

function TVectR.distancia(y: TVectR): NReal;
begin
  Result := sqrt(distancia2(y));
end;

procedure TVectR.Igual(x: TVectR);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := x.pv[k];
end;

function TVectR.trim_fin: TvectR;
  {elimina los ceros al final}
begin
  while (self.e(n) = 0) and (n > 0) do
  begin
    SetLength(pv, n);
    self.n := n - 1;
  end;
  Result := self;
end;

procedure TVectR.Copy(const x: TVectR);
var
  k: integer;
begin
  for k := 1 to x.n do
    pon_e(k, x.e(k));
end;

procedure TVectR.Copy(const x: TDAOfNReal);
var
  k: integer;
begin
  resize(length(x));
  for k := 1 to n do
    pon_e(k, x[k - 1]);
end;

procedure TVectR.CopyTo(var x: TVectR);
var
  k: integer;
begin
  if x.n <> n then
   x.resize( n );
  for k := 1 to x.n do
    x.pon_e(k, e(k));
end;

procedure TVectR.CopyTo(var x: TDAOfNReal);
var
  k: integer;
begin
  if length( x ) <> n then
    setlength( x, n );
  for k := 1 to n do
    x[k - 1]:= e(k);
end;

// self = a+b
procedure TVectR.suma(a, b: TVectR);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := a.pv[k] + b.pv[k];
end;


procedure TVectR.sum(y: TVectR);
var
  k: integer;
begin
  for k := 1 to n do
    pon_e(k, e(k) + y.e(k));
end;

procedure TVectR.sumSiDiferente(y: TVectR; Cero: Nreal);
var
  k: integer;
begin
  for k := 1 to n do
  begin
    if y.e(k) <> Cero then
      pon_e(k, e(k) + y.e(k));
  end;
end;

procedure TVectR.resSiDiferente(y: TVectR; Cero: Nreal);
var
  k: integer;
begin
  for k := 1 to n do
  begin
    if y.e(k) <> Cero then
      pon_e(k, e(k) - y.e(k));
  end;
end;


procedure TVectR.sumXVectSiYDiferente(x: TVectR; y: TVectR; Cero: Nreal);
var
  k: integer;
begin
  for k := 1 to n do
  begin
    if y.e(k) <> Cero then
      pon_e(k, e(k) + x.e(k));
  end;
end;

procedure TVectR.sumXEscSiYDiferente(x: Nreal; y: TVectR; Cero: Nreal);
var
  k: integer;
begin
  for k := 1 to n do
  begin
    if y.e(k) <> Cero then
      pon_e(k, e(k) + x);
  end;
end;

procedure TVectR.sumXEscSiYDiferenteConConsignaYFiltrado(x: Nreal;
  y: TVectR; h: TStringList; z: TVectR; tolerancia: NReal);
var
  k: integer;
  MaxZ: NReal;
begin
  MaxZ := z.maxVal;
  for k := 1 to n do
  begin
    if ((z.e(k) > tolerancia * Maxz) and (h.IndexOf(IntToStr(trunc(y.e(k)))) = -1) and
      ((h.IndexOf(IntToStr(trunc(z.e(k)))) = -1))) then
      pon_e(k, e(k) + x);
  end;
end;

procedure TVectR.sumXVectSiYDiferenteConConsignaYFiltrado(x: TVectR;
  y: TVectR; h: TStringList; z: TVectR; tolerancia: NReal);
var
  k: integer;
  MaxZ: NReal;
begin
  MaxZ := z.maxVal;
  for k := 1 to n do
  begin
    if ((z.e(k) > tolerancia * Maxz) and (h.IndexOf(IntToStr(trunc(y.e(k)))) = -1) and
      ((h.IndexOf(IntToStr(trunc(z.e(k)))) = -1)) and
      (((h.IndexOf(IntToStr(trunc(x.e(k)))) = -1)))) then
      pon_e(k, e(k) + x.e(k));
  end;
end;


procedure TVectR.sumXVectSiYDiferenteConConsignaYFiltrado2(x: TVectR;
  y: TVectR; w: TVectR; h: TStringList; z: TVectR; tolerancia: NReal);
var
  k: integer;
  MaxZ: NReal;
begin
  MaxZ := z.maxVal;
  for k := 1 to n do
  begin
    if ((z.e(k) > tolerancia * Maxz) and (h.IndexOf(IntToStr(trunc(y.e(k)))) = -1) and
      ((h.IndexOf(IntToStr(trunc(z.e(k)))) = -1)) and
      (((h.IndexOf(IntToStr(trunc(x.e(k)))) = -1))) and
      (((h.IndexOf(IntToStr(trunc(w.e(k)))) = -1)))) then
      pon_e(k, e(k) + x.e(k));
  end;
end;


procedure TVectR.resXVectSiYDiferenteConConsignaYFiltrado(x: TVectR;
  y: TVectR; h: TStringList; z: TVectR; tolerancia: NReal = 0.95);
var
  k: integer;
  MaxZ: NReal;

begin

  MaxZ := z.maxVal;
  for k := 1 to n do
  begin
    if ((z.e(k) > tolerancia * Maxz) and (h.IndexOf(IntToStr(trunc(x.e(k)))) = -1) and
      (h.IndexOf(IntToStr(trunc(y.e(k)))) = -1) and
      ((h.IndexOf(IntToStr(trunc(z.e(k)))) = -1))) then
      pon_e(k, e(k) - x.e(k))
    else
      pon_e(k, -777777);
  end;
end;


procedure TVectR.sumAbs(y: TVectR);
var
  k: integer;
begin
  for k := 1 to n do
    pon_e(k, e(k) + abs(y.e(k)));
end;

procedure TVectR.res(y: TVectR);
var
  k: integer;
begin
  for k := 1 to n do
    pon_e(k, e(k) - y.e(k));
end;

procedure TVectR.resConConsigna(y: TVectR; z: TVectR; tolerancia: NReal);
var
  k: integer;
  MaxZ: NReal;
begin
  MaxZ := z.maxVal;
  for k := 1 to n do
    if z.e(k) > tolerancia * Maxz then
      pon_e(k, e(k) - y.e(k))
    else
      pon_e(k, -777777);
end;

procedure TVectR.resConDatosNoValidos(y: TVectR; DatNoValidos: TStringList;
  rellenarCon: NReal);
var
k: integer;
begin
  for k := 1 to n do
  begin
    if ((DatNoValidos.IndexOf(IntToStr(trunc(y.e(k)))) = -1) and ((DatNoValidos.IndexOf(IntToStr(trunc(e(k)))) = -1))) then
      pon_e(k, e(k) - y.e(k))
    else
      pon_e(k, rellenarCon);
  end;
end;

function TVectR.sumatotal: NReal;
var
  k: integer;
  aux: NReal;
begin
  aux := 0;
  for k := 1 to n do
    aux := aux + e(k);
  Result := aux;
end;


procedure TVectR.sum0(y: TVectR);   //idem que sum pero desde el elemento 0
var
  k: integer;
begin
  for k := 0 to n do
    pon_e(k, e(k) + y.e(k));
end;

procedure TVectR.sumRPV(r: NReal; x: TVectR);
var
  k: integer;
begin
  for k := 1 to n do
    pon_e(k, e(k) + r * x.e(k));
end;


function TVectR.FourierEval(angRad: NReal): NReal;
var
  NArmonicos: integer;
  k: integer;
  res: NReal;
begin
  res := e(1);
  NArmonicos := (n - 1) div 2;
  for k := 1 to NArmonicos do
    res := res + e(k + 1) * cos(k * angRad) + e(k + 1 + NArmonicos) *
      sin(k * angRad);
  Result := res;
end;

procedure TVectR.PorReal(r: NReal; kDesde: integer = 1);
var
  k: integer;
begin
  for k := kDesde to n do
    pv[k] := pv[k] * r;
  //    pon_e(k, e(k)*r);
end;

procedure TVectR.MasReal(r: NReal);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := pv[k] + r;
  //    pon_e(k, e(k)+r);
end;

procedure TVectR.porRMasB(r, b: NReal);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := pv[k] * r + b;
end;

function TVectR.porVectorElementoAElemento(y: TVectR): TVectR;
var
  res: TVectR;
  i: integer;
begin
  res := TVectR.Create_Init(n);
  for i := 1 to n do
    res.pv[i] := pv[i] * y.pv[i];
  Result := res;
end;


procedure TVectR.divVectorElementoAElemento(y: TVectR);
var
  k: integer;
begin
  for k := 1 to n do
    if y.e(k) <> 0 then
      pon_e(k, e(k) / y.e(k))
    else
      pon_e(k, -777777);
end;




function TVectR.ne2: NReal; {norma euclideana al cuadrado }
var
  k: integer;
  acum: NReal;
begin
  acum := 0;
  for k := 1 to n do
    acum := acum + e(k) * e(k);
  Result := acum;
end;


procedure TVectR.PromedioVarianza(var prom, vrz: NReal; flg_vrz_nm1: boolean = True);
var
  k: integer;
begin
  prom := promedio;
  vrz := 0;
  for k := 1 to n do
    vrz := vrz + sqr(pv[k] - prom);

  if flg_vrz_nm1 then
    vrz := vrz / (n - 1)
  else
    vrz := vrz / n;

end;

function TVectR.varianza(flg_vrz_nm1: boolean = True): NReal;
var
  prom, vrz: NReal;
begin
  promedioVarianza(prom, vrz, flg_vrz_nm1);
  Result := vrz;
end;

procedure TVectR.promedioDesvEst(var prom, desvEst: NReal; flg_vrz_nm1: boolean);
var
  varianza: NReal;
begin
  promedioVarianza(prom, varianza, flg_vrz_nm1);
  desvEst := sqrt(varianza);
end;

procedure TVectR.PorReal_filtrando(umbralFiltro, r: NReal);
var
  k: integer;
begin
  for k := 1 to N do
  begin
    if pv[k] > umbralFiltro then
      pv[k] := pv[k] * r;
  end;
end;

procedure TVectR.MasReal_filtrando(umbralFiltro, r: NReal);
{ if pv[k] > umbralFiltro then pv[k]:= pv[k] + r }
var
  k: integer;
begin
  for k := 1 to N do
  begin
    if pv[k] > umbralFiltro then
      pv[k] := pv[k] + r;
  end;
end;

function TVectR.PromedioVarianza_filtrando( out Prom, vrz: NReal;
  umbralFiltro: NReal; flg_vrz_nm1: boolean = True): integer;
var
  k: integer;
  acum: NReal;
  cnt: integer;
  m: NReal;
begin
  prom := promedio_filtrando(umbralFiltro);
  acum := 0;
  cnt := 0;
  for k := 1 to n do
  begin
    m := pv[k];
    if m > umbralFiltro then
    begin
      acum := acum + sqr(m - prom);
      Inc(cnt);
    end;
  end;
  if flg_vrz_nm1 then
    vrz := acum / (cnt - 1)
  else
    vrz := acum / cnt;
  result:= cnt;
end;


function PromedioVarianza_filtrando(
  out Prom, vrz: NReal;
  cronicas_series: TDAOfVectR;
  umbralFiltro: NReal;
  flg_vrz_nm1: boolean = True): integer;
var
  k: integer;
  kCronica: integer;
  acum: NReal;
  cnt: integer;
  m: NReal;
  v: TVectR;

begin
  prom := promedio_filtrando(cronicas_series, umbralFiltro);
  acum := 0;
  cnt := 0;

  for kCronica:= 0 to high( cronicas_series ) do
  begin
    v:= cronicas_series[kCronica];
    for k := 1 to v.n do
    begin
      m := v.pv[k];
      if m > umbralFiltro then
      begin
        acum := acum + sqr(m - prom);
        Inc(cnt);
      end;
    end;

  end;
  if flg_vrz_nm1 then
    vrz := acum / (cnt - 1)
  else
    vrz := acum / cnt;
  result:= cnt;
end;



function TVectR.Varianza_filtrando(umbralFiltro: NReal; flg_vrz_nm1: boolean): NReal;
var
  prom: NReal;
  vrz: NReal;
begin
  PromedioVarianza_filtrando(Prom, vrz, umbralFiltro, flg_vrz_nm1);
  Result := vrz;
end;


function TVectR.promedio: NReal;
var
  a: NReal;
  k: integer;
begin
  a := 0;
  for k := 1 to n do
    a := a + pv[k];
  Result := a / n;
end;

function TVectR.promedioVentana(kDesde, NElementos: integer): NReal;
var
  a: NReal;
  k: integer;
begin
  a := 0;
  for k := 0 to NElementos - 1 do
    a := a + pv[kDesde + k];
  Result := a / NElementos;
end;


{ Calcula el m�ximo desde kDesde de NElementos }
function TVectR.maxVentana(kDesde, NElementos: integer): NReal;
var
  a: NReal;
  k: integer;
begin
  a := pv[kDesde];
  for k := 1 to NElementos - 1 do
    if pv[kDesde + k] > a then
      a := pv[kDesde + k];
  Result := a;
end;

{ Calcula el m�nimo desde kDesde de NElementos }
function TVectR.minVentana(kDesde, NElementos: integer): NReal;
var
  a: NReal;
  k: integer;
begin
  a := pv[kDesde];
  for k := 1 to NElementos - 1 do
    if pv[kDesde + k] < a then
      a := pv[kDesde + k];
  Result := a;
end;


function TVectR.Promedio_filtrando(umbralFiltro: NReal): NReal;
var
  a: NReal;
  k: integer;
  cnt: integer;
  m: NReal;
begin
  a := 0;
  cnt := 0;
  for k := 1 to n do
  begin
    m := pv[k];
    if m > umbralFiltro then
    begin
      a := a + m;
      Inc(cnt);
    end;
  end;
  Result := a / cnt;
end;



function Promedio_filtrando( cronicas_series: TDAofVectR; umbralFiltro: NReal): NReal;
var
  a: NReal;
  k: integer;
  cnt: integer;
  m: NReal;
  v: TVectR;
  kCron: integer;
begin
  a := 0;
  cnt := 0;
  for kCron:= 0 to high( cronicas_series ) do
  begin
    v:= cronicas_series[kCron];
    for k := 1 to v.n do
    begin
      m := v.pv[k];
      if m > umbralFiltro then
      begin
        a := a + m;
        Inc(cnt);
      end;
    end;

  end;
  Result := a / cnt;
end;



function TVectR.desviacionEstandar: NReal;
begin
  Result := sqrt(varianza(False));
end;

function TVectR.desviacionEstandar_nm1: NReal;
begin
  Result := sqrt(varianza(True));
end;

function TVectR.normEuclid: NReal;
begin
  normEuclid := sqrt(ne2);
end;

function TVectR.normMaxAbs: NReal;
var
  k: integer;
  m, maxA: NReal;
begin
  m := ABS(e(1));
  maxA := m;
  for k := 2 to n do
  begin
    m := ABS(e(k));
    if m > maxA then
      maxA := m;
  end;
  normMaxAbs := maxA;
end;

function TVectR.normSumAbs(init: integer = 1): NReal;
var
  k: integer;
  acum: NReal;
begin
  acum := 0;
  for k := init to n do
    acum := acum + ABS(e(k));
  normSumAbs := acum;
end;


function TVectR.normSum(init: integer): NReal;
var
  k: integer;
  acum: NReal;
begin
  acum := 0;
  for k := init to n do
    acum := acum + e(k);
  normSum := acum;
end;

function TVectR.normSumSI(vacio: NReal): NReal;
var
  k: integer;
  acum: NReal;
begin
  acum := 0;
  for k := 1 to n do
  begin
    if e(k) <> vacio then
      acum := acum + e(k);
  end;
  normSumSI := acum;

end;

function TVectR.normSumxReal(f: NReal): NReal;
var
  k: integer;
  acum: NReal;
begin
  acum := 0;
  for k := 1 to n do
    acum := acum + e(k) * f;
  Result := acum;
end;

/// Funcion que elimina los elementos con valor 0 y acorta el vector
function TVectR.Vector_filter(): TVectR;
var
  k, j: integer;
begin
  for k := 1 to n do
  begin
    if (self.pv[k] = 0) then
    begin
      for j := k to n - 1 do
      begin
        self.pv[j] := self.pv[j + 1];
        self.n := self.n - 1;
      end;
    end;
    if (self.pv[n] = 0) then
    begin
      self.n := self.n - 1;
    end;
  end;
  Result := self;
end;


procedure TVectR.random(madreUniforme: Tf_ddpUniformeRand3);
var
  k: integer;
  x: NReal;
  sorteadorUniforme: Tf_ddpUniformeRand3;
begin
  if madreUniforme = nil then
    sorteadorUniforme := Tf_ddpUniformeRand3.Create(nil, integer(System.RandSeed))
  else
    sorteadorUniforme := madreUniforme;
  for k := 1 to n do
  begin
    x := sorteadorUniforme.rnd;
    pv[k] := x;
  end;
  if madreUniforme = nil then
    sorteadorUniforme.Free;
end;


procedure TVectR.versor_randomico(madreUniforme: Tf_ddpUniformeRand3 = nil);
var
  k: integer;
  acum: NReal;
  x: NReal;
  sorteadorUniforme: Tf_ddpUniformeRand3;
  buscando: boolean;

begin
  if madreUniforme = nil then
    sorteadorUniforme := Tf_ddpUniformeRand3.Create(nil, System.RandSeed)
  else
    sorteadorUniforme := madreUniforme;
  buscando := True;
  while buscando do
  begin
    acum := 0;
    for k := 1 to n do
    begin
      x := 0.5 - sorteadorUniforme.rnd;
      pv[k] := x;
      acum := acum + x * x;
    end;
    acum := sqrt(acum);
    if acum > AsumaCero then
    begin
      acum := 1 / acum;
      for k := 1 to n do
        pv[k] := pv[k] * acum;
      buscando := False;
    end;
  end;

  if madreUniforme = nil then
    sorteadorUniforme.Free;
end;


function TVectR.coefcorr(y: TVectR; kdesp: integer; filtrar: boolean;
  umbralFiltro: NReal): NReal;
var
  a: NReal;
  k: integer;
  m: integer;
  v1, v2: NReal;
  cnt_Filtrados: integer;
begin
  if kdesp < 0 then
    Result := y.coefcorr(Self, -kdesp, filtrar, umbralFiltro)
  else
  begin
    a := 0;
    m := n - kdesp;
    if m > 0 then
    begin
      if not Filtrar then
      begin
        for k := 1 + kdesp to n do
          a := a + pv[k - kdesp] * y.pv[k];
        Result := a / m;
      end
      else
      begin
        cnt_Filtrados := 0;
        for k := 1 + kdesp to n do
        begin
          v1 := pv[k - kdesp];
          v2 := y.pv[k];
          if (v1 > umbralFiltro) and (v2 > umbralFiltro) then
            a := a + v1 * v2
          else
            Inc(cnt_Filtrados);
        end;

        Result := a / (m - cnt_Filtrados);
      end;
    end
    else
      Result := 0;
  end;
end;

function TVectR.coefcorr_Pearson(y: TVectR; kdesp: integer; filtrar: boolean;
  umbralFiltro: NReal): NReal;
var
  xy_sum: NReal;
  k: integer;
  m: integer;
  v1, v2: NReal;
  cnt_Filtrados: integer;
  x_sum, y_sum, x_sum2, y_sum2, x_med, y_med: NReal;
begin
  if kdesp < 0 then
    Result := y.coefcorr_Pearson(Self, -kdesp, filtrar, umbralFiltro)
  else
  begin
    xy_sum := 0;
    x_sum := 0;
    y_sum := 0;
    x_sum2 := 0;
    y_sum2 := 0;
    cnt_Filtrados := 0;
    m := n - kdesp;
    if m > 0 then
    begin
      if not Filtrar then
      begin
        for k := 1 + kdesp to n do
        begin
          v1 := pv[k - kdesp];
          v2 := y.pv[k];
          xy_sum := xy_sum + v1 * v2;
          x_sum := x_sum + v1;
          y_sum := y_sum + v2;
          x_sum2 := x_sum2 + power(v1, 2);
          y_sum2 := y_sum2 + power(v2, 2);
        end;
      end
      else
      begin
        for k := 1 + kdesp to n do
        begin
          v1 := pv[k - kdesp];
          v2 := y.pv[k];
          if (v1 > umbralFiltro) and (v2 > umbralFiltro) then
          begin
            xy_sum := xy_sum + v1 * v2;
            x_sum := x_sum + v1;
            y_sum := y_sum + v2;
            x_sum2 := x_sum2 + power(v1, 2);
            y_sum2 := y_sum2 + power(v2, 2);
          end
          else
            Inc(cnt_Filtrados);
        end;
      end;
      m := m - cnt_Filtrados;
      x_med := x_sum / m;
      y_med := y_sum / m;
      Result := (xy_sum - m * x_med * y_med) /
        ((power(x_sum2 - m * x_med * x_med, 0.5)) *
        (power(y_sum2 - m * y_med * y_med, 0.5)));
    end
    else
      Result := 0;
  end;
end;


{ Calcula el coeficiente entre los vectores, para el paso kPaso suponiendo
que en el vector existen ciclos.
kPaso puede tomar valores en [0..nPasosPorCiclo]
overlapping indica la cantidad de casillero adyacentes a la izquierda y a la
derecha el casillero de la muestra en quela muetra ser� considerada.
Por ejemplo overlapping= 3 indica que cada muestra debe considerarse como v�lida
en el casillero v�lido, en los tres anteriores y en los tres siguientes.
Por lo tanto si overlapping=3, dado un kPaso el coeficiente de correlaci�n
ser� calculado considerando las muestras correspondiente al kPaso (en cada cilclo
del vectror) m�s overlapping meustras posteriores y anteriores a ese kPaso.

En cnt_muestras retorna la cantidad de puntos con que hizo el promedio.
OJO, si es CERO quiere desir que NO hay puntos!!! y la funci�n devuelve CERO.

Si el Par�metro Normalizar = TRUE, el coeficiente de correlaci�n se calcula
y se divide por la norma de cada vector de forma de asegurar que si son coolineales
el resultado es 1.

if kdesp >= 0 then
  result:= < self[k-kdesp], y[k]>
else
  result:= < y[k- kdesp], self[k ]>
}
function TVectR.coefcorr_multiciclo(y: TVectR; kdesp: integer;
  filtrar: boolean; umbralFiltro: NReal; kPaso: integer; nPasosPorCiclo: integer;
  overlapping: integer; var cnt_muestras: integer; Normalizar: boolean;
  archi_dbg: string): NReal;

var
  a1, a2: NReal;
  a: NReal;
  k: integer;
  v1, v2: NReal;
  //  cnt_Filtrados: integer;
  j: integer;
  jOverlap: integer;
  buscando: boolean;

  f: textfile;

begin

  if kdesp < 0 then
    Result := y.coefcorr_multiciclo(self, -kdesp, filtrar, umbralFiltro,
      kPaso, nPasosPorCiclo, overlapping, cnt_muestras, normalizar, archi_dbg)
  else
  begin
    if kdesp >= nPasosPorCiclo then
      raise Exception.Create('TVectR.coefcorr_MultiCiclo, kdesp >= nPasosPorCiclo');


    assignfile(f, archi_dbg);
    rewrite(f);
    if (not filtrar) then
      writeln(f, 'SIN FILTRADO')
    else
      writeln(f, 'CON FILTRADO');

    a := 0;
    a1 := 0;
    a2 := 0;

    cnt_muestras := 0;

    for jOverlap := -overlapping to overlapping do
    begin
      j := 1 + kdesp + kPaso + jOverlap;
      k := j - kdesp;
      buscando := True;
      while buscando and (j <= n) do
      begin
        if k >= 1 then
          buscando := False
        else
        begin
          Inc(j, nPasosPorCiclo);
          k := j - kdesp;
        end;
      end;

      if buscando then
      begin
        Result := 0; // no hay datos
        exit;
      end;


      if not Filtrar then
      begin
        while (j <= n) do
        begin

          writeln(f, k, #9, pv[k - kdesp], #9, k - kdesp, #9, y.pv[k]);

          a := a + pv[k - kdesp] * y.pv[k];
          Inc(cnt_muestras);
          Inc(k, nPasosPorCiclo);
        end;
      end
      else
      begin
        //        cnt_Filtrados:= 0;
        while k <= n do
        begin
          v1 := pv[k - kdesp];
          v2 := y.pv[k];
          if (v1 > umbralFiltro) and (v2 > umbralFiltro) then
          begin
            if Normalizar then
            begin
              a1 := a1 + v1 * v1;
              a2 := a2 + v2 * v2;
            end;
            a := a + v1 * v2;
            Inc(cnt_muestras);
            writeln(f, k, #9, pv[k - kdesp], #9, k - kdesp, #9, y.pv[k], #9, 1);

          end
          else
            writeln(f, k, #9, pv[k - kdesp], #9, k - kdesp, #9, y.pv[k], #9, 0);

{          else
            inc( cnt_Filtrados );}
          Inc(k, nPasosPorCiclo);
        end;
      end;
    end;


    writeln(f, 'cnt_muestras:', #9, cnt_muestras);
    writeln(f, 'a:', #9, a);
    writeln(f, 'a1:', #9, a1);
    writeln(f, 'a2:', #9, a2);

    if cnt_muestras > 0 then
    begin
      a := a / cnt_muestras;
      if Normalizar then
      begin
        a1 := sqrt(a1 / cnt_muestras);
        a2 := sqrt(a2 / cnt_muestras);
        a := a / (a1 * a2);

        writeln(f, 'NORMALIZANDO');
      end;
      writeln(f, 'result:', #9, a);
      Result := a;
    end
    else
    begin
      Result := 0;
      writeln(f, 'result:', #9, 0);
    end;

  end;

  closefile(f);
end;


procedure TMatR.WriteM;
var
  k, J: integer;
begin
  writeln;
  writeln('---------------------------------------');
  for k := 1 to nf do
  begin
    Write('fila', k: 3, '):');
    for j := 1 to nc do
      Write(e(k, j): 12: 4);
    writeln;
  end;
end;


constructor TMatR.Create_ReadM; (* a debe estar sin inicializar *)
var
  k, J: integer;
  m: NReal;
begin

  writeln;
  writeln('---------------------------------------');
  Write('numero de filas=?');
  readln(k);
  Write('numero de columnas=?');
  readln(j);
  Create_init(k, j);
  for k := 1 to nf do
  begin
    Write('fila', k: 3, '):?');
    for j := 1 to nc do
    begin
      Read(m);
      pon_e(k, j, m);
    end;
    writeln;
  end;
end;

procedure Combinar(Eliminada, Eliminador: TVectR; Col1, Col2: integer; m: NReal);
var
  j: integer;
begin
  for j := Col1 to Col2 do
    Eliminada.pon_e(j, Eliminada.e(j) + Eliminador.e(j) * m);
end;


procedure Combinar_conIndexadorDeColumnas(Eliminada, Eliminador: TVectR;
  Col1, Col2: integer; m: NReal; pidx: TDAofNInt);
var
  j: integer;
  jj: integer;
begin
  for jj := Col1 to Col2 do
  begin
    j := pidx[jj];
    Eliminada.pon_e(j, Eliminada.e(j) + Eliminador.e(j) * m);
  end;
end;

procedure Print_HeapStatus;
var
  hs: TFPCHeapStatus;

begin
  hs := GETFPCHeapStatus;
  Write('MS: ', hs.MaxHeapSize); //Maximum allowed size for the heap, in bytes
  Write('MU: ', hs.MaxHeapUsed); //Maximum used size for the heap, in bytes
  Write('CS: ', hs.CurrHeapSize); //Current heap size, in bytes
  Write('CU: ', hs.CurrHeapUsed); //Currently used heap size, in bytes
  Write('CF: ', hs.CurrHeapFree); //Currently free memory on heap, in bytes
  writeln;

end;


function TMatR.Escaler(var i: TMatR; var invertible: boolean;
  var exp10: integer): NReal;
{$ifdef testdeter }
  procedure muestre;
  begin
    writeM;
    i.writeM;
    readln;
    writeln('===============');
  end;

{$endif}

var
  k, p, j: integer;
  ms: NReal;
  det, m, mc1: NReal;
  mult_10, div_10: cardinal;


  procedure mantener_escala_det;
  begin
    if abs(det) > 1e3 then
    begin
      repeat
        det := det / 10.0;
        Inc(mult_10);
      until abs(det) < 1e3;
    end
    else if abs(det) < 1e-3 then
    begin
      repeat
        det := det * 10.0;
        Inc(div_10);
      until abs(det) > 1e-3;
    end;
  end;

begin
  exp10 := 0;
  mult_10 := 0;
  div_10 := 0;

  invertible := True;
  p := 1;
  det := 1;
  {esca1}
  while invertible and (p < nf) do
  begin
  {$ifdef testdeter }
    muestre;
  {$endif}

    m := abs(e(p, p));
    j := p;

    for k := p + 1 to nf do
    begin
      ms := abs(e(k, p));
      if ms > m then
      begin
        m := ms;
        j := k;
      end;
    end;

    if p <> j then
    begin
      IntercambieFilas(p, j);
      i.IntercambieFilas(p, j);
      det := -det;
    end;

    if m <= AsumaCero then
    begin
      det := 0;
      invertible := False;
      p := nf;
    end
    else{eliminacion}
    begin
      mc1 := e(p, p);
      det := det * mc1;
      if det <> 0 then
      begin
        mantener_escala_det;
        for k := p + 1 to nf do
        begin
          m := -e(k, p) / mc1;
          Combinar(pm[k], pm[p], p + 1, nc, m);
          Combinar(i.pm[k], i.pm[p], 1, i.nc, m);
        end;
      end
      else
        invertible := False;
    end;
    p := p + 1;

  end;(* while *)

  det := det * e(nf, nf);
  if invertible and (det <> 0) then
  begin
    mantener_escala_det;

    if not EsCero(det) then
    begin{esca2}

      for k := 1 to nf do
      begin
      {$ifdef testdeter }
        muestre;
      {$endif}
        mc1 := 1 / e(k, k);
        i.pm[k].PorReal(mc1);
        for j := nc downto k + 1 do
          pon_e(k, j, e(k, j) * mc1);
      end;

      for p := nf downto 2 do
        for k := p - 1 downto 1 do
        begin
          mc1 := -e(k, p);
          Combinar(i.pm[k], i.pm[p], 1, i.nc, mc1);
        end;
    end
    else
      invertible := False;
  end;

  exp10 := mult_10 - div_10;
  Escaler := det;
{$ifdef testdeter }
  muestre;
{$endif}
end {deter};



procedure TMatR.CopyColVect(var Y: TVectR; J: integer);
var
  k: integer;
begin
  for k := 1 to nf do
    y.pon_e(k, e(k, j));
end;  (* CopyColVect *)


procedure TMatR.CopyVectCol(const Y: TVectR; j: integer);
var
  k: integer;
begin
  for k := 1 to nf do
    pon_e(k, j, Y.e(k));
end;

function TMatR.Traza: NReal;
var
  k: integer;
  temp: NReal;

begin
  temp := e(1, 1);
  for k := 2 to nc do
    temp := temp + e(k, k);
  Result := temp;
end; (* Traza *)

procedure TMatR.PolinomioCaracteristico(var P: TPoliR);

var
  pr: NReal;
  k, j: integer;
  m: TMatR;
begin
  m := TMatR.Create_Init(nf, nc);
  p.gr := nc;
  m.igual(Self);
  pr := m.Traza;
  p.a[p.gr] := 1;
  p.a[p.gr - 1] := -pr;
  for k := 2 to p.gr do
  begin
    for j := 1 to p.gr do
      m.acum_e(j, j, -pr);
    m.Mult(m, self);
    pr := m.Traza / k;
    p.a[p.gr - k] := -pr;
  end;
  p.a[p.gr] := 1;
  m.Free;
end; (* PolinomioCaracteristico *)



procedure TMatR.PorReal(r: NReal);
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].PorReal(r);
end;

procedure TMatR.Mult(a, b: TMatR);
var
  k, j: integer;
  v: TVectR;
  mtemp: TMatR;
begin
  v := TVectR.Create_init(b.nf);
  mtemp := TMatR.Create_init(a.nf, a.nc);
  mtemp.igual(a);

  for j := 1 to b.nc do
  begin
    b.CopyColVect(v, j);
    for k := 1 to A.nf do
      pon_e(k, j, TVectR(mtemp.pm[k]).PEV(v));
  end;
  mtemp.Free;
  v.Free;
end;  (* MultTMatR *)

procedure TMatR.porMatrizElementoAElemento(y: TMatR);
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k] := pm[k].porVectorElementoAElemento(y.pm[k]);

end;

procedure TMatR.PotenciaElementoAElemento(Pot: Nreal);
var
  k, j: integer;
begin
  for k := 1 to nf do
    for j := 1 to nc do
      self.pon_e(k, j, power(self.e(k, j), Pot));
end;

procedure TMatR.MaximizarElementoAElemento(ValMin: Nreal);
var
  k, j: integer;
begin
  for k := 1 to nf do
    for j := 1 to nc do
      self.pon_e(k, j, max(self.e(k, j), ValMin));
end;

function TMatR.SumarTodosLosElementos: NReal;
var
  res: NReal;
  k, j: integer;
begin
  res := 0;
  for k := 1 to nf do
    for j := 1 to nc do
      res := res + self.e(k, j);
  Result := res;
end;

procedure TMatR.Suma(a, b: TMatR);
var
  kfila: integer;
begin
  for kfila := 1 to nf do
    TVectR(pm[kfila]).Suma(a.pm[kfila], b.pm[kfila]);
end;

procedure TMatR.Transformar(var y: TVectR; x: TVectR);
var
  k: integer;
begin
  for k := 1 to nf do
    y.pon_e(k, x.PEV(pm[k]));
end;  (* Transformar *)

function TMatR.FormaCuadratica(x: TVectR): NReal;
var
  a: NReal;
  k: integer;
begin
  a := 0;
  for k := 1 to nf do
    a := x.e(k) * x.PEV(pm[k]);
  Result := a;
end;

function TMatR.NormMaxAbs: NReal;
var
  k: integer;
  m, ms: NReal;
begin
  m := pm[1].NormMaxAbs;
  for k := 2 to nf do
  begin
    ms := pm[k].NormMaxAbs;
    if ms > m then
      m := ms;
  end;
  NormMaxAbs := m;
end;

function TMatR.Deter: NReal;
var
  temp1, temp2: TMatR;
  invertible: boolean;
  e10: integer;
begin
  temp1 := TMatR.Create_init(nf, nc);
  temp1.igual(Self);
  temp2 := TMatR.Create_init(nf, 0);
  deter := temp1.escaler(temp2, invertible, e10) * Math.power(10, e10);
  temp2.Free;
  temp1.Free;
end;

function TMatR.Inv(var det: NReal): boolean;
var
  temp: TMatR;
  k, j: integer;
  invertible: boolean;
  e10: integer;
begin
  temp := TMatR.Create_init(nf, nc);
  for k := 1 to nf do
    for j := 1 to nc do
      if k = j then
        temp.pon_e(k, j, 1)
      else
        temp.pon_e(k, j, 0);

  det := escaler(temp, invertible, e10);
  det := det * power(10, e10);
  Self.igual(temp);
  temp.Free;
  Inv := invertible;
end;



function TMatR.Inv: boolean;
var
  det: NReal;
begin
  Result := inv(det);
end;


{
OJO esta en desarrollo
retorna la dimensi�n del subespacio NULO.
La matriz deve ser cuadrada (hasta que se revise el algoritmo }
function TMatR.CalcBSEN(var Base: TMatR): integer;
var
  k, p, j: integer;
  itmp: integer;
  det, m, mc1: NReal;
  redundancia: integer;
  pidxCol, pidxFil: TDAofNInt;
  buscando: boolean;
  xCeroPivote: NReal;
  ms: NReal;
  RangoMaximo, Rango: integer;
begin
  p := 1;
  det := 1;
  redundancia := 0;

  { Relajaci�n del cero de la m�quina para tener encuenta acumulacion
  de errores. /La eleccion de este valor esta realmente complicada. }
  xCeroPivote := 1e-12;

  { inicializacion del direccionador de columnas }
  setlength(pidxCol, nc + 1);
  for k := 1 to nc do
    pidxCol[k] := k;

  setlength(pidxFil, nf + 1);
  for k := 1 to nf do
    pidxFil[k] := k;

  // M�ximo del rango del subespacio generado por las columnas
  RangoMaximo := min(nf, nc);

  {esca1}
  {Escalerizo sin sustituir hacia atras}
  while p <= RangoMaximo - redundancia do
  begin

    { busqueda del mejor pivote }
    repeat
      m := abs(e(p, pidxCol[p]));
      j := p;
      for k := p + 1 to nf do
      begin
        ms := abs(e(k, pidxCol[p]));
        if ms > m then
        begin
          m := ms;
          j := k;
        end;
      end;

      { si es necesario intercambiar las filas }
      if p <> j then
      begin
        IntercambieFilas(p, j);
        itmp := pidxFil[p];
        pidxFil[p] := pidxFil[j];
        pidxFil[j] := itmp;
        det := -det;
      end;

      {      writeln( abs(m) ); readlN; }
      if Casi0(m, xCeroPivote) then  { pivote nulo }
      begin
        det := 0;
        // intercambio indicies de las columnas
        itmp := pidxCol[p];
        pidxCol[p] := pidxCol[nc - redundancia];
        pidxCol[nc - redundancia] := itmp;
        Inc(redundancia);
        buscando := True;
      end
      else
        buscando := False;
    until not buscando or (p > (RangoMaximo - redundancia));

    if not buscando then
    begin
      {eliminacion}
      mc1 := e(p, pidxCol[p]);
      det := det * mc1;
      mc1 := 1 / mc1;
      for k := p + 1 to nf do
      begin
        m := -e(k, pidxCol[p]) * mc1;
        Combinar_conIndexadorDeColumnas(pm[k], pm[p], p + 1, nc, m, pidxCol);
      end;
    end;
    Inc(p); { incremento el pivote }
  end;(* while *)

  //  det := det*e(nf,nc); lo comento porque no se usa

  { Resultado de la funci�n }
  Rango := p - 1;
  redundancia := nc - Rango;
  CalcBsen := redundancia;

  Base := TMatR.Create_init(redundancia, nc);
  if redundancia = 0 then
    exit; { nada que hacer }

  for k := 1 to Rango do
  begin
    mc1 := 1 / e(k, pidxCol[k]);
    for j := nc downto k + 1 do
      pon_e(k, pidxCol[j], e(k, pidxCol[j]) * mc1);
  end;

  { Escalerizaci�n  hacia arriba en el bloque no redundante
  modificando el bloque redundante }
  for p := Rango downto 2 do
    for k := p - 1 downto 1 do
    begin
      mc1 := e(k, pidxCol[p]);
      for j := rango + 1 to rango + redundancia do
        pon_e(k, pidxCol[j],
          e(k, pidxCol[j]) - e(p, pidxCol[j]) * mc1);
    end;

  {
  Un vector del subespacio nulo V lo partimos en dos V1 el conjunto
  de variables NO redundantes y V2 el conjunto de las redundantes
  debiendose cumplir:

  I V1 + B V2 = 0 => V1 = -BV2 .

  donde B es la matriz d (n-redundancia)x(redundancia) que queda en
  la esquina superior derecha de la matriz que estamos procesando.

  Observar que considerando la primer componente de V2 igual a 1 y
  todas las demas 0 y despejando el vector V1 correspondiente
  tenemos un vector del subespacio nulo. As� con el mismo procedimiento
  sobre cada una de las (redundancia) componentes de V2 obtenemos
  una base del espacio nulo que es lo que estamos buscando. Por
  construcci�n los vectores son Linealmente Independientes (LI).
  }


  {Copia el resultado }
  (***** aqui dudo si tengo que desindexar las filas ????
  for k := 1 to redundancia do
  begin
    for j := 1 to Rango do
      base.pon_e(k, pidxFil[j], -e(j, pidxCol[Rango + k]));
    for j := Rango + 1 to nf do
      base.pon_e(k, pidxFil[j], 0);
    base.pon_e(k, pidxFil[Rango + k], 1);
  end;
  ***)

  // ??? pruebo copiar sin desindexar
  for k := 1 to redundancia do
  begin
    for j := 1 to Rango do
      base.pon_e(k, j, -e(j, pidxCol[Rango + k]));
    for j := Rango + 1 to nc do
      base.pon_e(k, j, 0);
    base.pon_e(k, Rango + k, 1);
  end;


  { libero memoria}
  setlength(pidxCol, 0);
  setlength(pidxFil, 0);
end;

{ Calcula una base del subespacio invariante asociado a un autovalor
real dado }
function TMatR.CalcBSE_R(var Base: TMatR; av: NReal): integer;
var
  k: integer;
begin
  { Hacer coincidir el subespacio asociado a la raiz con el
  subespacio nulo }
  for k := 1 to nf do
    pon_e(k, k, e(k, k) - av);
  CalcBSE_R := CalcBSEN(Base);
end;

{ Calcula una base del subespacio invariate asociado a un par de
autovalores complejos conjugados }
function TMatR.CalcBSE_PCC(var Base: TMatR; av: NComplex): integer;
var
  k: integer;
  tm: TMatR;
  ed: NReal;
begin
  { Es lo mismo que calcular el nucleo de
    ( A*A - 2*av.r*A + mod2(av)) }
  tm := TMatR.Create_init(nf, nc);
  tm.igual(Self);
  ed := -2 * av.r;
  for k := 1 to nf do
    tm.pon_e(k, k, tm.e(k, k) + ed);
  Mult(tm, Self);
  tm.Free;
  ed := av.r * av.r + av.i * av.i;
  for k := 1 to nf do
    tm.pon_e(k, k, tm.e(k, k) + ed);
  CalcBSE_PCC := CalcBSEN(Base);
end;


function TMatR.OrtoNormal: integer;

var
  k, j: integer;
  m: NReal;
  redundancia: integer;

begin
  redundancia := 0;
  for k := 1 to nf do
  begin
    m := fila(k).NormEuclid;
    if not EsCero(m / nc) then
    begin
      fila(k).PorReal(1 / m);
      { ortogonalizacion del resto }
      for j := k + 1 to nf do
      begin
        m := fila(k).PEV(fila(j));
        fila(j).SumRPV(-m, fila(k));
      end;
    end
    else
      redundancia := redundancia + 1;
  end;
  OrtoNormal := nf - redundancia;
end;

function TMatR.raiz_Cholesky: TMatR;
var

  B: TMatR;
  m, mp: NReal;
  k, j: integer;

  {$IFDEF DEBUG_CHOLESKY}
  procedure DumpProblema;
  var
    f: textfile;
  begin
    assignfile(f, 'debug_cholesy.xlt');
    rewrite(f);
    writeln(f, 'Matriz Original');
    Self.WriteXLT(f);
    writeln(f);
    writeln(f, 'Matrz B en proceso ... ERROR');
    B.WriteXLT(f);
    closefile(f);
  end;

  {$ENDIF}

begin
  B := TMatR.Create_Init(nf, nc);
  for k := 1 to nf do
  begin
    m := e(k, k) - sumaproducto_ventana(B.Fila(k), B.Fila(k), 1, k - 1);
    if m <= 0 then
    begin
{$IFDEF DEBUG_CHOLESKY}
      DumpProblema;
{$ENDIF}
      B.Free;
      Result := nil;
      exit;
      //      raise Exception.Create('Error!. MatR.raiz_Cholesky, m <= 0 en k=' + IntToStr(k));
    end;
    mp := sqrt(m);
    b.pon_e(k, k, mp);
    for j := k + 1 to b.nc do
    begin
      m := e(k, j) - sumaproducto_ventana(B.Fila(k), B.Fila(j), 1, k - 1);
      m := m / mp;
      b.pon_e(j, k, m);
      b.pon_e(k, j, 0);
    end;
  end;
  Result := B;
end;

(****
La llamada a esta funci�n hace un PASO del Algoritmo de Potencia Iterada.
Suponemos ||v|| = 1,
se el resultado es v transformado y dividido por su norma y
lambda = v^T.SELF.v
en RESULT retorna la norma de v devuelto menos v entrada es decir
que con el resultado es posible controlar la convergencia del
algoritmo de potencia iterada.
***)

function TMatR.PotenciaIterada(var v: TVectR; var lambda: NReal): NReal;
var
  k: integer;
  a: TVectR;
  d: NReal;
  tv: TDAofNReal;
begin
  a := TVectR.Create_Init(v.n);
  transformar(a, v);

  lambda := a.PEV(v);
  a.HacerUnitario;

  if lambda < 0 then
    a.PorReal(-1);

  d := 0;
  for k := 1 to v.n do
    d := d + sqr(a.pv[k] - v.pv[k]);

  tv := v.pv;
  v.pv := a.pv;
  a.pv := tv;

  a.Free;
  Result := d;
end;

{$IFDEF ALGLIB}
function TMatR.RMatrixSVD(UNeeded: integer; VTNeeded: integer;
  AdditionalMemory: integer; var res_W: TVectR; var res_U: TMatR;
  var res_VT: TMatR): boolean;

var
  A: TReal2DArray;
  k, j: integer;
  W: TReal1DArray;
  U: TReal2DArray;
  VT: TReal2DArray;
  res: boolean;

begin
  A := create_MatOfNreal(nf, nc);
  for k := 1 to nf do
    for j := 1 to nc do
      A[k - 1][j - 1] := e(k, j);

  W := nil;
  U := nil;
  VT := nil;
  res_W := nil;
  res_U := nil;
  res_VT := nil;

  res := svd.RMatrixSVD(A, nf, nc, UNeeded, VTNeeded, AdditionalMemory, W, U, VT);

  if res then
  begin
    if W <> nil then
      res_W := TVectR.Create_FromDAofR(W);
    if (U <> nil) and (UNeeded > 0) then
      res_U := TMatR.Create_FromMatOfNReal(U);
    if (VT <> nil) and (VTNeeded > 0) then
      res_VT := TMatR.Create_FromMatOfNReal(VT);
  end;

  liberarMatriz(A);
  liberarVector(W);
  liberarMatriz(U);
  liberarMatriz(VT);
  Result := res;

end;




function TMatR.RMatrixEVD(VNeeded: integer; var res_WR: TVectR;
  var res_WI: TVectR; var res_VL: TMatR; var res_VR: TMatR): boolean;
var
  A: TReal2DArray;
  WR: TReal1DArray;
  WI: TReal1DArray;
  VL: TReal2DArray;
  VR: TReal2DArray;
  k, j: integer;

  res: boolean;
begin
  A := create_MatOfNreal(nf, nc);
  for k := 1 to nf do
    for j := 1 to nc do
      A[k - 1][j - 1] := e(k, j);

  WR := nil;
  WI := nil;
  VL := nil;
  VR := nil;

  res_WR := nil;
  res_WI := nil;
  res_VL := nil;
  res_VR := nil;

  res := evd.RMatrixEVD(A, nc, VNeeded, WR, WI, VL, VR);
  if res then
  begin
    res_WR := TVectR.Create_FromDAofR(WR);
    res_WI := TVectR.Create_FromDAofR(WI);

    if (VR <> nil) and ((VNeeded and 1) <> 0) then
      res_VR := TMatR.Create_FromMatOfNReal(VR);

    if (VL <> nil) and ((VNeeded and 2) <> 0) then
      res_VL := TMatR.Create_FromMatOfNReal(VL);

  end;

  liberarMatriz(A);
  liberarVector(WR);
  liberarVector(WI);
  liberarMatriz(VL);
  liberarMatriz(VR);
  Result := res;
end;



// retorna (Self)^alfa si tiene �xito y nil en caso contrario.
// Diagonaliza la matriz, aplica el pow( ) sobre los coeficientes diaglonales
// y luego desdiagonaliza
function TMatR.power_r(r: NReal): TMatR;
var
  WR, WI: TVectR; // autovalores
  VR, dummy: TMatR; // autovectores Derechos.
  res_b: boolean;
  c: NComplex;
  a_, b_: NReal;
  res: TMatR;

  AC: TMatComplex;
  Lambda: TVectComplex;
  Q, invQ: TMatComplex;

  kFil, jCol: integer;
  m: NReal;
  k: integer;

{$IFDEF POWER_R}
  sal: TextFile;
  TestInv: TMatComplex;
  TestPow: TMatR;
{$ENDIF}
begin
  res_b := self.RMatrixEVD(1, WR, WI, dummy, VR);
  if res_b then
  begin
    Q := TMatComplex.Create_Init(nf, nc);
    Lambda := TVectComplex.Create_Init(nf);

    k := 1;
    while k <= nf do
    begin
      if EsCero(WI.e(k)) then
      begin
        a_ := Math.power(WR.e(k), r);
        Lambda.pon_e(k, numc(a_, 0)^);
        for kfil := 1 to nf do
          Q.pon_e(kFil, k, numc(VR.e(kFil, k), 0)^);
      end
      else
      begin
        c := algebrac.power_r(numc(WR.e(k), WI.e(k))^, r)^;
        Lambda.pon_e(k, c);
        Lambda.pon_e(k + 1, cc(c)^);
        for kFil := 1 to nf do
        begin
          c := numc(VR.e(kFil, k), VR.e(kFil, k + 1))^;
          Q.pon_e(kFil, k, c);
          Q.pon_e(kFil, k + 1, cc(c)^);
        end;
        Inc(k);
      end;
      Inc(k);
    end;

    // A * Q = Q* Diag(lambda) => A = Q* Diag(Lambda) invQ
    // pow( A, alfa ) = Q* pow( Diag(Lambda), alfa ) * invQ
    invQ := TMatComplex.Create_Init(nf, nc);
    invQ.Copy(Q);
    if not invQ.Inv then
      raise Exception.Create('No es invertible la matriz de autovalores derechos??!!!');


    AC := TMatComplex.Create_Init(nf, nc);
    AC.Ceros;
    for k := 1 to nf do
    begin
      Lambda.e(c, k);
      AC.pon_e(k, k, c);
    end;

    AC.Mult(Q, AC);
    AC.Mult(AC, invQ);

    res := TMatR.Create_Init(nf, nc);

    // Echo esto, AC debiera ser de coeficientes reales.
    for kFil := 1 to nf do
      for jCol := 1 to nc do
      begin
        AC.e(c, kFil, jCol);
        if c.i > 10e-5 then
          raise Exception.Create('OJO ... POW no dio AC de reales');
        res.pon_e(kFil, jCol, c.r);
      end;

    {$IFDEF POWER_R}
    assignfile(sal, 'c:\basura\frac.xlt');
    rewrite(sal);
    writeln(sal, 'Lambda================');
    Lambda.WriteToXlt(sal);
    writeln(sal, 'Q====================');
    Q.WriteToXlt(sal);
    writeln(sal, 'invQ=================');
    invQ.WriteToXlt(sal);
    TestInv := TMatComplex.Create_Init(nf, nc);
    TestInv.Mult(Q, invQ);
    writeln(sal, 'Q * invQ ====================');
    TestInv.WriteToXlt(sal);
    TestInv.Free;
    writeln(sal, 'AC=================');
    AC.WriteToXlt(sal);
    writeln(sal, 'res = A^(' + FloatToStr(r) + ') ==========================');
    res.WriteXLT(sal);
    TestPow := TMatR.Create_Init(nf, nc);
    TestPow.Mult(res, res);
    TestPow.Mult(TestPow, res);
    TestPow.Mult(TestPow, res);
    TestPow.Mult(TestPow, res);
    TestPow.Mult(TestPow, res);
    TestPow.Mult(TestPow, res);

    writeln(sal, 'res^7 ==========================');
    TestPow.WriteXLT(sal);
    TestPow.Free;

    writeln(sal, 'A =============================');
    Self.WriteXLT(sal);

    closefile(sal);
{$ENDIF}

    AC.Free;
    Q.Free;
    Lambda.Free;
    invQ.Free;
    Result := res;
  end
  else
    Result := nil;
end;

{$ENDIF}

// result = Self (x) B
class function TMatR.Create_Kron(A, B: TMatR): TMatR;
var
  res: TMatR;
  res_nf, res_nc: integer;
  k_self, j_self: integer;
  k_B, j_B: integer;
  kBase, jBase: integer;
  a_: NReal;

begin
  res_nf := A.nf * B.nf;
  res_nc := A.nc * B.nc;
  res := TMatR.Create_Init(res_nf, res_nc);
  for k_Self := 1 to A.nf do
    for j_Self := 1 to A.nc do
    begin
      a_ := A.e(k_Self, j_Self);
      kBase := (k_Self - 1) * B.nf;
      jBase := (j_Self - 1) * B.nc;
      for k_B := 1 to B.nf do
        for j_B := 1 to B.nc do
          res.pon_e(kBase + k_B, jBase + j_B, a_ * B.e(k_B, j_B));
    end;
  Result := res;
end;

class function TMatR.Create_Combinar(alfa: NReal; A: TMatR; beta: NReal;
  B: TMatR): TMatR;
var
  res: TMatR;
  kFila: integer;

  procedure combinarFIlas(var pres: TDAOfNReal; pa, pb: TDAOfNReal);
  var
    j: integer;
  begin
    for j := 1 to high(pa) do
      pres[j] := alfa * pa[j] + beta * pb[j];
  end;

begin
  res := TMatR.Create_Init(A.nf, A.nc);
  for kFila := 1 to res.nf do
    combinarFilas(res.Fila(kFila).pv, A.fila(kFila).pv, B.Fila(kFila).pv);
  Result := res;
end;

function TMatR.vec: TVectR;
var
  res: TVectR;
  k, j: integer;
  h: integer;

begin
  res := TVectR.Create_Init(Self.nf * Self.nc);
  h := 1;
  for j := 1 to Self.nc do
    for k := 1 to Self.nf do
    begin
      res.pon_e(h, self.e(k, j));
      Inc(h);
    end;
  Result := res;
end;

function TMatR.Create_power_n(n: integer): TMatR;

var
  r, j: integer;
  res: TMatR;

begin
  r := abs(n);

  if r = 0 then
  begin
    Result := Create_identidad(self.nf);
    exit;
  end;

  // si llegamos aqu� quiere decir que r >= 1
  res := TMatR.Create_Clone(self);
  for j := 1 to r - 1 do
    res.Mult(res, self);

  if n > 0 then
    Result := res
  else if n < 0 then
  begin
    res.Inv;
    Result := res;
  end
  else
    raise Exception.Create('No puede llegar ac� pero con esto se saca el warning');
end;




// Eleva la potencia de una matriz a un exponente n entero
procedure TMatR.power_n(n: integer);
var
  tmp: TMatR;
  pm: TDAOfVectR;
begin
  tmp := Create_power_n(n);
  pm := tmp.pm;
  tmp.pm := self.pm;
  self.pm := pm;
  tmp.Free;
end;



function TMatR.menor_complementario(fila, columna: integer): NReal;

var
  MatTemp: TMatR;
  i, j, k, h: integer;
begin
  k := 1;
  h := 1;
  MatTemp := TMatR.Create_Init(Self.nf - 1, Self.nc - 1);
  for i := 1 to self.nf do
  begin
    if (i <> fila) then
    begin
      for j := 1 to self.nc do
      begin
        if (j <> columna) then
        begin
          MatTemp.pon_e(k, h, e(i, j));
          h := h + 1;
        end;
      end;
      k := k + 1;
    end;
    h := 1;
  end;
  Result := MatTemp.Deter;
  MatTemp.Free;
end;

function TMatR.Crear_adjunta: TMatR;
var
  MatTemp: TMatR;
  i, j: integer;
  signo: integer;
begin
  MatTemp := TMatR.Create_Init(Self.nf, Self.nc);
  signo := 1;
  for i := 1 to self.nf do
    for j := 1 to self.nc do
    begin
      // signo=   (-1)^(i+j)
      MatTemp.pon_e(i, j, signo * self.menor_complementario(i, j));
      signo := -signo;
    end;
  Result := MatTemp;
end;



procedure TMatR.identidad; // convierte la matriz a la identidad.
var
  k, j: integer;
begin
  for k := 1 to nf do
    for j := 1 to nc do
      if k = j then
        pon_e(k, j, 1)
      else
        pon_e(k, j, 0);
end;

class function TMatR.Create_identidad(n: integer): TMatR;
var
  res: TMatR;
begin
  res := TMatR.Create_init(n, n);
  res.Identidad;
  Result := res;
end;




// evalua sum( ak * x^(k-1) ; k= 1 a n );
function TVectR.rpoly(x: NReal): NReal;
var
  r: NReal;
  k: integer;
begin
  r := e(n);
  for k := n - 1 downto 1 do
    r := r * x + e(k);
  Result := r;
end;

function TVectR.HacerUnitario: NReal;
var
  m: NReal;
begin
  m := NormEuclid;
  if not EsCero(m / n) then
  begin
    PorReal(1 / m);
    Result := m;
  end
  else
  begin
    Ceros;
    pv[1] := 1;
    Result := 0.0;
  end;
end;

procedure TVectR.cpoly(var resc: NComplex; xc: NComplex);
var
  k: integer;
begin
  resc.r := e(n);
  resc.i := 0;

  for k := n - 1 downto 1 do
  begin
    Compol.Pro(resc, resc, xc);
    resc.r := resc.r + e(k);
  end;
end;

begin
(*
writeln('Unidad MatReal INSTALADA / RCH-90');
*)
end.
