unit uEditarTBaseMercadoSpot;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls,
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
  uBaseMercadoSpot;

type
  TEditarTBaseMercadoSpot = class(TEditarActorConFichas)
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFuenteDeAportes: TLabel;
    LBorne: TLabel;
    LFichas: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    CBFuente: TComboBox;
    CBBorne: TComboBox;
    sgFichas: TStringGrid;
    BAgregarFicha: TButton;
    BVerExpandida: TButton;
    BAyuda: TButton;
    BEditorDeUnidades: TButton;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
    procedure CBBorneChange(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarTBaseMercadoSpot.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TBaseMercadoSpot;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);
  inicializarCBFuente(CBFuente, CBBorne, False);

  if cosaConNombre <> nil then
  begin
    actor := TBaseMercadoSpot(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TClaseDeMercadoSpot(
      tipoCosa).TipoFichaLPD, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    setCBFuente(CBFuente, CBBorne, actor.fuente, actor.nombreBorne);
  end
  else
    inicializarComponentesLPD(nil, TClaseDeMercadoSpot(tipoCosa).TipoFichaLPD, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
end;

function TEditarTBaseMercadoSpot.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and inherited validarCBFuente(
    CBFuente, CBBorne, 0);
end;

procedure TEditarTBaseMercadoSpot.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTBaseMercadoSpot.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTBaseMercadoSpot.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTBaseMercadoSpot.BGuardarClick(Sender: TObject);
var
  actor: TBaseMercadoSpot;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TClaseDeMercadoSpot(tipoCosa).Create(
        capa,
        EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo), valorCBFuente(CBFuente), valorCBString(CBBorne));
      actor := TBaseMercadoSpot(cosaConNombre);
    end
    else
    begin
      actor := TBaseMercadoSpot(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.fuente := valorCBFuente(CBFuente);
      actor.nombreBorne := valorCBString(CBBorne);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTBaseMercadoSpot.CBBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne);
end;

procedure TEditarTBaseMercadoSpot.CBFuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

procedure TEditarTBaseMercadoSpot.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTBaseMercadoSpot.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTBaseMercadoSpot.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTBaseMercadoSpot.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
