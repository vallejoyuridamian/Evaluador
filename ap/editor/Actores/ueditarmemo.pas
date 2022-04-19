unit ueditarmemo;

{$mode delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uNodos;

type

  { TEditorMEMO }

  TEditorMEMO = class(TForm)
    BAyuda: TButton;
    BCancelar: TButton;
    BGuardar: TButton;
    Memo: TMemo;
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    constructor Create(AOwner: TComponent; memo: TStrings );
  end;

var
  EditorMEMO: TEditorMEMO;

implementation

{$R *.lfm}

procedure TEditorMEMO.BGuardarClick(Sender: TObject);
begin
// aquí correspondería por ejemplo tratar de verificar algo
      ModalResult := mrOk;
end;

procedure TEditorMEMO.BCancelarClick(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

constructor TEditorMemo.Create(AOwner: TComponent; memo: TStrings );
begin
  inherited Create( AOwner );
  Self.Memo.Lines:= memo;
end;

end.
