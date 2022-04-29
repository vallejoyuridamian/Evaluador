unit uEsclavizadorSubMuestreado;

interface

uses
  uEsclavizador, uFuentesAleatorias, uFechas, xMatDefs,
  uCosaConNombre,
  uGlobs,
  SysUtils,
  Math,
  uConstantesSimSEE;

type
  //TEsclavizadorSubMuestreado
  //Sortea muchas veces dentro de un paso de tiempo. Es submuestreado pues se
  //muestrea menos veces (1 por paso de tiempo) de las que tiene que sortear
  TEsclavizadorSubMuestreado = class(TEsclavizador)
  private
    //Fecha de comienzo del ultimo sorteo realizado
    tA: TFecha;

    //La cantidad de veces que se deben muestrear valores es: nMuestrasDelPaso =
    //ceil((tA.HorasHasta(globs.FechaFinDelPaso) + 1) / esclava.durPasoDeSorteoEnHoras)
    nMuestrasDelPaso: integer;

    //Borneras debe ser capaz de contener la máxima cantidad de valores que
    //deban calcularse, por lo que debe ser de tamaño
    //trunc(globs.horasDelPaso - 1 / esclava.durPasoDeSorteoEnHoras) + 1
    borneras: array of TDAofNReal;

    kpostes_borneras: TDAOfNInt;

    // si las borneas son horarias tiene el poste de cada bornera
    rxvals: TDAOfNreal; // auxiliar para mecanismo de máxima varianza por borne

    jRandomVals: TDAOfNInt; // auxiliar para mecanismo de máxima varianza

    //Variables auxiliares para facilitar las cuentas
    pasoSorteoSobrePasoTiempo: NReal;

  public

    // si es verdadero, las borneras se resumen con el promedio
    // si es false se resumen con un sorteo uniforme entre las muestras
    // de esa forma se consigue el mismo valor esperado que el promedio
    // pero la varianza es la de las muestras y no la del promedio.
    promediarMuestras: boolean;

    constructor Create(capa: integer; nombre: string; esclava: TFuenteAleatoria;
      xpromediarMuestras: boolean);
    procedure Free; override;

    procedure PrepararMemoria( Catalogo: TCatalogoReferencias; globs: TGlobs); override;
    procedure RegistrarParametrosDinamicos(CatalogoReferencias: TCatalogoReferencias); override;

    //Llena (X)a
    procedure Sim_Cronica_Inicio; override;


    procedure InicioSim; override;
    procedure InicioOpt; override;

    //Llena si hace falta (RB)a, (BC)a, (RB)b y (BC)b
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

    procedure Dump_Variables(var f: TextFile; charIndentacion: char); override;
//    procedure PubliVars; override;

  private
    // realiza los sorteos de cada subpaso en la esclava y copia
    // los valores a las Borneras. El procedimiento es diferente
    // si se está en Optimización que si se está en Simulación.
    procedure SorteosSubpasosOPT(xsortear: boolean);
    procedure SorteosSubpasosSIM(xsortear: boolean);

  end;


resourcestring
  ms_LaFuente = 'La fuente';
  ms_TienePasoDeTiempoNoCompatible =
    'tiene un paso de tiempo de sorteo que no es un divisor exacto del paso de tiempo de simulación por lo que no puede ser usada en esta sála.';

implementation


constructor TEsclavizadorSubMuestreado.Create(capa: integer; nombre: string;
  esclava: TFuenteAleatoria; xpromediarMuestras: boolean);
begin
  inherited Create(capa, nombre,
    0,  // le paso CERO pues el esclavizador es sincrono.
    xPromediarMuestras); // esto me parece no tiene consecuencias.
  promediarMuestras := xPromediarMuestras;
  tA := TFecha.Create_Dt(now());
  //  tB:= TFecha.Create_Dt(now());
  self.nombre := nombre;
  self.esclava := esclava;
  self.flg_ResumirBorneras := True;
end;

procedure TEsclavizadorSubMuestreado.Free;
var
  i: integer;
begin
  if borneras <> nil then
  begin
    for i := 0 to high(borneras) do
      SetLength(borneras[i], 0);
    SetLength(borneras, 0);
    SetLength(kpostes_borneras, 0);
    setlength(rxvals, 0);
    setlength(jRandomVals, 0);
  end;

  tA.Free;
  //  tB.Free;
  if esclava <> nil then
    esclava.Free;
  inherited Free;
end;

procedure TEsclavizadorSubMuestreado.PrepararMemoria(
  Catalogo: TCatalogoReferencias; globs: TGlobs);
var
  i: integer;
  SobreMuestreo: NReal;
