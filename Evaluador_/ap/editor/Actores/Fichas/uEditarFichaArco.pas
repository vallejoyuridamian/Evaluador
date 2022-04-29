unit uEditarFichaArco;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, xMatDefs, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, ExtCtrls, Grids, uArcos,
  uCosaConNombre, uFichasLPD,
  uSalasDeJuego, utilidades, uconstantesSimSEE, uFechas, uverdoc, uOpcionesSimSEEEdit;

type

  { TEditarFichaArco }

  TEditarFichaArco = class(TBaseEditoresFichas)
    cbConsiderarPeajeEnElDespacho: TCheckBox;
    cbSumarPeajeAl_CDP: TCheckBox;
    CbConsiderarArcoGem: TCheckBox;
    CbArcoGemelo: TComboBox;
    Label9: TLabel;
    Pmax2Arcos: TEdit;
    eFactorPeaje_CDP: TEdit;
    ePagoPorDisponibilidad: TEdit;
    eTMR: TEdit;
    eFD: TEdit;
    ePeaje_pp: TEdit;
    eRendimiento_pp: TEdit;
    ePMax_pp: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
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
    procedure FormCreate(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
     procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
    procedure validarCambioTabla(tabla: TStringGrid); override;
  private
    arco: TArco;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaArco: TEditarFichaArco;

implementation

uses uBaseAltasEditores, SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichaArco.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaArco;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  arco := cosaConNombre as TArco;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaArco;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    self.eRendimiento_pp.Text := DAOfNRealToStr_(fichaAux.rendimiento, 12, 2, ';');
    self.ePeaje_pp.Text := DAOfNRealToStr_(fichaAux.peaje, 12, 2, ';');
    self.ePMax_pp.Text := DAOfNRealToStr_(fichaAux.PMAx, 12, 1, ';');
    self.eFD.Text := FloatToStr(fichaAux.fd);
    self.eTMR.Text := FloatToStr(fichaAux.tRepHoras);
    self.cbConsiderarPeajeEnElDespacho.Checked :=
      fichaAux.flg_ConsiderarPeajeEnElDespacho;
    self.cbSumarPeajeAl_CDP.Checked := fichaAux.flg_SumarPeajeAlCDP;
    self.eFactorPeaje_CDP.Text := FloatToStr(fichaAux.factorPeajeCDP);
    self.ePagoPorDisponibilidad.text:= FloatToStr( fichaAux.PagoPorDisponibilidad_USD_MWh );
    {$IFDEF ARCO_GEMELOS}
    //ARCOGEMELO
    Self.CbConsiderarArcoGem.Checked:=fichaAux.flg_ConArgoGemelo;
    inicializarCBArcos(self.CbArcoGemelo,fichaAux.flg_ConArgoGemelo);
    setCBArco(self.CbArcoGemelo, fichaAux.ArcoGemelo);
    self.Pmax2Arcos.Text:=FloatToStr(fichaAux.PMaxConjunto);
    {$ENDIF}
  end
  else
  begin
    self.EFIni.Text := '';
    self.eRendimiento_pp.Text := '';
    self.ePeaje_pp.Text := '';
    self.ePMax_pp.Text := '';
    self.eFD.Text := '';
    self.eTMR.Text := '';
    self.cbConsiderarPeajeEnElDespacho.Checked := True;
    self.cbSumarPeajeAl_CDP.Checked := True;
    self.eFactorPeaje_CDP.Text := FloatToStr(1.0);
    self.ePagoPorDisponibilidad.text:= FloatToStr( 0.0 );
    {$IFDEF ARCO_GEMELOS}
    inicializarCBArcos(self.CbArcoGemelo,true);
    Self.CbConsiderarArcoGem.Checked:=false;
    self.Pmax2Arcos.Text:='';
    {$ENDIF}
  end;
end;

function TEditarFichaArco.validarFormulario: boolean;
var
  res: boolean;
begin

  res :=inherited validarFormulario and
    validarEditFecha(EFIni) and validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad) and validarEditFloat(eFD, 0, 2) and
    validarEditFloat(eTMR, 0, 10000) and validarEditDAOfNReal(
    eRendimiento_pp, -100, 100, ';') and validarEditDAOfNReal(
    ePMax_pp, -100000, 100000, ';') and validarEditDAOfNReal(
    ePeaje_pp, -100000, 100000, ';')
    and validarEditFloat( ePagoPorDisponibilidad );

  if cbSumarPeajeAl_CDP.Checked then
    res := res and validarEditFloat(eFactorPeaje_CDP, -1E20, 1E20);
  if CbConsiderarArcoGem.Checked then
     res := res and validarCBArco(CbArcoGemelo);
  Result := res;
end;

procedure TEditarFichaArco.validarCambioTabla(tabla: TStringGrid);
begin
  inherited validarCambioTablaNReals(tabla);
end;

procedure TEditarFichaArco.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaArco.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaArco.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaArco.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaArco.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaArco.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaArco.sgGetEditText(Sender: TObject; ACol, ARow: integer;
  var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaArco.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, key, Shift);
end;

procedure TEditarFichaArco.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaArco.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaArco.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  ValorArcoGem: TArco;
  Flg_ArcoGem:Boolean;
  Pmax_2Arcos: Integer;
begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

    if CbConsiderarArcoGem.Checked then
    begin
         ValorArcoGem:= valorCBArco(CbArcoGemelo);
         Flg_ArcoGem:= CbConsiderarArcoGem.Checked;
         Pmax_2Arcos:= StrToInt(Pmax2Arcos.Text);
    end
    else
    begin
         ValorArcoGem:= Nil;
         Flg_ArcoGem:= False;
         Pmax_2Arcos:= 0;
    end;

    ficha := TFichaArco.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad, StrToDAOfNReal_(eRendimiento_pp.Text, ';'),
      StrToDAOfNReal_(ePeaje_pp.Text, ';'), StrToDAOfNReal_(
      ePMax_pp.Text, ';'), StrToFloat(eFD.Text), StrToFloat(eTMR.Text),
      cbConsiderarPeajeEnElDespacho.Checked, cbSumarPeajeAl_CDP.Checked,
      StrToFloat(eFactorPeaje_CDP.Text), StrToFloat( ePagoPorDisponibilidad.text )
      ,ValorArcoGem,Flg_ArcoGem,Pmax_2Arcos);

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaArco.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TArco);
end;

end.
