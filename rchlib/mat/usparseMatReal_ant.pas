unit uSparseMatReal;

interface

uses
	Classes,
	SysUtils,
	Math,
	xMatDefs,
	COMPOL,
	MatReal;
type
	TCoeficiente = class
		private
			findice : Integer;
			fvalor : NReal;
		public
			property indice : Integer read findice write findice;
			property valor : NReal read fvalor write fvalor;

			Constructor Create(indice : Integer ; valor : NReal);
			Constructor Create_Clone(x : TCoeficiente);
			//Clona el coeficiente
	end;

	TSparseVectR = class
		private
			//n : Integer; no se usa mas es el capacity de la lista
			//cantNoCeros : Integer; no se usa mas, es el count de la lista
			Coefs : TList; {of TCoeficiente}
			ultimoIter : Integer;

			function buscarCoef(k : Integer) : Integer;
			//retorna la posición de la lista donde iría el indice k
			function getCapacity : Integer;
			procedure setCapacity(n : Integer);
		public
			property n : Integer read getCapacity write setCapacity;

		procedure Igual( x: TSparseVectR );
		constructor Create_Init( ne: integer);
		constructor Create_FromDAofR( a: TDAofNReal );
		constructor Create_Clone( vrx: TSparseVectR );
		procedure Free; virtual;

		constructor Create_Load( var S: TStream );
		procedure Store( var S: TStream );
		function e(k : integer) : NReal;
		procedure pon_e(k : integer ; x : NReal);
		procedure acum_e(k : integer ; x : NReal);

// copia los valores del vector xv a partir del kini  for k= 0 to high( xv ) do pon_e(ini+k, xv[k] ) ;
		procedure pon_ev( kini : integer ; xv : array of NReal );

		function PEV( y : TSparseVectR):NReal;
		function PEVRFLX(y : TSparseVectR): NReal;

// norma euclidea al cuadrado de la diferencia
		function distancia2( y : TSparseVectR):NReal;

// norma euclídea de la diferencia
		function distancia( y :TSparseVectR):NReal;

//Coeficiente de correlación < x[k] * y[k-kdesp] >
		function coefcorr( y: TSparseVectR ; kdesp : integer ): NReal;

		procedure PorReal(r : NReal);
		procedure sum(y : TSparseVectR);
		procedure sumRPV(r : NReal ; x : TSparseVectR);
		function ne2 : NReal; {norma euclideana al cuadrado }
		function varianza : NReal; { <pv[k]^2> }
		function normEuclid : NReal;
		function normMaxAbs : NReal;
		function normSumAbs : NReal;
		procedure Copy(var x : TSparseVectR);
		procedure Ceros; virtual;
		procedure MinMax(var kMin, kMax : integer ; var Min, Max : NReal);
		procedure Print; virtual;

		{ Divide las componetes por la norma obligando al vector a
		tener norma ecuclidea = 1 }
		procedure HacerUnitario;

		(*
		function EstimFrec(
						nivel,					{nivel de compoaracion}
						histeresis: NReal;	{histeresis del cruce }
						AbajoArriba: boolean	{sentido del cruce}
						): NReal;				{cantidad de cruces}
		*)

		procedure Sort( creciente: boolean );

		// evalua sum( ak * x^(k-1) ; k= 1 a n );
		function rpoly( x: NReal ): NReal;

		// evalua sum( ak * x^(k-1) ; k= 1 a n );
		procedure cpoly( var resc: NComplex; xc: NComplex );
		procedure versor_randomico;

// el indice kr es real y debe estar en el rango 1..n
		function interpol( kr: NReal ): NReal;

// retorna la recta que a*k+b que mejor aproxima al conjunto
// de puntos del vector en el sentido de mínimos cuadrados
		procedure AproximacionLineal( var a, b: NReal );
	end;

	TFuncCompare = function(item1, item2 : NReal) : Integer;
	//La función retorna: < 0 si Item1 es menor que Item2
	// 										0 si son iguales
	//									  > 0 si Item1 es mayor que Item2.

implementation
{************************
//Metodos de TCoeficiente
-------------------------}

Constructor TCoeficiente.Create(indice : Integer ; valor : NReal);
begin
	inherited Create;
	findice := indice;
	fvalor := valor;
