{$MODE Delphi}

{$DEFINE MONITORES}

unit SimSEEEditMain;

interface

uses
  LResources,
  EditBtn,
  uEditarMemo,
  ueditarfichafuentetiempo, ufuentetiempo,
  ueditarfichafuentesinusoide, ufuentesinusoide,
  ueditarfichafuentemaxmin, ufuentemaxmin, uEditarTGTer_Combinado,
  uEditarTMercadoSpot_postizado, uEditarFichaGTer_combinado,
  uEditarFichaMercadoSpot_postizado, uEditarFichaMercadoSpot_postizado_Fuentes,
  FileUtil, IpHtml, //TreeFilterEdit,
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, StdCtrls, ComCtrls, ExtCtrls, Grids, Buttons,
  LCLIntf,
  xmatdefs, ufechas, utilidades, utrazosxy,
  uConstantesSimSEE, uFormEditarOpciones, uAuxiliares,
  uBaseFormularios, uverdoc, uversiones, usalasdejuego,
  usalasdejuegoParaEditor,
  uListaMantenimientos,
  uEditarFichaUnidades, ucosa, ucosaparticipedemercado,
  uActorNodal,
  uActores,
  uunidades,
  ugter_basico,
  ugter_arranqueparada,
  ugter_onoffporpaso,
  ugter_onoffporposte,
  ugter_combinado,
  usolartermico,
  usolarPV,
  ubiomasaembalsable,
  unodos,
  unodocombustible,
  uarcocombustible,
  ugsimple_bicombustible,
  ugsimple_monocombustible,
  uDemandaCombustibleAnioBaseEIndices,
  uTSumComb,
  ueditarsumcomb,
  ueditarfichasumcomb,
  ueditartgsimple_bicombustible,
  ueditarfichagsimple_bicombustible,
  ueditartgsimple_monocombustible,
  ueditarfichagsimple_monocombustible,
  uEditarFichaArcoCombustible,
  uEditarTArcoCombustible,
  uEditarTDemandaCombustibleAnioBaseEIndices,
  uDemandas,
  udemandas01,
  uDemandaAnioBaseEIndices,
  uDemandaDetallada,
  uArcos,
  uArcoConSalidaProgramable,
  uCombustible,
  uHidroConEmbalse,
  uHidroConBombeo,
  uGeneradores,
  uCosaConNombre,
  uHidroDePasada,
  uMercadoSpot,
  uMercadoSpot_postizado,
  uParqueEolico,
  uParqueEolico_vxy,
  ugter_basico_TRep,
  ugter_basico_PyCVariable,
  ucontratomodalidaddevolucion,
  uComercioInternacional,
  uMercadoSpotConDetalleHorarioSemanal,
  ugter_onoffporpaso_conrestricciones,
  uHidroConEmbalseBinacional,
  uEditorSimRes3Main,
  uOpcionesSimSEEEdit,
  uBaseEditoresCosasConNombre,
  uEditarTNodo,
  uEditarTContratoModalidadDevolucion,
  uEditarTArco,
  uEditarTArcoConSalidaProgramable,
  uEditarTDemanda01,
  uEditarTDemandaAnioBaseEIndices,
  uEditarTDemandaDetallada,
  uEditarTGTer,
  uEditarTGTer_ArranqueParada,
  uEditarTGTer_Basico_TRep,
  ueditarTSolarTermico,
  ueditarTSolarPV,
  uEditarTBiomasaEmbalsable,
  uEditarTGTer_Basico_PyCVariable,
  uEditarTGTer_OnOffPorPaso_ConRestricciones,
  uEditarTHidroConEmbalse,
  uEditarTHidroConBombeo,
  uEditarTHidroConEmbalseBinacional,
  uEditarTHidroDePasada,
  uEditarTBaseMercadoSpot,
  uEditarTParqueEolico,
  uEditarTParqueEolico_vxy,
  uManejadoresDeMonitores,
  uReferenciaMonitor, uReferenciaMonitorConsola, uReferenciaMonitorGraficoSimple,
  uReferenciaMonArchivo, uReferenciaMonHistograma, uReferenciaMonSimRes,
  uBaseAltasMonitores, uAltaMonitorConsola, uAltaMonitorGrafico, uAltaMonArchivo,
  uAltaMonHistograma, uAltaMonSimRes,
  uFuentesAleatorias,
  uFuenteConstante, uFuenteUniforme, uFuenteGaussiana, uFuenteWeibull,
  uFuenteSintetizador, uFuenteCombinacion, uFuenteProducto, uFuenteSelector,
  uFuenteSelector_horario,
  uEditarFichaFuenteSelector_horario,
  uEditarFuentesSimples, uEditarFuenteSintetizador,
  uEditarFichaFuenteUniforme, uEditarFichaFuenteGaussiana, uEditarFichaFuenteConstante,
  uEditarFichaFuenteWeibull, uEditarFichaFuenteCombinacion,
  uEditarFichaFuenteProducto, uEditarFichaFuenteSelector,
  uEditarFichaGTer_Basico, uEditarFichaGTer_ArranqueParada,
  uEditarFichaGTer_OnOffPorPaso, uEditarFichaGTer_OnOffPorPoste,
  uEditarFichaSolarTermico, uEditarFichaSolarPV,
  uEditarFichaBiomasaEmbalsable,
  uEditarTCombustible,
  uEditarFichaCombustible,
  uRobotHttpPost,

  // {$IFDEF REGAS}

  uEditarRegasificadora,
  uRegasificadora,
  uEditarFichaRegasificadora,
  //{$ENDIF}


  uEditarFichaDemanda01, uEditarFichaHidroConEmbalse,
  uEditarFichaHidroConBombeo,
  uEditarFichaHidroDePasada,
  uEditarFichaArco,
  uEditarFichaArcoConSalidaProgramable,
  uEditarFichaMercadoSpot, uEditarFichaGTer_Basico_TRep,
  uEditarFichaGTer_Basico_PyCVariable,
  uEditarFichaContratoModalidadDevolucion, uEditarFichaMercadoSpotConDetalleHorario,
  uEditarFichaGTer_OnOffPorPaso_ConRestricciones,
  uEditarFichaHidroConEmbalseBinacional,
  uEditarFichaUsoGestionable_postizado, uEditarTUsoGestionable_postizado,
  ubancodebaterias01, ueditartbancodebaterias01, ueditarfichabancodebaterias01,
  uusogestionable_postizado,
  uInfoTabs, uFormSelectTipo, uInfoCosa, uFormExportar,
  uEstados, uEditarEnganches,
  uInterpreteDeParametros,
  uComponerCFs,
  uempaquetar,
  ulst_generadores,
  types,
  uFlucar, urawdata,
  uvisordetabla,
  ulst_plantillassimres3,
  ulst_escenarios,
  uescenarios, uCosaHashList,
  ueditor_resourcestrings,
  uEditarTNodoCombustible, uvisorgraficomantenimientos;

const
  NDivsAnioPMantenimiento = 53;
  separadorDeLineas = '|';
  IMG_NODE_ROOT = 0;
  IMG_NODE_CLOSED = 1;
  IMG_NODE_OPEN = 2;



