unit uEditarFichaMercadoSpot;


interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, xMatDefs, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, ExtCtrls, Grids, uMercadoSpot, uFichasLPD,
  uFechas, uCosaConNombre,
  usalasdejuego,
  uSalasDeJuegoParaEditor, uconstantesSimSEE, utilidades, uverdoc, uOpcionesSimSEEEdit;

resourcestring
  rsPMinNegativo = 'PMín[MW](Negativo):';
  rsPMaxP = 'PMáx[MW]:';
  rsFactorDeDisponibilidadPU = 'Factor de disponibilidad[p.u.]';

type
  TEditarFichaMercadoSpot = class(TBaseEditoresFichas)
    LFIni: TLabel;
    sgFicha: TStringGrid;
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
    procedure sgChequearCambios(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

procedure TEditarFichaMercadoSpot.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

constructor TEditarFichaMercadoSpot.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if ficha <> nil then
  begin
    EFIni.Text := FSimSEEEdit.fechaIniToString(ficha.fecha);
    sgFicha.Cells[1, 0] := FloatToStrF(TFichaMercadoSpot(ficha).Pmin,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 1] := FloatToStrF(TFichaMercadoSpot(ficha).Pmax,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 2] := FloatToStrF(TFichaMercadoSpot(ficha).fdisp,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
  end;
end;

function TEditarFichaMercadoSpot.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    inherited validarTablaNReals_(sgFicha);
end;

procedure TEditarFichaMercadoSpot.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaMercadoSpot.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaMercadoSpot.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(TstringGrid(Sender));
end;

procedure TEditarFichaMercadoSpot.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
        EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := nil;
    ficha := TFichaMercadoSpot.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad, StrToFloat(sgFicha.Cells[1, 0]),
      StrToFloat(sgFicha.Cells[1, 1]), StrToFloat(
      sgFicha.Cells[1, 2]));
    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaMercadoSpot.FormCreate(Sender: TObject);
begin
  sgFicha.Cells[0, 0] := rsPMinNegativo;
  sgFicha.Cells[0, 1] := rsPMaxP;
  sgFicha.Cells[0, 2] := rsFactorDeDisponibilidadPU;
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaMercadoSpot.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TMercadoSpot);
end;

end.
