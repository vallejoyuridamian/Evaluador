unit ucalculador_emisionesCO2;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, matreal, usalasdejuego,
  uactores, ugeneradores, uComercioInternacional, Math;

type
  TDAOfGenerador = array of TGenerador;
  TDAOfImportaciones = array of TComercioInternacional;

  TCalculadorEmisionesCO2 = class
  public
    constructor Create(sala_: TSalaDeJuego);
    procedure InicioDeCronica;
    procedure FinDelPaso;
    procedure FinCronica; // calcula la monotona de generación y el % de horas de marginación de las LowCostMustRun
    procedure Free;

  private
    sala: TSalaDeJuego;
    fsal_CO2: TextFile;

    cnt_LowCostMustRun: integer;
    cnt_HighCostMayRun: integer;

    generadores_LowCostMustRun: TDAofGenerador;
    generadores_HighCostMayRun: TDAofGenerador;
    Importaciones: TDAofImportaciones;

    // llevamos la cuenta para cada generador del acumulado desde
    // el inicio del AÑO.
    // Al inicio de cada crónica iniciamos el contador de Horasy borramos
    // los contadores de los generadores.
    gen_mwh_LowCostMustRun, gen_tco2_LowCostMustRun: TDAofNReal;
    gen_mwh_HighCostMayRun, gen_tco2_HighCostMayRun: TDAofNReal;
    importaciones_MWh: TDAofNReal;

    tot_mw_poste: TDAOfDAofNReal; // para cada paso y cada poste la pot total gen.
    acum_mwh_lcmr, acum_mwh_hcmr, acum_mwh_impo: NReal;
    acum_tco2_lcmr, acum_tco2_hcmr: NReal;

    cnt_paso_anual: integer; // pasos acumulados
    anio_inicio_cuenta: integer;

    monotona_MW_gen: TDAofNReal; // Monotona de generación representada por 100 valores
    lambda_factor_HorasLowCostMustRun_Marginando: NReal;

    acum_mwh_bm, acum_tco2_bm: NReal;

    procedure Imprimir_Contadores_anuales; // imprime un renglón con los acumlados
    procedure Limpiar_Contadores_anuales; // limpia los acumuladores.
    procedure Calcular_MonotonaAnaulYFactorDeMarginacion_lcmr;
    procedure Calcular_BM( EnergiaDelAnio: NReal; anio: integer );
  end;

implementation

constructor TCalculadorEmisionesCO2.Create(sala_: TSalaDeJuego);
var
  kGen: integer;
  aGen: TGenerador;
  kCom: integer;
  aCom: TComercioInternacional;
  iPoste: integer;
  kPaso: integer;
  maxNPasosPorAnio: integer;
