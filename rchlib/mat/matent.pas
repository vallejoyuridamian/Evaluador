{+doc
+NOMBRE: MatEnt
+CREACION: 6.1.1994
+AUTORES: rch @floresta
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: definicion del objeto MatEiz de enteros.
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
  Todas las tareas implementadas en esta biblioteca, tienen como
filosofia que los datos estan bien definidos, y para mejorar la
velocidad no verifican la coherencia. Tampoco se encargan de
inicializar MatEices. Supongamos que vamos a multiplicar las
MatEices A y B , y queremos el resultado en C, la sentecia es
C.MultM(A,B); pero se debe cuidar que los rangos sean los adecuados
y se debe inicializar C antes del llamado a MultMatE.
  Las unicas tareas que inicializan  datos del objeto son las de
lectura. Ej: a.readM; inicialliza a.

-doc}

unit MatEnt;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Math,
  Classes, SysUtils, xMatDefs, ComPol;

type

  { TVectE }

  TVectE = class
    n: integer;
    pv: TDAOfNInt;
    constructor Create_Init(ne: integer);
    //      constructor Create_Ventana( ne: integer; var x );
    constructor Create_Load(var S: TStream);
    procedure Store(var S: TStream);

    // retorna un string con { v1, v2, v3 .... vn } como para ser cargado en un campo de PostGreSQL
    function serialize_pg: string;

    // se crea a partir de un string como el devuelto por serialize_pg
    constructor Create_unserialize_pg(s: string; c_open: char = '{';
      c_close: char = '}');

    procedure Igual(x: TVectE);
    function e(k: integer): NEntero;
    procedure pon_e(k: integer; x: NEntero);
    procedure acum_e(k: integer; x: NEntero);
    procedure IntercambiarElementos(k1, k2: integer);
    function PEV(var y: TVectE): NEntero;
    function PEVRFLX(var y: TVectE): NEntero;
    procedure PorEntero(r: NEntero);
    procedure sum(var y: TVectE);
    procedure sumRPV(r: NEntero; var x: TVectE);
    function ne2: NEntero; {norma euclideana al cuadrado }
    function normEuclid: NReal;
    function normMaxAbs: NEntero;
    function normSumAbs: NEntero;
    procedure Copy(var x: TVectE);
    procedure Ceros; virtual;
    procedure MinMax(var kMin, kMax: integer; var Min, Max: NEntero);
    procedure Print; virtual;
    procedure Free; virtual;
  end;


type

  { TMatE }

  TMatE = class
    nf, nc: integer;
    pm: array of TVectE;


    // No inicializa las filas. Es para llamar si otro procedimiento
    // creará los TVectR de pm
    constructor Create_Init_pm(filas, columnas: integer);

    constructor Create_Init(filas, columnas: integer);

    constructor Create_Load(var S: TStream);
    procedure Store(var S: TStream);

    constructor Create_Load_COMPRESS_(var S: TStream);
    procedure Store_COMPRESS_(var S: TStream);


    constructor Create_ReadM; (* a debe estar sin inicializar *)

    // retorna un string con {{ v11, v12 },{ v21, v22 }} como para ser cargado
    // en un campo de PostGreSQL
    function serialize_pg: string;

    // se crea a partir de un string como el devuelto por serialize_pg
    constructor Create_unserialize_pg(s: string; c_open: char = '{'; c_close: char = '}');

    procedure Igual(x: TMatE);
    function e(k, j: integer): NEntero;
    procedure pon_e(k, j: integer; x: NEntero);
    procedure acum_e(k, j: integer; x: NEntero);

    // busca el mínimo y máximo de la matriz
    procedure MinMax(var kMin, jMin: integer; var kMax, jMax: integer;
      var Min, Max: integer); overload;

    // Si no interesan los índices usar esta
    procedure MinMax(var Min, Max: integer); overload;

    procedure IntercambieFilas(k1, k2: integer);
    procedure Mult(a, b: TMatE);
    procedure WriteM;
    function Traza: NEntero;
    function Deter: NEntero;
    function Escaler(var i: TMatE): NEntero;
    procedure CopyColVect(var Y: TVectE; J: integer);
    function inv: boolean;
    procedure Ceros; virtual;
    procedure Free; virtual;
  end;



implementation


