unit uEditorSimRes3Main;
interface
uses
  LResources,
  FileUtil, SynEdit, SynCompletion,
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType, LMessages,
  {$ENDIF}
  Messages,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseFormularios, StdCtrls, ComCtrls, Grids, Math, uSalasDeJuego,
  uActores, uFuentesAleatorias, utilidades,
  uLectorSimRes3Defs,
  uTSimRes,
  uConstantesSimSEE, uverdoc, uSustituirVariablesPlantilla,
  uInfoCosa, uFormSelectTipo, uOpcionesSimSEEEdit,
  uBaseAltaEdicionIndices, uBaseAltaEdicionCronVars, uBaseAltaEdicionCronOpers,
  uBaseAltaEdicionPostOpers, uBaseAltaEdicionPrintCronVars,
  uHistoVarsOps, uPostOpers, uPrintCronVars,
  uAltaEdicionTVarIdxs,

  uAltaEdicionTCronVar,

  uAltaEdicionTCronOper_suma,
  uAltaEdicionTCronOper_sumaConSigno,
  uAltaEdicionTCronOper_Combinar,
  uAltaEdicionTCronOper_promedio,
  uAltaEdicionTCronOper_sumaProductoConDurpos,
  uAltaEdicionTCronOper_sumaProductoConDurposHasta, uAltaEdicionTCronOper_filtrarCronica,
  uAltaEdicionTCronOper_sumaProductoConDurposTopeado,
  uAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado,
  uAltaEdicionTCronOper_promedioPonderadoPorDurpos,
  uAltaEdicionTCronOper_suma_m, uAltaEdicionTCronOper_promedio_m,
  uAltaEdicionTCronOper_sumaProductoConDurpos_m, uAltaEdicionTCronOper_Maximo_m,
  ualtaediciontcronoper_generica_m,

  uAltaEdicionTPostOper_2CronVarsUnReal,
  uAltaEdicionTPostOper_3CronVars,
  uAltaEdicionTPostOper_combinarCronVars,
  uAltaEdicionTPostOper_combinarDespCronVars,
  uAltaEdicionTPostOper_aplicarActualizador,
  uAltaEdicionTPostOper_cambioPasoDeTiempo,
  uAltaEdicionTPostOper_CVaR,
  uAltaEdicionTPostOper_CrearConstanteReal,
  uAltaEdicionTPostOper_acumularCronVar,
  ualtaediciontpostoper_acumularconpisoytecho,
  uAltaEdicionTPostOper_potenciaFirmeHidraulica,
  uAltaEdicionTPostOper_maximo,
  uAltaEdicionTPostOper_MultiOrdenar,
  uAltaEdicionTPostOper_MultiPromedioMovil,
  ualtaediciontpostoper_monotonizar,
  uAltaEdicionTPostOper_Recronizar,
  uAltaEdicionTPostOper_Enventanar,
  uAltaEdicionTPostOper_Transponer,
  uAltaEdicionTPostOper_AcumCron,

  {$IFNDEF SIMRES3SOLOTEXTO}
  uAltaEdicionTPrintCronVar_matrizDeDatos,
  uAltaEdicionTPrintCronVar_Histograma,
  uAltaEdicionTPrintCronVar_CompararValoresMultiplesCronVars,
  uAltaEdicionTPrintCronVar_HistogramaGlobal,
  {$ENDIF}
  uAltaEdicionTPrintCronVar_Histograma_text,
  uAltaEdicionTPrintCronVar_R,
  Menus, uauxiliares, ExtCtrls;

resourcestring
  rsNombre = 'Nombre';
  rsActor = 'Actor';
  rsVariable = 'Variable';
  rsNumeroDeSimRes = 'Número de SimRes';
  rsTipoDeOperacion = 'Tipo de operación';
  rsResultados = 'Resultados';
  rsParametrosIndice = 'Parámetros índice';
  rsParametrosAdicionales = 'Parámetros adicionales';
  rsParametrosVariablesCronicas = 'Parámetros variables crónicas';
  rsHoja = 'Hoja';
  rsTitulo = 'Título';
  mesNoGuardadoCambiosGuardarAhora =
    'No se han guardado los cambios. ¿Desea guardarlos ahora?';
  mesAlgunasReferenciasIndicesNoModificadas =
    'Algunas referencias en los indices no fueron modificadas.';
  mesCargueSalaDeArchivo =
    'Cargue la sala que se uso para editar este archivo de definiciones en el' +
    ' editor SimSEE o reemplaze el archivo de definiciones por uno de esta sala.';
  mesNoSeEncuentraArchivo = 'No se encuentra el archivo: ';
  mesConfirmaEliminarPostOperacion = '¿Confirma que desea eliminar la post operación?';
  mesConfirmaEliminarImpresion = '¿Confirma que desea eliminar la impresión "';

const
  strFechaIniDeSala = '{$fechaIniSim}';
  strFechaFinDeSala = '{$fechaFinSim}';
  LargoMax_Tipo = 40;
  LargoMax_Resultados = 40;
  LargoMax_ParametrosAdicionales = 40;
  LargoMax_ParametrosIndice = 40;
  LargoMax_ParametrosCronVar = 40;
  LargoMax_NombreItem = 40;
//  LargoMax_ParametrosAdicionales = 40;

