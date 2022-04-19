unit uEditarFichaMercadoSpot_postizado;
{$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, uconstantesSimSEE,
  usalasdejuego, uBaseEditoresFichasGeneradores, xMatDefs,
  uSalasDeJuegoParaEditor, uverdoc, uFuentesAleatorias, utilidades,
  uMercadoSpot_postizado, ucosaConNombre, uFichasLPD, uBaseAltasEditores,
  uOpcionesSimSEEEdit,
  uEditarFichaMercadoSpot_postizado_Fuentes, uCosa;

resourcestring
  rsPoste = 'Poste';
  rsFuenteAleatoria = 'Fuente aleatoria';
  rsBorne = 'Borne';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';
  mesDebeSeleccionarUnaFuenteA = 'Debe seleccionar una fuente aleatoria';

type

  { TEditarFichaMercadoSpot_postizado }

  TEditarFichaMercadoSpot_postizado = class(TBaseEditoresFichasGeneradores)
    cbTopeSaleActivo: TCheckBox;
    cbTopeEntraActivo: TCheckBox;
    cbActivarDeltas: TCheckBox;
    ComboFuentes: TComboBox;
    eDeltaExpo_USD_MWh: TEdit;
    eDeltaImpo_USD_MWh: TEdit;
    eTopeEntra: TEdit;
    eTopeSale: TEdit;
    EditPMins: TEdit;
    EditPMaxs: TEdit;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    PMins: TLabel;
    PMaxs: TLabel;
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
    Label1: TLabel;
    GrillaCostosVariables: TStringGrid;
    Label2: TLabel;

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
    procedure GrillaPotenciasDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure GrillaPotenciasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure GrillaPotenciasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure GrillaPotenciasMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
  protected
    function validarFormulario(): boolean; override;
    function editarFuentesAleatorias(Sender: TStringGrid; fila: integer): boolean;
    function validarGrillaLlena(grilla: TStringGrid): boolean;
  private
    Generador: TMercadoSpot_postizado;
    tiposColsUnidades: TDAOfTTipoColumna;
    fichaAux: TFichaMercadoSpot_postizado;
    sala: TSalaDeJuego;
    Pmin, Pmax: TDAofNReal;
    listaFuentesAleatoriasCostosVariables: TListaDeCosas;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

{$R *.lfm}

constructor TEditarFichaMercadoSpot_postizado.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
  s: string;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TMercadoSpot_postizado;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);

  utilidades.initListado(GrillaCostosVariables,
    [rsPoste, rsFuenteAleatoria, rsBorne, encabezadoBTEditar], tiposColsUnidades, False);
  fichaAux := ficha as TFichaMercadoSpot_postizado;
  self.sala := sala;

  listaFuentesAleatoriasCostosVariables :=
    TListaDeCosas.Create(capa, 'ListaDeFuentesAleatoriasCostosVariables');

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaMercadoSpot_postizado;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);

    self.IntFicha.cells[1, 0] := FloatToStr(fichaAux.fdisp);
    self.IntFicha.cells[1, 1] := FloatToStr(fichaAux.tRepHoras);

    for i := 0 to sala.globs.NPostes - 1 do
    begin
      if fichaAux.fuentesAleatoriasCostosVariablesPorPoste.Count > i then
      begin
        listaFuentesAleatoriasCostosVariables.Add(
          fichaAux.fuentesAleatoriasCostosVariablesPorPoste.items[i]);
      end
      else
      begin
        listaFuentesAleatoriasCostosVariables.Add(nil);
      end;
    end;

    EditPMins.Text := DAOfNRealToStr_(fichaAux.Pmin, 8, 1, ';');
    EditPMaxs.Text := DAOfNRealToStr_(fichaAux.PMax, 8, 1, ';');
    eTopeEntra.Text := FloatToStrF(fichaAux.topeEntra, ffFixed, 12, 2);
    cbTopeEntraActivo.Checked := fichaAux.topeEntraActivo;
    eTopeSale.Text := FloatToStrF(fichaAux.topeSale, ffFixed, 12, 2);
    cbTopeSaleActivo.Checked := fichaAux.topeSaleActivo;
    cbActivarDeltas.Checked := fichaAux.activarMargenExportador;
    eDeltaExpo_USD_MWh.Text := FloatToStrF(fichaAux.DeltaExportador, ffFixed, 12, 2);
    eDeltaImpo_USD_MWh.Text := FloatToStrF(fichaAux.DeltaImportador, ffFixed, 12, 2);
  end
  else
  begin
    self.EFIni.Text := '';
    for i := 0 to self.IntFicha.RowCount - 1 do
      self.IntFicha.cells[1, i] := '';
    for i := 0 to sala.globs.NPostes - 1 do
    begin
      listaFuentesAleatoriasCostosVariables.Add(nil);
    end;

    s := '0';
    for i := 1 to sala.globs.NPostes - 1 do
      s := s + '; 0';
    EditPMins.Text := s;
    EditPMaxs.Text := s;
    eTopeEntra.Text := '10000';
    cbTopeEntraActivo.Checked := False;
    eTopeSale.Text := '10000';
    cbTopeSaleActivo.Checked := False;
    cbActivarDeltas.Checked := False;
    eDeltaExpo_USD_MWh.Text := FloatToStrF(0.0, ffFixed, 12, 2);
    eDeltaImpo_USD_MWh.Text := FloatToStrF(0.0, ffFixed, 12, 2);
  end;