begin
  inherited PrepararMemoria(Catalogo, globs);
  esclava.PrepararMemoria(Catalogo, globs);

  inherited copiarJs;

  SobreMuestreo := globs.HorasDelPaso / esclava.durPasoDeSorteoEnHoras;

  if abs(frac(SobreMuestreo)) > 0.00001 then
    raise Exception.Create(ms_LaFuente + ': ' + esclava.nombre + ' ' +
      ms_TienePasoDeTiempoNoCompatible);
    (*  rch@201607121841 Esto no sé porqué estaba ... así solo deja esclavizar horarias
  if (globs.NPostes > 1) and (abs(esclava.durPasoDeSorteoEnHoras - 1.0) > 0.0001) then
    raise Exception.Create(ms_LaFuente + ': ' + esclava.nombre + ' ' +
      ms_TienePasoDeTiempoNoCompatible);
      *)
  nMuestrasDelPaso := ceil(SobreMuestreo);

  SetLength(borneras, nMuestrasDelPaso ); // antes decía + 1
  for i := 0 to high(borneras) do
    SetLength(borneras[i], length(esclava.Bornera));
  setlength(kpostes_borneras, length(borneras));
  setlength(rxvals, length(borneras));
  setlength(jRandomVals, length(esclava.bornera));

  assert((esclava.durPasoDeSorteoEnHoras <> 0) and
    (esclava.durPasoDeSorteoEnHoras <> globs.HorasDelPaso),
    'TEsclavizadorSubMuestreado.PrepararMemoria:' + 'La fuente ' +
    esclava.nombre + 'es sincrona y se la remplazo por un TEsclavizadorSubMuestreado');

  pasoSorteoSobrePasoTiempo := esclava.durPasoDeSorteoEnHoras / globs.HorasDelPaso;

end;

procedure TEsclavizadorSubMuestreado.RegistrarParametrosDinamicos(
  CatalogoReferencias: TCatalogoReferencias);
begin
  //En principio no se precisa hacer nada cuando la esclava cambie sus parámetros dinámicos
  //hay que verlo con mas detalle
  esclava.RegistrarParametrosDinamicos( CatalogoReferencias );
end;

procedure TEsclavizadorSubMuestreado.Sim_Cronica_Inicio;
begin
  tA.PonerIgualA(globs.FechaInicioDelpaso);
  //Llena esclava.bornera_X
  esclava.Sim_Cronica_Inicio;
end;


procedure TEsclavizadorSubMuestreado.InicioSim;
begin
  inherited InicioSim;
  esclava.InicioSim;
end;

procedure TEsclavizadorSubMuestreado.InicioOpt;
begin
  inherited InicioOpt;
  esclava.InicioOpt;

end;


procedure TEsclavizadorSubMuestreado.SorteosSubpasosOPT(xsortear: boolean);
var
  i: integer;
  fechaIniPaso: TFecha;

begin
  begin
    //Lleno (RB) en la esclava
    //(BC) lo lleno si la esclava no tiene estado inscripto en CF y tiene bornes calculados
    if dim_RB > 0 then
    begin
      fechaIniPaso := TFecha.Create_Clone(globs.FechaInicioDelpaso);
      tA.PonerIgualA(fechaIniPaso);
      if (not esclavaConEstadoEnCF) and (esclava.dim_BC > 0) then
      begin
        globs.kSubPaso_ := 0;
        //Fijo X
        esclava.fijarEstadoInterno;
        //Sorteo RB
        esclava.SorteosDelPaso(xsortear);
        //X y RB => BC y Xs
        esclava.calcular_XS;
        esclava.calcular_BC;

        vcopy(borneras[0], esclava.Bornera );
        kpostes_borneras[0] := globs.kPosteHorasDelPaso[0];
        ta.addHoras(esclava.durPasoDeSorteoEnHoras);

        for i := 1 to nMuestrasDelPaso - 1 do
        begin
          globs.Fijar_FechaInicioDelPaso(tA);
          globs.kSubPaso_ := i;
          //Xs => X
          esclava.EvolucionarEstado;
          //X válido
          esclava.SorteosDelPaso(xsortear);
          //X y RB => BC y Xs
          esclava.calcular_XS;
          esclava.calcular_BC;
          //Copio toda la bornera
          vcopy(borneras[i], esclava.Bornera );
          kpostes_borneras[i] := globs.kPosteHorasDelPaso[i];
          tA.addHoras(esclava.durPasoDeSorteoEnHoras);
        end;
      end
      else
      begin
        for i := 0 to nMuestrasDelPaso - 1 do
        begin
          globs.Fijar_FechaInicioDelPaso(tA);
          globs.kSubPaso_ := i;
          esclava.SorteosDelPaso(xsortear);
          vcopyTramo(borneras[i], esclava.Bornera, jPrimer_RB_, dim_RB);
          kpostes_borneras[i] := globs.kPosteHorasDelPaso[i];
          tA.addHoras(esclava.durPasoDeSorteoEnHoras);
        end;
      end;
      globs.Fijar_FechaInicioDelPaso(fechaIniPaso);
      fechaIniPaso.Free;
    end;
  end;
