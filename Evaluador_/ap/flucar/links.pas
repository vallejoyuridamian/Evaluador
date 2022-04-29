{+doc
+NOMBRE:  LINKS
+CREACION:
+AUTORES:  rch
+MODIFICACION:
+REGISTRO:
+TIPO:  Unidad Pascal
+PROPOSITO: Esta unidad es un parche para permitir llamadas a unidades no referenciadas
      para evitar referencias circulares
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit Links;

interface

uses
  AlgebraC,
  Lexemas32,
  xMatDefs, Horrores;

type

  TFunc_Indice = function(var r: string; var rescod: integer): integer;
  TFunc_VarPtr   = function(k: integer): PNComplex;
  TFunc_BarraPtr = function(k: integer): pointer;



var
  { Esta funcion se define en la unidad TYVS, la cual se encarga de
  hacer el LINK en la inicializacion. }
  Func_IndiceDeNodo: TFunc_Indice;
  Func_IndiceDeFunc: TFunc_Indice;
  Func_BarraPtr:     TFunc_BarraPtr;

  { Definida en TYVS }
  Func_VarPtr: TFunc_VarPtr;


function LeerNReal(var a: TFlujoLetras; var resultado: NReal): integer;
function LeerNInteger(var a: TFLujoLetras; var resultado: integer): integer;
function LeerNComplex(var a: TFLujoLetras; var resultado: NComplex): integer;

implementation




function LeerNReal(var a: TFlujoLetras; var resultado: NReal): integer;
label
  Check1;
var
  negativo: boolean;
  res: integer;
  r: string;
begin
  negativo := False;
  check1:
    getlexema(r, a);
  if r = '?' then
  begin
    LeerNReal := 114;
    exit;
  end;
  if r = 'N' then
  begin
    LeerNReal := 115;
    exit;
  end;

  if r = '-' then
  begin
    negativo := True;
    goto check1;
  end;

  if r = '+' then
    goto check1;
  val(r, resultado, res);
  if res <> 0 then
    error('convirtiendo a real');
  if negativo then
    resultado := -resultado;
  LeerNReal   := res;
end;

function LeerNInteger(var a: TFLujoLetras; var resultado: integer): integer;
label
  Check1;
var
  negativo: boolean;
  res: integer;
  r: string;
begin
  negativo := False;
  check1:
    getlexema(r, a);

  if r = '-' then
  begin
    negativo := True;
    goto check1;
  end;

  if r = '+' then
    goto check1;
  val(r, resultado, res);
  if res <> 0 then
    error('convirtiendo a integer');
  if negativo then
    resultado  := -resultado;
  LeerNInteger := res;
end;

function LeerNComplex(var a: TFLujoLetras; var resultado: NComplex): integer;
label
  Check1;
var
  cs:  string;
  negativo: boolean;
  res: integer;
  LeyendoParteReal: boolean;
  r:   string;
begin
  negativo := False;
  LeyendoParteReal := True;
  cs := '';
  check1:

    getlexema(r, a);

  if r = '-' then
  begin
    negativo := True;
    cs := cs + ' ' + r;
    goto check1;
  end;

  if r = '+' then
  begin
    cs := cs + ' ' + r;
    goto check1;
  end;

  if leyendoParteReal then
  begin
    { Parte Real }
    val(r, resultado.r, res);
    if negativo then
      resultado.r := -resultado.r;
    if res <> 0 then
      error('convirtiendo a ParteReal');
    leyendoParteReal := False;
    negativo := False;
    cs := '';
    goto check1;
  end
  else { Parte Imaginaria }
  if res = 0 then
  begin
    if (pos('j', r) = 1) or (pos('i', r) = 1) then
    begin
      Delete(r, 1, 1);
      if length(r) = 0 then
        getlexema(r, a);
      val(r, resultado.i, res);
      if negativo then
        resultado.i := -resultado.i;
      if res <> 0 then
        error('convirtiendo a ParteImaginaria');
      cs := '';
    end
    else
    begin
      r := cs + ' ' + r;
      PutLexema(r, a);
      resultado.i := 0;
    end;
  end;
  LeerNComplex := res;
end;

end.

