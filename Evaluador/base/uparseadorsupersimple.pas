unit uparseadorsupersimple;

(***  la intención es tener un parseador super-simple de expresiones
   que permitea identificar las referencias a una casilla en un Libro de cálculo.
****)
{$mode delphi}

interface

uses
  Classes, SysUtils;

type
  TTipoToken = (
    TTK_Ninguno, // -- ninguno --
    TTK_Oper, // +, -, *, = etc.
    TTK_Func, // nombre(
    TTK_Apertura, // (
    TTK_Cierre,  // )
    TTk_Array, // nombre[
    TTK_Cierre_Array, // ]
    TTK_Var,   // algun_texto
    TTK_Const_S,  // String, "texto entre comillas"
    TTK_Const_F,   // Float,  1.23
    TTK_Const_I,   // Integer, Constante Entera
    TTK_Const_B,  // Boolean, Constante Booleana  0, 1
    TTK_Const_D  // double represnta fecha como TDateTime de pascal.
    );




type
  TTokensLst = class(TList)
    procedure writeln; // solo para debug, lista los tokens Tipo ; valor
    procedure Free;
  end;

  TNodoToken = class
    tipo: TTipoToken;
    val: string;
    constructor Create(xTipo: TTipoToken; xVal: string);
  end;

type
  TExprRes = record
    case tipo: char of
      'B': (val_B: boolean);
      'I': (val_I: integer);
      'F': (val_F: double);
      'S': (val_S: shortstring);
      'D': (val_D: TDateTime);
  end;


  TExpresion = class
    val: TExprRes;
    procedure evaluar; virtual;
    // Retorna la versión serializada de la expresión.
    function Serialize: string; virtual; abstract;

    function ValAsStr: string;
    function ValAsFloat: extended;
    function ValAsInt: integer;
    function ValAsBool: boolean;

    // debe ser sobrescrito en cada clase descendiente
    //   class function Simbolo: string; virtual; abstract;
  end;

  TExprLst = class(TExpresion)
    lst: TList;
    constructor Create;
    procedure add(aExpr: TExpresion);
    procedure evaluar; override;
    function Serialize: string; override;
    procedure Free;

  private
    function GetExpr(const i: longint): TExpresion;
  public
    property Items[i: longint]: TExpresion read GetExpr; default;
  end;

  TExprInt = class(TExpresion)
  end;

  TExprNum = class(TExpresion)
  end;

  TExprStr = class(TExpresion)
  end;

  TConst_I = class(TExprInt)
    constructor Create(valorInicial: integer);
    function Serialize: string; override;
    //   class function Simbolo: string; override; // debe ser sobrescrito en cada clase descendiente
  end;

  TConst_F = class(TExprNum)
    constructor Create(valorInicial: double);
    function Serialize: string; override;
    //   class function Simbolo: string; override; // debe ser sobrescrito en cada clase descendiente
  end;


  TConst_B = class(TExpresion)
    constructor Create(valorInicial: boolean);
    function Serialize: string; override;
  end;

  TConst_D = class(TExpresion)
    constructor Create(valorInicial: TDateTime);
    function Serialize: string; override;
  end;

  TConst_S = class(TExprStr)
    constructor Create(valorInicial: string);
    function Serialize: string; override;
    //    class function Simbolo: string; override; // debe ser sobrescrito en cada clase descendiente
  end;


  TVar = class(TExpresion)
    id: string;
    constructor Create(id: string; valorInicial: double);
    function Serialize: string; override;
    //    class function Simbolo: string; override; // debe ser sobrescrito en cada clase descendiente
  end;



  { Esta clase permite definir el PROTOTIPO de un OPERADOR }
  TOperProcDef = class
    nombre: shortstring;
    tiposSalidas: shortstring;
    tiposEntradas: shortstring;
    procedure evaluar(salida: TExpresion; entradas: TExprLst); virtual;
    constructor Create(xNombre, xTiposSalidas, xTiposEntradas: shortstring);
  end;


  { TOperProc }

  TOperProc = class(TExpresion)
    template: TOperProcDef;
    parametros: TExprLst;
    constructor Create(template: TOperProcDef; parametros: TExprLst);
    procedure evaluar; override;
    function Serialize: string; override;
  end;


  { TEvaluadorExpresionesSimples }
  TEvaluadorExpresionesSimples = class
    CatalogoOperadoresBinomicos: TList;
    CatalogoFuncionesEstandar: TList;
    CatalogoFuncionesDeUsuario: TList;
    CatalogoVariables: TList;

    function tokenParser(s: string): TTokensLst;
    function TipoTokenName(tipo: TTipoToken): string;

    // Crea una expresión a partir de la lista de tokens.
    // vacía la lista de tokens.
    // retorna nil si la lista es vacía.
    function GetFullExpresion(var tokens: TTokensLst): TExpresion;

    // funciones de búsqueda en los catálogos
    function FindFuncDef(nombreFunc: string): TOperProcDef;
    function FindOperDef(nombreOper: string): TOperProcDef;

    function Ejecutar(str: string): double;

    function FindVar(var_id: string): TVar;

    function CrearExprFunc(nombreFunc: shortString; parametros: TExprLst): TExpresion;
    function CrearExprOperBi(nombreOper: shortString; a, b: TExpresion): TExpresion;
    constructor Create(auto_regsitrar_basicas: boolean = True);
    procedure Free;

    // Para ejecutar repetida veces el mismo scrtip puede llamar
    // aScript:= GetExprLst( str ) y luego ejecutar aScript.evaluar;
    function GetExprLst(str: string): TExprLst;

    function Evaluar(var res: double; const str: string): boolean; overload;
    function Evaluar(var res: integer; const str: string): boolean; overload;
    function Evaluar(var res: boolean; const str: string): boolean; overload;
    function Evaluar(var res: string; const str: string): boolean; overload;

  private
    // Evalua una serie de sentencias (str) y retorna la  Expresion evaluada
    // correspondiente a la última de las sentencias.
    function Evaluar(const str: string): TExpresion;

    function GetNextExpresion(var tokens: TTokensLst): TExpresion;

    function GetNextToken(var tokens: TTokensLst): TNodoToken;
  end;



