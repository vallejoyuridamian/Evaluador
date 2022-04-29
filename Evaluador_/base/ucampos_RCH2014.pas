unit ucampos;
{$mode delphi}
(**** rch@20140423
Intento por N-esima vez definir CAMPOS con representación en string
y punteros a variables de los difernetes tipos.
La idea es que los CAMPOS tengan Nombre, tipo, unidades y descripción
podrían ser campos de una DB.
Un TRecDefs tiene que ser la lista de campos que defininen una clase
Un TRecData tiene la lista de punteros a las variables y la lista
de valores str

un TRecDataSet es un array de TRecData

a las clases que puedan usar esta unidad hay que
creales la funcion getRecDefs como función de
y un procedimiento LinkRecData( var aRecData )
*)
interface

uses
  Classes, SysUtils, xmatdefs;


type

TCampoDef = class
  nombre: string;
  unidades: string;
  descripcion: string;
  constructor Create( xnombre, xunidades, xdescripcion: string );
  function valToStr( var xval ): string; virtual; abstract;
  function StrToVal( var xval; const xstr: string ): boolean; virtual; abstract;
end;


TCampoDef_NReal = class ( TCampoDef )
  function valToStr( var xval ): string; virtual;
  function StrToVal( var xval; const xstr: string ): boolean; virtual;
end;

TCampoDef_NInt = class ( TCampoDef )
  function valToStr( var xval ): string; virtual;
  function StrToVal( var xval; const xstr: string ): boolean; virtual;
end;


TCampoDef_Str = class ( TCampoDef )
  function valToStr( var xval ): string; virtual;
  function StrToVal( var xval; const xstr: string ): boolean; virtual;
end;


TCampo_Val = class
  tipo: TCampoDef;
  pval: pointer;
  vstr: string;
  constructor Create( xtipo: TCampoDef; var xval; xstr: string );
end;



implementation


constructor TCampoDef.Create( xnombre, xunidades, xdescripcion: string );
begin
  nombre:= xnombre;
  unidades:= xunidades;
  descripcion:= xdescripcion;
end;

function TCampoDef_NReal.valToStr( var xval ): string;
begin
  result:= FloatToStr( NReal( xval ) );
end;

function TCampoDef_NReal.StrToVal( var xval; const xstr: string ): boolean;
var
  res: integer;
begin
   val( xstr, NReal( xval ), res );
   result:= res = 0;
end;

function TCampoDef_NInt.valToStr( var xval ): string;
begin
  result:= IntToStr( integer( xval ) );
end;

function TCampoDef_NInt.StrToVal( var xval; const xstr: string ): boolean;
var
  res: integer;
begin
  val( xstr, Integer( xval ), res );
  result:= res = 0;
end;

function TCampoDef_Str.valToStr( var xval ): string;
begin
  result:= string( xval );
end;

function TCampoDef_Str.StrToVal( var xval; const xstr: string ): boolean;
begin
  string(xval):= xstr;
  result:= true;
end;



constructor TCampo_Val.Create( xtipo: TCampoDef; var xval; xstr: string);
begin
  tipo:= xtipo;
  pval:= @xval;
  vstr:= xstr;
end;

end.

