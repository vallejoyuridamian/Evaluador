{+doc
+NOMBRE: MatCPX
+CREACION: 1994
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: definicion del objeto matriz de complejos.
+PROYECTO: rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}
unit matcpx;

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}
interface

uses
  SysUtils,
  xMatDefs,
  Classes,
  AlgebraC;

type
  TVarArrayOfComplex = array of NComplex;

  TVectComplex = class
    v: TVarArrayOfComplex;
    constructor Create_Init(ne: integer);
    constructor Create_Load(var S: TStream);
    procedure Free;

    // ojo, esto no estaba bueno.
    //      constructor Create_OnVarArray( var vc: TVarArrayOfComplex );

    procedure e(var res: NComplex; k: word);
    procedure pon_e(k: word; var x: NComplex);
    procedure acum_e(k: word; var x: NComplex);
    procedure PEV(var res: NComplex; var y: TVectComplex); //res:= self.y
    procedure PorComplex(var r: NComplex);
    procedure sum(var y: TVectComplex);
    procedure sumComplexPV(var r: NComplex; var x: TVectComplex);
    function ne2: NReal; {norma euclideana al cuadrado }
    function normEuclid: NReal;
    function normMaxAbs: NReal;
    function normSumAbs: NReal;
    procedure Copy(var a: TVectComplex); // self <- a
    procedure Ceros; virtual;
    function pte(k: integer): PNComplex;
    function Get_n: integer;
    procedure Set_n(nn: integer);
    property n: integer read Get_n write Set_n;

    // suma los vectores A y B y guarda el resultado
    procedure sumvect(A, B: TVectComplex);

      {Si todos los elementos del vector son menores que (tol)
      el resultado de la función es true}
    function cond_epsilon(tol: NReal): boolean;

      {Si todos los elementos del vector son menores que los
      elementos de (tol)*PV correspondientes el resultado de la
      funcion es true}
    function cond_epsilonR(PX: TVectComplex; tol: NReal): boolean;

    {Escribe el vector en dos filas la primera con pa parte real
    la segunda con la parte imaginaria}
    procedure WriteToXlt(var f: textfile);

  end;


type
  TMatComplex = class
    nf, nc: integer;
    fila: array of TVectComplex;
    constructor Create_Init(nfilas, ncolumnas: integer);
    constructor Create_Load(var S: TStream);
    procedure Free;
    function pte(k, j: integer): PNComplex;
    procedure e(var res: NComplex; k, j: word);
    procedure pon_e(k, j: integer; x: NComplex);
    procedure acum_e(k, j: integer; x: NComplex);
    procedure Mult(a, b: TMatComplex);
    procedure Traza(var res: NComplex);
    procedure Deter(var res: NComplex);
    function Escaler(var i: TMatComplex; var invertible: boolean): NComplex;
    procedure CopyColVect(var Y: TVectComplex; J: integer);
    function Inv: boolean;
    procedure Ceros; virtual;
    procedure CerosFila(kfil: integer);
    procedure WriteToXlt(var f: textfile);
    procedure IntercambieFilas(k1, k2: integer);
    procedure Copy(var a: TMatComplex); // self <- a
  end;


implementation


procedure TMatComplex.IntercambieFilas(k1, k2: integer);
var
  tmp: TVectComplex;
begin
  tmp := fila[k1];
  fila[k1] := fila[k2];
  fila[k2] := tmp;
end;

procedure TMatComplex.copy(var a: TMatComplex);
var
  k: integer;
begin
  for k := 1 to high(fila) do
    fila[k].copy(a.fila[k]);
end;


function TMatComplex.pte(k, j: integer): PNComplex;
begin
  Result := fila[k].pte(j);
end;

constructor TMatComplex.Create_Init(nfilas, ncolumnas: integer);
var
  k: integer;
begin
  inherited Create;
  nf := nfilas;
  nc := ncolumnas;
  setlength(fila, nf + 1);
  for k := 1 to nf do
    fila[k] := TVectComplex.Create_Init(ncolumnas);
end;

constructor TMatComplex.Create_Load(var S: TStream);
var
  k: integer;

begin
  inherited Create;
  s.Read(nf, sizeOf(nf));
  s.Read(nc, sizeOf(nc));
  setlength(fila, nf + 1);
  for k := 1 to nf do
    fila[k] := TVectComplex.Create_Load(s);
