{+doc
+NOMBRE:videotxt
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Servicios de pantalla texto DOS.
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit videotxt;

interface
	uses
		CRT, DOS;


const
	SCR_FILAS = 25;
	SCR_COLUMNAS = 80;

var
	VidSeg:word;

Type
	ScreenType = (Mono, Color);
	ScreenChar = record
		ch: char;
		at: Byte;
	end;
	scrmem=array[1..SCR_FILAS,1..SCR_COLUMNAS] of ScreenChar;

	Pantalla = record
		s:ScrMem;
		x,y:byte;
		end;

	CursorStatusType = (SmallCursor,BigCursor,OffCursor);

var
	SType: ScreenType;

procedure CursorOff;
procedure CursorSmall;
procedure CursorBig;
function GetChar(x,y:integer):char;
procedure PutChar(x,y:integer; letra: char);
procedure InsChar(x,y: integer; letra: char);
procedure SalvePantalla(var Pant:Pantalla);
procedure RecompongaPantalla(var Pant:Pantalla);
procedure Beep;
function GetCursorStatus:CursorStatusType;
procedure SetCursorStatus(ncs:CursorStatusType);


implementation


var
	R: Registers;
	CursorStatus:CursorStatusType;

procedure Beep;
begin
	Sound(200);
	Delay(200);
	NoSound;
end;

function GetChar(x,y:integer):char;
begin
GetChar:=ScrMem(ptr(VidSeg,$00)^)[y,x].ch;
end;


procedure PutChar(x,y:integer; letra: char);
begin
	ScrMem(ptr(VidSeg,$00)^)[y,x].ch:=letra;
end;

procedure InsChar(x,y: integer; letra: char);
var
	d1, d2: pointer;
begin
	if x< SCR_COLUMNAS then
	begin
		d1:=@ScrMem(ptr(VidSeg,$00)^)[y,x];
		d2:=@ScrMem(ptr(VidSeg,$00)^)[y,x+1];
		move(d1^,d2^, (SCR_COLUMNAS-x)* SizeOf(ScreenChar));
	end;
	PutChar(x,y, letra);
end;


procedure SalvePantalla(var Pant: Pantalla);
begin
	move(ScrMem(ptr(VidSeg,$00)^),Pant.s,SizeOf(ScrMem));
	Pant.x:=WhereX;
	Pant.y:=WhereY;
end;

procedure RecompongaPantalla(var Pant:Pantalla);
begin
	move(Pant.s,ScrMem(ptr(VidSeg,$00)^),SizeOf(ScrMem));
	gotoXY(Pant.x,Pant.y);
end;

procedure CursorOff;
begin
FillChar(R,SizeOf(R),0);
with R do
	begin
	AH:=$01;
	CH:=$20;
	CL:=$20;
	end;
Intr($10,R);
CursorStatus:=OffCursor;
end;


Procedure CursorSmall;
var
	R: Registers;
begin
FillChar(R,SizeOf(R),0);
R.AH:= $01;
case SType of
	Mono:
		begin
		with R do
			begin
			CH:=12;
			CL:=13;
			end;
		end;
	Color:
		begin
		with R do
			begin
			CH:= 6;
			CL:= 7;
			end;
		end;
	end; {Case}
Intr($10,R);
CursorStatus:=SmallCursor;
end;

procedure CursorBig;
begin
FillChar(R,SizeOf(R),0);
R.AH:=$01;
R.CH:=0;
case SType of
	Mono: R.CL:=13;
	Color: R.CL:=7;
end;
Intr($10,R);
CursorStatus:=BigCursor;
end;

function GetCursorStatus:CursorStatusType;
begin
	GetCursorStatus:=CursorStatus;
end;

procedure SetCursorStatus(ncs:CursorStatusType);
begin
	case ncs of
	BigCursor: CursorBig;
	SmallCursor: CursorSmall;
	OffCursor: CursorOff;
	end;
end;

begin
FillChar(R,SizeOf(R),0);
R.AH:= $0F;
Intr($10,R);
if R.AL = 7 then
	begin
	SType:=Mono;
	VidSeg:=$B000;
	end
else
	begin
		Stype:=Color;
		VidSeg:=$B800;
	end;
CursorSmall;
end.
