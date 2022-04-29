unit u_ExcelFile;

{$MODE Delphi}

interface

// http://wiki.lazarus.freepascal.org/ExcelAutomation/de

uses
  Graphics,
  Dialogs, FileUtil, SysUtils, variants,
  {$IFDEF LOGO_SIMSEE}
  ulogoSimSEE,
  {$ENDIF}
  XLConst, xmatdefs, matreal;

const
  versionOffice2007 = 12.0;


type
  TDAOfVariant = array of variant;
  TPaletaColoresExcel = array [1..56] of TColor;

  { T_ExcelFile }

  T_ExcelFile = class
  private
    //La proxima posición a llenar del buffer
    iBuffer: integer;
    buffer: TDAOfVariant;
  public
    v: variant; // el workbook
    ha: variant; // hoja activa;
    r: variant; // rango activo;
    international: variant;

    fila, columna: integer; // puntero en la hoja activa
    autocierre: boolean;
    avisoCierre: boolean;

    constructor Create(nombreHoja1: WideString; Visible: boolean;
      autocierre, avisocierre: boolean); overload;

    constructor Create; overload;

    //    constructor CreateLoad( nombre: WideString; visible: boolean );
    procedure Guardar(nombre: WideString);
    procedure Abrir(nombArchivo: WideString);
    procedure agregoLibro;
    procedure agregoHoja(nombreHoja: WideString);
    function agregarNuevaHoja: variant;
    function Hoja(numeroHoja: integer): variant; overload;
    function Hoja(nombreHoja: WideString): variant; overload;
    procedure EscribirCeldaHojaActual(fila: integer; columna: integer;
      contenido: variant);
    procedure EscribirCelda(nombreHoja: WideString; fila: integer;
      columna: integer; contenido: variant);
    procedure EscribirCeldaTexto(nombreHoja: WideString; fila: integer;
      columna: integer; contenido: WideString);
    function ContenidoCelda(nombreHoja: WideString; var fila: integer;
      columna: integer; incrementa: boolean): variant;
    procedure Cerrar(conAviso: boolean);
    procedure Free;
    procedure VisibleOn;
    procedure VisibleOff;

    // agregado por comodidad.
    procedure ActivoHoja_nombre(nombreHoja: WideString); overload;
    procedure ActivoHoja_numero(numeroHoja: integer); overload;
    procedure ir(fila, columna: integer);
    procedure irr(dfila, dcolumna: integer);

    function ReadV: variant;
    // leen un valor incrementando la posición del cursor
    function ReadV_Str: shortstring;
    function ReadV_Float: extended;
    function ReadV_Int: integer;

    // posicionan el cursor y llaman a una de las de arriba
    function ReadStr(fila, columna: integer): shortstring;
    function ReadFloat(fila, columna: integer): extended;
    function ReadInt(fila, columna: integer): integer;

    procedure readln;

    (* estas dos son redundantes pero las agrego por comodidad *)
    procedure Write(contenido: variant); overload;
    procedure go(NombreHoja: WideString; fila, columna: integer);
    function BuscaPal(var kFil, jCol: integer; palabra: string;
      fIni, cIni, fFin, cFin: integer): boolean;

    (*.............................................................*)

    //Retorna la letra de la columna nroCol
    function nroColToExcelCol(nroCol: cardinal): WideString;

    //cambia el tamanio del buffer
    procedure setTamanioBuffer(nCeldas: integer);
    //Almacena los datos que se piden escribir en un buffer, los datos no se
    //bajan al excel hasta que se haga un llamado a WriteLnBuffer o el buffer
    //se llena. No usar en combinacion con otros writes. Esto es entre que se
    //hace una llamada WriteBuffereado y su correspondiente llamada a WriteLnBuffer
    //no debe llamarse otro write o se perdera el orden de las columnas
    procedure WriteBuffereado(const contenido: variant);
    procedure WriteLnBuffer;
    function columnaBuffereada: integer;

    procedure WriteV(contenido: variant);
    //Escribe una fila entera de valores
    procedure WriteFila(const contenido: TDAOfVariant);
    procedure WriteLnFila(const contenido: TDAOfVariant);
    procedure WriteF(contenido: variant; formato: WideString);
    procedure WriteMAF(contenido: variant; celdas: integer;
      alineacion: integer; formato: WideString);
    procedure writeln(contenido: variant); overload; // fila:=fila+1; columna:= 1

    procedure Write(val: shortString); overload;
    procedure Write(val: extended); overload;
    procedure Write(val: integer); overload;

    procedure Write(fila, columna: integer; val: shortString); overload;
    procedure Write(fila, columna: integer; val: extended); overload;
    procedure Write(fila, columna: integer; val: integer); overload;

    procedure writeln(val: shortstring); overload;
    procedure writeln(val: double); overload;
    procedure writeln(val: integer); overload;


    procedure writeln; overload;

    function ref(fila, columna: integer): WideString;
    function ref_rango(f1, c1, f2, c2: integer): WideString;

    procedure SelRango(fil1, col1, fil2, col2: integer);
    procedure BordeSimple(ancho: integer;
      Arriba, Derecha, Abajo, Izquierda, InteriorVertical,
      InteriorHorizontal: boolean);

    procedure CambiarFuente(nuevafuente: WideString);
    procedure CambiarTamFuente(nuevotam: integer);

    // cambio de color usando ColorIndex
    procedure CambiarColorFuente_ci(nuevoci: integer);
    procedure CambiarColorFondo_ci(nuevoci: integer);

    // cambio de color usuando un TColor
    procedure CambiarColorFuente_cl(nuevoCol: TColor);
    procedure CambiarColorFondo_cl(nuevoCol: TColor);

    procedure CambiarFormato(nuevoFormato: WideString);
    procedure CambiarAncho(nuevoAncho: integer);
    procedure CambiarAlto(nuevoAlto: integer);
    procedure CambiarFormula(nuevaFormula: WideString);
    procedure CombinarCeldas;

    procedure AlinearDerecha;
    procedure AlinearIzquierda;
    procedure AlinearCentro;
    procedure WrapTextON;
    procedure WrapTextOFF;
    procedure BoldON;
    procedure BoldOFF;
    procedure InsertarImagen(archi: WideString; x, y: double);
    procedure Zoom(porciento: integer);

    // acomada para imprimir
    procedure SetPage(PaginaVertical: boolean);
    //Retorna true si el libro del T_ExcelFile esta abierto.
    //Si se cerro el EXCEL sin liberar el T_ExcelFile retorna false
    function libroAbierto: boolean;

    procedure autoFitCells;

    //Retorna la cantidad de filas k entre la celda actual (x,y) y la primer
    //celda (x + k, y) cuyo contenido esté en blanco. El cursor queda en la
    //celda (x, y)
    function contarFilasHastaBlanco: integer;
    //Retorna la cantidad de columnas k entre la celda actual (x,y) y la primer
    //celda (x, y + k) cuyo contenido esté en blanco. El cursor queda en la
    //celda (x, y)
    function contarColumnasHastaBlanco: integer;
    function contarHojas: integer;

    function getPaletaColores: TPaletaColoresExcel;
    procedure setPaletaColores(nuevaPaleta: TPaletaColoresExcel);

    //12 = office 2007
    function version: double;


    procedure aplicarPropiedadesAGrafico(nombreHoja: shortString;
      tipoGrafico: integer;  // xlsConstant
      titulo, ejeY: shortString; minEjeYAuto, maxEjeYAuto: boolean;
      minEjeY, MaxEjeY: double; minEjeX, MaxEjeX: double;ejeX: shortString='');

    procedure aplicarPropiedadesASerie(nombreHoja: shortstring;
      iSerie: integer; //1..nSeries
      tipoGraficoPrincipal, tipoGrafico: integer; eje: integer; color: TColor);


    function graficar(nombreHoja: shortstring;
      colIni, colFin, filaIni, filaFin: integer;
      aCharType: integer = xlXYScatterLines): shortstring;

    function ReadFilaVect(Encab, Variable: string; offsetColVariable: integer;
      NCols: integer; offsetColDatos: integer; defVal: double=0; filIni: integer
  =1; colIni: integer=1; filFin: integer=490; colFin: integer=100;
  offsetFilDatos: integer=0; offsetFilVariable: integer=0): TVectR;

    function ReadColVect(Encab, Variable: string; offsetColVariable: integer;
      NFils: integer; offsetColDatos: integer; defVal: double=0; filIni: integer
      =1; colIni: integer=1; filFin: integer=490; colFin: integer=100;
      offsetFilDatos: integer=0; offsetFilVariable: integer=0): TVectR; overload;

    function ReadColVect(Variable: string; NFils: integer; offsetFilDatos: integer;
      defVal: double; filIni: integer; colIni: integer; filFin: integer;
  colFin: integer): TVectR; overload;
  end;

