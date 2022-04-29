{$DEFINE _OPT_kselectordeformador_}

(*+doc

Fuente CEGH - Correlaciones en Espacio Gaussiano con Histograma.
El modelo incluye un núcleo lineal, que sintetiza series temporales
gaussianas. El núcleo lineal capta las correlaciones temporales y espaciales
de las diferentes series.
Estas series gaussianas son luego llevadas a un espacio real mediante un conjunto
de trasformaciones no lineales de forma que el histograma de amplitudes de las
series es el deseado.
Las trasformaciones no lineales pueden variar con el tiempo lo que permite
ir variando el histograma esperado de los valores sintéticos con el tiempo.
El ejemplo de aplicación para el que fue desarrollado el modelo es para sintetizar
series de posibles aportes hidráulicos a las represas y en dicha aplicación
resulta natural hacer variar las transformaciones no lineales según la estación
del año para lograr histogramas diferentes en Primavera que en Verano.

-doc*)
unit uFuenteSintetizador;

interface

uses
  uFuentesAleatorias, MatReal, uCosa, xMatDefs, fddp,
  uAuxiliares, uEstados,
  uConversions,
  uGlobs, uconstantesSimSEE,
  Classes, umodelosintcegh, uDatosHistoricos,
  uFechas, Math, upronostico,
  ufichasdeterminismos_obsoleta,
  uvatespronosticos,
  uconsultapronosticoscli;

resourcestring
  rsSintetizadorCEGH = 'Sintetizador CEGH';
  exFaltaEspValorDeterministicoBornes =
    'Falta especificar el valor inicial de alguno de los Bornes en ';
  exNoSuficientesValoresDeterministicosInicializar =
    'No hay suficiente valores determinísticos como para inicial la memoria del filtro.';
  exErrorDiferenteLargoReducirEstado =
    'ERROR, R=NIL AND length(X) <> length(y) en TFuenteSintetizadorCEGH.ReducirEstado';

  rsFichaDe = 'Ficha de';

  exFuenteCEGHFichaFuente = 'TFuenteSintetizadorCEGH.getFichaPD: la fuente "';
  exFechaInvalida = '" no tiene válidas para la fecha ';
  exFuenteCEGHPrepararMemoria = 'TFuenteSintetizadorCEGH.PrepararMemoria: la fuente ';
  exNoTieneMultiplicadorVE =
    ' no tiene especificados suficientes multiplicadores de valores esperados o ';
  exVarianzaEnFicha = 'varianzas en su ficha nro ';
  exFichaEspecificarTantosVEcomoBornes =
    'Cada ficha debe especificar tantos ' +
    'valores esperados y varianzas como bornes de salida tenga la fuente.';
  exErrorDiferenteLargoExpandirEstado =
    'ERROR, RT=NIL y length(X) <> length(' +
    'Y) en TFuenteSintetizadorCEGH.ExpandirEstado';
  exVarianzaDemasiadoGrande =
    'La varianza es demasiado grande. El máximo alcanzable es: ';
  exValorMedioDemasiadoAlto = 'El valor medio es demasiado alto';
  exValorMedioBajo = 'El valor medio es muy bajo';
  exMaximoNumeroIteraciones = 'Salí por número máximo de iteraciones.';
  exNoSeLogroDeformarHistorgramaSerie =
    'CalcularNuevosDeformadores: No se logró ' +
    'deformar el histograma para lograr los valores indicados en la serie "';
  exAcercarVarianzaPromedio =
    'Intente acercar los valores de promedio y ' +
    'varianza objetivo a los originales (multiplicadores a 1).';
  exFaltaValorDeterministicoBorne =
    'Falta especificar el valor deterministico de alguno de los bornes en ';
  exCreandoLaFuente = 'Creando la fuente ';
  exArchivoDatosDuracionDistinta =
    'Especificó un archivo de datos ' +
    'historicos con distinta duración de paso de sorteo que la del archivo del modelo.';
  exBornesArchivoDiferente =
    'Los bornes en el archivo del modelo difieren de ' +
    'los bornes en el archivo de datos historicos.';
  exCEGHInitDatosHistoricosFromFile =
    'TFuenteSintetizadorCEGH.InitDatosHistoricosFromFile: ';

  exLeyendoLaFuente = ' Leyendo la fuente ';


const
  exFuenteSintetizador = 'FuenteSintetizadorCEGH: ';

  (*
      Xs = A1 X[k-1] + A2 X[k-2] + .. An X[k-n]  + B rbg

      Donde A = [ A1; A2;  .. An ]  y B  son las matrices del filtro.

      La dimensión del estado es A.nc

      El estado completo lo podemos poner como la concatenación de los vectores
      X[k-1] ... X[k-n]

      Los bornes de salida tienen la dimensión de Xs que es A.nf
      Los bornes en el mundo real tienen por consiguiente la misma dimensión A.nf

      La entrada RB:
      En la bornera ponemos el vector primero r[0], (los ruidos blancos)

      El estado; dim_X = A.nc + A.nc (pongo todos los estados en el mundo real por comodidad)
      luego el vector X[k-1] ... X[k-n].
      Luego de eso ponemos las salidas en el mundo real Y[k-1]

      Luego de eso repetimos el estado para X_s

  *)

//La bornera del sintetizador es:
//0                      .. dimRB-1                    -> ruidos blancos de entrada
//jPrimer_X              .. jPrimer_X + (dim_X/2)-1    -> estado gaussiano de este paso
//jPrimer_X + (dim_X/2)  .. jPrimer_X + dim_X -1       -> estado real de este paso
//jPrimer_Xs             .. jPrimer_Xs + (dim_Xs/2)-1  -> estado gaussiano del próximo paso
//jPrimer_Xs + (dim_Xs/2).. jPrimer_Xs + dim_Xs -1     -> estado real del próximo paso
//jPrimer_BC             .. jPrimer_BC + dim_BC-1      -> bornes calculados

//Primero vienen los ruidos blancos hasta dim_RB, luego hasta la mitad de dim_X
//vienen el estado de la fuente en el espacio gaussiano, en la segunda mitad de
//dim_X viene el estado en el espacio normal (los valores que tomaran los bornes),
//luego viene el estado gaussiano y normal del paso siguiente y al final del todo
// los bornes calculados.
type
  TTipoValorEsperadoCEGH = (TTVE_real, TTVE_Gaussiano);
  TDAOfTTipoValorEsperadoCEGH = array of TTipoValorEsperadoCEGH;


  { TFuenteSintetizadorCEGH }

  TFuenteSintetizadorCEGH = class(TFuenteAleatoria)
  private
    ixr: integer;       //Indice de la variable de estado en el conjunto global
    fuenteGaussiana: Tf_ddp_GaussianaNormal;

    //Si simularConDatosHistoricos estos valores apuntan a los indices y pesos
    // necesarios para calcular el proximo valor a apartir de las series histócas
    //    indiceDatosHistoricos: integer;
    //    indiceDatosHistoricos_s: integer;
    indicesDatosHistoricos, indicesDatosHistoricos_s: TDAOfNInt;
    pesosDatosHistoricos, pesosDatosHistoricos_s: TDAOfNReal;
    Desp_IniSim_IniDatosHistoricos: integer;

    //para no crearlos en cada paso
    calcularSalidaBorne: TDAOfBoolean;
    todosLosBornesEnTrue: TDAOfBoolean;

    escenarioSorteado: TEscenarioDePronosticos;

