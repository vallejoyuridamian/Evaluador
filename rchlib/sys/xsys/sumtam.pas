{$F+}
program SumTam;

type



	nameType = string[72];

	fichaArchivo = record
		nombre:string[8];
		ext:string[3];
		path:word;
		tam:LongInt;
		fecha:string[8];
	end;

	fichaPath = record
		dsk:string[3]; {identificador del disco}
		nombre:nameType; {camino dentro del disco}
	end;

var
	fa:fichaArchivo;
	fin:file of fichaArchivo;
	TamTot:LongInt;

begin
	TamTot:=0;
	assign(fin,'dic91.ndx');
	reset(fin);
	while not eof(fin) do
	begin
		read(fin,fa);
		if fa.ext='tpu' then Inc(TamTot,fa.tam);
	end;
	close(fin);
	writeln('TamTot : ',TamTot);
end.
