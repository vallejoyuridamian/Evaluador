{+doc
+NOMBRE: usistema
+CREACION: 18.12.94
+AUTORES: rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: encabezamiento estandar
+PROYECTO: redes

+REVISION:
2/97 Proyecto de estudiantes  MARCELO PETRUCELLI - MARIO VIGNOLO
    Se agregaron los procedimientos initcrearsistema, destruirsistema,
    AcumularConstante, ValCte, BorrarConstante, BorrarTodo y EliGaussPivPar
enero 2012; Proyecto de mejoras SimSEE FSE18/2009
    Revisión general e implementación
+DESCRIPCION:
-doc}

unit usistema;

interface

uses
  Classes,
  SysUtils,
  ecuacs,
  XMatDefs,
  AlgebraC, MatCPX,
  horrores,
  usortedlist;

type


  {TSistema es una clase de objetos que implementa los sistemas de ecuaciones
  como listas de objetos de tipo TEcuacion}
  TSistema = class(TSortedList)
    {Init de TSistema como TSortedCollection}
    constructor Create;

    {Crea un sistema con nec ecuaciones}
    constructor Create_crearsistema(nec: word);

    procedure Free; virtual;

    {destruye completamente un sistema de ecuaciones}
    procedure Free_destruirsistema; virtual;

    {Acumula (xFactor) en el coeficiete asociado a la variable de indice
    (ncol) de la ecuacion (nec). Primero se busca el coeficiente asociado
    a (ncol) en la ecuacion (nec), si no se encuentra se agrega}
    procedure Acumular_(nec, ncol: integer; xFactor: NComplex);

    {Suma al término independiente de la ecuación (nec) xsum}
    procedure AcumularConstante_(nec: integer; xFactor: NComplex);

    { Numero de ecuaciones en el sistema }
    function numeroDeEcuaciones: integer;

    { Maximo indice de variable involucrado }
    function MaxIndVar: integer;

    function ChequearFormacionDiagonal: boolean;
    { Chequeo que cada ecuacion tenga variable diagonal
    correspondiente}

    function ValCoef(var ResCoef: NComplex; nec, ncol: integer): boolean;
    {Devuelve en ResCoef, el valor del coeficiente asociado a la
    variable con indice (ncol) de la ecuacion (nec). El resultado de
    la funcion es (true) cuando la ecuación disponía de un coeficiente
    para esa variable y es (false) cuando no. En cualquiera de los casos
    el valor devuelto en (ResCoef) es el correcto. El resultado de la
     funcion puede usarse para saber si el valor del coeficiente es un
    CERO absoluto por no existir directamente en la ecuación}

    // llama a ValCoef y devuelve el complejo en el casillero k, j
    function e( k, j: integer): NComplex;

    procedure ValCte(var ResCte: NComplex; nec: integer);
    {Devuelve en ResCte el término independiente de la ecuación (nec)}

    procedure BorrarCoef(nec, ncol: integer);
    {Borra el coeficiente (ncol) de la ecuacíon (nec). Significa poner el
     coeficiente en CERO}

    procedure BorrarTodo;
    {Pone todos los coeficientes a CERO incluyendo el termino constante
    NO AFECTA LOS DEMAS PARAMETROS DE LA ECUACION, tales como el indice
    principal, el tipo de ecuacion y la lista de distribucion}

    procedure BorrarConstante(nec: integer);
    {Borra el término independiente de la ecuación (nec)}

    procedure Calc(var Resultado: NComplex; nec: integer; X: TVectComplex);
    {Calcula la suma de los productos de los coeficientes de la ecuacion
    (nec) por el valor de sus respectivas variables asociadas y le suma el
    campo (Constante)}