(*
    //Busca en los datos historicos el primer valor cuyo período de validez
    //contenga a fecha sin considerar el anio.
    //fechaIniSorteo <= fecha < fechaFinSorteo comparando solo mes y dia
    //offsetDatos es el desplazamiento en anios desde la fecha de inicio de los
    //valores historicos. El indice se calculara desde
    //datosHistoricos.fechaIni + offsetDatos anios
    // retorna en indiceDatos, el valor del índice que apunta al dato
    //???? no se si se usa
    function getIndiceDato__(fecha: TFecha; nAnios_offsetDatos: integer): integer;
  *)

    procedure InitDatosHistoricosFromFile;

    procedure Sim_Cronica_Inicio_SINTETICAS;
    procedure Sim_Cronica_Inicio_HISTORICAS;

  protected
    procedure GaussianarRafaga(var destino: TDAOfNReal; kBaseDestino: integer;
      const origen: TDAOfNReal; kBaseOrigen: integer;
      NBornesDestino, NRetardosXDestino: integer; NBornesOrigen: integer;
      datosModelo: TModeloSintetizadorCEGH; fecha: TFecha);

    procedure SortearEntradaRB(var aRB: NReal); override;
    procedure ValorEsperadoEntradaRB(var aRB: Nreal); override;
    procedure calcular_jsInicioFinal; override;

  public
    (**************************************************************************)
    (* A T R I B U T O S   P E R S I S T E N T E S                            *)
    (**************************************************************************)
    nombreArchivoModelo:            TArchiRef;
    simularConDatosHistoricos:      boolean;
    sincronizarConHistoricos:       boolean;
    SincronizarConSemillaAleatoria: boolean;
    nombreArchivoDatosHistoricos:   TArchiRef;
    usarModeloAuxiliar:             boolean;
    nombreArchivoModeloAuxiliar:    TArchiRef;

    //Información para introducción de pronósticos mediante sesgos.
    escenariosDePronosticos: TEscenariosDePronosticos;

    //Dirección web para extracción de pronósticos.
    url_get:     string;
    (**************************************************************************)

    datosModelo_Sim: TModeloSintetizadorCEGH;

    datosHistoricos: TDatosHistoricos;

    // esto es si queremos que al Optimizar utilice otro modelo
    // diferente al de Simular y además cuando simula
    // usa el modelo auxiliar para establecer el estado global
    // del sistema.
    modeloAuxiliar: TModeloSintetizadorCEGH;

    modeloAuxiliarActivo: boolean;

    // apunta al modelo a usar en la optimización.
    // puede ser datosModelo o modeloAuxiliar según el caso.
    datosModelo_Opt: TModeloSintetizadorCEGH;

    // variables auxiliares
    XRed, XsRed: TDAOfNReal; // estados reducidos de X y Xs
    XRed_aux: TDAOfNReal;

    // Estimación lineal de la diferencia en el costo futuro que ocasiona la evolución
    // del estado de EstadoK_Actual a EstadoK_Aux
    DeltaCosto: NReal;

    //    jPrimer_RBamp, jUltimo_RBamp: integer;
    jPrimer_X_x, jUltimo_X_x: integer;
    // primer X en el vector  de estado Xs (dim A.nc)
    jPrimer_X_y, jUltimo_X_y: integer; // primer y (mundo real ) ( dim A.nf )

    jPrimer_Xs_x, jUltimo_Xs_x: integer;
    // primer X en el vector  de estado Xs (dim A.nc)
    jPrimer_Xs_y, jUltimo_Xs_y: integer; // primer y (mundo real ) ( dim A.nf )

    constructor Create(capa: integer;
      nombre, nombreArchivoModelo, nombreArchivoDatosHistoricos: string;
      simularConDatosHistoricos: boolean;
      SincronizarConHistoricos, sincronizarConSemillaAleatoria: boolean;
      nombreArchivoModeloAuxiliar: string; usarModeloAuxiliar: boolean;
      EscenariosDePronosticos: TEscenariosDePronosticos; resumirPromediando: boolean;
      url_get: string );

    {$IFNDEF MIGRACION_PERSISTENCIA}
    constructor Create_ReadFromText(f: TArchiTexto); override;
    procedure WriteToText(f: TArchiTexto); override;
    {$ENDIF}

    class function DescClase: string; override;
    //Luego de asignado el nombre de archivo se carga desde el
    procedure InitModeloFromFile;

    procedure PrepararMemoria(globs: TGlobs); override;

    function cronicaIdInicio: string; override;
    procedure Sim_Cronica_Inicio; override;
    procedure fijarEstadoInterno; override;

    // Calcula el estado siguiente. Solo calcula Xs, no lo aplica.
    procedure calcular_Xs; override;
    procedure PosicionarseEnEstrellita; override;
    procedure EvolucionarEstado; override;

    procedure ActualizarEstadoGlobal(flg_Xs: boolean); override;

    procedure Optx_nvxs(var ixr, ixd, iauxNReal, iauxInt: integer); override;
    procedure Optx_RegistrarVariablesDeEstado(adminEstados: TAdminEstados); override;

    // carga el deltacosto para el término indep del simplex
    function calc_DeltaCosto: NReal; override;

    // las fuentes con estado tienen que calcular el delta costo
    // por el delta_X resultante del sorteo
    procedure PrepararPaso_ps; override;

    function dim_RBG: integer; override;
    function dim_Wa: integer; override;
    function dim_RBU: integer; override;
    function dim_X: integer; override;

    //Retorna el indice del array donde ira el valor de ese borne
    function IdBorne(nombre: string): integer; override;

    // Retorna el nombre del Borne a partir del índice
    function NombreBorne( idBorne: integer ): string; override;

    // Calcula el estado reducido a partir del estado X.
    // y= R* X.  Si R=NIL y length(x)=length(y) hace y= x;
    // X forma parte de la bornera a partir de jIniX
    procedure ReducirEstado(var y: TDAofNReal; jIniX: integer;
      const datosModelo: TModeloSintetizadorCEGH; const R: TMatR;
      const Bornera: TDAOfNReal);

    // Calcula el estado sin reducir X a partir del estado reducido y
    // mediante la estimación X= RT* y
    // Si RT= NIL y length(y)=length(x) hace X= y
    //El X esta en la bornera a partir de jIniX
    procedure ExpandirEstado(datosModelo: TModeloSintetizadorCEGH;
      jIniX: integer; var bornera: TDAofNReal; const y: TDAOfNReal);

    //Aplica las funciones deformantes a los valores del estado X en los bornes
    //indicados en calcularBorne
    procedure calcularSalidasDeX(Xs: boolean); overload;
    procedure calcularSalidasDeX(datosModelo: TModeloSintetizadorCEGH;
      Xs: boolean; calcularBorne: TDAOfBoolean); overload;

    procedure Free; override;

    procedure PubliVars; override;

    // retorna indice selector de la función desformante
    // que corresponde al paso de tiempo si fecha es nil y al de la fecha
    //sino.
    function kSelectorDesformador(datosModelo: TModeloSintetizadorCEGH;
      fecha: TFecha): integer;

    function Gaussianar_(datosModelo: TModeloSintetizadorCEGH;
      xNoGaussiana: NReal; kBorne: integer; fecha: TFecha): NReal;

    //Solo para debug
    function descBornera: string; override;
    procedure Dump_Variables(var f: TextFile; charIndentacion: char); override;


    procedure sim_FinCronicaPrintEstadoFinal(var fsal: textfile); override;

    // recalibra los sesgos y atenuadores de acuerdo con los parámetros de los
    // pronósticos.
    procedure ReCalibrarPronosticos(fechaIniSim: TFecha);

    // intenta obtener de la dirección url_get los pronósticos
    // de acuerdo a la descripción de los mismos.
    function GetPronosticos( fechaIniSim: TFecha ): boolean;

    {$IFDEF MIGRACION_PERSISTENCIA}
    class function CreateDataConversionList(): TListDataConversion; override;
    class function CreateDataColumnList(xClaseDeCosa:TClaseDeCosa; xVersion: integer = -2): TDataColumnListOfCosa; override;
    {$ENDIF}

    procedure AfterInstantiation; override;

    procedure Calibrar; override;

  published
    {$IFDEF MIGRACION_PERSISTENCIA}
    property _nombreArchivoModelo:            TArchiRef    read nombreArchivoModelo            write nombreArchivoModelo;
    property _simularConDatosHistoricos:      boolean      read simularConDatosHistoricos      write simularConDatosHistoricos;
    property _sincronizarConHistoricos:       boolean      read sincronizarConHistoricos       write sincronizarConHistoricos;
    property _SincronizarConSemillaAleatoria: boolean      read SincronizarConSemillaAleatoria write SincronizarConSemillaAleatoria;
    property _nombreArchivoDatosHistoricos:   TArchiRef    read nombreArchivoDatosHistoricos   write nombreArchivoDatosHistoricos;
    property _usarModeloAuxiliar:             boolean      read usarModeloAuxiliar             write usarModeloAuxiliar;
    property _nombreArchivoModeloAuxiliar:    TArchiRef    read nombreArchivoModeloAuxiliar    write nombreArchivoModeloAuxiliar;
    property _pronosticos:                    TPronosticos read pronosticos                    write pronosticos;
    property _url_get:                        string       read url_get                        write url_get;
    {$ENDIF}
  end;


procedure cambioFichaPDFuenteSintetizadorCEGH(fuente: TCosa);
procedure AlInicio;
procedure AlFinal;



implementation

uses
  ucalibrarconopronosticos,
  SysUtils;

{$IFDEF DEBUG_SORTEOS}
var
  fdebug_sorteos: TextFile;

{$ENDIF}



constructor TFuenteSintetizadorCEGH.Create(capa: integer; nombre,
  nombreArchivoModelo, nombreArchivoDatosHistoricos: string;
  simularConDatosHistoricos: boolean; SincronizarConHistoricos,
  sincronizarConSemillaAleatoria: boolean; nombreArchivoModeloAuxiliar: string;
  usarModeloAuxiliar: boolean;
  EscenariosDePronosticos: TEscenariosDePronosticos;
  resumirPromediando: boolean; url_get: string);
var
  i: integer;
begin
  inherited Create(capa, nombre, 0, resumirPromediando);
  self.nombreArchivoModelo := TArchiRef.Create(nombreArchivoModelo);
  self.simularConDatosHistoricos := simularConDatosHistoricos;
  self.SincronizarConHistoricos := SincronizarConHistoricos;
  self.sincronizarConSemillaAleatoria := sincronizarConSemillaAleatoria;
  self.nombreArchivoDatosHistoricos := TArchiRef.Create(nombreArchivoDatosHistoricos);
  self.nombreARchivoModeloAuxiliar := TArchiRef.Create(nombreArchivoModeloAuxiliar);
  self.usarModeloAuxiliar := usarModeloAuxiliar;
  self.url_get:= url_get;
  fuenteGaussiana := nil;

  self.datosModelo_Sim:= nil;
  InitModeloFromFile;

  self.escenariosDePronosticos := EscenariosDePronosticos;

  if simularConDatosHistoricos then
    InitDatosHistoricosFromFile;

  modeloAuxiliar := nil;
  modeloAuxiliarActivo := False;
  self.usarModeloAuxiliar := False;

end;

{$IFNDEF MIGRACION_PERSISTENCIA}
constructor TFuenteSintetizadorCEGH.Create_ReadFromText(f: TArchiTexto);
var
  corridaDeterminista: boolean;
  EstadoInicial_Real: TDAofNReal;
  i: integer;
  valoresBorne: TDAofNReal;
  k, j: integer;

  //  cantSesgos: integer;

  // auxiliares para pasar de versión 45,46 a >47
  x_cantsesgo_ruido: integer;
  x_sesgo_ruido: TDAOfDAOfNReal;
  x_factor_ruido: TDAOfNReal;

  x_fechaInisesgo: TFecha;

  x_rangoFechaSesgo: NReal;
  x_NPCC, x_NPLC, x_NPSA, x_NPAC: integer;
  x_aPronostico: TPronostico;
  lDeterminismos: TListaDeCosas;
  xlpd: TListaDeCosas;
  aDeterminismo: TFichaDeterminismo;
  x_arranqueConico, x_determinismoSoloEstadoInicial: boolean;
  x_aPronostico_rangoFechaSesgo: NReal;

  // variables obsoletas de la época de los f
  valorRbVeSeleccionado: boolean;
  valorProbExcedencia: NReal;
  valorCalibControlCono: integer;
  valorCalibIncDesviacion: integer;
  valorCalibMultNormaUno: integer;
  valorCalibCantIteraciones: integer;
  kBornePublicado: Integer;

  // Para lectura de salas anteriores a la version 140
  pronosticos : TPronosticos;
