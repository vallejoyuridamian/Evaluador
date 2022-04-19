uses
	absdsk, direntry;

var
	buffer: array[0..511*2] of byte;
	k,j:integer;
	res:byte;
	p: ^DirectoryEntryType;
	sector:integer;

const
	digitosHexa:string = '0123456789ABCDEF';

function WordToHexaStr( w:word):string;
var
	tmp:string;
	r,q:word;
begin
	tmp:='';
	q:= w;
	while q>0 do
	begin
		r:= q mod 16;
		q:= (q-r) div 16;
		tmp:=DigitosHexa[r+1]+tmp;
	end;
	WordToHexaStr:=tmp;
end;



begin
	sector:=20;
while true do
begin
	writeln;
	writeln('sector : ',sector);
	writeln;
	res:= AbsoluteDiskRead(
						0{Drv=A},
						Buffer,
						1{Leer un sector},
						sector{sector a leer});

	for k:= 0  to 15 do
	begin
		p:=pointer(@buffer[k*32]);
		With p^ do
		begin
			writeln;
			for j:=1 to 8 do write(FileName[j]);
			write('.');
			for j:= 1 to 3 do write(FileExt[j]);
			write('  Starting Cluster: ',StartingCluster);
		end;
	end;
	readln;
	inc(sector);
end;

end.
end.