unit Ocurrenx;
{
+NOMBRE: Ocurrenx.pas
+CREACION: 12.2.1992
+AUTOR: Ruben Chaer.
+REVISION: 8.3.1992
Domingo
+AUTOR: rch.
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Registrador de ocurrencias de una variable NReal.
+PROYECTO: ARTEF1. (RCh)
+DESCRIPCION:
}
interface

uses
  Classes,
  xMatDefs, MatEnt;

const
  c_sepQUATTRO: char = ','; { Separador para ExportarQUATTRO }
  c_sepEXCEL: char = #9; { Separador para ExportarEXCEL }
  c_sepTXT: char = ','; { Separador para ExportarTXT }



type
  TOcurrencias = class
    mayores,  {llevar  la cuenta de las ocurrencias
            mayores o iguales que sx2.}
    menores,  {cuenta de las ocurrencias menores que sx1}
    Total    {total de ocurrencias notificadas al objeto}: NEntero;

    x1,  {Origen del intervalo discretizado (sx1)}
    dx,   {Ancho del intervalo (sx2-sx1) }
    ddx   {Ancho de la discretizaci¢n. ( dx /NPDiv )}: NReal;

    NPDiv: integer;
    v  {Vector con las cuentas en cada franja}: TVectE;

    constructor Create_Init(sx1, sx2: NReal; NPDiv: integer);
    { Inicializa el objeto. Debe cumplirse sx2 > sx1}

    constructor Create_Load(var arch: TStream);
    procedure Store(var arch: TStream); virtual;
    procedure ExportarQUATTRO(var arch: Text); virtual;
    procedure ExportarEXCEL(var arch: Text); virtual;

    { Notifica de una ocurrencia. Con este procedimiento,
    le notificamos la ocurrencia de (x) al objeto. Segun donde
    caiga (x), se incrementaran los contadores }
    procedure Ocurrio(x: NReal);

    { Notifica de una ocurrencia que el valro x ocurrió nVeces.
    Segun donde  caiga (x), se incrementaran los contadores, en nVeces }
    procedure Ocurrio_nVeces(x: NReal; nVeces: integer);

    procedure Free; virtual;


    function res_peso(k: integer): NReal;
    { Devuelve la cuenta en v(k)/Total.
    k : 1..NPDiv
    v(1), conteiene la cantidad de ocurrencia de x en el
    intervalo sx1 <= x <sx1+ddx }

    procedure Print; virtual;
    function ValorMedio: NReal;
    procedure Maximo(var PesoMaximo: NReal; var PosicionDelMaximo: integer);

    // limpia todo los contadores
    procedure Clear;

  end;


implementation



procedure TOcurrencias.Clear;
begin
  v.Ceros;
  Total := 0;
  mayores := 0;
  menores := 0;
end;

constructor TOcurrencias.Create_Init(sx1, sx2: NReal; NPDiv: integer);
var
  k: integer;
begin
  inherited Create;
  Self.NPDiv := NPDiv;
  x1 := sx1;
  dx := sx2 - sx1;
  ddx := dx / NPDiv;
  v := TVectE.Create_Init(NPDiv);
  clear;
end;

constructor TOcurrencias.Create_Load(var arch: TStream);
begin
  inherited Create;
  arch.Read(mayores, sizeOf(mayores));
  arch.Read(menores, sizeOf(menores));
  arch.Read(Total, sizeOf(total));
  arch.Read(x1, sizeOf(NReal));
  arch.Read(dx, sizeOf(NReal));
  arch.Read(ddx, sizeOf(NReal));
  v := TVectE.Create_Load(arch);
end;

procedure TOcurrencias.Store(var arch: TStream);
begin
  arch.Write(mayores, sizeOf(mayores));
  arch.Write(menores, sizeOf(menores));
  arch.Write(Total, sizeOf(total));
  arch.Write(x1, sizeOf(NReal));
  arch.Write(dx, sizeOf(NReal));
  arch.Write(ddx, sizeOf(NReal));
  v.Store(arch);
end;

procedure TOcurrencias.Print;
var
  k: integer;
  x: NReal;
begin
  writeln('TOcurrencias.print...............');
  writeln(' Mayores: ', mayores);
  writeln(' Menores: ', menores);
  writeln(' Total: ', total);
  writeln(' x1: ', x1);
  writeln(' dx: ', dx);
  writeln(' ddx: ', ddx);
  v.print;
  for k := 1 to v.n do
  begin
    x := x1 + (k - 0.5) * ddx;
    writeln(x: 12: 4, c_SepTXT, res_peso(k): 10: 6);
  end;
end;

procedure TOcurrencias.ExportarQUATTRO(var arch: Text);
var
  k: integer;
  x: NReal;
begin
  x := x1 - ddx / 2;
  for k := 0 to v.n + 1 do
  begin
    writeln(arch, x: 12: 5, c_sepQUATTRO, res_peso(k): 12: 5);
    x := x + ddx;
  end;
end;



procedure TOcurrencias.ExportarEXCEL(var arch: Text);
var
  k: integer;
  x: NReal;
begin
  x := x1 - ddx / 2;
  for k := 0 to v.n + 1 do
  begin
    writeln(arch, x: 12: 5, c_sepEXCEL, res_peso(k): 12: 5);
    x := x + ddx;
  end;
end;


procedure TOcurrencias.Ocurrio(x: NReal);
begin
  Inc(total);
  if x < x1 then
    Inc(menores)
  else
  begin
    x := x - x1;
    if x >= dx then
      Inc(mayores)
    else
      Inc(v.pv[trunc(x / ddx) + 1]);
  end;
end;


procedure TOcurrencias.Ocurrio_nVeces(x: NReal; nVeces: integer);
begin
  Inc(total, nVeces);
  if x < x1 then
    Inc(menores, nVeces)
  else
  begin
    x := x - x1;
    if x >= dx then
      Inc(mayores, nVeces)
    else
      Inc(v.pv[trunc(x / ddx) + 1], nVeces);
  end;
end;

function TOcurrencias.res_peso(k: integer): NReal;
var
  temp: NReal;
begin
  if k = 0 then
    res_peso := menores / Total
  else
  if k = v.n + 1 then
    res_peso := mayores / Total
  else
  begin
    temp := v.e(k);
    res_peso := temp / total;
  end;
end;

procedure TOCurrencias.Free;
begin
  v.Free;
  inherited Free;
end;


function TOcurrencias.ValorMedio: NReal;
var
  k: integer;
  m, x: NReal;
begin
  x := (x1 - ddx);
  m := menores / total;
  for k := 1 to v.n + 1 do
  begin
    x := x + ddx;
    m := m + res_peso(k) * x;
  end;
  x := x + ddx;
  m := m + mayores / total;
  valorMedio := m;
end;


procedure TOcurrencias.Maximo(var PesoMaximo: NReal; var PosicionDelMaximo: integer);
var
  k, j: integer;
  m: NReal;
begin
  if total > 0 then
  begin
    m := menores;
    j := 0;
    for k := 1 to v.n do
      if v.e(k) > m then
      begin
        m := v.e(k);
        j := k;
      end;
    if mayores > m then
      m := mayores;
    j := v.n + 1;
    PesoMaximo := m / total;
    PosicionDelMaximo := j;
  end
  else
  begin
    PesoMaximo := 0;
    PosicionDelMaximo := 0;
  end;
end;


end.
