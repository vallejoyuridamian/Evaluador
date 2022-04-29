unit uEditarActorConFichas;
  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresActores, uSalasDeJuego, uActores, uFichasLPD,
  uCosaConNombre, utilidades, uBaseEditoresFichas, uInfoTabs, StdCtrls, Grids,
  uAuxiliares, uConstantesSimSEE, uOpcionesSimSEEEdit, uVisorFichasExpandidas,
  uCampos,
  uVarDefs,
  usalasdejuegoParaEditor;

resourcestring
  mesConfirmaEliminarFicha = '¿Confirma que desea eliminar la ficha seleccionada?';
  rsFechaDeInicio = 'Fecha de Inicio';
  rsInformacioNAdicional = 'Información adicional';
  rsPeriodicaQ = 'Periodica?';

type
  TEditarActorConFichas = class(TBaseEditoresActores)
  published
    procedure sgFichasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgFichasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure sgFichasDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgFichasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);

    procedure sgFichasValidarCambio(Sender: TObject);
    procedure sgFichasGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);

    function validarValorSG(listado: TStringGrid; fila, columna: integer): boolean;
    procedure cambiarValorSG(listado: TStringGrid; fila, columna: integer);

    procedure BAgregarFichaClick(Sender: TObject);
    procedure BVerExpandidaClick(Sender: TObject);
  protected
    tipoEditorFichas: TClaseEditoresFichas;
    lpd: TFichasLPD;
    tiposDeColumna: TDAOfTTipoColumna;
    hintsColumnas: array of string;

    sgFichasLPD: TStringGrid;
    BAgregarFicha, BVerExpandida, BGuardar, BCancelar: TButton;

    camposPrimitivosFichas: TDAOfTCampoPrimitivo;

    procedure inicializarComponentesLPD(lpdOrig: TFichasLPD;
      tipoFicha: TClaseDeFichaLPD; sgFichasLPD: TStringGrid;
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar: TButton);

    function altaFicha: TFichaLPD;
    function editarFicha(var ficha: TFichaLPD): TFichaLPD;
    function clonarFicha(var ficha: TFichaLPD): TFichaLPD;
    function eliminarFicha(var ficha: TFichaLPD): boolean;

    function validarFormulario: boolean; override;
    function validarSGFichas: boolean;

    procedure actualizarTabla;
  private

  public
    procedure Free;
  end;

implementation

uses ueditor_resourcestrings, SimSEEEditMain;

  {$R *.lfm}

procedure TEditarActorConFichas.Free;
begin
  if ModalResult <> mrOk then
    if lpd <> nil then
      lpd.Free;
  SetLength(tiposDeColumna, 0);
  inherited Free;
end;

function TEditarActorConFichas.altaFicha: TFichaLPD;
var
  formEditorFicha: TBaseEditoresFichas;
  res: TFichaLPD;
begin
  formEditorFicha := tipoEditorFichas.Create(self, cosaConNombre, nil, sala);
  if formEditorFicha.ShowModal = mrOk then
  begin
    res := formEditorFicha.darFicha();
    lpd.Add(res);
    guardado := False;
  end
  else
    res := nil;
  formEditorFicha.Free;
  Result := res;
end;

function TEditarActorConFichas.editarFicha(var ficha: TFichaLPD): TFichaLPD;
var
  formEditorFicha: TBaseEditoresFichas;
  res: TFichaLPD;
begin
  formEditorFicha := tipoEditorFichas.Create(self, cosaConNombre, ficha, sala);
  if formEditorFicha.ShowModal = mrOk then
  begin
    lpd.Remove(ficha);
    ficha.Free;
    res := formEditorFicha.darFicha();
    lpd.Add(res);
    guardado := False;
  end
  else
    res := nil;
  formEditorFicha.Free;
  ficha := res;
  Result := res;
end;

function TEditarActorConFichas.clonarFicha(var ficha: TFichaLPD): TFichaLPD;
var
  clonFicha: TFichaLPD;
  iFicha: integer;
