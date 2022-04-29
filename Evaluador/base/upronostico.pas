unit upronostico;
interface

uses
  Classes, SysUtils, xMatDefs, ufechas, ucosa, Math, umodelosintcegh;

const
  C_DT_1MINUTO = 1.0 / 24.0 / 60.0;

type
  // definición del Cono de Pronósticos para una serie temporal.
  // La "guia" es la especificación del Cono de Pronósticos en el Espacio de la Señal.
  // en base a la guía se calculan el vector "sesgos" y "factor" que contiene
  // que se aplican en el Espacio Gaussiano para guiar la salida del Filtro Lineal.
  // el ruido que se aplica sobre el canal se calcula como:
  // rs = sesgo[j] + factor[j] * Brbg[i]
  // donde "Brbg" es el Ruido Blanco Gaussiano transformado por la matriz B
  // del filtro lineal que corersponde al canal en cuestión
  // El control del cono de pronósticos se realiza mediante una "guia" del cono
  // e indicaciones de cómo abrir el cono de dispersión.
  // El vector "guia" indica valores para la guía. De ese vector, se utilizan los
  // primeros valores para inicializar el estado del filtro lineal.
  // El parámetro NPSA = Número de Pasos Sin Apertura del cono, determina la
  // cantidad de valores de la guía, posteriores a los usados para fijar el estado
  // inicial que serán utilizados como valores determinísticos.
  // Ese valor puede ir entre 0 hasta el total de valores que queden en la guía.

  { TPronostico }
  T_aux_pronostico = class  // auxilar para lectura
    p: NReal;
    nretardos: Integer;
    Serie: String;
    _fechaIniSesgo_: TCosa;
  end;


  { TPronostico
    Información del Cono de Pronóstico de una Serie de un modelo CEGH.
  }
  TPronostico = class(TCosa)
  private
    rangoFechaSesgo: NReal; // rango de aplicación del sesgo.
    rangoFechaFactor: NReal; // rango de aplicación del ruido

  public
  (**************************************************************************)
  (*              A T R I B U T O S   P E R S I S T E N T E S               *)
  (**************************************************************************)

    Serie_: String; // Nombre de la serie a la que esta asociado el pronostico
    kSerie_: integer; // A resolver en PrepararMemoria
    nRetardos_: integer; // Número de valores de la guía que serán usados para inicializar el filtro lineal
    guia: TDAOfNReal; // Guía en el espacio de la señal real
    guia_eg: TDAOfNReal; // Guía en el espacio gasussiano de la señal.
    guia_pe: NReal;      // probabilidad de excedencia de la guía.
    sesgo: TDAOfNReal; // sesgo del ruido (aditivo)
    factor: TDAOfNReal; // multiplicadores del ruido (multimplicativo)
    fechaIniSesgo: TFecha; // fecha a partir de la cual aplica el sesgo
    // parámetros de calibración control del cono de pronóstico a partir de los determinismos.
    NPCC: integer; // Número de Pasos de Control del Cono
    NPLC: integer; // Número de Pasos de Liberación del Cono
    NPSA: integer; // Número de pasos Sin Apertura del Cono (determinista).
    NPAC: integer; // Número de Pasos de Apertura del Cono
    // información para consulta a servicio web de pronósticos.
    url_get: string; // ej: http://simsee.org/pronosticos
    nombre_get: string; // ej: PEOL_1MW
    //Cantidad de valores deterministicos usados

  (**************************************************************************)
    cantValoresDeterministicosUsados: integer;
    constructor Create(capa: integer; xNPCC,
      xNPLC, xNPSA, xNPAC: integer; xurl_get, xnombre_get: string);
    constructor Create_Default(cegh: TModeloCEGH);

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    procedure Cambiar_GUIA(xNPCC, xNPLC, xNPSA,xNPAC: integer;xNuevaGuia: TDAOfNReal );
    procedure Free; override;
    function determinismoSoloEstadoInicial: boolean;

    // retorna max( NPCC+NPLC , NPSA+NPAC)
    // es útil para determinar a partir de qué paso el cono ya no tiene influencia.
    function NPasosCono: integer;

    // debe ser llamado en el preparar memoria de la fuente
    procedure calcular_rangos(DuracionPasoSorteoEnHoras: NReal);

    // determina si para la fechaDeInicioDelPaso pasada como parámetro es válido el cono
    // depronósticos o no. Si el resultado es TRUE indica que la fecha está en el rango del cono
    // y entonces en kSesgo y kFactor se devuelve los índices para leer los valores correspondientes
    // de los vectores "sesgo" y "factor".
    function fechaEnRango(fechaDeInicioDelPaso: TFecha;var kSesgo, kFactor: integer): boolean;


  private
    px: T_aux_pronostico; // auxiliar para lectura
  end;


  { TPronosticos
  Conjunto de Pronosticos, uno por SERIE asociados a una probabilidad
  de ocurrencia  P.
  }

  TPronosticos = class(TListaDeCosas)
  private
    modeloCEGH: TModeloCEGH;
  public

    P: Integer;

    constructor Create_Default (cegh: TModeloCEGH );

    procedure reset_DeterminismosUsados;
    procedure prepararse(DuracionPasoSorteoEnHoras: NReal );
    // retorna el máximo largo en pasos de sorteo de la fuente de los conos
    // de pronósticos represnetado.
    function max_NPasosCono: integer;

    constructor Create_ReadFromText(f: TArchiTexto); override;
    procedure WriteToText_(f: TArchiTexto); override;

    function getItem(i: integer): TPronostico;
    procedure setItem(i: integer; cosa: TPronostico);
    property items[i: integer]: TPronostico read getItem write setItem; default;

  end;


  { TEscenarioDePronosticos
  Conjunto de TPronosticos.
  }

  TEscenarioDePronosticos=class(TListaDeCosas)
  private
    function getItem(i: integer): TPronosticos;

  public
    constructor Create(capa: integer); override;

    function Add(Pronosticos: TPronosticos; P: Integer): integer;
    property items[Index: Integer]:TPronosticos read getItem; default;

    function GetEscenarioPorP(xP: NReal): TPronosticos;
    procedure prepararse(DuracionPasoSorteoEnHoras: NReal );
  end;


