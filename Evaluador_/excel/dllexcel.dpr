{$DEFINE LOGO_SIMSEE}
library dllexcel;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  windows,
  Classes,
  Graphics,
  xlConst,
  u_ExcelFile;

{$R *.res}

const
  tiposGraficosConMarcadores = [xlXYScatterLines];
  tiposGraficosConColorInterior = [xlAreaStacked];
                
var
  xf: T_ExcelFile;

function xf_Create( nombreHoja1: shortstring; visible: boolean; autocierre, avisocierre: boolean ): integer;
begin
  if xf = nil then
  begin
    xf:= T_ExcelFile.Create( nombreHoja1, visible, autocierre, avisocierre );
    result:= 1;
  end
  else
    result:= 0;
end;

procedure xf_Guardar( nombre: shortstring );
begin
  xf.Guardar( nombre );
end;

procedure xf_Abrir (nombArchivo: shortstring );
begin
  xf.Abrir( nombArchivo );
end;
procedure xf_agregolibro();
begin
  xf.agregoLibro;
end;

procedure xf_agregoHoja( nombreHoja: shortstring );
begin
  xf.agregoHoja( nombreHoja );
end;

procedure xf_EscribirCeldaTexto(nombreHoja:shortstring; fila:integer; columna:integer; contenido:shortstring);
begin
  xf.EscribirCeldaTexto(  nombreHoja, fila, columna , contenido );
end;


procedure xf_Cerrar( conAviso: boolean );
begin
  xf.Cerrar( conAviso );
end;
procedure xf_Free;
begin
  xf.Free;
  xf:= nil;
end;

procedure xf_VisibleOn;
begin
  xf.VisibleOn;
end;
procedure xf_VisibleOff;
begin
  xf.VisibleOff;
end;

procedure xf_ActivoHoja_nombre( nombreHoja: shortstring );
begin
  xf.ActivoHoja_nombre( nombreHoja );
end;

procedure xf_ActivoHoja_numero( numeroHoja: integer );
begin
  xf.ActivoHoja_numero( numeroHoja );
end;

procedure xf_ir( fila, columna : integer );
begin
  xf.ir( fila, columna );
end;
procedure xf_irr( dfila, dcolumna: integer);
begin
  xf.irr( dfila, dcolumna );
end;



function xf_ReadV_str: shortstring;
begin
  result:= xf.ReadV;
end;

function xf_ReadV_float: extended; 
begin
  result:= xf.ReadV;
end;

function xf_ReadV_int: integer;
begin
  result:= xf.ReadV;
end;


procedure xf_readln;
begin
  xf.readln;
end;

procedure xf_go( NombreHoja: shortstring; fila, columna: integer );
begin
  xf.go( NombreHoja, fila, columna );
end;

//Retorna la letra de la columna nroCol
function xf_nroColToExcelCol(nroCol: Cardinal): shortstring;
begin
  result:= xf.nroColToExcelCol( nroCol );
end;


procedure xf_write_str( val: shortstring );
begin
  xf.Write( val );
end;
procedure xf_write_float( val: extended );
begin
  xf.Write( val );
end;
procedure xf_write_int( val: integer );
begin
  xf.Write( val );
end;

procedure xf_WriteF_str( contenido: shortstring; formato: shortstring );
begin
  xf.WriteF( contenido, formato );
end;
procedure xf_WriteF_float( contenido: extended; formato: shortstring );
begin
  xf.WriteF( contenido, formato );
end;
procedure xf_WriteF_int( contenido: integer; formato: shortstring );
begin
  xf.WriteF( contenido, formato );
end;

procedure xf_WriteMAF_str( contenido: shortstring; celdas: integer; alineacion: integer; formato: shortstring );
begin
  xf.WriteMAF( contenido, celdas, alineacion, formato );
end;
procedure xf_WriteMAF_float( contenido: extended; celdas: integer; alineacion: integer; formato: shortstring );
begin
  xf.WriteMAF( contenido, celdas, alineacion, formato );
end;
procedure xf_WriteMAF_int( contenido: integer; celdas: integer; alineacion: integer; formato: shortstring );
begin
  xf.WriteMAF( contenido, celdas, alineacion, formato );
