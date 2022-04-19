{xDEFINE NORMALIZAR_RESTRICCIONES}
{xDEFINE ABORTARAOPTIMIZACIONSINOESMEJORABLE}
//Corta una rama si el (fval del mejor nodo / fval) < fvalMejorSobreFvalActualMinimo
{xDEFINE RELAJACIONENCADENA}
//Intenta relajar primero variables que en el padre estuvieran relajadas
{xDEFINE DBG_CONTAR_CNT_MIPSIMPLEX}
//Lleva un contador de la cantidad de nodos que le quedan por resolver
//en el arbol actual

{xDEFINE MIP_DBG}

unit umipsimplex;

{$MODE Delphi}

interface

uses
  SysUtils, xMatDefs, Math, usimplex, MatReal;
//   uListaViolacionesPermitidasSimplex;

{$IFDEF ABORTARAOPTIMIZACIONSINOESMEJORABLE}
const
  fvalMejorSobreFvalActualMinimo =
    (1.0 + 1.0 / 1000);//Si el fval de mi nodo sobre el mejor
//fval hallado no es mayor a esto ya no
//sigo desrelajando este nodo, pues puedo
//mejorar muy poco
{$ENDIF}
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
const
  cantNodosSignificativa = 1.0E+18;
{$ENDIF}

type
  TEstadoFichaNodo = (
    CN_NoAsignado,
    CN_EliminadoPor_fval,
    CN_EliminadoPor_infactible,
    CN_MejorFactible,
    CN_Relajado);


  ContadorParaCombinatoria = system.extended;
  TFichaNodoProblema = class;
  TDAOfFichaNodoProblema = array of TFichaNodoProblema;
  TDAOfAcoplesVEnts = array of TListaAcoplesVEntera;

  TFichaNodoProblema = class
  public
    Padre: TFichaNodoProblema;
    esFactible: boolean;
    Estado: TEstadoFichaNodo;
    kx_Relajada: integer; // indice de la variable entera relajada en base a la cual
    // se generan los sub-arboles.
    x: TDAofNReal; // resultado del simplex
    //y, xmult, ymult: TDAOfNReal; // resultado del simplex
    fval: NReal; // valor de la funci�n a maximiar para esta sol.
    nodo_izq: TFichaNodoProblema;
    nodo_der: TFichaNodoProblema;
    spx: TSimplex; // guarda una copia del problema con las modificaciones
    // de cotas que identifican al nodo. spx no se usa para
    // resolver, se usa s�lo para crear las ramas del nodo
    // agregando las modificaciones de cota de cada rama

    res_spx: integer; // resultado del resolver del simplex

    arbolCerrado: boolean;
    lstvents: TDAOfNInt;
    lstAcoplesVEnts: TDAOfAcoplesVEnts;
{$IFDEF RELAJACIONENCADENA}
    relajadas: TDAOfBoolean;
{$ENDIF}
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
    nVarsNoFijadas: integer;
{$ENDIF}
    kDesrelajar: integer;
    ires: NReal; // valor de la variable relajada en el padre
    sentido: integer;

    constructor Create_Raiz(xspx: TSimplex;
    // pasa el problema relajado del padre sin resolver
      xlstvents: TDAOfNInt; // es la l�sta de los indices de las variables enteras
      xlstAcoplesVEnts: TDAOfAcoplesVEnts);

    constructor Create_Desrelajando(xPadre: TFichaNodoProblema;
      xspx: TSimplex; // pasa el problema relajado del padre sin resolver
      xlstvents: TDAOfNInt; // es la l�sta de los indices de las variables enteras
      xlstAcoplesVEnts: TDAOfAcoplesVEnts; xkEnteraDesrelajar: integer;
    // es el indice en la lista de variables enteras que corresponde a la variable a desrelajar
      xires: NReal; // es el resultado de la optimizaci�n para la variable a desrelajar
      xsentido: integer // -1 es desrelajar hacia la izquierda, 1 hacia la derecha
      );
    procedure Free; virtual;
    function Solve(ElNodoRaiz: TFichaNodoProblema;
      var ElMejorNodoFactible: TFichaNodoProblema;
      const Carpeta_ParaDump: string): boolean;
    procedure PrintSolEncabs(var f: textfile);
    procedure PrintSolVals(var f: Textfile);
    function primerCerradoEnLaCadenaHaciaArriba: TFichaNodoProblema;
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
    function cnt_Relajaciones_Hacia_Abajo: ContadorParaCombinatoria;
    //Retorna la cantidad de nodos que se pueden relajar a partir de la ficha actual
{$ENDIF}
  end;

  TMIPSimplex = class(TSimplex)
  public
    ElNodoRaiz, ElMejorNodoFactible: TFichaNodoProblema;
    nvents: integer;
    //Se indexan desde 0
    lstvents: TDAOfNInt; // lista de las enteras.
    lstAcoplesVEnts: TDAOfAcoplesVEnts;

    constructor Create_init(mfilas, ncolumnas, nenteras: integer;
      xfGetNombreVar, xfGetNombreRes: TFuncNombre);
      reintroduce; virtual;

    function resolver: integer; override;

    function SimplexSolucion: TSimplex;

    procedure set_entera(ivae, ivar: integer; CotaSup: integer); override;

    procedure set_EnteraConAcople(ivae, ivar: integer; CotaSup: integer;
      ivarAcoplada, iresAcoplada: integer); override;

    procedure set_EnteraConAcoples(ivae, ivar: integer; CotaSup: integer;
      lstAcoples: TListaAcoplesVEntera); override;


    procedure fijarCotasSupDeVariablesAcopladas;
    procedure limpiar; override;
    procedure Free;

   (*
     Funciones auxiliares para leer los resultados
   *)
    function xval(ix: integer): NReal; override;
    function yval(iy: integer): NReal; override;
    function xmult(ix: integer): NReal; override;
    function ymult(iy: integer): NReal; override;
    function fval: NReal; override;

    procedure DumpSistemaToXLT(var f: textfile); override;

