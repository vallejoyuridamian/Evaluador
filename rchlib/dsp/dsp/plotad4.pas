{rch92}
program plotad4;
uses
	xMatDefs,Graph, Traxp, CRT;
const
	LIMARR = 45000;
type

	LVR = array[0..LimARR] of byte;
	LVRPtr = ^LVR;

var
	f:file;
	N,desp:word;
	pv: LVRPtr;
	z:string;
	MaxN:word;
	NP, res:integer;
	fin: boolean;
	c:char;

procedure Dibujar;
begin
	ClearDevice;
	Seek(f,desp );
	BlockRead(f, pv^, N);
	Tinicial:= 0;
	Tfinal:= N;
	subplot(1,1);
	PlotAD4Vect(0,N*2,pv^);
	titulo(ParamStr(1));
	linea0;
	str(N,z);
	z:= z+' Cantidad de muestras';
	xlabel(z);
end;

begin
	desp:=0;

	assign(f,ParamStr(1));

	reset(f,1);
	N:=FileSize(f);
	
	if N> LIMArr then N:= LimArr+1;
	MaxN:=N;
	if ParamCount > 1 then
	begin
		Val(ParamStr(2), NP, res);
		if res <> 0 then
		begin
			writeln(' Error de conversi�n de PARAMETRO 2 a entero');
			halt(1);
		end;
		if N>NP then N:=NP;
	end;

	if ParamCount > 2 then
	begin
		Val(ParamStr(3), NP, res);
		if res <> 0 then
		begin
			writeln(' Error de conversi�n de PARAMETRO 3 a entero');
			halt(1);
		end;
		gridX:=NP;
	end;

	if ParamCount > 3 then
	begin
		Val(ParamStr(4), NP, res);
		if res <> 0 then
		begin
			writeln(' Error de conversi�n de PARAMETRO 3 a entero');
			halt(1);
		end;
		Desp:=NP;
	end;

	GetMem(pv, N);
	fin:= false;
	InicieGr;

	while Not Fin do
	begin
		Dibujar;
		c:= ReadKey;
		case c of
		'Q':Fin:= true;
		'd': if(N+desp)< MaxN then inc(desp);
		'D': if(2*N+desp)<=MaxN then inc(desp,N);
		'a': if desp>0 then dec(desp);
		'A': if(desp >=N) then dec(desp,N);
		'l': if (N+desp+1)<MaxN then
					begin
						FreeMem(pv, N);
						inc(N);
						GetMem(pv, N);
					end
				else
					if (N+1)<MaxN then
					begin
						dec(desp);
						FreeMem(pv, N);
						inc(N);
						GetMem(pv, N);
					end;
			'L': if (N+desp+N)<MaxN then
					begin
						FreeMem(pv, N);
						inc(N,N);
						GetMem(pv, N);
					end
				else
					if (N+N)<MaxN then
					begin
						dec(desp);
						FreeMem(pv, N);
						inc(N,N);
						GetMem(pv, N);
					end;
		'k': if N>0 then
					begin
						FreeMem(pv, N);
						dec(N);
						GetMem(pv, N);
					end;

		'K': if N>0 then
					begin
						FreeMem(pv, N);
						N:= N div 2;
						GetMem(pv, N);
					end;

		'h': HoldOn(0);
		'H': HoldOff(0);
		end;
	end;

	TermineGr;
end.