Unit vgrfftf;
interface
	uses GigaVR, vgrffti;

procedure FFTF(var R:VGiganteR; var AZERO: real; var A, B:VGiganteR);

implementation
{====================
      SUBROUTINE EZFFTF(N,R,AZERO,A,B,WSAVE)
C***BEGIN PROLOGUE  EZFFTF
C***DATE WRITTEN   790601   (YYMMDD)
C***REVISION DATE  860115   (YYMMDD)
C***CATEGORY NO.  J1A1
C***KEYWORDS  FOURIER TRANSFORM
C***AUTHOR  SWARZTRAUBER, P. N., (NCAR)
C***PURPOSE  A simplified real, periodic, forward transform
C***DESCRIPTION
C           From the book, "Numerical Methods and Software" by
C                D. Kahaner, C. Moler, S. Nash
C                Prentice Hall, 1988
C
C  Subroutine EZFFTF computes the Fourier coefficients of a real
C  perodic sequence (Fourier analysis).  The transform is defined
C  below at Output Parameters AZERO, A and B.  EZFFTF is a simplified
C  but slower version of RFFTF.
C
C  Input Parameters
C
C  N       the length of the array R to be transformed.  The method
C          is must efficient when N is the product of small primes.
C
C  R       a real array of length N which contains the sequence
C          to be transformed.  R is not destroyed.
C
C
C  WSAVE   a work array which must be dimensioned at least 3*N+15
C          in the program that calls EZFFTF.  The WSAVE array must be
C          initialized by calling subroutine EZFFTI(N,WSAVE), and a
C          different WSAVE array must be used for each different
C          value of N.  This initialization does not have to be
C          repeated so long as N remains unchanged.  Thus subsequent
C          transforms can be obtained faster than the first.
C          The same WSAVE array can be used by EZFFTF and EZFFTB.
C
C  Output Parameters
C
C  AZERO   the sum from I=1 to I=N of R(I)/N
C
C  A,B     for N even B(N/2)=0. and A(N/2) is the sum from I=1 to
C          I=N of (-1)**(I-1)*R(I)/N
C
C          for N even define KMAX=N/2-1
C          for N odd  define KMAX=(N-1)/2
C
C          then for  k=1,...,KMAX
C
C               A(K) equals the sum from I=1 to I=N of
C
C                    2./N*R(I)*COS(K*(I-1)*2*PI/N)
C
C               B(K) equals the sum from I=1 to I=N of
C
C                    2./N*R(I)*SIN(K*(I-1)*2*PI/N)
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
C
C***REFERENCES  (NONE)
C***ROUTINES CALLED  RFFTF
C***END PROLOGUE  EZFFTF

		DIMENSION       R(*)       ,A(*)       ,B(*)       ,WSAVE(*)
C***FIRST EXECUTABLE STATEMENT  EZFFTF
========}




{
C***BEGIN PROLOGUE  RADF2
C***REFER TO  RFFTF
C***ROUTINES CALLED  (NONE)
C***END PROLOGUE  RADF2
      DIMENSION       CH(IDO,2,L1)           ,CC(IDO,L1,2)           ,
     1                WA1(*)
C***FIRST EXECUTABLE STATEMENT  RADF2
}

procedure RADF2(IDO,L1:integer; var CC,CH: VGiganteR; WA1: VGR_parasito);

label
	l105,l106,l107,l108,l109,l110,l111;
function CCidx(k,j,h:integer):integer;
	begin CCidx:={((k-1)*L1+j-1)*2+h} k+IDO*(j-1+L1*(h-1)) end;
function CHidx(k,j,h:integer):integer;
	begin CHidx:={((k-1)*2+j-1)*L1+h} k+IDO*(j-1+2*(h-1)) end;

var
	k,IDP2,I,IC:integer;
	TR2,TI2:real;

begin
	for k:= 1 to L1 do
	begin
		CH.put(CC.e(CCidx(1,k,1))+CC.e(CCidx(1,k,2)),k);
		CH.put(CC.e(CCidx(1,K,1))-CC.e(CCidx(1,K,2)),CHidx(IDO,2,K));
	end;
	IF (IDO-2)<0 then goto l107
	else if (IDO-2)=0 then goto l105;
	IDP2 := IDO+2;
	IF((IDO-1)/2 < L1) then goto l108;
	for k:= 1 to L1 do {104}
	begin
{CDIR$ IVDEP ???????????????????????}
		I:=3;
		while I<= IDO do {103}
		begin
			IC := IDP2-I;
			TR2 := WA1.e(I-2)*CC.e(CCidx(I-1,K,2))+WA1.e(I-1)*CC.e(CCidx(I,K,2));
			TI2 := WA1.e(I-2)*CC.e(CCidx(I,K,2))-WA1.e(I-1)*CC.e(CCidx(I-1,K,2));
			CH.put( CC.e(CCidx(I,K,1))+TI2,CHidx(I,1,K));
			CH.put(TI2- CC.e(CCidx(I,K,1)),CHidx(IC,2,K));
			CH.put(CC.e(CCidx(I-1,K,1))+TR2,CHidx(I-1,1,K));
			CH.put(CC.e(CCidx(I-1,K,1))-TR2,CHidx(IC-1,2,K));
			I:=I+2;
		end;
	end;


	GOTO l111;

l108:
	I:=3;
	while I<=IDO do {DO 110 I=3,IDO,2}
	begin
		IC := IDP2-I;
		{CDIR$ IVDEP????????????????????}
		for K:= 1 to L1 do {109}
		begin
			TR2 := WA1.e(I-2)*CC.e(CCidx(I-1,K,2))+WA1.e(I-1)*CC.e(CCidx(I,K,2));
			TI2 := WA1.e(I-2)*CC.e(CCidx(I,K,2))-WA1.e(I-1)*CC.e(CCidx(I-1,K,2));
			CH.put(CC.e(CCidx(I,K,1))+TI2,CHidx(I,1,K));
			CH.put(TI2-CC.e(CCidx(I,K,1)),CHidx(IC,2,K));
			CH.put(CC.e(CCidx(I-1,K,1))+TR2,CHidx(I-1,1,K));
			CH.put(CC.e(CCidx(I-1,K,1))-TR2,CHidx(IC-1,2,K));
		end;
		I:=I+2;
	end;

