unit uEditarFichaFuenteWeibull;


interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids,
  uFuenteWeibull, uBaseEditoresFichas,
  ucosaConNombre, uFichasLPD, uSalasdeJuego, uconstantesSimSEE, utilidades,
  uFechas, uverdoc, uOpcionesSimSEEEdit, xMatDefs;

resourcestring
  mesValorEsperadoFuenteWeibull =
    'El valor esperado de una fuente de Weibull debe ser distinto de 0';
  rsValorEsperado = 'Valor esperado';
  rsConstanteK = 'Constante K';

type
  TEditarFichaFuenteWeibull = class(TBaseEditoresFichas)
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
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CBLargoPeriodoChange(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarTablaNRealsWeibull(tabla: TStringGrid): boolean;
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses uBaseAltasEditores;

  {$R *.lfm}

constructor TEditarFichaFuenteWeibull.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;
    sgFicha.Cells[1, 0] := FloatToStrF(TFichaFuenteWeibull(ficha).valorEsperado,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 1] := FloatToStrF(TFichaFuenteWeibull(ficha).constanteK,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
  end;
end;

function TEditarFichaFuenteWeibull.validarTablaNRealsWeibull(tabla: TStringGrid)
: boolean;
var
  valor: NReal;
begin
  try
    begin
      valor := StrToFloat(tabla.cells[1, 0]);
      if valor = 0 then
      begin
        ShowMessage(mesValorEsperadoFuenteWeibull);
        Result := False;
      end
      else
      begin
        StrToFloat(tabla.cells[1, 1]);
        Result := True;
      end;
    end
  except
    on EConvertError do
    begin
      ShowMessage(mesValoresEnTablaNumericos);
      Result := False;
    end
  end;
end;

function TEditarFichaFuenteWeibull.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited
    validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo,
    sgPeriodicidad) and validarTablaNRealsWeibull(sgFicha);
end;

procedure TEditarFichaFuenteWeibull.FormCreate(Sender: TObject);
begin
  sgFicha.Cells[0, 0] := rsValorEsperado;
  sgFicha.Cells[0, 1] := rsConstanteK;
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteWeibull.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteWeibull.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteWeibull.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteWeibull.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteWeibull.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaFuenteWeibull.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(sgPeriodicidad);
end;

procedure TEditarFichaFuenteWeibull.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteWeibull.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;


procedure TEditarFichaFuenteWeibull.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteWeibull.BGuardarClick(Sender: TObject);
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
    ficha := TFichaFuenteWeibull.Create(capa, TFecha.Create_Str(EFIni.Text),
      periodicidad, StrToFloat(sgFicha.Cells[1, 0]), StrToFloat(sgFicha.Cells[1, 1]));
    modalResult := mrOk;
  end;
end;

procedure TEditarFichaFuenteWeibull.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteWeibull);
end;

end.
