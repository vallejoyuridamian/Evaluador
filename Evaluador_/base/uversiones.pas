unit uversiones;

interface
const
CONDITIONAL_DEFINES =''
 + {$IFDEF COSTOSHIDROPOSITIVOS}'+'{$ELSE}'-'{$ENDIF}+'COSTOSHIDROPOSITIVOS'#13#10
 + {$IFDEF PDE_RIESGO}'+'{$ELSE}'-'{$ENDIF}+'PDE_RIESGO'#13#10
 + {$IFDEF MONITORES}'+'{$ELSE}'-'{$ENDIF}+'MONITORES'#13#10
 + {$IFDEF CALC_DEMANDA_NETA}'+'{$ELSE}'-'{$ENDIF}+'CALC_DEMANDA_NETA'#13#10
 + {$IFDEF MODOGRAFICO}'+'{$ELSE}'-'{$ENDIF}+'MODOGRAFICO'#13#10
 + {$IFDEF DEBUG_MULTI_HILO}'+'{$ELSE}'-'{$ENDIF}+'DEBUG_MULTI_HILO'#13#10
 + {$IFDEF DBG_HIDRO_CON_EMBALSE}'+'{$ELSE}'-'{$ENDIF}+'DBG_HIDRO_CON_EMBALSE'#13#10
 ;

const
  vSimSEESimulador_ = '_161';
  // rch@20170728 Bugfix. Las fuentes esclavizadas no publicaban bien las variables en el caso
  // en que en la sala estaba marcado "publicar solo variables usadas en SimRes3".
  // Se implementó que el Esclavizador llama los métodos de la esclava.


//   vSimSEESimulador_ = '_160';
  // rch@20170826 Bugfix, se había deshabilitado el funcionamiento de "sincronizar con históricas"
  // para el caso de simulación con series históricas. Se vuelve a habilitar.

//  vSimSEESimulador_ = '_159';
  // rch@20170713 Bugfix, en el manejo del CFAux en la simulaicón había
  // dejado de funcionar correctamente impidiendo leer la variable en
  // SimRes3.

 //  vSimSEESimulador_= '_158';
  // rch@20170703 Cambiamos parámetros en Central Solar PV. Ahora se especifica
  // la Potencia de Pico para 1000 W/m2 a 25C y las pérdidas eléctricas (cableado+trafo+inv)
  // y la Potencia máxima de Inversor. Todo por MODULO.
  // rch@20170627 Bugfix en usolarpv daba error si se ponía PMax = 0 en la ficha dinámica
  // de parámetros.



//  vSimSEESimulador_= '_157';
  // rch@20170606
  // 1) Bugfix. Fuente selector Horario. Le faltaba inherited Create a la clase y eso
  // hace que se rompa el mecanismo de persistencia por lo cual no se salvava.
  // 2) elimino el nilonclose de los trazosxy porque aveces daba error
  // en calibrar cono.
  //

//  vSimSEESimulador_= '_156';
  // rch@201705261629 bugfix fddp.TMadreUniforme.randomIntRange tenía un error
  // por lo cual los extremos del rango tenían una probabilidad de ocurrir 0.5 de la
  // del resto de los puntos del rango. Este bug queda totalmente soslayado por el que se
  // comenta a continuación. El sorteo de enteros se utiliza en el resumir (sin promediar) pero
  // el segundo bug es el que realmente cambia los valores.
  // rch@201705291012 bugfix GRAVE. Había un error en el resumen de las fuentes esclavizadas
  // en un sub-muestreo que hacía que al usar en conjunto con NETEAR PARA POSTIZAR se creará
  // un sesgo en la elección del representante del poste en los generadores resumidos (eólica, solar)
  // hacia el lado de privilegiar las horas de mayor demanda neta lo que es lo mismo que sesgar hacia
  // una menor generación de las renovables.

  // vSimSEESimulador_= '_155';
    // rch@20170516
    // bugfix en exportación a ods de las fichas dinámicas de fuentes.

//   vSimSEESimulador_= '_154_ods';
  // rch@201704240835
  // Cambio la exportación/importación de Excel a que guarde/lea un archivo .ods
  // y luego lo abra con la función opendocument() para asegurar que abra el archivo
  // con la aplicación que tenga instalada para ese propósito. Este cambio fue necesario
  // pues en FING el estandar es LibreOffice (u OppenOffice) y no hay Excel instalado.

  // vSimSEESimulador_= '_153_Barumi';
  // rch@20170314 bugfix 1) en editor de fichas hidro con embalse e hidro con bobmeo
  // el bug impedía marcar la imposición de erogado mínimo por poste salvo que se hubiera
  // marcado activar la restricción de QTMin. Ahora lo permite si cualquiera de las restricciones
  // QTmin o QTmin_falla está activada.
  // bugfix 2) en cálculo de GRADIENTES DE INVERSION. En la versión 149 se separó del cálculo del
  // Costo Directo del Paso de los actores y faltó considerar este cambio en el cálculo de los
  // Gradientes de Inversión. Esto afecta los resultados de salas que tuvieran marcado ese resultado
  // y el error salta a la vista pues los gradientes dan POSITIVOS por faltar restar los pagos por
  // Potencia y Energía.


//  vSimSEESimulador_= '_152_Taslimah';
  // rch 20170309 Agrego manejo de Unidades (Inverson/Rectificador/Celda) a los bancos
  // de batería y PagoPorDisponibilidad_USDxMWhh a los bancos de batería.
  //

  //  vSimSEESimulador_= '_151_Taslimah';
  // rch@201702051020 BUGFIX *****
  // Había un error que hacía que se leyera mal (desplazada) la Política de Operación
  // en salas donde las fechas iniciales de Simulación y Optimización NO-COINCIDIAN.
  // El error impacta en resultados de Salas en que las fechas iniciales de Opt y Sim
  // no coinciden.
  // Además se agregó como variable persistente el HusoHorario_UTC para que SimSEE
  // pueda funcionar adecuadamente con en otras ubicaciones. Por Defecto el HusoHorario_UTC = -3 (Uruguay)


//  vSimSEESimulador_= '_150_Jessenia';
// jf@20161221 (revisión 1935 de uhidroconembalse)
//BUGFIX: Se corrige error en el parámetro que se le pasaba a la función que calcula
//el erogado mínimo de la central según el volumen embalsado (ErogadoMinimo_Ctrl_Crecida). En la versión anterior
// (revisión 1928 de uhidroconembalse) se llamaba a la función con el volúmen sin erogado Vs_SinErogado (volumen inicial paso+aportes-perdidas)
//sin considerar que dentro de la función se sumaban los aportes-perdidas . Esto ocasionaba que
//la central aplicara el control de crecida para un volúmen superior al real y por tanto hiciera
//un erogado superior al establecido en las curvas de vertido de la central.


//vSimSEESimulador_= '_149_Tharaa';
// rch@20161216
// 1) Cambio forma de leer las Cosas de forma de obligar la lectura en orden
// de los parámetros. Esto quita flexibilidad pero va a simplificar la migración a otras
// formas de lectura (por ej. vía web o db).
// 2) Agrego variable: flg_IncluirPagosPotenciaYEnergiaEn_CF a TSalaDeJuegos
// para controlar si se suman o no a CF los IngresosPorDisponibilidad e IngresosPorEnergia de los Actores
// En la implementación anterior estaba que SI, los sumaba. Ahora se deja la opción
// QUEDA PENDIENTE DE REVISAR LA CONSIDERACION DEL PEAJE EN LOS ARCOS (eléctricos y combustibles)
// EN la implementación actual (y anterior) el PEAJE se considera para el dspacho del paso y
// es opcional si se contabiliza para el Costo Directo del Paso (y por tanto en el Costo Futuro) y si
// se marca en el arco que se considere, se permite indicar un factor de consideración.
// En la versión actual, se optó por hacer que se reproduzca el comportamiento anterior pero hay que revisar.


//  vSimSEESimulador_= '_148b_Yasira';
  // rch@201612140740 BUGFIX de bug introducido en el proceso de debug de la 148
  // Se había eliminado la línea que cargaba los aportes de las hidro con embalse
  // por lo cual le quedaban los aportes en CERO.


  // vSimSEESimulador_= '_148_Yasira';
  // rch@201612131232
  // BUGFIG en THidroConEmbalse. No se inicializaba adecuadamente le variable h_real
  // en Sim_CronicaInicio. Esto tenía como consecuencia que calculara mal las pérdidas
  // por filtración y evaporación en el primer paso y tenía como consecuencia que daban diferentes
  // las simulaciones MONO-HILO de las MULTI-HILO. Las diferencias eran muy menores por
  // tratarse de las pérdidas del lago en un solo paso de simulación.