type
  TResultadoApertura = (TRA_Ok,
    TRA_EsParaOtraSala,
    TRA_Error);

  { TEditorSimRes3 }

  TEditorSimRes3 = class(TBaseFormularios)
    BAgregarCronOper: TButton;
    BAgregarCronVar: TButton;
    BAgregarIndice: TButton;
    BAgregarPostOper: TButton;
    BAgregarPrintCronVar: TButton;
    Button1: TButton;
    GBErrores: TGroupBox;
    LArchiSimRes: TLabel;
    eArchiSimRes: TEdit;
    BBuscarSimRes: TButton;
    lFDesde: TLabel;
    lFHasta: TLabel;
    eFDesde: TEdit;
    eFHasta: TEdit;

    GroupBox1: TGroupBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    pSuperior: TPanel;

    PCEditorSimRes3Main: TPageControl;
    rbSimRes3_html: TRadioButton;
    rbSimRes3_Excel: TRadioButton;
    SynCompletion1: TSynCompletion;
    SynEdit1: TSynEdit;
    TabSheet1: TTabSheet;
    TSIndices: TTabSheet;
    TSCronVars: TTabSheet;
    TSCronOpers: TTabSheet;
    TSPostOpers: TTabSheet;
    TSPrintCronVars: TTabSheet;
    sgIndices: TStringGrid;
    sgCronVars: TStringGrid;
    sgCronOpers: TStringGrid;
    sgPostOpers: TStringGrid;
    sgPrintCronVars: TStringGrid;
    bUsarFechaIniSim: TButton;
    bUsarFechaFinSim: TButton;
    bUsarArchivoCorrida: TButton;



    MainMenu1: TMainMenu;
    mArchivoEditorSimRes3: TMenuItem;
    mNuevoEditorSimRes3: TMenuItem;
    mAbrirEditorSimRes3: TMenuItem;
    N1: TMenuItem;
    mGuardarEditorSimRes3: TMenuItem;
    mGuardarComoEditorSimRes3: TMenuItem;
    N2: TMenuItem;
    mSalirEditorSimRes3: TMenuItem;
    odArchiSimRes: TOpenDialog;
    sdArchiSimRes: TSaveDialog;
    odArchiSala: TOpenDialog;
    TSAyuda: TTabSheet;
    TSEjecutar: TTabSheet;
    eSemillaSim: TEdit;
    lSemillaAleatoriaSim: TLabel;
    BEjecutar: TButton;
    btAyudaFuentes: TButton;
    mErrores: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure sgPrintCronVarsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgListadoDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgListadoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgListadoMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure sgCronVarsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgCronOpersMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgPostOpersMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgIndicesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAgregarIndiceClick(Sender: TObject);
    procedure BAgregarCronVarClick(Sender: TObject);
    procedure BAgregarCronOperClick(Sender: TObject);
    procedure BAgregarPostOperClick(Sender: TObject);
    procedure BAgregarPrintCronVarClick(Sender: TObject);
    procedure bUsarFechaIniSimClick(Sender: TObject);
    procedure bUsarFechaFinSimClick(Sender: TObject);
    procedure bUsarArchivoCorridaClick(Sender: TObject);
    procedure BBuscarSimResClick(Sender: TObject);
    procedure mGuardarEditorSimRes3Click(Sender: TObject);
    procedure mGuardarComoEditorSimRes3Click(Sender: TObject);
    procedure mAbrirEditorSimRes3Click(Sender: TObject);
    procedure mSalirEditorSimRes3Click(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure btAyudaFuentesClick(Sender: TObject);
    procedure PCEditorSimRes3MainChange(Sender: TObject);
    procedure mNuevoEditorSimRes3Click(Sender: TObject);
    procedure BEjecutarClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    //    procedure BEjecutarClick(Sender: TObject);
  public
    function altaIndice: TVarIdxs;
    //Retorna true si el usuario edito correctamente un indice
    function editarIndice(indice: TVarIdxs; clonar: boolean): boolean; overload;
    procedure editarIndice(fila: integer; clonar: boolean); overload;
    procedure eliminarIndice(fila: integer);

    function altaCronVar: TCronVar;
    procedure editarCronVar(fila: integer; clonar: boolean);
    procedure eliminarCronVar(fila: integer);

    function altaCronOper: TCronOper;
    procedure editarCronOper(fila: integer; clonar: boolean);
    procedure eliminarCronOper(fila: integer);

    function altaPostOper: TPostOper;
    procedure editarPostOper(fila: integer; clonar: boolean);
    procedure eliminarPostOper(fila: integer);

    function altaPrintCronVar: TPrintCronVar;
    procedure editarPrintCronVar(fila: integer; clonar: boolean);
    procedure eliminarPrintCronVar(fila: integer);
  protected
    function validarFormulario(): boolean; override;
  private
    tiposColsSGIndices, tiposColsSGCronVars, tiposColsSGCronOpers,
    tiposColsSGPostOpers, tiposColsSGPrintCronVars: TDAOfTTipoColumna;

    lector: TLectorSimRes3Defs;

    function tiposColsdeSG(tabla: TStringGrid): TDAOfTTipoColumna;

    procedure registrarIndices;
    procedure registrarCronVars;
    procedure registrarCronOpers;
    procedure registrarPostOpers;
    procedure registrarPrintCronVars;

    procedure actualizarTablaIndices;
    procedure actualizarTablaCronVars;
    procedure actualizarTablaCronOpers;
    procedure actualizarTablaPostOpers;
    procedure actualizarTablaPrintCronVars;

    //Chequea que los actores indicados por los indices en lector se correspondan
    //con actores en la sala. El arreglo resultado tiene los indices con actores
    //que no se encuentran en la sala
    function checkActoresYFuentes: TDAOfTVarIdxs;

    procedure inicializar;
    function abrir(archivo: string): TResultadoApertura;
    procedure guardar(archivo: string);
    procedure guardarComo;

    //Retorna la seleccion del usuario en el MessageDialog (mbYes, mbNo, mbCancel)
    function chequearNoReferenciados: integer;
    procedure chequearErrores;
  public
    errorAlCrear: boolean;
    constructor Create(AOwner: TComponent; xsala: TSalaDeJuego; archiSimResDefs: string);
      reintroduce;
  end;

var
  editorSimRes3: TEditorSimRes3;

implementation
 {$R *.lfm}

uses
  ueditor_resourcestrings,
  SimSEEEditMain;




// retorna el string limitado a ocupar N Caracteres.
// Si el string original tiene más de N Caracteres se borran los sobrantes
// y los últimos tres se sustituyen por '...'
function limitar_str(const s: string; N: integer): string;
var
  res: string;
  M, R: integer;
begin
  M := length(s);
  if M <= N then
    res := s
  else
  begin
    R := 3;
    M := N - R;
    if M < 0 then
      res := '...'
    else
      res := copy(s, 1, M) + '...';
  end;
  Result := res;
end;


constructor TEditorSimRes3.Create(AOwner: TComponent; xsala: TSalaDeJuego;
  archiSimResDefs: string);
begin

  inherited Create_conSalaYEditor_(AOwner,xsala);

  borderStyle := bsSizeable;

  lector := TLectorSimRes3Defs.Create;

  odArchiSimRes.InitialDir := uConstantesSimSEE.getCurrentDrive +
    ExtractFilePath(self.sala.dirSala);
  odArchiSimRes.Filter :=
    'Archivos de Texto (*.sr3)|*.sr3|Archivos de Texto (*.txt)|*.txt|Todos los Archivos (*.*)|*.*';
  odArchiSimRes.DefaultExt := 'sr3';
  sdArchiSimRes.InitialDir := odArchiSimRes.InitialDir;
  sdArchiSimRes.Filter := odArchiSimRes.Filter;
  sdArchiSimRes.DefaultExt := odArchiSimRes.DefaultExt;
  odArchiSala.InitialDir := ExtractFilePath(sala.dirResultadosCorrida);
  odArchiSala.Filter :=
    'Archivos SimRes (simres_*x*.xlt)|simres_*x*.xlt|Todos los Archivos (*.*)|*.*';

  utilidades.initListado(sgIndices,
    [rsNombre, rsActor, rsVariable, rsNumeroDeSimRes, encabezadoBTEditar,
    encabezadoBTEliminar, encabezadoBTClonar, encabezadoBTUp, encabezadoBTDown],
    tiposColsSGIndices, True);

  utilidades.initListado(sgCronVars,
    [rsNombre, encabezadoBTEditar, encabezadoBTEliminar, encabezadoBTClonar,
    encabezadoBTUp, encabezadoBTDown],
    tiposColsSGCronVars, True);

  utilidades.initListado(sgCronOpers,
    [rsTipoDeOperacion, rsResultados, rsParametrosIndice,
    rsParametrosAdicionales, encabezadoBTEditar, encabezadoBTEliminar,
    encabezadoBTClonar, encabezadoBTUp, encabezadoBTDown],
    tiposColsSGCronOpers, True);

  utilidades.initListado(sgPostOpers,
    [rsTipoDeOperacion, rsResultados, rsParametrosVariablesCronicas,
    rsParametrosAdicionales, encabezadoBTEditar, encabezadoBTEliminar,
    encabezadoBTClonar, encabezadoBTUp, encabezadoBTDown],
    tiposColsSGPostOpers, True);

  utilidades.initListado(sgPrintCronVars,
    [rsTipo, rsVariableCronica, rsHoja, rsTitulo, rsParametrosAdicionales,
    encabezadoBTEditar, encabezadoBTEliminar, encabezadoBTClonar,
    encabezadoBTUp, encabezadoBTDown],
    tiposColsSGPrintCronVars, True);

  PCEditorSimRes3Main.ActivePageIndex := 0;

  (*
  PCEditorSimRes3Main.Width := maxAnchoTablaEnorme;
  PCEditorSimRes3Main.Height := maxAlturaTablaGrande + 93;
  TSIndices.Width := PCEditorSimRes3Main.Width;
  TSCronVars.Width := PCEditorSimRes3Main.Width;
  TSCronOpers.Width := PCEditorSimRes3Main.Width;
  TSPostOpers.Width := PCEditorSimRes3Main.Width;
  TSPrintCronVars.Width := PCEditorSimRes3Main.Width;
  eArchiSimRes.Width := PCEditorSimRes3Main.Width - eArchiSimRes.Left -
    BBuscarSimRes.Width - bUsarArchivoCorrida.Width - 2 * utilidades.plusWidth;
  BBuscarSimRes.Left := eArchiSimRes.Left + eArchiSimRes.Width + utilidades.plusWidth;
  bUsarArchivoCorrida.Left := BBuscarSimRes.Left + BBuscarSimRes.Width +
    utilidades.plusWidth;
    *)
  registrarIndices;
  registrarCronVars;
  registrarCronOpers;
  registrarPostOpers;
  registrarPrintCronVars;

  lector.archisSimRes.Add(strUsarArchivoDeCorrida);
  lector.fechaDesde := strFechaIniDeSala;
  lector.fechaHasta := strFechaFinDeSala;
  if FileExists(archiSimResDefs) then
  begin
    odArchiSimRes.FileName := archiSimResDefs;
    errorAlCrear := abrir(archiSimResDefs) = TRA_Error;
  end
(*
  else if FileExists(ExtractFilePath(sala.archiSala) + 'PlantillaSimres3.txt')
  then
  begin
    archiSimResDefs := ExtractFilePath(sala.archiSala) + 'PlantillaSimres3.txt';
    odArchiSimRes.FileName := archiSimResDefs;
    errorAlCrear := abrir(archiSimResDefs) = TRA_Error;
  end
  *)
  else
  begin
    errorAlCrear := False;
    inicializar;
    guardado := True;
  end;

  eSemillaSim.Text:= IntToStr( sala.globs.semilla_inicial_sim );


  if editorSimRes3 <> nil then
    raise Exception.Create(
      'Creo una instancia nueva del editorSimRes3 mientras ya tenía otra. Solo debe haber una instancia creada.')
  else
    editorSimRes3 := Self;
end;

procedure TEditorSimRes3.actualizarTablaIndices;
var
  i: integer;
  indice: TVarIdxs;
begin
  sgIndices.RowCount := lector.lstIdxs.Count + 1;
  if sgIndices.RowCount > 1 then
    sgIndices.FixedRows := 1
  else
    sgLimpiarSeleccion(sgIndices);

  for i := 0 to lector.lstIdxs.Count - 1 do
  begin
    indice := lector.lstIdxs[i];

    sgIndices.Cells[0, i + 1] := indice.nombreIndice;
    sgIndices.Cells[1, i + 1] := indice.nombreActor;
    sgIndices.Cells[2, i + 1] := indice.nombreVar;
    sgIndices.Cells[3, i + 1] := indice.numSimRes;
  end;

  AutoSizeTypedColsAndTable(sgIndices, tiposColsSGIndices, FSimSEEEdit.iconos,
    maxAnchoTablaEnorme,
    maxAlturaTablaGrande, TSimSEEEditOptions.getInstance.
    deshabilitarScrollHorizontalEnListados);
  chequearErrores;
end;

procedure TEditorSimRes3.actualizarTablaCronVars;
var
  i: integer;
  cronVar: TCronVar;
begin
  sgCronVars.RowCount := lector.lstCronVars.Count + 1;
  if sgCronVars.RowCount > 1 then
    sgCronVars.FixedRows := 1
  else
    sgLimpiarSeleccion(sgCronVars);

  for i := 0 to lector.lstCronVars.Count - 1 do
  begin
    cronVar := lector.lstCronVars[i];

    sgCronVars.Cells[0, i + 1] := cronVar.nombre;
  end;

  AutoSizeTypedColsAndTable(sgCronVars, tiposColsSGCronVars, FSimSEEEdit.iconos,
    maxAnchoTablaEnorme,
    maxAlturaTablaGrande, TSimSEEEditOptions.getInstance.
    deshabilitarScrollHorizontalEnListados);
  chequearErrores;
end;

procedure TEditorSimRes3.actualizarTablaCronOpers;
var
  i: integer;
  cronOper: TCronOper;
begin
  sgCronOpers.RowCount := lector.lstCronOpers.Count + 1;
  if sgCronOpers.RowCount > 1 then
    sgCronOpers.FixedRows := 1
  else
    sgLimpiarSeleccion(sgCronOpers);

  for i := 0 to lector.lstCronOpers.Count - 1 do
  begin
    cronOper := lector.lstCronOpers[i];

    sgCronOpers.Cells[0, i + 1] := limitar_str(cronOper.tipo, LargoMax_Tipo);
    sgCronOpers.Cells[1, i + 1] :=
      limitar_str(cronOper.Resultados, LargoMax_Resultados);
    sgCronOpers.Cells[2, i + 1] :=
      limitar_str(cronOper.parametrosIndice, LargoMax_ParametrosIndice);
    sgCronOpers.Cells[3, i + 1] :=
      limitar_str(cronOper.parametrosAdicionales, LargoMax_ParametrosAdicionales);
  end;

  AutoSizeTypedColsAndTable(sgCronOpers, tiposColsSGCronOpers, FSimSEEEdit.iconos,
    maxAnchoTablaEnorme,
    maxAlturaTablaGrande, TSimSEEEditOptions.getInstance.
    deshabilitarScrollHorizontalEnListados);
  chequearErrores;
end;

procedure TEditorSimRes3.actualizarTablaPostOpers;
var
  i: integer;
  postOper: TPostOper;
begin
  sgPostOpers.RowCount := lector.lstPostOpers.Count + 1;
  if sgPostOpers.RowCount > 1 then
    sgPostOpers.FixedRows := 1
  else
    sgLimpiarSeleccion(sgPostOpers);

  for i := 0 to lector.lstPostOpers.Count - 1 do
  begin
    postOper := lector.lstPostOpers[i];

    sgPostOpers.Cells[0, i + 1] := limitar_str(postOper.tipo, LargoMax_Tipo);
    sgPostOpers.Cells[1, i + 1] :=
      limitar_str(postOper.res.nombre, LargoMax_Resultados);
    sgPostOpers.Cells[2, i + 1] :=
      limitar_str(postOper.nombresParametrosCronVar, LargoMax_ParametrosCronVar);
    sgPostOpers.Cells[3, i + 1] :=
      limitar_str(postOper.parametrosAdicionales, LargoMax_ParametrosAdicionales);
  end;

  AutoSizeTypedColsAndTable(sgPostOpers, tiposColsSGPostOpers, FSimSEEEdit.iconos,
    maxAnchoTablaEnorme,
    maxAlturaTablaGrande, TSimSEEEditOptions.getInstance.
    deshabilitarScrollHorizontalEnListados);
  chequearErrores;
end;

procedure TEditorSimRes3.actualizarTablaPrintCronVars;
var
  i: integer;
  printCronVar: TPrintCronVar;
begin
  sgPrintCronVars.RowCount := lector.lstPrintCronVars.Count + 1;
  if sgPrintCronVars.RowCount > 1 then
    sgPrintCronVars.FixedRows := 1
  else
    sgLimpiarSeleccion(sgPrintCronVars);

  for i := 0 to lector.lstPrintCronVars.Count - 1 do
  begin
    printCronVar := lector.lstPrintCronVars[i];

    sgPrintCronVars.Cells[0, i + 1] := limitar_str(printCronVar.tipo, LargoMax_Tipo);
    sgPrintCronVars.Cells[1, i + 1] :=
      limitar_str(printCronVar.getNombresCronVars, LargoMax_NombreItem);
    sgPrintCronVars.Cells[2, i + 1] :=
      limitar_str(printCronVar.nombreHoja, LargoMax_NombreItem);
    sgPrintCronVars.Cells[3, i + 1] :=
      limitar_str(printCronVar.titulo, LargoMax_NombreItem);
    sgPrintCronVars.Cells[4, i + 1] :=
      limitar_str(printCronVar.parametrosAdicionales, LargoMax_ParametrosAdicionales);

  end;

  AutoSizeTypedColsAndTable(sgPrintCronVars, tiposColsSGPrintCronVars,
    FSimSEEEdit.iconos,
    maxAnchoTablaEnorme,
    maxAlturaTablaGrande, TSimSEEEditOptions.getInstance.
    deshabilitarScrollHorizontalEnListados);
  chequearErrores;
end;

function TEditorSimRes3.checkActoresYFuentes: TDAOfTVarIdxs;
var
  i, iRes: integer;
  res: TDAOfTVarIdxs;
  esActorOFuenteDeLaSala: boolean;
  j: integer;
begin
  SetLength(res, lector.lstIdxs.Count);
  iRes := 0;
  for i := 0 to lector.lstIdxs.Count - 1 do
  begin
    //Si es el guión, es el actor 'Sala', sino busco a ver si es
    esActorOFuenteDeLaSala := TVarIdxs(lector.lstIdxs[i]).nombreActor = '-';
    if not esActorOFuenteDeLaSala then
    begin
      for j := 0 to self.sala.listaActores.Count - 1 do
        if TVarIdxs(lector.lstIdxs[i]).nombreActor =
          TActor(self.sala.listaActores[j]).nombre then
        begin
          esActorOFuenteDeLaSala := True;
          break;
        end;

      if not esActorOFuenteDeLaSala then
      begin
        for j := 0 to self.sala.listaFuentes_.Count - 1 do
          if TVarIdxs(lector.lstIdxs[i]).nombreActor =
            TFuenteAleatoria(self.sala.listaFuentes_[j]).nombre then
          begin
            esActorOFuenteDeLaSala := True;
            break;
          end;
      end;
    end;


    if not esActorOFuenteDeLaSala then
    begin
      res[iRes] := lector.lstIdxs[i];
      iRes := iRes + 1;
    end;
  end;
  if iRes < Length(res) then
    SetLength(res, iRes);

  Result := res;
end;

procedure TEditorSimRes3.inicializar;
var
  s: string;
begin
  if lector.lstArchis.Count = 0 then
   eArchiSimRes.Text:= strUsarArchivoDeCorrida
  else
   eArchiSimRes.Text := lector.lstArchis[0];


  eFDesde.Text := lector.fechaDesde;
  eFHasta.Text := lector.fechaHasta;

  actualizarTablaIndices;
  actualizarTablaCronVars;
  actualizarTablaCronOpers;
  actualizarTablaPostOpers;
  actualizarTablaPrintCronVars;
  if odArchiSimRes.FileName <> '' then
  begin
    s := odArchiSimRes.FileName;
    self.Caption := 'Editor SimRes3 - (' + s + ')';
  end
  else
    self.Caption := 'Editor SimRes3';
end;

procedure TEditorSimRes3.mAbrirEditorSimRes3Click(Sender: TObject);
begin
  if odArchiSimRes.Execute then
    abrir(odArchiSimRes.FileName);
end;

procedure TEditorSimRes3.mGuardarComoEditorSimRes3Click(Sender: TObject);
begin
  guardarComo;
end;

procedure TEditorSimRes3.mGuardarEditorSimRes3Click(Sender: TObject);
begin
  if sdArchiSimRes.FileName <> '' then
    guardar(sdArchiSimRes.FileName)
  else
    mGuardarComoEditorSimRes3Click(Sender);
end;

procedure TEditorSimRes3.mNuevoEditorSimRes3Click(Sender: TObject);
var
  guardar: integer;
  hacerNuevo: boolean;
begin
  guardar := hayQueGuardar(mesNoGuardadoCambiosGuardarAhora);
  if guardar = idYes then
  begin
    mGuardarEditorSimRes3Click(Sender);
    hacerNuevo := guardado;
  end
  else if guardar = idNo then
    hacerNuevo := True
  else
    hacerNuevo := False;

  if hacerNuevo then
  begin
    odArchiSimRes.FileName := '';
    sdArchiSimRes.FileName := '';
    lector.Free;
    lector := TLectorSimRes3Defs.Create;
    lector.archisSimRes.Add(strUsarArchivoDeCorrida);
    lector.fechaDesde := strFechaIniDeSala;
    lector.fechaHasta := strFechaFinDeSala;
    inicializar;
    guardado := True;
  end;
end;

procedure TEditorSimRes3.mSalirEditorSimRes3Click(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditorSimRes3.BGuardarClick(Sender: TObject);
begin
  mGuardarEditorSimRes3Click(Sender);
end;

function TEditorSimRes3.abrir(archivo: string): TResultadoApertura;
var
  indicesSinActor: TDAOfTVarIdxs;
  oldLector: TLectorSimRes3Defs;
  texto: string;
  i: integer;
  cambioReferencias: boolean;
  res: TResultadoApertura;
begin
  guardado := True;
  oldLector := lector;
  lector := TLectorSimRes3Defs.Create;
  lector.LeerDefiniciones(archivo, False, false);
  if lector.versionArchivo < 10 then
    guardado := False;
  indicesSinActor := checkActoresYFuentes;
  if length(indicesSinActor) > 0 then
  begin
    texto :=
      'Los siguientes indices contienen referencias a actores que no estan en la sala actual.'#13#10;
    if Length(indicesSinActor) <= 20 then
    begin
      for i := 0 to high(indicesSinActor) do
        texto := texto + indicesSinActor[i].nombreIndice + ', ' +
          indicesSinActor[i].nombreActor + ', ' + indicesSinActor[i].nombreVar + #13#10;
    end
    else
    begin
      for i := 0 to 19 do
        texto := texto + indicesSinActor[i].nombreIndice + ', ' +
          indicesSinActor[i].nombreActor + ', ' + indicesSinActor[i].nombreVar + #13#10;
      texto := texto + '...'#13#10;
    end;

    texto := texto + '¿Desea editarlos para referenciar actores de esta sala?'#13#10 +
      '(Si selecciona no, no se realizara la carga)';

    if (Application.MessageBox(PChar(texto), 'Confirme que desea',
      MB_YESNO + MB_ICONEXCLAMATION) = idYes) then
    begin
      cambioReferencias := True;
      for i := 0 to high(indicesSinActor) do
      begin
        cambioReferencias := editarIndice(indicesSinActor[i], False);
        if not cambioReferencias then
          break;
      end;
    end
    else
      cambioReferencias := False;

    if not cambioReferencias then
    begin
      ShowMessage(mesAlgunasReferenciasIndicesNoModificadas + #13#10 +
        mesCargueSalaDeArchivo);

      //Deshago la carga
      lector.Free;
      lector := oldLector;
      res := TRA_Error;
    end
    else
    begin
      oldLector.Free;
      res := TRA_EsParaOtraSala;
      inicializar;
      self.Caption := 'Editor SimRes3';
      sdArchiSimRes.FileName := '';
      guardado := False;
    end;
  end
  else
  begin
    oldLector.Free;
    res := TRA_Ok;
    inicializar;
    sdArchiSimRes.FileName := odArchiSimRes.FileName;
  end;

  Result := res;
end;

procedure TEditorSimRes3.guardar(archivo: string);
begin
  if archivo = '' then
    guardarComo
  else
  begin
    if validarFormulario then
    begin
      if not GBErrores.Visible or (Application.MessageBox(
        'La plantilla que va a guardar contiene errores.'#13#10'Puede guardarla, pero no podrá ejecutarla hasta que estos sean correjidos.'#13#10'¿Desea guardar de todos modos?', 'Guardar con errores',
        MB_YESNO + MB_ICONQUESTION) = ID_YES) then
      begin
        if chequearNoReferenciados <> idCancel then
        begin
          lector.archisSimRes.Clear;
          lector.archisSimRes.Add(eArchiSimRes.Text);

          lector.fechaDesde := eFDesde.Text;
          lector.fechaHasta := eFHasta.Text;

          lector.EscribirDefiniciones(archivo,
            TSimSEEEditOptions.getInstance.guardarBackupDeArchivos,
            TSimSEEEditOptions.getInstance.maxNBackups);
          guardado := True;
          self.Caption := 'Editor SimRes3 - (' + sdArchiSimRes.FileName + ')';
          odArchiSimRes.FileName := sdArchiSimRes.FileName;
        end;
      end;
    end;
  end;
end;

procedure TEditorSimRes3.guardarComo;
begin
  if sdArchiSimRes.Execute then
    guardar(sdArchiSimRes.FileName);
end;

function TEditorSimRes3.chequearNoReferenciados: integer;
const
  MAX_ITEMS_LISTADOS = 10;
var
  i, res, iHasta: integer;
  indicesNoReferenciados: TDAOfTVarIdxs;
  cronVarsNoReferenciadas: TDAOfCronVar;
  texto: string;
begin
  indicesNoReferenciados := lector.indicesSinReferencia;
  cronVarsNoReferenciadas := lector.cronVarsSinReferencia;

  if (length(indicesNoReferenciados) > 0) or
    (length(cronVarsNoReferenciadas) > 0) then
  begin
    texto := 'Advertencia!'#13#10#13#10;

    if length(indicesNoReferenciados) > 0 then
    begin
      if length(indicesNoReferenciados) = 1 then
        texto := texto + 'El siguiente Índice no es utilizado:'#13#10
      else
        texto := texto + 'Los siguientes Índices no son utilizados:'#13#10;

      iHasta := min(MAX_ITEMS_LISTADOS, high(indicesNoReferenciados));
      for i := 0 to iHasta do
        texto := texto + indicesNoReferenciados[i].nombreIndice + #13#10;
      if iHasta < high(indicesNoReferenciados) then
        texto := texto + '...'#13#10;
      texto := texto + #13#10;
    end;

    if Length(cronVarsNoReferenciadas) > 0 then
    begin
      if length(cronVarsNoReferenciadas) = 1 then
        texto := texto + 'La siguiente Variable Crónica no es utilizada:'#13#10
      else
        texto := texto + 'Las siguiente Variables Crónicas no son utilizadas:'#13#10;

      iHasta := min(MAX_ITEMS_LISTADOS, high(cronVarsNoReferenciadas));
      for i := 0 to high(cronVarsNoReferenciadas) do
        texto := texto + cronVarsNoReferenciadas[i].nombre + #13#10;
      if iHasta < high(cronVarsNoReferenciadas) then
        texto := texto + '...'#13#10;
      texto := texto + #13#10;
    end;

    texto := texto + '¿Desea conservarlos en el archivo de definiciones?'#0;

    res := Application.MessageBox(@texto[1], 'Variables sin utilizar',
      MB_YESNOCANCEL + MB_ICONQUESTION);
    if res = idNo then
    begin
      for i := 0 to high(indicesNoReferenciados) do
        lector.eliminarIndice(indicesNoReferenciados[i]);
      actualizarTablaIndices;
      for i := 0 to high(cronVarsNoReferenciadas) do
        lector.eliminarCronVar(cronVarsNoReferenciadas[i]);
      actualizarTablaCronVars;
    end;
  end
  else
    res := idNo;
  Result := res;
end;

procedure TEditorSimRes3.chequearErrores;
begin
  GBErrores.Visible := lector.hayErrores(mErrores.Lines);
end;

procedure TEditorSimRes3.BAgregarCronOperClick(Sender: TObject);
begin
  altaCronOper;
end;

procedure TEditorSimRes3.BAgregarCronVarClick(Sender: TObject);
begin
  altaCronVar;
end;

procedure TEditorSimRes3.BAgregarIndiceClick(Sender: TObject);
begin
  altaIndice;
end;

procedure TEditorSimRes3.BAgregarPostOperClick(Sender: TObject);
begin
  altaPostOper;
end;

procedure TEditorSimRes3.BAgregarPrintCronVarClick(Sender: TObject);
begin
  altaPrintCronVar;
end;

procedure TEditorSimRes3.BBuscarSimResClick(Sender: TObject);
begin
  if odArchiSala.Execute then
    eArchiSimRes.Text := odArchiSala.FileName;
end;

procedure TEditorSimRes3.BEjecutarClick(Sender: TObject);
var
  sustitutor: TSustituirVariablesPlantilla;
  archiCorrida: string;
  semilla: integer;
  oldGuardado: boolean;
  archisLst: TStringList;
  carpeta: string;
  flg_Sim_OK: boolean;

begin
  oldGuardado := guardado;
  if validarFormulario and inherited validarEditInt(eSemillaSim, -MaxInt, MaxInt) then
  begin
    guardado := oldGuardado;
    if inherited hayQueGuardar(
      'Debe guardar los cambios para continuar. ¿Desea guardarlos ahora?') = idYes then
      guardar(sdArchiSimRes.FileName);

    if guardado then
    begin
      sustitutor := TSustituirVariablesPlantilla.Create( 0 );
      semilla := StrToInt(eSemillaSim.Text);


      archiCorrida := sustitutor.obtenerArchiSimRes(eArchiSimRes.Text, self.sala, semilla);
      archisLst:=  ArchisSim_lst( carpeta, archiCorrida );
      flg_Sim_OK:= SortAndCountCronicas( archisLst ) = self.sala.globs.NCronicasSim;

      if not flg_Sim_OK then
      begin
        // pruebo si hay archivos de las simulaciones mono-hilo
        if eArchiSimRes.Text = strUsarArchivoDeCorrida then
        begin
           archisLst.Free;
           archiCorrida:= sustitutor.obtenerArchiSimRes( OLD_strUsarArchivoDeCorrida, self.sala, semilla);
           archisLst:=  ArchisSim_lst( carpeta, archiCorrida );
           flg_Sim_Ok:=  archisLst.count = 1;
        end;
      end;

      if flg_Sim_OK then
      begin
        try
          sustitutor.ejecutarSimRes3(sdArchiSimRes.FileName, self.sala,
            self.sala.EscenarioActivo.nombre, semilla, rbSimRes3_html.Checked );
        except
          on e: Exception do
            ShowMessage(e.Message);
        end;
        sustitutor.Free;
      end
      else
        ShowMessage(mesNoSeEncuentraArchivo + archiCorrida + '.'#13#10 +
          'Ejecute la simulación para la semilla y número de crónicas indicados y vuelva a intentarlo.');
     archisLst.Free;
    end;
  end;
end;

{procedure TEditorSimRes3.BEjecutarClick(Sender: TObject);
var
  sustitutor: TSustituirVariablesPlantilla;
  archiSimRes: String;
begin
  sustitutor:= TSustituirVariablesPlantilla.Create;
  archiSimRes:= sustitutor.obtenerArchiSimRes(eArchiSimRes.Text, sala);
  if FileExists(archiSimRes) then
  begin
    sustitutor.ejecutarSimRes3(sdArchiSimRes.FileName, sala);
  end
  else
    ShowMessage(mesNoSeEncuentraArchivo + archiSimRes + #13#10 +
                'Ejecute la simulación de la sala para la semilla aleatoria y el número de crónicas especificado y vuelva a intentarlo.');
end;}

procedure TEditorSimRes3.btAyudaFuentesClick(Sender: TObject);
begin
  verdoc(self, TEditorSimRes3);
end;

procedure TEditorSimRes3.bUsarArchivoCorridaClick(Sender: TObject);
begin
  eArchiSimRes.Text := strUsarArchivoDeCorrida;
end;

procedure TEditorSimRes3.bUsarFechaFinSimClick(Sender: TObject);
begin
  eFHasta.Text := strFechaFinDeSala;
  guardado := False;
end;

procedure TEditorSimRes3.bUsarFechaIniSimClick(Sender: TObject);
begin
  eFDesde.Text := strFechaIniDeSala;
  guardado := False;
end;

function TEditorSimRes3.tiposColsdeSG(tabla: TStringGrid): TDAOfTTipoColumna;
begin
  if tabla = sgIndices then
    Result := tiposColsSGIndices
  else if tabla = sgCronVars then
    Result := tiposColsSGCronVars
  else if tabla = sgCronOpers then
    Result := tiposColsSGCronOpers
  else if tabla = sgPostOpers then
    Result := tiposColsSGPostOpers
  else if tabla = sgPrintCronVars then
    Result := tiposColsSGPrintCronVars
  else
    raise Exception.Create(
      'TEditorSimRes3.tiposColsdeSG: Tipos de columna no definidos para la tabla ' +
      tabla.Name);
end;

procedure TEditorSimRes3.PCEditorSimRes3MainChange(Sender: TObject);
begin
  if PCEditorSimRes3Main.ActivePage = TSAyuda then
  begin
    verdoc(self, 'editorSimRes3-solaperoPrincipal', '');
    PCEditorSimRes3Main.ActivePage := TSIndices;
  end;
end;

procedure TEditorSimRes3.registrarIndices;
begin
  uInfoCosa.InfoIndicesSimRes.Clear;
  uInfoCosa.InfoIndicesSimRes.Add(TInfoCosa.Create(TVarIdxs, 'Indice',
    TAltaEdicionTVarIdxs));
end;

procedure TEditorSimRes3.registrarCronVars;
begin
  uInfoCosa.InfoCronVarsSimRes.Clear;

  uInfoCosa.InfoCronVarsSimRes.Add(TInfoCosa.Create(TCronVar,
    rsVariableCronica, TAltaEdicionTCronVar));
end;

procedure TEditorSimRes3.registrarCronOpers;
begin
  uInfoCosa.InfoCronOpersSimRes.Clear;
  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_suma,
    TCronOper_suma.tipo, TAltaEdicionTCronOper_Suma));
  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_sumaConSigno,
    TCronOper_sumaConSigno.tipo, TAltaEdicionTCronOper_sumaConSigno));
  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_Combinar,
    TCronOper_Combinar.tipo, TAltaEdicionTCronOper_combinar));
  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_promedio,
    TCronOper_promedio.tipo, TAltaEdicionTCronOper_promedio));
  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_sumaProductoConDurpos,
    TCronOper_sumaProductoConDurpos.tipo, TAltaEdicionTCronOper_sumaProductoConDurpos));
  uInfoCosa.InfoCronOpersSimRes.Add(
    TInfoCosa.Create(TCronOper_sumaProductoConDurposHasta,
    TCronOper_sumaProductoConDurposHasta.tipo,
    TAltaEdicionTCronOper_sumaProductoConDurposHasta));
  uInfoCosa.InfoCronOpersSimRes.Add(
    TInfoCosa.Create(TCronOper_sumaProductoConDurposTopeado,
    TCronOper_sumaProductoConDurposTopeado.tipo,
    TAltaEdicionTCronOper_sumaProductoConDurposTopeado));
  uInfoCosa.InfoCronOpersSimRes.Add(
    TInfoCosa.Create(TCronOper_sumaDobleProductoConDurposTopeado,
    TCronOper_sumaDobleProductoConDurposTopeado.tipo,
    TAltaEdicionTCronOper_sumaDobleProductoConDurposTopeado));
  uInfoCosa.InfoCronOpersSimRes.Add(
    TInfoCosa.Create(TCronOper_promedioPonderadoPorDurpos,
    TCronOper_promedioPonderadoPorDurpos.tipo,
    TAltaEdicionTCronOper_promedioPonderadoPorDurPos));
  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_filtrarCronica,
    TCronOper_filtrarCronica.tipo, TAltaEdicionTCronOper_filtrarCronica));
  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_suma_m,
    TCronOper_suma_m.tipo, TAltaEdicionTCronOper_suma_m));
  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_promedio_m,
    TCronOper_promedio_m.tipo, TAltaEdicionTCronOper_promedio_m));

  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_sumaProductoConDurpos_m,
    TCronOper_sumaProductoConDurpos_m.tipo,
    TAltaEdicionTCronOper_sumaProductoConDurpos_m));

  uInfoCosa.InfoCronOpersSimRes.Add(
    TInfoCosa.Create(TCronOper_promedioPonderadoConDurpos_m,
    TCronOper_promedioPonderadoConDurpos_m.tipo, TAltaEdicionTCronOper_generica_m));

  uInfoCosa.InfoCronOpersSimRes.Add(TInfoCosa.Create(TCronOper_Maximo_m,
    TCronOper_Maximo_m.tipo, TAltaEdicionTCronOper_Maximo_m));
