unit uExcelFile;
{xDEFINE VATES_HML}
{$IFDEF LINUX}
{$DEFINE SIM_EXCEL}
{$ENDIF}

{xDEFINE FORM_LIBRO_SIMSEE}

{$DEFINE OLE_DIRECTO}

{xDEFINE SIM_EXCEL}
{xDEFINE FORM_LIBRO_SIMSEE}


{$IFDEF FORM_LIBRO_SIMSEE}
{$DEFINE SIM_EXCEL}
{$ENDIF}

{$IFDEF SIM_EXCEL}
{$UNDEF OLE_DIRECTO}
{$ENDIF}

interface

uses
  Classes,
  {$IFDEF WINDOWS}
  windows,
  shellapi,
  {$ENDIF}

{$IFDEF SIM_EXCEL}
  ugraficador,
  xmatdefs,
  ufechas,
  math,
  utiposbasicosplanilla,
  {$IFNDEF APLICACION_CONSOLA}
  uverdoc,
  {$ENDIF}
  {$IFDEF FORM_LIBRO_SIMSEE}
  forms,
  ulibroDeCalculo,
  {$ENDIF}
{$ELSE}
  {$IFDEF OLE_DIRECTO}
  u_ExcelFile,
  {$ENDIF}
{$ENDIF}
{$IFDEF FP_CANVAS}
  ucoloresbasicos,
{$ENDIF}
  SysUtils;



{$IFDEF SIM_EXCEL}
 const
  xlXYScatterLines = ord( TG_DispersionXY );
  xlAreaStacked = ord( TG_AreasApiladas );
  xlLineMarkers = ord( TG_Lineas );
  {$IFDEF SVG_CANVAS}
  IMG_WIDTH = 1260;
  IMG_HEIGHT = 600;
  {$ELSE}
  IMG_WIDTH = 1260;
  IMG_HEIGHT = 600;
  {$ENDIF}

{$IFNDEF FP_CANVAS}
 type
   TColor = -$7FFFFFFF - 1..$7FFFFFFF;

 const
   // special colors
   clNone    = TColor($1FFFFFFF);
   clDefault = TColor($20000000);
{$ENDIF}
 {$ELSE}

 {$IFNDEF OLE_DIRECTO}
 const
  dllexcel = 'dllexcel.dll';
  {$ENDIF}

{$ENDIF}

{$IFNDEF SIM_EXCEL}
type
  TRangoRec = record
    fila1, columna1, fila2, columna2: integer;
  end;
{$ENDIF}

type
 {$IFDEF OLE_DIRECTO}
       TExcelFile = T_ExcelFile;
 {$ELSE}
  TExcelFile = class
  public
    {$IFDEF SIM_EXCEL}
    archi: string;
    hojas: TList;
    graficos: TList;
    kHojaActiva: integer;
    kFila, jColumna: integer; // cursor
    rango: TRangoRec;
    {$IFDEF FORM_LIBRO_SIMSEE}
    libro: TLibroDeCalculo;
    {$ENDIF}
    {$ENDIF}

    function fila: integer;
    function columna: integer;

    function columnaBuffereada: integer;

    constructor Create(nombreHoja1: string; Visible: boolean;
      autocierre, avisocierre: boolean);
    procedure Guardar(nombre: string);

    {$IFNDEF SIM_EXCEL}
    procedure Abrir(nombArchivo: string);
    {$ENDIF}

    procedure agregoLibro;
    procedure agregoHoja(nombreHoja: string);
    procedure EscribirCeldaTexto(nombreHoja: string; fila: integer;
      columna: integer; contenido: string);

    procedure Cerrar(conAviso: boolean);
    procedure Free;
    procedure VisibleOn;
    procedure VisibleOff;

     {$IFDEF SIM_EXCEL}
     procedure AgregoGrafico( NuevoGrafico: TGrafico );
     function GetGraficoByName( nombre: string ): TGrafico;
     function GetHojaByName( nombre: string ): THoja;

     // lee el formato de la celda indicada sin alterar la posición
     // del cursor
     function ReadFormato( kFila, jColumna: integer ): shortstring;
    {$ENDIF}



    // agregado por comodidad.
    // Retorna TRE si encontró la hoja y la activó. FALSE si no la encontró.
    function ActivoHoja_nombre(nombreHoja: string): boolean;

    procedure ActivoHoja_numero(numeroHoja: integer);
    procedure ir(fila, columna: integer);
    procedure irr(dfila, dcolumna: integer);


    // leen un valor incrementando la posición del cursor
    function ReadV_Str: shortstring;
    function ReadV_Float: extended;
    function ReadV_Int: integer;

    // posicionan el cursor y llaman a una de las de arriba
    function ReadStr(fila, columna: integer): shortstring;
    function ReadFloat(fila, columna: integer): extended;
    function ReadInt(fila, columna: integer): integer;

    procedure readln;
    procedure go(NombreHoja: string; fila, columna: integer);
    (*.............................................................*)

    //Retorna la letra de la columna nroCol
    function nroColToExcelCol(nroCol: cardinal): string;

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

    procedure WriteBuffereado(val: shortString); overload;
    procedure WriteBuffereado(val: double); overload;
    procedure WriteBuffereado(val: integer); overload;

    procedure writelnBuffer; overload;
(*
   function ref(fila, columna: integer): string;
    function ref_rango(f1, c1, f2, c2: integer): string;
*)
    procedure SelRango(fil1, col1, fil2, col2: integer);
    procedure CambiarFormato(nuevoFormato: string);
    procedure autoFitCells;


    //Retorna true si el libro del TExcelFile esta abierto.
     //Si se cerro el EXCEL sin liberar el TExcelFile retorna false
    function libroAbierto: boolean;

    function contarFilasHastaBlanco: integer;
        function contarColumnasHastaBlanco: integer;


    procedure aplicarPropiedadesAGrafico(nombreHoja: shortstring;
      tipoGrafico: integer;
      titulo, ejeY: shortstring;
      minEjeYAuto, maxEjeYAuto: boolean;
      minEjeY, MaxEjeY: double;
      minEjeX, MaxEjeX: double; ejeX: shortstring='');


    procedure aplicarPropiedadesASerie(nombreHoja: shortstring;
      iSerie: integer; //1..nSeries
      tipoGraficoPrincipal, tipoGrafico: integer;
      eje: integer;
      color: TColor);

    function graficar(nombreHoja: shortstring;
      colIni, colFin, filaIni, filaFin: integer): shortstring;

    function graficarXY(nombreHoja: shortstring;
       colIni, colFin, filaIni, filaFin,nSeries_ejex: integer): shortstring;

  end;
{$ENDIF}

// forma el string de formato numérico
function xf_formatoStr(ndecimales: integer): shortstring;


//QUita caracteres raros del nombre de la hora y lo limita en espacio.
// para evitar lios con Excel.
function PurificarNombreHoja( nombreHoja: String ): string;


implementation

{$IFDEF SIM_EXCEL}
var
  LibroActivo: TExcelFile;
{$ENDIF}




//QUita caracteres raros del nombre de la hora y lo limita en espacio.
function PurificarNombreHoja( nombreHoja: String ): string;
var
  k: integer;
  c: char;
  res: string;