l110: {CONTINUE}
l111:
	IF (IDO mod 2 = 1) then exit;
l105:
	for k:=1 to L1 do {106}
	begin
		CH.put(-CC.e(CCidx(IDO,K,2)),CHidx(1,2,K));
		CH.put(CC.e(CCidx(IDO,K,1)),CHidx(IDO,1,K));
	end;
l106: {CONTINUE}
l107: {RETURN}
end;



{
      SUBROUTINE RADF3(IDO,L1,CC,CH,WA1,WA2)
C***BEGIN PROLOGUE  RADF3
C***REFER TO  RFFTF
C***ROUTINES CALLED  (NONE)
C***END PROLOGUE  RADF3
      DIMENSION       CH(IDO,3,L1)           ,CC(IDO,L1,3)           ,
     1                WA1(*)     ,WA2(*)
C***FIRST EXECUTABLE STATEMENT  RADF3
}
procedure RADF3(IDO,L1:integer; var CC,CH: VGiganteR; var WA1,WA2: VGiganteR
{ VRG_Parasito});
function CCidx(k,j,h:integer):integer;
	begin CCidx:={((k-1)*L1+j-1)*3+h} k+IDO*(j-1+(h-1)*L1) end;
function CHidx(k,j,h:integer):integer;
	begin CHidx:={((k-1)*3+j-1)*L1+h} k+IDO*(j-1+(h-1)*3) end;

label
	l101,l102,l103,l104,l105,l106,l107,l108,l109,l110;
var
	DR2,DI2,DR3,DI3,CI2, TAUR, TAUI, CR2:real;
	TR2,TI2,TR3,TI3:REAL;
	K,I,IC,IDP2:integer;
begin
	TAUR := -0.5;
	TAUI := 0.5*SQRT(3.0);
	for K:= 1 to L1 do {101}
	begin
		CR2 := CC.e(CCidx(1,K,2))+CC.e(CCidx(1,K,3));
		CH.put(CC.e(CCidx(1,K,1))+CR2,CHidx(1,1,K));
		CH.put(TAUI*(CC.e(CCidx(1,K,3))-CC.e(CCidx(1,K,2))),CHidx(1,3,K));
		CH.put(CC.e(CCidx(1,K,1))+TAUR*CR2,CHidx(IDO,2,K));
	end;
l101: {CONTINUE}
	IF IDO = 1 then exit;
	IDP2 := IDO+2;
	IF((IDO-1)/2 <= L1) then GOTO l104;
	for k:= 1 to L1 do {103}
	{CDIR$ IVDEP????????????????????}
	begin
		I:=3;
		while I<= IDO do {DO 102 I=3,IDO,2}
		begin
			IC := IDP2-I;
			DR2 := WA1.e(I-2)*CC.e(CCidx(I-1,K,2))+WA1.e(I-1)*CC.e(CCidx(I,K,2));
			DI2 := WA1.e(I-2)*CC.e(CCidx(I,K,2))-WA1.e(I-1)*CC.e(CCidx(I-1,K,2));
			DR3 := WA2.e(I-2)*CC.e(CCidx(I-1,K,3))+WA2.e(I-1)*CC.e(CCidx(I,K,3));
			DI3 := WA2.e(I-2)*CC.e(CCidx(I,K,3))-WA2.e(I-1)*CC.e(CCidx(I-1,K,3));
			CR2 := DR2+DR3;
			CI2 := DI2+DI3;
			CH.put(CC.e(CCidx(I-1,K,1))+CR2,CHidx(I-1,1,K));
			CH.put(CC.e(CCidx(I,K,1))+CI2,CHidx(I,1,K));
			TR2 := CC.e(CCidx(I-1,K,1))+TAUR*CR2;
			TI2 := CC.e(CCidx(I,K,1))+TAUR*CI2;
			TR3 := TAUI*(DI2-DI3);
			TI3 := TAUI*(DR3-DR2);
			CH.put(TR2+TR3,CHidx(I-1,3,K));
			CH.put(TR2-TR3,CHidx(IC-1,2,K));
			CH.put(TI2+TI3,CHidx(I,3,K));
			CH.put(TI3-TI2,CHidx(IC,2,K));
			I:=I+2;
l102: end;{CONTINUE}
l103:
	end; {CONTINUE}
	exit; {RETURN}

l104:
	I:=3;
	while I<= IDO do { DO 106 I=3,IDO,2}
	begin
		IC := IDP2-I;
		{CDIR$ IVDEP???????????????????????}
		for K:= 1 to L1 do {105}
		begin
			DR2 := WA1.e(I-2)*CC.e(CCidx(I-1,K,2))+WA1.e(I-1)*CC.e(CCidx(I,K,2));
			DI2 := WA1.e(I-2)*CC.e(CCidx(I,K,2))-WA1.e(I-1)*CC.e(CCidx(I-1,K,2));
			DR3 := WA2.e(I-2)*CC.e(CCidx(I-1,K,3))+WA2.e(I-1)*CC.e(CCidx(I,K,3));
			DI3 := WA2.e(I-2)*CC.e(CCidx(I,K,3))-WA2.e(I-1)*CC.e(CCidx(I-1,K,3));
			CR2 := DR2+DR3;
			CI2 := DI2+DI3;
			CH[CHidx(I-1,1,K)] := CC[CCidx(I-1,K,1)]+CR2;
			CH[CHidx(I,1,K)] := CC[CCidx(I,K,1)]+CI2;
			TR2 := CC[CCidx(I-1,K,1)]+TAUR*CR2;
			TI2 := CC[CCidx(I,K,1)]+TAUR*CI2;
			TR3 := TAUI*(DI2-DI3);
			TI3 := TAUI*(DR3-DR2);
			CH[CHidx(I-1,3,K)] := TR2+TR3;
			CH[CHidx(IC-1,2,K)] := TR2-TR3;
			CH[CHidx(I,3,K)] := TI2+TI3;
			CH[CHidx(IC,2,K)] := TI3-TI2;
