{+doc
+NOMBRE: IntPoint
+CREACION: 31.1.98
+AUTORES:rch
+REGISTRO:
+TIPO: Unit PASCAL
+PROPOSITO:
   Algoritmo que determina si un punto es interior o no a un
   pol¡gono definido como un vector de complexs.

+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

{ La funci¢n InternalPoint retorna TRUE si el punto Q es interior
al Poligono que forman los puntos del vector X pasado como par metro }
unit IntPoint;

{$MODE Delphi}

interface

uses
  Math, xMatDefs, AlgebraC, MatCpx;

// recibe un puntero al primer Punto de un Poligono y la cantidad NPuntos del polígono
// que deben estar en direcciones contiguas de memoria.
// La función determina si el punto Q es interior al Poligono o no.
// El método utilizado para determinar si el punto es interior consiste en
// contar las veces que los segmentos del Polígono cortan la semirecta que
//  x = Q.r e y >= Q.i
// Si la cantidad de cortes es PAR el punto es exterior. Si la cantidad es impar
// el punto es interior.
function InternalPoint(Q: NComplex; pPrimerPunto: PNComplex; NPuntos: Integer ): boolean; overload;

// lo mismo que la anterior, pero sobre un Poligono pasado como un array dinámico de complejos
function InternalPoint(Q: NComplex; const poligono: TVarArrayOfComplex ): boolean; overload;

// productoVectorial( u, v )
// res= ro_u * ro_v * sin( alfa_u - alfa_v ) = img( u * cc( v ) )
function productoVectorial( const u, v: NComplex): NReal;

// angulo_uv( u, v )
// res = fase( u * cc( v ) )
function angulo_uv( const u, v: NComplex ): NReal;

// dado un Punto Q y un Poligono, retorna los dos vértices Va, Vb, del Poligono que
// forman el mayor ángulo con Q. Si Q es exterior al polígono, el ángulo formado
// en sentido anti-horario por las semirectas de origen Q y que pasan por Va y Vb
// contienen al polígono.
// Se asume que el polígono es convexo y que NPuntos >= 2
procedure AnguloAlConvexo(
    var kA, kB: integer; // vertices derecho e izquierdo del ángulo al Poligono ( 0..NPUntos-1)
    var alfa_P0_A, alfa_P0_B: NReal;
    const Q: NComplex;
    pPrimerPunto: PNComplex; NPuntos: integer // el poligono Convexo
    ); overload;

procedure AnguloAlConvexo(
    var kA, kB: integer; // vertices derecho e izquierdo del ángulo al Poligono
    var alfa_P0_A, alfa_P0_B: NReal;
    const Q: NComplex;
    const poligono: TVarArrayOfComplex ); overload;


// AmpliarConvexoAlPunto
// Amplia un convexo dado para incluir el punto dado
// El resultado es un nuevo convexo que incluye al punto Q.
procedure AmpliarConvexoAlPunto( var Convexo: TVarArrayOfComplex; const Q: NComplex );

// ContornoConvexo
// Dada una Nube de Complejos, retorna el Poligono que describe el contorno
// convexo más ajustado a la nube.
function ContornoConvexo( const Nube: TVarArrayOfComplex ): TVarArrayOfComplex;

implementation

// res= ro_u * ro_v * sin( alfa_u - alfa_v ) = img( u * cc( v ) )
function productoVectorial( const u, v: NComplex): NReal;
begin
  result := u.r * v.i - u.i * v.r;
end;

// angulo_uv( u, v )
// res = fase( u * cc( v ) )
function angulo_uv( const u, v: NComplex ): NReal;
begin
  result:= fase( pc( u, cc( v )^)^);
end;


procedure AnguloAlConvexo(
    var kA, kB: integer; // vertices derecho e izquierdo del ángulo al Poligono ( 0..NPUntos-1)
    var alfa_P0_A, alfa_P0_B: NReal;
    const Q: NComplex;
    pPrimerPunto: PNComplex; NPuntos: integer // el poligono convexo
    );
var
  minAlfa, maxAlfa, alfa: NReal;
  p: PNComplex;
  QP0, QPk, QPk_ant: NComplex;
  buscando: boolean;
  k: integer;
  estado: integer; // 0 no determiné el sentido, 1 sentido determinado, 2 reversa, 3 fin
  sentido: integer; // 1 alfa crece con k, -1 alfa decrece con k

procedure buscar_alfa_creciente_inck;
begin
  buscando:= true;
  while buscando and ( k < (NPuntos-1) ) do
  begin
    inc( p ); inc( k );
    QPk_ant:= QPk;
    QPk:= rc( p^, Q )^;
    alfa:= angulo_uv( QPk, QP0 );
    if alfa > maxAlfa then
      maxAlfa:= alfa
    else
      if alfa = maxAlfa then
      begin
        if mod2( QPk ) < mod2( QPk_ant ) then
          buscando:= false;
      end
      else
        buscando:= false;
  end;
end;

procedure buscar_alfa_decreciente_inck;
begin
  buscando:= true;
  while buscando and ( k < (NPuntos-1) ) do
  begin
    inc( p ); inc( k );
    QPk_ant:= QPk;
    QPk:= rc( p^, Q )^;
    alfa:= angulo_uv( QPk, QP0 );
    if alfa < minAlfa then
      minAlfa:= alfa
    else
      if minAlfa = alfa then
      begin
        if mod2( QPk ) < mod2( QPk_ant ) then
          buscando:= false;
      end
      else
        buscando:= false;
  end;
end;

procedure buscar_alfa_creciente_deck;
begin
  buscando:= true;
  while buscando and ( k > 0 ) do
  begin
    dec( p ); dec( k );
    QPk_ant:= QPk;
    QPk:= rc( p^, Q )^;
    alfa:= angulo_uv( QPk, QP0 );
    if alfa > maxAlfa then
      maxAlfa:= alfa
    else
      if maxAlfa = alfa then
      begin
        if mod2( QPk ) < mod2( QPk_ant ) then
          buscando:= false;
      end
      else
        buscando:= false;
  end;
end;

procedure buscar_alfa_decreciente_deck;
begin
  buscando:= true;
  while buscando and ( k > 0 ) do
  begin
    dec( p ); dec( k );
    QPk_ant:= QPk;
    QPk:= rc( p^, Q )^;
    alfa:= angulo_uv( QPk, QP0 );
    if alfa < minAlfa then
      minAlfa:= alfa
    else
      if minAlfa = alfa then
      begin
        if mod2( QPk ) < mod2( QPk_ant ) then
          buscando:= false;
      end
      else
        buscando:= false;
  end;
end;

begin
  minAlfa:= 0; maxAlfa:= 0;
  QP0:= rc( pPrimerPunto^, Q )^;

  // búsqueda k_Creciente
  buscando:= true;
  k:= 0;
  p:= pPrimerPunto;
  QPk:= QP0;

  // busco el primer vértice que me permita determinar el sentido
  while buscando and ( k < (NPuntos-1) ) do
  begin
    inc( p ); inc( k );
    QPk_ant:= QPk;
    QPk:= rc( p^, Q )^;
    alfa:= angulo_uv( QPk, QP0 );
    if (alfa > 0) and ( alfa < pi ) then sentido:= 1
    else if alfa < 0 then sentido:= -1;
  end;

  // si no pude determinar el sentido quiere decir que el polígono
  // es una recta que pasa por Q. En este sentido, debiera ser un
  // segmento. Devolvemos como puntos extremos el Primero y El ultimo;
  if buscando then
  begin
    kA:= 0; alfa_P0_A:= 0;
    kB:= NPuntos -1 ; alfa_P0_B:= alfa;
    exit;
  end;

  // ahora continuamos incrementando k hasta que se invierta el sentido
  // o lleguemos al final
  if sentido > 0 then
  begin
    buscar_alfa_creciente_inck;
    kB:= k;
    p:= pPrimerPunto; inc( p, NPuntos ); // apunto el último pues voy en reversa.
    k:= 0;
    buscar_alfa_decreciente_deck;
    kA:= k;
  end
  else
  begin
    buscar_alfa_decreciente_inck;
    kB:= k;
    p:= pPrimerPunto; inc( p, NPuntos ); // apunto el último pues voy en reversa.
    k:= 0;
    buscar_alfa_creciente_deck;
    kA:= k;
  end;
end;

procedure AnguloAlConvexo(
    var kA, kB: integer; // vertices derecho e izquierdo del ángulo al Poligono
    var alfa_P0_A, alfa_P0_B: NReal;
    const Q: NComplex;
    const poligono: TVarArrayOfComplex );
begin
  AnguloAlConvexo( kA, kB, alfa_P0_A, alfa_P0_B, Q, @poligono[0], length( poligono ));
end;

function InternalPoint(Q: NComplex; pPrimerPunto: PNComplex; NPuntos: Integer ): boolean;
var
  par:    boolean;
  k:      integer;
  amb1, amb2: integer;
  p1, p2: PNComplex;

  function intersec(var A, B: NComplex): integer;
  var
    QA, QB: NComplex;
    t1, t2: NReal;
  begin
    QA := rc(A, Q)^;
    QB := rc(B, Q)^;
    t1 := QA.r;
    t2 := QB.r;
    if productoVectorial(QA, QB) > 0 then
      if (t1 < 0) and (t2 > 0) then
        intersec := 1
      else if (t1 = 0) or (t2 = 0) then
        if (t1 < 0) or (t2 > 0) then
          intersec := 2
        else
          intersec := 0
      else
        intersec := 0
    else
    if (t1 > 0) and (t2 < 0) then
      intersec := 1
    else if (t1 = 0) or (t2 = 0) then
      if (t1 > 0) or (t2 < 0) then
        intersec := -2
      else
        intersec := 0
    else
      intersec := 0;
  end;

  procedure proc1;
  begin
    case intersec( p1^, p2^ ) of
      1: par := par xor True;
      2: Inc(amb1);
      -2: Inc(amb2);
      else {nada}
    end;
  end;

begin
  par  := False;
  amb1 := 0;
  amb2 := 0;


  p1   := pPrimerPunto;
  p2   := p1;
  inc( p2 );
  for k := 1 to NPuntos-1 do
  begin
    proc1;
    p1 := p2;
    Inc(p2);
  end;
  p2 := pPrimerPunto;
  proc1;
  amb1 := amb1 - amb2;
  internalPoint := par xor (amb1 <> 0);
end;


function InternalPoint(Q: NComplex; const poligono: TVarArrayOfComplex ): boolean;
begin
  result:= InternalPoint( Q, @poligono[0], length( poligono ) );
end;


procedure AmpliarConvexoAlPunto( var Convexo: TVarArrayOfComplex; const Q: NComplex );
var
  res: TVarArrayOfComplex;
  kA, kB, k: integer;
  kTest: integer;
  flgTestTramo, eliminarTramo: integer;
  alfa_P0_Q_A, alfa_P0_Q_B: NReal;
  uAB, uAQ, uAP0: NComplex;
//  alfa_Q, alfa_P0: NReal;
  d2AQ, d2AB, d2QB: NReal;

  k1, k2: integer;
  uAP: NComplex;
  alfa_BAP, alfa_BAQ: NReal;

begin
  if length( Convexo ) < 2 then
  begin
    if length( convexo ) = 0 then
    begin
      setlength( convexo, 1 );
      convexo[0]:= Q;
    end
    else
    begin
      uAB:= rc( convexo[0], Q )^;
      if mod2( uAB ) > 0 then
      begin
        setlength( Convexo, Length(Convexo) + 1 );
        res[high(res)]:= Q;
      end;
    end;
    exit;
  end;

// Si no salí antes es que el convexo tiene por lo menos 3 puntos.

  if ( InternalPoint( Q, Convexo ) ) then exit;

// Si el punto no es interior, puede ser exterior o estar en el contorno.
  AnguloAlConvexo( kA, kB, alfa_P0_Q_A, alfa_P0_Q_B, Q, Convexo);
  uAB:= rc( Convexo[kB], Convexo[kA] )^;
  uAQ:= rc( Q, Convexo[kA] )^;

  // detección del caso especial en que Q pertece a la recta AB
  // para ello, alfa_P0_Q_A y alfa_P0_Q_B son CERO o PI
  // si ambos tiene el mismo valor entonces Q es externo al segmento (AB)
  // y deberá sustituir uno de ambos. Si son diferentes Q está entre A y B
  // y entoces está incluído en el segmento y no hay que hacer nada.
  if (( alfa_P0_Q_A = 0 ) or (  alfa_P0_Q_A = pi ) ) and
      ( ( alfa_P0_Q_B = 0 ) or (  alfa_P0_Q_B = pi ) ) then
  begin
    if ( alfa_P0_Q_A = alfa_P0_Q_B ) then
    begin
      d2AQ:= mod2( uAQ );
      d2QB:= mod2( rc( Convexo[kB], Q )^);
      if d2AQ < d2QB then
        convexo[ kA ]:= Q
      else
        convexo[kB]:= Q;
    end;
    exit;
  end;

  // Si llegamos hasta aquí, Q es externo al convexo (incluyendo su contorno)
  // y además no está sobre la recta AB.


  assert( kA <> kB , 'AmpliarConvexoAlPunto kA<>kB FALLO!' );

  if kA < kB then
  begin
    k1:= kA;
    k2:= kB;
  end
  else
  begin
    k1:= kB;
    k2:= kA;
  end;


  if ( length( convexo ) = 2 ) then
  begin
    // simplemente agregamos el punto Q.
    setlength( convexo, 3);
    convexo[2]:= Q;
    exit;
  end;


  // El Convexo está dividido en 2 tramos por el segmento P_k1 P_k2
  // Un tramo es el de los vértices k1, k1+1, k1+2 , ... k2 (Tramo 1)
  // El otro tramo es el de los vértives k2, k2+1, ..NPuntos-1, 0, 1, ... k1 (Tramo 0)
  // O sea el Tramo 0, "cierra en anillo"
  // justo sea k1 = 0 o k2 = 0.
  // De los dos tramos, hay uno que está "mas cercano a Q" y que debe ser
  // eliminado del contorno del Convexo pues es sutituído por los lados
  // (Q, P_k1) y (Q, P_k2 )

  if ( k2 - k1 ) > 1 then // hay por lo menos un punto en el tramo superior
  begin
    // testeo sobre el tramo superior
    kTest:= k1 + 1;
    flgTestTramo:= 1;
  end
  else
  begin
    //testeo sobre el tramo inferior
    flgTestTramo:= 0;
    if ( k1 > 0 ) then
      kTest:= 0
    else
      if k2 < high( convexo ) then
        kTest:= k2+1;
  end;

  uAP:= rc( Convexo[kTest], Convexo[kA] )^;
  alfa_BAP:= angulo_uv( uAB, uAP );
  alfa_BAQ:= angulo_uv( uAB, uAQ );

  if ( sign( alfa_BAP ) = sign( alfa_BAQ ) ) then
    eliminarTramo:= flgTestTramo  // si coinciden los ángulos el tramo a eliminar es el bajo test
  else
    eliminarTramo:= 1- flgTestTramo; // si no coinciden es el tramo que no está bajo test

    if eliminarTramo = 1 then
    begin
      // 0..k1 , Q , k2...
      setlength( res, (k1+1) +1+ (high( convexo ) - k2 +1));
      for k:= 0 to k1 do
        res[k]:= convexo[k];
      res[k1+1]:= Q;
      for k:= k2 to high( convexo ) do
        res[ k-k2+ k1+2]:= convexo[k];
      convexo:= res;
    end
    else
    begin
      // Q, k1 ... k2
      setlength( res, 1 + (k2-k1 +1 ));
      res[0]:= Q;
      for k:= k1 to k2 do
        res[k-k1+1]:= convexo[k];
      convexo:= res;
    end;
end;

function ContornoConvexo( const Nube: TVarArrayOfComplex ): TVarArrayOfComplex;
var
  res: TVarArrayOfComplex;
  NPuntos: integer;
  k: integer;

begin
  setlength( res, 0  );
  for k:= 0 to high( nube ) do
    AmpliarConvexoAlPunto( res, Nube[k] );
  result:= res;
end;

end.