//  vSimSEESimulador_= '_147b_Yasmin';
  // rch@201612111813
  // 1) BugFix varios en los gráficos de áreas apiladas de SimRes3 tanto en formato
  // html como a Excel. (tema del ejex cuando el paso de tiempo es horario).
  // 2) Mejora la exportación de SimRes3 a scripts R, Octave y Matlab (ROM)
  // Ahora exporta las CronVars a archivos nombre.csv y en otro archivo
  // con nombre_def.csv salva la inforamción de la CronVar, como nPasos, nCronicas
  // y la fecha de la primera muestra. De esta forma se facilita a los scripts
  // ROM a leer por separado la matriz de datos y la información auxiliar si
  // la requieren.

  // vSimSEESimulador_= '_147_Yasmin';
  // rch@20161209
  // 1) Enganches entre salas mediante Evaluador de Expresiones.  (Beta)
  // Se agrega posibilidad de enganchar salas con transformación de variables de estado.
  // Para ello se agregó en el Editor de Enganches (todavía versión beta) la posibilidad
  // de definir expresiones del tipo $Y_NombreVar := Expresión; dónde
  // Exprsión es uan expresión que puede incluir nombres de variables del tipo $X_NOmbreVar
  // Siendo las varialbes $X_NombreVar las variables de la Sala QUE ENGANCHA y $Y_NOmbreVar
  // las variables de estado de la sala A LA QUE SE ENGANCHA (la del futuro).
  // A TParticipanteDeMerado se le agregó un método que le permite agregar FUNCIONES al Evaluador
  // de expresiones, de esa forma se consiguió en forma genérica que cualquier modelo pueda plantear
  // transformaciones a realizar en el enganche entre salas. En particular, este mecanismo se
  // desarrollo para que la central binacional con embalse pueda traducir la DiferenciaDeEnergíaEmbalsada
  // y el volumen de la central a un VOlumenVIsto en las salas de más largo plazo a las que se engancha.
  // 2) BUGFIX. en versión Multi-hilo del Simulador (botón agregado recientemente) había un error
  // por el que no se estaba imponiendo el OBLIGAR_DISPONIBILIDAD_1 en la simulación MULTI-HILO.
  // Esto hacía en las salas en que se había marcado OBLIGAR_DISPONIBILIDAD_1 que los resultados
  // entre las simulaciones Mono-HIlo y Multi-Hilo difirieran (las multi no obligaban la disponibilidad).

  //  vSimSEESimulador_= '_146_Yakootah';
  // rch@201611302127
  // 1) BUGFIX. Se corrige error del Editor por el que fallaba la importación
  //   desde Excel de fichas de parámetros dinámicos.
  // 2) Se corrige error en el editor que impedía la edición del valor de los
  //   enganches de la función CF.

  // vSimSEESimulador_= '_145_Yakootah';
  // rch@201611241822
  // Implemento que las Demandas tengan en cuenta las UNIDADES.
  // Esto se hizo para poder incluir en una sala demandas auxiliares que se
  // habilitan o des-habilitan según el Escenario.

  // vSimSEESimulador_= '_144_Yakootah';
  // rch,fp,ps@201611241145
  // Bugfix en THidroConEmbalse, el polinomio de cálculo de QE para control de crecida
  // podía dar negativo si el volumen superaba ampliamente los valores de calibración
  // se corrigió para que si V > VmaxControl el erogado sea el establecido en VMaxControl.

  // vSimSEESimulador_= '_143_Zafira';
  // rch@201611181625 ... comenzamos pruebas de introducción de pronósticos en
  // programación de corto plazo por medio de GUIA PE50 en CEGH.

  //vSimSEESimulador_= '_142e_Zahira';
  // rch@201611072153
  // BUGFIX en uauxiliares agrego una TCrticalSection para el manejo de
  //    SetSeparadoresGlobales y SetSeparadoresLocales
  //    en la simulación multi-hilo esto traia problema en el clonado de
  //    fichas dinámicas que terminaba confundiendo fechas y fallando dependiendo
  //    de la velocidad de la máquina.

  //  vSimSEESimulador_= '_142d_Zahira';
  // rch@201611071944
  // BUGFIX en editor de SimRes3, en detección de variables por poste se podía
  // producir una condición de error según el nombre de la variable.
  // También se recompila para que las fuentes PUBLIQUEN la bornera cosa que se
  // había deshabilitado.

  //vSimSEESimulador_= '_142c_Zahira';
  // rch@20161014
  // BUGFIX_1, MultiOrdenar ordenaba una crónica más de las existentes. (range check error)
  // BUGFIX_2, Enventalar se creaba con una crónica menos de las necesarias. (range check error)
  // Se agragan CONDITIONAL DEFINES en uHidroConEmbalse para deshabilitar/habilitar cambios
  // realizados por FP, respecto a limitar la QEmáx en las iteraciones de las hidráulicas
  // y en el cálculo de la QEmín por control de crecida para facilitar comparaciones de
  // cambios que está implementando FP en el agregado de una restricción de QEmin con
  // penalidad por incumplimiento.

  // vSimSEESimulador_= '_142b_Zahira';
  // 201610121925
  // BUGFIX_1, al finalizar Optimizacion MultiHilo al hacer Free de las salas
  // podía ocurrir que dos salas hieran Free del mismo archivo CEGH.
  // ahora antes de hacer haen un lock de una criticalsession.
  // este bug hacía que en algunas optimizaciones multihilo
  // se colgara al finalizar.
  // BUGFIX_2, en SimRes3, había un error al determinar la secuencia de crónicas
  // en archivos de simulación multi-hilo. El error hacía que fallara el SimRes3
  // con una excepción indicando que los archivos de resultados no corresponden
  // con un conjunto consecutivos de crónicas.
  // La corrección de estos bugs no cambia ningún resultado. Ambos bugas simplemente
  // hacian que se colgara la Optimización (multihilo) o la ejecución de SimRes3
  // en forma aleatoria.

  // vSimSEESimulador_= '_142_Zahira'; //fb&ps@20160923
  // BUGFIX en SimRes3 -> PostOper -> MultiOrdenar operaba fuera de rango.
  // Se agregan cuatro PostOpers: Recronizar, Ventanar, Transponer y AcumCon

  //vSimSEESimulador_= '_141_Zahara'; //jfp@201609131011
  //Se corrige tope de potencia máxima en iteraciones en uhidroconembalse que
  //producía turbinados mayores que los máximos de las turbinas. Dicho tope estaba
  //seteado como la semisuma entre la potencia generada por la central y
  //el tope en la iter anterior, pero no se chequeaba que fuera inferior
  //a la potencia máxima generable por la central el la iteracion actual. Para corregir el error
  //se minimizo el tope con la potencia maxima generable por la central que se actualiza
  //según coeficiente energético de cada iter.

  //vSimSEESimulador_= '_140_Zareen';    // rch@201609081141
  // Se agrega opción en Operación Crónica SumaDobleProductoConDurPosTopeado para facilitar
  // cálculo de ingreso en horas críticas
  // Se mejora cambios realativos a ls simuació MultiHilo
  // se Pasa a versió 64bits con lo que se reduce del orden de 30% el tiempo de optimización
  // y además se levanta la restricción de que el proceso no podía solictar más de 2Gb al sistema
  // lo que impedía la simulación/optmizació de salas horarias de varios años y además impedía
  // la confección de plantillas SimRes3 de muchas variables para manejo de esas salas.

  //vSimSEESimulador_= '_139_Zarifah';
  // Correcciones a SimRes3 intentando que pueda leer los archivos de salidas de simulación
  // tanto en formato viejo (un archivo) como en el formato nuevo introducido en la versión
  // anterior.

  //vSimSEESimulador_= '_138_Zaina';
  // rch@20160830  .. Se habilita la Simulación Multihilo. Ahora los resultados de simulación
  // se reparten en varios archivos  por ej: simres_31_Base_d00026a00050h0.xlt
  // donde, 31 es la semilla, "Base" es el escenario, d00026 a00050 indica el rango
  // de crónicas de simulación que incluye ese arcivo (de la 26 a la 50) y h0 indica que
  // ese archivo lo generó el Hilo 0. (los hilos se numeran de 0, a N-1).

  // vSimSEESimulador_= '_137d_Zurah';
  // rch@201608221638 vuelvo a habilitar la escritura buffereada a Excel
  // es notoria la diferencia de velocidad de escritura.
  // Esta forma de escritura se había deshabilitado cuando se implementó la versión
  // de salida en html ahora la vuelvo a habilitar.

  //vSimSEESimulador_= '_137c_Zurah';
  // rch@201608220739 bugfix: en Editor. Error al clonar fichas.
  // bugfix: se colgaba al simular con históricas por no haber sorteado los
  // Escenarios.


//  vSimSEESimulador_= '_137b_Zurah';
  // rch@201608191000 bugfix en el Edtior. Se rompía al intentar editar unidades
  // por error introducido en versión 136.

//  vSimSEESimulador_= '_137_Zurah';
  // rch@201608181208
  // en umadresuniformes procedure TMadresUniformes.Reiniciar( NuevaSemilla: integer );
  // hice cambio para que la generación de semillas no tenga desborde numérico
  // lo que ocurrió en simlaciones largas horarias de 1000 crónicas.
  //
  // rch@201608120711
  // 1) Se mejora el tratamiento multi-hilo de la simulación separando
  // el mecanismo de clonación de cosas. Tal como estaba interferían entre si los hilos
  // durante la simulación pues la expansión de fichas dinámicas incluye clonación de
  // las misma en caso de fichas períodicas. En la Optimización esto no era un problema
  // pues la expansión de las fichas y preparación de las salas se realiza antes de
  // inciar la Optimización. En la Simulación se trató de paralelizar también la preperación
  // de las salas y surgió el problema.
  // 2) En versiones recientes se habilitó expresamente que las fuentes CEGH exporten toda
  // la bornera lo que hace que los archivos de simulación sean bastante más voluminosos
  // y por eso es muy importante marcar "publicar solo variables usadas en SimRes3". Una
  // vez marcado este checkbox, al preparse para simular, la Sala debía leer las plantillas
  // SimRes3 para obtener el listado de variables a plublicar. Esta LECTURA de plantillas
  // al inicio de las simulaciones trajo aparejado dos problemas cuando la simulación
  // se ejecuta desde línea de comando: a) Las Plantillas con operaciones que implican
  // GRAFICOS no son leibles en aplicaciones de línea de comando y b) La información de
  // la ruta de la Plantilla SimRes3 debe ser completa para habilitar su lectura.
  // Estos dos inconvenientes surgieron al intentar ejecutar la simulación multi-hilo
  // en el CLUSTER y dio lugar a este cambio de versión. Se implementó que en la
  // lectura de las plantillas para determinar las variables a publicar sólo se lee hasta
  // el listado de índices eviantando por tanto leer las operaciones (y evitando así
  // el error por intentar leer un tipo de operación gráfico en el entorno de consola)
  // Con respecto a la ubicación de los archivos de Plantilla se utilizó el mismo criterio
  // que con el resto de los archivos asociados a una sala que consiste en buscarlo en
  // su ubicación origial, en el directorio de ejecución y en el directorio de la Sala.


  // vSimSEESimulador_= '_136_Escofina';
  // rch@201608031459 bugfix. Se fija error de pérdida de memoria que impedía ejecutar
  // optimizaciones/simulaciones horarias de más de un año.


  //vSimSEESimulador_= '_135_Congorosa';
  // rch@201607271335 bugfix en manejo de borneras de fuentes esclavizadas en subsorteo.
  // AL cambiar de paso estaba quedando en la bornera el RESUMEN del paso anterior y eso hacía
  // que no coinicidieran las salidas si la misma sala se simulaba conpaso horario.
  // El resultado era estadísticamente correcto en el sentido que al inicio del paso se estaba
  // usando un valor que era el resumen (promedio o máxvar) del paso anterior pero impedía la
  // comparación entre salas de paso semanal y horario.
  // Además se implementó que los CEGHs se cargan una vez y se comparten entre los threads
  // para el caso de las corridas multihilo lo que aumenta la eficiencia en los tiempos de
  // inicialización y finalización y además consume menos memoria.

