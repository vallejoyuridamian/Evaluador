unit useriestemporales;

{$mode delphi}

interface

uses
  Classes, SysUtils, Math, xmatdefs,
  matReal, matEnt, MatBool,
  {$IFDEF OPENCALC}
  uopencalc,
  {$ENDIF}
  uauxiliares;

const
  // rch@201407170838 agrego que se pueda especificar conjunto de canales
  // que deben ser transformados a POLARES para pasar los deformadores
  // de forma de poder garantizar histogramas de módulo y direcciones se
  // conservan.
  { dv@20170817 las series pasan a ser conjuntos de cronicas en la variable
    cronicas_series, se mantiene la variable series por compatibilidad y
    para usar como puntero a una cronica }
  VERSION_FORMATO_SERIES = 3;


type
  TIPO_SERIE = (SALIDA, ENTRADA);

  {$IFDEF GRUPOS_POLARES}
  TGruposPolares = class
    Grupos: TDAOfDAOfNInt;
    beta: NReal;
    constructor Create_vacio;
    constructor Create_ReadFromTextFile(var f: textFile;
      var cnt_linea: integer; var ultimalinealeida: string;
      var flg_ultimalineausada: boolean);
    procedure WriteToTextFile(var f: textfile);
    constructor Create_ReadFromBinFile(var f: file);
    procedure WriteToBinFile(var f: file);
    procedure Free;
  end;

  {$ENDIF}


  (* Clase para soporte de las series de datos *)

  { TSeriesDeDatos }

  TDAOfTipoSerie = array of TIPO_SERIE;

  TSeriesDeDatos = class
  public
    version: integer;
    archi: string;
    NSeries: integer;
    // Información de la primera muedtra (PM)
    PM_Anio, PM_Mes, PM_Dia, PM_Hora, PM_Minuto, PM_segundo: integer;
    PeriodoDeMuestreo_horas: NReal;
    NPuntos: integer;
    NCronicas: integer;
    rNPPorCiclo: NReal; // Cantidad de puntos por ciclo.
    nombresSeries: TStringList;

    cronicas_series: array of TDAOfVectR;

    NSeriesY: integer; // número de series de salida
    NSeriesX: integer; // Número de series de entrada

    NombresSeriesY: array of string; // Series de salida
    NombresSeriesX: array of string; // Series de entrada

    tipo_Serie: TDAOfTipoSerie;


    // Constantes auxiliares calculadas
    dtPrimeraMuestra: TDateTime;
    dtPrimeraMuestra_InicioDelAnio: TDateTime;
    dtPrimeraMuestra_InicioDelDia: TDateTime;
    dtInicioCiclo: TDateTime;
    dtDuracionCicloPrincial: TDateTime;
    dtEntreMuestras: TDateTime;
    rOffsetCiclo: NReal; // se calcula al crearse.


{$IFDEF GRUPOS_POLARES}
    GruposPolares: TGruposPolares;
{$ENDIF}
    constructor CreateFromArchi(archi: string);
    constructor CreateVacia(dtPrimeraMuestra: TDateTIme;
      PeriodoDeMuestreo_Horas: NReal; nPuntos: integer;nCronicas:integer = 1);

    procedure WriteToArchi(archi: string);
    procedure WriteCOVARS(archi: string; umbral_filtro: NReal);

    procedure Free;

    // Si el Nuevo_PeriodoDeMuestreo_horas > PeriodoDeMuestreo_horas promedia
    function Resampling(Nuevo_PeriodoDeMuestreo_horas: NReal): TSeriesDeDatos;

    // Crea un Clon del conjunto de series.
    function Clone: TSeriesDeDatos;

    // Crea un Clon del conjunto de series de Entrada
    function Clone_Entradas: TSeriesDeDatos;

    // Crea un Clon del conjunto de series de Salida
    function Clone_Salidas: TSeriesDeDatos;

    //Sustituye las series de velocidad y dirección de viento por velocidad en el eje x
    //y en el el eje y respectivamente. Se asume que dir es el ángulo con 0º en el norte y en sentido
    //horario. La velocidad en el eje x es positiva hacia el este y en el eje y es positiva hacia el norte.
    //Para cada punto de las series, si la velocidad o dirección es negativa, se pone en vel_x y vel_y -77777.
    procedure VelDir_To_VelxVely(kSerie_Dir, kSerie_Vel: integer;
      Nombre_Velx, Nombre_Vely: string);

    procedure DelSerie(kSerie: integer); // sinónimo de QuitarSerie
    procedure AddSerie(NombreSerie: string; vdatos: TVectR = nil;
      tipoSerie: TIPO_SERIE = SALIDA);

    procedure AddSerieCron(NombreSerie: string; sdatos: TDAOfVectR = nil;
      tipoSerie: TIPO_SERIE = SALIDA);
    procedure AddSeriesFromArchi(archi: string);

    // Obtiene un puntero a la serie kSerie de la Crónica Activa
    // Si kSerie >= NSeries, expande el ramillete de serie agregando
    // series vacías de longitud NPuntos.
    function GetSerie( kSerie: integer ): TVectR;
    function GetSerieX( kSerie: integer ): TVectR;
    function GetSerieY( kSerie: integer ): TVectR;

    // Acumula en las series, el ramillete xserie con un offset en las series
    // dado. (peseudocodigo: ) self.Serie[k+offset]:= self.Serie[k+Offset] + xserie[k]
    // Si k+offset > Self.NSeries agrega series al final
    // El array huecos debe contener los valores que se deben considerar como huecos (medidas faltantes)
    // en las series de xseries. Antes de sumar, los huecos son cambiados por el valor DefVal.
    procedure AcumSeries(  // Habia un _ al final DV 16/2/17
      xserie: TSeriesDeDatos; huecos: TDAofNReal;
      offset: integer = 0; defval: Nreal = 0 );



    // Calcula el índice del deformador usando la información
    // de rOffset y rNPuntosPorCiclo
    function kDefomador(kMuestra: integer): integer;

    // Retorna la fecha de la muestra kMuestra
    function dtMuestra(kMuestra: integer): TDateTime;


    // Busca una serie por su nombre, si la encuentra retorna el ordinal
    // sino retorna -1
    function kOfSerie( nombreSerie: string ): integer;


    // kCron : 1.. NCronicas
    procedure enfoqueCronica( kCron: integer );


    property series[ iSerie: integer ] : TVectR Read getSerie;
    property seriesX[ iSerie: integer ] : TVectR Read getSerie;
    property seriesY[ iSerie: integer ] : TVectR Read getSerie;

  private
    kCronicaActiva: integer; // 1..NCronicas apunta a la crónica enfocada
    series__: TDAOfVectR;
    seriesY__: TDAOfVectR; // Series de salida
    seriesX__: TDAOfVectR; // Series de entrada


    // Crea un grupo de series con la misma información que el grupo actual.
    // Lo único que no hace es fijar el largo los vectores de "series"
    function CreateCloneHeadInfo: TSeriesDeDatos;
    function CreateCloneHeadInfo_Entradas: TSeriesDeDatos;
    function CreateCloneHeadInfo_Salidas: TSeriesDeDatos;

    function calc_dtPrimeraMuestra: TDateTime;
    function calc_dtPrimeraMuestra_InicioDelAnio: TDateTime;
    function calc_dtPrimeraMuestra_InicioDelDia: TDateTime;
    function calc_dtDuracionCicloPrincial: TDateTime;
    function calc_dtEntreMuestras: TDateTime;
    procedure calc_constantes;

    // En función de la lista de nombres y de tipos setea las variables
    // que discriminan entre entradas y salidas.
    procedure actualizarAuxiliares;
  end;



  { TCalculadorCovars }

  TCalculadorCovars = class
    ve, desv: TVectR;
    cxx_k: TDAofMatR;
    cnt_cxx: TMatE;
    umbral_filtro: NReal;
    nSeries, nRetardos: integer;


    constructor Create( nSeries, nRetardos: integer; umbral_filtro: NReal );
  (*
  Calcula el vector de valor esperado (ve) y de desvíos estándar (desv)
  de las series pasadas por parámetro al procedimiento Calc
  También calcula las matrices de covariznas <X[j].X[j-k]^t>
  en el array de matrices cxx_k
  *)
    procedure Calc( series: TDAOfVectR );



  (*
    Supone que la distribución de las series es gaussiana y
    calcula la probabilidad de las observaciones.
    A mayor valor, es más probable que el proceso que genera las
    series sea realmente gaussiano.
  *)
    function Versimilitud_gaussiana( series: TDAOfVectR ): NReal;

    // Supone que es un proceso gaussiano normalizado
    function Versimilitud_gaussianaNormal( series: TDAOfVectR ): NReal;

    procedure PrintToArchi( archi: String; NombreSeries: TStringList );
    procedure Free;
  end;

