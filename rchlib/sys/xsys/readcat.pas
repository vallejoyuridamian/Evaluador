program readcat;

type
	fichaArchivo = record
		nombre:string[8];
		ext:string[3];
		path:word;
		tam:LongInt;
		fecha:string[8];
	end;

	fichaPath = record
		dsk:string[3]; {identificador del disco}
		nombre:string[72]; {camino dentro del disco}
	end;




label nada;
var
	dsk:string[3];
	path:string[72];
	r:string;
	fin:text;
	foutn:file of fichaArchivo;
	foutp:file of fichaPath;
	f:fichaArchivo;
	pf:fichaPath;
	PathCount:word;
	ts:string;
	k,res:integer;


begin
	assign(fin,'dic91.cat');
	reset(fin);
	assign(foutn,'dic91.ndx');
	assign(foutp,'dic91.pdx');
	rewrite(foutn);
	rewrite(foutp);
	pathCount:=0;
	while not eof(fin) do
	begin
		readln(fin,r);
		if length(r)<3 then goto nada;
		if pos('files found ',r)>0 then goto nada;
		if length(r)<5 then dsk:=copy(r,1,3)
		else
			if pos('Directory of ',r)<> 0 then
			begin
				delete(r,1,pos('Directory of ',r)+length('Directory of ')-1);
				path:=r;
				pf.dsk:=dsk;
				pf.nombre:=path;
				inc(pathCount);
				write(foutp,pf);
			end
			else
				if pos('<DIR>',r)>0 then {nada, es una entrada de dir}
				else
				begin
					f.nombre:=copy(r,1,8);
					f.ext:=copy(r,10,3);
					ts:=copy(r,15,9);
					k:=pos(',',ts);
					if k>0 then delete(ts,k,1);
					val(ts,f.tam,res);
					if res<>0 then
					begin
						writeln('Error de conversion numerico');
						halt(1)
					end;
					f.fecha:=copy(r,27,8);
					f.path:=PathCount;
					write(foutn,f);
				end;
	nada:
	end;
	close(foutn);
	close(foutp);
end.
