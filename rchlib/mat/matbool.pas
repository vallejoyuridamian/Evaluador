{+doc
+NOMBRE: MatBool
+CREACION: 6.1.1994
+AUTORES: rch @floresta
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: definicion del objeto MatBooliz de enteros.
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
  Todas las tareas implementadas en esta biblioteca, tienen como
filosofia que los datos estan bien definidos, y para mejorar la
velocidad no verifican la coherencia. Tampoco se encargan de
inicializar MatBoolices. Supongamos que vamos a multiplicar las
MatBoolices A y B , y queremos el resultado en C, la sentecia es
C.MultM(A,B); pero se debe cuidar que los rangos sean los adecuados
y se debe inicializar C antes del llamado a MultMatBool.
  Las unicas tareas que inicializan  datos del objeto son las de
lectura. Ej: a.readM; inicialliza a.

-doc}

unit MatBool;

interface

uses
  xMatDefs;

type

  PVectBool = ^TVectBool;

  TVectBool = class
    n: integer;
    pv: TDAOfBoolean;
    constructor Create_Init(n: integer);
    constructor Create_LoadFromFile(var f: textfile);
    function e(k: integer): boolean;
    procedure pon_e(k: integer; x: boolean);

    procedure xor_e(k: integer; x: boolean);
    procedure or_e(k: integer; x: boolean);
    procedure and_e(k: integer; x: boolean);
    procedure flip_e(k: integer);

    procedure IntercambiarElementos(k1, k2: integer);

    // retorna la suma( e(k) and y.e(k) ) from k = 1 to n
    function PEV(const y: TVectBool): integer;
    // retorna la suma( e(k) and y.e( n-(k-1)) ) from k = 1 to n
    function PEVRFLX(const y: TVectBool): integer;

    procedure AndBoolean(r: boolean);
    procedure OrBoolean(r: boolean);
    procedure orV(var y: TVectBool);
    procedure andV(var y: TVectBool);
    function ne2: NEntero; {norma euclideana al cuadrado }
    function normEuclid: NReal;
    function normMaxAbs: boolean;
    procedure Igual(const x: TVectBool);
    procedure Ceros; virtual;
    procedure Unos; virtual;
    procedure Free;
  end;


type
  PMatBool = ^TMatBool;

  TMatBool = class
    nf, nc: integer;
    pm: array of TVectBool;
    constructor Create_Init(nf, nc: integer);
    constructor Create_LoadFromFile(var f: textfile);

    // se iguala a M
    procedure Igual(M: TMatBool);

    function e(k, j: integer): boolean;
    procedure pon_e(k, j: integer; x: boolean);
    procedure or_e(k, j: integer; x: boolean);
    procedure and_e(k, j: integer; x: boolean);

    procedure Mult(a, b: TMatBool);
    function Traza: integer;
    procedure CopyColVect(var Y: TVectBool; J: integer);
    procedure Ceros; virtual;
    procedure Unos; virtual;
    function fila(k: integer): TVectBool;
    procedure Free;
  end;


implementation

constructor TMatBool.Create_Init(nf, nc: integer);
var
  k: integer;
begin
  inherited Create;
  self.nf := nf;
  self.nc := nc;
  setlength(pm, nf + 1);
  for k := 1 to nf do
    pm[k] := TVectBool.Create_init(nc);
end;


procedure TMatBool.Free;
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].Free;
  setlength(pm, 0);
  inherited Free;
end;

constructor TMatBool.Create_LoadFromFile(var f: textfile);
var
  k: integer;
begin
  inherited Create;
  readln(f, nf);
  readln(f, nc);
  setlength(pm, nf + 1);
  for k := 1 to nf do
    pm[k] := TVectBool.Create_LoadFromFile(f);
end;

function TMatBool.e(k, j: integer): boolean;
begin
  e := pm[k].e(j);
end;

procedure TMatBool.pon_e(k, j: integer; x: boolean);
begin
  pm[k].pon_e(j, x);
end;

procedure TMatBool.Or_e(k, j: integer; x: boolean);
begin
  pm[k].or_e(j, x);
end;

procedure TMatBool.And_e(k, j: integer; x: boolean);
begin
  pm[k].and_e(j, x);
end;



constructor TVectBool.Create_Init(n: integer);
begin
  inherited Create;
  self.n := n;
  setlength(pv, n + 1);
end;

procedure TVectBool.Free;
begin
  setlength(pv, 0);
  inherited Free;
end;

constructor TVectBool.Create_LoadFromFile(var f: textfile);
var
  k: integer;
  c: char;
