program xp;
uses
	NWStream, Dos,Objects;
var
	f:TNWStream;
   ps,qs: PString;


begin
	getMem(ps,100);
   getMem(qs,100);

	ps^:='Hola que tal';


	f.Init('c:\basura\', StCreate);
	writeln(f.errorInfo);
	f. writestr(ps);
	writeln(ps^);

	f.Seek(0);
	qs:=f.readstr ;
	writeln(qs^);

	f.done;
end.
