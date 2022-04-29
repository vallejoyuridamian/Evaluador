unit uVarDefs;
(*+doc unit uVarDefs
Esta unidad da soporte a la publicación de variables.

-doc*)
interface

uses
	Classes, uFechas, SysUtils, xMatDefs,
//  uConstantesSimSEE,
  uAuxiliares;

const
	vectorSeparator = chr(9);
  strSinUnidad = '';
  formatoReales = ffFixed;

type
{	TTypeOfVar= ( TVal_Error, TVal_S, TVal_NR, TVal_NI, TVal_VR,
										TVal_VI, TVal_B, TVal_VB, TVal_Fecha ); }

	PString = ^String;
	PBoolean = ^Boolean;
	PFecha = ^TFecha;
	PTDAOfNreal = ^TDAOfNreal;
	PTDAOfNInt = ^TDAofNInt;
	PTDAOfBoolean = ^TDAOfBoolean;
  PTList = ^TList;
  PTStringList = ^TStringList;
	TProcCalcVar = procedure ( pobj: TObject; var x );

	TVarDef= class	//Abstracta, no instanciar directamente
		protected
			pVariable : Pointer;
			Ppd : Pointer;
			offsetVector : Integer;
			offsetVar : Integer;
			cosa : Pointer;
      indice: String;
		public
			nombreVar, unidades: string;