function TipoTokenToStr(tipo: TTipoToken): string;

// busca el ";" como serparador de sentencias
function next_sentencia(var s: string): string;


implementation

uses
  uoperadoresbinomicosbasicos,
  ufuncionesbasicas;

const
  Separadores = [#0..' ', '(', '+', '-', '*', ')', '%', '>', '=',
    '<', '/', '^', ',', ';', ':', '[', ']'];
  DigitosYPunto = ['0'..'9', '.'];

function TipoTokenToStr(tipo: TTipoToken): string;
begin
  case tipo of
    TTK_Ninguno: Result := 'Ninguno';
    TTK_Oper: Result := 'Operador';
    TTK_Func: Result := 'Función';
    TTK_Apertura: Result := 'Apertura_(';
    TTK_Cierre: Result := ')_Cierre';
    TTk_Array: Result := 'Array_[';
    TTK_Cierre_Array: Result := ']_Array';
    TTK_Var: Result := 'Var';
    TTK_Const_S: Result := 'Const_S';
    TTK_Const_F: Result := 'Const_F';
    TTK_Const_I: Result := 'Const_I';
    TTK_Const_B: Result := 'Const_B';
    TTK_Const_D: Result := 'Const_D';
    else
      raise Exception.Create('Tipo Token desconocido: ' + IntToStr(Ord(tipo)));
  end;
end;


procedure TExpresion.evaluar;
begin
  // Nada, pero lo defino para que no quede sin definir.
end;

function TExpresion.ValAsStr: string;
begin
  case val.tipo of
    'B': if val.val_B then
        Result := '1'
      else
        Result := '0';
    'I': Result := IntToStr(val.val_I);
    'F': Result := FloatToStr(val.val_F);
    'S': Result := val.val_S;
    'D': Result := DateTimeToStr(val.val_D);
  end;
end;

