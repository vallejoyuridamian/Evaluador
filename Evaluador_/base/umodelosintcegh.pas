unit umodelosintcegh;

{$MODE Delphi}
{$DEFINE xRUIDA_MULTI_RETARDOS}
{$DEFINE FAST_B_TRIANG_INF}

(*+doc
Esta undidad permite leer y guardar el archivo de modelo
de fuentes correlacionadas en espacio gaussiano y las funciones
deformantes.

El modelo supone NSS series de datos a sintetizar con un filtro de ordern NOrdenDelFiltro
mediante un filtro lineal del tipo

x[is, k+1] = sum( h=1..NSS , j=1..NOrdenDelFiltro; a[is, (j-1) NOrdenDelFiltro + is ] * x[h,k-j+1] )+
              + sum( h=1..NSS; b[is, h]* u[h, k] )

Donde k identifica el tiempo de muestreo kTs siendo Ts el intervalo de muestreo.
las u[h,k] son NSS fuentes de ruido blanco gaussiano (standar, m=0; var=1)

La salida del filtro, x[is, k+1] es convertida a histograma UNIFORME mediante
la aplicación de la función UNIFOMIZAR.
-doc*)
interface

uses
  xMatDefs, Classes, matreal, MatEnt, SysUtils, uAuxiliares, fddp, fddp_conmatr, ufechas,
  umatriz_ruida, useriestemporales,
  uuniformizadores,
  Math;

resourcestring
  rs_kSelectorDeformador = 'kSelectorDeformador, no especificado para dh:';
  rs_ErrorDimDiscretizacion_VarE =
    'Error!. El mínimo valor para una discretización de una variable de estado es 2';


type
  TDAOfVectR = array of TVectR;
  TDAOfVectE = array of TVectE;


const
  // rch 20160729
  // agrego descripción de tipos de serie y tipo de CEGH
  VERSION_FORMATO_CEGH = 4;



type

  // Clase para leer archivos resultados de AnalisisSerial

  { TModeloCEGH Clasico X[k+1] = sum( A[h] X[k-h]; h=0..NRertardos-1 ) + B R[k] }
  TModeloCEGH = class
  public

    MRed: TMatR; // Matriz Reductora de estado. Xred = R X
    MRed_aux: TMatR; // usado en caso de tener una forma auxiliar de reducción
    MAmp_cte: TMatR; // Matriz Amplificadora del estdo,
    BAmp_cte: TMatR; // Recomponedor de la varianza si hay reducción de estado

    version: integer;

    A_cte, B_cte: TMatR; // Matrices del Filtro Lineal.
    mcA, mcB: TDAOfMatR;

    //Número de variables de estado Para Optimización (o sea pueden ser reducidas)
    nVE: integer;
    // Número de variables de estado del espacio Auxiliar (si lo hay)
    nVE_aux: integer;
    //Número de discretizaciones de cada variables de estado
    nDiscsVsE: TDAofNInt;
    // Probabilidad acumulada asignada al punto de discretización
    ProbsVsE: array of TDAofNReal;

    //Los nombres de las variables de estado
    nombreVarE: TDAofString;

    //Por cada punto de la función deformante se tiene un arreglo de reales con el valor
    //de la deformación de x perteneciente a [0, 1]
    // la dimensión de las funcionesDeformantes es [nBornesSalida, nPuntosPorPeriodo]
    funcionesDeformantes: TMatOf_ddp_VectDeMuestras;

{$IFDEF GRUPOS_POLARES}
    // GruposPolares   (introducido en la versión 2 de Series y CEGH).
    GruposPolares: TGruposPolares;
{$ENDIF}

    //Es la cantidad de salidas que presenta la fuente a los actores
    //Es igual a NombresDeBornes_Publicados.Count
    nBornesSalida: integer;
    nRetardos: integer; // cantidad de pasos de tiempo de retardo
    // largo de cada vector descriptor de una función deformante de un borne
    nPuntosPorPeriodo: integer;

    durPasoDeSorteoEnHoras: integer;
    // Nombres de los bornes
    NombresDeBornes_Publicados: TStringList;

    // fuente axiliar para transformaciones
    gaussiana: Tf_ddp_GaussianaNormal;

    // Número de Puntos de los Deformadores.
    NPuntosFuncionDeformante: integer;


    // crea el conjunto de datos vacio para ser llenado desde el identificador
    constructor Create(
      NSS: integer; NombresDeBornes_Publicados: TStringList;
      NOrdenDelFiltro, NFD, NPFD: integer; durPasoDeSorteoEnHoras: integer;
      nVERed: integer);

    constructor Create_MultiCiclo(NSS: integer;
      NombresDeBornes_Publicados: TStringList; NOrdenDelFiltro, NFD, NPFD: integer;
      durPasoDeSorteoEnHoras: integer; nVERed: integer);

    // carga los datos de un archivo previamente guardado con WriteToArchi
    constructor CreateFromFile(var f: textFile; NombreArchivo: string);

    // carga los datos de un archivo previamente guardado con WriteToArchi
    constructor CreateFromArchi(nombreArchivo: string);

    // carga desde un archivo en formato binario. ( por eficiencia )
    constructor CreateFromArchi_bin(nombreArchivo: string);

    // escribe los datos en un archivo de texto.
    procedure WriteToArchi(nombreArchivo: string;
      NDigitosDeformadores, NDecimalesDeformadores: integer);

    // escribe un archivo enformato binario (por eficiencia)
    procedure WriteToArchi_bin(nombreArchivo: string);


    procedure Free;

    (***** FUNCIONES AUXILIARES PARA CALCULOS ************)
    procedure xTog_Series(x: TSeriesDeDatos; flg_AplicarFiltrado: boolean;
      umbral_filtro: NReal);
    procedure gTox_Series(x: TSeriesDeDatos; flg_AplicarFiltrado: boolean;
      umbral_filtro: NReal);

    // Sobreescribe las series x con una posible realización y usa la
    // semilla para inicializar los generadores de ruido.
    procedure GenRealizacion(xSeries: TSeriesDeDatos; semilla: integer);

    // trasforma del espacio real al gaussiano
    function xTog(x: NReal; kSerie, kPaso: integer): NReal;

    // transforma del espacio gaussiano al real
    function gTox(g: NReal; kSerie, kPaso: integer): NReal;


    {$IFDEF GRUPOS_POLARES}
    // trasforma del espacio real al gaussiano
    // kPrimerSerie idientifica la posición de la primer serie en los vectores g y x
    // esto permite pasar las borneras de las fuentes por referencia e indicar qué posición
    // dentro de la bornera contiene los valores a transformar.
    procedure xTog_vect(var g, x: TDAOfNreal; kPrimerSerie, kPaso: integer);
    // transforma del espacio gaussiano al real
    procedure gTox_vect(var x, g: TDAOfNreal; kPrimerSerie, kPaso: integer);
    {$ENDIF}

    // crea un vector de estado según la cantidad de series y el orden del filtro
    function CrearVector_EstadoX: TVectR;
    // Crea un vector del tamaño necesario para alojar las salidas
    function CrearVector_Salida: TVectR;
    // crea un vector para alamcenar los valores de las fuentes de ruido blanco
    function CrearVector_RBG: TVectR;

    // rellena el vector con sorteos independientes con distribución normal standar
    procedure SortearValores(var rbg: TVectR);

    // Calcula en espacio gaussiano la salida del filtro
    // calcula Y= A X + B R sorteando   (para el caso MonoFiltro)
    // o calcula Y= A[kSelector] X + B[kSelector] R sorteando  (para el caso MultiFiltro)
    procedure CalcularProximasSalidas(var SalidaY: TVectR; EstadoX: TVectR;
      entradaRBG: TVectR; kSelector: integer);

    function CalcularSalida(kSal: integer; const pEstadoX, pEntradaRBG: PNReal;
      kSelector: integer): NReal;

    function CalcularSalidaConSesgo(kSal: integer;
      const pEstadoX, pEntradaRBG: PNReal; sesgoVM, atenuacion: NReal;
      kSelector: integer): NReal;

    // realiza los desplazamientos en X y copia Y en los casilleros que corresponde
    procedure EvolucionarEstado_(var EstadoX: TVectR; SalidaY: TVectR);

    // retorna el orden del filtro
    function CalcOrdenDelFiltro: integer;

    // inicializa el vector de estado X, a partir de la serie histórica de datos
    // considerando el paso (kPaso) dentro de la serie.
    // Si kPaso=1, se carga el primer valor de la serie histórica en
    // el casillero de X que refleja el estado al inicio del paso.
    // El estado se carga con la información de la serie anterior al paso idesp
    // el selelctor para transformar al espachi gaussiano se obtiene calculando
    // la posción de cada dato en la serie histórica - desp_selector0 módulo la
    // cantidad de puntos por ciclo
    // desp_selector0 puede ir de 0 .. NPuntosPorCiclo -1
    procedure InicializarDesdeDatosReales(X: TVectR;
      serieHistorica: TSeriesDeDatos; kPaso: integer; desp_selector0: integer);

    // retorna el k (base cero) del deformador para la fecha dada.
    function kSelectorDeformador(fecha: TFecha): integer;

    // estas funciones las agrego para que se fijen las dimensiones en las
    // matrices Ctes o las cíclicas según estén definidas.
    function A_nc: integer;
    function A_nf: integer;
    function B_nc: integer;
    function B_nf: integer;

    function Dim_X: integer;
    function Dim_XRed: integer;


    procedure Calc_Bamp_cte;


    // Escala la matriz Reductora y Calcula las matrices necesarias
    // para la transformación de Ampliación (inversa de la reductora)
    procedure Calcular_Matrices_Ampliacion;

    // busca los negativos y los anula. Esto es para el tratamiento de los KT (indice de claridad)
    procedure Anular_Negativos_DelDeformador(kSerie: integer);



    // Crea los deformadores a partir de las series de datos.
    procedure CrearDeformadores(seriesDeDatos: TSeriesDeDatos; overlapping,
      traslapping, NPuntosPorMiniciclo: integer; FiltrarMenores: boolean;
  umbralFiltro: NReal; NCronicasRuido: integer; PrecisionMedida_pu: NReal);

    // Gaussianiza las series.
    procedure GaussianizarSeries(seriesDeDatos: TSeriesDeDatos;
      FiltrarMenores: boolean; umbralFiltro: NReal;
  FiltrarAlGaussianizar: boolean; umbralFiltroAlGaussianizar: NReal;
  kCronRuido: integer; precicionMedida_pu: NReal);


    // Resta valor esperado y divide por desvío estándar.
    procedure Normalizar(seriesDeDatos: TSeriesDeDatos; filtrarMenores: boolean;
      umbralFiltro: NReal);


    // SeriesError
    function Calc_SeriesError(seriesDeDatos: TSeriesDeDatos;
      FiltrarMenores: boolean; umbralFiltro: NReal): TSeriesDeDatos;

  end;


  (**
    { TModeloCEGH_EntradaSalida Y[k] = sum( A[h] X[k-h]; h=0..NRertardos-1 ) + B R[k] }
    TModeloCEGH_EntradaSalida = class( TModeloCEGH )
      NSeriesEntrada, NSeriesSalida: integer;

      // Tipos de series
      tiposDeSerie: TDAOfTipoSerie;  // x: entrada, y: salida

      constructor Create(
        NS_Entrada, NS_Salida: integer;
        NombresDeBornes_Publicados: TStringList;
        NOrdenDelFiltro, NFD, NPFD: integer;
        durPasoDeSorteoEnHoras: integer; nVERed: integer);

    private
      function Calc_Series(seriesDeDatos: TSeriesDeDatos;
        FiltrarMenores: boolean; umbralFiltro: NReal): TSeriesDeDatos;
    end;
     *)

