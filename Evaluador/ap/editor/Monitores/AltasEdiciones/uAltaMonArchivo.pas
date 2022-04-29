unit uAltaMonArchivo;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  uBaseAltasMonitores, StdCtrls, Grids, uCosa, uCosaConNombre,
  uReferenciaMonitor, uMonitores, uReferenciaMonArchivo, uMonitorArchivo,
  xMatDefs, uVarDefs,
  uSalasDeJuego, utilidades, uEditarVariable, uManejadoresDeMonitores,
  uConstantesSimSEE, uEditarMensaje, uEventosOptSim, uverdoc, uOpcionesSimSEEEdit;

resourcestring
  rsEditarMonitorArchivo = 'Editar Monitor de Archivo';
  rsGuardarMonitor = 'Guardar Monitor';
  mesEliminarVariableSeleccionada =
    '¿Confirma que desea eliminar la variable seleccionada?';
  mesConfirmarEliminacion = 'Confirmar eliminación';
  mesTodosLosEventosYaAsignados =
    'Todos los eventos de la sala de juegos ' +
    'tienen un evento asignado. Si desea modificar un mensaje haga click en ' +
    'el boton editar a la derecha del mensaje correspondiente.';
  mesConfirmaEliminarMensaje = '¿Confirma que desea eliminar el mensaje seleccionado?';
  rsActorAMonitorear = 'Actor a monitorear(Clase, Nombre)';
  rsNombreDeLaVariable = 'Nombre de la variable';
  rsMensaje = 'Mensaje';
  rsAsignadoAlEvento = 'Asignado al evento';

type
  TAltaMonArchivo = class(TBaseAltasMonitores)
    LNMon: TLabel;
    ENMon: TEdit;
    LNArch: TLabel;
    ENArch: TEdit;
    BElegirArchivo: TButton;
    sgVariables: TStringGrid;
    LVars: TLabel;
    LEventoAbrir: TLabel;
    LEventoEscribir: TLabel;
    LEventoCerrarArchivo: TLabel;
    BAgregarVar: TButton;
    CBEventoAbrir: TComboBox;
    CBEventoEscribir: TComboBox;
    CBEventoCerrar: TComboBox;
    BAgregarMonitor: TButton;
    BCancelar: TButton;
    LEventos: TLabel;
    BAgregarMensaje: TButton;
    sgMensajes: TStringGrid;
    LMensajes: TLabel;
    BAyuda: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BElegirArchivoClick(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure ListadoVariablesDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure ListadoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ListadoVariablesMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure ListadoVariablesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAgregarVarClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure listadoMensajesDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure ListadoMensajesMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure listadoMensajesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure BAgregarMensajeClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure EditNombreExit(Sender: TObject);
  private
    ListaDefVars: TListaDeCosas; {of TReferenciaDefVar}
    ClasesCosas: TStrings;
    tiposColsVariables: TDAOfTTipoColumna;
    tiposColsMensajes: TDAOfTTipoColumna;
    msgs: TList{of TRecEventoMsg};
  protected
    function editarListado(fila: integer; lista: TListaDeCosas;
      clonar: boolean): boolean;
    procedure eliminar(fila: integer; lista: TListaDeCosas);
    procedure actualizarTabla(tabla: TStringGrid; lista: TListaDeCosas);

    procedure editarMensaje(fila: integer; lista: TList);
    procedure eliminarMensaje(fila: integer; lista: TList);
    procedure actualizarTablaMensajes(lista: TList);

    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TForm; monitor: TReferenciaMonitor;
      Sala: TSalaDeJuego; manejador: TManejadoresDeMonitores;
      alta: boolean; tipoReferencia: TClaseReferenciaMonitor); override;

    procedure Free;
  end;

implementation

  {$R *.lfm}

constructor TAltaMonArchivo.Create(AOwner: TForm; monitor: TReferenciaMonitor;
  Sala: TSalaDeJuego; manejador: TManejadoresDeMonitores; alta: boolean;
  tipoReferencia: TClaseReferenciaMonitor);
