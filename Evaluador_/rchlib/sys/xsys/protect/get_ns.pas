uses
	absdsk, {$I xCRT};


var
	buff: array [0..511] of byte;

	k:word;

const
	digitosHexa:string = '0123456789ABCDEF';

function WordToHexaStr( w:LongInt):string;
var
	tmp:string;
	r,q:LongInt;
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
	assign(output,'');
	rewrite(output);

	AbsoluteDiskRead(
		CDRV_C, {  0=A, 1=B, etc.}
		Buff, { Buffer de memoria al que se leer n los sectores }
		1, { Cantidad de sectores a leer }
		0 { Primer sector (l¢gico) a leer }
); { retorna c¢digo de error }

	writeln(WordToHexaStr(LongInt(pointer(@buff[$27])^)));
end.