begin
  datosModelo_Sim:= nil;
  modeloAuxiliar := nil;
  nombreArchivoModeloAuxiliar := TArchiRef.Create('');
  modeloAuxiliarActivo := False;
  usarModeloAuxiliar := False;
  lDeterminismos := nil;
  xlpd := nil;

  x_fechaInisesgo := nil;
  SincronizarConHistoricos := False;
  SincronizarConSemillaAleatoria := False;

  if f.Version < 10 then
  begin
    inherited Create_ReadFromText(f);
    f.IniciarLecturaRetrasada;
    f.rdArchRef('nombreArchivo', nombreArchivoModelo);
    f.rd('EstadoInicial_Real', EstadoInicial_Real);
    f.rd('corridaDeterminista', corridaDeterminista);
    f.EjecutarLectura;
    lDeterminismos := TListaDeCosas.Create(capa, 'lDeterminismos');
    for i := 0 to high(EstadoInicial_Real) do
    begin
      valoresBorne := copy(EstadoInicial_Real, i, 1);
      lDeterminismos.Add(TFichaDeterminismo.Create(capa, valoresBorne));
    end;
    fuenteGaussiana := nil;
    InitModeloFromFile;
    simularConDatosHistoricos := False;
    nombreArchivoDatosHistoricos := TArchiRef.Create('');
    datosHistoricos := nil;
  end
  else if f.Version < 11 then
  begin
    inherited Create_ReadFromText(f);
    f.IniciarLecturaRetrasada;
    f.rdArchRef('nombreArchivo', nombreArchivoModelo);
    f.rd('lDeterminismos', TCosa(lDeterminismos));
    f.EjecutarLectura;
    fuenteGaussiana := nil;
    InitModeloFromFile;
    simularConDatosHistoricos := False;
    nombreArchivoDatosHistoricos := TArchiRef.Create('');
    datosHistoricos := nil;
  end
  else
  begin
    inherited Create_ReadFromText(f);
    f.IniciarLecturaRetrasada;
    f.rdArchRef('nombreArchivo', nombreArchivoModelo);
    if (f.Version < 56) then
    begin
      f.rd('lpd', TCosa(xlpd));
      f.rd('lDeterminismos', TCosa(lDeterminismos));
    end;

    if f.version >= 60 then
      f.rd('sincronizarConHistoricos', sincronizarConHistoricos);

    if f.version >= 96 then
      f.rd('sincronizarConSemillaAleatoria', sincronizarConSemillaAleatoria);


    f.rd('simularConDatosHistoricos', simularConDatosHistoricos);
    f.rdArchRef('nombreArchivoDatosHistoricos', nombreArchivoDatosHistoricos);
    fuenteGaussiana := nil;
    modeloAuxiliar := nil;
    if f.Version >= 32 then
    begin
      f.rd('usarModeloAuxiliar', usarModeloAuxiliar);
      f.rdArchRef('nombreArchivoModeloAuxiliar', nombreArchivoModeloAuxiliar);
    end;
    if (f.Version >= 37) and (f.Version < 56) then
      f.rd('arranqueConico', x_arranqueConico);

    if (f.Version >= 44) and (f.Version < 56) then
      f.rd('determinismoSoloEstadoInicial', x_determinismoSoloEstadoInicial);


    x_sesgo_ruido := nil; // lo asigno a nil para chequear si es asignado más adelante
    if f.Version >= 45 then
    begin
      if (f.Version <= 54) then
      begin
        f.rd('cantsesgo_ruido', x_cantsesgo_ruido);
        f.EjecutarLectura;
        f.IniciarLecturaRetrasada;

        SetLength(x_sesgo_ruido, x_cantsesgo_ruido);

        for k := 0 to x_cantsesgo_ruido - 1 do
        begin
          f.rd('sesgo_ruido', x_sesgo_ruido[k]);
          f.EjecutarLectura;
          f.IniciarLecturaRetrasada;
        end;

        f.rd('factor_ruido', x_factor_ruido);
        f.rd('fechaInisesgo', x_fechaInisesgo);
        f.rd('rangoFechaSesgo', x_rangoFechaSesgo);
      end;
    end;

    f.EjecutarLectura;

    InitModeloFromFile;

    if f.Version < 47 then
    begin
      // información de deformadores
      valorRbVeSeleccionado := True;
      valorProbExcedencia := 95;
      valorCalibControlCono := 10;
      valorCalibIncDesviacion := 10;
      valorCalibMultNormaUno := 7;
      valorCalibCantIteraciones := 20;
      x_NPCC := 10;
      x_NPLC := 7;
      x_NPAC := 17;
    end
    else
    begin
      if f.Version <= 54 then
      begin
        f.rd('valorRbVeSeleccionado', valorRbVeSeleccionado);
        f.rd('valorProbExcedencia', valorProbExcedencia);
        f.rd('valorCalibControlCono', valorCalibControlCono);
        f.rd('valorCalibIncDesviacion', valorCalibIncDesviacion);
        f.rd('valorCalibMultNormaUno', valorCalibMultNormaUno);
        f.rd('valorCalibCantIteraciones', valorCalibCantIteraciones);
        f.rd('valorSesgoControlCono', x_NPCC);
        f.rd('valorSesgoIncDesviacion', x_NPAC);
        f.rd('valorSesgoMultNormaUno', x_NPLC);

        f.EjecutarLectura;

        if (x_determinismoSoloEstadoInicial) then
          x_NPSA := 0
        else
          x_NPSA := x_NPCC;


        if x_sesgo_ruido <> nil then
        begin
          pronosticos := TPronosticos.Create(capa, '');
          for k := 0 to high(x_sesgo_ruido) do
          begin

            // ojo la cantidad de retardos no la conozco todavía.
            // le pongo CERO y se ajusta más adelante
            x_aPronostico := TPronostico.Create(capa, NombresDeBornes_Publicados[k],
              1, 0, x_NPCC, x_NPLC, x_NPSA, x_NPAC, '', '');
            for j := 0 to high(x_aPronostico.sesgo) do
            begin
              if j < length(x_sesgo_ruido[k]) then
                x_aPronostico.sesgo[j] := x_sesgo_ruido[k][j]
              else
                x_aPronostico.sesgo[j] := 0.0;

              if (j < length(x_aPronostico.factor)) then
                if j < length(x_factor_ruido) then
                  x_aPronostico.factor[j] := x_factor_ruido[j]
                else
                  x_aPronostico.factor[j] := 1.0;

            end;
            x_aPronostico.fechaIniSesgo.dt := x_fechaInisesgo.dt;
            x_aPronostico_rangoFechaSesgo := x_rangoFechaSesgo;
            Pronosticos.Add(x_aPronostico);
            setlength(x_sesgo_ruido[k], 0);
          end;
          setlength(x_sesgo_ruido, 0);
          setlength(x_factor_ruido, 0);
          x_fechaInisesgo.Free;
        end;
      end
      else if f.Version < 142 then
      begin
        f.rd('pronosticos', TCosa(pronosticos));
        f.ejecutarLectura;

        self.escenariosDePronosticos:= TEscenariosDePronosticos.Create(0,'');
        self.escenariosDePronosticos.Add(TEscenarioDePronosticos.Create(1, datosModelo_Sim, datosModelo_Opt));
        for i:=0 to Min(NombresDeBornes_Publicados.Count, pronosticos.Count)-1 do
        begin
          pronosticos[i].Serie:=NombresDeBornes_Publicados[i];
          escenariosDePronosticos.items[0].AddPronostico(pronosticos[i]);
        end;
      end;
    end;

    if f.version >= 127 then
      f.rd( 'url_get', url_get )
    else
      url_get:= '';

    f.EjecutarLectura;

    if (lDeterminismos <> nil) then
    begin
      // si llego por aca quiere decir que la sala es un aversión < 56 y
      // el pronóstico si fue creado por existencia de sesgos no está completo
      // pues le faltan los datos guía.
      if (pronosticos = nil) then
      begin
        // no hay sesgos, solo determinismos esto
        // lo iterpreto como determinismos PUROS.
        if lDeterminismos.Count > 0 then
        begin
          pronosticos := TPronosticos.Create(capa, '');
          for k := 0 to lDeterminismos.Count - 1 do
          begin
            aDeterminismo := TFichaDeterminismo(lDeterminismos[k]);
            x_NPCC := length(aDeterminismo.valores);
            x_NPLC := 0;
            x_NPSA := x_NPCC;
            x_NPAC := 0;
            x_aPronostico := TPronostico.Create(capa, NombresDeBornes_Publicados[k],
              1, 0, x_NPCC, x_NPLC, x_NPSA, x_NPAC, '', '');
            pronosticos.add(x_aPronostico);
          end;
        end;
      end;

      // bueno ahora copio los determinismos a la guía del pronóstico
      // OJO puede pasar que la guia no tenga el mismo largo que los
      // determinismos por lo que chequeo los largos
      for j := 0 to lDeterminismos.Count - 1 do
      begin
        aDeterminismo := lDeterminismos[j] as TFichaDeterminismo;
        x_aPronostico := pronosticos[j] as TPronostico;

        if length(x_aPronostico.guia) <> length(aDeterminismo.valores) then
          setlength(x_aPronostico.guia, length(aDeterminismo.valores));

        for k := 0 to high(aDeterminismo.valores) do
        begin
          x_aPronostico.guia[k] := aDeterminismo.valores[k];
        end;
      end;

      lDeterminismos.Free;
      lDeterminismos := nil;
    end;

    if f.Version < 56 then
    begin // ajustamos el valor de NRetardos de los pronósticos.
      if Pronosticos <> nil then
      begin
        for j := 0 to Pronosticos.Count - 1 do
        begin
          x_aPronostico := Pronosticos[j] as TPronostico;
          if x_aPronostico.NRetardos <> datosModelo_Sim.nRetardos then
          begin
            x_aPronostico.NRetardos := datosModelo_Sim.nRetardos;
            x_aPronostico.NPCC :=
              max(0, x_aPronostico.NPCC - x_aPronostico.NRetardos);
            x_aPronostico.NPSA :=
              max(0, x_aPronostico.NPSA - x_aPronostico.NRetardos);
            setlength(x_aPronostico.sesgo, x_aPronostico.NPCC + x_aPronostico.NPLC);
            setlength(x_aPronostico.factor, x_aPronostico.NPSA + x_aPronostico.NPAC);
          end;
        end;
      end;
    end;

    if simularConDatosHistoricos then
      InitDatosHistoricosFromFile;
  end;
  if xlpd <> nil then
    xlpd.Free;


  if f.Version>=142 then
  begin

    f.rd('escenariosDePronosticos', TCosa(escenariosDePronosticos));
    f.EjecutarLectura;
  end;

end;

procedure TFuenteSintetizadorCEGH.WriteToText(f: TArchiTexto);
var
  k: integer;
begin
  inherited WriteToText(f);
  f.wrArchRef('nombreArchivo', nombreArchivoModelo);
  f.wr('sincronizarConHistoricos', sincronizarConHistoricos);
  f.wr('sincronizarConSemillaAleatoria', sincronizarConSemillaAleatoria);
  f.wr('simularConDatosHistoricos', simularConDatosHistoricos);
  f.wrArchRef('nombreArchivoDatosHistoricos', nombreArchivoDatosHistoricos);
  f.wr('usarModeloAuxiliar', usarModeloAuxiliar);
  f.wrArchRef('nombreArchivoModeloAuxiliar', nombreArchivoModeloAuxiliar);
  f.wr( 'url_get', url_get );
  f.wr('escenariosDePronosticos', escenariosDePronosticos);
end;
{$ENDIF}


class function TFuenteSintetizadorCEGH.DescClase: string;
begin
  Result := rsSintetizadorCEGH;
