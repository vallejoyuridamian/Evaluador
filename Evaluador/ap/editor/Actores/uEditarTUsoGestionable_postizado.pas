unit uEditarTUsoGestionable_postizado;

interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
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
  uDemandas,
  uUsoGestionable_postizado;

type

  { TEditarTUsoGestionable_postizado }

  TEditarTUsoGestionable_postizado = class(TEditarActorConFichas)
    BAgregarFicha: TButton;
    BVerExpandida: TButton;
    cbDemanda: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    CBNodo: TComboBox;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    BAyuda: TButton;
    sgFichas: TStringGrid;
    procedure BAgregarFichaClick(Sender: TObject);
    procedure BVerExpandidaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
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
    function demanda_sel(cb: TComboBox): TDemanda;
    procedure inicializar_cb_demanda(cb: TComboBox; Demanda: TDemanda);
    function validarDemanda(cb: TComboBox): boolean;

  end;


resourcestring
  rsSeleccionar = '<seleccionar>';
  rsDebeSeleccionarUnaDemanda = 'Debe seleccionar una demanda.';

implementation

uses SimSEEEditMain;

{$R *.lfm}



function TEditarTUsoGestionable_postizado.demanda_sel(cb: TComboBox): TDemanda;
begin
  if cb.Items[cb.ItemIndex] = rsSeleccionar then
    Result := nil
  else
    Result := sala.Dems.find(cb.Items[cb.ItemIndex]) as TDemanda;
end;

procedure TEditarTUsoGestionable_postizado.inicializar_cb_demanda(cb: TComboBox;
  Demanda: TDemanda);
var
  i, isel: integer;
  ad: TDemanda;
  seltext: string;
begin
  isel := -1;
  seltext := rsSeleccionar;
  for i := 0 to sala.Dems.Count - 1 do
  begin
    ad := sala.Dems[i] as TDemanda;
    if ad = Demanda then
    begin
      isel := i;
      seltext := ad.Nombre;
    end;
    cb.Items.Add(ad.Nombre);
  end;
  cb.ItemIndex := isel;
  cb.Text := seltext;
  cb.Tag := isel;
end;


constructor TEditarTUsoGestionable_postizado.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TUsoGestionable_postizado;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  inicializarCBNodos(CBNodo, False);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);



  if cosaConNombre <> nil then
  begin
    actor := TUsoGestionable_postizado(cosaConNombre);
    inicializarComponentesLPD(actor.lpd, TFichaUsoGestionable_postizado, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodo(CBNodo, actor.Nodo);

    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);

    inicializar_cb_demanda(cbDemanda, actor.Demanda);

  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaUsoGestionable_postizado, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);
    inicializar_cb_demanda(cbDemanda, nil);
  end;
end;


function TEditarTUsoGestionable_postizado.validarDemanda(cb: TComboBox): boolean;
begin
  if cb.ItemIndex >= 0 then
    Result := True
  else
  begin
    ShowMessage(rsDebeSeleccionarUnaDemanda);
    cb.SetFocus;
    Result := False;
  end;
end;

function TEditarTUsoGestionable_postizado.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodo(CBNodo) and inherited validarEditFecha(EFNac) and
    inherited  validarEditFecha(EFMuerte) and validarDemanda(cbDemanda);
end;

procedure TEditarTUsoGestionable_postizado.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, 'TUsoGestionable_Postizado');
end;

procedure TEditarTUsoGestionable_postizado.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTUsoGestionable_postizado.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;



procedure TEditarTUsoGestionable_postizado.BGuardarClick(Sender: TObject);
var
  actor: TUsoGestionable_postizado;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TUsoGestionable_postizado.Create(
        capa,
        EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades, lpd,
        valorCBNodo(CBNodo), demanda_sel(CBDemanda));
      actor := TUsoGestionable_postizado(cosaConNombre);
    end
    else
    begin
      actor := TUsoGestionable_postizado(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.nodo := valorCBNodo(CBNodo);
      actor.Demanda := demanda_sel(CBDemanda);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTUsoGestionable_postizado.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

procedure TEditarTUsoGestionable_postizado.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTUsoGestionable_postizado.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTUsoGestionable_postizado.BAgregarFichaClick(Sender: TObject);
begin

end;

procedure TEditarTUsoGestionable_postizado.BVerExpandidaClick(Sender: TObject);
begin

end;

procedure TEditarTUsoGestionable_postizado.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTUsoGestionable_postizado.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
