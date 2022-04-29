{xDEFINE DEBUG_MATRIZ_RUIDA}
{$DEFINE RUIDA_MAYO2013}

{$IFDEF RUIDA_MAYO2013}
{$DEFINE RUIDA_BaBa_PotIterada}
{$ENDIF}

unit umatriz_ruida;

{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, matreal;

(** rch@2012_08_03

  Xs = A * X + B R
  <RR'> = I   y   < XR'> = <RX'> = 0
  => <Xs Xs'> = A < X X' > A' + BB'

  Si suponemos que el proceso está en estado estacionario
  <Xs Xs'> = <XX'>

  con lo cual <XX'> = A <XX'> A'+ BB'  (ec.1 )

  ========
  Petersen & Pedersen, The Matrix Cookbook, Version: November 14, 2008, Page 60
  vec( A X B ) = Kron( B', A ) vec( X )   (ec. 2)

Kron = producto de Kronecker
  ========

  Entonces, vectorizando al ec. 1 tenemos:
   vec( <XX'> ) = Kron( A, A ) vec( <XX'> ) + vec( BB' )

  y podemos despejar:
   vec( <XX'> ) = Inv( I - Kron( A, A ))  vec( BB' )  (ec.3)

  Con la ec. 3 tenemos como calcular <XX'> dadas las matrices
  A y B del filtro.


  Si tenemos una reducción del espacio de estados Y = Mr X
  <YY'> = Mr <XX'> Mr'  (ec. 4)

  si consideramos una matriz de Amplificación Ma, y asumimos
  X = Ma Y , tenemos que la matriz de covarianzas de X no
  coincide la original <XX'>.

  Para recomoponer el "nivel de ruido" sumamos un rúido blango gaussiano W
  multiplicado por una matriz Ba.

  X = Ma Y + Ba W

  ******************* error  *************************
   ESTO ESTABA MAL !!! Y es dado y lo que hay que recomponer no es <XX'> sino
   <XX'> dado un Y.

  <WW'> = I   y  <YW'> = <WY'> = 0
  con lo cual se puede escribir:
  <XX'> = Ma*Mr <XX'> ( Ma*Mr )' + Ba * Ba'

  de donde es posible despejar:
     Ba * Ba' = <XX'> - Ma*Mr <XX'> ( Ma*Mr )' (ec. 5)
  Bautizo a la matriz Ba como "Matriz RUIDA" porque recompone el ruido.
  Dado un punto Y del espacio reducido, el punto
  =================== fin del error ==================


    Observar que si no hay reducción (o sea Mr = I ), como se debe cumplir
    que Mr * Ma = I (para que la reducción de un amplificado del el mismo Y ) resulta
    que de la ec.5 queda Ba = 0.

    También observar que si la reducción es TOtal Mr = 0 entonces, Ma = ? , pero
    como Ma * Mr = 0 , de la ec.5 deducimos que Ba * Ba' = <XX'> y todo el ruido
    tiene que ser recompuesto entonces por Ba pues no hay variación impuesta por
    el estado expandido.

    Si Mr = nil, supone que Mr = 0.

  ******************************
  ** cálculo de Ba - mayo 2013 * rch
  ------------------------------
  Para calcular <XX'>/Y , nos planteamos que X puede  puede simularse como
  X = H Z siendo Z un vector de ruidos
  blancos gaussianos independientes por lo que <ZZ'> = I y <HH'> = <XX'>

  Observar que una vez obtenida un H, si lo multiplicamos por una matriz OrtoNormal  G
  se cumple H G G' H' = H H' por lo que (HG) es también raiz de <XX'>.

  Bueno, dado Y, esribimos:
            X = Ma Y  +  Ba W = H Z

  Se trata de analizar como nos condiciona el conocimiento de Y en los posibles Z
  que podemos seleccionar en forma independiente.

  Observar que si multiplicamos por Mr la ec. anterior tenemos:
            Mr X = Mr Ma Y + Mr Ba W = Mr H Z

  Como Mr X = Y y Mr Ma Y = Y, simplificando tenemos:
            Y = Y + Mr Ba W = Mr H Z

  De donde surje que una solución posible es que Ba esté formado por una base
  del NUCLEO de la transformación Mr.

  Llamemos Fa una base OrtoNormal del núcleo de (Mr H)
  Dada Fa, existirá otra base ortonormal Fb que expande el complemento del
  Nucleo de (Mr H).
  La matriz [Fa, Fb] es por construcción Ortonormal. No perdemos generalidad entonces
  en multiplicar H por esa matriz y tener entonces:

     Y = Y + Mr Ba W = Mr H [Fa, Fb] Z

  Esto nos permite partir el vecto Z en dos tramos, un Za de igual dimensión que W
  y otro Zb y escribir:

     Y = Y + Mr Ba W = Mr H Fa Za + Mr H Fb Zb

  Oberservar entonces que Imponiendo Y = Mr H Fb Zb fijamos el Zb asociado al Y
  y nos queda que Ba = H Fa

  Entonces, hemos encontrado un Ba que cumple con todo.

  El método es entonces
  1) Encontrar un H como raíz de <XX'>
  2) Encontrar un Fa cuyas columnas sean una base Ortonormal del nucleo de (Mr H)
  3) Imponer Ba = H * Fa

  ****
  Otro error detectado en la implementación previa a la versión 392 (mayo 2013)
  es que el escalado de las filas de la matriz Mr tiene que realizarse para que
  la matriz <YY'> tenga 1 (unos ) en la diagonal. Esto es neceario para que
  la partición en bandas de probabilidad del espacio reducido refleje las
  probabilidades de cada variable del espacio reducido cuando es observada
  en forma independiente.

  Esto se soluciona calculando <YY'> = Mr<XX'>Mr' y luego calculando un nuevo
  Mr dividiendo cada fila del Mr original por la raiz cuadrada de los elementos
  diagonales de <YY'> correspondientes.
  Se supone que las filas de Mr son ortogonales por lo que para lograr Mr Ma = I
  basta con elegir Ma = Mr' y luego dividir las columnas de Ma por la norma al cuadrado
  de las filas de Mr para lograr los 1 en la diagonal de Mr Ma.
  ***

*)

