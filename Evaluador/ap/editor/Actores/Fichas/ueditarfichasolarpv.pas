unit uEditarFichaSolarPV;

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
  uSalasDeJuegoParaEditor, uverdoc, uFuentesAleatorias, utilidades,
  usolarPV, ucosaConNombre, uFichasLPD, uBaseAltasEditores,
  uOpcionesSimSEEEdit, uCosa, uFechas;

resourcestring
  rsPotenciaMaxima = 'Potencia máxima [MW]';
  rsFuenteAleatoria = 'Fuente aleatoria';
  rsBorne = 'Borne';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';
  mesDebeSeleccionarUnaFuenteA = 'Debe seleccionar una fuente aleatoria';

type

  { TEditarFichaSolarPV }

  TEditarFichaSolarPV = class(TBaseEditoresFichasGeneradores)
    ComboFuentes: TComboBox;
    ePMax_Inversor: TEdit;
    eFactorDePerdidas: TEdit;
    eInclinacion: TEdit;
    eAzimut: TEdit;
    ePMax_1000_W_m2: TEdit;
    eDisp: TEdit;
    eRefSuelo: TEdit;
    eTrep: TEdit;
    eLatitud: TEdit;
    eLongitud: TEdit;
    ePagoPorEnergia: TEdit;

    ePagoPorDisponibilidad: TEdit;
    GroupBox1: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
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
    IntFicha: TStringGrid;

    procedure BAyudaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure EditExit(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure ComboFuentesCloseUp(Sender: TObject);

  protected
    function validarFormulario(): boolean; override;

  private
    Generador: TSolarPV;
    tiposColsUnidades: TDAOfTTipoColumna;
    sala: TSalaDeJuego;

  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaSolarPV: TEditarFichaSolarPV;

implementation

uses SimSEEEditMain;
  {$R *.lfm}

constructor TEditarFichaSolarPV.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
  fichaAux: TFichaSolarPV;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TSolarPV;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);


  self.sala := sala;
  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaSolarPV;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);

    self.ePMax_1000_W_m2.Text := FloatToStr(fichaAux.PMax_1000_W_m2 );
    self.ePMax_Inversor.Text := FloatToStr(fichaAux.PMax_Inversor );

    self.eDisp.Text := FloatToStr(fichaAux.disp);
    self.eTrep.Text := FloatToStr(fichaAux.tRepHoras);

    self.ePagoPorDisponibilidad.Text :=
      FloatToStr(fichaAux.PagoPorDisponibilidad_USD_MWh);
    self.ePagoPorEnergia.Text := FloatToStr(fichaAux.PagoPorEnergia_USD_MWh);
    self.eLatitud.Text := FloatToStr(fichaAux.latitud);
    self.eLongitud.Text := FloatToStr(fichaAux.longitud);
    self.eInclinacion.Text := FloatToStr(fichaAux.inclinacion);
    self.eAzimut.Text := FloatToStr(fichaAux.azimut);
    self.eFactorDePerdidas.Text := FloatToStr(fichaAux.fPerdidas_pu);
    self.eRefSuelo.Text := FloatToStr(fichaAux.reflexion_suelo);

  end
  else
  begin
    self.EFIni.Text := '0';
    self.ePMax_1000_W_m2.Text := FloatToStr( 50 * 1.2 );
    self.ePMax_Inversor.Text := FloatToStr(50.0);
    self.eDisp.Text := FloatToStr(0.98);
    self.eTrep.Text := FloatToStr(72);

    self.ePagoPorDisponibilidad.Text :=
      FloatToStr(0);
    self.ePagoPorEnergia.Text := FloatToStr(0);
    self.eLatitud.Text := FloatToStr(35);
    self.eLongitud.Text := FloatToStr(55);
    self.eInclinacion.Text := FloatToStr(35);
    self.eAzimut.Text := FloatToStr(0);
    self.eFactorDePerdidas.Text := FloatToStr(0.0335);
    self.eRefSuelo.Text := FloatToStr(0.3);

  end;
end;

function TEditarFichaSolarPV.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad);
end;

procedure TEditarFichaSolarPV.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaSolarPV.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;

begin
  if validarFormulario then
  begin

    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

    ficha := TFichaSolarPV.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad, StrToFloat(self. ePMax_1000_W_m2.Text),
      StrToFloat(self. ePMax_Inversor.Text),
      StrToFloat(self.eDisp.Text),
      StrToFloat(self.eTrep.Text), StrToFloat(self.ePagoPorDisponibilidad.Text),
      StrToFloat(self.ePagoPorEnergia.Text),
      StrToFloat(self.eLatitud.Text), StrToFloat(self.eLongitud.Text),
      StrToFloat(self.eInclinacion.Text), StrToFloat(self.eAzimut.Text),
      StrToFloat(self.eFactorDePerdidas.Text), StrToFloat(self.eRefSuelo.Text) );

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaSolarPV.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;



procedure TEditarFichaSolarPV.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;


procedure TEditarFichaSolarPV.ComboFuentesCloseUp(Sender: TObject);
begin
  inherited;
  TComboBox(Sender).Visible := False;
end;

procedure TEditarFichaSolarPV.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaSolarPV.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaSolarPV.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaSolarPV.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TSolarPV);
end;

procedure TEditarFichaSolarPV.FormCreate(Sender: TObject);
var
  i: integer;
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaSolarPV.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaSolarPV.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;


end.
