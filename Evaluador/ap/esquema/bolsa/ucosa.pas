(*
  Una cosa es un objeto que puede guardarse.
  Una TListaDeCosas, es una lista de cosas
*)

unit ucosa;

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}
interface

uses
{$IFNDEF FPC}
  Dialogs,
{$ENDIF}
  SysUtils, Classes, xmatdefs, ufechas, uauxiliares,
// uconstantesSimSEE,
   uVarDefs;



(*20080713-rch
Agrego la constante VERSION_ArchiTexto. La idea es que al guardar un
archivo se escriba el n�mero de version de forma que al leerlo podamos
saber con qu� n�mero de versi�n fue escrito.
Cada vez que realicemos un cambio de una clase que implique una transformaci�n
debemos cambiar el n�ermo de versi�n y ense�arle a la clase en cuesti�n que
si el n�mero de versi�n de un archivo que se est� leyendo es inferior al nuevo
n�mero debe leer de la forma antigua y luego aplicar las transformaciones que
correspondan. Al escribir debe escribir el objeto y transformado.
*)
const
  VERSION_ArchiTexto = 42;
  (* v42, Agrego la posibilidad de cambiar la forma de resumir las muestras en las fuentes sub-muestreadas
         se agrega el campo ResumirPromediando a las fuentes aleatorias.
  *)
//  VERSION_ArchiTexto = 41; // En la 40 comet� un error en etiquetado de curvas de ParqueEolico_vxy
//  VERSION_ArchiTexto = 39; rch@6.11.2010 agrego curvas VP por direcci�n en TParqueEolico_vxy
  // VERSION_ArchiTexto = 37; // rch@26.9.2010 agrego ArranqueConico en las fuentes CEGH
  // VERSION_ArchiTexto= 36; // rch@30.7.2010 agrego pago por energ�a en TParqueEolico para calculo de CAD
  // VERSION_ArchiTexto= 35; // rch@10.6.2010 cambi� en THidroDePasada que el valor del agua es en USD/Hm3
  // VERSION_ArchiTexto= 34; // rch@12.5.2010 le agrego al t�rmico b�sico el PagoPorPoencia y PagoPorEnergia

  //  VERSION_ArchiTexto= 33; // rch@28.3.2010 le agrego ArchivoCFaux en la sala para
  // que se guarde y no haya que escribirlo cada vez.
  //  VERSION_ArchiTexto= 32;  // Le agrego la capacidad de tener otro modeloAuxiliar
  // para ser usado en la optimizaci�n y para posicionar
  // el estado global durante la simulaci�n.
  //  VERSION_ArchiTexto= 31;  // le agrego par�metro multiplicar_vm alas fuentes CEGH
  //  VERSION_ArchiTexto= 30;  // introduce SaltoMinimoOperativo en las THidroConEmbalse y THidroDePasada
  //  VERSION_ArchiTexto= 29;  // introduce ControlDeCrecida en las THidroConEmbalse

  formatoReales = ffFixed;

  CF_PRECISION= 12;
  CF_DECIMALES= 2;

type
  TArchiTexto = class; // definido m�s adelante.

  // Clase de todas las cosas que usamos en una sala.
  TCosa = class
  public
    //      camposRegistradosParaPersistencia: TListaVarDefs;

    constructor Create;
    constructor Create_ReadFromText(f: TArchiTexto); virtual;
    function Create_Clone: TCosa; virtual;
    procedure WriteToText(f: TArchiTexto); virtual;
    class function DescClase: string; virtual;
    procedure Free; virtual;

