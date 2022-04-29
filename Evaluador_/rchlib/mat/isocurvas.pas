{+doc
+NOMBRE:isocurvas
+CREACION: 2007-10-22
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Calculo de curvas iso-nivel
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:


-doc}

(*RCh9/90----------------------------------------------------------
  La unidad iso90, fue pensada para generar las curvas iso-nivel
de un cierto campo escalar NReal, que llamaremos f(x,y) para la explicaci¢n.
  El procedimiento de construccion de una curva de nivel, comienza
con la notificacion a iso90 de la fuci¢n que representa al campo escalar
y de la manera en que quremos que la acceda. Para llevar a cabo dicha
notificacion usamos:


Hay dos clases de TIsoScanner, TIsoScannerMatricial y TIsoScannerFuncional

La diferencia está en si el campo escalar y la conversión de la discritización
en coordenadas x, y se suministran mediante una Matriz y Vectores (Matricial)
o mediante funciones (Funcional)

En el caso Matricial, cada fila de la matriz corresponde a un valor de x
y cada columna de la matriz a un valor de y.
Los valores de x y de y son los de los correspondientes vectores.

En el Caso funcional, pasamos una funcion ff(k,j) otra fx(k) y otra fy(j)
que nos permite calcular el valor de f, x e y. En esta caso pasamos como
parámetro nk y nj que corresponden a la cantidad de líneas (x) y (y) respectivamente.

Al crear un objeto de cualquiera de las dos clases, pasamos el nivel
para calcular la curva.

xNivel: Es el nivel de la curva que queremos calcular. La curva
que se calcular  ser  la correspondiente a f(x,y) = xNNivel

Una vez creado el objeto, pedimos puntos de la curva iso-nivel
mediante llamadas a la función:
  function GetPunto(var Prx:puntoReal):boolean;


El punto calculado se devuelve en Prx. Si el resultado es  TRUE,
el punto devuelto es válido, pero para la correcta  interpretación del
punto devuelto, se debe tener en cuenta el  valor de la variable  "Estado"
que puede tomar los valores:

  (fin, SemiActivo, Activo, Reversa)

Como se mencionó más arriba, iso90 genera una matriz interna  para representarse
al campo f y es en esta matriz que buscará las  curvas de nivel NNivel.
La primera vez que llamamos a GetPunto,  buscará un punto cualquiera de la
curva, y el estado será Activo,  indicando que está en plena busqueda.
Desde el punto inicial, hay  dos direcciones para seguir la busqueda, e iso90
elige una  cualquiera, de tal manera que las siguientes llamadas a GetPunto
devolverá puntos del ramal elegido.
Continuando la busqueda por el ramal elegido, puede suceder  que se llegue
nuevamente al punto inicial, con lo que la curva era  cerrada o que lleguemos
al borde de la matriz de cálculo indicando  que la curva es abierta en la matriz.
El que se llego de nuevo al punto inicial se señala con  Estado = SemiActivo,
indicando que se ha completado una curva  iso-nivel, para NNivel, pero que aún
pueden quedar más. Un nuevo  llamado a GetPunto comenzará con una nueva curva
si la hay  volviendo el estado a Activo o indicará el final de la busqueda
con Estado = fin.
Si por el contrario, se llego al borde de la matriz, se  devolverá nuevamente
el punto inicial del ramal, y el estado se  pondra en Reversa, indicando así
que la busqueda seguira ahora  sobre la misma curva, pero desde el punto inicial,
por el ramal no  elegido en el principio. El siguiente llamado a GetPunto
cambiará  el Estado a lo que corresponda.
Como ayuda, depues del listado de la interface de iso90 se  presenta un torzo
de programa utilizado para generar las curvas  iso-lux de artefactos lumínicos.

ejemplo de uso: (sacado del programa de cálculo de curvas iso-lux)       ....
      ....
      repeat
         res:=getpunto(pr);  {pedimos un punto a iso90}
         if Estado = Reversa then desligue(0); {levanta el lapiz}
            if res then   {Si el punto es valido lo dibuja}
            begin
               if plabel.y<pr.y then   {elige el punto más alto}
                 plabel:=pr;          {para poner la etiqueta}
               trazoXY(0,pr.x,pr.y);   {dibuja}
            end;
         if Estado = Semiactivo then   {termino con una curva}
         begin
            desligue(0);               {levanta el lapiz}
            labelXY(0,plabel.x,plabel.y,luxs); {etiqueta la curva}
            plabel.y:=0;
         end;
      until Estado = fin;       {hasta terminar}
      ....


------------------------------------------------------------------*)
unit isocurvas;

