unit usimres3;

interface

uses
{$IFDEF WINDOWS}
  ComObj,
{$ENDIF}
  uExcelFile,

// Graphics,
  uHistoVarsOps,
  uTSimRes,
  Classes, SysUtils, xMatDefs,
  uPostOpers,
  uPrintCronVars,
  uSimResGlobs,
  uConstantesSimSEE,
  uLectorSimRes3Defs,
  uauxiliares;

type
  TProcNotificar = procedure of object;
  TProcInitNotificar = procedure(nPasosNotificacion: integer;
    const estado: string) of object;

var
  procInitNotificar: TProcInitNotificar;
  procNotificar: TProcNotificar;

procedure run(const archiDefs: string; const nombreLibroSalida: string;
  mostrar: boolean);


resourcestring
  RS_PROCESANDO_CRONOPERS = 'Procesando Operaciones Crónicas';
  RS_PROCESANDO_POSTOPERS = 'Procesando Post Operaciones';
  RS_COPIANDO_RESULTADOS_Y_GRAFICANDO = 'Copiando Resultados y Realizando Gráficos';
  RS_LEYENDO_DEFINICIONES = 'Leyendo definiciones:';
  RS_BARRIDO_EVALUAR = 'Barrido Evaluar';
  RS_BARRIDO_ESCRIBIR = 'Barrido Escribir';


implementation

var
  lector: TLectorSimRes3Defs;


{$IFDEF PALETACOLORES}
procedure revisarPaletaColores(xls: TExcelFile);
var
  nColoresTotal: integer;
  coloresPrints: array of TDAOfTColor;
  i, j, k, iColoresATenerEnLaPaleta: integer;
  yaEstaColor: boolean;
  coloresATenerEnLaPaleta: array of TColor;
  paletaCorregida: TPaletaColoresExcel;
begin
  nColoresTotal := 0;
  SetLength(coloresPrints, lector.lstPrintCronVars.Count);
  for i := 0 to lector.lstPrintCronVars.Count - 1 do
  begin
    coloresPrints[i] := TPrintCronVar(lector.lstPrintCronVars[i]).getColores;
    nColoresTotal := nColoresTotal + Length(coloresPrints[i]);
  end;

  iColoresATenerEnLaPaleta := 0;
  SetLength(coloresATenerEnLaPaleta, nColoresTotal);
  for i := 0 to High(coloresPrints) do
  begin
    for j := 0 to high(coloresPrints[i]) do
    begin
      yaEstaColor := False;
      for k := 0 to iColoresATenerEnLaPaleta - 1 do
        if coloresPrints[i][j] = coloresATenerEnLaPaleta[k] then
        begin
          yaEstaColor := True;
          break;
        end;

      if not yaEstaColor then
      begin
        coloresATenerEnLaPaleta[iColoresATenerEnLaPaleta] := coloresPrints[i][j];
        iColoresATenerEnLaPaleta := iColoresATenerEnLaPaleta + 1;
      end;
    end;
  end;

  if Length(coloresATenerEnLaPaleta) <> iColoresATenerEnLaPaleta then
    SetLength(coloresATenerEnLaPaleta, iColoresATenerEnLaPaleta);
  paletaCorregida := uExcelFile.corregirPaletaColores(coloresATenerEnLaPaleta,
    paletaExcelPorDefecto);
  xls.setPaletaColores(paletaCorregida);
end;

{$ENDIF}

procedure BarridoEvaluar;
var
  kPaso, iCronOper, iPostOpers, iSimRes: integer;
