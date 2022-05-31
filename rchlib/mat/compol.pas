{+doc
+NOMBRE: ComPol
+CREACION: 12/03/94
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Definición de servicios de polinomios de coeficientes
reales y numero complejos.
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

(* Algebra de Complejos y de Polinomios /RCH89 *)

unit ComPol;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, xmatdefs;


 (*
  TPR0= array[0..6000] of NReal;
  PPR0=^TPR0;
  *)


{ Polinomios de coeficientes reales }
type

  PPoliR = ^TPoliR;

  TPoliR = class

    a: TDAOfNReal;
    gr: integer;

    //inicializa el vector de coeficientes con lugar  para MaxGr+1 coeficientes
    constructor Create_Init(MaxGr: integer);

    // crea el polinomio que y=p(x), de grado "gr" que mejor aproxima la tabla de puntos
    // retorna false si no es posible la aproximación
    function AproxTabla2D(gr: integer; x, y: TDAOfNReal): boolean;

    procedure Free; virtual;

    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;

    procedure ValPR(var c: NComplex; s: NComplex);
    (* c := p(s) *)

    function Valx(x: NReal): NReal;
    (* Valx:= p(x) *)

    procedure derive;
    (* p(s) := p'(s) *)

    function RouthHurwitz: integer;
    (* devuelve el numero de raices en el semiplano derecho *)
    (* si el algoritmo no es aplicable devuelve -1               *)

    function Jury: integer;
    (* devuelve el mumero de raices exteriores al circulo unidad *)
    (* si el algoritmo no es aplicable devuelve -1               *)

    procedure CambioVar(b: NReal);
    (*  a(s):=a(s+b) *)

    procedure Homotecia(b: NReal);
    {q(s) := b^q.gr * q(s/b)}

    function RaicesDerecha(a: NReal): integer;
    (* numero de raices de p(x) a la derecha  x = a *)

    function PRR(nraiz: integer; error: NReal): NReal;
    (* parte NReal de la raiz numero n *)

    procedure AjusteGrado;
    (* Decrementa el grado hasta que el primer coeficiente sea no nulo
      o el grado sea cero *)

    function CocienteResto(var Cociente, Resto, Divisor: TPoliR): integer;
    (* retorna en cosiento y resto el cosiente y el resto respectiva-
      mente de realizar la división por el polinomio divisor *)
  end;


procedure WritelnComp(c: NComplex);
procedure WriteComp(c: NComplex);
procedure ReadComp(var c: NComplex);

procedure Sum(var a: NComplex; b, c: NComplex);
(* a := b+c *)

procedure Pro(var a: NComplex; b, c: NComplex);
(* a := b*c *)

procedure Divi(var a: NComplex; b, c: NComplex);
(* a := b/c *)

procedure Cnj(var p: NComplex; c: NComplex);
(* p := comjugado(c) *)

function Mod2(c: NComplex): NReal;
(* modulo al cuadrado de c *)

function Modulo(c: NComplex): NReal;
(* modulo de c *)


implementation

uses
  matreal;

constructor TPoliR.Create_Init(MaxGr: integer);
begin
  inherited Create;
  setlength(a, MaxGr + 1);
  { Inicializamos con el polinomio nulo }
  gr := 0;
  a[0] := 0;
end;

// crea el polinomio y=p(x) de grado Gr que mejor aproxima la tabla.
function TPoliR.AproxTabla2D(gr: integer; x, y: TDAOfNReal): boolean;
var
  mA, mB: TMatR;
  i, k, j: integer;
  xaux, potxk, potxj: NReal;
  resInv: boolean;
  NDatos: integer;
  N: integer;
  e10: integer;

begin
  setlength(a, gr + 1);
  self.gr := gr;

  NDatos := length(x);
  N := gr + 1;

  // armamos el sistema para obtener los coeficientes del polinomio
  // de grado dado que mejor describe la funcion.
  mA := TMatR.Create_Init(N, N);
  mB := TMatR.Create_Init(N, 1);

  mA.Ceros;
  mb.Ceros;

  for i := 0 to NDatos - 1 do
  begin
    xaux := x[i];
    potxk := 1;
    for k := 1 to N do
    begin
      potxj := potxk;
      for j := k to N do
      begin
        mA.acum_e(k, j, potxk * potxj);
        potxj := potxj * xaux;
      end;
      mB.acum_e(k, 1, y[i] * potxk);
      potxk := potxk * xaux;
    end;
  end;

  // ahora completamos el tríangulo inferior
  for k := 2 to N do
    for j := 1 to k - 1 do
      mA.pon_e(k, j, mA.e(j, k));

  mA.Escaler(mB, resInv, e10);
  if resInv then
  begin
    for k := 1 to N do
      a[k - 1] := mb.e(k, 1);
  end
  else
    self.gr := 0;

  mA.Free;
  mB.Free;
  Result := resInv;
end;

procedure TPoliR.Free;
begin
  setlength(a, 0);
  inherited Free;
end;

constructor TPoliR.Load(var S: TStream);
var
  n: integer;
begin
  inherited Create;
  S.Read(n{%H-}, sizeOf(n));
  setlength(a, n);
  S.Read(gr, SizeOf(gr));
  S.Read(a[0], (gr + 1) * SizeOf(NReal));
end;

procedure TPoliR.Store(var S: TStream);
var
  n: integer;
begin
  n := sizeof(a);
  S.Write(n, sizeOf(n));
  S.Write(gr, SizeOf(gr));
  S.Write(a[0], (gr + 1) * SizeOf(NReal));
end;

procedure TPolir.ValPR(var c: NComplex; s: NComplex);
var
  k: integer;
begin
  c.r := a[gr];
  c.i := 0;
  for k := gr - 1 downto 0 do
  begin
    pro(c, c, s);
    c.r := c.r + a[k];
  end;
end; (* ValPR *)

function TPoliR.Valx(x: NReal): NReal;
var
  res: NReal;
  k: integer;
begin
  res := a[gr];
  for k := gr - 1 downto 0 do
    res := res * x + a[k];
  Valx := res;
end;

procedure TPolir.derive;
var
  k: integer;
begin
  gr := gr - 1;
  for k := 0 to gr do
    a[k] := (k + 1) * a[k + 1];
end;

function TPoliR.RouthHurwitz: integer;
var
  Rh, k, p: integer;
  m: NReal;
  res: boolean;
begin
  res := True;
  for p := gr downto 3 do
    if a[p - 1] = 0 then
      res := False
    else
    begin
      m := a[p] / a[p - 1];
      k := p - 2;
      while k >= 1 do
      begin
        a[k] := a[k] - m * a[k - 1];
        k := k - 2;
      end;
    end;
  if res then
  begin
    RH := 0;
    res := a[0] > 0;
    for p := 1 to gr do
      if res xor (a[p] > 0) then
      begin
        res := not (res);
        Rh := Rh + 1;
      end;
    RouthHurwitz := Rh;
  end
  else
    RouthHurwitz := -1;
end; (* RouthHurwitz *)

procedure TPoliR.Homotecia(b: NReal);
var
  temp: NReal;
  k, j: integer;
begin
  temp := 1;
  if b <> 0 then
    for k := 1 to gr do     {for k:=q.gr-1 downto 0 do }
    begin
      temp := temp / b;        {temp:=temp*b}
      a[k] := a[k] * temp;
    end
  else
  begin
    a[0] := a[gr];
    gr := 0;
  end;

  k := 0;
  while a[k] = 0 do
    k := k + 1;

  if k > 0 then
  begin
    gr := gr - k;
    for j := 0 to gr do
      a[j] := a[j + k];
  end;
end; {Homotecia}

procedure WriteComp(c: NComplex);
begin
  Write(c.r, ' +j ', c.i);
end; (* WriteComp *)

procedure WritelnComp(c: NComplex);
begin
  WriteComp(c);
  writeln;
end; (* WritelnComp *)

procedure ReadComp(var c: NComplex);
begin
  writeln('Re?         Imag?');
  Read(c.r, c.i);
end; (* ReadComp *)

procedure Sum(var a: NComplex; b, c: NComplex);
begin
  a.r := b.r + c.r;
  a.i := b.i + c.i;
end; (* Sum *)

procedure Pro(var a: NComplex; b, c: NComplex);
begin
  a.r := b.r * c.r - b.i * c.i;
  a.i := b.r * c.i + b.i * c.r;
end; (* Pro *)

procedure Divi(var a: NComplex; b, c: NComplex);
var
  p: NComplex;
  m: NReal;
begin
  Cnj(p, c);
  m := Mod2(c);
  Pro(a, b, p);
  a.r := a.r / m;
  a.i := a.i / m;
end; (* Divi *)

procedure Cnj(var p: NComplex; c: NComplex);
begin
  p.r := c.r;
  p.i := -c.i;
end; (* Cnj *)

function Mod2(c: NComplex): NReal;
begin
  Result := c.r * c.r + c.i * c.i;
end; (* Mod2 *)

function Modulo(c: NComplex): NReal;
begin
  Result := Sqrt(Mod2(c));
end; (* Modulo *)




procedure TPoliR.CambioVar;
var
  k, j: integer;

begin
  for k := 0 to gr - 1 do
    for j := gr - 1 downto k do
      a[j] := a[j] + b * a[j + 1];
end; (* CambioVar *)


function TPoliR.RaicesDerecha;
begin
  CambioVar(a);
  RaicesDerecha := RouthHurwitz;
end;  (* RaicesDerecha *)




procedure TPoliR.AjusteGrado;
begin
  while (EsCero(a[Gr]) and (Gr > 0)) do
    Gr := Gr - 1;
end;


function TPoliR.CocienteResto(var Cociente, Resto, Divisor: TPoliR): integer;
var
  k, j: integer;
  //  c , r, d, p: PPR0;
  cmgd, cm: NReal;

begin
(*
  c:= Cociente.pv;
  r:= Resto.pv;
  d:= Divisor.pv;
  p:= pv;
  *)
  { Por precaución ajustamos los grados }
  AjusteGrado;
  Divisor.AjusteGrado;

  if ((Divisor.Gr = 0) and (abs(divisor.a[0]) < AsumaCero)) then
  begin
    Result := -1;
    exit;
  end;

  if Divisor.Gr > Gr then
  begin
    { El cociente es nulo }
    Cociente.Gr := 0;
    cociente.a[0] := 0;

    { El resto es el dividendo }
    Resto.Gr := Gr;
    for j := 0 to Gr do
      resto.a[j] := a[j];
  end
  else
  begin

    Cociente.Gr := Gr - Divisor.Gr;

    Resto.Gr := Gr;  { temporalmente }
    { Copiamos todo el polinomio como resto inicial }
    for j := 0 to Gr do
      resto.a[j] := a[j];

    { determinamos uno a uno los ceficientes del cociente y vamos
    actualizando el resto }
    cmgd := divisor.a[Divisor.Gr]; {coeficiente de mayor grado del divisor}
    for k := Cociente.Gr downto 0 do
    begin
      cm := resto.a[resto.Gr] / cmgd;
      cociente.a[k] := cm;
      for j := 0 to Divisor.Gr - 1 do
        resto.a[resto.Gr - Divisor.Gr + j] :=
          resto.a[resto.Gr - Divisor.Gr + j] - divisor.a[j] * cm;
      Resto.Gr := Resto.Gr - 1;
    end;

    { ajustamos el grado del resto }
    Resto.AjusteGrado;
  end;

  Result := 0;

end;




function TPoliR.PRR;

  function f(x: NReal): boolean;
  begin
    f := RaicesDerecha(x) > nraiz;
  end;

var
  x, paso: NReal;

begin
  if (nraiz > 0) and (nraiz <= gr) then
  begin
    nraiz := nraiz - 1;
    paso := 1.8182;
    if f(0) then
    begin

      x := paso;
      while f(x) do   (* busca cota derecha *)
      begin
        paso := paso * 2;
        x := x + paso;
      end;
    end
    else
    begin

      x := -paso;
      while not f(x) do   (* busca cota izquierda *)
      begin
        paso := paso * 2;
        x := x - paso;
      end;
      x := x + paso;  (* me paro a la derecha *)
    end;

    while paso > error do
    begin
      paso := paso / 2;
      if f(x - paso) then (* me paso *)
      else
        x := x - paso;
    end;
    PRR := x;
  end
  else
  begin
    writeln('*ERROR*(PRR/ComPol) ->numero de raiz fuera de rango');
    while True do ;
  end;
end; (* PRR *)



function TPoliR.Jury: integer;
label
  fin;

var
  k, j: integer;
  alfa, z: NReal;
  res: boolean;

begin
  // ponemos el coeficiente demayor grado positivo. para que ande todook.
  if (a[gr] < 0) then
    for j := 0 to gr do
      a[j] := -a[j];

  for j := gr downto 1 do
  begin
    { OJO! NO VERIFICAMOS SE a[j] = 0. SE ME TRANCO UNA VEZ }
    if a[j] = 0 then
    begin
      jury := -1;
      goto fin;
    end; {!!!!!!!!}

    alfa := a[0] / a[j];

    a[0] := a[j] - alfa * a[0];

    if j <> 1 then
    begin

      for k := 1 to j div 2 do
      begin
        z := a[j - k];
        a[j - k] := a[k] - alfa * z;
        if k <> j - k then
          a[k] := z - alfa * a[k];
      end;



      for k := 0 to (j - 1) div 2 do
      begin
        z := a[k];
        a[k] := a[j - 1 - k];
        a[j - 1 - k] := z;
      end;

    end;
  end;

  j := 0;
  res := True;

  for k := 0 to gr do
  begin
    if a[k] < 0 then
      j := j + 1
    else if a[k] = 0 then
      res := False;
  end;

  if res then
    Jury := j
  else
    Jury := -1;
  fin: ;
end; (* Jury *) (* 19/9/89 *)



begin
 (*
 writeln;
 writeln;
 writeln('********* Unidad ComPol ******* RCh/12/7/89');
 *)
end.
