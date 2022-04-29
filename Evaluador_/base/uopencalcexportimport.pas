unit uopencalcexportimport;

{$MODE Delphi}

interface

uses
  Grids,
  uopencalc,
  StdCtrls, SysUtils, Controls, Forms,
  Dialogs,
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  ComCtrls,
  Classes,
  uModeloSintCEGH,
  ufichasLPD,
  xMatDefs, uFechas, uCosa,
  uauxiliares;

resourcestring
  mesElNumeroDeColumnasEnElODSNoCoincideConElNumeroDeBornesEnElSintetizador =
    'El número de columnas en el ODS no coincide con el número de bornes en el sintetizador';
  RS_NoSeEncontroFinDeDatosHorarios =
    'No se encontro la fila final de los datos horarios.';
  RS_NoSeEncontroFilaDeInicio = 'No se encontró la fila inicial.';

procedure exportarTablaAODS_1(tabla: TStringGrid;
  filaIni, filaFin, colIni, colFin: integer;
  nFilasEncabezado, nColumnasEncabezado: integer; SeriesEnColumnas: boolean;
  tiposSeries: string; // ' S,I,F,D  String, Integer, Float, Date
  bImportar: TButton; PBExportacion: TProgressBar);

procedure importarTablaDesdeODS_1(tabla: TStringGrid;
  filaIni, filaFin, colIni, colFin: integer; bImportar: TButton;
  PBImportacion: TProgressBar;
  chequeoEncabezadosFila, chequeoEncabezadosColumna: boolean);

// Asume filaIni = 0, colIni = 0, filaFin = tabla.RowCount - 1 y
// colFin = tabla.ColCount - 1
procedure exportarTablaAODS_2(tabla: TStringGrid; bImportar: TButton;
  PBExportacion: TProgressBar);

// Asume filaIni = tabla.fixedRows, colIni = tabla.fixedCols,
// filaFin = tabla.RowCount - 1 y colFin = tabla.ColCount - 1
procedure importarTablaDesdeODS_2(tabla: TStringGrid; bImportar: TButton;
  PBImportacion: TProgressBar;
  chequeoEncabezadosFila, chequeoEncabezadosColumna: boolean);

procedure exportarTablaAODS_3(tabla: TStringGrid;
  filaIni, filaFin, colIni, colFin: integer);

procedure exportarTablaAODS_4(tabla: TStringGrid; filaIni, filaFin: integer;
  cols: array of integer);

procedure exportarPromStdDevDatosModeloCEGHAODS(const datosModelo: TModeloCEGH);


(* Exportar "datos" horarios. *)
procedure importarDatosHorariosDesdeODS(var datos: TDAOfNReal;
  var fechaIni: TDateTime; bImportar: TButton; PBImportacion: TProgressBar;
  chequeoEncabezadosFila, chequeoEncabezadosColumna: boolean);

(* Importar "datos" horarios. *)
procedure exportarDatosHorariosAODS(const datos: TDAOfNreal;
  fechaIni: TDateTime; bImportar: TButton; PBExportacion: TProgressBar);



// Exporta string con CEROS y UNOS a ODS
procedure exportarStrBoolAODS(strbool: string; bImportar: TButton);


// Obtiene string de CEROS y UNOS desde ODS
// Explora desde el casillero (1,1) hasta NCols_buscar y NFils_buscar
function importarStrBoolDesdeODS(bImportar: TButton; nbinsPorLinea: integer;
  NCols_buscar, NFils_Buscar: integer): string;

// Exporta una lista de fichas de parámetros dinámicos
procedure exportar_FichasLPD_aODS(fichas: TFichasLPD; bExportar, bImportar: TButton);

// Importa lista de fichas de paráemtros dinámicos
procedure importar_FichasLPD_DesdeODS(var fichas: TFichasLPD;
  Evaluador: TEvaluadorConCatalogo; bExportar, bImportar: TButton);


implementation


procedure exportarTablaAODS_3(tabla: TStringGrid;
  filaIni, filaFin, colIni, colFin: integer);
var
  i, j: integer;
  xls: TLibroOpenCalc;
  cursorAnterior: TCursor;
