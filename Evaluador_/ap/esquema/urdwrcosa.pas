unit urdwrcosa;
(*
  Una cosa es un objeto que puede guardarse.
  Una TListaDeCosas, es una lista de cosas
*)

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}
interface
uses
  Sysutils, classes, xmatdefs, ufechas, uAuxiliares;

const
  VERSION_ArchiTexto= 1;
  formatoReales = ffFixed;

type
	TArchiTexto= class; // definido más adelante.

// Clase de todas las cosas que usamos en una sala.
	TCosa = class
    public

      //      camposRegistradosParaPersistencia: TListaVarDefs;

  		constructor Create;
	  	constructor Create_ReadFromText( f: TArchiTexto ); virtual;
		  function Create_Clone : TCosa; virtual;
  		procedure WriteToText(f: TArchiTexto ); virtual;
	  	class function DescClase : String; virtual;
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
	TCualquierClase= class of TObject;

  TDAOfTCosa= array of TCosa;

	TListaDeCosas = class (TCosa)
    protected
   		lst: TList;
      function getItem(i: Integer) : TCosa;
      procedure setItem(i: Integer; cosa: TCosa);
      function getCapacity: Integer;
      procedure setCapacity(newCapacity : Integer);
    public
      idCarpeta: string; // identificador para salvar en carpeta
	  	constructor Create( idCarpeta: string );
  		constructor Create_ReadFromText( f: TArchiTexto ); override;
		  procedure WriteToText( f: TArchiTexto ); override;
	  	function Add(cosa : TCosa) : Integer; virtual;

      //Si freeElementos = true llama a ClearFreeElementos, sino a Clear,
      //luego hace add de todas las cosas en listaDeCosas
      procedure ponerIgualA(listaDeCosas: TListaDeCosas; freeElementos: boolean);

  	  procedure Free; override;
	  	//Libera la lista sin destruir los objetos que contiene
  		procedure FreeSinElemenentos;
      function Count: Integer;
      procedure insert(indice: Integer; cosa : TCosa);
      function Remove(cosa : TCosa): Integer;
      procedure Delete(indice: Integer);
      procedure Pack;
      procedure Exchange(indice1, indice2: Integer);
      function IndexOf(cosa: TCosa): Integer;
      function replace(cosaARemplazar, cosaNueva: TCosa): Integer;
      procedure Clear;
      procedure ClearFreeElementos;
      procedure Sort(Compare: TListSortCompare);
      function getList: TList;
      function toArray: TDAOfTCosa;
      property Capacity : Integer read getCapacity write setCapacity;
      property items[i: Integer] : TCosa read getItem write setItem; default;
	end;

(* La función ProcesoLineaRes puede retornar laguno de los siguientes
valores. No se prevé un código de error pues la función lanza
excepciones con cualquier error que detecte. *)
	TResultadoProcesoLinea = (
		CTPLR_CONTINUAR,  // continuar procesando
		CTPLR_FIN_OBJETO,  // se llegó al fin del objeto (cerrar la lista)
		CTPLR_ABRIR_NUEVO_OBJETO ); // Se encontró un objeto abrir otra lista

	TTipoCampo= (
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
      CTC_Referencia );

	TProcFijarValorPorDefecto= procedure(const nombre: string; pVal: Pointer; tipo: TTipoCampo ; const klinea : Integer);

	TCampoParaLeer= class
    public
      nombre: string;
      tipo: TTipoCampo;
      pVal: pointer;
      proc_vpd: TProcFijarValorPorDefecto;
      referente: TCosa;
      flgError: integer; // 0 es showmessage, 1 no muestra nada
      constructor Create( Nombre: string; pVal: Pointer; Tipo: TTipoCampo; proc_vpd: TProcFijarValorPorDefecto ); overload;
      constructor Create( Nombre: string; pVal: Pointer; Tipo: TTipoCampo; proc_vpd: TProcFijarValorPorDefecto; flgError: integer ); overload;
      constructor Create( Nombre: string; pVal: Pointer; Tipo: TTipoCampo; proc_vpd: TProcFijarValorPorDefecto ; referente: TCosa); overload;
      procedure Ejecutar_vpd(const klinea: Integer);
	end;

  ExcepcionNoSePidioElCampo = class (Exception) end;
  ExcepcionResolverCampoValor = class(Exception) end;
  ExcepcionClaseNoRegistrada = class (Exception) end;

	TListCamposParaLeer = class( TList )
		public
			cosa: TCosa;
      lecturaRetrasada, leiFinDeObjeto: boolean;
			constructor Create( IdentificadorDeLaClaseDelObjeto: string);
			procedure Esperar_NReal( Nombre: string; var Variable: NReal; proc_vpd: TProcFijarValorPorDefecto );
			procedure Esperar_String( Nombre: string; var Variable: String; proc_vpd: TProcFijarValorPorDefecto );
      procedure Esperar_Arch( Nombre: string; var Variable: String; proc_vpd: TProcFijarValorPorDefecto );
			procedure Esperar_NInt( Nombre: string; var Variable: Integer; proc_vpd: TProcFijarValorPorDefecto );
      procedure Esperar_NCardinal( Nombre: string; var Variable: Cardinal; proc_vpd: TProcFijarValorPorDefecto );
			procedure Esperar_Boolean( Nombre: string; var Variable: boolean; proc_vpd: TProcFijarValorPorDefecto );
			procedure Esperar_DAOfNReal( Nombre: string; var Variable: TDAOfNReal; proc_vpd: TProcFijarValorPorDefecto );
			procedure Esperar_DAOfNInt( Nombre: string; var Variable: TDAOfNInt; proc_vpd: TProcFijarValorPorDefecto );
			procedure Esperar_StringList( Nombre: string; var Variable: TStringList; proc_vpd: TProcFijarValorPorDefecto );
			procedure Esperar_Fecha( Nombre: string; var Variable: TFecha; proc_vpd: TProcFijarValorPorDefecto ); overload;
			procedure Esperar_Fecha( Nombre: string; var Variable: TFecha;
            proc_vpd: TProcFijarValorPorDefecto; flgError: integer ); overload;
			procedure Esperar_Cosa( Nombre: string; var Variable:TCosa; proc_vpd: TProcFijarValorPorDefecto );
      procedure Esperar_Referencia( Nombre: string; var Variable:TCosa; proc_vpd: TProcFijarValorPorDefecto ; referente : TCosa );
			function ProcesarLinea( klinea:integer; linea: string; var extres: string ): TResultadoProcesoLinea;
			procedure Free;
		private
			IdentificadorDeLaClaseDelObjeto: string; // identificador de la clase de objeto
			lineaAbierta: boolean;
  		xNombre, xval: string; // valores bajo procesamiento
  		procedure ResolverCampoValor( const xNombre, xVal: string );
			procedure Ejecutar_vpds(klinea : Integer);
      procedure Ejecutar_vpd(klinea: Integer; nombreCampo: String);
{$IFDEF DBG}
      //Para debug, muestra los campos que la lista tiene por leer
      function NombresCamposPorLeer: TDAofString;
{$ENDIF}
	end;

	TListaDeObjetosPorLeer= class( TList )
    public
  		constructor Create;
	  	procedure Free;
		  function ListaActiva: TListCamposParaLeer;
  		procedure FreeListaPorLeer; // libera la última lista(cerró objeto)
	  	procedure InicioObjeto( NombreClase: string );
		  procedure FinalObjeto;
	end;


	TArchiTexto= class
    public
  		klinea: integer;
      Version: integer;
      nombreArchivo: string;
      aux_idCarpeta: string; // auxiliar para pasaje de parámetros de TListaDeCosas CreateReadFromText

      unArchivoPorCosa: boolean;
      padre: TArchiTexto;
      ramas: TList;

	  	constructor CreateForRead( nombreArchivo: string; abortarEnError: boolean );
		  constructor CreateForWrite( nombreArchivo: string; crearBackupSiExiste: boolean; maxNBackups: Integer );

  		procedure Free;
	  	function NextLine: string;
		  procedure writeline( s: string );

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


	  	procedure rd( nombre: string; var valor: NReal); overload;
		  procedure rd( nombre: string; var valor: String ); overload;
      procedure rdArch( nombre: string; var valor: String );
  		procedure rd( nombre: string; var valor: NInt ); overload;
      procedure rd( nombre: string; var valor: Cardinal); overload;
	  	procedure rd( nombre: string; var valor: Boolean ); overload;
		  procedure rd( nombre: string; var valor: TDAOfNReal ); overload;
  		procedure rd( nombre: string; var valor: TDAOfNInt ); overload;
  		procedure rd( nombre: string; var valor: TStringList ); overload;
	  	procedure rd( nombre: string; var valor: TFecha ); overload;

      // flgError= 0 lo mismo que sin flg. flgError= 1 no avisa del error
	  	procedure rd( nombre: string; var valor: TFecha; flgError: integer ); overload;
		  procedure rd( nombre: string; var valor: TCosa ); overload;
      procedure rdReferencia( nombre: string; var valor: TCosa ; referente : TCosa );
  		procedure IniciarLecturaRetrasada;
	  	procedure EjecutarLectura;

      function CreateRamaForWrite( Carpeta, NombreClase, NombreCosa: string ): TArchiTexto;
      function CreateRamaForRead( Carpeta, NombreClase, NombreCosa: string ): TArchiTexto;
    private
      f: textfile;
      f_abierto: boolean;

      listaObjetosPorLeer: TListaDeObjetosPorLeer; //TListCamposParaLeer;
      abortarEnError: boolean;
      oldFileMode: Byte;

      indentstr: string;
      function EOF: boolean;
      function quedanCosasDelObjetoActualPorLeer(claseObjeto : String): boolean;
      function ListaPorLeer: TListCamposParaLeer;
      procedure ReadCosaFromText( var cosa: TCosa; cosaStrId: string );
	end;

  TProcMsg = procedure(msg : String);

