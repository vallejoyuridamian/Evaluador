{+doc
+NOMBRE:hcopy02
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Servicio de copiador de la pantalla en impresora EPSON 9pin.
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

{$O+}
Unit HCopy02;
interface
	uses CRT, Graph;
{ retorna 0 si todo ok, -1 si hay error }
function HardCopy(var arch: file; mm_LongX:integer ): integer;

implementation




function HardCopy(var arch: file; mm_LongX:integer ): integer;
const
	esc = #27;
	crlf = #13#10;

var
	MaxPinX,MaxPinY:integer;
	LongY,LongX:integer;
	x1,x2,y1,y2:integer;
	DeltaY:integer;
	factorX,factorY:real;
	imperr: boolean;

procedure Set_LongY;
var
	k:real;
procedure Set_k;
var
	xasp,yasp:word;
begin
	GetAspectRatio(xasp,yasp);
	k:=(y2-y1)/(x2-x1)*yasp/xasp;
end;

begin
	Set_k;
	LongY:=trunc(LongX/k);
end;
procedure Set_MaxPins;
begin
	MaxPinX:=trunc(LongX/25.4*120);
	MaxPinY:=trunc(LongY/25.4*72);
end;

procedure Rot90ScreenCoordsInit;
begin
	SetViewPort(0,0,GetMaxX,GetMaxY,true);
	x1:=0;
	y1:=0;
	x2:=GetMaxX;
	y2:=GetMaxY;
	DeltaY:=y2-y1;
	LongX:= mm_LongX;
	Set_LongY;
	Set_MaxPins;

	FactorY:=(y2-y1)/MaxPinX;
	FactorX:=(x2-x1)/MaxPinY;
end;

procedure Rot90ScreenCoords(var x,y:integer);
var
	temp:integer;
begin
	temp:=trunc(DeltaY-x*FactorY);
	x:=trunc(y*FactorX);
	y:=temp
end;


function Rot90GetPix(x,y:integer):boolean;
begin
	Rot90ScreenCoords(x,y);
	if (x<x1)or(x2<x)or(y<y1)or(y2<y)then
		Rot90GetPix:=false
	else
	begin
		Rot90GetPix:=graph.GetPixel(x,y)<>0;
	end;
end;


function getbyt(j,i:integer):char;
const
		Bits:array [0..7] of byte=(128,64,32,16,8,4,2,1);
var
	CByte,k:byte;
begin
		i:=i shl 3;
		CByte:=0;
		for k:=0 to 7 do
		  if Rot90GetPix(j,i+k) then CByte:=CByte or Bits[k];
		getbyt:=chr(CByte);
  end;


procedure PrintByte( b: char );
var
	imprimirbyte: boolean;
	tecla: char;

begin
	imprimirbyte:= true;
	while keypressed do tecla:= readkey;
	repeat
		{$I-}
		BlockWrite( arch, b,1);
		{$I+}
		if ioresult <> 0 then
		begin
			sound(500);
			delay(100);
			nosound;
			imperr:= true;
		end
		else imprimirbyte:=false;
		if keypressed then
		begin
			tecla:= readkey;
			if UPCASE(tecla) = 'S' then
				imprimirbyte:= false;
		end;
	
	until not imprimirbyte;
end;


procedure write(s:string );
var
	k: integer;
begin
	for k:= 1 to length(s) do PrintByte(s[k]);
end;
procedure writeln( s: string );
begin
	write(s+CRLF);
end;

label
	fin;

var
	k,j:integer;
	nl:LongInt;
	tb:char;

begin
	imperr:= false;
	write(esc+#85+'0');
	if imperr then goto fin;
	write(esc+'3'+#24);
	if imperr then goto fin;
	Rot90ScreenCoordsInit;

	nl:=round(MaxPinY/8+1);
	for k:= 0 to nl-1 do
	begin
		write(esc+'L'+chr(lo(MaxPinX+1))+chr(hi(MaxPinX+1)));
		for j:= 0 to MaxPinX do
		begin
			tb:=getbyt(j,k);
			printByte(tb);
			if imperr then goto fin;
	  end;
	  {
	  write(esc+'J'+#24+#13);
	  }
	  writeln('');
	end;
	writeln(#12);

fin:
	if imperr then hardcopy:= -1
	else hardcopy:=0;
end;

begin
end.
