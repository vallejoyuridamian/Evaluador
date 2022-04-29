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
  // Se implement� que el Esclavizador llama los m�todos de la esclava.


//   vSimSEESimulador_ = '_160';
  // rch@20170826 Bugfix, se hab�a deshabilitado el funcionamiento de "sincronizar con hist�ricas"
  // para el caso de simulaci�n con series hist�ricas. Se vuelve a habilitar.

//  vSimSEESimulador_ = '_159';
  // rch@20170713 Bugfix, en el manejo del CFAux en la simulaic�n hab�a
  // dejado de funcionar correctamente impidiendo leer la variable en
  // SimRes3.

 //  vSimSEESimulador_= '_158';
  // rch@20170703 Cambiamos par�metros en Central Solar PV. Ahora se especifica
  // la Potencia de Pico para 1000 W/m2 a 25C y las p�rdidas el�ctricas (cableado+trafo+inv)
  // y la Potencia m�xima de Inversor. Todo por MODULO.
  // rch@20170627 Bugfix en usolarpv daba error si se pon�a PMax = 0 en la ficha din�mica
  // de par�metros.



//  vSimSEESimulador_= '_157';
  // rch@20170606
  // 1) Bugfix. Fuente selector Horario. Le faltaba inherited Create a la clase y eso
  // hace que se rompa el mecanismo de persistencia por lo cual no se salvava.
  // 2) elimino el nilonclose de los trazosxy porque aveces daba error
  // en calibrar cono.
  //

//  vSimSEESimulador_= '_156';
  // rch@201705261629 bugfix fddp.TMadreUniforme.randomIntRange ten�a un error
  // por lo cual los extremos del rango ten�an una probabilidad de ocurrir 0.5 de la
  // del resto de los puntos del rango. Este bug queda totalmente soslayado por el que se
  // comenta a continuaci�n. El sorteo de enteros se utiliza en el resumir (sin promediar) pero
  // el segundo bug es el que realmente cambia los valores.
  // rch@201705291012 bugfix GRAVE. Hab�a un error en el resumen de las fuentes esclavizadas
  // en un sub-muestreo que hac�a que al usar en conjunto con NETEAR PARA POSTIZAR se crear�
  // un sesgo en la elecci�n del representante del poste en los generadores resumidos (e�lica, solar)
  // hacia el lado de privilegiar las horas de mayor demanda neta lo que es lo mismo que sesgar hacia
  // una menor generaci�n de las renovables.

  // vSimSEESimulador_= '_155';
    // rch@20170516
    // bugfix en exportaci�n a ods de las fichas din�micas de fuentes.

//   vSimSEESimulador_= '_154_ods';
  // rch@201704240835
  // Cambio la exportaci�n/importaci�n de Excel a que guarde/lea un archivo .ods
  // y luego lo abra con la funci�n opendocument() para asegurar que abra el archivo
  // con la aplicaci�n que tenga instalada para ese prop�sito. Este cambio fue necesario
  // pues en FING el estandar es LibreOffice (u OppenOffice) y no hay Excel instalado.

  // vSimSEESimulador_= '_153_Barumi';
  // rch@20170314 bugfix 1) en editor de fichas hidro con embalse e hidro con bobmeo
  // el bug imped�a marcar la imposici�n de erogado m�nimo por poste salvo que se hubiera
  // marcado activar la restricci�n de QTMin. Ahora lo permite si cualquiera de las restricciones
  // QTmin o QTmin_falla est� activada.
  // bugfix 2) en c�lculo de GRADIENTES DE INVERSION. En la versi�n 149 se separ� del c�lculo del
  // Costo Directo del Paso de los actores y falt� considerar este cambio en el c�lculo de los
  // Gradientes de Inversi�n. Esto afecta los resultados de salas que tuvieran marcado ese resultado
  // y el error salta a la vista pues los gradientes dan POSITIVOS por faltar restar los pagos por
  // Potencia y Energ�a.


//  vSimSEESimulador_= '_152_Taslimah';
  // rch 20170309 Agrego manejo de Unidades (Inverson/Rectificador/Celda) a los bancos
  // de bater�a y PagoPorDisponibilidad_USDxMWhh a los bancos de bater�a.
  //

  //  vSimSEESimulador_= '_151_Taslimah';
  // rch@201702051020 BUGFIX *****
  // Hab�a un error que hac�a que se leyera mal (desplazada) la Pol�tica de Operaci�n
  // en salas donde las fechas iniciales de Simulaci�n y Optimizaci�n NO-COINCIDIAN.
  // El error impacta en resultados de Salas en que las fechas iniciales de Opt y Sim
  // no coinciden.
  // Adem�s se agreg� como variable persistente el HusoHorario_UTC para que SimSEE
  // pueda funcionar adecuadamente con en otras ubicaciones. Por Defecto el HusoHorario_UTC = -3 (Uruguay)


//  vSimSEESimulador_= '_150_Jessenia';
// jf@20161221 (revisi�n 1935 de uhidroconembalse)
//BUGFIX: Se corrige error en el par�metro que se le pasaba a la funci�n que calcula
//el erogado m�nimo de la central seg�n el volumen embalsado (ErogadoMinimo_Ctrl_Crecida). En la versi�n anterior
// (revisi�n 1928 de uhidroconembalse) se llamaba a la funci�n con el vol�men sin erogado Vs_SinErogado (volumen inicial paso+aportes-perdidas)
//sin considerar que dentro de la funci�n se sumaban los aportes-perdidas . Esto ocasionaba que
//la central aplicara el control de crecida para un vol�men superior al real y por tanto hiciera
//un erogado superior al establecido en las curvas de vertido de la central.


//vSimSEESimulador_= '_149_Tharaa';
// rch@20161216
// 1) Cambio forma de leer las Cosas de forma de obligar la lectura en orden
// de los par�metros. Esto quita flexibilidad pero va a simplificar la migraci�n a otras
// formas de lectura (por ej. v�a web o db).
// 2) Agrego variable: flg_IncluirPagosPotenciaYEnergiaEn_CF a TSalaDeJuegos
// para controlar si se suman o no a CF los IngresosPorDisponibilidad e IngresosPorEnergia de los Actores
// En la implementaci�n anterior estaba que SI, los sumaba. Ahora se deja la opci�n
// QUEDA PENDIENTE DE REVISAR LA CONSIDERACION DEL PEAJE EN LOS ARCOS (el�ctricos y combustibles)
// EN la implementaci�n actual (y anterior) el PEAJE se considera para el dspacho del paso y
// es opcional si se contabiliza para el Costo Directo del Paso (y por tanto en el Costo Futuro) y si
// se marca en el arco que se considere, se permite indicar un factor de consideraci�n.
// En la versi�n actual, se opt� por hacer que se reproduzca el comportamiento anterior pero hay que revisar.


//  vSimSEESimulador_= '_148b_Yasira';
  // rch@201612140740 BUGFIX de bug introducido en el proceso de debug de la 148
  // Se hab�a eliminado la l�nea que cargaba los aportes de las hidro con embalse
  // por lo cual le quedaban los aportes en CERO.


  // vSimSEESimulador_= '_148_Yasira';
  // rch@201612131232
  // BUGFIG en THidroConEmbalse. No se inicializaba adecuadamente le variable h_real
  // en Sim_CronicaInicio. Esto ten�a como consecuencia que calculara mal las p�rdidas
  // por filtraci�n y evaporaci�n en el primer paso y ten�a como consecuencia que daban diferentes
  // las simulaciones MONO-HILO de las MULTI-HILO. Las diferencias eran muy menores por
  // tratarse de las p�rdidas del lago en un solo paso de simulaci�n.

