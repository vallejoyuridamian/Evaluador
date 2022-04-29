{
 +doc
 +NOMBRE: uCampo
 +CREACION: Julio 2011
 +AUTORES: Pablo Alfaro
 +REGISTRO:
 +TIPO: Unidad Pascal.
 +PROPOSITO: acceso uniforme a los campos de objetos del sistema sin importar
 la clase del objeto
 +PROYECTO: SimSEE

 +REVISION: Julio 2011
 +AUTOR: Pablo Alfaro
 +DESCRIPCION:
 Esta unidad permite definir el conjunto de campos que tiene un objeto y asociarlo
 a su clase, de modo de poder acceder a ellos uniformemente para cualquier clase
 de objeto del sistema.
 La funcionalidad para la que fue desarrollada es llenar en forma genérica las
 tablas de parámetros dinámicos de los actores y permitir la edición de estos
 campos directamente de la tabla, sin necesidad de entrar al formulario de
 edición de la ficha.

 ************************** Definición de un campo *****************************
 Los objetos son almacenados en memoria como un array plano de bytes con todos
 sus campos contiguos. Los tipos de los campos delimitan su tamaño. Así si un
 objeto tiene un campo integer, un campo puntero y un campo double (en ese orden)
 su disposición será la siguiente:

 InicioObjeto
 Int Ptr Dbl     Memoria fuera del objeto
 0...4...8.......16

 Cada TCampo guarda la diferencia en bytes (offset) desde la posición en memoria
 del campo del objeto y la posición en memoria del inicio del objeto.

 IniObjeto.......Campo del Objeto
 100.............112
 ....Offset=12...

 De esta manera cambiando el inicio del objeto y realizando el casteo
 correspondiente según el tipo del campo se obtiene el valor del campo para otro
 objeto
 Informalmente:
 Cast(IniObj' + Offset) = valor del campo de Obj'

 A estos campos se les da un nombre (y un nombre corto y unidad para facilitar la
 presentación) por el que luego podrán ser buscados.
 A su vez estos valores pueden ser casteados a otros tipos y en particular todos
 son casteables a string para poder presentarlos.

 ************************* Campos vs Campos Primitivos *************************
 Se realiza una clasificación entre los campos "primitivos" y los campos en general.
 Campos primitivos son aquellos cuyo valor es fácilmente ingresable como un string.
 Así, los campos de tipo integer, double, boolean, string y TFecha (en principio)
 son campos primitivos.
 Los campos en general, no tienen esta restricción y pueden incluir arreglos de
 tipos primitivos, referencias a objetos, objetos directamente, etc.

 ***************************** Campos de las clases ****************************
 Una vez creados los campos de un objeto, estos se asocian a su clase en la lista
 global listaCamposDeClases perteneciente a esta unidad.
 Esta lista guarda para cada clase sus campos y sus campos primitivos
 (diferenciados en 2 arreglos), para poder acceder a ellos.

 El formulario de edición de actores con fichas (TEditarActorConFichas), busca
 los campos primitivos de la clase del objeto que se esté editando, y luego
 llena la tabla de parámetros dinámicos con los valores de los campos casteados
 a string.
 Esta tabla luego puede ser editada directamente, gracias a haber sido llenada
 con valores de campos primitivos. Al modificar una celda se verifica por medio
 de un TValidador si el valor de la celda es válido para el campo y en caso de
 serlo, se modifica.

 ********************************** TO-DO **************************************
 Fecha: 08/07/2011
 Descripción: las clases implementadas actualmente solo permiten representar
 campos primitivos. Para campos mas complejos, como referencias a objetos o
 compuestos, como referencias a fuentes y borne de la fuente habría que
 desarrollar las clases TCampo necesarias y si buscar una forma, en lo posible,
 de ingresarlos como string, para hacerlos campos primitivos y poder ingresarlos
 de tablas.
 -doc }
unit uCampos;
interface

uses
  SysUtils, StrUtils, Math, uConstantesSimSEE, uFechas, Classes,
  uValidador,
  uCosa, uCosaConNombre, usalasdejuegoParaeditor;


type

  TCampo = class
  protected
    offset: Integer;
  public
    nombre, nombreCorto, unidad: String;

    validador: TValidador;
    // No instanciar esta clase directamente, crear una de sus derivadas con
    // este constructor
    Constructor Create(const nombre, nombreCorto, unidad: String; offset: Integer;
      validador: TValidador);

    // retorna un putero al comienzo del dato en base al offset.
    function val_ptr(objeto: TObject): pointer; virtual;

    function asString(objeto: TObject): String; virtual; abstract;
    function asBoolean(objeto: TObject): boolean; virtual; abstract;

    Destructor Destroy; override;
  end;

  TCampoPrimitivo = class(TCampo)
    procedure setValorFromString(objeto: TObject; const valor: String); virtual; abstract;
  end;

  TCampoInteger = class(TCampoPrimitivo)
  public
    procedure setValorFromString(objeto: TObject; const valor: String); override;
    function asString(objeto: TObject): String; override;
    function asBoolean(objeto: TObject): boolean; override;
  end;

  TCampoDouble = class(TCampoPrimitivo)
  public
    procedure setValorFromString(objeto: TObject; const valor: String); override;

    function asString(objeto: TObject): String; override;
    function asBoolean(objeto: TObject): boolean; override;
  end;

  TCampoString = class(TCampoPrimitivo)
  public
    procedure setValorFromString(objeto: TObject; const valor: String); override;

    function asString(objeto: TObject): String; override;
    function asBoolean(objeto: TObject): boolean; override;
  end;

  TCampoBoolean = class(TCampoPrimitivo)
  public
    procedure setValorFromString(objeto: TObject; const valor: String); override;

    function asString(objeto: TObject): String; override;
    function asBoolean(objeto: TObject): boolean; override;
  end;

  TCampoFecha = class(TCampoPrimitivo)
  public
    procedure setValorFromString(objeto: TObject; const valor: String); override;

    function asString(objeto: TObject): String; override;
    function asBoolean(objeto: TObject): boolean; override;
  end;

  { TCampoReferenciaObjeto = class(TCampoPrimitivo)
    public
    claseReferenciado: TClass;
    Constructor Create(const nombre: String; offset: Integer;
    claseReferenciado: TClass; validador: TValidador); reintroduce;
    procedure setValorFromString(objeto: TObject; const valor: String);
    override;

    function asString(objeto: TObject): String; override;
    function asBoolean(objeto: TObject): boolean; override;
    end; }

  TDAOfTCampo = array of TCampo;
  TDAOfTCampoPrimitivo = array of TCampoPrimitivo;

  TParClaseCampos = class
  public
    clase: TClass;
    campos: TDAOfTCampo;
    camposPrimitivos: TDAOfTCampoPrimitivo;

    Constructor Create(clase: TClass; const campos: TDAOfTCampo);
    Destructor Destroy; override;
  end;

  TListaCamposDeClase = class(TList)
  public
    function getCamposDeClase(clase: TClass): TDAOfTCampo;
    function getCamposPrimitivosDeClase(clase: TClass): TDAOfTCampoPrimitivo;

    function indiceDeClase(clase: TClass): Integer;

    procedure quitarClase(clase: TClass; liberarDefinicion: boolean);
  end;

  // Facilitadoras para crear campos

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: String): TCampoString; overload;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Integer): TCampoInteger; overload;
function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Integer; minimoValido, maximoValido: Integer): TCampoInteger; overload;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Double): TCampoDouble; overload;
function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Double; minimoValido, maximoValido: Double): TCampoDouble; overload;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: boolean): TCampoBoolean; overload;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: TFecha): TCampoFecha; overload;