//Retorna un arreglo de tipo TDAOf_ddp_VectDeMuestras de tamaño n y con todos sus
//elementos en NIL
function createNilTMatOf_ddp_VectDeMuestras(filas, columnas: integer):
  TMatOf_ddp_VectDeMuestras;
procedure freeTMatOf_ddp_VectDeMuestras(var matriz: TMatOf_ddp_VectDeMuestras);



// busca en la lista de cargados y si ya etá cargado retorna un puntero e
// incrementa el contador de referencias.
function Get_ModeloCEGH(archi: string): TModeloCEGH;

// busca el modelo en la lista de modelos cargados y decrementa el contador
// de referencias. Si llega a Cero hace Free del modelo.
// modelo es puesto a nil
procedure Free_ModeloCEGH(var modelo: TModeloCEGH);


// busca en la lista de cargados y si ya etá cargado y coincide nombre con puntero
// retorna sin cambiar nada, si difieren, hace Free_ModeloCEGH(modelo) y
// retorna en modelo el resultado de Get_ModeloCEGH
procedure Change_ModeloCEGH(archi: string; var modelo: TModeloCEGH);


implementation


// Guarda la lista de modelos cargados para re-utilizar la instancia
// si en más de un lugar (o thread) necesita el mismo modelo
// Para utilizar esta funcionalidad, en lugar de usar CreateFromArchi y Free
// de TModeloCEGH hay que usar las funciones Get_ModeloCEGH y Free_ModeloCEGH
var
  lst_ModelosCargados: TList;


type
  TRecModeloCargado = class
    archivo: string;
    modelo: TModeloCEGH;
    cnt_referencias: integer;
    constructor Create(xArchivo: string; xModelo: TModeloCEGH);
  end;


constructor TRecModeloCargado.Create(xArchivo: string; xModelo: TModeloCEGH);
begin
  archivo := xArchivo;
  modelo := xModelo;
  cnt_referencias := 1;
end;


function RecOfModeloCargado(archi: string): TRecModeloCargado;
var
  k: integer;
  buscando: boolean;
  aRec: TRecModeloCargado;
begin
  buscando := True;
  k := 0;
  while buscando and (k < lst_ModelosCargados.Count) do
  begin
    aRec := lst_ModelosCargados.items[k];
    if aRec.archivo = archi then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
    Result := nil
  else
    Result := aRec;
end;

function kOfModeloCargado(Modelo: TModeloCEGH): integer;
var
  k: integer;
  buscando: boolean;
  aRec: TRecModeloCargado;
begin
  buscando := True;
  k := 0;
  while buscando and (k < lst_ModelosCargados.Count) do
  begin
    aRec := lst_ModelosCargados.items[k];
    if aRec.modelo = Modelo then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
    Result := -1
  else
    Result := k;
end;


// busca en la lista de cargados y si ya etá cargado retorna un puntero e
// incrementa el contador de referencias.
function Get_ModeloCEGH(archi: string): TModeloCEGH;
var
  aRec: TRecModeloCargado;
  aModelo: TModeloCEGH;
begin
  aRec := RecOfModeloCargado(archi);
  aModelo := nil;
  if aREc = nil then
  begin
    aModelo := TModeloCEGH.CreateFromArchi(archi);
    if aModelo <> nil then
    begin
      aRec := TRecModeloCargado.Create(archi, aModelo);
      lst_ModelosCargados.Add(aRec);
    end;
  end
  else
  begin
    Inc(aRec.cnt_referencias);
    aModelo := aRec.modelo;
  end;
  Result := aModelo;
end;


// busca el modelo en la lista de modelos cargados y decrementa el contador
// de referencias. Si llega a Cero hace Free del modelo.
// modelo es puesto a nil
procedure Free_ModeloCEGH(var modelo: TModeloCEGH);
var
  aRec: TRecModeloCargado;
  k: integer;
begin
  k := kOfModeloCargado(modelo);
  if k < 0 then
  begin
    raise Exception.Create('Free_ModeloCEGH ... el modelo no está en la lista.');
  end;

  aRec := lst_ModelosCargados.items[k];

  Dec(aRec.cnt_referencias);
  if aRec.cnt_referencias = 0 then
  begin
    aRec.modelo.Free;
    lst_ModelosCargados.Delete(k);
  end;
  modelo := nil;

end;


procedure Change_ModeloCEGH(archi: string; var modelo: TModeloCEGH);
var
  aRec: TRecModeloCargado;
begin
  if modelo = nil then
  begin
    modelo := Get_ModeloCEGH(archi);
    exit;
  end;

  aRec := RecOfModeloCargado(archi);
  if (aRec <> nil) then
  begin
    if aRec.modelo <> modelo then
    begin
      Free_ModeloCEGH(modelo);
      modelo := Get_ModeloCEGH(archi);
    end;
  end
  else
    modelo := Get_ModeloCEGH(archi);
end;


procedure TModeloCEGH.Calc_Bamp_cte;
begin
  if BAmp_cte <> nil then
    BAmp_cte.Free;

  if (A_Cte <> nil) then
  begin
    if A_Cte.nf <> A_Cte.nc then
    begin
      {$IFDEF RUIDA_MULTI_RETARDOS}
      BAmp_cte := Matriz_RUIDA_MultiRetardos(A_cte, B_cte, MAmp_cte, MRed);
      {$ELSE}
      BAmp_cte := nil;
      // por ahora no tengo revisado el procedimiento
      // cuando hay más de un retardo
      {$ENDIF}
    end
    else
      BAmp_cte := Matriz_RUIDA(A_cte, B_cte, MAmp_cte, MRed);
  end
  else
    BAmp_cte := nil;
end;




procedure TModeloCEGH.Calcular_Matrices_Ampliacion;
var
  i, j: integer;
  ne2_FilaR: NReal;
begin
  // por ahora, supopngo que MRed tiene filas ortogonales
  // y calculo MAmp para que MRed * MAmp = I
  if MAmp_cte <> nil then
    MAmp_cte.Free;
  MAmp_cte := TMatR.Create_Init(MRed.nc, MRed.nf);

  for i := 1 to MRed.nf do
  begin
    ne2_FilaR := MRed.Fila(i).ne2;
    if ne2_FilaR < AsumaCero then
      raise Exception.Create('Error de modelo CEGH, la fila: ' +
        IntToStr(i) + ' del redutor de estado tiene norma nula.');
    for j := 1 to MAmp_cte.nf do
      MAmp_cte.pon_e(j, i, MRed.e(i, j) / ne2_FilaR);
  end;


  // Atención, al calcular Bamp, además se reescalan las filas de Mr y
  // las columnas de Ma para que las varianzas de las variables reducidas sena 1
  // al igual que la de las expandidas.
  Calc_Bamp_cte;
end;

constructor TModeloCEGH.CreateFromFile(var f: textFile; NombreArchivo: string);
var
  linea: string;
  num: NReal;
  nFuentesRBlancoGaussiano: integer;
  i, j, k: integer;
  ne2_FilaR: NReal;
  funcionesDeformantesI: TDAOf_ddp_VectDeMuestras;
  aVect: TVectR;
  nColsA: integer;
  archi_bin: string;
  buscando: boolean;
  fechaArchiBin, fechaArchivoTexto: TDateTime;
  NFiltros, kFiltro: integer;

  fecha_obligar_cambio_bin: TDateTime;

  cnt_linea: integer;
  flg_lineaUsada: boolean;


  procedure ReadFiltro(var f: textfile; var A, B: TMatR);
  var
    linea: string;
    i, j: integer;

  begin
    Readln(f, linea);

    //Numero de Fuentes De Ruido Blanco Gaussiano
    Readln(f, linea);
    NextPal(linea);
    nFuentesRBlancoGaussiano := NextInt(linea);

    Readln(f, linea); //Aca iría NSS pero ya lo leimos antes
    linea := ProximaLineaNoVacia(f);
    if pos('NCOLSA', linea) > 0 then
    begin
      nextpal(linea);
      NCOLSA := nextint(linea);
      linea := ProximaLineaNoVacia(f);
    end
    else
      NCOLSA := nBornesSalida; // asumo FiltroOrden1 si no me dicen nada.
    //Vuelve con Filtro A

    Readln(f, linea); //Nombres de las columnas

    A := TMatR.Create_Init(nBornesSalida, nColsA);
    B := TMatR.Create_Init(nBornesSalida, nFuentesRBlancoGaussiano);

    nRetardos := nColsA div nBornesSalida;

    for i := 1 to nBornesSalida do
    begin
      Readln(f, linea);
      nextpal(linea);
      nextpal(linea);
      nextpal(linea);
      for j := 1 to nColsA do
      begin
        num := nextFloat(linea);
        A.pon_e(i, j, num);
      end;

      nextpal(linea);

      for j := 1 to nFuentesRBlancoGaussiano do
      begin
        num := nextFloat(linea);
        B.pon_e(i, j, num);
      end;
    end;
    Readln(f, linea);
  end;

