unit uinterpolador_nlineal;
(*rch@20161230
Implementación de un Interpolador N-lineal en un espacio de R^n
( es lo mismo que el Bi-lineal del espacio 2d llevado a N-lineal )

Dado un conjunto de por lo menos n Puntos de un espacio de R^n y
el valor de una propiedad M en cada uno de los puntos, el Interpolador
bi-lineal aproxima el valor de M en cualquier punto P
por una fórmula del tipo:

m = At * ExpandNLineal( P )

Siendo ExpandNLineal( P ) un vector de 2^n coeficientes
formados por el producto de (1+x1)*(1+x2)*.... *(1+xn)
donde x1, ... xn son las coordenadas de P.

Para el cálculo de la matriz A se utiliza mínimos cuadrados
sbre el conjunto de N Puntos con los respectivos valores
de M dados para entrenamiento del interpolador.

*)
{$mode delphi}

interface

uses
  Classes, SysUtils, math, xmatdefs, matreal;


type

  { TInterpoladorNLineal }

  TInterpoladorNLineal = Class
    A: TVectR;
    constructor Create(Puntos: TList; M: TVectR);
    function ValM( P: TVectR ): NReal;
    procedure Free;
  end;


(* Dado un vector de coordenadas x1, x2, x3 ... xn retorna el vector
con los 2^n coeficientes de (1+x1)*(1+x2)*.... *(1+xn)
*)
function ExpandNLineal( X: TVectR ): TVectR;


implementation

function ExpandNLineal( X: TVectR ): TVectR;
var
 res: TVectR;
 NRes: integer;
 k, j, hBase: integer;
begin
  NRes:= round( power( x.n, 2) );
  res:= TVectR.Create_Init(  NRes );
  res.pon_e( 1, 1 );
  hBase:= 1;
  for j:= 1 to  x.n do
  begin
   for k:= 1 to hBase do
     res.pon_e( hBase + k, res.e(k)* x.e(j) );
   hBase:= hBase * 2;
  end;
  result:= res;
end;

{ TInterpoladorNLineal }

constructor TInterpoladorNLineal.Create( Puntos: TList;
  M: TVectR);
var
 X: TVectR;
 P: TVectR;
 nx: integer;
 sa, sb: TMatR;
 kPunto, kFil, jCol: integer;
 flg_invertible: boolean;
 exp10: integer;

begin
  inherited Create;
  if M.n < 1 then
    raise Exception.Create( 'TInterpoladorNLineal, error! datos vacíos' );

  P:= Puntos[0];
  nx:= round( power( P.n , 2 ) );
  // Primero chequeamos que sean coherentes los datos
  if Puntos.count < nx then
    raise Exception.Create( 'TInterpoladorNLineal, error de datos Count(Puntos): '
      +IntToStr( Puntos.Count )+' <  2^Dim(M): '
      +IntToStr( nx ) );

  // Armado del sistema para resolución por mínimos cuadrados.
  sa:= TMatR.Create_Init( nx, nx );
  sa.ceros;
  sb:= TMatR.Create_init( nx, 1 );
  sb.ceros;

  for kPunto:= 0 to Puntos.count - 1 do
  begin
   P:= Puntos[kPunto];
   X:= ExpandNLineal( P );
   for kFil:= 1 to nx do
   begin
    for jCol:= kFil to nx do
      sa.acum_e( kFil, jCol, x.e( kFil ) * x.e( jCol ) );
    sb.acum_e( kFil, 1, x.e( kFil ) * m.e( kPunto +1 ) );
   end;
   X.Free;
  end;

  // simetrizamos la matriz sa
  for kFil:= 2 to nx do
   for jCol:= 1 to kFil - 1 do
     sa.pon_e( kFil, jCol, sa.e( jCol, kFil ));

  sa.Escaler( sb, flg_invertible, exp10 );
  if not flg_invertible then
    raise Exception.Create( 'TInterpolador_NLIN ... sistema no invertible.' );

  A:= TVectR.Create_init( nx );
  for kFil:= 1 to nx do
    A.pon_e( kFil, sb.e( kfil, 1 ) );
  sb.Free;
  sa.Free;

end;

function TInterpoladorNLineal.ValM(P: TVectR): NReal;
var
  X:TVectR;
begin
  X:= ExpandNLineal( P );
  result:= A.PEV( X );
  X.Free;
end;

procedure TInterpoladorNLineal.Free;
begin
  A.Free;
  inherited Free;
end;

end.