procedure ValorPorDefectoNulo(const nombre: string; pVal: Pointer; tipo: TTipoCampo ; const klinea: Integer);
procedure ValorPorDefecto_ERROR(const nombre: string; pVal: Pointer; tipo: TTipoCampo ; const klinea: Integer);

var
	registro_de_ClasesDeActor: TListaDeCosas;
  procMsgValorPorDefecto: TProcMsg;
  procMsgErrorLectura: TProcMsg;
  procMsgAdvertenciaLectura: TProcMsg;

{$IFDEF CNT_COSAS}
type
	TCntCosasClase = class
		private
			clase : TClass;
			cnt : Integer;
		public
			Constructor create(xclase : TClass);
	end;

	TCntCosas = class
		private
			CntCosasClases : TList {of TCntCosasClase};
		public
			cnt_Cosas : Integer;

			Constructor Create;
			function incCntCosasClase(clase : TClass) : Integer;
			function decCntCosasClase(clase : TClass) : Integer;
			function CntCosasClase(clase : TClass) : Integer;
			procedure Free;
	end;

var
	CantCosas : TCntCosas;
{$ENDIF}

function registrarClaseDeCosa( nombre: string; Clase: TCualquierClase ): integer;
function getClaseOf( nombre: string ): TCualquierClase;
// si la clase no está registrada retorna '<CLASE_NO_REGISTRADA>'
function getIdStrOf( clase: TClaseDeCosa ): string;


procedure LimpiarRegistroDeClasesDeCosas;

procedure AlInicio;
procedure AlFinal;

procedure FreeAndNil(var obj : TCosa);


Type
  ExceptionFileNotFound = class(Exception)
    public
      arch: String;
      Constructor Create(arch, comentarios: String);
  end;

implementation


var
  global_FlgError: integer;




function getDir_Tmp: string;
begin
  result:= '';
end;


  
//---------------------------------
// Métodos de ExceptionFileNotFound
//=================================

Constructor ExceptionFileNotFound.Create(arch, comentarios: String);
begin
  inherited Create('No se encuentra el archivo ' + arch + '. ' + comentarios);
  self.arch:= arch;
end;

//-----------------
// Métodos de TCosa
//=================

constructor TCosa.Create;
begin
  inherited Create;
end;


function TCosa.Create_Clone : TCosa;
var
	f: TArchiTexto;
	a: TCosa;
  dirTemporales:  string;
begin

  dirTemporales:= getDir_Tmp;

  f := TArchiTexto.CreateForWrite(dirTemporales + 'aux_clonar.tmp', false, 0);
  try
		f.wr( '_', self );
  finally
		f.Free;
  end;
  f := TArchiTexto.CreateForRead(dirTemporales + 'aux_clonar.tmp', true);
  try
  	f.rd( '_', a );
		result:= a;
	finally
		f.Free;
	end
end;

constructor TCosa.Create_ReadFromText( f: TArchiTexto );
begin
 	inherited Create;
end;

procedure TCosa.Free;
begin
	ucosaConNombre.eliminar_referencias_del(self);
	inherited Free;
end;

procedure TCosa.WriteToText( f: TArchiTexto );
begin
end;

class function TCosa.DescClase : String;
begin
	result := 'Cosa';
end;

type
	TFichaClaseActor = class
    public
  		strClaseId: string;
	  	clase: TCualquierClase;
		  constructor Create( strClaseID: string; clase: TCualquierClase );
  		procedure Free;
	end;

{$IFDEF CNT_COSAS}
Constructor TCntCosasClase.create(xclase : TClass);
begin
	clase := xclase;
	cnt := 1;
end;

Constructor TCntCosas.Create;
begin
	cnt_Cosas := 0;
	CntCosasClases := TList.Create;
end;

function TCntCosas.incCntCosasClase(clase : TClass) : Integer;
var
	i : Integer;
	resultado : Integer;
	aux : TCntCosasClase;
