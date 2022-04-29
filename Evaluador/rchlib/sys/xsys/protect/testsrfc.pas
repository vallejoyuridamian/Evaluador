{$A-}
program TestSrfc; { RCH 9jun93 }

uses
	CRT, AbsDsk, Int2Hexa, DirEntry;

const
	drv = A;
type
	TiposDeFats = ( _12bits, _16bits );
var

	ts: string;
	TipoDeFat: TiposDeFats;
	m: word;
	Basura: Pointer;


Type
	TLAB = array[0..30000] of byte;
	pLab = ^Tlab;

	TTriBy = array[0..2] of byte;
	TBootSector = record
		NearJumpBootCode: TTriBy;
		OEMNameAndVersion: array[0..7] of char;
		{ BPB -------------------- }
		BytesPerSector : word;
		SectorsPerAllocationUnit: byte;
		ReservedSectors: word;
		NumberOfFats: byte;
		NumberOfRootsDirEntries: word;
		NumberOfSectorsInLogicalImage: word;
		MediaDescriptor: byte;
		NumberOfSectorsPerFat: word;
		{ BPB --------------------- }
		SectorsPerTrack: word;
		NumberOfHeads: word;
		NumberOfHiddendSectors: word;
		HighOrderNumberOfHiddenSectors: word;
		NumberOfLogicalSectos: Longint;
	end;

function TriBy2LongInt( x:TTriBy ): LongInt;
begin
	TriBy2LongInt := x[0]+(x[1]+x[2]*256)*256;
end;


function GetVal12BitsFat( var Fat: TLAB; cluster: word):word;
var
	byteoffset: LongInt;
	m: word;
begin
	byteoffset := trunc(cluster * 1.5);
	m:= word(pointer(@Fat[byteoffset])^);
	if (cluster and $01) = 0 then m:= m and $0FFF
	else m:=m SHR 4;
	GetVal12BitsFat := m;
end;


function GetVal16BitsFat( var Fat: TLAB; cluster: word):word;
var
	byteoffset: LongInt;
	m: word;
begin
	byteoffset := cluster * 2;
	m:= word(pointer(@Fat[byteoffset])^);
	GetVal16BitsFat := m;
end;

var
	dskinfo: T_DskInfo;
	buff: array[0..2550] of char;
	res: byte;
	k:integer;
	pFat1, pFat2: PLAB;
	NumeroDeClustersMalos: Longint;
	tam: integer;
	OffsetOfDataSector: Longint;




function ClusterGood( Cluster: word ): boolean;
var
	LogSec: LongInt;
	res: byte;
begin
	with TBootSector( pointer(@buff[0])^) do
	begin
		LogSec:= (Cluster-2)*SectorsPerAllocationUnit + OffsetOfDataSector;
		res:= AbsoluteDiskRead( DRV, Basura^, SectorsPerAllocationUnit, LogSec);
		if res <> 0 then ClusterGood:= false
		else ClusterGood:= true;
	end;
end;

procedure ComputeOffsetOfDataSector;
var
	tam: Longint;
begin
	with TBootSector( pointer(@buff[0])^) do
	begin

		tam:=SizeOf(DirectoryEntryType)*NumberOfRootsDirEntries;

		OffsetOfDataSector:=
				ReservedSectors+NumberOfSectorsPerFat*NumberOfFats+
					tam div BytesPerSector;

	end;
end;




begin
	res:=AbsoluteDiskRead(	Drv, Buff, 1, 0);
	if res <> 0 then
	begin
		writeln(' Error leyendo el sector 0 ');
		halt(1);
	end;

	with TBootSector( pointer(@buff[0])^) do
	begin
		ClrScr;
		writeln(' RCH... boot-sector inspector ');
		writeln('-------------------------------');
				
		case NearJumpBootCode[0] of
			235:	writeln(' Salto relativo al c¢digo de booteo: JMP ', NearJumpBootCode[1],' (rel8)');
			233:	writeln(' Salto relativo al c¢digo de booteo: JMP ', NearJumpBootCode[1],' (rel16)');
			else
			begin
				writeln(' C¢digo no conocido, por favor avise a: Ruben Chaer tel: 90-01-23 ');
				writeln(' que apareci¢ c¢digo : ', NearJumpBootCode[0] );
				writeln;
				writeln(' PRESIONE CUALQUIER TECLA PARA CONTINUAR');
				if keypressed then if readkey='m' then;
				repeat until keypressed;
				if keypressed then if readkey='m' then;
		
			end;
		end; {case}
		write(' OEM Name and Version: ');
		for k:= 0 to 7 do write( OEMNameAndVersion[k] );
		writeln;
		writeln(' ---------- comienzo del BPB ----------');

		{ BPB -------------------- }
		writeln(' Bytes por Sector: ',BytesPerSector);
		writeln(' Sectors por Unidad de Asignaci¢n: ',SectorsPerAllocationUnit);
		writeln(' Sectores Recervados: ',ReservedSectors);
		writeln(' N£mero de FATs: ',NumberOfFats);
		writeln(' N£mero de Entradas en el Directorio Raiz: ',NumberOfRootsDirEntries);
		writeln(' N£mero de Sectores en la Im gen L¢gica: ',NumberOfSectorsInLogicalImage);
		writeln(' Descriptor del Medio: ',MediaDescriptor);
		writeln(' N£mero de Sectores por FAT: ',NumberOfSectorsPerFat);
		{ BPB --------------------- }
		writeln(' ---------- fin del BPB ------------');

		writeln(' Sectors per Track: ',SectorsPerTrack);
		writeln(' Number of Heads: ',NumberOfHeads);
		writeln(' Number of Hiddend Sectors: ',NumberOfHiddendSectors);
		writeln(' High Order Number of Hidden Sectors: ',HighOrderNumberOfHiddenSectors );
		writeln(' Number of Logical Sectos: ',NumberOfLogicalSectos);

		writeln('------------------------');
		writeln(' RCH Fats Inspector ');
		writeln(' reading fat1');
		writeln('-----');
		write(' Tipo de Fat: ');
		if  NumberOfSectorsInLogicalImage > 4085 then
		begin
			TipoDeFat:= _16bits;
			writeln( '16bits');
		end
		else
		begin
			TipoDeFat:= _12bits;
			writeln( '12bits');
		end;

		GetMem( Basura, SectorsPerAllocationUnit* BytesPerSector );
		writeln(' FAT: < CLUSTERs > testing');
		NumeroDeClustersMalos:= 0;
		for k:= 2 to NumberOfSectorsInLogicalImage  div SectorsPerAllocationUnit- 1 do
		begin
			if Not ClusterGood(k) then
			begin
				ts:=LongInt2HexaStr(k);
				write('$'+ts+',');
				inc( NumeroDeClustersMalos );
			end;
		end;
		writeln;
		writeln(' Total de cluster malos: ', NumeroDeClustersMalos);
		FreeMem( Basura, SectorsPerAllocationUnit* BytesPerSector );

		readln;

	end; { fin del with }
	readln;
end.