//agrega los colores en coloresATenerEnLaPaleta si no existen en la paleta
//actual intentando poner los colores nuevos sobre el final
function corregirPaletaColores(const coloresATenerEnLaPaleta: array of TColor;
  const paletaACorregir: TPaletaColoresExcel): TPaletaColoresExcel;
function getColorIndex(color: TColor; const paleta: TPaletaColoresExcel): integer;

const
  paletaExcelPorDefecto: TPaletaColoresExcel =
    (0, 16777215, 255, 65280, 16711680, 65535, 16711935, 16776960, 128,
    32768, 8388608, 32896, 8388736, 8421376, 12632256, 8421504, 16751001,
    6697881, 13434879, 16777164, 6684774, 8421631, 13395456, 16764108,
    8388608, 16711935, 65535, 16776960, 8388736, 128, 8421376, 16711680,
    16763904, 16777164, 13434828, 10092543, 16764057, 13408767, 16751052,
    10079487, 16737843, 13421619, 52377, 52479, 39423, 26367, 10053222,
    9868950, 6697728, 6723891, 13056, 13107, 13209, 6697881, 10040115, 3355443);

  ciCanela = 40;
  //  ciAmarilloClaro =36;
  ciVerdeClaro = 35;
  ciTurquesaClaro = 34;
  ciAzulPalido = 37;
  ciLavanda = 39;
  ciAnil = 55;
  ciBlanco = 2;

  alDerecha = 1;
  alIzquierda = 2;
  alCentro = 3;
  alNada = 0;


function rgb(r, g, b: byte): TColor;
procedure extractRGB(color: TColor; var r, g, b: byte);
function BGRToRGB(colorBGR: TColor): TColor;

implementation

uses
  ComObj;

const
  tiposGraficosConMarcadores = [xlXYScatterLines];
  tiposGraficosConColorInterior = [xlAreaStacked];


{$IFDEF LOGO_SIMSEE}
function bin_root: WideString;
var
  s: string;
  k: integer;
  buscando: boolean;
begin
  s := ParamStr(0);
  buscando := True;
  k := length(s);
  while buscando and (k > 0) do
  begin
    if s[k] = '\' then
      buscando := False
    else
      Dec(k);
  end;
  if not buscando then
    Delete(s, k, length(s) - k + 1)
  else
    s := '';
  Result := s;
end;

{$ENDIF}



function rgb(r, g, b: byte): TColor;
begin
  Result := (b * 256 + g) * 256 + r;
end;

procedure extractRGB(color: TColor; var r, g, b: byte);
begin
  r := Color and $ff;
  g := (Color and $ff00) shr 8;
  b := (Color and $ff0000) shr 16;
end;

function BGRToRGB(colorBGR: TColor): TColor;
begin
  Result := (colorBGR and $ff) shl 16 + (colorBGR and $ff00) shl
    8 + (colorBGR and $ff0000);
end;

procedure T_ExcelFile.ir(fila, columna: integer);
begin
  self.Fila := fila;
  self.columna := columna;
end;

procedure T_ExcelFile.irr(dfila, dcolumna: integer);
begin
  fila := fila + dfila;
  columna := columna + dcolumna;
end;

function T_ExcelFile.ref(fila, columna: integer): WideString;
var
  scol: shortstring;
  kcol, dig: integer;
