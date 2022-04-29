(*
  Una cosa es un objeto que puede guardarse.
  Una TListaDeCosas, es una lista de cosas
*)

// Este define, permite que al leer se escriban en consola la clase y el nombre
// de las cosas leídas si son del tipo TCosaConNombre. Sirve a los efectos de
// debuggin cuando se tranca durante la lectura de la sala de juegos.
{xDEFINE WRLN_COSAS_CON_NOMBRE_LEIDAS}

// Este define hace que se escriban todas las líneas leídas.
{$DEFINE LECTURA_VERBOSA}
unit ucosa;

interface

uses
  SysUtils, Classes, Dialogs, xmatdefs, ufechas, typinfo,
  ubuscaarchivos,
  RegExpr, MatReal,
  uauxiliares,
  uversion_architexto,
  uConstantesSimSEE,
  uparseadorsupersimple;

resourcestring
  rs_NoSeEncuentraArchivo = 'No se encuentra el archivo: ';
  rs_ElArchivo = 'El archivo';
  rs_VersionPosterior =
    'esta escrito con una versión posterior a la instalada. Debe actualizar el software.';
  rs_NoInstanciasDe = 'No hay instancias de cosas de la clase';

const
  formatoReales = ffFixed;


// función para comparar TCapa por nid y ordenar
  function compare_nid_capa( c1, c2: pointer ): integer;