{$IFDEF NORMALIZAR_RESTRICCIONES}
    //divide las filas de la matriz entre el elemento de mayor valor
    //para reducir los errores de punto flotante
    procedure normalizar;
{$ENDIF}
  end;

  TDAOfTMIPSimplex = array of TMIPSimplex;

(*+doc spxActivo
Esta variable la usamos para apuntar al Simplex que est� bajo resoluci�n.
Lo usamos para monitoreo del simplex. Cuando no est� en rsoluci�n un simplex,
esta variable est� a nil -doc*)
var
  spxActivo: TSimplex;
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
  nodos_Totales, nodos_Recorridos: ContadorParaCombinatoria;
  acum_Nodos_Recorridos: ContadorParaCombinatoria;//acumula la cantidad de nodos
//recorridos hasta que sea un
//valor significativo
{$ENDIF}

implementation

constructor TMIPSimplex.Create_init(mfilas, ncolumnas, nenteras: integer;
  xfGetNombreVar, xfGetNombreRes: TFuncNombre);
var
  i: integer;
begin
  inherited Create_init(mfilas, ncolumnas, xfGetNombreVar, xfGetNombreRes);
  setlength(lstvents, nenteras);
  setLength(lstAcoplesVEnts, nenteras);
  nvents := nenteras;
  for i := 0 to nenteras - 1 do
  begin
    setLength(lstAcoplesVEnts[i], 1);
    lstAcoplesVEnts[i][0].ivar := -1;
    lstAcoplesVEnts[i][0].ires := -1;
  end;
  ElNodoRaiz := nil;
  ElMejorNodoFactible := nil;
end;

procedure TMIPSimplex.limpiar;
var
  i: integer;
begin
  inherited limpiar;
  for i := 0 to nvents - 1 do
  begin
    setLength(lstAcoplesVEnts[i], 1);
    lstAcoplesVEnts[i][0].ivar := -1;
    lstAcoplesVEnts[i][0].ires := -1;
  end;
  if ElMejorNodoFactible <> nil then
  begin
    //    ElMejorNodoFactible.Free;
    ElMejorNodoFactible := nil;
  end;
  if ElNodoRaiz <> nil then
  begin
    ElNodoRaiz.Free;
    ElNodoRaiz := nil;
  end;
