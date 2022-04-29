unit uTOGPropsForm;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TTOGPropForm = class(TForm)
    ColorDialog1: TColorDialog;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    cb_Close: TCheckBox;
    Shape1: TShape;
    sb_GrosorBorde: TScrollBar;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sb_GrosorBordeChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    cambio: boolean;
  end;

var
  TOGPropForm: TTOGPropForm;




implementation

{$R *.lfm}

procedure TTOGPropForm.Button1Click(Sender: TObject);
begin
  if ColorDialog1.Execute then
  begin
    cambio:= true;
    shape1.Pen.Color:= ColorDialog1.Color;
  end;
end;

procedure TTOGPropForm.Button2Click(Sender: TObject);
begin
  modalresult:= 1;
end;

procedure TTOGPropForm.Button3Click(Sender: TObject);
begin
  modalresult:= -1;
end;

procedure TTOGPropForm.Button4Click(Sender: TObject);
begin
  if ColorDialog1.Execute then
  begin
    cambio:= true;
    shape1.Brush.Color:= ColorDialog1.Color;
  end;
end;

procedure TTOGPropForm.FormCreate(Sender: TObject);
begin
  cambio:= false;
end;

procedure TTOGPropForm.FormShow(Sender: TObject);
begin
  sb_GrosorBorde.Position:= shape1.Pen.Width;
end;

procedure TTOGPropForm.sb_GrosorBordeChange(Sender: TObject);
begin
  shape1.Pen.Width:= sb_GrosorBorde.Position;
end;

end.
