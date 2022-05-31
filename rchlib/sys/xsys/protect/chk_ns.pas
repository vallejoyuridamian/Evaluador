program xchns;
uses
	CRT, NUMSER, AbsDsk, Int2Hexa;
var
	New_NS: string;
	NNS: LongInt;
	cdrv: char;
	drv: TipoDrive;
	p2:string;
	OldDirStr: string;
	ir:boolean;

begin

	if ParamCount <> 2 then Halt(3);
	NNS:= HexaStr2LongInt( ParamStr(1) );
	p2:= ParamStr(2);
	cdrv:= UpCase(p2[1]);
	case cdrv of
	'A': drv := A;
	'B': drv := B;
	else
		Halt(2);
	end;

	GetDir(0, OldDirStr);
	{$I-}
	ChDir(cdrv+':\');
	{$I+}
	if ioresult<>0 then ir:= true
	else ir:=false;

	ChDir(OldDirStr);

	if ir then Halt(4);

	if Not Check_NS(drv, NNS) then
		halt(1)
end.