interface

uses
  SysUtils, xMatDefs, MatReal;

type
  TIsoScanner_func_kj = function(k, j: integer): NReal;
  TIsoScanner_func_k  = function(k: integer): NReal;


  IsoScannerStateType = (fin, SemiActivo, Activo, Reversa);

type
  TIsoScanner_puntoReal = record
    x, y: NReal;
  end;

  TIsoScanner_puntoInt = record
    k, j: integer;
  end;



type
  TIsoScanner_LAB = array of shortint;
  TIsoScanner_MB = array of TIsoScanner_LAB;

  TIsoScanner = class
  public
    Estado: IsoScannerStateType;
  private
    CuentaPtr: TIsoScanner_MB;
    nivel:     NReal;
    p1, p2:    TIsoSCanner_puntoInt;
    p1Inicial, p2Inicial: TIsoSCanner_puntoInt;
    Pinicial, PR: TIsoSCanner_puntoReal;
    mk, mj:    integer;
  public
    // crea el objeto y fija el nivel en xNivel
    constructor Create(nk, nj: integer; xNivel: NReal);

    // Define el nuevo nivel y reinicializa la búsqueda.
    procedure FijarNuevoNivel(NuevoNivel: NReal);


    function GetPunto(var prx, pry: NReal): boolean;

    function EstadoAsStr: string;
    procedure Free;

  private
    function Cuenta(k, j: integer): integer;
    function CuentaPI(p: TIsoScanner_puntoInt): integer;
    function fPI(p: TIsoScanner_puntoInt): NReal;

    // retorna true si f(k,j) > nivel
    function pos(k, j: integer): boolean;
    procedure InitCuenta;
    procedure BorreCuenta;
    function BuscaPrincipioCurva(var p: TIsoScanner_puntoInt): boolean;
    function Corte(p1, p2: TIsoScanner_puntoInt; var prp: TIsoScanner_PuntoReal): boolean;
    function AdyacenteCuentaPos(var P: TIsoScanner_puntoInt): boolean;


{  Dado el segmento orientado P1P2, esta funci¢n devuelve
  P3 = rot(P2-P1, 90 grados antihorario) + P2
   Si el resulatado es true, el punto P3 corresponde a un
   elemento de la matriz, si SDI = false, el punto P3 se sale
   de la matriz
 }
    function SDI(const P1, P2: TIsoScanner_puntoInt; var P3: TIsoScanner_puntoInt
      ): boolean;


    function SegmentoSalida(var p1, p2: TIsoScanner_PuntoInt;
      var SegInterior: boolean): boolean;
    function BuscaSegmentoInicial(var p1, p2: TIsoScanner_puntoInt): boolean;
    function IniciarPoligonal: boolean;
    function IniciarTodo: boolean;
    function BusquedaActiva: boolean;
    function f(k, j: integer): NReal; virtual; abstract;
    function x(k: integer): NReal; virtual; abstract;
    function y(j: integer): NReal; virtual; abstract;
  end;


(*+doc, acepta una TFunc_kj como definición de f y dos TFun_k, como
  definiciones de x e y
  ATENCION, No se destruyen las matrices y los vectores, con el FREE.
  -doc*)
  TIsoScannerFuncional = class(TIsoScanner)
    func_f: TIsoScanner_func_kj;
    func_x, func_y: TIsoScanner_func_k;

    constructor Create(ff: TIsoScanner_func_kj; fx, fy: TIsoScanner_func_k;
      nk, nj: integer; xNivel: NReal);
    function f(k, j: integer): NReal; override;
    function x(k: integer): NReal; override;
    function y(j: integer): NReal; override;
  end;



  (*+doc, acepta un TMatR como definición de f y dos TVectR, como
  definiciones de x e y
  ATENCION, No se destruyen las matrices y los vectores, con el FREE.
  -doc*)
  TIsoScannerMatricial = class(TIsoScanner)
    mat_f:  TMatR;
    vect_x: TVectR;
    vect_y: TVectR;
    constructor Create(mf: TMatR; vx, vy: TVectR; xNivel: NReal);
    function f(k, j: integer): NReal; override;
    function x(k: integer): NReal; override;
    function y(j: integer): NReal; override;
  end;