// Facilitadoras para crear campos y añadirlos a un array de campos

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: String; var arreglo: TDAOfTCampo; var i: Integer); overload;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Integer; var arreglo: TDAOfTCampo; var i: Integer); overload;
procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Integer; minimoValido, maximoValido: Integer; var arreglo: TDAOfTCampo;
  var i: Integer); overload;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Double; var arreglo: TDAOfTCampo; var i: Integer); overload;
procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Double; minimoValido, maximoValido: Double; var arreglo: TDAOfTCampo;
  var i: Integer); overload;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: boolean; var arreglo: TDAOfTCampo; var i: Integer); overload;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: TFecha; var arreglo: TDAOfTCampo; var i: Integer); overload;

//Facilitadoras para acceso a un campo de un array por nombre

function buscarCampoPorNombre(const arreglo: TDAOfTCampo; const nombre: String): TCampo;
  overload;
function buscarCampoPorNombre(const arreglo: TDAOfTCampo; const nombre: String;
  var campo: TCampo): boolean; overload;
procedure liberarTDAOfTCampo(var arreglo: TDAOfTCampo);

function buscarCampoPrimitivoPorNombre(const arreglo: TDAOfTCampoPrimitivo;
  const nombre: String): TCampoPrimitivo; overload;
function buscarCampoPrimitivoPorNombre(const arreglo: TDAOfTCampoPrimitivo;
  const nombre: String; var campo: TCampoPrimitivo): boolean; overload;
