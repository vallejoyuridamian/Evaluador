unit uEditarCentralesEncadenadas;

interface

uses
   {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditores, Grids, StdCtrls, uGeneradores, utilidades,
  uCosaConNombre, uOpcionesSimSEEEdit,
  usalasdejuego,
  usalasdejuegoParaEditor, uConstantesSimSEE, uEditarCentralCoeficiente,
  xMatDefs, uBaseAltasEditores;

resourcestring
  rsCentral = 'Central';
  rsTipoCentral = 'Tipo de central';
  rsCoeficiente = 'Coeficiente';
  mesNoMasCentralesParaEncadenar =
    'No hay otras centrales que puedan ser encadenadas a esta.' +
    ' Agregue un nuevo generador hidráulico e intentelo nuevamente.';
  mesConfirmaEliminarFicha = '¿Confirma que desea eliminar la ficha seleccionada?';
  mesConfirmarEliminacion = 'Confirmar eliminación';

const
  strNinguno = '<Ninguno>';

type
  TEditarCentralesAguasArriba = class(TBaseEditores)
    BAgregar: TButton;
    sgCentrales: TStringGrid;
    BGuardar: TButton;
    BCancelar: TButton;
    LCentralDescarga: TLabel;
    CBCentralDescarga: TComboBox;
    LCentralesAguasArriba: TLabel;
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure listadoCentralesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure listadoCentralesDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure BAgregarClick(Sender: TObject);
    procedure listadoCentralesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure listadoCentralesMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure CBCentralDescargaChange(Sender: TObject);
  private
    //Se trabaja sobre una copia de la lista original,
    //asi si se desean descartar los cambios solo hay que tirar
    //la copia
    copia: TListaCentralesAguasArriba;
    sala: TSalaDeJuego;
    tiposColsCentrales: TDAOfTTipoColumna;
    central, centralDescarga: TGeneradorHidraulico;
    centralesDisponibles: TListaDeCosasConNombre;

    procedure editar(fila: integer);
    procedure eliminar(fila: integer);
    procedure actualizarTabla;
    procedure actualizarCBDescarga;
  public
    constructor Create(AOwner: TForm; central, centralDescarga: TGeneradorHidraulico;
      lista: TListaCentralesAguasArriba; sala: TSalaDeJuego); reintroduce;
    function DarCentralDescarga: TGeneradorHidraulico;
    function darCentralesAguasArriba: TListaCentralesAguasArriba;
    function ShowModal: integer; override;
    procedure Free;
  end;

implementation

uses Math;
  {$R *.lfm}

constructor TEditarCentralesAguasArriba.Create(AOwner: TForm;
  central, centralDescarga: TGeneradorHidraulico; lista: TListaCentralesAguasArriba;
  sala: TSalaDeJuego);
var
  i, basura: integer;
  cosaConNombre: TCosaConNombre;
begin
  inherited Create(AOwner, lista, sala );
  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;
  self.central := central;
  self.centralDescarga := centralDescarga;
  initListado(sgCentrales, [rsCentral, rsTipoCentral, rsCoeficiente,
    encabezadoBTEditar, encabezadoBTEliminar], tiposColsCentrales, True);

  self.sala := sala;
  copia := rbtEditorSala.Clonar_Y_ResolverReferencias( lista) as TListaCentralesAguasArriba;
  copia.Pack;

  actualizarTabla;

  centralesDisponibles := TListaDeCosasConNombre.Create(capa, 'Disponibles');
  for i := 0 to sala.gens.Count - 1 do
  begin
    cosaConNombre := sala.gens[i] as TCosaConNombre;
    if (cosaConNombre is TGeneradorHidraulico) and (cosaConNombre <> central) and
      //Si no soy yo
      (cosaConNombre <> centralDescarga) and         //ni mi central de descarga
      not copia.find(cosaConNombre.ClassName, cosaConNombre.nombre, basura) then
      //Ni esta entre mis centrales aguas arriba
      centralesDisponibles.Add(cosaConNombre);
  end;
  actualizarCBDescarga;
  guardado := True;
end;

function TEditarCentralesAguasArriba.DarCentralDescarga: TGeneradorHidraulico;
begin
  Result := centralDescarga;
end;

function TEditarCentralesAguasArriba.darCentralesAguasArriba:
TListaCentralesAguasArriba;
begin
  Result := copia;
end;

function TEditarCentralesAguasArriba.ShowModal: integer;
begin
  if ((centralesDisponibles.Count = 0) and (centralDescarga = nil) and
    (copia.Count = 0)) then
  begin
    ShowMessage(mesNoMasCentralesParaEncadenar);
    Result := mrAbort;
  end
  else
    Result := inherited ShowModal;
end;

procedure TEditarCentralesAguasArriba.Free;
begin
  if ModalResult <> mrOk then
  begin
    copia.Free;
  end;
  inherited Free;
end;

procedure TEditarCentralesAguasArriba.editar(fila: integer);
var
  form: TEditarCentralCoeficiente;
  centralAEditar: TGeneradorHidraulico;
  coeficiente: NReal;
begin
  if fila = 0 then
  begin
    centralAEditar := nil;
    coeficiente := -1;
  end
  else
  begin
    centralAEditar := TFichaCentralAguasArriba(copia[fila - 1]).central;
    coeficiente := TFichaCentralAguasArriba(copia[fila - 1]).coef;
  end;

  if (centralAEditar <> nil) then
    //Estoy editando una que ya existe entonces aunque este en la lista de
    //centrales aguas arriba la agrego a la lista de disponibles
    centralesDisponibles.Add(centralAEditar);

  if centralesDisponibles.Count > 0 then
  begin
    form := TEditarCentralCoeficiente.Create(self, centralAEditar,
      coeficiente, sala, centralesDisponibles);
    if form.ShowModal = mrOk then
    begin
      if centralAEditar <> nil then
      begin
        copia.replace(form.darCoeficiente, form.darCentral, centralAEditar);
        centralesDisponibles.Remove(centralAEditar);
        centralesDisponibles.Remove(form.darCentral);
      end
      else
      begin
        copia.add(form.darCoeficiente, form.darCentral);
        centralesDisponibles.Remove(form.darCentral);
      end;
      actualizarCBDescarga;
      actualizarTabla;
      guardado := False;
    end;
    form.Free;
  end
  else
    ShowMessage(mesNoMasCentralesParaEncadenar);
end;

procedure TEditarCentralesAguasArriba.eliminar(fila: integer);
begin
  if (Application.MessageBox(PChar(mesConfirmaEliminarFicha),
    PChar(mesConfirmarEliminacion), MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    centralesDisponibles.add(TFichaCentralAguasArriba(copia[fila - 1]).central);
    copia.Delete(fila - 1);
    actualizarTabla;
    actualizarCBDescarga;
    guardado := False;
  end;
end;

procedure TEditarCentralesAguasArriba.actualizarTabla;
var
  i: integer;
begin
  sgCentrales.RowCount := copia.Count + 1;
  if sgCentrales.RowCount > 1 then
    sgCentrales.FixedRows := 1
  else
    sgLimpiarSeleccion(sgCentrales);

  for i := 0 to copia.Count - 1 do
  begin
    sgCentrales.cells[0, i + 1] := TFichaCentralAguasArriba(copia[i]).central.nombre;
    sgCentrales.cells[1, i + 1] := TFichaCentralAguasArriba(copia[i]).central.DescClase;
    sgCentrales.Cells[2, i + 1] :=
      FloatToStrF(TFichaCentralAguasArriba(copia[i]).coef, ffGeneral,
      CF_PRECISION, CF_DECIMALESPU);
  end;

  for i := 0 to sgCentrales.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgCentrales, i, tiposColsCentrales[i], iconos);


  BAgregar.Left := sgCentrales.Left + sgCentrales.Width - BAgregar.Width;
end;

procedure TEditarCentralesAguasArriba.actualizarCBDescarga;
var
  i: integer;
begin
  CBCentralDescarga.Items.Clear;
  if centralDescarga <> nil then
    CBCentralDescarga.Items.Add(centralDescarga.ClaseNombre);
  for i := 0 to centralesDisponibles.Count - 1 do
    CBCentralDescarga.Items.Add(TGeneradorHidraulico(centralesDisponibles[i]).ClaseNombre);
  CBCentralDescarga.Items.Add(strNinguno);
  if centralDescarga <> nil then
    CBCentralDescarga.ItemIndex := 0
  else
    CBCentralDescarga.ItemIndex := CBCentralDescarga.Items.Count - 1;
end;

procedure TEditarCentralesAguasArriba.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarCentralesAguasArriba.BGuardarClick(Sender: TObject);
begin
  modalResult := mrOk;
end;

procedure TEditarCentralesAguasArriba.listadoCentralesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsCentrales);
  case res of
    TC_btEditar: editar(TStringGrid(Sender).row);
    TC_btEliminar: eliminar(TStringGrid(Sender).row);
    TC_btClonar: editar(TStringGrid(Sender).row);
  end;
end;

procedure TEditarCentralesAguasArriba.listadoCentralesDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.listadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColsCentrales[ACol], nil, iconos);
end;