begin
  scol := '';
  kcol := columna - 1;
  while kcol >= 0 do
  begin
    dig := kcol mod 26;
    scol := chr(Ord('A') + dig) + scol;
    kcol := (kcol div 26) - 1;
  end;

  Result := scol + IntToStr(fila);
end;

function T_ExcelFile.ref_rango(f1, c1, f2, c2: integer): WideString;
begin
  Result := ref(f1, c1) + ':' + ref(f2, c2);
end;

procedure T_ExcelFile.SelRango(fil1, col1, fil2, col2: integer);
begin
  r := ha.Range[ref_rango(fil1, col1, fil2, col2)];
end;


procedure T_ExcelFile.CambiarFuente(nuevafuente: WideString);
begin
  r.Font.Name := nuevaFuente;
end;

procedure T_ExcelFile.BordeSimple(ancho: integer;
  Arriba, Derecha, Abajo, Izquierda, InteriorVertical, InteriorHorizontal: boolean);
begin

  r.Borders[xlDiagonalDown].LineStyle := xlNone;
  r.Borders[xlDiagonalUp].LineStyle := xlNone;

  if Izquierda then
  begin
    r.Borders[xlEdgeLeft].LineStyle := xlContinuous;
    r.Borders[xlEdgeLeft].Weight := ancho;
    r.Borders[xlEdgeLeft].ColorIndex := xlAutomatic;
  end;
{
   else
    r.Borders[xlEdgeLeft].LineStyle := xlNone;
 }
  if Arriba then
  begin
    r.Borders[xlEdgeTop].LineStyle := xlContinuous;
    r.Borders[xlEdgeTop].Weight := ancho;
    r.Borders[xlEdgeTop].ColorIndex := xlAutomatic;
  end;
{
   else
    r.Borders[xlEdgeTop].LineStyle := xlNone;
 }

  if Abajo then
  begin
    r.Borders[xlEdgeBottom].LineStyle := xlContinuous;
    r.Borders[xlEdgeBottom].Weight := ancho;
    r.Borders[xlEdgeBottom].ColorIndex := xlAutomatic;
  end;
{
   else
    r.Borders[xlEdgeBottom].LineStyle := xlNone;
 }

  if Derecha then
  begin
    r.Borders[xlEdgeRight].LineStyle := xlContinuous;
    r.Borders[xlEdgeRight].Weight := ancho;
    r.Borders[xlEdgeRight].ColorIndex := xlAutomatic;
  end;
{
   else
    r.Borders[xlEdgeRight].LineStyle := xlNone;
 }

  if InteriorHorizontal and (r.Rows.Count > 1) then
  begin
    r.Borders[xlInsideHorizontal].LineStyle := xlContinuous;
    r.Borders[xlInsideHorizontal].Weight := ancho;
    r.Borders[xlInsideHorizontal].ColorIndex := xlAutomatic;
  end;
{
   else
    r.Borders[xlInsideHorizontal].LineStyle := xlNone;

 }

  if InteriorVertical and (r.Columns.Count > 1) then
  begin
    r.Borders[xlInsideVertical].LineStyle := xlContinuous;
    r.Borders[xlInsideVertical].Weight := ancho;
    r.Borders[xlInsideVertical].ColorIndex := xlAutomatic;
  end;
{
   else
    r.Borders[xlInsideVertical].LineStyle := xlNone;
}
end;

procedure T_ExcelFile.CambiarTamFuente(nuevotam: integer);
begin
  r.Font.Size := nuevoTam;
end;

procedure T_ExcelFile.CambiarColorFuente_ci(nuevoci: integer);
begin
  r.Font.ColorIndex := nuevoci;
end;

procedure T_ExcelFile.BoldON;
begin
  r.Font.Bold := True;
end;

procedure T_ExcelFile.BoldOFF;
begin
  r.Font.Bold := False;
end;

procedure T_ExcelFile.CambiarColorFondo_ci(nuevoci: integer);
begin
  r.Columns.Interior.ColorIndex := nuevoci;
end;

procedure T_ExcelFile.CambiarColorFuente_cl(nuevoCol: TColor);
begin
  r.Font.Color := nuevoCol;
end;

procedure T_ExcelFile.CambiarColorFondo_cl(nuevoCol: TColor);
begin
  r.Columns.Interior.Color := nuevoCol;
end;

procedure T_ExcelFile.CambiarFormato(nuevoFormato: WideString);
begin
  system.writeln('EXCEL v:', self.version, ' cambiarForamto: ', nuevoFormato);

  r.NumberFormat := nuevoFormato; // '0.00' por ejemplo, o 'd/m/yy h:mm'
end;

procedure T_ExcelFile.CambiarAncho(nuevoAncho: integer);
begin
  r.Columns.ColumnWidth := nuevoAncho;
end;

procedure T_ExcelFile.CambiarAlto(nuevoAlto: integer);
begin
  r.Rows.RowHeight := nuevoAlto;
end;

procedure T_ExcelFile.CambiarFormula(nuevaFormula: WideString);
begin
  r.Formula := nuevaFormula; // Por Ej.: nuevaFormula:= '=RAND()';
end;

procedure T_ExcelFile.CombinarCeldas;
begin
  r.Merge;
end;


procedure T_ExcelFile.AlinearDerecha;
begin
  r.HorizontalAlignment := xlRight;
end;

procedure T_ExcelFile.AlinearIzquierda;
begin
  r.HorizontalAlignment := xlLeft;
end;

procedure T_ExcelFile.AlinearCentro;
begin
  r.HorizontalAlignment := xlCenter;
end;

procedure T_ExcelFile.WrapTextON;
begin
  r.WrapText := True;
end;

procedure T_ExcelFile.WrapTextOFF;
begin
  r.WrapText := False;
end;

procedure T_ExcelFile.Zoom(porciento: integer);
begin
  v.ActiveWindow.Zoom := porciento;
end;


function T_ExcelFile.ReadV: variant;
begin
  Result := ha.cells[fila, columna].Value;
  Inc(columna);
end;


function T_ExcelFile.ReadV_Str: shortstring;
var
  s: WideString;
begin
  s:= readV;
  Result := AnsiToUtf8( s );
