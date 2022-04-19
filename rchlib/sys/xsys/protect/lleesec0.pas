uses
	absdsk,crt;

var
	buff: array [1..512] of byte;

	k:word;

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
	ClrScr;
	assign(output,'');
	rewrite(output);

	AbsoluteDiskRead(
		0, {  0=A, 1=B, etc.}
		Buff, { Buffer de memoria al que se leer n los sectores }
		1, { Cantidad de sectores a leer }
		0 { Primer sector (l¢gico) a leer }
); { retorna c¢digo de error }

	for k:= 1 to 512 do write( chr(buff[k]));
end.