begin
  assert( rbtEditorSala.CatalogoReferencias.referenciasSinResolver = 0);
  //Agregado 13/7 porque no se resolvian referencias al clonar ficha de hidro de pasada
  clonFicha := ficha.Create_Clone( rbtEditorSala.CatalogoReferencias, 0 ) as TFichaLPD;
  iFicha := lpd.IndexOf(ficha);
  // Si la ficha clonada es la ultima o la siguiente ficha a la ficha clonada está
  // mas de un día después le pongo fecha al clon igual a la fecha de la ficha clonada
  // + 1 día
  // Si no le pongo la fecha de la última ficha +1 día
  if (iFicha = lpd.Count - 1) or
    (TFichaLPD(lpd.items[iFicha + 1]).fecha.mayorQue_DT(ficha.fecha.dt + 1)) then
    clonFicha.fecha.addDias(1)
  else
    clonFicha.fecha.PonerIgualAMasOffsetDT(TFichaLPD(lpd.items[lpd.Count - 1]).fecha, 1);
  lpd.Add(clonFicha);
  guardado := False;
  rbtEditorSala.resolverReferenciasContraSala(False);
  Result := clonFicha;
end;

function TEditarActorConFichas.eliminarFicha(var ficha: TFichaLPD): boolean;
begin
  if (Application.MessageBox(PChar(mesConfirmaEliminarFicha),
    PChar(mesConfirmarEliminacion), MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    lpd.Remove(ficha);
    ficha.Free;
    ficha := nil;
    guardado := False;
    Result := True;
  end
  else
    Result := False;
end;

function TEditarActorConFichas.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarSGFichas;
end;

function TEditarActorConFichas.validarSGFichas: boolean;
var
  i, j: integer;
  campo: TCampoPrimitivo;
  error: boolean;
begin
  if camposPrimitivosFichas <> nil then
  begin
    error := False;
    for j := 0 to high(camposPrimitivosFichas) do
    begin
      campo := camposPrimitivosFichas[j];
      if campo.validador <> nil then
        for i := 1 to sgFichasLPD.RowCount - 1 do
        begin
          if not campo.validador.esValido(sgFichasLPD.Cells[j, i]) then
          begin
            ShowMessage
            ('El campo "' + campo.nombre + '" ' + campo.validador.msgValoresValidos);
            error := True;
            break;
          end;
        end;
      if error then
        break;
    end;
    Result := not error;
  end
  else
    Result := True;
end;

procedure TEditarActorConFichas.inicializarComponentesLPD(lpdOrig: TFichasLPD;
  tipoFicha: TClaseDeFichaLPD; sgFichasLPD: TStringGrid;
  BAgregarFicha, BVerExpandida, BGuardar, BCancelar: TButton);
var
  encabezados: array of string;
  i: integer;
begin
  tipoEditorFichas := infoTabs_.getInfoActor(tipoCosa).ClaseEditorFichas;
  if lpdOrig <> nil then
    lpd := rbtEditorSala.Clonar_Y_ResolverReferencias(lpdOrig) as
      TFichasLPD
  else
    lpd := TFichasLPD.Create(capa, 'fichasLPD', nil, tipoFicha);

  self.sgFichasLPD := sgFichasLPD;
  self.BAgregarFicha := BAgregarFicha;
  self.BVerExpandida := BVerExpandida;
  self.BGuardar := BGuardar;
  self.BCancelar := BCancelar;

  self.sgFichasLPD.OnMouseMove := self.sgFichasMouseMove;
  self.sgFichasLPD.OnDrawCell := self.sgFichasDrawCell;
  self.sgFichasLPD.OnMouseDown := self.sgFichasMouseDown;
  self.sgFichasLPD.OnMouseUp := self.sgFichasMouseUp;

  self.BAgregarFicha.OnClick := self.BAgregarFichaClick;
  self.BVerExpandida.OnClick := self.BVerExpandidaClick;

  // palfaro@110405_1657
  // Introduje esto para corregir el siguiente bug que se da si el StringGrid tiene RowSelect entre
  // sus opciones y hay scroll horizontal.
  // Al clickear en la grilla con RowSelect la columna se fija automaticamente a 0,
  // si la columna es 0 el control scrollea a la izquierda antes de llamar a los eventos
  // del ratón, por lo que cuando se levanta el botón del mouse el cursor está
  // a la izquierda de donde se clickeo, y los botones que siempre estan sobre la derecha
  // no pueden ser alcanzados.
  // Para evitar esto hago que se seleccione por filas solo si se deshabilita el
  // scroll horizontal en los listados

  camposPrimitivosFichas := listaCamposDeClases.getCamposPrimitivosDeClase(tipoFicha);
  if camposPrimitivosFichas <> nil then
  begin
    // Tengo los campos, puedo editar => agrego los eventos de edición del stringgrid
    sgFichasLPD.OnClick := self.sgFichasValidarCambio;
    sgFichasLPD.OnExit := self.sgFichasValidarCambio;
    sgFichasLPD.OnGetEditText := self.sgFichasGetEditText;

    SetLength(encabezados, Length(camposPrimitivosFichas) + 3);
    SetLength(hintsColumnas, Length(encabezados));
    for i := 0 to High(camposPrimitivosFichas) do
    begin
      encabezados[i] := encabezadoTextoEditable + camposPrimitivosFichas[i].nombreCorto +
        camposPrimitivosFichas[i].unidad;
      hintsColumnas[i] := camposPrimitivosFichas[i].nombre +
        camposPrimitivosFichas[i].unidad;
    end;
    encabezados[Length(camposPrimitivosFichas)] := encabezadoBTEditar;
    hintsColumnas[Length(camposPrimitivosFichas)] := rsEditar;
    encabezados[Length(camposPrimitivosFichas) + 1] := encabezadoBTEliminar;
    hintsColumnas[Length(camposPrimitivosFichas) + 1] := rsEliminar;
    encabezados[Length(camposPrimitivosFichas) + 2] := encabezadoBTClonar;
    hintsColumnas[Length(camposPrimitivosFichas) + 2] := rsClonar;

    utilidades.initListado(sgFichasLPD, encabezados, tiposDeColumna, False);
  end
  else
  begin
    // palfaro@110405_1657
    // Introduje esto para corregir el siguiente bug que se da si el StringGrid tiene RowSelect entre
    // sus opciones y hay scroll horizontal.
    // Al clickear en la grilla con RowSelect la columna se fija automaticamente a 0,
    // si la columna es 0 el control scrollea a la izquierda antes de llamar a los eventos
    // del ratón, por lo que cuando se levanta el botón del mouse el cursor está
    // a la izquierda de donde se clickeo, y los botones que siempre estan sobre la derecha
    // no pueden ser alcanzados.
    // Para evitar esto hago que se seleccione por filas solo si se deshabilita el
    // scroll horizontal en los listados
    utilidades.initListado(sgFichasLPD, [rsFechaDeInicio, rsInformacioNAdicional,
      rsPeriodicaQ, encabezadoBTEditar, encabezadoBTEliminar, encabezadoBTClonar],
      tiposDeColumna, TSimSEEEditOptions.getInstance.
      deshabilitarScrollHorizontalEnListados);
    SetLength(hintsColumnas, 0);
  end;
  actualizarTabla;
end;

procedure TEditarActorConFichas.actualizarTabla;
var
  i, j: integer;
begin
  lpd.SortByFecha;

  sgFichasLPD.RowCount := lpd.Count + 1;
  if sgFichasLPD.RowCount > 1 then
    sgFichasLPD.FixedRows := 1
  else
    sgLimpiarSeleccion(sgFichasLPD);

  if camposPrimitivosFichas <> nil then
  begin
    for i := 0 to lpd.Count - 1 do
      for j := 0 to high(camposPrimitivosFichas) do
        sgFichasLPD.Cells[j, i + 1] := camposPrimitivosFichas[j].AsString(lpd[i]);
    for i := 0 to sgFichasLPD.ColCount - 1 do
      utilidades.AutoSizeTypedCol(sgFichasLPD, i, tiposDeColumna[i], iconos);
  end
  else
  begin
    for i := 0 to lpd.Count - 1 do
    begin
      sgFichasLPD.Cells[0, i + 1] :=
        FSimSEEEdit.fechaIniToString(TFichaLPD(lpd[i]).fecha);
      sgFichasLPD.Cells[1, i + 1] := TFichaLPD(lpd[i]).InfoAd_20;
      sgFichasLPD.Cells[2, i + 1] := boolToSiNo(TFichaLPD(lpd[i]).periodicidad <> nil);
    end;
    for i := 0 to sgFichasLPD.ColCount - 1 do
      utilidades.AutoSizeTypedCol(sgFichasLPD, i, tiposDeColumna[i], iconos);
  end;

  if BAgregarFicha <> nil then
  begin
    BAgregarFicha.Left := sgFichasLPD.Left + sgFichasLPD.Width - BAgregarFicha.Width;
    if BVerExpandida <> nil then
      BVerExpandida.Left := BAgregarFicha.Left - BVerExpandida.Width - 10;
  end;
end;

procedure TEditarActorConFichas.sgFichasMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditarActorConFichas.sgFichasMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  cambios: boolean;
  tipoCol: TTipoColumna;
  ficha: TFichaLPD;
begin
  tipoCol := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposDeColumna);
  cambios := False;
  case tipoCol of
    TC_btEditar:
    begin
      ficha := lpd[TStringGrid(Sender).row - 1];
      cambios := editarFicha(ficha) <> nil;
    end;
    TC_btEliminar:
    begin
      ficha := lpd[TStringGrid(Sender).row - 1];
      cambios := eliminarFicha(ficha);
    end;
    TC_btClonar:
    begin
      ficha := lpd[TStringGrid(Sender).row - 1];
      cambios := clonarFicha(ficha) <> nil;
    end;
  end;
  if cambios then
  begin
    actualizarTabla;
    { if tipoCol = TC_btClonar then
      TStringGrid(Sender).row := TStringGrid(Sender).RowCount - 1; }
  end;
end;

procedure TEditarActorConFichas.sgFichasDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  if camposPrimitivosFichas <> nil then
    utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
      tiposDeColumna[ACol], nil,
      iconos, validarValorSG)
  else
    utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
      tiposDeColumna[ACol], nil,
      iconos);
