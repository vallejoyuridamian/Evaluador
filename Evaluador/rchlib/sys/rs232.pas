{+doc
+NOMBRE:rs232
+CREACION:1.1.90
+AUTORES:lec, af. Traduccion rch.
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Manejo de la rs232 en (DOS) FUNCIONA_MAL.
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit  RS232;
interface
	uses DOS,ic8259,ic80x86;

{=============================================================}
const
	RS_NO_CAR = -1;
	RS_TOUT	=	-2;

	BUFFER_LLENO= -1;
	COM_DES  = -2;
	OK = 0;
	OK_NO_CTS = 1;
	WR_HTR = 2;
	O_FLOW = 3;

	PARIDAD_PAR = $18;
	PARIDAD_IMPAR = $08;
	PARIDAD_1 = $28;
	PARIDAD_0 = $38;
	NO_PARIDAD = $00;
	STOP_1 = $00;
	STOP_2 = $04;
	BIT_5  = $00;
	BIT_6  = $01;
	BIT_7  = $02;
	BIT_8  = $03;

const  { Definici¢n de valores m s comunes }
	Modo1 = No_Paridad or Stop_1 or Bit_8;
	Hilos1 = true;

const
	intcount: word = 0;
	intnumer: byte = 0;

{=====================================================}


procedure Install( bauds:integer; modo:byte; hilos: boolean);
procedure Reset;
function PutChar(c:char):integer;
procedure PutStr(var s:string; n:integer);
procedure InitTimeOut(STout:integer);
function GetChar:integer;
procedure  UnGetChar;
procedure CheckSum;

{ Funciones de consulta de las l¡neas de estado }
function dsr:boolean;
function cts:boolean;
function delta_dsr:boolean;
function delta_cts:boolean;

{ Procedimiento para manejo de las l¡neas }
procedure DTrOn;
procedure DTrOff;
procedure rtson;
procedure rtsoff;

procedure En_wr;
procedure Dis_wr;

{========================}
	

const
	INTERR = $0F; { habilito interrupciones cms,rce,thre,rdr }
	AddrRS232	=$03F8;
	MaxBuf = 4;
	MinBuf =   1;
	IRQ4 =		12;
	CtrlBrk	= $23;

 const
	IntEn = AddrRS232+1;
	IntId = AddrRS232+2;
	LineCtrl = AddrRS232+3;
	ModemCtrl = AddrRS232+4;
	LineStatus = AddrRS232+5;
	ModemStatus = AddrRS232+6;


 const

	RDR = 1;            { Received Data Ready }
	OE =  2;            { Overrun Error }
	PE = 4;             { Parity Error }
	FE = 8;             { Framing Error }
	BD = 16;            { Break Detect }
	THRE = 32;          { Transmiter Holding Register Empty }
	TSRE = 64;          { Transmiter Shifting Register Empty }
	TimeOut = 128;      { Time Out }



 var
	Paridad:integer;
	BufferIn,BufferOut: array[0..MaxBuf-1]of char;
	BufferInWr, BufferInRd, BufferOutWr, BufferOutRd:integer;
	Flag_tout:Boolean;
	Tout:LongInt;
	Flag_Hilos:boolean;
	RS232LLENO:boolean;
	Flag_rd:boolean;
	Old_irq4,OldExitProc:pointer;

implementation

{----------------}
{		MACROS     }
{----------------}

 (*#define wr_rs232(c) outportb(ADR_RS232, c)*)
 procedure wr_rs232(c:char);
 begin
	Port[AddrRS232]:=byte(c);
 end;

 (*#define dis  outportb(INTEN, 0)*)
 procedure Dis;
 begin
	Port[IntEn]:=0;
 end;

 (*#define en_wr outportb(INTEN,inportb(INTEN) | 2)
							/* habilita int_escritura*/*)
 procedure En_Wr;
 begin
	writeln('En_wr');
	Port[INTEN]:=Port[INTEN] or 2; {???}
 end;

 (*#define dis_wr outportb(INTEN,inportb(INTEN) & 0xFD)
						  /* deshabilita int_escritura*/*)
 procedure Dis_Wr;
 begin
	writeln('Dis_wr');
	Port[INTEN]:=Port[INTEN] and $FD;
 end;

 (*#define dtron  outportb(MODEMCTRL,inportb(MODEMCTRL) | 1)*)
 procedure DTrOn;
 begin
	Port[MODEMCTRL]:= Port[MODEMCTRL] or 1; {???}
 end;

(* #define dtroff outportb(MODEMCTRL,inportb(MODEMCTRL) & ~1)*)
procedure DTrOff;
begin
	Port[MODEMCTRL]:= Port[MODEMCTRL] and not(1);
end;

(* #define rtson outportb(MODEMCTRL,inportb(MODEMCTRL)|2)*)
procedure rtson;
begin
	Port[MODEMCTRL]:= Port[MODEMCTRL] or 2;
end;

(* #define rtsoff outportb(MODEMCTRL,inportb(MODEMCTRL)&0xfd)*)
procedure rtsoff;
begin
	Port[MODEMCTRL]:= Port[MODEMCTRL] and $FD;
end;


(* #define rd_st inportb(LINEST)*)
function rd_st:byte;
begin
	rd_st:=byte(Port[LineStatus]);
end;


(*#define wr_free (inportb(LINEST) & THRE )*)
function  WrFree:boolean;
begin
	WrFree:=(Port[LineStatus] and THRE)<>0;
end;

(* #define rd_int inportb(INTID)*)
function rd_int:char;
begin
	rd_int:=Chr(Port[INTID]);
end;

(* #define dsr (inportb(MODEMST)&0x20||Flag_hilos)*)
function dsr:boolean;
begin
	dsr:= ((Port[ModemStatus] and $20)<>0) or Flag_hilos;
end;

(* #define cts (inportb(MODEMST)&0x10||Flag_hilos)*)

function cts:boolean;
begin
	cts:= ((Port[ModemStatus] and $10)<>0) or  Flag_hilos
end;

(* #define delta_dsr (inportb(MODEMST)&0x01)*)
function delta_dsr:boolean;
begin
	delta_dsr:=(Port[ModemStatus] and 1)<>0;
end;

(* #define delta_cts (inportb(MODEMST)&0x02)*)
function delta_cts:boolean;
begin
	delta_cts:=(Port[ModemStatus] and 2)<>0;
end;

{==========================================================}
{$F+}
procedure fin;
begin
	CLI;
	Port[INTEN]:=0;
	Port[MODEMCTRL]:=0;
	disirq(4);
	{???30.8.92EOI(4);}
	SetIntVec(IRQ4,Old_irq4);
	ExitProc:=OldExitProc;
	STI;
end;
{$F-}

(*============================================*)

procedure BreakCond;  {??? 30.8.92}

var
	estado: byte;
begin
	writeln('BreakCond: ');
	repeat
		estado:= rd_st;
		write(estado,' /')
	until estado = 0;
	writeln('fin BreakCond');
	 {	Leo el status hasta que no haya dada,
									¨Fue esto lo que comento Casamayou?}
end;

{=================================================================}

procedure rd;
var
	libre:integer;
begin
	BufferIn[BufferInWr]:=CHR(Port[AddrRS232]);   Inc(BufferInWr);
	BufferInWr := BufferInWr mod MaxBuf;
	libre := BufferInRd - BufferInWr;
	if libre =0 then
	begin
		Flag_Rd := true;        (*  /* se pierden caracteres */*)
		Dec(BufferInWr);
		if BufferInWr<0 then Inc(BufferInWr,MaxBuf);
	end
	else
	begin
		if libre < 0 then
			Inc(libre, MAXBUF);
		if libre < MINBUF then
		begin
			RS232Lleno := true;
			dtroff;
		end;
	end;
end;

{================================================================}

procedure wr;
begin
	if BufferOutRd = BufferOutWr then
		rtsoff
	else
	begin
		Port[AddrRS232]:=byte(BufferOut[BufferOutRd]); Inc(BufferOutRd);
		BufferOutRd := BufferOutRd mod MaxBuf;
	end
end;

{===================================================================}

procedure ModemInt;
begin
	if not(cts) then
		Dis_Wr {deshabilita int_escritura}
	else
		if ((BufferOutWr<>BufferOutRd) and WrFree) then
			Wr;
end;


{=====================================================}
{$F+}
procedure intrs232; interrupt;
var
	c:byte;
begin
	{$R-}
	inc(intcount);
	{$R+}
	c := Port[IntId];   {rd_int}
	intnumer:= c;
	case c shr 1 of { selecciona los dos bit de identificacion }
		3:BreakCond;
		2:rd;
		1:wr;
		0:ModemInt;
	else
	begin
		writeln('OJO, int n§:', c shr 1);
		readln;
	end
	end;{case}
	EOI {???}
end;
{$F-}
{==========================================================}

procedure Bauds_RS232(bauds:integer);
var
	nb:integer;
begin
	nb:=(9600*12) div bauds; {???}
	Port[LineCtrl]:=$9F;	{ 10011111 = 9F programar baud rate }
	Port[AddrRS232]:=Lo(nb); { nb & 0xff);	/*  12 = 9600 bauds */}
	Port[AddrRS232+1]:=Hi(nb); { nb>>8);}
end;
{===========================================================}

procedure CtrLine(modo: byte);
begin
	Port[LineCtrl]:= modo; {Paridad,Stop,Long}
end;

{========================================================}

procedure En_RS232(Hilos: boolean );
begin
	Flag_Hilos:= not Hilos;
	Port[IntEn]:= INTERR;   { habilito interrupciones cms,rce,thre,rdr}
	Port[ModemCtrl]:=$09;  { 1001 OUT1,OUT2,RTS,DTR }
end;

{============================================================}

procedure Install( bauds:integer;modo: byte; hilos: boolean);
var
	temp:byte;
begin
	CLI;
	(*/*inicializa Buffers*/*)
	BufferInWr := 0;
	BufferInRd := 0;
	BufferOutRd := 0;
	BufferOutWr := 0;
	temp:=Port[LineStatus]; {rd_st; limpio el status de la linea}
	GetIntVec(IRQ4,Old_irq4);
	SetIntVec(IRQ4,@IntRS232);
	OldExitProc:=ExitProc;
	ExitProc:= @fin;       (* atexit(fin); *)
	bauds_rs232(bauds);
	ctrline(modo);
	en_rs232(hilos);
	temp:=port[LineStatus];
	temp:=Port[AddrRS232];  (*rd_rs232;*)
	temp:=port[ModemStatus];        (*  /*limpio el status del modem*/*)
	temp:=byte(rd_int); (* /*inportb(INTID)*/*)
	EnIRq(4);
	STI;
end;

{==================================================}

procedure CheckSum;
var
	temp:integer;
begin
	temp:=PutChar(Chr(Paridad));
	Paridad:=0;
end;

procedure Reset;
begin
	CLI;
	BufferInRd:=0;
	BufferInWr:=0;
	BufferOutRd:=0;
	BufferOutWr:=0;
	dtron;
	STI;
end;


function PutChar(c:char):integer;
label fin;
begin
	CLI;
	Paridad := Paridad - ord(c); {-=} {???}
	rtson;                        {/* RTS =1*/}
	if (BufferOutRd = BufferOutWr) and WrFree and cts then
		begin
			wr_rs232(c);
			PutChar:=WR_HTR;   {/* escribo en el HTR */}
			goto fin
		end;
	BufferOut[BufferOutWr] := c; Inc(BufferOutWr);
	BufferOutWr := BufferOutWr mod MaxBuf;
	if (BufferOutRd = BufferOutWr) then
	begin
		if BufferOutWr = 0 then BufferOutWr := MaxBuf-1
		else
			Dec(BufferOutWr);
		Paridad := Paridad + ord(c); {???}

		if cts then
		begin
			PutChar:=BUFFER_LLENO; {/* buffer lleno */}
			goto fin
		end
		else
		begin
			PutChar:=COM_DES;    {/* buffer lleno com_deshabilitada*/}
			goto fin
		end
	end
	else
	begin
		if cts then
		begin
			PutChar:=OK;         { /* ok */}
			goto fin
		end
		else
		begin
			PutChar:=OK_NO_CTS;
			goto fin
		end
	end;
fin:
	STI;
end;

procedure PutStr(var s:string; n:integer);
var k:integer;
begin
	k:=1;
	if n<>0 then
		while (n<>0) and (ShortInt(PutChar(s[k]))>0) do
		begin
			dec(n);
			inc(k);
		end
	else
		while (s[k]<>#0) and (ShortInt(PutChar(s[k]))>0) do
			inc(k);
end;

procedure InitTimeOut(STout:integer);
begin
	Tout:= STout;
	Flag_tout := False;
end;

procedure time(var x:LongInt);
var	h, m, s, hund : Word;
begin
	GetTime(h,m,s,hund);
	x:=(h*60+m)*60+s;
end;


function test_tout:integer;
label fin;

var
	t0,t:LongInt;
	h, m, s, hund : Word;

begin
	if Tout = 0  then
	begin
		test_tout:=RS_NO_CAR;
		goto fin
	end;
	if not(Flag_tout) then
	begin
		time(t0);
		Flag_tout := true;
		test_tout:=-1;
		goto fin
	end;
	time(t);
	if t<t0 then
		t := t + 24*3600;
	if t-t0 < Tout  then
	begin
		test_tout:= RS_NO_CAR;
		goto fin
	end;
	test_tout:=RS_TOUT;
fin:
end;

function GetChar:integer;
label fin;

var
	c:char;
	libre:integer;
	res: integer;

begin

	if Flag_rd then
	begin
		Flag_rd := false;
		res:=O_FLOW;   { estoy perdiendo caracteres }
		goto fin
	end;

	if BufferInRd = BufferInWr then
	begin
		res:= test_tout;  { no estoy recibiendo }
		goto fin
	end;
	Flag_tout := false;
	c := BufferIn[BufferInRd]; inc(BufferInRd);
	BufferInRd := BufferInRd mod MaxBuf;
	if Rs232lleno then
	begin
		libre := BufferInRd - BufferInWr;
		if libre <0 then
			libre := libre + MaxBuf;
		if libre >2* MinBuf then
		begin
			Rs232lleno := False;
			dtron;
		end
	end;
	res:=ord(c);
fin:  GetChar:=res;
end;


procedure  UnGetChar;
begin
	CLI;
	dec(BufferInRd);
	If BufferInRd<0 then BufferInRd:= MaxBuf-1;
	STI;
end;

end.