function nextpal(var r: string; sep: string = #9): string;
var
  s: string;
  i: integer;
begin
  i := pos(sep, r);
  if i = 0 then
  begin
    s := trim(r);
    r := '';
  end
  else
  begin
    s := trim(copy(r, 1, i - 1));
    Delete(r, 1, i + length(sep) - 1);
  end;
  Result := s;
end;


constructor TMatE.Create_Init_pm(filas, columnas: integer);
var
  k: integer;
begin
  inherited Create;
  setlength(pm, filas + 1); // la fila 1 la desperdicio
  nf := filas;
  nc := columnas;
end;

constructor TMatE.Create_Init(filas, columnas: integer);
var
  k: integer;
begin
  Create_Init_pm(filas, columnas);
  for k := 1 to filas do
    pm[k] := TVectE.Create_Init(columnas);
end;


constructor TMatE.Create_Load(var S: TStream);
var
  k: integer;
begin
  inherited Create;
  S.Read(nf, sizeOf(nf));
  S.Read(nc, sizeOf(nc));
  setlength(pm, nf + 1);
  for k := 1 to nf do
    pm[k] := TVectE.Create_Load(s);
end;

procedure TMatE.Store(var S: TStream);
var
  k: integer;
begin
  S.Write(nf, sizeOf(nf));
  S.Write(nc, sizeOf(nc));
  for k := 1 to nf do
    pm[k].Store(s);
end;

constructor TMatE.Create_Load_COMPRESS_(var S: TStream);
var
  vmin, vmax, deltav: integer;
  vdata: packed array of byte;
  a1: byte;
  a2: word;
  a4: cardinal;
  a8: qword;
  pvv: TDAofNINt;
  k, j: integer;
  flg_Constante: boolean;
  p1: ^byte;
  p2: ^word;
  p4: ^cardinal;
  p8: ^qword;
  nbytesPerValue: byte;

begin
  S.Read(nf, sizeOf(nf));
  S.Read(nc, sizeOf(nc));
  Create_Init( nf, nc );

  s.Read( nbytesPerValue, 1 );
  s.Read( vmin, SizeOF( vmin ) );
  s.Read( vmax, sizeOf( vmax ) );

  deltav:= vmax - vmin;

  flg_Constante:= deltav < 1e-30;

  if flg_Constante then
    vmax:= vmin;

  if flg_constante then exit;


  setlength( vdata, nf * nc * nbytesPerValue );

  s.Read( vdata, length( vdata ) );

  p1:= @vdata[0];
  p2:= @vdata[0];
  p4:= @vdata[0];
  p8:= @vdata[0];

  case nbytesPerValue of
  1:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         pvv[j]:= p1^;
         inc( p1 );
       end;
     end;

  2:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         pvv[j]:= p2^;
         inc( p2 );
       end;
     end;
  4:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         pvv[j]:= p4^;
         inc( p4 );
       end;
     end;
  8:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         pvv[j]:= p8^;
         inc( p8 );
       end;
     end;
  else
    raise exception.Create('TMatE.Create_Load_COMPRESS: nBytesPerValue=[1|2|4|8]' );
  end;
end;


procedure TMatE.Store_COMPRESS_(var S: TStream);
var
  vmin, vmax, deltav: integer;
  vdata: packed array of byte;
  a1: byte;
  a2: word;
  a4: cardinal;
  a8: qword;
  pvv: TDAofNInt;
  k, j: integer;
  flg_Constante: boolean;
  p1: ^byte;
  p2: ^word;
  p4: ^cardinal;
  p8: ^qword;
  nbytesPerValue: integer;
  m: qword;
begin
  self.MinMax( vmin, vmax );
  deltav:= vmax - vmin;

  m:= qword($FFFFFFFFFFFFFFFF);
  nBytesPerValue:= 8;
  while ( m and deltav ) <> 0 do
  begin
    m:= m shr 8;
    dec( nBytesPerValue );
  end;
  nBytesPerValue:= 8 - nBytesPerValue;

  s.write( nf, sizeof( nf ) );
  s.write( nc, sizeOf( nc ) );
  flg_Constante:= deltav = 0;

  if flg_Constante then
    vmax:= vmin;
  s.Write( nbytesPerValue, 1 );
  s.write( vmin, SizeOF( vmin ) );
  s.write( vmax, sizeOf( vmax ) );

  if flg_constante then exit;


  setlength( vdata, nf * nc * nbytesPerValue );
  p1:= @vdata[0];
  p2:= @vdata[0];
  p4:= @vdata[0];
  p8:= @vdata[0];

  case nbytesPerValue of
  1:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         a1:= pvv[j] - vmin;
         p1^:= a1;
         inc( p1 );
       end;
     end;

  2:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         a2:= pvv[j] - vmin;
         p2^:= a2;
         inc( p2 );
       end;
     end;
  4:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         a4:= pvv[j] - vmin;
         p4^:= a4;
         inc( p4 );
       end;
     end;
  8:
     for k:= 1 to nf do
     begin
       pvv:= pm[k].pv;
       for j:= 1 to nc do
       begin
         a8:= pvv[j] - vmin;
         p8^:= a8;
         inc( p8 );
       end;
     end;
  else
    raise exception.Create('TMatE.Store_COMPRESS: nBytesPerValue=[1|2|4|8]' );
  end;

 s.Write( vdata, length( vdata ) );
 setlength( vdata, 0 );
end;



function TMatE.e(k, j: integer): NEntero;
begin
  e := pm[k].e(j);
end;

procedure TMatE.pon_e(k, j: integer; x: NEntero);
begin
  pm[k].pon_e(j, x);
end;

procedure TMatE.acum_e(k, j: integer; x: NEntero);
begin
  pm[k].acum_e(j, x);
end;

procedure TMatE.MinMax(var kMin, jMin: integer; var kMax, jMax: integer;
  var Min, Max: integer);
var
  k, j: integer;
  nuevo_min, nuevo_max: integer;
  nuevo_jmin, nuevo_jmax: integer;
begin
  kmin := 1;
  kmax := 1;
  pm[1].MinMax(jMin, jMax, Min, Max);
  for k := 2 to nf do
  begin
    pm[k].MinMax(nuevo_jMin, nuevo_jMax, nuevo_min, nuevo_max);
    if nuevo_min < min then
    begin
      jmin := nuevo_jmin;
      kmin := k;
      min := nuevo_min;
    end;
    if nuevo_max > max then
    begin
      jmax := nuevo_jmax;
      kmax := k;
      max := nuevo_max;
    end;
  end;
end;

procedure TMatE.MinMax(var Min, Max: integer);
var
  kmin, jmin, kmax, jmax: integer;
begin
  MinMax(kmin, jmin, kmax, jmax, Min, Max);
end;




constructor TVectE.Create_Init(ne: integer);
begin
  inherited Create;
  n := ne;
  setlength(pv, ne + 1);
end;

constructor TVectE.Create_Load(var S: TStream);
begin
  inherited Create;
  S.Read(n, sizeOf(n));
  setlength(pv, n + 1);
  S.Read(pv[1], n * SizeOf(integer));
end;


procedure TVectE.Store(var S: TStream);
begin
  S.Write(n, sizeOf(n));
  S.Write(pv[1], n * SizeOf(NReal));
end;

function TVectE.serialize_pg: string;
var
  k: integer;
  res: string;
begin
  res := '{';
  if n > 0 then
  begin
    res := res + IntToStr(e(1));
    for k := 2 to n do
      res := res + ', ' + IntToStr(e(k));
  end;
  res := res + ' }';
  Result := res;
end;

constructor TVectE.Create_unserialize_pg(s: string; c_open: char; c_close: char);
var
  k: integer;
  cnt: integer;
  pal: string;
begin
  cnt := 0;
  for k := 1 to length(s) do
    if s[k] = ',' then
      Inc(cnt);
  Create_init(cnt + 1);
  pal := nextpal(s, c_open);
  for k := 1 to n - 1 do
  begin
    pal := nextpal(s, ',');
    pv[k] := StrToInt(pal);
  end;
  pal := nextpal(s, c_close);
  pv[n] := StrToInt(pal);
end;


procedure TVectE.Free;
begin
  setlength(pv, 0);
  inherited Free;
end;


procedure TVectE.Print;
var
  k: integer;
begin
  writeln(' TVectE.print.inicio');

  for k := 1 to n do
    writeln(' N: ', k: 6, ' : ', e(k): 12);
  writeln(' TVectE.print.fin');

end;

(*
constructor TVectE.Ventana( ne: integer; var x );
begin
  TVect.Ventana( ne, SizeOf(NEntero), x);
end;
  *)

function TVectE.e(k: integer): NEntero;
begin
  e := pv[k];
end;


procedure TVectE.Igual(x: TVectE);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := x.pv[k];

end;


procedure TVectE.pon_e(k: integer; x: NEntero);
begin
  pv[k] := x;
end;

procedure TVectE.acum_e(k: integer; x: NEntero);
begin
  pv[k] := pv[k] + x;
end;

procedure TVectE.IntercambiarElementos(k1, k2: integer);
var
  x: integer;
begin
  x := e(k1);
  pon_e(k1, e(k2));
  pon_e(k2, x);
end;


procedure TMatE.Ceros;
var
  k: integer;
begin
  for k := 1 to nc do
    pm[k].Ceros;

end;


procedure TVectE.Ceros;
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := 0;
end;


procedure TVectE.MinMax(var kMin, kMax: integer; var Min, Max: NEntero);
var
  k: integer;
begin
  Min := pv[1];
  kMin := 1;
  Max := pv[1];
  kMax := 1;
  for k := 1 to n do
  begin
    if pv[k] < min then
    begin
      Min := pv[k];
      kMin := k;
    end
    else
    if pv[k] > max then
    begin
      Max := pv[k];
      kMax := k;
    end;
  end;
end;


function TVectE.PEV(var y: TVectE): NEntero;
var
  k: integer;
  temp: NEntero;
begin
  temp := 0;
  for k := 1 to n do
    temp := temp + pv[k] * y.pv[k];
  Result := temp;
end;  (* PEV *)


function TVectE.PEVRFLX(var y: TVectE): NEntero;
var
  k: integer;
  temp: NEntero;
begin
  temp := 0;
  for k := 1 to n do
    temp := temp + pv[k] * y.pv[n - k + 1];
  Result := temp;
end;  (* PEVRFLX *)



procedure TVectE.Copy(var x: TVectE);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := x.pv[k];
end;


procedure TVectE.sum(var y: TVectE);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := pv[k] + y.pv[k];
end;

procedure TVectE.sumRPV(r: NEntero; var x: TVectE);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := pv[k] + r * x.pv[k];
end;


procedure TVectE.PorEntero(r: NEntero);
var
  k: integer;
begin
  for k := 1 to n do
    pv[k] := pv[k] * r;
end;

function TVectE.ne2: NEntero; {norma euclideana al cuadrado }
var
  k: integer;
  acum: NEntero;
begin
  acum := 0;
  for k := 1 to n do
    acum := acum + SQR(pv[k]);
  ne2 := acum;
end;

function TVectE.normEuclid: NReal;
begin
  normEuclid := sqrt(ne2);
end;

function TVectE.normMaxAbs: NEntero;
var
  k: integer;
  maxA: NEntero;
begin
  maxA := 0;
  for k := 1 to n do
    if ABS(pv[k]) > maxA then
      maxA := Abs(pv[k]);
  normMaxAbs := maxA;
end;

function TVectE.normSumAbs: NEntero;
var
  k: integer;
  acum: NEntero;
begin
  acum := 0;
  for k := 1 to n do
    acum := acum + ABS(pv[k]);
  normSumAbs := acum;
end;

procedure TMatE.WriteM;
var
  k, J: integer;
begin
  writeln;
  writeln('---------------------------------------');
  for k := 1 to nf do
  begin
    Write('fila', k: 3, '):');
    for j := 1 to nc do
      Write(e(k, j): 12);
    writeln;
  end;
end;


procedure TMatE.Free;
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].Free;
  setlength(pm, 0);
  inherited Free;
