unit uradiacionsolar;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, ufechas;

const
  ConstanteSolar_Ics=1.367;  // kW/m2


// Radiación Solar Extraterrestre sobre plano horizontal en kW/m2
function RadiacionSolarExtraterrestrePlanoHorizontal_Ih0(
  dt_LocalTime: TDateTime;
  Latitud: NReal; // -35
  Longitud: NReal; // -54
  husoHorario_UTC: NReal // -3 para Uruguay
  ): NReal;


implementation

//irradiación extraterrestre sobre un plano horizontal (kW/m2)
function RadiacionSolarExtraterrestrePlanoHorizontal_Ih0(
    dt_LocalTime: TDateTime;
    Latitud: NReal; // -35
    Longitud: NReal; // -54
    husoHorario_UTC: NReal // -3
    ): NReal;

var
  parteDelAnio: NReal;
  gamma:NReal; // Parte del año en radianes.
  Fn:NReal; //factor orbital
  delta: NReal; //declinación solar
  w:NReal;   //angulo horario
  E:NReal;   //constante de la ecuación del tiempo en minutos
  latitud_rad:NReal;  //latitud en radianes

begin
  latitud_rad:= latitud*2*pi/360;
  parteDelAnio:= frac(dt_LocalTime /365.2425 );
  gamma:=2* pi * parteDelAnio;
  delta:=0.006918-0.399912* cos (gamma)+0.070257* sin (gamma)-0.006758*cos(2*gamma)+0.000907*sin(2*gamma)-0.002697*cos(3*gamma)+0.00148*sin(3*gamma);
  Fn:=1+0.033*cos(gamma);
  E:= 229.18*(0.0000075+0.001868*cos(gamma)-0.032077*sin(gamma)-0.014615*cos(2*gamma)-0.04089*sin(2*gamma));
  w:= 2*pi*frac( dt_Localtime+(longitud/15.0 -husoHorario_UTC+E/60-12)/24);
  result:=ConstanteSolar_Ics * Fn *(cos(delta)*cos(latitud_rad)*cos(w)+sin(delta)*sin(latitud_rad));
end;

end.