end;
procedure xf_writeln; overload;
begin
  xf.writeln;
end;

procedure xf_write_str_buffereado( val: shortstring );
begin
  xf.WriteBuffereado(val);
end;

procedure xf_write_float_buffereado( val: extended );
begin
  xf.WriteBuffereado(val);
end;

procedure xf_write_int_buffereado( val: integer );
begin
  xf.WriteBuffereado(val);
end;

procedure xf_writeln_buffereado;
begin
  xf.WriteLnBuffer;
end;

function xf_ref( fila, columna:integer ): shortstring;
begin
  result:= xf.ref( fila, columna );
end;

function xf_ref_rango( f1,c1, f2,c2: integer): shortstring;
begin
  result:= xf.ref_rango( f1, c1, f2, c2 );
end;

procedure xf_SelRango( fil1, col1, fil2,col2: integer);
begin
  xf.SelRango( fil1, col1, fil2, col2 );
end;

procedure xf_BordeSimple(ancho: integer;
                       Arriba, Derecha, Abajo, Izquierda,
                       InteriorVertical, InteriorHorizontal: boolean);
begin
  xf.BordeSimple( ancho, arriba, derecha, abajo, izquierda, InteriorVertical, InteriorHorizontal);
end;

procedure xf_CambiarFuente( nuevafuente: shortstring);
begin
  xf.CambiarFuente( nuevaFuente );
end;

procedure xf_CambiarTamFuente( nuevotam: integer);
begin
  xf.CambiarTamFuente( nuevoTam );
end;

// cambio de color usando ColorIndex
procedure xf_CambiarColorFuente_ci( nuevoci: integer );
begin
  xf.CambiarColorFuente_ci( nuevoci );
end;

procedure xf_CambiarColorFondo_ci( nuevoci: integer );
begin
  xf.CambiarColorFondo_ci( nuevoci );
end;

// cambio de color usuando un TColor
procedure xf_CambiarColorFuente_cl( nuevoCol: TColor );
begin
  xf.CambiarColorFuente_cl( nuevoCol );
end;

procedure xf_CambiarColorFondo_cl( nuevoCol: TColor );
begin
  xf.CambiarColorFondo_cl( nuevoCol );
end;

procedure xf_CambiarFormato( nuevoFormato: shortstring );
begin
  xf.CambiarFormato( nuevoFormato );
end;

procedure xf_CambiarAncho( nuevoAncho: integer);
begin
  xf.CambiarAncho( nuevoAncho );
end;

procedure xf_CambiarAlto( nuevoAlto: integer );
begin
  xf.CambiarAlto( nuevoAlto );
end;

procedure xf_CambiarFormula( nuevaFormula: shortstring );
begin
  xf.CambiarFormula( nuevaFormula );
end;


procedure xf_CombinarCeldas;
begin
  xf.CombinarCeldas;
end;

procedure xf_AlinearDerecha;
begin
  xf.AlinearDerecha;
end;

procedure xf_AlinearIzquierda;
begin
  xf.AlinearIzquierda;
end;

procedure xf_AlinearCentro;
begin
  xf.AlinearCentro;
end;

procedure xf_autoFitCells;
begin
  xf.autoFitCells;
end;


procedure xf_WrapTextON;
begin
  xf.WrapTextON;
end;

procedure xf_WrapTextOFF;
begin
  xf.WrapTextOFF;
end;

procedure xf_BoldON;
begin
  xf.BoldON;
end;

procedure xf_BoldOFF;
begin
  xf.BoldOFF;
end;

procedure xf_InsertarImagen( archi: shortstring; x, y: integer );
begin
  xf.InsertarImagen( archi, x, y );
end;

procedure xf_Zoom( porciento: integer );
begin
  xf.Zoom( porciento );
end;

// acomada para imprimir
procedure xf_SetPage(  PaginaVertical: boolean );
begin
  xf.SetPage( PaginaVertical );
end;

//Retorna true si el libro del T_ExcelFile esta abierto.
//Si se cerro el EXCEL sin liberar el T_ExcelFile retorna false
function xf_libroAbierto: boolean;
begin
  result:= xf.libroAbierto;
