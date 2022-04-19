{xDEFINE PSO_ENZO}// Pruebas para una optimización determinística.

{xDEFINE PERTURBADO}// Impone una perturbación en el último frame de la función CF
// es con propósitos académicos para mostrar la convergencia del algoritmo de PDE
// con una perturbación en la condición inicial.

{xDEFINE CHEQUEOMEM}// Chequea si los Actores "pierden" memoria en PrepararPaso_ps
{$DEFINE VERBOSO}
{$DEFINE rc_EXPANDO_}
{xDEFINE RECALCULAR_COSTO_DIRECTO_ACTORES}

{$DEFINE ITERADOR_FLUCAR}
{$DEFINE RESUMIR_HISTOGRAMA_VERSION_PABLO}

{$DEFINE ESTABILIZAR_FRAMEINICIAL}// Ejecuta repetidas veces el primer paso
// del algoritmo PDE para lograr una convergencia del último y ante
// penúltimo frame de la función CF. Cuando logra la convergencia
// continúa con la PDE tradicional. Puede ser una opción para poner un
// horizonte de guarda de Optimización menor.

// rch@20160511 deshabilito esto porque no parece apurar el cálculo y me deja
// dudas respecto la repetibilidad de los resultados para la Multi-hilo
{xDEFINE SPXMEJORCAMINO}// Si está activa, guarda información del camino recorrido
// en la desrelajación sucesiva de la resolución del MIP_Simplex e intenta
// recorrer el mejor camino en la solución del siguiente problema.
// Sobre todo en la simulación esto debiera acelear las resoluciones.

{$IFNDEF SUPRIMIR_DUMP_TEXT}// Suprime las salidas de archivos de texto
// detalladas tanto en Optimización como en Simulación.
// Puede ser útil si solo se quiere simular para tener los costos
// de operación futuros, dado que estos se salvan en un archivo resumido.

{$DEFINE DUMP_TEXT_SIMRES}// Indica que se generen las salidas de texto detalladas
// durante la simulación. Esta salida es la que usa el postprocesasdor
// de resultados crónicos SimRes3.

{$DEFINE DUMP_TEXT_OPTRES}// Indica que se generen las salidas de texto detalladas
// durante la optimización.
{$ENDIF}


unit usalasdejuego;

interface

uses
{$IFDEF CHEQUEOMEM}
  udbgutil,
{$ENDIF}
  Classes, SysUtils, Math, uglobs, uconstantesSimSEE, xmatdefs,

{$IFDEF SPXMEJORCAMINO}
  umipsimplex_mejorcamino,
{$ELSE}
  umipsimplex,
{$ENDIF}
  uActores, ucosa, uCosaConNombre,
  ucosaparticipedemercado,
  ufechas, uNodos, uArcos,
  uGeneradores, uDemandas,
  uComercioInternacional,
  uGTer,
  uEstados,
  uFuentesAleatorias,
  uCombustible,
  //  uSuministroCombustible,
  uUsoGestionable_postizado,
  ulistaplantillassr3,
  uescenarios,
  uEsclavizador,
  uFichasLPD,
  uActualizadorLPD,
  uEsclavizadorSobreMuestreado,
{$IFDEF WINDOWS}
  {$IFDEF FPCLCL}
  LCLIntf, lcltype,
  {$ELSE}
  Windows,
  {$ENDIF}
{$ELSE}
{$ENDIF}
  uEsclavizadorSubMuestreado,
  uAuxiliares,
  uHidroConEmbalse,
  uHidroConBombeo,
  uActorNodal,
{$IFDEF ITERADOR_FLUCAR}
  uiteradoressimsee,
{$ENDIF}
  ucontroladordeterminista,
{$IFDEF PSO_ENZO}
  uniform, particulas,
{$ELSE}
  fddp,
{$ENDIF}
  uacumuladores_sim,
  uLectorSimRes3Defs,
  uHistoVarsOps,
  uVarDefs,
  uversiones,
  uparseadorsupersimple;

type
  TDAOfTextFile = array of TextFile;

  // record para servir de respuesta de la función locate de la sala.
  TRec_Lst_CosaConNombre = record
    lst: TListaDeCosasConNombre;
    cosa: TCosaConNombre;
  end;


  TSalaDeJuego_auxRec = class
    durPosAux: TDAofNReal;
    funcsBasura: TListaDeCosasConNombre;
    nombre_EscenarioActivo: string;
  end;

  { TSalaDeJuego }

  TSalaDeJuego = class(TCosaParticipeDeMercado)
  public
    rbtEditor: pointer; // auxiliar para pasar un rbtEditor

    // Usado para evaluar una instancia a partir de la representación en texto.
    evaluador: TEvaluadorConCatalogo;

    (**************************************************************************)
    (*                        ATRIBUTOS PERSISTENTES                          *)
    (**************************************************************************)

    // Descripción de la Sala de Juego introducida por el usuario.
    descripcion: string;

    // Variables GLOBALES visibles por los Actores y Fuentes
    globs: TGlobs;

    // Sistema COMBUSTIBLES y conexión con ELECTRICO
    sums: TListaDeCosasConNombre;
    // Nodos, Arcos, Suministros, Generadores, Demandas Combustibles

    // Lista de FUENTES
    listaFuentes_: TListaDeCosasConNombre;
    // Son las mismas pero separada en la lista que sortea antes de resumir borneras y la
    // B tiene que sortear luego de resumir Borneras.
    listaFuentes_A, listaFuentes_B: TListaDeCosasConNombre;


    listaCombustibles: TListaDeCosasConNombre;
    {Lista de plantillas SimRes3 asociadas a esta sala. }
    listaPlantillasSimRes3: TListaPlantillasSimRes3;
    // listas de todos los actores en la Sala.
    listaActores: TListaDeCosasConNombre; {of TActor}



    // Listas de Actores por Grandes Grupos
    // Sistema ELECTRICO
    nods: TListaDeCosasConNombre; // Nodos
    arcs: TListaDeCosasConNombre; // Arcos
    gens: TListaDeCosasConNombre; // Generadores
    dems: TListaDeCosasConNombre; // Demandas
    comercioInternacional: TListaDeCosasConNombre; // Comercio Internacional
    usosGestionables: TListaDeCosasConNombre;


    estabilizarInicio: boolean;
    randSeed_SincronizarAlInicioDeCadaCronica: boolean;
    usarArchivoParaInicializarFrameInicial: integer;
    {El archivo desde el que se va cargar los datos para inicializar el frame inicial}
    archivoCF_ParaEnganches: TArchiRef;
    archivoSala_ParaEnganches: TArchiRef;
    {Los valores en los que se quiere inicializar las variables del CF archivoCF que no esten en el CF de esta sala. }
    enganchesContinuos: TListaDeCosas;
    enganchesDiscretos: TListaDeCosas;
    {Si es true, el radio button seleccionado es el de sala. }
    engancharConSala: boolean;
    {En caso de enganachar con una sala hay que indicar el escenario dentro de la sala.}
    engancharConSala_escenario: string;
    {si está definido es que queremos ir mirando durante la simulación por donde vamos en esta función de Costo Futuro Auxiliar. }
    archivoCFAux: TArchiRef;
    enganchar_promediando_desaparecidas: boolean;
    {Lista de variables que luego de hacer el enganche se debe uniformizar la información pomediando.}
    uniformizar_promediando: string;

    flg_usar_enganche_mapeo: boolean;
    enganche_mapeo: string;

    flg_IncluirPagosPotenciaYEnergiaEn_CF: boolean;



    usarIteradorFlucar: boolean;
    GenerarRaws: boolean;
    Escenarios: TListaEscenarios;
    nombre_EscenarioActivo: string;
    modo_Ejecucion: integer; // 0 solo el Seleccionado, 1 Todos los activos
    flg_ImprimirArchivos_Estado_Fin_Cron: boolean;

    (**************************************************************************)

    SalaMadre: TSalaDeJuego; // a nil por defecto

    {$IFDEF DEBUG_MULTI_HILO}
    fdebug_mh: textfile;
    {$ENDIF}

    EscenarioActivo: TEscenario_rec;


    // lista todos los tipos de combustibles en la Sala

    //Contiene las fuentes que hayan sido reemplazadas por algún esclavizador
    listaFuentesReemplazadas: TListaDeCosasConNombre;

    // listas auxiliares para acelerar los barridos
    lst_barridoFijarEstadoDeActoresToEstrella: TList;
    lst_barridoFijarEstadoDeFuentesToEstrella: TList;
    lst_SorteosDelPaso_Actores: array of TActor;
    lst_opt_PrintResultados: TList;
    lst_Sim_cronicaIdInicio: TList;

    lst_actores_evolucionarEstado: TList;
    lst_fuentes_evolucionarEstado: TList;

    //      lst_actores_costoDirectoDelPaso: TList;
    lst_fuentes_costoDirectoDelPaso: TList;

    lst_Sim_Paso_Fin: TList;
    lst_CalcularGradienteDeInviersion: TList;


    lst_NecesitoIterar: TList;
    {$IFDEF ITERADOR_FLUCAR}
    IteradorFlucar: TIteradorDePasoSimsee;
    {$ENDIF}
    termicos: array of TGter;
    actores: array of TActor;
    fuentes: array of TFuenteAleatoria;


    //    combustibles: array of TCombustible;

    //Se arman en optx_nvxs. Si la fuente original es sub_muestreada el arreglo
    //contiene el esclavizador
    fuentesConBCSinEstadoEnCF: array of TFuenteAleatoria;
    //subConjunto del arreglo fuentes de las fuentes que no registran estado en CF y tienen bornes calculados. Pueden tener variables de estado internas
    fuentesConBCConEstadoEnCF: array of TFuenteAleatoria;
    //subConjunto del arreglo fuentes de las fuentes que registran su estado en CF y tienen bornes calculados
    hidraulicos: array of TGeneradorHidraulico;

    // contadores de variables para el registro de variables por los actores
    // conjunto de variables asociadas con el planteo del Simplex.
    ivar: integer; // Contador de variables de optimización
    ires: integer; // Contador de restricciones
    ivae: integer; // Contador de variables Enteras en el problema de optimización

    // contadores de variables para el registro de variables por los actores
    // conjunto de variables asociadas con el espacio de estados.
    ivar_xr: integer; // Contador de variables de estado continuas
    ivar_xd: integer; // Contador de varialbes de estado discretas
    ivar_auxNReal: integer; // Contador de variables auxiliares de estado contínuas
    ivar_auxInt: integer; // Contador de variables auxiliares de estado discretas

    spx: TMIPSimplex;

    archiSala_: string; //El archivo de la sala de juego
    dirSala: string; // directorio del archiSala

    dirResultadosCorrida: string;
    //El directorio donde se van a salvar los resultados de
    //la corrida. Por defecto es uconstantes.getDir_bin+'/nombresala'


    escribirOptActores: boolean;

    HayQueIterar_: boolean; // Variable auxiliar que determina si es necesario iterar
    // para una mejor resolución del paso de tiempo.

    //      modoImprimirPotenciasFirmes: boolean;

    fsal: TextFile;

    {$IFDEF DUMP_TEXT_OPTRES}
    fsalopen: boolean;
    fsal_opt: TDAOfTextFile;
    {$ENDIF}
    {$IFDEF opt_Dump_PubliVars}
    //Archivo para debug de la optimizacion multihilo
    f_dbgMH: TextFile;
    f_dbgMH_Open: boolean;
    {$ENDIF}

    macro_ordenes: TStringList;
    macro_errMsg: WideString;
    macro_Sel: TListaDeCosasConNombre; // objetos seleccionados

    //*** variables auxiliares de cálculo ********
    // usada para controlar que se llame una sola vez a preparar memoria.
    flg_MemoriaPreparada: boolean;

    // Acumuladores con resumen de todas las cronicas.
    // La sala Madre tiene la instancia y el resto debe
    // apuntar a esta.
    Acumuladores: TAcumuladores_sim;

    // variables de simulacion
    qAct: NReal;
    idCronicaInicioFuenteK: string;
    tmpCF: TAdminEstados;
    CFAux: TAdminEstados;

    utilidadAcumCronica: NReal;
    CF_AlFinalDeLaCronica: NReal;
    Calculador_CO2: pointer;


    //Variables publicadas en la simulación
    costoDirectoDelpaso: NReal;
    costoOperativoDelPaso: NReal;
    utilidadDirectaDelPaso: NReal;
    PagosPorDisponibilidadDelPaso: NReal;
    PagosAdicionalesPorEnergiaDelPaso: NReal;


    // tiene el acumulado de los actores. Se carga en LeerSolucion de la Sala
    costoDelPaso_spx: NReal;
    CF_AlInicioDelPaso, CFaux_AlInicioDelPaso: NReal;


    // Variables auxiliares para resultado de Simulación.
    VE_CF, VaR05_CF, CVaR05_CF: NReal;


    constructor Create(capa: integer; nombre: string;
      fechaIniSim, fechaFinSim, fechaGuardaSim, fechaIniOpt, fechaFinOpt: TFecha;
      DurPos: TDAOfNReal);
      reintroduce;

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;


    constructor cargarSala(idHilo: integer;
      archiSala, nombre_escenario_activar: string; abortarEnError: boolean
    //   ;  rama: string = ''; capas: string = ''

      ); virtual;
    { Carga la sala "archiSala" y activa el escenario "nombre_escenario_activar"
    eliminando todas las cosas de las capas no activas. Si el parámetro
    "nombre_escenario_activar" = '' no se eliminan las cosas de las capas inactivas }


    function ArchiCF_bin(escenario: string = '__principal__'): string;

    // Carga el CF_{EscenarioArcivo}.bin de la carpete de ejecución de la sala
    // flg_FreeIfNotNil levera el CF anterior si no era nil y luego carga
    // El resultado es TRUE si la carga fue exitosa y false en caso contrario
    function CargarCFFrom_bin(flg_FreeIfNotNil: boolean = True): boolean;


    procedure Free; override;
    procedure PubliVars; override;
    procedure setDirCorrida(archivoSala: string);
    procedure ActivarEscenario(nombreEscenario: string);

    procedure AgregarDefinicionesEvaluador(Evaluador: TEvaluadorExpresionesSimples);
      override;

    //Crea los arreglos de actores  NO PUBLICA VARIABLES
    // flg_esclavizarfuentes se usa en false en el editor para evitar que cree fuentes
    // esclavizantes y las guarde en las salas.
    procedure PrepararMemoriaYListados(flg_esclavizarfuentes: boolean = True);

    procedure PrepararActualizadorFichasLPD(TiempoHaciaAdelante: boolean);

    //Se publicaran solo las variables seleccionadas en las plantillas activas de SimRes3
    //En caso de error publica todas
    procedure publicarSoloVariablesUsadasEnSimRes3;

    procedure publicarTodasLasVariables;

    // prepara los Actores y Fuentes de la Lista.
    //NO PUBLICA VARIABLES
    procedure lista_Prepararse(CatalogoReferencias: TCatalogoReferencias;
      lista: TListaDeCosasConNombre);

    // Arma una lista con la Sala, Globs, los Actores y las Fuentes y
    // llama al procedimiento lista_PrepararseYPubliVars;
    //NO PUBLICA LAS VARIABLES
    procedure Prepararse_(CatalogoReferencias: TCatalogoReferencias);

    // Determina la dimensión del espacio de estado y los frames
    // de variables auxiliares que sea necesario crear.
    // retorna la suma de las dimensiones continuas y discretas
    function optx_nvxs: integer;

    // retorna la suma de variables de estado primero llama a optx_nvxs
    function ContarVariablesDeEstado: integer;
    function generarResumenTermicoPrimerasFichas: string;

    // Camino completo y nombre de archivo simcosto_ssxnn_hm.xlt
    function archi_simcosto: string;


    procedure Clear_ResultadosSim;


    // retorna el valor esperado del CostoFuturo
    // si print = true imprime archivos sino no.
    function Simular(id_hilo: integer; print: boolean; kCronicaIni: integer = 0;
      kCronicaFin: integer = 0): NReal;

    // prepara archivos para SimRes3
    function PreprocesarPlantillasActivasDelEscenario( escenario: TEscenario_rec ): integer;

    function PreprocesarPlantillasActivasDelEscenarioActivo: integer;

    procedure Sim_Cronica_Inicio;

    procedure Actores_AcumularAuxs1;
    procedure Actores_SetAuxs1;

    procedure SorteosDelPasoOpt(sortear: boolean);
    procedure SorteosDelPasoSim(sortear: boolean);

    // este método sellama luego de los sorteos del  paso
    // y antes de preparar los actores.
    procedure Fuentes_PrepararPaso_ps( sortear: boolean );

    // este método se llama luego de los sorteos del  paso y luego
    // de que las fuentes se prepararon
    // y antes de PrepararPaso_ps
    procedure Actores_PrepararPaso_ps_pre;


    // Si hay iteraciones puede ocurrir que ese método se llame reiteradas veces.
    procedure Actores_PrepararPaso_ps;

    procedure InicioSim; override;
    procedure InicioOpt; override;
    procedure PrepararPaso_as;

    function ResolverPaso: NReal; // retorna el costo en USD

    procedure EvolucionarEstado; override;
    procedure Sim_Paso_Fin;
    procedure CalcularGradientesDeInversion;

    procedure CapturarResultadosDelPaso;
    procedure Sim_Cronica_Fin;
    procedure FinSimulacion;

    {$IFDEF PDE_RIESGO}
    // llena los histogramas de un rango de estrellas
    procedure LlenarHistograma_CostoDelPaso_masCF_llegada(var HistoCF: TDAOfNReal;
    // Producto Cartesiano ce(kCron) x HistoCF1( jCronF )
      jBase: integer);
    {$ENDIF}

    function CostoDelPaso_masCF_llegada_: NReal;

    procedure Optimizar(llenarConFrameFinal: boolean);
    procedure OptimizarDeterministica;

    procedure CrearYGuardarControladorDeterministicoInicial;

    procedure inicializarArchisOptRes(var fsal: TextFile;
      var fsal_opt: TDAOfTextFile; var fsalopen: boolean);
    procedure escribirPasoOptRes(var fsal: TextFile; var fsal_opt: TDAOfTextFile);
    procedure cerrarArchisOptRes(var fsal: TextFile; var fsal_opt: TDAOfTextFile;
      var fsalopen: boolean);

    {$IFDEF ESTABILIZAR_FRAMEINICIAL}
    procedure EstabilizarFrameInicial;
    {$ENDIF}

    procedure FinOptimizacion;

    //Reordena la lista de fuentes para que si una fuente usa un valor de otra
    //entonces el valor de la otra se calcule antes
    procedure ordenarFuentes;

    procedure Armar_lst_BarridoFijarEstadoDeActoresYFuentesToEstrella;
    procedure Armar_lst_SorteosDelPaso_Actores;

    procedure Armar_lst_opt_PrintResultados;
    procedure Armar_lst_Sim_cronicaIdInicio;

    procedure Armar_lst_Sim_Paso_Fin;
    procedure Armar_lst_CalcularGradienteDeInversion;

    procedure Armar_lst_EvolucionarEstado;
    procedure Armar_lst_costoDirectoDelPaso;




    procedure Armar_lst_necesitoIterar;
    function NecesitoIterar: boolean;

    //      procedure Armar_lst_Encadenamientos;
    procedure PosicionarseEnEstrellita;
    // actualiza el estado Global en el costo futuro.
    // si flg_Xs = TRUE los actores deben usar su proyección del estado para actualizar
    // si flg_Xs = FALSE los actores deben usar su estado actual.
    procedure fuentes_ActualizarEstadoGlobal(flg_Xs: boolean);
    procedure actores_ActualizarEstadoGlobal(flg_Xs: boolean);

    function getNombreVar(ivar: integer): string;
    function getNombreRes(ires: integer): string;
    procedure dump_Variables; overload;
    procedure dump_Variables(archi: string); overload;
    procedure ImprimirPotenciasFirmes;
    procedure ImprimirUnidadesInstaladas;

    //Para debug
    function genStrPasoCronEstrIter: string;//Optimizacion
    function genStrCronPasoIter: string;//Simulacion

    //Funciones para facilitar el calculo por partes de la Optimizacion..
    procedure inicializarOptimizacion_subproc01;

    // Crea prepara los Actores para la Optimización, crea CF y
    // registra los Actores en CF. (no crea la matriz solo lo necesario
    // para el registro de las variables.).
    function Preparar_CrearCF_y_regsitrar_variables_de_estado(
      flg_esclavizarfuentes: boolean = True): integer;

    function inicializarOptimizacion_subproc02(const salaMadre: TSalaDeJuego;
      const costoFuturo: TMatOfNReal): integer;

    function inicializarOptimizacion(const SalaMadre: TSalaDeJuego;
      const costoFuturo: TMatOfNReal): integer;

    procedure OptimizacionCronizada_UnPaso_RangoDeEstrellas(
      estrellaIni, estrellaFin: integer; notificar: boolean;
      printActores_OptRes: boolean);

    procedure OptimizacionValorEsperado_UnPaso_RangoDeEstrellas(
      estrellaIni, estrellaFin: integer; notificar: boolean;
      printActores_OptRes: boolean);

    procedure calcularRangoEstrellas(estrellaIni, estrellaFin: integer;
      notificar, printActoresOptRes: boolean);

    {$IFDEF DUMP_TEXT_OPTRES}
    procedure OptRes_Actores_WriteFecha;
    procedure OptRes_Actores_WriteEstrella;
    procedure OptRes_Actores_WritelnFrame;
    procedure OptRes_CF_WritelnFrame;
    {$ENDIF}

    {$IFDEF opt_Dump_PubliVars}
    procedure printPubliVarsDBG_OPT_MH;
    {$ENDIF}


    //Funciones para obtener o completar un rango del Frame, CF y Auxs
    function getRangoEstrellasCF(estrellaIni, estrellaFin, paso: integer): TDAOfNReal;
    function getRangoEstrellasAux_r1(estrellaIni, estrellaFin: integer): TDAOfDAofNReal;
    function getRangoEstrellasAux_i1(estrellaIni, estrellaFin: integer): TDAOfDAOfNInt;

    procedure setRangoEstrellasCF(estrellaIni: integer;
      tramoCostosFuturo: TDAOfNReal; kpaso: integer);
    procedure setRangoEstrellasAux_r1(estrellaIni: integer; tramoAux_r1: TDAOfDAofNReal);
    procedure setRangoEstrellasAux_i1(estrellaIni: integer; tramoAux_i1: TDAOfDAOfNInt);


    function irAPaso_(nuevoPaso: integer): integer;

    function llenarRangoDeEstrellasYDarPaso(estrellasIni: TDAofNInt;
      costosFuturos: TDAOfDAOfNReal; kpaso: integer): integer;

    procedure darPaso_Opt;
    //   procedure InicializarSimulacion_subproc01(print: boolean);

    {$IFDEF PDE_RIESGO}
    // Si estamos en un entrono MultiHilo, hay una sala que es "La Sala Madre"
    procedure Crear_HistogramasCF(SalaMadre: TSalaDeJuego);
    procedure Liberar_HistogramasCF(SalaMadre: TSalaDeJuego);
    procedure Inicializar_HistogramasCF(CF: TAdminEstados);

    // resume los histogramas de un rango de estrellas.
    procedure Resumir_HistogramaCF0aCF1(kEstrellaIni, kEstrellaFin: integer);

    {$IFDEF DEBUG_HistoCF0CF1}
    // para debug
    procedure Dump_HistogramasCF0CF1(caso: string; kpaso, kEstrella: integer);
    {$ENDIF}
    {$ENDIF}


    // busca en los objetos de la sala.
    // El resultado es NIL si no encontró una cosa con ese nombre.
    // Si el resutlado es <> nil, en (res) se retorna la lista en la que se encontró
    // la cosa (Actores, Fuentes, FuentesRemplazadas, Combustibles, NIL).
    // Si (res) = nil se trata de la pseudo-lista "globs"
    function BuscarPorNombre(const nombre: string;
      var res: TListaDeCosasConNombre): TCosaConNombre;

    function GetActorPorNombre(const nombre: string): TActor;
    function GetFuentePorNombre(const nombre: string): TFuenteAleatoria;
    function GetCombustiblePorNombre(const nombre: string): TCombustible;

    function EjecutarMacro(const macro: WideString): integer;

    procedure RecalibrarPronosticos;

    procedure FinSim_workers;
    function FinSim_Master(Print: boolean): NReal;


    procedure SimPrint_CrearArchivo(var fsal: Textfile;
      id_hilo, kCronicaIni, kCronicaFin: integer);
    procedure SimPrint_Inicio(var f: TextFile);
    procedure SimPrint_EncabezadoDeCronica(var fsal: Textfile);
    procedure SimPrint_ResultadosDelPaso(var fsal: Textfile);
    procedure SimPrint_Final(var f: TextFile);

    procedure Calc_CF_InicioDelPaso(CFAux: TAdminEstados);

    // Fija archiSala y calcula directorios de ejecución
    procedure SetArchiSala(archiSala_: string);

    function Calc_ArchiSR3(NombreEscenario, idPlantilla: string): string;

    procedure AddToCapasLst( capas: TList; padre: TCosa ); override;



  private
    px: TSalaDeJuego_auxRec;
  end;


(* Este procedimiento ejecuta la optimización sobre una Sala previamente cargada
Sin nHilos = 0 entonces se ejecuta MonoHilo.
Si nHilos = -1 se ejecuta MultiHilo con la cantidad de hilos igual a la cantidad
   de núcleos que se detecten en la máquina.
Si nHilos > 0 se ejecuta MultiHilo forzando la cantidad de hilos igual a nHilos.


El parametro nTareas = -1 indica que la cantidad de tareas sea igual a la de hilos
   Al finalizar, se puede consultar el estado de la sala para saber
si la optimización fue exitosa.
  ej.: sala.globs.EstadoDeLaSala <> CES_OPTIMIZACION_ABORTADA

*)
procedure runOptimizar(var sala: TSalaDeJuego; nHilos: integer = -1;
  nTareas: integer = -1; flg_LlenarConFrameFinal: boolean = False);


(*
Llama la simulación. Supone que la Sala está Cargada y que globs.CF también
*)
procedure runSimular(var sala: TSalaDeJuego; nHilos: integer = -1;
  nTareas: integer = -1);


procedure AlInicio;
procedure AlFinal;




implementation

uses
  umh_distribuidor_optsim,
  ucalculador_emisionesco2,
  {$IFDEF ITERADOR_FLUCAR}
  uiteradorflucar,
  {$ENDIF}
  uSustituirVariablesPlantilla,
  uFuenteSintetizador,
  uFuenteConstante;

procedure runOptimizar(var sala: TSalaDeJuego; nHilos: integer = -1;
  nTareas: integer = -1; flg_LlenarConFrameFinal: boolean = False);

var
  GestorMT: TGestorSalaMH;

begin
  (************** OPTIMIZAR **********************)
  setSeparadoresGlobales; // para que escriba en global
  if nHilos <> 0 then
  begin
    GestorMT := TGestorSalaMH.Create(sala);
    GestorMT.nHilosForzados := nHilos;
    GestorMT.nTareasForzadas := nTareas;
    GestorMT.opt_OptimizarMultiCore(nHilos);
    GestorMT.Free;
  end
  else
    sala.Optimizar(flg_llenarConFrameFinal);
  setSeparadoresLocales; // para que escriba en Local
  (***********************************************)
end;



procedure runSimular(var sala: TSalaDeJuego; nHilos: integer = -1;
  nTareas: integer = -1);

var
  GestorMT: TGestorSalaMH;

begin
  if sala.ArchivoCFAux.archi <> '' then
  begin
    sala.CFAux := TAdminEstados.CreateLoadFromArchi(sala.ArchivoCFAux.archi);
    sala.globs.CF.ChequearCompatibilidad_CFAux(sala.CFAux);
  end
  else
    sala.CFAux := nil;

  // !!!!!!!!!!!!! SIMULAR !!!!!!!!!!!!!!!!!!
  setSeparadoresGlobales; // para que escriba en global
  if nHilos <> 0 then
  begin
    GestorMT := TGestorSalaMH.Create(sala);
    GestorMT.nHilosForzados := nHilos;
    GestorMT.nTareasForzadas := nTareas;
    GestorMT.sim_SimularMultiCore(nHilos);
    GestorMT.Free;
  end
  else
    sala.Simular(0, True);

  sala.PreprocesarPlantillasActivasDelEscenarioActivo;
  setSeparadoresLocales;
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  if sala.CFaux <> nil then
    sala.CFAux.Free;
  sala.CFAux := nil;

end;

procedure TSalaDeJuego.RecalibrarPronosticos;
var
  k: integer;
  p: TFuenteAleatoria;
