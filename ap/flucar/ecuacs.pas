{+doc
+NOMBRE: ECUACS
+CREACION:16.6.93
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Definicion del objeto ecuacion.
+PROYECTO: Flujo de Carga (001), ANII-FSE18-2009

+REVISION:
17.2.97 proyecto flucar Vignolo y Petruchelli
Marzo 2011 proyecto Mejoras SimSEE.

+AUTOR:
+DESCRIPCION:
-doc}

unit ecuacs;

interface

uses
  Classes,
  links,
  AlgebraC, MatCPX,
  xmatDefs,
  uSortedList;

type
  TipoDeEcuacion = (E_NODO, E_CORTE, E_RELTEN);

type

  // representa un coeficinete en una ecuación.
  // Factor es el valor del coeficiente. Indice es el número de columna
  // en la ecuación. Indice puede tomar valores de 1 a N siendo N la cantidad
  // de columnas del sistema de ecuaciones.
  TCoef = class
    Indice: integer;
    Factor: NComplex;
    constructor Create(xIndice: integer; xfactor: NComplex);
    procedure Free; virtual;
    procedure acum(xc: NComplex);

    // lo ideal es no llamar este procedimiento sino llamar al borrar(k) de la
    // ecuación lo que libera el coeficiente en lugar de solo anularlo.
    procedure borrar_anulando; { factor := 0 }

    procedure AcumCalc(var Resultado: NComplex; var X: TVectComplex );
    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;
  end;


  // Ficha de distribución a ecuación de CORTE.
  // "nec" es la ecuación que debe recibir la modificación y "Factor" es el
  // factor de distribución a aplicar.
  TFDistCorte = class
    nec:    integer;
    Factor: NComplex;
    constructor Create(xNEc: integer; xFactor: NComplex);
    constructor load(var s: TStream);
    procedure Store(var s: TStream);
  end;


  // represent una ecuación del tipo y = SUM( c[i] * x[i] ; i = 1 .. N ) + Cte
  // cada c[i] es del tipo TCoef.
  // la ecuación está almacenada en forma "dispersa". Solamente están creados
  // los coeficientes no nulos.
  TEcuacion = class(TSortedList)
    Constante: NComplex;

    { señala el indice diagonal. Es el número de FILA en un sistema }
    idxPrincipal: integer;

    tdec:     TipoDeEcuacion; // E_NODO, E_CORTE o E_RELTEN
    fd_corte: TFDistCorte;  // si <>nil la ec está acumulada en un corte

    constructor Create;

    procedure Acumular_(kindice: integer; xsum: NComplex);
    procedure AcumularConstante_(xsum: NComplex);

    // retorna TRUE si el coeficiente existe y en ResCoef el valor del coeficiente
    // si retorna FALSE, en ResCoef retorna 0 (Cero).
    function ValCoef(var ResCoef: NComplex; kindice: integer): boolean;

    // retorna el valor del coeficiente Constante.
    procedure ValCte(var ResCte: NComplex);

    procedure BorrarCoef(kindice: integer);
    procedure BorrarConstante;
    procedure BorrarTodo;

    // retorna Resultado = SUM( c[i] * x[i] ; i = 1 .. N ) + Cte
    procedure CalcNC(var Resultado: NComplex; var X: TVectComplex );

    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;


    { mayor indice de variable involucrado }
    function MaxIndVar: integer;
    function KeyOf(Item: Pointer): Pointer; override;
    function Compare(Key1, Key2: Pointer): integer; override;

    procedure Free;
  end;




function EliminarVariable(var EcDestino, EcEliminadora: TEcuacion;
  kIndVar: integer): integer;

procedure CombinarEcuaciones(var EcDestino, EcOrigen: TEcuacion; mult: NComplex);


implementation

{ metodos de TFDistCorte }
constructor TFDistCorte.Create(xNEc: integer; xFactor: NComplex);
begin
  inherited Create;
  nec    := xnec;
  factor := xfactor;
end;

constructor TFDistCorte.Load(var s: TStream);
begin
  s.Read(nec, SizeOf(nec));
  s.Read(factor, SizeOf(factor));
end;

procedure TFDistCorte.Store(var s: TStream);
begin
  s.Write(nec, SizeOf(nec));
  s.Write(factor, SizeOf(factor));
end;


