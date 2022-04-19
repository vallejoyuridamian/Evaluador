(*
En esta unidad implementamos una función que permite calcular el coeficiente
de evaporación según la época del año (para tener en cuenta la temperatura media)
y una variable booleana HumedadNormal que indica si estamos en situación normal de humedadad TRUE
o si estamos en una supersecha FALSE


La idea es que si el aporte es superior al de probabilidad de exedencia 15%
se pase HumedadNormal= TRUE si es inferior FALSE.

*)
unit uevapUruguay;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses
  uAuxiliares, xMatDefs;


(* Se supone que el Qa_MuySeco corresponde a aquel valor de aportes
que no es superado con probabilidad 20%.

Se supone que la densidad de probabilidad es del tipo p(Qa)= alfa * exp( -alfa *Qa )

El valor esperado int(0, inf, p(x) *x *dx ) = 1/alfa

.: alfa = 1 / Qa_esperado

int( 0, Qa_MuySeco, p(x) * x * dx ) = 0.2

.: 0.2 = 1- exp( -alfa * Qa_MuySeco )
.: -alfa * Qa_MuySeco = ln( 0.8 )
.: Qa_MuySeco = Qa_esperado * 0.223143551


En el caso de Bonete, Qa_esperado = 540m3/s
.: alfa= 1.85E-3
.: Qa_MuySeco= 120 m3/s

¿Cuál es el Qx / P(Q > Qx) = 20%?

1- exp( -alfa * Qx ) = 0.8

Si Qa_MuySeco es el de probabilidad de 20%,
- alfa = 1/Qa_MuySeco * ln( 0.8 );

Qx/ Qa_MuySeco * ln( 0.8) = ln( 0.2 )

Qx / Qa_MuySeco = ln( 0.2 )/ln( 0.8 ) = 7.21


La función calcula el cociente Qa / Qa_MuySeco y si es < 1 retorna
el coeficiene a MuySeco, si es > que 7.21 retorna el coeficiente de MuyHumedo
y en el medio hace una interpolación lineal entre ambas tablas.

Retorna el coeficiente de evaporación en m/s.
Al multiplicar este coeficiente por el área en m2 se obtienen el caudal de
evaporación en m3/s.

Para que la interponación tenga sentido, el Qa_muyseco debiera ser el que corresponde
al caudal medio semanal que no es excedido con probabilidad 20% (o que es excedido con
probabilidad 80%).
*)
function CoeficienteDeEvaporacion_mps( kMesDelAnio: integer; Qa, Qa_muyseco: NReal ): NReal;


implementation

type
	TCoefEvap= array[1..12] of NREal;


{$IFDEF EVAP_DATOSVIEJOS}
type
	COEFS_h0: TCoefEvap= (
		8.59E-08,	7.03E-08,	5.41E-08,	3.47E-08,	2.43E-08,	1.54E-08,	1.68E-08,
		2.43E-08,	3.09E-08,	4.48E-08,	6.17E-08,	8.59E-08 );
	COEFS_h1: TCoefEvap= (
		4.85E-08,	3.72E-08,	1.68E-08,	9.65E-09,	9.33E-09,	9.65E-09,	9.33E-09,
		9.65E-09,	1.93E-08,	2.61E-08,	3.86E-08,	6.35E-08 );

function CoeficienteDeEvaporacion_mps( kMesDelAnio: integer; Qa, Qa_muyseco: NReal ): NReal;
begin
  if Qa > Qa_muyseco then
    result:= COEFS_h1[kMesDelAnio]
  else
    result:= COEFS_h0[kMesDelAnio]
end;
{$ELSE}

type
  TCoefEvapPorEstacion= array[ TEstacion ] of NReal;

var
	COEFS_h0, COEFS_h1: TCoefEvap;

(* Datos de meteorología
Evap [mm]	Max	Mín *)
const
//  Evap_Prom_: TCoefEvapPorEstacion = ( 468.0, 286.7, 207.0, 333.8 );
  Evap_Min_: TCoefEvapPorEstacion = ( 437.0, 224.0, 184.0, 311.0 );
  Evap_Max_: TCoefEvapPorEstacion = ( 569.0, 364.0, 276.0, 440.0 );



function CoeficienteDeEvaporacion_mps( kMesDelAnio: integer; Qa, Qa_MuySeco: NReal  ): NReal;
var
  alfa: NReal;
begin
  if Qa_MuySeco <= 1 then
  begin // impongo evap húmedo
    result:= COEFS_h1[kMesDelAnio];
    exit;
  end;

  alfa:= Qa / Qa_MuySeco;
  if alfa <= 1 then // estoy en el 20% más seco
    result:= COEFS_h0[kMesDelAnio]
  else if alfa >= 7.21 then // estoy en el 20% más húmedo
    result:= COEFS_h1[kMesDelAnio]
  else
  begin  // en el 60% intermedio interpolamos.
    alfa:= ( alfa - 1.0 ) / (7.21 - 1.0);
    result:= (1-alfa)*COEFS_h0[kMesDelAnio] + alfa*COEFS_h1[kMesDelAnio];
  end;
end;

(* Carga la información original disponible en mm/trimestre a m/s *)
procedure InicializarCoeficientesDeEvaporacion;
var
  kmes: integer;
begin
  for kmes := 1 to 12 do
  begin
      COEFS_h0[kmes]:= Evap_max_[ EstacionOfMes( kmes ) ]/(3600*24*365/4*1000.0);
      COEFS_h1[kmes]:= Evap_min_[ EstacionOfMes( kmes ) ]/(3600*24*365/4*1000.0);
  end;
end;
{$ENDIF}

begin
{$IFNDEF EVAP_DATOSVIEJOS}
  InicializarCoeficientesDeEvaporacion
{$ENDIF}

end.