function TExpresion.ValAsFloat: extended;
begin
  case val.tipo of
    'B': if val.val_B then
        Result := 1
      else
        Result := 0;
    'I': Result := val.val_I;
    'F': Result := val.val_F;
    'S': Result := StrToFloat(val.val_S);
    'D': Result := double(val.val_D);
  end;
end;

function TExpresion.ValAsInt: integer;
begin
  case val.tipo of
    'B': if val.val_B then
        Result := 1
      else
        Result := 0;
    'I': Result := val.val_I;
    'F': Result := round(val.val_F);
    'S': Result := StrToInt(val.val_S);
    'D': Result := round(val.val_D);
  end;
end;

function TExpresion.ValAsBool: boolean;
var
  c: char;
begin
  case val.tipo of
    'B': Result := val.val_B;
    'I': Result := val.val_I <> 0;
    'F': Result := val.val_F <> 0;
    'S':
    begin
      if length(val.val_S) > 0 then
      begin
        c := upCase(val.val_S[1]);
        Result := c in ['1', 'V', 'T'];
      end
      else
        Result := False;
    end;
    'D': Result := double(val.val_D) <> 0;
  end;
end;



constructor TOperProcDef.Create(xNombre, xTiposSalidas, xTiposEntradas: shortstring);
begin
  inherited Create;
  nombre := xNombre;
  tiposSalidas := xTiposSalidas;
  tiposEntradas := xTiposEntradas;
end;


procedure TOperProcDef.evaluar(salida: TExpresion; entradas: TExprLst);
begin
  // Nada
end;

procedure TTokensLst.writeln; // solo para debug, lista los tokens Tipo ; valor
var
  k: integer;
  nodo: TNodoToken;
begin
  for k := 0 to Count - 1 do
  begin
    nodo := items[k];
    system.writeln(nodo.tipo: 4, '; ', nodo.val);
  end;
end;

procedure TTokensLst.Free;
var
  k: integer;
  nodo: TNodoToken;
begin
  for k := 0 to Count - 1 do
  begin
    nodo := items[k];
    nodo.Free;
  end;
  inherited Free;
end;



function TEvaluadorExpresionesSimples.TipoTokenName(tipo: TTipoToken): string;
begin
  case tipo of
    TTK_Ninguno: Result := 'Ninguno';
    TTK_Oper: Result := 'Operador';
    TTK_Func: Result := 'Función';
    TTk_Array: Result := 'Array';
    TTK_Apertura: Result := 'Apertura';
    TTK_Cierre: Result := 'Cierre';
    TTK_Cierre_Array: Result := 'Cierre_Array';
    TTK_Var: Result := 'Var';
    TTK_Const_S: Result := 'String';
    TTK_Const_F: Result := 'Float';
    TTK_Const_I: Result := 'Integer';
    TTK_Const_B: Result := 'Boolean';
  end;
end;

constructor TNodoToken.Create(xTipo: TTipoToken; xVal: string);
begin
  inherited Create;
  tipo := xTipo;
  val := xval;
end;

function nextToken(var s: string): TNodoToken;
var
  i: integer;
  c: char;
  buscando: boolean;
  res: string;
  tipoToken: TTipoToken;