{+doc Suma a la ecuacion (EcDestino) la ecuacion (EcOrigen) multiplicada
por el multiplicador (mult) }
procedure CombinarEcuaciones(var EcDestino, EcOrigen: TEcuacion; mult: NComplex);
{-doc}
  procedure CombinarCo(p: pointer);
  begin
    EcDestino.Acumular_(TCoef(p).Indice, pc(TCoef(p).Factor, mult)^);
  end;

var
  k: integer;
begin

  for k := 0 to EcOrigen.Count - 1 do
    combinarco(EcOrigen.items[k]);

  EcDestino.Constante :=
    sc(EcDestino.Constante, pc(EcOrigen.Constante, mult)^)^;
end;




function EliminarVariable(var EcDestino, EcEliminadora: TEcuacion;
  kIndVar: integer): integer;
var
  mk, mult: NComplex;
begin
  if EcEliminadora.ValCoef(mk, kIndVar) then
    if not EsCero(mod2(mk)) then
      if EcDestino.ValCoef(mult, kIndVar) then
      begin
        mult := prc(-1, dc(mult, mk)^)^;
        CombinarEcuaciones(EcDestino, EcEliminadora, mult);
        EliminarVariable := 0;
        EcDestino.BorrarCoef(kIndVar);
      end
      else
        EliminarVariable := 0
    else
      EliminarVariable   := -2
  else
    EliminarVariable := -1;
end;




{+doc ------------ Metodos de TCoef-----------------------
  TCoef. Clase de Coeficientes complejos. Un coeficiente es un
  =====  factor complejo asociado a una variable compleja.
-doc}

{+doc}
constructor TCoef.Create(xIndice: integer; xfactor: NComplex);
{ (xIndice), es el identificador de la varible asociada al coeficiente.
  (xFactor), es el valor del coeficiente propiamente dicho.
-doc}
begin
  inherited Create;
  Indice := xIndice;
  Factor := xFactor;
end;

{+doc}
procedure TCoef.Free;
{ No hace nada especial,
-doc}

begin
  inherited Free;
end;

{+doc}
procedure TCoef.acum(xc: NComplex);
{ Efecto: ( factor:= factor + xc )
-doc}
begin
  Factor.r := Factor.r + xc.r;
  Factor.i := Factor.i + xc.i;
end;

{+doc}
procedure TCoef.borrar_anulando;
{ Efecto: (factor:= 0)
-doc}
begin
  Factor.r := 0;
  Factor.i := 0;
end;

{+doc}
procedure TCoef.AcumCalc(var Resultado: NComplex; var X: TVectComplex );
{ Resultado:= Resultado + Factor * VariableAsociada
-doc}
begin
  Resultado := sc(Resultado, pc(Factor, X.pte( indice )^)^)^;
end;

{+doc}
constructor TCoef.Load(var S: TStream);
{ standar
-doc}
begin
  S.Read(Indice, SIzeOf(Indice));
  S.Read(Factor, SIzeOf(Factor));
end;

{+doc}
procedure TCoef.Store(var S: TStream);
{ standar
-doc}
begin
  S.Write(Indice, SIzeOf(Indice));
  S.Write(Factor, SIzeOf(Factor));
end;

{+doc  ---------------  Metodos de TEcuacion ---------------------
  TEcuacion. Es un objeto que implementa una ecuacion como una lista
  de coeficientes.
-doc}

{+doc}
constructor TEcuacion.Create;
{ Se inicializa sin coeficientes. El termino constante se inicializa
a 0.
-doc}
begin
  inherited Create;
  Constante := complex_nulo;
  tdec      := E_NODO;
  fd_Corte:= nil;
end;


procedure TEcuacion.Free;
begin
  borrarTodo;
  if fd_corte <> nil then fd_corte.Free;
  inherited Free;
end;


{+doc}
function TEcuacion.KeyOf(Item: Pointer): Pointer;
{ retorna la direccion del campo (Indice) del coeficiente  apuntado
por Item.
-doc}
begin
  KeyOf := @TCoef(Item).Indice;
end;


{+doc}
function TEcuacion.Compare(Key1, Key2: Pointer): integer;
{ Permite ordenar los coeficientes de una ecuacion por orden creciente
de las varibles asociadas a los mismos. (Key1 y Key2) seran resultados
de llamadas a (KeyOf) y por lo tanto son punteros a objetos del tipo
integer. El resultado es (-1) si el integer apuntado por Key1 es mayor
que el apuntado por Key2, es (0) si es iguales y (+1) si es menor.
-doc}
begin
  if integer(Key1^) < integer(Key2^) then
    Compare := -1
  else if integer(Key1^) = integer(Key2^) then
    Compare := 0
  else
    Compare := 1;