{
     procedure registrarCampoNReal(nombre: string; var campo: NReal; precision: integer = CF_PRECISION; decimales: integer = CF_DECIMALES);
      procedure registrarCampoInt(nombre: string; var campo: Integer);
      procedure registrarCampoCardinal(nombre: string; var campo: Cardinal);
      procedure registrarCampoString(nombre: string; var campo: String);
      procedure registrarCampoArch(nombre: string; var campo: String);
      procedure registrarCampoBoolean(nombre: string; var campo: Boolean);
      procedure registrarCampoFecha(nombre: string; var campo: TFecha);
      procedure registrarCampoTDAOfNReal(nombre: string; var campo: TDAofNReal; precision: integer = CF_PRECISION; decimales: integer = CF_DECIMALES);
      procedure registrarCampoTDAOfNInt(nombre: string; var campo: TDAofNInt);
      procedure registrarCampoTStringList(nombre: string; var campo: TStringList);
      procedure registrarCampoTCosa(nombre: string; var campo: TCosa);
      procedure registrarCampoReferencia(nombre: string; var campo: TCosa);
}
{
      procedure wr( nombre: string; valor: NReal; precision : integer; decimales : integer); overload;
      procedure wr( nombre: string; valor: NReal ); overload;
      procedure wr( nombre: string; valor: String ); overload;
      procedure wrArch( nombre: string; valor: String );
      procedure wr( nombre: string; valor: NInt); overload;
      procedure wr( nombre: string; valor: Cardinal); overload;
      procedure wr( nombre: string; valor: Boolean ); overload;
      procedure wr( nombre: string; valor: TDAOfNReal; precision : integer; decimales : integer); overload;
      procedure wr( nombre: string; valor: TDAOfNReal ); overload;
      procedure wr( nombre: string; valor: TDAOfNInt ); overload;
      procedure wr( nombre: string; valor: TStringList ); overload;
      procedure wr( nombre: string; valor: TFecha ); overload;
      procedure wr( nombre: string; valor: TCosa ); overload;
      procedure wrReferencia( nombre: string; valor: TCosa );
}

  end;

  TClaseDeCosa = class of TCosa;
  TCualquierClase = class of TObject;

  TDAOfTCosa = array of TCosa;

  TListaDeCosas = class(TCosa)
  protected
    lst: TList;
    function getItem(i: integer): TCosa;
    procedure setItem(i: integer; cosa: TCosa);
    function getCapacity: integer;
    procedure setCapacity(newCapacity: integer);
  public
    idCarpeta: string; // identificador para salvar en carpeta
    constructor Create(idCarpeta: string);
    constructor Create_ReadFromText(f: TArchiTexto); override;
    procedure WriteToText(f: TArchiTexto); override;
    function Add(cosa: TCosa): integer; virtual;

    //Si freeElementos = true llama a ClearFreeElementos, sino a Clear,
    //luego hace add de todas las cosas en listaDeCosas
    procedure ponerIgualA(listaDeCosas: TListaDeCosas; freeElementos: boolean);

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
    property Capacity: integer Read getCapacity Write setCapacity;
    property items[i: integer]: TCosa Read getItem Write setItem; default;
  end;