//si la variable no es un arreglo rtornan el campo indicado
//si la variable es un arreglo con n elementos retornan el campo indicado
//repetido n veces, separado por vectorSeparator y sin separador tras el
//ultimo elemento
//i.e.
//   1                          2                                                  n
//nombre + vectorSeparator + nombre + vectorSeparator + ... + vectorSeparator + nombre
			function getNombreCosa: String; virtual;
      function getUnidades: String; virtual;
			function getNombreVar: String; virtual;
      function getIndicesVars: String; virtual;

      procedure getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String); virtual;

      //El indice se inicializa en 0 por defecto, si se quiere asignarle un índice
      //Debe hacerse explicitamente
      procedure setIndice(newIndice: Integer);

      function esV: boolean;

			function asS: String; overload; virtual; abstract;
			function asNR: NReal; overload; virtual; abstract;
			function asNI: integer; overload; virtual; abstract;
			function asVR: TDAOfNReal; overload; virtual; abstract;
			function asVI: TDAOFNInt; overload; virtual; abstract;
			function asB: boolean; overload; virtual; abstract;
			function asVB: TDAOfBoolean; overload; virtual; abstract;
			function asFecha: TFecha; overload; virtual; abstract;

      //las strings provistas a u obtenidas por estos métodos deben tener el formato
      //de lectura/grabación de archivos
      procedure setValorFromStringPersistida(const valor: String); virtual; abstract;
      function getValorAsStringPersistible: String; virtual; abstract;

      //Si la VarDef se creo con CreatePpd o CreatePpdIndice se debe llamar este
      //método antes de poder acceder al valor de la variable. Se usa para
      //calcular pVariable con el offset que ocupe en la ficha o vector
			procedure Prepararse(); virtual;

      //Usado para crear una var def cuando la variable esta en cosa (i.e. campo
      //de una clase). Se guarda pVariable y lo usa para acceder al valor
			constructor Create(cosa: Pointer{^TCosa}; const xnombreVar, unidades: string; pVariable : Pointer);
      //Usado para crear una var def cuando la variable esta en un puntero de la cosa
      //(i.e: campo de una ficha dinámicas, o elemento de un arreglo) guarda
      //pVariable - Ppd^ en offsetVar y se guarda Ppd.
      //Cuando se llama Prepararse() pvariable se carga con Ppd^ + offsetVar
			constructor CreatePpd(cosa: Pointer{^TCosa}; const xnombreVar, unidades: string; pVariable: Pointer; Ppd: Pointer);
      //Usado para crear una var def cuando la variable esta en un vector en un
      //puntero de la cosa (i.e: vector en las fichas dinámicas) guarda
      //pVariable - pVector^ en offsetVar, pvector - Ppd en offsetVector y se
      //guarda Ppd. Luego cuando se llama Prepararse() pvariable se carga
      //con (Ppd^ + offsetVector)^ + offsetVar
			constructor CreatePpdIndice(cosa: Pointer{^TCosa}; const xnombreVar, unidades: string; pVariable: Pointer; pVector: Pointer; Ppd: Pointer); virtual;

      property valStrPersistible: String read getValorAsStringPersistible write setValorFromStringPersistida;
	end;

	TVarDef_V = class(TVarDef)	//Abstracta, no instanciar directamente
    private
      usarNomenclaturaPorPoste: boolean;
    public
			function asS(indice : Integer): String; overload; virtual; abstract;
			function asNR(indice : Integer): NReal; overload; virtual; abstract;
			function asNI(indice : Integer): integer; overload; virtual; abstract;
			function asVR(indice : Integer): TDAOfNReal; overload; virtual; abstract;
			function asVI(indice : Integer): TDAOFNInt; overload; virtual; abstract;
			function asB(indice : Integer): boolean; overload; virtual; abstract;
			function asVB(indice : Integer): TDAOfBoolean; overload; virtual; abstract;
			function asFecha(indice : Integer): TFecha; overload; virtual; abstract;
			function highVarDef : Integer; virtual; abstract;
	end;

	TClaseVarDef = class of TVarDef;
	TDAOfVarDef = array of TVarDef;

	//En los constructores:
	//			- nombre especifica el nombre de la variable a definir
	//			- pVariable es el puntero a la dirección de memoria donde esta
	//				la variable definida
	//			- Ppd es el puntero a los parametros dinámicos

	//Los procedimientos asX devuelven el valor de la variable formateado como del
	//tipo X, Pej si variable apunta a 5 => TVarDef_NI.asS = '5'
	//Las convesiones de numero a booleano y viceversa son 0 <=> false y
	//1 en otro caso
	//Las conversiones de Real a entero son redondeadas
	//Si la conversion no esta definida se eleva una excepcion con el mensaje de
	//error

	TVarDef_NR = class (TVarDef)
		private
      precision, decimales: Integer;
		public
			constructor Create(cosa : Pointer{^TCosa}; const xnombre, xunidades: string; precision, decimales: Integer; variable : PNreal); reintroduce;
      constructor CreatePpdIndice(cosa: Pointer{^TCosa}; const xnombreVar, unidades: string; precision, decimales: Integer; pVariable: Pointer; pVector: Pointer; Ppd: Pointer); reintroduce;

			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;
      procedure setValor(valor: NReal);

      property valor: NReal read asNR write setValor;
	end;

	TVarDef_NI = class (TVarDef)
		private
		public
			constructor Create(cosa : Pointer{^TCosa} ; const xnombre, xunidades: string; variable : PNEntero); reintroduce;

			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;
      procedure setValor(valor: Integer);

      property valor: Integer read asNI write setValor;
	end;

	TVarDef_S = class (TVarDef)
		private
		public
			constructor Create(cosa : Pointer{^TCosa} ; const xnombre, xunidades: string ; variable : PString); reintroduce;

			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;
      property valor: String read asS write setValorFromStringPersistida;
	end;

	TVarDef_B = class (TVarDef)
		private
		public
			constructor Create(cosa : Pointer{^TCosa} ; const xnombre, xunidades: string ; variable : PBoolean); reintroduce;

			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;
      procedure setValor(valor: boolean);

      property valor: boolean read asB write setValor;
	end;

	TVarDef_Fecha = class (TVarDef)
		private
		public
			constructor Create(cosa : Pointer{^TCosa} ; const xnombre: string ; variable : PFecha); reintroduce;

			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;
      procedure setValor(valor: TFecha);

      property valor: TFecha read asFecha write setValor;
	end;

	TVarDef_Referencia = class (TVarDef)
		private
		public
			constructor Create(cosa : Pointer{^TCosa} ; const xnombre: string ; cosaConNombre: Pointer{^TCosaConNombre}); reintroduce;

			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;
      //Los TObject son TCosaConNombre, pero TCosaConNombre aparece en el uses
      //de la implementation
      procedure setValor(valor: TObject);
      function getValor: TObject;

      property valor: TObject read getValor write setValor;
	end;

	TVarDef_VNR = class (TVarDef_V)
		private
      precision, decimales: Integer;
		public
			constructor Create(cosa : Pointer{^TCosa}; const xnombre, xunidades: string;
                         precision, decimales: Integer; variable: PTDAOfNreal;
                         usarNomenclaturaPorPoste: boolean); reintroduce;

			function getNombreCosa : String; override;
      function getUnidades: String; override;
			function getNombreVar : String; override;
      function getIndicesVars: String; override;

      procedure getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String); override;

			function asS: String; overload; override;
			function asNR: NReal; overload; override;
			function asNI: integer; overload; override;
			function asVR: TDAOfNReal; overload; override;
			function asVI: TDAOFNInt; overload; override;
			function asB: boolean; overload; override;
			function asVB: TDAOfBoolean; overload; override;
			function asFecha: TFecha; overload; override;

			function asS(indice : Integer): String; overload; override;
			function asNR(indice : Integer): NReal; overload; override;
			function asNI(indice : Integer): integer; overload; override;
			function asVR(indice : Integer): TDAOfNReal; overload; override;
			function asVI(indice : Integer): TDAOFNInt; overload; override;
			function asB(indice : Integer): boolean; overload; override;
			function asVB(indice : Integer): TDAOfBoolean; overload; override;
			function asFecha(indice : Integer): TFecha; overload; override;
			function highVarDef : Integer; override;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;
      procedure setValor(valor: TDAofNReal);

      property valor: TDAofNReal read asVR write setValor;
	end;

	TVarDef_VNI = class (TVarDef_V)
		private
		public
			constructor Create(cosa: Pointer{^TCosa}; const xnombre, xunidades: string;
                         variable: PTDAofNInt;
                         usarNomenclaturaPorPoste: boolean); reintroduce;

			function getNombreCosa: String; override;
      function getUnidades: String; override;
			function getNombreVar: String; override;
      function getIndicesVars: String; override;

      procedure getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String); override;

			function asS: String; overload; override;
			function asNR: NReal; overload; override;
			function asNI: integer; overload; override;
			function asVR: TDAOfNReal; overload; override;
			function asVI: TDAOFNInt; overload; override;
			function asB: boolean; overload; override;
			function asVB: TDAOfBoolean; overload; override;
			function asFecha: TFecha; overload; override;

			function asS(indice : Integer): String; overload; override;
			function asNR(indice : Integer): NReal; overload; override;
			function asNI(indice : Integer): integer; overload; override;
			function asVR(indice : Integer): TDAOfNReal; overload; override;
			function asVI(indice : Integer): TDAOFNInt; overload; override;
			function asB(indice : Integer): boolean; overload; override;
			function asVB(indice : Integer): TDAOfBoolean; overload; override;
			function asFecha(indice : Integer): TFecha; overload; override;
			function highVarDef : Integer; override;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;
      procedure setValor(valor: TDAofNInt);

      property valor: TDAofNInt read asVI write setValor;
	end;

	TVarDef_VB = class (TVarDef_V)
		private
		public
			constructor Create(cosa : Pointer{^TCosa}; const xnombre, xunidades: string;
                         variable : PTDAOfBoolean;
                         usarNomenclaturaPorPoste: boolean); reintroduce;

			function getNombreCosa : String; override;
      function getUnidades: String; override;
			function getNombreVar : String; override;
      function getIndicesVars: String; override;

      procedure getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String); override;

			function asS: String; overload; override;
			function asNR: NReal; overload; override;
			function asNI: integer; overload; override;
			function asVR: TDAOfNReal; overload; override;
			function asVI: TDAOFNInt; overload; override;
			function asB: boolean; overload; override;
			function asVB: TDAOfBoolean; overload; override;
			function asFecha: TFecha; overload; override;

			function asS(indice : Integer): String; overload; override;
			function asNR(indice : Integer): NReal; overload; override;
			function asNI(indice : Integer): integer; overload; override;
			function asVR(indice : Integer): TDAOfNReal; overload; override;
			function asVI(indice : Integer): TDAOFNInt; overload; override;
			function asB(indice : Integer): boolean; overload; override;
			function asVB(indice : Integer): TDAOfBoolean; overload; override;
			function asFecha(indice : Integer): TFecha; overload; override;
			function highVarDef : Integer; override;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;
      procedure setValor(valor: TDAOfBoolean);

      property valor: TDAOfBoolean read asVB write setValor;
	end;

	TVarDef_PNR = class(TVarDef_NR)
		private
		public
{			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;}

			constructor Create(cosa : Pointer{^TCosa}; const xnombre, xunidades: string;
                         precision, decimales: Integer; Ppd: Pointer;
                         variable: PNReal); reintroduce; overload;
	end;

		TVarDef_PNI = class(TVarDef_NI)
		private
		public
{			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;}

			constructor Create(cosa: Pointer{^TCosa}; const xnombre, xunidades: string;
                         Ppd: Pointer; variable: PNEntero); reintroduce; overload;
	end;

	TVarDef_PS = class(TVarDef_S)
		private
		public
{			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;}

			constructor Create(cosa : Pointer{^TCosa}; const xnombre, xunidades: string ; Ppd : Pointer ; variable : PString); reintroduce;
	end;

	TVarDef_PB = class(TVarDef_B)
		private
		public
{			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;}

			constructor Create(cosa : Pointer{^TCosa}; const xnombre, xunidades: string ; Ppd : Pointer ; variable : PBoolean); reintroduce;
	end;

	TVarDef_PFecha = class(TVarDef_Fecha)
		private
		public
{			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;}

			constructor Create(cosa : Pointer{^TCosa}; const xnombre: string ; Ppd : Pointer ; variable : PFecha); reintroduce;
	end;

	TVarDef_PVNR = class(TVarDef_VNR)
		private
		public
{			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;}

			constructor Create(cosa: Pointer{^TCosa}; const xnombre, xunidades: string;
                         precision, decimales: Integer; Ppd: Pointer;
                         variable: PTDAOfNReal; usarNomenclaturaPorPoste: boolean); reintroduce;
	end;

	TVarDef_PVNI = class(TVarDef_VNI)
		private
		public
{			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;}

			constructor Create(cosa: Pointer{^TCosa}; const xnombre, xunidades: string;
                         Ppd : Pointer; variable: PTDAOfNInt;
                         usarNomenclaturaPorPoste: boolean); reintroduce;
	end;

	TVarDef_PVB = class(TVarDef_VB)
		private
		public
{			function asS: String; override;
			function asNR: NReal; override;
			function asNI: integer; override;
			function asVR: TDAOfNReal; override;
			function asVI: TDAOFNInt; override;
			function asB: boolean; override;
			function asVB: TDAOfBoolean; override;
			function asFecha: TFecha; override;}

			constructor Create(cosa: Pointer{^TCosa}; const xnombre, xunidades: string;
                         Ppd: Pointer; variable : PTDAOfBoolean;
                         usarNomenclaturaPorPoste: boolean); reintroduce;
	end;

  TVarDef_TStringList = class(TVarDef)
    private
      usarNomenclaturaPorPoste: boolean;
    public
			constructor Create(cosa : Pointer{^TCosa}; const xnombre, xunidades: string;
                         variable: PTStringList; usarNomenclaturaPorPoste: boolean); reintroduce;

			function getNombreCosa : String; override;
      function getUnidades: String; override;
			function getNombreVar : String; override;
      function getIndicesVars: String; override;

      procedure getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String); override;

			function asS: String; overload; override;
			function asNR: NReal; overload; override;
			function asNI: integer; overload; override;
			function asVR: TDAOfNReal; overload; override;
			function asVI: TDAOFNInt; overload; override;
			function asB: boolean; overload; override;
			function asVB: TDAOfBoolean; overload; override;
			function asFecha: TFecha; overload; override;                         

			function asS(indice : Integer): String; overload;
			function asNR(indice : Integer): NReal; overload;
			function asNI(indice : Integer): integer; overload;
			function asVR(indice : Integer): TDAOfNReal; overload;
			function asVI(indice : Integer): TDAOFNInt; overload;
			function asB(indice : Integer): boolean; overload;
			function asVB(indice : Integer): TDAOfBoolean; overload;
			function asFecha(indice : Integer): TFecha; overload;
			function CountVarDef : Integer;

      procedure setValorFromStringPersistida(const valor: String); override;
      function getValorAsStringPersistible: String; override;      
      procedure setValor(valor: TStringList);
	end;  

	TListaVarDefs = class (TList) //Lista de objetos de tipo TVarDef
		function find(const nombreVar : String; var pos : Integer) : boolean; overload;
    function find(const nombreVar : String): TVarDef; overload;

    procedure setValorFromStringPersistida(const nombreVar, valor: String);
    function getValorStrPersistible(const nombreVar: String): String;

		procedure Free;
	end;

	TClasesDeVarDefs = class of TVarDef;

implementation

uses
	uCosaConNombre;
//------------------
//Metodos de TVarDef
//==================

constructor TVarDef.Create(cosa: Pointer{^TCosa}; const xnombreVar, unidades: string; pVariable : Pointer);
begin
	inherited Create;
	self.cosa:= cosa;
	nombreVar:= xnombreVar;
  self.unidades:= unidades;
	self.pVariable:= pVariable;
	self.Ppd:= NIL;
	offsetVector:= -1;
	offsetVar:= -1;
  self.indice:= '0';
end;

constructor TVarDef.CreatePpd(cosa: Pointer{^TCosa}; const xnombreVar, unidades: string; pVariable: Pointer; Ppd: Pointer);
begin
	inherited Create;
	self.cosa:= cosa;
	nombreVar:= xnombreVar;
  self.unidades:= unidades;
	self.pVariable:= NIL;
	self.Ppd:= Ppd;
	offsetVar:= PChar(pVariable) - PChar(Ppd^);
	offsetVector:= -1;
  self.indice:= '0';
end;

