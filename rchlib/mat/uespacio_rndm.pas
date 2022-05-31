unit uespacio_rndm;
(* rch@2012-04-06 :> Viernes Santo

Implementación de vectores de un espacio de N dimensiones reales y M discretas.
Es para usar en el reductor de Estado de un sistema.
La descripción del estado tiene variables Continuas y Discretas y por eso
se preveé soporte para los dos espacios.


*)
interface

uses
  Classes, SysUtils,AlgebraC, xMatDefs, MatCPX, IntPoint;

type

TVector_Estado = class
  xr: TDAOfNReal;
  xd: TDAOfNInt;
  constructor create( nContinuas, nDiscretas: integer );
  procedure Free;
end;

// hace el producto escalar de la parte real de los vectores
function producto_escalar_r( v1, v2: TVector_Estado ): NReal;

// hace el producto escalar de la parte discreta de los vectores
function producto_escalar_d( v1, v2: TVector_Estado ): NReal;


TProyector_2D = class
  Origen: TVector_Estado;
  vr, vi: TVector_Estado;

  constructor Create( xOrigen, xvr, xvi: TVector_Estado );
  function Proyectar( x: TVector_Estado ): NComplex;
  procedure Free;
end;


implementation



constructor TVector_Estado.create( nContinuas, nDiscretas: integer );
begin
  setlength( xr, nContinuas );
  setlength( xd, nDiscretas );
end;

procedure TVector_Estado.Free;
begin
  setlength( xr, 0 );
  setlength( xd, 0 );
end;




function producto_escalar_r( v1, v2: TVector_Estado ): NReal;
var
  a: NReal;
  k: integer;
begin
  a:= 0;
  for k:= 0 to nContinuas -1 do
    a:= a + v1.xr[ k ] * v2.xr[ k ];
  result:= a;
end;


function producto_escalar_d( v1, v2: TVector_Estado ): NReal;
var
  a: NReal;
  k: integer;
begin
  a:= 0;
  for k:= 0 to nContinuas -1 do
    a:= a + v1.xd[ k ] * v2.xd[ k ];
  result:= a;
end;


constructor TProyector_2D.Create( xOrigen, xvr, xvi: TVector_Estado );
begin
  Origen:= xOrigen;
  vr:= xvr;
  vi:= xvi;
end;

function TProyector_2D.Proyectar( x: TVector_Estado ): NComplex;
var
  r, i: NReal;
begin
  r:= 0;
end;

procedure TProyector_2D.Free;
end;



end.


