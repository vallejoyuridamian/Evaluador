unit uAltaMonitorConsola;
  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uCosaConNombre, uVarDefs, utilidades, uBaseAltasMonitores,
  xMatDefs, uMonitores,
  uReferenciaMonitor, uReferenciaMonitorConsola,
  uSalasDeJuego, uManejadoresDeMonitores, uEventosOptSim, uverdoc;

resourcestring
  rsEditarMonitorConsola = 'Editar Monitor de Consola';
  rsGuardarMonitor = 'Guardar Monitor';

type
  TAltaMonitorConsola = class(TBaseAltasMonitores)
    CBNombre_Y_Clase: TComboBox;
    CBVariable: TComboBox;
    BAgregarMonitor: TButton;
    BCancelar: TButton;
    LNombre_Y_Clase: TLabel;
    LNVar: TLabel;
    CBEvento: TComboBox;
    LEvento: TLabel;
    LNMon: TLabel;
    ENMon: TEdit;
    BAyuda: TButton;
    procedure CBNombre_Y_ClaseChange(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure CBVariableChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure ENMonEnter(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarFormulario(): boolean; override;
  private
  public
    constructor Create(AOwner: TForm; monitor: TReferenciaMonitor;
      sala: TSalaDeJuego; manejador: TManejadoresDeMonitores; alta: boolean;
      tipoReferencia: TClaseReferenciaMonitor); override;

    procedure Free;
  end;

var
  AltaMonitor: TAltaMonitorConsola;

implementation
  {$R *.lfm}

constructor TAltaMonitorConsola.Create(AOwner: TForm; monitor: TReferenciaMonitor;
  sala: TSalaDeJuego; manejador: TManejadoresDeMonitores; alta: boolean;
  tipoReferencia: TClaseReferenciaMonitor);
var
  i: integer;
  aux: TCosaConNombre;
  claseNombre: string;
begin
  inherited Create(AOwner, monitor, sala, manejador, alta, tipoReferencia);
  for i := 0 to ListaDeCosasMonitoreables.Count - 1 do
  begin
    aux := TCosaConNombre(ListaDeCosasMonitoreables[i]);
    CBNombre_Y_Clase.Items.Add(aux.ClassName + ', ' + aux.nombre);
  end;
  CBEvento.Items := uEventosOptSim.nombresEventos;
  if monitor <> nil then
  begin
    self.Caption := rsEditarMonitorConsola;
    BAgregarMonitor.Caption := rsGuardarMonitor;
    ENMon.Text := monitor.nombre;
    claseNombre := TReferenciaMonConsola(monitor).defvar.claseCosa +
      ', ' + TReferenciaMonConsola(monitor).defvar.nombreCosa;
    CBNombre_Y_Clase.ItemIndex := CBNombre_Y_Clase.Items.IndexOf(claseNombre);
    CBNombre_Y_ClaseChange(CBNombre_Y_Clase);
    CBVariable.ItemIndex := CBVariable.Items.IndexOf(
      TReferenciaMonConsola(monitor).defvar.nombreVar);
    CBEvento.ItemIndex := CBEvento.Items.IndexOf(
      uEventosOptSim.EventoToStr(monitor.eventos[0].evento));
  end;
  guardado := True;
end;

procedure TAltaMonitorConsola.Free;
begin
  inherited Free;
end;

function TAltaMonitorConsola.validarFormulario(): boolean;
begin
  Result := inherited validarNombre(ENMon.Text) and
    inherited validarCBActor(CBNombre_Y_Clase) and
    inherited validarCBVariable(CBVariable) and
    inherited validarCBEvento(CBEvento, LEvento);
end;

procedure TAltaMonitorConsola.CBNombre_Y_ClaseChange(Sender: TObject);
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

  CBVariable.Items.Clear;
  CBVariable.Items := claseReferencia.nombresVarsMonitoreables(aux);
  guardado := False;
end;

procedure TAltaMonitorConsola.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TAltaMonitorConsola.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TAltaMonitorConsola.CBVariableChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TAltaMonitorConsola.CambiosForm(Sender: TObject);
begin
  guardado := False;
end;

procedure TAltaMonitorConsola.BGuardarClick(Sender: TObject);
var
  evprocs: TDAOfEventoProc;
begin
  if validarFormulario then
  begin
    SetLength(evprocs, 1);
    evprocs[0].evento := StrToEvento(CBEvento.Items[CBEvento.ItemIndex]);
    evprocs[0].refProc := 1;
    referencia := TReferenciaMonConsola.Create(capa, ENMon.Text,
      darNombre(CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]),
      darClase(CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]),
      valorCBString(CBVariable), evprocs);
    ModalResult := mrOk;
  end;
end;

procedure TAltaMonitorConsola.ENMonEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaMonitorConsola.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TReferenciaMonConsola);
end;

end.