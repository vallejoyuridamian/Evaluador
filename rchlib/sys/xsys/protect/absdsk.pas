{+doc
+NOMBRE: absdsk
+CREACION: 30.8.92
+AUTORES:  rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Interface para los servicios de escritura y lectura a y de
	clusters absolutos del disco.

+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit absdsk;
interface
uses
	{$I xdos};

Const
	CarryFlag = $01;

type
	TipoDrive = (CDRV_DEFAULT,CDRV_A,CDRV_B,CDRV_C,CDRV_D);

type

	T_DskInfo = record
		SectoresPorCluster: byte; { N£mero de sectores por cluster }
		BytesPorSector,			{ N£mero de bytes por sector }
		NumeroDeClusters: word; { N£mero total de cluster en el disco }
		FatId: byte;	{ Identificador de la Fat. }
	end;


procedure GetDefaultDriveData( var res: T_DskInfo);
procedure GetDriveData(
	drv: TipoDrive;
	var res: T_DskInfo
);

function AbsoluteDiskRead(
	Drv: TipoDrive;
	var Buffer; { Buffer de memoria al que se leer n los sectores }
	NumeroDeSectores: word; { Cantidad de sectores a leer }
	PrimerSector: word { Primer sector (l¢gico) a leer }
):byte; { retorna c¢digo de error }

function AbsoluteDiskWrite(
	Drv: TipoDrive;
	var Buffer; { Buffer de memoria del que se leer n los sectores }
	NumeroDeSectores: word; { Cantidad de sectores a leer }
	PrimerSector: word { Primer sector (l¢gico) a leer }
):byte; { retorna c¢digo de error }


implementation
procedure GetDefaultDriveData( var res: T_DskInfo);
var
{$IFDEF WINDOWS}
	r:TRegisters;
{$ELSE}
	r:registers;
{$ENDIF}

begin
	r.ah := $1b;
	MsDos(r);
	res.SectoresPorCluster:=r.al;
	res.BytesPorSector:=r.cx;
	res.NumeroDeClusters:=r.dx;
	res.FatID:=mem[r.ds:r.bx];
end;

procedure GetDriveData(
	drv: TipoDrive; { drv number  0= default, 1=A, 2=B, etc. }
	var res: T_DskInfo
);
var
{$IFDEF WINDOWS}
	r:TRegisters;
{$ELSE}
	r:registers;
{$ENDIF}

begin
	r.ah := $1c;
	r.dl:=byte(drv);
	MsDos(r);
	res.SectoresPorCluster:=r.al;
	res.BytesPorSector:=r.cx;
	res.NumeroDeClusters:=r.dx;
	res.FatID:=mem[r.ds:r.bx];
end;

function AbsoluteDiskRead(
	Drv: TipoDrive;
	var Buffer; { Buffer de memoria al que se leer n los sectores }
	NumeroDeSectores: word; { Cantidad de sectores a leer }
	PrimerSector: word { Primer sector (l¢gico) a leer }
):byte; { retorna c¢digo de error }
begin
{$IFOPT R+}
if (Drv <  CDRV_A ) or (Drv> CDRV_C) then RunError(201);
{$ENDIF}
dec(Drv);
asm
	push ds
	mov al, Drv
	lds bx, Buffer
	mov cx, NumeroDeSectores
	mov dx, PrimerSector
	push bp
	Int $25
	jc @fin
	xor al, al
@fin:
	mov @result,al
	popf
	pop bp
	pop ds
end;
end;


function AbsoluteDiskWrite(
	Drv: TipoDrive; {  0=A, 1=B, etc.}
	var Buffer; { Buffer de memoria del que se leer n los sectores }
	NumeroDeSectores: word; { Cantidad de sectores a leer }
	PrimerSector: word { Primer sector (l¢gico) a leer }
):byte; { retorna c¢digo de error }
begin
{$IFOPT R+}
if (Drv <  CDRV_A ) or (Drv> CDRV_C) then RunError(201);
{$ENDIF}
dec(Drv);
asm
	push ds
	mov al, Drv
	lds bx, Buffer
	mov cx, NumeroDeSectores
	mov dx, PrimerSector
	push bp
	Int $26
	jc @fin1
	xor al, al
	jp @fin2
@fin1:
	mov al, 1
@fin2:
	mov @result,al
	popf
	pop bp
	pop ds
end;
end;

end.


