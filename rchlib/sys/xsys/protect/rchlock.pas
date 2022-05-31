{$A-}
program RCHLOCK;
uses
	CRT, AbsDsk, DIRENTRY;

const
	drv = CDRV_A;
type
	TBadBoyInfo = record
		Ident: string;
		NBads: integer; { < 100 }
		Bads: array[1..100] of word;
		CRC: LongInt;
	end;


type
	TiposDeFats = ( _12bits, _16bits );


var

	ts: string;
	LastCluster, BadClusterMark, EndOfFileMark: word;
	TipoDeFat: TiposDeFats;
	m: word;
	Basura: pointer;
	BadBoyInfo: TBadBoyInfo;


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
		if tam > (tam div BytesPerSector)*BytesPerSector then
			Inc(OffsetOfDataSector);
	end;
end;


procedure LeerBadBoyInfo;
var
	cluster: word;
	malos, buenos: integer;
	k:integer;
	res: byte;
	TCRC:LongINt;

begin
	malos:= 0;buenos:= 0;
	with TBootSector( pointer(@buff[0])^) do
	begin
		res:= AbsoluteDiskRead( DRV, Basura^,
			SectorsPerAllocationUnit, SectorsPerAllocationUnit + OffsetOfDataSector);
		if res <> 0 then
		begin
			writeln(' ERROR: intentando leer cluster 3');
			halt(1);
		end;
	end;
	BadBoyInfo:= TBadBoyInfo(Basura^);
	with BadBoyInfo do
	begin
		CLRSCR;
		writeln(Ident);
		writeln('------');
		writeln(' chequeando disco llave .... ');
		tCRC:= -14;
		for k:= 1 to length(ident) do tCRC:= tCRC+ byte(Ident[k]);


		for k:= 1 to NBads do
		if ClusterGood(Bads[k]) then inc(buenos)
		else inc(malos);
		if malos / NBads < 0.8 then
		begin
			delay(1000);
			writeln(' :::::::> disco falso');
			writeln(' ....     :::::: ::::: ...:. ::..::..::.:::..:');
			writeln(' Su sistema se ha modificado ///////////>rch93');
			sound(1200);
			while true do;
		end;
		if tCRC<> CRC then
		begin
			writeln('INFORMACION CORROMPIDA..');
			sound(1200);
			while true do;
		END;
	END;
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
			BadClusterMark:= $FFF7;{???}
			EndOfFileMark:= $FFF8;
		end
		else
		begin
			TipoDeFat:= _12bits;
			writeln( '12bits');
			BadClusterMark:= $FF7;
			EndOfFileMark:= $FF8;
		end;

		ComputeOffsetOfDataSector;
		LastCluster:= (NumberOfSectorsInLogicalImage - OffsetOfDataSector)
											div SectorsPerAllocationUnit +1;

		GetMem( Basura, SectorsPerAllocationUnit* BytesPerSector );


		writeln(' FAT: < CLUSTERs > testing');
		leerBadBoyInfo;
		writeln('VERIFICACION EXITOSA... ');
		FreeMem( Basura, SectorsPerAllocationUnit* BytesPerSector );
	end; { fin del with }
END.
end.


