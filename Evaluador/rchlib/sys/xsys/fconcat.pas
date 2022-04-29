program fconcat;

uses
	horrores;

const
	TamBuff = 40*1024;
var
	fin, fout: file;
	pbuf: pointer;
	LF1, LF2, LF0: LongInt;


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
	writeln(' FConcat :::: >> rch93 ');
	writeln(' Sint xis: ');
	writeln('          FConcat  arch0 arch1 arch2 ');
	writeln;
	writeln('   Los archivos arch0 y arch1 se concatenan en arch2');
	halt(0);
end;

begin
	if ParamCount <> 3 then Help;

	GetMem( pbuf, TamBuff);

	assign( fout, ParamStr(3));
	rewrite( fout, 1);

	assign( fin, ParamStr(1) );
	reset( fin, 1);
	LF1:= FileSize(fin);
	Copiar( fout, LF1);
	close( fin);

	assign( fin, ParamStr(2));
	reset( fin, 1);
	LF2:= FileSize(fin);
	Copiar( fout, LF2);
	close(fin);

	close( fout );
	FreeMem(pbuf, TamBuff);
end.