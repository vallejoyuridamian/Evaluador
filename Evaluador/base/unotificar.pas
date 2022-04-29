unit uNotificar;

interface

uses
{$IFDEF WINDOWS}
Windows,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls
  {$IFNDEF LCL}
  , GIFImg
  {$ENDIF}
  , ExtCtrls;

type
  TfNotificar = class(TForm)
    panel: TPanel;
    Button1: TButton;
    texto: TMemo;
    logo: TImage;
    Label1: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    procedure Confirmar_OnClick(Sender: TObject);
  public
    { Public declarations }
    vel: integer;
    info: string;
  end;

var
  fNotificar: TfNotificar;

procedure notificar( texto: string ); overload;
procedure notificar( texto: string; rojo: boolean ); overload;

procedure esperando_inicio( texto: string );
procedure esperando_fin;

function confirmar( texto: string; opciones: array of string ): string;

implementation

{$R *.lfm}

var
  fEsperando: TfNotificar;




procedure esperando_inicio( texto: string );
begin
  if fEsperando <> nil then
    raise Exception.Create('Llamó esperando inicio y no es nil la form.' );

  fesperando:= TfNotificar.Create( nil );
  fesperando.color:= clGreen;
  fesperando.Button1.Visible:= false;

  fesperando.texto.text:= texto;
  fesperando.Timer1.Enabled:= false;
  fesperando.Show;
  fesperando.Invalidate;
  application.ProcessMessages;
  fesperando.Timer1.Enabled:= false;
  fesperando.vel:= 20;

end;


procedure esperando_fin;
begin
  if fesperando <> nil then
  begin
    fesperando.Timer1.Enabled:= false;
    fesperando.free;
    fesperando:= nil;
  end;
end;


procedure notificar( texto: string; rojo: boolean );
var
  fnot: TfNotificar;
begin
  fnot:= TfNotificar.Create( nil );
  if rojo then
    fnot.color:= clRed;
  fnot.texto.text:= texto;
  fnot.Timer1.Enabled:= true;
  fnot.vel:= 20;
  fnot.ShowModal;
  fnot.Timer1.Enabled:= false;
  fnot.free;
end;


procedure notificar( texto: string );
begin
  notificar( texto, false );
end;




procedure TfNotificar.Button1Click(Sender: TObject);
begin
  ModalResult:= mrOk;
end;

procedure TfNotificar.FormCreate(Sender: TObject);
begin
   top:= 0;
   left:= 0;
   width:=Screen.Width;
   height:= Screen.Height;

   Panel.top:=  (Height  - Panel.Height) div 2;
   Panel.left:= (width - Panel.Width ) div 2;

end;



procedure TfNotificar.Confirmar_OnClick(Sender: TObject);
begin
  info:= TButton( Sender ).Caption;
  modalresult:= mrOk;
end;


procedure TfNotificar.Timer1Timer(Sender: TObject);
begin

//  vel:=  trunc (0.9 * vel + 10 *(  random - 0.5 ) );
  if (logo.left < 40) then
    vel:= abs(vel);

  if (logo.left > (panel.Width - 40)) then
    vel:= -abs( vel );

  logo.left:= logo.left + vel;
end;


function confirmar( texto: string; opciones: array of string  ): string;
var
  fnot: TfNotificar;
  k: integer;
  pb: TButton;
  origen, ancho: integer;

const
  bsep= 5;// separación entre los botones

begin
  fnot:= TfNotificar.Create( nil );
  fnot.vel:= 20;
  fnot.Button1.Visible:= false;

  ancho:= trunc( fnot.Button1.width * length( opciones ) + bsep * ( length( opciones ) -1 ) );
  origen:= fnot.Button1.Left - ancho div 2;
  ancho:= fnot.Button1.Width + 5;

  fnot.info:= '';

  for k:= 0 to high( opciones ) do
  begin
    pb:= TButton.Create( fnot );
    pb.Caption:= opciones[k];
    pb.Width:= fnot.Button1.Width;
    pb.Height:= fnot.Button1.Height;
    pb.Left:= origen + k * ancho;
    pb.Top:= fnot.Button1.Top;
    pb.OnClick:= fnot.Confirmar_OnClick;
    pb.Parent:= fnot.panel;
  end;
  fnot.texto.text:= texto;
  fnot.texto.ReadOnly:= true;

  fnot.Timer1.Enabled:= true;
  fnot.ShowModal;
  fnot.Timer1.Enabled:= false;
  result:= fnot.info;
  fnot.free;
end;




begin
  fEsperando:= nil;
end.