begin
  gaussiana := nil;
  uauxiliares.setSeparadoresGlobales;
  gaussiana := Tf_ddp_GaussianaNormal.Create(nil, 31);
  A_cte := nil;
  B_cte := nil;
  mCA := nil;
  mCB := nil;

  NombresDeBornes_Publicados := TStringList.Create;
  // LECTURA DE VERSION
  readln(f, linea);
  if (pos('VERSION_FORMATO_CEGH', linea) <> 0) then
  begin
    nextpal(linea);
    version := nextInt(linea);
    readln(f, linea);
  end
  else
    version := 0;

  readln(f, linea);
  //Leo la cantidad de series de salida
  NextPal(linea);
  nBornesSalida := NextInt(linea);

  //Leo la cantidad de puntos por período
  Readln(f, linea);
  NextPal(linea);
  nPuntosPorPeriodo := NextInt(linea);

  //Leo la cantidad de puntos por función deformante
  Readln(f, linea);
  NextPal(linea);
  NPuntosFuncionDeformante := NextInt(linea);

  //Leo la duración del paso de sorteo EN HORAS
  Readln(f, linea);
  NextPal(linea);
  durPasoDeSorteoEnHoras := NextInt(linea);

  //Leo las funciones deformantes de las series
  SetLength(funcionesDeformantes, nBornesSalida);
  for i := 0 to nBornesSalida - 1 do
  begin
    linea := ProximaLineaNoVacia(f);//Nombre de la serie
    uauxiliares.Nextpal(linea);
    self.NombresDeBornes_Publicados.Add(uauxiliares.Nextpal(linea));
    Readln(f, linea);//intervalos

    SetLength(funcionesDeformantes[i], nPuntosPorPeriodo);
    funcionesDeformantesI := funcionesDeformantes[i];
    for j := 0 to nPuntosPorPeriodo - 1 do
    begin
      //leo los vectores para cada punto de la función deformante
      Readln(f, linea);

      //saco el paso: y el numero
      nextpal(linea);
      nextpal(linea);

      aVect := TVectR.Create_Init(NPuntosFuncionDeformante);
      for k := 1 to NPuntosFuncionDeformante do
        aVect.pon_e(k, NextFloat(linea));
      funcionesDeformantesI[j] :=
        Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(aVect, nil, 0);
    end;
  end;//Termino con las series

{$IFDEF GRUPOS_POLARES}
  readln(f, linea); // liena en blanco
  if version >= 2 then
  begin
    cnt_linea := 0;
    GruposPolares := TGruposPolares.Create_ReadFromTextFile(
      f, cnt_linea, linea, flg_lineausada);
  end
  else
    GruposPolares := TGruposPolares.Create_vacio;

  if flg_lineaUsada then
{$ENDIF}
    readln(f, linea); // línea en blanco.

  if version > 0 then
  begin
    readln(f, linea);
    nextpal(linea);
    NFiltros := nextInt(linea);
  end
  else
    NFiltros := 1;

  if NFiltros = 1 then
  begin
    readFiltro(f, A_cte, B_cte);
    mCA := nil;
    mCB := nil;
  end
  else
  begin
    setlength(mCA, NFiltros);
    setlength(mCB, NFiltros);
    for kfiltro := 0 to NFiltros - 1 do
      readFiltro(f, mCA[kFiltro], mCB[kFiltro]);
  end;

  linea := ProximaLineaNoVacia(f);
  if not EOF(f) then
  begin
    //nVE
    NextPal(linea);
    nVE := NextInt(linea);
    SetLength(nDiscsVsE, nVE);
    SetLength(nombreVarE, nVE);
    MRed := TMatR.Create_Init(nVe, nColsA);
    // Creamos la matriz de probabilidades
    setlength(ProbsVsE, nVE);

    for i := 1 to nVE do
    begin
      readln(f, linea);
      //ndi
      NextPal(linea);
      nDiscsVsE[i - 1] := NextInt(linea);

      if (nDiscsVsE[i - 1] < 2) then
        raise Exception.Create(rs_ErrorDimDiscretizacion_VarE +
          ' CEGH: ' + nombreArchivo + ', variable: ' + nombreVarE[i - 1]);

      //nombre de la var
      nombreVarE[i - 1] := NextPal(linea);
      for j := 1 to MRed.nc do
      begin
        num := NextFloat(linea);
        MRed.pon_e(i, j, num);
      end;
      //EstadoInicial
      NextPal(linea);

      // leemos las probabilidades asignadas
      readln(f, linea);
      nextpal(linea);
      setlength(ProbsVsE[i - 1], nDiscsVsE[i - 1]);
      for  j := 0 to nDiscsVsE[i - 1] - 1 do
        ProbsVsE[i - 1][j] := NextFloat(linea);
    end;

    Calcular_Matrices_Ampliacion;
  end;

  MRed_aux := nil;
  nVE_aux := 0;
  if not EOF(f) then
  begin
    linea := uauxiliares.ProximaLineaNoVacia(f);
    if linea = '<+Raux>' then
    begin
      linea := uauxiliares.ProximaLineaNoVacia(f);
      nVE_aux := uauxiliares.NextIntParam(linea, 'nVE');
      MRed_aux := TMatR.Create_Init(nVe_aux, nColsA);
      for i := 1 to nVE_aux do
      begin
        linea := uauxiliares.ProximaLineaNoVacia(f);
        for j := 1 to MRed_aux.nc do
        begin
          num := nextFloat(linea);
          MRed_aux.pon_e(i, j, num);
        end;
      end;
    end;
  end
  else
  begin
    nVE_aux := 0;
    MRed_aux := nil;
  end;

end;

constructor TModeloCEGH.CreateFromArchi(nombreArchivo: string);
var
  f: TextFile;
  linea: string;
  num: NReal;
  nFuentesRBlancoGaussiano: integer;
  i, j, k: integer;
  ne2_FilaR: NReal;
  funcionesDeformantesI: TDAOf_ddp_VectDeMuestras;
  aVect: TVectR;
  nColsA: integer;
  archi_bin: string;
  buscando: boolean;
  fechaArchiBin, fechaArchivoTexto: TDateTime;
  NFiltros, kFiltro: integer;

  fecha_obligar_cambio_bin: TDateTime;

  cnt_linea: integer;
  flg_lineaUsada: boolean;

begin

  // poner esta fecha cuando sea neceario que si el bin es anterior
  // sea regenerado.
  fecha_obligar_cambio_bin := EncodeDate(2013, 10, 14);

  if FileExists(nombreArchivo) then
  begin
    archi_bin := nombreArchivo;
    k := length(archi_bin);
    buscando := True;
    while (k > 0) and buscando do
      if archi_bin[k] = '.' then
        buscando := False
      else
        Dec(k);
    if buscando then
      archi_bin := archi_bin + '.'
    else
    if k < length(archi_bin) then
      Delete(archi_bin, k + 1, length(archi_bin) - k);
    archi_bin := archi_bin + 'bin';

    if FileExists(archi_bin) then
    begin
      fechaArchiBin := fileDateToDateTime(FileAge(archi_bin));
      fechaArchivoTexto := fileDateToDateTime(FileAge(nombreArchivo));
      if (fechaArchiBin > fechaArchivoTexto) and
        (fechaArchiBin > fecha_obligar_cambio_bin) then
      begin
        CreateFromArchi_bin(archi_bin);
        exit;
      end;
    end;
  end;


  if FileExists(nombreArchivo) then
  begin
    try
      try
        AssignFile(f, nombreArchivo);
        Reset(f);
        CreateFromFile(f, nombreArchivo);
        self.WriteToArchi_bin(archi_bin);
      finally
        uauxiliares.setSeparadoresLocales;
        CloseFile(f);
      end

    except
      on e: Exception do
      begin
        if gaussiana <> nil then
          gaussiana.Free;
        if A_cte <> nil then
          A_cte.Free;
        if B_cte <> nil then
          B_cte.Free;
        raise e;
      end
    end;
  end
  else
    raise Exception.Create('Datos sintetizador, NO Encuentro el archivo:' +
      nombreArchivo);
end;


constructor TModeloCEGH.CreateFromArchi_bin(nombreArchivo: string);
var
  f: file of byte;
  linea: ansistring;
  //  num: NReal;
  i, j: integer;
  ne2_FilaR: NReal;
  funcionesDeformantesI: TDAOf_ddp_VectDeMuestras;
  aVect: TVectR;
  nFiltros: integer;

  jh: integer;
  alfa, beta: NReal;
  buffint: array of smallint;
  kFiltro: integer;
  nColsA: integer;

  procedure bri(var n: integer);
  begin
    blockread(f, n, sizeOf(n));
  end;

  procedure brs(var s: ansistring);
  var
    n: integer;
  begin
    bri(n);
    setlength(s, n);
    blockread(f, s[1], n);
  end;

  procedure brr(var r: NReal);
  begin
    blockread(f, r, sizeOf(r));
  end;

  procedure readFiltro_bin(var A, B: TMatR);
  var
    i, nColsB: integer;
  begin
    //Numero de Fuentes De Ruido Blanco Gaussiano
    bri(nColsB);
    bri(nColsA);
    nRetardos := nColsA div nBornesSalida;

    A := TMatR.Create_Init(nBornesSalida, nColsA);
    B := TMatR.Create_Init(nBornesSalida, nColsB);
    for i := 1 to nBornesSalida do
    begin
      blockRead(f, A.pm[i].pv[1], nColsA * SizeOf(NReal));
      blockRead(f, B.pm[i].pv[1], nColsB * SizeOf(NReal));
    end;
  end;