begin
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  xls := TLibroOpenCalc.Create(True);
  try
    xls.go('x', 1, 1);
    for i := filaIni to filaFin do
    begin
      for j := colIni to colFin do
        xls.Write(tabla.Cells[j, i]);
      // WriteBuffereado(tabla.Cells[j, i]);
      // xls.WriteLnBuffer;
      xls.writeln;
    end;
  finally
    Screen.Cursor := cursorAnterior;
    xls.VisibleOn;
    xls.Free;
  end;
end;

procedure exportarTablaAODS_4(tabla: TStringGrid; filaIni, filaFin: integer;
  cols: array of integer);
var
  i, j: integer;
  xls: TLibroOpenCalc;
  cursorAnterior: TCursor;
begin
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  xls := TLibroOpenCalc.Create(True);
  try
    xls.go('x', 1, 1);
    for i := filaIni to filaFin do
    begin
      for j := 0 to High(cols) do
        xls.Write(tabla.Cells[cols[j], i]);
      xls.writeln;
    end;
  finally
    Screen.Cursor := cursorAnterior;
    xls.VisibleOn;
    xls.Free;
  end;
end;

procedure exportarPromStdDevDatosModeloCEGHAODS(const datosModelo: TModeloCEGH);
var
  i, j: integer;
  cursorAnterior: TCursor;
  nPuntosPorPeriodo: integer;
  xls: TLibroOpenCalc;
begin
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  xls := TLibroOpenCalc.Create(True);
  try
    xls.go('x', 1, 2);
    for i := 0 to datosModelo.nBornesSalida - 1 do
    begin
      xls.Write(datosModelo.NombresDeBornes_Publicados[i]);
      xls.Write('');
    end;
    xls.Writeln;
    xls.Write('Función Deformante');
    for i := 0 to datosModelo.nBornesSalida - 1 do
    begin
      xls.Write('Promedio');
      xls.Write('Desviación Estandar');
    end;
    xls.WriteLn;

    nPuntosPorPeriodo := length(datosModelo.funcionesDeformantes[0]);

    for i := 1 to nPuntosPorPeriodo do
    begin
      xls.Write(i);
      for j := 0 to datosModelo.nBornesSalida - 1 do
      begin
        xls.Write(datosModelo.funcionesDeformantes[j][i - 1].a.promedio);
        xls.Write(datosModelo.funcionesDeformantes[j][i - 1].a.desviacionEstandar);
      end;
      xls.writeln;
    end;

    // formatedo del área de datos
    xls.SelRango(3, 2, 2 + nPuntosPorPeriodo,
      1 + datosModelo.NombresDeBornes_Publicados.Count * 2);
    xls.CambiarFormato(xf_formatoStr(1));
    xls.ir(1, 1);
    xls.autoFitCells;
    xls.VisibleOn;
    Screen.Cursor := cursorAnterior;
  except
    Screen.Cursor := cursorAnterior;
  end;
  xls.Free;

end;



procedure exportarTablaAODS_1(tabla: TStringGrid;
  filaIni, filaFin, colIni, colFin: integer;
  nFilasEncabezado, nColumnasEncabezado: integer; SeriesEnColumnas: boolean;
  tiposSeries: string;
  // ' S,I,F,D  String, Integer, Float, Date
  bImportar: TButton; PBExportacion: TProgressBar);
var
  xls: TLibroOpenCalc;
  i, j: integer;
  kfil, jcol: integer;
  ctipo: char;
  ts: string;
  cursorAnterior: TCursor;
begin
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  if PBExportacion <> nil then
  begin
    PBExportacion.Min := filaIni;
    PBExportacion.Max := filaFin div 64 + 1;
    PBExportacion.Position := filaIni;
    PBExportacion.Step := 1;
  end;

  xls := TLibroOpenCalc.Create(True);
  try
    xls.go('x', 1, 1);
    for i := filaIni to filaFin do
    begin
      kfil := i - nFilasEncabezado;
      for j := colIni to colFin do
      begin
        jcol := j - nColumnasEncabezado;
        if (kfil < 0) or (jcol < 0) then
          xls.Write(tabla.Cells[j, i])
        else
        begin
          ctipo := 's';
          if SeriesEnColumnas then
          begin
            if length(tiposSeries) > jcol then
              ctipo := tiposSeries[jcol + 1];
          end
          else
          begin
            if length(tiposSeries) > kfil then
              ctipo := tiposSeries[kfil + 1];
          end;

          ts := tabla.Cells[j, i];
          if ctipo <> 's' then
            if ts = '' then
              ts := '0';

          case ctipo of
            's':
              xls.Write(tabla.Cells[j, i]);
            'i':
              xls.Write(StrToInt(ts));
            'f':
              xls.Write(StrToFloat(ts));
            'd':
              xls.WriteDateTime(StrToDate(ts));
          end;
        end;
      end;
      xls.writeln;
      if (PBExportacion <> nil) and (i mod 64 = 0) then
        PBExportacion.StepIt;
    end;
    bImportar.Enabled := True;
    xls.VisibleOn;
    Screen.Cursor := cursorAnterior;
  except
    Screen.Cursor := cursorAnterior;
    xls.Free;
  end;
  xls.Free;
