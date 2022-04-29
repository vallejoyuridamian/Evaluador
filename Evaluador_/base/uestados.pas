
(*
 rch.061122

 El propósito de esta unidad es definir una clase TAdminEstados
 que siva para administrar los estados de un sistema
 y brinde los servicios necesarios par realizar
 programación dinámica estocástica (PDE) sobre  el sistema y
 realizar simulaciones del sistema una vez que se ha fijado
 la mejor política de operación en base a la PDE.

 Para que el armado del espacio de estados se pueda realizar en forma
 colaborativa por el conjutno de Actores definimos métodos para
 registrar variables de estado indicando el rango de la variable,
 el tipo (continua o discreta) y la cantidad de puntos de discretización
 que se desea tener sobre el rango. La mínima cantidad de puntos es 2 y
 serían los extremos del rango de la variable.

 Al inicio, en la creación del sistema los Actores deben registar las variables
 Luego de registrados todos los actores, se debe indicar la cantidad de pasos
 de tiempo más uno como la cantidad de FOTOS del espacio de estado que se
 deben considerar.

*)

unit uEstados;

{$MODE Delphi}

interface

uses
  uparseadorsupersimple,
  Classes,
  Math, xmatdefs, uodt_types, uFechas, SysUtils,
  uCosa,
  uVersiones,
  matreal,
  ucontroladordeterminista, uRecCFMP, uauxiliares;

resourcestring
  exCopiarVariablesDe =
    'TAdminEstados.copiarVariablesDe: el CF de destino no tiene la misma cantidad de variables que el CF de origen';


const
  cfbin_nver = 2; // agrego numero de versión al CF.bin

type
  TFuncTraduccion = function(x: NReal): NReal of object;

  { TEngancheCFReal }

  TEngancheCFReal = class(TCosa)
  public
    nombreVar: string;
    unidades: string;
    valor: NReal;

    constructor Create(capa: integer; const nombreVar, unidades: string; valor: NReal);
    function Rec: TCosa_RecLnk; override;
    procedure AfterRead(version, id_hilo: integer); override;
  end;

  TDAOfEngancheCFReal = array of TEngancheCFReal;

  { TEngancheCFEntero }

  TEngancheCFEntero = class(TCosa)
  public
    nombreVar: string;
    unidades: string;
    valor: integer;

    constructor Create(capa: integer; const nombreVar, unidades: string; valor: integer);

    function Rec: TCosa_RecLnk; override;
    procedure AfterRead(version, id_hilo: integer); override;

    function ConversionV94(input: array of string): TDAofString;
  end;

  TDAOfEngancheCFEntero = array of TEngancheCFEntero;


  { TAdminEstados }

  TAdminEstados = class
    // dimensionado
    nVarsContinuas: integer;
    nVarsDiscretas: integer;

    // vectores con las definiciones de las variablas continuas y discretas
    xr_def: TDAOfDefVarContinua;
    xd_def: TDAOfDefVarDiscreta;

    // descripción de TIEMPO
    nPuntosT: integer; // nPasos+1
    fechaIni, fechaFin: TFecha;
    horasDelPaso: NReal;

    // soporte para el espacio de estado definido por los vectores anteriores
    constelacion: TConstelacion;

    // agrego soporte para controlador_determinista
    deterministico: boolean;
    // false si es un espacio de estado comú, true si es para que sea determinista
    ControladorDeterministico: TControladorDeterministico;


    // Agregados para manejo de Trayectoria
    // vectores para almacenar el ESTADO ACTUAL
    xr: TDAOfNReal;
    xd: TDAOfNInt;

    // Indices de la posición de la estrellita en cada  variables de estado
    // al recorrer las estrellas de un frame
    estrella_kr, estrella_kd: TDAOfNInt;

    // ordinal de la estrellita al recorrer las estrellas de un frame.
    ordinalEstrellaActual: integer;


    constructor Create(_nVarsContinuas, _nVarsDiscretas, _nPuntosT: integer);

    function CreateParasito: TAdminEstados;

    // carga un CF desde la posición actual del archivo f  (formato binario)
    constructor Create_LoadFromFile(var f: file);
    // guarda CF desde la posición actual del archivo f (formato binario)
    procedure StoreInFile(var f: file);

    // abre el archivo (archi) para lectura, llama a Create_LoadFromFile sobre
    // el archivo abierto y luego cierra (archi)
    constructor CreateLoadFromArchi(const archi: string);
    // abre el archivo (archi) para escritura, llama a StoreInFile y luego
    // cierra el archivo
    procedure StoreInArchi(const archi: string);

    procedure Free; virtual;

    procedure Registrar_Continua(ixr: integer; xmin, xmax: NReal;
      nPuntos: integer; nombre: string; unidades: string);

    function indexOf_Continua(nombre: string): integer;

    procedure RegistrarTraduccion_Continua(ixr: integer;
    // xmin, xmax: NReal;  nPuntos: integer;
      const nombre, unidades: string; funcTraduccion: TFuncTraduccion);

    procedure Registrar_Discreta(ixd: integer; npuntos: integer;
      const nombre, unidades: string);

    function indexOf_Discreta(nombre: string): integer;

    {
    procedure RegsitrarTraduccion_Discreta(ixd: integer;
    //npuntos: integer;
      nombre: string; unidades: string);
 }

    //Cuando cambiemos a paso variable cambiar el horasDelPaso por un array con
    //las horas de cada paso

    procedure CrearElEspacioTiempo(fechaIni, fechaFin: TFecha;
      horasDelPaso: NReal; const costoFuturo: TMatOfNReal; deterministico: boolean);

    procedure SetEstadoToEstrella;
    procedure SetEstadoToEstrella_indexada(vkr, vkd, idx_r, idx_d: TDAOfNInt);
    procedure SetEstrella_Indexada(vkr, vkd, idx_r, idx_d: TDAOfNInt);


    // interpona los vectores del Manto para la posición continua actual y
    // carga el resultado en "res" desde la posición jBase
    procedure mantoContinuo(var res: TDAOfNReal; jBase: integer;
      const Manto: TMatOfNReal);


    procedure SetCostoEstrella(kPuntoT: integer; valCosto: NReal);
    procedure AcumCostoEstrella(kPuntoT: integer; valCosto: NReal);


    function costoEstrella(kpuntoT: integer): NReal; virtual;
    function costoContinuo(kPuntoT: integer): NReal; virtual;

    // calcula la derivadas respecto de la variabla cuyo índice es (irx) para
    // el punto de tiempo kpuntoT. La derivada dCdx_Inc es la calculada con
    // un incremento de x, la dCdx_Dec es calculada con un decremento.
    procedure devxr_estrella_20_(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal); virtual;

    procedure devxr_continuo_20(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal); virtual;

    procedure devxr_estrella_(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer); virtual;

    procedure devxr_continuo(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer;
    // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
      var xrpos: NReal     // Posición del punto en la cajita de paroximación en por unidad
      ); virtual;

    // Calcula la variación del costo por un incremento delta_xd en la variable ird
    // en el punto de tiempo kpuntoT
    function deltaCosto_vxd_estrella_(ird: integer; kpuntoT: integer;
      delta_xd: integer): NReal; virtual;
    function deltaCosto_vxd_continuo(ird: integer; kpuntoT: integer;
      delta_xd: integer): NReal; virtual;

    function deltaCosto_vxr_continuo_DosEstados_UTE(irx, irx2, kpuntoT: integer;
      delta_xr, delta_xr2: NReal): NReal; virtual;
    // delta costo sobre una coordenada real
    function deltaCosto_vxr_continuo(irx: integer; kpuntoT: integer;
      delta_xr: NReal): NReal; virtual;

    // fija los vectores índices estrella_kr, estrella_kd al vértice CERO
    // de la discretización.
    procedure setEstrellaCERO;

    // incrementa los índices estrella_kr, estrella_kd de forma de apuntar
    // la siguiente estrella de la discretización.
    function IncEstrella: boolean;

    // Fija el punto de inicio de un barrido sobre los indexados;
    procedure SetEstrellaCERO_indexada(var estrella_idx_r, estrella_idx_d: TDAOfNint);

    // incrementa la estrella, pero sobre las variables indexadas
    function IncEstrella_indexada(var estrella_idx_r, estrella_idx_d: TDAOfNint;
      idx_r, idx_d: TDAOfNInt): boolean;

    procedure posicionarseEnEstrella(ordinalEstrella: integer);
    function nEstrellasPorPuntoT: integer;

    function CrearCF_AUX_para_enganaches_CFbin(archivoCF: string;
      CarpetaAlternativa: string): TAdminEstados;
    function CrearCF_AUX_para_enganaches_MPUTE(archi_mus, archi_pis: string;
      Sala_dtIni, Sala_dtFin: TFecha; Sala_HorasDelPaso: NReal): TAdminEstados;

    procedure InicializarFrameFinal(const CFaux: TAdminEstados;
      enganchesContinuos, enganchesDiscretos: TListaDeCosas;
      enganchar_promediando: boolean; uniformizar_promediando: string;
      flg_usar_mapeo: boolean; mapeo_str: string; sala: TCosa); virtual;

    procedure InicializarFrameFinal_mapeo_enganches(const CFaux: TAdminEstados;
    // desde: TFecha;
      enganchesContinuos, enganchesDiscretos: TListaDeCosas;
      enganchar_promediando: boolean; uniformizar_promediando: string); virtual;

    procedure InicializarFrameFinal_mapeo_evaluador(const CFaux: TAdminEstados;
      mapeo_str, uniformizar_promediando: string; sala: TCosa);


    // recibe un string con los nombres de las variables para uniformizar
    // promediando el último frame.

    // Clasifica las variables en "a_Uniformizar" y "Otras".
    // entonces, hace un FOR en Otras recorriendo las estrellas que define
    // el producto cartesiano de sus discretizaciones. En cada Super_Estrella así definida
    // se recorren todas las estrellas definidas para ese punto del producto cartesinao de otras
    // por el producto cartesiano de las discretizaciones de las variables "a_Uniformizar".
    procedure uniformizar_ultimo_frame_en(uniformizar_promediando: string);


    function variablesIgualesA(otroCF: TAdminEstados): boolean;
    procedure copiarVariablesDe(otroCF: TAdminEstados);

    procedure dumpToTextFile(const nomArchivo: string);

    // hace un promedio del costo futuro de a nPasos.
    procedure Ecualizar(nPasos: integer);

    // Copiar el útimo frame en todos los demas.
    procedure LlenarConFrameFinal;


    // retorna un string con las coordenadas de los estados continuos y discretos
    // separados por tabuladores.
    function GetEstado_XLT: string;

    // Cheque que el CFAux pasado como parámetro sea compatible para ser
    // accedido como un CFAux durante la simulación.
    function ChequearCompatibilidad_CFAux(const CFAux: TAdminEstados): boolean;

    // Retorna una TStringList con los nombres de las variables de estado
    function VariablesDeEstado_lst: TStringList;
  private
  end;



  // Esta clase es para usar durante la simulación de una sala
  // colgada de una CF calculada durante una optimización de mayor
  // duración de paso de tiempo de integración. Por ejemplo, la Optimización
  // corresponde a la programación semanal con paso horario, mientras que la
  // simulación corresponde a una simulación de 72h con paso diezminutal (o horario)
  TAdminEstados_sobremuestreado = class(TAdminEstados)
    Sala_dtIni, Sala_dtFin: TDateTime;
    Sala_HorasDelPaso: NReal;
    Inicios_DeltaHoras: NReal;

    // auxiliares modificadas en cada cálculo
    kPuntoT1, kPuntoT2: integer;
    Peso1, Peso2: NReal;

    constructor CreateLoadFromArchi(const archi: string;
      Sala_dtIni, Sala_dtFin: TdateTime; Sala_HorasDelPaso: NReal);

    function CalcAprox_kPuntosT(Sala_kPuntoT: integer): integer;

    function costoEstrella(kpuntoT: integer): NReal; override;
    function costoContinuo(kPuntoT: integer): NReal; override;

    // calcula la derivadas respecto de la variabla cuyo índice es (irx) para
    // el punto de tiempo kpuntoT. La derivada dCdx_Inc es la calculada con
    // un incremento de x, la dCdx_Dec es calculada con un decremento.
    procedure devxr_estrella_20_(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal); override;

    procedure devxr_continuo_20(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal); override;

    procedure devxr_estrella_(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer); override;

    procedure devxr_continuo(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer;
    // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
      var xrpos: NReal     // Posición del punto en la cajita de paroximación en por unidad
      ); override;

    // Calcula la variación del costo por un incremento delta_xd en la variable ird
    // en el punto de tiempo kpuntoT
    function deltaCosto_vxd_estrella_(ird: integer; kpuntoT: integer;
      delta_xd: integer): NReal; override;
    function deltaCosto_vxd_continuo(ird: integer; kpuntoT: integer;
      delta_xd: integer): NReal; override;

    function deltaCosto_vxr_continuo_DosEstados_UTE(irx, irx2, kpuntoT: integer;
      delta_xr, delta_xr2: NReal): NReal; override;
    // delta costo sobre una coordenada real
    function deltaCosto_vxr_continuo(irx: integer; kpuntoT: integer;
      delta_xr: NReal): NReal; override;

  end;




  { TAdminEstados_CFMPUTE }

  TAdminEstados_CFMPUTE = class(TAdminEstados)

    lstRecCFMP: TListaRecCFMP;
    constructor CreateLoadFromArchi(const archi_mus_, archi_pis: string;
      Sala_dtIni, Sala_dtFin: TFecha; Sala_HorasDelPaso: NReal);

    function costoEstrella(kpuntoT: integer): NReal; override;
    function costoContinuo(kPuntoT: integer): NReal; override;

    // calcula la derivadas respecto de la variabla cuyo índice es (irx) para
    // el punto de tiempo kpuntoT. La derivada dCdx_Inc es la calculada con
    // un incremento de x, la dCdx_Dec es calculada con un decremento.
    procedure devxr_estrella_20_(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal); override;

    procedure devxr_continuo_20(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal); override;

    procedure devxr_estrella_(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer); override;

    procedure devxr_continuo(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer;
    // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
      var xrpos: NReal
    // Posición del punto en la cajita de paroximación en por unidad
      ); override;

    // Calcula la variación del costo por un incremento delta_xd en la variable ird
    // en el punto de tiempo kpuntoT
    function deltaCosto_vxd_estrella_(ird: integer; kpuntoT: integer;
      delta_xd: integer): NReal; override;
    function deltaCosto_vxd_continuo(ird: integer; kpuntoT: integer;
      delta_xd: integer): NReal; override;

    function deltaCosto_vxr_continuo_DosEstados_UTE(irx, irx2, kpuntoT: integer;
      delta_xr, delta_xr2: NReal): NReal; override;
    // delta costo sobre una coordenada real
    function deltaCosto_vxr_continuo(irx: integer; kpuntoT: integer;
      delta_xr: NReal): NReal; override;

  end;


