unit uAltaMonHistograma;
  {$MODE Delphi}

interface

uses
   {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, uBaseAltasMonitores, uCosaConNombre, uReferenciaMonitor,
  uReferenciaMonHistograma, uSalasDeJuego, xMatDefs, uVarDefs, utilidades,
  uMonitores, Math, uManejadoresDeMonitores, uconstantesSimSEE, uEventosOptSim,
  uverdoc, uOpcionesSimSEEEdit;

resourcestring
  rsEditarMonitorHistograma = 'Editar Monitor de Histograma';
  rsGuardarMonitor = 'Guardar Monitor';
  mesValorIntroducidoDebeNum = 'El valor introducido debe ser numérico';
  mesValorIngresadoAntecesorSucesor =
    'El valor ingresado debe estar entre su antecesor y su sucesor en el vector';
  mesValoresEnTablaNumericos =
    'Los valores introducidos en la tabla deben ser numéricos';
  mesValoresTablaOrdenadosMenorMayor =
    'Los valores introducidos en la tabla deben estar ordenados de menor a mayor';

type
  TAltaMonitorHistograma = class(TBaseAltasMonitores)
    LNombre_Y_Clase: TLabel;
    LNVar: TLabel;
    LEvento: TLabel;
    LNMon: TLabel;
    CBNombre_Y_Clase: TComboBox;
    CBVariable: TComboBox;
    BAgregarMonitor: TButton;
    BCancelar: TButton;
    CBEvento: TComboBox;
    ENMon: TEdit;
    sgIntervalos: TStringGrid;
    LNIntervalos: TLabel;
    ENIntervalos: TEdit;
    BAyuda: TButton;
    procedure CBNombre_Y_ClaseChange(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure CBVariableChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure EditEnter(Sender: TObject);
    procedure EditNombreExit(Sender: TObject);
    procedure EditTamTablaExit(Sender: TObject);
    procedure sgValidarCambio(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer; var Value: string);
    procedure sgIntervalosKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure sgIntervalosDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarFormulario(): boolean; override;
    procedure validarCambioTabla(tabla: TStringGrid); override;
  private
    tiposColsIntervalos: array of TTipoColumna;
    function validarTabla(sg: TStringGrid): boolean;
    procedure rearmarTiposColsIntervalos;
  public
    constructor Create(AOwner: TForm; monitor: TReferenciaMonitor;
      Sala: TSalaDeJuego; manejador: TManejadoresDeMonitores; alta: boolean;
      tipoReferencia: TClaseReferenciaMonitor); override;

    procedure Free;
  end;

implementation

  {$R *.lfm}

constructor TAltaMonitorHistograma.Create(AOwner: TForm;
  monitor: TReferenciaMonitor; Sala: TSalaDeJuego; manejador: TManejadoresDeMonitores;
  alta: boolean; tipoReferencia: TClaseReferenciaMonitor);
var
  i: integer;
  aux: TCosaConNombre;
  claseNombre: string;
begin
  inherited Create(AOwner, monitor, Sala, manejador, alta, tipoReferencia);
  for i := 0 to ListaDeCosasMonitoreables.Count - 1 do
  begin
    aux := TCosaConNombre(ListaDeCosasMonitoreables[i]);
    CBNombre_Y_Clase.Items.Add(aux.ClassName + ', ' + aux.nombre);
  end;
  CBEvento.Items := uEventosOptSim.nombresEventos;
  if monitor <> nil then
  begin
    self.Caption := rsEditarMonitorHistograma;
    BAgregarMonitor.Caption := rsGuardarMonitor;
    ENMon.Text := monitor.nombre;

    //    ENIntervalos.Text := IntToStr(Length(TReferenciaMonHistograma(monitor).intervalos));
    sgIntervalos.ColCount := Length(TReferenciaMonHistograma(monitor).intervalos) + 2;
    sgIntervalos.Cells[0, 1] := '-Inf';
    for i := 0 to high(TReferenciaMonHistograma(monitor).intervalos) do
      sgIntervalos.Cells[i + 1, 1] :=
        FloatToStr(TReferenciaMonHistograma(monitor).intervalos[i]);
    sgIntervalos.Cells[sgIntervalos.ColCount - 1, 1] := 'Inf';

    claseNombre := TReferenciaMonHistograma(monitor).defvar.claseCosa +
      ', ' + TReferenciaMonHistograma(monitor).defvar.nombreCosa;
    CBNombre_Y_Clase.ItemIndex := CBNombre_Y_Clase.Items.IndexOf(claseNombre);
    CBNombre_Y_ClaseChange(CBNombre_Y_Clase);
    CBVariable.ItemIndex := CBVariable.Items.IndexOf(
      TReferenciaMonHistograma(monitor).defvar.nombreVar);
    CBEvento.ItemIndex := CBEvento.Items.IndexOf(
      uEventosOptSim.EventoToStr(monitor.eventos[0].evento));
  end
  else
  begin
    sgIntervalos.ColCount := 7;
    sgIntervalos.Cells[0, 1] := '-Inf';
    for i := 1 to sgIntervalos.ColCount - 2 do
      sgIntervalos.Cells[i, 1] := IntToStr(i);
  end;
  sgIntervalos.Cells[sgIntervalos.ColCount - 1, 1] := 'Inf';
  guardado := True;
end;

procedure TAltaMonitorHistograma.Free;
begin
  inherited Free;
end;

function TAltaMonitorHistograma.validarFormulario(): boolean;
begin
  Result := inherited validarNombre(ENMon.Text) and
    inherited validarCBActor(CBNombre_Y_Clase) and
    inherited validarCBVariable(CBVariable) and
    inherited validarCBEvento(CBEvento, LEvento) and
    validarTabla(sgIntervalos);
end;

procedure TAltaMonitorHistograma.validarCambioTabla(tabla: TStringGrid);
var
  x: NReal;
begin
  if (colValidarSG > 0) and (colValidarSG < sgIntervalos.ColCount - 1) and
    (sgIntervalos.ColCount > 3) then//Evito los 'Inf'
  begin
    if (tabla.Cells[colValidarSG, filaValidarSG] <> '') and
      (filaValidarSG > tabla.FixedRows - 1) and (colValidarSG > tabla.FixedCols - 1) then
    begin
      try
        begin
          x := StrToFloat(tabla.cells[colValidarSG, filaValidarSG]);
          if (colValidarSG > 1) and (colValidarSG < sgIntervalos.ColCount - 2) then
          begin
            if (x <= StrToFloat(sgIntervalos.Cells[colValidarSG - 1, 1])) or
              (x >= StrToFloat(sgIntervalos.Cells[colValidarSG + 1, 1])) then
              raise ERangeError.Create('');
          end
          else if colValidarSG = 1 then
          begin
            if x >= StrToFloat(sgIntervalos.Cells[colValidarSG + 1, 1]) then
              raise ERangeError.Create('');
          end
          else if colValidarSG = sgIntervalos.ColCount - 2 then
          begin
            if x <= StrToFloat(sgIntervalos.Cells[colValidarSG - 1, 1]) then
              raise ERangeError.Create('');
          end;
          guardado := False;
        end
      except
        on EConvertError do
        begin
          tabla.Cells[colValidarSG, filaValidarSG] := loQueHabia;
          ShowMessage(mesValorIntroducidoDebeNum);
        end;
        on ERangeError do
        begin
          tabla.Cells[colValidarSG, filaValidarSG] := loQueHabia;
          ShowMessage(mesValorIngresadoAntecesorSucesor);
        end
      end;
    end;
  end;
end;

function TAltaMonitorHistograma.validarTabla(sg: TStringGrid): boolean;
var
  i: integer;
  x, xAnt: NReal;
begin
  try
    begin
      xAnt := -Math.MaxDouble;
      for i := 1 to sg.ColCount - 2 do
      begin
        x := StrToFloat(sg.cells[i, 1]);
        if x < xAnt then
        begin
          raise ERangeError.Create('');
        end;
        xAnt := x;
      end;
      Result := True;
    end
  except
    on EConvertError do
    begin
      ShowMessage(mesValoresEnTablaNumericos);
      Result := False;
    end;
    on ERangeError do
    begin
      ShowMessage(mesValoresTablaOrdenadosMenorMayor);
      Result := False;
    end;
  end;
end;

procedure TAltaMonitorHistograma.rearmarTiposColsIntervalos;
var
  i: integer;
begin
  tiposColsIntervalos := nil;
  SetLength(tiposColsIntervalos, sgIntervalos.ColCount);
  tiposColsIntervalos[0] := TC_Texto;
  for i := 1 to high(tiposColsIntervalos) - 1 do
    tiposColsIntervalos[i] := TC_TextoEditable;
  tiposColsIntervalos[high(tiposColsIntervalos)] := TC_Texto;
end;

procedure TAltaMonitorHistograma.CBNombre_Y_ClaseChange(Sender: TObject);
var
  i: integer;
  nombre, clase: string;
  aux: TCosaConNombre;
begin
  nombre := self.darNombre(CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]);
  clase := Self.darClase(CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]);
  aux := nil;
  for i := 0 to ListaDeCosasMonitoreables.Count - 1 do
  begin
    aux := TCosaConNombre(ListaDeCosasMonitoreables[i]);
    if (nombre = aux.nombre) and (clase = aux.ClassName) then
      break;
  end;
  CBVariable.Clear;
  CBVariable.Items := claseReferencia.nombresVarsMonitoreables(aux);
  guardado := False;
