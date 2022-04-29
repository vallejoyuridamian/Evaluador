program fsplit;

uses
	horrores;

const
	TamBuff = 40*1024;
var
	fin, fout1, fout2: file;
	pbuf: pointer;
	LF1, LF2, LF0: LongInt;

function ParamLongInt( k: word ): LongInt;
var
	tmp: LongInt;
	s: string;
	rescode: integer;
begin
	s:= ParamStr(k);
	val(s, tmp, rescode);
	if rescode<> 0 then
	begin
		str( k, s);
		error(' Leyendo par metro (LongInt): '+s);
	end;
	ParamLongInt:= tmp;
end;

procedure Copiar( var fout: file; LF1: LongInt );
var
	nres: word;
begin
	while LF1 > 0 do
	begin
		if LF1 > TamBuff then
		begin
			BlockRead( fin, pbuf^, TamBuff, Nres );
			if nres <> tambuff then error( ' ojo no lei lo necesario ');
			BlockWrite( fout, pbuf^, tamBuff, Nres );
			if nres <> tamBuff then error(' ojo, no escribi todo ');
			LF1:= LF1 -TamBuff;
		end
		else
		begin
			BlockRead( fin, pbuf^, LF1, Nres );
			if nres <> LF1 then error( ' ojo no lei lo necesario ');
			BlockWrite( fout, pbuf^, LF1, Nres );
			if nres <> LF1 then error(' ojo, no escribi todo ');
			LF1:= 0;
		end
	end;
end;

procedure Help;
begin
	writeln;
	writeln(' FSplit :::: >> rch93 ');
	writeln(' Sint xis: ');
	writeln('          FSplit  arch0  NkBYTES arch1 arch2 ');
	writeln;
	writeln('   Se crean los archivos arch1 y arch2.');
	writeln('   El archivo arch1 contendr  los primeros ');
	writeln(' NkBYTES  kiloBytes de arch0 y arch2 los restantes.');
	writeln;
	writeln('   Para concatenar nuevamente los archivos puede utilizar');
	writeln(' el comando FConcat. ');
	halt(0);
end;

begin
	if ParamCount <> 4 then Help;
	assign( fin, ParamStr(1) );
	reset( fin, 1);

	LF1:= ParamLongInt(2)*1024;
	LF0:= FileSize(fin);
	LF2:= LF0 - LF1;


	GetMem(pbuf, TamBuff);

	assign( fout1, ParamStr(3));
	rewrite( fout1, 1);
	Copiar( fout1, LF1);
	close(fout1);

	assign( fout2, ParamStr(4));
	rewrite( fout2, 1);
	Copiar( fout2, LF2);
	close(fout2);

	close( fin );
	FreeMem(pbuf, TamBuff);
end.