end;

Constructor TCoeficiente.Create_Clone(x : TCoeficiente);
begin
	inherited Create;
	indice := x.indice;
	valor := x.valor;
end;

{*************************
//Meotodos de TSparseVectR
--------------------------}

function TSparseVectR.buscarCoef(k : Integer) : Integer;
var
	i{, pos} : integer;
begin
	if Coefs.Count > 0 then
		begin
		if (ultimoIter >= Coefs.Count) or (TCoeficiente(Coefs[ultimoIter]).indice > k) then
			ultimoIter := 0;
{		pos := -1;
		for i := ultimoIter to Coefs.Count -1 do
			begin
			if TCoeficiente(coefs[i]).indice >= k then
				begin
				pos := i;
				break;
				end;
			end;
		if pos <> -1 then
			begin
			ultimoIter := pos;
			result := pos
			end
		else
			begin
			ultimoIter := Coefs.Count -1;
			result := Coefs.Count
			end
		end   }
		i := ultimoIter;
		while (i < Coefs.Count) and (TCoeficiente(coefs[i]).indice < k) do
			inc(i);
		if i = Coefs.Count then
			 ultimoIter := i - 1
		else ultimoIter := i;
		result := i;
		end
	else
		result := 0;
end;

function TSparseVectR.getCapacity : Integer;
begin
	result := Coefs.Capacity + 1;
end;

procedure TSparseVectR.setCapacity(n : Integer);
begin
	Coefs.Capacity := n;
end;

procedure TSparseVectR.Igual( x: TSparseVectR );
var
	i : Integer;
begin
	for i := 0 to Coefs.Count -1 do
		TCoeficiente(Coefs[i]).Free;
	Coefs.Clear;
	Coefs.Capacity := x.Coefs.Capacity;
	for i := 0 to x.Coefs.Count -1 do
		Coefs.Add(TCoeficiente.Create_Clone(TCoeficiente(x.Coefs[i])));
end;

constructor TSparseVectR.Create_Init( ne: integer);
begin
	inherited Create;
	Coefs := TList.Create;
	Coefs.Capacity := ne;
	ultimoIter := 0;
end;

constructor TSparseVectR.Create_FromDAofR( a: TDAofNReal );
var
	i : Integer;
begin
	inherited Create;
	Coefs := TList.Create;
	Coefs.Capacity := Length(a);
	for i := 0 to high(a) do
		if a[i] <> 0 then
			begin
			Coefs.Add(TCoeficiente.Create(i, a[i]));
			end;
	ultimoIter := 0;
end;

constructor TSparseVectR.Create_Clone( vrx: TSparseVectR );
var
	i : Integer;
begin
	inherited Create;
	ultimoIter := vrx.ultimoIter;
	Coefs := TList.Create;
	Coefs.Capacity := vrx.Coefs.Capacity;
	for i := 0 to vrx.Coefs.Count -1 do
		Coefs.Add(TCoeficiente.Create_Clone(TCoeficiente(vrx.Coefs[i])));
end;

procedure TSparseVectR.Free;
var
	i : Integer;
begin
	for i := 0 to Coefs.Count -1 do
		TCoeficiente(Coefs[i]).Free;
	Coefs.Free;
	inherited Free;
end;

constructor TSparseVectR.Create_Load( var S: TStream );
type
	Tbuffer = record
		indice : Integer;
		valor : NReal;
	end;
var
	buff : array of Tbuffer;
	i : Integer;
	k : Integer;
	cantNoCeros : Integer;
begin
	inherited Create;
	Coefs := TList.Create;
	S.read(k, sizeOf(n));
	Coefs.Capacity := k;
	S.Read(cantNoCeros, sizeOf(cantNoCeros));
	if cantNoCeros > 0 then
		begin
		SetLength(buff, cantNoCeros);
		S.Read(buff[0], cantNoCeros * SizeOf(TBuffer));
		for i := 0 to cantNoCeros - 1 do
			Coefs.Add(TCoeficiente.Create(buff[i].indice, buff[i].valor));
		end;
	ultimoIter := 0;
end;

procedure TSparseVectR.Store( var S: TStream );
var
	i : Integer;
