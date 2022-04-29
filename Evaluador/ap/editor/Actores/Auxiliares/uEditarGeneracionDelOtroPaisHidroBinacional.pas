unit uEditarGeneracionDelOtroPaisHidroBinacional;

  {$MODE Delphi}

interface

uses
   {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, uBaseFormularios,
  uopencalcexportimport,
  xMatDefs, uconstantesSimSEE, utilidades;

resourcestring
  rsDiaDeLaSemana = 'Día de la semana';
  rsHora = 'Hora';
  rsPotencia = 'Potencia[MW]';

type
  TEditarGeneracionDelOtroPaisHidroBinacional = class(TBaseFormularios)
    sgFichaDetalleHorarioSemanal: TStringGrid;
    BGuardar: TButton;
    BCancelar: TButton;
    BImportar_ods: TButton;
    BExportar_ods: TButton;
    procedure BImportar_odsClick(Sender: TObject);
    procedure BExportar_odsClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
  private
  protected
    generacion: TDAofNReal;

    procedure validarCambioTabla(tabla: TStringGrid); override;
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; generacion: TDAOfNReal); reintroduce;
    function getGeneracion: TDAofNReal;
  end;

implementation

  {$R *.lfm}

constructor TEditarGeneracionDelOtroPaisHidroBinacional.Create(AOwner: TComponent;
  generacion: TDAOfNReal);
var
  i: integer;
begin
  inherited Create(AOwner);

  sgFichaDetalleHorarioSemanal.Cells[0, 0] := rsDiaDeLaSemana;
  sgFichaDetalleHorarioSemanal.Cells[1, 0] := rsHora;
  sgFichaDetalleHorarioSemanal.Cells[2, 0] := rsPotencia;
  for i := 1 to sgFichaDetalleHorarioSemanal.RowCount - 1 do
  begin
    sgFichaDetalleHorarioSemanal.Cells[0, i] := LongDayNames[((i - 1) div 24) + 1];
    sgFichaDetalleHorarioSemanal.Cells[1, i] := IntToStr((i - 1) mod 24);
  end;

  if generacion <> nil then
  begin
    for i := 0 to high(generacion) do
      sgFichaDetalleHorarioSemanal.Cells[2, i + 1] :=
        FloatToStrF(generacion[i], ffGeneral, CF_PRECISION, CF_DECIMALES);
  end;
end;

function TEditarGeneracionDelOtroPaisHidroBinacional.getGeneracion: TDAofNReal;
begin
  if ModalResult = mrOk then
    Result := generacion
  else
    raise Exception.Create(
      'TEditarGeneracionDelOtroPaisHidroBinacional.getGeneracion: modalResult <> mrOk');
end;

procedure TEditarGeneracionDelOtroPaisHidroBinacional.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarGeneracionDelOtroPaisHidroBinacional.validarCambioTabla(
  tabla: TStringGrid);
begin
  inherited validarCambioTablaNReals(sgFichaDetalleHorarioSemanal);
end;

function TEditarGeneracionDelOtroPaisHidroBinacional.validarFormulario: boolean;
begin
  Result := inherited validarTablaNReals_(sgFichaDetalleHorarioSemanal);
end;

procedure TEditarGeneracionDelOtroPaisHidroBinacional.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarGeneracionDelOtroPaisHidroBinacional.BExportar_odsClick(
  Sender: TObject);
begin
  exportarTablaAODS_2( sgFichaDetalleHorarioSemanal,
    BImportar_ods, nil);
end;

procedure TEditarGeneracionDelOtroPaisHidroBinacional.BGuardarClick(Sender: TObject);
var
  i: integer;
begin
  if validarFormulario then
  begin
    SetLength(generacion, sgFichaDetalleHorarioSemanal.RowCount - 1);
    for i := 0 to sgFichaDetalleHorarioSemanal.RowCount - 2 do
      generacion[i] := StrToFloat(sgFichaDetalleHorarioSemanal.Cells[2, i + 1]);

    ModalResult := mrOk;
  end;
end;

procedure TEditarGeneracionDelOtroPaisHidroBinacional.BImportar_odsClick(
  Sender: TObject);
begin
  importarTablaDesdeODS_2( sgFichaDetalleHorarioSemanal,
    BImportar_ods, nil, True, True);
end;

initialization
end.
