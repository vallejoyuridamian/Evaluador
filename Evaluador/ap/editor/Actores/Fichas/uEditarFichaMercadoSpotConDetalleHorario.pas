unit uEditarFichaMercadoSpotConDetalleHorario;


interface

uses

{$IFDEF WINDOWS}
 Windows,
 {$ELSE}
 LCLType,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, ExtCtrls, Grids, uCosaConNombre, uFichasLPD,
  uSalasDeJuego, uMercadoSpotConDetalleHorarioSemanal, uconstantesSimSEE,
  xMatDefs, utilidades, uimpvnreal, uimpmatnreal,
  uopencalcexportimport,
  uverdoc,
  uFuentesAleatorias,
// uExcelFile,
  uOpcionesSimSEEEdit;

resourcestring
  rsFactorDeDisponibilidadPU = 'Factor de disponibilidad[p.u.]';
  rsDiaDeLaSemana = 'Día de la semana';
  rsHora = 'Hora';
  rsPMin = 'PMín[MW]';
  rsPMax = 'PMáx[MW]';
  rsDeltaCosto = 'Delta costo[USD/MWh]';

type
  TEditarFichaMercadoSpotConDetalleHorario = class(TBaseEditoresFichas)
    LFIni: TLabel;
    sgFichaDetalleHorarioSemanal: TStringGrid;
    BGuardar: TButton;
    BCancelar: TButton;
    EFIni: TEdit;
    CBPeriodicidad: TCheckBox;
    PPeriodicidad: TPanel;
    LFinPeriodo: TLabel;
    LIniPeriodo: TLabel;
    LLargoPeriodo: TLabel;
    EFFinPeriodo: TEdit;
    EFIniPeriodo: TEdit;
    sgPeriodicidad: TStringGrid;
    ELargoPeriodo: TEdit;
    CBLargoPeriodo: TComboBox;
    BAyuda: TButton;
    BImportar_ods: TButton;
    BExportar_ods: TButton;
    sgFicha: TStringGrid;
    LMultPMin: TLabel;
    LMultPMax: TLabel;
    LBornePMin: TLabel;
    LBornePMax: TLabel;
    CBMultPMin: TComboBox;
    CBMultPMax: TComboBox;
    CBBornePMin: TComboBox;
    CBBornePMax: TComboBox;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure BExportar_odsClick(Sender: TObject);
    procedure BImportar_odsClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBMultPMinChange(Sender: TObject);
    procedure CBMultPMaxChange(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaMercadoSpotConDetalleHorario: TEditarFichaMercadoSpotConDetalleHorario;

implementation

uses SimSEEEditMain;
  {$R *.lfm}

procedure TEditarFichaMercadoSpotConDetalleHorario.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TMercadoSpotDetalleHorarioSemanal);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.BExportar_odsClick(
  Sender: TObject);
begin
  exportarTablaAODS_2( sgFichaDetalleHorarioSemanal,
    BImportar_ods, nil);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.BImportar_odsClick(
  Sender: TObject);
begin
  importarTablaDesdeODS_2(sgFichaDetalleHorarioSemanal,
    BImportar_ods, nil, True, True);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.BGuardarClick(Sender: TObject);