end;

procedure TEditarActorConFichas.sgFichasMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposDeColumna, hintsColumnas);
end;

procedure TEditarActorConFichas.sgFichasValidarCambio(Sender: TObject);
begin
  utilidades.listadoValidarCambio(Sender, tiposDeColumna, validarValorSG,
    cambiarValorSG);
end;

procedure TEditarActorConFichas.sgFichasGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  utilidades.listadoGetEditText(Sender, ACol, ARow );
end;


function TEditarActorConFichas.validarValorSG(listado: TStringGrid;
  fila, columna: integer): boolean;
var
  campo: TCampoPrimitivo;
begin
  campo := camposPrimitivosFichas[columna];
  if campo.validador <> nil then
    Result := campo.validador.esValido(listado.Cells[columna, fila])
  else
    Result := True;
end;

procedure TEditarActorConFichas.cambiarValorSG(listado: TStringGrid;
  fila, columna: integer);
var
  campo: TCampoPrimitivo;
  fecha: string;
  i: integer;
  sel: TGridRect;
begin
  campo := camposPrimitivosFichas[columna];
  campo.setValorFromString(lpd.items[fila - 1], listado.Cells[columna, fila]);
  if campo.nombre = rsFecha then
  begin
    fecha := listado.Cells[columna, fila];
    actualizarTabla;
    for i := 1 to sgFichasLPD.RowCount - 1 do
      if sgFichasLPD.Cells[columna, i] = fecha then
      begin
        sel.Left := columna;
        sel.Right := columna;
        sel.Top := i;
        sel.Bottom := i;
        sgFichasLPD.Selection := sel;
        break;
      end;
  end;
  guardado := False;
end;

procedure TEditarActorConFichas.BAgregarFichaClick(Sender: TObject);
begin
  if altaFicha <> nil then
    actualizarTabla;
end;

procedure TEditarActorConFichas.BVerExpandidaClick(Sender: TObject);
var
  form: TVisorFichasExpandidas;
begin
  form := TVisorFichasExpandidas.Create(self, self.sala, cosaConNombre, lpd);
  form.ShowModal;
  form.Free;
end;

end.
