unit ugraficador;

{$mode delphi}
// rch@201504051946
// Creo esta unidad de gráficos para tener una opción a la salida en Excel
// del SimRes3. Esto es especialmente útil en ambiente linux y para simulaciones
// de miles de crónicas que el Excel revienta.


interface

uses
  Classes, Math, types, SysUtils,
  {$IFDEF SVG_CANVAS}
  usvgcanvas,
  //utestsvg,
  {$ELSE}
  {$IFDEF FP_CANVAS}
  ucoloresbasicos,
  FPimage,
  FPImgCanv,
  ftfont,
  FPCanvas,
  {$ELSE}
  Graphics,
  {$ENDIF}
  FPWritePNG,
  FPWriteJPEG,
  //  ulogoSimSEE,
  {$ENDIF}
  // fpjsonrtti,
  fpjson,
  xmatdefs, autoesca, matreal, dateutils;

{$IFDEF SIM_EXCEL}
{$DEFINE SIN_GRAPHICS}
{$ENDIF}

{$IFDEF SVG_CANVAS}
{$DEFINE SIN_GRAPHICS}
{$ENDIF}

{$IFDEF FP_CANVAS}
{$UNDEF SIN_GRAPHICS}
{$ENDIF}

{$IFDEF SIN_GRAPHICS}
type
  TColor = -$7FFFFFFF - 1..$7FFFFFFF;

const
  // special colors
  clNone = TColor($1FFFFFFF);
  clDefault = TColor($20000000);
{$ENDIF}


type
  TTipoGrafico = (TG_Lineas, TG_AreasApiladas, TG_DispersionXY,
    TG_Barras, TG_BarrasApiladas, TG_MapaRectangular, TG_MapaCircular);
  TTipoSerie = (TS_Serie, TS_SerieX, TS_SerieY);
  TTipoMarcador = (TM_Circulo, TM_Cuadro, TM_Rombo, TM_Cruz, TM_X);
  TTipoDatoEje = (TDE_Real, TDE_Entero, TDE_Fecha);

  {$IFNDEF FP_CANVAS}
  TkColorPaleta = 0 .. 14;
  {$ENDIF}
  {$IFDEF SVG_CANVAS}
  TCanvas = TSVGCanvas;
  {$ENDIF}

const
  {$IFNDEF SVG_CANVAS}
  {$IFNDEF FP_CANVAS}
  TColoresPaleta: array[TkColorPaleta] of TColor = (
    clBlack
    , clMaroon
    , clGreen
    , clOlive
    , clNavy
    , clPurple
    , clTeal
    , clGray
    , clSilver
    , clRed
    , clLime
    , clYellow
    , clBlue
    , clFuchsia
    , clAqua);
  {$ENDIF}
  {$ELSE}
  TColoresPaleta: array[TkColorPaleta] of TColor = (
    clBlack
    , clNavy
    , clGreen
    , clTeal
    , clMaroon
    , clPurple
    , clOlive
    , clGray
    , clSilver
    , clblue
    , clLime
    , clAqua
    , clRed
    , clFuchsia
    , clYellow);
  {$ENDIF}

  TNombreColores: array[TkColorPaleta] of string = (
    'Negro'
    , 'Marrón'
    , 'Verde'
    , 'Oliva'
    , 'Azul marino'
    , 'Púrpura'
    , 'Verde azulado'
    , 'Gris'
    , 'Plata'
    , 'Rojo'
    , 'Lima'
    , 'Amarillo'
    , 'Azul'
    , 'Fusia'
    , 'Agua');

  TNombreMarcador: array[TTipoMarcador] of string = (
    'Circulo', 'Cuadro', 'Rombo', 'Cruz', 'X');

type
  TGrafico = class; // Canvas para graficos. Con área para titulos, etiquetas y despliegue XY

  { TEjeGrafico }

  TEjeGrafico = class
    titulo: string;
    v_min_real, v_max_real: NReal; // valores extremos de las series.
    v_min_forzado, v_max_forzado: NReal; // valores fijados forzados.
    v_min_auto, v_max_auto: NReal; // valores calculados automáticamente.
    v_min_activo, v_max_activo: NReal;
    // valores activos, auto o forzado según corresponda

    flg_min_auto, flg_max_auto, flg_espacio_inf: boolean;
    // indica se usa el automático o el forzado,
    v0: NReal; // posición primera linea de la grilla
    dv: NReal; // ancho de la divición
    nDivs: integer; // cantida de divisiones de la grilla

    nDivs_forzado: integer;
    flg_ndivs_auto: boolean;

    flg_mostrar_lineas: boolean;
    flg_etiquetaX: boolean;

    // Por defecto
    tipoDato: TTipoDatoEje; // TDE_Real, TDE_Entero, TDE_Fecha,
    FloatFormat: TFloatFormat;
    // (ffGeneral, ffExponent, ffFixed, ffNumber, ffCurrency);
    FloatFormat_NDigitos, FloatFormat_NDecimales: integer; // 12.2
    DateFormatStr: string; // Ej: 'yyyy/mm/dd hh:mm'

    //Por defecto el tipo de dato del eje es real. Si se quisiera que fuera fecha
    //hay que o bien especificarlo aca o que la serie de datos del eje tenga formato fecha.
    constructor Create(Titulo: string; tipoDato:TTipoDatoEje = TDE_Real);

    // en min_val, max_val deben ingresar los extremos REALES
    // y son devueltos los aplicables
    procedure Calcular(var min_val, max_val: NReal);

    procedure Forzar_vmin(v_min: NReal);
    procedure Forzar_vmax(v_max: NReal);
    procedure Forzar_ndivs(ndivs: integer);

    procedure Librar_vmin;
    procedure Librar_vmax;
    procedure Liberar_ndivs;

    // retorna la etiqueta k con el formato correspondiente
    function label_str(k: integer): string;

    procedure Free;
  end;

  // Caja en el área XY
  TCajaGraficoXY = class
    x1, y1, x2, y2: NReal;
    texto: string;
    colorArea, colorLinea, colorTexto: TColor;
    sizeTexto: integer;
    eje: integer; // 0: izquierdo , 1: derecho
    {$IFNDEF SVG_CANVAS}
    penStyle: TPenStyle;
    brushStyle: TBrushStyle;
    {$ELSE}
    penStyle: TSVGPenStyle;
    brushStyle: TSVGBrushStyle;
    {$ENDIF}

    constructor Create(x1, y1, x2, y2: NReal; texto: string);
    procedure Draw(c: TCanvas; g: TGrafico);
    procedure Free;
  end;


  { TSerieGrafico }

  TSerieGrafico = class
    nombre: string;
    orden: integer;
    colorArea, colorLinea, colorFondoMarcador, colorLineaMarcador: TColor;
    tipoMarcador: TTipoMarcador;
    tipoGrafico: TTipoGrafico; // AreaApilada, XY, linea
    tipoSerie: TTipoSerie;
    valores: TDAOfNReal;
    RadioMarcador: integer;
    AnchoLineaMarcador: integer;
    AnchoLinea: integer;
    nombreValores: array of string;
    serie_x: TSerieGrafico;
    eje: integer; // 0 izquierdo, 1 derecho
    formato_str: string;
    {$IFDEF SVG_CANVAS}
    tipo_pen: TSVGPenStyle;
    {$ENDIF}

    // al crear la serie se pasa xvalores y la serie se encarga de eliminar
    constructor Create(nombre: string; xvalores: TDAOfNReal;
      serie_x: TSerieGrafico; grafico: TGrafico = nil;
    // Si <> nil lo usa para fijar colores y marcador automático
      formato_str: string = ''; // Lo usa para detectar formato fecha
      flg_SerieX: boolean = False); overload;

    // al crear la serie se pasa xvalores como TVectR. La serie los copia por lo que
    // no se encarga de eliminar el vector xvalores
    constructor Create(nombre: string; xvalores: TVectR;
      serie_x: TSerieGrafico; grafico: TGrafico = nil;
    // Si <> nil lo usa para fijar colores y marcador automático
      formato_str: string = ''; // Lo usa para detectar formato fecha
      flg_SerieX: boolean = False); overload;

    (*Crea series de graficos a partir de los archivos .sas
    donde la primer columna es la fecha y los valores seriesY
    PARAMETROS:
    -NOMBRE : nombre de la serie;
    -ARCHI  : ruta del archivo .sas a leer;
    -GRAFICO: si ya hay grafico toma el tipo y colores de ahí;
    -FORMATO_STR: formato de la leyendas;
    -FLG_SERIEX : si es x o y;
    -CERO   : entero que se usa para reprecentar un hueco en la serie.
    *)
    constructor CreateFromSAS(nombre: string; archi: string;
      grafico: TGrafico; formato_str: string; flg_SerieX: boolean;
      cero: integer = 0); overload;

    function clone: TSerieGrafico;

    procedure pintar(color: TColor);

    function FormatoFecha: boolean;
    procedure Free;
  end;

  TDAofSerieGrafico = array of TSerieGrafico;

  { TGrafico }

  TGrafico = class
    nombre: string;
    Titulo: string;
    eje_x, eje_y, eje_y2: TEjeGrafico;
    series_y: TList;
    series_x: TList;
    cajasXY: TList;

    tipoGrafico: TTipoGrafico;
    kEnLibro: integer;
    FontSize: integer;
    k_LogoSimSEE: integer;
    xinis, xfins, Ymean: TDAofNInt;

    constructor Create(nombre: string; tipoGrafico: TTipoGrafico;
      k_LogoSimSEE: integer = 0);
    procedure AddSerie(NuevaSerie: TSerieGrafico);
    procedure AddCajaXY(NuevaCajaXY: TCajaGraficoXY);
    function ProximoColor: TColor;
    function ProximoMarcador: TTipoMarcador;
    procedure Draw(c: TCanvas; ancho, alto: integer); virtual;
   {$IFDEF SVG_CANVAS}
    procedure SaveSVG(archi: string; ancho, alto: integer);
   {$ENDIF}

    procedure SaveJPG(archi: string; ancho, alto: integer;
    {%H-}Calidad: TFPJPEGCompressionQuality = 100);

    function toJSON(elemento: string): string;

    procedure Free;

    // Funciones de pasaje de XY a pixeles durante el DRAW.
    function x2w(x: NReal): integer;
    function y2h(y: NReal): integer;
    function y2h2(y: NReal): integer;

    // Conversión de pixeles a reales para posicionamiento del mouse
    function w2x(left: integer): NReal;
    function h2y(top: integer): NReal;

  private
    nid_ProximoColor: integer;
    nid_ProximoMarcador: integer;

    w0, h0, w1, h1: integer;
    mx, my, my2: NReal;
    min_X, max_X, min_Y, max_Y, min_Y2, max_Y2: NReal;

    tag_w, tag_h: integer;
    dh_TItuloGrafico: integer;
    dh_TItuloX: integer;
    dw_TItuloY2: integer;
    dw_TItuloY: integer;
    dw_EtiquetasSeries: integer;
    dw_EtiquetaTipoGen: integer;
    dh_Etiqueta: integer;
    tag_Etiqueta: integer;
    dw_EscalaY: integer;
    dw_EscalaY2: integer;
    dh_EscalaX: integer;

    function calc_ylabel_ancho(c: TCanvas): integer;
    function calc_y2label_ancho(c: TCanvas): integer;
    function calc_xlabel_alto(c: TCanvas): integer;

    procedure PlotBarras(c: TCanvas; lst_SeriesBarras: TList);
    procedure PlotBarrasApiladas(c: TCanvas; lst_SeriesBApiladas: TList);

    procedure plotMarcador(c: TCanvas; x, y: integer; tipoMarcador: TTipoMarcador;
      anchoLinea: integer; RadioMarcador: integer);

    procedure plotFillRect(c: TCanvas; x, y: integer; anchoLinea: integer;
      w, h: integer);

    procedure PlotDispersionXY_marcadores(c: TCanvas; lst_SeriesDispXY: TList);

    procedure PlotDispersionXY(c: TCanvas; lst_SeriesDispXY: TList);
    procedure PlotAreasApiladas(c: TCanvas; lst_SeriesAreasApiladas: TList);

    procedure ClipRect(var c: TCanvas; x1, y1, x2, y2: integer);
  end;

