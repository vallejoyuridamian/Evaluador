{$DEFINE _OPT_kselectordeformador_}

(*+doc

Fuente CEGH - Correlaciones en Espacio Gaussiano con Histograma.
El modelo incluye un núcleo lineal, que sintetiza series temporales
gaussianas. El núcleo lineal capta las correlaciones temporales y espaciales
de las diferentes series.
Estas series gaussianas son luego llevadas a un espacio real mediante un conjunto
de trasformaciones no lineales de forma que el histograma de amplitudes de las
series es el deseado.
Las trasformaciones no lineales pueden variar con el tiempo lo que permite
ir variando el histograma esperado de los valores sintéticos con el tiempo.
El ejemplo de aplicación para el que fue desarrollado el modelo es para sintetizar
series de posibles aportes hidráulicos a las represas y en dicha aplicación
resulta natural hacer variar las transformaciones no lineales según la estación
del año para lograr histogramas diferentes en Primavera que en Verano.

-doc*)
unit uFuenteSintetizador;

interface

uses
  uFuentesAleatorias, MatReal, uCosa,
  uCosaConNombre,
  xMatDefs, fddp,
  uAuxiliares, uEstados,
  uGlobs, uconstantesSimSEE,
  Classes, umodelosintcegh, uDatosHistoricos,
  uFechas, Math, upronostico,
  ufichasdeterminismos_obsoleta,
  uvatespronosticos,
  ugeturlinfo,
  uconsultapronosticoscli;

resourcestring
  rsSintetizadorCEGH = 'Sintetizador CEGH';
  exFaltaEspValorDeterministicoBornes =
    'Falta especificar el valor inicial de alguno de los Bornes en ';
  exNoSuficientesValoresDeterministicosInicializar =
    'No hay suficiente valores determinísticos como para inicial la memoria del filtro.';
  exErrorDiferenteLargoReducirEstado =
    'ERROR, R=NIL AND length(X) <> length(y) en TFuenteSintetizadorCEGH.ReducirEstado';

  rsFichaDe = 'Ficha de';

  exFuenteCEGHFichaFuente = 'TFuenteSintetizadorCEGH.getFichaPD: la fuente "';
  exFechaInvalida = '" no tiene válidas para la fecha ';
  exFuenteCEGHPrepararMemoria = 'TFuenteSintetizadorCEGH.PrepararMemoria: la fuente ';
  exNoTieneMultiplicadorVE =
    ' no tiene especificados suficientes multiplicadores de valores esperados o ';
  exVarianzaEnFicha = 'varianzas en su ficha nro ';
  exFichaEspecificarTantosVEcomoBornes =
    'Cada ficha debe especificar tantos ' +
    'valores esperados y varianzas como bornes de salida tenga la fuente.';
  exErrorDiferenteLargoExpandirEstado =
    'ERROR, RT=NIL y length(X) <> length(' +
    'Y) en TFuenteSintetizadorCEGH.ExpandirEstado';
  exVarianzaDemasiadoGrande =
    'La varianza es demasiado grande. El máximo alcanzable es: ';
  exValorMedioDemasiadoAlto = 'El valor medio es demasiado alto';
  exValorMedioBajo = 'El valor medio es muy bajo';
  exMaximoNumeroIteraciones = 'Salí por número máximo de iteraciones.';
  exNoSeLogroDeformarHistorgramaSerie =
    'CalcularNuevosDeformadores: No se logró ' +
    'deformar el histograma para lograr los valores indicados en la serie "';
  exAcercarVarianzaPromedio =
    'Intente acercar los valores de promedio y ' +
    'varianza objetivo a los originales (multiplicadores a 1).';
  exFaltaValorDeterministicoBorne =
    'Falta especificar el valor deterministico de alguno de los bornes en ';
  exCreandoLaFuente = 'Creando la fuente ';
  exArchivoDatosDuracionDistinta =
    'Especificó un archivo de datos ' +
    'historicos con distinta duración de paso de sorteo que la del archivo del modelo.';
  exBornesArchivoDiferente =
    'Los bornes en el archivo del modelo difieren de ' +
    'los bornes en el archivo de datos historicos.';
  exCEGHInitDatosHistoricosFromFile =
    'TFuenteSintetizadorCEGH.InitDatosHistoricosFromFile: ';

  exLeyendoLaFuente = ' Leyendo la fuente ';


const
  exFuenteSintetizador = 'FuenteSintetizadorCEGH: ';



  (*
      Xs = A1 X[k-1] + A2 X[k-2] + .. An X[k-n]  + B rbg

      Donde A = [ A1; A2;  .. An ]  y B  son las matrices del filtro.

      La dimensión del estado es A.nc                                         paso: 	1	  -2.297	  -2.065	  -2.031	  -1.993	  -1.952	  -1.898	  -1.895	  -1.895	  -1.745	  -1.638	  -1.584	  -1.516	  -1.512	  -1.478	  -1.410	  -1.373	  -1.291	  -1.254	  -1.243	  -1.229	  -1.220	  -1.187	  -1.175	  -1.159	  -1.148	  -1.137	  -1.108	  -1.095	  -1.090	  -1.072	  -1.059	  -1.057	  -1.040	  -1.032	  -1.004	  -0.991	  -0.958	  -0.944	  -0.911	  -0.902	  -0.885	  -0.873	  -0.853	  -0.843	  -0.827	  -0.820	  -0.794	  -0.780	  -0.770	  -0.753	  -0.739	  -0.722	  -0.694	  -0.681	  -0.660	  -0.653	  -0.647	  -0.632	  -0.630	  -0.627	  -0.620	  -0.594	  -0.564	  -0.544	  -0.503	  -0.478	  -0.445	  -0.441	  -0.427	  -0.419	  -0.419	  -0.384	  -0.342	  -0.338	  -0.335	  -0.328	  -0.304	  -0.294	  -0.286	  -0.276	  -0.261	  -0.248	  -0.244	  -0.240	  -0.215	  -0.197	  -0.180	  -0.170	  -0.163	  -0.148	  -0.146	  -0.134	  -0.110	  -0.093	  -0.079	  -0.063	  -0.055	  -0.050	  -0.022	  -0.014	  -0.001	   0.027	   0.042	   0.050	   0.062	   0.079	   0.106	   0.128	   0.134	   0.141	   0.160	   0.164	   0.169	   0.181	   0.192	   0.197	   0.209	   0.215	   0.226	   0.234	   0.258	   0.264	   0.288	   0.310	   0.316	   0.319	   0.322	   0.354	   0.358	   0.369	   0.383	   0.408	   0.420	   0.434	   0.447	   0.462	   0.469	   0.478	   0.485	   0.505	   0.532	   0.559	   0.574	   0.594	   0.616	   0.629	   0.638	   0.641	   0.650	   0.663	   0.688	   0.705	   0.715	   0.731	   0.784	   0.794	   0.804	   0.814	   0.824	   0.840	   0.850	   0.870	   0.885	   0.894	   0.905	   0.919	   0.947	   0.950	   0.980	   0.992	   1.005	   1.020	   1.046	   1.062	   1.104	   1.133	   1.195	   1.222	   1.300	   1.320	   1.401	   1.427	   1.440	   1.465	   1.484	   1.494	   1.500	   1.510	   1.537	   1.557	   1.636	   1.645	   1.668	   1.781	   1.893	   1.906	   1.953	   2.184	   2.470	   3.330
paso: 	2	  -2.575	  -2.064	  -2.031	  -2.004	  -1.965	  -1.923	  -1.895	  -1.895	  -1.763	  -1.743	  -1.642	  -1.588	  -1.519	  -1.512	  -1.467	  -1.411	  -1.365	  -1.262	  -1.237	  -1.220	  -1.179	  -1.158	  -1.133	  -1.110	  -1.092	  -1.077	  -1.066	  -1.057	  -1.035	  -1.024	  -1.003	  -0.991	  -0.967	  -0.947	  -0.922	  -0.913	  -0.897	  -0.888	  -0.880	  -0.860	  -0.844	  -0.828	  -0.818	  -0.780	  -0.755	  -0.739	  -0.699	  -0.692	  -0.679	  -0.658	  -0.650	  -0.631	  -0.629	  -0.627	  -0.620	  -0.604	  -0.586	  -0.557	  -0.544	  -0.526	  -0.495	  -0.478	  -0.462	  -0.446	  -0.444	  -0.442	  -0.425	  -0.420	  -0.398	  -0.361	  -0.339	  -0.333	  -0.327	  -0.320	  -0.311	  -0.307	  -0.299	  -0.289	  -0.286	  -0.281	  -0.265	  -0.263	  -0.258	  -0.220	  -0.197	  -0.182	  -0.164	  -0.158	  -0.148	  -0.139	  -0.130	  -0.108	  -0.093	  -0.085	  -0.062	  -0.048	  -0.026	  -0.016	  -0.014	   0.007	   0.037	   0.058	   0.068	   0.073	   0.087	   0.098	   0.113	   0.130	   0.138	   0.156	   0.164	   0.186	   0.197	   0.205	   0.212	   0.226	   0.231	   0.243	   0.258	   0.285	   0.310	   0.319	   0.322	   0.350	   0.360	   0.370	   0.377	   0.385	   0.420	   0.429	   0.447	   0.462	   0.470	   0.478	   0.495	   0.509	   0.530	   0.537	   0.548	   0.559	   0.590	   0.605	   0.612	   0.628	   0.638	   0.648	   0.661	   0.684	   0.696	   0.724	   0.745	   0.792	   0.799	   0.810	   0.815	   0.840	   0.851	   0.857	   0.878	   0.890	   0.899	   0.907	   0.914	   0.927	   0.948	   0.952	   0.981	   0.996	   1.005	   1.028	   1.053	   1.077	   1.129	   1.134	   1.164	   1.183	   1.230	   1.298	   1.309	   1.327	   1.406	   1.424	   1.472	   1.485	   1.495	   1.501	   1.516	   1.550	   1.629	   1.645	   1.691	   1.812	   1.899	   1.910	   1.920	   1.960	   2.066	   2.276	   2.370	   3.330
paso: 	3	  -2.652	  -2.107	  -2.004	  -1.993	  -1.896	  -1.867	  -1.756	  -1.732	  -1.712	  -1.628	  -1.579	  -1.521	  -1.512	  -1.453	  -1.415	  -1.377	  -1.351	  -1.274	  -1.241	  -1.186	  -1.155	  -1.136	  -1.107	  -1.081	  -1.066	  -1.051	  -1.034	  -1.013	  -1.006	  -0.992	  -0.981	  -0.969	  -0.956	  -0.926	  -0.917	  -0.894	  -0.885	  -0.872	  -0.856	  -0.846	  -0.829	  -0.809	  -0.754	  -0.745	  -0.704	  -0.690	  -0.678	  -0.653	  -0.644	  -0.627	  -0.617	  -0.603	  -0.585	  -0.562	  -0.534	  -0.527	  -0.494	  -0.469	  -0.450	  -0.444	  -0.444	  -0.439	  -0.422	  -0.396	  -0.390	  -0.368	  -0.339	  -0.327	  -0.323	  -0.318	  -0.311	  -0.307	  -0.288	  -0.285	  -0.265	  -0.263	  -0.257	  -0.248	  -0.215	  -0.198	  -0.192	  -0.169	  -0.157	  -0.148	  -0.143	  -0.130	  -0.111	  -0.106	  -0.096	  -0.085	  -0.085	  -0.052	  -0.043	  -0.034	  -0.020	  -0.014	  -0.012	   0.005	   0.019	   0.050	   0.066	   0.071	   0.075	   0.087	   0.089	   0.098	   0.129	   0.135	   0.151	   0.156	   0.178	   0.192	   0.197	   0.205	   0.211	   0.225	   0.226	   0.230	   0.244	   0.259	   0.282	   0.301	   0.316	   0.321	   0.347	   0.354	   0.369	   0.377	   0.411	   0.421	   0.434	   0.446	   0.469	   0.476	   0.487	   0.509	   0.524	   0.537	   0.548	   0.562	   0.581	   0.591	   0.603	   0.610	   0.640	   0.683	   0.693	   0.725	   0.742	   0.768	   0.794	   0.805	   0.811	   0.815	   0.845	   0.856	   0.885	   0.892	   0.905	   0.912	   0.931	   0.948	   0.977	   0.986	   0.996	   1.019	   1.043	   1.064	   1.082	   1.115	   1.132	   1.136	   1.166	   1.187	   1.240	   1.299	   1.315	   1.367	   1.406	   1.419	   1.456	   1.483	   1.491	   1.497	   1.511	   1.539	   1.610	   1.645	   1.794	   1.854	   1.893	   1.904	   1.915	   1.941	   2.042	   2.154	   2.238	   2.407	   2.613	   3.330
paso: 	4	  -2.614	  -2.096	  -2.004	  -1.952	  -1.868	  -1.811	  -1.752	  -1.716	  -1.699	  -1.572	  -1.520	  -1.490	  -1.463	  -1.409	  -1.374	  -1.356	  -1.306	  -1.280	  -1.241	  -1.191	  -1.147	  -1.118	  -1.091	  -1.080	  -1.049	  -1.031	  -1.015	  -1.013	  -0.985	  -0.977	  -0.955	  -0.925	  -0.920	  -0.899	  -0.893	  -0.881	  -0.863	  -0.852	  -0.833	  -0.785	  -0.754	  -0.745	  -0.745	  -0.718	  -0.678	  -0.673	  -0.655	  -0.633	  -0.615	  -0.597	  -0.575	  -0.554	  -0.529	  -0.522	  -0.503	  -0.449	  -0.444	  -0.444	  -0.443	  -0.422	  -0.393	  -0.389	  -0.382	  -0.352	  -0.329	  -0.324	  -0.319	  -0.311	  -0.307	  -0.289	  -0.279	  -0.264	  -0.257	  -0.254	  -0.250	  -0.215	  -0.199	  -0.194	  -0.189	  -0.163	  -0.154	  -0.150	  -0.129	  -0.111	  -0.106	  -0.098	  -0.085	  -0.084	  -0.074	  -0.060	  -0.050	  -0.037	  -0.034	  -0.026	  -0.012	  -0.008	   0.005	   0.016	   0.028	   0.041	   0.051	   0.068	   0.072	   0.076	   0.087	   0.088	   0.095	   0.116	   0.155	   0.156	   0.189	   0.197	   0.208	   0.226	   0.233	   0.246	   0.261	   0.273	   0.301	   0.306	   0.323	   0.333	   0.347	   0.365	   0.377	   0.394	   0.413	   0.433	   0.455	   0.471	   0.481	   0.490	   0.511	   0.523	   0.537	   0.538	   0.547	   0.567	   0.576	   0.591	   0.606	   0.611	   0.622	   0.630	   0.658	   0.671	   0.684	   0.691	   0.710	   0.717	   0.725	   0.735	   0.766	   0.782	   0.803	   0.839	   0.853	   0.867	   0.891	   0.911	   0.930	   0.936	   0.952	   0.966	   0.974	   1.012	   1.022	   1.059	   1.075	   1.119	   1.124	   1.136	   1.148	   1.168	   1.194	   1.206	   1.272	   1.305	   1.324	   1.348	   1.364	   1.384	   1.421	   1.462	   1.485	   1.491	   1.511	   1.545	   1.612	   1.778	   1.844	   1.902	   1.941	   2.109	   2.155	   2.216	   2.334	   2.497	   2.657	   3.255


      El estado completo lo podemos poner como la concatenación de los vectores
      X[k-1] ... X[k-n]

      Los bornes de salida tienen la dimensión de Xs que es A.nf
      Los bornes en el mundo real tienen por consiguiente la misma dimensión A.nf

      La entrada RB:
      En la bornera ponemos el vector primero r[0], (los ruidos blancos)

      El estado; dim_X = A.nc + A.nc (pongo todos los estados en el mundo real por comodidad)
      luego el vector X[k-1] ... X[k-n].
      Luego de eso ponemos las salidas en el mundo real Y[k-1]

      Luego de eso repetimos el estado para X_s

  *)