//  vSimSEESimulador_= '_134b_Rienda';
  // rch@201607251807 bugfix en inicialización de escenarios by F.Barreto.

//  vSimSEESimulador_= '_134_Rienda';
  // rch@201607220018 Cambio la forma de hacer el sorteo de ResumirBorneras en
  // uEsclavizadorSubMuestreado para que para todos los borners asociados a un mismo
  // poste el sorteo sea el mismo. Esto se cambió para que si se conectan dos actores
  // al mismo borne y se está utilizando el Resumir por máxima varianza, ambos actores
  // vean lo mismo aunque usen un borne calculado.

//  vSimSEESimulador_= '_133_Bozal';
// rch@201606020757 bugfix se corrige error en el calibrado de conos de pronósticos
// introducido en versiones anteriores al trabajar sobre la definición de "escenarios de pronósticos"
// Lo que hice fue volver al código viejo hasta que revisemos el nuevo.

//   vSimSEESimulador_= '_130_Rebenque';
  // rch@201605172047 bugfix_cursoSimSEE2016. En  TActorBancoDeBaterias01 estaba mal el signo del
  // valor de la energía almacenada cv_MWh = - dCF/dX  (faltaba el "-")

 //  vSimSEESimulador_= '_129_Sobeo';
  // rch@201605111013 deshabilito el conditionaldefine SPXMEJORCAMINO en usaladejuegos.
  // Me parece que el uso del SPXMEJORCAMINO al "recordar" el camino de resolución del MIP_Simplex
  // puede causar diferencias entre el cálculo distribuido y el no distribuido (o entre el MultiHilo
  // y el Mono Hilo). Esas diferencias de existir tendrían que ser mínimas, pero para facilitar las
  // comparaciones de corridas deshabilito esta opción.

//  vSimSEESimulador_= '_128_Tia';
  // rch@201603090654  bugfix en Fuentes Reales asociadas al Actor PVSolar
  // El bug fue introducido el 14/2 al introducir en globs de SimSEE la variable
  // HUSOHorario y por tanto afecta los resultados de corridas que tuvieran el Actor Solar PV
  // realizadas con binarios compilados con posterioridad a dicha fecha (versiones 128_Prima y 128_PrimaPrima)

//  vSimSEESimulador_= '_128_PrimaPrima';
  // rch&fb 201603041231  bugfix en Editor de FUentes CEGH. No permitía cambiar el pronóstico.

  //vSimSEESimulador_= '_128_Prima';
  // rch 20160216 cambio en sorteo de fuentes CEGH para que si tiene un solo escenario NO sorte escenario
  // y así no afecte los sorteos de los Ruidos Blancos Gaussianos (RBG). EN futura versión esto se soluciona
  // con dos fuentes independientes de sorteso, una para los escenarios y otra para los RBG.
  // También se agregó un CheckBox "Modo ComparacióN" en la Operación Crónica
  // SumaDobleProductoConDurPosTopeado si el checkbox= false hace lo mismo que ahora si
  // está a true lo que hace es poner en el resutado el producto con durpos cuando el marginal está por
  // debajo del tope en el resultado y en el recorte cuando está para arriba. Esto tiene utilidad para
  // determinar la energía entregada por un generador por debajo y por encima de un determinado valor
  // por ejemplo para determinar la energía entregada en situación de excedentes de costo variable nulo poniendo
  // el umbral por encima del precio de la exportación "sumidero" de excedentes.


//   vSimSEESimulador_= '_128_Estribo';
  // rch 20151211 cambios en uPrint.pas bugfix en definición de tipos de series en los gráficos.

//  vSimSEESimulador_ =  '_127_Cabresto';
// rch 20151204 cambios en uescala.pas para mejorar cálculo de escalas automáticas para graificas SimRes3

//  vSimSEESimulador_ =  '_126_Sobre-Cincha';
  // rch@201511080726 cambios en el editor para serpar la MIGRACION_PERSISTENCIA
  // del editor que está en producción por problemas para Exportar fichas contantes
  // a Excel.
  // Agrego posibilidad de condicionar la disponibilidad de un Arco al valor
  // de una fuente.

//   vSimSEESimulador_ =  '_125_Badana';
 // rch@201510201014 hago cambio en ucmdoptsim para que funcione la definición de
 // un directori temporal de corridas diferente del de la sala. Esto puede traer problemas
 // en archivos que no tengan la ruta completa. En el caso de los archivos de DemandaDetallada
 // se solucionó, pero pueden quedar otros. Este cmabio no afecta el SimSEESimulador
 // solo afecta a los de línea de comando

//  vSimSEESimulador_ =  '_124_Pelego';
  // rch@20151001
  // BUGFIX IMPORTANTE. Había un error "desde el origen del SimSEE" que hacía que
  // el actualizador de fichas de parámetros dinámicos "no viera" la ficha que le
  // quedara en la posición 0 (Cero).
  // Esto tiene consecuencias o no dependiendo de la suerte que hubiera tenido en que
  // la primer ficha dinámica fuera relevante o no. Este bug afectaba solamente la OPTIMIZACION.
  // El lugar de las fichas LPD depende del resto de las fichas y del orden de insersión de los
  // Actores. Esto llevaba a comportamientos extraños como que por agregar una ficha en un actor
  // cambiaba el comportamiento de otro, por sustituirlo en el casillero "no visto".


// vSimSEESimulador_ = '_123_Cincha';
// Se agrega control en la resolución de bornes de las fuentes para que NO permita la ejecución
// si hay bornes sin resolver. Esto es para prevenir errores del editor. (O de la edición manual de salas).

 //  vSimSEESimulador_ = '_122_Basto';
 // Incorpora cambios de Felipe sobre la hidro con embalse binacional.(todavía beta)

//  vSimSEESimulador_ = '_121_Carona';
  // rch@20150901 BUGFIX IMPORTANTE: En la optimización MULTIHILO había un error
  // de diseño por el cuál si se corrían más de una Optimización MultiHilo en simultáneo
  // en la misma máquina los procesos se interferían. El error venía por los Eventos
  // creados en la unidad umh_sincrodata que tenía nombre que no identificaba el
  // proceso en forma única con lo cual los Workers de una optimización señalizaban
  // tarea entregada en todas las lanzadas en forma simultánea. El error no afecta los
  // resultados de las optimizaciones Multihilo si se ejecutaba una sola.

//  vSimSEESimulador_ = '_120_Jerga_';
  // Asociada al cambio de VERSION_ArchiTexto = 133; // df,fb@201508241122
  // Se le agrega al actor THidroConEmbalse la posibilidad de introducirle error
  // a la cota inicial.
  // Además se mejora acceso a Excel de SimRes3 tratando de mejorar la compatibilidad
  // con el Excel nuevo.

//  vSimSEESimulador_ = '_119_Amargo_'; // rch@201506291547
  // agrego DEFINE ExpansionRuida al Editor para que funcione TFuenteSelectorHorario
  // este parche es para que funcione, pero hay que cambiar la fuente para que guarde el nombre
  // del borne en lugar del idBorne para independizar la referencia del borne de la definición de
  // la bornera de las fuentes.

  //vSimSEESimulador_ = '_118_MateAmargo_'; // fb@201506241651
  //  en usaladejuegos->simular, se cambia el orden de Preparar_fuentes_ps para
  // antes de ActualizarEstadoGlobal(true) de Actores y Fuentes.
  // El cambio fue realizado para que HidoConEmbalse pueda leer el valor de la
  // fuente de Aportes en ActualizarEstadoGlobal(true)

  //vSimSEESimulador_ = '_117_Carqueja_'; // rch@201506190107
  //  Vuelvo a método Referencia definido por defecto en TFuenteAleatoria.


//  vSimSEESimulador_ = '_116_Carqueja_'; // rch&fb@201506172111
// bugfix: La fuente "MaxMin" no sebreescribía el método "referencia" con lo cual
// no se estaba ordenando bien la dependencia de fuentes. Esto ocasionaba diferencias
// entre las corridas monohilo y multihilo.

//  vSimSEESimulador_ = '_115_Carqueja_'; // rch&fb@201506121010
//  bugfix: THidroConEmbalse. Tal como estaba inicializaba mal h_real en el cálculo
// de las pérdidas de Filtración y Evaporación durante la optimización. Esto llevaba
// a que se calcularan en base a la resolución de la estrella anterior. Esto puede explicar
// las diferencias detectadas entre la optimización Multi-hilo y mono-hilo, dado que "la
// estrella anterior" cambia mucho al tener varios hilos. Las consecuencias sobre los resultados
// deben no ser muy grandes pues la filtración y la evaporación no son siempre volúmenes pequeños.


///  vSimSEESimulador_ = '_114_Carqueja_'; // rch@201506112022
// Bugfix en Editor de FuenteSelectorHorario Impedía editar una fuente
// previamente guardada.


//  vSimSEESimulador_ = '_113_Carqueja_'; // rch@201506011153
// BUGFIX. en el editor de TDemandaDetallada, exportaba mal a Excel si se trataba
// de un archivo binario de demanda que ya existía (o sea que no se creaba). El
// error se produce si el archivo tiene fecha de inicio diferente que la de la sala.

//  vSimSEESimulador_ = '_112_DeNoSi_'; // rch@201505261328
  // recompilo volviendo el cálculo del valor del agua a DERIVADAS NO SIMETRICAS.


//  vSimSEESimulador_ = '_111_Carqueja_'; // rch@20150518
// BUGFIX. Se arregla error introducido por DFusco en uaxiliares.pas que implicaba
// la mezcla de formatos entre ISO y locales durante la lectura de una sala.
// Se debe mantener el criterio de que TODA INFO guardad esté en formato ISO.


//  vSimSEESimulador_ = '_110_Carqueja_'; // rch@20150514
// Se arregla variable agregada pro Felipe para fijar el valor del agua en
// modalidad control de cota de las hidráulicas.
// Se recompila para habilitar Excel.

