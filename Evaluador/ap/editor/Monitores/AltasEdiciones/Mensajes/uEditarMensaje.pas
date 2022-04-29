unit uEditarMensaje;
  {$MODE Delphi}

interface

uses
   {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uSalasDeJuego, utilidades, uMonitorArchivo,
  uEventosOptSim, uBaseFormularios, uBaseAltasEditores;

type
  TRecOfEventoMsg = class
    public
      evento : TEventoOptSim;
      msg : String;
      Constructor Create(evento : TEventoOptSim ; msg : String);
  end;

  TEditarMensaje = class(TBaseFormularios)
    LMensaje: TLabel;
    EMsj: TEdit;
    CBEvento: TComboBox;
    LEvento: TLabel;
    BAgregarMensaje: TButton;
    BCancelar: TButton;
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CBEventoChange(Sender: TObject);
    procedure BAgregarMensajeClick(Sender: TObject);
    procedure EditStringExit(Sender: TObject);
  private
    msj : TRecOfEventoMsg;
  protected
    function validarFormulario : boolean; override;
  public
    Constructor Create(AOwner : TComponent ; msj : TRecOfEventoMsg ; eventosDisponibles : TStrings); reintroduce;
    function darMsj : TRecOfEventoMsg;
  end;

function compareRecOfEventoMsg(item1, item2: Pointer): Integer;

implementation

  {$R *.lfm}

function compareRecOfEventoMsg(item1, item2: Pointer): Integer;
begin
  if TRecOfEventoMsg(item1).evento < TRecOfEventoMsg(item2).evento then
    result:= -1
  else if TRecOfEventoMsg(item1).evento = TRecOfEventoMsg(item2).evento then
    result:= 0
  else
    result:= 1;
end;

Constructor TRecOfEventoMsg.Create(evento : TEventoOptSim ; msg : String);
begin
  inherited Create();
  self.evento := evento;
  Self.msg := msg;
end;

Constructor TEditarMensaje.Create(AOwner : TComponent ; msj : TRecOfEventoMsg ; eventosDisponibles : TStrings);
begin
  inherited Create(AOwner);
  CBEvento.Items := eventosDisponibles;
  if msj <> NIL then
  begin
    EMsj.Text := msj.msg;
    CBEvento.ItemIndex := CBEvento.Items.IndexOf(msj.msg);
  end;
end;

function TEditarMensaje.darMsj : TRecOfEventoMsg;
begin
  result := msj;
end;

procedure TEditarMensaje.EditStringExit(Sender: TObject);
begin
  inherited EditStringExit(Sender, true);
end;

function TEditarMensaje.validarFormulario : boolean;
begin
  result := (EMsj.Text <> '') and (CBEvento.ItemIndex <> -1);
end;

procedure TEditarMensaje.BCancelarClick(Sender: TObject);
begin
  self.Close;
end;

procedure TEditarMensaje.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarMensaje.CBEventoChange(Sender: TObject);
begin
  guardado := False;
  if EMsj.Text = '' then
    EMsj.Text := CBEvento.Items[CBEvento.ItemIndex];
end;

procedure TEditarMensaje.BAgregarMensajeClick(Sender: TObject);
var
  evento : TEventoOptSim;
begin
  if validarFormulario then
  begin
    evento := StrToEvento(CBEvento.Items[CBEvento.ItemIndex]);
    msj := TRecOfEventoMsg.Create(evento, EMsj.Text);
    ModalResult := mrOk;
  end;
end;

end.
