unit NumSer;
interface
uses
	absdsk;
Type
	RegistroDeArranque = array[0..511] of byte;


function Get_NS(drv:TipoDrive): LongInt;
function Check_NS(drv:TipoDrive; NS:Longint):boolean;
procedure Change_NS(drv:TipoDrive; New_NS: LongInt);




implementation

function Check_NS( drv: TipoDrive; NS:Longint):boolean;
begin
	Check_NS := Get_NS(drv) = NS;
end;


function Get_NS(drv:TipoDrive): LongInt;
var
	buff:
	record
		 x:array [0..$26] of byte;
		 ns:LongInt;
		 y:array [$2B..511] of byte;
	end;

begin
	AbsoluteDiskRead(
		drv, {  0=A, 1=B, etc.}
		Buff, { Buffer de memoria al que se leer n los sectores }
		1, { Cantidad de sectores a leer }
		0 { Primer sector (l¢gico) a leer }
); { retorna c¢digo de error }

	Get_NS:=Buff.ns;
end;
procedure Change_NS(drv:TipoDrive; New_NS: LongInt);
var
	buff:
	record
		 x:array [0..$26] of byte;
		 ns:LongInt;
		 y:array [$2B..511] of byte;
	end;

begin
	AbsoluteDiskRead(
		drv, {  0=A, 1=B, etc.}
		Buff, { Buffer de memoria al que se leer n los sectores }
		1, { Cantidad de sectores a leer }
		0 { Primer sector (l¢gico) a leer }
); { retorna c¢digo de error }

	Buff.ns:= New_NS;
	AbsoluteDiskWrite(
		drv, {  0=A, 1=B, etc.}
		Buff, { Buffer de memoria al que se leer n los sectores }
		1, { Cantidad de sectores a leer }
		0 { Primer sector (l¢gico) a leer }
); { retorna c¢digo de error }

end;

end.