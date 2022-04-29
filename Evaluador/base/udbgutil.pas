unit udbgutil;
{$IFDEF CHEQUEOMEM}
{$DEFINE DEBUG_MEM}
{$ENDIF}

interface
uses
	SysUtils;

{$IFDEF DEBUG_MEM}
procedure pdl( s: string; memSet: boolean; stop: boolean );

// TotalAllocatedMemory
function tam: cardinal;
{$ENDIF}

implementation

{$IFDEF DEBUG_MEM}
var
	TotalAllocated: cardinal;

function tam: cardinal;
var
	hs: TFPCHeapStatus;
begin
	hs:= GetFPCHeapStatus;
	result:= hs.CurrHeapUsed;
end;

procedure pdl( s: string; memSet: boolean; stop: boolean );
var
	ts: string;
	hs: TFPCHeapStatus;
begin
	hs:= GetFPCHeapStatus;
	ts:= s+' TotalAllocated: '+IntToStr( hs.CurrHeapUsed )+ ' Diff: '+IntToStr( hs.CurrHeapUsed - TotalAllocated ) ;
	if memSet then
		TotalALlocated:= hs.CurrHeapUsed;
	writeln( ts,' ...? ENTER' );
	if stop then	readln;
end;

initialization
	TotalAllocated:= 0;
{$ENDIF}
end.