constructor TVarDef.CreatePpdIndice(cosa: Pointer{^TCosa}; const xnombreVar, unidades: string; pVariable: Pointer; pVector: Pointer; Ppd: Pointer);
begin
	inherited Create;
	self.cosa:= cosa;
	nombreVar:= xnombreVar;
  self.unidades:= unidades;
	self.pVariable:= NIL;
	self.Ppd:= Ppd;
	offsetVector:= PChar(pVector) - PChar(Ppd^);
	offsetVar:= PChar(pVariable) - PChar(pVector^);
  self.indice:= '0';
end;

function TVarDef.getNombreCosa : String;
begin
	result:= TCosaConNombre(cosa).nombre;
end;

function TVarDef.getUnidades: String;
begin
  result:= unidades;
end;

function TVarDef.getNombreVar : String;
begin
	result:= nombreVar;
end;

function TVarDef.getIndicesVars: String;
begin
  result:= indice;
end;

procedure TVarDef.setIndice(newIndice: Integer);
begin
  Self.indice:= IntToStr(newIndice);
end;

function TVarDef.esV : boolean;
begin
	result:= self is TVarDef_V;
end;

procedure TVarDef.getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String);
begin
  xnombreCosa:= TCosaConNombre(cosa).nombre;
  xunidades:= unidades;
  xnombreVar:= nombreVar;
  xindicesVars:= indice;
end;

procedure TVarDef.Prepararse();
begin
{$IFOPT R+}
{	if Ppd = NIL then
		raise ERangeError.Create('Ppd = NIL en VarDef de ' + nombreVar);}
{$ENDIF}
  if pVariable = NIL then
  begin
    if offsetVector = - 1 then
    begin
      pVariable := PChar(Ppd^) + offsetVar;
    end
    else
    begin
      pVariable := PChar(PChar(PChar(Ppd^) + offsetVector)^) + offsetVar;
    end
  end
end;

//---------------------
//Metodos de TVarDef_NR
//=====================

constructor TVarDef_NR.Create(cosa : Pointer; const xnombre, xunidades: string; precision, decimales: Integer; variable: PNreal);
begin
	inherited Create(cosa, xnombre, xunidades, variable);
  self.precision:= precision;
  self.decimales:= decimales;
end;

constructor TVarDef_NR.CreatePpdIndice(cosa: Pointer{^TCosa}; const xnombreVar, unidades: string; precision, decimales: Integer; pVariable: Pointer; pVector: Pointer; Ppd: Pointer);
begin
  inherited CreatePpdIndice(cosa, xnombreVar, unidades, pVariable, pVector, Ppd);
  self.precision:= precision;
  self.decimales:= decimales;
end;

function TVarDef_NR.asS: String;
begin
	result:= FloatToStrF(PNreal(pVariable)^, formatoReales, precision, decimales);
end;

function TVarDef_NR.asNR: NReal;
begin
	result := PNreal(pVariable)^;
end;

function TVarDef_NR.asNI: integer;
begin
	result := ROUND(PNreal(pVariable)^);
end;

function TVarDef_NR.asVR: TDAOfNReal;
var
	a : TDAofNReal;
begin
	setLength(a, 1);
	a[0] := PNReal(pVariable)^;
	result := a;
end;

function TVarDef_NR.asVI: TDAOFNInt;
var
	a : TDAofNInt;
begin
	setLength(a, 1);
	a[0] := ROUND(PNReal(pVariable)^);
	result := a;
end;

function TVarDef_NR.asB: boolean;
begin
	result := PNReal(pVariable)^ <> 0;
end;

function TVarDef_NR.asVB: TDAOfBoolean;
var
	a : TDAOfBoolean;
begin
	setLength(a, 1);
	a[0] := PNReal(pVariable)^ <> 0;
	result := a;
end;

function TVarDef_NR.asFecha: TFecha;
begin
	result := TFecha.Create_Dt(PNReal(pVariable)^);
end;

procedure TVarDef_NR.setValorFromStringPersistida(const valor: String);
begin
  PNReal(pVariable)^:= StrToFloat(valor);
end;

function TVarDef_NR.getValorAsStringPersistible: String;
begin
  result:= FloatToStrF(PNreal(pVariable)^, formatoReales, precision, decimales);
end;

procedure TVarDef_NR.setValor(valor: NReal);
begin
  PNReal(pVariable)^:= valor;
end;

//---------------------
//Metodos de TVarDef_NI
//=====================

constructor TVarDef_NI.Create(cosa : Pointer; const xnombre, xunidades: string; variable : PNEntero);
begin
	inherited Create(cosa, xnombre, xunidades, variable);
end;

function TVarDef_NI.asS: String;
begin
	result := IntToStr(PNentero(pVariable)^);
end;

function TVarDef_NI.asNR: NReal;
begin
	result := PNentero(pVariable)^;
end;

function TVarDef_NI.asNI: integer;
begin
	result := PNentero(pVariable)^;
end;

function TVarDef_NI.asVR: TDAOfNReal;
var
	a : TDAofNReal;
begin
	setLength(a, 1);
	a[0] := PNentero(pVariable)^;
	result := a;
end;

function TVarDef_NI.asVI: TDAOFNInt;
var
	a : TDAofNInt;
begin
	setLength(a, 1);
	a[0] := PNentero(pVariable)^;
	result := a;
end;

function TVarDef_NI.asB: boolean;
begin
	result := PNentero(pVariable)^ <> 0;
end;

function TVarDef_NI.asVB: TDAOfBoolean;
var
	a : TDAOfBoolean;
begin
	setLength(a, 1);
	a[0] := PNentero(pVariable)^ <> 0;
  result:= a;
end;

function TVarDef_NI.asFecha: TFecha;
begin
	result := TFecha.Create_Dt(PNentero(pVariable)^);
end;

procedure TVarDef_NI.setValorFromStringPersistida(const valor: String);
begin
  PNentero(pVariable)^:= StrToInt(valor);
end;

function TVarDef_NI.getValorAsStringPersistible: String;
begin
  result:= IntToStr(PNentero(pVariable)^);
end;

procedure TVarDef_NI.setValor(valor: Integer);
begin
  PNentero(pVariable)^:= valor;
end;

//--------------------
//Metodos de TVarDef_S
//====================

constructor TVarDef_S.Create(cosa : Pointer; const xnombre, xunidades: string; variable : PString);
begin
	inherited Create(cosa, xnombre, xunidades, variable);
end;

function TVarDef_S.asS: String;
begin
	result := PString(pVariable)^;
end;

function TVarDef_S.asNR: NReal;
begin
	result := StrToFloat(PString(pVariable)^);
end;

function TVarDef_S.asNI: integer;
begin
	result := StrToInt(PString(pVariable)^);
end;

function TVarDef_S.asVR: TDAOfNReal;
var
	a : TDAofNReal;
begin
	setLength(a, 1);
	a[0] := StrToFloat(PString(pVariable)^);
	result := a;
end;

function TVarDef_S.asVI: TDAOFNInt;
var
	a : TDAofNInt;
begin
	setLength(a, 1);
	a[0] := StrToInt(PString(pVariable)^);
	result := a;
end;

function TVarDef_S.asB: boolean;
begin
	if PString(pVariable)^ = 'true' then
		result := true
	else if PString(pVariable)^ = 'false' then
		result := false
	else
		raise EConvertError.Create('TVarDef_S.asB: String <> true y String <> false')
end;

function TVarDef_S.asVB: TDAOfBoolean;
var
	a : TDAOfBoolean;
begin
	setLength(a, 1);
	if PString(pVariable)^ = 'true' then
		a[0] := true
	else if PString(pVariable)^ = 'false' then
		a[0] := false
	else
		raise EConvertError.Create('String <> true y String <> false');
	result := a;
end;

function TVarDef_S.asFecha: TFecha;
begin
	result:= TFecha.Create_Str(PString(pVariable)^)
end;

procedure TVarDef_S.setValorFromStringPersistida(const valor: String);
begin
  PString(pVariable)^:= valor;
end;

function TVarDef_S.getValorAsStringPersistible: String;
begin
  result:= PString(pVariable)^;
end;

//--------------------
//Metodos de TVarDef_B
//====================

constructor TVarDef_B.Create(cosa : Pointer; const xnombre, xunidades: string; variable : PBoolean);
begin
	inherited Create(cosa, xnombre, xunidades, variable);
end;

function TVarDef_B.asS: String;
begin
  result:= BoolToStr(PBoolean(pVariable)^, true);
end;

function TVarDef_B.asNR: NReal;
begin
	if PBoolean(pVariable)^ then
		result := 1
	else
		result := 0;
end;

function TVarDef_B.asNI: integer;
begin
	if PBoolean(pVariable)^ then
		result := 1
	else
		result := 0;
end;

function TVarDef_B.asVR: TDAOfNReal;
var
	a : TDAofNReal;
begin
	setLength(a, 1);
	if PBoolean(pVariable)^ then
		a[0] := 1
	else
		a[0] := 0;
	result := a;
end;

function TVarDef_B.asVI: TDAOFNInt;
var
	a : TDAofNInt;
begin
	setLength(a, 1);
	if PBoolean(pVariable)^ then
		a[0] := 1
	else
		a[0] := 0;
	result := a;
end;

function TVarDef_B.asB: boolean;
begin
	result := PBoolean(pVariable)^;
end;

