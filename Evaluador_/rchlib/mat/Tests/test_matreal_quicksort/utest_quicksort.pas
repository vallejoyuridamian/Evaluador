unit utest_quicksort;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, xMatDefs, matreal;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ecnt_error: TEdit;
    trx1: TPaintBox;
    trx2: TPaintBox;
    rb_Decreciente: TRadioButton;
    rb_Creciente: TRadioButton;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

{ TForm1 }



procedure PlotVect01( v: TVectR; c: TCanvas; cwidth, cheight: integer );
var
  mx, my: NReal;
  k: integer;
  xp, yp: integer;
  x, y: NReal;
begin
  mx:= cwidth / v.n;
  my:= cheight;
  x:= 1;
  y:= v.e( 1 );
  xp:= trunc( x * mx + 0.1 );
  yp:= cheight - trunc(  y  * my + 0.1 );

  c.MoveTo( xp, yp );

  for k:= 2 to v.n do
  begin
    x:= k;
    y:= v.e( k );
    xp:= trunc( x * mx + 0.1 );
    yp:= cheight - trunc( y * my + 0.1 );
    c.LineTo( xp, yp );
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  v: TVectR;
  nh, nv: integer;
  k: integer;
  cnt: integer;
begin
  nh:= trx1.Width;
  nv:= trx2.Height;

  v:= TVectR.Create_init( nh );
  for k:= 1 to nh do
    v.pv[k]:= random;

  PlotVect01( v, trx1.Canvas, trx1.Width, trx1.Height );
  v.Sort(rb_Creciente.checked );

  // verificación.
  cnt:= 0;
  for k:= 1 to v.n-1 do
  begin
    if rb_Creciente.checked then
    begin
      if ( v.e( k ) > v.e( k+1 ) ) then inc( cnt );
    end
    else
    begin
      if ( v.e( k ) < v.e( k+1 ) ) then inc( cnt );
    end;
  end;
  PlotVect01( v, trx2.Canvas, trx2.Width, trx2.Height );
  v.Free;

  ecnt_error.text:= IntToStr( cnt ) + ' / ' + IntToStr( v.n );
end;

end.

