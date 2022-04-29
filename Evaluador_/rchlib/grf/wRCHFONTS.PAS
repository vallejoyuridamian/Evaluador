{+doc
+NOMBRE:rchfonts
+CREACION:7.1.91
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Manejo de fonts de ChiWriter. (DOS en modo grafico) 
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}


{---------------
7/01/91/RCh
Esta unidad, extiende los juegos de caracteres disponibles
disponiendo del conjunto de caracteres en espa¤ol.

23.7.2003 Intento hacer que esto funcione para la wtraxp.
------------}

Unit wRCHFONTS;

interface

uses
   Classes, Graphics, SysUtils;


const
   PathToFonts= 'C:\rch\rchlib_30\grf\';

var
	ShiftHiRes, ShiftLowRes: integer;

type
  TextSettingsType = record
     Font      : Word;
     Direction : Word;
     CharSize  : Word;
     Horiz     : Word;
     Vert      : Word;
   end;

const
//  Constant      ¦ Value ¦ Meaning
//  --------------Ï-------Ï-------------------
  DefaultFont   =   0; //   ¦ 8x8 bit mapped font
  TriplexFont   =   1; //   ¦ Stroked font
  SmallFont     =   2; //   ¦ Stroked font
  SansSerifFont =   3; //   ¦ Stroked font
  GothicFont    =   4; //   ¦ Stroked font
  HorizDir      =   0; //   ¦ Orient left to right
  VertDir       =   1; //   ¦ Orient bottom to top
  UserCharSize  =   0; //   ¦ User-defined character






const
	just_CENTRO = 1;
	just_IZQUIERDA = 0;
	just_DERECHA = 2;
	just_ARRIBA =2;
	just_ABAJO = 0;

	dir_HORIZONTAL = 0;
	dir_VERTICAL = 1;


const
	HiResScreen:boolean=True;
	GetMaxColor:word=1;

const
	ColorPapel:TColor= clWhite;
	ColorTinta:TColor= clBlack;

const
	StandardFont = 1;
	BoldFont = 4;
	OratorFont = 12;

const
   ItalicFont = 3;
	UnderlineFont = 11;
	GreekFont = 7;

const
	ForeingFont = 5;
	LineDrawFont =8;
	MathIFont = 9;
	MathIIFont = 10;
	ScriptFont = 13;

var
	UTW,UTH:integer;

procedure GetTextSettings(var TextInfo :TextSettingsType);
procedure SetTextStyle(	Font,Direction,CharSize : Word);
procedure SetTextJustify(Horiz,Vert : Word);
procedure SetUserCharSize(MultX,DivX, MultY,DivY: Word);

function TextHeight(TextString : string): Word;
function TextWidth(TextString : string): Word;

procedure OutTextXY(canvas: TCanvas;	X,Y:integer; TextString:string);
//procedure OutText(TextString : string);

procedure SetColorTinta(nc: TColor);
procedure SetColorPapel(nc: TColor);



implementation


type
   {$A-}
	arint = array[1..10000] of smallint;
   {$A+}
var
	p:^arint;
	tam:word;
	State:TextSettingsType;
	ax,ay:integer;
	TW,TH:integer;
	Names:array[1..20] of string[8];


procedure PutPixel(canvas: TCanvas; x, y : integer; ColorTinta: TColor);
begin
   canvas.Pixels[x,y]:= ColorTinta;
end;


procedure SetFillStyle(canvas: TCanvas; Estilo: TBrushStyle; Color: TColor);
begin
	canvas.Brush.Style:= Estilo;
   canvas.Brush.Color:= Color;
end;


procedure SetColorTinta(nc: TColor);
begin
	ColorTinta:=nc;
end;

procedure SetColorPapel(nc: TColor);
begin
	ColorPapel:=nc;
end;


procedure SetTextStyle(	Font,Direction,CharSize : Word);
var
	f:file of byte;
	name:string;
begin
	if (State.Font <> Font)
		or(State.Direction<>Direction)
			or(State.CharSize<>CharSize) then
	begin
      if p <> nil then
   		FreeMem(p,tam);
		State.Font:=Font;
		if Font>0 then
		begin
			if HiResScreen then assign(f,names[Font]+'.eft')
			else assign(f,names[Font]+'.sft');
			{$I-}
			reset(f);
			{$I+}
			if ioresult <> 0 then
			begin
				if HiResScreen then assign(f,PathToFonts+names[Font]+'.eft')
				else assign(f,PathToFonts+names[Font]+'.sft');
				{$I-}
				reset(f);
				{$I+}
				if ioresult <> 0 then
               raise Exception.Create(' No encuentro FUENTES de caracteres');
			end;
			tam:=FileSize(f);
			GetMem(p,tam);
			blockRead(f,p^,tam);
			closeFile(f)
		end
		else
		begin
			p:=NIL;
			tam:=0;
		end;
	end;
	State.Direction:=Direction;
	State.CharSize:=CharSize;
	ax:=CharSize;ay:=CharSize;
	TW:=UTW*ax;TH:=UTH*ay;
end;

procedure SetTextJustify(Horiz,Vert : Word);
begin
	State.Horiz:=Horiz;
	State.Vert:=Vert;
end;

procedure GetTextSettings(var TextInfo :TextSettingsType);
begin
	TextInfo:=State;
end;

