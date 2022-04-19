unit usimplex;
{$IFNDEF WINDOWS}
{$UNDEF DBGMONSPX} // NO hay mensajería en Linux.
{$ENDIF}

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

{xDEFINE CNT_COTAS}
{$DEFINE IMPONGO_CEROS}
{xDEFINE ESPARSA}
//Usa una matriz esparsa para el simplex

{xDEFINE DBG_CONTAR_CNT_SIMPLEX}
//Lleva la cuenta de la cantidad de simplex resueltos en toda la ejecución
{$IFDEF DBG}
{$DEFINE DBG_CONTAR_CNT_SIMPLEX}
{$ENDIF}
interface

uses
{$IFDEF DBGMONSPX}
  Dialogs,
  Forms,
{$IFDEF WINDOWS}
  Windows,
{$ENDIF}
Messages,
{$ENDIF}
{$IFDEF ESPARSA}
  uSparseMatReal,
{$ELSE}
  MatReal,
{$ENDIF}
  Math,
  matent, xMatDefs,
  SysUtils,
  //  uConstantesSimSEE,
  uListaViolacionesPermitidasSimplex;

(*+doc usimplex
Implementación del método SIMPLEX para resolución de problemas de
optimización linea.

rch.2006 implementación del método simplex de acuerdo
 con el libro: Lectures on Numerical Mathematics ( Heinz Rutishauser 1990 )

El algoritmo trabaja sobre una matriz ( a ) de ( m x n )
La cantidad de variables de optimizacion (x ) es ( n-1 )
y la cantidad de restricciones es ( m-1 ).

El problema está planteado como de maximizar la funcion
  z= sum( a(m,j)* x(j); j=1..n-1 )
sujeto a (m-1) restricciones del tipo:
  y= sum( a(k,j)*x(j); j=1..n-1 ) + a(k, n) >= 0 ; k=1..m-1


Esta versión está mejorada respecto de la del libro en los siguientes
aspectos:
1) Busca de una solución factible inicial. Para eso se ordenan las
   restricciones dejando para el final las que no son satisfechas
   y se elige la primera insastifecha tal como si se tratase de la función
   a maximizar. Se intenta entonces resolver el problema con esa función
   objetivo hasta que la misma se vuelva positiva (pasó a factible). Luego
   se continúa con la siguiente restricción insatisfecha y así hasta que están
   todas satisfechas o no se puede continuar (problema infactible).
2) Tratamiento de cotas inferiores no nulas. Se introdujo el método
    procedure cota_inf_set( ivar: integer; vxinf: NReal );

    que permite fijar una cota inferior no nula para la variable de índice ivar.
    Tener en cuenta que este procedimiento tiene que ser llamado durante el
    armado del problema, luego de haber cargado todas las restricciones, pues
    realiza un cambio de variables sobre las mismas.

3) Manejo de cotas superiores en forma inteligente. En lugar de tener que
    incluir una restricción para cada cota superior, las mismas se tratan en
    forma inteligente observando que con un cambio de variable adecuado es posible
    representar la restricción de cota superior como una de x >= 0 y que no
    es necesario entonces incluir la restricción como una fila más en la matriz.

4) Los cambios de variables para el manejo de las "restricciones de caja"
    impone que al leer los resultado deben deshacerse dichos cambios, para eso
    incluímos las funciones:
    xval( ivar )  : retorna el resutaldo de la variable x
    yval( irest ) : retorna el valor que toma la restricicón
    fval : retorna el valor de la función objetivo
    xmult( ivar ): retorna el multiplicador de Lagrange asociado a la variable
                  será 0 (nulo) si la variable x no está en sus valores extremos
                  o será un valor no nulo si está activa una de las dos restricciones
                  en cuyo caso es el multiplicador asociado a la restriccion
                  activa.
    ymult(irest): retorna el multiplicador asociado a la restricción irest
                  será 0 (nulo) si la restricción no está activa y negativo
                  en caso contrario.
5) Posibilidad de FIJAR VARIABLES. Esto permite fijar un valor para una
variable (es decir que deja de ser variable). Es para facilitar el planteo
del problema.
**************************
Nota.
-----
Este simplex, MAXIMIZA la función objetivo f(x) y las restricciones son del
tipo y(x) >= 0 .
Esto lleva a que si lo que estamos es minimizando una función de costo(x)
la función objetivo sea f(x) = - costo(x)

Esto puede confundir un poco en la interpretación de los multiplicadores de Lagrange.
Por ejemplo, si una restricción represanta la necesidad de cubrir determinada demanda (D)
con diferentes fuentes (x). La variación del costo frente a un aumento del valor de (D) será
positiva por lo que la variación correspondiente de f(x) será negativa.

*)

const
(*
Esta constante se utiliza en el proceso de selección del mejor_pivote, para
no elegir pivotes casi nulos que sean el resultado de redondeos numéricos.
Cuando un coeficiente es comparado con CasiCero_Simplex para saber si es
candidato a pivote, colateralmente se lo impone CERO si es inferior en valor
absoluto a CasiCero_Simplex.
*)
  CasiCero_Simplex = 1.0E-7;
  CasiCero_Simplex_CotaSup = CasiCero_Simplex * 1e3;

{$IFDEF DBGMONSPX}
const
(*+doc WM_DBGMONSPX
  Mensaje a ser enviado a la ventana de monitoreo avisando
  que existe un mensaje en el buffer de log del monitoreo. -doc*)
  WM_DBGMONSPX = WM_USER + 1414;

var
  dbgmonspx_hwinMonitor: HWND;
  dbgmonspx_mensaje: string;

  // al enviar el mensaje lo ponemos a 0 y el monitor debe volverla a 1 para
  // indicar que se debe continuar o a -1 para ordenar abortar la ejecución.
  dbgmonspx_flgContinuar: integer;
{$ENDIF}

type
  TArrayOfStrings = array of string;
  TFuncNombre = function(i: integer): string of object;

  TFichaAcopleVEntera = record
    ivar: integer;
    ires: integer;
  end;
  TListaAcoplesVEntera = array of TFichaAcopleVEntera;


  {$IFDEF ESPARSA}
  TSimplex_Matrix = TSparseMatR;
  {$ELSE}
  TSimplex_Matrix = TMatR;
  {$ENDIF}

  TSimplex = class(TSimplex_Matrix)
  private
    //se fija si puede arreglar la restricción modificando la cota superior de
    //una de las variables permitidas
    function intentarModificarCotaSupParaResolverRes: boolean;
(*
realiza la combinacion lineal: fila(kdest,j):= fila(kdest,j) + m*fila(korg,j)
afectando solamente las celdas con j:= jini to jfin
*)

    //      procedure combinax( kdest, korg, jini, jfin: integer; m :NReal );
    //Cambia la fila que se encuentre ahora en kfil por la fila que se encuentre
    //ahora en jcol. No la variable o restriccion que haya sido cargada en la columna
    //o fila

    procedure intercambiar(kfil, jcol: integer);

(*
buscamos una columna en que en la ultima fila (fila z ) el valor es negativo
retorna el indice  si lo encontro, -1 si son todos >= 0
*)
    function locate_zpos(kfila_z: integer): integer;

(*
dada una columna q candidata busca la fila k para intercambiar
el resultado es el indice (p) de fila o -1 si no hay ningun candidato
a pivote a(p,q) que sea negativo.
La búsqueda se realiza entre las filas 1 y kmax -1.
Si la fila en kmax es una variable con restricción de cota superior
revisa tambien que esta no se este violando.

Si el resultado es -3, quiere decir que en la coluna q hay una variable x
con manejo de cota superior y que el mejor pivote corresponde a cambiar en la
misma columna la representación de la variable.
Si el resultado es > 0 pero la fantasma se devuelve con TRUE quiere decir
que el resultado identifica un fila para intercambiar con q, pero que la fila
a intercambiar es la "fantasma" asociada a la fila identificada. Es decir la
de su cota superior.
*)
    function mejorpivote(q, kmax: integer; var filaFantasma, colFantasma: boolean;
      checkearFilaOpt: boolean): integer;

(*
Suponiendo que se ha encontrado un estado FACTIBLE ( a(k, n) >=0 ,k=1..m-1 )
El resultado es:
  1 si el paso fue dado exitosamente
  0 si ya no hay más pasos para dar (ya es óptimo)
  -1 no se encontró un pivote bueno para dar el paso, PROBLEMA NO ACOTADO
*)
    function darpaso: integer;

(*
Reordenar para poner las factibles primero´
retorna el número de infactibles
*)
    function reordenarPorFactibilidad: integer;

(*
Intercambia las filas y los indices de left
*)
    procedure IntercambioFilas(k1, k2: integer);

(*
Intercambia las columnas y los indices de top
*)
    procedure IntercambioColumnas(j1, j2: integer);

(*
Búsqueda de punto factible
*)
    function pasoBuscarFactible: integer;

  {Busca el elemento con mayor valor absoluto en la caja entre cnt_RestriccionesRedundantes + 1
  y cnt_RestriccionesRedundantes + nIgualdadesNoResueltas. A su vez cuenta la cantidad
  de ceros en filas y columnas para cada valor en esa caja. Luego hace una segunda pasada
  comparando la cantidad de ceros en filas y columnas para los valores relativamente
  cercanos al maximo encontrado, si algun valor esta cerca y tiene mas ceros será elegido
  como pivote}
    function pasoBuscarFactibleIgualdad4(nIgualdadesNoResueltas: integer;
      var nCerosFilas, nCerosCols: TDAofNInt): integer;

    function locate_qOK(p, jhasta, jti: integer): integer;

    function test_qOK(p, q, jti: integer; var apq: NReal): boolean;

(*
  Fija las variables declaradas como constantes.
*)
    procedure FijarVariables;

(*
  Reordena el sistema poniendo las filas correspondientes a restricciones de
  igualdad encima de todo.
  Busca volverlas factibles de a una y en la medida en que logra que una
  restricción de igualdad quede en una columna reordena las columnas para fijar
  esa columna.
*)
    function ResolverIgualdades: integer;

