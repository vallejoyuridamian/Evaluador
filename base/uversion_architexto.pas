unit uversion_architexto;

{$mode delphi}

interface

uses
  Classes, SysUtils;


(*20080713-rch
Agrego la constante VERSION_ArchiTexto. La idea es que al guardar un
archivo se escriba el número de version de forma que al leerlo podamos
saber con qué número de versión fue escrito.
Cada vez que realicemos un cambio de una clase que implique una transformación
debemos cambiar el núermo de versión y enseñarle a la clase en cuestión que
si el número de versión de un archivo que se está leyendo es inferior al nuevo
número debe leer de la forma antigua y luego aplicar las transformaciones que
correspondan. Al escribir debe escribir el objeto y transformado.
*)


const
  VERSION_ArchiTexto = 156;// mc_ld@20170917 agrego factor de filtracion que se eroga
  // checkbox para indicar si se ejecuta o no SimRes3 en cada escenario
  // VERSION_ArchiTexto = 155;// rch@20170805 agrego
  // checkbox para indicar si se ejecuta o no SimRes3 en cada escenario

//  VERSION_ArchiTexto = 154;// rch@20170805 agrego modo_Ejecucion en la sala
  // para permitir desde el editor indicar que se ejecuten todos los escenarios
  // activos.

//  VERSION_ArchiTexto = 153;// rch@20170629 cambio la definición de las plantas de paneles
//VERSION_ArchiTexto = 151; // Curso SimSEE2017 agregamos Condicion Central Hidro en arcos.
// VERSION_ArchiTexto = 150; // Curso SimSEE2017 agregamos Restriccion arcos gemelos.

// para que en lugar de ingresar el area del TOTAL se ingrese la PMax_100_W_m2 de cada múdulo
// y la PMax_Inversor de cada modulo
// VERSION_ArchiTexto = 149; // rch@20170309 agrego pagoPorDisponibilidad y Unidades en BancoBat
// VERSION_ArchiTexto = 148; // rch@201702051013  se agrega persistencia de variable husoHorario_UTC de globs
// VERSION_ArchiTexto = 147; // rch@201612091709
// Comienzo Migración a TCosa_RecLnk con lo cual los CreateReadFromText pueden tener
// que quedar los viejos (por ej. en TFichasLPD por el tema de la periodicidad)

// VERSION_ArchiTexto = 146; // rch@201612161629
// Agrego variable flg_IncluirPagosPotenciaYEnergiaEn_CF en las Salas para
// que se pueda controlar si incluye o no los pagos por disponibilidad y por
// energía en la función de Costo Futuro. Si la versión es anterior carga TRUE
// para reproducir el comportamiento anterior.

// VERSION_ArchiTexto = 145; // rch@201612061339
// rch: Agrego flg_usar_enganche_mapeo y enganche_mapeo_
// Agrego parámetros en PrintCronVar para indicar R, Octave o Matlab
// y parámetros flg_ejecutar y flg_quit_al_final para controlar
// la ejecución automática y qué sucede luego de ejecutar.

// VERSION_ArchiTexto = 144; // fpalacio@201610141415
//JFP: Agrego a uhidrconembalse Erogado Minimo con posibilidad de fallar.

//VERSION_ArchiTexto = 143; // fbarreto@201606011200

//VERSION_ArchiTexto = 142; // fbarreto@201511261008

//VERSION_ArchiTexto = 141; // JFP @201502121151
//Actualizo control de crecida por cota en THidroConEmbalseBinacional y editor de ficha según THidroConEmbalse.

//VERSION_ArchiTexto = 140; // JFP @201511251659
//Cambio a que las compras de Argentina en THidroConEmbalseBinacional se puedan hacer desde el actor
//y no desde la ficha como se hizo inicialmente.

//VERSION_ArchiTexto = 140; // JFP @201511201722
//Le agrego a TFichaHidroConEmbalseBinacional la opción de tomar las compras de Argentina
//desde una fuente. Hasta ahora solo se podían ingresar valores para cada hora de cada dia de la semana.

