unit uEditarUnidades;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
 // Messages,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, ComCtrls, uBaseFormularios, uActores,
  utilidades, ufichasLPD,
  uunidades,
  usalasdejuegoParaEditor,
  uEditarFichaUnidades, uCosa, uVisorFichasExpandidas, uCosaConNombre,
  uverdoc,
  uopencalc,
  uopencalcexportimport,
  uSalasDeJuego, uConstantesSimSEE,
  uFechas,
  uOpcionesSimSEEEdit, uAuxiliares, xMatDefs;

resourcestring
  rsCapa = 'Capa';
  rsFechaDeInicio = 'Fecha de Inicio';
  rsNumeroDeMaquinas_Instaladas = 'Instaladas';
  rsNumeroDeMaquinas_EnMantenimiento = 'En M.Prog.';
  rsPeriodicaQ = 'Periodica?';
  mesConfirmaEliminarFicha = '¿Confirma que desea eliminar la ficha seleccionada?';
  mesActorDebeTener1Ficha =
    'El Actor debe tener al menos una ficha indicando la cantidad de unidades disponibles';

type

  { TEditarUnidades }

  TEditarUnidades = class( TBaseFormularios )
    BAgregarFicha: TButton;
    BAyuda: TButton;
    BCancelar: TButton;
    BGuardar: TButton;
    btExportar_ods: TButton;
    btImportar_ods: TButton;
    BVerExpandida: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    pb_EstadoImpExp: TProgressBar;
    sgUnidades: TStringGrid;
    procedure BAyudaClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure btExportar_odsClick(Sender: TObject);
    procedure btImportar_odsClick(Sender: TObject);
    procedure cb_AltaUnidades_CON_INCERTIDUMBREChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure sgUnidadesDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgUnidadesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgUnidadesMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure sgUnidadesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAgregarFichaClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BVerExpandidaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure sgUnidadesValidarCambio(Sender: TObject);
    procedure sgUnidadesGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
  private
    lista_aux: TFichasLPD;
    actor: TActor;
    tiposColsUnidades: TDAOfTTipoColumna;


    function editar(fila: integer; clonar: boolean): boolean;
    procedure eliminar(fila: integer);
    procedure actualizarTablaUnidades;
    function validarCambioTablaUnidades(listado: TStringGrid;
      fila, columna: integer): boolean;
    procedure cambioValorTablaUnidades(listado: TStringGrid; fila, columna: integer);
  public
    etiquetasUnidades: TDAofString;
    constructor Create(AOwner: TControl; xsala: TSalaDeJuego; actor: TActor;
      listaUnidades: TFichasLPD; etiquetasUnidades: TDAofString); reintroduce;
    function darLista_: TFichasLPD;
  end;

implementation

uses ueditor_resourcestrings, SimSEEEditMain;

{$R *.lfm}

constructor TEditarUnidades.Create(AOwner: TControl; xsala: TSalaDeJuego;
  actor: TActor; listaUnidades: TFichasLPD; etiquetasUnidades: TDAofString);
var
  etiquetas: array of string;
begin
  inherited Create_conSalaYEditor_(AOwner,xsala );

  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;

  listaUnidades.clearExpanded;
  lista_aux := listaUnidades.Create_Clone(rbtEditorSala.CatalogoReferencias, 0 ) as TFichasLPD;
  self.actor := actor;
  self.etiquetasUnidades := etiquetasUnidades;

  rbtEditorSala.CatalogoReferencias.resolver_referenciasDeCosa( lista_aux, sala.listaActores);
  rbtEditorSala.CatalogoReferencias.eliminar_referencias_del( lista_aux );

  //Aca escribo las etiquetas q salen en el formulario
  setlength(etiquetas, 8);
  etiquetas[0] := encabezadoTextoEditable + rsFechaDeInicio;
  etiquetas[1] := rsNumeroDeMaquinas_Instaladas;
  etiquetas[2] := rsNumeroDeMaquinas_EnMantenimiento;
  etiquetas[3] := rsPeriodicaQ;
  etiquetas[4] := rsCapa;
  etiquetas[5] := encabezadoBTEditar;
  etiquetas[6] := encabezadoBTEliminar;
  etiquetas[7] := encabezadoBTClonar;

  utilidades.initListado(sgUnidades, etiquetas, tiposColsUnidades, False);
  actualizarTablaUnidades;
  guardado := True;
end;

function TEditarUnidades.darLista_: TFichasLPD;
begin
  Result := lista_aux;
end;

