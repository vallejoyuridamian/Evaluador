unit uEditarFichaFuenteGaussiana;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, uBaseEditoresFichas, uCosaConNombre, uFichasLPD,
  uFuenteGaussiana,
  uconstantesSimSEE, utilidades, uFechas,
  usalasdejuego,
  uSalasDeJuegoParaEditor, uverdoc, uOpcionesSimSEEEdit, xMatDefs;

resourcestring
  rsValorEsperado = 'Valor esperado';
  rsVarianza = 'Varianza';

type

  { TEditarFichaFuenteGaussiana }

  TEditarFichaFuenteGaussiana = class(TBaseEditoresFichas)
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
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure sgChequearCambios(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure CBLargoPeriodoChange(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation
{$R *.lfm}

constructor TEditarFichaFuenteGaussiana.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;
    sgFicha.Cells[1, 0] := FloatToStrF(TFichaFuenteGaussiana(ficha).valorEsperado,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 1] := FloatToStrF(TFichaFuenteGaussiana(ficha).varianza,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
  end;
end;

function TEditarFichaFuenteGaussiana.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    inherited validarTablaNReals_(sgFicha);
end;

procedure TEditarFichaFuenteGaussiana.FormCreate(Sender: TObject);
begin
  sgFicha.Cells[0, 0] := rsValorEsperado;
  sgFicha.Cells[0, 1] := rsVarianza;
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteGaussiana.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteGaussiana.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteGaussiana.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteGaussiana.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteGaussiana.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteGaussiana.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteGaussiana.BGuardarClick(Sender: TObject);
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
    ficha := TFichaFuenteGaussiana.Create(capa, TFecha.Create_Str(EFIni.Text),
      periodicidad, StrToFloat(sgFicha.Cells[1, 0]), StrToFloat(sgFicha.Cells[1, 1]));
    modalResult := mrOk;
  end;
end;

procedure TEditarFichaFuenteGaussiana.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(sgPeriodicidad);
end;

procedure TEditarFichaFuenteGaussiana.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaFuenteGaussiana.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado := False;
end;


procedure TEditarFichaFuenteGaussiana.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteGaussiana);
end;

end.
