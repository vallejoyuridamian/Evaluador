unit gigavr;
{
PROPOSITO:
	Implementaci¢n del objecto Vector Gigante de reales.

}

interface
uses
	GigaVect;

type

	VGiganteRPtr = ^VGiganteR;

	VGiganteR = object(VectorGigante)
		constructor Init;
		procedure Put( x:real; k:LongInt);virtual;
		function e( k:LongInt): real;virtual;
	end;

	VGR_parasito = object
		procedure link( var xVGR: VGiganteR; xDesplazamiento: LongInt);
		procedure Put( x:real; k:LongInt);
		function e(k: LongInt): real;
	private
		vgrp: VGiganteRPtr;
		desp:LongInt;
	end;


implementation

constructor VGiganteR.Init;
begin
	VectorGigante.Init(SizeOf(Real));
end;

function VGiganteR.e( k: LongInt):real;
var
	x:real;
begin
	getElemento(x,k);
	e:=x;
end;

procedure VGiganteR.Put( x:real; k:LongInt);
begin
	PutElemento(x,k);
end;

procedure VGR_parasito.link(
	var xVGR: VGiganteR; xDesplazamiento: LongInt);
begin
	vgrp:= @xVGR;
	desp:= xDesplazamiento;
end;


procedure VGR_parasito.put( x:real; k:LongInt);
begin
	vgrp^.put(x,k+desp);
end;

function VGR_parasito.e(k: LongInt): real;
begin
	e:=vgrp^.e(k+desp);
end;

end.