procedure AlInicio;
procedure AlFinal;

implementation

{ TEscenarioDePronosticos }

function TEscenarioDePronosticos.getItem(i: integer): TPronosticos;
begin
  Result := lst.items[i];
end;

constructor TEscenarioDePronosticos.Create(capa: integer);
begin
  inherited Create(capa, '');
end;

function TEscenarioDePronosticos.Add(Pronosticos: TPronosticos; P: Integer
  ): integer;
begin
  Result:= inherited Add(Pronosticos);
  Pronosticos.P:=P;
end;

function TEscenarioDePronosticos.GetEscenarioPorP(xP: NReal): TPronosticos;
var
  i: Integer;
  PAcum: NReal;
begin
  if (xP<0) or (xP>100) then
    raise Exception.Create('TEscenarioDePronosticos.GetEscenarioPorP: 0<=xP<=100, xP='+
      FloatToStrF(xP, ffGeneral, 3,4));
  PAcum:=0;
  for i:=0 to self.Count-1 do
  begin
    PAcum:=PAcum+(items[i] as TPronosticos).p;
    if PAcum>=xp then
    begin
      Result:=items[i] as TPronosticos;
      break;
    end;
  end;
end;

procedure TEscenarioDePronosticos.prepararse(DuracionPasoSorteoEnHoras: NReal );
var
  aPronosticos: TPronosticos;
  k: integer;
begin
  for k:= 0 to count -1 do
  begin
    aPronosticos:= items[k];
    aPronosticos.prepararse( DuracionPasoSorteoEnHoras );
  end;
end;

function TPronosticos.getItem(i: integer): TPronostico;
begin
  Result := TPronostico(inherited items[i]);
end;

procedure TPronosticos.setItem(i: integer; cosa: TPronostico);
begin
  inherited items[i] := cosa;
end;



constructor TPronosticos.Create_Default(cegh: TModeloCEGH );
var
  i: Integer;
begin
  inherited Create(0, '');
  self.modeloCEGH:=cegh;
  for i:=0 to self.modeloCEGH.NombresDeBornes_Publicados.Count-1 do
   self.Add(TPronostico.Create_Default(self.modeloCEGH));
  P:=0;
end;

procedure TPronosticos.reset_DeterminismosUsados;
var
  k: integer;
begin
  for k := 0 to Count - 1 do
  begin
    TPronostico(items[k]).cantValoresDeterministicosUsados := 0;
  end;
end;

procedure TPronosticos.prepararse(DuracionPasoSorteoEnHoras: NReal);
var
  k: integer;
begin
  for k := 0 to Count - 1 do
    items[k].calcular_rangos(DuracionPasoSorteoEnHoras);
end;

function TPronosticos.max_NPasosCono: integer;
var
  k: integer;
  m, res: integer;
begin
  res := TPronostico(items[0]).NPasosCono;
  for k := 1 to Count - 1 do
  begin
    m := TPronostico(items[k]).NPasosCono;
    if (m > res) then
      res := m;
  end;
  Result := res;
end;

constructor TPronosticos.Create_ReadFromText(f: TArchiTexto);
begin
  if f.Version >= 143 then
     f.rd('P', P );
  inherited Create_ReadFromText(f);
end;

procedure TPronosticos.WriteToText_(f: TArchiTexto);
begin
  f.wr('P', P );
  inherited WriteToText_(f);
end;

constructor TPronostico.Create(capa: integer; xNPCC, xNPLC, xNPSA,
  xNPAC: integer; xurl_get, xnombre_get: string);