l105:	end;{CONTINUE}
		I:=I+2;
l106:
	end;{CONTINUE}
l107:
	{RETURN}
end;



{
		SUBROUTINE RADF4(IDO,L1,CC,CH,WA1,WA2,WA3)
C***BEGIN PROLOGUE  RADF4
C***REFER TO  RFFTF
C***ROUTINES CALLED  (NONE)
C***END PROLOGUE  RADF4
      DIMENSION       CC(IDO,L1,4)           ,CH(IDO,4,L1)           ,
     1                WA1(*)     ,WA2(*)     ,WA3(*)
C***FIRST EXECUTABLE STATEMENT  RADF4
}

procedure RADF4(IDO, L1:integer; var CC,CH,WA1,WA2,WA3: VGiganteR);
function CCidx(k,j,h:integer):integer;
	begin CCidx:={((k-1)*L1+j-1)*4+h} k+IDO*(j-1+(h-1)*L1) end;
function CHidx(k,j,h:integer):integer;
	begin CHidx:={((k-1)*4+j-1)*L1+h} k+IDO*(j-1+(h-1)*4) end;
label
	l101,l102,l103,l104,l105,l106,l107,l108,l109,l110,
	L111;


VAR
	HSQT2:REAL;
	CR2,CI2,CR3,CI3,CR4,CI4:REAL;
	TR1,TR2,TR3,TR4,TI1,TI2,TI3,TI4:REAL;
	K,I,IDP2,IC:INTEGER;

begin
	HSQT2 := 0.5*SQRT(2.0);
	for k:= 1 to L1 do {101}
	begin
		TR1 := CC[CCidx(1,K,2)]+CC[CCidx(1,K,4)];
		TR2 := CC[CCidx(1,K,1)]+CC[CCidx(1,K,3)];
		CH[CHidx(1,1,K)] := TR1+TR2;
		CH[CHidx(IDO,4,K)] := TR2-TR1;
		CH[CHidx(IDO,2,K)] := CC[CCidx(1,K,1)]-CC[CCidx(1,K,3)];
		CH[CHidx(1,3,K)] := CC[CCidx(1,K,4)]-CC[CCidx(1,K,2)];
	end;{101}
	IF (IDO-2) <0 then goto l107;
	if (Ido-2) = 0 then goto l105;
l102:
	IDP2 := IDO+2;
	IF((IDO-1)/2 <= L1) then GOTO l111;
	for K:= 1 to L1 do {104}
	begin
		{CDIR$ IVDEP??????????????????????}
		I:=3;
		while I<= IDO do {DO 103 I=3,IDO,2}
		begin
			IC := IDP2-I;
			CR2 := WA1[I-2]*CC[CCidx(I-1,K,2)]+WA1[I-1]*CC[CCidx(I,K,2)];
			CI2 := WA1[I-2]*CC[CCidx(I,K,2)]-WA1[I-1]*CC[CCidx(I-1,K,2)];
			CR3 := WA2[I-2]*CC[CCidx(I-1,K,3)]+WA2[I-1]*CC[CCidx(I,K,3)];
			CI3 := WA2[I-2]*CC[CCidx(I,K,3)]-WA2[I-1]*CC[CCidx(I-1,K,3)];
			CR4 := WA3[I-2]*CC[CCidx(I-1,K,4)]+WA3[I-1]*CC[CCidx(I,K,4)];
			CI4 := WA3[I-2]*CC[CCidx(I,K,4)]-WA3[I-1]*CC[CCidx(I-1,K,4)];
			TR1 := CR2+CR4;
			TR4 := CR4-CR2;
			TI1 := CI2+CI4;
			TI4 := CI2-CI4;
			TI2 := CC[CCidx(I,K,1)]+CI3;
			TI3 := CC[CCidx(I,K,1)]-CI3;
			TR2 := CC[CCidx(I-1,K,1)]+CR3;
			TR3 := CC[CCidx(I-1,K,1)]-CR3;
			CH[CHidx(I-1,1,K)] := TR1+TR2;
			CH[CHidx(IC-1,4,K)] := TR2-TR1;
			CH[CHidx(I,1,K)] := TI1+TI2;
			CH[CHidx(IC,4,K)] := TI1-TI2;
			CH[CHidx(I-1,3,K)] := TI4+TR3;
			CH[CHidx(IC-1,2,K)] := TR3-TI4;
			CH[CHidx(I,3,K)] := TR4+TI3;
			CH[CHidx(IC,2,K)] := TR4-TI3;
			I:=I+2;
		l103:   {CONTINUE}
		end;
	l104: {CONTINUE}
	end;
	GOTO l110;
	l111:
	I:=3;
	while I<= IDO do {DO 109 I=3,IDO,2}
	begin
		IC := IDP2-I;
		{CDIR$ IVDEP???????????????????????}
		for K:=1 to l1 do {108}
		begin
			CR2 := WA1[I-2]*CC[CCidx(I-1,K,2)]+WA1[I-1]*CC[CCidx(I,K,2)];
			CI2 := WA1[I-2]*CC[CCidx(I,K,2)]-WA1[I-1]*CC[CCidx(I-1,K,2)];
			CR3 := WA2[I-2]*CC[CCidx(I-1,K,3)]+WA2[I-1]*CC[CCidx(I,K,3)];
			CI3 := WA2[I-2]*CC[CCidx(I,K,3)]-WA2[I-1]*CC[CCidx(I-1,K,3)];
			CR4 := WA3[I-2]*CC[CCidx(I-1,K,4)]+WA3[I-1]*CC[CCidx(I,K,4)];
			CI4 := WA3[I-2]*CC[CCidx(I,K,4)]-WA3[I-1]*CC[CCidx(I-1,K,4)];
			TR1 := CR2+CR4;
			TR4 := CR4-CR2;
			TI1 := CI2+CI4;
			TI4 := CI2-CI4;
			TI2 := CC[CCidx(I,K,1)]+CI3;
			TI3 := CC[CCidx(I,K,1)]-CI3;
			TR2 := CC[CCidx(I-1,K,1)]+CR3;
			TR3 := CC[CCidx(I-1,K,1)]-CR3;

			CH[CHidx(I-1,1,K)] := TR1+TR2;
			CH[CHidx(IC-1,4,K)] := TR2-TR1;
			CH[CHidx(I,1,K)] := TI1+TI2;
			CH[CHidx(IC,4,K)] := TI1-TI2;
			CH[CHidx(I-1,3,K)] := TI4+TR3;
			CH[CHidx(IC-1,2,K)] := TR3-TI4;
			CH[CHidx(I,3,K)] := TR4+TI3;
			CH[CHidx(IC,2,K)] := TR4-TI3;
		l108:  {CONTINUE}
		end;
		I:=I+2;
	l109: {CONTINUE}
	end;
	l110:
	IF (IDO mod 2 = 1) then exit;
	l105:
	for K:=1 to L1 do {106}
	begin
		TI1 := -HSQT2*(CC[CCidx(IDO,K,2)]+CC[CCidx(IDO,K,4)]);
		TR1 := HSQT2*(CC[CCidx(IDO,K,2)]-CC[CCidx(IDO,K,4)]);
		CH[CHidx(IDO,1,K)] := TR1+CC[CCidx(IDO,K,1)];
		CH[CHidx(IDO,3,K)] := CC[CCidx(IDO,K,1)]-TR1;
		CH[CHidx(1,2,K)] := TI1-CC[CCidx(IDO,K,3)];
		CH[CHidx(1,4,K)] := TI1+CC[CCidx(IDO,K,3)];
	l106: {CONTINUE}
	end;