var
  i, refProc: integer;
  aux: TCosaConNombre;
  msj: TRecOfEventoMsg;
  evento: TEventoOptSim;
  monArch: TReferenciaMonArchivo;
  Catalogo: TCatalogoReferencias;

begin
  inherited Create(AOwner, monitor, Sala, manejador, alta, tipoReferencia);
  msgs := TList.Create;
  ClasesCosas := TStringList.Create;
  for i := 0 to ListaDeCosasMonitoreables.Count - 1 do
  begin
    aux := TCosaConNombre(ListaDeCosasMonitoreables[i]);
    ClasesCosas.Add(aux.ClassName + ', ' + aux.nombre);
  end;

  CBEventoAbrir.Items := uEventosOptSim.nombresEventos;
  CBEventoEscribir.Items := uEventosOptSim.nombresEventos;
  CBEventoCerrar.Items := uEventosOptSim.nombresEventos;

  if monitor <> nil then
  begin
    self.Caption := rsEditarMonitorArchivo;
    BAgregarMonitor.Caption := rsGuardarMonitor;
    ENMon.Text := monitor.nombre;
    monArch := monitor as TReferenciaMonArchivo;
    ENMon.Text := monArch.nombre;
    ENArch.Text := monArch.filename;

    Catalogo := TCatalogoReferencias.Create;
    ListaDefVars := monArch.defVars.Create_Clone(Catalogo, 0) as TListaDeCosas;
    Catalogo.Free;

    for i := 0 to high(monArch.eventos) do
    begin
      evento := monitor.eventos[i].evento;
      refProc := monitor.eventos[i].refProc;
      if refProc = TMonArchivo.darRefProc('AbrirArchivo', evento) then
      begin
        CBEventoAbrir.ItemIndex :=
          CBEventoAbrir.Items.IndexOf(uEventosOptSim.EventoToStr(
          monitor.eventos[i].evento));
      end
      else if refProc = TMonArchivo.darRefProc('EscribirArchivo', evento) then
      begin
        CBEventoEscribir.ItemIndex :=
          CBEventoEscribir.Items.IndexOf(uEventosOptSim.EventoToStr(
          monitor.eventos[i].evento));
      end
      else if refProc = TMonArchivo.darRefProc('CerrarArchivo', evento) then
      begin
        CBEventoCerrar.ItemIndex :=
          CBEventoCerrar.Items.IndexOf(uEventosOptSim.EventoToStr(
          monitor.eventos[i].evento));
      end
      else
      begin
        msj := TRecOfEventoMsg.Create(evento, monArch.mensajes[evento]);
        msgs.Add(msj);
      end;
    end;
  end
  else
    ListaDefVars := TListaDeCosas.Create(capa, 'ListaDefVars');
  guardado := True;
end;

procedure TAltaMonArchivo.Free;
begin
  ClasesCosas.Free;
  SetLength(tiposColsVariables, 0);
  SetLength(tiposColsMensajes, 0);
  if ModalResult <> mrOk then
    ListaDefVars.Free;
  inherited Free;
end;

