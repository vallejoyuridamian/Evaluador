unit uEditarFichaFuenteProducto;

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
  uFuenteProducto, uFichasLPD, uSalasDeJuego, uverdoc, utilidades, uFechas, xMatDefs;

type
  TEditarFichaFuenteProducto = class(TBaseEditoresFichas)
    LFIni: TLabel;
    LFuenteA: TLabel;
    LFuenteB: TLabel;
    LBorneA: TLabel;
    LBorneB: TLabel;
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
    CBBorneA: TComboBox;
    CBBorneB: TComboBox;
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

constructor TEditarFichaFuenteProducto.Create(AOwner: TComponent;
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
  end;

  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;

    inherited setCBFuente(CBFuenteA, CBBorneA, TFichaFuenteProducto(ficha).fuenteA,
      TFichaFuenteProducto(ficha).borneA);
    inherited setCBFuente(CBFuenteB, CBBorneB, TFichaFuenteProducto(ficha).fuenteB,
      TFichaFuenteProducto(ficha).borneB);
  end;
end;

function TEditarFichaFuenteProducto.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    inherited validarCBFuente(CBFuenteA, CBBorneA, 0) and
    inherited validarCBFuente(CBFuenteB, CBBorneB, 0);
end;

procedure TEditarFichaFuenteProducto.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteProducto);
end;

procedure TEditarFichaFuenteProducto.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteProducto.BGuardarClick(Sender: TObject);
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
    ficha := TFichaFuenteProducto.Create(capa, TFecha.Create_Str(EFIni.Text),
      periodicidad, valorCBFuente(CBFuenteA),
      valorCBFuente(CBFuenteB), valorCBString(
      CBBorneA), valorCBString(CBBorneB));
    modalResult := mrOk;
  end;
end;

procedure TEditarFichaFuenteProducto.CambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaFuenteProducto.CBFuenteAChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteA, CBBorneA);
end;

procedure TEditarFichaFuenteProducto.CBFuenteBChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteB, CBBorneB);
end;

procedure TEditarFichaFuenteProducto.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaFuenteProducto.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteProducto.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteProducto.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteProducto.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteProducto.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteProducto.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteProducto.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaFuenteProducto.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(sgPeriodicidad);
end;

end.
