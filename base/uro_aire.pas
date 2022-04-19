unit uro_aire;

{$mode delphi}
{$DEFINE r_CATALDO}
interface

uses
  Classes, SysUtils, Math, xMatDefs;

const
  // Densidad del aire de referencia para las curavs de los aerogeneradores.
  ro_BASE = 1.225; // kg/m3

// /  Densidad del aire [kg/m3]  formula del CIPM-2007 simplificada
function ro_aire(Temp_grC, Pre_hPa, HumRel_p100: NReal): NReal;

// Potencia del viento en MW por m2 de roto. [MW/m2]
function pv3Ofv( v_mps, ro_aire: NReal ): NReal;

// Velocidad del viento. [m/s].
function vOfpv3( pv3, ro_aire: NReal ): NReal;


// Multiplicador de la curva de potencia por efecto de la densidad del aire
function fcp_ro( ro_aire: NReal ): NReal;
function Ajuste_Cp_ro( ro: NReal ): NReal;  // sinónimo de la anterior

// Dada una velocidad y una densidad, calcula la velocidad equivalente a la densidad de referencia.
function fcv_ro( ro_aire: NReal ): NReal;

implementation


function fcp_ro(ro_aire: NReal): NReal;
begin
  {$IFDEF r_CATALDO}
  result:=ro_aire/ro_BASE;
  {$ELSE}
  result:= (1-exp(-2.17*ro_aire))/(1-exp(-2.17*ro_BASE));
  {$ENDIF}
end;

function Ajuste_Cp_ro( ro: NReal ): NReal;
begin
  result:= fcp_ro( ro );
end;


function fcv_ro(ro_aire: NReal): NReal;
begin
  result:= power( ro_aire / ro_BASE , 1.0/3.0 );
end;

function pv3Ofv( v_mps, ro_aire: NReal  ): NReal;
begin
  result:= 0.5 * ro_aire  * power( v_mps, 3 ) /1.0E6;
end;

function vOfpv3( pv3, ro_aire: NReal  ): NReal;
var
  res: NReal;
begin
   res := pv3/(0.5 * ro_aire )*1.0E6;
   result:= power( res, 1.0/3.0 )
end;



//  formula del CIPM-2007 simplificada
function ro_aire(Temp_grC, Pre_hPa, HumRel_p100: NReal): NReal;
var ro:NReal;
begin
  ro := (0.34848 * Pre_hPa - 0.009 * HumRel_p100 * exp(0.061 * Temp_grC)) /
    (273.16 + Temp_grC);

  if (ro<1.1) or (ro>1.3) then
    ro:=1.18; //PS y JFP: Valor medio de ro para evitar valores fuera de rango.

  Result:=ro;
end;




end.

