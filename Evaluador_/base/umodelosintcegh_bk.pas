unit umodelosintcegh;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

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
{$IFDEF FPC}
  //  FileUtil,
{$ENDIF}
  xMatDefs, Classes, matreal, SysUtils, uAuxiliares, fddp, ufechas, Math;

resourcestring
  exKSelectorDeformador = 'kSelectorDeformador, no especificado para dh:';

type

  TDAOf_ddp_VectDeMuestras = array of Tf_ddp_VectDeMuestras;
  TMatOf_ddp_VectDeMuestras = array of TDAOf_ddp_VectDeMuestras;
  TDAOfVectR = array of TVectR;


const
  VERSION_FORMATO_SERIES = 1;


type
  TIPO_SERIE = (SALIDA, ENTRADA);

  (* Clase para soporte de las series de datos *)
  TSeriesDeDatos = class
  public
    archi:      string;
    NSeries:    integer;
    // Información de la primera muedtra (PM)
    PM_Anio, PM_Mes, PM_Dia, PM_Hora, PM_Minuto, PM_segundo: integer;
    PeriodoDeMuestreo_horas: NReal;
    NPuntos, NPPorCiclo: integer;
    nombresSeries: TStringList;
    series:     TDAOfVectR;
    tipo_serie: array of TIPO_SERIE;
    constructor CreateFromArchi(archi: string);
    procedure WriteToArchi(archi: string);
    procedure Free;
  end;



  // Clase para leer archivos resultados de AnalisisSerial
  TModeloSintetizadorCEGH = class
  public
    A, B:  TMatR; // Matrices del Filtro Lineal.
    mcA, mcB: TDAOfMatR;

    MRed:     TMatR; // Matriz Reductora de estado. Xred = R X
    MRed_aux: TMatR; // usado en caso de tener una forma auxiliar de reducción
    MAmp:    TMatR; // Matriz Amplificadora del estdo,

    //Número de variables de estado Para Optimización (o sea pueden ser reducidas)
    nVE:   integer;
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

    //Es la cantidad de salidas que presenta la fuente a los actores
    //Es igual a NombresDeBornes_Publicados.Count
    nBornesSalida: integer;
    nRetardos:     integer; // cantidad de pasos de tiempo de retardo
    // largo de cada vector descriptor de una función deformante de un borne
    nPuntosPorPeriodo: integer;

    durPasoDeSorteoEnHoras:     integer;
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

    // crea un vector de estado según la cantidad de series y el orden del filtro
    function CrearVector_EstadoX: TVectR;
    // Crea un vector del tamaño necesario para alojar las salidas
    function CrearVector_Salida: TVectR;
    // crea un vector para alamcenar los valores de las fuentes de ruido blanco
    function CrearVector_RBG: TVectR;

    // rellena el vector con sorteos independientes con distribución normal standar
    procedure SortearValores(var rbg: TVectR);

    // calculas Y= A X + B R sorteadno
    procedure CalcularProximasSalidas(var SalidaY: TVectR; EstadoX: TVectR;
      entradaRBG: TVectR);
    function CalcularSalida(kSal: integer;
      const pEstadoX, pEntradaRBG: PNReal): NReal;
    function CalcularSalidaConSesgo(kSal: integer;
      const pEstadoX, pEntradaRBG: PNReal; sesgoVM, atenuacion: NReal): NReal;

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

  end;

 //Retorna un arreglo de tipo TDAOf_ddp_VectDeMuestras de tamaño n y con todos sus
 //elementos en NIL
function createNilTMatOf_ddp_VectDeMuestras(filas, columnas: integer):
  TMatOf_ddp_VectDeMuestras;
procedure freeTMatOf_ddp_VectDeMuestras(var matriz: TMatOf_ddp_VectDeMuestras);

implementation

constructor TSeriesDeDatos.CreateFromArchi(archi: string);
var
  f: TextFile;
  r, serie: string;
  kserie, kpunto, k: integer;
  version: integer;