begin
  gaussiana := nil;
  A_cte := nil;
  B_cte := nil;
  mcA := nil;
  mcB := nil;

  if FileExists(nombreArchivo) { *Converted from FileExists*  } then
  begin
    try
      try
        gaussiana := Tf_ddp_GaussianaNormal.Create(nil, 31);

        AssignFile(f, nombreArchivo);
        filemode:= 0;
        Reset(f);
        NombresDeBornes_Publicados := TStringList.Create;

        bri(version);
        if version = -1 then
        begin
          bri(version);
          //Leo la cantidad de series de salida
          bri(nBornesSalida);
        end
        else
        begin
          nBornesSalida := version;
          version := 0;
        end;

        //Leo la cantidad de puntos por período
        bri(nPuntosPorPeriodo);

        //Leo la cantidad de puntos por función deformante
        bri(NPuntosFuncionDeformante);

        //Leo la duración del paso de sorteo EN HORAS
        bri(durPasoDeSorteoEnHoras);

        setlength(buffint, NPuntosFuncionDeformante);

        //Leo las funciones deformantes de las series
        SetLength(funcionesDeformantes, nBornesSalida);
        for i := 0 to nBornesSalida - 1 do
        begin
          brs(linea);
          self.NombresDeBornes_Publicados.Add(string(linea));

          SetLength(funcionesDeformantes[i], nPuntosPorPeriodo);
          funcionesDeformantesI := funcionesDeformantes[i];
          for j := 0 to nPuntosPorPeriodo - 1 do
          begin
            //leo los vectores para cada punto de la función deformante
            brr(alfa);
            brr(beta);
            blockread(f, buffInt[0], sizeOf(buffInt[0]) * NPuntosFuncionDeformante);
            aVect := TVectR.Create_Init(NPuntosFuncionDeformante);
            for jh := 0 to high(buffint) do
              aVect.pv[jh + 1] := buffint[jh] * alfa + beta;

            funcionesDeformantesI[j] :=
              Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(aVect, nil, 0);
          end;
        end;//Termino con las series


        {$IFDEF GRUPOS_POLARES}
        if (version >= 2) then
        begin
          GruposPolares := TGruposPolares.Create_ReadFromBinFile(f);
        end;
        {$ENDIF}

        if (version > 0) then
          bri(NFiltros)
        else
          NFiltros := 1;

        if NFiltros = 1 then
        begin
          readFiltro_bin(A_cte, B_cte);
          mcA := nil;
          mcB := nil;
        end
        else
        begin
          A_cte := nil;
          B_cte := nil;
          setlength(mcA, nFiltros);
          setlength(mcB, nFiltros);
          for kFiltro := 0 to high(mcA) do
            readFiltro_bin(mcA[kFiltro], mcB[kFiltro]);
        end;

        bri(nVE);
        SetLength(nDiscsVsE, nVE);
        SetLength(nombreVarE, nVE);
        MRed := TMatR.Create_Init(nVe, nColsA);
        // Creamos la matriz de probabilidades
        setlength(ProbsVsE, nVE);

        if nVE > 0 then
          blockRead(f, nDiscsVsE[0], sizeOf(integer) * nVE);
        for i := 1 to nVE do
        begin
          //nombre de la var
          brs(linea);
          nombreVarE[i - 1] := string(linea);
          blockRead(f, MRed.pm[i].pv[1], MRed.nc * sizeOf(NReal));

          // leemos las probabilidades asignadas
          setlength(ProbsVsE[i - 1], nDiscsVsE[i - 1]);
          blockRead(f, ProbsVsE[i - 1][0], nDiscsVsE[i - 1] * sizeOf(NReal));
        end;

        MAmp_cte := TMatR.Create_Init(MRed.nc, MRed.nf);
        for i := 1 to MRed.nf do
        begin
          ne2_FilaR := MRed.Fila(i).ne2;
          if ne2_FilaR < AsumaCero then
            raise Exception.Create('Error de modelo CEGH, la fila: ' +
              IntToStr(i) + ' del redutor de estado tiene norma nula.');
          for j := 1 to MAmp_cte.nf do
            MAmp_cte.pon_e(j, i, MRed.e(i, j) / ne2_FilaR);
        end;


        Calc_Bamp_cte;


        if nVE_aux > 0 then
        begin
          MRed_aux := TMatR.Create_Init(nVe_aux, nColsA);
          for i := 1 to nVE_aux do
            blockRead(f, MRed_aux.pm[i].pv[1], MRed_aux.nc * SizeOf(NReal));
        end
        else
        begin
          nVE_aux := 0;
          MRed_aux := nil;
        end;
      finally
        setlength(buffint, 0);
        CloseFile(f);
      end

    except
      on e: Exception do
      begin
        if gaussiana <> nil then
          gaussiana.Free;
        if A_cte <> nil then
          A_cte.Free;
        if B_cte <> nil then
          B_cte.Free;
        raise e;
      end
    end;
  end
  else
    raise Exception.Create('Datos sintetizador, NO Encuentro el archivo:' +
      nombreArchivo);
end;


constructor TModeloCEGH.Create(NSS: integer; NombresDeBornes_Publicados: TStringList;
  NOrdenDelFiltro, NFD, NPFD: integer; durPasoDeSorteoEnHoras: integer;
  nVERed: integer);
var
  i, j: integer;
  A_nc: integer;
begin
  version := VERSION_FORMATO_CEGH;

  {$IFDEF GRUPOS_POLARES}
  GruposPolares := TGruposPolares.Create_vacio;
  {$ENDIF}

  gaussiana := Tf_ddp_GaussianaNormal.Create(nil, 31);

  nBornesSalida := NSS;

  self.NombresDeBornes_Publicados := NombresDeBornes_Publicados;
  Self.durPasoDeSorteoEnHoras := durPasoDeSorteoEnHoras;

  A_nc := NSS * NOrdenDelFiltro;

  { ??? rch 090425 - comento esto pues me parece que está de más
  pues cuando el modelo se crea con Create se asignan las matrices desde fuera.
  A:= TMatR.Create_Init( NSS, A_nc );
  B:= TMatR.Create_Init( NSS, NSS );
   }

  A_cte := nil;
  B_cte := nil;

  nRetardos := NOrdenDelFiltro;

  // esto lo pongo a nil para que no jorobe
  mcA := nil;
  mcB := nil;

  MRed := TMatR.Create_Init(nVERed, A_nc);
  MAmp_cte := TMatR.Create_init(A_nc, nVERed);
  nVE := nVERed;

  MRed_aux := nil;
  nVE_aux := 0;

  setlength(nDiscsVsE, nVE);
  setlength(ProbsVsE, nVE);
  setlength(nombreVarE, nVE);

  NPuntosFuncionDeformante := NPFD;

  setlength(funcionesDeformantes, NSS);
  for i := 0 to NSS - 1 do
  begin
    setlength(funcionesDeformantes[i], NFD);
    for j := 0 to NFD - 1 do
      funcionesDeformantes[i][j] :=
        Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(TVectR.Create_Init(NPFD), nil, 0);
  end;
end;


constructor TModeloCEGH.Create_MultiCiclo(NSS: integer;
  NombresDeBornes_Publicados: TStringList; NOrdenDelFiltro, NFD, NPFD: integer;
  durPasoDeSorteoEnHoras: integer; nVERed: integer);

begin
  Create(NSS, NombresDeBornes_Publicados,
    NOrdenDelFiltro, NFD, NPFD,
    durPasoDeSorteoEnHoras,
    nVERed);
  setlength(mcA, NPFD);
  setlength(mcB, NPFD);
  version := VERSION_FORMATO_CEGH;
end;

procedure WriteFiltro(var f: TextFile; A, B: TMatR);
var
  k, j, NSS, NOrdenDelFiltro: integer;