l107: {RETURN}
end;


{
      SUBROUTINE RADF5(IDO,L1,CC,CH,WA1,WA2,WA3,WA4)
C***BEGIN PROLOGUE  RADF5
C***REFER TO  RFFTF
C***ROUTINES CALLED  (NONE)
C***END PROLOGUE  RADF5
      DIMENSION       CC(IDO,L1,5)           ,CH(IDO,5,L1)           ,
     1                WA1(*)     ,WA2(*)     ,WA3(*)     ,WA4(*)
C***FIRST EXECUTABLE STATEMENT  RADF5
}

procedure RADF5(IDO,L1:integer; var CC,CH,WA1,WA2,WA3,WA4: VRType);
function CCidx(k,j,h:integer):integer;
	begin CCidx:={((k-1)*L1+j-1)*4+h} k+IDO*(j-1+(h-1)*L1) end;
function CHidx(k,j,h:integer):integer;
	begin CHidx:={((k-1)*4+j-1)*L1+h} k+IDO*(j-1+(h-1)*5) end;
label
	l101,l102,l103,l104,l105,l106,l107,l108,l109,l110;

VAR
	TR11,TI11,TR12,TI12:REAL;
	IC,IDP2,K,I:INTEGER;
	CR2,CR3,CR4,CR5,CI2,CI3,CI4,CI5:REAL;
	DR2,DR3,DR4,DR5,DI2,DI3,DI4,DI5:REAL;
	TR2,TR3,TR4,TR5,TI2,TI3,TI4,TI5:REAL;