procedure liberarTDAOfTCampoPrimitivo(var arreglo: TDAOfTCampoPrimitivo);

var
  // Contiene objetos de tipo TParClaseCampos
  listaCamposDeClases: TListaCamposDeClase;

implementation

{ TCampo }

type
  PByte = PChar; // solo para que funcione sumar un offset

constructor TCampo.Create(const nombre, nombreCorto, unidad: String; offset: Integer;
  validador: TValidador);
begin
  inherited Create;
  self.nombre := nombre;
  self.nombreCorto := nombreCorto;
  self.unidad := unidad;
  self.offset := offset;
  self.validador := validador;
end;

// retorna un putero al comienzo del dato en base al offset.
function TCampo.val_ptr(objeto: TObject): pointer;
begin
  result := (PChar(objeto) + offset);
end;

destructor TCampo.Destroy;
begin
  validador.Free;
  inherited;
end;

{ TCampoString }

procedure TCampoString.setValorFromString(objeto: TObject; const valor: String);
begin
  { if query.FieldByName(nombre).IsNull then
    PString((PByte(objeto) + offset))^ := NULL_STR
    else }

  PString(val_ptr(objeto))^ := valor;
end;

function TCampoString.asBoolean(objeto: TObject): boolean;
begin
  result := StrToBool(PString(val_ptr(objeto))^);
end;

function TCampoString.asString(objeto: TObject): String;
begin
  result := PString(val_ptr(objeto))^;
end;

{ TCampoInteger }

procedure TCampoInteger.setValorFromString(objeto: TObject; const valor: String);
begin
  PInteger(val_ptr(objeto))^ := StrToInt(valor);
end;

function TCampoInteger.asBoolean(objeto: TObject): boolean;
begin
  result := PInteger(val_ptr(objeto))^ <> 0;
end;

function TCampoInteger.asString(objeto: TObject): String;
begin
  result := IntToStr(PInteger(val_ptr(objeto))^);
end;

{ TCampoDouble }

procedure TCampoDouble.setValorFromString(objeto: TObject; const valor: String);
begin
  PDouble(val_ptr(objeto))^ := StrToFloat(valor);
end;

function TCampoDouble.asBoolean(objeto: TObject): boolean;
begin
  result := PDouble(val_ptr(objeto))^ <> 0;
end;

function TCampoDouble.asString(objeto: TObject): String;
begin
  result := FloatToStr(PDouble(val_ptr(objeto))^);
end;

{ TCampoBoolean }

procedure TCampoBoolean.setValorFromString(objeto: TObject; const valor: String);
begin
  PBoolean(val_ptr(objeto))^ := StrToBool(valor);
end;

function TCampoBoolean.asBoolean(objeto: TObject): boolean;
begin
  result := PBoolean(val_ptr(objeto))^;
end;

function TCampoBoolean.asString(objeto: TObject): String;
begin
  result := BoolToStr(PBoolean(val_ptr(objeto))^, True);
end;

{ TCampoFecha }

procedure TCampoFecha.setValorFromString(objeto: TObject; const valor: String);
begin
  if PFecha(val_ptr(objeto))^ = NIL then
    PFecha(val_ptr(objeto))^ := TFecha.Create_Any_Str(valor)
  else
    PFecha(val_ptr(objeto))^.setDt(valor);
end;

function TCampoFecha.asBoolean(objeto: TObject): boolean;
begin
  result := PFecha(val_ptr(objeto))^.dt <> 0;
end;

