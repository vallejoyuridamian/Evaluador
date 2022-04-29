unit uEditarFichaFuenteConstante;


interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, uBaseEditoresFichas, uCosaConNombre, uFichasLPD,
  uFuenteConstante,
  uconstantesSimSEE, utilidades, uFechas,
  usalasdejuego,
  uSalasDeJuegoParaEditor, uverdoc, uOpcionesSimSEEEdit, xMatDefs;

type

  { TEditarFichaFuenteConstante }

  TEditarFichaFuenteConstante = class(TBaseEditoresFichas)
    eValor: TEdit;
    Label1: TLabel;
    LFIni: TLabel;
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
    procedure BAyudaClick(Sender: TObject);
    procedure CBLargoPeriodoChange(Sender: TObject);
  private
    { Private declarations }
  protected
    function validarSgFichas: boolean;

    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation
{$R *.lfm}

constructor TEditarFichaFuenteConstante.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;
    eValor.Text:= FloatToStrF(TFichaFuenteConstante(ficha).valor,
      ffGeneral, CF_PRECISION, CF_DECIMALES);
  end;
end;

function TEditarFichaFuenteConstante.validarSgFichas: boolean;
begin
  Result := validarEditFloat( eValor ) ;
end;

function TEditarFichaFuenteConstante.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
     and validarEditFloat( eValor );

end;

procedure TEditarFichaFuenteConstante.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteConstante.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteConstante.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarFichaFuenteConstante.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteConstante.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteConstante.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteConstante.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteConstante.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteConstante.BGuardarClick(Sender: TObject);
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
    ficha := TFichaFuenteConstante.Create(capa, TFecha.Create_Str(EFIni.Text),
      periodicidad, StrToFloat( eValor.text ));
    modalResult := mrOk;
  end;
end;

procedure TEditarFichaFuenteConstante.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaFuenteConstante.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;


procedure TEditarFichaFuenteConstante.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteConstante);
end;

end.