(*
    constructor Load( var S: TStream );
    procedure Store( var S: TStream ); virtual;
    *)

    //Devuelve el puntero a la ecuacion con idxprincipal igual a (nec)
    // sin nec = 0 retorna nil (LA TIERRA)
    function NEcPtr(nec: integer): TEcuacion;

    //Retorna el idxprincipal de pec, si pec = nil retorna 0 (Cero).
    function PtrNEc(pec: TEcuacion): integer;

    // retorna la ecuación que almacena el corte al que pertenece pec
    // si pec.FDistCorte = nil, retorna pec pues toda ecuación pertenece a
    // su propio corte si no fue acumulada en otra.
    // si retorna NIL quiere decir que el almacen es LA TIERRA
    function almacenDelCorte(pec: TEcuacion): TEcuacion;

    // N1 y N2, son dos nodos que pueden pertenecer a un corte o no.
    // Busca los correspondientes cortes y acumula el corte en el de menor índice
    // de esa forma al combinar cortes, si uno es la TIERRA quedan acumulados en
    // la TIERRA que es la ecuación 0 (CERO)
    // Retorna la ecuación en la que hay que poner la relación de tensión
    // actualiza los factores de distribución del CORTE_ORIGEN
    // N2ToN1 sería el factor de distribución a aplicar si N1 y N2 fueran
    // dos nodos que no pertenecen a ningún corte y se forma un corte con ambos
    // sobre la ecuación N1. El procedimiento resuelve internamente los factores
    // correctos en base a esa información.
    function CombinarCortes(N1, N2: integer;
      factor_N2ToN1: NComplex): TEcuacion;

    // acumula el valor  de Y en la ecuación de nodo nEc en la columna nVar
    // si la ecuación se encuentra redireccionada por un corte el valor es distribuido
    // entre los cortes indicados en la lista de distribución.
    procedure Pon(nEc, nVar: integer; Y: NComplex);

    // agrega una admitancia entre los nodos N1 y N2
    procedure PonY(n1, n2: integer; xy: NComplex);

    // agrega un generador de corriente asociado a una función independiente
    procedure PonIG(nneg, npos: integer; nindep: integer;
    { Numero de la funcion independiente asociada }
      IgVal: NComplex);

    // agrega un generador de tensión con una impedancia de vacío.
    // la tensión de vacio es asociada a una función independiente
    procedure PonZVG(nneg, npos: integer; nindep: integer;
    {Numero de func. indep. asociada }
      ZVal, EVal: NComplex);


    // generador de corriente entre los nodos negIg->posIg cuya corriente
    // depende de la tensión entre los nodos posV y neg V
    // Ig = ay * (V[posV]-V[negV]  siendo Ig, la corrientre extraída por el componente
    // del nodo negIg e inyectada por el componente en el nodo posIg.
    procedure PonIgV(negIg, posIg, negV, posV: integer; ay: NComplex);


    // agrega un trafo dada su Zcc y relación de tensión
    procedure PonTrafoZcc(PriPos, PriNeg, SecPos, SecNeg: integer; Zcc, n: NComplex);
    Procedure PonTrafoZcc1(n1, n2: integer; xy: NComplex; n: NReal);

    // Agrega un generador de tensión entro dos nodos.
    // para ello crea la ecuación del corte (o se agrega a una existente si es el caso)
    // y crea la ecuación con la relación de tensión entre las barras.
    procedure PonVG(nneg, npos: integer; EVal: NComplex);


    // agrega el cuadripolo con admitancias al nodo n3 de los nodos n1 y n2,
    // Y13 e Y23 respectivamente y con impedancia entre los nodos Z12
    procedure PonCuadripolo(n1, n2, n3: integer; Y13, Z12, Y23: NComplex);


    {

    procedure PonTI(ppos, pneg, spos, sneg: integer;
    vs_d_vp: NComplex );
     }

    function EliminarVariable(EcDestino, EcEliminadora: integer;
      kIndVar: integer): integer;

    procedure CombinarEcuaciones(EcDestino, EcOrigen: integer; mult: NComplex);

    { Toma las ecuaciones de a una y elimina la variable asociada
    al elemento diagonal del resto de las ecuaciones. Cuando se completa
    el procedimiento se a resulto el sistema para las variables asociadas
    a la diagonal }
    function EliminacionDiagonalCompleta: integer;

    {dado un sistema,hace eliminacion  gaussiana con pivoteo
    parcial y lo resuelve quedando la solucion en la cte de cada ecuacion}
    procedure EliGaussPivPar;

    {Muestra el sistema de ecuaciones}
    procedure muestrasistema;


    {Muestra el sistema de ecuaciones en un archivo de texto}
    procedure writetoTXT(archi: string );

    function KeyOf(Item: Pointer): Pointer; override;
    function Compare(Key1, Key2: Pointer): integer; override;


  end;


  TMatrizDeAdmitancias = TSistema;