type

  { TFSimSEEEdit }

  TFSimSEEEdit = class(TBaseFormularios)
    BAgregarCombustible: TButton;
    BAgregarFichaUnidades: TButton;
    BAgregarFuente: TButton;
    BAgregarMonitor: TButton;
    BAyudaEnganchar: TButton;
    BCrearMonitorSimRes3PDefecto: TButton;
    btEjecutarManualmente: TButton;
    btAyudaFuentes: TButton;
    btAyudaMonitores: TButton;
    btAyuda_EmisionesCO2: TButton;
    btCrearNuevoEscenario: TButton;
    btGuardarMantenimientos: TButton;
    btVaciarCFAux: TButton;
    btVisorGraficoMantenimientos: TButton;
    bt_sr3_agregar_de_disco: TButton;
    bt_sr3_crear_nueva: TButton;
    bt_VaciarCFEnganche: TButton;
    btExportarActor_Barra: TButton;
    btImportarActor_Barra: TButton;
    btAplicarFiltro: TButton;
    btTodos: TButton;
    bt_Buscar_Flucar: TButton;
    BDefinir_Enganches_SimSEE_Flucar: TButton;
    Button2: TButton;
    Button3: TButton;
    btEjecutarAutomaticamente: TButton;
    btListarCapas: TButton;
    cbAversionAlRiesgo: TCheckBox;
    cbEmisionesCO2: TCheckBox;
    CBObligar_Disp1_Opt: TCheckBox;
    CBPostesMonotonos: TCheckBox;
    cb_enganchar_promediando_desaparecidas: TCheckBox;
    cb_CO2_ProyectoTipoSolarEolico: TCheckBox;
    cbModificarRendimiento: TCheckBox;
    cbModificarCapacidad: TCheckBox;
    cbModificarPeaje: TCheckBox;
    cbUsarIteradorFlucar: TCheckBox;
    cbGenerarRaws: TCheckBox;
    cbRestarUtilidadesDeCF: TCheckBox;
    cb_EngancharSala_Escenario: TComboBox;
    cbObligarInicioCronicaIncierto: TCheckBox;
    cbPublicarSoloVariablesUsadasEnSimRes3: TCheckBox;
    cb_flg_ImprimirArchivosEstadoFinCronica: TCheckBox;
    cbReservaRotante: TCheckBox;
    cbConsiderarPagosEnCF: TCheckBox;
    cgMascaraRun: TCheckGroup;
    eCAR: TEdit;
    EArchivo_Flucar: TEdit;
    EDurPaso: TEdit;
    eDurPaso_Minutos: TEdit;
    eFechaFinOpt: TEdit;
    eFechaIniOpt: TEdit;
    eFechaFinSim: TEdit;
    eFechaIniSim: TEdit;
    eFechaGuardaSim: TEdit;
    eFiltroGeneradores_CO2: TEdit;
    ENPasosOpt: TEdit;
    ENPasosSim: TEdit;
    eSemillaINicial_opt: TEdit;
    eSemillaInicial_sim: TEdit;
    eUniformizarPromediando: TEdit;
    eLimiteProbabilidad: TEdit;
    eNDiscHisto: TEdit;
    gbEscenarios: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    IntNPostes: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    eHusoHorario_UTC: TLabeledEdit;
    lblEngancheEscenario: TLabel;
    lblFormatoFecha: TLabel;
    LabelEnganchar: TLabel;
    LDurPaso: TLabel;
    LNPasosOpt: TLabel;
    LNPasosSim: TLabel;
    LNPostes: TLabel;
    LV_Simsee_Flucar: TListView;
    LV_Flucar: TListView;
    MainMenu1: TMainMenu;
    MArchivo: TMenuItem;
    mConsola: TMemo;
    mComandos: TMemo;
    MenuItem1: TMenuItem;
    MADME_DATA: TMenuItem;
    MSoporteUsuarios: TMenuItem;
    miComponerCFs: TMenuItem;
    MNuevo: TMenuItem;
    MAbrir: TMenuItem;
    N1: TMenuItem;
    MGuardar: TMenuItem;
    MGuardarComo: TMenuItem;
    N2: TMenuItem;
    MSalir: TMenuItem;
    DCargarSala: TOpenDialog;
    DSalvarSala: TSaveDialog;
    od: TOpenDialog;
    OD_Flucar: TOpenDialog;
    odPlantilla: TOpenDialog;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    panel_durpaso_minutal: TPanel;
    panel_durpos_horaria: TPanel;
    PCEditMain: TPageControl;
    rgModoEjecucion: TRadioGroup;
    rg_HorariaOMinutal: TRadioGroup;
    rbTipoOptimizacion: TRadioGroup;
    rb_CVaR: TRadioButton;
    rb_VaR: TRadioButton;
    rg_FactorEmisiones_MargenOperativoTipo: TRadioGroup;
    RBElegirSala: TRadioButton;
    RBElegirCF: TRadioButton;
    sb_Escenarios: TScrollBox;
    sb_Generadores: TScrollBox;
    sb_PlantillasSimRes3: TScrollBox;
    sd: TSaveDialog;
    sgCombustible: TStringGrid;
    sgPostes: TStringGrid;
    Splitter3: TSplitter;
    TabSheet1: TTabSheet;
    tsCapas: TTabSheet;
    ts_Escenarios: TTabSheet;
    ts_Flucar: TTabSheet;
    ts_PlantillasSimRes3: TTabSheet;
    TV_Simsee: TTreeView;
    ts_CO2: TTabSheet;
    ts_Combustible: TTabSheet;
    ts_Globales: TTabSheet;
    ts_Actores: TTabSheet;
    TCActores_: TTabControl;
    PActores: TPanel;
    ts_Fuentes: TTabSheet;
    ts_Estado: TTabSheet;
    ts_Simulador: TTabSheet;
    ts_Monitores: TTabSheet;
    sgMonitores: TStringGrid;
    MAyuda: TMenuItem;
    MManual: TMenuItem;
    DSalvarManejadorMonitores: TSaveDialog;
    MHerramientas: TMenuItem;
    MImportar: TMenuItem;
    MExportar: TMenuItem;
    sgFuentes: TStringGrid;
    DCargarManejadorMonitores: TOpenDialog;
    MMonitores: TMenuItem;
    MCargarMonitores: TMenuItem;
    N4: TMenuItem;
    MGuardarMonitores: TMenuItem;
    MGuardarMonitoresComo: TMenuItem;
    DImportarActor: TOpenDialog;
    MOpciones: TMenuItem;
    btAyudaEstados: TButton;
    gbHorizTiempo: TGroupBox;
    LFechaIni: TLabel;

    LFechaFin: TLabel;
    gbPasoTiempo: TGroupBox;
    btAyudaGlobales: TButton;
    ODO1: TMenuItem;
    gbVarSim_: TGroupBox;
    LNCronicasSim: TLabel;
    ENCronicasSim: TEdit;
    CBObligar_Disp1_Sim: TCheckBox;
    gbVarOpt: TGroupBox;
    EtAct: TEdit;
    ENCronicasOpt: TEdit;
    LNCronicasOpt: TLabel;
    LtAct: TLabel;
    CBSorteos: TCheckBox;
    btAyudaSimulador: TButton;
    PanelInferiorPrincipal: TPanel;
    gbAdvertencias: TGroupBox;
    MemoWarnings: TMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    gbDesc: TGroupBox;
    MemoDesc: TMemo;
    GBInicializarCF: TGroupBox;
    RGLlenarUltimoFrame: TRadioGroup;
    EArchivoCF: TEdit;
    BBuscarArchivoCF: TButton;
    CBEstabilizarFrameInicial: TCheckBox;
    ODCF: TOpenDialog;
    LSim: TLabel;
    LOpt: TLabel;

    BEnganches: TButton;
    MGenerarResumenTermico: TMenuItem;
    Panel1: TPanel;
    BGenerarResumenTermico: TButton;
    BImportar: TButton;
    BExportar: TButton;
    BAgregarActor: TButton;
    Panel2: TPanel;
    btAyudaActores_listaespecifica: TButton;
    Panel3: TPanel;
    sgActores: TStringGrid;
    ts_AyudaSolaperoPrincipal: TTabSheet;
    ts_Mantenimientos: TTabSheet;
    sgMantenimientos: TStringGrid;
    N3: TMenuItem;
    MCrearMonitorSimResPorDefecto: TMenuItem;
    lMaxNItersOpt: TLabel;
    eMaxNItersOpt: TEdit;
    eMaxNItersSim: TEdit;
    lMaxNItersSim: TLabel;
    MActualizar: TMenuItem;
    GroupBox1: TGroupBox;
    eArchiCFaux: TEdit;
    Button1: TButton;
    btBuscarCFaux: TButton;
    ddd1: TMenuItem;
    procedure BAyudaEngancharClick(Sender: TObject);
    procedure BDefinir_Enganches_SimSEE_FlucarClick(Sender: TObject);
    procedure btAyudaCrearFrameEngancheClick(Sender: TObject);
    procedure btAyuda_EmisionesCO2Click(Sender: TObject);
    procedure btGuardarMantenimientosClick(Sender: TObject);
    procedure btEjecutarAutomaticamenteClick(Sender: TObject);
    procedure btListarCapasClick(Sender: TObject);
    procedure btTodosClick(Sender: TObject);
    procedure btVaciarCFAuxClick(Sender: TObject);
    procedure btVisorGraficoMantenimientosClick(Sender: TObject);
    procedure bt_Buscar_FlucarClick(Sender: TObject);
    procedure bt_sr3_agregar_de_discoClick(Sender: TObject);
    procedure bt_sr3_crear_nuevaClick(Sender: TObject);
    procedure bt_VaciarCFEngancheClick(Sender: TObject);
    procedure btExportarActor_BarraClick(Sender: TObject);
    procedure btImportarActor_BarraClick(Sender: TObject);
    procedure btAplicarFiltroClick(Sender: TObject);
    procedure btCrearNuevoEscenarioClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure cbAversionAlRiesgoChange(Sender: TObject);
    procedure cbAversionAlRiesgoClick(Sender: TObject);
    procedure cbConsiderarPagosEnCFClick(Sender: TObject);
    procedure cbEmisionesCO2Click(Sender: TObject);
    procedure cbGenerarRawsChange(Sender: TObject);
    procedure cbPublicarSoloVariablesUsadasEnSimRes3Change(Sender: TObject);
    procedure cbModificarCapacidadClick(Sender: TObject);
    procedure cbModificarPeajeClick(Sender: TObject);
    procedure cbModificarRendimientoClick(Sender: TObject);
    procedure cbObligarInicioCronicaInciertoChange(Sender: TObject);
    procedure CBObligar_Disp1_OptChange(Sender: TObject);
    procedure CBObligar_Disp1_SimChange(Sender: TObject);
    procedure cbReservaRotanteChange(Sender: TObject);
    procedure cbRestarUtilidadesDeCFClick(Sender: TObject);
    procedure CBSorteosChange(Sender: TObject);
    procedure cbUsarIteradorFlucarChange(Sender: TObject);
    procedure cb_CO2_ProyectoTipoSolarEolicoChange(Sender: TObject);
    procedure cb_enganchar_promediando_desaparecidasChange(Sender: TObject);
    procedure cb_flg_ImprimirArchivosEstadoFinCronicaChange(Sender: TObject);
    procedure eArchiCFauxChange(Sender: TObject);
    procedure EArchivoCFChange(Sender: TObject);
    procedure eCARChange(Sender: TObject);
    procedure eCAREditingDone(Sender: TObject);
    procedure eCAREnter(Sender: TObject);
    procedure eDurPaso_MinutosChange(Sender: TObject);
    procedure eFechaGuardaSimChange(Sender: TObject);
    procedure eFechaIniSimChange(Sender: TObject);
    procedure eHusoHorario_UTCChange(Sender: TObject);
    procedure eLimiteProbabilidadChange(Sender: TObject);
    procedure eLimiteProbabilidadEditingDone(Sender: TObject);
    procedure eLimiteProbabilidadEnter(Sender: TObject);
    procedure eNDiscHistoEditingDone(Sender: TObject);
    procedure eNDiscHistoEnter(Sender: TObject);
    procedure eSemillaINicial_optChange(Sender: TObject);
    procedure eSemillaINicial_optEditingDone(Sender: TObject);
    procedure eSemillaInicial_simChange(Sender: TObject);
    procedure eSemillaInicial_simEditingDone(Sender: TObject);
    procedure eUniformizarPromediandoChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditTamTablaExit(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gbEscenariosClick(Sender: TObject);
    procedure gbVarOptClick(Sender: TObject);
    procedure gbVarSim_Click(Sender: TObject);
    procedure GroupBox3Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure LNPostesClick(Sender: TObject);
    procedure mConsolaKeyPress(Sender: TObject; var Key: char);
    procedure MenuItem1Click(Sender: TObject);
    procedure MADME_DATAClick(Sender: TObject);
    procedure miComponerCFsClick(Sender: TObject);
    procedure MNuevoClick(Sender: TObject);
    procedure MAbrirClick(Sender: TObject);
    procedure MGuardarComoClick(Sender: TObject);
    procedure MGuardarClick(Sender: TObject);
    procedure MSalirClick(Sender: TObject);
    procedure MSoporteUsuariosClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure rbTipoOptimizacionClick(Sender: TObject);
    procedure rb_CVaRClick(Sender: TObject);
    procedure rgModoEjecucionClick(Sender: TObject);
    procedure rg_FactorEmisiones_MargenOperativoTipoClick(Sender: TObject);
    procedure RBElegirCFChange(Sender: TObject);
    procedure RBElegirSalaChange(Sender: TObject);
    procedure rg_HorariaOMinutalClick(Sender: TObject);
    procedure sgPostesGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgPostesValidarCambio(Sender: TObject);
    procedure TCActores_Change(Sender: TObject);
    procedure BAgregarActorClick(Sender: TObject);
    procedure sgActoresDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgActoresMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgActoresMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure sgActoresMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure EditNCronicasSimExit(Sender: TObject);
    procedure btEjecutarManualmenteClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure sgMonitoresDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgMonitoresMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure sgMonitoresMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgMonitoresMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAgregarMonitorClick(Sender: TObject);
    procedure recalcNumeroPasos(Sender: TObject);
    procedure MManualClick(Sender: TObject);
    procedure CBSorteosClick(Sender: TObject);
    procedure EtActExit(Sender: TObject);
    procedure EditNCronicasOptExit(Sender: TObject);
    procedure DTPEnter(Sender: TObject);
    procedure MExportarClick(Sender: TObject);
    procedure MImportarClick(Sender: TObject);
    procedure PCEditMainChange(Sender: TObject);
    procedure sgMantenimientosDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgMantenimientosMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgFuentesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgFuentesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure sgFuentesDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgFuentesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgCombustibleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgCombustibleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure sgCombustibleDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgCombustibleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAgregarFuenteClick(Sender: TObject);
    procedure BAgregarCombustibleClick(Sender: TObject);
    procedure MCargarMonitoresClick(Sender: TObject);
    procedure MGuardarMonitoresClick(Sender: TObject);
    procedure MGuardarMonitoresComoClick(Sender: TObject);
    procedure BImportarClick(Sender: TObject);
    procedure BExportarClick(Sender: TObject);
    procedure MOpcionesClick(Sender: TObject);
    procedure CBPostesMonotonosClick(Sender: TObject);
    procedure MemoDescEnter(Sender: TObject);
    procedure MemoDescExit(Sender: TObject);
    procedure btAyudaSimuladorClick(Sender: TObject);
    procedure btAyudaGlobalesClick(Sender: TObject);
    procedure btAyudaFuentesClick(Sender: TObject);
    procedure btAyudaActores_listaespecificaClick(Sender: TObject);
    procedure btAyudaMantenimientosClick(Sender: TObject);
    procedure btAyudaEstadosClick(Sender: TObject);
    procedure btAyudaMonitoresClick(Sender: TObject);
    procedure ODO1Click(Sender: TObject);
    procedure CBEstabilizarFrameInicialClick(Sender: TObject);
    procedure RGLlenarUltimoFrameClick(Sender: TObject);
    procedure BBuscarArchivoCFClick(Sender: TObject);
    procedure EArchivoCFExit(Sender: TObject);
    procedure BEnganchesClick(Sender: TObject);
    procedure GenerarResumenTermico(Sender: TObject);
    procedure sgMantenimientosMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure sgMantenimientosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAgregarFichaUnidadesClick(Sender: TObject);
    procedure sgMantenimientosValidarCambio(Sender: TObject);
    procedure sgMantenimientosGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure EditEnter(Sender: TObject);
    procedure BCrearMonitorSimRes3PDefectoClick(Sender: TObject);
    procedure MCrearMonitorSimResPorDefectoClick(Sender: TObject);
    procedure eMaxNItersOptExit(Sender: TObject);
    procedure eMaxNItersSimExit(Sender: TObject);
    procedure DTPFechaFinSimChange(Sender: TObject);
    procedure DTPFechaIniOptChange(Sender: TObject);
    procedure DTPFechaFinOptChange(Sender: TObject);
    procedure sgPostesKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure MActualizarClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btBuscarCFauxClick(Sender: TObject);
    procedure ddd1Click(Sender: TObject);
    procedure tsCapasContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ts_GlobalesEnter(Sender: TObject);
    procedure ts_GlobalesShow(Sender: TObject);
    procedure TV_SimseeClick(Sender: TObject);
  private
    //    archiEditorSimRes3: string;

    hid_ActoresListaEspecifica: string;
    guardadoMonitores: boolean;
    TiposColActores, TiposColMonitores, TiposColMantenimientos,
    TiposColFuentes, TiposColCombustibles: TDAOfTTipoColumna;
    monitoresEnabled: TDAOfBoolean;
    // Las listas de los actores que muestra el listado
    ListasDeActoresTabs: array of TListaDeCosasConNombre;

    listaMantenimientos: TListaMantenimientos;

    nErroresCargando: integer;

    { procedure cargarDatosListadoMantenimiento;
      procedure actualizarAnioTablaMantenimiento(anio: Integer);
      procedure actualizarTablaMantenimiento(primerSemana, ultimaSemana: Integer);

      procedure agregarMantenimiento(actor: TActor ; col: Integer);
      procedure modificarMantenimiento; }


    procedure ClearConsolaAlertas;
    procedure WritelnAlerta(const s: string);

    function Ejecutar_Opt_Sim_SimRes(sala: TSalaDeJuego;
      archiSala, archiMonitores: string; Escenario: TEscenario_rec): integer;
    procedure LoadFormulario_SALAyGLOBS;
    procedure validarCambioTablaPostes(tabla: TStringGrid);

    procedure intentarCargarDeParametros;
    // procedure eliminarFuncionesPrivadasNoReferenciadas;
    // Crea una sala nueva con valores por defecto
    procedure crearSalaIni;
    // Carga una sala de juego de un archivo de texto (seleccionado en DCargarSala)
    procedure abrir;
    // Guarda la sala de juego en el archivo indicado por DSalvarSala
    procedure guardar;
    procedure abrirMonitores;
    procedure guardarMonitores;

    // Carga en el formulario los valores de la sala
    procedure Init;
    // Carga en el formulario los valores de los monitores
    procedure InitMonitores;
    // Separa los actores en los tabs que les corresponden
    procedure cargarListados;
    // Borra la sala actual, las referencias y las listas de actores asociados a los tabs
    procedure LimpiarSala;
    // Borra el manejador de monitores y lo pone a nil
    procedure LimpiarManejadorMonitores;

    // Carga los valores de los actores como si se estuviera simulando y se
    // hubiera llegado a fecha, retorna el paso de tiempo al que se llego
    // paso contiene el ultimo paso que ha sido preparado, se agrega para
    // poder preparar varios pasos seguidos de forma eficiente
    { function prepararSala(fecha: TFecha ; paso, horasDelPaso: Integer): Integer;
      procedure manejarExcepcionPrepararSala(e: Exception); }


    // abre un editor de Plantilla SimRes3 para el archivo archi.
    // si no existe el archivo permite crearlo.
    // si en el editor se hace GuardarComo retorna el nuevo archi
    // Retorna TRUE si se volvió del editor correctamente
    function EditarCrearSimRes3(var archi: string): boolean;

  protected
    function validarFechasOptSim: boolean;
    function validarFormulario: boolean; override;

  public

    lst_co2_gens: TListadoGeneradores;
    lst_PlantillasSimRes3: TListadoPlantillasSimRes3;
    lst_Escenarios: TListadoEscenarios;

    manejadorMonitores: TManejadoresDeMonitores;
    interpreteDeParametros: TInterpreteParametros;

    // lista de ayuda para la exporación por comando ls, cd
    LasCosas: TList;


    {dfusco/fbarreto@20150416
     Este constructor es necesario para que pase por los constructores padre.
     NO BORRAR aunque parezca innecesario. }
    constructor Create(AOwner: TComponent); reintroduce;

    // Registra los actores conocidos con sus formularios de alta y sus editores
    class procedure registrarActores;
    // Registra los monitores conocidos con sus formularios de alta y edicion
    class procedure registrarMonitores;
    // Registra las fuentes aleatorias conocidas con sus formularios de alta y edicion
    class procedure registrarFuentes;

    // Registra los combustibles conocidos con sus formularios de alta y edicion
    class procedure registrarCombustibles;


    // Manipulacion de actores
    // Retornan NIL si el usuario da cancelar y el actor resultado si dió guardar
    function altaActorClaseBase(claseBase: TClass): TActor;
    function altaActor(const nombreTab: string): TActor;
    function editarActor(actor: TActor): TActor;
    function clonarActor(actorOrig: TActor): TActor;

    // Retornan true si el actor se elimino, false si no
    function eliminarActor(actor: TActor): boolean;
    function eliminarNodo(nodo: TNodo): boolean;

    function altaActorCast(const nombreTab: string): TCosaConNombre;
    function clonarActorCast(actorOrig: TCosaConNombre): TCosaConNombre;
    function eliminarActorCast(actor: TCosaConNombre): boolean;

    // Para dar de alta sin editar, en una importación
    function agregarActor(actor: TActor): boolean;
    procedure importar;

    procedure actualizarTablaActores;
    // Fin de manipulacion de actores

    // Manipulacion de fuentes
    // Retornan NIL si el usuario da cancelar y la fuente resultado si dió guardar
    function altaFuente: TFuenteAleatoria;
    function editarFuente(fuente: TFuenteAleatoria): TFuenteAleatoria;
    function clonarFuente(fuenteOrig: TFuenteAleatoria): TFuenteAleatoria;
    // Retornan true si la fuente se elimino, false si no
    function eliminarFuente(fuente: TFuenteAleatoria): boolean;
    procedure actualizarTablaFuentes;

    procedure actualizarTablaPlantillasSimRes3;
    procedure actualizarTablaEscenarios;


    // Manipulacion de combustibles
    function altaCombustible: TCombustible;
    function editarCombustible(combustible: TCombustible): TCombustible;
    function clonarCombustible(combustibleOrig: TCombustible): TCombustible;
    // Retornan true si la fuente se elimino, false si no
    function eliminarCombustible(combustible: TCombustible): boolean;
    procedure actualizarTablaCombustibles;

    function editarMantenimiento(fila: integer; clonar: boolean): integer;
    procedure eliminarMantenimiento(fila: integer);
    procedure altaMantenimiento;
    procedure actualizarTablaMantenimientos;
    function validarCeldaMantenimientos(listado: TStringGrid;
      fila, columna: integer): boolean;
    procedure cambioValorMantenimientos(listado: TStringGrid; fila, columna: integer);

    procedure editarMonitor(fila: integer; clonar: boolean);
    procedure eliminarMonitor(fila: integer);
    procedure altaMonitor;
    procedure actualizarTablaMonitores;
    procedure crearMonitorSimResPorDefecto;

    procedure Free;
    procedure ShowHelp(msg: string);

    function fechaIniToString(fecha: TFecha): string;
    function fechaFinToString(fecha: TFecha): string;
    function StringToFecha(const fecha: string): TFecha;

    function darListaParaClase(actor: TCosaConNombre;
      iSala: TSalaDeJuego): TListaDeCosasConNombre;
    function hacerPathRelativoASala(const path: string): string;


    procedure wrln(s: string);
  end;

procedure msgAdvertenciaCargandoDeArchivo(msg: string);
procedure msgErrorCargandoDeArchivo(msg: string);

var
  FSimSEEEdit: TFSimSEEEdit;

implementation

{$R *.lfm}

function TFSimSEEEdit.altaActorClaseBase(claseBase: TClass): TActor;
var
  nombreTipo: string;
  infoClase: TInfoCosaConNombre;
  formularioEdicion: TBaseEditoresCosasConNombre;
  nuevoActor: TActor;
begin
  nuevoActor := nil;
  nombreTipo := selectTipo(self, infoTabs_.nombresSubClases(claseBase));
  if nombreTipo <> '' then
  begin
    infoClase := infoTabs_.getInfoActor(nombreTipo);
    if infoClase <> nil then
    begin
      formularioEdicion := infoClase.ClaseEditor.Create(self, sala,
        infoClase.clase, nil);
      if formularioEdicion.ShowModal = mrOk then
      begin
        nuevoActor := TActor(formularioEdicion.darResultado);
        self.agregarActor(nuevoActor);
        actualizarTablaActores;
        utilidades.sgBuscarYSeleccionarFila(sgActores, 0, nuevoActor.nombre);
      end;
      formularioEdicion.Free;
    end
    else
      raise Exception.Create(exFormularioEdicionParaClase + nombreTipo);
  end;
  Result := nuevoActor;
end;

function TFSimSEEEdit.altaActor(const nombreTab: string): TActor;
var
  nombreTipo: string;
  infoClase: TInfoCosaConNombre;
  formularioEdicion: TBaseEditoresCosasConNombre;
  nuevoActor: TActor;
begin
  nuevoActor := nil;
  nombreTipo := selectTipo(self, infoTabs_.nombresTiposTab(nombreTab));
  if nombreTipo <> '' then
  begin
    infoClase := infoTabs_.getInfoActor(nombreTab, nombreTipo);
    if infoClase <> nil then
    begin
      formularioEdicion := infoClase.ClaseEditor.Create(self, self.sala,
        infoClase.clase, nil);
      if formularioEdicion.ShowModal = mrOk then
      begin
        nuevoActor := TActor(formularioEdicion.darResultado);
        self.agregarActor(nuevoActor);
        actualizarTablaActores;
        utilidades.sgBuscarYSeleccionarFila(sgActores, 0, nuevoActor.nombre);
      end;
      formularioEdicion.Free;
    end
    else
      raise Exception.Create(exFormularioEdicionParaClase + nombreTipo);
  end;
  Result := nuevoActor;
end;

function TFSimSEEEdit.editarActor(actor: TActor): TActor;
var
  infoClase: TInfoCosaConNombre;
  formularioEdicion: TBaseEditoresCosasConNombre;
  res: TActor;
  fmemo: TEditorMEMO;
  amemo: TStrings;
  Catalogo: TCatalogoReferencias;

begin
  res := nil;
  infoClase := infoTabs_.getInfoActor(actor.ClassType);
  if infoClase <> nil then
  begin
    formularioEdicion := infoClase.ClaseEditor.Create(self, sala,
      actor.ClassType, actor);
    if formularioEdicion.ShowModal = mrOk then
    begin
      res := actor;
      guardado := False;
      actualizarTablaActores;
      utilidades.sgBuscarYSeleccionarFila(sgActores, 0, actor.nombre);
    end;
    formularioEdicion.Free;
    Result := res;
  end
  else
  begin
    amemo := Actor.asMemo(0);
    fmemo := TEditorMemo.Create(self, amemo);
    if fmemo.ShowModal = mrOk then
    begin
      amemo := fmemo.memo.Lines;
      Catalogo := TCatalogoReferencias.Create;
      res := TActor.Create_FromMemo(Catalogo, 0, amemo) as TActor;
      Catalogo.Free;
      guardado := False;
      actualizarTablaActores;
      utilidades.sgBuscarYSeleccionarFila(sgActores, 0, actor.nombre);
    end;
    fmemo.Free;
    Result := res;
    //    raise Exception.Create(exFormularioEdicionParaClase + actor.ClaseNombre);
  end;
end;

function TFSimSEEEdit.clonarActor(actorOrig: TActor): TActor;
var
  infoClase: TInfoCosaConNombre;
  formularioEdicion: TBaseEditoresCosasConNombre;
  nuevoActor: TActor;
begin
  infoClase := infoTabs_.getInfoActor(actorOrig.ClassType);
  if infoClase <> nil then
  begin
    nuevoActor := rbtEditorSala.Clonar_Y_ResolverReferencias(actorOrig) as TActor;

    formularioEdicion := infoClase.ClaseEditor.Create(self, sala,
      nuevoActor.ClassType, nuevoActor);
    if formularioEdicion.ShowModal = mrOk then
    begin
      agregarActor(nuevoActor);
      actualizarTablaActores;
      utilidades.sgBuscarYSeleccionarFila(sgActores, 0, nuevoActor.nombre);
    end
    else
    begin
      nuevoActor.Free;
      nuevoActor := nil;
    end;
    formularioEdicion.Free;
    Result := nuevoActor;
  end
  else
    raise Exception.Create(exFormularioEdicionParaClase + actorOrig.ClaseNombre);
end;

function TFSimSEEEdit.eliminarActor(actor: TActor): boolean;
var
  texto: string;
  res: boolean;
begin
  if not (actor is TNodo) then
  begin
    // Chequeo que nadie lo referencie
    if rbtEditorSala.existeReferenciaALaCosaConNombre(actor) then
    begin
      ShowMessage(mesNoSePuedeEliminarActor + actor.DescClase + ' ' +
        actor.nombre + mesExisteReferenciaAEl +
        mesElimineLasReferenciasVuelvaIntentarlo);
      res := False;
    end
    else
    begin
      texto := mesConfirmaEliminarActor + actor.DescClase + ' "' +
        actor.nombre + '"?';
      if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
        MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
      begin
        darListaParaClase(actor, Sala).Remove(actor);
        rbtEditorSala.eliminarActor(actor);
        guardado := False;
        actualizarTablaActores;
        res := True;
      end
      else
        res := False;
    end;
  end
  else
    res := eliminarNodo(TNodo(actor));
  Result := res;
end;

function TFSimSEEEdit.eliminarNodo(nodo: TNodo): boolean;
var
  texto: string;
  lista: TList;
  i: integer;
  res: boolean;
begin
  Lista := TList.Create();

  // Agrego generadores
  for i := 0 to Sala.Gens.Count - 1 do
  begin
    if (Sala.Gens[i] is TActorNodal) and (Sala.Gens[i] as
      TActorNodal).referenciaAlNodo(nodo) then
      lista.Add(Sala.Gens[i]);
  end;

  // Agrego demandas
  for i := 0 to Sala.Dems.Count - 1 do
  begin
    if (Sala.Dems[i] is TActorNodal) and (Sala.Dems[i] as
      TActorNodal).referenciaAlNodo(nodo) then
      lista.Add(Sala.Dems[i]);
  end;

  // Agrego arcos
  for i := 0 to Sala.Arcs.Count - 1 do
  begin
    if (Sala.Arcs[i] is TActorNodal) and (Sala.Arcs[i] as
      TActorNodal).referenciaAlNodo(nodo) then
      lista.Add(Sala.Arcs[i]);
  end;

  // Agrego comercio internacional
  for i := 0 to sala.ComercioInternacional.Count - 1 do
  begin
    if (Sala.ComercioInternacional[i] is TActorNodal) and
      (Sala.ComercioInternacional[i] as TActorNodal).referenciaAlNodo(nodo) then
      lista.Add(Sala.ComercioInternacional[i]);
  end;

  if lista.Count > 0 then
  begin
    texto :=
      mesEliminaNodoActoresReferenciasVacias + #13#10;
    for i := 0 to lista.Count - 1 do
      texto := texto + TActor(lista[i]).nombre + #13#10;
    texto := texto + mesElimineLasReferenciasVuelvaIntentarlo;
    ShowMessage(texto);
    res := False;
  end
  else
  begin
    texto := texto + mesConfirmaEliminarNodo + nodo.nombre + '"?';
    if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
      MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
    begin
      darListaParaClase(nodo, Sala).Remove(nodo);
      rbtEditorSala.eliminarActor(TActor(nodo));
      guardado := False;
      actualizarTablaActores;
      res := True;
    end
    else
      res := False;
  end;
  lista.Free;
  Result := res;
end;

function TFSimSEEEdit.altaActorCast(const nombreTab: string): TCosaConNombre;
begin
  Result := altaActor(nombreTab);
end;

function TFSimSEEEdit.clonarActorCast(actorOrig: TCosaConNombre): TCosaConNombre;
begin
  Result := clonarActor(TActor(actorOrig));
end;

function TFSimSEEEdit.eliminarActorCast(actor: TCosaConNombre): boolean;
begin
  Result := eliminarActor(TActor(actor));
end;

procedure TFSimSEEEdit.eMaxNItersOptExit(Sender: TObject);
begin
  if validarEditInt(eMaxNItersOpt, 0, MaxInt) then
    sala.globs.NMAX_ITERACIONESDELPASO_OPT := StrToInt(eMaxNItersOpt.Text);
end;

procedure TFSimSEEEdit.eMaxNItersSimExit(Sender: TObject);
begin
  if validarEditInt(eMaxNItersSim, 0, MaxInt) then
    sala.globs.NMAX_ITERACIONESDELPASO_SIM := StrToInt(eMaxNItersSim.Text);
end;

function TFSimSEEEdit.agregarActor(actor: TActor): boolean;
var
  actoresTab: TListaDeCosasConNombre;
  resultado: boolean;
begin
  if self.Sala = nil then
    raise Exception.Create('TFSimSEEEdit.agregarActor. Aun no se ha creado una sala!')
  else
  begin
    resultado := rbtEditorSala.addCosaConNombre(actor);
    if resultado then
    begin
      actoresTab := darListaParaClase(actor, self.Sala);
      if actoresTab <> nil then
        actoresTab.Add(actor);
      rbtEditorSala.resolverReferenciasContraSala(False);
      Sala.Prepararse_(rbtEditorSala.CatalogoReferencias);
      sala.publicarTodasLasVariables;
      guardado := False;
    end;
    Result := resultado;
  end;
end;

procedure TFSimSEEEdit.importar;
var
  cosaParticipeDeMercado: TCosaParticipeDeMercado;
  arch: TArchiTexto;
  k: integer;
  nomOrig: string;
  iBusquedaNombre: integer;
begin
  arch := nil;
  try
    k := rbtEditorSala.CatalogoReferencias.referenciasSinResolver;
    assert(k = 0, 'TFSimSEEEdit.importar: cantReferenciasSinResolver <> 0');

    arch := TArchiTexto.CreateForRead(0, rbtEditorSala.CatalogoReferencias,
      DImportarActor.FileName, True);
    arch.rd(':', TCosa(cosaParticipeDeMercado));
    if rbtEditorSala.buscarCosaConNombre(cosaParticipeDeMercado.nombre) <> nil then
    begin
      nomOrig := cosaParticipeDeMercado.nombre;
      iBusquedaNombre := 2;
      cosaParticipeDeMercado.nombre := nomOrig + '(' + IntToStr(iBusquedaNombre) + ')';
      while rbtEditorSala.buscarCosaConNombre(cosaParticipeDeMercado.nombre) <> nil do
      begin
        iBusquedaNombre := iBusquedaNombre + 1;
        cosaParticipeDeMercado.nombre := nomOrig + '(' + IntToStr(iBusquedaNombre) + ')';
      end;
      rbtEditorSala.CatalogoReferencias.
        cambiar_NombreDelReferidoEnReferenciasPosterioresAK(k, nomOrig,
        cosaParticipeDeMercado.nombre, cosaParticipeDeMercado.ClassName);
    end;

    if cosaParticipeDeMercado is TActor then
    begin
      if rbtEditorSala.resolverReferenciasContraSala(True) > 0 then
      begin
        ShowMessage(mesElActor + cosaParticipeDeMercado.ClaseNombre +
          mesReferenciasSinResolverResuelvalas);
        cosaParticipeDeMercado := editarActor(TActor(cosaParticipeDeMercado));
        rbtEditorSala.CatalogoReferencias.LimpiarReferencias;
        // uCosaConNombre.eliminar_referencias_del(actor);
      end;
      if cosaParticipeDeMercado <> nil then
      begin
        agregarActor(TActor(cosaParticipeDeMercado));
        actualizarTablaActores;
        //        manejadorListadoEditores.notificarGuardarDatos;
      end;
    end
    else if cosaParticipeDeMercado is TFuenteAleatoria then
    begin
      if rbtEditorSala.resolverReferenciasContraSala(True) > 0 then
      begin
        ShowMessage(mesLaFuenteAleatoria + cosaParticipeDeMercado.ClaseNombre +
          mesReferenciasSinResolverResuelvalas);
        cosaParticipeDeMercado := editarFuente(TFuenteAleatoria(cosaParticipeDeMercado));
        rbtEditorSala.CatalogoReferencias.LimpiarReferencias;
        // uCosaConNombre.eliminar_referencias_del(actor);
      end;
      if cosaParticipeDeMercado <> nil then
      begin
        sala.listaFuentes_.Add(cosaParticipeDeMercado);
        actualizarTablaFuentes;
      end;
    end
    else
      raise Exception.Create('TFSimSEEEdit.importar: importar cosas de clase ' +
        cosaParticipeDeMercado.ClassName + ' no implementado');
  except
    on E: EInOutError do
    begin
      ShowMessage(mesErrorImportandoActor + #13 + E.Message +
        '.' + #13 + mesArchivoAbiertoONoExiste);
      rbtEditorSala.CatalogoReferencias.LimpiarReferencias;
    end;
    on E: Exception do
    begin
      ShowMessage(mesErrorImportandoActor + #13 + E.Message + '.');
      rbtEditorSala.CatalogoReferencias.LimpiarReferencias;
    end;
  end;
  if arch <> nil then
    arch.Free;
end;



procedure TFSimSEEEdit.actualizarTablaActores;
var
  i: integer;
  actor: TActor;

  ListaDeActores: TListaDeCosasConNombre;

  TipoActor: string;
begin
  BGenerarResumenTermico.Visible := False;
  TipoActor := TCActores_.Tabs[TCActores_.tabindex];

  if TipoActor = '?' then
  begin
    PActores.Visible := False;
    verdoc(self, 'editor-actores', 'Actores');
    TCActores_.TabIndex := 0;
    actualizarTablaActores();
    exit;
  end;

  PActores.Visible := True;
  if TipoActor = strTabGeneradoresTermicos then
  begin
    BGenerarResumenTermico.Visible := True;
    ListadeActores := Sala.Gens;
    hid_ActoresListaEspecifica := '(Actores) Térmicas';
    BGenerarResumenTermico.Visible := sala.Gens.Count > 0;
  end
  else if TipoActor = strTabDemandas then
  begin
    ListadeActores := Sala.Dems;
    hid_ActoresListaEspecifica := '(Actores) Demandas';
  end
  else if TipoActor = strTabRed then
  begin
    ListadeActores := Sala.Nods;
    hid_ActoresListaEspecifica := '(Actores) Red';
  end
  else if TipoActor = strTabGeneradoresHidraulicos then
  begin
    ListadeActores := Sala.Gens;
    hid_ActoresListaEspecifica := '(Actores) Hidráulicas';
  end
  else if TipoActor = strTabEolica_ then
  begin
    ListadeActores := Sala.Gens;
    hid_ActoresListaEspecifica := '(Actores) Eólica';
  end
  else if TipoActor = strTabSolar then
  begin
    ListadeActores := Sala.Gens;
    hid_ActoresListaEspecifica := '(Actores) Solar';
  end
  else if TipoActor = strTabComercioInternacionalYOtros then
  begin
    ListadeActores := sala.ComercioInternacional;
    hid_ActoresListaEspecifica := '(Actores) Internacional';
  end
  else if TipoActor = strTabCombustibles then
  begin
    ListadeActores := sala.listaCombustibles;
    hid_ActoresListaEspecifica := 'Combustibles';
  end
  else if TipoActor = strTabSumCombustibles then
  begin
    ListadeActores := sala.Sums;
    hid_ActoresListaEspecifica := 'Red de combustibles';
  end
  else if TipoActor = strTabUsosGestionables then
  begin
    ListadeActores := Sala.UsosGestionables;
    hid_ActoresListaEspecifica := '(Actores) Usos Gestionables';
  end
  else if TipoActor = strTabSinEditorRegistrado then
  begin
    ListadeActores := nil;
    hid_ActoresListaEspecifica := '(Actores) Sin Editor Registrado';
  end
  else
    raise Exception.Create('TFSimSEEEdit.actualizarTablaActores: Tipo no registrado' +
      TipoActor + '.');

  if ListaDeActores <> nil then
    ListadeActores.Sort(uCosaConNombre.ordenString);

  ListasDeActoresTabs[TCActores_.TabIndex].Sort(uCosaConNombre.ordenString);

  sgActores.RowCount := ListasDeActoresTabs[TCActores_.TabIndex].Count + 1;
  if sgActores.RowCount > 1 then
    sgActores.FixedRows := 1
  else
    sgLimpiarSeleccion(sgActores);

  for i := 0 to ListasDeActoresTabs[TCActores_.TabIndex].Count - 1 do
  begin
    actor := TActor(ListasDeActoresTabs[TCActores_.TabIndex][i]);
    sgActores.Cells[0, i + 1] := actor.nombre;
    sgActores.Cells[1, i + 1] := actor.DescClase;
    sgActores.Cells[2, i + 1] := actor.infoAd_20;
    (*
    sgActores.Cells[3, i + 1] := fechaIniToString(actor.nacimiento);
    sgActores.Cells[4, i + 1] := fechaFinToString(actor.muerte);
    *)
  end;

  utilidades.AutoSizeTypedColsAndTable(sgActores, TiposColActores, iconos,
    maxAnchoTablaEnorme, maxAlturaTablaGrande,
    TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
  sgActores.Visible := True;
end;

function TFSimSEEEdit.altaFuente: TFuenteAleatoria;
var
  form: TBaseEditoresCosasConNombre;
  tipoStr: string;
  TipoFuente: TClaseDeFuenteAleatoria;
  tipoEditorFuente: TClaseEditoresCosasConNombre;
  res: TFuenteAleatoria;
begin
  tipoStr := selectTipo(self, uInfoCosa.InfoFuentes.descsClase);
  if tipoStr <> '' then
  begin
    TipoFuente := TClaseDeFuenteAleatoria(uInfoCosa.InfoFuentes.tipoDeCosa(tipoStr));
    tipoEditorFuente := TClaseEditoresCosasConNombre(
      uInfoCosa.InfoFuentes.getTipoEditor(TipoFuente));

    // Muestro el editor de la fuente seleccionada
    form := tipoEditorFuente.Create(self, sala, TipoFuente, nil);
    if form.ShowModal = mrOk then
    begin
      res := form.darResultado as TFuenteAleatoria;
      Sala.listaFuentes_.Add(res);
      actualizarTablaFuentes;
      guardado := False;
      sgBuscarYSeleccionarFila(sgFuentes, 0, res.nombre);
      sala.Prepararse_(rbtEditorSala.CatalogoReferencias);
      sala.publicarTodasLasVariables;
    end
    else
      res := nil;
    form.Free;
  end
  else
    res := nil;
  Result := res;
end;


function TFSimSEEEdit.editarFuente(fuente: TFuenteAleatoria): TFuenteAleatoria;
var
  form: TBaseEditoresCosasConNombre;
  TipoEditor: TClaseEditoresCosasConNombre;
  res: TFuenteAleatoria;
begin
  TipoEditor := TClaseEditoresCosasConNombre(
    uInfoCosa.InfoFuentes.getTipoEditor(fuente.ClassType));
  if TipoEditor <> nil then
  begin
    form := TipoEditor.Create(self, Sala, fuente.ClassType, fuente);
    if form.ShowModal = mrOk then
    begin
      res := form.darResultado as TFuenteAleatoria;
      guardado := False;
      actualizarTablaFuentes;
      utilidades.sgBuscarYSeleccionarFila(sgFuentes, 0, res.nombre);
    end
    else
      res := nil;
    form.Free;
  end
  else
  begin
    raise Exception.Create(exEditorNoRegistradoClase + fuente.ClassName);
  end;
  Result := res;
end;

function TFSimSEEEdit.clonarFuente(fuenteOrig: TFuenteAleatoria): TFuenteAleatoria;
var
  TipoEditor: TClaseEditoresCosasConNombre;
  formularioEdicion: TBaseEditoresCosasConNombre;
  nuevaFuente: TFuenteAleatoria;
begin
  TipoEditor := TClaseEditoresCosasConNombre(
    uInfoCosa.InfoFuentes.getTipoEditor(fuenteOrig.ClassType));
  if TipoEditor <> nil then
  begin
    nuevaFuente := rbtEditorSala.Clonar_Y_ResolverReferencias(fuenteOrig) as
      TFuenteAleatoria;

    formularioEdicion := TipoEditor.Create(self, Sala, nuevaFuente.ClassType,
      nuevaFuente);
    if formularioEdicion.ShowModal = mrOk then
    begin
      sala.listaFuentes_.Add(nuevaFuente);
      actualizarTablaFuentes;
      utilidades.sgBuscarYSeleccionarFila(sgFuentes, 0, nuevaFuente.nombre);
    end
    else
    begin
      nuevaFuente.Free;
      nuevaFuente := nil;
    end;
    formularioEdicion.Free;
    Result := nuevaFuente;
  end
  else
  begin
    raise Exception.Create(exEditorNoRegistradoClase + fuenteOrig.ClassName);
  end;
end;

function TFSimSEEEdit.eliminarFuente(fuente: TFuenteAleatoria): boolean;
var
  res: boolean;
  texto: string;
begin
  if rbtEditorSala.existeReferenciaALaCosaConNombre(fuente) then
  begin
    ShowMessage(mesNoSePuedeEliminarFuenteReferencia +
      mesElimineLasReferenciasVuelvaIntentarlo);
    res := False;
  end
  else
  begin
    texto := mesConfirmaDeseaEliminarFuentes + fuente.nombre + '"?';
    if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
      MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
    begin
      Sala.listaFuentes_.remove(fuente);
      fuente.Free;
      actualizarTablaFuentes;
      guardado := False;
      res := True;
    end
    else
      res := False;
  end;
  Result := res;
end;

procedure TFSimSEEEdit.actualizarTablaFuentes;
var
  i: integer;
  aux: TFuenteAleatoria;

begin
  sgFuentes.RowCount := Sala.listaFuentes_.Count + 1;
  if sgFuentes.RowCount > 1 then
    sgFuentes.FixedRows := 1
  else
    sgLimpiarSeleccion(sgFuentes);

  for i := 0 to Sala.listaFuentes_.Count - 1 do
  begin
    aux := TFuenteAleatoria(Sala.listaFuentes_[i]);
    sgFuentes.Cells[0, i + 1] := aux.nombre;
    sgFuentes.Cells[1, i + 1] := aux.DescClase;
    sgFuentes.Cells[2, i + 1] := aux.InfoAd_20;
  end;


  for i := 0 to sgFuentes.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgFuentes, i, TiposColFuentes[i], iconos);
  sgFuentes.Visible := True;

end;



function TFSimSEEEdit.altaCombustible: TCombustible;
var
  form: TBaseEditoresCosasConNombre;
  tipoStr: string;
  TipoCombustible: TClaseDeCombustible;
  tipoEditorCombustible: TClaseEditoresCosasConNombre;
  res: TCombustible;
begin
  tipoStr := selectTipo(self, uInfoCosa.InfoCombustibles.descsClase);

  if tipoStr <> '' then
  begin
    TipoCombustible := TClaseDeCombustible(
      uInfoCosa.InfoCombustibles.tipoDeCosa(tipoStr));
    tipoEditorCombustible := TClaseEditoresCosasConNombre(
      uInfoCosa.InfoCombustibles.getTipoEditor(TipoCombustible));

    // Muestro el editor del combustible seleccionado
    form := tipoEditorCombustible.Create(self, sala, TipoCombustible, nil);
    if form.ShowModal = mrOk then
    begin
      res := form.darResultado as TCombustible;
      Sala.listaCombustibles.Add(res);
      actualizarTablaCombustibles;
      guardado := False;
      sgBuscarYSeleccionarFila(sgCombustible, 0, res.nombre);
      sala.Prepararse_(rbtEditorSala.CatalogoReferencias);
      sala.publicarTodasLasVariables;
    end
    else
      res := nil;
    form.Free;
  end
  else
    res := nil;
  Result := res;
end;

function TFSimSEEEdit.editarCombustible(combustible: TCombustible): TCombustible;
var
  form: TBaseEditoresCosasConNombre;
  TipoEditor: TClaseEditoresCosasConNombre;
  res: TCombustible;
begin
  TipoEditor := TClaseEditoresCosasConNombre(
    uInfoCosa.InfoCombustibles.getTipoEditor(combustible.ClassType));
  if TipoEditor <> nil then
  begin
    form := TipoEditor.Create(self, Sala, combustible.ClassType, combustible);
    if form.ShowModal = mrOk then
    begin
      res := form.darResultado as TCombustible;
      guardado := False;
      actualizarTablaCombustibles;
      utilidades.sgBuscarYSeleccionarFila(sgCombustible, 0, res.nombre);
    end
    else
      res := nil;
    form.Free;
  end
  else
  begin
    raise Exception.Create(exEditorNoRegistradoClase + combustible.ClassName);
  end;
  Result := res;
end;

function TFSimSEEEdit.clonarCombustible(combustibleOrig: TCombustible): TCombustible;
var
  TipoEditor: TClaseEditoresCosasConNombre;
  formularioEdicion: TBaseEditoresCosasConNombre;
  nuevoCombustible: TCombustible;
begin
  TipoEditor := TClaseEditoresCosasConNombre(
    uInfoCosa.InfoCombustibles.getTipoEditor(combustibleOrig.ClassType));
  if TipoEditor <> nil then
  begin
    nuevoCombustible := rbtEditorSala.Clonar_Y_ResolverReferencias(combustibleOrig) as
      TCombustible;

    formularioEdicion := TipoEditor.Create(self, Sala, nuevoCombustible.ClassType,
      nuevoCombustible);
    if formularioEdicion.ShowModal = mrOk then
    begin
      sala.listaCombustibles.Add(nuevoCombustible);
      actualizarTablaCombustibles;
      sgBuscarYSeleccionarFila(sgCombustible, 0, nuevoCombustible.nombre);
    end
    else
    begin
      nuevoCombustible.Free;
      nuevoCombustible := nil;
    end;
    formularioEdicion.Free;
    Result := nuevoCombustible;
  end
  else
  begin
    raise Exception.Create(exEditorNoRegistradoClase + combustibleOrig.ClassName);
  end;
end;

function TFSimSEEEdit.eliminarCombustible(combustible: TCombustible): boolean;
var
  res: boolean;
  texto: string;
begin
  if rbtEditorSala.existeReferenciaALaCosaConNombre(combustible) then
  begin
    ShowMessage(mesNoSePuedeEliminarCombustibleReferencia +
      mesElimineLasReferenciasVuelvaIntentarlo);
    res := False;
  end
  else
  begin
    texto := mesConfirmaDeseaEliminarCombustible + combustible.nombre + '"?';
    if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
      MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
    begin
      Sala.listaCombustibles.remove(combustible);
      combustible.Free;
      actualizarTablaCombustibles;
      guardado := False;
      res := True;
    end
    else
      res := False;
  end;
  Result := res;
end;

procedure TFSimSEEEdit.actualizarTablaCombustibles;
var
  i: integer;
  aux: TCombustible;
begin
  sgCombustible.RowCount := Sala.listaCombustibles.Count + 1;
  if sgCombustible.RowCount > 1 then
    sgCombustible.FixedRows := 1
  else
    sgLimpiarSeleccion(sgCombustible);

  for i := 0 to Sala.listaCombustibles.Count - 1 do
  begin
    aux := TCombustible(Sala.listaCombustibles[i]);
    sgCombustible.Cells[0, i + 1] := aux.nombre;
    sgCombustible.Cells[1, i + 1] := aux.DescClase;
    sgCombustible.Cells[2, i + 1] := aux.InfoAd_20;
  end;

  for i := 0 to sgCombustible.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgCombustible, i, TiposColCombustibles[i], iconos);
end;

procedure TFSimSEEEdit.Free;
var
  i: integer;
begin
  Sala.Free;
  SetLength(TiposColActores, 0);
  SetLength(TiposColMonitores, 0);
  for i := 0 to high(ListasDeActoresTabs) do
    ListasDeActoresTabs[i].Free;
  SetLength(ListasDeActoresTabs, 0);

  listaMantenimientos.Free;
  inherited Free;
end;

procedure TFSimSEEEdit.ShowHelp(msg: string);
begin
  ShowMessage(msg);
end;

function TFSimSEEEdit.fechaIniToString(fecha: TFecha): string;
begin
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
  begin
    if fecha.dt = 0 then
      Result := 'Auto'
    else
      Result := fecha.AsStr;
  end
  else if fecha.dt = 0 then
  begin
    Result := '1/1/1900';
    { if sala.globs.fechaIniSim.EsMayorQue(sala.globs.fechaIniOpt) <= 0 then
      result:= sala.globs.fechaIniSim.AsStr
      else
      result:= sala.globs.fechaIniOpt.AsStr; }
  end
  else
    Result := fecha.AsStr;
end;

function TFSimSEEEdit.fechaFinToString(fecha: TFecha): string;
begin
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
  begin
    if fecha.dt = 0 then
      Result := 'Auto'
    else
      Result := fecha.AsStr;
  end
  else if fecha.dt = 0 then
    Result := '9/9/9999'
    { if sala.globs.fechaFinSim.EsMayorQue(sala.globs.fechaFinOpt) >= 0 then
      result:= sala.globs.fechaFinSim.AsStr
      else
      result:= sala.globs.fechaFinOpt.AsStr }
  else
    Result := fecha.AsStr;
end;

function TFSimSEEEdit.StringToFecha(const fecha: string): TFecha;
var
  res: TFecha;
begin
  if (fecha = 'Auto') or (fecha = '0') then
    res := TFecha.Create_Dt(0)
  else
    res := TFecha.Create_Str(fecha);
  Result := res;
end;

function TFSimSEEEdit.darListaParaClase(actor: TCosaConNombre;
  iSala: TSalaDeJuego): TListaDeCosasConNombre;
var
  i: integer;
  resultado: TListaDeCosasConNombre;
begin
  resultado := nil;
  if Sala = nil then
    raise Exception.Create('TFSimSEEEdit.darListaParaClase: sala = NIL');


  if actor is TFuenteAleatoria then
    resultado := nil
  else
  begin
    i := infoTabs_.indiceTabDeTipo_(Actor.ClassType);
    if i >= 0 then
      resultado := ListasDeActoresTabs[i]
    else
      raise Exception.Create(exTipoActorDesconocido + actor.DescClase);
  end;
  Result := resultado;
  exit;

end;

procedure TFSimSEEEdit.ddd1Click(Sender: TObject);
begin
  verdoc(self, 'versiones', 'versiones');
end;

procedure TFSimSEEEdit.tsCapasContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TFSimSEEEdit.ts_GlobalesEnter(Sender: TObject);
begin

end;

procedure TFSimSEEEdit.ts_GlobalesShow(Sender: TObject);
begin
  writeln('ts_GlobalesShow');
  LoadFormulario_SALAyGLOBS;
end;



procedure TFSimSEEEdit.TV_SimseeClick(Sender: TObject);
var
  nombre, nomb_FATHER: string;
  ID_padre: integer;
  pal, r: string;
  k: integer;
  a: TGenerador;
  b: TComercioInternacional;
  c: TDemanda;
  d: TNodo;
  jBarra, jCodigo: integer;
  Tipo_Gen, Nom_Gen: string;
  Flucar1: TFlucar;
  aDemFlucar: TRaw_Load;
  aGenFlucar: TRaw_Generator;
  i, j: integer;

begin

  //Flucar1.CreateFromArchi(getCurrentDrive+EArchivo_Flucar.Text);
  //Flucar.cargar_caso;
  if TV_Simsee.Selected.Level < 2 then
  begin
    LV_Simsee_Flucar.Clear;
  end
  else
  begin
    LV_Simsee_Flucar.Clear;
    nombre := TV_Simsee.Selected.Text;
    r := nombre;
    nomb_FATHER := TV_Simsee.Selected.GetParentNodeOfAbsoluteLevel(1).Text;
    if nomb_FATHER = 'GENERADORES' then
      ID_padre := 1;
    if nomb_FATHER = 'COMERCIO INTERNACIONAL' then
      ID_padre := 2;
    if nomb_FATHER = 'DEMANDAS' then
      ID_padre := 3;
    if nomb_FATHER = 'NODOS' then
      ID_padre := 4;



    case ID_padre of

      1:
      begin
        getPalHastaSep(pal, r, '->');
        Tipo_Gen := pal;
        Nom_Gen := r;
        a := sala.BuscarPorNombre(r, sala.listaActores) as TGenerador;
        if a = nil then
          raise Exception.Create('No encontré el actor: ' + pal);
        j := 0;
        //for i:=0 to Flucar1.sala.Generadores.Count-1 do
        //begin
        //   aGenFlucar:=Flucar1.sala.Generadores[i];
        //   if TRaw_Bus(aGenFlucar.Barra_I.jcol).ZONE=a.Nodo.ZonaFlucar then
        //   begin
        //     LV_Flucar.Items.Add;
        //     LV_Flucar.Items[j].Caption:=TRaw_Bus(aGenFlucar.Barra_I.jcol).nombre;
        //     LV_Flucar.Items[j].SubItems.add(IntToStr(TRaw_Bus(aGenFlucar.Barra_I.jcol).ZONE));
        //     LV_Flucar.Items[j].SubItems.add(IntToStr(aGenFlucar.I));
        //     LV_Flucar.Items[j].SubItems.add(aGenFlucar.ID);
        //     j:=j+1
        //   end;

        //end;
        //aGenFlucar:=Flucar.sala.Find_Generador(barra_Hijo, codigo_Hijo) as TRaw_Generator;
        if a.barras_flucar <> nil then
          for jbarra := 0 to length(a.barras_flucar) - 1 do
          begin
            LV_Simsee_Flucar.Items.Add;
            LV_Simsee_Flucar.Items[jbarra].Caption := a.Nodo.nombre;
            LV_Simsee_Flucar.Items[jbarra].SubItems.add(
              IntToStr(a.Nodo.ZonaFlucar));
            LV_Simsee_Flucar.Items[jbarra].SubItems.add(
              IntToStr(a.barras_flucar[jbarra]));
            LV_Simsee_Flucar.Items[jbarra].SubItems.add(
              a.codigos_flucar[jbarra]);

          end;
      end;
      2:
      begin
        getPalHastaSep(pal, r, '->');
        b := sala.BuscarPorNombre(r, sala.listaActores) as TComercioInternacional;
        if a = nil then
          raise Exception.Create('No encontré el actor: ' + pal);
        if b.barras_flucar <> nil then
          for jbarra := 0 to length(b.barras_flucar) - 1 do
          begin
            LV_Simsee_Flucar.Items.Add;
            LV_Simsee_Flucar.Items[jbarra].Caption := b.Nodo.nombre;
            LV_Simsee_Flucar.Items[jbarra].SubItems.add(
              IntToStr(b.Nodo.ZonaFlucar));
            LV_Simsee_Flucar.Items[jbarra].SubItems.add(
              IntToStr(b.barras_flucar[jbarra]));
            LV_Simsee_Flucar.Items[jbarra].SubItems.add(
              b.codigos_flucar[jbarra]);

          end;
      end;
      3:
      begin
        getPalHastaSep(pal, r, '->');
        c := sala.BuscarPorNombre(r, sala.listaActores) as TDemanda;
        if a = nil then
          raise Exception.Create('No encontré el actor: ' + pal);
        if c.barras_flucar <> nil then
          for jbarra := 0 to length(c.barras_flucar) - 1 do
          begin
            LV_Simsee_Flucar.Items.Add;
            LV_Simsee_Flucar.Items[jbarra].Caption := c.Nodo.nombre;
            LV_Simsee_Flucar.Items[jbarra].SubItems.add(
              IntToStr(c.Nodo.ZonaFlucar));
            LV_Simsee_Flucar.Items[jbarra].SubItems.add(
              IntToStr(c.barras_flucar[jbarra]));
            LV_Simsee_Flucar.Items[jbarra].SubItems.add(
              c.codigos_flucar[jbarra]);

          end;
      end;
      4:
      begin
        getPalHastaSep(pal, r, '->');
        d := sala.BuscarPorNombre(r, sala.listaActores) as TNodo;
        if a = nil then
          raise Exception.Create('No encontré el actor: ' + pal);
        begin
          LV_Simsee_Flucar.Items.Add;
          LV_Simsee_Flucar.Items[0].Caption := d.nombre;
          LV_Simsee_Flucar.Items[0].SubItems.add(IntToStr(d.ZonaFlucar));

        end;
      end;

    end;

  end;
  //Flucar1.Free;
end;

procedure TFSimSEEEdit.ClearConsolaAlertas;
begin
  MemoWarnings.Lines.Clear;
end;

procedure TFSimSEEEdit.WritelnAlerta(const s: string);
begin
  MemoWarnings.Lines.Add(s);
  application.ProcessMessages;
end;




function TFSimSEEEdit.hacerPathRelativoASala(const path: string): string;
var
  res, pathSala: string;
  cntDirectoriosArriba, i: integer;
begin
  if DCargarSala.FileName <> '' then
    pathSala := ExtractFilePath(DCargarSala.FileName)
  else
    pathSala := getDir_Corridas;
  res := path;
  cntDirectoriosArriba := 0;
  while pos(res, pathSala) = 0 do
  begin
    subirDirectorio(res);
    Inc(cntDirectoriosArriba);
  end;
  res := copy(pathSala, Length(res), MAXINT);
  for i := 1 to cntDirectoriosArriba do
    res := DirectorySeparator + '..' + res;
  Result := res;
end;

procedure TFSimSEEEdit.wrln(s: string);
begin
  while mConsola.Lines.Count > 1000 do
    mConsola.Lines.Delete(0);
  mConsola.Lines.add(s);
end;

procedure TFSimSEEEdit.FormCreate(Sender: TObject);
var
  i: integer;
  tabs: TStringList;
  f: TArchiTexto;

begin
  LasCosas := TList.Create;
  WindowState := wsMaximized;

  ChDir(ExtractFilePath(ParamStr(0)));
  crearDirectorios;
  registrarClaseDeCosa(TSimSEEEditOptions.ClassName, TSimSEEEditOptions);

  self.Caption := AnsiToUtf8('Editor - SimSEE - v' + uversiones.vSimSEEEdit_ +
    ' (GPLv3, IIE-FING)');

  self.MemoWarnings.Lines.add('Editor - SimSEE - v' + uversiones.vSimSEEEdit_ +
    ' (GPLv3, IIE-FING)');

  DCargarSala.InitialDir := getDir_Corridas;
  DCargarSala.Filter := 'Archivos SimSEEEdit (*.ese)|*.ese|Todos los Archivos (*.*)|*.*';
  DSalvarSala.InitialDir := getDir_Corridas;
  DSalvarSala.DefaultExt := 'ese';
  DImportarActor.InitialDir := TSimSEEEditOptions.getInstance.libPath;
  DImportarActor.Filter :=
    'Archivos de Actor SimSEE (*.act)|*.act|Todos los Archivos (*.*)|*.*';
  ODCF.InitialDir := getDir_Run;
  ODCF.Filter :=
    'Archivos Binarios de Costos Futuros (*.bin)|*.bin|Todos los Archivos (*.*)|*.*';
  DCargarManejadorMonitores.InitialDir := getDir_Corridas;
  DCargarManejadorMonitores.Filter := 'Archivos de Monitores SimSEE (*.mon)|*.mon';
  DSalvarManejadorMonitores.InitialDir := getDir_Corridas;
  DSalvarManejadorMonitores.Filter := 'Archivos de Monitores SimSEE (*.mon)|*.mon';
  DSalvarManejadorMonitores.DefaultExt := 'mon';

  registrarActores;
  registrarMonitores;
  registrarFuentes;

  registrarCombustibles;


  PCEditMain.ActivePage := PCEditMain.Pages[0];

  // sysutils.DecimalSeparator:= '.';

  ucosa.procMsgValorPorDefecto := SimSEEEditMain.msgAdvertenciaCargandoDeArchivo;
  ucosa.procMsgErrorLectura := SimSEEEditMain.msgErrorCargandoDeArchivo;
  ucosa.procMsgAdvertenciaLectura := SimSEEEditMain.msgAdvertenciaCargandoDeArchivo;
  self.Top := topDef;
  self.Left := leftDef;

  MemoDesc.Lines.Delimiter := separadorDeLineas;
  sala := nil;
  loQueHabia := '';
  guardado := True;
  guardadoMonitores := True;

  lblFormatoFecha.Caption := '(' + DateTimeToStr(now()) + ')';

  sgPostes.Cells[0, 0] := rsPosteN;
  for i := 1 to StrToInt(IntNPostes.Text) do
    sgPostes.Cells[i, 0] := IntToStr(i);

  sgPostes.Cells[0, 1] := rsDuracioN;

  // Listado de Fuentes Aleatorias
  utilidades.initListado(sgFuentes, [rsFuente, rsTipoDeFuente,
    rsInformacioNAdicional, encabezadoBTEditar, encabezadoBTEliminar,
    encabezadoBTClonar], TiposColFuentes, True);

  // Listado de Combustibles
  utilidades.initListado(sgCombustible, [rsCombusitbles, rsTipoDeCombustible,
    rsInformacioNAdicional, encabezadoBTEditar, encabezadoBTEliminar,
    encabezadoBTClonar], TiposColCombustibles, True);

  // Listado de Actores
  utilidades.initListado(sgActores, [rsActor, rsTipoDeActor, rsInformacioNAdicional,
    //    rsFechaDeNacimiento, rsFechaDeMuerte,
    encabezadoBTEditar, encabezadoBTEliminar, encabezadoBTClonar],
    TiposColActores, True);

  // Listado de Mantenimientos
  utilidades.initListado(sgMantenimientos, [rsActor, rsTipoDeActor,
    encabezadoTextoEditable + rsFecha, encabezadoTextoEditable +
    rsUnidades_Instaladas, encabezadoTextoEditable + rsUnidades_EnMantenimiento,
    rsPeriodicaQ, encabezadoBTEditar, encabezadoBTEliminar, encabezadoBTClonar],
    TiposColMantenimientos, False);

  // Listado de Monitores
  monitoresEnabled := nil;

  utilidades.initListado(sgMonitores, [rsMonitor, rsTipo, encabezadoCheckBox,
    encabezadoBTEditar, encabezadoBTEliminar, encabezadoBTClonar],
    TiposColMonitores, True);

  tabs := uInfoTabs.infoTabs_.tabNames;

  Tabs.Add('?');
  TCActores_.Tabs := tabs;

  SetLength(ListasDeActoresTabs, Tabs.Count);
  for i := 0 to Tabs.Count - 1 do
    ListasDeActoresTabs[i] := TListaDeCosasConNombre.Create(0, TCActores_.Tabs[i]);

  listaMantenimientos := TListaMantenimientos.Create;


  rbtEditorSala := TRbtEditorSala.Create(nil);


  // Hasta definir bien como se crea el monitor por defecto. Hay un MenuItem en el
  // menu de monitores que permite crearlo
  BCrearMonitorSimRes3PDefecto.Visible := False;

  utilidades.setTabOrderByTopAndLeft(self);
  intentarCargarDeParametros;
  self.BorderStyle := bsSizeable;
  ts_Actores.TabVisible := True;

  ts_Combustible.TabVisible := True;


  if interpreteDeParametros.valStr('macro') =
    'recalibrarPronosticos#$guardar#$close' then
  begin
    sala.RecalibrarPronosticos;
    f := TArchiTexto.CreateForWrite(Utf8ToAnsi(DSalvarSala.FileName), False, 0);
    f.wr('sala', TSalaDeJuego(sala));
    f.Free;
    Close;
  end;

  lst_Escenarios := nil;
  lst_PlantillasSimRes3 := nil;

  WriteLn(TSimSEEEditOptions.getInstance.libPath);

  for i:= 0 to 2 do
   cgMascaraRun.Checked[i]:= true;
end;

procedure TFSimSEEEdit.BAyudaEngancharClick(Sender: TObject);
begin
  verdoc(self, 'editor-EngancheCFs', '');
end;

procedure TFSimSEEEdit.BDefinir_Enganches_SimSEE_FlucarClick(Sender: TObject);
var
  k: integer;
  a: TGenerador;
  b: TComercioInternacional;
  c: TDemanda;
  d: TNodo;
  jBarra, jCodigo: integer;
  sText: string;
  lcFatherNode: TTreeNode;
  lcChildNode: TTreeNode;

begin

  {If nothing is selected}
  if (TV_Simsee.Selected = nil) then
  begin
    {Does a root node already exist?}
    if (TV_Simsee.Items.Count = 0) then
    begin
      {Add the root node}
      lcFatherNode := TV_Simsee.Items.AddFirst(nil, 'SimSEE');
      begin
        lcFatherNode.Selected := True;

        {Set the roots image index}
        lcFatherNode.ImageIndex := IMG_NODE_ROOT;
           {Set the roots selected index. The same image is uses
              as for the ImageIndex}
        lcFatherNode.SelectedIndex := IMG_NODE_ROOT;
      end;
    end
    else
    begin
      {There is a root, so user must first select a node}
      //MessageBeep(  -1  );
      //ShowMessage(  'Select a parent node'  );
      Exit;
    end;
  end;

  {Get a name for the new node}
  //InputQuery(  'New Node',  'Caption ?',  sText  );



  sText := 'GENERADORES';
  {Add the node as a child of the selected node}
  with TV_Simsee.Items.AddChildFirst(lcFatherNode, sText) do
  begin
    {Set the image used when the node is not selected}
    ImageIndex := IMG_NODE_CLOSED;
    {Image used when the node is selected}
    SelectedIndex := IMG_NODE_OPEN;
    MakeVisible;
    Selected := True;
  end;

  for k := 0 to sala.Gens.Count - 1 do
  begin
    a := sala.Gens[k] as TGenerador;
    sText := a.ClassName + '->' + a.Apodo;
    TV_Simsee.Items.AddChild(TV_Simsee.Selected, sText);
  end;
  TV_Simsee.GetTopParent;
  TV_Simsee.GetTopParent;


  sText := 'COMERCIO INTERNACIONAL';
  {Add the node as a child of the selected node}
  with TV_Simsee.Items.AddChild(lcFatherNode, sText) do
  begin
    {Set the image used when the node is not selected}
    ImageIndex := IMG_NODE_CLOSED;
    {Image used when the node is selected}
    SelectedIndex := IMG_NODE_OPEN;
    MakeVisible;
    Selected := True;
  end;

  for k := 0 to sala.ComercioInternacional.Count - 1 do
  begin
    b := sala.ComercioInternacional[k] as TComercioInternacional;
    sText := b.ClassName + '->' + b.Apodo;
    TV_Simsee.Items.AddChild(TV_Simsee.Selected, sText);
  end;
  TV_Simsee.GetTopParent;
  TV_Simsee.GetTopParent;


  sText := 'DEMANDAS';
  {Add the node as a child of the selected node}
  with TV_Simsee.Items.AddChild(lcFatherNode, sText) do
  begin
    {Set the image used when the node is not selected}
    ImageIndex := IMG_NODE_CLOSED;
    {Image used when the node is selected}
    SelectedIndex := IMG_NODE_OPEN;
    MakeVisible;
    Selected := True;
  end;

  for k := 0 to sala.Dems.Count - 1 do
  begin
    c := sala.Dems[k] as TDemanda;
    sText := c.ClassName + '->' + c.Apodo;
    TV_Simsee.Items.AddChild(TV_Simsee.Selected, sText);
  end;
  TV_Simsee.GetTopParent;
  TV_Simsee.GetTopParent;


  sText := 'NODOS';
  {Add the node as a child of the selected node}
  with TV_Simsee.Items.AddChild(lcFatherNode, sText) do
  begin
    {Set the image used when the node is not selected}
    ImageIndex := IMG_NODE_CLOSED;
    {Image used when the node is selected}
    SelectedIndex := IMG_NODE_OPEN;
    MakeVisible;
    Selected := True;
  end;

  for k := 0 to sala.Nods.Count - 1 do
  begin
    d := sala.Nods[k] as TNodo;
    sText := d.ClassName + '->' + d.Apodo;
    TV_Simsee.Items.AddChild(TV_Simsee.Selected, sText);
  end;
  TV_Simsee.GetTopParent;
  TV_Simsee.GetTopParent;

end;

procedure TFSimSEEEdit.btAyudaCrearFrameEngancheClick(Sender: TObject);
begin
  verdoc(self, 'editor-CrearFrameDeEnganche', 'Crear frame de enganche');
end;

procedure TFSimSEEEdit.btAyuda_EmisionesCO2Click(Sender: TObject);
begin
  verdoc(self, 'editor-EmisionesCO2', '');
end;


procedure TFSimSEEEdit.btGuardarMantenimientosClick(Sender: TObject);
var
  nuevaListaMantenimientos: TListaMantenimientos;
  i: integer;
begin
  nuevaListaMantenimientos := TListaMantenimientos.Create;

  nuevaListaMantenimientos.Init(sala.Gens);
  for i := 0 to sala.ComercioInternacional.Count - 1 do
    if not (sala.ComercioInternacional[i] is TContratoModalidadDevolucion) then
      nuevaListaMantenimientos.addActor(
        sala.ComercioInternacional[i] as TComercioInternacional);

  nuevaListaMantenimientos.sortByActorYFecha;
  nuevaListaMantenimientos.writeToText;
  nuevaListaMantenimientos.Free;

  ShowMessage(mesGuardarMantenimientos);
end;



function TFSimSEEEdit.Ejecutar_Opt_Sim_SimRes(sala: TSalaDeJuego;
  archiSala, archiMonitores: string; Escenario: TEscenario_rec): integer;

var
  parametros: array of string;
  dondeEstaba: string;
  baseDir: string;

  archi_ok: string;
  res: integer;

  lstPlantillas: TStrings;
  kPlantilla: integer;
  idPlantilla: string;

begin
  res := 0;
  getdir(0, dondeEstaba);
  ChDir(getDir_Bin);

  baseDir := sala.dirResultadosCorrida;
  if length(baseDir) > 0 then
    if baseDir[length(baseDir)] = DirectorySeparator then
      Delete(baseDir, length(BaseDir), 1);

  if cgMascaraRun.Checked[0] and Escenario.run_opt then
  begin
    WritelnAlerta(DateTimeToIsoStr(now) + ', OPT: ' + Escenario.nombre);

    ChDir(getDir_Bin);
    archi_ok := baseDir + DirectorySeparator + 'cmdopt_ok.txt';
    if fileExists(archi_ok) then
      DeleteFile(archi_ok);
    setlength(parametros, 4);
    parametros[0] := 'sala="' + archiSala + '"';
    parametros[1] := 'monitores="' + archiMonitores + '"';
    parametros[2] := 'escenario="' + Escenario.nombre + '"';
    parametros[3] := 'tmp_base="' + baseDir + '"';
    RunChild( 'cmdopt', parametros, True);
    setlength(parametros, 0);
    if not fileExists(archi_ok) then
    begin
      res := 1;
      WritelnAlerta('FALLO: ' + DateTimeToIsoStr(now));
    end
    else
      WritelnAlerta(' OK: ' + DateTimeToIsoStr(now));

  end;


  if (res = 0) and cgMascaraRun.Checked[1]  and Escenario.run_sim then
  begin
    WritelnAlerta(DateTimeToIsoStr(now) + ', SIM: ' + Escenario.nombre);
    ChDir(getDir_Bin);

    archi_ok := baseDir + DirectorySeparator + 'cmdsim_ok.txt';
    if fileExists(archi_ok) then
      DeleteFile(archi_ok);

    setlength(parametros, 4);
    parametros[0] := 'sala="' + archiSala + '"';
    parametros[1] := 'monitores="' + archiMonitores + '"';
    parametros[2] := 'escenario="' + Escenario.nombre + '"';
    parametros[3] := 'tmp_base="' + baseDir + '"';
    RunChild('cmdsim', parametros, True);
    setlength(parametros, 0);

    if not fileExists(archi_ok) then
    begin
      res := res + 2;
      WritelnAlerta('FALLO: ' + DateTimeToIsoStr(now));
    end
    else
      WritelnAlerta(' OK: ' + DateTimeToIsoStr(now));

  end;


  if (res = 0) and cgMascaraRun.Checked[2]  and Escenario.run_sr3 then
  begin
    WritelnAlerta(DateTimeToIsoStr(now) + ', SR3: ' + Escenario.nombre);
    ChDir(getDir_Bin);

    lstPlantillas:= sala.listaPlantillasSimRes3.lista_activas( Escenario.capasActivas );
    for kPlantilla:= 0 to lstPlantillas.Count-1 do
    begin
    idPlantilla:= nombreArchSinExtension( lstPlantillas[kPlantilla]);
     WritelnAlerta(DateTimeToIsoStr(now) + ', SR3_Plantilla: ' + idPlantilla );


    archi_ok := baseDir + DirectorySeparator + 'cmdsimres3_ok.txt';
    if fileExists(archi_ok) then
      DeleteFile(archi_ok);

    // Sintaxis: cmdsimres3 archi_defs [idSubCarpetaSalida [ejecutor [tmp_base]]]
    setlength(parametros, 4);
    parametros[0] := '"' + sala.Calc_ArchiSR3(Escenario.nombre, idPlantilla ) + '"';
    parametros[1] := '"' + Escenario.Nombre + '"';
    parametros[2] := '_ninguno_'; // idEjecutor
    parametros[3] := '"' + sala.dirSala + '"';
    RunChild('cmdsimres3', parametros, True);
    setlength(parametros, 0);

    if not fileExists(archi_ok) then
    begin
      res := res + 3;
      WritelnAlerta('FALLO: ' + DateTimeToIsoStr(now));
    end
    else
      WritelnAlerta(' OK: ' + DateTimeToIsoStr(now));
    end;

  end;

  ChDir(dondeEstaba);
  Result := res;
end;

procedure TFSimSEEEdit.btEjecutarAutomaticamenteClick(Sender: TObject);
var
  resultado: integer;
  aux: boolean;
  kEscenario: integer;
  aEscenario: TEscenario_rec;

begin
  aux := guardado;
  if validarFormulario then
  begin
    sala.globs.NCronicasOpt := StrToInt(ENCronicasOpt.Text);
    Sala.globs.TasaDeActualizacion := StrToFloat(EtAct.Text);
    sala.globs.NCronicasSim := StrToInt(ENCronicasSim.Text);
    sala.globs.abortarSim := False;

    guardado := aux;

    if not guardado then
    begin
      resultado := Application.MessageBox(
        PChar(mesGuardarCambiosSalaParaContinuar), PChar(mesSimSEEEdit),
        MB_YESNOCANCEL);
      if resultado = idYes then
        MGuardarComoClick(MGuardarComo)
      else if resultado = idCancel then
        exit;
    end;
    if not guardadoMonitores then
    begin
      resultado := Application.MessageBox(
        PChar(mesGuardarCambiosMonitoresParaContinuar), PChar(mesSimSEEEdit),
        MB_YESNOCANCEL);
      if resultado = idYes then
        MGuardarMonitoresComoClick(MGuardarMonitoresComo)
      else if resultado = idCancel then
        exit;
    end;
    if guardado and guardadoMonitores then
    begin
      ClearConsolaAlertas;
      WritelnAlerta('Inicio ejecuciones: ' + DateTimeToIsoStr(now));

      if rgModoEjecucion.ItemIndex = 0 then
        Ejecutar_Opt_Sim_SimRes(
          sala,
          DCargarSala.fileName,
          DCargarManejadorMonitores.fileName,
          sala.EscenarioActivo)
      else
        for kEscenario := 0 to sala.Escenarios.Count - 1 do
        begin
          aEscenario := sala.Escenarios[kEscenario] as TEscenario_rec;
          if aEscenario.activa then
            Ejecutar_Opt_Sim_SimRes(
              sala,
              DCargarSala.fileName,
              DCargarManejadorMonitores.fileName,
              aEscenario);
        end;

      WritelnAlerta('Fin de ejecuaciones: ' + DateTimeToIsoStr(now));
    end;
  end
  else
    guardado := aux;
end;



procedure TFSimSEEEdit.btListarCapasClick(Sender: TObject);
var
  lstCapas: TList;
  sal: textfile;
  kCapa: integer;
  aCapa: TCapa;
  aCosaRec: TCosaRec;
  nidCapa: integer;
  kCosaRec: integer;
  NCapas: integer;
  NEscenarios: integer;
  kEscenario: integer;
  aEscenario: TEscenario_rec;
  archi: string;
  color_encabezado: string;

procedure tr_begin( color: string= 'white' );
begin
  writeln( sal, '<tr bgcolor="'+color+'">' );
end;
procedure tr_end;
begin
  writeln( sal, '</tr>' );
end;

procedure wtd( s: string; color: string = 'white' );
begin
//  write( sal, '<td bgcolor="'+color+'">'+s+'</td>' );
    write( sal, '<td>'+s+'</td>' );
end;


begin

  color_encabezado:= '#FFEEEE';

  lstCapas:= TList.Create;
  sala.AddToCapasLst( lstCapas, nil );

  archi:= getDir_Tmp + 'capas_lst.html';
  assignfile( sal, archi);
  rewrite( sal );
  writeln( sal, '<html>');
  writeln( sal,'<head>');
  writeln( sal, '</head>' );
  writeln( sal, '<body>' );

  NCapas:= lstCapas.Count;
  NEscenarios:= sala.Escenarios.Count;

  // Ordenamos las capas por su nid
  lstCapas.Sort( compare_nid_capa );


  writeln(sal, 'Escenarios x Capas<br>' );

  write( sal, '<table bgcolor="navy" cellspacing="1" cellpadding="1">' );
  tr_begin( color_encabezado );
  wtd( 'Escenario' );
  for kCapa:= 0 to NCapas -1 do
    wtd( IntToStr( TCapa( lstCapas[kCapa] ).nid ) );
  wtd( 'Activo' ); wtd( 'Opt' ); wtd( 'Sim' ); wtd( 'SR3' ); wtd( 'Descripción' );
  tr_end;

  for kEscenario:= 0 to NEScenarios-1 do
  begin
    tr_begin;
    aEscenario:= TEscenario_rec( sala.Escenarios[kEscenario] );
    wtd( aEscenario.nombre );
    for kCapa:= 0 to NCapas -1 do
    begin
      if aEscenario.tieneCapa( TCapa( lstCapas[kCapa] ).nid ) then
        wtd( IntToStr( TCapa( lstCapas[kCapa] ).nid ) )
      else
        wtd( '__' );
    end;
    wtd( BoolToStr(aEscenario.activa, 'X', '_' ) );
    wtd( BoolToStr(aEscenario.run_opt, 'X', '_' ) );
    wtd( BoolToStr(aEscenario.run_sim, 'X', '_' ) );
    wtd( BoolToStr(aEscenario.run_sr3, 'X', '_' ) );
    wtd( aEscenario.descripcion );
    tr_end;
  end;
  writeln( sal, '</table>' );
  writeln( sal, '<hr>' );

  for kCapa:= 0 to lstCapas.count-1 do
  begin
    aCapa:= TCapa( lstCapas[kCapa] );
    nidCapa:= aCapa.nid;
    writeln( sal, '<hr>' );
    writeln( sal, 'Capa:', #9, nidCapa, '<br>' );
    write( sal, '<table bgcolor="navy" cellspacing="1" cellpadding="1">' );

    tr_begin( color_encabezado );
    wtd( 'Padre_Clase' ); wtd( 'Padre_Nombre' );
    wtd( 'Clase' ); wtd('Nombre');
    wtd( 'InfoAd' );
    tr_end;

    for kCosaRec:= 0 to aCapa.CosaRecs.Count-1 do
    begin
      tr_begin;
      aCosaRec:= TCosaRec( aCapa.CosaRecs[kCosaRec] );

      wtd( aCosaRec.padre.ClassName );
      if aCosaRec.padre is TCosaConNombre then
        wtd( TCosaConNombre( aCosaRec.padre ).nombre )
      else
        wtd(  '-sn-');


      wtd( aCosaRec.cosa.ClassName );
      if aCosaRec.cosa is TCosaConNombre then
        wtd( TCosaConNombre( aCosaRec.cosa ).nombre )
      else
        wtd( '-sn-');


      wtd( TCosa( aCosaRec.Cosa ).InfoAd_ );
     tr_end;
    end;
    writeln( sal, '</table>' );
  end;
  writeln( sal ,'</body></html>' );
  closefile( sal );
  lstCapas.Free;
  OpenURL('file://'+archi);
end;

procedure TFSimSEEEdit.actualizarTablaPlantillasSimRes3;
begin
  if lst_PlantillasSimRes3 = nil then
    lst_PlantillasSimRes3 := TListadoPlantillasSimRes3.Create(
      sb_PlantillasSimRes3, 'lst_PlantillasSimRes3', sala, self.Modificado)
  else
  begin
    lst_PlantillasSimRes3.flg_populate := True;
    lst_PlantillasSimRes3.Invalidate;
  end;
end;


procedure TFSimSEEEdit.actualizarTablaEscenarios;
begin
  if lst_Escenarios = nil then
  begin
    lst_Escenarios := TListadoEscenarios.Create(sb_Escenarios,
      'lst_Escenarios', sala, self.Modificado);
    lst_Escenarios.flg_disable_autoscroll := True;
  end
  else
  begin
    lst_Escenarios.flg_populate := True;
    lst_Escenarios.flg_disable_autoscroll := True;
    lst_Escenarios.Invalidate;
  end;
end;

procedure TFSimSEEEdit.btTodosClick(Sender: TObject);
begin
  eFiltroGeneradores_CO2.Text := '';
  btAplicarFiltroClick(Sender);
end;

procedure TFSimSEEEdit.btVaciarCFAuxClick(Sender: TObject);
begin
  eArchiCFAux.Text := '';
end;

procedure TFSimSEEEdit.btVisorGraficoMantenimientosClick(Sender: TObject);
var
  vgm: TFormVisorMantenimientos;
  res: integer;
begin
  vgm := TFormVisorMantenimientos.Create(self, sala);
  res := vgm.ShowModal;

end;

procedure TFSimSEEEdit.bt_Buscar_FlucarClick(Sender: TObject);
begin

  OD_Flucar.InitialDir := getDir_Corridas;
  OD_Flucar.Filter :=
    'Archivos SimSEEEdit (*.raw)|*.raw|Archivos *.Raw (*.raw)|*.raw';


  if OD_Flucar.Execute then
  begin
    EArchivo_Flucar.Text := OD_Flucar.FileName;
    Sala.globs.iteracion_flucar_Archivo_Flucar := EArchivo_Flucar.Text;
    //getCurrentDrive+
    //EArchivoCFExit(BBuscarArchivoCF);
  end;
end;

procedure TFSimSEEEdit.bt_sr3_agregar_de_discoClick(Sender: TObject);
var
  od: TOpenDialog;
begin
  od := TOpenDialog.Create(self);
  od.Filter := 'Plantilla SimRes3 (.sr3)|*.sr3|Plantillas SimRes3 (.txt)|*.txt';
  od.DefaultExt := '.sr3';
  if od.Execute then
  begin
    if sala.listaPlantillasSimRes3.AppendArchivo(od.FileName) <> nil then
    begin
      if lst_PlantillasSimRes3 = nil then
        lst_PlantillasSimRes3 :=
          TListadoPlantillasSimRes3.Create(sb_PlantillasSimRes3,
          'lst_PlantillasSimRes3', sala, self.Modificado);
      lst_PlantillasSimRes3.flg_populate := True;
      sb_PlantillasSimRes3.AutoScroll := True;
      sb_PlantillasSimRes3.HorzScrollBar.Visible := True;
      lst_PlantillasSimRes3.Invalidate;
    end
    else
      ShowMessage(rs_ElArchivoYaEstabaYNoFueAgregado_);
  end;
  od.Free;
end;

procedure TFSimSEEEdit.bt_sr3_crear_nuevaClick(Sender: TObject);
var
  archi: string;
begin
  archi := '';
  if EditarCrearSimRes3(archi) then
  begin
    if sala.listaPlantillasSimRes3.AppendArchivo(archi) <> nil then
    begin
      if lst_PlantillasSimRes3 = nil then
        lst_PlantillasSimRes3 :=
          TListadoPlantillasSimRes3.Create(sb_PlantillasSimRes3,
          'lst_PlantillasSimRes3', sala, self.Modificado);
      lst_PlantillasSimRes3.flg_populate := True;
      sb_PlantillasSimRes3.AutoScroll := True;
      sb_PlantillasSimRes3.HorzScrollBar.Visible := True;
      lst_PlantillasSimRes3.Invalidate;
    end
    else
      ShowMessage(rs_ElArchivoYaEstabaYNoFueAgregado_);
  end;
  modificado := True;
end;


procedure TFSimSEEEdit.bt_VaciarCFEngancheClick(Sender: TObject);
begin
  RGLlenarUltimoFrame.ItemIndex := 0;
  RGLlenarUltimoFrameClick(Sender);
  eArchivoCF.Text := '';
  sala.archivoCF_ParaEnganches.archi := '';
  sala.archivoSala_ParaEnganches.archi := '';
end;



procedure TFSimSEEEdit.btExportarActor_BarraClick(Sender: TObject);
var
  k: integer;
  a: TGenerador;
  b: TComercioInternacional;
  c: TDemanda;
  d: TNodo;
  jBarra, jCodigo: integer;
  fsal: textfile;
  archi: string;
begin

  if sd.Execute then
    archi := sd.FileName;

  assignfile(fsal, archi);
  rewrite(fsal);

  // Escribo los generadores
  writeln(fsal, 'GENERADORES;');
  for k := 0 to sala.Gens.Count - 1 do
  begin
    a := sala.Gens[k] as TGenerador;

    Write(fsal, a.ClassName + '->' + a.Apodo);

    Write(fsal, '; | ');

    if a.barras_flucar <> nil then
      for jbarra := 0 to length(a.barras_flucar) - 1 do
        Write(fsal, '; ', a.barras_flucar[jbarra]);

    Write(fsal, '; | ');
    if a.codigos_flucar <> nil then
      for jCodigo := 0 to length(a.codigos_flucar) - 1 do
        Write(fsal, '; ', a.codigos_flucar[jCodigo]);
    Write(fsal, ';');
    writeln(fsal);
  end;
  writeln(fsal);

  // Escribo los actores Comercio internacional
  writeln(fsal, 'COMERCIO INTERNACIONAL;');
  for k := 0 to sala.ComercioInternacional.Count - 1 do
  begin
    b := sala.ComercioInternacional[k] as TComercioInternacional;

    Write(fsal, b.ClassName + '->' + b.Apodo);

    Write(fsal, '; | ');

    if b.barras_flucar <> nil then
      for jbarra := 0 to length(b.barras_flucar) - 1 do
        Write(fsal, '; ', b.barras_flucar[jbarra]);

    Write(fsal, '; | ');
    if b.codigos_flucar <> nil then
      for jCodigo := 0 to length(b.codigos_flucar) - 1 do
        Write(fsal, '; ', b.codigos_flucar[jCodigo]);
    Write(fsal, ';');
    writeln(fsal);
  end;
  writeln(fsal);

  // Escribo las demandas
  writeln(fsal, 'DEMANDAS;');
  for k := 0 to sala.Dems.Count - 1 do
  begin
    c := sala.Dems[k] as TDemanda;

    Write(fsal, c.ClassName + '->' + c.Apodo);

    Write(fsal, '; | ');

    if c.barras_flucar <> nil then
      for jbarra := 0 to length(c.barras_flucar) - 1 do
        Write(fsal, '; ', c.barras_flucar[jbarra]);

    Write(fsal, '; | ');
    if c.codigos_flucar <> nil then
      for jCodigo := 0 to length(c.codigos_flucar) - 1 do
        Write(fsal, '; ', c.codigos_flucar[jCodigo]);
    Write(fsal, ';');
    writeln(fsal);
  end;
  writeln(fsal);

  // Escribo los Nodos
  writeln(fsal, 'NODOS SIMSEE;');
  for k := 0 to sala.Nods.Count - 1 do
  begin
    d := sala.Nods[k] as TNodo;
    Write(fsal, d.ClassName + '->' + d.Apodo);
    Write(fsal, '; | ');
    Write(fsal, '; ', d.ZonaFlucar);
    Write(fsal, ';');
    writeln(fsal);
  end;

  closefile(fsal);
end;

procedure TFSimSEEEdit.btImportarActor_BarraClick(Sender: TObject);
var
  k: integer;
  a: TGenerador;
  b: TComercioInternacional;
  c: TDemanda;
  d: TNodo;
  jBarra, jCodigo: integer;
  fent: textfile;
  archi: string;
  r: string;
  pal: string;
begin

  if od.Execute then
    archi := od.FileName;

  if FileExists(archi) then
  begin
    assignfile(fent, archi);
    reset(fent);

    // Se leen los generadores
    readln(fent, r);
    getPalHastaSep(pal, r, ';');
    for k := 0 to sala.Gens.Count - 1 do
    begin
      readln(fent, r);
      getPalHastaSep(pal, r, '->');
      getPalHastaSep(pal, r, ';');
      a := sala.BuscarPorNombre(pal, sala.listaActores) as TGenerador;
      if a = nil then
        raise Exception.Create('No encontré el actor: ' + pal);
      getPalHastaSep(pal, r, ';');
      setlength(a.barras_flucar, 100);
      getPalHastaSep(pal, r, ';');
      jbarra := 0;
      while pal <> '|' do
      begin
        a.barras_flucar[jbarra] := StrToInt(pal);
        Inc(jbarra);
        getPalHastaSep(pal, r, ';');
      end;
      setlength(a.barras_flucar, jbarra);

      setlength(a.codigos_flucar, 100);
      jcodigo := 0;
      getPalHastaSep(pal, r, ';');
      while pal <> '' do
      begin
        a.codigos_flucar[jcodigo] := pal;
        Inc(jCodigo);
        getPalHastaSep(pal, r, ';');
      end;
      setlength(a.codigos_flucar, jcodigo);
    end;

    // Se leen los actores de Comercio Internacional
    readln(fent, r);
    readln(fent, r);
    getPalHastaSep(pal, r, ';');
    for k := 0 to sala.ComercioInternacional.Count - 1 do
    begin
      readln(fent, r);
      getPalHastaSep(pal, r, '->');
      getPalHastaSep(pal, r, ';');
      b := sala.BuscarPorNombre(pal, sala.listaActores) as TComercioInternacional;
      if b = nil then
        raise Exception.Create('No encontré el actor: ' + pal);
      getPalHastaSep(pal, r, ';');
      setlength(b.barras_flucar, 100);
      getPalHastaSep(pal, r, ';');
      jbarra := 0;
      while pal <> '|' do
      begin
        b.barras_flucar[jbarra] := StrToInt(pal);
        Inc(jbarra);
        getPalHastaSep(pal, r, ';');
      end;
      setlength(b.barras_flucar, jbarra);

      setlength(b.codigos_flucar, 100);
      jcodigo := 0;
      getPalHastaSep(pal, r, ';');
      while pal <> '' do
      begin
        b.codigos_flucar[jcodigo] := pal;
        Inc(jCodigo);
        getPalHastaSep(pal, r, ';');
      end;
      setlength(b.codigos_flucar, jcodigo);
    end;

    // Se leen las demandas
    readln(fent, r);
    readln(fent, r);
    getPalHastaSep(pal, r, ';');
    for k := 0 to sala.Dems.Count - 1 do
    begin
      readln(fent, r);
      getPalHastaSep(pal, r, '->');
      getPalHastaSep(pal, r, ';');
      c := sala.BuscarPorNombre(pal, sala.listaActores) as TDemanda;
      if c = nil then
        raise Exception.Create('No encontré el actor: ' + pal);
      getPalHastaSep(pal, r, ';');
      setlength(c.barras_flucar, 100);
      getPalHastaSep(pal, r, ';');
      jbarra := 0;
      while pal <> '|' do
      begin
        c.barras_flucar[jbarra] := StrToInt(pal);
        Inc(jbarra);
        getPalHastaSep(pal, r, ';');
      end;
      setlength(c.barras_flucar, jbarra);

      setlength(c.codigos_flucar, 100);
      jcodigo := 0;
      getPalHastaSep(pal, r, ';');
      while pal <> '' do
      begin
        c.codigos_flucar[jcodigo] := pal;
        Inc(jCodigo);
        getPalHastaSep(pal, r, ';');
      end;
      setlength(c.codigos_flucar, jcodigo);
    end;

  end;

  // Se leen los nodos
  readln(fent, r);
  readln(fent, r);
  getPalHastaSep(pal, r, ';');
  for k := 0 to sala.Nods.Count - 1 do
  begin
    readln(fent, r);
    getPalHastaSep(pal, r, '->');
    getPalHastaSep(pal, r, ';');
    d := sala.BuscarPorNombre(pal, sala.listaActores) as TNodo;
    if d = nil then
      raise Exception.Create('No encontré el actor: ' + pal);
    getPalHastaSep(pal, r, ';');
    getPalHastaSep(pal, r, ';');
    d.ZonaFlucar := StrToInt(pal);
    getPalHastaSep(pal, r, ';');
  end;

  closefile(fent);
end;

procedure TFSimSEEEdit.btAplicarFiltroClick(Sender: TObject);
begin
  if lst_co2_gens = nil then
    lst_co2_gens := TListadoGeneradores.Create(sb_Generadores,
      'lst_co2_gens', sala, self.Modificado)
  else
  begin
    lst_co2_gens.flg_populate := True;
    lst_co2_gens.Invalidate;
  end;
  lst_co2_gens.filtro := eFiltroGeneradores_CO2.Text;
end;

procedure TFSimSEEEdit.btCrearNuevoEscenarioClick(Sender: TObject);
begin
  sala.Escenarios.AppendEscenario('Escenario_' + IntToStr(sala.Escenarios.Count));
  self.modificado := True;
  actualizarTablaEscenarios;
end;

procedure TFSimSEEEdit.Button2Click(Sender: TObject);
var
  saux: TSalaDeJuego;
  k: integer;
  lst: TStrings;
  ae: TEscenario_Rec;
  nombre: string;
begin
  saux := TSalaDeJuego.cargarSala(0, EArchivoCF.Text, '', True);
  if saux <> nil then
  begin
    lst := TStringList.Create;
    for k := 0 to saux.Escenarios.Count - 1 do
    begin
      ae := saux.Escenarios.items[k] as TEscenario_Rec;
      nombre := ae.Nombre;
      lst.Add(nombre);
    end;
    saux.Free;
    cb_EngancharSala_Escenario.Items := lst;
  end;
end;

procedure TFSimSEEEdit.Button3Click(Sender: TObject);
begin
  verdoc(self, 'editor_llamar_optimizador_simulador', '');
end;

procedure TFSimSEEEdit.Button4Click(Sender: TObject);
begin

end;


procedure TFSimSEEEdit.cbAversionAlRiesgoChange(Sender: TObject);
begin
  modificado := True;
end;

procedure TFSimSEEEdit.cbAversionAlRiesgoClick(Sender: TObject);
begin
  modificado := True;
  Sala.globs.usar_CAR := cbAversionAlRiesgo.Checked;
end;

procedure TFSimSEEEdit.cbConsiderarPagosEnCFClick(Sender: TObject);
begin
  modificado := True;
  sala.flg_IncluirPagosPotenciaYEnergiaEn_CF := cbConsiderarPagosEnCF.Checked;
end;

procedure TFSimSEEEdit.cbEmisionesCO2Click(Sender: TObject);
begin
  modificado := True;
  Sala.globs.Calcular_EmisionesCO2 := cbEmisionesCO2.Checked;
end;

procedure TFSimSEEEdit.cbGenerarRawsChange(Sender: TObject);
begin
  modificado := True;
  Sala.GenerarRaws := cbGenerarRaws.Checked;
end;

procedure TFSimSEEEdit.cbPublicarSoloVariablesUsadasEnSimRes3Change(Sender: TObject);
begin
  if Sala.globs.publicarSoloVariablesUsadasEnSimRes3 <>
    cbPublicarSoloVariablesUsadasEnSimRes3.Checked then
  begin
    guardado := False;
    Sala.globs.publicarSoloVariablesUsadasEnSimRes3 :=
      cbPublicarSoloVariablesUsadasEnSimRes3.Checked;
  end;
end;



procedure TFSimSEEEdit.cbModificarCapacidadClick(Sender: TObject);
begin
  modificado := True;
  Sala.globs.iteracion_flucar_modificar_capacidad := cbModificarCapacidad.Checked;
end;

procedure TFSimSEEEdit.cbModificarPeajeClick(Sender: TObject);
begin
  modificado := True;
  Sala.globs.iteracion_flucar_modificar_peaje := cbModificarPeaje.Checked;
end;

procedure TFSimSEEEdit.cbModificarRendimientoClick(Sender: TObject);
begin
  modificado := True;
  Sala.globs.iteracion_flucar_modificar_rendimiento := cbModificarRendimiento.Checked;
end;

procedure TFSimSEEEdit.cbObligarInicioCronicaInciertoChange(Sender: TObject);
begin
  if Sala.globs.ObligarInicioCronicaIncierto_1_Sim <>
    cbObligarInicioCronicaIncierto.Checked then
  begin
    guardado := False;
    Sala.globs.ObligarInicioCronicaIncierto_1_Sim :=
      cbObligarInicioCronicaIncierto.Checked;
  end;
end;

procedure TFSimSEEEdit.CBObligar_Disp1_OptChange(Sender: TObject);
begin
  if Sala.globs.ObligarDisponibilidad_1_Opt <> CBObligar_Disp1_Opt.Checked then
  begin
    guardado := False;
    Sala.globs.ObligarDisponibilidad_1_Opt := CBObligar_Disp1_Opt.Checked;
  end;
end;


procedure TFSimSEEEdit.CBObligar_Disp1_SimChange(Sender: TObject);
begin
  if Sala.globs.ObligarDisponibilidad_1_Sim <> CBObligar_Disp1_Sim.Checked then
  begin
    guardado := False;
    Sala.globs.ObligarDisponibilidad_1_Sim := CBObligar_Disp1_Sim.Checked;
  end;
end;

procedure TFSimSEEEdit.cbReservaRotanteChange(Sender: TObject);
begin
  guardado := False;
  sala.globs.flg_ReservaRotante := cbReservaRotante.Checked;
end;

procedure TFSimSEEEdit.cbRestarUtilidadesDeCFClick(Sender: TObject);
begin
  modificado := True;
  sala.globs.RestarUtilidadesDelCostoFuturo := cbRestarUtilidadesDeCF.Checked;
end;

procedure TFSimSEEEdit.CBSorteosChange(Sender: TObject);
begin
  guardado := False;
  sala.globs.SortearOpt := CBSorteos.Checked;

end;

procedure TFSimSEEEdit.cbUsarIteradorFlucarChange(Sender: TObject);
begin
  guardado := False;
  sala.usarIteradorFlucar := cbUsarIteradorFlucar.Checked;
end;

procedure TFSimSEEEdit.cb_CO2_ProyectoTipoSolarEolicoChange(Sender: TObject);
begin
  modificado := True;
  sala.globs.FactorEmisiones_ProyectoEolicoSolar :=
    cb_CO2_ProyectoTipoSolarEolico.Checked;
end;

procedure TFSimSEEEdit.cb_enganchar_promediando_desaparecidasChange(Sender: TObject);
begin
  guardado := False;
  sala.enganchar_promediando_desaparecidas :=
    cb_enganchar_promediando_desaparecidas.Checked;
end;

procedure TFSimSEEEdit.cb_flg_ImprimirArchivosEstadoFinCronicaChange(Sender: TObject);
begin
  modificado := True;
  sala.flg_ImprimirArchivos_Estado_Fin_Cron :=
    cb_flg_ImprimirArchivosEstadoFinCronica.Checked;
end;

procedure TFSimSEEEdit.eArchiCFauxChange(Sender: TObject);
begin
  if sala.archivoCFAux.archi <> eArchiCFAux.Text then
  begin
    sala.archivoCFAux.archi := eArchiCFaux.Text;
    guardado := False;
  end;
end;


procedure TFSimSEEEdit.EArchivoCFChange(Sender: TObject);
begin
  if sala.archivoCF_ParaEnganches.archi <> EArchivoCF.Text then
    guardado := False;
end;

procedure TFSimSEEEdit.eCARChange(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TFSimSEEEdit.eCAREditingDone(Sender: TObject);
begin
  if validarEditFloat(eCAR, 0, 1.2) then
    Sala.globs.CAR := StrToFloat(eCAR.Text);
end;

procedure TFSimSEEEdit.eCAREnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TFSimSEEEdit.eDurPaso_MinutosChange(Sender: TObject);
var
  m: integer;
begin
  try
    m := StrToInt(eDurPaso_Minutos.Text);
    sala.globs.DurPaso_minutos := m;
    sala.globs.dt_DelPaso := m / (60 * 24);
    guardado := False;
    TEdit(Sender).color := clDefault;
  except
    TEdit(Sender).color := clRed;
  end;
end;

procedure TFSimSEEEdit.eFechaGuardaSimChange(Sender: TObject);
begin
  try
    sala.globs.fechaGuardaSim.PonerIgualA(trim(eFechaGuardaSim.Text));
    guardado := False;
    TEdit(Sender).color := clDefault;
  except
    TEdit(Sender).Color := clRed;
  end;
end;

procedure TFSimSEEEdit.eFechaIniSimChange(Sender: TObject);
begin
  try
    sala.globs.fechaIniSim.PonerIgualA(trim(eFechaIniSim.Text));
    Sala.globs.HorasDelPaso := StrToFloat(EDurPaso.Text);
    ENPasosSim.Text := IntToStr(Sala.globs.calcNPasosSim);
    guardado := False;
    TEdit(Sender).color := clDefault;
  except
    TEdit(Sender).Color := clRed;
  end;
end;

procedure TFSimSEEEdit.eHusoHorario_UTCChange(Sender: TObject);
begin
  try
    sala.globs.husoHorario_UTC := strToFloat(eHusoHorario_UTC.Text);
    guardado := False;
    TEdit(Sender).color := clDefault;
  except
    TEdit(Sender).Color := clRed;
  end;
end;


procedure TFSimSEEEdit.eLimiteProbabilidadChange(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TFSimSEEEdit.eLimiteProbabilidadEditingDone(Sender: TObject);
begin
  if validarEditFloat(eLimiteProbabilidad, 0, 1.2) then
    Sala.globs.probLimiteRiesgo := StrToFloat(eLimiteProbabilidad.Text);
end;

procedure TFSimSEEEdit.eLimiteProbabilidadEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;



procedure TFSimSEEEdit.eNDiscHistoEditingDone(Sender: TObject);
begin
  if validarEditInt(eNDiscHisto, 0, MaxInt) then
    sala.globs.NDiscHistoCF := StrToInt(eNDiscHisto.Text);
end;

procedure TFSimSEEEdit.eNDiscHistoEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TFSimSEEEdit.eSemillaINicial_optChange(Sender: TObject);
begin
  modificado := True;
end;

procedure TFSimSEEEdit.eSemillaINicial_optEditingDone(Sender: TObject);
begin
  if validarEditInt(eSemillaInicial_opt, 0, MaxInt) then
    sala.globs.semilla_inicial_opt := StrToInt(eSemillaInicial_opt.Text);
  modificado := True;
end;

procedure TFSimSEEEdit.eSemillaInicial_simChange(Sender: TObject);
begin
  modificado := True;
end;

procedure TFSimSEEEdit.eSemillaInicial_simEditingDone(Sender: TObject);
begin
  if validarEditInt(eSemillaInicial_sim, 0, MaxInt) then
    sala.globs.semilla_inicial_sim := StrToInt(eSemillaInicial_sim.Text);
  modificado := True;
end;

procedure TFSimSEEEdit.eUniformizarPromediandoChange(Sender: TObject);
begin
  guardado := False;
  sala.uniformizar_promediando := eUniformizarPromediando.Text;
end;

class procedure TFSimSEEEdit.registrarActores;
var
  info: TInfoCosaConNombre;
begin
  // El orden en que se registran los actores determina el orden en que aparecen en las
  // tabs

  // Red
  info := TInfoCosaConNombre.Create(TNodo, TNodo.descClase, TEditarTNodo, nil);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabRed);

  info := TInfoCosaConNombre.Create(TArco, TArco.DescClase, TEditarTArco,
    TEditarFichaArco);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabRed);


  info := TInfoCosaConNombre.Create(TArcoConSalidaProgramable,
    TArcoConSalidaProgramable.DescClase, TEditarTArcoConSalidaProgramable,
    TEditarFichaArcoConSalidaProgramable);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabRed);


  // Demandas
  info := TInfoCosaConNombre.Create(TDemanda01, TDemanda01.DescClase,
    TEditarTDemanda01, TEditarFichaDemanda01);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabDemandas);
  info := TInfoCosaConNombre.Create(TDemandaDetallada, TDemandaDetallada.DescClase,
    TEditarTDemandaDetallada, nil);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabDemandas);
  info := TInfoCosaConNombre.Create(TDemandaAnioBaseEIndices,
    TDemandaAnioBaseEIndices.DescClase, TEditarTDemandaAnioBaseEIndices, nil);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabDemandas);



  // Eólica
  info := TInfoCosaConNombre.Create(TParqueEolico, TParqueEolico.DescClase,
    TEditarTParqueEolico, nil);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabEolica_);

  info := TInfoCosaConNombre.Create(TParqueEolico_vxy,
    TParqueEolico_vxy.DescClase, TEditarTParqueEolico_vxy, nil);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabEolica_);

  // Solar MILENA NUEVO ACTOR  solar termico
  info := TInfoCosaConNombre.Create(TSolartermico, TSolartermico.DescClase,
    TEditarTSolarTermico, TEditarFichaSolartermico);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabSolar);

  info := TInfoCosaConNombre.Create(TSolarPV, TSolarPV.DescClase,
    TEditarTSolarPV, TEditarFichaSolarPV);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabSolar);


  // Generadores Térmicos
  info := TInfoCosaConNombre.Create(TGTer_Basico, TGTer_Basico.DescClase,
    TEditarTGTer, TEditarFichaGTer_Basico);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresTermicos);
  info := TInfoCosaConNombre.Create(TGTer_OnOffPorPaso, TGTer_OnOffPorPaso.DescClase,
    TEditarTGTer, TEditarFichaGTer_OnOffPorPaso);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresTermicos);
  info := TInfoCosaConNombre.Create(TGTer_OnOffPorPoste,
    TGTer_OnOffPorPoste.DescClase, TEditarTGTer, TEditarFichaGTer_OnOffPorPoste);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresTermicos);
  info := TInfoCosaConNombre.Create(TGTer_ArranqueParada,
    TGTer_ArranqueParada.DescClase, TEditarTGter_ArranqueParada,
    TEditarFichaGTer_ArranqueParada);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresTermicos);
  info := TInfoCosaConNombre.Create(TGTer_Basico_TRep, TGTer_Basico_TRep.DescClase,
    TEditarTGTer_Basico_TRep, TEditarFichaGTer_Basico_TRep);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresTermicos);

  info := TInfoCosaConNombre.Create(TGTer_Basico_PyCVariable,
    TGTer_Basico_PyCVariable.DescClase, TEditarTGTer_Basico_PyCVariable,
    TEditarFichaGTer_Basico_PyCVariable);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresTermicos);

  info := TInfoCosaConNombre.Create(TGTer_OnOffPorPaso_ConRestricciones,
    TGTer_OnOffPorPaso_ConRestricciones.DescClase,
    TEditarTGTer_OnOffPorPaso_ConRestricciones,
    TEditarFichaGTer_OnOffPorPaso_ConRestricciones);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresTermicos);

  info := TInfoCosaConNombre.Create(THidroConEmbalse, THidroConEmbalse.DescClase,
    TEditarTHidroConEmbalse, TEditarFichaHidroConEmbalse);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresHidraulicos);

  info := TInfoCosaConNombre.Create(THidroConBombeo, THidroConBombeo.DescClase,
    TEditarTHidroConBombeo, TEditarFichaHidroConBombeo);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresHidraulicos);

  info := TInfoCosaConNombre.Create(TGTer_combinado, TGTer_combinado.DescClase,
    TEditarTGTer_Combinado, TEditarFichaGTer_combinado);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresTermicos);

  // BiomasaEmbalsable
  info := TInfoCosaConNombre.Create(TBiomasaEmbalsable, TBiomasaEmbalsable.DescClase,
    TEditarTBiomasaEmbalsable, TEditarFichaBiomasaEmbalsable);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresTermicos);


  // Generadores Hidráulicas
  { info:= TInfoActor.Create(THidroConEmbalseValorizado, THidroConEmbalseValorizado.DescClase, TAltaHidroConEmbalseValorizado, TEditarHidroConEmbalseValorizado, TEditarFichaHidroConEmbalseValorizado);
    uInfoTabs.infoTabs.addInfoActor(info, strTabGeneradoresHidraulicos); }
  info := TInfoCosaConNombre.Create(THidroDePasada, THidroDePasada.DescClase,
    TEditarTHidroDePasada, TEditarFichaHidroDePasada);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresHidraulicos);
  info := TInfoCosaConNombre.Create(THidroConEmbalseBinacional,
    THidroConEmbalseBinacional.DescClase, TEditarTHidroConEmbalseBinacional,
    TEditarFichaHidroConEmbalseBinacional);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabGeneradoresHidraulicos);

  // Comercio Internacional  y Otros
  info := TInfoCosaConNombre.Create(TMercadoSpot, TMercadoSpot.DescClase,
    TEditarTBaseMercadoSpot, TEditarFichaMercadoSpot);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabComercioInternacionalYOtros);
  info := TInfoCosaConNombre.Create(TMercadoSpotDetalleHorarioSemanal,
    TMercadoSpotDetalleHorarioSemanal.DescClase, TEditarTBaseMercadoSpot,
    TEditarFichaMercadoSpotConDetalleHorario);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabComercioInternacionalYOtros);

  info := TInfoCosaConNombre.Create(TContratoModalidadDevolucion,
    TContratoModalidadDevolucion.DescClase, TEditarTContratoModalidadDevolucion,
    TEditarFichaContratoModalidadDevolucion);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabComercioInternacionalYOtros);

  info := TInfoCosaConNombre.Create(TMercadoSpot_postizado,
    TMercadoSpot_postizado.DescClase, TEditarTMercadoSpot_postizado,
    TEditarFichaMercadoSpot_postizado);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabComercioInternacionalYOtros);

  info := TInfoCosaConNombre.Create(TBancoDeBaterias01,
    TBancoDeBaterias01.DescClase, TEditarTBancoDeBaterias01,
    TEditarFichaBancoDeBaterias01);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabComercioInternacionalYOtros);


  // USOS GESTIONABLES
  info := TInfoCosaConNombre.Create(TUsoGestionable_postizado,
    TUsoGestionable_postizado.DescClase, TEditarTUsoGestionable_postizado,
    TEditarFichaUsoGestionable_postizado);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabUsosGestionables);



  // Red Combustibles
  info := TInfoCosaConNombre.Create(TNodoCombustible, TNodoCombustible.descClase,
    TEditarTNodoCombustible, nil);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabSumCombustibles);

  // Agrego demanda combustible

  info := TInfoCosaConNombre.Create(TDemandaCombustibleAnioBaseEIndices,
    TDemandaCombustibleAnioBaseEIndices.descClase,
    TEditarTDemandaCombustibleAnioBaseEIndices, nil);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabSumCombustibles);

  info := TInfoCosaConNombre.Create(TRegasificadora, TRegasificadora.descClase,
    TEditarRegasificadora, TEditarfichaRegasificadora);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabSumCombustibles);



  info := TInfoCosaConNombre.Create(TArcoCombustible, TArcoCombustible.descClase,
    TEditarTArcoCombustible, TEditarFichaArcoCombustible);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabSumCombustibles);

  info := TInfoCosaConNombre.Create(TGSimple_MonoCombustible,
    TGSimple_MonoCombustible.descClase, TEditarTGsimple_MonoCombustible,
    TEditarfichagsimple_MonoCombustible);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabSumCombustibles);

  info := TInfoCosaConNombre.Create(TGSimple_BiCombustible,
    TGSimple_BiCombustible.descClase, TEditarTGsimple_biCombustible,
    TEditarfichagsimple_bicombustible);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabSumCombustibles);

  info := TInfoCosaConNombre.Create(TSuministroSimpleCombustible,
    TSuministroSimpleCombustible.descClase, TEditarsumcomb, TEditarfichasumcomb);
  uInfoTabs.infoTabs_.addInfoActor(info, strTabSumCombustibles);


  // agregamos un tab más para que el editor sea capaz de cargar los que no tengan
  // editor registrado.
  uInfoTabs.infoTabs_.addTab(strTabSinEditorRegistrado);


  uInfoTabs.infoTabs_.crearOrdinales;
