unit ucoloresbasicos;

{$mode delphi}

interface

uses
  Classes, SysUtils, FPCanvas, FPImgCanv, FPimage;

type
  TCanvas = TFPImageCanvas;
  TColor = TFPColor;
  TPenStyle = TFPPenStyle;
  TBrushStyle = TFPBrushStyle;

  TkColorPaleta = 0 .. 14;

const

  alphaTransparent = $0000;
  alphaOpaque = $FFFF;


  // standard colors
  clBlack: TFPColor = (Red: $0000; Green: $0000; Blue: $0000; Alpha: alphaOpaque);
  clMaroon: TFPColor = (Red: $8000; Green: $0000; Blue: $0000; Alpha: alphaOpaque);
  clGreen: TFPColor = (Red: $0000; Green: $ffff; Blue: $0000; Alpha: alphaOpaque);
  clOlive: TFPColor = (Red: $8000; Green: $8000; Blue: $0000; Alpha: alphaOpaque);
  clNavy: TFPColor = (Red: $0000; Green: $0000; Blue: $8000; Alpha: alphaOpaque);
  clPurple: TFPColor = (Red: $8000; Green: $0000; Blue: $8000; Alpha: alphaOpaque);
  clTeal: TFPColor = (Red: $0000; Green: $8000; Blue: $8000; Alpha: alphaOpaque);
  clGray: TFPColor = (Red: $8000; Green: $8000; Blue: $8000; Alpha: alphaOpaque);
  clSilver: TFPColor = (Red: $c000; Green: $c000; Blue: $c000; Alpha: alphaOpaque);
  clRed: TFPColor = (Red: $ffff; Green: $0000; Blue: $0000; Alpha: alphaOpaque);
  clLime: TFPColor = (Red: $0000; Green: $ffff; Blue: $0000; Alpha: alphaOpaque);
  clYellow: TFPColor = (Red: $ffff; Green: $ffff; Blue: $0000; Alpha: alphaOpaque);
  clBlue: TFPColor = (Red: $0000; Green: $0000; Blue: $ffff; Alpha: alphaOpaque);
  clFuchsia: TFPColor = (Red: $ffff; Green: $0000; Blue: $ffff; Alpha: alphaOpaque);
  clAqua: TFPColor = (Red: $0000; Green: $ffff; Blue: $ffff; Alpha: alphaOpaque);
  clLtGray: TFPColor = (Red: $c000; Green: $c000; Blue: $c000; Alpha: alphaOpaque);
  clDkGray: TFPColor = (Red: $4000; Green: $4000; Blue: $4000; Alpha: alphaOpaque);
  clWhite: TFPColor = (Red: $ffff; Green: $ffff; Blue: $ffff; Alpha: alphaOpaque);
  StandardColorsCount = 16;
(*
  // extended colors
  clMoneyGreen: TColor = ( red: $C0; green: $DC; blue: $C0; alpha: alphaOpaque);
  clSkyBlue: TColor = ( red: $F0; green: $CA; blue: $A6; alpha: alphaOpaque);
  clCream: TColor = ( red: $F0; green: $FB; blue: $FF; alpha: alphaOpaque);
  clMedGray: TColor = ( red: $A4; green: $A0; blue: $A0; alpha: alphaOpaque);
  ExtendedColorCount = 4;
  *)

  clCyan: TFPColor = (Red: $0000; Green: $ffff; Blue: $ffff; Alpha: alphaOpaque);
  clMagenta: TFPColor = (Red: $ffff; Green: $0000; Blue: $ffff; Alpha: alphaOpaque);
  clDkBlue: TFPColor = (Red: $0000; Green: $0000; Blue: $8000; Alpha: alphaOpaque);
  clDkGreen: TFPColor = (Red: $0000; Green: $8000; Blue: $0000; Alpha: alphaOpaque);
  clDkCyan: TFPColor = (Red: $0000; Green: $8000; Blue: $8000; Alpha: alphaOpaque);
  clDkRed: TFPColor = (Red: $8000; Green: $0000; Blue: $0000; Alpha: alphaOpaque);
  clDkMagenta: TFPColor = (Red: $8000; Green: $0000; Blue: $8000; Alpha: alphaOpaque);
  clDkYellow: TFPColor = (Red: $8000; Green: $8000; Blue: $0000; Alpha: alphaOpaque);
  clLtGreen: TFPColor = (Red: $0000; Green: $8000; Blue: $0000; Alpha: alphaOpaque);


  // special colors
  colTransparent: TFPColor = (Red: $0000; Green: $0000; Blue: $0000;
    Alpha: alphaTransparent);

  clNone: TColor = (Red: $0000; Green: $0000; Blue: $0000; Alpha: alphaTransparent);
  clDefault: TColor = (red: $0000; green: $0000; blue: $0000; alpha: alphaOpaque);