//  vSimSEESimulador_= '_147b_Yasmin';
  // rch@201612111813
  // 1) BugFix varios en los gr�ficos de �reas apiladas de SimRes3 tanto en formato
  // html como a Excel. (tema del ejex cuando el paso de tiempo es horario).
  // 2) Mejora la exportaci�n de SimRes3 a scripts R, Octave y Matlab (ROM)
  // Ahora exporta las CronVars a archivos nombre.csv y en otro archivo
  // con nombre_def.csv salva la inforamci�n de la CronVar, como nPasos, nCronicas
  // y la fecha de la primera muestra. De esta forma se facilita a los scripts
  // ROM a leer por separado la matriz de datos y la informaci�n auxiliar si
  // la requieren.

  // vSimSEESimulador_= '_147_Yasmin';
  // rch@20161209
  // 1) Enganches entre salas mediante Evaluador de Expresiones.  (Beta)
  // Se agrega posibilidad de enganchar salas con transformaci�n de variables de estado.
  // Para ello se agreg� en el Editor de Enganches (todav�a versi�n beta) la posibilidad
  // de definir expresiones del tipo $Y_NombreVar := Expresi�n; d�nde
  // Exprsi�n es uan expresi�n que puede incluir nombres de variables del tipo $X_NOmbreVar
  // Siendo las varialbes $X_NombreVar las variables de la Sala QUE ENGANCHA y $Y_NOmbreVar
  // las variables de estado de la sala A LA QUE SE ENGANCHA (la del futuro).
  // A TParticipanteDeMerado se le agreg� un m�todo que le permite agregar FUNCIONES al Evaluador
  // de expresiones, de esa forma se consigui� en forma gen�rica que cualquier modelo pueda plantear
  // transformaciones a realizar en el enganche entre salas. En particular, este mecanismo se
  // desarrollo para que la central binacional con embalse pueda traducir la DiferenciaDeEnerg�aEmbalsada
  // y el volumen de la central a un VOlumenVIsto en las salas de m�s largo plazo a las que se engancha.
  // 2) BUGFIX. en versi�n Multi-hilo del Simulador (bot�n agregado recientemente) hab�a un error
  // por el que no se estaba imponiendo el OBLIGAR_DISPONIBILIDAD_1 en la simulaci�n MULTI-HILO.
  // Esto hac�a en las salas en que se hab�a marcado OBLIGAR_DISPONIBILIDAD_1 que los resultados
  // entre las simulaciones Mono-HIlo y Multi-Hilo difirieran (las multi no obligaban la disponibilidad).

  //  vSimSEESimulador_= '_146_Yakootah';
  // rch@201611302127
  // 1) BUGFIX. Se corrige error del Editor por el que fallaba la importaci�n
  //   desde Excel de fichas de par�metros din�micos.
  // 2) Se corrige error en el editor que imped�a la edici�n del valor de los
  //   enganches de la funci�n CF.

  // vSimSEESimulador_= '_145_Yakootah';
  // rch@201611241822
  // Implemento que las Demandas tengan en cuenta las UNIDADES.
  // Esto se hizo para poder incluir en una sala demandas auxiliares que se
  // habilitan o des-habilitan seg�n el Escenario.

  // vSimSEESimulador_= '_144_Yakootah';
  // rch,fp,ps@201611241145
  // Bugfix en THidroConEmbalse, el polinomio de c�lculo de QE para control de crecida
  // pod�a dar negativo si el volumen superaba ampliamente los valores de calibraci�n
  // se corrigi� para que si V > VmaxControl el erogado sea el establecido en VMaxControl.

  // vSimSEESimulador_= '_143_Zafira';
  // rch@201611181625 ... comenzamos pruebas de introducci�n de pron�sticos en
  // programaci�n de corto plazo por medio de GUIA PE50 en CEGH.

  //vSimSEESimulador_= '_142e_Zahira';
  // rch@201611072153
  // BUGFIX en uauxiliares agrego una TCrticalSection para el manejo de
  //    SetSeparadoresGlobales y SetSeparadoresLocales
  //    en la simulaci�n multi-hilo esto traia problema en el clonado de
  //    fichas din�micas que terminaba confundiendo fechas y fallando dependiendo
  //    de la velocidad de la m�quina.

  //  vSimSEESimulador_= '_142d_Zahira';
  // rch@201611071944
  // BUGFIX en editor de SimRes3, en detecci�n de variables por poste se pod�a
  // producir una condici�n de error seg�n el nombre de la variable.
  // Tambi�n se recompila para que las fuentes PUBLIQUEN la bornera cosa que se
  // hab�a deshabilitado.

  //vSimSEESimulador_= '_142c_Zahira';
  // rch@20161014
  // BUGFIX_1, MultiOrdenar ordenaba una cr�nica m�s de las existentes. (range check error)
  // BUGFIX_2, Enventalar se creaba con una cr�nica menos de las necesarias. (range check error)
  // Se agragan CONDITIONAL DEFINES en uHidroConEmbalse para deshabilitar/habilitar cambios
  // realizados por FP, respecto a limitar la QEm�x en las iteraciones de las hidr�ulicas
  // y en el c�lculo de la QEm�n por control de crecida para facilitar comparaciones de
  // cambios que est� implementando FP en el agregado de una restricci�n de QEmin con
  // penalidad por incumplimiento.

  // vSimSEESimulador_= '_142b_Zahira';
  // 201610121925
  // BUGFIX_1, al finalizar Optimizacion MultiHilo al hacer Free de las salas
  // pod�a ocurrir que dos salas hieran Free del mismo archivo CEGH.
  // ahora antes de hacer haen un lock de una criticalsession.
  // este bug hac�a que en algunas optimizaciones multihilo
  // se colgara al finalizar.
  // BUGFIX_2, en SimRes3, hab�a un error al determinar la secuencia de cr�nicas
  // en archivos de simulaci�n multi-hilo. El error hac�a que fallara el SimRes3
  // con una excepci�n indicando que los archivos de resultados no corresponden
  // con un conjunto consecutivos de cr�nicas.
  // La correcci�n de estos bugs no cambia ning�n resultado. Ambos bugas simplemente
  // hacian que se colgara la Optimizaci�n (multihilo) o la ejecuci�n de SimRes3
  // en forma aleatoria.

  // vSimSEESimulador_= '_142_Zahira'; //fb&ps@20160923
  // BUGFIX en SimRes3 -> PostOper -> MultiOrdenar operaba fuera de rango.
  // Se agregan cuatro PostOpers: Recronizar, Ventanar, Transponer y AcumCon

  //vSimSEESimulador_= '_141_Zahara'; //jfp@201609131011
  //Se corrige tope de potencia m�xima en iteraciones en uhidroconembalse que
  //produc�a turbinados mayores que los m�ximos de las turbinas. Dicho tope estaba
  //seteado como la semisuma entre la potencia generada por la central y
  //el tope en la iter anterior, pero no se chequeaba que fuera inferior
  //a la potencia m�xima generable por la central el la iteracion actual. Para corregir el error
  //se minimizo el tope con la potencia maxima generable por la central que se actualiza
  //seg�n coeficiente energ�tico de cada iter.

  //vSimSEESimulador_= '_140_Zareen';    // rch@201609081141
  // Se agrega opci�n en Operaci�n Cr�nica SumaDobleProductoConDurPosTopeado para facilitar
  // c�lculo de ingreso en horas cr�ticas
  // Se mejora cambios realativos a ls simuaci� MultiHilo
  // se Pasa a versi� 64bits con lo que se reduce del orden de 30% el tiempo de optimizaci�n
  // y adem�s se levanta la restricci�n de que el proceso no pod�a solictar m�s de 2Gb al sistema
  // lo que imped�a la simulaci�n/optmizaci� de salas horarias de varios a�os y adem�s imped�a
  // la confecci�n de plantillas SimRes3 de muchas variables para manejo de esas salas.

  //vSimSEESimulador_= '_139_Zarifah';
  // Correcciones a SimRes3 intentando que pueda leer los archivos de salidas de simulaci�n
  // tanto en formato viejo (un archivo) como en el formato nuevo introducido en la versi�n
  // anterior.

  //vSimSEESimulador_= '_138_Zaina';
  // rch@20160830  .. Se habilita la Simulaci�n Multihilo. Ahora los resultados de simulaci�n
  // se reparten en varios archivos  por ej: simres_31_Base_d00026a00050h0.xlt
  // donde, 31 es la semilla, "Base" es el escenario, d00026 a00050 indica el rango
  // de cr�nicas de simulaci�n que incluye ese arcivo (de la 26 a la 50) y h0 indica que
  // ese archivo lo gener� el Hilo 0. (los hilos se numeran de 0, a N-1).

  // vSimSEESimulador_= '_137d_Zurah';
  // rch@201608221638 vuelvo a habilitar la escritura buffereada a Excel
  // es notoria la diferencia de velocidad de escritura.
  // Esta forma de escritura se hab�a deshabilitado cuando se implement� la versi�n
  // de salida en html ahora la vuelvo a habilitar.

  //vSimSEESimulador_= '_137c_Zurah';
  // rch@201608220739 bugfix: en Editor. Error al clonar fichas.
  // bugfix: se colgaba al simular con hist�ricas por no haber sorteado los
  // Escenarios.


//  vSimSEESimulador_= '_137b_Zurah';
  // rch@201608191000 bugfix en el Edtior. Se romp�a al intentar editar unidades
  // por error introducido en versi�n 136.

//  vSimSEESimulador_= '_137_Zurah';
  // rch@201608181208
  // en umadresuniformes procedure TMadresUniformes.Reiniciar( NuevaSemilla: integer );
  // hice cambio para que la generaci�n de semillas no tenga desborde num�rico
  // lo que ocurri� en simlaciones largas horarias de 1000 cr�nicas.
  //
  // rch@201608120711
  // 1) Se mejora el tratamiento multi-hilo de la simulaci�n separando
  // el mecanismo de clonaci�n de cosas. Tal como estaba interfer�an entre si los hilos
  // durante la simulaci�n pues la expansi�n de fichas din�micas incluye clonaci�n de
  // las misma en caso de fichas per�odicas. En la Optimizaci�n esto no era un problema
  // pues la expansi�n de las fichas y preparaci�n de las salas se realiza antes de
  // inciar la Optimizaci�n. En la Simulaci�n se trat� de paralelizar tambi�n la preperaci�n
  // de las salas y surgi� el problema.
  // 2) En versiones recientes se habilit� expresamente que las fuentes CEGH exporten toda
  // la bornera lo que hace que los archivos de simulaci�n sean bastante m�s voluminosos
  // y por eso es muy importante marcar "publicar solo variables usadas en SimRes3". Una
  // vez marcado este checkbox, al preparse para simular, la Sala deb�a leer las plantillas
  // SimRes3 para obtener el listado de variables a plublicar. Esta LECTURA de plantillas
  // al inicio de las simulaciones trajo aparejado dos problemas cuando la simulaci�n
  // se ejecuta desde l�nea de comando: a) Las Plantillas con operaciones que implican
  // GRAFICOS no son leibles en aplicaciones de l�nea de comando y b) La informaci�n de
  // la ruta de la Plantilla SimRes3 debe ser completa para habilitar su lectura.
  // Estos dos inconvenientes surgieron al intentar ejecutar la simulaci�n multi-hilo
  // en el CLUSTER y dio lugar a este cambio de versi�n. Se implement� que en la
  // lectura de las plantillas para determinar las variables a publicar s�lo se lee hasta
  // el listado de �ndices eviantando por tanto leer las operaciones (y evitando as�
  // el error por intentar leer un tipo de operaci�n gr�fico en el entorno de consola)
  // Con respecto a la ubicaci�n de los archivos de Plantilla se utiliz� el mismo criterio
  // que con el resto de los archivos asociados a una sala que consiste en buscarlo en
  // su ubicaci�n origial, en el directorio de ejecuci�n y en el directorio de la Sala.


  // vSimSEESimulador_= '_136_Escofina';
  // rch@201608031459 bugfix. Se fija error de p�rdida de memoria que imped�a ejecutar
  // optimizaciones/simulaciones horarias de m�s de un a�o.


  //vSimSEESimulador_= '_135_Congorosa';
  // rch@201607271335 bugfix en manejo de borneras de fuentes esclavizadas en subsorteo.
  // AL cambiar de paso estaba quedando en la bornera el RESUMEN del paso anterior y eso hac�a
  // que no coinicidieran las salidas si la misma sala se simulaba conpaso horario.
  // El resultado era estad�sticamente correcto en el sentido que al inicio del paso se estaba
  // usando un valor que era el resumen (promedio o m�xvar) del paso anterior pero imped�a la
  // comparaci�n entre salas de paso semanal y horario.
  // Adem�s se implement� que los CEGHs se cargan una vez y se comparten entre los threads
  // para el caso de las corridas multihilo lo que aumenta la eficiencia en los tiempos de
  // inicializaci�n y finalizaci�n y adem�s consume menos memoria.

//  vSimSEESimulador_= '_134b_Rienda';
  // rch@201607251807 bugfix en inicializaci�n de escenarios by F.Barreto.

