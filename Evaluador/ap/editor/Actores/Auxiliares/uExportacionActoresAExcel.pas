unit uExportacionActoresAExcel;

interface

uses
  uArcos, uExcelFile, Controls, StdCtrls, ComCtrls, Forms, SysUtils, uCosa,
  uFichasLPD, uActores, usalasdejuego, uExcelExportImport, uFechas, xmatdefs,
  XLConst, Dialogs, unodos, usalasdejuegoParaEditor, uresourcestring;

type
  TTiposColExportadas = (TCE_Fecha, TCE_String, TCE_Referencia, TCE_Entero,
    TCE_Real, TCE_Boolean);

  TExportadorImportadorCosas = class
  private
    procedure iniciarExportacion(maximoPB: Integer);
    procedure finalizarExportacion(error: boolean);

    procedure exportarUnidades(lpdUnidades: TFichasLPD);

    procedure aplicarFormatoAxls(filaFinActor, nFichas, colFinFichas,
      nUnidades: Integer);

    function iniciarImportacion(maximoPB: Integer): boolean;
    procedure finalizarImportacion(error: boolean);

    procedure avanzarPB;

    function contarFilasHastaBlanco: Integer;
    function contarFilasHastaBlancoYVolver: Integer;

    function chequearValidez(filaInicial, filaFinal, columnaInicial: Integer;
      const tiposColumnas: array of TTiposColExportadas): boolean; overload;
    function chequearValidez(filaInicial, columnaInicial: Integer;
      const tiposColumnas: array of TTiposColExportadas): boolean;
      overload;

    function msjError(fila, columna: Integer;
      tipoColumna: TTiposColExportadas): String;
  public
    cursorAnterior: TCursor;
    bImportar: TButton;
    pb: TProgressBar;
    xls: TExcelFile;
    sala: TSalaDeJuego;

    Constructor Create(bImportar: TButton; pb: TProgressBar;
      sala: TSalaDeJuego);
    Destructor Destroy; override;

    // Arcos
    procedure exportarArcoAExcel(arco: TArco);
    procedure importarArcoDeExcel(var arco: TArco);

    // Generadores

    // Nodos

    // Demandas

  end;

implementation

{ TExportadorImportadorActores }

Constructor TExportadorImportadorCosas.Create(bImportar: TButton;
  pb: TProgressBar; sala: TSalaDeJuego);
begin
  inherited Create;
  self.bImportar := bImportar;
  self.pb := pb;
  self.sala := sala;
end;

destructor TExportadorImportadorCosas.Destroy;
begin
  inherited Destroy;
end;

procedure TExportadorImportadorCosas.iniciarExportacion(maximoPB: Integer);
begin
  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  if pb <> NIL then
  begin
    pb.Min := 0;
    pb.Max := maximoPB;
    pb.Position := 0;
    pb.Step := 1;
  end;

  if xls = NIL then
    xls := TExcelFile.Create('x', False, True, False)
  else
  begin
    if not xls.libroAbierto then
    begin
      xls.agregoLibro;
      xls.agregoHoja('x');
    end;
    xls.VisibleOff;
  end;
end;

procedure TExportadorImportadorCosas.finalizarExportacion(error: boolean);
begin
  if not error then
  begin
    xls.ir(1, 1);
    xls.autoFitCells;
    xls.VisibleOn;
    Screen.Cursor := cursorAnterior;
    bImportar.Enabled := True;
  end
  else
  begin
    Screen.Cursor := cursorAnterior;
    xls.Cerrar(False);
    xls.Free;
    xls := NIL;
  end;
end;

procedure TExportadorImportadorCosas.aplicarFormatoAxls(filaFinActor, nFichas,
  colFinFichas, nUnidades: Integer);
var
  filaInicioFichas, filaInicioUnidades: Integer;
