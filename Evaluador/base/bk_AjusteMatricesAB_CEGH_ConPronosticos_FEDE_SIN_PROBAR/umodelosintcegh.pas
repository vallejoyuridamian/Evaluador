unit umodelosintcegh;

{$MODE Delphi}
{$DEFINE RUIDA_MULTI_RETARDOS}
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
  xMatDefs, Classes, matreal, MatEnt, SysUtils, uAuxiliares, fddp, ufechas,
  Math;

resourcestring
  rs_kSelectorDeformador = 'kSelectorDeformador, no especificado para dh:';
  rs_ErrorDimDiscretizacion_VarE =
    'Error!. El mínimo valor para una discretización de una variable de estado es 2';



type

  TDAOf_ddp_VectDeMuestras = array of Tf_ddp_VectDeMuestras;
  TMatOf_ddp_VectDeMuestras = array of TDAOf_ddp_VectDeMuestras;
  TDAOfVectR = array of TVectR;
  TDAOfVectE = array of TVectE;


const
 // rch@201407170838 agrego que se pueda especificar conjunto de canales
 // que deben ser transformados a POLARES para pasar los deformadores
 // de forma de poder garantizar histogramas de módulo y direcciones se
 // conservan.
  VERSION_FORMATO_SERIES = 2;
  VERSION_FORMATO_CEGH = 2;

{
  VERSION_FORMATO_SERIES = 1;
  VERSION_FORMATO_CEGH = 1;
 }
type
  TIPO_SERIE = (SALIDA, ENTRADA);

  {$IFDEF GRUPOS_POLARES}
  TGruposPolares = class
   Grupos:TDAOfDAOfNInt;
   beta: NReal;
   constructor Create_vacio;
   constructor Create_ReadFromTextFile(
    var f: textFile;
    var cnt_linea: integer;
    var ultimalinealeida: string;
    var flg_ultimalineausada: boolean );
   procedure WriteToTextFile( var f: textfile );
   constructor Create_ReadFromBinFile( var f: file );
   procedure WriteToBinFile( var f: file );
   procedure Free;
  end;
  {$ENDIF}


  (* Clase para soporte de las series de datos *)
  TSeriesDeDatos = class
  public
    version: integer;
    archi: string;
    NSeries: integer;
    // Información de la primera muedtra (PM)
    PM_Anio, PM_Mes, PM_Dia, PM_Hora, PM_Minuto, PM_segundo: integer;
    PeriodoDeMuestreo_horas: NReal;
    NPuntos, NPPorCiclo: integer;
    nombresSeries: TStringList;
    series: TDAOfVectR;
    tipo_serie: array of TIPO_SERIE;
{$IFDEF GRUPOS_POLARES}
    GruposPolares: TGruposPolares;
{$ENDIF}
    constructor CreateFromArchi(archi: string);
    procedure WriteToArchi(archi: string);

    // Ojo, supone que las series ya están normalizadas (sin valor esperado y con desvío = 1).
    procedure WriteCOVARS( archi: string );
    procedure Free;

    // Si el Nuevo_PeriodoDeMuestreo_horas > PeriodoDeMuestreo_horas
    function Resampling( Nuevo_PeriodoDeMuestreo_horas: NReal ): TSeriesDeDatos;
  private
    // Crea un grupo de series con la misma información que el grupo actual.
    // Lo único que no hace es fijar el largo los vectores de "series"
    function CreateCloneHeadInfo: TSeriesDeDatos;


  end;



  // Clase para leer archivos resultados de AnalisisSerial

  { TModeloSintetizadorCEGH }

  TModeloSintetizadorCEGH = class
  public
    version: integer;

    A_cte, B_cte: TMatR; // Matrices del Filtro Lineal.
    mcA, mcB: TDAOfMatR;

    MRed: TMatR; // Matriz Reductora de estado. Xred = R X
    MRed_aux: TMatR; // usado en caso de tener una forma auxiliar de reducción

    MAmp_cte: TMatR; // Matriz Amplificadora del estdo,

    {$IFDEF EXPANSION_RUIDA}
      BAmp_: TMatR; // Recomponedor de la varianza si hay reducción de estado
    {$ENDIF}

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

    // crea el conjunto de datos vacio para ser llenado desde el identificador
    constructor Create(NSS: integer; NombresDeBornes_Publicados: TStringList;
      NOrdenDelFiltro, NFD, NPFD: integer; durPasoDeSorteoEnHoras: integer;
      nVERed: integer);

    constructor Create_MultiCiclo(NSS: integer;
      NombresDeBornes_Publicados: TStringList; NOrdenDelFiltro, NFD, NPFD: integer;
      durPasoDeSorteoEnHoras: integer; nVERed: integer);

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

    // trasforma del espacio real al gaussiano
    function xTog(x: NReal; kSerie, kPaso: integer): NReal;

    // transforma del espacio gaussiano al real
    function gTox(g: NReal; kSerie, kPaso: integer): NReal;


    {$IFDEF GRUPOS_POLARES}
    // trasforma del espacio real al gaussiano
    // kPrimerSerie idientifica la posición de la primer serie en los vectores g y x
    // esto permite pasar las borneras de las fuentes por referencia e indicar qué posición
    // dentro de la bornera contiene los valores a transformar.
    procedure xTog_vect( var g, x: TDAOfNreal; kPrimerSerie, kPaso: integer);
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

    // calculas Y= A X + B R sorteando
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

    // Escala la matriz Reductora y Calcula las matrices necesarias
    // para la transformación de Ampliación (inversa de la reductora)
    procedure Calcular_Matrices_Ampliacion;
  end;

