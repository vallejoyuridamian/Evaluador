{xDEFINE DBG_UMH}
unit umh_sincrodata;
{
Tmh_SincroData
tiene lo elemental para la ejecución multihilo de tareas.
Una instancia de Tmh_SincroData debe ser creada y destruida por el Distribuidor
del cálculo y compartida con los Workers del calculo.

Cada Worker cuando está pronto para hacer una tarea llama get_Tarea
si obtiene una resultado <> nil debe ponerse a trabajar en la tarea.
Si obtiene nil debe terminar la ejecución del worker.

Cuando el worker termina la ejecución de la tarea llama fin_tarea
lo que implica contabilizar como terminada la tarea y si es la última
del pool de tareas se notifica al distribuidor que se ha finalizado la ultima
tarea de ese paso.

La CriticalSection "cs_Tareas" sirve para que los workers no se interfieran
en la petición de tareas o en la notificación de fin de tareas.
}

{$mode delphi}

interface

uses
  Classes, SysUtils, syncobjs;


type
  TEstadoTarea_mh = (
    ETMH_SinInfo, // implica que la tarea no tiene información útil
    ETMH_Disponible, // tiene la información y est´Disponible para ser asignada
    ETMH_Asignada, // fue asignada y se espera su finalización
    ETMH_Finalizada // fue finalizada la tarea
    );

  TEstadoSincroData_mh = (
    ESDMH_EsperandoNuevasTareas, // noy hay tareas por hacer y se está esperando nuevas
    ESDMH_EsperandoFinTareas, // hay tareas calculandose
    ESDMH_TerminarWorkers // Se terminaron los trabajos y se deben liberar los workers
    );


  TTarea_mh = class
    nid: integer; // ordinal en el array de tareas
    idWorker: integer; // identificador del worker si fue asignada
    estado: TEstadoTarea_mh;
    constructor Create( nid: integer );
  end;

  TDAOfTarea_mh = array of TTarea_mh;

  TSincroData_mh = class;

    TWorker_mh = class(TThread)
    public
      nid: integer;
      aTarea: TTarea_mh;
      iTareaAsignada: integer;
      sincrodata_mh: TSincroData_mh;
    public
      constructor Create( nid: integer; sincrodata_mh: TSincroData_mh );
      procedure Free; virtual;
      procedure Execute; override;
    end;

  TDAOfWorker_mh = array of TWorker_mh;


  TSincroData_mh = class
    private
    cs_Tareas_: TCriticalSection;
    ev_FinDeTareasEncargadas: TEvent;
    ev_TareasDisponibles: TEvent;

    // La llamada del distribuidor notificando nuevas tareas
    // carga el contador en la cantidad de tareas a realizar
    // y pone el esatdo en ESDMH_EsperandoFinTareas.
    // Cada worker al llamar wrk_NotificarAsignarTarea al fin de una tarea
    // decrementa el contador. Cuando llega a CERO se pasa al estado ESDMH_EsperandoNuevasTareas
    // y se notifica al Distribuidor
    cnt_TareasFaltantes: integer;
    iProximaTareaDisponible: integer;

    public
    tareas: TDAOfTarea_mh;
    robots: TDAOfWorker_mh;
    Paso: integer; // para indicar por dónde se va en un proceso multipaso
    Estado: TEstadoSincroData_mh;
    abortarSim: boolean; // en caso de error poner a TRUE para terminar sim

    // por defecto se crea el array de tareas, pero
    // pero en estado _lock para que nadie más que el
    // Distribuidor pueda rellenar las tareas y libear a los workers
    // a trabajar.
    constructor Create( nTareas, nRobots: integer );
    procedure Free;

    // El distribuidor debe llamar "dst_HacerTareas" para dispar
    // el trabajo de los workers.
    // Si esperar = TRUE, el distribuidor queda esperando el fin
    // de las tareas.
    procedure dst_HacerTareas( esperar: boolean; Paso, nTareas: integer );
    procedure dst_esperarTareas;


    // Por esta función los workers notifican el fin de la
    // tarea pasada por parámetro y obtienen una nueva tarea
    // para ejecutar.
    // Si el parámetro aInfoTarea = NIL el worker no estaba ejecutando
    // nada y simplemente se le asigna tarea.
    // Si el resultado es NIL el worker es que se finalizaron todos
    // los trabajos.
    function wrk_AsignarTarea( aWorker: TWorker_mh; aTarea: TTarea_mh ): TTarea_mh;

    // debe ser llamado por los Workers para notificar que abandonan el loop
    procedure wrk_Finalizado( aWroker: TWorker_mh );

    procedure lock_tareas_;
    procedure unlock_tareas_;

    // entra la cs_tareas y escribe
    procedure wrln( s: string );

    procedure start_workers;
    procedure free_workers;

  end;