//VERSION_ArchiTexto = 139; // rch@201511081616
// Agrego posibilidad de hacer que los arcos sean condicionales según
// el valor de una fuente.


//VERSION_ArchiTexto = 138; // JFP, rch @201511041105
// Cambiamos comportamiento por default del pasaje de versiones anteriores a la 136
// activando por defecto el control de crecida.

// VERSION_ArchiTexto = 137; // JFP@201510201556
// Se agregan a las fichas de uhidroconembalse, en el control de crecida, 1 pto más para la curva (cota, erogado mínimo). Dicho pto
// corresponde a un valor intermedio de la curva de vertidos de la central.

//VERSION_ArchiTexto = 136; // JFP@201509231217
//Agregué en las fichas de uhidroConEmbalseBinacional un casillero para especificar el turbinado mínimo de Uruguay.
//Por lo general se programa la semana asumiendo que las compras horarias de UY son al menos las correspondientes
//a la potencia que se extrae de 300 m3/s (110 MW aprox) si la central regula frecuencia. Si no regula son 70 MW minimos
//a comprar por UY (aprox 190 m3/s).

//VERSION_ArchiTexto = 135; // JFP@201509151555
//Agregué en las fichas de uhidroConEmbalseBinacional los parámetros de la curva de remanso y erogado para cota máxima de control de crecida (QE_ControlDeCrecidaAPleno).

// VERSION_ArchiTexto = 134; // df,fb@201508271420
// Los pronosticos manejan diferentes guias de pronosticos, a las cuales se
// le asignan probabilidades en funcion de la confianza del mismo

//VERSION_ArchiTexto = 133; // df,fb@201508241122
// Se le agrega al actor THidroConEmbalse la posibilidad de introducirle error
// a la cota inicial.

//VERSION_ArchiTexto = 132; // rch@201505142046
// Felipe agrega flg_ValorAguaExacto_hObjetivo en TFichaHidroConEmbalse


//  VERSION_ArchiTexto = 131; // rch@201505121851
// agrego flg_ReservaRotante en globs para proyecto de Michael y Facundo.


//  VERSION_ArchiTexto = 130; // rch@201505042020
// agrego flg_ImprimirArchivos_Estado_Fin_Cron  para imprimir
// los archivos de fin de estado en cada crónica solo si se solicita.

//VERSION_ArchiTexto = 129; // rch@201504240822
// Se modifican booleanas de activación de control de cota en THidroCon Embalse.
// agregando extensión _sim en el nombre para indicar que son válidas en SImulación
// y se agregan dos booleanas más con el mismo nombre pero extensión _opt para
// permitir activar el control también en optimización.

//  VERSION_ArchiTexto = 128; // rch@201503270810
// Agrego variables flg_QMedMax_Activo y QMedMax en uTSumComb.TFichaSuministroSimpleCombustible
// para poder imponer restricción de caudal medio maximo por paso de tiempo inferior a QMax
// del suministro. Esto permite imponer un límite al consumo de Gasoil semanal inferior
// al consumo que se puede tener en las horas de punta.

//VERSION_ArchiTexto = 127; // rch@201502211913
// agrego las variables url_get a TFuenteSintetizador para que la use por
// defecto sobre los pronósticos con el mismo nombre del borne.

//  VERSION_ArchiTexto = 126; // rch@201502210954
// agrego las variables url_get y nombre_get en upronostico.TPronostico
// para implementar consulta a servicio web de las guías de pronósticos
// en sintetizadores CEGH.


//  VERSION_ArchiTexto = 125; // rch@201502201027
// Agrego en los Actores la variable flg_ShowVisorMantenimientosProgramados
// para que la sala se acuerde qué generadores están desplegados y cuales no.