//  vSimSEESimulador_= '_134_Rienda';
  // rch@201607220018 Cambio la forma de hacer el sorteo de ResumirBorneras en
  // uEsclavizadorSubMuestreado para que para todos los borners asociados a un mismo
  // poste el sorteo sea el mismo. Esto se cambi� para que si se conectan dos actores
  // al mismo borne y se est� utilizando el Resumir por m�xima varianza, ambos actores
  // vean lo mismo aunque usen un borne calculado.

//  vSimSEESimulador_= '_133_Bozal';
// rch@201606020757 bugfix se corrige error en el calibrado de conos de pron�sticos
// introducido en versiones anteriores al trabajar sobre la definici�n de "escenarios de pron�sticos"
// Lo que hice fue volver al c�digo viejo hasta que revisemos el nuevo.

//   vSimSEESimulador_= '_130_Rebenque';
  // rch@201605172047 bugfix_cursoSimSEE2016. En  TActorBancoDeBaterias01 estaba mal el signo del
  // valor de la energ�a almacenada cv_MWh = - dCF/dX  (faltaba el "-")

 //  vSimSEESimulador_= '_129_Sobeo';
  // rch@201605111013 deshabilito el conditionaldefine SPXMEJORCAMINO en usaladejuegos.
  // Me parece que el uso del SPXMEJORCAMINO al "recordar" el camino de resoluci�n del MIP_Simplex
  // puede causar diferencias entre el c�lculo distribuido y el no distribuido (o entre el MultiHilo
  // y el Mono Hilo). Esas diferencias de existir tendr�an que ser m�nimas, pero para facilitar las
  // comparaciones de corridas deshabilito esta opci�n.

//  vSimSEESimulador_= '_128_Tia';
  // rch@201603090654  bugfix en Fuentes Reales asociadas al Actor PVSolar
  // El bug fue introducido el 14/2 al introducir en globs de SimSEE la variable
  // HUSOHorario y por tanto afecta los resultados de corridas que tuvieran el Actor Solar PV
  // realizadas con binarios compilados con posterioridad a dicha fecha (versiones 128_Prima y 128_PrimaPrima)

//  vSimSEESimulador_= '_128_PrimaPrima';
  // rch&fb 201603041231  bugfix en Editor de FUentes CEGH. No permit�a cambiar el pron�stico.

  //vSimSEESimulador_= '_128_Prima';
  // rch 20160216 cambio en sorteo de fuentes CEGH para que si tiene un solo escenario NO sorte escenario
  // y as� no afecte los sorteos de los Ruidos Blancos Gaussianos (RBG). EN futura versi�n esto se soluciona
  // con dos fuentes independientes de sorteso, una para los escenarios y otra para los RBG.
  // Tambi�n se agreg� un CheckBox "Modo Comparaci�N" en la Operaci�n Cr�nica
  // SumaDobleProductoConDurPosTopeado si el checkbox= false hace lo mismo que ahora si
  // est� a true lo que hace es poner en el resutado el producto con durpos cuando el marginal est� por
  // debajo del tope en el resultado y en el recorte cuando est� para arriba. Esto tiene utilidad para
  // determinar la energ�a entregada por un generador por debajo y por encima de un determinado valor
  // por ejemplo para determinar la energ�a entregada en situaci�n de excedentes de costo variable nulo poniendo
  // el umbral por encima del precio de la exportaci�n "sumidero" de excedentes.


//   vSimSEESimulador_= '_128_Estribo';
  // rch 20151211 cambios en uPrint.pas bugfix en definici�n de tipos de series en los gr�ficos.

//  vSimSEESimulador_ =  '_127_Cabresto';
// rch 20151204 cambios en uescala.pas para mejorar c�lculo de escalas autom�ticas para graificas SimRes3

//  vSimSEESimulador_ =  '_126_Sobre-Cincha';
  // rch@201511080726 cambios en el editor para serpar la MIGRACION_PERSISTENCIA
  // del editor que est� en producci�n por problemas para Exportar fichas contantes
  // a Excel.
  // Agrego posibilidad de condicionar la disponibilidad de un Arco al valor
  // de una fuente.

//   vSimSEESimulador_ =  '_125_Badana';
 // rch@201510201014 hago cambio en ucmdoptsim para que funcione la definici�n de
 // un directori temporal de corridas diferente del de la sala. Esto puede traer problemas
 // en archivos que no tengan la ruta completa. En el caso de los archivos de DemandaDetallada
 // se solucion�, pero pueden quedar otros. Este cmabio no afecta el SimSEESimulador
 // solo afecta a los de l�nea de comando

//  vSimSEESimulador_ =  '_124_Pelego';
  // rch@20151001
  // BUGFIX IMPORTANTE. Hab�a un error "desde el origen del SimSEE" que hac�a que
  // el actualizador de fichas de par�metros din�micos "no viera" la ficha que le
  // quedara en la posici�n 0 (Cero).
  // Esto tiene consecuencias o no dependiendo de la suerte que hubiera tenido en que
  // la primer ficha din�mica fuera relevante o no. Este bug afectaba solamente la OPTIMIZACION.
  // El lugar de las fichas LPD depende del resto de las fichas y del orden de insersi�n de los
  // Actores. Esto llevaba a comportamientos extra�os como que por agregar una ficha en un actor
  // cambiaba el comportamiento de otro, por sustituirlo en el casillero "no visto".


// vSimSEESimulador_ = '_123_Cincha';
// Se agrega control en la resoluci�n de bornes de las fuentes para que NO permita la ejecuci�n
// si hay bornes sin resolver. Esto es para prevenir errores del editor. (O de la edici�n manual de salas).

 //  vSimSEESimulador_ = '_122_Basto';
 // Incorpora cambios de Felipe sobre la hidro con embalse binacional.(todav�a beta)

//  vSimSEESimulador_ = '_121_Carona';
  // rch@20150901 BUGFIX IMPORTANTE: En la optimizaci�n MULTIHILO hab�a un error
  // de dise�o por el cu�l si se corr�an m�s de una Optimizaci�n MultiHilo en simult�neo
  // en la misma m�quina los procesos se interfer�an. El error ven�a por los Eventos
  // creados en la unidad umh_sincrodata que ten�a nombre que no identificaba el
  // proceso en forma �nica con lo cual los Workers de una optimizaci�n se�alizaban
  // tarea entregada en todas las lanzadas en forma simult�nea. El error no afecta los
  // resultados de las optimizaciones Multihilo si se ejecutaba una sola.

//  vSimSEESimulador_ = '_120_Jerga_';
  // Asociada al cambio de VERSION_ArchiTexto = 133; // df,fb@201508241122
  // Se le agrega al actor THidroConEmbalse la posibilidad de introducirle error
  // a la cota inicial.
  // Adem�s se mejora acceso a Excel de SimRes3 tratando de mejorar la compatibilidad
  // con el Excel nuevo.

//  vSimSEESimulador_ = '_119_Amargo_'; // rch@201506291547
  // agrego DEFINE ExpansionRuida al Editor para que funcione TFuenteSelectorHorario
  // este parche es para que funcione, pero hay que cambiar la fuente para que guarde el nombre
  // del borne en lugar del idBorne para independizar la referencia del borne de la definici�n de
  // la bornera de las fuentes.

  //vSimSEESimulador_ = '_118_MateAmargo_'; // fb@201506241651
  //  en usaladejuegos->simular, se cambia el orden de Preparar_fuentes_ps para
  // antes de ActualizarEstadoGlobal(true) de Actores y Fuentes.
  // El cambio fue realizado para que HidoConEmbalse pueda leer el valor de la
  // fuente de Aportes en ActualizarEstadoGlobal(true)

  //vSimSEESimulador_ = '_117_Carqueja_'; // rch@201506190107
  //  Vuelvo a m�todo Referencia definido por defecto en TFuenteAleatoria.


//  vSimSEESimulador_ = '_116_Carqueja_'; // rch&fb@201506172111
// bugfix: La fuente "MaxMin" no sebreescrib�a el m�todo "referencia" con lo cual
// no se estaba ordenando bien la dependencia de fuentes. Esto ocasionaba diferencias
// entre las corridas monohilo y multihilo.

//  vSimSEESimulador_ = '_115_Carqueja_'; // rch&fb@201506121010
//  bugfix: THidroConEmbalse. Tal como estaba inicializaba mal h_real en el c�lculo
// de las p�rdidas de Filtraci�n y Evaporaci�n durante la optimizaci�n. Esto llevaba
// a que se calcularan en base a la resoluci�n de la estrella anterior. Esto puede explicar
// las diferencias detectadas entre la optimizaci�n Multi-hilo y mono-hilo, dado que "la
// estrella anterior" cambia mucho al tener varios hilos. Las consecuencias sobre los resultados
// deben no ser muy grandes pues la filtraci�n y la evaporaci�n no son siempre vol�menes peque�os.


///  vSimSEESimulador_ = '_114_Carqueja_'; // rch@201506112022
// Bugfix en Editor de FuenteSelectorHorario Imped�a editar una fuente
// previamente guardada.


//  vSimSEESimulador_ = '_113_Carqueja_'; // rch@201506011153
// BUGFIX. en el editor de TDemandaDetallada, exportaba mal a Excel si se trataba
// de un archivo binario de demanda que ya exist�a (o sea que no se creaba). El
// error se produce si el archivo tiene fecha de inicio diferente que la de la sala.

//  vSimSEESimulador_ = '_112_DeNoSi_'; // rch@201505261328
  // recompilo volviendo el c�lculo del valor del agua a DERIVADAS NO SIMETRICAS.


//  vSimSEESimulador_ = '_111_Carqueja_'; // rch@20150518
// BUGFIX. Se arregla error introducido por DFusco en uaxiliares.pas que implicaba
// la mezcla de formatos entre ISO y locales durante la lectura de una sala.
// Se debe mantener el criterio de que TODA INFO guardad est� en formato ISO.


//  vSimSEESimulador_ = '_110_Carqueja_'; // rch@20150514
// Se arregla variable agregada pro Felipe para fijar el valor del agua en
// modalidad control de cota de las hidr�ulicas.
// Se recompila para habilitar Excel.

