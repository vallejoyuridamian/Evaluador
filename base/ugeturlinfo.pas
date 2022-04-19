unit ugeturlinfo;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, ufechas, uauxiliares, uRobotHttpPost;

type


(***

Hace un GET sobre la url

Por ejemplo:

http://pronos.adme.com.uy/getcono.php?dtIniSim=42850.875

y espera una respuesta en el formato:

+INICIO
VERSION: 1
HorasEntreMuestras: 1.0
fecha_primera_muestra: 2017-04-25 10:00
HORA:   PronoEol  PronoSol Temp
-10 0.074635934964669 0.326114490246161 18.3
-9 0.0935563140377497 0.277435273314134 19.1

....
....
+FIN

Para interpretar la respuesta crea un stringlist (res) entre la línea siguiente a
+INICIO y +FIN

ignora la primer línea de la lista
de la seguna extrae la fecha de la primera puestra (formato iso)y la convierte a DateTime
de la tercera extrae los encabezados

dimensiona las series con count(res) - 3 y lee la información

Atención, en la url puede ir información para determinar la hora a partir
de la cual se requiere el pronóstico, el resultado debiera tener como
fecha_primera_muestra un valor <= que el valor especificado como parámetro
de la consulta.

La primer columna es considerada como una marca de tiempos. Puede ser un ordinal
o un DateTiem o cualquir número. En el ejemplo es un ordinal que da la hora
con un 0 en la hora anterior a la del pronóstico requerido. Está pensado
para que quien llame utilice a partir del valor 1 en adelante.

***)


  TRecConoPronosticos = class
    version: integer;
    dtPrimeraMuestra: TDateTime;
    HorasEntreMuestras: double;
    nombres: TStringList;
    series: TDAOfDAofNReal;
    constructor Create(url: string);
    destructor Destroy; override;
  end;


implementation


{ TRecProno_EOL_SOL_TEMP }

constructor TRecConoPronosticos.Create(url: string);
var
  rbthttp: TRobotHttpPost;
  fecha_primera_muestra: string;
  res: TStringList;
  rs, pal: string;
  Nombre: string;
  kSerie, kPaso: integer;
  NSeries, NPasos: integer;

  klin: integer;

  function rdln: boolean;
  begin
    if klin < res.Count then
    begin
      rs := res[klin];
      Inc(klin);
      Result := True;
    end
    else
    begin
      rs := '';
      Result := False;
    end;
  end;

begin
  setSeparadoresGlobales;

  rbthttp := TRobotHttpPost.Create( Url, '+INICIO', '+FIN');
  res := rbthttp.post('GET');
  rbthttp.Free;
  klin := 0;

  rdln;
  pal := nextpal(rs);
  if pal = '' then
  begin
    version := 0;
    HorasEntreMuestras := 1.0;
  end
  else
  begin
    rdln;
    pal := nextpal(rs);
    version := nextint( rs );
  end;

  rdln;
  nextpal(rs);
  fecha_primera_muestra := trim(rs);

  dtPrimeraMuestra := IsoStrToDateTime(fecha_primera_muestra);

  rdln; // contiene los nombres
  nombres := TStringList.Create;
  while rs <> '' do
  begin
    nombre := nextpal(rs);
    nombres.Add(nombre);
  end;

  nSeries := nombres.Count;
  setlength(series, nSeries);
  nPasos := res.Count - klin;

  for kSerie := 0 to high(series) do
    setlength(series[kSerie], nPasos);

  for kPaso := 0 to NPasos - 1 do
  begin
    rdln;
    for kSerie := 0 to NSeries - 1 do
      series[kSerie][kPaso] := nextfloat(rs);
  end;

  setSeparadoresLocales;
end;

destructor TRecConoPronosticos.Destroy;
var
  kSerie: integer;
begin
  for kSerie := 0 to high(series) do
    setlength(series[kSerie], 0);

  setlength(series, 0);
  nombres.Free;
  inherited Destroy;
end;

end.

