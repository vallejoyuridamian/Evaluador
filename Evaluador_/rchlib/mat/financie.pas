{+doc
+NOMBRE: financie
+CREACION: 12/03/94
+AUTORES: RCH
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:  Definición de funciones financieras
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

UNIT financie;

interface
	uses
		xMatDefs, ComPol2, Math01, horrores;

{ Calcula el valor actual neto de INGRESOS.
	INGRESOS, es un Polinomio donde cada coeficiente indica un flujo neto,
si es positivo es un ingreso si es negativo es es egreso. El coeficiente
de grado 0 del polinomio se considera en el presente, el siguiente un paso
adelente en el tiempo, debiendo multiplicarse por (1/(1+tasa)) para llevarlo
y así sucesivamente asta el coeficiente de mayor grado del polinomio el cual
se considera (grado del polinomio) pasos de tiempo adelantado en el futuro.- }
function VAN( var Ingresos: TPoliR; tasa: NReal): NReal;

{ Dado un polinomio de Ingresos, calcula la tasa interna de retorno TIR,
como la tasa de actualización que lleva el VAN de los ingresos a ser nulo}
function TIR(
	var Ingresos: TPoliR;
	TasaInicial: NReal;
	var  res: boolean;
	var VANTIR: NReal): NReal;


{ Cantidad de meses entre dos fechas }
function MesesEntre( Mes1, Ano1, Mes2, Ano2: integer): integer;

{ RaizN }
function RaizN( x: NReal; n: integer): NReal;

{ PotenciaN }
function PotenciaN( x: NReal; n: integer): NReal;

{ Anual2Mensual, convierte una tasa de anual a mensual }
function Anual2Mensual( x: NReal ): NReal;

{ Mensual2Anual, convierte una tasa de mensual a anual }
function Mensual2Anual( x: NReal ): NReal;


implementation


function MesesEntre( Mes1, Ano1, Mes2, Ano2: integer): integer;
var
	da, dm: integer;
begin
	da:= Ano2- Ano1;
	dm:= Mes2-Mes1;
	if da < 0 then
		MesesEntre:= -MesesEntre( Mes2, Ano2, Mes1, Ano1)
	else
	begin
		if da = 0 then MesesEntre:= dm
		else
		begin
			if dm < 0 then
			begin
				dec(da);
				dm:= 12+dm;
			end;
			MesesEntre:= da*12+dm;
		end;
	end;
end;


{ Anual2Mensual, convierte una tasa de anual a mensual }
function Anual2Mensual( x: NReal ): NReal;
var
	q: NREal;
begin
	q:= 1+x;
	q:= raizN(q, 12);
	Anual2Mensual:= q -1;
end;

{ Mensual2Anual, convierte una tasa de mensual a anual }
function Mensual2Anual( x: NReal ): NReal;
var
	q: NReal;
begin
	q:= 1+x;
	q:= PotenciaN(q, 12);
	Mensual2Anual:= q -1;
end;


function RaizN( x: NReal; n: integer): NReal;
begin
	{$IFOPT R+}
	if N<1 then error('RaizN: N<1');
  {$ENDIF}
	if EsCero(x) then RaizN:=0
	else if (x<0)and ( N mod 2 <> 0) then
		RaizN:= -exp(ln(x)/N)
	else
		RaizN:= exp(ln(x)/N);
end;

function PotenciaN( x: NReal; n: integer): NReal;
begin
	if EsCero(x) then PotenciaN:= 0
	else
	if (x<0) and( N mod 2 <> 0) then
			PotenciaN:= -exp(ln(x)*N)
	else
			PotenciaN:= exp(ln(x)*N)
end;

  

function VAN( var Ingresos: TPoliR; tasa: NReal): NReal;
var
	actualizador: NReal;
begin
	actualizador:= 1/(tasa+1);
	VAN:= Ingresos.Valx(actualizador);
end;
    
var
	pIngresos: PPoliR;

function VANx( x: NReal): NReal; far;
begin
	VANx:= pIngresos^.Valx(x);

end;

	
function TIR(
	var Ingresos: TPoliR;
	TasaInicial: NReal;
	var  res: boolean;
	var VANTIR: NReal): NReal;
var
	xtol: NReal;
	VAN0, VAN1: NReal;
	Root, FAtRoot: NReal;
	NoOfIts: word;
	xInicial: NReal;
	k, desplazamiento: integer;


begin
	pIngresos:= @Ingresos;

	desplazamiento:= 0;
	k:= 1;
	while desplazamiento = 0 do
		if EsCero(NReal(pIngresos^.pte(k)^)) then inc(k)
		else desplazamiento:= k;
	desplazamiento:= desplazamiento-1;

	if Desplazamiento> 0 then
	begin
		for k:= 1 to pIngresos^.Gr+1-Desplazamiento do
			NReal(pIngresos^.pte(k)^):= NReal(pIngresos^.pte(k+desplazamiento)^);
		pIngresos^.GR:= pIngresos^.GR-Desplazamiento;
	end;

	xtol:=1e-5;

	xinicial:= 1/(1+tasaInicial);
	(*
	Secant(
		VANx, 							{funci¢n a anular}
		0, xinicial, xtol,  {valores iniciales de x y tolerancia}
		1000,					{n£mero m ximo de iteraciones}
		Root, fAtRoot,	{ra¡z y f(ra¡z)}
		NoOfIts,			{n£mero de iteraciones realizadas}
		res);	{valid‚s del resultado}

	*)

	res:= false;
	Dicot(
			VANx,
			0, xInicial,xtol,
			1000,
			Root,fAtRoot,
			NoOfIts,
			res);
	if not res then
		writeln(' OJO NO COnverge', 1/root -1:12:4)
		else writeln(' TIR: ', 1/root -1:12:4);

	TIR:= 1/Root -1;
	VANTIR:= fAtRoot;

	if Desplazamiento> 0 then
	begin
		for k:= pIngresos^.Gr+1 downto 1+desplazamiento do
			NReal(pIngresos^.pte(k)^):= NReal(pIngresos^.pte(k-desplazamiento)^);
		pIngresos^.GR:= pIngresos^.GR+Desplazamiento;
		for k:= desplazamiento downto 1 do NReal(pIngresos^.pte(k)^):=0;
	end;
end;
	

end.	 