implementation




procedure Error(s: string);
begin
  raise Exception.Create(s);
end;

function TIsoScanner.Cuenta(k, j: integer): integer;
begin
  Cuenta := CuentaPtr[k-1][j-1];
end;


function TIsoScanner.EstadoAsStr: string;
begin
  case Estado of
    fin: Result     := 'fin';
    SemiActivo: Result := 'SemiActivo';
    Activo: Result  := 'Activo';
    Reversa: Result := 'Reversa';
  end;
end;

procedure TIsoScanner.Free;
var
  k: integer;
begin
  for k := 1 to mk do
    setlength(CuentaPtr[k-1], 0);
  setlength(CuentaPtr, 0);
  inherited Free;
end;

function Int2Str(k: integer): string;
var
  ts: string;
begin
  str(k, ts);
  Int2Str := ts;
end;

procedure TIsoScanner.FijarNuevoNivel(NuevoNivel: NReal);
begin
  nivel  := NuevoNivel;
  Estado := fin;
end;

constructor TIsoScanner.Create(nk, nj: integer; xNivel: NReal);
var
  k: integer;

begin
  inherited Create;


  mk := nk;
  mj := nj;

  setlength(CuentaPtr, nk);
  for k := 1 to nk do
    setlength(CuentaPtr[k-1], nj);

  FijarNuevoNivel(xNivel);

end;

function TIsoScanner.CuentaPI(p: TIsoScanner_puntoInt): integer;
begin
  CuentaPI := cuenta(p.k, p.j);
end;

function TIsoScanner.fPI(p: TIsoScanner_puntoInt): NReal;
begin
  fPI := f(p.k, p.j);
end;


procedure TIsoScanner.BorreCuenta;
var
  k, j: integer;
begin
  for k := 1 to mk do
    for j := 1 to mj do
      cuentaPtr[k-1][j-1] := 0;
end;

function TIsoScanner.pos(k, j: integer): boolean;
begin
  Result := f(k, j) > nivel;
end;

procedure TIsoScanner.InitCuenta;
var
  k, j:     integer;
  PosTrack: boolean;
begin
  BorreCuenta;
  for k := 1 to mk do
  begin
    PosTrack := pos(k, 1);
    for j := 1 to mj - 1 do
      if pos(k, j + 1) <> PosTrack then
      begin
        Inc(CuentaPtr[k-1][j-1]);
        Inc(CuentaPtr[k-1][j]);
        PosTrack := not PosTrack;
      end;
  end;
  for j := 1 to mj do
  begin
    PosTrack := Pos(1, j);
    for k := 1 to mk - 1 do
      if pos(k + 1, j) <> PosTrack then
      begin
        Inc(CuentaPtr[k-1][j-1]);
        Inc(CuentaPtr[k][j-1]);
        PosTrack := not PosTrack;
      end;
  end;
end;

function TIsoScanner.BuscaPrincipioCurva(var p: TIsoScanner_puntoInt): boolean;
var
  k, j: integer;
  pb: TIsoScanner_LAB;
  buscando: boolean;
begin
  k:= 1;
  buscando:= true;
  while  buscando and (k <= mk) do
  begin
    pb:= cuentaPtr[k-1];
    for j := 1 to mj do
      if pb[j-1] > 0 then
      begin
        p.k := k;
        p.j := j;
        buscando := false;
        break;
      end;
    inc( k );
  end;
  result:= not buscando;
end;


function TIsoScanner.Corte(p1, p2: TIsoScanner_puntoInt;
  var prp: TIsoScanner_PuntoReal): boolean;