begin
  if Assigned(procInitNotificar) then
    procInitNotificar(lector.simRes.nCronicas, RS_PROCESANDO_CRONOPERS);
  try
    uauxiliares.setSeparadoresGlobales;
    //simRes es el simRes de la lista que tenga menor número de crónicas
    while not lector.simRes.EOF do
    begin
      for iSimRes := 0 to lector.lstSimRes_.Count - 1 do
        TResultadoSim(lector.lstSimRes_[iSimRes]).Next;

      kPaso := round(lector.simRes.rec[0]);
      if (uSimResGlobs.iCronica <> lector.simRes.iCronica - 1) then
      begin
        uSimResGlobs.iCronica := lector.simRes.iCronica - 1;
        if ((uSimResGlobs.iCronica - 1) mod 100 = 0) then
          Writeln('Procesando Crónica ' + IntToStr(uSimResGlobs.iCronica));
      end;
      if assigned(procNotificar) and (kPaso = lector.simRes.nPasos) then
        procNotificar;

      if (kPaso >= lector.kPasoDesde) and (kPaso < lector.kPasoHasta) then
      begin
        uSimResGlobs.iPaso := kPaso - lector.kPasoDesde;

        for iCronOper := 0 to lector.lstCronOpers.Count - 1 do
        begin
          TCronOper(lector.lstCronOpers[iCronOper]).Evaluar;
        end;
      end;

    end;
  finally
    uauxiliares.setSeparadoresLocales;
  end;

  if lector.simRes.iCronica <> lector.simRes.ncronicas then
    raise Exception.Create( 'ERROR. Se esperaban: '+IntToStr( lector.simRes.ncronicas )
      +' y se procesaron: '+INtToStr( lector.simRes.iCronica )+' crónicas.'
      +' Es posible que se haya interrupido la simulación y está analizando archivos truncados.' );
  if kPaso <>  lector.simRes.nPasos then
    raise Exception.Create( 'ERROR. Se esperaban: '+IntToStr( lector.simRes.nPasos )
      +' y se procesaron: '+INtToStr( kPaso )+' pasos de tiempo.'
      +' Es posible que se haya interrupido la simulación y está analizando archivos truncados.' );


  if Assigned(procInitNotificar) then
    procInitNotificar(lector.lstPostOpers.Count, RS_PROCESANDO_POSTOPERS);

  for iPostOpers := 0 to lector.lstPostOpers.Count - 1 do
  begin
    writeln('Ejecutando PostOper: ', TPostOper(lector.lstPostOpers[iPostOpers]).ClassName);
    TPostOper(lector.lstPostOpers[iPostOpers]).Prepararse;
    TPostOper(lector.lstPostOpers[iPostOpers]).Evaluar;
    if assigned(procNotificar) then
      procNotificar;
  end;
end;

procedure BarridoEvaluarPRUEBA;
var
  kPaso, iCronOper, iPostOpers, iSimRes: integer;
  res: TResultadoSim;
begin

  if Assigned(procInitNotificar) then
    procInitNotificar(lector.simRes.nCronicas, RS_PROCESANDO_CRONOPERS);

  try
    uauxiliares.setSeparadoresGlobales;

    //Para procesar cada uno de los simRes
    for iSimRes := 0 to lector.lstSimRes_.Count - 1 do
    begin
      res := TResultadoSim(lector.lstSimRes_[iSimRes]);
      while not res.EOF do //para recorrer todo el archivo
      begin
        res.Next;//Cargo el rec
        kPaso := round(res.rec[0]);//cargo el paso en kpaso
        Writeln('Procesando Crónica' + IntToStr(res.iCronica) +
          ', kPaso: ' + IntToStr(kPaso));
        for iCronOper := 0 to lector.lstCronOpers.Count - 1 do
          TCronOper(lector.lstCronOpers[iCronOper]).Evaluar;
      end;
    end;


  finally
    uauxiliares.setSeparadoresLocales;
  end;

  if Assigned(procInitNotificar) then
    procInitNotificar(lector.lstPostOpers.Count, RS_PROCESANDO_POSTOPERS);

  for iPostOpers := 0 to lector.lstPostOpers.Count - 1 do
  begin
    writeln('Ejecutando PostOper: ',
      TPostOper(lector.lstPostOpers[iPostOpers]).ClassName);
    TPostOper(lector.lstPostOpers[iPostOpers]).Evaluar;
    if assigned(procNotificar) then
      procNotificar;
  end;
end;


procedure barridoChequearParamsEscribir;
var
  iPrintCronVars, iError: integer;
  printCronVar: TPrintCronVar;
  erroresGlobales, erroresPrintCronVar: TStringList;