function TCampoFecha.asString(objeto: TObject): String;
begin
  result := PFecha(val_ptr(objeto))^.AsStr;
end;

{ TListaCamposDeClase }

function TListaCamposDeClase.getCamposDeClase(clase: TClass): TDAOfTCampo;
var
  i: Integer;
begin
  result := NIL;
  for i := 0 to Count - 1 do
    if TParClaseCampos(items[i]).clase = clase then
    begin
      result := TParClaseCampos(items[i]).campos;
      break;
    end;
end;

function TListaCamposDeClase.getCamposPrimitivosDeClase(clase: TClass): TDAOfTCampoPrimitivo;
var
  i: Integer;
begin
  result := NIL;
  for i := 0 to Count - 1 do
    if TParClaseCampos(items[i]).clase = clase then
    begin
      result := TParClaseCampos(items[i]).camposPrimitivos;
      break;
    end;
end;

function TListaCamposDeClase.indiceDeClase(clase: TClass): Integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to Count - 1 do
    if TParClaseCampos(items[i]).clase = clase then
    begin
      result := i;
      break;
    end;
end;

procedure TListaCamposDeClase.quitarClase(clase: TClass; liberarDefinicion: boolean);
var
  iClase: Integer;
begin
  iClase := indiceDeClase(clase);

  if iClase <> -1 then
  begin
    if liberarDefinicion then
      TParClaseCampos(items[iClase]).Free;
    self.Delete(iClase);
  end;
end;

(*
  { TCampoReferenciaObjeto }

  constructor TCampoReferenciaObjeto.Create(const nombre: String;
  offset: Integer; claseReferenciado: TClass; validador: TValidador);
  begin
  inherited Create(nombre, offset, validador);
  self.claseReferenciado := claseReferenciado;
  end;

  procedure TCampoReferenciaObjeto.setValorFromString(objeto: TObject;
  const valor: String);
  begin
  PCosaConNombre((PByte(objeto) + offset))^ :=
  end;

  function TCampoReferenciaObjeto.asString(objeto: TObject): String;
  begin
  result :=
  end;

  function TCampoReferenciaObjeto.asBoolean(objeto: TObject): boolean;
  begin

  end; *)

{ Funciones facilitadoras }

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: String): TCampoString;
begin
  result := TCampoString.Create(nombre, nombreCorto, unidad, PByte(@campo) - PByte(objeto),
    TValidadorString.Create);
end;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Integer): TCampoInteger;
begin
  result := TCampoInteger.Create(nombre, nombreCorto, unidad, PByte(@campo) - PByte(objeto),
    TValidadorInteger.Create(-MaxInt, MaxInt));
end;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Integer; minimoValido, maximoValido: Integer): TCampoInteger;
begin
  result := TCampoInteger.Create(nombre, nombreCorto, unidad, PByte(@campo) - PByte(objeto),
    TValidadorInteger.Create(minimoValido, maximoValido));
end;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Double): TCampoDouble;
begin
  result := TCampoDouble.Create(nombre, nombreCorto, unidad, PByte(@campo) - PByte(objeto),
    TValidadorDouble.Create(-MaxDouble, MaxDouble));
end;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Double; minimoValido, maximoValido: Double): TCampoDouble; overload;
begin
  result := TCampoDouble.Create(nombre, nombreCorto, unidad, PByte(@campo) - PByte(objeto),
    TValidadorDouble.Create(minimoValido, maximoValido));
end;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: boolean): TCampoBoolean;
begin
  result := TCampoBoolean.Create(nombre, nombreCorto, unidad, PByte(@campo) - PByte(objeto),
    TValidadorBoolean.Create);
end;

function CrearCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: TFecha): TCampoFecha;
begin
  result := TCampoFecha.Create(nombre, nombreCorto, unidad, PByte(@campo) - PByte(objeto),
    TValidadorFecha.Create);
end;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: String; var arreglo: TDAOfTCampo; var i: Integer);
begin
  arreglo[i] := CrearCampo(nombre, nombreCorto, unidad, objeto, campo);
  i := i + 1;
end;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Integer; var arreglo: TDAOfTCampo; var i: Integer);
begin
  arreglo[i] := CrearCampo(nombre, nombreCorto, unidad, objeto, campo);
  i := i + 1;