//La bornera del sintetizador es:
//0                      .. dimRB-1                    -> ruidos blancos de entrada
//jPrimer_X              .. jPrimer_X + (dim_X/2)-1    -> estado gaussiano de este paso
//jPrimer_X + (dim_X/2)  .. jPrimer_X + dim_X -1       -> estado real de este paso
//jPrimer_Xs             .. jPrimer_Xs + (dim_Xs/2)-1  -> estado gaussiano del próximo paso
//jPrimer_Xs + (dim_Xs/2).. jPrimer_Xs + dim_Xs -1     -> estado real del próximo paso
//jPrimer_BC             .. jPrimer_BC + dim_BC-1      -> bornes calculados

//Primero vienen los ruidos blancos hasta dim_RB, luego hasta la mitad de dim_X
//vienen el estado de la fuente en el espacio gaussiano, en la segunda mitad de
//dim_X viene el estado en el espacio normal (los valores que tomaran los bornes),
//luego viene el estado gaussiano y normal del paso siguiente y al final del todo
// los bornes calculados.
type
  TTipoValorEsperadoCEGH = (TTVE_real, TTVE_Gaussiano);
  TDAOfTTipoValorEsperadoCEGH = array of TTipoValorEsperadoCEGH;


  { TFuenteSintetizadorCEGH_auxRec }

  TFuenteSintetizadorCEGH_auxRec = class
      corridaDeterminista: boolean;
  EstadoInicial_Real: TDAofNReal;
  i: integer;
  valoresBorne: TDAofNReal;
  k, j: integer;

  //  cantSesgos: integer;

  // auxiliares para pasar de versión 45,46 a >47
  x_cantsesgo_ruido: integer;
  x_sesgo_ruido: TDAOfDAOfNReal;
  x_factor_ruido: TDAOfNReal;

  x_fechaInisesgo: TFecha;

  x_rangoFechaSesgo: NReal;
  x_NPCC, x_NPLC, x_NPSA, x_NPAC: integer;
  x_aPronostico: TPronostico;
  lDeterminismos: TListaDeCosas;
  xlpd: TListaDeCosas;
  aDeterminismo: TFichaDeterminismo;
  x_arranqueConico, x_determinismoSoloEstadoInicial: boolean;
  x_aPronostico_rangoFechaSesgo: NReal;

  // variables obsoletas de la época de los f
  valorRbVeSeleccionado: boolean;
  valorProbExcedencia: NReal;
  valorCalibControlCono: integer;
  valorCalibIncDesviacion: integer;
  valorCalibMultNormaUno: integer;
  valorCalibCantIteraciones: integer;
  kBornePublicado: integer;
  pronosticos: TPronosticos;

  constructor Create;
  procedure Free;

  end;

  { TFuenteSintetizadorCEGH }

  TFuenteSintetizadorCEGH = class(TFuenteAleatoria)
  private
    ixr: integer;       //Indice de la variable de estado en el conjunto global
    fuenteGaussiana: Tf_ddp_GaussianaNormal;

    //Si simularConDatosHistoricos estos valores apuntan a los indices y pesos
    // necesarios para calcular el proximo valor a apartir de las series histócas
    //    indiceDatosHistoricos: integer;
    //    indiceDatosHistoricos_s: integer;
    indicesDatosHistoricos, indicesDatosHistoricos_s: TDAOfNInt;
    pesosDatosHistoricos, pesosDatosHistoricos_s: TDAOfNReal;
    Desp_IniSim_IniDatosHistoricos: integer;

    //para no crearlos en cada paso
    calcularSalidaBorne: TDAOfBoolean;
    todosLosBornesEnTrue: TDAOfBoolean;


(*
    //Busca en los datos historicos el primer valor cuyo período de validez
    //contenga a fecha sin considerar el anio.
    //fechaIniSorteo <= fecha < fechaFinSorteo comparando solo mes y dia
    //offsetDatos es el desplazamiento en anios desde la fecha de inicio de los
    //valores historicos. El indice se calculara desde
    //datosHistoricos.fechaIni + offsetDatos anios
    // retorna en indiceDatos, el valor del índice que apunta al dato
    //???? no se si se usa
    function getIndiceDato__(fecha: TFecha; nAnios_offsetDatos: integer): integer;
  *)

    procedure InitDatosHistoricosFromFile;

    procedure Sim_Cronica_Inicio_SINTETICAS;
    procedure Sim_Cronica_Inicio_HISTORICAS;

  protected
    procedure GaussianarRafaga(var destino: TDAOfNReal; kBaseDestino: integer;
      const origen: TDAOfNReal; kBaseOrigen: integer;
      NBornesDestino, NRetardosXDestino: integer; NBornesOrigen: integer;
      datosModelo: TModeloCEGH; fecha: TFecha);

    procedure SortearEntradaRB(var aRB: NReal); override;
    procedure ValorEsperadoEntradaRB(var aRB: Nreal); override;
    procedure calcular_jsInicioFinal; override;

  public
    (**************************************************************************)
    (* A T R I B U T O S   P E R S I S T E N T E S                            *)
    (**************************************************************************)
    nombreArchivoModelo: TArchiRef;
    simularConDatosHistoricos: boolean;
    sincronizarConHistoricos: boolean;
    SincronizarConSemillaAleatoria: boolean;
    nombreArchivoDatosHistoricos: TArchiRef;
    usarModeloAuxiliar: boolean;
    nombreArchivoModeloAuxiliar: TArchiRef;

    //Información para introducción de pronósticos mediante sesgos.
    escenarioDePronosticos: TEscenarioDePronosticos;


    //Dirección web para extracción de pronósticos.
    url_get: string;
    (**************************************************************************)


    pronosticosSorteados: TPronosticos;
    sorteadorDePronosticos: TMadreUniforme;


    datosModelo_Sim: TModeloCEGH;

    datosHistoricos: TDatosHistoricos;

    // esto es si queremos que al Optimizar utilice otro modelo
    // diferente al de Simular y además cuando simula
    // usa el modelo auxiliar para establecer el estado global
    // del sistema.
    modeloAuxiliar: TModeloCEGH;
    modeloAuxiliarActivo: boolean;

    // apunta al modelo a usar en la optimización.
    // puede ser datosModelo o modeloAuxiliar según el caso.
    datosModelo_Opt: TModeloCEGH;

    // variables auxiliares
    XRed, XsRed: TDAOfNReal; // estados reducidos de X y Xs
    XRed_aux: TDAOfNReal;

    // Estimación lineal de la diferencia en el costo futuro que ocasiona la evolución
    // del estado de EstadoK_Actual a EstadoK_Aux
    DeltaCosto: NReal;

    //    jPrimer_RBamp, jUltimo_RBamp: integer;
    jPrimer_X_x, jUltimo_X_x: integer;
    // primer X en el vector  de estado Xs (dim A.nc)
    jPrimer_X_y, jUltimo_X_y: integer; // primer y (mundo real ) ( dim A.nf )

    jPrimer_Xs_x, jUltimo_Xs_x: integer;
    // primer X en el vector  de estado Xs (dim A.nc)
    jPrimer_Xs_y, jUltimo_Xs_y: integer; // primer y (mundo real ) ( dim A.nf )


    //******* VARIABLES AUXILIARES PARA OPTIMIZAR TIEMPOS DE CALCULO *****

    // M_amp * M_red
    MaMr:TMatR;

    {$IFDEF RESUMEN_POSTIZADO}
     fdebug: textfile;
    {$ENDIF}


    constructor Create(capa: integer;
      nombre, nombreArchivoModelo, nombreArchivoDatosHistoricos: string;
      simularConDatosHistoricos: boolean;
      SincronizarConHistoricos, sincronizarConSemillaAleatoria: boolean;
      nombreArchivoModeloAuxiliar: string; usarModeloAuxiliar: boolean;
      EscenarioDePronosticos: TEscenarioDePronosticos; resumirPromediando: boolean; url_get: string);


    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    //Luego de asignado el nombre de archivo se carga desde el
    procedure InitModeloFromFile;
    procedure PrepararMemoria( Catalogo: TCatalogoReferencias; globs: TGlobs); override;
    procedure InicioSim; override;
    procedure InicioOpt; override;
    procedure SorteosDelPaso(xsortear: boolean); override;
    function cronicaIdInicio: string; override;
    procedure Sim_Cronica_Inicio; override;
    procedure fijarEstadoInterno; override;

    // Calcula el estado siguiente. Solo calcula Xs, no lo aplica.
    procedure calcular_Xs; override;
    procedure PosicionarseEnEstrellita; override;
    procedure EvolucionarEstado; override;

    procedure ActualizarEstadoGlobal(flg_Xs: boolean); override;

    procedure Optx_nvxs(var ixr, ixd, iauxNReal, iauxInt: integer); override;
    procedure Optx_RegistrarVariablesDeEstado(adminEstados: TAdminEstados); override;

    // carga el deltacosto para el término indep del simplex
    function calc_DeltaCosto: NReal; override;

    // las fuentes con estado tienen que calcular el delta costo
    // por el delta_X resultante del sorteo
    procedure PrepararPaso_ps; override;

    function dim_RB: integer; override;
    function dim_X: integer; override;
    function dim_Wa: integer; override;


    //Retorna el indice del array donde ira el valor de ese borne
    function IdBorne(nombre: string): integer; override;

    // Retorna el nombre del Borne a partir del índice
    function NombreBorne(idBorne: integer): string; override;

    // Calcula el estado reducido a partir del estado X.
    // y= R* X.  Si R=NIL y length(x)=length(y) hace y= x;
    // X forma parte de la bornera a partir de jIniX
    procedure ReducirEstado(var y: TDAofNReal; jIniX: integer;
      const datosModelo: TModeloCEGH; const R: TMatR;
      const Bornera: TDAOfNReal);

    // Calcula el estado sin reducir X a partir del estado reducido y
    // mediante la estimación X= RT* y
    // Si RT= NIL y length(y)=length(x) hace X= y
    //El X esta en la bornera a partir de jIniX
    procedure ExpandirEstado(datosModelo: TModeloCEGH;
      jIniX: integer; var bornera: TDAofNReal; const y: TDAOfNReal);

    //Aplica las funciones deformantes a los valores del estado X en los bornes
    //indicados en calcularBorne
    procedure calcularSalidasDeX(Xs: boolean); overload;
    procedure calcularSalidasDeX(datosModelo: TModeloCEGH;
      Xs: boolean; calcularBorne: TDAOfBoolean); overload;


    procedure Free; override;

    procedure PubliVars; override;

    // retorna indice selector de la función desformante
    // que corresponde al paso de tiempo si fecha es nil y al de la fecha
    //sino.
    function kSelectorDesformador(datosModelo: TModeloCEGH;
      fecha: TFecha): integer;

    function Gaussianar_(datosModelo: TModeloCEGH;
      xNoGaussiana: NReal; kBorne: integer; fecha: TFecha): NReal;

    //Solo para debug
    function descBornera: string; override;
    procedure Dump_Variables(var f: TextFile; charIndentacion: char); override;


    procedure sim_FinCronicaPrintEstadoFinal(var fsal: textfile); override;

    // recalibra los sesgos y atenuadores de acuerdo con los parámetros de los
    // pronósticos.
    procedure ReCalibrarPronosticos(datosModelo: TModeloCEGH;
      fechaIniSim: TFecha);

    // intenta obtener de la dirección url_get los pronósticos
    // de acuerdo a la descripción de los mismos.
    function GetPronosticos(fechaIniSim: TFecha): boolean;


  private
    px: TFuenteSintetizadorCEGH_auxRec;
  end;