begin
  res:= '';
  for k:= 1 to length( nombreHoja ) do
  begin
    c:= nombreHoja[k];
    case c of
      '0'..'9', 'a'..'z', 'A'..'Z': res:= res + c;
      ' ', '_', '-', '.',':', '$':
        if length( res ) > 0 then
        begin
           if res[length(res)] <> '_' then
              res:= res+'_';
        end;
    end;
  end;

  if  length( res ) > 25 then
    result:= copy( res, 1, 25 )
  else
    result:= res;
end;


// forma el string de formato numérico
function xf_formatoStr(ndecimales: integer): shortstring;
var
  res: string;
  k:   integer;
begin
  if ndecimales <= 0 then
    Result := '0'
  else
  begin
    res := '';
    for k := 1 to ndecimales do
      res  := res + '0';
    res    := '0' + SysUtils.decimalseparator + res;
    Result := res;
  end;
end;


{$IFNDEF SIM_EXCEL}
{$IFNDEF OLE_DIRECTO}
procedure xf_alinicio; external dllexcel;
procedure xf_alfinal; external dllexcel;

function xf_fila: integer; external dllexcel;
function xf_columna: integer; external dllexcel;
function xf_columnaBuffereada: integer; external dllexcel;

function xf_Create(nombreHoja1: shortstring; Visible: boolean;
  autocierre, avisocierre: boolean): integer; external dllexcel;
procedure xf_Guardar(nombre: shortstring); external dllexcel;
procedure xf_Abrir(nombArchivo: shortstring); external dllexcel;
procedure xf_agregolibro; external dllexcel;
procedure xf_agregoHoja(nombreHoja: shortstring); external dllexcel;
procedure xf_EscribirCeldaTexto(nombreHoja: shortstring; fila: integer;
  columna: integer; contenido: shortstring); external dllexcel;
procedure xf_Cerrar(conAviso: boolean); external dllexcel;
procedure xf_Free; external dllexcel;
procedure xf_VisibleOn; external dllexcel;
procedure xf_VisibleOff; external dllexcel;
procedure xf_ActivoHoja_nombre(nombreHoja: shortstring); external dllexcel;
procedure xf_ActivoHoja_numero(numeroHoja: integer); external dllexcel;
procedure xf_ir(fila, columna: integer); external dllexcel;
procedure xf_irr(dfila, dcolumna: integer); external dllexcel;

function xf_ReadV_str: shortstring; external dllexcel;
function xf_ReadV_float: extended; external dllexcel;
function xf_ReadV_int: integer; external dllexcel;

procedure xf_readln; external dllexcel;
procedure xf_go(NombreHoja: shortstring; fila, columna: integer); external dllexcel;
function xf_nroColToExcelCol(nroCol: cardinal): shortstring; external dllexcel;

procedure xf_write_str(val: shortstring); external dllexcel;
procedure xf_write_float(val: extended); external dllexcel;
procedure xf_write_int(val: integer); external dllexcel;

procedure xf_WriteF_str(contenido: shortstring; formato: shortstring);
  external dllexcel;
procedure xf_WriteF_float(contenido: extended; formato: shortstring);
  external dllexcel;
procedure xf_WriteF_int(contenido: integer; formato: shortstring); external dllexcel;
procedure xf_WriteMAF_str(contenido: shortstring; celdas: integer;
  alineacion: integer; formato: shortstring); external dllexcel;
procedure xf_WriteMAF_float(contenido: extended; celdas: integer;
  alineacion: integer; formato: shortstring); external dllexcel;
procedure xf_WriteMAF_int(contenido: integer; celdas: integer;
  alineacion: integer; formato: shortstring); external dllexcel;

procedure xf_writeln; external dllexcel;

procedure xf_write_str_buffereado(val: shortstring); external dllexcel;
procedure xf_write_float_buffereado(val: extended); external dllexcel;
procedure xf_write_int_buffereado(val: integer); external dllexcel;

procedure xf_writeln_buffereado; external dllexcel;

function xf_ref(fila, columna: integer): shortstring; external dllexcel;
function xf_ref_rango(f1, c1, f2, c2: integer): shortstring; external dllexcel;
procedure xf_SelRango(fil1, col1, fil2, col2: integer); external dllexcel;
procedure xf_BordeSimple(ancho: integer;
  Arriba, Derecha, Abajo, Izquierda, InteriorVertical, InteriorHorizontal: boolean);
  external dllexcel;
procedure xf_CambiarFuente(nuevafuente: shortstring); external dllexcel;
procedure xf_CambiarTamFuente(nuevotam: integer); external dllexcel;
procedure xf_CambiarColorFuente_ci(nuevoci: integer); external dllexcel;
procedure xf_CambiarColorFondo_ci(nuevoci: integer); external dllexcel;
procedure xf_CambiarColorFuente_cl(nuevoCol: TColor); external dllexcel;
procedure xf_CambiarColorFondo_cl(nuevoCol: TColor); external dllexcel;
procedure xf_CambiarFormato(nuevoFormato: shortstring); external dllexcel;
procedure xf_CambiarAncho(nuevoAncho: integer); external dllexcel;
procedure xf_CambiarAlto(nuevoAlto: integer); external dllexcel;
procedure xf_CambiarFormula(nuevaFormula: shortstring); external dllexcel;
procedure xf_CombinarCeldas; external dllexcel;
procedure xf_AlinearDerecha; external dllexcel;
procedure xf_AlinearIzquierda; external dllexcel;
procedure xf_AlinearCentro; external dllexcel;
procedure xf_WrapTextON; external dllexcel;
procedure xf_WrapTextOFF; external dllexcel;
procedure xf_BoldON; external dllexcel;
procedure xf_BoldOFF; external dllexcel;
procedure xf_InsertarImagen(archi: shortstring; x, y: integer); external dllexcel;
procedure xf_Zoom(porciento: integer); external dllexcel;
procedure xf_SetPage(PaginaVertical: boolean); external dllexcel;
procedure xf_autoFitCells; external dllexcel;
function xf_libroAbierto: boolean; external dllexcel;
function xf_contarFilasHastaBlanco: integer; external dllexcel;
function xf_contarColumnasHastaBlanco: integer; external dllexcel;
function xf_version: double; external dllexcel;



function TExcelFile.fila: integer;
begin
  Result := xf_fila;
end;

function TExcelFile.columna: integer;
begin
  Result := xf_columna;
end;

function TExcelFile.columnaBuffereada: integer;
begin
  Result := xf_columnaBuffereada;
end;

constructor TExcelFile.Create(nombreHoja1: string; Visible: boolean;
  autocierre, avisocierre: boolean);
begin
  xf_Create( PurificarNombreHoja( NombreHoja1 ), Visible, autocierre, avisocierre);
end;

procedure TExcelFile.Guardar(nombre: string);
begin
  xf_Guardar(nombre );
end;


procedure TExcelFile.Abrir(nombArchivo: string);
begin
  xf_Abrir(nombArchivo);
end;


procedure TExcelFile.agregoLibro;
begin
  xf_agregoLibro;
end;

procedure TExcelFile.agregoHoja(nombreHoja: string);
begin
  xf_agregoHoja( PurificarNombreHoja( nombreHoja) );
