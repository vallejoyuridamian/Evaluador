unit uneuronas;

{$mode delphi}
(***
rch@20161101
Definición de clases para manejo de RedesNeuronales.

Este proyecto comenzó como una mejora a los CEGHs pensando en lograr
deformadores que transformen el conjunto de las señales en gaussianas.

En esta unidad se definen las clases: TCerebro, TCapaNeuronas y TNeurona

El TCerebro es un conjunto de TCapaNeuronas conectado a unas ENTRADAS y SALIDAS
Una TCapaNeurona es un agrupamiento de TNeurona
y una TNeurona es un elemento capaz de hacer una combinación lineal de sus
entradas y pasarla por una curva S para formar la salida con Saturación.


****)
interface

uses
  Classes, SysUtils, xMatDefs, matreal, uproblema, uresfxgx, ufxgx, utipos_xcf,
  usigmoide;

type

  { TNeurona }
  TNeurona = class
    id_str: string; // identificador para debug
    salida: NReal;
    constructor Create(xid_str: string);
    constructor CreateLoadFromFile(var f: textfile);
    procedure StoreInFile(var f: textfile); virtual;
    procedure Evaluar; virtual;
    procedure Free; virtual;
    procedure RandomInit(paso: NReal); virtual;
    procedure print_debug(var dbgfile: textfile); virtual;
  end;

  // Array dinámico de Neuronas
  TDAofNeurona = array of TNeurona;

  TNeuronaEntrada = class(TNeurona)
  end;

  // salida = sigmoide( sum_i( ro[i] * entrada[ kOffsetEntrada + i]) + Bias )

  { TNeuronaConEntradas }

  TNeuronaConEntradas = class(TNeurona)
    ro: TDAofNreal;  // Pesos para combinar las entradaS.
    bias: NReal; // Constante a sumar de la suma ponderada de las entradas
    entradas: TDAOfNeurona;
    flg_saturante: boolean;


    dro: TDAofNreal;
    dbias: NREal;
    dErr: NReal; // Porción del error que llega a la entrada


    // Crea una Neurona y la conecta a los vectores de Entradas y Salidas pasados
    // como parámetros.
    // xflg_saturante (true por defecto) determina si se aplica la función
    // sigmoide a la combinación lineal de las entradas para calcular la salida o no.
    constructor Create(const xid_str: string; const xEntradas: TDAOfNeurona;
      xflg_saturante: boolean = True);

    // calcula la salida a partir de las entradas
    procedure evaluar; override;

    // Crea la Neurona a partir de la información leída del archivo f
    // y la conecta a los vectores de entradas y salidas.
    constructor CreateLoadFromFile(var f: textfile; xEntradas: TDAofNeurona);

    // Almacena los parámetros de la Neurona en el archivo en forma compatible
    // con la lectura realizada en el constructor CreateFromFile
    procedure StoreInFile(var f: textfile); override;


    // retorna la cantidad de parámetros de la Neurona (length(ro)+1)
    function DimParametros: integer;

    // hace una copia de los parametros en el vector Parametros a partir
    // de la posición kOffset. Al retonrar kOffset está aumentado en la
    // cantidad de parámtros copiados. Esto es útil para hacer una copia
    // de muchas Neuronas en un mismo vector.
    procedure GetParametros(var parametros: TVectR; var kOffset: integer);

    // recupera valores del vector parámetros a partir de la posción kOffset
    // y los copia a los parámetros de la Neurona.
    // El parámetro kOffset se retorna aumentado en la cantidad de parámetros
    // de la Neurona.
    procedure SetParametros(const parametros: TVectR; var kOffset: integer);

    procedure AcumGradParametros(var gradParametros: TVectR; var kOffset: integer);


    // Libera la memoria reservada por la Neurona.
    procedure Free; override;

    // afecta los pesos y el bias entre  x = x + 2*( 1- random) * paso
    procedure RandomInit(paso: NReal); override;

    // Debe llamarse antes de iniciar el entrenamiento
    // Borra dro y dbias
    procedure BackPropagation_init;

    // Debe llamarse antes del EVALUAR con cda nueva muestra durante el entrenamiento
    // LIMPIA el acumulador dErr de la neurona
    procedure BackPropagation_ClearErr;

    // Agrega una muestra. Acumula en dro y dbias la componente aportada por la muestra
    // y transmite a las neuronas de entrada la componente de dErr de la muestra.
    procedure BackPropagation_addMuestra;

    // Afecta bias y ro de acuerdo a dbias y dro * (-paso)
    procedure BackPropagation_DarPaso(paso: NReal);

    procedure print_debug(var dbgfile: textfile); override;

  end;


  { TCapaNeuronasBase }

  TCapaNeuronasBase = class
    Neuronas: TDAOfNeurona;
    id_str: string;
    constructor Create(xid_str: string; NNeuronas: integer);
    constructor CreateLoadFromFile(var f: textfile);
    procedure StoreInFile(var f: textfile); virtual;

    procedure print_debug(var dbgfile: textfile);
    procedure evaluar; virtual;
    procedure RandomInit(paso: NReal);
    procedure Free; virtual;
  end;

  { TCapaNeuronasEntrada }

  TCapaNeuronasEntrada = class(TCapaNeuronasBase)
    constructor Create(xid_str: string; NNeuronas: integer);
    constructor CreateLoadFromFile(var f: textfile);
  end;


  { TCapaNeuronas
  Una capa de Nueronas está formada por un conjunto de Neuronas y un vector de
  Salida. El vector de Entradas es dado (externo a la Capa).
  En la implementación actual, todas las Neuronas de una Capa tienen como
  entrada el mismo vector de Entradas y cada Neurona controla uno de los casilleros
  de la Salida de la Capa.
  }
  TCapaNeuronas = class(TCapaNeuronasBase)

    // Crea una Capa sobre un vector de Entradas.
    constructor Create(xid_str: string; const xEntradas: TDAofNeurona;
      nNeuronas: integer; flg_saturante: boolean);

    // Recorre las Neuronas para que cada una evalúe su salida.
    procedure evaluar; override;


    // Carga la definición de la Capa desde archivo y la asocia al vector
    // de entradas xEntradas.
    constructor CreateLoadFromFile(var f: textfile; xEntradas: TDAofNeurona);

    // Retorna la cantidad de parámetros de la capa. NNeuronas * ( NEntradas + 1 )
    function DimParametros: integer;

    // hace una copia de los parametros de la capa en el vector Parametros
    // comenzando en el casillero kOffset. El parámetro kOffset se retorna
    // aumentado en la cantidad de elementos copiados.
    procedure GetParametros(var parametros: TVectR; var kOffset: integer);

    procedure AcumGradParametros(var gradParametros: TVectR; var kOffset: integer);


    // fija los parámetros de la Capa a partir del vector Parametros.
    // el parámetro kOffset se retorna aumentado en el cantidad de elementos
    // copiados
    procedure SetParametros(const parametros: TVectR; var kOffset: integer);

    // Libera la memoria reservada por la Capa
    procedure Free; override;


    procedure BackPropagation_init;
    procedure BackPropagation_ClearErr;
    procedure BackPropagation_AddMuestra;
    procedure BackPropagation_DarPaso(paso: NReal);

    function SalidasPtr: TDAOfNRealPtr;
  end;

  TDAofCapaNeuronas = array of TCapaNeuronas;

  { TCerebro }

  TCerebro = class
    Entrada_Capa0: TCapaNeuronasEntrada;
    capas: TDAofCapaNeuronas; // ademas de las entradas
    Salida_CapaN: TCapaNeuronas; // apunta capas[high(capas)]

    Premio_UsoInfo_i, Premio_UsoInfo_acum: NReal;
    // Auxiliar para uso algoritmo de distribución del uso de la información.


    constructor Create(nEntradas: integer; // Cantidad de entradas
      xCntNeuronasPorCapa: TDAofNInt; // Cantidad de capas (sin contar la entrada)
      flg_SaturarCapaSalida: boolean); // Indica si saturar la salida de la última capa.

    constructor CreateLoadFromFile(var f: textfile);
    procedure StoreInFile(var f: textfile);
    procedure StoreInArchi(archi: string);

    // devuelve la dimensión de un vector capaz de almacenar todos los parámetros
    // de las neuronas.
    function DimParametros: integer;

    // hace una copia de los parametros
    procedure GetParametros(var parametros: TVectR);

    procedure AcumGradParametros(var gradParametros: TVectR);


    // recupera la copia
    procedure SetParametros(const parametros: TVectR);

    procedure SetEntradas( X: TVectR );
    procedure SetEntrada(jEntrada: integer; valor: NReal);

    procedure evaluar;
    procedure Free;
    procedure RandomInit(paso: NReal);
    procedure BackPropagation_init;
    procedure BackPropagation_ClearErr;
    procedure BackPropagation_addMuestra(derr: TDAOfNReal);
    procedure BackPropagation_DarPaso(paso: NReal);

    procedure print_debug(var dbgfile: textfile);

    // Inicializa las capas intermedias para que transmita cada una
    // una de las entradas hasta la neurona de salida de la última capa
    // y calcula los pesos de la última neurona para minimizar su error
    procedure Iniciar_OptUltimaNeurona( const Data: TDAOfRecXCF);


  end;

  { TCF_Entrenador }

  TCF_Entrenador = class(Tfx)
    Data: TDAOfRecXCF;
    cerebro: TCerebro;

    constructor Create(aCerebro: TCerebro; aData: TDAOfRecXCF);
    function f(const X: TVectR): NReal; override;
    // acumula en grad, el gradiente.
    procedure acum_g(var grad: TVectR; const X: TVectR); override;
    procedure Free; override;

  private
    dimDato: integer;
    derr: TDAOfNReal;

  end;




