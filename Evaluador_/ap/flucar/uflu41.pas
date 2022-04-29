{xDEFINE OLD_FLUCAR}
unit uflu41;
interface


uses
  Classes, SysUtils, FileUtil, LResources,
  Forms, Controls,
  Graphics, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,
{$IFDEF OLD_FLUCAR}
  uprincipal,
{$ENDIF}
  uprincipal_raw;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1:     TButton;
    Button2:     TButton;
    Button3:     TButton;
    taps: TCheckBox;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    Timer1:      TTimer;
    TV_flujo:    TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
  end;

var
  Form1: TForm1;

implementation

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
{$IFDEF OLD_FLUCAR}
  if (OpenDialog1.Execute) then
    Principal(OpenDialog1.FileName);
{$ENDIF}
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  RootNode: TTreeNode;
begin
  if (OpenDialog2.Execute) then
    Principal_Raw(OpenDialog2.FileName,taps.Checked);//    Principal_Raw( OpenDialog2.FileName );
  RootNode := TV_flujo.Items.AddFirst(nil, OpenDialog2.FileName);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Close;

end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  timer1.Enabled := False;
  if paramcount = 2 then
    correr_raw_con_modificaciones(ParamStr(1), ParamStr(2));
end;

constructor TForm1.Create(TheOwner: TComponent);
var
  RootNode: TTreeNode;
begin
  inherited Create(TheOwner);
  RootNode := TV_flujo.Items.AddFirst(nil, OpenDialog2.FileName);
  TV_flujo.Items.AddChild(RootNode, 'DESCRIPCION');
  TV_flujo.Items.AddChild(RootNode, 'BARRAS');
  TV_flujo.Items.AddChild(RootNode, 'CARGAS');
  TV_flujo.Items.AddChild(RootNode, 'LINEAS');
  TV_flujo.Items.AddChild(RootNode, 'TRAFOS');
  TV_flujo.Items.AddChild(RootNode, 'SHUNTS');
  RootNode.Expanded := True;
end;

initialization
  {$I uflu41.lrs}
end.