end;

function T_ExcelFile.ReadV_Float: extended;
begin
  Result := ReadV;
end;

function T_ExcelFile.ReadV_Int: integer;
begin
  Result := ReadV;
end;

// posicionan el cursor y llaman a una de las de arriba
function T_ExcelFile.ReadStr(fila, columna: integer): shortstring;
begin
  ir(fila, columna);
  Result := ReadV_Str;
end;

function T_ExcelFile.ReadFloat(fila, columna: integer): extended;
begin
  ir(fila, columna);
  Result := ReadV_Float;
end;

function T_ExcelFile.ReadInt(fila, columna: integer): integer;
begin
  ir(fila, columna);
  Result := ReadV_Int;
end;


procedure T_ExcelFile.readln;
begin
  fila := fila + 1;
  columna := 1;
end;

procedure T_ExcelFile.WriteMAF(contenido: variant; celdas: integer;
  alineacion: integer; formato: WideString);
begin
  writev(contenido);
  selRango(fila, columna - 1, fila, columna - 1 + celdas - 1);

  if celdas > 0 then
    combinarCeldas;

  case alineacion of
    alDerecha: AlinearDerecha;
    alIzquierda: AlinearIzquierda;
    alCentro: AlinearCentro;
  end;
  if formato <> '' then
    cambiarFormato(formato);
  columna := columna + celdas - 1;
end;

constructor T_ExcelFile.Create;
begin
  inherited Create;
  v := CreateOleObject('Excel.Application');
  v.Visible := True;
end;

constructor T_ExcelFile.Create(nombreHoja1: WideString; Visible: boolean;
  autocierre, avisocierre: boolean);
var
  nBooks: integer;

begin

{$IFDEF LOGO_SIMSEE}
  save_logo_simsee_sr3(bin_root + '\logoSimSEE.jpg');
{$ENDIF}

  self.autocierre := autocierre;
  self.avisocierre := avisocierre;

  inherited Create;
  v := CreateOleObject('Excel.Application');
  v.Visible := Visible;

  if nombreHoja1 <> '' then
  begin
    v.Workbooks.Add;
    v.Workbooks[1].WorkSheets.Add;
    v.Workbooks[1].WorkSheets[1].Name := nombreHoja1;
    ActivoHoja_nombre(nombreHoja1);
  end;
  SetLength(buffer, 255); //tamaño para un libro excel 2003
end;

function T_ExcelFile.Hoja(numeroHoja: integer): variant;
begin
  Result := v.Workbooks[1].WorkSheets[numeroHoja];
end;

function T_ExcelFile.Hoja(nombreHoja: WideString): variant;
begin
  Result := v.Workbooks[1].WorkSheets[nombreHoja];
end;

procedure T_ExcelFile.ActivoHoja_nombre(nombreHoja: WideString);
begin
  ha := v.Workbooks[1].WorkSheets[nombreHoja];
  ha.Select;
  fila := 1;
  columna := 1;
end;

procedure T_ExcelFile.ActivoHoja_numero(numeroHoja: integer);
begin
  ha := v.Workbooks[1].WorkSheets[numeroHoja];
  ha.Select;
  fila := 1;
  columna := 1;
end;


procedure T_ExcelFile.go(NombreHoja: WideString; fila, columna: integer);
begin
  ActivoHoja_nombre(NombreHoja);
  ir(fila, columna);

end;


function T_ExcelFile.BuscaPal(var kFil, jCol: integer; palabra: string;
  fIni, cIni, fFin, cFin: integer): boolean;
var
  c, f: integer;
  s,s2: string;
  palabra_lower: string;

begin
  Result := False;
  palabra_lower := lowercase(trim(palabra));
  for c := cini to cfin do
  begin
    for f := fini to ffin do
    begin
      s2:= trim(ReadStr(f, c));
      s := lowercase( s2 );
      (*
      if pos(  'imp. gara', s ) > 0 then
      begin
        writeln('hola');
        s2:= trim(ReadStr(f, c));
      end;
      *)
      if (s = palabra_lower) then
      begin
        kFil:= f;
        jCol:= c;
        Result := True;
        break;
      end;
    end;
    if (Result = True) then
      break;
    end;
end;



procedure T_ExcelFile.SetPage(PaginaVertical: boolean);
begin
  ha.PageSetup.LeftHeader := '';
  ha.PageSetup.CenterHeader := '';
  ha.PageSetup.RightHeader := '';
  ha.PageSetup.LeftFooter := '';
  ha.PageSetup.CenterFooter := '';
  ha.PageSetup.RightFooter := '';
  ha.PageSetup.LeftMargin := v.Application.InchesToPoints(0.78740157480315 / 2);
  ha.PageSetup.RightMargin := v.Application.InchesToPoints(0.78740157480315 / 2);
  ha.PageSetup.TopMargin := v.Application.InchesToPoints(0.78740157480315);
  ha.PageSetup.BottomMargin := v.Application.InchesToPoints(0.78740157480315);
  ha.PageSetup.HeaderMargin := v.Application.InchesToPoints(0);
  ha.PageSetup.FooterMargin := v.Application.InchesToPoints(0);
  ha.PageSetup.PrintHeadings := False;
  ha.PageSetup.PrintGridlines := False;
  ha.PageSetup.PrintComments := xlPrintNoComments;
  //   ha.PageSetup.PrintQuality := 360;
  ha.PageSetup.CenterHorizontally := False;
  ha.PageSetup.CenterVertically := False;
  if PaginaVertical then
    ha.PageSetup.Orientation := xlPortrait
  else
    ha.PageSetup.Orientation := xlLandscape;
{
   ha.PageSetup.Draft := False;
   ha.PageSetup.PaperSize := xlPaperA4;
   ha.PageSetup.FirstPageNumber := xlAutomatic;
   ha.PageSetup.Order := xlDownThenOver;
   ha.PageSetup.BlackAndWhite := False;
}
  ha.PageSetup.Zoom := False;
  ha.PageSetup.FitToPagesWide := 1;
  ha.PageSetup.FitToPagesTall := 7;
  //    ActiveWindow.SelectedSheets.PrintOut Copies:=1, Preview:=True
