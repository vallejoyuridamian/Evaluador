{+doc
+NOMBRE:  SALIDA
+CREACION:
+MODIFICACION:  8/97
+AUTORES:  MARIO VIGNOLO
+REGISTRO:
+TIPO:  Unidad Pascal
+PROPOSITO:  Procedimientos para mostrar resultados
+PROYECTO: FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:

-doc}

unit salida;

interface
uses
  classes,
	Horrores, Lexemas32,
  AlgebraC, xMatDefs,
	Barrs2, Impds1, Cuadri1, Trafos1, Regulado, TYVS2, Links, TDefs0,
  MAtCPX;

procedure WriteBarras(var f:text; Barras:TList);
procedure WriteFlujosDePotencia(var f:text);

implementation

procedure WriteBarras(var f:text;Barras:TList);
var
	k: integer;
	TSG, TSC: NComplex;
begin
	TSG:= numc(0,0)^;
	TSC:= numc(0,0)^;

	for k:= 1 to NBARRAS do
	begin
		TBarra(Barras[k-1]).WriteTXT(f);
		if TBarra(Barras[k-1]).S.r>0 then
		TSG.r:=TSG.r+TBarra(Barras[k-1]).S.r
		else TSC.r:=TSC.r-TBarra(Barras[k-1]).S.r;
		if TBarra(Barras[k-1]).S.i>0 then
		TSG.i:=TSG.i+TBarra(Barras[k-1]).S.i
		else TSC.i:=TSC.i-TBarra(Barras[k-1]).S.i;
		writeln(f);
	end;
	write(f,' TSGeneracion: ');wtxtcln(f,TSG,CA_Rectangulares);
	write(f,' TSConsumo:    ');wtxtcln(f,TSC,CA_Rectangulares);
end;

procedure WriteFlujosDePotencia(var f:text);
var
	k: integer;
	Perdidas,Perdidasimp,Perdidascuad,Perdidastrafo,
	Perdidasregulador, Perdidastot: NReal;
	S,S1,S12,S2,S21,Scon,I: NComplex;
begin
	writeln(f);
	writeln(f,' POTENCIAS ENTREGADAS A LAS IMPEDANCIAS ');
	Perdidas:=0;
	for k:= 1 to NImpedancias do
  with TImpedancia(Impedancias[k-1]) do
	begin
		TransfS(S12,S21,Scon,I);
		if (nodo1<>0) and (nodo2<>0) then
		begin
			write(f,TBarra(BarrasOrdenadas[Nodo1-1]).Nombre,'->',Nombre,' ');
			wtxtcln(f,S12,CA_Rectangulares);
			write(f,TBarra(BarrasOrdenadas[Nodo2-1]).Nombre,'->',Nombre,' ');
			wtxtcln(f,S21,CA_Rectangulares);
			writeln(f);
		end
		else
		begin
			if nodo1=0 then
			begin
				write(f,'N ','->',Nombre,' ');
				wtxtcln(f,S12,CA_Rectangulares);
				write(f,TBarra(BarrasOrdenadas[Nodo2-1]).Nombre,'->',Nombre,' ');
				wtxtcln(f,S21,CA_Rectangulares);
				writeln(f);
			end
			else
			begin
				write(f,TBarra(BarrasOrdenadas[Nodo1-1]).Nombre,'->',Nombre,' ');
				wtxtcln(f,S12,CA_Rectangulares);
				write(f,'N ','->',Nombre,' ');
				wtxtcln(f,S21,CA_Rectangulares);
				writeln(f);
			end;
		end;
	Perdidas:=Perdidas+Scon.r;
	end; {with}
	Perdidasimp:=Perdidas;
	writeln(f,'Perdidas Joule en las impedancias: ',Perdidasimp:10:7);
	writeln(f);

	writeln(f,' POTENCIAS ENTREGADAS A LOS CUADRIPOLOS ');
	Perdidas:=0;
	for k:= 1 to NCuadripolosPi do
  with TCuadripoloPi(Cuadripolos[k-1]) do
	begin
		TransfS(S12,S21,Scon,I);
		write(f,TBarra(BarrasOrdenadas[Nodo1-1]).Nombre,'->',Nombre,' ');
		wtxtcln(f,S12,CA_Rectangulares);
		write(f,TBarra(BarrasOrdenadas[Nodo2-1]).Nombre,'->',Nombre,' ');
		wtxtcln(f,S21,CA_Rectangulares);
		writeln(f);
		Perdidas:=Perdidas+Scon.r;
	 end; {with}
	 Perdidascuad:=Perdidas;
	writeln(f,'Perdidas Joule en los cuadripolos: ',Perdidascuad:10:7);
	writeln(f);

	writeln(f,' POTENCIAS ENTREGADAS A LOS TRANSFORMADORES ');
	Perdidas:=0;
	for k:= 1 to NTrafos do
  with TTrafo(Trafos[k-1]) do
	begin
		TransfS(S12,S21,Scon,I);
		write(f,TBarra(BarrasOrdenadas[Nodo1-1]).Nombre,'->',Nombre,' ');
		wtxtcln(f,S12,CA_Rectangulares);
		write(f,TBarra(BarrasOrdenadas[Nodo2-1]).Nombre,'->',Nombre,' ');
		wtxtcln(f,S21,CA_Rectangulares);
		writeln(f);
		Perdidas:=Perdidas+Scon.r;
	 end; {with}
	 Perdidastrafo:=Perdidas;
	 Perdidastot:=Perdidasimp+Perdidascuad+Perdidastrafo;
	writeln(f,'Perdidas Joule en los transformadores: ',Perdidastrafo:10:7);
	writeln(f);

	writeln(f,' REGULADORES ');
	Perdidas:=0;
	for k:= 1 to NReguladores do
  with TRegulador(Reguladores[k-1]) do
	begin
		writeln(f,'Relaci¢n de transformaci¢n del regulador ',Nombre,': ',n:7:3);
		TransfS(S12,S21,Scon,I);
		write(f,TBarra(BarrasOrdenadas[Nodo1-1]).Nombre,'->',Nombre,' ');
		wtxtcln(f,S12,CA_Rectangulares);
		write(f,TBarra(BarrasOrdenadas[Nodo2-1]).Nombre,'->',Nombre,' ');
		wtxtcln(f,S21,CA_Rectangulares);
		writeln(f);
		Perdidas:=Perdidas+Scon.r;
	 end; {with}
	 Perdidasregulador:=Perdidas;
	 Perdidastot:=Perdidasimp+Perdidascuad+Perdidastrafo+Perdidasregulador;
	writeln(f,'Perdidas Joule en los reguladores: ',Perdidasregulador:10:7);
	writeln(f);
	writeln(f,'Perdidas Joule totales en las l¡neas: ',Perdidastot:10:7);


end;

end.