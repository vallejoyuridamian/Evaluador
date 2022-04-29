unit uescala;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs;

type

    TEscala = class
      xInf, xSup: NReal;
      NDivs: integer;

      puntos: TDAOfNReal;
      x0, dx: NReal;


      constructor Create(xInf, xSup: NReal; NDivs: integer);
      function krOfx( x: NReal ): NReal;
      procedure Free;

      // completa el vector puntos de forma que el primero tiene xInf, el último
      // xSup y los intermedios un discretizado uniforme de ese rango.
      procedure DiscretizadoUniforme( xInf, xSup: NReal; NDivs: integer );

    end;


implementation


constructor TEscala.Create(  xInf, xSup: NReal; NDivs: integer  );
begin
  inherited Create;
  self.xInf:= xInf;
  self.xSup:= xSup;
  self.NDivs:= NDivs;
  DiscretizadoUniforme( xInf, xSup, nDivs );
end;

function TEscala.krOfx( x: NReal ): NReal;
var
  kr: NReal;
begin
  kr:= ( x - x0 ) / dx;
end;

procedure TEscala.Free;
begin

end;

// completa el vector puntos de forma que el primero tiene xInf, el último
// xSup y los intermedios un discretizado uniforme de ese rango.
procedure TEscala.DiscretizadoUniforme( xInf, xSup: NReal; NDivs: integer );
var
  k: integer;
begin
  x0:= xInf;
  setlength( puntos, NDivs+1 );

  dx:= ( xSup-xInf ) / NDivs;
  for k:= 0 to high( puntos ) do
      puntos[k]:= xInf + k * dx;
end;


end.

