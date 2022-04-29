{+doc
+NOMBRE: CHECKLIM
+CREACION: 9/97
+MODIFICACION:
+AUTORES: MARIO VIGNOLO
+REGISTRO:
+TIPO: Unidad Pascal
+PROPOSITO: Verificaci¢n de los l¡mites de tensi¢n, corriente y potencia.
+PROYECTO: FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}


unit checklim;

interface

uses
  xMatDefs, AlgebraC,Barrs2,impds1,trafos1,regulado,cuadri1,tyvs2;


procedure  checkbarrs(var f:text);
procedure  checkimpds(var f:text);
procedure  checkcuadri(var f:text);
procedure  checktrafos(var f:text);
procedure  checkreg(var f:text);


implementation

procedure  checkbarrs(var f:text);

var
	k: integer;
	res: boolean;

begin
		res:=false;
		for k:=1 to NBarrasdecarga do
		begin
			if TBarra(BarrasdeCarga[k-1]).limitemin='S' then
			begin
				if mod1(TBarra(BarrasdeCarga[k-1]).V) <
				TBarra(BarrasdeCarga[k-1]).Rmin then
				begin
				res:=true;
				writeln(f,'La tensi¢n en el nodo ',
				TBarra(BarrasdeCarga[k-1]).Nombre,
				' est  por debajo del l¡mite inferior establecido.');
				end;
			end;
			if TBarra(BarrasdeCarga[k-1]).limitemax='S' then
			begin
				if mod1(TBarra(BarrasdeCarga[k-1]).V) >
				TBarra(BarrasdeCarga[k-1]).Rmax then
				begin
				res:=true;
				writeln(f,'La tensi¢n en el nodo ',
				TBarra(BarrasdeCarga[k-1]).Nombre,
				' est  por encima del l¡mite superior establecido.');
				end;
			end;
		end;
		for k:=1 to NBarrasdeGenyVcont do
		with TBarra(BarrasdeCarga[k-1]) do
		begin
			if limitemin='S' then
			begin
				if S.i < Rmin then
				begin
				res:=true;
				writeln(f,'La potencia reactiva en el nodo ',Nombre,
				' est  por debajo del l¡mite inferior establecido.');
				end;
			end;
			if limitemax='S' then
			begin
				if S.i > Rmax then
				begin
				res:=true;
				writeln(f,'La potencia reactiva en el nodo ',
				TBarra(BarrasdeCarga[k-1]).Nombre,
				' est  por encima del l¡mite superior establecido.');
				end;
			end;
		end;
		if res=false then
		writeln(f, 'No hubo violaciones de l¡mites en las barras.');
		writeln(f);
end;


procedure  checkimpds(var f:text);

var
	k: integer;
	res: boolean;
	S12,S21,Scon,I: NComplex;

begin
	res:=false;
	for k:=1 to NImpedancias do
	with TImpedancia(Impedancias[k-1]) do
	begin
		if Imax<>0 then
		begin
			TransfS(S12,S21,Scon,I);
			if mod1(I)>Imax then
			begin
				res:=true;
				writeln(f,'La corriente por la impedancia ',
				Nombre,' est  por encima del m ximo admisible.');
			end;
		end;
	end;
	if res=false then
	writeln(f,'No hubo violaciones de l¡mites en las impedancias.');
	writeln(f);
end;


procedure  checkcuadri(var f:text);

var
	k: integer;
	res: boolean;
	S12,S21,Scon,I: NComplex;

begin
	res:=false;
	for k:=1 to NCuadripolosPi do
	with TCuadripoloPi(Cuadripolos[k-1]) do
	begin
		if Imax<>0 then
		begin
			TransfS(S12,S21,Scon,I);
			if mod1(I)>Imax then
			begin
				res:=true;
				writeln(f,'La corriente por el cuadripolo ',
				Nombre,' est  por encima del m ximo admisible.');
			end;
		end;
	end;
	if res=false then
	writeln(f,'No hubo violaciones de l¡mites en los cuadripolos.');
	writeln(f);
end;



procedure  checktrafos(var f:text);

var
	k: integer;
	res: boolean;
	S12,S21,Scon,I: NComplex;

begin
	res:=false;
	for k:=1 to NTrafos do
	with TTrafo(Trafos[k-1]) do
	begin
		if Imax<>0 then
		begin
			TransfS(S12,S21,Scon,I);
			if mod1(I)>Imax then
			begin
				res:=true;
				writeln(f,'La corriente por el transformador ',
				Nombre,' est  por encima del m ximo admisible.');
			end;
		end;
	end;
	if res=false then
	writeln(f,'No hubo violaciones de l¡mites en los transformadores.');
	writeln(f);
end;

procedure  checkreg(var f:text);

var
	k: integer;
	res: boolean;
	S12,S21,Scon,I: NComplex;

begin
	res:=false;
	for k:=1 to NReguladores do
	with TRegulador(Reguladores[k-1]) do
	begin
		if Imax<>0 then
		begin
			TransfS(S12,S21,Scon,I);
			if mod1(I)>Imax then
			begin
				res:=true;
				writeln(f,'La corriente por el regulador ',
				Nombre,' est  por encima del m ximo admisible.');
			end;
		end;
		if n<nmin then  writeln(f,'La relaci¢n en el regulador ',
				Nombre,' est  por debajo del m¡nimo admisible.');
		if n>nmax then  writeln(f,'La relaci¢n en el regulador ',
				Nombre,' est  por encima del m ximo admisible.');

	end;
	if res=false then
	writeln(f,'No hubo violaciones de l¡mites en los reguladores.');
	writeln(f);
end;


end.