function EjeToStr(kEje: integer): string;

implementation

(*
var
  DateFormat: TFormatSettings = (CurrencyFormat: 1;
  NegCurrFormat: 5;
  ThousandSeparator: ',';
  DecimalSeparator: '.';
  CurrencyDecimals: 2;
  DateSeparator: '/';
  TimeSeparator: ':';
  ListSeparator: ',';
  CurrencyString: '$';
  ShortDateFormat: 'd/m/y';
  LongDateFormat: 'dd" "mmmm" "yyyy';
  TimeAMString: 'AM';
  TimePMString: 'PM';
  ShortTimeFormat: 'hh:nn';
  LongTimeFormat: 'hh:nn:ss';
  ShortMonthNames: ('Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul',
    'Ago', 'Sep', 'Oct', 'Nov', 'Dec');
  LongMonthNames: ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo',
    'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Novimbre', 'Diciembre');
  ShortDayNames: ('Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab');
  LongDayNames: ('Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves',
    'Viernes', 'Sabado');
  TwoDigitYearCenturyWindow: 50; );
  *)


function EjeToStr(kEje: integer): string;
begin
  if kEje = 0 then
    Result := 'izquierdo'
  else
    Result := 'derecho';
end;

constructor TEjeGrafico.Create(Titulo: string; tipoDato: TTipoDatoEje);
begin
  inherited Create;
  self.titulo := Titulo;
  v_min_real := 0;
  v_max_real := 0;
  v_min_forzado := 0;
  v_max_forzado := 0;
  v_min_activo := 0;
  v_max_activo := 0;
  v0 := 0.0;
  dv := 1.0;
  nDivs := 10;
  v_min_auto := 0;
  v_max_auto := 0;
  flg_min_auto := True;
  flg_max_auto := True;
  flg_mostrar_lineas := True;
  flg_etiquetaX := True;
  flg_espacio_inf := True;

  nDivs_forzado := 0;
  flg_ndivs_auto := True;

  self.tipoDato := tipoDato;
  FloatFormat := ffFixed;
  FloatFormat_NDigitos := 12;
  FloatFormat_NDecimales := 2;
  DateFormatStr := 'yyyy/mm/dd hh:mm';
end;

procedure TEjeGrafico.Calcular(var min_val, max_val: NReal);
begin

  self.v_min_real := min_val;
  self.v_max_real := max_val;

  v_min_auto := min_val;
  v_max_auto := max_val;


  if tipoDato = TDE_Fecha then
    if (flg_min_auto and flg_max_auto) then
      EscalaFechaN(v_min_auto, v_max_auto, dv, nDivs, 1)
    else
      EscalaFechaN(v_min_auto, v_max_auto, dv, nDivs, 0)
  else
  if (flg_min_auto and flg_max_auto) then
    Escala125N(v_min_auto, v_max_auto, dv, nDivs, 1)
  else
    Escala125N(v_min_auto, v_max_auto, dv, nDivs, 0);

  if nDivs = 0 then
    nDivs := 1;

  if not flg_ndivs_auto then
    nDivs := nDivs_forzado;

  if flg_min_auto then
    v_min_activo := v_min_auto
  else
    v_min_activo := v_min_forzado;

  if flg_max_auto then
    v_max_activo := v_max_auto
  else
    v_max_activo := v_max_forzado;


  // Si los valores estan muy juntos los separao para que no se rompa por ahí.
  if abs(v_min_activo - v_max_activo) < AsumaCero then
  begin
    v_min_activo := v_min_activo - AsumaCero * 10;
    v_max_activo := v_max_activo + AsumaCero * 10;
  end;


  v0 := v_min_activo;
  dv := (v_max_activo - v_min_activo) / nDivs;

  min_val := v_min_activo;
  max_val := v_max_activo;
end;


procedure TEjeGrafico.Forzar_vmin(v_min: NReal);
begin
  v_min_forzado := v_min;
  flg_min_auto := False;
end;

procedure TEjeGrafico.Forzar_vmax(v_max: NReal);
begin
  v_max_forzado := v_max;
  flg_max_auto := False;
end;

procedure TEjeGrafico.Forzar_ndivs(ndivs: integer);
begin
  ndivs_forzado := ndivs;
  flg_ndivs_auto := False;
end;


procedure TEjeGrafico.Librar_vmin;
begin
  flg_min_auto := True;
end;

procedure TEjeGrafico.Librar_vmax;
begin
  flg_max_auto := True;
end;

procedure TEjeGrafico.Liberar_ndivs;
begin
  flg_ndivs_auto := True;
end;

function TEjeGrafico.label_str(k: integer): string;
var
  s: string;
  x_v: NREal;
begin
  x_v := v0 + k * dv;
  case tipoDato of
    TDE_Fecha: DateTimeToString(s, DateFormatStr, x_v);
    TDE_Entero: s := IntToStr(round(x_v));
    else
      s := FloatToStrF(x_v, FloatFormat, FloatFormat_NDigitos, FloatFormat_NDecimales);
  end;
  Result := s;
end;


procedure TEjeGrafico.Free;
begin
  inherited Free;
end;


(* Métodos de TSerieGrafico *)
constructor TSerieGrafico.Create(nombre: string; xvalores: TDAOfNReal;
  serie_x: TSerieGrafico; grafico: TGrafico = nil; formato_str: string = '';
  flg_SerieX: boolean = False);
begin
  inherited Create;
  self.Nombre := nombre;
  valores := xvalores;
  Self.Serie_x := serie_x;
  self.formato_str := formato_str;
  {$IFDEF SVG_CANVAS}
  self.tipo_pen := psClear;
  {$ENDIF}

  //self.tipo_pen := psClear;

  AnchoLineaMarcador := 2;
  AnchoLinea := 1;
  RadioMarcador := 5;
  if grafico <> nil then
  begin
    colorArea := grafico.ProximoColor;
    colorLinea := colorArea;
    colorFondoMarcador := colorArea;
    colorLineaMarcador := colorArea;
    tipoMarcador := grafico.ProximoMarcador;
    tipoGrafico := grafico.tipoGrafico;
  end
  else
  begin
    colorArea := clBlack;
    colorLinea := clBlack;
    colorFondoMarcador := clBlack;
    colorLineaMarcador := clBlack;
    tipoMarcador := TM_Cruz;
    tipoGrafico := TG_Lineas;
  end;

  if flg_SerieX then
    tipoSerie := TS_SerieX
  else if serie_x = nil then
    tipoSerie := TS_Serie
  else
    tipoSerie := TS_SerieY;

  eje := 0; // por defecto del lado izquiedo.