(* La funci�n ProcesoLineaRes puede retornar laguno de los siguientes
valores. No se prev� un c�digo de error pues la funci�n lanza
excepciones con cualquier error que detecte. *)
  TResultadoProcesoLinea = (
    CTPLR_CONTINUAR,   // continuar procesando
    CTPLR_FIN_OBJETO,  // se lleg� al fin del objeto (cerrar la lista)
    CTPLR_ABRIR_NUEVO_OBJETO); // Se encontr� un objeto abrir otra lista

  TTipoCampo = (
    CTC_NReal,
    CTC_String,
    CTC_Arch,
    CTC_NInt,
    CTC_NCardinal,
    CTC_Boolean,
    CTC_DAOfNReal,
    CTC_DAOfNInt,
    CTC_StringList,
    CTC_Fecha,
    CTC_Cosa,
    CTC_Referencia);

  TProcFijarValorPorDefecto = procedure(const nombre: string; pVal: Pointer;
    tipo: TTipoCampo; const klinea: integer);

  TCampoParaLeer = class
  public
    nombre:    string;
    tipo:      TTipoCampo;
    pVal:      pointer;
    proc_vpd:  TProcFijarValorPorDefecto;
    referente: TCosa;
    flgError:  integer; // 0 es showmessage, 1 no muestra nada
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

  TListCamposParaLeer = class(TList)
  public
    cosa: TCosa;
    lecturaRetrasada, leiFinDeObjeto: boolean;
    constructor Create(IdentificadorDeLaClaseDelObjeto: string);
    procedure Esperar_NReal(const Nombre: string; var Variable: NReal;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_String(const Nombre: string; var Variable: string;
      proc_vpd: TProcFijarValorPorDefecto);
    procedure Esperar_Arch(const Nombre: string; var Variable: string;
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
    function ProcesarLinea(klinea: integer; linea: string;
      var extres: string): TResultadoProcesoLinea;
    procedure Free;
  private
    IdentificadorDeLaClaseDelObjeto: string; // identificador de la clase de objeto
    lineaAbierta:  boolean;
    xNombre, xval: string; // valores bajo procesamiento
    procedure ResolverCampoValor(const xNombre, xVal: string);
    procedure Ejecutar_vpds(klinea: integer);
    procedure Ejecutar_vpd(klinea: integer; nombreCampo: string);
{$IFDEF DBG}
    //Para debug, muestra los campos que la lista tiene por leer
    function NombresCamposPorLeer: TDAofString;
{$ENDIF}
  end;

  TListaDeObjetosPorLeer = class(TList)
  public
    constructor Create;
    procedure Free;
    function ListaActiva: TListCamposParaLeer;
    procedure FreeListaPorLeer; // libera la �ltima lista(cerr� objeto)
    procedure InicioObjeto(const NombreClase: string);
    procedure FinalObjeto;
  end;


  TArchiTexto = class
  public
    klinea:  integer;
    Version: integer;
    nombreArchivo: string;
    aux_idCarpeta: string;
    // auxiliar para pasaje de par�metros de TListaDeCosas CreateReadFromText

    unArchivoPorCosa: boolean;
    padre: TArchiTexto;
    ramas: TList;

    constructor CreateForRead(const nombreArchivo: string; abortarEnError: boolean);
    constructor CreateForWrite(const nombreArchivo: string; crearBackupSiExiste: boolean;
      maxNBackups: integer);

    procedure Free;
    function NextLine: string;
    procedure writeline(const s: string);

    procedure wr(const nombre: string; valor: NReal; precision: integer;
      decimales: integer); overload;
    procedure wr(const nombre: string; valor: NReal); overload;
    procedure wr(const nombre: string; valor: string); overload;
    procedure wrArch(const nombre: string; valor: string);
    procedure wr(const nombre: string; valor: NInt); overload;
    procedure wr(const nombre: string; valor: cardinal); overload;
    procedure wr(const nombre: string; valor: boolean); overload;
    procedure wr(const nombre: string; valor: TDAOfNReal; precision: integer;
      decimales: integer); overload;
    procedure wr(const nombre: string; valor: TDAOfNReal); overload;
    procedure wr(const nombre: string; valor: TDAOfNInt); overload;
    procedure wr(const nombre: string; valor: TStringList); overload;
    procedure wr(const nombre: string; valor: TFecha); overload;
    procedure wr(const nombre: string; valor: TCosa); overload;
    procedure wrReferencia(const nombre: string; valor: TCosa);


    procedure rd(const nombre: string; var valor: NReal); overload;
    procedure rd(const nombre: string; var valor: string); overload;
    procedure rdArch(const nombre: string; var valor: string);
    procedure rd(const nombre: string; var valor: NInt); overload;
    procedure rd(const nombre: string; var valor: cardinal); overload;
    procedure rd(const nombre: string; var valor: boolean); overload;
    procedure rd(const nombre: string; var valor: TDAOfNReal); overload;
    procedure rd(const nombre: string; var valor: TDAOfNInt); overload;
    procedure rd(const nombre: string; var valor: TStringList); overload;
    procedure rd(const nombre: string; var valor: TFecha); overload;

    // flgError= 0 lo mismo que sin flg. flgError= 1 no avisa del error
    procedure rd(const nombre: string; var valor: TFecha; flgError: integer); overload;
    procedure rd(const nombre: string; var valor: TCosa); overload;
    procedure rdReferencia(const nombre: string; var valor: TCosa; referente: TCosa);
    procedure IniciarLecturaRetrasada;
    procedure EjecutarLectura;

    function CreateRamaForWrite(const Carpeta, NombreClase, NombreCosa: string):
      TArchiTexto;
    function CreateRamaForRead(const Carpeta, NombreClase, NombreCosa: string):
      TArchiTexto;
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

  TProcMsg = procedure(msg: string);

procedure ValorPorDefectoNulo(const nombre: string; pVal: Pointer;
  tipo: TTipoCampo; const klinea: integer);
procedure ValorPorDefecto_ERROR(const nombre: string; pVal: Pointer;
  tipo: TTipoCampo; const klinea: integer);

var
  registro_de_ClasesDeActor: TListaDeCosas;
  procMsgValorPorDefecto: TProcMsg;
  procMsgErrorLectura: TProcMsg;
  procMsgAdvertenciaLectura: TProcMsg;

{$IFDEF CNT_COSAS}
type
  TCntCosasClase = class
  private
    clase: TClass;
    cnt:   integer;
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

function registrarClaseDeCosa(const nombre: string; Clase: TCualquierClase): integer;
function getClaseOf(const nombre: string): TCualquierClase;
// si la clase no est� registrada retorna '<CLASE_NO_REGISTRADA>'
function getIdStrOf(clase: TClaseDeCosa): string;


procedure LimpiarRegistroDeClasesDeCosas;

procedure AlInicio;
procedure AlFinal;

procedure FreeAndNil(var obj: TCosa);

// fija el directorio temporal para clonaciones
function getDir_Tmp: string;


type
  ExceptionFileNotFound = class(Exception)
  public
    arch: string;
    constructor Create(arch, comentarios: string);
  end;



implementation

uses
  uCosaConNombre;

var
  global_FlgError: integer;



function getDir_Tmp: string;
begin
  result:= '';
end;

 //---------------------------------
 // M�todos de ExceptionFileNotFound
 //=================================

constructor ExceptionFileNotFound.Create(arch, comentarios: string);
begin
  inherited Create('No se encuentra el archivo ' + arch + '. ' + comentarios);
  self.arch := arch;
end;

 //-----------------
 // M�todos de TCosa
 //=================

constructor TCosa.Create;
begin
  inherited Create;
end;

function TCosa.Create_Clone: TCosa;
var
  f: TArchiTexto;
  a: TCosa;
  dirTemporales: string;
begin
  dirTemporales := getDir_Tmp;

  f := TArchiTexto.CreateForWrite(dirTemporales + 'aux_clonar.tmp', False, 0);
  try
    f.wr('_', self);
  finally
    f.Free;
  end;

  f := TArchiTexto.CreateForRead(dirTemporales + 'aux_clonar.tmp', True);
  try
    f.rd('_', a);
    Result := a;
  finally
    f.Free;
  end;
end;

constructor TCosa.Create_ReadFromText(f: TArchiTexto);
begin
  inherited Create;
end;

procedure TCosa.Free;
begin
  ucosaConNombre.eliminar_referencias_del(self);
  inherited Free;
end;

procedure TCosa.WriteToText(f: TArchiTexto);
begin
end;

class function TCosa.DescClase: string;
begin
  Result := 'Cosa';
end;

type
  TFichaClaseActor = class
  public
    strClaseId: string;
    clase:      TCualquierClase;
    constructor Create(strClaseID: string; clase: TCualquierClase);
    procedure Free;
  end;

{$IFDEF CNT_COSAS}
constructor TCntCosasClase.Create(xclase: TClass);
begin
  clase := xclase;
  cnt   := 1;
end;

constructor TCntCosas.Create;
begin
  cnt_Cosas      := 0;
  CntCosasClases := TList.Create;
end;

function TCntCosas.incCntCosasClase(clase: TClass): integer;
var
  i:   integer;
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
  Result    := resultado;
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
      ipos      := i;
      cnt_Cosas := cnt_Cosas - 1;
      break;
    end;
  if ipos <> -1 then
    Result := TCntCosasClase(CntCosasClases[ipos]).cnt
  else
    raise Exception.Create('No hay instancias de cosas de la clase ' + clase.ClassName);
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

// m�todos de TFichaClaseActor
constructor TFichaClaseActor.Create(strClaseID: string; clase: TCualquierClase);
begin
  inherited Create;
  Self.strClaseId := strClaseId;
  self.clase      := clase;
end;

procedure TFichaClaseActor.Free;
begin
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
      ' No es una clase registrada. Procesando L�nea: ' + IntToStr(klinea));
  cosa := clase.Create_ReadFromText(Self);
end;

 //----------------------------------
 // M�todos de TListaDeCosasSinNombre
 //==================================

constructor TListaDeCosas.Create(idCarpeta: string);
begin
  inherited Create();
  self.idCarpeta := idCarpeta;
  lst := TList.Create;
end;

constructor TListaDeCosas.Create_ReadFromText(f: TArchiTexto);
var
  n, k:  integer;
  cosas: array of TCosa;
begin
  inherited Create_ReadFromText(f);
  self.idCarpeta := f.aux_idCarpeta;
  f.IniciarLecturaRetrasada;
  f.rd('n', n);
  f.EjecutarLectura;
  lst := TList.Create;
  SetLength(cosas, n);
  f.IniciarLecturaRetrasada;
  for k := 0 to n - 1 do
    f.rd(':', TCosa(cosas[k]));
  f.EjecutarLectura;

  //Esto es porque puede estar mal grabado el archivo y no se carguen las n cosas
  for k := 0 to n - 1 do
    if cosas[k] <> nil then
      lst.Add(cosas[k]);
  SetLength(cosas, 0);
end;

procedure TListaDeCosas.WriteToText(f: TArchiTexto);
var
  n, k: integer;
  cosa: TCosa;
begin
  inherited WriteToText(f);
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

procedure TListaDeCosas.Free;
var
  k: integer;
begin
  for k := 0 to lst.Count - 1 do
    if lst.Items[k] <> nil then
      TCosa(lst.items[k]).Free;
  lst.Free;
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
  i:   integer;
  res: TDAOfTCosa;
begin
  SetLength(res, lst.Count);
  for i := 0 to lst.Count - 1 do
    res[i] := lst[i];
  Result   := res;
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

function registrarClaseDeCosa(const nombre: string; Clase: TCualquierClase): integer;
var
  ficha: TFichaClaseActor;
begin
  ficha  := TFichaClaseActor.Create(nombre, clase);
  Result := registro_de_ClasesDeActor.lst.Add(ficha);
end;

function getClaseOf(const nombre: string): TCualquierClase;
var
  ipos: integer;
  res:  TCualquierClase;
begin
  res := nil;
  for ipos := 0 to registro_de_ClasesDeActor.lst.Count - 1 do
  begin
    if TFichaClaseActor(registro_de_ClasesDeActor.lst[ipos]).strClaseId = nombre then
    begin
      res := TFichaClaseActor(registro_de_ClasesDeActor.lst.items[ipos]).clase;
      break;
    end;
  end;

  if res = nil then
    raise Exception.Create('ucosa.getClaseOf: Clase de Actor desconocida ' + nombre)
  else
    Result := res;
end;

// si la clase no est� registrada retorna '<CLASE_NO_REGISTRADA>'
function getIdStrOf(clase: TClaseDeCosa): string;
var
  ipos:     integer;
  buscando: boolean;
begin
  buscando := True;
  for ipos := 0 to registro_de_ClasesDeActor.lst.Count - 1 do
    if TFichaClaseActor(registro_de_ClasesDeActor.lst.items[ipos]).Clase = Clase then
    begin
      buscando := False;
      break;
    end;
  if buscando then
    Result := '<CLASE_NO_REGISTRADA>'
  else
    Result := TFichaClaseActor(registro_de_ClasesDeActor.lst.items[ipos]).strClaseId;
end;

procedure LimpiarRegistroDeClasesDeCosas;
var
  k: integer;
begin
  for k := 0 to registro_de_ClasesDeActor.lst.Count - 1 do
    TFichaClaseActor(registro_de_ClasesDeActor.lst.items[k]).Free;
  registro_de_ClasesDeActor.lst.Clear;
end;

procedure AlInicio;
begin
{$IFDEF CNT_COSAS}
  CantCosas := TCntCosas.Create;
{$ENDIF}
  registro_de_ClasesDeActor := TListaDeCosas.Create('RegistroClasesDeActor');
  //  registrarClaseDeCosa( TCosa.ClassName, TCosa );
  registrarClaseDeCosa(TListaDeCosas.ClassName, TListaDeCosas);
end;

procedure AlFinal;
begin
  LimpiarRegistroDeClasesDeCosas;
  registro_de_ClasesDeActor.Free;
{$IFDEF CNT_COSAS}
  CantCosas.Free;
{$ENDIF}
end;

procedure FreeAndNil(var obj: TCosa);
var
  aux: TCosa;
begin
  aux := obj;
  obj := nil;
  aux.Free;
end;

constructor TListaDeObjetosPorLeer.Create;
begin
  inherited Create;
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
  a := TListCamposParaLeer.Create(NombreClase);
  add(a);
end;

procedure TListaDeObjetosPorLeer.FinalObjeto;
var
  xCosa: TCosa;
  nombreDelCampoObjeto: string;
  lpl:   TListCamposParaLeer;
  i:     integer;
  res:   boolean;
begin
  // procesar hasta el final del objeto
  lpl   := ListaActiva;
  xCosa := lpl.cosa;
  FreeListaPorLeer;
  lpl := ListaActiva;
  nombreDelCampoObjeto := lpl.xNombre;
  res := False;
  for i := 0 to lpl.Count - 1 do
    if TCampoParaLeer(lpl[i]).nombre = nombreDelCampoObjeto then
    begin
      TCosa(TCampoParaLeer(lpl.items[i]).pVal^) := xCosa;
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

constructor TArchiTexto.CreateForRead(const nombreArchivo: string; abortarEnError: boolean);
var
  s: string;
begin
  setSeparadoresGlobales;

  if FileExists(nombreArchivo) then
  begin
    inherited Create;
    f_abierto := False;
    unArchivoPorCosa := False;
    padre     := nil;
    ramas     := nil;


    Self.NombreArchivo := nombreArchivo;
    oldFileMode := FileMode;
    filemode    := fmOpenRead;

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
    s      := trim(s);
    klinea := 0;

    if pos('VERSION=', s) = 1 then
    begin
      Delete(s, 1, 8);
      version := StrToInt(s);
      Inc(klinea);
    end
    else
      version := 0;

    listaObjetosPorLeer := TListaDeObjetosPorLeer.Create();
    indentstr := '';
    listaObjetosPorLeer.InicioObjeto('TODO');
  end
  else
    //    raise ExceptionFileNotFound.Create('TArchiTexto.CreateForRead: no se encuentra el archivo ' + nombreArchivo);
    raise Exception.Create('TArchiTexto.CreateForRead: no se encuentra el archivo ' +
      nombreArchivo);
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

{$IFDEF backupear}
  if crearBackupSiExiste and FileExists(nombreArchivo) then
    uconstantesSimSEE.backupearArchivoAntesDeSalvar(nombreArchivo, maxNBackups);
{$ENDIF}
  assignFile(f, NombreArchivo);
  oldFileMode := FileMode;
  filemode    := fmOpenWrite;
   {$I-}
  Rewrite(f);
   {$I+}
  if ioresult = 0 then
    f_abierto := True
  else
    raise Exception.Create('TArchiTexto.CreateForWrite(' + nombreArchivo + ')');

  writeln(f, 'VERSION=' + IntToStr(VERSION_ArchiTexto));
  klinea := 1;
  listaObjetosPorLeer := TListaDeObjetosPorLeer.Create();
end;


function TArchiTexto.CreateRamaForWrite(const Carpeta, NombreClase, NombreCosa: string):
TArchiTexto;
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


function TArchiTexto.CreateRamaForRead(const carpeta, NombreClase, NombreCosa: string):
TArchiTexto;
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
  a := TArchiTexto.CreateForRead(s, self.abortarEnError);
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
    raise Exception.Create('Llegu� al fin del archivo en forma inesperada.');
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

procedure TArchiTexto.wr(const nombre: string; valor: NReal; precision: integer;
  decimales: integer);
begin
  writeline(nombre + '= ' + FloatToStrF(valor, ffGeneral, precision, decimales) + ';');
end;

procedure TArchiTexto.wr(const nombre: string; valor: NReal);
begin
  wr(nombre, valor, CF_PRECISION, CF_DECIMALES);
end;

procedure TArchiTexto.wr(const nombre: string; valor: string);
begin
  writeline(nombre + '= ' + valor + ';');
end;

procedure TArchiTexto.wrArch(const nombre: string; valor: string);
begin
  writeline(nombre + '= ' + valor + ';');
end;

procedure TArchiTexto.wr(const nombre: string; valor: NInt);
begin
  writeline(nombre + '= ' + IntToStr(valor) + ';');
end;

procedure TArchiTexto.wr(const nombre: string; valor: cardinal);
begin
  writeline(nombre + '= ' + IntToStr(valor) + ';');
end;

procedure TArchiTexto.wr(const nombre: string; valor: TFecha);
begin
  writeline(nombre + '= ' + valor.AsStr + ';');
end;

procedure TArchiTexto.wr(const nombre: string; valor: TCosa);
var
  CosaStrId: string;
  clase:     TClaseDeCosa;
begin
  if valor <> nil then
  begin
    clase     := TClaseDeCosa(valor.ClassType);
    CosaStrId := getIdStrOf(clase);
    writeline(nombre + '= <+' + CosaStrId + '>');
    indentstr := indentstr + '  ';
    valor.WriteToText(Self);
    Delete(indentstr, length(indentstr) - 1, 2);
    writeline('<-' + CosaStrId + '>;');
  end
  else
    writeline(nombre + '= NIL;');
end;

procedure TArchiTexto.wr(const nombre: string; valor: boolean);
begin
  if valor then
    writeline(nombre + '= 1;')
  else
    writeline(nombre + '= 0;');
end;

procedure TArchiTexto.wr(const nombre: string; valor: TDAOfNReal;
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

procedure TArchiTexto.wr(const nombre: string; valor: TDAOfNReal);
begin
  wr(nombre, valor, 12, 3);
end;

procedure TArchiTexto.wr(const nombre: string; valor: TDAOfNInt);
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

procedure TArchiTexto.wr(const nombre: string; valor: TStringList);
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

procedure TArchiTexto.wrReferencia(const nombre: string; valor: TCosa);
begin
  if assigned(valor) and (valor is TCosaConNombre) then
    writeline(nombre + '= <' + valor.ClassName + '.' +
      TCosaConNombre(valor).nombre + '>;')
(* rch0707121651 comento esto para que si est� mal escriba referencia vac�a y listo
    else
      raise Exception.Create('TArchiTexto.wrReferencia: intenta escribir una referencia a algo que no es TCosaConNombre');
  end
*)
  else
    writeline(nombre + '= <?.?>;');
end;

procedure TArchiTexto.rd(const nombre: string; var valor: NReal);
begin
  ListaPorLeer.Esperar_NReal(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: string);
begin
  ListaPorLeer.Esperar_String(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rdArch(const nombre: string; var valor: string);
begin
  ListaPorLeer.Esperar_Arch(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: NInt);
begin
  ListaPorLeer.Esperar_NInt(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: cardinal);
begin
  ListaPorLeer.Esperar_NCardinal(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TFecha);
begin
  ListaPorLeer.Esperar_Fecha(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

// flgError= 0 lo mismo que sin flg. flgError= 1 no avisa del error
procedure TArchiTexto.rd(const nombre: string; var valor: TFecha; flgError: integer);
begin
  ListaPorLeer.Esperar_Fecha(nombre, valor, nil, flgError);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;


procedure TArchiTexto.rd(const nombre: string; var valor: boolean);
begin
  ListaPorLeer.Esperar_Boolean(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TDAOfNReal);
begin
  ListaPorLeer.Esperar_DAOfNReal(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TCosa);
begin
  ListaPorLeer.Esperar_Cosa(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TDAOfNInt);
begin
  ListaPorLeer.Esperar_DAOfNInt(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd(const nombre: string; var valor: TStringList);
begin
  ListaPorLeer.Esperar_StringList(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rdReferencia(const nombre: string; var valor: TCosa;
  referente: TCosa);
begin
  ListaPorLeer.Esperar_Referencia(nombre, valor, nil, referente);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.IniciarLecturaRetrasada;
begin
  if ListaPorLeer <> nil then
    ListaPorLeer.lecturaRetrasada := True;
end;

procedure TArchiTexto.EjecutarLectura;
var
  s, NombreClaseSiguienteObjeto: string;
  resObjetoHijo, resObjetoPadre: TResultadoProcesoLinea;
  lpl:      TListCamposParaLeer;
{$IFDEF DBG}
  dbgAux:   TDAofString;
{$ENDIF}
  indiceDeLinea: integer;
  posIgual: integer;
begin
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
// system.writeln( indiceDeLinea:6, ': ', s );
      try
        resObjetoPadre := lpl.ProcesarLinea(klinea, s, NombreClaseSiguienteObjeto);
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
            //El +1 deber�a ser el n�mero de lineas que leyo y no le sirvieron
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
            resObjetoHijo := lpl.ProcesarLinea(klinea, s, NombreClaseSiguienteObjeto);
          until resObjetoHijo = CTPLR_FIN_OBJETO;

        listaObjetosPorLeer.FinalObjeto;
        lpl := ListaPorLeer;
      end;
    end;
    if resObjetoPadre = CTPLR_FIN_OBJETO then
      ListaPorLeer.leiFinDeObjeto := True;
  except
    on E: Exception do
      if pos('kLinea:', E.Message) = 0 then
        raise Exception.Create('kLinea:(' + IntToStr(klinea) + ') ' + E.Message)
      else
        raise;
  end; // try
       //ListaPorLeer.lecturaRetrasada:= false;
end;

function TipoToStr(tipo: TTipoCampo): string;
begin
  case Tipo of
    CTC_NReal: Result     := 'NReal';
    CTC_String: Result    := 'String';
    CTC_Arch: Result      := 'Archivo';
    CTC_NInt: Result      := 'Entero';
    CTC_NCardinal: Result := 'Entero Positivo';
    CTC_Boolean: Result   := 'Booleano';
    CTC_DAOfNReal: Result := 'Array din�mico de Reales';
    CTC_DAOfNInt: Result  := 'Array din�mico de Enteros';
    CTC_Fecha: Result     := 'Fecha';
    CTC_Cosa: Result      := 'Cosa';
  end; // case
end;

procedure ValorPorDefectoNulo(const nombre: string; pVal: Pointer;
  tipo: TTipoCampo; const klinea: integer);
var
  Msg: string;
begin
  case Tipo of
    CTC_NReal: NReal(pVal^)     := 0;
    CTC_String: string(pVal^)   := '';
    CTC_Arch: string(pVal^)     := '';
    CTC_NInt: NEntero(pVal^)    := 0;
    CTC_NCardinal: cardinal(pVal^) := 0;
    CTC_Boolean: boolean(pVal^) := False;
    CTC_DAOfNReal: setlength(TDAOfNReal(pVal^), 0);
    CTC_DAOfNInt: setlength(TDAOfNInt(pVal^), 0);
    CTC_Fecha: TFecha(pVal^) := TFecha.Create_dt(0);
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
  msg := 'No se encontr� una definici�n para el campo: ' + nombre +
    ' tipo: ' + TipoToStr(tipo);
  if klinea <> -1 then
    msg := msg + ' leyendo el final del objeto en la linea ' + IntToStr(klinea)
  else
    msg := msg + ' en el final del archivo.';

  //  raise Exception.Create(msg);

{$IFDEF FPC}
  writeln(msg);
  Write('... presine ENTER para continuar.');
  system.readln;
{$ELSE}
  ShowMessage(msg);
{$ENDIF}
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
  self.flgError  := 0;
  self.nombre    := nombre;
  self.tipo      := tipo;
  self.pVal      := pVal;
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

constructor TListCamposParaLeer.Create(IdentificadorDeLaClaseDelObjeto: string);
begin
  inherited Create;
  self.IdentificadorDeLaClaseDelObjeto := IdentificadorDeLaClaseDelObjeto;
  lineaAbierta := False;
  xNombre := '';
  xval := '';
  lecturaRetrasada := False;
  leiFinDeObjeto := False;
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

procedure TListCamposParaLeer.Esperar_Arch(const Nombre: string;
  var Variable: string; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_Arch, proc_vpd);
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

procedure TListCamposParaLeer.Esperar_StringList(const Nombre: string;
  var Variable: TStringList; proc_vpd: TProcFijarValorPorDefecto);
var
  a: TCampoParaLeer;
begin
  a := TCampoParaLeer.Create(Nombre, @Variable, CTC_StringList, proc_vpd);
  add(a);
end;


procedure TListCamposParaLeer.Esperar_Cosa(const Nombre: string; var Variable: TCosa;
  proc_vpd: TProcFijarValorPorDefecto);
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
  var Variable: TFecha; proc_vpd: TProcFijarValorPorDefecto;
  flgError: integer);
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
  var extres: string): TResultadoProcesoLinea;
var
  NombreClase: string;
begin
  Result := CTPLR_CONTINUAR;

  if pos('<-', linea) = 1 then
  begin
    if IdentificadorDeLaClaseDelObjeto <> '' then
      if pos(IdentificadorDeLaClaseDelObjeto, linea) <> 3 then
        raise Exception.Create('Error, cierre de objeto : ' + linea + ' Se esperaba: ' +
          '<-' + IdentificadorDeLaClaseDelObjeto + '>, en l�nea: ' + IntToStr(klinea));

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
      if getnextpal(xnombre, linea, '=') then
      begin
        xval := trim(linea);
        if length(xval) > 0 then
        begin
          if pos('<+', xval) = 1 then
          begin
            system.Delete(xval, 1, 2);
            if xval[length(xval)] <> '>' then
              raise Exception.Create('Error, falta el > de cierre en fin de clase : ' + xval);

            NombreClase := copy(xval, 1, length(xval) - 1);
            extres      := NombreClase;
            Result      := CTPLR_ABRIR_NUEVO_OBJETO;
          end
          else
          if xval[length(xval)] = ';' then
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
        Exception.Create('Error, no encontr� el (=) en la l�nea: [' +
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
  //quedar�an colgados todos los campos para leer de cada TCosa
  for k:= 0 to count - 1 do
    TCampoParaLeer( items[k] ).Free;
  inherited Free;
end;

procedure TListCamposParaLeer.ResolverCampoValor(const xNombre, xVal: string);
var
  buscando: boolean;
  k: integer;
  clase, nombreRef: string;
begin
  buscando := True;
  k := 0;
  while buscando and (k < Count) do
    if TCampoParaLeer(items[k]).nombre = xNombre then
      buscando := False
    else
      Inc(k);

  if buscando then
    raise ExcepcionNoSePidioElCampo.Create(
      'Se ley� el campo: ' + xnombre + ' pero no se esperaba en el objeto: ' +
      IdentificadorDeLaClaseDelObjeto +
      '. Pruebe guardar y cargar nuevamente la sala. Intentar� solucionar el problema.')
  else
  begin
    try
      with  TCampoParaLeer(items[k]) do
        case Tipo of
          CTC_NReal: NReal(pVal^)   := StrToFloat(xval);
          CTC_String: string(pVal^) := xval;
          CTC_Arch:
          begin
            string(pVal^) := xval;
                          {$IFDEF LINUX}
            toLinuxDir(string(pVal^));
                          {$ENDIF}
          end;
          CTC_NInt: NEntero(pVal^)    := StrToInt(xval);
          CTC_NCardinal: cardinal(pVal^) := StrToInt(xval);
          CTC_Boolean: boolean(pVal^) := (xval <> '') and (xval[1] = '1');
          CTC_DAOfNReal: parseDAOfNreal(TDAOfNReal(pVal^), xval);
          CTC_DAOfNInt: parseDAOfNInt(TDAOfNInt(pVal^), xval);
          CTC_StringList: parseStringList(TStringList(pVal^), xval);
          CTC_Fecha: TFecha(pVal^) := TFecha.Create_str(xval);
          CTC_Referencia:
          begin
            parsearReferencia(xval, clase, nombreRef);
            if (clase <> '?') then
              uCosaConNombre.registrar_referencia(referente,
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
         // eliminamos la ficha de lectura pendiente pues fu� resuelta
    TCampoParaLeer(items[k]).Free;
    Delete(k);
  end;
end;

 // recorremos las fichas que hallan quedado sin resolver y les asignamos los
 // valores por defecto (o tiramos excepciones si no se defini� una funci�n
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
  i:   integer;
  res: TDAofString;
begin
  SetLength(res, self.Count);
  for i := 0 to Self.Count - 1 do
    res[i] := TCampoParaLeer(items[i]).nombre;
  Result   := res;
end;

{$ENDIF}

function TFecha_Create_ReadFromText(NombreCampo: string; f: TArchiTexto): TFecha;
var
  s:     string;
  fecha: TFecha;
  dt:    TDateTime;
begin
  f.rd(NombreCampo, s);
  dt     := StrToDateTime(s);
  fecha  := TFecha.Create_dt(dt);
  Result := fecha;
end;

procedure TFecha_WriteToText(fecha: TFecha; NombreCampo: string; f: TArchiTexto);
begin
  f.wr(NombreCampo, fecha.AsStr);
end;

end.