end;

procedure importarTablaDesdeODS_1(tabla: TStringGrid;
  filaIni, filaFin, colIni, colFin: integer; bImportar: TButton;
  PBImportacion: TProgressBar;
  chequeoEncabezadosFila, chequeoEncabezadosColumna: boolean);
var
  xls: TLibroOpenCalc;
  i, j: integer;
  encabsIguales: boolean;
  valCeldaReal: double;
  valCelda: string;
  cursorAnterior: TCursor;
begin
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  bImportar.Enabled := False;
  xls := TLibroOpenCalc.Create(False);
  try
    xls.VisibleOff;
    xls.ActivoHoja_numero(1);
    encabsIguales := True;

    if PBImportacion <> nil then
    begin
      PBImportacion.Min := filaIni;
      if tabla.FixedCols >= 1 then
        PBImportacion.Max := tabla.RowCount div 64 + filaFin div 64 + 2
      else
        PBImportacion.Max := tabla.FixedRows div 64 + filaFin div 64 + 2;
      PBImportacion.Position := filaIni;
      PBImportacion.Step := 1;
    end;

    // Chequeo que los encabezados sean los mismos
    xls.ir(1, 1);

    if chequeoEncabezadosFila then
    begin
      for i := 0 to tabla.FixedRows - 1 do
      begin
        for j := 0 to tabla.ColCount - 1 do
        begin
          valCelda := xls.ReadV_Str;
          encabsIguales := tabla.Cells[j, i] = valCelda;
          if not encabsIguales then
            break;
        end;
        xls.readln;
        if (PBImportacion <> nil) and (i mod 64 = 0) then
          PBImportacion.StepIt;
      end;
    end
    else
      encabsIguales := True;

    if encabsIguales and chequeoEncabezadosColumna then
    begin
      for j := 0 to tabla.FixedCols - 1 do
        for i := tabla.FixedRows to tabla.RowCount - 1 do
        begin
          xls.ir(i + 1, j + 1);
          valCelda := xls.ReadV_Str;
          encabsIguales := tabla.Cells[j, i] = valCelda;
          if not encabsIguales then
            break;
          if (PBImportacion <> nil) and (i mod 64 = 0) then
            PBImportacion.StepIt;
        end;
    end;

    // Termine de chequear los encabezados
    if encabsIguales then
    begin
      for i := filaIni to filaFin do
      begin
        xls.ir(i + 1, colIni + 1);
        for j := colIni to colFin do
          try
            valCeldaReal := xls.ReadV_Float;
            tabla.Cells[j, i] := FloatToStrF(valCeldaReal, ffGeneral, 12, 3);
          except
            tabla.Cells[j, i] := xls.ReadV_Str;
          end;
        if (PBImportacion <> nil) and (i mod 64 = 0) then
          PBImportacion.StepIt;
      end;
    end
    else
      raise Exception.Create(
        'Los encabezados en el ODS difieren de los encabezados en la tabla.'
        );
  finally
    Screen.Cursor := cursorAnterior;
  end;

  xls.Free;
  Screen.Cursor := cursorAnterior;
end;



// Asumen filaIni = tabla.fixedRows, colIni = tabla.fixedCols,
// filaFin = tabla.RowCount - 1 y colFin = tabla.ColCount - 1
procedure exportarTablaAODS_2(tabla: TStringGrid; bImportar: TButton;
  PBExportacion: TProgressBar);
var
  seriesEnColumnas: boolean;
  defTipos: string;
  nFilas, nColumnas: integer;
  nSeries: integer;
  k: integer;