begin

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
    system.readln(f, NSeries) // cantidad de series a tratar
  else
    NSeries := nextInt(r);

  system.readln(f, r);

  PM_Anio    := nextInt(r);
  PM_Mes     := nextInt(r);
  PM_Dia     := nextInt(r);
  PM_Hora    := nextInt(r);
  PM_Minuto  := nextInt(r);
  PM_Segundo := nextInt(r);
  readln(f, r);
  PeriodoDeMuestreo_horas := nextFloat(r);

  system.readln(f, NPuntos);    // cantidad de puntos totales por serie
  system.readln(f, NPPorCiclo); // cantidad de puntos en un ciclo

  setlength(self.tipo_serie, NSeries);
  if (version > 0) then
  begin
    system.readln(f, r);
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

  system.readln(f, r); // encabezado de las series
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
    system.readln(f);
  end;
  uauxiliares.setSeparadoresLocales;
  CloseFile(f);
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

  r := '';
  for kserie := 0 to NSeries - 1 do
  begin
    if kserie > 0 then
      r := r + #9;
    r   := r + nombresSeries[kserie];
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

constructor TModeloSintetizadorCEGH.CreateFromArchi(nombreArchivo: string);
var
  f:      TextFile;
  linea:  string;
  num:    NReal;
  nPuntosPorFuncionDeformante, nFuentesRBlancoGaussiano: integer;
  i, j, k: integer;
  ne2_FilaR: NReal;
  funcionesDeformantesI: TDAOf_ddp_VectDeMuestras;
  aVect:  TVectR;
  nColsA: integer;
  archi_bin: string;
  buscando: boolean;
  fechaArchiBin, fechaArchivoTexto: TDateTime;
begin

  if FileExists(nombreArchivo) { *Converted from FileExists*  } then
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
      fechaArchiBin     := fileDateToDateTime(FileAge(archi_bin));
      fechaArchivoTexto := fileDateToDateTime(FileAge(nombreArchivo));
    {$ELSE}
      FileAge(archi_bin, fechaArchiBin);
      FileAge(nombreArchivo, fechaArchivoTexto);
    {$ENDIF}
      // palfaro@20101207_1731
      // La función FileAge con un parametro está deprecated, lo cambio para
      // sacar los warnings
      if fechaArchiBin > fechaArchivoTexto then
      begin
        CreateFromArchi_bin(archi_bin);
        exit;
      end;
    end;
  end;
  gaussiana := nil;
  A := nil;
  B := nil;

  if FileExists(nombreArchivo) { *Converted from FileExists*  } then
  begin
    try
      try
        gaussiana := Tf_ddp_GaussianaNormal.Create(nil, 31);

        AssignFile(f, nombreArchivo);
        Reset(f);
        uauxiliares.setSeparadoresGlobales;

        NombresDeBornes_Publicados := TStringList.Create;
        readln(f, linea);

        //Leo la cantidad de series de salida
        readln(f, linea);
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
              Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(aVect, 0);
          end;
        end;//Termino con las series
        linea := ProximaLineaNoVacia(f);

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
          linea  := ProximaLineaNoVacia(f);
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

        linea := ProximaLineaNoVacia(f);
        if not EOF(f) then
        begin
          //nVE
          NextPal(linea);
          nVE := NextInt(linea);
          SetLength(nDiscsVsE, nVE);
          SetLength(nombreVarE, nVE);
          MRed := TMatR.Create_Init(nVe, nBornesSalida);
          // Creamos la matriz de probabilidades
          setlength(ProbsVsE, nVE);


          for i := 1 to nVE do
          begin
            readln(f, linea);
            //ndi
            NextPal(linea);
            nDiscsVsE[i - 1]  := NextInt(linea);
            //nombre de la var
            nombreVarE[i - 1] := NextPal(linea);
            for j := 1 to nBornesSalida do
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