//  vSimSEESimulador_ = '_109_Carqueja_'; // rch@201505130635
// versi�n experimental NO USA EXCEL
  // + Bugfix en inicializaci�n de CF si engancha con otro CF y no est� CAR  activa
  // intentaba inicializar histogramas que no hab�a creado.
  // Este bug se introdujo en una versi�n reciente al "experimentar" con la CAR.
  // + Se agrega a los editores de GTer_Basico y DemandaDetallada el manejo
  // de la reserva rotante. Se agrega en el panel de Sim/Opt del editor
  // un checkbox para habilitar el manejo de ReservaRotante (todav�a en desarrollo).
  // + Se corrige align Panel de escenarios para que se vean todos.
  // + Se corrigen textos en panel de control de cota de THidroConEmbalse
//
//  vSimSEESimulador_ = '_108_Carqueja_'; // rch@201505042100
// Bugfix. en archivo SimCostos estaba imprimiendo mal el VaR(0.05)
// Tambi�n se agreg� checkbox al editor para poder marcar si se desea o no
// que se impriman los  archivos con estado de fin de cr�nica que son muchos
// y generalmente no se utilizan.
//

//  vSimSEESimulador_ = '_107_Garufa_'; // rch@201504240826
// modifico el control de cotas de las THidroConEmbalse para que pueda
// activarse en Simulaci�n y en Optimizaci�n por separado. Antes de esta
// versi�n cuando se activaba operaba solamente durante la Simulaci�n.
// Para agregarlo durante la optimizaci�n y que tenga sentido la funci�n
// CF(X,k) debe incluir el costo de la penalidad incurrido como un costo
// verdadero sino el optimizador termina compensando el control.


//  vSimSEESimulador_ = '_106_Garufa_'; // rch@201504222043
  // Se mejora optimizaci�n con aversi�n al riesgo cambiando el re-muestreo
  // de los histogramas de costo para conservar siempre el peor y mejor valor
  // entre las muestras.


//  vSimSEESimulador_ = '_105c_Corral_'; // rch@201503270902
  // Agrego restricci�n de caudal medio m�ximo por paso de tiempo
  // en TFichaSuministroSimpleCombustible


  // vSimSEESimulador_ = '_105c_Tranquera_'; // rch@2015031628
  // Recompilaci�n para propuesta de versi�n oficial.

  // vSimSEESimulador_ = '_105c_Laud_'; // rch@201503101743
  // Agreto que las Hidro de pasada publiquen la variable dual de la
  // restricci�n de balance (V_Turbinado+V_Vertido - V_Aportes = 0 ) en USD/Hm3

  // vSimSEESimulador_ = '_105c_Asinos_'; // rch@201502261954
  // Se mejora forma en que los Generadores Postizadores leen las fuentes
  // se contin�a debuggeando al versi�n Diezminutal.

  // vSimSEESimulador_ = '_105c_Bagual_'; // rch@20150222227
  // Se agregan par�metros a TPronostico y TFuenteSintetizador para poder
  // hacer consultas de pron�sticos.
  // Cambia el comportamiento de TEdit en VisorTablas para que al pegar
  // desde Excel cambie retornos de l�neas por ";" y tambi�n Tabuladores por ";"
  // Eso permite por ejemplo copiar una lista de valores desde Excel directamente
  // en el casillero de la GUIA de un cono de pron�sticos en una fuente CEGH.

  // vSimSEESimulador_ = '_105c_Arisco_'; // rch@201502132347
  // bugfix - THidroConembalse estaba calculando mal la derivada del costo futuro
  // en el nivel m�s bajo de la discretizaci�n lo que hac�a que se sub-valorara
  // el agua en el fondo del los lagos.

  //vSimSEESimulador_ = '_105c_Ch�caro_'; // rch@201502090757
  //  bugfix en el interpolador de demanda detallada horaria para salas diezminutales
  //  acondiciono mecanismo postizador en base a Demanda Neta para que funcione
  //  en salas Diezminutales. Tal como estaba asum�a paso de tiempo >= 1h.
  //  Se agrega publicaci�n por defecto para SimRes3 del valor dual de la
  //  restricci�n de caudal de las hidr�ulicas de pasa

//  vSimSEESimulador_ = '_105c_Argot_'; // rch@201502041222
  // Se cambi� la forma de tratar las series hist�ricas en los sitntetizadores CEGH para
  // permitir que se puedan usar series hist�ricas con diferente paso entre muestras que el
  // paso de simulaci�n.

  //  vSimSEESimulador_ = '_TEST105_daa'; // rch@201501310840
    // Se supone que no tiene cambios de algoritmos y que solo se agerg�
    // la capacidad de los objetos persistentes de describir sus campos para
    // faliciltar la edici�n de las salas. Pero se cambiaron muchos archivos con
    // lo cual se est� en MODO TEST.

//  vSimSEESimulador_ = '_ADME105_daa'; // rch@201501241030
  // agrego PostOper Monotonizar para facilitar la comparaci�n entre
  // salidas de salas horarias y de salas de paso de tiempo mayor con postes (semanal, diaria, etc.).
  // Adem�s cambi� la forma en que el Esclavizador sub-muestreado sortea en caso de
  // que se no se marque "resumir promediando" ahora usa su propia fuente aleatoria y as�
  // no perturaba los sorteos de la esclava. Esto tambi�n es para facilitar la comparaci�n
  // de simulaci�n cr�nicas horarias vs. semanales.


//  vSimSEESimulador_ = '_ADME_1.05da'; // rch@201501222154
// Agrego CONDITIONAL DEFINES en uEsclavizaroSubMuestreado y en uFuenteSintetizador para facilitar debug de sorteos en fuentes sub-muestreadas.
// bugfix en funciones de getEstado y setEstado de los sorteadores uniformes esto podr�a mejorar la repetitibilidad de las optimizaciones multi-hilo.
// bugfix en calculo de fecha del fin de paso. Esto puede afectar el funcionamiento de los CONTRATOS EN MODALIDAD DEVOLUCION.

  // vSimSEESimulador_ = '_ADME_1.05d'; // rch@201501221946
  // modifico comportamiento de TPostOper_acumularConPisoYTecho
  // para que adem�s de calcular la evoluci�n del acumulado con piso y techo
  // recorte el IngresoNeto cuando actuan el piso o el techo.

  //  vSimSEESimulador_ = '_ADME_1.05c'; // rch@201501051531
  // Se mejora modelo de Hidro con Embalse para cubrir la condici�n en que
  // iniciando el paso de tiempo en cotas por debajo de las operativas de las
  // turbinas y del vertedero (esto es no puede evacuar agua) el aporte del paso
  // es de tal magnitud que necesita de evaacuci�n para control de crecida.
  // Lo que se hizo fue cambiar el modelo de hidro para estimar los caudales
  // la capacidad de turbinar y de verter en base al volumen final del paso sin Erogado.

//  vSimSEESimulador_ = '_ADME_1.05b'; // rch@201412091917
  // Bugfix. En TFuenteSelector_Horario. Hab�a un bug que imped�a la ejecuci�n
  // de las salas con este tipo de fuente.
  // Se agrega Print en SimRes3 para soporte de Sripts R

  // vSimSEESimulador_ = '_ADME_1.05'; // rch@201411251123
  // cambio la PostOper cambioPasoDeTiempo para que funcione
  // tambi�n si el el cambio es reduciendo el paso. Tal como estaba
  // solo funcionaba bien si se aumentaba el paso.


//  vSimSEESimulador_ = '_ADME_1.04'; // rch@201411161131
  // Agrego postOpers CVaR, CrearConstante, AcumularConPisoYTecho todas
  // ellas para facilitar el c�lculo del Fondo de Estabilizaci�n de Energ�a.
  // Tambi�n modifico las PosOpers para que sepa como operar con CronVars
  // que sean mono_cronicas o mono_paso.

//  vSimSEESimulador_ = '_ADME_1.03'; // rch@201411080527
  // Bugfix corrijo bug introducido un usalasdejuego en la 1.02 por el cual
  // la fucion de CostoFuturo quedaba NULA salvo para el pen�ltimo
  // frame temporal.

//  vSimSEESimulador_ = '_ADME_1.02'; // rch@201410271633
  // 1) bugfix en los actores Solar y E�lico la opci�n "restar para postizar"
  // aplicaba siempre sin importar si el casillero estaba marcado o no.
  // 2) Se agreg� en SimRes la posoperaci�n CVaR para facilitar c�lculo
  // de par�metros para el Fondo de Estabilizaci�n de la Energ�a.

//  vSimSEESimulador_ = '_ADME_1.01'; // rch@201410030705
  // 1) se agrega opci�n de imprimir solamentFe variables usadas en
  // Plantillas SimRes3.
  // 2) agrega factores de indexaci�n en Bioembalse
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
  // se corrige problema de salvado de fuente de �ndice en bioembalse

//  vSimSEESimulador = '4.51_statera_frictio_'; // rch@201408021915
  // agrego operaci�n cr�nica promedioPonderadoConDurPos

//  vSimSEESimulador = '4.50_statera_frictio_'; // rch@201407300123
  // correcci�n de texto de etiqueta en formulario de edici�n de Parque E�lico

  //vSimSEESimulador = '4.49_statera_frictio_';
  //rch@201407272310 bugfix. En el editor de fichas de CicloCombinado
  // estaban invertidas las etiquetas de los casilleros de PagoPorPotencia
  // y pago por energ�a.

 // vSimSEESimulador = '4.48_statera_frictio_';
  // rch@201407261041 Agrego facilidad para c�lculo de GradienteDeInversion
  // en los GENERADORES.

//  vSimSEESimulador = '4.47_statera_frictio_';
// rch@201407221423 Bugfix en modelo de CicloCombinado.
// hab�a error en el cargado de la matriz del Paso. Este error afecta
// cualquier sala que estuviera usando esta central.


//  vSimSEESimulador = '4.46_statera_frictio_';
//rch@201407201911 Agrego cv_NoCombustible en generadores t�rmicos.

//  vSimSEESimulador = '4.45_fatum_statera_';
  // bugfix ... en en actor solar PV. Corrigo error introducido al netear
  // con la demanda.

//  vSimSEESimulador = '4.44_fatum_statera_';
  // rch20140714 mejoro interpolaci�n en transformadores CEGH.

//  vSimSEESimulador = '4.43_fatum_statera';
  // rch@20140705 comienzo a implementar la opci�n de POSTIZAR en base a
  // una demanda NETA en lugar de por una demanada principal.

//  vSimSEESimulador = '4.42_fatum_';
//  201407031509 BUGFIX. En c�lculo de CostoDirectoDelPaso en ugter_basico_PyCVariable
// El actor estaba sumando la energ�a de los postes en el costo en lugar de la energ�a
// por el costo de la fuente.