implementation

{ TCalculadorCovars }

constructor TCalculadorCovars.Create(nSeries, nRetardos: integer;
  umbral_filtro: NReal);
var
  kRet: integer;
begin
  inherited Create;
  self.nSeries:= nSeries;
  self.NRetardos:= nRetardos;
  self.umbral_filtro:= umbral_filtro;
  desv := TVectR.Create_init(NSeries);
  ve := TVectR.Create_init(NSeries);
  setlength( cxx_k, NRetardos+ 1 );
  for kRet:= 0 to nRetardos do
    cxx_k[kRet]:= TMatR.Create_init( NSeries, NSeries );
  cnt_cxx := TMatE.Create_Init( NSeries, NSeries );
end;

procedure TCalculadorCovars.Calc(series: TDAOfVectR);
var
  kserie, kpunto: integer;
  aSerie: TVectR;
  kRet, jSerie: integer;
  xs1, xs2: NReal;
  prom, vrz: NReal;
  nPuntos: integer;
  cxx: TMatR;
begin
  prom:= 0; vrz:= 0;

  // Primero calculamos los promedios y desvíos
  for kSerie := 1 to NSeries do
  begin
    aSerie := series[kSerie - 1];
    aSerie.PromedioVarianza_filtrando(prom, vrz, umbral_filtro);
    ve.pon_e(kSerie, prom);
    desv.pon_e(kSerie, sqrt(vrz));
  end;

  nPuntos:= aSerie.n;

  for kRet := 0 to nRetardos do
  begin
    cxx:= cxx_k[ kRet ];
    cxx.Ceros;
    cnt_cxx.Ceros;
    for kPunto := kRet + 1 to NPuntos do
    begin
      for kSerie := 1 to NSeries do
      begin
        xs1 := Series[kSerie - 1].e(kPunto - kRet);
        if xs1 > umbral_filtro then
        begin
          xs1 := (xs1 - ve.e(kSerie)) / desv.e(kSerie);
          for jSerie := 1 to NSeries do
          begin
            xs2 := Series[jSerie - 1].e(kPunto);
            if xs2 > umbral_filtro then
            begin
              xs2 := (xs2 - ve.e(jSerie)) / desv.e(jSerie);
              cxx.acum_e( kSerie, jSerie, xs1 * xs2);
              cnt_cxx.acum_e(kSerie, jSerie, 1);
            end;
          end;
        end;
      end;
    end;

    for kSerie := 1 to cxx.nf do
      for jSerie:= 1 to cxx.nc do
      if cnt_cxx.e(kSerie, jSerie) > 0 then
        cxx.pon_e(kSerie, jSerie, cxx.e(kSerie, jSerie) / cnt_cxx.e(kSerie, jSerie))
      else
        cxx.pon_e(kSerie, jSerie, umbral_filtro);
  end;
end;


function TCalculadorCovars.Versimilitud_gaussiana(series: TDAOfVectR): NReal;

var
  InvSuperSigma: TMatR;
  kRet, jRet: integer;
  kOffset, jOffset, k, j: integer;
  retOffset: integer;
  cxx: TMatR;
  detSigma: NReal;
  X: TVectR;
  huecos: TVectBool;
  cnt, kPaso: integer;
  lna, lnp_acum: NReal;

function Prob( x: TVectR ): NReal;
var
  a, b: NReal;
begin
  a:= power( 2* pi, x.n / 2 ) *  sqrt( detSigma );
  b:= - InvSuperSigma.FormaCuadratica( X ) / 2.0;
  result:= exp( b ) / a ;
end;

function LnProb( x: TVectR ): NReal;
var
  b: NReal;
begin
  b:= -InvSuperSigma.FormaCuadratica( X ) / 2.0;
  result:= b;
end;


procedure Cargue( X: TVectR; kPaso: integer );
var
  j: integer;
  v: NReal;
begin
  for j:= X.n downto nSeries+1 do
  begin
   x.pv[j]:= x.pv[j-nSeries];
   huecos.pv[j]:= huecos.pv[j-nSeries];
  end;
  for j:= 1 to NSeries do
  begin
    v:= series[j-1].pv[kPaso];
    if v <= umbral_filtro then
    begin
      x.pv[j]:= v;
      huecos.pv[j]:= true;
    end
    else
    begin
      x.pv[j]:= (series[j-1].pv[kPaso] - ve.pv[j])/ desv.pv[j];
      huecos.pv[j]:= false;
    end;
  end;
end;


function sin_huecos_X: boolean;
var
  k: integer;
begin
  result:= true;
  for k:= 1 to huecos.n do
    if huecos.pv[k] then
    begin
      result:= false;
      break;
    end;
end;


begin
  InvSuperSigma:= TMatR.Create_Init( nSeries * (nRetardos+1), nSeries* (nRetardos+1) );
  for kRet:= 0 to nRetardos do
  begin
    kOffset:= kRet * nSeries;
   for jRet:= 0 to nRetardos do
   begin
    jOffset:= jRet * nSeries;
    retOffset:= abs( kRet - jRet );
    cxx:= cxx_k[ retOffset ];
    for k:= 1 to nSeries do
     for j:= 1 to nSeries do
       InvSuperSigma.pon_e( kOffset +k, jOffset +j, cxx.e( k, j ) );
   end;
  end;

  detSigma:= 0;
  if (not INvSuperSigma.Inv( DetSigma )) or (detSigma < 1e-10 ) then
  begin
    InvSuperSigma.Free;
    result:= -1e20;
    exit;
  end;

  X:= TVectR.Create_Init( nSeries * (1+nRetardos) );
  huecos:= TVectBool.Create_Init( X.n );

  // auxiliar
  lna:=  ln( power( 2* pi, x.n / 2 ) *  sqrt( detSigma ) );

  X.Ceros;

  cnt:= 0;
  for kPaso := 1 to NRetardos do
   Cargue( X, kPaso );

  lnp_acum:= 0;

  for kPaso:= NRetardos + 1 to series[0].n do
  begin
   Cargue( X, kPaso );
   if sin_huecos_X then
   begin
     inc( cnt );
     lnp_acum:= lnp_acum + lnProb( X );
   end;
  end;
  result:= (lnp_acum / cnt - lna)/(nSeries * (nRetardos+1 ));

  X.Free;
  huecos.Free;
  invSuperSigma.Free;