end;

class procedure TFSimSEEEdit.registrarMonitores;
begin
  uInfoCosa.InfoMonitores.Add(TInfoCosa.Create(TReferenciaMonConsola,
    TReferenciaMonConsola.DescClase, TAltaMonitorConsola));
  uInfoCosa.InfoMonitores.Add(TInfoCosa.Create(TReferenciaMonGrafico,
    TReferenciaMonGrafico.DescClase, TAltaMonitorGrafico));
  uInfoCosa.InfoMonitores.Add(TInfoCosa.Create(TReferenciaMonArchivo,
    TReferenciaMonArchivo.DescClase, TAltaMonArchivo));
  uInfoCosa.InfoMonitores.Add(TInfoCosa.Create(TReferenciaMonHistograma,
    TReferenciaMonHistograma.DescClase, TAltaMonitorHistograma));
  uInfoCosa.InfoMonitores.Add(TInfoCosa.Create(TReferenciaMonSimRes,
    TReferenciaMonSimRes.DescClase, TAltaMonSimRes));
end;

procedure TFSimSEEEdit.RGLlenarUltimoFrameClick(Sender: TObject);
begin

  if ((RGLlenarUltimoFrame.ItemIndex = 0) or (RGLlenarUltimoFrame.ItemIndex = 2)) then
  begin
    if sala.usarArchivoParaInicializarFrameInicial <> RGLlenarUltimoFrame.ItemIndex then
    begin
      sala.usarArchivoParaInicializarFrameInicial := RGLlenarUltimoFrame.ItemIndex;
      EArchivoCF.Enabled := False;
      BBuscarArchivoCF.Enabled := False;
      BEnganches.Enabled := False;
      cb_enganchar_promediando_desaparecidas.Enabled := False;
    end;
  end
  else
  begin
    if not (sala.usarArchivoParaInicializarFrameInicial = 1) then
    begin
      sala.usarArchivoParaInicializarFrameInicial := 1;
      EArchivoCF.Enabled := True;
      BBuscarArchivoCF.Enabled := True;
      BEnganches.Enabled := True;
      cb_enganchar_promediando_desaparecidas.Enabled := True;
    end;
  end;
  guardado := False;
