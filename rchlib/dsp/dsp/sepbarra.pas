{+doc
+NOMBRE:     SepBarra
+CREACION:    7.2.93
+AUTORES:      rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:   Objeto para detectar barras relevantes en un espectro en forma
	autom tica.

+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
	Separa las barras cuyo valor sea mayor que el promedio de las
(AnchoVentana) barras siguientes multiplicado por (FactorRelacion).
	(TSeparadorDeBarras) se dise¤o para analizar autom ticamente se¤ales
y detectar la compunente determin¡stica de las mismas.
	(AnchoVentana) y (FactorRelacion) fijan el criterio.
-doc}

unit sepbarra;

interface
uses
	MatReal;

type

	TSeparadorDeBarras = object
		constructor Init(
			xPunteroVectorReal: PVectR;
			xAnchoVentana: LongInt;
			xFactorRelacion: real );
		function SepararPrimera:LongInt;
		function SepararPrimeraDesde( Primera: LongInt ):LongInt;
		function SepararSiguiente:LongInt;
		procedure CambiarAnchoVentana( xNuevoANcho: LongInt );
		procedure CambiarRelacion( xNuevaRelacion: real );
		procedure FijarVentanaDeBusqueda( xPosInf, xPosSup: LongInt );
		destructor Done;

	private
		Pos, PosInf, PosSup: LongInt;
		p1, p2: pointer;
		vrp : PVectR;
		SumaVentana: real;
		AnchoVentana: LongInt;
		FactorRelacion: real;
		FactorRelacionPromedio: real;

		procedure CalcularFRP;
	end;

implementation



constructor TSeparadorDeBarras.Init(
			xPunteroVectorReal: PVectR;
			xAnchoVentana: LongInt;
			xFactorRelacion: real );

begin
	vrp:= xPunteroVectorReal;
	AnchoVentana:= xAnchoVentana;
	FactorRelacion:= xFactorRelacion;
	PosInf:= 1;
	PosSup:= vrp^.n-AnchoVentana;
	CalcularFRP;
end;

function TSeparadorDeBarras.SepararPrimeraDesde( Primera: LongInt ):LongInt;
var
	k:LongInt;
begin
	pos:= Primera; { se¤alamos la primera barra }
	if Pos < PosInf then Pos:= PosInf;
	if Pos<=PosSup then
	begin
		SumaVentana:= 0;
		p1:=vrp^.pte(1); p2:= p1;

		for k:= 1 to AnchoVentana do
		begin
			SumaVentana:= SumaVentana + real(p2^);
			vrp^.inc(p2);
		end;
		SepararPrimeraDesde:= SepararSiguiente;
	end
	else SepararPrimeraDesde:= -1;
end;

function TSeparadorDeBarras.SepararPrimera:LongInt;
begin
	SumaVentana:= 0;
	SepararPrimera:= SepararPrimeraDesde( PosInf );
end;

procedure TSeparadorDeBarras.CalcularFRP;
begin
	FactorRelacionPromedio:= FactorRelacion / AnchoVentana;
end;


procedure TSeparadorDeBarras.FijarVentanaDeBusqueda( xPosInf, xPosSup: LongInt );
begin
	if xPosInf < 1 then PosInf:= 1
	else PosInf:= xPosInf;
	if xPosSup > vrp^.n-AnchoVentana then PosSup:= vrp^.n-AnchoVentana
	else PosSup:= xPosSup;
	if PosInf > PosSup then PosInf:= PosSup;
end;

function TSeparadorDeBarras.SepararSiguiente:LongInt;
var
	res: integer;
begin
	res:= -2;
	while res = -2 do
	begin
		if pos <= PosSup then
		begin
			SumaVentana:= SumaVentana - real(p1^)+real(p2^);
			if real(p1^) > SumaVentana * FactorRelacionPromedio then
				res:= pos;
			inc(pos); vrp^.inc(p1); vrp^.inc(p2);
		end
		else res:= -1;
	end;
	SepararSiguiente:= res;
end;





procedure TSeparadorDeBarras.CambiarAnchoVentana( xNuevoANcho: LongInt );
begin
	AnchoVentana:= xNuevoAncho;
	CalcularFRP;
	FijarVentanaDeBusqueda( PosInf, PosSup );
end;

procedure TSeparadorDeBarras.CambiarRelacion( xNuevaRelacion: real );
begin
	FactorRelacion:= xNuevaRelacion;
	CalcularFRP;
end;

destructor TSeparadorDeBarras.Done;
begin
end;

end.