begin
  xls.SelRango(1, 1, filaFinActor, 1);
  xls.BoldON;

  if nFichas >= 0 then
  begin
    filaInicioFichas := filaFinActor + 2;
    xls.SelRango(filaInicioFichas, 1, filaInicioFichas + nFichas, colFinFichas);
    xls.BoldON;
    xls.BordeSimple(xlThin, False, False, True, False, False, False);
    xls.SelRango(filaInicioFichas, 1, filaInicioFichas + nFichas, 1);
    xls.BordeSimple(xlThin, False, True, False, False, False, False);
  end;

  if nUnidades >= 0 then
  begin
    if nFichas >= 0 then
      filaInicioUnidades := filaInicioFichas + nFichas + 2
    else
      filaInicioUnidades := filaFinActor + 2;

    xls.SelRango(filaInicioUnidades, 1, filaInicioUnidades + nUnidades, 2);
    xls.BoldON;
    xls.BordeSimple(xlThin, False, False, True, False, False, False);
    xls.SelRango(filaInicioUnidades, 1, filaInicioUnidades + nUnidades, 1);
    xls.BordeSimple(xlThin, False, True, False, False, False, False);
  end;
end;

function TExportadorImportadorCosas.iniciarImportacion(maximoPB: Integer)
  : boolean;
begin
  if (xls <> NIL) and not estaEnModoEdicion then
  begin
    bImportar.Enabled := False;
    if not xls.libroAbierto then
    begin
      xls.Free;
      xls := NIL;
      Result := False;
    end
    else
    begin
      cursorAnterior := Screen.Cursor;
      Screen.Cursor := crHourGlass;
      Result := True;
    end
  end
  else
    Result := False;
end;

procedure TExportadorImportadorCosas.finalizarImportacion(error: boolean);
begin

end;

procedure TExportadorImportadorCosas.avanzarPB;
begin
  if pb <> NIL then
  begin
    pb.StepIt;
    Application.ProcessMessages;
  end;
end;

function TExportadorImportadorCosas.msjError(fila, columna: Integer;
  tipoColumna: TTiposColExportadas): String;
var
  res: String;
begin
  res := mesEnLaCelda + xls.nroColToExcelCol(columna) + IntToStr(fila)
    + mesNoHay;
  case tipoColumna of
    TCE_Fecha:
      res := res + mesUnaFechaValida;
    TCE_String:
      res := res + mesUnStringValido;
    TCE_Referencia:
      res := res + mesUnaReferenciaValida;
    TCE_Entero:
      res := res + mesUnEnteroValido;
    TCE_Real:
      res := res + mesUnRealValido;
    TCE_Boolean:
      res := res + mesUnBooleanoValido;
  end;
  Result := res;
end;

function TExportadorImportadorCosas.chequearValidez(filaInicial, filaFinal,
  columnaInicial: Integer; const tiposColumnas: array of TTiposColExportadas)
  : boolean;
var
  i, j, nFilas: Integer;
  aux: String;
begin
  nFilas := filaFinal - filaInicial + 1;
  Result := True;
  for i := 0 to nFilas - 1 do
  begin
    for j := 0 to high(tiposColumnas) do
    begin
      aux := xls.ReadV_Str;
      case tiposColumnas[j] of
        TCE_Fecha:
          begin
            try
              IsoStrToDateTime(aux);
            except
              Result := False;
            end;
          end;
        TCE_String:
          ;
        TCE_Referencia:
          if buscarCosaConNombrePorReferencia(sala, aux) = NIL then
            Result := False;
        TCE_Entero:
          begin
            try
              StrToInt(aux);
            except
              Result := False;
            end;
          end;
        TCE_Real:
          begin
            try
              StrToFloat(aux);
            except
              Result := False;
            end;
          end;
        TCE_Boolean:
          begin
            try
              StrToBool(aux);
            except
              Result := False;
            end;
          end;
      end;
      if not Result then
      begin
        xls.ir(xls.fila + i, xls.columna + j);
        ShowMessage(msjError(xls.fila + i, xls.columna + j, tiposColumnas[j]));
        break;
      end;
    end;
  end;
end;

function TExportadorImportadorCosas.chequearValidez(filaInicial,
  columnaInicial: Integer; const tiposColumnas: array of TTiposColExportadas)
  : boolean;
