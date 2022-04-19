{$M 20000,0,20000}
program tir;

uses
	Math01, RunChild, xMatDefs;



function VANx( x: NReal): NReal; far;
var
	f: file of NReal;
	VANres: NReal;
	tt: string;
begin
	str(x:8:5, tt);
	rc( 'VAN '+ParamStr(1)+' '+tt+' tmp.sal');
	assign(f, 'tmp.sal');
	reset(f);
	read(f, VANres);
	close(f);
	VANx:= VANres;
end;

	
var
	x0, x1, xtol: NReal;
	VAN0, VAN1: NReal;
	Root, FAtRoot: NReal;
	NoOfIts: word;
	res: boolean;


begin
	if paramCount<> 1 then
	begin
		writeln('TIR, (c) rch94');
		writeln('sintaxis: ');
		writeln('    TIR ingresos');
		writeln;
		writeln(' (ingresos) es un archivo con los ingresos ');
		halt(1);
	end;
	x0:=0;
	x1:=100;
  xtol:=1e-5;
	Dicot(
		VANx,
		x0,x1,xtol,
		1000,
		Root,fAtRoot,
		NoOfIts,
		res);
	writeln(' TIR: ', Root:8:5);
	writeln(' VAN_TIR: ', fAtRoot: 12:2);
end.

