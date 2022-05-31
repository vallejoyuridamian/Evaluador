{$M 5092,0,0}
program UpDate;

uses Dos;
const
	pkz = 'c:\util\pkz';
	zip = pkz+'\pkzip';
	unzip = pkz+'\pkunzip';
	zipfile:string = 'rchlib';
	Destino:string = 'c:\usr\rch\rchlib';
	Etiqueta:string = '3B21-12E8';

var
	DA:string;
	cmn:array[1..10] of string;
var
  Command: string[79];
  k:integer;


function UpStr(x:string):string;
var
	k:integer;
begin
	for k:= 1 to length(x) do x[k]:= UpCase(x[k]);
	UpStr:=x
end;

procedure RC(Cmn:string);
begin
	Cmn := '/C ' + Cmn;
	SwapVectors;
	Exec(GetEnv('COMSPEC'), Cmn);
	SwapVectors;
	if DosError <> 0 then
			WriteLn('No puedo ejecutar COMMAND.COM');
end;

procedure ChequearDisco;
var
	DirInfo: SearchRec;
begin
	FindFirst('*.*', VolumeID, DirInfo);
	if pos( Etiqueta, DirInfo.name)= 0 then
	begin
		writeln('............Se equivoc¢ de disco..........');
		readln;
		halt(1);
	end;
end;




begin
	zipfile:=ParamStr(1); { 'a:\' }
	destino:=ParamStr(2);
	Etiqueta:= UpStr(ParamStr(3));
	da:=copy(zipfile,1,3);
	if pos(':',da) = 2 then ChDir(DA);
	CHequearDisco;
	cmn[1]:=	unzip+' -d -n '+zipfile+' '+Destino;
	cmn[2]:=	'c:';
	cmn[3]:=	'cd '+Destino;
	cmn[4]:=	zip+' -bc:\basura -r -p -u '+zipfile+' *.pas *.txt *.doc *.sim *.bat *. *.dsk';
	for k:= 1 to 4 do
	begin
		command:= cmn[k];
		rc(command);
	end;
end.