function TAltaMonArchivo.editarListado(fila: integer; lista: TListaDeCosas;
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

procedure TAltaMonArchivo.eliminar(fila: integer; lista: TListaDeCosas);
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

procedure TAltaMonArchivo.actualizarTabla(tabla: TStringGrid; lista: TListaDeCosas);
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

procedure TAltaMonArchivo.editarMensaje(fila: integer; lista: TList);
var
  form: TEditarMensaje;
  msj: TRecOfEventoMsg;
  eventosDisponibles: TStrings;

  function listadoEventosDisponibles(msj: TRecOfEventoMsg): TStrings;
  var
    res: TStrings;
    i, j: integer;
    disponible: boolean;
    evento: string;
    iterEventoMsj, iterEventoSala: string;
  begin
    res := TStringList.Create;
    if msj <> nil then
      evento := EventoToStr(msj.evento)
    else
      evento := '';

    for i := 0 to uEventosOptSim.nombresEventos.Count - 1 do
    begin
      iterEventoSala := uEventosOptSim.nombresEventos[i];
      disponible := True;
      for j := 0 to msgs.Count - 1 do
      begin
        iterEventoMsj := EventoToStr(TRecOfEventoMsg(msgs[j]).evento);
        if (iterEventoMsj = iterEventoSala) and (iterEventoMsj <> evento) then
        begin
          disponible := False;
          break;
        end;
      end;
      if disponible then
        res.Add(iterEventoSala);
    end;
    Result := res;
  end;

begin
  if msgs.Count = uEventosOptSim.nombresEventos.Count then
  begin
    ShowMessage(mesTodosLosEventosYaAsignados);
  end
  else
  begin
    if fila = 0 then
    begin
      msj := nil;
    end
    else
    begin
      msj := TRecOfEventoMsg(lista[fila - 1]);
    end;

    eventosDisponibles := listadoEventosDisponibles(msj);

    form := TEditarMensaje.Create(self, msj, eventosDisponibles);
    if form.ShowModal = mrOk then
    begin
      if msj <> nil then
      begin
        lista.Remove(msj);
        msj.Free;
      end;
      lista.Add(form.darMsj);
      guardado := False;
      actualizarTablaMensajes(lista);
    end;
    form.Free;
  end;
end;

procedure TAltaMonArchivo.EditNombreExit(Sender: TObject);
begin
  inherited validarNombre(ENMon.Text);
end;

procedure TAltaMonArchivo.eliminarMensaje(fila: integer; lista: TList);
begin
  if (Application.MessageBox(PChar(mesConfirmaEliminarMensaje),
    PChar(mesConfirmarEliminacion), MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    TRecOfEventoMsg(lista[fila - 1]).Free;
    lista.Delete(fila - 1);
    guardado := False;
    actualizarTablaMensajes(lista);
  end;
end;

procedure TAltaMonArchivo.actualizarTablaMensajes(lista: TList);
var
  i: integer;
begin
  lista.Sort(compareRecOfEventoMsg);
  sgMensajes.RowCount := lista.Count + 1;
  if sgMensajes.RowCount > 1 then
    sgMensajes.FixedRows := 1
  else
    sgLimpiarSeleccion(sgMensajes);

  for i := 0 to lista.Count - 1 do
  begin
    sgMensajes.cells[0, i + 1] := TRecOfEventoMsg(lista[i]).msg;
    sgMensajes.cells[1, i + 1] := EventoToStr(TRecOfEventoMsg(lista[i]).evento);
  end;

  for i := 0 to sgMensajes.ColCount - 1 do
    utilidades.AutoSizeTypedCol(sgMensajes, i, tiposColsMensajes[i], iconos);

  BAgregarMensaje.Left := sgMensajes.Left + sgMensajes.Width - BAgregarMensaje.Width;
end;

function TAltaMonArchivo.validarFormulario: boolean;
begin
  inherited validarFormulario;
  Result := inherited validarNombre(ENMon.Text) and
    inherited validarEditString(ENArch, LNArch.Caption) and
    inherited validarListaVarDefs(ListaDefVars) and
    inherited validarCBEvento(CBEventoAbrir, LEventoAbrir) and
    inherited validarCBEvento(CBEventoEscribir, LEventoEscribir) and
    inherited validarCBEvento(CBEventoCerrar, LEventoCerrarArchivo);
end;

procedure TAltaMonArchivo.FormCreate(Sender: TObject);
begin
  SaveDialog1.InitialDir := getDir_Run;
  SaveDialog1.Filter :=
    'Plantilla (*.xlt)|*.xlt|Archivos de Texto (*.txt)|*.txt|Todos los Archivos (*.*)|(*.*)';
  SaveDialog1.DefaultExt := 'xlt';

  utilidades.initListado(sgVariables,
    [rsActorAMonitorear, rsNombreDeLaVariable, encabezadoBTEditar,
    encabezadoBTEliminar, encabezadoBTClonar, encabezadoBTUp, encabezadoBTDown],
    tiposColsVariables, True);

  actualizarTabla(sgVariables, ListaDefVars);

  BAgregarVar.Left := sgVariables.Left + sgVariables.Width - BAgregarVar.Width;

  utilidades.initListado(sgMensajes,
    [rsMensaje, rsAsignadoAlEvento, encabezadoBTEditar, encabezadoBTEliminar],
    tiposColsMensajes, True);

  actualizarTablaMensajes(msgs);

  BAgregarMensaje.Left := sgMensajes.Left + sgMensajes.Width - BAgregarMensaje.Width;
end;


procedure TAltaMonArchivo.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaMonArchivo.BElegirArchivoClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    SaveDialog1.FileName := SaveDialog1.FileName;
    ENArch.Text := SaveDialog1.FileName;
  end;
end;

procedure TAltaMonArchivo.CambiosForm(Sender: TObject);
begin
  guardado := False;
end;

procedure TAltaMonArchivo.ListadoVariablesDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColsVariables[ACol], nil, iconos);
end;

procedure TAltaMonArchivo.ListadoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaMonArchivo.ListadoVariablesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsVariables);
end;

procedure TAltaMonArchivo.ListadoVariablesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
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
        utilidades.filaListado, ListaDefVars.getList, Shift, nil, Modificado, nil );
    TC_btDown: utilidades.listadoClickDown_(sgVariables,
        utilidades.filaListado, ListaDefVars.getList, Shift, nil, Modificado, nil );
  end;