end;

procedure TMatComplex.Free;
var
  k: integer;
begin
  for k := 1 to nf do
    fila[k].Free;
  setlength(fila, 0);
  inherited Free;
end;

procedure TMatComplex.e(var res: NComplex; k, j: word);
begin
  fila[k].e(res, j);
end;

procedure TMatComplex.pon_e(k, j: integer; x: NComplex);
begin
  fila[k].pon_e(j, x);
end;

procedure TMatComplex.acum_e(k, j: integer; x: NComplex);
begin
  fila[k].acum_e(j, x);
end;


constructor TVectComplex.Create_Init(ne: integer);
begin
  inherited Create;
  setlength(v, ne + 1);
end;

procedure TVectComplex.Free;
begin
  setlength(v, 0);
  inherited Free;
end;

constructor TVectComplex.Create_Load(var S: TStream);
var
  i, n: integer;
begin
  inherited Create;
  s.Read(n{%H-}, sizeOf(n));
  setlength(v, n + 1);
  for i := 1 to n do
    s.Read(v[i], SizeOf(NComplex));
end;


(** para aceptar esto habría que marcar que no liverara el v al FREE
También hay que tener cuidado que se hace con el casillero v[0]
constructor TVectComplex.Create_OnVarArray( var vc: TVarArrayOfComplex );
begin
   inherited Create;
   v:= vc;
end;
***)


function TVectComplex.pte(k: integer): PNComplex;
begin
  Result := @v[k];
end;

procedure TVectComplex.e(var res: NComplex; k: word);
begin
  res := v[k];
end;

procedure TVectComplex.pon_e(k: word; var x: NComplex);
begin
  v[k] := x;
end;

procedure TVectComplex.acum_e(k: word; var x: NComplex);
begin
  v[k] := sc(v[k], x)^;
end;


function TVectComplex.Get_n: integer;
begin
  Result := length(v) - 1;
end;

procedure TVectComplex.Set_n(nn: integer);
begin
  setlength(v, nn + 1);
end;


procedure TMatComplex.Ceros;
var
  k: integer;
begin
  for k := 1 to nf do
    fila[k].Ceros;
end;

   {
procedure TMatComplex.MinMax(
      var kMin, jMin:word;
      var kMax, jMax:word;
      var Min,  Max: NComplex);
var
  k, j: integer;
  m: NReal;
begin
  Min:=Complex(pte(1,1)^);
  Max:=Min;
  kmin:=1; jmin:=1; kmax:=1; jmax:=1;
  for k:= 1 to nf do
  begin
    for j:= 1 to nc do
    begin
      m:=Complex(pte(k,j)^);
      if mod2(m)<Min then
      begin
        kmin:=k;
        jmin:=j;
        min:=m;
      end
      else
      if m>Max then
      begin
        kmax:=k;
        jmax:=j;
        max:=m;
      end;
    end;
  end;
end;
    }

procedure TMatComplex.CerosFila(kfil: integer);
begin
  fila[kfil].Ceros;
end;



procedure TVectComplex.Ceros;
var
  k: integer;
begin
  for k := 0 to high(v) do
    v[k] := Complex_Nulo;
end;

{

procedure TVectComplex.MinMax( var kMin, kMax: word; var Min, Max:NComplex);
var
  k:integer;
  p:pointer;
begin
  p:=pv;
  Min:= Complex(p^); kMin:=1;
  Max:= Complex(p^); kMax:=1;
  for k:= 1 to n do
  begin
    if Complex(p^)<min then
    begin
      Min := Complex(p^);
      kMin:=k
    end
    else
      if Complex(p^) > max then
      begin
        Max := Complex(p^);
        kMax:= k
      end;
    inc(p)
  end
end;
 }