procedure AlInicio;
procedure AlFinal;

// auxiliares para lectura escritura en archivo binario
procedure brwf(var f: file; var X: integer; flgw: boolean); overload;
procedure brwf(var f: file; var X: NReal; flgw: boolean); overload;
procedure brwf(var f: file; var X: TDateTime; flgw: boolean); overload;
procedure brwf(var f: file; var X: TDAOfNReal; flgw: boolean); overload;
procedure brwf(var f: file; var X: TVectR; flgw: boolean); overload;
procedure brwf(var f: file; var X: TDAOfNInt; flgw: boolean); overload;
procedure brwf(var f: file; var x: TDAOfDefVarContinua; flgw: boolean); overload;
procedure brwf(var f: file; var x: TDAOfDefVarDiscreta; flgw: boolean); overload;
procedure brwf(var f: file; var X: string; flgw: boolean); overload;

implementation

{ TAdminEstados_CFMPUTE }

constructor TAdminEstados_CFMPUTE.CreateLoadFromArchi(
  const archi_mus_, archi_pis: string; Sala_dtIni, Sala_dtFin: TFecha;
  Sala_HorasDelPaso: NReal);
var

  linea_pi: string;
  f_pi: TextFile;

  linea_mu: string;
  f_mu: TextFile;

  str_NIVEL_MU: string;
  str_MU: string;

  str_NIVEL_PI: string;
  str_ID_HIDRO: string;
  str_COTA: string;
  str_PI: string;

  xpi_bon: double;
  xpi_pal: double;
  xpi_sg: double;
  xpi_bay: double;

  xct_bon: double;
  xct_pal: double;
  xct_sg: double;
  xct_bay: double;

  rec: TRecCFMP;
  leer: boolean;
  i: integer;

  f: TextFile;
  r: TRecCFMP;
  CF0: double;
  CF: double;
  r1: TRecCFMP;

