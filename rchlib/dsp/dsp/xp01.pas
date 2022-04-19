program xp01;

uses
	xMatDefs,
	RFFTI01, RFFTF01,
	Graph, Traxp;

type
	TLAR = array[1..6000] of NReal;
	PLAR = ^TLAR;

const
	Armonica = 30;
	DatosVentana = 24*3;
	MediaVentana = DatosVentana  div 2;

var
	PESOS, Ventana: array[1..DatosVentana] of NReal; { un mes }
	an, bn: array[1..DatosVentana div 2] of NReal;

	f: file;
	pv: PLAR;
	NMed:LongInt;
	A0:NReal;
	Desp: LongInt;
	DespHasta: LongInt;


procedure CalcularPESOS;
var
	k:integer;
	kmed:NReal;
	w:NReal;
begin
	W:= 2* pi/DatosVentana;
	kmed:= (DatosVentana + 1)/2;
	for k:= 1 to DatosVentana do
		PESOS[k]:= 0.5*(1+cos( W * (k-kmed)));
end;

procedure CalcularVentana( Desplazamiento: LongInt );
var
	k:integer;
	tmp:NReal;
begin
	a0:= 0;
	for k:= 1 to DatosVentana do A0:= a0 + pv^[k+Desplazamiento];
	a0:= a0/DatosVentana;

	for k:= 1 to DatosVentana do
		Ventana[k]:=PESOS[k]*(pv^[Desplazamiento+k]-a0);

	FFTF( Ventana, tmp, an, bn );
	BorreCanal(5,0);
	borde;
	for k:= 1 to MediaVentana do
		Ventana[k]:= 0.5*(sqr(an[k])+sqr(bn[k]));
	PlotRealVect(5, MediaVentana, Ventana);


end;


procedure LeerValores;
begin
	assign(f, 'a:\vpdeleste.n79');
	reset(f, sizeOf(NReal));
	NMed:= FileSize(f);
	GetMem(pv, NMed* SizeOf(NReal));
	BlockRead(f, pv^, NMed);
	Close(f);
end;

procedure SacarValorMedio;
var
	k:LongInt;
begin
	A0:=0;
	for k:= 1 to NMed do
	begin
		A0:=A0+pv^[k]/NMed;
	end;

	for k:= 1 to NMed do
	begin
		pv^[k] := pv^[k] - A0;
	end;
end;


procedure Dibujar;
begin
	ClearDevice;
	Subplot(1,2);
	PlotRealVect(0,DatosVentana, pv^[Desp+1] );
	Linea0;
	grid;
	PlotRealVect(1,DatosVentana, Ventana[1] );
	Linea0;grid;
end;


begin
	RFFTI01.Init(DatosVentana);
	desp:= 0;
	LeerValores;
	DespHasta:= NMed- DatosVentana;
	CalcularPESOS;


	InicieGR;
	Traxp.tinicial:= 0;
	traxp.tfinal:= DespHasta;
	gridY:= 10;
	subplot(2,3);
	definay(0, 0, 20);
	linea0;grid;
	definay(1, 0, 20);
	Linea0;grid;
	definay(2, -10, 2);
	Linea0;grid;
	definay(3, -10, 2);
	Linea0;grid;
	definaX(4, -10, 2);
	definaY(4, -10, 2);
	Linea0;grid;

	desp:= 0;
	while desp <= DespHasta do
	begin
		CalcularVentana(desp);
		traxp.t:= desp;
		trazo( 0, pv^[ MediaVentana + desp] );
		trazo( 1, a0 );
		trazo( 2, an[armonica] );
		trazo( 3, bn[armonica] );
		trazoXY( 4, an[armonica], -bn[armonica] );
		inc(desp, DatosVentana);
	end;
	readln;
	TermineGR;
	FreeMem(pv, NMed* SizeOf(NReal));
end.
