unit particulas;

{
 rch@201506160911
   esto parece una prueba de Enzo iniciada en 2014 ... me parece que sin terminar.
}
interface

uses
  Classes, SysUtils, matreal, xmatdefs, StdCtrls, fddp;

type
  particula = class
    fitness: NReal;
    posicion: TDAofNReal;
    velocidad: TDAofNReal;
    mejorposicion: TDAofNReal;
    mejorfitness: NReal;
  public
    constructor Create(minX, maxX, minV, maxV: TDAofNReal);
    procedure asignar(fitness_, mejorfitness_: NReal;
      posicion_, velocidad_, mejorposicion_: TDAofNReal);
    function calcular_velocidad(w, c1, c2, r1, r2: NReal;
      minV, maxV, mejorposicionglobal: TDAofNReal): TDAofNReal;
    function calcular_posicion(minX, maxX: TDAofNReal): TDAofNReal;
    function calcular_fitness(): NReal;
    procedure mostrar(part: integer; tex: TMemo);
    procedure perturbar(fact: Nreal; minX, maxX: TDAofNReal);
    procedure Free();
  end;

var
  fmu: TMadreUniforme;

implementation




constructor particula.Create(minX, maxX, minV, maxV: TDAofNReal);
var
  i: integer;
  rando1, rando2: NReal;
  //  hr, min, sec, ms: word;
begin
  inherited Create;
  randomize;
  randomize;
  setlength(posicion, length(minX));
  setlength(velocidad, length(minX));
  setlength(mejorposicion, length(minX));
  for i := 0 to high(posicion) do
  begin
    //    DecodeTime(Time, hr, min, sec, ms);
    rando1 := fmu.rnd;
    rando2 := fmu.rnd;
    posicion[i] := (maxX[i] - minX[i]) * Rando1 + minX[i];
    velocidad[i] := (maxV[i] - minV[i]) * Rando2 + minV[i];
  end;
  //fitness:= calcular_fitness;
  vcopy(mejorposicion, posicion);
  //mejorfitness:=fitness;
end;

procedure particula.asignar(fitness_, mejorfitness_: NReal;
  posicion_, velocidad_, mejorposicion_: TDAofNReal);
begin
  fitness := fitness_;
  mejorfitness := mejorfitness_;
  vcopy(posicion, posicion_);
  vcopy(velocidad, velocidad_);
  vcopy(mejorposicion, mejorposicion_);
end;

function particula.calcular_velocidad(w, c1, c2, r1, r2: NReal;
  minV, maxV, mejorposicionglobal: TDAofNReal): TDAofNReal;
var
  i: integer;
begin
  for i := 0 to length(velocidad) - 1 do
  begin
    velocidad[i] := w * velocidad[i] + (c1 * r1 * (mejorposicion[i] - posicion[i])) +
      (c2 * r2 * (mejorposicionglobal[i] - posicion[i]));
    if velocidad[i] < minV[i] then
      velocidad[i] := minV[i];
    if velocidad[i] > maxV[i] then
      velocidad[i] := maxV[i];
  end;
  Result := velocidad;
end;

function particula.calcular_posicion(minX, maxX: TDAofNReal): TDAofNReal;
var
  i: integer;
begin
  for i := 0 to length(posicion) - 1 do
  begin
    posicion[i] := posicion[i] + velocidad[i];
    if posicion[i] < minX[i] then
      posicion[i] := minX[i];
    if posicion[i] > maxX[i] then
      posicion[i] := maxX[i];

  end;
  Result := posicion;
end;

function particula.calcular_fitness(): NReal;
var
  mejor, rest1, rest2: NReal;
begin
  mejor := sqr(posicion[0] - 5) + sqr(posicion[1] - 5) * sqr(sin(posicion[0]));
  rest1 := sqr(posicion[0]) + sqr(posicion[1]) - 16;
  rest2 := posicion[0];
  if rest1 <> 0 then
    mejor := mejor + 1e3 * sqr(rest1);
  if rest2 > 0 then
    mejor := mejor + 1e3 * sqr(rest2);
  if mejor < mejorfitness then
  begin
    mejorfitness := mejor;
    vcopy(mejorposicion, posicion);
  end;
  fitness := mejor;
  Result := mejor;
end;

procedure particula.mostrar(part: integer; tex: TMemo);
var
  j: integer;
begin
  for j := 0 to length(posicion) - 1 do
  begin
    tex.Append('Part: ' + IntToStr(part) + ' Pos: ' + floattostr(
      posicion[j]) + ' Vel: ' + floattostr(velocidad[j]) + ' Fit: ' +
      floattostr(fitness));
    //tex.Append(#13);
  end;

end;

procedure particula.perturbar(fact: Nreal; minX, maxX: TDAofNReal);
var
  rando1, rando2, rando3: NReal;
  i: integer;
begin
  for i := 0 to length(posicion) - 1 do
  begin
    rando1 := fmu.rnd;
    if rando1 < fact then
    begin
      rando2 := fmu.rnd;
      posicion[i] := (maxX[i] - minX[i]) * rando2 + minX[i];
      //self.calcular_fitness();
    end;
  end;
end;

procedure particula.Free();
begin
  setlength(posicion, 0);
  setlength(velocidad, 0);
  setlength(mejorposicion, 0);
end;


initialization

  fmu := TMadreUniforme.Create(31);

finalization

  FreeAndNil(fmu);
end.
