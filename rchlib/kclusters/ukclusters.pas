unit ukclusters;

{$mode delphi}
interface

uses
  xMatDefs,
  Classes, matreal, matent, SysUtils, uAuxiliares, fddp, ufechas, Math,
  useriestemporales,
  Uniform, MatBool, uopencalc;

type

  { TDatoRec }

  TDatoRec = class
    // dt Fecha del dato
    dt: TDateTime;

    // variables explicativas
    alfa: TVectR; // variables reales

    // variables explicadas
    p: TVectR;

    constructor Create(dt: TDateTime; P_: TVectR; alfa_: TVectR);
    constructor Create_Vacio(dim_alfa, dimp_p: integer);
    destructor Destroy; override;

    // retorna la distancia a otra observación en el espacio de Propiedades
    function d_alfa(const a: TDatoRec): NReal; virtual;

    // retorna la distancia a otra observación en el espacio de datos
    function d_p(const a: TDatoRec): NReal; virtual;

    procedure CopyFrom(aRec: TDatoRec);
    procedure WriteToODS(f: TLibroOpenCalc);
  end;

  TDAOfDatoRec = array of TDatoRec;


  { TClusterRec }

  TClusterRec = class
    centroide: TDatoRec;
    cnt_integrantes: integer; // cantidad de integrantes
    A: TMatR; // aproximador lineal del cluster
    B: TVectR; // p_i = A alfa_i + B + e_i
    constructor Create(dim_alfa, dim_p: integer);
    destructor Destroy; override;
    function distancia(aDato: TDatoRec): NReal;

    function Calc_e2(aDato: TDatoRec): NReal;
    procedure WriteToODS(f: TLibroOpenCalc);
    procedure CalcAB(datos: TDAOfDatoRec; iCluster: TVectE; kCluster: integer);
  end;

  TClusters = array of TClusterRec;

  { TClasificador_K_Means }
  TClasificador_K_Means = class
    clusters: TClusters;
    datos: TDAOfDatoRec;

    iCluster: TVectE; // Vector con la última clasificación
    flg_convergio: boolean;
    cnt_iteraciones: integer;
    K_Clusters: integer;
    NMaxIteraciones: integer;

    constructor Create(datos: TDAOfDatoRec; k_clusters, NMaxIteraciones: integer);

    procedure WritToArchiODS(archi: string);

    destructor Destroy; override;

  private
    procedure InicializarCentroidesRND;
    function ReclasificarDatos: integer;
    procedure RecalcularCentroides;
    procedure CalcularAB;
  end;


  { TEstimador_KNN }

  TEstimador_KNN = class
    k_Nears: integer;
    datos: TDAOfDatoRec;
    constructor Create(datos: TDAOfDatoRec; k_Nears: integer);
    procedure calc_P(dato: TDatoRec);
    destructor Destroy; override;
  end;



function ExtraerCurvasDem(series: TSeriesDeDatos;
    kSerieDem, kSerieTemp: integer): TDAOfDatoRec;


implementation



(**
   Calcula la aprox. por minimos cuadrados de
   p_i = A * alfa_i + B
   para los valores (alfa_i, p_i) de los datos
   para los cuales flg_Valido[i] = true
**)
procedure CalcMinCuad_AB(var A: TMatR; B: TVectR; datos: TDAOfDatoRec;
  flg_valido: TDAOfBoolean);

var
  Ma1a1t, Ma1tp: TMatR;
  kDato: integer;
  aDato: TDatoRec;
  i, j: integer;
  exp10: integer;
  flg_ok: boolean;

  procedure agregar_m(alfa, p: TVectR);
  var
    i, j: integer;
    a: NReal;
  begin
    for i := 1 to alfa.n do
    begin
      a := alfa.e(i);
      for j := i to Ma1a1t.nc do
        Ma1a1t.acum_e(i, j, a * alfa.e(j));
      for j := 1 to Ma1tp.nc do
        Ma1tp.acum_e(i, j, a * p.e(j));
    end;
  end;

