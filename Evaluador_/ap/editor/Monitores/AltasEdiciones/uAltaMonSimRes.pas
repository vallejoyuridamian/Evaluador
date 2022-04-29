unit uAltaMonSimRes;


interface

uses
   {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, uCosa, utilidades, uReferenciaMonitor, uSalasDeJuego,
  uManejadoresDeMonitores, uReferenciaMonSimRes, uCosaConNombre, uBaseAltasMonitores,
  uconstantesSimSEE, uEditarVariable, uOpcionesSimSEEEdit, uVerDoc;

resourcestring
  rsEditarMonitorArchivo = 'Editar Monitor de Archivo';
  rsGuardarMonitor = 'Guardar Monitor';
  rsActorAMonitorear = 'Actor a monitorear(Clase, Nombre)';
  rsNombreDeLaVariable = 'Nombre de la variable';
  mesEliminarVariableSeleccionada =
    '¿Confirma que desea eliminar la variable seleccionada?';
  mesConfirmarEliminacion = 'Confirmar eliminación';

type
  TAltaMonSimRes = class(TBaseAltasMonitores)
    LNMon: TLabel;
    LNArch: TLabel;
    LVars: TLabel;
    ENMon: TEdit;
    ENArch: TEdit;
    BElegirArchivo: TButton;
    sgVariables: TStringGrid;
    BAgregarVar: TButton;
    BAgregarMonitor: TButton;
    BCancelar: TButton;
    BAyuda: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure EditNombreExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure BElegirArchivoClick(Sender: TObject);
    procedure BAgregarVarClick(Sender: TObject);
    procedure listadoDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure listadoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure listadoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure listadoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BCancelarClick(Sender: TObject);
    procedure BAgregarMonitorClick(Sender: TObject);
  private
    ListaDefVars: TListaDeCosas; {of TReferenciaDefVar}
    ClasesCosas: TStrings;
    tiposColsVariables: TDAOfTTipoColumna;
  protected
    function editarListado(fila: integer; lista: TListaDeCosas; clonar: boolean): boolean;
    procedure eliminar(fila: integer; lista: TListaDeCosas);
    procedure actualizarTabla(tabla: TStringGrid; lista: TListaDeCosas);

    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TForm; monitor: TReferenciaMonitor;
      Sala: TSalaDeJuego; manejador: TManejadoresDeMonitores; alta: boolean;
      tipoReferencia: TClaseReferenciaMonitor); override;

    procedure Free;
  end;

implementation
  {$R *.lfm}

procedure TAltaMonSimRes.BAgregarMonitorClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    referencia := TReferenciaMonSimRes.Create(capa, ENMon.Text, ENArch.Text,
      ListaDefVars, SaladeJuego);
    ModalResult := mrOk;
  end;
end;

procedure TAltaMonSimRes.BAgregarVarClick(Sender: TObject);
begin
  editarListado(0, ListaDefVars, True);
end;

procedure TAltaMonSimRes.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TReferenciaMonSimRes);
end;

procedure TAltaMonSimRes.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TAltaMonSimRes.BElegirArchivoClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    SaveDialog1.FileName := SaveDialog1.FileName;
    ENArch.Text := SaveDialog1.FileName;
  end;
end;

constructor TAltaMonSimRes.Create(AOwner: TForm; monitor: TReferenciaMonitor;
  Sala: TSalaDeJuego; manejador: TManejadoresDeMonitores; alta: boolean;
  tipoReferencia: TClaseReferenciaMonitor);
var
  i: integer;
  aux: TCosaConNombre;
  monSimRes: TReferenciaMonSimRes;
  Catalogo: TCatalogoReferencias;
begin
  inherited Create(AOwner, monitor, Sala, manejador, alta, tipoReferencia);
  ClasesCosas := TStringList.Create;
  for i := 0 to ListaDeCosasMonitoreables.Count - 1 do
  begin
    aux := TCosaConNombre(ListaDeCosasMonitoreables[i]);
    ClasesCosas.Add(aux.ClassName + ', ' + aux.nombre);
  end;

  if monitor <> nil then
  begin
    self.Caption := rsEditarMonitorArchivo;
    BAgregarMonitor.Caption := rsGuardarMonitor;
    ENMon.Text := monitor.nombre;
    monSimRes := monitor as TReferenciaMonSimRes;
    ENMon.Text := monSimRes.nombre;
    ENArch.Text := monSimRes.filename;

    Catalogo:= TCatalogoReferencias.Create;
    ListaDefVars := monSimRes.defVars.Create_Clone( Catalogo, 0 ) as TListaDeCosas;
    Catalogo.Free;
  end
  else
    ListaDefVars := TListaDeCosas.Create(capa, 'ListaDefVars');
  guardado := True;
