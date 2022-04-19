program ventanar;
uses
	{$I xObjects}, horrores, {$I xCRT}, Params
	{$IFDEF WINDOWS}
	,Strings
	{$ENDIF};

var
	fin, fout: TBufStream;

var
	TamDato: integer;
	N1, NDats: LongInt;
	ModoAppend: boolean;


procedure help;
begin
		ClrScr;
		writeln('VentanaR..........................rch93');
		writeln;
		writeln(' Sint xis:');
		writeln;
		writeln(' ventanar Fuente N1 NMuestras Destino [/tdnn] [/append]');
		writeln;
		writeln(' 	Donde (Fuente) es un archivo de datos del c£al,');
		writeln(' se leer n (NMuestras) Datos comenzando en el dato (N1).');
		writeln(' Los Datos le¡dos se escribir n en el archivo Destino');
		writeln(' 	El par metro (/tdnn) es opcional e indica el tama¤o');
		writeln(' en bytes de un dato. Si se omite, se supondra que los datos');
		writeln(' son del tipo "extended" (10 bytes)');
		writeln(' 	Si se incluye el par metro [/append], los datos se agregan');
		writeln(' al final del arhivo (destino). Si el (destino) no existe, es');
		writeln(' creado.');
		writeln;
		writeln('   Ej1: ');
		writeln('      ventanar arch1.dat 1 10 arch2.dat');
		writeln(' Se crear  el archivo arch2.dat con los primeros 10 datos ');
		writeln(' del archivo arch1.dat. ');
		writeln;
		writeln('   Ej2: ');
		writeln('      ventanar arch1.dat 100 3 arch2.dat /td6 /append');
		halt(1);
end;

procedure AbrirCrearArchivos;
label
	lb_AppendOk;
var
	ts:{$IFDEF WINDOWS} array[0..50] of char {$ELSE} string[50] {$ENDIF};

begin
  {$IFDEF WINDOWS}
	StrPCopy( ts, ParamStr(1));
	{$ELSE}
	ts:= ParamStr(1);
  {$ENDIF}
	fin.Init(ts, stOpenRead, 1024* 10);
	if fin.status <> stOk then error(' Abriendo archivo: '+ts);
	if (N1<0)or((N1-1+NDats)*TamDato>fin.GetSize) then
		error('Ventana fuera del archivo');
  fin.Seek((N1-1)* TamDato);
	if fin.status <> stOk then error(' Posicionando primer DATO');


	{$IFDEF WINDOWS}
	StrPCopy( ts, ParamStr(4));
	{$ELSE}
	ts:= ParamStr(4);
	{$ENDIF}
	if ModoAppend then
	begin { Intentamos Append }
		fout.Init(ts, stOpenWrite, 1024*10);
		if fout.status = stOk then
		begin
			fout.Seek(fout.GetSize);
			if fout.status <> stOk then
				error(' posicionando el final del archivo');
			goto lb_AppendOk;
		end
		else fout.reset;
	end;

	{ Creaci¢n de un nuevo archivo }
	fout.Init(ts, stCreate, 1024* 10);
	if fout.status <> stOk then error(' Creando archivo: '+ts);

lb_AppendOk:
end;


begin
	if (ParamCount< 2) or(ParamCount>5) then help;

	if Not ModifInteger('/td', TamDato) then TamDato:= SizeOf(extended);
	if IndiceParamModif('/append') > 0 then ModoAppend:= true
	else ModoAppend:= false;

	N1:= ParamLongInt(2);
	NDats:= ParamLongInt(3);

	AbrirCrearArchivos;
	fout.CopyFrom(fin, Ndats*TamDato);
	if fout.status <> stOk then error(' durante la transferencia de datos ');
	fout.done;
	fin.done;
end.