begin
  // guardamos la referencia a la sala para poder consultar después.
  sala := sala_;

  // recorremos los generadores de la sala y contamos los
  // LowCostMustRun y los otros (HighCostMayRun).
  cnt_LowCostMustRun := 0;
  cnt_HighCostMayRun := 0;
  for kGen := 0 to sala.Gens.Count - 1 do
  begin
    aGen := sala.Gens[kGen] as TGenerador;
    if aGen.LowCostMustRun_ then
      Inc(cnt_LowCostMustRun)
    else
      Inc(cnt_HighCostMayRun);
  end;

  // ahora que sabemos cuantos hay de cada tipo, hacemos dos vectores
  // con los punteros a los generadores de cada tipo para poder después
  // recorrelos con facilidad y tener los acumulados de un tipo y del otro.
  setlength(generadores_LowCostMustRun, cnt_LowCostMustRun);
  setlength(generadores_HighCostMayRun, cnt_HighCostMayRun);
  cnt_LowCostMustRun := 0;
  cnt_HighCostMayRun := 0;
  for kGen := 0 to sala.Gens.Count - 1 do
  begin
    aGen := sala.Gens[kGen] as TGenerador;
    if aGen.LowCostMustRun_ then
    begin
      generadores_LowCostMustRun[cnt_LowCostMustRun] := aGen;
      Inc(cnt_LowCostMustRun);
    end
    else
    begin
      generadores_HighCostMayRun[cnt_HighCostMayRun] := aGen;
      Inc(cnt_HighCostMayRun);
    end;
  end;



  setlength( Importaciones,  sala.ComercioInternacional.count );
  for kCom:= 0 to sala.ComercioInternacional.count - 1 do
  begin
    aCom:= sala.ComercioInternacional[kCom] as TComercioInternacional;
    Importaciones[kCom]:= aCom;
  end;


  // creamos el archivo de salida para ir escribiendo al final de cada paso
  // y generar así información detallada por generador.
  assignfile(fsal_CO2, sala.dirResultadosCorrida + 'simres_CO2_' +
    IntToStr(sala.globs.semilla_inicial_sim) + 'x' +
    IntToStr(sala.Globs.NCronicasSim) + '.xlt');
  rewrite(fsal_CO2);


  // dimensionamos los vectores auxiliares para el cálculo.

  maxNPasosPorAnio:= ceil( 366*24 / sala.globs.HorasDelPaso );
  setlength( tot_mw_poste, maxNPasosPorAnio );
  for kPaso:= 0 to high( tot_mw_poste ) do
    setlength( tot_mw_poste[kPaso], sala.globs.NPostes);

  setlength( gen_mwh_LowCostMustRun, cnt_LowCostMustRun );
  setlength( gen_tco2_LowCostMustRun, cnt_LowCostMustRun );

  setlength( gen_mwh_HighCostMayRun, cnt_HighCostMayRun );
  setlength( gen_tco2_HighCostMayRun, cnt_HighCostMayRun );

  setlength( Importaciones_MWh, sala.ComercioInternacional.count );
                                                            setlength( monotona_MW_gen, 100 );

  limpiar_contadores_anuales;
end;

procedure TCalculadorEmisionesCO2.limpiar_contadores_anuales;
var
  kPaso: integer;
begin
  cnt_paso_anual:= 0;
  for kPaso:= 0 to high( tot_mw_poste ) do
    vclear( tot_mw_poste[kPaso] );
  vclear( gen_mwh_LowCostMustRun );
  vclear( gen_tco2_LowCostMustRun );
  vclear( gen_mwh_HighCostMayRun );
  vclear( gen_tco2_HighCostMayRun );
  vclear( importaciones_mwh );

  anio_inicio_cuenta:= sala.globs.AnioInicioDelPaso;
end;



procedure TCalculadorEmisionesCO2.InicioDeCronica;
var
  kGen: integer;
  aGen: TGenerador;
  kPaso: integer;
  k: integer;
  kCom: integer;
  aCom: TComercioInternacional;