begin
  s := trim(s);
  if length(s) = 0 then
  begin
    Result := nil;
    exit;
  end;

  c := s[1];
  if c in Separadores then
  begin
    res := c;
    Delete(s, 1, 1);
    case c of
      '(': tipoToken := TTK_Apertura;
      ')': tipoToken := TTK_Cierre;
      ']': tipoToken := TTK_Cierre_Array;
      else
      begin
        if (c = ':') and (length(s) > 0) and
          (s[1] = '=') then
        begin
          res := res + '=';
          Delete(s, 1, 1);
        end;
        tipoToken := TTK_Oper;
      end;
    end;
    Result := TNodoToken.Create(tipoToken, res);
    exit;
  end;

  // Detectamdos si empieza constante encomillada.
  if c = '"' then
  begin
    Delete(s, 1, 1);
    i := pos('"', s);
    if i = 0 then
      raise Exception.Create('Error ... comilla abierta pero no cerrada!( "' + s);
    res := copy(s, 1, i - 1);
    Delete(s, 1, i);
    s := trim(s);
    tipoToken := TTK_Const_S;
    Result := TNodoToken.Create(tipoToken, res);
    exit;
  end;

  // Si llegamos aquí comienza o un identificador o una constante numérica
  res := c;
  i := 2;
  buscando := True;
  while (i <= length(s)) and buscando do
  begin
    c := s[i];
    if ( c in Separadores ) and
      not (
        ( i>2)
         AND ( ((c='+')or(c='-')) and (UpperCase(s[i-1]) ='E'))) then
    begin
      case c of
        '(':
        begin
          tipoToken := TTK_Func;
          Inc(i);
        end;
        '[':
        begin
          tipoToken := TTK_Array;
          Inc(i);
        end;
        else
          if res[1] in DigitosYPunto then
            if ( pos('.', res) > 0 )
              or ( pos('e', res ) > 1 )
              or ( pos('E', res) > 1) then
              tipoToken := TTK_Const_F
            else if (length(res) = 1) and ((res[1] = '0') or (res[1] = '1')) then
              tipoToken := TTK_Const_B
            else
              tipoToken := TTK_Const_I
          else
            tipoToken := TTK_Var;
      end;
      buscando := False;
    end
    else
    begin
      res := res + c;
      Inc(i);
    end;
  end;

  if buscando then
  begin
    s := '';
    if res[1] in DigitosYPunto then
      if ( pos('.', res) > 0 )
              or ( pos('e', res ) > 1 )
              or ( pos('E', res) > 1) then
        tipoToken := TTK_Const_F
      else if (length(res) = 1) and ((res[1] = '0') or (res[1] = '1')) then
        tipoToken := TTK_Const_B
      else
        tipoToken := TTK_Const_I
    else
      tipoToken := TTK_Var;
  end
  else
    Delete(s, 1, i - 1);

  Result := TNodoToken.Create(tipoToken, res);
end;




constructor TEvaluadorExpresionesSimples.Create(auto_regsitrar_basicas: boolean);
begin
  inherited Create;
  CatalogoOperadoresBinomicos := TList.Create;
  CatalogoFuncionesEstandar := TList.Create;
  CatalogoFuncionesDeUsuario := TList.Create;
  CatalogoVariables := TList.Create;
  if auto_regsitrar_basicas then
  begin
    AgregarOperadoresBinomicos(self);
    AgregarFunciones(self);
  end;
end;

procedure TEvaluadorExpresionesSimples.Free;
begin

  // POR HACER.


  inherited Free;
end;

function TEvaluadorExpresionesSimples.tokenParser(s: string): TTokensLst;
var
  res: TTokensLst;
  nodo: TNodoToken;
begin
  res := TTokensLst.Create;
  nodo := nextToken(s);
  while nodo <> nil do
  begin
    res.add(nodo);
    nodo := nextToken(s);
  end;
  Result := res;
end;

(**** EXPRESIONES *******)


constructor TExprLst.Create;
begin
  inherited Create;
  lst := TList.Create;
end;

procedure TExprLst.add(aExpr: TExpresion);
begin
  lst.add(aExpr);
end;

procedure TExprLst.evaluar;
var
  k: integer;
  aExp: TExpresion;
begin
  for k := 0 to lst.Count - 1 do
  begin
    aExp := lst[k];
    aExp.evaluar;
  end;
end;

function TExprLst.Serialize: string;
var
  s: string;
  k: integer;
  aExpr: TExpresion;
begin
  s := '';
  for k := 0 to lst.Count - 1 do
  begin
    aExpr := lst[k];
    if k > 0 then
      s := s + ', ';
    s := s + aExpr.Serialize;
  end;
  Result := s;
end;


procedure TExprLst.Free;
var
  k: integer;
  aExp: TExpresion;
begin
  for k := 0 to lst.Count - 1 do
  begin
    aExp := lst[k];
    aExp.Free;
  end;
  inherited Free;
end;


function TExprLst.GetExpr(const i: longint): TExpresion;
begin
  Result := lst[i];
end;


constructor TConst_I.Create(valorInicial: integer);
begin
  inherited Create;
  val.tipo := 'I';
  val.val_I := valorInicial;
