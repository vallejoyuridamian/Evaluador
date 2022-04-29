unit umh_worker_sim;

{$mode delphi}

interface

uses
  xMatDefs, Classes, SysUtils, uglobs, usalasdejuego, uEstados, umh_sincrodata;

type
  TTareaSimRangoCronicas = class(TTarea_mh)
    kCronicaIni, kCronicaFin: integer;
    constructor Create(nid, kCronicaIni, kCronicaFin: integer);
  end;

  { TRobotOptRangoEstrellas }

  { TRobotSimRangoCronicas }

  TRobotSimRangoCronicas = class(TWorker_mh)
  private
    procedure copiarVarsTiempoEjecucion;
  public
    sala, salaMadre_: TSalaDeJuego;
    nTareasCalculadasEstePaso: integer;
  public
    constructor Create(nid: integer; sincroData: TSincroData_mh;
      const salax: TSalaDeJuego);
    procedure Free; override;
    procedure Execute; override;
  end;


implementation



constructor TTareaSimRangoCronicas.Create(nid, kCronicaIni, kCronicaFin: integer);
begin
  inherited Create(nid);
  self.kCronicaIni := kCronicaIni;
  self.kCronicaFin := kCronicaFin;
end;

constructor TRobotSimRangoCronicas.Create(nid: integer;
  sincroData: TSincroData_mh; const salax: TSalaDeJuego);
begin
  inherited Create(nid, sincroData);
  sala := TSalaDeJuego.cargarSala( nid +1,
    salax.archiSala_, salax.EscenarioActivo.nombre, True);

  salaMadre_ := salax;    // ojo esto decía sala en lugar de salax???

  sala.globs.idHilo := nid + 1;
  sala.SalaMadre:= salax;

writeln( 'creando robot: ', sala.globs.idHIlo );
  copiarVarsTiempoEjecucion;
  sala.estabilizarInicio := False;
  nTareasCalculadasEstePaso := 0;

  if salax.globs.CF <> nil then
    sala.globs.CF:= salax.globs.CF.CreateParasito
  else
    sala.globs.CF:= nil;
  sala.globs.flg_CF_parasito:= true; // para que no lo borre en el free
  writeln( 'fin creación parásito: ', sala.globs.idHIlo );

  if salax.CFAux <> nil then
     sala.CFAux:= salax.CFAux.CreateParasito

end;

procedure TRobotSimRangoCronicas.Free;
begin
writeln( 'Free worker ... '+ INtToStr( self.nid ) );
  if sala <> nil then
     sala.Free;
  inherited Free;
end;



procedure TRobotSimRangoCronicas.copiarVarsTiempoEjecucion;
begin
  sala.globs.NMAX_ITERACIONESDELPASO_OPT :=
    salaMadre_.globs.NMAX_ITERACIONESDELPASO_OPT;
  sala.globs.NMAX_ITERACIONESDELPASO_SIM :=
    salaMadre_.globs.NMAX_ITERACIONESDELPASO_SIM;

  sala.globs.SortearOpt := SalaMadre_.globs.SortearOpt;
  sala.escribirOptActores := SalaMadre_.escribirOptActores;
  sala.globs.TasaDeActualizacion := SalaMadre_.globs.TasaDeActualizacion;
  sala.globs.NCronicasOpt := SalaMadre_.globs.NCronicasOpt;
  sala.globs.NCronicasSim := SalaMadre_.globs.NCronicasSim;
  sala.globs.semilla_inicial_opt := SalaMadre_.globs.semilla_inicial_opt;
  sala.globs.semilla_inicial_sim := SalaMadre_.globs.semilla_inicial_sim;


  sala.globs.ObligarDisponibilidad_1_Sim := salaMadre_.globs.ObligarDisponibilidad_1_Sim;
  sala.globs.ObligarInicioCronicaIncierto_1_Sim :=  salaMadre_.globs.ObligarInicioCronicaIncierto_1_Sim;
  sala.globs.ObligarDisponibilidad_1_Opt := salaMadre_.globs.ObligarDisponibilidad_1_Opt;


end;




procedure TRobotSimRangoCronicas.Execute;
var
  pTarea: TTareaSimRangoCronicas;
begin
  (*

  if nid = 0 then
  begin
    sala.globs.procNot_InicioCronica:= sala.salaMadre.globs.procNot_InicioCronica;
    sala.globs.procNot_FinCronica:= sala.salaMadre.globs.procNot_FinCronica;
    sala.globs.procNot_InicioSimulacion:= sala.salaMadre.globs.procNot_InicioSimulacion;
    sala.globs.procNot_FinSimulacion:= sala.salaMadre.globs.procNot_FinSimulacion;
    sala.globs.procNot_InicioPaso:= sala.salaMadre.globs.procNot_FinPaso;
  end;
    *)

  nTareasCalculadasEstePaso := 0;
  pTarea := sincrodata_mh.wrk_AsignarTarea(self, nil) as TTareaSimRangoCronicas;
  aTarea := pTarea;
  if pTarea = nil then
  begin
 //   sala.globs.EstadoDeLaSala:= CES_SIMULACION_TERMINADA;
    Terminate;
  end;

  while (sincrodata_mh.Paso > 0) and (not Terminated) do
  begin
    writeln( 'Robot: '+IntToStr( nid )+' kPaso: '+IntToStr( sincrodata_mh.Paso )+
    ', kCronicaIni: '+IntTostr( pTarea.kCronicaIni ) +', kCronicaFin: '+IntTostr( pTarea.kCronicaFin ));

//     if  pTarea.kCronicaFin  >= pTarea.kCronicaIni then
       sala.Simular( nid, true, pTarea.kCronicaIni, pTarea.kCronicaFin );
//     else
//       sala.globs.EstadoDeLaSala:= CES_SIMULACION_TERMINADA;


     //    writeln( 'Robot: '+IntToStr( nid )+' Calcular_fin '+DateTimeTostr( now ) );
    Inc(nTareasCalculadasEstePaso);
    pTarea := sincrodata_mh.wrk_AsignarTarea(self, aTarea) as TTareaSimRangoCronicas;
    aTarea := pTarea;
    if aTarea = nil then
    begin
 //     sala.globs.EstadoDeLaSala:= CES_SIMULACION_TERMINADA;
      Terminate;
    end;
  end; //while de los pasos


  // aquí podría ir
  sincrodata_mh.wrk_Finalizado(Self);
end;

end.