begin

  limpiar_contadores_anuales;

  writeln(fsal_CO2);
  Writeln(fsal_CO2, 'CRONICA:', #9, sala.globs.kCronica, #9, 'SemillaAleatoria:', #9,
    sala.globs.madresUniformes.get_UltimaSemilla );

  write( fsal_CO2, 'Año', #9, 'Horas' );

  (***************************************************************)

  // encabezamos con los nombres de generadores para los MWh
  for kGen := 0 to high(generadores_LowCostMustRun) do
    Write(fsal_CO2, #9, 'MWh*');

  for kGen := 0 to high(generadores_HighCostMayRun) do
    Write(fsal_CO2, #9, 'MWh');

  for kGen:= 0 to high( importaciones_mwh ) do
    Write(fsal_CO2, #9, 'MWh');

  // encabezamos con los nombres de generadores para los Ton-CO2
  for kGen := 0 to high(generadores_LowCostMustRun) do
    Write(fsal_CO2, #9, 'Ton-CO2*');

  for kGen := 0 to high(generadores_HighCostMayRun) do
    Write(fsal_CO2, #9, 'Ton-CO2');

  Write(fsal_CO2, #9, 'MWh*');
  Write(fsal_CO2, #9, 'MWh');
  Write(fsal_CO2, #9, 'MWh**');
  Write(fsal_CO2, #9, 'Ton-CO2*');
  Write(fsal_CO2, #9, 'Ton-CO2');

  Write(fsal_CO2, #9, 'Ton-CO2/MWh');
  Write(fsal_CO2, #9, 'Ton-CO2/MWh');
  Write(fsal_CO2, #9, 'Ton-CO2/MWh');

  Write(fsal_CO2, #9, 'pu');

  for k:= 0 to 99 do
    Write(fsal_CO2, #9, 'MW');


 writeln( fsal_CO2);

 (***************************************************************)

  write( fsal_CO2, #9 );

 // encabezamos con los nombres de generadores para los MWh
  for kGen := 0 to high(generadores_LowCostMustRun) do
  begin
    aGen := generadores_LowCostMustRun[kGen];
    Write(fsal_CO2, #9, aGen.nombre);
  end;


  for kGen := 0 to high(generadores_HighCostMayRun) do
  begin
    aGen := generadores_HighCostMayRun[kGen];
    Write(fsal_CO2, #9, aGen.nombre);
  end;


  for kCom:= 0 to high( importaciones ) do
  begin
    aCom:= Importaciones[kCom] as TComercioInternacional;
    Write(fsal_CO2, #9, aCom.nombre);
  end;

  // encabezamos con los nombres de generadores para los Ton-CO2
  for kGen := 0 to high(generadores_LowCostMustRun) do
  begin
    aGen := generadores_LowCostMustRun[kGen];
    Write(fsal_CO2, #9, aGen.nombre);
  end;

  for kGen := 0 to high(generadores_HighCostMayRun) do
  begin
    aGen := generadores_HighCostMayRun[kGen];
    Write(fsal_CO2, #9, aGen.nombre);
  end;

  Write(fsal_CO2, #9, 'LCMR');
  Write(fsal_CO2, #9, 'HCMR');
  Write(fsal_CO2, #9, 'IMPO');

  Write(fsal_CO2, #9, 'LCMR');
  Write(fsal_CO2, #9, 'HCMR');

  Write(fsal_CO2, #9, 'EF_OM_Average');
  Write(fsal_CO2, #9, 'EF_OM_Simple');
  Write(fsal_CO2, #9, 'EF_OM_SimpleAdjusted');

  Write(fsal_CO2, #9, 'EF_BM');
  Write(fsal_CO2, #9, 'EF_CM');

  Write(fsal_CO2, #9, 'Lambda');

  for k:= 0 to 99 do
    Write(fsal_CO2, #9, (1+k));

  writeln( fsal_CO2 );
end;


procedure TCalculadorEmisionesCO2.Calcular_MonotonaAnaulYFactorDeMarginacion_lcmr;
var
  TotalHoras: integer;
  MW: TVectR;
  kPaso, kPoste: integer;
  acum_mwh: NReal;
  buscando: boolean;
  jHora, kHora: integer;
  horasDelPoste: integer;
  k: integer;
  j: integer;
  MWh_Limite: NReal;

begin
// ahora construimos la monótona de generación
  TotalHoras:= ceil( cnt_paso_anual * sala.globs.HorasDelPaso );
  MW:= TVectR.Create_Init( TotalHoras );
  khora:= 1;
  for kPaso:= 0 to cnt_paso_anual-1 do
   for kPoste:= 0 to sala.globs.NPostes-1 do
   begin
     horasDelPoste:= trunc( sala.globs.DurPos[kPoste] +0.49 );
     for jHora:= 1 to horasDelPoste do
     begin
       MW.pv[khora]:= self.tot_mw_poste[kPaso][kPoste];
       inc( khora );
     end;
   end;

  // ordenamos en forma decreciente las potencias del año.
  MW.Sort( false );

  MWh_Limite:= acum_mwh_lcmr + acum_mwh_impo;
  buscando:= true;
  kHora:= MW.N;
  acum_MWh:= MW.pv[kHora] * MW.N;
  while buscando and ( kHora > 1 ) do
  begin
    if acum_MWh >= MWh_Limite then
       buscando := false
    else
    begin
       acum_MWh:= acum_MWh + ( MW.pv[kHora - 1] - MW.pv[ kHora ] )* (( kHora -1) +0.5);
       dec( kHora );
    end;
  end;

  if not buscando then
    lambda_factor_HorasLowCostMustRun_Marginando := ( MW.N - kHora ) / MW.N
  else
    lambda_factor_HorasLowCostMustRun_Marginando := 1;

  // ahora RE_MUESTREO la monótona de generación para guardarla representada
  // por 100 valores y que resulte sencilla de manejar en el archivo de salida.
  for k:= 0 to 99 do
  begin
    j:= trunc(k / 99.0 * (MW.N-1) + 0.5) + 1;
    monotona_MW_gen[k]:= MW.pv[j];
  end;
  MW.Free;
end;

type
  TGenRec = record
    sublista: TDAOfGenerador;
    kGen: integer;
    gen: TGenerador;
  end;


  function Sort_GenRecs_By_DT_DESC( r1, r2: TGenRec ): integer;
  begin
    result:= Sort_Actores_By_DT_DESC( r1.gen, r2.gen );
  end;

procedure TCalculadorEmisionesCO2.Calcular_BM( EnergiaDelAnio: NReal; anio: integer );
var
  lst_generadores: TList;
  lst_generadores_no_cdm: TList;
  lst_generadores_cdm: TList;
  k: integer;
  a: TGenerador;
  rec: ^TGenRec;
  jGen: integer;
  umbral_mwh: NReal;
  buscando: boolean;
  flg_estado: integer;
  k_no_cdm: Integer;
  k_cdm: Integer;

begin
  // armo un lista con todos los generadores.
  // los anteriores al año de cálculo
  lst_generadores_no_cdm:= TList.Create;

  for k:= 0 to high( generadores_LowCostMustRun ) do
  begin
    a:= generadores_LowCostMustRun[k];
    if ( a.nacimiento.anio <= anio ) and  not a.CleanDevelopmentMechanism then
    begin
      new( rec );
      rec.kGen:= k;
      rec.sublista:= generadores_LowCostMustRun;
      rec.gen:= a;
      lst_generadores_no_cdm.add( rec );
    end;
  end;

  for k:= 0 to high( generadores_HighCostMayRun ) do
  begin
    a:= generadores_HighCostMayRun[k];
    if ( a.nacimiento.anio <= anio ) and  not a.CleanDevelopmentMechanism then
    begin
      new( rec );
      rec.kGen:= k;
      rec.sublista:= generadores_HighCostMayRun;
      rec.gen:= a;
      lst_generadores_no_cdm.add( rec );
    end;
  end;


  lst_generadores_cdm:= TList.Create;

  for k:= 0 to high( generadores_LowCostMustRun ) do
  begin
    a:= generadores_LowCostMustRun[k];
    if ( a.nacimiento.anio <= anio ) and  a.CleanDevelopmentMechanism then
    begin
      new( rec );
      rec.kGen:= k;
      rec.sublista:= generadores_LowCostMustRun;
      rec.gen:= a;
      lst_generadores_cdm.add( rec );
    end;
  end;

  for k:= 0 to high( generadores_HighCostMayRun ) do
  begin
    a:= generadores_HighCostMayRun[k];
    if ( a.nacimiento.anio <= anio ) and a.CleanDevelopmentMechanism then
    begin
      new( rec );
      rec.kGen:= k;
      rec.sublista:= generadores_HighCostMayRun;
      rec.gen:= a;
      lst_generadores_cdm.add( rec );
    end;
  end;


  // bien ahora ordeno la lista de forma de tener al principio los
  // últimos en ingresar al sistema
  lst_generadores_no_cdm.Sort( @Sort_GenRecs_By_DT_DESC );
  lst_generadores_cdm.Sort( @Sort_GenRecs_By_DT_DESC );

  lst_generadores:= TList.Create;

  k_no_cdm:= 0;
  buscando:= true;
  while ( buscando and (k_no_cdm < lst_generadores_no_cdm.count )) do
  begin
    rec:= lst_generadores_no_cdm.items[k_no_cdm];
    if (anio - rec.gen.nacimiento.anio)<=10 then
    begin
      lst_generadores.add( rec );
      inc( k_no_cdm );
    end
    else
      buscando:= false;
  end;

  for k_cdm := 0 to lst_generadores_cdm.count -1 do
      lst_generadores.add( lst_generadores_cdm[ k_cdm ] );

  if buscando = false then
  begin
    for k:= k_no_cdm to lst_generadores_no_cdm.count -1 do
        lst_generadores.add( lst_generadores_no_cdm[ k ] );
  end;


  // calculo el nivel al que hay que llegar
  umbral_mwh:= 0.2 * EnergiaDelAnio; // Factor especificado en el manual

  // pongo los acumuladores en CERO
  acum_mwh_bm:= 0;
  acum_tco2_bm:= 0;

  // empiezo a sumar hasta alcanzar el umbral
  // considero los últimos 5 generadores y si con esos no llego
  // al umbral sigo sumando.
  buscando:= true;
  k:= 0;

  while buscando and ( k < lst_generadores.count ) do
  begin
    rec:= lst_generadores.items[k];
    inc( k );

    if rec^.sublista = generadores_LowCostMustRun then
    begin
      acum_mwh_bm:= acum_mwh_bm + gen_mwh_LowCostMustRun[ rec^.kGen];
      acum_tco2_bm:= acum_tco2_bm + gen_tco2_LowCostMustRun[ rec^.kGen ];
    end
    else
    begin
        acum_mwh_bm:= acum_mwh_bm + gen_mwh_HighCostMayRun[ rec^.kGen ];
        acum_tco2_bm:= acum_tco2_bm + gen_tco2_HighCostMayRun[ rec^.kGen ];
    end;

    if (k >= 5) then
     if (acum_mwh_bm >= umbral_mwh) then buscando:= false;
  end;

  if buscando then
  begin
    // ??? NO alcanzó con los que no tenían
    raise Exception.Create('OJO, no tengo como llegar a determinar el grupo de generadores para BM' );
  end;


  // libero la lista auxiliar creada para el cálculo
  for k:= 0 to lst_generadores.Count -1 do
  begin
    rec:= lst_generadores.items[k];
    dispose( rec );
  end;
  lst_generadores.Free;
  lst_generadores_cdm.Free;
  lst_generadores_no_cdm.Free;
end;



procedure TCalculadorEmisionesCO2.Imprimir_Contadores_anuales; // imprime un renglón con los acumlados
var
  kGen: integer;
  aGen: TGenerador;

  kCom: integer;
  aCom: TComercioInternacional;

  kPaso: integer;
  cnt_horas: integer;
  k: integer;

  ef_average: NReal;
  ef_simple: NReal;
  ef_simple_adjusted: NReal;
  ef_seleccionado: NReal;
  ef_build: NReal;
  ef_combined: NReal;

begin
  cnt_horas:= ceil( cnt_paso_anual * sala.globs.HorasDelPaso );

  acum_mwh_lcmr:= 0;
  acum_mwh_hcmr:= 0;

  acum_mwh_impo:= 0;

  acum_tco2_lcmr:= 0;
  acum_tco2_hcmr:= 0;

  write( fsal_CO2, anio_inicio_cuenta , #9, cnt_horas );

  for kGen := 0 to high(generadores_LowCostMustRun) do
  begin
    acum_mwh_lcmr:= acum_mwh_lcmr + gen_mwh_LowCostMustRun[ kGen ];
    Write(fsal_CO2, #9, gen_mwh_LowCostMustRun[ kGen ]);
  end;

  for kGen := 0 to high(generadores_HighCostMayRun) do
  begin
    acum_mwh_hcmr:= acum_mwh_hcmr + gen_mwh_HighCostMayRun[ kGen ];
    Write(fsal_CO2, #9, gen_mwh_HighCostMayRun[ kGen ]);
  end;


  for kCom := 0 to high( Importaciones ) do
  begin
    acum_mwh_impo:= acum_mwh_impo + importaciones_MWh[ kCom ];
    Write(fsal_CO2, #9, importaciones_MWh[  kCom ]);
  end;



  for kGen := 0 to high(generadores_LowCostMustRun) do
  begin
    acum_tco2_lcmr:= acum_tco2_lcmr + gen_tco2_LowCostMustRun[ kGen ];
    Write(fsal_CO2, #9, gen_tco2_LowCostMustRun[ kGen ]);
  end;

  for kGen := 0 to high(generadores_HighCostMayRun) do
  begin
    acum_tco2_hcmr:= acum_tco2_hcmr + gen_tco2_HighCostMayRun[ kGen ];
    Write(fsal_CO2, #9, gen_tco2_HighCostMayRun[ kGen ]);
  end;

  Write(fsal_CO2, #9, acum_mwh_lcmr );
  Write(fsal_CO2, #9, acum_mwh_hcmr );
  Write(fsal_CO2, #9, acum_mwh_impo );
  Write(fsal_CO2, #9, acum_tco2_lcmr );
  Write(fsal_CO2, #9, acum_tco2_hcmr );

  // Factor de Emisiones OM - Promedio
  if ( acum_mwh_lcmr + acum_mwh_hcmr + acum_mwh_impo ) > 0.01 then
   ef_average:= (acum_tco2_lcmr + acum_tco2_hcmr )/ ( acum_mwh_lcmr + acum_mwh_hcmr + acum_mwh_impo)
  else
   ef_average:= 0;

  // Factor de Emisiones OM - Simple
  if ( acum_mwh_hcmr) > 0.01 then
     ef_simple:= acum_tco2_hcmr /  acum_mwh_hcmr
  else
     ef_simple:= 0;

  // ahora que ya calcule los acumulados anuales puedo calcular el factor de marginación de las lcmr
  Calcular_MonotonaAnaulYFactorDeMarginacion_lcmr;

  ef_simple_adjusted:= 0;
  if ( acum_mwh_lcmr + acum_mwh_impo ) > 0.01 then
   ef_simple_adjusted:= ef_simple_adjusted+ lambda_factor_HorasLowCostMustRun_Marginando * acum_tco2_lcmr / ( acum_mwh_lcmr + acum_mwh_impo );

  if acum_mwh_hcmr > 0.01 then
   ef_simple_adjusted:= ef_simple_adjusted + ( 1 - lambda_factor_HorasLowCostMustRun_Marginando ) * acum_tco2_hcmr / acum_mwh_hcmr;

  // Cálculo del BuildMargin. ??? no irán las importaciones ???? Fernanda dice que CREO que no.
  Calcular_BM( acum_mwh_lcmr + acum_mwh_hcmr, anio_inicio_cuenta );

  ef_build:= 0.0;
  if acum_mwh_bm > 0.01 then
    ef_build:= acum_tco2_bm / acum_mwh_bm;

  // Calculo del CombinedMargin
  case sala.globs.FactorEmisiones_MargenOperativoTipo of
  0: ef_seleccionado:= ef_average;
  1: ef_seleccionado:= ef_Simple;
  2: ef_seleccionado:= ef_simple_adjusted;
  end;

  if sala.globs.FactorEmisiones_ProyectoEolicoSolar then
    ef_combined:= 0.75 * ef_seleccionado + 0.25 * ef_build
  else
    ef_combined:= 0.50 * ef_seleccionado + 0.50 * ef_build;

  Write(fsal_CO2, #9, ef_average );
  Write(fsal_CO2, #9, ef_simple );
  Write(fsal_CO2, #9, ef_simple_adjusted );
  Write(fsal_CO2, #9, ef_build );
  Write(fsal_CO2, #9, ef_combined );

  write( fsal_co2, #9, lambda_factor_HorasLowCostMustRun_Marginando );
  for k:= 0 to 99 do
      write( fsal_co2, #9, monotona_mw_gen[ k ] );
  writeln( fsal_CO2 );
end;

procedure TCalculadorEmisionesCO2.FinDelPaso;
var
  kGen: integer;
  aGen: TGenerador;
  iPoste: integer;
  mwh: NReal;
  acum_mwh: NReal;
  acum_tco2: NReal;
  kCom: integer;
  aCom: TComercioInternacional;
  PImport: NReal;

begin

  // primero detectar si hay cambio de año.
  if sala.globs.AnioInicioDelPaso > anio_inicio_cuenta then
  begin
    Imprimir_Contadores_anuales;
    Limpiar_Contadores_anuales;
    anio_inicio_cuenta:= sala.Globs.AnioInicioDelPaso;
  end;


  for kGen := 0 to high(generadores_LowCostMustRun) do
  begin
    aGen := generadores_LowCostMustRun[kGen];
    acum_MWh := 0.0;
    acum_TCO2:= 0.0;
    for iposte := 0 to sala.globs.NPostes - 1 do
    begin
      tot_MW_poste[ cnt_paso_anual ][Iposte]:= tot_MW_poste[ cnt_paso_anual ][Iposte] + agen.P[iposte];
      MWh := agen.P[iposte] * sala.globs.DurPos[iposte];
      acum_MWh:= acum_MWh + MWh;
      acum_TCO2:= acum_TCO2+ MWh * agen.TonCO2xMWh;
    end;
    gen_mwh_LowCostMustRun[ kGen ]:= gen_mwh_LowCostMustRun[ kGen ] + acum_MWh;
    gen_tco2_LowCostMustRun[ kGen ]:= gen_tco2_LowCostMustRun[ kGen ] + acum_TCO2;
  end;


  for kGen := 0 to high(generadores_HighCostMayRun) do
  begin
    aGen := generadores_HighCostMayRun[kGen];
    acum_MWh := 0.0;
    acum_TCO2:= 0.0;
    for iposte := 0 to sala.globs.NPostes - 1 do
    begin
      tot_MW_poste[ cnt_paso_anual  ][Iposte]:= tot_MW_poste[ cnt_paso_anual  ][Iposte] + agen.P[iposte];
      MWh := agen.P[iposte] * sala.globs.DurPos[iposte];
      acum_MWh:= acum_MWh + MWh;
      acum_TCO2:= acum_TCO2+ MWh * agen.TonCO2xMWh;
    end;
    gen_mwh_HighCostMayRun[ kGen ]:= gen_mwh_HighCostMayRun[ kGen ] + acum_MWh;
    gen_tco2_HighCostMayRun[ kGen ]:= gen_tco2_HighCostMayRun[ kGen ] + acum_TCO2;
  end;


  for kCom:= 0 to high( importaciones ) do
  begin
    aCom:= Importaciones[kCom] as TComercioInternacional;
    acum_MWh := 0.0;
    for iposte := 0 to sala.globs.NPostes - 1 do
    begin
      PImport:= max( 0, aCom.P[iposte] );
      tot_MW_poste[ cnt_paso_anual  ][Iposte]:= tot_MW_poste[ cnt_paso_anual  ][Iposte] + PImport;
      MWh := PImport* sala.globs.DurPos[iposte];
      acum_MWh:= acum_MWh + MWh;
    end;
    Importaciones_MWh[ kCom ]:= Importaciones_MWh[ kCom ] + acum_MWh;
  end;

  inc( cnt_paso_anual );
end;

procedure TCalculadorEmisionesCO2.FinCronica; // calcula la monotona de generación y el % de horas de marginación de las LowCostMustRun
begin
  if cnt_paso_anual > 0 then
  begin
    Imprimir_contadores_anuales;
    Limpiar_contadores_anuales;
  end;
end;

procedure TCalculadorEmisionesCO2.Free;
begin
  if cnt_paso_anual > 0 then
     Imprimir_Contadores_anuales;
  closefile(fsal_CO2);
  inherited Free;
end;

end.