end;


function TConst_I.Serialize: string;
begin
  Result := IntToStr(val.val_I);
end;


constructor TConst_F.Create(valorInicial: double);
begin
  inherited Create;
  val.tipo := 'F';
  self.val.val_F := valorInicial;
end;

function TConst_F.Serialize: string;
begin
  Result := FloatToStr(val.val_F);
end;

(*
class function TConst_F.Simbolo: string;
begin
  result:= 'Const_F';
end;
  *)




constructor TConst_B.Create(valorInicial: boolean);
begin
  inherited Create;
  val.tipo := 'B';
  self.val.val_B := valorInicial;
end;

function TConst_B.Serialize: string;
begin
  if val.val_B then
    Result := '1'
  else
    Result := '0';
end;



constructor TConst_D.Create(valorInicial: TDateTime);
begin
  inherited Create;
  val.tipo := 'D';
  self.val.val_D := valorInicial;
end;



function TConst_D.Serialize: string;
begin
  Result := DateTimeToStr(val.val_D);
end;



constructor TConst_S.Create(valorInicial: string);
begin
  inherited Create;
  val.tipo := 'S';
  self.val.val_S := valorInicial;
end;



function TConst_S.Serialize: string;
begin
  Result := val.val_S;
end;


(*
class function TConst_S.Simbolo: string;
begin
  result:= 'Const_S';
end;
  *)

constructor TVar.Create(id: string; valorInicial: double);
begin
  inherited Create;
  self.id := id;
  val.tipo := 'F';
  self.val.val_F := valorInicial;
end;


function TVar.Serialize: string;
begin
  Result := id;
end;


function TEvaluadorExpresionesSimples.FindFuncDef(nombreFunc: string): TOperProcDef;
var
  res: TOperProcDef;
  buscando: boolean;
  k: integer;
begin

  // primero busco entre las definidas por el usuario
  buscando := True;
  k := 0;
  while buscando and (k < CatalogoFuncionesDeUsuario.Count) do
  begin
    res := CatalogoFuncionesDeUsuario.Items[k];
    if res.nombre = nombreFunc then
      buscando := False
    else
      Inc(k);
  end;

  if not buscando then
  begin
    Result := res;
    exit;
  end;


  // si no tuve suerte con las de usuario busco entre las estandar.
  buscando := True;
  k := 0;
  while buscando and (k < CatalogoFuncionesEstandar.Count) do
  begin
    res := CatalogoFuncionesEstandar.Items[k];
    if res.nombre = nombreFunc then
      buscando := False
    else
      Inc(k);
  end;

  if buscando then
    Result := nil
  else
    Result := res;

end;

function TEvaluadorExpresionesSimples.FindOperDef(nombreOper: string): TOperProcDef;
var
  res: TOperProcDef;
  buscando: boolean;
  k: integer;
begin
  buscando := True;
  k := 0;
  while buscando and (k < CatalogoOperadoresBinomicos.Count) do
  begin
    res := CatalogoOperadoresBinomicos.Items[k];
    if res.nombre = nombreOper then
      buscando := False
    else
      Inc(k);
  end;

  if buscando then
    Result := nil
  else
    Result := res;

end;


function TEvaluadorExpresionesSimples.Evaluar( const str: string): TExpresion;
var
  s, st: string;
  tokens: TTokensLst;
  exp: TExpresion;
begin
  exp := nil;
  st := str;
  s := next_sentencia(st);
  while s <> '' do
  begin
    if exp <> nil then
      exp.Free;
    tokens := tokenParser(s);
    exp := GetFullExpresion(tokens);
    tokens.Free;
    exp.evaluar;
    s := next_sentencia(st);
  end;
  result:= exp;
end;


function TEvaluadorExpresionesSimples.Evaluar(var res: double; const str: string): boolean;
var
  exp: TExpresion;
begin
  exp := evaluar( str );
  if exp <> nil then
  begin
    Res := exp.ValAsFloat;
    exp.Free;
    result:= true;
  end
  else
  begin
    Res := -11111111;
    result:= false;
  end;
end;

