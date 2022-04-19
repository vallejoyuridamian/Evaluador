unit uEditarTCombustible;

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uverdoc,
  uConstantesSimSEE,
  xMatDefs,
  uCombustible,
  uBaseEditoresCombustiblesConFichas;

type

  { TEditarTCombustible }

  TEditarTCombustible = class(TBaseEditoresCombustiblesConFichas)
    BAgregarFicha: TButton;
    BCancelar: TButton;
    BEditorDeUnidades: TButton;
    BGuardar: TButton;
    BVerExpandida: TButton;
    panel_botones_deabajo: TPanel;
    panel_EstadoInicial: TGroupBox;
    panel_ParametrosDinamicos: TGroupBox;
    LEstadoIni: TLabel;
    LFichas: TLabel;
    LNombre: TLabel;
    LNodo: TLabel;
    EditNombre: TEdit;
    BAyuda: TButton;
    sgFichas: TStringGrid;
    procedure EditEnter(Sender: TObject);
    procedure EditNombreExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    ////    procedure BEditorDeUnidadesClick(Sender: TObject);
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

  {$R *.lfm}



constructor TEditarTCombustible.Create(AOwner: TComponent; sala: TSalaDeJuego;
  tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  combustible: TCombustible;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  if cosaConNombre <> nil then
  begin
    combustible := TCombustible(cosaConNombre);
    inicializarComponentesLPD(combustible.lpd, TFichaCombustible, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := combustible.nombre;
  //EditDensidad.Text := FloatToStr(combustible.densidad);
  //EditUnidades.Text := combustible.unidad;

  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaCombustible, sgFichas,
      BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

  end;
end;

function TEditarTCombustible.validarFormulario: boolean;
begin
   Result := inherited validarFormulario and inherited  validarNombre(EditNombre);
   //and
  //inherited validarEditFloat(EditDensidad, 0, 100000) and
  //inherited validarNombre(EditUnidades);
end;

procedure TEditarTCombustible.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTCombustible.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

////procedure TEditarTCombustible.BEditorDeUnidadesClick(Sender: TObject);
////begin
////  inherited BEditorDeUnidadesClick(Sender);
////end;

procedure TEditarTCombustible.BGuardarClick(Sender: TObject);
var
  actor: TCombustible;
begin
  if validarFormulario then
  begin
    if cosaConNombre = nil then
    begin
      cosaConNombre := TCombustible.Create(capa, EditNombre.Text,
        lpd);
        //StrToFloat(EditDensidad.Text), EditUnidades.Text);

    end
    else
    begin
      actor := TCombustible(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.lpd.Free;
      actor.lpd := lpd;
     // actor.densidad := StrToFloat(EditDensidad.Text);
     // actor.unidad := EditUnidades.Text;
    end;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTCombustible.CambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarTCombustible.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTCombustible.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTCombustible.EditNombreExit(Sender: TObject);
begin
  inherited validarNombre(Sender);
end;

procedure TEditarTCombustible.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