end;

function TCalculadorCovars.Versimilitud_gaussianaNormal(series: TDAOfVectR
  ): NReal;

var
  kSerie: integer;
  X, aserie: TVectR;
  huecos: TVectBool;

  cnt, kPaso: integer;
  lna, lnp_acum: NReal;
  prom, vrz: NReal;
  acum_DIFF_VE_VRZ: NReal;


function LnProb( x: TVectR ): NReal;
var
  b: NReal;
begin
  b:= - X.ne2 / 2.0;
  result:= b;
end;


procedure Cargue( X: TVectR; kPaso: integer );
var
  j: integer;
  v: NReal;
begin
  for j:= X.n downto nSeries+1 do
  begin
   x.pv[j]:= x.pv[j-nSeries];
   huecos.pv[j]:= huecos.pv[j-nSeries];
  end;

  for j:= 1 to NSeries do
  begin
//   x.pv[j]:= (series[j-1].pv[kPaso] - ve.pv[j])/ desv.pv[j];
    v:= series[j-1].pv[kPaso];
    if v <= umbral_filtro then
    begin
      x.pv[j]:= v;
      huecos.pv[j]:= true;
    end
    else
    begin
      x.pv[j]:= v/desv.pv[j];
      huecos.pv[j]:= false;
    end;
  end;
end;

function sin_huecos_X: boolean;
var
  k: integer;
begin
  result:= true;
  for k:= 1 to huecos.n do
    if huecos.pv[k] then
    begin
      result:= false;
      break;
    end;
end;


begin
  prom:= 0; vrz:= 0;
  acum_DIFF_VE_VRZ:= 0;

  // Primero calculamos los promedios y desvíos
  for kSerie := 1 to NSeries do
  begin
    aSerie := series[kSerie - 1];
    aSerie.PromedioVarianza_filtrando(prom, vrz, umbral_filtro);
    ve.pon_e(kSerie, prom);
    desv.pon_e(kSerie, sqrt(vrz));
    acum_DIFF_VE_VRZ:= acum_DIFF_VE_VRZ + sqr( prom ) + sqr( vrz - 1 );
  end;


  X:= TVectR.Create_Init( nSeries * (1+nRetardos) );
  huecos:= TVectBool.Create_Init( X.n );
  huecos.Ceros;

  // auxiliar
  lna:=  ln( power( 2* pi, x.n / 2 )  );

  X.Ceros;
  cnt:= 0;
  for kPaso := 1 to NRetardos do
   Cargue( X, kPaso );

  lnp_acum:= 0;

  for kPaso:= NRetardos + 1 to series[0].n do
  begin
   Cargue( X, kPaso );
   if sin_huecos_X then
   begin
     inc( cnt );
     lnp_acum:= lnp_acum + lnProb( X );
   end;
  end;
  result:= (lnp_acum / cnt - lna)/(nSeries * (nRetardos+1 ));
  //   - 10000* acum_DIFF_VE_VRZ ;

  X.Free;
end;


procedure TCalculadorCovars.PrintToArchi(archi: String;
  NombreSeries: TStringList);
var
  kRet, kSerie, jSerie: integer;
  nombres: TStringList;
  sal: textFile;
  cxx: TMatR;