end;

function TEditarFichaMercadoSpot_postizado.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad) and inherited validarTablaNReals_(IntFicha) and
    validarGrillaLlena(grillaCostosVariables);

end;


procedure TEditarFichaMercadoSpot_postizado.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaMercadoSpot_postizado.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
  restrEMax: NReal;
  potencias_minimas, potencias_maximas: TDAofNReal;
  topeEntra, topeSale: NReal;
  topeEntraActivo, topeSaleActivo: boolean;

begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      periodicidad := nil
    else
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo,
        ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

    potencias_minimas := StrToDAOfNReal_(EditPMins.Text, ';');
    potencias_maximas := StrToDAOfNReal_(EditPMaxs.Text, ';');

    TopeEntra := StrToFloat(eTopeEntra.Text);
    TopeEntraActivo := cbTopeEntraActivo.Checked;
    TopeSale := StrToFloat(eTopeSale.Text);
    TopeSaleActivo := cbTopeSaleActivo.Checked;


    ficha := TFichaMercadoSpot_postizado.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
      StrToFloat(self.IntFicha.cells[1, 0]), StrToFloat(self.IntFicha.Cells[1, 1]),
      potencias_minimas, potencias_maximas,
      listaFuentesAleatoriasCostosVariables, TopeEntra, TopeEntraActivo,
      TopeSale, TopeSaleActivo, cbActivarDeltas.Checked, StrToFloat(
      self.eDeltaExpo_USD_MWh.Text), StrToFloat(self.eDeltaImpo_USD_MWh.Text));
    ModalResult := mrOk;

  end;
end;

procedure TEditarFichaMercadoSpot_postizado.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaMercadoSpot_postizado.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;


procedure TEditarFichaMercadoSpot_postizado.ComboFuentesCloseUp(Sender: TObject);
begin
  inherited;
  TComboBox(Sender).Visible := False;
end;

procedure TEditarFichaMercadoSpot_postizado.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaMercadoSpot_postizado.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaMercadoSpot_postizado.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaMercadoSpot_postizado.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, 'ht_fichamspot_postizado');
end;

procedure TEditarFichaMercadoSpot_postizado.FormCreate(Sender: TObject);
var
  i: integer;
  nroPostes: integer;
  fuenteAleatoriaAux: TFuenteAleatoria_Borne;