begin
  for k := 0 to ListaFuentes_.Count - 1 do
  begin
    p := TFuenteAleatoria(ListaFuentes_.items[k]);
    if p is TFuenteSintetizadorCEGH then
      if self.globs.EstadoDeLaSala = CES_OPTIMIZANDO then
        TFuenteSintetizadorCEGH(p).recalibrarPronosticos(
          TFuenteSintetizadorCEGH(p).datosModelo_Opt, globs.FechaIniSim)
      else if self.globs.EstadoDeLaSala = CES_SIMULANDO then
        TFuenteSintetizadorCEGH(p).recalibrarPronosticos(
          TFuenteSintetizadorCEGH(p).datosModelo_Sim, globs.FechaIniSim);
  end;
end;


function TSalaDeJuego.GetActorPorNombre(const nombre: string): TActor;
begin
  Result := listaActores.find(nombre) as TActor;
end;

function TSalaDeJuego.GetFuentePorNombre(const nombre: string): TFuenteAleatoria;
begin
  Result := listaFuentes_.find(nombre) as TFuenteAleatoria;
end;

function TSalaDeJuego.GetCombustiblePorNombre(const nombre: string): TCombustible;
begin
  Result := listaCombustibles.find(nombre) as TCombustible;
end;


(*  busca entre los actores, las fuentes y globs  *)
function TSalaDeJuego.BuscarPorNombre(const nombre: string;
  var res: TListaDeCosasConNombre): TCosaConNombre;
var
  cosa: TCosaConNombre;
begin
  Result := nil;


  if LowerCase(nombre) = 'globs' then
  begin
    res := nil;
    Result := globs;
    exit;
  end;

  cosa := listaActores.find(nombre);
  if cosa <> nil then
  begin
    Result := cosa;
    res := listaActores;
    exit;
  end;

  cosa := listaFuentes_.find(nombre);
  if cosa <> nil then
  begin
    Result := cosa;
    res := listaFuentes_;
    exit;
  end;

  cosa := listaFuentesReemplazadas.find(nombre);
  if cosa <> nil then
  begin
    Result := cosa;
    res := listaFuentesReemplazadas;
    exit;
  end;

  cosa := listaCombustibles.find(nombre);
  if cosa <> nil then
  begin
    Result := cosa;
    res := listaCombustibles;
    exit;
  end;

  Result := nil;
end;



function ParametrosToLst(const spars: WideString): TStringList;
var
  i: integer;
  res: TStringList;
  s: WideString;
  r: WideString;
begin
  res := TStringList.Create;
  s := trim(spars);
  i := pos(',', s);

  while (s <> '') and (i > 0) do
  begin
    r := trim(copy(s, 1, i - 1));
    Delete(s, 1, i + 1);
    s := trim(s);
    i := pos(',', s);
    res.Add(r);
  end;
  res.Add(s);
  Result := res;
end;

function TSalaDeJuego.EjecutarMacro(const macro: WideString): integer;
var
  i, k: integer;
  s, st: WideString;
  r: WideString;
  res: integer;
  resOrden: TStringList;
  sentencia_str: string;
  cosa_str: string;
  orden_str: string;
  parametros_str: string;
  iopen_parametros: integer;
  icierre_parametros: integer;
  ipunto: integer;
  cosa: TCosaConNombre;
  lst: TListaDeCosasConNombre;
  lst_parametros: TStringList;
begin

  macro_ordenes.Clear;
  macro_Sel.Clear;

  resOrden := TStringList.Create;

  // Parseamos la macro separando las órdenes
  // y quitando los comentarios.
  s := trim(macro);
  i := pos('#$', s);

  while (s <> '') and (i > 0) do
  begin
    r := trim(copy(s, 1, i - 1));
    Delete(s, 1, i + 1);
    s := trim(s);
    i := pos('#$', s);
    k := pos('//', r);
    if k > 0 then
      r := trim(copy(r, 1, k - 1));

    if r <> '' then
      macro_ordenes.Add(r);
  end;

  if s <> '' then
  begin
    r := s;
    k := pos('//', r);
    if k > 0 then
      r := trim(copy(r, 1, k - 1));

    if r <> '' then
      macro_ordenes.Add(r);
  end;

  macro_errMsg := '';

  res := 0;
  for k := 0 to macro_ordenes.Count - 1 do
  begin
    sentencia_str := macro_ordenes[k];
    cosa_str := '';
    parametros_str := '';
    // parsiamos la órden.   cosa.orden( parametros )
    iopen_parametros := pos('(', sentencia_str);
    if (iopen_parametros > 0) then
    begin
      cosa_str := trim(copy(sentencia_str, 1, iopen_parametros - 1));

      ipunto := pos('.', cosa_str);
      if (ipunto > 0) then
      begin
        orden_str := trim(copy(cosa_str, 1, ipunto - 1));
        Delete(cosa_str, 1, ipunto);
        cosa_str := trim(cosa_str);
      end
      else
      begin
        orden_str := cosa_str;
        cosa_str := '';
      end;

      icierre_parametros := pos(')', sentencia_str);
      if (icierre_parametros > iopen_parametros) then
      begin
        parametros_str := trim(copy(sentencia_str, iopen_parametros +
          1, (icierre_parametros - iopen_parametros - 1)));
      end
      else
      begin
        macro_errMsg := 'Error, orden mal formada! (k)' + IntToStr(
          k) + #10#13 + sentencia_str;
        Result := -1;
        exit;
      end;
    end;

    lst_parametros := ParametrosToLst(parametros_str);
    if cosa_str = '' then
      resOrden := EjecutarSentencia(orden_str, lst_parametros)
    else
    begin
      cosa := BuscarPorNombre(cosa_str, lst);
      if cosa <> nil then
        resOrden := cosa.EjecutarSentencia(orden_str, lst_parametros);
    end;

    st := resOrden[0];
    if pos('+ERROR', st) > 0 then
    begin
      macro_errMsg := macro_errMsg + 'Error al ejecutar oden: (' + IntToStr(k) + ') ';
      for i := 0 to resOrden.Count - 1 do
        macro_errMsg := macro_errMsg + #13#10 + resOrden[i];
      break; // paramos en la primer orden que falle
    end;
  end;
  Result := res;
end;



constructor TSalaDeJuego.Create(capa: integer; nombre: string;
  fechaIniSim, fechaFinSim, fechaGuardaSim, fechaIniOpt, fechaFinOpt: TFecha;
  DurPos: TDAOfNReal);
begin
  inherited Create(capa, nombre);
  // Por ahora sin catalogo de referencias, esto impide que se
  // utilice el mecanismo de evaluación en las referencias.
  Evaluador := TEvaluadorConCatalogo.Create(nil);
  salaMadre := nil;

  self.Globs := TGlobs.Create('globs', 0, fechaIniSim, fechaFinSim,
    fechaGuardaSim, fechaIniOpt, fechaFinOpt, DurPos);
  self.gens := TListaDeCosasConNombre.Create(capa, 'gens');
  self.dems := TListaDeCosasConNombre.Create(capa, 'dems');
  self.Sums := TListaDeCosasConNombre.Create(capa, 'Suministros Combustible');
  self.nods := TListaDeCosasConNombre.Create(capa, 'nods');
  self.arcs := TListaDeCosasConNombre.Create(capa, 'arcs');
  self.comercioInternacional :=
    TListaDeCosasConNombre.Create(capa, 'ComercioInternacional');
  self.UsosGestionables := TListaDeCosasConNombre.Create(capa, 'usos_gestionables');

  listaActores := TListaDeCosasConNombre.Create(capa, 'Lista de Actores');

  listaFuentes_ := TListFuenteAleatoria.Create(capa, 'listaFuentes');
  listaFuentes_A := TListFuenteAleatoria.Create(capa, 'listaFuentes_A');
  listaFuentes_B := TListFuenteAleatoria.Create(capa, 'listaFuentes_B');

  listaFuentesReemplazadas := TListaDeCosasConNombre.Create(capa, 'FuentesReemplazadas');
  listaCombustibles := TListaDeCosasConNombre.Create(capa, 'Combustibles');

  enganchesContinuos := TListaDeCosas.Create(capa, 'enganchesContinuos');
  enganchesDiscretos := TListaDeCosas.Create(capa, 'enganchesDiscretos');
  enganchar_promediando_desaparecidas := False;

  uniformizar_promediando := '';

  flg_usar_enganche_mapeo := False;
  flg_IncluirPagosPotenciaYEnergiaEn_CF := False;
  enganche_mapeo := '';

  spx := nil;
  dirResultadosCorrida := getDir_Run;

  estabilizarInicio := False;
  usarArchivoParaInicializarFrameInicial := 0;
  GenerarRaws := False;
  usarIteradorFlucar := False;

  archivoCFAux := TArchiRef.Create('');
  archivoCF_ParaEnganches := TArchiRef.Create('');
  archivoSala_ParaEnganches := TArchiRef.Create('');

  listaPlantillasSimRes3 := TListaPlantillasSimRes3.Create(capa, 'PlantillasSimRes3');
  Escenarios := TListaEscenarios.Create('Escenarios');
  EscenarioActivo := Escenarios.items[0] as TEscenario_rec;

  self.escribirOptActores := False;

  RandSeed_SincronizarAlInicioDeCadaCronica := True;
  globs.idHilo := 0;
  // por defecto. Si Está en ambiento MultiHilo se encargan de ponerle el id.

  macro_ordenes := TStringList.Create;
  macro_errMsg := '';
  macro_Sel := TListaDeCosasConNombre.Create(capa, 'macro_Sel');

  flg_MemoriaPreparada := False;
  devaluar;
end;

function TSalaDeJuego.Rec: TCosa_RecLnk;
begin
  Result := inherited Rec;


  // 0<= Version < 4
  Result.addCampoDef('descripcion', descripcion, 0, 4);
  Result.addCampoDef('globs', TCosa(self.globs), 0, 4);
  Result.addCampoDef('gens', TCosa(self.gens), 0, 4);
  Result.addCampoDef('dems', TCosa(self.dems), 0, 4);
  Result.addCampoDef('nods', TCosa(self.nods), 0, 4);
  Result.addCampoDef('arcs', TCosa(self.arcs), 0, 4);
  Result.addCampoDef('spots', TCosa(self.comercioInternacional), 0, 4);
  Result.addCampoDef('listaFuentes', TCosa(listaFuentes_), 0, 4);
  Result.addCampoDef('funcs', TCosa(px.funcsBasura), 0, 4);
  Result.addCampoDef('estabilizarInicio', estabilizarInicio, 0, 4);

  Result.addCampoDef('usarArchivoParaInicializarFrameInicial',
    usarArchivoParaInicializarFrameInicial, 0, 4);
  Result.addCampoDef_archRef('archivoCF', archivoCF_ParaEnganches, 0, 4);
  Result.addCampoDef('enganchesContinuos', TCosa(enganchesContinuos), 0, 4);
  Result.addCampoDef('enganchesDiscretos', TCosa(enganchesDiscretos), 0, 4);


  // 4 <= Version < 9
  Result.addCampoDef('descripcion', descripcion, 4, 9);
  Result.addCampoDef('globs', TCosa(self.globs), 4, 9);
  Result.addCampoDef('gens', TCosa(self.gens), 4, 9);
  Result.addCampoDef('dems', TCosa(self.dems), 4, 9);
  Result.addCampoDef('nods', TCosa(self.nods), 4, 9);
  Result.addCampoDef('arcs', TCosa(self.arcs), 4, 9);
  Result.addCampoDef('ComercioInternacional', TCosa(comercioInternacional), 4, 9);
  Result.addCampoDef('listaFuentes', TCosa(listaFuentes_), 4, 9);
  Result.addCampoDef('funcs', TCosa(px.funcsBasura), 4, 9);
  Result.addCampoDef('estabilizarInicio', estabilizarInicio, 4, 9);
  Result.addCampoDef('usarArchivoParaInicializarFrameInicial',
    usarArchivoParaInicializarFrameInicial, 4, 9);
  Result.addCampoDef_archRef('archivoCF', archivoCF_ParaEnganches, 4, 9);
  Result.addCampoDef('enganchesContinuos', TCosa(enganchesContinuos), 4, 9);
  Result.addCampoDef('enganchesDiscretos', TCosa(enganchesDiscretos), 4, 9);


  // 9 <= version
  Result.addCampoDef('descripcion', descripcion, 9);
  Result.addCampoDef('globs', TCosa(self.globs), 9);
  Result.addCampoDef('gens', TCosa(self.gens), 9);
  Result.addCampoDef('dems', TCosa(self.dems), 9);
  Result.addCampoDef('sums', TCosa(self.sums), 73);
  Result.addCampoDef('nods', TCosa(self.nods), 9);
  Result.addCampoDef('arcs', TCosa(self.arcs), 9);
  Result.addCampoDef('ComercioInternacional', TCosa(self.comercioInternacional), 9);
  Result.addCampoDef('UsosGestionables', TCosa(UsosGestionables), 79);
  Result.addCampoDef('listaFuentes', TCosa(listaFuentes_), 9);
  Result.addCampoDef('estabilizarInicio', estabilizarInicio, 9);
  Result.addCampoDef('RandSeed_SincronizarAlInicioDeCadaCronica',
    RandSeed_SincronizarAlInicioDeCadaCronica, 99);
  Result.addCampoDef('usarArchivoParaInicializarFrameInicial',
    usarArchivoParaInicializarFrameInicial, 9);
  Result.addCampoDef_archRef('archivoCF', archivoCF_ParaEnganches, 9, 46);
  Result.addCampoDef_archRef('archivoCF_ParaEnganches', archivoCF_ParaEnganches, 46);
  Result.addCampoDef_archRef('archivoSala_ParaEnganches',
    archivoSala_ParaEnganches, 46);
  Result.addCampoDef('engancharConSala', engancharConSala, 46);
  Result.addCampoDef('engancharConSala_escenario', engancharConSala_escenario, 95);
  Result.addCampoDef_archRef('archivoCFaux', archivoCFaux, 33);
  Result.addCampoDef('enganchesContinuos', TCosa(enganchesContinuos), 9);
  Result.addCampoDef('enganchesDiscretos', TCosa(enganchesDiscretos), 9);
  Result.addCampoDef('enganchar_promediando_desaparecidas',
    enganchar_promediando_desaparecidas, 64);
  Result.addCampoDef('uniformizar_promediando', uniformizar_promediando, 65);
  Result.addCampoDef('flg_usar_enganche_mapeo', flg_usar_enganche_mapeo, 145);
  Result.addCampoDef('enganche_mapeo', enganche_mapeo, 145);
  Result.addCampoDef('flg_IncluirPagosPotenciaYEnergiaEn_CF',
    flg_IncluirPagosPotenciaYEnergiaEn_CF, 146, 0, 'T');
  Result.addCampoDef('Combustibles', TCosa(listaCombustibles), 54);
  Result.addCampoDef('usarIteradorFlucar', usarITeradorFlucar, 79);
  Result.addCampoDef('GenerarRaws', GenerarRaws, 81);
  Result.addCampoDef('PlantillasSimRes3', TCosa(listaPlantillasSimRes3), 75);
  Result.addCampoDef('Escenarios', TCosa(Escenarios), 92);
  Result.addCampoDef('EscenarioActivo', nombre_EscenarioActivo, 93);
  Result.addCampoDef('modo_Ejecucion', modo_Ejecucion, 154, 0, '0');
  Result.addCampoDef('flg_ImprimirArchivos_Estado_Fin_Cron',
    flg_ImprimirArchivos_Estado_Fin_Cron, 130);

end;

procedure TSalaDeJuego.SetArchiSala(archiSala_: string);
var
  pal: string;
  i: integer;
begin
  self.archiSala_ := archiSala_;
  pal := SysUtils.ExtractFileName(archiSala_);
  i := pos('.', pal);
  if i > 0 then
    Delete(pal, i, length(pal) - i + 1);
  if uConstantesSimSEE.tmp_rundir = '' then
    dirResultadosCorrida := getDir_Run + pal + DirectorySeparator
  else
  if tmp_rundir[Length(tmp_rundir)] = DirectorySeparator then
    dirResultadosCorrida := tmp_rundir
  else
    dirResultadosCorrida := tmp_rundir + DirectorySeparator;
end;

function TSalaDeJuego.Calc_ArchiSR3( NombreEscenario, idPlantilla: string ): string;
begin
  result:= dirResultadosCorrida
          + nombreArchSinExtension(archiSala_)+'_'+NombreEscenario+'_'+idPlantilla + '.txt';

end;

procedure TSalaDeJuego.AddToCapasLst(capas: TList; padre: TCosa);
var
  k: integer;
begin

//  globs.AddToCapasLst( capas );

  for k:= 0 to listaFuentes_.count-1 do
    TCosa( listaFuentes_[k] ).AddToCapasLst( capas, self );

  for k:= 0 to listaCombustibles.Count -1 do
    TCosa( listaCombustibles[k]  ).AddToCapasLst( capas, self );

  for k:= 0 to listaPlantillasSimRes3.Count-1 do
    TCosa( listaPlantillasSimRes3[k] ).AddToCapasLst( capas, self );

  for k:= 0 to ListaActores.Count-1 do
    TCosa( listaActores[k] ).AddToCapasLst( capas, self );

end;

procedure TSalaDeJuego.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);

  px := TSalaDeJuego_auxRec.Create;

  salaMadre := nil;
  flg_MemoriaPreparada := False;
  UsosGestionables := nil;
  RandSeed_SincronizarAlInicioDeCadaCronica := True;
  estabilizarInicio := False;
  usarArchivoParaInicializarFrameInicial := 0;
  spx := nil;
  archivoCF_ParaEnganches := TArchiRef.Create('');
  usarIteradorFlucar := False;
  GenerarRaws := False;
  if Version < 33 then
    archivoCFAux := TArchiRef.Create('');

  self.escribirOptActores := False;

end;

procedure TSalaDeJuego.AfterRead(version, id_hilo: integer);
var
  i, k: integer;
begin
  inherited AfterRead(version, id_hilo);

  if Version < 4 then
  begin
    Sums := TListaDeCosasConNombre.Create(self.capa, 'Suministros Combustible');
    spx := nil;
    if self.globs = nil then
    begin
      SetLength(px.durPosAux, 1);
      self.globs := TGlobs.Create('globs', id_Hilo, TFecha.Create_Dt(0),
        TFecha.Create_Dt(0), TFecha.Create_Dt(0), TFecha.Create_Dt(0),
        TFecha.Create_Dt(0), px.durPosAux);
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudieron leer las variables globales. Asignando valores por defecto.');
    end;
    if self.gens = nil then
    begin
      self.gens := TListaDeCosasConNombre.Create(self.capa, 'gens');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de generadores. Asignando la lista vacía.');
    end;
    if self.nods = nil then
    begin
      self.nods := TListaDeCosasConNombre.Create(capa, 'nods');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de nodos. Asignando la lista vacía.');
    end;
    if self.dems = nil then
    begin
      self.dems := TListaDeCosasConNombre.Create(capa, 'dems');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de demandas. Asignando la lista vacía.');
    end;

    if sums = nil then
    begin
      Sums := TListaDeCosasConNombre.Create(capa, 'Suministros Combustible');
    end;

    if self.arcs = nil then
    begin
      self.arcs := TListaDeCosasConNombre.Create(capa, 'arcs');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de arcos. Asignando la lista vacía.');
    end;

    if self.comercioInternacional = nil then
    begin
      self.comercioInternacional :=
        TListaDeCosasConNombre.Create(capa, 'Comercio Internacional');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de spots de mercado. Asignando la lista vacía.');
    end;


    if listaFuentes_ = nil then
    begin
      listaFuentes_ := TListaDeCosasConNombre.Create(capa, 'fuentes');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de fuentes. Asignando la lista vacía.');
    end;
    listaFuentes_A := TListaDeCosasConNombre.Create(capa, 'fuentes_A');
    listaFuentes_B := TListaDeCosasConNombre.Create(capa, 'fuentes_B');

    if enganchesContinuos = nil then
    begin
      enganchesContinuos := TListaDeCosas.Create(capa, 'EnganchesContinuos');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de Enganches Continuos. Asignando la lista vacía.');
    end;
    if enganchesDiscretos = nil then
    begin
      enganchesDiscretos := TListaDeCosas.Create(capa, 'EnganchesDiscretos');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de Enganches Discretos. Asignando la lista vacía.');
    end;

    listaActores := TListaDeCosasConNombre.Create(capa, 'Lista de Actores');
    listaActores.Capacity :=
      self.gens.Count + self.dems.Count + self.sums.Count +
      self.nods.Count + self.arcs.Count;

    for i := 0 to self.nods.Count - 1 do
      listaActores.Add(self.nods[i] as TNodo);

    for i := 0 to self.dems.Count - 1 do
      listaActores.Add(self.dems[i] as TDemanda);

    // atención los suministros están agregados antes de lso generadores
    for i := 0 to self.sums.Count - 1 do
      listaActores.Add(TCosaConNombre(sums[i]));

    for i := 0 to self.gens.Count - 1 do
      listaActores.Add(self.gens[i] as TGenerador);
    for i := 0 to self.arcs.Count - 1 do
      listaActores.Add(self.arcs[i] as TArco);

    for i := 0 to comercioInternacional.Count - 1 do
      listaActores.Add(comercioInternacional[i] as TComercioInternacional);
    if px.funcsBasura <> nil then
      px.funcsBasura.Free;
    listaFuentesReemplazadas :=
      TListaDeCosasConNombre.Create(capa, 'FuentesReemplazadas');
  end
  else if Version < 9 then
  begin

    self.sums := TListaDeCosasConNombre.Create(capa, 'Suministros Combustible');
    spx := nil;

    if globs = nil then
    begin
      SetLength(px.durPosAux, 1);
      self.globs := TGlobs.Create('globs', id_Hilo, TFecha.Create_Dt(0),
        TFecha.Create_Dt(0), TFecha.Create_Dt(0), TFecha.Create_Dt(0),
        TFecha.Create_Dt(0), px.durPosAux);
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudieron leer las variables globales. Asignando valores por defecto.');
    end;
    if self.gens = nil then
    begin
      self.gens := TListaDeCosasConNombre.Create(capa, 'gens');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de generadores. Asignando la lista vacía.');
    end;
    if self.nods = nil then
    begin
      self.nods := TListaDeCosasConNombre.Create(capa, 'nods');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de nodos. Asignando la lista vacía.');
    end;
    if self.dems = nil then
    begin
      self.dems := TListaDeCosasConNombre.Create(capa, 'dems');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de demandas. Asignando la lista vacía.');
    end;
    if self.arcs = nil then
    begin
      self.arcs := TListaDeCosasConNombre.Create(capa, 'arcs');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de arcos. Asignando la lista vacía.');
    end;
    if comercioInternacional = nil then
    begin
      comercioInternacional :=
        TListaDeCosasConNombre.Create(capa, 'Comercio Internacional');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de spots de mercado. Asignando la lista vacía.');
    end;

    if listaFuentes_ = nil then
    begin
      listaFuentes_ := TListaDeCosasConNombre.Create(capa, 'fuentes');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de fuentes. Asignando la lista vacía.');
    end;
    listaFuentes_A := TListaDeCosasConNombre.Create(capa, 'fuentes_A');
    listaFuentes_B := TListaDeCosasConNombre.Create(capa, 'fuentes_B');


    if enganchesContinuos = nil then
    begin
      enganchesContinuos := TListaDeCosas.Create(capa, 'EnganchesContinuos');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de Enganches Continuos. Asignando la lista vacía.');
    end;
    if enganchesDiscretos = nil then
    begin
      enganchesDiscretos := TListaDeCosas.Create(capa, 'EnganchesDiscretos');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de Enganches Discretos. Asignando la lista vacía.');
    end;

    listaActores := TListaDeCosasConNombre.Create(capa, 'Lista de Actores');
    listaActores.Capacity :=
      self.gens.Count + self.dems.Count + self.nods.Count +
      self.arcs.Count + comercioInternacional.Count;

    for i := 0 to self.nods.Count - 1 do
      listaActores.Add(self.nods[i] as TNodo);
    for i := 0 to self.dems.Count - 1 do
      listaActores.Add(self.dems[i] as TDemanda);
    for i := 0 to self.gens.Count - 1 do
      listaActores.Add(self.gens[i] as TGenerador);
    for i := 0 to self.arcs.Count - 1 do
      listaActores.Add(self.arcs[i] as TArco);
    for i := 0 to self.comercioInternacional.Count - 1 do
      listaActores.Add(self.comercioInternacional[i] as TComercioInternacional);

    if px.funcsBasura <> nil then
      px.funcsBasura.Free;
    listaFuentesReemplazadas :=
      TListaDeCosasConNombre.Create(capa, 'FuentesReemplazadas');
  end
  else
  begin
    if Version < 73 then
      self.sums := TListaDeCosasConNombre.Create(capa, 'sums');

    if Version < 79 then
      UsosGestionables := TListaDeCosasConNombre.Create(capa, 'UsosGestionables');

    if Version < 99 then
      RandSeed_SincronizarAlInicioDeCadaCronica := True;


    if version < 145 then
    begin
      flg_usar_enganche_mapeo := False;
      enganche_mapeo := '';
    end;
    if (version < 54) then
      listaCombustibles := TListaDeCosasConNombre.Create(capa, 'Combusitbles');
    if (version < 75) then
      listaPlantillasSimRes3 :=
        TListaPlantillasSimRes3.Create(capa, 'PlantillasSimRes3');

    if (version < 92) then
      Escenarios := TListaEscenarios.Create('Escenarios');

    if (version < 93) then
      nombre_EscenarioActivo := '??';

    if Escenarios = nil then
    begin
      Escenarios := TListaEscenarios.Create('Escenarios');
      EscenarioActivo := Escenarios[0] as TEscenario_rec;
    end;

    if nombre_EscenarioActivo = '??' then
      EscenarioActivo := Escenarios[0] as TEscenario_rec
    else
    begin
      EscenarioActivo := Escenarios.find(nombre_EscenarioActivo) as TEscenario_rec;
      if EscenarioActivo = nil then
        EscenarioActivo := Escenarios[0] as TEscenario_rec;
    end;

    spx := nil;
    if listaPlantillasSimRes3 = nil then
      listaPlantillasSimRes3 :=
        TListaPlantillasSimRes3.Create(capa, 'PlantillasSimRes3');


    if globs = nil then
    begin
      SetLength(px.durPosAux, 1);
      globs := TGlobs.Create('globs', id_Hilo, TFecha.Create_Dt(0),
        TFecha.Create_Dt(0), TFecha.Create_Dt(0), TFecha.Create_Dt(0),
        TFecha.Create_Dt(0), px.durPosAux);
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudieron leer las variables globales. Asignando valores por defecto.');
    end;
    if self.gens = nil then
    begin
      self.gens := TListaDeCosasConNombre.Create(capa, 'gens');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de generadores. Asignando la lista vacía.');
    end;

    if self.nods = nil then
    begin
      self.nods := TListaDeCosasConNombre.Create(capa, 'nods');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de nodos. Asignando la lista vacía.');
    end;
    if self.dems = nil then
    begin
      self.dems := TListaDeCosasConNombre.Create(capa, 'dems');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de demandas. Asignando la lista vacía.');
    end;


    if self.sums = nil then
    begin
      self.sums := TListaDeCosasConNombre.Create(capa, 'sums');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de suministros de combustible. Asignando la lista vacía.');
    end;

    if self.arcs = nil then
    begin
      self.arcs := TListaDeCosasConNombre.Create(capa, 'arcs');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de arcos. Asignando la lista vacía.');
    end;

    if self.comercioInternacional = nil then
    begin
      self.comercioInternacional :=
        TListaDeCosasConNombre.Create(capa, 'Comercio Internacional');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de spots de mercado. Asignando la lista vacía.');
    end;

    if UsosGestionables = nil then
    begin
      UsosGestionables := TListaDeCosasConNombre.Create(capa, 'UsosGestionables');
      //      ucosa.procMsgErrorLectura( ' Advertencia: no se leyo lista de usos gestionables. Asignando la lista vacía.' );
    end;

    if listaFuentes_ = nil then
    begin
      listaFuentes_ := TListaDeCosasConNombre.Create(capa, 'fuentes');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de fuentes. Asignando la lista vacía.');
    end;
    listaFuentes_A := TListaDeCosasConNombre.Create(capa, 'fuentes_A');
    listaFuentes_B := TListaDeCosasConNombre.Create(capa, 'fuentes_B');

    if enganchesContinuos = nil then
    begin
      enganchesContinuos := TListaDeCosas.Create(capa, 'EnganchesContinuos');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de Enganches Continuos. Asignando la lista vacía.');
    end;
    if enganchesDiscretos = nil then
    begin
      enganchesDiscretos := TListaDeCosas.Create(capa, 'EnganchesDiscretos');
      ucosa.procMsgErrorLectura(
        'Advertencia: no se pudo leer la lista de Enganches Discretos. Asignando la lista vacía.');
    end;

    listaActores := TListaDeCosasConNombre.Create(capa, 'Lista de Actores');
    listaActores.Capacity :=
      self.gens.Count + self.dems.Count + self.nods.Count +
      self.arcs.Count + self.comercioInternacional.Count;

        {$IFDEF VERBOSO}
    writeln('Agregando NODOS');
    for i := 0 to nods.Count - 1 do
    begin
      writeln('i: ', i, ', Nodo: ', nods[i].Apodo);
      listaActores.Add(nods[i] as TNodo);
    end;

    writeln('Agregando DEMANDAS');
    for i := 0 to dems.Count - 1 do
    begin
      writeln('i: ', i, ', Dems: ', dems[i].Apodo);
      listaActores.Add(dems[i] as TDemanda);
    end;

    writeln('Agregando SUMINISTROS_COMBUSTIBLES');
    for i := 0 to sums.Count - 1 do
    begin
      writeln('i: ', i, ', SumComb: ', sums[i].Apodo);
      listaActores.Add(TCosaConNombre(sums[i]));
    end;

    writeln('Agregando GENERADORES');
    for i := 0 to gens.Count - 1 do
    begin
      writeln('i: ', i, ', gens: ', gens[i].Apodo);
      listaActores.Add(gens[i] as TGenerador);
    end;

    writeln('Agregando ARCOS');
    for i := 0 to arcs.Count - 1 do
    begin
      writeln('i: ', i, ', Arcs: ', arcs[i].Apodo);
      listaActores.Add(arcs[i] as TArco);
    end;

    writeln('Agregando COMERCIO INTERNACIONAL');
    for i := 0 to comercioInternacional.Count - 1 do
    begin
      writeln('i: ', i, ', ComInt: ', comercioInternacional[i].Apodo);
      listaActores.Add(comercioInternacional[i] as TComercioInternacional);
    end;

    writeln('Agregando Usos Gestionables');
    for i := 0 to UsosGestionables.Count - 1 do
    begin
      writeln('i: ', i, ', Uso Gest.: ', UsosGestionables[i].Apodo);
      listaActores.Add(UsosGestionables[i] as TUsoGestionable_postizado);
    end;

        {$ELSE}

    for i := 0 to self.nods.Count - 1 do
      listaActores.Add(self.nods[i] as TNodo);

    for i := 0 to self.dems.Count - 1 do
      listaActores.Add(self.dems[i] as TDemanda);

    for i := 0 to self.sums.Count - 1 do
      listaActores.Add(self.sums[i] as TActor);


    for i := 0 to self.gens.Count - 1 do
      listaActores.Add(self.gens[i] as TGenerador);

    for i := 0 to self.arcs.Count - 1 do
      listaActores.Add(self.arcs[i] as TArco);

    for i := 0 to self.ComercioInternacional.Count - 1 do
      listaActores.Add(self.ComercioInternacional[i] as TComercioInternacional);

    for i := 0 to UsosGestionables.Count - 1 do
      listaActores.Add(UsosGestionables[i] as TUsoGestionable_postizado);
        {$ENDIF}

    listaFuentesReemplazadas :=
      TListaDeCosasConNombre.Create(capa, 'FuentesReemplazadas');

  end;

  macro_ordenes := TStringList.Create;
  macro_errMsg := '';
  macro_Sel := TListaDeCosasConNombre.Create(capa, 'macro_Sel');

  px.Free;
