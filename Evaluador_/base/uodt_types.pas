// La si está definida extiende la derivada en el borde interior de la ZonaInterior
// hacia la ZonaExterior (la no comprendida en la discretización).
{$DEFINE extender_derivada_en_ZonaExterior}


unit uodt_types;(*
  20050305.rch Definición de la clase para soportar
  la información de estado para un optimizador dinámico
  estocástico.

  El estado del sistema lo consideramos descripto por un conjunto
  de variables que pueden ser del tipo DISCRETO o CONTINUO.

  Las variables se consideras definidas con un RANGO (xmin, xmax)
  y una cantidad de puntos definidos en ese rango.

  El mínimo de puntos es 2 y en ese caso son los valores xmin y xmax

  Para las variables CONTINUAS, se supondrá algún tipo de aproximación
  entre los puntos (Lineal por ejemplo).
  Las variables DISCRETAS no tienen valores entre los puntos.

  En la optimización dinámica estocástica es necesario guardar
  el valor de la función de costo a futuro para todos los posibles
  estados del sistema en cada paso de tiempo desde el actual
  hasta el futuro. Puede resultar conveniente variar los rangos
  y la cantidad de puntos considerados para diferentes tiempos.
  Por ejemplo, en una simulación de 20 años puede resultar conveniente
  tener una discretización fina del estado en los primeros cinco años y
  una discretización más grosera en los últimos años, con el fin de
  apurar la optimización.

  La clase TEstadoRec está pensada para almacenar la información de
  estado en un PUNTO del tiempo.

  La clase THistoriaRec está pensada para almacener el conjunto de TEstadoRec
  que representan la optimización de un sistema en un horizonte de tiempo.

*)

interface

uses
  SysUtils, xMatDefs;

(*
 En cada paso de tiempo, tenemos que representar el costo para los diferentes
 valores del estado del sistema.

 Para ello clasificamos las variables de estado en CONTINUAS y DISCRETAS

 Para representar una variable CONTINUA, definimos un RANGO dado por los
 parámetros [xim, xmax] y una cantidad NPuntos de discretización de ese
 rango. Para completar la descripción, le damos un vectos de los valores
 de x para los que se calcula el costo dentro del rango. Los valores de x
 los suponemos ordenados en forma creciente
  siendo x[0]=xmin y x[NPuntos-1]= xmax

  Para representar una variable DISCRETA decimos simplemente la cantidad
  de puntos NPuntos y los valores que toma la variable serán 0, 1, 2 ... NPuntos-1
  Esto lo hicimos así por simplicidad, dado que las varibles discretas serán
  usadas en su mayoría para representar booleanas (NPuntos=2).

*)

const
  blockSize_ArchiBin = 1;

type
(* Una variable de este tipo representa el conjunto de valores que puede
tomar una variable de estado continua en un instante de tiempo *)

  { TDefVarContinua }

  TDefVarContinua = class
  public
    nombre: string;
    unidades: string;
    NPuntos: integer;
    dbase: integer;    // auxiliar para indexar la constelación.
    x: TDAOfNReal; // por defecto se carga con xmin, xmin+dx, ... ,xmax
    dx_pcd: NReal;      // por defecto se carga con (xmin-xmax)/(NPuntos-1)
    traduccion: TDefVarContinua;


    constructor Create(nombre_, unidades_: string; xmin_, xmax_: NReal;
      NPuntos_: integer);
    constructor Create_LoadFromFile(var f: file);
    function clonar: TDefVarContinua;
    procedure StoreInFile(var f: file);
    procedure Free; virtual;
    procedure PrintToText(var fsal: TextFile);

    function minval: NREal;  // retorna el mínimo del intervalo
    function maxval: NREal; // retorna el máximo del intervalo
    function deltaval: NReal; // Retorna Maxval-minval
    // retorna (xmax + xmin ) /2
    function xmed: NReal;
    function esIgualA(otraVarDef: TDefVarContinua): boolean;
  end;

(* Una variable de este tipo representa el conjunto de valores que puede
tomar una variable de estado Discreta en un instante de tiempo *)

  { TDefVarDiscreta }

  TDefVarDiscreta = class
    nombre: string;
    unidades: string;
    NPuntos: integer;
    dbase: integer;
    x: TDAOfNINt; // por defecto se carga con 0,1,... NPuntos-1
    traduccion: TDefVarDiscreta;
    constructor Create(nombre_, unidades_: string; NPuntos_: integer);
    constructor Create_LoadFromFile(var f: file);
    function clonar: TDefVarDiscreta;
    procedure StoreInFile(var f: file);
    procedure Free; virtual;
    procedure PrintToText(var fsal: TextFile);

    function minval: integer;  // retorna el mínimo del intervalo
    function maxval: integer; // retorna el máximo del intervalo
    function deltaval: integer; // Retorna Maxval-minval

    function esIgualA(otraVarDef: TDefVarDiscreta): boolean;
  end;



(*** siempre pensando en un instante dado, y con el objetivo de
representar el "espacio de estado" del sistema para ese instante,
creamos la estructura para soportar al conjunto de valores de las
variables de estado. Las suponemos agrupadas a las continuas en un
array y a las discretas en otro. Las siguientes son las definiciones
de tipo de esos arrays.***)

type
(* Representa el conjunto de valores que pueden tomar el conjunto de
variables de estado continuas en un instante dado*)
  TDAOfDefVarContinua = array of TDefVarContinua;

(* Representa el conjunto de valores que pueden tomar el conjunto de
variables de estado discretas en un instante dado*)
  TDAOfDefVarDiscreta = array of TDefVarDiscreta;


type
  TEstado = class
    vc: TDAOfNReal; // valor tomado por las continuas.
    vd: TDAOfNInt;  // valor tomado por las discretas.
  end;




(** Ahora crearemos la estructura que permita representar el espacio de estado
y los valores que toma una función real definida de ese espacio en R.
La función real la llamaremos (costo) pues se utilizará para alojar el
valor del costo **)


type
  TConstelacion = class
  private
    liberarFCosto: boolean; //si me pasaron un fcosto al crearme no lo libero
  public
    // descripción del espacio de estado
    rX: TDAOfDefVarContinua;
    dX: TDAOfDefVarDiscreta;

    nContinuas, nDiscretas: integer;
    nVerticesHipercuboContinuas: integer;
    nEstrellas: integer;
    nPuntosT: integer;

    // El producto Cartesiano de los valores da una Constalación de puntos
    // que representan el espacio de estado.

    // valores de la función Costo en la constelación de puntos
    // Se indexa desde 1
    fCosto: TMatOfNReal;

    // buffers de variables usados en la interpolación
    apro_k1, apro_k2, apro_res,
    // -1 indica me fui para la izquierda , 0 en rango, 1 me fui por la derecha
    apro_estrellita: TDAOfNInt;
    apro_r: TDAOfNreal;


    constructor Create(rX_: TDAOfDefVarContinua; dX_: TDAOfDefVarDiscreta;
      nPuntosT_: integer; const costoFuturo: TMatOfNReal);

    function CreateParasito: TConstelacion;

    constructor Create_LoadFromFile(var f: file);
    procedure StoreInFile(var f: file);

    procedure Free; virtual;

{*
    posiciona los buffers de aproximación del hipercubo continuo
*}

    procedure buscar_hipercubo_continuo(rxv: TDAOfNReal);