end;


procedure TEsclavizadorSubMuestreado.SorteosSubpasosSIM(xsortear: boolean);
var
  i, empezarDesde: integer;
  fechaIniPaso: TFecha;
begin
  //Simulacion
  //En este momento tengo un valor válido de X en la esclava
  //Debo obtener RB para todas las muestras del paso.
  //BC lo deberíamos calcular en calcular BC pero lo calcularemos ahora para evitar
  //copias innecesarias de las borneras
  //Como para calcular BC debemos calcular X y Xs por medio de calcular_Xs y
  //Evolucionar estado actual también los guardamos ahora

  empezarDesde := 0;
  globs.kSubPaso_ := 0;

  if dim_RB > 0 then
  begin
    fechaIniPaso := TFecha.Create_Clone(globs.FechaInicioDelpaso);
    //X válido
    esclava.SorteosDelPaso(xsortear);
    //X y RB => BC y Xs
    esclava.calcular_XS;
    esclava.calcular_BC;

    vcopy(borneras[empezarDesde], esclava.Bornera );

    kpostes_borneras[empezarDesde] := globs.kPosteHorasDelPaso[0];

    ta.addHoras(esclava.durPasoDeSorteoEnHoras);

    for i := empezarDesde + 1 to nMuestrasDelPaso - 1 do
    begin
      globs.Fijar_FechaInicioDelPaso(tA);
      globs.kSubPaso_ := i - empezarDesde;

      //Xs => X
      esclava.EvolucionarEstado;
      //X válido
      esclava.SorteosDelPaso(xsortear);
      //X y RB => BC y Xs
      esclava.calcular_XS;
      esclava.calcular_BC;
      //Copio toda la bornera
      vcopy(borneras[i], esclava.Bornera );
      kpostes_borneras[i] := globs.kPosteHorasDelPaso[i];
      tA.addHoras(esclava.durPasoDeSorteoEnHoras);
    end;

    globs.Fijar_FechaInicioDelPaso(fechaIniPaso);
    fechaIniPaso.Free;
  end;
end;


procedure TEsclavizadorSubMuestreado.SorteosDelPaso(xsortear: boolean);
var
  kborne: integer;
  kPoste: integer;
begin


  (* Primero sorteamos todos los sub-pasos y los guardamos en las
  borneras.
  El procedimiento es levemente diferente si se trata de la
  Optimización que si se trata de la simulación. *)
  if globs.EstadoDeLaSala = CES_OPTIMIZANDO then
    SorteosSubPasosOPT(xsortear)
  else
    SorteosSubPasosSIM(xsortear);


  // calculo aquí los elegidos en los sorteos para que sea independiente
  // del estado del sistema.
  if (not PromediarMuestras) and (dim_RB > 0) then
  begin
    for kBorne := 0 to high(esclava.Bornera) do
    begin
      kPoste:= esclava.kPostes_bornes[kBorne];
      if ( kPoste = -1) then
       jRandomVals[kBorne] := globs.jRnd_Paso_globs
      else
        jRandomVals[kBorne] := globs.jRnd_Poste_globs[kPoste];
    end;
 end;
end;

procedure TEsclavizadorSubMuestreado.PosicionarseEnEstrellita;
begin
  if esclavaConEstadoEnCF then
    esclava.PosicionarseEnEstrellita;
end;

procedure TEsclavizadorSubMuestreado.PrepararPaso_ps;
var
  i: integer;
  fechaIniPaso: TFecha;

  procedure ResumirBorneras;
  var
    kBorne: integer;
    jxval: integer;
    mxval: NReal;
    i: integer;
  begin
    if PromediarMuestras then
    begin
      vclear(esclava.Bornera);
      for kBorne := 0 to high(esclava.Bornera) do
      begin
        jxval := 0;
        mxval := 0;

        for i := 0 to nMuestrasDelPaso - 1 do
          if (esclava.kPostes_bornes[kBorne] = -1) or
            (esclava.kPostes_bornes[kBorne] = kPostes_borneras[i]) then
          begin
            mxval := mxval + borneras[i][kBorne];
            Inc(jxval);
          end;

        esclava.Bornera[kBorne] := mxval / jxval;
        // si es CERO que se rompa pues algo está mal. Por ejemplo no hay demanda que clasifique las horas del paso.
      end;
    end
    else
    begin
      for kBorne := 0 to high(esclava.Bornera) do
      begin
        jxval := 0;
        for i := 0 to nMuestrasDelPaso - 1 do
          if (esclava.kPostes_bornes[kBorne] = -1) or
            (esclava.kPostes_bornes[kBorne] = kPostes_borneras[i]) then
          begin
            rxvals[jxval] := borneras[i][kBorne];
            Inc(jxval);
          end;
        esclava.Bornera[kBorne] := rxvals[jRandomVals[kBorne]];
      end;
    end;
  end;

