unit ueditarfichagsimple_monocombustible;


interface

uses
{$IFDEF FPC-LCL}
  LResources,
{$ENDIF}

{$IFDEF WINDOWS}
 Windows,
 {$ELSE}
 LCLType,
 {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ugsimple_MonoCombustible, CheckLst, uglobs, ufichasLPD, uBaseEditoresFichas,
  utilidades, uFechas, uBaseAltasEditores, uCosaConNombre, ExtCtrls, uconstantesSimSEE,
  usalasdejuego, uBaseEditoresFichasGeneradores, xMatDefs,
  uSalasDeJuegoParaEditor, uverdoc, uFuentesAleatorias, uOpcionesSimSEEEdit;



type

  { TEditarFichagsimple_MonoCombustible }

  TEditarFichagsimple_MonoCombustible = class(TBaseEditoresFichasGeneradores)
    eFD: TLabeledEdit;
    ePMax: TLabeledEdit;
    eQMax_A: TLabeledEdit;
    eRen_A: TLabeledEdit;
    eTMR: TLabeledEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    LFIni: TLabel;
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
    CBRestrEMax: TCheckBox;
    ERestrEMax: TEdit;
    BAyuda: TButton;
    Label1: TLabel;
    ePagoPorPotencia: TEdit;
    Label2: TLabel;
    ePagoPorEnergia: TEdit;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer; var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
  protected
    function validarFormulario(): boolean; override;
  private
    Generador: TGsimple_MonoCombustible;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichagsimple_MonoCombustible.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichagsimple_MonoCombustible;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TGsimple_MonoCombustible;
  guardado := True;

  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);


  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichagsimple_MonoCombustible;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    ePMax.Text := FloatToStr(fichaAux.PMax);
    eQMax_A.Text := FloatToStr(fichaAux.QMax_A);
    eRen_A.Text:= FloatToStr( fichaAux.ren_A );
    eFD.Text := FloatToStr(fichaAux.disp);
    eTMR.Text := FloatToStr(fichaAux.tRepHoras);
    self.ePagoPorPotencia.Text := FloatToStr(fichaAux.PagoPorDisponibilidad_USD_MWh );
    self.ePagoPorEnergia.Text := FloatToStr(fichaAux.PagoPorEnergia_USD_MWh);
  end
  else
  begin
    self.EFIni.Text := '';
    ePMax.Text := '';
    eQMax_A.Text := '';
    eRen_A.text:= FloatToStr( 0.5 );
    eFD.Text :='';
    eTMR.Text := '';
    self.ePagoPorPotencia.Text := FloatToStr( 0 );
    self.ePagoPorEnergia.Text := FloatToStr(0 );

    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);
  end;
end;

function TEditarFichagsimple_MonoCombustible.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad)
    and ValidarEditFloat( ePMax )
    and ValidarEditFloat( eQMax_A )
    and ValidarEditFloat( eFD )
    and validarEditFloat( eTMR )
    and validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal)
end;

procedure TEditarFichagsimple_MonoCombustible.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);
end;




procedure TEditarFichagsimple_MonoCombustible.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  restrEMax,caudalB: NReal;
begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
    restrEMax := inherited rest(CBRestrEMax, ERestrEMax, MaxNReal);

    ficha := TFichagsimple_MonoCombustible.Create(
      capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad,
      StrToFloat( ePMax.Text ),
      StrToFloat( eQMax_A.Text ),
      StrToFloat( eRen_A.Text ),
      StrToFloat( eFD.Text ),
      StrToFloat( eTMR.Text ),
      StrToFloat( self.ePagoPorPotencia.Text ),
      StrToFloat( self.ePagoPorEnergia.text )
      ); ///estos son los pago por disponibilidad y por energia respectivamente

     //notificarGuardarDatos;
     ModalResult := mrOk;
  end;
end;

procedure TEditarFichagsimple_MonoCombustible.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichagsimple_MonoCombustible.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichagsimple_MonoCombustible.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichagsimple_MonoCombustible.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichagsimple_MonoCombustible.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichagsimple_MonoCombustible.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichagsimple_MonoCombustible.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichagsimple_MonoCombustible.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichagsimple_MonoCombustible.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichagsimple_MonoCombustible.BAyudaClick(Sender: TObject);
begin
  verdoc(self, Tgsimple_MonoCombustible);
end;

initialization
end.