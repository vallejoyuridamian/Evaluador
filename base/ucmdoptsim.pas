unit ucmdoptsim;

interface

uses
  SysUtils, Classes,
  usalasdejuego, uglobs,
  uCosa, xMatDefs,
  uEstados,
{$IFDEF MONITORES}
  uManejadoresDeMonitores,
  uReferenciaMonitor,
  uEventosOptSim,
{$ENDIF}
{$IFDEF LINUX}
  baseunix,
  unix,
  ctypes,
{$ENDIF}
  uConstantesSimSEE,
  uInicioYFinal,
  umh_distribuidor_optsim,
  uInterpreteDeParametros,
  uauxiliares;

procedure WriteAlerta(const s: string);

procedure call_RunOptimizar;
procedure call_RunSimular;

procedure WriteHelpParametros( cmd: string );


{$IFDEF LINUX}
procedure Handler(Sig: integer); cdecl;
procedure InstallHandlers;
{$ENDIF}

implementation

var
  interpreteDeParametros: TInterpreteParametros;
  nombre_escenario: string;
  archi_sala: string;
//  nombre_rama: string;
//  lista_capas: string;
  sala: TSalaDeJuego;

{$IFDEF MONITORES}
  manejadorMonitores: TManejadoresDeMonitores;
{$ENDIF}
  tiempoIni, tiempoTotal, tiempoIniCronica: NReal;
  nHilosForzados, nTareasForzadas: integer;


{$IFDEF LINUX}
var
  SActionRec: SigActionRec;

{ Procedimientos agregados para el manejo de señales
del sistema.}
procedure Handler(Sig: integer); cdecl;
begin
  writeln('--estoy en el Handler---', GetThreadId);
  case Sig of
{    SIGALRM:
    begin
      writeln('SIGALRM');
      umensajesretardados.tic_Barrer;
      exit;
    end;}
    SIGINT, SIGTERM:
    begin
      writeln('--- recibi SIGINT o SIGTERM --- pongo abortarSim= true ');
      sala.globs.abortarSim := True;
      exit;
    end;
    //  SIGIO: writeln('SIGIO');
  end; { case }
end;

procedure InstallHandlers;
begin
  //writeln('Instalo Handlers, ThreadId= ', GetThreadId);
  with SActionRec do
  begin
    sa_handler := SigActionHandler(@Handler);
    fpsigemptyset(sa_mask);
    sa_flags := 0;
  end; { with }
  fpsigaction(SIGINT, @SActionRec, nil);
  fpsigaction(SIGTERM, @SActionRec, nil);
  //  fpsigaction(SIGALRM, @SActionRec, nil);
  //   sigaction(SIGIO, @SActionRec, nil );
  //  umensajesretardados.IniciarBarridos;
end;

{$ENDIF}

procedure WriteAlerta(const s: string);
begin
  Writeln(s);
end;


function CargarSala(idHilo: integer; archiSala, escenario: string; rama: string = '';
  capas: string = ''): TSalaDeJuego;
var
  sala: TSalaDeJuego;
begin
  writeln('CargarSala: archiSala= ' + archiSala + ', escenario= ' + escenario);
  try
    sala := TSalaDeJuego.cargarSala(idHilo, archiSala, escenario, True
    // , rama, capas
    );
    Result := sala;
  except
    on E: Exception do
    begin
      Writeln('Error cargando la sala:');
      writeln(E.Message);
      halt;
    end;
  end;
end;

{$IFDEF MONITORES}
function CargarMonitores(sala: TSalaDeJuego;
  archiMonitores: string): TManejadoresDeMonitores;
var
  manejadorMonitores: TManejadoresDeMonitores;
