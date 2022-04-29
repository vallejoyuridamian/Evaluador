unit uEditarTArcoCombustible;
  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls,
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
  uArcoCombustible;

type

  { TEditarTArcoCombustible }

  TEditarTArcoCombustible = class(TEditarActorConFichas)
    LNombre: TLabel;
    LNodoCombustible: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LNodoCombustibleSalida: TLabel;
    LFichas: TLabel;
    cbNodoCombustibleEntrada: TComboBox;
    BGuardar: TButton;
    BCancelar: TButton;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    cbNodoCombustibleSalida: TComboBox;
    BEditorDeUnidades: TButton;
    sgFichas: TStringGrid;
    BAgregarFicha: TButton;
    BVerExpandida: TButton;
    BAyuda: TButton;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure cbNodoCombustibleEntradaChange(Sender: TObject);
    procedure cbNodoCombustibleSalidaChange(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure cbAplicarPerdidasCuadraticasClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarNodosCombustible: boolean;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarTArcoCombustible.Create(AOwner: TComponent; sala: TSalaDeJuego;
  tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TArcoCombustible;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  inicializarCBNodosCombustibleLinkeados(
     cbNodoCombustibleEntrada, cbNodoCombustibleSalida);

  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := TArcoCombustible(cosaConNombre);
    inicializarComponentesLPD(
       actor.lpd, TFichaArcoCombustible, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;

    setCBNodoCombustibleLinkeado(
     cbNodoCombustibleEntrada,
     cbNodoCombustibleSalida,
      actor.NodoCombA,
      actor.NodoCombB);

    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    //    cbAplicarPerdidasCuadraticas.Checked:= actor.aplicarPerdidasCuadraticas;
    guardado := True;
  end
  else
    inicializarComponentesLPD(nil, TFichaArcoCombustible, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
end;


function TEditarTArcoCombustible.validarNodosCombustible: boolean;
begin
  result:= valorCBNodoCombustible(CBNodoCombustibleEntrada).combustible=
   valorCBNodoCombustible(CBNodoCombustibleSalida).combustible;
end;

function TEditarTArcoCombustible.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and
    inherited  validarNombre(EditNombre) and
    validarNodosCombustible and
    inherited validarEditFecha(EFNac) and inherited validarEditFecha(EFMuerte);
end;

procedure TEditarTArcoCombustible.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTArcoCombustible.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTArcoCombustible.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTArcoCombustible.BGuardarClick(Sender: TObject);
var
  actor: TArcoCombustible;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TArcoCombustible.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodoCombustible(CBNodoCombustibleEntrada), valorCBNodoCombustible(CBNodoCombustibleSalida)
    );     actor := TArcoCombustible(cosaConNombre);
    end
    else
    begin
      actor := TArcoCombustible(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.NodoCombA := valorCBNodoCombustible(cbNodoCombustibleEntrada);
      actor.NodoCombB := valorCBNodoCombustible(cbNodoCombustibleSalida);
      //      actor.aplicarPerdidasCuadraticas:= cbAplicarPerdidasCuadraticas.Checked;
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTArcoCombustible.cbAplicarPerdidasCuadraticasClick(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarTArcoCombustible.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TEditarTArcoCombustible.cbNodoCombustibleEntradaChange(Sender: TObject);
begin
  cbNodoCombustibleLinkeadoChange(Sender, cbNodoCombustibleSalida);
end;

procedure TEditarTArcoCombustible.cbNodoCombustibleSalidaChange(Sender: TObject);
begin
  cbNodoCombustibleLinkeadoChange(Sender, cbNodoCombustibleEntrada);
end;

procedure TEditarTArcoCombustible.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTArcoCombustible.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTArcoCombustible.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