//  VERSION_ArchiTexto = 124; // rch@201502140826 Cambio la representación de
// las Unidades pasando a tenger Unidades_Instaladas y Unidades_EnMantenimiento
// esto es para poder reflejar mejor en las Salas la cantidad de máquinas instaladas
// y cuales están en mantenimiento.


//    VERSION_ArchiTexto = 123; // rch@201409260816 Agrego ECA_DOP, ECA_TOP y PEX al bioembalse

//  VERSION_ArchiTexto = 122; // rch@201409131155 Cambio especificación de consumos propios de la Regas.

//  VERSION_ArchiTexto = 121; // rch@201409042011 Agregamo parámetros en Banco de Baterías.
//   VERSION_ArchiTexto = 120; // fp, rch@201409020955 Agregamos parámetros en Ficha HIdroCOnEmbalse para
// Conrol de crecida por restricción de h(QA) como es usada en Salto Grande.

//  VERSION_ArchiTexto = 119; // sigo modificando la regasificadora
//  VERSION_ArchiTexto = 116;
// rch@201408251834 agrego QGN_Max en TFichaRegasificadora.

//  VERSION_ArchiTexto = 115;
// rch@201408251325 agrego persistencia del vector de decisiones de la Regasificadora.

//  VERSION_ArchiTexto = 114;
// rch@20140823 agrego persistencia de rendimientos de acto TGSimple_Bbicombustible

//  VERSION_ArchiTexto = 113;
// rch@20140810 agrego posibilidad de indicar On/Off PorPaso para la TV del CC. Antes era solo por poste.

//  VERSION_ArchiTexto = 112;
// rch@20140724 agrego cálculo de ValorEnergiaAlMarginal y GradienteDeInversion

//  VERSION_ArchiTexto = 111;
// rch@20140720 agrego cv_NoCombustible en Generador Térmico básico, OnOf/paso
// arranque/parada ONoFf por poste, combinado

//VERSION_ArchiTexto = 110;
// rch@20140705 v443_fatum_statera ... agrego flg_SumarParaPostizado
// en las Demandas y flg_RestarParaPostizado
// en los generadores ParqueEolico, ParqueEolic_vxy, SolarPV.

//VERSION_ArchiTexto = 109;
// rch@20142506 Agrego Meses_TOP en ubiomasaembalsable

//  VERSION_ArchiTexto = 108;
// rch@20140506 Agrego lista de nodsCombustibles y arcsCombustibles
// en la sala para poder almacenar la red de combustibles.

// VERSION_ArchiTexto = 107;
// rch@201404161428 Agrego opción de imponer Despacho de igual
// Agrego cvea_impuesto en TBiomasaEmabalsable como parámetro
// dinámico y el checkbox "Imponer cvea" en el formulario principal.
// Si se marca el checkbox, se utiliza cvea_impueto (multiplicado por
// la indexación) del PEE para el despacho de la central. En este caso
// No utiliza la variable de estado para optimización.

//VERSION_ArchiTexto = 106;
// rch@20140412113 Agrego opción de imponer Despacho de igual
// potencia en todos los postes de las  centrales hidro de pasada
// Es pera poder preveer que las mini-hidráulicas pueden no-tener
// la capacidad de empuntar la energía.

// VERSION_ArchiTexto = 105;
// rch@20140405 Agrego capacidad de manejo de fuente de escurrimientos
// en las hidráulicas con embalse y de pasada. Esto es para poder
// utilizar el CEGH de escurrimientos desarrollado en conjunto con el
// IMFIA para el proyecto ANII-FSE-1-2011-1-6552_ModeladoAutoctonasEnSimSEE.


//  VERSION_ArchiTexto = 104;
// rch@20140317 Agrego descripción MINUTAL a globs.

//  VERSION_ArchiTexto = 103;
// rch@20140309 cambio nombre de variables en Parque Eólico
// para que quede claro que el pago por disponibilidad es por
// la Energia Disponible y no por las máquinas sanas o rotas.

//  VERSION_ArchiTexto = 102;
// rch@20140216 agrego fechaGuardaSim en uglobs.

