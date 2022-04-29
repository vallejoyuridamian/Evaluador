unit netwks;
interface
function GetMachineName(var MachineName:string):integer;

implementation

uses
	{$I xDOS};

function GetMachineName(var MachineName:string):integer;
var
	mn:string[16];
{$IFDEF WINDOWS}
	r:Tregisters;
{$ELSE}
	r:registers;
{$ENDIF}

begin
	r.AH:=$5E;
	r.AL:=$00;
	r.DS:= Seg(mn[1]);
	r.DX:= Ofs(mn[1]);
	MSDOS(r);

	if r.CH = 0 then
	begin
		MachineName:='';
		GetMachineName:=1;
	end
	else
	begin
		mn[0]:=chr(15);
		while pos(' ',mn) <> 0 do delete(mn,pos(' ',mn),1);
	(*
		mn[0]:= chr(1);
		while mn[byte(mn[0])] <> #0 do inc(byte(mn[0]));
	  *)

		MachineName:=mn;
		GetMachineName:=0;
	end;
end;


end.