implementation

{ TCF_Entrenador }

constructor TCF_Entrenador.Create(aCerebro: TCerebro; aData: TDAOfRecXCF);
begin
  cerebro := aCerebro;
  Data := aData;
  dimDato := Data[0].X.n;
  setlength(derr, 1);
end;

function TCF_Entrenador.f(const X: TVectR): NReal;
var
  acum_e2, e: NReal;
  kRec: integer;
  aRec: TRecXCF;
  jEntrada: integer;
  CFAprox: NReal;
  flog: textfile;

begin
  assignfile( flog, 'c:\basura\cerebro_dbg.xlt' );
  rewrite( flog );

  Cerebro.SetParametros(X);
  Cerebro.BackPropagation_init;
  acum_e2 := 0;
  setlength(derr, 1);
  for kRec := 0 to high(Data) do
  begin
    aRec := Data[kRec];
    for jEntrada := 0 to dimDato - 1 do
      Cerebro.SetEntrada(jEntrada, aRec.X.e(jEntrada + 1));
    Cerebro.evaluar;
    CFAprox := Cerebro.Salida_CapaN.Neuronas[0].salida;
    derr[0] := (CFAprox - aRec.CF);

    acum_e2 := acum_e2 + sqr(derr[0]);

    Cerebro.BackPropagation_ClearErr;

    Cerebro.BackPropagation_addMuestra(derr);

    if kRec = 0  then
       Cerebro.print_debug( flog );
  end;
  Result := acum_e2;
  closefile( flog );
