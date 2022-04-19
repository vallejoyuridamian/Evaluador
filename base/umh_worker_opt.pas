unit umh_worker_opt;

{$MODE Delphi}

interface

uses
  xMatDefs, Classes, SysUtils, usalasdejuego, umh_sincrodata;

type
  TTareaCalcularRangoEstrellas = class(TTarea_mh)
    estrellaIni, estrellaFin: integer;
    constructor Create(nid, estrellaIni, estrellaFin: integer);
  end;

  { TRobotOptRangoEstrellas }

  TRobotOptRangoEstrellas = class(TWorker_mh)
  private
    procedure copiarVarsTiempoEjecucion;
    function Opt_irAPaso(nuevoPaso: integer): integer;
  public
    sala, salaMadre: TSalaDeJuego;
    nTareasCalculadasEstePaso: integer;
  public
    constructor Create(nid: integer; sincroData: TSincroData_mh;
      const sala: TSalaDeJuego);
    procedure Execute; override;
  end;


implementation

constructor TTareaCalcularRangoEstrellas.Create(
  nid, estrellaIni, estrellaFin: integer);
begin
  inherited Create(nid);
  self.estrellaIni := estrellaIni;
  self.estrellaFin := estrellaFin;
end;

constructor TRobotOptRangoEstrellas.Create(nid: integer;
  sincroData: TSincroData_mh; const sala: TSalaDeJuego);
{$IFDEF opt_Dump_PubliVars}
var
  archi: string;
{$ENDIF}

begin
  inherited Create(nid, sincroData);
  self.sala := TSalaDeJuego.cargarSala( nid + 1,
    sala.archiSala_, sala.EscenarioActivo.nombre, True);
  salaMadre := sala;


  {$IFDEF opt_Dump_PubliVars}
  self.sala.f_dbgMH_Open := False;
  {$ENDIF}

  self.sala.globs.idHilo := nid + 1;
  self.sala.SalaMadre:= sala;

  {$IFDEF GLOBS_LOG}
  sala.globs.log_OpenCreate;
  {$ENDIF}


  copiarVarsTiempoEjecucion;
  sala.estabilizarInicio := False;
  self.sala.inicializarOptimizacion(sala, sala.globs.CF.constelacion.fCosto);
  nTareasCalculadasEstePaso := 0;

{$IFDEF opt_Dump_PubliVars}
  archi := self.salaMadre.dirResultadosCorrida + 'opt_Dump_PubliVars_' +
    IntToStr(nid) + '.txt';
  assignfile(self.sala.f_dbgMH, archi);
  rewrite(self.sala.f_dbgMH);
  self.sala.f_dbgMH_Open := True;
  self.sala.publicarTodasLasVariables;
{$ENDIF}
end;



procedure TRobotOptRangoEstrellas.copiarVarsTiempoEjecucion;
begin
  sala.globs.NMAX_ITERACIONESDELPASO_OPT :=
    salaMadre.globs.NMAX_ITERACIONESDELPASO_OPT;
  sala.globs.NMAX_ITERACIONESDELPASO_SIM :=
    salaMadre.globs.NMAX_ITERACIONESDELPASO_SIM;

  sala.globs.SortearOpt := SalaMadre.globs.SortearOpt;
  sala.escribirOptActores := SalaMadre.escribirOptActores;
  sala.globs.TasaDeActualizacion := SalaMadre.globs.TasaDeActualizacion;
  sala.globs.NCronicasOpt := SalaMadre.globs.NCronicasOpt;
  sala.globs.semilla_inicial_opt := SalaMadre.globs.semilla_inicial_opt;
  sala.globs.semilla_inicial_sim := SalaMadre.globs.semilla_inicial_sim;
end;


function TRobotOptRangoEstrellas.Opt_irAPaso(nuevoPaso: integer): integer;
var
  i: integer;
  dPasos: integer;
begin
  sala.globs.Auxs_i0 := SalaMadre.globs.Auxs_i0;
  sala.globs.Auxs_i1 := SalaMadre.globs.Auxs_i1;
  sala.globs.Auxs_r0 := SalaMadre.globs.Auxs_r0;
  sala.globs.Auxs_r1 := SalaMadre.globs.Auxs_r1;

    {$IFDEF PDE_RIESGO}
  sala.globs.HistoCF1_ := salaMadre.globs.HistoCF1_;
  sala.globs.HistoCF1_s := salaMadre.globs.HistoCF1_s;
    {$ENDIF}


  dPasos := sala.globs.kPaso_Opt - nuevoPaso;
  if dPasos > 0 then
  begin
    sala.globs.Fijar_kPaso(nuevoPaso);
    nTareasCalculadasEstePaso := 0;
    Result := 1;
  end
  else if dPasos = 0 then
    Result := 2
  else
    Result := 0;
end;


procedure TRobotOptRangoEstrellas.Execute;
var
  pTarea: TTareaCalcularRangoEstrellas;
begin
  nTareasCalculadasEstePaso := 0;
  pTarea := sincrodata_mh.wrk_AsignarTarea(self, nil) as TTareaCalcularRangoEstrellas;
  aTarea := pTarea;
  if pTarea = nil then
  begin
    Terminate;
  end;

  while (sincrodata_mh.Paso > 0) and (not Terminated) do
  begin
    {
    writeln( 'Robot: '+IntToStr( nid )+' kPaso: '+IntToStr( sincrodata_mh.Paso )+
    ', kEstrellaINI: '+IntTostr( pTarea.estrellaIni ) +', kEstrellaFin: '+IntTostr( pTarea.estrellaFin ));
     }
    Opt_irAPaso(sincrodata_mh.Paso);
    sala.calcularRangoEstrellas(pTarea.estrellaIni, pTarea.estrellaFin, False, False);
    //    writeln( 'Robot: '+IntToStr( nid )+' Calcular_fin '+DateTimeTostr( now ) );
    Inc(nTareasCalculadasEstePaso);
    pTarea := sincrodata_mh.wrk_AsignarTarea(self, aTarea) as
      TTareaCalcularRangoEstrellas;
    aTarea := pTarea;
    if aTarea = nil then
    begin
      Terminate;
    end;
  end; //while de los pasos
  {$IFDEF opt_Dump_PubliVars}
  if self.sala.f_dbgMH_Open then
    CloseFile(sala.f_dbgMH);
  {$ENDIF}
  {$IFDEF GLOBS_LOG}
  sala.globs.log_Close;
  {$ENDIF}

  writeln( 'Voy a sala .free ' );
  sincrodata_mh.lock_tareas_;
  sala.Free;
  sincrodata_mh.unlock_tareas_;

  writeln( 'volvi ... voy a sincrodata_mh.wrk_Finalizado(self)' );
  // aquí podría ir
  sincrodata_mh.wrk_Finalizado(Self);
  writeln( 'volvi de sincrodata_mh.wrk_Finalizado(self)' );
end;

end.
