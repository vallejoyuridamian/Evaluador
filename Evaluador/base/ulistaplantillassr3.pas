unit ulistaplantillassr3;

{$mode delphi}
(*
Objetivo: Definición de la clase TListaPlantillas_SR3 como una "cosa con nombre"
que sirve para agregar a la Sala el listado de plantillas.

Esta clase también debe ser capaz de colaborar en el empaquetado de la sala
y también en la formación del monitor a ejecutar en la sala en base a las
Plantillas ACTIVAS.

En el editor debe estar la posibilidad de Activar y/o Desactivar las plantillas.

*)
interface

uses
  Classes, SysUtils, ucosa, ucosaconnombre, xmatdefs;

type

  { TPlantillaSimRes3_rec }

  TPlantillaSimRes3_rec = class(TCosaConNombre)
  public
    activa: boolean;
    archi: TArchiRef;
    constructor Create(capa: integer; nombre, xarchi: string);
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

  end;

  { TListaPlantillasSimRes3 }

  TListaPlantillasSimRes3 = class(TListaDeCosasConNombre)
  public
    next_nid: integer;
    constructor Create(capa: integer; nombre: string);
     
    constructor Create_ReadFromText(f: TArchiTexto); override;
    procedure WriteToText_(f: TArchiTexto); override;

    // chequea si el archivo ya no está en la lista y lo agrega.
    // retorna el puntero al Rec agregado o NIL si ya estaba y no fue agregado.
    function AppendArchivo(nombreArchivo: string): TPlantillaSimRes3_rec;

    // retorna NIL si no encuentra una ficha que apunte al archivo nombreArchivo
    function FindArchivo(nombreArchivo: string): TPlantillaSimRes3_rec;

    function lista_activas(capas: TDAOfNInt=nil): TStrings;
  end;


procedure AlInicio;
procedure AlFinal;

implementation


constructor TPlantillaSimRes3_rec.Create(capa: integer; nombre, xarchi: string);
begin
  inherited Create(capa, nombre);
  activa := True;
  archi := TArchiRef.Create(xarchi);
end;

function TPlantillaSimRes3_rec.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('activa', activa);
  Result.addCampoDef_ArchRef('archi', archi );
end;

procedure TPlantillaSimRes3_rec.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TPlantillaSimRes3_rec.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


constructor TListaPlantillasSimRes3.Create(capa: integer; nombre: string);
begin
  inherited Create(capa, nombre);
  next_nid := 1;
end;

constructor TListaPlantillasSimRes3.Create_ReadFromText(f: TArchiTexto);
begin
  inherited Create_ReadFromText( f );
  f.rd('next_nid', next_nid);
end;

procedure TListaPlantillasSimRes3.WriteToText_(f: TArchiTexto);
begin
  inherited WriteToText_( f );
  f.wr('next_nid', next_nid);
end;


function TListaPlantillasSimRes3.FindArchivo(nombreArchivo: string):
TPlantillaSimRes3_rec;
var
  rec: TPlantillaSimRes3_rec;
  k: integer;
  buscando: boolean;
begin
  buscando := True;
  k := 0;
  while buscando and (k < Count) do
  begin
    rec := items[k] as TPlantillaSimRes3_rec;
    if (rec.archi.archi = nombreArchivo) then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
    Result := nil
  else
    Result := rec;
end;


function TListaPlantillasSimRes3.lista_activas( capas: TDAOfNInt = nil ): TStrings;
var
  k: integer;
  rec: TPlantillaSimRes3_rec;
  res: TStringList;

function EnCapaActiva( capa: integer ): boolean;
var
  k: integer;
  buscando: boolean;
begin
  if ( capas = nil )  then
    result:= true
  else
  begin
    buscando:= true;
    for k:= 0 to high( capas ) do
      if capa = capas[k] then
      begin
        buscando:= false;
        break;
      end;
    result:= not buscando;
  end;
end;

begin
  res := TStringList.Create;
  for k := 0 to Count - 1 do
  begin
    rec := items[k] as TPlantillaSimRes3_rec;
    if  rec.activa and EnCapaActiva( rec.capa ) and rec.archi.testearYResolver then
      res.Add( rec.archi.archi );
  end;
  Result := res;
end;

function TListaPlantillasSimRes3.AppendArchivo(nombreArchivo: string):
TPlantillaSimRes3_rec;
var
  rec: TPlantillaSimRes3_rec;
begin
  if FindArchivo(nombreArchivo) = nil then
  begin
    rec := TPlantillaSimRes3_rec.Create(0, 'rec_' + IntToStr(next_nid), nombreArchivo);
    Inc(next_nid);
    add(rec);
    Result := rec;
  end
  else
    Result := nil;
end;










procedure AlInicio;
begin
  registrarClaseDeCosa(TPlantillaSimRes3_rec.ClassName,
    TPlantillaSimRes3_rec);
  registrarClaseDeCosa(TListaPlantillasSimRes3.ClassName,
    TListaPlantillasSimRes3);
end;

procedure AlFinal;
begin
end;


end.