procedure cambioFichaPDFuenteSintetizadorCEGH(fuente: TCosa);
procedure AlInicio;
procedure AlFinal;



implementation

uses
  ucalibrarconopronosticos,
  SysUtils;

{ TFuenteSintetizadorCEGH_auxRec }

constructor TFuenteSintetizadorCEGH_auxRec.Create;
begin
  setlength( EstadoInicial_Real, 0 );
  setlength( valoresBorne, 0 );
  setlength( x_sesgo_ruido, 0 );
  setlength( x_factor_ruido, 0 );
  x_fechaInisesgo:= nil;
  x_aPronostico:= nil;
  lDeterminismos:= nil;
  xlpd:= nil;
  aDeterminismo:= nil;
  pronosticos:= nil;
end;

procedure TFuenteSintetizadorCEGH_auxRec.Free;
begin
  setlength( EstadoInicial_Real, 0 );
  setlength( valoresBorne, 0 );
  setlength( x_sesgo_ruido, 0 );
  setlength( x_factor_ruido, 0 );
  (* OJO
  if x_fechaInisesgo <> nil then x_fechaInisesgo.Free;
  if x_aPronostico <> nil then x_aPronostico.Free;
  if lDeterminismos <> nil then lDeterminismos.Free;
  if xlpd <> nil then xlpd.Free;
  if aDeterminismo <> nil then aDeterminismo.Free;
  if pronosticos <> nil then pronosticos.Free;
  *)
end;

{$IFDEF DEBUG_SORTEOS}
var
  fdebug_sorteos: TextFile;

{$ENDIF}



constructor TFuenteSintetizadorCEGH.Create(capa: integer; nombre,
  nombreArchivoModelo, nombreArchivoDatosHistoricos: string;
  simularConDatosHistoricos: boolean; SincronizarConHistoricos,
  sincronizarConSemillaAleatoria: boolean; nombreArchivoModeloAuxiliar: string;
  usarModeloAuxiliar: boolean; EscenarioDePronosticos: TEscenarioDePronosticos;
  resumirPromediando: boolean; url_get: string);
var
  i: integer;
begin
  inherited Create(capa, nombre, 0, resumirPromediando);
 sorteadorDePronosticos:= nil;
  self.nombreArchivoModelo := TArchiRef.Create(nombreArchivoModelo);
  self.simularConDatosHistoricos := simularConDatosHistoricos;
  self.SincronizarConHistoricos := SincronizarConHistoricos;
  self.sincronizarConSemillaAleatoria := sincronizarConSemillaAleatoria;
  self.nombreArchivoDatosHistoricos := TArchiRef.Create(nombreArchivoDatosHistoricos);
  self.nombreARchivoModeloAuxiliar := TArchiRef.Create(nombreArchivoModeloAuxiliar);
  self.usarModeloAuxiliar := usarModeloAuxiliar;
  self.escenarioDePronosticos := escenarioDePronosticos;
  self.url_get := url_get;
  fuenteGaussiana := nil;

  self.datosModelo_Sim := nil;
  InitModeloFromFile;

  if simularConDatosHistoricos then
    InitDatosHistoricosFromFile;

  modeloAuxiliar := nil;
  modeloAuxiliarActivo := False;
  self.usarModeloAuxiliar := False;

end;

function TFuenteSintetizadorCEGH.Rec: TCosa_RecLnk;
begin
    Result:= inherited Rec;

    Result.addCampoDef_archRef('nombreArchivo', nombreArchivoModelo, 0, 10);
    Result.addCampoDef('EstadoInicial_Real', px.EstadoInicial_Real, 0, 10);
    Result.addCampoDef('corridaDeterminista', px.corridaDeterminista, 0, 10);
    Result.addCampoDef_archRef('nombreArchivo', nombreArchivoModelo, 10, 11);
    Result.addCampoDef('lDeterminismos', TCosa(px.lDeterminismos), 10, 11);
    Result.addCampoDef_archRef('nombreArchivo', nombreArchivoModelo, 11 );
    Result.addCampoDef('lpd', TCosa(px.xlpd), 11, 56 );
    Result.addCampoDef('lDeterminismos', TCosa(px.lDeterminismos), 11, 56 );
    Result.addCampoDef('sincronizarConHistoricos', sincronizarConHistoricos, 60 );
    Result.addCampoDef('sincronizarConSemillaAleatoria', sincronizarConSemillaAleatoria, 96 );
    Result.addCampoDef('simularConDatosHistoricos', simularConDatosHistoricos, 11 );
    Result.addCampoDef_archRef('nombreArchivoDatosHistoricos', nombreArchivoDatosHistoricos, 11 );
    Result.addCampoDef('usarModeloAuxiliar', usarModeloAuxiliar, 32 );
    Result.addCampoDef_archRef('nombreArchivoModeloAuxiliar', nombreArchivoModeloAuxiliar, 32 );
    Result.addCampoDef('arranqueConico', px.x_arranqueConico, 37, 56 );
    Result.addCampoDef('determinismoSoloEstadoInicial', px.x_determinismoSoloEstadoInicial, 44, 56 );

    // Lee un campo cantidad NombreCantidad y luego la misma cantidad de vectores de reales
    // todos con el mismo NombreItem
    // Esta función es por compatibilidad con una versión antigua de escritura
    result.addCampoDef_Array_OLD1_(
     'cantsesgo_ruido', // NombreCantidad
     'sesgo_ruido', // NombreItem
     px.x_sesgo_ruido, //  TDAOfDAOfNReal Vector de Vectores items.
     45, 55 );

    Result.addCampoDef('factor_ruido', px.x_factor_ruido, 45, 55 );
    Result.addCampoDef('fechaInisesgo', px.x_fechaInisesgo, 45, 55 );
    Result.addCampoDef('rangoFechaSesgo', px.x_rangoFechaSesgo, 45, 55 );
    Result.addCampoDef('valorRbVeSeleccionado', px.valorRbVeSeleccionado, 47, 55 );
    Result.addCampoDef('valorProbExcedencia', px.valorProbExcedencia, 47, 55 );
    Result.addCampoDef('valorCalibControlCono', px.valorCalibControlCono, 47, 55 );
    Result.addCampoDef('valorCalibIncDesviacion', px.valorCalibIncDesviacion, 47, 55 );
    Result.addCampoDef('valorCalibMultNormaUno', px.valorCalibMultNormaUno, 47, 55 );
    Result.addCampoDef('valorCalibCantIteraciones', px.valorCalibCantIteraciones, 47, 55 );
    Result.addCampoDef('valorSesgoControlCono', px.x_NPCC, 47, 55 );
    Result.addCampoDef('valorSesgoIncDesviacion', px.x_NPAC, 47, 55 );
    Result.addCampoDef('valorSesgoMultNormaUno', px.x_NPLC, 47, 55 );
    Result.addCampoDef('pronosticos', TCosa(px.pronosticos), 55, 143 );
    Result.addCampoDef('url_get', url_get, 127 );
    Result.addCampoDef('escenariosDePronosticos', TCosa(escenarioDePronosticos), 143 );
end;

procedure TFuenteSintetizadorCEGH.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
  px:= TFuenteSintetizadorCEGH_auxRec.Create;
  datosModelo_Sim := nil;
  modeloAuxiliar := nil;
  nombreArchivoModeloAuxiliar := TArchiRef.Create('');
  modeloAuxiliarActivo := False;
  usarModeloAuxiliar := False;
  px.lDeterminismos := nil;
  px.xlpd := nil;
  escenarioDePronosticos := nil;
  px.x_fechaInisesgo := nil;
  SincronizarConHistoricos := False;
  SincronizarConSemillaAleatoria := False;
  sorteadorDePronosticos:= nil;
end;