end;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Integer; minimoValido, maximoValido: Integer; var arreglo: TDAOfTCampo;
  var i: Integer);
begin
  arreglo[i] := CrearCampo(nombre, nombreCorto, unidad, objeto, campo, minimoValido,
    maximoValido);
  i := i + 1;
end;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Double; var arreglo: TDAOfTCampo; var i: Integer);
begin
  arreglo[i] := CrearCampo(nombre, nombreCorto, unidad, objeto, campo);
  i := i + 1;
end;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: Double; minimoValido, maximoValido: Double; var arreglo: TDAOfTCampo;
  var i: Integer);
begin
  arreglo[i] := CrearCampo(nombre, nombreCorto, unidad, objeto, campo, minimoValido,
    maximoValido);
  i := i + 1;
end;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: boolean; var arreglo: TDAOfTCampo; var i: Integer);
begin
  arreglo[i] := CrearCampo(nombre, nombreCorto, unidad, objeto, campo);
  i := i + 1;
end;

procedure addCampo(const nombre, nombreCorto, unidad: String; objeto: TObject;
  var campo: TFecha; var arreglo: TDAOfTCampo; var i: Integer);
begin
  arreglo[i] := CrearCampo(nombre, nombreCorto, unidad, objeto, campo);
  i := i + 1;
end;

{ TDAOfTCampo }

function buscarCampoPorNombre(const arreglo: TDAOfTCampo; const nombre: String): TCampo;
var
  i: Integer;
begin
  result := NIL;
  for i := 0 to high(arreglo) do
    if arreglo[i].nombre = nombre then
    begin
      result := arreglo[i];
      break;
    end;
end;

function buscarCampoPorNombre(const arreglo: TDAOfTCampo; const nombre: String;
  var campo: TCampo): boolean;
var
  i: Integer;
begin
  campo := NIL;
  for i := 0 to high(arreglo) do
    if arreglo[i].nombre = nombre then
    begin
      campo := arreglo[i];
      break;
    end;
  result := campo <> NIL;
end;

procedure liberarTDAOfTCampo(var arreglo: TDAOfTCampo);
var
  i: Integer;
begin
  for i := 0 to high(arreglo) do
    arreglo[i].Free;
  arreglo := NIL;
end;

function buscarCampoPrimitivoPorNombre(const arreglo: TDAOfTCampoPrimitivo;
  const nombre: String): TCampoPrimitivo;
var
  i: Integer;
begin
  result := NIL;
  for i := 0 to high(arreglo) do
    if arreglo[i].nombre = nombre then
    begin
      result := arreglo[i];
      break;
    end;
end;

function buscarCampoPrimitivoPorNombre(const arreglo: TDAOfTCampoPrimitivo;
  const nombre: String; var campo: TCampoPrimitivo): boolean;
var
  i: Integer;
begin
  campo := NIL;
  for i := 0 to high(arreglo) do
    if arreglo[i].nombre = nombre then
    begin
      campo := arreglo[i];
      break;
    end;
  result := campo <> NIL;
end;

procedure liberarTDAOfTCampoPrimitivo(var arreglo: TDAOfTCampoPrimitivo);
var
  i: Integer;
begin
  for i := 0 to high(arreglo) do
    arreglo[i].Free;
  arreglo := NIL;
end;

{ TParClaseCampos }

constructor TParClaseCampos.Create(clase: TClass; const campos: TDAOfTCampo);
var
  i, n: Integer;
begin
  inherited Create;
  self.clase := clase;
  self.campos := campos;

  SetLength(camposPrimitivos, Length(campos));
  n := 0;
  for i := 0 to high(campos) do
    if campos[i] is TCampoPrimitivo then
    begin
      camposPrimitivos[n] := TCampoPrimitivo(campos[i]);
      n := n + 1;
    end;
  if Length(camposPrimitivos) <> n then
    SetLength(camposPrimitivos, n);
end;

Destructor TParClaseCampos.Destroy;
begin
  liberarTDAOfTCampo(campos);
  // Este no se libera con elementos porque se liberaron con campos
  camposPrimitivos := NIL;
  inherited Destroy;
end;

initialization

listaCamposDeClases := TListaCamposDeClase.Create;

finalization

listaCamposDeClases.Free;
end.
