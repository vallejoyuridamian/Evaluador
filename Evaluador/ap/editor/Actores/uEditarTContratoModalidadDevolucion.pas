unit uEditarTContratoModalidadDevolucion;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls,
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
  ucontratomodalidaddevolucion;

type
  TEditarTContratoModalidadDevolucion = class(TEditarActorConFichas)
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFichas: TLabel;
    LVEstado: TLabel;
    LNDisc: TLabel;
    LEImp_Ini_: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    sgFichas: TStringGrid;
    BAgregarFicha: TButton;
    BVerExpandida: TButton;
    BAyuda: TButton;
    eE_Credito_Ini_: TEdit;
    ENDisc: TEdit;
    Panel1: TPanel;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
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

{$IFNDEF FPC}
  {$R *.dfm}

{$ELSE}
  {$R *.lfm}
{$ENDIF}

constructor TEditarTContratoModalidadDevolucion.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TContratoModalidadDevolucion;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := TContratoModalidadDevolucion(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaContratoModalidadDevolucion, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    eE_Credito_Ini_.Text := FloatToStrF(actor.E_Credito_ini, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    ENDisc.Text := IntToStr(actor.NDisc);
  end
  else
    inicializarComponentesLPD(nil, TFichaContratoModalidadDevolucion, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
end;

function TEditarTContratoModalidadDevolucion.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited validarEditFecha(EFMuerte) and
    inherited validarEditFloat(eE_Credito_Ini_, -MaxNReal, MaxNReal) and
    inherited validarEditInt(ENDisc, 2, MaxInt);
end;

procedure TEditarTContratoModalidadDevolucion.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, TContratoModalidadDevolucion);
end;

procedure TEditarTContratoModalidadDevolucion.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTContratoModalidadDevolucion.BGuardarClick(Sender: TObject);
var
  actor: TContratoModalidadDevolucion;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TContratoModalidadDevolucion.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo), StrToFloat(eE_Credito_Ini_.Text), StrToInt(ENDisc.Text));
      actor := TContratoModalidadDevolucion(cosaConNombre);
    end
    else
    begin
      actor := TContratoModalidadDevolucion(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.E_Credito_ini := StrToFloat(eE_Credito_Ini_.Text);
      actor.NDisc := StrToInt(ENDisc.Text);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTContratoModalidadDevolucion.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTContratoModalidadDevolucion.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTContratoModalidadDevolucion.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTContratoModalidadDevolucion.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