begin

  Ma1a1t := TMatR.Create_init(datos[0].alfa.n + 1, datos[0].alfa.n + 1);
  Ma1tp := TMatR.Create_init(Ma1a1t.nf, datos[0].p.n);
  Ma1a1t.Ceros;
  Ma1tp.Ceros;

  for kDato := 0 to high(datos) do
  begin
    if flg_valido[kDato] then
      agregar_m(aDato.alfa, aDato.p);
  end;

  // simetrizamos matriz principal
  for i := 2 to Ma1a1t.nf do
    for j := 1 to i - 1 do
      Ma1a1t.pon_e(i, j, Ma1a1t.e(j, i));

  // ahora resolvemos
  Ma1a1t.Escaler(Ma1tp, flg_ok, exp10);
  if not flg_ok then
    raise Exception.Create('Sistema no invertible CalcAB');

  if B <> nil then
    B.Free;
  B := Ma1tp.QuitarFila(Ma1tp.nf);

  if A <> nil then
    A.Free;
  A := Ma1tp.Crear_Transpuesta;

  Ma1a1t.Free;
  Ma1tp.Free;
end;




{ TEstimador_KNN }

constructor TEstimador_KNN.Create(datos: TDAOfDatoRec; k_Nears: integer);
begin
  inherited Create;
  self.datos := datos;
  self.k_Nears := k_Nears;
end;

type
  TKNNSortRec = record
    iDato: integer;
    d: NReal;
  end;

  { TKNNSortedList }

  TKNNSortedList = class
    NElementos: integer;
    elementos: array of TKNNSortRec;
    cnt_usados: integer;
    constructor Create(NElementos: integer);
    destructor Destroy; override;
    procedure insert(iDato: integer; dDato: NReal);
  end;

{ TKNNSortedList }

constructor TKNNSortedList.Create(NElementos: integer);
begin
  inherited Create;
  self.NElementos := NElementos;
  setlength(elementos, NElementos);
  cnt_usados := 0;
end;

destructor TKNNSortedList.Destroy;
begin
  setlength(elementos, 0);
  inherited Destroy;
end;

procedure TKNNSortedList.insert(iDato: integer; dDato: NReal);
var
  k, j: integer;
  buscando: boolean;
begin
  k := 0;
  buscando := True;
  while buscando and (k < cnt_usados) do
  begin
    if elementos[k].d < dDato then
      Inc(k)
    else
      buscando := False;
  end;
  if buscando then
    if k < NElementos then // amplio la lista
    begin
      elementos[cnt_usados].iDato := iDato;
      elementos[cnt_usados].d := dDato;
      Inc(cnt_usados);
    end
    else // la lista está completa cambio el último
    begin
      elementos[NElementos - 1].iDato := iDato;
      elementos[NElementos - 1].d := dDato;
    end
  else // encontré donde insertar
  if cnt_usados < NElementos then // inserto y amplio la lista
  begin
    for j := cnt_usados downto k + 1 do
      elementos[j] := elementos[j - 1];
    elementos[k].iDato := iDato;
    elementos[k].d := dDato;
    Inc(cnt_usados);
  end
  else
  begin //la lista está completa, inserto eliminando el último
    for j := cnt_usados - 1 downto k + 1 do
      elementos[j] := elementos[j - 1];
    elementos[k].iDato := iDato;
    elementos[k].d := dDato;
  end;
end;


procedure TEstimador_KNN.calc_P(dato: TDatoRec);
var
  KNN: TKNNSortedList;
  kDato, kNear: integer;
  d: NReal;
  flg_valido: TDAOfBoolean;
  A: TMatR;
  B: TVectR;
begin

  // Creamos la lista de k-Nearest Neighbors
  KNN := TKNNSortedList.Create(k_Nears);
  for kDato := 0 to high(datos) do
  begin
    d := dato.d_alfa(datos[kDato]);
    if d >= 0 then // d < 0 implica filtrado
      KNN.insert(kDato, d);
  end;

  setlength(flg_valido, length(datos));
  for kNear := 0 to KNN.cnt_usados - 1 do
    flg_valido[kNN.elementos[kNear].iDato] := True;
  A := nil;
  B := nil;
  CalcMinCuad_AB(A, B, datos, flg_valido);

  A.Transformar(dato.p, dato.alfa);
  dato.p.sum(B);

  A.Free;
  B.Free;
  setlength(flg_valido, 0);
  KNN.Free;