end;



procedure TEcuacion.AcumularConstante_(xsum: NComplex);
begin
  constante := sc(constante, xsum)^;
end;

{+doc}
procedure TEcuacion.Acumular_(kindice: integer; xsum: NComplex);
{ Acumula (xFactor) en el coeficiete asociado a la variable de indice
(kindice). Primero se busca el coeficiente asociado a (kindice), si
no se encuentra se agrega.
enero 2012, agrego que si da CERO elimine el coeficiente.
también agrego que si xFactor es cero no haga nada
-doc}
var
  p: TCoef;
  k: integer;
begin
  if EsCero( xsum ) then exit;

  if kindice = 0 then
    AcumularConstante_(xsum)
  else
  begin
    if sorted_Search(@kindice, k) then
    begin
      p := items[k];
      p.acum(xsum);
      if EsCero(p.Factor) then
      begin
        p.Free;
        Delete(k);
      end;
    end
    else
    begin
      p := TCoef.Create(kindice, xsum );
      insert(k, p);
    end;
  end;
end;


{+doc Devuelve en ResCoef, el valor del coeficiente asociado a la
variable con indice (kindice). El resultado de la funcion es (true)
cuando la ecuación disponía de un coeficiente para esa variable y es
(false) cuando no. En cualquiera de los casos el valor devuelto en
(ResCoef) es el correcto. El resultado de la funcion puede usarse
para saber si el valor del coeficiente es un CERO absoluto por no
existir directamente en la ecuacion }
function TEcuacion.ValCoef(var ResCoef: NComplex; kindice: integer): boolean;
  {-doc}

var
  k: integer;
begin
  if sorted_Search(@kindice, k) then
  begin
    ValCoef := True;
    ResCoef := TCoef(items[k]).Factor;
  end
  else
  begin
    ValCoef := False;
    ResCoef := complex_nulo;
  end;
end;

procedure TEcuacion.ValCte(var ResCte: NComplex);

begin
  ResCte := Constante;
end;

{+doc}
procedure TEcuacion.BorrarCoef(kindice: integer);
{ Borra el coeficiente de la ecuacíon. Significa poner el coeficiente
en CERO }
var
  k: integer;
begin
  if sorted_Search(@kindice, k) then
  begin
    TCoef(items[k]).Free;
    Delete(k);
  end;
end;

procedure TEcuacion.BorrarConstante;

begin
  Constante := complex_nulo;
end;


{+doc}
procedure TEcuacion.BorrarTodo;
{ Pone todos los coeficientes a CERO incluyendo el termino constante
NO AFECTA LOS DEMAS PARAMETROS DE LA ECUACION, tales como el indice
principal, el tipo de ecuacion y la lista de distribucion}
var
  k: integer;
begin
  for k := 0 to Count - 1 do
    TCoef(items[k]).Free;
  Clear;
  constante := Complex_nulo;
end;


{+doc}
procedure TEcuacion.CalcNC(var Resultado: NComplex; var X: TVectComplex );
{ Calcula la suma de los productos de los coeficientes de la ecuacion por
el valor de sus respectivas variables asociadas y le suma la campo (Constante)
  Calc := sumatoria( factores*varibles ) + Constante
-doc}
var
  tmp: NComplex;

  procedure Agregar(p: pointer); far;
  begin
    TCoef(p).AcumCalc(tmp, X );
  end;

var
  k: integer;

begin
  tmp := Constante;
  for k := 0 to Count - 1 do
    Agregar(items[k]);
  Resultado := tmp;
end;




{+doc}
constructor TEcuacion.Load(var S: TStream);
  {-doc}
var
  n, k: integer;
begin
  inherited Create;
  S.Read(Constante, SizeOf(Constante));
  S.Read(n, sizeof(n));
  for k := 0 to n - 1 do
    add(TCoef.Load(S));

end;

{+doc}
procedure TEcuacion.Store(var S: TStream);
{-doc}
var
  k, n: integer;
begin
  S.Write(Constante, SizeOf(Constante));
  n := Count;
  S.Write(n, sizeof(n));
  for k := 0 to n - 1 do
    TCoef(items[k]).Store(S);
end;


{ mayor indice de variable involucrado }
function TEcuacion.MaxIndVar: integer;
begin
  MaxIndVar := TCoef(Items[Count - 1]).Indice;
end;



end.

