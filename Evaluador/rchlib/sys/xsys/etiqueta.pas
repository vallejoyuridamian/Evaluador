{$M 1024,0,1000}
program Etiqueta;
{
Prop¢sito: Devuelve la etiqueta del drive en que est 
}

uses
	CRT,dos;

var
	DirInfo: SearchRec;
	s:string;
begin
	writeln;
	writeln('--------------------------------');
	writeln('>>>> Etiqueta <<<< RCh, 17/11/91');
	writeln('................................');
	writeln;
	writeln('Etiqueta ?, despliega ayuda');
	writeln;
	if (ParamCount = 1) and (ParamStr(1) = '?') then
	begin
		writeln('Prop¢sito: Despliega la Etiqueta del drive actual,');
		writeln('o del drive pasado como par metro.');
		writeln;
		writeln('Sintaxis:  Etiqueta [drive]');
		writeln;
		writeln('Ejemplos:');
		writeln(' Etiqueta        ,despliega la etiqueta del disco actual');
		writeln(' Etiqueta a:     ,despliega la etiqueta del disco a:');
		writeln(' Etiqueta ?      ,despliega esta ayuda');
		writeln;
		writeln('­Para desplegar la etiqueta, se usa la salida standard');
		writeln('por tanto, es posible redireccionar la respuesta.!');
	end;
	GetDir(0,s);

	assign(Output,'');
	rewrite(Output);
	if ParamCount = 1 then ChDir(ParamStr(1));
	FindFirst('*.*', VolumeID, DirInfo);
	writeln(DirInfo.Name);
	if ParamCount = 1 then ChDir(s);
end.
