unit uEditarFichaGTer_Basico_PyCVariable;


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
  ugter_basico_PyCVariable, ucosaConNombre, uFichasLPD, uBaseAltasEditores,
  uOpcionesSimSEEEdit,
  uEditarFichaGTer_Basico_PyCVariable_Fuentes, uCosa;

resourcestring
  rsPoste = 'Poste';
  rsFuenteAleatoria = 'Fuente aleatoria';
  rsBorne = 'Borne';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita[p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación[horas]';
  mesDebeSeleccionarUnaFuenteA = 'Debe seleccionar una fuente aleatoria';

type

  { TEditarFichaGTer_Basico_PyCVariable }

  TEditarFichaGTer_Basico_PyCVariable = class(TBaseEditoresFichasGeneradores)
    ComboFuentes: TComboBox;
    ePagoPorEnergia: TEdit;
    ePagoPorDisponibilidad: TEdit;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
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
    CBRestrEMax: TCheckBox;
    ERestrEMax: TEdit;
    BAyuda: TButton;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    GrillaPotencias: TStringGrid;
    IntFicha: TStringGrid;
    Label1: TLabel;
    GrillaCostosVariables: TStringGrid;
    Label2: TLabel;

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
    Generador: TGTer_Basico_PyCVariable;
    tiposColsUnidades: TDAOfTTipoColumna;
    fichaAux: TFichaGTer_Basico_PyCVariable;
    sala: TSalaDeJuego;
    listaFuentesAleatoriasPotencias: TListaDeCosas;
    listaFuentesAleatoriasCostosVariables: TListaDeCosas;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichaGTer_Basico_PyCVariable.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Generador := cosaConNombre as TGTer_Basico_PyCVariable;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  utilidades.initListado(GrillaPotencias, [rsPoste, rsFuenteAleatoria,
    rsBorne, encabezadoBTEditar], tiposColsUnidades, False);
  fichaAux := ficha as TFichaGTer_Basico_PyCVariable;
  self.sala := sala;

  listaFuentesAleatoriasPotencias :=
    TListaDeCosas.Create(capa, 'ListaDeFuentesAleatoriasPotencias');
  listaFuentesAleatoriasCostosVariables :=
    TListaDeCosas.Create(capa, 'ListaDeFuentesAleatoriasCostosVariables');

  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaGTer_Basico_PyCVariable;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);

    self.IntFicha.cells[1, 0] := FloatToStr(fichaAux.disp);
    self.IntFicha.cells[1, 1] := FloatToStr(fichaAux.tRepHoras);

    for i := 0 to sala.globs.NPostes - 1 do
    begin
      if fichaAux.fuentesAleatoriasPotenciasPorPoste.Count > i then
      begin
        listaFuentesAleatoriasPotencias.Add(
          fichaAux.fuentesAleatoriasPotenciasPorPoste.items[i]);
        listaFuentesAleatoriasCostosVariables.Add(
          fichaAux.fuentesAleatoriasCostosVariablesPorPoste.items[i]);
      end
      else
      begin
        listaFuentesAleatoriasPotencias.Add(nil);
        listaFuentesAleatoriasCostosVariables.Add(nil);
      end;
    end;

    self.ePagoPorDisponibilidad.Text :=
      FloatToStr(fichaAux.PagoPorDisponibilidad_USD_MWh);
    self.ePagoPorEnergia.Text := FloatToStr(fichaAux.PagoPorEnergia_USD_MWh);

    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
      fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited setCBFuente(CBFuenteIndicePreciosPorCombustible,
      CBBorneIndicePreciosCombustible, fichaAux.indicePreciosPorCombustible,
      fichaAux.bornePreciosPorCombustible);
  end
  else
  begin
    self.EFIni.Text := '';
    for i := 0 to self.IntFicha.RowCount - 1 do
      self.IntFicha.cells[1, i] := '';
    inherited initCBRestriccion(False, CBRestrEMax, 0, ERestrEMax);

    for i := 0 to sala.globs.NPostes - 1 do
    begin
      listaFuentesAleatoriasPotencias.Add(nil);
      listaFuentesAleatoriasCostosVariables.Add(nil);
    end;
    self.ePagoPorDisponibilidad.Text := FloatToStr(0.0);
    self.ePagoPorEnergia.Text := FloatToStr(0.0);
  end;
end;

function TEditarFichaGTer_Basico_PyCVariable.validarFormulario(): boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad) and inherited validarTablaNReals_(IntFicha) and
    inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0) and validarGrillaLlena(
    grillaPotencias) and validarGrillaLlena(grillaCostosVariables)
    and validarEditFloat( ePagoPorDisponibilidad ) and validarEditFloat( ePagoPorEnergia);
end;