end;

procedure TExcelFile.EscribirCeldaTexto(nombreHoja: string; fila: integer;
  columna: integer; contenido: string);
begin
  xf_EscribirCeldaTexto( PurificarNombreHoja(nombreHoja ), fila, columna, contenido);
end;

procedure TExcelFile.Cerrar(conAviso: boolean);
begin
  xf_Cerrar(conAviso);
end;

procedure TExcelFile.Free;
begin
  xf_Free;
end;

procedure TExcelFile.VisibleOn;
begin
  xf_VisibleOn;
end;

procedure TExcelFile.VisibleOff;
begin
  xf_VisibleOff;
end;

function TExcelFile.ActivoHoja_nombre(nombreHoja: string):boolean;
begin
  xf_ActivoHoja_nombre( PurificarNombreHoja( nombreHoja) );
  result:= true;
end;

procedure TExcelFile.ActivoHoja_numero(numeroHoja: integer);
begin
  xf_ActivoHoja_numero(numeroHoja);
end;

procedure TExcelFile.ir(fila, columna: integer);
begin
  xf_ir(fila, columna);
end;

procedure TExcelFile.irr(dfila, dcolumna: integer);
begin
  xf_irr(dfila, dcolumna);
end;


function TExcelFile.ReadV_Str: shortstring;
begin
  Result := xf_readv_str;
end;

function TExcelFile.ReadV_Float: extended;
begin
  Result := xf_readv_float;
end;

function TExcelFile.ReadV_Int: integer;
begin
  Result := xf_readv_int;
end;

procedure TExcelFile.readln;
begin
  xf_readln;
end;

function TExcelFile.ReadStr(fila, columna: integer): shortstring;
begin
  ir(fila, columna);
  Result := ReadV_str;
end;

function TExcelFile.ReadFloat(fila, columna: integer): extended;
begin
  ir(fila, columna);
  Result := ReadV_Float;
end;

function TExcelFile.ReadInt(fila, columna: integer): integer;
begin
  ir(fila, columna);
  Result := ReadV_Int;
end;




procedure TExcelFile.go(NombreHoja: string; fila, columna: integer);
begin
  xf_go( PurificarNombreHoja( nombreHoja ), fila, columna);
end;

function TExcelFile.nroColToExcelCol(nroCol: cardinal): string;
begin
  Result := xf_nroColToExcelCol(nroCol);
end;

procedure TExcelFile.Write(val: shortString);
begin
  xf_write_str(val);
end;

procedure TExcelFile.Write(val: extended);
begin
  xf_write_float(val);
end;

procedure TExcelFile.Write(val: integer);
begin
  xf_write_int(val);
end;


procedure TExcelFile.Write(fila, columna: integer; val: shortString);
begin
  ir(fila, columna);
  Write(val);
end;

procedure TExcelFile.Write(fila, columna: integer; val: extended);
begin
  ir(fila, columna);
  Write(val);
end;

procedure TExcelFile.Write(fila, columna: integer; val: integer);
begin
  ir(fila, columna);
  Write(val);
end;


procedure TExcelFile.writeln;
begin
  xf_writeln;
end;

(*
procedure TExcelFile.WriteF(contenido: shortstring; formato: shortstring);
begin
  xf_WriteF_str(contenido, formato);
end;

procedure TExcelFile.WriteF(contenido: extended; formato: shortstring);
begin
  xf_WriteF_float(contenido, formato);
end;

procedure TExcelFile.WriteF(contenido: integer; formato: shortstring);
begin
  xf_WriteF_int(contenido, formato);
end;

procedure TExcelFile.WriteMAF(contenido: shortstring; celdas: integer;
  alineacion: integer; formato: shortstring);
begin
  xf_WriteMAF_str(contenido, celdas, alineacion, formato);
end;

procedure TExcelFile.WriteMAF(contenido: extended; celdas: integer;
  alineacion: integer; formato: shortstring);
begin
  xf_WriteMAF_float(contenido, celdas, alineacion, formato);
end;

procedure TExcelFile.WriteMAF(contenido: integer; celdas: integer;
  alineacion: integer; formato: shortstring);
begin
  xf_WriteMAF_int(contenido, celdas, alineacion, formato);
end;
*)
procedure TExcelFile.Write_buffereado(val: shortString);
begin
  xf_write_str_buffereado(val);
end;

procedure TExcelFile.Write_buffereado(val: double);
begin
  xf_write_float_buffereado(val);
end;

procedure TExcelFile.Write_buffereado(val: integer);
begin
  xf_write_int_buffereado(val);
end;

procedure TExcelFile.writelnBuffer;
begin
  xf_writeln_buffereado;
end;

procedure TExcelFile.writeln(val: shortstring);
begin
  Write(val);
  writeln;
end;

procedure TExcelFile.writeln(val: double);
begin
  Write(val);
  writeln;
end;

procedure TExcelFile.writeln(val: integer);
begin
  Write(val);
  writeln;
end;



(*
function TExcelFile.ref(fila, columna: integer): string;
begin
  Result := xf_ref(fila, columna);
end;

function TExcelFile.ref_rango(f1, c1, f2, c2: integer): string;
begin
  Result := xf_ref_rango(f1, c1, f2, c2);
end;
  *)
procedure TExcelFile.SelRango(fil1, col1, fil2, col2: integer);
begin
  xf_selRango(fil1, col1, fil2, col2);
end;

(*
procedure TExcelFile.BordeSimple(ancho: integer;
  Arriba, Derecha, Abajo, Izquierda,
  InteriorVertical, InteriorHorizontal: boolean);
begin
  xf_BordeSimple(ancho, arriba, derecha, abajo, izquierda, InteriorVertical,
    InteriorHorizontal);
end;

procedure TExcelFile.CambiarFuente(nuevafuente: string);
begin
  xf_CambiarFuente(nuevafuente);
end;

procedure TExcelFile.CambiarTamFuente(nuevotam: integer);
begin
  xf_CambiarTamFuente(nuevoTam);
end;

procedure TExcelFile.CambiarColorFuente_ci(nuevoci: integer);
begin
  xf_CambiarColorFuente_ci(nuevoci);
end;

procedure TExcelFile.CambiarColorFondo_ci(nuevoci: integer);
begin
  xf_CambiarColorFondo_ci(nuevoci);
end;

procedure TExcelFile.CambiarColorFuente_cl(nuevoCol: TColor);
begin
  xf_CambiarColorFuente_cl(nuevoCol);
end;

procedure TExcelFile.CambiarColorFondo_cl(nuevoCol: TColor);
begin
  xf_CambiarColorFondo_cl(nuevoCol);
end;
*)

procedure TExcelFile.CambiarFormato(nuevoFormato: string);
begin
  xf_CambiarFormato(nuevoFormato);
end;