function TEditarUnidades.editar(fila: integer; clonar: boolean): boolean;
var
  form: TEditarFichaUnidades;
  ficha: TFichaUnidades;
  res: boolean;
begin
  res := False;
  if fila = 0 then
    ficha := nil
  else
    ficha := TFichaUnidades( lista_aux[fila - 1]);

  form := TEditarFichaUnidades.Create(self, actor, ficha, nil, etiquetasUnidades);
  if form.ShowModal = mrOk then
  begin
    if ficha <> nil then
    begin
      if not clonar then
      begin
        lista_aux.Remove(ficha);
        ficha.Free;
      end;
    end;
    lista_aux.add(form.darFicha());
    actualizarTablaUnidades;
    guardado := False;
    res := True;
  end;
  form.Free;
  Result := res;
end;

procedure TEditarUnidades.eliminar(fila: integer);
begin
  if lista_aux.Count > 1 then
  begin
    if (Application.MessageBox(PChar(mesConfirmaEliminarFicha),
      PChar(mesConfirmarEliminacion), MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
    begin
      lista_aux[fila - 1].Free;
      lista_aux.Delete(fila - 1);
      actualizarTablaUnidades;
      guardado := False;
    end;
  end
  else
    ShowMessage(mesActorDebeTener1Ficha);
end;

procedure TEditarUnidades.actualizarTablaUnidades;
var
  i: integer;
  oldItemRow: TCosa;
begin
  if (sgUnidades.row > 0) and (sgUnidades.row < lista_aux.Count) then
    oldItemRow := lista_aux.items[sgUnidades.row - 1]
  else
    oldItemRow := nil;

  lista_aux.SortByFecha;

  sgUnidades.RowCount := lista_aux.Count + 1;
  if sgUnidades.RowCount > 1 then
    sgUnidades.FixedRows := 1
  else
    sgLimpiarSeleccion(sgUnidades);

  for i := 0 to lista_aux.Count - 1 do
  begin
    sgUnidades.cells[0, i + 1] :=
      FSimSEEEdit.fechaIniToString(TFichaUnidades(lista_aux[i]).fecha);
    sgUnidades.cells[1, i + 1] := TDAOfNIntToStringSinTamanio( TFichaUnidades(lista_aux[i]).nUnidades_Instaladas, ';' );
    sgUnidades.cells[2, i + 1] := TDAOfNIntToStringSinTamanio( TFichaUnidades(lista_aux[i]).nUnidades_EnMantenimiento, ';' );
    sgUnidades.Cells[3, i + 1] := boolToSiNo(TFichaLPD(lista_aux[i]).periodicidad <> nil);
    sgUnidades.Cells[4, i + 1] := IntToStr(TFichaUnidades(lista_aux[i]).capa);
  end;

  for i := 0 to sgUnidades.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgUnidades, i, tiposColsUnidades[i], iconos);

  BAgregarFicha.Left := sgUnidades.Left + sgUnidades.Width - BAgregarFicha.Width;
  BVerExpandida.Left := BAgregarFicha.Left - BVerExpandida.Width - 10;

  if oldItemRow <> nil then
    sgUnidades.Row := lista_aux.IndexOf(oldItemRow) + 1;

end;

function TEditarUnidades.validarCambioTablaUnidades(listado: TStringGrid;
  fila, columna: integer): boolean;
begin
  case columna of
    0:
      Result := inherited validarCeldaFecha(listado, fila, columna);
    1:
      Result := inherited validarCeldaNInt(listado, fila, columna);
    else
      Result := True;
  end;
end;

procedure TEditarUnidades.cambioValorTablaUnidades(listado: TStringGrid;
  fila, columna: integer);
begin
  if columna = 0 then //Fecha
  begin
    TFichaUnidades(lista_aux[fila - 1]).fecha.Free;
    TFichaUnidades(lista_aux[fila - 1]).fecha :=
      FSimSEEEdit.StringToFecha(listado.Cells[columna, fila]);
    guardado := False;
    actualizarTablaUnidades;
  end
  else if columna = 1 then //NUnidades_Instaladas
  begin
    TFichaUnidades(lista_aux[fila - 1]).nUnidades_Instaladas[0] :=
      StrToInt(listado.Cells[columna, fila]);
    guardado := False;
  end
  else if columna = 2 then //NUnidades_EnMantenimiento
  begin
    TFichaUnidades(lista_aux[fila - 1]).nUnidades_EnMantenimiento[0] :=
      StrToInt(listado.Cells[columna, fila]);
    guardado := False;
  end;
end;

procedure TEditarUnidades.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;






procedure exportarUnidadesAODS(
  Lista:TFichasLPD;
  bImportar: TButton;
  PBExportacion: TProgressBar);
var
  kfil, jCol: integer;
  ctipo: char;
  ts: string;
  cursorAnterior: TCursor;
  NFils: integer;
  NCols: integer;

 aFicha: TFichaUnidades;
 xls: TLibroOpenCalc;
begin

 // primero cheque si hay alguna ficha con periodicidad pues por ahora no
 // implemento exportar/importar con periodicidad.

  for kFil:= 0 to lista.count -1 do
  begin
    aFicha:= lista.f[kFil] as TFichaUnidades;
    if aFicha.periodicidad <> nil then
    begin
      showmessage('Lo siento, pero por ahora no está implementado exportar fichas con PERIODICIDAD');
      exit;
    end;
  end;


  aFicha:= lista.f[0] as TFichaUnidades;
  NCols:= length( aFicha.nUnidades_Instaladas );

  NFils := lista.count;

  cursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  if PBExportacion <> nil then
  begin
    PBExportacion.Min := 0;
    PBExportacion.Max := NCols;
    PBExportacion.Position := 0;
    PBExportacion.Step := 1;
  end;

  xls := TLibroOpenCalc.Create(True);
  try
    xls.go('x', 1, 1);

    xls.write( 'capa' );
    xls.write( 'Fecha' );
    for jCol := 1 to NCols do
    begin
      xls.Write( 'NU_Inst'+IntToStr( jCol ));
      xls.Write( 'NU_EnMP'+IntToStr( jCol ));
    end;
    for jCol := 1 to NCols do
      xls.write( 'AI_'+IntToStr( jCol ) );
    for jCol := 1 to NCols do
      xls.write( 'ICI_'+IntToStr( jCol ));
    xls.writeln('');


    for kFil := 0 to NFils - 1 do
    begin
      aFicha:= lista.f[kFil] as TFichaUnidades;

      xls.write( aFicha.capa );
      xls.WriteDateTime( aFicha.fecha.AsDt );

      for jCol := 0 to NCols - 1 do
      begin
        xls.Write( aFicha.nUnidades_Instaladas[jCol]);
        xls.Write( aFicha.nUnidades_EnMantenimiento[jCol]);
      end;

      for jCol := 0 to NCols - 1 do
        xls.Write( boolToInt( aFicha.AltaConIncertidumbre[jCol]));
      for jCol := 0 to NCols - 1 do
        xls.write( boolToInt( aFicha.InicioCronicaConIncertidumbre[jCol] ));

      xls.writeln;

      if (PBExportacion <> nil) then
        PBExportacion.StepIt;
    end;

    xls.SelRango( 1+1, 2, 1+NFils, 2);
    xls.CambiarFormato(  SysUtils.ShortDateFormat + ' hh' );

    bImportar.Enabled := True;
    xls.VisibleOn;
    Screen.Cursor := cursorAnterior;
  except
    Screen.Cursor := cursorAnterior;
  end;
  xls.Free;
end;


procedure importarUnidadesDesdeODS(
  var lista: TFichasLPD; bImportar: TButton;
  PBImportacion: TProgressBar );
var
  encabsIguales: boolean;
  valCeldaReal: double;
  valCelda: string;
  cursorAnterior: TCursor;
  kFil, jCol: integer;
  NCols, NFils: integer;
  s: string;
  aFicha: TFichaUnidades;

// auxiliares para armar las fichas
  capa: integer;
  dtfecha: TDateTime;
  fecha: TFecha;
  nUnidades_Instaladas, nUnidades_EnMantenimiento: TDAofNInt;
  AltaConIncertidumbre: TDAOfBoolean;
  InicioCronicaConIncertidumbre: TDAOfBoolean;

  res: TList;
  xls: TLibroOpenCalc;

begin
    aFicha:= lista.f[0] as TFichaUnidades;
    NCols:= length( aFicha.nUnidades_Instaladas );

    cursorAnterior := Screen.Cursor;
    Screen.Cursor := crHourGlass;

    bImportar.Enabled := False;
    xls:= TLibroOpenCalc.Create( false );
        try
          xls.VisibleOff;
          xls.ActivoHoja_numero(1);
          encabsIguales := True;

          setlength( nUnidades_Instaladas, NCols );
          setlength( nUnidades_EnMantenimiento, NCols );
          setlength( AltaConIncertidumbre, NCols );
          setlength( InicioCronicaConIncertidumbre, NCols );


          NFils := 0;
          s := trim(xls.ReadStr(2 + NFils, 1 + NCols));
          while (NFils < 1000) and (s <> '') do
          begin
            Inc(NFils);
            s := trim(xls.ReadStr(2 + NFils, 1 + NCols));
          end;

          if PBImportacion <> nil then
          begin
            PBImportacion.Min := 0;
            PBImportacion.Max := NFils;
            PBImportacion.Position := 0;
            PBImportacion.Step := 1;
          end;


          res:= TList.Create;

          xls.ir(1, 2);


          for kFil := 0 to NFils - 1 do
          begin
            capa:=  xls.ReadInt(2 + kFil, 1);
            dtFecha := xls.ReadFloat(2 + kFil, 2);
            Fecha:= TFecha.Create_Dt( dtFecha );

            for jCol := 0 to NCols - 1 do
            begin
              s := trim(xls.ReadStr(2 + kFil, 3 + jCol*2));
              nunidades_Instaladas[jCol] := StrToInt(s);
              s := trim(xls.ReadStr(2 + kFil, 3 + jCol*2+1));
              nunidades_EnMantenimiento[jCol] := StrToInt(s);
            end;

            for jCol := 0 to NCols - 1 do
            begin
              s := trim(xls.ReadStr(2 + kFil, 3+2*NCols + jCol));
              AltaConIncertidumbre[jCol] := s<>'0';
            end;

            for jCol := 0 to NCols - 1 do
            begin
              s := trim(xls.ReadStr(2 + kFil, 3+3*NCols + jCol));
              InicioCronicaConIncertidumbre[jCol] := s<>'0';
            end;

            aFicha:= TFichaUnidades.Create(capa, fecha, nil, nUnidades_Instaladas, nUnidades_EnMantenimiento, AltaConIncertidumbre, InicioCronicaConIncertidumbre );
            res.add( aFicha );
            if (PBImportacion <> nil) then
              PBImportacion.StepIt;
          end;
        finally
          Screen.Cursor := cursorAnterior;
        end;
      xls.Free;
      Screen.Cursor := cursorAnterior;
      lista.clearAll;
      for kFil:= 0 to res.count - 1 do
      begin
        aFicha:= res[kFil];
        lista.insertar( aFicha );
      end;

      setlength( nUnidades_Instaladas, 0 );
      setlength( nUnidades_EnMantenimiento, 0 );
      setlength( AltaConIncertidumbre, 0 );
      setlength( InicioCronicaConIncertidumbre, 0 );
end;





procedure TEditarUnidades.btExportar_odsClick(Sender: TObject);
begin
    exportarUnidadesAODS( lista_aux,
      self.btImportar_ods,
      self.pb_EstadoImpExp);
end;

procedure TEditarUnidades.btImportar_odsClick(Sender: TObject);
begin
  importarUnidadesDesdeODS( lista_aux,
   self.btImportar_ods,
   self.pb_EstadoImpExp);
  actualizarTablaUnidades;
end;

procedure TEditarUnidades.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFichaUnidades);
end;

