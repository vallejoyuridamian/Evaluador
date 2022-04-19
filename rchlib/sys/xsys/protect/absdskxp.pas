program absdskxp;
uses
	absdsk;

var
	DInf: T_DskInfo;
	Buffer:array[0..511] of byte;
	sector:word;
	res:byte;
	k:integer;

begin
	GetDefaultDriveData(Dinf);
	Writeln;
	writeln(' Datos del drive por defecto:');
	writeln('+++++++++++++++++++++++++++++');
	writeln('FatID: ',dinf.FatId);
	writeln('N£mero de sectores por cluster: ',dinf.SectoresPorCluster);
	writeln(' N£mero de bytes por sector: ',dinf.BytesPorSector);
	writeln('N£mero total de clusters: ',dinf.NumeroDeClusters);
	writeln;
	readln;
	writeln('Coloque un disco en el drive (A) y presione ENTER');
	readln;
	GetDriveData(1,Dinf);
	Writeln;
	writeln(' Datos del drive (A) :');
	writeln('++++++++++++++++++++++');
	writeln('FatID: ',dinf.FatId);
	writeln('N£mero de sectores por cluster: ',dinf.SectoresPorCluster);
	writeln(' N£mero de bytes por sector: ',dinf.BytesPorSector);
	writeln('N£mero total de clusters: ',dinf.NumeroDeClusters);
	writeln;
	readln;

	writeln(' Realizaremos ahora lecturas(absolutas) de Clusters del drive(A)');
	sector:=0;
	while (sector>=0)and(Sector<dinf.NumeroDeClusters) do
	begin
		write(' Qu‚ sector ?:');readln(sector);
		res:= AbsoluteDiskRead(
						0{Drv=A},
						Buffer,
						1{Leer un sector},
						sector{sector a leer});
		writeln('Resultado de la operaci¢n: ',res);
		for k:= 0 to 511 do
			write(chr(buffer[k]));
	end;
end.