end;

function T_ExcelFile.libroAbierto: boolean;
begin
  Result := v.workbooks.Count > 0;
end;

procedure T_ExcelFile.autoFitCells;
var
  celda: WideString;
begin
  ha.Cells.Select;
  ha.Cells.EntireColumn.AutoFit;
  celda := nroColToExcelCol(columna) + IntToStr(fila);
  ha.Range[celda, celda].Select;
end;

function T_ExcelFile.contarFilasHastaBlanco: integer;
var
  filaInicial, columnaInicial, res: integer;
  contenidoCelda: WideString;
  celdaEnBlanco: boolean;
begin
  filaInicial := self.fila;
  columnaInicial := self.columna;
  res := 0;
  contenidoCelda := self.ReadV;
  celdaEnBlanco := contenidoCelda = '';
  while not celdaEnBlanco do
  begin
    res := res + 1;
    self.ir(filaInicial + res, columnaInicial);
    contenidoCelda := self.ReadV;
    celdaEnBlanco := contenidoCelda = '';
  end;
  self.ir(filaInicial, columnaInicial);
  Result := res;
end;

function T_ExcelFile.contarColumnasHastaBlanco: integer;
var
  filaInicial, columnaInicial, res: integer;
  contenidoCelda: WideString;
  celdaEnBlanco: boolean;
begin
  filaInicial := self.fila;
  columnaInicial := self.columna;
  res := 0;
  contenidoCelda := self.ReadV;
  celdaEnBlanco := contenidoCelda = '';
  while not celdaEnBlanco do
  begin
    res := res + 1;
    self.ir(filaInicial, columnaInicial + res);
    contenidoCelda := self.ReadV;
    celdaEnBlanco := contenidoCelda = '';
  end;
  self.ir(filaInicial, columnaInicial);
  Result := res;
end;

function T_ExcelFile.contarHojas: integer;
var
  res: integer;
begin
  res := self.v.Worksheets.Count;
  Result := res;
end;

function T_ExcelFile.getPaletaColores: TPaletaColoresExcel;
var
  i: integer;
  res: TPaletaColoresExcel;
  paleta: variant;
begin
  paleta := v.workbooks[1].Colors;
  for i := low(res) to high(res) do
    res[i] := paleta[i];
  Result := res;
end;

procedure T_ExcelFile.setPaletaColores(nuevaPaleta: TPaletaColoresExcel);
var
  i: integer;
  //  r, g, b: byte;
begin
  for i := low(nuevaPaleta) to high(nuevaPaleta) do
    v.workbooks[1].Colors[i] := nuevaPaleta[i];

{  paleta:= v.workbooks[1].Palette;
  for i:= low(nuevaPaleta) to high(nuevaPaleta) do
  begin
    extractRGB(nuevaPaleta[i], r, g, b);
    paleta.SetColorAt(i, r, g, b);
  end;}
end;

function T_ExcelFile.version: double;
begin
  Result := v.Version;
end;

procedure T_ExcelFile.setTamanioBuffer(nCeldas: integer);
var
  nuevoBuffer: TDAOfVariant;
  i: integer;
begin
  if Length(buffer) <> nCeldas then
  begin
    SetLength(nuevoBuffer, nCeldas);
    for i := 0 to iBuffer - 1 do
      nuevoBuffer[i] := buffer[i];
    SetLength(buffer, 0);
    buffer := nuevoBuffer;
  end;
end;

procedure T_ExcelFile.WriteBuffereado(const contenido: variant);
begin
  if iBuffer < Length(buffer) then
  begin
    buffer[iBuffer] := contenido;
    iBuffer := iBuffer + 1;
  end
  else
  begin
    WriteFila(copy(buffer, 0, iBuffer - 1));
    iBuffer := 0;
  end;
end;

procedure T_ExcelFile.WriteLnBuffer;
begin
  if iBuffer > 0 then
  begin
    WriteLnFila(copy(buffer, 0, iBuffer));
    iBuffer := 0;
  end;
end;

function T_ExcelFile.columnaBuffereada: integer;
begin
  Result := columna + iBuffer;
end;

procedure T_ExcelFile.WriteV(contenido: variant);
begin
  ha.cells[fila, columna].Value := contenido;
  Inc(columna);
end;

procedure T_ExcelFile.WriteFila(const contenido: TDAOfVariant);
var
  celdaDesde, celdaHasta: WideString;
  filaStr: WideString;
begin
  if length(contenido) > 0 then
  begin
    filaStr := IntToStr(fila);
    celdaDesde := nroColToExcelCol(columna) + filaStr;
    celdaHasta := nroColToExcelCol(columna + high(contenido)) + filaStr;
    columna := columna + Length(contenido);

    ha.Range[celdaDesde, celdaHasta].Value := VarArrayOf(contenido);
  end;
end;

procedure T_ExcelFile.WriteLnFila(const contenido: TDAOfVariant);
var
  celdaDesde, celdaHasta: WideString;
  filaStr: WideString;
begin
  if length(contenido) > 0 then
  begin
    filaStr := IntToStr(fila);
    celdaDesde := nroColToExcelCol(columna) + filaStr;
    celdaHasta := nroColToExcelCol(columna + high(contenido)) + filaStr;
    columna := 1;
    fila := fila + 1;

    ha.Range[celdaDesde, celdaHasta].Value := VarArrayOf(contenido);
  end;
end;

function T_ExcelFile.nroColToExcelCol(nroCol: cardinal): WideString;
var
  res: WideString;
  digitos, offset, limite, c: cardinal;
begin
  digitos := 1;
  offset := 0;
  nroCol := nroCol - 1;
  limite := 26;
  while (nroCol >= limite + offset) do
  begin
    offset := offset + limite;
    limite := limite * 26;
    digitos := digitos + 1;
  end;

  res := '';
  c := nroCol - offset;
  while digitos > 0 do
  begin
    digitos := digitos - 1;
    res := Chr(Ord('A') + c mod 26) + res;
    c := c div 26;
  end;

  Result := res;
end;