(*
procedure TExcelFile.CambiarAncho(nuevoAncho: integer);
begin
  xf_CambiarAncho(nuevoAncho);
end;

procedure TExcelFile.CambiarAlto(nuevoAlto: integer);
begin
  xf_CambiarAlto(nuevoAlto);
end;

procedure TExcelFile.CambiarFormula(nuevaFormula: string);
begin
  xf_CambiarFormula(nuevaFormula);
end;

procedure TExcelFile.CombinarCeldas;
begin
  xf_CombinarCeldas;
end;

procedure TExcelFile.AlinearDerecha;
begin
  xf_AlinearDerecha;
end;

procedure TExcelFile.AlinearIzquierda;
begin
  xf_AlinearIzquierda;
end;
  *)
procedure TExcelFile.autoFitCells;
begin
  xf_autoFitCells;
end;

(*
procedure TExcelFile.AlinearCentro;
begin
  xf_AlinearCentro;
end;

procedure TExcelFile.WrapTextON;
begin
  xf_WrapTextOn;
end;

procedure TExcelFile.WrapTextOFF;
begin
  xf_WrapTextOff;
end;

procedure TExcelFile.BoldON;
begin
  xf_BoldOn;
end;

procedure TExcelFile.BoldOFF;
begin
  xf_BoldOff;
end;

procedure TExcelFile.InsertarImagen(archi: string; x, y: integer);
begin
  xf_InsertarImagen(archi, x, y);
end;

procedure TExcelFile.Zoom(porciento: integer);
begin
  xf_Zoom(porciento);
end;

procedure TExcelFile.SetPage(PaginaVertical: boolean);
begin
  xf_SetPage(PaginaVertical);
end;

*)

function TExcelFile.libroAbierto: boolean;
begin
  Result := xf_LibroAbierto;
end;

function TExcelFile.contarFilasHastaBlanco: integer;
begin
  Result := xf_contarFilasHastaBlanco;
end;

function TExcelFile.contarColumnasHastaBlanco: integer;
begin
  Result := xf_contarColumnasHastaBlanco;
end;

(*
function TExcelFile.version: double;
begin
  Result := Version;
end;

*)



procedure xf_aplicarPropiedadesAGrafico(nombreHoja: shortstring;
  tipoGrafico: integer;
  titulo, ejeY: shortstring;
  minEjeYAuto, maxEjeYAuto: boolean;
  minEjeY, MaxEjeY: double;
  minEjeX, MaxEjeX: double); external dllexcel;


procedure xf_aplicarPropiedadesASerie(nombreHoja: shortstring;
  iSerie: integer; //1..nSeries
  tipoGraficoPrincipal, tipoGrafico: integer;
  eje: integer;
  color: TColor); external dllexcel;

function xf_graficar(nombreHoja: shortstring;
  colIni, colFin, filaIni, filaFin: integer): shortstring;
  external dllexcel;




initialization
  xf_AlInicio;

finalization
  xf_AlFinal;
  {$ENDIF}
{$ELSE}

(*****
Métodos de TExcelFile
****)

function TExcelFile.fila: integer;
begin
  result:= self.kFila;
end;

function TExcelFile.columna: integer;
begin
  result:= self.jColumna;
end;



constructor TExcelFile.Create(nombreHoja1: string; Visible: boolean;
  autocierre, avisocierre: boolean);
var
  hoja1: THoja;
begin
  inherited Create;

  {$IFDEF FORM_LIBRO_SIMSEE}
  Application.CreateForm(TLibroDeCalculo, libro);
  libro.tab_hojas.Tabs.Clear;
  libro.Inicializar;
  libro.pdatos:= self;
  {$ENDIF}

  self.hojas:= TList.Create;
  self.graficos:= TList.Create;
  hoja1:= THoja.Create( nombreHoja1 );
  agregoHoja( nombreHoja1 );
  kHojaActiva:= 1;
  kFila:= 1;
  jColumna:= 1;
  LibroActivo:= self;
end;


{$IFDEF VATES_HML}

procedure TExcelFile.Guardar(nombre: string);
var
  f_index: textfile;
  f: textfile;
  carpeta: string;
  archi_hoja: string;

  hojaActiva: THoja;

  NHojas: integer;
  NFilas: integer;
  NColumnas: integer;

  kHoja, kFila, jColumna: integer;
  kGrafico: integer;
  aGrafico: TGrafico;
  icol: integer;
  url: string;
  ext: string;