end;


// al crear la serie se pasa xvalores como TVectR. La serie los copia por lo que
// no se encarga de eliminar el vector xvalores
constructor TSerieGrafico.Create(nombre: string; xvalores: TVectR;
  serie_x: TSerieGrafico; grafico: TGrafico; formato_str: string; flg_SerieX: boolean);
var
  xvals: TDAofNReal;
begin
  xvals := xvalores.toTDAOfNReal;
  Create(nombre, xvals, serie_x, grafico, formato_str, flg_SerieX);
end;

constructor TSerieGrafico.CreateFromSAS(nombre: string; archi: string;
  grafico: TGrafico; formato_str: string; flg_SerieX: boolean; cero: integer);
var
  memento: TStringList;
  l: string;
  res: TStrings;
  k: integer;
  xserie_x: array of NReal;
  val: NReal;
  periodo: integer;
  muestrasXperiodo: int64;
  largo: int64;
  j: integer;
  primerdato: integer;
  idx: integer;
begin
  inherited Create;
  self.Nombre := nombre;
  self.formato_str := formato_str;
{$IFDEF SVG_CANVAS}
  self.tipo_pen := psClear;
{$ENDIF}
  AnchoLineaMarcador := 2;
  AnchoLinea := 1;
  RadioMarcador := 3;
  if grafico <> nil then
  begin
    colorArea := grafico.ProximoColor;
    colorLinea := colorArea;
    colorFondoMarcador := colorArea;
    colorLineaMarcador := colorArea;
    tipoMarcador := grafico.ProximoMarcador;
    tipoGrafico := grafico.tipoGrafico;
  end
  else
  begin
    colorArea := clBlack;
    colorLinea := clBlack;
    colorFondoMarcador := clBlack;
    colorLineaMarcador := clBlack;
    tipoMarcador := TM_Cruz;
    tipoGrafico := TG_Lineas;
  end;

  if flg_SerieX then
    tipoSerie := TS_SerieX
  else if serie_x = nil then
    tipoSerie := TS_Serie
  else
    tipoSerie := TS_SerieY;

  eje := 0; // por defecto del lado izquiedo.

  res := TStringList.Create;
  memento := TStringList.Create;
  memento.LoadFromFile(archi);

  primerdato := 6;
  periodo := 60;
  muestrasXperiodo := trunc(periodo / 10);
  largo := trunc((memento.Count - 6) / muestrasXperiodo);

  SetLength(valores, largo);
  SetLength(xserie_x, largo);


  for k := 0 to largo - 1 do //memento.Count-1 do
  begin
    val := 0;
    for j := 0 to muestrasXperiodo - 1 do
    begin
      idx := primerdato + k * muestrasXperiodo + j;
      l := memento[idx];
      ExtractStrings([#09], [], PChar(l), res);
      val := StrToFloat(res[(idx - primerdato) * 3 + 1]);
      if ((val <> cero) and (val <> -121111) and (val <> -111111)) then
        valores[k] := valores[k] + val;
      if j = 0 then
        xserie_x[k] := StrToFloat(res[(idx - primerdato) * 3]);
      if j = muestrasXperiodo - 1 then
        valores[k] := valores[k] / muestrasXperiodo;
    end;
  end;

  serie_x := Tseriegrafico.Create('fecha', xserie_x, nil, grafico, 'dd/mm/yyyy t', True);

  res.Free;
  memento.Free;

end;

function TSerieGrafico.clone: TSerieGrafico;
begin
  Result := TSerieGrafico.Create(self.nombre, self.valores, self.serie_x,
    nil, self.formato_str, False);
  Result.colorArea := colorArea;
  Result.colorLinea := colorLinea;
  Result.colorFondoMarcador := colorFondoMarcador;
  Result.colorLineaMarcador := colorLineaMarcador;
  Result.tipoMarcador := tipoMarcador;
  Result.tipoGrafico := tipoGrafico;
  tipoSerie := self.tipoSerie;

end;

procedure TSerieGrafico.pintar(color: TColor);
begin
  colorArea := color;
  colorLinea := color;
  colorFondoMarcador := color;
  colorLineaMarcador := color;
end;

function TSerieGrafico.FormatoFecha: boolean;
begin
  Result := (((pos('-', formato_str) + pos('/', formato_str)) > 0) or
    (formato_str = 'c'));
end;

procedure TSerieGrafico.Free;
begin
  //setlength(valores, 0);
  //  if ((Assigned(serie_X)) and (serie_x <> nil) ) then
  //    serie_x.free;
  inherited Free;
end;

procedure TGrafico.ClipRect(var c: TCanvas; x1, y1, x2, y2: integer);

begin
  {$IFNDEF SVG_CANVAS}
  {$IFNDEF FP_CANVAS}
  c.ClipRect := Rect(x1, y1, x2, y2);
  c.Clipping := True;
  {$ENDIF}
  {$ELSE}
  c.ClipRect(x1, y1, x2, y2);
  {$ENDIF}
end;


(* Métodos de TGrafico *)
constructor TGrafico.Create(nombre: string; tipoGrafico: TTipoGrafico;
  k_LogoSimSEE: integer = 0);
begin
  inherited Create;
  self.Nombre := nombre;
  titulo := '';
  eje_x := TEjeGrafico.Create('');
  eje_y := TEjeGrafico.Create('');
  eje_y2 := TEjeGrafico.Create('');
  series_y := TList.Create;
  series_x := TList.Create;
  cajasXY := TList.Create;
  self.tipoGrafico := tipoGrafico;
  nid_ProximoColor := 0;
  nid_ProximoMarcador := 0;
  kEnLibro := -1;
  FontSize := 14;
  self.k_LogoSimSEE := k_logoSimSEE;
end;



procedure TGrafico.AddSerie(NuevaSerie: TSerieGrafico);
begin
  if NuevaSerie.tipoSerie = TS_SerieX then
    series_x.add(NuevaSerie)
  else
  begin
    if (NuevaSerie.tipoGrafico = TG_DispersionXY) and (NuevaSerie.serie_x = nil) then
    begin
      if series_x.Count > 0 then
        NuevaSerie.serie_x := series_x[0];
    end;
    series_y.add(NuevaSerie);
  end;
end;


procedure TGrafico.AddCajaXY(NuevaCajaXY: TCajaGraficoXY);
begin
  cajasXY.add(NuevaCajaXY);
end;

procedure AmpliarRango(var amin, amax: NReal; var cnt_series: integer;
  NuevaSerie: TSerieGrafico);
var
  bmin, bmax: NReal;
begin
  if length(NuevaSerie.valores) = 0 then
    exit;
  bmin := vmin(NuevaSerie.valores);
  bmax := vmax(NuevaSerie.Valores);
  if cnt_series > 0 then
  begin
    if bmin < amin then
      amin := bmin;
    if bmax > amax then
      amax := bmax;
  end
  else
  begin
    amin := bmin;
    amax := bmax;
  end;
  Inc(cnt_series);
end;



function trunc_int(r: extended): integer;
begin
  if r < -MaxSmallint then
    Result := -MaxSmallint
  else if r > MaxSmallint then
    Result := MaxSmallint
  else if IsNan(r) then
    Result := -MaxSmallInt
  else
    Result := trunc(r);
end;

function TGrafico.x2w(x: NReal): integer;
begin
  Result := w0 + trunc_int(mx * (x - min_X) + 0.5);
end;

function TGrafico.y2h(y: NReal): integer;
begin
  Result := h1 - trunc_int(my * (y - min_Y) + 0.5);
end;

function TGrafico.y2h2(y: NReal): integer;
begin
  Result := h1 - trunc_int(my2 * (y - min_Y2) + 0.5);
end;


// Conversión de pixeles a reales para posicionamiento del mouse
function TGrafico.w2x(left: integer): NReal;
begin
  Result := (left - w0) / mx + min_X;
end;

function TGrafico.h2y(top: integer): NReal;
begin
  Result := (h1 - top) / my + min_Y;
end;


procedure TGrafico.plotMarcador(c: TCanvas; x, y: integer;
  tipoMarcador: TTipoMarcador; anchoLinea: integer; RadioMarcador: integer);
var
  rombo: array of TPoint;
  x1, y1, x2, y2: integer;
  old_AnchoLinea: integer;
begin
  old_AnchoLinea := c.Pen.Width;
  c.Pen.Width := anchoLinea;
  x1 := x - RadioMarcador;
  x2 := x + RadioMarcador;
  y1 := y - RadioMarcador;
  y2 := y + RadioMarcador;
  case tipoMarcador of
    TM_Circulo:
      c.Ellipse(x1, y1, x2, y2);
    TM_Cuadro:
      c.Rectangle(x1, y1, x2, y2);
    TM_Rombo:
    begin
      setlength(rombo, 4);
      rombo[0].x := x;
      rombo[0].y := y - RadioMarcador;
      rombo[1].x := x - RadioMarcador;
      rombo[1].y := y;
      rombo[2].x := x;
      rombo[2].y := y + RadioMarcador;
      rombo[3].x := x + RadioMarcador;
      rombo[3].y := y;
      c.Polygon(rombo);
      setlength(rombo, 0);
    end;
    TM_Cruz:
    begin
      c.Line(x1, y, x2, y);
      c.Line(x, y1, x, y2);
    end;

    TM_X:
    begin
      c.Line(x1, y1, x2, y2);
      c.Line(x1, y2, x2, y1);
    end;
  end;
  c.pen.Width := old_AnchoLinea;
end;

procedure TGrafico.plotFillRect(c: TCanvas; x, y: integer; anchoLinea: integer;
  w, h: integer);
var
  x1, y1, x2, y2: integer;
  old_Ancho_linea: integer;
begin
  x1 := x - w div 2;
  x2 := x1 + w;
  y1 := y - h div 2;
  y2 := y + h;
  old_Ancho_linea := c.pen.Width;
  c.pen.Width := anchoLinea;
  c.Rectangle(x1, y1, x2, y2);
  c.FillRect(x1, y1, x2, y2);
  c.pen.Width := old_Ancho_linea;
end;




procedure TGrafico.PlotDispersionXY_marcadores(c: TCanvas; lst_SeriesDispXY: TList);
var
  k, j: integer;
  aSerie, aSerieX: TSerieGrafico;
  x, y: int64;
begin
  aSerie := lst_SeriesDispXY[0];
  for k := 0 to lst_SeriesDispXY.Count - 1 do
  begin
    aSerie := lst_SeriesDispXY[k];
    aSerieX := aSerie.serie_x;
{$IFDEF FP_CANVAS}
    c.Pen.FPColor := aSerie.colorLineaMarcador;
    c.Brush.FPColor := aSerie.colorFondoMarcador;
{$ELSE}
    c.Pen.Color := aSerie.colorLineaMarcador;
    c.Brush.Color := aSerie.colorFondoMarcador;
{$ENDIF}
    c.Pen.Width := 3;
    c.Brush.Style := bsClear;

    for j := 0 to high(aSerie.valores) do
    begin
      x := x2w(aSerieX.valores[j]);
      if aSerie.valores[j] < (-1E9 + 2) then
        x := x;
      if aSerie.eje = 0 then
        y := y2h(aSerie.valores[j])
      else
        y := y2h2(aSerie.valores[j]);
      plotMarcador(c, x, y, aSerie.tipoMarcador, aSerie.AnchoLineaMarcador,
        aSerie.RadioMarcador);
    end;
  end;
end;


procedure TGrafico.PlotDispersionXY(c: TCanvas; lst_SeriesDispXY: TList);
var
  k, j: integer;
  aSerie, aSerieX: TSerieGrafico;
  Points: array of TPoint;
begin
  aSerie := lst_SeriesDispXY[0];
  for k := 0 to lst_SeriesDispXY.Count - 1 do
  begin
    aSerie := lst_SeriesDispXY[k];

    if ( aSerie.colorLinea = clNone ) or ( aSerie.AnchoLinea = 0 ) then
      continue;

    aSerieX := aSerie.serie_x;
{$IFDEF FP_CANVAS}
    c.Pen.FPColor := aSerie.colorLinea;
{$ELSE}
    c.Pen.Color := aSerie.colorLinea;
{$ENDIF}
    c.Pen.Width := aSerie.AnchoLinea;
    {$IFDEF SVG_CANVAS}
    c.pen.Style := aSerie.tipo_pen;
    {$ENDIF}
    //////
    //queda implementado el polyline
    //////
    //x := x2w(aSerieX.valores[0]);
    //if eje = 0 then
    //  y := y2h(aSerie.valores[0])
    //else
    //  y := y2h2(aSerie.valores[0]);
    //c.MoveTo(x, y);

    SetLength(Points, Length(aSerie.valores));

    for j := 0 to high(aSerie.valores) do
    begin
      //  {$IFDEF xSVG_CANVAS}
      Points[j].x := x2w(aSerieX.valores[j]);
      if aSerie.eje = 0 then
        Points[j].y := y2h(aSerie.valores[j])
      else
        Points[j].y := y2h2(aSerie.valores[j]);
      //////
      //QUEDA IMPLEMENTADO el polyline
      //////
      //  {$ELSE}
      //x := x2w(aSerieX.valores[j]);
      //if aSerie.eje = 0 then
      //  y := y2h(aSerie.valores[j])
      //else
      //  y := y2h2(aSerie.valores[j]);
      //c.LineTo(x, y);
      //{$ENDIF}
    end;
    //{$IFDEF xSVG_CANVAS}
    c.Polyline(Points);
    //{$ENDIF}
  end;
end;

procedure TGrafico.PlotBarras(c: TCanvas; lst_SeriesBarras: TList);

var
  xy: NReal;
  yini, xini, yfin, xfin, hspace, kSerie, k, NP, anchoBarra, nSeries: integer;
  aSerie: TSerieGrafico;
  //poligono: array of TPoint;
begin

  nSeries := lst_SeriesBarras.Count;
  Yini := y2h(0);
  aSerie := lst_SeriesBarras[0];
  anchoBarra := trunc((w1 - w0) / nSeries / length(aSerie.valores) * 0.9);
  hspace := trunc(anchoBarra * 0.9 / 10);

  for kSerie := 0 to nSeries - 1 do
  begin
    xfin := w0 + (kSerie + 1 - nSeries) * anchoBarra + 2 * hspace;
    aSerie := lst_SeriesBarras[kSerie];
{$IFDEF FP_CANVAS}
    c.Brush.FPColor := aSerie.colorArea;
{$ELSE}
    c.Brush.color := aSerie.colorArea;
{$ENDIF}
    eje_x.flg_etiquetaX := False;
    NP := length(aSerie.valores);
    SetLength(xinis, NP);
    SetLength(xfins, NP);

    for k := 0 to NP - 1 do      //si pongo otro -1 no plotea demanda
    begin
      {$IFDEF FP_CANVAS}
      c.Brush.FPColor := aSerie.colorArea;
      {$ELSE}
      c.Brush.color := aSerie.colorArea;
      {$ENDIF}
      xy := aSerie.valores[k];
      yfin := y2h(xy);
      xini := xfin + hspace + (nSeries - 1) * anchoBarra;
      //el inicio es donde termina la serie
      //+ el ancho de todas las barras + una separación (se podría agregar offset luego tambien)
      xfin := xini + anchoBarra;
      c.Rectangle(xini, {yini}yfin, xfin, {yfin}yini);
      xinis[k] := trunc((xini + xfin) / 2);
      //xfins[k] := xfin;

    end;
  end;
  c.Font.Orientation := 0;
end;

procedure TGrafico.PlotBarrasApiladas(c: TCanvas; lst_SeriesBApiladas: TList);
var
  xy: NReal;
  yini, xini, yfin, xfin, hval, kSerie, k, NP: integer;
  aSerie: TSerieGrafico;
begin

  c.Pen.Width := 2;
  c.Font.Orientation := 0;

  for kSerie := 0 to 0{nSeries - 1} do
  begin
    Yfin := y2h(0);
    Xini := w0 + 1;
    Xfin := w1;
    aSerie := lst_SeriesBApiladas[kSerie];
    eje_x.flg_etiquetaX := False;
    NP := length(aSerie.valores);
    SetLength(ymean, NP);
    {$IFDEF FP_CANVAS}
    c.Brush.FPcolor := aSerie.colorFondoMarcador;//ProximoColor;
    {$ELSE}
    c.Brush.color := aSerie.colorFondoMarcador;//ProximoColor;
    {$ENDIF}


    for k := 0 to NP - 1 do
    begin
      xy := aSerie.valores[k];
      if (xy > 1) then
      begin
        yini := yfin;
        hval := h1 - yfin;
        yfin := y2h(xy) - hval;
        c.Rectangle(xini, {yini}yfin, xfin, {yfin}yini);
        ymean[k] := trunc((yfin + yini) / 2);
      end;
      {$IFDEF FP_CANVAS}
      c.Brush.FPcolor := ProximoColor;
      {$ELSE}
      c.Brush.color := ProximoColor;
      {$ENDIF}
    end;
  end;
end;


procedure TGrafico.PlotAreasApiladas(c: TCanvas; lst_SeriesAreasApiladas: TList);
var
  kSerie: integer;
  k: integer;
  vinf, vsup: TDAOfNreal;
  poligono: array of TPoint;
  aSerieX, aSerie: TSerieGrafico;
  vx, vy: NReal;
  NP: integer;
  NPM1: integer;
  eje: integer;

begin
  aSerie := lst_SeriesAreasApiladas[0];
  eje := aSerie.eje;
  aSerieX := aSerie.serie_x;
  NP := length(aSerie.valores);
  NPM1 := NP - 1;

  setlength(vinf, NP);
  setlength(vsup, NP);
  setlength(poligono, 2 * NP);

  vclear(vinf);
  for k := 0 to NPM1 do
    vsup[k] := aSerie.valores[k];

  kSerie := 0;
  repeat
    {$IFDEF FP_CANVAS}
    c.Brush.FPcolor := aSerie.colorArea;
    {$ELSE}
    c.Brush.color := aSerie.colorArea;
    {$ENDIF}


    for k := 0 to NPM1 do
    begin
      vx := aSerieX.valores[k];
      vy := vsup[k];
      poligono[k].x := x2w(vx);
      if eje = 0 then
        poligono[k].y := y2h(vy)
      else
        poligono[k].y := y2h2(vy);
    end;
    for k := 0 to NPM1 do
    begin
      vx := aSerieX.valores[NPM1 - k];
      vy := vinf[NPM1 - k];
      poligono[k + NP].x := x2w(vx);
      if eje = 0 then
        poligono[k + NP].y := y2h(vy)
      else
        poligono[k + NP].y := y2h(vy);

    end;


    c.Polygon(poligono); // no compliquemos , True);

    Inc(kSerie);
    if kSerie < lst_SeriesAreasApiladas.Count then
    begin
      aSerie := lst_SeriesAreasApiladas[kSerie];
      vswap(vsup, vinf);

      for k := 0 to NPM1 do
        vsup[k] := vinf[k] + aSerie.valores[k];
    end;

  until kSerie >= lst_SeriesAreasApiladas.Count;

  setlength(vsup, 0);
  setlength(vinf, 0);
  setlength(poligono, 0);

end;

procedure AmpliarRangoBApiladas(var min_Y, max_Y: NReal;
  var cnt_seriesConsideradas: integer; lst_SeriesAA: TList);
var
  aSerie: TSerieGrafico;
  k: integer;
  m: NReal;
  N: integer;
  VectorSerie: TVectR;
begin
  aSerie := lst_SeriesAA[0];
  N := length(aSerie.valores);
  max_Y := 100;
  min_Y := 0;

  Inc(cnt_seriesConsideradas);

  for k := 0 to lst_SeriesAA.Count - 1 do
  begin
    aSerie := lst_SeriesAA[k];
    VectorSerie := TVectR.Create_FromDAofR(aSerie.valores, 0);
    m := VectorSerie.normEuclid;
    if not EsCero(m / n) then
      VectorSerie.PorReal(100 / m);

  end;

end;


procedure AmpliarRangoApiladas(var min_Y, max_Y: NReal;
  var cnt_seriesConsideradas: integer; lst_SeriesAA: TList);
var
  vsup: TDAOfNReal;
  aSerie: TSerieGrafico;
  k, j: integer;
  N: integer;
begin
  aSerie := lst_SeriesAA[0];
  N := length(aSerie.valores);

  setlength(vsup, N);
  vclear(vsup);

  if cnt_seriesConsideradas = 0 then
  begin
    min_Y := 0;
    max_Y := 0;
  end;
  Inc(cnt_seriesConsideradas);

  for k := 0 to lst_SeriesAA.Count - 1 do
  begin
    aSerie := lst_SeriesAA[k];
    for j := 0 to high(vsup) do
    begin
      vsup[j] := vsup[j] + aSerie.valores[j];
      if vsup[j] < min_Y then
        min_Y := vsup[j]
      else if vsup[j] > max_Y then
        max_Y := vsup[j];
    end;
  end;

end;


function TGrafico.calc_ylabel_ancho(c: TCanvas): integer;
var
  k: integer;
  res: integer;
  m: integer;
  s: string;
begin
  res := 0;
  for k := 0 to Eje_y.nDivs do
  begin
    s := eje_y.label_str(k);
    m := c.TextWidth(s);
    if m > res then
      res := m;
  end;
  Result := res;
end;

function TGrafico.calc_y2label_ancho(c: TCanvas): integer;
var
  k: integer;
  res: integer;
  m: integer;
  s: string;
begin
  res := 0;
  for k := 0 to Eje_y2.nDivs do
  begin
    s := eje_y2.label_str(k);
    m := c.TextWidth(s);
    if m > res then
      res := m;
  end;
  Result := res;
end;

function TGrafico.calc_xlabel_alto(c: TCanvas): integer;
var
  k: integer;
  res: integer;
  m: integer;
  s: string;
begin
  res := 0;
  for k := 0 to eje_x.nDivs do
  begin
    s := eje_x.label_str(k);
    m := c.TextWidth(s);
    if m > res then
      res := m;
  end;
  Result := res;
end;


procedure SumSiPos(var largo: integer; ancho, tag: integer);
begin
  if ancho > 0 then
    largo := largo + ancho + tag;
end;


procedure draw_logo_simsee(c: TCanvas; left, top: integer);
var
  h, g: integer;
  clAnt: TColor;

begin
{$IFDEF FP_CANVAS}
  clAnt := c.Pen.FPColor;
  c.Brush.FPColor := RGBToColor($FF, $D3, $20);
  c.Pen.FPcolor := c.Brush.FPColor;
{$ELSE}
  clAnt := c.Pen.Color;
  c.Brush.Color := RGBToColor($FF, $D3, $20);
  c.Pen.color := c.Brush.Color;
{$ENDIF}
  h := c.TextHeight('S') div 2;
  g := c.TextWidth('.') div 2;
  top := top + h + h div 2;

  c.FillRect(left, top - 2 * h - 2 * g, left + h, top - h - 2 * g);

{$IFDEF FP_CANVAS}
  c.Brush.FPColor := RGBToColor($83, $CA, $FE);
  c.Pen.FPcolor := c.Brush.FPColor;
{$ELSE}
  c.Brush.Color := RGBToColor($83, $CA, $FE);
  c.Pen.color := c.Brush.Color;
  {$ENDIF}
  c.FillRect(left + h + g, top - 2 * h - 2 * g, left + h + h + g, top - h - 2 * g);

  {$IFDEF FP_CANVAS}
  c.Brush.FPColor := RGBToColor($99, $65, $00);
  c.Pen.FPcolor := c.Brush.FPColor;
  {$ELSE}
  c.Brush.Color := RGBToColor($99, $65, $00);
  c.Pen.color := c.Brush.Color;
  {$ENDIF}

  c.FillRect(left + h + g, top - h - g, left + h + h + g, top - g);

  {$IFDEF FP_CANVAS}
  c.Brush.FPColor := RGBToColor($65, $CC, $00);
  c.Pen.FPcolor := c.Brush.FPColor;
  {$ELSE}
  c.Brush.Color := RGBToColor($65, $CC, $00);
  c.Pen.color := c.Brush.Color;
  {$ENDIF}


  c.FillRect(left, top - h - g, left + h, top - g);
  {$IFDEF FP_CANVAS}
  c.Brush.FPColor := clNone;
  {$ELSE}
  c.Brush.Color := clNone;
  {$ENDIF}

  c.TextOut(left + h + g + h + g, top - h, 'SimSEE');
  {$IFDEF FP_CANVAS}
  c.Pen.FPColor := clAnt;
  {$ELSE}
  c.Pen.color := clAnt;
  {$ENDIF}

end;

procedure TGrafico.Draw(c: TCanvas; ancho, alto: integer);
var
  w, h: integer;
  x, y: integer;
  x_v, y_v: NReal;

  NSeries_X: integer;
  NSeries_Y: integer;
  NSeries_XY: integer;
  k, j: integer;
  aSerie: TSerieGrafico;
  cnt_series_rango: integer;
  cnt_series_rango2: integer;
  LargoSeries_noxy: integer; // cantidad de elementos de la serie más larga que no es xy

  // Listas para ordenar el dibujo
  lst_barras_1, lst_barras_2, lst_lineas_1, lst_lineas_2, lst_dispXY_1,
  lst_dispXY_2, lst_AApiladas_1, lst_AApiladas_2, lst_BApiladas_1,
  lst_BApiladas_2: TList;

  s: string;
  dw_s, dh_s: integer;

  anch: integer;

  maxRadioMarcador: integer;
  dt_paso_x: NReal;




  function calc_ylabel_ancho(aEje_y: TEjeGrafico): integer;
  var
    k: integer;
    res: integer;
    m: integer;
  begin
    res := 0;
    for k := 0 to aEje_y.nDivs do
    begin
      s := aEje_y.label_str(k);
      m := c.TextHeight(s);
      if m > res then
        res := m;
    end;
    Result := res;
  end;


  function calc_xlabel_alto: integer;
  var
    k: integer;
    res: integer;
    m: integer;
  begin
    res := 0;
    for k := 0 to eje_x.nDivs do
    begin
      s := eje_x.label_str(k);
      m := c.TextWidth(s);
      if m > res then
        res := m;
    end;
    Result := res;
  end;

begin
  lst_barras_1 := TList.Create;
  lst_barras_2 := TList.Create;
  lst_lineas_1 := TList.Create;
  lst_lineas_2 := TList.Create;
  lst_dispXY_1 := TList.Create;
  lst_dispXY_2 := TList.Create;
  lst_AApiladas_1 := TList.Create;
  lst_AApiladas_2 := TList.Create;
  lst_BApiladas_1 := TList.Create;
  lst_BApiladas_2 := TList.Create;

  NSeries_XY := 0;
  largoSeries_noxy := 0;

  NSeries_X := series_x.Count;
  if NSeries_X > 0 then
  begin
    cnt_series_rango := 0;

    aSerie := series_X[0];
    min_X := vmin(aSerie.valores);
    max_X := vmax(aSerie.valores);
    for k := 1 to NSeries_X - 1 do
    begin
      aSerie := series_X[k];
      AmpliarRango(min_X, max_X, cnt_series_rango, aSerie);
    end;

    if aSerie.FormatoFecha then
    begin
      eje_x.tipoDato := TDE_Fecha;
      eje_x.DateFormatStr := trim(aSerie.formato_str);
      dt_paso_x := (max_x - min_x) / 12; // Divido entre 12 solo para
      // tener una idea de la precisión que vale tener en las etiquetas del gráfico
      if eje_x.DateFormatStr = '' then
      begin   //mmmm alguien no hizo las cosas bien ... intento arreglarlo
        eje_x.DateFormatStr := SysUtils.FormatSettings.ShortDateFormat;
        // SysUtils.ShortDateFormat;
        if dt_paso_x < 1 then
          eje_x.DateFormatStr := eje_x.DateFormatStr + ' hh';
        dt_paso_x := dt_paso_x * 24;
        if dt_paso_x < 1 then
          eje_x.DateFormatStr := eje_x.DateFormatStr + ':mm';
        dt_paso_x := dt_paso_x * 60;
        if dt_paso_x < 1 then
          eje_x.DateFormatStr := eje_x.DateFormatStr + ':ss';
      end;
    end;
  end;

  cnt_series_rango := 0;
  cnt_series_rango2 := 0;

  NSeries_Y := series_y.Count;
  if NSeries_Y > 0 then
  begin
    for k := 0 to NSeries_Y - 1 do
    begin
      aSerie := series_y[k];
      if aSerie.serie_x <> nil then
        Inc(NSeries_XY)
      else
      begin
        if length(aSerie.valores) > LargoSeries_noxy then
          LargoSeries_noxy := length(aSerie.valores);
      end;
      if aSerie.eje = 0 then
      begin
        if aSerie.tipoGrafico <> TG_AreasApiladas then
          AmpliarRango(min_Y, max_Y, cnt_series_rango, aSerie);
        case aSerie.tipoGrafico of
          TG_Lineas: lst_lineas_1.add(aSerie);
          TG_AreasApiladas: lst_AApiladas_1.add(aSerie);
          TG_Barras: lst_barras_1.add(aSerie);
          TG_DispersionXY: lst_dispXY_1.add(aSerie);
          TG_BarrasApiladas: lst_BApiladas_1.add(aSerie);
        end;
      end
      else
      begin
        if aSerie.tipoGrafico <> TG_AreasApiladas then
          AmpliarRango(min_Y2, max_Y2, cnt_series_rango2, aSerie);
        case aSerie.tipoGrafico of
          TG_Lineas: lst_lineas_2.add(aSerie);
          TG_AreasApiladas: lst_AApiladas_2.add(aSerie);
          TG_Barras: lst_barras_2.add(aSerie);
          TG_DispersionXY: lst_dispXY_2.add(aSerie);
          TG_BarrasApiladas: lst_BApiladas_2.add(aSerie);
        end;
      end;
    end;
  end;


  // ahora si hay areas o barras apiladas recalculamos los rangos
  if lst_AApiladas_1.Count > 0 then
    AmpliarRangoApiladas(min_Y, max_Y, cnt_series_rango, lst_AApiladas_1);

  if lst_AApiladas_2.Count > 0 then
    AmpliarRangoApiladas(min_Y2, max_Y2, cnt_series_rango2, lst_AApiladas_2);

  if lst_BApiladas_1.Count > 0 then
    //  AmpliarRangoApiladas(min_Y2, max_Y2, cnt_series_rango2, lst_BApiladas_1);
    max_Y := 100;

  if lst_BApiladas_2.Count > 0 then
    max_Y := 100;
  //     AmpliarRangoApiladas(min_Y2, max_Y2, cnt_series_rango2, lst_BApiladas_2);

(*
  if eje_x.tipoDato = TDE_Fecha then
  begin
    if min_x < ( 0.99 * max_x ) then
    begin
      eje_x.Forzar_vmin(min_x);
      eje_x.Forzar_vmax(max_x);
    end
    else
    begin
     eje_x.Forzar_vmin(min_x);
     eje_x.Forzar_vmax(max_x);
    end;
  end;

  *)
  eje_x.Calcular(min_x, max_x);

  eje_y.Calcular(min_y, max_y);
  eje_y2.Calcular(min_y2, max_y2);


  c.Font.Orientation := 0;
  c.Font.Size := FontSize;

  tag_w := c.TextHeight('M') div 2;
  tag_h := c.TextHeight('M') div 2;
  if self.Titulo <> '' then
    dh_TItuloGrafico := c.TextHeight('M')
  else
    dh_TituloGrafico := 0;

  if self.eje_x.titulo <> '' then
    dh_TItuloX := c.TextHeight('M')
  else
    dh_TituloX := 0;

  if self.eje_y2.titulo <> '' then
    dw_TItuloY2 := c.TextHeight('M')
  else
    dw_TItuloY2 := 0;

  if self.eje_y.titulo <> '' then
    dw_TItuloY := c.TextHeight('M')
  else
    dw_TItuloY := 0;

  dh_EscalaX := calc_xlabel_alto;
  c.Font.Orientation := 0;
  dw_EtiquetasSeries := 0;
  dw_EtiquetaTipoGen := 0;
  maxRadioMarcador := 0;
  for k := 0 to NSeries_Y - 1 do
  begin
    aSerie := series_y[k];
    if aSerie.RadioMarcador > maxRadioMarcador then
      maxRadioMarcador := aSerie.RadioMarcador;
    dw_EtiquetasSeries := max(dw_EtiquetasSeries, c.TextWidth(aSerie.nombre));
    if aSerie.tipoGrafico = TG_BarrasApiladas then
    begin
      for j := 0 to Length(aSerie.nombreValores) - 1 do
        dw_EtiquetaTipoGen :=
          max(dw_EtiquetaTipoGen, c.TextWidth(aSerie.nombreValores[j]));

      dh_EscalaX := 0;         //si es de barras apiladas lo quiero más abajo
    end;
  end;

  dh_Etiqueta := c.TextHeight('M');
  dh_Etiqueta := trunc(max(dh_Etiqueta, maxRadioMarcador) * 1.1 + 0.5);
  tag_Etiqueta := 2;

  if cnt_series_rango > 0 then
    dw_EscalaY := self.calc_ylabel_ancho(c)
  else
    dw_EscalaY := 0;

  if cnt_series_rango2 > 0 then
    dw_EscalaY2 := calc_y2label_ancho(c)
  else
    dw_EscalaY2 := 0;


  w := ancho;
  h := alto;

  // Borde izquierdo
  w0 := tag_w;
  sumSiPos(w0, dw_TituloY, tag_w);
  sumSiPos(w0, dw_EscalaY, tag_w);

  // Borde derecho
  w1 := tag_w;
  SumSiPos(w1, dw_EtiquetasSeries, tag_w);
  SumSiPos(w1, dw_EscalaY2, tag_w);
  SumSiPos(w1, maxRadioMarcador * 2, tag_w);
  SumSiPos(w1, dw_EtiquetaTipoGen, c.TextWidth('## %'));
  w1 := w - w1;

  // Borde superior
  h0 := tag_h;
  SumSiPos(h0, dh_TItuloGrafico, tag_h);

  // Borde inferior
  h1 := tag_h;
  SumSiPos(h1, dh_TItuloX, tag_h);
  SumSiPos(h1, dh_EscalaX, tag_h);
  h1 := h - h1;

  mx := (w1 - w0) / (max_x - min_x);
  if cnt_series_rango > 0 then
    my := (h1 - h0) / (max_y - min_y);

  if cnt_series_rango2 > 0 then
    my2 := (h1 - h0) / (max_y2 - min_y2);

  // borramos
{$IFDEF FP_CANVAS}
  c.Brush.FPColor := clWhite;
{$ELSE}
  c.Brush.Color := clWhite;
{$ENDIF}
  c.FillRect(0, 0, w - 1, h - 1);

  // Caja Grafico XY
  c.Pen.Style := psSolid;
  {$IFDEF FP_CANVAS}
  c.Pen.FPColor := clBlack;
  {$ELSE}
  c.Pen.Color := clBlack;
  {$ENDIF}

  c.Rectangle(w0, h0, w1, h1);



  // Título Superior
  anch := c.Font.Size * length(Titulo);
  x := trunc((w1 + w0) / 2.0 - anch / 2.0);
  c.TextOut(x, tag_h, titulo);

  // Etiquetas de las series en el lateral derecho
  x := w - tag_w - dw_EtiquetasSeries;
  y := h0 + tag_h;
  for k := 0 to NSeries_Y - 1 do
  begin
    aSerie := series_y[k];
    {$IFDEF FP_CANVAS}
    c.Pen.FPColor := aSerie.colorLineaMarcador;
    c.Brush.FPColor := aSerie.colorFondoMarcador;
    {$ELSE}
    c.Pen.Color := aSerie.colorLineaMarcador;
    c.Brush.Color := aSerie.colorFondoMarcador;
    {$ENDIF}
    c.Pen.Width := 3;

    if aSerie.tipoGrafico in [TG_Lineas, TG_DispersionXY] then
    begin
      c.Brush.Style := bsClear;
      plotMarcador(c, x - aSerie.RadioMarcador - tag_w,
        trunc(y + k * dh_Etiqueta + dh_Etiqueta / 2 + 0.5),
        aSerie.tipoMarcador, 3, aSerie.RadioMarcador);
    end
    else
    begin
      {$IFDEF FP_CANVAS}
      c.Pen.FPColor := clWhite;
      {$ELSE}
      c.Pen.Color := clWhite;
      {$ENDIF}

      c.Brush.Style := bsSolid;
      plotFillRect(c, x - aSerie.RadioMarcador - tag_w,
        trunc(y + k * dh_Etiqueta + dh_Etiqueta / 2 + 0.5),
        2, 2 * maxRadioMarcador, dh_Etiqueta - maxRadioMarcador);
      c.Brush.Style := bsClear;
    end;

    {$IFDEF FP_CANVAS}
    c.Pen.FPColor := clBlack;
    {$ELSE}
    c.Pen.Color := clBlack;
    {$ENDIF}
    c.TextOut(x, trunc(y + k * dh_Etiqueta
    {$IFDEF SVG_CANVAS}
      + dh_Etiqueta / 2 + 0.5
    {$ENDIF}
      )
      , aSerie.nombre);
  end;


  // Fijamos el rectángulo visible al área XY
  ClipRect(c, w0, h0, w1, h1);

  // Plot AreasApiladas
  c.Pen.Width := 2;
  if lst_AApiladas_1.Count > 0 then
    PlotAreasApiladas(c, lst_AApiladas_1);
  if lst_AApiladas_2.Count > 0 then
    PlotAreasApiladas(c, lst_AApiladas_2);

  c.Pen.Width := 3;
  // Plot DispersiónXY
  if lst_dispXY_1.Count > 0 then
  begin
    PlotDispersionXY(c, lst_dispXY_1);
    PlotDispersionXY_marcadores(c, lst_dispXY_1);
  end;
  if lst_dispXY_2.Count > 0 then
  begin
    PlotDispersionXY(c, lst_dispXY_2);
    PlotDispersionXY_marcadores(c, lst_dispXY_2);
  end;

  // Plot Barras
  c.Pen.Width := 1;
  if lst_barras_1.Count > 0 then
    PlotBarras(c, lst_barras_1);

  if lst_barras_2.Count > 0 then
    PlotBarras(c, lst_barras_2);

  if (lst_barras_1.Count > 0) or (lst_barras_1.Count > 0) then
  begin
    // Grillas de Plot Barras//
    c.Font.Orientation := 3150;
    {$IFDEF FP_CANVAS}
    c.Brush.FPColor := clWhite;
    {$ELSE}
    c.Brush.Color := clWhite;
    {$ENDIF}

    ClipRect(c, 0, 0, w, h);
    (*mvarela@07/04/16
    c.ClipRect := Rect(0, 0, w, h);
    c.Clipping := True;
    *)
    for k := 0 to Length(xinis) - 1 do
      c.TextOut(xinis[k], h1 + 20, (aSerie.nombreValores[k]));
    c.Font.Orientation := 0;
    SetLength(xinis, 0);
    SetLength(xfins, 0);
    c.Font.Orientation := 0;
  end;


  // Plot Barras Apiladas
  ClipRect(c, w0, h0, w1, h1);
  c.Pen.Width := 1;
  if lst_BApiladas_1.Count > 0 then
    PlotBarrasApiladas(c, lst_BApiladas_1);
  if lst_BApiladas_2.Count > 0 then
    PlotBarrasApiladas(c, lst_BApiladas_2);

  k := lst_BApiladas_1.Count;
  if (lst_BApiladas_1.Count > 0) or (lst_BApiladas_2.Count > 0) then
  begin
    // Grillas de Plot Barras Apiladas//
    c.Font.Orientation := 0;
    {$IFDEF FP_CANVAS}
    c.Brush.FPColor := clwhite;
    c.Pen.FPColor := clBlack;
    {$ELSE}
    c.Brush.Color := clwhite;
    c.Pen.Color := clBlack;
    {$ENDIF}


    ClipRect(c, 0, 0, w, h);

    (*mvarela@07/04/16
    c.ClipRect := Rect(0, 0, w, h);
    c.Clipping := True;
    *)
    for k := 0 to Length(Ymean) - 1 - 1 do
      //el ultimo es pa que no aparesca demanda hay q hacerlo generico luego
    begin
      if (aSerie.valores[k] > 1) then
        c.TextOut(w1 + tag_w, Ymean[k],
          (aSerie.nombreValores[k] + ' ' + FloatToStr(round(aSerie.valores[k])) + ' %'));
    end;
    c.Font.Orientation := 0;
    SetLength(xinis, 0);
    SetLength(xfins, 0);
  end;

  // GRILLAS
  ClipRect(c, 0, 0, w, h);
  (*mvarela@07/04/16
  c.ClipRect := Rect(0, 0, w, h);
  c.Clipping := True;
  *)
  c.Pen.Width := 1;
  {$IFDEF FP_CANVAS}
  c.Pen.FPColor := clBlack;
  c.Brush.FPColor := clWhite;
  {$ELSE}
  c.Pen.Color := clBlack;
  c.Brush.Color := clWhite;
  {$ENDIF}

  c.Pen.Style := psSolid;
  c.Brush.Style := bsSolid;

  if eje_x.flg_etiquetaX then
  begin
    c.Font.Orientation := 900;
    // Etiquetas X
    {$IFNDEF SVG_CANVAS}
    dw_s := c.TextHeight('1') div 2;
    {$ELSE}
    dw_s := 0;
    {$ENDIF}
    for k := 0 to eje_x.nDivs do
    begin
      x_v := Eje_x.v0 + k * eje_x.dv;
      x := x2w(x_v);
      s := eje_x.label_str(k);
      c.TextOut(x - dw_s, h1 + tag_h + c.TextWidth(s), s);
    end;
  end;


  c.Font.Orientation := 0;

  // Etiquetas Y
  {$IFNDEF SVG_CANVAS}
  dh_s := c.TextHeight('1') div 2;
  {$ELSE}
  dh_s := 0;
  {$ENDIF}
  for k := 0 to eje_y.nDivs do
  begin
    s := eje_y.label_str(k);
    y_v := Eje_y.v0 + k * eje_y.dv;
    y := y2h(y_v);
    c.TextOut(w0 - tag_w - c.TextWidth(s), y - dh_s, s);
  end;

  // Etiquetas Y2
  if cnt_series_rango2 > 0 then
  begin
   {$IFNDEF SVG_CANVAS}
    dh_s := c.TextHeight('1') div 2;
   {$ELSE}
    dh_s := 0;
   {$ENDIF}
    for k := 0 to eje_y2.nDivs do
    begin
      s := eje_y2.label_str(k);
      y_v := Eje_y2.v0 + k * eje_y2.dv;
      y := y2h2(y_v);
      c.TextOut(w1 + tag_w, y - dh_s, s);
    end;
    {$IFDEF FP_CANVAS}
    c.Pen.FPColor := clRed;
    {$ELSE}
    c.Pen.Color := clRed;
    {$ENDIF}
    c.Pen.Style := psDot;
    for k := 0 to eje_y2.nDivs do
    begin
      y_v := Eje_y2.v0 + k * eje_y2.dv;
      y := y2h2(y_v);
      c.Line(w1 - 20, y, w1, y);
    end;
  end;

  // Título del eje X
  if eje_x.titulo <> '' then
  begin
    {$IFDEF FP_CANVAS}
    c.Pen.FPColor := clBlack;
    {$ELSE}
    c.Pen.Color := clBlack;
    {$ENDIF}
    c.Font.Orientation := 0;
    x := c.TextWidth(eje_x.titulo);
    c.TextOut(trunc((w - x) / 2), h - tag_h - dh_TItuloX, eje_x.titulo);
  end;

  // Titulo del eje Y
  if eje_y.titulo <> '' then
  begin
    {$IFDEF FP_CANVAS}
    c.Pen.FPColor := clBlack;
    {$ELSE}
    c.Pen.Color := clBlack;
    {$ENDIF}
    c.Font.Orientation := 900;
    y := c.TextWidth(eje_y.titulo);
    c.TextOut(tag_w, trunc((h0 + h1) / 2 + y / 2), eje_y.titulo);
  end;

  // Titulo del eje Y2
  if eje_y2.titulo <> '' then
  begin
    {$IFDEF FP_CANVAS}
    c.Pen.FPColor := clBlack;
    {$ELSE}
    c.Pen.Color := clBlack;
    {$ENDIF}
    c.Font.Orientation := 900;
    y := c.TextWidth(eje_y2.titulo);
    c.TextOut(w1 + dw_EscalaY2 + 3 * tag_w, trunc((h0 + h1) / 2 + y / 2), eje_y2.titulo);
  end;

  c.Font.Orientation := 0;
  {$IFDEF FP_CANVAS}
  c.Pen.FPColor := clGray;
  {$ELSE}
  c.Pen.Color := clGray;
  {$ENDIF}

  c.Pen.Style := psDot;

  // GridX
  if eje_X.flg_mostrar_lineas then
    for k := 0 to eje_x.nDivs do
    begin
      x_v := Eje_x.v0 + k * eje_x.dv;
      x := x2w(x_v);
      c.MoveTo(x, h1);
      c.LineTo(x, h0);
    end;


  // Grid_y
  if eje_X.flg_mostrar_lineas then
    for k := 1 to eje_y.nDivs - 1 do
    begin
      y_v := Eje_y.v0 + k * eje_y.dv;
      y := y2h(y_v);
      c.MoveTo(w0, y);
      c.LineTo(w1, y);
    end;


  for k := 0 to cajasXY.Count - 1 do
    TCajaGraficoXY(cajasXY.Items[k]).Draw(c, self);


  if k_LogoSimSEE >= 0 then
  begin
    c.Font.Size := 8;
    draw_logo_simsee(c, w1 - c.TextWidth('_ZZ_SimSEE__') - maxRadioMarcador * 2 - tag_w,
      h0 - c.TextHeight('S') div 2);
  end;

  if lst_barras_1 <> nil then
    lst_barras_1.Free;
  if lst_barras_2 <> nil then
    lst_barras_2.Free;
  if lst_lineas_1 <> nil then
    lst_lineas_1.Free;
  if lst_lineas_2 <> nil then
    lst_lineas_2.Free;
  if lst_dispXY_1 <> nil then
    lst_dispXY_1.Free;
  if lst_dispXY_2 <> nil then
    lst_dispXY_2.Free;
  if lst_AApiladas_1 <> nil then
    lst_AApiladas_1.Free;
  if lst_AApiladas_2 <> nil then
    lst_AApiladas_2.Free;
  if lst_BApiladas_1 <> nil then
    lst_BApiladas_1.Free;
  if lst_BApiladas_2 <> nil then
    lst_BApiladas_2.Free;
end;

function TGrafico.ProximoColor: TColor;
begin
  Result := TColoresPaleta[TkColorPaleta(nid_ProximoColor)];
  nid_ProximoColor := (nid_ProximoColor + 1) mod (High(TkColorPaleta) + 1);
end;

function TGrafico.ProximoMarcador: TTipoMarcador;
begin
  Result := TTipoMarcador(nid_ProximoMarcador);
  nid_ProximoMarcador := (nid_ProximoMarcador + 1) mod (Ord(High(TTipoMarcador)) + 1);
end;


{$IFDEF SVG_CANVAS}
procedure TGrafico.SaveSVG(archi: string; ancho, alto: integer);
var
  c: TSVGCanvas;
begin
  c := TSVGCanvas.Create(ancho, alto);
  Draw(c, ancho, alto);
  c.WriteToArchi(archi);
  c.Free;
end;

{$ENDIF}


{$IFNDEF SVG_CANVAS}
{$IFDEF FP_CANVAS}
procedure TGrafico.SaveJPG(archi: string; ancho, alto: integer;
  Calidad: TFPJPEGCompressionQuality = 100);
var
  canvas: TFPImageCanvas;
  image: TFPCustomImage;
  writer: TFPCustomImageWriter;
  AFont: TFreeTypeFont;

begin
  ftfont.InitEngine;
  FontMgr.SearchPath := ExtractFilePath(ParamStr(0));
  AFont := TFreeTypeFont.Create;

  image := TFPMemoryImage.Create(ancho, alto);
  Canvas := TFPImageCanvas.Create(image);

  Canvas.Font := AFont;
  Canvas.Font.Name := 'mifont';
  Canvas.Font.Size := 20;


  //  Writer := TFPWriterPNG.Create;
  Writer := TFPWriterJPEG.Create;

  { Set the pen styles }
  with canvas do
  begin
    pen.mode := pmCopy;
    pen.style := psSolid;
    pen.Width := 1;
    pen.FPColor := clBlack;
    brush.FPColor:= clWhite;
  end;

  Draw(Canvas, ancho, alto);


  { Save to file }
  image.SaveToFile(archi, writer);

  { Clean up! }
  AFont.Free;
  Canvas.Free;
  image.Free;
  writer.Free;

end;

{$ELSE}
procedure TGrafico.SaveJPG(archi: string; ancho, alto: integer;
  Calidad: TFPJPEGCompressionQuality = 100);
var
  jp: TJPEGImage;  //Requires the "jpeg" unit added to "uses" clause.
  b: TBitmap;
begin
  b := TBitmap.Create;
  b.Width := ancho;
  b.Height := alto;
  Draw(b.Canvas, ancho, alto);
  jp := TJPEGImage.Create;
  jp.CompressionQuality := Calidad;
  try
    jp.Assign(b);
    jp.SaveToFile(archi);
  finally
    jp.Free;
  end;
  b.Free;
end;

{$ENDIF}

{$ELSE}
procedure TGrafico.SaveJPG(archi: string; ancho, alto: integer;
  Calidad: TFPJPEGCompressionQuality = 100);
var
  c: TSVGCanvas;
begin
  c := TSVGCanvas.Create(ancho, alto);
  Draw(c, ancho, alto);
  c.writeToArchi(archi);
  c.Free;
end;

{$ENDIF}

function TGrafico.toJSON(elemento: string): string;
var
  NseriesX: integer;
  NseriesY: integer;
  grafico: TJSONObject;
  xkeys: TJSONArray;
  ykeys: TJSONArray;
  labels: TJSONArray;
  Data: TJSONArray;
  punto: TJSONObject;
  k: integer;
  j: integer;
  i: integer;
  largo: integer;
  _serie: TSerieGrafico;
  xl: string;
begin
  grafico := TJSONObject.Create;
  xkeys := TJSONArray.Create;
  ykeys := TJSONArray.Create;
  labels := TJSONArray.Create;
  Data := TJSONArray.Create;

  NseriesY := series_y.Count;
  NseriesX := series_x.Count;

  if series_y.Count > 0 then
    largo := length(TSerieGrafico(series_y[0]).valores)
  else
    raise Exception.Create('no hay series_y a graficar');

  for k := 0 to NseriesY - 1 do
  begin
    _serie := TSerieGrafico(series_y[k]);
    if (largo <> Length(_serie.valores)) then
      raise Exception.Create('las series a graficar tienen diferentes largos');
  end;

  if ((tipoGrafico = TG_Barras) or (tipoGrafico = TG_AreasApiladas)) then
  begin
    //**CARGAR ARREGLO DATA CON OBJETOS PUNTO**//
    for k := 0 to largo - 1 do
    begin
      punto := TJSONObject.Create;
      for j := 0 to NseriesX - 1 do
      begin
        _serie := TSerieGrafico(series_x[j]);
        if _serie.FormatoFecha then
          DateTimeToString(xl, _serie.formato_str, _serie.valores[k])
        else
          xl := floattostr(_serie.valores[k]);
        punto.Add(_serie.nombre, xl);
      end;
      for i := 0 to NseriesY - 1 do
      begin
        _serie := TSerieGrafico(series_y[i]);
        punto.Add(_serie.nombre, _serie.valores[k]);
      end;
      Data.Add(punto);
      //punto.free;

    end;
    //==========================================//
    //**CARGAR ARREGLO XKEYS, YKEYS Y LABELS CON LOS NOMBRES**//
    for j := 0 to NseriesX - 1 do
      xkeys.Add(TSerieGrafico(series_x[j]).nombre);
    for i := 0 to NseriesY - 1 do
    begin
      ykeys.Add(TSerieGrafico(series_y[i]).nombre);
      labels.add(TSerieGrafico(series_y[i]).nombre);
    end;

    grafico.add('element', TJSONString.Create(elemento));
    grafico.add('data', Data);
    grafico.add('xkey', xkeys);
    grafico.add('ykeys', ykeys);
    grafico.add('labels', labels);

    Result := grafico.FormatJSON();
  end;

end;


procedure TGrafico.Free;
var
  k: integer;
  aSerie: TSerieGrafico;
  aCaja: TCajaGraficoXY;

begin

  for k := 0 to series_y.Count - 1 do
  begin
    aSerie := series_y[k];
    aSerie.Free;
  end;


  for k := 0 to series_x.Count - 1 do
  begin
    aSerie := series_x[k];
    aSerie.Free;
  end;

  for k := 0 to cajasXY.Count - 1 do
  begin
    aCaja := cajasXY[k];
    aCaja.Free;
  end;

  series_y.Free;
  series_x.Free;
  cajasXY.Free;
  eje_x.Free;
  eje_y.Free;
  eje_y2.Free;
  inherited Free;

end;


constructor TCajaGraficoXY.Create(x1, y1, x2, y2: NReal; texto: string);
begin
  inherited Create;
  self.x1 := x1;
  self.y1 := y1;
  self.x2 := x2;
  self.y2 := y2;
  self.texto := texto;
  colorArea := clNone;
  colorLinea := clBlack;
  colorTexto := clBlack;
  eje := 0;
  penStyle := psSolid;
  brushStyle := bsSolid;
end;

procedure TCajaGraficoXY.Draw(c: TCanvas; g: TGrafico);
var
  px1, py1, px2, py2: integer;
  textSize: TSize;
begin
  px1 := g.x2w(x1);
  px2 := g.x2w(x2);
  if eje = 0 then
  begin
    py1 := g.y2h(y1);
    py2 := g.y2h(y2);
  end
  else
  begin
    py1 := g.y2h2(y1);
    py2 := g.y2h2(y2);
  end;

  c.Pen.Style := penStyle;
  c.Brush.Style := brushStyle;
  if (colorLinea <> clNone) or (colorArea <> clNone) then
  begin
    {$IFDEF FP_CANVAS}
    c.Pen.FPColor := colorLinea;
    c.Brush.FPColor := colorArea;
    {$ELSE}
    c.Pen.Color := colorLinea;
    c.Brush.Color := colorArea;
    {$ENDIF}
    c.Rectangle(px1, py1, px2, py2);
  end;
  if texto <> '' then
  begin
    {$IFDEF FP_CANVAS}
    c.Brush.FPColor := colorArea;
    c.Font.FPColor := colorTexto;
    {$ELSE}
    c.Brush.Color := colorArea;
    c.Font.Color := colorTexto;
    {$ENDIF}
    textSize := c.TextExtent(texto);
    px1 := round((px1 + px2) / 2 - textSize.cx / 2);
    py1 := round((py1 + py2) / 2 - textSize.cy / 2);
    c.TextOut(px1, py1, Texto);
  end;
end;

procedure TCajaGraficoXY.Free;
begin
  inherited Free;

end;


end.
