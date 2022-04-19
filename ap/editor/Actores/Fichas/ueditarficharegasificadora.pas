unit ueditarficharegasificadora;
interface

uses
{$IFDEF FPC-LCL}
  LResources,
{$ENDIF}

{$IFDEF WINDOWS}
 Windows,
 {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs,
  StdCtrls, Grids,
  CheckLst, uglobs, ufichasLPD, uBaseEditoresFichas,
  utilidades, uFechas, uBaseAltasEditores, uCosaConNombre, ExtCtrls, uconstantesSimSEE,
  usalasdejuego,
  uBaseEditoresFichasGeneradores,
  xMatDefs,
  uSalasDeJuegoParaEditor, uverdoc,
  uFuentesAleatorias,
  uRegasificadora,
  uOpcionesSimSEEEdit;


type

  { TEditarfichaRegasificadora }

  TEditarfichaRegasificadora = class(TBaseEditoresFichasGeneradores)
    CBBorneIndicePreciosCombustible: TComboBox;
    CBFuenteIndicePreciosCombustible: TComboBox;
    BGuardar: TButton;
    BCancelar: TButton;
    eConsumosPropios_ca: TLabeledEdit;
    eQGN_Max: TLabeledEdit;
    eFD: TLabeledEdit;
    eConsumosPropios_cb: TLabeledEdit;
    eTMR: TLabeledEdit;
    eBOG_ca: TLabeledEdit;
    eBOG_cb: TLabeledEdit;
    eGNL_Vmin: TLabeledEdit;
    eGNL_Vmax: TLabeledEdit;
    gbConsumosPropios: TGroupBox;
    LBornePreciosPorCombustible: TLabel;
    LFIni: TLabel;
    EFIni: TEdit;
    CBPeriodicidad: TCheckBox;
    LIndicePreciosPorCombustible: TLabel;
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
    procedure CBFuenteIndicePreciosCombustibleChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer; var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
  protected
    function validarFormulario(): boolean; override;
  private
    Generador: TRegasificadora;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarfichaRegasificadora.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaRegasificadora;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  inherited inicializarCBFuente(
    CBFuenteIndicePreciosCombustible,
    CBBorneIndicePreciosCombustible, True);

  guardado := True;


  Generador := cosaConNombre as TRegasificadora;


  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaRegasificadora;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    eFD.Text := FloatToStr(fichaAux.fd);
    eTMR.Text := FloatToStr(fichaAux.TMR);
    eBOG_ca.Text := FloatToStr(fichaAux.QGN_BOG_ca);
    eBOG_Cb.Text := FloatToStr(fichaAux.QGN_BOG_cb);
    eGNL_Vmin.Text := FloatToStr(fichaAux.VGNL_min);
    eGNL_Vmax.Text := FloatToStr(fichaAux.VGNL_max);
    eQGN_Max.Text := FloatToStr(fichaAux.QGN_Max);
    eConsumosPropios_ca.Text := FloatToStr(fichaAux.QGN_ConsumosPropios_ca);
    eConsumosPropios_cb.Text := FloatToStr(fichaAux.QGN_ConsumosPropios_cb);

    inherited setCBFuente(CBFuenteIndicePreciosCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.fuente_idxPrecioCombustible,
      fichaAux.borne_idxPrecioCombustible);

  end
  else
  begin
    self.EFIni.Text := 'Auto';
    eFD.Text := FloatToStr(1);
    eTMR.Text := FloatToStr(0);
    eBOG_ca.Text := FloatToStr( 250000/(24*3600) );
    eBOG_Cb.Text := FloatToStr( 0 );
    eGNL_Vmin.Text := FloatToStr( 250000 );
    eGNL_Vmin.Text := FloatToStr( 15000 );
    eGNL_Vmax.Text := FloatToStr( 265000 );
    eConsumosPropios_cb.Text := FloatToStr( 0.95 );
    eQGN_Max.Text := FloatToStr( 10E6 / (24*3600 ) );
    eConsumosPropios_ca.Text := FloatToStr( 0.67 ); { 39.27mT/d }
    eConsumosPropios_cb.Text := FloatToStr( 1.76E-3 ); { 1.193 mT/Mm3 }
  end;
end;

function TEditarfichaRegasificadora.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni)
  and inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
  and validarEditFloat( eFD )
  and validarEditFloat( eTMR )
  and validarEditFloat( eBOG_ca )
  and validarEditFloat( eBOG_cb )
  and validarEditFloat( eGNL_Vmin )
  and validarEditFloat( eGNL_Vmax )
  and validarEditFloat( eQGN_Max )
  and validarEditFloat( eConsumosPropios_ca )
  and validarEditFloat( eConsumosPropios_cb )
  and inherited validarCBFuente(CBFuenteIndicePreciosCombustible,
          CBBorneIndicePreciosCombustible, 0);
end;


procedure TEditarfichaRegasificadora.CBFuenteIndicePreciosCombustibleChange(
  Sender: TObject);
begin
    inherited cbFuenteChange(CBFuenteIndicePreciosCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarfichaRegasificadora.BGuardarClick(Sender: TObject);
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


    ficha := TFichaRegasificadora.Create(
      capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad,
      valorCBFuente(CBFuenteIndicePreciosCombustible), valorCBString(
      CBBorneIndicePreciosCombustible),
      StrToFloat( eFD.Text ), StrToFloat( eTMR.Text ),
      StrToFloat( eGNL_Vmin.Text ), StrToFloat( eGNL_Vmax.Text ),
      StrToFloat( eBOG_ca.Text ), StrToFloat( eBOG_cb.Text ),
      StrToFloat( eQGN_Max.Text ),
      StrToFloat( eConsumosPropios_ca.text ),
      StrToFloat( eConsumosPropios_cb.Text )
      );

      ModalResult := mrOk;
  end;
end;

procedure TEditarfichaRegasificadora.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarfichaRegasificadora.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarfichaRegasificadora.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarfichaRegasificadora.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarfichaRegasificadora.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarfichaRegasificadora.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarfichaRegasificadora.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarfichaRegasificadora.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;



procedure TEditarfichaRegasificadora.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TRegasificadora );
end;

initialization
end.
