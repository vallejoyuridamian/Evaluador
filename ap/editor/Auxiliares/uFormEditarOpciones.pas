unit uFormEditarOpciones;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  SysUtils, Classes, Controls, StdCtrls, utilidades, uOpcionesSimSEEEdit,
  uBaseFormularios;

type
  TFormEditarOpciones = class(TBaseFormularios)
    LLibPath: TLabel;
    ELibPath: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    CBFechasAutomaticas: TCheckBox;
    cbSinScrollHListados: TCheckBox;
    cbGuardarCopiaDeArchivos: TCheckBox;
    lMaxNBackups: TLabel;
    eMaxNBackups: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BCancelarClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure CambiosEditForm(Sender: TObject);
    procedure CBChange(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure cbGuardarCopiaDeArchivosClick(Sender: TObject);
    procedure EditCardinalExit(Sender: TObject);
  public
    Constructor Create(AOwner: TComponent); reintroduce;
  end;

implementation

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

Constructor TFormEditarOpciones.Create(AOwner: TComponent);
begin
  inherited Create_conSalaYEditor_( AOwner, nil );
  ELibPath.Text:= TSimSEEEditOptions.getInstance.libPath;
  CBFechasAutomaticas.Checked:= TSimSEEEditOptions.getInstance.fechasAutomaticas;
  cbSinScrollHListados.Checked:= TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados;
  cbGuardarCopiaDeArchivos.Checked:= TSimSEEEditOptions.getInstance.guardarBackupDeArchivos;
  cbGuardarCopiaDeArchivosClick(NIL);
  eMaxNBackups.Text:= IntToStr(TSimSEEEditOptions.getInstance.maxNBackups);
end;

procedure TFormEditarOpciones.FormCreate(Sender: TObject);
begin
  guardado:= true;
end;

procedure TFormEditarOpciones.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TFormEditarOpciones.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TFormEditarOpciones.EditCardinalExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, MaxInt);
end;

procedure TFormEditarOpciones.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TFormEditarOpciones.CambiosEditForm(Sender: TObject);
begin
if TEdit(Sender).Text <> loQueHabia then
  guardado:= false;
end;

procedure TFormEditarOpciones.CBChange(Sender: TObject);
begin
  inherited CBChange(Sender);
end;

procedure TFormEditarOpciones.cbGuardarCopiaDeArchivosClick(Sender: TObject);
begin
  eMaxNBackups.Enabled:= cbGuardarCopiaDeArchivos.Checked;
end;

procedure TFormEditarOpciones.BGuardarClick(Sender: TObject);
var
  opciones: TSimSEEEditOptions;
begin
  if validarFormulario then
  begin
    opciones:= TSimSEEEditOptions.getInstance;
    opciones.libPath:= ELibPath.Text;
    opciones.fechasAutomaticas:= CBFechasAutomaticas.Checked;
    opciones.deshabilitarScrollHorizontalEnListados:= cbSinScrollHListados.Checked;
    opciones.guardarBackupDeArchivos:= cbGuardarCopiaDeArchivos.Checked;
    opciones.maxNBackups:= StrToInt(eMaxNBackups.Text);
    ModalResult:= mrOk;
  end;
end;

end.
