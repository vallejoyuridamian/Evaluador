unit ueditarfichafuentetiempo;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
//  Windows,
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, Grids, ExtCtrls, EditBtn,
  uCosaConNombre, uFuentesAleatorias, ufuentetiempo, uFichasLPD, uSalasDeJuego,
  uverdoc, utilidades, uFechas, xMatDefs;

type

  { TEditarFichaFuenteTiempo }

  TEditarFichaFuenteTiempo = class(TBaseEditoresFichas)
    FechaInicialDinamica: TDateEdit;
    LFIni: TLabel;
    LFechaInicialDinamica: TLabel;
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
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CBLargoPeriodoChange(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: Integer;
    var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure CambiosForm(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
  private
  protected
    function validarFormulario : boolean; override;
  public
    Constructor Create(AOwner : TComponent; cosaConNombre : TCosaConNombre ; ficha: TFichaLPD; sala : TSalaDeJuego ); override;
  end;

implementation

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

Constructor TEditarFichaFuenteTiempo.Create(AOwner : TComponent; cosaConNombre : TCosaConNombre ; ficha: TFichaLPD; sala : TSalaDeJuego );
var
  i: Integer;
  prueba: String;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  if ficha <> nil then
  begin
    EFIni.Text := ficha.fecha.AsStr;
    FechaInicialDinamica.text := TFichaFuenteTiempo(ficha).fechaInicial.AsStr;
  end;
end;

function TEditarFichaFuenteTiempo.validarFormulario : boolean;
begin
  result:= inherited validarFormulario and
  validarEditFecha(EFIni) and
  validarTDateTimeEdit(FechaInicialDinamica) and
  inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
end;

procedure TEditarFichaFuenteTiempo.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteTiempo);
end;

procedure TEditarFichaFuenteTiempo.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteTiempo.BGuardarClick(Sender: TObject);
var
  periodicidad : TPeriodicidad;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := NIL;
    ficha:= TFichaFuenteTiempo.Create(
      capa,
    TFecha.Create_Str(EFIni.Text), periodicidad,
                                      TFecha.Create_Str(FechaInicialDinamica.Text));
    modalResult:= mrOk;
  end
end;

procedure TEditarFichaFuenteTiempo.CambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaFuenteTiempo.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado:= false;
end;

procedure TEditarFichaFuenteTiempo.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteTiempo.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteTiempo.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaFuenteTiempo.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteTiempo.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteTiempo.sgGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteTiempo.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaFuenteTiempo.sgChequearCambios(
  Sender: TObject);
begin
  inherited sgChequearCambios(sgPeriodicidad);
end;

end.