//  vSimSEESimulador_ = '_109_Carqueja_'; // rch@201505130635
// versión experimental NO USA EXCEL
  // + Bugfix en inicialización de CF si engancha con otro CF y no está CAR  activa
  // intentaba inicializar histogramas que no había creado.
  // Este bug se introdujo en una versión reciente al "experimentar" con la CAR.
  // + Se agrega a los editores de GTer_Basico y DemandaDetallada el manejo
  // de la reserva rotante. Se agrega en el panel de Sim/Opt del editor
  // un checkbox para habilitar el manejo de ReservaRotante (todavía en desarrollo).
  // + Se corrige align Panel de escenarios para que se vean todos.
  // + Se corrigen textos en panel de control de cota de THidroConEmbalse
//
//  vSimSEESimulador_ = '_108_Carqueja_'; // rch@201505042100
// Bugfix. en archivo SimCostos estaba imprimiendo mal el VaR(0.05)
// También se agregó checkbox al editor para poder marcar si se desea o no
// que se impriman los  archivos con estado de fin de crónica que son muchos
// y generalmente no se utilizan.
//

//  vSimSEESimulador_ = '_107_Garufa_'; // rch@201504240826
// modifico el control de cotas de las THidroConEmbalse para que pueda
// activarse en Simulación y en Optimización por separado. Antes de esta
// versión cuando se activaba operaba solamente durante la Simulación.
// Para agregarlo durante la optimización y que tenga sentido la función
// CF(X,k) debe incluir el costo de la penalidad incurrido como un costo
// verdadero sino el optimizador termina compensando el control.


//  vSimSEESimulador_ = '_106_Garufa_'; // rch@201504222043
  // Se mejora optimización con aversión al riesgo cambiando el re-muestreo
  // de los histogramas de costo para conservar siempre el peor y mejor valor
  // entre las muestras.


//  vSimSEESimulador_ = '_105c_Corral_'; // rch@201503270902
  // Agrego restricción de caudal medio máximo por paso de tiempo
  // en TFichaSuministroSimpleCombustible


  // vSimSEESimulador_ = '_105c_Tranquera_'; // rch@2015031628
  // Recompilación para propuesta de versión oficial.

  // vSimSEESimulador_ = '_105c_Laud_'; // rch@201503101743
  // Agreto que las Hidro de pasada publiquen la variable dual de la
  // restricción de balance (V_Turbinado+V_Vertido - V_Aportes = 0 ) en USD/Hm3

  // vSimSEESimulador_ = '_105c_Asinos_'; // rch@201502261954
  // Se mejora forma en que los Generadores Postizadores leen las fuentes
  // se continúa debuggeando al versión Diezminutal.

  // vSimSEESimulador_ = '_105c_Bagual_'; // rch@20150222227
  // Se agregan parámetros a TPronostico y TFuenteSintetizador para poder
  // hacer consultas de pronósticos.
  // Cambia el comportamiento de TEdit en VisorTablas para que al pegar
  // desde Excel cambie retornos de líneas por ";" y también Tabuladores por ";"
  // Eso permite por ejemplo copiar una lista de valores desde Excel directamente
  // en el casillero de la GUIA de un cono de pronósticos en una fuente CEGH.

  // vSimSEESimulador_ = '_105c_Arisco_'; // rch@201502132347
  // bugfix - THidroConembalse estaba calculando mal la derivada del costo futuro
  // en el nivel más bajo de la discretización lo que hacía que se sub-valorara
  // el agua en el fondo del los lagos.

  //vSimSEESimulador_ = '_105c_Chúcaro_'; // rch@201502090757
  //  bugfix en el interpolador de demanda detallada horaria para salas diezminutales
  //  acondiciono mecanismo postizador en base a Demanda Neta para que funcione
  //  en salas Diezminutales. Tal como estaba asumía paso de tiempo >= 1h.
  //  Se agrega publicación por defecto para SimRes3 del valor dual de la
  //  restricción de caudal de las hidráulicas de pasa

//  vSimSEESimulador_ = '_105c_Argot_'; // rch@201502041222
  // Se cambió la forma de tratar las series históricas en los sitntetizadores CEGH para
  // permitir que se puedan usar series históricas con diferente paso entre muestras que el
  // paso de simulación.

  //  vSimSEESimulador_ = '_TEST105_daa'; // rch@201501310840
    // Se supone que no tiene cambios de algoritmos y que solo se agergó
    // la capacidad de los objetos persistentes de describir sus campos para
    // faliciltar la edición de las salas. Pero se cambiaron muchos archivos con
    // lo cual se está en MODO TEST.

//  vSimSEESimulador_ = '_ADME105_daa'; // rch@201501241030
  // agrego PostOper Monotonizar para facilitar la comparación entre
  // salidas de salas horarias y de salas de paso de tiempo mayor con postes (semanal, diaria, etc.).
  // Además cambié la forma en que el Esclavizador sub-muestreado sortea en caso de
  // que se no se marque "resumir promediando" ahora usa su propia fuente aleatoria y así
  // no perturaba los sorteos de la esclava. Esto también es para facilitar la comparación
  // de simulación crónicas horarias vs. semanales.


//  vSimSEESimulador_ = '_ADME_1.05da'; // rch@201501222154
// Agrego CONDITIONAL DEFINES en uEsclavizaroSubMuestreado y en uFuenteSintetizador para facilitar debug de sorteos en fuentes sub-muestreadas.
// bugfix en funciones de getEstado y setEstado de los sorteadores uniformes esto podría mejorar la repetitibilidad de las optimizaciones multi-hilo.
// bugfix en calculo de fecha del fin de paso. Esto puede afectar el funcionamiento de los CONTRATOS EN MODALIDAD DEVOLUCION.

  // vSimSEESimulador_ = '_ADME_1.05d'; // rch@201501221946
  // modifico comportamiento de TPostOper_acumularConPisoYTecho
  // para que además de calcular la evolución del acumulado con piso y techo
  // recorte el IngresoNeto cuando actuan el piso o el techo.

  //  vSimSEESimulador_ = '_ADME_1.05c'; // rch@201501051531
  // Se mejora modelo de Hidro con Embalse para cubrir la condición en que
  // iniciando el paso de tiempo en cotas por debajo de las operativas de las
  // turbinas y del vertedero (esto es no puede evacuar agua) el aporte del paso
  // es de tal magnitud que necesita de evaacución para control de crecida.
  // Lo que se hizo fue cambiar el modelo de hidro para estimar los caudales
  // la capacidad de turbinar y de verter en base al volumen final del paso sin Erogado.

//  vSimSEESimulador_ = '_ADME_1.05b'; // rch@201412091917
  // Bugfix. En TFuenteSelector_Horario. Había un bug que impedía la ejecución
  // de las salas con este tipo de fuente.
  // Se agrega Print en SimRes3 para soporte de Sripts R

  // vSimSEESimulador_ = '_ADME_1.05'; // rch@201411251123
  // cambio la PostOper cambioPasoDeTiempo para que funcione
  // también si el el cambio es reduciendo el paso. Tal como estaba
  // solo funcionaba bien si se aumentaba el paso.


//  vSimSEESimulador_ = '_ADME_1.04'; // rch@201411161131
  // Agrego postOpers CVaR, CrearConstante, AcumularConPisoYTecho todas
  // ellas para facilitar el cálculo del Fondo de Estabilización de Energía.
  // También modifico las PosOpers para que sepa como operar con CronVars
  // que sean mono_cronicas o mono_paso.

//  vSimSEESimulador_ = '_ADME_1.03'; // rch@201411080527
  // Bugfix corrijo bug introducido un usalasdejuego en la 1.02 por el cual
  // la fucion de CostoFuturo quedaba NULA salvo para el penúltimo
  // frame temporal.

//  vSimSEESimulador_ = '_ADME_1.02'; // rch@201410271633
  // 1) bugfix en los actores Solar y Eólico la opción "restar para postizar"
  // aplicaba siempre sin importar si el casillero estaba marcado o no.
  // 2) Se agregó en SimRes la posoperación CVaR para facilitar cálculo
  // de parámetros para el Fondo de Estabilización de la Energía.

//  vSimSEESimulador_ = '_ADME_1.01'; // rch@201410030705
  // 1) se agrega opción de imprimir solamentFe variables usadas en
  // Plantillas SimRes3.
  // 2) agrega factores de indexación en Bioembalse
  // 3) SimRes3 Si solo se usan PrintCronVars que no usan Excel no intenta
  // abrir el libro Excel. Esto hace que no sea necesario tener Excel instalado
  // si solo se usan por hitograma_txt como princronvar

//  vSimSEESimulador_ = '_ADME_1.0'; // rch@201409161942

//  vSimSEESimulador = '4.56_regas_prebeta'; // rch@201408262148

//  vSimSEESimulador = '4.55_statera_frictio_'; // rch@201408231804
  // varios cambios en actores asociados a la red de combustibles.

//  vSimSEESimulador = '4.54_statera_frictio_'; // rch@201408182114
  // bugfix. error introducido en la 4.53 impedia cargar salas con
  // algunso cegh; dando error al cargar.

//  vSimSEESimulador = '4.53_statera_frictio_'; // rch@201408101836
  // agrego posibilidad de especificar On/Off por paso en la TV
  // del TGer_Combinado.


//  vSimSEESimulador = '4.52_statera_frictio_'; // rch@201408041721
  // se corrige problema de salvado de fuente de índice en bioembalse

//  vSimSEESimulador = '4.51_statera_frictio_'; // rch@201408021915
  // agrego operación crónica promedioPonderadoConDurPos

//  vSimSEESimulador = '4.50_statera_frictio_'; // rch@201407300123
  // corrección de texto de etiqueta en formulario de edición de Parque Eólico

  //vSimSEESimulador = '4.49_statera_frictio_';
  //rch@201407272310 bugfix. En el editor de fichas de CicloCombinado
  // estaban invertidas las etiquetas de los casilleros de PagoPorPotencia
  // y pago por energía.

 // vSimSEESimulador = '4.48_statera_frictio_';
  // rch@201407261041 Agrego facilidad para cálculo de GradienteDeInversion
  // en los GENERADORES.