procedure TEditarCentralesAguasArriba.BAgregarClick(Sender: TObject);
begin
  editar(0);
end;

procedure TEditarCentralesAguasArriba.listadoCentralesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditarCentralesAguasArriba.listadoCentralesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsCentrales);
end;

procedure TEditarCentralesAguasArriba.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarCentralesAguasArriba.CBCentralDescargaChange(Sender: TObject);
var
  ipos: integer;
  nombre, clase: string;
begin
  if CBCentralDescarga.Items[CBCentralDescarga.ItemIndex] <> '<Ninguno>' then
  begin
    nombre := uCosaConNombre.ParseNombre(
      CBCentralDescarga.Items[CBCentralDescarga.ItemIndex]);
    clase := uCosaConNombre.ParseClase(
      CBCentralDescarga.Items[CBCentralDescarga.ItemIndex]);
    if centralesDisponibles.find(clase, nombre, ipos) then
    begin
      if centralDescarga <> nil then
        centralesDisponibles.Add(centralDescarga);
      centralDescarga := TGeneradorHidraulico(centralesDisponibles[ipos]);
      centralesDisponibles.Remove(centralDescarga);
      actualizarCBDescarga;
    end;
  end
  else
  begin
    if centralDescarga <> nil then
      centralesDisponibles.Add(centralDescarga);
    centralDescarga := nil;
  end;
end;


end.