//  VERSION_ArchiTexto = 101;
// rch@20131228 agrego variable global "ObligarInicioCronicaIncierto_1_Sim"
// en TGlobs para forzar InicioCronicaConIncertidumbre en las disponibilidades
// sin importar lo que se especifique en las fichas dinámicas.

//  VERSION_ArchiTexto = 100;
// rch@20131228 cambio la variable que indica si el alta de unidades es
// con o sin incertidumbre. En la versión anterior, esta variable era por actor.
// Ahora paso a ser por ficha de unidades
// También se agrega una variable en las fichas de unidades que permite especificar
// Si el inicio de crónica es Con o Sin Incertidumbre. El comportamiento por defecto
// es el anterior (esto es sin incertidumbre). Si se marca este casillero, el
// comportamiento pasa a ser Inicio Cronica Con INcertidumbre y se aplican las
// probabilidades de estado estacionario para las unidades que de acuerdo a las
// fichas de unidades estén disponibles al inicio de la crónica.



//  VERSION_ArchiTexto = 99;
// rch@201311022130 acomodo agregados de FBarreto en usalasdejuego y uglobs
//  en usalasdejuego agrega RandSeed_sincronoziaraliniciodecadacronica.
// en uglobs agrega la persistencia de las variables semilla_inicial_sim y semilla_inicial_opt

//  VERSION_ArchiTexto = 98;
// rch@201310191015 agrego pagos por energía y potencia en las Hidráulicas.

//   VERSION_ArchiTexto = 97;
// rch@201310121819 Agrego RadioBUtton para especificar tipo
// de cálculo de Riesgo  entre CVaR y VaR.

//   VERSION_ArchiTexto = 96;
// rch@201310121010 Agrego variable sincronizarConSemillaAleatoria en
// uFuenteSintetizador. Esta booleana permite especificar si al hacer la
// simulación con históricas, la serie se sincrioniza con el ordinal de la
// crónica o con el ordinal de la crónica más la semilla aleatoria. Esto permite
// en simulaciones de una crónica, seleccionar diferentes crónicas historicas
// cambiando la semilla de simulación.

//  VERSION_ArchiTexto = 95;
// rch@201309291900 Agrego parámetro engancharConSala_escenario en TSalaDeJuego
// esto es para compatibilizar que al especificar el enganche con una sala ahora
// hay que especificar el escenario para el enganche.

//  VERSION_ArchiTexto = 94;
// rch@20130928 agrego parametro "unidades" en los enganches de los CFs.
// esto es para seprar el nombre de la variable de la unidad y si en el
// futuro hay cambios de de unidades se pueda traducir.

//  VERSION_ArchiTexto = 93;
// rch@20130916 agrego parámetro EscenarioActivo en TSalaDeJuego

//  VERSION_ArchiTexto = 92;
// rch@20130914  agrego Escenarios en globs.

//  VERSION_ArchiTexto = 91;
// rch@20130914
//  agrego manejo de "CAPAS".
// La idea es que cada cosa puede estar en una CAPA. Por defecto
// todas están en la capa 0 (cero) pero pueden ser movidas a otras
// capas. Después introduciremos Escenarios y se permitirá que
// cada escenario tenga "capas asociadas". Así, se logrará en la misma
// sala tener diferentes escenarios.

//  VERSION_ArchiTexto = 90;
// rch@20130910
//  VERSION_ArchiTexto = 89;
//rch+milena@20130905 cambios en TGter_SolarTermico ... manenjos del almacen de energía.

//  VERSION_ArchiTexto = 88;
// rch@20130822
// Agrego Deterministico (booleana) que indica si la sala debe ser tratada como deterministica
// se agrega para emular solución como la usada por aplicación CPC en DNC-UTE a la fecha.


//  VERSION_ArchiTexto = 87;
// rch@20130817
// Agrego ObligarDisponibilidad_1_Opt en la Sala de Juego. Por defecto
// la cargo en FALSE que es como actuava. Esto es independiente de "Realizar Sorteos" de la Opt.

