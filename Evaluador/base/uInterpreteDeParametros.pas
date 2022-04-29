unit uInterpreteDeParametros;
interface

uses
  SysUtils, Classes;

type
  TPar = class
    nombre, valor: string;
    constructor Create(xNombre, xValor: string);
  end;

  TInterpreteParametros = class(TList)
    constructor Create( archiSalaObligatorio: boolean );

    // si el parámetro no esta definido retorna ''
    function valStr(nombre: string; defval: string = '' ): string;

    // si el parámetro no esta definido retorna '-1'
    function valInt(nombre: string; defval: integer = -1 ): integer;

    // retorna el índice del Parametro si lo encuentra o -1 si no
    function buscar(nombre: string): integer;
    procedure Free;

    // add or replace
    procedure addor(aPar: TPar);
  end;

implementation


constructor TPar.Create(xNombre, xValor: string);
begin
  Nombre:= xNombre;
  Valor:= xValor;
end;

constructor TInterpreteParametros.Create(archiSalaObligatorio: boolean);
var
  i, k:      integer;
  Name, val: string;
  nPars:     integer;
//  a: TPar;
  s: string;

begin

  inherited Create;

  //Valores por defecto
  add(TPar.Create('monitores', ''));
  add(TPar.Create('nhilos', '-1'));
  add(TPar.Create('ntareas', '-1'));

  nPars := ParamCount;
  for k := 1 to nPars do
  begin
    s:= ParamStr(k);
    i := pos('=', s);
    if i > 0 then
    begin
      Name := copy(s, 1, i - 1);
      if i < length(s) then
        val := copy(s, i + 1, length(s) - i)
      else
        val := '';
      val:= trim( val );
      if ( pos( '"', val ) = 1 )
         and ( ( length( val ) > 1 ) and (val[length(val )] = '"'))
         then
      begin
        system.delete( val, 1, 1 );
        system.delete( val, length(val), 1 );
      end;
    end
    else
    begin
      Name := s;
      val  := 'sin valor';
    end;
    addor(TPar.Create( AnsiLowerCase( name ), val));
  end;

  if (archiSalaObligatorio) then
  begin
    if buscar('sala') < 0 then
    begin
      Free;
      writeln( 'El parametro sala es obligatorio' );
      raise Exception.Create('El parametro "sala" es obligatorio.');
    end
    else
    begin
      val := ValStr('sala');
      if not FileExists( val ) then
      begin
        Free;
        raise Exception.Create('No se encuentra el archivo de sala: ' + val);
      end;
    end;
  end;
end;


function TInterpreteParametros.valStr(nombre: string; defval: string = ''): string;
var
  k: integer;
begin
  k:= buscar( nombre );
  if k < 0 then
    result:= defval
  else
    result:= TPar( items[k] ).valor;
end;

function TInterpreteParametros.valInt(nombre: string; defval: integer = -1 ): integer;
var
  k: integer;
begin
  k:= buscar( nombre );
  if k < 0 then
    result:= defval
  else
    result:= StrToInt( TPar( items[k] ).valor );
end;

// retorna el índice del Par si lo encuentra o -1 si no
function TInterpreteParametros.buscar(nombre: string): integer;
var
  k: integer;
  buscando: boolean;
  pal: string;
  a: TPar;

begin
  k:= 0;
  buscando:= true;
  pal:= AnsiLowerCase( nombre );
  while buscando and ( k < Count ) do
  begin
    a:= items[k];
    if pal = a.nombre then
      buscando:= false
    else
      inc( k );
  end;
  if buscando then
    result:= -1
  else
    result:= k;
end;

// insert or replace
procedure TInterpreteParametros.addor(aPar: TPar);
var
  k: integer;
begin
  k:= buscar( aPar.Nombre );
  if k < 0 then
    add( aPar )
  else
  begin
    TPar( items[k] ).valor:= aPar.valor;
    aPar.Free;
  end;
end;


procedure TInterpreteParametros.Free;
var
  k: integer;
begin
  for k := 0 to Count - 1 do
    TPar(items[k]).Free;
  inherited Free;
end;


end.