var
  nFilas: Integer;
begin
  xls.ir(filaInicial, columnaInicial);
  nFilas := contarFilasHastaBlancoYVolver;
  Result := chequearValidez(filaInicial, filaInicial + nFilas, columnaInicial,
    tiposColumnas);
end;

function TExportadorImportadorCosas.contarFilasHastaBlanco: Integer;
var
  filaInicial, columnaInicial, res: Integer;
begin
  filaInicial := xls.fila;
  columnaInicial := xls.columna;
  res := 0;
  while xls.ReadV_Str <> '' do
  begin
    res := res + 1;
    xls.ir(filaInicial + res, columnaInicial);
  end;
  xls.ir(xls.fila, xls.columna - 1);
  Result := res;
end;

function TExportadorImportadorCosas.contarFilasHastaBlancoYVolver: Integer;
var
  filaInicial, columnaInicial, res: Integer;
begin
  filaInicial := xls.fila;
  columnaInicial := xls.columna;
  res := 0;
  while xls.ReadV_Str = '' do
  begin
    res := res + 1;
    xls.ir(filaInicial + res, columnaInicial);
  end;
  xls.ir(filaInicial, columnaInicial);
  Result := res;
end;

procedure TExportadorImportadorCosas.exportarUnidades(lpdUnidades: TFichasLPD);
var
  i: Integer;
  fichaUnidades: TFichaUnidades;
begin
  xls.Write_buffereado(rsFecha);
  xls.Write_buffereado(rsUnidades);
  xls.writelnBuffer;
  for i := 0 to lpdUnidades.Count - 1 do
  begin
    fichaUnidades := TFichaUnidades(lpdUnidades[i]);

    xls.Write_buffereado(fichaUnidades.fecha.AsISOStr);
    xls.Write_buffereado(fichaUnidades.nUnidades);
    xls.writelnBuffer;

    avanzarPB;
  end;
end;

procedure TExportadorImportadorCosas.exportarArcoAExcel(arco: TArco);
var
  i: Integer;
  ficha: TFichaArco;
begin
  iniciarExportacion(1 + arco.lpd.Count + arco.lpdUnidades.Count);
  try
    xls.go('x', 1, 1);

    // Actor
    xls.Write_buffereado(rsNombre);
    xls.Write_buffereado(arco.nombre);
    xls.writelnBuffer;
    xls.Write_buffereado(rsNodoEntrada);
    xls.Write_buffereado(referenciaACosa(arco.NodoA));
    xls.writelnBuffer;
    xls.Write_buffereado(rsNodoSalida);
    xls.Write_buffereado(referenciaACosa(arco.NodoB));
    xls.writelnBuffer;
    xls.writeln('');
    avanzarPB;

    // Fichas
    xls.Write_buffereado(rsFecha);
    xls.Write_buffereado(rsRendimientoPU);
    xls.Write_buffereado(rsPeaje);
    xls.Write_buffereado(rsFactorDeDisponibilidadPU);
    xls.Write_buffereado(rsTiempoDeReparacionH);
    xls.Write_buffereado(rsPotenciaMaxima);
    xls.writelnBuffer;
    for i := 0 to arco.lpd.Count - 1 do
    begin
      ficha := TFichaArco(arco.lpd[i]);

      xls.Write_buffereado(ficha.fecha.AsISOStr);
      xls.Write_buffereado(ficha.rendimiento);
      xls.Write_buffereado(ficha.peaje);
      xls.Write_buffereado(ficha.fd);
      xls.Write_buffereado(ficha.tRepHoras);
      xls.Write_buffereado(ficha.PMax);
      xls.writelnBuffer;
      avanzarPB;
    end;
    xls.writeln('');

    // Fichas Unidades
    exportarUnidades(arco.lpdUnidades);

    // Estilo
    aplicarFormatoAxls(3, arco.lpd.Count, 6, arco.lpdUnidades.Count);

    finalizarExportacion(False);
  except
    finalizarExportacion(True);
  end;