begin
	resultado := 0;
	for i := 0 to CntCosasClases.Count -1 do
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
	cnt_Cosas := cnt_Cosas +1;
	result := resultado;
end;

function TCntCosas.decCntCosasClase(clase : TClass) : Integer;
var
	i, ipos : Integer;
begin
	ipos := -1;
	for i := 0 to CntCosasClases.Count -1 do
		if TCntCosasClase(CntCosasClases[i]).clase = clase then
			begin
			TCntCosasClase(CntCosasClases[i]).cnt := TCntCosasClase(CntCosasClases[i]).cnt - 1;
			ipos := i;
			cnt_Cosas := cnt_Cosas -1;
			break;
			end;
	if ipos <> -1 then
		result := TCntCosasClase(CntCosasClases[ipos]).cnt
	else
		raise Exception.Create('No hay instancias de cosas de la clase ' + clase.ClassName)
end;

function TCntCosas.CntCosasClase(clase : TClass) : Integer;
var
	i, ipos : Integer;
begin
	ipos := -1;
	for i := 0 to CntCosasClases.Count -1 do
		if TCntCosasClase(CntCosasClases[i]).clase = clase then
			begin
			ipos := i;
			break;
			end;
	if ipos <> -1 then
		result := TCntCosasClase(CntCosasClases[i]).cnt
	else
		result := 0;
end;

procedure TCntCosas.Free;
var
	i : Integer;
begin
	for i := 0 to CntCosasClases.Count -1 do
		TCntCosasClase(CntCosasClases[i]).Free;
	CntCosasClases.Free;
	inherited Free;
end;
{$ENDIF}

// métodos de TFichaClaseActor
constructor TFichaClaseActor.Create( strClaseID: string; clase: TCualquierClase );
begin
	inherited Create;
	Self.strClaseId:= strClaseId;
	self.clase:=clase ;
end;

procedure TFichaClaseActor.Free;
begin
	inherited free;
end;

procedure TArchiTexto.ReadCosaFromText(var cosa: TCosa; cosaStrId: string );
var
	 clase: TClaseDeCosa;
begin
	clase:= TClaseDeCosa(getClaseOf(CosaStrId));
	if clase = nil then
		raise ExcepcionClaseNoRegistrada.Create('TArchiTexto.ReadCosaFromText: Error, '+CosaStrId+' No es una clase registrada. Procesando Línea: '+IntToStr( klinea ));
  cosa:= clase.Create_ReadFromText(Self);
end;

//----------------------------------
// Métodos de TListaDeCosasSinNombre
//==================================

Constructor TListaDeCosas.Create(idCarpeta: string );
begin
	inherited Create( );
  self.idCarpeta:= idCarpeta;
	lst:= TList.Create;
end;

constructor TListaDeCosas.Create_ReadFromText( f: TArchiTexto );
var
	n, k: integer;
  cosas: array of TCosa;
begin
  inherited Create_ReadFromText( f );
  self.idCarpeta:= f.aux_idCarpeta;
  f.IniciarLecturaRetrasada;
	f.rd( 'n', n );
  f.EjecutarLectura;
	lst := TList.Create;
  SetLength(cosas, n);
  f.IniciarLecturaRetrasada;
	for k:= 0 to n - 1 do
		f.rd(':', TCosa(cosas[k]));
  f.EjecutarLectura;

  //Esto es porque puede estar mal grabado el archivo y no se carguen las n cosas
  for k:= 0 to n -1 do
    if cosas[k] <> NIL then
      lst.Add(cosas[k]);
  SetLength(cosas, 0);
end;

procedure TListaDeCosas.WriteToText( f: TArchiTexto );
var
	 n, k: integer;
	 cosa: TCosa;
begin
	inherited WriteToText( f );
	n:= lst.count;
	f.wr('n', n );
	for k:= 0 to n-2 do
	begin
		cosa:= lst.items[k];
		f.wr( ':', cosa );
    f.writeline('');
	end;
  if n > 0 then
  begin
    cosa:= lst.items[n-1];
	  f.wr( ':', cosa );
  end;
end;

function TListaDeCosas.Add(cosa : TCosa) : Integer;
begin
 	result := self.lst.Add(cosa)
end;

procedure TListaDeCosas.ponerIgualA(listaDeCosas: TListaDeCosas; freeElementos: boolean);
var
  i: Integer;
begin
  if freeElementos then
    ClearFreeElementos
  else
    Clear;

  lst.Capacity:= listaDeCosas.lst.Count;
  for i:= 0 to listaDeCosas.lst.Count - 1 do
    lst.Add(listaDeCosas.lst[i])
end;

procedure TListaDeCosas.Free;
var
	k: integer;
begin
	for k:= 0 to lst.count-1 do
    if lst.Items[k] <> NIL then
  		TCosa( lst.items[k] ).Free;
	lst.Free;
	inherited Free;
end;

procedure TListaDeCosas.FreeSinElemenentos;
begin
	lst.Free;
	inherited Free;
end;

function TListaDeCosas.Count: Integer;
begin
  result:= lst.Count;
end;

procedure TListaDeCosas.insert(indice : Integer; cosa : TCosa);
begin
  lst.Insert(indice, cosa);
end;

function TListaDeCosas.Remove(cosa : TCosa): Integer;
begin
  result:= lst.Remove(cosa)
end;

procedure TListaDeCosas.Delete(indice: Integer);
begin
  lst.Delete(indice);
end;

procedure TListaDeCosas.Pack;
begin
  lst.Pack;
end;

procedure TListaDeCosas.Exchange(indice1, indice2: Integer);
begin
  lst.Exchange(indice1, indice2);
end;

function TListaDeCosas.IndexOf(cosa: TCosa): Integer;
begin
  result:= lst.IndexOf(cosa)
end;

function TListaDeCosas.replace(cosaARemplazar, cosaNueva: TCosa): Integer;
var
  i: Integer;
begin
  i:= 0;
  while (i < Count) and
        (lst.Items[i] <> cosaARemplazar) do
    i:= i + 1;
  if i < Count then
  begin
    lst.Items[i]:= cosaNueva;
    result:= i;
  end
  else
    result:= -1;
end;

procedure TListaDeCosas.Clear;
begin
  lst.Clear;
end;

procedure TListaDeCosas.ClearFreeElementos;
var
  i: Integer;
begin
  for i:= 0 to lst.Count - 1 do
    TCosa(items[i]).Free;
  lst.Clear;
end;

procedure TListaDeCosas.Sort(Compare: TListSortCompare);
begin
  lst.Sort(Compare);
end;

function TListaDeCosas.getList: TList;
begin
  result:= lst;
end;

function TListaDeCosas.toArray: TDAOfTCosa;
var
  i: Integer;
  res: TDAOfTCosa;
begin
  SetLength(res, lst.Count);
  for i:= 0 to lst.Count - 1 do
    res[i]:= lst[i];
  result:= res;
end;

function TListaDeCosas.getItem(i: Integer) : TCosa;
begin
  result:= lst.items[i]
