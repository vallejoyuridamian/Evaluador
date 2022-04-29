unit uEditarForzamientos;

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ExtCtrls, uBaseFormularios, uActores, utilidades, ufichasLPD,
  uForzamientos,
  uunidades,
  usalasdejuegoParaEditor,
  uEditarFichaForzamientos, uCosa, uVisorFichasExpandidas, uCosaConNombre,
  uSalasDeJuego, uConstantesSimSEE, uOpcionesSimSEEEdit, uAuxiliares, xMatDefs;

resourcestring
  rsCapa = 'Capa';
  rsFechaDeInicio = 'Fecha de Inicio';
  rsForzamiento = 'Forzamiento';
  rsPeriodicaQ = 'Periodica';
  rsActivarForzamiento = 'Activo';
  rsConfirmaEliminarFichaFrozamiento = '¿Confirma que desea eliminar la ficha seleccionada?';

type

  { TEditarForzamientos }

  TEditarForzamientos = class(TBaseFormularios)
    Panel1: TPanel;
    BGuardar: TButton;
    BCancelar: TButton;
    BAgregarFicha: TButton;
    BVerExpandida: TButton;
    sgForzamientos: TStringGrid;
    procedure BCancelarClick(Sender: TObject);
    procedure sgForzamientosDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgForzamientosMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgForzamientosMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure sgForzamientosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAgregarFichaClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BVerExpandidaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure sgForzamientosValidarCambio(Sender: TObject);
    procedure sgForzamientosGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
  private
    lista: TFichasLPD;
    actor: TActor;
    tiposColsForzamientos: TDAOfTTipoColumna;
    function editar(fila: integer; clonar: boolean): boolean;
    procedure eliminar(fila: integer);
    procedure actualizarTablaForzamientos;
    function validarCambioTablaForzamientos(listado: TStringGrid;
      fila, columna: integer): boolean;
    procedure cambioValorTablaForzamientos(listado: TStringGrid; fila, columna: integer);
  public
    etiquetasForzamientos: TDAofString;

    constructor Create(AOwner: TControl; xsala: TSalaDeJuego; actor: TActor;
      listaForzamientos: TFichasLPD; etiquetasForzamientos: TDAofString); reintroduce;

    function darLista: TFichasLPD;
  end;

implementation

uses ueditor_resourcestrings, SimSEEEditMain;

 {$R *.lfm}

constructor TEditarForzamientos.Create(AOwner: TControl; xsala: TSalaDeJuego;
  actor: TActor; listaForzamientos: TFichasLPD;
  etiquetasForzamientos: TDAofString);
var
  etiquetas: array of string;
begin
  inherited Create_conSalaYEditor_( AOwner, xsala );

  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;

  listaForzamientos.clearExpanded;
  self.lista := listaForzamientos.Create_Clone( nil, 0 ) as TFichasLPD;
  self.actor := actor;
  self.etiquetasForzamientos := etiquetasForzamientos;

  rbtEditorSala.CatalogoReferencias.resolver_referenciasDeCosa(self.lista, self.sala.listaActores);
  rbtEditorSala.CatalogoReferencias.eliminar_referencias_del(self.lista);

  //Aca escribo las etiquetas q salen en el formulario
  setlength(etiquetas, 8);
  etiquetas[0] := encabezadoTextoEditable + rsFechaDeInicio;
  etiquetas[1] := rsForzamiento;
  etiquetas[2] := rsPeriodicaQ;
  etiquetas[3] := rsActivarForzamiento;
  etiquetas[4] := rsCapa;
  etiquetas[5] := encabezadoBTEditar;
  etiquetas[6] := encabezadoBTEliminar;
  etiquetas[7] := encabezadoBTClonar;

  utilidades.initListado(sgForzamientos, etiquetas, tiposColsForzamientos, False);

  actualizarTablaForzamientos;
  guardado := True;
end;

function TEditarForzamientos.darLista: TFichasLPD;
begin
  Result := lista;
end;

function TEditarForzamientos.editar(fila: integer; clonar: boolean): boolean;
var
  form: TEditarFichaForzamientos;
  ficha: TFichaForzamientos;
  res: boolean;
begin
  res := False;
  if fila = 0 then
    ficha := nil
  else
    ficha := TFichaForzamientos(lista[fila - 1]);

  form := TEditarFichaForzamientos.Create(self, actor, ficha, nil, etiquetasForzamientos);
  if form.ShowModal = mrOk then
  begin
    if ficha <> nil then
    begin
      if not clonar then
      begin
        lista.Remove(ficha);
        ficha.Free;
      end;
    end;
    lista.add(form.darFicha());
    actualizarTablaForzamientos;
    guardado := False;
    res := True;
  end;
  form.Free;
  Result := res;
end;

