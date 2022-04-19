unit ueditarfichasumcomb;

interface

uses
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
  utsumcomb,
  uOpcionesSimSEEEdit;


type

  { TEditarfichasumcomb }

  TEditarfichasumcomb = class(TBaseEditoresFichasGeneradores)
    CBFuenteIndicePreciosCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    BGuardar: TButton;
    BCancelar: TButton;
    cbUnidadesDelPrecio: TComboBox;
    cb_flg_QMedMeax_Activo: TCheckBox;
    eFD: TLabeledEdit;
    eQMax: TLabeledEdit;
    ePrecio: TLabeledEdit;
    eTMR: TLabeledEdit;
    gbRestriccionCaudalMedio: TGroupBox;
    eQMedMax: TLabeledEdit;
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
    rbPrecio_PCS: TRadioButton;
    rbPrecio_PCI: TRadioButton;
    sgPeriodicidad: TStringGrid;
    ELargoPeriodo: TEdit;
    CBLargoPeriodo: TComboBox;
    BAyuda: TButton;
    procedure CBFuenteIndicePreciosCombustibleChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
    Generador: TSuministroSimpleCombustible;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarfichasumcomb.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaSuministroSimpleCombustible;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TSuministroSimpleCombustible;

  guardado := True;

  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(
    CBFuenteIndicePreciosCombustible,
    CBBorneIndicePreciosCombustible, True);

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaSuministroSimpleCombustible;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    eQMax.Text := FloatToStr(fichaAux.QMax);
    cb_flg_QMedMeax_Activo.Checked:= fichaAux.flg_QMedMax_Activo;
    eQMedMax.Text:= FloatToStr( fichaAux.QMedMax );
    ePrecio.Text := FloatToStr(fichaAux.precio_por_unidad);
    cbUnidadesDelPrecio.ItemIndex:= cbUnidadesDelPrecio.Items.IndexOf( fichaAux.unidades_del_precio );
    rbPrecio_PCS.Checked := fichaAux.flg_precio_a_PCS;
    rbPrecio_PCI.Checked := not fichaAux.flg_precio_a_PCS;
    eFD.Text := FloatToStr(fichaAux.fd);
    eTMR.Text := FloatToStr(fichaAux.TMR);
    inherited setCBFuente(CBFuenteIndicePreciosCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.fuente_idxPrecioCombustible,
      fichaAux.borne_idxPrecioCombustible);
  end
  else
  begin
    self.EFIni.Text := '';
    eQMax.Text := '';
    ePrecio.Text :=  '';
    cb_flg_QMedMeax_Activo.Checked:= false;
    eQMedMax.Text:= FloatToStr( 0.0 );
    cbUnidadesDelPrecio.ItemIndex:= 0;
    rbPrecio_PCS.Checked := true;
    rbPrecio_PCI.Checked := false;
    eFD.Text := FloatToStr( 1 );
    eTMR.Text := FloatToStr( 0 );
  end;
end;

function TEditarFichasumcomb.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad)
    and validarEditFloat( eQMax )
    and validarEditFloat( eQMedMax )
    and validarEditFloat( eFD )
    and validarEditFloat( eTMR )
    and validarEditFloat( ePrecio )
    and validarCBFuente(CBFuenteIndicePreciosCombustible,
    CBBorneIndicePreciosCombustible, 0);
end;

procedure TEditarfichasumcomb.CBFuenteIndicePreciosCombustibleChange(Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosCombustible,
    CBBorneIndicePreciosCombustible);
end;


procedure TEditarFichasumcomb.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;


procedure TEditarFichasumcomb.BGuardarClick(Sender: TObject);
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


    ficha := TFichaSuministroSimpleCombustible.Create(
      capa, FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
      StrToFloat( eQMax.Text),
      cb_flg_QMedMeax_Activo.Checked,
      StrToFloat( eQMedMax.Text ),
      StrToFloat( ePrecio.Text),
      cbUnidadesDelPrecio.Items[cbUnidadesDelPrecio.ItemIndex],
      rbPrecio_PCS.Checked,
      valorCBFuente(CBFuenteIndicePreciosCombustible),
      valorCBString( CBBorneIndicePreciosCombustible),
      StrToFloat( eFD.Text ),
      StrToFloat( eTMR.Text) );

    ModalResult := mrOk;

  end;
end;

procedure TEditarFichasumcomb.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichasumcomb.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichasumcomb.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichasumcomb.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichasumcomb.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichasumcomb.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichasumcomb.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichasumcomb.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;



procedure TEditarFichasumcomb.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TSuministroSimpleCombustible);
end;

initialization
end.