type
  TProcMsg = procedure(msg: string);
  TArchiTexto = class; // definido más adelante.

  // Atención esta clase sirve de base para definir TCatalogoReferencias en uCosaConNombre
  // y permite aquí pasar como parametro un Catalogo evitando la refencia circular de las
  // unidades
  TCatalogo = class
    abstract
  end;

  { TEvaluadorConCatalogo }

  TEvaluadorConCatalogo = class(TEvaluadorExpresionesSimples)
    Catalogo: TCatalogo;
    constructor Create(Catalogo_: TCatalogo);
  end;

  // Define la referenica a un archivo externo.
  // se utiliza para centralizar las dependencias.
  TArchiRef = class
  private
    archiRefStr: string;
    function get_archi: string;
    procedure set_archi(const archi_str: string);

  public
    constructor Create(archiRef_: string);
    procedure Free; virtual;

    // testea si el archivo existe, si no lo encuentra lo busca
    // en la lista global de cmaminos de búsqueda y modifica archiRefStr
    // apuntando al lugar completo. Retorna TRUE si el archivo existe.
    function testearYResolver: boolean;
    property archi: string read get_archi write set_archi;
  end;


  // Clase de todas las cosas que usamos en una sala.
  { TCosa }
  TCosa = class;
  TListaDeCosas = class;
  TClaseDeCosa = class of TCosa;

  TDAofCosa = array of TCosa;

  { TCapa }

  { TCosaRec }

  TCosaRec = class
    cosa, padre: TCosa;
    constructor Create( cosa_, padre_: TCosa );
  end;


  TCapa = class
    nid: integer;
    CosaRecs: TList;
    constructor Create( nid: integer );
    procedure AddCosa( aCosa, Padre: TCosa );
    destructor Destroy; override;
  end;

  { TCosa_CampoDef }

  { TCosa_CampoDef_BASE }

  TCosa_CampoDef_BASE = class
    nombreCampo: string;
    version_on: integer;
    version_off: integer;
    defVal: string;
    constructor Create(nombre: string; version_on, version_off: integer;
      defVal: string);
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; virtual;
    function Devaluar( var aVar ): string; virtual; abstract;
  end;

  TCosa_CampoDef_Stringeable = class( TCosa_CampoDef_BASE );

  { TCosa_CampoDef_Integer }

  TCosa_CampoDef_Integer = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_Float }

  TCosa_CampoDef_Float = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_String }

  TCosa_CampoDef_String = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_Boolean }

  TCosa_CampoDef_Boolean = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_DateTime }

  TCosa_CampoDef_DateTime = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_DAOfNInt }

  TCosa_CampoDef_DAOfNInt = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_DAOfNReal }

  TCosa_CampoDef_DAOfNReal = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_TVectR }

  TCosa_CampoDef_TVectR = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;


  { TCosa_CampoDef_DAOfBoolean }

  TCosa_CampoDef_DAOfBoolean = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_DAOfString }

  TCosa_CampoDef_DAOfString = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_StringList }

  TCosa_CampoDef_StringList = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_ListaDeCosas }

  TCosa_CampoDef_ListaDeCosas = class(TCosa_CampoDef_Base)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
  end;

  { TCosa_CampoDef_Fecha }

  TCosa_CampoDef_Fecha = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_Cosa }

  TCosa_CampoDef_Cosa = class(TCosa_CampoDef_Base)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_CosaRef }

  TCosa_CampoDef_CosaRef = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  { TCosa_CampoDef_ArchRef }

  TCosa_CampoDef_ArchRef = class(TCosa_CampoDef_Stringeable)
    function Evaluar(var aVar; referente: TCosa; const str: string;
      Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean; override;
    function Devaluar( var aVar ): string; override;
  end;

  // Definición del Record de una Cosa.

  { TCosa_RecDef }

  TCosa_RecDef = class(TList) // Lista de TCosa_CampoDef
    procedure Free;
  end;

  { TCosa_RecLnk }

  TCosa_RecLnk = class(TList)
  // Esta variable se pone a TRUE por defecto en el Create
  // En la medida en que se vayan traduciendo los formularios de edición
  // se debe poner a FALSE en AfterRead de la Cosa para que no Devalue al
  // guardar. Esto se hace para permitir la migración del Editor formulario
  // a formulario.
    flg_DevaluarAntesDeGuardar: boolean;
    aCosa: pointer;
    RecDef: TCosa_RecDef;
    constructor Create(var aCosa: TCosa);

    procedure addCampoDef(nombre: string; var aObjectVar: integer;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '0';
      pbool_cond_read: pboolean = nil); overload;
    procedure addCampoDef(nombre: string; var aObjectVar: NReal;
      version_on: integer = 0; version_off: integer = 0;
      DefVal: string = '0.0'; pbool_cond_read: pboolean = nil); overload;
    procedure addCampoDef(nombre: string; var aObjectVar: string;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil); overload;
    procedure addCampoDef(nombre: string; var aObjectVar: TDateTime;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '0';
      pbool_cond_read: pboolean = nil); overload;
    procedure addCampoDef(nombre: string; var aObjectVar: boolean;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = 'F';
      pbool_cond_read: pboolean = nil); overload;

    procedure addCampoDef(nombre: string; var aObjectVar: TDAofNInt;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil);
      overload;

    procedure addCampoDef(nombre: string; var aObjectVar: TDAofNReal;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil);
      overload;
    procedure addCampoDef(nombre: string; var aObjectVar: TVectR;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil);
      overload;


    procedure addCampoDef(nombre: string; var aObjectVar: TDAOfBoolean;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil);
      overload;
    procedure addCampoDef(nombre: string; var aObjectVar: TDAOfString;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil);
      overload;
    procedure addCampoDef(nombre: string; var aObjectVar: TStringList;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil);
      overload;

    procedure addCampoDef(nombre: string; var aObjectVar: TFecha;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '0';
      pbool_cond_read: pboolean = nil);
      overload;
    procedure addCampoDef(nombre: string; var aObjectVar: TList;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil);
      overload;

    procedure addCampoDef(nombre: string; var aObjectVar: TCosa;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil);
      overload;

    procedure addCampoDef_ref(nombre: string; var aObjectVar: TCosa;
      Referente: TCosa; version_on: integer = 0; version_off: integer = 0;
      DefVal: string = ''; pbool_cond_read: pboolean = nil); overload;

    procedure addCampoDef_archRef(nombre: string; var aObjectVar: TArchiRef;
      version_on: integer = 0; version_off: integer = 0; DefVal: string = '';
      pbool_cond_read: pboolean = nil);
      overload;

    // Lee un campo cantidad NombreCantidad y luego la misma cantidad de vectores de reales
    // todos con el mismo NombreItem
    // Esta función es por compatibilidad con una versión antigua de escritura
    procedure addCampoDef_Array_OLD1_(NombreCampoCantidad: string;
    // NombreCantidad
      NombreCampoItems: string;
    // NombreItem hay tantos con el mismo nombre como lo que vengan en Cantiadad
      var aObjectVar: TDAOfDAOfNReal; //  TDAOfDAOfNReal Vector de Vectores items.
      version_on: integer = 0; version_off: integer = 0);

    // LEe el campo Cantindad y luego tantos recors de items (con sus respectivos nombres) como
    // Indique cantidad. En ObjectVar
    procedure addCampoDef_DAOfDAOfStr_OLD2_(NombreCampoCantidad: string;
    // NombreCantidad
      NombresItems: array of string;
    // NombreItem hay tantos con el mismo nombre como lo que vengan en Cantiadad
      var aObjectVar: TDAofDAofString; //  TDAOfDAOfNReal Vector de Vectores items.
      version_on: integer = 0; version_off: integer = 0);

    procedure Free;

    // Recorre los campos y evalua la versión STRING hacia las variables
    // Retorna la cantidad de FALLOS de evaluación
    function Evaluar(Referente: TCosa; evaluador: TEvaluadorConCatalogo; flg_save: boolean): integer;

    // Recorre los campos y Devalua de la Instancia hacia la versión String.
    procedure Devaluar;

    // Elimina los registros que no PERSISTEN en la version pasada como parámetro
    // Este método debe ser ejecutado luego de leer una instancia, para dejar
    // el Rec_Lnk LIMPIO.
    function Destilar(version: integer): integer;

  private
    // Variables auxiliares inicializadas en Create y usadas por los addCampoDef_xxx
    kCampo: integer;
    flg_creando_def: boolean;

    procedure acd_(const aCampoDef: TCosa_CampoDef_BASE; var ObjectVar;
      pbool_cond_read: pboolean);
  end;

  { TCosa_CampoLnk }
  TCosa_CampoLnk = class
    CampoDef: TCosa_CampoDef_base;
    Parent_RecLnk: TCosa_RecLnk;
    StrVal: ansistring;
    pval: pointer;
    pbool_cond_read: pboolean;

    constructor Create(const CampoDef: TCosa_CampoDef_base;
      const Parent_RecLnk: TCosa_RecLnk; pval: pointer; pbool_cond_read: pboolean);
    function nombre: string;
    // retorna StrVal
    function GetStrVal: string;

    // fija StrVal
    procedure SetStrVal(sVal: string; evaluador: TEvaluadorConCatalogo);

    function Evaluar(Referente: TCosa; Evaluador: TEvaluadorConCatalogo;
      flg_save: boolean): boolean;

    procedure Devaluar;

    procedure UsarDefault;

    // Aplicable(Version) retorna TRUE si el registro es aplicable
    // a la version.
    // -2 = No aplicable por condición previa. (pbool^ = FALSE).
    // -1 = NO aplicable por OBSOLETO
    //  0 = Campo disponible LEER
    //  1 = Campo nuevo USAR DEFAULT


    function aplicable(version: integer): integer;
  end;



  TCosa = class
  public
  var
    capa: integer;

    // Lista de Campos Destilada luego de la lectura
    rec_lnk: TCosa_RecLnk;

    // Retorna lista de campos asociados a la instacia
    function Rec: TCosa_RecLnk; virtual;

    procedure BeforeRead(version, id_hilo: integer); virtual;
    procedure AfterRead(version, id_hilo: integer); virtual;

    // Este create es solo a los efectos de ser usado en el registo
    // de clases para que se cree la definición de campos persistentes.
    constructor Create_dummy; virtual;
    procedure Free_dummy; virtual;

    constructor Create; overload; virtual;
    constructor Create(capa: integer); overload; virtual;

    constructor Create_ReadFromText(f: TArchiTexto); virtual;
    procedure WriteToText_(f: TArchiTexto); virtual;

    // crea el archivo y lo sobreescribe si existe y llama a WriteToText
    procedure WriteToArchi(archi: string);

    // retorna el texto como se guarda en el archivo de texto de  la sala.
    function asMemo(idHilo: integer): TStrings;
    class function Create_FromMemo(CatalogReferencias: TCatalogo;
      idHilo: integer; const memo: TStrings): TCosa;

    function Create_Clone(CatalogoReferencias: TCatalogo; idHilo: integer): TCosa;
      virtual;

    // obtiene el string infoAd pero lo recorta a 20 caracteres.
    function InfoAd_20: string;
    function InfoAd_: string; virtual;

    class function DescClase: string; virtual;

    procedure Free; virtual;
    function Apodo: string; virtual;
    // en las cosas con nombre retorna el nombre, en las sin nombre retonra '-'

    procedure ActivarCapas(const capasActivas: TDAOfNInt); virtual;
    function Validate: boolean; virtual;


    // Las funciones SetValXXX fijan el ValStr de Campo_Lnk y activan la
    // flg_GuardarStrVal que indica que ese campo fue actualizado por esta
    // vía y po tanto se guarada el StrVal

    // Los editores deberían usar exclusivamente estas funciones
    // para acceder a los campos persitentes
    function GetValStr(nombreCampo: string): string;
    procedure SetValStr(nombreCampo, nuevoValor: string;
      Evaluador: TEvaluadorConCatalogo);

    function GetFieldByName(nombreCampo: string): TCosa_CampoLnk;


    function Evaluar(Referente: TCosa; evaluador: TEvaluadorConCatalogo; flg_save:  boolean ): integer;
    procedure Devaluar;


    procedure AgregarDefinicionesEvaluador(eval: TEvaluadorExpresionesSimples); virtual;

    procedure AddToCapasLst(capas: TList; padre: TCosa); virtual;
  end;

  TCualquierClase = class of TObject;

  TDAOfTCosa = array of TCosa;

  { TFichaClase }
  TFichaClase = class
  public
    strClaseId: string;
    clase: TClaseDeCosa;
    recDef: TCosa_RecDef;
    constructor Create(strClaseID: string; clase: TClaseDeCosa);
    procedure Free;
  end;

  { TListaDeCosas }
  TListaDeCosas = class(TCosa)
    function getItem(i: integer): TCosa;
    procedure setItem(i: integer; cosa: TCosa);
    function getCapacity: integer;
    procedure setCapacity(newCapacity: integer);

  public
    lst: TList;

    idCarpeta: string; // identificador para salvar en carpeta
    constructor Create(capa: integer; idCarpeta: string);

    constructor Create_ReadFromText(f: TArchiTexto); override;
    procedure WriteToText_(f: TArchiTexto); override;
    function Add(cosa: TCosa): integer; virtual;

    //Si freeElementos = true llama a ClearFreeElementos, sino a Clear,
    //luego hace add de todas las cosas en listaDeCosas
    procedure ponerIgualA(listaDeCosas: TListaDeCosas; freeElementos: boolean);
    procedure ActivarCapas(const CapasActivas: TDAOfNInt); override;
    procedure Free; override;
    //Libera la lista sin destruir los objetos que contiene
    procedure FreeSinElemenentos;
    function Count: integer;
    procedure insert(indice: integer; cosa: TCosa);
    function Remove(cosa: TCosa): integer;
    procedure Delete(indice: integer);
    procedure Pack;
    procedure Exchange(indice1, indice2: integer);
    function IndexOf(cosa: TCosa): integer;
    function replace(cosaARemplazar, cosaNueva: TCosa): integer;
    procedure Clear;
    procedure ClearFreeElementos;
    procedure Sort(Compare: TListSortCompare);
    function getList: TList;
    function toArray: TDAOfTCosa;
    property Capacity: integer read getCapacity write setCapacity;
    property items[i: integer]: TCosa read getItem write setItem; default;
  end;

(* La función ProcesoLineaRes puede retornar laguno de los siguientes
valores. No se prevé un código de error pues la función lanza
excepciones con cualquier error que detecte. *)
  TResultadoProcesoLinea = (
    CTPLR_CONTINUAR,   // continuar procesando
    CTPLR_FIN_OBJETO,  // se llegó al fin del objeto (cerrar la lista)
    CTPLR_ABRIR_NUEVO_OBJETO); // Se encontró un objeto abrir otra lista

  TTipoCampo = (
    CTC_NReal,
    CTC_String,
    CTC_ArchRef,
    CTC_NInt,
    CTC_NCardinal,
    CTC_Boolean,
    CTC_DAOfNReal,
    CTC_DAOfNInt,
    CTC_DAOfBoolean,
    CTC_DAOfString,
    CTC_StringList,
    CTC_Fecha,
    CTC_TDataRowOfCosa,
    CTC_Cosa,
    CTC_Referencia);


  TProcFijarValorPorDefecto = procedure(const nombre: string;
    pVal: Pointer; tipo: TTipoCampo; const klinea: integer);

  { TListCamposParaLeer }
  TListCamposParaLeer = class(TList)
  public
    cosa: TCosa;
    Catalogo: TCatalogo;

    leiFinDeObjeto: boolean;
    constructor Create(Catalogo: TCatalogo; IdentificadorDeLaClaseDelObjeto: string);
    procedure Esperar_NReal(const Nombre: string; var Variable: NReal;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_String(const Nombre: string; var Variable: string;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_ArchRef(const Nombre: string; var Variable: TArchiRef;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_NInt(const Nombre: string; var Variable: integer;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_NCardinal(const Nombre: string; var Variable: cardinal;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_Boolean(const Nombre: string; var Variable: boolean;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_DAOfNReal(const Nombre: string; var Variable: TDAOfNReal;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_DAOfNInt(const Nombre: string; var Variable: TDAOfNInt;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_DAOfBoolean(const Nombre: string; var Variable: TDAOfBoolean;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_DAOfString(const Nombre: string; var Variable: TDAOfString;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_StringList(const Nombre: string; var Variable: TStringList;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_Fecha(const Nombre: string; var Variable: TFecha;
      proc_vpd: TProcFijarValorPorDefecto); overload;
    procedure Esperar_Fecha(const Nombre: string; var Variable: TFecha;
      proc_vpd: TProcFijarValorPorDefecto; flgError: integer); overload;
    procedure Esperar_Cosa(const Nombre: string; var Variable: TCosa;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_Referencia(const Nombre: string; var Variable: TCosa;
      proc_vpd: TProcFijarValorPorDefecto; referente: TCosa);
    function ProcesarLinea(klinea: integer; linea: string; var extres: string;
      var ColumnName: string): TResultadoProcesoLinea;
    procedure Free;
  private
    IdentificadorDeLaClaseDelObjeto: string; // identificador de la clase de objeto
    lineaAbierta: boolean;
    xNombre, xval: string; // valores bajo procesamiento
    procedure ResolverCampoValor(const xNombre, xVal: string);
    procedure Ejecutar_vpds(klinea: integer);
    procedure Ejecutar_vpd(klinea: integer; nombreCampo: string);
{$IFDEF DBG}
    //Para debug, muestra los campos que la lista tiene por leer
    function NombresCamposPorLeer: TDAofString;
{$ENDIF}
  end;

  TCampoParaLeer = class
  public
    nombre: string;
    tipo: TTipoCampo;
    pVal: pointer;
    proc_vpd: TProcFijarValorPorDefecto;
    referente: TCosa;
    flgError: integer; // 0 es showmessage, 1 no muestra nada
    constructor Create(const Nombre: string; pVal: Pointer; Tipo: TTipoCampo;
      proc_vpd: TProcFijarValorPorDefecto); overload;
    constructor Create(const Nombre: string; pVal: Pointer; Tipo: TTipoCampo;
      proc_vpd: TProcFijarValorPorDefecto; flgError: integer); overload;
    constructor Create(const Nombre: string; pVal: Pointer; Tipo: TTipoCampo;
      proc_vpd: TProcFijarValorPorDefecto; referente: TCosa); overload;
    procedure Ejecutar_vpd(const klinea: integer);
  end;

  ExcepcionNoSePidioElCampo = class(Exception)
  end;

  ExcepcionResolverCampoValor = class(Exception)
  end;

  ExcepcionClaseNoRegistrada = class(Exception)
  end;

  ExcepcionPersistentAttributeDoesNotHasProperty = class(Exception)
  end;

  ExcepcionPersistentPropertyHasToPointAtAttribute = class(Exception)
  end;

  { TListaDeObjetosPorLeer }
  TListaDeObjetosPorLeer = class(TList)
  public
    Catalogo: TCatalogo;
    constructor Create(Catalogo: TCatalogo);
    procedure Free;
    function ListaActiva: TListCamposParaLeer;
    procedure FreeListaPorLeer; // libera la última lista(cerró objeto)
    procedure InicioObjeto(const NombreClase: string);
    procedure FinalObjeto;
  end;

  { TArchiTexto }

  TArchiTexto = class
  public
    idHilo: integer;
    klinea: integer;
    Version: integer;
    nombreArchivo: string;
    aux_idCarpeta: string;
    // auxiliar para pasaje de parámetros de TListaDeCosas CreateReadFromText

    unArchivoPorCosa: boolean;
    padre: TArchiTexto;
    ramas: TList;

    CatalogoReferencias: TCatalogo;

    evaluador: TEvaluadorConCatalogo;

    constructor CreateForRead(idHilo: integer; // identifica el Hilo
    // Usa este catalogo para cargar las referencias no resueltas.
      CatalogoReferencias: TCatalogo; const nombreArchivo: string;
      abortarEnError: boolean);

    constructor CreateForWrite(const nombreArchivo: string;
      crearBackupSiExiste: boolean; maxNBackups: integer);

    procedure Free;
    function NextLine: string;
    procedure writeline(const s: string);

    procedure wr(const nombre: string; const valor: NReal; precision: integer;
      decimales: integer); overload;
    procedure wr(const nombre: string; const valor: NReal); overload;
    procedure wr(const nombre: string; const valor: string); overload;
    procedure wrArchRef(const nombre: string; const valor: TArchiRef);
    procedure wr(const nombre: string; const valor: NInt); overload;
    procedure wr(const nombre: string; const valor: cardinal); overload;
    procedure wr(const nombre: string; const valor: boolean); overload;
    procedure wr(const nombre: string; const valor: TDAOfNReal;
      precision: integer; decimales: integer); overload;
    procedure wr(const nombre: string; const valor: TDAOfNReal); overload;
    procedure wr(const nombre: string; const valor: TDAOfNInt); overload;
    procedure wr(const nombre: string; const valor: TDAOfBoolean); overload;
    procedure wr(const nombre: string; const valor: TDAOfString); overload;
    procedure wr(const nombre: string; const valor: TStringList); overload;
    procedure wr(const nombre: string; const valor: TFecha); overload;
    procedure wrReferencia(const nombre: string; const valor: TCosa);
    procedure wr(const nombre: string; const valor: TCosa); overload;

    procedure rd(const nombre: string; var valor: NReal); overload;
    procedure rd(const nombre: string; var valor: string); overload;
    procedure rdArchRef(const nombre: string; var valor: TArchiRef);
    procedure rd(const nombre: string; var valor: NInt); overload;
    procedure rd(const nombre: string; var valor: cardinal); overload;
    procedure rd(const nombre: string; var valor: boolean); overload;
    procedure rd(const nombre: string; var valor: TDAOfNReal); overload;
    procedure rd(const nombre: string; var valor: TDAOfNInt); overload;
    procedure rd(const nombre: string; var valor: TDAOfString); overload;
    procedure rd(const nombre: string; var valor: TDAOfBoolean); overload;
    procedure rd(const nombre: string; var valor: TStringList); overload;
    procedure rd(const nombre: string; var valor: TFecha); overload;
    // flgError= 0 lo mismo que sin flg. flgError= 1 no avisa del error
    procedure rd(const nombre: string; var valor: TFecha; flgError: integer); overload;
    procedure rd(const nombre: string; var valor: TCosa); overload;
    procedure rdReferencia(const nombre: string; var valor: TCosa; referente: TCosa);


    procedure EjecutarLectura_;

    function CreateRamaForWrite(
      const Carpeta, NombreClase, NombreCosa: string): TArchiTexto;

    function CreateRamaForRead(CatalogoReferencias: TCatalogo;
      const Carpeta, NombreClase, NombreCosa: string): TArchiTexto;
  private
    f: textfile;
    f_abierto: boolean;

    listaObjetosPorLeer: TListaDeObjetosPorLeer; //TListCamposParaLeer;
    abortarEnError: boolean;
    oldFileMode: byte;

    indentstr: string;
    function EOF: boolean;
    function quedanCosasDelObjetoActualPorLeer(claseObjeto: string): boolean;
    function ListaPorLeer: TListCamposParaLeer;

    procedure ReadCosaFromText(var cosa: TCosa; cosaStrId: string);

  end;



procedure ValorPorDefectoNulo(const nombre: string; pVal: Pointer;
  tipo: TTipoCampo; const klinea: integer);
procedure ValorPorDefecto_ERROR(const nombre: string; pVal: Pointer;
  tipo: TTipoCampo; const klinea: integer);

var
  registro_de_ClasesDeCosas_: TList;


  procMsgValorPorDefecto: TProcMsg;
  procMsgErrorLectura: TProcMsg;
  procMsgAdvertenciaLectura: TProcMsg;

  MrFlag: boolean = False;

  pAux: TCosa;

{$IFDEF CNT_COSAS}
type
  TCntCosasClase = class
  private
    clase: TClass;
    cnt: integer;
  public
    constructor Create(xclase: TClass);
  end;

  TCntCosas = class
  private
    CntCosasClases: TList {of TCntCosasClase};
  public
    cnt_Cosas: integer;

    constructor Create;
    function incCntCosasClase(clase: TClass): integer;
    function decCntCosasClase(clase: TClass): integer;
    function CntCosasClase(clase: TClass): integer;
    procedure Free;
  end;

var
  CantCosas: TCntCosas;

{$ENDIF}

function registrarClaseDeCosa(const nombre: string; Clase: TClaseDeCosa): integer;

// Busca la Ficha de registro de la clase.
// Si no encuentra devuelve NIL.
function getFichaClase(const nombre: string): TFichaClase;

function getClaseOf(const nombre: string): TCualquierClase;

// si la clase no está registrada retorna '<CLASE_NO_REGISTRADA>'
function getIdStrOf(clase: TClaseDeCosa): string;

//Retorna TRUE si la clase child está en el árbol de herencias de la clase
// Parent y false en caso contrario.
function IsChild(Parent, Child: string): boolean; overload;
function IsChild(Parent, Child: TClass): boolean; overload;

function ListarRegistroDeClases: TStringList;

procedure LimpiarRegistroDeClasesDeCosas;

// Retorna la cadena de padres separados por '->'
function ParentsStrList(clase: TClass): string;

procedure AlInicio;
procedure AlFinal;

procedure FreeAndNil(var obj: TCosa);
function referenciaACosa(cosa: TCosa): string;

type
  ExceptionFileNotFound = class(Exception)
  public
    arch: string;
    constructor Create(arch, comentarios: string);
  end;


var
  // Lista de referencias a archivos externos.
  ReferenciasAArchivosExternos: TList;

  // Lista de caminos de búsquedas de los archivos externos.
  // La aplicación debe agregar aquí las rutas de búqueda que
  // se deben usar en la función testear de las referencias a
  // archivos.
  lista_caminos: TBuscaArchivos;


// retorna la constante de versión de formato de sala almacenada en la unidad
// uversion_architexto
function version_ArchiTexto: integer;


implementation

uses
  //  uVirtualTablesDefs,
  uCosaConNombre, usalasdejuego, uFuenteConstante, uActores, unodos,
  ufichasLPD, udemandadetallada;

var
  global_FlgError: integer;


function version_ArchiTexto: integer;
begin
  Result := uversion_architexto.version_ArchiTexto;
end;

{ TCosaRec }

constructor TCosaRec.Create(cosa_, padre_: TCosa);
begin
  inherited Create;
  cosa:= cosa_;
  padre:= padre_;
end;

{ TCapa }

constructor TCapa.Create(nid: integer);
begin
  inherited Create;
  self.nid:= nid;
  cosaRecs:= TList.Create;
end;

procedure TCapa.AddCosa(aCosa, Padre: TCosa);
begin
  cosaRecs.Add( TCosaRec.Create(aCosa, Padre) );
end;

destructor TCapa.Destroy;
var
  k: integer;
begin
  for k:= 0 to cosaRecs.Count-1 do
    TCosaRec( cosaRecs[k] ).Free;
  cosaRecs.Clear;
  inherited Destroy;
end;


{ TEvaluadorConCatalogo }

constructor TEvaluadorConCatalogo.Create(Catalogo_: TCatalogo);
begin
  inherited Create;
  Catalogo := Catalogo_;
end;


{ TCosa_CampoDef_ArchRef }

function TCosa_CampoDef_ArchRef.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean;
var
  ts: string;
  dummy, xvar: TArchiRef;
begin
  ts := str;
   {$IFDEF LINUX}
  toLinuxDir(ts);
   {$ENDIF}
   dummy:= TArchiref.create( ts );
   if flg_save  then
   begin
     xvar:= TArchiRef(avar);
     if xvar <> nil then xvar.Free;
     xvar:= dummy;
   end;
  Result := True;
end;

function TCosa_CampoDef_ArchRef.Devaluar(var aVar): string;
var
  valor: TArchiRef;
begin
  valor:= TARchiRef( aVar );
  if valor <> nil then
    result:= valor.archiRefStr
  else
    result:= '';
end;


{ TCosa_CampoDef_CosaRef }

function TCosa_CampoDef_CosaRef.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  nombreRef, clase: string;

begin
  nombreRef := '';
  clase := '';
  parsearReferencia(str, clase, nombreRef);

(****
  ATENCION, esto estaba así y lo dejo porque no termino de entender
  pero me parece que el Evaluar deviera chequear que la Cosa a la que se
  refiere existe y resolver la referencia. Pero por otro lado puede ser que
  para resolver las referencias se precise mas que el catálogo (se precisa la lista
  de referencias ...) entonces por ahora lo dejo así.
***)

raise Exception.Create( 'TCosa_CampoDef_CosaRef.Evaluar' ); // SOLO PARA ASEGURARNOS QUE NO SE USA

  if (clase <> '?') then
    TCatalogoReferencias(evaluador.Catalogo).registrar_referencia(referente,
      clase, nombreRef, aVar)
  else
    TCosa(aVar) := nil;
  Result := True;
end;

function TCosa_CampoDef_CosaRef.Devaluar(var aVar): string;
begin
  result:= referenciaACosa( TCosa( aVar ) );
end;

{ TCosa_CampoDef_Cosa }

function TCosa_CampoDef_Cosa.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  aCosa: TCosa;
begin
  aCosa := TCosa(aVar);
  if aCosa = nil then
    Result := True
  else
    Result := TCosa(aVar).rec_lnk.Evaluar(referente, evaluador, flg_save ) = 0;
end;

function TCosa_CampoDef_Cosa.Devaluar(var aVar): string;
var
  aCosa: TCosa;
begin
  aCosa := TCosa(aVar);
  if aCosa <> nil then
    TCosa(aVar).rec_lnk.Devaluar;
end;

{ TCosa_CampoDef_Fecha }

function TCosa_CampoDef_Fecha.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  dummy: TFecha;
begin
  try
    dummy:=  TFecha.Create_str(str);
    if flg_save then
    begin
      if TFecha(aVar) <> nil then TFecha(aVar ).Free;
      TFecha(aVar):= dummy
    end
    else
      dummy.Free;
    result:= true;
  except
    result:= false;
  end;
end;

function TCosa_CampoDef_Fecha.Devaluar(var aVar): string;
var
  valor: TFecha;
begin
  valor:= TFecha( aVar );
  if valor <> nil then
    result:= valor.AsStr
  else
    result:= '0';
end;

{ TCosa_CampoDef_ListaDeCosas }

function TCosa_CampoDef_ListaDeCosas.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  res: boolean;
  aCosa: TCosa;
  lst: TListaDeCosas;
  k: integer;
begin
  res := True;
  if lst <> nil then
  begin
    lst := TListaDeCosas(aVar);
    for k := 0 to lst.Count - 1 do
    begin
      aCosa := lst[k];
      if aCosa.rec_lnk.Evaluar(Referente, evaluador, flg_save ) > 0 then
      begin
        res := False;
        break;
      end;
    end;
  end;
  Result := res;
end;

{ TCosa_CampoDef_StringList }

function TCosa_CampoDef_StringList.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  dummy: TStringList;
begin
  if flg_save then
   parseStringList(TStringList(aVar), str)
  else
  begin
   parseStringList( dummy, str);
   dummy.Free;
  end;
  result:= true;
end;

function TCosa_CampoDef_StringList.Devaluar(var aVar): string;
var
  k: integer;
  valor: TStringList;
  res: string;
begin
  valor:= TStringList( aVar );
  res:=  '['+ IntToStr( valor.Count )+'| ';
  if valor.Count > 0 then
  begin
    res:= res + valor[0];
    for k := 1 to valor.Count - 1 do
    begin
      res:= res + ', '+valor[k];
    end;
  end;
  result:= res + ']';
end;

{ TCosa_CampoDef_DAOfString }

function TCosa_CampoDef_DAOfString.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  dummy: TDAOfString;
begin
  if flg_save then
    parseDAOfString(TDAOfString(aVar), str)
  else
  begin
    parseDAOfString( dummy, str);
    setlength( dummy, 0 );
  end;
  result:= true;
end;

function TCosa_CampoDef_DAOfString.Devaluar(var aVar): string;
var
  k: integer;
  valor: TDAOfString;
  res: string;
begin
  valor:= TDAOfString( aVar );
  res:= '['+IntToStr( length(valor) ) + '| ';
  if length(valor) > 0 then
  begin
    res:= res + valor[0];
    for k := 1 to high(valor) do
    begin
      res:= res + ', '+valor[k];
    end;
  end;
  res:= res + ']';
  result:= res;
end;

{ TCosa_CampoDef_DAOfBoolean }

function TCosa_CampoDef_DAOfBoolean.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  dummy: TDAOfBoolean;
begin
  if flg_save then
    parseDAOfBoolean(TDAOfBoolean(aVar), str)
  else
  begin
    parseDAOfBoolean( dummy, str);
    setlength( dummy, 0 );
  end;
  result:= true;
end;

function TCosa_CampoDef_DAOfBoolean.Devaluar(var aVar): string;
var
  k: integer;
  res: string;
  valor: TDAOfBoolean;
begin
  valor:= TDAOfBoolean( aVar );
  res:= '['+ IntToStr( length(valor))+ '| ';
  if length(valor) > 0 then
  begin
    res:= res + BoolToStr( valor[0], '1', '0' );
    for k := 1 to high(valor) do
      res:= res +  ', '+  BoolToStr( valor[k], '1', '0' );
  end;
  res:= res + ']';
  result:= res;
end;

{ TCosa_CampoDef_DAOfNReal }

function TCosa_CampoDef_DAOfNReal.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  xvar: TDAOfNReal;
begin
  try
   if flg_save then
     parseDAOfNreal(TDAofNReal(aVar), str)
   else
   begin
     parseDAOfNreal(xvar, str);
     setlength( xvar, 0 );
   end;
    result:= true;
  except
    result:= false;
  end;
end;

function TCosa_CampoDef_DAOfNReal.Devaluar(var aVar): string;
var
  k: integer;
  res: string;
  valor: TDAOfNReal;
begin
  valor:= TDAOfNReal( aVar );
  res:= '['+ IntToStr( length(valor))+ '| ';
  if length(valor) > 0 then
  begin
    res:= res + FloatToStrF( valor[0], ffFixed, CF_PRECISION, CF_DECIMALES );
    for k := 1 to high(valor) do
      res:= res +  ', '+ FloatToStrF( valor[k], ffFixed, CF_PRECISION, CF_DECIMALES );
  end;
  res:= res + ']';
  result:= res;
end;



{ TCosa_CampoDef_TVectR }

function TCosa_CampoDef_TVectR.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  xvar: TDAOfNReal;
begin
  try
   parseDAOfNreal(xvar, str);
   if flg_save then
   begin
     if TVectR( aVar ) = nil then
       TVectR( aVar ):= TVectR.Create_FromDAofR( xvar )
     else
     begin
       TVectR( aVar ).Copy( xvar );
     end;
   end
   else
   begin
     setlength( xvar, 0 );
   end;
    result:= true;
  except
    result:= false;
  end;
end;

function TCosa_CampoDef_TVectR.Devaluar(var aVar): string;
var
  k: integer;
  res: string;
  valor: TVectR;
begin
  valor:= TVectR( aVar );
  res:= '['+ IntToStr( valor.n )+ '| ';
  if valor.n > 0 then
  begin
    res:= res + FloatToStrF( valor.e(1), ffFixed, CF_PRECISION, CF_DECIMALES );
    for k := 2 to valor.n do
      res:= res +  ', '+ FloatToStrF( valor.e(k), ffFixed, CF_PRECISION, CF_DECIMALES );
  end;
  res:= res + ']';
  result:= res;
end;



{ TCosa_CampoDef_DAOfNInt }

function TCosa_CampoDef_DAOfNInt.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  xvar: TDAOfNInt;
begin
  try
  if flg_save then
   parseDAOfNInt(TDAOfNInt(aVar), str)
  else
  begin
    parseDAOfNInt( xvar, str);
    setlength( xvar, 0 );
  end;
  result:= true;


  except
    result:= false;
  end;
end;

function TCosa_CampoDef_DAOfNInt.Devaluar(var aVar): string;
var
  k: integer;
  res: string;
  valor: TDAOfNInt;
begin
  valor:= TDAOfNInt( aVar );
  res:= '['+ IntToStr( length(valor))+ '| ';
  if length(valor) > 0 then
  begin
    res:= res + IntToStr( valor[0] );
    for k := 1 to high(valor) do
      res:= res +  ', '+ IntToStr( valor[k] );
  end;
  res:= res + ']';
  result:= res;
end;

{ TCosa_CampoDef_DateTime }

function TCosa_CampoDef_DateTime.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  xvar: TDateTime;
begin
  try
    xvar := IsoStrToDateTime(str);
    if flg_save then
     TDateTime(avar):= xvar;
    Result := True;
  except
    Result := False;
  end;
  (**** POR AHORA NO EVALUAMOS FECHAS ****)
end;

function TCosa_CampoDef_DateTime.Devaluar(var aVar): string;
begin
  result:= DateTimeToIsoStr( TDateTime( aVar ) );
end;

{ TCosa_CampoDef_Boolean }

function TCosa_CampoDef_Boolean.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  s: string;
  xvar: boolean;
begin
  s := LowerCase(trim(str));
  if (s = '') or (s = 'f') or (s = 'false') or (s = 'falso') then
    s := '0'
  else if (s = 't') or (s = 't') or (s = 'true') or (s = 'verdadero') or
    (s = 'v') then
    s := '1'
  else
    s := trim(str);
  Result := Evaluador.Evaluar( xvar, s);
  if flg_save then
   boolean(aVar):= xvar;
end;

function TCosa_CampoDef_Boolean.Devaluar(var aVar): string;
begin
  if boolean( aVar ) then
   result:= '1'
  else
   result:= '0';
end;

{ TCosa_CampoDef_String }

function TCosa_CampoDef_String.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
begin
  if flg_save then
    string(aVar) := str;
  // Para llamar el evaluador sobre campos string hay que resolver primero
  // el tema de los strings que representan string_list pero como un solo string
  // como es el caso de la Descripción de la Sala.
  // Result:= Evaluador.Evaluar( String( aVar ), str );
  Result := True;
end;

function TCosa_CampoDef_String.Devaluar(var aVar): string;
begin
  result:= string( aVar );
end;

{ TCosa_CampoDef_Float }

function TCosa_CampoDef_Float.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  xvar: double;
begin
  Result := Evaluador.Evaluar( xvar, str);
  if flg_save then
    double(aVar):= xvar;
end;

function TCosa_CampoDef_Float.Devaluar(var aVar): string;
begin
  result:= FloatToStrF( NREal( aVar ), ffGeneral, CF_PRECISION, CF_DECIMALES );
end;

{ TCosa_CampoDef_Integer }

function TCosa_CampoDef_Integer.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
var
  xvar: integer;
begin
  Result := Evaluador.Evaluar( xvar, str);
  if flg_save then
    integer(aVar):= xvar;
end;

function TCosa_CampoDef_Integer.Devaluar(var aVar): string;
begin
  result:= IntToStr( NInt( aVar ) );
end;

{ TCosa_CampoLnk }

constructor TCosa_CampoLnk.Create(const CampoDef: TCosa_CampoDef_base;
  const Parent_RecLnk: TCosa_RecLnk; pval: pointer; pbool_cond_read: pboolean);
begin
  self.CampoDef := CampoDef;
  self.Parent_RecLnk := Parent_RecLnk;
  self.StrVal := '';
  // String conteniendo la versión Texto de la variable. (Para los campos primitivos)
  self.pval := pval; // Puntero a la variable
  self.pbool_cond_read := pbool_cond_read;
end;

function TCosa_CampoLnk.nombre: string;
begin
  Result := CampoDef.nombreCampo;
end;

function TCosa_CampoLnk.GetStrVal: string;
begin
  Result := strVal;
end;

procedure TCosa_CampoLnk.SetStrVal(sVal: string; evaluador: TEvaluadorConCatalogo );
begin
  strVal := sVal;
  if evaluador <> nil then
   if Parent_RecLnk <> nil then
    evaluar( Parent_RecLnk.aCosa, evaluador, true )
   else
    evaluar( nil, evaluador, true );
end;

function TCosa_CampoLnk.Evaluar(Referente: TCosa;
  Evaluador: TEvaluadorConCatalogo; flg_save: boolean ): boolean;
begin
  Result := CampoDef.Evaluar(pval^, Referente, StrVal, Evaluador, flg_save );
end;

procedure TCosa_CampoLnk.Devaluar;
begin
  // Aqui lee la variable pvar^ y asigna el valor a strVal
  // Esto sirve para obtener la primera vez la representación de texto.
  StrVal:= CampoDef.Devaluar( pval^ );
end;

procedure TCosa_CampoLnk.UsarDefault;
begin
  StrVal := copy(CampoDef.defVal, 1, length(CampoDef.defVal));
end;

function TCosa_CampoLnk.aplicable(version: integer): integer;
var
  res: integer;
begin
  if (CampoDef.version_off > 0) and (version >= CampoDef.version_off) then
    res := -1 // Campo obsoleto IGNORAR
  else if (version >= CampoDef.version_on) then
    res := 0  // Campo disponible LEER
  else
    res := 1; // Campo nuevo USAR DEFAULT

  if (res >= 0) then
    if (pbool_cond_read <> nil) and not pbool_cond_read^ then
      res := -2; // NO APLICABLE POR CONDICION PREVIA
  Result := res;
end;


//---------------------------------
// Métodos de TArchiRef
//=================================


constructor TArchiRef.Create(archiRef_: string);
begin
  archiRefStr := archiRef_;
  ReferenciasAArchivosExternos.add(self);
end;

procedure TArchiRef.Free;
var
  i: integer;
begin
  i := ReferenciasAArchivosExternos.IndexOf(Self);
  if i >= 0 then
    ReferenciasAArchivosExternos.Delete(i);
  inherited Free;
end;


function TArchiRef.get_archi: string;
begin
  Result := archiRefStr;
end;



procedure TArchiRef.set_archi(const archi_str: string);
begin
  archiRefStr := archi_str;
end;

function TArchiRef.testearYResolver: boolean;
var
  nombre: string;
  camino: string;
  carpeta: string;
  buscando: boolean;
  k: integer;

begin
  if FileExists(archiRefStr) then
    Result := True
  else
  begin
    buscando := lista_caminos.Count > 0;
    k := 0;
    while buscando and (k < lista_caminos.Count) do
    begin
      carpeta := lista_caminos[k];
      if carpeta <> '' then
      begin
        nombre := ExtractFileName(archiRefStr);
        camino := ExtractFilePath(archiRefStr);
        if length(camino) > length(nombre) then
        begin
          Delete(nombre, 1, length(camino));
        end;
        nombre := carpeta + DirectorySeparator + nombre;
        if FileExists(nombre) then
        begin
          archiRefStr := nombre;
          buscando := False;
        end
        else
          Inc(k);
      end;
    end;
    Result := not buscando;
  end;
end;



//---------------------------------
// Métodos de ExceptionFileNotFound
//=================================

constructor ExceptionFileNotFound.Create(arch, comentarios: string);
begin
  inherited Create(rs_NoSeEncuentraArchivo + ': ' + arch + '. ' + comentarios);
  self.arch := arch;
end;


{ TCosa_RecLnk }

constructor TCosa_RecLnk.Create(var aCosa: TCosa);
var
  k: integer;
  aFichaClase: TFichaClase;
begin
  inherited Create;
  flg_DevaluarAntesDeGuardar:= true;

  // Guardamos el Puntero a la Cosa
  self.aCosa := aCosa;

  // Buscamos la Ficha de la Clase en el registor de clases
  aFichaClase := getFichaClase(aCosa.ClassName);

  self.RecDef := aFichaClase.recDef;

  if RecDef = nil then
  begin
    flg_creando_def := True;
    RecDef := TCosa_RecDef.Create;
  end
  else
    flg_creando_def := False;

  kCampo := 0; // índice a la próxima definición de campo
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: integer;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);

var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_Integer.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: NReal;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_Float.Create(nombre, version_on,
      version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: string;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_String.Create(nombre, version_on,
      version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TDateTime;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_DateTime.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: boolean;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_Boolean.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TFecha;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_Fecha.Create(nombre, version_on,
      version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TList;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_ListaDeCosas.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;


procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TDAofNInt;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_DAOfNInt.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TDAofNReal;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_DAOfNReal.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TVectR;
  version_on: integer; version_off: integer; DefVal: string;
  pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_TVectR.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;


procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TDAOfBoolean;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_DAOfBoolean.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TDAOfString;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_DAOfString.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TStringList;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_StringList.Create(
      nombre, version_on, version_off, defVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef(nombre: string; var aObjectVar: TCosa;
  version_on: integer; version_off: integer; DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_Cosa.Create(nombre, version_on, version_off, DefVal)
  else
    aCampoDef := nil;

  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef_ref(nombre: string; var aObjectVar: TCosa;
  Referente: TCosa; version_on: integer; version_off: integer;
  DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_CosaRef.Create(nombre, version_on,
      version_off, DefVal)
  else
    aCampoDef := nil;
  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.addCampoDef_archRef(nombre: string;
  var aObjectVar: TArchiRef; version_on: integer; version_off: integer;
  DefVal: string; pbool_cond_read: pboolean);
var
  aCampoDef: TCosa_CampoDef_BASE;
begin
  if flg_creando_def then
    aCampoDef := TCosa_CampoDef_ArchRef.Create(nombre, version_on,
      version_off, DefVal)
  else
    aCampoDef := nil;
  acd_(aCampoDef, aObjectVar, pbool_cond_read);
end;

procedure TCosa_RecLnk.acd_(const aCampoDef: TCosa_CampoDef_BASE;
  var ObjectVar; pbool_cond_read: pboolean);
begin
  if flg_creando_def then
  begin
    RecDef.Add(aCampoDef);
    add(TCosa_CampoLnk.Create(aCampoDef, self, @ObjectVar, pbool_cond_read));
  end
  else
    add(TCosa_CampoLnk.Create(RecDef.items[kCampo], self, @ObjectVar, pbool_cond_read));
  Inc(kCampo);
end;

procedure TCosa_RecLnk.addCampoDef_Array_OLD1_(NombreCampoCantidad: string;
  NombreCampoItems: string; var aObjectVar: TDAOfDAOfNReal;
  version_on: integer; version_off: integer);
begin

end;

procedure TCosa_RecLnk.addCampoDef_DAOfDAOfStr_OLD2_(NombreCampoCantidad: string;
  NombresItems: array of string; var aObjectVar: TDAofDAofString;
  version_on: integer; version_off: integer);

var
  i, k: integer;
begin
  (*** ALGO COMO ESTO EN EL READ
  f.rd('nEventos', nEventos);
  setlengt( aObjectVar, nEventos);
  for i:= 0 to high( aObjectVar ) do
    setlengt( aObjectVar[i], length( NombreItems );

  for i := 0 to high(eventos) do
    for k:= 0 to high( nombreItems ) do
      f.rd( nombreItems[k], aObjectVar[i][k] );
      ***)
end;


procedure TCosa_RecLnk.Free;
var
  k: integer;
begin
  for k := 0 to Count - 1 do
    TCosa_CampoLnk(items[k]).Free;
  inherited Free;
end;

function TCosa_RecLnk.Evaluar(Referente: TCosa;
  evaluador: TEvaluadorConCatalogo; flg_save: boolean): integer;
var
  k: integer;
  cnt: integer;
  aCampoLnk: TCosa_CampoLnk;
  resb: boolean;
begin
  cnt := 0;
  for k := 0 to Count - 1 do
  begin
    aCampoLnk := items[k];
    resb := aCampoLnk.Evaluar(Referente, evaluador, flg_save );
    if not resb then
      Inc(cnt);
  end;
  Result := cnt;
end;

procedure TCosa_RecLnk.Devaluar;
var
  k: integer;
  aCampoLnk: TCosa_CampoLnk;
begin
  for k := 0 to Count - 1 do
  begin
    aCampoLnk := items[k];
    aCampoLnk.Devaluar;
  end;
end;

function TCosa_RecLnk.Destilar(version: integer): integer;
var
  aRec: TCosa_CampoLnk;
  k: integer;
begin
  k := 0;
  while k < Count do
  begin
    aRec := items[k];
    if aRec.aplicable(version) = -1 then
    begin
      aRec.Free;
      self.Delete(k);
    end
    else
      Inc(k);
  end;
end;


{ TCosa_RecDef }

procedure TCosa_RecDef.Free;
var
  k: integer;
  aRec: TCosa_CampoDef_BASE;
begin
  for k := 0 to Count - 1 do
  begin
    aRec := items[k];
    aRec.Free;
  end;
  inherited Free;
end;

{ TCosa_CampoDef }

constructor TCosa_CampoDef_BASE.Create(nombre: string;
  version_on, version_off: integer; defVal: string);
begin
  inherited Create;
  nombreCampo := nombre;
  self.version_on := version_on;
  self.version_off := version_off;
  self.defVal := DefVal;
end;

function TCosa_CampoDef_BASE.Evaluar(var aVar; referente: TCosa;
  const str: string; Evaluador: TEvaluadorConCatalogo; flg_save: boolean
  ): boolean;
begin
  Result := True;
end;




//-----------------
// Métodos de TCosa
//=================


constructor TCosa.Create;
var
  aFichaClase: TFichaClase;
begin
  inherited Create;
  rec_lnk := nil;
  aFichaClase := getFichaClase(ClassName);
  if aFichaClase <> nil then
  begin
    self.rec_lnk := Rec;
    rec_lnk.Destilar(VERSION_ArchiTexto);
  end;
end;

constructor TCosa.Create(capa: integer);
begin
  Create;
  self.capa := capa; // CapaPorDefecto
end;

constructor TCosa.Create_ReadFromText(f: TArchiTexto);
var
  kCampo: integer;
  aRecLnk: TCosa_CampoLnk;
begin
  inherited Create;
  rec_lnk := nil;
  BeforeRead(f.version, f.idHilo);
  self.rec_lnk := Rec;
  for kCampo := 0 to self.rec_lnk.Count - 1 do
  begin
    aRecLnk := rec_lnk[kCampo];
    case aRecLnk.aplicable(f.Version) of
      -1, -2: ;// IGNORAR;
      0:
      begin
        if aRecLnk.CampoDef is TCosa_CampoDef_Cosa then
          f.rd(aRecLnk.nombre, TCosa(aRecLnk.pval^))
        else if aRecLnk.CampoDef is TCosa_CampoDef_CosaRef then
          f.rdReferencia(aRecLnk.nombre, TCosa(aRecLnk.pval^), self)
        else if aRecLnk.CampoDef is TCosa_CampoDef_ArchRef then
          f.rdArchRef(aRecLnk.nombre, TArchiRef(aRecLnk.pval^))
        else
        begin
          f.rd(aRecLnk.nombre, aRecLnk.StrVal);
          aRecLnk.Evaluar(Self, f.Evaluador, true );
        end;
      end;
      1:
      begin
        aRecLnk.UsarDefault; //Aplicar Defualt
        aRecLnk.Evaluar(Self, f.Evaluador, true );
      end;
    end;
  end;

  // Antes de ejecutar AfterRead tengo que evaluar para que
  // exista una version evaluable
  //  rec_lnk.Evaluar( Self, f.Evaluador );

  AfterRead(f.version, f.idHilo);

  // Acá tengo que Destilar el R
  rec_lnk.Destilar(VERSION_ArchiTexto);
end;

procedure TCosa.WriteToText_(f: TArchiTexto);
var
  kCampo: integer;
  aRecLnk: TCosa_CampoLnk;
begin

  for kCampo := 0 to self.rec_lnk.Count - 1 do
  begin
    aRecLnk := rec_lnk[kCampo];
    if aRecLnk.CampoDef is TCosa_CampoDef_Cosa then
      f.wr(aRecLnk.nombre, TCosa(aRecLnk.pval^))
    else if aRecLnk.CampoDef is TCosa_CampoDef_CosaRef then
      f.wrReferencia(aRecLnk.nombre, TCosa(aRecLnk.pval^))
    else if aRecLnk.CampoDef is TCosa_CampoDef_ArchRef then
      f.wrArchRef(aRecLnk.nombre, TArchiRef(aRecLnk.pval^))
    else
    begin
      if aRecLnk.Parent_RecLnk.flg_DevaluarAntesDeGuardar then
        aRecLnk.Devaluar;
      f.wr(aRecLnk.nombre, aRecLnk.StrVal);
    end;
  end;

end;


function TCosa.Apodo: string;
begin
  Result := '-';
end;


procedure TCosa.Free;
begin
  inherited Free;
end;

procedure TCosa.ActivarCapas(const capasActivas: TDAOfNInt);
begin
  // este no hace nada.
end;

procedure TCosa.WriteToArchi(archi: string);
var
  f: TArchiTexto;
begin
  f := TArchiTexto.CreateForWrite(archi, False, 0);
  try
    f.wr(apodo, Self);
  finally
    f.Free;
  end;
end;

function TCosa.Create_Clone(CatalogoReferencias: TCatalogo; idHilo: integer): TCosa;
var
  f: TArchiTexto;
  a: TCosa;
  archi: string;
begin
  a := nil;
  archi := getDir_Tmp + 'aux_clonar' + IntToStr(idHilo) + '.tmp';
  f := TArchiTexto.CreateForWrite(archi, False, 0);
  try
    f.wr('_', self);
  finally
    f.Free;
  end;

  f := TArchiTexto.CreateForRead(idHilo, CatalogoReferencias, archi, True);
  try
    f.rd('_', a);
    Result := a;
  finally
    f.Free;
  end;
end;

function TCosa.asMemo(idHilo: integer): TStrings;
var
  f: TArchiTexto;
  ff: textfile;
  a: TCosa;
  dirTemporales: string;
  r: string;
  res: TStringList;
begin
  dirTemporales := getDir_Tmp;
  f := TArchiTexto.CreateForWrite(dirTemporales + 'aux_clonar' +
    IntToStr(idHilo) + '.tmp', False, 0);
  try
    f.wr('_', self);
  finally
    f.Free;
  end;

  res := TStringList.Create;
  assignfile(ff, dirTemporales + 'aux_clonar' + IntToStr(idHilo) + '.tmp');
  reset(ff);
  while not EOF(ff) do
  begin
    readln(ff, r);
    res.add(r);
  end;
  closefile(ff);
  Result := res;
end;

class function TCosa.Create_FromMemo(CatalogReferencias: TCatalogo;
  idHilo: integer; const memo: TStrings): TCosa;
var
  f: TArchiTexto;
  ff: textfile;
  a: TCosa;
  dirTemporales: string;
  k: integer;
begin
  a := nil;
  dirTemporales := getDir_Tmp;
  assignfile(ff, dirTemporales + 'aux_clonar' + IntToStr(idHilo) + '.tmp');
  rewrite(ff);
  for k := 0 to memo.Count - 1 do
    writeln(ff, memo[k]);
  closefile(ff);

  f := TArchiTexto.CreateForRead(idHilo, CatalogReferencias, dirTemporales +
    'aux_clonar' + IntToStr(idHilo) + '.tmp', True);
  try
    f.rd('_', a);
    Result := a;
  finally
    f.Free;
  end;
end;


function TCosa.Rec: TCosa_RecLnk;
var
  res: TCosa_RecLnk;
begin
  if rec_lnk = nil then
    rec_lnk := TCosa_RecLnk.Create(self);
  res := rec_lnk;
  res.addCampoDef('capa', capa, 91, 0);
  Result := res;
end;

procedure TCosa.BeforeRead(version, id_hilo: integer);
begin

end;

procedure TCosa.AfterRead(version, id_hilo: integer);
begin

end;

constructor TCosa.Create_dummy;
begin
  inherited Create;
end;

procedure TCosa.Free_dummy;
begin
  inherited Free;
end;



function TCosa.InfoAd_: string;
begin
  Result := IntToStr(capa) + ', ';
end;

function TCosa.InfoAd_20: string;
var
  res: string;
begin
  res := infoAd_;
  if length(res) > 20 then
  begin
    Delete(res, 21, length(res) - 20);
    res := res + '...';
  end;
  Result := res;
end;


class function TCosa.DescClase: string;
begin
  Result := 'Cosa';
end;


function TCosa.Validate: boolean;
begin
  Result := True;
end;

function TCosa.GetValStr(nombreCampo: string): string;
var
  aRec: TCosa_CampoLnk;
begin
  aRec := GetFieldByName(nombreCampo);
  if aRec = nil then
    raise Exception.Create('No se encuentra el campo: ' +
      nombreCampo + ' en la clase: ' + ClassName)
  else
    Result := aRec.GetStrVal;
end;

procedure TCosa.SetValStr( nombreCampo, nuevoValor: string; Evaluador: TEvaluadorConCatalogo );
var
  aRec: TCosa_CampoLnk;
begin
  aRec := GetFieldByName(nombreCampo);
  if aRec = nil then
    raise Exception.Create('No se encuentra el campo: ' +
      nombreCampo + ' en la clase: ' + ClassName)
  else
    aRec.SetStrVal( nuevoValor, Evaluador );
end;

function TCosa.GetFieldByName(nombreCampo: string): TCosa_CampoLnk;
var
  res: TCosa_CampoLnk;
  buscando: boolean;
  k: integer;
begin
  k := 0;
  buscando := True;
  for k := 0 to rec_lnk.Count - 1 do
  begin
    res := rec_lnk[k];
    if res.nombre = nombreCampo then
    begin
      buscando := False;
      break;
    end;
  end;
  if buscando then
    Result := nil
  else
    Result := res;
end;

function TCosa.Evaluar(Referente: TCosa; evaluador: TEvaluadorConCatalogo;
  flg_save: boolean): integer;
begin
  result:= rec_lnk.Evaluar( Referente, evaluador, flg_save );
end;

procedure TCosa.Devaluar;
begin
  rec_lnk.Devaluar;
end;

procedure TCosa.AgregarDefinicionesEvaluador(eval: TEvaluadorExpresionesSimples
  );
begin
  // nada
end;

procedure TCosa.AddToCapasLst(capas: TList; padre: TCosa );
var
  k: integer;
  buscando: boolean;
  aCapa: TCapa;
begin
  buscando:= true;
  k:= 0;
  while buscando and ( k < capas.Count ) do
  begin
    aCapa:= TCapa( capas[ k ] );
    if aCapa.nid = self.capa then
      buscando := false
    else
      inc( k );
  end;
  if buscando then
  begin
    aCapa:= TCapa.Create( self.capa );
    capas.Add( aCapa );
  end;
  aCapa.AddCosa( Self, Padre );
end;

{$IFDEF CNT_COSAS}
constructor TCntCosasClase.Create(xclase: TClass);
begin
  clase := xclase;
  cnt := 1;
end;

constructor TCntCosas.Create;
begin
  cnt_Cosas := 0;
  CntCosasClases := TList.Create;
end;

function TCntCosas.incCntCosasClase(clase: TClass): integer;
var
  i: integer;
  resultado: integer;
  aux: TCntCosasClase;
begin
  resultado := 0;
  for i := 0 to CntCosasClases.Count - 1 do
    if TCntCosasClase(CntCosasClases[i]).clase = clase then
    begin
      TCntCosasClase(CntCosasClases[i]).cnt := TCntCosasClase(CntCosasClases[i]).cnt + 1;
      resultado := TCntCosasClase(CntCosasClases[i]).cnt;
      break;
    end;
  if resultado = 0 then
  begin
    aux := TCntCosasClase.Create(clase);
    resultado := aux.cnt;
    CntCosasClases.Add(aux);
  end;
  cnt_Cosas := cnt_Cosas + 1;
  Result := resultado;
end;

function TCntCosas.decCntCosasClase(clase: TClass): integer;
var
  i, ipos: integer;
begin
  ipos := -1;
  for i := 0 to CntCosasClases.Count - 1 do
    if TCntCosasClase(CntCosasClases[i]).clase = clase then
    begin
      TCntCosasClase(CntCosasClases[i]).cnt := TCntCosasClase(CntCosasClases[i]).cnt - 1;
      ipos := i;
      cnt_Cosas := cnt_Cosas - 1;
      break;
    end;
  if ipos <> -1 then
    Result := TCntCosasClase(CntCosasClases[ipos]).cnt
  else
    raise Exception.Create(rs_NoInstanciasDe + ': ' + clase.ClassName);
end;

function TCntCosas.CntCosasClase(clase: TClass): integer;
var
  i, ipos: integer;
begin
  ipos := -1;
  for i := 0 to CntCosasClases.Count - 1 do
    if TCntCosasClase(CntCosasClases[i]).clase = clase then
    begin
      ipos := i;
      break;
    end;
  if ipos <> -1 then
    Result := TCntCosasClase(CntCosasClases[i]).cnt
  else
    Result := 0;
end;

procedure TCntCosas.Free;
var
  i: integer;
begin
  for i := 0 to CntCosasClases.Count - 1 do
    TCntCosasClase(CntCosasClases[i]).Free;
  CntCosasClases.Free;
  inherited Free;
end;

{$ENDIF}

// métodos de TFichaClase
constructor TFichaClase.Create(strClaseID: string; clase: TClaseDeCosa);
begin
  inherited Create;
  Self.strClaseId := strClaseId;
  self.clase := clase;
  self.recDef := nil;
end;

procedure TFichaClase.Free;
begin
  if recDef <> nil then
    recDef.Free;
  inherited Free;
end;


procedure TArchiTexto.ReadCosaFromText(var cosa: TCosa; cosaStrId: string);
var
  clase: TClaseDeCosa;
begin
  clase := TClaseDeCosa(getClaseOf(CosaStrId));
  if clase = nil then
    raise ExcepcionClaseNoRegistrada.Create(
      'TArchiTexto.ReadCosaFromText: Error, ' + CosaStrId +
      ' No es una clase registrada. Procesando Línea: ' + IntToStr(klinea));

  cosa := clase.Create_ReadFromText(Self);

{$IFDEF WRLN_COSAS_CON_NOMBRE_LEIDAS}
  if cosa is TCosaConNombre then
    writeln(IntToStr(klinea) + ', Se leyó: ' + cosaStrId + '...' + cosa.apodo);
{$ENDIF}
end;


//-------------------------
// Métodos de TListaDeCosas
//=========================

constructor TListaDeCosas.Create(capa: integer; idCarpeta: string);
begin
  inherited Create(capa);
  self.idCarpeta := idCarpeta;
  lst := TList.Create;
end;



constructor TListaDeCosas.Create_ReadFromText(f: TArchiTexto);
var
  k: integer;
  cosas: array of TCosa;
  n: integer;
begin
  //  inherited Create_ReadFromText_( f );
  // OJO no llamo el inherited Create_ReadFromText_ para que no entre en la lógica
  // De REC_lnk ... en lugar de eso sipmlemente leemos la CAPA
  f.rd('capa', capa);

  self.idCarpeta := f.aux_idCarpeta;
  f.rd('n', n);
  lst := TList.Create;
  SetLength(cosas, n);
  for k := 0 to n - 1 do
    f.rd(':', TCosa(cosas[k]));

  //Esto es porque puede estar mal grabado el archivo y no se carguen las n cosas
  for k := 0 to n - 1 do
    if cosas[k] <> nil then
      lst.Add(cosas[k]);
  SetLength(cosas, 0);
end;

procedure TListaDeCosas.WriteToText_(f: TArchiTexto);
var
  n, k: integer;
  cosa: TCosa;
begin
  //   inherited WriteToText(f);
  f.wr('capa', capa);

  n := lst.Count;
  f.wr('n', n);
  for k := 0 to n - 2 do
  begin
    cosa := lst.items[k];
    f.wr(':', cosa);
    f.writeline('');
  end;
  if n > 0 then
  begin
    cosa := lst.items[n - 1];
    f.wr(':', cosa);
  end;
end;


function TListaDeCosas.Add(cosa: TCosa): integer;
begin
  Result := self.lst.Add(cosa);
end;

procedure TListaDeCosas.ponerIgualA(listaDeCosas: TListaDeCosas; freeElementos: boolean);
var
  i: integer;
begin
  if freeElementos then
    ClearFreeElementos
  else
    Clear;

  lst.Capacity := listaDeCosas.lst.Count;
  for i := 0 to listaDeCosas.lst.Count - 1 do
    lst.Add(listaDeCosas.lst[i]);
end;


procedure TListaDeCosas.ActivarCapas(const CapasActivas: TDAOfNInt);
var
  k: integer;
  ac: TCosa;
begin
  k := 0;
  while (k < Count) do
  begin
    ac := items[k];
    if kInArray(CapasActivas, ac.capa) >= 0 then
    begin
      ac.ActivarCapas(CapasActivas);
      Inc(k);
    end
    else
    begin
      ac.Free;
      Delete(k);
    end;
  end;
end;

procedure TListaDeCosas.Free;
var
  k: integer;
begin
  if lst <> nil then
  begin
    for k := 0 to lst.Count - 1 do
      if lst.Items[k] <> nil then
        TCosa(lst.items[k]).Free;
    lst.Free;
  end;
  inherited Free;
end;

procedure TListaDeCosas.FreeSinElemenentos;
begin
  lst.Free;
  inherited Free;
end;

function TListaDeCosas.Count: integer;
begin
  Result := lst.Count;
end;

procedure TListaDeCosas.insert(indice: integer; cosa: TCosa);
begin
  lst.Insert(indice, cosa);
end;

function TListaDeCosas.Remove(cosa: TCosa): integer;
begin
  Result := lst.Remove(cosa);
end;

procedure TListaDeCosas.Delete(indice: integer);
begin
  lst.Delete(indice);
end;

procedure TListaDeCosas.Pack;
begin
  lst.Pack;
end;

procedure TListaDeCosas.Exchange(indice1, indice2: integer);
begin
  lst.Exchange(indice1, indice2);
end;

function TListaDeCosas.IndexOf(cosa: TCosa): integer;
begin
  Result := lst.IndexOf(cosa);
end;

function TListaDeCosas.replace(cosaARemplazar, cosaNueva: TCosa): integer;
var
  i: integer;
begin
  i := 0;
  while (i < Count) and (lst.Items[i] <> cosaARemplazar) do
    i := i + 1;
  if i < Count then
  begin
    lst.Items[i] := cosaNueva;
    Result := i;
  end
  else
    Result := -1;
end;

procedure TListaDeCosas.Clear;
begin
  lst.Clear;
end;

procedure TListaDeCosas.ClearFreeElementos;
var
  i: integer;
begin
  for i := 0 to lst.Count - 1 do
    TCosa(items[i]).Free;
  lst.Clear;
end;

procedure TListaDeCosas.Sort(Compare: TListSortCompare);
begin
  lst.Sort(Compare);
end;

function TListaDeCosas.getList: TList;
begin
  Result := lst;
end;

function TListaDeCosas.toArray: TDAOfTCosa;
var
  i: integer;
  res: TDAOfTCosa;
begin
  SetLength(res, lst.Count);
  for i := 0 to lst.Count - 1 do
    res[i] := lst[i];
  Result := res;
end;

function TListaDeCosas.getItem(i: integer): TCosa;
begin
  Result := lst.items[i];
end;

procedure TListaDeCosas.setItem(i: integer; cosa: TCosa);
begin
  lst.items[i] := cosa;
end;

function TListaDeCosas.getCapacity: integer;
begin
  Result := lst.Capacity;
end;

procedure TListaDeCosas.setCapacity(newCapacity: integer);
begin
  lst.Capacity := newCapacity;
end;



/////////////////////////
//Procedimientos Globales
/////////////////////////

function registrarClaseDeCosa(const nombre: string; Clase: TClaseDeCosa): integer;
var
  ficha: TFichaClase;
  a: TCosa;
  res: integer;
begin
  ficha := TFichaClase.Create(nombre, clase);
  res := registro_de_ClasesDeCosas_.Add(ficha);

  a := Clase.Create_dummy;
  ficha.recDef := a.Rec.RecDef;
  a.Free_dummy;

  Result := res;
end;


function getFichaClase(const nombre: string): TFichaClase;
var
  ipos: integer;
  res: TFichaClase;
  slow: string;
begin
  res := nil;
  slow := LowerCase(nombre);
  for ipos := 0 to registro_de_ClasesDeCosas_.Count - 1 do
  begin
    if LowerCase(TFichaClase(registro_de_ClasesDeCosas_[ipos]).strClaseId) =
      slow then
    begin
      res := TFichaClase(registro_de_ClasesDeCosas_.items[ipos]);
      break;
    end;
  end;
  Result := res;
end;


function getClaseOf(const nombre: string): TCualquierClase;
var
  aFicha: TFichaClase;
begin
  aFicha := getFichaClase(nombre);
  if aFicha = nil then
    raise Exception.Create('ucosa.getClaseOf: Clase de Actor desconocida ' + nombre)
  else
    Result := aFicha.clase;
end;

// si la clase no está registrada retorna '<CLASE_NO_REGISTRADA>'
function getIdStrOf(clase: TClaseDeCosa): string;
var
  ipos: integer;
  buscando: boolean;
  b: string;
begin
  buscando := True;
  b := clase.ClassName;
  for ipos := 0 to registro_de_ClasesDeCosas_.Count - 1 do
    if TFichaClase(registro_de_ClasesDeCosas_.items[ipos]).Clase = Clase then
    begin
      buscando := False;
      break;
    end;
  if buscando then
    Result := '<CLASE_NO_REGISTRADA>'
  else
    Result := TFichaClase(registro_de_ClasesDeCosas_.items[ipos]).strClaseId;
end;


// Retorna la cadena de padres separados por #9
function ParentsStrList(clase: TClass): string;
var
  res: string;
  padre: TClass;
begin
  res := clase.ClassName;
  padre := clase;
  while assigned(padre.ClassParent) do
  begin
    padre := padre.ClassParent;
    res := padre.ClassName + '->' + res;
  end;
  Result := res;

end;

function IsChild(Parent, Child: string): boolean;
begin
  Result := IsChild(getClaseOf(Parent), getClaseOf(Child));
end;

function IsChild(Parent, Child: TClass): boolean;
begin
  if not Assigned(Child) then
  begin
    Result := False;
    exit;
  end;
  if (Parent.ClassName = Child.ClassParent.ClassName) then
    Result := True
  else if Child.ClassParent.ClassName = TObject.ClassName then
    Result := False
  else
    Result := IsChild(Parent, Child.ClassParent);
end;

function ListarRegistroDeClases: TStringList;
var
  k: integer;
  aFicha: TFichaClase;
  res: TStringList;
  s: string;
  clase: TClass;

begin
  res:= TStringList.Create;
  for k := 0 to registro_de_ClasesDeCosas_.Count - 1 do
  begin
    s:= '';
    aFicha := registro_de_ClasesDeCosas_.items[k];
    if aFicha <> nil then
    begin
      clase:= aFicha.clase;
      while (clase <> nil ) do
      begin
        s:= clase.ClassName+#9+s;
        if clase <> TCosa then
         clase:= clase.ClassParent
        else
         clase:= nil;
      end;
    end
    else
      s:= s+ ' ojo Ficha = NIL ';
    s:= IntToStr( k )+': '+s;
    res.add( s );
  end;
  result:= res;
end;

procedure LimpiarRegistroDeClasesDeCosas;
var
  k: integer;
  aFicha: TFichaClase;
begin
  for k := 0 to registro_de_ClasesDeCosas_.Count - 1 do
  begin
    aFicha := registro_de_ClasesDeCosas_.items[k];
    if aFicha <> nil then
      aFicha.Free;
  end;
  registro_de_ClasesDeCosas_.Clear;
end;

procedure AlInicio;
begin
  ReferenciasAArchivosExternos := TList.Create;
  lista_caminos := TBuscaArchivos.Create;

{$IFDEF CNT_COSAS}
  CantCosas := TCntCosas.Create;
{$ENDIF}
  registro_de_ClasesDeCosas_ := TList.Create;
  //  registrarClaseDeCosa( TCosa.ClassName, TCosa );
  registrarClaseDeCosa(TListaDeCosas.ClassName, TListaDeCosas);
end;


procedure AlFinal;
begin
  LimpiarRegistroDeClasesDeCosas;
  registro_de_ClasesDeCosas_.Free;
{$IFDEF CNT_COSAS}
  CantCosas.Free;
{$ENDIF}
  ReferenciasAArchivosExternos.Free;
  lista_caminos.Free;
end;

procedure FreeAndNil(var obj: TCosa);
var
  aux: TCosa;
begin
  aux := obj;
  obj := nil;
  aux.Free;
end;

function referenciaACosa(cosa: TCosa): string;
begin
  if assigned(cosa) and (cosa is TCosaConNombre) then
    Result := '<' + cosa.ClassName + '.' + TCosaConNombre(cosa).nombre + '>'
  else
    Result := '<?.?>';
end;

constructor TListaDeObjetosPorLeer.Create(Catalogo: TCatalogo);
begin
  inherited Create;
  Self.Catalogo := Catalogo;
end;

procedure TListaDeObjetosPorLeer.Free;
var
  k: integer;
begin
  for k := 0 to Count - 1 do
    TListCamposParaLeer(items[k]).Free;
  self.Clear;
  inherited Free;
end;

function TListaDeObjetosPorLeer.ListaActiva: TListCamposParaLeer;
begin
  if Count > 0 then
    Result := items[Count - 1]
  else
  begin
    raise Exception.Create('Error, no hay un Objeto activo para lectura ');
    Result := nil;
  end;
end;

procedure TListaDeObjetosPorLeer.FreeListaPorLeer;
begin
  if Count > 0 then
  begin
    TListCamposParaLeer(items[Count - 1]).Free;
    Delete(Count - 1);
  end;
end;

procedure TListaDeObjetosPorLeer.InicioObjeto(const NombreClase: string);
var
  a: TListCamposParaLeer;
begin
  a := TListCamposParaLeer.Create(Catalogo, NombreClase);
  add(a);
end;

procedure TListaDeObjetosPorLeer.FinalObjeto;
var
  xCosa: TCosa;
  nombreDelCampoObjeto: string;
  lpl: TListCamposParaLeer;
  i: integer;
  res: boolean;
begin
  // procesar hasta el final del objeto
  lpl := ListaActiva;
  xCosa := lpl.cosa;
  FreeListaPorLeer;
  lpl := ListaActiva;
  nombreDelCampoObjeto := lowercase(lpl.xNombre);
  res := False;
  for i := 0 to lpl.Count - 1 do
    if lowercase(TCampoParaLeer(lpl[i]).nombre) = nombreDelCampoObjeto then
    begin

      if xCosa <> nil then
        TCosa(TCampoParaLeer(lpl.items[i]).pVal^) := xCosa;
      if xCosa = nil then
        raise Exception.Create(
          'TListaDeObjetosPorLeer.FinalObjeto: xCosa=nil');
      TCampoParaLeer(lpl.items[i]).Free;
      lpl.Delete(i);
      res := True;
      break;
    end;
  if not res then
    raise Exception.Create('Aparentemente el objeto: ' +
      lpl.IdentificadorDeLaClaseDelObjeto + ' no tienen definido el campo: ' +
      nombreDelCampoObjeto);
end;


constructor TArchiTexto.CreateForRead(idHilo: integer;
  CatalogoReferencias: TCatalogo; const nombreArchivo: string; abortarEnError: boolean);
var
  s: string;
  iposver: integer;
begin
  self.idHilo := idHilo;
  self.CatalogoReferencias := CatalogoReferencias;
  evaluador := TEvaluadorConCatalogo.Create(CatalogoReferencias);
  setSeparadoresGlobales;
  if FileExists(nombreArchivo) then
  begin
    inherited Create;

    f_abierto := False;
    unArchivoPorCosa := False;
    padre := nil;
    ramas := nil;


    Self.NombreArchivo := nombreArchivo;
    oldFileMode := FileMode;
    filemode := fmOpenRead;

    assignfile(f, NombreARchivo);
    {$I-}
    reset(f);
    {$I+}
    if ioresult = 0 then
      f_abierto := True
    else
      raise Exception.Create('TArchiTexto.CreateForRead: No pude abrir archivo: ' +
        NombreArchivo);

    self.abortarEnError := abortarEnError;

    readln(f, s);
    s := trim(s);

    klinea := 0;

    iposver := pos('VERSION=', s);
    if iposver >= 1 then
    begin
      Delete(s, 1, iposver - 1 + length('VERSION='));
      s := trim(s);
      version := StrToInt(s);
      Inc(klinea);
    end
    else
      version := 0;

    // parche chancho para poder leer archivos de la gente de la regasificadora
    if (version < 10000) and (version > VERSION_ArchiTexto) then
      raise Exception.Create(rs_ElArchivo + ' ' + nombreArchivo +
        ' ' + rs_VersionPosterior);


    if version <= 45 then
      setSeparadoresGlobales_FechaUruguaya_V45_;

    listaObjetosPorLeer := TListaDeObjetosPorLeer.Create(CatalogoReferencias);
    indentstr := '';
    listaObjetosPorLeer.InicioObjeto('TODO');
  end
  else
    raise Exception.Create('TArchiTexto.CreateForRead: ' +
      rs_NoSeEncuentraArchivo + nombreArchivo);
end;



constructor TArchiTexto.CreateForWrite(const nombreArchivo: string;
  crearBackupSiExiste: boolean; maxNBackups: integer);
begin
  inherited Create;
  setSeparadoresGlobales;

  unArchivoPorCosa := False;
  padre := nil;
  ramas := nil;

  f_abierto := False;
  Self.NombreArchivo := NombreArchivo;

  if crearBackupSiExiste and FileExists(nombreArchivo) then
    uconstantesSimSEE.backupearArchivoAntesDeSalvar(nombreArchivo, maxNBackups);
  assignFile(f, NombreArchivo);
  oldFileMode := FileMode;
  filemode := fmOpenWrite;
   {$I-}
  Rewrite(f);
   {$I+}
  if ioresult = 0 then
    f_abierto := True
  else
    raise Exception.Create('TArchiTexto.CreateForWrite(' + nombreArchivo + ')');

  writeln(f, 'VERSION=' + IntToStr(VERSION_ArchiTexto));
  klinea := 1;
  listaObjetosPorLeer := nil; // TListaDeObjetosPorLeer.Create;
end;

function TArchiTexto.CreateRamaForWrite(
  const Carpeta, NombreClase, NombreCosa: string): TArchiTexto;
var
  s: string;
  i: integer;
  a: TArchiTexto;
begin
  if ramas = nil then
    ramas := TList.Create;
  i := pos('.sse', nombreArchivo);
  s := copy(nombreArchivo, 1, i - 1);
  if carpeta <> '' then
    s := s + '/' + carpeta + '/';

  s := s + '$' + NombreClase + '$' + NombreCosa + '.sse';

  a := TArchiTexto.CreateForWrite(s, False, 0);
  a.unArchivoPorCosa := True;
  ramas.Add(a);
  Result := a;
end;


function TArchiTexto.CreateRamaForRead(CatalogoReferencias: TCatalogo;
  const Carpeta, NombreClase, NombreCosa: string): TArchiTexto;
var
  s: string;
  i: integer;
  a: TArchiTexto;
begin
  if ramas = nil then
    ramas := TList.Create;
  i := pos('.sse', nombreArchivo);
  s := copy(nombreArchivo, 1, i - 1);
  if carpeta <> '' then
    s := s + '/' + carpeta + '/';

  s := s + '$' + NombreClase + '$' + NombreCosa + '.sse';
  a := TArchiTexto.CreateForRead(self.idHilo, CatalogoReferencias,
    s, self.abortarEnError);
  a.unArchivoPorCosa := True;
  ramas.Add(a);
  Result := a;
end;


procedure TArchiTexto.Free;
var
  i: integer;
  //  a: TArchiTexto;
begin
  setSeparadoresLocales;

  if listaObjetosPorLeer <> nil then
    listaObjetosPorLeer.Free;

  if evaluador <> nil then
  begin
    evaluador.Free;
    evaluador := nil;
  end;

  if ramas <> nil then
  begin
    if ramas.Count > 0 then
      raise Exception.Create(
        'Toy tratando de FREE un ArchiTexto pero tiene RAMAS, revisar esto')
    else
      ramas.Free;
(* creo que no es necesario esto, si lo de arriba salta, talvez tenga que
   usar lo de abajo
    for i:= 0 to ramas.Count - 1 do
    begin
      a:= ramas.Items[i];
      a.padre:= self.padre;
      padre.ramas.Add( a );
    end;
*)
  end;

  if padre <> nil then
  begin
    // quitamos este archivo de la lista del padre
    i := padre.ramas.IndexOf(self);
    padre.ramas.Delete(i);
  end;

  if (f_abierto) then
  begin
    f_abierto := False;
    closefile(f);
  end;
  FileMode := oldFileMode;


  inherited Free;
end;

function TArchiTexto.NextLine: string;
var
  r: string;
begin
  if not system.EOF(f) then
  begin
    readln(f, r);
    Inc(klinea);
    Result := trim(r);
  end
  else
    raise Exception.Create('Llegué al fin del archivo en forma inesperada.');
end;

procedure TArchiTexto.writeline(const s: string);
begin
  writeln(f, indentstr + s);
end;

function TArchiTexto.EOF: boolean;
begin
  Result := system.EOF(f);
end;

function TArchiTexto.quedanCosasDelObjetoActualPorLeer(claseObjeto: string): boolean;
var
  s: string;
begin
  s := NextLine;
  //Solo puede haber lineas vacias, sino devuelvo true
  while (s <> '<-' + claseObjeto + '>;') and (trim(s) = '') do
    s := NextLine;
  if s = '<-' + claseObjeto + '>;' then
    Result := False
  else
    Result := True;
end;

function TArchiTexto.ListaPorLeer: TListCamposParaLeer;
begin
  Result := listaObjetosPorLeer.ListaActiva;
end;

procedure TArchiTexto.wr(const nombre: string; const valor: NReal;
  precision: integer; decimales: integer);
begin
  writeline(nombre + '= ' + FloatToStrF(valor, ffGeneral, precision, decimales) + ';');
end;

procedure TArchiTexto.wr(const nombre: string; const valor: NReal);
begin
  wr(nombre, valor, CF_PRECISION, CF_DECIMALES);
end;

procedure TArchiTexto.wr(const nombre: string; const valor: string);
begin
  writeline(nombre + '= ' + valor + ';');
end;

procedure TArchiTexto.wrArchRef(const nombre: string; const valor: TArchiRef);
begin
  if valor <> nil then
    writeline(nombre + '= ' + valor.archiRefStr + ';')
  else
    writeline(nombre + '= ;');
end;

procedure TArchiTexto.wr(const nombre: string; const valor: NInt);
begin
  writeline(nombre + '= ' + IntToStr(valor) + ';');
end;

procedure TArchiTexto.wr(const nombre: string; const valor: cardinal);
begin
  writeline(nombre + '= ' + IntToStr(valor) + ';');
end;

procedure TArchiTexto.wr(const nombre: string; const valor: TFecha);
begin
  if valor <> nil then
    writeline(nombre + '= ' + valor.AsStr + ';')
  else
    writeline(nombre + '= 0;');
end;

procedure TArchiTexto.wr(const nombre: string; const valor: TCosa);
var
  CosaStrId: string;
  clase: TClaseDeCosa;
  b: string;
begin
  if valor <> nil then
  begin
    b := valor.ClassName;
    clase := TClaseDeCosa(valor.ClassType);
    CosaStrId := getIdStrOf(clase);
    writeline(nombre + '= <+' + CosaStrId + '>');
    indentstr := indentstr + '  ';
    valor.WriteToText_(Self);
    Delete(indentstr, length(indentstr) - 1, 2);
    writeline('<-' + CosaStrId + '>;');
  end
  else
    writeline(nombre + '= NIL;');
end;

procedure TArchiTexto.wr(const nombre: string; const valor: boolean);
begin
  if valor then
    writeline(nombre + '= 1;')
  else
    writeline(nombre + '= 0;');
end;

procedure TArchiTexto.wr(const nombre: string; const valor: TDAOfNReal;
  precision: integer; decimales: integer);
var
  k: integer;
begin
  Write(f, indentstr + nombre, '= [', length(valor), '| ');
  if length(valor) > 0 then
  begin
    Write(f, FloatToStrF(valor[0], ffFixed, precision, decimales));
    for k := 1 to high(valor) do
    begin
      if ((k mod 12) = 0) then
        writeline('  ');
      Write(f, ', ', FloatToStrF(valor[k], ffFixed, precision, decimales));
    end;
  end;
  writeln(f, '];');
end;

procedure TArchiTexto.wr(const nombre: string; const valor: TDAOfNReal);
begin
  wr(nombre, valor, 12, 3);
end;

procedure TArchiTexto.wr(const nombre: string; const valor: TDAOfNInt);
var
  k: integer;
begin
  Write(f, indentstr + nombre, '= [', length(valor), '| ');
  if length(valor) > 0 then
  begin
    Write(f, valor[0]);
    for k := 1 to high(valor) do
    begin
      if ((k mod 12) = 0) then
        writeline('  ');
      Write(f, ', ', valor[k]);
    end;
  end;
  writeln(f, '];');
end;

procedure TArchiTexto.wr(const nombre: string; const valor: TDAOfBoolean); overload;
var
  k: integer;
begin
  Write(f, indentstr + nombre, '= [', length(valor), '| ');
  if length(valor) > 0 then
  begin
    Write(f, valor[0]);
    for k := 1 to high(valor) do
    begin
      if ((k mod 12) = 0) then
        writeline('  ');
      if Valor[k] then
        Write(f, ', ', valor[k])
      else
        Write(f, ', ', valor[k]);
    end;
  end;
  writeln(f, '];');
end;


procedure TArchiTexto.wr(const nombre: string; const valor: TStringList);
var
  k: integer;
begin
  Write(f, indentstr + nombre, '= [', valor.Count, '| ');
  if valor.Count > 0 then
  begin
    Write(f, valor[0]);
    for k := 1 to valor.Count - 1 do
    begin
      if ((k mod 12) = 0) then
        writeline('  ');
      Write(f, ', ', valor[k]);
    end;
  end;
  writeln(f, '];');
end;


procedure TArchiTexto.wr(const nombre: string; const valor: TDAOfString);
var
  k: integer;
begin
  Write(f, indentstr + nombre, '= [', length(valor), '| ');
  if length(valor) > 0 then
  begin
    Write(f, valor[0]);
    for k := 1 to high(valor) do
    begin
      if ((k mod 12) = 0) then
        writeline('  ');
      Write(f, ', ', valor[k]);
    end;
  end;
  writeln(f, '];');
end;



procedure TArchiTexto.wrReferencia(const nombre: string; const valor: TCosa);
begin
  writeline(nombre + '= ' + referenciaACosa(valor) + ';');
{  if assigned(valor) and (valor is TCosaConNombre) then
    writeline(nombre + '= <' + valor.ClassName + '.' +
      TCosaConNombre(valor).nombre + '>;')
(* rch0707121651 comento esto para que si está mal escriba referencia vacía y listo
    else
      raise Exception.Create('TArchiTexto.wrReferencia: intenta escribir una referencia a algo que no es TCosaConNombre');
  end
*)
  else
    writeline(nombre + '= <?.?>;');}
end;

procedure TArchiTexto.rd(const nombre: string; var valor: NReal);
begin
  ListaPorLeer.Esperar_NReal(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: string);
var
  a: integer;
begin
  ListaPorLeer.Esperar_String(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rdArchRef(const nombre: string; var valor: TArchiRef);
begin
  ListaPorLeer.Esperar_ArchRef(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: NInt);
begin
  ListaPorLeer.Esperar_NInt(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: cardinal);
begin
  ListaPorLeer.Esperar_NCardinal(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TFecha);
begin
  ListaPorLeer.Esperar_Fecha(nombre, valor, nil);
  EjecutarLectura_;
end;

// flgError= 0 lo mismo que sin flg. flgError= 1 no avisa del error
procedure TArchiTexto.rd(const nombre: string; var valor: TFecha; flgError: integer);
begin
  ListaPorLeer.Esperar_Fecha(nombre, valor, nil, flgError);
  EjecutarLectura_;
end;


procedure TArchiTexto.rd(const nombre: string; var valor: boolean);
begin
  ListaPorLeer.Esperar_Boolean(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TDAOfNReal);
begin
  ListaPorLeer.Esperar_DAOfNReal(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TDAOfBoolean); overload;
begin
  ListaPorLeer.Esperar_DAOfBoolean(nombre, valor, nil);
  EjecutarLectura_;
end;


procedure TArchiTexto.rd(const nombre: string; var valor: TCosa);
begin
  ListaPorLeer.Esperar_Cosa(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TDAOfNInt);
begin
  ListaPorLeer.Esperar_DAOfNInt(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TDAOfString);
begin
  ListaPorLeer.Esperar_DAOfString(nombre, valor, nil);
  EjecutarLectura_;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TStringList);
begin
  ListaPorLeer.Esperar_StringList(nombre, valor, nil);
  EjecutarLectura_;
end;



procedure TArchiTexto.rdReferencia(const nombre: string; var valor: TCosa;
  referente: TCosa);
begin
  ListaPorLeer.Esperar_Referencia(nombre, valor, nil, referente);
  EjecutarLectura_;
end;

procedure TArchiTexto.EjecutarLectura_;
var
  s, NombreClaseSiguienteObjeto: string;
  resObjetoHijo, resObjetoPadre: TResultadoProcesoLinea;
  lpl: TListCamposParaLeer;
{$IFDEF DBG}
  dbgAux: TDAofString;
{$ENDIF}
  indiceDeLinea: integer;
  posIgual: integer;
  ColumnName: string;
  i: integer;
  a: integer;
begin
  ColumnName := '';
  NombreClaseSiguienteObjeto := '';
  try
    lpl := ListaPorLeer;
    resObjetoPadre := CTPLR_CONTINUAR;
    while (resObjetoPadre <> CTPLR_FIN_OBJETO) and (lpl <> nil) and
      (lpl.Count > 0) and not EOF do
    begin
      {$IFDEF DBG}
      dbgAux := lpl.nombresCamposPorLeer;
      {$ENDIF}

      indiceDeLinea := klinea;
      s := nextline;
 {$IFDEF LECTURA_VERBOSA}
      system.writeln(indiceDeLinea: 6, ': ', s);
 {$ENDIF}
      try
        resObjetoPadre := lpl.ProcesarLinea(klinea, s, NombreClaseSiguienteObjeto,
          ColumnName);
      except
        on E: ExcepcionNoSePidioElCampo do
        begin
          lpl.Ejecutar_vpds(klinea);
          if quedanCosasDelObjetoActualPorLeer(lpl.IdentificadorDeLaClaseDelObjeto) then
          begin
            resObjetoPadre := CTPLR_CONTINUAR;
            klinea := indiceDeLinea;
          end
          else
            resObjetoPadre := CTPLR_FIN_OBJETO;
        end;
        on E: ExcepcionResolverCampoValor do
        begin
          posIgual := pos('=', s);
          lpl.Ejecutar_vpd(klinea, copy(s, 0, posIgual - 1));
          if quedanCosasDelObjetoActualPorLeer(lpl.IdentificadorDeLaClaseDelObjeto) then
          begin
            resObjetoPadre := CTPLR_CONTINUAR;
            klinea := indiceDeLinea + 1;
            //El +1 debería ser el número de lineas que leyo y no le sirvieron
          end
          else
            resObjetoPadre := CTPLR_FIN_OBJETO;
        end
      end;
      if resObjetoPadre = CTPLR_ABRIR_NUEVO_OBJETO then
      begin
        listaObjetosPorLeer.InicioObjeto(NombreClaseSiguienteObjeto);
        lpl := ListaPorLeer;
        try
          ReadCosaFromText(lpl.cosa, NombreClaseSiguienteObjeto);

        except
          on E: Exception do
          begin
            lpl.cosa := nil;
            if Assigned(procMsgErrorLectura) then
              procMsgErrorLectura(E.Message + '. Leyendo el actor en la linea ' +
                IntToStr(klinea));
            if abortarEnError then
              raise;

            if not EOF then
              repeat
                s := NextLine;
              until (s = '<-' + NombreClaseSiguienteObjeto + '>;') or EOF;
            lpl.leiFinDeObjeto := True;
          end
        end;
        if not lpl.leiFinDeObjeto then
          repeat
            s := nextline;
            resObjetoHijo := lpl.ProcesarLinea(klinea, s,
              NombreClaseSiguienteObjeto, ColumnName);
          until resObjetoHijo = CTPLR_FIN_OBJETO;

        listaObjetosPorLeer.FinalObjeto;
        lpl := ListaPorLeer;
      end;
    end;
    if resObjetoPadre = CTPLR_FIN_OBJETO then
      ListaPorLeer.leiFinDeObjeto := True;
  except
    on E: Exception do
      if pos('kLinea:', E.Message) = 0 then        raise Exception.Create('kLinea:(' + IntToStr(klinea) + ') ' + E.Message)
      else
        raise;
  end; // try
  //ListaPorLeer.lecturaRetrasada:= false;
end;

function TipoToStr(tipo: TTipoCampo): string;
begin
  case Tipo of
    CTC_NReal: Result := 'NReal';
    CTC_String: Result := 'String';
    CTC_ArchRef: Result := 'Ref. Archivo Externo';
    CTC_NInt: Result := 'Entero';
    CTC_NCardinal: Result := 'Entero Positivo';
    CTC_Boolean: Result := 'Booleano';
    CTC_DAOfNReal: Result := 'Array dinámico de Reales';
    CTC_DAOfNInt: Result := 'Array dinámico de Enteros';
    CTC_DAOfBoolean: Result := 'Array dinámico de Booleanas';
    CTC_Fecha: Result := 'Fecha';
    CTC_TDataRowOfCosa: Result := 'TDataRowOfCosa';
    CTC_Cosa: Result := 'Cosa';
  end; // case
end;

function compare_nid_capa(c1, c2: pointer): integer;
begin
  if TCapa( c1 ).nid < TCapa( c2 ).nid then
    result:= -1
  else if TCapa( c1 ).nid = TCapa( c2 ).nid then
    result:= 0
  else
    result:= 1;
end;

procedure ValorPorDefectoNulo(const nombre: string; pVal: Pointer;
  tipo: TTipoCampo; const klinea: integer);
var
  Msg: string;
begin
  case Tipo of
    CTC_NReal: NReal(pVal^) := 0;
    CTC_String: string(pVal^) := '';
    CTC_ArchRef: TArchiRef(pVal^) := TArchiRef.Create('');
    CTC_NInt: NEntero(pVal^) := 0;
    CTC_NCardinal: cardinal(pVal^) := 0;
    CTC_Boolean: boolean(pVal^) := False;
    CTC_DAOfNReal: setlength(TDAOfNReal(pVal^), 0);
    CTC_DAOfNInt: setlength(TDAOfNInt(pVal^), 0);
    CTC_DAOfBoolean: setlength(TDAOfBoolean(pVal^), 0);
    CTC_Fecha: TFecha(pVal^) := TFecha.Create_dt(0);
    CTC_TDataRowOfCosa: pointer(pVal^) := nil;
    CTC_Cosa: pointer(pVal^) := nil;
    CTC_Referencia: Pointer(pVal^) := nil;
  end; // case


  if global_flgError = 0 then
    if assigned(procMsgValorPorDefecto) then
    begin
      msg := 'Asignando valor por defecto al campo ' + nombre;
      if klinea <> -1 then
        msg := msg + ' leyendo el final del objeto en la linea ' + IntToStr(klinea)
      else
        msg := msg + ' en el final del archivo.';
      procMsgValorPorDefecto(msg);
    end;
end;

procedure ValorPorDefecto_ERROR(const nombre: string; pVal: Pointer;
  tipo: TTipoCampo; const klinea: integer);
var
  msg: string;
begin
  msg := 'No se encontró una definición para el campo: ' + nombre +
    ' tipo: ' + TipoToStr(tipo);
  if klinea <> -1 then
    msg := msg + ' leyendo el final del objeto en la linea ' + IntToStr(klinea)
  else
    msg := msg + ' en el final del archivo.';

  writeln(msg);
  Write('... presione ENTER para continuar.');
  system.readln;
end;

constructor TCampoParaLeer.Create(const Nombre: string; pVal: Pointer;
  Tipo: TTIpoCampo; proc_vpd: TProcFijarValorPorDefecto);
begin
  Create(Nombre, pVal, Tipo, proc_vpd, nil);
end;

constructor TCampoParaLeer.Create(const Nombre: string; pVal: Pointer;
  Tipo: TTIpoCampo; proc_vpd: TProcFijarValorPorDefecto; flgError: integer);
begin
  Create(Nombre, pVal, Tipo, proc_vpd, nil);
  self.flgError := flgError;
end;


constructor TCampoParaLeer.Create(const Nombre: string; pVal: Pointer;
  Tipo: TTipoCampo; proc_vpd: TProcFijarValorPorDefecto; referente: TCosa);
begin
  inherited Create;
  self.flgError := 0;
  self.nombre := nombre;
  self.tipo := tipo;
  self.pVal := pVal;
  self.referente := referente;

{$IFDEF PORDEFECTO_NULO}
  if not assigned(proc_vpd) then
    self.proc_vpd := ValorPorDefectoNulo
  else
    self.proc_vpd := proc_vpd;
{$ELSE}
  self.proc_vpd := proc_vpd;
{$ENDIF}
end;

procedure TCampoParaLeer.Ejecutar_vpd(const klinea: integer);
begin
  if assigned(proc_vpd) then
  begin
    global_flgError := Self.flgError;
    proc_vpd(nombre, pVal, tipo, klinea);
  end
  else
  if flgError = 0 then
    ValorPorDefecto_ERROR(nombre, pVal, tipo, klinea);
end;

constructor TListCamposParaLeer.Create(Catalogo: TCatalogo;
  IdentificadorDeLaClaseDelObjeto: string);
begin
  inherited Create;
  self.Catalogo := Catalogo;
  self.IdentificadorDeLaClaseDelObjeto := IdentificadorDeLaClaseDelObjeto;
  lineaAbierta := False;
  xNombre := '';
  xval := '';
  leiFinDeObjeto := False;
  self.cosa := nil;
end;

procedure TListCamposParaLeer.Esperar_NReal(const Nombre: string;
  var Variable: NReal; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_NReal, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_String(const Nombre: string;
  var Variable: string; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_String, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_ArchRef(const Nombre: string;
  var Variable: TArchiRef; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_ArchRef, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_NInt(const Nombre: string;
  var Variable: integer; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_NInt, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_NCardinal(const Nombre: string;
  var Variable: cardinal; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_NCardinal, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_Boolean(const Nombre: string;
  var Variable: boolean; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_Boolean, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_DAOfNReal(const Nombre: string;
  var Variable: TDAOfNReal; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_DAOfNReal, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_DAOfNInt(const Nombre: string;
  var Variable: TDAOfNInt; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_DAOfNInt, proc_vpd);
  add(a);
end;


procedure TListCamposParaLeer.Esperar_DAOfBoolean(const Nombre: string;
  var Variable: TDAOfBoolean; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_DAOfBoolean, proc_vpd);
  add(a);
end;


procedure TListCamposParaLeer.Esperar_DAOfString(const Nombre: string;
  var Variable: TDAOfString; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_DAOfString, proc_vpd);
  add(a);
end;



procedure TListCamposParaLeer.Esperar_StringList(const Nombre: string;
  var Variable: TStringList; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_StringList, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_Cosa(const Nombre: string;
  var Variable: TCosa; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_Cosa, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_Referencia(const Nombre: string;
  var Variable: TCosa; proc_vpd: TProcFijarValorPorDefecto; referente: TCosa);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_Referencia, proc_vpd, referente);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_Fecha(const Nombre: string;
  var Variable: TFecha; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_Fecha, proc_vpd);
  add(a);
end;

procedure TListCamposParaLeer.Esperar_Fecha(const Nombre: string;
  var Variable: TFecha; proc_vpd: TProcFijarValorPorDefecto; flgError: integer);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_Fecha, proc_vpd, flgError);
  add(a);
end;

(*
    CTPLR_CONTINUAR,
    CTPLR_FIN_OBJETO,
    CTPLR_ABRIR_NUEVO_OBJETO );
*)
function TListCamposParaLeer.ProcesarLinea(klinea: integer; linea: string;
  var extres: string; var ColumnName: string): TResultadoProcesoLinea;
var
  NombreClase: string;
begin
  ColumnName := '';
  Result := CTPLR_CONTINUAR;
  if pos('<-', linea) = 1 then
  begin
    if IdentificadorDeLaClaseDelObjeto <> '' then
      if pos(IdentificadorDeLaClaseDelObjeto, linea) <> 3 then
        raise Exception.Create('Error, cierre de objeto : ' + linea +
          ' Se esperaba: ' + '<-' + IdentificadorDeLaClaseDelObjeto +
          '>, en línea: ' + IntToStr(klinea));

    Ejecutar_vpds(klinea);      // procesamos los no resueltos
    Result := CTPLR_FIN_OBJETO; // cierro esta lista FIN DEL OBJETO
  end
  else
  begin
    if LineaAbierta then
    begin
      xval := xval + ' ' + linea;
      if xval[length(xval)] = ';' then
      begin
        xval := copy(xval, 0, Length(xval) - 1);//Saco el ;
        ResolverCampoValor(xNombre, xVal);
        LineaAbierta := False;
      end;
    end
    else
    begin
      if getPalHastaSep(xnombre, linea, '=') then
      begin
        xval := trim(linea);
        if length(xval) > 0 then
        begin
          if pos('<+', xval) = 1 then
          begin
            system.Delete(xval, 1, 2);
            if xval[length(xval)] <> '>' then
              raise Exception.Create('Error, falta el > de cierre en fin de clase : '
                + xval);
            NombreClase := copy(xval, 1, length(xval) - 1);
            ColumnName := xNombre;
            extres := NombreClase;
            Result := CTPLR_ABRIR_NUEVO_OBJETO;
          end
          else
          if xval[length(xval)] = ';' then
            //if getPalHastaSep(xval, linea, ';') then
          begin
            xval := copy(xval, 0, Length(xval) - 1);//Saco el ;
            try
              ResolverCampoValor(xNombre, xVal)
            except
              on E: ExcepcionNoSePidioElCampo do
              begin
                if Assigned(procMsgAdvertenciaLectura) then
                  procMsgAdvertenciaLectura(E.Message);
              end;
              on Exception do
              begin
                raise;
              end;
            end;
          end
          else
            LineaAbierta := True;
        end
        else
          LineaAbierta := True;
      end
      else
        Exception.Create('Error, no encontré el (=) en la línea: [' +
          IntToStr(klinea) + '] :' + linea);
    end;
  end;
end;

procedure TListCamposParaLeer.Free;
var
  k: integer;
begin
  Ejecutar_vpds(-1);
  //PAlfaro@101104 0307
  //Ojo, estaba comentado, pero me parece que tiene que ir. No se tranca y sin esto
  //quedarían colgados todos los campos para leer de cada TCosa
  for k := 0 to Count - 1 do
    TCampoParaLeer(items[k]).Free;
  inherited Free;
end;

procedure TListCamposParaLeer.ResolverCampoValor(const xNombre, xVal: string);
var
  buscando: boolean;
  k: integer;
  clase, nombreRef: string;
  lc_xNombre, lct: string;
  ts: string;
begin
  buscando := True;
  k := 0;
  lc_xNombre := lowercase(xNombre);
  while buscando and (k < Count) do
  begin
    lct := lowercase(TCampoParaLeer(items[k]).nombre);
    if lct = lc_xNombre then
      buscando := False
    else
      Inc(k);
  end;

  if buscando then

    raise ExcepcionNoSePidioElCampo.Create('Se leyó el campo: ' +
      xnombre + ' pero no se esperaba en el objeto: ' +
      IdentificadorDeLaClaseDelObjeto +
      '. Pruebe guardar y cargar nuevamente la sala. Intentaré solucionar el problema.')
  else
  begin
    try
      with  TCampoParaLeer(items[k]) do
        case Tipo of
          CTC_NReal: NReal(pVal^) := StrToFloat(xval);
          CTC_String: string(pVal^) := xval;
          CTC_ArchRef:
          begin
            ts := xval;
             {$IFDEF LINUX}
            toLinuxDir(ts);
             {$ENDIF}
            TArchiRef(pVal^) := TArchiRef.Create(ts);
          end;
          CTC_NInt: NEntero(pVal^) := StrToInt(xval);
          CTC_NCardinal: cardinal(pVal^) := StrToInt(xval);
          CTC_Boolean: boolean(pVal^) := (xval <> '') and (xval[1] = '1');
          CTC_DAOfNReal: parseDAOfNreal(TDAOfNReal(pVal^), xval);
          CTC_DAOfNInt: parseDAOfNInt(TDAOfNInt(pVal^), xval);
          CTC_DAOfBoolean: parseDAOfBoolean(TDAOfBoolean(pVal^), xval);
          CTC_DAOfString: parseDAOfString(TDAOfString(pVal^), xval);
          CTC_StringList: parseStringList(TStringList(pVal^), xval);
          CTC_Fecha: TFecha(pVal^) := TFecha.Create_str(xval);

          CTC_Referencia:
          begin
            nombreRef := '';
            clase := '';
            parsearReferencia(xval, clase, nombreRef);
            if (clase <> '?') then
              TCatalogoReferencias(Catalogo).registrar_referencia(referente,
                clase, nombreRef, pVal^)
            else
              TCosa(pVal^) := nil;
          end;

          CTC_Cosa:
          begin
            TCosa(pval^) := nil;
          end;
        end; // case
    except
      on E: Exception do
      begin
        raise ExcepcionResolverCampoValor.Create('ResolverCampoValor(' +
          xnombre + ',' + xval + ') ' + E.Message);
      end;
    end; // try
    // eliminamos la ficha de lectura pendiente pues fué resuelta
    TCampoParaLeer(items[k]).Free;
    Delete(k);
  end;
end;

// recorremos las fichas que hallan quedado sin resolver y les asignamos los
// valores por defecto (o tiramos excepciones si no se definió una función
// alternativa.
procedure TListCamposParaLeer.Ejecutar_vpds(klinea: integer);
var
  k: integer;
begin
  for k := 0 to Count - 1 do
  begin
    TCampoParaLeer(items[k]).Ejecutar_vpd(klinea);
    TCampoParaLeer(items[k]).Free;
  end;
  self.Clear;
end;

procedure TListCamposParaLeer.Ejecutar_vpd(klinea: integer; nombreCampo: string);
var
  k: integer;
begin
  for k := 0 to Count - 1 do
  begin
    if TCampoParaLeer(items[k]).nombre = nombreCampo then
    begin
      TCampoParaLeer(items[k]).Ejecutar_vpd(klinea);
      TCampoParaLeer(items[k]).Free;
      Delete(k);
      Pack;
      break;
    end;
  end;
end;

{$IFDEF DBG}
function TListCamposParaLeer.nombresCamposPorLeer: TDAofString;
var
  i: integer;
  res: TDAofString;
begin
  SetLength(res, self.Count);
  for i := 0 to Self.Count - 1 do
    res[i] := TCampoParaLeer(items[i]).nombre;
  Result := res;
end;
{$ENDIF}

begin
  ReferenciasAArchivosExternos := nil;
  lista_caminos := nil;
end.
