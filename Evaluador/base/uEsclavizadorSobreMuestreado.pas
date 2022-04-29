//No usar el define en multihilo
{x$DEFINE DEBUG_SOBREMUESTREADO}
unit uEsclavizadorSobreMuestreado;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  uEsclavizador, uFuentesAleatorias,
  uCosaConNombre,
  uFechas, xMatDefs, uGlobs, uEstados, SysUtils,
  uFuenteSintetizador;

type
  //TEsclavizadorSobreMuestreado
  //Sortea una vez cada mas de un paso de tiempo. Es sobremuestreado pues se
  //muestrea mas veces (1 por paso de tiempo) de las que tiene que sortear
  TEsclavizadorSobreMuestreado = class(TEsclavizador)
  private
    //Los sorteos son utiles desde tA hasta tB (tB = tA + esclava.durPasoDeSorteoEnHoras).
    //La fecha de fin del paso debe estar contenida entre ellos dos para tener
    //valores con los que interpolar
    //tA es el primer instante desde el que son validos los valores en la bornera
    //tB es el primer instante del próximo sorteo es decir tA + esclava.durPasoSorteoEnHoras
    //Se debe calcular valores mientras globs.FechaFinDelPaso no pertenezca
    //a [tA, tB)

    //Se usan en la simulación. En la optimización se tiene un solo valor para
    //cada bloque de la bornera que se mantiene en la bornera de la esclava
    tA, tB: TFecha;
    borneraA, borneraB, bornera_bk: TDAOfNReal;

    //Variables auxiliares para facilitar las cuentas
    pasoTiempoSobrePasoSorteo: NReal;
    unoSobre_dtPasoSorteo: NReal;

    fIniPasoMayorOIgualtB: boolean;
    primerPasoSim: boolean;

{$IFDEF DEBUG_SOBREMUESTREADO}
    fdbg: TextFile;
    procedure writeEncabDebug;
    procedure writeDebug(evento: string);



{$ENDIF}

    // auxiliares de SorteoDelPaso sólo por claridad.
    procedure SorteosDelPaso_Optimizando(xsortear: boolean);
    procedure SorteosDelPaso_Simulando(xsortear: boolean);
    procedure SorteosPrimerPasoSim(xsortear: boolean);
  public
    constructor Create(capa: integer; nombre: string; esclava: TFuenteAleatoria);
    procedure Free; override;

    procedure PrepararMemoria( Catalogo: TCatalogoReferencias; globs: TGlobs); override;
    procedure RegistrarParametrosDinamicos(CatalogoReferencias: TCatalogoReferencias); override;

    //Llena (X)a
    procedure Sim_Cronica_Inicio; override;

    //Llena si hace falta (RB)a, (RB)b
    //Los valores de A, si es el primer paso los sortea y los copia de la
    //fuente sino los swapea con los de B
    procedure SorteosDelPaso(xsortear: boolean); override;

    procedure PosicionarseEnEstrellita; override;

    //Llena (Xs)a y (X)b si hace falta
    //En la esclava llena (RB), (X) y (BC) con la interpolación entre la
    //bornera A y la bornera B
    //(Xs) lo llena con (X) mas la pendiente de la interpolacion por un paso
    //de tiempo sobre el paso de sorteo
    procedure PrepararPaso_ps; override;

    //Llena (X)a si hace falta con los valores de (X)b
    procedure EvolucionarEstado; override;

    function calc_DeltaCosto: NReal; override;

    procedure InicioSim; override;
    procedure InicioOpt; override;


    procedure Dump_Variables(var f: TextFile; charIndentacion: char); override;
//    procedure PubliVars; override;
  end;

implementation

constructor TEsclavizadorSobreMuestreado.Create(capa: integer;
  nombre: string; esclava: TFuenteAleatoria);
begin
  inherited Create(
    capa,
    nombre,
    0, // le paso CERO pues el esclavizador es sincrono.
    False); // no tiene nada que resumir

  tA := TFecha.Create_Dt(now());
  tB := TFecha.Create_Dt(now());
  self.nombre := nombre;
  self.esclava := esclava;
end;

procedure TEsclavizadorSobreMuestreado.Free;
begin
{$IFDEF DEBUG_SOBREMUESTREADO}
  CloseFile(fdbg);
{$ENDIF}

  if borneraA <> nil then
    SetLength(borneraA, 0);
  if borneraB <> nil then
    SetLength(borneraB, 0);
  if bornera_BK <> nil then
    setlength(bornera_bk, 0);

  tA.Free;
  tB.Free;
  if esclava <> nil then
    esclava.Free;
  inherited Free;