end;

procedure TListaDeCosas.setItem(i: Integer; cosa: TCosa);
begin
  lst.items[i]:= cosa;
end;

function TListaDeCosas.getCapacity: Integer;
begin
  result:= lst.Capacity;
end;

procedure TListaDeCosas.setCapacity(newCapacity : Integer);
begin
  lst.Capacity:= newCapacity;
end;

/////////////////////////
//Procedimientos Globales
/////////////////////////

function registrarClaseDeCosa( nombre: string; Clase: TCualquierClase ): integer;
var
	ficha: TFichaClaseActor;
begin
	ficha:= TFichaClaseActor.Create( nombre, clase );
	result := registro_de_ClasesDeActor.lst.Add( ficha );
end;

function getClaseOf( nombre: string ): TCualquierClase;
var
	ipos : integer;
  res : TCualquierClase;
begin
	res := NIL;
	for ipos := 0 to registro_de_ClasesDeActor.lst.Count -1 do
  begin
		if TFichaClaseActor(registro_de_ClasesDeActor.lst[ipos]).strClaseId = nombre then
    begin
			res := TFichaClaseActor(registro_de_ClasesDeActor.lst.items[ipos]).clase;
			break;
    end;
  end;

  if res = NIL then
    raise Exception.Create('ucosa.getClaseOf: Clase de Actor desconocida ' + nombre)
  else
    result:= res;
end;

// si la clase no está registrada retorna '<CLASE_NO_REGISTRADA>'
function getIdStrOf( clase: TClaseDeCosa ): string;
var
	 ipos: integer;
	 buscando: boolean;
begin
	buscando:= true;
	for ipos:= 0 to registro_de_ClasesDeActor.lst.count-1 do
  if TFichaClaseActor(registro_de_ClasesDeActor.lst.items[ipos]).Clase = Clase then
	begin
	  buscando:= false;
		break;
  end;
	if buscando then
		result := '<CLASE_NO_REGISTRADA>'
	else
		result := TFichaClaseActor(registro_de_ClasesDeActor.lst.items[ipos]).strClaseId;
end;

procedure LimpiarRegistroDeClasesDeCosas;
var
	k: integer;
begin
	for k:= 0 to 	registro_de_ClasesDeActor.lst.Count-1 do
			TFichaClaseActor(registro_de_ClasesDeActor.lst.items[k]).Free;
	registro_de_ClasesDeActor.lst.Clear;
end;

procedure AlInicio;
begin
{$IFDEF CNT_COSAS}
	CantCosas := TCntCosas.Create;
{$ENDIF}
	registro_de_ClasesDeActor:= TListaDeCosas.Create('RegistroClasesDeActor');
//	registrarClaseDeCosa( TCosa.ClassName, TCosa );
	registrarClaseDeCosa( TListaDeCosas.ClassName, TListaDeCosas );
end;

procedure AlFinal;
begin
	LimpiarRegistroDeClasesDeCosas;
	registro_de_ClasesDeActor.Free;
{$IFDEF CNT_COSAS}
	CantCosas.Free;
{$ENDIF}
end;

procedure FreeAndNil(var obj : TCosa);
var
	aux : TCosa;
begin
	aux := obj;
	obj := NIL;
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
	for k:= 0 to count -1 do
		TListCamposParaLeer(items[k]).Free;
  self.Clear;
	inherited Free;
end;

function TListaDeObjetosPorLeer.ListaActiva: TListCamposParaLeer;
begin
	if count > 0 then
		result:= items[ count -1 ]
	else
	begin
		raise Exception.Create('Error, no hay un Objeto activo para lectura ');
		result:= nil;
	end;
end;

procedure TListaDeObjetosPorLeer.FreeListaPorLeer;
begin
	if count > 0 then
	begin
		TListCamposParaLeer(items[count -1]).Free;
		delete(count -1);
	end;
end;

procedure TListaDeObjetosPorLeer.InicioObjeto( NombreClase: string );
var
	a: TListCamposParaLeer;
begin
 	a:= TListCamposParaLeer.Create( NombreClase);
	add(a);
end;

procedure TListaDeObjetosPorLeer.FinalObjeto;
var
  xCosa: TCosa;
  nombreDelCampoObjeto: String;
  lpl: TListCamposParaLeer;
  i: Integer;
  res: boolean;
begin
// procesar hasta el final del objeto
  lpl:= ListaActiva;
  xCosa:= lpl.cosa;
	FreeListaPorLeer;
	lpl:= ListaActiva;
  nombreDelCampoObjeto:= lpl.xNombre;
  res:= false;
  for i:= 0 to lpl.Count -1 do
    if TCampoParaLeer(lpl[i]).nombre = nombreDelCampoObjeto then
    begin
      TCosa(TCampoParaLeer(lpl.items[i]).pVal^):= xCosa;
      TCampoParaLeer(lpl.items[i]).Free;
    	lpl.delete(i);
      res:= true;
      break;
    end;
  if not res then
    raise exception.Create('Aparentemente el objeto: '+lpl.IdentificadorDeLaClaseDelObjeto+' no tienen definido el campo: ' + nombreDelCampoObjeto)
end;

constructor TArchiTexto.CreateForRead( nombreArchivo: string; abortarEnError: boolean);
var
  s: string;
begin
  if FileExists(nombreArchivo) then
  begin
    inherited Create;
    f_abierto:= false;
    unArchivoPorCosa:= false;
    padre:= nil;
    ramas:= nil;


    Self.NombreArchivo:= nombreArchivo;
    oldFileMode:= FileMode;
    filemode:= fmOpenRead;

  	assignfile(f, NombreARchivo);
    {$I-}
    reset(f);
    {$I+}
    if ioresult = 0 then
      f_abierto:= true
    else
      raise Exception.Create('TArchiTexto.CreateForRead: No pude abrir archivo: '+NombreArchivo );

    self.abortarEnError:= abortarEnError;

    readln( f, s );
    s:= trim(s);
    klinea:= 0;

    if pos('VERSION=',s)=1 then
    begin
      delete(s, 1, 8 );
      version:= StrToInt( s );
      inc( klinea );
    end
    else
      version:= 0;

    listaObjetosPorLeer:= TListaDeObjetosPorLeer.Create();
    indentstr:= '';
    listaObjetosPorLeer.InicioObjeto('TODO');
  end
  else
//    raise ExceptionFileNotFound.Create('TArchiTexto.CreateForRead: no se encuentra el archivo ' + nombreArchivo);
    raise Exception.Create('TArchiTexto.CreateForRead: no se encuentra el archivo ' + nombreArchivo);
end;

