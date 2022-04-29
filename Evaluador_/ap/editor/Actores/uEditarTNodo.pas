unit uEditarTNodo;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uNodos;

type

  { TEditarTNodo }

  TEditarTNodo = class(TBaseEditoresActores)
    eZonaFlucar: TEdit;
    Label1: TLabel;
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
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BCancelarClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
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
constructor TEditarTNodo.Create(AOwner: TComponent; sala: TSalaDeJuego;
  tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  nodo: TNodo;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);

  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    nodo := TNodo(cosaConNombre);
    EditNombre.Text := nodo.nombre;

    EFNac.Text := FSimSEEEdit.fechaIniToString(nodo.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(nodo.muerte);
    eZonaFlucar.Text := IntToStr(TNodo(cosaConNombre).ZonaFlucar);
  end;
end;

function TEditarTNodo.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarEditFecha(EFNac) and inherited validarEditFecha(EFMuerte) and
    inherited validarEditInt(eZonaFlucar, -10000, MaxInt);
end;

procedure TEditarTNodo.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, TNodo);
end;

procedure TEditarTNodo.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTNodo.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTNodo.BGuardarClick(Sender: TObject);
var
  actor: TNodo;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TNodo.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades,
        StrToInt(eZonaFlucar.Text));
      actor := TNodo(cosaConNombre);
    end
    else
    begin
      actor := TNodo(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.ZonaFlucar := StrToInt(eZonaFlucar.Text);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTNodo.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTNodo.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTNodo.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