(*
  Calcula el aporte al costo_continuo de los vertices del hipercubo correspondientes
  al lateral especificado por jlat respecto de la variable jvar.

  Esta función es útil para el cálculo de diferencias de costos sobre desplazamientos
  en una coordenada continua.
*)
    function costo_continuo_lateral(kPaso: integer; rxv: TDAOfNReal;
      dXv: TDAOfNInt; jvar: integer;
    // indice de la variable para la que se considera el lateral
      jlat: integer // 0: latizquierdo, 1: latderecho
      ): NReal;


  (*  Esta función retorna el valor de la función de costo de acuerdo
  con el valor tomado por las variables de estado (x) interpolando
  entre los valores más próximos en el sub-espacio de las continuas *)
    function costo_continuo(kPaso: integer; rxv: TDAOfNReal; dXv: TDAOfNInt): NReal;

  (* Esta función llena en el Vector HistoRes desde la posición jBase los
  valores de interpolar los vectores del Manto en la posición especificada
  del espacio de estado.
  Se Supone que Manto es una constelación de vectores definidos sobre las
  estrellas del espacio de estado. Esta función es similar a la de cálculo
  del costo_continuo, pero en lugar de interpolar los valores de CF interpola
  los vectores del Manto pasado como parámetro.
  El resultado se guarda en un "tramo" del vector de resultados pasado como
  parámetros "HistoRes" que comienza en la posición jBase. Esto se implementó así
  para poder guardar varios resultados en diferentes tramos de un vector.
  *)
    procedure manto_continuo(rxv: TDAOfNReal; dXv: TDAOfNInt;
      var HistoRes: TDAOfNReal; jBase: integer; const Manto: TMatOfNReal);



    procedure dev_costo_continuo(kPaso: integer; rxv: TDAOfNReal;
      dxv: TDAOfNInt; ir: integer; var dCdx_Inc, dCdx_Dec: NReal;
      var resCod: integer; // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
      var xrpos: NReal     // Posición del punto en la cajita de paroximación en por unidad
      );


    // retorna el costo alamecenado en la estrella identificada por su ordinal
    function costo_estrella(kPaso: integer; ordinal_estrella: integer): NReal;
      overload;

  (* retorna el costo para el nodo (estrella) identificado por los índices
  akr (variables continuas) y aki (variables discretas) *)
    function costo_estrella(kPaso: integer; var akr, aki: TDAOfNInt): NReal;
      overload;

  (* retorna la derivada del costo para el nodo (estrella) identificado por los índices
  akr (variables continuas) y aki (variables discretas)
    respecto a la variable continua identificada por (ir) .
    La estimación del costo se obtiene por diferencia del costo entre el costo
    de la estrella (akr, aki) y la estrella (akr', aki) dónde akr' es la estrella
    akr decrementando en 1 el valor del índice correspondiente a la variable( ir)
    Retorna las estimaciones de las derivadas en el punto correspondientes
    a suponer un incremento de la variable de estado o a suponer un decremento
    respectivamente en dCdx_Inc y dCdx_Dec.
  *)

    procedure dev_costo_estrella_(kPaso: integer; var akr, aki: TDAOfNInt;
      ir: integer; var dCdx_Inc, dCdx_Dec: NReal;
      var resCod: integer // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
      );

    // lo mismo que lo anterior pero además pasamos el ordinal de la estrella
    // base para que no pierda tiempo calculando su ordinal
    procedure dev_costo_estrella_conbase_(kPaso: integer;
      ordinal_Estrella: integer; var akr, aki: TDAOfNInt; ir: integer;
      var dCdx_Inc, dCdx_Dec: NReal;
      var resCod: integer // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
      );

  (* Retorna la diferencia del costo de la estrella identificada por (akr, aki)
  y la estrella corresponidente a sumar delta_dx a la coordenada id de aki *)
    function delta_costo_estrella_dx_(kPaso: integer; var akr, aki: TDAOfNInt;
      id, delta_dx: integer): NReal;

  (* Rentorna la diferencia del costo en el esado identificado por (rxv, dxv)
  y el estado corresponidente a sumar delta_dx a la coordenada id de dxv *)
    function delta_costo_continuo_dx(kPaso: integer; rxv: TDAOfNReal;
      dxv: TDAOfNInt; id, delta_dx: integer): NReal;

  (* Rentorna la diferencia del costo en el esado identificado por (rxv, dxv)
  y el estado corresponidente a sumar delta_rx a la coordenada ir de rxv *)
    function delta_costo_continuo_rx(kPaso: integer; rxv: TDAOfNReal;
      dxv: TDAOfNInt; ir: integer; delta_rx: NReal): NReal;

   (* Rentorna la diferencia del costo en el esado identificado por (rxv, dxv)
    y el estado corresponidente a sumar delta_rx a la coordenada ir de rxv luego de
    sumar delta_rx2 en la coordenada ir2*)
    function delta_costo_continuo_rx_DosEstados_UTE(kPaso: integer;
      rxv: TDAOfNReal; dxv: TDAOfNInt; ir, ir2: integer;
      delta_rx, delta_rx2: NReal): NReal;


  (* guarda el costo para el nodo (estrella) identificado por los índices
  akr (variables continuas) y aki (variables discretas) *)
    procedure set_costo_estrella(kPaso: integer; ordinal_estrella: integer;
      valcosto: NReal); overload;
    procedure set_costo_estrella(kPaso: integer; var akr, aki: TDAOfNInt;
      valcosto: NReal); overload;

    procedure acum_costo_estrella(kPaso: integer; ordinal_Estrella: integer;
      valcosto: NReal); overload;
    procedure acum_costo_estrella(kPaso: integer; var akr, aki: TDAOfNInt;
      valcosto: NReal); overload;

  (*  Para interpolar en el subespacio de las continuas es necesario encontrar
  los puntos más proximos en cada una de las variables y los pesos que
  se les asignará a cada punto del espacio de estado del hiper-cubo formado
  por las estrellas más proximas de la constelación de puntos
  function intervalo_dXr
    buscamos en la variable de ordinal (kvarr) el intervalo que contine el valor
    de (x).
      El resultado es
      -1 indica que x es menor que todo el intervalo (k1=0, k2=1)
      0 indica x en el intervalo k1 y k2 son los índices del intervalo
      1 indica x es mayor al intervalo (k1=NPUNTOS-2, k2=NPUNTOS-1) siendo
        NPUNTOS la cantidad de puntos de la variable kvarr

      En xr se retorna la cordenada de x en el intervalo en por unidad del
      largo del intervalo. xr tomará valores entre 0 y 1 según que x se
      encuentre más cerca del inicio o del fin del intervalo respectivamente.
          *)
    function intervalo_dXr(var k1, k2: integer;
    // indice del rango que incluye el valor (resultado)
      var xr: NReal; // coordenada dentro del rango en pu. (resultado)
      kvarr: integer; // indice de la variable continua a interpolar
      x: NReal): integer;


    // funciones auxiliares para indexar las estrellas
    procedure indicesEstrella_i(var iContinuas: TDAOfNInt;
      var iDiscretas: TDAOfNInt; iEstrella: integer);

    procedure coordenadasEstrella_icid(var xContinuas: TDAOfNReal;
      var xDiscretas: TDAOfNInt; const iContinuas, iDiscretas: TDAOfNInt);


    procedure coordenadasEstrella_icid_indexada(var xContinuas: TDAOfNReal;
      var xDiscretas: TDAOfNInt; const iContinuas, iDiscretas: TDAOfNInt;
      const idx_Continuas, idx_Discretas: TDAOfNInt);


    function ordinalEstrella(iContinuas: TDAOfNInt; iDiscretas: TDAOfNInt): integer;


    // Incrementa la estrella. Considermaos el vector [akr, aki]
    // e incrementamos la primer posición (akr[0]) si ya está en el valor máximo
    // ponemos la posición en cero e intentamos incrementar la siguiente
    // así hasta que logramos incrementar una posición. Si no logramos
    // incrementar ninguna quiere decir que todos los dígitos están en su
    // máximo y hemos llegado a la última de las estrellas. En ese caso
    // el resultado es false.

    // incrementa en el espacio de las continuas
    function inc_kr_estrella(var akr: TDAOfNInt): boolean;

    // incrementa en el espacio de las discretas
    function inc_kd_estrella(var akd: TDAOfNInt): boolean;

    // incrementa la estrella en ambos espacios
    function inc_estrella(var akr, akd: TDAOfNInt): boolean;


    // incrementa en el espacio de las continuas
    // del conjunto de indexadas
    function inc_kr_estrella_indexada(var akr: TDAOfNInt; var idx_r: TDAofNInt): boolean;

    // incrementa en el espacio de las discretas
    // del conjunto de indexadas
    function inc_kd_estrella_indexada(var akd: TDAOfNInt;
      var idx_d: TDAOfNInt): boolean;


    // incrementa la estrella en ambos espacios
    // sobre el subcojunto de variables indexadas
    function inc_estrella_indexada(var akr, akd: TDAOfNInt;
      idx_r, idx_d: TDAOfNInt): boolean;



    // El volumen discretizado, es una caja resultante del producto
    // carteciano de las discretizaciones en las diferentes dimensiones.
    // Esa caja tiene VERTICES que son las estrellas formadas por el producto
    // carteciano de los extremos de las discretizaciones en cada dimensión.

    // incrementa hasta el siguiente vértice de la caja de discretización
    // en el espacio de las continuas
    function inc_kr_vertice(var akr: TDAOfNInt): boolean;

    // incrementa hasta el siguiente vértice de la caja de discretización
    // en el espacio de las discretas
    function inc_kd_vertice(var akd: TDAOfNInt): boolean;

    // incrementa los índices estrella_kr, estrella_kd de forma de apuntar
    // el siguiente VERTICE de la caja que contiene el espacio discretizado.
    function inc_vertice(var akr, akd: TDAOfNInt): boolean;



    // pone a cero la función de costo para el frame identificado por kPuntoT
    procedure ClearFrame_k(kPuntoT: integer);

    // pone a cero el último frame
    procedure ClearUltimoFrame;

    // pone a cero la función de costo para el frame identificado por kPuntoT para
    // las estrellas entre estrellaIni y estrellaFin
    procedure ClearFrame_k_rango(kPuntoT: integer; estrellaIni, estrellaFin: integer);

    // Imprime las definiciones en un archivo de texto.
    //optRes indica si es en el archivo optRes o en uno de los optActor
    // La diferencia es que si es optRes es para Encabezar CF y entonces
    // en el encabezado pone NPuntosT-1  Sino pone NPuntosT-2 para que los
    // actores imprimen los valores de la derivada de la función CF al final
    // del paso y entonces tienen un paso menos.
    procedure PrintDefsToText(var fsal: textFile; optRes: boolean);
  end;

implementation



constructor TConstelacion.Create(rX_: TDAOfDefVarContinua;
  dX_: TDAOfDefVarDiscreta; nPuntosT_: integer; const costoFuturo: TMatOfNReal);
var
  k, ndim: integer;

begin
  inherited Create;
  self.rX := rX_;
  self.dX := dX_;

  nContinuas := length(rX);
  nDiscretas := length(dX);
  nPuntosT := nPuntosT_;

  setlength(apro_k1, nContinuas);
  setlength(apro_k2, nContinuas);
  setlength(apro_res, nContinuas);
  setlength(apro_r, nContinuas);
  setlength(apro_estrellita, nContinuas);

  ndim := 1;
  nVerticesHipercuboContinuas := 1;
  for k := 0 to nContinuas - 1 do
  begin
    rX[k].dbase := ndim;
    ndim := ndim * rX[k].NPuntos;
    nVerticesHipercuboContinuas := nVerticesHipercuboContinuas * 2;
  end;

  for k := 0 to nDiscretas - 1 do
  begin
    dX[k].dbase := ndim;
    ndim := ndim * dX[k].NPuntos;
  end;



  if costoFuturo = nil then
  begin
    setlength(fcosto, nPuntosT);
    for k := 0 to high(fcosto) do
      setlength(fcosto[k], ndim);
    liberarFCosto := True;
  end
  else
  begin

    if (Length(costoFuturo) <> nPuntosT) or (length(costoFuturo[1]) <> ndim) then
      raise Exception.Create(
        'Error en TConstelacion.Create: me pasaron un costo futuro que no coincide con las dimensiones de la sala.');

    fCosto := costoFuturo;
    liberarFCosto := False;
  end;
  nEstrellas := ndim;
end;

function TConstelacion.CreateParasito: TConstelacion;
var
  res: TConstelacion;

begin
  res := TConstelacion.Create(rX, dX, nPuntosT, fCosto);
  Result := res;
end;


// pone a cero la función de costo para el frame identificado por kPuntoT
procedure TConstelacion.ClearFrame_k(kPuntoT: integer);
begin
  vclear(fcosto[kPuntoT]);
end;

procedure TConstelacion.ClearUltimoFrame;
begin
  ClearFrame_k(high(fcosto));
end;


procedure TConstelacion.ClearFrame_k_rango(kPuntoT: integer;
  estrellaIni, estrellaFin: integer);
var
  i: integer;
begin
  for i := estrellaIni to estrellaFin do
    fcosto[kPuntoT][i] := 0;
end;



constructor TConstelacion.Create_LoadFromFile(var f: file);
var
  rX_: TDAOfDefVarContinua;
  dX_: TDAOfDefVarDiscreta;
  nPuntosT_: integer;
  n: integer;
  k: integer;
begin
  BlockRead(f, n, sizeof(n));
  setlength(rX_, n);
  for k := 0 to n - 1 do
    rX_[k] := TDefVarContinua.Create_LoadFromFile(f);

  BlockRead(f, n, sizeof(n));
  setlength(dX_, n);
  for k := 0 to n - 1 do
    dX_[k] := TDefVarDiscreta.Create_LoadFromFile(f);

  blockread(f, nPuntosT_, sizeOf(nPuntosT_));
  Create(rX_, dX_, nPuntosT_, nil);

  for k := 0 to high(fcosto) do
    blockread(f, fCosto[k][0], nEstrellas * sizeOf(fCosto[k][0]));
  liberarFCosto := True;

end;

procedure TConstelacion.StoreInFile(var f: file);
var
  k: integer;
begin
  BlockWrite(f, nContinuas, sizeof(nContinuas));
  for k := 0 to nContinuas - 1 do
    rX[k].StoreInFile(f);

  BlockWrite(f, nDiscretas, sizeof(nDiscretas));
  for k := 0 to nDiscretas - 1 do
    dX[k].StoreInFile(f);

  blockwrite(f, nPuntosT, sizeOf(nPuntosT));
  for k := 0 to high(fcosto) do
    blockwrite(f, fCosto[k][0], nEstrellas * sizeOf(fCosto[k][0]));
end;

procedure TConstelacion.PrintDefsToText(var fsal: textFile; optRes: boolean);
var
  k: integer;
begin
  writeln(fsal, 'NContinuas:', #9, NContinuas);
  writeln(fsal, 'NDiscretas:', #9, NDiscretas);
  writeln(fsal, 'nEstrellas/PuntoT:', #9, nEstrellas);
  if optRes then
    writeln(fsal, 'nPuntosT:', #9, nPuntosT - 1)
  else
    writeln(fsal, 'nPuntosT:', #9, nPuntosT - 2);

  if nContinuas > 0 then
  begin
    writeln(fsal, '-- Descripción variables contínuas --');
    for k := 0 to nContinuas - 1 do
      rX[k].PrintToText(fsal);
  end;
  if nDiscretas > 0 then
  begin
    writeln(fsal, '-- Descripción variables discretas --');
    for k := 0 to nDiscretas - 1 do
      dX[k].PrintToText(fsal);
  end;

  writeln(fsal);
end;

procedure TConstelacion.indicesEstrella_i(var iContinuas: TDAOfNInt;
  var iDiscretas: TDAOfNInt; iEstrella: integer);
var
  ie: integer;
  k: integer;
begin
  ie := iEstrella;
  for k := 0 to nContinuas - 1 do
  begin
    iContinuas[k] := ie mod rX[k].NPuntos;
    ie := ie div rX[k].NPuntos;
  end;
  for k := 0 to nDiscretas - 1 do
  begin
    iDiscretas[k] := ie mod dX[k].NPuntos;
    ie := ie div dX[k].NPuntos;
  end;
end;

procedure TConstelacion.coordenadasEstrella_icid(var xContinuas: TDAOfNReal;
  var xDiscretas: TDAOfNInt; const iContinuas, iDiscretas: TDAOfNInt);
var
  k: integer;
begin
  for k := 0 to nContinuas - 1 do
    xContinuas[k] := rX[k].x[iContinuas[k]];
  for k := 0 to nDiscretas - 1 do
    xDiscretas[k] := dX[k].x[iDiscretas[k]];
end;

procedure TConstelacion.coordenadasEstrella_icid_indexada(var xContinuas: TDAOfNReal;
  var xDiscretas: TDAOfNInt; const iContinuas, iDiscretas: TDAOfNInt;
  const idx_Continuas, idx_Discretas: TDAOfNInt);
var
  k: integer;
begin
  for k := 0 to high(idx_Continuas) do
    xContinuas[idx_Continuas[k]] := rX[idx_Continuas[k]].x[iContinuas[k]];
  for k := 0 to high(idx_Discretas) do
    xDiscretas[idx_Discretas[k]] := dX[idx_Discretas[k]].x[iDiscretas[k]];
end;


function TConstelacion.ordinalEstrella(iContinuas: TDAOfNInt;
  iDiscretas: TDAOfNInt): integer;

var
  k, j: integer;
begin
  j := 0;

  for k := 0 to nContinuas - 1 do
    Inc(j, iContinuas[k] * rX[k].dbase);

  for k := 0 to nDiscretas - 1 do
    Inc(j, iDiscretas[k] * dX[k].dbase);

  Result := j;
end;

// retorna el costo de almacenado para la estrella identificada por el ordinal
function TConstelacion.costo_estrella(kPaso: integer; ordinal_estrella: integer): NReal;
begin
  Result := fcosto[kPaso][ordinal_Estrella];
end;

(* retorna el costo para el nodo (estrella) identificado por los índices
  akr (variables continuas) y aki (variables discretas) *)
function TConstelacion.costo_estrella(kPaso: integer; var akr, aki: TDAOfNInt): NReal;
begin
  Result := fcosto[kPaso][ordinalEstrella(akr, aki)];
end;

procedure TConstelacion.dev_costo_estrella_conbase_(kPaso: integer;
  ordinal_Estrella: integer; var akr, aki: TDAOfNInt; ir: integer;
  var dCdx_Inc, dCdx_Dec: NReal;
  var resCod: integer // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
  );
var
  ordinal_OtraEstrella: integer;
  C0, C1, X0, X1: NReal;
  ix: integer;
  irmod, irmaxsup: integer;
begin
  ix := akr[ir]; // valor entero actual de la coordenada ir
  c0 := fcosto[kPaso][ordinal_Estrella];
  x0 := rx[ir].x[ix];

  if ir < high(rx) then
  begin
    irmaxsup := rx[ir + 1].dbase;
    irmod := ordinal_Estrella mod irmaxsup;
  end
  else
  if length(dx) > 0 then
  begin
    irmaxsup := dx[0].dbase;
    irmod := ordinal_Estrella mod irmaxsup;
  end
  else
  begin
    irmaxsup := NEstrellas;
    irmod := ordinal_Estrella;
  end;

  resCod := 0;

  if irmod < (irmaxsup - 1) then
  begin // si es posible calculo la derivada incrementando el x
    ordinal_OtraEstrella := ordinal_Estrella + rx[ir].dbase;
    c1 := fcosto[kPaso][ordinal_OtraEstrella];
    x1 := rx[ir].x[ix + 1];
    dCdx_Inc := (c1 - c0) / (x1 - x0);
  end
  else
    resCod := 1;


  if irmod > 0 then
  begin // si es posible calculo la derivada decrementando el x
    ordinal_OtraEstrella := ordinal_Estrella - rx[ir].dbase;
    c1 := fcosto[kPaso][ordinal_OtraEstrella];
    x1 := rx[ir].x[ix - 1];
    dCdx_Dec := (c1 - c0) / (x1 - x0);

    if resCod = 1 then
      dCdx_Inc := dCdx_Dec;

  end
  else
  begin // como no fue posible la calculo incrementando
    assert(resCod = 0, 'Me fui de la caja por ambos lados, calculando dev_costo_estrella');
    dCdx_Dec := dCdx_Inc;
    resCod := -1;
  end;
end;

procedure TConstelacion.dev_costo_estrella_(kPaso: integer;
  var akr, aki: TDAOfNInt; ir: integer; var dCdx_Inc, dCdx_Dec: NReal;
  var resCod: integer // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
  );

var
  {  i0, i1: integer;}
  ix: integer;
  C0, C1, X0, X1: NReal;
begin
  ix := akr[ir]; // valor entero actual de la coordenada ir
  c0 := fcosto[kPaso][ordinalEstrella(akr, aki)];
  x0 := rx[ir].x[ix];

  resCod := 0;
  if ix < (rx[ir].NPuntos - 1) then
  begin // si es posible calculo la derivada incrementando el x
    akr[ir] := ix + 1;
    c1 := fcosto[kPaso][ordinalEstrella(akr, aki)];
    x1 := rx[ir].x[ix + 1];
    dCdx_Inc := (c1 - c0) / (x1 - x0);
  end
  else
    resCod := 1;

  if ix > 0 then
  begin // si es posible calculo la derivada decrementando el x
    akr[ir] := ix - 1;
    c1 := fcosto[kPaso][ordinalEstrella(akr, aki)];
    x1 := rx[ir].x[ix - 1];
    dCdx_Dec := (c1 - c0) / (x1 - x0);

    if resCod = 1 then
      dCdx_Inc := dCdx_Dec;

  end
  else
  begin // como no fue posible la calculo incrementando
    assert(resCod = 0, 'Me fui de la caja por ambos lados, calculando dev_costo_estrella');
    dCdx_Dec := dCdx_Inc;
    resCod := -1;
  end;

  akr[ir] := ix;
end;

procedure TConstelacion.dev_costo_continuo(kPaso: integer; rxv: TDAOfNReal;
  dxv: TDAOfNInt; ir: integer; var dCdx_Inc, dCdx_Dec: NReal;
  var resCod: integer; // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
  var xrpos: NReal     // Posición del punto en la cajita de paroximación en por unidad
  );

var
  {  i0, i1: integer;}
  ix: integer;
  C0, C1, X0: NReal;

  aproRes0, aproK10, aproK20: integer;
  aproR0: NReal;

  dx: NReal;

  parb_y0, parb_y1, parb_y2, parb_r: NReal;

begin
  x0 := rxv[ir];

  // primero calculamos el costo en el punto real.
  // como efecto secundario quedan cargados los buffers de aproximación
  // en la constelación con la información del hipercubo que contiene al punto.
  c0 := costo_continuo(kPaso, rxv, dxv);
  aproRes0 := apro_res[ir];
  aproK10 := apro_k1[ir];
  aproK20 := apro_k2[ir];
  aproR0 := apro_r[ir];
  xrpos := aproR0;

  dx := rx[ir].dx_pcd;
  ix := apro_k2[ir];

  resCod := 0;

  if ix < (rx[ir].NPuntos - 1) then
  begin
    // si es posible calculo la derivada incrementando el x
    rxv[ir] := rxv[ir] + dx;
    c1 := costo_continuo(kPaso, rxv, dxv);
    dCdx_Inc := (c1 - c0) / dx;
  end
  else
{$IFDEF extender_derivada_en_ZonaExterior}
    resCod := 1;  // me fui por arriba
{$ELSE}
  begin
    resCod := 1;  // me fui por arriba


    rxv[ir] := rx[ir].x[rx[ir].NPuntos - 2];
    c0 := costo_continuo(kPaso, rxv, dxv);
    rxv[ir] := rx[ir].x[rx[ir].NPuntos - 1];
    c1 := costo_continuo(kPaso, rxv, dxv);
    dCdx_Inc := (c1 - c0) / dx;
  end;
{$ENDIF}
  rxv[ir] := x0;
  apro_res[ir] := aproRes0;
  apro_k1[ir] := aproK10;
  apro_k2[ir] := aproK20;
  apro_r[ir] := aproR0;

  ix := apro_k1[ir];
  if ix > 0 then
  begin
    // si es posible calculo la derivada decrementando el x
    rxv[ir] := rxv[ir] - dx;
    c1 := costo_continuo(kPaso, rxv, dxv);
    dCdx_Dec := -(c1 - c0) / dx;
{$IFDEF extender_derivada_en_ZonaExterior}
    //    if resCod = 1 then  dCdx_Inc := dCdx_Dec;
    if resCod = 1 then
    begin

      rxv[ir] := rx[ir].x[rx[ir].NPuntos - 3];
      parb_y0 := costo_continuo(kPaso, rxv, dxv);

      rxv[ir] := rx[ir].x[rx[ir].NPuntos - 2];
      parb_y1 := costo_continuo(kPaso, rxv, dxv);

      rxv[ir] := rx[ir].x[rx[ir].NPuntos - 1];
      parb_y2 := costo_continuo(kPaso, rxv, dxv);

      parb_r := (x0 - rx[ir].x[rx[ir].NPuntos - 3]) / dx + 1.0;

      c1 := interpolacion_parabolica_012(parb_y0, parb_y1, parb_y2, parb_r);
      dCdx_Inc := (c1 - c0) / dx;

    end;
{$ENDIF}
  end
  else
  begin
    assert(resCod = 0,
      'TConstelacion.dev_costo_continuo: Imposible calcular deltacosto futuro me fui por los dos lados de la caja!!!!');
    resCod := -1; // indico que me fui por abajo de la caja
{$IFDEF extender_derivada_en_ZonaExterior}
    // dCdx_Dec := dCdx_Inc;
    rxv[ir] := rx[ir].x[0];
    parb_y0 := costo_continuo(kPaso, rxv, dxv);

    rxv[ir] := rx[ir].x[1];
    parb_y1 := costo_continuo(kPaso, rxv, dxv);

    rxv[ir] := rx[ir].x[2];
    parb_y2 := costo_continuo(kPaso, rxv, dxv);

    parb_r := (x0 - rx[ir].x[0]) / dx - 1.0;
    c1 := interpolacion_parabolica_012(parb_y0, parb_y1, parb_y2, parb_r);

    dCdx_Dec := (c0 - c1) / dx;

{$ELSE}
    rxv[ir] := rx[ir].x[0];
    c0 := costo_continuo(kPaso, rxv, dxv);
    rxv[ir] := rx[ir].x[1];
    c1 := costo_continuo(kPaso, rxv, dxv);
    dCdx_Dec := (c1 - c0) / dx;
{$ENDIF}
  end;
  rxv[ir] := x0;
end;

function TConstelacion.delta_costo_estrella_dx_(kPaso: integer;
  var akr, aki: TDAOfNInt; id, delta_dx: integer): NReal;
var
  c0, c1: NReal;
  ix: integer;
begin
  ix := aki[id]; // valor entero actual de la coordenada id
  c0 := fcosto[kPaso][ordinalEstrella(akr, aki)];
  aki[id] := ix + delta_dx; // ojo, no estamos chequeando el rango.
  c1 := fcosto[kPaso][ordinalEstrella(akr, aki)];
  aki[id] := ix;
  Result := (c1 - c0);
end;

function TConstelacion.delta_costo_continuo_dx(kPaso: integer;
  rxv: TDAOfNReal; dxv: TDAOfNInt; id, delta_dx: integer): NReal;
var
  c0, c1: NReal;
  dxv_id0: integer;
begin
  // primero calculamos el costo en el punto real.
  // como efecto secundario quedan cargados los buffers de aproximación
  // en la constelación con la información del hipercubo que contiene al punto.
  c0 := costo_continuo(kPaso, rxv, dxv);
  dxv_id0 := dxv[id];
  dxv[id] := dxv_id0 + delta_dx; // ojo, no estamos chequeando el rango.
  c1 := costo_continuo(kPaso, rxv, dxv);
  dxv[id] := dxv_id0;
  Result := (c1 - c0);
end;


(* Rentorna la diferencia del costo en el esado identificado por (rxv, dxv)
y el estado corresponidente a sumar delta_rx a la coordenada ir de rxv luego de
sumar delta_rx2 en la coordenada ir2*)
function TConstelacion.delta_costo_continuo_rx_DosEstados_UTE(kPaso: integer;
  rxv: TDAOfNReal; dxv: TDAOfNInt; ir: integer; ir2: integer;
  delta_rx: NReal; delta_rx2: NReal): NReal;
var
  c0, c1: NReal;
  rxv_ir0, rxv2_ir0: NReal;
begin
  // primero calculamos el costo en el punto real.
  // como efecto secundario quedan cargados los buffers de aproximación
  // en la constelación con la información del hipercubo que contiene al punto.
  rxv2_ir0 := rxv[ir2];
  rxv[ir2] := rxv2_ir0 + delta_rx2; // ojo, no estamos chequeando el rango.
  c0 := costo_continuo(kPaso, rxv, dxv);
  rxv_ir0 := rxv[ir];

  rxv[ir] := rxv_ir0 + delta_rx; // ojo, no estamos chequeando el rango.
  c1 := costo_continuo(kPaso, rxv, dxv);
  rxv[ir] := rxv_ir0;
  rxv[ir2] := rxv2_ir0;
  Result := (c1 - c0);
end;


(* Rentorna la diferencia del costo en el esado identificado por (rxv, dxv)
y el estado corresponidente a sumar delta_rx a la coordenada ir de rxv *)
function TConstelacion.delta_costo_continuo_rx(kPaso: integer;
  rxv: TDAOfNReal; dxv: TDAOfNInt; ir: integer; delta_rx: NReal): NReal;
var
  c0, c1: NReal;
  rxv_ir0: NReal;
begin
  // primero calculamos el costo en el punto real.
  // como efecto secundario quedan cargados los buffers de aproximación
  // en la constelación con la información del hipercubo que contiene al punto.
  c0 := costo_continuo(kPaso, rxv, dxv);
  rxv_ir0 := rxv[ir];
  rxv[ir] := rxv_ir0 + delta_rx; // ojo, no estamos chequeando el rango.
  c1 := costo_continuo(kPaso, rxv, dxv);
  rxv[ir] := rxv_ir0;
  Result := (c1 - c0);
end;

(* guarda el costo para el nodo (estrella) identificado  ordinal_estrella *)
procedure TConstelacion.set_costo_estrella(kPaso: integer;
  ordinal_estrella: integer; valcosto: NReal);
begin
  fcosto[kPaso][ordinal_Estrella] := valcosto;
end;

(* guarda el costo para el nodo (estrella) identificado por los índices
  akr (variables continuas) y aki (variables discretas) *)
procedure TConstelacion.set_costo_estrella(kPaso: integer; var akr, aki: TDAOfNInt;
  valcosto: NReal);
begin
  fcosto[kPaso][ordinalEstrella(akr, aki)] := valcosto;
end;

procedure TConstelacion.acum_costo_estrella(kPaso: integer;
  ordinal_Estrella: integer; valcosto: NReal);
var
  pr: ^NReal;
begin
  pr := @fcosto[kPaso][ordinal_Estrella];
  pr^ := pr^ + valcosto;
end;

procedure TConstelacion.acum_costo_estrella(kPaso: integer;
  var akr, aki: TDAOfNInt; valcosto: NReal);
var
  pr: ^NReal;
begin
  pr := @fcosto[kPaso][ordinalEstrella(akr, aki)];
  pr^ := pr^ + valcosto;
end;

procedure TConstelacion.Free;
var
  k: integer;
begin

  setlength(apro_k1, 0);
  setlength(apro_k2, 0);
  setlength(apro_res, 0);
  setlength(apro_r, 0);
  setlength(apro_estrellita, 0);

  if liberarFCosto then
  begin
    for k := 0 to high(rX) do
      rX[k].Free;
    setlength(rX, 0);
    for k := 0 to high(dX) do
      dX[k].Free;
    setlength(dX, 0);

    for k := 0 to high(fcosto) do
      setlength(fcosto[k], 0);
    setlength(fcosto, 0);
  end;

  inherited Free;
end;

function TConstelacion.intervalo_dXr(var k1, k2: integer;
  // indice del rango que incluye el valor (resultado)
  var xr: NReal; // coordenada dentro del rango en pu. (resultado)
  kvarr: integer; // indice de la variable continua a interpolar
  x: NReal): integer;

var
  buscando: boolean;
  k, max_k: integer;
  vr: TDefVarContinua;
begin
  vr := rX[kvarr];
  max_k := vr.NPuntos - 1;
  if x < vr.x[0] then
  begin
    k1 := 0;
    k2 := 1;
    xr := 0;
    Result := -1;
  end
  else
  begin
    if x > vr.x[max_k] then
    begin
      k1 := max_k - 1;
      k2 := max_k;
      xr := 1;
      Result := 1;
    end
    else
    begin
      k := 0;
      buscando := True;
      while buscando and (k < (max_k - 1)) do
      begin
        if (x <= vr.x[k + 1]) then
          buscando := False
        else
          Inc(k);
      end;

      k1 := k;
      k2 := k + 1;
      xr := (x - vr.x[k1]) / (vr.x[k2] - vr.x[k1]);
      Result := 0;
    end;
  end;
end;



procedure TConstelacion.buscar_hipercubo_continuo(rxv: TDAOfNReal);
var
  k: integer;
begin
  // obtenemos los rangos de aproximación.
  // esto es determinamos el hiper-cubo de las continuas que continene el punto
  for k := 0 to nContinuas - 1 do
  begin
    apro_res[k] := intervalo_dXr(apro_k1[k], apro_k2[k], apro_r[k], k, rxv[k]);
  end;
end;

function TConstelacion.costo_continuo_lateral(kPaso: integer;
  rxv: TDAOfNReal; dXv: TDAOfNInt; jvar: integer;
  // indice de la variable para la que se considera el lateral
  jlat: integer // 0: latizquierdo, 1: latderecho
  ): NReal;
var
  k, j: integer;
  f: NReal;
  a: NReal;
  m, mlat: integer;
begin
  // recorremos ahora los vértices del hiper-cubo y vamos calculando
  // el aporte de cada estrella-vértice en el resultado.
  f := 0;
  mlat := (1 shl jvar); // construimos la máscara para clasificar los nodos
  // respecto a jvar
  for k := 0 to nVerticesHipercuboContinuas - 1 do
  begin
    if ((k and mlat) = jlat) then
    begin // proceso el nodo pue está del lado adecuado
      a := 1;
      m := 1;
      for j := 0 to nContinuas - 1 do
      begin
        if (m and k) = 0 then
        begin
          a := a * (1 - apro_r[j]);
          apro_estrellita[j] := apro_k1[j];
        end
        else
        begin
          a := a * apro_r[j];
          apro_estrellita[j] := apro_k2[j];
        end;
        m := m shl 1;
      end;
      f := f + a * costo_estrella(kPaso, apro_estrellita, dXv);
    end;
  end;
  Result := f;
end;




function TConstelacion.costo_continuo(kPaso: integer; rxv: TDAOfNReal;
  dXv: TDAOfNInt): NReal;
var
  k, j: integer;
  f: NReal;
  a: NReal;
  m: integer;
begin
  buscar_hipercubo_continuo(rxv);

  // recorremos ahora los vértices del hiper-cubo y vamos calculando
  // el aporte de cada estrella-vértice en el resultado.
  f := 0;
  for k := 0 to nVerticesHipercuboContinuas - 1 do
  begin
    a := 1;
    m := 1;
    for j := 0 to nContinuas - 1 do
    begin
      if (m and k) = 0 then
      begin
        a := a * (1 - apro_r[j]);
        apro_estrellita[j] := apro_k1[j];
      end
      else
      begin
        a := a * apro_r[j];
        apro_estrellita[j] := apro_k2[j];
      end;
      m := m shl 1;
    end;
    f := f + a * costo_estrella(kPaso, apro_estrellita, dXv);
  end;
  Result := f;
end;



procedure TConstelacion.manto_continuo(rxv: TDAOfNReal; dXv: TDAOfNInt;
  var HistoRes: TDAOfNReal; jBase: integer; const Manto: TMatOfNReal);

var
  k, j: integer;
  f: NReal;
  a: NReal;
  m: integer;

  NProps: integer;
  jProp: integer;
  kEstrellita: integer;
  pmv: TDAOfNReal;

begin
  buscar_hipercubo_continuo(rxv);

  NProps := length(Manto[0]);
  for jProp := 0 to NProps - 1 do
    HistoRes[jBase + jProp] := 0;

  // recorremos ahora los vértices del hiper-cubo y vamos calculando
  // el aporte de cada estrella-vértice en el resultado.
  for k := 0 to nVerticesHipercuboContinuas - 1 do
  begin
    a := 1;
    m := 1;
    for j := 0 to nContinuas - 1 do
    begin
      if (m and k) = 0 then
      begin
        a := a * (1 - apro_r[j]);
        apro_estrellita[j] := apro_k1[j];
      end
      else
      begin
        a := a * apro_r[j];
        apro_estrellita[j] := apro_k2[j];
      end;
      m := m shl 1;
    end;

    kEstrellita := ordinalEstrella(apro_estrellita, dXv);
    pmv := manto[kEstrellita];
    for jProp := 0 to NProps - 1 do
      HistoRes[jBase + jProp] := HistoRes[jBase + jProp] + a * pmv[jProp];
  end;
end;



function TConstelacion.inc_kr_estrella(var akr: TDAOfNInt): boolean;
var
  buscando: boolean;
  kdigito: integer;
begin
  buscando := True;
  kdigito := 0;
  while buscando and (kdigito <= high(akr)) do
  begin
    Inc(akr[kdigito]);
    if akr[kdigito] < rx[kdigito].NPuntos then
      buscando := False
    else
    begin
      akr[kdigito] := 0;
      Inc(kdigito);
    end;
  end;
  Result := not buscando;
end;


function TConstelacion.inc_kd_estrella(var akd: TDAOfNInt): boolean;
var
  buscando: boolean;
  kdigito: integer;
begin
  buscando := True;
  kdigito := 0;
  while buscando and (kdigito <= high(akd)) do
  begin
    Inc(akd[kdigito]);
    if akd[kdigito] < dx[kdigito].NPuntos then
      buscando := False
    else
    begin
      akd[kdigito] := 0;
      Inc(kdigito);
    end;
  end;
  Result := not buscando;
end;


function TConstelacion.inc_estrella(var akr, akd: TDAOfNInt): boolean;
begin
  if inc_kr_estrella(akr) then
    Result := True
  else
    Result := inc_kd_estrella(akd);
end;


// incrementa en el espacio de las continuas
// del conjunto de indexadas
function TConstelacion.inc_kr_estrella_indexada(var akr: TDAOfNInt;
  var idx_r: TDAofNInt): boolean;
var
  buscando: boolean;
  kdigito: integer;
begin
  buscando := True;
  kdigito := 0;
  while buscando and (kdigito <= high(akr)) do
  begin
    Inc(akr[kdigito]);
    if akr[kdigito] < rx[idx_r[kdigito]].NPuntos then
      buscando := False
    else
    begin
      akr[kdigito] := 0;
      Inc(kdigito);
    end;
  end;
  Result := not buscando;
end;

// incrementa en el espacio de las discretas
// del conjunto de indexadas
function TConstelacion.inc_kd_estrella_indexada(var akd: TDAOfNInt;
  var idx_d: TDAOfNInt): boolean;
var
  buscando: boolean;
  kdigito: integer;
begin
  buscando := True;
  kdigito := 0;
  while buscando and (kdigito <= high(akd)) do
  begin
    Inc(akd[kdigito]);
    if akd[kdigito] < dx[idx_d[kdigito]].NPuntos then
      buscando := False
    else
    begin
      akd[kdigito] := 0;
      Inc(kdigito);
    end;
  end;
  Result := not buscando;
end;


// incrementa la estrella en ambos espacios
// sobre el subcojunto de variables indexadas
function TConstelacion.inc_estrella_indexada(var akr, akd: TDAOfNInt;
  idx_r, idx_d: TDAOfNInt): boolean;
begin
  if inc_kr_estrella_indexada(akr, idx_r) then
    Result := True
  else
    Result := inc_kd_estrella_indexada(akd, idx_d);
end;


function TConstelacion.inc_kr_vertice(var akr: TDAOfNInt): boolean;
var
  buscando: boolean;
  kdigito: integer;
begin
  buscando := True;
  kdigito := 0;
  while buscando and (kdigito <= high(akr)) do
  begin
    if akr[kdigito] < (rx[kdigito].NPuntos - 1) then
    begin
      akr[kdigito] := rx[kdigito].NPuntos - 1;
      buscando := False;
    end
    else
    begin
      akr[kdigito] := 0;
      Inc(kdigito);
    end;
  end;
  Result := not buscando;
end;

function TConstelacion.inc_kd_vertice(var akd: TDAOfNInt): boolean;
var
  buscando: boolean;
  kdigito: integer;
begin
  buscando := True;
  kdigito := 0;
  while buscando and (kdigito <= high(akd)) do
  begin
    if akd[kdigito] < (dx[kdigito].NPuntos - 1) then
    begin
      akd[kdigito] := dx[kdigito].NPuntos - 1;
      buscando := False;
    end
    else
    begin
      akd[kdigito] := 0;
      Inc(kdigito);
    end;
  end;
  Result := not buscando;
end;

function TConstelacion.inc_vertice(var akr, akd: TDAOfNInt): boolean;
begin
  if inc_kr_vertice(akr) then
    Result := True
  else
    Result := inc_kd_vertice(akd);
end;

function TDefVarContinua.clonar: TDefVarContinua;
var
  res: TDefVarContinua;
  k: integer;
begin
  res := TDefVarContinua.Create(nombre, unidades, x[0], x[high(x)], NPuntos);
  res.dx_pcd := dx_pcd;
  for k := 0 to high(x) do
    res.x[k] := x[k];
  if traduccion <> nil then
    res.traduccion := traduccion.clonar
  else
    res.traduccion := nil;
  Result := res;
end;


(*
function TDefVarContinua.clonar: TDefVarContinua;
var
  f: file;
begin
  AssignFile(f, 'temp.tmp');
  Rewrite(f, blockSize_ArchiBin);
  self.StoreInFile(f);
  CloseFile(f);

  AssignFile(f, 'temp.tmp');
  Reset(f, blockSize_ArchiBin);
  Result := TDefVarContinua.Create_LoadFromFile(f);
  CloseFile(f);
end;
*)

constructor TDefVarContinua.Create(nombre_, unidades_: string;
  xmin_, xmax_: NReal; NPuntos_: integer);
var
  k: integer;
  xx: NReal;
begin
  inherited Create;
  nombre := nombre_;
  unidades := unidades_;
  NPuntos := NPuntos_;
  setlength(x, NPuntos);
  if (NPuntos > 1) then
    dx_pcd := (xmax_ - xmin_) / (NPuntos - 1)
  else
    dx_pcd := 0;
  xx := xmin_;
  for k := 0 to NPuntos - 1 do
  begin
    x[k] := xx;
    xx := xx + dx_pcd;
  end;
  traduccion := nil;
end;

constructor TDefVarContinua.Create_LoadFromFile(var f: file);
var
  n: integer;
  tieneTraduccion: boolean;
  // Para poder intercambiar CFs creados con ejecutables compilados en delphi
  // 2009 o superior o en free pascal. Los strings en delphi 2009 ocupan distinto
  // que los ansistring. De esta forma siempre son ansistrings
  aux: ansistring;
begin
  inherited Create;

  blockread(f, n, sizeof(n));
  setlength(aux, n);
  blockread(f, aux[1], n * sizeOf(aux[1]));
  nombre := string(aux);
  blockread(f, n, sizeof(n));
  setlength(aux, n);
  blockread(f, aux[1], n * sizeOf(aux[1]));
  unidades := string(aux);
{
  blockread(f, xmin, sizeof(xmin));
  blockread(f, xmax, sizeof(xmax));
  }
  blockread(f, NPuntos, sizeof(Npuntos));
  setlength(x, NPuntos);
  blockread(f, x[0], sizeof(x[0]) * NPuntos);


  if (NPuntos > 1) then
    dx_pcd := (x[NPuntos - 1] - x[0]) / (NPuntos - 1)
  else
    dx_pcd := 0;

  BlockRead(f, tieneTraduccion, sizeof(tieneTraduccion));
  if tieneTraduccion then
    traduccion := TDefVarContinua.Create_LoadFromFile(f);
end;

function TDefVarContinua.esIgualA(otraVarDef: TDefVarContinua): boolean;
var
  res: boolean;
  i: integer;
begin
  res := (self.nombre = otraVarDef.nombre) and
    (self.unidades = otraVarDef.unidades) and (self.NPuntos = otraVarDef.NPuntos) and
    (self.dbase = otraVarDef.dbase) and (self.dx_pcd = otraVarDef.dx_pcd);

  if res then
  begin
    for i := 0 to high(self.x) do
      if self.x[i] <> otraVarDef.x[i] then
      begin
        res := False;
        break;
      end;
  end;
  Result := res;
end;

procedure TDefVarContinua.StoreInFile(var f: file);
var
  n: integer;
  tieneTraduccion: boolean;
  // Para poder intercambiar CFs creados con ejecutables compilados en delphi
  // 2009 o superior o en free pascal. Los strings en delphi 2009 ocupan distinto
  // que los ansistring. De esta forma siempre son ansistrings
  aux: ansistring;
begin
  aux := nombre;
  n := length(aux);
  blockwrite(f, n, sizeof(n));
  blockwrite(f, aux[1], n * sizeOf(aux[1]));
  aux := unidades;
  n := length(aux);
  blockwrite(f, n, sizeof(n));
  blockwrite(f, aux[1], n * sizeOf(aux[1]));
  blockwrite(f, NPuntos, sizeof(Npuntos));
  blockwrite(f, x[0], sizeof(x[0]) * NPuntos);
  if traduccion <> nil then
  begin
    tieneTraduccion := True;
    BlockWrite(f, tieneTraduccion, sizeof(tieneTraduccion));
    traduccion.StoreInFile(f);
  end
  else
  begin
    tieneTraduccion := False;
    BlockWrite(f, tieneTraduccion, sizeof(tieneTraduccion));
  end;
end;

procedure TDefVarContinua.PrintToText(var fsal: TextFile);
var
  k: integer;
begin
  if traduccion = nil then
  begin
    writeln(fsal, 'Nombre:', #9, Nombre);
    writeln(fsal, 'unidades:', #9, unidades);
    {
    writeln(fsal, 'xmin:', #9, xmin);
    writeln(fsal, 'xmax:', #9, xmax);
    }
    writeln(fsal, 'NPuntos:', #9, NPuntos);
    Write(fsal, 'x[..]:');
    for k := 0 to high(x) do
      Write(fsal, #9, x[k]);
    writeln(fsal);
  end
  else
  begin
    writeln(fsal, 'Nombre:', #9, Nombre, #9, traduccion.nombre);
    writeln(fsal, 'unidades:', #9, unidades, #9, traduccion.unidades);
    {
    writeln(fsal, 'xmin:', #9, xmin, #9, traduccion.xmin);
    writeln(fsal, 'xmax:', #9, xmax, #9, traduccion.xmax);
    }
    writeln(fsal, 'NPuntos:', #9, NPuntos, #9, traduccion.NPuntos);
    Write(fsal, 'x[..]:');
    for k := 0 to high(x) do
      Write(fsal, #9, x[k]);
    writeln(fsal);
    Write(fsal, 'xT[..]:');
    for k := 0 to high(traduccion.x) do
      Write(fsal, #9, traduccion.x[k]);
    writeln(fsal);
  end;
end;

function TDefVarContinua.minval: NREal;
begin
  result:= self.x[0];
end;

function TDefVarContinua.maxval: NREal;
begin
  result:= x[high( x ) ]

end;

function TDefVarContinua.deltaval: NReal;
begin
   result:= maxval - minval;
end;


function TDefVarContinua.xmed: NReal;
begin
  Result := (x[NPuntos - 1] + x[0]) / 2;
end;

procedure TDefVarContinua.Free;
begin
  if traduccion <> nil then
    traduccion.Free;
  setlength(x, 0);
  inherited Free;
end;

function TDefVarDiscreta.clonar: TDefVarDiscreta;
var
  res: TDefVarDiscreta;
  k: integer;
begin
  res := TDefVarDiscreta.Create(nombre, unidades, NPuntos);
  for k := 0 to high(x) do
    res.x[k] := x[k];
  if traduccion <> nil then
    res.traduccion := traduccion.clonar
  else
    res.traduccion := nil;
  Result := res;
end;

(*
function TDefVarDiscreta.clonar: TDefVarDiscreta;
var
  f: file;
begin
  AssignFile(f, 'temp.tmp');
  Rewrite(f, blockSize_ArchiBin);
  self.StoreInFile(f);
  CloseFile(f);

  AssignFile(f, 'temp.tmp');
  Reset(f, blockSize_ArchiBin);
  Result := TDefVarDiscreta.Create_LoadFromFile(f);
  CloseFile(f);
  DeleteFile('temp.tmp');
end;
  *)

constructor TDefVarDiscreta.Create(nombre_, unidades_: string; NPuntos_: integer);
var
  k: integer;
begin
  inherited Create;
  nombre := nombre_;
  unidades := unidades_;
  NPuntos := NPuntos_;
  setlength(x, NPuntos);
  for k := 0 to high(x) do
    x[k] := k;
  traduccion := nil;
end;

constructor TDefVarDiscreta.Create_LoadFromFile(var f: file);
var
  n: integer;
  tieneTraduccion: boolean;
  // Para poder intercambiar CFs creados con ejecutables compilados en delphi
  // 2009 o superior o en free pascal. Los strings en delphi 2009 ocupan distinto
  // que los ansistring. De esta forma siempre son ansistrings
  aux: ansistring;
begin
  inherited Create;
  blockread(f, n, sizeof(n));
  setlength(Nombre, n);
  setlength(aux, n);
  blockread(f, aux[1], n * sizeOf(aux[1]));
  nombre := string(aux);
  blockread(f, n, sizeof(n));
  setlength(aux, n);
  blockread(f, aux[1], n * sizeOf(aux[1]));
  unidades := string(aux);

  blockread(f, NPuntos, sizeOf(NPuntos));
  setlength(x, NPuntos);
  blockread(f, x[0], NPuntos * sizeof(x[0]));
  BlockRead(f, tieneTraduccion, sizeof(tieneTraduccion));
  if tieneTraduccion then
    traduccion := TDefVarDiscreta.Create_LoadFromFile(f);
end;

function TDefVarDiscreta.esIgualA(otraVarDef: TDefVarDiscreta): boolean;
var
  res: boolean;
  i: integer;
begin
  res := (self.nombre = otraVarDef.nombre) and
    (self.unidades = otraVarDef.unidades) and (self.NPuntos = otraVarDef.NPuntos) and
    (self.dbase = otraVarDef.dbase);

  if res then
  begin
    for i := 0 to high(self.x) do
      if self.x[i] <> otraVarDef.x[i] then
      begin
        res := False;
        break;
      end;
  end;
  Result := res;
end;

procedure TDefVarDiscreta.StoreInFile(var f: file);
var
  n: integer;
  tieneTraduccion: boolean;
  // Para poder intercambiar CFs creados con ejecutables compilados en delphi
  // 2009 o superior o en free pascal. Los strings en delphi 2009 ocupan distinto
  // que los ansistring. De esta forma siempre son ansistrings
  aux: ansistring;
begin
  aux := nombre;
  n := length(aux);
  blockwrite(f, n, sizeof(n));
  blockwrite(f, aux[1], n * sizeOf(aux[1]));

  aux := unidades;
  n := length(aux);
  blockwrite(f, n, sizeof(n));
  blockwrite(f, aux[1], n * sizeOf(aux[1]));

  blockwrite(f, NPuntos, sizeOf(NPuntos));
  blockwrite(f, x[0], NPuntos * sizeof(x[0]));
  if traduccion <> nil then
  begin
    tieneTraduccion := True;
    BlockWrite(f, tieneTraduccion, sizeof(tieneTraduccion));
    traduccion.StoreInFile(f);
  end
  else
  begin
    tieneTraduccion := False;
    BlockWrite(f, tieneTraduccion, sizeof(tieneTraduccion));
  end;
end;

procedure TDefVarDiscreta.PrintToText(var fsal: TextFile);
var
  k: integer;
begin
  if traduccion = nil then
  begin
    writeln(fsal, 'Nombre:', #9, Nombre);
    writeln(fsal, 'unidades:', #9, unidades);
    writeln(fsal, 'NPuntos:', #9, NPuntos);
    Write(fsal, 'x[..]:');
    for k := 0 to high(x) do
      Write(fsal, #9, x[k]);
    writeln(fsal);
  end
  else
  begin
    writeln(fsal, 'Nombre:', #9, Nombre, #9, traduccion.nombre);
    writeln(fsal, 'unidades:', #9, unidades, #9, traduccion.unidades);
    writeln(fsal, 'NPuntos:', #9, NPuntos, #9, traduccion.NPuntos);
    Write(fsal, 'x[..]:');
    for k := 0 to high(x) do
      Write(fsal, #9, x[k]);
    writeln(fsal);
    Write(fsal, 'xT[..]:');
    for k := 0 to high(traduccion.x) do
      Write(fsal, #9, traduccion.x[k]);
    writeln(fsal);
  end;
end;

function TDefVarDiscreta.minval: integer;
begin
  result:= self.x[0];
end;


function TDefVarDiscreta.maxval: integer;
begin
  result:= x[high( x ) ]
end;

function TDefVarDiscreta.deltaval: integer;
begin
  result:= maxval - minval;
end;

procedure TDefVarDiscreta.Free;
begin
  if traduccion <> nil then
    traduccion.Free;
  setlength(x, 0);
  inherited Free;
end;

end.