var
  f1, f2: NReal;
  landa:  NReal;
  df:     NReal;
begin
  f1 := fpi(p1);
  f2 := fpi(p2);
  df := (f2 - f1);
  if abs(df) > AsumaCero then   // agregado marzo2002 chequear decisión
  begin
    landa := (nivel - f1) / (f2 - f1);
    if (0 <= landa) and (landa <= 1) then
    begin
      Corte := True;
      prp.x := x(p1.k) + landa * (x(p2.k) - x(p1.k));
      prp.y := y(p1.j) + landa * (y(p2.j) - y(p1.j));
      Dec(CuentaPtr[p1.k-1][p1.j-1]);
      Dec(CuentaPtr[p2.k-1][p2.j-1]);
    end
    else
      Corte := False;
  end
  else
    Corte := False;
end;

function TIsoScanner.AdyacenteCuentaPos(var P: TIsoScanner_puntoInt): boolean;
label
  FinTRUE, Fin;
var
  temp: boolean;

  function rlt(k, j: integer): boolean;
  begin
    rlt := temp xor pos(k, j);
  end;

begin
  temp := pos(p.k, p.j);
  if (p.k > 1) and (cuentaPtr[p.k - 2][p.j-1] > 0) and rlt(p.k - 1, p.j) then
  begin
    Dec(p.k);
    goto finTRUE;
  end;
  if (p.k < mk) and (CuentaPtr[p.k ][p.j-1] > 0) and rlt(p.k + 1, p.j) then
  begin
    Inc(p.k);
    goto finTRUE;
  end;
  if (p.j > 1) and (CuentaPtr[p.k-1][p.j - 2] > 0) and rlt(p.k, p.j - 1) then
  begin
    Dec(p.j);
    goto finTRUE;
  end;
  if (p.j < mj) and (CuentaPtr[p.k-1][p.j] > 0) and rlt(p.k, p.j + 1) then
  begin
    Inc(p.j);
    goto finTRUE;
  end;
  AdyacenteCuentaPos := False;
  goto fin;
  finTRUE:
    AdyacenteCuentaPos := True;
  fin: ;
end;

{---------------------------------------------------------
  Dado el segmento orientado P1P2, esta funci¢n devuelve
P3 = rot(P2-P1, 90 grados antihorario) + P2
  Si el resulatado es true, el punto P3 corresponde a un
elemento de la matriz, si SDI = false, el punto P3 se sale
de la matriz
-------------------------------------------------------}


function TIsoScanner.SDI(const P1,  P2: TIsoScanner_puntoInt; var P3: TIsoScanner_puntoInt): boolean;
begin
  P3.k := P2.k - (P2.j - P1.j);
  P3.j := P2.j + (P2.k - P1.k);
  if (P3.k < 1) or (p3.k > mk) or (p3.j < 1) or (p3.j > mj) then
    SDI := False
  else
    SDI := True;
end;


{--------------------------------------------------------------
Entradas:
Por P1P2, indicamos cual es el segmento de entrada a un cuadro.
Salidadas:
  P1P2, Segmento de salida del cuadro.
  SegInterior, Si es TRUE, el segmento no es borde de la matriz.
  SegmentoSalida, es TRUE si encontr¢ un segmento de salida.

Cuando SegmentoSalida = TRUE, P1P2 es el segmento de salida,
Si SegmentoSalida = FALSE, Con SegInterior sabemos porque no
se encontro un segmento de salida
--------------------------------------------------------------}


function TIsoScanner.SegmentoSalida(var p1, p2: TIsoScanner_PuntoInt;
  var SegInterior: boolean): boolean;
var
  cont: integer;
  p3:   TIsoScanner_puntoInt;

  function SegSal: boolean;
  begin
    Inc(cont);
    SegInterior := SDI(p1, p2, p3);
    if not SegInterior then
      SegSal := False
    else
    begin
      if (cuentaPI(p3) > 0) and (cuentaPI(p2) > 0) and ((fpi(p3) - nivel) * (fpi(p2) - nivel) <= 0) then
      begin
        p1     := p3;
        SegSal := True;
      end
      else
      if cont < 3 then
      begin
        p1     := p2;
        p2     := p3;
        SegSal := SegSal;
      end
      else
        SegSal := False;
    end;
  end;