end;

function xf_contarFilasHastaBlanco: Integer;
begin
  result := xf.contarFilasHastaBlanco;
end;

function xf_contarColumnasHastaBlanco: Integer;
begin
  result := xf.contarColumnasHastaBlanco;
end;

//12 = office 2007
function xf_version: Double;
begin
  result:= xf.version;
end;

function xf_fila: integer;
begin
  result:= xf.fila;
end;

function xf_columna: integer;
begin
  result:= xf.columna;
end;

function xf_columnaBuffereada: Integer;
begin
  result:= xf.columnaBuffereada;
end;

(************ complicadas  *****************
function xf_Hoja_numero( numeroHoja: integer ): Variant;
begin
  result:= xf.Hoja( numeroHoja );
end;

function xf_Hoja_nombre( nombreHoja: string ): Variant;
begin
  result:= xf.Hoja( nombreHoja );
end;

procedure xf_EscribirCeldaHojaActual(fila:integer; columna:integer; contenido:variant);
begin
  xf.EscribirCeldaHojaActual( fila, columna, contenido );
end;

procedure xf_EscribirCelda(nombreHoja:shortstring; fila:integer; columna:integer; contenido:variant);
begin
  xf.EscribirCelda( nombreHOja, fila, columna, contenido );
end;

function xf_ContenidoCelda(nombreHoja:shortstring; var fila:integer; columna:integer; incrementa:boolean): variant;
begin
  result:=  xf.ContenidoCelda( nombreHoja, fila, columna, incrementa );
end;

function xf_ReadV: variant;
begin
  result:= xf.ReadV;
end;

procedure xf_Write( contenido: variant );
begin
  xf.write( contenido );
end;


//cambia el tamanio del buffer
procedure xf_setTamanioBuffer(nCeldas: Integer);
begin
  xf.setTamanioBuffer( nCeldas );
end;

//Almacena los datos que se piden escribir en un buffer, los datos no se
//bajan al excel hasta que se haga un llamado a WriteLnBuffer o el buffer
//se llena. No usar en combinacion con otros writes. Esto es entre que se
//hace una llamada WriteBuffereado y su correspondiente llamada a WriteLnBuffer
//no debe llamarse otro write o se perdera el orden de las columnas
procedure xf_WriteBuffereado(const contenido: variant );
begin
  xf.WriteBuffereado( contenido );
end;

procedure xf_WriteLnBuffer;
begin
  xf.WriteLnBuffer;
end;

function xf_columnaBuffereada: Integer;
begin
  result:=  xf.columnaBuffereada;
end;

procedure xf_WriteV( contenido: variant );
begin
  xf.WriteV( contenido );
end;

//Escribe una fila entera de valores
procedure xf_WriteFila(const contenido: TDAOfVariant);
begin
  xf.WriteFila( contenido );
end;

procedure xf_WriteLnFila(const contenido: TDAOfVariant);
begin
  xf.WriteLnFila( contenido );
end;



procedure xf_writeln( contenido: variant ); overload; // fila:=fila+1; columna:= 1
begin
  xf.writeln( contenido );
end;

function xf_getPaletaColores: TPaletaColoresExcel;
begin
  result:= xf.getPaletaColores;
end;

procedure xf_setPaletaColores(nuevaPaleta: TPaletaColoresExcel);
begin
  xf.setPaletaColores( nuevaPaleta );
end;

*)

procedure xf_aplicarPropiedadesAGrafico(nombreHoja: shortString;
                                        tipoGrafico: integer;  // xlsConstant
                                        titulo, ejeY: shortString;
                                        minEjeYAuto, maxEjeYAuto: boolean;
                                        minEjeY, MaxEjeY: double;
                                        minEjeX, MaxEjeX: double);
var
  hojag, serie: Variant;
  i, highSeries: Integer;
  xls: T_ExcelFile;