begin
  nFilas := tabla.RowCount - tabla.FixedRows;
  nColumnas := tabla.ColCount - tabla.FixedCols;

  if (nFilas > nColumnas) then
  begin
    SeriesEnColumnas := True;
    nSeries := nColumnas;
  end
  else
  begin
    SeriesEnColumnas := False;
    nSeries := nFilas;
  end;

  SetLength(defTipos, nSeries);
  for k := 1 to nSeries do
    defTipos[k] := 'f';

  exportarTablaAODS_1(
    tabla, 0,
    tabla.RowCount - 1,
    0,
    tabla.ColCount - 1,
    tabla.FixedRows,
    tabla.FixedCols,
    SeriesEnColumnas,
    defTipos,
    bImportar,
    PBExportacion);
end;

procedure importarTablaDesdeODS_2(tabla: TStringGrid; bImportar: TButton;
  PBImportacion: TProgressBar;
  chequeoEncabezadosFila, chequeoEncabezadosColumna: boolean);
begin
  importarTablaDesdeODS_1(tabla, tabla.FixedRows, tabla.RowCount - 1,
    tabla.FixedCols, tabla.ColCount - 1, bImportar, PBImportacion,
    chequeoEncabezadosFila, chequeoEncabezadosColumna);
end;



procedure exportarDatosHorariosAODS(const datos: TDAOfNreal;
  fechaIni: TDateTime; bImportar: TButton; PBExportacion: TProgressBar);
var
  NDias, iHora, iDia: integer;
  cursorAnterior: TCursor;
  dtDia: TDateTime;
  xls: TLibroOpenCalc;

begin
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  NDias := length(datos) div 24;

  if PBExportacion <> nil then
  begin
    PBExportacion.Min := 0;
    PBExportacion.Max := NDias div 30;
    PBExportacion.Position := 0;
    PBExportacion.Step := 1;
  end;

  xls := TLibroOpenCalc.Create(True);

  try
    xls.go('x', 1, 1);

    xls.Write('');
    for iHora := 0 to 23 do
      xls.Write(ihora);
    xls.writeln;

    try
      setSeparadoresGlobales;
      for iDia := 1 to NDias do
      begin
        dtDia := trunc(fechaIni + iDia - 1 + dt_medio_Minuto);
        xls.WriteDateTime(dtDia, 'yyyy-mm-dd');
        for iHora := 0 to 23 do
          xls.Write(datos[(iDia - 1) * 24 + iHora]);
        xls.writeln;
        if (PBExportacion <> nil) and (iDia mod 30 = 0) then
          PBExportacion.StepIt;
      end;
    finally
      setSeparadoresLocales;
    end;
    bImportar.Enabled := True;
    xls.VisibleOn;
    Screen.Cursor := cursorAnterior;
  except
    Screen.Cursor := cursorAnterior;
  end;
  xls.Free;
end;


procedure importarDatosHorariosDesdeODS(var datos: TDAOfNReal;
  var fechaIni: TDateTime; bImportar: TButton; PBImportacion: TProgressBar;
  chequeoEncabezadosFila, chequeoEncabezadosColumna: boolean);
var
  i, j: integer;
  valr: double;
  vali: integer;
  vals: string;
  cursorAnterior: TCursor;
  buscando: boolean;
  iHora, iDia: integer;
  irow, irow_PrimerDia, irow_UltimoDia: integer;
  icol: integer;
  NDias: integer;
  xls: TLibroOpenCalc;