end;

procedure TEsclavizadorSobreMuestreado.PrepararMemoria(
  Catalogo: TCatalogoReferencias; globs: TGlobs);
begin
  inherited PrepararMemoria(Catalogo, globs);
  esclava.PrepararMemoria(Catalogo, globs);

  inherited copiarJs;

  SetLength(borneraA, length(esclava.Bornera));
  SetLength(borneraB, length(esclava.Bornera));
  SetLength(bornera_BK, length(esclava.Bornera));

  assert((esclava.durPasoDeSorteoEnHoras <> 0) and
    (esclava.durPasoDeSorteoEnHoras <> globs.HorasDelPaso),
    'TEsclavizadorSobreMuestreado.PrepararMemoria:' + 'La fuente ' +
    esclava.nombre + 'es sincrona y se la remplazo por un TEsclavizadorSobreMuestreado');

  self.unoSobre_dtPasoSorteo := 24.0 / esclava.durPasoDeSorteoEnHoras;
  pasoTiempoSobrePasoSorteo := globs.HorasDelPaso / esclava.durPasoDeSorteoEnHoras;

{$IFDEF DEBUG_SOBREMUESTREADO}
  AssignFile(fdbg, '\simsee\debug\' + ClassName + '_' + nombre + '.xlt');
  Rewrite(fdbg);
  writeEncabDebug;
{$ENDIF}
end;

procedure TEsclavizadorSobreMuestreado.RegistrarParametrosDinamicos(
  CatalogoReferencias: TCatalogoReferencias);
begin
  esclava.RegistrarParametrosDinamicos( CatalogoReferencias );
end;

procedure TEsclavizadorSobreMuestreado.Sim_Cronica_Inicio;
begin
  tA.PonerIgualA(globs.FechaInicioDelpaso);
  //Nace vencido y se arregla en sorteosDelPaso por ser el primer paso sim
  tB.dt := 0;
  esclava.Sim_Cronica_Inicio;
  if esclava.dim_X > 0 then
    vcopyTramo(borneraA, esclava.Bornera, jPrimer_X, esclava.dim_X);
  fIniPasoMayorOIgualtB := False;
  primerPasoSim := True;

{$IFDEF DEBUG_SOBREMUESTREADO}
  writeDebug('Sim_Cronica_Inicio');
{$ENDIF}
end;

procedure TEsclavizadorSobreMuestreado.SorteosDelPaso_Optimizando(xsortear: boolean);
begin
  //Lleno (RB) y (BC) en la esclava
  esclava.SorteosDelPaso(xsortear);
end;


procedure TEsclavizadorSobreMuestreado.SorteosPrimerPasoSim(xsortear: boolean);
begin
  //Lleno (RB)a
  if esclava.dim_RB > 0 then
  begin
    esclava.SorteosDelPaso(xsortear);
    vcopyTramo(borneraA, esclava.Bornera, jPrimer_RB_, esclava.dim_RB);
  end;

  //(X)a y (RB)a -> Lleno (Xs)a
  if esclava.dim_Xs > 0 then
  begin
    esclava.calcular_Xs;
    vcopyTramo(borneraA, esclava.Bornera, jPrimer_Xs, esclava.dim_Xs);
  end;

  //Lleno (BC)a. Esto se debiera hacer en calcular_BC, pero como sabemos
  //que estamos simulando lo calculamos aca para evitar copias innecesarias
  //de las borneras
  if esclava.dim_BC > 0 then
  begin
    esclava.calcular_BC;
    vcopyTramo(borneraA, esclava.Bornera, jPrimer_BC, esclava.dim_BC);
  end;
  //La bornera A queda completa luego de esto
  tB.PonerIgualAMasOffsetHoras(ta, esclava.durPasoDeSorteoEnHoras);
end;

procedure TEsclavizadorSobreMuestreado.SorteosDelPaso_Simulando(xsortear: boolean);
var
  FIPbk: TFecha;

begin
  Assert(tA.menorOIgualQue(globs.FechaInicioDelpaso),
    'TEsclavizadorSobreMuestreado.SorteosDelPaso: la fecha del ultimo sorteo es posterior a la fecha del paso de tiempo');

  if globs.FechaInicioDelpaso.mayorOIgualQue(tb) then
  begin
    //....tA...........tB..t.........
    fIniPasoMayorOIgualtB := True;

    if primerPasoSim then
      SorteosPrimerPasoSim(xsortear)
    else
    begin
      //Los valores anteriores de la bornera pasan a ser los que eran siguientes
      vswap(borneraA, borneraB);
      tA.PonerIgualA(tB);
      tB.addHoras(esclava.durPasoDeSorteoEnHoras);
    end;

    // respaldo la fecha de inicio del paso para poder fijarla para que la fuente
    // vea la información (por ejemplo deformadores en las CEGH) para el instante tB.
    FIPbk := TFecha.Create_Clone(globs.FechaInicioDelpaso);

    // ahora fijamos el tiempo en el futuro para que la esclava lo vea.
    globs.Fijar_FechaInicioDelPaso(tB);

    // ahora calculamos la bornera B

    //Primero que la esclava genere los sorteos de ruido blanco (tramo RB)
    // y los copiamos a la bornera B.
    if esclava.dim_RB > 0 then
    begin
      esclava.SorteosDelPaso(xsortear);
      vcopyTramo(borneraB, esclava.Bornera, jPrimer_RB_, esclava.dim_RB);
    end;

    // ahora, si hay estado, llenamos el X de la bornera B con el Xs de la
    // bornera A que sería lo que quedaría al evolucionar el estado.
    //Lleno (X)b = (Xs)a
    if esclava.dim_Xs > 0 then
    begin
      vcopyTramoDesplazando(borneraB, jPrimer_X, borneraA, jPrimer_Xs, dim_Xs);

      // OJO **********************+++
      // esto es lo que está armando lio. Está dejando la fuente esclava
      // con el estado de la borneraB y eso joroba en el SetEstado.
      // repaldo el estado X de la bornera de la esclava para poder restituírselo.
      // hay que analizar si esto es una macana introducida por tratar de "optimizar"
      // más abajo le reestablezco los valores a la esclava
      vcopyTramo(Bornera_BK, esclava.bornera, jPrimer_X, dim_X);

      // ahora le pongo a la esclava los valores de X de la borneraB para que pueda calcular
      vcopyTramo(esclava.Bornera, borneraB, jPrimer_X, dim_X);
    end;


    // Ahora que ya hicimos las cuentas, le vuelvo a la esclava sus valores
    // originales del estado para que funcione correctamente el fijar estado
    // global del sistema que se hace antes de prepararpaso_ps
    if esclava.dim_Xs > 0 then
      vcopyTramo(esclava.bornera, Bornera_BK, jPrimer_X, dim_X);


    // restablecemos la fecha de inicio del paso en la sala para que todos
    // vean el tiempo correcto.
    globs.Fijar_FechaInicioDelPaso(FIPbk);
    FIPbk.Free;
  end;
end;


procedure TEsclavizadorSobreMuestreado.SorteosDelPaso(xsortear: boolean);
begin
  if globs.EstadoDeLaSala = CES_OPTIMIZANDO then //Optimizacion
    SorteosDelPaso_Optimizando(xsortear)
  else //Simulacion
    SorteosDelPaso_Simulando(xsortear);

{$IFDEF DEBUG_SOBREMUESTREADO}
  writeDebug('SorteosDelPaso');
{$ENDIF}
end;

procedure TEsclavizadorSobreMuestreado.PosicionarseEnEstrellita;
begin
  esclava.PosicionarseEnEstrellita;

{$IFDEF DEBUG_SOBREMUESTREADO}
  writeDebug('PosicionarseEnEstrellita');
{$ENDIF}
end;

procedure TEsclavizadorSobreMuestreado.PrepararPaso_ps;
var
  i: integer;
  dx, frt: NReal;
  fechaAnteriorAlFijarFecha: TFecha;
begin
  if globs.EstadoDeLaSala = CES_OPTIMIZANDO then //Optimizacion
  begin
    // Llena el (Xs)
    esclava.PrepararPaso_ps;

    //OJO Revisar el deltaCosto

    // En el Xs de la esclava dejamos la interpolacíon entre X y Xs avanzando
    // horasDelPaso en vez de durPasoSorteo
    for i := 0 to esclava.dim_X - 1 do
    begin
      dx := esclava.Bornera[i + jPrimer_Xs] - esclava.Bornera[i + jPrimer_X];
      {$IFDEF NO_INTERPOLA_SUBMUESTREOS}
      esclava.Bornera[i + jPrimer_Xs] :=
        esclava.Bornera[i + jPrimer_X];
      {$ELSE}
      esclava.Bornera[i + jPrimer_Xs] :=
        esclava.Bornera[i + jPrimer_X] + dx * pasoTiempoSobrePasoSorteo;
      {$ENDIF}
    end;
  end
  else //Simulacion
  begin
    if fIniPasoMayorOIgualtB then
    begin
      fechaAnteriorAlFijarFecha := TFecha.Create_Clone(globs.FechaInicioDelpaso);
      globs.Fijar_FechaInicioDelPaso(tB);

      //(RB) = (RB)b
      if esclava.dim_RB > 0 then
        vcopyTramo(esclava.bornera, borneraB, jPrimer_RB_, esclava.dim_RB);

      if esclava.dim_Wa > 0 then
        vcopyTramo(esclava.bornera, borneraB, jPrimer_Wa_, esclava.dim_Wa);

      //(X) = (X)b
      if esclava.dim_X > 0 then
        vcopyTramo(esclava.bornera, borneraB, jPrimer_X, esclava.dim_X);

      // Tengo (RB) y (X) => calculo (Xs)
      esclava.PrepararPaso_ps;
      //Lleno (Xs)b
      if esclava.dim_Xs > 0 then
        vcopyTramo(borneraB, esclava.bornera, jPrimer_Xs, esclava.dim_Xs);

      globs.Fijar_FechaInicioDelPaso(fechaAnteriorAlFijarFecha);
      fechaAnteriorAlFijarFecha.Free;
    end;

(** ojo HorasHasta me trucaba e interfería con diezminutal
    frt := tA.HorasHasta(globs.FechaInicioDelpaso) * unoSobreDurPasoSorteo;
    frtSig := (tA.HorasHasta(globs.FechaInicioDelpaso) + globs.HorasDelPaso) *
      unoSobreDurPasoSorteo;
   ***)

    {$IFDEF NO_INTERPOLA_SUBMUESTREOS}
    for i := jPrimer_RB_ to jUltimo_RB_ do
      esclava.Bornera[i] := BorneraA[i];
    {$ELSE}
    frt := (globs.FechaInicioDelpaso.dt - tA.dt) * unoSobre_dtPasoSorteo;
    //Interpolo la bornera de la esclava
    for i := jPrimer_RB_ to jUltimo_RB_ do
    begin
      dx := BorneraB[i] - BorneraA[i];
      esclava.Bornera[i] := BorneraA[i] + dx * frt;
    end;
   {$ENDIF}

(*** ojo esto decía
    offsetXXs := jPrimer_Xs - jPrimer_X;
    for i := jPrimer_X to jUltimo_X do
    begin
      dx := BorneraB[i] - BorneraA[i];
      esclava.Bornera[i] := BorneraA[i] + dx * frt;
      esclava.Bornera[i + offsetXXs] := BorneraA[i] + dx * frtSig;
    end;
    ***)

    {$IFDEF NO_INTERPOLA_SUBMUESTREOS}
    for i := jPrimer_X to jUltimo_X do
      esclava.Bornera[i] := BorneraA[i] ;
    for i := jPrimer_Xs to jUltimo_Xs do
      esclava.Bornera[i] := BorneraA[i] ;
    {$ELSE}
    // cambio por esto otro abierto en dos for
    for i := jPrimer_X to jUltimo_X do
    begin
      dx := BorneraB[i] - BorneraA[i];
      esclava.Bornera[i] := BorneraA[i] + dx * frt;
    end;
    for i := jPrimer_Xs to jUltimo_Xs do
    begin
      dx := BorneraB[i] - BorneraA[i];
      esclava.Bornera[i] := BorneraA[i] + dx * frt;
    end;
    {$ENDIF}

    (*
    for i := jPrimer_BC to jUltimo_BC do
    begin
      dx := BorneraB[i] - BorneraA[i];
      esclava.Bornera[i] := BorneraA[i] + dx * frt;
    end;
      *)
  end;

  esclava.calcular_BC;

{$IFDEF DEBUG_SOBREMUESTREADO}
  writeDebug('PrepararPaso_ps');
{$ENDIF}
end;


procedure TEsclavizadorSobreMuestreado.EvolucionarEstado;
begin
  if fIniPasoMayorOIgualtB then
  begin
    if primerPasoSim then
      primerPasoSim := False;
    fIniPasoMayorOIgualtB := False;
  end;
  esclava.EvolucionarEstado;

{$IFDEF DEBUG_SOBREMUESTREADO}
  writeDebug('EvolucionarEstadoActual');
{$ENDIF}
end;

function TEsclavizadorSobreMuestreado.calc_DeltaCosto: NReal;
begin
  Result := esclava.calc_DeltaCosto * pasoTiempoSobrePasoSorteo;
end;

procedure TEsclavizadorSobreMuestreado.InicioSim;
begin
  inherited InicioSim;
  esclava.InicioSim;
end;

procedure TEsclavizadorSobreMuestreado.InicioOpt;
begin
  inherited InicioOpt;
  esclava.InicioOpt;
end;

procedure TEsclavizadorSobreMuestreado.Dump_Variables(var f: TextFile;
  charIndentacion: char);
var
  i: integer;
begin
  inherited Dump_Variables(f, charIndentacion);
  writeln(f, charIndentacion + 'tA= ' + tA.AsISOStr);
  Writeln(f, charIndentacion + 'tB= ' + tB.AsISOStr);

  writeln(f, charIndentacion + 'frt= ' + FloatToStrF(
    (globs.FechaInicioDelpaso.dt - tA.dt) * unoSobre_dtPasoSorteo, ffFixed, 8, 8));

  for i := 0 to high(borneraA) do
    writeln(f, charIndentacion, 'borneraA[' + IntToStr(i) + ']= ',
      FloatToStr(borneraA[i]));
  for i := 0 to high(borneraB) do
    writeln(f, charIndentacion, 'borneraB[' + IntToStr(i) + ']= ',
      FloatToStr(borneraB[i]));

  writeln(f, charIndentacion + StringReplace(esclava.descBornera,
    '#10', #10 + charIndentacion, [rfReplaceAll]));
  for i := 0 to high(esclava.Bornera) do
    writeln(f, charIndentacion, 'esclava.bornera[' + IntToStr(i) +
      ']= ', FloatToStr(esclava.Bornera[i]));
end;

(**
procedure TEsclavizadorSobreMuestreado.PubliVars;
var
  i: integer;
begin
  inherited Publivars;
  for i := 0 to esclava.variablesParaSimRes.Count - 1 do
    variablesParaSimRes.Add(esclava.variablesParaSimRes.Items[i]);
end;
**)

{$IFDEF DEBUG_SOBREMUESTREADO}
procedure TEsclavizadorSobreMuestreado.writeEncabDebug;
var
  i: integer;
  indice: string;
begin
  Write(fdbg, 'Evento'#9'FIniPaso'#9'tA'#9'tB');
  for i := jPrimer_RB to jUltimo_RB do
  begin
    indice := IntToStr(i - jPrimer_RB);
    Write(fdbg, #9'RB(A[' + indice + '])'#9'RB(B[' + indice +
      '])'#9'RB(Esc[' + indice + '])');
  end;

  for i := jPrimer_X to jUltimo_X do
  begin
    indice := IntToStr(i - jPrimer_X);
    Write(fdbg, #9'X(A[' + indice + '])'#9'X(B[' + indice + '])'#9'X(Esc[' +
      indice + '])');
  end;

  for i := jPrimer_Xs to jUltimo_XS do
  begin
    indice := IntToStr(i - jPrimer_Xs);
    Write(fdbg, #9'Xs(A[' + indice + '])'#9'Xs(B[' + indice +
      '])'#9'Xs(Esc[' + indice + '])');
  end;

  for i := jPrimer_BC to jUltimo_BC do
  begin
    indice := IntToStr(i - jPrimer_BC);
    Write(fdbg, #9'BC(A[' + indice + '])'#9'BC(B[' + indice +
      '])'#9'BC(Esc[' + indice + '])');
  end;
  Writeln(fdbg);
end;

procedure TEsclavizadorSobreMuestreado.writeDebug(evento: string);
var
  i: integer;
begin
  Write(fdbg, evento, #9, globs.FechaInicioDelpaso.AsStr, #9, tA.AsStr, #9, tB.AsStr);

  for i := jPrimer_RB to jUltimo_RB do
    Write(fdbg, #9, borneraA[i], #9, borneraB[i], #9, esclava.Bornera[i]);

  for i := jPrimer_X to jUltimo_X do
    Write(fdbg, #9, borneraA[i], #9, borneraB[i], #9, esclava.Bornera[i]);

  for i := jPrimer_Xs to jUltimo_XS do
    Write(fdbg, #9, borneraA[i], #9, borneraB[i], #9, esclava.Bornera[i]);

  for i := jPrimer_BC to jUltimo_BC do
    Write(fdbg, #9, borneraA[i], #9, borneraB[i], #9, esclava.Bornera[i]);
  Writeln(fdbg);
end;

{$ENDIF}

end.
