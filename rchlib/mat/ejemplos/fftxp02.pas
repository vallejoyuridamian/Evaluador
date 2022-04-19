{+doc
+NOMBRE: fftexp02
+CREACION:
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:test rfftb01
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

program fftxp02;
uses
	xMatDefs,
 RFFTF01,RFFTI01,RFFTB01,
 {$I xtraxp};

const
	NData = 200;
var
	AutoCorrel, autoSpect:array[1..2*NData] of NReal;
	datos,autocorr:array[1..NData] of NReal;
	a,b:array[1..NData div 2] of NReal;
	F,a0:NReal;


procedure AutoCorrelacion(n:integer; var dat);
type
	VR = array[1..6000]of NReal;
var
	pd,pa,pb:^VR;
	a0:NReal;
	k:integer;
begin
	GetMem(pd,n*2*sizeOf(NReal));
	GetMem(pa,n*sizeOf(NReal));
	GetMem(pb,n*SizeOf(NReal));
	a0:=0;
	for k:= 1 to n do
	begin
		a0:=a0+VR(dat)[k]
	end;
	a0:=a0/n;

	for k:= 1 to n do
	begin
		pd^[k]:=VR(dat)[k]-a0;
		pd^[k+n]:=0;
	end;
	RFFTI01.Init(2*n);
	FFTF(pd^,a0,pa^,pb^);
	a0:=a0*a0;
	for k:= 1 to n do
	begin
		pa^[k]:=(sqr(pa^[k])+sqr(pb^[k]))/2;
		pb^[k]:=0;
	end;
	pa^[n]:=2*pa^[n];
	FFTB(pd^,a0,pa^,pb^);
	RFFTI01.done;
	for k:=1 to n do
		VR(dat)[k]:=pd^[k];
	FreeMem(pb,n*SizeOf(NReal));
	FreeMem(pa,n*SizeOf(NReal));
	FreeMem(pd,n*2*sizeOf(NReal));
end;

function sign(x:NReal):integer;
begin
	if x>0 then sign:=1
	else sign:=-1
end;

function Runge(x:NReal):NReal;
begin
	Runge:=5*x*(x+1)*(x-1)*(X-0.5)*(x+0.5){1/(1+25*sqr(x))}
end;


procedure GenData;
var
	k:integer;
	delx:NReal;
	x0:NReal;
begin
	x0:=-1;
	delx:=2/ndata;
	for k:= 1 to NData do
			datos[k]:=runge(delx*(k-1)-1);
{	f:= 2* pi/(NData*delx);
	for k:= 1 to (Ndata div 2) do
	begin
		c[k]:=cos(k*F*x0);
		s[k]:=sin(k*F*x0)
	end}
end;

{
function Interpolant(var x:NReal):NReal;
var
	tn:NReal;
	j:integer;
begin
 tn:= a0;
 for j:= 1 to (NData div 2 ) do
	tn:= tn + DFTA[j]*cos(j*F*x)+DFTB[j]*sin(j*F*x);
 interpolant:=tn
end;
	}

procedure grafique;
var
	K:integer;
	m,am:NReal;
	delx,x:NReal;

begin
	InicieGr;
	subplot(2,2);
	plotRealVect(0,Ndata,Datos);
	Linea0;
	grid;
	titulo('muetra de datos');
	plotRealVect(3,Ndata,autocorr);
	titulo('autocorrelacion');
	linea0;
	grid;
	plotRealVect(1,Ndata div 2, A);
	titulo('espectro de potencia');
	linea0;
	grid;
	PlotRealVect(2,Ndata div 2 , b);
	readln;
end;
var k:integer;
begin
	randomize;
	GenData;
	Init(NData);
	FFTF(datos,a0,a,b);
	{
	for k:= 1 to (Ndata div 2) do
	begin
		DFTA[k]:= a[k]*c[k]-b[k]*s[k];
		DFTB[k]:= a[k]*s[k]+b[k]*c[k];
	end;

	writeln('=======================================');
	writeln('N: ',nData,'Azero: ',a0);
	for k:= 1 to (Ndata div 2 ) do
		writeln(ndata:4,DFTa[k]:18:-6, DFTb[k]:18:-6);
		}

	autocorr:=datos;
	autocorrelacion(NData,autocorr);
	Done;
	grafique;
end.