end;

procedure TAltaMonSimRes.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaMonSimRes.FormCreate(Sender: TObject);
begin
  SaveDialog1.InitialDir := getDir_Run;
  SaveDialog1.Filter :=
    'Plantilla (*.xlt)|*.xlt|Archivos de Texto (*.txt)|*.txt|Todos los Archivos (*.*)|(*.*)';
  SaveDialog1.DefaultExt := 'xlt';

  utilidades.initListado(sgVariables,
    [rsActorAMonitorear, rsNombreDeLaVariable,
    encabezadoBTEditar, encabezadoBTEliminar, encabezadoBTClonar,
    encabezadoBTUp, encabezadoBTDown],
    tiposColsVariables, True);

  actualizarTabla(sgVariables, ListaDefVars);

  BAgregarVar.Left := sgVariables.Left + sgVariables.Width - BAgregarVar.Width;
end;


procedure TAltaMonSimRes.Free;
begin
  ClasesCosas.Free;
  SetLength(tiposColsVariables, 0);
  if ModalResult <> mrOk then
    ListaDefVars.Free;
  inherited Free;
end;

procedure TAltaMonSimRes.listadoDrawCell(Sender: TObject; ACol, ARow: integer;
  Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColsVariables[ACol], nil, iconos);
end;

procedure TAltaMonSimRes.listadoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaMonSimRes.listadoMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsVariables);
end;

procedure TAltaMonSimRes.listadoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsVariables);
  case res of
    TC_btEditar: editarListado(TStringGrid(Sender).Row, ListaDefVars, False);
    TC_btEliminar: eliminar(TStringGrid(Sender).Row, ListaDefVars);
    TC_btClonar: if editarListado(TStringGrid(Sender).Row, ListaDefVars, True) then
        sgVariables.Row := sgVariables.RowCount - 1;
    TC_btUp: utilidades.listadoClickUp_(sgVariables,
        utilidades.filaListado, ListaDefVars.getList, Shift, nil, Modificado);
    TC_btDown: utilidades.listadoClickDown_(sgVariables,
        utilidades.filaListado, ListaDefVars.getList, Shift, nil, Modificado);
  end;
end;

function TAltaMonSimRes.editarListado(fila: integer; lista: TListaDeCosas;
  clonar: boolean): boolean;
var
  form: TEditarVariable;
  defVar: TReferenciaDefVar;
  res: boolean;
begin
  res := False;
  if fila = 0 then
    defVar := nil
  else
    defVar := TReferenciaDefVar(lista.items[fila - 1]);

  form := TEditarVariable.Create(self, ListaDeCosasMonitoreables, ClasesCosas, defVar);
  if form.ShowModal = mrOk then
  begin
    if defVar <> nil then
      if not clonar then
      begin
        lista.Remove(defVar);
        defVar.Free;
      end;
    lista.Add(form.darVariable);
    guardado := False;
    actualizarTabla(sgVariables, lista);
    res := True;
  end;
  form.Free;
  Result := res;
end;

procedure TAltaMonSimRes.EditNombreExit(Sender: TObject);
begin
  inherited validarNombre(ENMon.Text);
end;

procedure TAltaMonSimRes.eliminar(fila: integer; lista: TListaDeCosas);
begin
  if (Application.MessageBox(PChar(mesEliminarVariableSeleccionada),
    PChar(mesConfirmarEliminacion), MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    TReferenciaDefVar(lista[fila - 1]).Free;
    lista.Delete(fila - 1);
    guardado := False;
    actualizarTabla(sgVariables, lista);
  end;
end;

procedure TAltaMonSimRes.actualizarTabla(tabla: TStringGrid; lista: TListaDeCosas);
var
  i: integer;
begin
  //    lista.SortByFecha;
  tabla.RowCount := lista.Count + 1;
  if tabla.RowCount > 1 then
    tabla.FixedRows := 1
  else
    sgLimpiarSeleccion(tabla);

  for i := 0 to lista.Count - 1 do
  begin
    tabla.cells[0, i + 1] := TReferenciaDefVar(lista[i]).ClaseNombre;
    tabla.cells[1, i + 1] := TReferenciaDefVar(lista[i]).nombreVar;
  end;

  for i := 0 to tabla.ColCount - 1 do
    utilidades.AutoSizeTypedCol(tabla, i, tiposColsVariables[i], iconos);

  BAgregarVar.Left := sgVariables.Left + sgVariables.Width - BAgregarVar.Width;
end;

function TAltaMonSimRes.validarFormulario: boolean;
begin
  Result := inherited validarNombre(ENMon.Text) and
    inherited validarEditString(ENArch, LNArch.Caption) and
    inherited validarListaVarDefs(ListaDefVars);
end;

end.
