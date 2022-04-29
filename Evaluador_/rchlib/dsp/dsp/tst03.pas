program tst02;
{ test de adquidef }
uses
	adquidef,traxp,
	RFFTF01,RFFTI01;


type

	filt01 = object
		s:real;
		procedure Init(x:real);
		procedure Ent(x:real);
		function Sal:real;
		function EntSal(x:real):real;
	end;

	filt02 = object
		m1,s:real;
		procedure Init(x:real);
		procedure Ent(x:real);
		function Sal:real;
		function EntSal(x:real):real;
	end;

procedure filt01.Init(x:real);
begin
	s:=x;
end;

procedure filt01.Ent(x:real);
begin
	s:=(s+x)/2;
end;

function filt01.Sal:real;
begin
	Sal:=s;
end;

function filt01.EntSal(x:real):real;
begin
	Ent(x);
	EntSal:=Sal
end;

procedure filt02.Init(x:real);
begin
	m1:=x;
end;

procedure filt02.Ent(x:real);
begin
	s:=x-m1;
	m1:=x
end;

function filt02.Sal:real;
begin
	Sal:=s
end;

function filt02.EntSal(x:real):real;
begin
	Ent(x);
	EntSal:=s
end;


var
	a:adqui;
	k:integer;
	TiempoTotalDesplegado,
	FrecuenciaTotalDesplegada,
	FrecuenciaBase:real;
	tmpstr:string;
	NData,Datk1,Datk2,FrecK1,FrecK2,rescode:integer;
	datos: array[1..600] of real;
	ac,bc:array[1..300] of real;
	pot2:array[0..300] of real;
	a0:real;

begin
	assign(Input,'');reset(Input);
	assign(Output,'');rewrite(Output);

	a.readFrom(ParamSTR(1));
	Val(ParamStr(2),DatK1,rescode);
	Val(ParamStr(3),DatK2,rescode);
	Val(ParamStr(4),Freck1,rescode);
	Val(ParamStr(5),Freck2,rescode);

	NData:=DatK2-Datk1+1;

	for k:= DatK1 to DatK2 do
		datos[k]:= (LVI(a.CURVE^)[k]-128)*a.YMULT;

	RFFTI01.Init(NData);
	FFTF(datos,a0,ac,bc);

	pot2[0]:= sqr(a0);
	for k:= 1 to NDATA div 2 do
		pot2[k]:=(sqr(ac[k])+sqr(bc[k]))/2;

	TiempoTotalDesplegado:=(DatK2-Datk1)*a.XINCR;
	FrecuenciaBase:=1/TiempoTotalDesplegado;
	FrecuenciaTotalDesplegada:=(Freck2-FrecK1)*FrecuenciaBase;


	InicieGR;
	subplot(2,1);
	activeCanal(0);
	titulo('v(t) adquirida');
	activeCanal(1);
	titulo('P(f) Espectro de Potencia');
	PlotRealVect(0,NDATA,datos[Datk1]);
	Str(TiempoTotalDesplegado/GridX:12:-4,tmpstr);
	tmpStr:=tmpStr+ ' '+a.XUNIT+' /DIV';
	xlabel(tmpstr);
	linea0;
	str(FrecuenciaTotalDesplegada/gridx:12:-4,tmpstr);
	tmpStr:=tmpStr+ ' '+a.XUNIT+'^-1 /DIV';
	PlotRealVect(1,Freck2-Freck1+1,pot2[Freck1]);
	xlabel(tmpstr);
	readln;
	TermineGr;
	Writeln('>>>>>>>>>>>=====');
	writeln('Archivo de datos: ', paramStr(1));
	writeln('Primer dato considerado: ',paramStr(2));
	writeln('Ultimo dato considerado: ',paramStr(3));
	writeln('------------');
	writeln('Frecuencia del primer arm¢nico : ',FrecuenciaBase);
	writeln('Contenido de potencia de las distintas arm¢nicas: ');

	for k:= 0 to (NData Div 2) do
	begin
		writeln(k:6,': ',pot2[k]);
	end;
end.