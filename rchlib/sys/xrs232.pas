{+doc
+NOMBRE:xrs232
+CREACION:1.1.90
+AUTORES:lec, af. Traduccion rch.
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Manejo de la rs232 en (DOS).
+PROYECTO:rchlib

+REVISION: 10.1.1995 (ipor )
+AUTOR: rch
+DESCRIPCION:
	Correcci¢n de manejo de hilos.

-doc}

unit  xRS232;
interface
	uses DOS,ic8259,ic80x86, Buffers;

{=============================================================}
const
	WrInt: boolean = false;

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


procedure Install( bauds:integer; modo:byte; hilos: boolean; TamBufIn, TamBufOut: integer);
procedure Reset;

function PutChar(c:char):integer;
function GetChar(var c: char):integer;


{ Funciones de consulta de las l¡neas de estado }
{function dsr:boolean;}
function cts:boolean;
{
function delta_dsr:boolean;
function delta_cts:boolean;
 }
{ Procedimiento para manejo de las l¡neas }
{
procedure DTrOn;
procedure DTrOff;
}
procedure rtson;
procedure rtsoff;

procedure En_wr;
procedure Dis_wr;

{========================}
	

const
	INTERR = $0F; { habilito interrupciones cms,rce,thre,rdr }
	AddrRS232	=$03F8;
	MinBufIn =   10;
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
	BufIn,BufOut: TFiFo;

	Flag_Hilos:boolean;
	Flag_BufInCasiLleno:boolean;
	Flag_rd:boolean;
	Old_irq4,OldExitProc:pointer;

procedure wr;
procedure rd;

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
	WrInt:= false;
	Port[IntEn]:=0;
 end;

 (*#define en_wr outportb(INTEN,inportb(INTEN) | 2)
							/* habilita int_escritura*/*)
 procedure En_Wr;
 begin
	WrInt:= true;
	Port[INTEN]:=Port[INTEN] or 2; {???}
 end;

 (*#define dis_wr outportb(INTEN,inportb(INTEN) & 0xFD)
						  /* deshabilita int_escritura*/*)
 procedure Dis_Wr;
 begin
	WrInt:= false;
	Port[INTEN]:=Port[INTEN] and $FD;
 end;

 {
 (*#define dtron  outportb(MODEMCTRL,inportb(MODEMCTRL) | 1)*)
 procedure DTrOn;
 begin
	Port[MODEMCTRL]:= Port[MODEMCTRL] or 1;
 end;

(* #define dtroff outportb(MODEMCTRL,inportb(MODEMCTRL) & ~1)*)
procedure DTrOff;
begin
	Port[MODEMCTRL]:= Port[MODEMCTRL] and not(1);
end;
  }
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
{
function dsr:boolean;
begin
	dsr:= ((Port[ModemStatus] and $20)<>0) or Flag_hilos;
end;
 }
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
{$F-}
begin
	CLI;
	Port[INTEN]:=0;
	WrInt:= false;
	Port[MODEMCTRL]:=0;
	disirq(4);
	SetIntVec(IRQ4,Old_irq4);
	ExitProc:=OldExitProc;
	STI;
	BufIn.done;
	BufOut.done;
end;

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
	 {	Leo el status hasta que no haya nada,
									¨Fue esto lo que comento Casamayou?}
end;

{=================================================================}


{===================================================================}

procedure ModemInt;
begin
(*
	not(dtr) -> dsr
	not(rts) -> cts
*)
	if  cts then En_Wr
	else Dis_Wr;
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
	EOI
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
	WrInt:=true;
	Port[IntEn]:= INTERR;   { habilito interrupciones cms,rce,thre,rdr}
	Port[ModemCtrl]:=$09;  { 1001 OUT1,OUT2,RTS,DTR }
end;

{============================================================}
procedure Install( bauds:integer; modo:byte; hilos: boolean; TamBufIn, TamBufOut: integer);
var
	temp:byte;

begin

	Flag_Rd:= false;
	Flag_Hilos:= false;


	CLI;
	(*/*inicializa Buffers*/*)

	BufIn.Init( TamBufIn, SizeOf(byte));
	BufOut.Init( TamBufOut, SizeOf(byte));

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


procedure Reset;
begin
	CLI;
	BufIn.Limpiar;
	Flag_BufInCasiLleno:= false;
	BufOut.Limpiar;
	STI;
	rtson;
end;



(****************************************)
(*   PROCESOS DE ESCRITURA DE DATOS     *)
(*......................................*)

{ Proceso que escribe del buffer de salida al (IC) }
procedure wr;
var
	C: byte;
	res: integer;
begin
	res:= BufOut.Sacar(C);
	if res = ce_BufferVacio then
		Dis_wr { Desabilitamos interrupci¢n de escritura }
	else if res = ce_Ok then
		Port[AddrRS232]:= C;
end;

function PutChar(c:char):integer;
var
	res: integer;
begin

	CLI;
	res:= BufOut.Entrar(C);
	STI;

	if res= ce_BufferLleno then
		if cts then
			PutChar:=BUFFER_LLENO {/* buffer lleno */}
		else
			PutChar:=COM_DES    {/* buffer lleno com_deshabilitada*/}
	else if res= ce_Ok then
		if cts then
		begin
			PutChar:=OK;         { /* ok */}
			En_Wr;
		end
		else
			PutChar:=OK_NO_CTS

end;



(**************************************)
(*   PROCESOS DE LECTURA DE DATOS     *)
(*....................................*)

{ Lectura del IC y escritura en el buffer de entrada }
procedure rd;
var
	libre:integer;
	C: byte;
begin
	C:= Port[AddrRS232];
	if BufIn.Entrar( C ) <> ce_Ok then
		Flag_Rd:= true { Pierdo caracteres }
	else if BufIn.Lugar < MinBufIn then
	begin
		Flag_BufInCasiLleno := true;
		{dtroff;}
		rtsoff; { le hacemos ver cts = 0 a la otra m quina }
	end;
end;


{ Lectura del buffer de entrada }
function GetChar(var c: char):integer;
var
	libre: integer;
	res: integer;

begin

	{ Lectura de la bandera indicadora de p‚rdida de caracteres puesta
	a TRUE por el procedimiento (wr) si se llen¢ el Buffer }
	if Flag_rd then
	begin
		Flag_rd := false;
		res:=O_FLOW;
	end;

	CLI;
	res:= BufIn.Sacar(C);
	libre:= BufIn.Lugar;
	STI;

	if res = ce_ok then
	begin
		if Flag_BufInCasiLleno then
		begin
			if libre > 2* MinBufIn then
			begin
				Flag_BufInCasiLleno := False;
				rtson; { le hacemos ver cts=1 a la otra m quina }
			end
		end;
	end;

	GetChar:=res;
end;



end.