function Matriz_RUIDA(const A, B: TMatR; var Ma, Mr: TMatR): TMatR;

(* Si el filtro es X_-1 = A {X_0; X_1; ... .X_nr-1} + B R_0
 donde "_k" indica retardo k

El vector de estados es {X_0; X_1; ... .X_nr-1}

*)
function Matriz_RUIDA_MultiRetardos(const A, B: TMatR; var Ma, Mr: TMatR): TMatR;


implementation

{$IFDEF DEBUG_MATRIZ_RUIDA}
var
  fdbg: textfile;

{$ENDIF}

function Matriz_RUIDA(const A, B: TMatR; var Ma, Mr: TMatR): TMatR;
var
  Kr: TMatR;
  BB: TMatR;
  vecBB: TVectR;
  TI: TMatR;
  resOk: boolean;
  res: TMatR;
  MaMr: TMatR;
  MaMrXXMaMr: TMatR;
  BaBa: TMatR;
  Ba: TMatR;
  k, j: integer;
  aval: NReal;
  XX: TMatR;
  vecXX: TVectR;
  exp10: integer;
  lambda: NReal;

  H: TMatR;
  Fa: TMatR;
  MrH: TMatR;

  DimRes: integer;

begin
  BaBa:= nil;

  {$IFDEF DEBUG_MATRIZ_RUIDA}
  writeln(fdbg, 'Matriz Ruida ');
  writeln(fdbg, 'A');
  A.WriteXLT(fdbg);
  writeln(fdbg, 'B');
  B.WriteXLT(fdbg);
  writeln(fdbg, 'Ma');
  Ma.WriteXLT(fdbg);
  writeln(fdbg, 'Mr');
  Mr.WriteXLT(fdbg);
  {$ENDIF}


  res := nil;

  // Primero calculamos <XXt> a partir de las matrices A y B
  Kr := TMatR.Create_Kron(A, A);
  // Ahora formo I - K
  for k := 1 to Kr.nf do
    for j := 1 to Kr.nc do
    begin
      Kr.pon_e(k, j, -Kr.e(k, j));
      if k = j then
        Kr.acum_e(k, j, 1.0);
    end;

  BB := TMatR.Create_Init( B.nf, B.nf );
  for k:= 1 to B.nf do
    for j:= k to B.nf do
    begin
      aval:= B.Fila(k).PEV( B.Fila(j) );
      BB.pon_e( k, j , aval );
      if j > k then
        BB.pon_e( j, k, aval );
    end;
  vecBB := BB.vec;
  BB.Free;

  TI := vecBB.reshape(vecBB.n, 1); // lo paso a matriz para poder invertir el sistema
  Kr.Escaler(TI, resOk, exp10);
  Kr.Free;
  vecBB.Free;
  // TI queda cargado con vec( <XX'> )
  if resOk then
  begin
    vecXX := TI.vec;
    XX := vecXX.reshape(A.nf, A.nc);
    vecXX.Free;
    {$IFDEF DEBUG_MATRIZ_RUIDA}
    writeln(fdbg, 'XX');
    XX.WriteXLT(fdbg);
    {$ENDIF}
  end
  else
  begin
    {$IFDEF DEBUG_MATRIZ_RUIDA}
    writeln(fdbg, 'Sistema NO Invertible. No Puedo Calcular XXt');
    {$ENDIF}
    Result := nil;
    TI.Free;
    exit;
  end;


  if (Mr <> nil) then
  begin
    {$IFDEF RUIDA_MAYO2013}

    // Primero Reacondiciono Mr y Ma para que Mr <XXt> Mrt tenga diagonal I
    // y que se mantenga que Mr.Ma = I
    VecXX := TVectR.Create_Init(XX.nf);
    for j := 1 to Mr.nf do
    begin
      for k := 1 to XX.nf do
      begin
        VecXX.pv[k] := XX.Fila(k).PEV(Mr.Fila(j));
      end;
      lambda := Mr.Fila(j).PEV(VecXX);
      lambda := sqrt(lambda);
      Mr.Fila(j).PorReal(1 / lambda);
      for k := 1 to Ma.nf do
        Ma.pm[k].pv[j] := Ma.pm[k].pv[j] * lambda;
    end;
    VecXX.Free;