procedure TEditarForzamientos.eliminar(fila: integer);
begin
  if lista.Count > 0 then
  begin
    if (Application.MessageBox(PChar(rsConfirmaEliminarFichaFrozamiento),
      PChar(mesConfirmarEliminacion), MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
    begin
      lista[fila - 1].Free;
      lista.Delete(fila - 1);
      actualizarTablaForzamientos;
      guardado := False;
    end;
  end;
end;

procedure TEditarForzamientos.actualizarTablaForzamientos;
var
  i: integer;
  oldItemRow: TCosa;
  pf: TFichaForzamientos;

begin
  if (sgForzamientos.row > 0) and (sgForzamientos.row < lista.Count) then
    oldItemRow := lista.items[sgForzamientos.row - 1]
  else
    oldItemRow := nil;

  lista.SortByFecha;

  sgForzamientos.RowCount := lista.Count + 1;
  if sgForzamientos.RowCount > 1 then
    sgForzamientos.FixedRows := 1
  else
    sgLimpiarSeleccion(sgForzamientos);

  for i := 0 to lista.Count - 1 do
  begin
    pf:= TFichaForzamientos(lista[i]);
    sgForzamientos.cells[0, i + 1] :=
      FSimSEEEdit.fechaIniToString(TFichaForzamientos(lista[i]).fecha);

    try
       sgForzamientos.cells[1, i + 1] := DAOfNRealToStr_( pf.P, 12, 2, ';' );
    except
      sgForzamientos.cells[1, i + 1] := '?';
    end;

    sgForzamientos.Cells[2, i + 1] := boolToSiNo( pf.periodicidad <> nil);
    sgForzamientos.Cells[3, i + 1] := boolToSiNo( pf.activar_forzamiento  );
    sgForzamientos.Cells[4, i + 1] := IntToStr(TFichaUnidades(lista[i]).capa );

  end;

  for i := 0 to sgForzamientos.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgForzamientos, i, tiposColsForzamientos[i], iconos);

  BAgregarFicha.Left := sgForzamientos.Left + sgForzamientos.Width - BAgregarFicha.Width;
  BVerExpandida.Left := BAgregarFicha.Left - BVerExpandida.Width - 10;

  if oldItemRow <> nil then
    sgForzamientos.Row := lista.IndexOf(oldItemRow) + 1;

end;

function TEditarForzamientos.validarCambioTablaForzamientos(listado: TStringGrid;
  fila, columna: integer): boolean;
begin
  case columna of
    0:
      Result := inherited validarCeldaFecha(listado, fila, columna);
    1:
      Result := inherited validarCeldaNReal(listado, fila, columna);
    else
      Result := True;
  end;
end;

procedure TEditarForzamientos.cambioValorTablaForzamientos(listado: TStringGrid;
  fila, columna: integer);
begin
  if columna = 0 then //Fecha
  begin
    TFichaForzamientos(lista[fila - 1]).fecha.Free;
    TFichaForzamientos(lista[fila - 1]).fecha :=
      FSimSEEEdit.StringToFecha(listado.Cells[columna, fila]);
    guardado := False;
    actualizarTablaForzamientos;
  end
  else if columna = 1 then //NForzamientos
  begin
    TFichaForzamientos(lista[fila - 1]).P[0] :=
      StrToFloat(listado.Cells[columna, fila]);
    guardado := False;
  end;
end;

procedure TEditarForzamientos.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarForzamientos.sgForzamientosDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.listadoDrawCell(Sender, ACol, ARow, Rect, State, tiposColsForzamientos[ACol],
    nil, iconos, validarCambioTablaForzamientos);
end;

procedure TEditarForzamientos.sgForzamientosGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  utilidades.listadoGetEditText(Sender, ACol, ARow );
end;


procedure TEditarForzamientos.sgForzamientosValidarCambio(Sender: TObject);
begin
  utilidades.listadoValidarCambio(Sender, tiposColsForzamientos,
    self.validarCambioTablaForzamientos, self.cambioValorTablaForzamientos);
end;

procedure TEditarForzamientos.sgForzamientosMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditarForzamientos.sgForzamientosMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsForzamientos);
end;

procedure TEditarForzamientos.sgForzamientosMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsForzamientos);
  case res of
    TC_btEditar: editar(TStringGrid(Sender).row, False);
    TC_btEliminar: eliminar(TStringGrid(Sender).row);
    TC_btClonar: if editar(TStringGrid(Sender).row, True) then
        sgForzamientos.Row := sgForzamientos.RowCount - 1;
  end;
end;

procedure TEditarForzamientos.BAgregarFichaClick(Sender: TObject);
begin
  editar(0, False);
end;

procedure TEditarForzamientos.BGuardarClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TEditarForzamientos.BVerExpandidaClick(Sender: TObject);
var
  form: TVisorFichasExpandidas;
begin
  form := TVisorFichasExpandidas.Create(self, self.sala, actor, lista);
  form.ShowModal;
end;

procedure TEditarForzamientos.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