end;

destructor TEstimador_KNN.Destroy;
var
  kDato: integer;
begin
  for kDato := 0 to high(datos) do
    datos[kDato].Free;
  setlength(datos, 0);

  inherited Free;
end;


function ExtraerCurvasDem(series: TSeriesDeDatos;
  kSerieDem, kSerieTemp: integer): TDAOfDatoRec;
var
  NCurvas: integer;
  dt_InicioAnio, dt_InicioDia: TDateTime;
  kHorasDiff: integer;
  kIni, kFin: integer;
  dt_MuestraSiguienteALaUltima: TDateTime;

  res: TDAOfDatoRec;
  sDem, sTemp: TVectR;
  Temp, PDem: TVectR;
  kDia, kHora: integer;
  kBase: integer;
  dt_Dia: TDateTime;

begin
  if abs(series.dtEntreMuestras - 1 / 24.0) > dt_1ms / 10.0 then
    raise Exception.Create('ExtraerCurvaDem ... solo es aplicable a muestras horarias ');

  kIni := 1;
  kFin := series.NPuntos;
  dt_InicioAnio := series.dtPrimeraMuestra_InicioDelAnio;
  dt_InicioDia := series.dtPrimeraMuestra_InicioDelDia;

  // solo sacaremos días enteros por lo cual verificamos si es necesario
  // cambiar kIni y/o kFin;
  kHorasDiff := round((series.dtPrimeraMuestra - dt_InicioDia) * 24);
  if kHorasDiff > 0 then
    kIni := (24 - kHOrasDiff) + 1
  else
    kIni := 1;

  dt_MuestraSiguienteALaUltima := series.dtPrimeraMuestra + series.NPuntos / 24.0;
  kHorasDiff := round(frac(dt_MuestraSiguienteALaUltima) * 24.0);
  kFin := series.NPuntos - kHorasDiff;

  NCurvas := Round((kFin - kIni + 1) / 24.0);
  if NCurvas <= 0 then
    raise Exception.Create('No hay datos ni para una curva');

  setlength(res, NCurvas);

  Temp := TVectR.Create_Init(24);

  sDem := series.series[kSerieDem];
  sTemp := series.series[kSerieTemp];

  for kDia := 0 to NCurvas - 1 do
  begin
    PDem := TVectR.Create_Init(24);
    kBase := kIni + kDia * 24;
    dt_Dia := series.dtPrimeraMuestra + (kBase - 1) / 24.0;
    for kHora := 0 to 23 do
    begin
      pDem.pon_e(kHora + 1, sDem.e(kBase + kHora));
      Temp.pon_e(kHora + 1, sTemp.e(kBase + kHora));
    end;
    res[kDia] := TDatoRec.Create(dt_Dia, PDem, Temp);
  end;
  Temp.Free;
  Result := res;
end;



function TClasificador_K_Means.ReclasificarDatos: integer;
var
  kDato: integer;
  kCluster: integer;
  kMejor: integer;
  dMejor: NReal;
  aCluster: TClusterRec;
  aDato: TDatoRec;
  cnt_cambios: integer;
  dTest: NReal;
begin
  for kCluster := 0 to high(Clusters) do
    Clusters[kCluster].cnt_integrantes := 0;

  cnt_cambios := 0;

  // Reclasifico y cuento cambios de clase
  for kDato := 0 to high(datos) do
  begin
    aDato := datos[kDato];
    aCluster := clusters[0];
    kMejor := 0;
    dMejor := aDato.d_alfa(aCluster.centroide) + aDato.d_p(aCluster.Centroide);
    for kCluster := 1 to high(Clusters) do
    begin
      aCluster := clusters[kCluster];
      dTest := aDato.d_alfa(aCluster.centroide) + aDato.d_p(aCluster.centroide);
      if dTest < dMejor then
      begin
        kMejor := kCluster;
        dMejor := dTest;
      end;
    end;

    if kMejor <> iCluster.e(kDato + 1) then
    begin
      iCluster.pon_e(kDato + 1, kMejor);
      Inc(cnt_cambios);
    end;
    Inc(clusters[kMejor].cnt_integrantes);
  end;

  writeln('cnt_iters: ', cnt_iteraciones, ' : cambios: ', cnt_cambios);
  if cnt_cambios > 0 then
    RecalcularCentroides;
  Result := cnt_cambios;