//Retorna un arreglo de tipo TDAOf_ddp_VectDeMuestras de tamaño n y con todos sus
//elementos en NIL
function createNilTMatOf_ddp_VectDeMuestras(filas, columnas: integer):
  TMatOf_ddp_VectDeMuestras;
procedure freeTMatOf_ddp_VectDeMuestras(var matriz: TMatOf_ddp_VectDeMuestras);

implementation


{$IFDEF GRUPOS_POLARES}
constructor TGruposPolares.Create_vacio;
begin
  inherited Create;
  setlength( grupos, 0 );
  beta:= 1;
end;

constructor TGruposPolares.Create_ReadFromTextFile(
 var f: textFile;
 var cnt_linea: integer;
 var ultimalinealeida: string;
 var flg_ultimalineausada: boolean );
var
  NGruposPOlares: integer;
  kgrupo: Integer;
  NSeriesDelGrupo: Integer;
  kSerie: integer;
  r: string;

  procedure readln(var f: textfile; var s: string);
  begin
    system.readln(f, s);
    Inc(cnt_linea);
  end;
begin
  inherited Create;
    flg_ultimaLineaUsada:= true;
    setlength( Grupos, 0 );
    readln( f, r );
    if ( pos( 'Grupos Polares', r ) > 0 ) then
    begin
      readln( f, r );
      beta:= nextFloat( r );

    NGruposPolares:= nextInt( r );
    setlength( Grupos, NGruposPolares );
    for kgrupo:= 0 to NGruposPolares-1 do
    begin
      readln( f, r );
      NSeriesDelGrupo:= nextInt( r );
      setlength( Grupos[kGrupo], NSeriesDelGrupo );
      for kSerie:= 0 to NSeriesDelGrupo-1 do
         Grupos[kGrupo][kSerie]:= NextInt( r );
    end;
    readln( f , r );
    end
    else
    begin
     flg_ultimalineausada:= false;
    end;
    ultimalinealeida:= r;
end;

procedure TGruposPolares.WriteToTextFile( var f: textfile );

var
  kGrupo, kSerie: integer;
