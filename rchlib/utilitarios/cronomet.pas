{+doc
+NOMBRE: cronomet
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:def. objeto (TCrono). Sive de cronometro para medir tiempos.
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit cronomet;

interface
(******************************)
(* Devuelve el tiempo transcurrido en segundos  *)
uses
 (* antiguo
  {$I xCRT},
  {$I xDOS},
  *)
  SysUtils,
  xMatDefs;

type
  TCrono = object
    tac, tarr: NReal;
    procedure borre;
    procedure pare;
    procedure cuente;
    function cuenta: NReal;
  end;

  // rch@20121111
  // Defino una clase más moderna
  TCronometro = class
    dtum, dts: TDateTime;
    acums: array of double;
    cnt: array of integer;

    // Crea un array de nElementos de cronómetros y comienza a contar
    // el tiempo.
    constructor Create(nElementos: integer);
    procedure Free;


    procedure Marca(k: integer);
    procedure writeln;
  end;

implementation




procedure TCrono.borre;
begin
  tac := 0;
  tarr := 0;
end;

procedure TCrono.cuente;
begin
  TArr := now() * 24 * 3600;
end;

procedure TCrono.pare;
var
  temp: NReal;
begin
  Temp := now() * 24 * 3600;
  tarr := temp - tarr;
  tac := tac + tarr;
end;

function TCrono.cuenta: NReal;
begin
  cuenta := tac;
end;


constructor TCronometro.Create(nElementos: integer);
begin
  setlength(acums, nElementos);
  setlength(cnt, nElementos);
  dtum := now;
  dts := 0;
end;

procedure TCronometro.Free;
begin
  setlength(acums, 0);
  setlength(cnt, 0);
end;

procedure TCronometro.Marca(k: integer);
begin
  dts := now;
  acums[k] := acums[k] + dts - dtum;
  dtum := dts;
end;

procedure TCronometro.writeln;
var
  k: integer;

begin
  system.writeln('Cronometro | diff[ms] ');
  for k := 1 to high(acums) do
    system.writeln(k: 4, ' : ', trunc(acums[k] * 24 * 3600 * 1000));

end;

end.
