program numpcnfs;
uses
	horrores,
	Int2Hexa;

var
	f: file of char;
	c: char;

const
	PCNFS: string = 'PC-NFS';

var
	ki: integer;
	buscando: boolean;
	fp: LongInt;


function ROL( i: integer ): integer;
begin
	i:= i SHL 1;
	if (i and $10) <> 0 then i:= (i or 1) and $F;
	ROL:= i;
end;


function ROR( i: integer ): integer;
begin
	if (i and $1) <> 0 then i:= i or $10;
	i:= i SHR 1;
	ROR:= i;
end;

function CheckSum( var s: string ): integer;
var
	cs: integer;
	k: integer;
begin
	cs:= CD(s[5]);
	cs:= ROR(cs xor( CD(s[6])));
	cs:= (cs xor( CD(s[7])));
	CheckSum:=cs;
end;





begin
	if ParamCount = 1 then
	begin
		writeln(' Sintaxis: ');
		writeln;
		writeln('   numpcnfs [-s xxxxyyyy]');
		writeln;
		writeln('  Donde xxxxyyyy es un n£mero de serie.');
		writeln('  El valor CheckSum deber¡a conincidir con el £ltimo d¡gito');
		halt(1);
	end;

	assign(f, 'pcnfs.sys');
	reset(f);

	for ki:= 1 to 20 do read(f,c);

	buscando:= true;
	ki:= 1;
	while Buscando and Not EOF(f) do
	begin
		read(f,c);
		if c=PCNFS[ki] then
		begin
			inc(ki);
			if ki>length(PCNFS) then
			begin
				Buscando:=false;
				fp:= filepos(f);
			end
		end
		else ki:=1;
	end;

	if not buscando then
	begin
		seek(f, fp);
		writeln('N£mero de serie: ');
		for ki:= 1 to 8 do
		begin
			read(f,c); write(c);
		end;
		writeln;
	end
	else
		error('NO ENCUENTRO CADENA: "PC-NFS"');

	if ParamStr(1) = '-s' then
	begin
		seek(f, fp);
		PCNFS:= ParamStr(2);
		if length(PCNFS) <> 8 then error(' los n£mero deben ser de 8 d¡gitos hexa.');
		writeln(' CheckSum: ', CheckSum(PCNFS));
		for ki:= 1 to 8 do
			write(f, PCNFS[ki]);
	end;

	close(f);
end.