// por ahora, supopngo que MRed tiene filas ortogonales
// y calculo MAmp para que MRed * MAmp = I
          MAmp:= TMatR.Create_Init( MRed.nc, MRed.nf);

          for i := 1 to MRed.nf do
          begin
            ne2_FilaR := MRed.Fila(i).ne2;
            if ne2_FilaR < AsumaCero then
              raise Exception.Create('Error de modelo CEGH, la fila: ' +
                IntToStr(i) + ' del redutor de estado tiene norma nula.');
            for j := 1 to MAmp.nf do
              MAmp.pon_e(j, i, MRed.e(i, j) / ne2_FilaR );
          end;

        end;

        MRed_aux   := nil;
        nVE_aux := 0;
        if not EOF(f) then
        begin
          linea := uauxiliares.ProximaLineaNoVacia(f);
          if linea = '<+Raux>' then
          begin
            linea   := uauxiliares.ProximaLineaNoVacia(f);
            nVE_aux := uauxiliares.NextIntParam(linea, 'nVE');
            MRed_aux   := TMatR.Create_Init(nVe_aux, nBornesSalida);

            for i := 1 to nVE_aux do
            begin
              linea := uauxiliares.ProximaLineaNoVacia(f);
              for j := 1 to nBornesSalida do
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
          MRed_aux   := nil;
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
        if A <> nil then
          A.Free;
        if B <> nil then
          B.Free;
        raise e;
      end
    end;
  end
  else
    raise Exception.Create('Datos sintetizador, NO Encuentro el archivo:' +
      nombreArchivo);
end;


constructor TModeloSintetizadorCEGH.CreateFromArchi_bin(nombreArchivo: string);
var
  f:      file of byte;
  linea:  ansistring;
  //  num: NReal;
  nPuntosPorFuncionDeformante, nFuentesRBlancoGaussiano: integer;
  i, j:   integer;
  ne2_FilaR: NReal;
  funcionesDeformantesI: TDAOf_ddp_VectDeMuestras;
  aVect:  TVectR;
  nColsA: integer;

  jh:      integer;
  alfa, beta: NReal;
  buffint: array of smallint;

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

begin
  gaussiana := nil;
  A := nil;
  B := nil;

  if FileExists(nombreArchivo) { *Converted from FileExists*  } then
  begin
    try
      try
        gaussiana := Tf_ddp_GaussianaNormal.Create(nil, 31);

        AssignFile(f, nombreArchivo);
        Reset(f);
        NombresDeBornes_Publicados := TStringList.Create;

        //Leo la cantidad de series de salida
        bri(nBornesSalida);

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
              Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(aVect, 0);
          end;
        end;//Termino con las series

        //Numero de Fuentes De Ruido Blanco Gaussiano
        bri(nFuentesRBlancoGaussiano);
        bri(NCOLSA); // asumo FiltroOrden1 si no me dicen nada.


        A := TMatR.Create_Init(nBornesSalida, nColsA);
        B := TMatR.Create_Init(nBornesSalida, nFuentesRBlancoGaussiano);

        nRetardos := nColsA div nBornesSalida;

        for i := 1 to nBornesSalida do
        begin
          blockRead(f, A.pm[i].pv[1], nColsA * SizeOf(NReal));
          blockRead(f, B.pm[i].pv[1], nFuentesRBlancoGaussiano * SizeOf(NReal));
        end;

        bri(nVE);


        SetLength(nDiscsVsE, nVE);
        SetLength(nombreVarE, nVE);
        MRed := TMatR.Create_Init(nVe, nBornesSalida);
        // Creamos la matriz de probabilidades
        setlength(ProbsVsE, nVE);

        if nVE > 0 then
          blockRead(f, nDiscsVsE[0], sizeOf(integer) * nVE);
        for i := 1 to nVE do
        begin
          //nombre de la var
          brs(linea);
          nombreVarE[i - 1] := string(linea);
          blockRead(f, MRed.pm[i].pv[1], nBornesSalida * sizeOf(NReal));

          // leemos las probabilidades asignadas
          setlength(ProbsVsE[i - 1], nDiscsVsE[i - 1]);
          blockRead(f, ProbsVsE[i - 1][0], nDiscsVsE[i - 1] * sizeOf(NReal));
        end;

        MAmp := TMatR.Create_Init( MRed.nc, MRed.nf);
        for i := 1 to MRed.nf do
        begin
          ne2_FilaR := MRed.Fila(i).ne2;
          if ne2_FilaR < AsumaCero then
            raise Exception.Create('Error de modelo CEGH, la fila: ' +
              IntToStr(i) + ' del redutor de estado tiene norma nula.');
          for j := 1 to MAmp.nf do
            MAmp.pon_e(j, i, MRed.e(i, j) / ne2_FilaR);
        end;

        if nVE_aux > 0 then
        begin
          MRed_aux := TMatR.Create_Init(nVe_aux, nBornesSalida);
          for i := 1 to nVE_aux do
            blockRead(f, MRed_aux.pm[i].pv[1], nBornesSalida * SizeOf(NReal));
        end
        else
        begin
          nVE_aux := 0;
          MRed_aux   := nil;
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
        if A <> nil then
          A.Free;
        if B <> nil then
          B.Free;
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

  A := nil;
  B := nil;

  nRetardos := NOrdenDelFiltro;

  // esto lo pongo a nil para que no jorobe
  mcA := nil;
  mcB := nil;

  MRed  := TMatR.Create_Init(nVERed, A_nc);
  MAmp  := TMatR.Create_init(A_nc, nVERed);
  nVE := nVERed;

  MRed_aux   := nil;
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
        Tf_ddp_VectDeMuestras.Create_SinClonarMuestras(TVectR.Create_Init(NPFD), 0);
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