end;



function TSalaDeJuego.ArchiCF_bin(escenario: string = '__principal__'): string;
begin
  if escenario = '__principal__' then
    escenario := EscenarioActivo.nombre;
  Result := dirResultadosCorrida + 'CF_' + Escenario + '.bin';
end;


function TSalaDeJuego.CargarCFFrom_bin(flg_FreeIfNotNil: boolean = True): boolean;
begin
  try
    if flg_FreeIfNotNil and (globs.CF <> nil) then
      globs.CF.Free;
    globs.CF := TAdminEstados.CreateLoadFromArchi(ArchiCF_bin(EscenarioActivo.nombre));
    Result := True
  except
    Result := False;
  end;

end;


constructor TSalaDeJuego.cargarSala(idHilo: integer;
  archiSala, nombre_escenario_activar: string; abortarEnError: boolean
  // ; rama: string = ''; capas: string = ''
  );
var
  f: TArchiTexto;
  aux: TListaDeCosasConNombre;
  old_dir: string;
  CatalogoReferencias: TCatalogoReferencias;

begin
  evaluador := nil;
  salaMadre := nil;
  old_dir := '';

  if FileExists(archiSala) then
  begin
    // Por ahora sin catalogo de referencias, esto impide que se
    // utilice el mecanismo de evaluación en las referencias.
    Evaluador := TEvaluadorConCatalogo.Create(nil);

    CatalogoReferencias := TCatalogoReferencias.Create;

    f := TArchiTexto.CreateForRead(idHilo, CatalogoReferencias,
      archiSala, abortarEnError);
    aux := TListaDeCosasConNombre.Create(0, 'aux');
    dirSala := ExtractFileDir(archiSala);
    getdir(0, old_dir);
    chdir(dirSala);
    try
      f.rd('sala', TCosa(self));
      f.Free;
      f := nil;

      setArchiSala(archiSala);

      chdir(old_dir);
      //Resolver referencias
      if CatalogoReferencias.referenciasSinResolver > 0 then
      begin
        aux.Add(globs);
        CatalogoReferencias.resolver_referencias(aux);
        CatalogoReferencias.resolver_referencias(listaActores);
        CatalogoReferencias.resolver_referencias(listaFuentes_);
        CatalogoReferencias.resolver_referencias(listaCombustibles);
        aux.FreeSinElemenentos;
        aux := nil;
      end;
      if CatalogoReferencias.referenciasSinResolver > 0 then
      begin
        CatalogoReferencias.DumpReferencias('errRefs.txt');
        raise Exception.Create(
          'TSalaDeJuego.cargarSala: Quedaron Referencias Sin Resolver Cargando la Sala. Puede Ver Que Referencias No Se Resolvieron En: '
          + 'errRefs.txt');
      end;
      CatalogoReferencias.Free;
      self.setDirCorrida(archiSala);
      globs.idHilo := 0;
      if nombre_escenario_activar <> '' then
      begin
        if nombre_escenario_activar = '__principal__' then
          nombre_escenario_activar := EscenarioActivo.nombre;
        ActivarEscenario(nombre_escenario_activar);
      end;
    except
      if old_dir <> '' then
        chdir(old_dir);
      if aux <> nil then
        aux.Free;
      if f <> nil then
        f.Free;
      raise;
    end;
  end
  else
    raise Exception.Create('TSalaDeJuego.cargarSala: no se encuentra el archivo ' +
      archiSala);
end;


procedure TSalaDeJuego.Free;
begin

  {$IFDEF DEBUG_MULTI_HILO}
  writeln(fdebug_mh, 'Free: ' + DateTimeToStr(now()));
  closefile(fdebug_mh);
  {$ENDIF}

  gens.Free;
  self.dems.Free;
  Sums.Free;
  nods.Free;
  arcs.Free;

  self.comercioInternacional.Free;
  listaActores.FreeSinElemenentos;
  listaFuentes_.Free;
  listaFuentes_A.clear;
  listaFuentes_B.clear;
  listaFuentes_A.Free;
  listaFuentes_B.Free;

  listaFuentesReemplazadas.FreeSinElemenentos;

  if listaCombustibles <> nil then
    listaCombustibles.Free;

  if SalaMadre = nil then
    if listaPlantillasSimRes3 <> nil then
      listaPlantillasSimRes3.Free;

  if lst_barridoFijarEstadoDeActoresToEstrella <> nil then
    lst_barridoFijarEstadoDeActoresToEstrella.Free;
  if lst_barridoFijarEstadoDeFuentesToEstrella <> nil then
    lst_barridoFijarEstadoDeFuentesToEstrella.Free;
  if lst_opt_PrintResultados <> nil then
    lst_opt_PrintResultados.Free;
  if lst_Sim_cronicaIdInicio <> nil then
    lst_Sim_cronicaIdInicio.Free;

  if lst_actores_evolucionarEstado <> nil then
    lst_actores_evolucionarEstado.Free;

  if lst_fuentes_evolucionarEstado <> nil then
    lst_fuentes_evolucionarEstado.Free;


  if lst_NecesitoIterar <> nil then
    lst_NecesitoIterar.Free;

{$IFDEF ITERADOR_FLUCAR}
  if lst_NecesitoIterar <> nil then
    IteradorFlucar.Free;
{$ENDIF}


(*
  if lst_actores_costoDirectoDelPaso <> NIL then
    lst_actores_costoDirectoDelPaso.Free;
  *)
  if lst_fuentes_costoDirectoDelPaso <> nil then
    lst_fuentes_costoDirectoDelPaso.Free;

  if lst_Sim_Paso_Fin <> nil then
    lst_Sim_Paso_Fin.Free;

  if lst_CalcularGradienteDeInviersion <> nil then
    lst_CalcularGradienteDeInviersion.Free;
  if spx <> nil then
    spx.Free;
  Globs.Free;
  SetLength(actores, 0);
  SetLength(fuentes, 0);
  SetLength(hidraulicos, 0);
  SetLength(termicos, 0);
  //  SetLength(combustibles, 0);

  if enganchesContinuos <> nil then
    enganchesContinuos.Free;
  if enganchesDiscretos <> nil then
    enganchesDiscretos.Free;

  if archivoCFAux <> nil then
    archivoCFAux.Free;
  if archivoCF_ParaEnganches <> nil then
    archivoCF_ParaEnganches.Free;
  if archivoSala_ParaEnganches <> nil then
    archivoSala_ParaEnganches.Free;

  if Evaluador <> nil then
    Evaluador.Free;
  inherited Free;
end;

procedure TSalaDeJuego.PubliVars;
begin
  inherited PubliVars;
  PublicarVariableNR('CF_AlInicioDelPaso', '[USD]', 12, 1, CF_AlInicioDelPaso, True);
  PublicarVariableNR('CFaux', '[USD]', 12, 1, CFaux_AlInicioDelPaso,
    ArchivoCFAux.archi <> '');
  PublicarVariableNR('CPSimplex', '[USD]', 12, 1, costoDelPaso_spx, True);
  PublicarVariableNR('CPDirecto', '[USD]', 12, 1, costoDirectoDelPaso, True);
  PublicarVariableNR('CPOperativo', '[USD]', 12, 1, costoOperativoDelPaso, True);
  PublicarVariableNR('UPDirectA', '[USD]', 12, 1, utilidadDirectaDelPaso, True);
  PublicarVariableNR('PagosPorDisponibilidadDelPaso', '[USD]', 12,
    1, PagosPorDisponibilidadDelPaso, True);
  PublicarVariableNR('PagosAdicionalesPorEnergiaDelPaso', '[USD]',
    12, 1, PagosAdicionalesPorEnergiaDelPaso, True);
end;

procedure TSalaDeJuego.setDirCorrida(archivoSala: string);
var
  nombreSala: string;
begin
  self.archiSala_ := archivoSala;
  dirSala := extractFilePath(archivoSala);
  nombreSala := ExtractFileName(archivoSala);
  nombreSala := ChangeFileExt(nombreSala, '');
  if tmp_rundir = '' then
    dirResultadosCorrida := getDir_Run + LowerCase(nombreSala) + DirectorySeparator
  else
  if tmp_rundir[Length(tmp_rundir)] = DirectorySeparator then
    dirResultadosCorrida := tmp_rundir
  else
    dirResultadosCorrida := tmp_rundir + DirectorySeparator;
end;


procedure TSalaDeJuego.ActivarEscenario(nombreEscenario: string);
var
  ea: TEscenario_rec;

begin
  ea := Escenarios.find(nombreEscenario) as TEscenario_rec;
  if ea = nil then
    raise Exception.Create('ActivarEscenario. ERROR: no se encuentra el escenario: ' +
      nombreEscenario);

  EscenarioActivo := ea;
  globs.EscenarioActivo := ea;
  // Ahora recorremos las fuentes y los actores, las filtramos y si
  // pasan el filtro les pedimos que filtren sus fichas de parámetros
  // para el escenario activo.
  listaFuentes_.ActivarCapas(ea.capasActivas);
  listaActores.ActivarCapas(ea.CapasActivas);
  listaCombustibles.ActivarCapas(ea.CapasActivas);
end;

procedure TSalaDeJuego.AgregarDefinicionesEvaluador(
  Evaluador: TEvaluadorExpresionesSimples);
var
  k: integer;
begin
  inherited AgregarDefinicionesEvaluador(Evaluador);
  for k := 0 to high(actores) do
    actores[k].AgregarDefinicionesEvaluador(Evaluador);
  for k := 0 to high(fuentes) do
    fuentes[k].AgregarDefinicionesEvaluador(Evaluador);
end;

procedure TSalaDeJuego.PrepararMemoriaYListados(flg_esclavizarfuentes: boolean = True);
var
  acumr: NReal;
  k, j: integer;
  cntHidraulicos, cntTermicos: integer;
  fuente: TFuenteAleatoria;
  AuxDurPos: TDAofNReal;
  CatalogoReferencias: TCatalogoReferencias;

