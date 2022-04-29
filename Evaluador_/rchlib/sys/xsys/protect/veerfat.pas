{$A-}
program veerfat; { RCH 8jun93 }

uses
	CRT, AbsDsk, Int2Hexa, DirEntry;

const
	drv = CDRV_A;
type
	TiposDeFats = ( _12bits, _16bits );
	TTablaDeDirectorio = array[1..1000] of DirectoryEntryType;
	ptabladedirectorio =^TTablaDeDirectorio;
var

	ts: string;
	TipoDeFat: TiposDeFats;
	pRootDir: ptabladedirectorio;
	ultima: boolean;
	m: word;


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
	NumeroDeDistintos: LongInt;
	tam: integer;
	OffsetOfDataSector: LongInt;



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

procedure printbuff;
var
	k: integer;
	c: char;
begin
	for k:= 0 to sizeof(buff)-1 do
	begin
		c:= upcase( Buff[k] );
		case c of
		'a'..'z': write(c);
		'A'..'Z': write(c);
		else write('_');
		end;
	end;
	readln;
end;



begin
	res:=AbsoluteDiskRead(	Drv, Buff, 1, 0);
	PrintBuff;
	if res <> 0 then
	begin
		writeln(' Error leyendo el sector 0 ');
		halt(1);
	end;
	ComputeOffsetOfDataSector;
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
		GetMem( pFat1, NumberOfSectorsPerFat * BytesPerSector );
		res := AbsoluteDiskRead(	Drv, pFat1^, NumberOfSectorsPerFat, ReservedSectors);
		if res <> 0 then
		begin
			writeln(' ERROR: leyendo FAT1 ');
			halt(1);
		end;

		if NumberOfFats > 1 then
		begin
			writeln(' reading Fat2 ');
			 GetMem( pFat2, NumberOfSectorsPerFat * BytesPerSector );
			 res := AbsoluteDiskRead(	Drv, pFat2^, NumberOfSectorsPerFat, ReservedSectors+NumberOfSectorsPerFat);
			 if res <> 0 then
			 begin
				 writeln(' ERROR: leyendo FAT1 ');
				 halt(1);
			 end;

			 writeln('--- coparando las Fats -----');
			 NumeroDeDIstintos:= 0;
			 for k:= 0 to NumberOfSectorsPerFat * BytesPerSector  - 1 do
			 begin
					if pFat1^[k]<> pFat2^[k] then
					begin
						inc( NumeroDeDistintos );
						writeln(' diferencia en byte con offset: ',k);
					end;
			 end;
			 writeln(' N£mero de discrepancias: ',NumeroDeDistintos );
			 writeln('-- fin de la comparaci¢n ---');

		end;

		writeln('-----');
		write(' Tipo de Fat: ');
		if  NumberOfSectorsInLogicalImage > 4085 then
		begin
			TipoDeFat:= _16bits;
			writeln( '16bits');
			readln;
			writeln(' FAT: < CLUSTERs >');

			for k:= 0 to (NumberOfSectorsInLogicalImage - OffsetOfDataSector) div SectorsPerAllocationUnit +1 do
			begin
				m:=GetVal16bitsFat( pFat1^, k);
				case m of
					$000: write('0000>');
					$FF7: write('_BAD>');
					$FF8, $FFF: write('_EOF>');
					else
					begin
						ts:=LongInt2HexaStr(m);
						while length(ts)<4 do ts:='0'+ts;
						write(ts,'>');
					end
				end; {case}
			end;
			readln;

		end
		else
		begin
			TipoDeFat:= _12bits;
			writeln( '12bits');
			readln;
			writeln(' FAT: < CLUSTERs >');
			for k:= 0 to (NumberOfSectorsInLogicalImage - OffsetOfDataSector) div SectorsPerAllocationUnit +1 do
			begin
				m:=GetVal12bitsFat( pFat1^, k);
				case m of
					$000: write('<000>');
					$FF7: write('<BAD>');
					$FF8, $FFF: write('<EOF>');
					else
					begin
						ts:=LongInt2HexaStr(m);
						while length(ts)<3 do ts:='0'+ts;
						write('<',ts,'>');
					end
				end; {case}
			end;
			readln;
		end;

		readln;
		writeln(' Leyendo el directorio ra¡z ');
		tam:=SizeOf(DirectoryEntryType)*NumberOfRootsDirEntries;
		getmem(prootdir, SizeOf(tam));
		res := AbsoluteDiskRead(
				Drv, pRootDir^, tam div BytesPerSector,
				ReservedSectors+NumberOfSectorsPerFat*NumberOfFats);
		if res <> 0 then
		begin
			writeln(' ERROR: leyendo directorio ra¡z ');
			halt(1);
		end;


		ultima := false;
		for k:= 1 to NumberOfRootsDirEntries do
		begin
			if not ultima then
			begin
				WriteFileInfo( pRootDir^[k] , ultima);
				writeln;
			end;
		end;



	end; { fin del with }
	readln;
end.