begin
  if FileExists(archiMonitores) then
  begin
    try
      manejadorMonitores := TManejadoresDeMonitores.CargarManejadorDeMonitores(
        archiMonitores, True, sala);
      Result := manejadorMonitores;
    except
      on E: Exception do
      begin
        Writeln('CargarMonitores: Se Encontro El Siguiente Error:' + #13 + E.Message);
        halt;
      end;
    end;
  end
  else
  begin
    Writeln('CargarMonitores: No se encuentra el archivo de monitores ' +
      archiMonitores);
    halt;
  end;
end;

{$ENDIF}

procedure Sim_Inicio;
begin
  tiempoIni := now();

{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    try
      manejadorMonitores.resolverReferenciasMonitores(TResolverMonitoresSimulacion);
    except
      on E: EMonitorException do
        Writeln('Se Encontraron Los Siguientes Errores:' + #13 +
          e.Message + #13 +
          'La Simulacion Continuara Sin Monitorear Los Actores/Variables Sin Resolver.');
    end;
    manejadorMonitores.notificarEvento(E_Sim_Inicio);
  end;
{$ENDIF}
end;

procedure Sim_InicioCronica;
begin
  tiempoIniCronica := now();
{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    manejadorMonitores.notificarEvento(E_Sim_InicioCronica);
  end;
{$ENDIF}
end;

procedure Sim_IniPaso;
begin
{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    uManejadoresDeMonitores.notifyIniPaso;
  end;
{$ENDIF}
end;

procedure Sim_FinPaso;
begin
{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    manejadorMonitores.notificarEvento(E_Sim_FinPaso);
  end;
{$ENDIF}
end;

procedure Sim_FinCronica;
{$IFDEF VERBORRAGICO}
var
  segsPorCronica: double;
{$ENDIF}
begin
{$IFDEF VERBORRAGICO}
  tiempoTotal := (now() - tiempoIni) * 24 * 3600;
  segsPorCronica := tiempoTotal / sala.globs.kCronica;
  writeln('Tiempo Restante [segs]: ', FloatToStrF(segsPorCronica *
    (sala.globs.NCronicasSim - sala.globs.kCronica), ffFixed, 8, 3));
  writeln('Tiempo Total [segs]: ', FloatToStrF(tiempoTotal, ffFixed, 8, 3));
  tiempoIniCronica := now();
{$ENDIF}
{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    manejadorMonitores.notificarEvento(E_Sim_FinCronica);
  end;
{$ENDIF}
end;

procedure Sim_Fin;
begin
{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    manejadorMonitores.notificarEvento(E_Sim_Fin);
  end;
{$ENDIF}
  writeln('Fin de la simulacion. ' + DateTimeToStr(now()));
end;

procedure Opt_Inicio;
begin
  tiempoini := now();
{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    try
      manejadorMonitores.resolverReferenciasMonitores(TResolverMonitoresOptimizacion);
    except
      on E: EMonitorException do
      begin
        Writeln('Se Encontraron Los Siguientes Errores:' + #13 +
          e.Message + #13 +
          'La Optimización Continuara Sin Monitorear Los Actores/Variables Sin Resolver.');
        writeln('1.5');
      end;
    end;
    manejadorMonitores.notificarEvento(E_Opt_Inicio);
  end;
{$ENDIF}
end;

procedure Opt_InicioCalculosDeEtapa;
begin
{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    manejadorMonitores.notificarEvento(E_Opt_InicioCalculosEtapa);
  end;
{$ENDIF}
  tiempoIniCronica := now();
end;

procedure Opt_FinCalculosDeEtapa;
{$IFDEF VERBORRAGICO}
var
  tiempoMedioPorCronica: NReal;
{$ENDIF}
begin
{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    manejadorMonitores.notificarEvento(E_Opt_FinCalculosEtapa);
  end;
{$ENDIF}

{$IFDEF VERBORRAGICO}
  tiempoTotal := Now() - tiempoIni;
  tiempoMedioPorCronica := tiempoTotal / (sala.globs.NPasos - sala.globs.kPaso_ + 1);
{  if (sala.globs.kPaso_ mod 10 <> 0) then
    writeln('Etapa: ', sala.globs.kPaso_)
  else}
  if (sala.globs.kPaso_ mod 10 = 0) then
    writeln('Etapa: ', sala.globs.kPaso_,
      ' Tiempo Total: ', FloatToStrF(tiempoTotal * 24 * 3600, ffFixed,
      8, 2), 'segs',
      ' Tiempo Restante Estimado: ', FloatToStrF(tiempoMedioPorCronica *
      sala.globs.kPaso_ * 24 * 3600, ffFixed, 8, 2), 'segs');
{$ENDIF}
end;

procedure Opt_Fin;
begin
{$IFDEF MONITORES}
  if manejadorMonitores <> nil then
  begin
    manejadorMonitores.notificarEvento(E_Opt_Fin);
  end;
{$ENDIF}
end;

procedure Terminar;
begin
  writeln('Voy a free de sala ');
  if Sala <> nil then
    Sala.Free;
  writeln('Volví de free de sala');

  {$IFDEF MONITORES}
  if manejadorMonitores <> nil then
    ManejadorMonitores.Free;
  {$ENDIF}

  writeln('Voy a free interprete de parametros');
  if interpreteDeParametros <> nil then
    interpreteDeParametros.Free;
  writeln('volvi del interprete');
end;



procedure Iniciar;
var
  tmp_base: string;

begin

  sala := nil;

{$IFDEF MONITORES}
  manejadorMonitores := nil;
{$ENDIF }

  tmp_base := interpreteDeParametros.valStr('tmp_base');
  if tmp_base = '' then
    tmp_base := getDefault_tmp_base;

  tmp_rundir := CrearDirectorioTemporal(
    tmp_base, interpreteDeParametros.valStr('ejecutor'));

  writeln('Cambio de directorio a : ', tmp_rundir);
  ucosa.lista_caminos.Add(tmp_rundir);

  chdir(tmp_rundir);
  if ioresult <> 0 then
    raise Exception.Create('No pude cambiar de directorio a: ' + tmp_rundir);

  tmp_rundir := tmp_rundir + DirectorySeparator;

  archi_sala := interpreteDeParametros.valStr('sala');
  nombre_escenario := interpreteDeParametros.valStr('escenario');
  {$IFDEF RAMA_Y_CAPAS}
  nombre_rama := interpreteDeParametros.valStr('rama');
  lista_capas := interpreteDeParametros.valStr('capas');
  {$ENDIF}

  if nombre_escenario = '' then
    nombre_escenario := '__principal__';

  ucosa.lista_caminos.Add(ExtractFilePath(archi_sala));

  writeln('Voy a cargar la sala ');

  if interpreteDeParametros.valStr('sala') <> '' then
    sala := CargarSala(0, archi_sala, nombre_escenario
    //, nombre_rama, lista_capas
    );

  writeln('volvi de cargar la sala ');

{$IFDEF MONITORES}
  if interpreteDeParametros.valStr('monitores') <> '' then
    manejadorMonitores := CargarMonitores(sala,
      interpreteDeParametros.valStr('monitores'));
{$ENDIF}
  if interpreteDeParametros.valStr('macro') <> '' then
    sala.EjecutarMacro(interpreteDeParametros.valStr('macro'));
end;

procedure EnlazarProcedimientos_Opt;
begin
  sala.globs.procNot_opt_InicioOptimizacion := Opt_Inicio;
  sala.globs.procNot_opt_FinCalculosDeEtapa := Opt_FinCalculosDeEtapa;
  sala.globs.procNot_opt_FinOptimizacion := Opt_Fin;
  sala.globs.setProcAlerta(WriteAlerta);
end;

procedure EnlazarProcedimientos_Sim;
begin
  sala.globs.procNot_InicioSimulacion := Sim_Inicio;
  sala.globs.procNot_InicioCronica := Sim_InicioCronica;
  sala.globs.procNot_InicioPaso := Sim_IniPaso;
  sala.globs.procNot_FinPaso := Sim_FinPaso;
  sala.globs.procNot_FinCronica := Sim_FinCronica;
  sala.globs.procNot_FinSimulacion := Sim_Fin;

end;

procedure call_RunOptimizar;
var
  f: textfile;
  semilla: integer;
  flist: TStringList;
  s: string;

begin
  interpreteDeParametros := TInterpreteParametros.Create( false );
  archi_sala := interpreteDeParametros.valStr('sala');
  if archi_sala = '' then
  begin
    WriteHelpParametros('cmdopt' );
    exit;
  end;

  {$IFDEF LINUX}
    installHandlers;
  {$ENDIF}
    tiempoIni := now;
    writeln('tiempoIni ' + DateTimeToStr(tiempoIni));
  uInicioYFinal.AlInicio;
  nombre_escenario := interpreteDeParametros.valStr('escenario');

//  nombre_rama := interpreteDeParametros.valStr('rama');
//  lista_capas := interpreteDeParametros.valStr('capas');

  nHilosForzados := interpreteDeParametros.valInt('nhilos', -1);
  nTareasForzadas := interpreteDeParametros.valInt('ntareas', -1);

  try
    writeln('voy a iniciar ');
    Iniciar;

    writeln('Borrando archivos ');
    SysUtils.deletefile('CF_' + nombre_escenario + '.bin');
    SysUtils.deletefile('cmdopt_ok_' + nombre_escenario + '.txt');
    SysUtils.deletefile('cmdopt_err_' + nombre_escenario + '.txt');

    EnlazarProcedimientos_Opt;

    if interpreteDeParametros.valStr('semilla') <> '' then
    begin
      if interpreteDeParametros.valStr('semilla') = 'randomize' then
      begin
        randomize;
        semilla := random(29999);
      end
      else
        semilla := interpreteDeParametros.valInt('semilla');
    end
    else
      semilla := sala.globs.semilla_inicial_opt;

    sala.globs.semilla_inicial_opt := semilla;

    if interpreteDeParametros.valStr( 'ncronicasopt' ) <> '' then
      sala.globs.NCronicasOpt := interpreteDeParametros.valInt( 'ncronicasopt' );

    runOptimizar(sala, nHilosForzados, nTareasForzadas);

    if sala.globs.CF <> nil then
      sala.globs.CF.StoreInArchi(sala.ArchiCF_bin);

    tiempoTotal := Now() - tiempoIni;
    writeln(' Tiempo Total: ', FloatToStrF(tiempoTotal * 24 * 3600,
      ffFixed, 8, 2), 'segs');

    writeln('OK');
    writeln('Sala: ', interpreteDeParametros.valStr('sala'));
    writeln('Monitores: ', interpreteDeParametros.valStr('monitores'));
    writeln('dtini: ', DateTimeToStr(tiempoIni));
    writeln('dtfin: ', DateTimeToStr(now()));
    writeln('Tiempo de calculo [segs]: ', FloatToStrF(
      trunc((now() - tiempoini) * 24 * 3600 * 100) / 100, ffGeneral, 12, 2));

    assignfile(f, 'cmdopt_ok.txt');
    rewrite(f);
    writeln(f, 'OK');
    writeln(f, 'Sala: ', interpreteDeParametros.valStr('sala'));
    writeln(f, 'Monitores: ', interpreteDeParametros.valStr('monitores'));
    writeln(f, 'dtini: ', DateTimeToStr(tiempoIni));
    writeln(f, 'dtfin: ', DateTimeToStr(now()));
    writeln(f, 'Tiempo de calculo [segs]: ', FloatToStrF(
      trunc((now() - tiempoini) * 24 * 3600 * 100) / 100, ffGeneral, 12, 2));
    closefile(f);

    Terminar;

  except
    on E: Exception do
    begin
      assignfile(f, 'cmdopt_err.txt');
      rewrite(f);
      writeln(f, DateTimeToStr(now()));
      writeln(f, 'Exception: ', E.message);
      closefile(f);
      writeln('Exception: ', E.Message);
      halt(0);
    end;
  end;
  uInicioYFinal.AlFinal;
end;


procedure call_RunSimular;
var
  f: textfile;
  semilla: integer;
begin
  interpreteDeParametros := TInterpreteParametros.Create( false );
  archi_sala := interpreteDeParametros.valStr('sala');
  if archi_sala = '' then
  begin
    WriteHelpParametros('cmdsim' );
    exit;
  end;

  {$IFDEF LINUX}
  installHandlers;
{$ENDIF}
  uInicioYFinal.AlInicio;

  nombre_escenario := interpreteDeParametros.valStr('escenario');
  nHilosForzados := interpreteDeParametros.valInt('nhilos', 0);
  nTareasForzadas := interpreteDeParametros.valInt('ntareas', -1);

  SysUtils.deletefile('cmdsim_ok_' + nombre_escenario + '.txt');
  SysUtils.deletefile('cmdsim_err_' + nombre_escenario + '.txt');

  try

    Iniciar;

    nombre_escenario := sala.EscenarioActivo.nombre;
    EnlazarProcedimientos_Sim;

    //sala.Prepararse_;
    //sala.PrepararActualizadorFichasLPD( true );


    sala.PrepararMemoriaYListados;
    if Sala.ContarVariablesDeEstado > 0 then
      Sala.CargarCFFrom_bin;

    if interpreteDeParametros.valStr('semilla') <> '' then
    begin
      if interpreteDeParametros.valStr('semilla') = 'randomize' then
      begin
        randomize;
        semilla := random(29999);
      end
      else
        semilla := interpreteDeParametros.valInt('semilla');
    end
    else
      semilla := sala.globs.semilla_inicial_sim;

    if interpreteDeParametros.valStr('ncronicassim') <> '' then
      sala.globs.NcronicasSim := interpreteDeParametros.valInt('ncronicassim');

    sala.globs.semilla_inicial_sim := semilla;
    setSeparadoresGlobales; // para que escriba en global

    sala.Clear_ResultadosSim;
    runSimular(sala, nHilosForzados, nTareasForzadas);

    setSeparadoresLocales; // para que escriba en global
    try
      filemode := 1;
      assignfile(f, 'cmdsim_ok.txt');
      rewrite(f);
      writeln(f, 'OK');
      writeln(f, 'Sala: ', interpreteDeParametros.valStr('sala'));
      writeln(f, 'Monitores: ', interpreteDeParametros.valStr('monitores'));
      writeln(f, 'dtini: ', DateTimeToStr(tiempoIni));
      writeln(f, 'dtfin: ', DateTimeToStr(now()));
      writeln(f, 'Tiempo de cálculo [segs]: ', FloatToStrF(
        trunc((now() - tiempoini) * 24 * 3600 * 100) / 100, ffGeneral, 12, 2));
      closefile(f);
    except
      writeln('fallo al escribir cmdsim_ok.txt');
      raise Exception.Create('Error al intentar escribir cmdsim_ok.txt');
    end;

    Terminar;
  except
    on E: Exception do
    begin
      assignfile(f, 'cmdsim_err.txt');
      rewrite(f);
      writeln(f, DateTimeToStr(now()));
      writeln(f, 'Exception: ', E.message);
      closefile(f);
    end;
  end;

  uInicioYFinal.AlFinal;
end;

procedure WriteHelpParametros( cmd: string );
begin
  writeln( 'SINTAXIS: ' );
  writeln( '   '+cmd+ ' sala="archivo_sala"  [parametros opcionales] ' );
  writeln;
  writeln( 'Los parámetros opcionales son: ' );
  write( '   semilla={randomize | N} // sustituye el valor especificado en la Sala para la semilla de ' );
  if cmd = 'cmdopt'  then
     writeln( 'optimización.' )
  else
     writeln( 'simulación.' );
  if cmd = 'cmdopt'  then
     writeln( '   ncronicasopt=N // sustituye el valor especificado en la Sala.' );
  if cmd = 'cmdsim' then
    writeln( '   ncronicassim=N // sustituye el valor especificado en la Sala.' );
  writeln( '   escenario="nombre...escenario" // sustituye el valore especificado en la Sala como Escenario Activo.' );
  writeln( '   nhilos=N // fuerza la cantidad de hilos. Si no se especifica intenta detectar y usar el máximo.' );
  writeln( '   ntareas=N // fuerza la cantidad de tareas. Si no se especifica será igual a la cantidad de hilos.' );
  writeln( '   tmp_base="carpeta_base_tmp" // si se especifica se utiliza como raiz para carpetas de resultados.');
  writeln( '   ejecutor=N // si se especifica, se usa para crear la carpeta dentro de la base para resultados.');
  writeln( '   monitores="archivo" // permite especificar un archivo de monitores.' );
  writeln( '   macro="secuencia" // permite especificar una secuencia de comandos sobre la Sala.' );

end;



end.