function TEvaluadorExpresionesSimples.Evaluar(var res: integer;
  const str: string): boolean;
var
  exp: TExpresion;
begin
  exp := evaluar( str );
  if exp <> nil then
  begin
    Res := exp.ValAsInt;
    exp.Free;
    result:= true;
  end
  else
  begin
    Res := -11111111;
    result:= false;
  end;
end;

function TEvaluadorExpresionesSimples.Evaluar(var res: boolean;
  const str: string): boolean;
var
  exp: TExpresion;
begin
  exp := evaluar( str );
  if exp <> nil then
  begin
    Res := exp.ValAsBool;
    exp.Free;
    result:= true;
  end
  else
  begin
    Res := false;
    result:= false;
  end;
end;

function TEvaluadorExpresionesSimples.Evaluar(var res: string; const str: string
  ): boolean;
var
  exp: TExpresion;
begin
  exp := evaluar( str );
  if exp <> nil then
  begin
    Res := exp.ValAsStr;
    exp.Free;
    result:= true;
  end
  else
  begin
    Res := '';
    result:= false;
  end;
end;



function TEvaluadorExpresionesSimples.GetExprLst(str: string): TExprLst;
var
  s, st: string;
  tokens: TTokensLst;
  res: TExprLst;
  exp: TExpresion;
begin
  res:= TExprLst.Create;

  exp := nil;
  st := str;
  s := next_sentencia(st);
  while s <> '' do
  begin
    tokens := tokenParser(s);
    exp := GetFullExpresion(tokens);
    tokens.Free;
    if exp <> nil then
      res.add( exp );
    s := next_sentencia(st);
  end;
  Result:= res;
end;


function TEvaluadorExpresionesSimples.Ejecutar(str: string): double;
var
  s, st: string;
  tokens: TTokensLst;
  exp: TExpresion;
begin
  exp := nil;
  st := str;
  s := next_sentencia(st);
  while s <> '' do
  begin
    if exp <> nil then
      exp.Free;
    tokens := tokenParser(s);
    exp := GetFullExpresion(tokens);
    tokens.Free;
    exp.evaluar;
    s := next_sentencia(st);
  end;

  if exp <> nil then
  begin
    Result := exp.ValAsFloat;
    exp.Free;
  end
  else
    Result := -11111111;
end;




function TEvaluadorExpresionesSimples.FindVar(var_id: string): TVar;
var
  res: TVar;
  buscando: boolean;
  k: integer;
begin
  buscando := True;
  k := 0;
  while buscando and (k < CatalogoVariables.Count) do
  begin
    res := CatalogoVariables.Items[k];
    if res.id = var_id then
      buscando := False
    else
      Inc(k);
  end;

  if buscando then
    Result := nil
  else
    Result := res;

end;



function TEvaluadorExpresionesSimples.CrearExprFunc(nombreFunc: shortString;
  parametros: TExprLst): TExpresion;
var
  aDef: TOperProcDef;
begin
  aDef := FindFuncDef(nombreFunc);
  if aDef = nil then
    raise Exception.Create('No se encuentra: "' + nombreFunc +
      '" en los catálogos de funciones.');
  Result := TOperProc.Create(aDef, parametros);
end;


function TEvaluadorExpresionesSimples.CrearExprOperBi(nombreOper: shortString;
  a, b: TExpresion): TExpresion;
var
  aDef: TOperPRocDef;
  parametros: TExprLst;
begin
  aDef := FindOperDef(nombreOper);
  if aDef = nil then
    raise Exception.Create('No se encuentra: "' + nombreOper +
      '" en el catálogo de operadores.');
  parametros := TExprLst.Create;
  parametros.add(a);
  parametros.add(b);
  Result := TOperProc.Create(aDef, parametros);
end;


function TEvaluadorExpresionesSimples.GetNextToken(var tokens: TTokensLst): TNodoToken;
begin
  if tokens.Count > 0 then
  begin
    Result := tokens[0];
    tokens.Delete(0);
  end
  else
    Result := nil;

end;


