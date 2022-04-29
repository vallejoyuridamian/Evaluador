unit uEditarFichaFuenteSelector;


interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, Grids, ExtCtrls, uCosaConNombre,
  uFuentesAleatorias,
  uFuenteSelector, uFichasLPD, uSalasDeJuego, uverdoc, utilidades, uFechas, xMatDefs;

type

  { TEditarFichaFuenteSelector }

  TEditarFichaFuenteSelector = class(TBaseEditoresFichas)
    CBBorneC:  TComboBox;
    CBBorneD:  TComboBox;
    CBFuenteC: TComboBox;
    CBFuenteD: TComboBox;
    LBorneA1:  TLabel;
    LBorneB1:  TLabel;
    LFIni:     TLabel;
    LFuenteA:  TLabel;
    LFuenteA1: TLabel;
    LFuenteB:  TLabel;
    LBorneA:   TLabel;
    LBorneB:   TLabel;
    BGuardar:  TButton;
    BCancelar: TButton;
    EFIni:     TEdit;
    CBPeriodicidad: TCheckBox;
    LFuenteB1: TLabel;
    PPeriodicidad: TPanel;
    LFinPeriodo: TLabel;
    LIniPeriodo: TLabel;
    LLargoPeriodo: TLabel;
    EFFinPeriodo: TEdit;
    EFIniPeriodo: TEdit;
    sgPeriodicidad: TStringGrid;
    ELargoPeriodo: TEdit;
    CBLargoPeriodo: TComboBox;
    BAyuda:    TButton;
    CBFuenteA: TComboBox;
    CBFuenteB: TComboBox;
    CBBorneA:  TComboBox;
    CBBorneB:  TComboBox;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CBLargoPeriodoChange(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure CBFuenteAChange(Sender: TObject);
    procedure CBFuenteBChange(Sender: TObject);
    procedure CBFuenteCChange(Sender: TObject);
    procedure CBFuenteDChange(Sender: TObject);

    procedure CambiosForm(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
  private
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

  {$R *.lfm}

constructor TEditarFichaFuenteSelector.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  for i := 0 to sala.listaFuentes_.Count - 1 do
  begin
    CBFuenteA.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
    CBFuenteB.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
    CBFuenteC.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
    CBFuenteD.Items.Add(TFuenteAleatoria(sala.listaFuentes_[i]).nombre);
  end;

  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;

    inherited setCBFuente(CBFuenteA, CBBorneA, TFichaFuenteSelector(ficha).fuenteA,
      TFichaFuenteSelector(ficha).borneA);
    inherited setCBFuente(CBFuenteB, CBBorneB, TFichaFuenteSelector(ficha).fuenteB,
      TFichaFuenteSelector(ficha).borneB);
    inherited setCBFuente(CBFuenteC, CBBorneC, TFichaFuenteSelector(ficha).fuenteC,
      TFichaFuenteSelector(ficha).borneC);
    inherited setCBFuente(CBFuenteD, CBBorneD, TFichaFuenteSelector(ficha).fuenteD,
      TFichaFuenteSelector(ficha).borneD);
  end;
end;

function TEditarFichaFuenteSelector.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    inherited validarCBFuente(CBFuenteA, CBBorneA, 0) and
    inherited validarCBFuente(CBFuenteB, CBBorneB, 0) and
    inherited validarCBFuente(CBFuenteC, CBBorneC, 0) and
    inherited validarCBFuente(CBFuenteD, CBBorneD, 0);
end;

procedure TEditarFichaFuenteSelector.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteSelector);
end;

procedure TEditarFichaFuenteSelector.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteSelector.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := nil;
    ficha := TFichaFuenteSelector.Create(
      capa,
      TFecha.Create_Str(EFIni.Text), periodicidad,
      valorCBFuente(CBFuenteA), valorCBFuente(CBFuenteB),
      valorCBFuente(CBFuenteC), valorCBFuente(CBFuenteD),
      valorCBString(CBBorneA), valorCBString(CBBorneB),
      valorCBString(CBBorneC), valorCBString(CBBorneD));
    modalResult := mrOk;
  end;
end;

procedure TEditarFichaFuenteSelector.CambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaFuenteSelector.CBFuenteAChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteA, CBBorneA);
end;

procedure TEditarFichaFuenteSelector.CBFuenteBChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteB, CBBorneB);
end;


procedure TEditarFichaFuenteSelector.CBFuenteCChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteC, CBBorneC);
end;

procedure TEditarFichaFuenteSelector.CBFuenteDChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteD, CBBorneD);
end;

procedure TEditarFichaFuenteSelector.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaFuenteSelector.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteSelector.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteSelector.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteSelector.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteSelector.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteSelector.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteSelector.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaFuenteSelector.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(sgPeriodicidad);
end;

end.