begin
  erroresPrintCronVar := TStringList.Create;
  erroresGlobales := TStringList.Create;
  erroresGlobales.QuoteChar := '''';
  for iPrintCronVars := 0 to lector.lstPrintCronVars.Count - 1 do
  begin
    printCronVar := lector.lstPrintCronVars[iPrintCronVars];
    printCronVar.checkParams(erroresPrintCronVar);

    if erroresPrintCronVar.Count <> 0 then
    begin
      erroresGlobales.Add('');
      erroresGlobales.Add('En la printCronVar "' + printCronVar.titulo + '":');
      for iError := 0 to erroresPrintCronVar.Count - 1 do
        erroresGlobales.Add(erroresPrintCronVar[iError]);
      erroresPrintCronVar.Clear;
    end;
  end;
  if erroresGlobales.Count <> 0 then
  begin
    erroresGlobales.Delimiter := #13;
    raise Exception.Create('Se encontraron los siguientes errores al momento de imprimir:'#13 + erroresGlobales.DelimitedText + #13#13 + 'Corrijalos y vuelva a intentarlo.');
  end;
end;

procedure BarridoEscribir(nombreLibroSalida: string; mostrar: boolean);
var
  iPrintCronVars: integer;
  xls: TExcelFile;
  printCronVar: TPrintCronVar;
  //  wordApp: Variant;
  usa_excel: boolean;
  iPrint: integer;
  carpeta_destino: string;
begin
  uauxiliares.setSeparadoresGlobales;

  if assigned(procInitNotificar) then
    procInitNotificar(lector.lstPrintCronVars.Count,
      RS_COPIANDO_RESULTADOS_Y_GRAFICANDO);

  barridoChequearParamsEscribir;

  // guardar resultados coleccionados

  carpeta_destino := quitarExtension(nombreLibroSalida);


{$IFNDEF SIMRES3SOLOTEXTO}
  if mostrar or (nombreLibroSalida <> '') then
  begin

    // PRIMERO CHEQUEAMOS SI ALGUNA DE LAS PRINT QUIERE USAR EXCEL
    usa_excel := False;
    iPrint := 0;
    while (not usa_excel) and (iPrint < lector.lstPrintCronVars.Count) do
    begin
      usa_excel := TPrintCronVar(lector.lstPrintCronVars[iPrint]).usa_excel;
      Inc(iPrint);
    end;


    if usa_excel then
    begin
      writeln('voy a crear libro Excel');
      xls := TExcelFile.Create('x', False, False, True);
      writeln('volví de crear libro Excel');


    {$IFDEF PALETACOLORES}
      if xls.version < versionOffice2007 then
        revisarPaletaColores(xls);
    {$ENDIF}
    end
    else
      xls := nil;
  end
  else
{$ENDIF}
    xls := nil;


  try
    for iPrintCronVars := 0 to lector.lstPrintCronVars.Count - 1 do
    begin
      printCronVar := lector.lstPrintCronVars[iPrintCronVars];
      writeln('Ejecutando PrintCronVar ', printCronVar.tipo, ': ',
        printCronVar.titulo);
      if printCronVar is TPrintCronVar_R then
        TPrintCronVar_R(printCronVar).carpeta_destino := carpeta_destino;

      printCronVar.imprimirse(xls);
      if assigned(procNotificar) then
        procNotificar;
    end;
    writeln('... fin impresión  PrintCronVars ');
{$IFNDEF SIMRES3SOLOTEXTO}
    if (xls <> nil) and (nombreLibroSalida <> '') then
    begin
      writeln(' xls.Guardar(' + nombreLibroSalida + ') ... ');
      xls.VisibleOn;
      xls.Guardar(nombreLibroSalida);
      writeln(' ... volvi de guardar ... ');
    end;
{$ENDIF}
  finally
{$IFNDEF SIMRES3SOLOTEXTO}
    if xls <> nil then
    begin
      if mostrar then
        xls.VisibleOn
      else
      begin
        xls.Cerrar(False);
        // xls.Free;
      end;
    end;
{$ENDIF}
  end;
  uauxiliares.setSeparadoresLocales;
end;


procedure write_archi_ok( dir: string );
var
  f: textfile;
begin
      try
      filemode := 1;
      assignfile(f, dir + 'cmdsimres3_ok.txt');
      rewrite(f);
      writeln(f, 'OK');
      closefile(f);
    except
      writeln('fallo al escribir cmdsimres3_ok.txt');
      raise Exception.Create('Error al intentar escribir cmdsimres3_ok.txt');
    end;

end;

procedure run(const archiDefs: string; const nombreLibroSalida: string;
  mostrar: boolean);
var
  errores: TStringList;
  texto: string;
begin
  lector := TLectorSimRes3Defs.Create;
  try
    writeln(RS_LEYENDO_DEFINICIONES);
    writeln(archiDefs);
    lector.LeerDefiniciones(archiDefs, True, false );
    errores := TStringList.Create;
    if not lector.hayErrores(errores) then
    begin
     {$IFDEF pruebasDistSimRes3}
      lector.imprimir;
      BarridoEvaluarPRUEBA;
     {$ELSE}
      writeln(RS_BARRIDO_EVALUAR);
      BarridoEvaluar;
     {$ENDIF}
      writeln(RS_BARRIDO_ESCRIBIR);
      BarridoEscribir(nombreLibroSalida, mostrar);
    end
    else
    begin
      texto := 'Se encontraron los siguientes errores en el archivo de definiciones:'#13#10#13#10 + errores.Text + #13#10'Corríjalos e intentelo nuevamente.';
      raise Exception.Create(texto);
    end;

    lector.Free;
    lector:= nil;

    write_archi_ok( ExtractFilePath( archiDefs ) );

  except
    on E: Exception do
    begin
      if lector <> nil then
         lector.Free;
      raise;
    end;
  end;
end;


end.
