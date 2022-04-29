{+doc
+NOMBRE: DireEntry
+CREACION: 30.8.92
+AUTORES:  rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Definici¢n del tipo (DirectoryEntryType)

+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit direntry;


interface
uses
	dos;


const
	DirectoryEntryHasNeverBeenUsed = $00;
	FirstCharOfFileNameIsAnE5Char = $05;
	EntryForADirecory = $2E;
	UsedButSinceBeenErased = $E5;

type

	 DirectoryEntryType = record
		FileName: array[1..8] of char;
		FileExt: array[1..3] of char;
		FileAttr: byte;
		RESERVED: array[$0C..$15] of byte;
		Time: word;
		Date: word;
		StartingCluster: word;
		FileSize: LongInt;
	 end;


procedure WriteFileInfo( var DE: DirectoryEntryType; var Ultima: boolean );



implementation

procedure WriteFileInfo( var DE: DirectoryEntryType; var Ultima: boolean );
var
	ts: string;
	k:integer;
begin
	Ultima:= false;
	With DE do
	begin
		ts:='';
		Case Ord(FileName[1]) of
			$00: begin
						write('nunca usada ');
						ultima:= true;
					end;
			$2E: write('directorio');
			$E5: write('recien borrado');
			else
			begin
				if FileName[1] = Char($05) then ts:= char($E5)
				else ts:= FileName[1];
				for k:= 2 to 8 do ts:= ts+FileName[k];
			end
		end; { case }
		ts:= ts+'.';
		for k:= 1 to 3 do ts:= ts+ FileExt[k];
		write(ts+'   ');

		ts:= '______';
		if FileAttr and 1 <> 0 then ts[1]:='R';
		if FileAttr and 2 <> 0 then ts[2]:='H';
		if FileAttr and 4 <> 0 then ts[3]:='S';
		if FileAttr and 8 <> 0 then ts[4]:='V';
		if FileAttr and $10 <> 0 then ts[5] :='D';
		if FileAttr and $20 <> 0 then ts[6] := 'A';
		write(ts+'   ');
{
		RESERVED: array[$0C..$15] of byte;

		Time: word;
		Date: word;
}
		write( ' 1cluster: ',StartingCluster );
{
		FileSize: LongInt;
}
	end { del with }
end;
end.