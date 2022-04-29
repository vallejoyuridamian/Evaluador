unit uBaseAltasMonitores;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, uCosaConNombre,
  uBaseAltasEditores, xMatDefs, uReferenciaMonitor, utilidades,
  uManejadoresDeMonitores, uSalasDeJuego, uInfoTabs, uCosa, StdCtrls, ExtCtrls;

resourcestring
  mesYaExisteUnMonitor = 'Ya existe un monitor con el nombre ingresado';
  mesNombreNoSerVacio = 'El campo nombre no puede ser vacio';
  mesSeleccionarVariableMonitorear = 'Debe seleccionar una variable para monitorear';
  mesSeleccionarEventoCampo = 'Debe seleccionar un evento para el campo ';
  mesSeleccionarActorVariableMonitorear =
    'Debe seleccionar un actor y una variable para monitorear';

type

  { TBaseAltasMonitores }

  TBaseAltasMonitores = class(TBaseAltasEditores)
  published
  protected
    referencia: TReferenciaMonitor;
    ListaDeCosasMonitoreables: TListaDeCosasConNombre;
    function validarNombre(nombreMon: string): boolean;
    function validarListaVarDefs(listaVarDefs: TListaDeCosas): boolean;
    function validarCBEvento(cb: TComboBox; etiqueta: TLabel): boolean;
    function validarCBActor(cb: TComboBox): boolean;
    function validarCBVariable(cb: TComboBox): boolean;
  private
    alta: boolean;
    monitorOrig: TReferenciaMonitor;
    manejador: TManejadoresDeMonitores;
  public
    claseReferencia: TClaseReferenciaMonitor;

    constructor Create(AOwner: TForm; monitor: TReferenciaMonitor;
      sala: TSalaDeJuego; manejador: TManejadoresDeMonitores;
      alta: boolean; tipoReferencia: TClaseReferenciaMonitor); reintroduce; virtual;

    function darNombre(cadena: string): string; virtual;
    function darClase(cadena: string): string; virtual;

    property darReferenciaMonitor: TReferenciaMonitor read referencia;
  end;

  TClaseEditoresMonitores = class of TBaseAltasMonitores;

implementation

uses
  SimSEEEditMain;

  {$R *.lfm}
constructor TBaseAltasMonitores.Create(AOwner: TForm; monitor: TReferenciaMonitor;
  sala: TSalaDeJuego; manejador: TManejadoresDeMonitores; alta: boolean;
  tipoReferencia: TClaseReferenciaMonitor);
begin
  inherited Create(AOwner, monitor, sala );
  self.SaladeJuego := sala;
  self.manejador := manejador;
  self.alta := alta;
  monitorOrig := monitor;
  self.Top := TForm(Owner).Top + utilidades.plusTop;
  self.Left := TForm(OWner).Left + utilidades.plusLeft;
  if monitor <> nil then
    ListaDeCosasMonitoreables := monitor.cosasMonitoreables(manejador.cosasMonitoreables)
  else
    ListaDeCosasMonitoreables :=
      tipoReferencia.cosasMonitoreablesDeClase(manejador.cosasMonitoreables);
  ListaDeCosasMonitoreables.Sort(uInfoTabs.compareTipos);
  claseReferencia := tipoReferencia;
  guardado := True;
  referencia := nil;
end;

function TBaseAltasMonitores.darNombre(cadena: string): string;
var
  ipos: integer;
begin
  ipos := pos(',', cadena) + 2;//El +2 es uno por la coma y otro por el espacio
  Result := copy(cadena, ipos, MAXINT);
end;

function TBaseAltasMonitores.darClase(cadena: string): string;
var
  ipos: integer;
begin
  ipos := pos(',', cadena) - 1;
  Result := copy(cadena, 0, ipos);
end;

function TBaseAltasMonitores.validarNombre(nombreMon: string): boolean;
var
  i: integer;
  encontre: boolean;
begin
  if (nombreMon <> loQueHabia) then
  begin
    if (nombreMon <> '') then
    begin
      if not alta then
      begin
        encontre := False;
        for i := 0 to manejador.referenciasMonitores.Count - 1 do
          if (TCosaConNombre(manejador.referenciasMonitores[i]).nombre = nombreMon) and
            (TCosaConNombre(manejador.referenciasMonitores[i]) <> monitorOrig) then
          begin
            encontre := True;
            ShowMessage(mesYaExisteUnMonitor);
            break;
          end;
        if not encontre then
        begin
          Result := True;
          guardado := False;
        end
        else
          Result := False;
      end
      else
      begin
        Result := True;
        guardado := False;
      end;
    end
    else
    begin
      ShowMessage(mesNombreNoSerVacio);
      Result := False;
    end;
  end
  else
    Result := True;
end;

function TBaseAltasMonitores.validarListaVarDefs(listaVarDefs: TListaDeCosas): boolean;
begin
  if listaVarDefs.Count > 0 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarVariableMonitorear);
    Result := False;
  end;
end;

function TBaseAltasMonitores.validarCBEvento(cb: TComboBox; etiqueta: TLabel): boolean;
begin
  if cb.ItemIndex <> -1 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarEventoCampo + etiqueta.Caption);
    Result := False;
  end;
end;

function TBaseAltasMonitores.validarCBActor(cb: TComboBox): boolean;
begin
  if cb.ItemIndex <> -1 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarActorVariableMonitorear);
    Result := False;
  end;
end;

function TBaseAltasMonitores.validarCBVariable(cb: TComboBox): boolean;
begin
  if cb.ItemIndex <> -1 then
    Result := True
  else
  begin
    ShowMessage(mesSeleccionarVariableMonitorear);
    Result := False;
  end;
end;

end.