begin

  utilidades.AgregarFormatoFecha(LFIni);
  nroPostes := sala.globs.NPostes;
  self.GrillaCostosVariables.RowCount := nroPostes + 1;

  for i := 0 to nroPostes - 1 do
  begin

    //Se inicializa la grilla de costos variables
    self.GrillaCostosVariables.cells[0, i + 1] := 'Poste ' + FloatToStr(i + 1);

    fuenteAleatoriaAux := TFuenteAleatoria_Borne(
      listaFuentesAleatoriasCostosVariables.items[i]);
    if fuenteAleatoriaAux <> nil then
    begin
      self.GrillaCostosVariables.Cells[1, i + 1] := fuenteAleatoriaAux.fuente.nombre;
      self.GrillaCostosVariables.Cells[2, i + 1] := fuenteAleatoriaAux.borne;
    end
    else
    begin
      self.GrillaCostosVariables.Cells[1, i + 1] := '<Ninguna>';
      self.GrillaCostosVariables.Cells[2, i + 1] := '';
    end;

  end;

  utilidades.AutoSizeCol(GrillaCostosVariables, 0);

  self.IntFicha.cells[0, 0] := rsCoeficienteDisponibilidadFortuita;
  self.IntFicha.cells[0, 1] := rsTiempoDeReparacionH;

  utilidades.AutoSizeCol(IntFicha, 0);
end;

procedure TEditarFichaMercadoSpot_postizado.GrillaPotenciasDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  if ACol = 3 then
    utilidades.listadoDrawCell(
      Sender, ACol, ARow, Rect, State, TC_btEditar, nil, iconos);
end;

procedure TEditarFichaMercadoSpot_postizado.GrillaPotenciasMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditarFichaMercadoSpot_postizado.GrillaPotenciasMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsUnidades);
end;

procedure TEditarFichaMercadoSpot_postizado.GrillaPotenciasMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsUnidades);
  case res of
    TC_btEditar: editarFuentesAleatorias(TStringGrid(Sender),
        TStringGrid(Sender).row);
  end;
end;

procedure TEditarFichaMercadoSpot_postizado.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaMercadoSpot_postizado.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);

end;

function TEditarFichaMercadoSpot_postizado.editarFuentesAleatorias(Sender: TStringGrid;
  fila: integer): boolean;
var
  form: TEditarFichaMercadoSpot_postizado_Fuentes;
  fuenteAleatoria: TFuenteAleatoria;
  borne: string;
  fuenteAleatoriaConBorne: TFuenteAleatoria_Borne;
  res: boolean;
begin

  fuenteAleatoria := nil;
  borne := '';
  if Sender.Name = 'GrillaPotencias' then
  begin

    if fuenteAleatoriaConBorne <> nil then
    begin
      fuenteAleatoria := fuenteAleatoriaConBorne.fuente;
      borne := fuenteAleatoriaConBorne.borne;
    end;
  end
  else
  begin
    fuenteAleatoriaConBorne :=
      listaFuentesAleatoriasCostosVariables.items[fila - 1] as TFuenteAleatoria_Borne;
    if fuenteAleatoriaConBorne <> nil then
    begin
      fuenteAleatoria := fuenteAleatoriaConBorne.fuente;
      borne := fuenteAleatoriaConBorne.borne;
    end;
  end;

  res := False;
  form := TEditarFichaMercadoSpot_postizado_Fuentes.Create(self,
    Generador, fichaAux, sala, fuenteAleatoria, borne);
  if form.ShowModal = mrOk then
  begin
    fuenteAleatoria := form.darFuenteAleatoria();
    borne := form.darBorne();
    fuenteAleatoriaConBorne := TFuenteAleatoria_Borne.Create(capa, fuenteAleatoria, borne);
    if Sender.Name = 'GrillaCostosVariables' then
    begin
      listaFuentesAleatoriasCostosVariables.items[fila - 1] := fuenteAleatoriaConBorne;
      GrillaCostosVariables.Cells[1, fila] := fuenteAleatoria.nombre;
      GrillaCostosVariables.Cells[2, fila] := borne;
    end;

    res := True;
  end;
  form.Free;
  Result := res;
end;

function TEditarFichaMercadoSpot_postizado.validarGrillaLlena(
  grilla: TStringGrid): boolean;
var
  i: integer;
  rect: TGridRect;
begin
  Result := True;
  for i := 0 to sala.globs.NPostes - 1 do
  begin
    if grilla.Cells[1, i + 1] = '<Ninguna>' then
    begin
      rect.Top := i + 1;
      rect.Bottom := i + 1;
      rect.Left := 1;
      rect.Right := 2;
      grilla.Selection := rect;
      ShowMessage(mesDebeSeleccionarUnaFuenteA);
      grilla.SetFocus();
      Result := False;
      exit;
    end;
  end;
end;

end.
