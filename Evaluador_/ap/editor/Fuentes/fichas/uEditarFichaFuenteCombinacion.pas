unit uEditarFichaFuenteCombinacion;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, uBaseEditoresFichas, uCosaConNombre, uFichasLPD,
  uSalasDeJuego, uFuenteCombinacion, uConstantesSimSEE, uFuentesAleatorias,
  utilidades, uVerdoc, uFechas, uOpcionesSimSEEEdit;

type
  TEditarFichaFuenteCombinacion = class(TBaseEditoresFichas)
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
    CBFuenteA: TComboBox;
    CBFuenteB: TComboBox;
    LFuenteA: TLabel;
    LFuenteB: TLabel;
    LBorneA: TLabel;
    LBorneB: TLabel;
    CBBorneA: TComboBox;
    CBBorneB: TComboBox;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure EditIntExit(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure CBFuenteAChange(Sender: TObject);
    procedure CBFuenteBChange(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBLargoPeriodoChange(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure CBBorneBChange(Sender: TObject);
  private
  protected
    function validarSgFichas: boolean;

    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

  {$R *.lfm}

procedure TEditarFichaFuenteCombinacion.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteCombinacion);
end;

procedure TEditarFichaFuenteCombinacion.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteCombinacion.BGuardarClick(Sender: TObject);
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
    ficha := TFichaFuenteCombinacion.Create(capa, TFecha.Create_Str(EFIni.Text),
      periodicidad, StrToFloat(sgFicha.Cells[1, 0]),
      StrToFloat(sgFicha.Cells[1, 1]),
      valorCBFuente(CBFuenteA),
      valorCBFuente(CBFuenteB), valorCBString(
      CBBorneA), valorCBString(CBBorneB));
    modalResult := mrOk;
  end;
end;

procedure TEditarFichaFuenteCombinacion.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaFuenteCombinacion.CBBorneBChange(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaFuenteCombinacion.CBFuenteAChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteA, CBBorneA);
end;

procedure TEditarFichaFuenteCombinacion.CBFuenteBChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteB, CBBorneB);
end;

procedure TEditarFichaFuenteCombinacion.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaFuenteCombinacion.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

constructor TEditarFichaFuenteCombinacion.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  inicializarCBFuente(CBFuenteA, CBBorneA, False);
  inicializarCBFuente(CBFuenteB, CBBorneB, False);

  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;
    sgFicha.Cells[1, 0] := FloatToStrF(TFichaFuenteCombinacion(ficha).a,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 1] := FloatToStrF(TFichaFuenteCombinacion(ficha).b,
      ffGeneral, CF_PRECISION, CF_DECIMALES);

    inherited setCBFuente(CBFuenteA, CBBorneA, TFichaFuenteCombinacion(ficha).fuenteA,
      TFichaFuenteCombinacion(ficha).borneA);
    inherited setCBFuente(CBFuenteB, CBBorneB, TFichaFuenteCombinacion(ficha).fuenteB,
      TFichaFuenteCombinacion(ficha).borneB);
  end;
end;

procedure TEditarFichaFuenteCombinacion.EditIntExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, MAXINT);
end;

procedure TEditarFichaFuenteCombinacion.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteCombinacion.FormCreate(Sender: TObject);
begin
  sgFicha.Cells[0, 0] := 'a';
  sgFicha.Cells[0, 1] := 'b';
  utilidades.AgregarFormatoFecha(LFIni);
end;


procedure TEditarFichaFuenteCombinacion.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

function TEditarFichaFuenteCombinacion.validarSgFichas: boolean;
begin
  Result := inherited validarTablaNReals_(sgFicha);
end;

function TEditarFichaFuenteCombinacion.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    validarSgFichas and inherited validarCBFuente(
    CBFuenteA, CBBorneA, 0) and inherited validarCBFuente(CBFuenteB, CBBorneB, 0);
end;

end.