begin
  xls:= xf;

  hojag:= xls.Hoja(nombreHoja);
  hojag.ChartType:= tipoGrafico;

  if titulo <> '' then
  begin
    hojag.HasTitle:= True;
    hojag.ChartTitle.Characters.Text:= titulo;
  end;
  hojag.Axes(xlCategory, xlPrimary).HasTitle:= False;
  if tipoGrafico <> xlAreaStacked then
  begin
    hojag.Axes(xlCategory).MinimumScale:= minEjeX;
    hojag.Axes(xlCategory).MaximumScale:= maxEjeX;
  end;
  if ejeY <> '' then
  begin
    hojag.Axes(xlValue, xlPrimary).HasTitle:= True;
    hojag.Axes(xlValue, xlPrimary).AxisTitle.Characters.Text:= ejeY;
  end;
  hojag.PlotArea.Interior.ColorIndex:= 2;       //Color de fondo blanco
  if minEjeYAuto then
    hojag.Axes(xlValue).MinimumScaleIsAuto:= true
  else
    hojag.Axes(xlValue).MinimumScale:= minEjeY;   //Mínimo del eje Y
  if maxEjeYAuto then
    hojag.Axes(xlValue).MaximumScaleIsAuto:= true
  else
    hojag.Axes(xlValue).MaximumScale:= MaxEjeY;   //Máximo del eje Y

  highSeries:= hojag.SeriesCollection.Count-1;
  for i:= 0 to highSeries do
  begin
    serie:= hojag.SeriesCollection( i + 1 );
    serie.MarkerSize:= 5;
//    serie.MarkerStyle:= -4142;
  end;
end;

procedure xf_aplicarPropiedadesASerie(nombreHoja: shortstring;
                                      iSerie: Integer; //1..nSeries
                                      tipoGraficoPrincipal, tipoGrafico: Integer;
                                      eje: Integer;
                                      color: TColor);
var
  xls: T_ExcelFile;
  hojag, serie: Variant;
  colorIndex: Integer;
  aux: TPaletaColoresExcel;
begin
  xls:= xf;
  hojag:= xls.Hoja(nombreHoja);
  serie:= hojag.SeriesCollection(iSerie);
  if tipoGrafico <> tipoGraficoPrincipal then
    serie.ChartType:= tipoGrafico;
  serie.AxisGroup:= eje;

  if color <> clDefault then
  begin
    if xls.version < versionOffice2007 then
    begin
      aux:= xls.getPaletaColores;
      colorIndex:= getColorIndex(color, aux);

      if tipoGrafico in tiposGraficosConColorInterior then
        serie.Interior.Colorindex:= colorIndex;
      serie.Border.Colorindex:= colorIndex;
      if tipoGrafico in tiposGraficosConMarcadores then
      begin
        serie.MarkerStyle:= xlAutomatic;
        serie.MarkerBackgroundColorIndex:= colorIndex;
        serie.MarkerForegroundColorIndex:= colorIndex;
      end;
    end
    else
    begin
      if tipoGrafico in tiposGraficosConColorInterior then
        serie.Interior.Color:= color;
      serie.Border.Color:= color;
      if tipoGrafico in tiposGraficosConMarcadores then
      begin
        serie.MarkerStyle:= xlAutomatic;
        serie.MarkerBackgroundColor:= color;
        serie.MarkerForegroundColor:= color;
      end;
    end;
  end;
end;

function bin_root: string;
var
  s: string;
  k: integer;
  buscando: boolean;
begin
  s:= paramstr( 0 );
  buscando:= true;
  k:= length( s );
  while buscando and (k > 0 ) do
  begin
    if s[k] = '\' then
      buscando:= false
    else
      dec( k );
  end;
  if not buscando then
    delete( s, k, length( s ) - k +1 )
  else
    s:= '';
  result:= s;
end;
function xf_graficar(nombreHoja: shortstring;
                     colIni, colFin, filaIni, filaFin: Integer): shortstring;
var
  ARange: Variant;
  hoja, hojag, htmp: Variant;
  celdaIni, celdaFin: shortstring;
  xls: T_ExcelFile;
  {$IFDEF LOGO_SIMSEE}
  x_, y_: double;
  {$ENDIF}
    