end;

procedure TMIPSimplex.Free;
var
  iAcoples: integer;
begin
  if ElNodoraiz <> nil then
  begin
    ElNodoRaiz.Free;
    ElNodoRaiz := nil;
  end;
  ElMejorNodoFactible := nil;
  setlength(lstvents, 0);
  for iAcoples := 0 to high(lstAcoplesVEnts) do
    SetLength(lstAcoplesVEnts[iAcoples], 0);
  setLength(lstAcoplesVEnts, 0);
  inherited Free(True);
end;

procedure TMIPSimplex.set_entera(ivae, ivar: integer; CotaSup: integer);
begin
  lstvents[ivae - 1] := ivar;
  cota_sup_set(ivar, CotaSup);
end;

procedure TMIPSimplex.set_EnteraConAcople(ivae, ivar: integer;
  CotaSup: integer; ivarAcoplada, iresAcoplada: integer);
begin
  lstvents[ivae - 1] := ivar;
  cota_sup_set(ivar, CotaSup);
  setLength(lstAcoplesVEnts[ivae - 1], 0);
  SetLength(lstAcoplesVEnts[ivae - 1], 1);
  lstAcoplesVEnts[ivae - 1][0].ivar := ivarAcoplada;
  lstAcoplesVEnts[ivae - 1][0].ires := iresAcoplada;
end;

procedure TMIPSimplex.set_EnteraConAcoples(ivae, ivar: integer;
  CotaSup: integer; lstAcoples: TListaAcoplesVEntera);
begin
  lstvents[ivae - 1] := ivar;
  cota_sup_set(ivar, CotaSup);
  setLength(lstAcoplesVEnts[ivae - 1], 0);
  lstAcoplesVEnts[ivae - 1] := lstAcoples;
end;

procedure TMIPSimplex.fijarCotasSupDeVariablesAcopladas;
var
  i, j: integer;
  acoples: TListaAcoplesVEntera;
  xsup: NReal;
begin
  acoples := nil;
  for i := 0 to high(lstAcoplesVEnts) do
  begin
    acoples := lstAcoplesVEnts[i];
    if length(acoples) > 0 then
    begin
      for j := 0 to high(acoples) do
      begin
        if (acoples[j].ivar <> -1) and (self.flg_x[acoples[j].ivar] = 0) then
        begin
          xsup := pm[acoples[j].ires].pv[lstvents[i]] *
            (self.x_sup.pv[lstvents[i]] + self.x_inf.pv[lstvents[i]]) * 1.1;
          cota_sup_set(acoples[j].ivar, xsup);
        end;
      end;
    end;
  end;
end;

{$IFDEF NORMALIZAR_RESTRICCIONES}
procedure TMIPSimplex.normalizar;
var
  i, j: integer;
  fila: TVectR;
  maxAbsFila: NReal;
begin
  for i := cnt_RestriccionesRedundantes + 1 to nf - 1 do
  begin
    fila := pm[i];
    //    maxAbsFila:= abs(fila.e(1));
    maxAbsFila := abs(fila.pv[1]);
    for j := 2 to nc do
{      if abs(fila.e(j)) > maxAbsFila then
        maxAbsFila:= abs(fila.e(j)); }
      if abs(fila.pv[j]) > maxAbsFila then
        maxAbsFila := abs(fila.pv[j]);
    if abs(maxAbsFila - 1) > 0.2 then
    begin
      if maxAbsFila > 1E-12 then
        fila.PorReal(1 / maxAbsFila)
      else
        raise Exception.Create('TMIPSimplex.normalizar, MaxAbsFila (' +
          IntToStr(i) + ')= ' + FloatToStr(maxAbsFila) +
          ' < 1E-12 , por favor plantear el problema en forma m�s razonable.');
    end;
  end;
end;

{$ENDIF}

procedure TMIPSimplex.DumpSistemaToXLT(var f: textfile);
var
  k, j: integer;