begin
  inherited Create( capa );

  NPCC := xNPCC;
  NPLC := xNPLC;
  NPSA := xNPSA;
  NPAC := xNPAC;

  url_get:= xurl_get;
  nombre_get:= xnombre_get;

  //fechaIniSesgo_ := TFecha.Create_Dt(0);
  rangoFechaSesgo := 0;
  guia_pe := 0.5;

  //  cantValoresDeterministicosUsados := 0;
end;


procedure TPronostico.Cambiar_GUIA(
  xNPCC, xNPLC, xNPSA,
  xNPAC: integer;
  xNuevaGuia: TDAOfNReal );
begin
  NPCC := xNPCC;
  NPLC := xNPLC;
  NPSA := xNPSA;
  NPAC := xNPAC;

  guia:= copy( xNuevaGuia );

  //fechaIniSesgo_ := TFecha.Create_Dt(0);
  rangoFechaSesgo := 0;
  guia_pe := 0.5;
end;


constructor TPronostico.Create_Default(cegh: TModeloCEGH );
begin
  Create(0, 0, 0, 0, 0, '', '');
  SetLength(guia, cegh.CalcOrdenDelFiltro);
  vclear(guia);

end;

function TPronostico.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('Serie', px.Serie, 133, 143 );
  Result.addCampoDef('p', px.p, 133, 143 );
  // Si la version es menor el nombre de los bornes para los pronosticos los carga
  // Create_ReadFromText de la fuente
  Result.addCampoDef('nretardos', px.nretardos,0, 143);
  Result.addCampoDef('guia', guia);
  Result.addCampoDef('guia_eg', guia_eg, 82, 143 );
  Result.addCampoDef('guia_pe', guia_pe, 0, 143 );
  Result.addCampoDef('NPCC', NPCC);
  Result.addCampoDef('NPLC', NPLC);
  Result.addCampoDef('NPSA', NPSA);
  Result.addCampoDef('NPAC', NPAC);
  Result.addCampoDef('sesgo', sesgo);
  Result.addCampoDef('factor', factor);
  Result.addCampoDef('fechaIniSesgo', px._fechaIniSesgo_, 0, 143 );
  Result.addCampoDef('rangoFechaSesgo', rangoFechaSesgo, 0, 143 );
  Result.addCampoDef( 'url_get', url_get, 126 );
  Result.addCampoDef( 'nombre_get', nombre_get, 126 );
end;

procedure TPronostico.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
  url_get:= '';
  nombre_get:= '';
  px:= T_aux_pronostico.Create;
end;

procedure TPronostico.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
  if version < 82 then
   setlength(guia_eg, length(guia)); // no los dejo en CERO.
 //  cantValoresDeterministicosUsados := 0;
  px.free
end;

function TPronostico.NPasosCono: integer;
begin
  Result := max(NPCC + NPLC, NPSA + NPAC);
end;


procedure TPronostico.calcular_rangos(DuracionPasoSorteoEnHoras: NReal);
begin
  self.rangoFechaSesgo := (NPCC + NPLC) * DuracionPasoSorteoEnHoras / 24.0;
  self.rangoFechaFactor := (NPSA + NPAC) * DuracionPasoSorteoEnHoras / 24.0;
end;

function TPronostico.fechaEnRango(fechaDeInicioDelPaso: TFecha;
  var kSesgo, kFactor: integer): boolean;
var
  dxdt: NReal;
begin
  dxdt := fechaDeInicioDelPaso.dt - fechaIniSesgo.dt + C_DT_1MINUTO;
  if (dxdt > 0) then
  begin
    if (dxdt < rangoFechaSesgo) then
      kSesgo := trunc(dxdt / rangoFechaSesgo * length(sesgo))
    else
      kSesgo := -1; // indicamos fuera de rango.
    if (dxdt < rangoFechaFactor) then
      kFactor := trunc(dxdt / rangoFechaFactor * length(factor))
    else
      kFactor := -1; // indicamos fuera de rango.
  end
  else
  begin
    kSesgo := -1;
    kFactor := -1;
  end;
  Result := (kSesgo >= 0) or (kFactor >= 0);
end;



procedure TPronostico.Free;
begin
  setlength(guia, 0);
  setlength(sesgo, 0);
  setlength(factor, 0);
  if fechaIniSesgo <> nil then
    FechaIniSesgo.Free;
  inherited Free;
end;

function TPronostico.determinismoSoloEstadoInicial: boolean;
begin
  Result := NPSA = 0;
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TPronostico.ClassName, TPronostico);
  registrarClaseDeCosa(TPronosticos.ClassName, TPronosticos);
  registrarClaseDeCosa(TEscenarioDePronosticos.ClassName, TEscenarioDePronosticos);
end;

procedure AlFinal;
begin
end;


end.
