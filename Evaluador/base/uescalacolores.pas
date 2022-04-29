unit uescalacolores;

{$mode delphi}

interface

uses
  Classes, SysUtils, Graphics, math, xmatdefs;

type
  TEscalaColor = class
    constructor Create( Xmin, Xmax: NReal );
    function Color( X: NReal ): TColor; virtual;
  private
    Xmin, deltaX: NReal;
    function XtoR( X: NReal ): NReal;
  end;

  TEscalaColor_Pastel = class( TEscalaColor )
    function Color( X: NReal ): TColor; override;
  end;

implementation

constructor TEscalaColor.Create( xmin, xmax: NReal );
begin
  self.Xmin:= xmin;
  self.deltaX:= xmax-xmin;
  if abs( deltaX ) < 1.0E-20 then
     deltaX:= 1;
end;

function TEscalaColor.XtoR( X: NReal ): NReal;
begin
  result:= (x - XMin)/ deltaX;
end;

function TEscalaColor.Color( X: NReal ): TColor;
var
  pr, pg, pb: NReal;
  green, blue, red: integer;
  sector: integer;
  temp: NReal;
  r: NReal;
begin
  r:= XtoR( X );
  if r < 0 then
    r:= 0
  else if r > 1 then r:= 1;

  r:= r + sin( r * 4* pi )/ (4*pi)/1.5;

  sector:= trunc( r * 4.0);
  if sector > 3 then sector:= 3;

  case sector of
  0: begin
       pb:= 1;
       pr:= 0;
       pg:= frac( r )*4;
     end;
  1: begin
        pb:= 1-frac( r - 0.25 )*4;
        pr:= 0;
        pg:= 1;
     end;
  2: begin
        pb:= 0;
        pr:= frac( r - 0.5 )*4;
        pg:= 1;
     end;
  3: begin
        pb:= 0;
        pr:= 1;
        pg:= 1- frac( r - 0.75 )*4;
     end;
  end;

(*
  temp:= pb + pr + pg;
  pb:= pb / temp;
  pr:= pr / temp;
  pg:= pg / temp;
*)

  green:= round( pg * 255.0 );
  blue:= round( pb * 255.0 );
  red:= round( pr * 255.0 );

  result:= RGBToColor(red, green, blue);
end;





function TEscalaColor_Pastel.Color( X: NReal ): TColor;
var
  pr, pg, pb: NReal;
  green, blue, red: integer;
  alfa: NReal;
  r: NReal;
begin
  r:= XtoR( X );

  if r < 0 then
    r:= 0
  else if r > 1 then r:= 1;

  alfa:= 2.0 * pi * 240.0/360.0 * r;

  pb:= ( max( 0, 0.5 + cos( alfa ) )/1.5);
  pg:= ( max( 0, 0.5 + cos( alfa - 120/180*pi ) )/1.5);
  pr:= ( max(0,  0.5 + cos( alfa + 120/180*pi) )/1.5);

  green:= round( pg * 255.0 );
  blue:= round( pb * 255.0 );
  red:= round( pr * 255.0 );

  result:= RGBToColor(red, green, blue);
end;

end.