end;

procedure TAltaMonitorHistograma.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TAltaMonitorHistograma.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TAltaMonitorHistograma.CBVariableChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TAltaMonitorHistograma.CambiosForm(Sender: TObject);
begin
  guardado := False;
end;

procedure TAltaMonitorHistograma.BGuardarClick(Sender: TObject);
var
  evprocs: TDAOfEventoProc;
  intervalos: TDAofNReal;
  i: integer;
begin
  if validarFormulario then
  begin
    SetLength(evprocs, 1);
    evprocs[0].evento := StrToEvento(CBEvento.Items[CBEvento.ItemIndex]);
    evprocs[0].refProc := 1;
    SetLength(intervalos, sgIntervalos.ColCount - 2);
    for i := 0 to sgIntervalos.ColCount - 3 do
      intervalos[i] := StrToFloat(sgIntervalos.cells[i + 1, 1]);
    referencia := TReferenciaMonHistograma.Create(capa, ENMon.Text,
      darNombre(CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]),
      darClase(CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]),
      valorCBString(CBVariable), evprocs, intervalos);
    ModalResult := mrOk;
  end;
end;

procedure TAltaMonitorHistograma.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaMonitorHistograma.EditNombreExit(Sender: TObject);
begin
  validarNombre(ENMon.Text);