begin
  system.writeln( f, IntToStr( length( Grupos )) ,#9,'// Grupos Polares' );
  system.writeln( f, beta );
  for kgrupo:= 0 to high( grupos ) do
  begin
    system.write( f, IntToStr( length( Grupos[kGrupo] ) ) );
    for kSerie:= 0 to high( Grupos[kGrupo] ) do
       system.write( f, #9, IntToStr( Grupos[kGrupo][kSerie] ));
    system.writeln( f );
  end;
  system.writeln(f );
end;

constructor TGruposPolares.Create_ReadFromBinFile( var f: file );
var
 NGrupos, NSeriesDelGrupo: integer;
 kGrupo, kSerie: integer;
begin
  inherited Create;
  blockread( f, beta, SizeOf( beta ) );
  blockread( f, NGrupos, SizeOf( NGrupos ) );
  setlength( grupos, NGrupos );
  for kGrupo:= 0 to high( grupos ) do
  begin
    blockread( f, NSeriesDelGrupo, SizeOf( NSeriesDelGrupo ) );
    for kSerie:= 0 to high( grupos[kGrupo] ) do
      blockread( f, grupos[kGrupo, kSerie], sizeOf(NInt ) );
  end;
end;

procedure TGruposPolares.WriteToBinFile( var f: file );
var
 NGrupos, NSeriesDelGrupo: integer;
 kGrupo, kSerie: integer;
begin
  blockwrite( f, beta, SizeOf( beta ));
  NGrupos:= length( grupos );
  blockwrite( f, NGrupos, SizeOf( NGrupos ) );
  for kGrupo:= 0 to high( grupos ) do
  begin
    NSeriesDelGrupo:= length( grupos[ kGrupo ] );
    blockwrite( f, NSeriesDelGrupo, SizeOf( NSeriesDelGrupo ) );
    for kSerie:= 0 to high( grupos[kGrupo] ) do
      blockwrite( f, grupos[kGrupo, kSerie], sizeOf(NInt ) );
  end;
end;

procedure TGruposPolares.Free;
begin
  setlength( grupos, 0 );
  inherited Free;
end;

{$ENDIF}

constructor TSeriesDeDatos.CreateFromArchi(archi: string);
var
  f: TextFile;
  r, serie: string;
  kserie, kpunto, k: integer;
  cnt_linea: integer;

  flg_GruposPolares: boolean;

  procedure readln(var f: textfile; var s: string);
  begin
    system.readln(f, s);
    Inc(cnt_linea);
  end;

begin
  cnt_linea := 0;

  try

    inherited Create;
    self.archi := archi;
    assignfile(f, archi);
  {$I-}
    reset(f);
  {$I+}
    if ioresult <> 0 then
      raise Exception.Create('No puedo abrir el archivo: ' + archi);
    uauxiliares.setSeparadoresGlobales;

    readln(f, r);
    if pos('VERSION_FORMATO_SERIES', r) <> 0 then
    begin
      nextpal(r);
      version := nextInt(r);
    end
    else
      version := 0;

    (* leemos los parámetros globales *)
    if (version > 0) then
    begin
      readln(f, r); // cantidad de series a tratar
      NSeries := nextInt(r);
    end
    else
      NSeries := nextInt(r);

    readln(f, r);

    PM_Anio := nextInt(r);
    PM_Mes := nextInt(r);
    PM_Dia := nextInt(r);
    PM_Hora := nextInt(r);
    PM_Minuto := nextInt(r);
    PM_Segundo := nextInt(r);
    readln(f, r);
    PeriodoDeMuestreo_horas := nextFloat(r);


    readln(f, r);
    NPuntos := nextInt(r);    // cantidad de puntos totales por serie
    readln(f, r);
    NPPorCiclo := nextInt(r); // cantidad de puntos en un ciclo



    setlength(self.tipo_serie, NSeries);
    if (version > 0) then
    begin
      readln(f, r);
      for kserie := 1 to NSeries do
      begin
        if r[kserie] = 'x' then
          tipo_serie[kserie - 1] := SALIDA
        else
          tipo_serie[kserie - 1] := ENTRADA;
      end;
    end
    else
    begin
      for kserie := 1 to NSeries - 1 do
        tipo_serie[kserie - 1] := SALIDA;
    end;

{$IFDEF GRUPOS_POLARES}
    flg_GruposPolares:= true;
    if ( version >= 2 ) then
    begin
      GruposPolares:= TGruposPolares.Create_ReadFromTextFile( f , cnt_linea, r, flg_GruposPolares );
    end
    else
      GruposPolares:= TGruposPolares.Create_vacio;

    if not flg_GruposPolares then // si no usé la línea son las series
{$ENDIF}

    readln(f, r); // encabezado de las series

    nombresSeries := TStringList.Create;
    for kserie := 0 to NSeries - 1 do
    begin
      serie := NextPal(r);
      nombresSeries.Add(serie);
    end;

    // Creamos e inicializamos el soporte para las series
    setlength(series, NSeries);
    for kserie := 1 to NSeries do
      series[kserie - 1] := TVectR.Create_Init(NPuntos);

    // Leemos los datos en las series $
    for kpunto := 1 to NPuntos do
    begin
      Read(f, k);
      for kserie := 1 to nSeries do
        Read(f, series[kserie - 1].pv[kpunto]);
      readln(f, r);
    end;
    uauxiliares.setSeparadoresLocales;
    CloseFile(f);
  except
    raise Exception.Create('Error leyendo línea: ' + IntToStr(cnt_linea));
  end;
end;


procedure TSeriesDeDatos.WriteToArchi(archi: string);
var
  f: TextFile;
  r: string;
  kserie, kpunto: integer;
begin
  self.archi := archi;
  assignfile(f, archi);
  {$I-}
  rewrite(f);
  {$I+}
  if ioresult <> 0 then
    raise Exception.Create('No puedo abrir el archivo: ' + archi);
  uauxiliares.setSeparadoresGlobales;

  system.writeln(f, 'VERSION_FORMATO_SERIES:', #9, VERSION_FORMATO_SERIES);

  (* leemos los parámetros globales *)
  system.writeln(f, NSeries); // cantidad de series a tratar

  r := IntToStr(PM_Anio) + #9 + IntToStr(PM_Mes) + #9 + IntToStr(
    PM_Dia) + #9 + IntToStr(PM_Hora) + #9 + IntToStr(PM_Minuto) + #9 +
    IntToStr(PM_Segundo);
  system.writeln(f, r);

  writeln(f, PeriodoDeMuestreo_horas);


  system.writeln(f, NPuntos);    // cantidad de puntos totales por serie
  system.writeln(f, NPPorCiclo); // cantidad de puntos en un ciclo

  r := '';
  for kserie := 1 to NSeries do
  begin
    if tipo_serie[kserie - 1] = SALIDA then
      r := r + 'x'
    else
      r := r + 'y';
  end;
  system.writeln(f, r);

  {$IFDEF GRUPO_POLARES}
// Grupos Polares
  GruposPolares.WriteToTextFile( f );
  {$ENDIF}

  r := '';
  for kserie := 0 to NSeries - 1 do
  begin
    if kserie > 0 then
      r := r + #9;
    r := r + nombresSeries[kserie];
  end;
  system.writeln(f, r); // encabezado de las series


  // escribimos los datos de las series
  for kpunto := 1 to NPuntos do
  begin
    system.Write(f, kpunto);
    for kserie := 1 to nSeries do
      system.Write(f, #9, series[kserie - 1].pv[kpunto]);
    system.writeln(f);
  end;
  uauxiliares.setSeparadoresLocales;
  CloseFile(f);
end;



function TSeriesDeDatos.CreateCloneHeadInfo: TSeriesDeDatos;
var
  res: TSeriesDeDatos;
  k: integer;

begin
  res:= TSeriesDeDatos.Create;
  res.version:= version;
  res.archi:= 'clonada_de_'+archi;
  res.NSeries:= NSeries;
  res.PM_Anio:= PM_Anio;
  res.PM_Mes:= PM_Mes;
  res.PM_Dia:= PM_Dia;
  res.PM_Hora:= PM_Hora;
  res.PM_Minuto:= PM_Minuto;
  res.PM_segundo:= PM_segundo;
  res.PeriodoDeMuestreo_horas:= PeriodoDeMuestreo_horas;
  res.NPuntos:= NPuntos;
  res.NPPorCiclo:= NPPorCiclo;
  res.nombresSeries:=TStringList.Create;
  for k:= 0 to nombresSeries.Count-1 do res.NombresSeries.add( nombresSeries[k] );
  setlength( res.series, NSeries );
  setlength( res.tipo_serie, NSeries );
  for k:= 0 to high( tipo_serie ) do
    res.tipo_serie[k]:= tipo_serie[k];
  result:= res;
end;

function TSeriesDeDatos.Resampling( Nuevo_PeriodoDeMuestreo_horas: NReal ): TSeriesDeDatos;
var
  res: TSeriesDeDatos;
  k, j : integer;
  aSerie, bSerie: TVectR;
  flg_SubMuestreo: boolean;
  kr1, kr2: NReal;
  fTs: NReal;
  aval: NReal;

begin
  fTs:= Nuevo_PeriodoDeMuestreo_horas /PeriodoDeMuestreo_horas;
  flg_Submuestreo:= fTs > 1.0;
  res:= CreateCloneHeadInfo;
  res.PeriodoDeMuestreo_horas:= Nuevo_PeriodoDeMuestreo_horas;
  res.NPuntos:= trunc( (NPuntos-1) / fTs ) ;
  for k:= 0 to high( res.series ) do
  begin
    aSerie:= TVectR.Create_Init( res.NPuntos );
    res.series[k]:= aSerie;
    bSerie:= series[k];
    if flg_SubMuestreo then
    begin
      aSerie.pon_e(1, bSerie.e(1) );
      for j:= 2 to aSerie.n do
      begin
        kr1:= (j-2)* fTs +1;
        kr2:= kr1 + fTs;
        aval:= bSerie.integral( kr1, kr2 );
        aSerie.pon_e( j, aval/fTs );
      end
    end
    else
      for j:= 1 to aSerie.n do
      begin
        kr1:= (j-1)* fTs + 1;
        aval:= bSerie.interpol( kr1 );
        aSerie.pon_e( j, aval );
      end
  end;
  result:= res;
end;



procedure TSeriesDeDatos.WriteCOVARS( archi: string );
var
  f: TextFile;
  r: string;
  kserie, kpunto: integer;
  kPaso: integer;
  desv: TVectR;
  cxx: TVectR;
  aSerie: TVectR;
  a: NReal;
  kRet, jSerie: integer;
  xs1, xs2: NReal;
  jvar: integer;
begin
  self.archi := archi;
  assignfile(f, archi);
  {$I-}
  rewrite(f);
  {$I+}
  if ioresult <> 0 then
    raise Exception.Create('No puedo abrir el archivo: ' + archi);
  uauxiliares.setSeparadoresGlobales;

  system.writeln(f, 'VERSION_FORMATO_SERIES:', #9, VERSION_FORMATO_SERIES);

  system.writeln(f, NSeries); // cantidad de series a tratar

  r := IntToStr(PM_Anio) + #9 + IntToStr(PM_Mes) + #9 + IntToStr(
    PM_Dia) + #9 + IntToStr(PM_Hora) + #9 + IntToStr(PM_Minuto) + #9 +
    IntToStr(PM_Segundo);
  system.writeln(f, r);

  writeln(f, PeriodoDeMuestreo_horas);


  system.writeln(f, NPuntos);    // cantidad de puntos totales por serie
  system.writeln(f, NPPorCiclo); // cantidad de puntos en un ciclo


  // escribimos encabezados
  for kserie := 0 to NSeries - 1 do
  for jserie:= kserie to NSeries - 1 do
    system.write( f, #9, nombresSeries[kserie]+'(x)'+nombresSeries[jserie]);
  system.writeln(f, ''); // encabezado de las series

  desv:= TVectR.Create_init( NSeries );
  cxx:= TVectR.Create_Init( (NSeries * (NSeries +1)) div 2 );

  // Primero calculamos los desvíos
  for kSerie:= 1 to NSeries do
  begin
   aSerie:= series[kSerie -1 ];
   desv.pon_e( kSerie,  sqrt(aSerie.ne2/aSerie.n));
  end;

  // Ahora para cada retardo calculamos los coeficientes de covarianza
  for kRet:= 0 to NPuntos - 1 do
  begin
   cxx.Ceros;
   write( f, kRet );
   for kPunto:= kRet+1 to NPuntos do
   begin
      jvar:= 1;
      for kSerie:= 1 to NSeries do
        for jSerie:= kSerie to NSeries do
        begin
         xs1:= Series[kSerie-1].e( kPunto-kRet )/desv.e(kSerie);
         xs2:= Series[jSerie-1].e( kPunto )/desv.e(jSerie);
         cxx.acum_e( jvar, xs1 * xs2 );
         inc( jvar );
        end;
   end;
   cxx.PorReal( 1/ ( NPuntos - kRet ) );
   jvar:= 1;
   for kSerie:= 1 to NSeries do
     for jSerie:= kSerie to NSeries do
     begin
        write( f, #9, cxx.e( jvar ):12:4 );
        inc( jvar );
     end;
   system.writeln( f );
  end;
  uauxiliares.setSeparadoresLocales;
  CloseFile(f);
  desv.Free;
  cxx.Free;
end;


procedure TSeriesDeDatos.Free;
var
  i: integer;
begin
  if nombresSeries <> nil then
    nombresSeries.Free;
  if series <> nil then
  begin
    for i := 0 to high(series) do
      series[i].Free;
    setlength(series, 0);
  end;
  inherited Free;
end;

procedure TModeloSintetizadorCEGH.Calcular_Matrices_Ampliacion;
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

end;


constructor TModeloSintetizadorCEGH.CreateFromArchi(nombreArchivo: string);
var
  f: TextFile;
  linea: string;
  num: NReal;
  nPuntosPorFuncionDeformante, nFuentesRBlancoGaussiano: integer;
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
    {$IFDEF FPC}
      fechaArchiBin := fileDateToDateTime(FileAge(archi_bin));
      fechaArchivoTexto := fileDateToDateTime(FileAge(nombreArchivo));
    {$ELSE}
      FileAge(archi_bin, fechaArchiBin);
      FileAge(nombreArchivo, fechaArchivoTexto);
    {$ENDIF}
     if (fechaArchiBin > fechaArchivoTexto) and
        (fechaArchiBin > fecha_obligar_cambio_bin) then
      begin
        CreateFromArchi_bin(archi_bin);
        exit;
      end;
    end;
  end;

  gaussiana := nil;
  A_cte := nil;
  B_cte := nil;
  mCA := nil;
  mCB := nil;
  if FileExists(nombreArchivo) then
  begin
    try
      try
        gaussiana := Tf_ddp_GaussianaNormal.Create(nil, 31);

        AssignFile(f, nombreArchivo);
        Reset(f);
        uauxiliares.setSeparadoresGlobales;

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
        nPuntosPorFuncionDeformante := NextInt(linea);

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

            aVect := TVectR.Create_Init(nPuntosPorFuncionDeformante);
            for k := 1 to nPuntosPorFuncionDeformante do
              aVect.pon_e(k, NextFloat(linea));
            funcionesDeformantesI[j] :=
              Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(aVect, nil, 0);
          end;
        end;//Termino con las series

        {$IFDEF GRUPOS_POLARES}
        readln(f, linea ); // liena en blanco
        if version >= 2 then
        begin
          cnt_linea:= 0;
          GruposPolares:= TGruposPolares.Create_ReadFromTextFile(
            f, cnt_linea, linea, flg_lineausada );
        end
        else
          GruposPolares:= TGruposPolares.Create_vacio;

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
    raise Exception.Create('Datos sintetizador, NO Encuentro el archivo:' +  nombreArchivo);
end;


constructor TModeloSintetizadorCEGH.CreateFromArchi_bin(nombreArchivo: string);
var
  f: file of byte;
  linea: ansistring;
  //  num: NReal;
  nPuntosPorFuncionDeformante: integer;
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
        bri(nPuntosPorFuncionDeformante);

        //Leo la duración del paso de sorteo EN HORAS
        bri(durPasoDeSorteoEnHoras);

        setlength(buffint, nPuntosPorFuncionDeformante);

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
            blockread(f, buffInt[0], sizeOf(buffInt[0]) * nPuntosPorFuncionDeformante);
            aVect := TVectR.Create_Init(nPuntosPorFuncionDeformante);
            for jh := 0 to high(buffint) do
              aVect.pv[jh + 1] := buffint[jh] * alfa + beta;

            funcionesDeformantesI[j] :=
              Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(aVect, nil, 0);
          end;
        end;//Termino con las series


        {$IFDEF GRUPOS_POLARES}
        if ( version >= 2 ) then
        begin
          GruposPolares:= TGruposPolares.Create_ReadFromBinFile( f );
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


constructor TModeloSintetizadorCEGH.Create(NSS: integer;
  NombresDeBornes_Publicados: TStringList; NOrdenDelFiltro, NFD, NPFD: integer;
  durPasoDeSorteoEnHoras: integer; nVERed: integer);
var
  i, j: integer;
  A_nc: integer;
begin
  version := VERSION_FORMATO_CEGH;

  {$IFDEF GRUPOS_POLARES}
  GruposPolares:= TGruposPolares.Create_vacio;
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

  setlength(funcionesDeformantes, NSS);
  for i := 0 to NSS - 1 do
  begin
    setlength(funcionesDeformantes[i], NFD);
    for j := 0 to NFD - 1 do
      funcionesDeformantes[i][j] :=
        Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(TVectR.Create_Init(NPFD), nil, 0);
  end;
end;


constructor TModeloSintetizadorCEGH.Create_MultiCiclo(NSS: integer;
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

procedure TModeloSintetizadorCEGH.WriteToArchi(nombreArchivo: string;
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
  if version>= 2 then
  begin
    GruposPolares.WriteToTextFile( f );
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
      writeFiltro(f, mcA[j], mcB[j]);
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



procedure TModeloSintetizadorCEGH.WriteToArchi_bin(nombreArchivo: string);

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
   GruposPolares.WriteToBinFile( f );
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

function TModeloSintetizadorCEGH.xTog(x: NReal; kSerie, kPaso: integer): NReal;
var
  u: NReal;
  p: Tf_ddp_VectDeMuestras;
begin
  p := funcionesDeformantes[kSerie - 1][kPaso - 1];
  u := p.area_t(x);
//  Result := u;
  Result := Gaussiana.t_area(u);
end;


function TModeloSintetizadorCEGH.gTox(g: NReal; kSerie, kPaso: integer): NReal;
var
  u: NReal;
  p: Tf_ddp_VectDeMuestras;
begin
  p := funcionesDeformantes[kSerie - 1][kPaso - 1];
  u := Gaussiana.area_t(g);
  Result := p.t_area(u);
end;



{$IFDEF GRUPOS_POLARES}
// trasforma del espacio real al gaussiano
procedure TModeloSintetizadorCEGH.xTog_vect( var g, x: TDAOfNreal; kPrimerSerie, kPaso: integer);
var
 kSerie: integer;
 kGrupo: integer;
 tocadas: TDAOfBoolean;
 ro_x, fi_x, ro_g, fi_g: NReal;
 cnt_tocadas: integer;
 aGrupo: TDAOfNInt;
 iSerie: integer;

begin
  if length( GruposPolares.Grupos ) > 0 then
  begin
    setlength( tocadas, A_nf );
    for kSerie:= 0 to high( tocadas ) do tocadas[kSerie]:= false;
    cnt_tocadas:= 0;
    for kGrupo:= 0 to high( GruposPolares.Grupos ) do
    begin
      aGrupo:= GruposPolares.Grupos[ kGrupo ];
      ro_x:= 0;

      for iSerie:= 0 to high( aGrupo ) do
        ro_x:= ro_x + sqr( x[ kPrimerSerie + (aGrupo[ iSerie] - 1) ] );
      ro_x:= sqrt( ro_x );
      ro_x:= power( ro_x, GruposPolares.beta );

      for iSerie:= 0 to high( aGrupo ) do
      begin
        kSerie:= aGrupo[ iSerie] - 1;
        g[ kSerie ]:= xTog_mono(  ro_x * x[ kPrimerSerie+ kSerie], kSerie+1, kPaso  );
        tocadas[kSerie]:= true;
        inc( cnt_tocadas );
      end;
    end;

    if cnt_tocadas < length( tocadas ) then
    begin
      for kSerie:= 0 to high( tocadas ) do
      begin
         if not tocadas[ kSerie ] then
         begin
           g[ kPrimerSerie+kSerie ]:= xTog_mono( x[ kPrimerSerie+ kSerie], kSerie+1, kPaso );
         end;
      end;
    end;

  end
  else
  begin
    for kSerie:= 0 to A_nf-1 do
      g[ kPrimerSerie+kSerie ]:= xTog_mono( x[ kPrimerSerie+ kSerie], kSerie+1, kPaso );
  end;

end;

 // transforma del espacio gaussiano al real
procedure TModeloSintetizadorCEGH.gTox_vect(var x, g: TDAOfNreal; kPrimerSerie, kPaso: integer);
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
  if length( GruposPolares.Grupos ) > 0 then
  begin
    setlength( tocadas, A_nf );
    setlength( y, A_nf );
    for kSerie:= 0 to high( tocadas ) do
    begin
      tocadas[kSerie]:= false;
      y[kSerie]:= gToX_mono( g[kPrimerSerie+kSerie], kSerie, kPaso );
    end;
    cnt_tocadas:= 0;

    for kGrupo:= 0 to high( GruposPolares.Grupos ) do
    begin
      aGrupo:= GruposPolares.Grupos[ kGrupo ];
      ro_g:= 0;
      for iSerie:= 0 to high( aGrupo ) do
       ro_g:= ro_g + sqr( y[ kPrimerSerie+ aGrupo[iSerie]-1 ] );
      ro_g:= 1/ power( ro_g, 1.0/3.0 );

      for iSerie:= 0 to high( aGrupo ) do
       ro_g:= ro_g + sqr( y[ kPrimerSerie+ aGrupo[iSerie]-1 ] );


      ro_x:= gTox_mono( ro_g, aGrupos[0], kPaso );
      fi_x:= gTox_mono( fi_g, aGrupos[1], kPaso );


      vx:= ro_x* cos( fi_g );
      vy:= ro_x* sin( fi_g );

      x[ kPrimerSerie+ i1 ]:= vx;
      x[ kPrimerSerie+ i2 ]:= vy;

      tocadas[ i1 ]:= true;
      tocadas[ i2 ]:= true;
      inc( cnt_tocadas, 2 );
    end;

    if cnt_tocadas < length( tocadas ) then
    begin
      for kSerie:= 0 to hign( tocadas ) do
      begin
         if not tocadas[ kSerie ] then
         begin
           x[ kPrimerSerie+kSerie ]:= gTox_mono( g[ kPrimerSerie+ kSerie], kSerie+1, kPaso );
         end;
      end;
    end;

  end
  else
  begin
    for kSerie:= 1 to A_nf do
      x[ kPrimerSerie+kSerie-1]:= gTox_mono( g[ kPrimerSerie+kSerie-1],  kSerie, kPaso );
  end;
end;


{$ENDIF}

// crea un vector de estado según la cantidad de series y el orden del filtro
function TModeloSintetizadorCEGH.CrearVector_EstadoX: TVectR;
begin
  if A_cte <> nil then
    Result := TVectR.Create_Init(A_cte.nc)
  else
    Result := TVectR.Create_init(mcA[0].nc);
end;

// Crea un vector del tamaño necesario para alojar las salidas
function TModeloSintetizadorCEGH.CrearVector_Salida: TVectR;
begin
  if A_cte <> nil then
    Result := TVectR.Create_Init(A_cte.nf)
  else
    Result := TVectR.Create_init(mcA[0].nf);
end;

// crea un vector para alamcenar los valores de las fuentes de ruido blanco
function TModeloSintetizadorCEGH.CrearVector_RBG: TVectR;
begin
  if B_cte <> nil then
    Result := TVectR.Create_Init(B_cte.nc)
  else
    Result := TVectR.Create_Init(mcB[0].nc);
end;

// rellena el vector con sorteos independientes con distribución normal standar
procedure TModeloSintetizadorCEGH.SortearValores(var rbg: TVectR);
var
  k: integer;
begin
  for k := 1 to rbg.n do
    rbg.pv[k] := gaussiana.rnd;
end;



// calculas Y= A X + B R
procedure TModeloSintetizadorCEGH.CalcularProximasSalidas(var SalidaY: TVectR;
  EstadoX: TVectR; entradaRBG: TVectR; kSelector: integer);
var
  ksal: integer;
begin
  if A_cte <> nil then
    for ksal := 1 to SalidaY.n do
      SalidaY.pv[ksal] := A_cte.Fila(ksal).pev(EstadoX) +
        B_cte.Fila(ksal).pev(entradaRBG)
  else
    for ksal := 1 to SalidaY.n do
      SalidaY.pv[ksal] := mcA[kSelector].Fila(ksal).pev(EstadoX) +
        mcB[kSelector].Fila(ksal).pev(entradaRBG);
end;

function TModeloSintetizadorCEGH.CalcularSalida(kSal: integer;
  const pEstadoX, pEntradaRBG: PNReal; kSelector: integer): NReal;
begin
  if A_cte <> nil then
    Result := A_cte.Fila(ksal).pev(pEstadoX) + B_Cte.Fila(ksal).pev(pEntradaRBG)
  else
    Result := mcA[kSelector].Fila(ksal).pev(pEstadoX) +
      mcB[kSelector].Fila(ksal).pev(pEntradaRBG);
end;

function TModeloSintetizadorCEGH.CalcularSalidaConSesgo(kSal: integer;
  const pEstadoX, pEntradaRBG: PNReal; sesgoVM, atenuacion: NReal;
  kSelector: integer): NReal;
begin
  if A_cte <> nil then
    Result := A_cte.Fila(ksal).pev(pEstadoX) + atenuacion *
      B_cte.Fila(ksal).pev(pEntradaRBG) + sesgoVM
  else
    Result := mcA[kSelector].Fila(ksal).pev(pEstadoX) + atenuacion *
      mcB[kSelector].Fila(ksal).pev(pEntradaRBG) + sesgoVM;

end;

// realiza los desplazamientos en X y copia Y en los casilleros que corresponde
procedure TModeloSintetizadorCEGH.EvolucionarEstado_(var EstadoX: TVectR;
  SalidaY: TVectR);
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
function TModeloSintetizadorCEGH.CalcOrdenDelFiltro: integer;
begin
  if A_cte <> nil then
    Result := A_cte.nc div A_cte.nf
  else
    Result := mcA[0].nc div mcA[0].nf;
end;



procedure TModeloSintetizadorCEGH.InicializarDesdeDatosReales(X: TVectR;
  serieHistorica: TSeriesDeDatos; kPaso: integer; desp_selector0: integer);
var
  kSerie: integer;
  jRetardo: integer;
  ipaso: integer;
  OrdenDelFiltro: integer;
begin
  OrdenDelFiltro := CalcOrdenDelFiltro;
  for kSerie := 0 to serieHistorica.NSeries - 1 do
  begin
    for jRetardo := 1 to OrdenDelFiltro do
    begin
      ipaso := kPaso - jRetardo + 1;
      if ipaso > 0 then
        x.pv[(jRetardo - 1) * OrdenDelFiltro + kSerie + 1] :=
          xtog(serieHistorica.series[kserie].pv[ipaso], kSerie + 1,
          ((ipaso - 1 - desp_selector0) mod serieHistorica.NPPorCiclo) + 1)
      else
        x.pv[(jRetardo - 1) * OrdenDelFiltro + kSerie + 1] := 0;
    end;
  end;
end;



function TModeloSintetizadorCEGH.kSelectorDeformador(fecha: TFecha): integer;
var
  res: integer;
begin
  case durPasoDeSorteoEnHoras of
    730: res := fecha.mes - 1;
    672: res := (fecha.semana52 - 1) div 4; // se agrega paso de tiempo de 4 semanas
    336: res := (fecha.semana52 - 1) div 2; //se agrega paso de tiempo de 2 semanas
    168: res := fecha.semana52 - 1;
    24: res := min(fecha.dia - 1, 364);
    1: res := fecha.horasDesdeElInicioDelAnio;
    else
      raise Exception.Create(rs_kSelectorDeformador + IntToStr(durPasoDeSorteoEnHoras));
  end;
  Result := res mod nPuntosPorPeriodo;
end;



function TModeloSintetizadorCEGH.Dim_X: integer;
begin
  Result := A_nc;
end;

function TModeloSintetizadorCEGH.Dim_XRed: integer;
begin
 {$IFDEF EXPANSION_RUIDA}
  if MRed <> nil then
    Result := MRed.nf
  else
    Result := 0;
 {$ELSE}
  Result := 0;
 {$ENDIF}
end;

function TModeloSintetizadorCEGH.A_nc: integer;
begin
  if A_cte <> nil then
    Result := A_cte.nc
  else
    Result := mcA[0].nc;
end;

function TModeloSintetizadorCEGH.A_nf: integer;
begin
  if A_cte <> nil then
    Result := A_cte.nf
  else
    Result := mcA[0].nf;
end;

function TModeloSintetizadorCEGH.B_nc: integer;
begin
  if B_cte <> nil then
    Result := B_cte.nc
  else
    Result := mcB[0].nc;
end;

function TModeloSintetizadorCEGH.B_nf: integer;
begin
  if B_cte <> nil then
    Result := B_cte.nf
  else
    Result := mcB[0].nf;
end;


procedure TModeloSintetizadorCEGH.Free;
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

end.
