unit uSparseMatReal;
{$mode delphi}

interface

uses
  Classes,
  SysUtils,
  MatReal,
  xMatDefs,
  COMPOL;

type
  TCoeficiente = class
  private
    findice: integer;
    fvalor: NReal;
  public
    property indice: integer read findice write findice;
    property valor: NReal read fvalor write fvalor;

    constructor Create( indice: integer; valor: NReal);
    constructor Create_Clone(x: TCoeficiente);
    //Clona el coeficiente
  end;

  TSparseVectR = class
  private
    //n : Integer; no se usa mas es el capacity de la lista
    //cantNoCeros : Integer; no se usa mas, es el count de la lista
    Coefs: TList; {of TCoeficiente}
    ultimoIter: integer;

    function buscarCoef(k: integer): integer;
    //retorna la posición de la lista donde iría el indice k
    function getCapacity: integer;
    procedure setCapacity(n: integer);
  public
    procedure Igual(x: TSparseVectR);
    constructor Create_Init(ne: integer);
    constructor Create_FromDAofR(a: TDAofNReal);
    constructor Create_Clone(vrx: TSparseVectR);
    procedure Free; virtual;

    constructor Create_Load(var S: TStream);
    procedure Store(var S: TStream);

    function e(k: integer): NReal;
    procedure pon_e(k: integer; x: NReal);
    procedure acum_e(k: integer; x: NReal);

    // copia los valores del vector xv a partir del kini  for k= 0 to high( xv ) do pon_e(ini+k, xv[k] ) ;
    procedure pon_ev(kini: integer; xv: array of NReal);

    function PEV(y: TSparseVectR): NReal;
    function PEVRFLX(y: TSparseVectR): NReal;

    // norma euclidea al cuadrado de la diferencia
    function distancia2(y: TSparseVectR): NReal;

    // norma euclídea de la diferencia
    function distancia(y: TSparseVectR): NReal;

    //Coeficiente de correlación < x[k] * y[k-kdesp] >
    function coefcorr(y: TSparseVectR; kdesp: integer): NReal;

    procedure PorReal(r: NReal);
    procedure sum(y: TSparseVectR);
    procedure sumRPV(r: NReal; x: TSparseVectR);
    function ne2: NReal; {norma euclideana al cuadrado }
    function varianza: NReal; { <pv[k]^2> }
    function normEuclid: NReal;
    function normMaxAbs: NReal;
    function normSumAbs: NReal;
    procedure Copy(var x: TSparseVectR);
    procedure Ceros; virtual;
    procedure MinMax(var kMin, kMax: integer; var Min, Max: NReal);
    procedure Print; virtual;

      { Divide las componetes por la norma obligando al vector a
      tener norma ecuclidea = 1 }
    procedure HacerUnitario;

      (*
      function EstimFrec(
              nivel,          {nivel de compoaracion}
              histeresis: NReal;  {histeresis del cruce }
              AbajoArriba: boolean  {sentido del cruce}
              ): NReal;        {cantidad de cruces}
      *)

    procedure Sort(creciente: boolean);

    // evalua sum( ak * x^(k-1) ; k= 1 a n );
    function rpoly(x: NReal): NReal;

    // evalua sum( ak * x^(k-1) ; k= 1 a n );
    procedure cpoly(var resc: NComplex; xc: NComplex);
    procedure versor_randomico;

    // el indice kr es real y debe estar en el rango 1..n
    function interpol(kr: NReal): NReal;

    // retorna la recta que a*k+b que mejor aproxima al conjunto
    // de puntos del vector en el sentido de mínimos cuadrados
    procedure AproximacionLineal(var a, b: NReal);

    property n: integer read getCapacity write setCapacity;
    property pv[i: integer]: NReal read e write pon_e;
  end;

  TFuncCompare = function(item1, item2: NReal): integer;
  //La función retorna: < 0 si Item1 es menor que Item2
  //                     0 si son iguales
  //                    > 0 si Item1 es mayor que Item2.




  TSparseMatR = class
  public
    nf, nc: integer;
    pm: array of TSparseVectR;
    procedure Igual(x: TSparseMatR);
    procedure Free; virtual;
    constructor Create_Init(filas, columnas: integer);
    constructor Create_Load(var S: TStream);
    constructor Create_Clone(mrx: TSparseMatR);
    procedure Store(var s: TStream);
    function e(k, j: integer): NReal;
    procedure pon_e(k, j: integer; x: NReal);
    procedure acum_e(k, j: integer; x: NReal);

    procedure pon_fila(kfil, jcol: integer; xv: array of NReal);
    procedure pon_columna(kfil, jcol: integer; xv: array of NReal);

    procedure Mult(a, b: TSparseMatR);
    procedure Transformar(var y: TSparseVectR; x: TSparseVectR);
    procedure WriteM;
    constructor Create_ReadM; (* a debe estar sin inicializar *)
    function Traza: NReal;
    function Deter: NReal;
    function Escaler(var i: TSparseMatR; var invertible: boolean;
      var exp10: integer): NReal;
    function Escaler2(var i: TSparseMatR; var invertible: boolean;
      var exp10: integer): NReal;
    procedure PolinomioCaracteristico(var P: TPoliR);
    procedure CopyColVect(var Y: TSparseVectR; J: integer);
    function Inv: boolean;
    procedure Ceros; virtual;
    procedure CerosFila(kfil: integer);
    procedure MinMax(var kMin, jMin: integer; var kMax, jMax: integer;
      var Min, Max: NReal);

    function NormMaxAbs: NReal;

    { OJO esta en desarrollo
    retorna la dimensión del subespacio NULO.
    La matriz deve ser cuadrada (hasta que se revise el algoritmo
    el resultado es la matriz Base, en la cual el conjunto de filas
    forman una base del subespacio nulo de la matriz SELF.
    Si se quiere una base  Ortonormal invocar el método
    Ortonormal en la matriz resultado (base).
    Como ejemplo: CBSENON.PAS.
    LAS FILAS DE Base SON LOS VECTORES DE LA BASE }
    function CalcBSEN(var Base: TSparseMatR): integer;

    { Hace que el conjunto de filas sea una base OROTORMAL,
    el resultado de la función es la dimensión del espacio generado
    por las filas.
    Como ejemplo: CBSENON.PAS
    ORTOGONALIZA LAS FILAS DE LA MATRIZ COMO SI FUERA UNA BASE }
    function OrtoNormal: integer;

    { Calcula una base del subespacio invariante asociado a un autovalor
    real dado
    LAS FILAS DE Base SON LOS VECTORES DE LA BASE }
    function CalcBSE_R(var Base: TSparseMatR; av: NReal): integer;

    { Calcula una base del subespacio invariate asociado a un par de
    autovalores complejos conjugados
    LAS FILAS DE Base SON LOS VECTORES DE LA BASE }
    function CalcBSE_PCC(var Base: TSparseMatR; av: NComplex): integer;

    procedure IntercambieFilas(k1, k2: integer);

    function Fila(k: integer): TSparseVectR;
    function Columna(k: integer): TSparseVectR;
    function transpuesta: TSparseMatR;

    procedure WriteXLT(var f: textfile);
  end;


{************************************
      FUNCIONES DE CONVERSION
 ------------------------------------}
function MatReal_To_CompSparse(M: TMatR): TSparseMatR;
function CompSparse_to_MatReal(M: TSparseMatR): TMatR;



implementation


{************************************
      FUNCIONES DE CONVERSION
 ------------------------------------}

function MatReal_To_CompSparse(M: TMatR): TSparseMatR;
var
  col, fil, k, j: integer;
  MatTemp: TSparseMatR;
begin
  col := M.nc;
  fil := M.nf;
  MatTemp := TSparseMatR.Create_Init(fil, col);
  for k := 1 to fil do
    for j := 1 to col do
      if M.e(k, j) <> 0 then
      begin
        // writeln(k,'   ',j,'   ',M.e(k,j));
        MatTemp.pon_e(k, j, M.e(k, j));
      end;
  Result := MatTemp;
end;

function CompSparse_to_MatReal(M: TSparseMatR): TMatR;
var
  col, fil, i, j: integer;
  MatTemp: TMatR;
begin
  col := M.nc;
  fil := M.nf;
  MatTemp := TMatR.Create_Init(fil, col);
  for i := 1 to fil do
    for j := 1 to col do
      if M.e(i, j) <> 0 then
      begin
        MatTemp.pon_e(i, j, M.e(i, j));
      end;
  Result := MatTemp;
end;

{************************
//Metodos de TCoeficiente
-------------------------}

constructor TCoeficiente.Create(indice: integer; valor: NReal);
begin
  inherited Create;
  findice := indice;
  fvalor := valor;
end;

constructor TCoeficiente.Create_Clone(x: TCoeficiente);
begin
  inherited Create;
  indice := x.indice;
  valor := x.valor;
end;

{*************************
//Meotodos de TSparseVectR
--------------------------}

function TSparseVectR.buscarCoef(k: integer): integer;
var
  i{, pos}: integer;
begin
  if Coefs.Count > 0 then
  begin
    if (ultimoIter >= Coefs.Count) or (TCoeficiente(Coefs[ultimoIter]).indice > k) then
      ultimoIter := 0;
{    pos := -1;
    for i := ultimoIter to Coefs.Count -1 do
      begin
      if TCoeficiente(coefs[i]).indice >= k then
        begin
        pos := i;
        break;
        end;
      end;
    if pos <> -1 then
      begin
      ultimoIter := pos;
      result := pos
      end
    else
      begin
      ultimoIter := Coefs.Count -1;
      result := Coefs.Count
      end
    end   }
    i := ultimoIter;
    while (i < Coefs.Count) and (TCoeficiente(coefs[i]).indice < k) do
      Inc(i);
    if i = Coefs.Count then
      ultimoIter := i - 1
    else
      ultimoIter := i;
    Result := i;
  end
  else
    Result := 0;
end;

function TSparseVectR.getCapacity: integer;
begin
  Result := Coefs.Capacity + 1;
end;

procedure TSparseVectR.setCapacity(n: integer);
begin
  Coefs.Capacity := n;
end;

procedure TSparseVectR.Igual(x: TSparseVectR);
var
  i: integer;
begin
  for i := 0 to Coefs.Count - 1 do
    TCoeficiente(Coefs[i]).Free;
  Coefs.Clear;
  Coefs.Capacity := x.Coefs.Capacity;
  for i := 0 to x.Coefs.Count - 1 do
    Coefs.Add(TCoeficiente.Create_Clone(TCoeficiente(x.Coefs[i])));
end;

constructor TSparseVectR.Create_Init(ne: integer);
begin
  inherited Create;
  Coefs := TList.Create;
  Coefs.Capacity := ne;
  ultimoIter := 0;
end;

constructor TSparseVectR.Create_FromDAofR(a: TDAofNReal);
var
  i: integer;
begin
  inherited Create;
  Coefs := TList.Create;
  Coefs.Capacity := Length(a);
  for i := 0 to high(a) do
    if a[i] <> 0 then
    begin
      Coefs.Add(TCoeficiente.Create(i, a[i]));
    end;
  ultimoIter := 0;
end;

constructor TSparseVectR.Create_Clone(vrx: TSparseVectR);
var
  i: integer;
begin
  inherited Create;
  ultimoIter := vrx.ultimoIter;
  Coefs := TList.Create;
  Coefs.Capacity := vrx.Coefs.Capacity;
  for i := 0 to vrx.Coefs.Count - 1 do
    Coefs.Add(TCoeficiente.Create_Clone(TCoeficiente(vrx.Coefs[i])));
end;

procedure TSparseVectR.Free;
var
  i: integer;
begin
  for i := 0 to Coefs.Count - 1 do
    TCoeficiente(Coefs[i]).Free;
  Coefs.Free;
  inherited Free;
end;

constructor TSparseVectR.Create_Load(var S: TStream);
type
  Tbuffer = record
    indice: integer;
    valor: NReal;
  end;
var
  buff: array of Tbuffer;
  i: integer;
  k: integer;
  cantNoCeros: integer;
begin
  inherited Create;
  Coefs := TList.Create;
  S.Read(k, sizeOf(n));
  Coefs.Capacity := k;
  S.Read(cantNoCeros, sizeOf(cantNoCeros));
  if cantNoCeros > 0 then
  begin
    SetLength(buff, cantNoCeros);
    S.Read(buff[0], cantNoCeros * SizeOf(TBuffer));
    for i := 0 to cantNoCeros - 1 do
      Coefs.Add(TCoeficiente.Create(buff[i].indice, buff[i].valor));
  end;
  ultimoIter := 0;
end;

procedure TSparseVectR.Store(var S: TStream);
var
  i: integer;
begin
  S.Write(Coefs.Capacity, sizeOf(Coefs.Capacity));
  S.Write(Coefs.Count, sizeOf(Coefs.Count));
  for i := 0 to Coefs.Count - 1 do
  begin
    S.Write(TCoeficiente(Coefs[i]).indice, sizeOf(TCoeficiente(Coefs[i]).indice));
    S.Write(TCoeficiente(Coefs[i]).valor, sizeOf(TCoeficiente(Coefs[i]).valor));
  end;
end;

function TSparseVectR.e(k: integer): NReal;
var
  indice: integer;
begin
  indice := buscarCoef(k);
  if (indice < Coefs.Count) and (TCoeficiente(Coefs[indice]).indice = k) then
    Result := TCoeficiente(Coefs[indice]).valor
  else
    Result := 0;
end;

procedure TSparseVectR.pon_e(k: integer; x: NReal);
var
  indice: integer;
begin
  indice := buscarCoef(k);
  if x <> 0 then
  begin
    if (indice >= Coefs.Count) or (TCoeficiente(Coefs[indice]).indice <> k) then
      Coefs.Insert(indice, TCoeficiente.Create(k, x))
    else
      TCoeficiente(Coefs[indice]).valor := x;
  end
  else
  begin
    if (indice < Coefs.Count) and (TCoeficiente(Coefs[indice]).indice = k) then
    begin
      TCoeficiente(Coefs[indice]).Free;
      Coefs.Delete(indice);
    end;
  end;
end;

procedure TSparseVectR.acum_e(k: integer; x: NReal);
var
  indice: integer;
  coef: TCoeficiente;
begin
  if x <> 0 then
  begin
    indice := buscarCoef(k);
    if (indice >= Coefs.Count) or (TCoeficiente(Coefs[indice]).indice <> k) then
      Coefs.Insert(indice, TCoeficiente.Create(k, x))
    else
    begin
      coef := TCoeficiente(Coefs[indice]);
      if coef.valor + x = 0 then  //Si la suma da 0 lo saco de la lista
      begin
        coef.Free;
        coefs.Delete(indice);
      end
      else
        TCoeficiente(Coefs[indice]).valor := TCoeficiente(Coefs[indice]).valor + x;
    end;
  end;
end;

procedure TSparseVectR.pon_ev(kini: integer; xv: array of NReal);
var
  i: integer;
begin
  for i := 0 to Coefs.Count - 1 do
    TCoeficiente(Coefs[i]).Free;
  Coefs.Clear;
  Coefs.Capacity := Length(xv);
  for i := kini to high(xv) do
    if xv[i] <> 0 then
      Coefs.Add(TCoeficiente.Create(i, xv[i]));
  ultimoIter := 0;
end;

function TSparseVectR.PEV(y: TSparseVectR): NReal;
var
  iterX, iterY: integer;
  temp: NReal;
begin
  temp := 0;
  iterX := 0;
  iterY := 0;
  while (iterX < Coefs.Count) and (iterY < y.Coefs.Count) do
  begin
    if TCoeficiente(Coefs[iterX]).indice < TCoeficiente(y.Coefs[iterY]).indice then
      Inc(iterX)
    else if TCoeficiente(Coefs[iterX]).indice > TCoeficiente(y.Coefs[iterY]).indice then
      Inc(iterY)
    else
    begin
      temp := temp + TCoeficiente(Coefs[iterX]).valor * TCoeficiente(y.Coefs[iterY]).valor;
      Inc(iterX);
      Inc(iterY);
    end;
  end;
  PEV := temp;
end;

function TSparseVectR.PEVRFLX(y: TSparseVectR): NReal;
var
  temp: NReal;
  iterX, iterY, aux: integer;
begin
  temp := 0;
  iterX := 0;
  iterY := y.Coefs.Count - 1;
  while (iterX < Coefs.Count) and (iterY > 0) do
  begin
    aux := Coefs.Capacity + 1 - TCoeficiente(Coefs[iterX]).indice;
    if aux > TCoeficiente(y.Coefs[iterY]).indice then
      Inc(iterX)
    else if aux < TCoeficiente(y.Coefs[iterY]).indice then
      Dec(iterY)
    else
    begin
      temp := temp + TCoeficiente(Coefs[iterX]).valor * TCoeficiente(y.Coefs[iterY]).valor;
      Inc(iterX);
      Dec(iterY);
    end;
  end;
  PEVRFLX := temp;
end;

function TSparseVectR.distancia2(y: TSparseVectR): NReal;
var
  iterX, iterY, i: integer;
  coefX, coefY: TCoeficiente;
  temp: NReal;
begin
  temp := 0;
  iterX := 0;
  iterY := 0;
  while (iterX < Coefs.Count) and (iterY < y.Coefs.Count) do
  begin
    coefX := TCoeficiente(Coefs[iterX]);
    coefY := TCoeficiente(y.Coefs[iterY]);
    if coefX.indice < coefY.indice then
    begin
      temp := temp + sqr(coefX.valor);
      Inc(iterX);
    end
    else if coefX.indice > coefY.indice then
    begin
      temp := temp + sqr(coefY.valor);//sería -coefY.valor pero al cuadrado da igual
      Inc(iterY);
    end
    else
    begin
      temp := temp + sqr(coefX.valor - coefY.valor);
      Inc(iterX);
      Inc(iterY);
    end;
  end;

  for i := iterX to Coefs.Count - 1 do
    //Solo se ejecuta uno de estos fors para terminar con el que me haya quedado
    temp := temp + sqr(TCoeficiente(Coefs[i]).valor);
  for i := iterY to y.Coefs.Count - 1 do
    temp := temp + sqr(TCoeficiente(y.Coefs[i]).valor);

  Result := temp;
end;

function TSparseVectR.distancia(y: TSparseVectR): NReal;
begin
  Result := sqrt(distancia2(y));
end;

function TSparseVectR.coefcorr(y: TSparseVectR; kdesp: integer): NReal;
var
  a: NReal;
  m, iterX, iterY, aux: integer;
begin
  if kdesp < 0 then
    Result := y.coefcorr(Self, -kdesp)
  else
  begin
    a := 0;
    m := Coefs.Capacity + 1 - kdesp;
    if m > 0 then
    begin
      iterX := buscarCoef(kdesp);
      iterY := 0;
      while (iterX < Coefs.Count) and (iterY < y.Coefs.Count) do
      begin
        aux := TCoeficiente(Coefs[iterX]).indice - kdesp;
        if TCoeficiente(y.Coefs[iterY]).indice > aux then
          Inc(iterX)
        else if TCoeficiente(y.Coefs[iterY]).indice < aux then
          Inc(iterY)
        else
        begin
          a := a + TCoeficiente(Coefs[iterX]).valor * TCoeficiente(y.Coefs[iterY]).valor;
          Inc(iterX);
          Inc(iterY);
        end;
      end;
      Result := a / m;
    end
    else
      Result := 0;
  end;
end;

procedure TSparseVectR.PorReal(r: NReal);
var
  i, aux: integer;
begin
  if r <> 0 then
    for i := 0 to Coefs.Count - 1 do
      TCoeficiente(Coefs[i]).valor := TCoeficiente(Coefs[i]).valor * r
  else
  begin
    for i := 0 to Coefs.Count - 1 do
    begin
      TCoeficiente(coefs[i]).Free;
    end;
    aux := Coefs.Capacity;
    Coefs.Clear;
    Coefs.Capacity := aux;
  end;
end;

procedure TSparseVectR.sum(y: TSparseVectR);
var
  iterY, iterSelf, indiceY: integer;
begin
  iterSelf := 0;
  iterY := 0;
  while (iterSelf < Coefs.Count) and (iterY < y.Coefs.Count) do
  begin
    indiceY := TCoeficiente(y.Coefs[iterY]).indice;
    while (iterSelf < Coefs.Count) and (TCoeficiente(Coefs[iterSelf]).indice < indiceY) do
      Inc(iterSelf);
    if (iterSelf < Coefs.Count) and (TCoeficiente(Coefs[iterSelf]).indice <> indiceY) then
    begin
      Coefs.Insert(iterSelf, TCoeficiente.Create(TCoeficiente(y.Coefs[iterY]).indice,
        TCoeficiente(y.Coefs[iterY]).valor));
      Inc(iterSelf);
    end
    else if iterSelf < Coefs.Count then
    begin
      TCoeficiente(Coefs[iterSelf]).valor :=
        TCoeficiente(Coefs[iterSelf]).valor + TCoeficiente(y.Coefs[iterY]).valor;
      if TCoeficiente(Coefs[iterSelf]).valor = 0 then
      begin
        TCoeficiente(Coefs[iterSelf]).Free;
        Coefs.Delete(iterSelf);
        Dec(iterSelf);
      end
      else
        Inc(iterSelf);
    end
    else
      Coefs.Add(TCoeficiente.Create(TCoeficiente(y.Coefs[iterY]).indice,
        TCoeficiente(y.Coefs[iterY]).valor));
    Inc(iterY);
  end;
  for iterY := iterY to y.Coefs.Count - 1 do
    Coefs.Add(TCoeficiente.Create(TCoeficiente(y.Coefs[iterY]).indice,
      TCoeficiente(y.Coefs[iterY]).valor));
end;

procedure TSparseVectR.sumRPV(r: NReal; x: TSparseVectR);
var
  iterX, iterSelf, indiceX: integer;
begin
  if r <> 0 then
  begin
    iterSelf := 0;
    iterX := 0;
    while (iterSelf < Coefs.Count) and (iterX < x.Coefs.Count) do
    begin
      indiceX := TCoeficiente(x.Coefs[iterX]).indice;
      while (iterSelf < Coefs.Count) and (TCoeficiente(Coefs[iterSelf]).indice < indiceX) do
        Inc(iterSelf);
      if (iterSelf < Coefs.Count) and (TCoeficiente(Coefs[iterSelf]).indice <> indiceX) then
      begin
        Coefs.Insert(iterSelf, TCoeficiente.Create(TCoeficiente(x.Coefs[iterX]).indice,
          TCoeficiente(x.Coefs[iterX]).valor * r));
        Inc(iterSelf);
      end
      else if iterSelf < Coefs.Count then
      begin
        TCoeficiente(Coefs[iterSelf]).valor :=
          TCoeficiente(Coefs[iterSelf]).valor + r * TCoeficiente(x.Coefs[iterX]).valor;
        if TCoeficiente(Coefs[iterSelf]).valor = 0 then
        begin
          TCoeficiente(Coefs[iterSelf]).Free;
          Coefs.Delete(iterSelf);
          Dec(iterSelf);
        end
        else
          Inc(iterSelf);
      end
      else
        Coefs.Add(TCoeficiente.Create(TCoeficiente(x.Coefs[iterX]).indice,
          TCoeficiente(x.Coefs[iterX]).valor * r));
      Inc(iterX);
    end;
    for iterX := iterX to x.Coefs.Count - 1 do
      Coefs.Add(TCoeficiente.Create(TCoeficiente(x.Coefs[iterX]).indice,
        TCoeficiente(x.Coefs[iterX]).valor * r));
  end;
end;

function TSparseVectR.ne2: NReal;
var
  iter: integer;
  acum: NReal;
begin
  acum := 0;
  for iter := 0 to Coefs.Count - 1 do
    acum := acum + sqr(TCoeficiente(Coefs[iter]).valor);
  ne2 := acum;
end;

function TSparseVectR.varianza: NReal;
begin
  Result := ne2 / (Coefs.Capacity + 1);
end;

function TSparseVectR.normEuclid: NReal;
begin
  normEuclid := sqrt(ne2);
end;

function TSparseVectR.normMaxAbs: NReal;
var
  k: integer;
  max, aux: NReal;
begin
  if Coefs.Count > 0 then
  begin
    max := abs(TCoeficiente(Coefs[0]).valor);
    for k := 1 to Coefs.Count - 1 do
    begin
      aux := abs(TCoeficiente(Coefs[k]).valor);
      if aux > max then
        max := aux;
    end;
    Result := max;
  end
  else
    Result := 0;
end;

function TSparseVectR.normSumAbs: NReal;
var
  k: integer;
  acum: NReal;
begin
  acum := 0;
  for k := 0 to Coefs.Count - 1 do
    acum := acum + abs(TCoeficiente(Coefs[k]).valor);
  normSumAbs := acum;
end;

procedure TSparseVectR.Copy(var x: TSparseVectR);
var
  i: integer;
begin
  for i := 0 to Coefs.Count - 1 do
  begin
    TCoeficiente(Coefs[i]).Free;
  end;
  Coefs.Clear;
  Coefs.Capacity := x.Coefs.Capacity;
  for i := 0 to x.Coefs.Count - 1 do
    Coefs.Add(TCoeficiente.Create_Clone(TCoeficiente(x.Coefs[i])));
end;

procedure TSparseVectR.Ceros;
var
  i: integer;
begin
  for i := 0 to Coefs.Count - 1 do
  begin
    TCoeficiente(Coefs[i]).Free;
    Coefs[i] := nil;
  end;
  Coefs.Pack;
end;

procedure TSparseVectR.MinMax(var kMin, kMax: integer; var Min, Max: NReal);
var
  m: NReal;
  i: integer;
begin
  if Coefs.Count > 0 then
  begin
    Min := TCoeficiente(Coefs[0]).valor;
    kMin := TCoeficiente(Coefs[0]).indice;
    Max := TCoeficiente(Coefs[0]).valor;
    kMin := TCoeficiente(Coefs[0]).indice;

    for i := 1 to Coefs.Count - 1 do
    begin
      m := TCoeficiente(Coefs[i]).valor;
      if m < min then
      begin
        Min := m;
        kMin := TCoeficiente(Coefs[i]).indice;
      end
      else if m > max then
      begin
        Max := m;
        kMax := TCoeficiente(Coefs[i]).indice;
      end;
    end;
  end
  else
  begin
    kmin := 0;
    kmax := 0;
    min := 0;
    max := 0;
  end;
end;

procedure TSparseVectR.Print;
var
  k: integer;
begin
  writeln(' TSparseVectR.print.inicio');
  for k := 0 to Coefs.Capacity - 1 do
    writeln(' N: ', k: 6, ' : ', e(k): 12: 4);
  writeln(' TSparseVectR.print.fin');
end;

procedure TSparseVectR.HacerUnitario;
var
  m: NReal;
begin
  m := NormEuclid;
  if not EsCero(m / Coefs.Capacity) then
    PorReal(1 / m)
  else
    pon_e(0, 1);
end;

function mayor(item1, item2: NReal): integer;
begin
  if item1 < item2 then
    Result := -1
  else if item1 = item2 then
    Result := 0
  else
    Result := 1;
end;

function menor(item1, item2: NReal): integer;
begin
  if item1 > item2 then
    Result := -1
  else if item1 = item2 then
    Result := 0
  else
    Result := 1;
end;

function MedianaDeTres(elems: TDAofNReal; inf, sup: integer;
  compare: TFuncCompare): NReal;
var
  centro: integer;
  aux: NReal;
begin
  centro := (inf + sup) div 2;
  if (compare(elems[centro], elems[inf]) < 0) then
  begin
    aux := elems[inf];
    elems[inf] := elems[centro];
    elems[centro] := aux;
  end;
  if (compare(elems[sup], elems[inf]) < 0) then
  begin
    aux := elems[inf];
    elems[inf] := elems[sup];
    elems[sup] := aux;
  end;
  if (compare(elems[sup], elems[centro]) < 0) then
  begin
    aux := elems[centro];
    elems[centro] := elems[sup];
    elems[sup] := aux;
  end;

{  aux := elems[centro];
  elems[centro] := elems[sup - 1];
  elems[sup - 1] := aux; }

  Result := elems[centro];
end;

procedure QuickSort(elems: TDAofNReal; inf, sup: integer; compare: TFuncCompare);
var
  i, j: integer;
  sigo: boolean;
  pivote, aux: NReal;
begin
  if inf < sup then
  begin
    pivote := MedianaDeTres(elems, inf, sup, compare);
    i := inf;
    j := sup;
    sigo := True;
    while sigo do
    begin
      while (compare(elems[i], pivote) <= 0) do
        Inc(i);
      while (compare(elems[j], pivote) >= 0) do
        Dec(j);
      if i < j then
      begin
        aux := elems[i];
        elems[i] := elems[j];
        elems[j] := aux;
      end
      else
        sigo := False;
    end;
    if inf < j then
      QuickSort(elems, inf, j, compare);
    if i < sup then
      QuickSort(elems, i, sup, compare);
  end;
end;

procedure TSparseVectR.Sort(creciente: boolean);
var
  compare: TFuncCompare;
  i: integer;
  elems: TDAofNReal;
begin
  SetLength(elems, Coefs.Capacity);
  for i := 0 to Coefs.Capacity - 1 do
    elems[i] := e(i);
  if creciente then
    compare := mayor
  else
    compare := menor;
  QuickSort(elems, 0, high(elems), compare);
  pon_ev(0, elems);
  SetLength(elems, 0);
end;

function TSparseVectR.rpoly(x: NReal): NReal;
var
  r: NReal;
  k, iter: integer;
begin
  r := 0;
  iter := Coefs.Count - 1;
  for k := n downto 1 do
  begin
    if (iter >= 0) and (TCoeficiente(Coefs[iter]).indice = k) then
    begin
      r := r * x + TCoeficiente(Coefs[iter]).valor;
      Dec(iter);
    end
    else
      r := r * x; //TCoeficiente(Coefs[iter]).valor = 0
  end;
  Result := r;
end;

procedure TSparseVectR.cpoly(var resc: NComplex; xc: NComplex);
var
  k: integer;
begin
  resc.r := e(Coefs.Capacity - 1);
  resc.i := 0;

  for k := Coefs.Capacity - 2 downto 0 do
  begin
    Compol.Pro(resc, resc, xc);
    resc.r := resc.r + e(k);
  end;
end;

procedure TSparseVectR.versor_randomico;
var
  k: integer;
  acum: NReal;
  x: NReal;
begin
  acum := 0;
  for k := 0 to Coefs.Capacity - 1 do
  begin
    x := 0.5 - random;
    pon_e(k, x);
    acum := acum + x * x;
  end;

  acum := sqrt(acum);
  if acum > AsumaCero then
  begin
    for k := 0 to Coefs.Capacity - 1 do
      TCoeficiente(Coefs[k]).valor := TCoeficiente(Coefs[k]).valor / acum;
  end
  else
    pon_e(0, 1);
end;

function TSparseVectR.interpol(kr: NReal): NReal;
var
  k1: integer;
  aux: NReal;
begin
  k1 := trunc(kr);
  if k1 <= 0 then
    Result := e(0)
  else if k1 >= Coefs.Capacity - 1 then
    Result := e(Coefs.Capacity - 1)
  else
  begin
    aux := e(k1);//solo para no hacer la busqueda 2 veces
    Result := (e(k1 + 1) - aux) * (kr - k1) + aux;
  end;
end;

// retorna la recta a*k+b que mejor aproxima al conjunto
// de puntos del vector en el sentido de mínimos cuadrados
procedure TSparseVectR.AproximacionLineal(var a, b: NReal);
var
  ma, mb: TSparseMatR;
  k: integer;
  prom_k2, prom_k, prom_uno, prom_k_yk, prom_yk: NReal;
  res: NReal;
  coef: TCoeficiente;
  invertible: boolean;
  e10: integer;
begin
  prom_k := (n + 1) / 2;
  prom_uno := 1;
  prom_k_yk := 0;
  prom_yk := 0;
  for k := 0 to Coefs.Count - 1 do
  begin
    coef := TCoeficiente(Coefs[k]);
    prom_k_yk := prom_k_yk + coef.indice * coef.valor;
    prom_yk := prom_yk + coef.valor;
  end;
  prom_k_yk := prom_k_yk / n;
  prom_yk := prom_yk / n;
  prom_k2 := (((n) * (n + 1) * (2 * n + 1)) / (6 * n)) / n;

  ma := TSparseMatR.Create_Init(2, 2);
  mb := TSparseMatR.Create_Init(2, 1);

  ma.pon_e(1, 1, prom_k2);
  ma.pon_e(1, 2, prom_k);
  ma.pon_e(2, 1, prom_k);
  ma.pon_e(2, 2, prom_uno);

  mb.pon_e(1, 1, prom_k_yk);
  mb.pon_e(2, 1, prom_yk);

  res := ma.Escaler(mb, invertible, e10);
  if (abs(res) < AsumaCero) then
    raise Exception.Create('TSparseVectR.AproximacionLineal res= 0');

  a := mb.e(1, 1);
  b := mb.e(2, 1);
end;

procedure TSparseMatR.WriteXLT(var f: textfile);
var
  k, j: integer;
begin
  writeln(f, 'NFilas: '#9, nf, #9, 'NColumnas: '#9, nc);
  Write(f, ' ');
  for j := 1 to nc do
    Write(f, #9, j);
  writeln(f);

  for k := 1 to nf do
  begin
    Write(f, k);
    for j := 1 to nc do
      Write(f, #9, e(k, j));
    writeln(f);
  end;
end;

function TSparseMatR.Fila(k: integer): TSparseVectR;
begin
  Fila := pm[k];
end;

function TSparseMatR.Columna(k: integer): TSparseVectR;
var
  v: TSparseVectR;
  kf: integer;
begin
  v := TSparseVectR.Create_Init(nf);
  for kf := 1 to nf do
    v.pon_e(kf, e(kf, k));
  Result := v;
end;


constructor TSparseMatR.Create_Init(filas, columnas: integer);
var
  k: integer;
begin
  inherited Create;
  setlength(pm, filas + 1); // la fila 1 la desperdicio
  nf := filas;
  nc := columnas;
  for k := 1 to filas do
    pm[k] := TSparseVectR.Create_Init(columnas);
end;


constructor TSparseMatR.Create_Clone(mrx: TSparseMatR);
var
  k: integer;
begin
  inherited Create;
  setlength(pm, mrx.nf + 1); // la fila 1 la desperdicio
  nf := mrx.nf;
  nc := mrx.nc;
  for k := 1 to nf do
    pm[k] := TSparseVectR.Create_Clone(mrx.pm[k]);
end;


procedure TSparseMatR.Igual(x: TSparseMatR);
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].Igual(x.pm[k]);
end;

procedure TSparseMatR.IntercambieFilas(k1, k2: integer);
var
  t: TSparseVectR;
begin
  t := pm[k1];
  pm[k1] := pm[k2];
  pm[k2] := t;
end;



procedure TSparseMatR.Free;
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].Free;
  setlength(pm, 0);
  inherited Free;
end;


constructor TSparseMatR.Create_Load(var S: TStream);
var
  k: integer;
begin
  inherited Create;
  S.Read(nf, sizeOf(nf));
  S.Read(nc, sizeOf(nc));
  setlength(pm, nf + 1);
  for k := 1 to nf do
    pm[k] := TSparseVectR.Create_Load(s);
end;


procedure TSparseMatR.Store(var s: TStream);
var
  k: integer;
begin
  S.Write(nf, sizeOf(nf));
  S.Write(nc, sizeOf(nc));
  for k := 1 to nf do
    pm[k].Store(s);
end;


function TSparseMatR.e(k, j: integer): NReal;
begin
  e := pm[k].e(j);
end;

procedure TSparseMatR.pon_e(k, j: integer; x: NReal);
begin
  pm[k].pon_e(j, x);
end;

procedure TSparseMatR.acum_e(k, j: integer; x: NReal);
begin
  pm[k].acum_e(j, x);
end;

procedure TSparseMatR.pon_fila(kfil, jcol: integer; xv: array of NReal);
begin
  pm[kfil].pon_ev(jcol, xv);
end;

procedure TSparseMatR.pon_columna(kfil, jcol: integer; xv: array of NReal);
var
  k: integer;
begin
  for k := 0 to high(xv) do
    pon_e(kfil + k, jcol, xv[k]);
end;

function TSparseMatR.transpuesta: TSparseMatR;
var
  m: TSparseMatR;
  k, j: integer;
begin
  m := TSparseMatR.Create_Init(nc, nf);
  for k := 1 to nf do
    for j := 1 to nc do
      m.pon_e(j, k, e(k, j));
  Result := m;
end;

procedure TSparseMatR.Ceros;
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].Ceros;
end;

procedure TSparseMatR.MinMax(var kMin, jMin: integer; var kMax, jMax: integer;
  var Min, Max: NReal);
var
  k, j: integer;
  m: NReal;
begin
  Min := e(1, 1);
  Max := Min;
  kmin := 1;
  jmin := 1;
  kmax := 1;
  jmax := 1;
  for k := 1 to nf do
  begin
    for j := 1 to nc do
    begin
      m := e(k, j);
      if m < Min then
      begin
        kmin := k;
        jmin := j;
        min := m;
      end
      else
      if m > Max then
      begin
        kmax := k;
        jmax := j;
        max := m;
      end;
    end;
  end;
end;

procedure TSparseMatR.CerosFila(kfil: integer);
var
  k: integer;
begin
  for k := 1 to nc do
    pm[kfil].Ceros;
end;

procedure TSparseMatR.WriteM;
var
  k, J: integer;
begin
  writeln;
  writeln('---------------------------------------');
  for k := 1 to nf do
  begin
    Write('fila', k: 3, '):');
    for j := 1 to nc do
      Write(e(k, j): 12: 4);
    writeln;
  end;
end;


constructor TSparseMatR.Create_ReadM; (* a debe estar sin inicializar *)
var
  k, J: integer;
  m: NReal;
begin

  writeln;
  writeln('---------------------------------------');
  Write('numero de filas=?');
  readln(k);
  Write('numero de columnas=?');
  readln(j);
  Create_init(k, j);
  for k := 1 to nf do
  begin
    Write('fila', k: 3, '):?');
    for j := 1 to nc do
    begin
      Read(m);
      pon_e(k, j, m);
    end;
    writeln;
  end;
end;

procedure Combinar(Eliminada, Eliminador: TSparseVectR; Col1, Col2: integer; m: NReal);
var
  j: integer;
begin
  for j := Col1 to Col2 do
    Eliminada.pon_e(j, Eliminada.e(j) + Eliminador.e(j) * m);
end;

function TSparseMatR.Escaler(var i: TSparseMatR; var invertible: boolean;
  var exp10: integer): NReal;
{$ifdef testdeter }
  procedure muestre;
  begin
    writeM;
    i.writeM;
    readln;
    writeln('===============');
  end;

{$endif}

var
  k, p, j: integer;
  ms: NReal;
  det, m, mc1: NReal;
  mult_10, div_10: cardinal;

  procedure mantener_escala_det;
  begin
    if abs(det) > 1e3 then
    begin
      repeat
        det := det / 10.0;
        Inc(mult_10);
      until abs(det) < 1e3;
    end
    else if abs(det) < 1e-3 then
    begin
      repeat
        det := det * 10.0;
        Inc(div_10);
      until abs(det) > 1e-3;
    end;
  end;

begin
  exp10 := 0;
  mult_10 := 0;
  div_10 := 0;

  invertible := True;
  p := 1;
  det := 1;

  {esca1}

  while p < nf do
  begin
      {$ifdef testdeter }
    muestre;
      {$endif}

    m := abs(e(p, p));
    j := p;

    for k := p + 1 to nf do
    begin
      ms := abs(e(k, p));
      if ms > m then
      begin
        m := ms;
        j := k;
      end;
    end;

    if p <> j then
    begin
      IntercambieFilas(p, j);
      i.IntercambieFilas(p, j);
      det := -det;
    end;

    if m <= AsumaCero then
    begin
      det := 0;
      invertible := False;
      p := nf;
    end
    else{eliminacion}
    begin
      mc1 := e(p, p);
      det := det * mc1;
      mantener_escala_det;
      for k := p + 1 to nf do
      begin

        m := -e(k, p) / mc1;
        Combinar(pm[k], pm[p], p + 1, nc, m);
        Combinar(i.pm[k], i.pm[p], 1, i.nc, m);

      end;
    end;
    p := p + 1;
    //writeln('P: ',p,' m ',mc1);
  end;(* while *)


  det := det * e(nf, nf);
  mantener_escala_det;


  if not EsCero(det) then
  begin{esca2}
    for k := 1 to nf do
    begin
    {$ifdef testdeter }
      muestre;
    {$endif}
      mc1 := 1 / e(k, k);
      i.pm[k].PorReal(mc1);
      for j := nc downto k + 1 do
        pon_e(k, j, e(k, j) * mc1);
    end;

    for p := nf downto 2 do
      for k := p - 1 downto 1 do
      begin
        mc1 := -e(k, p);
        Combinar(i.pm[k], i.pm[p], 1, i.nc, mc1);
      end;
  end
  else
    invertible := False;

  exp10 := mult_10 - div_10;
  Escaler := det;
{$ifdef testdeter }
  muestre;
{$endif}
end {deter};

function TSparseMatR.Escaler2(var i: TSparseMatR; var invertible: boolean;
  var exp10: integer): NReal;
{$ifdef testdeter }
  procedure muestre;
  begin
    writeM;
    i.writeM;
    readln;
    writeln('===============');
  end;

{$endif}

var
  k, p, j: integer;
  ms: NReal;
  det, m, mc1: NReal;
  mult_10, div_10: cardinal;
  LU: TSparseMatR;
  dii: NReal;

begin
  exp10 := 0;
  mult_10 := 0;
  div_10 := 0;

  invertible := True;
  p := 1;
  det := 1;

  {escaler2}
  LU := TSparseMatR.Create_Init(nf, nc);

  for k := 1 to nf do
  begin

    dii := e(k, k);
    for j := 1 to pm[k].Coefs.Count do
      writeln(pm[k].Coefs.Count);

  end;

end {deter};

procedure TSparseMatR.CopyColVect(var Y: TSparseVectR; J: integer);
var
  k: integer;
begin
  for k := 1 to nf do
    y.pon_e(k, e(k, j));
end;  (* CopyColVect *)



function TSparseMatR.Traza: NReal;
var
  k: integer;
  temp: NReal;

begin
  temp := e(1, 1);
  for k := 2 to nc do
    temp := temp + e(k, k);
  Result := temp;
end; (* Traza *)

procedure TSparseMatR.PolinomioCaracteristico(var P: TPoliR);

var
  pr: NReal;
  k, j: integer;
  m: TSparseMatR;
begin
  m := TSparseMatR.Create_Init(nf, nc);
  p.gr := nc;
  m.igual(Self);
  pr := m.Traza;
  p.a[p.gr] := 1;
  p.a[p.gr - 1] := -pr;
  for k := 2 to p.gr do
  begin
    for j := 1 to p.gr do
      m.acum_e(j, j, -pr);
    m.Mult(m, self);
    pr := m.Traza / k;
    p.a[p.gr - k] := -pr;
  end;
  p.a[p.gr] := 1;
  m.Free;
end; (* PolinomioCaracteristico *)


procedure TSparseMatR.Mult(a, b: TSparseMatR);
var
  k, j: integer;
  v: TSparseVectR;
  mtemp: TSparseMatR;

begin

  v := TSparseVectR.Create_init(b.nf);
  mtemp := TSparseMatR.Create_init(a.nf, a.nc);
  mtemp.igual(a);

  for j := 1 to b.nc do
  begin
    b.CopyColVect(v, j);
    for k := 1 to A.nf do
      pon_e(k, j, v.PEV(mtemp.pm[j]));
  end;
  mtemp.Free;
  v.Free;
end;  (* MultTSparseMatR *)



procedure TSparseMatR.Transformar(var y: TSparseVectR; x: TSparseVectR);
var
  k: integer;
begin
  for k := 1 to nf do
    y.pon_e(k, x.PEV(pm[k]));
end;  (* Transformar *)




function TSparseMatR.NormMaxAbs: NReal;
var
  k: integer;
  m, ms: NReal;

begin
  m := pm[1].NormMaxAbs;
  for k := 2 to nf do
  begin
    ms := pm[k].NormMaxAbs;
    if ms > m then
      m := ms;
  end;
  NormMaxAbs := m;
end;


function TSparseMatR.deter: NReal;
var
  temp1, temp2: TSparseMatR;
  invertible: boolean;
  e10: integer;

begin
  temp1 := TSparseMatR.Create_init(nf, nc);
  temp1.igual(Self);
  temp2 := TSparseMatR.Create_init(nf, 0);
  deter := temp1.escaler(temp2, invertible, e10);
  temp2.Free;
  temp1.Free;
end;

function TSparseMatR.inv: boolean;
var
  temp: TSparseMatR;
  k, j: integer;
  aux: NReal;
  invertible: boolean;
  e10: integer;

begin
  temp := TSparseMatR.Create_init(nf, nc);
  for k := 1 to nf do
    for j := 1 to nc do
      if k = j then
        temp.pon_e(k, j, 1)
      else
        temp.pon_e(k, j, 0);

  aux := Self.escaler(temp, invertible, e10);
  Self.igual(temp);
  temp.Free;
  Inv := not EsCero(aux);
end;




{
OJO esta en desarrollo
retorna la dimensión del subespacio NULO.
La matriz deve ser cuadrada (hasta que se revise el algoritmo }
function TSparseMatR.CalcBSEN(var Base: TSparseMatR): integer;
var
  k, p, j: integer;
  itmp: integer;
  det, m, mc1: NReal;
  redundancia: integer;
  pidx: TDAofNInt;
  buscando: boolean;
  xCeroPivote: NReal;
  ms: NReal;

begin
  p := 1;
  det := 1;
  redundancia := 0;

  { Relajaci¢n del cero de la m quina para tener encuenta acumulacion
  de errores. /La eleccion de este valor esta realmente complicada. }
  xCeroPivote := 1e-5;

  { inicializacion del direccionador de columnas }
  setlength(pidx, nc + 1);
  for k := 1 to nc do
    pidx[k] := k;

  {esca1}
  while p <= nc - redundancia do
  begin
    repeat
      { busqueda del mejor pivote }
      m := abs(e(p, pidx[p]));
      j := p;
      for k := p + 1 to nf do
      begin
        ms := abs(e(k, pidx[p]));
        if ms > m then
        begin
          m := ms;
          j := k;
        end;
      end;

      { si es necesario intercambiar las filas }
      if p <> j then
      begin
        IntercambieFilas(p, j);
        det := -det;
      end;

      {      writeln( abs(m) ); readlN; }
      if Casi0(m, xCeroPivote) then    {  pivote nulo }
      begin
        det := 0;
        itmp := pidx[p];
        pidx[p] := pidx[nc - redundancia];
        pidx[nc - redundancia] := itmp;
        redundancia := redundancia + 1;
        buscando := True;
      end
      else
        buscando := False;
    until not buscando or (p > (nc - redundancia));

    if buscando then
    else{eliminacion}
    begin
      mc1 := e(p, pidx[p]);
      det := det * mc1;
      for k := p + 1 to nf do
      begin
        m := -e(k, pidx[p]) / mc1;
        Combinar(pm[k], pm[p], p + 1, nc, m);
      end;
    end;
    p := p + 1; { incremento el pivote }
  end;(* while *)

  //  det := det*e(nf,nc); lo comento porque no se usa

  { Resultado de la función }
  CalcBsen := redundancia;

  Base := TSparseMatR.Create_init(redundancia, nf);
  if redundancia = 0 then
    exit; { nada que hacer }

  if redundancia < nc then
  begin{esca2}

    for k := 1 to nc - redundancia do
    begin
      mc1 := 1 / e(k, pidx[k]);
      for j := nc downto k + 1 do
        pon_e(k, pidx[j], e(k, pidx[j]) * mc1);
    end;


    { Escalerización  hacia arriba en el bloque no redundante
    modificando el bloque redundante }
    for p := nf - redundancia downto 2 do
      for k := p - 1 downto 1 do
      begin
        mc1 := e(k, pidx[p]);
        for j := 1 to redundancia do
          pon_e(
            k, pidx[nf - redundancia + j],
            e(k, pidx[nf - redundancia + j]) - e(p, pidx[nf - redundancia + j]) * mc1
            );

      end;


    {
    Un vector del subespacio nulo V lo partimos en dos V1 el conjunto
    de variables NO redundantes y V2 el conjunto de las redundantes
    debiendose cumplir:

    I V1 + B V2 = 0 => V1 = -BV2 .

    donde B es la matriz d (n-redundancia)x(redundancia) que queda en
    la esquina superior derecha de la matriz que estamos procesando.

    Observar que considerando la primer componente de V2 igual a 1 y
    todas las demas 0 y despejando el vector V1 correspondiente
    tenemos un vector del subespacio nulo. Así con el mismo procedimiento
    sobre cada una de las (redundancia) componentes de V2 obtenemos
    una base del espacio nulo que es lo que estamos buscando. Por
    construcción los vectores son Linealmente Independientes (LI).
    }


    {Copia el resultado}
    for k := 1 to redundancia do
    begin
      for j := 1 to nf - redundancia do
        base.pon_e(k, j, -e(j, pidx[nc - redundancia + k]));
      for j := nf - redundancia + 1 to nf do
        base.pon_e(k, j, 0);
      base.pon_e(k, nc - k + 1, 1);
    end;

  end;


  { libero memoria}
  setlength(pidx, 0);

end {deter};




{ Calcula una base del subespacio invariante asociado a un autovalor
real dado }
function TSparseMatR.CalcBSE_R(var Base: TSparseMatR; av: NReal): integer;
var
  k: integer;
begin
  { Hacer coincidir el subespacio asociado a la raiz con el
  subespacio nulo }
  for k := 1 to nf do
    pon_e(k, k, e(k, k) - av);
  CalcBSE_R := CalcBSEN(Base);
end;




{ Calcula una base del subespacio invariate asociado a un par de
autovalores complejos conjugados }
function TSparseMatR.CalcBSE_PCC(var Base: TSparseMatR; av: NComplex): integer;
var
  k: integer;
  tm: TSparseMatR;
  ed: NReal;
begin
  { Es lo mismo que calcular el nucleo de
    ( A*A - 2*av.r*A + mod2(av)) }
  tm := TSparseMatR.Create_init(nf, nc);
  tm.igual(Self);
  ed := -2 * av.r;
  for k := 1 to nf do
    tm.pon_e(k, k, tm.e(k, k) + ed);
  Mult(tm, Self);
  tm.Free;
  ed := av.r * av.r + av.i * av.i;
  for k := 1 to nf do
    tm.pon_e(k, k, tm.e(k, k) + ed);
  CalcBSE_PCC := CalcBSEN(Base);
end;

function TSparseMatR.OrtoNormal: integer;

var
  k, j: integer;
  m: NReal;
  redundancia: integer;

begin
  redundancia := 0;
  for k := 1 to nf do
  begin
    m := fila(k).NormEuclid;
    if not EsCero(m / nc) then
    begin
      fila(k).PorReal(1 / m);
      { ortogonalizacion del resto }
      for j := k + 1 to nf do
      begin
        m := fila(k).PEV(fila(j));
        fila(j).SumRPV(-m, fila(k));
      end;
    end
    else
      redundancia := redundancia + 1;
  end;
  OrtoNormal := nf - redundancia;
end;

end.
