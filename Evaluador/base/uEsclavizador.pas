unit uEsclavizador;

interface
uses
  uFuentesAleatorias, uEstados, xMatDefs;

type
(* Definición de la clase madre de todas las esclavizadoras *)

  { TEsclavizador }

  TEsclavizador = class(TFuenteAleatoria)
    protected
      procedure copiarJs;
    public
      esclava: TFuenteAleatoria;
      //indica si la esclava registro variables de estado en el manejador de
      //estados
      esclavaConEstadoEnCF: boolean;

      //Es llamado para las fuentes sin estado en CF
      //Fija el estado interno de la fuente en un valor determinado (p.ej el valor esperado)
      procedure fijarEstadoInterno; override;

      procedure calcular_BC; override;
      procedure Optx_nvxs( var ixr, ixd, iauxNReal, iauxInt: integer ); override;
      procedure Optx_RegistrarVariablesDeEstado( adminEstados: TAdminEstados ); override;

      function CostoDirectoDelPaso: NReal; override;      

      function cronicaIdInicio: String; override;

      //En ninguno de los procedimientos se usa (Xs)b
      procedure ActualizarEstadoGlobal( flg_Xs: boolean ); override;      

      function dim_RB: integer; override;
      function dim_X: integer; override;
      function dim_BC: integer; override;

      procedure sim_FinCronicaPrintEstadoFinal( var fsal: textfile ); override;

      procedure sim_PrintResultados_Encab(var fsal: textfile; kencab: integer); override;
      procedure sim_PrintResultados(var fsal: textfile); override;

      procedure publivars; override;
      procedure Depurar_VaraiblesParaSimRes; override;

  end;

implementation

procedure TEsclavizador.fijarEstadoInterno;
begin
  esclava.fijarEstadoInterno;
end;

procedure TEsclavizador.calcular_BC;
begin
  //No hace nada, los bornes calculados de las fuentes esclavizadas se calculan en
  //SorteosDelPaso si se esta simulando u optimizando sin registrar estados en
  //CF, o en prepararPaso_ps si se esta optimizando y se registran estados en CF
end;

procedure TEsclavizador.Optx_nvxs( var ixr, ixd, iauxNReal, iauxInt: integer );
var
  oldIxr, oldIxd: Integer;
begin
  oldIxr:= ixr;
  oldIxd:= ixd;

  esclava.Optx_nvxs(ixr, ixd, iauxNReal, iauxInt);
  esclavaConEstadoEnCF:= (oldIxr <> ixr) or (oldIxd <> ixd);
end;

procedure TEsclavizador.Optx_RegistrarVariablesDeEstado( adminEstados: TAdminEstados );
begin
  esclava.Optx_RegistrarVariablesDeEstado(adminEstados);
end;

function TEsclavizador.CostoDirectoDelPaso: NReal;
begin
  result:= esclava.CostoDirectoDelPaso;
end;

function TEsclavizador.cronicaIdInicio: String;
begin
  result:= esclava.cronicaIdInicio;
end;

procedure TEsclavizador.ActualizarEstadoGlobal( flg_Xs: boolean );
begin
  esclava.ActualizarEstadoGlobal( flg_Xs );
end;

function TEsclavizador.dim_RB: integer;
begin
  result:= esclava.dim_RB;
end;

function TEsclavizador.dim_X: integer;
begin
  result:= esclava.dim_X;
end;

function TEsclavizador.dim_BC: integer;
begin
  result:= esclava.dim_BC;
end;


procedure TEsclavizador.sim_FinCronicaPrintEstadoFinal( var fsal: textfile );
begin
  esclava.sim_FinCronicaPrintEstadoFinal( fsal );
end;

procedure TEsclavizador.sim_PrintResultados_Encab(var fsal: textfile;
  kencab: integer);
begin
  esclava.sim_PrintResultados_Encab(fsal, kencab);
end;

procedure TEsclavizador.sim_PrintResultados(var fsal: textfile);
begin
  esclava.sim_PrintResultados(fsal);
end;

procedure TEsclavizador.publivars;
begin
  esclava.PubliVars;
end;

procedure TEsclavizador.Depurar_VaraiblesParaSimRes;
begin
  esclava.Depurar_VaraiblesParaSimRes;
end;

procedure TEsclavizador.copiarJs;
begin
  jPrimer_RB_:= esclava.jPrimer_RB_;
  jUltimo_RB_:= esclava.jUltimo_RB_;
  jPrimer_Wa_:= esclava.jPrimer_Wa_;
  jUltimo_Wa_:= esclava.jUltimo_Wa_;
  jPrimer_X:= esclava.jPrimer_X;
  jUltimo_X:= esclava.jUltimo_X;
  jPrimer_Xs:= esclava.jPrimer_Xs;
  jUltimo_Xs:= esclava.jUltimo_XS;
  jPrimer_BC:= esclava.jPrimer_BC;
  jUltimo_BC:= esclava.jUltimo_BC;
end;

end.