end;

procedure TClasificador_K_Means.RecalcularCentroides;
var
  kCluster, kDato: integer;
  aCluster: TClusterRec;
begin
  // limpiamos los acumuladores
  for kCluster := 0 to high(Clusters) do
    Clusters[kCluster].centroide.p.Ceros;

  // recorremos los datos y los sumamos al que corresponda
  for kDato := 0 to high(datos) do
  begin
    kCluster := iCluster.e(kDato + 1);
    clusters[kCluster].centroide.p.sum(datos[kDato].p);
  end;

  // ahora promediamos
  for kCluster := 0 to high(Clusters) do
  begin
    aCluster := Clusters[kCluster];
    aCluster.centroide.p.PorReal(1 / aCluster.cnt_integrantes);
  end;

end;

procedure TClasificador_K_Means.CalcularAB;
var
  kCluster: integer;
begin
  for kCluster := 0 to high(clusters) do
    clusters[kCLuster].CalcAB(datos, iCluster, kCluster);
end;



procedure TClasificador_K_Means.InicializarCentroidesRND;
var
  flg_Seleccionado: TVectBool;
  kCluster, kDato: integer;
  NDatos: integer;
  unif: uniform.T_UNIFORM_RND_GENERATOR;
  buscando: boolean;

begin
  NDatos := length(datos);
  flg_Seleccionado := TVectBool.Create_Init(NDatos);
  flg_Seleccionado.Ceros;
  unif := T_UNIFORM_RND_GENERATOR.Create(31);
  // Para inicializar cargamos al azar un centroide en cada cluster
  // cuidando de que no se repitan
  for kCluster := 0 to high(clusters) do
  begin
    kDato := trunc(unif.Call_UNI * NDatos);
    buscando := True;
    while buscando do
    begin
      if kDato >= NDatos then
        kDato := 0;
      if flg_Seleccionado.e(kDato + 1) then
        Inc(kDato)
      else
      begin
        buscando := False;
        Clusters[kCluster].centroide.CopyFrom(datos[kDato]);
        flg_Seleccionado.pon_e(kDato + 1, True);
      end;
    end;
  end;
  flg_Seleccionado.Free;
  unif.Free;
end;



{ TClasificador_K_Means }

constructor TClasificador_K_Means.Create(datos: TDAOfDatoRec;
  k_clusters, NMaxIteraciones: integer);
var
  // Conjunto de vectores para almacenar los centroides y los vectores asociados
  NDatos: integer;
  kDato, kCluster: integer;

begin
  inherited Create;
  self.datos := datos;
  self.K_Clusters := k_CLusters;
  self.NMaxIteraciones := NMaxIteraciones;
  flg_convergio := False;

  NDatos := length(datos);
  if k_Clusters > NDatos then
    raise Exception.Create('No tiene sentdio k_Clusters > NDatos ');

  setlength(Clusters, k_clusters);
  for kCluster := 0 to k_Clusters - 1 do
    Clusters[kCluster] := TClusterRec.Create(datos[0].alfa.n, datos[0].p.n);

  // Iniciamos con centroides elegidos al azar
  InicializarCentroidesRND;

  // Inicializamos el vector de asignación en -1
  iCluster := TVectE.Create_Init(NDatos);
  for kDato := 1 to length(datos) do
    iCluster.pon_e(kDato, -1); // no clasificado

  cnt_iteraciones := 0;
  flg_convergio := False;
  while (not flg_convergio) and (cnt_iteraciones < NMaxIteraciones) do
  begin
    if ReclasificarDatos > 0 then
      Inc(cnt_iteraciones)
    else
      flg_convergio := True;
  end;
end;

procedure TClasificador_K_Means.WritToArchiODS(archi: string);
var
  f: TLibroOpenCalc;
  kCluster, kDato: integer;
  aDato: TDatoRec;
  aCluster: TClusterRec;