begin
  if globs.EstadoDeLaSala = CES_OPTIMIZANDO then //Optimizacion
  begin
    if esclavaConEstadoEnCF then
    begin
      //Me cambiaron el estado, debo restaurar los sorteos y hacer todo el ciclo
      fechaIniPaso := TFecha.Create_Clone(globs.FechaInicioDelpaso);
      tA.PonerIgualA(fechaIniPaso);
      globs.kSubPaso_ := 0;
      //Fijo RB
      if dim_RB > 0 then
        vcopyTramo(esclava.Bornera, borneras[0], jPrimer_RB_, dim_RB);
      //X y RB => BC y Xs
      esclava.calcular_XS;
      esclava.calcular_BC;

      //Me guardo el (X), (Xs) y (BC)
      vcopyTramo(borneras[0], esclava.Bornera, jPrimer_X,
        length(esclava.Bornera) - jPrimer_X);
      ta.addHoras(esclava.durPasoDeSorteoEnHoras);

      for i := 1 to nMuestrasDelPaso - 1 do
      begin
        globs.Fijar_FechaInicioDelPaso(tA);
        globs.kSubPaso_ := i;

        //Xs => X
        esclava.EvolucionarEstado;
        if dim_RB > 0 then
          vcopyTramo(esclava.Bornera, borneras[0], jPrimer_RB_, dim_RB);
        //X y RB => BC y Xs
        esclava.calcular_XS;
        esclava.calcular_BC;

        //Me guardo el (X), (Xs) y (BC)
        vcopyTramo(borneras[0], esclava.Bornera, jPrimer_X,
          length(esclava.Bornera) - jPrimer_X);
        tA.addHoras(esclava.durPasoDeSorteoEnHoras);
      end;
      globs.Fijar_FechaInicioDelPaso(fechaIniPaso);
      fechaIniPaso.Free;
    end;
  end;


  // Optimización y Simulacion
  // Los actores pueden inhibir este comportamiento si
  // ellos se encargan de hacer sus propios resúmenes.
  if flg_resumirBorneras then
    resumirBorneras;

  //La esclava hace el calcular_Xs correspondiente y el estado siguiente
  //queda determinado por el estado resultante del promedio de los estados y el
  //promedio de los sorteos Xs(BC, X)
  esclava.PrepararPaso_ps;
end;

procedure TEsclavizadorSubMuestreado.EvolucionarEstado;
begin
  // rch@201607262109 bugfix -------------------
  // Antes de evolucionar etado reponemos la ultima bornera del paso
  // para eliminar el RESUMEN que se ubiera realizdo
  // Antes no hacía esta copia y entonces, al inicio del paso, la bornera
  // contenía el resumen del paso anterior con la consecuencia de que
  // los valores con correspondian a la evolución de la fuente.
  vcopy( esclava.Bornera, borneras[ high( borneras ) ] );
  esclava.EvolucionarEstado;
end;

function TEsclavizadorSubMuestreado.calc_DeltaCosto: NReal;
begin
  //OJO, revisar el significado del estado en este caso
  Result := esclava.calc_DeltaCosto;
end;

procedure TEsclavizadorSubMuestreado.Dump_Variables(var f: TextFile;
  charIndentacion: char);
var
  i, j: integer;
begin
  inherited Dump_Variables(f, charIndentacion);
  writeln(f, charIndentacion + 'tA= ' + tA.AsISOStr);
  Writeln(f, charIndentacion, 'nMuestrasDelPaso= ', nMuestrasDelPaso);

  for i := 0 to high(borneras) do
  begin
    for j := 0 to high(borneras[i]) do
      writeln(f, charIndentacion, 'borneras[' + IntToStr(i) + '][' +
        IntToStr(j) + ']= ', FloatToStr(borneras[i][j]));
  end;

  writeln(f, charIndentacion + StringReplace(esclava.descBornera,
    '#10', #10 + charIndentacion, [rfReplaceAll]));
  for i := 0 to high(esclava.Bornera) do
    writeln(f, charIndentacion, 'esclava.bornera[' + IntToStr(i) +
      ']= ', FloatToStr(esclava.Bornera[i]));
end;

(***
procedure TEsclavizadorSubMuestreado.PubliVars;
var
  i: integer;
begin
  inherited Publivars;
  for i := 0 to esclava.variablesParaSimRes.Count - 1 do
    variablesParaSimRes.Add(esclava.variablesParaSimRes.Items[i]);
end;
***)

end.