end;

procedure TEditorSimRes3.registrarPostOpers;
begin
  uInfoCosa.InfoPostOpersSimRes.Clear;

  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_minEntreCronVarYReal,
    TPostOper_minEntreCronVarYReal.tipo, TAltaEdicionTPostOper_2CronVarsUnReal));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_maxEntreCronVarYReal,
    TPostOper_maxEntreCronVarYReal.tipo, TAltaEdicionTPostOper_2CronVarsUnReal));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_cronVarMasReal,
    TPostOper_cronVarMasReal.tipo, TAltaEdicionTPostOper_2CronVarsUnReal));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_cronVarPorReal,
    TPostOper_cronVarPorReal.tipo, TAltaEdicionTPostOper_2CronVarsUnReal));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_restaCronVars,
    TPostOper_restaCronVars.tipo, TAltaEdicionTPostOper_3CronVars));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_multiplicacionCronVars,
    TPostOper_multiplicacionCronVars.tipo, TAltaEdicionTPostOper_3CronVars));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_divisionCronVars,
    TPostOper_divisionCronVars.tipo, TAltaEdicionTPostOper_3CronVars));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_combinarCronVars,
    TPostOper_combinarCronVars.tipo, TAltaEdicionTPostOper_combinarCronVars));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_combinarDespCronVars,
    TPostOper_combinarDespCronVars.tipo, TAltaEdicionTPostOper_combinarDespCronVars));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_aplicarActualizador,
    TPostOper_aplicarActualizador.tipo, TAltaEdicionTPostOper_aplicarActualizador));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_cambioPasoDeTiempo,
    TPostOper_cambioPasoDeTiempo.tipo, TAltaEdicionTPostOper_cambioPasoDeTiempo));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_CVaR,
    TPostOper_CVaR.tipo, TAltaEdicionTPostOper_CVaR));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_CrearConstanteReal,
    TPostOper_CrearConstanteReal.tipo, TAltaEdicionTPostOper_CrearConstanteReal));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_acumularCronVar,
    TPostOper_acumularCronVar.tipo, TAltaEdicionTPostOper_acumularCronVar));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_acumularConPisoYTecho,
    TPostOper_acumularConPisoYTecho.tipo, TAltaEdicionTPostOper_acumularConPisoYTecho));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_potenciaFirmeHidraulica,
    TPostOper_potenciaFirmeHidraulica.tipo,
    TAltaEdicionTPostOper_potenciaFirmeHidraulica));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_maximo,
    TPostOper_maximo.tipo, TAltaEdicionTPostOper_maximo));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_MultiOrdenar,
    TPostOper_MultiOrdenar.tipo, TAltaEdicionTPostOper_MultiOrdenar));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_MultiPromedioMovil,
    TPostOper_MultiPromedioMovil.tipo, TAltaEdicionTPostOper_MultiPromedioMovil));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_MonotonizarCronVars,
    TPostOper_MonotonizarCronVars.tipo, TAltaEdicionTPostOper_Monotonizar));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_Recronizar,
      TPostOper_Recronizar.tipo, TAltaEdicionTPostOper_Recronizar));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_Enventanar,
    TPostOper_Enventanar.tipo, TAltaEdicionTPostOper_Enventanar));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_Transponer,
    TPostOper_Transponer.tipo, TAltaEdicionTPostOper_Transponer));
  uInfoCosa.InfoPostOpersSimRes.Add(TInfoCosa.Create(TPostOper_AcumCron,
    TPostOper_AcumCron.tipo, TAltaEdicionTPostOper_AcumCron));