end;


constructor TMatE.Create_ReadM; (* a debe estar sin inicializar *)
var
  k, J: integer;
  m: integer;
begin

  writeln;
  writeln('---------------------------------------');
  Write('numero de filas=?');
  readln(k);
  Write('numero de columnas=?');
  readln(j);
  Create_init(k, j);
  for k := 1 to nf do
  begin
    Write('fila', k: 3, '):?');
    for j := 1 to nc do
    begin
      Read(m);
      pon_e(k, j, m);
    end;
    writeln;
  end;
end;

function TMatE.serialize_pg: string;
var
  res: string;
  k: integer;

begin
  res := '{';
  if nf > 0 then
  begin
    res := res + pm[1].serialize_pg;
    for k := 2 to nf do
      res := res + ', ' + pm[k].serialize_pg;
  end;
  res := res + '}';
  Result := res;
end;


constructor TMatE.Create_unserialize_pg(s: string; c_open: char; c_close: char);
var
  cnt_Aperturas, cnt_Comas: integer;
  nfilas, ncolumnas: integer;
  k: integer;
  c: char;
  sfila: string;
  // { { 1, 2, 3}, { 3, 4, 5 } }
  // nComas:= ( nColumnas  - 1 ) * nFilas + ( nFilas - 1)
  // nColumnas = ( nComas - nFilas + 1 ) / nFilas + 1
