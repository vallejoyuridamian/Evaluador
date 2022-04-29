unit ubuscaarchivos;

{$mode delphi}

interface

uses
  Classes, SysUtils;

type
// TBuscaArchivos permite agregar una lista de carpetas en las que buscar
// un archivo.
// La función Locate( archivo ) retorna el camino completo al archivo
// Si no lo encuentra, el resultado es '';
  TBuscaArchivos = class( TStringList )
    function Locate( archi: string ): string;
  end;


implementation


function TBuscaArchivos.Locate( archi: string ): string;
var
  buscando: boolean;
  ts, nombre: string;
  k: integer;
begin
  // primero probamos si el archivo tal cual existe;
  if fileexists( archi ) then
  begin
    result:= archi;
    exit;
  end;
  nombre:= ExtractFileName( archi );

  buscando:= true;
  for k:= 0 to count-1 do
  begin
     ts:= Self[k]+ DirectorySeparator + nombre;
     if fileexists( ts ) then
     begin
       buscando:= false;
       break;
     end;
  end;

  if buscando then
    result:= ''
  else
    result:= ts;

end;

end.