constructor TArchiTexto.CreateForWrite( nombreArchivo: string; crearBackupSiExiste: boolean; maxNBackups: Integer );
begin
	inherited Create;
  unArchivoPorCosa:= false;
  padre:= nil;
  ramas:= nil;

  f_abierto:= false;
	Self.NombreArchivo:= NombreArchivo;

  if crearBackupSiExiste and FileExists(nombreArchivo) then
    uconstantesSimSEE.backupearArchivoAntesDeSalvar(nombreArchivo, maxNBackups);
	assignFile( f, NombreArchivo );
  oldFileMode:= FileMode;
	filemode:= fmOpenWrite;
   {$I-}
	Rewrite( f );
   {$I+}
   if ioresult = 0 then
     f_abierto:= true
   else
     raise Exception.Create('TArchiTexto.CreateForWrite('+nombreArchivo+')');

  writeln( f, 'VERSION='+IntToStr( VERSION_ArchiTexto ) );
	klinea:= 1;
	listaObjetosPorLeer:= TListaDeObjetosPorLeer.Create();
end;


function TArchiTexto.CreateRamaForWrite( Carpeta, NombreClase, NombreCosa: string ): TArchiTexto;
var
  s: string;
  i: integer;
  a: TArchiTexto;
begin
  if ramas = nil then
    ramas:= Tlist.Create;
  i:= pos('.sse', nombreArchivo );
  s:= copy( nombreArchivo, 1, i-1);
  if carpeta <> '' then
    s:= s + '/'+carpeta+'/';

  s:= s + '$'+NombreClase+'$'+NombreCosa+'.sse';

  a:= TArchiTexto.CreateForWrite( s, false, 0 );
  a.unArchivoPorCosa:= true;
  ramas.Add( a );
  result:= a;
end;


function TArchiTexto.CreateRamaForRead( carpeta, NombreClase, NombreCosa: string ): TArchiTexto;
var
  s: string;
  i: integer;
  a: TArchiTexto;
begin
  if ramas = nil then
    ramas:= Tlist.Create;
  i:= pos('.sse', nombreArchivo );
  s:= copy( nombreArchivo, 1, i-1);
  if carpeta <> '' then
    s:= s + '/'+carpeta+'/';

  s:= s + '$'+NombreClase+'$'+NombreCosa+'.sse';
  a:= TArchiTexto.CreateForRead( s, self.abortarEnError );
  a.unArchivoPorCosa:= true;
  ramas.Add( a );
  result:= a;
end;


procedure TArchiTexto.Free;
var
  i: integer;
//  a: TArchiTexto;
begin

  if listaObjetosPorLeer <> nil then
	begin
		listaObjetosPorLeer.Free;
		listaObjetosPorLeer:= nil;
	end;

  if ramas <> nil then
  begin
    if ramas.Count > 0 then
       raise Exception.Create('Toy tratando de FREE un ArchiTexto pero tiene RAMAS, revisar esto');
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
    i:= padre.ramas.IndexOf( self );
    padre.ramas.Delete( i );
  end;
  
  if ( f_abierto ) then
  begin
    f_abierto:= false;
    closefile( f );
  end;
  FileMode:= oldFileMode;
	inherited Free;
end;

function TArchiTexto.NextLine: string;
var
	r: string;
begin
  if not system.eof( f ) then
  begin
  	readln( f, r );
	  inc( klinea );
  	result:= trim(r);
  end
  else
    raise Exception.Create('Llegué al fin del archivo en forma inesperada.' );
end;

procedure TArchiTexto.writeline( s: string );
begin
	writeln( f, indentstr + s );
end;

function TArchiTexto.EOF: boolean;
begin
	result:= system.eof( f );
end;

function TArchiTexto.quedanCosasDelObjetoActualPorLeer(claseObjeto : String): boolean;
var
  s: String;
begin
  s:= NextLine;
  //Solo puede haber lineas vacias, sino devuelvo true
  while (s <> '<-' + claseObjeto + '>;') and (trim(s) = '') do
    s:= NextLine;
  if s = '<-' + claseObjeto + '>;' then
    result:= false
  else
    result:= true;
end;

function TArchiTexto.ListaPorLeer: TListCamposParaLeer;
begin
	result:= listaObjetosPorLeer.ListaActiva;
end;

procedure TArchiTexto.wr( nombre: string;  valor: NReal; precision : integer; decimales : integer);
begin
	writeline(  nombre+'= '+ FloatToStrF(valor, ffGeneral, precision, decimales )+';');
end;

procedure TArchiTexto.wr( nombre: string;  valor: NReal );
begin
	wr( nombre, valor, CF_PRECISION, CF_DECIMALES );
end;

procedure TArchiTexto.wr( nombre: string;  valor: String );
begin
	writeline( nombre+'= '+valor+';' );
end;

procedure TArchiTexto.wrArch( nombre: string; valor: String );
begin
  writeline( nombre+'= '+valor+';' );
end;

procedure TArchiTexto.wr( nombre: string;  valor: NInt);
begin
  writeline( nombre+'= '+IntToStr(valor)+';' );
end;

procedure TArchiTexto.wr( nombre: string; valor: Cardinal);
begin
  writeline( nombre+'= '+IntToStr(valor)+';' );
end;

procedure TArchiTexto.wr( nombre: string;  valor: TFecha );
begin
	 writeline( nombre+'= '+valor.AsStr+';' );
end;

procedure TArchiTexto.wr( nombre: string;  valor: TCosa );
var
	 CosaStrId: string;
	 clase: TClaseDeCosa;
begin
  if valor <> NIL then
  begin
  	clase:= TClaseDeCosa(valor.ClassType);
	  CosaStrId:= getIdStrOf( clase );
  	writeline(nombre+'= <+' + CosaStrId + '>' );
	  indentstr:= indentstr + '  ';
	  valor.WriteToText( Self );
	  delete( indentstr, length(indentstr) -1, 2);
	  writeline('<-'+CosaStrId+'>;' );
  end
  else
    writeline(nombre+'= NIL;');
end;

procedure TArchiTexto.wr( nombre: string;  valor: Boolean );
begin
  if valor then
	  writeline( nombre+'= 1;' )
	else
	  writeline( nombre+'= 0;' );
end;

procedure TArchiTexto.wr( nombre: string;  valor: TDAOfNReal; precision : integer; decimales : integer);
var
	 k: integer;
begin
	 write( f, indentstr+ nombre,'= [',length( valor ),'| ' );
	 if length( valor ) > 0 then
	 begin
			 write( f, FloatToStrF(valor[0], ffFixed, precision, decimales ) );
			 for k:= 1 to high( valor ) do
			 begin
					 if ((k mod 12) = 0 ) then writeline( '  ' );
					 write(f,', ', FloatToStrF(valor[k], ffFixed, precision, decimales ));
			 end;
	 end;
	 writeln( f, '];' );
end;

procedure TArchiTexto.wr( nombre: string;  valor: TDAOfNReal );
begin
	 wr(nombre, valor, 12, 3 );
end;

procedure TArchiTexto.wr( nombre: string;  valor: TDAOfNInt );
var
	k: integer;