procedure TFuenteSintetizadorCEGH.AfterRead(version, id_hilo: integer);
  var
    i: integer;
    k, j: integer;

  begin
      inherited AfterRead(version, id_hilo);

    if Version < 10 then
    begin
      px.lDeterminismos := TListaDeCosas.Create(capa, 'lDeterminismos');
      for i := 0 to high( px.EstadoInicial_Real) do
      begin
        px.valoresBorne := copy(px.EstadoInicial_Real, i, 1);
        px.lDeterminismos.Add(TFichaDeterminismo.Create(capa, px.valoresBorne));
      end;
      fuenteGaussiana := nil;
      InitModeloFromFile;
      simularConDatosHistoricos := False;
      nombreArchivoDatosHistoricos := TArchiRef.Create('');
      datosHistoricos := nil;
    end
    else if Version < 11 then
    begin
      fuenteGaussiana := nil;
      InitModeloFromFile;
      simularConDatosHistoricos := False;
      nombreArchivoDatosHistoricos := TArchiRef.Create('');
      datosHistoricos := nil;
    end
    else
    begin
      fuenteGaussiana := nil;
      modeloAuxiliar := nil;
      px.x_sesgo_ruido := nil; // lo asigno a nil para chequear si es asignado más adelante

      if Version < 47 then
      begin
        // información de deformadores
        px.valorRbVeSeleccionado := True;
        px.valorProbExcedencia := 95;
        px.valorCalibControlCono := 10;
        px.valorCalibIncDesviacion := 10;
        px.valorCalibMultNormaUno := 7;
        px.valorCalibCantIteraciones := 20;
        px.x_NPCC := 10;
        px.x_NPLC := 7;
        px.x_NPAC := 17;
      end
      else
      begin
        if Version <= 54 then
        begin
          if (px.x_determinismoSoloEstadoInicial) then
            px.x_NPSA := 0
          else
            px.x_NPSA := px.x_NPCC;
          if px.x_sesgo_ruido <> nil then
          begin
            px.pronosticos := TPronosticos.Create(capa, '');
            for k := 0 to high(px.x_sesgo_ruido) do
            begin

              // ojo la cantidad de retardos no la conozco todavía.
              // le pongo CERO y se ajusta más adelante
              px.x_aPronostico := TPronostico.Create(capa,
                px.x_NPCC, px.x_NPLC, px.x_NPSA, px.x_NPAC, '', '');
              for j := 0 to high(px.x_aPronostico.sesgo) do
              begin
                if j < length(px.x_sesgo_ruido[k]) then
                  px.x_aPronostico.sesgo[j] := px.x_sesgo_ruido[k][j]
                else
                  px.x_aPronostico.sesgo[j] := 0.0;

                if (j < length(px.x_aPronostico.factor)) then
                  if j < length(px.x_factor_ruido) then
                    px.x_aPronostico.factor[j] := px.x_factor_ruido[j]
                  else
                    px.x_aPronostico.factor[j] := 1.0;

              end;
              px.x_aPronostico.fechaIniSesgo.dt := px.x_fechaInisesgo.dt;
              px.x_aPronostico_rangoFechaSesgo := px.x_rangoFechaSesgo;
              px.Pronosticos.Add(px.x_aPronostico);
              setlength(px.x_sesgo_ruido[k], 0);
            end;
            setlength(px.x_sesgo_ruido, 0);
            setlength(px.x_factor_ruido, 0);
            px.x_fechaInisesgo.Free;
            px.pronosticos.reset_DeterminismosUsados;
  //          pronosticos.prepararse(datosModelo_Sim.durPasoDeSorteoEnHoras);
          end;
        end
        else
        begin
          if Version<143 then
          begin
            px.pronosticos.reset_DeterminismosUsados;
            //pronosticos.prepararse(datosModelo_Sim.durPasoDeSorteoEnHoras);
          end;
        end;
      end;

      InitModeloFromFile;

      if (px.lDeterminismos <> nil) then
      begin
        // si llego por aca quiere decir que la sala es un aversión < 56 y
        // el pronóstico si fue creado por existencia de sesgos no está completo
        // pues le faltan los datos guía.
        if (px.pronosticos = nil) then
        begin
          // no hay sesgos, solo determinismos esto
          // lo iterpreto como determinismos PUROS.
          if px.lDeterminismos.Count > 0 then
          begin
            px.pronosticos := TPronosticos.Create(capa, '');
            for k := 0 to px.lDeterminismos.Count - 1 do
            begin
              px.aDeterminismo := TFichaDeterminismo(px.lDeterminismos[k]);
              px.x_NPCC := length(px.aDeterminismo.valores);
              px.x_NPLC := 0;
              px.x_NPSA := px.x_NPCC;
              px.x_NPAC := 0;
              px.x_aPronostico := TPronostico.Create(capa, px.x_NPCC, px.x_NPLC, px.x_NPSA,
                px.x_NPAC, '', '');
              px.pronosticos.add(px.x_aPronostico);
            end;
          end;
        end;

        // bueno ahora copio los determinismos a la guía del pronóstico
        // OJO puede pasar que la guia no tenga el mismo largo que los
        // determinismos por lo que chequeo los largos
        for j := 0 to px.lDeterminismos.Count - 1 do
        begin
          px.aDeterminismo := px.lDeterminismos[j] as TFichaDeterminismo;
          px.x_aPronostico := px.pronosticos[j] as TPronostico;

          if length(px.x_aPronostico.guia) <> length(px.aDeterminismo.valores) then
            setlength(px.x_aPronostico.guia, length(px.aDeterminismo.valores));

          for k := 0 to high(px.aDeterminismo.valores) do
          begin
            px.x_aPronostico.guia[k] := px.aDeterminismo.valores[k];
          end;
        end;

        px.lDeterminismos.Free;
        px.lDeterminismos := nil;
      end;
      if simularConDatosHistoricos then
        InitDatosHistoricosFromFile;
    end;
    if px.xlpd <> nil then
      px.xlpd.Free;


    if Version<143 then
    begin
      self.escenarioDePronosticos:=TEscenarioDePronosticos.Create(0);
      self.escenarioDePronosticos.Add(px.pronosticos, 100);
    end ;

  px.Free;
end;





class function TFuenteSintetizadorCEGH.DescClase: string;
begin
  Result := rsSintetizadorCEGH;
end;

function TFuenteSintetizadorCEGH.kSelectorDesformador(
  datosModelo: TModeloCEGH; fecha: TFecha): integer;
var
  res: integer;
begin
  // esta función hace lo mismo que la de igual nombre de TModeloSintetizadorCEGH, pero
  // por eficiencia aquí se puede utilizar aprovechando lo ya calculado en las variables de
  // globs para inicio del paso.
  if fecha = nil then
  begin
  {$IFDEF _OPT_kselectordeformador_}
    case datosModelo.durPasoDeSorteoEnHoras of
      730: res := globs.MesInicioDelPaso - 1; // mensual
      672: res := (globs.SemanaInicioDelPaso - 1) div 4; // 4-semanas
      336: res := (globs.SemanaInicioDelPaso - 1) div 2;  // bi-semanal
      168: res := globs.SemanaInicioDelPaso - 1; // semanal
      24: if datosModelo.nPuntosPorPeriodo = 7 then
         res:= globs.DiaDeLaSemanaInicioDelPaso -1 // 0 Domingo
         else
         res := min(globs.DiaDelAnioInicioDelPaso - 1, 364); // Diario,
      1: res := globs.HoraDelAnioInicioDelPaso; // Horario
      else
        raise Exception.Create(rs_kSelectorDeformador + ' ' +
          IntToStr(durPasoDeSorteoEnHoras));
    end;
    res := res mod datosModelo.nPuntosPorPeriodo;
  {$ELSE}
    res := datosModelo.kSelectorDeformador(globs.FechaInicioDelPaso);
  {$ENDIF}
  end
  else
    res := datosModelo.kSelectorDeformador(fecha);
  Result := res;
end;


function TFuenteSintetizadorCEGH.descBornera: string;
begin
  Result :=
    'RB: ' + IntToStr(jPrimer_RB_) + '..' + IntToStr(jUltimo_RB_) +
    #10 + 'Wa: ' + IntToStr(jPrimer_Wa_) + '..' + IntToStr(jUltimo_Wa_) +
    #10 + 'X: ' + IntToStr(jPrimer_X_x) + '..' + IntToStr(jUltimo_X_x) +
    #10 + 'Y: ' + IntToStr(jPrimer_X_y) + '..' + IntToStr(jUltimo_X_y) +
    #10 + 'Xs: ' + IntToStr(jPrimer_Xs_x) + '..' + IntToStr(jUltimo_Xs_x) +
    #10 + 'Ys: ' + IntToStr(jPrimer_Xs_y) + '..' + IntToStr(jUltimo_Xs_y) +
    #10 + 'BC: ' + IntToStr(jPrimer_BC) + '..' + IntToStr(jUltimo_BC);
end;

procedure TFuenteSintetizadorCEGH.Dump_Variables(var f: TextFile;
  charIndentacion: char);
begin
  inherited Dump_Variables(f, charIndentacion);
  Writeln(f, charIndentacion, descBornera);
end;

procedure TFuenteSintetizadorCEGH.sim_FinCronicaPrintEstadoFinal(var fsal: textfile);
var
  k: integer;
  val: NReal;
begin
  for k := 0 to NombresDeBornes_Publicados.Count - 1 do
  begin
    val := Bornera[jPrimer_X_y + k];
    writeln(fsal, Nombre + '.' + NombresDebornes_Publicados[k] +
      ' = ' + FloatToStr(val));
  end;
end;

function TFuenteSintetizadorCEGH.cronicaIdInicio: string;
begin
  if simularConDatosHistoricos then
    if SincronizarConHistoricos then
      Result := Self.ClaseNombre + #9 + IntToStr(globs.AnioInicioDelPaso)
    else
      Result := Self.ClaseNombre + #9 + IntToStr(datosHistoricos.anioIni +
        ((globs.kCronica - 1) mod datosHistoricos.nAniosDatos_Min)) +
        ', ' + IntToStr(indicesDatosHistoricos[0])
  else
    Result := '';
end;


procedure TFuenteSintetizadorCEGH.Sim_Cronica_Inicio_SINTETICAS;
var
  kBorne, jRetardo: integer;
  aPronostico: TPronostico;
  j_x, j_y: integer;
  mval: NReal;
  fechaDelDato: TFecha;

  p: NReal;

begin // simulando con series Sintéticas

  fechaDelDato := TFecha.Create_Dt(globs.fechaIniSim.dt);


  if escenarioDePronosticos.Count > 1 then
    p := sorteadorDePronosticos.rnd
  else
    p := 1;

  pronosticosSorteados:=escenarioDePronosticos.GetEscenarioPorP(P*100);

  if pronosticosSorteados.Count <> datosModelo_Sim.nBornesSalida then
    raise Exception.Create(exFaltaEspValorDeterministicoBornes + Self.nombre);


  for kBorne := 0 to NombresDeBornes_Publicados.Count-1 do
  begin

    aPronostico := pronosticosSorteados[kBorne];
    if length(aPronostico.guia) < datosModelo_Sim.nRetardos then
      raise Exception.Create(exFuenteSintetizador + Nombre + '. ' +
        exNoSuficientesValoresDeterministicosInicializar);

    for jRetardo := 0 to datosModelo_Sim.nRetardos - 1 do
    begin
      fechaDelDato.PonerIgualA(globs.fechaIniSim);
      fechaDelDato.addHoras(-jRetardo * durPasoDeSorteoEnHoras);
      j_x := jPrimer_X_x + jRetardo * datosModelo_Sim.nBornesSalida;
      j_y := jPrimer_X_y + jRetardo * datosModelo_Sim.nBornesSalida;

      mval := aPronostico.guia[datosModelo_Sim.nRetardos - 1 - jRetardo];
      Bornera[j_x + kBorne] :=
        gaussianar_(datosModelo_Sim, mval, kBorne, fechaDelDato);
      Bornera[j_y + kBorne] := mval;
    end;
    aPronostico.cantValoresDeterministicosUsados := datosModelo_Sim.nRetardos;
  end;
  fechaDelDato.Free;
end;


procedure TFuenteSintetizadorCEGH.Sim_Cronica_Inicio_HISTORICAS;
var
  kBorne, jRetardo: integer;
  aPronostico: TPronostico;
  j_x, j_y: integer;
  mval: NReal;
  dt_dato: double;
  fechaDelDato: TFecha;
  P: NReal;