begin
  cnt_Aperturas := 0;
  cnt_Comas := 0;
  for k := 1 to length(s) do
  begin
    c := s[k];
    if c = c_open then
      Inc(cnt_Aperturas)
    else if c = ',' then
      Inc(cnt_Comas);
  end;
  nFilas := cnt_Aperturas - 1;
  if nFilas > 0 then
    nColumnas := (cnt_Comas - nFilas + 1) div nFilas + 1
  else
    nFilas := 0;

  Create_Init_pm(nFilas, nColumnas);

  nextpal(s, c_open);
  for k := 1 to nFilas do
  begin
    sfila := c_open + nextPalEntre(s, c_open, c_close) + c_close;
    pm[k] := TVectE.Create_unserialize_pg(sfila, c_open, c_close);
  end;
end;


procedure TMatE.IntercambieFilas(k1, k2: integer);
var
  t: TVectE;
begin
  t := pm[k1];
  pm[k1] := pm[k2];
  pm[k2] := t;
end;


procedure Combinar_E(Eliminada, Eliminador: TVectE; Col1, Col2: integer;
  m1, m2: NEntero);
var
  j: integer;
begin
  for j := Col1 to Col2 do
    Eliminada.pon_e(j, Eliminada.e(j) * m1 + Eliminador.e(j) * m2);