function TVarDef_B.asVB: TDAOfBoolean;
var
	a : TDAOfBoolean;
begin
	setLength(a, 1);
	a[0] := PBoolean(pVariable)^;
	result := a;
end;

function TVarDef_B.asFecha: TFecha;
begin
	raise EConvertError.Create('Boolean to fecha indefinido');
  result:= NIL;
end;

procedure TVarDef_B.setValorFromStringPersistida(const valor: String);
begin
  PBoolean(pVariable)^:= StrToBool(valor);
end;

function TVarDef_B.getValorAsStringPersistible: String;
begin
  result:= BoolToStr(PBoolean(pVariable)^, true);
end;

procedure TVarDef_B.setValor(valor: boolean);
begin
  PBoolean(pVariable)^:= valor;
end;

//------------------------
//Metodos de TVarDef_Fecha
//========================

constructor TVarDef_Fecha.Create(cosa : Pointer; const xnombre: string; variable : PFecha);
begin
	inherited Create(cosa, xnombre, strSinUnidad, variable);
end;

function TVarDef_Fecha.asS: String;
begin
	result := (PFecha(pVariable)^).AsISOStr;
end;

function TVarDef_Fecha.asNR: NReal;
begin
	result := (PFecha(pVariable)^).AsDt;
end;

function TVarDef_Fecha.asNI: integer;
begin
	result := ROUND(PFecha(pVariable)^.AsDt);
end;

function TVarDef_Fecha.asVR: TDAOfNReal;
var
	a : TDAofNReal;
begin
	setLength(a, 1);
	a[0] := (PFecha(pVariable)^).AsDt;
	result := a
end;

function TVarDef_Fecha.asVI: TDAOFNInt;
var
	a : TDAofNInt;
begin
	setLength(a, 1);
	a[0] := ROUND((PFecha(pVariable)^).AsDt);
	result := a
end;

function TVarDef_Fecha.asB: boolean;
begin
	Raise EConvertError.Create('Fecha to boolean indefinido');
  result:= false;
end;

function TVarDef_Fecha.asVB: TDAOfBoolean;
begin
	Raise EConvertError.Create('Fecha to vector boolean indefinido');
  result:= NIL;  
end;

function TVarDef_Fecha.asFecha: TFecha;
begin
	result:= PFecha(pVariable)^;
end;

procedure TVarDef_Fecha.setValorFromStringPersistida(const valor: String);
begin
  if PFecha(pVariable^) = NIL then
    PFecha(pVariable)^:= TFecha.Create_Str(valor)
  else
    PFecha(pVariable)^.PonerIgualA(valor);
end;

function TVarDef_Fecha.getValorAsStringPersistible: String;
begin
  result:= PFecha(pVariable)^.AsISOStr;
end;

procedure TVarDef_Fecha.setValor(valor: TFecha);
begin
  PFecha(pVariable)^:= valor;
end;

//-----------------------------
//Metodos de TVarDef_Referencia
//=============================

constructor TVarDef_Referencia.Create(cosa : Pointer{^TCosa} ; const xnombre: string ; cosaConNombre: Pointer{^TCosaConNombre});
begin
  inherited Create(cosa, xnombre, unidades, cosaConNombre);
end;

function TVarDef_Referencia.asS: String;
begin
  result:= PCosaConNombre(pVariable)^.ClaseNombre;
end;

function TVarDef_Referencia.asNR: NReal;
begin
  Raise Exception.Create('TVarDef_Referencia.asNR: Referencia to NReal no definido');
end;

function TVarDef_Referencia.asNI: integer;
begin
  Raise Exception.Create('TVarDef_Referencia.asNI: Referencia to Integer no definido');
end;

function TVarDef_Referencia.asVR: TDAOfNReal;
begin
  Raise Exception.Create('TVarDef_Referencia.asVR: Referencia to TDAOfNReal no definido');
end;

function TVarDef_Referencia.asVI: TDAOFNInt;
begin
  Raise Exception.Create('TVarDef_Referencia.asVI: Referencia to TDAOfNInt no definido');
end;

function TVarDef_Referencia.asB: boolean;
begin
  Raise Exception.Create('TVarDef_Referencia.asB: Referencia to Boolean no definido');
end;

function TVarDef_Referencia.asVB: TDAOfBoolean;
begin
  Raise Exception.Create('TVarDef_Referencia.asVB: Referencia to TDAOfBoolean no definido');
end;

function TVarDef_Referencia.asFecha: TFecha;
begin
  Raise Exception.Create('TVarDef_Referencia.asFecha: Referencia to TFecha no definido');
end;

procedure TVarDef_Referencia.setValorFromStringPersistida(const valor: String);
var
  clase, nombreRef: String;
begin
  parsearReferencia(valor, clase, nombreRef);
  if (clase <> '?') then
    uCosaConNombre.registrar_referencia(cosa, clase, nombreRef, pVariable)
  else
    PCosaConNombre(pVariable)^:= NIL;
end;

function TVarDef_Referencia.getValorAsStringPersistible: String;
begin
	if assigned( valor ) and ( valor is TCosaConNombre) then
    result:= '<' + PCosaConNombre(pVariable)^.ClassName + '.' + PCosaConNombre(pVariable)^.nombre + '>'
	else
    result:= '<?.?>';
end;

//Los TObject son TCosaConNombre, pero TCosaConNombre aparece en el uses
//de la implementation
procedure TVarDef_Referencia.setValor(valor: TObject);
begin
  PCosaConNombre(pVariable)^:= TCosaConNombre(valor);
end;

function TVarDef_Referencia.getValor: TObject;
begin
  result:= PCosaConNombre(pVariable)^;
end;

//----------------------
//Metodos de TVarDef_VNR
//======================

constructor TVarDef_VNR.Create(cosa : Pointer; const xnombre, xunidades: string;
                               precision, decimales: Integer;
                               variable: PTDAOfNreal;
                               usarNomenclaturaPorPoste: boolean);
begin
	inherited Create(cosa, xnombre, xunidades, variable);
  self.precision:= precision;
  self.decimales:= decimales;
  self.usarNomenclaturaPorPoste:= usarNomenclaturaPorPoste;
end;

function TVarDef_VNR.getNombreCosa : String;
var
	cadena : String;
	i : Integer;
begin
	cadena := TCosaConNombre(cosa).nombre;
	for i := 1 to high(PTDAOfNReal(pVariable)^) do
		cadena := cadena + vectorSeparator + TCosaConNombre(cosa).nombre;
	result := cadena;
end;

function TVarDef_VNR.getUnidades: String;
var
	cadena : String;
	i : Integer;
begin
	cadena:= unidades;
	for i := 1 to high(PTDAOfNReal(pVariable)^) do
		cadena := cadena + vectorSeparator + unidades;
	result := cadena;
end;

function TVarDef_VNR.getNombreVar : String;
var
	cadena : String;
	i : Integer;
begin
	cadena := '';
  if usarNomenclaturaPorPoste then
  begin
    for i := 0 to high(PTDAOfNReal(pVariable)^) - 1 do
      cadena := cadena + nombreVar + '_P' + IntToStr(i + 1) + vectorSeparator;
    cadena := cadena + nombreVar + '_P' + IntToStr(high(PTDAOfNReal(pVariable)^) + 1);
  end
  else
  begin
    for i := 0 to high(PTDAOfNReal(pVariable)^) - 1 do
      cadena := cadena + nombreVar + '[' + IntToStr(i + 1) + ']' + vectorSeparator;
    cadena := cadena + nombreVar + '[' + IntToStr(high(PTDAOfNReal(pVariable)^) + 1) + ']';
  end;
	result := cadena;
end;

function TVarDef_VNR.getIndicesVars: String;
var
	cadena : String;
	i : Integer;
begin
	cadena:= '';
	for i:= 0 to high(PTDAOfNReal(pVariable)^) - 1 do
		cadena:= cadena + IntToStr(i + 1) + vectorSeparator;
	cadena:= cadena + IntToStr(Length(PTDAOfNReal(pVariable)^));
	result:= cadena;
end;

procedure TVarDef_VNR.getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String);
var
	i: Integer;
begin
	xnombreCosa := TCosaConNombre(cosa).nombre;
	for i := 1 to high(PTDAOfNReal(pVariable)^) do
		xnombreCosa:= xnombreCosa + vectorSeparator + TCosaConNombre(cosa).nombre;

	xunidades:= unidades;
	for i:= 1 to high(PTDAOfNReal(pVariable)^) do
		xunidades:= xunidades + vectorSeparator + unidades;

  if usarNomenclaturaPorPoste then
  begin
    xnombreVar:= nombreVar + '_P1';
    for i:= 1 to high(PTDAOfNReal(pVariable)^) do
      xnombreVar:= xnombreVar + vectorSeparator + nombreVar + '_P' + IntToStr(i + 1);
  end
  else
  begin
    xnombreVar:= nombreVar + '[1]';
    for i:= 1 to high(PTDAOfNReal(pVariable)^) do
      xnombreVar:= xnombreVar + vectorSeparator + nombreVar + '[' + IntToStr(i + 1) + ']';
  end;

	xindicesVars:= '1';
	for i:= 1 to high(PTDAOfNReal(pVariable)^) do
		xindicesVars:= xindicesVars + vectorSeparator + IntToStr(i + 1);