begin

  fechaDelDato := TFecha.Create_Clone(globs.fechaIniSim);

  if escenarioDePronosticos.Count > 1 then
    p := sorteadorDePronosticos.rnd
  else
    p := 1;

  pronosticosSorteados:=escenarioDePronosticos.GetEscenarioPorP( P*100);

  for jRetardo := 0 to datosModelo_Sim.nRetardos - 1 do
  begin
    dt_dato := globs.fechaIniSim.dt - jRetardo * dt_PasoDeSorteo;

    if sincronizarConSemillaAleatoria then
      datosHistoricos.calc_indices_y_pesos_dt(
        Desp_IniSim_IniDatosHistoricos - globs.ultimaSemillaFijada,
        dt_dato,
        indicesDatosHistoricos, pesosDatosHistoricos)
    else
      if sincronizarConHistoricos then
      datosHistoricos.calc_indices_y_pesos_dt(
        Desp_IniSim_IniDatosHistoricos,
        dt_dato,
        indicesDatosHistoricos, pesosDatosHistoricos)
      else
      datosHistoricos.calc_indices_y_pesos_dt(
        Desp_IniSim_IniDatosHistoricos - globs.kCronica,
        dt_dato,
        indicesDatosHistoricos, pesosDatosHistoricos);


    j_x := jPrimer_X_x + jRetardo * datosModelo_Sim.nBornesSalida;
    j_y := jPrimer_X_y + jRetardo * datosModelo_Sim.nBornesSalida;

    fechaDelDato.dt := dt_dato;
    for kBorne := 0 to datosModelo_Sim.nBornesSalida - 1 do
    begin
      mval := datosHistoricos.get_mval_(kBorne, IndicesDatosHistoricos,
        PesosDatosHistoricos);
      Bornera[j_x + kBorne] :=
        gaussianar_(datosModelo_Sim, mval, kBorne, fechaDelDato);
      Bornera[j_y + kBorne] := mval;
    end;
  end;
  fechaDelDato.Free;

end;

procedure TFuenteSintetizadorCEGH.Sim_Cronica_Inicio;
begin
  inherited Sim_Cronica_Inicio;
  if not simularConDatosHistoricos then
    Sim_Cronica_inicio_SINTETICAS
  else // simulando con series Históricas
    Sim_Cronica_Inicio_HISTORICAS;
end;

procedure TFuenteSintetizadorCEGH.fijarEstadoInterno;
var
  i: integer;
  dm: TModeloCEGH;
begin

  if globs.EstadoDeLaSala = CES_SIMULANDO then
  begin
    assert(datosModelo_Sim.nVE = 0,
      'TFuenteSintetizadorCEGH.setEstadoInterno con nVE= ' +
      IntToStr(datosModelo_Sim.nVE) + ' debe ser 0');
    dm := datosModelo_Sim;
  end
  else
  begin
    assert(datosModelo_Opt.nVE = 0,
      'TFuenteSintetizadorCEGH.setEstadoInterno con nVE= ' +
      IntToStr(datosModelo_Opt.nVE) + ' debe ser 0');
    dm := datosModelo_Opt;
  end;
  for i := jPrimer_X_x to jUltimo_X_x do
    Bornera[i] := 0; // Pongo el valor de Probabilidad 50%
  calcularSalidasDeX(dm, False, todosLosBornesEnTrue);
end;

procedure TFuenteSintetizadorCEGH.PosicionarseEnEstrellita;
var
  i: integer;

  ax: NReal;
  j: integer;
  fila: TVectR;

  aPronostico: TPronostico;
  usarCono: TDAOfBoolean;
  kSesgo: TDAOfNInt;
  kFactor: TDAofNInt;
  kSerie: integer;

begin

  setlength(usarCono, pronosticosSorteados.Count);
  setlength(kSesgo, pronosticosSorteados.Count);
  setlength(kFactor, pronosticosSorteados.Count);

  for kSerie := 0 to pronosticosSorteados.Count - 1 do
  begin
    aPronostico := TPronostico(pronosticosSorteados.items[kSerie]);
    usarCono[kSerie] := aPronostico.fechaEnRango(globs.FechaInicioDelpaso,
      kSesgo[kSerie], kFactor[kSerie]);
  end;

  if datosModelo_Opt.nVE = 0 then
  begin
    for i := jPrimer_X_x to jUltimo_X_x do
    begin
      kSerie := (i - jPrimer_X_x) mod pronosticosSorteados.Count;
      aPronostico := pronosticosSorteados.items[kSerie];
      ax:=0;
      // hay informacion de pronosticos
      if (kSesgo[kSerie] >= 0) and (kSesgo[kSerie]<= High(aPronostico.guia_eg))  then
        ax := ax + aPronostico.guia_eg[kSesgo[kSerie]];

      // Calculamos el estado expandido x= MAmp * y + BAmp * R
      if datosModelo_Opt.BAmp_Cte <> nil then
      begin
        fila := datosModelo_Opt.BAmp_Cte.fila(kserie + 1);
        for j := 1 to datosModelo_Opt.BAmp_Cte.nc do
          ax := ax + fila.e(j) * bornera[jPrimer_Wa_ + j - 1];
      end;
      Bornera[i] := ax;
    end;
  end
  else
  begin
    // copiamos el estado reducido
    for i := 0 to high(XRed) do
      XRed[i] := globs.CF.xr[self.ixr + i];

    // expandimos el reducido para posicionar el no reducido
    ExpandirEstado(datosModelo_Opt, jPrimer_X_x, Bornera, XRed);

  end;
  calcularSalidasDeX(datosModelo_Opt, False, todosLosBornesEnTrue);

  setlength(usarCono, 0);
  setlength(kSesgo, 0);
  setlength(kFactor, 0);

end;

procedure TFuenteSintetizadorCEGH.calcular_jsInicioFinal;
begin
  inherited calcular_jsInicioFinal;
  // calculamos los indices auxiliares en las borneras
  jPrimer_X_x := jPrimer_x; // primer X en el vector  de estado Xs (dim A.nc)
  if datosModelo_Sim.A_cte <> nil then
    jUltimo_X_x := jPrimer_X_x + datosModelo_Sim.A_cte.nc - 1
  else
    jUltimo_X_x := jPrimer_X_x + datosModelo_Sim.mcA[0].nc - 1;

  jPrimer_X_y := jUltimo_X_x + 1; // primer y (mundo real ) ( dim A.nf )

  if datosModelo_Sim.A_cte <> nil then
    jUltimo_X_y := jPrimer_X_y + datosModelo_Sim.A_cte.nc - 1
  else
    jUltimo_X_y := jPrimer_X_y + datosModelo_Sim.mcA[0].nc - 1;


  jPrimer_Xs_x := jPrimer_X_x + dim_x; // primer X en el vector  de estado Xs (dim A.nc)
  jUltimo_Xs_x := jUltimo_X_x + dim_x;
  jPrimer_Xs_y := jPrimer_X_y + dim_x; // primer y (mundo real ) ( dim A.nf )
  jUltimo_Xs_y := jUltimo_X_y + dim_x;
end;


procedure TFuenteSintetizadorCEGH.PrepararMemoria(
  Catalogo: TCatalogoReferencias; globs: TGlobs);
var
  i: integer;
begin

  inherited PrepararMemoria(Catalogo, globs);
  fuenteGaussiana := Tf_ddp_GaussianaNormal.Create(sorteadorUniforme, 0);

  // Creo el sorteador de escenarios independiente del sorteadorUniforme
  // para no alterar el orden los sorteos

  if sorteadorDePronosticos = nil then
      sorteadorDePronosticos:= globs.madresUniformes.Get_NuevaMadreUniforme(get_hash_nombre+1543);

  escenarioDePronosticos.prepararse( durPasoDeSorteoEnHoras );

  SetLength(calcularSalidaBorne, datosModelo_Sim.nBornesSalida);
  SetLength(todosLosBornesEnTrue, datosModelo_Sim.nBornesSalida);
  for i := 0 to datosModelo_Sim.nBornesSalida - 1 do
    todosLosBornesEnTrue[i] := True;

  if simularConDatosHistoricos then
  begin
    datosHistoricos.setLength_indices_y_pesos(indicesDatosHistoricos,
      pesosDatosHistoricos);
    datosHistoricos.setLength_indices_y_pesos(
      indicesDatosHistoricos_s, pesosDatosHistoricos_s);
    if sincronizarConHistoricos then
     Desp_IniSim_IniDatosHistoricos := 0
    else
    Desp_IniSim_IniDatosHistoricos :=
      (globs.fechaIniSim.anio - datosHistoricos.fechaIni.anio) + 1;
  end;


end;

procedure TFuenteSintetizadorCEGH.InicioSim;
begin
  inherited InicioSim;
  self.ReCalibrarPronosticos(datosModelo_Sim, self.globs.fechaIniSim);

end;

procedure TFuenteSintetizadorCEGH.InicioOpt;
begin
  inherited InicioOpt;

  self.ReCalibrarPronosticos(datosModelo_Opt, self.globs.fechaIniSim);

  MaMr:=nil;
  with datosModelo_Opt do
  begin
    if MRed<>nil then
    begin
      MaMr:=TMatR.Create_Init(MAmp_cte.nf, MRed.nc);
      MaMr.Mult(MAmp_cte, MRed);
    end;
  end;
end;

procedure TFuenteSintetizadorCEGH.SorteosDelPaso(xsortear: boolean);
var
  p: NReal;
begin
  inherited SorteosDelPaso(xsortear);

  // En este procedimiento el sorteo de escenarios se debe ralizar solo para la
  // optimizacion, ya que en cada cronica se elije un escenario.
  // Para la simulacion el sorteo se realiza una unica vez por cronica en Sim_Cronica_Inicio

  if self.globs.EstadoDeLaSala=CES_OPTIMIZANDO then
  begin
    if escenarioDePronosticos.Count > 1 then
      p := sorteadorDePronosticos.rnd
    else
      p := 1;

    pronosticosSorteados:=escenarioDePronosticos.GetEscenarioPorP(P*100);

  end;

end;



function TFuenteSintetizadorCEGH.IdBorne(nombre: string): integer;
begin
  Result :=
    Dim_Rb + // salto los rb
    Dim_Wa + datosModelo_Sim.A_nc + // salto las x
    NombresDeBornes_Publicados.IndexOf(nombre);
end;

function TFuenteSintetizadorCEGH.NombreBorne(idBorne: integer): string;
var
  k: integer;
begin
  k := idBorne - Dim_Rb - Dim_Wa - datosModelo_Sim.A_nc;
  if (k < 0) or (k >= NombresDeBornes_Publicados.Count) then
    Result := '?'
  else
    Result := NombresDeBornes_Publicados[k];
end;

procedure TFuenteSintetizadorCEGH.ReducirEstado(var y: TDAofNReal;
  jIniX: integer; const datosModelo: TModeloCEGH;
  const R: TMatR; const Bornera: TDAOfNReal);
var
  i, j: integer;
  fila: TVectR;
  ay: NReal;
begin
  if R <> nil then
  begin
    // Calculamos el estado reducido y= R*x
    for i := 1 to R.nf do
    begin
      ay := 0;
      fila := R.Fila(i);
      for j := 1 to R.nc do
        ay := ay + fila.e(j) * bornera[jIniX + j - 1];
      y[i - 1] := ay;
    end;
  end
  else if length(y) = datosModelo.nVE then
  begin
    for i := 0 to datosModelo.nVE - 1 do
      y[i] := bornera[i];
  end
  else
    raise Exception.Create(exErrorDiferenteLargoReducirEstado);
end;

procedure TFuenteSintetizadorCEGH.ExpandirEstado(datosModelo: TModeloCEGH;
  jIniX: integer; var bornera: TDAofNReal; const y: TDAOfNReal);
var
  i, j: integer;
  fila: TVectR;
  ax: NReal;
  aPronostico: TPronostico;
  usarCono: TDAOfBoolean;
  kSesgo: TDAOfNInt;
  kFactor: TDAofNInt;
  kSerie: integer;

  guia_eg: TVectR;
  Id: TMatR;

