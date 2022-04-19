unit upreprocesador;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, uevaluador, SysUtils;

(******
Esta unidad da servicios de sustitución de valores en texto.
Para eso hay que crear una instancia de la clase TListaDeVariblesPP
y agregarle las definiciones (nombre, valor) que uno quiera.
Tener en cuenta que el nombre es CASE sensitive.
Luego uno puede usar la función "SustituirVariables" o el procedimiento
"CopiarSustituyendo" para realizar una sustitución en un texto
ya sea en un widestring en memoria (primer caso) o mediante el
copiado de un archivo en otro (segundo caso).

Para que una variable sea sustituída, en el texto debe aparecer como
{$nombre}

Por ejemplo si un texto dice " el año es {$anioEntrada} de entrada "
se deberá haber agregado la definición de la variable "anioEntrada"

Si se encuentra con una variable de la que no encuentra definicón
da un error
****)
type

  TVariablePP = class
    nombre, valor: string;
    constructor Create(xnombre, xvalor: string);
    procedure Free; virtual;
  end;

  TListaDeVariablesPP = class(TList)
    constructor Create;
    procedure Free; virtual;
    procedure Agregar(nombre, valor: string); overload;
    procedure Agregar(avar: TVariablePP); overload;
    function buscar(nombre: string): TVariablePP;
  end;

function strpos_i(const pal, frase: WideString; ibase: integer): integer;

function SustituirVariables(const texto: WideString;
  ListaDeVariables: TListaDeVariablesPP): WideString;

procedure CopiarSustituyendo(const ArchiEnt, ArchiSal: string;
  ListaDeVariables: TListaDeVariablesPP);

procedure LeerDefiniciones_fromTextFile(var f: textfile;
  var ListaDeVariables: TListaDeVariablesPP);
procedure LeerDefiniciones_fromArchi(var archi: string;
  var ListaDeVariables: TListaDeVariablesPP);

(*Retonra la Variable si la línea tiene una definición y NIL en caso contrario *)
function parse_var_line(const r: WideString): TVariablePP;

implementation


function parse_var_line(const r: WideString): TVariablePP;
var
  i, ibarrabarra: integer;
  nombre, valor:  WideString;
begin
  ibarrabarra := pos('//', r);
  if ibarrabarra = 0 then
    ibarrabarra := length(r)+1;

  i := pos('=', r);
  if (i > 0) and (i < ibarrabarra) then
  begin
    nombre := trim(copy(r, 1, i - 1));
    valor  := trim(copy(r, i + 1, ibarrabarra - i -1));
    Result := TVariablePP.Create(nombre, valor);
  end
  else
    Result := nil;
end;

procedure LeerDefiniciones_fromTextFile(var f: textfile;
  var ListaDeVariables: TListaDeVariablesPP);

var
  r:      string;
  avar:   TVariablePP;
  archi:  string;
  kLinea: integer;
begin
  kLinea := 1;
  while not EOF(f) do
  begin
    readln(f, r);
    Inc(kLinea);
    try
      avar := parse_var_line(r);
      if avar <> nil then
        if avar.nombre = '#include' then
        begin
          archi := SustituirVariables(avar.valor, ListaDeVariables);
          LeerDefiniciones_fromArchi(archi, ListaDeVariables);
        end
        else
        begin
          ListaDeVariables.Agregar(avar);
//          writeln(' add( '+avar.nombre+', '+avar.valor+' );');
        end;
    except
      begin
        writeln('ERROR en linea: ' + IntToStr(kLinea));
        writeln(r);
        writeln('Presione cualquier tecla para continuar.');
        readln;
      end;
    end;
  end;
end;

procedure LeerDefiniciones_fromArchi(var archi: string;
  var ListaDeVariables: TListaDeVariablesPP);
var
  ent:   TextFile;
  OldFileMode: byte;
begin
  OldFileMode := filemode;
  filemode    := 0;
  assignfile(ent, Archi);
  {$I-}
  reset(ent);
  {$I+}
  filemode := OldFileMode;

  if ioresult <> 0 then
  begin
    writeln('No encuentro el archivo: ' + Archi);
    writeln('.... ENTER para salir');
    readln;
    halt(1);
  end;

  if ListaDeVariables = nil then
    ListaDeVariables := TListaDeVariablesPP.Create;

  writeln('Leyendo definiciones desde: ' + Archi);
  LeerDefiniciones_fromTextFile(ent, ListaDeVariables);
  closefile(ent);
end;

procedure CopiarSustituyendo(const ArchiEnt, ArchiSal: string;
  ListaDeVariables: TListaDeVariablesPP);
var
  ent, sal: TextFile;
  OldFileMode: byte;
  r, rt: string;
