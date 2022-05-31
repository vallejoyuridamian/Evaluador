

Unit AdquiDef;
interface
uses
	LectFile;

type

	palStr = string[10];
	LVI = array[1..10000] of integer;
	LVIPtr = ^LVI;

	adqui = object
		{ WFMPRE }
		WFID:string; {"REF2, CH1, 50.0V, AC, 5.0mS, SAMPLE, CRV# 3",}
		NR_PT:integer;  {512,}
		PT_OFF:integer; {256, }
		PT_FMT:palstr; {Y,}
		XMULT:real; {1.0E+0,}
		XOFF:real; {0,}
		XUNIT:palStr; {S,}
		XINCR:real; {0.1E-3,}
		YMULT:real; {2.0E+0,}
		YOFF:real; {0,}
		YUNIT:palStr; {V,}
		ENCDG:palStr; {ASCII,}
		BN_FMT:palStr; {RP,}
		BYT_NR:integer; {1,}
		BIT_NR:integer; {8,}
		CRVCHK:palStr; {CHKSM0;}
		CURVE: LVIPtr;

		constructor readFrom(nomb:string);
		destructor done;
	end;

implementation

constructor adqui.readFrom(nomb:string);
var
	f:FOC;
	k:integer;
begin
	assign(f,nomb);
	reset(f);

		WFID:=RNS(f);
		NR_PT:=RNI(f);
		PT_OFF:=RNI(f);
		PT_FMT:=RNS(f);
		XMULT:=RNR(f);
		XOFF:=RNR(f);
		XUNIT:=RNS(f);
		XINCR:=RNR(f);
		YMULT:=RNR(f);
		YOFF:=RNR(f);
		YUNIT:=RNS(f);
		ENCDG:=RNS(f);
		BN_FMT:=RNS(f);
		BYT_NR:=RNI(f);
		BIT_NR:=RNI(f);
		CRVCHK:=RNS(f);

		GetMem(CURVE,NR_PT * SizeOf(Integer));

		SkipStr(f,'CURVE ');
		for k:= 1 to NR_PT do
			LVI(CURVE^)[k]:=RII(f);

	close(f)
end;

destructor adqui.done;
begin
	FreeMem(curve,NR_PT*SizeOf(Integer));
end;


end.
