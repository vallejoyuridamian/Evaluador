program xptraxp;
(* programa para optimizaci¢n de tiempos *)

uses
	dos,traxp;
var
	k:integer;
function tiempo:word;
const
	h:word=0;
	m:word=0;
	s:word=0;
	s100:word=0;
	par:boolean=true;
var
	ha,ma,sa,s100a:word;

begin
	if par then
	begin
		gettime(h,m,s,s100);
		par:=false;
		tiempo:=0
	end
	else
	begin
		gettime(ha,ma,sa,s100a);
		par:=true;
		tiempo:=(ma*60+sa)*100+s100a-((m*60+s)*100+s100);
	end;
end;


var
	tax:word;

begin
	Iniciegr;
	subplot(1,1);
	tinicial:=0;
	tfinal:=1000;
	definaY(0,-4,1);
	tax:=tiempo;
	for k:= 0 to 1000 do
	begin
		t:=k;
		trazo(0,(k mod 7)-3);
	end;
	tax:=tiempo;
	readln;
	TermineGr;
	writeln('Tiempo para hacer 1000 trazos sin cortes: ',tax);
end.