end;

procedure TCF_Entrenador.acum_g(var grad: TVectR; const X: TVectR);
begin
  Cerebro.AcumGradParametros(grad);
end;

procedure TCF_Entrenador.Free;
begin
  setlength(derr, 0);
end;

{ TCapaNeuronasEntrada }

constructor TCapaNeuronasEntrada.Create(xid_str: string; NNeuronas: integer);
var
  k: integer;
begin
  inherited Create(xid_str, NNeuronas);
  for k := 0 to high(Neuronas) do
    Neuronas[k] := TNeuronaEntrada.Create(id_str + IntToStr(k));
end;

constructor TCapaNeuronasEntrada.CreateLoadFromFile(var f: textfile);
var
  kNeurona, nNeuronas: integer;
begin
  inherited CreateLoadFromFile(f);
  for kNeurona := 0 to high(Neuronas) do
    Neuronas[kNeurona] := TNeuronaEntrada.CreateLoadFromFile(f);
end;


{ TNeurona }

constructor TNeurona.Create(xid_str: string);
begin
  inherited Create;
  id_str := xid_str;
end;

constructor TNeurona.CreateLoadFromFile(var f: textfile);
begin
  inherited Create;
  readln(f, id_str);
end;

procedure TNeurona.StoreInFile(var f: textfile);
begin
  writeln(f, id_str);

