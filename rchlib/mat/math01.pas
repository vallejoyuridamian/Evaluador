{+doc
+NOMBRE: Math01
+CREACION: 1990
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: definici¢n de algor¡tmos para buscar raices de funciones
  reales.
+PROYECTO: rchlib
+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit math01;
{$MODE Delphi}


interface

uses
  xMatDefs;

type
  // Implementación moderna (2014) usuando una clase.
  // Para usar hay que definir la Clase del problema escribiendo
  // la función f(x) especifica.

  T_ProblemaFx_Cero = class
    function f(x: NReal): NReal; virtual; abstract;

    function Dicot(x0, x1, xtol: NReal;          {extremos y tolerancia}
      MaxIts: word;          {n£mero m ximo de iteraciones}
      var Root, fAtRoot: NReal;    {ra¡z y f(ra¡z)}
      var NoOfIts: word): boolean;  { retonra TRUE si conviergió, False si no}

    function Secant(x0, x1, xtol: NReal;        {valores iniciales de x y tolerancia}
      MaxIts: word;          {n£mero m ximo de iteraciones}
      var Root, fAtRoot: NReal;  {ra¡z y f(ra¡z)}
      var NoOfIts: word      {n£mero de iteraciones realizadas}
      ): boolean;  {valid‚s del resultado}
  end;


  // clase para facilitar la resolución si fx es una función externa.
  T_ProblemaFx_Cero_externa = class(T_ProblemaFx_Cero)
    fx: TFdeX;
    constructor Create(f: TFdeX);
    function f(x: NReal): NReal; override;
  end;


// Interface antigua.
procedure Dicot(f: TFdeX;              {funci¢n a anular}
  x0, x1, xtol: NReal;          {extremos y tolerancia}
  MaxIts: word;          {n£mero m ximo de iteraciones}
  var Root, fAtRoot: NReal;    {ra¡z y f(ra¡z)}
  var NoOfIts: word;          {n£mero de iteraciones realizadas}
  var converged: boolean);  {valid‚s del resultado}


procedure Secant(f: TFdeX;               {funci¢n a anular}
  x0, x1, xtol: NReal;        {valores iniciales de x y tolerancia}
  MaxIts: word;          {n£mero m ximo de iteraciones}
  var Root, fAtRoot: NReal;  {ra¡z y f(ra¡z)}
  var NoOfIts: word;      {n£mero de iteraciones realizadas}
  var converged: boolean);  {valid‚s del resultado}

// Calcula la integrall de f(x) entre x = a y x = b con la tolereancia tol
procedure Romberg(f: TfdeX; a, b, tol: NReal; var integral: NReal; var success: boolean);


implementation


function T_ProblemaFx_Cero.Dicot(x0, x1, xtol: NReal;          {extremos y tolerancia}
  MaxIts: word;          {n£mero m ximo de iteraciones}
  var Root, fAtRoot: NReal;    {ra¡z y f(ra¡z)}
  var NoOfIts: word): boolean;  { retonra TRUE si conviergió, False si no}
var
  converged: boolean;
  x, fx, f0: NReal;
  ItCount: word;
  state: (Iterating, WithinTol, MaxItsReached, EqualSigns);
begin
  if x0 > x1 then
  begin
    x := x0;
    x0 := x1;
    x1 := x;
  end;
  f0 := f(x0);
  ItCount := 0;
  fx := f(x1);
  if f0 * fx <= 0 then
  begin
    state := Iterating;
    repeat
      Inc(ItCount);
      x := (x0 + x1) / 2;
      fx := f(x);
      if f0 * fx <= 0 then
        x1 := x
      else
      begin
        x0 := x;
        f0 := fx;
      end;
      if x1 - x0 <= xTol then
        state := WithinTol
      else if ItCount = MaxIts then
        state := MaxItsReached
    until state <> iterating;
  end
  else
    state := EqualSigns;
  converged := state = WithInTol;
  Root := (x0 + x1) / 2;
  fAtRoot := f(root);
  NoOfIts := ItCount;
  Result := converged;
end; {Dicot }


function T_ProblemaFx_Cero.Secant(x0, x1, xtol: NReal;
  {valores iniciales de x y tolerancia}
  MaxIts: word;          {n£mero m ximo de iteraciones}
  var Root, fAtRoot: NReal;  {ra¡z y f(ra¡z)}
  var NoOfIts: word      {n£mero de iteraciones realizadas}
  ): boolean;  {valid‚s del resultado}

label
  _fin;

var
  converged: boolean;
  xs, fs, xb, fb, xa, fa, df, dx: NReal;
  ItCount: word;
  state: (Iterating, WithinTol, MaxItsReached, DivByZero);
  RaizEnIntervalo: boolean;
  SignoIntervalo: integer;
  signo_fa, signo_fb: integer;
begin
  xa := x0;
  fa := f(x0);
  Signo_fa := SignoNR(fa);

  xs := xa;
  fs := fa;
  signoIntervalo := 0;// inicializo para evitar warnings del compilador


  if Signo_fa = 0 then
  begin
    Converged := True;
    NoOfIts := 0;
    Root := xa;
    fAtRoot := fa;
    //    state:=WithInTol; comento pue no es neceario
    goto _fin;
  end
  else
  begin
    xb := x1;
    fb := f(x1);
    Signo_fb := SignoNR(fb);
    if Signo_fb = 0 then
    begin
      Converged := True;
      NoOfIts := 0;
      Root := xb;
      fAtRoot := fb;
      //      state:=WithInTol; comento pues no es necesario
      goto _fin;
    end;
  end;

  if signo_fa * signo_fb < 0 then
    RaizEnIntervalo := True
  else
  begin
    RaizEnIntervalo := False;
    SignoIntervalo := signo_fa;
  end;

  ItCount := 0;
  state := iterating;
  while state = iterating do
  begin
    df := fb - fa;
    if df <> 0 then
    begin
      Inc(ItCount);
      dx := (xb - xa);
      xs := xa - fa * dx / df;
      fs := f(xs);
      if RaizEnIntervalo then
        if fs < 0 then
        begin
          fa := fs;
          xa := xs;
        end
        else
        begin
          fb := fs;
          xb := xs;
        end
      else
      begin
        if abs(xs - xa) < abs(xs - xb) then
        begin
          xa := xs;
          fa := fs;
        end
        else
        begin
          xb := xs;
          fb := fs;
        end;
        if signoNR(fs) <> SignoIntervalo then
          RaizEnIntervalo := True;
      end;

      if ItCount = MaxIts then
        state := MaxItsReached;
      if abs(dx) < xtol then
        state := WithinTol;
    end
    else
      state := DivByZero;
  end;
  converged := state = WithInTol;
  if fs = 0 then
    converged := True;
  Root := xs;
  fAtRoot := fs;
  NoOfIts := ItCount;

  _fin:
    Result := converged;
end;


// Métodos de T_ProblemaFx_Cero_externa
constructor T_ProblemaFx_Cero_externa.Create(f: TFdeX);
begin
  self.fx := f;
end;

function T_ProblemaFx_Cero_externa.f(x: NReal): NReal;
begin
  Result := fx(x);
end;


procedure Dicot(f: TFdeX;              {funci¢n a anular}
  x0, x1, xtol: NReal;          {extremos y tolerancia}
  MaxIts: word;          {n£mero m ximo de iteraciones}
  var Root, fAtRoot: NReal;    {ra¡z y f(ra¡z)}
  var NoOfIts: word;          {n£mero de iteraciones realizadas}
  var converged: boolean);  {valid‚s del resultado}

var
  problema: T_ProblemaFx_Cero_externa;
begin
  problema := T_ProblemaFx_Cero_externa.Create(f);
  converged := problema.Dicot(x0, x1, xtol, MaxIts, Root, fAtRoot, NoOfIts);
  problema.Free;
end;

procedure Secant(f: TFdeX;               {funci¢n a anular}
  x0, x1, xtol: NReal;           {valores iniciales de x y tolerancia}
  MaxIts: word;          {n£mero m ximo de iteraciones}
  var Root, fAtRoot: NReal;  {ra¡z y f(ra¡z)}
  var NoOfIts: word;      {n£mero de iteraciones realizadas}
  var converged: boolean);  {valid‚s del resultado}
var
  problema: T_ProblemaFx_Cero_externa;
begin
  problema := T_ProblemaFx_Cero_externa.Create(f);
  converged := problema.Secant(x0, x1, xtol, MaxIts, Root, fAtRoot, NoOfIts);
  problema.Free;
end;


procedure Romberg(f: TfdeX; a, b, tol: NReal; var integral: NReal; var success: boolean);
const
  maxrow = 10;
  maxpt = 512; { = 2^(maxrow-1) }
type
  rows = 0..maxrow;
var
  ss, news, sigma, hcoeff, h: NReal;
  twotothekminus1, fourtothej: longint;
  j, k: rows;
  p: 1.. maxpt;
  s: array[rows] of NReal;
  state: (splitting, withintol, lastrowreached);
begin
  k := 1;
  twotothekminus1 := 1;
  h := (b - a) / 2;
  news := h * (f(a) + f(b));
  s[0] := news;
  state := splitting;
  repeat
    sigma := 0;
    hcoeff := -1;
    for p := 1 to twotothekminus1 do
    begin
      hcoeff := hcoeff + 2;
      sigma := sigma + f(a + hcoeff * h);
    end;
    ss := s[0];
    news := ss / 2 + h * sigma;
    s[0] := news;
    fourtothej := 1;
    for j := 1 to k - 1 do
    begin
      fourtothej := fourtothej * 4;
      news := (fourtothej * news - ss) / (fourtothej - 1);
      ss := s[j];
      s[j] := news;
    end;
    fourtothej := fourtothej * 4;
    news := (fourtothej * news - ss) / (fourtothej - 1);
    if abs(news - ss) <= tol then
      state := withintol
    else
    if k = maxrow then
      state := lastrowreached
    else
    begin
      k := k + 1;
      h := h / 2;
      twotothekminus1 := twotothekminus1 * 2;
      s[k] := news;
    end
  until state <> splitting;
  success := state = withintol;
  if success then
    integral := news;
end; {Romberg}

end.