end;

function TFuenteSintetizadorCEGH.kSelectorDesformador(
  datosModelo: TModeloSintetizadorCEGH; fecha: TFecha): integer;
var
  res: integer;
begin
  // esta función hace lo mismo que la de igual nombre de TModeloSintetizadorCEGH, pero
  // por eficiencia aquí se puede utilizar aprovechando lo ya calculado en las variables de
  // globs para inicio del paso.
  if fecha = nil then
  begin
  {$IFDEF _OPT_kselectordeformador_}
    case datosModelo.durPasoDeSorteoEnHoras of
      730: res := globs.MesInicioDelPaso - 1;
      672: res := (globs.SemanaInicioDelPaso - 1) div 4;
      // se agrega paso de tiempo 4 semanas
      336: res := (globs.SemanaInicioDelPaso - 1) div 2;
      //se agrega paso de tiempo 2 semanas
      168: res := globs.SemanaInicioDelPaso - 1;
      24: res := min(globs.DiaDelAnioInicioDelPaso - 1, 364);
      1: res := globs.HoraDelAnioInicioDelPaso;
      else
        raise Exception.Create(rs_kSelectorDeformador + ' ' +
          IntToStr(durPasoDeSorteoEnHoras));
    end;
    res := res mod datosModelo.nPuntosPorPeriodo;
  {$ELSE}
    res := datosModelo.kSelectorDeformador(globs.FechaInicioDelPaso);
  {$ENDIF}
  end
  else
    res := datosModelo.kSelectorDeformador(fecha);
  Result := res;
end;


function TFuenteSintetizadorCEGH.descBornera: string;
begin
  Result :=
    'RBG: ' + IntToStr(jPrimer_RBG_) + '..' + IntToStr(jUltimo_RBG_) +
    #10 + 'Wa: ' + IntToStr(jPrimer_Wa_) + '..' + IntToStr(jUltimo_Wa_) +
    #10 + 'RBU: ' + IntToStr(jPrimer_RBU_) + '..' + IntToStr(jUltimo_RBU_) +
    #10 + 'X: ' + IntToStr(jPrimer_X_x) + '..' + IntToStr(jUltimo_X_x) +
    #10 + 'Y: ' + IntToStr(jPrimer_X_y) + '..' + IntToStr(jUltimo_X_y) +
    #10 + 'Xs: ' + IntToStr(jPrimer_Xs_x) + '..' + IntToStr(jUltimo_Xs_x) +
    #10 + 'Ys: ' + IntToStr(jPrimer_Xs_y) + '..' + IntToStr(jUltimo_Xs_y) +
    #10 + 'BC: ' + IntToStr(jPrimer_BC) + '..' + IntToStr(jUltimo_BC);
end;

procedure TFuenteSintetizadorCEGH.Dump_Variables(var f: TextFile;
  charIndentacion: char);
begin
  inherited Dump_Variables(f, charIndentacion);
  Writeln(f, charIndentacion, descBornera);
end;

procedure TFuenteSintetizadorCEGH.sim_FinCronicaPrintEstadoFinal(var fsal: textfile);
var
  k: integer;
  val: NReal;
begin
  for k := 0 to NombresDeBornes_Publicados.Count - 1 do
  begin
    val := Bornera[jPrimer_X_y + k];
    writeln(fsal, Nombre + '.' + NombresDebornes_Publicados[k] +
      ' = ' + FloatToStr(val));
  end;
end;

function TFuenteSintetizadorCEGH.cronicaIdInicio: string;
begin
  if simularConDatosHistoricos then
    if SincronizarConHistoricos then
      Result := Self.ClaseNombre + #9 + IntToStr(globs.AnioInicioDelPaso)
    else
      Result := Self.ClaseNombre + #9 + IntToStr(datosHistoricos.anioIni +
        ((globs.kCronica - 1) mod datosHistoricos.nAniosDatos_Min)) +
        ', ' + IntToStr(indicesDatosHistoricos[0])
  else
    Result := '';
end;


procedure TFuenteSintetizadorCEGH.Sim_Cronica_Inicio_SINTETICAS;
var
  kBorne, jRetardo: integer;
  j_x, j_y: integer;
  mval: NReal;
  fechaDelDato: TFecha;

  p: NReal;
  aPronostico: TPronostico;

begin // simulando con series Sintéticas

  fechaDelDato := TFecha.Create_Dt(0);

  p:=SorteadorUniforme.rnd;
  escenarioSorteado:=escenariosDePronosticos.GetEscenarioPronosticos(p);

  if escenarioSorteado.pronosticos.Count <> datosModelo_Sim.nBornesSalida then
    raise Exception.Create(exFaltaEspValorDeterministicoBornes + Self.nombre);

  for kBorne := 0 to escenarioSorteado.pronosticos.Count - 1 do
  begin

    aPronostico:= escenarioSorteado.pronosticos[kBorne];
    if length(aPronostico.guia) < datosModelo_Sim.nRetardos then
      raise Exception.Create(exFuenteSintetizador + Nombre + '. ' +
        exNoSuficientesValoresDeterministicosInicializar);

    for jRetardo := 0 to datosModelo_Sim.nRetardos - 1 do
    begin
      fechaDelDato.PonerIgualA(globs.fechaIniSim);
      fechaDelDato.addHoras(-jRetardo * durPasoDeSorteoEnHoras);
      j_x := jPrimer_X_x + jRetardo * datosModelo_Sim.nBornesSalida;
      j_y := jPrimer_X_y + jRetardo * datosModelo_Sim.nBornesSalida;

      mval := aPronostico.guia[datosModelo_Sim.nRetardos - 1 - jRetardo];
      Bornera[j_x + kBorne] :=
        gaussianar_(datosModelo_Sim, mval, kBorne, fechaDelDato);
      Bornera[j_y + kBorne] := mval;
    end;
    aPronostico.cantValoresDeterministicosUsados := datosModelo_Sim.nRetardos;
  end;
  fechaDelDato.Free;
end;


procedure TFuenteSintetizadorCEGH.Sim_Cronica_Inicio_HISTORICAS;
var
  kBorne, jRetardo: integer;
  j_x, j_y: integer;
  mval: NReal;
  dt_dato: double;
  fechaDelDato: TFecha;
begin
  fechaDelDato := TFecha.Create_Clone(globs.fechaIniSim);


  for jRetardo := 0 to datosModelo_Sim.nRetardos - 1 do
  begin
    dt_dato := globs.fechaIniSim.dt - jRetardo * dt_PasoDeSorteo;

    if sincronizarConSemillaAleatoria then
      datosHistoricos.calc_indices_y_pesos_dt(
        Desp_IniSim_IniDatosHistoricos - globs.ultimaSemillaFijada,
        dt_dato,
        indicesDatosHistoricos, pesosDatosHistoricos)
    else
      datosHistoricos.calc_indices_y_pesos_dt(
        Desp_IniSim_IniDatosHistoricos - globs.kCronica,
        dt_dato,
        indicesDatosHistoricos, pesosDatosHistoricos);


    j_x := jPrimer_X_x + jRetardo * datosModelo_Sim.nBornesSalida;
    j_y := jPrimer_X_y + jRetardo * datosModelo_Sim.nBornesSalida;

    fechaDelDato.dt := dt_dato;
    for kBorne := 0 to datosModelo_Sim.nBornesSalida - 1 do
    begin
      mval := datosHistoricos.get_mval_(kBorne, IndicesDatosHistoricos,
        PesosDatosHistoricos);
      Bornera[j_x + kBorne] :=
        gaussianar_(datosModelo_Sim, mval, kBorne, fechaDelDato);
      Bornera[j_y + kBorne] := mval;
    end;
  end;
  fechaDelDato.Free;

end;

procedure TFuenteSintetizadorCEGH.Sim_Cronica_Inicio;
begin
  inherited Sim_Cronica_Inicio;
  if not simularConDatosHistoricos then
    Sim_Cronica_inicio_SINTETICAS
  else // simulando con series Históricas
    Sim_Cronica_Inicio_HISTORICAS;
end;

procedure TFuenteSintetizadorCEGH.fijarEstadoInterno;
var
  i: integer;
  dm: TModeloSintetizadorCEGH;
begin

  if globs.EstadoDeLaSala = CES_SIMULANDO then
  begin
    assert(datosModelo_Sim.nVE = 0,
      'TFuenteSintetizadorCEGH.setEstadoInterno con nVE= ' +
      IntToStr(datosModelo_Sim.nVE) + ' debe ser 0');
    dm := datosModelo_Sim;
  end
  else
  begin
    assert(datosModelo_Opt.nVE = 0,
      'TFuenteSintetizadorCEGH.setEstadoInterno con nVE= ' +
      IntToStr(datosModelo_Opt.nVE) + ' debe ser 0');
    dm := datosModelo_Opt;
  end;
  for i := jPrimer_X_x to jUltimo_X_x do
    Bornera[i] := 0; // Pongo el valor de Probabilidad 50%
  calcularSalidasDeX(dm, False, todosLosBornesEnTrue);
end;

procedure TFuenteSintetizadorCEGH.PosicionarseEnEstrellita;
var
  i: integer;
{$IFDEF EXPANSION_RUIDA}
  ax: NReal;
  j: integer;
  fila: TVectR;
  kSerie: integer;
  Bamp: TMatR;
{$ENDIF}
begin

  // Si no hay variables de estado la posicion del sistema depende de solo de
  // Bamp
  if datosModelo_Opt.nVE = 0 then
  begin
    for i := jPrimer_X_x to jUltimo_X_x do
    begin
    {$IFDEF EXPANSION_RUIDA}
      Bamp:=escenarioSorteado.GetBamp(globs.fechaToPasoSim(globs.FechaInicioDelpaso));

      // Calculamos el estado expandido x= BAmp * R
      ax := 0; // VA_LA_GUIA

      if Bamp <> nil then
      begin
        kSerie := (i - jPrimer_X_x);
        fila := Bamp.fila(kserie + 1);
        for j := 1 to Bamp.nc do
          ax := ax + fila.e(j) * bornera[jPrimer_Wa_ + j -1];

        Bornera[i] := ax;
      end
      else
      begin
        Bornera[i] := 0;
      end;
    {$ELSE}
      Bornera[i] := 0;//Pongo el valor esperado de la gaussiana
    {$ENDIF}
    end;
  end
  else
  begin
    // copiamos el estado reducido
    for i := 0 to high(XRed) do
      XRed[i] := globs.CF.xr[self.ixr + i];

    // expandimos el reducido para posicionar el no reducido
    ExpandirEstado(datosModelo_Opt, jPrimer_X_x, Bornera, XRed);

  end;
  calcularSalidasDeX(datosModelo_Opt, False, todosLosBornesEnTrue);
