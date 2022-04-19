unit ueditor_resourcestrings;

{$mode delphi}

interface

uses
  Classes, SysUtils;

resourcestring
  strTabDemandas = 'Demandas';
  strTabGeneradoresTermicos = 'Térmicas';
  strTabRed = 'Red eléctrica';
  strTabGeneradoresHidraulicos = 'Hidráulicas';
  strTabEolica_ = 'Eolicas';
  strTabSolar = 'Solar';
  strTabComercioInternacionalYOtros = 'Internacional y Otros';
  strTabCombustibles = 'Combustible';
  strTabSumCombustibles = 'Red de combustibles';
  strTabUsosGestionables = 'Usos Gestionables';
  strTabSinEditorRegistrado ='Sin Editor';

  rsActor = 'Actor';
  rsTipoDeActor = 'Tipo de actor';
  rsFecha = 'Fecha';
  rsUnidades_Instaladas = 'Und. Instaladas';
  rsUnidades_EnMantenimiento = 'Und. en mantenimiento';
  rsInformacioNAdicional = 'Información adicional';
  rsFechaDeMuerte = 'Fecha de muerte';
  rsFechaDeNacimiento = 'Fecha de nacimiento';
  rsPosteN = 'Poste Nº';
  rsDuracioN = 'Duración';
  rsFuente = 'Fuente';
  rsTipoDeFuente = 'Tipo de fuente';
  rsTipoDeCombustible = 'Tipo de combustible';
  rsPeriodicaQ = 'Periódica?';
  rsMonitor = 'Monitor';
  rsTipo = 'Tipo';
  rsSeleccioneUnGenerador = 'Seleccione un generador';

  exFormularioEdicionParaClase = 'Formulario de edición no registrado para la clase ';
  exEditorNoRegistradoClase = 'Editor no registrado para la clase ';
  exTipoActorDesconocido = 'Tipo de actor desconocido: ';
  exNoFuePosibleLeerSala = 'No fue posible leer la sala.';

  mesNoSePuedeEliminarActor = 'No se puede eliminar el actor ';
  mesExisteReferenciaAEl = ' pues existe una referencia a el.';
  mesElimineLasReferenciasVuelvaIntentarlo =
    'Elimine las referencias y vuelva a intentarlo.';
  mesConfirmaEliminarActor = '¿Confirma que desea eliminar el actor ';
  mesEliminaNodoActoresReferenciasVacias =
    'Si elimina el nodo seleccionado ' +
    'los siguientes actores quedaran con referencias vacias:';
  mesConfirmarEliminacion = 'Confirmar eliminación';
  mesConfirmaEliminarNodo = '¿Confirma que desea eliminar el nodo "';
  mesElActor = 'El actor ';
  mesReferenciasSinResolverResuelvalas =
    ' tiene referencias sin resolver. Resuelvalas para poder continuar.';
  mesLaFuenteAleatoria = 'La fuente aleatoria ';
  mesErrorImportandoActor = 'Se encontro el siguiente error importando el actor:';
  mesArchivoAbiertoONoExiste =
    'Puede ser que el archivo se encuentre abierto o no exista.';
  mesNoSePuedeEliminarFuenteReferencia =
    'No se puede eliminar la fuente pues existe una referencia a ella. ';
  mesNoSePuedeEliminarCombustibleReferencia =
    'No se puede eliminar el combustible pues existe una referencia a el. ';
  mesConfirmaDeseaEliminarFuentes = '¿Confirma que desea eliminar la fuente "';
  mesConfirmaDeseaEliminarCombustible = '¿Confirma que desea eliminar el combustible "';
  mesSimSEEEdit = 'SimSEEEdit';
  mesNoSeEncuentraArchivoMonitores = 'No se encuentra el archivo de monitores ';
  mesNoSeEncuentraSalaDeJuego = 'No se encuentra el archivo de sala de juego ';
  mesMonitoresNoGuardadosGuardarCambios =
    'Los Monitores no se han guardado. ¿Desea guardar los cambios?';
  mesSalaNoGuardadaGuardarCambios =
    'La sala no se ha guardado. ¿Desea guardar los cambios?';
  mesError = 'Error: ';
  mesElArchivo = 'El archivo ';
  mesNoExiste = ' no existe!';
  mesNoSePuedeEliminarLaFichaDeUnidades =
    'No se puede eliminar la ficha de unidades pues es la ' +
    'única que tiene el actor. Agregue otra y vuelva a intentarlo.';
  mesConfirmaEliminarFichaUnidadesActor =
    '¿Confirma que desea eliminar la ficha de unidades del actor "';
  mesConfirmaEliminarMonitor = '¿Confirma que desea eliminar el monitor "';
  mesMonitorXDefectoCreadoRemplazarlo =
    'El monitor por defecto ya fue creado. ¿Desea reemplazarlo?';
  mesRemplazarMonitorSimRes3 = 'Reemplazar monitor SimRes3';
  mesValorIntroducidoDebeNum = 'El valor introducido debe ser numérico';
  mesArchivoSalaContieneErrores = 'El archivo de sala seleccionado contiene errores.';
  mesSeLogroCargarSalaConProblemas =
    ' Se logró cargar la sala, sin embargo ' +
    'hubieron algunos problemas, revise el Memo de Advertencias para mas información.';
  mesAntesDeGuardarAsegureseContieneTodaInfo =
    'Antes de guardar la sala ' +
    'asegurese que contiene toda la información que usted desea.';
  mesHorizontesSimulacionNoValidos =
    'Los horizontes de simulación u optimización no son válidos.';
  mesGuardarCambiosSalaParaContinuar =
    'Debe guardar los cambios realizados a la sala para continuar.' +
    '¿Desea hacerlo ahora?';
  mesSeDebeCumplirRelacionHorizontes =
    'Se debe cumplir IniOpt <= IniSim <= FinSim <= FinOpt';
  mesGuardarCambiosMonitoresParaContinuar =
    'Debe guardar los cambios realizados a los monitores' +
    'para continuar. ¿Desea hacerlo ahora?';
  mesSeleccionarArchivoBin = 'Debe seleccionar un archivo CF.bin';
  rsArchivosBinariosDeCostosFuturos = 'Archivos Binarios de Costos Futuros';
  rsTodosLosArchivos = 'Todos los Archivos';
  mesGuardarMantenimientos = 'Los mantenimientos han sido guardados';

  rs_ElArchivoYaEstabaYNoFueAgregado_ ='El archivo seleccionado ya estaba en el listado por lo que no fue agregado.';
  rs_ArchivoEmpaquetadoConExito = 'La Sala fue empaquetada con éxito en el archivo:';
  rs_ErrorEmpaquetandoArchivo = 'Ocurrieron errores que no permitieron empaquetar la Sala.';

implementation

end.

