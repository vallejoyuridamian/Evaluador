unit uEditarTDemandaDetallada;
{$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uConstantesSimSEE,
  xMatDefs,
  udemandadetallada,
  udatoshorariosdetallados,
  uCrearBinDatosHorarios,
  uopencalc,
  uopencalcexportimport,
  uDemandas;

type

  { TEditarTDemandaDetallada }

  TEditarTDemandaDetallada = class(TBaseEditoresActores)
    cbSumarParaPostizar: TCheckBox;
    chkSumarFuentePotencia: TCheckBox;
    eFactorReserva: TLabeledEdit;
    LNombre: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LNodo: TLabel;
    LEscalonesdeFalla: TLabel;
    LNEscalones: TLabel;
    LNarch: TLabel;
    LFuenteDeAportes: TLabel;
    LBorne: TLabel;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    CBNodo: TComboBox;
    sgFalla: TStringGrid;
    EditTamTablaFalla: TEdit;
    ENarch: TEdit;
    BExaminar: TButton;
    BEditorDeUnidades: TButton;
    BCrear: TButton;
    CBFuente: TComboBox;
    CBBorne: TComboBox;
    BAyuda: TButton;
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    OpenDialog1: TOpenDialog;

    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
    procedure CBBorneChange(Sender: TObject);
    procedure EditTamTablaFallaExit(Sender: TObject);
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
    procedure CBBorneIndicePreciosCombustibleChange(Sender: TObject);
    procedure BExaminarClick(Sender: TObject);
    procedure BCrearClick(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
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

constructor TEditarTDemandaDetallada.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TDemandaDetallada;
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
    actor := TDemandaDetallada(cosaConNombre);

    EditNombre.Text := actor.nombre;
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    setCBNodo(CBNodo, actor.Nodo);
    chkSumarFuentePotencia.Checked := actor.SumarEnergiaHr;
    cbSumarParaPostizar.Checked:= actor.flg_SumarParaPostizado;
    eFactorReserva.Text:= FloatToStr( actor.fReserva );
    setCBFuente(CBFuente, CBBorne, actor.fuente, actor.nombreBorne);
    setTablaFalla(sgFalla, EditTamTablaFalla, actor.falla_profundidad,
      actor.falla_costo_0, cambioTamTablaFalla);
    setCBFuente(CBFuenteIndicePreciosPorCombustible, CBBorneIndicePreciosCombustible,
      actor.icf_Fuente, actor.icf_NombreBorne);
    ENarch.Text := actor.ArchiDatos.archi;
    OpenDialog1.InitialDir := getCurrentDrive + ExtractFilePath(ENarch.Text);
    OpenDialog1.Filter := 'Archivos Binarios (*.bin)|*.bin|Todos los Archivos (*.*)|*.*';
  end
  else
  begin
    cbSumarParaPostizar.checked:= true;
    eFactorReserva.Text:= FloatToStr( 0.0 );
    setTablaFalla(sgFalla, EditTamTablaFalla, ProfundidadEscalonesDeFallaPorDefecto,
      CostoEscalonesDeFallaPorDefecto, cambioTamTablaFalla);
    OpenDialog1.InitialDir := getDir_DatosComunes;
    OpenDialog1.Filter := 'Archivos Binarios (*.bin)|*.bin|Todos los Archivos (*.*)|*.*';
  end;
end;

function TEditarTDemandaDetallada.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarEditFecha(EFNac) and inherited validarEditFecha(EFMuerte) and
    inherited validarCBNodo(CBNodo) and inherited validarCBFuente(CBFuente,
    CBBorne, 0) and inherited validarEditInt(EditTamTablaFalla, 1, MAXINT) and
    validarEditFloat( eFactorReserva ) and
    inherited validarTablaFalla(sgFalla) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0) and inherited validarEditNArch(ENarch);
end;

procedure TEditarTDemandaDetallada.cambioTamTablaFalla;
begin
  LIndicePreciosPorCombustible.Left := sgFalla.Left + sgFalla.Width + 5;
  LBornePreciosPorCombustible.Left := LIndicePreciosPorCombustible.Left;
  CBFuenteIndicePreciosPorCombustible.Left :=
    LIndicePreciosPorCombustible.Left + LIndicePreciosPorCombustible.Width + 5;
  CBBorneIndicePreciosCombustible.Left := CBFuenteIndicePreciosPorCombustible.Left;
  if sgFalla.Width - ENarch.Left > maxAnchoTablaMediana then
  begin
    ENarch.Width := sgFalla.Width - ENarch.Left;
    BExaminar.Left := ENarch.Left + ENarch.Width + 5;
    BCrear.Left := BExaminar.Left + BCrear.Width + 5;
  end;
end;

procedure TEditarTDemandaDetallada.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTDemandaDetallada.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTDemandaDetallada.BCrearClick(Sender: TObject);
var
  form: TCrearBinDatosHorarios;
  archi: string;

begin
  archi := ENarch.Text;
  if not fileexists(archi) then
  begin
    form := TCrearBinDatosHorarios.Create(self, sala.globs.fechaIniOpt.AsDt,
      sala.globs.fechaFinOpt.AsDt);
  end
  else
  begin
    form := TCrearBinDatosHorarios.Create(self, archi );
  end;
  if form.ShowModal = mrOk then
    ENarch.Text := form.darNombreArch;
  form.Free;

end;

procedure TEditarTDemandaDetallada.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTDemandaDetallada.BExaminarClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    OpenDialog1.FileName := OpenDialog1.FileName;
    ENarch.Text := OpenDialog1.FileName;
  end;
end;

procedure TEditarTDemandaDetallada.BGuardarClick(Sender: TObject);
var
  actor: TDemandaDetallada;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TDemandaDetallada.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades,
        valorCBNodo(CBNodo), getFallaProfundidad(sgFalla),
        getFallaCosto(sgFalla), ENarch.Text, valorCBFuente(CBFuente),
        valorCBString(CBBorne), chkSumarFuentePotencia.Checked,
        cbSumarParaPostizar.checked,
        valorCBFuente(CBFuenteIndicePreciosPorCombustible),
        valorCBString(CBBorneIndicePreciosCombustible),
        StrToFloat( eFactorReserva.Text ));
      actor := TDemandaDetallada(cosaConNombre);
    end
    else
    begin
      actor := TDemandaDetallada(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.Nodo := valorCBNodo(CBNodo);
      actor.falla_profundidad := getFallaProfundidad(sgFalla);
      actor.falla_costo_0 := getFallaCosto(sgFalla);
      actor.ArchiDatos.archi := ENarch.Text;
      actor.fuente := valorCBFuente(CBFuente);
      actor.nombreBorne := valorCBString(CBBorne);
      actor.SumarEnergiaHr := chkSumarFuentePotencia.Checked;
      actor.flg_SumarParaPostizado:= cbSumarParaPostizar.checked;
      actor.fReserva:= StrToFloat( eFactorReserva.Text );
      actor.icf_Fuente := valorCBFuente(CBFuenteIndicePreciosPorCombustible);
      actor.icf_NombreBorne := valorCBString(CBBorneIndicePreciosCombustible);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTDemandaDetallada.CBBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne);
end;

procedure TEditarTDemandaDetallada.CBBorneIndicePreciosCombustibleChange(
  Sender: TObject);
begin
  inherited CBBorneChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarTDemandaDetallada.CBFuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

procedure TEditarTDemandaDetallada.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorneIndicePreciosCombustible);
end;

procedure TEditarTDemandaDetallada.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTDemandaDetallada.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTDemandaDetallada.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTDemandaDetallada.EditTamTablaFallaExit(Sender: TObject);
begin
  inherited EditTamTablaFallaExit(Sender, sgFalla, cambioTamTablaFalla);
end;

procedure TEditarTDemandaDetallada.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