begin
  readln(f, n);
  setlength(pv, n + 1);
  for k := 1 to n do
  begin
    readln(f, c);
    pv[k] := UpCase(c) in ['1', 'V', 'T'];
  end;
end;




function TVectBool.e(k: integer): boolean;
begin
  Result := pv[k];
end;

procedure TVectBool.pon_e(k: integer; x: boolean);
begin
  pv[k] := x;
end;

procedure TVectBool.xor_e(k: integer; x: boolean);
begin
  pv[k] := pv[k] xor x;
end;


procedure TVectBool.or_e(k: integer; x: boolean);
begin
  pv[k] := pv[k] or x;
end;

procedure TVectBool.and_e(k: integer; x: boolean);
begin
  pv[k] := pv[k] and x;
end;

procedure TVectBool.flip_e(k: integer);
begin
  pv[k] := not pv[k];
end;

procedure TVectBool.IntercambiarElementos(k1, k2: integer);
var
  x: boolean;
begin
  x := e(k1);
  pon_e(k1, e(k2));
  pon_e(k2, x);
end;

function TMatBool.fila(k: integer): TVectBool;
begin
  Result := pm[k];
end;

procedure TMatBool.Ceros;
var
  k: integer;
begin
  for k := 1 to nf do
    fila(k).Ceros;
end;

procedure TMatBool.Unos;
var
  k: integer;
begin
  for k := 1 to nf do
    fila(k).Unos;
end;


procedure TVectBool.Ceros;
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := False;
end;


procedure TVectBool.Unos;
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := True;
end;

function TVectBool.PEV(const y: TVectBool): integer;
var
  k: integer;
  temp: integer;
begin
  temp := 0;
  for k := 1 to n do
    if (pv[k] and y.pv[k]) then
      Inc(temp);
  Result := temp;
end;  (* PEV *)


function TVectBool.PEVRFLX(const y: TVectBool): integer;
var
  k: integer;
  temp: integer;
begin
  temp := 0;
  for k := 1 to n do
    if (pv[k] and y.pv[n - (k - 1)]) then
      Inc(temp);
  Result := temp;
end;  (* PEVRFLX *)



procedure TVectBool.Igual(const x: TVectBool);
begin
  pv := system.copy(x.pv);
end;

procedure TVectBool.orV(var y: TVectBool);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := pv[k] or y.pv[k];
end;

procedure TVectBool.andV(var y: TVectBool);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := pv[k] and y.pv[k];
end;



procedure TVectBool.AndBoolean(r: boolean);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := pv[k] and r;
end;

procedure TVectBool.OrBoolean(r: boolean);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := pv[k] or r;
end;


function TVectBool.ne2: NEntero; {norma euclideana al cuadrado }
var
  k: integer;
  acum: NEntero;
begin
  acum := 0;
  for k := 1 to n do
    if pv[k] then
      Inc(acum);
  Result := acum;
end;

function TVectBool.normEuclid: NReal;
begin
  normEuclid := sqrt(ne2);
end;

function TVectBool.normMaxAbs: boolean;
var
  k: integer;
  maxA: boolean;
begin
  maxA := False;
  for k := 1 to N do
    if pv[k] then
    begin
      maxA := True;
      break;
    end;
  Result := maxA;
end;


procedure TMatBool.CopyColVect(var Y: TVectBool; J: integer);
var
  k: integer;
begin
  for k := 1 to nf do
    y.pon_e(k, e(k, j));
end;  (* CopyColVect *)



function TMatBool.Traza: integer;
var
  k: integer;
  temp: integer;
begin
  temp := 0;
  for k := 1 to nc do
    if e(k, k) then
      Inc(temp);
  Result := temp;
end; (* Traza *)


procedure TMatBool.Igual(m: TMatBool);
var
  k: integer;
begin
  setlength(pm, m.nf);
  for k := 1 to nf do
    pm[k].Igual(m.pm[k]);
end;

procedure TMatBool.Mult(a, b: TMatBool);
var
  k, j: integer;
  v: TVectBool;
  mtemp: TMatBool;
  cnt: integer;
begin
  v.Create_init(b.nf);
  mtemp.Create_init(a.nf, a.nc);
  mtemp.igual(a);
  for j := 1 to A.nc do
  begin
    b.CopyColVect(v, j);
    for k := 1 to A.nf do
    begin
      cnt := v.PEV(mtemp.fila(k));
      pon_e(k, j, cnt > 0);
    end;
  end;
  mtemp.Free;
  v.Free;
end;  (* MultTMatBool *)

end.