begin
	S.Write(Coefs.Capacity, sizeOf(Coefs.Capacity));
	S.Write(Coefs.Count, sizeOf(Coefs.Count));
	for i := 0 to Coefs.Count -1 do
		begin
		S.Write(TCoeficiente(Coefs[i]).indice, sizeOf(TCoeficiente(Coefs[i]).indice));
		S.Write(TCoeficiente(Coefs[i]).valor, sizeOf(TCoeficiente(Coefs[i]).valor));
		end;
end;

function TSparseVectR.e(k : integer) : NReal;
var
	indice : Integer;
begin
	indice := buscarCoef(k);
	if (indice < Coefs.Count) and (TCoeficiente(Coefs[indice]).indice = k) then
		result := TCoeficiente(Coefs[indice]).valor
	else result := 0;
end;

procedure TSparseVectR.pon_e(k : integer ; x : NReal);
var
	indice : Integer;
begin
indice := buscarCoef(k);
if x <> 0 then
	begin
	if (indice >= Coefs.Count) or (TCoeficiente(Coefs[indice]).indice <> k) then
		Coefs.Insert(indice, TCoeficiente.Create(k, x))
	else
		TCoeficiente(Coefs[indice]).valor := x;
	end
else
	begin
	if (indice < Coefs.Count) and (TCoeficiente(Coefs[indice]).indice = k) then
		begin
		TCoeficiente(Coefs[indice]).Free;
		Coefs.Delete(indice);
		end;
	end
end;

procedure TSparseVectR.acum_e(k : integer ; x : NReal);
var
	indice : Integer;
	coef : TCoeficiente;
begin
if x <> 0 then
	begin
	indice := buscarCoef(k);
	if (indice >= Coefs.Count) or (TCoeficiente(Coefs[indice]).indice <> k) then
		Coefs.Insert(indice, TCoeficiente.Create(k, x))
	else
		begin
		coef :=	TCoeficiente(Coefs[indice]);
		if coef.valor + x = 0 then	//Si la suma da 0 lo saco de la lista
			begin
			coef.Free;
			coefs.Delete(indice);
			end
		else
			TCoeficiente(Coefs[indice]).valor := TCoeficiente(Coefs[indice]).valor + x;
		end
	end
end;

procedure TSparseVectR.pon_ev( kini : integer ; xv : array of NReal );
var
	i : Integer;
begin
	for i := 0 to Coefs.Count -1 do
		TCoeficiente(Coefs[i]).Free;
	Coefs.Clear;
	Coefs.Capacity := Length(xv);
	for i := kini to high(xv) do
		if xv[i] <> 0 then
			Coefs.Add(TCoeficiente.Create(i, xv[i]));
	ultimoIter := 0;
end;

function TSparseVectR.PEV( y : TSparseVectR):NReal;
var
	iterX, iterY : Integer;
	temp : NReal;
begin
	temp := 0;
	iterX := 0;
	iterY := 0;
	while (iterX < Coefs.Count) and (iterY < y.Coefs.Count) do
		begin
		if TCoeficiente(Coefs[iterX]).indice < TCoeficiente(y.Coefs[iterY]).indice then
			inc(iterX)
		else if TCoeficiente(Coefs[iterX]).indice > TCoeficiente(y.Coefs[iterY]).indice then
			inc(iterY)
		else
			begin
			temp := temp + TCoeficiente(Coefs[iterX]).valor * TCoeficiente(y.Coefs[iterY]).valor;
			inc(iterX);
			inc(iterY);
			end
		end;
	PEV	:=	temp
end;

function TSparseVectR.PEVRFLX(y : TSparseVectR): NReal;
var
	temp : NReal;
	iterX, iterY, aux : Integer;
begin
	temp := 0;
	iterX := 0;
	iterY := y.Coefs.Count - 1;
	while (iterX < Coefs.Count) and (iterY > 0) do
		begin
		aux := Coefs.Capacity + 1 - TCoeficiente(Coefs[iterX]).indice;
		if aux > TCoeficiente(y.Coefs[iterY]).indice then
			inc(iterX)
		else if aux < TCoeficiente(y.Coefs[iterY]).indice then
			dec(iterY)
		else
			begin
			temp := temp + TCoeficiente(Coefs[iterX]).valor * TCoeficiente(y.Coefs[iterY]).valor;
			inc(iterX);
			dec(iterY);
			end
		end;
	PEVRFLX := temp