begin
  self.archi:= nombre;
  ext:= ExtractFileExt( nombre );
  carpeta:= copy( nombre,1, length( nombre ) - length( ext ) );

  carpeta:= carpeta+'_resultados_';

  if not DirectoryExists( carpeta ) then
   if not CreateDir( carpeta )
      then Raise Exception.Create( 'Error!. no es posible crear la carpeta: '+carpeta);

  assignfile( f_index, carpeta + sysutils.PathDelim+'index.html' );
  rewrite( f_index );


  NHojas:= hojas.Count;
  system.writeln( f_index, '<hr>Fecha: <input type="text" width="30" id="fecha" name="fecha" value="'+DateTimeToStr( now )+'"><br>' );

  system.writeln( f_index, '<hr>' );
  for kGrafico:= 0 to graficos.count -1 do
  begin
    aGrafico:= graficos[kGrafico];
    {$IFDEF SVG_CANVAS}
    archi_hoja:= carpeta + sysutils.PathDelim + 'grafico_'+aGrafico.nombre+'.svg';
    system.WriteLn( archi_hoja );
    aGrafico.SaveSVG( archi_hoja, IMG_WIDTH, IMG_HEIGHT );
    url:= 'grafico_'+aGrafico.nombre+'.svg';
    {$ELSE}
    archi_hoja:= carpeta + sysutils.PathDelim + 'grafico_'+aGrafico.nombre+'.jpg';
    system.WriteLn( archi_hoja );
    aGrafico.SaveJPG( archi_hoja, IMG_WIDTH, IMG_HEIGHT );
    url:= 'grafico_'+aGrafico.nombre+'.jpg';
    {$ENDIF}


    if kGrafico = 0 then
    begin
        system.writeln( f_index, '<img name="grafico" id="grafico" src="'+url+'"'
        +' width="80%" height="80%"><hr>' );
        system.writeln( f_index, '<script language="javascript"> ');

        system.writeln( f_index, 'url_img = "'+url+'";');

        system.writeln( f_index, 'function loadimg( nombre ){ ');
        system.writeln( f_index, '  var img = document.getElementById( ''grafico'' ); ' );
        system.writeln( f_index, '  img.src=nombre; url_img= nombre; ');
        system.writeln( f_index, '} ');

        system.writeln( f_index, 'function refrescar(){ ');
        system.writeln( f_index, '  var img = document.getElementById( ''grafico'' ); ' );
        system.writeln( f_index, '  img.src=url_img+''?rand='' + Math.random(); ');
        system.writeln( f_index, ' var e = document.getElementById( ''fecha'' ); ' );
        system.writeln( f_index, ' e.value = Date(); ');

        system.writeln( f_index, '  setTimeout( refrescar, 1000*60 ); } ');

        system.writeln( f_index, ' setTimeout( refrescar, 1000*60 );' );
        system.writeln( f_index, '</script>');

    end;

    system.writeln( f_index, '| <a href="javascript:loadimg('''+url+''');">'+aGrafico.nombre+'</a>' );
  end;
  closefile( f_index );

  {$IFNDEF APLICACION_CONSOLA}
  abrir_url(  carpeta + sysutils.PathDelim+'index.html' );
  {$ENDIF}
end;

{$ELSE}
procedure TExcelFile.Guardar(nombre: string);
var
  f_index: textfile;
  f: textfile;
  carpeta: string;
  archi_hoja: string;

  hojaActiva: THoja;

  NHojas: integer;
  NFilas: integer;
  NColumnas: integer;

  kHoja, kFila, jColumna: integer;
  kGrafico: integer;
  aGrafico: TGrafico;
  icol: integer;
  url: string;
  ext: string;

begin

  self.archi:= nombre;
  ext:= ExtractFileExt( nombre );
  carpeta:= copy( nombre,1, length( nombre ) - length( ext ) );

  carpeta:= carpeta+'_resultados_';

  if not DirectoryExists( carpeta ) then
   if not CreateDir( carpeta )
      then Raise Exception.Create( 'Error!. no es posible crear la carpeta: '+carpeta);

  assignfile( f_index, carpeta + sysutils.PathDelim+'index.html' );
  rewrite( f_index );

  NHojas:= hojas.Count;
  system.writeln( f_index, '<hr>Datos: <br>' );
  system.writeln( f_index, '<table cellpading="4" border="1">' );
  icol:= 0;

  for kHoja:= 2 to NHojas do
  begin
    ActivoHoja_numero( kHoja );
    hojaActiva:= self.hojas[kHoja-1];
    NFilas:= hojaActiva.NFilas;
    NColumnas:= hojaActiva.NColumnas;

    archi_hoja:= carpeta + sysutils.PathDelim + 'hoja_'+hojaActiva.nombre+'.xlt';

    if icol= 0 then
      system.writeln( f_index, '<tr> ');
    system.write( f_index,  '<td>' );
    system.writeln( f_index, '<a href="hoja_'+hojaActiva.nombre+'.xlt">'+hojaActiva.nombre+'</a>' );
    system.write( f_index,  '</td>' );

    inc( icol );
    if icol = 4 then
    begin
      icol:= 0;
      system.writeln( f_index, '</tr>' );
    end;

    assignfile( f, archi_hoja );
    rewrite( f );

    if NColumnas > 0 then
    begin
      for kFila:= 1 to NFilas  do
      begin
          system.write( f, hojaActiva.ReadStr( kFila, 1 ) );
          for jColumna:= 2 to NColumnas do
              system.write( f, #9, hojaActiva.ReadStr( kFila, jColumna ) );
          system.writeln( f );
      end;
    end;

    closefile( f );
  end;

  while icol <> 0 do
  begin
    inc( icol );
    system.writeln( f_index, '<td>&nbsp;</td>' );
    if icol = 4 then
    begin
      icol:= 0;
      system.writeln( f_index, '</tr>' );
    end;
  end;

  system.writeln( f_index, '</table>' );

  icol:= 0;

  system.writeln( f_index, '<hr>Gráficos: <br>' );
  system.writeln( f_index, '<table  cellpading="4" border="1">' );

  for kGrafico:= 0 to graficos.count -1 do
  begin
    if icol = 0 then
      system.writeln( f_index, '<tr> ');
    system.write( f_index,  '<td>' );
    aGrafico:= graficos[kGrafico];

    {$IFDEF SVG_CANVAS}
    archi_hoja:= carpeta + sysutils.PathDelim + 'grafico_'+aGrafico.nombre+'.svg';
    system.WriteLn( archi_hoja );
    aGrafico.SaveSVG( archi_hoja, IMG_WIDTH, IMG_HEIGHT );
    url:= 'grafico_'+aGrafico.nombre+'.svg';
    system.writeln( f_index, '<a href="'+url+'"><img src="'+url+'" width="'
     + IntToStr(trunc( IMG_WIDTH / 4.0+0.5))
     +'" height="'+ IntToStr( trunc( IMG_HEIGHT / 4.0+0.5)) +'"></a>' );

    {$ELSE}
    archi_hoja:= carpeta + sysutils.PathDelim + 'grafico_'+aGrafico.nombre+'.jpg';
    system.WriteLn( archi_hoja );
    aGrafico.SaveJPG( archi_hoja, IMG_WIDTH, IMG_HEIGHT );
    url:= 'grafico_'+aGrafico.nombre+'.jpg';
    system.writeln( f_index, '<a href="'+url+'"><img src="'+url+'" width="'
     + IntToStr(trunc( IMG_WIDTH / 4.0+0.5))
     +'" height="'+ IntToStr( trunc( IMG_HEIGHT / 4.0+0.5)) +'"></a>' );

    {$ENDIF}
    system.writeln( f_index, '</td>' );
    inc( icol );
    if icol = 4 then
    begin
      icol:= 0;
      system.writeln( f_index, '</tr>' );
    end;
  end;

  while icol <> 0 do
  begin
    inc( icol );
    system.writeln( f_index, '<td>&nbsp;</td>' );
    if icol = 4 then
    begin
      icol:= 0;
      system.writeln( f_index, '</tr>' );
    end;
  end;
  system.writeln( f_index, '</table>' );

  closefile( f_index );
  {$IFNDEF APLICACION_CONSOLA}
  abrir_url(  carpeta + sysutils.PathDelim+'index.html' );
  {$ENDIF}
end;

{$ENDIF}

(*
procedure TExcelFile.Abrir(nombArchivo: string);
*)

procedure TExcelFile.agregoLibro;
begin
  // por ahora nada
end;

procedure TExcelFile.agregoHoja(nombreHoja: string);
var
  hoja: THoja;
begin
  hoja:= THoja.Create( PurificarNombreHoja(nombreHoja) );
  hojas.Add( hoja );
  kHojaActiva:= hojas.count;
  kFila:= 1;
  jColumna:= 1;
  {$IFDEF FORM_LIBRO_SIMSEE}
  libro.AddHoja( hoja.nombre );
  libro.aHoja:= hoja;
  hoja.kTabEnLibro:= libro.tab_hojas.tabs.Count -1;
  {$ENDIF}
end;



procedure TExcelFile.EscribirCeldaTexto(nombreHoja: string; fila: integer;
  columna: integer; contenido: string);
begin
  ActivoHoja_nombre( nombreHoja );
  Write( fila, columna, contenido );
end;

procedure TExcelFile.Cerrar(conAviso: boolean);
begin
//  Guardar( archi );
  Free;
end;

procedure TExcelFile.Free;
var
  kHoja: integer;
begin
  for kHoja:= 0 to hojas.count -1 do
    THoja( hojas[kHoja] ).free;
  hojas.Free;
  {$IFDEF FORM_LIBRO_SIMSEE}
  if libro <> nil then
  begin
    libro.Close;
    libro.Free;
  end;
  {$ENDIF}
  inherited Free;
end;

procedure TExcelFile.VisibleOn;
begin
  // cuando pueda que habra un FORM y muestre libro
  {$IFDEF FORM_LIBRO_SIMSEE}
  libro.ShowOnTop;
  {$ENDIF}
end;


procedure TExcelFile.VisibleOff;
begin
  // si el form está abierto lo cierra.
  {$IFDEF FORM_LIBRO_SIMSEE}
  libro.Hide;
  {$ENDIF}
end;

procedure TExcelFile.AgregoGrafico( NuevoGrafico: TGrafico );
begin
  graficos.add( NuevoGrafico );
  {$IFDEF FORM_LIBRO_SIMSEE}
  libro.AddGrafico( NuevoGrafico.nombre );
  NuevoGrafico.kEnLibro:= libro.tab_hojas.Tabs.Count-1;
  {$ENDIF}
end;


function TExcelFile.GetGraficoByName( nombre: string ): TGrafico;
var
  buscando: boolean;
  k: integer;
  aGrafico: TGrafico;
begin
  buscando:= true;
  k:= 0;
  for k:= 0 to graficos.count -1 do
  begin
    aGrafico:= graficos[k];
    if aGrafico.nombre = nombre then
    begin
      buscando:= false;
      break;
    end;
  end;
  if buscando then
    result:= nil
  else
    result:= aGrafico;
end;


function TExcelFile.GetHojaByName( nombre: string ): THoja;
var
  buscando: boolean;
  k: integer;
  aHoja: THoja;
begin
  buscando:= true;
  k:= 0;
  for k:= 0 to hojas.count -1 do
  begin
    aHoja:= hojas[k];
    if aHoja.nombre = nombre then
    begin
      buscando:= false;
      break;
    end;
  end;
  if buscando then
    result:= nil
  else
    result:= aHoja;
end;



// agregado por comodidad.
function TExcelFile.ActivoHoja_nombre(nombreHoja: string): boolean;
var
  buscando: boolean;
  k: integer;
  aHoja: THoja;
  nombreHoja_Purificado: string;
begin
  nombreHoja_Purificado:= PurificarNombreHoja( nombreHoja );
  buscando:= true;
  k:= 0;
  while buscando and ( k < hojas.count ) do
  begin
    aHoja:= hojas[k];
    if ( aHoja.Nombre = nombreHoja_Purificado ) then
      buscando:= false
    else
      inc( k );
  end;
  if buscando then
    result:= false
  else
  begin
    ActivoHoja_numero( k+1 );
    result:= true
  end;
end;

procedure TExcelFile.ActivoHoja_numero(numeroHoja: integer);
begin
  kHojaActiva:= numeroHoja;
  kFila:= 1;
  jColumna:= 1;
  {$IFDEF FORM_LIBRO_SIMSEE}
  if libro <> nil then
    libro.tab_hojas.TabIndex:= THoja( hojas[ kHojaActiva-1] ).kTabEnLibro;
  {$ENDIF}
end;


procedure TExcelFile.ir(fila, columna: integer);
begin
  kFila:= fila;
  jColumna:= columna;
end;

procedure TExcelFile.irr(dfila, dcolumna: integer);
begin
  kFila:= kFila + dfila;
  jColumna:= jColumna + dcolumna;
end;

function TExcelFile.ReadFormato( kFila, jColumna: integer ): shortstring;
var
  s: string;
  hoja: THoja;
begin
  hoja:= hojas[kHojaActiva - 1 ];
  s:= hoja.ReadFormato( kFila, jColumna );
  result:= s;
end;

function TExcelFile.ReadV_Str: shortstring;
var
  s: string;
  hoja: THoja;
begin
  hoja:= hojas[kHojaActiva - 1 ];
  s:= hoja.ReadStr( kFila, jColumna );
  inc( jColumna );
  result:= s;
end;

function TExcelFile.ReadV_Float: extended;
var
  s: string;
begin
  s:= ReadV_Str;
  try
    try
     result:= StrToFloat( s );
    except
       if pos( '-', s ) > 4 then
         result:= ISOStrToDateTime( s )
       else if pos( '/', s ) > 1 then
         result:= ufechas.StrToDateTime( s )
       else
        raise Exception.Create( 'Error de conversión: *'+s+'* no es un NReal' );
    end;
  except
     raise Exception.Create( 'Error de conversión: *'+s+'* no es un NReal' );
  end;
end;

function TExcelFile.ReadV_Int: integer;
begin
  result:= StrToInt( ReadV_Str );
end;

function TExcelFile.ReadStr(fila, columna: integer): shortstring;
begin
  kFila:= fila;
  jColumna:= columna;
  result:= self.ReadV_Str;
end;

function TExcelFile.ReadFloat(fila, columna: integer): extended;
begin
  kFila:= fila;
  jColumna:= columna;
  result:= self.ReadV_Float;
end;

function TExcelFile.ReadInt(fila, columna: integer): integer;
begin
  kFila:= fila;
  jColumna:= columna;
  result:= self.ReadV_Int;
end;

procedure TExcelFile.readln;
begin
  inc( kFila );
  jColumna:= 1;
end;

procedure TExcelFile.go(NombreHoja: string; fila, columna: integer);
begin
  ActivoHoja_nombre( nombreHoja );
  ir( fila, columna );
end;

(*.............................................................*)

//Retorna la letra de la columna nroCol
function TExcelFile.nroColToExcelCol(nroCol: cardinal): string;
var
  res: string;
  digito, resto: integer;
  letraDigito: char;
begin
  resto:= nroCol-1;
  res:= '';
  repeat
    digito:= resto  mod 26;
    letraDigito:= Chr( Ord('A')+ digito );
    res:= letraDigito + res;
    resto:= resto div 26
  until resto = 0;
  result:= res;
end;

procedure TExcelFile.Write(val: shortString);
var
  hoja: THoja;
begin
  hoja:= hojas[kHojaActiva - 1 ];
  hoja.Write( kFila, jColumna, val );
  {$IFDEF FORM_LIBRO_SIMSEE}
  if libro <> nil then
     libro.grid_.Cells[ jColumna, kFila]:= hoja.ReadEvalStr( kFila, jColumna);
  {$ENDIF}
  inc( jColumna );
end;

procedure TExcelFile.Write(val: extended);
var
  hoja: THoja;
begin
  hoja:= hojas[kHojaActiva - 1 ];
  hoja.Write( kFila, jColumna, val );
  {$IFDEF FORM_LIBRO_SIMSEE}
  if libro <> nil then
    libro.grid_.Cells[ jColumna, kFila]:= FloatToStr( val );
  {$ENDIF}
  inc( jColumna );
end;

procedure TExcelFile.Write(val: integer);
var
  hoja: THoja;
begin
  hoja:= hojas[kHojaActiva - 1 ];
  hoja.Write( kFila, jColumna, val );
  {$IFDEF FORM_LIBRO_SIMSEE}
  if libro <> nil then
    libro.grid_.Cells[ jColumna, kFila]:= IntToStr( val );
  {$ENDIF}
  inc( jColumna );
end;

{$IFDEF SIM_EXCEL}

function TExcelFile.columnaBuffereada: integer;
begin
  result:= jColumna;
end;

procedure TExcelFile.WriteBuffereado(val: shortString);
begin
  write(val);
end;

procedure TExcelFile.WriteBuffereado(val: double);
begin
  write(val);
end;

procedure TExcelFile.WriteBuffereado(val: integer);
begin
  write(val);
end;

procedure TExcelFile.writelnBuffer;
begin
  writeln;
end;
{$ENDIF}


procedure TExcelFile.Write(fila, columna: integer; val: shortString);
begin
  kFila:= fila;
  jColumna:= columna;
  write( val );
end;

procedure TExcelFile.Write(fila, columna: integer; val: extended);
begin
  kFila:= fila;
  jColumna:= columna;
  write( val );
end;

procedure TExcelFile.Write(fila, columna: integer; val: integer);
begin
  kFila:= fila;
  jColumna:= columna;
  write( val );
end;

(*

procedure TExcelFile.WriteF(contenido: shortstring; formato: shortstring);

procedure TExcelFile.WriteF(contenido: extended; formato: shortstring);
var
  s: string;
begin
  s:= FloatToStrF( contenido, FFGeneral, 12, 2 );
  write( s );
end;

procedure TExcelFile.WriteF(contenido: integer; formato: shortstring);

procedure TExcelFile.WriteMAF(contenido: shortstring; celdas: integer;
  alineacion: integer; formato: shortstring); overload;
procedure TExcelFile.WriteMAF(contenido: extended; celdas: integer;
  alineacion: integer; formato: shortstring); overload;
procedure TExcelFile.WriteMAF(contenido: integer; celdas: integer;
  alineacion: integer; formato: shortstring); overload;

  *)

procedure TExcelFile.writeln(val: shortstring);
begin
  write( val );
  writeln;
end;

procedure TExcelFile.writeln(val: double);
begin
  write( val );
  writeln;
end;

procedure TExcelFile.writeln(val: integer);
begin
  write( val );
  writeln;
end;

procedure TExcelFile.writeln;
begin
  inc( kFila );
  jColumna:= 1;
end;


(*
function TExcelFile.ref(fila, columna: integer): string;
function TExcelFile.ref_rango(f1, c1, f2, c2: integer): string;
*)
procedure TExcelFile.SelRango(fil1, col1, fil2, col2: integer);
begin
  rango.fila1:=fil1;
  rango.columna1:= col1;
  rango.fila2:= fil2;
  rango.columna2:= col2;
end;

(*
procedure TExcelFile.BordeSimple(ancho: integer;
  Arriba, Derecha, Abajo, Izquierda,
  InteriorVertical, InteriorHorizontal: boolean);

procedure TExcelFile.CambiarFuente(nuevafuente: string);
procedure TExcelFile.CambiarTamFuente(nuevotam: integer);

// cambio de color usando ColorIndex
procedure TExcelFile.CambiarColorFuente_ci(nuevoci: integer);
procedure TExcelFile.CambiarColorFondo_ci(nuevoci: integer);

// cambio de color usuando un TColor
procedure TExcelFile.CambiarColorFuente_cl(nuevoCol: TColor);
procedure TExcelFile.CambiarColorFondo_cl(nuevoCol: TColor);

*)

procedure TExcelFile.CambiarFormato(nuevoFormato: string);
var
  aHoja: THoja;
  k, j: integer;
  s: string;
begin
  aHoja:= hojas[ kHojaActiva - 1];
  aHoja.WriteFormato( rango, nuevoFormato );
  {$IFDEF FORM_LIBRO_SIMSEE}
  if libro <> nil then
  begin
    for k:= rango.fila1 to rango.fila2 do
      for j:= rango.columna1 to rango.columna2 do
      begin
//        s:= aHoja.ReadStr( k, j );
//        aHoja.WriteEvalStr(k, j, s );
        libro.grid_.Cells[ j, k ]:= aHoja.ReadEvalStr( k, j );
      end;
  end;
  {$ENDIF}
end;


(*
procedure TExcelFile.CambiarAncho(nuevoAncho: integer);
procedure TExcelFile.CambiarAlto(nuevoAlto: integer);
procedure TExcelFile.CambiarFormula(nuevaFormula: string);
procedure TExcelFile.CombinarCeldas;
*)
procedure TExcelFile.autoFitCells;
begin
// por ahora nada

end;

(*
procedure TExcelFile.AlinearDerecha;
procedure TExcelFile.AlinearIzquierda;
procedure TExcelFile.AlinearCentro;
procedure TExcelFile.WrapTextON;
procedure TExcelFile.WrapTextOFF;
procedure TExcelFile.BoldON;
procedure TExcelFile.BoldOFF;
procedure TExcelFile.InsertarImagen(archi: string; x, y: integer);
procedure TExcelFile.Zoom(porciento: integer);

// acomada para imprimir
procedure TExcelFile.SetPage(PaginaVertical: boolean);

*)


//Retorna true si el libro del TExcelFile esta abierto.
//Si se cerro el EXCEL sin liberar el TExcelFile retorna false
function TExcelFile.libroAbierto: boolean;
begin
  result:= true;
  // por ahora en la versión NO WIndows si existe está abierto
end;

function TExcelFile.contarFilasHastaBlanco: integer;
var
  filaInicial, columnaInicial, res: Integer;
  contenidoCelda: String;
  celdaEnBlanco: boolean;
begin
  filaInicial := self.fila;
  columnaInicial := self.columna;
  res := 0;
  contenidoCelda := ReadV_str;
  celdaEnBlanco := contenidoCelda = '';
  while not celdaEnBlanco do
  begin
    res := res + 1;
    self.ir(filaInicial + res, columnaInicial);
    contenidoCelda := self.ReadV_str;
    celdaEnBlanco := contenidoCelda = '';
  end;
  self.ir(filaInicial, columnaInicial);
  Result := res;
end;

function TExcelFile.contarColumnasHastaBlanco: Integer;
var
  filaInicial, columnaInicial, res: Integer;
  contenidoCelda: String;
  celdaEnBlanco: boolean;
begin
  filaInicial := self.fila;
  columnaInicial := self.columna;
  res := 0;
  contenidoCelda := self.ReadV_str;
  celdaEnBlanco := contenidoCelda = '';
  while not celdaEnBlanco do
  begin
    res := res + 1;
    self.ir(filaInicial, columnaInicial + res);
    contenidoCelda := self.ReadV_str;
    celdaEnBlanco := contenidoCelda = '';
  end;
  self.ir(filaInicial, columnaInicial);
  Result := res;
end;


(*
//12 = office 2007
function TExcelFile.version: double;

*)



procedure TExcelFile.aplicarPropiedadesAGrafico(nombreHoja: shortstring;
  tipoGrafico: integer;
  titulo, ejeY: shortstring;
  minEjeYAuto, maxEjeYAuto: boolean;
  minEjeY, MaxEjeY: double;
  minEjeX, MaxEjeX: double; ejeX : shortstring);
var
  aGrafico: TGrafico;
begin
  aGrafico:= LibroActivo.GetGraficoByName( nombreHoja );
  if aGrafico = nil then
     raise Exception.Create( 'Error: xf_aplicarPropiedadesAGrafic Gráfico('+nombreHoja+') NO ENCONTRADO ' );

  aGrafico.tipoGrafico:= TTipoGrafico( tipoGrafico );
  aGrafico.Titulo:= titulo;
  aGrafico.eje_y.titulo:= ejeY;
  aGrafico.eje_x.titulo:= ejeX;
  aGrafico.eje_y.flg_min_auto:= minEjeYAuto;
  aGrafico.eje_y.flg_max_auto:= maxEjeYAuto;
  aGrafico.eje_y.v_min_forzado:= minEjeY;
  aGrafico.eje_y.v_max_forzado:= maxEjeY;
  aGrafico.eje_x.v_min_forzado:= minEjeX;
  aGrafico.eje_x.v_max_forzado:= maxEjeX;
end;


procedure TExcelFile.aplicarPropiedadesASerie(nombreHoja: shortstring;
  iSerie: integer; //1..nSeries
  tipoGraficoPrincipal, tipoGrafico: integer;
  eje: integer;
  color: TColor);
var
  aGrafico: TGrafico;
  serie: TSerieGrafico;
begin
  aGrafico:= LibroActivo.GetGraficoByName( nombreHoja );
  if aGrafico = nil then
     raise Exception.Create( 'Error: xf_aplicarPropiedadesAGrafic Gráfico('+nombreHoja+') NO ENCONTRADO ' );


  serie:= aGrafico.series_y[ iSerie-1 ];

  {$IFDEF FP_CANVAS}
  if not colores_iguales( color, clDefault ) then
  {$ELSE}
  if color <> clDefault then
  {$ENDIF}
  begin
    serie.colorArea:= color;
    serie.colorFondoMarcador:= color;
    serie.colorLinea:= color;
    serie.colorLineaMarcador:= color;
  end;

  serie.eje:= max( 0, eje-1 );
  serie.tipoGrafico:= TTipoGrafico( tipoGrafico );
end;

function TExcelFile.graficar(nombreHoja: shortstring;
  colIni, colFin, filaIni, filaFin: integer): shortstring;
var
  aGrafico: TGrafico;
  aSerie, seriex: TSerieGrafico;
  kSerie, kDato: integer;
  nSeries, nDatos: integer;
  nombresSeries: TDAOfString;
  valoresSeries: TDAOfDAOfNReal;
  avSerie: TDAOfNReal;
  g_NombreHoja: string;
  format_str: array of string;

begin

  g_NombreHoja:= 'g_'+nombreHoja;

  aGrafico:= TGrafico.Create( g_NombreHoja, TG_DispersionXY);

  nSeries:= colFin - colIni+1 ;

  nDatos:=  filaFin - filaIni; // no sumo 1 porque la primera es encabezado

  if ( nSeries <= 0 ) or ( nDatos <= 0 ) then
    raise Exception.Create( 'xf_graficar .... error de rango: nSeries: '+IntToStr( nSeries )+' , nDatos: '+IntToStr( nDatos ) );

  setlength( valoresSeries, nSeries );
  setlength( nombresSeries, nSeries );
  LibroActivo.ActivoHoja_nombre( nombreHoja );

  setlength( format_str, NSeries );
  for kSerie:= 0 to NSeries-1 do
  begin
    setlength( valoresSeries[ kSerie ], nDatos );
    avSerie:= valoresSeries[ kSerie ];
    NombresSeries[kSerie]:= LibroActivo.ReadStr( filaIni, colIni+ kSerie );
    for kDato:= 1 to NDatos  do
    begin
      avSerie[ kDato-1] := LibroActivo.ReadFloat( filaIni+ kDato, colIni+ kSerie);
    end;
    format_str[kSerie]:= LibroActivo.ReadFormato( filaINi+1, colini+kSerie );
  end;



  seriex:= TSerieGrafico.Create( NombresSeries[ 0 ], valoresSeries[0], nil, aGrafico, format_str[0], true  );
    aGrafico.AddSerie( seriex );

  for kSerie:= 1 to NSeries-1 do
  begin
    aSerie:= TSerieGrafico.Create(
    NombresSeries[ kSerie ], valoresSeries[kSerie], seriex, aGrafico,  format_str[kSerie], false  );
    aGrafico.AddSerie( aSerie );
  end;

  LibroActivo.agregoGrafico( aGrafico );

  setlength( valoresSeries, 0 );
  setlength( nombresSeries, 0 );
  result:= g_NombreHoja;
end;

function TExcelFile.graficarXY(nombreHoja: shortstring;
  colIni, colFin, filaIni, filaFin, nSeries_ejex: integer): shortstring;
var
  aGrafico: TGrafico;
  aSerie: TSerieGrafico;
  seriex: array of TSerieGrafico;
  kSerie, kDato, kSerie_ejex, iSerie_ejex: integer;
  nSeries, nDatos: integer;
  nombresSeries: TDAOfString;
  valoresSeries: TDAOfDAOfNReal;
  avSerie: TDAOfNReal;
  g_NombreHoja: string;
  format_str: array of string;

begin

  g_NombreHoja:= 'g_'+nombreHoja;

  aGrafico:= TGrafico.Create( g_NombreHoja, TG_DispersionXY);

  nSeries:= colFin - colIni+1 ;

  nDatos:=  filaFin - filaIni; // no sumo 1 porque la primera es encabezado

  if ( nSeries <= 0 ) or ( nDatos <= 0 ) then
    raise Exception.Create( 'xf_graficar .... error de rango: nSeries: '+IntToStr( nSeries )+' , nDatos: '+IntToStr( nDatos ) );

  setlength( valoresSeries, nSeries );
  setlength( nombresSeries, nSeries );
  LibroActivo.ActivoHoja_nombre( nombreHoja );

  setlength( format_str, NSeries );
  for kSerie:= 0 to NSeries-1 do
  begin
    setlength( valoresSeries[ kSerie ], nDatos );
    avSerie:= valoresSeries[ kSerie ];
    NombresSeries[kSerie]:= LibroActivo.ReadStr( filaIni, colIni+ kSerie );
    for kDato:= 1 to NDatos  do
    begin
      avSerie[ kDato-1] := LibroActivo.ReadFloat( filaIni+ kDato, colIni+ kSerie);
    end;
    format_str[kSerie]:= LibroActivo.ReadFormato( filaINi+1, colini+kSerie );
  end;
  SetLength(seriex,nSeries_ejex);

  for kSerie_ejex:=0 to NSeries_ejex-1  do
  begin
      seriex[kSerie_ejex]:= TSerieGrafico.Create( NombresSeries[ kSerie_ejex ],
                            valoresSeries[kSerie_ejex], nil, aGrafico, format_str[kSerie_ejex], true  );
      aGrafico.AddSerie( seriex[kSerie_ejex] );
  end;

  iSerie_ejex:= 0;
  for kSerie:= NSeries_ejex to NSeries-1 do
  begin
    aSerie:= TSerieGrafico.Create(NombresSeries[ kSerie ], valoresSeries[kSerie],
             seriex[ iSerie_ejex ], aGrafico,  format_str[kSerie], false  );
    aSerie.AnchoLinea:= 0;
    aSerie.AnchoLineaMarcador:= 1;
    aSerie.RadioMarcador:= 2;

    aGrafico.AddSerie( aSerie );
    iSerie_ejex := ( iSerie_ejex + 1 ) MOD NSeries_ejex;
  end;

  LibroActivo.agregoGrafico( aGrafico );

  setlength( valoresSeries, 0 );
  setlength( nombresSeries, 0 );
  result:= g_NombreHoja;
end;


{$ENDIF}





end.