end;

procedure TEditorSimRes3.registrarPrintCronVars;
begin
  uInfoCosa.InfoPrintCronVarsSimRes.Clear;
  {$IFNDEF SIMRES3SOLOTEXTO}
  uInfoCosa.InfoPrintCronVarsSimRes.Add(TInfoCosa.Create(TPrintCronVar_matrizDeDatos,
    TPrintCronVar_matrizDeDatos.tipo, TAltaEdicionPrintCronVar_matrizDeDatos));
  uInfoCosa.InfoPrintCronVarsSimRes.Add(TInfoCosa.Create(TPrintCronVar_histograma,
    TPrintCronVar_histograma.tipo, TAltaEdicionPrintCronVar_histograma));
  uInfoCosa.InfoPrintCronVarsSimRes.Add(TInfoCosa.Create(TPrintCronVar_HistogramaGlobal,
    TPrintCronVar_HistogramaGlobal.tipo, TAltaEdicionPrintCronVar_histogramaGlobal));
  uInfoCosa.InfoPrintCronVarsSimRes.Add(TInfoCosa.Create(
    TPrintCronVar_compararValoresMultiplesCronVars,
    TPrintCronVar_compararValoresMultiplesCronVars.tipo,
    TAltaEdicionPrintCronVar_CompararValoresMultiplesCronVars));
  {$ENDIF}
  uInfoCosa.InfoPrintCronVarsSimRes.Add(TInfoCosa.Create(TPrintCronVar_histograma_text,
    TPrintCronVar_histograma_text.tipo, TAltaEdicionPrintCronVar_histograma_text));

  uInfoCosa.InfoPrintCronVarsSimRes.Add(
    TInfoCosa.Create(
       TPrintCronVar_R,
       TPrintCronVar_R.tipo, TAltaEdicionPrintCronVar_R));