end;

procedure TFuenteSintetizadorCEGH.calcular_jsInicioFinal;
begin
  inherited calcular_jsInicioFinal;
  // calculamos los indices auxiliares en las borneras
  jPrimer_X_x := jPrimer_x; // primer X en el vector  de estado Xs (dim A.nc)
  if datosModelo_Sim.A_cte <> nil then
    jUltimo_X_x := jPrimer_X_x + datosModelo_Sim.A_cte.nc - 1
  else
    jUltimo_X_x := jPrimer_X_x + datosModelo_Sim.mcA[0].nc - 1;

  jPrimer_X_y := jUltimo_X_x + 1; // primer y (mundo real ) ( dim A.nf )

  if datosModelo_Sim.A_cte <> nil then
    jUltimo_X_y := jPrimer_X_y + datosModelo_Sim.A_cte.nc - 1
  else
    jUltimo_X_y := jPrimer_X_y + datosModelo_Sim.mcA[0].nc - 1;


  jPrimer_Xs_x := jPrimer_X_x + dim_x; // primer X en el vector  de estado Xs (dim A.nc)
  jUltimo_Xs_x := jUltimo_X_x + dim_x;
  jPrimer_Xs_y := jPrimer_X_y + dim_x; // primer y (mundo real ) ( dim A.nf )
  jUltimo_Xs_y := jUltimo_X_y + dim_x;
end;


procedure TFuenteSintetizadorCEGH.PrepararMemoria(globs: TGlobs);
var
  i: integer;
begin

  inherited PrepararMemoria(globs);

  fuenteGaussiana := Tf_ddp_GaussianaNormal.Create(sorteadorUniforme, 0);

  SetLength(calcularSalidaBorne, datosModelo_Sim.nBornesSalida);
  SetLength(todosLosBornesEnTrue, datosModelo_Sim.nBornesSalida);
  for i := 0 to datosModelo_Sim.nBornesSalida - 1 do
    todosLosBornesEnTrue[i] := True;

  if simularConDatosHistoricos then
  begin
    datosHistoricos.setLength_indices_y_pesos(indicesDatosHistoricos,
      pesosDatosHistoricos );
    datosHistoricos.setLength_indices_y_pesos(
      indicesDatosHistoricos_s, pesosDatosHistoricos_s);
    Desp_IniSim_IniDatosHistoricos :=
      (globs.fechaIniSim.anio - datosHistoricos.fechaIni.anio) + 1;
  end;

end;



function TFuenteSintetizadorCEGH.IdBorne(nombre: string): integer;
begin
  // Obtiene el indice del estado en espacio real
  Result :=
    dim_RBG + // salto los rb
    Dim_Wa + dim_RBU + datosModelo_Sim.A_nc + // salto las X,
    NombresDeBornes_Publicados.IndexOf(nombre)-1;
end;

function TFuenteSintetizadorCEGH.NombreBorne( idBorne: integer ): string;
var
  k: integer;
begin
  k:= idBorne - dim_RBG - Dim_Wa - dim_RBU - datosModelo_Sim.A_nc;
  if (k < 0) or ( k >= NombresDeBornes_Publicados.count ) then
    result:= '?'
  else
    result:= NombresDeBornes_Publicados[k];
end;

procedure TFuenteSintetizadorCEGH.ReducirEstado(var y: TDAofNReal;
  jIniX: integer; const datosModelo: TModeloSintetizadorCEGH;
  const R: TMatR; const Bornera: TDAOfNReal);
var
  i, j: integer;
  fila: TVectR;
  ay: NReal;
begin
  if R <> nil then
  begin
    // Calculamos el estado reducido y= R*x
    for i := 1 to R.nf do
    begin
      ay := 0;
      fila := R.Fila(i);
      for j := 1 to R.nc do
        ay := ay + fila.e(j) * bornera[jIniX + j - 1];
      y[i - 1] := ay;
    end;
  end
  else if length(y) = datosModelo.nVE then
  begin
    for i := 0 to datosModelo.nVE - 1 do
      y[i] := bornera[i];
  end
  else
    raise Exception.Create(exErrorDiferenteLargoReducirEstado);
end;

procedure TFuenteSintetizadorCEGH.ExpandirEstado(datosModelo: TModeloSintetizadorCEGH;
  jIniX: integer; var bornera: TDAofNReal; const y: TDAOfNReal);
var
  i, j: integer;
  fila: TVectR;
  ax: NReal;
{$IFDEF EXPANSION_RUIDA}
  Bamp: TMatR;
{$ENDIF}

begin
  if datosModelo.MAmp_cte <> nil then
  begin
    {$IFDEF EXPANSION_RUIDA}
     // Calculamos el estado expandido x= MAmp * y + BAmp * R
     Bamp:=escenarioSorteado.GetBamp(globs.fechaToPasoSim(globs.FechaInicioDelpaso));
    {$ENDIF}

    // Calculamos el estado expandido x= MAmp * y
    for i := 1 to datosModelo.MAmp_cte.nf do
    begin
      ax := 0; // _PROYECCION_DE_LA_GUIA_EN_NUCLEO(R)_
      fila := datosModelo.MAmp_cte.Fila(i);
      for j := 1 to datosModelo.MAmp_cte.nc do
        ax := ax + fila.e(j) * y[j - 1];
     {$IFDEF EXPANSION_RUIDA}
      // Calculamos el estado expandido x= MAmp * y + BAmp * R
      if Bamp <> nil then
      begin
        fila := Bamp.fila(i);
        for j := 1 to Bamp.nc do
          ax := ax + fila.e(j) * bornera[jPrimer_Wa_ + j - 1];
      end;
     {$ENDIF}
      bornera[jIniX + i - 1] := ax;
    end;
  end
  else
  if datosModelo.nVE = length(y) then
  begin
    for i := 0 to datosModelo.nVE - 1 do
      bornera[jIniX + i] := y[i];
  end
  else
    raise Exception.Create(exErrorDiferenteLargoExpandirEstado);
end;

procedure TFuenteSintetizadorCEGH.ActualizarEstadoGlobal(flg_Xs: boolean);
var
  i: integer;
  tBornera: TDAOfNreal;
begin
  //rch@20140826  OJO , por ahora ingnoro flg_Xs

  if (globs.EstadoDeLaSala = CES_SIMULANDO) and (datosModelo_Opt <>
    datosModelo_Sim) then
  begin
    setlength(tBornera, length(bornera));
    // convertir estados del modelo simulador al optimizador
    if globs.CFauxActivo then
      // atención estoy suponiendo que el CFAux es manejable con el modelo usado en Sim.
      gaussianarRafaga(
        tBornera, jPrimer_X_x,  // destino
        Bornera, jPrimer_X_y,   // origen
        datosModelo_Sim.A_nc, datosModelo_Sim.nRetardos,
        datosModelo_Sim.A_nc, // nBornes del Origen.
        datosModelo_Sim, globs.FechaInicioDelpaso)
    else
      gaussianarRafaga(
        tBornera, jPrimer_X_x,  // destino
        Bornera, jPrimer_X_y,   // origen
        datosModelo_Opt.A_nc, datosModelo_Opt.nRetardos,
        datosModelo_Sim.A_nc, // nBornes del Origen.
        datosModelo_Opt, globs.FechaInicioDelpaso);

  end
  else
    tBornera := Bornera;

  if not globs.CFauxActivo or (datosModelo_Opt.MRed_aux = nil)
  // si no hay un reductor especial uso el mismo del principal
  then
  begin
    if datosModelo_Opt.MRed <> nil then
    begin

      // Calculamos el estado reducido y= R*x
      ReducirEstado(XRed, jPrimer_X_x, datosModelo_Opt, datosModelo_Opt.MRed, tBornera);
      for i := 0 to high(XRed) do
        globs.CF.xr[self.ixr + i] := XRed[i];
    end
    else if datosModelo_Opt.nVE > 0 then
    begin
      //Los estados estan sin reducir. Son los que estan en el administrador de
      //estados
      for i := 0 to datosModelo_Opt.nVe - 1 do
        globs.CF.xr[self.ixr + i] := tBornera[jPrimer_X_x + i];
      //  aplicarFunciones;
    end;
  end
  else
  begin
    if datosModelo_Opt.MRed_aux <> nil then
    begin
      // Calculamos el estado reducido y= R*x
      ReducirEstado(XRed_aux, jPrimer_X, datosModelo_Opt,
        datosModelo_Opt.MRed_aux, tBornera);

      for i := 0 to high(XRed_aux) do
        globs.CF.xr[self.ixr + i] := XRed_aux[i];
    end
    else if datosModelo_Opt.nVE_aux > 0 then
    begin
      //Los estados estan sin reducir. Son los que estan en el administrador de
      //estados
      for i := 0 to datosModelo_Opt.nVE_aux do
        globs.CF.xr[self.ixr + i] := tBornera[jPrimer_X + i];
      //  aplicarFunciones;
    end;
  end;
  if tBornera <> Bornera then
    setlength(tBornera, 0);
end;

procedure TFuenteSintetizadorCEGH.Optx_nvxs(var ixr, ixd, iauxNReal,
  iauxInt: integer);
begin
  self.ixr := ixr;
  ixr := ixr + datosModelo_Opt.nVE;
end;

procedure TFuenteSintetizadorCEGH.Optx_RegistrarVariablesDeEstado(
  adminEstados: TAdminEstados);
var
  i: integer;
  xmin, xmax: double;
  area, deltaArea: double;
  j: integer;
  xt: double;
  dn: Tf_ddp_GaussianaNormal;
  probs: TDAOfNReal;

  dx_pcd, min_dx_pcd: NReal;

begin
  dn := Tf_ddp_GaussianaNormal.Create(nil, 0);

  min_dx_pcd := 10; // un valor grande para ser susitituido en la búsqueda

  for i := 0 to datosModelo_Opt.nVE - 1 do
  begin
    xmax := 2.5; // por poner algo * (nDiscsVsE[i] -1) / (nDiscsVsE[i] + 1);
    xmin := -xmax;
    adminEstados.Registrar_Continua(ixr + i, xmin, xmax,
      datosModelo_Opt.nDiscsVsE[i], datosModelo_Opt.nombreVarE[i], 'p.u. GN' // unidades
      );

    probs := datosModelo_Opt.ProbsVsE[i]; // referenciamos el vector
    area := 0;
    for j := 0 to datosModelo_opt.nDiscsVsE[i] - 1 do
    begin
      deltaArea := probs[j] / 2.0;
      area := area + deltaArea;
      xt := dn.t_area(area);
      adminEstados.xr_def[ixr + i].x[j] := xt;
      if j > 0 then
      begin
        dx_pcd := adminEstados.xr_def[ixr + i].x[j] -
          adminEstados.xr_def[ixr + i].x[j - 1];
        if dx_pcd < min_dx_pcd then
          min_dx_pcd := dx_pcd;
      end;
      area := area + deltaArea;
    end;
    adminEstados.xr_def[ixr + i].dx_pcd := min_dx_pcd;
  end;

  dn.Free;
