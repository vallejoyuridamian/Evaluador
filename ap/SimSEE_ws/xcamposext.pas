// (c) ZonaExterior 2014 , rchaer@zonaexterior.net
unit xcamposext;
interface
uses
  classes, sysutils, xcampos, lib_dbmysql, fphttpserver, HTTPDefs;

(* retorna un combo simple.
(nombre) es el nombre del combo
(ds) debe se el resultado de una consulta donde la primer columna es el código (NID)
y la segunda es el nombre a desplegar.
(selnid) es el valor originalmente seleccionado. Si no es ninguno poner ''
*)
function new_lookupcombo( nombre: String; ds: TDB_ds ): TCF_Select;


function new_multicombo( nombre: string; ds: TDB_ds ): TCF_Select;


function new_keyedlookupcombo(
    nombre: string; ds: TDB_ds;
    addkey_selectone: String='';
    addtitle_selectone:String='-Seleccione-';
    multi_select: boolean = false;
    alto_min: integer= 1;
    alto_max: integer= 1 ): TCF_keyedselect;

function new_keyedmulticombo(  nombre: String; ds: TDB_ds ): TCF_keyedselect;


implementation

(* retorna un combo simple.
(nombre) es el nombre del combo
(ds) debe se el resultado de una consulta donde la primer columna  es el nombre a desplegar.
(selnid) es el valor originalmente seleccionado. Si no es ninguno poner ''
*)
function new_lookupcombo(  nombre: String; ds: TDB_ds ): TCF_Select;
var
  names: TStringList;
  r: TDB_row;
  ksel, k: integer;
begin
  names:= TStringList.Create;
  ksel:=0;
  k:=0;
  r:= ds.first;
  while ( r <> nil ) do
  begin
    names.add( r[0] );
    inc( k );
    r:= ds.next;
  end;
  result:= TCF_select.Create( nombre, names, false, 1, 1);
end;


function new_multicombo(  nombre: string; ds: TDB_ds ): TCF_Select;
var
  names: TStringList;
  r: TDB_row;
begin
  names:= TStringList.Create;
  r:= ds.first;
  while ( r <> nil ) do
  begin
    names.add( r[1] );
    r:= ds.next;
  end;
  result:= TCF_select.Create( nombre, names, true, 1, 8);
end;



function new_keyedlookupcombo(
    nombre: string; ds: TDB_ds;
    addkey_selectone: String='';
    addtitle_selectone:String='-Seleccione-';
    multi_select: boolean = false;
    alto_min: integer= 1;
    alto_max: integer= 1 ): TCF_keyedselect;

var
  nids, names: TStringList;
  r: TDB_row;
begin

  nids:= TStringList.Create;
  names:= TStringList.Create;

  if ( addkey_selectone <> '' ) then
  begin
    nids.add( addkey_selectone );
    names.add( addtitle_selectone );
  end;

  r:= ds.first;
  while ( r <> nil ) do
  begin
    nids.add( r[0] );
    names.add( r[1] );
    r:= ds.next;
  end;

  result:= TCF_keyedselect.Create( nombre, nids, names, multi_select, alto_min, alto_max );
end;


function new_keyedmulticombo(
    nombre: String; ds: TDB_ds ): TCF_keyedselect;
var
  nids, names: TStringList;
  flg_armar_selini_todas: boolean;
  r: TDB_row;
begin
  nids:= TStringList.Create;
  names:= TStringList.Create;
  r:= ds.first;
  while ( r<> nil ) do
  begin
    nids.add( r[0] );
    names.add( r[1] );
    r:= ds.next;
  end;
  result:= TCF_keyedselect.Create( nombre, nids, names, true, 1, 8);
end;


end.
