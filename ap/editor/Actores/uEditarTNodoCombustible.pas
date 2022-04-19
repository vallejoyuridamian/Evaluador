unit uEditarTNodoCombustible;

interface

uses
 // Windows,
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  unodocombustible,
  uverdoc,
  uNodos;

type

  { TEditarTNodoCombustible }

  TEditarTNodoCombustible = class(TBaseEditoresActores)
    cbCombustible_: TComboBox;
    lblCombustible: TLabel;
    LNombre: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    BEditorDeUnidades: TButton;
    BAyuda: TButton;
    procedure CBChange(Sender: TObject);
    procedure cbCombustible_Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BCancelarClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
  private
    { Private declarations }
  public
    Constructor Create(AOwner: TComponent; sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;

{$R *.lfm}
Constructor TEditarTNodoCombustible.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  nodoComb: TNodoCombustible;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  inicializarCBCombustible( cbCombustible_, false );

  utilidades.AgregarFormatoFecha(LFNac);
	utilidades.AgregarFormatoFecha(LFMuerte);

  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> NIL then
  begin
    nodoComb:= TNodoCombustible(cosaConNombre);
  	EditNombre.Text := nodoComb.nombre;

	  EFNac.Text := FSimSEEEdit.fechaIniToString(nodoComb.nacimiento);
  	EFMuerte.Text := FSimSEEEdit.fechaFinToString(nodoComb.muerte);
    setCBCombustible( cbCombustible_, TNOdoCOmbustible( cosaConNombre ).Combustible );
  end;
end;

function TEditarTNodoCombustible.validarFormulario: boolean;
begin
  result:= inherited validarFormulario
           and validarNombre(EditNombre)
           and validarEditFecha(EFNac)
           and validarCBCombustible( cbCombustible_ )
           and validarEditFecha(EFMuerte);
end;

procedure TEditarTNodoCombustible.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, TNodo);
end;

procedure TEditarTNodoCombustible.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTNodoCombustible.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTNodoCombustible.BGuardarClick(Sender: TObject);
var
	actor: TNodoCombustible;
begin
  if validarFormulario then
	begin
    if cosaConNombre = NIL then
    begin
      cosaConNombre:= TNodoCombustible.Create(0, EditNombre.Text,
                               FSimSEEEdit.StringToFecha(EFNac.Text),
                               FSimSEEEdit.StringToFecha(EFMuerte.Text),
                               lpdUnidades, valorCBCombustible( cbCombustible_ ) );
    end
    else
    begin
      actor:= TNodoCombustible(cosaConNombre);
      actor.nombre:= EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades:= lpdUnidades;
      actor.combustible:= valorCBCombustible( cbCombustible_ );
    end;

    ModalResult:= mrOk;
	end
end;

procedure TEditarTNodoCombustible.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTNodoCombustible.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTNodoCombustible.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarTNodoCombustible.CBChange(Sender: TObject);
begin
end;

procedure TEditarTNodoCombustible.cbCombustible_Change(Sender: TObject);
begin
    self.cbCombustibleChange(Self, true);
end;



end.
