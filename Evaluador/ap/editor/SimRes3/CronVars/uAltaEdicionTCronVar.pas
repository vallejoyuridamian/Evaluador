unit uAltaEdicionTCronVar;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uBaseAltaEdicionCronVars, uHistoVarsOps, uLectorSimRes3Defs,
  uVerDoc;

type
  TAltaEdicionTCronVar = class(TBaseAltaEdicionCronVars)
    lNombre: TLabel;
    eNombre: TEdit;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bCancelarClick(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditStringExit(Sender: TObject);
  protected
    function validarFormulario: boolean;  override;
  public
    Constructor Create(AOwner: TComponent;lector: TLectorSimRes3Defs; cronVar: TCronVar); override;
  end;

var
  AltaEdicionTCronVar: TAltaEdicionTCronVar;

implementation

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

Constructor TAltaEdicionTCronVar.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronVar: TCronVar);
begin
  inherited Create(AOwner, lector, cronVar);
  if cronVar <> NIL then
    eNombre.Text:= cronVar.nombre;
end;

procedure TAltaEdicionTCronVar.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTCronVar.EditStringExit(Sender: TObject);
begin
  inherited EditStringExit(Sender, true);
end;

function TAltaEdicionTCronVar.validarFormulario: boolean;
begin
  result:= validarNombreCronVar(eNombre);
end;

procedure TAltaEdicionTCronVar.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TCronVar);
end;

procedure TAltaEdicionTCronVar.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronVar.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronVar = NIL then
      cronVar:= TCronVar.Create(eNombre.Text)
    else
      cronVar.nombre:= eNombre.Text;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTCronVar.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TAltaEdicionTCronVar.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.