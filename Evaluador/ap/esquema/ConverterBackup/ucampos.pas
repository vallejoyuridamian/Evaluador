unit ucampos;

interface

type
  TCampo = class
    Nombre,
    ValorStr,
    Unidades,
    FormatoPreferido: string;
    constructor Create( xNombre, xValorStr, xUnidades, xFormatoPreferido: string );
    function Edtiar: boolean; virtual;
    function Clonar: TCampo; virtual;
  end;

implementation


constructor TCampo.Create( xNombre, xValorStr, xUnidades, xFormatoPreferido: string );
begin
  Nombre:= xNombre;
  ValorStr:= xValorStr;
  Unidades:= xUnidades;
  FormatoPreferido:= xFormatoPreferido;
end;

function TCampo.Clonar: TCampo;
var
  res: TCampo;
begin
  res:= TCampo.Create( Nombre, ValorStr, Unidades, FormatoPreferido );
  result:= res;
end;

function TCampo.Edtiar: boolean;
var
  bk: TCampo;
begin
  bk:= clonar;

  bk.Free;
end;

end.