// Lee la primer expresión comenzando de la Izquierda.
// retorna NIL si la lista de tokens estaba vacía.
function TEvaluadorExpresionesSimples.GetNextExpresion(
  var tokens: TTokensLst): TExpresion;
var
  aToken: TNodoToken;
  sublst: TTokensLst;
  a: TExpresion;
  cntAperturas: integer;
  nombreOperFunc: string;
  aExprLst: TExpresion;
  buscando: boolean;
  parametros: TExprLst;

begin
  aToken := getNextToken(tokens);
  if aToken = nil then
  begin
    Result := nil;
    exit;
  end;



  case aToken.tipo of
    TTK_Apertura:
    begin
      // Primero me fijo si empieza un paréntesis. Si es así
      // vamos a crear la sublista de tokens del parétnesis y cremos
      // una expresión que lo representa
      aToken.Free;
      aToken := nil;
      cntAperturas := 1;
      buscando := True;
      sublst := TTokensLst.Create;
      while buscando and (tokens.Count > 0) do
      begin
        aToken := getNextToken(tokens);
        case aToken.tipo of
          TTK_Cierre: Dec(cntAperturas);
          TTK_Apertura, TTK_Func: Inc(cntAperturas);
        end;
        if (aToken.tipo = TTK_Cierre) and (cntAperturas = 0) then
          buscando := False
        else
          sublst.add(aToken);
      end;

      if buscando then
        raise Exception.Create('Falta cerrar paréntesis');
      a := GetFullExpresion(sublst);
    end;

    TTK_Func:
    begin
      // hay que leer la lista de parámetros
      NombreOperFunc := aToken.val;
      aToken.Free;
      aToken := nil;

      parametros := TExprLst.Create;

      cntAperturas := 1;
      buscando := True;
      sublst := TTokensLst.Create;
      while buscando and (tokens.Count > 0) do
      begin
        aToken := getNextToken(tokens);

        case aToken.tipo of
          TTK_Cierre: Dec(cntAperturas);
          TTK_Apertura, TTK_Func: Inc(cntAperturas);
        end;

        if (aToken.tipo = TTK_Cierre) and (cntAperturas = 0) then
        begin
          buscando := False;
          if sublst.Count > 0 then
          begin
            aExprLst := GetFullExpresion(sublst);
            parametros.add(aExprLst);
            sublst.Free;
          end;
        end
        else
        begin
          if (aToken.val = ',') and (cntAperturas = 1) then
          begin
            aExprLst := GetFullExpresion(sublst);
            parametros.add(aExprLst);
            sublst.Free;
            sublst := TTokensLst.Create;
          end
          else
            sublst.add(aToken);
        end;

      end;
      if buscando then
        raise Exception.Create('Falta cerrar paréntesis en Func:');
      a := CrearExprFunc(NombreOperFunc, parametros);
    end;

    TTK_Const_B:
      a := TConst_B.Create(StrToBool(aToken.val));

    TTK_Const_D:
      a := TConst_D.Create(StrToInt(aToken.val));

    TTK_Const_I:
      a := TConst_I.Create(StrToInt(aToken.val));
    TTK_Const_F:
      a := TConst_F.Create(StrToFloat(aToken.val));

    TTK_Const_S:
      a := TConst_S.Create(aToken.val);
    TTK_Var:
    begin
      a := FindVar(aToken.val);
      if a = nil then
      begin
        a := TVar.Create(aToken.val, 0);
        CatalogoVariables.Add(a);
      end;
    end;
    TTK_Oper:
      if  ( aToken.val = '-' ) then
      begin
        a:= CrearExprOperBi('-', TConst_I.Create(0), GetNextExpresion( tokens ));
      end
      else  // del case
        raise Exception.Create('OJO; Token tipo OPERADOR: ' +  aToken.Val + '. No impelentado en CASE de GetNextExpresion ');
    else  // del case
      raise Exception.Create('OJO; Token tipo: ' + TipoTokenToStr(
        aToken.Tipo) + '. No impelentado en CASE de GetNextExpresion ');
  end;

  if aToken <> nil then
    aToken.Free;
  Result := a;

end;


function TEvaluadorExpresionesSimples.GetFullExpresion(
  var tokens: TTokensLst): TExpresion;