//  VERSION_ArchiTexto = 86;
// rch@20130815 agrego definición de forzamientos como fichas de parámetros dinámicos.

//   VERSION_ArchiTexto = 85;
// rch@20130801 Agrego parámetro QE_proteccion_cota_max para facilitar la
// especificación de la curva de erogado mínimo para protección de la presa.

//  VERSION_ArchiTexto = 84;
// rch@20130725
// Corrigo cálculo de UtilidadDirectaDelPaso que no se reincializaba a CERO en cada
// paso y se iba acumulando. Este error no afecta resutados salvo el de esa variable.
// Al corregir ese error verifico también que las utilidades no se consideran en la
// formación del costo futuro durante la optimización y agrego un CheckBox que sea
// Restar utilidades de CF que por defecto sea TRUE.

//  VERSION_ArchiTexto = 83;
// rch@20130716
// Agrego en las Fichas de Hidro con Embalse dos checkboxs para
// indicar si hay que calcular los caudales de pérdias por Evaporación y Filtración.


//    VERSION_ArchiTexto = 82;
// rch@20130602. Agrege a los pronósticos que guarden la GUIA en el espacio Gaussiano.
// Este guía es necesaria para imponer durante la optimización el centro
// de las gasussianas.

//  VERSION_ArchiTexto = 81;
// se agrega variable GerarRaw en TSalaDeJuego.

//  VERSION_ArchiTexto = 80;
//v80 agrego redimiento_pmin y rendimiento_pmax en las ONOFF por paso y POr poste
// rendimiento_pmin= 0.27;  rendimiento_pmax= 0.525;
// esto es por compatibilidad con la versión UTE de la regasificadora.

//  VERSION_ArchiTexto = 79;
// v79 rch@201305041200 agrego UsosGestionables a TSalaDeJuego

//  VERSION_ArchiTexto = 78;
//v78 agrego factor de amplificación en fuente de gen solar

//  VERSION_ArchiTexto = 77;
// v77 agrego manejo de Delta Asimetrico para Exportaciones e Importaciones en
//  en los mercados SpotPostizados.

//  VERSION_ArchiTexto = 76;
// v76 agrego manejo de Delta como margen exportador en los mercados SpotPostizados.

//  VERSION_ArchiTexto = 75;
// v75 rch@20130327 Agrego lista de plantillas SimRes3 a la sala.
// el objetivo es que el empaquetar pueda guardar las plantillas junto con la
// sala y además que el simuulador sea capaz de usar esta información para
// sacar las variables asociadas a las plantillas "activas" del listado.

//    VERSION_ArchiTexto = 74;
// v74 rch, enzo@20130308 Agrego parametros de iteración con flucar.
//  VERSION_ArchiTexto = 73;
// v72, v73 - rch@20130225 agrego suministros para modelo de regasificadora.

//VERSION_ArchiTexto = 71;
// v71 - rch@20130110 agrego Pago_Por_Disponibilidad y Pago_Por_Energía en actores
// PyCVariale,

//  VERSION_ArchiTexto = 70; // rch@20121306 agrego CheckBoxes que permiten especificar si el peaje en los arcos
// debe ser tenido en cuenta o no para el despacho y si el mismo se debe sumar al CDP luego de resuelto el
// despacho.
//  VERSION_ArchiTexto = 69; // rch@20121303 POSTIZADO de PMax, rendimiento y peaje de los arcos.
//  VERSION_ArchiTexto = 68; // rch@20121113 agrego variables en globs para calculo emisiones.
//  VERSION_ArchiTexto = 67; // rch@20121110 agrego variable CleanDevelopmentMechanism en los actores.
//v66 rch@20121107 agrego identificador de ZonaFlucar a los Nodos.
(* v65 rch@2012-10-09 agrego uniformizar_primediando de lista de variables NO Desaparecidas FSE31-2009*)
    (* v64 rch@2012-10-08 agrego la posibilidad de enganchar promediando en las dimensiones
    desaparecidas de los CF, para proyecto FSE-31-2009-Aportes_IMFIA *)