end;

function TEditorSimRes3.altaIndice: TVarIdxs;
var
  form: TBaseAltaEdicionIndices;
  formSelectTipo: TFormSelectTipo;
  tipoObjeto: TClaseDeIndice;
  tipoEditor: TClaseAltaEdicionIndices;
  res: TVarIdxs;
begin
  res := nil;

  formSelectTipo := TFormSelectTipo.Create(self,
    uInfoCosa.InfoIndicesSimRes.descsClase);


  if formSelectTipo.ShowModal = mrOk then
  begin
    tipoObjeto := TClaseDeIndice(uInfoCosa.InfoIndicesSimRes.tipoDeCosa(
      formSelectTipo.darTipo));
    tipoEditor := TClaseAltaEdicionIndices(
      uInfoCosa.InfoIndicesSimRes.getTipoEditor(tipoObjeto));

    form := tipoEditor.Create(self, self.Sala, lector, nil);
    if form.ShowModal = mrOk then
    begin
      res := form.darIndice;
      lector.agregarIndice(res);
      actualizarTablaIndices;
      sgIndices.Row := sgIndices.RowCount - 1;
      guardado := False;
    end;
    form.Free;
  end;
  formSelectTipo.Free;
  Result := res;
end;

function TEditorSimRes3.editarIndice(indice: TVarIdxs; clonar: boolean): boolean;
var
  form: TBaseAltaEdicionIndices;
  TipoEditor: TClaseAltaEdicionIndices;