//  vSimSEESimulador = '4.47_statera_frictio_';
// rch@201407221423 Bugfix en modelo de CicloCombinado.
// había error en el cargado de la matriz del Paso. Este error afecta
// cualquier sala que estuviera usando esta central.


//  vSimSEESimulador = '4.46_statera_frictio_';
//rch@201407201911 Agrego cv_NoCombustible en generadores térmicos.

//  vSimSEESimulador = '4.45_fatum_statera_';
  // bugfix ... en en actor solar PV. Corrigo error introducido al netear
  // con la demanda.

//  vSimSEESimulador = '4.44_fatum_statera_';
  // rch20140714 mejoro interpolación en transformadores CEGH.

//  vSimSEESimulador = '4.43_fatum_statera';
  // rch@20140705 comienzo a implementar la opción de POSTIZAR en base a
  // una demanda NETA en lugar de por una demanada principal.

//  vSimSEESimulador = '4.42_fatum_';
//  201407031509 BUGFIX. En cálculo de CostoDirectoDelPaso en ugter_basico_PyCVariable
// El actor estaba sumando la energía de los postes en el costo en lugar de la energía
// por el costo de la fuente.


//  vSimSEESimulador = '4.41_fatum_';
//  201406252112

//  vSimSEESimulador = '4.40_garza_';
  // 20140613 bugfix en uFuncionesReales el cálculo de la potencia del
  // Panel no estaba topeado al máximo lo que hacía que diera diferente
  // según que la sala fuera horaria o de paso superior pues el tope se
  // aplicaba vía la restricción de caja y entoces actuaba sobre el promedio
  // en el caso de salas de paso de tiempo superior a la hora.

//  vSimSEESimulador = '4.39_garza_';
  // 20140603 bugfix en uSolaPV en fijación de restricción de caja de la
  // potencia no tenía en cuenta si había más de una unidad.

//  vSimSEESimulador = '4.38_garza_';
  //20140520 cambios en formularios de edición SimRes3 para facilitar entrada

  //  vSimSEESimulador = '4.37_garza_';
  // se agrega que las fichas de parámetros dinámicos se ordenan por FECHA y
  // luego por CAPA de esa forma tendría que ante dos fichas en capas
  // diferenes con la misma fecha (del mismo actor o fuente) prevalecer
  // la ficha de mayor capa.

  // vSimSEESimulador = '4.36_garza_';
  // 1) bug fix en BiomasaEmbalsable. La energía vertida no se inicializaba
  // correctamente al inicio de cada crónica. Esto hacía que si al final
  // de una crónica había vertimiento al inicio de la siguiente se repetía
  // ese valor para la energía vertida.
  // 2) Se agregó también que al resolver los bornes de las fuentes de los
  // actores PyCVariable si el borne NO EXISTE tire una excpción con un
  // mensaje que indica el actor, la fuente y el borne.

  // vSimSEESimulador = '4.35_garza_';
  // rch@201404161514
  // Agrego actor TBiomasaEmbalsable


  //  vSimSEESimulador = '4.34_garza_';
  // rch@20140412
  // Agrego posibilidad de indicar
  // "Imponer todas las potencias iguales" en las hidráulicas de pasada.
  // para un mejor modelado de las mini-hidráulicas en el marco del
  // proyecto ANII-FSE-1-2011-1-6552_ModeladoAutoctonasEnSimSEE.
  // **Bugfix. En THidro de Pasada, el Vertimiento NO estaba valorizado
  // con el costo variable (parámetro puesto en USD/Hm3) en la fila de costo
  // este bug nunca apareció pues nunca se utilizó el modelo de central de pasada
  // con un costo diferente de CERO. En la central de pasada la suma de
  // vertimiento más turbinado suma el caudal entrante (Aportes propios más erogados
  // por otras centrales.

  // vSimSEESimulador = '4.33_bandurria_';
  // rch@20140408
  // Corrección en fecha de guarda Sim para SimRes3.

//  vSimSEESimulador = '4.32_bandurria_';
  // rch@20140406
  // Agrego manejo de FuenteDeEscurrimientos en THidroConEmbalse, THidroDePasada y THidroConBombeo
  // Este agregado es para poder utilizar el CEGH de escurrimientos desarrollado en conjunto con el
  // IMFIA para el proyecto ANII-FSE-1-2011-1-6552_ModeladoAutoctonasEnSimSEE.

//  vSimSEESimulador = '4.31_bandurria_';
  // rch@20140403 BUGFIX-IMPORTANTE
  // En la versión 4.24 se introdujo un error en el tratamiento de las BAJAS
  // de unidades. El error actuaba en unidades con factor de dispnibilidad < 0.55
  // si al momento de dar de baja la unidad se encotraba rota por los sorteos de
  // disponibilidad fortuita. Dada la doble condición de que se encontrase rota
  // al momento de la baja y además que fuese una máquina con disponibilidad < 0.55
  // el bug no se manifestó en las salas de uso común. En la clase del curso de
  // SimSEE (2014-04-03) se analizó una sala en que se bajó a propósito la dispnibilidad
  // de un generador a 0.5 y luego se le dio de baja por 1 día.
  // El bug se manisfestó en que a pesar de darlo de baja en algunas crónicas
  // el generador estaba y se despachaba.


//  vSimSEESimulador = '4.30b_martineta_';
      //rch@20140331  versión - beta -
      // Incluye algunos cambios de Enzo trabajando en los escenarios.
      // también incluye TRobotHttpPost que introduzco para consulta de pronósticos.

//  vSimSEESimulador = '4.30_martineta_';
      //rch@20140315 Agrego "Soporte a Usuarios" en el Menú del Editor.

  //vSimSEESimulador = '4.29_martineta_';
      //rch@20140309 bugfix
      // En ufuncionesReales.pas, en la función
      // function TFf_xmult_conselector_vxy.fval( vx, vy: NReal): NReal;
      //
      // que es usada por ParqueEolico_vxy
      // Habia un erro, si vy = 0  antes simplemente ponía iang:= 0;
      // esto estaba mal, si la componente NoreteSur era CERO
      // imponía viento del Norte cuando lo correcto es viento del Este
      // o del Oeste según la componente vx
      // El impacto podría ser en aplicar un factor de rendimiento equivocado
      // cuando abs( vy ) < 1E-3.

//  vSimSEESimulador = '4.28_terra_';
  // rch@20140306
  // bugfix. En optimización multicore con CAR activada. No estaba intercambiando
  // los histogramas de interpolación en los robots de los hilos.

  //vSimSEESimulador = '4.27_flecha_';
  // rch@20140216
  //   1) Corrigo bug en function Tf_ddp_Weibull.t_area(area: NReal): NReal;
  // de la unidad fddp.pas.  Este bug hacía que las fuentes de Weibull no generaran
  // números con distribución de Weibull. El bug surge al documentar la fuente
  // y no surgió antes pues no ha sido usada. No afecta ninguna Sala de las comunmente
  // usadas.
  //   2) Se agrega parámetro "Fecha de Guarda" en Simulación. Esta fecha es usada
  // para ignorar en los archivos de salida todo lo que sucede antes de esa fecha.
  // se agrega como una forma cómoda de independizarse de la condición inicial.


//  vSimSEESimulador = '4.26_DIENTUDO_';
  // rch@20140102
  // bugfix: TFuenteSelectorHorario no se guardaba bien.

  // vSimSEESimulador = '4.25_DIENTUDO_';
  // rch@20131228
  // bugfix: en procedure THidroConEmbalse.cambioFichaPD;
  // Se corrige que para el cálculo de las constantes de la parábola de
  // las funciones CotaToVolumen y VolumenToCota.
  // Tal como estaba suponía que el h_min era el punto con volumen cero
  // en la tabla de cotas-volumenes.

  //vSimSEESimulador = '4.24_DIENTUDO_';
  // rch@20131228
  // Cambio el manejo de las disponibilidad fortuita. Ahora el AltaConIncertidumbre
  // se especifica por FIcha y por tipo de Unidad.
  // También agregué InicioCronicaConIncertidumbre por ficha y por unidad.
  // Esto permite indicar si al inicio de cada crónica se debe considerar las unidades
  // fuera de mantenimiento como DISPONIBLES o si de debe introducir incertidumbre sobre
  // el estado inicial haciendo un sorteo para representar las probabilidades de estado
  // estacionario.

//  vSimSEESimulador = '4.23_BOA';
// rch@20131221 Milena agrega modelo de planta solar PV.

//  vSimSEESimulador = '4.22_BAGRE';
// rch@20131207 Federico agrega persistencia de las semillas de Sim y Opt y el tipo
// de optimización (PDE o Determinista) a la sala de juego. Yo las agrego al editor.


//  vSimSEESimulador = '4.21_BOGA_';
// rch@20131027 bugfix en THidroConEmbalse y en la activación de escenarios.
// El error hacía que el inicio del control de crecidas quedara incierto
// desde el inicio.

//  vSimSEESimulador = '4.20_BOGA_';
  // rch@20131020 Uniformizo un poco el tratamiento de los PagosPorDisponibilidad
  // y PagoPorEnergia. (no logré uniformizar en todos los actores).
  // Por lo menos se los agregué a los más usados.

//  vSimSEESimulador = '4.19b_BOGA_';
  // rch@20131018
  // bugfix en editor de curvas velocidad-potencia de los parques eólicos.

//  vSimSEESimulador = '4.19_BOGA_';
  // rch@201310152247
  // Cambio tratamiento de datos históricos para que interpole de forma
  // de mantener el promedio.

  //vSimSEESimulador = '4.18_BOGA_';
  // rch@201310141239 - Bugfix. Al agregar los ruidos Wa en la bornera
  // se corrió el indexado de los bornes de las fuentes CEGH.

//  vSimSEESimulador = '4.17_BOGA_';
  // rch@201310131216 - Comienzo a introducir Ruida Multi Retardo

//  vSimSEESimulador = '4.16_BOGA_';
// rch@201310121847
// Agrego radio buttons para definir si usar CVaR o VaR en la optimización
// con Riesgo.
// -> sigo modificando la versión mh (MultiHilo) buscando porqué da diferente
// que la simple hilo. Al parecer el problema era con los CEGH de más de un retardo
// con reducción de estado. El problema estaba en la lectura de la matriz de reducción
// y en la escritura en formato binario del CEGH.
// Atención: Sigue sin estar operativa MatrizRuida para CEGHs multi-retardos.

