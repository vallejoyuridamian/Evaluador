unit uhistograma;

interface

type
  TDArrOfInteger= array of integer;

  THistograma = class
			registro: TDArrOfInteger;
			xMin, xMax, ampInt: double;
			minFuera, maxFuera: double;
			minimo_x, maximo_x: double;
			cantInt,
      cantMenores,
      cantMayores,
      cantTotal: integer;

			constructor Create (xMin, xMax: double; cantInt: integer);
			procedure Registrar (valor:double; peso:integer); overload;
			procedure Registrar (valor:double ); overload;
			procedure EscribirATexto(var archSalida:TextFile);

      function x_delArea( area: double ): double;
      function AreaHasta_x( x: double ): double;
      function valorEsperado: double;

// k va de 0..CantInt-1
      function xInicioIntervalo( k: integer ): double;
      function xFinIntervalo( k: integer ): double;

      procedure Free; virtual;

		private
			procedure ActualizarMin(valor:double);
			procedure ActualizarMax(valor:double);
			procedure	ActualizarPuntasDentro(valor:double);
 end;

TSerieHistograma = class
  h: array of THistograma;
	constructor Create (xMin, xMax: double; cantInt: integer; CantidadDePasos: integer);
  procedure Free; virtual;
end;

implementation


constructor Thistograma.Create(
	xMin, xMax: double; cantInt: integer );

begin
	inherited create;
	self.xMin:= xMin;
	self.xMax:=xMax;
	self.cantInt:= cantInt;
	self.ampInt:= (xMax - xMin)/cantInt;
	self.cantMenores:= 0;
	self.cantMayores:= 0;
	self.cantTotal:= 0;
	self.minFuera:= 1E50;
	self.maxFuera:= -1E50;
	minimo_x:= 1e50;
	maximo_x:= -1e50;
	SetLength(self.registro, cantInt);
end;

procedure THistograma.Free;
begin
	SetLength(self.registro, 0);
  inherited Free;
end;

function THistograma.xInicioIntervalo( k: integer ): double;
begin
  result:= xMin+ ampInt* k;
end;

function THistograma.xFinIntervalo( k: integer ): double;
begin
  result:= xMin+ ampInt* (k+1);
end;


function THistograma.valorEsperado: double;
var
  k: integer;
  acum: double;
  x: double;
begin
  acum:= 0;
  if minFuera <= xMin then
      acum:= acum + ( minFuera + xMin )/2* cantMenores / cantTotal;

  if maxFuera > xMax then
      acum:= acum + ( maxFuera + xMax )/2* cantMayores / cantTotal;

  x:= xMin + ampInt / 2.0 ;
  for k:= 0 to high( registro ) do
  begin
    acum:= acum + x * registro[k] / cantTotal;
    x:= x + ampInt;
  end;

  result:= acum;


end;


function THistograma.x_delArea( area: double ): double;
var
  cuenta: double;
  a, acumulado: integer;
  buscando: boolean;
  k: integer;
  x1: double;

begin
  cuenta:= area* cantTotal; // cuenta equivalente para el área
  if cuenta <= cantMenores then
  begin
    result:= xMin;
    exit;
  end;
  if cuenta >= cantTotal then
  begin
    result:= xMax;
    exit;
  end;

  buscando:= true;
  k:= 0;
  acumulado:= cantMenores;
  while buscando and ( k <= high( registro ) ) do
  begin
    acumulado:= acumulado + registro[k];
    if acumulado >= cuenta  then
      buscando:= false
    else
      inc( k );
  end;

  if buscando then
  begin
      result:= xMax;
      exit; // no debiera salir por acá, pero seguro ...
  end;

  // el acumulado al final del intervalo es superior a la cuenta,
  // pero al inicio es inferior.
  a:= acumulado - registro[k];
  x1:= xInicioIntervalo( k );
  result:= x1 + ampInt * (( cuenta - a ) / registro[k] );

end;

function THistograma.AreaHasta_x( x: double ): double;
var
  acumulado: integer;
  kr: double;
  k, i: integer;
begin
  if x < xMin then
  begin
    // los menores los supongo distribuidos uniformemente
    // entre minFuera (si es menor que xMin ) y xMin
    if minFuera > xMin then
      result:= 0
    else
      if x < minFuera then
         result:= 0
      else
        if abs( (minFuera - xMin )/ampInt ) > 1e-4 then
          result:= ( cantMenores / cantTotal ) * ( x - minFuera )/ (xMin-minFuera)
        else
          result:= cantMenores;
    exit;
  end;

  if x >= xMax then
  begin
    // los mayores los supongo distribuidos uniformemente
    // entre maxFuera (si es mayor que xMax ) y xMax
    if maxFuera > xMin then
      result:= 0
    else
      if x > maxFuera then
         result:= 0
      else
        if abs( (maxFuera - xMax )/ampInt ) > 1e-4 then
          result:= ( cantMayores / cantTotal ) * ( x - xMax )/ (maxFuera-xMax)
        else
          result:= cantMayores;
    exit;
  end;


  kr:= ( x - xmin ) / ampInt;
  k:= trunc( kr );
  if k < 0 then
  begin
    result:= CantMenores;
    exit;
  end;

  if k > high( registro ) then
  begin
    result:= CantMayores;
    exit;
  end;


  acumulado:= cantMenores;
  for i:= 0 to k-1 do
    acumulado:= acumulado + registro[k];

  result:= ( acumulado + registro[k] * ( x - xInicioIntervalo( k ) )/ampInt );