begin
  assignfile( sal, archi );
  rewrite( sal );

  if NombreSeries <> nil then
    nombres:= NombreSeries
  else
  begin
    nombres:= TStringList.Create;
    for kSerie:= 1 to NSeries do
      nombres.add( 's_'+IntToStr( kSerie ) );
  end;

  writeln( sal,'Calculador Covars. Fecha: '+ DateTimeToStr( now ) );

  writeln( sal );
  writeln( sal, 'Serie', #9, 'VE' );
  for kSerie:= 1 to NSeries do
      writeln( sal, Nombres[kSerie-1], #9, ve.e( kSerie ) );

  writeln( sal );
  writeln( sal, 'Serie', #9, 'desv' );
  for kSerie:= 1 to NSeries do
      writeln( sal, Nombres[kSerie-1], #9, desv.e( kSerie ) );


  writeln( sal );
  writeln( sal, 'Matrices de covarianzas <X[].X[-kRet]^t>' );
  for kRet:= 0 to nRetardos do
  begin
    cxx:= cxx_k[kRet];
    writeln( sal, 'kRet: ',#9, kRet );
    for kSerie:= 1 to NSeries do
    begin
      write( sal, kSerie );
      for jSerie:= 1 to NSeries do
         write( sal, #9, cxx.e(kSerie, jSerie ) );
      writeln( sal );
    end;
  end;

  if NombreSeries = nil then
        nombres.Free;

  closefile( sal );
end;

procedure TCalculadorCovars.Free;
var
  kRet: integer;
begin
  desv.Free;
  ve.Free;
  for kRet:= 0 to nRetardos do
    cxx_k[kRet].Free;
  setlength( cxx_k, 0 );
  cnt_cxx.Free;
  inherited Free;
end;



{$IFDEF GRUPOS_POLARES}
constructor TGruposPolares.Create_vacio;
begin
  inherited Create;
  setlength(grupos, 0);
  beta := 1;
end;

constructor TGruposPolares.Create_ReadFromTextFile(var f: textFile;
  var cnt_linea: integer; var ultimalinealeida: string;
  var flg_ultimalineausada: boolean);
var
  NGruposPOlares: integer;
  kgrupo: integer;
  NSeriesDelGrupo: integer;
  kSerie: integer;
  r: string;

  procedure readln(var f: textfile; var s: string);
  begin
    system.readln(f, s);
    Inc(cnt_linea);
  end;

begin
  inherited Create;
  flg_ultimaLineaUsada := True;
  setlength(Grupos, 0);
  readln(f, r);
  if (pos('Grupos Polares', r) > 0) then
  begin
    readln(f, r);
    beta := nextFloat(r);

    NGruposPolares := nextInt(r);
    setlength(Grupos, NGruposPolares);
    for kgrupo := 0 to NGruposPolares - 1 do
    begin
      readln(f, r);
      NSeriesDelGrupo := nextInt(r);
      setlength(Grupos[kGrupo], NSeriesDelGrupo);
      for kSerie := 0 to NSeriesDelGrupo - 1 do
        Grupos[kGrupo][kSerie] := NextInt(r);
    end;
    readln(f, r);
  end
  else
  begin
    flg_ultimalineausada := False;
  end;
  ultimalinealeida := r;
end;

procedure TGruposPolares.WriteToTextFile(var f: textfile);

var
  kGrupo, kSerie: integer;
begin
  system.writeln(f, IntToStr(length(Grupos)), #9, '// Grupos Polares');
  system.writeln(f, beta);
  for kgrupo := 0 to high(grupos) do
  begin
    system.Write(f, IntToStr(length(Grupos[kGrupo])));
    for kSerie := 0 to high(Grupos[kGrupo]) do
      system.Write(f, #9, IntToStr(Grupos[kGrupo][kSerie]));
    system.writeln(f);
  end;
  system.writeln(f);
end;

constructor TGruposPolares.Create_ReadFromBinFile(var f: file);
var
  NGrupos, NSeriesDelGrupo: integer;
  kGrupo, kSerie: integer;
begin
  inherited Create;
  blockread(f, beta, SizeOf(beta));
  blockread(f, NGrupos, SizeOf(NGrupos));
  setlength(grupos, NGrupos);
  for kGrupo := 0 to high(grupos) do
  begin
    blockread(f, NSeriesDelGrupo, SizeOf(NSeriesDelGrupo));
    for kSerie := 0 to high(grupos[kGrupo]) do
      blockread(f, grupos[kGrupo, kSerie], sizeOf(NInt));
  end;
end;

procedure TGruposPolares.WriteToBinFile(var f: file);
var
  NGrupos, NSeriesDelGrupo: integer;
  kGrupo, kSerie: integer;
begin
  blockwrite(f, beta, SizeOf(beta));
  NGrupos := length(grupos);
  blockwrite(f, NGrupos, SizeOf(NGrupos));
  for kGrupo := 0 to higSetLonginth(grupos) do
  begin
    NSeriesDelGrupo := length(grupos[kGrupo]);
    blockwrite(f, NSeriesDelGrupo, SizeOf(NSeriesDelGrupo));
    for kSerie := 0 to high(grupos[kGrupo]) do
      blockwrite(f, grupos[kGrupo, kSerie], sizeOf(NInt));
  end;
end;

procedure TGruposPolares.Free;
begin
  setlength(grupos, 0);
  inherited Free;
end;

{$ENDIF}

constructor TSeriesDeDatos.CreateFromArchi(archi: string);
var
  f: TextFile;
  r, serie: string;
  kserie, kpunto,kCronica: integer;
  fk: NReal;
  cnt_linea: integer;
  {$IFDEF GRUPOS_POLARES}
  flg_GruposPolares: boolean;
  {$ENDIF}
  {$IFDEF OPENCALC}
  ext:string;
  ods: TLibroOpenCalc;
  flg_from_ods:Boolean;
  {$ENDIF}

  procedure readln(var s: string);
  begin
    {$IFDEF OPENCALC}
    if flg_from_ods then
      ods.readln(s)
    else
      system.readln(f, s);
    {$ELSE}
    system.readln(f, s);
    {$ENDIF}
    Inc(cnt_linea);
  end;

begin
  cnt_linea := 0;

  try

    inherited Create;
    self.archi := archi;

    {$IFDEF OPENCALC}
    ext:=ExtractFileExt(archi);
    if ext = '.ods' then
    begin
      flg_from_ods:=true;
      ods:=TLibroOpenCalc.Create(false,archi);
      ods.FormatSettings.DecimalSeparator:='.';
      uauxiliares.setSeparadoresGlobales;
    end
    else
    begin
      flg_from_ods:=False;
   {$ENDIF}
      assignfile(f, archi);
    {$I-}
      reset(f);
    {$I+}
      if ioresult <> 0 then
        raise Exception.Create('No puedo abrir el archivo: ' + archi);
      uauxiliares.setSeparadoresGlobales;
   {$IFDEF OPENCALC}
    end;
   {$ENDIF}

    r:= '';
    readln(r);
    eliminar_BOM(r );


    if pos('VERSION_FORMATO_SERIES', r) <> 0 then
    begin
      nextpal(r);
      version := nextInt(r);
    end
    else
      version := 0;

    (* leemos los parámetros globales *)
    if (version > 0) then
    begin
      readln(r); // cantidad de series a tratar
      NSeries := nextInt(r);
    end
    else
      NSeries := nextInt(r);

    readln(r);

    PM_Anio := nextInt(r);
    PM_Mes := nextInt(r);
    PM_Dia := nextInt(r);
    PM_Hora := nextInt(r);
    PM_Minuto := nextInt(r);
    PM_Segundo := nextInt(r);
    //PM_Segundo := trunc(NextFloat(r));
    readln(r);
    PeriodoDeMuestreo_horas := nextFloat(r);


    readln(r);
    NPuntos := nextInt(r);    // cantidad de puntos totales por serie
    readln(r);
    rNPPorCiclo := nextFloat(r); // cantidad de puntos en un ciclo
    if version > 2 then
    begin
      readln(r);
      NCronicas := nextInt(r)    // cantidad de cronicas por serie
    end
    else
      NCronicas:= 1;

    setlength(self.tipo_Serie, NSeries);
    if (version > 0) then
    begin
      readln(r);
      for kserie := 1 to NSeries do
      begin
        if r[kserie] = 'x' then
          tipo_Serie[kserie - 1] := ENTRADA
        else
          tipo_Serie[kserie - 1] := SALIDA;
      end;
    end
    else
    begin
      for kserie := 1 to NSeries - 1 do
        tipo_Serie[kserie - 1] := SALIDA;
    end;

{$IFDEF GRUPOS_POLARES}
    flg_GruposPolares := True;
    if (version >= 2) then
    begin
      GruposPolares := TGruposPolares.Create_ReadFromTextFile(
        f, cnt_linea, r, flg_GruposPolares);
    end
    else
      GruposPolares := TGruposPolares.Create_vacio;

    if not flg_GruposPolares then // si no usé la línea son las series
{$ENDIF}



    // Creamos e inicializamos el soporte para las series
    SetLength(cronicas_series, NCronicas);
    for kCronica:=0 to NCronicas - 1 do
    begin
       SetLength(cronicas_series[kCronica],NSeries);
       for kserie := 1 to NSeries do
         cronicas_series[kCronica][kserie - 1] := TVectR.Create_Init(NPuntos);
    end;


    nombresSeries := TStringList.Create;


    // Leemos los datos en las series $
    for kCronica:=0 to NCronicas - 1 do
    begin
      if version > 2 then
      begin
        readln(r); // renglon en blanco
        readln(r); // el identificador de la cronica
      end;
      readln(r); // encabezado de las series

      if kCronica = 0 then
        for kserie := 0 to NSeries - 1 do
        begin
          serie := NextPal(r);
          nombresSeries.Add(serie);
        end;

      for kpunto := 1 to NPuntos do
      begin
        readln(r );
        fk:= NextFloat( r );
        for kserie := 1 to nSeries do
          cronicas_series[kCronica][kserie - 1].pv[kpunto]:= nextFloat( r );
      end;
    end;


    uauxiliares.setSeparadoresLocales;
    {$IFDEF OPENCALC}
    if flg_from_ods then
      ods.Free
    else
    {$ENDIF}
      CloseFile(f);

    calc_constantes;
    actualizarAuxiliares;
  except
    raise Exception.Create('Error leyendo línea: ' + IntToStr(cnt_linea));
  end;
end;




constructor TSeriesDeDatos.CreateVacia(dtPrimeraMuestra: TDateTIme;
  PeriodoDeMuestreo_Horas: NReal; nPuntos: integer;nCronicas:integer);

var
  anio, mes, dia, hora, minuto, segundo, milisegundo: word;
begin
  inherited Create;
  decodeDate(dtPrimeraMuestra, Anio, Mes, Dia);
  PM_Anio := Anio;
  PM_Mes := Mes;
  PM_Dia := Dia;
  decodetime(dtPrimeraMuestra, hora, minuto, segundo, milisegundo);
  PM_Hora := hora;
  PM_Minuto := minuto;
  PM_Segundo := segundo;
  self.Nseries:=0;
  rNPPorCiclo := 1;
  Self.NCronicas:=nCronicas;
  self.NPuntos := NPuntos;
  self.PeriodoDeMuestreo_horas := PeriodoDeMuestreo_Horas;
  nombresSeries := TStringList.Create;

  setlength(tipo_Serie, 0);
  setlength(cronicas_series,nCronicas);

  calc_constantes;
  actualizarAuxiliares;
end;


procedure TSeriesDeDatos.calc_constantes;
begin
  dtDuracionCicloPrincial := calc_dtDuracionCicloPrincial;
  dtPrimeraMuestra_InicioDelAnio := calc_dtPrimeraMuestra_InicioDelAnio;
  dtPrimeraMuestra_InicioDelDia := calc_dtPrimeraMuestra_InicioDelDia;
  dtPrimeraMuestra := calc_dtPrimeraMuestra;
  dtEntreMuestras := calc_dtEntreMuestras;
  (**ATENCION rch@201602120900
  Agrego detección del offset del ciclo en las series de datos.
  Si se trata de un ciclo ANUAL, el offset es desde inicio del año.
  Si se trata de un ciclo DIARIO, el offset es dede inicio del dia.
  Si NPuntosPorCiclo = 1 el offset es cero. **)

  if dtDuracionCicloPrincial < 0.9 then
  begin
    dtInicioCiclo := dtPrimeraMuestra;
    rOffsetCiclo := 0;
  end
  else
  begin
    if abs(dtDuracionCicloPrincial - 1) < 0.1 then
      dtInicioCiclo := dtPrimeraMuestra_InicioDelDia
    else
      dtInicioCiclo := dtPrimeraMuestra_InicioDelAnio;
    rOffsetCiclo := (dtPrimeraMuestra - dtInicioCiclo) / dtDuracionCicloPrincial;
  end;
end;


procedure TSeriesDeDatos.actualizarAuxiliares;
var
  cnt_Entradas, cnt_Salidas: integer;
  kTipoSerie,kCronicas: integer;
begin

  cnt_Entradas := 0;
  cnt_Salidas := 0;

  for kTipoSerie := 0 to high(self.tipo_Serie) do
    if tipo_Serie[kTipoSerie] = ENTRADA then
      Inc(cnt_Entradas)
    else
      Inc(cnt_Salidas);

  setlength(seriesX__, cnt_Entradas);
  setlength(seriesy__, cnt_Salidas);

  setlength(NombresSeriesX, cnt_Entradas);
  setlength(NombresSeriesy, cnt_Salidas);

  NSeriesX := cnt_Entradas;
  NSeriesY := cnt_Salidas;

  cnt_Entradas := 0;
  cnt_Salidas := 0;


  for kTipoSerie := 0 to high(self.tipo_Serie) do
    if tipo_Serie[kTipoSerie] = ENTRADA then
    begin
      NombresSeriesX[cnt_Entradas] := nombresSeries[kTipoSerie];
      Inc(cnt_Entradas);
    end
    else
    begin
      NombresSeriesY[cnt_Salidas] := nombresSeries[kTipoSerie];
      Inc(cnt_Salidas);
    end;

  kCronicaActiva:= 1;
  enfoqueCronica( kCronicaActiva );
end;

function TSeriesDeDatos.calc_dtPrimeraMuestra_InicioDelAnio: TDateTime;
var
  res_date: TDateTime;
begin
  res_date := encodedate(PM_Anio, 1, 1);
  Result := res_date;
end;

function TSeriesDeDatos.calc_dtPrimeraMuestra_InicioDelDia: TDateTime;
var
  res_date: TDateTime;
begin
  res_date := encodedate(PM_Anio, PM_Mes, PM_Dia);
  Result := res_date;
end;



function TSeriesDeDatos.calc_dtPrimeraMuestra: TDateTime;
var
  res_date: TDateTime;
  res_time: TDateTime;
begin
  res_date := calc_dtPrimeraMuestra_InicioDelDia;
  res_time := encodetime(PM_Hora, PM_Minuto, PM_segundo, 0);
  Result := res_date + res_time;
end;

function TSeriesDeDatos.calc_dtEntreMuestras: TDateTime;
begin
  Result := PeriodoDeMuestreo_horas / 24.0;
end;

function TSeriesDeDatos.calc_dtDuracionCicloPrincial: TDateTime;
begin
  Result := calc_dtEntreMuestras * rNPPorCiclo;
end;

// Calcula el índice del deformador usando la información
// de rOffset y rNPuntosPorCiclo
function TSeriesDeDatos.kDefomador(kMuestra: integer): integer;
begin
  Result := kPasoCiclico(kMuestra, rNPPorCiclo, rOffsetCiclo);
end;

// Retorna la fecha de la muestra kMuestra
function TSeriesDeDatos.dtMuestra(kMuestra: integer): TDateTime;
begin
  Result := dtPrimeraMuestra + (kMuestra - 1) * dtEntreMuestras;
end;

function TSeriesDeDatos.kOfSerie(nombreSerie: string): integer;
var
  buscando: boolean;
  k: integer;
begin
  buscando:= true;
  k:= 0;
  while buscando and (k < self.nombresSeries.Count) do
  begin
    if nombreSerie = nombresSeries[k] then
      buscando:= false
    else
      inc( k );
  end;
  if buscando then
    result:= -1
  else
    result:= k;
end;

procedure TSeriesDeDatos.enfoqueCronica(kCron: integer);
var
  kTipoSerie: integer;
  cnt_entradas: integer;
  cnt_salidas: integer;

begin
  kCronicaActiva:=kCron;
  series__:= cronicas_series[kCronicaActiva-1];

  cnt_entradas:= 0;
  cnt_salidas:= 0;
  for kTipoSerie := 0 to high(self.tipo_Serie) do
    if tipo_Serie[kTipoSerie] = ENTRADA then
    begin
      seriesX__[cnt_Entradas] := series__[kTipoSerie];
      Inc(cnt_Entradas);
    end
    else
    begin
      seriesY__[cnt_Salidas] := series__[kTipoSerie];
      Inc(cnt_Salidas);
    end;

end;




procedure TSeriesDeDatos.WriteToArchi(archi: string);
var
  f: TextFile;
  r: string;
  kserie, kpunto,kCronica: integer;
  buff: array[1..1024 * 1024] of byte;
  dt: TDateTime;

begin
  self.archi := archi;
  assignfile(f, archi);
  {$I-}
  rewrite(f);
  {$I+}
  SetTextBuf(f, buff{%H-});
  if ioresult <> 0 then
    raise Exception.Create('No puedo abrir el archivo: ' + archi);
  uauxiliares.setSeparadoresGlobales;


  calc_constantes;


  system.writeln(f, 'VERSION_FORMATO_SERIES:', #9, VERSION_FORMATO_SERIES);

  (* leemos los parámetros globales *)
  system.writeln(f, NSeries); // cantidad de series a tratar

  r := IntToStr(PM_Anio) + #9 + IntToStr(PM_Mes) + #9 + IntToStr(
    PM_Dia) + #9 + IntToStr(PM_Hora) + #9 + IntToStr(PM_Minuto) + #9 +
    IntToStr(PM_Segundo);
  system.writeln(f, r);

  writeln(f, PeriodoDeMuestreo_horas);


  system.writeln(f, NPuntos);    // cantidad de puntos totales por serie
  system.writeln(f, rNPPorCiclo: 12: 4); // cantidad de puntos en un ciclo
  system.writeln(f, NCronicas); // cantidad de cronicas por serie

  r := '';
  for kserie := 1 to NSeries do
  begin
    if tipo_Serie[kserie - 1] = SALIDA then
      r := r + 'x'
    else
      r := r + 'y';
  end;
  system.writeln(f, r);

  {$IFDEF GRUPO_POLARES}
  // Grupos Polares
  GruposPolares.WriteToTextFile(f);
  {$ENDIF}


  for kCronica:= 1 TO NCronicas do
  begin
    enfoqueCronica( kCronica );
    system.writeln( f );
    system.writeln( f, 'kCron:', #9, kCronica );
    r := #9;
    for kserie := 0 to NSeries - 1 do
    begin
      if kserie > 0 then
        r := r + #9;
      r := r + nombresSeries[kserie];
    end;
    system.writeln(f, r); // encabezado de las series

  // escribimos los datos de las series
  for kpunto := 1 to NPuntos do
  begin
    //    system.Write(f, kpunto);
    dt := dtPrimeraMuestra + dtEntreMuestras * (kPunto - 1);
    system.Write(f, dt);
    for kserie := 1 to nSeries do

     { if series[kserie - 1].n  < NPuntos then
      begin
        SetLength(series[kserie-1].pv,NPuntos);
        for j:=kpunto to Npuntos do
          series[kserie-1].pv[j]:=-777777;
      end;  }
      system.Write(f, #9, series__[kserie - 1].pv[kpunto]);
    system.writeln(f);
  end;


  end;


  uauxiliares.setSeparadoresLocales;
  CloseFile(f);
end;



function TSeriesDeDatos.CreateCloneHeadInfo: TSeriesDeDatos;
var
  res: TSeriesDeDatos;
  k,kCronica: integer;

begin
  res := TSeriesDeDatos.Create;
  res.version := version;
  res.archi := 'clonada_de_' + archi;
  res.NSeries := NSeries;
  res.PM_Anio := PM_Anio;
  res.PM_Mes := PM_Mes;
  res.PM_Dia := PM_Dia;
  res.PM_Hora := PM_Hora;
  res.PM_Minuto := PM_Minuto;
  res.PM_segundo := PM_segundo;
  res.PeriodoDeMuestreo_horas := PeriodoDeMuestreo_horas;
  res.NPuntos := NPuntos;
  res.rNPPorCiclo := rNPPorCiclo;
  res.nombresSeries := TStringList.Create;
  for k := 0 to nombresSeries.Count - 1 do
    res.NombresSeries.add(nombresSeries[k]);
  setlength(res.tipo_Serie, NSeries);
  SetLength(res.cronicas_series,NCronicas);

  for kCronica:= 0 to NCronicas - 1 do
    SetLength(res.cronicas_series[kCronica],NSeries);
  res.series__:=res.cronicas_series[0];

  for k := 0 to high(tipo_Serie) do
    res.tipo_Serie[k] := tipo_Serie[k];

  res.NSeriesX := NSeriesX;
  res.NSeriesY := NSeriesY;
  res.NCronicas:= NCronicas;

  Result := res;
end;

function TSeriesDeDatos.CreateCloneHeadInfo_Entradas: TSeriesDeDatos;
var
  res: TSeriesDeDatos;
  k,kCronica: integer;
begin
  res := TSeriesDeDatos.Create;
  res.version := version;
  res.archi := 'ENTRADAS_clonada_de_' + archi;
  res.NSeries := NSeriesX;
  res.PM_Anio := PM_Anio;
  res.PM_Mes := PM_Mes;
  res.PM_Dia := PM_Dia;
  res.PM_Hora := PM_Hora;
  res.PM_Minuto := PM_Minuto;
  res.PM_segundo := PM_segundo;
  res.PeriodoDeMuestreo_horas := PeriodoDeMuestreo_horas;
  res.NPuntos := NPuntos;
  res.NCronicas:=NCronicas;
  res.rNPPorCiclo := rNPPorCiclo;
  res.nombresSeries := TStringList.Create;
  for k := 0 to high(NombresSeriesX) do
    res.NombresSeries.add(nombresSeries[k]);

  SetLength(res.cronicas_series,NCronicas);
  for kCronica:= 0 to NCronicas - 1 do
    SetLength(res.cronicas_series[kCronica],NSeriesX);

  setlength(res.tipo_Serie, NSeriesX);
  for k := 0 to high(res.tipo_Serie) do
    res.tipo_Serie[k] := ENTRADA;

  res.actualizarAuxiliares;

  Result := res;
end;



function TSeriesDeDatos.CreateCloneHeadInfo_Salidas: TSeriesDeDatos;
var
  res: TSeriesDeDatos;
  k,kCronica: integer;
begin
  res := TSeriesDeDatos.Create;
  res.version := version;
  res.archi := 'SALIDAS_clonada_de_' + archi;
  res.NSeries := NSeriesY;
  res.PM_Anio := PM_Anio;
  res.PM_Mes := PM_Mes;
  res.PM_Dia := PM_Dia;
  res.PM_Hora := PM_Hora;
  res.PM_Minuto := PM_Minuto;
  res.PM_segundo := PM_segundo;
  res.PeriodoDeMuestreo_horas := PeriodoDeMuestreo_horas;
  res.NPuntos := NPuntos;
  res.rNPPorCiclo := rNPPorCiclo;
  res.nombresSeries := TStringList.Create;
  for k := 0 to high(NombresSeriesY) do
    res.NombresSeries.add(nombresSeries[k]);

  SetLength(res.cronicas_series,NCronicas);
  for kCronica:= 0 to NCronicas - 1 do
    SetLength(res.cronicas_series[kCronica],NSeriesY);


  setlength(res.tipo_Serie, NSeriesY);
  for k := 0 to high(res.tipo_Serie) do
    res.tipo_Serie[k] := SALIDA;

  res.actualizarAuxiliares;

  Result := res;
end;


function TSeriesDeDatos.Resampling(Nuevo_PeriodoDeMuestreo_horas: NReal): TSeriesDeDatos;
var
  res: TSeriesDeDatos;
  k, j: integer;
  aSerie, bSerie: TVectR;
  flg_SubMuestreo: boolean;
  kr1, kr2: NReal;
  fTs: NReal;
  aval: NReal;
  kCronica: integer;

begin
  fTs := Nuevo_PeriodoDeMuestreo_horas / PeriodoDeMuestreo_horas;
  flg_Submuestreo := fTs > 1.0;
  res := CreateCloneHeadInfo;
  res.PeriodoDeMuestreo_horas := Nuevo_PeriodoDeMuestreo_horas;
  res.NPuntos := trunc((NPuntos - 1) / fTs);

  for kCronica:= 1 to NCronicas do
  begin
     res.series__:= res.cronicas_series[ kCronica-1 ];
     series__:= cronicas_series[ kCronica-1 ];
     for k := 0 to high(res.series__) do
     begin
       aSerie := TVectR.Create_Init(res.NPuntos);
       res.series__[k] := aSerie;
       bSerie := series__[k];
       if flg_SubMuestreo then
       begin
         aSerie.pon_e(1, bSerie.e(1));
         for j := 2 to aSerie.n do
         begin
           kr1 := (j - 2) * fTs + 1;
           kr2 := kr1 + fTs;
           aval := bSerie.integral(kr1, kr2);
           aSerie.pon_e(j, aval / fTs);
         end;
       end
       else
         for j := 1 to aSerie.n do
         begin
           kr1 := (j - 1) * fTs + 1;
           aval := bSerie.interpol(kr1);
           aSerie.pon_e(j, aval);
         end;
     end;
  end;
  res.actualizarAuxiliares;
  Result := res;
end;

function TSeriesDeDatos.Clone: TSeriesDeDatos;
var
  kSerie,kCronica: integer;
  res: TSeriesDeDatos;
begin
  res := CreateCloneHeadInfo;

  for kCronica:=0 to res.NCronicas - 1 do
    for kSerie:= 0 to res.NSeries - 1 do
      res.cronicas_series[kCronica][kSerie]:=
        TVectR.Create_Clone(cronicas_series[kCronica][kSerie]);

  //    res.series[k] := TVectR.Create_Clone(series[k]);

  res.calc_constantes;
  res.actualizarAuxiliares;
  Result := res;
end;


// Crea un Clon del conjunto de series de Entrada
function TSeriesDeDatos.Clone_Entradas: TSeriesDeDatos;
var
  kSerie,kCronica: integer;
  res: TSeriesDeDatos;
begin
  res := CreateCloneHeadInfo_Entradas;
  for kCronica:= 0 to res.NCronicas - 1 do
  begin
    enfoqueCronica( kCronica + 1 );
    res.enfoqueCronica( kCronica+1 );
    for kSerie:= 0 to res.NSeries - 1 do
      res.cronicas_series[kCronica][kSerie]:=
        TVectR.Create_Clone( seriesX__[kSerie]);
  end;
  res.calc_constantes;
  res.actualizarAuxiliares;
  Result := res;
end;

// Crea un Clon del conjunto de series de Salida
function TSeriesDeDatos.Clone_Salidas: TSeriesDeDatos;
var
  kSerie,kCronica: integer;
  res: TSeriesDeDatos;
begin
  res := CreateCloneHeadInfo_Salidas;
  for kCronica:= 0 to res.NCronicas - 1 do
  begin
    enfoqueCronica( kCronica + 1 );
    res.enfoqueCronica( kCronica+1 );
    for kSerie:= 0 to res.NSeries - 1 do
      res.cronicas_series[kCronica][kSerie]:=
        TVectR.Create_Clone( seriesY__[kSerie]);
  end;

  res.calc_constantes;
  res.actualizarAuxiliares;
  Result := res;
end;


procedure TSeriesDeDatos.VelDir_To_VelxVely(kSerie_Dir, kSerie_Vel: integer;
  Nombre_Velx, Nombre_Vely: string);
var
  kPunto: integer;
  Vel_x, valor_filtro: NReal;
  Vel_y: NReal;
begin
  for kPunto := 1 to NPuntos do
    if ( series__[kSerie_Dir].e(kPunto) < 0) or (series__[kSerie_Vel].e(kPunto) < 0) then
    begin
      valor_filtro := min(series__[kSerie_Dir].e(kPunto), series__[kSerie_Vel].e(kPunto));
      series__[kSerie_Dir].pon_e(kPunto, valor_filtro);
      series__[kSerie_Vel].pon_e(kPunto, valor_filtro);
    end
    else
    begin
      Vel_x := -sin(series__[kSerie_Dir].e(kPunto) * pi / 180) *
        series__[kSerie_Vel].e(kPunto);
      Vel_y := -cos(series__[kSerie_Dir].e(kPunto) * pi / 180) *
        series__[kSerie_Vel].e(kPunto);
      series__[kSerie_Dir].pon_e(kPunto, Vel_y);
      series__[kSerie_Vel].pon_e(kPunto, Vel_x);
    end;

  nombresSeries[kSerie_Dir] := Nombre_Vely;
  nombresSeries[kSerie_Vel] := Nombre_Velx;

end;




procedure TSeriesDeDatos.DelSerie(kSerie: integer);
var
  aux: TDAOfVectR;
  auxTipos: TDAOfTipoSerie;
  k: integer;
  kCron: integer;
begin
  Dec(nSeries);
  setlength(auxTipos, nseries);
  for k := 0 to kSerie - 1 do
    auxTipos[k] := tipo_Serie[k];
  for k := kSerie to high(aux) do
    auxTipos[k] := tipo_Serie[k + 1];
  setlength(tipo_Serie, 0);
  tipo_Serie := auxTipos;

  for kCron:= 0 to NCronicas-1 do
  begin
    series__:=cronicas_series[kCron];
    series__[kSerie].Free;
    setlength(aux, NSeries);
    for k := 0 to kSerie - 1 do
      aux[k] := series__[k];
    for k := kSerie to high(aux) do
      aux[k] := series__[k + 1];
    cronicas_series[kCron]:= aux;
  end;

  nombresSeries.Delete(kSerie);
  actualizarAuxiliares;
end;


procedure TSeriesDeDatos.AddSerie(NombreSerie: string; vdatos: TVectR;
  tipoSerie: TIPO_SERIE);

begin
  // si usan esto es porque tienen una cronica sola
  if NCronicas > 1 then
    raise Exception.Create('NCronicas > 1, imposible agregar una serie de una'+
      ' sola realizacion');

   Inc(nseries);

   setlength( cronicas_series[0], nseries);
   series__:= cronicas_series[0];
   if vdatos = nil then
     series__[nseries - 1] := TVectR.Create_init(self.NPuntos)
   else
     series__[nseries - 1] := vdatos;

   setlength(tipo_Serie, nseries);
   tipo_Serie[nseries - 1] := tipoSerie;
   nombresSeries.add(NombreSerie);
   actualizarAuxiliares;

end;

procedure TSeriesDeDatos.AddSerieCron(NombreSerie: string; sdatos: TDAOfVectR;
  tipoSerie: TIPO_SERIE);
var
  kCronica:integer;
begin

   Inc(nseries);

   for kCronica:=0 to NCronicas - 1 do
   begin
     setlength(cronicas_series[kCronica], nseries);
     if sdatos = nil then
       cronicas_series[kCronica][NSeries - 1]:=TVectR.Create_init(self.NPuntos)
     else
       cronicas_series[kCronica][NSeries - 1] := sdatos[kCronica];
   end;

   setlength(tipo_Serie, nseries);
   tipo_Serie[nseries - 1] := tipoSerie;
   nombresSeries.add(NombreSerie);

   actualizarAuxiliares;

end;

procedure TSeriesDeDatos.AddSeriesFromArchi(archi: string);
var
  saux: TSeriesDeDatos;
  nombre: string;
  val: TVectR;
  kSerie: integer;
  sDatos: TDAOfVectR;
  kCronica: integer;

begin
  saux := TSeriesDeDatos.CreateFromArchi(archi);

  if saux.NCronicas <> NCronicas then
    raise Exception.Create('TSeriesDeDatos.AddSeriesFromArchi ... NCronicas(archi): '+IntToStr( saux.NCronicas)+' <> '+IntToStr( NCronicas ));

  if self.NPuntos <> saux.NPuntos then
    raise Exception.Create('TSeriesDeDatos.AddSeriesFromArchi ... NCPuntos(archi): '+IntToStr( saux.NPuntos )+' <> '+IntToStr( NPuntos ));

  for kSerie := 0 to saux.NSeries - 1 do
  begin
    nombre := saux.nombresSeries[kSerie];
    setlength( sDatos, NCronicas );

    for kCronica:= 0 to high( sDatos ) do
      sDatos[kCronica] := saux.cronicas_series[kCronica][kSerie];

    self.AddSerieCron( nombre, sDatos);
  end;
end;

function TSeriesDeDatos.GetSerie(kSerie: integer): TVectR;
var
  jSerie, kCronica, nSeriesAdicionales: integer;
  sDatos: TDAOfVectR;
begin
  nSeriesAdicionales:= kSerie- (self.NSeries-1);
  if nSeriesAdicionales > 0 then
  begin
    for jSerie := 0 to nSeriesAdicionales - 1 do
    begin
      setlength( sDatos, NCronicas );
      for kCronica:= 0 to high( sDatos ) do
        sdatos[kCronica]:= TVectR.Create_Init( NPuntos);
      AddSerieCron( 'sa_'+IntToStr( NSeries ), sDatos );
    end;
  end;
  result:= series__[ kSerie ];
end;

function TSeriesDeDatos.GetSerieX(kSerie: integer): TVectR;
begin
  result:= seriesX__[ kSerie ];
end;

function TSeriesDeDatos.GetSerieY(kSerie: integer): TVectR;
begin
  result:= seriesY__[ kSerie ];
end;

procedure TSeriesDeDatos.AcumSeries(xserie: TSeriesDeDatos; huecos: TDAofNReal; // guion bajo DV 16/2/17
  offset: integer; defval: Nreal);
var
  kSerie, kCronica, nSeriesAdicionales: integer;
  sDatos: TDAOfVectR;
begin
  nSeriesAdicionales:= xserie.NSeries - (self.NSeries - offset);
  if nSeriesAdicionales > 0 then
  begin
    for kSerie := 0 to nSeriesAdicionales - 1 do
    begin
      setlength( sDatos, NCronicas );
      for kCronica:= 0 to high( sDatos ) do
        sDatos[kCRonica]:=TVectR.Create_Init(xserie.NPuntos);
      self.AddSerieCron(xserie.nombresSeries[
       kSerie + (xserie.NSeries - nSeriesAdicionales) ], sDatos );
    end;
  end;

  for kCronica:= 0 to nCronicas do
  begin
   series__:= cronicas_series[kCronica];
   xserie.series__:= xserie.cronicas_series[kCronica];
   for kSerie := 0 to xserie.NSeries - 1 do
   begin
     xserie.series__[kSerie].limpiar_huecos(huecos, defval);
     self.series__[kSerie + offset].sum( xserie.series__[kSerie] );
   end;
  end;
end;

procedure TSeriesDeDatos.WriteCOVARS(archi: string; umbral_filtro: NReal);
var
  f: TextFile;
  r: string;
  kserie, kCronica, kpunto: integer;
  ve, desv: TVectR;
  cxx: TVectR;
  cnt_cxx: TVectE;
  aSerie: TVectR;
  kRet, jSerie: integer;
  xs1, xs2: NReal;
  k, jvar: integer;
  prom, vrz: NReal;
  NPuntosCovar: integer;
  ramillete: TDAOfVectR;

begin
  self.archi := archi;
  assignfile(f, archi);
  {$I-}
  rewrite(f);
  {$I+}
  if ioresult <> 0 then
    raise Exception.Create('No puedo abrir el archivo: ' + archi);
  uauxiliares.setSeparadoresGlobales;
  system.writeln(f, 'VERSION_FORMATO_SERIES:', #9, VERSION_FORMATO_SERIES);
  system.writeln(f, NSeries); // cantidad de series a tratar

  r := IntToStr(PM_Anio) + #9 + IntToStr(PM_Mes) + #9 + IntToStr(
    PM_Dia) + #9 + IntToStr(PM_Hora) + #9 + IntToStr(PM_Minuto) + #9 +
    IntToStr(PM_Segundo);
  system.writeln(f, r);

  writeln(f, PeriodoDeMuestreo_horas);


  system.writeln(f, NPuntos);    // cantidad de puntos totales por serie
  system.writeln(f, rNPPorCiclo: 12: 4); // cantidad de puntos en un ciclo

  // escribimos encabezados
  for kserie := 0 to NSeries - 1 do
    for jserie := 0 to NSeries - 1 do
      system.Write(f, #9, nombresSeries[kserie] + '(x)' + nombresSeries[jserie]);
  system.writeln(f, ''); // encabezado de las series

  desv := TVectR.Create_init(NSeries);
  ve := TVectR.Create_init(NSeries);
  cxx := TVectR.Create_Init(NSeries * NSeries);
  cnt_cxx := TVectE.Create_Init(cxx.n);



  // Primero calculamos los promedios y desvíos
  for kSerie := 1 to NSeries do
  begin
    setlength( ramillete, NCronicas );
    for kCronica:= 0 to NCronicas - 1 do
    begin
      ramillete[kCronica]:= cronicas_series[kCronica][kSerie];
    end;
    PromedioVarianza_filtrando( prom, vrz, ramillete, umbral_filtro);
    ve.pon_e(kSerie, prom);
    desv.pon_e(kSerie, sqrt( vrz ));
  end;


  // Ahora para cada retardo calculamos los coeficientes de covarianza
  if rNPPorCiclo >= 24 then
    NPuntosCovar := trunc(rNPPorCiclo)
  else
    NPuntosCovar := NPuntos div 4;

  NPuntosCovar := min(6 * 36, NPuntosCovar);

  for kRet := 0 to NPuntosCovar - 1 do
  begin
    writeln('Paso WriteCovar : ', (kRet + 1), ' de : ', NPuntosCovar);
    cxx.Ceros;
    cnt_cxx.Ceros;
    Write(f, kRet);
    for kPunto := kRet + 1 to NPuntos do
    begin
      for kCronica:= 0 to NCronicas-1 do
      begin
        series__:= cronicas_series[kCronica];
        for kSerie := 1 to NSeries do
        begin
          xs1 :=  Series__[kSerie - 1].e(kPunto - kRet);
          if xs1 > umbral_filtro then
          begin
            xs1 := (xs1 - ve.e(kSerie)) / desv.e(kSerie);
            for jSerie := 1 to NSeries do
            begin
              xs2 := Series__[jSerie - 1].e(kPunto);
              if xs2 > umbral_filtro then
              begin
                xs2 := (xs2 - ve.e(jSerie)) / desv.e(jSerie);
                jvar := ((kSerie - 1) * NSeries + jSerie);
                cxx.acum_e(jvar, xs1 * xs2);
                cnt_cxx.acum_e(jvar, 1);
              end;
            end;
          end;
        end;
      end;
    end;

    for k := 1 to cxx.n do
      if cnt_cxx.e(k) > 0 then
        cxx.pon_e(k, cxx.e(k) / cnt_cxx.e(k))
      else
        cxx.pon_e(k, umbral_filtro);

    for kSerie := 1 to NSeries do
      for jSerie := 1 to NSeries do
      begin
        jvar := ((kSerie - 1) * NSeries + jSerie);
        Write(f, #9, cxx.e(jvar): 12: 4);
      end;
    system.writeln(f);
  end;
  uauxiliares.setSeparadoresLocales;
  CloseFile(f);
  desv.Free;
  cxx.Free;
  cnt_cxx.Free;
end;




procedure TSeriesDeDatos.Free;
var
  kCron, i,kSerie: integer;
begin
  setlength(seriesX__, 0);
  setlength(seriesy__, 0);
  setlength(NombresSeriesX, 0);
  setlength(NombresSeriesy, 0);
  if nombresSeries <> nil then
    nombresSeries.Free;

  if cronicas_series <> nil then
  begin
    for kCron:= 0 to NCronicas-1 do
    begin
      series__:= cronicas_series[kCron];
      for i := 0 to NSeries - 1 do
      begin
          FreeAndNil(series__[i]); //series__[i].Free;
      end;
      setlength( cronicas_series[kCron], 0 );
    end;
    setlength( cronicas_series, 0);
    setlength( series__, 0 );
  end;
  inherited Free;
end;

end.

