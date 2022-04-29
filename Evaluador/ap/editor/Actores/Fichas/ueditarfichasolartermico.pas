unit ueditarFichaSolarTermico;

  {$MODE Delphi}

interface

uses
//  Windows,
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, uconstantesSimSEE,
  usalasdejuego, uBaseEditoresFichasGeneradores, xMatDefs,
  uSalasDeJuegoParaEditor, uverdoc, uFuentesAleatorias, utilidades,
  usolartermico, ucosaConNombre, uFichasLPD, uBaseAltasEditores,
  uOpcionesSimSEEEdit,
  uCosa, uFechas;

resourcestring
  rsPotenciaMinima = 'Potencia mínima [MW]';
  rsPotenciaMaxima = 'Potencia máxima [MW]';
  rsCostoVariablePotenciaMinima = 'Costo Variable a potencia mínima [USD/MWh]';
  rsCostoVariable = 'Costo Variable [USD/MWh]';
  rsPoste = 'Poste';
  rsFuenteAleatoria = 'Fuente aleatoria';
  rsBorne = 'Borne';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';
  mesDebeSeleccionarUnaFuenteA = 'Debe seleccionar una fuente aleatoria';

type

  { TEditarFichaSolarTermico }

  TEditarFichaSolarTermico = class(TBaseEditoresFichasGeneradores)
    ComboFuentes: TComboBox;
    eRendAlmac: TEdit;
    eFAmp: TEdit;
    ePagoPorEnergia: TEdit;

    ePagoPorDisponibilidad: TEdit;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
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
    cbHayAlmacenDeEnergia: TCheckBox;
    BAyuda: TButton;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    IntFicha: TStringGrid;

    procedure cbHayAlmacenDeEnergiaChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure cbHayAlmacenDeEnergiaClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  protected
    function validarFormulario(): boolean; override;

  private
    Generador: TSolartermico;
    tiposColsUnidades: TDAOfTTipoColumna;
    fichaAux: TFichaSolarTermico;
    sala: TSalaDeJuego;


  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaSolarTermico: TEditarFichaSolarTermico;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichaSolarTermico.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
  fichaAux: TFichaSolartermico;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TSolartermico;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);


  fichaAux := ficha as TFichaSolartermico;
  self.sala := sala;

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaSolartermico;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    self.IntFicha.cells[1, 0] := FloatToStr(fichaAux.Pmin);
    self.IntFicha.cells[1, 1] := FloatToStr(fichaAux.Pmax);
    self.IntFicha.cells[1, 2] := FloatToStr(fichaAux.cv_min);
    self.IntFicha.cells[1, 3] := FloatToStr(fichaAux.cv);
    self.IntFicha.cells[1, 4] := FloatToStr(fichaAux.disp);
    self.IntFicha.cells[1, 5] := FloatToStr(fichaAux.tRepHoras);

    self.ePagoPorDisponibilidad.Text :=
      FloatToStr(fichaAux.PagoPorDisponibilidad_USD_MWh);
    self.ePagoPorEnergia.Text := FloatToStr(fichaAux.PagoPorEnergia_USD_MWh);
    self.eFAmp.Text := FloatToStr(fichaAux.FAmp);
    self.eRendAlmac.Text := DAOfNRealToStr_(fichaAux.rendimiento_almacen, 1, 3, ';');

    cbHayAlmacenDeEnergia.Checked := fichaAux.HayAlmacenDeEnergia;
    inherited setCBFuente(CBFuenteIndicePreciosPorCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.indicePreciosPorCombustible,
      fichaAux.bornePreciosPorCombustible)
  end
  else
  begin
    self.EFIni.Text := '';
    for i := 0 to self.IntFicha.RowCount - 1 do
      self.IntFicha.cells[1, i] := '';
    cbHayAlmacenDeEnergia.Checked := False;
    self.ePagoPorDisponibilidad.Text := FloatToStr(0.0);
    self.ePagoPorEnergia.Text := FloatToStr(0.0);
    self.eFAmp.Text := FloatToStr(1.0);
    self.eRendAlmac.Text := FloatToStr(1.0);
    if sala.globs.NPostes > 1 then
    begin
      for i := 1 to sala.globs.NPostes - 1 do
        self.eRendAlmac.Text := self.eRendAlmac.Text + ';' + FloatToStr(1.0);
    end;
  end;
  eRendAlmac.Enabled := cbHayAlmacenDeEnergia.Checked;
end;

function TEditarFichaSolarTermico.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad) and inherited validarTablaNReals_(IntFicha) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0);
end;


procedure TEditarFichaSolarTermico.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaSolarTermico.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  restrEMax: NReal;
  cv: NReal;
  nuevos_valores: TDAofNReal;
begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

    nuevos_valores := StrToDAOfNReal_(eRendAlmac.Text, ';');

    ficha := TFichaSolartermico.Create(
      capa, FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
      StrToFloat(self.IntFicha.cells[1, 0]), StrToFloat(self.IntFicha.cells[1, 1]),
      StrToFloat(self.IntFicha.cells[1, 2]), StrToFloat(self.IntFicha.cells[1, 3]),
      valorCBFuente(CBFuenteIndicePreciosPorCombustible), valorCBString(
      CBBorneIndicePreciosCombustible), StrToFloat(self.IntFicha.cells[1, 4]),
      cbHayAlmacenDeEnergia.Checked, StrToFloat(self.IntFicha.Cells[1, 5]),
      StrToFloat(self.ePagoPorDisponibilidad.Text),
      StrToFloat(self.ePagoPorEnergia.Text), StrToFloat(self.eFAmp.Text),
      nuevos_valores);

    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaSolarTermico.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaSolarTermico.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaSolarTermico.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaSolarTermico.cbHayAlmacenDeEnergiaClick(Sender: TObject);
begin

end;


procedure TEditarFichaSolarTermico.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaSolarTermico.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaSolarTermico.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaSolarTermico.cbHayAlmacenDeEnergiaChange(Sender: TObject);
begin
  eRendAlmac.Enabled := cbHayAlmacenDeEnergia.Checked;
end;

procedure TEditarFichaSolarTermico.FormCreate(Sender: TObject);
var
  i: integer;
  nroPostes: integer;
  fuenteAleatoriaAux: TFuenteAleatoria_Borne;
begin
  utilidades.AgregarFormatoFecha(LFIni);

  self.IntFicha.cells[0, 0] := rsPotenciaMinima;
  self.IntFicha.cells[0, 1] := rsPotenciaMaxima;
  self.IntFicha.cells[0, 2] := rsCostoVariablePotenciaMinima;
  self.IntFicha.cells[0, 3] := rsCostoVariable;

  nroPostes := sala.globs.NPostes;


  self.IntFicha.cells[0, 4] := rsCoeficienteDisponibilidadFortuita;
  self.IntFicha.cells[0, 5] := rsTiempoDeReparacionH;

  utilidades.AutoSizeCol(IntFicha, 0);
end;


procedure TEditarFichaSolarTermico.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaSolarTermico.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);

end;

procedure TEditarFichaSolarTermico.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TSolartermico);
end;

end.