begin
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  setSeparadoresGlobales;

  bImportar.Enabled := False;
  xls := TLibroOpenCalc.Create(False);
  try
    xls.VisibleOff;
    xls.ActivoHoja_numero(1);

    irow := 1;
    icol := 2;
    xls.ir(irow, icol);
    buscando := True;

    while buscando and (irow < 1000) do
    begin
      vali := xls.ReadV_Int;
      if vali = 0 then
        buscando := False
      else
      begin
        Inc(irow);
        xls.ir(irow, icol);
      end;
    end;

    if buscando then
      raise Exception.Create(RS_NoSeEncontroFilaDeInicio);

    buscando := False;
    for iHora := 1 to 23 do
    begin
      vali := xls.ReadV_int;
      if vali <> iHora then
        raise Exception.Create(RS_NoSeEncontroFilaDeInicio);
    end;
    irow_primerDia := irow + 1;
    xls.ir(irow_primerDia, 1);
    valr := xls.ReadV_Float;
    vals := DateTimeToStr(valr);
    FechaIni := StrToDateTime(vals);
    buscando := True;
    irow_ultimoDia := irow_primerDia;
    while buscando and (irow_UltimoDia < 65536) do
    begin
      vals := xls.ReadV_Str;
      if vals = '' then
        buscando := False
      else
      begin
        Inc(irow_UltimoDia);
        xls.ir(irow_UltimoDia, 2);
      end;
    end;

    if buscando then
      raise Exception.Create(RS_NoSeEncontroFinDeDatosHorarios);


    Dec(irow_UltimoDia);
    NDias := irow_UltimoDia - irow_PrimerDia + 1;
    setlength(datos, NDias * 24);


    if PBImportacion <> nil then
    begin
      PBImportacion.Min := 0;
      PBImportacion.Max := NDias div 30;
      PBImportacion.Position := 0;
      PBImportacion.Step := 1;
    end;


    for iDia := 0 to NDias - 1 do
    begin
      xls.ir(irow_PrimerDia + iDia, 2);
      for ihora := 0 to 23 do
        datos[iDia * 24 + ihora] := xls.ReadV_Float;
      if (PBImportacion <> nil) and (iDia mod 30 = 0) then
        PBImportacion.StepIt;
    end;

  finally
    setSeparadoresLocales;
    Screen.Cursor := cursorAnterior;
  end;
  xls.Free;
  Screen.Cursor := cursorAnterior;
end;




procedure exportarStrBoolAODS(strbool: string; bImportar: TButton);
var
  k: integer;
  c: char;
  cursorAnterior: TCursor;
  xls: TLibroOpenCalc;
begin
  xls := TLibroOpenCalc.Create(True);
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  try
    xls.go('x', 1, 1);
    for k := 1 to length(strbool) do
    begin
      c := strbool[k];
      case c of
        '1', '0': xls.Write(c);
        #13: xls.writeln;
      end;
    end;
    bImportar.Enabled := True;
    xls.VisibleOn;
    Screen.Cursor := cursorAnterior;
  except
    Screen.Cursor := cursorAnterior;
  end;
  xls.Free;
end;



procedure exportar_FichasLPD_aODS(fichas: TFichasLPD; bExportar, bImportar: TButton);
var
  k, j: integer;
  c: char;
  cursorAnterior: TCursor;
  aF: TFichaLPD;
  camposDefs: TCosa_RecLnk;
  acd: TCosa_CampoLnk;
  xls: TLibroOpenCalc;
begin
  setSeparadoresGlobales;
  for k := 0 to Fichas.Count - 1 do
  begin
    aF := fichas[k];
    if aF.periodicidad <> nil then
    begin
      ShowMessage('Lo siento, pero por ahora no está implementado exportar fichas con PERIODICIDAD');
      exit;
    end;
  end;

  bExportar.Enabled := False;
  bImportar.Enabled := False;

  xls := TLibroOpenCalc.Create(True);
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  try
    xls.go('x', 1, 1);
    af := fichas[0];
    camposDefs := af.rec_lnk;
    for j := 0 to camposDefs.Count - 1 do
    begin
      acd := camposDefs[j];
      xls.Write(acd.nombre);
    end;
    xls.writeln;

    for k := 0 to fichas.Count - 1 do
    begin
      af := fichas[k];
      camposDefs := af.rec_lnk;
      for j := 0 to camposDefs.Count - 1 do
      begin
        acd := camposDefs[j];
        if j = 1 then
          xls.WriteDateTime(StrToDateTime(acd.GetStrVal), 'yyyy-mm-dd hh')
        else
        begin
          if acd.CampoDef is TCosa_CampoDef_Boolean then
             xls.Write( StrToBool( acd.GetStrVal ) )
          else if ( acd.CampoDef is TCosa_CampoDef_DateTime )
             or ( acd.CampoDef is TCosa_CampoDef_Fecha ) then
             xls.WriteDateTime(StrToDateTime(acd.GetStrVal), 'yyyy-mm-dd hh')
          else if acd.CampoDef is TCosa_CampoDef_Float then
             xls.Write(StrToFloat(acd.GetStrVal))
          else if acd.CampoDef is TCosa_CampoDef_Integer then
             xls.Write(StrToInt(acd.GetStrVal))
          else
             xls.Write(acd.GetStrVal);
        end;
      end;
      xls.writeln;
    end;

    bImportar.Enabled := True;
    xls.VisibleOn;
    Screen.Cursor := cursorAnterior;
  except
    Screen.Cursor := cursorAnterior;
  end;
  xls.Free;
  setSeparadoresLocales;
