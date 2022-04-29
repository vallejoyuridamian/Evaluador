{+doc
+NOMBRE:Mouse
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Servicios de manejo del mouse (DOS).
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

Unit Mouse;

interface

uses CRT, DOS,VideoTXT, BINU;

type

	GraphCursMaskType = record
		Mask: array[0..1,0..15] of word;
		HorzHotSpot,
		VertHotSpot:integer;
	end;

var

	StandardShapeCurs,
	UpArrowCurs,
	LeftArrowCurs,
	CheckMarkCurs,
	PointingHandCurs,
	RectangularCrossCurs,
	HoursGlasCurs: GraphCursMaskType;

	MouseX,
	MouseY,
	ButtonPressCount,
	ButtonReleaseCount,
	TextScrMask,
	TextCursMask: word;

	NumMouseKeys: byte;
	MousePresent: boolean;

	MKey: (None, Left, Right, Both);

procedure ResetMouse;
procedure VirtualScreenSize(var MaxX,
									MaxY,
									CellSizeX,
									CellSizeY: word);
procedure ShowMouseCursor;
procedure HideMouseCursor;
procedure GetButtonStatus;
procedure SetMouseCursorPos(x,y: word);
procedure GetButtonPressInfo(KeyNum: word);
procedure GetButtonReleaseInfo(KeyNum: word);
procedure SetMinMaxHorzCursPos(Min,Max:word);
procedure SetMinMaxVertCursPos(Min,Max: word);
procedure SetSoftTextCursor(	TextScrMask,
								TextCursMask: word);
procedure SetHardTextCursorBig;
procedure SetHardTextCursorSmall;
procedure ReadMouseMotionCounters( var	HCount,
												VCount: word);
procedure LigthPenEmulOn;
procedure LigthPenEmulOff;
procedure SetMickeyToPixels(HRatio,Vratio:word);
procedure ConditionalOff(x1,y1,x2,y2: word);
procedure SetDoubleSpeed(Speed: word);
procedure SaveMouseDriverState;
procedure RestoreMouseDriverState;
procedure SetCrtPageNumber(page:word);
procedure GetCrtPageNumber(var page: word);

function AnyMouseKeyPressed:boolean;
function LeftMouseKeyPressed: boolean;
function RightMouseKeyPressed: boolean;
function BothMouseKeysPressed: boolean;

implementation

const
	MouseDelay = 250;
var
	MouseSaveBuffer: pointer;
	MKP,
	MouseVisible: boolean;
	MouseBufferSize: word;

	regs: Registers;

procedure DefineStandardShape;
begin
	With StandardShapeCurs do
	begin
		Mask[0,0]  := BinToWord('0011111111111111');
		Mask[0,1]  := BinToWord('0001111111111111');
		Mask[0,2]  := BinToWord('0000111111111111');
		Mask[0,3]  := BinToWord('0000011111111111');
		Mask[0,4]  := BinToWord('0000001111111111');
		Mask[0,5]  := BinToWord('0000000111111111');
		Mask[0,6]  := BinToWord('0000000011111111');
		Mask[0,7]  := BinToWord('0000000001111111');
		Mask[0,8]  := BinToWord('0000000000111111');
		Mask[0,9]  := BinToWord('0000000000011111');
		Mask[0,10] := BinToWord('0000000111111111');
		Mask[0,11] := BinToWord('0001000011111111');
		Mask[0,12] := BinToWord('0011000011111111');
		Mask[0,13] := BinToWord('1111100001111111');
		Mask[0,14] := BinToWord('1111110000111111');
		Mask[0,15] := BinToWord('1111111000011111');

		HorzHotSpot := -1;
		VertHotSpot := -1;
	end;
end;

procedure SetKeyStatus(MStatus: word);
begin
	Case MStatus of
		0: MKey := None;
		1: MKey := Left;
		2: Mkey := Right;
		3: Mkey := Both;
	end;
end;

procedure ResetMouse;
begin
	regs.ax:= 0;
	Intr($33, regs);
	with regs do
	begin
		MousePresent := ax>0;
		if MousePresent then
			NumMouseKeys := bx
		else
			NumMouseKeys :=0;
	end;
	MouseVisible := false;
end;


procedure VirtualScreenSize(var MaxX,
									MaxY,
									CellSizeX,
									CellSizeY: word);
begin
	regs.ah:= $0F;
	Intr($10, regs);
	case regs.al of
		0,1:
		begin
			MaxX := 640;
			MaxY := 200;
			CellSizeX := 16;
			CellSizeY := 8;
		end;
		2,3,7:
		begin
			MaxX := 640;
			MaxY := 200;
			CellSizeX := 8;
			CellSizeY := 8;
		end;
		4,5:
		begin
			MaxX := 640;
			MaxY := 200;
			CellSizeX := 2;
			CellSizeY := 1;
		end;
		6:
		begin
			MaxX := 640;
			MaxY := 200;
			CellSizeX := 1;
			CellSizeY := 1;
		end;
		13:
		begin
			MaxX := 640;
			MaxY := 200;
			CellSizeX := 16;
			CellSizeY := 8;
		end;
		14,15:
		begin
			MaxX := 640;
			MaxY := 350;
			CellSizeX := 1;
			CellSizeY := 1;
		end;
	end;
end;

procedure ShowMouseCursor;
begin
	if not MouseVisible then
	begin
		regs.ax:=1;
		Intr($33,regs);
		MouseVisible:=true
	end;
end;

procedure HideMouseCursor;
begin
	if MouseVisible then
	begin
		regs.ax:=2;
		Intr($33,regs);
		MOuseVisible := false;
	end;
end;

procedure GetButtonStatus;
begin
	regs.ax:=3;
	Intr($33,regs);
	with regs do
	begin
		SetKeyStatus(bx);
		MouseX:=cx;
		MouseY:=dx;
	end;
end;

procedure SetMouseCursorPos(x,y: word);
begin
	with regs do
	begin
		ax:=4;
		cx:=x;
		dx:=y;
	end;
	Intr($33,regs);
	MouseX:=x;
	MouseY:=y;
end;

procedure GetButtonPressInfo(KeyNum: word);
begin
	with regs do
	begin
		 ax:=5;
		 bx:=keyNum-1;
	end;
	Intr($33,regs);
	with regs do
	begin
		SetKeyStatus(ax);
		ButtonPressCount:= bx;
		MouseX:= cx;
		MouseY:= dx;
	end;
end;

procedure GetButtonReleaseInfo(keyNum: word);
begin
	with regs do
	begin
		ax:= 6;
		bx:= KeyNum -1;
	end;
	Intr($33,regs);
	with regs do
	begin
		SetKeyStatus(ax);
		ButtonReleaseCount := bx;
		MouseX := cx;
		MouseY := dx;
	end;
end;

procedure SetMinMaxHorzCursPos(min,max: word);
begin
	with regs do
	begin
		ax:=7;
		cx:=min;
		dx:=max;
	end;
	Intr($33,regs);
end;

procedure SetMinMaxVertCursPos(min,max: word);
begin
	with regs do
	begin
		ax:=8;
		cx:=min;
		dx:=max;
	end;
	Intr($33,regs);
end;

procedure SetGraphicsCursor(var Mask:GraphCursMaskType);
begin
	with regs do
	begin
		ax:=9;
		bx:= word(Mask.HorzHotSpot);
		cx:= word(Mask.VertHotSpot);
		dx:= ofs(Mask);
		Es:= seg(Mask);
	end;
	Intr($33,regs);
end;

procedure SetSoftTextCursor(	TextScrMask,
								TextCursMask : word);
begin
	with regs do
	begin
		ax:=10;
		bx:= 0;
		cx:= TextScrMask;
		dx:= TextCursMask;
	end;
	Intr($33,regs);
end;

procedure SetHardTextCursorBig;
begin
	with regs do
	begin
		ax:=10;
		bx:= 1;
      if Stype = Mono then
      begin
			cx:= 0;
			dx:= 13;
		end
		else
		begin
			cx:= 0;
			dx:=7;
		end;
		Intr($33,regs);
	end;
end;

procedure SetHardTextCursorSmall;
begin
	with regs do
	begin
		ax:=10;
		bx:= 1;
      if Stype = Mono then
      begin
			cx:= 12;
			dx:= 13;
		end
		else
		begin
			cx:=6;
			dx:=7;
		end;
		Intr($33,regs);
	end;
end;

procedure ReadMouseMotionCounters( var HCount, VCOunt: word);
begin
	regs.ax:= 11;
	Intr($33,regs);
	with regs do
	begin
		HCount:= cx;
		VCount:= dx;
	end;
end;

procedure LigthPenEmulOn;
begin
	regs.ax:=13;
	Intr($33,regs);
end;

procedure LigthPenEmulOff;
begin
	regs.ax:= 14;
	intr($33,regs);
end;

procedure SetMickeyToPixels(HRatio,VRatio:word);
begin
	with regs do
	begin
		ax:= 15;
		cx:= HRatio;
		Dx:= VRatio;
	end;
	Intr($33,regs);
end;

procedure ConditionalOff(x1,y1,x2,y2: word);
begin
	with regs do
	begin
		ax:=16;
		cx:=x1;
		dx:=y1;
		si:=x2;
		di:=y2;
	end;
	Intr($33,regs);
end;

procedure SetDoubleSpeed(Speed:word);
begin
	with regs do
	begin
		ax:=19;
		dx:=speed;
	end;
	Intr($33,regs);
end;

procedure GetMouseSaveSize;
begin
	regs.ax:=21;
	Intr($33,regs);
	MouseBufferSize:= regs.bx;
end;

procedure SaveMOuseDriverState;
begin
	GetMem(MouseSaveBuffer, MouseBufferSize);
	with regs do
	begin
		ax:=22;
		dx:=ofs(MouseSaveBuffer^);
		es:=seg(MouseSaveBuffer^);
	end;
	Intr($33,regs);
end;

procedure RestoreMouseDriverState;
begin
	with regs do
	begin
		ax:=23;
		dx:=ofs(MOuseSaveBuffer^);
		es:=seg(MouseSaveBuffer^);
	end;
	Intr($33,regs);
	FreeMem(MouseSaveBuffer,MouseBufferSize);
end;

procedure SetCrtPageNumber(page: word);
begin
	with regs do
	begin
		ax:=29;
		bx:=page;
	end;
	intr($33,regs);
end;

procedure GetCrtPageNumber(var page:word);
begin
	regs.ax:=23;
	Intr($33,regs);
	page:=regs.bx;
end;

function AnyMOuseKeyPressed:boolean;
begin
	if MKP then
		Delay(MouseDelay);
	GetButtonStatus;
	MKP:= Mkey<> None;
	AnyMouseKeyPressed := MKP;
end;

function LeftMouseKeyPressed: boolean;
begin
	if MKP then
		Delay(MouseDelay);
	GetButtonStatus;
	MKP:= MKey = Left;
	LeftMouseKeyPressed:= MKP;
end;

function RightMouseKeyPressed: boolean;
begin
	if MKP then
		Delay(MouseDelay);
	GetButtonStatus;
	MKP:= MKey = Right;
	RightMouseKeyPressed := MKP;
end;

function BothMouseKeysPressed: boolean;
begin
	if MKP then
		Delay(MouseDelay);
	GetButtonStatus;
	MKP:= MKey = Both;
	BothMouseKeysPressed:= MKP;
end;

begin
	ResetMouse;
	DefineStandardShape;
	{
	DefineUpArrow;
	DefineLeftArrow;
	DefineCheckMark;
	DefinePointingHand;
	DefineDiagonalCross;
	DefineHourGlass;
	}
	MKP:=false;
end.