//  vSimSEESimulador = '4.15_BOGA_';
// rch@201310120931
// bugfix, en simulaciones con series históricas de CEGHs había 2 errores
// 1) El valor de la primer semana se tomara de la crónica
// correspondiente a el número de crónica más la semilla aleatoria (según una opción de compilación)
// pero luego continuaba tomando valores de la crónica asociada al ordinal de la cróncia.
// 2) Al anillar las crónicas se repetía la primer crónica dos veces. Este error no afecta
// a la mayoría de las corridas pues casi siempre se simula la misma cantidad de crónicas
// que las históricas y por lo tanto la repetición no aparecía.

//  vSimSEESimulador = '4.14_BOGA_';
// cambio la versión multihilo para tener mejor control de los hilos.

//  vSimSEESimulador = '4.13_BOGA_';
// rch@201309302315
// bugfix. Editor de Actores fallaba si al crear un actor se intentaba definir unidades sin antes guardar el actor
// este error se introdujo en la versión 4.07 al definir el checkbox AltaUnidades_Con_Incertidumbre

//  vSimSEESimulador = '4.12_BOGA_';
// rch@20130928
// bugfix: en el editor de enganches de CF había un error por el cual
// si bien salvaba los enganches al abrir de nuevo el editor los perdía
// y volvía a poner los valores por defecto.

//  vSimSEESimulador = '4.11_MOJARRITA_';
  //rch@20130925  bugfix. en ploteo de conos de pronósticos. El error
  // fue introducido en la 4.10 y no introduce errores de resultados
  // causaba excepción al intentar plotear los conos de pronósticos de un CEGH.

//  vSimSEESimulador = '4.10_MOJARRA_';
  //rch@20130921  agrego en CalibrarCono de los CEGH que muetre
  // la trayectoria del estado reducido. Esto es para poder ver
  // el estado en el que hay que enganchar en una semanal horaria
  // con la MP de paso diario pero CEGH semanal.

//  vSimSEESimulador = '4.09_MOJARRA_';
  // rch@20130920 queda andando la ejecución de escenarios.

//    vSimSEESimulador = '4.08_TARARIRA_';
  // rch@20130917
  // Mejoro margen en control de crecidas.

//  vSimSEESimulador = '4.07_TARARIRA_';
  // rch@20130910
  // Agrego booleana AltaUnidades_CON_INCERTIDUMBRE en los Actores.
  // El comportamiento por defecto es TRUE y significa que cuando la cantidad
  // de unidades del actor AUMENTA (o sea se dan de alta nuevas o salen de man
  // tenimientos programdos. El alta se raliza CON_INCERTIDUMBRE y significa que
  // pasan al estado "rotas" y estarán disponible con la probabilidad dada por
  // la reparación. Esto es así en los actores que por los parámetros FD y TMR
  // tenga sentido el modelo de FALLA/REPARACION.

//  vSimSEESimulador = '4.06_TARARIRA_';
  // rch@20130824
  // 1) (bugfix_menor)SimSEE_OptSim. La llamada a SimRes3 desde OptSim cambiaba de directorio y luego
  // fallaba la segunda vez por no encontrar el archivo de Plantilla cuando no
  // estaba especificado con la ruta completa. Se corrigió haciendo que vuelva
  // a posicionarse en el directorio de la sala.
  // 2) Se agrega botón Optimización Determinista y se comienza a probar la resolución
  // del problema de despacho determinístico.


//  vSimSEESimulador = '4.04_TARARIRA_';
// Agrego parámetro en las salas ObligarDisponibilidad_1_Opt separando así el
// comporatamiento enter Opt y Sim. Esto es para permitir hacer Optimizaciones
// en las que NO se rompan las máquinas.

//  vSimSEESimulador = '4.03_TARARIRA_';
// Comienzo a introducir forzamientos y habilito que las fechas peudan pornerse
// especificando DateTime (es decir no solo el día, también hh:mm:ss
// esto permite hacer que los parámetros dinámicos valgan desde una hora en particular.

// rch@20130816 ... comenzamos a introducir Los Forzamientos .
//  vSimSEESimulador = '4.02_NUTRIA_';
// rch@20130813
// 1) Modificamos con Enzo la forma de estimar la derivada de CF en los bordes de la discretización
// Ahora, aproxima primero una parábola con los tres puntos más próximos al extremo
// y en base a la parábola calcula la derivada hacia el exterior de la discretización.
// 2) Se agregó en THidroConEmbalse la posibilidad de iterar en la altura del cálculo
// del coeficiente energético para tener en cuenta variaciones de la cota durante el paso
// de tiempo. Esta opción se habilita con un conditional define USAR_APRI  (de usar Aproximación de Integral).
//

//  vSimSEESimulador = '4.01_NUTRIA_';
// rch@20130807
// Modificaciones al Simulador/Optimizador
// agrego Botón LlenarConUltimoFrame en el panel de Optimización
// agrego botón Ecualizar y casillero para fijar la cantidad de pasos.
// Es para probar diferentes formas de las prog. semanal.

//  vSimSEESimulador = '4.00_APEREA_';
// rch@20130801
//   mejoro el funcionamiento del Control de Crecida en THidroConEmbalse
//   agregué un parámetro que permite especificar el Caudal a erogar con el
//   control a pleno. Además, ahora el control tiene en cuenta la duración
//   del paso de tiempo suavisando las variaciones del lago.

//    vSimSEESimulador = '3.99_CAPINCHO_';
    // rch@20130728
    // Agrego fuente TFuenteSelector_horario para perimitir ejecutar corridas horarias
    // con fuentes de precios semanales con definición de precios por POSTES mediante
    // la definición de filtros horarios que seleccionan la fuente y borne adecuado
    // según la hora de inicio del paso.
    // También acomodo la fijación de ls PMIN en THidroConEmbalse en el caso de iteraciones
    // para evitar que PMin de despacho infactible por llegar al fondo del lago.

//  vSimSEESimulador = '3.98_AMBROSIA_';
// rch@20130724
  // Corrigo cálculo de UtilidadDirectaDelPaso que no se reincializaba a CERO en cada
  // paso y se iba acumulando. Este error no afecta resutados salvo el de esa variable.
  // Al corregir ese error verifico también que las utilidades no se consideran en la
  // formación del costo futuro durante la optimización y agrego un CheckBox que sea
  // Restar utilidades de CF que por defecto sea TRUE.


//  vSimSEESimulador = '3.97_AMBROSIA_';
  // rch@20130723

//  vSimSEESimulador = '3.96_PIRINGUNDIN_';
  // rch@20130716
  // Agrego checkboxes en las fichas de parámetros dinámicos de THidroConEmbalse,
  // THidroConBombeo y THidroConEmbalseBinacional para poder deshabilitar el cálculo
  // de la evaporación y del filtrado del lago. También revierto el "alambre" puesto
  // en la 3.94 que se señalizaba con Qa_MuySeco = 0 que no se quería calcular la
  // evaporación del lago.

  // vSimSEESimulador = '3.95_PIRINGUNDIN_';
  // rch@20130715
  // Corrigo actor uMercadoSpot_Postizado, para que el CostoDirectoDelPaso
  // tenga en cuenta los DeltaExportadores.
  // También agrega publicación de variables para SimRes3 de Conector de Combustible y
  // Contrato TakeOrPay asociados al modelado de la regasificadora.

  //  vSimSEESimulador = '3.94_CALIBRANDO_';
  // Enzo agregó que si el Qa_MuySeco es CERO entonces no considera Evaporación.
  // Esto se arregló pues en el caso de Salto Grande, los aportes disponibles
  // ya tienen descontada la evaporación.

//  vSimSEESimulador = '3.93_CALIBRANDO_';
  // rch@20130618
  // bugfix1: en uevapUruguay.pas, la función "InicializarCoeficientesDeEvap"
  //        tenía un bug y usaba las tablas de coeficientes de evap, alreves.
  // bugfix2: en uHidroConEmbalse.pas, la función "THidroConEmbalse.CotaToSuperficie"
  //         devolvía el área en Hm3/m lo que es 1e-6 del valor en m2.
  //         esto tenía como efecto que la evaporación; que se calcula como un
  //         valor en coeficiente expresado en  m/s multiplicado por el área
  //         dava valores despreciables. Ahora la función retorna el valor en m2 como debe ser.

  // vSimSEESimulador = '3.92c';
  // rch@20130606 agrego en uHidroConEmbalse control de NO Desfondar el Lago con
  // caudales negativos.

//  vSimSEESimulador = '3.92b';
  // rch@20130606 cambio formulario edición fichas fuentes simples porque no funcionaba
  // bien el scroll cuando se agregan muchas.

//  vSimSEESimulador = '3.92';
// Se implementa ExpansorRuida cuando la reducción de estado en los CEGH no es completa.

//  vSimSEESimulador = '3.91';
  // rch@20130524 - Cambio operaciones sumaproducto en SimRes3 para que funcionen
  // aunque uno de los índices no sean postizados. Esto facilita cálculos como
  // sumadobleproducto_condurpos para calcular el COSTO de generación al hacer
  // sumadobleproductocondurpos de las potencias con el CV de la máquina.

//  vSimSEESimulador = '3.90';
  // rch@201305161909
  // Agrego evento prepararPaso_ps en los monitores de la optimización.
  // Agrego que al empaquetar se fije si existe archivo con mismo nombre .mon y lo empaquete.

//  vSimSEESimulador = '3.89_UG';
// rch@201305061034
// Se agregan UsosGestionables.
// Bugfix en EMPAQUETAR que no andaba bien con duplicados.


//  vSimSEESimulador = '3.88_CHAOS+++';
// rch@201305011243 - Día de los trabajadores.
// Bugfix en modelo de TArcoConSalidaProgramable que afectaba al Editor.

//  vSimSEESimulador = '3.87_CHAOS++';
// rch@20130423
// corrigo bug en fddp.pas
// function TMadreUniforme.rnd: NReal;
// generaba números que no siempre estaban en entre 0 y 1