end;


class procedure TFSimSEEEdit.registrarCombustibles;
begin
  uInfoCosa.InfoCombustibles.Add(TInfoCosa.Create(TCombustible,
    TCombustible.DescClase, TEditarTCombustible));
  uInfoCosa.InfoFichasCombustibles.Add(TInfoCosa.Create(TFichaCombustible,
    TFichaCombustible.DescClase, TEditarFichaCombustible));
end;


class procedure TFSimSEEEdit.registrarFuentes;
begin
  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteConstante,
    TFuenteConstante.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteConstante,
    TFichaFuenteConstante.DescClase, TEditarFichaFuenteConstante));
  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteUniforme,
    TFuenteUniforme.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteUniforme,
    TFichaFuenteUniforme.DescClase, TEditarFichaFuenteUniforme));
  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteGaussiana,
    TFuenteGaussiana.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteGaussiana,
    TFichaFuenteGaussiana.DescClase, TEditarFichaFuenteGaussiana));
  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteWeibull,
    TFuenteWeibull.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteWeibull,
    TFichaFuenteWeibull.DescClase, TEditarFichaFuenteWeibull));
  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteCombinacion,
    TFuenteCombinacion.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteCombinacion,
    TFichaFuenteCombinacion.DescClase, TEditarFichaFuenteCombinacion));
  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteProducto,
    TFuenteProducto.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteProducto,
    TFichaFuenteProducto.DescClase, TEditarFichaFuenteProducto));

  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteSintetizadorCEGH,
    TFuenteSintetizadorCEGH.DescClase, TEditarFuenteSintetizador));

  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteTiempo,
    TFuenteTiempo.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteTiempo,
    TFichaFuenteTiempo.DescClase, TEditarFichaFuenteTiempo));

  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteSinusoide,
    TFuenteSinusoide.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteSinusoide,
    TFichaFuenteSinusoide.DescClase, TEditarFichaFuenteSinusoide));

  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteMaxMin,
    TFuenteMaxMin.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteMaxMin,
    TFichaFuenteMaxMin.DescClase, TEditarFichaFuenteMaxMin));

  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteSelector,
    TFuenteSelector.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteSelector,
    TFichaFuenteSelector.DescClase, TEditarFichaFuenteSelector));


  uInfoCosa.InfoFuentes.Add(TInfoCosa.Create(TFuenteSelector_horario,
    TFuenteSelector_horario.DescClase, TEditarFuentesSimples));
  uInfoCosa.InfoFichasFuentes.Add(TInfoCosa.Create(TFichaFuenteSelector_horario,
    TFichaFuenteSelector_horario.DescClase, TEditarFichaFuenteSelector_horario));

