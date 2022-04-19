unit uAltaMonitorGrafico;
  {$MODE Delphi}
interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uBaseAltasMonitores, uCosa, uCosaConNombre, xMatDefs, uVarDefs,
  uReferenciaMonitorGraficoSimple, uReferenciaMonitor,
  uSalasDeJuego, ExtCtrls, Grids, uMonitores, utilidades, uEditarSerie,
  uManejadoresDeMonitores, uEventosOptSim, uverdoc, uConstantesSimSEE,
  uOpcionesSimSEEEdit;

resourcestring
  rsEditarMonitorGrafico = 'Editar monitor gráfico';
  rsGuardarMonitor = 'Guardar Monitor';
  rsPasoDelTiempo = 'Paso del tiempo';
  mesConfirmaEliminarSerie = '¿Confirma que desea eliminar la serie seleccionada?';
  mesConfirmarEliminacion = 'Confirmar eliminación';
  rsNombreDeLaSerie = 'Nombre de la serie';
  rsActorAMonitorear = 'Actor a monitorear(Clase, Nombre)';
  rsNombreDeLaVariable = 'Nombre de la variable';


type

  { TAltaMonitorGrafico }

  TAltaMonitorGrafico = class(TBaseAltasMonitores)
    BAgregarMonitor: TButton;
    BAgregarSerie: TButton;
    BAyuda: TButton;
    BCancelar: TButton;
    CBEventoGraficar: TComboBox;
    CBEventoLimpiar: TComboBox;
    CBGrilla: TCheckBox;
    ECantPtos: TEdit;
    EDiffX: TEdit;
    EEtiquetax: TEdit;
    EEtiquetay: TEdit;
    ENDivX: TEdit;
    ENDivY: TEdit;
    ENGrafico: TEdit;
    ENSerieX: TEdit;
    EX1: TEdit;
    EX2: TEdit;
    EXFin: TEdit;
    EXIni: TEdit;
    EY1: TEdit;
    EY2: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    LCantPtos: TLabel;
    LDiffX: TLabel;
    LEtiquetax: TLabel;
    LEtiquetay: TLabel;
    LEventoGraficar: TLabel;
    LEventoLimpiar: TLabel;
    LNDivx: TLabel;
    LNDivY: TLabel;
    LNgrafico: TLabel;
    LNSeriex: TLabel;
    LRect: TLabel;
    LX1: TLabel;
    LX2: TLabel;
    ColorDialog1: TColorDialog;
    LXFin: TLabel;
    LXIni: TLabel;
    LY1: TLabel;
    LY2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    sgVariables: TStringGrid;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBGrillaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditNatExit(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure ListadoDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure ListadoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure ListadoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ListadoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure EditIntExit(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure BAgregarSerieClick(Sender: TObject);
    procedure EDiffXExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  protected
    function editarListado(fila: integer; lista: TListaDeCosas;
      clonar: boolean): boolean;
    procedure eliminar(fila: integer; lista: TListaDeCosas);
    procedure cambiarColor(fila: integer; ListaDeSeries: TlistaDeCosas);

    procedure actualizarTabla(tabla: TStringGrid; lista: TListaDeCosas);

    function validarFormulario: boolean; override;
  private
    ClasesCosas: TStringList;
    ListaDeSeries: TListaDeCosas; {of TReferenciaSerie}
    TiposDeColumna: TDAOfTTipoColumna;
    colores: TDAOfColores;

    procedure rearmarColores();
    procedure recalcularCantPtos;
  public
    constructor Create(AOwner: TForm; monitor: TReferenciaMonitor;
      sala: TSalaDeJuego; manejador: TManejadoresDeMonitores;
      alta: boolean; tipoReferencia: TClaseReferenciaMonitor); override;

    procedure Free;
  end;

implementation

  {$R *.lfm}

constructor TAltaMonitorGrafico.Create(AOwner: TForm; monitor: TReferenciaMonitor;
  sala: TSalaDeJuego; manejador: TManejadoresDeMonitores; alta: boolean;
  tipoReferencia: TClaseReferenciaMonitor);
var
  i: integer;
  aux: TCosaConNombre;
  monGraf: TReferenciaMonGrafico;
 Catalogo: TCatalogoReferencias;

begin
  inherited Create(AOwner, monitor, sala, manejador, alta, tipoReferencia);

  ClasesCosas := TStringList.Create;
  for i := 0 to ListaDeCosasMonitoreables.Count - 1 do
  begin
    aux := TCosaConNombre(ListaDeCosasMonitoreables[i]);
    ClasesCosas.Add(aux.ClassName + ', ' + aux.nombre);
  end;
  CBEventoGraficar.Items := uEventosOptSim.nombresEventos;
  CBEventoLimpiar.Items := uEventosOptSim.nombresEventos;
  if monitor <> nil then
  begin
    self.Caption := rsEditarMonitorGrafico;
    BAgregarMonitor.Caption := rsGuardarMonitor;
    ENGrafico.Text := monitor.nombre;
    monGraf := monitor as TReferenciaMonGrafico;
    ENGrafico.Text := monGraf.nombreGrafico;
    ECantPtos.Text := IntToStr(monGraf.MaxNPuntos);
    EEtiquetax.Text := monGraf.etiquetax;
    EEtiquetay.Text := monGraf.etiquetay;
    ENSerieX.Text := monGraf.nombre_sx;
    EXIni.Text := IntToStr(monGraf.XIni);
    EXFin.Text := IntToStr(monGraf.diffX * monGraf.MaxNPuntos + monGraf.XIni - 1);
    EDiffX.Text := IntToStr(monGraf.diffX);

    Catalogo:= TCatalogoReferencias.Create;
    ListaDeSeries := mongraf.defVars.Create_Clone( Catalogo, 0 ) as TListaDeCosas;
    Catalogo.Free;

    CBEventoGraficar.ItemIndex :=
      CBEventoGraficar.Items.IndexOf(uEventosOptSim.EventoToStr(
      monitor.eventos[0].evento));
    CBEventoLimpiar.ItemIndex :=
      CBEventoLimpiar.Items.IndexOf(
      uEventosOptSim.EventoToStr(monitor.eventos[1].evento));
    EX1.Text := FloatToStr(monGraf.x1);
    EX2.Text := FloatToStr(monGraf.x2);
    EY1.Text := FloatToStr(monGraf.y1);
    EY2.Text := FloatToStr(monGraf.y2);
    CBGrilla.Checked := monGraf.grilla;
    ENDivX.Text := IntToStr(monGraf.NDivisionesX);
    ENDivY.Text := IntToStr(monGraf.NDivisionesY);
  end
  else
  begin
    ENSerieX.Text := rsPasoDelTiempo;
    EXIni.Text := '1';
    EXFin.Text := IntToStr(sala.globs.calcNPasosSim);
    EDiffX.Text := '1';
    recalcularCantPtos;

    ListaDeSeries := TListaDeCosas.Create(capa, 'ListaDeSeries');

    EX1.Text := '1';
    EX2.Text := IntToStr(Sala.globs.calcNPasosSim);
    EY1.Text := '0';
    EY2.Text := '2000';
  end;
  guardado := True;
end;

procedure TAltaMonitorGrafico.Free;
begin
  ClasesCosas.Free;
  SetLength(TiposDeColumna, 0);
  SetLength(colores, 0);
  if ModalResult <> mrOk then
    ListaDeSeries.Free;
  inherited Free;
end;

procedure TAltaMonitorGrafico.rearmarColores();
var
  i: integer;
begin
  SetLength(colores, 0);
  SetLength(colores, listaDeSeries.Count);
  for i := 0 to ListaDeSeries.Count - 1 do
    colores[i] := TReferenciaSerie(ListaDeSeries[i]).color;
  sgVariables.Invalidate;
end;

procedure TAltaMonitorGrafico.recalcularCantPtos;
begin
  if (EXIni.Text <> '') and (EXFin.Text <> '') and (EDiffX.Text <> '') then
    ECantPtos.Text := IntToStr((StrToInt(EXFin.Text) - StrToInt(EXIni.Text) + 1) div
      StrToInt(EDiffX.Text));
end;

function TAltaMonitorGrafico.editarListado(fila: integer; lista: TListaDeCosas;
  clonar: boolean): boolean;
var
  form: TEditarSerie;
  serie: TReferenciaSerie;
  res: boolean;
begin
  res := False;
  if fila = 0 then
    serie := nil
  else
    serie := TReferenciaSerie(lista.items[fila - 1]);

  form := TEditarSerie.Create(self, ListaDeCosasMonitoreables, ClasesCosas, serie);
  if form.ShowModal = mrOk then
  begin
    if serie <> nil then
      if not clonar then
      begin
        lista.Remove(serie);
        serie.Free;
      end;
    lista.Add(form.darSerie);
    guardado := False;
    actualizarTabla(sgVariables, lista);
    res := True;
  end;
  form.Free;
  Result := res;
end;

procedure TAltaMonitorGrafico.eliminar(fila: integer; lista: TListaDeCosas);
begin
  if (Application.MessageBox(PChar(mesConfirmaEliminarSerie),
    PChar(mesConfirmarEliminacion), MB_OKCANCEL + MB_ICONEXCLAMATION) = idOk) then
  begin
    TReferenciaSerie(lista[fila - 1]).Free;
    lista.Delete(fila - 1);
    rearmarColores;
    guardado := False;
    actualizarTabla(sgVariables, lista);
  end;
end;

procedure TAltaMonitorGrafico.cambiarColor(fila: integer; ListaDeSeries: TlistaDeCosas);
begin
  if ColorDialog1.Execute then
  begin
    TReferenciaSerie(ListaDeSeries[fila - 1]).color := ColorDialog1.Color;
    rearmarColores;
  end;
end;

procedure TAltaMonitorGrafico.actualizarTabla(tabla: TStringGrid; lista: TListaDeCosas);
var
  i: integer;
begin
  //    lista.SortByFecha;
  rearmarColores();
  tabla.RowCount := lista.Count + 1;
  if tabla.RowCount > 1 then
    tabla.FixedRows := 1;

  for i := 0 to lista.Count - 1 do
  begin
    tabla.cells[0, i + 1] := TReferenciaSerie(lista[i]).nombreSerie;
    tabla.cells[1, i + 1] := TReferenciaSerie(lista[i]).claseCosa +
      ', ' + TReferenciaSerie(lista[i]).nombreCosa;
    tabla.cells[2, i + 1] := TReferenciaSerie(lista[i]).nombreVar;
  end;

  for i := 0 to tabla.ColCount - 1 do
    utilidades.AutoSizeTypedCol(tabla, i, tiposdeColumna[i], iconos);

end;

function TAltaMonitorGrafico.validarFormulario: boolean;
begin
  inherited validarFormulario;
  Result := inherited validarNombre(ENGrafico.Text) and
    inherited validarEditString(EEtiquetax, LEtiquetax.Caption) and
    inherited validarEditString(EEtiquetay, LEtiquetay.Caption) and
    inherited validarEditString(ENSerieX, LNSeriex.Caption) and
    inherited validarEditInt(EXIni, -MAXINT, MAXINT) and
    inherited validarEditInt(EXFin, -MAXINT, MAXINT) and
    inherited validarEditInt(EDiffX, 1, MAXINT) and
    inherited validarCBEvento(CBEventoGraficar, LEventoGraficar) and
    inherited validarCBEvento(CBEventoLimpiar, LEventoLimpiar) and
    inherited validarEditFloat(EX1, -MAXINT, MAXINT) and
    inherited validarEditFloat(EX2, -MAXINT, MAXINT) and
    inherited validarEditFloat(EY1, -MAXINT, MAXINT) and
    inherited validarEditFloat(EY2, -MAXINT, MAXINT) and
    (not CBGrilla.Checked or (validarEditInt(ENDivX, 1, MAXINT) and
    validarEditInt(ENDivY, 1, MAXINT))) and
    inherited  validarListaVarDefs(ListaDeSeries);
end;

procedure TAltaMonitorGrafico.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaMonitorGrafico.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TAltaMonitorGrafico.BGuardarClick(Sender: TObject);
var
  evprocs: TDAOfEventoProc;
begin
  if validarFormulario then
  begin
    SetLength(evprocs, 2);
    evprocs[0].evento := StrToEvento(CBEventoGraficar.Items[CBEventoGraficar.ItemIndex]);
    evprocs[0].refProc := 1;
    evprocs[1].evento := StrToEvento(CBEventoLimpiar.Items[CBEventoLimpiar.ItemIndex]);
    evprocs[1].refProc := 2;
    referencia := TReferenciaMonGrafico.Create(capa, ENGrafico.Text,
      evprocs, ENGrafico.Text, StrToInt(ECantPtos.Text), ENSerieX.Text,
      EEtiquetax.Text, EEtiquetay.Text, StrToFloat(EX1.Text),
      StrToFloat(EX2.Text), StrToFloat(EY1.Text), StrToFloat(EY2.Text),
      StrToInt(ENDivX.Text), StrToInt(ENDivY.Text), StrToInt(EXIni.Text),
      StrToInt(EDiffX.Text), ListaDeSeries, CBGrilla.Checked);
    ModalResult := mrOk;
  end;
end;

procedure TAltaMonitorGrafico.CBGrillaClick(Sender: TObject);
begin
  ENDivX.Enabled := CBGrilla.Checked;
  ENDivY.Enabled := CBGrilla.Checked;
  guardado := False;
end;

procedure TAltaMonitorGrafico.FormCreate(Sender: TObject);
begin
  utilidades.initListado(sgVariables,
    [rsNombreDeLaSerie, rsActorAMonitorear, rsNombreDeLaVariable,
    encabezadoColor, encabezadoBTEditar, encabezadoBTEliminar,
    encabezadoBTClonar, encabezadoBTUp, encabezadoBTDown],
    TiposDeColumna, True);

  actualizarTabla(sgVariables, ListaDeSeries);

  SetLength(colores, sgVariables.RowCount);
end;

procedure TAltaMonitorGrafico.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaMonitorGrafico.EditNatExit(Sender: TObject);
begin
  inherited ValidarEditInt(Sender as TEdit, 1, MAXINT);
end;

procedure TAltaMonitorGrafico.CambiosForm(Sender: TObject);
begin
  guardado := False;
end;


procedure TAltaMonitorGrafico.ListadoDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    TiposDeColumna[ACol], colores, iconos);
end;

procedure TAltaMonitorGrafico.ListadoMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, TiposDeColumna);
end;

