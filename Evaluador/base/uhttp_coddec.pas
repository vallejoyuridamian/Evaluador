unit uhttp_coddec;

{$mode delphi}
{$H+}
interface

uses
  Classes, SysUtils;

// codifica los caracteres especiales para devolverlos en codificación
// entendible en una url
function HTTPDecode(const AStr: string): string;

// Decodifica los caracteres especiales de una url.
function HTTPEncode(const AStr: string): string;

// busca en cadenaEntrada  el siguiente par NOMBRE=VALOR lo
// retorna en las variables "nombre" y "valor" y lo quita de
// cadenaEntrada. Como separador se reconoce el "&"
// El resultado es TRUE si fue posible encontrar un par y FALSE
// en caso contrario.
// Los valores asignados a "nombre" y "valor" son pasados por
// la función HTTPDecode.
function getNextCampoValor(var nombre, valor, cadenaEntrada: string): boolean;

implementation



function HTTPDecode(const AStr: string): string;
var
  S, SS, R: PChar;
  H: string[3];
  L, C: integer;

begin
  L := Length(Astr);
  SetLength(Result, L);
  if (L = 0) then
    exit;
  S := PChar(AStr);
  SS := S;
  R := PChar(Result);
  while (S - SS) < L do
  begin
    case S^ of
      '+': R^ := ' ';
      '%':
      begin
        Inc(S);
        if ((S - SS) < L) then
        begin
          if (S^ = '%') then
            R^ := '%'
          else
          begin
            H := '$00';
            H[2] := S^;
            Inc(S);
            if (S - SS) < L then
            begin
              H[3] := S^;
              Val(H, PByte(R)^, C);
              if (C <> 0) then
                R^ := ' ';
            end;
          end;
        end;
      end;
      else
        R^ := S^;
    end;
    Inc(R);
    Inc(S);
  end;
  SetLength(Result, R - PChar(Result));
end;

function HTTPEncode(const AStr: string): string;

const
  HTTPAllowed = ['A'..'Z', 'a'..'z', '*', '@', '.', '_', '-',
    '0'..'9', '$', '!', '''', '(', ')'];

var
  SS, S, R: PChar;
  H: string[2];
  L: integer;

begin
  L := Length(AStr);
  SetLength(Result, L * 3); // Worst case scenario
  if (L = 0) then
    exit;
  R := PChar(Result);
  S := PChar(AStr);
  SS := S; // Avoid #0 limit !!
  while ((S - SS) < L) do
  begin
    if S^ in HTTPAllowed then
      R^ := S^
    else if (S^ = ' ') then
      R^ := '+'
    else
    begin
      R^ := '%';
      H := HexStr(Ord(S^), 2);
      Inc(R);
      R^ := H[1];
      Inc(R);
      R^ := H[2];
    end;
    Inc(R);
    Inc(S);
  end;
  SetLength(Result, R - PChar(Result));
end;


function getNextCampoValor(var nombre, valor, cadenaEntrada: string): boolean;
var
  i: integer;
  nombre_valor: string;

begin
  cadenaEntrada := trim(cadenaEntrada);
  if length(cadenaEntrada) = 0 then
  begin
    nombre := '';
    valor := '';
    Result := False;
    exit;
  end;

  Result := True;
  i := pos('&', cadenaEntrada);
  if i > 0 then
  begin
    nombre_valor := copy(cadenaEntrada, 1, i - 1);
    Delete(cadenaEntrada, 1, i);
  end
  else
  begin
    nombre_valor := cadenaEntrada;
    cadenaEntrada := '';
  end;

  i := pos('=', nombre_valor);
  if i = 0 then
  begin
    nombre := nombre_valor;
    valor := '';
  end
  else
  begin
    nombre := copy(nombre_valor, 1, i - 1);
    valor := copy(nombre_valor, i + 1, length(nombre_valor) - i);
  end;

  nombre := HTTPDecode(nombre);
  valor := HTTPDecode(valor);
end;



end.