begin
	TR11 := SIN(0.1*PI);
	TI11 := SIN(0.4*PI);
	TR12 := -SIN(0.3*PI);
	TI12 := SIN(0.2*PI);
	for K:= 1 to L1 do {101}
	begin
		CR2 := CC[CCidx(1,K,5)]+CC[CCidx(1,K,2)];
		CI5 := CC[CCidx(1,K,5)]-CC[CCidx(1,K,2)];
		CR3 := CC[CCidx(1,K,4)]+CC[CCidx(1,K,3)];
		CI4 := CC[CCidx(1,K,4)]-CC[CCidx(1,K,3)];
		CH[CHidx(1,1,K)] := CC[CCidx(1,K,1)]+CR2+CR3;
		CH[CHidx(IDO,2,K)] := CC[CCidx(1,K,1)]+TR11*CR2+TR12*CR3;
		CH[CHidx(1,3,K)] := TI11*CI5+TI12*CI4;
		CH[CHidx(IDO,4,K)] := CC[CCidx(1,K,1)]+TR12*CR2+TR11*CR3;
		CH[CHidx(1,5,K)] := TI12*CI5-TI11*CI4;
	l101: {CONTINUE}
	end;
	IF (IDO =1 ) then exit;
	IDP2 := IDO+2;
	IF((IDO-1)/2 <= L1) then  GOTO l104;
	for K:= 1 to L1 do {103}
	begin
	{CDIR$ IVDEP??????????????????????}
		I:=3;
		while I<=IDO do {102 I=3,IDO,2}
		begin
			IC := IDP2-I;
			DR2 := WA1[I-2]*CC[CCidx(I-1,K,2)]+WA1[I-1]*CC[CCidx(I,K,2)];
			DI2 := WA1[I-2]*CC[CCidx(I,K,2)]-WA1[I-1]*CC[CCidx(I-1,K,2)];
			DR3 := WA2[I-2]*CC[CCidx(I-1,K,3)]+WA2[I-1]*CC[CCidx(I,K,3)];
			DI3 := WA2[I-2]*CC[CCidx(I,K,3)]-WA2[I-1]*CC[CCidx(I-1,K,3)];
			DR4 := WA3[I-2]*CC[CCidx(I-1,K,4)]+WA3[I-1]*CC[CCidx(I,K,4)];
			DI4 := WA3[I-2]*CC[CCidx(I,K,4)]-WA3[I-1]*CC[CCidx(I-1,K,4)];
			DR5 := WA4[I-2]*CC[CCidx(I-1,K,5)]+WA4[I-1]*CC[CCidx(I,K,5)];
			DI5 := WA4[I-2]*CC[CCidx(I,K,5)]-WA4[I-1]*CC[CCidx(I-1,K,5)];
			CR2 := DR2+DR5;
			CI5 := DR5-DR2;
			CR5 := DI2-DI5;
			CI2 := DI2+DI5;
			CR3 := DR3+DR4;
			CI4 := DR4-DR3;
			CR4 := DI3-DI4;
			CI3 := DI3+DI4;
			CH[CHidx(I-1,1,K)] := CC[CCidx(I-1,K,1)]+CR2+CR3;
			CH[CHidx(I,1,K)] := CC[CCidx(I,K,1)]+CI2+CI3;
			TR2 := CC[CCidx(I-1,K,1)]+TR11*CR2+TR12*CR3;
			TI2 := CC[CCidx(I,K,1)]+TR11*CI2+TR12*CI3;
			TR3 := CC[CCidx(I-1,K,1)]+TR12*CR2+TR11*CR3;
			TI3 := CC[CCidx(I,K,1)]+TR12*CI2+TR11*CI3;
			TR5 := TI11*CR5+TI12*CR4;
			TI5 := TI11*CI5+TI12*CI4;
			TR4 := TI12*CR5-TI11*CR4;
			TI4 := TI12*CI5-TI11*CI4;
			CH[CHidx(I-1,3,K)] := TR2+TR5;
			CH[CHidx(IC-1,2,K)] := TR2-TR5;
			CH[CHidx(I,3,K)] := TI2+TI5;
			CH[CHidx(IC,2,K)] := TI5-TI2;
			CH[CHidx(I-1,5,K)] := TR3+TR4;
			CH[CHidx(IC-1,4,K)] := TR3-TR4;
			CH[CHidx(I,5,K)] := TI3+TI4;
			CH[CHidx(IC,4,K)] := TI4-TI3;
			I:=I+2;
		l102:    {CONTINUE}
		end;
	l103: {CONTINUE}
	end;
	exit; {RETURN}
	
	l104:
   I:=3;
	while I<=IDO do {106 I=3,IDO,2}
	begin
		IC := IDP2-I;
		{CDIR$ IVDEP??????????????????????}
		for K:= 1 to L1 do {105}
		begin
				DR2 := WA1[I-2]*CC[CCidx(I-1,K,2)]+WA1[I-1]*CC[CCidx(I,K,2)];
				DI2 := WA1[I-2]*CC[CCidx(I,K,2)]-WA1[I-1]*CC[CCidx(I-1,K,2)];
				DR3 := WA2[I-2]*CC[CCidx(I-1,K,3)]+WA2[I-1]*CC[CCidx(I,K,3)];
				DI3 := WA2[I-2]*CC[CCidx(I,K,3)]-WA2[I-1]*CC[CCidx(I-1,K,3)];
				DR4 := WA3[I-2]*CC[CCidx(I-1,K,4)]+WA3[I-1]*CC[CCidx(I,K,4)];
				DI4 := WA3[I-2]*CC[CCidx(I,K,4)]-WA3[I-1]*CC[CCidx(I-1,K,4)];
				DR5 := WA4[I-2]*CC[CCidx(I-1,K,5)]+WA4[I-1]*CC[CCidx(I,K,5)];
				DI5 := WA4[I-2]*CC[CCidx(I,K,5)]-WA4[I-1]*CC[CCidx(I-1,K,5)];
            CR2 := DR2+DR5;
            CI5 := DR5-DR2;
            CR5 := DI2-DI5;
            CI2 := DI2+DI5;
            CR3 := DR3+DR4;
            CI4 := DR4-DR3;
            CR4 := DI3-DI4;
            CI3 := DI3+DI4;
            CH[CHidx(I-1,1,K)] := CC[CCidx(I-1,K,1)]+CR2+CR3;
            CH[CHidx(I,1,K)] := CC[CCidx(I,K,1)]+CI2+CI3;
            TR2 := CC[CCidx(I-1,K,1)]+TR11*CR2+TR12*CR3;
            TI2 := CC[CCidx(I,K,1)]+TR11*CI2+TR12*CI3;
            TR3 := CC[CCidx(I-1,K,1)]+TR12*CR2+TR11*CR3;
            TI3 := CC[CCidx(I,K,1)]+TR12*CI2+TR11*CI3;
            TR5 := TI11*CR5+TI12*CR4;
            TI5 := TI11*CI5+TI12*CI4;
            TR4 := TI12*CR5-TI11*CR4;
            TI4 := TI12*CI5-TI11*CI4;
            CH[CHidx(I-1,3,K)] := TR2+TR5;
            CH[CHidx(IC-1,2,K)] := TR2-TR5;
            CH[CHidx(I,3,K)] := TI2+TI5;
            CH[CHidx(IC,2,K)] := TI5-TI2;
            CH[CHidx(I-1,5,K)] := TR3+TR4;
            CH[CHidx(IC-1,4,K)] := TR3-TR4;
            CH[CHidx(I,5,K)] := TI3+TI4;
				CH[CHidx(IC,4,K)] := TI4-TI3;
		l105:    {CONTINUE/for}
		end;
		I:=I+2;
	l106: {CONTINUE/while}
	end;
