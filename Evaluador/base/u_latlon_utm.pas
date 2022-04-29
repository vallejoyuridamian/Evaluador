unit u_latlon_utm;

{$mode delphi}

interface

uses
  Classes, SysUtils, Math;

type
  TEllipsoidRec = record
    Id: integer;
    Name: string;
    radius, ecc: double;
  end;

type
  TEllipsoid = array [1..23] of TEllipsoidRec;

const
  //  Conv = 111.2; // 1º = 111,2 km no Equador
  Ellipsoid: TEllipsoid =
    ((Id: 1; Name: 'Airy'; radius: 6377563; ecc: 0.00667054),
    (Id: 2; Name: 'Australian National'; radius: 6378160; ecc: 0.006694542),
    (Id: 3; Name: 'Bessel 1841'; radius: 6377397; ecc: 0.006674372),
    (Id: 4; Name: 'Bessel 1841 (Nambia)'; radius: 6377484; ecc: 0.006674372),
    (Id: 5; Name: 'Clarke 1866'; radius: 6378206; ecc: 0.006768658),
    (Id: 6; Name: 'Clarke 1880'; radius: 6378249; ecc: 0.006803511),
    (Id: 7; Name: 'Everest'; radius: 6377276; ecc: 0.006637847),
    (Id: 8; Name: 'Fischer 1960 (Mercury)'; radius: 6378166; ecc: 0.006693422),
    (Id: 9; Name: 'Fischer 1968'; radius: 6378150; ecc: 0.006693422),
    (Id: 10; Name: 'GRS 1967'; radius: 6378160; ecc: 0.006694605),
    (Id: 11; Name: 'GRS 1980'; radius: 6378137; ecc: 0.00669438),    // URUGUAY
    (Id: 12; Name: 'Helmert 1906'; radius: 6378200; ecc: 0.006693422),
    (Id: 13; Name: 'Hough'; radius: 6378270; ecc: 0.00672267),
    (Id: 14; Name: 'International'; radius: 6378388; ecc: 0.00672267),
    (Id: 15; Name: 'Krassovsky'; radius: 6378245; ecc: 0.006693422),
    (Id: 16; Name: 'Modified Airy'; radius: 6377340; ecc: 0.00667054),
    (Id: 17; Name: 'Modified Everest'; radius: 6377304; ecc: 0.006637847),
    (Id: 18; Name: 'Modified Fischer 1960'; radius: 6378155; ecc: 0.006693422),
    (Id: 19; Name: 'South American 1969'; radius: 6378160; ecc: 0.006694542),
    (Id: 20; Name: 'WGS 60'; radius: 6378165; ecc: 0.006693422),
    (Id: 21; Name: 'WGS 66'; radius: 6378145; ecc: 0.006694542),
    (Id: 22; Name: 'WGS-72'; radius: 6378135; ecc: 0.006694318),
    (Id: 23; Name: 'WGS-84'; radius: 6378137; ecc: 0.00669438));

C_Ellipsoid_WGS84 = 23;
C_Ellipsoid_URUGUAY = C_Ellipsoid_WGS84; // es igual al 11;

// Retorna la letra de la Zona UTM en base a la Latitud
function LetraDeZonaUTM(Lat: double): char;

// Retorna las coordenadas UTM dado el identificador de ellipsoide
// y la Latitud y Longitud en grados DEG.
procedure LatLonToUTM(var UTME, UTMN: double;
  var UTMZona: char;
  var UTMHuso: integer;
  RefEllipsoid: integer; Lat, Long: double);

// Calcula la Latitud y Longitud dado
// un Metodo_NorteSur de determinación del hemifério
// el identificador de ellipsoide
// y las coordenadas UTM

// El método de determinación del hemisfério puede ser 0, 1, 2, o 3 con
// el siguiente significado.
//Metodo_NorteSur define como será determinado el hemifério Norte o Sur.
// 0 : Una letra indicando la latitud acompaña la zona
//     (si no hay letra, se usará el método 3)
// 1 : Hemisfério Norte
// 2 : Hemisfério Sur
// 3 : El hemisferio será decidido en base a Northing (pontos próximos al Equador)

procedure UTMToLatLon(var Lat, Lon: double; MetodoNS: byte;
  RefEllipsoid: integer; UTME, UTMN: double; UTMZona: char; UTMHuso: integer );



implementation

                //00000000011111111112
const           //12345678901234567890
  LetrasDeZona = 'CDEFGHJKLMNPQRSTUVWX';

function LetraDeZonaUTM(Lat: double): char;
var
  k: integer;

begin
  if ( Lat > 84 ) or ( Lat < -80 ) then
  begin
    result:= '?';
    exit;
  end;

  k:= trunc( ( Lat + 80 ) / 8.0 )+1;
  if k >= 20 then
  begin
    result:= 'X';
    exit;
  end;
  result:= LetrasDeZona[k];

