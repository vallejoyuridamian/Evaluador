program newfile;

uses DOS, Objects, ShareDOS;

var
	f: TDosStream;
   t:string;

begin
	t:='c:\basura\';
   f.INit(t, $5A02);
   f.Seek(0);
	 f.write(t[2],4);
	 f.done;
end.