end;

function TVarDef_VNR.asS: String;
var
	cadena : String;
	i : Integer;
begin
	cadena := '';
	for i := 0 to high(PTDAOfNReal(pVariable)^) - 1 do
		cadena := cadena + FloatToStrF((PTDAOfNReal(pVariable)^)[i], formatoReales, precision, decimales) + vectorSeparator;
	cadena := cadena + FloatToStrF((PTDAOfNReal(pVariable)^)[high(PTDAOfNReal(pVariable)^)], formatoReales, precision, decimales);
	result := cadena;
end;

function TVarDef_VNR.asNR: NReal;
begin
	raise EConvertError.Create('VNR to NR indefinido');
  result:= 0;
end;

function TVarDef_VNR.asNI: integer;
begin
	raise EConvertError.Create('VNR to NI indefinido');
  result:= 0;
end;

function TVarDef_VNR.asVR: TDAOfNReal;
begin
	result := copy(PTDAOfNReal(pVariable)^, 0, MAXINT)
end;

function TVarDef_VNR.asVI: TDAOFNInt;
var
	a : TDAofNInt;
	i : Integer;
begin
	setLength(a, Length(PTDAOfNReal(pVariable)^));
	for i := 0 to high(a) do
		a[i] := ROUND((PTDAOfNReal(pVariable)^)[i]);
	result := a;
end;

function TVarDef_VNR.asB: boolean;
begin
	raise EConvertError.Create('VNR to B indefinido');
  result:= false;
end;

function TVarDef_VNR.asVB: TDAOfBoolean;
var
	a : TDAOfBoolean;
	i : Integer;
begin
	setLength(a, Length(PTDAOfNReal(pVariable)^));
	for i := 0 to high(a) do
		a[i] := (PTDAOfNReal(pVariable)^)[i] <> 0;
	result := a;
end;

function TVarDef_VNR.asFecha: TFecha;
begin
	raise EConvertError.Create('VNR to Fecha indefinido');
  result:= NIL;
end;

function TVarDef_VNR.asS(indice : Integer): String;
begin
	result := FloatToStrF((PTDAOfNReal(pVariable)^)[indice], formatoReales, CF_PRECISION, CF_DECIMALES);
end;

function TVarDef_VNR.asNR(indice : Integer): NReal;
begin
	result := (PTDAOfNReal(pVariable)^)[indice];
end;

function TVarDef_VNR.asNI(indice : Integer): integer;
begin
	result := round((PTDAOfNReal(pVariable)^)[indice]);
end;

function TVarDef_VNR.asVR(indice : Integer): TDAOfNReal;
var
	res : TDAOfNReal;
begin
	SetLength(res, 1);
	res[0] := (PTDAOfNReal(pVariable)^)[indice];
	result := res;
end;

function TVarDef_VNR.asVI(indice : Integer): TDAOFNInt;
var
	res : TDAofNInt;
begin
	SetLength(res, 1);
	res[0] := round((PTDAOfNReal(pVariable)^)[indice]);
	result := res;
end;

function TVarDef_VNR.asB(indice : Integer): boolean;
begin
	result := (PTDAOfNReal(pVariable)^)[indice] <> 0;
end;

function TVarDef_VNR.asVB(indice : Integer): TDAOfBoolean;
var
	res : TDAOfBoolean;
begin
	SetLength(res, 1);
	res[0] := (PTDAOfNReal(pVariable)^)[indice] <> 0;
	result := res;
end;

function TVarDef_VNR.asFecha(indice : Integer): TFecha;
begin
	Raise EConvertError.Create('VNR to Fecha indefinido');
  result:= NIL;
end;

function TVarDef_VNR.highVarDef : Integer;
begin
	result := high(PTDAOfNReal(pVariable)^);
end;

procedure TVarDef_VNR.setValorFromStringPersistida(const valor: String);
begin
  parseDAOfNreal(PTDAOfNReal(pVariable)^, valor);
end;

function TVarDef_VNR.getValorAsStringPersistible: String;
begin
  result:= TDAOfNRealToString(PTDAOfNReal(pVariable)^, precision, decimales, ', ');
end;

procedure TVarDef_VNR.setValor(valor: TDAofNReal);
begin
  PTDAOfNReal(pVariable)^:= valor;
end;

//----------------------
//Metodos de TVarDef_VNI
//======================

constructor TVarDef_VNI.Create(cosa: Pointer; const xnombre, xunidades: string;
                               variable : PTDAOfNInt;
                               usarNomenclaturaPorPoste: boolean);
begin
	inherited Create(cosa, xnombre, xunidades, variable);
  self.usarNomenclaturaPorPoste:= usarNomenclaturaPorPoste;
end;

function TVarDef_VNI.getNombreCosa : String;
var
	cadena : String;
	i : Integer;
begin
	cadena := TCosaConNombre(cosa).nombre;
	for i := 1 to high(PTDAOfNInt(pVariable)^) do
		cadena := cadena + vectorSeparator;
	result := cadena;
end;

function TVarDef_VNI.getUnidades: String;
var
	cadena : String;
	i : Integer;
begin
	cadena:= unidades;
	for i := 1 to high(PTDAOfNInt(pVariable)^) do
		cadena := cadena + vectorSeparator + unidades;
	result := cadena;
end;

function TVarDef_VNI.getNombreVar : String;
var
	cadena : String;
	i : Integer;
begin
	cadena := '';
  if usarNomenclaturaPorPoste then
  begin
    for i := 0 to high(PTDAOfNInt(pVariable)^) - 1 do
      cadena := cadena + nombreVar + '_P' + IntToStr(i + 1) + vectorSeparator;
    cadena := cadena + nombreVar + '_P' + IntToStr(high(PTDAOfNInt(pVariable)^) + 1);
  end
  else
  begin
    for i := 0 to high(PTDAOfNInt(pVariable)^) - 1 do
      cadena := cadena + nombreVar + '[' + IntToStr(i + 1) + ']' + vectorSeparator;
    cadena := cadena + nombreVar + '[' + IntToStr(high(PTDAOfNInt(pVariable)^) + 1) + ']';
  end;
	result := cadena;
end;

function TVarDef_VNI.getIndicesVars: String;
var
	cadena : String;
	i : Integer;
begin
	cadena:= '';
	for i:= 0 to high(PTDAOfNInt(pVariable)^) - 1 do
		cadena:= cadena + IntToStr(i + 1) + vectorSeparator;
	cadena:= cadena + IntToStr(Length(PTDAOfNReal(pVariable)^));
	result:= cadena;
end;

procedure TVarDef_VNI.getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String);
var
	i: Integer;
begin
	xnombreCosa := TCosaConNombre(cosa).nombre;
	for i := 1 to high(PTDAOfNInt(pVariable)^) do
		xnombreCosa:= xnombreCosa + vectorSeparator + TCosaConNombre(cosa).nombre;

	xunidades:= unidades;
	for i:= 1 to high(PTDAOfNInt(pVariable)^) do
		xunidades:= xunidades + vectorSeparator + unidades;

  if usarNomenclaturaPorPoste then
  begin
    xnombreVar:= nombreVar + '_P1';
    for i:= 1 to high(PTDAOfNInt(pVariable)^) do
      xnombreVar:= xnombreVar + vectorSeparator + nombreVar + '_P' + IntToStr(i + 1);
  end
  else
  begin
    xnombreVar:= nombreVar + '[1]';
    for i:= 1 to high(PTDAOfNInt(pVariable)^) do
      xnombreVar:= xnombreVar + vectorSeparator + nombreVar + '[' + IntToStr(i + 1) + ']';
  end;

	xindicesVars:= '1';
	for i:= 1 to high(PTDAOfNInt(pVariable)^) do
		xindicesVars:= xindicesVars + vectorSeparator + IntToStr(i + 1);
end;

function TVarDef_VNI.asS: String;
var
	cadena : String;
	i : Integer;
begin
	cadena := '';
	for i := 0 to high(PTDaOfNInt(pVariable)^) - 1 do
		cadena := cadena + IntToStr((PTDaOfNInt(pVariable)^)[i]) + vectorSeparator;
	cadena := cadena + IntToStr((PTDaOfNInt(pVariable)^)[high(PTDaOfNInt(pVariable)^)]);
	result := cadena;
end;

function TVarDef_VNI.asNR: NReal;
begin
	raise EConvertError.Create('VNI to NR indefinido');
  result:= 0;
end;

function TVarDef_VNI.asNI: integer;
begin
	raise EConvertError.Create('VNI to NI indefinido');
  result:= 0;
end;

function TVarDef_VNI.asVR: TDAOfNReal;
var
	a : TDAofNReal;
	i : Integer;
begin
	SetLength(a, Length(PTDaOfNInt(pVariable)^));
	for i := 0 to high(a) do
		a[i] := (PTDaOfNInt(pVariable)^)[i];
	result := a;
end;

function TVarDef_VNI.asVI: TDAOFNInt;
begin
	result := copy(PTDaOfNInt(pVariable)^, 0, MAXINT)
end;