procedure TAltaMonitorGrafico.ListadoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TAltaMonitorGrafico.ListadoMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposDeColumna);
  case res of
    TC_btEditar: editarListado(TStringGrid(Sender).Row, ListaDeSeries, False);
    TC_btEliminar: eliminar(TStringGrid(Sender).Row, ListaDeSeries);
    TC_btClonar: if editarListado(TStringGrid(Sender).Row, ListaDeSeries, True) then
        TStringGrid(Sender).Row := TStringGrid(Sender).RowCount - 1;
    TC_btUp:
    begin
      utilidades.listadoClickUp_(sgVariables,
        utilidades.filaListado, ListaDeSeries.getList, Shift, nil, Modificado, colores);
//      rearmarColores;
    end;
    TC_btDown:
    begin
      utilidades.listadoClickDown_(sgVariables,
        utilidades.filaListado, ListaDeSeries.getList, Shift, nil, Modificado, colores );
//      rearmarColores;
    end;
    TC_Color: cambiarColor(TStringGrid(Sender).Row, ListaDeSeries);
  end;
end;

procedure TAltaMonitorGrafico.EditIntExit(Sender: TObject);
begin
  if inherited ValidarEditInt(Sender as TEdit, -MAXINT, MAXINT) then
    recalcularCantPtos;
end;

procedure TAltaMonitorGrafico.EditFloatExit(Sender: TObject);
begin
  inherited ValidarEditFloat(Sender as TEdit, -MAXINT, MAXINT);
end;

procedure TAltaMonitorGrafico.BAgregarSerieClick(Sender: TObject);
begin
  editarListado(0, ListaDeSeries, True);
end;

procedure TAltaMonitorGrafico.EDiffXExit(Sender: TObject);
begin
  if inherited validarEditInt(Sender as TEdit, 1, MAXINT) then
    recalcularCantPtos;
end;

procedure TAltaMonitorGrafico.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TReferenciaMonGrafico);
end;

end.