end; {RETURN}


{
		SUBROUTINE RADFG(IDO,IP,L1,IDL1,CC,C1,C2,CH,CH2,WA)
C***BEGIN PROLOGUE  RADFG
C***REFER TO  RFFTF
C***ROUTINES CALLED  (NONE)
C***END PROLOGUE  RADFG
      DIMENSION       CH(IDO,L1,IP)          ,CC(IDO,IP,L1)          ,
     1                C1(IDO,L1,IP)          ,C2(IDL1,IP),
	  2                CH2(IDL1,IP)           ,WA(*)
C***FIRST EXECUTABLE STATEMENT  RADFG
}

procedure RADFG(IDO,IP,L1,IDL1:integer; var CC,C1,C2,CH,CH2,WA:VRType);
function CCidx(k,j,h:integer):integer;
	begin CCidx:={((k-1)*IP+j-1)*L1+h} k+IDO*(j-1+(h-1)*IP) end;
function CHidx(k,j,h:integer):integer;
	begin CHidx:={((k-1)*L1+j-1)*IP+h} k+IDO*(j-1+(h-1)*L1)  end;
function C1idx(k,j,h:integer):integer;
	begin C1idx:={((k-1)*L1+j-1)*IP+h} k+IDO*(j-1+(h-1)*L1) end;
function CH2idx(k,j:integer):integer;
	begin CH2idx:= {(k-1)*IP+j} k+(j-1)*IDL1 end;
function C2idx(k,j:integer):integer;
	begin C2IDX:= {(k-1)*IP+j} k+(j-1)*IDL1 END;

label
	L100,l101,l102,l103,l104,l105,l106,l107,l108,l109,
	L110,L111,L112,L113,L114,L115,L116,L117,L118,L119,
	L120,L121,L122,L123,L124,L125,L126,L127,L128,L129,
	L130,L131,L132,L133,L134,L135,L136,L137,L138,L139,
	L140,L141,L142,L143,L144,L145,L146,L147,L148,L149;


VAR
	TPI:REAL;
	ARG,DCP,DSP:REAL;
	L,IPPH,IPP2,IDP2,NBD:INTEGER;
	IC,J2,LC,JC,I,IDIJ,IS,IK,J,K:INTEGER;
	DC2,DS2,AR1H,AR1,AI1:REAL;
	AR2H,AR2,AI2:REAL;