end;




procedure importar_FichasLPD_DesdeODS(var fichas: TFichasLPD;
  Evaluador: TEvaluadorConCatalogo; bExportar, bImportar: TButton);

var
  i, j: integer;
  valCelda: string;
  cursorAnterior: TCursor;
  col: integer;
  res: string;
  NCols: integer;
  buscando: boolean;
  fecha_str: string;

  aF: TFichaLPD;
  camposDefs: TCosa_RecLnk;
  acl: TCosa_CampoLnk;

  s: string;
  av_s: string;
  av_f: double;
  av_i: integer;
  av_d: TDateTime;
  av_b: boolean;

  aF0: TFichaLPD;
  dt: double;
  xls: TLibroOpenCalc;

begin
  setSeparadoresGlobales;
  bExportar.Enabled := False;
  bImportar.Enabled := False;

  res := '';
  aF0 := Fichas[0];
  for j := 1 to fichas.Count - 1 do
    Fichas[j].Free;

  fichas.Clear;

  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  xls := TLibroOpenCalc.Create(False);
  try
    xls.VisibleOff;
    xls.ActivoHoja_numero(1);
    xls.ir(2, 1);
    col := 0;
    s := xls.ReadV_str;
    while s <> '' do
    begin
      af := aF0.Create_Clone(nil, 0) as TFichaLPD;
      camposDefs := af.rec_lnk;
      acl := camposDefs[0];
      acl.SetStrVal(s, evaluador);
      for j := 1 to camposDefs.Count - 1 do
      begin
        acl := camposDefs[j];
        if acl.CampoDef is TCosa_CampoDef_Boolean then
        begin
           av_b:= xls.ReadV_bool;
           s:= BoolToStr( av_b );
        end
        else if ( acl.CampoDef is TCosa_CampoDef_DateTime )
           or ( acl.CampoDef is TCosa_CampoDef_Fecha ) then
        begin
           av_d:= xls.ReadV_Float;
           s:= DateTimeToStr( av_d );
        end
        else if acl.CampoDef is TCosa_CampoDef_Float then
        begin
           av_f:= xls.ReadV_Float;
           s:= FloatToStr( av_f );
        end
        else if acl.CampoDef is TCosa_CampoDef_Integer then
        begin
           av_i:= xls.ReadV_Int;
           s:= IntToStr( av_i );
        end
        else
           s:= xls.ReadV_Str;

        acl.SetStrVal(s, evaluador);

      end;
      xls.readln;
      fichas.Add(af);
      s := xls.ReadV_str;
    end;
  finally
    Screen.Cursor := cursorAnterior;
  end;

  xls.Free;
  aF0.Free;
  Screen.Cursor := cursorAnterior;
  bExportar.Enabled := True;
  setSeparadoresLocales;
end;



function importarStrBoolDesdeODS(bImportar: TButton; nbinsPorLinea: integer;
  NCols_buscar, NFils_Buscar: integer): string;

var
  i, j: integer;
  valCelda: string;
  cursorAnterior: TCursor;
  col: integer;
  res: string;
  xls: TLibroOpenCalc;
begin
  res := '';
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  bImportar.Enabled := False;
  xls := TLibroOpenCalc.Create(False);
  try
    xls.VisibleOff;
    xls.ActivoHoja_numero(1);
    xls.ir(1, 1);
    col := 0;

    for i := 1 to NCols_buscar do
    begin
      for j := 1 to NFils_Buscar do
      begin
        valCelda := xls.ReadV_Str;
        if (valCelda = '1') or (valCelda = '0') then
        begin
          res := res + valCelda;
          Inc(col);
          if col = nbinsPorLinea then
          begin
            res := res + #13#10;
            col := 0;
          end;
        end
        else
          break;
      end;
      xls.readln;
    end;
    Result := res;
  finally
    Screen.Cursor := cursorAnterior;
  end;
  xls.Free;
  Screen.Cursor := cursorAnterior;
end;

end.