//  vSimSEESimulador = '3.86_CHAOS+_GNL_';
// rch@201304111947 bugsfixs
// a) en manejo de la lista de plantillasSimRes3
// b) el modelo ParqueEolico re-publicaba las variables de Potencia.
// -- ninguno de los bugs tiene consecuencias en los resultados --

//       vSimSEESimulador = '3.85_CHAOS+_GNL_';
// corrgimos con AC. sorteos Turbo Vapor en el CC. Revisar actualización sorteos.

//     vSimSEESimulador = '3.84_CHAOS_GNL_beta';
     // rch@201303212337
     // 1) corrigo bug en editor de SimRes3 que mezclaba los índices de las variables.
     // 2) quito mensaje que aparecía al intentar editar el cono de pronósticos de un CEGH.
     // ninguno de los cambios afecta resultados. Son solo cuestiones de "edición".
     // vSimSEESimulador = '3.83_CHAOS_GNL_beta ... no existió.
//    vSimSEESimulador = '3.82_CHAOS_GNL_beta';
    // rch@20130310 le agrego TGTer_ConectableASuministro que calcule el cvm (coso medio para despacho)
    // y lo publique para SimRes3PorDefecto.

//  vSimSEESimulador = '3.81_CHAOS_GNL_beta';
// rch@20130307 bugfix en Simplex. Había un error que ocasionaba un bucle inifinito
// en la resolución de igualdades que termina con una excepción por acceso fuera de
// que se daba en las situaciones en que el Simplex era usado desde un MIPSimplex y
// en condiciones en que en un NODO PADRE resultan redundante restricciones de igualdad.
// Al resolver una rama de ese nodo se producía la condición.

//  vSimSEESimulador = '3.80_CHAOS_GNL_beta';
  //rch@20130306 Integra fuentes desarrollados por equipo de UTE (F.Ron A.Bouvier) de
  // modelo de la regasificadora en el Simulador - Falta agregar en EDITOR.

//  vSimSEESimulador = '3.79_CHAOS_GNLgamma';
    // rch@20130227 BUGFIX en modelo de uger_onoffporpaso ( en la v3.76 quedo un bug que afectaba el cálculo del pago adicional por energía
    // en las onoff por paso. No se inicializaba una variable, con lo cual dependiendo de la suerte, se producía un error de desborde numérico.
//  vSimSEESimulador = '3.78_CHAOS_GNLgamma';
  // comenzamos a agregar actores para modelo de Regasificadora y Suministros de Combustible.
//  vSimSEESimulador = '3.77_CHAOS';
  // Fernanda Maciel &rch@20130225 agrego consideración de las importaciones en el cálculo de los factores de emisiones de CO2
//  vSimSEESimulador = '3.76_CHAOS';
  // rch@20130222 corrigo BUG  en cálculo del CDP de las Térmicas con ONOFFPORPASO.
//  vSimSEESimulador = '3.75_CHAOS';
  // rch@20130218 corrigo BUG en Expansion RUIDA. Intentando hacer andar CEGH_peol7p2MWsem1234_mvar
  // todavía quedan detalles a arreglar para generalizar el uso de la ExpansiónRUIDA.