(* v63 y 62 rch@2012-10-05 agrego información para calculo de factores de emisión en TGenerador *)

    (* v61 rch@2012-09-24 agrego TArchiRef para que todas las referencias a archivos externos
    pasen por una clase y sea fácil empaquetar una corrida.
    Se supone que no cambia nada en cómo están escritas las salas *)

(*v60 2012-07-23 agrego SincronizarConHistoricos en las fuentes Sintetizador CEGH *)
(*v59 2012-06-26 agrego parámetros en la sala para menejo de la aversión al riesgo *)
(*v58, 2012-06-17 agrego parámetro NPasosAntesNuevaProg en TArcoConSalidaProgramable *)
(*v55, 14/11/2011 . sintetizadorCEGH ahora maneja los determinismos por separado . *)

(*v54, rch 6/11/2011 . agrego lectura de lista de combustibles en la sala. *)

  (*v53, rch 16/10/2011 agrego PenalidadONOFF en las fichas de parámetros dinámicos
  de TGer_ArranqueParada *)
  (* v52, rch 15/10/2011 se agregar histéresis en los ON/OFF de los generadores
  con costo de arranque/parada para evitar oscilaciones *)

    (* v51, 12/10/2011
       nUnidades de actores ahora es un TDAofNInt en vez de integer
    *)

// agrego control de topes de precios en TMercadoSpot_postizado.
//  VERSION_ArchiTexto = 49; // agrego descripción de barra_flucar y códigos_flucar en actores UniNodales

    (* v48, mejorando  22/9/2011
      TMercadoSpot para hacerlo con Límites de Potencia por Poste y precios por poste.
    *)

    (* En la v47 estoy guardando los parametros de la ficha SintetizadorCEGH
    (dichos parametros son los que valores con los que se itera en la ficha ) *)

    (* v44, En la fuente CEGH se agrega la posibilidad de arranque usando solo determinismo
     para fijar el estado inicial del filtro.
    *)
    (* v42, Agrego la posibilidad de cambiar la forma de resumir las muestras en las fuentes sub-muestreadas
           se agrega el campo ResumirPromediando a las fuentes aleatorias.
    *)
//  VERSION_ArchiTexto = 41; // En la 40 cometí un error en etiquetado de curvas de ParqueEolico_vxy
//  VERSION_ArchiTexto = 39; rch@6.11.2010 agrego curvas VP por dirección en TParqueEolico_vxy
//  VERSION_ArchiTexto = 37; // rch@26.9.2010 agrego ArranqueConico en las fuentes CEGH
//  VERSION_ArchiTexto= 36; // rch@30.7.2010 agrego pago por energía en TParqueEolico para calculo de CAD
//  VERSION_ArchiTexto= 35; // rch@10.6.2010 cambié en THidroDePasada que el valor del agua es en USD/Hm3
//  VERSION_ArchiTexto= 34; // rch@12.5.2010 le agrego al térmico básico el PagoPorPoencia y PagoPorEnergia

//  VERSION_ArchiTexto= 33; // rch@28.3.2010 le agrego ArchivoCFaux en la sala para
//  que se guarde y no haya que escribirlo cada vez.
//  VERSION_ArchiTexto= 32;  // Le agrego la capacidad de tener otro modeloAuxiliar
//  para ser usado en la optimización y para posicionar
//  el estado global durante la simulación.
//  VERSION_ArchiTexto= 31;  // le agrego parámetro multiplicar_vm alas fuentes CEGH
//  VERSION_ArchiTexto= 30;  // introduce SaltoMinimoOperativo en las THidroConEmbalse y THidroDePasada
//  VERSION_ArchiTexto= 29;  // introduce ControlDeCrecida en las THidroConEmbalse


implementation

end.
