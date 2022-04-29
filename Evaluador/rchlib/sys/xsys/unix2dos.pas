program unix2dos;

uses
		Objects, PARAMS;
label
		 fin;
const
	ALFANUMERICO= ['!'..'~',#9,#10,#13,' '];


var
	 ent, sal: TBufStream;
	 N, k: longint;
	 c: char;

	 param: string;
	 ConvertirTabs, FiltrarAlfa: boolean;
	 u2d: boolean;
		anchotab: integer;
		res: integer;


procedure error( s: string );
begin
	writeln;
	writeln('ERR: ');
	writeln(s);
	halt;
end;


procedure Help;
begin
	writeln;
	writeln('UNIX2DOS entrada salida [/tnn] [/f]');
	writeln;
	writeln(' /tnn sustituye los tabuladores por nn blancos');
	writeln(' /f  elimina lo que no es ALFANUMERICO');
	halt;
end;

procedure writeChar(var sal: TStream; c: char);
begin
	if FiltrarAlfa then
		if not( c in ALFANUMERICO) then
		begin
			write('/',ord(c));
			c:=' ';
		end;


	if ConvertirTabs then
		if c=#9 then
		begin
			write('/t');
			c:= ' ';
			for k:= 1 to AnchoTab do
				sal.write( c, 1 );
		end
		else
			sal.write(c, 1);
end;


begin
	if ParamCount < 2 then
		Help;

	 ConvertirTabs:= ModifStr( '/t', param);

	 if ConvertirTabs then
	 if(length(param) > 0) then
	 begin
		val( param, AnchoTab, res );
		if res <> 0 then error('Convirtiendo AnchoTab: '+param);
	 end
	 else
		error('Si especifica /t, debe decir el ancho del TAB, /t3 para 3 por ej');

	 FiltrarAlfa:= ModifStr( '/f', param);


	 ent.init( ParamStr(1), stOpenRead, 1024*20 );
	 if ent.status <> stok then
	 begin
				ent.done;
				writeln('error abriendo: '+ParamStr(1));
				halt;
	 end;
	 N:= ent.GetSize;
	 sal.init( ParamStr(2), stCreate, 1024*20 );
	 if sal.status <> stok then
	 begin
				ent.done;
				sal.done;
				writeln('error creando: '+ParamStr(2));
				halt;
	 end;

	 u2d:= true;

	 for k:= 1 to N do
	 begin
			ent.read(c, 1);
			if u2d then
			begin
				 if c = #13 then
				 begin
					u2d:= false;
				 end
				 else
						if c = #10 then
						begin
								 c:= #13;
								 sal.write(c, 1);
								 c:=#10;
								 sal.write( c, 1 );
						end
						else
								writeChar(sal, c);
			end
			else
			 writeChar(sal, c);
	 end;


fin:
		 sal.done;
		 ent.done;
end.