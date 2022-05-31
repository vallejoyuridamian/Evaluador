program verlck;
uses
	{$I xCRT},
	Objects, {$I xDOS}, ShareDos;

var
	f,g:TDosStream;
	

type
	lckrc= record
		n: string;
		s: word;
		res: integer;
		ree: integer;
	end;

const
	scs: array[1..5] of lckrc = (
			(n: 'Compa'; s: Share_Compatibility; res:0; ree:0),
			(n: 'DBoth'; s: Share_DenyBoth; res:0; ree:0),
			(n: 'DWrit'; s: Share_DenyWrite; res:0; ree:0),
			(n: 'DRead'; s: Share_DenyRead; res:0; ree:0),
			(n: 'DNone'; s: Share_DenyNone; res:0; ree:0));



procedure testlck( fn: string);
var
	f: TDosStream;
	k: integer;
begin
	for k:= 1 to 5 do
	begin
		{$IFDEF WINDOWS}
		fn:= fn+#0;
		f.Init(@fn[1], stOpen + scs[k].s);
		{$ELSE}
		f.Init(fn, stOpen + scs[k].s);
		{$ENDIF}
		scs[k].res:= f.status;
		scs[k].ree:= f.ErrorInfo;
		if f.status = stOk then
			f.done;
	end;
	while length(fn)<14 do fn:=fn+' ';
	write(fn, ': ');
	for k:= 1 to 5 do
		write(scs[k].res:6, scs[k].ree:6);
	writeln;
end;

var
{$IFDEF WINDOWS}
  DirInfo: TSearchRec;
{$ELSE}
  DirInfo: SearchRec;
{$ENDIF}
  mascara: string;
  k: integer;
begin
	if ParamCount>0 then mascara:= ParamStr(1)
	else Mascara:= '*.*';
	writeln;
	write(' testlcks:            ');
{$IFDEF WINDOWS}
	mascara:= mascara+#0;
{$ENDIF}
	for k:= 1 to 5 do write(scs[k].n,'       ');
	writeln;
{$IFDEF WINDOWS}
	FindFirst(@mascara[1], faArchive, DirInfo);
{$ELSE}
	FindFirst(mascara, Archive, DirInfo);
{$ENDIF}
  while DosError = 0 do
  begin
	 {WriteLn(DirInfo.Name);}
	 TestLck(DirInfo.Name);
    FindNext(DirInfo);
  end;
end.