begin

  self.fechaIni := TFecha.Create_Clone(Sala_dtIni);
  self.fechaFin := TFecha.Create_Clone(Sala_dtFin);

  self.horasDelPaso := Sala_HorasDelPaso;
  nVarsContinuas := 3;
  nVarsDiscretas := 0;
  nPuntosT := 2;
  SetLength(xr_def, 3);
  xr_def[0] := TDefVarContinua.Create('Bonete_Vol', 'Hm3', 0, 100, 100);
  xr_def[1] := TDefVarContinua.Create('Palmar_Vol', 'Hm3', 0, 100, 100);
  xr_def[2] := TDefVarContinua.Create('SG_Vol', 'Hm3', 0, 100, 100);

  SetLength(xd_def, 0);
  constelacion := nil;
  SetLength(xr, 3);
  SetLength(xd, 0);


  SetLength(estrella_kr, 3);
  SetLength(estrella_kd, 0);

  ordinalEstrellaActual := 0;

  lstRecCFMP := TListaRecCFMP.Create;
  //Se abren los 2 archivos
  assignfile(f_mu, archi_mus_);
  {$I-}
  reset(f_mu);
  {$I+}
  if ioresult <> 0 then
    raise Exception.Create('No pude abrir archivo: ' + archi_mus_);

  assignfile(f_pi, archi_pis);
  {$I-}
  reset(f_pi);
  {$I+}
  if ioresult <> 0 then
    raise Exception.Create('No pude abrir archivo: ' + archi_pis);

  //Lee el encabezado
  readln(f_mu, linea_mu);
  //Lee los guiones
  readln(f_mu, linea_mu);
  //Lee el encabezado
  readln(f_pi, linea_pi);
  //Lee los guiones
  readln(f_pi, linea_pi);

  //Leo la primera fila de datos del achivo MU
  readln(f_mu, linea_mu);
  leer := True;
  while leer do
  begin

    //leo un nivel del archivo mu
    getPalHastaSep(str_NIVEL_MU, linea_mu, ' ');
    str_MU := trim(linea_mu);

    for i := 0 to 3 do
    begin
      readln(f_pi, linea_pi);
      getPalHastaSep(str_ID_HIDRO, linea_pi, ' ');
      getPalHastaSep(str_NIVEL_PI, linea_pi, ' ');
      getPalHastaSep(str_COTA, linea_pi, ' ');
      str_PI := trim(linea_pi);

      if str_ID_HIDRO = '1' then
      begin
        xpi_sg := StrToFloat(str_PI);
        xct_sg := StrToFloat(str_COTA);
      end;
      if str_ID_HIDRO = '2' then
      begin
        xpi_bon := StrToFloat(str_PI);
        xct_bon := StrToFloat(str_COTA);
      end;
      if str_ID_HIDRO = '3' then
      begin
        xpi_bay := StrToFloat(str_PI);
        xct_bay := StrToFloat(str_COTA);
      end;
      if str_ID_HIDRO = '4' then
      begin
        xpi_pal := StrToFloat(str_PI);
        xct_pal := StrToFloat(str_COTA);
      end;
    end;

    rec := TRecCFMP.Create(StrToInt(str_NIVEL_MU));
    rec.cargar_mu(StrToFloat(str_MU));
    rec.cargar_pi(xpi_bon, xpi_pal, xpi_sg, xpi_bay);
    rec.cargar_ct(xct_bon, xct_pal, xct_sg, xct_bay);

    lstRecCFMP.Add(rec);

    readln(f_mu, linea_mu);

    if ((linea_mu = '') or EOF(f_mu)) then
      leer := False;
  end;

  assignfile(f, 'C:\Users\fbarreto\Desktop\res.xlt');
  {$I-}
  Rewrite(f);
  {$I+}

  writeln(f, 'NIVEL' + #9 + 'ct_SG' + #9 + 'ct_bon' + #9 + 'ct_pal' +
    #9 + 'ct_bay' + #9 + 'V_sg_0' + #9 + 'V_bon_0' + #9 + 'V_pal_0' +
    #9 + 'V_bay_0' + #9 + 'mu' + #9 + 'pi_sg' + #9 + 'pi_bon' + #9 +
    'pi_pal' + #9 + 'pi_bay' + #9 + 'CF0' + #9 + 'CF' + #9 + 'CF-CF0' +
    #9 + 'nivelMax');


  for i := 0 to lstRecCFMP.Count - 1 do
  begin
    r := lstRecCFMP.Items[i];
    Write(f, r.nivel);
    Write(f, #9);

    Write(f, r.ct_sg);
    Write(f, #9);
    Write(f, r.ct_bon);
    Write(f, #9);
    Write(f, r.ct_pal);
    Write(f, #9);
    Write(f, r.ct_bay);
    Write(f, #9);

    Write(f, r.V_sg_0);
    Write(f, #9);
    Write(f, r.V_bon_0);
    Write(f, #9);
    Write(f, r.V_pal_0);
    Write(f, #9);
    Write(f, r.V_bay_0);
    Write(f, #9);

    Write(f, r.mu);
    Write(f, #9);

    Write(f, r.pi_sg);
    Write(f, #9);
    Write(f, r.pi_bon);
    Write(f, #9);
    Write(f, r.pi_pal);
    Write(f, #9);
    Write(f, r.pi_bay);
    Write(f, #9);

    CF0 := r.evalCF(r.V_bon_0, r.V_pal_0, r.V_sg_0, r.V_bay_0);
    Write(f, CF0);
    Write(f, #9);

    CF := lstRecCFMP.maxEvalRecCFMP(r.V_bon_0, r.V_pal_0, r.V_sg_0, r.V_bay_0, r1{%H-});
    Write(f, CF);
    Write(f, #9);

    Write(f, CF - CF0);
    Write(f, #9);
    writeln(f, r1.nivel);

  end;
  CloseFile(f);

end;


function TAdminEstados_CFMPUTE.costoEstrella(kpuntoT: integer): NReal;
var
  c1: NReal;
  rec: TRecCFMP;

begin

  //c1:=lstRecCFMP.maxEvalRecCFMP(xr, xd);

  c1 := lstRecCFMP.maxEvalRecCFMP(xr[0], xr[1], xr[2] * 2, 0, rec);
  Result := c1;

end;

function TAdminEstados_CFMPUTE.costoContinuo(kPuntoT: integer): NReal;
var
  c1: NReal;
  rec: TRecCFMP;

begin

  //c1:=lstRecCFMP.maxEvalRecCFMP(xr, xd);

  c1 := lstRecCFMP.maxEvalRecCFMP(xr[0], xr[1], xr[2] * 2, 0, rec);
  Result := c1;

end;

procedure TAdminEstados_CFMPUTE.devxr_estrella_20_(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal);
var
  c1: NReal;
  rec: TRecCFMP;

begin

  c1 := lstRecCFMP.maxEvalRecCFMP(xr[0], xr[1], xr[2] * 2, 0, rec);

  dCdx_Dec := rec.pi[irx];
  dCdx_Inc := dCdx_Dec;

end;

procedure TAdminEstados_CFMPUTE.devxr_continuo_20(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal);
var
  c1: NReal;
  rec: TRecCFMP;

begin

  c1 := lstRecCFMP.maxEvalRecCFMP(xr[0], xr[1], xr[2] * 2, 0, rec);

  dCdx_Dec := rec.pi[irx];
  dCdx_Inc := dCdx_Dec;

end;

procedure TAdminEstados_CFMPUTE.devxr_estrella_(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer);
var
  c1: NReal;
  rec: TRecCFMP;

begin

  c1 := lstRecCFMP.maxEvalRecCFMP(xr[0], xr[1], xr[2] * 2, 0, rec);

  dCdx_Dec := rec.pi[irx];
  dCdx_Inc := dCdx_Dec;
  resCod := 0;
end;

procedure TAdminEstados_CFMPUTE.devxr_continuo(irx: integer; kpuntoT: integer;
  var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer; var xrpos: NReal);
var
  c1: NReal;
  rec: TRecCFMP;

begin

  c1 := lstRecCFMP.maxEvalRecCFMP(xr[0], xr[1], xr[2] * 2, 0, rec);

  dCdx_Dec := rec.pi[irx];
  dCdx_Inc := dCdx_Dec;
  resCod := 0;
  xrpos := 0;

end;

function TAdminEstados_CFMPUTE.deltaCosto_vxd_estrella_(ird: integer;
  kpuntoT: integer; delta_xd: integer): NReal;
begin
  raise Exception.Create('Esta clase no soporta variables de estado discretas.');
end;

function TAdminEstados_CFMPUTE.deltaCosto_vxd_continuo(ird: integer;
  kpuntoT: integer; delta_xd: integer): NReal;
begin
  raise Exception.Create('Esta clase no soporta variables de estado discretas.');
end;

function TAdminEstados_CFMPUTE.deltaCosto_vxr_continuo_DosEstados_UTE(
  irx, irx2, kpuntoT: integer; delta_xr, delta_xr2: NReal): NReal;
var
  c1, c2, x1, x2: NReal;

begin
  c1 := costoContinuo(kpuntoT);
  x1 := xr[irx];
  x2 := xr[irx2];

  xr[irx] := xr[irx] + delta_xr;
  xr[irx2] := xr[irx2] + delta_xr2;

  c2 := costoContinuo(kpuntoT);

  xr[irx] := x1;
  xr[irx2] := x2;


  Result := c2 - c1;

end;

function TAdminEstados_CFMPUTE.deltaCosto_vxr_continuo(irx: integer;
  kpuntoT: integer; delta_xr: NReal): NReal;
var
  c1, c2, x1: NReal;

begin
  c1 := costoContinuo(kpuntoT);
  x1 := xr[irx];

  xr[irx] := xr[irx] + delta_xr;

  c2 := costoContinuo(kpuntoT);

  xr[irx] := x1;
  Result := c2 - c1;

end;


constructor TEngancheCFReal.Create(capa: integer; const nombreVar, unidades: string;
  valor: NReal);
begin
  inherited Create(capa);
  self.nombreVar := nombreVar;
  self.unidades := unidades;
  self.valor := valor;
end;

function TEngancheCFReal.Rec: TCosa_RecLnk;
begin
  Result := inherited Rec;
  Result.addCampoDef('nombreVar', nombreVar);
  Result.addCampoDef('unidades', unidades, 94);
  Result.addCampoDef('valor', valor);
end;

procedure TEngancheCFReal.AfterRead(version, id_hilo: integer);
var
  i1, i2: integer;
begin
  inherited AfterRead(version, id_hilo);
  if Version < 94 then
  begin
    i1 := pos('[', nombreVar);
    i2 := pos(']', nombreVar);
    if (i1 > 0) and (i2 > i1) then
    begin
      unidades := trim(copy(nombreVar, i1 + 1, i2 - i1 - 1));
      Delete(nombreVar, i1, length(nombreVar) - i1 + 1);
      nombreVar := trim(nombreVar);
    end
    else
      unidades := '';
  end;
end;


constructor TEngancheCFEntero.Create(capa: integer; const nombreVar, unidades: string;
  valor: integer);
begin
  inherited Create(capa);
  self.nombreVar := nombreVar;
  self.unidades := unidades;
  self.valor := valor;
end;

function TEngancheCFEntero.Rec: TCosa_RecLnk;
begin
  Result := inherited Rec;
  Result.addCampoDef('nombreVar', nombreVar);
  Result.addCampoDef('unidades', unidades, 94);
  Result.addCampoDef('valor', valor);
end;

procedure TEngancheCFEntero.AfterRead(version, id_hilo: integer);
var
  i1, i2: integer;
begin
  inherited AfterRead(version, id_hilo);
  if Version < 94 then
  begin
    i1 := pos('[', nombreVar);
    i2 := pos(']', nombreVar);
    if (i1 > 0) and (i2 > i1) then
    begin
      unidades := trim(copy(nombreVar, i1 + 1, i2 - i1 - 1));
      Delete(nombreVar, i1, length(nombreVar) - i1 + 1);
      nombreVar := trim(nombreVar);
    end
    else
      unidades := '';
  end;
end;



function TEngancheCFEntero.ConversionV94(input: array of string): TDAofString;
var
  i1: SizeInt;
  i2: SizeInt;

  nombreVar: string;
  unidades: string;

begin

  nombreVar := input[0];

  i1 := pos('[', nombreVar);
  i2 := pos(']', nombreVar);
  if (i1 > 0) and (i2 > i1) then
  begin
    unidades := trim(copy(nombreVar, i1 + 1, i2 - i1 - 1));
    Delete(nombreVar, i1, length(nombreVar) - i1 + 1);
    nombreVar := trim(nombreVar);
  end
  else
    unidades := '';

  SetLength(Result, 2);
  Result[0] := nombreVar;
  Result[1] := unidades;
end;

procedure brwf(var f: file; var X: integer; flgw: boolean); overload;
begin
  if flgw then
    BlockWrite(f, X, SizeOf(X))
  else
    BlockRead(f, X, SizeOf(X));
end;

procedure brwf(var f: file; var X: NReal; flgw: boolean); overload;
begin
  if flgw then
    BlockWrite(f, X, SizeOf(X))
  else
    BlockRead(f, X, SizeOf(X));
end;

procedure brwf(var f: file; var X: TDateTime; flgw: boolean); overload;
begin
  if flgw then
    BlockWrite(f, X, SizeOf(X))
  else
    BlockRead(f, X, SizeOf(X));
end;

procedure brwf(var f: file; var X: TDAOfNReal; flgw: boolean); overload;
var
  n, k: integer;
begin
  if flgw then
  begin
    n := length(X);
    brwf(f, n, True);
    for k := 0 to high(X) do
      brwf(f, x[k], True);
  end
  else
  begin
    brwf(f, n, False);
    setlength(X, n);
    for k := 0 to high(X) do
      brwf(f, x[k], False);
  end;
end;

procedure brwf(var f: file; var X: TVectR; flgw: boolean);
var
  n, k: integer;
begin
  if flgw then
  begin
    n := X.n;
    brwf(f, n, True);
    for k := 1 to n do
      brwf(f, x.pv[k], True);
  end
  else
  begin
    brwf(f, n, False);
    X:= TVectR.Create_init( n );
    for k := 1 to n do
      brwf(f, x.pv[k], False);
  end;
end;

procedure brwf(var f: file; var X: TDAOfNInt; flgw: boolean); overload;
var
  n, k: integer;
begin
  if flgw then
  begin
    n := length(X);
    brwf(f, n, True);
    for k := 0 to high(X) do
      brwf(f, x[k], True);
  end
  else
  begin
    brwf(f, n, False);
    setlength(X, n);
    for k := 0 to high(X) do
      brwf(f, x[k], False);
  end;
end;

procedure brwf(var f: file; var x: TDAOfDefVarContinua; flgw: boolean);
  overload;
var
  n, k: integer;
begin
  if flgw then
  begin
    n := length(X);
    brwf(f, n, True);
    for k := 0 to high(X) do
      x[k].StoreInFile(f);
  end
  else
  begin
    brwf(f, n, False);
    setlength(X, n);
    for k := 0 to high(X) do
      x[k] := TDefVarContinua.Create_LoadFromFile(f);
  end;
end;

procedure brwf(var f: file; var x: TDAOfDefVarDiscreta; flgw: boolean);
  overload;
var
  n, k: integer;
begin
  if flgw then
  begin
    n := length(X);
    brwf(f, n, True);
    for k := 0 to high(X) do
      x[k].StoreInFile(f);
  end
  else
  begin
    brwf(f, n, False);
    setlength(X, n);
    for k := 0 to high(X) do
      x[k] := TDefVarDiscreta.Create_LoadFromFile(f);
  end;
end;

procedure brwf(var f: file; var X: string; flgw: boolean);
var
  n, k, m: integer;
begin
  if flgw then
  begin
    n := length(X);
    brwf(f, n, True);
    if n > 0 then
    begin
      m:= sizeOf( X[1] );
      for k:= 1 to n do
        BlockWrite(f, X[k], m);
    end;
  end
  else
  begin
    brwf(f, n, False);
    setlength(X, n);
    if n > 0 then
    begin
      m:= sizeOf( X[1] );
      for k:= 1 to n do
       BlockRead(f, X[k], m);

    end;
  end;
end;

procedure TAdminEstados.StoreInArchi(const archi: string);
var
  f: file;
begin
  assignFile(f, archi);
  rewrite(f, blockSize_ArchiBin);
  StoreInFile(f);
  closefile(f);
end;

procedure TAdminEstados.StoreInFile(var f: file);
var
  flgw: boolean;
  raux: double;
  iaux: integer;

begin
  flgw := True;
  raux := -1;
  iaux := cfbin_nver;
  brwf(f, raux, flgw);
  brwf(f, iaux, flgw);
  brwf(f, fechaIni.dt, flgw);
  brwf(f, fechaFin.dt, flgw);
  brwf(f, horasDelPaso, flgw);
  brwf(f, nVarsContinuas, flgw);
  brwf(f, nVarsContinuas, flgw);
  brwf(f, nVarsDiscretas, flgw);
  brwf(f, nPuntosT, flgw);
  brwf(f, xr_def, flgw);
  brwf(f, xd_def, flgw);
  constelacion.StoreInFile(f);
  brwf(f, xr, flgw);
  brwf(f, xd, flgw);
  brwf(f, estrella_kr, flgw);
  brwf(f, estrella_kd, flgw);
  brwf(f, ordinalEstrellaActual, flgw);
end;

function TAdminEstados.variablesIgualesA(otroCF: TAdminEstados): boolean;
var
  res: boolean;
  i: integer;
begin
  if (nVarsContinuas = otroCF.nVarsContinuas) or (nVarsDiscretas =
    otroCF.nVarsDiscretas) then
  begin
    res := True;
    for i := 0 to nVarsContinuas - 1 do
      if not xr_def[i].esIgualA(otroCF.xr_def[i]) then
      begin
        res := False;
        break;
      end;

    if res then
      for i := 0 to nVarsContinuas - 1 do
        if not xd_def[i].esIgualA(otroCF.xd_def[i]) then
        begin
          res := False;
          break;
        end;
    Result := res;
  end
  else
    Result := False;
end;

procedure TAdminEstados.copiarVariablesDe(otroCF: TAdminEstados);
var
  i: integer;
begin
  if (Self.nVarsContinuas <> otroCF.nVarsContinuas) or
    (self.nVarsDiscretas <> otroCF.nVarsDiscretas) then
    raise Exception.Create(exCopiarVariablesDe);

  for i := 0 to High(otroCF.xr_def) do
    self.xr_def[i] := otroCF.xr_def[i].clonar;
  for i := 0 to high(otroCF.xd_def) do
    self.xd_def[i] := otroCF.xd_def[i].clonar;
end;

constructor TAdminEstados.CreateLoadFromArchi(const archi: string);
var
  f: file;
  old_filemode: integer;
begin
  old_filemode := filemode;
  filemode := 0;
  assignFile(f, archi);
{$I-}
  reset(f, blockSize_ArchiBin);
{$I+}
  if ioresult <> 0 then
    raise Exception.Create('Error, no pude abrir el archivo: ' + archi);

  Create_LoadFromFile(f);
  closefile(f);
  filemode := old_filemode;
end;

constructor TAdminEstados.Create_LoadFromFile(var f: file);
var
  flgw: boolean;
  dtAux: TDateTime;
  v0: double; // primer numero. Si es -1 indica que
  // el segundo es el número de versión.
  // si no es -1 asumo que el numero de versión es 1
  nver: integer;
  intaux: integer;

begin
  inherited Create;
  constelacion := nil;
  ControladorDeterministico := nil;
  flgw := False;
  brwf(f, v0, flgw);
  if (v0 = -1) then
  begin
    brwf(f, nver, flgw);
    brwf(f, dtAux, flgw);
  end
  else
  begin
    nver := 1;
    dtAux := TDateTime(v0);
  end;

  FechaIni := TFecha.Create_Dt(dtAux);
  brwf(f, dtAux, flgw);
  fechaFin := TFecha.Create_Dt(dtAux);

  if nver < 2 then
  begin
    brwf(f, intaux, flgw);
    horasDelPaso := intaux;
  end
  else
  begin
    brwf(f, horasDelPaso, flgw);
  end;
  brwf(f, nVarsContinuas, flgw);
  brwf(f, nVarsContinuas, flgw);
  brwf(f, nVarsDiscretas, flgw);
  brwf(f, nPuntosT, flgw);
  brwf(f, xr_def, flgw);
  brwf(f, xd_def, flgw);
  constelacion := TConstelacion.Create_LoadFromFile(f);
  brwf(f, xr, flgw);
  brwf(f, xd, flgw);
  brwf(f, estrella_kr, flgw);
  brwf(f, estrella_kd, flgw);
  brwf(f, ordinalEstrellaActual, flgw);
end;

function TAdminEstados.CreateParasito: TAdminEstados;
var
  res: TAdminEstados;
  k: integer;

begin
  res := TAdminEstados.Create(nVarsContinuas, nVarsDiscretas, nPuntosT);
  res.fechaIni := fechaIni;
  res.FechaFin := fechaFin;
  res.horasDelPaso := HorasDelPaso;
  for k := 0 to high(res.xr_def) do
    res.xr_def[k] := xr_def[k].clonar;
  for k := 0 to high(res.xd_def) do
    res.xd_def[k] := xd_def[k].clonar;

  for k := 0 to high(res.xr) do
    res.xr[k] := xr[k];
  for k := 0 to high(res.xd) do
    res.xd[k] := xd[k];

  for k := 0 to high(estrella_kr) do
    res.estrella_kr[k] := estrella_kr[k];
  for k := 0 to high(estrella_kd) do
    res.estrella_kd[k] := estrella_kd[k];
  res.ordinalEstrellaActual := ordinalEstrellaActual;

  res.constelacion := constelacion.CreateParasito;

  Result := res;
end;



function TAdminEstados.IncEstrella: boolean;
begin
  Result := constelacion.inc_estrella(estrella_kr, estrella_kd);
  ordinalEstrellaActual := constelacion.ordinalEstrella(estrella_kr, estrella_kd);
end;


function TAdminEstados.IncEstrella_indexada(
  var estrella_idx_r, estrella_idx_d: TDAOfNint; idx_r, idx_d: TDAOfNInt): boolean;

begin
  Result := constelacion.inc_estrella_indexada(estrella_idx_r,
    estrella_idx_d, idx_r, idx_d);
end;




procedure TAdminEstados.posicionarseEnEstrella(ordinalEstrella: integer);
begin
  constelacion.indicesEstrella_i(estrella_kr, estrella_kd, ordinalEstrella);
  ordinalEstrellaActual := ordinalEstrella;
end;

function TAdminEstados.nEstrellasPorPuntoT: integer;
begin
  Result := constelacion.nEstrellas;
end;

function TAdminEstados.CrearCF_AUX_para_enganaches_CFbin(archivoCF: string;
  CarpetaAlternativa: string): TAdminEstados;
var
  CFaux: TAdminEstados;
begin
  try
    if not FileExists(archivoCF) then
      archivoCF := CarpetaAlternativa + DirectorySeparator + ExtractFileName(archivoCF);
    CFaux := TAdminEstados.CreateLoadFromArchi(archivoCF);
  except
    raise Exception.Create('Error al intentar leer CFaux: ' + archivoCF +
      '. Capaz deba optimizar la otra sala primero.');
  end;

  Result := CFaux;

end;

function TAdminEstados.CrearCF_AUX_para_enganaches_MPUTE(archi_mus, archi_pis: string;
  Sala_dtIni, Sala_dtFin: TFecha; Sala_HorasDelPaso: NReal): TAdminEstados;
var
  CFaux: TAdminEstados;
begin
  try
    CFaux := TAdminEstados_CFMPUTE.CreateLoadFromArchi(archi_mus,
      archi_pis, Sala_dtIni, Sala_dtFin, Sala_HorasDelPaso);
  except
    raise Exception.Create('Error al intentar leer CF_MP_UTE: ' +
      archi_mus + ' o ' + archi_pis);
  end;

  Result := CFaux;

end;



procedure TAdminEstados.InicializarFrameFinal(const CFaux: TAdminEstados;
  enganchesContinuos, enganchesDiscretos: TListaDeCosas;
  enganchar_promediando: boolean; uniformizar_promediando: string;
  flg_usar_mapeo: boolean; mapeo_str: string; sala: TCosa);
begin
  if flg_usar_mapeo then
    InicializarFrameFinal_mapeo_evaluador(CFaux, mapeo_str,
      uniformizar_promediando, sala)
  else
    InicializarFrameFinal_mapeo_enganches(CFaux, enganchesContinuos,
      enganchesDiscretos, enganchar_promediando,
      uniformizar_promediando);
end;

procedure TAdminEstados.InicializarFrameFinal_mapeo_enganches(
  const CFaux: TAdminEstados; enganchesContinuos, enganchesDiscretos: TListaDeCosas;
  enganchar_promediando: boolean; uniformizar_promediando: string);

var

  //Guarda los indices en self de las variables comunes a ambos CFs
  xr_varsComunes, xd_varsComunes: TDAofNInt;
  //Guarda los indices en CFaux de las variables comunes a ambos CFs
  xr_varsComunesAux, xd_varsComunesAux: TDAofNInt;
  costoAux: NReal;

  desde: TFecha;

  i, j, nVarsComunes: integer;
  finBarridoEstrellas: boolean;
  kpr, alfa, beta: NReal;
  kp1, kp2: integer;
  encontre: boolean;
  {$IFDEF DBG}
  fDbg: Textfile;
  {$ENDIF}
  // Desaparecida significa que Está En CFAux y no en Self.
  cnt_desaparecidas_continuas, cnt_desaparecidas_discretas: integer;
  k_desaparecidas_continuas, k_desaparecidas_discretas: TDAOfNInt;
  cnt_: integer;
  encontradas: array of boolean;
  contadores_continuas, contadores_discretas: TDAOfNInt;
  k: integer;
  recorriendo_desaparecidas: boolean;
  hay_desaparecidas: boolean;

  v_uniformizar: TStrings;

begin
  desde := self.fechaFin;


  //kpr es la cantidad de pasos desde el inicio de CFaux hasta "desde.dt"
  //con el paso de tiempo de aux
  kpr := (desde.dt - CFaux.fechaIni.dt) * 24.0 / CFaux.horasDelPaso + 1;
  alfa := frac(kpr);
  beta := 1 - alfa;
  kp1 := trunc(kpr);
  kp2 := kp1 + 1;

  if not (CFaux is TAdminEstados_CFMPUTE) then
    if (kp1 <= 0) or (kp2 > high(CFAux.constelacion.fcosto)) then
      raise Exception.Create(
        'TAdminEstados.InicializarFrameFinal: se desea enganchar el ' +
        desde.AsStr + ' y el archivo de costo futuro con que desea enganchar va desde el '
        + CFaux.fechaIni.AsStr + ' hasta el ' + CFaux.fechaFin.AsStr +
        '.'#10'La fecha de enganche debe estar contenida dentro del período de optimización del archivo CF.bin');

  //Identifico las variables reales comunes a ambos CFs
  setLength(xr_varsComunes, length(xr_def));
  setLength(xr_varsComunesAux, length(CFaux.xr_def));
  setlength(encontradas, length(CFaux.xr_def));
  nVarsComunes := 0;
  cnt_desaparecidas_continuas := length(CFaux.xr_def);
  for j := 0 to high(CFaux.xr_def) do
  begin  // buscamos en CFaux si hay una con igual nombre
    encontradas[j] := False;
    for i := 0 to high(xr_def) do
    begin // para cada variable del CF
      if xr_def[i].nombre = CFaux.xr_def[j].nombre then
      begin
        xr_varsComunes[nVarsComunes] := i;
        xr_varsComunesAux[nVarsComunes] := j;
        Inc(nVarsComunes);
        Dec(cnt_desaparecidas_continuas);
        encontradas[j] := True;
        break;
      end;
    end;
  end;

  setlength(k_desaparecidas_continuas, cnt_desaparecidas_continuas);
  cnt_ := 0;
  for j := 0 to high(CFaux.xr_def) do
    if not encontradas[j] then
    begin
      k_desaparecidas_continuas[cnt_] := j;
      Inc(cnt_);
    end;


  if nVarsComunes < Length(xr_varsComunes) then
    if nVarsComunes <> 0 then
      xr_varsComunes := copy(xr_varsComunes, 0, nVarsComunes)
    else
      xr_varsComunes := nil;

  if nVarsComunes < Length(xr_varsComunesAux) then
    if nVarsComunes <> 0 then
      xr_varsComunesAux := copy(xr_varsComunesAux, 0, nVarsComunes)
    else
      xr_varsComunesAux := nil;

  cnt_desaparecidas_discretas := length(CFaux.xd_def);
  setlength(encontradas, length(CFaux.xd_def));
  //Identifico las variables discretas comunes a ambos CFs
  SetLength(xd_varsComunes, length(xd_def));
  SetLength(xd_varsComunesAux, length(CFaux.xd_def));
  nVarsComunes := 0;
  for j := 0 to high(CFaux.xd_def) do
  begin
    encontradas[j] := False;
    for i := 0 to high(xd_def) do
    begin
      if xd_def[i].nombre = CFaux.xd_def[j].nombre then
      begin
        xd_varsComunes[nVarsComunes] := i;
        xd_varsComunesAux[nVarsComunes] := j;
        Inc(nVarsComunes);
        Dec(cnt_desaparecidas_discretas);
        encontradas[j] := True;
        break;
      end;
    end;
  end;

  setlength(k_desaparecidas_discretas, cnt_desaparecidas_discretas);
  cnt_ := 0;
  for j := 0 to high(CFaux.xd_def) do
    if not encontradas[j] then
    begin
      k_desaparecidas_discretas[cnt_] := j;
      Inc(cnt_);
    end;


  if nVarsComunes < Length(xd_varsComunes) then
    if nVarsComunes <> 0 then
      xd_varsComunes := copy(xd_varsComunes, 0, nVarsComunes)
    else
      xd_varsComunes := nil;

  if nVarsComunes < Length(xd_varsComunesAux) then
    if nVarsComunes <> 0 then
      xd_varsComunesAux := copy(xd_varsComunesAux, 0, nVarsComunes)
    else
      xd_varsComunesAux := nil;

  hay_desaparecidas := (cnt_desaparecidas_continuas + cnt_desaparecidas_discretas) > 0;

  setEstrellaCERO; // iniciamos barrido

  //Resolver los enganches
  //Fijamos los valores especificados de las variables continuas en el CFAux
  for j := 0 to high(CFaux.xr_def) do
  begin
    encontre := False;
    for i := 0 to enganchesContinuos.Count - 1 do
    begin
      if CFaux.xr_def[j].nombre = TEngancheCFReal(enganchesContinuos[i])
        .nombreVar then
      begin
        CFaux.xr[j] := TEngancheCFReal(enganchesContinuos[i]).valor;
        encontre := True;
        break;
      end;
    end;
    if not encontre then  //Si no me especificaron su valor, la pongo en el valor medio
      CFaux.xr[j] := CFAux.xr_def[j].xmed;
  end;

  //Fijamos los valores especificados de las variables discretas en el CFAux
  for j := 0 to high(CFaux.xd_def) do
  begin
    encontre := False;
    for i := 0 to enganchesDiscretos.Count - 1 do
    begin
      if CFaux.xd_def[j].nombre = TEngancheCFEntero(enganchesDiscretos[i])
        .nombreVar then
      begin
        CFaux.xd[j] := TEngancheCFEntero(enganchesDiscretos[i]).valor;
        encontre := True;
        break;
      end;
    end;
    if not encontre then
      //Si no me especificaron su valor, la pongo en el valor mínimo
      CFaux.xd[j] := CFAux.xd_def[j].x[0];
  end;

  {$IFDEF DBG}
  AssignFile(fDbg, 'inicializarFrameFinalDbg.xlt');
  rewrite(fDbg);
  {$ENDIF}

  if hay_desaparecidas and enganchar_promediando then
  begin
    // si se va a precisar iterar en los estados perdidos de CFAux ponemos
    // los contadores de las discretizaciones para poder iterar.
    setlength(contadores_continuas, cnt_desaparecidas_continuas);
    setlength(contadores_discretas, cnt_desaparecidas_discretas);
    for k := 0 to high(contadores_continuas) do
      contadores_continuas[k] := CFaux.xr_def[k_desaparecidas_continuas[k]].NPuntos;
    for k := 0 to high(contadores_discretas) do
      contadores_continuas[k] := CFaux.xd_def[k_desaparecidas_discretas[k]].NPuntos;
  end;

  repeat
    //Iteramos en los estados de CF
    SetEstadoToEstrella; // cargamos las variables de acuerdo con la estrella

    /// $Y_j = $X_k
    for i := 0 to High(xr_varsComunes) do
      CFaux.xr[xr_varsComunesAux[i]] := xr[xr_varsComunes[i]];
    for i := 0 to High(xd_varsComunes) do
      CFaux.xd[xd_varsComunesAux[i]] := xd[xd_varsComunes[i]];

    if (hay_desaparecidas and enganchar_promediando) then
    begin
      costoAux := 0;
      cnt_ := 0;
      recorriendo_desaparecidas := True;
      CFaux.SetEstrellaCERO_indexada(contadores_continuas, contadores_discretas);
      while recorriendo_desaparecidas do
      begin
        // fijamos los valores de las indexaddas
        for i := 0 to high(k_desaparecidas_continuas) do
          CFaux.xr[k_desaparecidas_continuas[i]] := contadores_continuas[i];
        for i := 0 to high(k_desaparecidas_discretas) do
          CFaux.xr[k_desaparecidas_discretas[i]] := contadores_discretas[i];
        if abs(alfa) > AsumaCero then
          costoAux := costoAux + CFaux.costoContinuo(kp1) * beta +
            CFaux.costoContinuo(kp2) * alfa
        else
          costoAux := costoAux + CFaux.costoContinuo(kp1);
        Inc(cnt_);

        recorriendo_desaparecidas :=
          CFAux.IncEstrella_indexada(contadores_continuas,
          contadores_discretas, k_desaparecidas_continuas,
          k_desaparecidas_discretas);

      end;
      costoAux := costoAux / cnt_;
    end
    else
    begin
      if abs(alfa) > AsumaCero then
        costoAux := CFaux.costoContinuo(kp1) * beta +
          CFaux.costoContinuo(kp2) * alfa
      else
        costoAux := CFaux.costoContinuo(kp1);
    end;


    constelacion.set_costo_estrella(high(constelacion.fcosto),
      ordinalEstrellaActual, costoAux);
  {$IFDEF DBG}
    Write(fDbg, FloatToStrF(costoAux, ffGeneral, 6, 2), #9);
  {$ENDIF}
    finBarridoEstrellas := not IncEstrella;
  until (finBarridoEstrellas);
  {$IFDEF DBG}
  CloseFile(fDbg);
  {$ENDIF}

  // Ahora si hay alguna en uniformizar_promediando que
  // no haya desaparecido calculo el promedio y se lo impongo
  uniformizar_ultimo_frame_en(uniformizar_promediando);

end;



// (*****
procedure TAdminEstados.InicializarFrameFinal_mapeo_evaluador(
  const CFaux: TAdminEstados; mapeo_str, uniformizar_promediando: string; sala: TCosa);

var
  costoAux: NReal;
  desde: TFecha;
  i: integer;
  finBarridoEstrellas: boolean;
  kpr, alfa, beta: NReal;
  kp1, kp2: integer;
  // Desaparecida significa que Está En CFAux y no en Self.
  cnt_desaparecidas_continuas, cnt_desaparecidas_discretas: integer;
  k_desaparecidas_continuas, k_desaparecidas_discretas: TDAOfNInt;

  cnt_y: integer;
  xrs, xds, yrs, yds: array of TVar;
  iyrs, iyds: TDAOfNInt;

  cnt_: integer;
  contadores_continuas, contadores_discretas: TDAOfNInt;
  k: integer;
  recorriendo_desaparecidas: boolean;
  hay_desaparecidas: boolean;

  Evaluador: TEvaluadorExpresionesSimples;
  aVar: TVar;

  ss: TStringList;
  s: string;

  ts: string;
  klin: integer;
  iPosBarraBarra: integer;
  aScript: TExprLst;

begin

  ss := TStringList.Create;
  ss.DelimitedText := mapeo_str;

  for klin := 0 to ss.Count - 1 do
  begin
    ts := trim(ss[klin]);
    iPosBarraBarra := pos('//', ts);
    if iPosBarraBarra > 0 then
      ts := copy(ts, 1, iPosBarraBarra - 1);
    ss[klin] := trim(ts);
  end;
  ss.LineBreak := ' ';
  s := ss.Text;
  ss.Free;

  desde := self.fechaFin;


  //kpr es la cantidad de pasos desde el inicio de CFaux hasta "desde.dt"
  //con el paso de tiempo de aux
  kpr := (desde.dt - CFaux.fechaIni.dt) * 24.0 / CFaux.horasDelPaso + 1;
  alfa := frac(kpr);
  beta := 1 - alfa;
  kp1 := trunc(kpr);
  kp2 := kp1 + 1;

  if not (CFaux is TAdminEstados_CFMPUTE) then
    if (kp1 <= 0) or (kp2 > high(CFAux.constelacion.fcosto)) then
      raise Exception.Create(
        'TAdminEstados.InicializarFrameFinal: se desea enganchar el ' +
        desde.AsStr + ' y el archivo de costo futuro con que desea enganchar va desde el '
        + CFaux.fechaIni.AsStr + ' hasta el ' + CFaux.fechaFin.AsStr +
        '.'#10'La fecha de enganche debe estar contenida dentro del período de optimización del archivo CF.bin');


  setEstrellaCERO; // iniciamos barrido

  evaluador := TEvaluadorExpresionesSimples.Create;

  sala.AgregarDefinicionesEvaluador(Evaluador);

  //inicializamos variables "X" en entorno de cálculo
  for i := 0 to nVarsContinuas - 1 do
    evaluador.Ejecutar('$X_' + xr_Def[i].nombre + ':= 0.0');
  for i := 0 to nVarsDiscretas - 1 do
    evaluador.Ejecutar('$X_' + xd_Def[i].nombre + ':= 0');


  aScript := evaluador.GetExprLst(s);
  setlength(xrs, nVarsContinuas);
  setlength(xds, nVarsDiscretas);

  SetEstadoToEstrella; // cargamos las variables de acuerdo con la estrella
  //Cargamos variables "X" según estado actual
  for i := 0 to nVarsContinuas - 1 do
  begin
    aVar := evaluador.FindVar('$X_' + xr_Def[i].nombre);
    aVar.val.Val_F := xr[i];
    xrs[i] := aVar;
  end;
  for i := 0 to nVarsDiscretas - 1 do
  begin
    aVar := evaluador.FindVar('$X_' + xd_Def[i].nombre);
    aVar.val.Val_I := xd[i];
    xds[i] := aVar;
  end;
  aScript.evaluar;

  setlength(k_desaparecidas_continuas, length(CFaux.xr_def));
  cnt_desaparecidas_continuas := 0;
  cnt_y := 0;
  //leo los valores "Y" resultantes. Si no encuentro alguna variable la marco como
  // desaparecida.
  setlength(yrs, CFAux.nVarsContinuas);
  setlength(iyrs, CFAux.nVarsContinuas);
  for i := 0 to CFAux.nVarsContinuas - 1 do
  begin
    aVar := evaluador.FindVar('$Y_' + CFAux.xr_Def[i].nombre);
    if aVar <> nil then
    begin
      yrs[cnt_y] := aVar;
      iyrs[cnt_y] := i;
      Inc(cnt_y);
    end
    else
    begin
      k_desaparecidas_continuas[cnt_desaparecidas_continuas] := i;
      Inc(cnt_desaparecidas_continuas);
    end;
  end;

  setlength(yrs, cnt_y);
  setlength(iyrs, cnt_y);
  setlength(k_desaparecidas_continuas, cnt_desaparecidas_continuas);


  setlength(k_desaparecidas_discretas, length(CFaux.xd_def));
  cnt_y := 0;
  cnt_desaparecidas_discretas := 0;

  setlength(yds, CFAux.nVarsDiscretas);
  setlength(iyds, CFAux.nVarsDiscretas);
  for i := 0 to CFAux.nVarsDiscretas - 1 do
  begin
    aVar := evaluador.FindVar('$Y_' + CFAux.xd_Def[i].nombre);
    if aVar <> nil then
    begin
      yds[cnt_y] := aVar;
      iyds[cnt_y] := i;
      Inc(cnt_y);
    end
    else
    begin
      k_desaparecidas_discretas[cnt_desaparecidas_discretas] := i;
      Inc(cnt_desaparecidas_discretas);
    end;
  end;


  setlength(yds, cnt_y);
  setlength(iyds, cnt_y);
  setlength(k_desaparecidas_discretas, cnt_desaparecidas_discretas);

  hay_desaparecidas := (cnt_desaparecidas_discretas + cnt_desaparecidas_discretas) > 0;


  if hay_desaparecidas then
  begin
    // si se va a precisar iterar en los estados perdidos de CFAux ponemos
    // los contadores de las discretizaciones para poder iterar.
    setlength(contadores_continuas, cnt_desaparecidas_continuas);
    setlength(contadores_discretas, cnt_desaparecidas_discretas);
    for k := 0 to high(contadores_continuas) do
      contadores_continuas[k] := CFaux.xr_def[k_desaparecidas_continuas[k]].NPuntos;
    for k := 0 to high(contadores_discretas) do
      contadores_continuas[k] := CFaux.xd_def[k_desaparecidas_discretas[k]].NPuntos;
  end;

  repeat
    writeln('... ordinalEstrellaActual: ', ordinalEstrellaActual);

    //Iteramos en los estados de CF
    SetEstadoToEstrella; // cargamos las variables de acuerdo con la estrella

    //Cargamos variables "X" según estado actual
    for i := 0 to nVarsContinuas - 1 do
      xrs[i].val.Val_F := xr[i];
    for i := 0 to nVarsDiscretas - 1 do
      xds[i].val.Val_I := xd[i];

    // cargo y ejecuto las funciones Y=f(X)
    //    evaluador.Ejecutar(s);
    aScript.evaluar;



    // leemos los resultados
    for i := 0 to high(yrs) do
      CFAux.xr[iyrs[i]] := yrs[i].ValAsFloat;

    for i := 0 to high(yds) do
      CFAux.xr[iyds[i]] := yds[i].ValAsInt;



    if (hay_desaparecidas) then
    begin
      costoAux := 0;
      cnt_ := 0;
      recorriendo_desaparecidas := True;
      CFaux.SetEstrellaCERO_indexada(contadores_continuas, contadores_discretas);
      while recorriendo_desaparecidas do
      begin
        // fijamos los valores de las indexaddas
        for i := 0 to high(k_desaparecidas_continuas) do
          CFaux.xr[k_desaparecidas_continuas[i]] := contadores_continuas[i];
        for i := 0 to high(k_desaparecidas_discretas) do
          CFaux.xr[k_desaparecidas_discretas[i]] := contadores_discretas[i];
        if abs(alfa) > AsumaCero then
          costoAux := costoAux + CFaux.costoContinuo(kp1) * beta +
            CFaux.costoContinuo(kp2) * alfa
        else
          costoAux := costoAux + CFaux.costoContinuo(kp1);
        Inc(cnt_);

        recorriendo_desaparecidas :=
          CFAux.IncEstrella_indexada(contadores_continuas,
          contadores_discretas, k_desaparecidas_continuas,
          k_desaparecidas_discretas);

      end;
      costoAux := costoAux / cnt_;
    end
    else
    begin
      if abs(alfa) > AsumaCero then
        costoAux := CFaux.costoContinuo(kp1) * beta +
          CFaux.costoContinuo(kp2) * alfa
      else
        costoAux := CFaux.costoContinuo(kp1);
    end;


    constelacion.set_costo_estrella(high(constelacion.fcosto),
      ordinalEstrellaActual, costoAux);
    finBarridoEstrellas := not IncEstrella;
  until (finBarridoEstrellas);

  setlength(yrs, 0);
  setlength(iyrs, 0);
  setlength(k_desaparecidas_continuas, 0);
  setlength(yds, 0);
  setlength(iyds, 0);
  setlength(k_desaparecidas_discretas, 0);
  setlength(contadores_continuas, 0);
  setlength(contadores_discretas, 0);

  evaluador.Free;

  // Ahora si hay alguna en uniformizar_promediando que
  // no haya desaparecido calculo el promedio y se lo impongo
  uniformizar_ultimo_frame_en(uniformizar_promediando);

end;

//***)


procedure TAdminEstados.uniformizar_ultimo_frame_en(uniformizar_promediando: string);
var
  v_uniformizar: TStringList;
  clasificadas_r, clasificadas_d: array of boolean;
  h, i, j, k: integer;
  cnt_r: integer;
  cnt_d: integer;

  a_uniformizar_r, otras_r, a_uniformizar_d, otras_d: TDAofNInt;
  u_r, u_d, o_r, o_d: TDAOfNInt;
  loop_otras: boolean;
  m: NREal;
  loop_uniformizar: boolean;
  cnt_: integer;
begin
  if trim(uniformizar_promediando) = '' then
    exit;

  // creamos una lista con el nombre de las variables
  v_uniformizar := TStringList.Create;
  v_uniformizar.Delimiter := ';';
  v_uniformizar.DelimitedText := uniformizar_promediando;

  if v_uniformizar.Count = 0 then
    exit;

  // armo el grupo de los a_uniformizar y el grupo otras
  setlength(clasificadas_r, length(xr_def));
  setlength(clasificadas_d, length(xd_def));

  for k := 0 to high(clasificadas_r) do
    clasificadas_r[k] := False;
  for k := 0 to high(clasificadas_d) do
    clasificadas_d[k] := False;

  cnt_r := 0;
  cnt_d := 0;

  for k := 0 to v_uniformizar.Count - 1 do
  begin
    j := indexOf_Continua(v_uniformizar[k]);
    if j >= 0 then
    begin
      clasificadas_r[j] := True;
      Inc(cnt_r);
    end
    else
    begin
      j := indexOf_Discreta(v_uniformizar[k]);
      if j < 0 then
        raise Exception.Create('No enonctré: ' + v_uniformizar[k] +
          ', en la función de CF. Imposible aplicar uniformizador sobre dicha variable');
      clasificadas_d[j] := True;
      Inc(cnt_d);
    end;
  end;

  setlength(a_uniformizar_r, cnt_r);
  setlength(otras_r, length(xr_def) - cnt_r);

  j := 0;
  h := 0;
  for k := 0 to high(clasificadas_r) do
    if clasificadas_r[k] then
    begin
      a_uniformizar_r[j] := k;
      Inc(j);
    end
    else
    begin
      otras_r[h] := k;
      Inc(h);
    end;

  setlength(a_uniformizar_d, cnt_d);
  setlength(otras_d, length(xd_def) - cnt_d);
  j := 0;
  h := 0;
  for k := 0 to high(clasificadas_d) do
    if clasificadas_d[k] then
    begin
      a_uniformizar_d[j] := k;
      Inc(j);
    end
    else
    begin
      otras_d[h] := k;
      Inc(h);
    end;

  setlength(o_r, length(otras_r));
  setlength(o_d, length(otras_d));
  setlength(u_r, length(a_uniformizar_r));
  setlength(u_d, length(a_uniformizar_d));

  SetEstrellaCERO_indexada(o_r, o_d);
  loop_otras := True;
  while loop_otras do
  begin
    SetEstrella_Indexada(o_r, o_d, otras_r, otras_d);

    // calculamos el promedio
    m := 0;
    SetEstrellaCERO_indexada(u_r, u_d);
    loop_uniformizar := True;
    cnt_ := 0;
    while loop_uniformizar do
    begin
      SetEstrella_Indexada(u_r, u_d, a_uniformizar_r, a_uniformizar_d);
      m := m + costoEstrella(high(constelacion.fcosto));
      Inc(cnt_);
      loop_uniformizar := IncEstrella_indexada(u_r, u_d, a_uniformizar_r,
        a_uniformizar_d);
    end;
    m := m / cnt_;

    // imponemos el promedio calculado
    SetEstrellaCERO_indexada(u_r, u_d);
    loop_uniformizar := True;
    cnt_ := 0;
    while loop_uniformizar do
    begin
      SetEstrella_Indexada(u_r, u_d, a_uniformizar_r, a_uniformizar_d);
      SetCostoEstrella(high(constelacion.fCosto), m);
      loop_uniformizar := IncEstrella_indexada(u_r, u_d, a_uniformizar_r,
        a_uniformizar_d);
    end;


    loop_otras := IncEstrella_Indexada(o_r, o_d, otras_r, otras_d);
  end;

end;

procedure TAdminEstados.setEstrellaCERO;
begin
  vclear(estrella_kr);
  vclear(estrella_kd);
  ordinalEstrellaActual := 0;
end;

procedure TAdminEstados.SetEstrellaCERO_indexada(
  var estrella_idx_r, estrella_idx_d: TDAOfNint);
begin
  vclear(estrella_idx_r);
  vclear(estrella_idx_d);
end;


procedure TAdminEstados.SetEstrella_Indexada(vkr, vkd, idx_r, idx_d: TDAOfNInt);
var
  i: integer;
begin
  for i := 0 to high(idx_r) do
    estrella_kr[idx_r[i]] := vkr[i];
  for i := 0 to high(idx_d) do
    estrella_kd[idx_d[i]] := vkd[i];
end;


procedure TAdminEstados.AcumCostoEstrella(kPuntoT: integer; valCosto: NReal);
begin
  constelacion.acum_costo_estrella(kPuntoT, estrella_kr, estrella_kd, valCosto);
  //  constelacion.acum_costo_estrella( kPuntoT, ordinalEstrellaActual, valCosto );
end;

procedure TAdminEstados.SetCostoEstrella(kPuntoT: integer; valCosto: NReal);
begin
  constelacion.set_costo_estrella(kPuntoT, estrella_kr, estrella_kd, valCosto);
  //  constelacion.set_costo_estrella( kPuntoT, ordinalEstrellaActual, valCosto );
end;

function TAdminEstados.costoEstrella(kpuntoT: integer): NReal;
begin
  Result := constelacion.costo_estrella(kpuntoT, estrella_kr, estrella_kd);
  //  result:= constelacion.costo_estrella(kpuntoT, ordinalEstrellaActual);
end;

function TAdminEstados.costoContinuo(kPuntoT: integer): NReal;
begin
  if deterministico then
    if kPuntoT < nPuntosT then
      Result := ControladorDeterministico.GradInfos[kPuntoT - 1].CF
    else
      Result := constelacion.costo_continuo(1, xr, xd)
  else
    Result := constelacion.costo_continuo(kpuntoT, xr, xd);
end;

function TAdminEstados.GetEstado_XLT: string;
var
  k: integer;
  res: string;
begin
  res := 'xr:';
  for k := 0 to high(xr) do
    res := res + #9 + FloatToStr(xr[k]);
  res := res + #9 + 'xd:';
  for k := 0 to high(xd) do
    res := res + #9 + IntToStr(xd[k]);
  Result := res;
end;

function TAdminEstados.ChequearCompatibilidad_CFAux(
  const CFAux: TAdminEstados): boolean;
var
  msg: string;


  procedure apm(s: string);
  begin
    if msg <> '' then
      msg := msg + ', ';
    msg := msg + s;
  end;

begin
  msg := '';
  // chequear ventana temporal
  if nPuntosT <> CFAux.nPuntosT then
    apm('nPuntosT <> CFAux.nPuntosT');

  if fechaIni.dt <> CFAux.fechaIni.dt then
    apm('fechaIni.dt <> CFAux.fechaIni.dt');

  if fechaFin.dt <> CFAux.fechaFin.dt then
    apm('fechaFin.dt <> CFAux.fechaFin.dt');

  if horasDelPaso <> CFAux.horasDelPaso then
    apm('horasDelPaso <> CFAux.horasDelPaso');


  // dimensionado
  if nVarsContinuas <> CFAux.nVarsContinuas then
    apm('nVarsContinuas <> CFAux.nVarsContinuas');
  if nVarsDiscretas <> CFAux.nVarsDiscretas then
    apm('nVarsDiscretas <> CFAux.nVarsDiscretas');

  if msg <> '' then
  begin
    Result := False;
    raise Exception.Create('CFAux incompatible!!! : ' + msg);

  end
  else
    Result := True;
end;


// Retorna una TStringList con los nombres de las variables de estado
function TAdminEstados.VariablesDeEstado_lst: TStringList;
var
  k: integer;
  res: TStringList;
begin
  res := TStringList.Create;
  for k := 0 to nVarsContinuas - 1 do
    res.add(xr_def[k].nombre);
  for k := 0 to nVarsDiscretas - 1 do
    res.add(xd_def[k].nombre);
  Result := res;
end;


procedure TAdminEstados.mantoContinuo(var res: TDAOfNReal; jBase: integer;
  const Manto: TMatOfNReal);
begin
  constelacion.manto_continuo(xr, xd, res, jBase, Manto);
end;

procedure TAdminEstados.devxr_estrella_(irx: integer; kpuntoT: integer;
  var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer);
begin
  constelacion.dev_costo_estrella_(kpuntoT, estrella_kr, estrella_kd, irx,
    dCdx_Inc, dCdx_Dec, resCod);
end;

procedure TAdminEstados.devxr_estrella_20_(irx: integer; kpuntoT: integer;
  var dCdx_Inc, dCdx_Dec: NReal);
var
  codRes: integer;
  //  xrpos: NReal;
begin
  devxr_estrella_(irx, kpuntoT, dCdx_Inc, dCdx_Dec, codRes);

  if codRes <> 0 then
  begin
    if codRes < 0 then
      dCdx_Dec := dCdx_Inc * 2
    else
      dCdx_Inc := 0;
  end;
end;

procedure TAdminEstados.dumpToTextFile(const nomArchivo: string);
var
  f: Textfile;
  k, j: integer;
  iterFecha, dtDelPaso: TDateTime;
begin
  assignFile(f, nomArchivo);
  try
    rewrite(f);
    dtDelPaso := horasDelPaso * horaToDt;

    Writeln(f, 'Versión del simulador:'#9, vSimSEESimulador_);
    Writeln(f, 'fActPaso: '#9, '???'
      {FloatToStrF(globs.fActPaso, ffGeneral, 12, 10 )});
    constelacion.PrintDefsToText(f, True);
    Write(f, 'paso\estado'#9'Fecha');
    for k := 1 to nEstrellasPorPuntoT do
      Write(f, #9, k);
    Writeln(f);

    // salvamos el frame del último paso de tiempo
    for k := nPuntosT - 1 downto 1 do
    begin
      iterFecha := fechaIni.dt + dtDelPaso * (k - 1);
      Write(f, IntToStr(k) + #9 + DateTimeToIsoStr(iterFecha));

      for j := 0 to nEstrellasPorPuntoT - 1 do
        Write(f, #9, FloatToStrF(constelacion.fcosto[k][j], ffGeneral, 6, 2));
      Writeln(f);
    end;

  finally
    closefile(f);
  end;
end;

// hace un promedio del costo futuro de a nPasos.
procedure TAdminEstados.Ecualizar(nPasos: integer);
var
  k, k_ultimo, dk, j: integer;
  a: NReal;
begin
  if nPasos <= 0 then
    raise Exception.Create('TAdminEstados.Ecualizar nPasos <= 0 ');

  k_ultimo := nPuntosT - nPasos;
  if k_ultimo <= 0 then
  begin
    k_ultimo := 1;
    nPasos := nPuntosT;
  end;

  for k := 1 to k_ultimo do
  begin
    for j := 0 to nEstrellasPorPuntoT - 1 do
    begin
      a := 0;
      for dk := 0 to nPasos - 1 do
        a := a + constelacion.fcosto[k + dk][j];
      a := a / nPasos;
      constelacion.fcosto[k][j] := a;
    end;
  end;
  for k := k_ultimo + 1 to nPuntosT - 1 do
    for j := 0 to nEstrellasPorPuntoT - 1 do
      constelacion.fcosto[k][j] := constelacion.fcosto[k - 1][j];
end;

procedure TAdminEstados.LlenarConFrameFinal;
var
  k, j: integer;
  a: NReal;
begin
  // k puede ir de 1 a nPuntosT-1
  // k= 1nPuntosT-1 corresponde al fin de la última etapa.
  // k= 1 corresponde al inicio de la primer etapa
  // k= 0 no se utiliza

  // para cada estrella
  for j := 0 to nEstrellasPorPuntoT - 1 do
  begin
    // valor en el último frame
    a := constelacion.fcosto[nPuntosT - 1][j];
    for k := 1 to nPuntosT - 2 do
      constelacion.fcosto[k][j] := a;
    // lo copio en las estrellas de los frames anteriores
  end;
end;

procedure TAdminEstados.devxr_continuo(irx: integer; kpuntoT: integer;
  var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer;
  // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
  var xrpos: NReal     // Posición del punto en la cajita de paroximación en por unidad
  );
begin
  if deterministico then
  begin
    if kPuntoT < nPuntosT then
    begin
      dCdx_Inc := ControladorDeterministico.GradInfos[kPuntoT - 1].Grad_Xr[irx];
      dCdx_Dec := dcdx_Inc;
      resCod := 0;
      xrpos := 0;
    end
    else
      constelacion.dev_costo_continuo(1, xr, xd, irx, dCdx_Inc, dCdx_Dec,
        resCod, xrpos);
  end
  else
    constelacion.dev_costo_continuo(kpuntoT, xr, xd, irx, dCdx_Inc, dCdx_Dec,
      resCod, xrpos);
end;


procedure TAdminEstados.devxr_continuo_20(irx: integer; kpuntoT: integer;
  var dCdx_Inc, dCdx_Dec: NReal);

var
  codRes: integer;
  xrpos: NReal;

begin
  devxr_continuo(irx, kpuntoT, dCdx_Inc, dCdx_Dec, codRes, xrpos);

  if codRes <> 0 then
  begin
    if codRes < 0 then
    begin
      if xrpos > 0 then
      begin
        dCdx_Dec := dCdx_Dec * xrpos + (1 - xrpos) * dCdx_Inc * 2;

        // me aseguro la convexidad.
        dCdx_Dec := min(dCdx_Inc, dCdx_Dec);
      end
      else
        dCdx_Dec := dCdx_Inc * 2;
    end
    else
    begin
      if xrpos < 1 then
      begin
        // me aseguro la convexidad
        dCdx_Inc := max(dCdx_Dec, dCdx_Inc);
      end
      else
        dCdx_Inc := 0;
    end;
  end;

end;

function TAdminEstados.deltaCosto_vxd_estrella_(ird: integer;
  kpuntoT: integer; delta_xd: integer): NReal;
begin
  Result := constelacion.delta_costo_estrella_dx_(kPuntoT, estrella_kr,
    estrella_kd, ird, delta_xd);
end;

function TAdminEstados.deltaCosto_vxd_continuo(ird: integer; kpuntoT: integer;
  delta_xd: integer): NReal;
begin
  if deterministico then
    if kPuntoT < nPuntosT then
      Result := ControladorDeterministico.GradInfos[kPuntoT - 1].Grad_Xr[ird]
    else
      Result := constelacion.delta_costo_continuo_dx(1, xr, xd, ird, delta_xd)
  else
    Result := constelacion.delta_costo_continuo_dx(kpuntoT, xr, xd, ird, delta_xd);
end;

function TAdminEstados.deltaCosto_vxr_continuo(irx: integer; kpuntoT: integer;
  delta_xr: NReal): NReal;
begin
  Result := constelacion.delta_costo_continuo_rx(kpuntoT, xr, xd, irx, delta_xr);
end;

function TAdminEstados.deltaCosto_vxr_continuo_DosEstados_UTE(
  irx, irx2, kpuntoT: integer; delta_xr, delta_xr2: NReal): NReal;

begin
  Result := constelacion.delta_costo_continuo_rx_DosEstados_UTE(kPuntoT,
    xr, xd, irx, irx2, delta_xr, delta_xr2);
end;



procedure TAdminEstados.SetEstadoToEstrella;
begin
  constelacion.coordenadasEstrella_icid(xr, xd, estrella_kr, estrella_kd);
end;


procedure TAdminEstados.SetEstadoToEstrella_indexada(
  vkr, vkd, idx_r, idx_d: TDAOfNInt);
begin
  constelacion.coordenadasEstrella_icid_indexada(xr, xd, vkr, vkd, idx_r, idx_d);
end;


constructor TAdminEstados.Create(_nVarsContinuas, _nVarsDiscretas, _nPuntosT: integer);
begin
  inherited Create;
  nVarsContinuas := _nVarsContinuas;
  nVarsDiscretas := _nVarsDiscretas;
  //1 porque el de la posicion 0 se tira y otro para almacenar el costo del
  //al final del últimpo paso de tiempo.
  nPuntosT := _nPuntosT + 2;
  setLength(xr_def, nVarsContinuas);
  setLength(xd_def, nVarsDiscretas);
  setLength(xr, nVarsContinuas);
  setLength(xd, nVarsDiscretas);
  setLength(estrella_kr, nVarsContinuas);
  setLength(estrella_kd, nVarsDiscretas);
  constelacion := nil;
  deterministico := False;
  ControladorDeterministico := nil;
end;

procedure TAdminEstados.Free;
begin
  FechaIni.Free;
  fechaFin.Free;
  setLength(xr_def, 0);
  setLength(xd_def, 0);
  setLength(xr, 0);
  setLength(xd, 0);
  setLength(estrella_kr, 0);
  setLength(estrella_kd, 0);
  if constelacion <> nil then
  begin
    constelacion.Free;
    constelacion := nil;
  end;
  if ControladorDeterministico <> nil then
  begin
    ControladorDeterministico.Free;
    ControladorDeterministico := nil;
  end;
  inherited Free;
end;

procedure TAdminEstados.Registrar_Continua(ixr: integer; xmin, xmax: NReal;
  nPuntos: integer; nombre: string; unidades: string);
begin
  if nPuntos < 2 then
    raise Exception.Create('TAdminEstados.Registrar_Continua, Nombre: ' +
      nombre + ' NPuntos :' + IntToStr(nPuntos) + '. Tiene que ser > 1');
  xr_def[ixr] := TDefVarContinua.Create(nombre, unidades, xmin, xmax, nPuntos);
end;

function TAdminEstados.indexOf_Continua(nombre: string): integer;
var
  k: integer;
  buscando: boolean;
begin
  k := 0;
  buscando := True;
  while buscando and (k < length(xr_def)) do
    if xr_def[k].nombre = nombre then
      buscando := False
    else
      Inc(k);
  if buscando then
    Result := -1
  else
    Result := k;
end;

procedure TAdminEstados.RegistrarTraduccion_Continua(ixr: integer;
  //xmin, xmax: NReal; nPuntos: integer;
  const nombre, unidades: string; funcTraduccion: TFuncTraduccion);
var
  i: integer;
begin
  xr_def[ixr].traduccion := TDefVarContinua.Create(nombre, unidades,
    0, 1, xr_def[ixr].nPuntos);
  for i := 0 to high(xr_def[ixr].x) do
    xr_def[ixr].traduccion.x[i] := funcTraduccion(xr_def[ixr].x[i]);
end;

procedure TAdminEstados.Registrar_Discreta(ixd: integer; npuntos: integer;
  const nombre, unidades: string);
begin
  xd_def[ixd] := TDefVarDiscreta.Create(nombre, unidades, Npuntos);
end;


function TAdminEstados.indexOf_Discreta(nombre: string): integer;
var
  k: integer;
  buscando: boolean;
begin
  k := 0;
  buscando := True;
  while buscando and (k < length(xd_def)) do
    if xd_def[k].nombre = nombre then
      buscando := False
    else
      Inc(k);
  if buscando then
    Result := -1
  else
    Result := k;
end;



{
 procedure TAdminEstados.RegsitrarTraduccion_Discreta(ixd: integer;
  // npuntos: integer;
  nombre: string; unidades: string);
 begin
  xd_def[ixd].traduccion := TDefVarDiscreta.Create(nombre, unidades, xd_def[ixd].Npuntos);
 end;
}

procedure TAdminEstados.CrearElEspacioTiempo(fechaIni, fechaFin: TFecha;
  horasDelPaso: NReal; const costoFuturo: TMatOfNReal; deterministico: boolean);

begin
  self.FechaIni := TFecha.Create_Clone(FechaIni);
  self.fechaFin := TFecha.Create_Clone(fechaFin);
  self.horasDelPaso := horasDelPaso;
  self.deterministico := deterministico;
  if not deterministico then
  begin
    Constelacion := TConstelacion.Create(xr_def, xd_def, nPuntosT, costoFuturo);
    ControladorDeterministico := nil;
  end
  else
  begin
    if costoFuturo <> nil then
      raise Exception.Create(
        'TAdminEstados.ClearElEspacioTiempo ... deterministico  and ( costofuturo <> nil ) no es posible'
        );
    // creo un solo frame de la constelación para ser usado como FRAME FINAL
    // este frame debe ser llenado con el enganche que corresponda.
    Constelacion := TConstelacion.Create(xr_def, xd_def, 2, nil);
    ControladorDeterministico :=
      TControladorDeterministico.Create(length(xr_def), length(xd_def), nPuntosT - 1);
  end;
end;



constructor TAdminEstados_sobremuestreado.CreateLoadFromArchi(
  const archi: string; Sala_dtIni, Sala_dtFin: TdateTime; Sala_HorasDelPaso: NReal);
begin
  inherited CreateLoadFromArchi(archi);
  self.Sala_dtIni := Sala_dtIni;
  self.Sala_dtFin := Sala_dtFin;
  self.Sala_HorasDelPaso := Sala_HorasDelPaso;
  Inicios_DeltaHoras := (Sala_dtIni - fechaIni.dt) * 24.0;
end;


function TAdminEstados_sobremuestreado.CalcAprox_kPuntosT(
  Sala_kPuntoT: integer): integer;

var
  dh: NReal;
  kr: NReal;
begin
  dh := Inicios_DeltaHoras + (Sala_kPuntoT - 1) * Sala_HorasDelPaso;
  kr := dh / horasDelPaso;
  kPuntoT1 := trunc(kr) + 1;
  Peso2 := frac(kr);
  Peso1 := 1 - Peso2;
  kPuntoT2 := kPuntoT1 + 1;

  if Peso1 < 0.1 then
    Result := 2
  else if Peso2 < 0.1 then
    Result := 1
  else
    Result := 0;

  //  writeln( Sala_KPuntoT, ', ', kPuntoT1,', ', kPUntoT2 );

end;

function TAdminEstados_sobremuestreado.costoEstrella(kpuntoT: integer): NReal;
var
  c1, c2: NReal;
  rescod: integer;
begin
  rescod := CalcAprox_kPuntosT(kpuntoT);
  case rescod of
    0:
    begin
      c1 := inherited CostoEstrella(kPuntoT1);
      c2 := inherited CostoEstrella(kPuntoT2);
      Result := peso1 * c1 + peso2 * c2;
    end;
    1: Result := inherited CostoEstrella(kPuntoT1);
    2: Result := inherited CostoEstrella(kPuntoT2);
  end;
end;


function TAdminEstados_sobremuestreado.costoContinuo(kPuntoT: integer): NReal;
var
  c1, c2: NReal;
  rescod: integer;
begin
  rescod := CalcAprox_kPuntosT(kpuntoT);
  case rescod of
    0:
    begin
      c1 := inherited CostoContinuo(kPuntoT1);
      c2 := inherited CostoContinuo(kPuntoT2);
      Result := peso1 * c1 + peso2 * c2;
    end;
    1: Result := inherited CostoContinuo(kPuntoT1);
    2: Result := inherited CostoContinuo(kPuntoT2);
  end;
end;


// calcula la derivadas respecto de la variabla cuyo índice es (irx) para
// el punto de tiempo kpuntoT. La derivada dCdx_Inc es la calculada con
// un incremento de x, la dCdx_Dec es calculada con un decremento.
procedure TAdminEstados_sobremuestreado.devxr_estrella_20_(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal);
var
  dCdx_Inc1, dCdx_Inc2: NReal;
  dCdx_Dec1, dCdx_Dec2: NReal;

  rescod: integer;
begin
  rescod := CalcAprox_kPuntosT(kpuntoT);
  case rescod of
    0:
    begin
      inherited devxr_estrella_20_(irx, kPuntoT1, dCdx_Inc1, dCdx_Dec1);
      inherited devxr_estrella_20_(irx, kPuntoT2, dCdx_Inc2, dCdx_Dec2);
      dCdX_Inc := peso1 * dCdX_Inc1 + peso2 * dCdX_Inc2;
      dCdX_Dec := peso1 * dCdX_Dec1 + peso2 * dCdX_Dec2;
    end;
    1: inherited devxr_estrella_20_(irx, kPuntoT1, dCdx_Inc, dCdx_Dec);
    2: inherited devxr_estrella_20_(irx, kPuntoT2, dCdx_Inc, dCdx_Dec);
  end;
end;


procedure TAdminEstados_sobremuestreado.devxr_continuo_20(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal);
var
  dCdx_Inc1, dCdx_Inc2: NReal;
  dCdx_Dec1, dCdx_Dec2: NReal;
  rescod: integer;
begin
  rescod := CalcAprox_kPuntosT(kpuntoT);
  case rescod of
    0:
    begin
      inherited devxr_continuo_20(irx, kPuntoT1, dCdx_Inc1, dCdx_Dec1);
      inherited devxr_continuo_20(irx, kPuntoT2, dCdx_Inc2, dCdx_Dec2);
      dCdX_Inc := peso1 * dCdX_Inc1 + peso2 * dCdX_Inc2;
      dCdX_Dec := peso1 * dCdX_Dec1 + peso2 * dCdX_Dec2;
    end;
    1: inherited devxr_continuo_20(irx, kPuntoT1, dCdx_Inc, dCdx_Dec);
    2: inherited devxr_continuo_20(irx, kPuntoT2, dCdx_Inc, dCdx_Dec);
  end;
end;


procedure TAdminEstados_sobremuestreado.devxr_estrella_(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer);
var
  dCdx_Inc1, dCdx_Inc2: NReal;
  dCdx_Dec1, dCdx_Dec2: NReal;
  rrescod: integer;
begin
  rrescod := CalcAprox_kPuntosT(kpuntoT);
  case rrescod of
    0:
    begin
      inherited devxr_estrella_(irx, kPuntoT1, dCdx_Inc1, dCdx_Dec1, resCod);
      inherited devxr_estrella_(irx, kPuntoT2, dCdx_Inc2, dCdx_Dec2, resCod);
      dCdX_Inc := peso1 * dCdX_Inc1 + peso2 * dCdX_Inc2;
      dCdX_Dec := peso1 * dCdX_Dec1 + peso2 * dCdX_Dec2;
    end;
    1: inherited devxr_estrella_(irx, kPuntoT1, dCdx_Inc, dCdx_Dec, resCod);
    2: inherited devxr_estrella_(irx, kPuntoT2, dCdx_Inc, dCdx_Dec, resCod);
  end;
end;


procedure TAdminEstados_sobremuestreado.devxr_continuo(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer;
  // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
  var xrpos: NReal     // Posición del punto en la cajita de paroximación en por unidad
  );

var
  dCdx_Inc1, dCdx_Inc2: NReal;
  dCdx_Dec1, dCdx_Dec2: NReal;
  rrescod: integer;
begin

  rrescod := CalcAprox_kPuntosT(kpuntoT);
  case rrescod of
    0:
    begin
      inherited devxr_continuo(irx, kPuntoT1, dCdx_Inc1, dCdx_Dec1, resCod, xrpos);
      inherited devxr_continuo(irx, kPuntoT2, dCdx_Inc2, dCdx_Dec2, resCod, xrpos);
      dCdX_Inc := peso1 * dCdX_Inc1 + peso2 * dCdX_Inc2;
      dCdX_Dec := peso1 * dCdX_Dec1 + peso2 * dCdX_Dec2;
    end;
    1: inherited devxr_continuo(irx, kPuntoT1, dCdx_Inc, dCdx_Dec, resCod, xrpos);
    2: inherited devxr_continuo(irx, kPuntoT2, dCdx_Inc, dCdx_Dec, resCod, xrpos);
  end;
end;


// Calcula la variación del costo por un incremento delta_xd en la variable ird
// en el punto de tiempo kpuntoT
function TAdminEstados_sobremuestreado.deltaCosto_vxd_estrella_(ird: integer;
  kpuntoT: integer; delta_xd: integer): NReal;
var
  c1, c2: NReal;
  rescod: integer;
begin
  rescod := CalcAprox_kPuntosT(kpuntoT);
  case rescod of
    0:
    begin
      c1 := inherited deltaCosto_vxd_estrella_(ird, kPuntoT1, delta_xd);
      c2 := inherited deltaCosto_vxd_estrella_(ird, kPuntoT2, delta_xd);
      Result := peso1 * c1 + peso2 * c2;
    end;
    1: Result := inherited deltaCosto_vxd_estrella_(ird, kPuntoT1, delta_xd);
    2: Result := inherited deltaCosto_vxd_estrella_(ird, kPuntoT2, delta_xd);
    else
      raise Exception.Create('rescod invalido' );
  end;
end;

function TAdminEstados_sobremuestreado.deltaCosto_vxd_continuo(ird: integer;
  kpuntoT: integer; delta_xd: integer): NReal;
var
  c1, c2: NReal;
  rescod: integer;
begin
  rescod := CalcAprox_kPuntosT(kpuntoT);
  case rescod of
    0:
    begin
      c1 := inherited deltaCosto_vxd_continuo(ird, kPuntoT1, delta_xd);
      c2 := inherited deltaCosto_vxd_continuo(ird, kPuntoT2, delta_xd);
      Result := peso1 * c1 + peso2 * c2;
    end;
    1: Result := inherited deltaCosto_vxd_continuo(ird, kPuntoT1, delta_xd);
    2: Result := inherited deltaCosto_vxd_continuo(ird, kPuntoT2, delta_xd);
    else
      raise Exception.Create('rescod invalido' );

  end;
end;


function TAdminEstados_sobremuestreado.deltaCosto_vxr_continuo_DosEstados_UTE(
  irx, irx2, kpuntoT: integer; delta_xr, delta_xr2: NReal): NReal;
  // delta costo sobre una coordenada real
var
  c1, c2: NReal;
  rescod: integer;
begin
  rescod := CalcAprox_kPuntosT(kpuntoT);
  case rescod of
    0:
    begin
      c1 := inherited deltaCosto_vxr_continuo_DosEstados_UTE(
        irx, irx2, kPuntoT1, delta_xr, delta_xr2);
      c2 := inherited deltaCosto_vxr_continuo_DosEstados_UTE(
        irx, irx2, kPuntoT2, delta_xr, delta_xr2);
      Result := peso1 * c1 + peso2 * c2;
    end;
    1: Result := inherited deltaCosto_vxr_continuo_DosEstados_UTE(
        irx, irx2, kPuntoT1, delta_xr, delta_xr2);
    2: Result := inherited deltaCosto_vxr_continuo_DosEstados_UTE(
        irx, irx2, kPuntoT2, delta_xr, delta_xr2);
    else
      raise Exception.Create('rescod invalido' );

  end;
end;


function TAdminEstados_sobremuestreado.deltaCosto_vxr_continuo(irx: integer;
  kpuntoT: integer; delta_xr: NReal): NReal;
var
  c1, c2: NReal;
  rescod: integer;
begin
  rescod := CalcAprox_kPuntosT(kpuntoT);
  case rescod of
    0:
    begin
      c1 := inherited deltaCosto_vxr_continuo(irx, kPuntoT1, delta_xr);
      c2 := inherited deltaCosto_vxr_continuo(irx, kPuntoT2, delta_xr);
      Result := peso1 * c1 + peso2 * c2;
    end;
    1: Result := inherited deltaCosto_vxr_continuo(irx, kPuntoT1, delta_xr);
    2: Result := inherited deltaCosto_vxr_continuo(irx, kPuntoT2, delta_xr);
    else
      raise Exception.Create('rescod invalido' );

  end;
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TEngancheCFReal.ClassName, TEngancheCFReal);
  registrarClaseDeCosa(TEngancheCFEntero.ClassName, TEngancheCFEntero);
end;

procedure AlFinal;
begin

end;

end.