var
  TColoresPaleta: array[TkColorPaleta] of TColor;


// Supone Red, geen, glue en codificación de 8 bits (esto es entre 0 y 255)
function RGBToColor(red, green, blue: word): TColor;

function ColorToString(Color: TColor): ansistring;
function StringToColor(const S: shortstring): TColor;

function colores_iguales(c1, c2: TColor): boolean;


implementation

function escaleColor(c: word): word;
begin
  if (c and 1) <> 0 then
    Result := c * 16 + $FF
  else
    Result := c * 16;

end;

function ColorToString(Color: TColor): ansistring;
begin
  Result := '$' + HexStr(color.red div 16, 2) + HexStr(
    color.green div 16, 2) + HexStr(color.blue div 16, 2);
end;

function apodoToHexa(const s: shortstring): shortstring;
var
  ts: shortstring;

begin
  ts := LowerCase(s);
  if pos('cl', ts) <> 1 then
    Result := s
  else if ts = 'clblack' then
    Result := '$000000'
  else if ts = 'clmaroon' then
    Result := '$000080'
  else if ts = 'clgreen' then
    Result := '$008000'
  else if ts = 'clolive' then
    Result := '$008080'
  else if ts = 'clnavy' then
    Result := '$800000'
  else if ts = 'clpurple' then
    Result := '$800080'
  else if ts = 'clteal' then
    Result := '$808000'
  else if ts = 'clgray' then
    Result := '$808080'
  else if ts = 'clsilver' then
    Result := '$C0C0C0'
  else if ts = 'clred' then
    Result := '$0000FF'
  else if ts = 'cllime' then
    Result := '$00FF00'
  else if ts = 'clyellow' then
    Result := '$00FFFF'
  else if ts = 'clblue' then
    Result := '$FF0000'
  else if ts = 'clfuchsia' then
    Result := '$FF00FF'
  else if ts = 'claqua' then
    Result := '$FFFF00'
  else if (ts = 'clltgray') or (ts = 'clsilver') then
    Result := '$C0C0C0'
  else if (ts = 'cldkgray') or (ts = 'clgray') then
    Result := '$808080'
  else if ts = 'clwhite' then
    Result := '$FFFFFF'
  else if ts = 'clmoneygreen' then
    Result := '$C0DCC0'
  else if ts = 'clskyblue' then
    Result := '$F0CAA6'
  else if ts = 'clcream' then
    Result := '$F0FBFF'
  else if ts = 'clmedgray' then
    Result := '$A4A0A0'
  else if ts = 'clnone' then
    Result := '$1FFFFFFF'
  else if ts = 'cldefault' then
    Result := '$20000000'
  else
    Result := s;
end;

function StringToColor(const S: shortstring): TColor;
var
  ts: shortstring;
  i: integer;
  red, green, blue: word;
begin
  ts := apodoToHexa(s);
  if ts = '$1FFFFFFF' then
    Result := clNone
  else if ts = '$20000000' then
    Result := clDefault
  else
  begin

    i := StrToInt(ts) and $FFFFFF;
    red := i and $FF;
    i := i shl 8;
    green := i and $FF;
    i := i shl 8;
    blue := i and $FF;
    Result := RGBToColor(red, green, blue);

  end;
end;

function RGBToColor(red, green, blue: word): TColor;
var
  res: TColor;
begin
  res.red := escaleColor(red);
  res.green := escaleColor(green);
  res.blue := escaleColor(blue);
  res.alpha := alphaOpaque;
end;

function colores_iguales(c1, c2: TColor): boolean;
begin
  Result := (c1.red = c2.red) and (c1.green = c2.green) and
    (c1.blue = c2.blue) and (c1.alpha = c2.alpha);
end;




initialization

  TColoresPaleta[0] := clBlack;
  TColoresPaleta[1] := clMaroon;
  TColoresPaleta[2] := clGreen;
  TColoresPaleta[3] := clOlive;
  TColoresPaleta[4] := clNavy;
  TColoresPaleta[5] := clPurple;
  TColoresPaleta[6] := clTeal;
  TColoresPaleta[7] := clGray;
  TColoresPaleta[8] := clSilver;
  TColoresPaleta[9] := clRed;
  TColoresPaleta[10] := clLime;
  TColoresPaleta[11] := clYellow;
  TColoresPaleta[12] := clBlue;
  TColoresPaleta[13] := clFuchsia;
  TColoresPaleta[14] := clAqua;

end.