end;

procedure TFSimSEEEdit.LimpiarSala;
var
  i: integer;
begin
  Sala.Free;
  rbtEditorSala.CatalogoReferencias.LimpiarReferencias;
  for i := 0 to high(ListasDeActoresTabs) do
    ListasDeActoresTabs[i].Clear;
  Sala := nil;
  lst_co2_gens.Free;
  lst_co2_gens := nil;
  lst_PlantillasSimRes3.Free;
  lst_PlantillasSimRes3 := nil;
  lst_Escenarios.Free;
  lst_Escenarios := nil;
end;

procedure TFSimSEEEdit.LimpiarManejadorMonitores;
begin
  manejadorMonitores.Free;
  manejadorMonitores := nil;
end;


function TFSimSEEEdit.editarMantenimiento(fila: integer; clonar: boolean): integer;
var
  form: TEditarFichaUnidades;
  formSelectActor: TFormSelectTipo;
  nombresActoresConMantenimiento: TStringList;
  actor: TActor;
  ficha: TFichaUnidades;
  editar: boolean;
  res: integer;
  i: integer;
begin
  res := -1;
  if fila = 0 then
  begin
    nombresActoresConMantenimiento := TStringList.Create;
    nombresActoresConMantenimiento.Sorted := True;
    nombresActoresConMantenimiento.Duplicates := dupIgnore;
    for i := 0 to listaMantenimientos.Count - 1 do
      nombresActoresConMantenimiento.Add(TNodoListaMantenimientos(
        listaMantenimientos.Items[i]).actor.nombre);

    formSelectActor := TFormSelectTipo.Create(self, rsSeleccioneUnGenerador,
      nombresActoresConMantenimiento);
    if formSelectActor.ShowModal = mrOk then
    begin
      actor := TActor(sala.listaActores.find(formSelectActor.darTipo));
      editar := True;
    end
    else
    begin
      actor := nil; // para evitar el warning
      editar := False;
    end;

    ficha := nil;
    formSelectActor.Free;
    nombresActoresConMantenimiento.Free;
  end
  else
  begin
    actor := TNodoListaMantenimientos(listaMantenimientos[fila - 1]).actor;
    ficha := TNodoListaMantenimientos(listaMantenimientos[fila - 1]).fichaUnidades;
    editar := True;
  end;

  if editar then
  begin
    form := TEditarFichaUnidades.Create(self, actor, ficha, nil);
    if form.ShowModal = mrOk then
    begin
      if not clonar then
      begin
        if ficha <> nil then // Si no estoy agregando una ficha nueva
        begin
          TNodoListaMantenimientos(listaMantenimientos[fila - 1]).Free;
          listaMantenimientos.Delete(fila - 1);
          actor.lpdUnidades.replace(ficha, form.darFicha);
          ficha.Free;
        end
        else
          actor.lpdUnidades.Add(form.darFicha);
      end;
      res := listaMantenimientos.addInOrderByActorYFecha(actor,
        TFichaUnidades(form.darFicha())) + 1;
      actualizarTablaMantenimientos;
      guardado := False;
    end;
    form.Free;
  end
  else
    res := -1;
  Result := res;