begin

	TPI := 2*pi;
	ARG := TPI/IP;
	DCP := COS(ARG);
	DSP := SIN(ARG);
	IPPH := (IP+1) DIV 2;
	IPP2 := IP+2;
	IDP2 := IDO+2;
	NBD := (IDO-1) DIV 2;
	IF (IDO = 1) then  GOTO l119;
	for IK:=1 to IDL1 do {101}
		CH2[CH2idx(IK,1)] := C2[C2idx(IK,1)];
	l101: {CONTINUE}

	for J:= 2 to IP do {103}
		for K:=1 to L1 do {102}
			CH[CHidx(1,K,J)] := C1[C1idx(1,K,J)];
		l102:  {CONTINUE}
	l103: {CONTINUE}

	IF (NBD > L1) then  GOTO l107;
	IS := -IDO;


	for J:= 2 to IP do {106}
	begin
		IS := IS+IDO;
		IDIJ := IS;
		I:=3;
		while I<=IDO do {DO 105 I:=3,IDO,2;}
		begin
			IDIJ := IDIJ+2;
			for K:=1 to L1 do {104}
			begin
				CH[CHidx(I-1,K,J)] := WA[IDIJ-1]*C1[C1idx(I-1,K,J)]+WA[IDIJ]*C1[C1idx(I,K,J)];
				CH[CHidx(I,K,J)] := WA[IDIJ-1]*C1[C1idx(I,K,J)]-WA[IDIJ]*C1[C1idx(I-1,K,J)];
			l104: {CONTINUE}
			end;
			I:=I+2;
		l105:    {CONTINUE}
		end;
	l106: {CONTINUE}
	end;
	GOTO l111;
	l107:
	IS := -IDO;

	for J:= 2 to IP do {110}
	begin
		IS := IS+IDO;
		for K:= 1 to L1 do {109}
		begin
			IDIJ := IS;
			{CDIR$ IVDEP;???????????????????????}
			I:=3;
			while I<= IDO do {DO 108 I:=3,IDO,2;}
			begin
				IDIJ:= IDIJ+2;
				CH[CHidx(I-1,K,J)] := WA[IDIJ-1]*C1[C1idx(I-1,K,J)]+WA[IDIJ]*C1[C1idx(I,K,J)];
				CH[CHidx(I,K,J)] := WA[IDIJ-1]*C1[C1idx(I,K,J)]-WA[IDIJ]*C1[C1idx(I-1,K,J)];
				I:=I+2;
			l108:  {CONTINUE}
			end;
		l109: {CONTINUE}
		end;
	l110: {CONTINUE}
	end;


	l111:
	IF (NBD < L1) then  GOTO l115;

	for J:= 2 to IPPH do {114}
	begin
		JC := IPP2-J;
		for K:= 1 to L1 do {113}
		begin
		{CDIR$ IVDEP;????????????}
			I:= 3;
			while I<= IDO do {DO 112 I:=3,IDO,2;}
			begin
				C1[C1idx(I-1,K,J)] := CH[CHidx(I-1,K,J)]+CH[CHidx(I-1,K,JC)];
				C1[C1idx(I-1,K,JC)] := CH[CHidx(I,K,J)]-CH[CHidx(I,K,JC)];
				C1[C1idx(I,K,J)] := CH[CHidx(I,K,J)]+CH[CHidx(I,K,JC)];
				C1[C1idx(I,K,JC)] := CH[CHidx(I-1,K,JC)]-CH[CHidx(I-1,K,J)];
				I:=I+2;
			l112:   {CONTINUE}
			end;
		l113:    {CONTINUE}
		end;
	l114: {CONTINUE;}
	end;


	GOTO l121;
	l115:

	for J:= 2 to IPPH do {118}
	begin
		JC := IPP2-J;
		I:= 3;
		while I<= IDO do {DO 117 I:=3,IDO,2;}
		begin
			for K:= 1 to L1 do {116}
			begin
				C1[C1idx(I-1,K,J)] := CH[CHidx(I-1,K,J)]+CH[CHidx(I-1,K,JC)];
				C1[C1idx(I-1,K,JC)] := CH[CHidx(I,K,J)]-CH[CHidx(I,K,JC)];
				C1[C1idx(I,K,J)] := CH[CHidx(I,K,J)]+CH[CHidx(I,K,JC)];
				C1[C1idx(I,K,JC)] := CH[CHidx(I-1,K,JC)]-CH[CHidx(I-1,K,J)];
			l116:   {CONTINUE}
			end;
			I:=I+2;
		l117: { CONTINUE}
		end;
	l118: { CONTINUE}
	end;

	GOTO l121;
	l119:

	for IK:= 1 to IDL1 do {120}
		C2[C2idx(IK,1)] := CH2[CH2idx(IK,1)];
	l120: {CONTINUE}
	l121:

	for J:= 2 to IPPH do {123}
	begin
		JC := IPP2-J;
		for K:= 1 to L1 do {122}
		begin
			C1[C1idx(1,K,J)] := CH[CHidx(1,K,J)]+CH[CHidx(1,K,JC)];
			C1[C1idx(1,K,JC)] := CH[CHidx(1,K,JC)]-CH[CHidx(1,K,J)];
		l122:{CONTINUE}
		end;
	l123:{CONTINUE}
	end;

	AR1 := 1.0;
	AI1 := 0.0;

	for L:= 2 to IPPH do {127}
	begin
		LC := IPP2-L;
		AR1H := DCP*AR1-DSP*AI1;
		AI1 := DCP*AI1+DSP*AR1;
		AR1 := AR1H;
		for IK:= 1 to IDL1 do {124}
		begin
			CH2[CH2idx(IK,L)] := C2[C2idx(IK,1)]+AR1*C2[C2idx(IK,2)];
			CH2[CH2idx(IK,LC)] := AI1*C2[C2idx(IK,IP)];
		l124:  {CONTINUE}
		end;
		DC2 := AR1;
		DS2 := AI1;
		AR2 := AR1;
		AI2 := AI1;
		for J:= 3 to IPPH do {126}
		begin
			JC := IPP2-J;
			AR2H := DC2*AR2-DS2*AI2;
			AI2 := DC2*AI2+DS2*AR2;
			AR2 := AR2H;
			for IK:= 1 to IDL1 do {125}
			begin
				CH2[CH2idx(IK,L)] := CH2[CH2idx(IK,L)]+AR2*C2[C2idx(IK,J)];
				CH2[CH2idx(IK,LC)] := CH2[CH2idx(IK,LC)]+AI2*C2[C2idx(IK,JC)];
			l125: {CONTINUE}
			END;
		l126: {CONTINUE}
		END;
	l127: {CONTINUE}
	END;


	for J:= 2 to IPPH do {129}
		for IK:= 1 to IDL1 do {128}
			CH2[CH2idx(IK,1)] := CH2[CH2idx(IK,1)]+C2[C2idx(IK,J)];
		l128: {CONTINUE;}
	l129:{CONTINUE}

	IF (IDO < L1) then GOTO l132;
	for k:= 1 to L1 do {131}
		for I:= 1 to IDO do {130}
			CC[CCidx(I,1,K)] := CH[CHidx(I,K,1)];
		l130:{CONTINUE}
	l131: {CONTINUE}
	GOTO l135;
	l132:
	for I:= 1 to IDO do {134}
		for K:= 1 to L1 do {133}
			CC[CCidx(I,1,K)] := CH[CHidx(I,K,1)];
		l133:{CONTINUE}
	l134: {CONTINUE}

	l135:
	for J:= 2 to IPPH do {137}
	begin
		JC := IPP2-J;
		J2 := J+J;
		for K:= 1 to L1 do {136}
		begin
			CC[CCidx(IDO,J2-2,K)] := CH[CHidx(1,K,J)];
			CC[CCidx(1,J2-1,K)] := CH[CHidx(1,K,JC)];
		l136:{CONTINUE}
		END;
	l137: {CONTINUE}
	END;
	IF (IDO = 1) then exit;
	IF (NBD < L1) then GOTO l141;

	for J:= 2 to IPPH do {140}
	begin
		JC := IPP2-J;
		J2 := J+J;
		for K:= 1 to L1 do {139}
		begin
			{CDIR$ IVDEP????????????????????????}
			I:= 3;
			while I<= IDO do {DO 138 I:=3,IDO,2;}
			begin
				IC := IDP2-I;
				CC[CCidx(I-1,J2-1,K)] := CH[CHidx(I-1,K,J)]+CH[CHidx(I-1,K,JC)];
				CC[CCidx(IC-1,J2-2,K)] := CH[CHidx(I-1,K,J)]-CH[CHidx(I-1,K,JC)];
				CC[CCidx(I,J2-1,K)] := CH[CHidx(I,K,J)]+CH[CHidx(I,K,JC)];
				CC[CCidx(IC,J2-2,K)] := CH[CHidx(I,K,JC)]-CH[CHidx(I,K,J)];
				I:= I+2;
			l138:{CONTINUE}
			end;
		l139:{CONTINUE}
		end;
	l140: {CONTINUE}
	end;
	exit; {RETURN}
	l141:

	for J:= 2 to IPPH do {144}
	begin
		JC := IPP2-J;
		J2 := J+J;
		I:= 3;
		while I<= IDO do {DO 143 I:=3,IDO,2}
		begin
			IC := IDP2-I;
			for K:= 1 to L1 do {142}
			begin
				CC[CCidx(I-1,J2-1,K)] := CH[CHidx(I-1,K,J)]+CH[CHidx(I-1,K,JC)];
				CC[CCidx(IC-1,J2-2,K)] := CH[CHidx(I-1,K,J)]-CH[CHidx(I-1,K,JC)];
				CC[CCidx(I,J2-1,K)] := CH[CHidx(I,K,J)]+CH[CHidx(I,K,JC)];
				CC[CCidx(IC,J2-2,K)] := CH[CHidx(I,K,JC)]-CH[CHidx(I,K,J)];
			l142: {CONTINUE}
			end;
			I:=I+2;
		l143:  {CONTINUE}
		end;
	l144: {CONTINUE}
	END;