procedure SetUserCharSize(MultX,DivX, MultY,DivY: Word);
begin
	ax:=Trunc(MultX/DivX);
	ay:=Trunc(MultY/DivY);
	State.CharSize:=0;
	TW:=UTW*ax;
	TH:=UTH*ay
end;

function TextHeight(TextString : string): Word;
begin
	if state.direction = HorizDir then TextHeight := Th
	else TextHeight:=TW*Length(TextString);
end;

function TextWidth(TextString : string): Word;
begin
	if state.direction = HorizDir then TextWidth:=TW*Length(TextString)
	else TextWidth:=TH
end;


type
	barr = array[0..15] of byte;


{mejorada en velocidad el 10/8/91}
procedure DrawCharHXY(canvas: TCanvas; c:char;x,y:integer);
var
	indx:smallint;
	b:^barr;
	xb,k,j,mask:smallint;
	kx,ky: smallint;
	tmpx,tmpy: smallint;
begin
	{13/8/91 +
	ColorPapel:=GetMaxColor;
	ColorTinta:=0;
	13/8/91 -}

{Cambio caracteres especiales de windows }
   if c='º' then
      c:='§';

	if c=' ' then exit;
	if HiResScreen= true
		then
			indx:=(ord(c)-ord('1'))*8+ ShiftHiRes //301
		else
			indx:=(ord(c)-ord('h'))*5+ShiftLowRes; //528;

	b:=@p^[indx];
	tmpy:=y;
	for K:=0 to UTH-1 do
	begin
		mask:=$80;
		xb:=b^[k];
		tmpx:=x;
		for j:= 0 to 7 do
		begin
			if (xb and mask)<>0 then
				for kx:=0 to ax-1 do
				for ky:=0 to ay-1 do
					PutPixel(canvas, tmpx+kx,tmpy+ky, ColorTinta);
			mask := mask shr 1;
			inc(tmpx,ax);
		end;
		inc(tmpy,ay);
	end;
end;

procedure DrawCharVXY(canvas: TCanvas; c:char;x,y:integer);
var
	indx:integer;
	b:^barr;
	xb,k,j,mask:integer;
	kx,ky:integer;

begin
	if c = ' ' then exit;
	if HiResScreen= true then indx:=(ord(c)-ord('1'))*8+301
	else  indx:=(ord(c)-ord('h'))*5+528;
	b:=@p^[indx];
	y:=y+TextHeight(c)-1;
	for K:=0 to UTH-1 do
	begin
		mask:=$80;
		xb:=b^[k];
		for j:= 0 to 7 do
		begin
			if (xb and mask)<>0 then
				for kx:=0 to ax-1 do
				for ky:=0 to ay-1 do
					PutPixel(canvas, x+k*ay+ky,y-(j*ax+kx),ColorTinta);
			mask := mask shr 1;
		end;
	end;
end;

procedure OutTextXY(canvas: TCanvas;	X,Y:integer; TextString:string);
var
	cpx,cpy,k:integer;
begin

	case State.Horiz of
		just_IZQUIERDA: {nada};
		just_CENTRO: x:=x-(TextWidth(TextString)-1) div 2;
		just_DERECHA: x:=x- (TextWidth(TextString)-1);
	end;
	case State.Vert of
		just_ARRIBA: {nada};
		just_CENTRO: y:=y-(TextHeight(TextString)-1) div 2;
		just_ABAJO: y:=y-(TextHeight(TextString)-1);
	end;

	cpx:=X;
	cpy:=Y;

{
	SetFillStyle(canvas, bsSolid, ColorPapel);
   canvas.fillRect(rect(x,y,x+TextWidth(TextString)-1,y+TextHeight(TextString)-1));
 }

	if State.Direction = HorizDir then
	begin
		for k:= 1 to Length(TextString) do
		begin
			DrawCharHXY(canvas, TextString[k],cpx,cpy);
			cpx:=cpx+TW;
		end
	end
	else
	begin
		for k:= Length(TextString) downto 1 do
		begin
			DrawCharVXY(canvas, TextString[k],cpx,cpy);
			cpy:=cpy+TW;
		end;
	end;
   canvas.moveTo(cpx,cpy);
end;

{
procedure OutText(TextString : string);
begin
	OutTextXY(GetX,GetY,TextString);
end;
 }


begin
   p:= nil;
// 	UTW:=8;UTH:=10;HiResScreen:=False;
	UTW:=8; UTH:=16;HiResScreen:= true;

	ColorTinta:=clRed;
	names[StandardFont]:='Standard';
	names[SmallFont]:='Small';
	names[ItalicFont]:= 'Italic';
	names[BoldFont]:='Bold';
	names[ForeingFont]:='Foreing';
	names[GothicFont]:='Gothic';
	names[GreekFont]:='Greek';
	names[LineDrawFont]:='LineDraw';
	names[MathIFont]:='MathI';
	names[MathIIFont]:='MathII';
	names[UnderlineFont]:='Underlin';
	names[OratorFont]:='Orator';
	names[ScriptFont]:='Script';
	p:=NIL;tam:=0;
	State.Font:=0;
	SetTextStyle(StandardFont,HorizDir,1);
	SetTextJustify(just_IZQUIERDA,just_ARRIBA);

	ShiftHiRes:= 301;
	ShiftLowRes:= 528;

end.