//  vSimSEESimulador = '4.41_fatum_';
//  201406252112

//  vSimSEESimulador = '4.40_garza_';
  // 20140613 bugfix en uFuncionesReales el c�lculo de la potencia del
  // Panel no estaba topeado al m�ximo lo que hac�a que diera diferente
  // seg�n que la sala fuera horaria o de paso superior pues el tope se
  // aplicaba v�a la restricci�n de caja y entoces actuaba sobre el promedio
  // en el caso de salas de paso de tiempo superior a la hora.

//  vSimSEESimulador = '4.39_garza_';
  // 20140603 bugfix en uSolaPV en fijaci�n de restricci�n de caja de la
  // potencia no ten�a en cuenta si hab�a m�s de una unidad.

//  vSimSEESimulador = '4.38_garza_';
  //20140520 cambios en formularios de edici�n SimRes3 para facilitar entrada

  //  vSimSEESimulador = '4.37_garza_';
  // se agrega que las fichas de par�metros din�micos se ordenan por FECHA y
  // luego por CAPA de esa forma tendr�a que ante dos fichas en capas
  // diferenes con la misma fecha (del mismo actor o fuente) prevalecer
  // la ficha de mayor capa.

  // vSimSEESimulador = '4.36_garza_';
  // 1) bug fix en BiomasaEmbalsable. La energ�a vertida no se inicializaba
  // correctamente al inicio de cada cr�nica. Esto hac�a que si al final
  // de una cr�nica hab�a vertimiento al inicio de la siguiente se repet�a
  // ese valor para la energ�a vertida.
  // 2) Se agreg� tambi�n que al resolver los bornes de las fuentes de los
  // actores PyCVariable si el borne NO EXISTE tire una excpci�n con un
  // mensaje que indica el actor, la fuente y el borne.

  // vSimSEESimulador = '4.35_garza_';
  // rch@201404161514
  // Agrego actor TBiomasaEmbalsable


  //  vSimSEESimulador = '4.34_garza_';
  // rch@20140412
  // Agrego posibilidad de indicar
  // "Imponer todas las potencias iguales" en las hidr�ulicas de pasada.
  // para un mejor modelado de las mini-hidr�ulicas en el marco del
  // proyecto ANII-FSE-1-2011-1-6552_ModeladoAutoctonasEnSimSEE.
  // **Bugfix. En THidro de Pasada, el Vertimiento NO estaba valorizado
  // con el costo variable (par�metro puesto en USD/Hm3) en la fila de costo
  // este bug nunca apareci� pues nunca se utiliz� el modelo de central de pasada
  // con un costo diferente de CERO. En la central de pasada la suma de
  // vertimiento m�s turbinado suma el caudal entrante (Aportes propios m�s erogados
  // por otras centrales.

  // vSimSEESimulador = '4.33_bandurria_';
  // rch@20140408
  // Correcci�n en fecha de guarda Sim para SimRes3.

//  vSimSEESimulador = '4.32_bandurria_';
  // rch@20140406
  // Agrego manejo de FuenteDeEscurrimientos en THidroConEmbalse, THidroDePasada y THidroConBombeo
  // Este agregado es para poder utilizar el CEGH de escurrimientos desarrollado en conjunto con el
  // IMFIA para el proyecto ANII-FSE-1-2011-1-6552_ModeladoAutoctonasEnSimSEE.

//  vSimSEESimulador = '4.31_bandurria_';
  // rch@20140403 BUGFIX-IMPORTANTE
  // En la versi�n 4.24 se introdujo un error en el tratamiento de las BAJAS
  // de unidades. El error actuaba en unidades con factor de dispnibilidad < 0.55
  // si al momento de dar de baja la unidad se encotraba rota por los sorteos de
  // disponibilidad fortuita. Dada la doble condici�n de que se encontrase rota
  // al momento de la baja y adem�s que fuese una m�quina con disponibilidad < 0.55
  // el bug no se manifest� en las salas de uso com�n. En la clase del curso de
  // SimSEE (2014-04-03) se analiz� una sala en que se baj� a prop�sito la dispnibilidad
  // de un generador a 0.5 y luego se le dio de baja por 1 d�a.
  // El bug se manisfest� en que a pesar de darlo de baja en algunas cr�nicas
  // el generador estaba y se despachaba.


//  vSimSEESimulador = '4.30b_martineta_';
      //rch@20140331  versi�n - beta -
      // Incluye algunos cambios de Enzo trabajando en los escenarios.
      // tambi�n incluye TRobotHttpPost que introduzco para consulta de pron�sticos.

//  vSimSEESimulador = '4.30_martineta_';
      //rch@20140315 Agrego "Soporte a Usuarios" en el Men� del Editor.

  //vSimSEESimulador = '4.29_martineta_';
      //rch@20140309 bugfix
      // En ufuncionesReales.pas, en la funci�n
      // function TFf_xmult_conselector_vxy.fval( vx, vy: NReal): NReal;
      //
      // que es usada por ParqueEolico_vxy
      // Habia un erro, si vy = 0  antes simplemente pon�a iang:= 0;
      // esto estaba mal, si la componente NoreteSur era CERO
      // impon�a viento del Norte cuando lo correcto es viento del Este
      // o del Oeste seg�n la componente vx
      // El impacto podr�a ser en aplicar un factor de rendimiento equivocado
      // cuando abs( vy ) < 1E-3.

//  vSimSEESimulador = '4.28_terra_';
  // rch@20140306
  // bugfix. En optimizaci�n multicore con CAR activada. No estaba intercambiando
  // los histogramas de interpolaci�n en los robots de los hilos.

  //vSimSEESimulador = '4.27_flecha_';
  // rch@20140216
  //   1) Corrigo bug en function Tf_ddp_Weibull.t_area(area: NReal): NReal;
  // de la unidad fddp.pas.  Este bug hac�a que las fuentes de Weibull no generaran
  // n�meros con distribuci�n de Weibull. El bug surge al documentar la fuente
  // y no surgi� antes pues no ha sido usada. No afecta ninguna Sala de las comunmente
  // usadas.
  //   2) Se agrega par�metro "Fecha de Guarda" en Simulaci�n. Esta fecha es usada
  // para ignorar en los archivos de salida todo lo que sucede antes de esa fecha.
  // se agrega como una forma c�moda de independizarse de la condici�n inicial.


//  vSimSEESimulador = '4.26_DIENTUDO_';
  // rch@20140102
  // bugfix: TFuenteSelectorHorario no se guardaba bien.

  // vSimSEESimulador = '4.25_DIENTUDO_';
  // rch@20131228
  // bugfix: en procedure THidroConEmbalse.cambioFichaPD;
  // Se corrige que para el c�lculo de las constantes de la par�bola de
  // las funciones CotaToVolumen y VolumenToCota.
  // Tal como estaba supon�a que el h_min era el punto con volumen cero
  // en la tabla de cotas-volumenes.

  //vSimSEESimulador = '4.24_DIENTUDO_';
  // rch@20131228
  // Cambio el manejo de las disponibilidad fortuita. Ahora el AltaConIncertidumbre
  // se especifica por FIcha y por tipo de Unidad.
  // Tambi�n agregu� InicioCronicaConIncertidumbre por ficha y por unidad.
  // Esto permite indicar si al inicio de cada cr�nica se debe considerar las unidades
  // fuera de mantenimiento como DISPONIBLES o si de debe introducir incertidumbre sobre
  // el estado inicial haciendo un sorteo para representar las probabilidades de estado
  // estacionario.

//  vSimSEESimulador = '4.23_BOA';
// rch@20131221 Milena agrega modelo de planta solar PV.

//  vSimSEESimulador = '4.22_BAGRE';
// rch@20131207 Federico agrega persistencia de las semillas de Sim y Opt y el tipo
// de optimizaci�n (PDE o Determinista) a la sala de juego. Yo las agrego al editor.


//  vSimSEESimulador = '4.21_BOGA_';
// rch@20131027 bugfix en THidroConEmbalse y en la activaci�n de escenarios.
// El error hac�a que el inicio del control de crecidas quedara incierto
// desde el inicio.

//  vSimSEESimulador = '4.20_BOGA_';
  // rch@20131020 Uniformizo un poco el tratamiento de los PagosPorDisponibilidad
  // y PagoPorEnergia. (no logr� uniformizar en todos los actores).
  // Por lo menos se los agregu� a los m�s usados.

//  vSimSEESimulador = '4.19b_BOGA_';
  // rch@20131018
  // bugfix en editor de curvas velocidad-potencia de los parques e�licos.

//  vSimSEESimulador = '4.19_BOGA_';
  // rch@201310152247
  // Cambio tratamiento de datos hist�ricos para que interpole de forma
  // de mantener el promedio.

  //vSimSEESimulador = '4.18_BOGA_';
  // rch@201310141239 - Bugfix. Al agregar los ruidos Wa en la bornera
  // se corri� el indexado de los bornes de las fuentes CEGH.

//  vSimSEESimulador = '4.17_BOGA_';
  // rch@201310131216 - Comienzo a introducir Ruida Multi Retardo

//  vSimSEESimulador = '4.16_BOGA_';
// rch@201310121847
// Agrego radio buttons para definir si usar CVaR o VaR en la optimizaci�n
// con Riesgo.
// -> sigo modificando la versi�n mh (MultiHilo) buscando porqu� da diferente
// que la simple hilo. Al parecer el problema era con los CEGH de m�s de un retardo
// con reducci�n de estado. El problema estaba en la lectura de la matriz de reducci�n
// y en la escritura en formato binario del CEGH.
// Atenci�n: Sigue sin estar operativa MatrizRuida para CEGHs multi-retardos.

//  vSimSEESimulador = '4.15_BOGA_';
// rch@201310120931
// bugfix, en simulaciones con series hist�ricas de CEGHs hab�a 2 errores
// 1) El valor de la primer semana se tomara de la cr�nica
// correspondiente a el n�mero de cr�nica m�s la semilla aleatoria (seg�n una opci�n de compilaci�n)
// pero luego continuaba tomando valores de la cr�nica asociada al ordinal de la cr�ncia.
// 2) Al anillar las cr�nicas se repet�a la primer cr�nica dos veces. Este error no afecta
// a la mayor�a de las corridas pues casi siempre se simula la misma cantidad de cr�nicas
// que las hist�ricas y por lo tanto la repetici�n no aparec�a.