begin
	write( f, indentstr+nombre,'= [',length( valor ),'| ' );
	if length( valor ) > 0 then
	begin
	  write( f, valor[0] );
		for k:= 1 to high( valor ) do
		begin
		  if ((k mod 12) = 0) then writeline( '  ' );
			  write(f,', ', valor[k] );
      end;
	end;
	writeln( f, '];' );
end;

procedure TArchiTexto.wr( nombre: string;  valor: TStringList );
var
	k: integer;
begin
	write( f, indentstr+nombre,'= [',valor.Count,'| ' );
	if valor.count > 0 then
	begin
	  write( f, valor[0] );
		for k:= 1 to valor.Count-1 do
		begin
		  if ((k mod 12) = 0) then writeline( '  ' );
			  write(f,', ', valor[k] );
      end;
	end;
	writeln( f, '];' );
end;

procedure TArchiTexto.wrReferencia( nombre: string; valor: TCosa );
begin
	if assigned( valor ) and ( valor is TCosaConNombre) then
      writeline( nombre + '= <' + valor.ClassName + '.' + TCosaConNombre(valor).nombre + '>;' )
(* rch0707121651 comento esto para que si está mal escriba referencia vacía y listo
    else
      raise Exception.Create('TArchiTexto.wrReferencia: intenta escribir una referencia a algo que no es TCosaConNombre');
  end
*)
	else
    writeline( nombre + '= <?.?>;' );
end;