begin
  f := TLibroOpenCalc.Create(True, archi);
  f.Write('NIteraciones:');
  f.Write(cnt_iteraciones);
  f.Write('NMaxIteraciones:');
  f.Write(NMaxIteraciones);
  f.writeln;

  f.writeln('Clusters: ');
  for kCluster := 0 to high(clusters) do
  begin
    aCluster := clusters[kCluster];
    f.Write(kCluster);
    aCluster.writeToOds(f);
    f.writeln;
  end;

  f.writeln;
  f.writeln('Datos:');
  for kDato := 0 to high(datos) do
  begin
    aDato := datos[kDato];
    f.Write(kDato);
    f.Write(iCluster.e(kDato + 1));
    aDato.WriteToODS(F);
    f.writeln;
  end;
  f.Free;

end;

destructor TClasificador_K_Means.Destroy;
var
  kDato, kCluster: integer;
begin
  for kDato := 0 to high(datos) do
    datos[kDato].Free;
  setlength(datos, 0);

  for kCluster := 0 to high(clusters) do
    clusters[kCluster].Free;
  setlength(clusters, 0);
end;


{ TClusterRec }

constructor TClusterRec.Create(dim_alfa, dim_p: integer);
begin
  inherited Create;
  A := nil;
  B := nil;
  centroide := TDatoRec.Create_Vacio(dim_alfa, dim_p);
  cnt_integrantes := 0;
end;

destructor TClusterRec.Destroy;
begin
  if A <> nil then
    A.Free;
  if B <> nil then
    B.Free;
  centroide.Free;
  inherited Destroy;
end;

function TClusterRec.distancia(aDato: TDatoRec): NReal;
begin
  Result := centroide.d_alfa(aDato) + centroide.d_p(aDato);
end;

function TClusterRec.Calc_e2(aDato: TDatoRec): NReal;
var
  e2: NReal;
  k: integer;
begin
  e2 := 0;
  for k := 1 to A.nf do
    e2 := sqr(A.pm[k].PEV(aDato.alfa) + B.pv[k] - aDato.p.pv[k]);
  Result := e2;
end;


procedure TClusterRec.WriteToODS(f: TLibroOpenCalc);
begin
  f.Write(cnt_integrantes);
  centroide.WriteToODS(f);
end;



procedure TClusterRec.CalcAB(datos: TDAOfDatoRec; iCluster: TVectE; kCluster: integer);
var
  flg_Valido: TDAOfBoolean;
  kdato: integer;
begin
  setlength(flg_valido, length(datos));
  for kDato := 0 to high(datos) do
    flg_valido[kDato] := iCluster.e(kDato + 1) = kCluster;
  CalcMinCuad_AB(A, B, datos, flg_valido);
  setlength(flg_Valido, 0);
end;


{ TDatoRec }

constructor TDatoRec.Create(dt: TDateTime; P_: TVectR; alfa_: TVectR);
begin
  inherited Create;
  p := P_;
  alfa := alfa_;
  self.dt := dt;
end;

constructor TDatoRec.Create_Vacio(dim_alfa, dimp_p: integer);
begin
  inherited Create;
  p := TVectR.Create_Init(dim_alfa);
  alfa := TVectR.Create_Init(dimp_p);
end;


destructor TDatoRec.Destroy;
begin
  p.Free;
  alfa.Free;
  inherited Destroy;
end;


function TDatoRec.d_alfa(const a: TDatoRec): NReal;
begin
  Result := alfa.distancia(a.alfa);
end;


function TDatoRec.d_p(const a: TDatoRec): NReal;
begin
  Result := p.distancia(a.p);
end;

procedure TDatoRec.CopyFrom(aRec: TDatoRec);
begin
  dt := aRec.dt;
  alfa.Copy(aRec.alfa);
  p.Copy(aRec.p);
end;

procedure TDatoRec.WriteToODS(f: TLibroOpenCalc);
var
  k: integer;

begin
  f.Write( dt );

  for k := 1 to alfa.n do
    f.Write(alfa.e(k));

  for k := 1 to p.n do
    f.Write(p.e(k));
end;

end.
