{+doc
+NOMBRE:rffti01
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Modulo de inicializacion para servicios de FFT
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit rfftI01;

interface
uses
	xMatDefs;

type
	VRPtrType = ^VRType;
	VRType = array[1..6000] of NReal;
	VIType = array[1..6000] of integer;

var
	CHPtr, CPtr, WAPtr, IFACPtr: pointer;
	N:word;

procedure Init(NInit:word);
procedure Done;

implementation

procedure EZFFT1(var WA:VRType; var IFAC:VIType);
label l101,l104,l107;
const
	NTRYH:array[1..4] of integer = (4,2,3,5);
var
	TPI, ARGH, ARG1,
	CH1, SH1, DSH1, DCH1,
	CH1H
		:NReal;
	NL,NF,J,NTRY, NR, NQ,
	I, IB, IS_, NFM1, L1,
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
	IS_ := 0;
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
			I := IS_+2;
			WA[I-1] := CH1;
			WA[I] := SH1;
			IF (IDO >= 5) then
			begin
				II:=5;
				while II<= IDO do {DO 108 II=5,IDO,2}
				begin
					I := I+2;
					WA[I-1] := CH1*WA[I-3]-SH1*WA[I-2];
					WA[I] := CH1*WA[I-2]+SH1*WA[I-3];
					II:=II+2;
				end; {108}
			end;
			IS_ := IS_+IDO;
		end; {110}
		L1 := L2;
	end; {111}
end;




procedure Init(Ninit:word);
begin
	if Ninit <> N then
	begin
		if N > 0 then Done;
		N := Ninit;
		if N > 0 then
		begin
			GetMem(CHPtr,n*sizeOf(NReal));
			GetMem(CPtr,n*sizeOf(NReal));
			GetMem(WAPtr,n*sizeOf(NReal));
			GetMem(IFACPtr,15*sizeOf(Integer));
			if N > 1 then EZFFT1(VRType(WAPtr^),VIType(IFACPtr^));
		end
	end
end;

procedure Done;
begin
	if N > 0 then
	begin
		FreeMem(CHPtr,n*sizeOf(NReal));
		FreeMem(CPtr,n*sizeOf(NReal));
		FreeMem(WAPtr,n*sizeOf(NReal));
		FreeMem(IFACPtr,15*sizeOf(Integer));
		N:=0
	end
end;

{=====================}
begin
	N:=0;
end.