begin

  Id:=TMatR.Create_identidad(MaMr.nf);

  // MAmp_cte no asignada indica que hay reduccion de estados !

  if datosModelo.MAmp_cte <> nil then
  begin
    setlength(usarCono, pronosticosSorteados.Count);
    setlength(kSesgo, pronosticosSorteados.Count);
    setlength(kFactor, pronosticosSorteados.Count);

    guia_eg := TVectR.Create_Init(pronosticosSorteados.Count);
    for kSerie := 0 to pronosticosSorteados.Count - 1 do
    begin
      aPronostico := TPronostico(pronosticosSorteados.items[kSerie]);
      usarCono[kSerie] := aPronostico.fechaEnRango(globs.FechaInicioDelpaso,
        kSesgo[kSerie], kFactor[kSerie]);

      if (kSesgo[kSerie]>=0)and(kSesgo[kSerie]<length(aPronostico.guia_eg)) then
        guia_eg.pon_e(kSerie, aPronostico.guia_eg[kSesgo[kSerie]])
      else
        guia_eg.pon_e(kSerie,0.0);
    end;

    // Calculamos el estado expandido x= MAmp * y
    for i := 1 to datosModelo.MAmp_cte.nf do
    begin
      ax := 0;
      fila := datosModelo.MAmp_cte.Fila(i);
      for j := 1 to datosModelo.MAmp_cte.nc do
        ax := ax + fila.e(j) * y[j - 1];

      // Calculamos el estado expandido x= MAmp * y + BAmp * R
      if datosModelo.BAmp_cte <> nil then
      begin
        fila := datosModelo.Bamp_cte.fila(i);
        for j := 1 to datosModelo.Bamp_cte.nc do
          ax := ax + fila.e(j) * bornera[jPrimer_Wa_ + j - 1];
        // se supone que los ruidos están al arranque
      end;

      if (MaMr<>nil) then
      begin
        Id.Fila(i).res(MaMr.Fila(i));
        ax := ax + Id.Fila(i).PEV(guia_eg);
      end;

      bornera[jIniX + i - 1] := ax;
    end;

    guia_eg.Free;
  end
  else
  if datosModelo.nVE = length(y) then
  begin
    for i := 0 to datosModelo.nVE - 1 do
      bornera[jIniX + i] := y[i];
  end
  else
    raise Exception.Create(exErrorDiferenteLargoExpandirEstado);

  Id.Free;
end;

procedure TFuenteSintetizadorCEGH.ActualizarEstadoGlobal(flg_Xs: boolean);
var
  i: integer;
  tBornera: TDAOfNreal;
begin
  //rch@20140826  OJO , por ahora ingnoro flg_Xs

  if (globs.EstadoDeLaSala = CES_SIMULANDO) and (datosModelo_Opt <>
    datosModelo_Sim) then
  begin
    setlength(tBornera, length(bornera));
    // convertir estados del modelo simulador al optimizador
    if globs.CFauxActivo then
      // atención estoy suponiendo que el CFAux es manejable con el modelo usado en Sim.
      gaussianarRafaga(
        tBornera, jPrimer_X_x,  // destino
        Bornera, jPrimer_X_y,   // origen
        datosModelo_Sim.A_nc, datosModelo_Sim.nRetardos,
        datosModelo_Sim.A_nc, // nBornes del Origen.
        datosModelo_Sim, globs.FechaInicioDelpaso)
    else
      gaussianarRafaga(
        tBornera, jPrimer_X_x,  // destino
        Bornera, jPrimer_X_y,   // origen
        datosModelo_Opt.A_nc, datosModelo_Opt.nRetardos,
        datosModelo_Sim.A_nc, // nBornes del Origen.
        datosModelo_Opt, globs.FechaInicioDelpaso);

  end
  else
    tBornera := Bornera;

  if not globs.CFauxActivo or (datosModelo_Opt.MRed_aux = nil)
  // si no hay un reductor especial uso el mismo del principal
  then
  begin
    if datosModelo_Opt.MRed <> nil then
    begin

      // Calculamos el estado reducido y= R*x
      ReducirEstado(XRed, jPrimer_X_x, datosModelo_Opt, datosModelo_Opt.MRed, tBornera);
      for i := 0 to high(XRed) do
        globs.CF.xr[self.ixr + i] := XRed[i];
    end
    else if datosModelo_Opt.nVE > 0 then
    begin
      //Los estados estan sin reducir. Son los que estan en el administrador de
      //estados
      for i := 0 to datosModelo_Opt.nVe - 1 do
        globs.CF.xr[self.ixr + i] := tBornera[jPrimer_X_x + i];
      //  aplicarFunciones;
    end;
  end
  else
  begin
    if datosModelo_Opt.MRed_aux <> nil then
    begin
      // Calculamos el estado reducido y= R*x
      ReducirEstado(XRed_aux, jPrimer_X, datosModelo_Opt,
        datosModelo_Opt.MRed_aux, tBornera);

      for i := 0 to high(XRed_aux) do
        globs.CF.xr[self.ixr + i] := XRed_aux[i];
    end
    else if datosModelo_Opt.nVE_aux > 0 then
    begin
      //Los estados estan sin reducir. Son los que estan en el administrador de
      //estados
      for i := 0 to datosModelo_Opt.nVE_aux do
        globs.CF.xr[self.ixr + i] := tBornera[jPrimer_X + i];
      //  aplicarFunciones;
    end;
  end;
  if tBornera <> Bornera then
    setlength(tBornera, 0);
end;

procedure TFuenteSintetizadorCEGH.Optx_nvxs(var ixr, ixd, iauxNReal, iauxInt: integer);
begin
  self.ixr := ixr;
  ixr := ixr + datosModelo_Opt.nVE;
end;

procedure TFuenteSintetizadorCEGH.Optx_RegistrarVariablesDeEstado(
  adminEstados: TAdminEstados);
var
  i: integer;
  xmin, xmax: double;
  area, deltaArea: double;
  j: integer;
  xt: double;
  dn: Tf_ddp_GaussianaNormal;
  probs: TDAOfNReal;

  dx_pcd, min_dx_pcd: NReal;

begin
  dn := Tf_ddp_GaussianaNormal.Create(nil, 0);

  min_dx_pcd := 10; // un valor grande para ser susitituido en la búsqueda

  for i := 0 to datosModelo_Opt.nVE - 1 do
  begin
    xmax := 2.5; // por poner algo * (nDiscsVsE[i] -1) / (nDiscsVsE[i] + 1);
    xmin := -xmax;
    adminEstados.Registrar_Continua(ixr + i, xmin, xmax,
      datosModelo_Opt.nDiscsVsE[i], datosModelo_Opt.nombreVarE[i], 'p.u. GN' // unidades
      );

    probs := datosModelo_Opt.ProbsVsE[i]; // referenciamos el vector
    area := 0;
    for j := 0 to datosModelo_opt.nDiscsVsE[i] - 1 do
    begin
      deltaArea := probs[j] / 2.0;
      area := area + deltaArea;
      xt := dn.t_area(area);
      adminEstados.xr_def[ixr + i].x[j] := xt;
      if j > 0 then
      begin
        dx_pcd := adminEstados.xr_def[ixr + i].x[j] -
          adminEstados.xr_def[ixr + i].x[j - 1];
        if dx_pcd < min_dx_pcd then
          min_dx_pcd := dx_pcd;
      end;
      area := area + deltaArea;
    end;
    adminEstados.xr_def[ixr + i].dx_pcd := min_dx_pcd;
  end;

  dn.Free;
end;

// las fuentes con estado tienen que calcular el delta costo
// por el delta_X resultante del sorteo
procedure TFuenteSintetizadorCEGH.PrepararPaso_ps;
var
  k: integer;
  dxred, dx: TDAOfNReal;
begin
  // La variación del costo por la variación (involuntaria) del estado
  DeltaCosto := 0;
  calcular_Xs;

  if (globs.EstadoDeLaSala = CES_OPTIMIZANDO) then
  begin
    if datosModelo_Opt.nVE = 0 then
      exit;

    setlength(dxred, datosModelo_Opt.nVE);
    setlength(dx, datosModelo_Opt.A_nc);
    for k := 0 to high(dx) do
      dx[k] := bornera[jPrimer_Xs + k] - bornera[jPrimer_X + k];

    ReducirEstado(dxred, 0, datosModelo_Opt, datosModelo_Opt.MRed, dx);

    // writeln( 'Fuente Sintetizador PreparaPaso_ps: ', self.nombre );
    for k := 0 to datosModelo_Opt.nVE - 1 do
      DeltaCosto := DeltaCosto + globs.CF.deltaCosto_vxr_continuo(
        ixr + k, globs.kPaso_Opt + 1, dxred[k]);
    setlength(dx, 0);
    setlength(dxred, 0);
  end;

end;

function TFuenteSintetizadorCEGH.dim_RB: integer;
begin
  Result := datosModelo_Sim.B_nc;
end;

function TFuenteSintetizadorCEGH.dim_X: integer;
begin
  Result :=
    datosModelo_Sim.A_nc +  // vector _x estado gaussiano, memoria de la salida
    datosModelo_Sim.A_nc;   // vector _y (  x pasados al mundo real ).
end;

function TFuenteSintetizadorCEGH.dim_Wa: integer;
begin

  if datosModelo_Opt.BAmp_cte <> nil then
    Result := datosModelo_Opt.BAmp_cte.nc
  else
    Result := 0;

end;

// carga el deltacosto en el término indep del simplex
function TFuenteSintetizadorCEGH.calc_DeltaCosto: NReal;
begin
  Result := DeltaCosto;
end;

function mFilaPorColumna(a: TVectR; b: TDAOfNReal): NReal;
var
  acum: NREal;
  k: integer;
begin
  acum := 0;
  for k := 0 to high(b) do
    acum := acum + a.e(k + 1) * b[k];
  Result := acum;
end;

procedure TFuenteSintetizadorCEGH.SortearEntradaRB(var aRB: NReal);
var
  j, jUltimoRuido: integer;
  UltimoRND: NReal;