end;



procedure LatLonToUTM(var UTME, UTMN: double; var UTMZona: char;
  var UTMHuso: integer; RefEllipsoid: integer; Lat, Long: double);

var
  a, eccSquared, k0, LongOrigin, eccPrimeSquared, LongTemp, LatRad, LongRad, deg2rad,
  LongOriginRad, N, T, C, A2, M: double;
  ZoneNumber: integer;
begin
  //converts lat/long to UTM coords.  Equations from USGS Bulletin 1532
  //East Longitudes are positive, West longitudes are negative.
  //North latitudes are positive, South latitudes are negative
  //Lat and Long are in decimal degrees
  //Written by Chuck Gantz- chuck.gantz@globalstar.com
  //Translated from C++ by Rodrigo Dias - rodrigo1406@gmail.com

  //  FourthPI:=Pi/4;
  deg2rad := Pi / 180;
  //  rad2deg:=180/Pi;

  a := Ellipsoid[RefEllipsoid].radius;
  eccSquared := Ellipsoid[RefEllipsoid].ecc;
  k0 := 0.9996;

  //Make sure the longitude is between -180.00 .. 179.9
  LongTemp := (Long + 180) - Trunc((Long + 180) / 360) * 360 - 180;
  LatRad := Lat * deg2rad;
  LongRad := LongTemp * deg2rad;

  ZoneNumber := Trunc((LongTemp + 180) / 6) + 1;
  if (Lat >= 56) and (Lat < 64) and (LongTemp >= 3) and (LongTemp < 12) then
    ZoneNumber := 32; //???

  // Special zones for Svalbard
  if (Lat >= 72) and (Lat < 84) then
  begin
    if (LongTemp >= 0) and (LongTemp < 9) then
      ZoneNumber := 31
    else
    if (LongTemp >= 9) and (LongTemp < 21) then
      ZoneNumber := 33
    else
    if (LongTemp >= 21) and (LongTemp < 33) then
      ZoneNumber := 35
    else
    if (LongTemp >= 33) and (LongTemp < 42) then
      ZoneNumber := 37;
  end;

  LongOrigin := (ZoneNumber - 1) * 6 - 180 + 3; //+3 põe a origem no meio da zona
  LongOriginRad := LongOrigin * deg2rad;

  UTMZona :=  LetraDeZonaUTM(Lat);
  UTMHuso:= ZoneNumber;

  eccPrimeSquared := eccSquared / (1 - eccSquared);

  N := a / sqrt(1 - eccSquared * sin(LatRad) * sin(LatRad));
  T := tan(LatRad) * tan(LatRad);
  C := eccPrimeSquared * cos(LatRad) * cos(LatRad);
  A2 := cos(LatRad) * (LongRad - LongOriginRad);

  M := a * ((1 - eccSquared / 4 - 3 * eccSquared * eccSquared / 64 -
    5 * eccSquared * eccSquared * eccSquared / 256) * LatRad -
    (3 * eccSquared / 8 + 3 * eccSquared * eccSquared / 32 +
    45 * eccSquared * eccSquared * eccSquared / 1024) * sin(2 * LatRad) +
    (15 * eccSquared * eccSquared / 256 + 45 * eccSquared * eccSquared * eccSquared / 1024) *
    sin(4 * LatRad) - (35 * eccSquared * eccSquared * eccSquared / 3072) * sin(6 * LatRad));

  UTME := k0 * N * (A2 + (1 - T + C) * A2 * A2 * A2 / 6 + (5 - 18 * T + T * T + 72 * C -
    58 * eccPrimeSquared) * A2 * A2 * A2 * A2 * A2 / 120) + 500000;

  UTMN := k0 * (M + N * tan(LatRad) * (A2 * A2 / 2 + (5 - T + 9 * C + 4 * C * C) * A2 * A2 * A2 * A2 / 24 +
    (61 - 58 * T + T * T + 600 * C - 330 * eccPrimeSquared) * A2 * A2 * A2 * A2 * A2 * A2 / 720));

  if Lat < 0 then
    UTMN := UTMN + 10000000; // offset de 10 mil km para o hemisfério sul
end;

procedure UTMToLatLon(var Lat, Lon: double; MetodoNS: byte;
  RefEllipsoid: integer; UTME, UTMN: double; UTMZona: char; UTMHuso: integer);

