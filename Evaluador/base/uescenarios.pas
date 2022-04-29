unit uescenarios;

{
rch@20130914
Un escenario está definido por un conjunto de capas activas.
Las capas son números enteros
}


interface

uses
  Classes, SysUtils, xMatDefs, uCosa, uCosaConNombre;

type

  { TEscenario_rec }

  TEscenario_rec = class(TCosaConNombre)
  public
    capasActivas: TDAOfNInt;
    activa: boolean;
    descripcion: string;
    run_opt: boolean;
    run_sim: boolean;
    run_sr3: boolean;
    constructor Create(nombre: string);
    function Rec: TCosa_RecLnk; override;
    procedure Free; override;
    procedure AddCapa(capa: integer);
    procedure DelCapa(capa: integer);
    function tieneCapa(capa: integer): boolean;

    // Chequea si la Cosa está en una capa de las activas
    // del escenario y retonra TRUE en caso afirmativo.
    function Participa(Cosa: TCosa): boolean;
  end;

  { TListaEscenarios }

  TListaEscenarios = class(TListaDeCosasConNombre)
    constructor Create(nombre: string);

    // chequea si el escenario ya no está en la lista y lo agrega.
    // retorna el puntero al Rec agregado o NIL si ya estaba y no fue agregado.
    function AppendEscenario(nombreEscenario: string): TEscenario_rec;
    function lista_activas: TStrings;
  end;

procedure AlInicio;
procedure AlFinal;

implementation


constructor TEscenario_rec.Create(nombre: string);
begin
  inherited Create(0, nombre);
  setlength(capasActivas, 1);
  capasActivas[0] := 0;
  activa := True;
  run_opt := True;
  run_sim := True;
  run_sr3 := true;
end;

function TEscenario_rec.Rec: TCosa_RecLnk;
begin
  Result := inherited Rec;
  Result.addCampoDef('capasActivas', capasActivas);
  Result.addCampoDef('activa', activa);
  Result.addCampoDef('descripcion', descripcion);
  Result.addCampoDef('run_opt', run_opt);
  Result.addCampoDef('run_sim', run_sim);
  Result.addCampoDef('run_sr3', run_sr3, 155, 0, '1' );
end;




procedure TEscenario_rec.Free;
begin
  setlength(capasActivas, 0);
  inherited Free;
end;

procedure TEscenario_rec.AddCapa(capa: integer);
begin
  addToArray(capasActivas, capa);
end;

procedure TEscenario_rec.DelCapa(capa: integer);
var
  arr: TDAofNInt;
begin
  arr := capasActivas;
  delFromArray(arr, capa);
  capasActivas := arr;

end;

function TEscenario_rec.tieneCapa(capa: integer): boolean;
begin
  Result := kInArray(capasActivas, capa) >= 0;
end;


function TEscenario_rec.Participa(Cosa: TCosa): boolean;
begin
  Result := kInArray(capasActivas, Cosa.capa) >= 0;
end;




constructor TListaEscenarios.Create(nombre: string);
var
  ae: TEscenario_rec;
begin
  inherited Create(0, nombre);
  // por defecto ponemos escenario base con capa cero
  ae := TEscenario_rec.Create('Base');
  add(ae);
end;




function TListaEscenarios.lista_activas: TStrings;

var
  k: integer;
  rec: TEscenario_rec;
  res: TStringList;

begin
  res := TStringList.Create;
  for k := 0 to Count - 1 do
  begin
    rec := items[k] as TEscenario_rec;
    if rec.activa then
      res.Add(rec.nombre);
  end;
  Result := res;
end;



function TListaEscenarios.AppendEscenario(nombreEscenario: string): TEscenario_rec;
var
  rec: TEscenario_rec;
begin
  if Find(nombreEscenario) = nil then
  begin
    rec := TEscenario_rec.Create(nombreEscenario);
    add(rec);
    Result := rec;
  end
  else
    Result := nil;
end;



(*********************************)
procedure AlInicio;
begin
  registrarClaseDeCosa(TEscenario_rec.ClassName, TEscenario_rec);
  registrarClaseDeCosa(TListaEscenarios.ClassName, TListaEscenarios);
end;

procedure AlFinal;
begin
end;

end.





