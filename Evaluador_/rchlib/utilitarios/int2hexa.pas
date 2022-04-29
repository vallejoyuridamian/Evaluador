unit Int2Hexa;
interface

const
	DigitosHexa:string = '0123456789ABCDEF';

{ Convierte un decimal (LongInt) a la correspondiente cadena de caracteres
	hexa }
function LongInt2HexaStr( w:LongInt ):string;

{ Convierte una cadena de caracteres hexa a un n£mero decimal (LongInt) }
function HexaStr2LongInt( s: string): longInt;

{ Convierte un caracter hexa a un n£mero decimal }
function CD( c:char):integer;

implementation
function LongInt2HexaStr( w:LongInt ):string;
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
	LongInt2HexaStr:=tmp;
end;

function CD( c:char):integer;
var
	i:integer;
begin
	i:= pos( UpCase(c), DigitosHexa);
{$IFOPT R+}
	if  i<= 0 then runerror(201);
{$ENDIF}
	CD:= i-1;
end;

function HexaStr2LongInt( s: string): LongInt;
var
	k,pu:word;
	x:LongInt;
begin
	pu:= Length(s);
	x:= cd(s[1]);
	for k:=2 to pu do x:= x*16+cd(s[k]);
	HexaStr2LongInt := x
end;


end.