procedure T_ExcelFile.Write(contenido: variant);
begin
  ha.cells[fila, columna].Value := contenido;
  Inc(columna);
end;

procedure T_ExcelFile.WriteF(contenido: variant; formato: WideString);
begin
  ha.cells[fila, columna].Value := contenido;
  ha.cells[fila, columna].NumberFormat := formato;
  Inc(columna);
end;

procedure T_ExcelFile.writeln; // fila:=fila+1; columna:= 1
begin
  Inc(fila);
  columna := 1;
end;

procedure T_ExcelFile.writeln(contenido: variant);
begin
  WriteV(contenido);
  writeln;
end;


procedure T_ExcelFile.Write(val: shortString);
var
  s: WideString;
begin
  s:= val;
  writeV( s );
end;

procedure T_ExcelFile.Write(val: extended);
begin
  writeV(val);
end;

procedure T_ExcelFile.Write(val: integer);
begin
  writeV(val);
end;

procedure T_ExcelFile.Write(fila, columna: integer; val: shortString);
begin
  ir(fila, columna);
  Write(val);
end;

procedure T_ExcelFile.Write(fila, columna: integer; val: extended);
begin
  ir(fila, columna);
  Write(val);
end;

procedure T_ExcelFile.Write(fila, columna: integer; val: integer);
begin
  ir(fila, columna);
  Write(val);
end;

procedure T_ExcelFile.writeln(val: shortstring);
begin
  ir(fila, columna);
  Write(val);
  writeln;
end;

procedure T_ExcelFile.writeln(val: double);
begin
  ir(fila, columna);
  writeln(val);
  writeln;
end;

procedure T_ExcelFile.writeln(val: integer);
begin
  ir(fila, columna);
  writeln(val);
  writeln;
end;


procedure T_ExcelFile.InsertarImagen(archi: WideString; x, y: double);
var
  s: variant;
  //  n: integer;
begin
  (*
  ha.Pictures.Insert(archi);
  n:= ha.Pictures.Count;
  s:= ha.Pictures[n];
  s.Left:= x; s.Top:= y;
  *)
  if (FileExistsUTF8(archi) { *Convertido desde FileExists* }) then
  begin
    s := ha.Pictures.Insert(archi);
    s.ShapeRange.IncrementLeft(x - s.ShapeRange.Width * 1.2);
    s.ShapeRange.IncrementTop(y + (s.ShapeRange.Height / 3.0));
  end;
end;

procedure T_ExcelFile.EscribirCeldaHojaActual(fila: integer; columna: integer;
  contenido: variant);
begin
  ha.cells[fila, columna].Value := contenido;
end;

procedure T_ExcelFile.EscribirCelda(nombreHoja: WideString; fila: integer;
  columna: integer; contenido: variant);
var
  h: variant;
begin
  h := self.Hoja(nombreHoja);
  h.cells[fila, columna].Value := contenido;
end;

procedure T_ExcelFile.EscribirCeldaTexto(nombreHoja: WideString;
  fila: integer; columna: integer; contenido: WideString);
var
  h: variant;
begin
  h := self.Hoja(nombreHoja);
  h.cells[fila, columna].Value := contenido;
end;

function T_ExcelFile.ContenidoCelda(nombreHoja: WideString; var fila: integer;
  columna: integer; incrementa: boolean): variant;
var
  h: variant;
begin
  //  h:= v.Workbooks[1].WorkSheets[1];
  h := self.Hoja(nombreHoja);
  Result := h.cells[fila, columna].Value;
  if incrementa then
    Inc(fila);
end;