begin
  xls:= xf;
  hoja:= xls.Hoja(nombreHoja);
  xls.v.Workbooks[1].Sheets.Add(,,1,xlChart);
  hojag:= xls.v.Workbooks[1].Sheets[1];
  hojag.Name:= 'g' + nombreHoja;

  celdaIni:= xf_nroColToExcelCol(colIni) + IntToStr(filaIni);
  celdaFin:= xf_nroColToExcelCol(colFin) + IntToStr(filaFin);
  ARange:= hoja.Range[celdaIni + ':' + celdaFin];

  hojag.SetSourceData( ARange, xlColumns );


  htmp:= xls.ha;
  xls.ha:= hojag;
  xls.ha.chartarea.font.size:= 14;
  xls.ha.Axes(xlValue).TickLabels.NumberFormat := '0';
  xls.ha.chartarea.Select;
  xls.v.ActiveWindow.Zoom:= false;

  {$IFDEF LOGO_SIMSEE}
  x_:= xls.ha.PlotArea.left + xls.ha.PlotArea.width;
  y_:= xls.ha.PlotArea.top;
//  x_:= 0; y_:= 0;
  xls.InsertarImagen( bin_root+'\logoSimSEE.gif', x_, y_ );
  {$ENDIF}
  xls.ha.ChartArea.Select;
  xls.v.ActiveWindow.Zoom := True;

  xls.ha:= htmp;
  result:= 'g' + nombreHoja;
end;

procedure xf_alinicio;
begin
  xf:= nil;
end;

procedure xf_alfinal;
begin
  if xf <> nil then
  begin
    xf.Free;
    xf:= nil;
  end;
end;

exports
  xf_alinicio,
  xf_alfinal,
  xf_fila,
  xf_columna,
  xf_columnaBuffereada,
  xf_create,
  xf_guardar,
  xf_abrir,
  xf_agregolibro,
  xf_agregohoja,
  xf_escribirceldatexto,
  xf_cerrar,
  xf_free,
  xf_visibleon,
  xf_visibleoff,
  xf_activohoja_nombre,
  xf_activohoja_numero,
  xf_ir,
  xf_irr,
  xf_readv_str,
  xf_readv_float,
  xf_readv_int,
  xf_readln,
  xf_go,
  xf_nrocoltoexcelcol,
  xf_write_str,
  xf_write_float,
  xf_write_int,
  xf_WriteF_str,
  xf_WriteF_float,
  xf_WriteF_int,
  xf_WriteMAF_str,
  xf_WriteMAF_float,
  xf_WriteMAF_int,

  xf_writeln,
  xf_write_str_buffereado,
  xf_write_float_buffereado,
  xf_write_int_buffereado,
  xf_writeln_buffereado,
  xf_ref,
  xf_ref_rango,
  xf_selrango,
  xf_bordesimple,
  xf_cambiarfuente,
  xf_cambiartamfuente,
  xf_cambiarcolorfuente_ci,
  xf_cambiarcolorfondo_ci,
  xf_cambiarcolorfuente_cl,
  xf_cambiarcolorfondo_cl,
  xf_cambiarformato,
  xf_cambiarancho,
  xf_cambiaralto,
  xf_cambiarformula,
  xf_combinarceldas,
  xf_alinearderecha,
  xf_alinearizquierda,
  xf_alinearcentro,
  xf_autoFitCells,
  xf_contarFilasHastaBlanco,
  xf_contarColumnasHastaBlanco,
  xf_wraptexton,
  xf_wraptextoff,
  xf_boldon,
  xf_boldoff,
  xf_insertarimagen,
  xf_zoom,
  xf_setpage,
  xf_libroabierto,
  xf_version,
  xf_aplicarpropiedadesagrafico,
  xf_aplicarPropiedadesASerie,
  xf_graficar;


//  xf_Hoja_numero,
//  xf_Hoja_nombre,
//  xf_EscribirCeldaHojaActual,
//  xf_EscribirCelda,
//  xf_ContenidoCelda,
//  xf_ReadV,
//  xf_Write,
//  xf_setTamanioBuffer,
//  xf_WriteBuffereado,
//  xf_WriteLnBuffer,
//  xf_columnaBuffereada,
//  xf_WriteV,
//  xf_WriteFila,
//  xf_WriteLnFila,
//  xf_WriteF,
//  xf_WriteMAF,
//  xf_getPaletaColores,
//  xf_setPaletaColores,



end.