end;


procedure TModeloSintetizadorCEGH.WriteToArchi(nombreArchivo: string;
  NDigitosDeformadores, NDecimalesDeformadores: integer);
var
  f:     textfile;
  kserie, k, j: integer;
  kpaso: integer;
  NSS, NFD, NPFD: integer;
  NOrdenDelFiltro: integer;

begin
  assignFile(f, nombreArchivo);
  rewrite(f);
  uauxiliares.setSeparadoresGlobales;

  NSS  := nBornesSalida;
  NFD  := length(funcionesDeformantes[0]);
  NPFD := funcionesDeformantes[0][0].a.n;
  NOrdenDelFiltro := A.nc div A.nf;

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
  f:     file of byte;
  kserie, k: integer;
  kpaso: integer;
  {NSS,} NFD, NPFD: integer;
  //  NOrdenDelFiltro: integer;

  //  tm: TMatR;
  tv: TVectR;

  //  kmin, kmax: integer;
  jh:      integer;
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

begin
  assignFile(f, nombreArchivo);
  rewrite(f);

  //  NSS:= nBornesSalida;
  NFD  := length(funcionesDeformantes[0]);
  NPFD := funcionesDeformantes[0][0].a.n;
  //  NOrdenDelFiltro:= A.nc div A.nf;

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
      tv     := funcionesDeformantes[kserie][kpaso - 1].a;
      minVal := tv.pv[1];
      maxVal := tv.pv[tv.n];
      alfa   := (maxVal - minVal) / 65000.0;
      if abs(alfa) < 1e-12 then
        alfa := 1;
      beta   := (maxVal + minVal) / 2;
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

  bwi(B.nc);
  bwi(A.nc);

  for k := 1 to nBornesSalida do
  begin
    blockWrite(f, A.pm[k].pv[1], A.nc * SizeOf(NReal));
    blockWrite(f, B.pm[k].pv[1], B.nc * SizeOf(NReal));
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
    bwi( MRed_aux.nf );
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
  p      := funcionesDeformantes[kSerie - 1][kPaso - 1];
  u      := p.area_t(x);
  Result := Gaussiana.t_area(u);