begin
  if globs.EstadoDeLaSala = CES_OPTIMIZANDO then
    globs.nPasos := globs.calcNPasosOpt
  else
    globs.nPasos := globs.calcNPasosSim;

  if flg_MemoriaPreparada then
    exit;

  flg_MemoriaPreparada := True;

  {$IFDEF DEBUG_MULTI_HILO}
  assignfile(fdebug_mh, 'debug_mh' + IntToStr(idHilo) + '_' +
    EscenarioActivo.nombre + '.xlt');
  rewrite(fdebug_mh);
  writeln(fdebug_mh, 'Prepararse: '#9 + DateTimeToStr(now()));
  {$ENDIF}


  // Atención si la sala es minutal obligo un solo poste
  // de duración en horas igual a los minutos especificados.
  if globs.SalaMinutal then
  begin
    globs.NPostes := 1;
    setlength(AuxDurPos, 1);
    globs.DurPos := AuxDurPos;
    globs.DurPos[0] := globs.DurPaso_minutos / 60.0;
  end;

  //Preparar valores de las variables globales de la sala
  acumr := xmatdefs.vsum(globs.DurPos);

  globs.HorasDelPaso := acumr;

  globs.fActPaso := 1.0 + globs.TasaDeActualizacion;
  globs.fActPaso := Math.power(1 / globs.fActPaso, acumr / (365 * 24));

  //Armar el listado de actores
  j := 0;
  SetLength(actores, listaActores.Count);
  // Es importante que PRIMERO estén los NODOS para que en leer solución
  // la lean antes que los demás por si los demás precisan disponer del costo marginal
  for k := 0 to self.nods.Count - 1 do
  begin
    actores[j] := self.nods[k] as TActor;
    Inc(j);
  end;

  for k := 0 to self.dems.Count - 1 do
  begin
    actores[j] := self.dems[k] as TDemanda;
    Inc(j);
  end;

  for k := 0 to sums.Count - 1 do
  begin
    actores[j] := TActor(sums[k]);
    Inc(j);
  end;

  for k := 0 to self.arcs.Count - 1 do
  begin
    actores[j] := self.arcs[k] as TArco;
    Inc(j);
  end;
  cntHidraulicos := 0;
  cntTermicos := 0;

  for k := 0 to self.gens.Count - 1 do
  begin
    actores[j] := self.gens[k] as TGenerador;
    if actores[j] is TGeneradorHidraulico then
      Inc(cntHidraulicos)
    else if actores[j] is TGTer then
      Inc(cntTermicos);
    Inc(j);
  end;

  for k := 0 to self.comercioInternacional.Count - 1 do
  begin
    actores[j] := self.comercioInternacional[k] as TComercioInternacional;
    Inc(j);
  end;

  for k := 0 to UsosGestionables.Count - 1 do
  begin
    actores[j] := UsosGestionables[k] as TUsoGestionable_postizado;
    Inc(j);
  end;

  //Armar el listado de generadores hidráulicos
  setlength(Hidraulicos, cntHidraulicos);
  cntHidraulicos := 0;

  for k := 0 to self.gens.Count - 1 do
  begin
    if self.gens[k] is TGeneradorHidraulico then
    begin
      hidraulicos[cntHidraulicos] := self.gens[k] as TGeneradorHidraulico;
      Inc(cntHidraulicos);
    end;
  end;

  //Armar el listado de generadores térmicos
  setlength(termicos, cntTermicos);
  cntTermicos := 0;

  for k := 0 to self.gens.Count - 1 do
  begin
    if self.gens[k] is TGTer then
    begin
      termicos[cntTermicos] := self.gens[k] as TGTer;
      Inc(cntTermicos);
    end;
  end;



  // Atención, al Expandir FICHAS DINAMICAS con referencias es necesario
  // resolver dichas referencias para lo cual se necesita un catálogo.
  CatalogoReferencias := TCatalogoReferencias.Create;


  SetLength(fuentes, listaFuentes_.Count);
  // ATENCION aquí controlamos si es necesario esclavizar fuentes.
  for k := 0 to listaFuentes_.Count - 1 do
  begin
    fuente := TFuenteAleatoria( listaFuentes_[k]);
    if (fuente.durPasoDeSorteoEnHoras = 0) or
      (fuente.durPasoDeSorteoEnHoras = globs.HorasDelPaso) or
      (not flg_esclavizarfuentes) then
      fuentes[k] := fuente
    else
    begin
      if globs.HorasDelPaso < fuente.durPasoDeSorteoEnHoras then
      begin
        listaFuentesReemplazadas.Add(fuente);
        fuentes[k] := TEsclavizadorSobreMuestreado.Create(
          capa, 'SobreMuestreada_' + fuente.nombre, fuente);
        listaFuentes_[k] := fuentes[k];
        fuente.Esclavizador := fuentes[k];
      end
      else
      begin
        listaFuentesReemplazadas.Add(fuente);
        fuentes[k] := TEsclavizadorSubMuestreado.Create(
          capa, 'SubMuestreada_' + fuente.nombre, fuente, fuente.ResumirPromediando);
        listaFuentes_[k] := fuentes[k];
        fuente.Esclavizador := fuentes[k];
      end;
    end;
  end;

  //Armar el listado de fuentes
  ordenarFuentes;


  Armar_lst_SorteosDelPaso_Actores;

  globs.ActualizadorLPD.limpiar;

(**** ATENCION *******************************************************
Primero preparan memoria los ACTORES y luego las FUENTES
Esto es así pues los actores pueden registrar funciones en las fuentes
y las fuentes precisan esa información para prepararse
*********************************************************************)
  {$IFDEF CALC_DEMANDA_NETA}
  globs.InicializarNeteadorDeDemanda;
  {$ENDIF}

  // Que los actores preparen su memoria
  // Primero tienen que preparar la memoria los actores porque REGISTRAN
  // funciones en los bornes de las fuentes.
  for k := 0 to high(actores) do
  begin
    actores[k].PrepararMemoria(CatalogoReferencias, globs);
  end;

  //Preparar las fuentes
  for k := 0 to high(fuentes) do
  begin
    fuentes[k].prepararMemoria(CatalogoReferencias, globs);
    fuentes[k].RegistrarParametrosDinamicos(CatalogoReferencias);
  end;


  //Preparar los combustibles
  for k := 0 to listaCombustibles.Count - 1 do
  begin
    TCombustible(listaCombustibles.items[k]).prepararMemoria(CatalogoReferencias, globs);
    TCombustible(listaCombustibles.items[k]).RegistrarParametrosDinamicos(
      CatalogoReferencias);
  end;
  // Que los actores registren sus parámetros dinámicos
  for k := 0 to high(actores) do
    actores[k].RegistrarParametrosDinamicos(CatalogoReferencias);
  CatalogoReferencias.resolver_referencias(self.listaActores);
  CatalogoReferencias.resolver_referencias(self.listaFuentes_);
  CatalogoReferencias.resolver_referencias(listaFuentesReemplazadas);
  if CatalogoReferencias.referenciasSinResolver > 0 then
  begin
    CatalogoReferencias.DumpReferencias('errRefs.txt');
    raise Exception.Create(
      'TSalaDeJuego.PrepararMemoriaYListados - Quedan referencias sin resolver');
  end;
  CatalogoReferencias.Free;
end;

procedure TSalaDeJuego.PrepararActualizadorFichasLPD(TiempoHaciaAdelante: boolean);
begin
  // Preparamos el actualizador de fichas.
  if globs.EstadoDeLaSala = CES_OPTIMIZANDO then
  begin
    globs.ActualizadorLPD.ChequeoFechas(globs.fechaIniOpt, globs.fechaFinOpt);
    globs.ActualizadorLPD.Preparse(TiempoHaciaAdelante, globs.fechaIniOpt,
      globs.fechaFinOpt);
    globs.ActualizadorLPD.PrepararOptSim(globs.fechaIniOpt, globs.fechaFinOpt);
  end
  else
  begin
    globs.ActualizadorLPD.ChequeoFechas(globs.fechaIniSim, globs.fechaFinSim);
    globs.ActualizadorLPD.Preparse(TiempoHaciaAdelante, globs.fechaIniSim,
      globs.fechaFinSim);
    globs.ActualizadorLPD.PrepararOptSim(globs.fechaIniSim, globs.fechaFinSim);
  end;

end;


procedure TSalaDeJuego.publicarSoloVariablesUsadasEnSimRes3;
var
  planillasActivasSimRes3: TStrings;
  nPlanillasSimRes3Activas: integer;
  k: integer;
  lector: TLectorSimRes3Defs;
  res: TListaDeCosasConNombre;
  cosa: TCosaConNombre;
  varDef: TVarDef;
  i: integer;

  aVarDef, aVarDefx: TVarDef;
  aIndice: TVarIdxs;

  nombre_vect: string;

begin

  planillasActivasSimRes3 := listaPlantillasSimRes3.lista_activas;
  nPlanillasSimRes3Activas := planillasActivasSimRes3.Count;

  lector := TLectorSimRes3Defs.Create;
  for k := 0 to nPlanillasSimRes3Activas - 1 do
  begin
    lector.LeerDefiniciones(planillasActivasSimRes3[k], False, True);
    for i := 0 to lector.lstIdxs.Count - 1 do
    begin
      aIndice := TVarIdxs(lector.lstIdxs[i]);
      cosa := BuscarPorNombre(aIndice.nombreActor, res);
      if cosa <> nil then
      begin
        if cosa.pubvarlst = nil then
          cosa.PubliVars;
        aVarDef := cosa.PubVarlst.find(aIndice.nombreVar);
        if aVarDef <> nil then
        begin
          if cosa is TCosaParticipeDeMercado then
          begin

            Write(' nombreVar: ', aIndice.nombreVar);
            aVarDefx := TCosaParticipeDeMercado(cosa).variablesParaSimRes.find(
              aIndice.nombreVar);
            if aVarDefx = nil then
            begin  // seguramente es una posición de un vector lo agregamos a mano
              // bien ...mmm.... buscamos entonces si el vector está publicado
              nombre_vect := avarDef.nombre_vect;
              if nombre_vect <> '' then
              begin
                aVarDefx := cosa.PubVarlst.find(nombre_vect);
                if aVarDefx <> nil then
                  aVarDefx.flg_smartdump_write := True;
              end;
              Write(' NIL ');
            end;

            writeln;

          end;
          aVarDef.flg_smartdump_write := True;
        end
        else
        begin
          writeln('ERROR en plantilla SimRes3: ' + planillasActivasSimRes3[k] +
            ', el índice : ' + aIndice.nombreVar +
            ' no corresponde a ninguna variable publicada.');
        end;
      end;

    end;
  end;
  lector.Free;


  // Ahora depuramos las variables no marcadas de los Actores y
  // de las fuentes.

  // Que los actores publiquen las variables
  for k := 0 to listaActores.Count - 1 do
    TCosaParticipeDeMercado(listaActores[k]).Depurar_VaraiblesParaSimRes;

(*
  // Que las fuentes publiquen las variables
  for k := 0 to listaFuentesReemplazadas.Count - 1 do
    TCosaParticipeDeMercado(listaFuentesReemplazadas[k]).Depurar_VaraiblesParaSimRes;
  *)

  for k := 0 to listaFuentes_.Count - 1 do
    TCosaParticipeDeMercado(listaFuentes_[k]).Depurar_VaraiblesParaSimRes;

end;


procedure TSalaDeJuego.publicarTodasLasVariables;
var
  k: integer;
begin

  self.PubliVars;
  globs.PubliVars;
  // Que los actores publiquen las variables
  for k := 0 to listaActores.Count - 1 do
    listaActores[k].PubliVars;

  (*
  // Que las fuentes publiquen las variables
  for k := 0 to listaFuentesReemplazadas.Count - 1 do
    TCosaConNombre(listaFuentesReemplazadas[k]).PubliVars;
    *)

  // Que las fuentes publiquen las variables
  for k := 0 to listaFuentes_.Count - 1 do
    listaFuentes_[k].PubliVars;

end;



procedure TSalaDeJuego.lista_Prepararse(CatalogoReferencias: TCatalogoReferencias;
  lista: TListaDeCosasConNombre);
var
  i: integer;
begin

  // primer barrido Preparo Actores.
  for i := 0 to lista.Count - 1 do
  begin
    if TObject(lista[i]) is TActor then
    begin
      //    WriteLn(TActor(lista[i]).ClassName + '-' + TActor(lista[i]).nombre);
      TActor(lista[i]).PrepararMemoria(CatalogoReferencias, globs);
    end;
  end;

  // segundo barrido Preparo Las Fuentes Aleatorias.
  // tiene que hacerce luego de preparar los Actores pues
  // aquellos puede agregar bornes sobre las fuentes
  for i := 0 to lista.Count - 1 do
  begin
    if TObject(lista[i]) is TFuenteAleatoria then
      TFuenteAleatoria(lista[i]).PrepararMemoria(CatalogoReferencias, globs);
  end;

  //// tercer barrido para publicar las variables.
  //for i := 0 to lista.Count - 1 do
  //begin
  //  TCosaConNombre(lista[i]).PubliVars;
  //end;
end;



procedure TSalaDeJuego.Prepararse_(CatalogoReferencias: TCatalogoReferencias);
var
  i: integer;
  cosasEnLaSala: TListaDeCosasConNombre;
  ficha: TFichaFuenteConstante;
begin
  cosasEnLaSala := TListaDeCosasConNombre.Create(0, 'aux_PrepararseYPubliVars');
  cosasEnLaSala.Capacity := 2 + listaActores.Count + listaFuentes_.Count;
  cosasEnLaSala.Add(self);
  cosasEnLaSala.Add(globs);
  for i := 0 to listaActores.Count - 1 do
    cosasEnLaSala.Add(TCosaConNombre(listaActores[i]));
  for i := 0 to listaFuentes_.Count - 1 do
    cosasEnLaSala.Add(TCosaConNombre(listaFuentes_[i]));
  lista_Prepararse(CatalogoReferencias, cosasEnLaSala);
  cosasEnLaSala.FreeSinElemenentos;
end;

procedure TSalaDeJuego.Armar_lst_BarridoFijarEstadoDeActoresYFuentesToEstrella;
var
  k: integer;
  p1, p2: procedure of object;
  actor1, actor: TActor;
  fuente1, fuente: TFuenteAleatoria;
begin
  // FijarEstadoEstrellita
  if lst_barridoFijarEstadoDeActoresToEstrella <> nil then
    lst_barridoFijarEstadoDeActoresToEstrella.Clear
  else
    lst_barridoFijarEstadoDeActoresToEstrella := TList.Create;

  actor1 := TActor.Create(capa, '', TFecha.Create_DT(now()),
    TFecha.Create_DT(Now()), TActor.CreateDefaultLPDUnidades_(1));
  p1 := Actor1.PosicionarseEnEstrellita;
  for k := 0 to high(actores) do
  begin
    actor := actores[k];
    p2 := actor.PosicionarseEnEstrellita;
    if @p1 <> @p2 then
      lst_barridoFijarEstadoDeActoresToEstrella.Add(actor);
  end;
  actor1.Free;

  if lst_barridoFijarEstadoDeFuentesToEstrella <> nil then
    lst_barridoFijarEstadoDeFuentesToEstrella.Clear
  else
    lst_barridoFijarEstadoDeFuentesToEstrella := TList.Create;

  fuente1 := TFuenteAleatoria.Create(capa, '', -1, False);
  p1 := fuente1.PosicionarseEnEstrellita;
  for k := 0 to listaFuentes_.Count - 1 do
  begin
    fuente := fuentes[k];

    if fuente is TEsclavizador then
      p2 := TEsclavizador(fuente).esclava.PosicionarseEnEstrellita
    else
      p2 := fuente.PosicionarseEnEstrellita;

    if @p1 <> @p2 then
      lst_barridoFijarEstadoDeFuentesToEstrella.Add(fuente);
  end;
  fuente1.Free;
end;

procedure TSalaDeJuego.Armar_lst_SorteosDelPaso_Actores;
var
  k, cantRedefiniciones: integer;
  p1, p2: procedure(sortear: boolean) of object;
  actor1, actor: TActor;
begin
  SetLength(lst_SorteosDelPaso_Actores, length(actores));

  actor1 := TActor.Create(capa, '', TFecha.Create_DT(now()),
    TFecha.Create_DT(now()), TActor.CreateDefaultLPDUnidades_(1));

  p1 := Actor1.SorteosDelPaso;
  cantRedefiniciones := 0;
  for k := 0 to high(actores) do
  begin
    actor := actores[k];
    p2 := actor.SorteosDelPaso;
    if @p1 <> @p2 then
    begin
      lst_SorteosDelPaso_Actores[cantRedefiniciones] := actor;
      cantRedefiniciones := cantRedefiniciones + 1;
    end;
  end;
  actor1.Free;
  if cantRedefiniciones <> Length(lst_SorteosDelPaso_Actores) then
    if cantRedefiniciones <> 0 then
      lst_SorteosDelPaso_Actores :=
        copy(lst_SorteosDelPaso_Actores, 0, cantRedefiniciones)
    else
      lst_SorteosDelPaso_Actores := nil;
end;

procedure TSalaDeJuego.Armar_lst_opt_PrintResultados;
var
  k: integer;
  p1, p2: procedure(var fsal: textfile) of object;
  actor1: TActor;
begin
  actor1 := TActor.Create(capa, '', TFecha.Create_DT(now()),
    TFecha.Create_DT(now()), TActor.CreateDefaultLPDUnidades_(1));

  // lst_opt_PrintResultados
  if lst_opt_PrintResultados <> nil then
    lst_opt_PrintResultados.Clear
  else
    lst_opt_PrintResultados := TList.Create;

  p1 := Actor1.opt_PrintResultados;
  for k := 0 to high(actores) do
  begin
    p2 := actores[k].opt_PrintResultados;
    if @p1 <> @p2 then
      lst_opt_PrintResultados.add(actores[k]);
  end;

  actor1.Free;
end;

procedure TSalaDeJuego.Armar_lst_Sim_cronicaIdInicio;
var
  k: integer;
  p1, p2: function: string of object;
  fuente1, fuente: TFuenteAleatoria;
begin
  // FijarEstadoEstrellita
  if lst_Sim_cronicaIdInicio <> nil then
    lst_Sim_cronicaIdInicio.Clear
  else
    lst_Sim_cronicaIdInicio := TList.Create;

  fuente1 := TFuenteAleatoria.Create(capa, '', 0, False);
  p1 := fuente1.cronicaIdInicio;
  for k := 0 to high( fuentes ) do
  begin
    fuente := fuentes[k];
    if fuente is TEsclavizador then
      p2 := TEsclavizador(fuente).esclava.cronicaIdInicio
    else
      p2 := fuente.cronicaIdInicio;

    if @p1 <> @p2 then
      lst_Sim_cronicaIdInicio.Add(fuente);
  end;
  fuente1.Free;
end;


procedure TSalaDeJuego.Armar_lst_Sim_Paso_Fin;
var
  k: integer;
  p1, p2: procedure of object;
  actor1: TActor;
begin
  actor1 := TActor.Create(capa, '', TFecha.Create_DT(now()),
    TFecha.Create_DT(now()), TActor.CreateDefaultLPDUnidades_(1));

  // lst_opt_PrintResultados
  if lst_Sim_Paso_Fin <> nil then
    lst_Sim_Paso_Fin.Clear
  else
    lst_Sim_Paso_Fin := TList.Create;

  p1 := Actor1.Sim_Paso_Fin;
  for k := 0 to high(actores) do
  begin
    p2 := actores[k].Sim_Paso_Fin;
    if @p1 <> @p2 then
      lst_Sim_Paso_Fin.add(actores[k]);
  end;
  actor1.Free;
end;

procedure TSalaDeJuego.Armar_lst_CalcularGradienteDeInversion;
var
  k: integer;
  Actor: TActor;
begin

  if lst_CalcularGradienteDeInviersion <> nil then
    lst_CalcularGradienteDeInviersion.Clear
  else
    lst_CalcularGradienteDeInviersion := TList.Create;

  for k := 0 to high(actores) do
  begin
    Actor := actores[k];
    if Actor is TGenerador then
      if TGenerador(Actor).flg_CalcularGradienteDeInversion then
        lst_CalcularGradienteDeInviersion.add(Actor);
  end;
end;


procedure TSalaDeJuego.Armar_lst_costoDirectoDelPaso;
var
  k: integer;
  p1, p2: function: NReal of object;
  //  actor1: TActor;
  fuente1: TFuenteAleatoria;
begin
(*  actor1:= TActor.Create('', TFecha.Create_DT(now()), TFecha.Create_DT(now()), TActor.CreateDefaultLPDUnidades);


// lst_opt_PrintResultados
  if lst_actores_costoDirectoDelPaso <> nil then
    lst_actores_costoDirectoDelPaso.Clear
  else
    lst_actores_costoDirectoDelPaso:= TList.Create;
  p1:= Actor1.costoDirectoDelPaso;

  for k:= 0 to high( actores ) do
  begin
    p2:= actores[k].costoDirectoDelpaso;
    if @p1<>@p2 then
      lst_actores_costoDirectoDelPaso.add( actores[k] );
  end;
  actor1.Free;
    *)

  fuente1 := TFuenteAleatoria.Create(capa, '', 0, False);
  if lst_fuentes_costoDirectoDelPaso <> nil then
    lst_fuentes_costoDirectoDelPaso.Clear
  else
    lst_fuentes_costoDirectoDelPaso := TList.Create;

  p1 := fuente1.costoDirectoDelPaso;
  for k := 0 to high( fuentes ) do
  begin
    if fuentes[k] is TEsclavizador then
      p2 := TEsclavizador(fuentes[k]).esclava.costoDirectoDelPaso
    else
      p2 := fuentes[k].costoDirectoDelPaso;

    if @p1 <> @p2 then
      lst_fuentes_costoDirectoDelPaso.add(fuentes[k]);
  end;
  fuente1.Free;
end;


procedure TSalaDeJuego.Armar_lst_EvolucionarEstado;
var
  k: integer;
  p1, p2: procedure of object;
  actor1: TActor;
  fuente1: TFuenteAleatoria;
begin
  actor1 := TActor.Create(capa, '', TFecha.Create_DT(now()),
    TFecha.Create_DT(now()), TActor.CreateDefaultLPDUnidades_(1));

  // lst_opt_PrintResultados
  if lst_actores_EvolucionarEstado <> nil then
    lst_actores_evolucionarEstado.Clear
  else
    lst_actores_evolucionarEstado := TList.Create;

  p1 := Actor1.EvolucionarEstado;

  for k := 0 to high(actores) do
  begin
    p2 := actores[k].EvolucionarEstado;
    if @p1 <> @p2 then
      lst_actores_evolucionarEstado.add(actores[k]);
  end;
  actor1.Free;

  fuente1 := TFuenteAleatoria.Create(capa, '', 0, False);
  if lst_fuentes_EvolucionarEstado <> nil then
    lst_fuentes_EvolucionarEstado.Clear
  else
    lst_fuentes_EvolucionarEstado := TList.Create;

  p1 := fuente1.evolucionarEstado;
  for k := 0 to high(fuentes) do
  begin
    p2 := fuentes[k].evolucionarEstado;
    if @p1 <> @p2 then
      lst_fuentes_EvolucionarEstado.add(fuentes[k]);
  end;
  fuente1.Free;
end;


procedure TSalaDeJuego.Armar_lst_necesitoIterar;
var
  k: integer;
  p1, p2: function(kIteracion: integer; var errRelativo: NReal): boolean of object;
  actor1: TActor;
begin
  actor1 := TActor.Create(capa, '', TFecha.Create_DT(now()),
    TFecha.Create_DT(now()), TActor.CreateDefaultLPDUnidades_(1));

  // lst_opt_PrintResultados
  if lst_necesitoIterar <> nil then
    lst_necesitoIterar.Clear
  else
    lst_necesitoIterar := TList.Create;

  p1 := Actor1.opt_NecesitoIterar;
  for k := 0 to high(actores) do
  begin
    p2 := actores[k].opt_NecesitoIterar;
    if @p1 <> @p2 then
      lst_NecesitoIterar.add(actores[k]);
  end;
  actor1.Free;
  {$IFDEF ITERADOR_FLUCAR}
  if usarIteradorFlucar then
  begin
    IteradorFlucar := TIteradorFlucar.Create(self);
  end
  else
    IteradorFlucar := nil;
  {$ENDIF}
end;



(****** por ahora no va esto. Puede ser que vuelva a ponerse para
aumentar la eficiencia

procedure TSalaDeJuego.Armar_lst_Encadenamientos;
var
  iHidraulicos, iAux, nHidraulicos: Integer;
  temp: TGeneradorHidraulico;
function todasResueltas(centralesAguasArriba : TListaCentralesAguasArriba ; var noResuelta : TGeneradorHidraulico) : boolean;
var
  iCentralesEncadenadas, iter: Integer;
  res, buscando: boolean;
begin
  res:= true;
  iCentralesEncadenadas:= 0;
  //Recorro las centrales aguas arriba de la mía, si las encuentro entre las
  //que ya estan ordenadas entonces estan todas resueltas y puedo dejar la central
  //en ese lugar en la lista
  while iCentralesEncadenadas < Length(centralesAguasArriba.lst) do
  begin
    noResuelta:= centralesAguasArriba.lst[iCentralesEncadenadas];
    buscando:= true;
    for iter:= 0 to iHidraulicos -1 do
    begin
      if hidraulicos[iter] = noResuelta then
      begin
        buscando:= false;
        break;
      end;
    end;
    if not buscando then
      inc(iCentralesEncadenadas)
    else
    begin
      res:= false;
      break;
    end;
  end;
  result:= res;
end;

begin
  if length(hidraulicos) = 0 then
  begin
    nHidraulicos:= 0;
    for iAux:= 0 to Gens.lst.Count -1 do
    begin
      if (TGenerador(gens.lst[iAux]) is TGeneradorHidraulico) then
        inc(nHidraulicos);
    end;
    SetLength(hidraulicos, nHidraulicos);
    iHidraulicos:= 0;
    for iAux:= 0 to Gens.lst.Count -1 do
    begin
      if (TGenerador(gens.lst[iAux]) is TGeneradorHidraulico) then
      begin
        hidraulicos[iHidraulicos]:= gens.lst[iAux];
        inc(iHidraulicos);
        if iHidraulicos >= nHidraulicos then
          break;
      end;
    end;
  end
  else
    nHidraulicos:= Length(hidraulicos);

  iHidraulicos:= 0;
  while iHidraulicos < nHidraulicos do
  begin
    if todasResueltas(hidraulicos[iHidraulicos].centralesAguasArriba, temp) then
      inc(iHidraulicos)
    else
    begin
      for iAux:= iHidraulicos +1 to nHidraulicos -1 do
        if hidraulicos[iAux] = temp then
          break;
      hidraulicos[iAux]:= hidraulicos[iHidraulicos];
      hidraulicos[iHidraulicos]:= temp;
    end;
  end;
end;
**********)


function TSalaDeJuego.NecesitoIterar: boolean;
var
  k: integer;
  xerr: NReal;
  cnt: integer;
begin
  cnt := 0;

  // Atención: Es a propósito que le preguntamos a todos los actores.
  // No paramos en el primero que precise iterar dado que ya que vamos a iterar
  // le permitimos a los demás mejorar sus valores para lo que hay que llamar
  // a su correspondiente NecesitoIterar.
  for k := 0 to lst_NecesitoIterar.Count - 1 do
    if TActor(lst_NecesitoIterar.Items[k]).opt_NecesitoIterar(
      globs.cntIteracionesDelPaso, xerr) then
      Inc(cnt);

  {$IFDEF ITERADOR_FLUCAR}
  //   llamar a verificador de FLUCAR
  if usarIteradorFlucar then
    if IteradorFlucar.NecesitoIterar then
      Inc(cnt);
  {$ENDIF}

  Result := cnt > 0;
end;



function TSalaDeJuego.getNombreVar(ivar: integer): string;
var
  i: integer;
  nombre: string;
begin
  nombre := '';
  for i := 0 to high(actores) do
    if actores[i].getNombreVar(ivar, nombre) then
      break;
  if nombre = '' then
    nombre := '??_x' + IntToStr(ivar);
  Result := nombre;
end;

function TSalaDeJuego.getNombreRes(ires: integer): string;
var
  i: integer;
  nombre: string;
begin
  nombre := '';
  for i := 0 to high(actores) do
  begin
    if actores[i].getNombreRes(ires, nombre) then
      break;
  end;
  if nombre = '' then
    nombre := '??_y' + IntToStr(ires);
  Result := nombre;
end;

procedure TSalaDeJuego.dump_Variables;
var
  archi: string;
begin
  archi := DateTimeToStr(now()) + '_dump_Variables.txt';
  while pos('/', archi) > 0 do
    archi[pos('/', archi)] := '-';
  while pos(':', archi) > 0 do
    archi[pos(':', archi)] := '-';
  archi := getDir_Dbg + archi;
  dump_Variables(archi);
end;

procedure TSalaDeJuego.dump_Variables(archi: string);
const
  indentador = #9;
var
  f: TextFile;
  k: integer;
begin
  if pos(getDir_Dbg, archi) <> 1 then
    archi := getDir_Dbg + archi;
  try
    AssignFile(f, archi);
    rewrite(f);
    writeln(f, 'Estado de la Sala= ', estadoSalaToString(globs.EstadoDeLaSala));
    writeln(f, 'globs.kpaso_= ', globs.kpaso_Sim);
    if globs.EstadoDeLaSala = CES_OPTIMIZANDO then
      writeln(f, 'globs.CF.ordinalEstrellaActual= ', globs.CF.ordinalEstrellaActual);

    writeln(f, 'globs.kcronica= ', globs.kcronica);

    writeln(f, 'globs.cntIteracionesDelPaso= ', globs.cntIteracionesDelPaso);

    writeln(f);
    for k := 0 to self.nods.Count - 1 do
      (self.nods[k] as TNodo).dump_Variables(f, indentador);
    for k := 0 to self.dems.Count - 1 do
      (self.dems[k] as TDemanda).dump_Variables(f, indentador);

    (*
    for k := 0 to Sums.Count - 1 do
      TSuministroCombustible(Sums[k]).dump_Variables(f, indentador);
      *)
    for k := 0 to self.gens.Count - 1 do
      (self.gens[k] as TGenerador).dump_Variables(f, indentador);
    for k := 0 to self.comercioInternacional.Count - 1 do
      (self.comercioInternacional[k] as TComercioInternacional).dump_Variables(f,
        indentador);
    for k := 0 to self.arcs.Count - 1 do
      (self.arcs[k] as TArco).dump_Variables(f, indentador);
    for k := 0 to high(fuentes) do
      fuentes[k].dump_Variables(f, indentador);
  finally
    CloseFile(f);
  end;
end;

procedure TSalaDeJuego.Sim_Cronica_Inicio;
var
  k: integer;
begin
  // 8/11/2011 con esto intentamos que las cronicas sean reproducibles sin importar
  // su largo. O sea que si acortamos el horizonte de simulación los tramos iniciales
  // de las crónicas sean los mismos.
  if (RandSeed_SincronizarAlInicioDeCadaCronica) then
    globs.fijarSemillaAleatoria_(Self.globs.semilla_inicial_sim + globs.kCronica);

  globs.Fijar_kPaso(1);
  globs.ActualizadorLPD.PrepararOptSim(globs.fechaIniSim, globs.fechaFinSim);

  for k := 0 to high(fuentes) do
  begin
    fuentes[k].Sim_Cronica_Inicio;
  end;

  for k := 0 to high(actores) do
  begin
    actores[k].Sim_Cronica_Inicio;
  end;
  globs.procNot(globs.procNot_InicioCronica);
end;


{procedure TSalaDeJuego.prepararSalaParaPaso;
begin
  globs.ActualizadorLPD.ActualizarFichasHasta( globs.FechaInicioDelpaso );
end;}

procedure TSalaDeJuego.PosicionarseEnEstrellita;
var
  k: integer;
begin
  {$IFDEF rc_EXPANDO_}
  for k := 0 to high(fuentesConBCSinEstadoEnCF) do
    fuentesConBCSinEstadoEnCF[k].fijarEstadoInterno;
  {$ENDIF}

  for k := 0 to high(fuentes) do
    fuentes[k].PosicionarseEnEstrellita;

  for k := 0 to High(fuentesConBCConEstadoEnCF) do
    fuentesConBCConEstadoEnCF[k].calcular_BC;

  {$IFDEF rc_EXPANDO_}
  for k := 0 to high(fuentesConBCSinEstadoEnCF) do
    fuentesConBCSinEstadoEnCF[k].calcular_BC;
  {$ENDIF}

  for k := 0 to lst_barridoFijarEstadoDeActoresToEstrella.Count - 1 do
    TActor(lst_barridoFijarEstadoDeActoresToEstrella.items[k]).PosicionarseEnEstrellita;
end;

procedure TSalaDeJuego.fuentes_ActualizarEstadoGlobal(flg_Xs: boolean);
var
  k: integer;
begin
  for k := 0 to lst_barridoFijarEstadoDeFuentesToEstrella.Count - 1 do
    TFuenteAleatoria(lst_barridoFijarEstadoDeFuentesToEstrella[k]).
      ActualizarEstadoGlobal(flg_Xs);
end;

procedure TSalaDeJuego.actores_ActualizarEstadoGlobal(flg_Xs: boolean);
var
  k: integer;
begin
  for k := 0 to lst_barridoFijarEstadoDeActoresToEstrella.Count - 1 do
    TActor(lst_barridoFijarEstadoDeActoresToEstrella.items[k]).ActualizarEstadoGlobal(
      flg_Xs);
end;


procedure TSalaDeJuego.Actores_AcumularAuxs1;
var
  k: integer;
begin
  for k := 0 to high(actores) do
    actores[k].AcumAux1(globs.invNCronicasOpt);
end;

procedure TSalaDeJuego.Actores_SetAuxs1;
var
  k: integer;
begin
  for k := 0 to high(actores) do
    actores[k].SetAux1;
end;

procedure TSalaDeJuego.SorteosDelPasoOpt(sortear: boolean);
var
  k: integer;
begin

  globs.SorteosDelPaso;

  // generamos los números aleatorios en las borneras de entrada.
  for k := 0 to high(fuentes) do
    fuentes[k].sorteosDelPaso(sortear);

  // para las fuentes que no tienen estado en CF, podemos fijar su estado
  // interno (no depende del estado del sistema) y además ya podemos calcular
  // sus Bornes Calculados.

  {$IFNDEF rc_EXPANDO_}
  // OJO las fuentes que Expanden el estado deben calcular los bornes luego
  // de sumar la expansión del estado.
  for k := 0 to high(fuentesConBCSinEstadoEnCF) do
  begin
    fuentesConBCSinEstadoEnCF[k].fijarEstadoInterno;
    fuentesConBCSinEstadoEnCF[k].calcular_BC;
  end;
  {$ENDIF}

  for k := 0 to high(lst_SorteosDelPaso_Actores) do
    lst_SorteosDelPaso_Actores[k].SorteosDelPaso(sortear);
end;

procedure TSalaDeJuego.SorteosDelPasoSim(sortear: boolean);
var
  k: integer;
begin
  globs.SorteosDelPaso;

  for k := 0 to high(fuentes) do
  begin
    fuentes[k].sorteosDelPaso(sortear);
    fuentes[k].calcular_BC;
  end;
  for k := 0 to high(lst_SorteosDelPaso_Actores) do
    lst_SorteosDelPaso_Actores[k].SorteosDelPaso(sortear);
end;

procedure TSalaDeJuego.PrepararPaso_as;
var
  k: integer;
begin
  for k := 0 to high(actores) do
    actores[k].PrepararPaso_as;

  {$IFDEF ITERADOR_FLUCAR}
  //   afectar rendimiento y capacidades de los arcos según resultados del FLUCAR
  if IteradorFlucar <> nil then
    IteradorFlucar.preparar_paso_as;
  {$ENDIF}
end;


procedure TSalaDeJuego.InicioSim;
var
  k: integer;
begin
  for k := 0 to high(Fuentes) do
    Fuentes[k].InicioSim;
  for k := 0 to high(actores) do
    actores[k].InicioSim;
end;

procedure TSalaDeJuego.InicioOpt;
var
  k: integer;
begin
  for k := 0 to high(Fuentes) do
    Fuentes[k].InicioOpt;
  for k := 0 to high(actores) do
    actores[k].InicioOpt;
end;

procedure TSalaDeJuego.Fuentes_PrepararPaso_ps(sortear: boolean);
var
  k: integer;
begin
  for k := 0 to listaFuentes_A.Count-1 do
  begin
    TFuenteAleatoria( listaFuentes_A[k] ).PrepararPaso_ps;
  end;

  for k := 0 to listaFuentes_B.Count-1 do
  begin
    TFuenteAleatoria( listaFuentes_B[k] ).SorteosDelPaso( sortear );
  end;

  for k := 0 to listaFuentes_B.Count-1 do
  begin
    TFuenteAleatoria( listaFuentes_B[k] ).PrepararPaso_ps;
  end;
end;


procedure TSalaDeJuego.Actores_PrepararPaso_ps_pre;
var
  k: integer;

begin

{$IFDEF CALC_DEMANDA_NETA}
  globs.borrarSumaPHorarias;
  for k := 0 to high(actores) do
    actores[k].PrepararPaso_ps_pre;
  globs.postizarPHoraria;
{$ENDIF}
end;


procedure TSalaDeJuego.Actores_PrepararPaso_ps;
var
  k: integer;
{$IFDEF CHEQUEOMEM}
  tam: cardinal;
{$ENDIF}

begin
{$IFDEF CHEQUEOMEM}
  tam := udbgutil.tam;
{$ENDIF}
  for k := 0 to high(actores) do
  begin
    actores[k].PrepararPaso_ps;
{$IFDEF CHEQUEOMEM}
    if tam <> udbgutil.tam then
      raise Exception.Create('OJO; el Actor: ' + actores[k].nombre +
        ' pierde memoria en PrepararPaso_ps');
{$ENDIF}
  end;

{$IFDEF ITERADOR_FLUCAR}
  //   afectar rendimiento y capacidades de los arcos según resultados del FLUCAR
  if IteradorFlucar <> nil then
    IteradorFlucar.preparar_paso_ps;
{$ENDIF}

end;

function TSalaDeJuego.ResolverPaso: NReal;
var
  k: integer;
  ispxres: integer;
begin

  (*
  writeln( 'kPaso: ', globs.kPaso_, ', kCronica: ',
           globs.kCronica, ', estrella: ', globs.CF.ordinalEstrellaActual );
    *)
  // Inicializamos el conteo de variables para dimensionar el problema.
  ivar := 1;
  ires := 1;
  ivae := 1;
  // barrido para determinar dimensión del problema.
  for k := 0 to high(actores) do
    actores[k].opt_nvers(ivar, ivae, ires);


  if ((ires = spx.nf) and (ivar = spx.nc)) and (ivae - 1 = spx.nvents) then
    spx.limpiar
  else
  begin
    spx.Free;
    spx := TMIPSimplex.Create_init(ires, ivar, ivae - 1, self.getNombreVar,
      self.getNombreRes);
  end;


  for k := 0 to high(actores) do
    actores[k].opt_cargue(spx);

  // !!!! OJO, los encadenamientos hay que resolverlos antes de
  // fijar las restricciones de caja, para que los cambios de variables
  // tengan efecto en todas las filas.
  for k := 0 to high(hidraulicos) do
    hidraulicos[k].ResolverEncadenamientos(spx);

  // le damos la oportunidad a las fuentes con estado de cargar
  for k := 0 to high(fuentes) do
    fuentes[k].opt_cargue(spx);


  // fijar las restricciones es lo último que hacemos pues cambia
  // la columna de los términos independientes
  for k := 0 to high(actores) do
    actores[k].opt_fijarRestriccionesDeCaja(spx);

  try
    (*
    if ((globs.kPaso_=151) and (globs.cntIteracionesDelPaso=1)) then
    spx.DumpSistemaToXLT_('Problema_planteado_kPaso_' + IntToStr(
      globs.kPaso_) + '_kCron_' + IntToStr(
      globs.kCronica) + '_kEstrellita_' + IntToStr(
      globs.CF.ordinalEstrellaActual) + '_kIter_' + IntToStr(
      globs.cntIteracionesDelPaso) + '_' + EscenarioActivo.nombre +
      '.XLT', '..para debug..');
    *)

     (* Fallo con mejor camino Test20140727
 if ( globs.kPaso_ = 198) and ( globs.kCronica = 1 )
      and ( globs.CF.ordinalEstrellaActual = 31) then
      spx.DumpSistemaToXLT_('Problema_planteado_kPaso_' + IntToStr(
        globs.kPaso_)+'_kEstrellita_'+ IntToStr( globs.CF.ordinalEstrellaActual )+'_' + EscenarioActivo.nombre+ '.XLT', '..para debug..');


    if ( globs.kPaso_ = 118) and ( globs.kCronica = 5 )
      and ( globs.EstadoDeLaSala =   CES_OPTIMIZANDO) then
         spx.DumpSistemaToXLT_('Problema_planteado_kPaso_' + IntToStr(
           globs.kPaso_)+'_'+IntToStr( globs.CF.ordinalEstrellaActual) + EscenarioActivo.nombre+ '.XLT', '..para debug..');


    if ( globs.EstadoDeLaSala =   CES_SIMULANDO) and (globs.kPaso_ = 21 ) then
    spx.DumpSistemaToXLT_('Problema_planteado_kPaso_' + IntToStr(
           globs.kPaso_)+'_'+IntToStr( globs.CF.ordinalEstrellaActual) + EscenarioActivo.nombre+ '.XLT', '..para debug..');

  *)
    (**
    if ( globs.kPaso_ = 1) and ( globs.kCronica = 2 )
      and ( globs.EstadoDeLaSala =   CES_SIMULANDO) then
         spx.DumpSistemaToXLT_('Problema_planteado_kPaso_' + IntToStr(
           globs.kPaso_)+'c'+IntToStr( globs.kCronica)
           +'i'+IntToStr( globs.cntIteracionesDelPaso )
           +'h'+IntToStr( globs.idHilo )
           + EscenarioActivo.nombre+ '.XLT', '..para debug..');
       **)

    ispxres := spx.resolver;

    if ispxres < 0 then
    begin
      raise Exception.Create('ERROR DE DATOS, NO ENCONTRE DESPACHO FACTIBLE!!! ispxres:'
        + IntToStr(ispxres) + ' kpaso:' + IntToStr(globs.kPaso_Sim) +
        ', kCronica: ' + IntToStr(globs.kCronica) + ', nIterDelPaso:' +
        IntToStr(globs.cntIteracionesDelPaso));
    end;

    (***
  if ( globs.kPaso_ = 364 ) and ( globs.CF.ordinalEstrellaActual = 1 ) then
      spx.DumpSistemaToXLT_('Problema_resuelto_kPaso_' + IntToStr(
        globs.kPaso_)+'_kEstrellita_'+ IntToStr( globs.CF.ordinalEstrellaActual )+'_' + EscenarioActivo.nombre+ '.XLT', '..para debug..');
***)
  except
    On E: Exception do
    begin
      spx.DumpSistemaToXLT_('DESPACHOINFACTIBLE.XLT', e.Message);
      dump_Variables;
      raise;
    end;
  end;


  globs.costodelpaso := -spx.fval;

  // spx.DumpSistemaToXLT('_rch_2' + genStrPasoCronEstrIter + '.xlt', '');

  {$IFDEF Micho}
  spx.DumpSistemaToXLT('spx-despuesderesolver.xlt', 'debug');
{$ENDIF}

  costoOperativoDelPaso := 0.0;
  self.utilidadDirectaDelPaso := 0.0;
  PagosPorDisponibilidadDelPaso := 0.0;
  PagosAdicionalesPorEnergiaDelPaso := 0.0;
  for k := 0 to high(actores) do
  begin
    actores[k].opt_leerSolucion(spx);
    costoOperativoDelPaso := costoOperativoDelPaso + actores[k].costoDirectoDelPaso;
    utilidadDirectaDelPaso := utilidadDirectaDelPaso + actores[k].utilidadDirectaDelPaso;
    PagosPorDisponibilidadDelPaso :=
      PagosPorDisponibilidadDelPaso + actores[k].Ingreso_PorDisponibilidad_;
    PagosAdicionalesPorEnergiaDelPaso :=
      PagosAdicionalesPorEnergiaDelPaso + actores[k].Ingreso_PorEnergia_;
  end;
  self.costoDirectoDelPaso := costoOperativoDelPaso + PagosPorDisponibilidadDelPaso +
    PagosAdicionalesPorEnergiaDelPaso;
  Result := -spx.fval;

end;

procedure TSalaDeJuego.Sim_Paso_Fin;
var
  k: integer;
begin
  for k := 0 to lst_Sim_Paso_Fin.Count - 1 do
    TActor(lst_Sim_Paso_Fin[k]).Sim_Paso_Fin;
  globs.procNot(globs.procNot_FinPaso);
end;


procedure TSalaDeJuego.CalcularGradientesDeInversion;
var
  k: integer;
begin
  for k := 0 to lst_CalcularGradienteDeInviersion.Count - 1 do
    TGenerador(lst_CalcularGradienteDeInviersion[k]).CalcularGradienteDeInversion;
end;




procedure TSalaDeJuego.CapturarResultadosDelPaso;
begin
end;

procedure TSalaDeJuego.Sim_Cronica_Fin;
var
  k: integer;
  {$IFDEF DUMP_TEXT_SIMRES}
  fsal: textfile;
  {$ENDIF}
begin
  for k := 0 to high(actores) do
    actores[k].Sim_Cronica_Fin;


  {$IFDEF DUMP_TEXT_SIMRES}
  if flg_ImprimirArchivos_Estado_Fin_Cron then
  begin
    assignfile(fsal, dirResultadosCorrida + 'estado_fin_cron_' +
      IntToStr(globs.semilla_inicial_sim) + 'x' + IntToStr(Globs.kCronica) +
      '_' + EscenarioActivo.nombre + '.xlt');
    rewrite(fsal);

    for k := 0 to high(fuentes) do
      fuentes[k].sim_FinCronicaPrintEstadoFinal(fsal);
    for k := 0 to high(actores) do
      actores[k].sim_FinCronicaPrintEstadoFinal(fsal);
    closefile(fsal);
  end;
  {$ENDIF}
  globs.procNot(globs.procNot_FinCronica);
  Inc(globs.kCronica);
end;

procedure TSalaDeJuego.FinSimulacion;
begin
  globs.procNot(globs.procNot_FinSimulacion);
end;

procedure TSalaDeJuego.FinOptimizacion;
begin
  globs.procNot(globs.procNot_opt_FinOptimizacion);
end;

function TSalaDeJuego.optx_nvxs: integer;
var
  oldIvar_xr, oldIvar_xd: integer;
  nFuentesConEstado, nFuentesSinEstado: integer;
  k: integer;
begin
  // ahora determinamos la dimensión del espacio de estado y los frames
  // de variables auxiliares que sea necesario crear.
  ivar_xr := 0;
  ivar_xd := 0;
  ivar_auxNReal := 0;
  ivar_auxInt := 0;
  for k := 0 to high(actores) do
    actores[k].optx_nvxs(ivar_xr, ivar_xd, ivar_auxNReal, ivar_auxInt);

  SetLength(fuentesConBCSinEstadoEnCF, length(fuentes));
  SetLength(fuentesConBCConEstadoEnCF, length(fuentes));

  oldIvar_xr := ivar_xr;
  oldIvar_xd := ivar_xd;
  nFuentesConEstado := 0;
  nFuentesSinEstado := 0;
  for k := 0 to high(fuentes) do
  begin
    fuentes[k].optx_nvxs(ivar_xr, ivar_xd, ivar_auxNReal, ivar_auxInt);
    if fuentes[k].dim_BC > 0 then
    begin
      if (oldIvar_xr = ivar_xr) and (oldIvar_xd = ivar_xd) then //No registro estado
      begin
        fuentesConBCSinEstadoEnCF[nFuentesSinEstado] := fuentes[k];
        nFuentesSinEstado := nFuentesSinEstado + 1;
      end
      else
      begin
        fuentesConBCConEstadoEnCF[nFuentesConEstado] := fuentes[k];
        nFuentesConEstado := nFuentesConEstado + 1;
      end;
    end;
    oldIvar_xr := ivar_xr;
    oldIvar_xd := ivar_xd;
  end;


  if nFuentesSinEstado <> 0 then
    fuentesConBCSinEstadoEnCF := copy(fuentesConBCSinEstadoEnCF, 0, nFuentesSinEstado)
  else
    fuentesConBCSinEstadoEnCF := nil;

  if nFuentesConEstado <> 0 then
    fuentesConBCConEstadoEnCF := copy(fuentesConBCConEstadoEnCF, 0, nFuentesConEstado)
  else
    fuentesConBCConEstadoEnCF := nil;

  Result := ivar_xr + ivar_xd;
end;

function TSalaDeJuego.ContarVariablesDeEstado: integer;
begin
  optx_nvxs;
  Result := ivar_xr + ivar_xd;
end;

function TSalaDeJuego.generarResumenTermicoPrimerasFichas: string;
var
  archi: TextFile;
  i: integer;
  res: string;
begin
  if not DirectoryExists(dirResultadosCorrida) then
    MkDir(dirResultadosCorrida);
  res := dirResultadosCorrida + 'resumen_termico_' +
    nombreArchSinExtension(archiSala_) + '_' + EscenarioActivo.nombre + '.xlt';
  AssignFile(archi, res);
  try
    Rewrite(archi);
    TGTer.generarLineaEncabezadosResumen(archi);
    for i := 0 to self.gens.Count - 1 do
      if self.gens[i] is TGTer then
      begin
        writeln(self.gens[i].nombre + ' TGter ');
        (self.gens[i] as TGter).generarLineaResumenPrimerFicha(archi);
      end
      else
      begin
        writeln(self.gens[i].nombre + ' .... ' + self.gens[i].ClassName);
      end;
    Result := res;
  finally
    CloseFile(archi);
  end;
end;



procedure TSalaDeJuego.EvolucionarEstado;
var
  k: integer;
begin
  for k := 0 to lst_actores_evolucionarEstado.Count - 1 do
    TActor(lst_actores_evolucionarEstado[k]).EvolucionarEstado;
  for k := 0 to lst_fuentes_evolucionarEstado.Count - 1 do
    TFuenteAleatoria(lst_fuentes_evolucionarEstado[k]).EvolucionarEstado;
end;



(*
procedure TSalaDeJuego.inicializarSimulacion(const SalaMadre: TSalaDeJuego;
  const costoFuturo, costoFuturoAuxiliar: TMatOfNReal);
var
  DimX, k: integer;
begin
  InicializarSimulacion_subproc01(True);
  Preparar_CrearCF_y_regsitrar_variables_de_estado;
  if CostoFuturo <> nil then
  begin
    dimX := ivar_xr + ivar_xd;
    if dimX > 0 then
    begin
      globs.CF := TAdminEstados.Create(ivar_xr, ivar_xd, globs.NPasos);
      //    globs.ActualizadorLPD.ActualizarFichasHasta( globs.fechaFin  );
      for k := 0 to high(actores) do
        actores[k].optx_RegistrarVariablesDeEstado(globs.CF);
      for k := 0 to high(fuentes_) do
        fuentes_[k].optx_RegistrarVariablesDeEstado(globs.CF);
    end;
    globs.CF.CrearElEspacioTiempo(
      globs.fechaIniOpt,
      globs.fechaFinOpt,
      globs.HorasDelPaso, costoFuturo, globs.Deterministico);
  end;
end;

procedure TSalaDeJuego.|(print: boolean);
begin
  globs.EstadoDeLaSala := CES_SIMULANDO;

  //Para sacar los warnings
  CFAux := nil;
  CFaux_AlInicioDelPaso := 0;

{$IFDEF DUMP_TEXT_SIMRES}
  if print then
  begin
    //Creo el archivo de simres
    if not DirectoryExists(dirResultadosCorrida) then
      MkDir(dirResultadosCorrida);
    if globs.Calcular_EmisionesCO2 then
      Calculador_CO2 := TCalculadorEmisionesCO2.Create(self);
  end;
{$ENDIF}

  spx := TMipSimplex.Create_init(1, 1, 1, self.getNombreVar, self.getNombreRes);
  // solo para que esté definido.

  // Preparamos la sala y los actores.
  PrepararMemoriaYListados;
  PrepararActualizadorFichasLPD(True);

  //Publica todas las variables de la sala
  publicarTodasLasVariables;

  // Determinamos la dimesión del espacio de estados y si es necesario
  // crear frames auxiliares del estado para cálculos iterativos.
  optx_nvxs;

  Armar_lst_BarridoFijarEstadoDeActoresYFuentesToEstrella;
  Armar_lst_Sim_Paso_Fin;
  Armar_lst_CalcularGradienteDeInversion;
  Armar_lst_EvolucionarEstado;
  Armar_lst_necesitoIterar;
  Armar_lst_Sim_cronicaIdInicio;
end;
*)


procedure TSalaDeJuego.FinSim_workers;
begin
  FinSimulacion;
  globs.EstadoDeLaSala := CES_SIMULACION_TERMINADA;
end;

function TSalaDeJuego.FinSim_Master(Print: boolean): NReal;
var
  res: NReal;

begin
  if print then
  begin
    {$IFDEF DUMP_TEXT_SIMRES}
    SimPrint_Final(fsal);
    Close(fsal);
    if globs.Calcular_EmisionesCO2 then
      TCalculadorEmisionesCO2(Calculador_CO2).Free;
    {$ENDIF}
    res := Acumuladores.PrinArchi(archi_simcosto);
  end
  else
    res := Acumuladores.VE_CF_MUSD;

  if globs.EstadoDeLaSala <> CES_SIMULACION_TERMINADA then
    globs.EstadoDeLaSala := CES_SIMULACION_ABORTADA;

  if CFAux <> nil then
    CFAux.Free;

  Result := res;
end;

procedure TSalaDeJuego.SimPrint_EncabezadoDeCronica(var fsal: Textfile);
var
  kfuenterres, kactorres: integer;
begin
  writeln(fsal);
  Write(fsal, 'CRONICA:', #9, globs.kCronica, #9, 'SemillaAleatoria:', #9,
    globs.MadresUniformes.get_UltimaSemilla);
  for kfuenterres := 0 to lst_Sim_cronicaIdInicio.Count - 1 do
  begin
    idCronicaInicioFuenteK :=
      TFuenteAleatoria(lst_Sim_cronicaIdInicio[kfuenterres]).cronicaIdInicio;
    if idCronicaInicioFuenteK <> '' then
      Write(fsal, #9, idCronicaInicioFuenteK);
  end;
  writeln(fsal);

  // PRINT kencab= 0
  Write(fsal, '-', #9, '-');
  for kactorres := 0 to high(actores) do
    actores[kactorres].sim_PrintResultados_Encab(fsal, 0);
  for kfuenterres := 0 to high(fuentes) do
    fuentes[kfuenterres].sim_PrintResultados_Encab(fsal, 0);
  Write(fsal, #9, '-');
  if CFaux <> nil then
    Write(fsal, #9, '-');
  Write(fsal, #9, '-');
  Write(fsal, #9, '-');
  Write(fsal, #9, '-');
  writeln(fsal, #9, '-');

  // PRINT kencab= 1
  Write(fsal, '-', #9, '-');
  for kactorres := 0 to high(actores) do
    actores[kactorres].sim_PrintResultados_Encab(fsal, 1);
  for kfuenterres := 0 to high(fuentes) do
    fuentes[kfuenterres].sim_PrintResultados_Encab(fsal, 1);
  Write(fsal, #9, '[USD]');
  if CFaux <> nil then
    Write(fsal, #9, '[USD]');
  Write(fsal, #9, '[USD]');
  Write(fsal, #9, '[USD]');
  Write(fsal, #9, '[USD]');
  writeln(fsal, #9, '[u]');

  // PRINT kencab= 2
  Write(fsal, '-', #9, '-');

  for kactorres := 0 to high(actores) do
    actores[kactorres].sim_PrintResultados_Encab(fsal, 2);

  for kfuenterres := 0 to high(fuentes) do
    fuentes[kfuenterres].sim_PrintResultados_Encab(fsal, 2);

  Write(fsal, #9, 'CF_AlInicioDelPaso');
  if CFaux <> nil then
    Write(fsal, #9, 'CFaux');
  Write(fsal, #9, 'CPDirecto');
  Write(fsal, #9, 'UPDirecta');
  Write(fsal, #9, 'CPSimplex');
  writeln(fsal, #9, 'cntIterPaso');

  // PRINT kencab= 3
  Write(fsal, 'Paso', #9, 'FechaInicioDelPaso');
  for kactorres := 0 to high(actores) do
    actores[kactorres].sim_PrintResultados_Encab(fsal, 3);
  for kfuenterres := 0 to high(fuentes) do
    fuentes[kfuenterres].sim_PrintResultados_Encab(fsal, 3);
  Write(fsal, #9, '0');
  if CFaux <> nil then
    Write(fsal, #9, '0');
  Write(fsal, #9, '0');
  Write(fsal, #9, '0');
  Write(fsal, #9, '0');
  writeln(fsal, #9, '0');

end;


procedure TSalaDeJuego.SimPrint_ResultadosDelPaso(var fsal: Textfile);
var
  kactorres, kfuenterres: integer;
begin

  Write(fsal, IntToStr(globs.kPaso_Sim), #9, globs.FechaInicioDelPaso.AsISOStr);
  for kactorres := 0 to high(actores) do
    actores[kactorres].sim_PrintResultados(fsal);
  for kfuenterres := 0 to high(fuentes) do
    fuentes[kfuenterres].sim_PrintResultados(fsal);

  Write(fsal, #9, FloatToStrF(CF_AlInicioDelPaso, formatoReales, 12, 1));
  if CFAux <> nil then
    Write(fsal, #9, FloatToStrF(CFAux_AlInicioDelPaso, formatoReales, 12, 1));

  Write(fsal, #9, FloatToStrF(costoDirectoDelPaso, formatoReales, 12, 1));
  Write(fsal, #9, FloatToStrF(utilidadDirectaDelPaso, formatoReales, 12, 1));

  Write(fsal, #9, FloatToStrF(costoDelPaso_spx, formatoReales, 12, 1));
  writeln(fsal, #9, globs.cntIteracionesDelPaso);

end;


procedure TSalaDeJuego.Clear_ResultadosSim;
var
  archi: string;
  archi_mask: string;
  Info: TSearchRec;
begin
  archi_mask := dirResultadosCorrida + 'simres' + '_' +
    IntToStr(globs.semilla_inicial_sim) + '_' + EscenarioActivo.nombre + '_d*';
  if FindFirst(archi_mask, faArchive, Info) = 0 then
  begin
    repeat
      archi := dirResultadosCorrida + info.Name;
      system.writeln('Eliminando: ', archi);
      SysUtils.deletefile(archi);
    until FindNext(info) <> 0;
  end;
  SysUtils.FindClose(Info);
end;

procedure TSalaDeJuego.SimPrint_CrearArchivo(var fsal: Textfile;
  id_hilo, kCronicaIni, kCronicaFin: integer);
var
  archi_fsal: string;

begin
  //Creo el archivo de simres
  if not DirectoryExists(dirResultadosCorrida) then
    MkDir(dirResultadosCorrida);

  archi_fsal := dirResultadosCorrida + 'simres' + '_' +
    IntToStr(globs.semilla_inicial_sim)
    //+ 'x' + IntToStr(Globs.NCronicasSim)
    + '_' + EscenarioActivo.nombre;

  (*
  if SalaMadre <> nil then
  begin
  *)
  archi_fsal := archi_fsal + '_d' + padNd(IntToStr(kCronicaIni), 5) +
    'a' + padNd(IntToStr(kCronicaFin), 5) + 'h' + IntToStr(id_hilo);
  (*
  end;
  *)
  archi_fsal := archi_fsal + '.xlt';

  assignfile(fsal, archi_fsal);
  rewrite(fsal);

  if globs.Calcular_EmisionesCO2 then
    Calculador_CO2 := TCalculadorEmisionesCO2.Create(self);
end;


procedure TSalaDeJuego.SimPrint_Inicio(var f: TextFile);
var
  iposteres, kactorres: integer;
begin
  system.Writeln(f, 'Versión del simulador:'#9, vSimSEESimulador_);
  system.writeln(f, 'Inicio simulación: '#9, DateTimeToIsoStr(now()));
  system.Writeln(f, 'FechaIniSim:'#9, globs.fechaIniSim.AsISOStr,
    #9'FechaFinSim:'#9, globs.fechaFinSim.AsISOStr);
  system.writeln(f, 'NCronicas:'#9, globs.NCronicasSim);
  system.writeln(f, 'NPasos:'#9, globs.nPasos);
  system.writeln(f, 'NPostes:'#9, length(globs.Durpos));
  system.Write(f, 'DurPos[h]:');
  for iposteres := 0 to high(globs.DurPos) do
    Write(f, #9, globs.DurPos[iposteres]);
  system.writeln(f);
  system.writeln(f, 'NActores:'#9, length(actores));

  TActor.printEncabezadoResumenSim(f);

  for kactorres := 0 to high(actores) do
    actores[kactorres].printResumenSim(f);
end;

procedure TSalaDeJuego.SimPrint_Final(var f: TextFile);
begin
  system.writeln(f, 'Fin simulación:'#9, DateTimeToIsoStr(now()));
end;


procedure TSalaDeJuego.Calc_CF_InicioDelPaso(CFAux: TAdminEstados);
var
  tmpCF: TAdminEstados;
begin
  if globs.CF <> nil then
  begin
    fuentes_ActualizarEstadoGlobal(False);
    actores_ActualizarEstadoGlobal(False);
    CF_AlInicioDelPaso := globs.CF.costoContinuo(globs.kPaso_Opt);
  end
  else
    CF_AlInicioDelPaso := 0;
  if CFaux <> nil then
  begin
    tmpCF := globs.CF;
    globs.CF := CFaux;
    globs.CFAuxActivo := True;
    fuentes_ActualizarEstadoGlobal(False);
    actores_ActualizarEstadoGlobal(False);
    globs.CFAuxActivo := False;
    globs.CF := tmpCF;
    CFaux_AlInicioDelPaso := CFaux.costoContinuo(globs.kPaso_Opt);
  end;
end;


function TSalaDeJuego.archi_simcosto: string;
begin
  Result := dirResultadosCorrida + 'simcosto_' + IntToStr(globs.semilla_inicial_sim) +
    'x' + IntToStr(Globs.NCronicasSim) + '_' + EscenarioActivo.nombre + '.xlt';
end;

function TSalaDeJuego.Simular(id_hilo: integer; print: boolean;
  kCronicaIni: integer = 0; kCronicaFin: integer = 0): NReal;
var
  costoAcumCronica: NReal;
  utilidadAcumCronica: NReal;
  qAct: NReal;

{$IFDEF DUMP_TEXT_SIMRES}
  fsal: TextFile;
  Calculador_CO2: TCalculadorEmisionesCO2;
{$ENDIF}
  CF_AlFinalDeLaCronica: NReal;
  flg_EnGuardaSim: boolean;

begin
  globs.ObligarDisponibilidad_1_ := globs.ObligarDisponibilidad_1_Sim;

  globs.EstadoDeLaSala := CES_SIMULANDO;
  //Para sacar los warnings
  CFaux_AlInicioDelPaso := 0;
  VE_CF := 0;
  VaR05_CF := 0;
  CVaR05_CF := 0;

  if (kCronicaIni <= 0) or (kCronicaFin <= 0) then
  begin
    globs.kCronica := 1;
    kCronicaIni := 1;
    kCronicaFin := globs.NCronicasSim;
  end
  else
    globs.kCronica := kCronicaIni;

  globs.NCronicasSim := kCronicaFin - kCronicaIni + 1;

{$IFDEF DUMP_TEXT_SIMRES}
  if print then
    SimPrint_CrearArchivo(fsal, id_hilo, kCronicaIni, kCronicaFin);
{$ENDIF}

  try
    // solo para que esté definido.
    spx := TMipSimplex.Create_init(1, 1, 1, self.getNombreVar, self.getNombreRes);

    // Preparamos la sala y los actores.
    PrepararMemoriaYListados;
    PrepararActualizadorFichasLPD(True);
    InicioSim;

    // Determinamos la dimesión del espacio de estados y si es necesario
    // crear frames auxiliares del estado para cálculos iterativos.

    optx_nvxs;
    Armar_lst_BarridoFijarEstadoDeActoresYFuentesToEstrella;
    Armar_lst_Sim_Paso_Fin;
    Armar_lst_CalcularGradienteDeInversion;
    Armar_lst_EvolucionarEstado;
    Armar_lst_necesitoIterar;
    Armar_lst_Sim_cronicaIdInicio;


    //Publicamos las variables
    if globs.publicarSoloVariablesUsadasEnSimRes3 then
    begin
      publicarSoloVariablesUsadasEnSimRes3;
    end
    else
    begin
      publicarTodasLasVariables;
    end;


    {$IFDEF DUMP_TEXT_SIMRES}
    if print then
    begin
      SimPrint_Inicio(fsal);
    end;
    {$ENDIF}
    globs.procNot(globs.procNot_InicioSimulacion);


    if SalaMadre = nil then
      Acumuladores := TAcumuladores_Sim.Create(globs, globs.NCronicasSim)
    else
      Acumuladores := SalaMadre.Acumuladores;

    while (globs.kCronica <= kCronicaFin) and (not globs.abortarSim) do
    begin
      writeln('sim: ', id_hilo, ', ', trunc(
        (1 - (globs.kCronica - kCronicaIni) / (kCronicaFin - kCronicaINi + 1)) * 100));

      Sim_Cronica_Inicio;
      // inicializamos los acumuladore de costo y utilidad de la crónica
      costoAcumCronica := 0;
      utilidadAcumCronica := 0;
      qAct := 1;

      // Si corresponde activamos la Guarda de Simulación
      flg_EnGuardaSim := globs.fechaGuardaSim.EsMayorQue(globs.fechaIniSim) = 1;

      {$IFDEF DUMP_TEXT_SIMRES}
      if print then
      begin
        SimPrint_EncabezadoDeCronica(fsal);
        if globs.Calcular_EmisionesCO2 then
          Calculador_CO2.InicioDeCronica;
      end;
      {$ENDIF}

      //   globs.ActualizadorLPD.DumpListaToArchi('c:\basura\ActualizadorLPD_'+INtTostr( globs.idHilo )+'_'+IntToStr(id_hilo )+'.txt');


      while (globs.kPaso_Sim <= globs.nPasos) and (not globs.abortarSim) do
      begin

        //        writeln( 'globs.kCronica: ', globs.kCronica , ', globs.kPaso_: ',
        //        globs.kPaso_, ', globs.nPasos: ', globs.nPasos );
        globs.procNot(globs.procNot_InicioPaso);

        // si está activada la GuardaSim, nos fijamos si corresponde desactivarla
        if flg_EnGuardaSim then
          flg_EnGuardaSim := globs.fechaGuardaSim.EsMayorQue(
            globs.FechaInicioDelpaso) = 1;

        // Actualiza los parámemtros dinámicos de todos los Entes (Actores, Fuentes, etc.)
        globs.ActualizadorLPD.ActualizarFichasHasta(globs.FechaInicioDelpaso);

        // EVENTO: PrepararPaso_as
        //    Actores + Flucar antes de sorteos
        PrepararPaso_as;

        // EVENTO: SorteosDelPaso( true )
        //    Fuentes (sorteo y calcula bornes calculados) + Actores
        SorteosDelPasoSim(True);

        Calc_CF_InicioDelPaso(CFAux);
        // rch@201408261144 Agrego que (a continuación) que Actores y Fuentes
        // POYECTEN el Xs (lo de CF_AlInicioDelPaso está demás).
        // Esto hace que el cálculo de CF Al inicio del Paso no sea necesario, pero
        // no lo borro ahora para no jorobar las plantillas SimRes3 que están funcioando.
        // pero se puede ganar eficiencia haciendo


        //fbarreto@062420151636 Se mueve el procedimiento Fuentes_PrepararPaso_ps
        // porque los actores necesitan a las fuentes preparadas para actualizar el estado global
        // (actores_ActualizarEstadoGlobal)
        // Nota: En la ubicacion anterior se deja la llamada comentada.

        // EVENTO: Las Fuentes se preparan PostSorteos para dar el paso.
        //         Por eficiencia esto se hace fuera del bucle de iteraciones del paso
        //         pues se supone que las fuentes no necesitar ITERAR.
        Fuentes_PrepararPaso_ps( true );

        // EVENTO: Los Actores y las Fuentes PROYECTAN su estado (Xs) al final del paso
        //         lo que da mejor informaicón para el calculo del gradiente de CF al final
        //         del paso que suponer que el estado permanecía fijo. Este cambio es fundamental
        //         para el funcionamiento del vector de deciciones de compras/desvíos de la Regasificadora
        fuentes_ActualizarEstadoGlobal(True);
        actores_ActualizarEstadoGlobal(True);

        // fbarreto@062420151636: ubicacion original.
        // EVENTO: Las Fuentes se preparan PostSorteos para dar el paso.
        //         Por eficiencia esto se hace fuera del bucle de iteraciones del paso
        //         pues se supone que las fuentes no necesitar ITERAR.
        //Fuentes_PrepararPaso_ps;

        // EVENTOs: Actores_PrepararPaso_ps_pre y Actores_PrepararPaso_ps
        //         En esta llamada, si se está usando el método de cálculo
        //         de demanda NETA, se realiza el cálculo de la demanda NETA
        //         y el POSTIZADO efectivo del paso de tiempo. Como consecuencia
        //         se llama al EVENTO: PrepararPaso_ps_pre de los Actores.
        //         Luego se llama al EVENTO: PreaparaPaso_ps de Actores y FLUCAR
        //         Los Actores se preparan PostSorteos para dar el paso.
        //         En esta preparación, cada Actor, calcula los parámetros
        //         dependientes de los valores de las fuentes, los sorteos y
        //         del estado del sistema de su modelo.
        //         Además de los Actores, también se prepara el Iterador
        //         FLUCAR si es que se está usando.
        Actores_PrepararPaso_ps_pre;

        globs.cntIteracionesDelPaso := 0;
        repeat
          Inc(globs.cntIteracionesDelPaso);

          Actores_PrepararPaso_ps;
          CostoDelPaso_spx := ResolverPaso;

        until (globs.cntIteracionesDelPaso >=
            globs.NMAX_ITERACIONESDELPASO_SIM) or (not NecesitoIterar);
        // El bucle de iteraciones se repite hasta alcanzar el número máximo
        // especificado o hasta que ningún Actor ni el Iterador FLUCAR
        // indica que necesita iterar.

        Sim_Paso_Fin;
        CalcularGradientesDeInversion;

        {$IFDEF DUMP_TEXT_SIMRES}
        if print and not flg_EnGuardaSim then
        begin
          SimPrint_ResultadosDelPaso(fsal);
          if globs.Calcular_EmisionesCO2 then
            Calculador_CO2.FinDelPaso;
        end;
        {$ENDIF}

        EvolucionarEstado;

        globs.Fijar_kPaso(globs.kPaso_Sim + 1);

        if not flg_EnGuardaSim then
        begin
          costoAcumCronica := costoAcumCronica + costoDirectoDelpaso * qAct;
          utilidadAcumCronica := utilidadAcumCronica + utilidadDirectaDelPaso * qAct;
          qAct := qAct * globs.fActPaso;
        end;
      end;

      (*** ahora guardo el resultado de la crónica y le sumo el CF_AlFinal de la misma **)
      if globs.CF <> nil then
      begin
        fuentes_ActualizarEstadoGlobal(False);
        actores_ActualizarEstadoGlobal(False);
        CF_AlFinalDeLaCronica := globs.CF.costoContinuo(globs.kPaso_Sim);
      end
      else
        CF_AlFinalDeLaCronica := 0;

      Acumuladores.cdpAcum[globs.kcronica - 1] := costoAcumCronica;
      Acumuladores.udpAcum[globs.kcronica - 1] := utilidadAcumCronica;

      Acumuladores.CF_final[globs.kcronica - 1] := qAct * CF_AlFinalDeLaCronica;

      Acumuladores.costosAcum[globs.kcronica - 1] :=
        costoAcumCronica + Acumuladores.CF_final[globs.kcronica - 1];

      if CFaux <> nil then
      begin
        tmpCF := globs.CF;
        globs.CF := CFaux;
        globs.CFAuxActivo := True;
        fuentes_ActualizarEstadoGlobal(False);
        actores_ActualizarEstadoGlobal(False);
        globs.CFAuxActivo := False;
        globs.CF := tmpCF;
        CF_AlFinalDeLaCronica := CFaux.costoContinuo(globs.kPaso_Opt);
        Acumuladores.CFaux_final[globs.kcronica - 1] := qAct * CF_AlFinalDeLaCronica;
        Acumuladores.costosAcum_aux[globs.kcronica - 1] :=
          costoAcumCronica + Acumuladores.CFaux_final[globs.kcronica - 1];
      end;

    {$IFDEF DUMP_TEXT_SIMRES}
      if print then
        if globs.Calcular_EmisionesCO2 then
          Calculador_CO2.FinCronica;
    {$ENDIF}

      Sim_Cronica_Fin; // entre otras cosas incrementa globs.kCronica

    end;
    FinSimulacion;
    globs.EstadoDeLaSala := CES_SIMULACION_TERMINADA;

    if print then
    begin
    {$IFDEF DUMP_TEXT_SIMRES}
      SimPrint_Final(fsal);
      Close(fsal);
      if globs.Calcular_EmisionesCO2 then
        Calculador_CO2.Free;
    {$ENDIF}
      if SalaMadre = nil then
      begin
        VE_CF := Acumuladores.PrinArchi(archi_simcosto);
        acumuladores.GetResumen(VE_CF, VaR05_CF, CVaR05_CF);
      end;
    end
    else
    if SalaMadre = nil then
      acumuladores.GetResumen(VE_CF, VaR05_CF, CVaR05_CF);

    if SalaMadre = nil then
      Acumuladores.Free;

  finally

    if globs.EstadoDeLaSala <> CES_SIMULACION_TERMINADA then
      globs.EstadoDeLaSala := CES_SIMULACION_ABORTADA;

  end;
  Result := VE_CF;
end;


function TSalaDeJuego.PreprocesarPlantillasActivasDelEscenarioActivo: integer;
var
  plantillas: TStrings;
  sustitutor: TSustituirVariablesPlantilla;
  k: integer;
  idPlantillaSR3: string;
begin
  plantillas := listaPlantillasSimRes3.lista_activas;
  for k := 0 to plantillas.Count - 1 do
  begin
    sustitutor := TSustituirVariablesPlantilla.Create(0);
    idPlantillaSR3:= nombreArchSinExtension( plantillas[k]);
    sustitutor.sustituirVariables(
      plantillas[k], self,
      EscenarioActivo.nombre,
      idPlantillaSR3,
      globs.semilla_inicial_sim);
    sustitutor.Free;
  end;
  Result := plantillas.Count;
  plantillas.Free;
end;


function TSalaDeJuego.PreprocesarPlantillasActivasDelEscenario(
  escenario: TEscenario_rec): integer;
var
  plantillas: TStrings;
  sustitutor: TSustituirVariablesPlantilla;
  k: integer;
  idPlantillaSR3: string;
begin
  plantillas := listaPlantillasSimRes3.lista_activas( escenario.capasActivas );
  for k := 0 to plantillas.Count - 1 do
  begin
    sustitutor := TSustituirVariablesPlantilla.Create(0);
    idPlantillaSR3:= nombreArchSinExtension( plantillas[k]);
    sustitutor.sustituirVariables(
      plantillas[k], self,
      Escenario.nombre,
      idPlantillaSR3,
      globs.semilla_inicial_sim);
    sustitutor.Free;
  end;
  Result := plantillas.Count;
  plantillas.Free;
end;


procedure TSalaDeJuego.ImprimirPotenciasFirmes;

  procedure PrintEncabezado(var fPotsFirmes: TextFile);
  var
    iposteres, kactor: integer;
  begin
    system.Writeln(fPotsFirmes, 'Versión del simulador:'#9, vSimSEESimulador_);
    system.writeln(fPotsFirmes, 'Inicio simulación: '#9, DateTimeToIsoStr(now()));
    system.Writeln(fPotsFirmes, 'FechaIniSim: '#9, globs.fechaIniSim.AsISOStr,
      #9, 'FechaFinSim: ', #9, globs.fechaFinSim.AsISOStr);
    system.writeln(fPotsFirmes, 'NCronicas:'#9, 1);
    system.writeln(fPotsFirmes, 'NPasos:'#9, globs.nPasos);
    system.writeln(fPotsFirmes, 'NPostes:'#9, length(globs.Durpos));
    system.Write(fPotsFirmes, 'DurPos[h]:');
    for iposteres := 0 to high(globs.DurPos) do
      Write(fPotsFirmes, #9, globs.DurPos[iposteres]: 6: 0);
    system.writeln(fPotsFirmes);
    system.writeln(fPotsFirmes, 'NActores:'#9, length(actores));
    TActor.printEncabezadoResumenSim(fPotsFirmes);
    for kactor := 0 to high(actores) do
      actores[kactor].printResumenSim(fPotsFirmes);

    writeln(fPotsFirmes);
    writeln(fPotsFirmes, 'CRONICA:'#9, globs.kCronica, #9, 'SemillaAleatoria:'#9,
      globs.MadresUniformes.get_UltimaSemilla);

    // PRINT kencab= 0
    Write(fPotsFirmes, '-'#9'-');
    for kactor := 0 to high(termicos) do
      termicos[kactor].sim_PrintResultados_Encab_PotFirme(fPotsFirmes, 0);
    writeln(fPotsFirmes);

    // PRINT kencab= 1
    Write(fPotsFirmes, '-'#9'-');
    for kactor := 0 to high(termicos) do
      termicos[kactor].sim_PrintResultados_Encab_PotFirme(fPotsFirmes, 1);
    writeln(fPotsFirmes);

    // PRINT kencab= 2
    Write(fPotsFirmes, 'Paso'#9'FechaInicioDelPaso');
    for kactor := 0 to high(termicos) do
      termicos[kactor].sim_PrintResultados_Encab_PotFirme(fPotsFirmes, 2);
    writeln(fPotsFirmes);
  end;

var
  ipaso, kactor: integer;
  fPotsFirmes_porpaso: TextFile;
  fPotsFirmes_Mensuales: TextFile;
  potFirme: array of TDAOfNReal;
  mes, anio: array of word;
  iActor: integer;
  //  I: Integer;
  cnt, jpaso: integer;
  a: NReal;

begin
  globs.EstadoDeLaSala := CES_SIMULANDO;
  try
    // Preparamos la sala y los actores.
    globs.kCronica := 1;
    PrepararMemoriaYListados;
    PrepararActualizadorFichasLPD(True);

    //Publicamos las variables
    if globs.publicarSoloVariablesUsadasEnSimRes3 then
      publicarSoloVariablesUsadasEnSimRes3
    else
      publicarTodasLasVariables;

    Sim_Cronica_Inicio;

    setLength(potFirme, length(termicos));
    for iActor := 0 to high(termicos) do
      setLength(potFirme[iActor], globs.NPasos);
    setLength(mes, globs.npasos);
    setlength(anio, globs.NPasos);

    //Creo el archivo de simres
    if not DirectoryExists(dirResultadosCorrida)
    { *Converted from DirectoryExists*  } then
      MkDir(dirResultadosCorrida);

    assignfile(fPotsFirmes_porpaso, dirResultadosCorrida +
      'potencias_Termicas_Firmes_porpaso' + '_' + EscenarioActivo.nombre + '.xlt');
    rewrite(fPotsFirmes_porpaso);
    PrintEncabezado(fPotsFirmes_porpaso);

    assignfile(fPotsFirmes_mensuales, dirResultadosCorrida +
      'potencias_Termicas_Firmes_mensuales' + '_' + EscenarioActivo.nombre + '.xlt');
    rewrite(fPotsFirmes_mensuales);
    PrintEncabezado(fPotsFirmes_mensuales);

    while (globs.kPaso_Sim <= globs.nPasos) do
    begin
      globs.procNot(globs.procNot_InicioPaso);
      globs.ActualizadorLPD.ActualizarFichasHasta(globs.FechaInicioDelpaso);
      mes[globs.kPaso_Sim - 1] := globs.MesInicioDelPaso;
      anio[globs.kPaso_Sim - 1] := globs.AnioInicioDelPaso;
      Write(fPotsFirmes_porpaso, IntToStr(globs.kPaso_Sim), #9,
        globs.FechaInicioDelPaso.AsISOStr);
      for kactor := 0 to high(termicos) do
      begin
        potFirme[kActor][globs.kPaso_Sim - 1] := termicos[kactor].PotenciaFirme;
        termicos[kactor].sim_PrintResultados_PotFirme(fPotsFirmes_porpaso);
      end;
      writeln(fPotsFirmes_porpaso);
      globs.Fijar_kPaso(globs.kPaso_Sim + 1);
    end;
    globs.EstadoDeLaSala := CES_SIMULACION_TERMINADA;


    ipaso := 0;
    jpaso := 1;
    while ipaso < globs.npasos do
    begin
      Write(fPotsFirmes_mensuales, anio[ipaso], #9, mes[ipaso]);

      for kactor := 0 to high(termicos) do
      begin
        jpaso := ipaso + 1;
        a := potFirme[kactor][ipaso];
        cnt := 1;
        while (jpaso < globs.npasos) and (mes[jpaso] = mes[ipaso]) do
        begin
          Inc(cnt);
          a := a + potFirme[kactor][jpaso];
          Inc(jpaso);
        end;
        a := a / cnt;
        Write(fPotsFirmes_mensuales, #9, a);
      end;
      ipaso := jpaso;
      writeln(fPotsFirmes_mensuales);
    end;

  finally
    system.writeln(fPotsFirmes_porpaso, 'Fin simulación: ', #9, DateTimeToStr(now()));
    closefile(fPotsFirmes_porpaso);
    closefile(fpotsFirmes_mensuales);
  end;
end;

procedure Print_UnidadesDisponibles_xlt(archiSalida: string;
  etiquetas: TDAOfString; fechas: TDAOfDateTime; unidades: TMatOfNInt);

var
  xls: textfile;
  kPaso: integer;
  NPasos: integer;
  iserie: integer;

  procedure xls_write(s: string);
  begin
    Write(xls, s, #9);
  end;

  procedure xls_writeln(s: string = '');
  begin
    writeln(xls, s, #9);
  end;

begin
  assignfile(xls, archiSalida);
  rewrite(xls);
  xls_Write(' ');
  xls_Write(' ');
  for iserie := 0 to high(etiquetas) do
    xls_Write(etiquetas[iserie]);
  xls_writeln;

  NPasos := length(fechas);
  for kPaso := 1 to NPasos do
  begin
    xls_Write(IntToStr(kPaso));
    xls_Write(DateTimeToIsoStr(fechas[kPaso - 1]));
    for iserie := 0 to high(unidades) do
      xls_Write(IntToStr(unidades[iserie][kPaso - 1]));
    xls_writeln;
  end;
  xls_Write('Fin simulación: ');
  xls_writeln(DateTimeToStr(now()));
  closefile(xls);
end;



procedure TSalaDeJuego.ImprimirUnidadesInstaladas;
var
  ipaso, kactor: integer;
  etiquetas: TDAOfString;
  fechas: TDAOfDateTime;
  unidadesDisp: TMatOfNInt;
  iActor: integer;
  cnt, jpaso: integer;
  a: NReal;
  ngeneradores: integer;
  Generadores: TDAOfGenerador;
  i, k, j: integer;
  nombre: string;
  cnt_unidades: integer;
  kGen: integer;
  gen: TGenerador;
  iUnidad, kUnidad: integer;
  archiSalida: string;

begin
  globs.EstadoDeLaSala := CES_SIMULANDO;

  // Preparamos la sala y los actores.
  globs.kCronica := 1;
  PrepararMemoriaYListados;
  PrepararActualizadorFichasLPD(True);
  Sim_Cronica_Inicio;

  // Creamos array con puneros a los GENERADORES
  // y de paso contabilizamos el total de unidades (por los CCs u otros que pudieran
  // tener más de un tipo de unidad por actor.
  setLength(Generadores, length(actores));
  cnt_unidades := 0;
  ngeneradores := 0;
  for iActor := 0 to high(actores) do
    if actores[iActor] is TGenerador then
    begin
      gen := actores[iActor] as TGenerador;
      Generadores[ngeneradores] := gen;
      Inc(ngeneradores);
      cnt_unidades := cnt_unidades + length(gen.paUnidades.nUnidades_Instaladas);
    end;
  setLength(Generadores, ngeneradores);

  setlength(etiquetas, cnt_unidades);
  iUnidad := 0;
  for kGen := 0 to high(generadores) do
  begin
    gen := Generadores[kGen];

    for kUnidad := 0 to high(gen.paUnidades.nUnidades_Instaladas) do
    begin
      etiquetas[iunidad] := gen.nombre + '_' + IntToStr(kUnidad);
      Inc(iunidad);
    end;
  end;

  setLength(unidadesDisp, cnt_unidades);
  for i := 0 to high(unidadesDisp) do
    setLength(unidadesDisp[i], globs.NPasos);

  setlength(fechas, globs.nPasos);

  while (globs.kPaso_Sim <= globs.nPasos) do
  begin

    globs.procNot(globs.procNot_InicioPaso);
    globs.ActualizadorLPD.ActualizarFichasHasta(globs.FechaInicioDelpaso);

    fechas[globs.kPaso_Sim - 1] := globs.FechaInicioDelpaso.AsDt;

    iUnidad := 0;
    for kGen := 0 to high(generadores) do
    begin
      gen := generadores[kGen];
      for kUnidad := 0 to high(gen.paUnidades.nUnidades_Instaladas) do
      begin
        unidadesDisp[iUnidad][globs.kPaso_Sim - 1] :=
          gen.paUnidades.nUnidades_Instaladas[kUnidad];
        Inc(iUnidad);
      end;
    end;
    globs.Fijar_kPaso(globs.kPaso_Sim + 1);
  end;
  globs.EstadoDeLaSala := CES_SIMULACION_TERMINADA;



  archiSalida := dirResultadosCorrida + nombreArchSinExtension(self.archiSala_) +
    '_U_' + self.EscenarioActivo.nombre + '.xlt';


  Print_UnidadesDisponibles_xlt(
    archiSalida,
    etiquetas,
    fechas,
    unidadesDisp);

  setlength(generadores, 0);
  for iUnidad := 0 to high(unidadesDisp) do
    setlength(unidadesDisp[iUnidad], 0);
  setlength(unidadesDisp, 0);
  setlength(fechas, 0);
  setlength(etiquetas, 0);

end;


type

{ TFuenteRefRec }

TFuenteRefRec = class
  fuente: TFuenteAleatoria;
  referentes: TList;
  nivel: integer;
  constructor Create( aFuente: TFuenteAleatoria );
  procedure addReferente(aRec: TFuenteRefRec);
  procedure Destroy; virtual;
  procedure calc_nivel;
end;

constructor TFuenteRefRec.Create( aFuente: TFuenteAleatoria );
begin
  inherited Create;
  fuente:= aFuente;
  referentes:= TList.Create;
  nivel:= 0;
end;

procedure TFuenteRefRec.addReferente(aRec: TFuenteRefRec);
begin
  referentes.Add( aRec );
end;


procedure TFuenteRefRec.Destroy;
begin
  referentes.Free;
  inherited Destroy;
end;

procedure TFuenteRefRec.calc_nivel;
var
  i: integer;

begin
  if ( fuente is TEsclavizadorSubMuestreado ) or  ( fuente is TEsclavizadorSobreMuestreado ) then
  begin
    for i:= 0 to referentes.count -1 do
     inc( TFuenteRefRec( referentes[i] ).nivel );
  end;
end;


procedure TSalaDeJuego.ordenarFuentes;
var
  auxSwap, fuenteI: TFuenteAleatoria;
  huboReferencia: boolean;
  i, j: integer;
  refrecs: array of TFuenteRefRec;
  auxSwapRec: TFuenteRefRec;


begin
  setlength( refrecs, ListaFuentes_.Count );
  for i:= 0 to ListaFuentes_.Count -1 do
    refrecs[i]:= TFuenteRefRec.Create( TFuenteAleatoria(listaFuentes_[i]) );

  i := 0;
  //El -1 esta bien porque la ultima fuente no tiene despues de ella nadie,
  //particularmente nadie que la referencie
  while i < listaFuentes_.Count - 1 do
  begin
    fuenteI := TFuenteAleatoria(listaFuentes_[i]);
    huboReferencia := False;
    for j := i + 1 to listaFuentes_.Count - 1 do
    begin
      if fuenteI.referenciaFuente(TFuenteAleatoria(listaFuentes_[j])) then
      begin
        if TFuenteAleatoria(listaFuentes_[j]).referenciaFuente(fuenteI) then
          raise Exception.Create(
            'TSalaDeJuego.ordenarFuentes: hay un ciclo entre las fuentes.' +
            'Las fuentes ' + fuenteI.nombre + ' y ' +
            TFuenteAleatoria(listaFuentes_[j]).nombre + ' se referencian mutuamente.');

        auxSwapRec:= refrecs[i];
        refrecs[j].addReferente( auxSWapRec );
        refrecs[i]:= refrecs[j];
        refrecs[j]:= auxSwapRec;

        auxSwap := TFuenteAleatoria(listaFuentes_[j]);
        listaFuentes_[j] := fuenteI;
        listaFuentes_[i] := auxSwap;
        huboReferencia := True;
        break;
      end;
    end;
    if not huboReferencia then
      Inc(i);
  end;



  ListaFuentes_A:= TListaDeCosasConNombre.Create(0, 'ListaFuentes_A' );
  ListaFuentes_B:= TListaDeCosasConNombre.Create(0, 'ListaFuentes_B' );

  // Bien ahora recorro los registros de referencias para detectar quienes dependen
  // de fuentes que necesiten RESUMIR para crear otra lista
  for i:= 0 to ListaFuentes_.Count -1 do
  begin
    if refrecs[i].nivel = 0 then
      ListaFuentes_A.add( TFuenteAleatoria(listaFuentes_[i]) )
    else
      ListaFuentes_B.add( TFuenteAleatoria(listaFuentes_[i]) );
  end;

  for i:= 0 to high( refrecs )  do
     refrecs[i].Free;
  setlength(refrecs, 0 );

end;


{$IFDEF PDE_RIESGO}
procedure TSalaDeJuego.LlenarHistograma_CostoDelPaso_masCF_llegada(
  var HistoCF: TDAOfNReal; // Producto Cartesiano ce(kCron) x HistoCF1( jCronF )
  jBase: integer);
var
  costoDirectoDelPaso_Actores, costoDirectoDelPaso_Fuentes: NReal;
  utilidadDirectaDelPaso_Actores: NReal;
  k: integer;
  cdp: NReal;
begin

  if flg_IncluirPagosPotenciaYEnergiaEn_CF then
    costoDirectoDelPaso_Actores := costoDirectoDelpaso
  else
    costoDirectoDelPaso_Actores := costoOperativoDelPaso;
  (**
  costoDirectoDelPaso_Actores := 0;
  for k := 0 to high(Actores) do
    costoDirectoDelPaso_Actores :=
      costoDirectoDelPaso_Actores + Actores[k].costoDirectoDelPaso;
     **)

  // no me imagino fuentes con costo pero por las dudas ponemos
  costoDirectoDelPaso_Fuentes := 0;
  for k := 0 to lst_fuentes_costoDirectoDelPaso.Count - 1 do
    costoDirectoDelPaso_Fuentes :=
      costoDirectoDelPaso_Fuentes + TFuenteAleatoria(
      lst_fuentes_costoDirectoDelPaso[k]).costoDirectoDelPaso;

  utilidadDirectaDelPaso_Actores := utilidadDirectaDelPaso;
  (**
  utilidadDirectaDelPaso_Actores := 0.0;
  if globs.restarUtilidadesDelCostoFuturo then
  begin
    for k := 0 to high(Actores) do
      utilidadDirectaDelPaso_Actores :=
        utilidadDirectaDelPaso_Actores + Actores[k].utilidadDirectaDelPaso;
  end;
  **)


  fuentes_ActualizarEstadoGlobal(False);
  actores_ActualizarEstadoGlobal(False);
  // posicionamos la estrella de acuerdo al estado de los actores

  // Carga el histograma correspondiente al punto de llegada.
  globs.CF.mantoContinuo(HistoCF, jBase, globs.HistoCF1_);

  // completamos agregando el costo directo del paso y aplicando factor de actualización.
  cdp := costoDirectoDelPaso_Actores + costoDirectoDelPaso_Fuentes -
    utilidadDirectaDelPaso_Actores;
  for k := 0 to globs.NDiscHistoCF - 1 do
  begin
    {$IFDEF DEBUG_MULTI_HILO}
    writeln(fdebug_mh, 'estrella:'#9, globs.CF.ordinalEstrellaActual
      , #9'CActs:'#9, costoDirectoDelPaso_Actores, #9'CFuns: '#9,
      costoDirectoDelPaso_Fuentes, #9'CFLL'#9, HistoCF[jBase + k], #9'XLL',
      globs.CF.GetEstado_XLT);
    {$ENDIF}
    HistoCF[jBase + k] := cdp + globs.factPaso * HistoCF[jBase + k];
  end;
end;


procedure TSalaDeJuego.Crear_HistogramasCF(SalaMadre: TSalaDeJuego);
var
  k: integer;
begin
  if SalaMadre = nil then
  begin
    if globs.usar_CAR and globs.SortearOpt then
    begin
      setlength(globs.HistoCF1_, globs.CF.nEstrellasPorPuntoT);
      setlength(globs.HistoCF1_s, globs.CF.nEstrellasPorPuntoT);
      for k := 0 to high(globs.HistoCF1_) do
      begin
        setlength(globs.HistoCF1_[k], globs.NDiscHistoCF);
        setlength(globs.HistoCF1_s[k], globs.NDiscHistoCF);
      end;
      setlength(globs.HistoCF0, globs.CF.nEstrellasPorPuntoT);
      for k := 0 to high(globs.HistoCF0) do
        setlength(globs.HistoCF0[k], globs.NCronicasOpt * globs.NDiscHistoCF);
    end;
  end
  else
  begin
    globs.HistoCF1_ := SalaMadre.globs.HistoCF1_;
    globs.HistoCF1_s := SalaMadre.globs.HistoCF1_s;
    globs.HistoCF0 := SalaMadre.globs.HistoCF0;
  end;
end;


procedure TSalaDeJuego.Inicializar_HistogramasCF(CF: TAdminEstados);
var
  kEstrella, jPuntoHisto: integer;
  val_CF: NReal;
  kUltimoFrame: integer;
begin
  for kEstrella := 0 to CF.nEstrellasPorPuntoT - 1 do
  begin
    val_CF := CF.constelacion.fCosto[high(CF.constelacion.fCosto)][kEstrella];
    for jPuntoHisto := 0 to globs.NDiscHistoCF - 1 do
      globs.HistoCF1_[kEstrella][jPuntoHisto] := val_CF;
  end;
end;

procedure TSalaDeJuego.Liberar_HistogramasCF(SalaMadre: TSalaDeJuego);
var
  k: integer;
begin
  if SalaMadre = nil then
  begin
    if globs.HistoCF1_ <> nil then
    begin
      for k := 0 to high(globs.HistoCF1_) do
      begin
        setlength(globs.HistoCF1_[k], 0);
        setlength(globs.HistoCF1_s[k], 0);
      end;
      setlength(globs.HistoCF1_, 0);
      setlength(globs.HistoCF1_s, 0);
    end;
    if globs.HistoCF0 <> nil then
    begin
      for k := 0 to high(globs.HistoCF0) do
        setlength(globs.HistoCF0[k], 0);
      setlength(globs.HistoCF0, 0);
    end;
  end
  else
  begin
    globs.HistoCF1_ := nil;
    globs.HistoCF1_s := nil;
    globs.HistoCF0 := nil;
  end;
end;

{$IFDEF DEBUG_HistoCF0CF1}
procedure TSalaDeJuego.Dump_HistogramasCF0CF1(caso: string; kpaso, kEstrella: integer);
var
  f: textfile;
  k: integer;

begin
  assignfile(f, 'histos_CF_estrella' + IntToStr(kEstrella) + 'paso' +
    IntToStr(kpaso) + caso + '.xlt');
  rewrite(f);
  for k := 0 to high(globs.HistoCF1_[kEstrella]) do
    writeln(f, k, #9, globs.HistoCF0[kEstrella][k], #9,
      globs.HistoCF1_[kEstrella][k], #9, globs.HistoCF1_s[kEstrella][k]);
  for k := high(globs.HistoCF1_[kEstrella]) + 1 to high(globs.HistoCF0[kEstrella]) do
    writeln(f, k, #9, globs.HistoCF0[kEstrella][k]);
  closefile(f);
end;

{$ENDIF}


procedure TSalaDeJuego.Resumir_HistogramaCF0aCF1(kEstrellaIni, kEstrellaFin: integer);
var
  kEstrella: integer;
  jbase: integer;
  CF_Medida: NReal;
  CF_Medida_HistoCF1_s: NReal;
  CF_Medida_HistoCF0: NReal;
  Dif_CF_Medida: NReal;
  Dif_CF_ve: NReal;
  Dif_CF_Var: NReal;
  Dif_CF_VpE: NReal;

  CF_ve_HistoCF0: NReal;   // Valor Esperado HistoCF0
  CF_VaR_HistoCF0: NReal; // Valor a Riesgo
  CF_VpE_HistoCF0: NReal; // Valor con Probabilidad de Excedencia
  CF_ve_HistoCF1_s: NReal;   // Valor Esperado HistoCF1_s
  CF_VaR_HistoCF1_s: NReal; // Valor a Riesgo
  CF_VpE_HistoCF1_s: NReal; // Valor con Probabilidad de Excedencia
  CF_ve_HistoCF1_s_corregido: NReal;

  jPE: integer;
  jPuntoHisto: integer;
  jPH: integer;
  aval: NReal;
  cont1: integer;
  cont2: integer;
  cont3: integer;
  cont4: integer;
  cont5: integer;
  cont6: integer;
  alfa: double;

  //NHistogrande: integer;

{$IFDEF DEBUG_RESUMIR_HISTOGRAMA}
  flog: textfile;
{$ENDIF}

begin

  //NHistogrande:= length(globs.HistoCF0[0]);
  // aquí resumimos
  for kEstrella := kEstrellaIni to kEstrellaFin do
  begin

    {$IFDEF DEBUG_RESUMIR_HISTOGRAMA}
    if kEstrella = kEstrellaIni then
    begin
      assignfile(flog, 'carlog' + IntToStr(globs.kPaso_) + '.xlt');
      rewrite(flog);
      writeln(flog, 'globs.HistoCF0[kEstrella] antes de sort');
      printvect(flog, globs.HistoCF0[kEstrella], 4000);
    end;
    {$ENDIF}

    // ordenamos el histograma largo.
    QuickSort_Decreciente(globs.HistoCF0[kEstrella]);



    {$IFNDEF RESUMIR_HISTOGRAMA_VERSION_PABLO}


    // resumimos el histograma corto.
    jbase := globs.NCronicasOpt div 2;
    CF_ve := 0;
    CF_VaR := 0;

    jPE := trunc(globs.NDiscHistoCF * globs.probLimiteRiesgo);
    if jPE > 0 then
    begin
      for jPuntoHisto := 0 to jPE - 1 do
      begin
        aval := globs.HistoCF0[kEstrella][jbase];
        CF_VaR := CF_VaR + aval;
        globs.HistoCF1_s[kEstrella][jPuntoHisto] := aval;
        jbase := jbase + globs.NCronicasOpt;
      end;
      CF_ve := CF_VaR;
      CF_VaR := CF_VaR / jPE;
      CF_VpE := aval;
    end;

    for jPuntoHisto := jPE to globs.NDiscHistoCF - 1 do
    begin
      aval := globs.HistoCF0[kEstrella][jbase];
      CF_ve := CF_ve + aval;
      globs.HistoCF1_s[kEstrella][jPuntoHisto] := aval;
      jbase := jbase + globs.NCronicasOpt;
    end;

    CF_ve := CF_ve / globs.NDiscHistoCF;


     {$ELSE}
    // CALCULO NUEVO DE RESUMIR HISTOGRAMA //

    CF_ve_HistoCF0 := 0;
    CF_VaR_HistoCF0 := 0;
    CF_VpE_HistoCF0 := 0;
    CF_ve_HistoCF1_s := 0;
    CF_VaR_HistoCF1_s := 0;
    CF_VpE_HistoCF1_s := 0;
    CF_ve_HistoCF1_s_corregido := 0;
    Dif_CF_Medida := 0;
    Dif_CF_ve := 0;
    Dif_CF_Var := 0;
    Dif_CF_VpE := 0;
    cont1 := 0;
    cont2 := 0;
    cont3 := 0;
    cont4 := 0;
    cont5 := 0;
    cont6 := 0;


    // Corrector_ve := 0;


    //Cálculo de la medida de riesgo del CF en HistoCF0
    jPE := trunc(length(globs.HistoCF0[kEstrella]) * globs.probLimiteRiesgo);
    if jPE > 0 then
    begin

      for cont1 := 0 to jPE - 1 do
      begin
        aval := globs.HistoCF0[kEstrella][cont1];
        CF_VaR_HistoCF0 := CF_VaR_HistoCF0 + aval;

      end;

      CF_VaR_HistoCF0 := CF_VaR_HistoCF0 / jPE;
      CF_VpE_HistoCF0 := aval;
    end;

    //Cálculo del valor esperado del CF en HistoCF0
    for cont2 := 0 to length(globs.HistoCF0[kEstrella]) - 1 do
    begin
      aval := globs.HistoCF0[kEstrella][cont2];
      CF_ve_HistoCF0 := CF_ve_HistoCF0 + aval;
    end;

    CF_ve_HistoCF0 := CF_ve_HistoCF0 / length(globs.HistoCF0[kEstrella]);


    //calculamos medidas Histograma largo HistoCF0

    if globs.CAR_CVaR then
      CF_Medida_HistoCF0 := CF_ve_HistoCF0 * (1 - globs.CAR) +
        CF_VaR_HistoCF0 * globs.CAR
    else
      CF_Medida_HistoCF0 := CF_ve_HistoCF0 * (1 - globs.CAR) +
        CF_VpE_HistoCF0 * globs.CAR;

     {$IFDEF DEBUG_RESUMIR_HISTOGRAMA}
    if kEstrella = kEstrellaIni then
    begin
      //assignfile(flog, 'carlog' + IntToStr(globs.kPaso_) + '.xlt');
      //rewrite(flog);
      writeln(flog, 'globs.HistoCF0[kEstrella] despues de sort');
      printvect(flog, globs.HistoCF0[kEstrella], 4000);
      writeln(flog, 'CF_ve_HistoCF0: ', #9, CF_ve_HistoCF0);
      writeln(flog, 'CF_Medida_HistoCF0: ', #9, CF_Medida_HistoCF0);
      writeln(flog, 'CF_VaR_HistoCF0: ', #9, CF_VaR_HistoCF0);
      writeln(flog, 'CF_VpE_HistoCF0: ', #9, CF_VpE_HistoCF0);
      // closefile(flog);
    end;
    {$ENDIF}

    //Sampleo del Histograma largo (HistoCF0) en el corto (HistoCF1_s)
    //y Cálculo del valor esperado del CF en HistoCF1_s

    // alfa:=  power((globs.NDiscHistoCF*(globs.NCronicasOpt-1)),(1/(globs.NDiscHistoCF-1)));

    for cont3 := 0 to globs.NDiscHistoCF - 1 do
    begin
      jbase := trunc(cont3 * ((globs.NCronicasOpt * globs.NDiscHistoCF - 1) /
        (globs.NDiscHistoCF - 1)) + 0.49);
      //if cont3 = 0 then jbase:=0 else
      //jbase:= round(cont3 + power(alfa,cont3));
      globs.HistoCF1_s[kEstrella][cont3] := globs.HistoCF0[kEstrella][jbase];
      CF_ve_HistoCF1_s := CF_ve_HistoCF1_s + globs.HistoCF1_s[kEstrella][cont3];
    end;

    CF_ve_HistoCF1_s := CF_ve_HistoCF1_s / length(globs.HistoCF1_s[kEstrella]);

    //Cálculo de la medida de riesgo del CF en HistoCF1_s
    jPE := trunc(length(globs.HistoCF1_s[kEstrella]) * globs.probLimiteRiesgo);
    if jPE > 0 then
    begin

      for cont4 := 0 to jPE - 1 do
      begin
        aval := globs.HistoCF1_s[kEstrella][cont4];
        CF_VaR_HistoCF1_s := CF_VaR_HistoCF1_s + aval;

      end;

      CF_VaR_HistoCF1_s := CF_VaR_HistoCF1_s / jPE;
      CF_VpE_HistoCF1_s := aval;
    end;

    //calculamos medidas Histograma corto HistoCF1_s

    if globs.CAR_CVaR then
      CF_Medida_HistoCF1_s := CF_ve_HistoCF1_s * (1 - globs.CAR) +
        CF_VaR_HistoCF1_s * globs.CAR
    else
      CF_Medida_HistoCF1_s := CF_ve_HistoCF1_s * (1 - globs.CAR) +
        CF_VpE_HistoCF1_s * globs.CAR;


    //calculamos diferencia de CF_Medida_Histo

    Dif_CF_Medida := CF_Medida_HistoCF1_s - CF_Medida_HistoCF0;
    Dif_CF_ve := CF_ve_HistoCF1_s - CF_ve_HistoCF0;
    Dif_CF_Var := CF_Var_HistoCF1_s - CF_Var_HistoCF0;
    Dif_CF_VpE := CF_VpE_HistoCF1_s - CF_VpE_HistoCF0;


    //corregimos valor esperado en el Histograma corto
    for cont5 := 0 to length(globs.HistoCF1_s[kEstrella]) - 1 do
      globs.HistoCF1_s[kEstrella][cont5] :=
        globs.HistoCF1_s[kEstrella][cont5] - Dif_CF_ve;

    //Cálculo del valor esperado del CF en HistoCF1_s corregido
    for cont6 := 0 to length(globs.HistoCF1_s[kEstrella]) - 1 do
    begin
      aval := globs.HistoCF1_s[kEstrella][cont6];
      CF_ve_HistoCF1_s_corregido := CF_ve_HistoCF1_s_corregido + aval;
    end;

    CF_ve_HistoCF1_s_corregido :=
      CF_ve_HistoCF1_s_corregido / length(globs.HistoCF1_s[kEstrella]);




    {$ENDIF}

    // calculamos medidas a almacenar.

    if globs.CAR_CVaR then
      CF_Medida := CF_ve_HistoCF0 * (1 - globs.CAR) + CF_VaR_HistoCF0 * globs.CAR
    else
      CF_Medida := CF_ve_HistoCF0 * (1 - globs.CAR) + CF_VpE_HistoCF0 * globs.CAR;

    globs.CF.constelacion.set_costo_estrella(globs.kPaso_Opt,
      kEstrella, CF_Medida);



    {$IFDEF DEBUG_RESUMIR_HISTOGRAMA}
    if kEstrella = kEstrellaIni then
    begin
      writeln(flog, 'globs.HistoCF1_s[kEstrella]');
      printvect(flog, globs.HistoCF1_s[kEstrella], 4000);
      writeln(flog, 'CF_ve_HistoCF1_s: ', #9, CF_ve_HistoCF1_s);
      writeln(flog, 'CF_Medida_HistoCF1_s: ', #9, CF_Medida_HistoCF1_s);
      writeln(flog, 'CF_VaR_HistoCF1_s: ', #9, CF_VaR_HistoCF1_s);
      writeln(flog, 'CF_VpE_HistoCF1_s: ', #9, CF_VpE_HistoCF1_s);
      writeln(flog, 'Dif_CF_ve: ', #9, Dif_CF_ve);
      writeln(flog, 'CF_ve_HistoCF1_s_corregido: ', #9, CF_ve_HistoCF1_s_corregido);
      closefile(flog);
    end;
    {$ENDIF}

  end;
end;


{$ENDIF}

function TSalaDeJuego.CostoDelPaso_masCF_llegada_: NReal;
var
  costoDirectoDelPaso_Actores, costoDirectoDelPaso_Fuentes: NReal;
  utilidadDirectaDelPaso_Actores: NReal;

  CF_llegada: NReal;
  k: integer;

{$IFDEF DEBUG_OPTIMIZACION}
  archi_debug: string;
  f_debug: textfile;
  a_debug: TActor;
{$ENDIF}

begin
 {$IFDEF RECALCULAR_COSTO_DIRECTO_ACTORES}
  costoDirectoDelPaso_Actores := 0;
  for k := 0 to high(Actores) do
    costoDirectoDelPaso_Actores :=
      costoDirectoDelPaso_Actores + Actores[k].costoDirectoDelPaso;
  {$ELSE}
  if flg_IncluirPagosPotenciaYEnergiaEn_CF then
    costoDirectoDelPaso_Actores := costoDirectoDelpaso
  else
    costoDirectoDelPaso_Actores := costoOperativoDelPaso;
  {$ENDIF}


  // no me imagino fuentes con costo pero por las dudas ponemos
  costoDirectoDelPaso_Fuentes := 0;
  for k := 0 to lst_fuentes_costoDirectoDelPaso.Count - 1 do
    costoDirectoDelPaso_Fuentes :=
      costoDirectoDelPaso_Fuentes + TFuenteAleatoria(
      lst_fuentes_costoDirectoDelPaso[k]).costoDirectoDelPaso;


  {$IFDEF RECALCULAR_COSTO_DIRECTO_ACTORES}
  utilidadDirectaDelPaso_Actores := 0.0;
  if globs.restarUtilidadesDelCostoFuturo then
  begin
    for k := 0 to high(Actores) do
      utilidadDirectaDelPaso_Actores :=
        utilidadDirectaDelPaso_Actores + Actores[k].utilidadDirectaDelPaso;
  end;
  {$ELSE}
  utilidadDirectaDelPaso_Actores := self.utilidadDirectaDelPaso;
  {$ENDIF}

  fuentes_ActualizarEstadoGlobal(False);
  actores_ActualizarEstadoGlobal(False);
  // posicionamos la estrella de acuerdo al estado de los actores
  CF_llegada := globs.CF.costoContinuo(globs.kPaso_Opt + 1);

  {$IFDEF DEBUG_MULTI_HILO}
  writeln(fdebug_mh, 'estrella:'#9, globs.CF.ordinalEstrellaActual
    , #9'CActs:'#9, costoDirectoDelPaso_Actores, #9'CFuns: '#9,
    costoDirectoDelPaso_Fuentes, #9'CFLL'#9, CF_llegada, #9'XLL',
    globs.CF.GetEstado_XLT);
  {$ENDIF}


  Result := costoDirectoDelPaso_Actores + costoDirectoDelPaso_Fuentes -
    utilidadDirectaDelPaso_Actores + globs.factPaso * CF_llegada;
end;




procedure TSalaDeJuego.inicializarOptimizacion_subproc01;
begin

  if not DirectoryExists(dirResultadosCorrida) then
    MkDir(dirResultadosCorrida);
  if globs.NCronicasOpt > 0 then
    globs.invNCronicasOpt := 1 / globs.NCronicasOpt
  else
    globs.invNCronicasOpt := 0;

  globs.EstadoDeLaSala := CES_OPTIMIZANDO;
end;


function TSalaDeJuego.Preparar_CrearCF_y_regsitrar_variables_de_estado(
  flg_esclavizarfuentes: boolean = True): integer;
var
  k: integer;
  dimX: integer;
begin
  PrepararMemoriaYListados(flg_esclavizarfuentes);

  PrepararActualizadorFichasLPD(False);

  optx_nvxs;
  dimX := ivar_xr + ivar_xd;
  if globs.CF <> nil then
    globs.CF.Free;
  if dimX > 0 then
  begin
    globs.CF := TAdminEstados.Create(ivar_xr, ivar_xd, globs.NPasos);
    //    globs.ActualizadorLPD.ActualizarFichasHasta( globs.fechaFin  );
    for k := 0 to high(actores) do
      actores[k].optx_RegistrarVariablesDeEstado(globs.CF);
    for k := 0 to high(fuentes) do
      fuentes[k].optx_RegistrarVariablesDeEstado(globs.CF);
  end;
  Result := dimX;
end;

function TSalaDeJuego.inicializarOptimizacion_subproc02(const salaMadre: TSalaDeJuego;
  const costoFuturo: TMatOfNReal): integer;
var
  k: integer;
  dimX: integer;
  CF_Tmp: TAdminEstados;
  ficha_CERO: TFichaActualizar;
begin

  if salaMadre <> nil then
  begin
    globs.ObligarDisponibilidad_1_Sim := salaMadre.globs.ObligarDisponibilidad_1_Sim;
    globs.ObligarInicioCronicaIncierto_1_Sim :=
      salaMadre.globs.ObligarInicioCronicaIncierto_1_Sim;
    globs.ObligarDisponibilidad_1_Opt := salaMadre.globs.ObligarDisponibilidad_1_Opt;
  end;
  globs.ObligarDisponibilidad_1_ := globs.ObligarDisponibilidad_1_Opt;


  dimX := Preparar_CrearCF_y_regsitrar_variables_de_estado;
  Result := dimX;
  if dimX = 0 then
  begin
    globs.EstadoDeLaSala := CES_OPTIMIZACION_TERMINADA;
    exit; // si no hay variables de estado no optimizo nada y me voy
  end;

  InicioOpt;

  Armar_lst_BarridoFijarEstadoDeActoresYFuentesToEstrella;
  Armar_lst_costoDirectoDelPaso;
  spx := TMIPSimplex.Create_init(1, 1, 1, self.getNombreVar, self.getNombreRes);
  // solo para que esté definido.

  globs.CF.CrearElEspacioTiempo(globs.fechaIniOpt, globs.fechaFinOpt,
    globs.HorasDelPaso, costoFuturo, globs.Deterministico);

  if SalaMadre = nil then
  begin
    // Ahora creamos frames para las variables auxiliares
    setlength(globs.Auxs_r0, ivar_auxNReal);
    setlength(globs.Auxs_r1, ivar_auxNReal);
    for k := 0 to ivar_auxNReal - 1 do
    begin
      setlength(globs.Auxs_r0[k], globs.CF.constelacion.nEstrellas);
      setlength(globs.Auxs_r1[k], globs.CF.constelacion.nEstrellas);
      vclear(globs.Auxs_r0[k]);
      vclear(globs.Auxs_r1[k]);
    end;
    setlength(globs.Auxs_i0, ivar_auxInt);
    setlength(globs.Auxs_i1, ivar_auxInt);
    for k := 0 to ivar_auxInt - 1 do
    begin
      setlength(globs.Auxs_i0[k], globs.CF.constelacion.nEstrellas);
      setlength(globs.Auxs_i1[k], globs.CF.constelacion.nEstrellas);
      vclear(globs.Auxs_i0[k]);
      vclear(globs.Auxs_i1[k]);
    end;
    Globs.liberarAuxs := True;
  end
  else
  begin
    globs.Auxs_r0 := SalaMadre.globs.Auxs_r0;
    globs.Auxs_r1 := SalaMadre.globs.Auxs_r1;
    globs.Auxs_i0 := SalaMadre.globs.Auxs_i0;
    globs.Auxs_i1 := SalaMadre.globs.Auxs_i1;
    Globs.liberarAuxs := False;
  end;

  // fijamos la fecha del paso igual a la de inicio del último paso
  globs.Fijar_kPaso(globs.nPasos);
  //prepararSalaParaPaso;

  {$IFDEF _MODTRAR_FICHA_CERO_}
  writeln('*****************************************');
  writeln('ATENCION!!!');
  ficha_CERO := TFichaActualizar(globs.ActualizadorLPD.items[0]);
  writeln('FICHA_CERO: ', Ficha_Cero.lst_fichas.Propietario.nombre,
    ': fecha: ', ficha_Cero.fecha.AsStr,
    ' tipo: ', ficha_CERO.lst_fichas[ficha_CERO.ificha].ClassName);
  writelN('PRESIONE ENTER PARA SALIR');
  readln;
  halt(0);
  {$ENDIF}

  globs.ActualizadorLPD.ActualizarFichasHasta(globs.FechaInicioDelpaso);

  //globs.ActualizadorLPD.DumpListaToArchi('fichaslpd.txt');
  Armar_lst_EvolucionarEstado;

  Armar_lst_necesitoIterar;



  if SalaMadre = nil then
  begin
{$IFDEF PERTURBADO}
    // Frame CERO EN CERO y un pendorcho
    globs.CF.constelacion.ClearUltimoFrame;
    globs.CF.posicionarseEnEstrella(2);
    globs.CF.SetCostoEstrella(globs.CF.high(costoFuturo), 1.0E7);
{$ELSE}
    case usarArchivoParaInicializarFrameInicial of

      0: globs.CF.constelacion.ClearUltimoFrame;

      1:
      begin
        CF_tmp := globs.CF.CrearCF_AUX_para_enganaches_CFbin(
          archivoCF_ParaEnganches.archi, dirSala);
        globs.CF.InicializarFrameFinal(
          CF_Tmp,
          // globs.fechaFinOpt,
          enganchesContinuos, enganchesDiscretos, enganchar_promediando_desaparecidas,
          uniformizar_promediando, flg_usar_enganche_mapeo, enganche_mapeo, self);
        CF_Tmp.Free;
      end;

      2:
      begin
        CF_tmp := globs.CF.CrearCF_AUX_para_enganaches_MPUTE(
          dirSala + 'mus.txt', dirSala + 'pis.txt', self.globs.fechaIniOpt,
          self.globs.fechaFinOpt, self.globs.HorasDelPaso);
        globs.CF.InicializarFrameFinal(CF_tmp,
          // globs.fechaFinOpt,
          enganchesContinuos, enganchesDiscretos, enganchar_promediando_desaparecidas,
          uniformizar_promediando, flg_usar_enganche_mapeo, enganche_mapeo, self);
        CF_tmp.Free;
      end;

    end;

{$ENDIF}

  end;

{$IFDEF PDE_RIESGO}
  if globs.usar_CAR and globs.SortearOpt then
  begin
    Crear_HistogramasCF(SalaMadre);

    if (SalaMadre = nil) and (usarArchivoParaInicializarFrameInicial > 0) then
      Inicializar_HistogramasCF(globs.CF);
  end;
{$ENDIF}


{$IFDEF ESTABILIZAR_FRAMEINICIAL}
  if (SalaMadre = nil) and (globs.CF <> nil) and EstabilizarInicio then
    EstabilizarFrameInicial;
{$ENDIF}

end;

function TSalaDeJuego.inicializarOptimizacion(const SalaMadre: TSalaDeJuego;
  const costoFuturo: TMatOfNReal): integer;
begin
  InicializarOptimizacion_subproc01;
  Result := InicializarOptimizacion_subproc02(SalaMadre, costoFuturo);
end;

{$IFDEF DUMP_TEXT_OPTRES}
procedure TSalaDeJuego.OptRes_Actores_WriteEstrella;
var
  kSalOpt: integer;
begin
  for kSalOpt := 0 to high(fsal_opt) do
  begin
    //                TActor(Self.lst_opt_PrintResultados.items[k]).PosicionarseEnEstrellita;
    //                TActor(Self.lst_opt_PrintResultados.items[k]).prepararPaso_ps;
    TActor(self.lst_opt_PrintResultados.Items[kSalOpt]).opt_PrintResultados(
      fsal_opt[kSalOpt]);
  end;
end;


procedure TSalaDeJuego.OptRes_Actores_WriteFecha;
var
  k: integer;
begin
  for k := 0 to high(fsal_opt) do
    Write(fsal_opt[k], IntToStr(globs.kPaso_Opt) + #9 +
      globs.FechaInicioDelpaso.AsISOStr);
end;

procedure TSalaDeJuego.OptRes_Actores_WritelnFrame;
var
  k: integer;
begin
  for k := 0 to high(fsal_opt) do
    writeln(fsal_opt[k]);
end;

procedure TSalaDeJuego.OptRes_CF_WritelnFrame;
var
  NoFinBarridoEstrellas: boolean;
begin
  Write(fsal, IntToStr(globs.kPaso_Opt) + #9 + globs.FechaInicioDelpaso.AsISOStr);
  globs.CF.setEstrellaCERO;
  NoFinBarridoEstrellas := True;
  while NoFinBarridoEstrellas do
  begin
    Write(fsal, #9, FloatToStrF(globs.CF.costoEstrella(globs.kPaso_Opt),
      ffGeneral, 6, 2));
    NoFinBarridoEstrellas := globs.CF.incEstrella;
  end;
  writeln(fsal);
end;

{$ENDIF}

{$IFDEF opt_Dump_PubliVars}
procedure TSalaDeJuego.printPubliVarsDBG_OPT_MH;
var
  i: integer;
begin

  Write(self.f_dbgMH, 'Paso=', self.globs.kPaso_, #9, 'estrellita=',
    self.globs.CF.ordinalEstrellaActual);

  globs.printPubliVars(f_dbgMH);
  for i := 0 to listaActores.Count - 1 do
    listaActores.items[i].printPubliVars(f_dbgMH);

  WriteLn(self.f_dbgMH);

end;

{$ENDIF}

procedure TSalaDeJuego.OptimizacionCronizada_UnPaso_RangoDeEstrellas(
  estrellaIni, estrellaFin: integer; notificar: boolean; printActores_OptRes: boolean);

var
  kCron: integer;
  kEstrella: integer;
  CostoFuturo_cronica: NReal;
  flog: textfile;

  {$IFDEF CHEQUEOMEM}
  tam: cardinal;
  {$ENDIF}

begin
  {$IFDEF PDE_RIESGO}
  if not (globs.usar_CAR) then
  {$ENDIF}
  begin
    // borro el frame pues lo voy a usar para acumular
    globs.CF.constelacion.ClearFrame_k_rango(globs.kPaso_Opt, estrellaIni, estrellaFin);
  end;

  globs.ClearAuxs1(estrellaIni, estrellaFin);

  (* optimización CRONIZADA
  Para cada crónica realizamos sorteos y realizamos un barrido de los
  estados con el sorteo fijo. Así vamos acumulando los costos del paso
  con cada sorteo para cada uno de los estados. Después de haber realizado
  todos los sorteos-barridos_de_estado que queremos, realizamos un nuevo
  barrido_de_estado para promediar los valores acumulados.
  El orden en que se realiza esto es importante, pues es importante calcular con
  cada sorteo el costo para los diferentes estados. Los sorteos determinan
  las máquinas que estan disponibles, los aportes a los embalses y los
  recursos disponibles en general. Es importante que para un mismo conjunto
  de recursos disponibles se realice el barrido de los estados y luego con
  otro conjunto para salvaguardar la monotonía esperable de los costos de
  una etapa respecto de las variables de estado.
  *)

  // esto acá no tendría que ser necesario a partir de que independizamos
  // las madres uniformes de sorteos.
  globs.fijarSemillaAleatoria_(globs.semilla_inicial_opt + globs.kPaso_Opt);
  {$IFDEF DEBUG_MULTI_HILO}
  writeln(fdebug_mh, #9'RandSeed:'#9, globs.semilla_inicial_opt + globs.kPaso_Opt);
  {$ENDIF}

  for kCron := 1 to globs.NCronicasOpt do
  begin
    globs.kCronica := kCron;
    if notificar then
      globs.procNot(globs.procNot_opt_InicioCronicaSorteos);


    {$IFDEF CHEQUEOMEM}
    tam := udbgutil.tam;
    {$ENDIF}
    SorteosDelPasoOpt(True);
    {$IFDEF CHEQUEOMEM}
    if tam <> udbgutil.tam then
      raise Exception.Create('Se pierde memoria en sorteos del paso');
    {$ENDIF}

    // Aqui hacemos el barrido de los estados
    // nos posicionamos en la primer estrella
    globs.CF.posicionarseEnEstrella(estrellaIni);
    for kEstrella := estrellaIni to estrellaFin do
    begin

      {$IFDEF CHEQUEOMEM}
      tam := udbgutil.tam;
      {$ENDIF}
      globs.CF.SetEstadoToEstrella; // Fijamos la estrella
      {$IFDEF CHEQUEOMEM}
      if tam <> udbgutil.tam then
        raise Exception.Create('Se pierde memoria en globs.CF.SetEstadoToEstrella');
      {$ENDIF}

      {$IFDEF CHEQUEOMEM}
      tam := udbgutil.tam;
      {$ENDIF}
      PosicionarseEnEstrellita;     // Fijamos el estado en los actores
      {$IFDEF CHEQUEOMEM}
      if tam <> udbgutil.tam then
        raise Exception.Create('Se pierde memoria en PosicionarseEnEstrellita');
      {$ENDIF}

      {$IFDEF CHEQUEOMEM}
      tam := udbgutil.tam;
      {$ENDIF}
      Fuentes_PrepararPaso_ps( true ) ;
      {$IFDEF CHEQUEOMEM}
      if tam <> udbgutil.tam then
        raise Exception.Create('Se pierde memoria en prepararpaso_ps');
      {$ENDIF}

      //rch@201408261402 atención!!!
      // agrego este Actualizar con Xs para que las derivadas de CF se calculen
      // en base al Xs proyectado
      fuentes_ActualizarEstadoGlobal(True);
      actores_ActualizarEstadoGlobal(True);

      Actores_PrepararPaso_ps_pre;


      globs.cntIteracionesDelPaso := 0;
      repeat
        Inc(globs.cntIteracionesDelPaso);
        // writeln( 'kPaso: ', globs.kPaso_, ', kCron: ', kCron, ', kEstrella: ', kEstrella, ', cntIteracionesDelPaso: ', globs.cntIteracionesDelPaso );

(*
        if (globs.kPaso_ = 123) and ( kCron = 19 ) and ( kEstrella = 40 ) and ( globs.cntIteracionesDelPaso = 1 ) then
  writeln( 'hola--->' );
  *)
        Actores_PrepararPaso_ps;
        if notificar then
          if globs.cntIteracionesDelPaso = 1 then
            globs.procNot(globs.procNot_opt_PrepararPaso_ps);


{$IFDEF DUMP_TEXT_OPTRES}
        if PrintActores_OptRes then
          if kCron = 1 then
            if globs.cntIteracionesDelPaso = 1 then
              OptRes_Actores_WriteEstrella;
{$ENDIF}
        ResolverPaso;

        {$IFDEF opt_Dump_PubliVars}
        if kCron = 1 then

          if globs.cntIteracionesDelPaso = 1 then

            printPubliVarsDBG_OPT_MH;
        {$ENDIF}


      until (globs.cntIteracionesDelPaso >= globs.NMAX_ITERACIONESDELPASO_OPT) or
        (not NecesitoIterar);


      EvolucionarEstado;

{$IFDEF PDE_RIESGO}
      if globs.usar_CAR then
        LlenarHistograma_CostoDelPaso_masCF_llegada(
          globs.HistoCF0[globs.CF.ordinalEstrellaActual], (kCron - 1) *
          globs.NDiscHistoCF)
      else
{$ENDIF}
      begin
        CostoFuturo_cronica := CostoDelPaso_masCF_llegada_;

        globs.CF.AcumCostoEstrella(globs.kPaso_Opt, CostoFuturo_Cronica *
          globs.invNCronicasOpt);

     {//debug CF
     if kEstrella = estrellaIni then
    begin
     assignfile(flog, 'carlog_CF' + IntToStr(globs.kPaso_)+'  ' + IntToStr(kCron) +  '.xlt');
     rewrite(flog);

     writeln(flog, 'CostoFuturo_cronica: ', #9, CostoFuturo_cronica*
          globs.invNCronicasOpt);

     closefile(flog);
     end;
      //  }

      end;

      Actores_AcumularAuxs1;

{$IFDEF SPXMEJORCAMINO}
      vswap(spx.mejorCaminoEsperado, spx.mejorCaminoEncontrado);
{$ENDIF}
      globs.CF.incEstrella; // pasamos a la siguiente estrella
    end; // for de las estrellas
  end; // for de las crónicas

{$IFDEF PDE_RIESGO}
  if globs.usar_CAR then
  begin
    Resumir_HistogramaCF0aCF1(estrellaIni, estrellaFin);
    {$IFDEF DEBUG_HistoCF0CF1}
    Dump_HistogramasCF0CF1('pos', globs.kPaso_, 0);
    {$ENDIF}
  end;
{$ENDIF}
end;


procedure TSalaDeJuego.OptimizacionValorEsperado_UnPaso_RangoDeEstrellas(
  estrellaIni, estrellaFin: integer; notificar: boolean; printActores_OptRes: boolean);

var
  kEstrella: integer;
  CostoFuturo_Esperado: NReal;
begin

  globs.kCronica := 0; // ponemos a cero para que sea en valor esperado
  SorteosDelPasoOpt(False);
  // Aqui hacemos el barrido de los estados
  // nos posicionamos en la primer estrella

  globs.CF.posicionarseEnEstrella(estrellaIni);
  for kEstrella := estrellaIni to estrellaFin do
  begin
    // fijamos el estado
    globs.CF.SetEstadoToEstrella;
    PosicionarseEnEstrellita;// Fijamos el estado en los actores

    //rch@201408261402 atención!!!
    // agrego este Actualizar con Xs para que las derivadas de CF se calculen
    // en base al Xs proyectado
    fuentes_ActualizarEstadoGlobal(True);
    actores_ActualizarEstadoGlobal(True);

    Fuentes_PrepararPaso_ps( true );
    Actores_PrepararPaso_ps_pre;

    globs.cntIteracionesDelPaso := 0;
    repeat
      Inc(globs.cntIteracionesDelPaso);

      Actores_PrepararPaso_ps;

      if notificar then

        if globs.cntIteracionesDelPaso = 1 then

          globs.procNot(globs.procNot_opt_PrepararPaso_ps);

      ResolverPaso;

    until (globs.cntIteracionesDelPaso >= globs.NMAX_ITERACIONESDELPASO_OPT) or
      (not NecesitoIterar);


    EvolucionarEstado;
    CostoFuturo_Esperado := CostoDelPaso_masCF_llegada_;
    globs.CF.SetCostoEstrella(globs.kPaso_Opt, CostoFuturo_Esperado);
    Actores_SetAuxs1;

      {$IFDEF DUMP_TEXT_OPTRES}
    if PrintActores_OptRes then
      OptRes_Actores_WriteEstrella;
      {$ENDIF}

  {$IFDEF SPXMEJORCAMINO}
    vswap(spx.mejorCaminoEsperado, spx.mejorCaminoEncontrado);
  {$ENDIF}
    globs.CF.incEstrella;
  end;// barrido estrellas
end;

procedure TSalaDeJuego.calcularRangoEstrellas(estrellaIni, estrellaFin: integer;
  notificar, printActoresOptRes: boolean);
       {$IFDEF CHEQUEOMEM}
var
  tam: cardinal;
      {$ENDIF}

begin

      {$IFDEF CHEQUEOMEM}
  tam := udbgutil.tam;
      {$ENDIF}


  globs.ActualizadorLPD.ActualizarFichasHasta(globs.FechaInicioDelpaso);
  PrepararPaso_as;

  if notificar then
    globs.procNot(globs.procNot_opt_InicioCalculosDeEtapa);
  if globs.SortearOpt then // Cálculo de los costos de la etapa con sorteos
  begin
    OptimizacionCronizada_UnPaso_RangoDeEstrellas(
      estrellaIni, estrellaFin, notificar, printActoresOptRes);
  end // fin de la optimización Cronizada
  else
  begin // optimización con valores esperados
    OptimizacionValorEsperado_UnPaso_RangoDeEstrellas(
      estrellaIni, estrellaFin, notificar, printActoresOptRes);
  end;

  if notificar then
    globs.procNot(globs.procNot_opt_FinCalculosDeEtapa);

  {$IFDEF CHEQUEOMEM}
  if tam <> udbgutil.tam then
    raise Exception.Create('Se pierde memoria en calcularRangoEstrellas');
  {$ENDIF}

end;




function TSalaDeJuego.genStrPasoCronEstrIter: string;//Optimizacion
begin
  if globs.CF <> nil then
  begin

    Result := 'kpaso' + IntToStr(globs.kPaso_Opt) + '_kCronica' +
      IntToStr(globs.kCronica) + '_kEstr' + IntToStr(globs.CF.ordinalEstrellaActual) +
      'kIter' + IntToStr(globs.cntIteracionesDelPaso);

  end
  else
  begin

    Result := 'kpaso' + IntToStr(globs.kPaso_Opt) + '_kCronica' +
      IntToStr(globs.kCronica) + 'kIter' + IntToStr(globs.cntIteracionesDelPaso);

  end;
end;

function TSalaDeJuego.genStrCronPasoIter: string;//Simulacion
begin
  Result := 'kCronica' + IntToStr(globs.kCronica) + '_kpaso' +
    IntToStr(globs.kPaso_Sim) + 'kIter' + IntToStr(globs.cntIteracionesDelPaso);
end;


function TSalaDeJuego.getRangoEstrellasCF(estrellaIni, estrellaFin, paso: integer):
TDAOfNReal;

var
  res: TDAofNReal;
begin
  SetLength(res, estrellaFin - estrellaIni + 1);
  vcopyTramoDesplazando(res, 0, globs.CF.constelacion.fCosto[paso],
    estrellaIni, estrellaFin - estrellaIni + 1);
  Result := res;
end;

function TSalaDeJuego.getRangoEstrellasAux_r1(estrellaIni, estrellaFin: integer):
TDAOfDAofNReal;
var
  n, m: integer;
  res: TDAOfDAofNReal;
  i: integer;
begin

  n := Length(globs.Auxs_r1);
  m := estrellaFin - estrellaIni + 1;
  if ((n <> 0) and (m <> 0)) then
  begin
    SetLength(res, n);
    for i := 0 to n - 1 do
    begin
      SetLength(res[i], m);
      vcopyTramoDesplazando(res[i], 0, globs.Auxs_r1[i], estrellaIni, m);
    end;
  end;
  Result := res;
end;

function TSalaDeJuego.getRangoEstrellasAux_i1(estrellaIni, estrellaFin: integer):
TDAOfDAOfNInt;

var
  n, m: integer;
  res: TDAOfDAOfNInt;
  i: integer;
begin

  n := Length(globs.Auxs_i1);
  m := estrellaFin - estrellaIni + 1;
  if ((n <> 0) and (m <> 0)) then
  begin
    SetLength(res, n);
    for i := 0 to n - 1 do
    begin
      SetLength(res[i], m);
      vcopyTramoDesplazando(res[i], 0, globs.Auxs_i1[i], estrellaIni, m);
    end;
  end;
  Result := res;
end;

procedure TSalaDeJuego.setRangoEstrellasCF(estrellaIni: integer;
  tramoCostosFuturo: TDAOfNReal; kpaso: integer);
begin
  vcopyTramoDesplazando(globs.CF.constelacion.fCosto[kpaso],
    estrellaIni, tramoCostosFuturo, 0, Length(tramoCostosFuturo));
end;

procedure TSalaDeJuego.setRangoEstrellasAux_r1(estrellaIni: integer;
  tramoAux_r1: TDAOfDAofNReal);
var
  n: integer;
  i: integer;
begin
  n := Length(tramoAux_r1);
  if n <> 0 then
    for i := 0 to n - 1 do
      vcopyTramoDesplazando(globs.Auxs_r1[i],
        estrellaIni, tramoAux_r1[i], 0, Length(tramoAux_r1[i]));
end;

procedure TSalaDeJuego.setRangoEstrellasAux_i1(estrellaIni: integer;
  tramoAux_i1: TDAOfDAOfNInt);
var
  n: integer;
  i: integer;
begin
  n := Length(tramoAux_i1);
  if n <> 0 then
    for i := 0 to n - 1 do
      vcopyTramoDesplazando(globs.Auxs_i1[i],
        estrellaIni, tramoAux_i1[i], 0, Length(tramoAux_i1[i]));
end;

function TSalaDeJuego.irAPaso_(nuevoPaso: integer): integer;
begin
  if globs.EstadoDeLaSala = CES_OPTIMIZANDO then
  begin
    if globs.kPaso_Opt > nuevoPaso then
    begin
      globs.Fijar_kPaso(nuevoPaso);
      globs.procNot(globs.procNot_opt_FinCalculosDeEtapa);
      Result := 1;
    end
    else if globs.kpaso_Opt = nuevoPaso then
      Result := 2
    else
      Result := 0;
  end
  else
    Result := 10; //cualquiera para que de resultado******
end;

function TSalaDeJuego.llenarRangoDeEstrellasYDarPaso(estrellasIni: TDAofNInt;
  costosFuturos: TDAOfDAOfNReal; kpaso: integer): integer;
var
  i: integer;
begin
  if globs.kPaso_Opt >= kpaso then
  begin
    for i := 0 to high(estrellasIni) do
      vcopyTramoDesplazando(globs.CF.constelacion.fCosto[kPaso],
        estrellasIni[i], costosFuturos[i], 0, Length(costosFuturos[i]));
  end;
  Result := irAPaso_(kpaso - 1);
end;

procedure TSalaDeJuego.darPaso_Opt;
begin
  self.globs.kPaso_Opt := self.globs.kPaso_Opt - 1;
end;

procedure TSalaDeJuego.Optimizar(llenarConFrameFinal: boolean);
var
  NoFinBarridoEstrellas: boolean;
  {$IFDEF opt_Dump_PubliVars}
  archi: string;

  {$ENDIF}

  procedure wrtilen(s: string);
  begin
    system.writeln(s);
  end;

begin
  inicializarOptimizacion_subproc01;
{$IFDEF DUMP_TEXT_OPTRES}
  fsalopen := False;
{$ENDIF}
{$IFDEF opt_Dump_PubliVars}
  self.f_dbgMH_Open := False;
{$ENDIF}
  try
    try
      (****** INICIALIZAR OPTIMIZACION ************)
      if inicializarOptimizacion_subproc02(nil, nil) = 0 then
        exit; // No hay variables de estado = no hay optimización

{$IFDEF DUMP_TEXT_OPTRES}
      inicializarArchisOptRes(fsal, fsal_opt, fsalopen);
{$ENDIF}
      if not DirectoryExists(dirResultadosCorrida) then
        MkDir(dirResultadosCorrida);

      // Publico las variables para que puedan funcionar los monitores
      // durante la optización.
      publicarTodasLasVariables;

     {$IFDEF opt_Dump_PubliVars}
      archi := self.dirResultadosCorrida + 'opt_Dump_PubliVars.txt';
      assignfile(self.f_dbgMH, archi);
      self.f_dbgMH_Open := True;
      rewrite(self.f_dbgMH);
     {$ENDIF}


      globs.procNot(globs.procNot_opt_InicioOptimizacion);

      if LlenarConFrameFinal then
        globs.CF.LlenarConFrameFinal
      else
         {$IFDEF CHEQUEOMEM}
        pdl('INicio While Optmización ' + IntToStr(globs.kPaso_), True, False);
         {$ENDIF}


      // Barrido de los pasos en reversa
      while (globs.kPaso_Opt > 0) and (not globs.abortarSim) do
      begin
          {$IFDEF CHEQUEOMEM}
        pdl('pasoOpt: ' + IntToStr(globs.kPaso_Opt), True, False);
          {$ENDIF}


          {$IFDEF DUMP_TEXT_OPTRES}
        OptRes_Actores_WriteFecha;
        {$ENDIF}

                                                          (*
writeln( globs.kPaso_ );
if globs.kPaso_ =  5 then
begin
  writeln( 'TSalaDeJuego.Optimizar TOY' );
  globs.ActualizadorLPD.DumpListaToArchi( 'c:\basura\fichaslpd.xlt' );
end;
*)
        globs.ActualizadorLPD.ActualizarFichasHasta(globs.FechaInicioDelpaso);
        PrepararPaso_as;
        globs.procNot(globs.procNot_opt_InicioCalculosDeEtapa);

        if globs.SortearOpt then // Cálculo de los costos de la etapa con sorteos
        begin
          OptimizacionCronizada_UnPaso_RangoDeEstrellas(
            0, globs.CF.nEstrellasPorPuntoT - 1, True, True);
        end // fin de la optimización Cronizada
        else
        begin // incio: optimización con valores esperados
          OptimizacionValorEsperado_UnPaso_RangoDeEstrellas(
            0, globs.CF.nEstrellasPorPuntoT - 1, True, True);
        end;

        {$IFDEF DUMP_TEXT_OPTRES}
        OptRes_CF_WritelnFrame;
        OptRes_Actores_WritelnFrame;
        {$ENDIF}
        globs.Fijar_kPaso(globs.kPaso_Opt - 1);
        globs.SwapAuxs;
        globs.procNot(globs.procNot_opt_FinCalculosDeEtapa);
      end; // while del paso

      FinOptimizacion;
    finally

    {$IFDEF opt_Dump_PubliVars}
      if self.f_dbgMH_Open then
        CloseFile(self.f_dbgMH);
    {$ENDIF}

{$IFDEF PDE_RIESGO}
      if globs.usar_CAR and globs.SortearOpt then
        Liberar_HistogramasCF(nil);
{$ENDIF}

{$IFDEF DUMP_TEXT_OPTRES}
      cerrarArchisOptRes(fsal, fsal_opt, fsalopen);
{$ENDIF}
    end;

    if not globs.abortarSim then
    begin
      globs.EstadoDeLaSala := CES_OPTIMIZACION_TERMINADA;
    end
    else
      globs.EstadoDeLaSala := CES_OPTIMIZACION_ABORTADA;
  except
    globs.EstadoDeLaSala := CES_OPTIMIZACION_ABORTADA;
    raise;
  end;
end;


{$IFDEF PSO_ENZO}
procedure TSalaDeJuego.OptimizarDeterministica;
const
  Num_particulas: integer = 10;
  Num_iteraciones: integer = 200;
  fact_perturbacion: NReal = 0.001;
  dimensiones: integer = 2;
  valmaxX: NReal = 10;
  valminX: NReal = -10;
  valmaxV: NReal = 10;
  valminV: NReal = -10;
  uw: double = 0.729;
  uc1: double = 1.49445;
  uc2: double = 1.49445;

var
  NoFinBarridoEstrellas: boolean;
  u, us: TDAOfNReal;
  c, cs: NReal;
  K: NReal;
  flg_optimizando: boolean;
  largo_u: integer;

  i, j: integer;
  uminX, umaxX, uminV, umaxV: TDAofNReal;
  mejor, ur1, ur2: NReal;
  indice_mejor: integer;
  mejor_pos: TDAofNReal;
  cumulo: array of particula;

begin
  inicializarOptimizacion_subproc01;
  if inicializarOptimizacion_subproc02(nil, nil) = 0 then
    exit; // No hay variables de estado = no hay optimización

  u := GLobs.CF.ControladorDeterministico.create_vect_u;
  largo_u := length(u);
  vclear(u);

  setlength(cumulo, Num_particulas + 1);
  setlength(uminX, largo_u);
  setlength(umaxX, largo_u);
  setlength(uminV, largo_u);
  setlength(umaxV, largo_u);
  setlength(mejor_pos, largo_u);

  // cargo limites inferiores y superiores
  for i := 0 to largo_u - 1 do
  begin
    uminX[i] := valminX;
    umaxX[i] := valmaxX;
    uminV[i] := valminV;
    umaxV[i] := valmaxV;
  end;

  // primera evaluacion de f(u)
  GLobs.CF.ControladorDeterministico.set_vect_u(u);
  c := Simular(0, False);
  mejor := c;
  writeln('mejor_c: ', mejor);

  K := 0.0;
  while flg_optimizando do
  begin
    // cargo el cumulo de particulas y cargo fitness
    for i := 1 to Num_particulas do
    begin
      cumulo[i] := particula.Create(uminX, umaxX, uminV, umaxV);
      vcopy(u, cumulo[i].posicion);
      GLobs.CF.ControladorDeterministico.set_vect_u(u);
      c := Simular(0, False);
      writeln('i: ', i, ', c: ', c);
      cumulo[i].fitness := c;
      cumulo[i].mejorfitness := c;
      if c < mejor then
      begin
        mejor := c;
        indice_mejor := i;
        vcopy(mejor_pos, cumulo[i].posicion);
        vcopy(cumulo[i].mejorposicion, cumulo[i].posicion);
        vcopy(u, cumulo[i].posicion);
        cumulo[i].mejorfitness := c;
      end;
    end;

    writeln('mejor_c: ', mejor);

    // evaluar
    // f(u)
    GLobs.CF.ControladorDeterministico.set_vect_u(u);
    c := Simular(0, False);
    for j := 0 to Num_iteraciones do
    begin
      for i := 1 to Num_particulas do
      begin
        randomize;
        ur1 := Call_UNI;
        ur2 := Call_UNI;
        if j < Num_iteraciones * 3 / 4 then
          cumulo[i].perturbar(fact_perturbacion, uminX, umaxX);
        cumulo[i].calcular_velocidad(uw, uc1, uc2, ur1, ur2, uminV, umaxV, mejor_pos);
        cumulo[i].calcular_posicion(uminX, umaxX);
        vcopy(u, cumulo[i].posicion);
        GLobs.CF.ControladorDeterministico.set_vect_u(u);
        c := Simular(0, False);

        writeln('j: ', j, ', i: ', i, ', c: ', c);
        cumulo[i].fitness := c;
        if c < cumulo[i].mejorfitness then
        begin
          cumulo[i].mejorfitness := c;
          vcopy(cumulo[i].mejorposicion, cumulo[i].posicion);
        end;

        if c < mejor then
        begin
          mejor := c;
          indice_mejor := i;
          vcopy(mejor_pos, cumulo[i].posicion);
          writeln('mejor_c: ', mejor);
        end;
      end;
    end;
    flg_optimizando := False;
    vcopy(u, mejor_pos);
  end;
  writeln('mejor_c: ', mejor);
  for i := 0 to largo_u - 1 do
    writeln('u_', IntToStr(i), ': ', floattostr(u[i]));

  for i := 1 to Num_particulas do
  begin
    cumulo[i].Free;
  end;

  setlength(cumulo, 0);
  setlength(uminX, 0);
  setlength(umaxX, 0);
  setlength(uminV, 0);
  setlength(umaxV, 0);
  setlength(mejor_pos, 0);
end;

{$ELSE}
procedure TSalaDeJuego.OptimizarDeterministica;
var
  NoFinBarridoEstrellas: boolean;
  u, us, Agite: TDAOfNReal;
  c, cs: NReal;
  flg_optimizando: boolean;
  cnt_fracasos_seguidos: TDAOfNInt;
  largo_u: integer;
  rnd: TMadreUniforme;
  j: integer;
  vma: NReal;
  jIter: integer;

  // retorna la posición de máximo agite aleatoria entre los que sean
  // iguales
  function pos_max_agite: integer;
  var
    k, j: integer;
    m, ma: NReal;
  begin
    k := 0;
    m := Agite[0];
    for j := 1 to high(Agite) do
    begin
      ma := Agite[j];
      if ma > m then
      begin
        m := ma;
        k := j;
      end
      else
      if (m = ma) and (rnd.rnd > 0.5) then
        k := j;

    end;
    Result := k;
  end;

begin
  rnd := TMadreUniforme.Create(31);
  inicializarOptimizacion_subproc01;
  if inicializarOptimizacion_subproc02(nil, nil) = 0 then
    exit; // No hay variables de estado = no hay optimización

  u := GLobs.CF.ControladorDeterministico.create_vect_u;
  largo_u := length(u);
  setlength(us, largo_u);
  setlength(Agite, largo_u);
  setlength(cnt_fracasos_seguidos, largo_u);
  vclear(u);

  // primera evaluacion de f(u)
  GLobs.CF.ControladorDeterministico.set_vect_u(u);
  c := Simular(0, False);



  // copiamos el vector para trabajar con us
  vcopy(us, u);


  for jIter := 1 to 3 do
  begin

    for j := 0 to high(Agite) do
    begin
      Agite[j] := 1000;
      cnt_fracasos_seguidos[j] := 0;
    end;

    flg_optimizando := True;
    while flg_optimizando do
    begin
      // selecciono al asar una dirección en al que probar
      j := rnd.randomIntRange(0, high(u));
      while Agite[j] < 1e-1 do
        j := rnd.randomIntRange(0, high(u));

      //    j:= pos_max_agite;
      us[j] := u[j] + (rnd.rnd - 0.5) * Agite[j];

      GLobs.CF.ControladorDeterministico.set_vect_u(us);
      cs := Simular(0, False);
      if cs < c then
      begin
        // tuve éxito cambio u y c y reseteo el contador de fracasos
        u[j] := us[j];
        c := cs;
        writeln;
        writeln('c: ', c, ' cnt_fracasos_seguidos: ', cnt_fracasos_seguidos[j],
          ', j: ', j);
        cnt_fracasos_seguidos[j] := 0;
      end
      else
      begin
        // fracaso, vuelvo a la posición original e incremento el número
        // de fracasos
        us[j] := u[j];
        Inc(cnt_fracasos_seguidos[j]);
        if cnt_fracasos_seguidos[j] > 5 then
        begin
          Agite[j] := Agite[j] / 2.0;
          vma := vmax(Agite);
          Write('| ', vma);
          cnt_fracasos_seguidos[j] := 0;
          if vma < 1e-1 then
            flg_optimizando := False;
        end;
      end;
    end;

  end;
  rnd.Free;

end;

procedure TSalaDeJuego.CrearYGuardarControladorDeterministicoInicial;
begin
  inicializarOptimizacion_subproc01;
  if inicializarOptimizacion_subproc02(nil, nil) = 0 then
    exit; // No hay variables de estado = no hay optimización
end;

{$ENDIF}


procedure TSalaDeJuego.inicializarArchisOptRes(var fsal: TextFile;
  var fsal_opt: TDAOfTextFile; var fsalopen: boolean);
var
  archi: string;
  k: integer;
  NoFinBarridoEstrellas: boolean;
begin
  if globs.SortearOpt then
    archi := dirResultadosCorrida + 'optres_' + IntToStr(
      globs.semilla_inicial_opt) + 'x' + IntToStr(globs.NCronicasOpt) +
      '_' + EscenarioActivo.nombre + '.xlt'
  else
    archi := dirResultadosCorrida + 'optres_VE' + '_' + EscenarioActivo.nombre + '.xlt';

  if FileExists(archi) then
    SysUtils.DeleteFile(archi);

  assignfile(fsal, archi);
  {$I-}
  rewrite(fsal);
  {$I+}
  if ioresult <> 0 then
    raise Exception.Create('No es posible crear el archivo: ' + archi);
  fsalopen := True;


  if escribirOptActores then
  begin
    Armar_lst_opt_PrintResultados;
    // aquí ya podemos detectar cuantos hay en lst_PrintResultadosOpt
    setlength(fsal_opt, lst_opt_PrintResultados.Count);
    for k := 0 to high(fsal_opt) do
    begin
      if globs.SortearOpt then
        archi := dirResultadosCorrida + 'opt' +
          TActor(lst_opt_PrintResultados.items[k]).nombre + '_' +
          IntToStr(globs.semilla_inicial_opt) + 'x' +
          IntToStr(globs.NCronicasOpt) + '_' + EscenarioActivo.nombre + '.xlt'
      else
        archi := dirResultadosCorrida + 'opt' +
          TActor(lst_opt_PrintResultados.items[k]).nombre + '_VE' +
          '_' + EscenarioActivo.nombre + '.xlt';
      assignfile(fsal_opt[k], archi);
      rewrite(fsal_opt[k]);
    end;
  end
  else
  begin
    SetLength(fsal_opt, 0);
    Armar_lst_opt_PrintResultados;
    for k := 0 to lst_opt_PrintResultados.Count - 1 do
    begin
      if globs.SortearOpt then
        archi := dirResultadosCorrida + 'opt' +
          TActor(lst_opt_PrintResultados.items[k]).nombre + '_' +
          IntToStr(globs.semilla_inicial_opt) + 'x' +
          IntToStr(globs.NCronicasOpt) + '_' + EscenarioActivo.nombre + '.xlt'
      else
        archi := dirResultadosCorrida + 'opt' +
          TActor(lst_opt_PrintResultados.items[k]).nombre + '_VE' +
          '_' + EscenarioActivo.nombre + '.xlt';
      DeleteFile(PChar(archi));
    end;
    lst_opt_PrintResultados.Clear;
  end;

  system.Writeln(fsal, 'Versión del simulador:'#9, vSimSEESimulador_);
  for k := 0 to high(fsal_opt) do
    writeln(fsal_opt[k], 'Versión del simulador:'#9, vSimSEESimulador_);
  writeln(fsal, 'fActPaso: '#9, FloatToStrF(globs.fActPaso, ffGeneral, 12, 10));
  for k := 0 to high(fsal_opt) do
    writeln(fsal_opt[k], 'fActPaso:'#9, FloatToStrF(globs.fActPaso,
      ffGeneral, 12, 10));
  globs.CF.constelacion.PrintDefsToText(fsal, True);
  for k := 0 to high(fsal_opt) do
    globs.CF.constelacion.PrintDefsToText(fsal_opt[k], False);

  Write(fsal, 'paso\estado'#9'Fecha');
  for k := 1 to globs.CF.nEstrellasPorPuntoT do
    Write(fsal, #9, k);
  writeln(fsal);

  // salvamos el frame del último paso de tiempo
  globs.Fijar_kPaso(globs.kPaso_Opt + 1);
  Write(fsal, IntToStr(globs.kpaso_Opt) + #9 + globs.FechaInicioDelpaso.AsISOStr);
  globs.Fijar_kPaso(globs.kPaso_Opt - 1);
  for k := 0 to high(fsal_opt) do
    Write(fsal_opt[k], 'paso\estado'#9'Fecha');

  globs.CF.setEstrellaCERO;
  NoFinBarridoEstrellas := True;
  while NoFinBarridoEstrellas do
  begin
    globs.CF.SetEstadoToEstrella; // Fijamos la estrella
    Write(fsal, #9, FloatToStrF(globs.CF.costoEstrella(globs.kPaso_Opt + 1)
      , ffGeneral, 6, 2));
    for k := 0 to high(fsal_opt) do
    begin
      TActor(Self.lst_opt_PrintResultados.items[k]).PosicionarseEnEstrellita;

      TActor(Self.lst_opt_PrintResultados.items[k]).prepararPaso_ps;
      TActor(Self.lst_opt_PrintResultados.items[k]).opt_PrintResultados_Encab(
        fsal_opt[k]);
    end;
    NoFinBarridoEstrellas := globs.CF.incEstrella;
  end;// barrido estrellas
  writeln(fsal);
  for k := 0 to high(fsal_opt) do
    writeln(fsal_opt[k]);
end;

procedure TSalaDeJuego.escribirPasoOptRes(var fsal: TextFile;
  var fsal_opt: TDAOfTextFile);
var
  k: integer;
  NoFinBarridoEstrellas: boolean;
begin
  writeln(fsal, IntToStr(globs.kPaso_Opt) + #9 + globs.FechaInicioDelpaso.AsISOStr,
    #9, TDAOfNRealToTabbedString(globs.cf.constelacion.fcosto[globs.kpaso_Opt], 6, 2));

  if escribirOptActores then
  begin
    for k := 0 to high(fsal_opt) do
      Write(fsal_opt[k], IntToStr(globs.kPaso_Opt) + #9 +
        globs.FechaInicioDelpaso.AsISOStr);
    vclear(globs.CF.estrella_kr);
    vclear(globs.CF.estrella_kd);
    NoFinBarridoEstrellas := True;
    while NoFinBarridoEstrellas do
    begin
      globs.CF.SetEstadoToEstrella;
      PosicionarseEnEstrellita;

      //rch@201408261402 atención!!!
      // agrego este Actualizar con Xs para que las derivadas de CF se calculen
      // en base al Xs proyectado
      fuentes_ActualizarEstadoGlobal(True);
      actores_ActualizarEstadoGlobal(True);


      for k := 0 to high(fsal_opt) do
      begin
        TActor(Self.lst_opt_PrintResultados.items[k]).prepararPaso_ps;
        TActor(Self.lst_opt_PrintResultados.items[k]).opt_PrintResultados(fsal_opt[k]);
      end;
      NoFinBarridoEstrellas := globs.CF.incEstrella;
    end;
    for k := 0 to high(fsal_opt) do
      writeln(fsal_opt[k]);
  end;
end;

procedure TSalaDeJuego.cerrarArchisOptRes(var fsal: TextFile;
  var fsal_opt: TDAOfTextFile; var fsalopen: boolean);
var
  k: integer;
begin
  if fsalopen then
  begin
    for k := 0 to high(fsal_opt) do
      closeFile(fsal_opt[k]);
    if fsalopen then
      closeFile(fsal);
  end;
end;


{$IFDEF ESTABILIZAR_FRAMEINICIAL}
procedure TSalaDeJuego.EstabilizarFrameInicial;
const
  MAX_CANT_ITERS = 100;
var
  NoFinBarridoEstrellas: boolean;

  //cociente sera costok+1/costok
  cociente: NReal;
  maxCociente: NReal;
  CostoFuturo_Esperado, CostoDelPaso_Simplex: NReal;
  //  CF_Base: NReal;
  cntIters: integer;
  stop: boolean;
  max, min, err, err_estrella: NReal;
  k: integer;

  err_max_relativo: NReal;

begin

  writeln('Estabilizando freme inicial');

  cntIters := 0;
  stop := False;
  globs.kCronica := 0;

  err_max_relativo := 0.05;

  while (not stop) and (cntIters < MAX_CANT_ITERS) do
  begin

    (**********************************)
    globs.ActualizadorLPD.ActualizarFichasHasta(globs.FechaInicioDelpaso);
    PrepararPaso_as;
    globs.procNot(globs.procNot_opt_InicioCalculosDeEtapa);

    if globs.SortearOpt then // Cálculo de los costos de la etapa con sorteos
    begin
      OptimizacionCronizada_UnPaso_RangoDeEstrellas(
        0, globs.CF.nEstrellasPorPuntoT - 1, True, True);
    end // fin de la optimización Cronizada
    else
    begin // incio: optimización con valores esperados
      OptimizacionValorEsperado_UnPaso_RangoDeEstrellas(
        0, globs.CF.nEstrellasPorPuntoT - 1, True, True);
    end;
    (*****************)
    min := vmin(globs.CF.constelacion.fCosto[globs.kPaso_Opt]);
    max := vmax(globs.CF.constelacion.fCosto[globs.kPaso_Opt]) - min;
    err := 0;
    for k := 0 to high(globs.CF.constelacion.fCosto[globs.kPaso_Opt]) do
    begin
      globs.CF.constelacion.fCosto[globs.kPaso_Opt][k] :=
        globs.CF.constelacion.fCosto[globs.kPaso_Opt][k] - min;
      err_estrella := abs(globs.CF.constelacion.fCosto[globs.kPaso_Opt][k] -
        globs.CF.constelacion.fCosto[globs.kPaso_Opt + 1][k]) / max;
      if err_estrella > err then
        err := err_estrella;
    end;

    writeln(cntIters, ' : ', err: 12: 4);

    vswap(globs.CF.constelacion.fCosto[globs.kPaso_Opt],
      globs.CF.constelacion.fCosto[globs.kPaso_Opt + 1]);
    if err < err_max_relativo then
      stop := True;
    Inc(cntIters);

  end;

  if not stop then
    globs.Alerta(Self.Nombre + ': Estabilizar frame inicial no convergio');
end;

{$ENDIF}



procedure AlInicio;
begin
  registrarClaseDeCosa(TSalaDeJuego.ClassName, TSalaDeJuego);
end;

procedure AlFinal;
begin
end;

end.