end;

procedure TFSimSEEEdit.eliminarMantenimiento(fila: integer);
var
  nodo: TNodoListaMantenimientos;
  texto: string;
begin
  nodo := listaMantenimientos[fila - 1];
  if nodo.actor.lpdUnidades.Count = 1 then
  begin
    ShowMessage(
      mesNoSePuedeEliminarLaFichaDeUnidades);
  end
  else
  begin
    texto :=
      mesConfirmaEliminarFichaUnidadesActor + nodo.actor.nombre +
      '" para el ' + nodo.fichaUnidades.fecha.AsStr + '?';
    if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
      MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
    begin
      nodo.actor.lpdUnidades.Remove(nodo.fichaUnidades);
      nodo.fichaUnidades.Free;
      nodo.Free;
      listaMantenimientos.Delete(fila - 1);
      actualizarTablaMantenimientos;
      guardado := False;
    end;
  end;
end;

procedure TFSimSEEEdit.altaMantenimiento;
begin
  editarMantenimiento(0, False);
end;

procedure TFSimSEEEdit.actualizarTablaMantenimientos;
var
  i: integer;
  aux: TNodoListaMantenimientos;
begin
  sgMantenimientos.RowCount := listaMantenimientos.Count + 1;
  if sgMantenimientos.RowCount > 1 then
    sgMantenimientos.FixedRows := 1
  else
    sgLimpiarSeleccion(sgMantenimientos);

  for i := 0 to listaMantenimientos.Count - 1 do
  begin
    aux := TNodoListaMantenimientos(listaMantenimientos[i]);
    sgMantenimientos.Cells[0, i + 1] := aux.actor.nombre;
    sgMantenimientos.Cells[1, i + 1] := aux.actor.DescClase;
    sgMantenimientos.Cells[2, i + 1] := aux.fichaUnidades.fecha.AsStr;
    sgMantenimientos.Cells[3, i + 1] :=
      IntToStr(aux.fichaUnidades.nUnidades_Instaladas[0]);
    sgMantenimientos.Cells[4, i + 1] :=
      IntToStr(aux.fichaUnidades.nUnidades_EnMantenimiento[0]);
    sgMantenimientos.Cells[5, i + 1] :=
      boolToSiNo(aux.fichaUnidades.periodicidad <> nil);
  end;

  for i := 0 to sgMantenimientos.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgMantenimientos, i, TiposColMantenimientos[i], iconos);

  sgMantenimientos.Visible := True;
  (*
  utilidades.AutosizeTable(sgMantenimientos, maxAnchoTablaEnorme,
    maxAlturaTablaGrande, TSimSEEEditOptions.getInstance.
    deshabilitarScrollHorizontalEnListados);
    *)
end;

function TFSimSEEEdit.validarCeldaMantenimientos(listado: TStringGrid;
  fila, columna: integer): boolean;
begin
  case columna of
    2:
      Result := inherited validarCeldaFecha(listado, fila, columna);
    3:
      Result := inherited validarCeldaNInt(listado, fila, columna);
    else
      Result := True;
  end;
end;

procedure TFSimSEEEdit.cambioValorMantenimientos(listado: TStringGrid;
  fila, columna: integer);
var
  aux: TNodoListaMantenimientos;
begin
  if columna = 2 then
  begin
    aux := TNodoListaMantenimientos(listaMantenimientos[fila - 1]);
    aux.fichaUnidades.fecha.Free;
    aux.fichaUnidades.fecha := FSimSEEEdit.StringToFecha(listado.Cells[columna, fila]);
    guardado := False;
    listaMantenimientos.sortByActorYFecha;
    actualizarTablaMantenimientos;
    sgMantenimientos.Row := listaMantenimientos.IndexOf(aux) + 1;
  end
  else if columna = 3 then
  begin
    TNodoListaMantenimientos(listaMantenimientos[fila -
      1]).fichaUnidades.nUnidades_Instaladas[0] :=
      StrToInt(listado.Cells[columna, fila]);
    guardado := False;
  end
  else if columna = 43 then
  begin
    TNodoListaMantenimientos(listaMantenimientos[fila -
      1]).fichaUnidades.nUnidades_EnMantenimiento[0] :=
      StrToInt(listado.Cells[columna, fila]);
    guardado := False;
  end;
end;


procedure TFSimSEEEdit.editarMonitor(fila: integer; clonar: boolean);
var
  form: TBaseAltasMonitores;
  TipoEditor: TClaseEditoresMonitores;
  monitor, nuevoMonitor: TReferenciaMonitor;
begin
  monitor := TReferenciaMonitor(manejadorMonitores.referenciasMonitores[fila - 1]);
  TipoEditor := TClaseEditoresMonitores(uInfoCosa.InfoMonitores.getTipoEditor
    (monitor.ClassType));
  if TipoEditor <> nil then
  begin
    form := TipoEditor.Create(self, monitor, sala, manejadorMonitores,
      clonar, TClaseReferenciaMonitor(monitor.ClassType));
    if form.ShowModal = mrOk then
    begin
      nuevoMonitor := form.darReferenciaMonitor;
      if manejadorMonitores.notificarCambioCosa(monitor, nuevoMonitor) then
        guardadoMonitores := False;
      if not clonar then
      begin
        manejadorMonitores.quitarMonitor(monitor);
        manejadorMonitores.referenciasMonitores.Remove(monitor);
        monitor.Free;
      end;
      manejadorMonitores.referenciasMonitores.Add(nuevoMonitor);
      actualizarTablaMonitores;
      sgBuscarYSeleccionarFila(sgMonitores, 0, nuevoMonitor.nombre);
      manejadorMonitores.PrepararseYPubliVars;
      guardadoMonitores := False;
    end;
    form.Free;
  end
  else
  begin
    raise Exception.Create(exEditorNoRegistradoClase + monitor.ClassName);
  end;
end;

procedure TFSimSEEEdit.eliminarMonitor(fila: integer);
var
  monitor: TReferenciaMonitor;
  texto: string;
begin
  monitor := TReferenciaMonitor(manejadorMonitores.referenciasMonitores[fila - 1]);
  texto := mesConfirmaEliminarMonitor + monitor.nombre + '"?';
  if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
    MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    manejadorMonitores.referenciasMonitores.Delete(fila - 1);
    monitor.Free;
    actualizarTablaMonitores;
    guardadoMonitores := False;
  end;
end;

procedure TFSimSEEEdit.altaMonitor;
var
  form: TBaseAltasMonitores;
  formSelectTipo: TFormSelectTipo;
  tipoEditorMonitor: TClaseEditoresMonitores;
  tipoReferencia: TClaseReferenciaMonitor;
begin
  // Selecciono el tipo de monitor
  formSelectTipo := TFormSelectTipo.Create(self, uInfoCosa.InfoMonitores.descsClase);
  if formSelectTipo.ShowModal = mrOk then
  begin
    tipoReferencia := TClaseReferenciaMonitor(
      uInfoCosa.InfoMonitores.tipoDeCosa(formSelectTipo.darTipo));
    tipoEditorMonitor := TClaseEditoresMonitores(
      uInfoCosa.InfoMonitores.getTipoEditor(tipoReferencia));
    formSelectTipo.Free;

    // Muestro el editor del monitor seleccionado
    form := tipoEditorMonitor.Create(self, nil, sala, manejadorMonitores,
      True, tipoReferencia);
    if form.ShowModal = mrOk then
    begin
      manejadorMonitores.referenciasMonitores.Add(form.darReferenciaMonitor);
      actualizarTablaMonitores;
      manejadorMonitores.PrepararseYPubliVars;
      sgBuscarYSeleccionarFila(sgMonitores, 0, form.darReferenciaMonitor.nombre);
      guardadoMonitores := False;
    end;
    form.Free;
  end;
end;

procedure TFSimSEEEdit.actualizarTablaMonitores;
var
  i: integer;
  aux: TReferenciaMonitor;
begin
  sgMonitores.RowCount := manejadorMonitores.referenciasMonitores.Count + 1;
  if sgMonitores.RowCount > 1 then
    sgMonitores.FixedRows := 1
  else
    sgLimpiarSeleccion(sgMonitores);

  for i := 0 to manejadorMonitores.referenciasMonitores.Count - 1 do
  begin
    aux := TReferenciaMonitor(manejadorMonitores.referenciasMonitores[i]);
    sgMonitores.Cells[0, i + 1] := aux.nombre;
    sgMonitores.Cells[1, i + 1] := aux.DescClase;
    if aux.Enabled then
      sgMonitores.Cells[2, i + 1] := '1'
    else
      sgMonitores.Cells[2, i + 1] := '';
  end;

  for i := 0 to sgMonitores.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgMonitores, i, TiposColMonitores[i], iconos);

  (*
  utilidades.AutosizeTable(sgMonitores, maxAnchoTablaEnorme,
    maxAlturaTablaGrande, TSimSEEEditOptions.getInstance.
    deshabilitarScrollHorizontalEnListados);
    *)
end;

procedure TFSimSEEEdit.crearMonitorSimResPorDefecto;
var
  newMonSimRes, oldMonSimRes: TReferenciaMonSimRes;
begin
  newMonSimRes := manejadorMonitores.crearMonitorSimResPorDefecto;

  oldMonSimRes := TReferenciaMonSimRes(manejadorMonitores.referenciasMonitores.find
    (nomMonSimRes3PDefecto));
  if oldMonSimRes = nil then
  begin
    manejadorMonitores.referenciasMonitores.Add(newMonSimRes);
    actualizarTablaMonitores;
  end
  else
  begin
    if Application.MessageBox(PChar(mesMonitorXDefectoCreadoRemplazarlo),
      PChar(mesRemplazarMonitorSimRes3), MB_YESNO + MB_ICONQUESTION) = idYes then
    begin
      manejadorMonitores.referenciasMonitores.replace(oldMonSimRes, newMonSimRes);
      oldMonSimRes.Free;
      actualizarTablaMonitores;
    end;
  end;
end;

procedure TFSimSEEEdit.validarCambioTablaPostes(tabla: TStringGrid);
var
  i: integer;
  DurPaso: NReal;
begin
  filaValidarSg := tabla.Row;
  colValidarSg := tabla.Col;
  writeln(filaValidarSg, ', ', colValidarSG);
  if (colValidarSG <> -1) and (filaValidarSG <> -1) then
  begin
    if (tabla.Cells[colValidarSG, filaValidarSG] <> loQueHabia) and
      (filaValidarSG > tabla.FixedRows - 1) and (colValidarSG > tabla.FixedCols - 1) then
      try
        if colValidarSG - 1 < Length(Sala.globs.DurPos) then
          sala.globs.DurPos[colValidarSG - 1] :=
            StrToFloat(tabla.Cells[colValidarSG, filaValidarSG]);
        DurPaso := 0;
        for i := 0 to Sala.globs.NPostes - 1 do
          DurPaso := DurPaso + Sala.globs.DurPos[i];

        EDurPaso.Text := FloatToStr(DurPaso);
        guardado := False;
      except
        on EConvertError do
        begin
          tabla.Cells[tabla.col, tabla.Row] := loQueHabia;
          ShowMessage(mesValorIntroducidoDebeNum);
        end
      end;
  end;
end;

procedure TFSimSEEEdit.EditTamTablaExit(Sender: TObject);
var
  nAnt, n, i: integer;
  DurPaso: integer;
begin
  if validarEditInt(TEdit(Sender), 1, MAXINT) then
  begin
    nAnt := sgPostes.ColCount - 1;
    n := StrToInt(TEdit(Sender).Text);
    if n <> nAnt then
    begin
      sgPostes.ColCount := n + 1;
      Sala.globs.NPostes := n;

      setLength(Sala.globs.durpos, n);
      for i := nAnt + 1 to n do
      begin
        sgPostes.Cells[i, 0] := IntToStr(i);
        sgPostes.Cells[i, 1] := sgPostes.Cells[nAnt, 1];
      end;

      DurPaso := 0;
      for i := 1 to n do
        DurPaso := DurPaso + StrToInt(sgPostes.Cells[i, 1]);
      EDurPaso.Text := IntToStr(DurPaso);

      for i := 0 to n - 1 do
        Sala.globs.DurPos[i] := StrToFloat(sgPostes.cells[i + 1, 1]);

      recalcNumeroPasos(Sender);

      Sala.Prepararse_(rbtEditorSala.CatalogoReferencias);
      sala.publicarTodasLasVariables;

      guardado := False;
    end;
  end;
end;

procedure TFSimSEEEdit.FormDestroy(Sender: TObject);
begin
  if rbtEditorSala <> nil then
  begin
    rbtEditorSala.Free;
    rbtEditorSala := nil;
  end;
  interpreteDeParametros.Free;

  //  if manejadorListadoEditores <> nil then   manejadorListadoEditores.Free;
  //  if observadorCambiosEditoresActores <> nil then   observadorCambiosEditoresActores.Free;
  inherited;
end;

procedure TFSimSEEEdit.gbEscenariosClick(Sender: TObject);
begin

end;

procedure TFSimSEEEdit.gbVarOptClick(Sender: TObject);
begin

end;

procedure TFSimSEEEdit.gbVarSim_Click(Sender: TObject);
begin

end;

procedure TFSimSEEEdit.GroupBox3Click(Sender: TObject);
begin

end;

procedure TFSimSEEEdit.Label7Click(Sender: TObject);
begin

end;

procedure TFSimSEEEdit.LNPostesClick(Sender: TObject);
begin

end;


procedure TFSimSEEEdit.mConsolaKeyPress(Sender: TObject; var Key: char);
var
  aRecLnk: TCosa_RecLnk;
  aCampoLnk: TCosa_CampoLnk;
  campo, orden, s: string;
  LaCosa: TCosa;
  aCosaH: TCosa;
  k, rescod: integer;
begin
  if key = #13 then
  begin
    s := trim(mComandos.Lines[mComandos.Lines.Count - 1]);
    if LasCosas.Count = 0 then
      LasCosas.add(sala);
    LaCosa := LasCosas[LasCosas.Count - 1];

    aRecLnk := LaCosa.rec_lnk;
    if aRecLnk = nil then
    begin
      wrln('LaCosa.rec_lnk = NIL !!!!! PROBLEMA');
    end;

    orden := NextPal(s);

    if (orden = 'ls') and (s = '') then
    begin
      wrln('Explorando una instancia de:' + LaCosa.ClassName);
      if aRecLnk <> nil then
      begin
        for k := 0 to aRecLnk.Count - 1 do
        begin
          aCampoLnk := aRecLnk[k];
(**** OJO CON ESTO
          aCampoLnk.Devaluar;
          ***)
          wrln(IntToStr(k) + ': ' + aCampoLnk.CampoDef.nombreCampo +
            ' (' + aCampoLnk.CampoDef.ClassName + '), = ' + aCampoLnk.StrVal);
        end;
      end
      else
      begin
        // chequeamos si es una Lista de Cosas.
        if LaCosa is TListaDeCosas then
          for k := 0 to TListaDeCosas(LaCosa).Count - 1 do
          begin
            aCosaH := TCosa(TListaDeCosas(LaCosa)[k]);
            if aCosaH is TCosaConNombre then
              wrln(IntToStr(k) + ' : ' + (aCosaH as TCosaConNombre).nombre +
                ' (' + aCosaH.ClassName + ')')
            else
              wrln(IntToStr(k) + ' : s/n (' + aCosaH.ClassName + ')');
          end;

      end;
    end
    else if (orden = 'ls') and (s = 'clases_registradas') then
    begin
      mConsola.Lines.add('');
      mConsola.Lines.AddStrings(ListarRegistroDeClases);
    end
    else if (orden = 'cd') and (s <> '') then
    begin
      if s = '..' then
      begin
        // Subir al Padre
        if LasCosas.Count = 1 then
          wrln('Ya está en la raíz')
        else
        begin
          LasCosas.Delete(LasCosas.Count - 1);
          LaCosa := LasCosas[LasCosas.Count - 1];
          wrln('La Cosa: ' + LaCosa.InfoAd_20);
        end;
      end
      else if length(s) > 0 then
      begin
        val(s, k, rescod);
        if LaCosa is TListaDeCosas then
        begin
          if rescod = 0 then
            if (0 <= k) and (k < TListaDeCosas(LaCosa).Count) then
              aCosaH := TListaDeCosas(LaCosa)[k]
            else
              aCosaH := nil
          else
          if LaCosa is TListaDeCosasConNombre then
            aCosaH := TListaDeCosasConNombre(LaCosa).find(s)
          else
            wrln('no puede buscar por nombre en una lista de cosas sin nombre');

          if aCosaH <> nil then
          begin
            LasCosas.add(TCosa(aCosaH));
          end
          else
            wrln('No fue posible ubicar la Cosa: ' + s);
        end
        else
        begin
          if rescod = 0 then
          begin
            if (0 <= k) and (k < aRecLnk.Count) then
              aCampoLnk := aRecLnk[k]
            else
              aCampoLnk := nil;
          end
          else
            aCampoLnk := LaCosa.GetFieldByName(s);
          if (aCampoLnk <> nil) then
            if (aCampoLnk.CampoDef.ClassName = 'TCosa_CampoDef_Cosa') then
              if aCampoLnk.pval <> nil then
              begin
                LasCosas.add(TCosa(aCampoLnk.pval^));
                LaCosa := LasCosas[LasCosas.Count - 1];
                wrln('La Cosa: ' + LaCosa.InfoAd_20);
              end
              else
                wrln('COSA = NIL no es posible seleccionarla.')
            else
              wrln('El campo: ' + s + ' no es una Cosa')
          else
            wrln('No logré identificar el campo: ' + s);

        end;
      end;
    end
    else if (orden = 'set') then
    begin
      campo := nextpal(s);
      LaCosa.SetValStr(campo, s, self.sala.evaluador);
    end;
  end;
end;

procedure TFSimSEEEdit.MenuItem1Click(Sender: TObject);
var
  mbResult: integer;
  empaquetar: boolean;
  archi_zip: string;

begin
  empaquetar := guardado;
  if not empaquetar then
  begin
    mbResult := Application.MessageBox(
      PChar(mesSalaNoGuardadaGuardarCambios), PChar(mesSimSEEEdit),
      MB_YESNOCANCEL or MB_ICONEXCLAMATION);
    if mbResult = idYes then
    begin
      MGuardarClick(MGuardar);
      empaquetar := guardado;
    end
    else if mbResult = idNo then
    begin
      empaquetar := True;
    end
    else
    begin
      empaquetar := False;
    end;
  end;

  if empaquetar then
  begin
    archi_zip := uempaquetar.EmpaquetarSalaEnZip(sala.archiSala_, nil);
    if archi_zip <> '' then
      ShowMessage(rs_ArchivoEmpaquetadoConExito + ' ' + archi_zip)
    else
      ShowMessage(rs_ErrorEmpaquetandoArchivo);
  end;

end;

procedure TFSimSEEEdit.MADME_DATAClick(Sender: TObject);
begin
  // acá que habra aplicación ADME_DATA
  ShowMessage(
    'Próximamente usted podrá acceder a los datos del Mercado Mayorista de Energía Eléctrica (MMEE) desde aquí.'
    );
end;

procedure TFSimSEEEdit.MNuevoClick(Sender: TObject);
var
  hacerNuevo: boolean;
  mbResult: integer;
begin
  hacerNuevo := guardado;
  if not guardado then
  begin
    mbResult := Application.MessageBox(
      PChar(mesSalaNoGuardadaGuardarCambios), PChar(mesSimSEEEdit),
      MB_YESNOCANCEL or MB_ICONEXCLAMATION);
    if mbResult = idYes then
    begin
      MGuardarClick(MGuardar);
      hacerNuevo := guardado;
      Sala.globs.abortarSim := guardado;
    end
    else if mbResult = idNo then
    begin
      Sala.globs.abortarSim := True;
      hacerNuevo := True;
    end
    else
    begin
      hacerNuevo := False;
    end;
  end;
  if hacerNuevo then
  begin
    if Sala <> nil then
      LimpiarSala;
    crearSalaIni;
    MemoWarnings.Clear;
    Init;
    self.Caption := AnsiToUtf8('Editor - SimSEE - v' + uversiones.vSimSEEEdit_ +
      ' (GPLv3, IIE-FING )');
  end;
end;

procedure TFSimSEEEdit.intentarCargarDeParametros;
var
  archi: WideString;
begin
  interpreteDeParametros := TInterpreteParametros.Create(False);

  if interpreteDeParametros.ValStr('sala') <> '' then
  begin
    DCargarSala.FileName := AnsiToUTF8(interpreteDeParametros.ValStr('sala'));
    if not FileExists(UTF8ToAnsi(DCargarSala.FileName)) then
    begin
      msgErrorCargandoDeArchivo(mesNoSeEncuentraSalaDeJuego + ' ' +
        DCargarSala.FileName);
      DCargarSala.FileName := '';
    end;
    DCargarManejadorMonitores.FileName :=
      AnsiToUTF8(interpreteDeParametros.ValStr('monitores'));
    if (DCargarManejadorMonitores.FileName <> '') then
      if FileExists(DCargarManejadorMonitores.FileName) then
      begin
        DSalvarManejadorMonitores.FileName := DCargarManejadorMonitores.FileName;
      end
      else
        msgAdvertenciaCargandoDeArchivo
        (mesNoSeEncuentraArchivoMonitores + DCargarManejadorMonitores.FileName);
    abrir;
  end
  else
  if ParamCount > 0 then
  begin
    archi := ParamStr(1);
    if FileExists(archi) then
    begin
      DCargarSala.FileName := AnsiToUTF8(ParamStr(1));
      if ParamCount > 1 then
      begin
        if FileExists(ParamStr(2)) then
        begin
          DCargarManejadorMonitores.FileName := AnsiToUTF8(ParamStr(2));
          DSalvarManejadorMonitores.FileName := DCargarManejadorMonitores.FileName;
        end
        else
          msgAdvertenciaCargandoDeArchivo
          (mesNoSeEncuentraArchivoMonitores + AnsiToUTF8(ParamStr(2)));
      end;
      abrir;
    end
    else
      msgErrorCargandoDeArchivo(mesNoSeEncuentraSalaDeJuego + AnsiToUTF8(ParamStr(1)));
  end;
end;


procedure TFSimSEEEdit.crearSalaIni();
var
  DurPos: TDAofNReal;
begin
  nErroresCargando := 0;
  DCargarSala.FileName := '';
  DSalvarSala.FileName := '';
  DCargarManejadorMonitores.FileName := '';
  DSalvarManejadorMonitores.FileName := '';

  setLength(DurPos, 3);

  durpos[0] := 4;
  durpos[1] := 10;
  durpos[2] := 10;

  Sala := TSalaDeJuego.Create(0, 'sala', StringToFecha('01/01/2009'),
    StringToFecha('01/01/2011'), TFecha.Create_Dt(0), StringToFecha('01/01/2009'),
    StringToFecha('01/01/2011'), DurPos);

  sala.globs.SortearOpt := False;
  Sala.globs.NCronicasOpt := 20;
  Sala.globs.NCronicasSim := 100;
  Sala.globs.TasaDeActualizacion := 0.12;
  rbtEditorSala.SetSala(Sala);
  manejadorMonitores := TManejadoresDeMonitores.Create(0, self.sala);
end;

procedure TFSimSEEEdit.abrir();
var
  f: TarchiTexto;
  mbResult: integer;
  archi: WideString;
  filePath: WideString;
