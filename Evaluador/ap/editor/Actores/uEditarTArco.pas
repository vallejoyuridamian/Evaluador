unit uEditarTArco;
  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,
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
  uArcos;

type

  { TEditarTArco }

  TEditarTArco = class(TEditarActorConFichas)
    CBCondicion_NombreBorne: TComboBox;
    cbCondicion_Fuente: TComboBox;
    CbHidroConEmbalse: TComboBox;
    cv_edit: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LBornePreciosPorCombustible: TLabel;
    LIndicePreciosPorCombustible: TLabel;
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
    procedure cbCondicion_FuenteChange(Sender: TObject);
    procedure CBCondicion_NombreBorneChange(Sender: TObject);
    procedure CbHidroConEmbalseChange(Sender: TObject);
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

constructor TEditarTArco.Create(AOwner: TComponent; sala: TSalaDeJuego;
  tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TArco;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  inicializarCBNodosLinkeados(cbNodoEntrada, cbNodoSalida);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  inicializarCBFuente(cbCondicion_Fuente, CBCondicion_NombreBorne, True);
  inicializarCBHidroConEmbalse(CbHidroConEmbalse,true);
  inicializarEditCV(cv_edit);

  if cosaConNombre <> nil then
  begin
    actor := TArco(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaArco, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodoLinkeado(cbNodoEntrada, cbNodoSalida, actor.NodoA, actor.NodoB);
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    cv_edit.Text:= FloatToStr(actor.cv_Hidro);
    setCBFuente(cbCondicion_Fuente, CBCondicion_NombreBorne,
      actor.Condicion_Fuente, actor.Condicion_NombreBorne);
    setCBHidroConEmbalse(CbHidroConEmbalse,actor.Condicion_HidroConEmbalse);

    //    cbAplicarPerdidasCuadraticas.Checked:= actor.aplicarPerdidasCuadraticas;
    guardado := True;
  end
  else
    inicializarComponentesLPD(nil, TFichaArco, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
end;

function TEditarTArco.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodoLinkeado(cbNodoEntrada, cbNodoSalida) and
   // inherited validarCBFuente(cbCondicion_Fuente,  CBCondicion_NombreBorne, 0) and
    inherited validarEditFecha(EFNac) and inherited validarEditFecha(EFMuerte)
   // and inherited validarCBHidroConEmbalse(CbHidroConEmbalse);

end;

procedure TEditarTArco.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTArco.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTArco.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTArco.BGuardarClick(Sender: TObject);
var
  actor: TArco;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TArco.Create(capa, EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodoEntrada), valorCBNodo(CBNodoSalida){,
                               cbAplicarPerdidasCuadraticas.Checked},
        valorCBFuente(CBCondicion_Fuente), valorCBString(CBCondicion_NombreBorne),
        valorCBHidroConEmbalse(CbHidroConEmbalse),StrToFloat(cv_edit.text));
      actor := TArco(cosaConNombre);
    end
    else
    begin
      actor := TArco(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.NodoA := valorCBNodo(cbNodoEntrada);
      actor.NodoB := valorCBNodo(cbNodoSalida);
      //      actor.aplicarPerdidasCuadraticas:= cbAplicarPerdidasCuadraticas.Checked;
      actor.Condicion_fuente := valorCBFuente(CBCondicion_Fuente);
      actor.Condicion_nombreBorne := valorCBString(CBCondicion_NombreBorne);
      actor.Condicion_HidroConEmbalse:=valorCBHidroConEmbalse(CbHidroConEmbalse);
      actor.cv_Hidro:=StrToFloat(cv_edit.text);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTArco.cbAplicarPerdidasCuadraticasClick(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarTArco.cbNodoEntradaChange(Sender: TObject);
begin
  cbNodoLinkeadoChange(Sender, cbNodoSalida);
end;

procedure TEditarTArco.cbNodoSalidaChange(Sender: TObject);
begin
  cbNodoLinkeadoChange(Sender, cbNodoEntrada);
end;

procedure TEditarTArco.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTArco.cbCondicion_FuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBCondicion_NombreBorne );
end;

procedure TEditarTArco.CBCondicion_NombreBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(cbCondicion_Fuente, CBCondicion_NombreBorne );
end;

procedure TEditarTArco.CbHidroConEmbalseChange(Sender: TObject);
begin
  inherited cbHidroConEmbalseChange(Sender,true);
end;

procedure TEditarTArco.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTArco.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
