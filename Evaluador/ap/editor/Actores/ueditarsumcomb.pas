unit ueditarsumcomb;
interface
uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids,
  uEditarActorConFichas,
  ufichasLPD,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uConstantesSimSEE,
  xMatDefs,
  uTSumComb;

type

  { TEditarsumcomb }

  TEditarsumcomb = class(TEditarActorConFichas)
    btEditarForzamientos: TButton;
    cbNodoComb: TComboBox;
    lbNodoCombA: TLabel;
    LNombre: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFichas: TLabel;
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
    procedure BAgregarFichaClick(Sender: TObject);
    procedure btEditarForzamientosClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
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

constructor TEditarsumcomb.Create(AOwner: TComponent; sala: TSalaDeJuego;
  tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TSuministroSimpleCombustible;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  inicializarCBNodosCombustible( cbNodoComb, false);

  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);

  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := TSuministroSimpleCombustible( cosaConNombre );
    inicializarComponentesLPD(actor.lpd,
      TFichaSuministroSimpleCombustible, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;


    setCBNodoCombustible(
     cbNodoComb,
      actor.NodoComb );


    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
  end
  else
  begin

    inicializarComponentesLPD(nil, TFichaSuministroSimpleCombustible, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

  end;
end;

function TEditarsumcomb.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodoCombustible(cbNodoComb) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte);
end;

procedure TEditarsumcomb.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarsumcomb.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarsumcomb.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarsumcomb.BGuardarClick(Sender: TObject);
var
  actor: TSuministroSimpleCombustible;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TSuministroSimpleCombustible.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades,
        lpd,
        valorCBNodoCombustible(CBNodoComb));
      actor := TSuministroSimpleCombustible(cosaConNombre);
    end
    else
    begin
      actor := TSuministroSimpleCombustible(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.NodoComb := valorCBNodoCombustible(cbNodoComb);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarsumcomb.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarsumcomb.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarsumcomb.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;

procedure TEditarsumcomb.BAgregarFichaClick(Sender: TObject);
begin
  inherited BAgregarFichaClick(Sender);
end;

procedure TEditarsumcomb.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarsumcomb.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