//  vSimSEESimulador = '4.14_BOGA_';
// cambio la versi�n multihilo para tener mejor control de los hilos.

//  vSimSEESimulador = '4.13_BOGA_';
// rch@201309302315
// bugfix. Editor de Actores fallaba si al crear un actor se intentaba definir unidades sin antes guardar el actor
// este error se introdujo en la versi�n 4.07 al definir el checkbox AltaUnidades_Con_Incertidumbre

//  vSimSEESimulador = '4.12_BOGA_';
// rch@20130928
// bugfix: en el editor de enganches de CF hab�a un error por el cual
// si bien salvaba los enganches al abrir de nuevo el editor los perd�a
// y volv�a a poner los valores por defecto.

//  vSimSEESimulador = '4.11_MOJARRITA_';
  //rch@20130925  bugfix. en ploteo de conos de pron�sticos. El error
  // fue introducido en la 4.10 y no introduce errores de resultados
  // causaba excepci�n al intentar plotear los conos de pron�sticos de un CEGH.

//  vSimSEESimulador = '4.10_MOJARRA_';
  //rch@20130921  agrego en CalibrarCono de los CEGH que muetre
  // la trayectoria del estado reducido. Esto es para poder ver
  // el estado en el que hay que enganchar en una semanal horaria
  // con la MP de paso diario pero CEGH semanal.

//  vSimSEESimulador = '4.09_MOJARRA_';
  // rch@20130920 queda andando la ejecuci�n de escenarios.

//    vSimSEESimulador = '4.08_TARARIRA_';
  // rch@20130917
  // Mejoro margen en control de crecidas.

//  vSimSEESimulador = '4.07_TARARIRA_';
  // rch@20130910
  // Agrego booleana AltaUnidades_CON_INCERTIDUMBRE en los Actores.
  // El comportamiento por defecto es TRUE y significa que cuando la cantidad
  // de unidades del actor AUMENTA (o sea se dan de alta nuevas o salen de man
  // tenimientos programdos. El alta se raliza CON_INCERTIDUMBRE y significa que
  // pasan al estado "rotas" y estar�n disponible con la probabilidad dada por
  // la reparaci�n. Esto es as� en los actores que por los par�metros FD y TMR
  // tenga sentido el modelo de FALLA/REPARACION.

//  vSimSEESimulador = '4.06_TARARIRA_';
  // rch@20130824
  // 1) (bugfix_menor)SimSEE_OptSim. La llamada a SimRes3 desde OptSim cambiaba de directorio y luego
  // fallaba la segunda vez por no encontrar el archivo de Plantilla cuando no
  // estaba especificado con la ruta completa. Se corrigi� haciendo que vuelva
  // a posicionarse en el directorio de la sala.
  // 2) Se agrega bot�n Optimizaci�n Determinista y se comienza a probar la resoluci�n
  // del problema de despacho determin�stico.


//  vSimSEESimulador = '4.04_TARARIRA_';
// Agrego par�metro en las salas ObligarDisponibilidad_1_Opt separando as� el
// comporatamiento enter Opt y Sim. Esto es para permitir hacer Optimizaciones
// en las que NO se rompan las m�quinas.

//  vSimSEESimulador = '4.03_TARARIRA_';
// Comienzo a introducir forzamientos y habilito que las fechas peudan pornerse
// especificando DateTime (es decir no solo el d�a, tambi�n hh:mm:ss
// esto permite hacer que los par�metros din�micos valgan desde una hora en particular.

// rch@20130816 ... comenzamos a introducir Los Forzamientos .
//  vSimSEESimulador = '4.02_NUTRIA_';
// rch@20130813
// 1) Modificamos con Enzo la forma de estimar la derivada de CF en los bordes de la discretizaci�n
// Ahora, aproxima primero una par�bola con los tres puntos m�s pr�ximos al extremo
// y en base a la par�bola calcula la derivada hacia el exterior de la discretizaci�n.
// 2) Se agreg� en THidroConEmbalse la posibilidad de iterar en la altura del c�lculo
// del coeficiente energ�tico para tener en cuenta variaciones de la cota durante el paso
// de tiempo. Esta opci�n se habilita con un conditional define USAR_APRI  (de usar Aproximaci�n de Integral).
//

//  vSimSEESimulador = '4.01_NUTRIA_';
// rch@20130807
// Modificaciones al Simulador/Optimizador
// agrego Bot�n LlenarConUltimoFrame en el panel de Optimizaci�n
// agrego bot�n Ecualizar y casillero para fijar la cantidad de pasos.
// Es para probar diferentes formas de las prog. semanal.

//  vSimSEESimulador = '4.00_APEREA_';
// rch@20130801
//   mejoro el funcionamiento del Control de Crecida en THidroConEmbalse
//   agregu� un par�metro que permite especificar el Caudal a erogar con el
//   control a pleno. Adem�s, ahora el control tiene en cuenta la duraci�n
//   del paso de tiempo suavisando las variaciones del lago.

//    vSimSEESimulador = '3.99_CAPINCHO_';
    // rch@20130728
    // Agrego fuente TFuenteSelector_horario para perimitir ejecutar corridas horarias
    // con fuentes de precios semanales con definici�n de precios por POSTES mediante
    // la definici�n de filtros horarios que seleccionan la fuente y borne adecuado
    // seg�n la hora de inicio del paso.
    // Tambi�n acomodo la fijaci�n de ls PMIN en THidroConEmbalse en el caso de iteraciones
    // para evitar que PMin de despacho infactible por llegar al fondo del lago.

//  vSimSEESimulador = '3.98_AMBROSIA_';
// rch@20130724
  // Corrigo c�lculo de UtilidadDirectaDelPaso que no se reincializaba a CERO en cada
  // paso y se iba acumulando. Este error no afecta resutados salvo el de esa variable.
  // Al corregir ese error verifico tambi�n que las utilidades no se consideran en la
  // formaci�n del costo futuro durante la optimizaci�n y agrego un CheckBox que sea
  // Restar utilidades de CF que por defecto sea TRUE.


//  vSimSEESimulador = '3.97_AMBROSIA_';
  // rch@20130723

//  vSimSEESimulador = '3.96_PIRINGUNDIN_';
  // rch@20130716
  // Agrego checkboxes en las fichas de par�metros din�micos de THidroConEmbalse,
  // THidroConBombeo y THidroConEmbalseBinacional para poder deshabilitar el c�lculo
  // de la evaporaci�n y del filtrado del lago. Tambi�n revierto el "alambre" puesto
  // en la 3.94 que se se�alizaba con Qa_MuySeco = 0 que no se quer�a calcular la
  // evaporaci�n del lago.

  // vSimSEESimulador = '3.95_PIRINGUNDIN_';
  // rch@20130715
  // Corrigo actor uMercadoSpot_Postizado, para que el CostoDirectoDelPaso
  // tenga en cuenta los DeltaExportadores.
  // Tambi�n agrega publicaci�n de variables para SimRes3 de Conector de Combustible y
  // Contrato TakeOrPay asociados al modelado de la regasificadora.

  //  vSimSEESimulador = '3.94_CALIBRANDO_';
  // Enzo agreg� que si el Qa_MuySeco es CERO entonces no considera Evaporaci�n.
  // Esto se arregl� pues en el caso de Salto Grande, los aportes disponibles
  // ya tienen descontada la evaporaci�n.

//  vSimSEESimulador = '3.93_CALIBRANDO_';
  // rch@20130618
  // bugfix1: en uevapUruguay.pas, la funci�n "InicializarCoeficientesDeEvap"
  //        ten�a un bug y usaba las tablas de coeficientes de evap, alreves.
  // bugfix2: en uHidroConEmbalse.pas, la funci�n "THidroConEmbalse.CotaToSuperficie"
  //         devolv�a el �rea en Hm3/m lo que es 1e-6 del valor en m2.
  //         esto ten�a como efecto que la evaporaci�n; que se calcula como un
  //         valor en coeficiente expresado en  m/s multiplicado por el �rea
  //         dava valores despreciables. Ahora la funci�n retorna el valor en m2 como debe ser.

  // vSimSEESimulador = '3.92c';
  // rch@20130606 agrego en uHidroConEmbalse control de NO Desfondar el Lago con
  // caudales negativos.

//  vSimSEESimulador = '3.92b';
  // rch@20130606 cambio formulario edici�n fichas fuentes simples porque no funcionaba
  // bien el scroll cuando se agregan muchas.

//  vSimSEESimulador = '3.92';
// Se implementa ExpansorRuida cuando la reducci�n de estado en los CEGH no es completa.

//  vSimSEESimulador = '3.91';
  // rch@20130524 - Cambio operaciones sumaproducto en SimRes3 para que funcionen
  // aunque uno de los �ndices no sean postizados. Esto facilita c�lculos como
  // sumadobleproducto_condurpos para calcular el COSTO de generaci�n al hacer
  // sumadobleproductocondurpos de las potencias con el CV de la m�quina.

//  vSimSEESimulador = '3.90';
  // rch@201305161909
  // Agrego evento prepararPaso_ps en los monitores de la optimizaci�n.
  // Agrego que al empaquetar se fije si existe archivo con mismo nombre .mon y lo empaquete.

//  vSimSEESimulador = '3.89_UG';
// rch@201305061034
// Se agregan UsosGestionables.
// Bugfix en EMPAQUETAR que no andaba bien con duplicados.


//  vSimSEESimulador = '3.88_CHAOS+++';
// rch@201305011243 - D�a de los trabajadores.
// Bugfix en modelo de TArcoConSalidaProgramable que afectaba al Editor.

//  vSimSEESimulador = '3.87_CHAOS++';
// rch@20130423
// corrigo bug en fddp.pas
// function TMadreUniforme.rnd: NReal;
// generaba n�meros que no siempre estaban en entre 0 y 1

//  vSimSEESimulador = '3.86_CHAOS+_GNL_';
// rch@201304111947 bugsfixs
// a) en manejo de la lista de plantillasSimRes3
// b) el modelo ParqueEolico re-publicaba las variables de Potencia.
// -- ninguno de los bugs tiene consecuencias en los resultados --

//       vSimSEESimulador = '3.85_CHAOS+_GNL_';
// corrgimos con AC. sorteos Turbo Vapor en el CC. Revisar actualizaci�n sorteos.