function TVarDef_VNI.asB: boolean;
begin
	raise EConvertError.Create('VNR to B indefinido');
  result:= false;
end;

function TVarDef_VNI.asVB: TDAOfBoolean;
var
	a : TDAOfBoolean;
	i : Integer;
begin
	setLength(a, Length(PTDaOfNInt(pVariable)^));
	for i := 0 to high(a) do
		a[i] := (PTDaOfNInt(pVariable)^)[i] <> 0;
	result := a;
end;

function TVarDef_VNI.asFecha: TFecha;
begin
	raise EConvertError.Create('VNI to Fecha indefinido');
  result:= NIL;
end;

function TVarDef_VNI.asS(indice : Integer): String;
begin
	result := IntToStr((PTDAOfNInt(pVariable)^)[indice]);
end;

function TVarDef_VNI.asNR(indice : Integer): NReal;
begin
	result := (PTDAOfNInt(pVariable)^)[indice];
end;

function TVarDef_VNI.asNI(indice : Integer): integer;
begin
	result := (PTDAOfNInt(pVariable)^)[indice];
end;

function TVarDef_VNI.asVR(indice : Integer): TDAOfNReal;
var
	res : TDAOfNReal;
begin
	SetLength(res, 1);
	res[0] := (PTDAOfNInt(pVariable)^)[indice];
	result := res;
end;

function TVarDef_VNI.asVI(indice : Integer): TDAOFNInt;
var
	res : TDAofNInt;
begin
	SetLength(res, 1);
	res[0] := (PTDAOfNInt(pVariable)^)[indice];
	result := res;
end;

function TVarDef_VNI.asB(indice : Integer): boolean;
begin
	result := (PTDAOfNInt(pVariable)^)[indice] <> 0;
end;

function TVarDef_VNI.asVB(indice : Integer): TDAOfBoolean;
var
	res : TDAOfBoolean;
begin
	SetLength(res, 1);
	res[0] := (PTDAOfNInt(pVariable)^)[indice] <> 0;
	result := res;
end;

function TVarDef_VNI.asFecha(indice : Integer): TFecha;
begin
	Raise EConvertError.Create('VNI to Fecha indefinido');
  result:= NIL;
end;

function TVarDef_VNI.highVarDef : Integer;
begin
	result := high(PTDAOfNInt(pVariable)^);
end;

procedure TVarDef_VNI.setValorFromStringPersistida(const valor: String);
begin
  parseDAOfNInt(PTDAOfNInt(pVariable)^, valor);
end;

function TVarDef_VNI.getValorAsStringPersistible: String;
begin
  result:= TDAOfNIntToString(PTDAOfNInt(pVariable)^, ', ');
end;

procedure TVarDef_VNI.setValor(valor: TDAofNInt);
begin
  PTDAOfNInt(pVariable)^:= valor;
end;

//---------------------
//Metodos de TVarDef_VB
//=====================

constructor TVarDef_VB.Create(cosa: Pointer; const xnombre, xunidades: string;
                              variable: PTDAOfBoolean;
                              usarNomenclaturaPorPoste: boolean);
begin
	inherited Create(cosa, xnombre, xunidades, variable);
  self.usarNomenclaturaPorPoste:= usarNomenclaturaPorPoste;
end;

function TVarDef_VB.getNombreCosa : String;
var
	cadena : String;
	i : Integer;
begin
	cadena := TCosaConNombre(cosa).nombre;
	for i := 0 to high(PTDAOfBoolean(pVariable)^) do
		cadena := cadena + vectorSeparator;
	result := cadena;
end;

function TVarDef_VB.getUnidades: String;
var
	cadena : String;
	i : Integer;
begin
	cadena:= unidades;
	for i := 1 to high(PTDAOfBoolean(pVariable)^) do
		cadena := cadena + vectorSeparator + unidades;
	result := cadena;
end;

function TVarDef_VB.getNombreVar : String;
var
	cadena : String;
	i : Integer;
begin
	cadena := '';
  if usarNomenclaturaPorPoste then
  begin
    for i := 0 to high(PTDAOfBoolean(pVariable)^) - 1 do
      cadena := cadena + nombreVar + '_P' + IntToStr(i + 1) + vectorSeparator;
    cadena := cadena + nombreVar + '_P' + IntToStr(high(PTDAOfBoolean(pVariable)^) + 1);
  end
  else
  begin
    for i := 0 to high(PTDAOfBoolean(pVariable)^) - 1 do
      cadena := cadena + nombreVar + '[' + IntToStr(i + 1) + ']' + vectorSeparator;
    cadena := cadena + nombreVar + '[' + IntToStr(high(PTDAOfBoolean(pVariable)^) + 1) + ']';
  end;
	result := cadena;
end;

function TVarDef_VB.getIndicesVars: String;
var
	cadena : String;
	i : Integer;
begin
	cadena:= '';
	for i:= 0 to high(PTDAOfBoolean(pVariable)^) - 1 do
		cadena:= cadena + IntToStr(i + 1) + vectorSeparator;
	cadena:= cadena + IntToStr(Length(PTDAOfNReal(pVariable)^));
	result:= cadena;
end;

procedure TVarDef_VB.getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String);
var
	i: Integer;
begin
	xnombreCosa := TCosaConNombre(cosa).nombre;
	for i := 1 to high(PTDAOfBoolean(pVariable)^) do
		xnombreCosa:= xnombreCosa + vectorSeparator + TCosaConNombre(cosa).nombre;

	xunidades:= unidades;
	for i:= 1 to high(PTDAOfBoolean(pVariable)^) do
		xunidades:= xunidades + vectorSeparator + unidades;

  if usarNomenclaturaPorPoste then
  begin
    xnombreVar:= nombreVar + '_P1';
    for i:= 1 to high(PTDAOfBoolean(pVariable)^) do
      xnombreVar:= xnombreVar + vectorSeparator + nombreVar + '_P' + IntToStr(i + 1);
  end
  else
  begin
    xnombreVar:= nombreVar + '[1]';
    for i:= 1 to high(PTDAOfBoolean(pVariable)^) do
      xnombreVar:= xnombreVar + vectorSeparator + nombreVar + '[' + IntToStr(i + 1) + ']';
  end;

	xindicesVars:= '1';
	for i:= 1 to high(PTDAOfBoolean(pVariable)^) do
		xindicesVars:= xindicesVars + vectorSeparator + IntToStr(i + 1);
end;

function TVarDef_VB.asS: String;
var
	cadena : String;
	i : Integer;
begin
	cadena := '';
	for i := 0 to high(PTDAOfBoolean(pVariable)^) - 1 do
		begin
		if (PTDAOfBoolean(pVariable)^)[i] then
			cadena := cadena + 'true' + vectorSeparator
		else
			cadena := cadena + 'false' + vectorSeparator
		end;
		if (PTDAOfBoolean(pVariable)^)[high(PTDAOfBoolean(pVariable)^)] then
			cadena := cadena + 'true'
		else
			cadena := cadena + 'false';
	result := cadena;
end;

function TVarDef_VB.asNR: NReal;
begin
	raise EConvertError.Create('VB to NR indefinido');
  result:= 0;
end;

function TVarDef_VB.asNI: integer;
begin
	raise EConvertError.Create('VB to NI indefinido');
  result:= 0;
end;

function TVarDef_VB.asVR: TDAOfNReal;
var
	a : TDAofNReal;
	i : Integer;
begin
	SetLength(a, Length(PTDAOfBoolean(pVariable)^));
	for i := 0 to high(a) do
		begin
		if (PTDAOfBoolean(pVariable)^)[i] then
			a[i] := 1
		else
			a[i] := 0
		end;
	result := a;
end;

function TVarDef_VB.asVI: TDAOFNInt;
var
	a : TDAofNInt;
	i : Integer;
begin
	SetLength(a, Length(PTDAOfBoolean(pVariable)^));
	for i := 0 to high(a) do
		begin
		if (PTDAOfBoolean(pVariable)^)[i] then
			a[i] := 1
		else
			a[i] := 0
		end;
	result := a;
end;

function TVarDef_VB.asB: boolean;
begin
	raise EConvertError.Create('VB to B indefinido');
  result:= false;
end;

function TVarDef_VB.asVB: TDAOfBoolean;
begin
	result := copy(PTDAOfBoolean(pVariable)^, 0, MAXINT)
end;

function TVarDef_VB.asFecha: TFecha;
begin
	raise EConvertError.Create('VV to Fecha indefinido');
  result:= NIL;
end;

function TVarDef_VB.asS(indice : Integer): String;
var
	res : String;
begin
	if (PTDAOfBoolean(pVariable)^)[indice] then
		res := 'true'
	else
		res := 'false';
	result := res;
end;

function TVarDef_VB.asNR(indice : Integer): NReal;
var
	res : NReal;
begin
	if (PTDAOfBoolean(pVariable)^)[indice] then
		res := 1
	else
		res := 0;
	result := res;
end;

function TVarDef_VB.asNI(indice : Integer): integer;
var
	res : Integer;
begin
	if (PTDAOfBoolean(pVariable)^)[indice] then
		res := 1
	else
		res := 0;
	result := res;
end;