procedure T_ExcelFile.Guardar(nombre: WideString);
begin

  system.writeln('T_ExcelFile.Guardar('''+nombre+''')');

  v.Workbooks[1].SaveAs(nombre, v.Workbooks[1].fileformat);
{
  FileName:="C:\Mis documentos\Hoja1.xls",
  FileFormat:= xlNormal,
  Password:="",
  WriteResPassword:="",
  ReadOnlyRecommended:=False,
  CreateBackup:=False );}
end;

procedure T_ExcelFile.Abrir(nombArchivo: WideString);
begin
  v.Workbooks.Open(nombArchivo);
end;

procedure T_ExcelFile.agregoLibro;
begin
  v.Workbooks.Add(xlWBatWorkSheet);
end;

procedure T_ExcelFile.agregoHoja(nombreHoja: WideString);
begin
  // v.Workbooks[1].WorkSheets.count
  v.Workbooks[1].WorkSheets.Add(, , 1, xlWorksheet); // el 1 es una hoja
  v.Workbooks[1].WorkSheets[1].Name := nombreHoja;
end;

function T_ExcelFile.agregarNuevaHoja: variant;
begin
  v.Workbooks[1].WorkSheets.Add(, , 1, xlWorksheet); // el 1 es una hoja
  result:= v.Workbooks[1].WorkSheets[1];
end;

procedure T_ExcelFile.Free;
begin
  if autocierre and not VarIsEmpty(v) then
  begin
    v.DisplayAlerts := avisocierre;
    v.Quit;
  end;
  SetLength(buffer, 0);
  inherited Free;
end;

procedure T_ExcelFile.Cerrar(conAviso: boolean);
begin
  if not VarIsEmpty(v) then
  begin
    v.DisplayAlerts := conAviso;
    v.Quit;
  end;
end;

procedure T_ExcelFile.VisibleOn;
begin
  v.Visible := True;
end;

procedure T_ExcelFile.VisibleOff;
begin
  v.Visible := False;
end;

function iColorEnPaleta(color: TColor; const arreglo: TPaletaColoresExcel): integer;
var
  i, res: integer;
begin
  res := -1;
  for i := Low(arreglo) to High(arreglo) do
    if arreglo[i] = color then
    begin
      res := i;
      break;
    end;
  Result := res;
end;


function ExcelStr2Nreal(s: String): string;
begin
  //la idea es dejar esta funcion para luego poder hacer esto de forma prolija
  //ahora solo voy a remplazar la coma por punto mvarela@11/2015

  Result:=StringReplace(s,',','.',[rfReplaceAll]);
end;

function corregirPaletaColores(const coloresATenerEnLaPaleta: array of TColor;
  const paletaACorregir: TPaletaColoresExcel): TPaletaColoresExcel;
var
  res: TPaletaColoresExcel;
  i, j: integer;
  iColoresATenerEnLaPaleta: integer;
  //Cual es la posición en paletaACorregir que contiene al color coloresATenerEnLaPaleta[i]
  matchColor: array of integer;
  matcheaConOtro: boolean;
begin
  if Length(coloresATenerEnLaPaleta) > high(paletaACorregir) then
    raise Exception.Create(
      'uExcelFile.corregirPaletaColores: esta intentando agregar mas de ' +
      IntToStr(High(paletaACorregir)) +
      ' a la paleta de colores de Excel, pero su versión no lo soporta.' +
      'Intente utilizar mas colores en común entre los distintos gráficos y vuelva a intentarlo.');

  SetLength(matchColor, length(coloresATenerEnLaPaleta));
  for i := 0 to High(coloresATenerEnLaPaleta) do
    matchColor[i] := iColorEnPaleta(coloresATenerEnLaPaleta[i], paletaACorregir);

  res := paletaACorregir;
  i := high(res);
  for iColoresATenerEnLaPaleta := High(coloresATenerEnLaPaleta) downto 0 do
  begin
    if matchColor[iColoresATenerEnLaPaleta] = -1 then
    begin
      //busco el primer i que no matchee ningun color
      repeat
        matcheaConOtro := False;
        for j := 0 to High(matchColor) do
          if matchColor[j] = i then
          begin
            matcheaConOtro := True;
            i := i - 1;
            break;
          end;
      until not matcheaConOtro;

      res[i] := coloresATenerEnLaPaleta[iColoresATenerEnLaPaleta];
      i := i - 1;
    end;
  end;

  Result := res;
end;

function getColorIndex(color: TColor; const paleta: TPaletaColoresExcel): integer;
var
  i, res: integer;
begin
  res := -1;
  for i := Low(paleta) to High(paleta) do
    if color = paleta[i] then
    begin
      res := i;
      break;
    end;
  Result := res;
end;


procedure T_ExcelFile.aplicarPropiedadesAGrafico(nombreHoja: shortString;
  tipoGrafico: integer;  // xlsConstant
  titulo, ejeY: shortString; minEjeYAuto, maxEjeYAuto: boolean;
  minEjeY, MaxEjeY: double; minEjeX, MaxEjeX: double;ejeX: shortString);
var
  hojag, serie: variant;
  i, highSeries: integer;
  xls: T_ExcelFile;
begin
  xls := self;

  hojag := v.Workbooks[1].Charts[nombreHoja];
  hojag.ChartType := tipoGrafico;

  if titulo <> '' then
  begin
    hojag.HasTitle := True;
    hojag.ChartTitle.Characters.Text := titulo;
  end;
  hojag.Axes(xlCategory, xlPrimary).HasTitle := False;
  if tipoGrafico <> xlAreaStacked then
  begin
    hojag.Axes(xlCategory).MinimumScale := minEjeX;
    hojag.Axes(xlCategory).MaximumScale := maxEjeX;
  end;
  if ejeY <> '' then
  begin
    hojag.Axes(xlValue, xlPrimary).HasTitle := True;
    hojag.Axes(xlValue, xlPrimary).AxisTitle.Characters.Text := ejeY;
  end;
  hojag.PlotArea.Interior.ColorIndex := 2;       //Color de fondo blanco
  if minEjeYAuto then
    hojag.Axes(xlValue).MinimumScaleIsAuto := True
  else
    hojag.Axes(xlValue).MinimumScale := minEjeY;   //Mínimo del eje Y
  if maxEjeYAuto then
    hojag.Axes(xlValue).MaximumScaleIsAuto := True
  else
    hojag.Axes(xlValue).MaximumScale := MaxEjeY;   //Máximo del eje Y

  highSeries := hojag.SeriesCollection.Count - 1;
  for i := 0 to highSeries do
  begin
    serie := hojag.SeriesCollection(i + 1);
    serie.MarkerSize := 2;
    //    serie.MarkerStyle:= -4142;
  end;
end;


procedure T_ExcelFile.aplicarPropiedadesASerie(nombreHoja: shortstring;
  iSerie: integer; //1..nSeries
  tipoGraficoPrincipal, tipoGrafico: integer; eje: integer; color: TColor);
var
  xls: T_ExcelFile;
  hojag, serie: variant;
  colorIndex: integer;
  aux: TPaletaColoresExcel;
begin
  xls := self;
  hojag := v.Workbooks[1].Charts[nombreHoja];
  serie := hojag.SeriesCollection(iSerie);
  //  if tipoGrafico <> tipoGraficoPrincipal then
  serie.ChartType := tipoGrafico;
  serie.AxisGroup := eje;

  if color <> clDefault then
  begin
    if xls.version < versionOffice2007 then
    begin
      aux := xls.getPaletaColores;
      colorIndex := getColorIndex(color, aux);

      if tipoGrafico in tiposGraficosConColorInterior then
        serie.Interior.Colorindex := colorIndex;
      serie.Border.Colorindex := colorIndex;
      if tipoGrafico in tiposGraficosConMarcadores then
      begin
        serie.MarkerStyle := xlAutomatic;
        serie.MarkerSize:=2;
        serie.MarkerBackgroundColorIndex := colorIndex;
        serie.MarkerForegroundColorIndex := colorIndex;
      end;
    end
    else
    begin
      if tipoGrafico in tiposGraficosConColorInterior then
        serie.Interior.Color := color;
      serie.Border.Color := color;
      if tipoGrafico in tiposGraficosConMarcadores then
      begin
        serie.MarkerStyle :=xlAutomatic;
        serie.MarkerSize:=2;
        serie.MarkerBackgroundColor := color;
        serie.MarkerForegroundColor := color;
      end;
    end;
  end;
end;


function T_ExcelFile.graficar(nombreHoja: shortstring;
  colIni, colFin, filaIni, filaFin: integer;
  aCharType: integer = xlXYScatterLines): shortstring;
var
  ARange: variant;
  hoja, hojag, htmp: variant;
  celdaIni, celdaFin: shortstring;
  {$IFDEF LOGO_SIMSEE}
  x_, y_: double;
  {$ENDIF}
  aLogo: variant;
begin
  hoja := Self.Hoja(nombreHoja);
  hojag := v.Workbooks[1].Charts.Add;
  hojag.Activate;
  hojag.ChartType := aCharType;

  (*
  Chart      VBA Constant (ChartType property of Chart object)
Column     xlColumnClustered, xlColumnStacked, xlColumnStacked100
Bar        xlBarClustered, xlBarStacked, xlBarStacked100
Line       xlLine, xlLineMarkersStacked, xlLineStacked
Pie        xlPie, xlPieOfPie
Scatter    xlXYScatter, xlXYScatterLines
*)

  hojag.Name := 'g' + nombreHoja;

  celdaIni := self.nroColToExcelCol(colIni) + IntToStr(filaIni);
  celdaFin := self.nroColToExcelCol(colFin) + IntToStr(filaFin);
  ARange := hoja.Range[celdaIni + ':' + celdaFin];

  hojag.SetSourceData(ARange, xlColumns);

  htmp := self.ha;
  self.ha := hojag;
  self.ha.chartarea.font.size := 14;

  self.ha.Axes(xlValue).TickLabels.NumberFormat := WideString('0.0');

  self.ha.chartarea.Select;

  {$IFDEF LOGO_SIMSEE}
  // v.ActiveWindow.Zoom:= 100;
  ha.ChartArea.Select;
  aLogo := ha.Pictures.Insert(bin_root + '\logoSimSEE.jpg');
  aLogo.Select;

  aLogo.Height := 14;
  aLogo.Width := trunc(144 * 14 / 43 + 0.5);

  aLogo.Left := ha.PlotArea.InsideLeft + ha.PlotArea.InsideWidth - (1.2 * aLogo.Width);
  aLogo.Top := ha.PlotArea.InsideTop - (aLogo.Height / 6);

  (*
  aLogo.ShapeRange.IncrementLeft( 548.8317322835 );
  aLogo.ShapeRange.IncrementTop( 46.2616535433 );



  x_:= self.ha.PlotArea.left + self.ha.PlotArea.width;
  y_:= self.ha.PlotArea.top;
//  x_:= 0; y_:= 0;
  InsertarImagen( bin_root+'\logoSimSEE.png', x_, y_ );
     **)
  self.ha.ChartArea.Select;
  //  self.v.ActiveWindow.Zoom := true;
  //  v.ActiveWindow.Zoom:= 100;

  {$ENDIF}

  self.ha := htmp;
  Result := 'g' + nombreHoja;
end;

function T_ExcelFile.ReadFilaVect(
   Encab, Variable: string;
   offsetColVariable: integer; // Offset de la columna de la Variable respecto del Encabezado
   NCols: integer;
   offsetColDatos: integer; // columnas a saltear desde la variable
   defVal: double = 0;
   filIni: integer = 1;
   colIni: integer = 1;
   filFin: integer = 490;
   colFin: integer = 100;
   offsetFilDatos:integer = 0;
   offsetFilVariable:integer = 0): TVectR;
var
  res: TVectR;
  fila, columna: integer;
  s: string;
  r: double;
  rescod: integer;
  j: integer;
begin
  res:= TVectR.Create_init(NCols);
  if BuscaPal( fila, columna, Encab, filIni, ColIni, FilFin, ColFin ) then
    if BuscaPal( fila, columna, Variable, fila + offsetFilVariable , columna+ offsetColVariable, FilFin, ColFin ) then
    begin
        for j:= 1 to res.n do
        begin
          s:= ReadStr( fila+ offsetFilDatos, columna + offsetcolDatos + j  );
          s:= ExcelStr2Nreal(s);
          val( s, r, rescod );
          if rescod = 0 then
            res.pon_e(j, r )
          else
            res.pon_e(j, defVal );
        end;
    end;
  Result:=res;
end;

function T_ExcelFile.ReadColVect(
   Encab, Variable: string;
   offsetColVariable: integer; // Offset de la columna de la Variable respecto del Encabezado
   NFils: integer;
   offsetColDatos: integer; // columnas a saltear desde la variable
   defVal: double = 0;
   filIni: integer = 1;
   colIni: integer = 1;
   filFin: integer = 490;
   colFin: integer = 100;
   offsetFilDatos:integer = 0;
   offsetFilVariable:integer = 0): TVectR;
var
  res: TVectR;
  fila, columna: integer;
  s: string;
  r: double;
  rescod: integer;
  j: integer;
begin
  res:= TVectR.Create_init(Nfils);
  if BuscaPal( fila, columna, Encab, filIni, ColIni, FilFin, ColFin ) then
    if BuscaPal( fila, columna, Variable, fila + offsetFilVariable , columna+ offsetColVariable, FilFin, ColFin ) then
    begin
        for j:= 1 to res.n do
        begin
          s:= ReadStr( fila+ offsetFilDatos + j, columna + offsetcolDatos );
          s:= ExcelStr2Nreal(s);
          val( s, r, rescod );
          if rescod = 0 then
            res.pon_e(j, r )
          else
            res.pon_e(j, defVal );
        end;
    end;
  Result:=res;
end;

function T_ExcelFile.ReadColVect(Variable: string;
  NFils: integer; offsetFilDatos: integer;
  defVal: double; filIni: integer; colIni: integer; filFin: integer;
  colFin: integer): TVectR;
var
  res: TVectR;
  fila, columna: integer;
  s: string;
  r: double;
  rescod: integer;
  j: integer;
begin
  res:= nil;
    if BuscaPal( fila, columna, Variable, filini , colini, FilFin, ColFin ) then
    begin
        res:= TVectR.Create_init( NFils );
        for j:= 1 to res.n do
        begin
          s:= ReadStr( fila + offsetFilDatos + j, columna );
          val( s, r, rescod );
          if rescod = 0 then
            res.pon_e(j, r )
          else
            res.pon_e(j, defVal );
        end;
    end;
   Result:=res;
end;

end.