procedure TEditarUnidades.cb_AltaUnidades_CON_INCERTIDUMBREChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarUnidades.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  inherited FormClose( sender, CloseAction );
end;

procedure TEditarUnidades.sgUnidadesDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.listadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsUnidades[ACol],
    nil, iconos, validarCambioTablaUnidades);
end;

procedure TEditarUnidades.sgUnidadesGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  utilidades.listadoGetEditText(Sender, ACol, ARow );
end;



procedure TEditarUnidades.sgUnidadesValidarCambio(Sender: TObject);
begin
  utilidades.listadoValidarCambio(Sender, tiposColsUnidades,
    self.validarCambioTablaUnidades, self.cambioValorTablaUnidades);
end;

procedure TEditarUnidades.sgUnidadesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditarUnidades.sgUnidadesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsUnidades);
end;

procedure TEditarUnidades.sgUnidadesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsUnidades);
  case res of
    TC_btEditar: editar(TStringGrid(Sender).row, False);
    TC_btEliminar: eliminar(TStringGrid(Sender).row);
    TC_btClonar: if editar(TStringGrid(Sender).row, True) then
        sgUnidades.Row := sgUnidades.RowCount - 1;
  end;
end;

procedure TEditarUnidades.BAgregarFichaClick(Sender: TObject);
begin
  editar(0, False);
end;

procedure TEditarUnidades.BGuardarClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TEditarUnidades.BVerExpandidaClick(Sender: TObject);
var
  form: TVisorFichasExpandidas;
begin
  form := TVisorFichasExpandidas.Create(self, self.sala, actor, lista_aux);
  form.ShowModal;
end;

procedure TEditarUnidades.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
