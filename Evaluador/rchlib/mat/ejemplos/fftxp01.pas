{+doc
+NOMBRE:
+CREACION:
+AUTORES:
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: test de RFFTI01 y RFFTF01
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

program fftxp01;
uses
 xMatDefs,
 RFFTI01, RFFTF01,
 {$I xtraxp};

const
	NData = 1000;
var
	datos:array[1..NData] of NReal;
	a,b:array[1..NData] of NReal;
	w1,w2:NReal;
	a0:NReal;

function sign(x:NReal):integer;
begin
	if x>0 then sign:=1
	else sign:=-1
end;

procedure GenData;
var
	k:integer;
begin
	randomize;
	for k:= 1 to NData do
			datos[k]:={ 6*(Random(1000)-500)/1000;} 6*sign(sin(w1*k))*sin(w2*k);
end;

procedure grafique;
var
	K:integer;
	m,am:NReal;

begin
	InicieGr;
	subplot(1,2);
	definaY(0,0,5);
	definaX(0,0,((NData +2)div 2)/10);
   XLabel('FFT');
	definaY(1,-80,20);
	definaX(1,1,NData/10);
	YLabel('Datos');
	m:=0;
	trazoXY(0,0,a0);
	for k:= 1 to ((Ndata+1) div 2)  do
	begin
  	{$IFDEF WINDOWS}
		TraxpW.t:=k
		{$ELSE}
		Traxp.t:= k
    {$ENDIF};

		am:=(sqr(a[k])+sqr(b[k]));
		if am> m then m:= am;
		trazo(0,am);
	end;
	for k:= 1 to Ndata do
	begin
		{$IFDEF WINDOWS}
		TraxpW
		{$ELSE}
		Traxp
		{$ENDIF}.t:=k;
		trazo(1,datos[k]);
	end;
	readln;
	readln;
end;
begin
	w1:= 2 * pi/NData*3;
	w2:= 2 * pi/NData*100.6;
	GenData;
	Init(NData);
	FFTF(datos,a0,a,b);
	Done;
	grafique;
end.
