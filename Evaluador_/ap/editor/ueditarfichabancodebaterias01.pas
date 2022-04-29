unit uEditarFichaBancodeBaterias01;


interface

uses
   {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, xMatDefs, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas,
  ubancodebaterias01, uFichasLPD,
  uFechas, uCosaConNombre,
  usalasdejuego,
  uSalasDeJuegoParaEditor, uconstantesSimSEE, utilidades, uverdoc, StdCtrls,
  ExtCtrls, Grids, uOpcionesSimSEEEdit;

type

  { TEditarFichaBancoDeBaterias01 }

  TEditarFichaBancoDeBaterias01 = class(TBaseEditoresFichas)
    eCapacidadMaxima: TEdit;
    ePagoPorDisponibilidad: TEdit;
    etmr: TEdit;
    efd: TEdit;
    eRen_Dem: TEdit;
    eRen_Gen: TEdit;
    ePMax_Dem: TEdit;
    ePMax_Gen: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    eCV_MWh_ValorizadoManual: TLabeledEdit;
    Label8: TLabel;
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
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure cambiosForm(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaBancoDeBaterias01: TEditarFichaBancoDeBaterias01;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

procedure TEditarFichaBancoDeBaterias01.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaBancoDeBaterias01.BGuardarClick(Sender: TObject);
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
    ficha := TFichaBancoDeBaterias01.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad,
      StrToFloat(ePMax_Gen.Text), StrToFloat(
      ePMax_Dem.Text), StrToFloat(
      eRen_Gen.Text), StrToFloat(
      eRen_Dem.Text), StrToFloat(
      eCapacidadMaxima.Text), StrToFloat(
      efd.Text), StrToFloat(etmr.Text), StrToFloat( eCV_MWh_ValorizadoManual.text ),
      strToFloat( ePagoPorDisponibilidad.text ));
    ModalResult := mrOk;
  end;
end;


procedure TEditarFichaBancoDeBaterias01.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaBancoDeBaterias01.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

constructor TEditarFichaBancoDeBaterias01.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fCasteada: TFichaBancoDeBaterias01;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if ficha <> nil then
  begin
    fCasteada := ficha as TFichaBancoDeBaterias01;
    eFIni.Text := fCasteada.fecha.asStr;

    eCapacidadMaxima.Text:= FloatToStr( fCasteada.CapacidadMaxima_MWh );

    ePMax_Gen.Text := FloatToStrF(fCasteada.PMax_Gen, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    eRen_Gen.Text := FloatToStrF(fCasteada.ren_Gen, ffGeneral,
      CF_PRECISION, CF_DECIMALES);

    ePMax_Dem.Text := FloatToStrF(fCasteada.PMax_Dem, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    eRen_Dem.Text := FloatToStrF(fCasteada.ren_Dem, ffGeneral,
      CF_PRECISION, CF_DECIMALES);

    efd.Text := FloatToStrF(fCasteada.fd, ffGeneral, 6, 4);
    etmr.Text := FloatToStrF(fCasteada.tmr, ffGeneral, 6, 1);
    eCV_MWh_ValorizadoManual.text:= FloatToStrF( fCasteada.cv_MWh_ValorizadoManual, ffGeneral, 6,3 );
    ePagoPorDisponibilidad.Text:= FloatToStrF( fCasteada.pagoPorDisponibilidad_USDxMWhh, ffGeneral, 6, 3);
  end
  else
  begin
    fCasteada := ficha as TFichaBancoDeBaterias01;
    eFIni.Text := 'Auto';
    eCapacidadMaxima.Text:= FloatToStr( 0.0 );

    ePMax_Gen.Text := FloatToStrF(0.0, ffGeneral, CF_PRECISION, CF_DECIMALES);
    eRen_Gen.Text := FloatToStrF(0.0, ffGeneral, CF_PRECISION, CF_DECIMALES);

    ePMax_Dem.Text := FloatToStrF(0.0, ffGeneral, CF_PRECISION, CF_DECIMALES);
    eRen_Dem.Text := FloatToStrF(0.0, ffGeneral, CF_PRECISION, CF_DECIMALES);

    efd.Text := FloatToStrF(0.0, ffGeneral, 6, 4);
    etmr.Text := FloatToStrF(0.0, ffGeneral, 6, 1);
    eCV_MWh_ValorizadoManual.text:= FloatToStrF( 0.0, ffGeneral, 6,3 );
    ePagoPorDisponibilidad.Text:= FloatToStrF( 0.0, ffGeneral, 6, 3);

  end;

end;


function TEditarFichaBancoDeBaterias01.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and
    validarEditFecha(EFIni) and validarPeriodicidad(CBPeriodicidad,
    CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    validarEditFloat(ePMax_Gen, 0, 1e10) and validarEditFloat(
    ePMax_Dem, 0, 1e10) and validarEditFloat(eren_Gen, 0, 1) and
    validarEditFloat(eren_Dem, 0, 1) and validarEditFloat(
    efd, 0, 1) and validarEditFloat(etmr, 0, 1e10)
    and validarEditFloat( eCV_MWh_ValorizadoManual, -1e10, 1e10);
end;



end.