end;

function TSparseVectR.distancia2( y : TSparseVectR):NReal;
var
	iterX, iterY, i : Integer;
	coefX, coefY : TCoeficiente;
	temp : NReal;
begin
	temp := 0;
	iterX := 0;
	iterY := 0;
	while (iterX < Coefs.Count) and (iterY < y.Coefs.Count) do
		begin
		coefX := TCoeficiente(Coefs[iterX]);
		coefY := TCoeficiente(y.Coefs[iterY]);
		if coefX.indice < coefY.indice then
			begin
			temp := temp + sqr(coefX.valor);
			inc(iterX)
			end
		else if coefX.indice > coefY.indice then
			begin
			temp := temp + sqr(coefY.valor);//sería -coefY.valor pero al cuadrado da igual
			inc(iterY)
			end
		else
			begin
			temp := temp + sqr(coefX.valor - coefY.valor);
			inc(iterX);
			inc(iterY)
			end;
		end;

		for i := iterX to Coefs.Count -1 do												//Solo se ejecuta uno de estos fors para terminar con el que me haya quedado
			temp := temp + sqr(TCoeficiente(Coefs[i]).valor);
		for i := iterY to y.Coefs.Count -1 do
			temp := temp + sqr(TCoeficiente(y.Coefs[i]).valor);

	result:= temp;
end;

function TSparseVectR.distancia( y :TSparseVectR):NReal;
begin
	result := sqrt(distancia2(y));
end;

function TSparseVectR.coefcorr( y: TSparseVectR ; kdesp : integer ): NReal;
var
	a : NReal;
	m, iterX, iterY, aux : integer;
begin
	if kdesp < 0 then
		result:= y.coefcorr( Self, -kdesp )
	else
		begin
		a:= 0;
		m:= Coefs.Capacity + 1 - kdesp;
		if m > 0 then
			begin
			iterX := buscarCoef(kdesp);
			iterY := 0;
			while (iterX < Coefs.Count) and (iterY < y.Coefs.Count) do
				begin
				aux := TCoeficiente(Coefs[iterX]).indice - kdesp;
				if TCoeficiente(y.Coefs[iterY]).indice > aux then
					inc(iterX)
				else if TCoeficiente(y.Coefs[iterY]).indice < aux then
					inc(iterY)
				else
					begin
					a := a + TCoeficiente(Coefs[iterX]).valor * TCoeficiente(y.Coefs[iterY]).valor;
					inc(iterX);
					inc(iterY)
					end;
				end;
				result := a / m;
			end
		else
			result:= 0;
		end
end;

procedure TSparseVectR.PorReal(r : NReal);
var
	i, aux : Integer;
begin
if r <> 0 then
	for i := 0 to Coefs.Count -1 do
		TCoeficiente(Coefs[i]).valor := TCoeficiente(Coefs[i]).valor * r
else
	begin
	for i := 0 to Coefs.Count -1 do
		begin
		TCoeficiente(coefs[i]).Free;
		end;
	aux := Coefs.Capacity;
	Coefs.Clear;
	Coefs.Capacity := aux;
	end
end;

procedure TSparseVectR.sum(y : TSparseVectR);
var
	iterY, iterSelf, indiceY : Integer;