end;



procedure Thistograma.Registrar (valor:double; peso:integer);
var
	indicePrimRegistro: double;
	indiceRegistro: integer;

begin
	indicePrimRegistro:= ((valor - xMin)/self.ampInt);
	{ no lo trunque aca dado que me quedarían valores en 0 que
			 pueden ser tanto válidos como no, en funcion de como esté
			 definido el intervalo}
	cantTotal:= cantTotal + peso;
	if indicePrimRegistro < 0 then
	begin
		cantMenores:= cantMenores + peso;
		ActualizarMin(valor);
	end
			 else if indicePrimRegistro >= cantInt then
			 begin
					cantMayores := cantMayores + peso;
					ActualizarMax(valor);
			 end
			 else
				begin
					 ActualizarPuntasDentro(valor);
					 indiceRegistro:= trunc(indicePrimRegistro);
					 registro[indiceRegistro] := registro[indiceRegistro] + peso;
				end;
	 end;

procedure Thistograma.Registrar (valor:double );
begin
  registrar( valor, 1 );
end;

procedure Thistograma.EscribirATexto(var archSalida:TextFile);
		 var
{        archSalida:TextFile;}
				i:integer;
				xIni, xFin, acumulador:double;

		 begin
				{$I-}
				append(archSalida);
				{$I-}
				if ioresult <>0 then
					 rewrite(archSalida);

				{EscribirCabezales;}
				Writeln (archSalida, 'GENERADO POR PROGRAMA HISTOGRAMA');
				Writeln (archSalida, '');
				Writeln (archSalida, 'Intervalos de la forma: [ )');
				Writeln (archSalida, 'xMin:',#9,xMin:12:4);
				Writeln (archSalida, 'xMax:',#9,xMax:12:4);
				Writeln (archSalida, 'Cantidad de Intervalos:',#9,cantInt);
				Writeln (archSalida, 'Amplitud de Intervalos:',#9,ampInt:12:4);
				Writeln (archSalida, '');
				Writeln (archSalida, 'Cantidad de Valores:',#9,cantTotal);
				Writeln (archSalida, 'Cantidad de Mayores:',#9,cantMayores);
				Writeln (archSalida, 'Cantidad de Menores:',#9,cantMenores);
				Writeln (archSalida, 'Mínimo valor fuera:',#9,minFuera:12:4);
				Writeln (archSalida, 'Máximo valor fuera:',#9,maxFuera:12:4);
				Writeln (archSalida, 'Mínimo valor dentro:',#9,minimo_x:12:4);
				Writeln (archSalida, 'Máximo valor dentro:',#9,maximo_x:12:4);
				Writeln (archSalida, '');

				{EscribirCabezales de Tabla}
				Writeln (archSalida, #9,'xIni [',#9,'xFin )',#9,'Cant.Valores', #9,'Acumulado');
				xIni:= xMin;
				xFin:= xIni+ampInt;
				acumulador:= cantMenores;
				acumulador:= acumulador + registro[0];
				Writeln (archSalida, #9, xIni:12:4,#9, xFin:12:4,#9, registro[0],#9, acumulador:12:4);
				xIni:= xFin;
				For i:=1 to cantInt - 2 do
					 begin
								xFin:= xIni+ampInt;
								acumulador:= acumulador + registro[i];
								Writeln (archSalida, #9, xIni:12:4,#9, xFin:12:4,#9, registro[i],#9,acumulador:12:4);
								xIni:= xFin;
					 end;
			acumulador:= acumulador + registro[cantInt - 1];
			xFin:= xIni+ampInt;
			Writeln (archSalida, #9, xIni:12:4,#9, xFin:12:4,#9, registro[cantInt - 1],#9,acumulador:12:4);
			acumulador:= acumulador + cantMayores;
			Writeln (archSalida, #9, #9, #9, #9,acumulador:12:4);
			CloseFile(archSalida);


end;


procedure Thistograma.ActualizarMin(valor:double);

	begin
		if valor < self.minFuera then
			self.minFuera:= valor
	end;

procedure Thistograma.ActualizarMax(valor:double);

	begin
	 if valor > self.maxFuera then
			self.maxFuera:= valor
	end;

procedure	Thistograma.ActualizarPuntasDentro(valor:double);
begin
  if valor < self.minimo_x then
    self.minimo_x:= valor
  else if  valor > self.maximo_x then
    self.maximo_x:= valor;
end;



constructor TSerieHistograma.Create (xMin, xMax: double; cantInt: integer; CantidadDePasos: integer);
var
  k: integer;
begin
  inherited Create;
  setlength( h, CantidadDePasos );
  for k:= 0 to high( h ) do
      h[k]:= THistograma.Create( xMin, xMax, cantInt );
end;


procedure TSerieHistograma.Free;
var
  k: integer;
begin
  for k:= 0 to high( h ) do
      h[k].Free;
  inherited Free;
end;

end.