end;

// las fuentes con estado tienen que calcular el delta costo
// por el delta_X resultante del sorteo
procedure TFuenteSintetizadorCEGH.PrepararPaso_ps;
var
  k: integer;
  dxred, dx: TDAOfNReal;
begin
  // La variación del costo por la variación (involuntaria) del estado
  DeltaCosto := 0;
  calcular_Xs;

  if (globs.EstadoDeLaSala = CES_OPTIMIZANDO) then
  begin
    if datosModelo_Opt.nVE = 0 then
      exit;

    setlength(dxred, datosModelo_Opt.nVE);
    setlength(dx, datosModelo_Opt.A_nc);
    for k := 0 to high(dx) do
      dx[k] := bornera[jPrimer_Xs + k] - bornera[jPrimer_X + k];

    ReducirEstado(dxred, 0, datosModelo_Opt, datosModelo_Opt.MRed, dx);

// writeln( 'Fuente Sintetizador PreparaPaso_ps: ', self.nombre );
    for k := 0 to datosModelo_Opt.nVE - 1 do
      DeltaCosto := DeltaCosto + globs.CF.deltaCosto_vxr_continuo(
        ixr + k, globs.kPaso_ + 1, dxred[k]);
    setlength(dx, 0);
    setlength(dxred, 0);
  end;
end;

function TFuenteSintetizadorCEGH.dim_RBG: integer;
begin
  Result := datosModelo_Sim.B_nc;
end;

function TFuenteSintetizadorCEGH.dim_X: integer;
begin
  Result :=
    datosModelo_Sim.A_nc +  // vector _x estado gaussiano, memoria de la salida
    datosModelo_Sim.A_nc;   // vector _y (  x pasados al mundo real ).
end;

function TFuenteSintetizadorCEGH.dim_Wa: integer;
begin
  {$IFDEF EXPANSION_RUIDA}
    Result := datosModelo_Sim.A_cte.nc;
    if datosModelo_Sim.MRed<>nil then
      Result := Result- datosModelo_Sim.MRed.nf;
  {$ELSE}
  Result := 0;
  {$ENDIF}
end;

function TFuenteSintetizadorCEGH.dim_RBU: integer;
begin
  {$IFDEF EXPANSION_RUIDA}
    Result:=1;
  {$ELSE}
    Result := 0;
  {$ENDIF}
end;

// carga el deltacosto en el término indep del simplex
function TFuenteSintetizadorCEGH.calc_DeltaCosto: NReal;
begin
  Result := DeltaCosto;
end;

function mFilaPorColumna(a: TVectR; b: TDAOfNReal): NReal;
var
  acum: NREal;
  k: integer;
begin
  acum := 0;
  for k := 0 to high(b) do
    acum := acum + a.e(k + 1) * b[k];
  Result := acum;
end;

procedure TFuenteSintetizadorCEGH.SortearEntradaRB(var aRB: NReal);
var
  j, jUltimoRuido: integer;
  UltimoRND: NReal;