end;


function TModeloSintetizadorCEGH.gTox(g: NReal; kSerie, kPaso: integer): NReal;
var
  u: NReal;
  p: Tf_ddp_VectDeMuestras;
begin
  p      := funcionesDeformantes[kSerie - 1][kPaso - 1];
  u      := Gaussiana.area_t(g);
  Result := p.t_area(u);
end;


// crea un vector de estado según la cantidad de series y el orden del filtro
function TModeloSintetizadorCEGH.CrearVector_EstadoX: TVectR;
begin
  Result := TVectR.Create_Init(A.nc);
end;

// Crea un vector del tamaño necesario para alojar las salidas
function TModeloSintetizadorCEGH.CrearVector_Salida: TVectR;
begin
  Result := TVectR.Create_Init(A.nf);
end;

// crea un vector para alamcenar los valores de las fuentes de ruido blanco
function TModeloSintetizadorCEGH.CrearVector_RBG: TVectR;
begin
  Result := TVectR.Create_Init(B.nc);
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
  EstadoX: TVectR; entradaRBG: TVectR);
var
  ksal: integer;
begin
  for ksal := 1 to SalidaY.n do
    SalidaY.pv[ksal] := a.Fila(ksal).pev(EstadoX) + b.Fila(ksal).pev(entradaRBG);
end;

function TModeloSintetizadorCEGH.CalcularSalida(kSal: integer;
  const pEstadoX, pEntradaRBG: PNReal): NReal;
begin
  Result := a.Fila(ksal).pev(pEstadoX) + b.Fila(ksal).pev(pEntradaRBG);
end;

function TModeloSintetizadorCEGH.CalcularSalidaConSesgo(kSal: integer;
  const pEstadoX, pEntradaRBG: PNReal; sesgoVM, atenuacion: NReal): NReal;
begin
  Result := a.Fila(ksal).pev(pEstadoX) + atenuacion * b.Fila(ksal).pev(
    pEntradaRBG) + sesgoVM;
end;

// realiza los desplazamientos en X y copia Y en los casilleros que corresponde
procedure TModeloSintetizadorCEGH.EvolucionarEstado_(var EstadoX: TVectR;
  SalidaY: TVectR);
var
  kserie, jcol: integer;
  ordenFiltro:  integer;

begin

  ordenFiltro := CalcOrdenDelFiltro;

  for jcol := A.nf * ordenFiltro downto A.nf + 1 do
    EstadoX.pv[jcol] := EstadoX.pv[jcol - A.nf];

  for kserie := 1 to A.nf do
    EstadoX.pv[kserie] := SalidaY.pv[kserie];

end;


// retorna el orden del filtro
function TModeloSintetizadorCEGH.CalcOrdenDelFiltro: integer;
begin
  Result := A.nc div A.nf;
end;



procedure TModeloSintetizadorCEGH.InicializarDesdeDatosReales(X: TVectR;
  serieHistorica: TSeriesDeDatos; kPaso: integer; desp_selector0: integer);
var
  kSerie:   integer;
  jRetardo: integer;
  ipaso:    integer;
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
    168: res := fecha.semana52 - 1;
    24: res  := min(fecha.dia - 1, 364);
    1: res   := fecha.horasDesdeElInicioDelAnio;
    else
      raise Exception.Create(exKSelectorDeformador + IntToStr(durPasoDeSorteoEnHoras));
  end;
  Result := res mod nPuntosPorPeriodo;
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

  if A <> nil then
    A.Free;
  if B <> nil then
    B.Free;
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
  if MAmp <> nil then
    MAmp.Free;
  if MRed_aux <> nil then
    MRed_aux.Free;

  gaussiana.Free;
  inherited Free;
end;

function createNilTMatOf_ddp_VectDeMuestras(filas, columnas: integer):
TMatOf_ddp_VectDeMuestras;
var
  i, j: integer;
  res:  TMatOf_ddp_VectDeMuestras;
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