end;

function TMatE.Escaler(var i: TMatE): NEntero;
var
  k, p, j: integer;
  det, m, mc1: NEntero;
  ms: NEntero;

begin { Escaler }

  p := 1;
  det := 1;

  while p < nf do { ESCA 1 }
  begin
    m := abs(e(p, p));
    j := p;
    for k := p + 1 to nf do
    begin
      ms := abs(e(k, p));
      if ms > m then
      begin
        m := ms;
        j := k;
      end;
    end;
    if p <> j then
    begin
      IntercambieFilas(p, j);
      i.IntercambieFilas(p, j);
      det := -det;
    end;
    if m = 0 then
    begin
      det := 0;
      p := nf;
    end
    else{eliminacion}
    begin
      mc1 := e(p, p);
      det := det * mc1;
      for k := p + 1 to nf do
      begin
        m := -e(k, p);
        Combinar_E(pm[k], pm[p], p + 1, nc, mc1, m);
        Combinar_E(i.pm[k], i.pm[p], 1, i.nc, mc1, m);
      end;
    end; { Eliminación }
    p := p + 1;
  end; { Esca 1 }

  det := det * e(nf, nf);

  if det <> 0 then {Esca 2 }
  begin
    for p := nf downto 2 do
    begin
      m := e(p, p);
      for k := p - 1 downto 1 do
      begin
        mc1 := -e(k, p);
        Combinar_E(i.pm[k], i.pm[p], 1, i.nc, mc1, m);
      end;
    end;
  end; { Esca 2 }
  Escaler := det;
end; {deter}


procedure TMatE.CopyColVect(var Y: TVectE; J: integer);
var
  k: integer;
begin
  for k := 1 to nf do
    y.pon_e(k, e(k, j));
end;  (* CopyColVect *)




function TMatE.Traza: NEntero;
var
  k: integer;
  temp: NEntero;

begin
  temp := e(1, 1);
  for k := 2 to nc do
    temp := temp + e(k, k);
  Result := temp;
end; (* Traza *)

procedure TMatE.Igual(x: TMatE);
var
  k: integer;
begin
  for k := 1 to nf do
    pm[k].Igual(x.pm[k]);
end;


procedure TMatE.Mult(a, b: TMatE);
var
  k, j: integer;
  v: TVectE;
  mtemp: TMatE;

begin
  v := TVectE.Create_init(b.nf);
  mtemp := TMatE.Create_init(a.nf, a.nc);
  mtemp.igual(a);

  for j := 1 to b.nc do
  begin
    b.CopyColVect(v, j);
    for k := 1 to A.nf do
      pon_e(k, j, v.PEV(mtemp.pm[j]));
  end;
  mtemp.Free;
  v.Free;
end;  (* MultTMatE *)



function TMatE.Deter: NEntero;
var
  temp1, temp2: TMatE;
begin
  temp1 := TMatE.Create_init(nf, nc);
  temp1.igual(Self);
  temp2 := TMatE.Create_init(nf, 0);
  deter := temp1.escaler(temp2);
  temp2.Free;
  temp1.Free;
end;




function TMatE.inv: boolean;
var
  temp: TMatE;
  k, j: integer;
  aux: NReal;
begin
  temp := TMatE.Create_init(nf, nc);
  for k := 1 to nf do
    for j := 1 to nc do
      if k = j then
        temp.pon_e(k, j, 1)
      else
        temp.pon_e(k, j, 0);

  aux := Self.escaler(temp);
  Self.igual(temp);
  temp.Free;
  Inv := not EsCero(aux);
end;

begin
(*
writeln('Unidad MatE INSTALADA / RCH-90');
*)
end.
