program Llenar;
uses
	DOS;

var
	f:file;
	a:array[1..512*100] of char;
	k:word;
	Disco:string;
	Resto:LongInt;
	DiscoDeArranque:string;
	OldExitProc:pointer;

procedure AlFinal;
begin
	ExitProc:=OldExitProc;
	ChDir(DiscoDeArranque);
end;



begin
	GetDir(0, DiscoDeArranque);
	OldExitProc:=ExitProc;
	ExitProc:= @AlFInal;

	Disco:='a:\';
	ChDir(Disco);

	for k:= 1 to 512*100 do a[k]:= 'r';
	assign(f,'Llenar.dat');
	rewrite(f,512);
	Resto:= DiskFree(0);
	Writeln(' Espacio Total: ',Resto);

	while Resto >= 512*100 do
	begin
		BlockWrite(f,a,100);
		Resto:= DiskFree(0);
		writeln('Resto: ',Resto);
	end;

	while Resto >= 512 do
	begin
		BlockWrite(f,a,1);
		Resto:= DiskFree(0);
		writeln('Resto: ',Resto);
	end;

	Close(f);
	Resto:=DiskFree(0);
	if Resto > 0 then
	begin
		writeln(' Rellenando el resto');
		reset(f,1);
		seek(f,FileSize(f));
		BlockWrite(f,a,Resto);
		close(f)
	end;
end.