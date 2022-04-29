unit ueditarTSolarTermico;

  {$MODE Delphi}

interface

uses
 // Windows,
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids,
  uEditarActorConFichas,
  uFichasLPD,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uConstantesSimSEE,
  xMatDefs,
  usolartermico,uEditarFichaGTer_solartermico_Fuentes,
  uFuentesAleatorias,uBaseAltasEditores,
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

  { TEditarTSolarTermico }

  TEditarTSolarTermico = class(TEditarActorConFichas)
    btEditarForzamientos: TButton;
    cbCleanDevelopmentMechanism: TCheckBox;
    cbLowCostMustRun: TCheckBox;
    cb_CalcularGradienteDeInversion: TCheckBox;
    eTonCO2xMWh: TEdit;
    GrillaPotencias: TStringGrid;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label11: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFichas: TLabel;
    CBNodo: TComboBox;
    sgFichas: TStringGrid;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BAgregarFicha: TButton;
    BGuardar: TButton;
    BCancelar: TButton;
    BEditorDeUnidades: TButton;
    BVerExpandida: TButton;
    BAyuda: TButton;
    procedure btEditarForzamientosClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure ComboFuentesCloseUp(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GrillaPotenciasDrawCell(Sender: TObject; ACol, ARow: integer;
      Rect: TRect; State: TGridDrawState);
    procedure GrillaPotenciasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure GrillaPotenciasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure GrillaPotenciasMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure sgFichasMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  protected
    function editarFuentesAleatorias(Sender: TStringGrid; fila: integer): boolean;
    function validarGrillaLlena(grilla: TStringGrid): boolean;
  private
    Generador: TSolartermico;
    tiposColsUnidades: TDAOfTTipoColumna;
    sala: TSalaDeJuego;
    listaFuentesAleatoriasPotencias: TListaDeCosas;
    fichaAux: TFichaSolarTermico;
    ficha: TFichaLPD;
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;

  end;

implementation

uses SimSEEEditMain;

{$R *.lfm}

constructor TEditarTSolarTermico.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TSolartermico;
  i:integer;
  nroPostes: integer;
  fuenteAleatoriaAux: TFuenteAleatoria_Borne;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);

  utilidades.initListado(GrillaPotencias, [rsPoste, rsFuenteAleatoria,
    rsBorne, encabezadoBTEditar], tiposColsUnidades, False);
  self.sala := sala;
  fichaAux := ficha as TFichaSolarTermico;
  Generador := cosaConNombre as TSolarTermico;

  listaFuentesAleatoriasPotencias :=
    TListaDeCosas.Create(capa, 'ListaDeFuentesAleatoriasPotencias');

  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := TSolartermico(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaSolartermico, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    cb_CalcularGradienteDeInversion.Checked:= actor.flg_CalcularGradienteDeInversion;


    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    eTonCO2xMWh.Text := FloatToStr(actor.TonCO2xMWh);
    cbLowCostMustRun.Checked := actor.LowCostMustRun_;
    cbCleanDevelopmentMechanism.Checked := actor.CleanDevelopmentMechanism;

     for i := 0 to sala.globs.NPostes - 1 do
    begin
      if actor.fuentesAleatoriasPotenciasPorPoste.Count > i then
      begin
        listaFuentesAleatoriasPotencias.Add(
          actor.fuentesAleatoriasPotenciasPorPoste.items[i]);
      end
      else
      begin
        listaFuentesAleatoriasPotencias.Add(nil);
      end;

    end;

  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaSolarTermico, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    cb_CalcularGradienteDeInversion.Checked:= False;

    eTonCO2xMWh.Text := FloatToStr(0.0);
    cbLowCostMustRun.Checked := True;
    cbCleanDevelopmentMechanism.Checked := False;
    for i := 0 to sala.globs.NPostes - 1 do
    begin
      listaFuentesAleatoriasPotencias.Add(nil);
    end;

   end;

end;

function TEditarTSolarTermico.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and validarEditFloat(eTonCO2xMWh,
    -1000, 1000000)and validarGrillaLlena(grillaPotencias);
end;

procedure TEditarTSolarTermico.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTSolarTermico.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTSolarTermico.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTSolarTermico.BGuardarClick(Sender: TObject);
var
  actor: TSolarTermico;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TSolarTermico.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades,
        lpd, valorCBNodo(CBNodo),
        cb_CalcularGradienteDeInversion.Checked,
        StrToFloat(eTonCO2xMWh.Text),
        cbLowCostMustRun.Checked, cbCleanDevelopmentMechanism.Checked,listaFuentesAleatoriasPotencias);
      actor := TSolarTermico(cosaConNombre);
    end
    else
    begin
      actor := TSolarTermico(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      if actor.lpdUnidades <> nil then actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      if actor.lpd <> nil then actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.flg_CalcularGradienteDeInversion:= cb_CalcularGradienteDeInversion.Checked;
      actor.TonCO2xMWh := StrToFloat(eTonCO2xMWh.Text);
      actor.LowCostMustRun_ := cbLowCostMustRun.Checked;
      actor.CleanDevelopmentMechanism := cbCleanDevelopmentMechanism.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTSolarTermico.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTSolarTermico.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTSolarTermico.ComboFuentesCloseUp(Sender: TObject);
begin
  inherited;
  TComboBox(Sender).Visible := False;
end;

procedure TEditarTSolarTermico.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTSolarTermico.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;


procedure TEditarTSolarTermico.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTSolarTermico.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarTSolarTermico.FormCreate(Sender: TObject);
var
  i: integer;
  nroPostes: integer;
  fuenteAleatoriaAux: TFuenteAleatoria_Borne;

begin

  nroPostes := sala.globs.NPostes;
  self.GrillaPotencias.RowCount := nroPostes + 1;

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
  end;

  utilidades.AutoSizeCol(GrillaPotencias, 0);
end;

procedure TEditarTSolarTermico.GrillaPotenciasDrawCell(Sender: TObject;
  ACol, ARow: integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  if ACol = 3 then
    utilidades.listadoDrawCell(
      Sender, ACol, ARow, Rect, State, TC_btEditar, nil, iconos);
end;

procedure TEditarTSolarTermico.GrillaPotenciasMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEditarTSolarTermico.GrillaPotenciasMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: integer);
begin
  utilidades.ListadoMouseMove(Sender, Shift, X, Y, tiposColsUnidades);
end;

procedure TEditarTSolarTermico.sgFichasMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TEditarTSolarTermico.GrillaPotenciasMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  res: TTipoColumna;
begin
  res := utilidades.ListadoMouseUp(Sender, Button, Shift, X, Y, tiposColsUnidades);
  case res of
    TC_btEditar: editarFuentesAleatorias(TStringGrid(Sender), TStringGrid(Sender).row);
  end;
end;

function TEditarTSolarTermico.editarFuentesAleatorias(Sender: TStringGrid;
  fila: integer): boolean;
var
  form: TEditarFichaGTer_solartermico_Fuentes;
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
  end;

  res := False;
  form := TEditarFichaGTer_solartermico_Fuentes.Create(self, Generador,
    fichaAux, sala, fuenteAleatoria, borne);
  if form.ShowModal = mrOk then
  begin
    fuenteAleatoria := form.darFuenteAleatoria();
    borne := form.darBorne();
    fuenteAleatoriaConBorne :=
      TFuenteAleatoria_Borne.Create(capa, fuenteAleatoria, borne);
    if Sender.Name = 'GrillaPotencias' then
    begin
      listaFuentesAleatoriasPotencias.items[fila - 1] := fuenteAleatoriaConBorne;
      GrillaPotencias.Cells[1, fila] := fuenteAleatoria.nombre;
      GrillaPotencias.Cells[2, fila] := borne;
    end;

    res := True;
  end;
  form.Free;
  Result := res;

end;

function TEditarTSolarTermico.validarGrillaLlena(grilla: TStringGrid): boolean;
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