end;

procedure TExportadorImportadorCosas.importarArcoDeExcel(var arco: TArco);
var
  filaInicioFichas, nFichas, filaInicioUnidades, nFichasUnidades: Integer;
//  nuevoArco: TArco;

  aux: String;
  i, j: Integer;
  newFichasLpd: TFichasLPD;
  fecha: TFecha;
  rendimiento, peaje, fd, tRepHoras, PMax: Double;
  nUnidades: Integer;
  comparacionFechas: Integer;
  ficha: TFichaArco;
begin
  if iniciarImportacion(3) then
  begin
    try
      xls.VisibleOff;
      xls.ActivoHoja_numero(1);

      filaInicioFichas := contarFilasHastaBlanco + 2;
      nFichas := contarFilasHastaBlanco;
      filaInicioUnidades := filaInicioFichas + nFichas + 2;
      nFichasUnidades := contarFilasHastaBlanco;

      if chequearValidez(2, 3, 2, [TCE_Referencia]) and chequearValidez
        (filaInicioFichas, 1, [TCE_Fecha, TCE_Real, TCE_Real, TCE_Real,
        TCE_Real, TCE_Real]) and chequearValidez(filaInicioUnidades, 1,
        [TCE_Fecha, TCE_Entero]) then
      begin
        xls.ir(1, 2);
        arco.nombre := xls.ReadV_Str;

        xls.ir(2, 2);
        aux := xls.ReadV_Str;
        arco.NodoA := TNodo(buscarCosaConNombrePorReferencia(sala, aux));

        xls.ir(3, 2);
        aux := xls.ReadV_Str;
        arco.NodoB := TNodo(buscarCosaConNombrePorReferencia(sala, aux));

        newFichasLpd := TFichasLPD.Create(arco.lpd.idCarpeta,
          arco.lpd.Propietario, arco.lpd.tipo);
        j := 0;
        for i := 0 to nFichas - 1 do
        begin
          xls.ir(filaInicioFichas + 1 + i, 1);
          aux := xls.ReadV_Str;
          fecha := TFecha.Create_ISOStr(aux);
          rendimiento := xls.ReadV_Float;
          peaje := xls.ReadV_Float;
          fd := xls.ReadV_Float;
          tRepHoras := xls.ReadV_Float;
          PMax := xls.ReadV_Float;

          comparacionFechas := fecha.EsMayorQue(TFichaArco(arco.lpd[i]).fecha);
          // TODO
          if comparacionFechas = -1 then
          begin
            ficha := TFichaArco.Create(fecha, NIL, rendimiento, peaje, fd,
              tRepHoras, PMax);
            newFichasLpd.Add(ficha);
          end
          else if comparacionFechas = 0 then
          begin
            ficha := TFichaArco(arco.lpd[j]);
            ficha.fecha.Free;
            ficha.fecha := fecha;
            ficha.rendimiento := rendimiento;
            ficha.peaje := peaje;
            ficha.fd := fd;
            ficha.tRepHoras := tRepHoras;
            ficha.PMax := PMax;

            arco.lpd[j] := NIL;
            j := j + 1;
            newFichasLpd.Add(ficha);
          end
          else
            // Borrar fichas viejas hasta llegar a fecha
            { repeat
              arco.lpd[j].Free;
              arco.lpd[j] := NIL;
              j := j + 1;
              until ; }
          end;

          arco.lpdUnidades.ClearFreeElementos;
          for i := 0 to nFichasUnidades - 1 do
          begin
            xls.ir(filaInicioUnidades + 1 + i, 1);
            aux := xls.ReadV_Str;
            fecha := TFecha.Create_ISOStr(aux);
            nUnidades := xls.ReadV_Int;

            arco.lpdUnidades.Add(TFichaUnidades.Create(fecha, NIL, nUnidades));
          end;

          finalizarImportacion(False);
        end
        else
          xls.VisibleOn;
        finally
          Screen.Cursor := cursorAnterior;
          xls.Cerrar(False);
        end;
      end;
    end;

end.