procedure TEditarFichaGTer_Basico_PyCVariable.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.BGuardarClick(Sender: TObject);
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

    ficha := TFichaGTer_Basico_PyCVariable.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
      valorCBFuente(CBFuenteIndicePreciosPorCombustible), valorCBString(
      CBBorneIndicePreciosCombustible), StrToFloat(self.IntFicha.cells[1, 0]),
      CBRestrEMax.Checked, restrEMax, StrToFloat(self.IntFicha.Cells[1, 1]),
      listaFuentesAleatoriasPotencias, listaFuentesAleatoriasCostosVariables,
      StrToFloat(self.ePagoPorDisponibilidad.Text),
      StrToFloat(self.ePagoPorEnergia.Text));
    ModalResult := mrOk;
   {     end
  else
       begin
       ShowMessage(mesYaExisteFichaEnFecha);
       end     }
  end;
end;

procedure TEditarFichaGTer_Basico_PyCVariable.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.ComboFuentesCloseUp(Sender: TObject);
begin
  inherited;
  TComboBox(Sender).Visible := False;
end;

procedure TEditarFichaGTer_Basico_PyCVariable.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.FormCreate(Sender: TObject);
var
  i: integer;
  nroPostes: integer;
  fuenteAleatoriaAux: TFuenteAleatoria_Borne;
begin
  utilidades.AgregarFormatoFecha(LFIni);

  nroPostes := sala.globs.NPostes;
  self.GrillaPotencias.RowCount := nroPostes + 1;
  self.GrillaCostosVariables.RowCount := nroPostes + 1;

  for i := 0 to nroPostes - 1 do
  begin
    //Se inicializa la grilla de potencias
    self.GrillaPotencias.cells[0, i + 1] := 'Poste ' + FloatToStr(i + 1);

    fuenteAleatoriaAux := TFuenteAleatoria_Borne(
      listaFuentesAleatoriasPotencias.items[i]);
    if fuenteAleatoriaAux <> nil then
    begin
      self.GrillaPotencias.Cells[1, i + 1] := fuenteAleatoriaAux.fuente.nombre;
      self.GrillaPotencias.Cells[2, i + 1] := fuenteAleatoriaAux.borne;
    end
    else
    begin
      self.GrillaPotencias.Cells[1, i + 1] := '<Ninguna>';
      self.GrillaPotencias.Cells[2, i + 1] := '';
    end;



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

  utilidades.AutoSizeCol(GrillaPotencias, 0);

  utilidades.AutoSizeCol(GrillaCostosVariables, 0);

  self.IntFicha.cells[0, 0] := rsCoeficienteDisponibilidadFortuita;
  self.IntFicha.cells[0, 1] := rsTiempoDeReparacionH;

  utilidades.AutoSizeCol(IntFicha, 0);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.GrillaPotenciasDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  if ACol = 3 then
    utilidades.listadoDrawCell(
      Sender, ACol, ARow, Rect, State, TC_btEditar, nil, iconos);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.GrillaPotenciasMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.GrillaPotenciasMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsUnidades);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.GrillaPotenciasMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsUnidades);
  case res of
    TC_btEditar: editarFuentesAleatorias(TStringGrid(Sender), TStringGrid(Sender).row);
  end;
end;

procedure TEditarFichaGTer_Basico_PyCVariable.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaGTer_Basico_PyCVariable.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);

end;

function TEditarFichaGTer_Basico_PyCVariable.editarFuentesAleatorias(
  Sender: TStringGrid; fila: integer): boolean;
var
  form: TEditarFichaGTer_Basico_PyCVariable_Fuentes;
  fuenteAleatoria: TFuenteAleatoria;
  borne: string;
  fuenteAleatoriaConBorne: TFuenteAleatoria_Borne;
  res: boolean;
begin
 {
  res:= false;
  if fila = 0 then
    ficha := NIL
  else
    ficha := TFichaUnidades(lista[fila - 1]);
 }

  fuenteAleatoria := nil;
  borne := '';
  if Sender.Name = 'GrillaPotencias' then
  begin
    fuenteAleatoriaConBorne :=
      listaFuentesAleatoriasPotencias.items[fila - 1] as TFuenteAleatoria_Borne;
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
  form := TEditarFichaGTer_Basico_PyCVariable_Fuentes.Create(self,
    Generador, fichaAux, sala, fuenteAleatoria, borne);
  if form.ShowModal = mrOk then
  begin
    fuenteAleatoria := form.darFuenteAleatoria();
    borne := form.darBorne();
    fuenteAleatoriaConBorne := TFuenteAleatoria_Borne.Create(capa, fuenteAleatoria, borne);
    if Sender.Name = 'GrillaPotencias' then
    begin
      listaFuentesAleatoriasPotencias.items[fila - 1] := fuenteAleatoriaConBorne;
      GrillaPotencias.Cells[1, fila] := fuenteAleatoria.nombre;
      GrillaPotencias.Cells[2, fila] := borne;
    end
    else
    begin
      listaFuentesAleatoriasCostosVariables.items[fila - 1] := fuenteAleatoriaConBorne;
      GrillaCostosVariables.Cells[1, fila] := fuenteAleatoria.nombre;
      GrillaCostosVariables.Cells[2, fila] := borne;
    end;
    //form.darFicha
    //    lista.add(form.darFicha());
    //    actualizarTablaUnidades;
    //guardado := false;
    res := True;
  end;
  form.Free;
  Result := res;

end;

function TEditarFichaGTer_Basico_PyCVariable.validarGrillaLlena(
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