//  vSimSEESimulador = '3.74_CHAOS';
   // rch@20130216
   // 1) Agrego en algunos actores térmicos el IngresoPorDisponibilidad y IngresoPorEnergia
   // como variables calculadas y publicadas. Habría que genralizarlo a todos los actores.
   // En estos actores el vector "costos" tiene los costos por poste que resultan de los costos operativos
   // considerados para el despacho. Ojo, en versión anterio el vector "costos" incluía los IngresosPorEnergia
   // Este cambio es para separar mejor lo que son costos considerados para el despacho de costos operativos.
   // Hay que pensar como se generaliza esto. Habrá que poner el vector Costos y las variables
   // IngresosPorEnergia e IngresoPorPotencia al nivel de TActor para que esté en todos.
   // 2) En SimRes2 se producía un error (se colgaba el Excel) si en alguna operación se ponen
   // nombres para la hoja con caracteres raros y/o nombres demasiados largos.
   // Para evitar esto, se agregó una función de "purificación" de los nombres de las hojas
   // que quita caracteres raros y cambio espacios por "_".



  // vSimSEESimulador = '3.73_CHAOS';
  // rch@201301224 corrección en el editor para despliegue de actores con muchas unidades.
  //  vSimSEESimulador = '3.71_ANARQUIA_GD'; // rch@201301224 mejora en el cálculo del factor de emisiones BuildMargin y corrección en el editor del listado con información para emisiones.
  //  vSimSEESimulador = '3.70_ANARQUIA_GD'; // rch@20121206 ArcosPostizados y con manejo del peaje en despacho y CDP.

  //  vSimSEESimulador = '3.69_ANARQUIA_EFCM'; // rch@20121203 cambio los arcos para que se pueda especificar
  // PMax, rendimiento y peaje por poste. Esto es necesario para la integración con Flucar.

  //  vSimSEESimulador = '3.68_ANARQUIA_EFCM'; // rch@20121116 completo Posibilidad de cálculo de Factor de Emisiones "Combined Margin".
  // se agrega en el editor el formulario CO2, que permite especificar el cálculo.
  // este formulario contiene un despliege de los generadores para poder especificar facilmente
  // los parámetros de los mismos que intervienen en el cálculo de las emisiones.
  // Se agregó a los generadores un campo booleano que permite indicar si el mismo está
  // aderido a un CDM (Clean Development Mechanism) para considerarlo o no en el cálculo del
  // Build_Margin que luego se utiliza en el calculo del Combined_Margin.

  //  vSimSEESimulador = '3.67_ANARQUIA_EFCM'; // rch@20121110 agrego Posibilidad de cálculo de Factor de Emisiones "Combined Margin".
  //   vSimSEESimulador = '3.66_ANARQUIA_CongPosDispo'; // rch@20121019 agrego además que publicquen la disponibilidad los arcos y de los generadores PyCV

  //  vSimSEESimulador = '3.65_ANARQUIA_CongestiónPositiva'; // rch@20121019 cambio costo de congestión. Ahora es SOLO cuando está activa la restricción del tope.
  // Tal como estaba era la suma de la restricción del tope y la del piso (P=0) y era confuso.

  //  vSimSEESimulador = '3.64_ANARQUIA_'; // rch@20121015 corrigo bug en editor el [VACIAR] limpiaba el cuadro de texto, pero no las variables de la sala
  // que defnian los archivos de enganche. Esto hacía que al empaquetar la sala fallaba por no encontrar el archivo referido.
  // También se acompodó el ZIPPER del empaquetar para que pueda zippear archivos que estén abiertos para lectura.
  // Esto hacía fallar el empaquetado de salas con "demandas detalladas" pues dichas demandas dejan abierto en archivo
  // de datos en modalidad lectura.

  //  vSimSEESimulador = '3.63_ANARQUIA_'; // rch@20121014 Independizo a todos los Actores y Fuentes ... ahora que cada uno se realice como quiera.
  //  vSimSEESimulador = '3.62_RUIDA_ConSesgosOd_CO2_EnganchesProm_Beta'; // rch@20121008 agrego posibilidad de enganches de CF promediando en las dimensiones desaparecidas
  //  vSimSEESimulador = '3.61_RUIDA_ConSesgosOd_CO2_Beta'; // rch@20121005 Uniformiso vector P en los uninodales = Potencia Inyectada.
  // Esto cambió el comportamiento de las variables exportadas de las demandas (antes era la P pretendida consumir)
  // y ahora es la P Neta (Fallas - Demanda Pretendida) = - Demanda Real
  // Además de ese cambio (que es para que sea fácil tener las potencias que irían al FLUCAR
  // se agregó en la clase generador TonCO2xMWh (factor de emisiones) y LowCostMustRun (booleana) para facilitar
  // el cálculo de factores de emsiones.

  //  vSimSEESimulador = '3.60_RUIDA_ConSesgosOd_Beta'; // rch@20120920 cambio en la lectura para que los nombres de campos ignoren entre mayúsuclas y minúsculas
  // esto facilita la modificación manual de los archivos de sala.

  //  vSimSEESimulador = '3.59_RUIDA_ConSesgosOd_Beta'; // rch@20120812 agrego que imprima en SimCosto el CFaux y el CT = cdp+CFaux
  //  vSimSEESimulador = '3.58_RUIDA_ConSesgosOd_Beta'; // rch@20120812 bugfix ufechas setAnio en una fecha si justo mes=2 y dia=29
  //rch20120911  vSimSEESimulador = '3.57_RUIDA_ConSesgosOd_Beta'; // rch@20120811  bugfix en sicronizacion de historicos. En determinada condición
  // en simulaciones horarias con CEGH BPS semanal se tracaba con Excption por una comparación
  // de fechas mal hecha.
  //  vSimSEESimulador = '3.56_RUIDA_ConSesgosOd_Beta'; // Agrego expansion de sesgos en opt RUIDA->Od
  //  vSimSEESimulador = '3.55_RUIDA_Beta'; // Corrige BUG impresion de reales con Formato
  // y además se agrega que en los resultados de simulación "simcosto_SEM_NCRON.xlt" se
  // imprimen los costos directos actualizados y el costo Futuro de final de juego
  // también actualizados. Además de imprimir los costos Totales.
  // También se aegregó que se genera un archivo por crónica en el que los actores
  // con estado escriben su valor de fin de juego. Esto es con el propósito de
  // poder encadenar simulaciones tomando el estado inicial desde el final de otra.

  //  vSimSEESimulador = '3.54_RUIDA_Beta'; // Agrego Expansión RUIDA en modelos CEGH.
  // atención por ahora aplica solo a los casos en que la reducción va a 0 ve.
  // por ejemplo caso modelos horarios de viento.
  // Todavía no aplica a todos pues me tranqué en resolver la raiz de BaBa cuando
  // es semi-definida positiva.
  //  vSimSEESimulador = '3.53'; // agrego posibilidad de Sincronizar con Datos Históricos.
  //  vSimSEESimulador = '3.52beta'; // rch@20120705 Se corrigen FUENTES dependientes de FUENTES
  // para que calculen sus salidadas den prepeararpaso_ps. Antes por eficiencia durante la
  // optimización esto se hacía en SortearEntradasdaRB y ValorEsperadoEntradaRB y el mismo
  // procedimiento Sortear se encarga de calcular las salidas. Pero esto ESTABA MAL pues
  // por ejemplo en la fuente producto, si una de las entradas era un CEGH con estado,
  // al ir posicionando la estrellita (luego de los sorteos del paso) se cambia la salida
  // del CEGH, pero no se recalcula el producto posterior. Por simplicitad se cambiaron las fuentes
  // combinacion, producto, sinusoide, maxmin, selector para que calculen sus salidas en
  // prepararpaso_ps. Esto puede ser ineficiente durante el proceso de optimización si
  // ninguna de las fuentes de entrada a una fuente de ese tipo tiene estado, pero
  // para optimizar este tema habría que ubicar dentro de las fuentes que dependen de una con
  // estado y ponerlas en una lista de "recalcular en prepararpaso_ps". Por ahora más vale
  // ineficiente pero ROBUSTO.

  //  vSimSEESimulador = '3.51beta2'; // rch@20120701 Corrigo bug tonto en modalidad NO usar CAR.
  //  vSimSEESimulador = '3.51';
  // rch@20120626 Agrego menejo de la Aversión Al Riesgo en la programación dinámica estocástica.

  //  vSimSEESimulador = '3.50';
  //rch@20120624 Queda funcionando que los modelos CEGH pueden trabajar con filtro lienal constate (como antes)
  // y además puede tener el filtro lineal variable al igual que los deformadores.
  // Para generar el CEGH variable.
  // Cambio realizado para proyecto del IMFIA (ANII-FSE-31-2009-Mejoras en la simulación de aportes a las represas hidroeléctricas para su incorporación a modelos de planificación energética)

  //  vSimSEESimulador = '3.49';
  // +agrega: modelo TArcoConSalidaProgramable.
  // +mejora: se cambió el comportamiento de THidroConEmbalse para que si está
  // marcado "Valorizado Manual del Lago" igual mantenga las tablas auxiliares
  // de caudal erogado durante la optimización para mejorar la precisión de la
  // estimación del coeficiente energético durante la optimizazión aunque no se
  // considere el volumen embalsado como variable de estado.

  //  vSimSEESimulador = '3.48';
  // corrijo interpolación entre tablas de evaporación en fuente uevapUruguay.pas.
  // Esta corrección es menor. En la interpolación entre las dos tablas de evaporación
  // correspondiente a muy_seco y a muy_humedo había un error que implicaba un pequeño sesgo
  // hacia la tabla de muy_seco.

  //  vSimSEESimulador = '3.47';
  // Elimino el control de monotonía de la derivada introducido enla 3.46.
  // Sencillamente me convencí que la función de Costo Futuro no tiene porqué ser convexa
  // respecto del volumen embalsado. Haciendo una optimización de un sistema muy sencillo
  // con solo una central don embalse con caudal constante, demanda constante y con un único
  // recurso en el sistema de costo constante, el mismo volumen de agua sustituye una cantidad
  // de energía mayor a mayor cota, por lo tanto su valor para el futuro es SUPERIOR a conta
  // mayor y esto implica que la función de costo futuro es CONCAVA para este ejemplo!!.
  // Así que no tiene sentido imponer la monotonía del derivada.
  // En el caso más natural, el sistema tiene muchos recursos y de diferentes valores y
  // por eso resulta natural suponer que si tengo el lago con mayor cota estoy "mejor" y
  // entonces el agua vale menos, pero el contraejemplo anterior es contundente en mostrar
  // que la convexidad de CF no está garantizada.

  //  vSimSEESimulador = '3.46';
  // Agrego control de monotonía de la derivada en la HidroConEmbalse.
  // en funciones de costo futuro en las que la derivada Inc se igualaba a la Dec los errores
  // de truncamiento lograban suvertir el orden y eso ocasiona inestabilidad en el algoritmo de
  // programación dinámica estocástica.

  //  vSimSEESimulador = '3.45';
  // Corrijo chequeo de Turbinado y Bombeo simultaneo
  // en las HidroConBombeo. El chequeo estaba mal pues verificaba la suma de los
  // turbinados y bombeos de los postes, y detectaba como error situaciones
  // en que el bombeo se realiza en un poste y el turbinado en otro.

  //  vSimSEESimulador = '3.44';// Agrego modelo de Banco de Baterías.
  //  vSimSEESimulador = '3.43';// comento lecutra del filtrao de crónica introducido en la v341 todavía no está listo
  //  vSimSEESimulador = '3.42';// corrigo bug. Luego de leer un CEGH impongo la cantidad
  // de retardos de los pronósticos igual al del modelo de simulación.
  // tal como estaban eran independientes y si creaba una sala con un modelo
  // de varios retardos luego aunque cambiara el modelo la cantidad de retardos
  // de los pronósticos seguía con la del modelo inicial.

  //  vSimSEESimulador = '3.41';//  rch+20120524 v3.41 agrego filtrado global de cróncia en SimRes3 (EN PROCESO)
  //  vSimSEESimulador = '3.40';//  rch+20120426. v3.40
  // Agregué en el cálculo del máximo volumen exigible en las restricciones de erogado
  // mínimo que tenga en cuenta además del volúmen embalsado y los aportes, la capacidad
  // de extraer ese volúmen mediante turivinado+vertido. Tal como estaba no se hacía
  // ese control y en situaciones en que el lago se encuentra por debajo del vertedero
  // si se le pedía un erogado por encima del máximo turbinable no lo lograba.
  // Ahora, para determinar si puede cumplir con una condición de Erogado Mínimo,
  // Limita el volumen de la condición a no superar ni el volumen
  // embalsado + Aportes - pérdidas del paso ni el máximo volumen erogable
  // (turbinado + vertido). En esta versión se agregó el control del volumen erogable.

  //  vSimSEESimulador = '3.39'; // rch@20120419 Se corrige bug en ucalibradorpronosticos.pas. El error afectaba la visualización de los conos de pronósticos
  // en el caso de fuentes CEGH con NRetardos > 1. En ese caso se visualizaban los valores en el mundo gaussiano del estado en k-1.
  // y no la salidas en el mundo real en el instante k como debía de ser. Esto no afecta resultados de simulación, solo lo que se visualizaba
  // en el calibrador.
  //  vSimSEESimulador = '3.38'; // rch@20120414 Recompilo para que cmdsim escriba los resultados detallado de simulación y no solo el costo
  //  vSimSEESimulador = '3.37'; // rch@20120329 Corrige error en Imprimir Matriz de Datos de SimRes3 que fallaba si se marcaba graficar
  //  vSimSEESimulador = '3.36'; // Se agregaa la fuete aleatoria "selector(A; B, C, D ) donde s

  //  vSimSEESimulador = '3.35'; // Corrige error en la determinación de la cantidad de años para simulación con series históricas.
  //  vSimSEESimulador = '3.34'; // Corrige confusión por BOM en archivos de texto. Por alguna misteriosa razón empezarona aparecer 3 bytes al inicio de los archivos que confunde la lectura de la versión.
  //  vSimSEESimulador = '3.33'; // Corrige bug en Edtior SimRes3 que ocurría al cambiar el actor de un índice.
  //  vSimSEESimulador = '3.32'; // Corregimos error de lectura de las PrintCronVar_CompararMultiples_cronvar introducido en la v3.31
  //  vSimSEESimulador = '3.31'; // Agrego a SimRes3 PostOperaciones MultiOrdenar y MultiPromedioMovil. También agrego a los PrintCronVars, la posibilidad de
  // de indicar si hacen un Pre_Ordenar (como ya lo hacian) para imprimir resultados probabilísticos o no.
  // También si los resultados probabilísticos son ProbabilidadesDeExcedencia (como hasta ahora) so son ValoresEnRiesgo
  // la diferencia es que en un caso imprime el valor que es exedido con cierta probabilidad pero en el caso de ValorEnRiesgo imprime
  // el promedio de los valores entre los límites de ProbDeExcedencia.
  //  vSimSEESimulador = '3.30'; // se corrige lector de TFuenteSintetizador para solucionar lectura de version v54
  //    vSimSEESimulador = '3.29'; // cambios en las funciones de fecha para diferenciar entre semanas en base 52 o semanas de 7 días.
  //  vSimSEESimulador = '3.28'; // arreglo tamaño de venta exportar actores del editor
  //  vSimSEESimulador = '3.27'; // Cambio sorteo para resumir borneras en esclavizador sub-muestreado a "sorteos delpaso" para que sea independiente del estado
  //  vSimSEESimulador = '3.26'; // manejo de CFAux en editor agrego posibilidad de borrado
  //  vSimSEESimulador = '3.25'; // arreglo error de manejo de CFAux

  //  vSimSEESimulador = '3.24'; //1) agregamos que la semilla aleatori se inicial al principio de cada
  // crónica como semillaInicial+kCronica
  // 2) se corrigió que si se marca "Escribir Archivos Opt Actores" deshabilite la posibilidad de correr multi-hilo

  //    vSimSEESimulador = '3.23'; // Acomdamos orden de graficado en CompararVariables de SimRes3
  //    vSimSEESimulador = '3.22'; // Agregado de botón "Borrar Sesgos" en fuentes CEGH
  //    vSimSEESimulador = '3.21'; // MinHOrasOn y MinHOrasOFF en las Térmica con costo de arranque/parada
  //    vSimSEESimulador = '3.20'; // Actores con varias tipos de unidades
  //  vSimSEESimulador = '3.19 beta'; // Postizado del actor TMercadoSpot.
  //  vSimSEESimulador = '3.18 beta'; // Mejora del cálculo de la matríz B de los CEGH.
  vSimSEEEdit_ = vSimSEESimulador_;
  vSimRes3_ = vSimSEESimulador_;
(*
El log de cambio de versiones está en:
http://iie.fing.edu.uy/simsee/ayuda/ayuda.php?hid=versiones&titulo=versiones#

por favor mantener actualizado ese log.
El log debe contener la descripción del cambio de versión desde el punto
de vista del usuario de la plataforma SimSEE y no el detalle
de los cambios en la programación (los cuales si son relevantes deben quedar
como comentarios DENTRO DE LOS FUENTES con el formato
autor@FECHA:comentario.
*)

implementation

end.