begin
  if Sala <> nil then
    LimpiarSala;

  nErroresCargando := 0;
  MemoWarnings.Clear;

  archi := Utf8ToAnsi(DCargarSala.FileName);
  filePath:= extractFilePath(archi);
  chdir( filePath );

  f := TArchiTexto.CreateForRead(0, rbtEditorSala.CatalogoReferencias, archi, False);
  try
    f.rd('sala', TCosa(sala));
  finally
    f.Free;
  end;

  if sala = nil then
    raise Exception.Create(exNoFuePosibleLeerSala);

  // le creo un evaluador a la sala.
  sala.evaluador := TEvaluadorConCatalogo.Create(rbtEditorSala.CatalogoReferencias);

  sala.setDirCorrida(archi);
  rbtEditorSala.SetSala(sala);

  if rbtEditorSala.resolverReferenciasContraSala(False) > 0 then
  begin
    MessageDlg('No se pudo resolver todas las asociaciones entre los actores' +
      ' de la sala, por lo que no se cargará. Puede ver la lista de ' +
      'referencias que no pudieron resolverse en el siguiente ' +
      'archivo: ' + getDir_Run + 'errRefs.txt', mtError, [mbOK], 0);
    rbtEditorSala.CatalogoReferencias.DumpReferencias(getDir_Run + 'errRefs.txt');
    LimpiarSala;
    rbtEditorSala.CatalogoReferencias.LimpiarReferencias;
    Init;
    Exit;
  end;

  {$IFDEF MONITORES}
  if not guardadoMonitores then
  begin
    mbResult := Application.MessageBox(
      PChar(mesMonitoresNoGuardadosGuardarCambios), PChar(mesSimSEEEdit),
      MB_YESNOCANCEL or MB_ICONEXCLAMATION);
    if mbResult = idYes then
      guardarMonitores;
  end;

  if manejadorMonitores <> nil then
  begin
    LimpiarManejadorMonitores;
    DCargarManejadorMonitores.FileName := '';
    DSalvarManejadorMonitores.FileName := '';
  end;

  if FileExists(utilidades.titulo(archi) + '.mon') then
  begin
    DCargarManejadorMonitores.FileName :=
      utilidades.titulo(archi) + '.mon';
    DSalvarManejadorMonitores.FileName := DCargarManejadorMonitores.FileName;
    abrirMonitores;
  end
  else
    manejadorMonitores := TManejadoresDeMonitores.Create(0, sala);
  {$ENDIF}

  Init;

  DSalvarSala.FileName := DCargarSala.FileName;
  self.Caption := AnsiToUtf8('Editor - SimSEE - v' + uversiones.vSimSEEEdit_ +
    ' (GPLv3, IIE-FING) - ' + ExtractFileName(archi));

  cargarListados;

  if nErroresCargando > 0 then
    ShowMessage(
      mesArchivoSalaContieneErrores + #10 + mesSeLogroCargarSalaConProblemas +
      #10 + mesAntesDeGuardarAsegureseContieneTodaInfo);

end;

procedure TFSimSEEEdit.cargarListados;
var
  TipoActor: TClass;
  i, indiceTab: integer;
begin
  // Limpio lo que hubiera
  for i := 0 to high(ListasDeActoresTabs) do
    ListasDeActoresTabs[i].Clear;

  // Agrego los nodos a los listados
  if Sala.Nods.Count > 0 then
  begin
    TipoActor := Sala.Nods[0].ClassType;
    indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
    for i := 0 to Sala.Nods.Count - 1 do
    begin
      if TipoActor <> Sala.Nods[i].ClassType then
      begin
        TipoActor := Sala.Nods[i].ClassType;
        indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
      end;
      ListasDeActoresTabs[indiceTab].Add(Sala.Nods[i] as TActor);
    end;
  end;

  // Agrego las Demandas a los listados
  if Sala.Dems.Count > 0 then
  begin
    TipoActor := Sala.Dems[0].ClassType;
    indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
    for i := 0 to Sala.Dems.Count - 1 do
    begin
      if TipoActor <> Sala.Dems[i].ClassType then
      begin
        TipoActor := Sala.Dems[i].ClassType;
        indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
      end;
      ListasDeActoresTabs[indiceTab].Add(Sala.Dems[i] as TActor);
    end;
  end;

  // Agrego los Generadores a los listados
  if Sala.Gens.Count > 0 then
  begin
    TipoActor := Sala.Gens[0].ClassType;
    indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
    for i := 0 to Sala.Gens.Count - 1 do
    begin
      if TipoActor <> Sala.Gens[i].ClassType then
      begin
        TipoActor := Sala.Gens[i].ClassType;
        indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
      end;
      ListasDeActoresTabs[indiceTab].Add(Sala.Gens[i] as TActor);
    end;
  end;

  // Agrego los Arcos a los listados
  if Sala.Arcs.Count > 0 then
  begin
    TipoActor := Sala.Arcs[0].ClassType;
    indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
    for i := 0 to Sala.Arcs.Count - 1 do
    begin
      if TipoActor <> Sala.Arcs[i].ClassType then
      begin
        TipoActor := Sala.Arcs[i].ClassType;
        indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
      end;
      ListasDeActoresTabs[indiceTab].Add(Sala.Arcs[i] as TActor);
    end;
  end;

  // Agrego los Contratos Energéticos a los listados
  if Sala.ComercioInternacional.Count > 0 then
  begin
    TipoActor := Sala.ComercioInternacional[0].ClassType;
    indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
    for i := 0 to Sala.ComercioInternacional.Count - 1 do
    begin
      if TipoActor <> Sala.ComercioInternacional[i].ClassType then
      begin
        TipoActor := Sala.ComercioInternacional[i].ClassType;
        indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
      end;
      ListasDeActoresTabs[indiceTab].Add(Sala.ComercioInternacional[i] as TActor);
    end;
  end;

  // Agrego los Suministradores de Combustible
  if Sala.sums.Count > 0 then
  begin
    TipoActor := Sala.sums[0].ClassType;
    indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
    for i := 0 to Sala.sums.Count - 1 do
    begin
      if TipoActor <> Sala.sums[i].ClassType then
      begin
        TipoActor := Sala.sums[i].ClassType;
        indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
      end;
      ListasDeActoresTabs[indiceTab].Add(Sala.sums[i] as TActor);
    end;
  end;

  // Agrego los Usos Gestionables
  if Sala.UsosGestionables.Count > 0 then
  begin
    TipoActor := Sala.UsosGestionables[0].ClassType;
    indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
    for i := 0 to Sala.UsosGestionables.Count - 1 do
    begin
      if TipoActor <> Sala.UsosGestionables[i].ClassType then
      begin
        TipoActor := Sala.UsosGestionables[i].ClassType;
        indiceTab := uInfoTabs.infoTabs_.indiceTabDeTipo_(TipoActor);
      end;
      ListasDeActoresTabs[indiceTab].Add(Sala.UsosGestionables[i] as TActor);
    end;
  end;

  TCActores_Change(TCActores_);
end;

procedure TFSimSEEEdit.guardar;
var
  f: TArchiTexto;
  dirTemporales: array [0 .. MAX_PATH] of char;
  archi: WideString;
begin
  // Saco el foco del control activo para que haga el onExit y guarde los cambios
  // si hace falta
  // Tengo que hacerlo así porque no permite hacer setFocus en controles invisibles
  // Si la pagina activa no es alguna de estas no importa porque no tienen controles
  // que necesiten perder el foco para guardar sus cambios
  if PCEditMain.ActivePage = ts_Globales then
    rg_HorariaOMinutal.SetFocus
  else if PCEditMain.ActivePage = ts_Estado then
    CBEstabilizarFrameInicial.SetFocus
  else if PCEditMain.ActivePage = ts_Simulador then
    CBObligar_Disp1_Sim.SetFocus;

  dirTemporales := GetTempDir;
  // GetTempPath(MAX_PATH, @dirTemporales);
  f := TArchiTexto.CreateForWrite(dirTemporales + 'guardar_temp.ese', False, 0);
  try
    begin
      // Salvo en un archivo auxiliar para no corromper el original si hay problemas
      f.wr('sala', TSalaDeJuego(sala));
      f.Free;

      archi := Utf8ToAnsi(DSalvarSala.FileName);
      f := TArchiTexto.CreateForWrite(
        archi, TSimSEEEditOptions.getInstance.guardarBackupDeArchivos,
        TSimSEEEditOptions.getInstance.maxNBackups);
      f.wr('sala', TSalaDeJuego(sala));
      guardado := True;
      DCargarSala.FileName := DSalvarSala.FileName;
      sala.setDirCorrida(archi);
    end
  finally
    f.Free;
  end;
end;

procedure TFSimSEEEdit.abrirMonitores;
var
  error: string;
begin
  if manejadorMonitores <> nil then
    LimpiarManejadorMonitores;

  try
    manejadorMonitores := TManejadoresDeMonitores.CargarManejadorDeMonitores
      (DCargarManejadorMonitores.FileName, False, sala);

    InitMonitores();
    DSalvarManejadorMonitores.FileName := DCargarManejadorMonitores.FileName;
  except
    on E: Exception do
      raise;
  end;

  try
    manejadorMonitores.resolverReferenciasMonitores(TTodas);
  except
    on E: Exception do
    begin
      error := e.Message;

      while error <> '' do
        MemoWarnings.Lines.Add(NextStr(error));
    end;
  end;
  manejadorMonitores.limpiar;
end;

procedure TFSimSEEEdit.guardarMonitores;
var
  f: TArchiTexto;
  dirTemporales: array [0 .. MAX_PATH] of char;
begin
  if ActiveControl is TEdit and assigned(TEdit(ActiveControl).onExit) then
    TEdit(ActiveControl).onExit(ActiveControl);

  dirTemporales := GetTempDir;
  //GetTempPath(MAX_PATH, @dirTemporales);
  f := TArchiTexto.CreateForWrite(dirTemporales + 'guardarMonitores_temp.ese', False, 0);
  try
    begin
      // Guardo en un archivo auxiliar para no corromper el original si hay problemas
      f.wr('manejadorMonitores', manejadorMonitores);
      f.Free;

      f := TArchiTexto.CreateForWrite(DSalvarManejadorMonitores.FileName,
        TSimSEEEditOptions.getInstance.guardarBackupDeArchivos,
        TSimSEEEditOptions.getInstance.maxNBackups);
      f.wr('manejadorMonitores', manejadorMonitores);
      guardadoMonitores := True;
      DCargarManejadorMonitores.FileName := DSalvarManejadorMonitores.FileName;
    end
  finally
    f.Free;
  end;
end;

procedure TFSimSEEEdit.LoadFormulario_SALAyGLOBS;
var
  nPostes, i: integer;
  DurPaso: NReal;
  aux_s: string;

begin

  //  eFechaIniSim.Text := Sala.globs.GetValStr('fechaIniSim' );
  eFechaIniSim.Text := Sala.globs.fechaIniSim.AsStr;
  eFechaFinSim.Text := Sala.globs.fechaFinSim.AsStr;
  eFechaGuardaSim.Text := Sala.globs.fechaGuardaSim.asStr;
  eFechaIniOpt.Text := Sala.globs.fechaIniOpt.AsStr;
  eFechaFinOpt.Text := Sala.globs.fechaFinOpt.AsStr;
  eHusoHorario_UTC.Text := FloatToStr(Sala.Globs.husoHorario_UTC);
  nPostes := Sala.globs.NPostes;

  IntNPostes.Text := IntToStr(nPostes);
  sgPostes.ColCount := nPostes + 1;
  utilidades.AutosizeTableWidth(sgPostes);
  for i := 0 to nPostes - 1 do
  begin
    sgPostes.Cells[i + 1, 0] := IntToStr(i + 1);
    sgPostes.Cells[i + 1, 1] := FloatToStr(Sala.globs.DurPos[i]);
  end;

  CBPostesMonotonos.Checked := sala.globs.PostesMonotonos;
  if sala.globs.SalaMinutal then
  begin
    rg_HorariaOMinutal.ItemIndex := 1;
    panel_durpaso_minutal.Visible := True;
    panel_durpos_horaria.Visible := False;
  end
  else
  begin
    rg_HorariaOMinutal.ItemIndex := 0;
    panel_durpaso_minutal.Visible := False;
    panel_durpos_horaria.Visible := True;
  end;
  eDurPaso_Minutos.Text := IntToStr(trunc(sala.globs.DurPaso_minutos));

  durPaso := 0;
  for i := 1 to nPostes do
    DurPaso := DurPaso + StrToFloat(sgPostes.Cells[i, 1]);
  EDurPaso.Text := FloatToStr(durPaso);
  recalcNumeroPasos(IntNPostes);

  CBEstabilizarFrameInicial.Checked := sala.estabilizarInicio;
  if sala.usarArchivoParaInicializarFrameInicial = 1 then
  begin
    RGLlenarUltimoFrame.ItemIndex := 1;
    EArchivoCF.Enabled := True;
    BBuscarArchivoCF.Enabled := True;
    BEnganches.Enabled := True;
    cb_enganchar_promediando_desaparecidas.Enabled := True;
  end
  else
  begin
    RGLlenarUltimoFrame.ItemIndex := sala.usarArchivoParaInicializarFrameInicial;
    EArchivoCF.Enabled := False;
    BBuscarArchivoCF.Enabled := False;
    BEnganches.Enabled := False;
    cb_enganchar_promediando_desaparecidas.Enabled := False;
  end;

  self.eArchiCFaux.Text := sala.archivoCFAux.archi;

  if (sala.engancharConSala) then
  begin
    RBElegirSala.Checked := True;
    EArchivoCF.Text := sala.archivoSala_ParaEnganches.archi;
  end
  else
  begin
    RBElegirCF.Checked := True;
    EArchivoCF.Text := sala.archivoCF_ParaEnganches.archi;
  end;
  cbGenerarRaws.Checked := sala.GenerarRaws;
  cb_enganchar_promediando_desaparecidas.Checked :=
    sala.enganchar_promediando_desaparecidas;
  aux_s := sala.uniformizar_promediando;
  eUniformizarPromediando.Text := aux_s; // mmm el on_change se comía la cola

  ENCronicasSim.Text := IntToStr(Sala.globs.NCronicasSim);
  ENCronicasOpt.Text := IntToStr(Sala.globs.NCronicasOpt);
  cbUsarIteradorFlucar.Checked := sala.usarIteradorFlucar;
  CBSorteos.Checked := Sala.globs.SortearOpt;
  ENCronicasOpt.Enabled := CBSorteos.Checked;
  CBObligar_Disp1_Sim.Checked := Sala.globs.ObligarDisponibilidad_1_Sim;
  cbObligarInicioCronicaIncierto.Checked :=
    Sala.globs.ObligarInicioCronicaIncierto_1_Sim;
  CBObligar_Disp1_Opt.Checked := Sala.globs.ObligarDisponibilidad_1_Opt;
  cbEmisionesCO2.Checked := Sala.globs.Calcular_EmisionesCO2;
  cb_CO2_ProyectoTipoSolarEolico.Checked :=
    sala.globs.FactorEmisiones_ProyectoEolicoSolar;
  rg_FactorEmisiones_MargenOperativoTipo.ItemIndex :=
    sala.globs.FactorEmisiones_MargenOperativoTipo;
  EtAct.Text := FloatToStrF(sala.globs.TasaDeActualizacion, ffGeneral,
    CF_PRECISION, CF_DECIMALES);
  eMaxNItersOpt.Text := IntToStr(sala.globs.NMAX_ITERACIONESDELPASO_OPT);
  eMaxNItersSim.Text := IntToStr(sala.globs.NMAX_ITERACIONESDELPASO_SIM);

  EArchivo_Flucar.Text := Sala.globs.iteracion_flucar_Archivo_Flucar;
  cbModificarRendimiento.Checked := Sala.globs.iteracion_flucar_modificar_rendimiento;
  cbModificarCapacidad.Checked := Sala.globs.iteracion_flucar_modificar_capacidad;
  cbModificarPeaje.Checked := Sala.globs.iteracion_flucar_modificar_peaje;

  cbAversionAlRiesgo.Checked := sala.globs.usar_CAR;
  cbRestarUtilidadesDeCF.Checked := sala.globs.restarUtilidadesDelCostoFuturo;
  cbConsiderarPagosEnCF.Checked := sala.flg_IncluirPagosPotenciaYEnergiaEn_CF;
  eNDiscHisto.Text := IntToStr(sala.globs.NDiscHistoCF);
  eLimiteProbabilidad.Text :=
    FloatToStrF(sala.globs.probLimiteRiesgo, ffGeneral, CF_PRECISION, CF_DECIMALES);
  eCAR.Text := FloatToStrF(sala.globs.CAR, ffGeneral, CF_PRECISION, CF_DECIMALES);
  rb_CVaR.Checked := sala.globs.CAR_CVaR;
  rb_VaR.Checked := not sala.globs.CAR_CVaR;

  cbPublicarSoloVariablesUsadasEnSimRes3.Checked :=
    sala.globs.publicarSoloVariablesUsadasEnSimRes3;

  if sala.globs.Deterministico then
    rbTipoOptimizacion.ItemIndex := 1
  else
    rbTipoOptimizacion.ItemIndex := 0;

  eSemillaINicial_opt.Text := IntToStr(sala.globs.semilla_inicial_opt);
  eSemillaINicial_sim.Text := IntToStr(sala.globs.semilla_inicial_sim);

  cbReservaRotante.Checked := sala.globs.flg_ReservaRotante;
  rgModoEjecucion.ItemIndex := sala.modo_Ejecucion;

  MemoDesc.Clear;
  MemoDesc.Lines.DelimitedText := sala.descripcion;
  loQueHabia := MemoDesc.Lines.DelimitedText;
end;

procedure TFSimSEEEdit.Init;

begin
  if sala <> nil then
  begin
    //    archiEditorSimRes3 := '';
    MGuardar.Enabled := True;
    MGuardarComo.Enabled := True;
    MHerramientas.Enabled := True;
    MMonitores.Enabled := True;
    TCActores_.Visible := True;
    PCEditMain.Visible := True;

    LoadFormulario_SALAyGLOBS;

    guardado := True;
    Sala.Prepararse_(rbtEditorSala.CatalogoReferencias);
    sala.publicarTodasLasVariables;

    {$IfDef MONITORES}
    manejadorMonitores.PrepararseYPubliVars;
    {$EndIf}

    PCEditMainChange(Self);
  end
  else
  begin
    MGuardar.Enabled := False;
    MGuardarComo.Enabled := False;
    MHerramientas.Enabled := False;
    MMonitores.Enabled := False;
    TCActores_.Visible := False;
    PCEditMain.Visible := False;
    cbAversionAlRiesgo.Checked := False;
    eNDiscHisto.Text := IntToStr(20);
    eLimiteProbabilidad.Text := FloatToStrF(0.05, ffGeneral, CF_PRECISION, CF_DECIMALES);
    eCAR.Text := FloatToStrF(1, ffGeneral, CF_PRECISION, CF_DECIMALES);
    rbTipoOptimizacion.ItemIndex := 0;
    eSemillaINicial_opt.Text := IntToStr(31);
    eSemillaINicial_sim.Text := IntToStr(31);
  end;
end;

procedure TFSimSEEEdit.InitMonitores;
begin
  PCEditMainChange(Self);
  guardadoMonitores := True;
end;

{ function TFSimSEEEdit.prepararSala(fecha: TFecha ; paso, horasDelPaso: Integer): Integer;
  var
  pasoDeFecha: Integer;
  i: integer;
  begin
  if paso = 1 then
  begin
  sala.globs.Fijar_kPaso( paso );
  sala.Prepararse( true ); // Preparar para editar
  end;
  pasoDeFecha:= sala.globs.fechaToPaso(fecha);
  while (sala.globs.kPaso_ <= pasoDeFecha) do
  begin
  Sala.prepararSalaParaPaso;
  for i:= 0 to sala.Dems.Count -1 do
  TActor(sala.Dems[i]).PrepararPaso_ps;
  sala.globs.FechaInicioDelPaso.AddHoras( HorasDelPaso );
  inc( sala.globs.kPaso_ );
  end;
  result:= sala.globs.kPaso_;
  end;

  procedure TFSimSEEEdit.manejarExcepcionPrepararSala(e: Exception);
  begin
  ShowMessage('Se Encontro el Siguiente Error:' + #13 + e.Message + #13 + 'Resuelvalo para Poder Continuar.');
  end; }

function TFSimSEEEdit.validarFechasOptSim: boolean;
begin
  // fIniOpt <= fIniSim <= fFinSim <= fFinOpt
  if (sala.globs.FechaIniOpt.dt <= sala.globs.FechaIniSim.dt) and
    (sala.globs.FechaIniSim.dt <= sala.globs.FechaFinSim.dt) and
    (sala.globs.FechaFinSim.dt <= sala.globs.FechaFinOpt.dt) then
  begin
    Result := True;
  end
  else
  begin
    ShowMessage(mesHorizontesSimulacionNoValidos + #13#10 +
      mesSeDebeCumplirRelacionHorizontes);
    Result := False;
  end;
end;

function TFSimSEEEdit.validarFormulario: boolean;
begin
  Result := validarFechasOptSim and inherited validarEditInt(IntNPostes, 1,
    MaxInt) and inherited validarEditInt(ENCronicasOpt, 1, MaxInt) and
    inherited validarEditFloat(EtAct, 0, MaxInt) and
    inherited validarEditInt(eMaxNItersOpt, 0, MaxInt) and
    inherited validarEditInt(TEdit(ENCronicasSim), 1, MaxInt) and
    inherited validarEditInt(eMaxNItersSim, 0, MaxInt);
end;

constructor TFSimSEEEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TFSimSEEEdit.MAbrirClick(Sender: TObject);
var
  mbResult: integer;
begin
  if (not guardado) then
  begin
    mbResult := Application.MessageBox(
      PChar(mesSalaNoGuardadaGuardarCambios), PChar(mesSimSEEEdit),
      MB_YESNOCANCEL or MB_ICONEXCLAMATION);
    if mbResult = idYes then
    begin
      guardar;
      if self.DCargarSala.Execute then
        abrir;
    end
    else if mbResult = idNo then
      if self.DCargarSala.Execute then
        abrir;
  end
  else if self.DCargarSala.Execute then
    abrir;
end;

procedure TFSimSEEEdit.MActualizarClick(Sender: TObject);
var
  parametros: array of string;
begin
  ChDir(getDir_Bin);
  setlength(parametros, 0);
  RunChildAndWAIT('actualizador', parametros);
end;


procedure TFSimSEEEdit.MGuardarComoClick(Sender: TObject);
begin
  if self.DSalvarSala.Execute then
  begin

    DCargarSala.FileName := DSalvarSala.FileName;
    self.Caption := AnsiToUtf8('Editor - SimSEE - v' + uversiones.vSimSEEEdit_ +
      ' (GPLv3, IIE-FING) - ' + ExtractFileName(DCargarSala.FileName));
    guardar();
  end;
end;

procedure TFSimSEEEdit.MGuardarClick(Sender: TObject);
begin
  if DSalvarSala.FileName = '' then
    MGuardarComoClick(Sender)
  else
    guardar();
end;

procedure TFSimSEEEdit.MSalirClick(Sender: TObject);
begin
  Close;
end;

procedure TFSimSEEEdit.MSoporteUsuariosClick(Sender: TObject);
begin
  SistemaDeSoporteAUsuarios(Self);
end;

procedure TFSimSEEEdit.N2Click(Sender: TObject);
begin

end;


procedure TFSimSEEEdit.rbTipoOptimizacionClick(Sender: TObject);
begin
  modificado := True;
  Sala.globs.Deterministico := rbTipoOptimizacion.ItemIndex = 1;
end;

procedure TFSimSEEEdit.rb_CVaRClick(Sender: TObject);
begin
  modificado := True;
  Sala.globs.CAR_CVaR := rb_CVaR.Checked;
end;

procedure TFSimSEEEdit.rgModoEjecucionClick(Sender: TObject);
begin
  modificado := True;
  sala.modo_Ejecucion := rgModoEjecucion.ItemIndex;
end;

procedure TFSimSEEEdit.rg_FactorEmisiones_MargenOperativoTipoClick(Sender: TObject);
begin
  modificado := True;
  sala.globs.FactorEmisiones_MargenOperativoTipo :=
    rg_FactorEmisiones_MargenOperativoTipo.ItemIndex;
end;

procedure TFSimSEEEdit.RBElegirCFChange(Sender: TObject);
begin
  if (RBElegirCF.Checked = True) then
  begin
    sala.engancharConSala := False;
    EArchivoCF.Text := sala.archivoCF_ParaEnganches.archi;
    sala.archivoSala_ParaEnganches.archi := '';
  end;
  guardado := False;
end;

procedure TFSimSEEEdit.RBElegirSalaChange(Sender: TObject);
begin
  if (RBElegirSala.Checked = True) then
  begin
    sala.engancharConSala := True;
    EArchivoCF.Text := sala.archivoSala_ParaEnganches.archi;
    sala.archivoCF_ParaEnganches.archi := ''; //limpio el otro
  end;
  guardado := False;
end;

procedure TFSimSEEEdit.rg_HorariaOMinutalClick(Sender: TObject);
begin
  if rg_HorariaOMinutal.ItemIndex = 0 then
  begin
    sala.globs.SalaMinutal := False;
    panel_durpaso_minutal.Visible := False;
    panel_durpos_horaria.Visible := True;
  end
  else
  begin
    sala.globs.SalaMinutal := True;
    panel_durpaso_minutal.Visible := True;
    panel_durpos_horaria.Visible := False;
  end;
end;

procedure TFSimSEEEdit.sgPostesGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  utilidades.listadoGetEditText(Sender, ACol, ARow);
end;

procedure TFSimSEEEdit.sgPostesKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
var
  senderAsGrid: TStringGrid;
begin
  senderAsGrid := Sender as TStringGrid;
  validarSg := senderAsGrid.Cells[senderAsGrid.col, senderAsGrid.Row] <> loQueHabia;
  if (Key in teclas) then
    validarCambioTablaPostes(TStringGrid(Sender));
end;

procedure TFSimSEEEdit.sgPostesValidarCambio(Sender: TObject);
begin
  validarCambioTablaPostes(TStringGrid(Sender));
end;


procedure TFSimSEEEdit.sgMantenimientosGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  utilidades.listadoGetEditText(Sender, ACol, ARow);
end;

procedure TFSimSEEEdit.TCActores_Change(Sender: TObject);
begin
  actualizarTablaActores;
end;

procedure TFSimSEEEdit.BAgregarActorClick(Sender: TObject);
begin
  altaActor(TCActores_.Tabs[TCActores_.tabindex]);
end;

procedure TFSimSEEEdit.sgActoresDrawCell(Sender: TObject; ACol, ARow: integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, TiposColActores[ACol], nil,
    iconos);
end;

procedure TFSimSEEEdit.sgActoresMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFSimSEEEdit.sgActoresMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, TiposColActores);
end;

procedure TFSimSEEEdit.sgActoresMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, TiposColActores);
  case res of
    TC_btEditar:
      editarActor(
        TActor(ListasDeActoresTabs[TCActores_.tabindex][utilidades.filaListado - 1])
        );
    TC_btEliminar:
      eliminarActor
      (TActor(ListasDeActoresTabs[TCActores_.tabindex][utilidades.filaListado - 1]));
    TC_btClonar:
      clonarActor(TActor(ListasDeActoresTabs[TCActores_.tabindex]
        [utilidades.filaListado - 1])
        );
  end;