var
  i: integer;
  periodicidad: TPeriodicidad;
  Pmins, Pmaxs, multsCosto: TDAOfNReal;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
        EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := nil;

    SetLength(Pmins, 168);
    SetLength(Pmaxs, 168);
    SetLength(multsCosto, 168);

    for i := 0 to High(Pmins) do
    begin
      Pmins[i] := StrToFloat(sgFichaDetalleHorarioSemanal.Cells[2, i + 1]);
      Pmaxs[i] := StrToFloat(sgFichaDetalleHorarioSemanal.Cells[3, i + 1]);
      multsCosto[i] := StrToFloat(sgFichaDetalleHorarioSemanal.Cells[4, i + 1]);
    end;

    ficha := TFichaMercadoSpotDetalleHorarioSemanal.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
      StrToFloat(
      sgFicha.Cells[1, 0]),
      valorCBFuente(CBMultPMin), valorCBFuente(CBMultPMax),
      valorCBString(CBBornePMin),
      valorCBString(CBBornePMax),
      Pmins, Pmaxs, multsCosto);
    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.CBMultPMaxChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBMultPMax, CBBornePMax);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.CBMultPMinChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBMultPMin, CBBornePMin);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.CBPeriodicidadClick(
  Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

constructor TEditarFichaMercadoSpotConDetalleHorario.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
  fichaCast: TFichaMercadoSpotDetalleHorarioSemanal;
  //  multPMin, multPMax: TFuenteAleatoria;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(CBMultPMin, CBBornePMin, True);
  inherited inicializarCBFuente(CBMultPMax, CBBornePMax, True);

  if ficha <> nil then
  begin
    fichaCast := ficha as TFichaMercadoSpotDetalleHorarioSemanal;

    inherited setCBFuente(CBMultPMin, CBBornePMin, fichaCast.multPMin,
      fichaCast.borneMultPmin);
    inherited setCBFuente(CBMultPMax, CBBornePMax, fichaCast.multPMax,
      fichaCast.borneMultPmax);

    EFIni.Text := FSimSEEEdit.fechaIniToString(ficha.fecha);
    sgFicha.Cells[1, 0] := FloatToStrF(fichaCast.fDisp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    for i := 0 to High(fichaCast.Pmins) do
    begin
      sgFichaDetalleHorarioSemanal.Cells[2, i + 1] :=
        FloatToStrF(fichaCast.Pmins[i], ffGeneral, CF_PRECISION, CF_DECIMALES);
      sgFichaDetalleHorarioSemanal.Cells[3, i + 1] :=
        FloatToStrF(fichaCast.Pmaxs[i], ffGeneral, CF_PRECISION, CF_DECIMALES);
      sgFichaDetalleHorarioSemanal.Cells[4, i + 1] :=
        FloatToStrF(fichaCast.deltaCosto[i], ffGeneral, CF_PRECISION, CF_DECIMALES);
    end;
  end;
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.FormCreate(Sender: TObject);
var
  i: integer;
begin
  sgFicha.Cells[0, 0] := rsFactorDeDisponibilidadPU;

  sgFichaDetalleHorarioSemanal.Cells[0, 0] := rsDiaDeLaSemana;
  sgFichaDetalleHorarioSemanal.Cells[1, 0] := rsHora;
  sgFichaDetalleHorarioSemanal.Cells[2, 0] := rsPMin;
  sgFichaDetalleHorarioSemanal.Cells[3, 0] := rsPMax;
  sgFichaDetalleHorarioSemanal.Cells[4, 0] := rsDeltaCosto;

  for i := 1 to sgFichaDetalleHorarioSemanal.RowCount - 1 do
  begin
    sgFichaDetalleHorarioSemanal.Cells[0, i] := LongDayNames[((i - 1) div 24) + 1];
    sgFichaDetalleHorarioSemanal.Cells[1, i] := IntToStr((i - 1) mod 24);
  end;

  for i := 0 to sgFichaDetalleHorarioSemanal.ColCount - 1 do
    utilidades.AutoSizeCol(sgFichaDetalleHorarioSemanal, i);

  utilidades.AutoSizeCol(sgFicha, 0);
  sgFicha.ColWidths[1] := sgFichaDetalleHorarioSemanal.Width - sgFicha.ColWidths[0] - 5;

  BExportar_ods.Left := sgFicha.Left + sgFicha.Width - BExportar_ods.Width -
    BImportar_ods.Width - plusWidth;
  BImportar_ods.Left := sgFicha.Left + sgFicha.Width - BImportar_ods.Width;

  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaMercadoSpotConDetalleHorario.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(TstringGrid(Sender));
end;

function TEditarFichaMercadoSpotConDetalleHorario.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    inherited validarTablaNReals_(sgFicha) and
    inherited validarCBFuente(CBMultPMin, CBBornePMin, 0) and
    inherited validarCBFuente(CBMultPMax, CBBornePMax, 0) and
    inherited validarTablaNReals_(sgFichaDetalleHorarioSemanal);
end;

initialization
end.