begin
  NSS := A.nf;
  NOrdenDelFiltro := A.nc div A.nf;

  writeln(f, '<+FILTRO LINEAL>');
  writeln(f, 'NFRBG', #9, B.nc);
  writeln(f, 'NSS', #9, A.nf);
  writeln(f, 'NCOLSA', #9, A.nc);
  writeln(f);

  //Copiado de donde escribe filtroAB pero para f
  writeln(f, 'Filtro A');

  // encabezado de la matriz A
  Write(f, #9#9);
  for j := 1 to NOrdenDelfiltro do
    for k := 1 to NSS do
      Write(f, #9, 'S', k, '-', j);
  Write(f, #9'|'); // separador

  // encabezado de la matriz B
  for j := 1 to B.nc do
    Write(f, #9, 'u', j);
  writeln(f, #9'|');

  for k := 1 to A.nf do
  begin
    Write(f, ' serie: ', #9, k, #9, '|');
    for j := 1 to A.nc do
      Write(f, #9, A.e(k, j));
    Write(f, #9'|');
    for j := 1 to B.nc do
      Write(f, #9, B.e(k, j));
    writeln(f, #9'|');
  end;
  writeln(f);
end;

procedure TModeloCEGH.WriteToArchi(nombreArchivo: string;
  NDigitosDeformadores, NDecimalesDeformadores: integer);
var
  f: textfile;
  kserie, k, j: integer;
  kpaso: integer;
  NSS, NFD, NPFD: integer;
  NOrdenDelFiltro: integer;

begin
  assignFile(f, nombreArchivo);
  rewrite(f);
  uauxiliares.setSeparadoresGlobales;

  system.writeln(f, 'VERSION_FORMATO_CEGH:', #9, VERSION_FORMATO_CEGH);


  NSS := nBornesSalida;
  NFD := length(funcionesDeformantes[0]);
  NPFD := funcionesDeformantes[0][0].a.n;
  if A_cte <> nil then
    NOrdenDelFiltro := A_cte.nc div A_cte.nf
  else
    NOrdenDelFiltro := mcA[0].nc div mcA[0].nf;

  writeln(f, '<+FUNCIONES DEFORMANTES>');
  writeln(f, 'NSS', #9, nBornesSalida, #9, 'Número de Series de Salida');
  writeln(f, 'NPP', #9, NFD, #9, 'Número de Puntos por Período');
  writeln(f, 'NPFD', #9, NPFD, #9, 'Número de Puntos por Función Deformante');
  writeln(f, 'DurPasoSorteo', #9, durPasoDeSorteoEnHoras);
  // ahora escribimos los uniformizadores de cada serie
  for kserie := 0 to nBornesSalida - 1 do
  begin
    writeln(f, 'serie' + IntToStr(kserie + 1), #9, NombresDeBornes_Publicados[kserie]);
    Write(f, ' ', #9);
    // escribimos los %
    for j := 1 to NPFD do
      //PA@ 091028 la probabilidad estaba mal impresa. No se condecía con los resultados
      //de Tf_ddp_VectDeMuestras.area_t
      //      write( f, #9, trunc(j/NPFD*1000+0.5)/10.0 : 5:2,'%' );
      Write(f, #9, FloatToStrF((j - 1) / (NPFD - 1) * 100, ffGeneral, 6, 3), '%');
    writeln(f);
    for kpaso := 1 to NFD do
    begin
      Write(f, 'paso: ', #9, kpaso);
      for j := 1 to NPFD do
        Write(f, #9, funcionesDeformantes[kserie][kpaso - 1].a.e(
          j): NDigitosDeformadores: NDecimalesDeformadores);
      writeln(f);
    end;
    writeln(f);
  end;

  {$IFDEF GRUPOS_POLARES}
  if version >= 2 then
  begin
    GruposPolares.WriteToTextFile(f);
  end;
  {$ENDIF}

  if A_cte <> nil then
  begin
    writeln(f, 'NFILTROS: ' + #9 + ' 1');
    writeFiltro(f, A_cte, B_cte);
  end
  else
  begin
    writeln(f, 'NFILTROS: ' + #9 + IntToStr(length(mcA)));
    for j := 0 to high(mcA) do
    begin
      writeln('WriteFiltro-> ', j );
      writeFiltro(f, mcA[j], mcB[j]);
    end;
  end;

  writeln(f, 'nVE', #9, nVE);
  for k := 0 to nVE - 1 do
  begin
    Write(f, 'nd' + IntToStr(k + 1), #9, nDiscsVsE[k], #9, nombreVarE[k]);
    for j := 1 to MRed.nc do
      Write(f, #9, MRed.e(k + 1, j): 12: 4);
    writeln(f, #9, 'EstadoInicial', #9, 0);
    Write(f, 'probs');
    for j := 1 to nDiscsVsE[k] do
      Write(f, #9, ProbsVsE[k][j - 1]: 12: 4);
    writeln(f);
  end;
  uauxiliares.setSeparadoresLocales;
  closeFile(f);
end;



procedure TModeloCEGH.WriteToArchi_bin(nombreArchivo: string);

var
  f: file of byte;
  kserie, k: integer;
  kpaso: integer;
  {NSS,} NFD, NPFD: integer;
  //  NOrdenDelFiltro: integer;

  //  tm: TMatR;
  tv: TVectR;

  //  kmin, kmax: integer;
  jh: integer;
  minval, maxval: NReal;
  alfa, beta: NReal;
  buffint: array of smallint;

  procedure bwi(n: integer);
  begin
    blockwrite(f, n, sizeof(n));
  end;

  procedure bwr(r: NReal);
  begin
    blockwrite(f, r, sizeof(r));
  end;

  procedure bws(const s: ansistring);
  var
    n: integer;
  begin
    n := length(s);
    bwi(n);
    blockwrite(f, s[1], n);
  end;


  procedure WriteFiltro_bin(A, B: TMatR);
  var
    k: integer;
  begin
    bwi(B.nc);
    bwi(A.nc);
    for k := 1 to nBornesSalida do
    begin
      blockWrite(f, A.pm[k].pv[1], A.nc * SizeOf(NReal));
      blockWrite(f, B.pm[k].pv[1], B.nc * SizeOf(NReal));
    end;
  end;

begin
  assignFile(f, nombreArchivo);
  rewrite(f);

  //  NSS:= nBornesSalida;
  NFD := length(funcionesDeformantes[0]);
  NPFD := funcionesDeformantes[0][0].a.n;
  //  NOrdenDelFiltro:= A.nc div A.nf;

  bwi(-1); // solo para indicar que viene el Nº de versión.
  bwi(VERSION_FORMATO_CEGH); // la versión.

  bwi(nBornesSalida);
  bwi(NFD);
  bwi(NPFD);
  bwi(durPasoDeSorteoEnHoras);


  setlength(buffint, NPFD);

  // ahora escribimos los uniformizadores de cada serie
  for kserie := 0 to nBornesSalida - 1 do
  begin
    bws(NombresDeBornes_Publicados[kserie]);
    for kpaso := 1 to NFD do
    begin
      tv := funcionesDeformantes[kserie][kpaso - 1].a;
      minVal := tv.pv[1];
      maxVal := tv.pv[tv.n];
      alfa := (maxVal - minVal) / 65000.0;
      if abs(alfa) < 1e-12 then
        alfa := 1;
      beta := (maxVal + minVal) / 2;
      bwr(alfa);
      bwr(beta);
      alfa := 1 / alfa; // inverso del alfa a guardar
      for jh := 0 to high(buffint) do
      begin
        buffint[jh] := trunc((tv.pv[jh + 1] - beta) * alfa + 0.5);
      end;
      blockWrite(f, buffint[0], sizeOf(buffint[0]) * NPFD);
    end;
  end;


  {$IFDEF GRUPOS_POLARES}
  if version >= 2 then
  begin
    GruposPolares.WriteToBinFile(f);
  end;
  {$ENDIF}

  if A_cte <> nil then
  begin
    bwi(1); // con esto indicamos que es uno solo
    writeFiltro_bin(A_cte, B_cte);
  end
  else
  begin
    bwi(length(mcA));
    for kPaso := 0 to high(mcA) do
      writeFiltro_bin(mcA[kPaso], mcB[kPaso]);
  end;

  bwi(nVE);
  if nVE > 0 then
    blockWrite(f, nDiscsVsE[0], sizeOf(integer) * nVE);

  for k := 1 to nVE do
  begin
    //nombre de la var
    bws(nombreVarE[k - 1]);
    blockWrite(f, MRed.pm[k].pv[1], MRed.nc * sizeOf(NReal));

    // Escribimos las probabilidades asignadas
    blockWrite(f, ProbsVsE[k - 1][0], nDiscsVsE[k - 1] * sizeOf(NReal));
  end;

  if MRed_aux <> nil then
  begin
    bwi(MRed_aux.nf);
    for k := 1 to MRed_aux.nf do
      blockWrite(f, MRed_aux.pm[k].pv[1], MRed_aux.nc * SizeOf(NReal));
  end
  else
  begin
    k := 0;
    bwi(k);
  end;

  setlength(buffint, 0);
  closeFile(f);
end;


procedure TModeloCEGH.xTog_Series(x: TSeriesDeDatos; flg_AplicarFiltrado: boolean;
  umbral_filtro: NReal);
var
  iSerie, kMuestra, kDeformador: integer;
  m: NReal;
begin
  for kMuestra := 1 to x.series[0].n do
  begin
    kDeformador := x.kDefomador(kMuestra);
    for iSerie := 1 to x.NSeries do
    begin
      m := x.series[iSerie - 1].e(kMuestra);
      if flg_AplicarFiltrado then
      begin
        if m > umbral_filtro then
          x.series[iSerie - 1].pon_e(kMuestra, xTog(m, iSerie, kDeformador));
      end
      else
        x.series[iSerie - 1].pon_e(kMuestra, xTog(m, iSerie, kDeformador));
    end;
  end;
end;


procedure TModeloCEGH.gTox_Series(x: TSeriesDeDatos; flg_AplicarFiltrado: boolean;
  umbral_filtro: NReal);
var
  iSerie, kMuestra, kDeformador: integer;
  m: NReal;
begin
  for kMuestra := 1 to x.series[0].n do
  begin
    kDeformador := x.kDefomador(kMuestra);
    for iSerie := 1 to x.NSeries do
    begin
      m := x.series[iSerie - 1].e(kMuestra);
      if flg_AplicarFiltrado then
      begin
        if m > umbral_filtro then
          x.series[iSerie - 1].pon_e(kMuestra, gTox(m, iSerie, kDeformador));
      end
      else
        x.series[iSerie - 1].pon_e(kMuestra, gTox(m, iSerie, kDeformador));
    end;
  end;
end;

procedure TModeloCEGH.GenRealizacion(xSeries: TSeriesDeDatos; semilla: integer);
var
  X: TVectR;
  Y, Xs: TVectR;
  rbg: TVectR;
  kSelector: integer;
  kDato: integer;
  kSerie: integer;
  m: NReal;
  j: integer;

begin
  X := CrearVector_EstadoX;
  Xs := CrearVector_Salida;
  Y := CrearVector_Salida;
  rbg := CrearVector_RBG;

  // Inicialización del filtro.
  for kDato := 1 to nRetardos do
  begin
    kSelector := xSeries.kDefomador(kDato);
    for kSerie := 1 to xseries.nSeries do
    begin
      m := xtog(xseries.series[kserie - 1].e(kDato), kSerie, kSelector);
      X.pon_e((nRetardos - kDato) * xseries.nSeries + kSerie, m);
    end;
  end;

  // Inicializamos el sorteador con la semilla.
  gaussiana.Reiniciar(semilla);


  // ahora evolucionamos y vamos completando las series
  for kDato := nRetardos + 1 to xSeries.NPuntos do
  begin
    SortearValores(rbg);
    kSelector := xSeries.kDefomador(kDato);
    CalcularProximasSalidas(Xs, X, rbg, kSelector);
    for kSerie := 1 to xSeries.NSeries do
    begin
      m := gToX(Xs.e(kSerie), kSerie, kSelector);
      xseries.series[kSerie - 1].pon_e(kDato, m);
    end;
    // ahora actualizamos el estado haciendo el shift e incorporando Xs
    for j := X.n downto xSeries.NSeries + 1 do
      X.pon_e(j, X.e(j - xSeries.NSeries));
    for j := 1 to xSeries.NSeries do
      X.pon_e(j, Xs.e(j));
  end;

end;


function TModeloCEGH.xTog(x: NReal; kSerie, kPaso: integer): NReal;
var
  u: NReal;
  p: Tf_ddp_VectDeMuestras;
begin
  p := funcionesDeformantes[kSerie - 1][kPaso - 1];
  u := p.area_t(x);
  //  Result := u;
  Result := Gaussiana.t_area(u);
end;


function TModeloCEGH.gTox(g: NReal; kSerie, kPaso: integer): NReal;
var
  u: NReal;
  p: Tf_ddp_VectDeMuestras;
begin
  p := funcionesDeformantes[kSerie - 1][kPaso - 1];
  u := Gaussiana.area_t(g);
  Result := p.t_area(u);
end;


// busca los negativos y los anula. Esto es para el tratamiento de los KT (indice de claridad)
procedure TModeloCEGH.Anular_Negativos_DelDeformador(kSerie: integer);
var
  p: Tf_ddp_VectDeMuestras;
  kpaso: integer;
  j: integer;
begin
  for kPaso := 0 to high(funcionesDeformantes[kSerie - 1]) do
  begin
    p := funcionesDeformantes[kSerie - 1][kPaso];
    for j := 1 to p.a.n do
      if p.a.e(j) < 0 then
        p.a.pon_e(j, 0);
  end;
end;


// Crea los deformadors a partir de las series de datos.
procedure TModeloCEGH.CrearDeformadores(seriesDeDatos: TSeriesDeDatos;
  // series a utilizar
  overlapping, traslapping, NPuntosPorMiniciclo: integer; FiltrarMenores: boolean;
  umbralFiltro: NReal; NCronicasRuido: integer; PrecisionMedida_pu: NReal
  );
var
  kserie: integer;
begin

  (* Para cada serie, calculamos los uniformizadores.
  Cada casillero de FX tiene un vector de fuentes aleatorias
  una para cada punto de un ciclo con igual histograma que el grupo
  de puntos de la serie original para ese punto del ciclo *)
  for kserie := 1 to seriesDeDatos.NSeries do
    funcionesDeformantes[kserie - 1] :=
      uniformizadores_(seriesDeDatos.series[kserie - 1],
      seriesDeDatos.rNPPorCiclo, seriesDeDatos.rOffsetCiclo, overlapping,
      traslapping, NPuntosPorMiniciclo, FiltrarMenores, umbralFiltro,
      NPuntosFuncionDeformante, NCronicasRuido, PrecisionMedida_pu );

end;


// Gaussianiza las series.
procedure TModeloCEGH.GaussianizarSeries(seriesDeDatos: TSeriesDeDatos;
  FiltrarMenores: boolean; umbralFiltro: NReal; FiltrarAlGaussianizar: boolean;
  umbralFiltroAlGaussianizar: NReal;
  kCronRuido: integer; precicionMedida_pu: NReal );

var
  kPaso, kPunto, kSerie: integer;
  u, y: NReal;
  ruido: Tf_ddp_GaussianaNormal;
  kMinVal, kMaxVal: integer;
  minVal, MaxVal, rango: NReal;
  aSerie: TVectR;

begin
  if kCronRuido > 1 then
    ruido:= Tf_ddp_GaussianaNormal.Create( nil, 31 + kCronRuido * seriesDeDatos.NPuntos * seriesDeDatos.NSeries );
  // ahora transformamos los datos de las series obteniendo así
  // las señales gaussianas con las que podremos hacer la identificación
  // lineal.
  for kSerie := 1 to seriesDeDatos.NSeries do
  begin
    aSerie:= seriesDeDatos.series[ kSerie -1];
    aSerie.MinMax( kMinVal, kMaxVal, MinVal, MaxVal );
    rango:= MaxVal - MinVal;

    for kPunto := 1 to seriesDeDatos.NPuntos do
    begin
      kPaso := seriesDeDatos.kDefomador(kPunto);
        (* Con el número de serie y el paso dentro del ciclo, identificamos
        la fuente aleatoria cuya función de distribución de prob. podemos
        usar para transformar la serie de datos en una uniforme *)
      u := aSerie.e(kPunto);
      if FiltrarAlGaussianizar and (u < umbralFiltroAlGaussianizar) then
      begin
        u := umbralFiltro - 10;
        aSerie.pon_e(kPunto, u);
      end
      else if (not FiltrarMenores) or (u > umbralFiltro) then
      begin
        if kCronRuido > 1 then
          u:= u + rango * ruido.rnd * precicionMedida_pu;
        y := xTog(u, kSerie, kPaso);
        (* Guardamos el valor transformado en la misma serie *)
        aSerie.pon_e(kPunto, y);
      end;
    end;
  end;
  if kCronRuido > 1 then
    ruido.Free;
end;


// Resta valor esperado y divide por desvío estándar.
procedure TModeloCEGH.Normalizar(seriesDeDatos: TSeriesDeDatos;
  filtrarMenores: boolean; umbralFiltro: NReal);

var
  kSerie: integer;
  u, y: NREal;
begin

  // verificamos que las varianzas de las series trasformadas
  // sean la unidad
  writeln(' Varianza y promedio de las series gaussianadas. Deberían ser 1 y 0 respectivamente.'
    );


  for kSerie := 1 to seriesDeDatos.NSeries do
  begin
    u := seriesDeDatos.Series[kSerie - 1].promedio_filtrando(umbralFiltro);
    y := seriesDeDatos.Series[kSerie - 1].varianza_filtrando(umbralFiltro);

    writeln(' varianza xg(', kSerie, '): ', y, ' , prom: ', u);

    // como puede pasar que el overlapping y el traslapping hagan que
    // la realización particular no tenga varianza 1 y eso afecta el cálculo
    // de las matrices A y B del filtro escalamos las series para llevarlas a varianza 1
    seriesDeDatos.Series[kSerie - 1].MasReal_filtrando(umbralFiltro, -u);
    seriesDeDatos.Series[kSerie - 1].PorReal_filtrando(umbralFiltro, 1 / sqrt(y));
  end;
end;


// SeriesError
function TModeloCEGH.Calc_SeriesError(seriesDeDatos: TSeriesDeDatos;
  FiltrarMenores: boolean; umbralFiltro: NReal): TSeriesDeDatos;
var
  seriesGaussianas, res: TSeriesDeDatos;
  kPaso, kSerie, kRetardo: integer;
  X: TVectR;
  Y: TVectR;
  kSel: integer;
  filtrar: boolean;
  xval: NReal;
  error: NReal;
begin
  res := seriesDeDatos.Clone;
  seriesGaussianas := seriesDeDatos.Clone;

  GaussianizarSeries(seriesGaussianas, filtrarMenores, umbralfiltro, False, -1111111, 1, 0);

  X := TVectR.Create_Init(A_nc);
  Y := TVectR.Create_Init(nBornesSalida);

  for kPaso := 1 to NRetardos do
    for kSerie := 1 to nBornesSalida do
      res.series[kSerie - 1].pon_e(kPaso, -1111111);

  for kPaso := NRetardos + 1 to seriesDeDatos.NPuntos do
  begin
    // Cargamos el Estado X
    filtrar := False;
    for kRetardo := 1 to NRetardos do
      for kSerie := 1 to nBornesSalida do
      begin
        xval := seriesGaussianas.series[kSerie - 1].e(kPaso - kRetardo);
        if FiltrarMenores and (xval < umbralFiltro) then
          filtrar := True;
        X.pon_e((kRetardo - 1) * nBornesSalida + kSerie, xval);
      end;

    if filtrar then
      for kSerie := 1 to seriesDeDatos.NSeries do
        res.series[kSerie - 1].pon_e(kPaso, umbralFiltro)
    else
    begin

      kSel := seriesDeDatos.kDefomador(kPaso);
      // Proyectamos la salida del filtro.
      if A_cte <> nil then
        A_cte.Transformar(Y, X)
      else
        mcA[kSel-1].Transformar(Y, X);

      for kSerie := 1 to seriesDeDatos.NSeries do
      begin
        error := gTox(y.e(kserie), kSerie, kSel) -
          seriesDeDatos.series[kSerie - 1].e(kPaso);
        res.series[kSerie - 1].pon_e(kPaso, error);
      end;
    end;
  end;
  X.Free;
  Y.Free;
  seriesGaussianas.Free;
  Result := res;
end;



{$IFDEF GRUPOS_POLARES}
// trasforma del espacio real al gaussiano
procedure TModeloCEGH.xTog_vect(var g, x: TDAOfNreal; kPrimerSerie, kPaso: integer);
var
  kSerie: integer;
  kGrupo: integer;
  tocadas: TDAOfBoolean;
  ro_x, fi_x, ro_g, fi_g: NReal;
  cnt_tocadas: integer;
  aGrupo: TDAOfNInt;
  iSerie: integer;

begin
  if length(GruposPolares.Grupos) > 0 then
  begin
    setlength(tocadas, A_nf);
    for kSerie := 0 to high(tocadas) do
      tocadas[kSerie] := False;
    cnt_tocadas := 0;
    for kGrupo := 0 to high(GruposPolares.Grupos) do
    begin
      aGrupo := GruposPolares.Grupos[kGrupo];
      ro_x := 0;

      for iSerie := 0 to high(aGrupo) do
        ro_x := ro_x + sqr(x[kPrimerSerie + (aGrupo[iSerie] - 1)]);
      ro_x := sqrt(ro_x);
      ro_x := power(ro_x, GruposPolares.beta);

      for iSerie := 0 to high(aGrupo) do
      begin
        kSerie := aGrupo[iSerie] - 1;
        g[kSerie] := xTog_mono(ro_x * x[kPrimerSerie + kSerie], kSerie + 1, kPaso);
        tocadas[kSerie] := True;
        Inc(cnt_tocadas);
      end;
    end;

    if cnt_tocadas < length(tocadas) then
    begin
      for kSerie := 0 to high(tocadas) do
      begin
        if not tocadas[kSerie] then
        begin
          g[kPrimerSerie + kSerie] :=
            xTog_mono(x[kPrimerSerie + kSerie], kSerie + 1, kPaso);
        end;
      end;
    end;

  end
  else
  begin
    for kSerie := 0 to A_nf - 1 do
      g[kPrimerSerie + kSerie] := xTog_mono(x[kPrimerSerie + kSerie], kSerie + 1, kPaso);
  end;

end;

// transforma del espacio gaussiano al real
procedure TModeloCEGH.gTox_vect(var x, g: TDAOfNreal; kPrimerSerie, kPaso: integer);
var
  kSerie: integer;
  kGrupo: integer;
  tocadas: TDAOfBoolean;
  i1, i2: integer;
  ro_g: NReal;
  cnt_tocadas: integer;
  aGrupo: TDAOfNInt;
  y: TDAOfNReal;
begin
  if length(GruposPolares.Grupos) > 0 then
  begin
    setlength(tocadas, A_nf);
    setlength(y, A_nf);
    for kSerie := 0 to high(tocadas) do
    begin
      tocadas[kSerie] := False;
      y[kSerie] := gToX_mono(g[kPrimerSerie + kSerie], kSerie, kPaso);
    end;
    cnt_tocadas := 0;

    for kGrupo := 0 to high(GruposPolares.Grupos) do
    begin
      aGrupo := GruposPolares.Grupos[kGrupo];
      ro_g := 0;
      for iSerie := 0 to high(aGrupo) do
        ro_g := ro_g + sqr(y[kPrimerSerie + aGrupo[iSerie] - 1]);
      ro_g := 1 / power(ro_g, 1.0 / 3.0);

      for iSerie := 0 to high(aGrupo) do
        ro_g := ro_g + sqr(y[kPrimerSerie + aGrupo[iSerie] - 1]);


      ro_x := gTox_mono(ro_g, aGrupos[0], kPaso);
      fi_x := gTox_mono(fi_g, aGrupos[1], kPaso);


      vx := ro_x * cos(fi_g);
      vy := ro_x * sin(fi_g);

      x[kPrimerSerie + i1] := vx;
      x[kPrimerSerie + i2] := vy;

      tocadas[i1] := True;
      tocadas[i2] := True;
      Inc(cnt_tocadas, 2);
    end;

    if cnt_tocadas < length(tocadas) then
    begin
      for kSerie := 0 to hign(tocadas) do
      begin
        if not tocadas[kSerie] then
        begin
          x[kPrimerSerie + kSerie] :=
            gTox_mono(g[kPrimerSerie + kSerie], kSerie + 1, kPaso);
        end;
      end;
    end;

  end
  else
  begin
    for kSerie := 1 to A_nf do
      x[kPrimerSerie + kSerie - 1] :=
        gTox_mono(g[kPrimerSerie + kSerie - 1], kSerie, kPaso);
  end;
end;


{$ENDIF}

// crea un vector de estado según la cantidad de series y el orden del filtro
function TModeloCEGH.CrearVector_EstadoX: TVectR;
begin
  if A_cte <> nil then
    Result := TVectR.Create_Init(A_cte.nc)
  else
    Result := TVectR.Create_init(mcA[0].nc);
end;

// Crea un vector del tamaño necesario para alojar las salidas
function TModeloCEGH.CrearVector_Salida: TVectR;
begin
  if A_cte <> nil then
    Result := TVectR.Create_Init(A_cte.nf)
  else
    Result := TVectR.Create_init(mcA[0].nf);
end;

// crea un vector para alamcenar los valores de las fuentes de ruido blanco
function TModeloCEGH.CrearVector_RBG: TVectR;
begin
  if B_cte <> nil then
    Result := TVectR.Create_Init(B_cte.nc)
  else
    Result := TVectR.Create_Init(mcB[0].nc);
end;

// rellena el vector con sorteos independientes con distribución normal standar
procedure TModeloCEGH.SortearValores(var rbg: TVectR);
var
  k: integer;
begin
  for k := 1 to rbg.n do
    rbg.pv[k] := gaussiana.rnd;
end;



// calculas Y= A X + B R

function TModeloCEGH.CalcularSalida(kSal: integer; const pEstadoX, pEntradaRBG: PNReal;
  kSelector: integer): NReal;
begin
  {$IFNDEF FAST_B_TRIANG_INF}
  if A_cte <> nil then
    Result := A_cte.Fila(ksal).pev(pEstadoX) + B_Cte.Fila(ksal).pev(pEntradaRBG)
  else
    Result := mcA[kSelector].Fila(ksal).pev(pEstadoX) +
      mcB[kSelector].Fila(ksal).pev(pEntradaRBG);
  {$ELSE}
  if A_cte <> nil then
    Result := A_cte.Fila(ksal).pev(pEstadoX) +
      B_Cte.Fila(ksal).pev(pEntradaRBG, 1, ksal)
  else
    Result := mcA[kSelector].Fila(ksal).pev(pEstadoX) +
      mcB[kSelector].Fila(ksal).pev(pEntradaRBG, 1, ksal);
  {$ENDIF}
end;


procedure TModeloCEGH.CalcularProximasSalidas(var SalidaY: TVectR;
  EstadoX: TVectR; entradaRBG: TVectR; kSelector: integer);
var
  ksal: integer;
begin
  {$IFNDEF FAST_B_TRIANG_INF}
  if A_cte <> nil then
    for ksal := 1 to SalidaY.n do
      SalidaY.pv[ksal] := A_cte.Fila(ksal).pev(EstadoX) +
        B_cte.Fila(ksal).pev(entradaRBG)
  else
    for ksal := 1 to SalidaY.n do
      SalidaY.pv[ksal] := mcA[kSelector].Fila(ksal).pev(EstadoX) +
        mcB[kSelector].Fila(ksal).pev(entradaRBG);
  {$ELSE}
  if A_cte <> nil then
    for ksal := 1 to SalidaY.n do
      SalidaY.pv[ksal] := A_cte.Fila(ksal).pev(EstadoX) +
        B_cte.Fila(ksal).pev(entradaRBG, 1, ksal)
  else
    for ksal := 1 to SalidaY.n do
      SalidaY.pv[ksal] := mcA[kSelector].Fila(ksal).pev(EstadoX) +
        mcB[kSelector].Fila(ksal).pev(entradaRBG, 1, ksal);
  {$ENDIF}
end;


function TModeloCEGH.CalcularSalidaConSesgo(kSal: integer;
  const pEstadoX, pEntradaRBG: PNReal; sesgoVM, atenuacion: NReal;
  kSelector: integer): NReal;
begin
  {$IFNDEF FAST_B_TRIANG_INF}
  if A_cte <> nil then
    Result := A_cte.Fila(ksal).pev(pEstadoX) + atenuacion *
      B_cte.Fila(ksal).pev(pEntradaRBG) + sesgoVM
  else
    Result := mcA[kSelector].Fila(ksal).pev(pEstadoX) + atenuacion *
      mcB[kSelector].Fila(ksal).pev(pEntradaRBG) + sesgoVM;
  {$ELSE}
  if A_cte <> nil then
    Result := A_cte.Fila(ksal).pev(pEstadoX) + atenuacion *
      B_cte.Fila(ksal).pev(pEntradaRBG, 1, ksal) + sesgoVM
  else
    Result := mcA[kSelector].Fila(ksal).pev(pEstadoX) + atenuacion *
      mcB[kSelector].Fila(ksal).pev(pEntradaRBG, 1, ksal) + sesgoVM;
  {$ENDIF}
end;

// realiza los desplazamientos en X y copia Y en los casilleros que corresponde
procedure TModeloCEGH.EvolucionarEstado_(var EstadoX: TVectR; SalidaY: TVectR);
var
  kserie, jcol: integer;
  ordenFiltro: integer;

begin
  ordenFiltro := CalcOrdenDelFiltro;
  if A_cte <> nil then
  begin
    for jcol := A_cte.nf * ordenFiltro downto A_cte.nf + 1 do
      EstadoX.pv[jcol] := EstadoX.pv[jcol - A_cte.nf];

    for kserie := 1 to A_cte.nf do
      EstadoX.pv[kserie] := SalidaY.pv[kserie];
  end
  else
  begin
    for jcol := mcA[0].nf * ordenFiltro downto mcA[0].nf + 1 do
      EstadoX.pv[jcol] := EstadoX.pv[jcol - mcA[0].nf];

    for kserie := 1 to mcA[0].nf do
      EstadoX.pv[kserie] := SalidaY.pv[kserie];
  end;

end;


// retorna el orden del filtro
function TModeloCEGH.CalcOrdenDelFiltro: integer;
begin
  if A_cte <> nil then
    Result := A_cte.nc div A_cte.nf
  else
    Result := mcA[0].nc div mcA[0].nf;
end;



procedure TModeloCEGH.InicializarDesdeDatosReales(X: TVectR;
  serieHistorica: TSeriesDeDatos; kPaso: integer; desp_selector0: integer);
var
  kSerie: integer;
  jRetardo: integer;
  ipaso: integer;
  OrdenDelFiltro: integer;
  kSelector: integer;
begin
  OrdenDelFiltro := CalcOrdenDelFiltro;
  for kSerie := 0 to serieHistorica.NSeries - 1 do
  begin
    for jRetardo := 1 to OrdenDelFiltro do
    begin
      ipaso := kPaso - jRetardo + 1;
      if ipaso > 0 then
      begin
        kSelector := serieHistorica.kDefomador(ipaso);
        x.pv[(jRetardo - 1) * OrdenDelFiltro + kSerie + 1] :=
          xtog(serieHistorica.series[kserie].pv[ipaso], kSerie + 1, kSelector);
      end
      else
        x.pv[(jRetardo - 1) * OrdenDelFiltro + kSerie + 1] := 0;
    end;
  end;
end;



function TModeloCEGH.kSelectorDeformador(fecha: TFecha): integer;
var
  res: integer;
begin
  case durPasoDeSorteoEnHoras of
    730: res := fecha.mes - 1;
    672: res := (fecha.semana52 - 1) div 4; // se agrega paso de tiempo de 4 semanas
    336: res := (fecha.semana52 - 1) div 2; //se agrega paso de tiempo de 2 semanas
    168: res := fecha.semana52 - 1;
    24: if nPuntosPorPeriodo = 7 then
      res:= DayOfWeek(  fecha.dt )-1
      else
      res := min(fecha.diaDelAnio - 1, 364);
    1: res := fecha.horasDesdeElInicioDelAnio;
    else
      raise Exception.Create(rs_kSelectorDeformador + IntToStr(durPasoDeSorteoEnHoras));
  end;
  Result := res mod nPuntosPorPeriodo;
end;



function TModeloCEGH.Dim_X: integer;
begin
  Result := A_nc;
end;

function TModeloCEGH.Dim_XRed: integer;
begin
  if MRed <> nil then
    Result := MRed.nf
  else
    Result := 0;
end;

function TModeloCEGH.A_nc: integer;
begin
  if A_cte <> nil then
    Result := A_cte.nc
  else
    Result := mcA[0].nc;
end;

function TModeloCEGH.A_nf: integer;
begin
  if A_cte <> nil then
    Result := A_cte.nf
  else
    Result := mcA[0].nf;
end;

function TModeloCEGH.B_nc: integer;
begin
  if B_cte <> nil then
    Result := B_cte.nc
  else
    Result := mcB[0].nc;
end;

function TModeloCEGH.B_nf: integer;
begin
  if B_cte <> nil then
    Result := B_cte.nf
  else
    Result := mcB[0].nf;
end;


procedure TModeloCEGH.Free;
var
  i, j: integer;
begin
  for i := 0 to High(funcionesDeformantes) do
  begin
    for j := 0 to high(funcionesDeformantes[i]) do
      funcionesDeformantes[i][j].Free;
    SetLength(funcionesDeformantes[i], 0);
  end;
  SetLength(funcionesDeformantes, 0);

  SetLength(nDiscsVsE, 0);
  for i := 0 to high(ProbsVsE) do
    setlength(ProbsVsE[i], 0);
  setlength(ProbsVsE, 0);

  SetLength(nombreVarE, 0);
  NombresDeBornes_Publicados.Free;

  if A_cte <> nil then
    A_cte.Free;
  if B_cte <> nil then
    B_cte.Free;
  if mcA <> nil then
  begin
    for i := 0 to high(mcA) do
      if mcA[i] <> nil then
        mcA[i].Free;
    SetLength(mcA, 0);
  end;
  if mcB <> nil then
  begin
    for i := 0 to high(mcB) do
      if mcB[i] <> nil then
        mcB[i].Free;
    SetLength(mcB, 0);
  end;

  if MRed <> nil then
    MRed.Free;
  if MAmp_cte <> nil then
    MAmp_cte.Free;
  if MRed_aux <> nil then
    MRed_aux.Free;

  gaussiana.Free;
  inherited Free;
end;

function createNilTMatOf_ddp_VectDeMuestras(filas, columnas: integer):
TMatOf_ddp_VectDeMuestras;
var
  i, j: integer;
  res: TMatOf_ddp_VectDeMuestras;
begin
  SetLength(res, filas);
  for i := 0 to filas - 1 do
  begin
    SetLength(res[i], columnas);
    for j := 0 to columnas - 1 do
      res[i][j] := nil;
  end;
  Result := res;
end;

procedure freeTMatOf_ddp_VectDeMuestras(var matriz: TMatOf_ddp_VectDeMuestras);
var
  i, j: integer;
begin
  for i := 0 to high(matriz) do
  begin
    for j := 0 to High(matriz[i]) - 1 do
    begin
      if matriz[i][j] <> nil then
        matriz[i][j].Free;
    end;
    SetLength(matriz[i], 0);
  end;
  SetLength(matriz, 0);
end;



(**
constructor TModeloCEGH_EntradaSalida.Create(
  NS_Entrada, NS_Salida: integer;
  tiposDeSerie: TDAOfTipoSerie;
  NombresDeBornes_Publicados: TStringList;
  NOrdenDelFiltro, NFD, NPFD: integer;
  durPasoDeSorteoEnHoras: integer; nVERed: integer);
var
  i, j: integer;
  A_nc, A_nf: integer;
begin
  version := VERSION_FORMATO_CEGH;
  NSeriesEntrada:= NS_Entrada;
  NSeriesSalida:= NS_Salida;

  {$IFDEF GRUPOS_POLARES}
  GruposPolares := TGruposPolares.Create_vacio;
  {$ENDIF}

  gaussiana := Tf_ddp_GaussianaNormal.Create(nil, 31);

  nBornesSalida := NS_Salida;
  self.NombresDeBornes_Publicados := NombresDeBornes_Publicados;

  Self.durPasoDeSorteoEnHoras := durPasoDeSorteoEnHoras;

  A_nc := NS_Entrada * NOrdenDelFiltro;
  A_nf := NS_Salida;

  A_cte := nil;
  B_cte := nil;

  nRetardos := NOrdenDelFiltro;

  // esto lo pongo a nil para que no jorobe
  mcA := nil;
  mcB := nil;

  MRed := TMatR.Create_Init(nVERed, A_nc);
  MAmp_cte := TMatR.Create_init(A_nc, nVERed);
  nVE := nVERed;

  MRed_aux := nil;
  nVE_aux := 0;

  setlength(nDiscsVsE, nVE);
  setlength(ProbsVsE, nVE);
  setlength(nombreVarE, nVE);

  NPuntosFuncionDeformante := NPFD;

  setlength(funcionesDeformantes, NS_Entrada + NS_Salida );
  for i := 0 to high( funcionesDeformantes ) do
  begin
    setlength(funcionesDeformantes[i], NFD);
    for j := 0 to NFD - 1 do
      funcionesDeformantes[i][j] :=
        Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(TVectR.Create_Init(NPFD), nil, 0);
  end;

end;

procedure TModeloCEGH_EntradaSalida.WriteToArchi( archi: string );
var
  f: textfile:
begin
  assignfile(f, archi );
  rewrite( f );
  writeln( f, 'Version: ', VERSION );
  write( f, 'Tipos_de_series', #9 );
  for kSerie:= 0 to nBornesSalida -1 do
     if tiposDeSerie[k] = ENTRADA then
       write( f, 'x')
     else
       write( f, 'y');
  writlen( f );

end;

constructor TModeloCEGH_EntradaSalida.CreateReadFromArchi( archi: string );
begin

setlength( tiposDeSerie, nBornesSalida );
if version >= 3 then
begin
 //Leo tipos de series
  Readln(f , linea );
  nextPal( linea );
  for k:= 1 to nBornesSalida -1  do
    if lowerCase( linea[k] ) = 'x' then
      tiposDeSerie[k-1]:= ENTRADA
    else
      tiposDeSeries[k-1]:= SALIDA;
end
else
  for k:= 1 to nBornesSalida -1  do
    if lowerCase( linea[k] ) = 'x' then
      tiposDeSerie[k-1]:= ENTRADA
    else
      tiposDeSeries[k-1]:= SALIDA;

end;



{ Creta un juego de series con las salidas proyectas del CEGH a partir
de las entradas }
function TModeloCEGH_EntradaSalida.Calc_Series(
  seriesDeDatos: TSeriesDeDatos;
  FiltrarMenores: boolean; umbralFiltro: NReal): TSeriesDeDatos;
var
  seriesGaussianas, res: TSeriesDeDatos;
  kPaso, kSerie, kRetardo: integer;
  X: TVectR;
  Y: TVectR;
  kSel: integer;
  filtrar: boolean;
  xval: NReal;
  yval: NReal;
begin
  res := seriesDeDatos.Clone_Salidas;
  seriesGaussianas := seriesDeDatos.Clone_Entradas;

  GaussianizarSeries(seriesGaussianas, filtrarMenores, umbralfiltro, False, -1111111);
  X := TVectR.Create_Init(A_cte.nc);
  Y := TVectR.Create_Init( NSeriesSalida );

  for kPaso := 1 to NRetardos do
    for kSerie := 1 to nBornesSalida do
      res.series[kSerie - 1].pon_e(kPaso, -1111111);

  for kPaso := NRetardos + 1 to seriesDeDatos.NPuntos do
  begin
    // Cargamos el Estado X
    filtrar := False;
    for kRetardo := 1 to NRetardos do
      for kSerie := 1 to nBornesSalida do
      begin
        xval := seriesGaussianas.series[kSerie - 1].e(kPaso - kRetardo);
        if FiltrarMenores and (xval < umbralFiltro) then
          filtrar := True;
        X.pon_e((kRetardo - 1) * nBornesSalida + kSerie, xval);
      end;

    if filtrar then
     for kSerie := 1 to seriesDeDatos.NSeries do
       res.series[kSerie - 1].pon_e(kPaso, umbralFiltro)
    else
    begin
      kSel := seriesDeDatos.kDefomador(kPaso);
      // Proyectamos la salida del filtro.
      if A_cte <> nil then
        A_cte.Transformar(Y, X)
      else
        mcA[kSel].Transformar(Y, X);

      for kSerie := 1 to res.NSeries do
      begin
        yval := gTox(y.e(kserie), kSerie, kSel);
        res.series[kSerie - 1].pon_e(kPaso, yval);
      end;
    end;
  end;
  X.Free;
  Y.Free;
  seriesGaussianas.Free;
  Result := res;
end;
*)

initialization
  lst_ModelosCargados := TList.Create;

end.