begin
iterSelf := 0;
iterY := 0;
while (iterSelf < Coefs.Count) and (iterY < y.Coefs.Count) do
	begin
	indiceY := TCoeficiente(y.Coefs[iterY]).indice;
	while (iterSelf < Coefs.Count) and (TCoeficiente(Coefs[iterSelf]).indice < indiceY) do
		inc(iterSelf);
	if (iterSelf < Coefs.Count) and (TCoeficiente(Coefs[iterSelf]).indice <> indiceY) then
		begin
		Coefs.Insert(iterSelf, TCoeficiente.Create(TCoeficiente(y.Coefs[iterY]).indice, TCoeficiente(y.Coefs[iterY]).valor));
		inc(iterSelf);
		end
	else if iterSelf < Coefs.Count then
		begin
		TCoeficiente(Coefs[iterSelf]).valor := TCoeficiente(Coefs[iterSelf]).valor + TCoeficiente(y.Coefs[iterY]).valor;
		if TCoeficiente(Coefs[iterSelf]).valor = 0 then
			begin
			TCoeficiente(Coefs[iterSelf]).Free;
			Coefs.Delete(iterSelf);
			dec(iterSelf);
			end
		else
			inc(iterSelf)
		end
	else
		Coefs.Add(TCoeficiente.Create(TCoeficiente(y.Coefs[iterY]).indice, TCoeficiente(y.Coefs[iterY]).valor));
	inc(iterY)
	end;
for iterY := iterY to y.Coefs.Count -1 do
	Coefs.Add(TCoeficiente.Create(TCoeficiente(y.Coefs[iterY]).indice, TCoeficiente(y.Coefs[iterY]).valor));
end;

procedure TSparseVectR.sumRPV(r : NReal ; x : TSparseVectR);
var
	iterX, iterSelf, indiceX : Integer;
begin
if r <> 0 then
	begin
	iterSelf := 0;
	iterX := 0;
	while (iterSelf < Coefs.Count) and (iterX < x.Coefs.Count) do
		begin
		indiceX := TCoeficiente(x.Coefs[iterX]).indice;
		while (iterSelf < Coefs.Count) and (TCoeficiente(Coefs[iterSelf]).indice < indiceX) do
			inc(iterSelf);
		if (iterSelf < Coefs.Count) and (TCoeficiente(Coefs[iterSelf]).indice <> indiceX) then
			begin
			Coefs.Insert(iterSelf, TCoeficiente.Create(TCoeficiente(x.Coefs[iterX]).indice, TCoeficiente(x.Coefs[iterX]).valor * r));
			inc(iterSelf);
			end
		else if iterSelf < Coefs.Count then
			begin
			TCoeficiente(Coefs[iterSelf]).valor := TCoeficiente(Coefs[iterSelf]).valor + r * TCoeficiente(x.Coefs[iterX]).valor;
			if TCoeficiente(Coefs[iterSelf]).valor = 0 then
				begin
				TCoeficiente(Coefs[iterSelf]).Free;
				Coefs.Delete(iterSelf);
				dec(iterSelf);
				end
			else
				inc(iterSelf)
			end
		else
			Coefs.Add(TCoeficiente.Create(TCoeficiente(x.Coefs[iterX]).indice, TCoeficiente(x.Coefs[iterX]).valor * r));
		inc(iterX)
		end;
	for iterX := iterX to x.Coefs.Count -1 do
		Coefs.Add(TCoeficiente.Create(TCoeficiente(x.Coefs[iterX]).indice, TCoeficiente(x.Coefs[iterX]).valor * r));
	end
end;

function TSparseVectR.ne2 : NReal;
var
	iter : Integer;
	acum : NReal;
begin
	acum := 0;
	for iter := 0 to Coefs.Count -1 do
		acum := acum + sqr(TCoeficiente(Coefs[iter]).valor);
	ne2 := acum
end;

function TSparseVectR.varianza : NReal;
begin
	result := ne2 / (Coefs.Capacity + 1);
end;

function TSparseVectR.normEuclid : NReal;
begin
	normEuclid := sqrt(ne2)
end;

function TSparseVectR.normMaxAbs : NReal;
var
	k : integer;
	max, aux : NReal;
begin
if Coefs.Count > 0 then
	begin
	max := abs(TCoeficiente(Coefs[0]).valor);
	for k := 1 to Coefs.Count -1 do
		begin
		aux := abs(TCoeficiente(Coefs[k]).valor);
		if aux > max then
			max := aux;
		end;
	result := max;
	end
else
	result := 0;
end;

function TSparseVectR.normSumAbs : NReal;
var
	k :integer;
	acum  :NReal;
begin
	acum:=0;
	for k := 0 to Coefs.Count -1 do
		acum := acum + abs(TCoeficiente(Coefs[k]).valor);
	normSumAbs:=acum
end;

procedure TSparseVectR.Copy(var x : TSparseVectR);
var
	i : Integer;