begin
{$IFDEF DBG_CONTAR_CNT_SIMPLEX}
  if usimplex.cnt_debug >= usimplex.minCnt_DebugParaDump then
  begin
{$ENDIF}
    Write(f, 'NEnteras:', #9, length(lstvents));
    for k := 0 to high(lstvents) do
      Write(f, #9, lstvents[k]);
    writeln(f);
    writeln(f, 'ivae', #9, 'VarAcoplada', #9, 'ResAcoplada');
    for k := 0 to high(lstAcoplesVEnts) do
    begin
      if high(lstAcoplesVEnts[k]) >= 0 then
        for j := 0 to high(lstAcoplesVEnts[k]) do
          writeln(f, k, #9, lstAcoplesVEnts[k][j].ivar, #9, lstAcoplesVEnts[k][j].ires)
      else
        writeln(f, k, #9, -1, #9, -1);
    end;
    inherited DumpSistemaToXLT(f);
    if ElMejorNodoFactible <> nil then
    begin
      writeln(f, '--dump de ElMejorNodoFactible--');
      ElMejorNodoFactible.spx.DumpSistemaToXLT(f);
    end;
{$IFDEF DBG_CONTAR_CNT_SIMPLEX}
  end;
{$ENDIF}
end;

function TMIPSimplex.SimplexSolucion: TSimplex;
begin
  if ElMejorNodoFactible <> nil then
    Result := ElMejorNodoFactible.spx
  else
    Result := nil;
end;

function TMIPSimplex.xval(ix: integer): NReal;
begin
  Result := ElMejorNodoFactible.spx.xval(ix);
end;

function TMIPSimplex.yval(iy: integer): NReal;
begin
  Result := ElMejorNodoFactible.spx.yval(iy);
end;

function TMIPSimplex.xmult(ix: integer): NReal;
begin
  Result := ElMejorNodoFactible.spx.xmult(ix);
end;

function TMIPSimplex.ymult(iy: integer): NReal;
begin
  Result := ElMejorNodoFactible.spx.ymult(iy);
end;

function TMIPSimplex.fval: NReal;
begin
  Result := ElMejorNodoFactible.spx.fval;
end;

function TMIPSimplex.Resolver: integer;
begin
  if ElNodoRaiz <> nil then
    ElNodoRaiz.Free;
  ElMejorNodoFactible := nil;
{$IFDEF NORMALIZAR_RESTRICCIONES}
  normalizar;
{$ENDIF}
  fijarCotasSupDeVariablesAcopladas;
  ElNodoRaiz := TFichaNodoProblema.Create_Raiz(Self, lstvents, lstAcoplesVEnts);
  if ElNodoRaiz.Solve(ElNodoRaiz, ElMejorNodoFactible, 'c:\basura\') then
  begin
    Result := 0;
  end
  else
    Result := -1;
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
  writeln('Nodos Restantes: ', (nodos_Totales - (nodos_Recorridos +
    acum_Nodos_Recorridos)): 8: 0);
{$ENDIF}
end;

procedure TFichaNodoProblema.PrintSolEncabs(var f: textfile);
var
  k: integer;
begin
  Write(f, 'fval');
  for k := 1 to high(x) do
    Write(f, #9, 'x', k);
{  for k:= 1 to high( y ) do
    write( f, #9,'y',k);
  for k:= 1 to high( xmult ) do
    write( f, #9, 'mx',k );
  for k:= 1 to high( ymult ) do
    write( f, #9, 'my', k );}
  writeln(f);
end;

procedure TFichaNodoProblema.PrintSolVals(var f: Textfile);
var
  k: integer;
begin
  Write(f, fval);
  for k := 1 to high(x) do
    Write(f, #9, x[k]);
{  for k:= 1 to high( y ) do
    write( f, #9, y[k] );
  for k:= 1 to high( xmult ) do
    write( f, #9, xmult[k] );
  for k:= 1 to high( ymult ) do
    write( f, #9, ymult[k] );}
  writeln(f);
end;

function TFichaNodoProblema.primerCerradoEnLaCadenaHaciaArriba: TFichaNodoProblema;
var
  aux: TFichaNodoProblema;
begin
  aux := self;
  while (aux.padre <> nil) and (aux.Padre.arbolCerrado) do
    aux := aux.Padre;
  Result := aux;
end;

{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
function TFichaNodoProblema.cnt_Relajaciones_Hacia_Abajo: ContadorParaCombinatoria;
var
  res: ContadorParaCombinatoria;
  i, nVarsNoFijadasRecorridas: integer;
begin
  res := 1;
  nVarsNoFijadasRecorridas := 0;
  i := 0;
  while nVarsNoFijadasRecorridas < nVarsNoFijadas do
  begin
    if abs(spx.flg_x[lstvents[i]]) <> 2 then
    begin
   //      res:= res * (spx.x_sup.e(lstvents[i]) + 1);
      res := res * (spx.x_sup.pv[lstvents[i]] + 1);
      Inc(nVarsNoFijadasRecorridas);
    end;
    Inc(i);
  end;
  Result := res;
end;

{$ENDIF}

constructor TFichaNodoProblema.Create_Raiz(xspx: TSimplex;
  // pasa el problema relajado del padre sin resolver
  xlstvents: TDAOfNInt; // es la l�sta de los indices de las variables enteras
  xlstAcoplesVEnts: TDAOfAcoplesVEnts);
begin
  inherited Create;
  arbolCerrado := False;
  Padre := nil;
  spx := TSimplex.Create_clone(xspx);
  res_spx := -1010; // no corrido.
  Estado := CN_NoAsignado;
  lstvents := xlstvents;
  lstAcoplesVEnts := xlstAcoplesVEnts;
{$IFDEF RELAJACIONENCADENA}
  SetLength(relajadas, length(lstvents));
{$ENDIF}
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
  nVarsNoFijadas := length(lstvents);
  nodos_Totales := cnt_Relajaciones_Hacia_Abajo;
  nodos_Recorridos := 0;
  acum_Nodos_Recorridos := 0;
{$ENDIF}
  kDesrelajar := -1;
  sentido := 0;
  ires := 0.5;
  nodo_izq := nil;
  nodo_der := nil;
end;

constructor TFichaNodoProblema.Create_Desrelajando(xPadre: TFichaNodoProblema;
  xspx: TSimplex; // pasa el problema relajado resuelto por el padre
  xlstvents: TDAOfNInt; // es la l�sta de los indices de las variables enteras
  xlstAcoplesVEnts: TDAOfAcoplesVEnts; xkEnteraDesrelajar: integer;
  // es el indice en la lista de variables enteras que corresponde a la variable a desrelajar
  xires: NReal; // es el resultado de la optimizaci�n para la variable a desrelajar
  xsentido: integer // -1 es desrelajar hacia la izquierda, 1 hacia la derecha
  );

  procedure resolverAcoples;
  var
    iAcoples{, miresY, mivarB, mivarA}: integer;
    Acoples: TListaAcoplesVEntera;
  begin
    Acoples := lstAcoplesVEnts[xkEnteraDesrelajar];
    for iAcoples := 0 to high(Acoples) do
    begin
      if Acoples[iAcoples].ivar <> -1 then
      begin
        spx.FijarVariable(Acoples[iAcoples].ivar, 0);
        spx.declararRestriccionRedundante(Acoples[iAcoples].ires);
      end;
    end;
  end;

var
  xmin, xmax: integer;
  xres: integer;

{$IFDEF SPXCONLOG}
  sdbg: string;
{$ENDIF}
begin
  inherited Create;
  arbolCerrado := False;
  Padre := xPadre;
  nodo_izq := nil;
  nodo_der := nil;

  spx := TSimplex.Create_Clone(xspx);

  // rch@20130307.bugfix
  // spx.cnt_RestriccionesRedundantes_:= 0;
  // en lugar de esto acomodamos las resoluci�n de ingualdades en el Simplex.

  res_spx := -1010; // no corrido.

  Estado := CN_NoAsignado;
  lstvents := xlstvents;
  lstAcoplesVEnts := xlstAcoplesVEnts;
{$IFDEF RELAJACIONENCADENA}
  SetLength(relajadas, length(lstvents));
{$ENDIF}
  sentido := xsentido;
  ires:= xires;

  kDesrelajar := lstVEnts[xkEnteraDesrelajar];
  // bien ahora hacemos la desrelajaci�n
  xmin := round(spx.x_inf.pv[kDesrelajar]);
  xmax := round(spx.x_sup.pv[kDesrelajar] + spx.x_inf.pv[kDesrelajar]);

  // rch@20140727 OJO, agrego esto pues ven�a ires en -0.18 y causa
  // loop de desrelajaciones con xmin = 0 y xmax = 1
  if xmax -xmin = 1 then
  begin
    if sentido < 0 then
      xmax := xmin
    else
      xmin := xmax;
  end
  else
  begin
    xres := round( xires );
    if sentido < 0 then
      xmax := max(xmin, min( xres, xmax-1 ))
    else
      xmin := min(xmax, max( xres, xmin+1 ));
  end;


{$IFDEF SPXCONLOG}
  spxActivo := spx;
  if spx.dbg_on then
  begin
    sdbg := 'MIPSpx Cambio de Rama';
    spx.writelog(sdbg);
  end;
{$ENDIF}

  if xmax = xmin then
  begin
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
    self.nVarsNoFijadas := xPadre.nVarsNoFijadas - 1;
{$ENDIF}
    spx.FijarVariable(kDesrelajar, xmin);

{$IFDEF SPXCONLOG}
    if spx.dbg_on then
    begin
      sdbg := 'MIPSpx Fijar_Variable_Entera x: ' + spx.nombreVars[kDesrelajar] +
        ' valor= ' + IntToStr(xmin);
      spx.writelog(sdbg);
    end;
{$ENDIF}
    if xmin = 0 then
      resolverAcoples;
  end
  else
  if sentido < 0 then
  begin
    spx.cota_sup_set(kDesrelajar, xmax);
{$IFDEF SPXCONLOG}
    if spx.dbg_on then
    begin
      sdbg := 'MIPSpx Desrelajar_Variable_Entera x: ' +
        spx.nombreVars[kDesrelajar] + ' cotaSup= ' +
        IntToStr(round(spx.x_sup.pv[kDesrelajar])) + '->' + IntToStr(xmax);
      spx.writelog(sdbg);
    end;
{$ENDIF}
  end
  else
  begin
    spx.cota_inf_set(kDesrelajar, xmin);
{$IFDEF SPXCONLOG}
    if spx.dbg_on then
    begin
      sdbg := 'MIPSpx Desrelajar_Variable_Entera x: ' +
        spx.nombreVars[kDesrelajar] + ' cotaInf= ' +
        IntToStr(round(spx.x_inf.pv[kDesrelajar])) + '->' + IntToStr(xmin);
      spx.writelog(sdbg);
    end;
{$ENDIF}
  end;
end;

procedure TFichaNodoProblema.Free;
begin
  setlength(x, 0);
{  setlength(y,0);
  setlength(xmult,0);
  setlength(ymult, 0 );}
{$IFDEF RELAJACIONENCADENA}
  SetLength(relajadas, 0);
{$ENDIF}
  if nodo_izq <> nil then
  begin
    nodo_izq.Free;
    nodo_izq := nil;
  end;

  if nodo_der <> nil then
  begin
    nodo_der.Free;
    nodo_der := nil;
  end;
  if spx <> nil then
  begin
    spx.Free(False);
    spx := nil;
  end;
  inherited Free;
end;


function TFichaNodoProblema.Solve(ElNodoRaiz: TFichaNodoProblema;
  var ElMejorNodoFactible: TFichaNodoProblema; const Carpeta_ParaDump: string): boolean;
var
  primer_entera_relajada: integer;
  k: integer;
  RamaDelMejor: boolean;
  nodoAux, nodoAuxPadre: TFichaNodoProblema;
begin

  try
    spxActivo := spx;
    res_spx := spx.resolver;
    spxActivo := nil;
  except
    On E: Exception do
    begin
      spxActivo := nil;
      spx.DumpSistemaToXLT_(Carpeta_ParaDump + 'problema_.XLT', e.Message);
      raise;
    end;
  end;

  if res_spx <> 0 then // rama infactible
  begin
{$IFDEF MIP_DBG}
    writeln('Rama Infactible');
{$ENDIF}
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
    acum_Nodos_Recorridos := acum_Nodos_Recorridos + cnt_Relajaciones_Hacia_Abajo;
    if acum_Nodos_Recorridos > cantNodosSignificativa then
    begin
      nodos_Recorridos := nodos_Recorridos + acum_Nodos_Recorridos;
      acum_Nodos_Recorridos := 0;
    end;
    writeln('Nodos Restantes: ', (nodos_Totales -
      (nodos_Recorridos + acum_Nodos_Recorridos)): 8: 0);
{$ENDIF}
    Estado := CN_EliminadoPor_Infactible;
    Result := False; // eliminar rama
    exit;
  end;

  fval := spx.fval;
  if ElMejorNodoFactible <> nil then
  begin
    if fval <= ElMejorNodoFactible.fval then
      // esta rama se elimina por que no puede mejorar el costo
    begin
{$IFDEF MIP_DBG}
      writeln('Rama Mayorada por la Factible');
{$ENDIF}
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
      acum_Nodos_Recorridos := acum_Nodos_Recorridos + cnt_Relajaciones_Hacia_Abajo;
      if acum_Nodos_Recorridos > cantNodosSignificativa then
      begin
        nodos_Recorridos := nodos_Recorridos + acum_Nodos_Recorridos;
        acum_Nodos_Recorridos := 0;
      end;
      writeln('Nodos Restantes: ', (nodos_Totales -
        (nodos_Recorridos + acum_Nodos_Recorridos)): 8: 0);
{$ENDIF}
      Estado := CN_EliminadoPor_fval;
      Result := False; // eliminar rama
      exit;
    end;

{$IFDEF ABORTARAOPTIMIZACIONSINOESMEJORABLE}
    if ElMejorNodoFactible <> nil then
    begin
      if fval > abs(AsumaCero) and ElMejorNodoFactible.fval / fval <
        fvalMejorSobreFvalActualMinimo then
      begin
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
        acum_Nodos_Recorridos := acum_Nodos_Recorridos + cnt_Relajaciones_Hacia_Abajo;
        if acum_Nodos_Recorridos > cantNodosSignificativa then
        begin
          nodos_Recorridos := nodos_Recorridos + acum_Nodos_Recorridos;
          acum_Nodos_Recorridos := 0;
        end;
        writeln('Nodos Restantes: ',
          (nodos_Totales - (nodos_Recorridos + acum_Nodos_Recorridos)): 8: 0);
{$ENDIF}
        if Padre <> nil then
        begin
          arbolCerrado := True;
          spx.Free;
          spx := nil;
        end;
        Result := False;
        exit;
      end;
    end;
{$ENDIF}
  end;

  // creamos los vectores para guardar el resultado
  setlength(x, spx.nc);
  for k := 1 to spx.nc - 1 do
    x[k] := spx.xval(k);

{$IFDEF RELAJACIONENCADENA}
  // guardo cuales de mis variables estan relajadas
  for k := 0 to high(relajadas) do
    relajadas[k] := abs(frac(x[lstvents[k]])) > usimplex.CasiCero_Simplex;

  primer_entera_relajada := -1;
  // busco la primera variable entera relajada
  for k := 0 to high(relajadas) do
    if relajadas[k] then
    begin
      primer_entera_relajada := k;
      break;
    end;
  //ahora me fijo si alguna de las relajadas no estaba relajada en el padre
  if (primer_entera_relajada <> -1) and (padre <> nil) then
  begin
    for k := primer_entera_relajada to high(relajadas) do
      if relajadas[k] and not padre.relajadas[k] then
      begin
        primer_entera_relajada := k;
        break;
      end;
  end;
{$ELSE}
  // busco la primera variable entera relajada
  primer_entera_relajada := -1;
  for k := 0 to high(lstvents) do
    if abs(frac(x[lstvents[k]])) > usimplex.CasiCero_Simplex then
    begin
      primer_entera_relajada := k;
      break;
    end;
{$ENDIF}
  if primer_entera_relajada < 0 then
  begin
    Estado := CN_MejorFactible;
    if ElMejorNodoFactible <> nil then
    begin
      nodoAux := ElMejorNodoFactible.primerCerradoEnLaCadenaHaciaArriba;
      if nodoAux <> nil then
      begin
        nodoAuxPadre := nodoAux.Padre;
        if nodoAuxPadre <> nil then
        begin
          if nodoAuxPadre.nodo_izq = nodoAux then
            nodoAuxPadre.nodo_izq := nil
          else
            nodoAuxPadre.nodo_der := nil;
        end;
        nodoAux.Free;
      end;
    end;
    ElMejorNodoFactible := Self;
{$IFDEF MIP_DBG}
    writeln('Encontramos un nuevo Mejor Nodo Factible');
{$ENDIF}
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
    acum_Nodos_Recorridos := acum_Nodos_Recorridos + cnt_Relajaciones_Hacia_Abajo;
    if acum_Nodos_Recorridos > cantNodosSignificativa then
    begin
      nodos_Recorridos := nodos_Recorridos + acum_Nodos_Recorridos;
      acum_Nodos_Recorridos := 0;
    end;
    writeln('Nodos Restantes: ', (nodos_Totales -
      (nodos_Recorridos + acum_Nodos_Recorridos)): 8: 0);
{$ENDIF}
    arbolCerrado := True;
    Result := True;
  end
  else
  begin
    Estado := CN_Relajado;
{$IFDEF MIP_DBG}
    writeln('Nodo Relajado Activo');
{$ENDIF}
    kx_relajada := lstvents[primer_entera_relajada];
    RamaDelMejor := False;

    //PA@25/05/07
    //Empezamos por el nodo derecho porque implica tener
    //prendidas todas las maquinas, lo que en general da un
    //costo menor que probar con todas las maquinas apagadas
    //y tener que usar las maquinas de falla. De esta forma
    //el primer nodo factible tiene un costo menor y permite
    //descartar mas nodos intermedios.
    nodo_der := TFichaNodoProblema.Create_Desrelajando(
      Self, spx, lstvents, lstAcoplesVEnts, primer_entera_relajada, x[kx_relajada], 1);
    if not nodo_der.solve(ElNodoRaiz, ElMejorNodoFactible, Carpeta_ParaDump) then
    begin
      nodo_der.Free;
      nodo_der := nil;
    end
    else
      RamaDelMejor := True;

    nodo_izq := TFichaNodoProblema.Create_Desrelajando(
      Self, spx, lstvents, lstAcoplesVEnts, primer_entera_relajada, x[kx_relajada], -1);

    if not nodo_izq.Solve(ElNodoRaiz, ElMejorNodoFactible, Carpeta_ParaDump) then
    begin
      nodo_izq.Free;
      nodo_izq := nil;
    end
    else
      RamaDelMejor := True;
{$IFDEF DBG_CONTAR_CNT_MIPSIMPLEX}
    acum_Nodos_Recorridos := acum_Nodos_Recorridos + 1;
    if acum_Nodos_Recorridos > cantNodosSignificativa then
    begin
      nodos_Recorridos := nodos_Recorridos + acum_Nodos_Recorridos;
      acum_Nodos_Recorridos := 0;
    end;
    //writeln('Nodos Restantes: ', (nodos_Totales - nodos_Recorridos - acum_Nodos_Recorridos):8:0);
{$ENDIF}
    // ya puedo liberar memoria si no soy el raiz
    if (Padre <> nil) then
    begin
      arbolCerrado := True;
      if (self <> ElMejorNodoFactible) then
      begin
        spx.Free(False);
        spx := nil;
      end;
    end;
    Result := RamaDelMejor;
  end;
end;

initialization
  spxActivo := nil;
end.
