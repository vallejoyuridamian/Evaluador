program CataNorm;

uses
	HCopy02, traxp, Printer;

type
	LVR = array[0..10920] of real;
	LVRPtr = ^LVR;

var
	f:file;
	k,N:word;
	pv: LVRPtr;
	z:string;
	sigma2:real;
	p0:real;

begin
	assign(f,ParamStr(1));
	reset(f,SizeOf(Real));
	N:=FileSize(f);
	GetMem(pv, N*SizeOf(real));

	BlockRead(f,pv^,N);
	Close(f);

	p0:= pv^[1];
	writeln(' Potencia de continua: ',p0);
	sigma2:= 0;
	pv^[1]:=0;
	for k:= 2 to N do sigma2:=sigma2 + pv^[k];
	writeln(' Sigma2 = ',sigma2);
	writeln;
	writeln(' Presione una ENTER para continuar');
	readln;
	for k:= 1 to N do pv^[k]:=pv^[k]*k/sigma2;



	InicieGr;
	Tinicial:= 0;
	Tfinal:= N;
	subplot(1,1);
	PlotRealVect(0,N,pv^);
	linea0;
	str(N,z);
	z:= z+' Cantidad de muestras';
	xlabel(z);
{
	HardCopy(lst);

	}
	readln;
	TermineGr;
end.

