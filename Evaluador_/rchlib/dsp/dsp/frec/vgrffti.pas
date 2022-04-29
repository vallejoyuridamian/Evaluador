unit vgrffti;

interface
uses
	GigaVR;

type
 {	VRType = array[1..10000] of real; }
	VIType = array[1..10000] of integer;

var
	CH, C, WA: VGiganteR;
	IFACPtr: Pointer;
	N:integer;

procedure Init(NInit:LongInt);
procedure Done;

implementation

procedure EZFFT1(var WA:VGiganteR; var IFAC:VIType);
label l101,l104,l107;
const
	NTRYH:array[1..4] of integer = (4,2,3,5);
var
	TPI, ARGH, ARG1,
	CH1, SH1, DSH1, DCH1,
	CH1H
		:real;
	NL,NF,J,NTRY, NR, NQ,
	I, IB, IS, NFM1, L1,
	K1, IP, L2,
	IDO, IPM, II
		:integer;


begin
	TPI := 2*pi;
	NL := N;
	NF := 0;
	J := 0;
l101:
	J := J+1;
	if (J>4) then NTRY := NTRY+2
	else NTRY := NTRYH[J];
l104:
	NQ := NL div NTRY;
	NR := NL-NTRY*NQ;
	IF NR<>0 then goto l101;
	NF := NF+1;
	IFAC[NF+2] := NTRY;
	NL := NQ;
	IF (NTRY <> 2) then GOTO l107;
	IF (NF = 1) then GOTO l107;
	for I:= 2 to NF do {DO 106 I=2,NF}
	begin
		IB := NF-I+2;
		IFAC[IB+2] := IFAC[IB+1]
	end; {106}
	IFAC[3] := 2;
l107:
	IF (NL <> 1) then  GOTO l104;

	IFAC[1] := N;
	IFAC[2] := NF;

	ARGH := TPI/N;
	IS := 0;
	NFM1 := NF-1;
	L1 := 1;
	IF (NFM1 = 0) then Exit;
	for K1 := 1 to NFM1 do {111}
	begin
		IP := IFAC[K1+2];
		L2 := L1*IP;
		IDO := N div L2;
		IPM := IP-1;
		ARG1 := L1*ARGH;
		CH1 := 1.0;
		SH1 := 0.0;
		DCH1 := COS(ARG1);
		DSH1 := SIN(ARG1);
		for J:=1 to IPM do {110}
		begin
			CH1H := DCH1*CH1-DSH1*SH1;
			SH1 := DCH1*SH1+DSH1*CH1;
			CH1 := CH1H;
			I := IS+2;
			WA.Put(CH1,I-1);
			WA.Put(SH1,I);
			IF (IDO >= 5) then
			begin
				II:=5;
				while II<= IDO do {DO 108 II=5,IDO,2}
				begin
					I := I+2;
					WA.Put(CH1*WA.e(I-3)-SH1*WA.e(I-2),I-1);
					WA.Put(CH1*WA.e(I-2)+SH1*WA.e(I-3),I);
					II:=II+2;
				end; {108}
			end;
			IS := IS+IDO;
		end; {110}
		L1 := L2;
	end; {111}
end;




procedure Init(Ninit:LongInt);
var
	a:real;
	k:LongInt;
begin
	if Ninit <> N then
	begin
		if N > 0 then Done;
		N := Ninit;
		if N > 0 then
		begin
			CH.Init;  { n }
			C.Init; {n}
			WA.Init; {n}
			CH.assign('tmwkfft.ch');
			C.assign('tmwkfft.c');
			WA.assign('tmwkfft.wa');
			CH.Rewrite; C.Rewrite; WA.Rewrite;
			a:=0;
			for k:= 1 to N do
			begin
				CH.agregar(a);
				C.agregar(a);
				WA.agregar(a);
			end;


			GetMem(IFACPtr,15*sizeOf(Integer));
			if N > 1 then EZFFT1(WA,VIType(IFACPtr^));
		end
	end
end;

procedure Done;
begin
	if N > 0 then
	begin
		CH.Close; C.Close; WA.Close;
		FreeMem(IFACPtr,15*sizeOf(Integer));
		N:=0
	end
end;

{=====================}
begin
	N:=0;
end.