function TVarDef_VB.asVR(indice : Integer): TDAOfNReal;
var
	res : TDAOfNReal;
begin
	SetLength(res, 1);
	if (PTDAOfBoolean(pVariable)^)[indice] then
		res[0] := 1
	else
		res[0] := 0;
	result := res;
end;

function TVarDef_VB.asVI(indice : Integer): TDAOFNInt;
var
	res : TDAofNInt;
begin
	SetLength(res, 1);
	if (PTDAOfBoolean(pVariable)^)[indice] then
		res[0] := 1
	else
		res[0] := 0;
	result := res;
end;

function TVarDef_VB.asB(indice : Integer): boolean;
begin
	result := (PTDAOfBoolean(pVariable)^)[indice];
end;

function TVarDef_VB.asVB(indice : Integer): TDAOfBoolean;
var
	res : TDAOfBoolean;
begin
	SetLength(res, 1);
	res[0] := (PTDAOfBoolean(pVariable)^)[indice];
	result := res;
end;

function TVarDef_VB.asFecha(indice : Integer): TFecha;
begin
	Raise EConvertError.Create('VB to Fecha indefinido');
  result:= NIL;
end;

function TVarDef_VB.highVarDef : Integer;
begin
	result := high(PTDAOfBoolean(pVariable)^);
end;

procedure TVarDef_VB.setValorFromStringPersistida(const valor: String);
begin
  parseDAOfBoolean(PTDAOfBoolean(pVariable)^, valor);
end;

function TVarDef_VB.getValorAsStringPersistible: String;
begin
  result:= TDAOfBooleanToString(PTDAOfBoolean(pVariable)^, ', ', true);
end;

procedure TVarDef_VB.setValor(valor: TDAOfBoolean);
begin
  PTDAOfBoolean(pVariable)^:= valor;
end;

//----------------------
//Metodos de TVarDef_PNR
//======================

constructor TVarDef_PNR.Create(cosa : Pointer; const xnombre, xunidades: string; precision, decimales: Integer; Ppd: Pointer; variable: PNReal);
begin
	inherited CreatePpd(cosa, xnombre, xunidades, variable, Ppd);
  self.precision:= precision;
  self.decimales:= decimales;
end;

{function TVarDef_PNR.asS: String;
begin
//Prepararse;
result := inherited asS;
end;

function TVarDef_PNR.asNR: NReal;
begin
//Prepararse;
result := inherited asNR;
end;

function TVarDef_PNR.asNI: integer;
begin
//Prepararse;
result := inherited asNI;
end;

function TVarDef_PNR.asVR: TDAOfNReal;
begin
//Prepararse;
result := inherited asVR;
end;

function TVarDef_PNR.asVI: TDAOFNInt;
begin
//Prepararse;
result := inherited asVI;
end;

function TVarDef_PNR.asB: boolean;
begin
//Prepararse;
result := inherited asB;
end;

function TVarDef_PNR.asVB: TDAOfBoolean;
begin
//Prepararse;
result := inherited asVB;
end;

function TVarDef_PNR.asFecha: TFecha;
begin
//Prepararse;
result := inherited asFecha;
end;}

//----------------------
//Metodos de TVarDef_PNI
//======================

constructor TVarDef_PNI.Create(cosa : Pointer ; const xnombre, xunidades: string ; Ppd : Pointer ; variable : PNEntero);
begin
	inherited CreatePpd(cosa, xnombre, xunidades, variable, Ppd);
end;

{function TVarDef_PNI.asS: String;
begin
//Prepararse;
result := inherited asS;
end;

function TVarDef_PNI.asNR: NReal;
begin
//Prepararse;
result := inherited asNR;
end;

function TVarDef_PNI.asNI: integer;
begin
//Prepararse;
result := inherited asNI;
end;

function TVarDef_PNI.asVR: TDAOfNReal;
begin
//Prepararse;
result := inherited asVR;
end;

function TVarDef_PNI.asVI: TDAOFNInt;
begin
//Prepararse;
result := inherited asVI;
end;

function TVarDef_PNI.asB: boolean;
begin
//Prepararse;
result := inherited asB;
end;

function TVarDef_PNI.asVB: TDAOfBoolean;
begin
//Prepararse;
result := inherited asVB;
end;

function TVarDef_PNI.asFecha: TFecha;
begin
//Prepararse;
result := inherited asFecha;
end;}

//---------------------
//Metodos de TVarDef_PS
//=====================

constructor TVarDef_PS.Create(cosa : Pointer ; const xnombre, xunidades: string ; Ppd : Pointer ; variable : PString);
begin
	inherited CreatePpd(cosa, xnombre, xunidades, variable, Ppd);
end;

{function TVarDef_PS.asS: String;
begin
//Prepararse;
result := inherited asS;
end;

function TVarDef_PS.asNR: NReal;
begin
//Prepararse;
result := inherited asNR;
end;

function TVarDef_PS.asNI: integer;
begin
//Prepararse;
result := inherited asNI;
end;

function TVarDef_PS.asVR: TDAOfNReal;
begin
//Prepararse;
result := inherited asVR;
end;

function TVarDef_PS.asVI: TDAOFNInt;
begin
//Prepararse;
result := inherited asVI;
end;

function TVarDef_PS.asB: boolean;
begin
//Prepararse;
result := inherited asB;
end;

function TVarDef_PS.asVB: TDAOfBoolean;
begin
//Prepararse;
result := inherited asVB;
end;

function TVarDef_PS.asFecha: TFecha;
begin
//Prepararse;
result := inherited asFecha;
end;}

//---------------------
//Metodos de TVarDef_PB
//=====================

constructor TVarDef_PB.Create(cosa : Pointer ; const xnombre, xunidades: string ; Ppd : Pointer ; variable : PBoolean);
begin
	inherited CreatePpd(cosa, xnombre, xunidades, variable, Ppd);
end;

{function TVarDef_PB.asS: String;
begin
//Prepararse;
result := inherited asS;
end;

function TVarDef_PB.asNR: NReal;
begin
//Prepararse;
result := inherited asNR;
end;

function TVarDef_PB.asNI: integer;
begin
//Prepararse;
result := inherited asNI;
end;

function TVarDef_PB.asVR: TDAOfNReal;
begin
//Prepararse;
result := inherited asVR;
end;

function TVarDef_PB.asVI: TDAOFNInt;
begin
//Prepararse;
result := inherited asVI;
end;

function TVarDef_PB.asB: boolean;
begin
//Prepararse;
result := inherited asB;
end;

function TVarDef_PB.asVB: TDAOfBoolean;
begin
//Prepararse;
result := inherited asVB;
end;

function TVarDef_PB.asFecha: TFecha;
begin
//Prepararse;
result := inherited asFecha;
end;}

//-------------------------
//Metodos de TVarDef_PFecha
//=========================

constructor TVarDef_PFecha.Create(cosa : Pointer ; const xnombre: string ; Ppd : Pointer ; variable : PFecha);
begin
	inherited CreatePpd(cosa, xnombre, strSinUnidad, variable, Ppd);
end;

{function TVarDef_PFecha.asS: String;
begin
//Prepararse;
result := inherited asS;
end;

function TVarDef_PFecha.asNR: NReal;
begin
//Prepararse;
result := inherited asNR;
end;

function TVarDef_PFecha.asNI: integer;
begin
//Prepararse;
result := inherited asNI;
end;

function TVarDef_PFecha.asVR: TDAOfNReal;
begin
//Prepararse;
result := inherited asVR;
end;

function TVarDef_PFecha.asVI: TDAOFNInt;
begin
//Prepararse;
result := inherited asVI;
end;

function TVarDef_PFecha.asB: boolean;
begin
//Prepararse;
result := inherited asB;
end;

function TVarDef_PFecha.asVB: TDAOfBoolean;
begin
//Prepararse;
result := inherited asVB;
end;

function TVarDef_PFecha.asFecha: TFecha;
begin
//Prepararse;
result := inherited asFecha;
end;}

//-----------------------
//Metodos de TVarDef_PVNR
//=======================

constructor TVarDef_PVNR.Create(cosa: Pointer; const xnombre, xunidades: string;
                                precision, decimales: Integer; Ppd: Pointer;
                                variable: PTDAOfNReal;
                                usarNomenclaturaPorPoste: boolean);
begin
	inherited CreatePpd(cosa, xnombre, xunidades, variable, Ppd);
  self.precision:= precision;
  self.decimales:= decimales;
  self.usarNomenclaturaPorPoste:= usarNomenclaturaPorPoste;
end;

//-----------------------
//Metodos de TVarDef_PVNI
//=======================

constructor TVarDef_PVNI.Create(cosa: Pointer; const xnombre, xunidades: string;
                                Ppd: Pointer; variable: PTDAOfNInt;
                                usarNomenclaturaPorPoste: boolean);
begin
	inherited CreatePpd(cosa, xnombre, xunidades, variable, Ppd);
  self.usarNomenclaturaPorPoste:= usarNomenclaturaPorPoste;
end;

//----------------------
//Metodos de TVarDef_PVB
//======================