{ res:= Self.*.cc(y) // ojo, lo que está escrito es res:= Self.*.y (no cc)}
procedure TVectComplex.PEV(var res: NComplex; var y: TVectComplex);
var
  k: integer;
  temp: NComplex;
begin
  temp := complex_nulo;
  for k := 1 to high(v) do
    temp := sc(temp, pc(v[k], y.v[k])^)^;
  res := temp;
end;  (* PEV *)




function TVectComplex.cond_epsilon(tol: NReal): boolean;
var
  k: word;
  cond: boolean;
begin
  cond := True;
  for k := 1 to n do
    if mod1(v[k]) >= tol then
      cond := False;
  Result := cond;
end;


function TVectComplex.cond_epsilonR(PX: TVectComplex; tol: NReal): boolean;
var
  j: integer;
  cond: boolean;
  res1, res2: NComplex;
begin
  j := 0;
  cond := True;
  if n <> PX.n then
    raise Exception.Create('los vectores deben ser de la misma dimension');
  while (j < n) and (cond = True) do
  begin
    j := j + 1;
    e(res1{%H-}, j);
    PX.e(res2{%H-}, j);
    if (mod1(res1)) >= (tol * mod1(res2)) then
      cond := False;
  end;
  Result := cond;
end;


procedure TVectComplex.WriteToXlt(var f: textfile);

var
  k: integer;
  x: NComplex;

begin
  Write(f, 'r:');
  for k := 1 to n do
  begin
    e(x, k);
    Write(f, #9, x.r);
  end;
  writeln(f);

  Write(f, 'i:');
  for k := 1 to n do
  begin
    e(x, k);
    Write(f, #9, x.i);
  end;
  writeln(f);

end;



procedure TVectComplex.Copy(var a: TVectComplex);
var
  k: integer;
begin
  for k := 1 to n do
    v[k] := a.v[k];
end;


procedure TVectComplex.sum(var y: TVectComplex);
var
  k: integer;
begin
  for k := 0 to high(v) do
    v[k] := sc(v[k], y.v[k])^;
end;

procedure TVectComplex.sumvect(A, B: TVectComplex);
var
  k: integer;
begin
  for k := 0 to high(v) do
    v[k] := sc(A.v[k], B.v[k])^;
end;



procedure TVectComplex.sumComplexPV(var r: NComplex; var x: TVectComplex);
var
  k: integer;
begin
  for k := 0 to high(v) do
    v[k] := sc(v[k], pc(r, x.v[k])^)^;
end;


procedure TVectComplex.PorComplex(var r: NComplex);
var
  k: integer;
begin
  for k := 0 to high(v) do
    v[k] := pc(v[k], r)^;
end;

function TVectComplex.ne2: NReal; {norma euclideana al cuadrado }
var
  k: integer;
  acum: NReal;
begin
  acum := 0;
  for k := 0 to high(v) do
    acum := acum + mod2(v[k]);
  Result := acum;
end;

function TVectComplex.normEuclid: NReal;
begin
  Result := sqrt(ne2);
end;

function TVectComplex.normMaxAbs: NReal;
var
  k: integer;
  maxA: NReal;
begin
  maxA := 0;
  for k := 0 to high(v) do
    if mod2(v[k]) > maxA then
      maxA := mod2(v[k]);
  Result := sqrt(maxA);
end;

function TVectComplex.normSumAbs: NReal;
var
  k: integer;
  acum: NReal;
begin
  acum := 0;
  for k := 0 to high(v) do
    acum := acum + sqrt(mod2(v[k]));
  Result := acum;
end;

procedure TMatComplex.WriteToXlt(var f: textfile);
var
  k, j: integer;
  c: NComplex;
begin
  writeln(f, 'parte real -----------');
  for k := 1 to nf do
  begin
    for j := 1 to nc do
    begin
      e(c, k, j);
      if j > 1 then
        Write(f, #9);
      Write(f, c.r);
    end;
    writeln(f);
  end;
  writeln(f, 'parte imaginaria -----------');
  for k := 1 to nf do
  begin
    for j := 1 to nc do
    begin
      e(c, k, j);
      if j > 1 then
        Write(f, #9);
      Write(f, c.i);
    end;
    writeln(f);
  end;

end;

procedure Combinar(Eliminada, Eliminador: TVectComplex; Col1, Col2: integer;
  m: NComplex);
var
  j: integer;
begin
  for j := Col1 to Col2 do
    Eliminada.pon_e(j, sc(Eliminada.v[j], pc(Eliminador.v[j], m)^)^);
end;


function TMatComplex.Escaler(var i: TMatComplex; var invertible: boolean): NComplex;
{$ifdef testdeter }
  procedure muestre;
  begin
    writeM;
    i.writeM;
    readln;
    writeln('===============');
  end;

{$endif}

var
  k, p, j: integer;
  ptfe: TVarArrayOfComplex;
  det, mc1, mcoef: NComplex;
  m, ms: NReal;

begin
  invertible := True;
  p := 1;
  det := numc(1, 0)^;
  {esca1}
  while invertible and (p < nf) do
  begin
    {$ifdef testdeter }
    muestre;
    {$endif}

    // buscamos el mejor pivote en la columna p
    // en las filas de p a n
    m := mod2(fila[p].v[p]);
    j := p;
    for k := p + 1 to nf do
    begin
      ms := mod2(fila[k].v[p]);
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
      det := prc(-1, det)^;
    end;

    if m <= AsumaCero then
    begin
      det := complex_Nulo;
      invertible := False;
      p := nf;
    end
    else{eliminacion}
    begin
      e(mc1, p, p);
      det := pc(det, mc1)^;
      if mod2(det) > AsumaCero then
      begin
        for k := p + 1 to nf do
        begin
          mcoef := prc(-1, dc(fila[k].v[p], mc1)^)^;
          Combinar(fila[k], fila[p], p + 1, nc, mcoef);
          Combinar(i.fila[k], i.fila[p], 1, i.nc, mcoef);
        end;
      end
      else
        invertible := False;
    end;
    p := p + 1;
  end;(* while *)

  det := pc(det, fila[nf].v[nf])^;

  if invertible and (mod2(det) > AsumaCero) then
  begin{esca2}
    for k := 1 to nf do
    begin
      {$ifdef testdeter }
      muestre;
      {$endif}
      ptfe := fila[k].v;
      mc1 := invc(ptfe[k])^;
      i.fila[k].PorComplex(mc1);
      for j := nc downto k + 1 do
        ptfe[j] := pc(ptfe[j], mc1)^;
    end;

    for p := nf downto 2 do
    begin
      for k := p - 1 downto 1 do
      begin
        e(mc1, k, p);
        mc1 := prc(-1, mc1)^;
        Combinar(i.fila[k], i.fila[p], 1, i.nc, mc1);
      end;
    end;
  end
  else
    invertible := False;

  if not invertible then
    det := complex_NULO;
  Result := det;
  {$ifdef testdeter }
  muestre;
  {$endif}
end {deter};


procedure TMatComplex.CopyColVect(var Y: TVectComplex; J: integer);
var
  k: integer;
begin
  for k := 1 to nc do
    y.v[k] := fila[k].v[j];
end;  (* CopyColVect *)



procedure TMatComplex.Traza(var res: NComplex);
var
  k: integer;
  temp: NComplex;
begin
  temp := fila[1].v[1];
  for k := 2 to nf do
    temp := sc(temp, fila[k].v[k])^;
  res := temp;
end; (* Traza *)



procedure TMatComplex.Mult(a, b: TMatComplex);
var
  k, j: integer;
  v: TVectComplex;
  mtemp: TMatComplex;

  c: NComplex;

begin
  v := TVectComplex.Create_Init(b.nf);
  // copiamos la matriz A por si la modificamos
  mtemp := TMatComplex.Create_init(a.nf, a.nc);
  mtemp.copy(a);
  for j := 1 to A.nc do
  begin
    b.CopyColVect(v, j);
    for k := 1 to nf do
    begin
      v.PEV(c, mtemp.fila[k]);
      fila[k].v[j] := c;
    end;
  end;
  mtemp.Free;
  v.Free;
end;

procedure TMatComplex.deter(var res: NComplex);
var
  temp1, temp2: TMatComplex;
  tmp: NComplex;
  invertible: boolean;
begin
  temp1 := TMatComplex.Create_init(nf, nc);
  temp1.copy(Self);
  temp2 := TMatComplex.Create_init(0, 0);
  tmp := temp1.escaler(temp2, invertible);
  temp2.Free;
  temp1.Free;
  res := tmp;
end;

function TMatComplex.inv: boolean;
var
  temp: TMatComplex;
  k, j: integer;
  invertible: boolean;

begin
  temp := TMatComplex.Create_init(nf, nc);
  for k := 1 to nf do
    for j := 1 to nc do
      if k = j then
        temp.pon_e(k, j, complex_UNO)
      else
        temp.pon_e(k, j, complex_NULO);
  escaler(temp, invertible);
  copy(temp);
  temp.Free;
  Result := invertible;
end;

begin
(*
writeln('Unidad MatReal INSTALADA / RCH-90');
*)
end.