end;

procedure TAltaMonitorHistograma.EditTamTablaExit(Sender: TObject);
var
  nAnt, n, i: integer;
begin
  if validarEditInt(Sender as TEdit, 0, MAXINT) then
  begin
    nAnt := sgIntervalos.ColCount;
    n := StrToInt(TEdit(Sender).Text) + 3;
    sgIntervalos.ColCount := n;

    rearmarTiposColsIntervalos;

    for i := nAnt - 1 to n - 2 do
    begin
      sgIntervalos.Cells[i, 0] := 'x' + IntToStr(i);
      sgIntervalos.Cells[i, 1] := FloatToStr(StrToFloat(sgIntervalos.Cells[i - 1, 1]) + 1);
    end;
    sgIntervalos.Cells[n - 1, 0] := 'x' + IntToStr(n - 1);
    sgIntervalos.Cells[n - 1, 1] := 'Inf';

    sgIntervalos.Width := max(self.ClientWidth, n *
      (sgIntervalos.DefaultColWidth + sgIntervalos.GridLineWidth) + 3);
    guardado := False;
  end;
end;

procedure TAltaMonitorHistograma.sgValidarCambio(Sender: TObject);
begin
  inherited sgValidarCambio(Sender);
end;

procedure TAltaMonitorHistograma.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TAltaMonitorHistograma.sgIntervalosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgKeyDown(Sender, Key, Shift);
end;

procedure TAltaMonitorHistograma.FormCreate(Sender: TObject);
var
  i: integer;
begin
  SetLength(tiposColsIntervalos, sgIntervalos.ColCount);
  sgIntervalos.Cells[0, 0] := 'x0';

  rearmarTiposColsIntervalos;
  for i := 1 to sgIntervalos.ColCount - 2 do
    sgIntervalos.Cells[i, 0] := 'x' + IntToStr(i);
  sgIntervalos.Cells[sgIntervalos.ColCount - 1, 0] :=
    'x' + IntToStr(sgIntervalos.ColCount - 1);

  ENIntervalos.Text := IntToStr(sgIntervalos.ColCount - 3);
end;


procedure TAltaMonitorHistograma.sgIntervalosDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  utilidades.ListadoDrawCell(Sender, ACol, ARow, Rect, State,
    tiposColsIntervalos[Acol], nil, iconos);
end;

procedure TAltaMonitorHistograma.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TReferenciaMonHistograma);
end;

end.