(*** Esto estaba mal
    // si hay Reducción calculo BaBa = <XXt> - MaMr <XXt> (MaMr)t
    MaMr := TMatR.Create_Init(Ma.nf, Mr.nc);
    MaMr.Mult(Ma, Mr);
    MaMrXXMaMr := TMatR.Create_Init(Ma.nf, Ma.nf);
    MaMrXXMaMr.Mult(MaMr, XX);
    MaMr.Transponer;
    MaMrXXMaMr.Mult(MaMrXXMaMr, MaMr);
    BaBa := TMatR.Create_Init(XX.nf, XX.nc);
    for k := 1 to BaBa.nf do
      for j := 1 to BaBa.nc do
        BaBa.pon_e(k, j, XX.e(k, j) - MaMrXXMaMr.e(k, j));
    MaMr.Free;
    MaMrXXMaMr.Free;
***)


(***
Entonces, hemos encontrado un Ba que cumple con todo. El método es entonces
1) Encontrar un H como raíz de <XX'>
2) Encontrar un Fa cuyas columnas sean una base Ortonormal del nucleo de (Mr H)
3) Imponer Ba = H * Fa
***)

//   XX.WriteArchiXLT('c:\basura\XX.xlt');

    H := XX.RaizPorPotenciaIterada( DimRes, true );
    if DimRes < 0 then Raise Exception.Create( 'Matriz_RUIDA, RaízPotenciaIterda autovalor negativo' );

//   H.WriteArchiXLT('c:\basura\H.xlt');

    MrH := TMatR.Create_Init(Mr.nf, H.nc);
    MrH.Mult(Mr, H);


// MrH.WriteArchiXLT('c:\basura\MrH.xlt');

    MrH.CalcBSEN(Fa);

//  Fa.WriteArchiXLT('c:\basura\Fa_CalcBSEN.xlt');
    Fa.OrtoNormal;
    Fa.Transponer;

    Ba := TMatR.Create_Init(H.nf, Fa.nc);
    Ba.Mult(H, Fa);

//  Ba.WriteArchiXLT('c:\basura\Ba.xlt');

    H.Free;
    MrH.Free;
    Fa.Free;
{$ELSE}
    Ba := nil;
{$ENDIF}
  end
  else
  begin
    // si la Reducción es total calculo BaBa = <XXt>
    BaBa := TMatR.Create_Init(XX.nf, XX.nc);
    for k := 1 to BaBa.nf do
      for j := 1 to BaBa.nc do
        BaBa.pon_e(k, j, XX.e(k, j));
  {$IFDEF RUIDA_BaBa_PotIterada}
    Ba := BaBa.RaizPorPotenciaIterada( DimRes, true );
  {$ELSE}
    // mmmm .... salvo que BaBa = <XXt> no funciona.
    Ba := BaBa.raiz_Cholesky;
  {$ENDIF}
  end;


  {$IFDEF DEBUG_MATRIZ_RUIDA}
  writeln(fdbg, 'BaBa');
  BaBa.WriteXLT(fdbg);
  writeln(fdbg, 'Ba');
  if Ba <> nil then
    Ba.WriteXLT(fdbg)
  else
    writeln(fdbg, 'NIL');
  {$ENDIF}
  XX.Free;
  if BaBa <> nil then  BaBa.Free;
  Result := Ba;
end;


function Matriz_RUIDA_MultiRetardos(const A, B: TMatR; var Ma, Mr: TMatR): TMatR;
var
  A_Completa, B_Completa: TMatR;
  nRetardos: integer;
  k, j: integer;
begin
  nRetardos:= A.nc div A.nf;
  if nRetardos = 1 then
  begin
    result:= Matriz_RUIDA( A, B, Ma, Mr);
    exit;
  end;

  A_Completa:= TMatR.Create_Init( A.nc, A.nc );
  A_Completa.Ceros;
  for k:= 1 to A.nf do
    for j:= 1 to A.nc do
      A_Completa.pon_e( k, j,  A.e(k,j ));
  for k:= A.nf+1 to A_Completa.nf do
    A_Completa.pon_e( k, k- A.nf, 1.0 );

  B_Completa:= TMatR.Create_Init( A.nc, B.nc );
  B_Completa.Ceros;
  for k:= 1 to B.nf do
   for j:= 1 to B.nc do
     B_Completa.pon_e( k,j, B.e(k,j));

  result:= Matriz_RUIDA( A_Completa, B_Completa, Ma, Mr);
  A_completa.Free;
  B_Completa.Free;
end;

initialization

{$IFDEF DEBUG_MATRIZ_RUIDA}
  assignfile(fdbg, 'MATRIZ_RUIDA.TXT');
  rewrite(fdbg);
{$ENDIF}

finalization

{$IFDEF DEBUG_MATRIZ_RUIDA}
  closefile(fdbg);
{$ENDIF}

end.



