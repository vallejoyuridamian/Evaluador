unit uesquema;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,
  LCLIntf,
  LCLClasses,
  LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    PaintBox1: TPaintBox;
    StatusBar1: TStatusBar;
    procedure GroupBox1Click(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{ TForm1 }

var
   xdn, ydn: integer;
   xup, yup: integer;
   xp, yp: integer;
   mouse_is_UP: boolean;


procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   xup:= x;
   yup:= y;
   mouse_is_Up:= true;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
   r: TRect;
   res: boolean;
begin
    res:= LCLIntf.GetClientRect( PaintBox1.parent.Handle, r );
    PaintBox1.Canvas.MoveTo( xdn, ydn );
    PaintBox1.Canvas.LineTo( xp, yp );

//     self.PaintBox1.Canvas.Rectangle( r );
end;

procedure swapi( var a, b: longint );
var
   x: longint;
begin
     x:= a;
     a:= b;
     b:= x;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
   r: TRect;
begin
  if not mouse_Is_UP then
  begin

    r := Rect( xdn, ydn, xp, yp );
    if xdn > xp then swapi( r.Left, r.Right );
    if ydn > yp then swapi( r.top, r.bottom );
    r.left:= r.left-4;
    r.right:= r.right+4;
    r.Top:= r.top -4;
    r.bottom:= r.bottom+4;

    LCLIntf.InvalidateRect( PaintBox1.parent.handle, @r, true );
    xp:= x;
    yp:= y;

    statusbar1.SimpleText:= 'x: '+IntToStr( x )+', y: '+IntToStr(y );
  end;
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  xdn:= x;
  ydn:= y;
  mouse_is_up:= false;
end;

procedure TForm1.GroupBox1Click(Sender: TObject);
begin

end;



initialization
  {$I uesquema.lrs}

end.