begin
  TipoEditor := TClaseAltaEdicionIndices(uInfoCosa.InfoIndicesSimRes.getTipoEditor(
    indice.ClassType));
  if clonar then
    indice := lector.clonarIndice(indice);

  form := TipoEditor.Create(self, self.sala, lector, indice);
  if clonar then
  begin
    if form.ShowModal = mrOk then
    begin
      lector.agregarIndice(indice);
      actualizarTablaIndices;
      sgIndices.Row := sgIndices.RowCount - 1;
      guardado := False;
      Result := True;
    end
    else
    begin
      indice.Free;
      Result := False;
    end;
  end
  else
  if form.ShowModal = mrOk then
  begin
    actualizarTablaIndices;
    actualizarTablaCronOpers;
    guardado := False;
    Result := True;
  end
  else
    Result := False;
  form.Free;
end;

procedure TEditorSimRes3.editarIndice(fila: integer; clonar: boolean);
begin
  editarIndice(TVarIdxs(lector.lstIdxs[fila - 1]), clonar);
end;

procedure TEditorSimRes3.eliminarIndice(fila: integer);
var
  i: integer;
  msjError, texto: string;
  indice: TVarIdxs;
  referentes: TDAOfCronOper;
begin
  indice := lector.lstIdxs[fila - 1];

  if lector.existeReferenciaAlIndice(indice, referentes) then
  begin
    if length(referentes) = 1 then
      msjError := 'El índice es parámetro de una CronOper:'#13#10
    else
      msjError := 'El índice es parámetro de ' + IntToStr(length(referentes)) +
        ' CronOpers:'#13#10;

    for i := 0 to high(referentes) do
      msjError := msjError + 'CronOper, Tipo: ' + referentes[i].tipo + #13#10;

    if length(referentes) = 1 then
      msjError := msjError + 'Elimínela antes de eliminar el índice.'
    else
      msjError := msjError + 'Elimínelas antes de eliminar el índice.';
    ShowMessage(msjError);
  end
  else
  begin
    texto := '¿Confirma que desea eliminar el indice "' + indice.nombreIndice + '"?';
    if (Application.MessageBox(PChar(texto), 'Confirmar Eliminación',
      MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
    begin
      lector.eliminarIndice(fila - 1);
      guardado := False;
      actualizarTablaIndices;
    end;
  end;
end;

function TEditorSimRes3.altaCronVar: TCronVar;
var
  form: TBaseAltaEdicionCronVars;
  formSelectTipo: TFormSelectTipo;
  tipoObjeto: TClaseDeCronVar;
  tipoEditor: TClaseAltaEdicionCronVars;
  res: TCronVar;
begin
  res := nil;
  formSelectTipo := TFormSelectTipo.Create(self,
    uInfoCosa.InfoCronVarsSimRes.descsClase);
  if formSelectTipo.ShowModal = mrOk then
  begin
    tipoObjeto := TClaseDeCronVar(uInfoCosa.InfoCronVarsSimRes.tipoDeCosa(
      formSelectTipo.darTipo));
    tipoEditor := TClaseAltaEdicionCronVars(
      uInfoCosa.InfoCronVarsSimRes.getTipoEditor(tipoObjeto));

    form := tipoEditor.Create(self, lector, nil);
    if form.ShowModal = mrOk then
    begin
      res := form.darCronVar;
      lector.agregarCronVar(res);
      actualizarTablaCronVars;
      sgCronVars.Row := sgCronVars.RowCount - 1;
      guardado := False;
    end;
    form.Free;
  end;
  formSelectTipo.Free;
  Result := res;
end;

procedure TEditorSimRes3.editarCronVar(fila: integer; clonar: boolean);
var
  form: TBaseAltaEdicionCronVars;
  TipoEditor: TClaseAltaEdicionCronVars;
  cronVar: TCronVar;
begin
  cronVar := lector.lstCronVars[fila - 1];
  TipoEditor := TClaseAltaEdicionCronVars(
    uInfoCosa.InfoCronVarsSimRes.getTipoEditor(cronVar.ClassType));
  if clonar then
    cronVar := lector.clonarCronVar(cronVar);

  form := TipoEditor.Create(self, lector, cronVar);
  if clonar then
  begin
    if form.ShowModal = mrOk then
    begin
      lector.agregarCronVar(cronVar);
      actualizarTablaCronVars;
      sgCronVars.Row := sgCronVars.RowCount - 1;
      guardado := False;
    end
    else
      cronVar.Free;
  end
  else
  if form.ShowModal = mrOk then
  begin
    actualizarTablaCronVars;
    actualizarTablaCronOpers;
    actualizarTablaPostOpers;
    actualizarTablaPrintCronVars;
    guardado := False;
  end;
  form.Free;
end;

procedure TEditorSimRes3.eliminarCronVar(fila: integer);
var
  msjError, texto: string;
  cronVar: TCronVar;
begin
  cronVar := lector.lstCronVars[fila - 1];
  msjError := lector.existeReferenciaALaCronVar(cronVar);
  if msjError <> '' then
    ShowMessage(msjError)
  else
  begin
    texto := '¿Confirma que desea eliminar la variable crónica "' +
      cronVar.nombre + '"?';
    if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
      MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
    begin
      lector.eliminarCronVar(fila - 1);
      guardado := False;
      actualizarTablaCronVars;
    end;
  end;
end;

function TEditorSimRes3.altaCronOper: TCronOper;
var
  form: TBaseAltaEdicionCronOpers;
  formSelectTipo: TFormSelectTipo;
  tipoObjeto: TClaseDeCronOper;
  tipoEditor: TClaseAltaEdicionCronOpers;
  res: TCronOper;
begin
  res := nil;
  formSelectTipo := TFormSelectTipo.Create(self,
    uInfoCosa.InfoCronOpersSimRes.descsClase);
  if formSelectTipo.ShowModal = mrOk then
  begin
    tipoObjeto := TClaseDeCronOper(uInfoCosa.InfoCronOpersSimRes.tipoDeCosa(
      formSelectTipo.darTipo));
    tipoEditor := TClaseAltaEdicionCronOpers(
      uInfoCosa.InfoCronOpersSimRes.getTipoEditor(tipoObjeto));

    form := tipoEditor.Create(self, lector, nil, tipoObjeto);
    if form.ShowModal = mrOk then
    begin
      res := form.darCronOper;
      lector.agregarCronOper(res);
      actualizarTablaCronOpers;
      sgCronOpers.Row := sgCronOpers.RowCount - 1;
      guardado := False;
    end;
    form.Free;
  end;
  formSelectTipo.Free;
  Result := res;
end;

procedure TEditorSimRes3.editarCronOper(fila: integer; clonar: boolean);
var
  form: TBaseAltaEdicionCronOpers;
  TipoEditor: TClaseAltaEdicionCronOpers;
  cronOper: TCronOper;
begin
  cronOper := lector.lstCronOpers[fila - 1];
  TipoEditor := TClaseAltaEdicionCronOpers(
    uInfoCosa.InfoCronOpersSimRes.getTipoEditor(cronOper.ClassType));
  if clonar then
    cronOper := lector.clonarCronOper(cronOper);

  form := TipoEditor.Create(self, lector, cronOper,
    TClaseDeCronOper(cronOper.ClassType));
  if clonar then
  begin
    if form.ShowModal = mrOk then
    begin
      lector.agregarCronOper(cronOper);
      actualizarTablaCronOpers;
      sgCronOpers.Row := sgCronOpers.RowCount - 1;
      guardado := False;
    end
    else
      cronOper.Free;
  end
  else
  if form.ShowModal = mrOk then
  begin
    actualizarTablaCronOpers;
    guardado := False;
  end;
  form.Free;
end;

procedure TEditorSimRes3.eliminarCronOper(fila: integer);
var
  texto: string;
  //  cronOper: TCronOper;
begin
  //  cronOper:= lector.lstCronOpers[fila - 1];
  texto := '¿Confirma que desea eliminar la operación crónica?';
  if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
    MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    lector.eliminarCronOper(fila - 1);
    guardado := False;
    actualizarTablaCronOpers;
  end;
end;

function TEditorSimRes3.altaPostOper: TPostOper;
var
  form: TBaseAltaEdicionPostOpers;
  formSelectTipo: TFormSelectTipo;
  tipoObjeto: TClaseDePostOper;
  tipoEditor: TClaseAltaEdicionPostOpers;
  res: TPostOper;
begin
  res := nil;
  formSelectTipo := TFormSelectTipo.Create(self,
    uInfoCosa.InfoPostOpersSimRes.descsClase);
  if formSelectTipo.ShowModal = mrOk then
  begin
    tipoObjeto := TClaseDePostOper(uInfoCosa.InfoPostOpersSimRes.tipoDeCosa(
      formSelectTipo.darTipo));
    tipoEditor := TClaseAltaEdicionPostOpers(
      uInfoCosa.InfoPostOpersSimRes.getTipoEditor(tipoObjeto));

    form := tipoEditor.Create(self, lector, nil, tipoObjeto);
    if form.ShowModal = mrOk then
    begin
      res := form.darPostOper;
      lector.agregarPostOper(res);
      actualizarTablaPostOpers;
      sgPostOpers.Row := sgPostOpers.RowCount - 1;
      guardado := False;
    end;
    form.Free;
  end;
  formSelectTipo.Free;
  Result := res;
end;

procedure TEditorSimRes3.editarPostOper(fila: integer; clonar: boolean);
var
  form: TBaseAltaEdicionPostOpers;
  TipoEditor: TClaseAltaEdicionPostOpers;
  postOper: TPostOper;
begin
  postOper := lector.lstPostOpers[fila - 1];
  TipoEditor := TClaseAltaEdicionPostOpers(
    uInfoCosa.InfoPostOpersSimRes.getTipoEditor(postOper.ClassType));
  if clonar then
    postOper := lector.clonarPostOper(postOper);

  form := TipoEditor.Create(self, lector, postOper,
    TClaseDePostOper(postOper.ClassType));
  if clonar then
  begin
    if form.ShowModal = mrOk then
    begin
      lector.agregarPostOper(postOper);
      actualizarTablaPostOpers;
      sgPostOpers.Row := sgPostOpers.RowCount - 1;
      guardado := False;
    end
    else
      postOper.Free;
  end
  else
  if form.ShowModal = mrOk then
  begin
    actualizarTablaPostOpers;
    guardado := False;
  end;
  form.Free;
end;

procedure TEditorSimRes3.eliminarPostOper(fila: integer);
var
  texto: string;
  //  cronOper: TCronOper;
begin
  //  cronOper:= lector.lstCronOpers[fila - 1];
  texto := mesConfirmaEliminarPostOperacion;
  if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
    MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    lector.eliminarPostOper(fila - 1);
    guardado := False;
    actualizarTablaPostOpers;
  end;
end;

function TEditorSimRes3.altaPrintCronVar: TPrintCronVar;
var
  form: TBaseAltaEdicionPrintCronVars;
  formSelectTipo: TFormSelectTipo;
  tipoObjeto: TClaseDePrintCronVar;
  tipoEditor: TClaseAltaEdicionPrintCronVars;
  res: TPrintCronVar;
begin
  res := nil;
  formSelectTipo := TFormSelectTipo.Create(self,
    uInfoCosa.InfoPrintCronVarsSimRes.descsClase);
  if formSelectTipo.ShowModal = mrOk then
  begin
    tipoObjeto := TClaseDePrintCronVar(uInfoCosa.InfoPrintCronVarsSimRes.tipoDeCosa(
      formSelectTipo.darTipo));
    tipoEditor := TClaseAltaEdicionPrintCronVars(
      uInfoCosa.InfoPrintCronVarsSimRes.getTipoEditor(tipoObjeto));

    form := tipoEditor.Create(self, lector, nil, tipoObjeto);
    if form.ShowModal = mrOk then
    begin
      res := form.darPrintCronVar;
      lector.agregarPrintCronVar(res);
      actualizarTablaPrintCronVars;
      sgPrintCronVars.Row := sgPrintCronVars.RowCount - 1;
      guardado := False;
    end;
    form.Free;
  end;
  formSelectTipo.Free;
  Result := res;
end;

procedure TEditorSimRes3.editarPrintCronVar(fila: integer; clonar: boolean);
var
  form: TBaseAltaEdicionPrintCronVars;
  TipoEditor: TClaseAltaEdicionPrintCronVars;
  printCronVar: TPrintCronVar;
begin
  printCronVar := lector.lstPrintCronVars[fila - 1];

  TipoEditor := TClaseAltaEdicionPrintCronVars(
    uInfoCosa.InfoPrintCronVarsSimRes.getTipoEditor(printCronVar.ClassType));
  if clonar then
    printCronVar := lector.clonarPrintCronVar(printCronVar);

  form := TipoEditor.Create(self, lector, printCronVar,
    TClaseDePrintCronVar(printCronVar.ClassType));
  if clonar then
  begin
    if form.ShowModal = mrOk then
    begin
      lector.agregarPrintCronVar(printCronVar);
      actualizarTablaPrintCronVars;
      sgPrintCronVars.Row := sgPrintCronVars.RowCount - 1;
      guardado := False;
    end
    else
      printCronVar.Free;
  end
  else
  if form.ShowModal = mrOk then
  begin
    actualizarTablaPrintCronVars;
    guardado := False;
  end;
  form.Free;
end;

procedure TEditorSimRes3.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditorSimRes3.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditorSimRes3.eliminarPrintCronVar(fila: integer);
var
  texto: string;
  printCronVar: TPrintCronVar;
begin
  printCronVar := lector.lstPrintCronVars[fila - 1];
  texto := mesConfirmaEliminarImpresion + printCronVar.titulo + '"?';
  if (Application.MessageBox(PChar(texto), PChar(mesConfirmarEliminacion),
    MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    lector.eliminarPrintCronvar(fila - 1);
    guardado := False;
    actualizarTablaPrintCronVars;
  end;
end;


function TEditorSimRes3.validarFormulario(): boolean;
begin
  Result := ((eArchiSimRes.Text = strUsarArchivoDeCorrida) or
   inherited validarEditNArch(eArchiSimRes))
    and
    ((eFDesde.Text = strFechaIniDeSala) or inherited validarEditFecha(eFDesde)) and
    ((eFHasta.Text = strFechaFinDeSala) or inherited validarEditFecha(eFHasta));
end;

procedure TEditorSimRes3.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
  if CanClose then
  begin
    lector.Free;
  end;
end;

procedure TEditorSimRes3.sgCronOpersMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGCronOpers);
  case res of
    TC_btEditar: editarCronOper(utilidades.filaListado, False);
    TC_btEliminar: eliminarCronOper(utilidades.filaListado);
    TC_btClonar: editarCronOper(utilidades.filaListado, True);
    TC_btUp: listadoClickUp_(sgCronOpers, utilidades.filaListado,
        lector.lstCronOpers, Shift, lector.swapObjetosSimRes, Modificado);
    TC_btDown: listadoClickDown_(sgCronOpers, utilidades.filaListado,
        lector.lstCronOpers, Shift, lector.swapObjetosSimRes, Modificado);
  end;
end;

procedure TEditorSimRes3.sgCronVarsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGCronVars);
  case res of
    TC_btEditar: editarCronVar(utilidades.filaListado, False);
    TC_btEliminar: eliminarCronVar(utilidades.filaListado);
    TC_btClonar: editarCronVar(utilidades.filaListado, True);
    TC_btUp: listadoClickUp_(sgCronVars, utilidades.filaListado,
        lector.lstCronVars, Shift, lector.swapObjetosSimRes, Modificado);
    TC_btDown: listadoClickDown_(sgCronVars, utilidades.filaListado,
        lector.lstCronVars, Shift, lector.swapObjetosSimRes, Modificado);
  end;
end;

procedure TEditorSimRes3.sgListadoDrawCell(Sender: TObject; ACol, ARow: integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColsdeSG(TStringGrid(Sender))[ACol], nil, FSimSEEEdit.iconos);
end;

procedure TEditorSimRes3.sgListadoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditorSimRes3.sgListadoMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsdeSG(TStringGrid(Sender)));
end;

procedure TEditorSimRes3.sgPostOpersMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGPostOpers);
  case res of
    TC_btEditar: editarPostOper(utilidades.filaListado, False);
    TC_btEliminar: eliminarPostOper(utilidades.filaListado);
    TC_btClonar: editarPostOper(utilidades.filaListado, True);
    TC_btUp: listadoClickUp_(sgPostOpers, utilidades.filaListado,
        lector.lstPostOpers, Shift, lector.swapObjetosSimRes, Modificado);
    TC_btDown: listadoClickDown_(sgPostOpers, utilidades.filaListado,
        lector.lstPostOpers, Shift, lector.swapObjetosSimRes, Modificado);
  end;
