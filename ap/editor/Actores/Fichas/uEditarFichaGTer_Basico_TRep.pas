unit uEditarFichaGTer_Basico_TRep;


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
  uGTer_Basico_TRep, ucosaConNombre, uFichasLPD, uBaseAltasEditores, uOpcionesSimSEEEdit;

resourcestring
  rsPotenciaMaxima = 'Potencia máxima[MW]';
  rsCostoVariable = 'Costo variable[USD/MWh]';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';

type

  { TEditarFichaGTer_Basico_TRep }

  TEditarFichaGTer_Basico_TRep = class(TBaseEditoresFichasGeneradores)
    ePagoPorDisponibilidad: TEdit;
    ePagoPorEnergia: TEdit;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LFIni: TLabel;
    IntFicha: TStringGrid;
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
    CBRestrEMax: TCheckBox;
    ERestrEMax: TEdit;
    BAyuda: TButton;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
  protected
    function validarFormulario(): boolean; override;
  private
    Generador: TGTer_Basico_TRep;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaGTer_Basico_TRep: TEditarFichaGTer_Basico_TRep;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichaGTer_Basico_TRep.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fichaAux: TFichaGTer_Basico_TRep;
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TGTer_Basico_TRep;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaGTer_Basico_TRep;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    self.IntFicha.cells[1, 0] := FloatToStr(fichaAux.PMax);
    self.IntFicha.cells[1, 1] := FloatToStr(fichaAux.cv);
    self.IntFicha.cells[1, 2] := FloatToStr(fichaAux.disp);
    self.IntFicha.cells[1, 3] := FloatToStr(fichaAux.tRepHoras);

    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited setCBFuente(CBFuenteIndicePreciosPorCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.indicePreciosPorCombustible,
      fichaAux.bornePreciosPorCombustible);
    ePagoPorDisponibilidad.text:= FloatToStr( fichaAux.PagoPorDisponibilidad_MWh );
    ePagoPorEnergia.text:= FloatToStr( fichaAux.PagoPorEnergia_MWh );
  end
  else
  begin
    self.EFIni.Text := '';
    for i := 0 to self.IntFicha.RowCount - 1 do
      self.IntFicha.cells[1, i] := '';
    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);
    ePagoPorDisponibilidad.text:= FloatToStr( 0.0 );
    ePagoPorEnergia.text:= FloatToStr( 0.0 );
  end;
end;

function TEditarFichaGTer_Basico_TRep.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo,
    sgPeriodicidad) and inherited validarTablaNReals_(IntFicha) and
    inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0)
    and validarEditFloat( ePagoPorDisponibilidad )
    and validarEditFloat( ePagoPorEnergia )
    ;
end;


procedure TEditarFichaGTer_Basico_TRep.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaGTer_Basico_TRep.BGuardarClick(Sender: TObject);
var
  {  fAux : TFichaGenSencillo;}
  periodicidad: TPeriodicidad;
  restrEMax: NReal;
begin
  if validarFormulario then
  begin
  {  fAux := TFichaGenSencillo(Generador.lpd.ficha(StrToInt(self.IntAnio.text), StrToInt(self.IntSemana.text)));
  if (fAux = NIL) or (fAux = ficha2) then
     begin          }
    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
    restrEMax := inherited rest(CBRestrEMax, ERestrEMax, MaxNReal);

    ficha := TFichaGTer_Basico_TRep.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad, StrToFloat(self.IntFicha.cells[1, 0]),
      StrToFloat(self.IntFicha.cells[1, 1]),
      valorCBFuente(CBFuenteIndicePreciosPorCombustible), valorCBString(
      CBBorneIndicePreciosCombustible),
      StrToFloat(self.IntFicha.cells[1, 2]),
      CBRestrEMax.Checked, restrEMax,
      StrToFloat(self.IntFicha.Cells[1, 3]), StrToFloat( ePagoPorDisponibilidad.text ), StrToFloat( ePagoPorEnergia.text ));
    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaGTer_Basico_TRep.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaGTer_Basico_TRep.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaGTer_Basico_TRep.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaGTer_Basico_TRep.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichaGTer_Basico_TRep.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaGTer_Basico_TRep.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaGTer_Basico_TRep.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaGTer_Basico_TRep.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);

  self.IntFicha.cells[0, 0] := rsPotenciaMaxima;
  self.IntFicha.cells[0, 1] := rsCostoVariable;
  self.IntFicha.cells[0, 2] := rsCoeficienteDisponibilidadFortuita;
  self.IntFicha.cells[0, 3] := rsTiempoDeReparacionH;

  utilidades.AutoSizeCol(IntFicha, 0);
end;

procedure TEditarFichaGTer_Basico_TRep.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaGTer_Basico_TRep.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

end.