end;

procedure TNeurona.Evaluar;
begin
  // NADA
end;

procedure TNeurona.Free;
begin
  inherited Free;
end;

procedure TNeurona.RandomInit(paso: NReal);
begin
  // NADA
end;

procedure TNeurona.print_debug(var dbgfile: textfile);
begin
  writeln(dbgfile, 'Neurona: ' + id_str + ' (' + ClassName + ')', #9 , 'Salida:', #9, Salida );
end;

{ TCapaNeuronasBase }

constructor TCapaNeuronasBase.Create(xid_str: string; NNeuronas: integer);
begin
  inherited Create;
  id_str := xid_str;
  setlength(Neuronas, NNeuronas);
end;

constructor TCapaNeuronasBase.CreateLoadFromFile(var f: textfile);
var
  nNeuronas: integer;
begin
  readln(f, id_str);
  readln(f, nNeuronas);
  Create(id_str, nNeuronas);
end;

procedure TCapaNeuronasBase.StoreInFile(var f: textfile);
begin
  writeln(f, id_str);
  writeln(f, length(Neuronas));
end;

procedure TCapaNeuronasBase.print_debug(var dbgfile: textfile);
var
  k: integer;
begin
  writeln( dbgfile, 'Capa: ', id_str);
  for k:= 0 to high( Neuronas ) do
    Neuronas[k].print_debug( dbgfile );
end;

procedure TCapaNeuronasBase.evaluar;
begin
  // NADA
end;

procedure TCapaNeuronasBase.RandomInit(paso: NReal);
var
  kNeurona: integer;
begin
  for kNeurona := 0 to high(Neuronas) do
    Neuronas[kNeurona].RandomInit(paso);
end;

procedure TCapaNeuronasBase.Free;
var
  k: integer;
begin
  for k := 0 to high(Neuronas) do
    Neuronas[k].Free;
  setlength(Neuronas, 0);
  inherited Free;
end;



{ TCerebro }

constructor TCerebro.Create(nEntradas: integer; xCntNeuronasPorCapa: TDAofNInt;
  flg_SaturarCapaSalida: boolean);
var
  kCapa: integer;
  entradas: TDAofNeurona;
  flg_saturante: boolean;
begin
  inherited Create;

  Entrada_Capa0 := TCapaNeuronasEntrada.Create('CapaE', nEntradas);
  setlength(capas, length(xCntNeuronasPorCapa));
  entradas := Entrada_Capa0.Neuronas;
  for kCapa := 0 to high(capas) do
  begin
    if kCapa < high(capas) then
      flg_saturante := True
    else
      flg_saturante := flg_SaturarCapaSalida;
    capas[kCapa] := TCapaNeuronas.Create('Capa' + IntToStr(kCapa),
      entradas, xCntNeuronasPorCapa[kCapa], flg_saturante);
    entradas := capas[kCapa].Neuronas;
  end;
  Salida_CapaN := capas[high(capas)];
end;

constructor TCerebro.CreateLoadFromFile(var f: textfile);
var
  nEntradas: integer;
  nCapas, kCapa: integer;
  entradas: TDAofNeurona;
  s: string;
begin
  inherited Create;
  Entrada_Capa0 := TCapaNeuronasEntrada.CreateLoadFromFile(f);
  readln(f, nCapas);
  entradas := Entrada_Capa0.Neuronas;
  for kCapa := 0 to high(capas) do
  begin
    capas[kCapa] := TCapaNeuronas.CreateLoadFromFile(f, entradas);
    entradas := capas[kCapa].Neuronas;
  end;
  Salida_CapaN := capas[high(capas)];
end;

procedure TCerebro.StoreInFile(var f: textfile);
var
  nCapas, kCapa: integer;
begin
  Entrada_Capa0.StoreInFile(f);
  nCapas := length(capas);
  writeln(f, nCapas);
  for kCapa := 0 to high(capas) do
    capas[kCapa].StoreInFile(f);
end;

procedure TCerebro.StoreInArchi(archi: string);
var
  f: textfile;
begin
  Assign(f, archi);
  rewrite(f);
  StoreInFile(f);
  closefile(f);

end;


function TCerebro.DimParametros: integer;
var
  res, kCapa: integer;
begin
  res := 0;
  for kCapa := 0 to high(capas) do
    res := res + capas[kCapa].DimParametros;
  Result := res;
end;

procedure TCerebro.GetParametros(var parametros: TVectR);
var
  kOffset, kCapa: integer;
begin
  kOffset := 0;
  for kCapa := 0 to high(capas) do
    capas[kCapa].GetParametros(parametros, kOffset);
end;

procedure TCerebro.AcumGradParametros(var gradParametros: TVectR);
var
  kOffset, kCapa: integer;
begin
  kOffset := 0;
  for kCapa := 0 to high(capas) do
    capas[kCapa].AcumGradParametros(GradParametros, kOffset);
end;


procedure TCerebro.SetParametros(const parametros: TVectR);
var
  kOffset, kCapa: integer;
begin
  kOffset := 0;
  for kCapa := 0 to high(capas) do
    capas[kCapa].SetParametros(parametros, kOffset);
end;

procedure TCerebro.SetEntradas(X: TVectR);
var
  jEntrada: integer;
begin
  for jEntrada := 0 to high( Entrada_Capa0.Neuronas ) do
    SetEntrada(jEntrada,X.e(jEntrada + 1));
end;

procedure TCerebro.evaluar;
var
  kCapa: integer;
begin
  for kCapa := 0 to high(capas) do
    capas[kCapa].evaluar;
end;


procedure TCerebro.SetEntrada(jEntrada: integer; valor: NReal);
begin
  Entrada_Capa0.Neuronas[jEntrada].salida := valor;
end;

procedure TCerebro.Free;
var
  kCapa: integer;
begin
  for kCapa := 0 to high(capas) do
    capas[kCapa].Free;
  setlength(capas, 0);
  inherited Free;
end;


procedure TCerebro.RandomInit(paso: NReal);
var
  kCapa: integer;
begin
  for kCapa := 0 to high(capas) do
    Capas[kCapa].RandomInit(paso);
end;

procedure TCerebro.BackPropagation_init;
var
  kCapa: integer;
begin
  for kCapa := 0 to high(capas) do
    Capas[kCapa].BackPropagation_init;
end;

procedure TCerebro.BackPropagation_ClearErr;
var
  kCapa: integer;
begin
  for kCapa := 0 to high(capas) do
    Capas[kCapa].BackPropagation_ClearErr;
end;

procedure TCerebro.BackPropagation_addMuestra(derr: TDAOfNReal);
var
  kNeurona: integer;
  aNeurona: TNeurona;
  kCapa: integer;
begin
  // Cargamos los errores de la última capa
  for kNeurona := 0 to high(Salida_CapaN.Neuronas) do
  begin
    aNeurona := Salida_CapaN.Neuronas[kNeurona];
    if aNeurona is TNeuronaConEntradas then
      (aNeurona as TNeuronaConEntradas).dErr := derr[kNeurona];
  end;
  for kCapa := High(Capas) downto 0 do
    Capas[kCapa].BackPropagation_AddMuestra;
end;


procedure TCerebro.BackPropagation_DarPaso(paso: NReal);
var
  kCapa: integer;
  normGrad: NReal;
begin
  normGrad := 0;
  for kCapa := 0 to high(capas) do
    Capas[kCapa].BackPropagation_DarPaso(paso);
end;

procedure TCerebro.print_debug(var dbgfile: textfile);
var
  kCapa: integer;
begin
  Entrada_Capa0.print_debug( dbgfile );
  for kCapa := 0 to high(capas) do
    Capas[kCapa].print_debug( dbgfile );
end;

procedure TCerebro.Iniciar_OptUltimaNeurona(const Data: TDAOfRecXCF);
var
  kCapa, kNeurona: integer;
  jEntrada: integer;
  aNeurona: TNeuronaConEntradas;
  alfa, bias: TVectR;
  bias_s: NReal;
  data_copia: TDAOfRecXCF;
  pesos: TVectR;
  c_min, dc: NReal;

begin
  data_copia:= clonar( data );
  alfa:= TVectR.Create_Init( length( Entrada_Capa0.Neuronas ) );
  bias:= TVectR.Create_init( alfa.n );
  for kCapa:= 0 to high( Capas ) - 1 do
  begin
    for jEntrada:= 1 to alfa.n do
    begin
      Escalas_Entrada_j_conjuntoXCF(
        alfa.pv[jEntrada], bias.pv[jEntrada], jEntrada, data_copia );
    end;
    for kNeurona:= 0 to high( Capas[kCapa].Neuronas ) do
    begin
      aNeurona:= Capas[kCapa].Neuronas[ kNeurona ] as TNeuronaConEntradas;
      aNeurona.bias:= bias.e( kNeurona+1 );
      for jEntrada:= 0 to high( aNeurona.entradas ) do
      begin
        if kNeurona= jEntrada then
          aNeurona.ro[jEntrada]:= alfa.e( jEntrada+1 )
        else
          aNeurona.ro[jEntrada]:= 0.0;
      end;
    end;
  end;

  alfa.Free;
  pesos:= TVectR.Create_Init( length( data_copia ) );
  pesos.Unos;
  MejorNeurona( alfa, bias_s, c_min, dc, data_copia, pesos );
  pesos.Free;
  aNeurona:= Salida_CapaN.Neuronas[0] as TNeuronaConEntradas;
  aNeurona.bias:= bias_s;
  for jEntrada:= 0 to high( aNeurona.ro ) do
   aNeurona.ro[jEntrada]:= alfa.e( jEntrada+1 );
  free_data( data_copia );
end;

{ TCapaNeuronas }

constructor TCapaNeuronas.Create(xid_str: string; const xEntradas: TDAofNeurona;
  nNeuronas: integer; flg_saturante: boolean);
var
  kNeurona: integer;
begin
  inherited Create(xid_str, nNeuronas);
  for kNeurona := 0 to high(Neuronas) do
    Neuronas[kNeurona] := TNeuronaConEntradas.Create(
      xid_str + '_N' + IntToStr(kNeurona), xentradas, flg_saturante);
end;

procedure TCapaNeuronas.evaluar;
var
  kNeurona: integer;
begin
  for kNeurona := 0 to high(Neuronas) do
    Neuronas[kNeurona].evaluar;
end;

constructor TCapaNeuronas.CreateLoadFromFile(var f: textfile; xEntradas: TDAofNeurona);
var
  kNeurona: integer;
begin
  inherited CreateLoadFromFile(f);
  for kNeurona := 0 to high(Neuronas) do
    Neuronas[kNeurona] := TNeuronaConEntradas.CreateLoadFromFile(f, xEntradas);
end;


function TCapaNeuronas.DimParametros: integer;
var
  kNeurona, res: integer;
begin
  res := 0;
  for kNeurona := 0 to high(Neuronas) do
    res := res + (Neuronas[kNeurona] as TNeuronaConEntradas).DimParametros;
  Result := res;
end;

procedure TCapaNeuronas.GetParametros(var parametros: TVectR; var kOffset: integer);
var
  kNeurona: integer;
begin
  for kNeurona := 0 to high(Neuronas) do
    (Neuronas[kNeurona] as TNeuronaConEntradas).GetParametros(parametros, kOffset);
end;

procedure TCapaNeuronas.AcumGradParametros(var gradParametros: TVectR;
  var kOffset: integer);
var
  kNeurona: integer;
begin
  for kNeurona := 0 to high(Neuronas) do
    (Neuronas[kNeurona] as TNeuronaConEntradas).AcumGradParametros(
      gradParametros, kOffset);
end;

procedure TCapaNeuronas.SetParametros(const parametros: TVectR; var kOffset: integer);
var
  kNeurona: integer;
begin
  for kNeurona := 0 to high(Neuronas) do
    (Neuronas[kNeurona] as TNeuronaConEntradas).SetParametros(parametros, kOffset);
end;



procedure TCapaNeuronas.Free;
var
  kNeurona: integer;
begin
  for kNeurona := 0 to high(Neuronas) do
    Neuronas[kNeurona].Free;
  setlength(Neuronas, 0);
  inherited Free;
end;


procedure TCapaNeuronas.BackPropagation_init;
var
  kNeurona: integer;
  aNeurona: TNeuronaConEntradas;
begin
  for kNeurona := 0 to high(neuronas) do
  begin
    aNeurona := Neuronas[kNeurona] as TNeuronaConEntradas;
    aNeurona.BackPropagation_init;
  end;
end;

procedure TCapaNeuronas.BackPropagation_ClearErr;
var
  kNeurona: integer;
  aNeurona: TNeuronaConEntradas;
begin
  for kNeurona := 0 to high(neuronas) do
  begin
    aNeurona := Neuronas[kNeurona] as TNeuronaConEntradas;
    aNeurona.BackPropagation_ClearErr;
  end;
end;

procedure TCapaNeuronas.BackPropagation_AddMuestra;
var
  kNeurona: integer;
  aNeurona: TNeuronaConEntradas;
begin
  for kNeurona := 0 to high(neuronas) do
  begin
    aNeurona := Neuronas[kNeurona] as TNeuronaConEntradas;
    aNeurona.BackPropagation_addMuestra;
  end;
end;




procedure TCapaNeuronas.BackPropagation_DarPaso(paso: NReal);
var
  kNeurona: integer;
  aNeurona: TNeuronaConEntradas;
begin
  for kNeurona := 0 to high(neuronas) do
  begin
    aNeurona := Neuronas[kNeurona] as TNeuronaConEntradas;
    aNeurona.BackPropagation_DarPaso(paso);
  end;
end;

function TCapaNeuronas.SalidasPtr: TDAOfNRealPtr;
var
  kNeurona: integer;
  res: TDAOfNRealPtr;
begin
  setlength(res, Length(Neuronas));
  for kNeurona := 0 to high(res) do
    res[kNeurona] := @Neuronas[kNeurona].salida;
  Result := res;
end;

constructor TNeuronaConEntradas.Create(const xid_str: string;
  const xEntradas: TDAOfNeurona; xflg_saturante: boolean);
begin
  inherited Create(xid_str);
  entradas := xEntradas;
  flg_saturante := xflg_saturante;
  setlength(ro, length(entradas));
  setlength(dro, length(entradas));
  vclear(dro);
end;

procedure TNeuronaConEntradas.evaluar;
var
  kEntrada: integer;
  a: NReal;
begin
  a := bias;
  for kEntrada := 0 to high(ro) do
    a := a + ro[kEntrada] * Entradas[kEntrada].salida;
  if flg_saturante then
    a := sigmoide(a);
  salida := a;
end;

constructor TNeuronaConEntradas.CreateLoadFromFile(var f: textfile;
  xEntradas: TDAofNeurona);
var
  n, k: integer;

begin
  inherited CreateLoadFromFile(f);

  entradas := xEntradas;
  readln(f, bias);

  readln(f, k);
  if k = 0 then
    flg_saturante := False
  else
    flg_saturante := True;

  Read(f, n);
  setlength(ro, n);
  for k := 0 to n - 1 do
    Read(f, ro[k]);
  readln(f);

  setlength(dro, length(entradas));
  vclear(dro);
  dbias := 0;
  derr := 0;
end;

function TNeuronaConEntradas.DimParametros: integer;
begin
  Result := 1 + length(ro);
end;

procedure TNeuronaConEntradas.GetParametros(var parametros: TVectR;
  var kOffset: integer);
var
  k: integer;
begin
  parametros.pon_e(kOffset + 1, bias);
  Inc(kOffset);
  for k := 0 to high(ro) do
    parametros.pon_e(kOffset + k + 1, ro[k]);
  Inc(kOffset, length(ro));
end;

procedure TNeuronaConEntradas.SetParametros(const parametros: TVectR;
  var kOffset: integer);
var
  k: integer;
begin
  bias := parametros.e(kOffset + 1);
  Inc(kOffset);
  for k := 0 to high(ro) do
    ro[k] := parametros.e(kOffset + k + 1);
  Inc(kOffset, length(ro));
end;


procedure TNeuronaConEntradas.AcumGradParametros(var gradParametros: TVectR;
  var kOffset: integer);
var
  k: integer;
begin
  gradParametros.acum_e(kOffset + 1, dbias);
  Inc(kOffset);
  for k := 0 to high(dro) do
    gradParametros.acum_e(kOffset + k + 1, dro[k]);
  Inc(kOffset, length(dro));
end;


procedure TNeuronaConEntradas.StoreInFile(var f: textfile);
var
  n, k: integer;
begin
  inherited StoreInFile(f);

  writeln(f, bias);
  if flg_saturante then
    writeln(f, 1)
  else
    writeln(f, 0);

  n := length(ro);
  Write(f, n);
  for k := 0 to n - 1 do
    Write(f, #9, ro[k]);
  writeln(f);
end;

procedure TNeuronaConEntradas.Free;
begin
  setlength(ro, 0);
  inherited Free;
end;

procedure TNeuronaConEntradas.RandomInit(paso: NReal);
var
  k: integer;
begin
  for k := 0 to high(ro) do
    ro[k] := ro[k] + 2 * (1 - random) * paso;
  bias := bias + 2 * (1 - random) * paso;
end;

procedure TNeuronaConEntradas.BackPropagation_init;
begin
  dbias := 0;
  vclear(dro);
  dErr := 0;
end;

procedure TNeuronaConEntradas.BackPropagation_ClearErr;
begin
  dErr:= 0;
end;

procedure TNeuronaConEntradas.BackPropagation_addMuestra;
var
  dev: NReal;
  aNeurona: TNeuronaConEntradas;
  k: integer;

begin

  if flg_saturante then
    dev := salida * (1 - salida)
  else
    dev := 1;

  // Pasamos el error de la Salida de la sigmoide a la entrada.
  derr := dev * derr;

  // Acumulamos en las componentes del gradiente de la Neurona
  for k := 0 to high(ro) do
    dro[k] := dro[k] + derr *  Entradas[k].salida;
  dbias := dbias + derr;

  // Ahora transmitimos a las neuronas de entrada la componente del error
  // para que puedan ellas ajustar sus gradientes.
  if Entradas[0] is TNeuronaConEntradas then
    for k := 0 to high(Entradas) do
    begin
      aNeurona := Entradas[k] as TNeuronaConEntradas;
      aNeurona.dErr := aNeurona.dErr + derr * ro[k];
    end;
end;

procedure TNeuronaConEntradas.BackPropagation_DarPaso( paso: NReal);
var
  k: integer;
begin
  for k := 0 to high(ro) do
    ro[k] := ro[k] - paso * dro[k];
  bias := bias - paso * dbias;
end;

procedure TNeuronaConEntradas.print_debug(var dbgfile: textfile);
var
  k: integer;
begin
  inherited print_debug(dbgfile);

  writeln(dbgfile, #9,'derr:', #9, dErr);
  Write(dbgfile, #9, 'ro:');
  for k := 0 to high(ro) do
    Write(dbgfile, #9, ro[k]);
  writeln(dbgfile, #9, 'bias:', #9, bias);

  Write(dbgfile, #9, 'dro:');
  for k := 0 to high(ro) do
    Write(dbgfile, #9, dro[k]);
  writeln(dbgfile, #9, 'dbias:', #9, dbias);

  Write(dbgfile, #9, 'Entradas:');
  for k := 0 to high(entradas) do
    Write(dbgfile, #9, entradas[k].id_str);
  writeln(dbgfile);
  writeln(dbgfile);
end;

end.