var
  a, eccSquared, k0, LongOrigin, eccPrimeSquared, rad2deg, e1, mu, phi1Rad, x, y,
  N1, T1, C1, R1, D, M: double;
  ZoneNumber: integer; // 1 para norte, 0 para sul
  ZoneLetter: string;


  function Nums(T: string): integer;
  var
    I, N: integer;
    R: string;
  begin
    I := 1;
    N:= length( T );
    R := '';
    while ( I <= N ) and (T[I] in [' ', 'a'..'z', 'A'..'Z']) do
      Inc(I);
    while ( I <= N ) and (T[I] in ['0'..'9']) do
    begin
      R := R + T[I];
      Inc(I);
    end;
    Result := StrToInt(R);
  end;

  function Letras(T: string): string;
  var
    I, N: integer;

  begin
    I := 1;
    N:= length( T );
    Result := '';
    while ( I <= N ) and ( T[I] in [' ', '0'..'9'] ) do
      Inc(I);
    while ( I <= N ) and (T[I] in ['a'..'z', 'A'..'Z']) do
    begin
      Result := Result + T[I];
      Inc(I);
    end;
  end;

begin
  //converts UTM coords to lat/long.  Equations from USGS Bulletin 1532
  //East Longitudes are positive, West longitudes are negative.
  //North latitudes are positive, South latitudes are negative
  //Lat and Long are in decimal degrees.
  //Written by Chuck Gantz- chuck.gantz@globalstar.com
  //Translated from C++ by Rodrigo Dias - rodrigo1406@gmail.com
  //MetodoNS define como será lido o hemisfério Norte ou Sul:
  // 0 : Uma letra indicando a latitude acompanha a zona
  //     (se não houver a letra, será usado o método 3)
  // 1 : Hemisfério Norte
  // 2 : Hemisfério Sul
  // 3 : O hemisfério será decidido com base no Northing (pontos próximos ao Equador)

  rad2deg := 180 / Pi;

  a := Ellipsoid[RefEllipsoid].radius;
  eccSquared := Ellipsoid[RefEllipsoid].ecc;
  k0 := 0.9996;

  e1 := (1 - sqrt(1 - eccSquared)) / (1 + sqrt(1 - eccSquared));

  x := UTME - 500000; // tira offset de 500 km da longitude
  y := UTMN;

  ZoneNumber := UTMHuso;
  ZoneLetter := UTMZona;
  if (MetodoNS = 0) and (ZoneLetter = '') then
    MetodoNS := 3;

  case MetodoNS of
    0:
      if UpCase(ZoneLetter[1]) < 'N' then
        Y := Y - 10000000; // tira offset de 10 mil km usado para o hemisfério sul
    2:
      Y := Y - 10000000; // tira offset de 10 mil km usado para o hemisfério sul
    3:
      if Y > 5000000 then
        Y := Y - 10000000; // tira offset de 10 mil km usado para o hemisfério sul
  end;

  LongOrigin := (ZoneNumber - 1) * 6 - 180 + 3; // +3 põe a origem no meio da zona

  eccPrimeSquared := (eccSquared) / (1 - eccSquared);

  M := y / k0;
  mu := M / (a * (1 - eccSquared / 4 - 3 * eccSquared * eccSquared / 64 - 5 * eccSquared *
    eccSquared * eccSquared / 256));

  phi1Rad := mu + (3 * e1 / 2 - 27 * e1 * e1 * e1 / 32) * sin(2 * mu) +
    (21 * e1 * e1 / 16 - 55 * e1 * e1 * e1 * e1 / 32) * sin(4 * mu) +
    (151 * e1 * e1 * e1 / 96) * sin(6 * mu);

  N1 := a / sqrt(1 - eccSquared * sin(phi1Rad) * sin(phi1Rad));
  T1 := tan(phi1Rad) * tan(phi1Rad);
  C1 := eccPrimeSquared * cos(phi1Rad) * cos(phi1Rad);
  R1 := a * (1 - eccSquared) / power(1 - eccSquared * sin(phi1Rad) * sin(phi1Rad), 1.5);
  D := x / (N1 * k0);

  Lat := phi1Rad - (N1 * tan(phi1Rad) / R1) *
    (D * D / 2 - (5 + 3 * T1 + 10 * C1 - 4 * C1 * C1 - 9 * eccPrimeSquared) * D * D * D * D / 24 +
    (61 + 90 * T1 + 298 * C1 + 45 * T1 * T1 - 252 * eccPrimeSquared - 3 * C1 * C1) * D * D * D * D * D * D / 720);
  Lat := Lat * rad2deg;

  Lon := (D - (1 + 2 * T1 + C1) * D * D * D / 6 + (5 - 2 * C1 + 28 * T1 - 3 * C1 * C1 + 8 * eccPrimeSquared + 24 * T1 * T1) * D *
    D * D * D * D / 120) / cos(phi1Rad);
  Lon := LongOrigin + Lon * rad2deg;
end;

end.
