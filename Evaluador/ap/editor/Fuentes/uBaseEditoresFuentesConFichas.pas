unit uBaseEditoresFuentesConFichas;

  {$MODE Delphi}

interface

uses
   {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls,
  uBaseEditoresCosasConNombre,
  uBaseEditoresFichas,
  uFichasLPD,
  utilidades,
  uConstantesSimSEE,
  uInfoCosa,
  uauxiliares,
  uOpcionesSimSEEEdit,
  uVisorFichasExpandidas,
  {$IFDEF UCAMPOS}
  uCampos,
  {$ENDIF}
  ueditor_resourcestrings,
  uCosaConNombre;

resourcestring
  mesConfirmaEliminarFicha = '¿Confirma que desea eliminar la ficha seleccionada?';
  rsFechaDeInicio = 'Fecha de Inicio';
  rsInformacioNAdicional = 'Información adicional';
  rsPeriodicaQ = 'Periodica?';

type
  TBaseEditoresFuentesConFichas = class(TBaseEditoresCosasConNombre)
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
    tiposdeColumna: TDAOfTTipoColumna;
    hintsColumnas: array of string;

    sgFichasLPD: TStringGrid;
    {$IFDEF UCAMPOS}
    camposPrimitivosFichas: TDAOfTCampoPrimitivo;
    {$ENDIF}
    BAgregarFicha, BVerExpandida, BGuardar, BCancelar: TButton;


    procedure inicializarComponentesLPD(lpdOrig: TFichasLPD;
      tipoFicha: TClaseDeFichaLPD; sgFichasLPD: TStringGrid;
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar: TButton);

    function altaFicha: TFichaLPD;
    function editarFicha(var ficha: TFichaLPD): TFichaLPD;
    function clonarFicha(var ficha: TFichaLPD): TFichaLPD;
    function eliminarFicha(var ficha: TFichaLPD): boolean;

    procedure actualizarTabla;
  private

  public
    procedure Free;
  end;

implementation

uses usalasdejuegoParaEditor, SimSEEEditMain,
  // uRegistroDeEditores,
  ucosa;

{$R *.lfm}

procedure TBaseEditoresFuentesConFichas.Free;
begin
  if ModalResult <> mrOk then
    if lpd <> nil then
      lpd.Free;
  SetLength(tiposdeColumna, 0);
  inherited Free;
end;

function TBaseEditoresFuentesConFichas.altaFicha: TFichaLPD;
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

function TBaseEditoresFuentesConFichas.editarFicha(var ficha: TFichaLPD): TFichaLPD;
var
  formEditorFicha: TBaseEditoresFichas;
  res: TFichaLPD;
  id: integer;
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

function TBaseEditoresFuentesConFichas.clonarFicha(var ficha: TFichaLPD): TFichaLPD;
var
  clonFicha: TFichaLPD;
  iFicha: integer;
  diasDelPaso: integer;

{  formEditorFicha: TBaseEditoresFichas;
  res: TFichaLPD;}
begin
  {formEditorFicha:= tipoEditorFichas.Create(self, cosaConNombre, ficha, sala);
  if formEditorFicha.ShowModal = mrOk then
  begin
    res:= formEditorFicha.darFicha();
     lpd.Add(res);
    guardado := false;
  end
  else
    res:= NIL;
  formEditorFicha.Free;
  ficha:= res;
  result:= res;}

  assert(rbtEditorSala.CatalogoReferencias.referenciasSinResolver = 0);
  //Agregado 13/7 porque no se resolvian referencias al clonar ficha de hidro de pasada
  clonFicha := ficha.Create_Clone(nil, 0) as TFichaLPD;

  iFicha := lpd.IndexOf(ficha);
  // Si la ficha clonada es la ultima o la siguiente ficha a la ficha clonada está
  // mas de un día después le pongo fecha al clon igual a la fecha de la ficha clonada
  // + 1 día
  // Si no le pongo la fecha de la última ficha +1 día

  DiasDelPaso := trunc(sala.globs.HorasDelPaso / 24.0 + 0.1);

  if (iFicha = lpd.Count - 1) or
    (TFichaLPD(lpd.items[iFicha + 1]).fecha.mayorQue_DT(ficha.fecha.dt +
    DiasDelPaso)) then
    clonFicha.fecha.addDias(diasDelPaso)
  else
    clonFicha.fecha.PonerIgualAMasOffsetDT(TFichaLPD(lpd.items[lpd.Count - 1]).fecha,
      DiasDelPaso);

  lpd.Add(clonFicha);
  guardado := False;
  rbtEditorSala.resolverReferenciasContraSala(False);
  //Agregado 13/7 porque no se resolvian referencias al clonar ficha de hidro de pasada
  Result := clonFicha;
end;

function TBaseEditoresFuentesConFichas.eliminarFicha(var ficha: TFichaLPD): boolean;
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

procedure TBaseEditoresFuentesConFichas.inicializarComponentesLPD(lpdOrig: TFichasLPD;
  tipoFicha: TClaseDeFichaLPD; sgFichasLPD: TStringGrid;
  BAgregarFicha, BVerExpandida, BGuardar, BCancelar: TButton);
var
  encabezados: array of string;
  i: integer;
  a: integer;
begin

  tipoEditorFichas := TClaseEditoresFichas(InfoFichasFuentes.getTipoEditor(tipoFicha));

  if lpdOrig <> nil then
    lpd := rbtEditorSala.Clonar_Y_ResolverReferencias(lpdOrig) as
      TFichasLPD
  else
    lpd := TFichasLPD.Create(capa, 'fichasLPD', nil, tipoFicha);

  self.sgFichasLPD := sgFichasLPD;
  self.BAgregarFicha := BAgregarFicha;
  Self.BVerExpandida := BVerExpandida;
  Self.BGuardar := BGuardar;
  Self.BCancelar := BCancelar;

  self.sgFichasLPD.OnMouseMove := Self.sgFichasMouseMove;
  self.sgFichasLPD.OnDrawCell := Self.sgFichasDrawCell;
  self.sgFichasLPD.OnMouseDown := Self.sgFichasMouseDown;
  self.sgFichasLPD.OnMouseUp := Self.sgFichasMouseUp;

  self.BAgregarFicha.OnClick := self.BAgregarFichaClick;
  self.BVerExpandida.OnClick := Self.BVerExpandidaClick;

  {$IFDEF UCAMPOS}
  camposPrimitivosFichas := listaCamposDeClases.getCamposPrimitivosDeClase(tipoFicha);
  if camposPrimitivosFichas <> nil then
  begin
    // Tengo los campos, puedo editar => agrego los eventos de edición del stringgrid
    sgFichasLPD.OnClick := self.sgFichasValidarCambio;
    sgFichasLPD.OnExit := self.sgFichasValidarCambio;
    sgFichasLPD.OnGetEditText := self.sgFichasGetEditText;
    sgFichasLPD.OnKeyDown := self.sgFichasKeyDown;

    SetLength(encabezados, Length(camposPrimitivosFichas) + 3);
    SetLength(hintsColumnas, Length(encabezados));
    for i := 0 to High(camposPrimitivosFichas) do
    begin
      encabezados[i] := encabezadoTextoEditable +
        camposPrimitivosFichas[i].nombreCorto + camposPrimitivosFichas[i].unidad;
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
  {$ENDIF}
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

{  utilidades.initListado(sgFichasLPD, [rsFechaDeInicio, rsInformacioNAdicional, rsPeriodicaQ,
      encabezadoBTEditar, encabezadoBTEliminar, encabezadoBTClonar], tiposDeColumna, true);}
  actualizarTabla;
end;

procedure TBaseEditoresFuentesConFichas.actualizarTabla;
var
  i, j: integer;
begin
  lpd.SortByFecha;

  sgFichasLPD.RowCount := lpd.Count + 1;
  if sgFichasLPD.RowCount > 1 then
    sgFichasLPD.FixedRows := 1
  else
    sgLimpiarSeleccion(sgFichasLPD);

  {$IFDEF UCAMPOS}
  if camposPrimitivosFichas <> nil then
  begin
    for i := 0 to lpd.Count - 1 do
      for j := 0 to high(camposPrimitivosFichas) do
        sgFichasLPD.Cells[j, i + 1] := camposPrimitivosFichas[j].AsString(lpd[i]);
    for i := 0 to sgFichasLPD.ColCount - 1 do
      utilidades.AutoSizeTypedCol(sgFichasLPD, i, tiposDeColumna[i], iconos);
  end
  else
 {$ENDIF}
  begin
    for i := 0 to lpd.Count - 1 do
    begin
      sgFichasLPD.cells[0, i + 1] :=
        FSimSEEEdit.fechaIniToString(TFichaLPD(lpd[i]).fecha);
      sgFichasLPD.cells[1, i + 1] := TFichaLPD(lpd[i]).InfoAd_20;
      sgFichasLPD.cells[2, i + 1] := boolToSiNo(TFichaLPD(lpd[i]).periodicidad <> nil);
    end;
    for i := 0 to sgFichasLPD.ColCount - 1 do
      utilidades.AutoSizeTypedCol(sgFichasLPD, i, tiposdeColumna[i], iconos);
  end;

  (*
  utilidades.AutoSizeTable(self, sgFichasLPD, maxAnchoTablaEnorme,
    maxAlturaTablaMediana,
    TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
    *)
end;

procedure TBaseEditoresFuentesConFichas.sgFichasMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TBaseEditoresFuentesConFichas.sgFichasMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  cambios: boolean;
  tipoCol: TTipoColumna;
  ficha, fichaClon: TFichaLPD;
  oldCol: integer;
begin
  tipoCol := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposdeColumna);
  fichaClon := nil;
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
      fichaClon := clonarFicha(ficha);
      cambios := fichaClon <> nil;
    end;
  end;
  if cambios then
  begin
    actualizarTabla;
    //    if tipoCol = TC_btClonar then
    //      TStringGrid(Sender).Row := TStringGrid(Sender).RowCount - 1;
  end;
end;

procedure TBaseEditoresFuentesConFichas.sgFichasDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposdeColumna[ACol], nil, iconos);
end;

