{$M  1024,0,1024}
program delchar;
uses
	dos,crt;

procedure ayuda;
begin
	writeln;
	writeln('====================================================');
	writeln('rch91');
	writeln('.......');
	writeln('...............');
	Writeln('..........................');
	writeln('........ DELCHAR .................');
	writeln;
	writeln('--------------------');
	writeln('Sintaxis:');
	writeln('delchar x sbstr str [archivo.sal]');
	writeln('--------------------');
	writeln('Prop¢sito:');
	writeln('   Borra el primer o el £ltimo caracter del string (str)');
	writeln('hasta que el substring sbstr no apareza en lo que queda');
	writeln(' si x = i, el borrado se hace de izquierda a derecha,');
	writeln(' si x = d, el borrado se hace desde la derecha. ');
	writeln('   Si se especif¡ca archivo de salida, el resultado es ');
	writeln('agregado al final del mismo');
	Halt(1);
end;


var
	r,b:string;
	d:char;
	k,tam:integer;

begin
	
	assign(input,'');reset(input);
	if ParamCount< 3 then Ayuda;

	if length(ParamStr(1))<>1 then ayuda;
	r:=ParamStr(1);
	d:=UpCase(r[1]);
	r:=ParamStr(3);
	b:=ParamStr(2);
	tam:=length(b);
	k:=pos(b,r);

	if d = 'I' then
		while k<> 0 do
		begin
			delete(r,1,k+tam-1);
			k:=pos(b,r)
		end
	else
		if d = 'D' then
			while k<> 0 do
			begin
				delete(r,k,length(r)-k+1);
				k:=pos(b,r)
			end
		else ayuda;
	assign(output,ParamStr(4));
	{$I-}
	append(output);
	{$F+}
	if ioresult<> 0 then	rewrite(output);
	writeln(r);
	close(output);
end.



