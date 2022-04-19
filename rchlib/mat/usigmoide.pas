unit usigmoide;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs;

// result = 1/ (1 + exp( -x ))
function sigmoide(x: NReal): Nreal;

// y in (0,1)
// result = - ln( 1/y -1 )
function inv_sigmoide(y: NReal): NReal;

implementation


// y = 1/ (1 + exp( -x ))
function sigmoide(x: NReal): Nreal;
begin
  if x < -10 then
    Result := -4.53978687024344E-04 / x
  else if x > 10 then
    Result := 1 - 4.53978687023904E-04 / x
  else
    Result := 1 / (1 + exp(-x));
end;

// y in (0,1)
// x = - ln( 1/y -1 )
function inv_sigmoide(y: NReal): NReal;
var
  residuo: NReal;
begin
  if y < 4.53978687024344E-04 then
    if y < 1e-25 then
      Result := -4.53978687024344E+020
    else
      Result := -4.53978687024344E-04 / y
  else if y > (1 - 4.53978687024344E-05) then
  begin
    residuo := (1 - y);
    if residuo < 1e-25 then
      Result := 4.53978687024344E+020
    else
      Result := 4.53978687023904E-04 / residuo;
  end
  else
    Result := -ln(1 / y - 1);
end;

end.