procedure TBaseEditoresFuentesConFichas.sgFichasMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposdeColumna);
end;

procedure TBaseEditoresFuentesConFichas.sgFichasValidarCambio(Sender: TObject);
begin
  utilidades.listadoValidarCambio(Sender, tiposDeColumna, validarValorSG,
    cambiarValorSG);
end;

procedure TBaseEditoresFuentesConFichas.sgFichasGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  utilidades.listadoGetEditText(Sender, ACol, ARow);
end;



function TBaseEditoresFuentesConFichas.validarValorSG(listado: TStringGrid;
  fila, columna: integer): boolean;
{$IFDEF UCAMPOS}
var
  campo: TCampoPrimitivo;
{$ENDIF}
begin
  {$IFDEF UCAMPOS}
  campo := camposPrimitivosFichas[columna];
  if campo.validador <> nil then
    Result := campo.validador.esValido(listado.Cells[columna, fila])
  else
  {$ENDIF}
    Result := True;
end;

procedure TBaseEditoresFuentesConFichas.cambiarValorSG(listado: TStringGrid;
  fila, columna: integer);
var
  {$IFDEF UCAMPOS}
  campo: TCampoPrimitivo;
  {$ENDIF}
  fecha: string;
  i: integer;
  sel: TGridRect;
begin
  {$IFDEF UCAMPOS}
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
  {$ENDIF}
  guardado := False;
end;

procedure TBaseEditoresFuentesConFichas.BAgregarFichaClick(Sender: TObject);
begin
  if altaFicha <> nil then
    actualizarTabla;
end;

procedure TBaseEditoresFuentesConFichas.BVerExpandidaClick(Sender: TObject);
var
  form: TVisorFichasExpandidas;
begin
  form := TVisorFichasExpandidas.Create(self, self.sala, cosaConNombre, lpd);
  form.ShowModal;
  form.Free;
end;

end.
