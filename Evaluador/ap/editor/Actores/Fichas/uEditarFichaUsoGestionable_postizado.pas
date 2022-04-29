unit uEditarFichaUsoGestionable_postizado;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, uconstantesSimSEE,
  usalasdejuego, uBaseEditoresFichasGeneradores, xMatDefs,
  uSalasDeJuegoParaEditor, uverdoc,
  utilidades,
  uUsoGestionable_postizado, ucosaConNombre, uFichasLPD, uBaseAltasEditores,
  uOpcionesSimSEEEdit,
  uCosa;

resourcestring
  rsPoste = 'Poste';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';
  mesDebeSeleccionarUnaFuenteA = 'Debe seleccionar una fuente aleatoria';

type

  { TEditarFichaUsoGestionable_postizado }

  TEditarFichaUsoGestionable_postizado = class(TBaseEditoresFichasGeneradores)
    e_fdpp: TEdit;
    e_uvpp: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    lb_fdpp: TLabel;
    lbUtilidades: TLabel;
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
    Label1: TLabel;

    procedure BAyudaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure EditExit(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure ComboFuentesCloseUp(Sender: TObject);
  protected
    function validarFormulario(): boolean; override;
  private
    Generador: TUsoGestionable_postizado;
    tiposColsUnidades: TDAOfTTipoColumna;
    fichaAux: TFichaUsoGestionable_postizado;
    sala: TSalaDeJuego;
    fdpp, uvpp: TDAofNReal;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichaUsoGestionable_postizado.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
  s: string;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TUsoGestionable_postizado;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  fichaAux := ficha as TFichaUsoGestionable_postizado;
  self.sala := sala;


  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaUsoGestionable_postizado;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    e_fdpp.Text := DAOfNRealToStr_(fichaAux.fdpp, 8, 3, ';');
    e_uvpp.Text := DAOfNRealToStr_(fichaAux.uvpp, 8, 2, ';');
  end
  else
  begin
    self.EFIni.Text := '';
    s := '0';
    for i := 1 to sala.globs.NPostes - 1 do
      s := s + '; 0';
    e_fdpp.Text := s;
    e_uvpp.Text := s;
  end;
end;

function TEditarFichaUsoGestionable_postizado.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad);
end;


procedure TEditarFichaUsoGestionable_postizado.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaUsoGestionable_postizado.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  fdpp, uvpp: TDAofNReal;

begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

    fdpp := StrToDAOfNReal_(e_fdpp.Text, ';');
    uvpp := StrToDAOfNReal_(e_uvpp.Text, ';');

    ficha := TFichaUsoGestionable_postizado.Create( capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad, fdpp, uvpp);

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaUsoGestionable_postizado.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaUsoGestionable_postizado.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;


procedure TEditarFichaUsoGestionable_postizado.ComboFuentesCloseUp(Sender: TObject);
begin
  inherited;
  TComboBox(Sender).Visible := False;
end;

procedure TEditarFichaUsoGestionable_postizado.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaUsoGestionable_postizado.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaUsoGestionable_postizado.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaUsoGestionable_postizado.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, 'TUsoGestionable_Postizado');
end;

procedure TEditarFichaUsoGestionable_postizado.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;


end.
