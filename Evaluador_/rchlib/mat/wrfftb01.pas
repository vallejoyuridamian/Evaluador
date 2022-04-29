{+doc
+NOMBRE:rfftb01
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Fast Fourier Transform-INVERSA.
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

Unit WRFFTB01;
interface
uses
	xMatDefs,
	WRFFTI01;

procedure FFTB(	var R;var AZERO: NReal;
						var A,B);

implementation

{
		SUBROUTINE RADB2(IDO,L1,CC,CH,WA1);
C***BEGIN PROLOGUE  RADB2;
C***REFER TO  RFFTB;
C***ROUTINES CALLED  (NONE);
C***END PROLOGUE  RADB2;
      DIMENSION       CC[CCidx(IDO,2,L1)           ,CH[CHidx(IDO,L1,2)           ,;
     1                WA1(*);
C***FIRST EXECUTABLE STATEMENT  RADB2;
}


procedure RADB2(IDO,L1:integer; var CC,CH,WA1: VRType);

label
	l101,l102,l103,l104,l105,l106,l107,l108,l109,l110,l111;
function CCidx(k,j,h:integer):integer;
	begin CCidx:= k+IDO*(j-1+2*(h-1)) end;
function CHidx(k,j,h:integer):integer;
	begin CHidx:= k+IDO*(j-1+L1*(h-1)) end;

var
	k,IDP2,I,IC:integer;
	TR2,TI2:NReal;

begin
	for K:= 1 to L1 do {101}
	begin
		CH[CHidx(1,K,1)] := CC[CCidx(1,1,K)]+CC[CCidx(IDO,2,K)];
		CH[CHidx(1,K,2)] := CC[CCidx(1,1,K)]-CC[CCidx(IDO,2,K)];
	l101:{ CONTINUE}
	end;
	IF (IDO-2) < 0 then goto l107;
	if (IDO-2) = 0 then goto l105;
	l102:
	IDP2 := IDO+2;
	IF((IDO-1) div 2) < L1 then goto  l108;
	for k:= 1 to L1 do {104}
	begin
		{CDIR$ IVDEP;}
		I:=3;
		while I<= IDO do {  DO 103 I:=3,IDO,2;}
		begin
			IC := IDP2-I;
			CH[CHidx(I-1,K,1)] := CC[CCidx(I-1,1,K)]+CC[CCidx(IC-1,2,K)];
			TR2 := CC[CCidx(I-1,1,K)]-CC[CCidx(IC-1,2,K)];
			CH[CHidx(I,K,1)] := CC[CCidx(I,1,K)]-CC[CCidx(IC,2,K)];
			TI2 := CC[CCidx(I,1,K)]+CC[CCidx(IC,2,K)];
			CH[CHidx(I-1,K,2)] := WA1[I-2]*TR2-WA1[I-1]*TI2;
			CH[CHidx(I,K,2)] := WA1[I-2]*TI2+WA1[I-1]*TR2;
			I:=I+2;
		l103:{CONTINUE}
		end;
	l104: {CONTINUE}
	end;
	goto  l111;
	l108:
	I:=3;
	while I<= IDO do {DO 110 I:=3,IDO,2}
	begin
		IC := IDP2-I;
		{CDIR$ IVDEP;}
		for K:= 1 to L1 do {109}
		begin
			CH[CHidx(I-1,K,1)] := CC[CCidx(I-1,1,K)]+CC[CCidx(IC-1,2,K)];
			TR2 := CC[CCidx(I-1,1,K)]-CC[CCidx(IC-1,2,K)];
			CH[CHidx(I,K,1)] := CC[CCidx(I,1,K)]-CC[CCidx(IC,2,K)];
			TI2 := CC[CCidx(I,1,K)]+CC[CCidx(IC,2,K)];
			CH[CHidx(I-1,K,2)] := WA1[I-2]*TR2-WA1[I-1]*TI2;
			CH[CHidx(I,K,2)] := WA1[I-2]*TI2+WA1[I-1]*TR2;
		l109:{ CONTINUE}
		end;
		I:=I+3;
	l110:{CONTINUE}
	end;
	l111:
	IF (IDO mod 2) = 1 then exit;
	l105:
	for K:=1 to L1 do {106}
	begin
		CH[CHidx(IDO,K,1)] := CC[CCidx(IDO,1,K)]+CC[CCidx(IDO,1,K)];
		CH[CHidx(IDO,K,2)] := -(CC[CCidx(1,2,K)]+CC[CCidx(1,2,K)]);
	l106: {CONTINUE}
	end;
l107:
end;

{
		SUBROUTINE RADB3(IDO,L1,CC,CH,WA1,WA2);
C***BEGIN PROLOGUE  RADB3;
C***REFER TO  RFFTB;
C***ROUTINES CALLED  (NONE);
C***END PROLOGUE  RADB3;
      DIMENSION       CC[CCidx(IDO,3,L1)]           ,CH[CHidx(IDO,L1,3)]           ,;
     1                WA1(*)     ,WA2(*);
C***FIRST EXECUTABLE STATEMENT  RADB3;
}
procedure RADB3(IDO,L1:integer; var CC,CH,WA1,WA2: VRType);
function CHidx(k,j,h:integer):integer;
	begin CHidx:= k+IDO*(j-1+(h-1)*L1) end;
function CCidx(k,j,h:integer):integer;
	begin CCidx:= k+IDO*(j-1+(h-1)*3) end;

label
	l101,l102,l103,l104,l105,l106,l107,l108,l109,l110;
var
	DR2,DI2,DR3,DI3,CI2, TAUR, TAUI, CR2:NReal;
	TR2,TI2{,TR3,TI3},CI3, CR3:NReal;
	K,I,IC,IDP2:integer;
begin
	TAUR := -0.5;
	TAUI := 0.5*SQRT(3.0);
	for k:= 1 to L1 do {101}
	begin
		TR2 := CC[CCidx(IDO,2,K)]+CC[CCidx(IDO,2,K)];
		CR2 := CC[CCidx(1,1,K)]+TAUR*TR2;
		CH[CHidx(1,K,1)] := CC[CCidx(1,1,K)]+TR2;
		CI3 := TAUI*(CC[CCidx(1,3,K)]+CC[CCidx(1,3,K)]);
		CH[CHidx(1,K,2)] := CR2-CI3;
		CH[CHidx(1,K,3)] := CR2+CI3;
	l101: {CONTINUE;}
	end;
	IF (IDO = 1) then Exit;
	IDP2 := IDO+2;
	IF(((IDO-1) div 2) < L1) then goto  l104;
	for K:= 1 to L1 do {103}
	begin
	{CDIR$ IVDEP;?????????}
		I:= 3;
		while I<= IDO do {102 I:=3,IDO,2}
		begin
			IC := IDP2-I;
			TR2 := CC[CCidx(I-1,3,K)]+CC[CCidx(IC-1,2,K)];
			CR2 := CC[CCidx(I-1,1,K)]+TAUR*TR2;
			CH[CHidx(I-1,K,1)] := CC[CCidx(I-1,1,K)]+TR2;
			TI2 := CC[CCidx(I,3,K)]-CC[CCidx(IC,2,K)];
			CI2 := CC[CCidx(I,1,K)]+TAUR*TI2;
			CH[CHidx(I,K,1)] := CC[CCidx(I,1,K)]+TI2;
			CR3 := TAUI*(CC[CCidx(I-1,3,K)]-CC[CCidx(IC-1,2,K)]);
			CI3 := TAUI*(CC[CCidx(I,3,K)]+CC[CCidx(IC,2,K)]);
			DR2 := CR2-CI3;
			DR3 := CR2+CI3;
			DI2 := CI2+CR3;
			DI3 := CI2-CR3;
			CH[CHidx(I-1,K,2)] := WA1[I-2]*DR2-WA1[I-1]*DI2;
			CH[CHidx(I,K,2)] := WA1[I-2]*DI2+WA1[I-1]*DR2;
			CH[CHidx(I-1,K,3)] := WA2[I-2]*DR3-WA2[I-1]*DI3;
			CH[CHidx(I,K,3)] := WA2[I-2]*DI3+WA2[I-1]*DR3;
			I:=I+2;
			l102: {CONTINUE}
		end;
		l103: {CONTINUE}
	end;
	exit;
	l104:
	I:= 3;
	while I<= IDO do {106 I:=3,IDO,2}
	begin
		IC := IDP2-I;
		{CDIR$ IVDEP;??????????????}
		for K:= 1 to L1 do {105}
		begin
			TR2 := CC[CCidx(I-1,3,K)]+CC[CCidx(IC-1,2,K)];
			CR2 := CC[CCidx(I-1,1,K)]+TAUR*TR2;
			CH[CHidx(I-1,K,1)] := CC[CCidx(I-1,1,K)]+TR2;
			TI2 := CC[CCidx(I,3,K)]-CC[CCidx(IC,2,K)];
			CI2 := CC[CCidx(I,1,K)]+TAUR*TI2;
			CH[CHidx(I,K,1)] := CC[CCidx(I,1,K)]+TI2;
			CR3 := TAUI*(CC[CCidx(I-1,3,K)]-CC[CCidx(IC-1,2,K)]);
			CI3 := TAUI*(CC[CCidx(I,3,K)]+CC[CCidx(IC,2,K)]);
			DR2 := CR2-CI3;
			DR3 := CR2+CI3;
			DI2 := CI2+CR3;
			DI3 := CI2-CR3;
			CH[CHidx(I-1,K,2)] := WA1[I-2]*DR2-WA1[I-1]*DI2;
			CH[CHidx(I,K,2)] := WA1[I-2]*DI2+WA1[I-1]*DR2;
			CH[CHidx(I-1,K,3)] := WA2[I-2]*DR3-WA2[I-1]*DI3;
			CH[CHidx(I,K,3)] := WA2[I-2]*DI3+WA2[I-1]*DR3;
			l105:
		end;
		I:=I+2;
		l106:
	end;
	exit;
end;

{
      SUBROUTINE RADB4(IDO,L1,CC,CH,WA1,WA2,WA3);
C***BEGIN PROLOGUE  RADB4;
C***REFER TO  RFFTB;
C***ROUTINES CALLED  (NONE);
C***END PROLOGUE  RADB4;
      DIMENSION       CC[CCidx(IDO,4,L1)           ,CH[CHidx(IDO,L1,4)           ,;
     1                WA1(*)     ,WA2(*)     ,WA3(*);
C***FIRST EXECUTABLE STATEMENT  RADB4;
}
procedure RADB4(IDO,L1:integer; var CC,CH,WA1,WA2,WA3: VRType);
function CHidx(k,j,h:integer):integer;
	begin CHidx:= k+IDO*(j-1+(h-1)*L1) end;
function CCidx(k,j,h:integer):integer;
	begin CCidx:= k+IDO*(j-1+(h-1)*4) end;

label
	l100,l101,l102,l103,l104,l105,l106,l107,l108,l109,
	l110,l111;
var
	{DR2,DI2,DR3,DI3,}CI2,CR4,CI4,CR2:NReal;
	SQRT2,TR4,TR1,TR2,TI2,TI1,TI4,TR3,TI3,CI3, CR3:NReal;
	K,I,IC,IDP2:integer;
begin
	SQRT2 := SQRT(2);
	for k:= 1 to L1 do {101}
	begin
		TR1 := CC[CCidx(1,1,K)]-CC[CCidx(IDO,4,K)];
		TR2 := CC[CCidx(1,1,K)]+CC[CCidx(IDO,4,K)];
		TR3 := CC[CCidx(IDO,2,K)]+CC[CCidx(IDO,2,K)];
		TR4 := CC[CCidx(1,3,K)]+CC[CCidx(1,3,K)];
		CH[CHidx(1,K,1)] := TR2+TR3;
		CH[CHidx(1,K,2)] := TR1-TR4;
		CH[CHidx(1,K,3)] := TR2-TR3;
		CH[CHidx(1,K,4)] := TR1+TR4;
		l101:
	end;
	IF (IDO-2) < 0 then goto l107;
	IF (IDO-2) = 0 then goto l105;
	l102:
	IDP2 := IDO+2;
	IF(((IDO-1) div 2) <L1) then goto  l108;
	for K:= 1 to L1 do {104}
	begin
		{CDIR$ IVDEP;????????????}
		I:= 3;
		while I<= IDO do { 103 I:=3,IDO,2}
		begin
			IC := IDP2-I;
			TI1 := CC[CCidx(I,1,K)]+CC[CCidx(IC,4,K)];
			TI2 := CC[CCidx(I,1,K)]-CC[CCidx(IC,4,K)];
			TI3 := CC[CCidx(I,3,K)]-CC[CCidx(IC,2,K)];
			TR4 := CC[CCidx(I,3,K)]+CC[CCidx(IC,2,K)];
			TR1 := CC[CCidx(I-1,1,K)]-CC[CCidx(IC-1,4,K)];
			TR2 := CC[CCidx(I-1,1,K)]+CC[CCidx(IC-1,4,K)];
			TI4 := CC[CCidx(I-1,3,K)]-CC[CCidx(IC-1,2,K)];
			TR3 := CC[CCidx(I-1,3,K)]+CC[CCidx(IC-1,2,K)];
			CH[CHidx(I-1,K,1)] := TR2+TR3;
			CR3 := TR2-TR3;
			CH[CHidx(I,K,1)] := TI2+TI3;
			CI3 := TI2-TI3;
			CR2 := TR1-TR4;
			CR4 := TR1+TR4;
			CI2 := TI1+TI4;
			CI4 := TI1-TI4;
			CH[CHidx(I-1,K,2)] := WA1[I-2]*CR2-WA1[I-1]*CI2;
			CH[CHidx(I,K,2)] := WA1[I-2]*CI2+WA1[I-1]*CR2;
			CH[CHidx(I-1,K,3)] := WA2[I-2]*CR3-WA2[I-1]*CI3;
			CH[CHidx(I,K,3)] := WA2[I-2]*CI3+WA2[I-1]*CR3;
			CH[CHidx(I-1,K,4)] := WA3[I-2]*CR4-WA3[I-1]*CI4;
			CH[CHidx(I,K,4)] := WA3[I-2]*CI4+WA3[I-1]*CR4;
			I:=I+2;
			l103:
		end;
		l104:
	end;
	goto  l111;
	l108:
	I:=3;
	while I<= IDO do {110 I:=3,IDO,2}
	begin
		IC := IDP2-I;
		{CDIR$ IVDEP????????????????}
		for K:= 1 to L1 do {109}
		begin
			TI1 := CC[CCidx(I,1,K)]+CC[CCidx(IC,4,K)];
			TI2 := CC[CCidx(I,1,K)]-CC[CCidx(IC,4,K)];
			TI3 := CC[CCidx(I,3,K)]-CC[CCidx(IC,2,K)];
			TR4 := CC[CCidx(I,3,K)]+CC[CCidx(IC,2,K)];
			TR1 := CC[CCidx(I-1,1,K)]-CC[CCidx(IC-1,4,K)];
			TR2 := CC[CCidx(I-1,1,K)]+CC[CCidx(IC-1,4,K)];
			TI4 := CC[CCidx(I-1,3,K)]-CC[CCidx(IC-1,2,K)];
			TR3 := CC[CCidx(I-1,3,K)]+CC[CCidx(IC-1,2,K)];
			CH[CHidx(I-1,K,1)] := TR2+TR3;
			CR3 := TR2-TR3;
			CH[CHidx(I,K,1)] := TI2+TI3;
			CI3 := TI2-TI3;
			CR2 := TR1-TR4;
			CR4 := TR1+TR4;
			CI2 := TI1+TI4;
			CI4 := TI1-TI4;
			CH[CHidx(I-1,K,2)] := WA1[I-2]*CR2-WA1[I-1]*CI2;
			CH[CHidx(I,K,2)] := WA1[I-2]*CI2+WA1[I-1]*CR2;
			CH[CHidx(I-1,K,3)] := WA2[I-2]*CR3-WA2[I-1]*CI3;
			CH[CHidx(I,K,3)] := WA2[I-2]*CI3+WA2[I-1]*CR3;
			CH[CHidx(I-1,K,4)] := WA3[I-2]*CR4-WA3[I-1]*CI4;
			CH[CHidx(I,K,4)] := WA3[I-2]*CI4+WA3[I-1]*CR4;
			l109:
		end;
		I:=I+2;
		l110:
	end;
	l111:
	if (IDO mod 2) = 1 then exit;
	l105:
	for K:= 1 to L1 do {106}
	begin
		TI1 := CC[CCidx(1,2,K)]+CC[CCidx(1,4,K)];
		TI2 := CC[CCidx(1,4,K)]-CC[CCidx(1,2,K)];
		TR1 := CC[CCidx(IDO,1,K)]-CC[CCidx(IDO,3,K)];
		TR2 := CC[CCidx(IDO,1,K)]+CC[CCidx(IDO,3,K)];
		CH[CHidx(IDO,K,1)] := TR2+TR2;
		CH[CHidx(IDO,K,2)] := SQRT2*(TR1-TI1);
		CH[CHidx(IDO,K,3)] := TI2+TI2;
		CH[CHidx(IDO,K,4)] := -SQRT2*(TR1+TI1);
		l106:
	end;
	l107:
end;

{
      SUBROUTINE RADB5(IDO,L1,CC,CH,WA1,WA2,WA3,WA4);
C***BEGIN PROLOGUE  RADB5;
C***REFER TO  RFFTB;
C***ROUTINES CALLED  (NONE);
C***END PROLOGUE  RADB5;
      DIMENSION       CC[CCidx(IDO,5,L1)           ,CH[CHidx(IDO,L1,5)           ,;
	  1                WA1(*)     ,WA2(*)     ,WA3(*)     ,WA4(*);

C***FIRST EXECUTABLE STATEMENT  RADB5;
}
procedure RADB5(IDO,L1:integer; var CC,CH,WA1,WA2,WA3,WA4: VRType);
function CHidx(k,j,h:integer):integer;
	begin CHidx:= k+IDO*(j-1+(h-1)*L1) end;
function CCidx(k,j,h:integer):integer;
	begin CCidx:= k+IDO*(j-1+(h-1)*5) end;

label
	l100,l101,l102,l103,l104,l105,l106,l107,l108,l109,
	l110,l111;
var
	DR2,DR3,DR4,DR5,
	DI2,DI3,DI4,DI5,
	CR2,CR3,CR4,CR5:NReal;
	CI2,CI3,CI4,CI5:NReal;
	TR1,TR2,TR3,TR4,TR5,TR11,TR12:NReal;
	TI1,TI2,TI3,TI4,TI5,TI11,TI12:NReal;
	SQRT2:NReal;
	K,I,IC,IDP2:integer;
begin
	TR11 := SIN(0.1*PI);
	TI11 := SIN(0.4*PI);
	TR12 := -SIN(0.3*PI);
	TI12 := SIN(0.2*PI);
	for K:=1 to L1 do {101}
	begin
		TI5 := CC[CCidx(1,3,K)]+CC[CCidx(1,3,K)];
		TI4 := CC[CCidx(1,5,K)]+CC[CCidx(1,5,K)];
		TR2 := CC[CCidx(IDO,2,K)]+CC[CCidx(IDO,2,K)];
		TR3 := CC[CCidx(IDO,4,K)]+CC[CCidx(IDO,4,K)];
		CH[CHidx(1,K,1)] := CC[CCidx(1,1,K)]+TR2+TR3;
		CR2 := CC[CCidx(1,1,K)]+TR11*TR2+TR12*TR3;
		CR3 := CC[CCidx(1,1,K)]+TR12*TR2+TR11*TR3;
		CI5 := TI11*TI5+TI12*TI4;
		CI4 := TI12*TI5-TI11*TI4;
		CH[CHidx(1,K,2)] := CR2-CI5;
		CH[CHidx(1,K,3)] := CR3-CI4;
		CH[CHidx(1,K,4)] := CR3+CI4;
		CH[CHidx(1,K,5)] := CR2+CI5;
		l101:
	end;
	IF (IDO = 1) then exit;
	IDP2 := IDO+2;
	IF(((IDO-1) div 2) < L1) then  goto  l104;
	for K:= 1 to L1 do {103}
	begin
		{CDIR$ IVDEP;????????????}
		I:= 3;
		while I<= IDO do {102 I:=3,IDO,2}
		begin
			IC := IDP2-I;
			TI5 := CC[CCidx(I,3,K)]+CC[CCidx(IC,2,K)];
			TI2 := CC[CCidx(I,3,K)]-CC[CCidx(IC,2,K)];
			TI4 := CC[CCidx(I,5,K)]+CC[CCidx(IC,4,K)];
			TI3 := CC[CCidx(I,5,K)]-CC[CCidx(IC,4,K)];
			TR5 := CC[CCidx(I-1,3,K)]-CC[CCidx(IC-1,2,K)];
			TR2 := CC[CCidx(I-1,3,K)]+CC[CCidx(IC-1,2,K)];
			TR4 := CC[CCidx(I-1,5,K)]-CC[CCidx(IC-1,4,K)];
			TR3 := CC[CCidx(I-1,5,K)]+CC[CCidx(IC-1,4,K)];
			CH[CHidx(I-1,K,1)] := CC[CCidx(I-1,1,K)]+TR2+TR3;
			CH[CHidx(I,K,1)] := CC[CCidx(I,1,K)]+TI2+TI3;
			CR2 := CC[CCidx(I-1,1,K)]+TR11*TR2+TR12*TR3;
			CI2 := CC[CCidx(I,1,K)]+TR11*TI2+TR12*TI3;
			CR3 := CC[CCidx(I-1,1,K)]+TR12*TR2+TR11*TR3;
			CI3 := CC[CCidx(I,1,K)]+TR12*TI2+TR11*TI3;
			CR5 := TI11*TR5+TI12*TR4;
			CI5 := TI11*TI5+TI12*TI4;
			CR4 := TI12*TR5-TI11*TR4;
			CI4 := TI12*TI5-TI11*TI4;
			DR3 := CR3-CI4;
			DR4 := CR3+CI4;
			DI3 := CI3+CR4;
			DI4 := CI3-CR4;
			DR5 := CR2+CI5;
			DR2 := CR2-CI5;
			DI5 := CI2-CR5;
			DI2 := CI2+CR5;
			CH[CHidx(I-1,K,2)] := WA1[I-2]*DR2-WA1[I-1]*DI2;
			CH[CHidx(I,K,2)] := WA1[I-2]*DI2+WA1[I-1]*DR2;
			CH[CHidx(I-1,K,3)] := WA2[I-2]*DR3-WA2[I-1]*DI3;
			CH[CHidx(I,K,3)] := WA2[I-2]*DI3+WA2[I-1]*DR3;
			CH[CHidx(I-1,K,4)] := WA3[I-2]*DR4-WA3[I-1]*DI4;
			CH[CHidx(I,K,4)] := WA3[I-2]*DI4+WA3[I-1]*DR4;
			CH[CHidx(I-1,K,5)] := WA4[I-2]*DR5-WA4[I-1]*DI5;
			CH[CHidx(I,K,5)] := WA4[I-2]*DI5+WA4[I-1]*DR5;
			I:= I+2;
			l102:
		end;
		l103:
	end;
	exit;
	l104:
	I:=3;
	while I<= IDO do {106}
	begin
		IC := IDP2-I;
		{CDIR$ IVDEP;?????????}
		for K:= 1 to L1 do {105}
		begin
			TI5 := CC[CCidx(I,3,K)]+CC[CCidx(IC,2,K)];
			TI2 := CC[CCidx(I,3,K)]-CC[CCidx(IC,2,K)];
			TI4 := CC[CCidx(I,5,K)]+CC[CCidx(IC,4,K)];
			TI3 := CC[CCidx(I,5,K)]-CC[CCidx(IC,4,K)];
			TR5 := CC[CCidx(I-1,3,K)]-CC[CCidx(IC-1,2,K)];
			TR2 := CC[CCidx(I-1,3,K)]+CC[CCidx(IC-1,2,K)];
			TR4 := CC[CCidx(I-1,5,K)]-CC[CCidx(IC-1,4,K)];
			TR3 := CC[CCidx(I-1,5,K)]+CC[CCidx(IC-1,4,K)];
			CH[CHidx(I-1,K,1)] := CC[CCidx(I-1,1,K)]+TR2+TR3;
			CH[CHidx(I,K,1)] := CC[CCidx(I,1,K)]+TI2+TI3;
			CR2 := CC[CCidx(I-1,1,K)]+TR11*TR2+TR12*TR3;
			CI2 := CC[CCidx(I,1,K)]+TR11*TI2+TR12*TI3;
			CR3 := CC[CCidx(I-1,1,K)]+TR12*TR2+TR11*TR3;
			CI3 := CC[CCidx(I,1,K)]+TR12*TI2+TR11*TI3;
			CR5 := TI11*TR5+TI12*TR4;
			CI5 := TI11*TI5+TI12*TI4;
			CR4 := TI12*TR5-TI11*TR4;
			CI4 := TI12*TI5-TI11*TI4;
			DR3 := CR3-CI4;
			DR4 := CR3+CI4;
			DI3 := CI3+CR4;
			DI4 := CI3-CR4;
			DR5 := CR2+CI5;
			DR2 := CR2-CI5;
			DI5 := CI2-CR5;
			DI2 := CI2+CR5;
			CH[CHidx(I-1,K,2)] := WA1[I-2]*DR2-WA1[I-1]*DI2;
			CH[CHidx(I,K,2)] := WA1[I-2]*DI2+WA1[I-1]*DR2;
			CH[CHidx(I-1,K,3)] := WA2[I-2]*DR3-WA2[I-1]*DI3;
			CH[CHidx(I,K,3)] := WA2[I-2]*DI3+WA2[I-1]*DR3;
			CH[CHidx(I-1,K,4)] := WA3[I-2]*DR4-WA3[I-1]*DI4;
			CH[CHidx(I,K,4)] := WA3[I-2]*DI4+WA3[I-1]*DR4;
			CH[CHidx(I-1,K,5)] := WA4[I-2]*DR5-WA4[I-1]*DI5;
			CH[CHidx(I,K,5)] := WA4[I-2]*DI5+WA4[I-1]*DR5;
			l105:
		end;
		I:=I+2;
		l106:
	end;
end;

{
      SUBROUTINE RADBG(IDO,IP,L1,IDL1,CC,C1,C2,CH,CH2,WA);
C***BEGIN PROLOGUE  RADBG;
C***REFER TO  RFFTB;
C***ROUTINES CALLED  (NONE);
C***END PROLOGUE  RADBG;
      DIMENSION       CH[CHidx(IDO,L1,IP)          ,CC[CCidx(IDO,IP,L1)          ,;
     1                C1[C1idx(IDO,L1,IP)          ,C2[C2idx(IDL1,IP),;
     2                CH2[CH2idx(IDL1,IP)           ,WA(*);
C***FIRST EXECUTABLE STATEMENT  RADBG;
}

procedure RADBG(IDO,IP,L1,IDL1:integer; var CC,C1,C2,CH,CH2,WA: VRType);
function CHidx(k,j,h:integer):integer;
	begin CHidx:= k+IDO*(j-1+(h-1)*L1) end;
function CCidx(k,j,h:integer):integer;
	begin CCidx:= k+IDO*(j-1+(h-1)*IP) end;
function C1idx(k,j,h:integer):integer;
	begin C1idx:= k+IDO*(j-1+(h-1)*L1) end;
function C2idx(k,j:integer):integer;
	begin C2idx:= k+IDL1*(j-1) end;
function CH2idx(k,j:integer):integer;
	begin CH2idx:= k+IDL1*(j-1) end;


label
	l100,l101,l102,l103,l104,l105,l106,l107,l108,l109,
	l110,l111,l112,l113,l114,l115,l116,l117,l118,l119,
	l120,l121,l122,l123,l124,l125,l126,l127,l128,l129,
	l130,l131,l132,l133,l134,l135,l136,l137,l138,l139,
	l140,l142,l143;

var
	ARG,DCP,DSP,TPI:NReal;
	IDIJ,IS_,IK,LC,L,NBD,IDP2,IC,J2,JC,J,I,K,IPPH,IPP2:integer;
	AR2H,AR2,AI2,DS2,DC2,AR1H,AR1,AI1:NReal;
begin
	TPI := 2*PI;
	ARG := TPI/IP;
	DCP := COS(ARG);
	DSP := SIN(ARG);
	IDP2 := IDO+2;
	NBD := (IDO-1) div 2;
	IPP2 := IP+2;
	IPPH := (IP+1) div 2;
	IF (IDO < L1) then goto  l103;
	for K:= 1 to L1 do {102}
		for I:= 1 to IDO do {101}
			CH[CHidx(I,K,1)] := CC[CCidx(I,1,K)];
	l101:
	l102:
	goto  l106;
	l103:
	for I:= 1 to IDO do {105}
		for K:= 1 to L1 do {104}
			CH[CHidx(I,K,1)] := CC[CCidx(I,1,K)];
	l104:
	l105:
	l106:
	for J:= 2 to IPPH do {108}
	begin
		JC := IPP2-J;
		J2 := J+J;
		for K:= 1 to L1 do {107}
		begin
			CH[CHidx(1,K,J)] := CC[CCidx(IDO,J2-2,K)]+CC[CCidx(IDO,J2-2,K)];
			CH[CHidx(1,K,JC)] := CC[CCidx(1,J2-1,K)]+CC[CCidx(1,J2-1,K)];
			l107:
		end;
		l108:
	end;
	IF (IDO = 1) then goto  l116;
	IF (NBD < L1) then goto  l112;
	for J:= 2 to IPPH do {111}
	begin
		JC := IPP2-J;
		for K:= 1 to L1 do {110}
		begin
			{CDIR$ IVDEP;???????????}
			I:= 3;
			while I<= IDO do {109 I:=3,IDO,2}
			begin
				IC := IDP2-I;
				CH[CHidx(I-1,K,J)] := CC[CCidx(I-1,2*J-1,K)]+CC[CCidx(IC-1,2*J-2,K)];
				CH[CHidx(I-1,K,JC)] := CC[CCidx(I-1,2*J-1,K)]-CC[CCidx(IC-1,2*J-2,K)];
				CH[CHidx(I,K,J)] := CC[CCidx(I,2*J-1,K)]-CC[CCidx(IC,2*J-2,K)];
				CH[CHidx(I,K,JC)] := CC[CCidx(I,2*J-1,K)]+CC[CCidx(IC,2*J-2,K)];
				I:=I+2;
				l109:
			end;
			l110:
		end;
		l111:
	end;
	goto  l116;
	l112:
	for J:= 2 to IPPH do {115}
	begin
		JC := IPP2-J;
		{CDIR$ IVDEP;?????????}
		I:= 3;
		while I<=IDO do {114 I:=3,IDO,2}
		begin
			IC := IDP2-I;
			for K:= 1 to L1 do {113}
			begin
				CH[CHidx(I-1,K,J)] := CC[CCidx(I-1,2*J-1,K)]+CC[CCidx(IC-1,2*J-2,K)];
				CH[CHidx(I-1,K,JC)] := CC[CCidx(I-1,2*J-1,K)]-CC[CCidx(IC-1,2*J-2,K)];
				CH[CHidx(I,K,J)] := CC[CCidx(I,2*J-1,K)]-CC[CCidx(IC,2*J-2,K)];
				CH[CHidx(I,K,JC)] := CC[CCidx(I,2*J-1,K)]+CC[CCidx(IC,2*J-2,K)];
				l113:
			end;
			I:=I+2;
			l114:
		end;
		l115:
	end;
	l116:
	AR1 := 1.0;
	AI1 := 0.0;
	for L:= 2 to IPPH do {120}
	begin
		LC := IPP2-L;
		AR1H := DCP*AR1-DSP*AI1;
		AI1 := DCP*AI1+DSP*AR1;
		AR1 := AR1H;
		for IK:= 1 to IDL1 do {117}
		begin
			C2[C2idx(IK,L)] := CH2[CH2idx(IK,1)]+AR1*CH2[CH2idx(IK,2)];
			C2[C2idx(IK,LC)] := AI1*CH2[CH2idx(IK,IP)];
			l117:
		end;
		DC2 := AR1;
		DS2 := AI1;
		AR2 := AR1;
		AI2 := AI1;
		for J:= 3 To IPPH do {119}
		begin
			JC := IPP2-J;
			AR2H := DC2*AR2-DS2*AI2;
			AI2 := DC2*AI2+DS2*AR2;
			AR2 := AR2H;
			for IK:= 1 to IDL1 do {118}
			begin
				C2[C2idx(IK,L)] := C2[C2idx(IK,L)]+AR2*CH2[CH2idx(IK,J)];
				C2[C2idx(IK,LC)] := C2[C2idx(IK,LC)]+AI2*CH2[CH2idx(IK,JC)];
				l118:
			end;
			l119:
		end;
		l120:
	end;
	for J:= 2 to IPPH do {122}
		for IK:= 1 to IDL1 do {121}
            CH2[CH2idx(IK,1)] := CH2[CH2idx(IK,1)]+CH2[CH2idx(IK,J)];
	l121:
	l122:
	for J:= 2 to IPPH do {124}
	begin
		JC := IPP2-J;
		for K:= 1 to L1 do {123}
		begin
			CH[CHidx(1,K,J)] := C1[C1idx(1,K,J)]-C1[C1idx(1,K,JC)];
			CH[CHidx(1,K,JC)] := C1[C1idx(1,K,J)]+C1[C1idx(1,K,JC)];
		end;  {l123}
	end;  {l124}
	IF (IDO = 1) then  goto  l132;
	IF (NBD < L1) then goto  l128;
	for J:= 2 to IPPH do {127}
	begin
		JC := IPP2-J;
		for K:= 1 to L1 do {126}
		begin
			{CDIR$ IVDEP;????????}
			I:= 3;
			while I<= IDO do {125 I:=3,IDO,2}
			begin
				CH[CHidx(I-1,K,J)] := C1[C1idx(I-1,K,J)]-C1[C1idx(I,K,JC)];
				CH[CHidx(I-1,K,JC)] := C1[C1idx(I-1,K,J)]+C1[C1idx(I,K,JC)];
				CH[CHidx(I,K,J)] := C1[C1idx(I,K,J)]+C1[C1idx(I-1,K,JC)];
				CH[CHidx(I,K,JC)] := C1[C1idx(I,K,J)]-C1[C1idx(I-1,K,JC)];
				I:= I+2;
			end; {125}
		end; {126}
	end; {127}
	goto  l132;
	l128:
	for J:= 2 to IPPH do {131}
	begin
		JC := IPP2-J;
		I:=3;
		while I<= IDO do {130 I:=3,IDO,2}
		begin
			for K:= 1 to L1 do {129}
			begin
				CH[CHidx(I-1,K,J)] := C1[C1idx(I-1,K,J)]-C1[C1idx(I,K,JC)];
				CH[CHidx(I-1,K,JC)] := C1[C1idx(I-1,K,J)]+C1[C1idx(I,K,JC)];
				CH[CHidx(I,K,J)] := C1[C1idx(I,K,J)]+C1[C1idx(I-1,K,JC)];
				CH[CHidx(I,K,JC)] := C1[C1idx(I,K,J)]-C1[C1idx(I-1,K,JC)];
			end; {129}
			I:=I+2;
		end;{130}
	end;{131}
	l132:
	IF (IDO = 1)then exit;
	for IK:= 1 to IDL1 do {133}
			C2[C2idx(IK,1)]:= CH2[CH2idx(IK,1)]; {133}
	for J:= 2 to IP do {135}
		for K:= 1 to L1 do {134}
				C1[C1idx(1,K,J)] := CH[CHidx(1,K,J)]; {134,135}
	IF (NBD > L1) then goto  l139;
	IS_ := -IDO;
	for J:= 2 to IP do {138}
	begin
		IS_ := IS_+IDO;
		IDIJ := IS_;
		I:=3;
		while I<= IDO do {137 I:=3,IDO,2}
		begin
			IDIJ := IDIJ+2;
			for K:= 1 to L1 do {136}
			begin
				C1[C1idx(I-1,K,J)] := WA[IDIJ-1]*CH[CHidx(I-1,K,J)]-WA[IDIJ]*CH[CHidx(I,K,J)];
				C1[C1idx(I,K,J)] := WA[IDIJ-1]*CH[CHidx(I,K,J)]+WA[IDIJ]*CH[CHidx(I-1,K,J)];
			end; {136}
			I:=I+2;
		end; {137}
	end;{138}
	goto  l143;
	l139:
	IS_ := -IDO;
	for J:= 2 to IP do {142}
	begin
		IS_ := IS_+IDO;
		for K:= 1 to L1 do {141}
		begin
			IDIJ := IS_;
			{CDIR$ IVDEP;??????????????}
			I:=3;
			while I<= IDO do {140 I:=3,IDO,2}
			begin
				IDIJ := IDIJ+2;
				C1[C1idx(I-1,K,J)] := WA[IDIJ-1]*CH[CHidx(I-1,K,J)]-WA[IDIJ]*CH[CHidx(I,K,J)];
				C1[C1idx(I,K,J)]:= WA[IDIJ-1]*CH[CHidx(I,K,J)]+WA[IDIJ]*CH[CHidx(I-1,K,J)];
				I:=I+2;
			end; {140}
		end; {141}
	end;{ 142}
l143:
end;







{
      SUBROUTINE RFFTB1(N,C,CH,WA,IFAC)
C***BEGIN PROLOGUE  RFFTB1
C***REFER TO  RFFTB
C***ROUTINES CALLED  RADB2,RADB3,RADB4,RADB5,RADBG
C***END PROLOGUE  RFFTB1
      DIMENSION       CH[CHidx(*)      ,C(*)       ,WA(*)      ,IFAC(*)
C***FIRST EXECUTABLE STATEMENT  RFFTB1
}


procedure RFFTB1(var C,CH,WA: VRType; var IFAC: VIType);
label
	l100,l101,l102,l103,l104,l105,l106,l107,l108,l109,
	l110,l111,l112,l113,l114,l115,l116,l117;
var
	I,NF,IX2,IX3,IX4,IDL1,NA,K1,L1,IP,IW,L2,IDO:integer;
begin
	NF := IFAC[2];
	NA := 0;
	L1 := 1;
	IW := 1;
	for K1:= 1 to NF do {l116}
	begin
		IP := IFAC[K1+2];
		L2 := IP*L1;
		IDO := N div L2;
		IDL1 := IDO*L1;
		IF (IP <> 4) then goto  l103;
		IX2 := IW+IDO;
		IX3 := IX2+IDO;
		IF (NA <> 0) then goto  l101;
		RADB4 (IDO,L1,C,CH,
				VRType(addr(WA[IW])^),VRType(addr(WA[IX2])^),
				VRType(addr(WA[IX3])^));
		goto  l102;
		l101:
		RADB4 (IDO,L1,CH,C,
				VRType(addr(WA[IW])^),VRType(addr(WA[IX2])^),
				VRType(addr(WA[IX3])^));
		l102:
		NA := 1-NA;
		goto  l115;
		l103:
		IF (IP <> 2) then goto  l106;
		IF (NA <> 0) then goto  l104;
		RADB2 (IDO,L1,C,CH,VRType(addr(WA[IW])^));
		goto  l105;
		l104:
		RADB2 (IDO,L1,CH,C,VRType(addr(WA[IW])^));
		l105:
		NA := 1-NA;
		goto  l115;
		l106:
		IF (IP <> 3) then goto  l109;
		IX2 := IW+IDO;
		IF (NA <> 0) then goto  l107;
		RADB3 (IDO,L1,C,CH,
				VRType(addr(WA[IW])^),VRType(addr(WA[IX2])^));
		goto  l108;
		l107:
		RADB3 (IDO,L1,CH,C,
				VRType(addr(WA[IW])^),VRType(addr(WA[IX2])^));
		l108:
		NA := 1-NA;
		goto  l115;
		l109:
		IF (IP <> 5) then goto  l112;
		IX2 := IW+IDO;
		IX3 := IX2+IDO;
		IX4 := IX3+IDO;
		IF (NA <> 0) then goto  l110;
		RADB5 (IDO,L1,C,CH,
      		VRType(addr(WA[IW])^),VRType(addr(WA[IX2])^),
				VRType(addr(WA[IX3])^),VRType(addr(WA[IX4])^));
		goto  l111;
		l110:
		RADB5 (IDO,L1,CH,C,
				VRType(addr(WA[IW])^),VRType(addr(WA[IX2])^),
				VRType(addr(WA[IX3])^),VRType(addr(WA[IX4])^));
		l111:
		NA := 1-NA;
		goto  l115;
		l112:
		IF (NA <> 0) then goto  l113;
		RADBG (IDO,IP,L1,IDL1,C,C,C,CH,CH,VRType(addr(WA[IW])^));
		goto  l114;
		l113:
		RADBG (IDO,IP,L1,IDL1,CH,CH,CH,C,C,VRType(addr(WA[IW])^));
		l114:
		IF (IDO = 1) then NA := 1-NA;
		l115:
		L1 := L2;
		IW := IW+(IP-1)*IDO;
	l116: {CONTINUE}
	end;
	IF (NA = 0) then Exit;
	for I:= 1 to N do {117}
		C[I] := CH[I];
	l117: {CONTINUE}
end;



{
      SUBROUTINE RFFTB(N,R,WSAVE)
C***BEGIN PROLOGUE  RFFTB
C     THIS PROLOGUE HAS BEEN REMOVED FOR REASONS OF SPACE
C     FOR A COMPLETE COPY OF THIS ROUTINE CONTACT THE AUTHORS
C     From the book "Numerical Methods and Software"
C          by  D. Kahaner, C. Moler, S. Nash
C               Prentice Hall 1988
C***END PROLOGUE  RFFTB
      DIMENSION       R(*)       ,WSAVE(*)
C***FIRST EXECUTABLE STATEMENT  RFFTB
}
procedure RFFTB(var R: VRType);
begin
	IF (N = 1) then exit;
	RFFTB1(R,VRType(CHPtr^),VRType(WAPtr^),VIType(IFACPtr^));
end;


{
		SUBROUTINE EZFFTB(N,R,AZERO,A,B,WSAVE)
C***BEGIN PROLOGUE  EZFFTB
C***DATE WRITTEN   790601   (YYMMDD)
C***REVISION DATE  860115   (YYMMDD)
C***CATEGORY NO.  J1A1
C***KEYWORDS  FOURIER TRANSFORM
C***AUTHOR  SWARZTRAUBER, P. N., (NCAR)
C***PURPOSE  A Simplified NReal, periodic, backward transform
C***DESCRIPTION
C           From the book, "Numerical Methods and Software" by
C                D. Kahaner, C. Moler, S. Nash
C                Prentice Hall, 1988
C
C  Subroutine EZFFTB computes a NReal perodic sequence from its
C  Fourier coefficients (Fourier synthesis).  The transform is   
C  defined below at Output Parameter R.  EZFFTB is a simplified
C  but slower version of RFFTB.    
C    
C  Input Parameters
C
C  N       the length of the output array R.  The method is most
C          efficient when N is the product of small primes.
C
C  AZERO   the constant Fourier coefficient
C
C  A,B     arrays which contain the remaining Fourier coefficients.   
C          These arrays are not destroyed.
C    
C          The length of these arrays depends on whether N is even or
C          odd.
C
C          If N is even, N/2    locations are required.
C          If N is odd, (N-1)/2 locations are required
C
C  WSAVE   a work array which must be dimensioned at least 3*N+15
C          in the program that calls EZFFTB.  The WSAVE array must be
C          initialized by calling subroutine EZFFTI(N,WSAVE), and a
C          different WSAVE array must be used for each different
C          value of N.  This initialization does not have to be
C          repeated so long as N remains unchanged.  Thus subsequent
C          transforms can be obtained faster than the first.
C          The same WSAVE array can be used by EZFFTF and EZFFTB.
C
C
C  Output Parameters
C
C  R       if N is even, define KMAX=N/2
C          if N is odd,  define KMAX=(N-1)/2
C
C          Then for I=1,...,N
C
C               R(I)=AZERO plus the sum from K=1 to K=KMAX of
C
C               A(K)*COS(K*(I-1)*2*PI/N)+B(K)*SIN(K*(I-1)*2*PI/N)
C
C  ********************* Complex Notation **************************
C
C          For J=1,...,N
C
C          R(J) equals the sum from K=-KMAX to K=KMAX of
C
C               C(K)*EXP(I*K*(J-1)*2*PI/N)
C
C          where
C
C               C(K) = .5*CMPLX(A(K),-B(K))   for K=1,...,KMAX
C
C               C(-K) = CONJG(C(K))
C
C               C(0) = AZERO
C
C                    and I=SQRT(-1)
C
C  *************** Amplitude - Phase Notation ***********************
C
C          For I=1,...,N
C
C          R(I) equals AZERO plus the sum from K=1 to K=KMAX of
C
C               ALPHA(K)*COS(K*(I-1)*2*PI/N+BETA(K))
C
C          where
C
C               ALPHA(K) = SQRT(A(K)*A(K)+B(K)*B(K))
C
C               COS(BETA(K))=A(K)/ALPHA(K)
C
C               SIN(BETA(K))=-B(K)/ALPHA(K)
C
C  *                                                                   *
C  *   References                                                      *
C  *                                                                   *
C  *   1. P.N. Swarztrauber, Vectorizing the FFTs, in Parallel         *
C  *      Computations (G. Rodrigue, ed.), Academic Press, 1982,       *
C  *      pp. 51-83.                                                   *
C  *   2. B.L. Buzbee, The SLATEC Common Math Library, in Sources      *
C  *      and Development of Mathematical Software (W. Cowell, ed.),   *
C  *      Prentice-Hall, 1984, pp. 302-318.                            *
C  *                                                                   *
C  *********************************************************************
C
C***REFERENCES  (NONE)
C***ROUTINES CALLED  RFFTB
C***END PROLOGUE  EZFFTB
      DIMENSION       R(*)       ,A(*)       ,B(*)       ,WSAVE(*)
C***FIRST EXECUTABLE STATEMENT  EZFFTB
}


procedure FFTB(	var R; var AZERO: NReal;
						var A,B);
label
	l101,l102,l103,l104;
var
	NS2, I :integer;
begin
	if N = 2 then goto l102;
	if N > 2 then goto l103;
	l101:
	VRType(R)[1] := AZERO;
	Exit;
	l102:
	VRType(R)[1] := AZERO+VRType(A)[1];
	VRType(R)[2] := AZERO-VRType(A)[1];
	Exit;
	l103:
	NS2 := (N-1) div 2;
	for I:= 1 to NS2 do {104}
	begin
		VRType(R)[2*I] := 0.5*VRType(A)[I];
		VRType(R)[2*I+1] := -0.5*VRType(B)[I];
	l104:
	end;
	VRType(R)[1] := AZERO;
	IF (N mod 2) = 0  then VRType(R)[N] := VRType(A)[NS2+1];
	RFFTB (VRType(R))
end;
end.