begin
	for i := 0 to Coefs.Count - 1 do
		begin
		TCoeficiente(Coefs[i]).Free;
		end;
	Coefs.Clear;
	Coefs.Capacity := x.Coefs.Capacity;
	for i := 0 to x.Coefs.Count - 1 do
		Coefs.Add(TCoeficiente.Create_Clone(TCoeficiente(x.Coefs[i])))
end;

procedure TSparseVectR.Ceros;
var
	i : Integer;
begin
	for i := 0 to Coefs.Count - 1 do
		begin
		TCoeficiente(Coefs[i]).Free;
		Coefs[i] := NIL;
		end;
	Coefs.Pack;
end;

procedure TSparseVectR.MinMax(var kMin, kMax : integer ; var Min, Max : NReal);
var
	m : NReal;
	i : integer;
begin
if Coefs.Count > 0 then
	begin
	Min := TCoeficiente(Coefs[0]).valor; kMin := TCoeficiente(Coefs[0]).indice;
	Max := TCoeficiente(Coefs[0]).valor; kMin := TCoeficiente(Coefs[0]).indice;

	for i := 1 to Coefs.Count -1 do
		begin
		m := TCoeficiente(Coefs[i]).valor;
		if m < min then
			begin
			Min := m;
			kMin := TCoeficiente(Coefs[i]).indice
			end
		else if m > max then
			begin
			Max := m;
			kMax := TCoeficiente(Coefs[i]).indice
			end;
		end
	end
else
	begin
	kmin := 0;
	kmax := 0;
	min := 0;
	max := 0;
	end
end;

procedure TSparseVectR.Print;
var
	k : integer;
begin
	writeln(' TSparseVectR.print.inicio');
	for k:= 0 to Coefs.Capacity -1 do
		writeln(' N: ',k:6,' : ',e(k):12:4);
	writeln(' TSparseVectR.print.fin');
end;

procedure TSparseVectR.HacerUnitario;
var
	m : NReal;
begin
	m := NormEuclid;
	if Not EsCero(m/Coefs.Capacity) then
		PorReal(1/m)
	else
		pon_e(0, 1);
end;

function mayor(item1, item2 : NReal) : Integer;
begin
	if item1 < item2 then result := -1
	else if item1 = item2 then result := 0
	else result := 1
end;

function menor(item1, item2 : NReal) : Integer;
begin
	if item1 > item2 then result := -1
	else if item1 = item2 then result := 0
	else result := 1
end;

function MedianaDeTres(elems : TDAofNReal; inf, sup : Integer; compare : TFuncCompare) : NReal;
var
	centro : Integer;
	aux : NReal;
begin
	centro := (inf + sup) div 2;
	if (compare(elems[centro], elems[inf]) < 0) then
			begin
			aux := elems[inf];
			elems[inf] := elems[centro];
			elems[centro] := aux
			end;
	if (compare(elems[sup], elems[inf]) < 0) then
			begin
			aux := elems[inf];
			elems[inf] := elems[sup];
			elems[sup] := aux
			end;
	if (compare(elems[sup], elems[centro]) < 0) then
			begin
			aux := elems[centro];
			elems[centro] := elems[sup];
			elems[sup] := aux
			end;

{	aux := elems[centro];
	elems[centro] := elems[sup - 1];
	elems[sup - 1] := aux; }

 	result := elems[centro];
end;

procedure QuickSort(elems : TDAofNReal; inf, sup : Integer; compare : TFuncCompare);
var
	i, j : Integer;
	sigo : boolean;
	pivote, aux : NReal;
begin
	if inf < sup then
		begin
		pivote := MedianaDeTres(elems, inf, sup, compare);
		i := inf;
		j := sup;
		sigo := true;
		while sigo do
			begin
			while (compare(elems[i], pivote) <= 0) do inc(i);
			while (compare(elems[j], pivote) >= 0) do dec(j);
			if i < j then
				begin
				aux := elems[i];
				elems[i] := elems[j];
				elems[j] := aux;
				end
			else
				sigo := false;
		end;
		if inf < j then QuickSort(elems, inf, j, compare);
		if i < sup then QuickSort(elems, i, sup, compare)
		end
