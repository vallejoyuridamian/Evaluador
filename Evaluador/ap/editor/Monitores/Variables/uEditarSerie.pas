unit uEditarSerie;
  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uCosaConNombre, uBaseAltasMonitores, uVarDefs, uBaseAltasEditores,
  uReferenciaMonitor,
  uBaseEditoresVariables, uReferenciaMonitorGraficoSimple;

resourcestring
  mesSeleccionarVariableMonitorear = 'Debe seleccionar una variable para monitorear';
  mesSeleccionarActorMonitorear = 'Debe seleccionar un actor para monitorear';
  mesIngresarNombreSerie = 'Debe ingresar un nombre para la serie';

type
  TEditarSerie = class(TBaseEditoresVariables)
    LNombre_Y_Clase: TLabel;
    LNVar: TLabel;
    CBNombre_Y_Clase: TComboBox;
    CBVariable: TComboBox;
    LNSerieY: TLabel;
    LCSY: TLabel;
    BColor: TButton;
    ENSerie: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    ColorDialog1: TColorDialog;
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure CambiosForm(Sender: TObject);
    procedure BColorClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBNombre_Y_ClaseChange(Sender: TObject);
    procedure CBVariableChange(Sender: TObject);
  private
    colorElegido: boolean;
    serie: TReferenciaSerie;

  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TBaseAltasMonitores;
      ListaDeCosas: TListaDeCosasConNombre; ClasesCosas: TStrings;
      serie: TReferenciaSerie); reintroduce;
    function darSerie: TReferenciaSerie;
  end;

var
  EditarSerie: TEditarSerie;

implementation
  {$R *.lfm}

constructor TEditarSerie.Create(AOwner: TBaseAltasMonitores;
  ListaDeCosas: TListaDeCosasConNombre; ClasesCosas: TStrings;
  serie: TReferenciaSerie);
begin
  inherited Create(AOwner, ListaDeCosas, ClasesCosas, serie);
  CBNombre_Y_Clase.Items := ClasesCosas;
  if serie <> nil then
  begin
    ENSerie.Text := serie.nombreSerie;
    inherited setCBActorYVariable(CBNombre_Y_Clase, CBVariable, serie);
    LCSY.Font.Color := serie.color;
    ColorDialog1.Color := serie.color;
  end;
  guardado := True;
end;

function TEditarSerie.darSerie: TReferenciaSerie;
begin
  Result := serie;
end;

function TEditarSerie.validarFormulario: boolean;
begin
  if ENSerie.Text <> '' then
  begin
    if CBNombre_Y_Clase.ItemIndex <> -1 then
    begin
      if CBVariable.ItemIndex <> -1 then
      begin
        Result := True;
      end
      else
      begin
        ShowMessage(mesSeleccionarVariableMonitorear);
        Result := False;
      end;
    end
    else
    begin
      ShowMessage(mesSeleccionarActorMonitorear);
      Result := False;
    end;
  end
  else
  begin
    ShowMessage(mesIngresarNombreSerie);
    Result := False;
  end;
end;

procedure TEditarSerie.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarSerie.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarSerie.CambiosForm(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarSerie.BColorClick(Sender: TObject);
begin
  if ColorDialog1.Execute then
  begin
    LCSY.Font.Color := ColorDialog1.Color;
    colorElegido := True;
  end;
end;

procedure TEditarSerie.BGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
{$IFDEF ARBOL}
    serie := TReferenciaSerie.Create(capa, ENSerie.Text,
      TBaseAltasMonitores(Owner).darNombre(
      CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]),
      TBaseAltasMonitores(Owner).darClase(
      CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]),
      CBVariable.Items[CBVariable.ItemIndex], ColorDialog1.Color);
{$ENDIF}
    ModalResult := mrOk;
  end;
end;

procedure TEditarSerie.CBNombre_Y_ClaseChange(Sender: TObject);
begin
  inherited CambioCBActor(CBNombre_Y_Clase, CBVariable);
end;

procedure TEditarSerie.CBVariableChange(Sender: TObject);
begin
  CambiosForm(Sender);
  if ENSerie.Text = '' then
    ENSerie.Text := CBVariable.Text;
end;

end.