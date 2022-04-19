unit usortedlist;

interface

uses
  Classes;

type
  TSortedList = class(TList)
    function KeyOf(Item: Pointer): Pointer; virtual; abstract;
    function Compare(Key1, Key2: Pointer): integer; virtual; abstract;
    function sorted_search(key: pointer; var kindice: integer): boolean;
    procedure sorted_insert(Item: Pointer);
  end;



implementation

function TSortedList.sorted_search(key: pointer; var kindice: integer): boolean;
var
  buscando, encontrado: boolean;
  rc: integer;

begin
  buscando   := True;
  encontrado := False;
  kindice    := 0;
  while buscando and (kindice < Count) do
  begin
    rc := compare(keyof(items[kindice]), key);
    if rc = 0 then
    begin
      buscando   := False;
      encontrado := True;
    end
    else
    if rc < 0 then
      Inc(kindice)
    else
      buscando := False;

  end;
  Result := encontrado;
end;

procedure TSortedList.sorted_insert(Item: Pointer);
var
  kindice: integer;
begin
  sorted_Search(keyof(item), kindice);
  insert(kindice, item);
end;


end.