end;

procedure TFSimSEEEdit.EditNCronicasSimExit(Sender: TObject);
begin
  if validarEditInt(Sender as TEdit, 1, MAXINT) then
    sala.globs.NCronicasSim := StrToInt(TEdit(Sender).Text);
end;

procedure TFSimSEEEdit.btEjecutarManualmenteClick(Sender: TObject);
var
  resultado: integer;
  aux: boolean;
  parametros: array of string;
  dondeEstaba: string;
begin
  aux := guardado;
  if validarFormulario then
  begin
    sala.globs.NCronicasOpt := StrToInt(ENCronicasOpt.Text);
    Sala.globs.TasaDeActualizacion := StrToFloat(EtAct.Text);
    sala.globs.NCronicasSim := StrToInt(ENCronicasSim.Text);
    sala.globs.abortarSim := False;

    guardado := aux;

    if not guardado then
    begin
      resultado := Application.MessageBox(
        PChar(mesGuardarCambiosSalaParaContinuar), PChar(mesSimSEEEdit), MB_YESNOCANCEL);
      if resultado = idYes then
        MGuardarComoClick(MGuardarComo)
      else if resultado = idCancel then
        exit;
    end;
    if not guardadoMonitores then
    begin
      resultado := Application.MessageBox(
        PChar(mesGuardarCambiosMonitoresParaContinuar), PChar(mesSimSEEEdit),
        MB_YESNOCANCEL);
      if resultado = idYes then
        MGuardarMonitoresComoClick(MGuardarMonitoresComo)
      else if resultado = idCancel then
        exit;
    end;
    if guardado and guardadoMonitores then
    begin
      getdir(3, dondeEstaba);
      ChDir(getDir_Bin);

      setlength(parametros, 3);
      parametros[0] := 'sala="' + Self.DCargarSala.fileName + '"';
      parametros[1] := 'monitores="' + self.DCargarManejadorMonitores.fileName + '"';
      parametros[2] := 'escenario="' + sala.EscenarioActivo.nombre + '"';
      RunChild('SimSEESimulador', parametros, False);

      ChDir(dondeEstaba);
    end;
  end
  else
    guardado := aux;
end;

procedure TFSimSEEEdit.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  mbResult: integer;
begin
  if ActiveControl is TEdit and assigned(TEdit(ActiveControl).OnExit) then
    TEdit(ActiveControl).OnExit(ActiveControl)
  else if ActiveControl is TStringGrid and
    assigned(TStringGrid(ActiveControl).onExit) then
    TStringGrid(ActiveControl).OnExit(ActiveControl);
  if (not guardado) then
  begin
    mbResult := Application.MessageBox(
      PChar(mesSalaNoGuardadaGuardarCambios), PChar(mesSimSEEEdit),
      MB_YESNOCANCEL or MB_ICONEXCLAMATION);
    if mbResult = idYes then
    begin
      MGuardarClick(MGuardar);
      CanClose := guardado;
    end
    else if mbResult = idNo then
    begin
      CanClose := True;
    end
    else
    begin
      CanClose := False;
    end;
  end;
  if (not guardadoMonitores) then
  begin
    mbResult := Application.MessageBox(
      PChar(mesMonitoresNoGuardadosGuardarCambios), PChar(mesSimSEEEdit),
      MB_YESNOCANCEL or MB_ICONEXCLAMATION);
    if mbResult = idYes then
    begin
      MGuardarMonitoresClick(MGuardarMonitoresComo);
      CanClose := guardado;
    end
    else if mbResult = idNo then
    begin
      CanClose := True;
    end
    else
    begin
      CanClose := False;
    end;
  end;
  if CanClose then
    TSimSEEEditOptions.getInstance.guardar;
end;

procedure TFSimSEEEdit.sgMonitoresDrawCell(Sender: TObject; ACol, ARow: integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    TiposColMonitores[ACol], nil,
    iconos);
end;

procedure TFSimSEEEdit.sgMonitoresMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, TiposColMonitores);
end;

procedure TFSimSEEEdit.sgMonitoresMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFSimSEEEdit.sgMonitoresMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, TiposColMonitores);
  case res of
    TC_checkBox:
    begin
      if sgMonitores.Cells[utilidades.colListado, utilidades.filaListado] = '' then
        TReferenciaMonitor
        (manejadorMonitores.referenciasMonitores[utilidades.filaListado - 1])
          .Enabled := False
      else
        TReferenciaMonitor
        (manejadorMonitores.referenciasMonitores[utilidades.filaListado - 1])
          .Enabled := True;
    end;
    TC_btEditar:
      editarMonitor(utilidades.filaListado, False);
    TC_btEliminar:
      eliminarMonitor(utilidades.filaListado);
    TC_btClonar:
      editarMonitor(utilidades.filaListado, True);
  end;
end;

procedure TFSimSEEEdit.BAgregarFichaUnidadesClick(Sender: TObject);
begin
  altaMantenimiento;
end;

procedure TFSimSEEEdit.BAgregarMonitorClick(Sender: TObject);
begin
  altaMonitor;
end;

procedure TFSimSEEEdit.BBuscarArchivoCFClick(Sender: TObject);
begin

  if (RBElegirCF.Checked = True) then
  begin
    ODCF.InitialDir := getDir_Run;
    ODCF.Filter :=
      'Archivos Binarios de Costos Futuros (*.bin)|*.bin|Todos los Archivos (*.*)|*.*';
  end
  else
  begin
    ODCF.InitialDir := getDir_Corridas;
    ODCF.Filter := 'Archivos SimSEEEdit (*.ese)|*.ese|Todos los Archivos (*.*)|*.*';
  end;

  if ODCF.Execute then
  begin
    EArchivoCF.Text := ODCF.FileName;
    EArchivoCFExit(BBuscarArchivoCF);
  end;
end;

procedure TFSimSEEEdit.BCrearMonitorSimRes3PDefectoClick(Sender: TObject);
begin
  crearMonitorSimResPorDefecto;
end;

procedure TFSimSEEEdit.recalcNumeroPasos(Sender: TObject);
begin
  Sala.globs.HorasDelPaso := StrToFloat(EDurPaso.Text);
  ENPasosSim.Text := IntToStr(Sala.globs.calcNPasosSim);
  ENPasosOpt.Text := IntToStr(Sala.globs.calcNPasosOpt);
end;

procedure TFSimSEEEdit.MManualClick(Sender: TObject);
begin
  verdoc(self, 'editor-manualdeusuario', 'Manual de Usuario del Editor');
end;

procedure TFSimSEEEdit.CBSorteosClick(Sender: TObject);
begin
  guardado := False;
  ENCronicasOpt.Enabled := CBSorteos.Checked;
  LNCronicasOpt.Enabled := CBSorteos.Checked;
  Sala.globs.SortearOpt := CBSorteos.Checked;
end;

procedure TFSimSEEEdit.EtActExit(Sender: TObject);
begin
  if validarEditFloat(EtAct, 0, MAXINT) then
    Sala.globs.TasaDeActualizacion := StrToFloat(EtAct.Text);
end;

procedure TFSimSEEEdit.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TFSimSEEEdit.EditNCronicasOptExit(Sender: TObject);
begin
  if validarEditInt(TEdit(Sender), 1, MAXINT) then
    Sala.globs.NCronicasOpt := StrToInt(TEdit(Sender).Text);
end;



procedure TFSimSEEEdit.EArchivoCFExit(Sender: TObject);
var
  CF: TAdminEstados;
begin
  if loQueHabia <> EArchivoCF.Text then
  begin
    if FileExists(EArchivoCF.Text) then
    begin
      if (RBElegirSala.Checked = True) then
      begin
        sala.archivoSala_ParaEnganches.archi := EArchivoCF.Text;
        sala.engancharConSala := True;
      end
      else
      begin
        sala.archivoCF_ParaEnganches.archi := EArchivoCF.Text;
        sala.engancharConSala := False;
      end;

      guardado := False;

      if (RBElegirCF.Checked = True) then
      begin
        CF := TAdminEstados.CreateLoadFromArchi(EArchivoCF.Text);
        CF.Free;
      end;
    end
    else
      ShowMessage(mesElArchivo + EArchivoCF.Text + mesNoExiste);
  end;
end;


procedure TFSimSEEEdit.DTPEnter(Sender: TObject);
begin
  loQueHabia := SysUtils.DateToStr(TDateEdit(Sender).Date);
end;

procedure TFSimSEEEdit.DTPFechaFinOptChange(Sender: TObject);
begin
  try
    sala.globs.fechaFinOpt.PonerIgualA(trim(eFechaFinOpt.Text));
    Sala.globs.HorasDelPaso := StrToFloat(EDurPaso.Text);
    ENPasosOpt.Text := IntToStr(Sala.globs.calcNPasosOpt);
    guardado := False;
    TEdit(Sender).color := clDefault;
  except
    TEdit(Sender).Color := clRed;
  end;
end;

procedure TFSimSEEEdit.DTPFechaFinSimChange(Sender: TObject);
begin
  try
    sala.globs.fechaFinSim.PonerIgualA(trim(eFechaFinSim.Text));
    Sala.globs.HorasDelPaso := StrToFloat(EDurPaso.Text);
    ENPasosSim.Text := IntToStr(Sala.globs.calcNPasosSim);
    guardado := False;

    TEdit(Sender).color := clDefault;
  except
    TEdit(Sender).Color := clRed;
  end;
end;

procedure TFSimSEEEdit.DTPFechaIniOptChange(Sender: TObject);
begin
  try
    sala.globs.fechaIniOpt.PonerIgualA(trim(eFechaIniOpt.Text));
    Sala.globs.HorasDelPaso := StrToFloat(EDurPaso.Text);
    ENPasosOpt.Text := IntToStr(Sala.globs.calcNPasosOpt);
    guardado := False;
    TEdit(Sender).color := clDefault;
  except
    TEdit(Sender).Color := clRed;
  end;

end;


procedure TFSimSEEEdit.MExportarClick(Sender: TObject);
var
  form: TFormExportar;
begin
  form := TFormExportar.Create(self, Sala.ListaActores, Sala.listaFuentes_);
  if form.ShowModal = mrOk then
    cargarListados;
  form.Free;

end;

procedure TFSimSEEEdit.MImportarClick(Sender: TObject);
begin
  if DImportarActor.Execute then
    importar;
end;

procedure TFSimSEEEdit.PCEditMainChange(Sender: TObject);
var
  i: integer;
begin
  if PCEditMain.ActivePage = ts_AyudaSolaperoPrincipal then
  begin
    verdoc(self, 'editor-solaperoPrincipal', '');
    PCEditMain.ActivePage := ts_Globales;
  end
  else if PCEditMain.ActivePage = ts_Actores then
    TCActores_Change(TCActores_)
  else if PCEditMain.ActivePage = ts_Monitores then
  begin
    sala.Prepararse_(rbtEditorSala.CatalogoReferencias);
    sala.publicarTodasLasVariables;
    {$IfDef MONITORES}
    manejadorMonitores.PrepararseYPubliVars;
    actualizarTablaMonitores;
    {$EndIf}
  end
  else if PCEditMain.ActivePage = ts_Mantenimientos then
  begin
    listaMantenimientos.Init(sala.Gens);
    for i := 0 to sala.ComercioInternacional.Count - 1 do
      if not (TComercioInternacional(sala.ComercioInternacional[i]) is
        TContratoModalidadDevolucion) then
        listaMantenimientos.addActor(sala.ComercioInternacional[i] as
          TComercioInternacional);
    listaMantenimientos.sortByActorYFecha;
    BAgregarFichaUnidades.Enabled :=
      sala.Gens.Count + sala.ComercioInternacional.Count > 0;
    actualizarTablaMantenimientos;
  end
  else if PCEditMain.ActivePage = ts_Fuentes then
  begin
    actualizarTablaFuentes;
  end
  else if PCEditMain.ActivePage = ts_Combustible then
    actualizarTablaCombustibles
  else if PCEditMain.ActivePage = ts_PlantillasSimRes3 then
    actualizarTablaPlantillasSimRes3
  else if PCEDITMain.ActivePage = ts_Simulador then
    actualizarTablaEscenarios;

end;

{ procedure TFSimSEEEdit.CBAnioMantenimientoChange(Sender: TObject);
  begin
  actualizarAnioTablaMantenimiento(StrToInt(CBAnioMantenimiento.Items[CBAnioMantenimiento.ItemIndex]));
  end; }

procedure TFSimSEEEdit.sgMantenimientosDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    TiposColMantenimientos[ACol],
    nil, iconos, validarCeldaMantenimientos);
end;


procedure TFSimSEEEdit.sgMantenimientosMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFSimSEEEdit.sgMantenimientosMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, TiposColMantenimientos);
end;

procedure TFSimSEEEdit.sgMantenimientosMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
  filaClon: integer;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, TiposColMantenimientos);
  case res of
    TC_btEditar:
      editarMantenimiento(TStringGrid(Sender).Row, False);
    TC_btEliminar:
      eliminarMantenimiento(TStringGrid(Sender).Row);
    TC_btClonar:
    begin
      filaClon := editarMantenimiento(TStringGrid(Sender).Row, True);
      if filaClon <> -1 then
        sgMantenimientos.Row := filaClon;
    end;
  end;
end;

procedure TFSimSEEEdit.sgMantenimientosValidarCambio(Sender: TObject);
begin
  utilidades.listadoValidarCambio(Sender, TiposColMantenimientos,
    Self.validarCeldaMantenimientos, self.cambioValorMantenimientos);
end;

procedure TFSimSEEEdit.CBEstabilizarFrameInicialClick(Sender: TObject);
begin
  sala.estabilizarInicio := CBEstabilizarFrameInicial.Checked;
  guardado := False;
end;

procedure TFSimSEEEdit.sgFuentesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFSimSEEEdit.sgFuentesMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, TiposColFuentes);
end;

procedure TFSimSEEEdit.sgFuentesDrawCell(Sender: TObject; ACol, ARow: integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State, TiposColFuentes[ACol], nil,
    iconos);
end;

procedure TFSimSEEEdit.sgFuentesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColFuentes);
  case res of
    TC_btEditar:
      editarFuente(TFuenteAleatoria(sala.listaFuentes_[utilidades.filaListado - 1]));
    TC_btEliminar:
      eliminarFuente(TFuenteAleatoria(sala.listaFuentes_[utilidades.filaListado - 1]));
    TC_btClonar:
      clonarFuente(TFuenteAleatoria(sala.listaFuentes_[utilidades.filaListado - 1]));
  end;
end;



procedure TFSimSEEEdit.sgCombustibleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFSimSEEEdit.sgCombustibleMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, TiposColCombustibles);
end;

procedure TFSimSEEEdit.sgCombustibleDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    TiposColCombustibles[ACol], nil,
    iconos);
end;

procedure TFSimSEEEdit.sgCombustibleMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, TiposColCombustibles);
  case res of
    TC_btEditar:
      editarCombustible(TCombustible(
        sala.listaCombustibles[utilidades.filaListado - 1]));
    TC_btEliminar:
      eliminarCombustible(TCombustible(
        sala.listaCombustibles[utilidades.filaListado - 1]));
    TC_btClonar:
      clonarCombustible(TCombustible(
        sala.listaCombustibles[utilidades.filaListado - 1]));
  end;
end;

procedure TFSimSEEEdit.BAgregarFuenteClick(Sender: TObject);
begin
  altaFuente;
end;

procedure TFSimSEEEdit.BAgregarCombustibleClick(Sender: TObject);
begin
  altaCombustible;
end;

procedure TFSimSEEEdit.MCargarMonitoresClick(Sender: TObject);
var
  mbResult: integer;
begin
  if (not guardadoMonitores) then
  begin
    mbResult := Application.MessageBox(
      PChar(mesMonitoresNoGuardadosGuardarCambios), PChar(mesSimSEEEdit),
      MB_YESNOCANCEL or MB_ICONEXCLAMATION);
    if mbResult = idYes then
    begin
      guardarMonitores;
      if self.DCargarManejadorMonitores.Execute then
        abrirMonitores;
    end
    else if mbResult = idNo then
      if self.DCargarManejadorMonitores.Execute then
        abrirMonitores;
  end
  else if self.DCargarManejadorMonitores.Execute then
    abrirMonitores;
end;

procedure TFSimSEEEdit.MCrearMonitorSimResPorDefectoClick(Sender: TObject);
begin
  crearMonitorSimResPorDefecto;
end;

function TFSimSEEEdit.EditarCrearSimRes3(var archi: string): boolean;
var
  resultado: integer;
  aux: boolean;
  res: boolean;
begin
  res := False;
  aux := guardado;
  if validarFormulario then
  begin
    sala.globs.NCronicasOpt := StrToInt(ENCronicasOpt.Text);
    Sala.globs.TasaDeActualizacion := StrToFloat(EtAct.Text);
    sala.globs.NCronicasSim := StrToInt(ENCronicasSim.Text);
    sala.globs.abortarSim := False;

    guardado := aux;

    if not guardado then
    begin
      resultado := Application.MessageBox(
        PChar(mesGuardarCambiosSalaParaContinuar), PChar(mesSimSEEEdit), MB_YESNOCANCEL);
      if resultado = idYes then
        MGuardarComoClick(MGuardarComo)
      else
        exit;
    end;

    editorSimRes3 := TEditorSimRes3.Create(self, sala, archi);
    if not editorSimRes3.errorAlCrear then
    begin
      if editorSimRes3.ShowModal <> 0 then
      begin
        if FileExists(editorSimRes3.sdArchiSimRes.FileName) then
        begin
          archi := editorSimRes3.sdArchiSimRes.FileName;
          res := True;
        end;
      end;
    end;
    editorSimRes3.Free;
    editorSimRes3 := nil;
  end;
  Result := res;
end;

procedure TFSimSEEEdit.MGuardarMonitoresClick(Sender: TObject);
begin
  if DSalvarManejadorMonitores.FileName = '' then
    MGuardarMonitoresComoClick(Sender)
  else
  begin
    guardarMonitores();
  end;
end;

procedure TFSimSEEEdit.MGuardarMonitoresComoClick(Sender: TObject);
begin
  if DSalvarManejadorMonitores.FileName = '' then
    DSalvarManejadorMonitores.FileName :=
      utilidades.titulo(DSalvarSala.FileName) + '.mon';
  if self.DSalvarManejadorMonitores.Execute then
  begin
    DCargarManejadorMonitores.FileName := DSalvarManejadorMonitores.FileName;
    guardarMonitores();
  end;
end;

procedure TFSimSEEEdit.miComponerCFsClick(Sender: TObject);
var
  formCompositor: TComponerCFs;
begin
  formCompositor := TComponerCFs.Create(Self);
  formCompositor.ShowModal;
  formCompositor.Free;
end;

procedure TFSimSEEEdit.BImportarClick(Sender: TObject);
begin
  if DImportarActor.Execute then
    importar;
end;

procedure TFSimSEEEdit.BEnganchesClick(Sender: TObject);
var
  form: TEditarEnganches;
  flg: string;
begin

  flg := '';

  if EArchivoCF.Text = '' then
    flg := flg + ', Nombre VACIO';
  ;
  if not FileExists(EArchivoCF.Text) then
    flg := flg + ', El archivo NO EXISTE';
  if not RBElegirCF.Checked then
    flg := flg + 'ElegirCF NO MARCADO';
  if flg = '' then
  begin
    form := TEditarEnganches.Create(self, EArchivoCF.Text, sala);
    if form.ShowModal = mrOk then
      guardado := False;
    form.Free;
  end
  else
    ShowMessage(mesSeleccionarArchivoBin + '. Causa: ' + flg +
      ' Archi:' + EArchivoCF.Text + ', CurDir: ' + GetCurrentDir);
end;

procedure TFSimSEEEdit.BExportarClick(Sender: TObject);
begin
  MExportarClick(MExportar);
end;

procedure TFSimSEEEdit.GenerarResumenTermico(Sender: TObject);
var
  archiRes: string;
begin
  archiRes := sala.generarResumenTermicoPrimerasFichas;
  if FileExists(archiRes) then
    opendocument(archiRes);
end;

procedure TFSimSEEEdit.MOpcionesClick(Sender: TObject);
var
  form: TFormEditarOpciones;
  i: integer;
  actor: TActor;
begin
  form := TFormEditarOpciones.Create(self);
  if form.ShowModal = mrOk then
  begin
    if not TSimSEEEditOptions.getInstance.fechasAutomaticas then
    begin
      for i := 0 to sala.listaActores.Count - 1 do
      begin
        actor := TActor(sala.listaActores[i]);
        if actor.nacimiento.dt = 0 then
          actor.nacimiento.PonerIgualA(minFecha(sala.globs.fechaIniSim,
            sala.globs.fechaIniOpt));
        if actor.muerte.dt = 0 then
          actor.muerte.PonerIgualA(maxFecha(sala.globs.fechaFinSim,
            sala.globs.fechaFinOpt));
      end;
    end
    else
    begin
      for i := 0 to sala.listaActores.Count - 1 do
      begin
        actor := TActor(sala.listaActores[i]);
        actor.nacimiento.dt := 0;
        actor.muerte.dt := 0;
      end;
    end;
    if PCEditMain.ActivePage = ts_Actores then
      actualizarTablaActores;
  end;
end;

procedure TFSimSEEEdit.CBPostesMonotonosClick(Sender: TObject);
begin
  sala.globs.PostesMonotonos := CBPostesMonotonos.Checked;
end;

procedure msgAdvertenciaCargandoDeArchivo(msg: string);
begin
  FSimSEEEdit.MemoWarnings.Lines.Add('Advertencia: ' + msg);
  // FSimSEEEdit.MemoWarnings.Visible:= true;
  // FSimSEEEdit.gbAdvertencias.Visible:= true;
end;

procedure msgErrorCargandoDeArchivo(msg: string);
begin
  FSimSEEEdit.MemoWarnings.Lines.Add(mesError + msg);
  FSimSEEEdit.nErroresCargando := FSimSEEEdit.nErroresCargando + 1;
end;

procedure TFSimSEEEdit.MemoDescEnter(Sender: TObject);
begin
  loQueHabia := MemoDesc.Lines.DelimitedText;
end;

procedure TFSimSEEEdit.MemoDescExit(Sender: TObject);
var
  AsString: string;
begin
  AsString := MemoDesc.Lines.DelimitedText;
  if loQueHabia <> AsString then
  begin
    sala.descripcion := AsString;
    guardado := False;
  end;
end;

procedure TFSimSEEEdit.btAyudaSimuladorClick(Sender: TObject);
begin
  verdoc(self, 'editor-optsim', '');
end;


procedure TFSimSEEEdit.btBuscarCFauxClick(Sender: TObject);
var
  CF: TAdminEstados;
  s: string;
begin
  ODCF.Filter := rsArchivosBinariosDeCostosFuturos + ' (*.bin)|*.bin|' +
    rsTodosLosArchivos + ' (*.*)|*.*';
  if ODCF.Execute then
  begin
    guardado := False;
    s := trim(ODCF.FileName);
    if s <> eArchiCFaux.Text then
      eArchiCFAux.Text := s;
    if eArchiCFAux.Text <> '' then
      if FileExists(eArchiCFAux.Text) then
      begin
        sala.archivoCFAux.archi := EArchiCFaux.Text;
        CF := TAdminEstados.CreateLoadFromArchi(EArchiCFAux.Text);
        CF.Free;
      end
      else
        ShowMessage(mesElArchivo + EArchiCFAux.Text + mesNoExiste);
  end;
end;

procedure TFSimSEEEdit.Button1Click(Sender: TObject);
begin
  verdoc(self, 'editor-cfaux', 'Función de Costo Futuro Auxiliar');
end;

procedure TFSimSEEEdit.btAyudaGlobalesClick(Sender: TObject);
begin
  verdoc(self, 'editor-variablesglobales', 'Variables Globales');
end;

procedure TFSimSEEEdit.btAyudaFuentesClick(Sender: TObject);
begin
  verdoc(self, 'editor-fuentesaleatorias', 'Fuentes Aleatorias');
end;

procedure TFSimSEEEdit.btAyudaActores_listaespecificaClick(Sender: TObject);
begin
  verdoc(self, 'editor-' + hid_ActoresListaEspecifica, '');
end;

procedure TFSimSEEEdit.btAyudaMantenimientosClick(Sender: TObject);
begin
  verdoc(self, 'editor-mantenimientos', 'Mantenimientos');
end;

procedure TFSimSEEEdit.btAyudaEstadosClick(Sender: TObject);
begin
  verdoc(self, 'editor-estados', 'Estados');
end;

procedure TFSimSEEEdit.btAyudaMonitoresClick(Sender: TObject);
begin
  verdoc(self, 'editor-monitores', 'Monitores');
end;

procedure TFSimSEEEdit.ODO1Click(Sender: TObject);
begin
  verdoc(self, 'editor-todo', 'PorHacer');
end;

end.