end;

procedure TSparseVectR.Sort( creciente: boolean );
var
	compare : TFuncCompare;
	i : Integer;
	elems : TDAofNReal;
begin
	SetLength(elems, Coefs.Capacity);
	for i := 0 to Coefs.Capacity -1 do
		elems[i] := e(i);
	if creciente then compare := mayor
	else compare := menor;
	QuickSort(elems, 0, high(elems), compare);
	pon_ev(0, elems);
	SetLength(elems, 0);
end;

function TSparseVectR.rpoly( x: NReal ): NReal;
var
	r : NReal;
	k, iter : integer;
begin
	r := 0;
	iter := Coefs.Count -1;
	for k := n downto 1 do
		begin
			if (iter >= 0) and (TCoeficiente(Coefs[iter]).indice = k) then
				begin
				r := r * x + TCoeficiente(Coefs[iter]).valor;
				dec(iter);
				end
			else
				r := r * x //TCoeficiente(Coefs[iter]).valor = 0
		end;
	result := r;
end;

procedure TSparseVectR.cpoly( var resc: NComplex; xc: NComplex );
var
	k: integer;
begin
	resc.r := e(Coefs.Capacity -1);
	resc.i := 0;

	for k := Coefs.Capacity - 2 downto 0 do
	begin
		Compol.Pro( resc, resc, xc );
		resc.r:= resc.r + e(k);
	end;
end;

procedure TSparseVectR.versor_randomico;
var
	k : integer;
	acum : NReal;
	x : NReal;
begin
	acum := 0;
	for k:= 0 to Coefs.Capacity -1 do
	begin
		x:= 0.5 - random;
		pon_e(k, x);
		acum := acum + x*x;
	end;

	acum := sqrt(acum);
	if acum > AsumaCero then
		begin
		for k := 0 to Coefs.Capacity -1 do
			TCoeficiente(Coefs[k]).valor := TCoeficiente(Coefs[k]).valor/acum;
		end
	else
		pon_e(0, 1);
end;

function TSparseVectR.interpol( kr: NReal ): NReal;
var
	k1: integer;
	aux : NReal;
begin
	k1 := trunc( kr );
	if k1 <= 0 then
		result:= e(0)
	else if k1 >= Coefs.Capacity -1 then
		result:= e(Coefs.Capacity -1)
	else
		begin
		aux := e(k1);//solo para no hacer la busqueda 2 veces
		result:= (e(k1 + 1) - aux) * (kr - k1) + aux;
		end
end;

// retorna la recta a*k+b que mejor aproxima al conjunto
// de puntos del vector en el sentido de mínimos cuadrados
procedure TSparseVectR.AproximacionLineal( var a, b: NReal );
var
	ma, mb: TMatR;
	k: integer;
	prom_k2, prom_k, prom_uno, prom_k_yk, prom_yk: NReal;
	res: NReal;
	coef : TCoeficiente;
begin
	prom_k:= (n + 1) / 2;
	prom_uno:= 1;
	prom_k_yk:= 0;
	prom_yk:= 0;
	for k := 0 to Coefs.Count -1 do
	begin
		coef := TCoeficiente(Coefs[k]);
		prom_k_yk := prom_k_yk + coef.indice * coef.valor;
		prom_yk := prom_yk + coef.valor;
	end;
	prom_k_yk := prom_k_yk / n ;
	prom_yk := prom_yk / n;
	prom_k2 := (((n) * (n + 1) * (2*n + 1))  / (6*n)) / n;

	ma := TMatR.Create_Init( 2, 2 );
	mb := TMatR.Create_Init( 2, 1 );

	ma.pon_e( 1, 1, prom_k2 );
	ma.pon_e( 1, 2, prom_k );
	ma.pon_e( 2, 1, prom_k );
	ma.pon_e( 2, 2, prom_uno );

	mb.pon_e(1,1, prom_k_yk );
	mb.pon_e(2,1, prom_yk );

	res:= ma.Escaler( mb );
	if ( abs( res ) < AsumaCero ) then
		raise Exception.Create('TVectR.AproximacionLineal res= 0');

	a:= mb.e(1,1);
	b:= mb.e(2,1);
end;

end.
