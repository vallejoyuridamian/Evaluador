program mn;

uses
	netwks;

var
	m:string;
   f: text;

begin
	 if GetMachineName(m)=0 then
		writeln('set maquina='+m)
{
	assign(f,'c:\nmaq.bat');
	 rewrite(f);
	 if GetMachineName(m)=0 then write(f,'set maquina='+m)
	 else;
	 close(f);  }
end.