procedure TArchiTexto.rd( nombre: string;  var valor: NReal);
begin
 	ListaPorLeer.Esperar_NReal(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd( nombre: string;  var valor: String );
begin
	ListaPorLeer.Esperar_String(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rdArch( nombre: string; var valor: String );
begin
	ListaPorLeer.Esperar_Arch(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd( nombre: string;  var valor: NInt );
begin
	ListaPorLeer.Esperar_NInt(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd( nombre: string; var valor: Cardinal);
begin
	ListaPorLeer.Esperar_NCardinal(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd( nombre: string;  var valor: TFecha );
begin
	ListaPorLeer.Esperar_Fecha(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

// flgError= 0 lo mismo que sin flg. flgError= 1 no avisa del error
procedure TArchiTexto.rd( nombre: string; var valor: TFecha; flgError: integer );
begin
	ListaPorLeer.Esperar_Fecha(nombre, valor, nil, flgError );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;


procedure TArchiTexto.rd( nombre: string;  var valor: Boolean );
begin
	ListaPorLeer.Esperar_Boolean(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd( nombre: string;  var valor: TDAOfNReal );
begin
	ListaPorLeer.Esperar_DAOfNReal(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd( nombre: string;  var valor: TCosa );
begin
	ListaPorLeer.Esperar_Cosa(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd( nombre: string;  var valor: TDAOfNInt );
begin
	ListaPorLeer.Esperar_DAOfNInt(nombre, valor, nil );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rd( nombre: string;  var valor: TStringList );
begin
  ListaPorLeer.Esperar_StringList(nombre, valor, nil);
  if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.rdReferencia( nombre: string; var valor: TCosa ; referente : TCosa);
begin
	ListaPorLeer.Esperar_Referencia(nombre, valor, nil, referente );
	if not ListaPorLeer.lecturaRetrasada then
    EjecutarLectura;
end;

procedure TArchiTexto.IniciarLecturaRetrasada;
begin
  if ListaPorLeer <> NIL then
  	ListaPorLeer.lecturaRetrasada:= true;
end;

procedure TArchiTexto.EjecutarLectura;
var
	s, NombreClaseSiguienteObjeto: string;
	resObjetoHijo, resObjetoPadre: TResultadoProcesoLinea;
	lpl: TListCamposParaLeer;
{$IFDEF DBG}
  dbgAux: TDAofString;
{$ENDIF}
  indiceDeLinea: Integer;
  posIgual: Integer;
begin
	try
    lpl:= ListaPorLeer;
    resObjetoPadre:= CTPLR_CONTINUAR;
		while (resObjetoPadre <> CTPLR_FIN_OBJETO) and (lpl <> nil) and
          (lpl.Count > 0) and not EOF do
		begin
{$IFDEF DBG}
      dbgAux:= lpl.nombresCamposPorLeer;
{$ENDIF}
      indiceDeLinea:= klinea;
		  s:= nextline;
      //system.writeln( indiceDeLinea:6, ': ', s );
      try
     	  resObjetoPadre:= lpl.ProcesarLinea(klinea, s, NombreClaseSiguienteObjeto);
      except
        on E: ExcepcionNoSePidioElCampo do
        begin
          lpl.Ejecutar_vpds(klinea);
          if quedanCosasDelObjetoActualPorLeer(lpl.IdentificadorDeLaClaseDelObjeto) then
          begin
            resObjetoPadre:= CTPLR_CONTINUAR;
            klinea:= indiceDeLinea;
          end
          else
            resObjetoPadre:= CTPLR_FIN_OBJETO;
        end;
        on E: ExcepcionResolverCampoValor do
        begin
          posIgual:= pos('=', s);
          lpl.Ejecutar_vpd(klinea, copy(s, 0, posIgual-1));
          if quedanCosasDelObjetoActualPorLeer(lpl.IdentificadorDeLaClaseDelObjeto) then
          begin
            resObjetoPadre:= CTPLR_CONTINUAR;
            klinea:= indiceDeLinea +1;//El +1 debería ser el número de lineas que leyo y no le sirvieron
          end
          else
            resObjetoPadre:= CTPLR_FIN_OBJETO;
        end
      end;
			if resObjetoPadre = CTPLR_ABRIR_NUEVO_OBJETO then
			begin
				listaObjetosPorLeer.InicioObjeto(NombreClaseSiguienteObjeto);
        lpl:= ListaPorLeer;
        try
          ReadCosaFromText(lpl.cosa, NombreClaseSiguienteObjeto);
        except
          on E: Exception do
          begin
            lpl.cosa:= NIL;
            if Assigned(procMsgErrorLectura) then
              procMsgErrorLectura(E.Message + '. Leyendo el actor en la linea ' + IntToStr(klinea));
            if abortarEnError then
              raise;

            if not EOF then
              repeat
                s:= NextLine;
              until (s = '<-' + NombreClaseSiguienteObjeto + '>;' ) or EOF;
            lpl.leiFinDeObjeto:= true;
          end
        end;
        if not lpl.leiFinDeObjeto then
    			repeat
           	s:= nextline;
	  	  		resObjetoHijo:= lpl.ProcesarLinea(klinea, s, NombreClaseSiguienteObjeto);
          until resObjetoHijo = CTPLR_FIN_OBJETO;

        listaObjetosPorLeer.FinalObjeto;
        lpl:= ListaPorLeer;
			end;
		end;
    if resObjetoPadre = CTPLR_FIN_OBJETO then
      ListaPorLeer.leiFinDeObjeto:= true;
	except
		on E: Exception do
      if pos('kLinea:', E.Message) = 0 then
  			raise Exception.Create('kLinea:('+intToStr(klinea)+') '+E.Message )
      else
        raise;
	end; // try
	//ListaPorLeer.lecturaRetrasada:= false;
end;

function TipoToStr( tipo: TTipoCampo ): string;
begin
	case Tipo of
		 CTC_NReal:  result:= 'NReal';
		 CTC_String:  result:= 'String';
     CTC_Arch:    result:= 'Archivo';
		 CTC_NInt:  result:= 'Entero';
     CTC_NCardinal: result:= 'Entero Positivo';
		 CTC_Boolean:   result:= 'Booleano';
		 CTC_DAOfNReal: result:= 'Array dinámico de Reales';
		 CTC_DAOfNInt: result:= 'Array dinámico de Enteros';
		 CTC_Fecha: result:= 'Fecha';
		 CTC_Cosa: result:= 'Cosa';
	end; // case
end;

procedure ValorPorDefectoNulo(const nombre: string; pVal: Pointer; tipo: TTipoCampo ; const klinea: Integer);
var
  Msg: String;
begin
	case Tipo of
		CTC_NReal:  NReal(pVal^):= 0;
		CTC_String: string(pVal^):= '';
    CTC_Arch: string(pVal^):= '';
		CTC_NInt: NEntero(pVal^):= 0;
    CTC_NCardinal: Cardinal(pVal^):= 0;
		CTC_Boolean: boolean( pVal^):= false;
		CTC_DAOfNReal: setlength(TDAOfNReal(pVal^), 0 );
		CTC_DAOfNInt: setlength(TDAOfNInt(pVal^), 0 );
		CTC_Fecha: TFecha(pVal^):= TFecha.Create_dt( 0 );
		CTC_Cosa: pointer(pVal^):= nil;
    CTC_Referencia: Pointer(pVal^):= NIL;
	end; // case


  if global_flgError= 0 then
  if assigned(procMsgValorPorDefecto) then
  begin
    msg:= 'Asignando valor por defecto al campo ' + nombre;
    if klinea <> -1 then
      msg:= msg + ' leyendo el final del objeto en la linea ' + IntToStr(klinea)
    else
      msg:= msg + ' en el final del archivo.';
    procMsgValorPorDefecto(msg);
  end;
end;

procedure ValorPorDefecto_ERROR(const nombre: string; pVal: Pointer; tipo: TTipoCampo ; const klinea: Integer);
var
  msg: String;
begin
  msg:= 'No se encontró una definición para el campo: ' + nombre + ' tipo: ' + TipoToStr(tipo);
  if klinea <> -1 then
    msg:= msg + ' leyendo el final del objeto en la linea ' + IntToStr(klinea)
  else
    msg:= msg + ' en el final del archivo.';

//	raise Exception.Create(msg);

{$IFDEF FPC}
  writeln( msg );
  write('... presine ENTER para continuar.' );
  system.readln;
{$ELSE}
  showmessage( msg );
{$ENDIF}
end;

constructor TCampoParaLeer.Create( Nombre: string; pVal: Pointer; Tipo: TTIpoCampo; proc_vpd: TProcFijarValorPorDefecto );
begin
  Create(Nombre, pVal, Tipo, proc_vpd, NIL);
end;

constructor TCampoParaLeer.Create( Nombre: string; pVal: Pointer; Tipo: TTIpoCampo; proc_vpd: TProcFijarValorPorDefecto; flgError: integer );
begin
  Create(Nombre, pVal, Tipo, proc_vpd, NIL);
  self.flgError:= flgError;
end;


constructor TCampoParaLeer.Create( Nombre: string; pVal: Pointer; Tipo: TTipoCampo; proc_vpd: TProcFijarValorPorDefecto ; referente: TCosa);
begin
	inherited Create;
  self.flgError:= 0;
	self.nombre:= nombre;
	self.tipo:= tipo;
	self.pVal:= pVal;
  self.referente:= referente;

{$IFDEF PORDEFECTO_NULO}
  if not assigned(proc_vpd) then
    self.proc_vpd:= ValorPorDefectoNulo
  else
    self.proc_vpd:= proc_vpd;
{$ELSE}
	self.proc_vpd:= proc_vpd;
{$ENDIF}
end;

procedure TCampoParaLeer.Ejecutar_vpd(const klinea: Integer);
begin
  if assigned(proc_vpd) then
  begin
    global_flgError:= Self.flgError;
    proc_vpd(nombre, pVal, tipo, klinea);
  end
  else
    if flgError= 0 then
  		ValorPorDefecto_ERROR(nombre, pVal, tipo, klinea);
end;

constructor TListCamposParaLeer.Create( IdentificadorDeLaClaseDelObjeto: string);
begin
	inherited Create;
	self.IdentificadorDeLaClaseDelObjeto:= IdentificadorDeLaClaseDelObjeto;
	lineaAbierta:= false;
	xNombre:= '';
	xval:= '';
  lecturaRetrasada:= false;
  leiFinDeObjeto:= false;
end;

procedure TListCamposParaLeer.Esperar_NReal( Nombre: string; var Variable: NReal; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_NReal, proc_vpd );
	add( a );
end;

procedure TListCamposParaLeer.Esperar_String( Nombre: string; var Variable: String; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_String, proc_vpd );
	add( a );
end;

procedure TListCamposParaLeer.Esperar_Arch( Nombre: string; var Variable: String; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_Arch, proc_vpd );
	add( a );
end;
procedure TListCamposParaLeer.Esperar_NInt( Nombre: string; var Variable: Integer; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_NInt, proc_vpd );
	add( a );
end;

procedure TListCamposParaLeer.Esperar_NCardinal( Nombre: string; var Variable: Cardinal; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_NCardinal, proc_vpd );
	add( a );
end;

procedure TListCamposParaLeer.Esperar_Boolean( Nombre: string; var Variable: boolean; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_Boolean, proc_vpd );
	add( a );
end;

procedure TListCamposParaLeer.Esperar_DAOfNReal( Nombre: string; var Variable: TDAOfNReal; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_DAOfNReal, proc_vpd );
	add( a );
end;

procedure TListCamposParaLeer.Esperar_DAOfNInt( Nombre: string; var Variable: TDAOfNInt; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_DAOfNInt, proc_vpd );
	add( a );
end;

procedure TListCamposParaLeer.Esperar_StringList( Nombre: string; var Variable: TStringList; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_StringList, proc_vpd );
	add( a );
end;


procedure TListCamposParaLeer.Esperar_Cosa( Nombre: string; var Variable: TCosa; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_Cosa, proc_vpd );
	add( a );
end;

procedure TListCamposParaLeer.Esperar_Referencia( Nombre: string; var Variable:TCosa; proc_vpd: TProcFijarValorPorDefecto ; referente : TCosa );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_Referencia, proc_vpd, referente);
	add( a );
end;

procedure TListCamposParaLeer.Esperar_Fecha( Nombre: string; var Variable: TFecha; proc_vpd: TProcFijarValorPorDefecto );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_Fecha, proc_vpd );
	add( a );
end;

procedure TListCamposParaLeer.Esperar_Fecha( Nombre: string; var Variable: TFecha;
            proc_vpd: TProcFijarValorPorDefecto; flgError: integer );
var
	a: TCampoParaLeer;
begin
	a:= TCampoParaLeer.Create( Nombre, @Variable, CTC_Fecha, proc_vpd, flgError );
	add( a );
end;


(*
		CTPLR_CONTINUAR,
		CTPLR_FIN_OBJETO,
		CTPLR_ABRIR_NUEVO_OBJETO );
*)
function TListCamposParaLeer.ProcesarLinea( klinea:integer; linea: string; var extres: string ): TResultadoProcesoLinea;
var
	NombreClase: string;
begin
	result:= CTPLR_CONTINUAR;

	if pos('<-', linea ) = 1 then
	begin
		if IdentificadorDeLaClaseDelObjeto <> '' then
			if pos( IdentificadorDeLaClaseDelObjeto , linea ) <> 3 then
				raise Exception.Create('Error, cierre de objeto : '+linea+' Se esperaba: '+
									'<-'+IdentificadorDeLaClaseDelObjeto+'>, en línea: ' + IntToStr(klinea));

		Ejecutar_vpds(klinea); // procesamos los no resueltos
		result:= CTPLR_FIN_OBJETO; // cierro esta lista FIN DEL OBJETO
	end
	else
	begin
		if LineaAbierta then
		begin
			xval:= xval + ' ' + linea;
			if xval[length(xval)]= ';' then
			begin
			  xval := copy(xval, 0, Length(xval) - 1);//Saco el ;
				ResolverCampoValor(xNombre, xVal);
				LineaAbierta:= false;
      end;
		end
		else
		begin
			if getnextpal(xnombre, linea, '=') then
			begin
				xval:= trim(linea);
				if length(xval) > 0 then
				begin
					if pos('<+', xval) = 1 then
					begin
						system.delete(xval, 1, 2);
						if xval[length(xval)] <> '>' then
							raise Exception.Create('Error, falta el > de cierre en fin de clase : '+xval );

						NombreClase:= copy( xval, 1, length(xval)-1 );
      			extres:= NombreClase;
						result:=CTPLR_ABRIR_NUEVO_OBJETO;
					end
					else
					if xval[length(xval)] = ';' then
					begin
						xval := copy(xval, 0, Length(xval) -1);//Saco el ;
            try
              ResolverCampoValor( xNombre, xVal )
            except
              on E : ExcepcionNoSePidioElCampo do
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
						LineaAbierta:= true;
				end
				else
					LineaAbierta:= true;
			end
			else
				Exception.Create( 'Error, no encontré el (=) en la línea: ['+IntToStr(klinea)+'] :'+linea );
		end;
	end;
end;

procedure TListCamposParaLeer.Free;
{var
   k: integer;}
begin
  Ejecutar_vpds(-1);
{  for k:= 0 to count-1 do
    TCampoParaLeer( items[k] ).Free;}
	inherited Free;
end;

procedure TListCamposParaLeer.ResolverCampoValor( const xNombre, xVal: string );
var
	buscando: boolean;
	k: integer;
  clase, nombreRef: String;
begin
	buscando:= true;
  k:= 0;
  while buscando and ( k < count ) do
		if TCampoParaLeer( items[k] ).nombre= xNombre then
		  buscando:= false
    else
      inc( k );

  if buscando then
	  raise ExcepcionNoSePidioElCampo.Create(
          'Se leyó el campo: '+xnombre+' pero no se esperaba en el objeto: '+IdentificadorDeLaClaseDelObjeto+'. Pruebe guardar y cargar nuevamente la sala. Intentaré solucionar el problema.' )
  else
	begin
		try
			with  TCampoParaLeer(items[k]) do
			case Tipo of
				 CTC_NReal:       NReal(pVal^):= StrToFloat( xval );
				 CTC_String:      string(pVal^):= xval;
         CTC_Arch:        begin
                            string(pVal^):= xval;
                          {$IFDEF LINUX}
                            toLinuxDir(string(pVal^));
                          {$ENDIF}
                          end;
				 CTC_NInt:        NEntero(pVal^):= StrToInt( xval );
         CTC_NCardinal:   Cardinal(pVal^):= StrToInt(xval);
				 CTC_Boolean:     boolean( pVal^):= (xval <> '' ) and ( xval[1]= '1');
				 CTC_DAOfNReal:   parseDAOfNreal( TDAOfNReal(pVal^), xval );
				 CTC_DAOfNInt:    parseDAOfNInt( TDAOfNInt(pVal^), xval );
         CTC_StringList:  parseStringList( TStringList( pVal^), xval );
				 CTC_Fecha:       TFecha( pVal^):= TFecha.Create_str( xval );
         CTC_Referencia:  begin
                          parsearReferencia(xval, clase, nombreRef);
                         	if (clase <> '?') then
                        	  uCosaConNombre.registrar_referencia(referente, clase, nombreRef, pVal^)
                          else
                        		TCosa(pVal^):= NIL;
                          end;
         CTC_Cosa:        begin
                            TCosa(pval^):= NIL;
                          end;
			end; // case
		except
			on E: Exception do
			begin
				 raise ExcepcionResolverCampoValor.Create('ResolverCampoValor('+xnombre+','+xval+') '+E.Message );
			end;
		end; // try
    // eliminamos la ficha de lectura pendiente pues fué resuelta
		TCampoParaLeer(items[k]).Free;
		delete(k);
	end;
end;

// recorremos las fichas que hallan quedado sin resolver y les asignamos los
// valores por defecto (o tiramos excepciones si no se definió una función
// alternativa.
procedure TListCamposParaLeer.Ejecutar_vpds(klinea : Integer);
var
	k: integer;
begin
	for k:= 0 to count-1 do
  begin
		TCampoParaLeer(items[k]).Ejecutar_vpd(klinea);
    TCampoParaLeer(items[k]).Free;
  end;
  self.Clear;
end;

procedure TListCamposParaLeer.Ejecutar_vpd(klinea: Integer; nombreCampo: String);
var
	k: integer;
begin
	for k:= 0 to count-1 do
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
  i: Integer;
  res: TDAofString;
begin
  SetLength(res, self.Count);
  for i:= 0 to Self.Count -1 do
    res[i]:= TCampoParaLeer(items[i]).nombre;
  result:= res;
end;
{$ENDIF}

function TFecha_Create_ReadFromText(NombreCampo: string; f: TArchiTexto ): TFecha;
var
	s: string;
	fecha: TFecha;
	dt: TDateTime;
begin
	f.rd( NombreCampo, s );
	dt:= StrToDateTime( s );
	fecha:= TFecha.Create_dt( dt );
	result:= fecha;
end;

procedure TFecha_WriteToText( fecha: TFecha; NombreCampo: string; f: TArchiTexto );
begin
	f.wr( NombreCampo,  fecha.AsStr );
end;

end.
