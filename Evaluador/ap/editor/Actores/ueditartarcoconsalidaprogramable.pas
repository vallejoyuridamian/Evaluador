unit uEditarTArcoConSalidaProgramable;

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
  uArcoConSalidaProgramable;

type

  { TEditarTArcoConSalidaProgramable }

  TEditarTArcoConSalidaProgramable = class(TEditarActorConFichas)
    eX_Desc_Ini: TEdit;
    Label1: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LNodoSalida: TLabel;
    LFichas: TLabel;
    cbNodoEntrada: TComboBox;
    BGuardar: TButton;
    BCancelar: TButton;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    cbNodoSalida: TComboBox;
    BEditorDeUnidades: TButton;
    sgFichas: TStringGrid;
    BAgregarFicha: TButton;
    BVerExpandida: TButton;
    BAyuda: TButton;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure cbNodoEntradaChange(Sender: TObject);
    procedure cbNodoSalidaChange(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure cbAplicarPerdidasCuadraticasClick(Sender: TObject);
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

constructor TEditarTArcoConSalidaProgramable.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TArcoConSalidaProgramable;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  inicializarCBNodosLinkeados(cbNodoEntrada, cbNodoSalida);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := TArcoConSalidaProgramable(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaArcoConSalidaProgramable, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodoLinkeado(cbNodoEntrada, cbNodoSalida, actor.NodoA, actor.NodoB);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    eX_Desc_Ini.Text := IntToStr(actor.X_Desc_Ini);
    guardado := True;
  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaArcoConSalidaProgramable, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    eX_Desc_Ini.Text := IntToStr(0);
  end;
end;

function TEditarTArcoConSalidaProgramable.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodoLinkeado(cbNodoEntrada, cbNodoSalida) and
    inherited validarEditFecha(EFNac) and inherited validarEditFecha(EFMuerte) and
    inherited validarEditInt(eX_Desc_Ini, -MaxInt, MaxInt);
end;

procedure TEditarTArcoConSalidaProgramable.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, TArcoConSalidaProgramable);
end;

procedure TEditarTArcoConSalidaProgramable.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTArcoConSalidaProgramable.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTArcoConSalidaProgramable.BGuardarClick(Sender: TObject);
var
  actor: TArcoConSalidaProgramable;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TArcoConSalidaProgramable.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodoEntrada), valorCBNodo(CBNodoSalida), 0);
      actor := TArcoConSalidaProgramable(cosaConNombre);
    end
    else
    begin
      actor := TArcoConSalidaProgramable(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.NodoA := valorCBNodo(cbNodoEntrada);
      actor.NodoB := valorCBNodo(cbNodoSalida);
      actor.X_Desc_Ini := StrToInt(eX_Desc_ini.Text);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTArcoConSalidaProgramable.cbAplicarPerdidasCuadraticasClick(
  Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarTArcoConSalidaProgramable.cbNodoEntradaChange(Sender: TObject);
begin
  cbNodoLinkeadoChange(Sender, cbNodoSalida);
end;

procedure TEditarTArcoConSalidaProgramable.cbNodoSalidaChange(Sender: TObject);
begin
  cbNodoLinkeadoChange(Sender, cbNodoEntrada);
end;

procedure TEditarTArcoConSalidaProgramable.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTArcoConSalidaProgramable.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTArcoConSalidaProgramable.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