begin
  if (globs.EstadoDeLaSala = CES_OPTIMIZANDO) then
    jUltimoRuido := jUltimo_Wa_
  else
    jUltimoRuido := jULtimo_RB_;
  {$IFDEF DEBUG_SORTEOS}
  Write(fdebug_sorteos, globs.FechaInicioDelpaso.AsISOStr: 20);
  {$ENDIF}
  for j := jPrimer_RB_ to jUltimoRuido do
  begin
    repeat
      UltimoRND := fuenteGaussiana.rnd;
    until (-3.69 <= UltimoRND) and (UltimoRND <= 3.69);
    TVLArrOfNReal_0(pointer(@aRB)^)[j] := UltimoRND;
    {$IFDEF DEBUG_SORTEOS}
    Write(fdebug_sorteos, #9, UltimoRND: 12: 4);
    {$ENDIF}
  end;
{$IFDEF DEBUG_SORTEOS}
  writeln(fdebug_sorteos);
{$ENDIF}

end;

procedure TFuenteSintetizadorCEGH.ValorEsperadoEntradaRB(var aRB: Nreal);
var
  j, jUltimoRuido: integer;
begin
  if (globs.EstadoDeLaSala = CES_OPTIMIZANDO) then
    jUltimoRuido := jUltimo_Wa_
  else
    jUltimoRuido := jULtimo_RB_;

  for j := jPrimer_RB_ to jUltimoRuido do
    TVLArrOfNReal_0(pointer(@aRB)^)[j] := 0;
end;

// Hace efectivo el cambio de estado haciendo EstadoK_origen:= EstadoK_aux
procedure TFuenteSintetizadorCEGH.EvolucionarEstado;
var
  i: integer;
begin
  {$IFDEF RESUMEN_POSTIZADO}
    write( fdebug, globs.kPaso_, #9, globs.kSubPaso_ );
    for i := 0 to high( Bornera ) do
      write(fdebug, #9,  Bornera[ i] );
    writeln(fdebug);
  {$ENDIF}

  for i := 0 to dim_X - 1 do
    Bornera[jPrimer_X + i] := Bornera[jPrimer_Xs + i];

  if simularConDatosHistoricos then
  begin
    vswap(indicesDatosHistoricos, indicesDatosHistoricos_s);
    vswap(pesosDatosHistoricos, pesosDatosHistoricos_s);
  end;
end;

function TFuenteSintetizadorCEGH.Gaussianar_(datosModelo: TModeloCEGH;
  xNoGaussiana: NReal; kBorne: integer; fecha: TFecha): NReal;
begin
  //el false en usarProximosDeformadoresAlterados no esta bien. en verdad debería seleccionarse
  //los deformadores alterados que correspondan a la fecha, no necesariamente los proximos,
  //si al inicializar en sim_cronica_inicio se toman varios datos para atras.
  //Si se toma UN SOLO valor en el sim_cronica_inicio si esta bien porque tiene
  //que usar los deformadores de la fecha de inicio de la simulacion que vienen
  //cargados en pa
  Result := datosModelo.xTog(xNoGaussiana, kBorne + 1,
    kSelectorDesformador(datosmodelo, fecha) + 1);
end;

procedure TFuenteSintetizadorCEGH.GaussianarRafaga(var destino: TDAOfNReal;
  kBaseDestino: integer; const origen: TDAOfNReal; kBaseOrigen: integer;
  NBornesDestino, NRetardosXDestino: integer; NBornesOrigen: integer;
  datosModelo: TModeloCEGH; fecha: TFecha);

var
  kBorne, kSelector: integer;
  jRetardo: integer;
  j_x, j_y: integer;
  xFecha: TFecha;
begin
  xFecha := TFecha.Create_Clone(fecha);
  for jRetardo := 0 to NRetardosXDestino - 1 do
  begin
    kSelector := kSelectorDesformador(datosmodelo, xFecha) + 1;
    j_x := kBaseDestino + jRetardo * NBornesDestino;
    j_y := kBaseOrigen + jRetardo * NBornesOrigen;
    //Ver el comentario en Gaussianar_
    for kBorne := 0 to NBornesDestino - 1 do
      destino[j_x + kBorne] :=
        datosModelo.xTog(origen[j_y + kBorne], kBorne + 1, kSelector);
    xFecha.addHoras(-self.durPasoDeSorteoEnHoras);
  end;
  xFecha.Free;
end;


procedure TFuenteSintetizadorCEGH.calcular_Xs;
var
  i, j: integer;
  //  AiporX, BiporRB: NReal;
  //  Mi: TVectR;

  fechaProximoSorteo: TFecha;
  hayQueCalcularSalidas: boolean;
  dm: TModeloCEGH;
  mval: NReal;

  aPronostico: TPronostico;
  usarCono: TDAOfBoolean;
  kSesgo: TDAOfNInt;
  kFactor: TDAofNInt;
  kSerie: integer;

  kSelector: integer;

  sesgo, factor: NReal;

label  // por claridad del código - no sacar
  lbl_Optimizando,
  lbl_SimulandoConSeriesSinteticas,
  lbl_SimulandoConSeriesHistoricas,
  lbl_Continuar;

begin

  setlength(usarCono, pronosticosSorteados.Count);
  setlength(kSesgo, pronosticosSorteados.Count);
  setlength(kFactor, pronosticosSorteados.Count);
  for kSerie := 0 to pronosticosSorteados.Count - 1 do
  begin
    aPronostico := TPronostico(pronosticosSorteados.items[kSerie]);
    usarCono[kSerie] := aPronostico.fechaEnRango(globs.FechaInicioDelpaso,
      kSesgo[kSerie], kFactor[kSerie]);
  end;

  if (globs.EstadoDeLaSala = CES_OPTIMIZANDO) then
    dm := datosModelo_Opt
  else
    dm := datosModelo_Sim;

  if dm.A_cte <> nil then
    kSelector := 0
  else
    kSelector := dm.kSelectorDeformador(globs.FechaInicioDelpaso);

  if (globs.EstadoDeLaSala <> CES_OPTIMIZANDO) then
    if simularConDatosHistoricos then
      goto lbl_SimulandoConSeriesHistoricas
    else
      goto lbl_SimulandoConSeriesSinteticas;

  lbl_Optimizando:
    hayQueCalcularSalidas := True;
  for i := 0 to dm.nBornesSalida - 1 do
  begin
    calcularSalidaBorne[i] := True;
    if usarCono[i] then
    begin
      aPronostico := TPronostico(pronosticosSorteados.items[i]);
      if kSesgo[i] >= 0 then
      begin
        if kFactor[i] >= 0 then
          Bornera[jPrimer_Xs_x + i] :=
            dm.CalcularSalidaConSesgo(i + 1, @Bornera[jPrimer_X_x],
            @Bornera[jPrimer_rb_], aPronostico.sesgo[kSesgo[i]],
            aPronostico.factor[kFactor[i]], kSelector)
        else
          Bornera[jPrimer_Xs_x + i] :=
            dm.CalcularSalidaConSesgo(i + 1, @Bornera[jPrimer_X_x],
            @Bornera[jPrimer_rb_], aPronostico.sesgo[kSesgo[i]], 1.0, kSelector);
      end
      else
      begin // lods dos < 0 no se puede dar si usarCono = true
        Bornera[jPrimer_Xs_x + i] :=
          dm.CalcularSalidaConSesgo(i + 1, @Bornera[jPrimer_X_x],
          @Bornera[jPrimer_rb_], 0, aPronostico.factor[kFactor[i]], kSelector);
      end;
    end
    else
      Bornera[jPrimer_Xs_x + i] :=
        dm.CalcularSalida(i + 1, @Bornera[jPrimer_X_x], @Bornera[jPrimer_rb_],
        kSelector);
  end;
  goto lbl_Continuar;

  lbl_SimulandoConSeriesSinteticas:
    hayQueCalcularSalidas := False;
  // marco False por si los valores deterministicos me dan
  for i := 0 to dm.nBornesSalida - 1 do
  begin
    aPronostico := pronosticosSorteados[i] as TPronostico;


    // NPCC________NPLC__________
    // NPSA______________________________NPAC________________


    if (aPronostico.cantValoresDeterministicosUsados < aPronostico.NPSA) and
      (aPronostico.cantValoresDeterministicosUsados < aPronostico.NPCC) and
      not aPronostico.determinismoSoloEstadoInicial then
    begin
      // si todavía estoy en la guia determinística calculo impongo valores
      fechaProximoSorteo := TFecha.Create_OffsetHoras(globs.FechaInicioDelpaso,
        durPasoDeSorteoEnHoras);
      mval := aPronostico.guia[aPronostico.cantValoresDeterministicosUsados];
      Bornera[jPrimer_Xs_x + i] := Gaussianar_(dm, mval, i, fechaProximoSorteo);
      Bornera[jPrimer_Xs_y + i] := mval;
      Inc(aPronostico.cantValoresDeterministicosUsados);
      fechaProximoSorteo.Free;
      calcularSalidaBorne[i] := False;
    end
    else
    begin
      // ya no es determinístico.
      calcularSalidaBorne[i] := True;
      if usarCono[i] then
      begin

        if kSesgo[i] >= 0 then
          sesgo:= aPronostico.sesgo[kSesgo[i]]
        else
          sesgo:= 0;

        if kFactor[i] >= 0 then
           factor:= aPronostico.factor[kFactor[i]]
        else
          factor:= 1;

//        writeln( 'sesgo: ', sesgo,', factor: ', factor );

        Bornera[jPrimer_Xs_x + i] := dm.CalcularSalidaConSesgo(i + 1,
          @Bornera[jPrimer_X_x], @Bornera[jPrimer_rb_], sesgo,factor, kSelector)
      end
      else
        Bornera[jPrimer_Xs_x + i] :=
          dm.CalcularSalida(i + 1, @Bornera[jPrimer_X_x], @Bornera[jPrimer_rb_],
          kSelector);
      hayQueCalcularSalidas := True;
    end;
  end;
  goto lbl_Continuar;

  lbl_SimulandoConSeriesHistoricas:
    hayQueCalcularSalidas := False;

  fechaProximoSorteo := TFecha.Create_OffsetHoras(globs.FechaInicioDelpaso,
    durPasoDeSorteoEnHoras);

  if sincronizarConSemillaAleatoria then
    datosHistoricos.calc_indices_y_pesos_dt(
      Desp_IniSim_IniDatosHistoricos - globs.ultimaSemillaFijada,
      fechaProximoSorteo.dt,
      indicesDatosHistoricos_s, pesosDatosHistoricos_s)
  else
    if sincronizarConHistoricos then
    datosHistoricos.calc_indices_y_pesos_dt(
      Desp_IniSim_IniDatosHistoricos,
      fechaProximoSorteo.dt,
      indicesDatosHistoricos_s, pesosDatosHistoricos_s)
    else
    datosHistoricos.calc_indices_y_pesos_dt(
      Desp_IniSim_IniDatosHistoricos - globs.kCronica,
      fechaProximoSorteo.dt,
      indicesDatosHistoricos_s, pesosDatosHistoricos_s);



  for i := 0 to dm.nBornesSalida - 1 do
  begin
    mval := datosHistoricos.get_mval_(i, IndicesDatosHistoricos_s,
      PesosDatosHistoricos_s);
    Bornera[jPrimer_Xs_y + i] := mval;
    Bornera[jPrimer_Xs_x + i] := Gaussianar_(dm, mval, i, fechaProximoSorteo);
  end;
  fechaProximoSorteo.Free;


  lbl_Continuar:

(*
// si NRetardos_X > 1

Bien, una vez calculado el Xs correspondiente a los bornes de salida,
si NRetardos_X > 1 tenemos que rellenar el tramo de Xs que no corresponde
directamente a los bornes de salida copiando de X lo que le va a tocar
cuando se produzca el desplazamiento en "evolucionar estado" *)

    for j := jPrimer_Xs_x + dm.nBornesSalida to jUltimo_Xs_x do
      Bornera[j] := Bornera[j - dim_x - dm.nBornesSalida];

  // esto no se si importa, pero por las dudas lo hago.
  for j := jPrimer_Xs_y + dm.nBornesSalida to jUltimo_Xs_y do
    Bornera[j] := Bornera[j - dim_x - dm.nBornesSalida];

  (* fin del rellando de Xs e Ys *)


  if hayQueCalcularSalidas then
    calcularSalidasDeX(dm, True, calcularSalidaBorne);

    setlength(usarCono, 0);
    setlength(kSesgo, 0);
    setlength(kFactor, 0);
end;

procedure TFuenteSintetizadorCEGH.Free;
begin

  {$IFDEF RESUMEN_POSTIZADO}
   closefile(fdebug);
  {$ENDIF}

  if sorteadorDePronosticos <> nil then
   sorteadorDePronosticos.Free;

  if modeloAuxiliar <> nil then
  begin
   {$IFDEF CEGH_CREATE_NOCOMPRATIDO}
    modeloAuxiliar.Free;
    modeloAuxiliar := nil;
    {$ELSE}
    Free_ModeloCEGH( modeloAuxiliar );
    {$ENDIF}
  end;

  if datosHistoricos <> nil then
  begin
    datosHistoricos.Free;
    datosHistoricos := nil;
  end;

  if escenarioDePronosticos <> nil then
  begin
    escenarioDePronosticos.Free;
    escenarioDePronosticos := nil;
  end;

  {$IFDEF CEGH_CREATE_NOCOMPRATIDO}
  datosModelo_Sim.Free;
  {$ELSE}
  Free_ModeloCEGH( datosModelo_Sim );
  {$ENDIF}

  setlength(calcularSalidaBorne, 0);
  setlength(todosLosBornesEnTrue, 0);
  setlength(XRed, 0);
  setlength(XsRed, 0);
  setLength(XRed_aux, 0);

  setlength(indicesDatosHistoricos, 0);
  setlength(pesosDatosHistoricos, 0);
  setlength(indicesDatosHistoricos_s, 0);
  setlength(pesosDatosHistoricos_s, 0);

  if fuenteGaussiana <> nil then
  begin
    fuenteGaussiana.Free;
  end;

  nombreArchivoModelo.Free;
  nombreArchivoDatosHistoricos.Free;
  nombreArchivoModeloAuxiliar.Free;
  inherited Free;
end;



procedure TFuenteSintetizadorCEGH.PubliVars;
var
  k: integer;
  NSeries: integer;

begin
  inherited PubliVars;

  NSeries:= self.datosModelo_Sim.nBornesSalida;

  for k:= jPrimer_RB_ to jUltimo_RB_ do
    PublicarVariableNR( 'RB_'+ NombresDeBornes_Publicados[ k - jPrimer_RB_], 'p.u.', 12, 3, bornera[k], true );

  for k:= jPrimer_Wa_ to jUltimo_Wa_ do
      PublicarVariableNR( 'Wa_'+IntToStr( 1+ k - jPrimer_Wa_), 'p.u.', 12, 3, bornera[k], true );

  for k:= jPrimer_X_x to jUltimo_X_x do
      PublicarVariableNR( 'X_'+ NombresDeBornes_Publicados[ ( k - jPrimer_X_x ) mod NSeries], 'p.u.', 12, 3, bornera[k], true );

  for k:= jPrimer_X_y to jUltimo_X_y do
      PublicarVariableNR( 'Y_'+ NombresDeBornes_Publicados[ ( k - jPrimer_X_y  ) mod NSeries], '_', 12, 3, bornera[k], true );

  for k:= jPrimer_Xs_x to jUltimo_Xs_x do
      PublicarVariableNR( 'Xs_'+ NombresDeBornes_Publicados[ ( k - jPrimer_Xs_x  ) mod NSeries], 'p.u.', 12, 3, bornera[k], true );

  for k:= jPrimer_Xs_y to jUltimo_Xs_y do
      PublicarVariableNR( 'Ys_'+ NombresDeBornes_Publicados[ ( k - jPrimer_Xs_y  ) mod NSeries], '_', 12, 3, bornera[k], true );

  for k:= jPrimer_BC to jUltimo_BC do
      PublicarVariableNR( 'BC_'+IntToStr( 1+ k - jPrimer_BC ), '_', 12, 3, bornera[k], true );

  PublicarVariableVR('XRed', '-', 15, 15, XRed, False, True);

end;

(*
function TFuenteSintetizadorCEGH.getIndiceDato__(fecha: TFecha;
  nAnios_offsetDatos: integer): integer;
var
  iterFechaIniSorteo, iterFechaFinSorteo: TFecha;
  indiceDatos: integer;
  desp: NReal;
begin
  if SincronizarConHistoricos then
    indiceDatos := datosHistoricos.locate_fecha_(fecha, desp )
  else
    indiceDatos := datosHistoricos.locate_fecha_ignore_anio_(fecha, nAnios_offsetDatos, desp );

  if indiceDatos < 0 then
    raise Exception.Create(
      'Error en: TFuenteSintetizadorCEGH.getIndiceDto_InicioAnio ' + Nombre);
  Result := indiceDatos;
end;
  *)

procedure TFuenteSintetizadorCEGH.InitModeloFromFile;
var
  i: integer;
begin

  if nombreArchivoModelo.testearYResolver then
  begin
    {$IFDEF CEGH_CREATE_NOCOMPRATIDO}
    if datosModelo_Sim <> nil then
      datosModelo_Sim.Free
    else
     datosModelo_Sim := TModeloSintetizadorCEGH.CreateFromArchi( nombreArchivoModelo.archi );
    {$ELSE}
    Change_ModeloCEGH( nombreArchivoModelo.archi, datosModelo_Sim );
    {$ENDIF}

    self.durPasoDeSorteoEnHoras := datosModelo_Sim.durPasoDeSorteoEnHoras;

    if NombresDeBornes_Publicados <> nil then
      NombresDeBornes_Publicados.Clear
    else
      NombresDeBornes_Publicados := TStringList.Create;

    // esto se inicaliza de nuevo en preparar memoria, pero se necesita
    // aquí para que el editor de SimRes3 funcione
    setlength(bornera, dim_RB + dim_X + dim_Xs + dim_BC);

    for i := 0 to datosModelo_Sim.NombresDeBornes_Publicados.Count - 1 do
    begin
      self.NombresDeBornes_Publicados.Add(
        datosModelo_Sim.NombresDeBornes_Publicados[i]);
      //    fuenteGaussiana:= Tf_ddp_GaussianaNormal.Create( 0 );
    end;

  end
  else
    raise ExceptionFileNotFound.Create(nombreArchivoModelo.archi,
      exCreandoLaFuente + ClaseNombre);

  // si hay un modelo auxiliar para la optimización lo cargo.
  if self.usarModeloAuxiliar then
    if nombreArchivoModeloAuxiliar.testearYResolver then
    begin
      {$IFDEF CEGH_CREATE_NOCOMPRATIDO}
      if modeloAuxiliar <> nil then
        modeloAuxiliar.Free;
      modeloAuxiliar := TModeloSintetizadorCEGH.CreateFromArchi( nombreArchivoModeloAuxiliar.archi);
      {$ELSE}
      Change_ModeloCEGH( nombreArchivoModeloAuxiliar.archi, modeloAuxiliar);
      {$ENDIF}
    end
    else
      ExceptionFileNotFound.Create(nombreArchivoModelo.archi,
        exCreandoLaFuente + ClaseNombre);

  if self.usarModeloAuxiliar then
    datosModelo_Opt := modeloAuxiliar
  else
    datosModelo_Opt := datosModelo_Sim;

  setlength(XRed, datosModelo_Opt.nVE);
  setlength(XsRed, datosModelo_Opt.nVE);
  setlength(XRed_aux, datosModelo_Opt.nVE_aux);


  {$IFDEF RESUMEN_POSTIZADO}
   assignfile(fdebug, getDir_Dbg+ DirectorySeparator+  nombre+'_debug_resumen_postizado.xlt');
   rewrite(fdebug);
  {$ENDIF}

end;

procedure TFuenteSintetizadorCEGH.InitDatosHistoricosFromFile;
var
  i: integer;
  mismosBornes: boolean;
begin
  try
    datosHistoricos := TDatosHistoricos.CreateFromArchi(
      nombreArchivoDatosHistoricos.archi);

    if self.durPasoDeSorteoEnHoras <> Trunc(datosHistoricos.dt_EntrePuntos *
      dtToHora + 0.001) then
      raise Exception.Create(exArchivoDatosDuracionDistinta);

    mismosBornes := datosHistoricos.NombresDeBornes_Publicados.Count =
      NombresDeBornes_Publicados.Count;
    i := 0;
    while (i < datosHistoricos.NombresDeBornes_Publicados.Count) and mismosBornes do
    begin
      mismosBornes := NombresDeBornes_Publicados[i] =
        datosHistoricos.NombresDeBornes_Publicados[i];
      i := i + 1;
    end;

    if not mismosBornes then
      raise Exception.Create(exBornesArchivoDiferente);

  except
    on e: Exception do
      raise Exception.Create(exCEGHInitDatosHistoricosFromFile +
        e.Message + exLeyendoLaFuente + nombre);
  end;
end;

procedure TFuenteSintetizadorCEGH.calcularSalidasDeX(Xs: boolean);
var
  dm: TModeloCEGH;
begin
  if globs.EstadoDeLaSala = CES_SIMULANDO then
    dm := datosModelo_Sim
  else
    dm := datosModelo_Opt;
  calcularSalidasDeX(dm, Xs, todosLosBornesEnTrue);
end;

procedure TFuenteSintetizadorCEGH.calcularSalidasDeX(
  datosModelo: TModeloCEGH; Xs: boolean; calcularBorne: TDAOfBoolean);
var
  i, sel: integer;
  sg: NReal;
  fechaProximoSorteo: TFecha;
begin
  if Xs then
  begin

    fechaProximoSorteo := TFecha.Create_OffsetHoras(globs.FechaInicioDelpaso,
      durPasoDeSorteoEnHoras);
    sel := kSelectorDesformador(datosModelo, fechaProximoSorteo);


    //aplicar funciones deformantes
    for i := 0 to datosModelo.nBornesSalida - 1 do
    begin
      if calcularBorne[i] then
      begin
        sg := Bornera[jPrimer_Xs_x + i];
        bornera[jPrimer_Xs_y + i] :=
          datosModelo.gTox(sg, i + 1, sel + 1);
      end;
    end;
    fechaProximoSorteo.Free;
  end
  else
  begin
    sel := kSelectorDesformador(datosModelo, nil);
    //aplicar funciones deformantes
    for i := 0 to datosModelo.nBornesSalida - 1 do
    begin
      if calcularBorne[i] then
      begin
        sg := Bornera[jPrimer_X_x + i];
        bornera[jPrimer_X_y + i] := datosModelo.gTox(sg, i + 1, sel + 1);
      end;
    end;
  end;
end;

procedure cambioFichaPDFuenteSintetizadorCEGH(fuente: TCosa);
begin
  TFuenteSintetizadorCEGH(fuente).CambioFichaPD;
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteSintetizadorCEGH.ClassName, TFuenteSintetizadorCEGH);
  //  registrarClaseDeCosa(TFichaDeterminismo.ClassName, TFichaDeterminismo);
end;

procedure AlFinal;
begin
end;

procedure TFuenteSintetizadorCEGH.ReCalibrarPronosticos(
  datosModelo: TModeloCEGH; fechaIniSim: TFecha);
begin
  ucalibrarconopronosticos.CalibrarConoCentrado(datosModelo,
    escenarioDePronosticos, fechaIniSim);
end;

// intenta obtener los pronósticos desde las direcciones
// indicadas. El resultado es TRUE si logró obtener todos los pronósticos
// y FALSE en caso contrario.
function TFuenteSintetizadorCEGH.GetPronosticos(fechaIniSim: TFecha): boolean;
var
  rbt: TConsultaPronostico_Cliente;
  kSerie: integer;
  aProno: TPronostico;
  resConsulta: TList_FRVarPronostico;
  aVarProno: TFRVarPronostico;
  desconocidas: string;
  bProno: TPronostico;

begin
  // si no hay una url especificada no consultamos nada.
  if url_get = '' then
  begin
    Result := True;
    exit;
  end;

  rbt := TConsultaPronostico_Cliente.Create(url_get);
  for kSerie := 0 to datosModelo_Sim.NombresDeBornes_Publicados.Count - 1 do
  begin
    aProno := escenarioDePronosticos.items[0].items[0];
    //aProno := pronosticosSorteados[kSerie];// pronosticos[kSerie];
    rbt.add(datosModelo_Sim.NombresDeBornes_Publicados[kSerie],
      globs.fechaIniSim.dt, datosModelo_Sim.durPasoDeSorteoEnHoras*3600.0,
      datosModelo_Sim.CalcOrdenDelFiltro, aProno.NPCC);
  end;
  resConsulta := rbt.get_pronostico;
  rbt.Free;

  if resConsulta.Count <> datosModelo_Sim.NombresDeBornes_Publicados.Count then
    raise Exception.Create('Fuente sintetizador CEGH ' +
      self.nombre + ' consulto pronostico por: ' + IntToStr(
      datosModelo_Sim.NombresDeBornes_Publicados.Count) +
      ' series, pero obtuvo ' + IntToStr(resConsulta.Count) + ' fichas de resultado.');

  desconocidas := '';
  for kSerie := 0 to datosModelo_Sim.NombresDeBornes_Publicados.Count - 1 do
  begin
//    aProno := escenarioDePronosticos.items[0].items[0];//pronosticosSorteados[kSerie];
    aVarProno := resConsulta[kSerie];
    if aVarProno.NPCC = -1 then
      desconocidas := desconocidas + ', ' + aVarProno.nombre;
    if datosModelo_Sim.NombresDeBornes_Publicados[kSerie] <> aVarProno.nombre then
      raise Exception.Create('Error en nombre de pronóstico, se esperaba: '
        + datosModelo_Sim.NombresDeBornes_Publicados[kSerie] +
        ' se obtuvo: ' + aVarProno.nombre);
  end;

  if desconocidas <> '' then
  begin
    writeln('Lo siento el servidor de pronósticos no reconoce las variables: ' +
      desconocidas);
    Result := False;
  end
  else
  begin
    for kSerie := 0 to datosModelo_Sim.NombresDeBornes_Publicados.Count - 1 do
    begin
      aProno := escenarioDePronosticos.items[0].items[0];//pronosticosSorteados[kSerie];
      aVarProno := resConsulta[kSerie];
      aProno.Cambiar_GUIA(aVarProno.NPCC, aVarProno.NPLC, aVarProno.NPSA,
        aVarProno.NPAC, aVarProno.guia_p50);
    end;
    Result := True;
  end;

  resConsulta.Free;
end;



initialization
  {$IFDEF DEBUG_SORTEOS}
  assignfile(fdebug_sorteos, 'c:\simsee\bin\debug_sorteos.xlt');
  rewrite(fdebug_sorteos);
  {$ENDIF}
finalization
{$IFDEF DEBUG_SORTEOS}
  closefile(fdebug_sorteos);
{$ENDIF}
end.