(*
  Realiza el cambio de cota (superio <-> inferior) considerada para la
  variable x asociada a la fila k_fila del sistema y cuya cota superior
  está siendo violada. Se supone que k_fila es el resultado a una
  llamada a "primer_cota_sup_violada" y que por lo tanto realmente identifica
  una fila que está representando una variable x (o x'= x_sup-x ) cuya cota
  superior está siendo violada.
*)
    procedure cambiar_borde_de_caja(k_fila: integer);

(*
  Estas funciones actualizan los índices directos en función del contenido
  de los indices inversos left y top
*)
    procedure Actualizo_iileft(k: integer);
    procedure Actualizo_iitop(k: integer);

(*
  Si q es el índice de una columna que está asociada a una variable del
  tipo x , y esa variable tiene cota superior, realiza el cambio de variable
  en la columna.
*)
    function cambio_var_cota_sup_en_columna(q: integer): boolean;

    //Decrementa la cantidad de restricciones infactibles
    procedure decCnt_RestrInfactibles;
    //Indica si la restricción en kfila esta siendo cumplida
    //en caso de no ser cumplida fantasma indica si la violada es la restricción
    //complementaria (true) o la directa (false)
    function filaEsFactible(kfila: integer; var fantasma: boolean): boolean;

{$IFDEF DBG}
(*
Chequeo de factibiblidad, retorna true si el estado actual es factible,
false en caso contrario.
*)
    function primerainfactible: integer;

(*
  Busca la fila correspondiente a una x cuya restricción de cota superior
  es violada.
  Retorna -1 si no encuentra ninguna en esas condiciones, sino retorna el
  índice de la fila.
*)
    function primer_cota_sup_violada: integer;
{$ENDIF}

(*******************************************************************************
  Las siguientes funciones no se usan en la implementación actual, por eso se
  dejan comentadas. Su código se encuentra comentado al final de la unidad
*******************************************************************************)
(*
  Busca el indice de la celda de mayor valor absoluto.
  La búsqueda se realiza entre j= 1 y j=jmax
  Si ningun valor supera en valor abosoluto a AsumaCero el resultado
  es -1.
*)
    //      function locate_maxabs( p, jmax: integer ): integer;
(*
  Búsqueda de punto factible intentando resolver la restricción de igualdad ifila

  Busca un pivote bueno entre las columnas [1..jhasta]
  para solucionar la funcion objetivo de la fila p siendo jti la columna
  de los términos independientes. Esta función se utiliza en la búsqueda
  de la factibilidad donde la función objetivo es la primer restricción violada *)
    //      function pasoBuscarFactibleIgualdad( ifila: integer ): integer;

  {Busca el elemento con mayor valor absoluto en la caja entre cnt_RestriccionesRedundantes + 1
  y cnt_RestriccionesRedundantes + nIgualdadesNoResueltas y lo toma como pivote}
    //      function pasoBuscarFactibleIgualdad3( nIgualdadesNoResueltas: integer ): integer;
  protected
    function defaultGetNombreVar(i: integer): string;
    function defaultGetNombreRes(i: integer): string;
    function getNombreFila(kfila: integer): string; virtual;
    function getNombreCol(kcol: integer): string; virtual;
  public
{$IFDEF SPXCONLOG}
    dbg_on: boolean; // llave para debug
    sdbg: string; // buffer para el log
    nombreVars, nombreRest: TArrayOfStrings;
    archi_spxconlog: string; // camino completo al archivo.
{$ENDIF}
    //Se indexan desde 1 a nc - 1
{$IFDEF ESPARSA}
    x_inf, x_sup: TSparseVectR; // restricciones de caja
{$ELSE}
    x_inf, x_sup: TVectR; // restricciones de caja
{$ENDIF}
{$IFDEF GATILLOS_CAMBIOVAR}
    cnt_Gatillos: integer;
    gatillos_CambioVar: array of smallint;
    gatillos_no_procesados: boolean;
{$ENDIF}
{$IFDEF CNT_COTAS}
    cnt_cotas_inf, cnt_cotas_sup: integer;
{$ENDIF}

    mensajeDeError: string;
    // contadores para debug
    cnt_resolver, cnt_paso, cnt_ViolacionesUsadas: integer;
    violacionesPermitidas: TListaViolacionesPermitidasSimplex;
    fGetNombreVar, fGetNombreRes: TFuncNombre;

(*
abs(top[i]) guarda el número de fila original de la restricción o variable en la
columna i.
abs(left[j]) guarda el número de fila original de la restricción o variable en la
fila j.
Para determinar si se trata de una restricción o una variable se utiliza el signo,
si su valor es negativo es una variable, si es positivo es una restricción.
Se indexan desde 1 y el primer elemento no se utiliza.
Al iniciar a resolver top[i] = -i y left[j] = j.

Ejemplo
Si en la columna 8 se encuentra la restricción que se había creado en la
fila 2 => top[8] = 2.
Si en la fila 1 se encuentra la variable que se había creado en la
columna 3 => left[1] = -3.
*)
    top, left: array of smallint; // < 0 es una x, > 0 es una y

(*
iix[i] guarda la posición que ocupa la variable que originalmente estaba en la
columna i. Si iix[i] = -k la variable se encuentra en la fila k, si iix[i] = k
la variable se encuentra en la columna k.

iiy[j] guarda la posición que ocupa la restricción que originalmente estaba en
la fila j. Si iiy[j] = -m la variable se encuentra en la columna m, si iiy[j] = m
la variable se encuentra en la fila m.
Se indexan desde 1 y el primer elemento no se utiliza.
Al iniciar a resolver iix [i] = i y iiy [j] = j.

Ejemplo
Si la variable que originalmente estaba en la columna 8 se encuentra en la fila 3 => iix[8] = -3.
Si la restricción que originalmente estaba en la fila 1 se encuentra en la columna 4 => iiy [1] = -4.
*)
    iix: array of smallint; // > 0 estan arriba, < 0 estan abajo
    iiy: array of smallint; // < 0 estan arriba, > 0 estan abajo

    cnt_RestrInfactibles: integer;
    cnt_igualdades: integer; // canidad de restricciones de igualdad (al inicio de A ).
    cnt_varfijas: integer; // cantidad de variables fijadas
    cnt_columnasFijadas: integer;
    // Cantidad de columnas fijadas con variables y restricciones

    //Hasta esta fila inclusive las restricciones se consideran resueltas
    cnt_RestriccionesRedundantes_: integer;

    //Se indexan desde 1
    flg_x: array of shortint; // es 0 si no hay cota superior,
    // es -1 si hay cota superior, pero es la inferior la considerada actualemnte
    // es 1 si hay cotas superior y es la considerada actualmente en el sistema.
    // es 2 si esta variable fue fijada.

    flg_y: array of shortint;
    // 0 para restricciones de >=0, 2 si es una =0 , -2 si es una =0 a la que le cambié el signo

    constructor Create_init(m, n: integer;
      xfGetNombreVar, xfGetNombreRes: TFuncNombre); virtual;
    //Crea una copina nueva de spx
    //OJO!! no copia la lista de violacionesPermitidas por eficiencia para el TMIPSimplex
    constructor Create_clone(spx: TSimplex);

    procedure Free(borrarListaViolacionesPermitidas: boolean); reintroduce;

    (* Fijamos que la restricción kfila es de igualdad *)
    procedure FijarRestriccionIgualdad(kfila: integer);

(*
  Fija el valor de una variable. Esto permite escribir las ecuaciones
  considerando la variable pero luego imponerle un valor.
  Debe ser llamado con el indice que tenía la variable cuando se cargo en el
  Simplex
*)
    procedure FijarVariable(ivar: integer; valor: NReal);

    // método para menejo de las restricciones de caja
(*
  Fija el valor de la cota inferior
*)
    procedure cota_inf_set(ivar: integer; vxinf: NReal);

(*
  Fija el valor de la cota superior
*)
    procedure cota_sup_set(ivar: integer; vxsup: NReal);

(*Gatilla un cambio de variable de cota superior para se ejecutado
antes de comenzar a resolver el problema.
Esto se previó para poder indicar que se realicen algunos cambios de variables
antes de comenzar la búsqueda de factibilidad y permitir que si el usuario
sabe que mejora la búsqueda un determinado cambio lo gatille antes de comenzar.*)
{$IFDEF GATILLOS_CAMBIOVAR}
    procedure GatillarCambioVarCotaSup(q: integer);
{$ENDIF}

    (*Funciones auxiliares para leer los resultados*)
    function xval(ix: integer): NReal; virtual;
    function yval(iy: integer): NReal; virtual;
    function xmult(ix: integer): NReal; virtual;
    function ymult(iy: integer): NReal; virtual;
    function fval: NReal; virtual;

    procedure DumpSistemaToXLT(var f: textfile); overload; virtual;
    procedure DumpSistemaToXLT_(archi: string; InfoAdicional: string);
      overload; virtual;

(*
  Busca un punto de arranque factible y si lo encuentra maximiza la función fval
  El resultado es 0 si logró encontrar un punto factible y realizar la maximización
  si no se puede resolver el resultado es <> 0 y se guarda en la variable
  "MensajeDeError" del objeto la causa encontrada.
  *)
    function resolver: integer; virtual;

(*
  Limpia todo el sistema y lo preprara para recibir un nuevo problema.
*)
    procedure limpiar; virtual;

(*
  Esta función se define, pero no se implementa en este simplex.
  Se implementa en TMIPSimplex, aquí se introduce por comodidad de escritura
  del código.
*)
    procedure set_entera(ivae, ivar: integer; CotaSup: integer); virtual;
    procedure set_EnteraConAcople(ivae, ivar: integer; CotaSup: integer;
      ivarAcoplada, iresAcoplada: integer); virtual;

    procedure set_EnteraConAcoples(ivae, ivar: integer; CotaSup: integer; lstAcoples: TListaAcoplesVEntera); virtual;

    //Debe ser llamado con el indice que tenía la restricción cuando se cargo en
    //el Simplex.
    //Hace que la fila kres original se considere satisfecha (=0) y deja de
    //considerarla en las cuentas
    procedure declararRestriccionRedundante(kres: integer);
    //Debe ser llamado con los indices que tenían la restricción y la variable
    //cuando se cargaron en el Simplex
    //Declara que la variable ivar puede agrandar su cota superior si la restricción
    //ires no puede satisfacerse de otra manera
    procedure permitirViolarBordeSupParaSatisfacerRestriccion(ires: integer;
      ivars: TDAofNInt);

    procedure rearmarIndicesiiXiiY;
{$IFDEF SPXCONLOG}
    (*Funciones para debug*)
    procedure clearlog;
    procedure writelog(const s: string);
    // escribe el sistema entero para poder hacer dbug
    procedure appendWriteXLT(const texto: string; var cnt_llamadas: integer;
      reescribir: boolean);
    procedure set_NombreVar(ivar: integer; xnombre: string);
    procedure set_NombreRest(irest: integer; xnombre: string);

    function flagXToString(flagX: integer): string;
    function flagYToString(flagY: integer): string;

    property xval_dbg[ix: integer]: NReal read xval;
    property yval_dbg[iy: integer]: NReal read yval;
{$ENDIF}
  end;

procedure ejemplo;

{$IFDEF DBGMONSPX}
(*+doc dbgmonspx_RegistrarMonitor
 registra la aplicación que recibirá los mensajes.
 Atención la aplicación debe llamar la función dbgmonspx_LeerMensaje
 como respuesta al mensaje que reciba para liberar el buffer de mensaje.
 Además debe llamar dbgmonspx_Continuar para que continué la ejecución
 del simplex.
 Para desregistrar la aplicación llamar eta función con hmon=0 que significa
 que no hay monitor registrado.
  -doc*)
procedure dbgmonspx_RegistrarMonitor(hmon: HWND);

(*+doc dbgmonspx_LeerMensaje
 debe ser llamada por la aplicación de monitoreo para leer el texo del
 mensaje asociado. -doc*)
function dbgmonspx_LeerMensaje: string;

(*+doc dbgmonspx_Continuar
 Este procedimiento debe ser llamado al final de la atención del mensaje
 por parte de la aplicación de monitoreo para indicar que ha terminado
 la atención al mensaje y que se puede continuar con la ejecución. -doc*)
procedure dbgmonspx_Continuar;

(*+doc dbgmonspx_Abortar
 Este procedimiento debe ser llamado al final de la atención del mensaje
 por parte de la aplicación de monitoreo para indicar que ha terminado
 la atención al mensaje y que se debe abortar  la ejecución.
 Como consecuencia de la llamada de esta función se dispara una exception EAbort
 -doc*)
procedure dbgmonspx_Abortar;

(*doc+ dbgmonspx_notificar
Envía el mensaje de WM_DBGMONSPX a la aplicación registrada como
monitor. Si no hay aplicación registrada no hace nada.
Luego de enviar el mensaje se queda esperando que el monitor llame a la
función dbgmonspx_Continuar para continuar con la ejecución. -doc*)
procedure dbgmonspx_notificar(s: string; wparam, lparam: integer);
{$ENDIF}


{$IFDEF DBG_CONTAR_CNT_SIMPLEX}
var
  cnt_debug: integer;
  minCnt_DebugParaDump: integer;
{$ENDIF}

implementation




{$IFDEF DBGMONSPX}
procedure dbgmonspx_RegistrarMonitor(hmon: HWND);
begin
  dbgmonspx_hwinMonitor := hmon;
  dbgmonspx_mensaje := '';
  dbgmonspx_flgContinuar := 1;
end;

function dbgmonspx_LeerMensaje: string;
begin
  Result := dbgmonspx_mensaje;
end;

procedure dbgmonspx_Abortar;
begin
  dbgmonspx_flgContinuar := -1;
end;

procedure dbgmonspx_Continuar;
begin
  dbgmonspx_flgContinuar := 1;
end;

procedure dbgmonspx_notificar(s: string; wparam, lparam: integer);
begin
  if dbgmonspx_flgContinuar <> 1 then
  begin
    ShowMessage('[dbgmonspx_notificar]OJO, llamada reentrante a NOTIFICAR con mensaje: '
      + s + ' Ignoramos notificación al monitor para continuar');
    exit;
  end;

  dbgmonspx_mensaje := s;
  if dbgmonspx_hwinMonitor = 0 then
    exit; // no hay monitor registrado

  dbgmonspx_flgContinuar := 0;
  if not SendNotifyMessage(dbgmonspx_hwinMonitor, WM_DBGMONSPX, wParam, lParam) then
    raise Exception.Create(
      'Error enviando mensaje de notificación al MONITOR DE SIMPLEX')
  else
    while dbgmonspx_flgContinuar = 0 do
      Application.ProcessMessages;
  if dbgmonspx_flgContinuar = -1 then
    raise EAbort.Create('ABORTADO POR MONITOR');
end;

{$ENDIF}

procedure TSimplex.DumpSistemaToXLT(var f: textfile);
var
  kvar: integer;
  k, j: integer;
  ficha: TFichaViolacionPermitida;
{$IFNDEF SPXCONLOG}
  nom: string;
{$ENDIF}
begin
  writeln(f, 'cnt_varfijas:', #9, cnt_varfijas);
  writeln(f, 'cnt_RestriccionesRedundantes:', #9, cnt_RestriccionesRedundantes_);
  writeln(f, 'cnt_violacionesUsadas', #9, cnt_violacionesUsadas);
  writeln(f, 'violacionesPermitidas');
  writeln(f, 'violacionesPermitidas.Count= ', #9, violacionesPermitidas.Count);
  writeln(f, 'ires', #9, 'usada', #9, 'iViolacionAUsar', #9, 'nIvars', #9, 'ivars[]');

  for k := 0 to violacionesPermitidas.Count - 1 do
  begin
    ficha := violacionesPermitidas[k];
    Write(f, ficha.ires, #9, ficha.usada, #9, ficha.iViolacionAUsar,
      #9, length(ficha.ivars));
    for j := 0 to high(ficha.ivars) do
      Write(f, #9, ficha.ivars[j]);
    writeln(f);
  end;
{$IFDEF SPXCONLOG}
  writeln(f, '*****************************');
  Write(f, 'x: ');
  for kvar := 1 to nc - 1 do
    Write(f, #9, nombreVars[kvar]);
  writeln(f);

  Write(f, 'x_inf:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, x_inf.pv[kvar]);
  writeln(f);

  Write(f, 'x_sup:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, x_sup.pv[kvar]);
  writeln(f);

  Write(f, 'flg_x:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, flg_x[kvar]);
  writeln(f);

  Write(f, 'flg_y:');
  for kvar := 1 to nf - 1 do
    Write(f, #9, flg_y[kvar]);
  writeln(f);

  Write(f, 'top:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, top[kvar]);
  writeln(f);

  Write(f, 'left:');
  for kvar := 1 to nf - 1 do
    Write(f, #9, left[kvar]);
  writeln(f);

  writeln(f, '----------------------');
  writeln(f, 'sistema --------------');
  writeln(f, '......................');

  // encabezados de las columnas
  Write(f, '-');
  for j := 1 to nc - 1 do
    if top[j] < 0 then
      Write(f, #9, nombreVars[-top[j]])
    else
      Write(f, #9, nombreRest[top[j]]);
  writeln(f, #9, 'ti');

  // filas ecuaciones >= 0
  for k := 1 to nf - 1 do
  begin
    if left[k] > 0 then
      Write(f, nombreRest[left[k]])
    else
      Write(f, nombreVars[-left[k]]);
    for j := 1 to nc do
      Write(f, #9, e(k, j));

    if left[k] < 0 then
    begin
      Write(f, #9, '>= 0');
      if flg_x[-left[k]] <> 0 then
        Write(f, #9, ' <= ', FloatToStrF(x_sup.pv[-left[k]], ffFixed, 10, 3));
    end
    else if left[k] > 0 then
    begin
      if flg_y[k] <> 0 then
        Write(f, #9, '=0')
      //para que imprima un ' al principio y el excel no lo tome como un número
      else
        Write(f, #9, '>=0');
      Write(f, #9);
    end
    else if flg_x[-left[k]] = 0 then
      Write(f, #9);
    writeln(f, #9, k);
  end;
{$ELSE}
  writeln(f, '*****************************');
  Write(f, 'x: ');
  for kvar := 1 to nc - 1 do
  begin
    nom := fGetNombreVar(kvar);
    Write(f, #9, nom);
  end;
  writeln(f);

  Write(f, 'x_inf:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, x_inf.pv[kvar]);
  writeln(f);

  Write(f, 'x_sup:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, x_sup.pv[kvar]);
  writeln(f);

  Write(f, 'flg_x:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, flg_x[kvar]);
  writeln(f);

  Write(f, 'flg_y:');
  for kvar := 1 to nf - 1 do
    Write(f, #9, flg_y[kvar]);
  writeln(f);

  Write(f, 'top:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, top[kvar]);
  writeln(f);

  Write(f, 'left:');
  for kvar := 1 to nf - 1 do
    Write(f, #9, left[kvar]);
  writeln(f);

  writeln(f, '----------------------');
  writeln(f, 'sistema --------------');
  writeln(f, '......................');

  // encabezados de las columnas
  Write(f, '-');
  for j := 1 to nc - 1 do
    if top[j] < 0 then
    begin
      nom := fGetNombreVar(-top[j]);
      Write(f, #9, nom);
    end
    else
    begin
      nom := fGetNombreRes(top[j]);
      Write(f, #9, nom);
    end;
  writeln(f, #9, 'ti');

  // filas ecuaciones >= 0
  for k := 1 to nf - 1 do
  begin
    if left[k] > 0 then
    begin
      nom := fGetNombreRes(left[k]);
      Write(f, nom);
    end
    else
    begin
      nom := fGetNombreVar(-left[k]);
      Write(f, nom);
    end;
    for j := 1 to nc do
      Write(f, #9, e(k, j));

    if left[k] < 0 then
    begin
      Write(f, #9, '>= 0');
      if flg_x[-left[k]] <> 0 then
        Write(f, #9, ' <= ', FloatToStrF(x_sup.pv[-left[k]], ffFixed, 10, 3));
    end
    else if left[k] > 0 then
    begin
      if flg_y[k] <> 0 then
        Write(f, #9, '= 0')
      else
        Write(f, #9, '>=0');
      Write(f, #9);
    end
    else if flg_x[-left[k]] = 0 then
      Write(f, #9);
    writeln(f, #9, k);
  end;

{$ENDIF}
  // ultima fila (función a maximizar )
  Write(f, 'max:');
  for j := 1 to nc do
    Write(f, #9, e(nf, j));
  writeln(f);
  writeln(f);
  for j := 1 to nc do
    Write(f, #9, j);
  writeln(f);
end;

procedure TSimplex.DumpSistemaToXLT_(archi: string; InfoAdicional: string);
var
  f: textfile;
begin
{$IFDEF DBG_CONTAR_CNT_SIMPLEX}
  if cnt_debug >= minCnt_DebugParaDump then
  begin
{$ENDIF}
    Assign(f, archi);
    rewrite(f);
    writeln(f, 'InfoAdicional: ', InfoAdicional);
    DumpSistemaToXLT(f);
    closefile(f);
{$IFDEF DBG_CONTAR_CNT_SIMPLEX}
  end;
{$ENDIF}
end;

{$IFDEF SPXCONLOG}
procedure TSimplex.appendWriteXLT(const texto: string; var cnt_llamadas: integer;
  reescribir: boolean);
var
  f: textfile;
  kvar: integer;
  k, j: integer;
begin
  Assign(f, archi_spxconlog);
  if reescribir then
    rewrite(f)
  else
  begin
    {$I-}
    append(f);
    {$I+}
    if ioresult <> 0 then
      rewrite(f);
  end;

  writeln(f, '*****************************');
  writeln(f, texto, #9, 'cnt_llamadas:', cnt_llamadas);
  Inc(cnt_llamadas);
  Write(f, 'x: ');
  for kvar := 1 to nc - 1 do
    Write(f, #9, nombreVars[kvar]);
  writeln(f);

  Write(f, 'x_inf:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, x_inf.pv[kvar]: 8: 2);
  writeln(f);

  Write(f, 'x_sup:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, x_sup.pv[kvar]: 8: 2);
  writeln(f);

  Write(f, 'flg_x:');
  for kvar := 1 to nc - 1 do
    Write(f, #9, flg_x[kvar]);
  writeln(f);

  Write(f, 'flg_y:');
  for kvar := 1 to nf - 1 do
    Write(f, #9, flg_y[kvar]);
  writeln(f);

  writeln(f, '----------------------');
  writeln(f, 'sistema --------------');
  writeln(f, '......................');

  // encabezados de las columnas
  Write(f, '-');
  for j := 1 to nc - 1 do
    if top[j] < 0 then
      Write(f, #9, nombreVars[-top[j]])
    else
      Write(f, #9, nombreRest[top[j]]);
  writeln(f, #9, 'ti');

  // filas ecuaciones >= 0
  for k := 1 to nf - 1 do
  begin
    if left[k] > 0 then
      Write(f, nombreRest[left[k]])
    else
      Write(f, nombreVars[-left[k]]);
    for j := 1 to nc do
      Write(f, #9, e(k, j): 8: 2);
    Write(f, #9, '>= 0');
    if left[k] < 0 then
      if flg_x[-left[k]] <> 0 then
        Write(f, #9, ' <= ', x_sup.pv[-left[k]]: 8: 2);
    writeln(f);
  end;

  // ultima fila (función a maximizar )
  Write(f, 'max:');
  for j := 1 to nc do
    Write(f, #9, e(nf, j): 8: 2);
  writeln(f);

  closefile(f);
end;

procedure TSimplex.clearlog;
var
  f: textfile;
begin
  assignfile(f, archi_spxconlog);
  rewrite(f);
  closefile(f);
end;

procedure TSimplex.writelog(const s: string);
var
  f: textfile;
begin
  assignfile(f, archi_spxconlog);
{$I-}
  append(f);
{$I+}
  if ioresult <> 0 then
    rewrite(f);
  writeln(f, s);
  closefile(f);
{$IFDEF DBGMONSPX}
  dbgmonspx_notificar(s, 0, 0);
{$ENDIF}
end;

procedure TSimplex.set_nombreVar(ivar: integer; xnombre: string);
begin
  nombreVars[ivar] := xnombre;
end;

procedure TSimplex.set_nombreRest(irest: integer; xnombre: string);
begin
  nombreRest[irest] := xnombre;
end;

{$ENDIF}

function TSimplex.xval(ix: integer): NReal;
var
  k: integer;
  res: NReal;
begin
  k := iix[ix];
  if k > 0 then
  begin
    if flg_x[ix] >= 0 then
      res := 0
    else
      res := x_sup.pv[ix];
  end
  else
  begin
    if flg_x[ix] >= 0 then
      //      res:= e( -k, nc )
      res := pm[-k].pv[nc]
    else
      //      res:= x_sup.pv[ix] - e( -k, nc );
      res := x_sup.pv[ix] - pm[-k].pv[nc];
  end;

  if x_inf.pv[ix] <> 0 then
    res := res + x_inf.pv[ix];
  Result := res;
end;

function TSimplex.yval(iy: integer): NReal;
var
  k: integer;
  res: NReal;
begin
  k := iiy[iy];
  if k < cnt_RestriccionesRedundantes_ then
    res := 0
  else
    //    res:= e( k, nc );
    res := pm[k].pv[nc];
  Result := res;
end;

function TSimplex.xmult(ix: integer): NReal;
var
  k: integer;
  res: NReal;
begin
  k := iix[ix];
  if k > 0 then
    if flg_x[ix] >= 0 then
      res := pm[nf].pv[k]
    else
      res := -pm[nf].pv[k]  //rch@201408250739 le agrego el signo de menos. Me parece que faltaba.
  else
    res := 0;
  Result := res;
end;

function TSimplex.ymult(iy: integer): NReal;
var
  k: integer;
  res: NReal;
begin
  k := -iiy[iy];
  if k > 0 then
    if flg_y[iy] >= 0 then
      res := pm[nf].pv[k]
    else
      res := -pm[nf].pv[k]
  else
    res := 0;
  Result := res;
end;

function TSimplex.fval: NReal;
begin
  Result := pm[nf].pv[nc];
end;

procedure TSimplex.IntercambioColumnas(j1, j2: integer);
var
  k: integer;
  m: NReal;
begin
{$IFDEF SPXCONLOG}
  if dbg_on then
  begin
    sdbg := 'Intercambio columna: ' + IntToStr(j1);
    if top[j1] > 0 then
      sdbg := sdbg + 'y(' + nombreRest[top[j1]] + ')'
    else
      sdbg := sdbg + 'x(' + nombreVars[-top[j1]] + ')';

    sdbg := sdbg + ' con columna: ' + IntToStr(j2);

    if top[j2] > 0 then
      sdbg := sdbg + 'y(' + nombreRest[top[j2]] + ')'
    else
      sdbg := sdbg + 'x(' + nombreVars[-top[j2]] + ')';
  end;
{$ENDIF}
  //  for k:= 1 to nf do
  for k := cnt_RestriccionesRedundantes_ + 1 to nf do
  begin
    m := pm[k].pv[j1];
    pm[k].pv[j1] := pm[k].pv[j2];
    pm[k].pv[j2] := m;
  end;

  k := top[j1];
  top[j1] := top[j2];
  top[j2] := k;

  Actualizo_iitop(j1);
  Actualizo_iitop(j2);
{$IFDEF SPXCONLOG}
  if dbg_on then
    writelog(sdbg);
{$ENDIF}
end;

procedure TSimplex.FijarRestriccionIgualdad(kfila: integer);
begin
  Inc(cnt_igualdades);
  flg_y[kfila] := 2;
end;

procedure TSimplex.FijarVariables;
var
  kColumnas, mejorColumnaParaCambiarFila, kFor, kFilaAFijar: integer;
  mejorAkFilai: NReal;
  buscando: boolean;
  cnt_fijadas: integer;
  kPrimeraLibre: integer;

  procedure posicionarPrimeraLibre;
  begin
    while (cnt_fijadas < cnt_varfijas) and
      (((top[kPrimeraLibre] < 0) and (abs(flg_x[-top[kPrimeraLibre]]) = 2)) or
        ((top[kPrimeraLibre] > 0) and (abs(flg_y[top[kPrimeraLibre]]) = 2))) do
    begin
      if (top[kPrimeraLibre] < 0) then
        Inc(cnt_fijadas);
      Inc(cnt_columnasFijadas);
      Dec(kPrimeraLibre);
    end;
  end;

begin
  if (cnt_varfijas > 0) then
  begin
    cnt_fijadas := 0;
    kPrimeraLibre := nc - 1;
    kColumnas := 1;
    while (cnt_fijadas < cnt_varfijas) and (kColumnas <= kPrimeraLibre) do
    begin
      posicionarPrimeraLibre;
      //Busco en columnas
      if (cnt_fijadas < cnt_varfijas) and (kColumnas <= kPrimeraLibre) then
      begin
        buscando := True;
        while buscando and (kColumnas <= kPrimeraLibre) do
        begin
          if ((top[kColumnas]) < 0) and (abs(flg_x[-top[kColumnas]]) = 2) then
            //es una x fija
            buscando := False
          else
            Inc(kColumnas);
        end;
        if not buscando then
        begin
          intercambioColumnas(kColumnas, kPrimeraLibre);
          Dec(kPrimeraLibre);
          Inc(cnt_fijadas);
          Inc(cnt_columnasFijadas);
          Inc(kColumnas);
        end;
      end;
    end;

    //Se inicializa en la fila anterior a la ultima fijada
    kFilaAFijar := cnt_RestriccionesRedundantes_;
    while (cnt_fijadas < cnt_varfijas) do
    begin
      posicionarPrimeraLibre;
      if (cnt_fijadas < cnt_varfijas) then
      begin
{$IFDEF DBG}
        buscando := True;
{$ENDIF}
        //Busco en filas
        for kFor := kFilaAFijar + 1 to nf - 1 do
        begin
          if (left[kFor] < 0) and (abs(flg_x[-left[kFor]]) = 2) then
          begin
{$IFDEF DBG}
            buscando := False;
{$ENDIF}
            kFilaAFijar := kFor;
            break;
          end;
        end;
{$IFDEF DBG}
        if buscando then
          raise Exception.Create(
            'TSimplex.fijarVariables: cnt_fijadas < cnt_varfijas. cnt_debug= ' +
            IntToStr(cnt_debug));
{$ENDIF}
        mejorColumnaParaCambiarFila := 1;
        //        mejorAkFilai:= abs(e(kFilaAFijar, 1));
        mejorAkFilai := abs(pm[kFilaAFijar].pv[1]);
        for kColumnas := 2 to kPrimeraLibre do
        begin
          //          if abs(e(kFilaAFijar, kColumnas)) > mejorAkFilai then
          if abs(pm[kFilaAFijar].pv[kColumnas]) > mejorAkFilai then
          begin
            mejorColumnaParaCambiarFila := kColumnas;
            //            mejorAkFilai:= abs(e(kFilaAFijar, kColumnas));
            mejorAkFilai := abs(pm[kFilaAFijar].pv[kColumnas]);
          end;
        end;
        intercambiar(kFilaAFijar, mejorColumnaParaCambiarFila);
        if (mejorColumnaParaCambiarFila <> kPrimeraLibre) then
          IntercambioColumnas(mejorColumnaParaCambiarFila, kPrimeraLibre);
        Inc(cnt_fijadas);
        Inc(cnt_columnasFijadas);
        Dec(kPrimeraLibre);
      end;
    end;
  end;
end;



function TSimplex.ResolverIgualdades: integer;
var
  res: integer;
  cnt_acomodadas: integer;
  ifila, icolumna: integer;
  nIgualdadesResueltas, nIgualdadesAResolver: integer;
  iFilaLibre, iFilaAcomodando: integer;
  nCerosFilas, nCerosCols: TDAofNInt;
  fantasma: boolean;
begin

  cnt_acomodadas := cnt_columnasFijadas - cnt_varfijas;


  //Muevo las igualdades que esten en columnas al lado derecho junto con las FIJADAS
  icolumna := nc - cnt_columnasFijadas - 1;
  while (icolumna >= 1) and (cnt_acomodadas < cnt_Igualdades) do
  begin
    if (top[icolumna] > 0) and (abs(flg_y[top[icolumna]]) = 2) then
    begin
      if icolumna <> (nc - cnt_columnasFijadas - 1) then
        IntercambioColumnas(icolumna, nc - cnt_columnasFijadas - 1);
      Inc(cnt_acomodadas);
      Inc(cnt_columnasFijadas);
    end;
    Dec(icolumna);
  end;

  // rch@20130307.bugfix - begin ----------------------------
  // ahora reviso las que ya estén declaradas como redundantes a ver si hay
  // igualdades e incremento el contador de acomodadas.
  for iFilaAcomodando := 1 to cnt_RestriccionesRedundantes_ do
    if (left[iFilaAcomodando] > 0) and (abs(flg_y[iFilaAcomodando]) = 2) then
      //  Es una restricción  y es de igualdad
      Inc(cnt_acomodadas);

  // En el caso de estar resolviendo un MIPSimplex, en contador de redundantes puede venir
  // incrementado del problema PADRE y pueden haber restricciones de igualdad dentro de las
  // redundantes. Esto hacía que el  "while  cnt_acomodadas < cnt_Igualdades"
  // que está unas lineas abajo NO saliera por no alcanzar la condición.
  // rch@20130307.bugfix - end ----------------------------


  // ahora reordeno las igualdades y las que queden en filas las pongo al inicio
  iFilaLibre := cnt_RestriccionesRedundantes_ + 1;
  iFilaAcomodando := cnt_RestriccionesRedundantes_ + 1;

  while cnt_acomodadas < cnt_Igualdades do
  begin
    if (left[iFilaAcomodando] > 0) and (abs(flg_y[iFilaAcomodando]) = 2) then
    begin
      //  Es una restricción  y es de igualdad
      if iFilaLibre <> iFilaAcomodando then
        IntercambioFilas(iFilaAcomodando, iFilaLibre);
      Inc(cnt_acomodadas);
      Inc(iFilaLibre);
    end;
    Inc(iFilaAcomodando);
  end; //Al salir de aca iFilaLibre queda en la primer fila que no es de igualdad

  res := 1;

{$IFDEF SPXCONLOG}
  writelog('Resolviendo Igualdades+++++++++++++++++++++++++++++++++++++++++++');
{$ENDIF}

  nIgualdadesResueltas := 0;
  nIgualdadesAResolver := iFilaLibre - (cnt_RestriccionesRedundantes_ + 1);
  setLength(nCerosFilas, nf);
  setLength(nCerosCols, nc);
  while nIgualdadesResueltas < nIgualdadesAResolver do
  begin
    //    res:= pasoBuscarFactibleIgualdad( cnt_RestriccionesRedundantes + 1 + nIgualdadesResueltas );
    //    res:= pasoBuscarFactibleIgualdad2( cnt_RestriccionesRedundantes + 1 + nIgualdadesResueltas );
    //    res:= pasoBuscarFactibleIgualdad3( nIgualdadesAResolver - nIgualdadesResueltas);
    res := pasoBuscarFactibleIgualdad4(nIgualdadesAResolver -
      nIgualdadesResueltas, nCerosFilas, nCerosCols);
    if res = 1 then
    begin
      nIgualdadesResueltas := nIgualdadesResueltas + 1;
      Inc(cnt_columnasFijadas);
    end
    else
    begin
      ifila := cnt_RestriccionesRedundantes_ + 1;
      while (nIgualdadesResueltas < nIgualdadesAResolver) and
        filaEsFactible(ifila, fantasma) do
      begin
        if iFila <> cnt_RestriccionesRedundantes_ + 1 then
          IntercambioFilas(ifila, cnt_RestriccionesRedundantes_ + 1);

        cnt_RestriccionesRedundantes_ := cnt_RestriccionesRedundantes_ + 1;
        nIgualdadesResueltas := nIgualdadesResueltas + 1;
        ifila := ifila + 1;
      end;
      if (nIgualdadesResueltas < nIgualdadesAResolver) then
      begin
        mensajeDeError := 'PROBLEMA INFACTIBLE - Resolviendo igualdades.';
        res := -13;
        break;
      end
      else
        res := 1;
    end;

{    case res of
      1:  begin
          inc(ifila);
          inc(cnt_columnasFijadas);
          if cnt_columnasFijadas = nc - 1 then
          begin
          //Tengo todas las columnas fijas, si la solucion actual no es factible
          //entonces no hay solucion factible, si es factible es la mejor solucion
          //que puedo encontrar
            res:= 1;
            for ifila:= cnt_RestriccionesRedundantes + 1 to nf - 1 do
              if not filaEsFactible(ifila, fantasma) then
              begin
                mensajeDeError:= 'PROBLEMA INFACTIBLE - Resolviendo igualdades. No quedan columnas libres para mover.';
                res:= -13;
              end;
            break;
          end;
          end;
      0:  begin
          mensajeDeError:= 'PROBLEMA INFACTIBLE - Resolviendo igualdades.';
          result:= -10;
          setLength(nCerosFilas, 0);
          setLength(nCerosCols, 0);
          exit;
          end;
      -1: begin
          mensajeDeError:= 'NO encontramos pivote bueno - Resolviendo igualdades.';
          result:= -11;
          setLength(nCerosFilas, 0);
          setLength(nCerosCols, 0);
          exit;
          end;
      -2: begin
          mensajeDeError:= '???cnt_infactibles= 0 - Resolviendo igualdades.';
          result:= -12;
          setLength(nCerosFilas, 0);
          setLength(nCerosCols, 0);
          exit;
          end;
    else
      raise Exception.Create('OJOResolverIgualdades: pasoBuscarFactibleIgualdad retorno algo no espeardo, res:'+IntToStr(res ));
    end;}
  end;
  setLength(nCerosFilas, 0);
  setLength(nCerosCols, 0);
  Result := res;
end;

function TSimplex.pasoBuscarFactibleIgualdad4(nIgualdadesNoResueltas: integer;
  var nCerosFilas, nCerosCols: TDAofNInt): integer;
var
  iFila, iColumna: integer;
  columnasLibres: integer;
  maxVal, m: NReal;
  filaPiv, colPiv: integer;
begin
  //Tengo todas las igualdades en columnas al final y las igualdades en filas al
  //principio
  columnasLibres := nc - cnt_columnasFijadas - 1;
  for iColumna := 1 to columnasLibres do
    nCerosCols[iColumna] := 0;

  //Busco el máximo valor absoluto y cuento la cantidad de ceros en filas y columnas en la caja desde
  //cnt_RestriccionesRedundantes + 1 hasta cnt_RestriccionesRedundantes + nIgualdadesNoResueltas
  //la caja de las igualdades sin resolver
  maxVal := -MaxNReal;
  filaPiv := -1;
  colPiv := -1;
  for iFila := cnt_RestriccionesRedundantes_ + 1 to cnt_RestriccionesRedundantes_ +
    nIgualdadesNoResueltas do
  begin
    for iColumna := 1 to columnasLibres do
    begin
      m := abs(pm[iFila].pv[iColumna]);
      if m < AsumaCero then
      begin
        Inc(nCerosFilas[iFila]);
        Inc(nCerosCols[iColumna]);
      end
      else if m > maxVal then
      begin
        maxVal := m;
        filaPiv := iFila;
        colPiv := iColumna;
      end;
    end;
  end;

  //Termino de contar la cantidad de ceros en columnas con el resto de las
  //filas
  for iFila := cnt_RestriccionesRedundantes_ + nIgualdadesNoResueltas + 1 to nf - 1 do
  begin
    for iColumna := 1 to columnasLibres - 1 do
      if abs(pm[iFila].pv[iColumna]) < AsumaCero then
        Inc(nCerosCols[iColumna]);
  end;

  if maxVal > CasiCero_Simplex then
  begin
    for iFila := cnt_RestriccionesRedundantes_ + 1 to cnt_RestriccionesRedundantes_ +
      nIgualdadesNoResueltas do
    begin
      for iColumna := 1 to columnasLibres do
      begin
        if (abs(pm[iFila].pv[iColumna]) * 1000 >= maxVal) then
          //lo considero como posible pivote
        begin
          if nCerosFilas[filaPiv] + nCerosCols[colPiv] <
            nCerosFilas[iFila] + nCerosCols[iColumna] then
          begin
            filaPiv := iFila;
            colPiv := iColumna;
          end;
        end;
      end;
    end;
    //Muevo la fila a intercambiar al final asi me siguen quedando las que voy a
    //acomodar en bloque desde cnt_RestriccionesRedundantes
    if filaPiv <> cnt_RestriccionesRedundantes_ + nIgualdadesNoResueltas then
      IntercambioFilas(filaPiv, cnt_RestriccionesRedundantes_ + nIgualdadesNoResueltas);
    intercambiar(cnt_RestriccionesRedundantes_ + nIgualdadesNoResueltas, colPiv);
    if colPiv <> columnasLibres then
      IntercambioColumnas(colPiv, columnasLibres);
    Result := 1;
  end
  else
    Result := -1;
end;

procedure TSimplex.limpiar;
var
  k: integer;
begin
{$IFDEF GATILLOS_CAMBIOVAR}
  gatillos_no_procesados := True;
  cnt_Gatillos := 0;
{$ENDIF}
{$IFDEF SPXCONLOG}
  Self.dbg_on := True;
  if dbg_on then
  begin
    for k := 1 to nc - 1 do
      nombreVars[k] := 'x' + IntToStr(k);
    for k := 1 to nf - 1 do
      nombreRest[k] := 'y' + IntToStr(k);
  end;
{$ENDIF}
  cnt_paso := 0;
  mensajeDeError := '???';
  for k := 1 to nc - 1 do
  begin
    top[k] := -k;
    iix[k] := k;
    flg_x[k] := 0;
  end;
  for k := 1 to nf - 1 do
  begin
    left[k] := k;
    iiy[k] := k;
    flg_y[k] := 0;
  end;
  violacionesPermitidas.Limpiar;
  cnt_ViolacionesUsadas := 0;
  x_inf.Ceros;
  x_sup.Ceros; // creo que no es necesario

  cnt_RestrInfactibles := 0;
  cnt_igualdades := 0;
  cnt_varfijas := 0;
  cnt_columnasFijadas := 0;
  cnt_RestriccionesRedundantes_ := 0;

{$IFDEF CNT_COTAS}
  cnt_cotas_inf := 0;
  cnt_cotas_sup := 0;
{$ENDIF}
  self.Ceros;
end;

constructor TSimplex.Create_init(m, n: integer;
  xfGetNombreVar, xfGetNombreRes: TFuncNombre);
begin
  inherited Create_init(m, n);
  cnt_resolver := 0;
  cnt_RestriccionesRedundantes_ := 0;
  cnt_ViolacionesUsadas := 0;
  Self.violacionesPermitidas := TListaViolacionesPermitidasSimplex.Create;
{$IFDEF SPXCONLOG}
  setlength(nombreVars, 0);
  setlength(nombreRest, 0);
  Self.dbg_on := True;
  archi_spxconlog := 'simplex_spxconlog.xlt';
{$ENDIF}
{$IFDEF ESPARSA}
  x_inf := TSparseVectR.Create_Init(n - 1);
  x_sup := TSparseVectR.Create_Init(n - 1);
{$ELSE}
  x_inf := TVectR.Create_Init(n - 1);
  x_sup := TVectR.Create_Init(n - 1);
{$ENDIF}
  setlength(flg_x, n);
  setlength(flg_y, m);
  setlength(top, n + 1);
  setlength(left, m + 1);
  setlength(iix, n + 1);
  setlength(iiy, m + 1);
{$IFDEF GATILLOS_CAMBIOVAR}
  setlength(gatillos_CambioVar, n);
{$ENDIF}
{$IFDEF SPXCONLOG}
  if dbg_on then
  begin
    setlength(nombreVars, n);
    setlength(nombreRest, m);
  end;
{$ENDIF}
  if Assigned(xfGetNombreVar) then
    self.fGetNombreVar := xfGetNombreVar
  else
    self.fGetNombreVar := defaultGetNombreVar;
  if Assigned(xfGetNombreRes) then
    self.fGetNombreRes := xfGetNombreRes
  else
    self.fGetNombreRes := defaultGetNombreRes;
  limpiar;
end;

constructor TSimplex.Create_clone(spx: TSimplex);
begin
  inherited Create_Clone(spx);
  mensajeDeError := '';
  cnt_resolver := 0;
  cnt_paso := 0;
{$IFDEF SPXCONLOG}
  dbg_on := spx.dbg_on;
  sdbg := '';
  nombreVars := copy(spx.nombreVars);
  nombreRest := copy(spx.nombreRest);
{$ENDIF}
  top := copy(spx.top);
  left := copy(spx.left);
  iix := copy(spx.iix);
  iiy := copy(spx.iiy);

  cnt_RestriccionesRedundantes_ := spx.cnt_RestriccionesRedundantes_;
  cnt_RestrInfactibles := spx.cnt_RestrInfactibles;
  cnt_ViolacionesUsadas := spx.cnt_ViolacionesUsadas;
  cnt_igualdades := spx.cnt_igualdades;
  cnt_varfijas := spx.cnt_varfijas;

{$IFDEF CNT_COTAS}
  cnt_cotas_inf := spx.cnt_cotas_inf;
  cnt_cotas_sup := spx.cnt_cotas_sup;
{$ENDIF}

  violacionesPermitidas := spx.violacionesPermitidas;

{$IFDEF ESPARSA}
  x_inf := TSparseVectR.Create_clone(spx.x_inf);
  x_sup := TSparseVectR.Create_clone(spx.x_sup);
{$ELSE}
  x_inf := TVectR.Create_clone(spx.x_inf);
  x_sup := TVectR.Create_clone(spx.x_sup);
{$ENDIF}

  flg_x := copy(spx.flg_x);
  flg_y := copy(spx.flg_y);
{$IFDEF GATILLOS_CAMBIOVAR}
  cnt_Gatillos := spx.cnt_Gatillos;
  gatillos_CambioVar := copy(spx.gatillos_CambioVar);
  gatillos_no_procesados := spx.Gatillos_no_procesados;
{$ENDIF}
  self.fGetNombreVar := spx.fGetNombreVar;
  self.fGetNombreRes := spx.fGetNombreRes;
end;

procedure TSimplex.cota_inf_set(ivar: integer; vxinf: NReal);
var
  kfila, k: integer;
  old_cotainf: NReal;
begin
  old_cotainf := x_inf.pv[ivar];
  x_inf.pv[ivar] := vxinf;

  if (old_cotainf <> 0) then
{$IFDEF CNT_COTAS}
  begin
    // si ya había impuesto una cota y la estoy cambiando
    // deshago el cambio
    if vxinf = 0 then
      Dec(cnt_cotas_inf);
{$ENDIF}
    vxinf := vxinf - old_cotainf;
{$IFDEF CNT_COTAS}
  end
  else
  if vxinf <> 0 then
    Inc(cnt_cotas_inf);
{$ENDIF}

  // me fijo si ya fue fijada una cota superior para esta variable
  // la cambio para reflejar la nueva cota para la nueva variable
  if (flg_x[ivar] <> 0) then
    x_sup.pv[ivar] := x_sup.pv[ivar] - vxinf;

  if flg_x[ivar] >= 0 then //Es la variable directa
  begin
    k := iix[ivar];
    if k > 0 then //Estoy arriba y es la variable directa
      // hacemos el cambio de variables
      for kfila := cnt_RestriccionesRedundantes_ + 1 to nf do
        //        acum_e(kfila, nc, e(kfila, k) * vxinf)
        pm[kfila].pv[nc] := pm[kfila].pv[nc] + pm[kfila].pv[k] * vxinf
    else//Estoy abajo y es la variable directa
      //      acum_e(-k, nc, -vxinf);
      pm[-k].pv[nc] := pm[-k].pv[nc] - vxinf;
  end;
end;

procedure TSimplex.cota_sup_set(ivar: integer; vxsup: NReal);
var
  k, kfila: integer;
  deltaCotaSup: NReal;
begin
  vxsup := vxsup - x_inf.pv[ivar];
  if flg_x[ivar] = 0 then
  begin
{$IFDEF CNT_COTAS}
    Inc(cnt_cotas_sup);
{$ENDIF}
    flg_x[ivar] := 1;
    x_sup.pv[ivar] := vxsup;
  end
  else
  begin // ya tiene fijada cota sup la cambio
    deltaCotaSup := vxsup - x_sup.pv[ivar];
    x_sup.pv[ivar] := vxsup;
    if flg_x[ivar] < 0 then //Es la variable complementaria
    begin
      k := iix[ivar];
      if k > 0 then //Estoy arriba y es la variable complementaria
        // hacemos el cambio de variables
        for kfila := cnt_RestriccionesRedundantes_ + 1 to nf do
          //          acum_e( kfila, nc, -e(kfila, k) * deltaCotaSup)
          pm[kfila].pv[nc] := pm[kfila].pv[nc] - pm[kfila].pv[k] * deltaCotaSup
      else//Estoy abajo y es la variable complementaria
        //        acum_e( -k, nc, deltaCotaSup);
        pm[-k].pv[nc] := pm[-k].pv[nc] + deltaCotaSup;
    end;
  end;
end;

procedure TSimplex.FijarVariable(ivar: integer; valor: NReal);
begin
  if abs(flg_x[ivar]) <> 2 then
  begin
    cota_inf_set(ivar, valor);
    cota_sup_set(ivar, valor);
    if flg_x[ivar] >= 0 then
      flg_x[ivar] := 2
    else
      flg_x[ivar] := -2;
    Inc(cnt_varfijas);
  end
  else
    cota_inf_set(ivar, valor);
end;

{$IFDEF GATILLOS_CAMBIOVAR}
procedure TSimplex.GatillarCambioVarCotaSup(q: integer);
begin
  Inc(cnt_Gatillos);
  gatillos_CambioVar[cnt_Gatillos] := q;
end;

{$ENDIF}

procedure TSimplex.Free(borrarListaViolacionesPermitidas: boolean);
begin
  setlength(top, 0);
  setlength(left, 0);
  setlength(iix, 0);
  setlength(iiy, 0);

  x_inf.Free;
  x_sup.Free;
  setlength(flg_x, 0);
  setlength(flg_y, 0);
{$IFDEF GATILLOS_CAMBIOVAR}
  setlength(gatillos_cambioVar, 0);
{$ENDIF}

{$IFDEF SPXCONLOG}
  setlength(nombreVars, 0);
  setlength(nombreRest, 0);
{$ENDIF}
  if borrarListaViolacionesPermitidas then
    violacionesPermitidas.Free;
  inherited Free;
end;

{procedure TSimplex.combinax( kdest, korg, jini, jfin: integer; m :NReal );
var
  j: Integer;
begin
  if abs(m) > AsumaCero then
  begin
    for j:= jini to jfin do
      pm[kdest].pv[j]:= pm[kdest].pv[j] + m * pm[korg].pv[j];
  end;
end;}

procedure TSimplex.intercambiar(kfil, jcol: integer);
var
  m, piv, invPiv: NReal;
  k, j: integer;
begin
{$IFDEF SPXCONLOG}
  if dbg_on then
  begin
    sdbg := 'Intercambio fila: ' + IntToStr(kfil);
    if left[kfil] > 0 then
      sdbg := sdbg + 'y(' + nombreRest[left[kfil]] + ')'
    else
      sdbg := sdbg + 'x(' + nombreVars[-left[kfil]] + ')';

    sdbg := sdbg + ' con columna: ' + IntToStr(jcol);

    if top[jcol] > 0 then
      sdbg := sdbg + 'y(' + nombreRest[top[jcol]] + ')'
    else
      sdbg := sdbg + 'x(' + nombreVars[-top[jcol]] + ')';
  end;
{$ENDIF}

  //  piv:= e(kfil, jcol);
  piv := pm[kfil].pv[jcol];
{$IFDEF DBG}
  if abs(piv) < 1E-4 then
  begin
    writeln('TSimplex: Ojo, MejorPivote= ', piv);
    writeln('Intercambiando fila ' + getNombreFila(kfil) + ' con columna ' +
      getNombreCol(jcol));
  end;
{$ENDIF}
  invPiv := 1 / piv;

  //  for k:= 1 to kfil -1 do
  for k := cnt_RestriccionesRedundantes_ + 1 to kfil - 1 do
  begin
    m := -pm[k].pv[jcol] * invPiv;
    if abs(m) > AsumaCero then
    begin
      for j := 1 to jcol - 1 do
        pm[k].pv[j] := pm[k].pv[j] + m * pm[kfil].pv[j];
      pm[k].pv[jcol] := -m;
      for j := jcol + 1 to nc do
        pm[k].pv[j] := pm[k].pv[j] + m * pm[kfil].pv[j];
    end
    else
{$IFDEF IMPONGO_CEROS}
      pm[k].pv[jcol] := 0;
{$ELSE}
    pm[k].pv[jcol] := -m;
{$ENDIF}
    //    m:= -e(k, jcol) / piv;
    //    combinax( k, kfil, 1, jcol-1, m );
    //    pon_e( k, jcol, -m);
    //    combinax( k, kfil, jcol+1, nc, m );
  end;

  for k := kfil + 1 to nf do
  begin
    m := -pm[k].pv[jcol] * invPiv;
    if abs(m) > AsumaCero then
    begin
      for j := 1 to jcol - 1 do
        pm[k].pv[j] := pm[k].pv[j] + m * pm[kfil].pv[j];
      pm[k].pv[jcol] := -m;
      for j := jcol + 1 to nc do
        pm[k].pv[j] := pm[k].pv[j] + m * pm[kfil].pv[j];
    end
    else
{$IFDEF IMPONGO_CEROS}
      pm[k].pv[jcol] := 0;
{$ELSE}
    pm[k].pv[jcol] := -m;
{$ENDIF}
    //    m:= -e( k, jcol ) / piv;
    //    combinax( k, kfil, 1, jcol-1, m );
    //    pon_e( k, jcol, -m);
    //    combinax( k, kfil, jcol+1, nc, m );
  end;

  m := -invPiv;
  for j := 1 to jcol - 1 do
    pm[kfil].pv[j] := pm[kfil].pv[j] * m;
  //  pon_e(kfil, jcol, -m);
  pm[kfil].pv[jcol] := -m;
  for j := jcol + 1 to nc do
    pm[kfil].pv[j] := pm[kfil].pv[j] * m;

  k := top[jcol];
  top[jcol] := left[kfil];
  left[kfil] := k;

  Actualizo_iitop(jcol);
  Actualizo_iileft(kfil);

{$IFDEF SPXCONLOG}
  if dbg_on then
    writelog(sdbg);
{$ENDIF}
end;

(*
buscamos la columna que en la ultima fila (fila z) tenga el valor positivo mas grande
retorna el número de columna si lo encontro, -1 si son todos < 0
*)
function TSimplex.locate_zpos(kfila_z: integer): integer;
var
  j: integer;
  ires: integer;
  maxval: NReal;
begin
  ires := -1;
  maxval := CasiCero_Simplex; //1/4/2007 le agrego el CasiCero_simplex antes decía 0

  //rch 6/12/2006 le agrego restar las fijas e igualdades ??? ojo hay que pensar
  //rch y pa 070329 agregamos lo de maxval
  for j := 1 to nc - 1 - (cnt_columnasFijadas) do
    if pm[kfila_z].pv[j] > maxval then
    begin
      maxval := pm[kfila_z].pv[j];
      ires := j;
    end;
  Result := ires;
end;

function TSimplex.mejorpivote(q, kmax: integer; var filaFantasma, colFantasma: boolean;
  checkearFilaOpt: boolean): integer;
var
  i, p: integer;
  aiq, b_: NReal;
  a_max, b_max: NReal;
  ix: integer;
  xfantasma_Fila: boolean;
  esCandidato: boolean;
begin
  // inicializaciones no necesarias, solo para evitar el warning
  b_ := 0;
  xfantasma_Fila := False;
  b_max := 0;
  a_max := 1;

(*11/9/2006 le voy a agregar para que si la q corresponde a una x con manejo
de cota superior considere la existencia de una fila adicional correspondiente
a la cota superior.
Dicha fila tiene un -1 en la coluna q y el valor x_sup como término independiente

rch.30/3/2007 Agrego el manejo del CasiCero_Simplex

PA.21/06/2007 Le agrego que al buscar el mejorpivote para optimizar la fila
kmax chequee si esta es una variable con restriccion de cota superior y que el
pivote elegido no la viole*)
  ix := -top[q];
  if (ix > 0) and (flg_x[ix] <> 0) then
  begin  // en la columna q hay una x con manejo de cota superior
    colFantasma := True;
    p := q;
    //lo fijamos en -1 porque todas las restricciones fantasma tienen un -1 en
    //en el coeficiente de la variable y x_sup como termino independiente
    a_max := -1;
    b_max := x_sup.pv[ix];
  end
  else
  begin
    p := -1;
    colFantasma := False;
  end;

  filaFantasma := False;

  for i := cnt_RestriccionesRedundantes_ + 1 to kmax - 1 do
  begin
    //b(i) >= 0 para todo i / cnt_RestriccionesRedundantes < i < kmax-1
    //Buscamos la fila i que tenga el maximo b(i)/a(i,q) con a(i,q) < 0
    //    aiq:= e( i, q );
    aiq := pm[i].pv[q];
    if aiq > CasiCero_Simplex then
    begin
      ix := -left[i];
      if (ix > 0) and (flg_x[ix] <> 0) then
        //la variable en la fila i tiene cota superior, hay que probar con el cambio de variable
      begin
        aiq := -aiq;
        //        b_:= x_sup.pv[ix] - e(i, nc);
        b_ := x_sup.pv[ix] - pm[i].pv[nc];
        xfantasma_Fila := True;
        esCandidato := True;
      end
      else
        esCandidato := False;
    end
    else if aiq < -CasiCero_Simplex then
    begin
      //      b_:= e( i, nc );
      b_ := pm[i].pv[nc];
      esCandidato := True;
      xfantasma_Fila := False;
    end
    else
    begin
{$IFDEF IMPONGO_CEROS}
      //      pon_e(i, q, 0); // imponemos el cero para que no ande haciendo macanas
      pm[i].pv[q] := 0;
{$ENDIF}
      esCandidato := False;
    end;

    if esCandidato then //considero el coeficiente para elegir el pivote
    begin
      //aiq < 0 por como lo tomamos para esCandidato
      //bi >= 0 para todo i / cnt_RestriccionesRedundantes < i < kmax-1
      //El pivote es aquel que tenga mayor bi/aiq siempre que bi/aiq < 0 y aiq < 0
      //Ademas bi/aiq y b_max/a_max tienen el mismo signo =>
      //bi/aiq > b_max/a_max <=> bi * a_max > b_max * aiq
      if ((p < 0) or ((b_ * a_max) > (b_max * aiq))) then
      begin
        a_max := aiq;
        b_max := b_;
        p := i;
        filaFantasma := xfantasma_Fila;
        colFantasma := False;
      end;
    end;
  end;

  if checkearFilaOpt then
  begin
    ix := -left[kmax];
    if (ix > 0) and (flg_x[ix] <> 0) then
      //la fila a optimizar es una variable con manejo de cota superior
    begin
      {En la fila kmax el aiq es positivo, pues fue elegido con locate_zpos.}
      //      aiq:= -e(kmax, q);
      aiq := -pm[kmax].pv[q];
      assert(aiq < 0, 'aiq >= 0 en tsimplex.mejorpivote');
      //      b_:= x_sup.pv[ix] - e(kmax, nc);
      b_ := x_sup.pv[ix] - pm[kmax].pv[nc];
      if ((p < 0) or ((b_ * a_max) > (b_max * aiq))) then
      begin
        filaFantasma := True;
        colFantasma := False;
        p := kmax;
      end;
    end;
  end;
  Result := p;
end;

function TSimplex.pasoBuscarFactible: integer;
var
  pFilaOpt, ppiv, qpiv: integer;
  res: integer;
  rval: NReal;
  ix: integer;
  filaFantasma, colFantasma: boolean;
begin
  pFilaOpt := nf - cnt_RestrInfactibles;
  //  rval:= e(pFilaOpt, nc);
  rval := pm[pFilaOpt].pv[nc];

  (* OJO LE AGREGO ESTE CHEQUEO PARA PROBAR **)
  // si parece satisfecha verifico que no se esté violándo la  fantasma
  if (rval > 0) then
  begin
    if (left[pFilaOpt] < 0) then
    begin
      ix := -left[pFilaOpt];
      if (flg_x[ix] <> 0) and (rval > x_sup.pv[ix]) then
      begin
        if rval > x_sup.pv[ix] + CasiCero_Simplex then
        begin
          cambiar_borde_de_caja(pFilaOpt);
          //          rval:= e(pFilaOpt, nc );
          rval := pm[pFilaOpt].pv[nc];
        end
        else
        begin
          //          pon_e(pFilaOpt, nc, x_sup.pv[ix]);
          pm[pFilaOpt].pv[nc] := x_sup.pv[ix];
          rval := x_sup.pv[ix];
        end;
      end;
    end;
  end
  else if rval > -CasiCero_Simplex then
  begin
{$IFDEF IMPONGO_CEROS}
    //    pon_e(pFilaOpt, nc, 0);
    pm[pFilaOpt].pv[nc] := 0;
{$ENDIF}
    rval := 0;
  end;

  if (rval >= 0) then
  begin
    // ya es factible, probablemente se arregló con algún cambio anterior.
    decCnt_RestrInfactibles;
    res := 1;
  end
  else
  begin
(*Nos planteamos el problema de optimización con objetivo el
  valor de la restricción violada.*)
    if cnt_RestrInfactibles > 0 then
    begin
      qpiv := locate_zpos(pFilaOpt);
      if qpiv > 0 then
      begin
        ppiv := mejorpivote(qpiv, pFilaOpt, filaFantasma, colFantasma, True);
        if ppiv < 1 then
          res := -1 //ShowMessage('No encontre pivote bueno ');
        else
        begin
          if not colFantasma then
          begin
            intercambiar(ppiv, qpiv);
            if filaFantasma then
              cambio_var_cota_sup_en_columna(qpiv);
            //            if ( e( pFilaOpt, nc) >= 0 ) then
            if pm[pFilaOpt].pv[nc] >= 0 then
              decCnt_RestrInfactibles;
            res := 1;
          end
          else
          begin
            cambio_var_cota_sup_en_columna(ppiv);
            //           if ( e( pFilaOpt, nc) >= 0 ) then
            if pm[pFilaOpt].pv[nc] >= 0 then
              decCnt_RestrInfactibles;
            res := 1;
          end;
        end;
      end
      else
        res := 0; //  ShowMessage('No encontre z - positivo ' );
    end
    else
      res := -2;

    if res = -1 then
    begin
      (*
     Pruebo si soluciono la infactibildad con un intercambio
     de la infactible con una de las Activas.
      *)
      qpiv := locate_qOK(pFilaOpt, nc - cnt_columnasFijadas - 1, nc);
      if qpiv > 0 then
      begin
        intercambiar(pFilaOpt, qpiv);
        decCnt_RestrInfactibles;
        res := 1;
      end;
    end;
  end;

  Result := res;
end;

function TSimplex.cambio_var_cota_sup_en_columna(q: integer): boolean;
var
  ix: integer;
  res: boolean;
  kfil: integer;
  xsup: NReal;
begin
  res := False;
  ix := -top[q];
  if (ix > 0) and (flg_x[ix] <> 0) then // corresponde a una x con cota sup
  begin
    // cambio de variable en la misma columna
    flg_x[ix] := -flg_x[ix];
    xsup := x_sup.pv[ix];
    //  for kfil := 1 to nf do
    for kfil := cnt_RestriccionesRedundantes_ + 1 to nf do
    begin
      pm[kfil].pv[nc] := pm[kfil].pv[nc] + pm[kfil].pv[q] * xsup;
      pm[kfil].pv[q] := -pm[kfil].pv[q];
    end;
    res := True;

{$IFDEF SPXCONLOG}
    if dbg_on then
    begin
      sdbg := 'cambio_cota_sup_en_columna x' + IntToStr(q) + ': ' +
        nombreVars[ix] + ' flg_x: ' + flagXToString(-flg_x[ix]) +
        ' -> ' + flagXToString(flg_x[ix]);
      writelog(sdbg);
    end;
{$ENDIF}
  end;
  Result := res;
end;

(*
Esta función retorna true si la columna q soluciona la infactibilidad
de la fila p. Se supone que (jti) es la columna de los términos constantes
(generalmente la nc ) la dejamos como parámetro por si es necesario

El valor retornado apq, es e(p,q) y puede usarse para
elegir el q que devuelva el valor más grande para disminuir los
errores numéricos.

*)
function TSimplex.test_qOK(p, q, jti: integer; var apq: NReal): boolean;
var
  resOK: boolean;
  k: integer;
  alfa_p, akq: NReal;
  nuevo_ti: NReal;
  ix: integer;
begin
  resOK := True;
  //  apq:= e(p, q);
  apq := pm[p].pv[q];
  if (apq <= AsumaCero) then
    Result := False
  else
  begin
    //    alfa_p:= -e( p, jti ) / apq;
    alfa_p := -pm[p].pv[jti] / apq;
    ix := -top[q];
    if ix > 0 then // la col q es una x
      if flg_x[ix] <> 0 then  // tiene manejo de cotasup
        if alfa_p > x_sup.pv[ix] then
        begin // de intercambiar esta columna se violaría la cotas superior
          Result := False;
          exit;
        end;

    for k := cnt_RestriccionesRedundantes_ + 1 to p - 1 do
    begin
      //      akq:= e(k, q);
      akq := pm[k].pv[q];
      //      nuevo_ti:= e(k,jti) + akq * alfa_p;
      nuevo_ti := pm[k].pv[jti] + akq * alfa_p;
      if nuevo_ti < 0 then
      begin
        resOK := False;
        break;
      end
      else
      begin
        ix := -left[k];
        if (ix > 0) and (flg_x[ix] <> 0) then
          if nuevo_ti > x_sup.pv[ix] then
          begin
            resOK := False;
            break;
          end;
      end;
    end;

    Result := resOK;
  end;
end;

function TSimplex.locate_qOK(p, jhasta, jti: integer): integer;
var
  mejorq, q: integer;
  max_apq, apq: NReal;
begin
  mejorq := -1;
  max_apq := -1;
  for q := 1 to jhasta do
    if test_qOK(p, q, jti, apq) and ((mejorq < 0) or (apq > max_apq)) then
    begin
      mejorq := q;
      max_apq := apq;
    end;
  Result := mejorq;
end;

procedure TSimplex.cambiar_borde_de_caja(k_fila: integer);
var
  ix, k: integer;
begin
  (*
    Realizamos el cambio de variable x'= x_sup - x para que la restricción
    violada sea representada por x' >= 0
    Observar que para la nueva variable la restricción x >= 0 se transforma
    en x' <= x_sup. Es decir que la cota superior de x' es también x_sup.
  *)

  ix := -left[k_fila]; // se supone que esto da positivo, sino no es una x
  for k := 1 to nc do
    pm[k_fila].pv[k] := -pm[k_fila].pv[k];
  pm[k_fila].pv[nc] := pm[k_fila].pv[nc] + x_sup.pv[ix];
  flg_x[ix] := -flg_x[ix];

{$IFDEF SPXCONLOG}
  if dbg_on then
  begin
    sdbg := 'Cambiar_borde_de_caja(' + IntToStr(k_fila) + ') x: ' +
      nombreVars[ix] + ' flg_x: ' + flagXToString(-flg_x[ix]) + ' -> ' +
      flagXToString(flg_x[ix]);
    writelog(sdbg);
  end;
{$ENDIF}
end;

function TSimplex.darpaso: integer;
var
  ppiv, qpiv: integer;
  res: integer;
  filaFantasma, colFantasma: boolean;
{$IFDEF DBG}
  k_cota_sup_violada: integer;
{$ENDIF}
begin
  Inc(cnt_paso);
  qpiv := locate_zpos(nf);
  if qpiv > 0 then
  begin
    ppiv := mejorpivote(qpiv, nf, filaFantasma, colFantasma, False);
    if ppiv < 1 then
    begin
      Result := -1; //ShowMessage('No encontre pivote bueno ');
      exit;
    end;
    if not colFantasma then
    begin
      intercambiar(ppiv, qpiv);
      if filaFantasma then
        cambio_var_cota_sup_en_columna(qpiv);
      res := 1;
    end
    else
    begin
      cambio_var_cota_sup_en_columna(ppiv);
      res := 1;
    end;

{$IFDEF DBG}
    (*** ME PARECE QUE ESTO NO DEBE PASAR NUNCA PERO POR LAS DUDAS LO PONEMOS ***)
    k_cota_sup_violada := primer_cota_sup_violada;
    if k_cota_sup_violada > 0 then
    begin
{$IFDEF SPXCONLOG}
      writelog('DUMP VIOLO FACTIBILIDAD COTA SUPERIOR, kcota_sup_violada:' +
        IntToStr(k_cota_sup_violada));
      appendWriteXLT('Después del cambio', cnt_paso, False);
{$ENDIF}
      // invierto los cambios
      if not colFantasma then
      begin
        if filaFantasma then
          cambio_var_cota_sup_en_columna(qpiv);
        intercambiar(ppiv, qpiv);
{$IFDEF SPXCONLOG}
        writelog('---- sin el último cambio --- ( p: ' + IntToStr(
          ppiv) + ' q: ' + IntToStr(qpiv) + ' )');
        appendWriteXLT('Después del cambio', cnt_paso, False);
{$ENDIF}
        raise Exception.Create(
          'Se violó la factibilidad de una cota superior intercambiando la fila ' +
          IntToStr(ppiv) + ' con la columna ' + IntToStr(qpiv) +
          '; k_cota_sup_violada: ' + IntToStr(k_cota_sup_violada));
      end
      else
      begin
        cambio_var_cota_sup_en_columna(ppiv);
{$IFDEF SPXCONLOG}
        writelog('---- sin el último cambio --- ( p: ' + IntToStr(ppiv));
        appendWriteXLT('Después del cambio', cnt_paso, False);
{$ENDIF}
        raise Exception.Create(
          'Se violó la factibilidad de una cota superior cambiando el borde de caja de la columna'
          + IntToStr(ppiv) + '; k_cota_sup_violada: ' +
          IntToStr(k_cota_sup_violada) + '; cnt_debug= ' + IntToStr(cnt_debug));
      end;
      cambiar_borde_de_caja(k_cota_sup_violada);
      res := 2; // con esto indicamos que es posible que halla que rechequear
    end;
    (****************************************************************************)
{$ENDIF}//DBG
  end
  else
    res := 0; //  ShowMessage('No encontre z - positivo ' );

  Result := res;
end;

procedure TSimplex.Actualizo_iileft(k: integer);
begin
  // actualizo los indices iix e iiy
  if left[k] > 0 then
    iiy[left[k]] := k
  else
    iix[-left[k]] := -k;
end;

procedure TSimplex.Actualizo_iitop(k: integer);
begin
  // actualizo los indices iix e iiy
  if top[k] < 0 then
    iix[-top[k]] := k
  else
    iiy[top[k]] := -k;
end;

procedure TSimplex.IntercambioFilas(k1, k2: integer);
var
{$IFDEF ESPARSA}
  p: TSparseVectR;
{$ELSE}
  p: TVectR;
{$ENDIF}
  ks: integer;
begin
{$IFDEF SPXCONLOG}
  if dbg_on then
  begin
    sdbg := 'Intercambio fila: ' + IntToStr(k1);
    if left[k1] > 0 then
      sdbg := sdbg + 'y(' + nombreRest[left[k1]] + ')'
    else
      sdbg := sdbg + 'x(' + nombreVars[-left[k1]] + ')';

    sdbg := sdbg + ' con fila: ' + IntToStr(k2);

    if left[k2] > 0 then
      sdbg := sdbg + 'y(' + nombreRest[left[k2]] + ')'
    else
      sdbg := sdbg + 'x(' + nombreVars[-left[k2]] + ')';
  end;
{$ENDIF}

  p := pm[k1];
  pm[k1] := pm[k2];
  pm[k2] := p;

  ks := left[k1];
  left[k1] := left[k2];
  left[k2] := ks;

  Actualizo_iileft(k1);
  Actualizo_iileft(k2);

{$IFDEF SPXCONLOG}
  if dbg_on then
    writelog(sdbg);
{$ENDIF}
end;

function TSimplex.reordenarPorFactibilidad: integer;
var
  kfil: integer;
  rval: NReal;
  ix: integer;
begin
(*Primero recorremos las restricciones y
  si la restricción no está violada me fijo si corresponde a una variable
  con restricción de cota superior y si es así verificamos que tampoco esté
  violada la restricción fantasma, si la fantasma se viola hacemos el cambio
  de variable para volverla explícita *)
  for kfil := cnt_RestriccionesRedundantes_ + 1 to nf - 1 do
  begin
    //    rval:= e(kfil, nc);
    rval := pm[kfil].pv[nc];
    if (rval > 0) then
      //Si es = 0 no chequeo pues la fantasma no puede estar violada
    begin
      if (left[kfil] < 0) then
      begin
        ix := -left[kfil];
        if (flg_x[ix] <> 0) and (x_sup.pv[ix] < rval) then
          //Parece que violo la cota superior
        begin
{$IFDEF IMPONGO_CEROS}
          if (x_sup.pv[ix] + CasiCero_Simplex) < rval then
            //La viola realmente
            cambiar_borde_de_caja(kfil)
          else
            //La viola por errores númericos
            //            pon_e(kfil, nc, x_sup.pv[ix])
            pm[kfil].pv[nc] := x_sup.pv[ix];
{$ELSE}
          cambiar_borde_de_caja(kfil);
{$ENDIF}
        end;
      end;
    end
{$IFDEF IMPONGO_CEROS}
    else
    if rval > -CasiCero_Simplex then
      //        pon_e(kfil, nc, 0);
      pm[kfil].pv[nc] := 0;
{$ENDIF}
  end;

  // Ahora sabemos que las violadas están explícitas, movemos todas las
  //restricciones violadas al final
  kfil := cnt_RestriccionesRedundantes_ + 1;
  cnt_RestrInfactibles := 0;
  while (kfil < (nf - cnt_RestrInfactibles)) do
  begin
    //    rval:= e(kfil, nc);
    rval := pm[kfil].pv[nc];
    if rval < 0 then
    begin
      Inc(cnt_RestrInfactibles);
      //      while (e(nf-cnt_RestrInfactibles, nc ) < 0)
      while (pm[nf - cnt_RestrInfactibles].pv[nc] < 0) and
        (kfil < (nf - cnt_RestrInfactibles)) do
        Inc(cnt_RestrInfactibles);
      if kfil < (nf - cnt_RestrInfactibles) then
        IntercambioFilas(kfil, nf - cnt_RestrInfactibles);
    end;
    Inc(kfil);
  end;
  Result := cnt_RestrInfactibles;
end;

function TSimplex.resolver: integer;
label
  lbl_inicio, lbl_buscofact;
var
  res: integer;
{$IFDEF DBG}
  aux_dbg: integer;
{$ENDIF}
begin
  Inc(cnt_resolver);
  cnt_columnasFijadas := 0;


{$IFDEF DBG_CONTAR_CNT_SIMPLEX}
  Inc(cnt_debug);

  if (cnt_debug mod 10000) = 0 then
    writeln('cnt_debug= ', cnt_debug);
{$ENDIF}

{$IFDEF SPXCONLOG}
  appendWriteXLT('INICIO CntResolver: ' + IntToStr(cnt_resolver), cnt_paso, True);
{$ENDIF}
{$IFDEF GATILLOS_CAMBIOVAR}
  if (cnt_Gatillos > 0) and (gatillos_no_procesados) then
  begin
    for k := 1 to cnt_Gatillos do
      cambio_var_cota_sup_en_columna(gatillos_CambioVar[k]);
    gatillos_no_procesados := True;
  {$IFDEF SPXCONLOG}
    appendWriteXLT('GATILLOS_CAMBIOVAR Cnt_Gatillos: ' + IntToStr(cnt_Gatillos),
      cnt_paso, False);
  {$ENDIF}
  end;
{$ENDIF}
{$IFDEF SPXCONLOG}
  writelog('Fijando Variables++++++++++++++++++++++++++++++++++++++++++++++++');
{$ENDIF}
  // Fijamos las variables que se hayan declarado como constantes.

  FijarVariables;
{$IFDEF SPXCONLOG}
  writelog('Ordenando Igualdades+++++++++++++++++++++++++++++++++++++++++++++');
{$ENDIF}
  //system.writeln( cnt_resolver );
  if ResolverIgualdades <> 1 then
  begin
    mensajeDeError :=
      'PROBLEMA INFACTIBLE - No logré resolver las restricciones de igualdad.';
    Result := -31;
    exit;
  end;

{$IFDEF SPXCONLOG}
  appendWriteXLT('INICIO CntResolver: ' + IntToStr(cnt_resolver), cnt_paso, False);
{$ENDIF}

  lbl_inicio:

{$IFDEF SPXCONLOG}
    writelog('Reordenando por factibilidad+++++++++++++++++++++++++++++++++++++');
{$ENDIF}
  reordenarPorFactibilidad;

  lbl_buscofact:
{$IFDEF SPXCONLOG}
    writelog('Buscar Factible++++++++++++++++++++++++++++++++++++++++++++++++++');
{$ENDIF}
  res := 1;
  while cnt_RestrInfactibles > 0 do
  begin
{$IFDEF SPXCONLOG}
    writelog('BuscandoFactible: cnt_infactibles: ' + IntToStr(cnt_RestrInfactibles) +
      '; Fila Infactible: ' + getNombreFila(nf - cnt_RestrInfactibles));
{$ENDIF}
    res := pasoBuscarFactible;

(*
{$IFDEF SPXCONLOG}
    writelog('BuscandoFactible: res: '+IntToStr( res ) );
    appendWriteXLT( 'A', cnt_paso, false );
{$ENDIF}
*)
    case res of
      0: if cnt_RestrInfactibles > 0 then
        begin
          if intentarModificarCotaSupParaResolverRes then
            goto lbl_inicio;
          mensajeDeError := 'PROBLEMA INFACTIBLE - Buscando factibilidad';
          Result := -10;
{$IFDEF SPXCONLOG}
          writelog(mensajeDeError);
{$ENDIF}
          exit;
        end;
      -1:
      begin
        if intentarModificarCotaSupParaResolverRes then
          goto lbl_inicio;
        mensajeDeError := 'NO encontramos pivote bueno - Buscando Factibilidad';
        Result := -11;
{$IFDEF SPXCONLOG}
        writelog(mensajeDeError);
{$ENDIF}
        exit;
      end;
      -2:
      begin
        mensajeDeError := '???cnt_infactibles= 0 - Buscando Factibilidad';
        Result := -12;
{$IFDEF SPXCONLOG}
        writelog(mensajeDeError);
{$ENDIF}
        exit;
      end;
    end;
  end;

{$IFDEF SPXCONLOG}
  writelog('Maximizando por pasos++++++++++++++++++++++++++++++++++++++++++++');
{$ENDIF}

{$IFDEF DBG}
  aux_dbg := primerainfactible;
  if aux_dbg <> nf + 1 then
    raise Exception.Create(
      'TSimplex.Resolver: Hay una Fila Infactible al Momento de Maximizar Por Pasos. Kfila ='
      + IntToStr(aux_dbg) + '; cnt_debug= ' + IntToStr(cnt_debug));
{$ENDIF}

  while res = 1 do
  begin
(*
{$IFDEF SPXCONLOG}
    writelog('DarPaso: cnt_infactibles: '+IntToStr( cnt_infactibles ) );
{$ENDIF}
*)
    res := darpaso;
(*
{$IFDEF SPXCONLOG}
    writelog('DarPaso: res: '+IntToStr( res ) );
    appendWriteXLT( 'B', cnt_paso, false );
{$ENDIF}
*)
    case res of
      //    0: showmessage('FIN');
      -1:
      begin
        mensajeDeError := 'Error -- NO encontramos pivote bueno dando paso';
        Result := -21;
{$IFDEF SPXCONLOG}
{$IFDEF DBG_CONTAR_CNT_SIMPLEX}
        writelog('Error -- NO encontramos pivote bueno dando paso: cnt_dbug:' +
          IntToStr(cnt_debug));
{$ENDIF}
        appendWriteXLT('ERROR!, cnt_paso', cnt_paso, False);
{$ENDIF}
        exit;
      end;
    end;
  end;
  if res = 2 then
    goto lbl_inicio;
{$IFDEF SPXCONLOG}
  writelog('Finalizado+++++++++++++++++++++++++++++++++++++++++++++++++++++++');
{$ENDIF}
  Result := res;
end;

procedure TSimplex.set_entera(ivae, ivar: integer; CotaSup: integer);
begin
  raise Exception.Create('TSimplex.set_entera ES ABSTRACTA, NO DEBE LLAMARLA');
end;

procedure TSimplex.set_EnteraConAcople(ivae, ivar: integer; CotaSup: integer;
  ivarAcoplada, iresAcoplada: integer);
begin
  raise Exception.Create('TSimplex.set_EnteraConAcople ES ABSTRACTA, NO DEBE LLAMARLA');
end;

procedure TSimplex.set_EnteraConAcoples(ivae, ivar: integer; CotaSup: integer;
  lstAcoples: TListaAcoplesVEntera);
begin
  raise Exception.Create('TSimplex.set_EnteraConAcoples ES ABSTRACTA, NO DEBE LLAMARLA');
end;

procedure TSimplex.declararRestriccionRedundante(kres: integer);
var
  i, ires: integer;
  maxAbs: NReal;
  filaPiv: integer;
begin
  ires := iiy[kres];

  if ires < 0 then
  begin
    // La restricción está en una columna. Antes de declararla redundante
    // debemos conmutarla con una fila.
    // busca una fila con quien conmutar, las intercambia y sigue
    ires := -ires;
    maxAbs := 0;
    filaPiv := -1;
    for i := cnt_RestriccionesRedundantes_ + 1 to nf - 1 do
      if abs(pm[i].pv[ires]) > maxAbs then
      begin
        maxAbs := abs(pm[i].pv[ires]);
        filaPiv := i;
      end;

    Assert(filaPiv <> -1,
      'TSimplex.declararRestriccionRedundante: la restricción esta en una columna y no hay una fila con que pivotear');
    intercambiar(filaPiv, ires);
    ires := filaPiv;
  end;


{$IFDEF DBG}
  if ires <= cnt_RestriccionesRedundantes_ then
    raise Exception.Create('Esta restricción ya esta considerada redundante');
{$ENDIF}

  if ires > cnt_RestriccionesRedundantes_ + 1 then
    IntercambioFilas(ires, cnt_RestriccionesRedundantes_ + 1);

  Inc(cnt_RestriccionesRedundantes_);
end;

procedure TSimplex.permitirViolarBordeSupParaSatisfacerRestriccion(ires: integer;
  ivars: TDAofNInt);
var
  fichaNueva: TFichaViolacionPermitida;
begin
  fichaNueva := TFichaViolacionPermitida.Create(ires, ivars);
  violacionesPermitidas.Add(fichaNueva);
end;

procedure TSimplex.rearmarIndicesiiXiiY;
var
  k: integer;
begin
  for k := 1 to nc - 1 do
  begin
    if top[k] < 0 then //es una x
      iix[-top[k]] := k
    else //es una y
      iiy[top[k]] := -k;
  end;
  for k := 1 to nf - 1 do
  begin
    if left[k] < 0 then //es una x
      iix[-left[k]] := -k
    else //es una y
      iiy[left[k]] := k;
  end;
end;

//Revisa si puede decrementar la cantidad de restricciones infactibles y
//lo hace en caso de poder hacerlo
procedure TSimplex.decCnt_RestrInfactibles;
{$IFDEF DBG}
var
  i: integer;
  fantasma: boolean;
  infactibles: string;
{$ENDIF}
begin
  cnt_RestrInfactibles := cnt_RestrInfactibles - 1;
{$IFDEF DBG}
  //Si tengo una fila infactible en el rango de filas factibles hay un error
  infactibles := 'Filas Infactibles en el Rango de Factibles: ';
  for i := cnt_RestriccionesRedundantes_ + 1 to nf - 1 - cnt_RestrInfactibles do
    if not filaEsFactible(i, fantasma) then
      infactibles := infactibles + IntToStr(i) + ', ';
  if infactibles <> 'Filas Infactibles en el Rango de Factibles: ' then
    raise Exception.Create(
      'Decremente La Cantidad De Infactibles Sin Resolver Una Fila. cnt_debug=' +
      IntToStr(cnt_debug) + ', ' + infactibles);
{$ENDIF}
end;

//Indica si la restricción en kfila esta siendo cumplida
function TSimplex.filaEsFactible(kfila: integer; var fantasma: boolean): boolean;
var
  ix: integer;
begin
  //  if e(kfila, nc) < -CasiCero_Simplex then
  if pm[kfila].pv[nc] < -CasiCero_Simplex then
  begin
    //Si la fila es < 0
    fantasma := False;
    Result := False;
  end
  else if (left[kfila] < 0) then
  begin
    //Si rval es >= 0 reviso si es una variable con cota superior
    ix := -left[kfila];
    //    if (flg_x[ix] <> 0) and (e(kfila, nc) > (x_sup.pv[ix] + CasiCero_Simplex_CotaSup)) then
    if (flg_x[ix] <> 0) and (pm[kfila].pv[nc] > (x_sup.pv[ix] +
      CasiCero_Simplex_CotaSup)) then

    begin
      //Si violo la cota superior
      fantasma := True;
      Result := False;
    end
    //Sino
    else
    begin
      fantasma := False;
      Result := True;
    end;
  end
  else
  begin
    //Si es una y >= 0
    fantasma := False;
    Result := True;
  end;
end;

function TSimplex.defaultGetNombreVar(i: integer): string;
begin
  Result := 'Var' + IntToStr(i);
end;

function TSimplex.defaultGetNombreRes(i: integer): string;
begin
  Result := 'Res' + IntToStr(i);
end;

function TSimplex.getNombreFila(kfila: integer): string;
begin
  if left[kfila] < 0 then
  begin
    if Assigned(fGetNombreVar) then
      Result := fGetNombreVar(-left[kfila])
    else
{$IFDEF SPXCONLOG}
      Result := nombreVars[-left[kfila]];
{$ELSE}
    Result := 'x' + IntToStr(-left[kfila]);
{$ENDIF}
  end
  else
  begin
    if Assigned(fGetNombreRes) then
      Result := fGetNombreRes(left[kfila])
    else
{$IFDEF SPXCONLOG}
      Result := nombreRest[left[kfila]];
{$ELSE}
    Result := 'y' + IntToStr(left[kfila]);
{$ENDIF}
  end;
end;

function TSimplex.getNombreCol(kcol: integer): string;
begin
  if top[kcol] < 0 then
  begin
    if Assigned(fGetNombreVar) then
      Result := fGetNombreVar(-top[kcol])
    else
{$IFDEF SPXCONLOG}
      Result := nombreVars[-top[kcol]];
{$ELSE}
    Result := 'x' + IntToStr(-top[kcol]);
{$ENDIF}
  end
  else
  if Assigned(fGetNombreRes) then
    Result := fGetNombreRes(top[kcol])
  else
{$IFDEF SPXCONLOG}
    Result := nombreRest[top[kcol]];
{$ELSE}
  Result := 'y' + IntToStr(top[kcol]);
{$ENDIF}
end;

{$IFDEF SPXCONLOG}
function TSimplex.flagXToString(flagX: integer): string;
begin
  if flagX = 0 then
    Result := '(0) SinCotaSup'
  else if flagX = -1 then
    Result := '(-1) ConCotaSup_ConsiderandoInf'
  else if flagX = 1 then
    Result := '(1) ConCotaSup_ConsiderandoSup'
  else if flagX = 2 then
    Result := 'VarFija'
  else
    raise Exception.Create('TSimplex.flagXToString: flagX desconocida ' +
      IntToStr(flagX));
end;

function TSimplex.flagYToString(flagY: integer): string;
begin
  if flagY = 0 then
    Result := '(0) res >=0'
  else if flagY = 2 then
    Result := '(2) res = 0'
  else if flagY = -2 then
    Result := '(-2) -res = 0'
  else
    raise Exception.Create('TSimplex.flagYToString: flagY desconocida ' +
      IntToStr(flagY));
end;

{$ENDIF}

function TSimplex.intentarModificarCotaSupParaResolverRes: boolean;
var
  iy, ix, posActualX, i: integer;
  ficha: TFichaViolacionPermitida;
  deltax_sup: NReal;
  filaRestriccion, jcol: integer;
  buscando: boolean;
  minDelta, b, menos_a, ti_mas_axsup, alfa: NReal;
  minDeltaAsignado: boolean;
  fila_x, jPiv: integer;
begin
  filaRestriccion := nf - cnt_RestrInfactibles;
{$IFDEF SPXCONLOG}
  writelog('No puede resolver la restricción: ' + getnombreFila(filaRestriccion));
{$ENDIF}
  iy := left[filaRestriccion];
  if (iy > 0) then
  begin
    if violacionesPermitidas.sePuedeViolarCotaSupParaArreglar(iy, ficha) then
    begin  //La primer fila violada es una y, y se puede violar una cota para arreglarla
      ix := ficha.ivars[ficha.iViolacionAUsar];
      ficha.iViolacionAUsar := ficha.iViolacionAUsar + 1;
      if ficha.iViolacionAUsar = length(ficha.ivars) then
        ficha.iViolacionAUsar := 0;

      posActualX := iix[ix];
      if (posActualX > 0) then
      begin//La variable a la que se le puede modificar la cota esta en una columna
        {$IFDEF SPXCONLOG}
        writelog('Esta restricción tiene asociada la variable ' +
          getNombreCol(posActualX));
        {$ENDIF}
        if (flg_x[ix] = -1) then
        begin  //La variable esta valiendo su valor superior, ya se intento usarla para resolver la fila
          if not ficha.usada then
          begin
            ficha.usada := True;
            Inc(cnt_ViolacionesUsadas);
          end;

          (*
              y = ...........a*x..............+ti  >= 0; Si  < 0 => cambioCotaSup

          La retricción llega aquí entonces en la forma:
              y = ...........-a*x'............+ti + a * x_sup >= 0; Si  < 0 =>
          quiero  ti + a * (x_sup + deltax_sup) = 0 => deltax_sup = -(ti + a * x_sup)/a
          O lo que es lo mismo deltax_sup = (ti+a*x_sup) / (-a )
          *)
          deltax_sup := pm[filaRestriccion].pv[nc] /
            pm[filaRestriccion].pv[posActualX] * 1.015;
          for i := cnt_RestriccionesRedundantes_ + 1 to nf do
            pm[i].pv[nc] := pm[i].pv[nc] - pm[i].pv[posActualX] * deltax_sup;
          x_sup.pv[ix] := x_sup.pv[ix] + deltax_sup;
          {$IFDEF SPXCONLOG}
          writelog('Cambio x_sup[' + getNombreCol(iix[ix]) + '] a ' +
            FloatToStrF(x_sup.pv[ix], ffFixed, 10, 3));
          {$ENDIF}
          Result := True;
        end
        else
          raise Exception.Create('TSimplex.intentarModificarCotaSupParaResolverRes: ' +
            'la variable a la que se le va a intentar cambiar la cota ' +
            'superior aun no ha sido utilizada.'
                                 {$IFDEF DBG_CONTAR_CNT_SIMPLEX}
            + ' cnt_debug= ' + IntToStr(cnt_debug)
                                 {$ENDIF}
            + ' variable: ' + getNombreCol(posActualX));
      end
      else
      begin
        fila_x := -PosActualX;
        {$IFDEF SPXCONLOG}
        writelog('La variable a la que se le intenta cambiar la cota sup, está' +
          ' en la fila kRow= ' + IntToStr(fila_x) + ' ' + Self.GetNombreFila(fila_x));
        {$ENDIF}
        (* Si la variable que puedo usar para satisfacer la restricción
        está en una fila, verifico que la fila explícita sea la fantasma,
        si no lo es cambio-cota-sup en fila para volverla explícita,
        luego recorro todos los coeficientes de la fila (dentro de las columnas no fijadas)
        y calculo con cada uno el deltaCotaSup necesario para satisfacer la restricción.
        Luego aumento la cota superior en el menor de los incrementos necesarios
        y salgo con TRUE para que se vuelva a intentar solucionar el problema.
        *)

        if (flg_x[ix] > 0) then
          Self.cambiar_borde_de_caja(fila_x);

        minDelta := 0;
        minDeltaAsignado := False;
        jPiv := 0;

        alfa := pm[filaRestriccion].pv[nc]; // término independiente de la restricción
        for jCol := 1 to nc - 1 - Self.cnt_columnasFijadas do
        begin
          b := pm[filaRestriccion].pv[jCol];
          if abs(b) > 1E-8 then
          begin
            menos_a := pm[fila_x].pv[jCol];
            if abs(menos_a) > 1E-8 then
            begin
              ti_mas_axsup := pm[fila_x].pv[nc];
              deltax_sup := -alfa / b + ti_mas_axsup / menos_a;
              if deltax_sup > 0 then
              begin
                if minDeltaAsignado then
                begin
                  if deltax_sup < minDelta then
                  begin
                    minDelta := deltax_sup;
                    jPiv := jCol;
                  end;
                end
                else
                begin
                  minDelta := deltax_sup;
                  minDeltaAsignado := True;
                  jPiv := jCol;
                end;
              end;
            end;
          end;
        end;

        if minDeltaAsignado then
        begin
          pm[fila_x].pv[nc] :=
            pm[fila_x].pv[nc] - pm[fila_x].pv[jPiv] * minDelta * 1.015;
          x_sup.pv[ix] := x_sup.pv[ix] + minDelta * 1.015;

          if not ficha.usada then
          begin
            ficha.usada := True;
            Inc(cnt_ViolacionesUsadas);
          end;
          Result := True;
        end
        else
          raise Exception.Create(
            'TSimplex.intentarModificarCotaSupParaResolverRes: ' +
            'la variable a la que se le va a intentar cambiar la cota ' +
            'superior esta en una fila. kRow= ' + IntToStr(fila_x) +
            ' ' + Self.GetNombreFila(fila_x) + '; x_sup= ' +
            FloatToStrF(x_sup.pv[ix], ffFixed, 10, 3) + '; ti= ' +
            FloatToStrF(pm[fila_x].pv[nc], ffFixed, 10, 3)
               {$IFDEF DBG_CONTAR_CNT_SIMPLEX}
            + '; cnt_debug= ' + IntToStr(cnt_debug)
               {$ENDIF}
            + ' NO PUDE ENCONTRAR COMO ARREGLARLO!');
      end;
    end
    else
    begin
      {$IFDEF SPXCONLOG}
      writelog('No puedo modificar ninguna cota para arreglarla');
      {$ENDIF}
      Result := False;
    end;
  end
  else
  begin//La primer fila violada es una variable
    {$IFDEF SPXCONLOG}
    writelog('Es una x intento ver si hay (y) con la que conmutar.');
    {$ENDIF}
    buscando := True;
    for jcol := 1 to nc - self.cnt_columnasFijadas - 1 do
    begin
      if (abs(pm[filaRestriccion].pv[jcol]) > 1.0E-4) and (top[jcol] > 0) then
        // es una y
        (* and(violacionesPermitidas.sePuedeViolarCotaSupParaArreglar( top[jcol], ficha)) *)
      begin
        {$IFDEF SPXCONLOG}
        writelog('Encontré la y: ' + Self.getNombreCol(jcol) +
          ' ... intercambio y reintento');
        {$ENDIF}
        buscando := False;
        Self.intercambiar(filaRestriccion, jcol);
        break;
      end;
    end;
    Result := not buscando;
  end;
end;

procedure ejemplo;
var
  i: integer;
  spx: TSimplex;
begin
  {
  min z = x1 + 3x2 + 2x3
  s.a.
    x1 + x2 + x3 >= 10.5
    x1 + x2 = 5.3
    x1 - x3 <= 2.9
    0 <= x1 <= 12, -6 <= x2 <= 6, -5 <= x3 <= 5

  =>

  max -z = -x1 -3x2 -2x3
  s.a.
    x1 + x2 + x3 -10.5 >= 0
    x1 + x2 - 5.3 = 0
    -x1 + x3 + 2.9 >= 0
    0 <= x1 <= 12, -6 <= x2 <= 6, -5 <= x3 <= 5
  }

  //Creamos un simplex vacío cuya matriz M tendrá:
  //3 restricciones + la función objetivo
  //3 variables + los términos independientes
  spx := TSimplex.Create_init(4, 4, nil, nil);

  //Cargamos la fila 1, pon_e(k, j, x) hace Mkj:= x
  spx.pon_e(1, 1, 1);
  spx.pon_e(1, 2, 1);
  spx.pon_e(1, 3, 1);
  spx.pon_e(1, spx.nc, -10.5);

  //Cargamos la fila 2 y la declaramos como de igualdad
  spx.pon_e(2, 1, 1);
  spx.pon_e(2, 2, 1);
  spx.pon_e(2, 3, 0);
  spx.pon_e(2, spx.nc, -5.3);
  spx.FijarRestriccionIgualdad(2);

  //Cargamos la fila 3
  spx.pon_e(3, 1, -1);
  spx.pon_e(3, 2, 0);
  spx.pon_e(3, 3, 1);
  spx.pon_e(3, spx.nc, 2.9);

  //Cargamos la fila objetivo z
  spx.pon_e(spx.nf, 1, -1);
  spx.pon_e(spx.nf, 2, -3);
  spx.pon_e(spx.nf, 3, -2);

  //cota_inf_set(i, x) fija la cota inferior de la variable en la
  //posición i a x, sota_sup_set hace lo propio con la cota superior
  //Cotas inferior y superior de x1
  spx.cota_inf_set(1, 0);
  spx.cota_sup_set(1, 12);

  //Cotas inferior y superior de x2
  spx.cota_inf_set(2, -6);
  spx.cota_sup_set(2, 6);

  //Cotas inferior y superior de x3
  spx.cota_inf_set(3, -5);
  spx.cota_sup_set(3, 5);

  //Vuelco el simplex al archivo 'ProblemaEjemplo.xlt' para verificar
  //que el problema armado sea el que quería
  spx.DumpSistemaToXLT_('ProblemaEjemplo.xlt', '');

  //intento resolver
  if spx.resolver = 0 then
  begin
    //ok, encontró solución
    Writeln('Solución óptima encontrada:');
    //spx.fval obtiene el valor de z
    Writeln('z= ', FloatToStrF(-spx.fval, ffGeneral, 8, 4));
    Writeln;
    for i := 1 to 3 do
      //spx.xval(i) obtiene el valor de la variable i
      Writeln(#9, spx.fGetNombreVar(i), '= ', FloatToStrF(spx.xval(i), ffGeneral, 8, 3));
    Writeln;
    for i := 1 to 3 do
      //spx.yval(i) obtiene el valor de la restriccion i
      Writeln(#9, spx.fGetNombreRes(i), '= ', FloatToStrF(spx.yval(i), ffGeneral, 8, 3));
    Writeln('Presione <Enter> para continuar');
    Readln;
  end
  else
    //Error, lanzamos la excepción
    raise Exception.Create('Error resolviendo simplex: ' + spx.mensajeDeError);

  //Liberamos la memoria usada por el objeto
  spx.Free(True);
end;

{$IFDEF DBG}
function TSimplex.primerainfactible: integer;
var
  k, ix: integer;
  ti: NReal;
  res: integer;
begin
  res := nf + 1;
  for k := cnt_RestriccionesRedundantes_ + 1 to nf - 1 do
  begin
    //    ti:= e(k, nc);
    ti := pm[k].pv[nc];
    if ti < -CasiCero_Simplex then
      //ti.....-CasiCero......0......
    begin
      res := k;
      break;
    end
{$IFDEF IMPONGO_CEROS}
    else if ti < 0 then
      //.....-CasiCero.....ti....0......
      //      pon_e(k, nc, 0)
      pm[k].pv[nc] := 0
{$ENDIF}
    else if (left[k] < 0) then
    begin
      ix := -left[k];
      if (flg_x[ix] <> 0) then
        if ti > (x_sup.pv[ix] + CasiCero_Simplex_CotaSup) then
          //.......xsup.........xsup+CasiCeroCotaSup......ti......
        begin
          res := -k;
          break;
        end
{$IFDEF IMPONGO_CEROS}
        else if ti > x_sup.pv[ix] then
          //.......xsup.........ti.......xsup+CasiCeroCotaSup.........
          //          pon_e(k, nc, x_sup.pv[ix]);
          pm[k].pv[nc] := x_sup.pv[ix];
{$ENDIF}
    end;
  end;
  Result := res;
end;

function TSimplex.primer_cota_sup_violada: integer;
var
  ix: integer;
  k: integer;
  buscando: boolean;
begin
  k := cnt_RestriccionesRedundantes_ + 1;
  buscando := True;
  while (k < (nf - 1)) and buscando do
  begin
    if left[k] < 0 then // es una x que fue puesta como fila
    begin
      ix := -left[k];
      if flg_x[ix] <> 0 then // hay cota sup verifico
        //        if e(k, nc) > (x_sup.pv[ix] + CasiCero_Simplex_CotaSup) then
        if pm[k].pv[nc] > (x_sup.pv[ix] + CasiCero_Simplex_CotaSup) then
          buscando := False
{$IFDEF IMPONGO_CEROS}
        //        else if e(k, nc) > x_sup.pv[ix] then
        else if pm[k].pv[nc] > x_sup.pv[ix] then
          //          pon_e(k, nc, x_sup.pv[ix]);
          pm[k].pv[nc] := x_sup.pv[ix];
{$ENDIF}
    end;
    if buscando then
      Inc(k);
  end;
  if buscando then
    Result := -1
  else
    Result := k;
end;

{$ENDIF}

{function TSimplex.locate_maxabs( p, jmax: integer ): integer;
var
  maxabs: NReal;
  j, jdelmax: integer;
begin
  maxabs:= abs(pm[p].pv[1]);
  jdelmax:= 1;
  for j:= 2 to jmax do
  begin
    if abs(pm[p].pv[j]) > maxabs then
    begin
      maxabs:= abs(pm[p].pv[j]);
      jdelmax:= j;
    end;
  end;
  result:= jdelmax;
end;}

(*
procedure TSimplex.FijarNIgualdades( cnt_Igualdades: integer );
begin
  if cnt_igualdades > (nf-1) then
    raise Exception.Create('Intentó fijar la cantidad de igualdades mayor al número total de restricciones.');
  Self.cnt_igualdades:= cnt_Igualdades;
end;
  *)

{function TSimplex.pasoBuscarFactibleIgualdad( ifila: integer ): integer;
var
  p, q: integer;
  rval: NReal;
  ultimaColumnaAConsiderar: integer;
  j: integer;
begin
// rch. 070723- pongo que busque la columna de mayor abs y haga el intercambio
// y comento lo que había, REVISAR!!!!!!!!!!!!
  ultimaColumnaAConsiderar:= nc - cnt_columnasFijadas - 1;
  p:= ifila;
//  rval:= abs( e(p, 1 ) );
  rval:= abs(pm[p].pv[1]);
  q:= 1;
  for j:= 2 to ultimaColumnaAConsiderar do
//    if abs( e(p, j ) ) > rval then
    if abs(pm[p].pv[j]) > rval then
    begin
//      rval:= abs(e(p,j));
      rval:= abs(pm[p].pv[j]);
      q:= j;
    end;

  if rval > CasiCero_Simplex then
  begin
    intercambiar( p, q );
    if q < ultimaColumnaAConsiderar then
      IntercambioColumnas( q, ultimaColumnaAConsiderar );
    result:= 1;
  end
  else
  begin
    result:= -1;
  end;
end;

(********** ESTO ES LO QUE HABÍA ANTES--- POR LAS DUDAS MIRAR UN FUENTE ANTERIOR
  rval:=e (ifila, nc);
  if ( rval > 0 ) then // le cambiamos el signo
  begin
    fila(ifila).PorReal(-1 );
    flg_y[ left[ifila] ]:= - flg_y[left[ifila]];
  end;

//   Primero probamos si solucionamos la infactibildad con un intercambio
//   de la infactible con una de las Activas.

lbl_repetirAnormalidadDetectada:

  p:= ifila;
  ultimaColumnaAConsiderar:= nc - cnt_columnasFijadas - 1;
  q:= locate_qOK( p, ultimaColumnaAConsiderar, nc );
  if q > 0 then
  begin
    intercambiar( p, q );
    if q < ultimaColumnaAConsiderar then
      IntercambioColumnas( q, ultimaColumnaAConsiderar );
    result:= 1;
    exit;
  end
  else
    result:= -1;
  end;


//  Si no se solucionó cambiando la misma fila infactible,
//  nos planteamos el problema de optimización con objetivo el
//  valor de la restricción violada.

  q:= locate_zpos(ifila, 1);
  if q > 0 then
  begin
    p:= mejorpivote( q, ifila, filaFantasma, colFantasma, true );
    if p < 1 then
    begin
      result:= -1; //ShowMessage('No encontre pivote bueno ');
      exit
    end;
    if not colFantasma then
    begin
      intercambiar( p, q );
      if filaFantasma then cambio_var_cota_sup_en_columna( q );
      res:= 1;
    end
    else
    begin
      cambio_var_cota_sup_en_columna( p );
      res:= 1;
    end;
  end
  else
    res:= 0; //  ShowMessage('No encontre z - positivo ' );

  result:= res;
end;
***************)}

{function TSimplex.pasoBuscarFactibleIgualdad3( nIgualdadesNoResueltas: integer ): integer;
var
  iFila, iColumna: Integer;
  columnasLibres: Integer;
  maxVal: NReal;
  filaPiv, colPiv: Integer;
begin
 columnasLibres:= nc - cnt_columnasFijadas-1;

  maxVal:= -MaxNReal; filaPiv:= -1; colPiv:= -1;
  for iFila:= cnt_RestriccionesRedundantes + 1 to cnt_RestriccionesRedundantes + nIgualdadesNoResueltas do
  begin
    for iColumna:= 1 to columnasLibres -1 do
    begin
      if abs(pm[iFila].pv[iColumna]) > maxVal then
      begin
        maxVal:= abs(pm[iFila].pv[iColumna]);
        filaPiv:= iFila;
        colPiv:= iColumna;
      end;
    end;
  end;

  if maxVal > CasiCero_Simplex then
  begin
    //Muevo la fila a intercambiar al final asi me siguen quedando las que voy a
    //acomodar en bloque desde cnt_RestriccionesRedundantes
    if filaPiv <> cnt_RestriccionesRedundantes + nIgualdadesNoResueltas then
      IntercambioFilas(filaPiv, cnt_RestriccionesRedundantes + nIgualdadesNoResueltas);
    intercambiar(cnt_RestriccionesRedundantes + nIgualdadesNoResueltas, colPiv);
    if colPiv <> columnasLibres then
      IntercambioColumnas(colPiv, columnasLibres);
    result:= 1;
  end
  else
    result:= -1;
end;}

initialization
{$IFDEF DBG_CONTAR_CNT_SIMPLEX}
  cnt_debug := 0;
  minCnt_DebugParaDump := 0;
{$ENDIF}
{$IFDEF DBGMONSPX}
  dbgmonspx_hwinMonitor := 0;
{$ENDIF}



end.