begin
  if (globs.EstadoDeLaSala = CES_OPTIMIZANDO) then
  begin
    jUltimoRuido := jUltimo_Wa_;
    for j := jPrimer_RBU_ to jUltimo_RBU_ do
    begin
      UltimoRND:= SorteadorUniforme.rnd;
      TVLArrOfNReal_0(pointer(@aRB)^)[j] := UltimoRND;
      {$IFDEF DEBUG_SORTEOS}
      Write(fdebug_sorteos, #9, UltimoRND: 12: 4);
      {$ENDIF}
    end;

    escenarioSorteado:= escenariosDePronosticos.GetEscenarioPronosticos(Bornera[jPrimer_RBU_]);
  end
  else if (globs.EstadoDeLaSala = CES_SIMULANDO) then
  begin
    jUltimoRuido := jULtimo_RBG_;
  end;

  {$IFDEF DEBUG_SORTEOS}
  Write(fdebug_sorteos, globs.FechaInicioDelpaso.AsISOStr: 20);
  {$ENDIF}

  for j := jPrimer_RBG_ to jUltimoRuido do
  begin
    repeat
      UltimoRND := fuenteGaussiana.rnd;
    until (-3.69 <= UltimoRND) and (UltimoRND <= 3.69);
    TVLArrOfNReal_0(pointer(@aRB)^)[j] := UltimoRND;
    {$IFDEF DEBUG_SORTEOS}
    Write(fdebug_sorteos, #9, UltimoRND: 12: 4);
    {$ENDIF}
  end;

{$IFDEF DEBUG_SORTEOS}
  writeln(fdebug_sorteos);
{$ENDIF}

end;

procedure TFuenteSintetizadorCEGH.ValorEsperadoEntradaRB(var aRB: Nreal);
var
  j, jUltimoRuido: integer;
begin
  if (globs.EstadoDeLaSala = CES_OPTIMIZANDO) then
    jUltimoRuido := jUltimo_Wa_
  else
    jUltimoRuido := jULtimo_RBG_;

  for j := jPrimer_RBG_ to jUltimoRuido do
    TVLArrOfNReal_0(pointer(@aRB)^)[j] := 0;

  for j := jPrimer_RBU_ to jUltimo_RBU_ do
    TVLArrOfNReal_0(pointer(@aRB)^)[j] :=0.5;

end;

// Hace efectivo el cambio de estado haciendo EstadoK_origen:= EstadoK_aux
procedure TFuenteSintetizadorCEGH.EvolucionarEstado;
var
  i: integer;
begin
  for i := 0 to dim_X - 1 do
    Bornera[jPrimer_X + i] := Bornera[jPrimer_Xs + i];

  if simularConDatosHistoricos then
  begin
    vswap(indicesDatosHistoricos, indicesDatosHistoricos_s);
    vswap(pesosDatosHistoricos, pesosDatosHistoricos_s);
  end;
end;

function TFuenteSintetizadorCEGH.Gaussianar_(datosModelo: TModeloSintetizadorCEGH;
  xNoGaussiana: NReal; kBorne: integer; fecha: TFecha): NReal;
begin
  //el false en usarProximosDeformadoresAlterados no esta bien. en verdad debería seleccionarse
  //los deformadores alterados que correspondan a la fecha, no necesariamente los proximos,
  //si al inicializar en sim_cronica_inicio se toman varios datos para atras.
  //Si se toma UN SOLO valor en el sim_cronica_inicio si esta bien porque tiene
  //que usar los deformadores de la fecha de inicio de la simulacion que vienen
  //cargados en pa
  Result := datosModelo.xTog(xNoGaussiana, kBorne + 1,
    kSelectorDesformador(datosmodelo, fecha) + 1);
end;

procedure TFuenteSintetizadorCEGH.GaussianarRafaga(var destino: TDAOfNReal;
  kBaseDestino: integer; const origen: TDAOfNReal; kBaseOrigen: integer;
  NBornesDestino, NRetardosXDestino: integer; NBornesOrigen: integer;
  datosModelo: TModeloSintetizadorCEGH; fecha: TFecha);

var
  kBorne, kSelector: integer;
  jRetardo: integer;
  j_x, j_y: integer;
  xFecha: TFecha;
begin
  xFecha := TFecha.Create_Clone(fecha);
  for jRetardo := 0 to NRetardosXDestino - 1 do
  begin
    kSelector := kSelectorDesformador(datosmodelo, xFecha) + 1;
    j_x := kBaseDestino + jRetardo * NBornesDestino;
    j_y := kBaseOrigen + jRetardo * NBornesOrigen;
    //Ver el comentario en Gaussianar_
    for kBorne := 0 to NBornesDestino - 1 do
      destino[j_x + kBorne] :=
        datosModelo.xTog(origen[j_y + kBorne], kBorne + 1, kSelector);
    xFecha.addHoras(-self.durPasoDeSorteoEnHoras);
  end;
  xFecha.Free;
end;


procedure TFuenteSintetizadorCEGH.calcular_Xs;
var
  i, j: integer;
  //  AiporX, BiporRB: NReal;
  //  Mi: TVectR;

  fechaProximoSorteo: TFecha;
  hayQueCalcularSalidas: boolean;
  dm: TModeloSintetizadorCEGH;
  mval: NReal;

  pronosticos: TPronosticos;
  aPronostico: TPronostico;
  usarCono: TDAOfBoolean;
  kSesgo: TDAOfNInt;
  kFactor: TDAofNInt;
  kSerie: integer;

  kSelector: integer;

label  // por claridad del código - no sacar
  lbl_Optimizando,
  lbl_SimulandoConSeriesSinteticas,
  lbl_SimulandoConSeriesHistoricas,
  lbl_Continuar;

begin

  pronosticos:=escenarioSorteado.pronosticos;

  if pronosticos.HaySesgos then
  begin
    setlength(usarCono, pronosticos.Count);
    setlength(kSesgo, pronosticos.Count);
    setlength(kFactor, pronosticos.Count);
    for kSerie := 0 to pronosticos.Count - 1 do
    begin
      aPronostico := TPronostico(pronosticos.items[kSerie]);
      usarCono[kSerie] := aPronostico.fechaEnRango(globs.FechaInicioDelpaso,
        kSesgo[kSerie], kFactor[kSerie]);
    end;
  end;

  if (globs.EstadoDeLaSala = CES_OPTIMIZANDO) then
    dm := datosModelo_Opt
  else
    dm := datosModelo_Sim;

  if dm.A_cte <> nil then
    kSelector := 0
  else
    kSelector := dm.kSelectorDeformador(globs.FechaInicioDelpaso);

  if (globs.EstadoDeLaSala <> CES_OPTIMIZANDO) then
    if simularConDatosHistoricos then
      goto lbl_SimulandoConSeriesHistoricas
    else
      goto lbl_SimulandoConSeriesSinteticas;

  lbl_Optimizando:
    hayQueCalcularSalidas := True;
  for i := 0 to dm.nBornesSalida - 1 do
  begin
    calcularSalidaBorne[i] := True;
    if pronosticos.HaySesgos and usarCono[i] then
    begin
      aPronostico := TPronostico(Pronosticos.items[i]);
      if kSesgo[i] >= 0 then
      begin
        if kFactor[i] >= 0 then
          Bornera[jPrimer_Xs_x + i] :=
            dm.CalcularSalidaConSesgo(i + 1, @Bornera[jPrimer_X_x],
            @Bornera[jPrimer_RBG_], aPronostico.sesgo[kSesgo[i]],
            aPronostico.factor[kFactor[i]], kSelector)
        else
          Bornera[jPrimer_Xs_x + i] :=
            dm.CalcularSalidaConSesgo(i + 1, @Bornera[jPrimer_X_x],
            @Bornera[jPrimer_RBG_], aPronostico.sesgo[kSesgo[i]], 1.0, kSelector);
      end
      else
      begin // lods dos < 0 no se puede dar si usarCono = true
        Bornera[jPrimer_Xs_x + i] :=
          dm.CalcularSalidaConSesgo(i + 1, @Bornera[jPrimer_X_x],
          @Bornera[jPrimer_RBG_], 0, aPronostico.factor[kFactor[i]], kSelector);
  end;
    end
    else
      Bornera[jPrimer_Xs_x + i] :=
        dm.CalcularSalida(i + 1, @Bornera[jPrimer_X_x], @Bornera[jPrimer_RBG_],
        kSelector);
  end;
  goto lbl_Continuar;

  lbl_SimulandoConSeriesSinteticas:
    hayQueCalcularSalidas := False;
  // marco False por si los valores deterministicos me dan
  for i := 0 to dm.nBornesSalida - 1 do
  begin
    aPronostico := pronosticos[i] as TPronostico;


    // NPCC________NPLC__________
    // NPSA______________________________NPAC________________


    if (aPronostico.cantValoresDeterministicosUsados < aPronostico.NPSA) and
      (aPronostico.cantValoresDeterministicosUsados < aPronostico.NPCC) and
      not aPronostico.determinismoSoloEstadoInicial then
    begin
      // si todavía estoy en la guia determinística calculo impongo valores
      fechaProximoSorteo := TFecha.Create_OffsetHoras(globs.FechaInicioDelpaso,
        durPasoDeSorteoEnHoras);
      mval := aPronostico.guia[aPronostico.cantValoresDeterministicosUsados];
      Bornera[jPrimer_Xs_x + i] := Gaussianar_(dm, mval, i, fechaProximoSorteo);
      Bornera[jPrimer_Xs_y + i] := mval;
      Inc(aPronostico.cantValoresDeterministicosUsados);
      fechaProximoSorteo.Free;
      calcularSalidaBorne[i] := False;
    end
    else
    begin
      // ya no es determinístico.
      calcularSalidaBorne[i] := True;
      if (pronosticos.HaySesgos and usarCono[i]) then
      begin
        if kSesgo[i] >= 0 then
          if kFactor[i] >= 0 then
            Bornera[jPrimer_Xs_x + i] :=
              dm.CalcularSalidaConSesgo(i + 1, @Bornera[jPrimer_X_x],
              @Bornera[jPrimer_RBG_], aPronostico.sesgo[kSesgo[i]],
              aPronostico.factor[kFactor[i]], kSelector)
          else
            Bornera[jPrimer_Xs_x + i] :=
              dm.CalcularSalidaConSesgo(i + 1, @Bornera[jPrimer_X_x],
              @Bornera[jPrimer_RBG_], aPronostico.sesgo[kSesgo[i]], 1, kSelector)
        else
          Bornera[jPrimer_Xs_x + i] :=
            dm.CalcularSalidaConSesgo(i + 1, @Bornera[jPrimer_X_x],
            @Bornera[jPrimer_RBG_], 0, aPronostico.factor[kFactor[i]], kSelector);
      end
      else
        Bornera[jPrimer_Xs_x + i] :=
          dm.CalcularSalida(i + 1, @Bornera[jPrimer_X_x], @Bornera[jPrimer_RBG_],
          kSelector);
      hayQueCalcularSalidas := True;
    end;
  end;
  goto lbl_Continuar;

  lbl_SimulandoConSeriesHistoricas:
    hayQueCalcularSalidas := False;

  fechaProximoSorteo := TFecha.Create_OffsetHoras(globs.FechaInicioDelpaso,
    durPasoDeSorteoEnHoras);

  if sincronizarConSemillaAleatoria then
    datosHistoricos.calc_indices_y_pesos_dt(
      Desp_IniSim_IniDatosHistoricos - globs.ultimaSemillaFijada,
      fechaProximoSorteo.dt,
      indicesDatosHistoricos_s, pesosDatosHistoricos_s)
  else
    datosHistoricos.calc_indices_y_pesos_dt(
      Desp_IniSim_IniDatosHistoricos - globs.kCronica,
      fechaProximoSorteo.dt,
      indicesDatosHistoricos_s, pesosDatosHistoricos_s);

  for i := 0 to dm.nBornesSalida - 1 do
  begin
    mval := datosHistoricos.get_mval_(i, IndicesDatosHistoricos_s,
      PesosDatosHistoricos_s);
    Bornera[jPrimer_Xs_y + i] := mval;
    Bornera[jPrimer_Xs_x + i] := Gaussianar_(dm, mval, i, fechaProximoSorteo);
  end;
  fechaProximoSorteo.Free;


  lbl_Continuar:

(*
// si NRetardos_X > 1

Bien, una vez calculado el Xs correspondiente a los bornes de salida,
si NRetardos_X > 1 tenemos que rellenar el tramo de Xs que no corresponde
directamente a los bornes de salida copiando de X lo que le va a tocar
cuando se produzca el desplazamiento en "evolucionar estado" *)

    for j := jPrimer_Xs_x + dm.nBornesSalida to jUltimo_Xs_x do
      Bornera[j] := Bornera[j - dim_x - dm.nBornesSalida];

  // esto no se si importa, pero por las dudas lo hago.
  for j := jPrimer_Xs_y + dm.nBornesSalida to jUltimo_Xs_y do
    Bornera[j] := Bornera[j - dim_x - dm.nBornesSalida];

  (* fin del rellando de Xs e Ys *)


  if hayQueCalcularSalidas then
    calcularSalidasDeX(dm, True, calcularSalidaBorne);

  if pronosticos.HaySesgos then
  begin
    setlength(usarCono, 0);
    setlength(kSesgo, 0);
    setlength(kFactor, 0);
end;
end;

procedure TFuenteSintetizadorCEGH.Free;
begin

  if modeloAuxiliar <> nil then
  begin
    modeloAuxiliar.Free;
    modeloAuxiliar := nil;
  end;
  if datosHistoricos <> nil then
  begin
    datosHistoricos.Free;
    datosHistoricos := nil;
  end;

  if escenariosDePronosticos <> nil then
  begin
    escenariosDePronosticos.Free;
    escenariosDePronosticos := nil;
  end;

  if Assigned(datosModelo_Sim) then
  begin
    datosModelo_Sim.Free;
    datosModelo_Sim:=nil;
  end;

  setlength(calcularSalidaBorne, 0);
  setlength(todosLosBornesEnTrue, 0);
  setlength(XRed, 0);
  setlength(XsRed, 0);
  setLength(XRed_aux, 0);

  setlength(indicesDatosHistoricos, 0);
  setlength(pesosDatosHistoricos, 0);
  setlength(indicesDatosHistoricos_s, 0);
  setlength(pesosDatosHistoricos_s, 0);

  if fuenteGaussiana <> nil then
  begin
    fuenteGaussiana.Free;
  end;

  nombreArchivoModelo.Free;
  nombreArchivoDatosHistoricos.Free;
  nombreArchivoModeloAuxiliar.Free;
  inherited Free;
end;



procedure TFuenteSintetizadorCEGH.PubliVars;
begin
  inherited PubliVars;
  PublicarVariableVR('X', '-', 15, 15, XRed, False, True);
end;

(*
function TFuenteSintetizadorCEGH.getIndiceDato__(fecha: TFecha;
  nAnios_offsetDatos: integer): integer;
var
  iterFechaIniSorteo, iterFechaFinSorteo: TFecha;
  indiceDatos: integer;
  desp: NReal;
begin
  if SincronizarConHistoricos then
    indiceDatos := datosHistoricos.locate_fecha_(fecha, desp )
  else
    indiceDatos := datosHistoricos.locate_fecha_ignore_anio_(fecha, nAnios_offsetDatos, desp );

  if indiceDatos < 0 then
    raise Exception.Create(
      'Error en: TFuenteSintetizadorCEGH.getIndiceDto_InicioAnio ' + Nombre);
  Result := indiceDatos;
end;
  *)

procedure TFuenteSintetizadorCEGH.InitModeloFromFile;
var
  i: integer;
begin
  if nombreArchivoModelo.testear then
  begin
    if datosModelo_Sim <> nil then datosModelo_Sim.Free;
    datosModelo_Sim := TModeloSintetizadorCEGH.CreateFromArchi(nombreArchivoModelo.archi);
    self.durPasoDeSorteoEnHoras := datosModelo_Sim.durPasoDeSorteoEnHoras;

    if NombresDeBornes_Publicados <> nil then
      NombresDeBornes_Publicados.Clear
    else
      NombresDeBornes_Publicados := TStringList.Create;

    // esto se inicaliza de nuevo en preparar memoria, pero se necesita
    // aquí para que el editor de SimRes3 funcione
    setlength(bornera, dim_RBG+ dim_Wa + dim_RBU + dim_X + dim_Xs + dim_BC);

    for i := 0 to datosModelo_Sim.NombresDeBornes_Publicados.Count - 1 do
    begin
      self.NombresDeBornes_Publicados.Add(
        datosModelo_Sim.NombresDeBornes_Publicados[i]);
      //    fuenteGaussiana:= Tf_ddp_GaussianaNormal.Create( 0 );
    end;

  end
  else
    raise ExceptionFileNotFound.Create(nombreArchivoModelo.archi,
      exCreandoLaFuente + ClaseNombre);

  // si hay un modelo auxiliar para la optimización lo cargo.
  if self.usarModeloAuxiliar then
    if nombreArchivoModeloAuxiliar.testear then
    begin
      if modeloAuxiliar <> nil then modeloAuxiliar.Free;
      modeloAuxiliar := TModeloSintetizadorCEGH.CreateFromArchi(
        nombreArchivoModeloAuxiliar.archi)
    end
    else
      ExceptionFileNotFound.Create(nombreArchivoModelo.archi,
        exCreandoLaFuente + ClaseNombre);

  if self.usarModeloAuxiliar then
  begin
    {$IfDef EXPANSION_RUIDA}
      writeln( 'OJO ... EXPANSION_RUIDA HABILITADO .... ' );
      writeln( 'Fuente: '+ self.nombre);
      writeln( 'Los modelos para optimizacion y simulacion son diferentes.');
      writeln( 'PRESIONE ENTER PARA CONTINUAR.' );
      readln;
      datosModelo_Opt := datosModelo_Sim;
    {$Else}
      datosModelo_Opt := modeloAuxiliar
    {$EndIf}
  end
  else
    datosModelo_Opt := datosModelo_Sim;

  setlength(XRed, datosModelo_Opt.nVE);
  setlength(XsRed, datosModelo_Opt.nVE);
  setlength(XRed_aux, datosModelo_Opt.nVE_aux);

end;

procedure TFuenteSintetizadorCEGH.InitDatosHistoricosFromFile;
var
  i: integer;
  mismosBornes: boolean;
begin
  try
    datosHistoricos := TDatosHistoricos.CreateFromArchi(
      nombreArchivoDatosHistoricos.archi);

    if self.durPasoDeSorteoEnHoras <> Trunc(datosHistoricos.dt_EntrePuntos *
      dtToHora + 0.001) then
      raise Exception.Create(exArchivoDatosDuracionDistinta);

    mismosBornes := datosHistoricos.NombresDeBornes_Publicados.Count =
      NombresDeBornes_Publicados.Count;
    i := 0;
    while (i < datosHistoricos.NombresDeBornes_Publicados.Count) and mismosBornes do
    begin
      mismosBornes := NombresDeBornes_Publicados[i] =
        datosHistoricos.NombresDeBornes_Publicados[i];
      i := i + 1;
    end;

    if not mismosBornes then
      raise Exception.Create(exBornesArchivoDiferente);

  except
    on e: Exception do
      raise Exception.Create(exCEGHInitDatosHistoricosFromFile +
        e.Message + exLeyendoLaFuente + nombre);
  end;
end;

procedure TFuenteSintetizadorCEGH.calcularSalidasDeX(Xs: boolean);
var
  dm: TModeloSintetizadorCEGH;
begin
  if globs.EstadoDeLaSala = CES_SIMULANDO then
    dm := datosModelo_Sim
  else
    dm := datosModelo_Opt;
  calcularSalidasDeX(dm, Xs, todosLosBornesEnTrue);
end;

procedure TFuenteSintetizadorCEGH.calcularSalidasDeX(
  datosModelo: TModeloSintetizadorCEGH; Xs: boolean; calcularBorne: TDAOfBoolean);
var
  i, sel: integer;
  sg: NReal;
  fechaProximoSorteo: TFecha;
begin
  if Xs then
  begin

    fechaProximoSorteo := TFecha.Create_OffsetHoras(globs.FechaInicioDelpaso,
      durPasoDeSorteoEnHoras);
    sel := kSelectorDesformador(datosModelo, fechaProximoSorteo);


    //aplicar funciones deformantes
    for i := 0 to datosModelo.nBornesSalida - 1 do
    begin
      if calcularBorne[i] then
      begin
        sg := Bornera[jPrimer_Xs_x + i];
        bornera[jPrimer_Xs_y + i] :=
          datosModelo.gTox(sg, i + 1, sel + 1);
      end;
    end;
    fechaProximoSorteo.Free;
  end
  else
  begin
    sel := kSelectorDesformador(datosModelo, nil);
    //aplicar funciones deformantes
    for i := 0 to datosModelo.nBornesSalida - 1 do
    begin
      if calcularBorne[i] then
      begin
        sg := Bornera[jPrimer_X_x + i];
        bornera[jPrimer_X_y + i] := datosModelo.gTox(sg, i + 1, sel + 1);
      end;
    end;
  end;
end;

procedure cambioFichaPDFuenteSintetizadorCEGH(fuente: TCosa);
begin
  TFuenteSintetizadorCEGH(fuente).CambioFichaPD;
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteSintetizadorCEGH.ClassName, TFuenteSintetizadorCEGH);
//  registrarClaseDeCosa(TFichaDeterminismo.ClassName, TFichaDeterminismo);
end;

procedure AlFinal;
begin
end;


procedure TFuenteSintetizadorCEGH.ReCalibrarPronosticos(fechaIniSim: TFecha);
begin
  //ucalibrarconopronosticos.CalibrarConoCentrado(datosModelo_Sim,
  //  pronosticos, fechaIniSim);
end;

// intenta obtener los pronósticos desde las direcciones
 // indicadas. El resultado es TRUE si logró obtener todos los pronósticos
 // y FALSE en caso contrario.
function TFuenteSintetizadorCEGH.GetPronosticos( fechaIniSim: TFecha ): boolean;
var
  rbt: TConsultaPronostico_Cliente;
  kSerie: integer;
  aProno: TPronostico;
  resConsulta: TList_FRVarPronostico;
  aVarProno: TFRVarPronostico;
  desconocidas: string;

begin
  //// si no hay una url especificada no consultamos nada.
  //if url_get = '' then
  //begin
  //  result:= true;
  //  exit;
  //end;
  //
  //rbt:= TConsultaPronostico_Cliente.Create( url_get );
  //for kSerie:= 0 to datosModelo_Sim.NombresDeBornes_Publicados.Count-1 do
  //begin
  //  aProno:= pronosticos[kSerie];
  //  rbt.add( datosModelo_Sim.NombresDeBornes_Publicados[kSerie],
  //           globs.fechaIniSim.dt, datosModelo_Sim.durPasoDeSorteoEnHoras/3600.0,
  //           aProno.NRetardos, aProno.NPCC  );
  //end;
  //resConsulta:= rbt.get_pronostico;
  //rbt.Free;
  //
  //if resConsulta.Count <> datosModelo_Sim.NombresDeBornes_Publicados.Count then
  //   raise Exception.Create(
  //         'Fuente sintetizador CEGH '+self.nombre
  //         +' consulto pronostico por: '
  //         +INtToStr( datosModelo_Sim.NombresDeBornes_Publicados.Count )
  //         +' series, pero obtuvo '+IntToStr( resConsulta.count )+' fichas de resultado.' );
  //
  //desconocidas:= '';
  //for kSerie:= 0 to datosModelo_Sim.NombresDeBornes_Publicados.Count-1 do
  //begin
  //  aProno:= pronosticos[kSerie];
  //  aVarProno:= resConsulta[kSerie];
  //  if aVarProno.NPCC = -1 then
  //    desconocidas:= desconocidas + ', '+ aVarProno.nombre;
  //  if datosModelo_Sim.NombresDeBornes_Publicados[kSerie] <> aVarProno.nombre then
  //     raise Exception.Create('Error en nombre de pronóstico, se esperaba: '
  //           +datosModelo_Sim.NombresDeBornes_Publicados[kSerie]
  //           +' se obtuvo: '+ aVarProno.nombre );
  //end;
  //
  //if desconocidas <> '' then
  //begin
  //   writeln( 'Lo siento el servidor de pronósticos no reconoce las variables: '+desconocidas );
  //   result:= false;
  //end
  //else
  //begin
  //  for kSerie:= 0 to datosModelo_Sim.NombresDeBornes_Publicados.Count-1 do
  //  begin
  //    aProno:= pronosticos[kSerie];
  //    aVarProno:= resConsulta[kSerie];
  //    aProno.Cambiar_GUIA( aVarProno.NPCC, aVarProno.NPLC, aVarProno.NPSA, aVarProno.NPAC, aVarProno.guia_p50);
  //  end;
  //  result:= true;
  //end;
  //
  //resConsulta.Free;
end;

{$IFDEF MIGRACION_PERSISTENCIA}
class function TFuenteSintetizadorCEGH.CreateDataConversionList: TListDataConversion;
begin
  Result:=inherited CreateDataConversionList;
  Result.Add(VERSION_MIGRACION_PERSISTENCIA,
             ['nombreArchivo'],
             ['nombreArchivoModelo'],
             Result.ConversionNAMECHANGE);
end;

class function TFuenteSintetizadorCEGH.CreateDataColumnList(xClaseDeCosa:TClaseDeCosa; xVersion: integer):
TDataColumnListOfCosa;
begin

  if (xVersion<56) and (xVersion<>-2) then
  begin
    raise Exception.Create('Está intentando utilizar un archivo *.ese no soportado en la versión actual del sistema. \n\r' +
                           'ERROR INTERNO: \n\r' +
                           'TFuenteSintetizadorCEGH.CreateDataColumnList: xVersion<56');
  end;

  Result:=inherited CreateDataColumnList(xClaseDeCosa,xVersion);
  Result.AddFileReferenceColumn('nombreArchivo',                         0, VERSION_MIGRACION_PERSISTENCIA);
  Result.AddFileReferenceColumn('nombreArchivoModelo',                   VERSION_MIGRACION_PERSISTENCIA   );
  Result.AddBooleanColumn      ('sincronizarConHistoricos',       false, 60                               );
  Result.AddBooleanColumn      ('sincronizarConSemillaAleatoria', false, 96                               );
  Result.AddBooleanColumn      ('simularConDatosHistoricos',      false, 11                               );
  Result.AddFileReferenceColumn('nombreArchivoDatosHistoricos',          11                               );
  Result.AddBooleanColumn      ('usarModeloAuxiliar',             false, 32                               );
  Result.AddStringColumn       ('nombreArchivoModeloAuxiliar',    '',    32                               );
  Result.AddCosaColumn         ('pronosticos',                    57                                      );
  Result.AddStringColumn       ('url_get',                        '',    127                              );
end;
{$ENDIF}

procedure TFuenteSintetizadorCEGH.AfterInstantiation;
begin

  inherited AfterInstantiation;
  datosModelo_Sim:= nil;
  modeloAuxiliar:= nil;
  InitModeloFromFile;

  if simularConDatosHistoricos then
    InitDatosHistoricosFromFile;

  raise Exception.Create('VERIFICAR !!!');

end;

procedure TFuenteSintetizadorCEGH.Calibrar;
begin
  inherited Calibrar;

  if (globs.EstadoDeLaSala=CES_OPTIMIZANDO)  then
  begin
    datosModelo_Sim.Calcular_Matrices_Ampliacion;
  end;

  escenariosDePronosticos.Calibrar(globs, datosModelo_Opt, datosModelo_Sim);


end;

initialization
  {$IFDEF DEBUG_SORTEOS}
  assignfile(fdebug_sorteos, 'c:\simsee\bin\debug_sorteos.xlt');
  rewrite(fdebug_sorteos);
  {$ENDIF}
finalization
{$IFDEF DEBUG_SORTEOS}
  closefile(fdebug_sorteos);
{$ENDIF}
end.