implementation

constructor TSistema.Create_crearsistema(nec: word);

var
  p: TEcuacion;
  k: integer;

begin
  Create;

  for k := 1 to nec do
  begin
    p := TEcuacion.Create;
    p.idxPrincipal := k;
    sorted_insert(p);
  end;
end;



procedure TSistema.Free_destruirsistema;

var
  p:      TEcuacion;
  k, nec: word;

begin
  nec := Count;
  for k := 1 to nec do
  begin
    p := items[k - 1];
    p.Free;
  end;
  Clear;
  inherited Free;
end;


procedure TSistema.EliGaussPivPar; {dado un sistema,
        hace eliminacion  gaussiana con pivoteo
        parcial y lo resuelve quedando la solucion
        en la cte de cada ecuacion}

var
  i, iaux, r, k, elimvar, necs: integer;
  pr, pi: TEcuacion;
  m:      Nreal;
  res, sum, rescoef, rescte, bi, Uii, Uiiaux, xi, xiaux, ann, xn: NComplex;

begin
  necs := NumeroDeEcuaciones;
  for i := 1 to necs - 1 do  {aplico eliminacion desde la ec.1 a la necs-1}
  begin
    m := 0;
    r := i;
    for iaux := i to necs do {para la variable i recorro hasta
          abajo}
    begin
      if ValCoef(res, iaux, i) then {si esta el tno i
              en la ecuacion iaux}
      begin
        if mod1(res) > m then
        begin
          m := mod1(res);
          r := iaux;
        end;
      end;
    end;{al terminar el for en m tengo el maximo de los
    modulos de los coeficientes y en r la ecuacion donde se da}
    if m = 0 then
      horrores.error('Sistema ecuaciones incompatible o indeterminado.');

    if r <> i then {cambio el orden de las ecuaciones:
          la i por la r}
    begin
      pi := NEcPtr(i);
      pr := NEcPtr(r);
      {reordenarecs(sist);}
      remove(pi);
      remove(pr);
      pi.idxPrincipal := r;   {cambio los indices}
      pr.idxPrincipal := i;
      sorted_insert(pi);
      sorted_insert(pr);
    end;
    for k := i + 1 to necs do
    begin
      elimvar := EliminarVariable(k, i, i);
      if elimvar <> 0 then
        horrores.error('Sistema de ecuaciones incompatible o indeterminado.');
    end;

  end;
  {a continuacion implemento la resolucion del sistema resultante
  diagonal superior; el vector solucion sera el vector constante
  del sistema}
  ValCte(rescte, necs);
  if ValCoef(rescoef, necs, necs) then
    ann := rescoef
  else
    horrores.error('Sistema de ecuaciones incompatible o indeterminado.');

  if (ann.i = complex_nulo.i) and (ann.r = complex_nulo.r) then
    horrores.error('Sistema de ecuaciones incompatible o indeterminado.');

  xn := rc(complex_nulo, dc(rescte, ann)^)^;
  BorrarConstante(necs);
  AcumularConstante_(necs, xn);
  for i := necs - 1 downto 1 do
  begin
    sum := complex_nulo;
    for iaux := i + 1 to necs do
    begin
      if ValCoef(rescoef, i, iaux) then
        Uiiaux := rescoef
      else
        Uiiaux := complex_nulo;
      ValCte(xiaux, iaux);
      sum := sc(sum, pc(xiaux, Uiiaux)^)^;
    end;
    Valcte(bi, i);
    if ValCoef(rescoef, i, i) then
      Uii := rescoef
    else
      horrores.error('Sistema de ecuaciones incompatible o indeterminado.');
    if (Uii.i = complex_nulo.i) and (Uii.r = complex_nulo.r) then
      horrores.error('Sistema de ecuaciones incompatible o indeterminado');

    xi := rc(complex_nulo, dc(sc(bi, sum)^, Uii)^)^;
    BorrarConstante(i);
    AcumularConstante_(i, xi);
  end;