implementation
var
  mpid: integer;


constructor TTarea_mh.Create( nid: integer );
begin
  inherited Create;
  self.nid:= nid;
end;

constructor TSincroData_mh.Create( nTareas, nRobots: integer );
begin
  inherited Create;
  cs_Tareas_:= TCriticalSection.Create;
  ev_FinDeTareasEncargadas:= TEvent.Create(nil, true, false, 'FinDeTareasEncargadas'+IntToStr( mpid ) );
  ev_TareasDisponibles:= TEvent.Create(nil, true, false, 'TareasDisponibles'+IntToStr( mpid ) );
  setlength( tareas, nTareas );
  setlength( robots, nRobots );
  abortarSim:= false;
  Estado:= ESDMH_EsperandoNuevasTareas;
end;

procedure TSincroData_mh.Free;
var
  k: integer;
begin
  if Length( robots ) > 0 then
    free_workers;
  ev_FinDeTareasEncargadas.Free;
  ev_TareasDisponibles.Free;
  cs_Tareas_.Free;
  for k:= 0 to high( tareas ) do
    tareas[k].Free;
  setlength( tareas,  0 );
end;


procedure TSincroData_mh.wrk_Finalizado( aWroker: TWorker_mh );
begin
 lock_tareas_;
 dec( cnt_TareasFaltantes );
 if cnt_TareasFaltantes <= 0 then
    ev_FinDeTareasEncargadas.SetEvent;
 unlock_tareas_;
end;

function TSincroData_mh.wrk_AsignarTarea( aWorker: TWorker_mh; aTarea: TTarea_mh ): TTarea_mh;
var
  flg_waitfor_nuevas_tareas: boolean;
  flg_comunicar_fin_tareas: boolean;
  res: TTarea_mh;

begin
  flg_waitfor_nuevas_tareas:= true;
  flg_comunicar_fin_tareas:= false;
  res:= nil;

  lock_tareas_;
  {$IFDEF DBG_UMH}
  wrln( 'idRobot: '+IntToStr( aWorker.nid )+' ingreso a wrk_AsignarTarea ' );
  {$ENDIF}

  if aTarea <> nil then
  begin
    aTarea.estado:= ETMH_Finalizada;
    dec( cnt_TareasFaltantes );
  end;

  case Estado of
    ESDMH_EsperandoFinTareas:
      begin
        {$IFDEF DBG_UMH}
        wrln( 'idRobot: '+IntToStr( aWorker.nid )+' ESDMH_EsperandoFinTareas, cnt_TareasFaltantes: '+IntToStr(cnt_TareasFaltantes ) );
        {$ENDIF}
        if ( cnt_TareasFaltantes = 0 ) then
        begin
          Estado:=ESDMH_EsperandoNuevasTareas;
          flg_waitfor_nuevas_tareas:= true;
          flg_comunicar_fin_Tareas:= true;
        end
        else
        begin
          if iProximaTareaDisponible <= high( Tareas ) then
          begin
            res:= tareas[ iProximaTareaDisponible ];
            res.idWorker:= aWorker.nid;
            inc( iProximaTareaDisponible );
            flg_waitfor_nuevas_tareas:= false;
          end
          else
          begin
            ev_TareasDisponibles.ResetEvent;
            flg_waitfor_nuevas_tareas:= true;
          end;
        end;
      end;
    ESDMH_EsperandoNuevasTareas:
    begin
      {$IFDEF DBG_UMH}
      wrln( 'idRobot: '+IntToStr( aWorker.nid )+' ESDMH_EsperandoNuevasTareas, cnt_TareasFaltantes: '+IntToStr(cnt_TareasFaltantes ) );
      {$ENDIF}
      flg_waitfor_nuevas_tareas:= true;
    end;

    ESDMH_TerminarWorkers:
    begin
      {$IFDEF DBG_UMH}
      wrln( 'idRobot: '+IntToStr( aWorker.nid )+' ESDMH_TerminarWorkers, cnt_TareasFaltantes: '+IntToStr(cnt_TareasFaltantes ) );
      {$ENDIF}
      flg_waitfor_nuevas_tareas:= false;
      result:= nil;
    end;
  end;

  // sería raro que esto ocurriera aquí, pero igual lo ponemos.
  if paso < 0 then
  begin
    res:= nil;
    flg_waitfor_nuevas_tareas:= false;
  end;

  if flg_comunicar_fin_tareas then
  begin
    flg_comunicar_fin_tareas:= false;
    ev_FinDeTareasEncargadas.SetEvent;
  end;

  unlock_tareas_;

  while flg_waitfor_nuevas_tareas do
  begin
    {$IFDEF DBG_UMH}
    wrln( 'idRobot: '+IntToStr( aWorker.nid )+' inicio WaitFor' );
    {$ENDIF}
    ev_TareasDisponibles.WaitFor( INFINITE );
    {$IFDEF DBG_UMH}
    wrln( 'idRobot: '+IntToStr( aWorker.nid )+' Me Desperte.' );
    {$ENDIF}
    lock_tareas_;
    if Estado = ESDMH_TerminarWorkers then
    begin
      res:= nil;
      flg_waitfor_nuevas_tareas:= false;
    end
    else if iProximaTareaDisponible <= high( Tareas ) then
    begin
      res:= tareas[ iProximaTareaDisponible ];
      res.idWorker:= aWorker.nid;
      inc( iProximaTareaDisponible );
      flg_waitfor_nuevas_tareas:= false;
    end
    else
     res:= nil;

    if paso < 0 then // si la orden es finalizar ya damos por terminado
    begin
      res:= nil;
      flg_waitfor_nuevas_tareas:= false;
    end;
    unlock_tareas_;
  end;

  result:= res;
