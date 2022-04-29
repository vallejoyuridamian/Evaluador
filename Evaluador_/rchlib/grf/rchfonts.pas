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

{$O+,F+}
{---------------
7/01/91/RCh
Esta unidad, extiende los juegos de caracteres disponibles
disponiendo del conjunto de caracteres en espa¤ol.
------------}
{$Q-}
Unit RChFonts;

interface
uses
	graph,CRT,PathDrvs, horrores;
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
	ColorPapel:word=0;
	ColorTinta:word=1;

const
	StandardFont = 1;
	SmallFont = 2;
	BoldFont = 4;
	OratorFont = 12;

const
   ItalicFont = 3;
	UnderlineFont = 11;
	GreekFont = 7;

const
	ForeingFont = 5;
	GothicFont = 6;
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

procedure OutTextXY(	X,Y:integer; TextString:string);
procedure OutText(TextString : string);

procedure SetColorTinta(nc:word);
procedure SetColorPapel(nc:word);



implementation


type
	arint = array[1..10000] of integer;
var
	p:^arint;
	tam:word;
	State:TextSettingsType;
	ax,ay:integer;
	TW,TH:integer;
	Names:array[1..20] of string[8];



procedure SetColorTinta(nc:word);
begin
	ColorTinta:=nc;
end;

procedure SetColorPapel(nc:word);
begin
	ColorPapel:=nc;
end;


procedure SetTextStyle(	Font,Direction,CharSize : Word);
var
	f:file;
	name:string;
begin
	if (State.Font <> Font)
		or(State.Direction<>Direction)
			or(State.CharSize<>CharSize) then
	begin
		FreeMem(p,tam);
		State.Font:=Font;
		if Font>0 then
		begin
			if HiResScreen then assign(f,names[Font]+'.eft')
			else assign(f,names[Font]+'.sft');
			{$I-}
			reset(f,1);
			{$I+}
			if ioresult <> 0 then
			begin
				if HiResScreen then assign(f,PathToFonts+names[Font]+'.eft')
				else assign(f,PathToFonts+names[Font]+'.sft');
				{$I-}
				reset(f,1);
				{$I+}
				if ioresult <> 0 then error(' No encuentro FUENTES de caracteres');
			end;
			tam:=FileSize(f);
			GetMem(p,tam);
			blockRead(f,p^,tam);
			close(f)
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
procedure DrawCharHXY(c:char;x,y:integer);
var
	indx:integer;
	b:^barr;
	xb,k,j,mask:integer;
	kx,ky:integer;
	tmpx,tmpy:integer;
begin
	{13/8/91 +
	ColorPapel:=GetMaxColor;
	ColorTinta:=0;
	13/8/91 -}

	if c=' ' then exit;
	if HiResScreen= true
		then
			indx:=(ord(c)-ord('1'))*8+301
		else
			indx:=(ord(c)-ord('h'))*5+528;
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
					PutPixel(tmpx+kx,tmpy+ky,ColorTinta);
			mask := mask shr 1;
			inc(tmpx,ax);
		end;
		inc(tmpy,ay);
	end;
end;

procedure DrawCharVXY(c:char;x,y:integer);
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
					PutPixel(x+k*ay+ky,y-(j*ax+kx),ColorTinta);
			mask := mask shr 1;
		end;
	end;
end;

procedure OutTextXY(	X,Y:integer; TextString:string);
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


	SetFillStyle(SolidFill,ColorPapel);
	bar(x,y,x+TextWidth(TextString)-1,y+TextHeight(TextString)-1);


	if State.Direction = HorizDir then
	begin
		for k:= 1 to Length(TextString) do
		begin
			DrawCharHXY(TextString[k],cpx,cpy);
			cpx:=cpx+TW;
		end
	end
	else
	begin
		for k:= Length(TextString) downto 1 do
		begin
			DrawCharVXY(TextString[k],cpx,cpy);
			cpy:=cpy+TW;
		end;
	end;
	moveTo(cpx,cpy);
end;

procedure OutText(TextString : string);
begin
	OutTextXY(GetX,GetY,TextString);
end;


procedure DetectScreenType;
  var
    grDriver : Integer;
    grMode   : Integer;
    ErrCode  : Integer;
  begin
    grDriver := Detect;
	 InitGraph(grDriver,grMode,PathToBGI{'c:\lng\tp'});
    ErrCode := GraphResult;
    if ErrCode = grOk then
		begin
			GetMaxColor:=Graph.GetMaxColor;
		  if GetMaxY<300 then
		  begin
			UTW:=8;UTH:=10;HiResScreen:=False;
		  end
		  else
		  begin
			UTW:=8;UTH:=16
		  end;
		  CloseGraph;
      end
    else
      WriteLn('Graphics error:',
              GraphErrorMsg(ErrCode));
end;


begin
	DetectScreenType;
	ColorTinta:=GetMaxColor;
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
end.