end;

procedure TAltaMonArchivo.BAgregarVarClick(Sender: TObject);
begin
  editarListado(0, ListaDefVars, True);
end;

procedure TAltaMonArchivo.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TAltaMonArchivo.BGuardarClick(Sender: TObject);
var
  i: integer;
  eventos: TDAOfEventoProc;
  mensajes: TDAOfMsgs;
  j: TEventoOptSim;
begin
  if validarFormulario then
  begin
    SetLength(eventos, 3 + msgs.Count);

    for j := low(TEventoOptSim) to high(TEventoOptSim) do
      mensajes[j] := '';

    for i := 0 to msgs.Count - 1 do
    begin
      eventos[i].evento := TRecOfEventoMsg(msgs[i]).evento;
      eventos[i].refProc := uMonitorArchivo.TMonArchivo.darRefProc(
        'EscribirMsg', eventos[i].evento);
      mensajes[TRecOfEventoMsg(msgs[i]).evento] := TRecOfEventoMsg(msgs[i]).msg;
    end;

    eventos[msgs.Count].evento :=
      StrToEvento(CBEventoAbrir.Items[CBEventoAbrir.ItemIndex]);
    eventos[msgs.Count].refProc :=
      uMonitorArchivo.TMonArchivo.darRefProc('AbrirArchivo', eventos[msgs.Count].evento);
    eventos[msgs.Count + 1].evento :=
      StrToEvento(CBEventoEscribir.Items[CBEventoEscribir.ItemIndex]);
    eventos[msgs.Count + 1].refProc :=
      uMonitorArchivo.TMonArchivo.darRefProc('EscribirArchivo',
      eventos[msgs.Count + 1].evento);
    ;
    eventos[msgs.Count + 2].evento :=
      StrToEvento(CBEventoCerrar.Items[CBEventoCerrar.ItemIndex]);
    eventos[msgs.Count + 2].refProc :=
      uMonitorArchivo.TMonArchivo.darRefProc('CerrarArchivo',
      eventos[msgs.Count + 2].evento);

    referencia := TReferenciaMonArchivo.Create(capa, ENMon.Text,
      ENArch.Text, ListaDefVars, eventos, mensajes);
    ModalResult := mrOk;
  end;
end;

procedure TAltaMonArchivo.listadoMensajesDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColsMensajes[ACol], nil, iconos);
end;

procedure TAltaMonArchivo.ListadoMensajesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsMensajes);
end;

procedure TAltaMonArchivo.listadoMensajesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsMensajes);
  case res of
    TC_btEditar: editarMensaje(TStringGrid(Sender).Row, msgs);
    TC_btEliminar: eliminarMensaje(TStringGrid(Sender).Row, msgs);
  end;
end;


procedure TAltaMonArchivo.BAgregarMensajeClick(Sender: TObject);
begin
  editarMensaje(0, msgs);
end;

procedure TAltaMonArchivo.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TReferenciaMonArchivo);
end;

end.