end;



procedure TSistema.muestrasistema;

var
  k, i, nec: word;
  bol1: boolean;
  cki: NComplex;
  aki: Nreal;

begin
  nec := Count;
  for k := 1 to nec do
  begin
    for i := 1 to nec do
    begin
      bol1 := ValCoef(cki, k, i);
      Write(k);
      Write(i);
      Write(' ');
      if bol1 then
      begin
        aki := cki.r;
      end
      else
      begin
        aki := 0;
      end;
      Write(cki.r: 4: 6,' ',cki.i: 4: 6);
      Write('  ');
      Write('  ');
    end;
    ValCte(cki, k);
    aki := cki.r;
    Write(cki.r: 4: 6,' ',cki.i: 4: 6);
    writeln(' ');
    writeln(' ');
  end;
  writeLn(' ');
    {writeLN('SOLUCION');
    for k:=1 to nec do
    begin
      ValCte(cki,k);
      aki:=cki.r;
      writeLn(aki:4:2);
    end;}
end;

procedure TSistema.writetoTXT(archi: string );

var

  f: textfile;
  //i: integer;

  k, i, nec: word;
  bol1: boolean;
  cki: NComplex;
  aki: Nreal;

begin
  assignfile( f, archi );
  rewrite( f );
  nec := Count;
  for k := 1 to nec do
  begin
    for i := 1 to nec do
    begin
      bol1 := ValCoef(cki, k, i);
      Write(f,k,'_');
      Write(f,i);
      Write(f,': ');
      if bol1 then
      begin
        aki := cki.r;
      end
      else
      begin
        aki := 0;
      end;
      Write(f,cki.r: 4: 6,' ',cki.i: 4: 6, #9);
      Write(f,'  ');
      Write(f,'  ');
    end;
    ValCte(cki, k);
    aki := cki.r;
    Write(f,cki.r: 4: 6,' ',cki.i: 4: 6, #9);
    writeln(f,' ');
  end;
  writeLn(f,' ');
  closefile( f );
end;

constructor TSistema.Create;

begin
  inherited Create;
end;

procedure TSistema.Acumular_(nec, ncol: integer; xFactor: NComplex);
var
  p: TEcuacion;
begin
  p := NEcPtr(nec);
  p.Acumular_(ncol, xFactor);
end;

procedure TSistema.AcumularConstante_(nec: integer; xFactor: NComplex);
var
  p: TEcuacion;
begin
  p := NEcPtr(nec);
  p.AcumularConstante_(xFactor);
end;

function TSistema.ValCoef(var ResCoef: NComplex; nec, ncol: integer): boolean;
var
  p: TEcuacion;
begin
  p := NEcPtr(nec);
  ValCoef := p.ValCoef(ResCoef, ncol);
end;

function TSistema.e( k, j: integer): NComplex;
var
  res: NComplex;
begin
  ValCoef( res, k, j );
  result:= res;
end;

procedure TSistema.ValCte(var ResCte: NComplex; nec: integer);
var
  p:   TEcuacion;
  Cte: NComplex;
begin
  p := NEcPtr(nec);
  p.ValCte(Cte);
  ResCte := Cte;
end;



procedure TSistema.BorrarCoef(nec, ncol: integer);
var
  p: TEcuacion;
begin
  p := NEcPtr(nec);
  p.BorrarCoef(ncol);
end;

procedure TSistema.BorrarConstante(nec: integer);
var
  p: TEcuacion;
begin
  p := NEcPtr(nec);
  p.BorrarConstante;
end;

procedure TSistema.Borrartodo;

var
  numec, k, i: integer;

begin
  numec := Count;
  for k := 1 to numec do
  begin
    BorrarConstante(k);
    for i := 1 to numec do
    begin
      BorrarCoef(k, i);
    end;
  end;
end;

procedure TSistema.Calc(var Resultado: NComplex; nec: integer; X: TVectComplex);
var
  p: TEcuacion;
begin
  p := NEcPtr(nec);
  p.CalcNC(resultado, X);
end;


function TSistema.NEcPtr(nec: integer): TEcuacion;
var
  p: TEcuacion;

begin
  if nec = 0 then
    Result := nil
  else
  begin
    p := items[nec - 1];
    if p.idxPrincipal <> nec then
      horrores.error('TSistema.NecPtr, idxPrincipal<>nec, (' + IntToStr(
        p.idxPrincipal) + '<>' + IntToStr(nec) + ')');
    NEcPtr := p;
  end;
end;


function TSistema.PtrNEc(pec: TEcuacion): integer;
begin
  if pec = nil then
    Result := 0
  else
    Result := pec.idxprincipal;
end;

procedure TSistema.Pon(nEc, nVar: integer; Y: NComplex);
var
  p: TEcuacion;
  q: TFDistCorte;
  k: integer;
begin
  p := NECPtr(nec);
  if (nEc <> 0) and (nVar <> 0) then
  begin
    if p.fd_corte <> nil then
    begin
      q := p.fd_corte;
      // esto causa la recursión hacia la ecuación que contiene el corte
      // y va concatenando los factores. Si las ecuaciones de los cortes
      // se resuelven siempre apuntando directamente al corte la recursión
      // es de un solo paso.
      pon(q.nec, nvar, pc(Y, q.Factor)^);
    end
    else
      p.Acumular_(nVar, Y);
  end;
end;




function TSistema.KeyOf(Item: Pointer): Pointer;
begin
  KeyOf := @TEcuacion(Item).idxPrincipal;
end;


function TSistema.Compare(Key1, Key2: Pointer): integer;
begin
  if integer(Key1^) < integer(Key2^) then
    compare := -1
  else if integer(Key1^) = integer(Key2^) then
    compare := 0
  else
    compare := 1;
end;



function TSistema.EliminarVariable(EcDestino, EcEliminadora: integer;
  kIndVar: integer): integer;
var
  pdes, pelim: TEcuacion;
begin
  pdes  := NEcPtr(EcDestino);
  pelim := NEcPtr(EcEliminadora);
  EliminarVariable := ecuacs.EliminarVariable(pdes, pelim, KIndVar);
end;


procedure TSistema.CombinarEcuaciones(EcDestino, EcOrigen: integer; mult: NComplex);
var
  pdes, porg: TEcuacion;
begin
  pdes := NEcPtr(EcDestino);
  porg := NEcPtr(EcOrigen);
  ecuacs.CombinarEcuaciones(pdes, porg, mult);
end;



{ Toma las ecuaciones de a una y elimina la variable asociada
al elemento diagonal del resto de las ecuaciones. Cuando se completa
el procedimiento se a resulto el sistema para las variables asociadas
a la diagonal }
function TSistema.EliminacionDiagonalCompleta: integer;

var
  kelim, kdes: integer;
  res: integer;

begin
  Result := 0;
  for kelim := 1 to Count do
    for kdes := 1 to Count do
      if kdes <> kelim then
      begin
        res := EliminarVariable(kelim, kdes, kelim);
        if res < 0 then
        begin
          Result := -kelim;
          exit;
        end;
      end;
end;



function TSistema.NumeroDeEcuaciones: integer;
begin
  NumeroDeEcuaciones := Count;
end;



function TSistema.MaxIndVar: integer;
var
  t, m, kec: integer;
begin
  m := 0;
  for kec := 0 to Count - 1 do
  begin
    t := TEcuacion(items[kec]).MaxIndVar;
    if t > m then
      m := t;
  end;
  MaxIndVar := m;
end;



function TSistema.ChequearFormacionDiagonal: boolean;
var
  t, kec: integer;
begin
  for kec := 0 to Count - 1 do
  begin
    t := TEcuacion(items[kec]).IdxPrincipal;
    if t <> kec + 1 then
    begin
      ChequearFormacionDiagonal := False;
      exit;
    end;
  end;
  ChequearFormacionDiagonal := True;
end;




procedure TSistema.PonY(n1, n2: integer; xy: NComplex);
var
  menosy: NComplex;
begin
  menosy := prc(-1, xy)^;
  pon(n1, n1, xy);
  pon(n1, n2, menosy);
  pon(n2, n1, menosy);
  pon(n2, n2, xy);
end;




procedure TSistema.PonIG(nneg, npos: integer; nindep: integer;
  { Numero de la funcion independiente asociada }
  IgVal: NComplex);
begin
  pon(nneg, nindep, prc(1, IgVal)^);
  pon(npos, nindep, prc(-1, IgVal)^);
end;


procedure TSistema.PonZVG(nneg, npos: integer; nindep: integer;
  {Numero de func. indep. asociada }
  ZVal, EVal: NComplex);

var
  Y: NComplex;
begin
  Y := invc(ZVal)^;
  PonIg(nneg, npos, nindep, pc(EVal, Y)^);
  PonY(nneg, npos, Y);
end;

// generador de corriente entre los nodos negIg->posIg cuya corriente
// depende de la tensión entre los nodos posV y neg V
// Ig = ay * (V[posV]-V[negV]  siendo Ig, la corrientre extraída por el componente
// del nodo negIg e inyectada por el componente en el nodo posIg.

procedure TSistema.PonIgV(negIg, posIg, negV, posV: integer; ay: NComplex);
var
  menosy: NComplex;
begin
  menosy := prc(-1, ay)^;
  pon(posIg, posV, menosy);
  pon(posIg, negV, ay);
  pon(negIg, posV, ay);
  pon(negIg, negV, menosy);
end;

procedure TSistema.PonTrafoZcc(PriPos, PriNeg, SecPos, SecNeg: integer;
  Zcc, n: NComplex);

var
  y,xyt,n2,y2: NComplex;
begin
  y := invc(Zcc)^;
  xyt:= prc(sqr(n.r),y)^;
  n2:=  pc(n,n)^;
  y2:=prc(1/n2.r,y)^;
  PonIgV(PriPos, PriNeg, PriNeg, PriPos, y2);
  y := dc(y, n)^;
  PonIgV(PriNeg, PriPos, SecNeg, SecPos, y);
 (*
 OJO  para mi que estan dados vuelta ENERO 2012 lo corrijo
  PonIgV(SecPos, SecNeg, PriNeg, PriPos, y);
  y := dc(y, n)^;
  PonIgV(SecNeg, SecPos, SecNeg, SecPos, y);
  *)
  PonIgV(SecNeg, SecPos, PriNeg, PriPos, y);

  y2 := pc(n,y)^;
  PonIgV(SecPos, SecNeg, SecNeg, SecPos, y2);

end;


procedure TSistema.PonTrafoZcc1(n1, n2: integer; xy: NComplex; n: NReal);

var
  xyt,menosy, menosyt,y2: NComplex;
begin

        y2:=prc(1/(n*n),xy)^;
        menosyt:= prc(-n,y2)^;

        self.pon(n1,n1,y2);
	self.pon(n1,n2, menosyt);
	self.pon(n2,n1, menosyt);
	self.pon(n2,n2, xy);

end;



procedure TSistema.PonCuadripolo(n1, n2, n3: integer; Y13, Z12, Y23: NComplex);
begin
  PonY(n1, n3, y13);
  PonY(n1, n2, invc(Z12)^);
  PonY(n2, n3, Y23);
end;


function TSistema.almacenDelCorte(pec: TEcuacion): TEcuacion;
begin
  if pec = nil then
    Result := pec
  else
  if pec.fd_corte = nil then
    Result := pec
  else
    Result := almacenDelCorte(necPtr(pec.fd_corte.nec));
end;

 // acumula el corte en la de menor índice
 // y nos retorna la ecuación en la que hay que poner la relación de tensión
function TSistema.CombinarCortes(N1, N2: integer; factor_N2ToN1: NComplex): TEcuacion;

var
  corteDestino, corteOrigen: TEcuacion;
  ec1, ec2: TEcuacion;
  almacen1, almacen2: TEcuacion;
  nalmacen1, nalmacen2: integer;
  N_CorteOrigen, N_CorteDestino: integer;
  r:   NComplex;
  k:   integer;
  pec: TEcuacion;

begin
  ec1      := NEcPtr(N1);
  ec2      := NEcPtr(N2);
  almacen1 := almacenDelCorte(ec1);
  almacen2 := almacenDelCorte(ec2);
  nalmacen1 := ptrnec(almacen1);
  nalmacen2 := ptrnec(almacen2);
  if nalmacen1 = nalmacen2 then
    raise Exception.Create('CombinarCortes( ' + IntToStr(N1) +
      ', ' + IntToStr(N2) + ', ...) bucle de cortes!! con destino: ' +
      IntToStr(nalmacen1));


  if (nalmacen1 < nalmacen2) then
  begin
    N_CorteOrigen := nalmacen2;
    N_CorteDestino := nalmacen1;
    r := factor_N2ToN1;
    if Nalmacen2 <> n2 then
      r := dc(r, ec2.fd_corte.factor)^;
    if nalmacen1 <> n1 then
      r := pc(r, ec1.fd_Corte.factor)^;
    corteOrigen := almacen2;
    corteDestino := almacen1;
  end
  else
  begin
    N_CorteOrigen := nalmacen1;
    N_CorteDestino := nalmacen2;
    r := invc(factor_N2ToN1)^;
    if Nalmacen1 <> n1 then
      r := dc(r, ec1.fd_Corte.factor)^;
    if nalmacen2 <> n2 then
      r := pc(r, ec2.fd_Corte.factor)^;
    corteOrigen := almacen1;
    corteDestino := almacen2;
  end;



  for k := 1 to Count do
  begin
    pec := NecPtr(k);
    if pec.fd_corte.nec = N_CorteOrigen then
    begin
      pec.fd_corte.nec    := N_CorteDestino;
      pec.fd_corte.factor := pc(pec.fd_corte.factor, r)^;
    end;
  end;

  if (N_CorteDestino > 0) then
    CombinarEcuaciones(N_CorteDestino, N_CorteOrigen, r);

  corteOrigen.borrartodo;
  corteOrigen.fd_corte.nec := N_CorteDestino;
  corteOrigen.fd_corte.factor := r;
  corteOrigen.tdec := E_RELTEN;
  Result := corteOrigen;
end;


procedure TSistema.PonVG(nneg, npos: integer; EVal: NComplex);
var
  prelten: TEcuacion;

begin
  if nneg = npos then
    horrores.error('PonVG: los dos bornes  son iguales ');

  prelten := CombinarCortes(nneg, npos, numc(1.0, 0)^);

  // -V(npos) +V(nneg ) + EVal = 0
  prelten.Acumular_(nPos, numc(-1.0, 0.0)^);
  prelten.Acumular_(nNeg, numc(+1.0, 0.0)^);
  prelten.AcumularConstante_(EVal);
end;

   (*


procedure TSistema.PonTI(ppos, pneg, spos, sneg: integer; vs_d_vp: NComplex );



  *)
{para el sistema en cuestion incluyendo el vector constante realiza
la eliminacion gaussiana clasica con pivoteo parcial}


procedure TSistema.Free;
begin
  Free_destruirsistema;
end;

end.