//     vSimSEESimulador = '3.84_CHAOS_GNL_beta';
     // rch@201303212337
     // 1) corrigo bug en editor de SimRes3 que mezclaba los �ndices de las variables.
     // 2) quito mensaje que aparec�a al intentar editar el cono de pron�sticos de un CEGH.
     // ninguno de los cambios afecta resultados. Son solo cuestiones de "edici�n".
     // vSimSEESimulador = '3.83_CHAOS_GNL_beta ... no existi�.
//    vSimSEESimulador = '3.82_CHAOS_GNL_beta';
    // rch@20130310 le agrego TGTer_ConectableASuministro que calcule el cvm (coso medio para despacho)
    // y lo publique para SimRes3PorDefecto.

//  vSimSEESimulador = '3.81_CHAOS_GNL_beta';
// rch@20130307 bugfix en Simplex. Hab�a un error que ocasionaba un bucle inifinito
// en la resoluci�n de igualdades que termina con una excepci�n por acceso fuera de
// que se daba en las situaciones en que el Simplex era usado desde un MIPSimplex y
// en condiciones en que en un NODO PADRE resultan redundante restricciones de igualdad.
// Al resolver una rama de ese nodo se produc�a la condici�n.

//  vSimSEESimulador = '3.80_CHAOS_GNL_beta';
  //rch@20130306 Integra fuentes desarrollados por equipo de UTE (F.Ron A.Bouvier) de
  // modelo de la regasificadora en el Simulador - Falta agregar en EDITOR.

//  vSimSEESimulador = '3.79_CHAOS_GNLgamma';
    // rch@20130227 BUGFIX en modelo de uger_onoffporpaso ( en la v3.76 quedo un bug que afectaba el c�lculo del pago adicional por energ�a
    // en las onoff por paso. No se inicializaba una variable, con lo cual dependiendo de la suerte, se produc�a un error de desborde num�rico.
//  vSimSEESimulador = '3.78_CHAOS_GNLgamma';
  // comenzamos a agregar actores para modelo de Regasificadora y Suministros de Combustible.
//  vSimSEESimulador = '3.77_CHAOS';
  // Fernanda Maciel &rch@20130225 agrego consideraci�n de las importaciones en el c�lculo de los factores de emisiones de CO2
//  vSimSEESimulador = '3.76_CHAOS';
  // rch@20130222 corrigo BUG  en c�lculo del CDP de las T�rmicas con ONOFFPORPASO.
//  vSimSEESimulador = '3.75_CHAOS';
  // rch@20130218 corrigo BUG en Expansion RUIDA. Intentando hacer andar CEGH_peol7p2MWsem1234_mvar
  // todav�a quedan detalles a arreglar para generalizar el uso de la Expansi�nRUIDA.