begin
  cont := 0;
  SegmentoSalida := SegSal;
end;




function TIsoScanner.BuscaSegmentoInicial(var p1, p2: TIsoScanner_puntoInt): boolean;
begin
  if BuscaPrincipioCurva(p1) then
  begin
    p2 := p1;
    BuscaSegmentoInicial := AdyacenteCuentaPos(p2);
  end
  else
    BuscaSegmentoInicial := False;
end;



function TIsoScanner.IniciarPoligonal: boolean;
var
  res: boolean;
begin
  res := BuscaSegmentoInicial(p1, p2);
  if res then
  begin
    res      := Corte(p1, p2, pr);
    Pinicial := PR;
    p1Inicial := p1;
    p2Inicial := p2;
    Estado   := activo;
  end
  else
  begin
    res    := False;
    Estado := fin;
  end;
  IniciarPoligonal := res;
end;


function TIsoScanner.IniciarTodo: boolean;
{var
  res:boolean;}
begin
  InitCuenta;
  IniciarTodo := IniciarPoligonal;
end;

function TIsoScanner.BusquedaActiva: boolean;
var
  res1, SegInter: boolean;
begin
  res1 := SegmentoSalida(p1, p2, SegInter);
  if res1 then
    BusquedaActiva := Corte(p1, p2, PR)
  else
  if SegInter then
  begin
    PR     := Pinicial;
    BusquedaActiva := True;
    Estado := Semiactivo;
  end
  else
  begin
    if estado = Reversa then
    begin
      BusquedaActiva := False;
      Estado := SemiActivo;
    end
    else
    begin
      p1 := p2Inicial;
      p2 := p1Inicial;
      BusquedaActiva := Corte(p1, p2, pr);
      Inc(cuentaPtr[p1.k-1][p1.j-1]);
      Inc(cuentaPtr[p2.k-1][p2.j-1]);
      Estado := Reversa;
    end;
  end;
end;


function TIsoScanner.GetPunto(var prx, pry: NReal): boolean;
var
  res0: boolean;

begin
  case Estado of

    fin: res0    := IniciarTodo;
    SemiActivo: res0 := IniciarPoligonal;
    Activo: res0 := BusquedaActiva;
    Reversa:
    begin
      res0 := BusquedaActiva;
      if res0 then
        Estado := Activo;
    end;
  end;
  prx      := Pr.x;
  pry      := Pr.y;
  GetPunto := res0;
end;



constructor TIsoScannerMatricial.Create(mf: TMatR; vx, vy: TVectR; xNivel: NReal);
begin
  if mf.nf <> vx.n then
    raise Exception.Create('TIsoScannerMatricial, mf.nf <> vx.n ');
  if mf.nc <> vy.n then
    raise Exception.Create('TIsoScannerMatricial, mf.nc <> vy.n ');

  inherited Create(mf.nf, mf.nc, xNivel);
  mat_f  := mf;
  vect_x := vx;
  vect_y := vy;
end;

function TIsoScannerMatricial.f(k, j: integer): NReal;
begin
  Result := mat_f.e(k, j);
end;

function TIsoScannerMatricial.x(k: integer): NReal;
begin
  Result := vect_x.e(k);
end;


function TIsoScannerMatricial.y(j: integer): NReal;
begin
  Result := vect_y.e(j);
end;


constructor TIsoScannerFuncional.Create(ff: TIsoScanner_func_kj;
  fx, fy: TIsoScanner_func_k; nk, nj: integer; xNivel: NReal);
begin
  inherited Create(nk, nj, xNivel);
  func_f := ff;
  func_x := fx;
  func_y := fy;
end;

function TIsoScannerFuncional.f(k, j: integer): NReal;
begin
  Result := func_f(k, j);
end;

function TIsoScannerFuncional.x(k: integer): NReal;
begin
  Result := func_x(k);
end;

function TIsoScannerFuncional.y(j: integer): NReal;
begin
  Result := func_y(j);
end;


end.