begin
  OldFileMode := filemode;
  filemode    := 0;
  assignfile(ent, ArchiEnt);
  {$I-}
  reset(ent);
  {$I+}
  if ioresult <> 0 then
  begin
    writeln('No encuentro el archivo: ' + ArchiEnt);
    writeln('.... ENTER para salir');
    readln;
    halt(1);
  end;
  filemode := 2;
  assignfile(sal, ArchiSal);
  rewrite(sal);
  while not EOF(ent) do
  begin
    readln(ent, r);
    rt := SustituirVariables(r, ListaDeVariables);
    writeln(sal, rt);
  end;
  closefile(sal);
  closefile(ent);
  filemode := OldFileMode;
end;

function strpos_i_reversa(const pal, frase: WideString; ibase: integer): integer;
var
  buscando: boolean;
  nPal, i, j, iMin: integer;
begin
  if ibase <= 0 then
    ibase := length(frase);
  buscando := True;
  nPal := length(pal);
  iMin := nPal - 1;
  j := nPal;
  i := ibase;
  while buscando and (i >= iMin) do
  begin
    if frase[i] = pal[j] then
    begin
      Dec(j);
      if j < 1 then
        buscando := False;
    end
    else
      j := nPal;
    Dec(i);
  end;
  if buscando then
    Result := 0
  else
    Result := i + 1;
end;



function strpos_i(const pal, frase: WideString; ibase: integer): integer;
var
  buscando: boolean;
  nFrase, nPal, i, j, iMax: integer;
begin
  if ibase <= 0 then
    ibase := 1;
  buscando := True;
  nPal := length(pal);
  nFrase := length(frase);
  iMax := nFrase - nPal + 1;
  j := 1;
  i := ibase;
  while buscando and (i <= iMax) do
  begin
    if frase[i] = pal[j] then
    begin
      Inc(j);
      if j > nPal then
        buscando := False;
    end
    else
      j := 1;
    Inc(i);
  end;
  if buscando then
    Result := 0
  else
    Result := i - nPal;
end;

function SustituirVariables(const texto: WideString;
  ListaDeVariables: TListaDeVariablesPP): WideString;
var
  i, j{, ibase}: integer;
  s, s1, s2, pal: WideString;
  v: TVariablePP;
  r: double;
  c: char;
  v_valor: WideString;
begin
  s := texto;
  i := strpos_i_reversa('{$', s, length(s));
  while (i > 0) do
  begin
    j := strpos_i('}', s, i);
    if j = 0 then
      raise Exception.Create('Atención no encontré cierre } sustituyendo: ' +
        copy(s, i, 8));
    pal := trim(copy(s, i + 2, j - (i + 2)));
    if pos('#', pal) = 1 then
    begin // evaluar
      if length(pal) < 2 then
        raise Exception.Create('{$#} no es una secuenca válida');
      c := pal[2];
      Delete(pal, 1, 2);
      r := evalStrToFloat(pal);
      case c of
        'F': v_valor := FloatToStr(r);
        'I': v_valor := IntToStr(trunc(r + 0.5));
      end;
    end
    else
    begin // busqueda común
      v := ListaDeVariables.buscar(pal);
      if v = nil then
        raise Exception.Create('No encontré definición para la variable: ' + pal);
      v_valor := v.valor;
    end;
    s1 := copy(s, 1, i - 1);
    s2 := copy(s, j + 1, length(s) - j);
    s  := s1 + v_valor + s2;
    i  := strpos_i_reversa('{$', s, i - 1);
  end;
  Result := s;
end;

constructor TVariablePP.Create(xnombre, xvalor: string);
begin
  inherited Create;
  nombre := xnombre;
  valor  := xvalor;
end;

procedure TVariablePP.Free;
begin

  inherited Free;
end;

constructor TListaDeVariablesPP.Create;
begin
  inherited Create;
end;

procedure TListaDeVariablesPP.Free;
var
  k: integer;
begin
  for k := 0 to Count - 1 do
    TVariablePP(items[k]).Free;
  inherited Free;
end;


procedure TListaDeVariablesPP.Agregar(avar: TVariablePP);
var
  auxVal: WideString;
begin
  auxVal     := SustituirVariables(avar.valor, Self);
  avar.valor := auxVal;
  add(avar);
end;


procedure TListaDeVariablesPP.Agregar(nombre, valor: string);
var
  v: TVariablePP;
begin
  v := TVariablePP.Create(nombre, valor);
  Agregar(v);
end;

function TListaDeVariablesPP.buscar(nombre: string): TVariablePP;
var
  buscando: boolean;
  a: TVariablePP;
  i: integer;
begin
  a := nil;
  buscando := True;

  // writeln( 'Buscando: [', nombre, ']' );
  for I := 0 to Count - 1 do
  begin
    a := items[i];
    // writeln( i, '[', a.nombre,']' );
    if a.nombre = nombre then
    begin
      buscando := False;
      break;
    end;
  end;

  if buscando then
    Result := nil
  else
    Result := a;
end;

end.