var
  aToken: TNodoToken;
  a: TExpresion;
  buscando: boolean;
  operLst: TTokensLst;
  terminos: TExprLst;
  kOper: integer;

begin
  if (tokens = nil) or (tokens.Count = 0) then
  begin
    Result := nil;
    exit;
  end;

  operLst := TTokensLst.Create;
  terminos := TExprLst.Create;


  buscando := True;
  while buscando do
  begin
    a := GetNextExpresion(tokens);
    terminos.add(a);
    aToken := getNextToken(tokens);
    if aToken <> nil then
      operLst.Add(aToken)
    else
      buscando := False;
  end;


  // Resolvemos operadores de prioridad 0 (^)
  kOper := 0;
  while kOper < operLst.Count do
  begin
    aToken := operLst[kOper];
    if (aToken.val = '^') then
    begin
      a := CrearExprOperBi(aToken.val, terminos[kOper], terminos[kOper + 1]);
      aToken.Free;
      operLst.Delete(kOper);
      terminos.lst[kOper] := a;
      terminos.lst.Delete(kOper + 1);
    end
    else
      Inc(kOper);
  end;

  // Resolvemos oeradores de prioridad 1 (* y /)
  kOper := 0;
  while kOper < operLst.Count do
  begin
    aToken := operLst[kOper];
    if (aToken.val = '*') or (aToken.val = '/') then
    begin
      a := CrearExprOperBi(aToken.val, terminos[kOper], terminos[kOper + 1]);
      aToken.Free;
      operLst.Delete(kOper);
      terminos.lst[kOper] := a;
      terminos.lst.Delete(kOper + 1);
    end
    else
      Inc(kOper);
  end;

  // Resolvemos los operadores de última prioridad  (+ y -)
  // Salvo el de asignación que lo dejamos al final de todo
  kOper := 0;
  while kOper < operLst.Count do
  begin
    aToken := operLst[kOper];
    if aToken.val <> ':=' then
    begin
      a := CrearExprOperBi(aToken.val, terminos[kOper], terminos[kOper + 1]);
      aToken.Free;
      operLst.Delete(kOper);
      terminos.lst[kOper] := a;
      terminos.lst.Delete(kOper + 1);
    end
    else
      Inc(kOper);
  end;


  // Resolvemos las asignaciones
  kOper := 0;
  while kOper < operLst.Count do
  begin
    aToken := operLst[kOper];
    if aToken.val = ':=' then
    begin
      a := CrearExprOperBi(aToken.val, terminos[kOper], terminos[kOper + 1]);
      aToken.Free;
      operLst.Delete(kOper);
      terminos.lst[kOper] := a;
      terminos.lst.Delete(kOper + 1);
    end
    else
      Inc(kOper);
  end;


  // llegados aquí, la lista de operadores debe estar vacía.
  // y en operLst tiene que haber solo un término.
  assert(operLst.Count = 0, 'Error, operLst.cont <> 0');
  assert(terminos.lst.Count = 1, 'Error, hay más de una expresión en terminos');

  Result := terminos.lst[0];
  operLst.Free;
  terminos.lst.Delete(0);  // antes del Free elimino la referencia al resultado
  terminos.Free;
end;




constructor TOperProc.Create(template: TOperProcDef; parametros: TExprLst);
begin
  inherited Create;
  self.template := template;
  val.tipo := template.tiposSalidas[1];
  self.parametros := parametros;
end;

procedure TOperProc.evaluar;
begin
  parametros.Evaluar;
  template.evaluar(self, parametros);
end;

function TOperProc.Serialize: string;
begin
  Result := template.nombre + '(' + parametros.Serialize + ')';
end;


// busca el ";" como serparador de sentencias
function next_sentencia(var s: string): string;
var
  i: integer;
  res: string;
begin
  i := pos(';', s);
  if i = 0 then
  begin
    Result := trim(s);
    s := '';
  end
  else
  begin
    res := copy(s, 1, i - 1);
    Delete(s, 1, i);
    s := trim(s);
    Result := trim(res);
  end;
end;

end.