end;

procedure TSincroData_mh.dst_HacerTareas( esperar: boolean; Paso, nTareas: integer );
var
  k: integer;

begin
  lock_tareas_;
  Estado:=  ESDMH_EsperandoFinTareas;
  Self.Paso:= Paso;
  if nTareas < 0 then
   cnt_TareasFaltantes:= length( Tareas )
  else
   cnt_TareasFaltantes:= nTareas;

  // Paso negativo indica que la tarea es FINALIZAR los loops
  if Paso < 0 then
   cnt_TareasFaltantes:= length( robots );

  iProximaTareaDisponible:= 0;
  ev_FinDeTareasEncargadas.ResetEvent;
  ev_TareasDisponibles.SetEvent;
  unlock_tareas_;

  if esperar then
    dst_esperarTareas;
end;

procedure TSincroData_mh.lock_tareas_;
begin
     cs_Tareas_.Enter;
end;

procedure TSincroData_mh.unlock_tareas_;
begin
  cs_Tareas_.Leave;
end;

procedure TSincroData_mh.wrln( s: string );
begin
  writeln( s );
end;


procedure TSincroData_mh.start_workers;
var
  k: integer;
begin
  for k:= 0 to high( robots ) do
   robots[k].Start;
end;

procedure TSincroData_mh.free_workers;
var
  k: integer;
begin
  dst_HacerTareas( true, -1, 0 );
  for k:= 0 to high( robots ) do
   robots[k].Free;
  setlength( robots, 0 );
end;

procedure TSincroData_mh.dst_esperarTareas;
var
  res: TWaitResult;
begin
  res:= ev_FinDeTareasEncargadas.WaitFor( INFINITE );
  (*
  repeat
    res:= ev_FinDeTareasEncargadas.WaitFor( 1000 );
      case res of
        wrSignaled: writeln( 'wrSignaled' );
        wrTimeout: writeln('wrTimeout' );
        wrAbandoned: writeln( 'wrAbandoned' );
        wrError: writeln( 'wrError' );
      end;
  until res <> wrTimeOut;
    *)
end;



constructor TWorker_mh.Create( nid: integer; sincrodata_mh: TSincroData_mh );
begin
  inherited Create( true );
  self.FreeOnTerminate := False;
  self.nid:= nid;
  self.sincrodata_mh:= sincrodata_mh;
end;

procedure TWorker_mh.Free;
begin
  inherited Free;
end;


procedure TWorker_mh.Execute;
begin
  aTarea:= sincrodata_mh.wrk_AsignarTarea( self, nil );
  if aTarea = nil then
  begin
   sincrodata_mh.wrln( 'idRobot: '+IntToStr( nid )+' me fui aTarea = NIL' );
   Terminate;
  end;
  while (not Terminated) do
  begin
    // sincrodata_mh.wrln( 'EJECUNTADO :.. idRobot: '+IntToStr( nid )+' calculando tarea: '+ IntToStr( aTarea.nid ) );
    aTarea:= sincrodata_mh.wrk_AsignarTarea( self, aTarea );
    if aTarea = nil then
    begin
      sincrodata_mh.wrln( 'idRobot: '+IntToStr( nid )+' me fui aTarea = NIL' );
      Terminate;
    end;
  end; //while de los pasos

  // aqui trabajos finales
  sincrodata_mh.wrk_Finalizado( Self );
end;

initialization
  mpid:= GetProcessId;

end.


