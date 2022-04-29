unit uEditarTDemanda01;

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
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
  udemandas01,
  uDemandas;

type

  { TEditarTDemanda01 }

  TEditarTDemanda01 = class(TEditarActorConFichas)
    cbSumarParaPostizar: TCheckBox;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFichas: TLabel;
    LEscalonesdeFalla: TLabel;
    LNEscalones: TLabel;
    LFuenteDeAportes: TLabel;
    LBorne: TLabel;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    CBNodo: TComboBox;
    sgFichas: TStringGrid;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BAgregarFicha: TButton;
    BGuardar: TButton;
    BCancelar: TButton;
    sgFalla: TStringGrid;
    EditTamTablaFalla: TEdit;
    BEditorDeUnidades: TButton;
    BVerExpandida: TButton;
    CBFuente: TComboBox;
    CBBorne: TComboBox;
    BAyuda: TButton;
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    chkSumarFuentePotencia: TCheckBox;
    procedure BVerExpandidaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
    procedure CBBorneChange(Sender: TObject);
    procedure EditTamTablaFallaExit(Sender: TObject);
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
    procedure CBBorneIndicePreciosCombustibleChange(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
  private
    procedure cambioTamTablaFalla;
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;
{$R *.lfm}

constructor TEditarTDemanda01.Create(AOwner: TComponent; sala: TSalaDeJuego;
  tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TDemanda01;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);
  inicializarCBNodos(CBNodo, False);
  inicializarCBFuente(CBFuente, CBBorne, True);
  inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  if cosaConNombre <> nil then
  begin
    actor := TDemanda01(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaDemanda01, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    setCBNodo(CBNodo, actor.Nodo);
    setCBFuente(CBFuente, CBBorne, actor.fuente, actor.nombreBorne);
    chkSumarFuentePotencia.Checked := actor.SumarEnergiaHr;
    cbSumarParaPostizar.Checked:= actor.flg_SumarParaPostizado;
    setTablaFalla(sgFalla, EditTamTablaFalla, actor.falla_profundidad,
      actor.falla_costo_0, cambioTamTablaFalla);
    setCBFuente(CBFuenteIndicePreciosPorCombustible, CBBorneIndicePreciosCombustible,
      actor.icf_Fuente, actor.icf_NombreBorne);
  end
  else
  begin
    cbSumarParaPostizar.Checked:= true;
    inicializarComponentesLPD(nil, TFichaDemanda01, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    setTablaFalla(sgFalla, EditTamTablaFalla, ProfundidadEscalonesDeFallaPorDefecto,
      CostoEscalonesDeFallaPorDefecto, cambioTamTablaFalla);
  end;
end;

function TEditarTDemanda01.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarEditFecha(EFNac) and inherited validarEditFecha(EFMuerte) and
    inherited validarCBNodo(CBNodo) and inherited validarCBFuente(CBFuente,
    CBBorne, 0) and inherited validarEditInt(EditTamTablaFalla, 1, MAXINT) and
    inherited validarTablaFalla(sgFalla) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0);
end;

procedure TEditarTDemanda01.CBBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne);
end;

procedure TEditarTDemanda01.CBBorneIndicePreciosCombustibleChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarTDemanda01.CBFuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

procedure TEditarTDemanda01.CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorneIndicePreciosCombustible);
end;

procedure TEditarTDemanda01.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTDemanda01.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTDemanda01.BVerExpandidaClick(Sender: TObject);
begin

end;


procedure TEditarTDemanda01.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTDemanda01.EditTamTablaFallaExit(Sender: TObject);
begin
  inherited EditTamTablaFallaExit(Sender, sgFalla, cambioTamTablaFalla);
end;

procedure TEditarTDemanda01.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TEditarTDemanda01.sgGetEditText(Sender: TObject; ACol, ARow: integer;
  var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarTDemanda01.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarTDemanda01.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarTDemanda01.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTDemanda01.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTDemanda01.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTDemanda01.BGuardarClick(Sender: TObject);
var
  actor: TDemanda01;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TDemanda01.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo), getFallaProfundidad(sgFalla), getFallaCosto(sgFalla),
        valorCBFuente(CBFuente), valorCBString(CBBorne),
        chkSumarFuentePotencia.Checked,
        cbSumarParaPostizar.Checked,
        valorCBFuente(CBFuenteIndicePreciosPorCombustible),
        valorCBString(CBBorneIndicePreciosCombustible));
      actor := TDemanda01(cosaConNombre);
    end
    else
    begin
      actor := TDemanda01(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.Nodo := valorCBNodo(CBNodo);
      actor.falla_profundidad := getFallaProfundidad(sgFalla);
      actor.falla_costo_0 := getFallaCosto(sgFalla);
      actor.fuente := valorCBFuente(CBFuente);
      actor.nombreBorne := valorCBString(CBBorne);
      actor.SumarEnergiaHr := chkSumarFuentePotencia.Checked;
      actor.flg_SumarParaPostizado:= cbSumarParaPostizar.Checked;
      actor.icf_Fuente := valorCBFuente(CBFuenteIndicePreciosPorCombustible);
      actor.icf_NombreBorne := valorCBString(CBBorneIndicePreciosCombustible);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTDemanda01.cambioTamTablaFalla;
begin
  LIndicePreciosPorCombustible.Left := sgFalla.Left + sgFalla.Width + 5;
  LBornePreciosPorCombustible.Left := LIndicePreciosPorCombustible.Left;
  CBFuenteIndicePreciosPorCombustible.Left :=
    LIndicePreciosPorCombustible.Left + LIndicePreciosPorCombustible.Width + 5;
  CBBorneIndicePreciosCombustible.Left := CBFuenteIndicePreciosPorCombustible.Left;
end;

end.