end;


{
C***BEGIN PROLOGUE  RFFTF1
C***REFER TO  RFFTF
C***ROUTINES CALLED  RADF2,RADF3,RADF4,RADF5,RADFG
C***END PROLOGUE  RFFTF1
      DIMENSION       CH(*)      ,C(*)       ,WA(*)      ,IFAC(*)
C***FIRST EXECUTABLE STATEMENT  RFFTF1
}

procedure RFFTF1(var C,CH,WA:VGiganteR; var IFAC: VIType);
label
	L100,l101,l102,l103,l104,l105,l106,l107,l108,l109,
	l110,l111,l112,l113,l114,l115,l116,l117,l118,l119;
var
	NF,NA,L2,IW,L1,IDO,IDL1,IP:integer;
	k1,kh,IX2,IX3,IX4,I:integer;
	wa1,wa2,wa3: VGR_parasito;

begin
	NF := IFAC[2];
	NA := 1;
	L2 := N;
	IW := N;
	for k1 := 1 to NF do {111}
	begin
		KH := NF-K1;
		IP := IFAC[KH+3];
		L1 := L2 div IP;
		IDO := N div L2;
		IDL1 := IDO*L1;
		IW := IW-(IP-1)*IDO;
		NA := 1-NA;
		IF (IP = 4) then
		begin
			IX2 := IW+IDO;
			IX3 := IX2+IDO;
         wa1.Link(WA,IW);
			wa2.Link(WA,IX2);
			wa3.Link(WA,IX3);
			IF (NA <> 0) then
				RADF4 (IDO,L1,CH,C,wa1,wa2,wa3)
			else
				RADF4 (IDO,L1,C,CH,wa1,wa2,wa3);
		end
		else
		begin
			IF (IP <> 2) then GOTO l104;
			IF (NA <> 0) then GOTO l103;
			wa1.link(WA,IW);
			RADF2 (IDO,L1,C,CH,wa1);
			GOTO l110;
l103:    wa1.link(WA,IW);
			RADF2 (IDO,L1,CH,C,wa1);
			GOTO l110;
l104:		IF (IP <> 3) then GOTO l106;
			IX2 := IW+IDO;
			IF (NA <> 0) then GOTO l105;
			wa1.link(WA,IW);
			wa2.link(WA,IX2);
			RADF3 (IDO,L1,C,CH,wa1,wa2);
			GOTO l110;
l105:    wa1.link(WA,IW); wa2.link(WA,IX2);
			RADF3 (IDO,L1,CH,C,wa1,wa2);
			GOTO l110;
l106:		IF (IP <> 5) then GOTO l108;
			IX2 := IW+IDO;
			IX3 := IX2+IDO;
			IX4 := IX3+IDO;
			IF (NA <> 0) then GOTO l107;
			wa1.link(wa,iw); wa2.link(wa,ix2);wa3.link(wa,ix3);wa4.link(wa,ix4);
			RADF5 (IDO,L1,C,CH,wa1,wa2,wa3,wa4);
			GOTO l110;
l107:    wa1.link(wa,iw); wa2.link(wa,ix2);wa3.link(wa,ix3);wa4.link(wa,ix4);
			RADF5 (IDO,L1,CH,C,wa1,wa2,wa3,wa4);
			GOTO l110;
l108:    IF (IDO = 1)then NA := 1-NA;
			IF (NA <> 0 )then  GOTO l109;
			wa1.link(wa,iw);
			RADFG (IDO,IP,L1,IDL1,C,C,C,CH,CH,wa1);
			NA := 1;
			GOTO l110;
l109:    wa1.link(wa,iw);
			RADFG (IDO,IP,L1,IDL1,CH,CH,CH,C,C,wa1);
			NA := 0;
l110: 	{nada}
		end;

		L2 := L1; {original l110}
	end; {111}

	if NA <> 1 then
		for I:= 1 to N do C.put(CH.e(I),I);
end;





procedure FFTF(var R:VGiganteR; var AZERO: real; var A, B:VGiganteR);
var
	NS2,NS2M,I:integer;
	CFM,CF:real;
begin
	if n<2 then
	begin
		AZERO:=R.e(1);
		exit
	end;
	if n = 2 then
	begin
		AZERO := 0.5*(R.e(1)+R.e(2));
		A.put(0.5*(R.e(1)-R.e(2)),1);
		exit
	end;
	for I:= 1 to N do   C.put(R.e(I),I);
	RFFTF1 (C,CH,WA,VIType(IFACPtr^));
	CF := 2/N;
	CFM := -CF;
	AZERO := 0.5*CF*C.e(1);
	NS2 := (N+1) DIV 2;
	NS2M := NS2-1;
	for I:= 1 to NS2M do
	begin
		A.put(CF*C.e(2*I),I);
		B.put(CFM*C.e(2*I+1),I);
	end;
	IF (N mod 2 =  0) THEN
	begin
		A.put(0.5*CF*C.e(N),NS2);
		B.put(0.0,NS2);
	end
end;


end.