end;

procedure TEditorSimRes3.sgPrintCronVarsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y,
    tiposColsSGPrintCronVars);
  case res of
    TC_btEditar: editarPrintCronVar(utilidades.filaListado, False);
    TC_btEliminar: eliminarPrintCronVar(utilidades.filaListado);
    TC_btClonar: editarPrintCronVar(utilidades.filaListado, True);
    TC_btUp: listadoClickUp_(sgPrintCronVars, utilidades.filaListado,
        lector.lstPrintCronVars, Shift, lector.swapObjetosSimRes, Modificado);
    TC_btDown: listadoClickDown_(sgPrintCronVars, utilidades.filaListado,
        lector.lstPrintCronVars, Shift, lector.swapObjetosSimRes, Modificado);
  end;
end;

procedure TEditorSimRes3.Button1Click(Sender: TObject);
var
  j: integer;
  aActor: TActor;
  aFuente: TFuenteAleatoria;
  sala_identificadores: TStringList;
begin
  sala_identificadores:= TStringList.Create;

  for j := 0 to self.sala.listaActores.Count - 1 do
  begin
    aActor:= sala.listaActores[j] as TActor;
    sala_identificadores.add( '$a_'+aActor.nombre );
  end;
  for j := 0 to self.sala.listaFuentes_.Count - 1 do
  begin
    aFuente:= sala.listaFuentes_[j] as TFuenteAleatoria;
    sala_identificadores.Add( '$f_'+ aFuente.nombre );
  end;
end;

procedure TEditorSimRes3.sgIndicesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsSGIndices);
  case res of
    TC_btEditar: editarIndice(utilidades.filaListado, False);
    TC_btEliminar: eliminarIndice(utilidades.filaListado);
    TC_btClonar: editarIndice(utilidades.filaListado, True);
    TC_btUp: listadoClickUp_(sgIndices, utilidades.filaListado,
        lector.lstIdxs, Shift, lector.swapObjetosSimRes, Modificado);
    TC_btDown: listadoClickDown_(sgIndices, utilidades.filaListado,
        lector.lstIdxs, Shift, lector.swapObjetosSimRes, Modificado);
  end;
end;

initialization
end.