//  vSimSEESimulador = '3.74_CHAOS';
   // rch@20130216
   // 1) Agrego en algunos actores t�rmicos el IngresoPorDisponibilidad y IngresoPorEnergia
   // como variables calculadas y publicadas. Habr�a que genralizarlo a todos los actores.
   // En estos actores el vector "costos" tiene los costos por poste que resultan de los costos operativos
   // considerados para el despacho. Ojo, en versi�n anterio el vector "costos" inclu�a los IngresosPorEnergia
   // Este cambio es para separar mejor lo que son costos considerados para el despacho de costos operativos.
   // Hay que pensar como se generaliza esto. Habr� que poner el vector Costos y las variables
   // IngresosPorEnergia e IngresoPorPotencia al nivel de TActor para que est� en todos.
   // 2) En SimRes2 se produc�a un error (se colgaba el Excel) si en alguna operaci�n se ponen
   // nombres para la hoja con caracteres raros y/o nombres demasiados largos.
   // Para evitar esto, se agreg� una funci�n de "purificaci�n" de los nombres de las hojas
   // que quita caracteres raros y cambio espacios por "_".



  // vSimSEESimulador = '3.73_CHAOS';
  // rch@201301224 correcci�n en el editor para despliegue de actores con muchas unidades.
  //  vSimSEESimulador = '3.71_ANARQUIA_GD'; // rch@201301224 mejora en el c�lculo del factor de emisiones BuildMargin y correcci�n en el editor del listado con informaci�n para emisiones.
  //  vSimSEESimulador = '3.70_ANARQUIA_GD'; // rch@20121206 ArcosPostizados y con manejo del peaje en despacho y CDP.

  //  vSimSEESimulador = '3.69_ANARQUIA_EFCM'; // rch@20121203 cambio los arcos para que se pueda especificar
  // PMax, rendimiento y peaje por poste. Esto es necesario para la integraci�n con Flucar.

  //  vSimSEESimulador = '3.68_ANARQUIA_EFCM'; // rch@20121116 completo Posibilidad de c�lculo de Factor de Emisiones "Combined Margin".
  // se agrega en el editor el formulario CO2, que permite especificar el c�lculo.
  // este formulario contiene un despliege de los generadores para poder especificar facilmente
  // los par�metros de los mismos que intervienen en el c�lculo de las emisiones.
  // Se agreg� a los generadores un campo booleano que permite indicar si el mismo est�
  // aderido a un CDM (Clean Development Mechanism) para considerarlo o no en el c�lculo del
  // Build_Margin que luego se utiliza en el calculo del Combined_Margin.

  //  vSimSEESimulador = '3.67_ANARQUIA_EFCM'; // rch@20121110 agrego Posibilidad de c�lculo de Factor de Emisiones "Combined Margin".
  //   vSimSEESimulador = '3.66_ANARQUIA_CongPosDispo'; // rch@20121019 agrego adem�s que publicquen la disponibilidad los arcos y de los generadores PyCV

  //  vSimSEESimulador = '3.65_ANARQUIA_Congesti�nPositiva'; // rch@20121019 cambio costo de congesti�n. Ahora es SOLO cuando est� activa la restricci�n del tope.
  // Tal como estaba era la suma de la restricci�n del tope y la del piso (P=0) y era confuso.

  //  vSimSEESimulador = '3.64_ANARQUIA_'; // rch@20121015 corrigo bug en editor el [VACIAR] limpiaba el cuadro de texto, pero no las variables de la sala
  // que defnian los archivos de enganche. Esto hac�a que al empaquetar la sala fallaba por no encontrar el archivo referido.
  // Tambi�n se acompod� el ZIPPER del empaquetar para que pueda zippear archivos que est�n abiertos para lectura.
  // Esto hac�a fallar el empaquetado de salas con "demandas detalladas" pues dichas demandas dejan abierto en archivo
  // de datos en modalidad lectura.

  //  vSimSEESimulador = '3.63_ANARQUIA_'; // rch@20121014 Independizo a todos los Actores y Fuentes ... ahora que cada uno se realice como quiera.
  //  vSimSEESimulador = '3.62_RUIDA_ConSesgosOd_CO2_EnganchesProm_Beta'; // rch@20121008 agrego posibilidad de enganches de CF promediando en las dimensiones desaparecidas
  //  vSimSEESimulador = '3.61_RUIDA_ConSesgosOd_CO2_Beta'; // rch@20121005 Uniformiso vector P en los uninodales = Potencia Inyectada.
  // Esto cambi� el comportamiento de las variables exportadas de las demandas (antes era la P pretendida consumir)
  // y ahora es la P Neta (Fallas - Demanda Pretendida) = - Demanda Real
  // Adem�s de ese cambio (que es para que sea f�cil tener las potencias que ir�an al FLUCAR
  // se agreg� en la clase generador TonCO2xMWh (factor de emisiones) y LowCostMustRun (booleana) para facilitar
  // el c�lculo de factores de emsiones.

  //  vSimSEESimulador = '3.60_RUIDA_ConSesgosOd_Beta'; // rch@20120920 cambio en la lectura para que los nombres de campos ignoren entre may�suclas y min�sculas
  // esto facilita la modificaci�n manual de los archivos de sala.

  //  vSimSEESimulador = '3.59_RUIDA_ConSesgosOd_Beta'; // rch@20120812 agrego que imprima en SimCosto el CFaux y el CT = cdp+CFaux
  //  vSimSEESimulador = '3.58_RUIDA_ConSesgosOd_Beta'; // rch@20120812 bugfix ufechas setAnio en una fecha si justo mes=2 y dia=29
  //rch20120911  vSimSEESimulador = '3.57_RUIDA_ConSesgosOd_Beta'; // rch@20120811  bugfix en sicronizacion de historicos. En determinada condici�n
  // en simulaciones horarias con CEGH BPS semanal se tracaba con Excption por una comparaci�n
  // de fechas mal hecha.
  //  vSimSEESimulador = '3.56_RUIDA_ConSesgosOd_Beta'; // Agrego expansion de sesgos en opt RUIDA->Od
  //  vSimSEESimulador = '3.55_RUIDA_Beta'; // Corrige BUG impresion de reales con Formato
  // y adem�s se agrega que en los resultados de simulaci�n "simcosto_SEM_NCRON.xlt" se
  // imprimen los costos directos actualizados y el costo Futuro de final de juego
  // tambi�n actualizados. Adem�s de imprimir los costos Totales.
  // Tambi�n se aegreg� que se genera un archivo por cr�nica en el que los actores
  // con estado escriben su valor de fin de juego. Esto es con el prop�sito de
  // poder encadenar simulaciones tomando el estado inicial desde el final de otra.

  //  vSimSEESimulador = '3.54_RUIDA_Beta'; // Agrego Expansi�n RUIDA en modelos CEGH.
  // atenci�n por ahora aplica solo a los casos en que la reducci�n va a 0 ve.
  // por ejemplo caso modelos horarios de viento.
  // Todav�a no aplica a todos pues me tranqu� en resolver la raiz de BaBa cuando
  // es semi-definida positiva.
  //  vSimSEESimulador = '3.53'; // agrego posibilidad de Sincronizar con Datos Hist�ricos.
  //  vSimSEESimulador = '3.52beta'; // rch@20120705 Se corrigen FUENTES dependientes de FUENTES
  // para que calculen sus salidadas den prepeararpaso_ps. Antes por eficiencia durante la
  // optimizaci�n esto se hac�a en SortearEntradasdaRB y ValorEsperadoEntradaRB y el mismo
  // procedimiento Sortear se encarga de calcular las salidas. Pero esto ESTABA MAL pues
  // por ejemplo en la fuente producto, si una de las entradas era un CEGH con estado,
  // al ir posicionando la estrellita (luego de los sorteos del paso) se cambia la salida
  // del CEGH, pero no se recalcula el producto posterior. Por simplicitad se cambiaron las fuentes
  // combinacion, producto, sinusoide, maxmin, selector para que calculen sus salidas en
  // prepararpaso_ps. Esto puede ser ineficiente durante el proceso de optimizaci�n si
  // ninguna de las fuentes de entrada a una fuente de ese tipo tiene estado, pero
  // para optimizar este tema habr�a que ubicar dentro de las fuentes que dependen de una con
  // estado y ponerlas en una lista de "recalcular en prepararpaso_ps". Por ahora m�s vale
  // ineficiente pero ROBUSTO.

  //  vSimSEESimulador = '3.51beta2'; // rch@20120701 Corrigo bug tonto en modalidad NO usar CAR.
  //  vSimSEESimulador = '3.51';
  // rch@20120626 Agrego menejo de la Aversi�n Al Riesgo en la programaci�n din�mica estoc�stica.

  //  vSimSEESimulador = '3.50';
  //rch@20120624 Queda funcionando que los modelos CEGH pueden trabajar con filtro lienal constate (como antes)
  // y adem�s puede tener el filtro lineal variable al igual que los deformadores.
  // Para generar el CEGH variable.
  // Cambio realizado para proyecto del IMFIA (ANII-FSE-31-2009-Mejoras en la simulaci�n de aportes a las represas hidroel�ctricas para su incorporaci�n a modelos de planificaci�n energ�tica)

  //  vSimSEESimulador = '3.49';
  // +agrega: modelo TArcoConSalidaProgramable.
  // +mejora: se cambi� el comportamiento de THidroConEmbalse para que si est�
  // marcado "Valorizado Manual del Lago" igual mantenga las tablas auxiliares
  // de caudal erogado durante la optimizaci�n para mejorar la precisi�n de la
  // estimaci�n del coeficiente energ�tico durante la optimizazi�n aunque no se
  // considere el volumen embalsado como variable de estado.

  //  vSimSEESimulador = '3.48';
  // corrijo interpolaci�n entre tablas de evaporaci�n en fuente uevapUruguay.pas.
  // Esta correcci�n es menor. En la interpolaci�n entre las dos tablas de evaporaci�n
  // correspondiente a muy_seco y a muy_humedo hab�a un error que implicaba un peque�o sesgo
  // hacia la tabla de muy_seco.

  //  vSimSEESimulador = '3.47';
  // Elimino el control de monoton�a de la derivada introducido enla 3.46.
  // Sencillamente me convenc� que la funci�n de Costo Futuro no tiene porqu� ser convexa
  // respecto del volumen embalsado. Haciendo una optimizaci�n de un sistema muy sencillo
  // con solo una central don embalse con caudal constante, demanda constante y con un �nico
  // recurso en el sistema de costo constante, el mismo volumen de agua sustituye una cantidad
  // de energ�a mayor a mayor cota, por lo tanto su valor para el futuro es SUPERIOR a conta
  // mayor y esto implica que la funci�n de costo futuro es CONCAVA para este ejemplo!!.
  // As� que no tiene sentido imponer la monoton�a del derivada.
  // En el caso m�s natural, el sistema tiene muchos recursos y de diferentes valores y
  // por eso resulta natural suponer que si tengo el lago con mayor cota estoy "mejor" y
  // entonces el agua vale menos, pero el contraejemplo anterior es contundente en mostrar
  // que la convexidad de CF no est� garantizada.

  //  vSimSEESimulador = '3.46';
  // Agrego control de monoton�a de la derivada en la HidroConEmbalse.
  // en funciones de costo futuro en las que la derivada Inc se igualaba a la Dec los errores
  // de truncamiento lograban suvertir el orden y eso ocasiona inestabilidad en el algoritmo de
  // programaci�n din�mica estoc�stica.

  //  vSimSEESimulador = '3.45';
  // Corrijo chequeo de Turbinado y Bombeo simultaneo
  // en las HidroConBombeo. El chequeo estaba mal pues verificaba la suma de los
  // turbinados y bombeos de los postes, y detectaba como error situaciones
  // en que el bombeo se realiza en un poste y el turbinado en otro.

  //  vSimSEESimulador = '3.44';// Agrego modelo de Banco de Bater�as.
  //  vSimSEESimulador = '3.43';// comento lecutra del filtrao de cr�nica introducido en la v341 todav�a no est� listo
  //  vSimSEESimulador = '3.42';// corrigo bug. Luego de leer un CEGH impongo la cantidad
  // de retardos de los pron�sticos igual al del modelo de simulaci�n.
  // tal como estaban eran independientes y si creaba una sala con un modelo
  // de varios retardos luego aunque cambiara el modelo la cantidad de retardos
  // de los pron�sticos segu�a con la del modelo inicial.

  //  vSimSEESimulador = '3.41';//  rch+20120524 v3.41 agrego filtrado global de cr�ncia en SimRes3 (EN PROCESO)
  //  vSimSEESimulador = '3.40';//  rch+20120426. v3.40
  // Agregu� en el c�lculo del m�ximo volumen exigible en las restricciones de erogado
  // m�nimo que tenga en cuenta adem�s del vol�men embalsado y los aportes, la capacidad
  // de extraer ese vol�men mediante turivinado+vertido. Tal como estaba no se hac�a
  // ese control y en situaciones en que el lago se encuentra por debajo del vertedero
  // si se le ped�a un erogado por encima del m�ximo turbinable no lo lograba.
  // Ahora, para determinar si puede cumplir con una condici�n de Erogado M�nimo,
  // Limita el volumen de la condici�n a no superar ni el volumen
  // embalsado + Aportes - p�rdidas del paso ni el m�ximo volumen erogable
  // (turbinado + vertido). En esta versi�n se agreg� el control del volumen erogable.

  //  vSimSEESimulador = '3.39'; // rch@20120419 Se corrige bug en ucalibradorpronosticos.pas. El error afectaba la visualizaci�n de los conos de pron�sticos
  // en el caso de fuentes CEGH con NRetardos > 1. En ese caso se visualizaban los valores en el mundo gaussiano del estado en k-1.
  // y no la salidas en el mundo real en el instante k como deb�a de ser. Esto no afecta resultados de simulaci�n, solo lo que se visualizaba
  // en el calibrador.
  //  vSimSEESimulador = '3.38'; // rch@20120414 Recompilo para que cmdsim escriba los resultados detallado de simulaci�n y no solo el costo
  //  vSimSEESimulador = '3.37'; // rch@20120329 Corrige error en Imprimir Matriz de Datos de SimRes3 que fallaba si se marcaba graficar
  //  vSimSEESimulador = '3.36'; // Se agregaa la fuete aleatoria "selector(A; B, C, D ) donde s

  //  vSimSEESimulador = '3.35'; // Corrige error en la determinaci�n de la cantidad de a�os para simulaci�n con series hist�ricas.
  //  vSimSEESimulador = '3.34'; // Corrige confusi�n por BOM en archivos de texto. Por alguna misteriosa raz�n empezarona aparecer 3 bytes al inicio de los archivos que confunde la lectura de la versi�n.
  //  vSimSEESimulador = '3.33'; // Corrige bug en Edtior SimRes3 que ocurr�a al cambiar el actor de un �ndice.
  //  vSimSEESimulador = '3.32'; // Corregimos error de lectura de las PrintCronVar_CompararMultiples_cronvar introducido en la v3.31
  //  vSimSEESimulador = '3.31'; // Agrego a SimRes3 PostOperaciones MultiOrdenar y MultiPromedioMovil. Tambi�n agrego a los PrintCronVars, la posibilidad de
  // de indicar si hacen un Pre_Ordenar (como ya lo hacian) para imprimir resultados probabil�sticos o no.
  // Tambi�n si los resultados probabil�sticos son ProbabilidadesDeExcedencia (como hasta ahora) so son ValoresEnRiesgo
  // la diferencia es que en un caso imprime el valor que es exedido con cierta probabilidad pero en el caso de ValorEnRiesgo imprime
  // el promedio de los valores entre los l�mites de ProbDeExcedencia.
  //  vSimSEESimulador = '3.30'; // se corrige lector de TFuenteSintetizador para solucionar lectura de version v54
  //    vSimSEESimulador = '3.29'; // cambios en las funciones de fecha para diferenciar entre semanas en base 52 o semanas de 7 d�as.
  //  vSimSEESimulador = '3.28'; // arreglo tama�o de venta exportar actores del editor
  //  vSimSEESimulador = '3.27'; // Cambio sorteo para resumir borneras en esclavizador sub-muestreado a "sorteos delpaso" para que sea independiente del estado
  //  vSimSEESimulador = '3.26'; // manejo de CFAux en editor agrego posibilidad de borrado
  //  vSimSEESimulador = '3.25'; // arreglo error de manejo de CFAux

  //  vSimSEESimulador = '3.24'; //1) agregamos que la semilla aleatori se inicial al principio de cada
  // cr�nica como semillaInicial+kCronica
  // 2) se corrigi� que si se marca "Escribir Archivos Opt Actores" deshabilite la posibilidad de correr multi-hilo

  //    vSimSEESimulador = '3.23'; // Acomdamos orden de graficado en CompararVariables de SimRes3
  //    vSimSEESimulador = '3.22'; // Agregado de bot�n "Borrar Sesgos" en fuentes CEGH
  //    vSimSEESimulador = '3.21'; // MinHOrasOn y MinHOrasOFF en las T�rmica con costo de arranque/parada
  //    vSimSEESimulador = '3.20'; // Actores con varias tipos de unidades
  //  vSimSEESimulador = '3.19 beta'; // Postizado del actor TMercadoSpot.
  //  vSimSEESimulador = '3.18 beta'; // Mejora del c�lculo de la matr�z B de los CEGH.
  vSimSEEEdit_ = vSimSEESimulador_;
  vSimRes3_ = vSimSEESimulador_;
(*
El log de cambio de versiones est� en:
http://iie.fing.edu.uy/simsee/ayuda/ayuda.php?hid=versiones&titulo=versiones#

por favor mantener actualizado ese log.
El log debe contener la descripci�n del cambio de versi�n desde el punto
de vista del usuario de la plataforma SimSEE y no el detalle
de los cambios en la programaci�n (los cuales si son relevantes deben quedar
como comentarios DENTRO DE LOS FUENTES con el formato
autor@FECHA:comentario.
*)

implementation

end.