constructor TVarDef_PVB.Create(cosa: Pointer; const xnombre, xunidades: string;
                               Ppd: Pointer; variable: PTDAOfBoolean;
                               usarNomenclaturaPorPoste: boolean);
begin
	inherited CreatePpd(cosa, xnombre, xunidades, variable, Ppd);
  self.usarNomenclaturaPorPoste:= usarNomenclaturaPorPoste;
end;

//------------------------------
//Metodos de TVarDef_TStringList
//==============================

constructor TVarDef_TStringList.Create(cosa : Pointer{^TCosa}; const xnombre, xunidades: string;
                                       variable: PTStringList; usarNomenclaturaPorPoste: boolean);
begin
  inherited Create(cosa, xnombre, xunidades, variable);
  self.usarNomenclaturaPorPoste:= usarNomenclaturaPorPoste;
end;

function TVarDef_TStringList.getNombreCosa: String;
var
	cadena : String;
	i, n : Integer;
begin
  n:= PTStringList(pVariable)^.Count;
	cadena:= TCosaConNombre(cosa).nombre;
	for i := 1 to n - 1 do
		cadena := cadena + vectorSeparator + TCosaConNombre(cosa).nombre;
	result := cadena;
end;

function TVarDef_TStringList.getUnidades: String;
var
	cadena : String;
	i, n : Integer;
begin
  n:= PTStringList(pVariable)^.Count;
	cadena:= unidades;
	for i := 1 to n - 1 do
		cadena := cadena + vectorSeparator + unidades;
	result := cadena;
end;

function TVarDef_TStringList.getNombreVar : String;
var
	cadena : String;
	i, n : Integer;
begin
  n:= PTStringList(pVariable)^.Count;
	cadena := '';
  if usarNomenclaturaPorPoste then
  begin
    for i := 1 to n - 1 do
      cadena := cadena + nombreVar + '_P' + IntToStr(i) + vectorSeparator;
    cadena := cadena + nombreVar + '_P' + IntToStr(n);
  end
  else
  begin
    for i := 1 to n - 1 do
      cadena := cadena + nombreVar + '[' + IntToStr(i) + ']' + vectorSeparator;
    cadena := cadena + nombreVar + '[' + IntToStr(n) + ']';
  end;
	result := cadena;
end;

function TVarDef_TStringList.getIndicesVars: String;
var
	cadena : String;
	i, n : Integer;
begin
  n:= PTStringList(pVariable)^.Count;
	cadena:= '';
	for i:= 1 to n - 1 do
		cadena:= cadena + IntToStr(i) + vectorSeparator;
	cadena:= cadena + IntToStr(n);
	result:= cadena;
end;

procedure TVarDef_TStringList.getNombreUnidadesNomVarEIndice(var xnombreCosa, xunidades, xnombreVar, xindicesVars: String);
var
	i, n: Integer;
begin
  n:= PTStringList(pVariable)^.Count;
	xnombreCosa := TCosaConNombre(cosa).nombre;
	for i := 1 to n - 1 do
		xnombreCosa:= xnombreCosa + vectorSeparator + TCosaConNombre(cosa).nombre;

	xunidades:= unidades;
	for i:= 1 to n - 1 do
		xunidades:= xunidades + vectorSeparator + unidades;

  if usarNomenclaturaPorPoste then
  begin
    xnombreVar:= nombreVar + '_P1';
    for i:= 1 to n - 1 do
      xnombreVar:= xnombreVar + vectorSeparator + nombreVar + '_P' + IntToStr(i + 1);
  end
  else
  begin
    xnombreVar:= nombreVar + '[1]';
    for i:= 1 to n - 1 do
      xnombreVar:= xnombreVar + vectorSeparator + nombreVar + '[' + IntToStr(i + 1) + ']';
  end;

	xindicesVars:= '1';
	for i:= 1 to n - 1 do
		xindicesVars:= xindicesVars + vectorSeparator + IntToStr(i + 1);
end;

function TVarDef_TStringList.asS: String;
begin
  result:= PTStringList(pVariable)^.DelimitedText;
end;

function TVarDef_TStringList.asNR: NReal;
begin
  Raise Exception.Create('TVarDef_TStringList.asNR: TStringList to NReal no definido');
end;

function TVarDef_TStringList.asNI: integer;
begin
  Raise Exception.Create('TVarDef_TStringList.asNI: TStringList to Integer no definido');
end;

function TVarDef_TStringList.asVR: TDAOfNReal;
var
  i, n: Integer;
  res: TDAofNReal;
begin
  n:= PTStringList(pVariable)^.Count;
  SetLength(res, n);
  for i:= 0 to n - 1 do
    res[i]:= StrToFloat(PTStringList(pVariable)^[i]);
  result:= res;
end;

function TVarDef_TStringList.asVI: TDAOFNInt;
var
  i, n: Integer;
  res: TDAofNInt;
begin
  n:= PTStringList(pVariable)^.Count;
  SetLength(res, n);
  for i:= 0 to n - 1 do
    res[i]:= StrToInt(PTStringList(pVariable)^[i]);
  result:= res;
end;

function TVarDef_TStringList.asB: boolean;
begin
  Raise Exception.Create('TVarDef_TStringList.asB: TStringList to Boolean no definido');
end;

function TVarDef_TStringList.asVB: TDAOfBoolean;
var
  i, n: Integer;
  res: TDAOfBoolean;
begin
  n:= PTStringList(pVariable)^.Count;
  SetLength(res, n);
  for i:= 0 to n - 1 do
    res[i]:= StrToBool(PTStringList(pVariable)^[i]);
  result:= res;
end;

function TVarDef_TStringList.asFecha: TFecha;
begin
  Raise Exception.Create('TVarDef_TStringList.asFecha: TStringList to TFecha no definido');
end;

function TVarDef_TStringList.asS(indice : Integer): String;
begin
  result:= PTStringList(pVariable)^[indice];
end;

function TVarDef_TStringList.asNR(indice : Integer): NReal;
begin
  result:= StrToFloat(PTStringList(pVariable)^[indice]);
end;

function TVarDef_TStringList.asNI(indice : Integer): integer;
begin
  result:= StrToInt(PTStringList(pVariable)^[indice]);
end;

function TVarDef_TStringList.asVR(indice : Integer): TDAOfNReal;
var
  res: TDAofNReal;
begin
  SetLength(res, 1);
  res[0]:= StrToFloat(PTStringList(pVariable)^[indice]);
  result:= res;
end;

function TVarDef_TStringList.asVI(indice : Integer): TDAOFNInt;
var
  res: TDAofNInt;
begin
  SetLength(res, 1);
  res[0]:= StrToInt(PTStringList(pVariable)^[indice]);
  result:= res;
end;

function TVarDef_TStringList.asB(indice : Integer): boolean;
begin
  result:= StrToBool(PTStringList(pVariable)^[indice]);
end;

function TVarDef_TStringList.asVB(indice : Integer): TDAOfBoolean;
var
  res: TDAOfBoolean;
begin
  SetLength(res, 1);
  res[0]:= StrToBool(PTStringList(pVariable)^[indice]);
  result:= res;
end;

function TVarDef_TStringList.asFecha(indice : Integer): TFecha;
begin
  result:= TFecha.Create_Str(PTStringList(pVariable)^[indice]);
end;

function TVarDef_TStringList.CountVarDef : Integer;
begin
  result:= PTStringList(pVariable)^.Count;
end;

procedure TVarDef_TStringList.setValorFromStringPersistida(const valor: String);
begin
  if PTStringList(pVariable)^ <> NIL then
    PTStringList(pVariable)^.Free;
  parseStringList(PTStringList(pVariable)^, valor);
end;

function TVarDef_TStringList.getValorAsStringPersistible: String;
begin
  result:= TStringListToString(PTStringList(pVariable)^, ', ');
end;

procedure TVarDef_TStringList.setValor(valor: TStringList);
begin
  if PTStringList(pVariable)^ <> NIL then
    PTStringList(pVariable)^.Free;
  PTStringList(pVariable)^:= valor;
end;

//------------------------
//Metodos de TListaVarDefs
//========================

function TListaVarDefs.find(const nombreVar : String; var pos : Integer) : boolean;
var
	i : Integer;
begin
	pos := -1;
	for i := 0 to Count - 1 do
		if TVarDef(items[i]).nombreVar = nombreVar then
  	begin
			pos := i;
			break;
		end;
	result := pos <> -1;
end;

function TListaVarDefs.find(const nombreVar : String): TVarDef;
var
	i : Integer;
  res: TVarDef;
begin
	res:= NIL;
	for i := 0 to Count - 1 do
		if TVarDef(items[i]).nombreVar = nombreVar then
		begin
			res:= TVarDef(items[i]);
			break;
		end;
	result:= res;
end;

procedure TListaVarDefs.setValorFromStringPersistida(const nombreVar, valor: String);
begin
  find(nombreVar).valStrPersistible:= valor;
end;

function TListaVarDefs.getValorStrPersistible(const nombreVar: String): String;
begin
  result:= find(nombreVar).valStrPersistible;
end;

procedure TListaVarDefs.Free;
var
	i : Integer;
begin
	for i := 0 to Count -1 do
		TVarDef(items[i]).Free;
	inherited Free;
end;

end.
