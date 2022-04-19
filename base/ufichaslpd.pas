(* Fichas de Lista de Parametros Dinámicos *)
unit ufichasLPD;

{$MODE Delphi}

interface

uses
  Classes, SysUtils,
  Math,
  xmatdefs,
  ucosa,
  uCosaConNombre,
  ufechas;

resourcestring
  mesElActor = 'El actor ';
  exNoTieneFicha = ' no tiene fichas.';

const  // bisiestos son los múltiplos de 4 que no son múltiplos de 100 salvo que sea
  // múltiplo de 400
  //cada 100 años 24 bisiestos y 76 comunes salvo cuando los 100 años completan
  // un múltipo de 400 caso en que hay 25 bisiestos y 75 comunes
  diasEnUnAnio = (3 * (365 * 76.0 + 366 * 24.0) + (365 * 75.0 + 366 * 25.0)) / 400.0;
  diasEnUnMes = diasEnUnAnio / 12.0;

type
  TProcCalculosAdicionales = procedure(actor: TCosa);
  TProcCalculosAdicionalesDeObjeto = procedure of object;
  TFichasLPD = class; // lo defino más adelante
  PFichaLPD = ^TFichaLPD;
  TTipoPeriodicidad = (TP_Anual, TP_Mensual, TP_Semanal, TP_Diaria);

(***
  La idea es que define un PEINE de fechas.
  La distancia entre fechas es durPeriodoEnHoras
  El peine de fechas está a su vez filtraodo por una cadencia representada
  por ciclosON fechas del peine seguida por la ausencia de ciclosOFF fechas del peine
  Para fijar el inicio de la cadencia fijamos el ciclosOffset como la cantidad
  de fechas desde la fehcaBase (inicio del peine) hasta la primera fecha
  del ciclosON.


  000000000011111111112222222222333333333344444444445555555555666666
  012345678901234567890123456789012345678901234567890123456789012345 (tiempo)
  ..............................b................................... (fecha base NO ESTA EN LA PERIODICIDAD)
  f.....f.....f.....f.....f.....f.....f.....f.....f.....f.....f..... (peine de fechas )
  0.....1.....1.....1.....0.....0.....1.....1.....1.....0.....0..... (filtro de cadencia)
  000000001111111111111111111111111111111111111111111111111100000000 (filtro de horizonte)

  Entonces, del peine de fechas que en este caso tiene período 6 (unidades de tiempo)
  La fechaBase está en la posición 30.
  El filtro de cadencia está formado por 3 ciclosOn y 2 ciclosOFF.
  Como vemos la fecha base tiene un 0 en el filtro de cadencia y no pasa
  y no tenemos que desplazar a la siguiente fecha (la que está en el 36)
  para tener una que pase el filtro de cadencia. Entonces, podemos decir
  que  ciclosOffset=1
  Además del filtro de cadencia, aplicamos un filtro de horizonte que
  solamente deja pasar las fechas que están entre las fechas del horizonte.
  En el ejemplo horizonteIni= 8 y horizonteFin= 58


*)
  { TPeriodicidad }

  TPeriodicidad = class(TCosa)
  public
    //Si alguna de las fechas es NIL se toman las fechas del horizonte de simulación
    iniHorizonte: TFecha;
    finHorizonte: TFecha;
    //La ficha va a estar activa durante cantCiclosOn y luego inactiva durante
    //cantCiclosOff, empezando en fechaBaseEnElHorizonte + (durPeriodo * offset)
    ciclosOffset: NReal;
    ciclosOn: integer;
    ciclosOff: integer;
    //La cantidad de horas que dura el período
    durPeriodoEnHoras: NReal;
    px_TipoPeriodicidad: integer;

    //fechaBaseEnElHorizonte es la fecha mas cercana a fechaBase que diste de ella
    //un multiplo de durPeriodo * (cantCiclosOn + cantCiclosOff) y este antes
    //del horizonte.
    //Para hallarla usar la funcion hallarFechaBaseEnElHorizonte de TFichaLPD

    //    xfechaBaseEnElHorizonte : TFecha;

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    constructor Create(iniHorizonte, finHorizonte: TFecha;   // filtro de horizonte
      durPeriodoEnHoras: NReal;               // distancia entre fechas del peine
      cantCiclosOn, cantCiclosOff: integer;  // filtro de cadencia
      offset: NReal; tipo: TTipoPeriodicidad);

    //retorna la cantidad de anios, meses, semanas, o dias que dura un ciclo
    function duracionEnUnidadesCiclos: integer;
    procedure Free; override;

    function GetTipoPeriodicidad: TTipoPeriodicidad;
    procedure SetTipoPeriodicidad(xTipo: TTipoPeriodicidad);
    property tipoPeriodicidad_: TTipoPeriodicidad
      read GetTipoPeriodicidad write SetTipoPeriodicidad;

  end;


  TFichaLPD_auxRec = class
    esPeriodica: boolean;
    ciclosOn, ciclosOff, auxTipo: integer;
    durPeriodo: NReal;
    offset: NReal;
    ini, fin: TFecha;
  end;

  { TFichaLPD }

  TFichaLPD = class(TCosa)
  private
    //procedimiento auxiliar para incrementar la fecha de la ficha en la cantidad
    //de ciclos especificada mas el offset de la periodicidad
    //los ciclos se incrementan usando la lógica de fechas exacta (incYear, incMonth, incDay)
    //Si el offset es un número entero incrementa usando la lógica de fechas
    //exacta sino suma las durPeriodoEnHoras * ciclosOffset
    procedure incFechaPorCiclosMasOffset(nCiclos: integer);
  public
    px: TFichaLPD_auxRec;

    expandida, activa: boolean; //El actualizadorLPD solo considera aquellas
    //fichas que tengan activa = true

    periodicidad: TPeriodicidad;
    fecha: TFecha;

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad);

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    //Si la ficha es periodica se agrega expandida en lista
    //en el periodo [fechaIni, fechaFin]
    procedure expandirseEn(CatalogoReferencias: TCatalogoReferencias;
      idHilo: integer; lista: TFichasLPD; fechaIni, fechaFin: TFecha); virtual;

    function fechaMasInfoAd: string;
    function InfoAd_: string; override;
    procedure generarLineaResumen(var archi: TextFile); virtual; abstract;
    procedure Free; override;

  end;

  TClaseDeFichaLPD = class of TFichaLPD;

  { TFichasLPD }

  TFichasLPD = class(TListaDeCosas)
  private
    calculosAdicionales: TProcCalculosAdicionales;
    //Devuelve la ficha en la posición indicada
    function getFicha(i: integer): TFichaLPD; overload;
    procedure setFicha(i: integer; ficha: TFichaLPD);
  public
    Propietario: TCosaConNombre; // puntero a la cosa a la que pertenece
    pA, pB: PFichaLPD;
    // Punteros a las variables a modificar en la medida en que el tiempo cambia
    // El actualizador intenta mantener pA con una ficha cuya fecha sea menor o igual
    // a la del tiempo de simulación y pB con una ficha cuya fecha sea superior o igual
    // al tiempo de simulación.
    tipo: TClaseDeFichaLPD;
    calculosAdicionalesEsclavizador: TProcCalculosAdicionalesDeObjeto;

    constructor Create(capa: integer; idCarpeta: string;
      Propietario: TCosaConNombre; tipo: TClaseDeFichaLPD);

    function Rec: TCosa_RecLnk; override;
    procedure WriteToText_(f: TArchiTexto); override;

    procedure RegistrarFichasAActualizar(Propietario: TCosaConNombre;
      Actualizador: pointer;
      pFichaA, pFichaB: PFichaLPD     // la que sea nil no se actualiza
      ); overload;

    procedure RegistrarFichasAActualizar(Propietario: TCosaConNombre;
      Actualizador: pointer; pFichaA, pFichaB: PFichaLPD;
    // la que sea nil no se actualiza
      CalculosAdicionales: TProcCalculosAdicionales); overload;

    procedure Prepararse(FechaInicial: TFecha);


    //Inserta la ficha en su lugar correspondiente en el orden
    function insertar(ficha: TFichaLPD): integer;

    // Busca si hay una ficha de undades con la misma fecha, si la hay
    // le suma las unidades. Si no la hay crea una nueva ficha con
    // las unidades de la ficha anterior (en el tiempo) más delta_unidades
    // El resultado es el índice de la ficha modificada o agregada en la lista.
    // OJo, que este procedimiento NO maneja las periodicidades.
    // Como efecto secundario se retorna en delta_unidades los valores
    // que quedaron en la ficha.
    // Supopne que el Delta es en Unidades Instaladas e impone en CERO las unidades
    // en mantenimiento Programado
    function delta_unidades_(fecha: TFecha; var delta_Unidades: TDAOfNInt): integer;

    //Llama al expandir de cada ficha que contenga pasandoles como parametros las fechas
    //del horizonte de simulacion
    //Hay que pasarlo como object porque sino da circular unit reference
    procedure expandirFichas(CatalogoReferencias: TCatalogoReferencias;
      globs: TObject);

    //Libera todas las fichas expandidas
    procedure clearExpanded;

    //Libera todas las ficha
    procedure clearAll;


    procedure errorDatos(s: string);
    procedure chequeo_datos(FechaInicial, FechaFinal: TFecha);

    property f[i: integer]: TFichaLPD read getFicha write setFicha; default;

(* Busca las fichas de datos que continen un dt dado.
El resultado de la función es -1 si el dt dado es anterior
a todas las fichas. Cero (0 ) si el dt esta entre
las fichas identificadas por i1 e i2 y 1 si el dt es posterior
a todas las fichas.
En todos los caso i1 e i2 identifican los indices de las fichas
y f1, f2 son las fichas seleccionadas como aquellas que contienen
a la fecha dt. Si el resultado de la función es cero esto es así.
En el caso de resultado -1 i2=0 y f2= items[0] en el caso
de resultado = 1 i1= count-1 y f1= items[count-1] *)
    function locate_dt(var i1, i2: integer; var f1, f2: TFichaLPD;
      xfecha: TFecha; i1_desde: integer): integer; overload;
    function locate_dt(var i1, i2: integer; var f1, f2: TFichaLPD;
      fecha_dt: TDateTime; i1_desde: integer): integer; overload;


    procedure SortByFecha;

    procedure cambiarFicha(ificha: integer);
    procedure cambiarPorFichaAnteriorAFicha(ificha: integer);

    function chequeoFechas(fechaIni, fechaFin: TFecha): boolean;

    // Si la lista es de UNIDADES retorna la cantidad de tipos de unidades
    function unidades_nTipos: integer;

    // Retorna el valor máximo de unidades instaladas del tipo kTipo
    function unidades_MaximoInstaladas(kTipo: integer): integer;

  end;

procedure AlInicio;
procedure AlFinal;




// funciones de conversión auxiliares.
// para la conversión se considera el promedio de años bisiestos en 100 años
function horasToAnios(horas: NReal): NReal;
function horasToMeses(horas: NReal): NReal;
function horasToSemanas(horas: NReal): NReal;
function horasToDias(horas: NReal): NReal;
function aniosTohoras(anios: NReal): NReal;
function mesesToHoras(meses: NReal): NReal;
function semanasToHoras(semanas: NReal): NReal;
function diasToHoras(dias: NReal): NReal;

implementation

uses
  uActualizadorLPD, uGlobs, uActores, uunidades;

//---------------------
// Métodos de TFichaLPD
//=====================

constructor TFichaLPD.Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad);
begin
  inherited Create(capa);
  Self.fecha := fecha;
  self.periodicidad := periodicidad;
  expandida := False;
end;

function TFichaLPD.Rec: TCosa_RecLnk;
var
  res: TCosa_RecLnk;
begin
  res := inherited Rec;
  res.addCampoDef('fecha', fecha);
  res.addCampoDef('expandida', expandida);

  // Hasta la 146, la lectura es condicionada a una bandera "esPeriodica"
  res.addCampoDef('esPeriodica', px.esPeriodica, 0, 147);
  res.addCampoDef('iniHorizonte', px.ini, 0, 147, '', @px.esPeriodica);
  res.addCampoDef('finHorizonte', px.fin, 0, 147, '', @px.esPeriodica);
  res.addCampoDef('offset', px.offset, 0, 147, '0', @px.esPeriodica);
  res.addCampoDef('ciclosOn', px.ciclosOn, 0, 147, '0', @px.esPeriodica);
  res.addCampoDef('ciclosOff', px.ciclosOff, 0, 147, '0', @px.esPeriodica);
  res.addCampoDef('durPeriodoEnHoras', px.durPeriodo, 0, 147, '0.0', @px.esPeriodica);
  res.addCampoDef('tipo', px.auxTipo, 0, 147, '0', @px.esPeriodica);

  // Desde la 147 escribimos la Periodicidad
  res.addCampoDef('periodicidad', TCosa(periodicidad), 147);

  Result := res;
end;

procedure TFichaLPD.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
  px := TFichaLPD_auxRec.Create;
end;

procedure TFichaLPD.AfterRead(version, id_hilo: integer);
var
  tipo: TTipoPeriodicidad;
begin
  inherited AfterRead(version, id_hilo);
  tipo := TTipoPeriodicidad(px.auxTipo);
  if version < 147 then
  begin
    if px.esPeriodica then
      periodicidad := TPeriodicidad.Create(px.ini, px.fin,
        px.durPeriodo, px.ciclosOn, px.ciclosOff, px.offset, tipo)
    else
      periodicidad := nil;
  end;
  px.Free;
end;


procedure TFichaLPD.expandirseEn(CatalogoReferencias: TCatalogoReferencias;
  idHilo: integer; lista: TFichasLPD; fechaIni, fechaFin: TFecha);
var
  ini_dt, fin_dt: TDateTime;
  kIniHorizonte, kFinHorizonte, kCiclo, kCiclo_EnCadencia,
  NCiclosPorPeriodoDeCadencia: integer;
  aux: TFichaLPD;
  fechaBase_dt, durCiclo_dt: TDateTime;
begin
  if periodicidad <> nil then
  begin
    self.activa := False;

    if periodicidad.durPeriodoEnHoras = 0 then
      raise Exception.Create(
        'TFichaLPD.expandirseEn .. durPeriodoEnHoras = 0. No puede especifiar fichas periódicas con período CERO'
        );

    // duración de un ciclo
    durCiclo_dt := periodicidad.durPeriodoEnHoras / 24.0;

    // dterminamos la fecha de inicio del Horizonte de Expansión.
    if periodicidad.iniHorizonte.dt = 0 then
      ini_dt := fechaIni.dt - durCiclo_dt - 0.5
    else
    if periodicidad.iniHorizonte.dt < fechaIni.dt then
    begin
      ini_dt := fechaIni.dt - durCiclo_dt - 0.5;
      if ini_dt < periodicidad.iniHorizonte.dt then
        ini_dt := periodicidad.iniHorizonte.dt;
    end
    else
      ini_dt := periodicidad.iniHorizonte.dt;

    // determinamos la fecha de fin del Horizonte de Expansión
    if periodicidad.finHorizonte.dt = 0 then
      fin_dt := fechaFin.dt + durCiclo_dt + 0.5
    else
    if periodicidad.finHorizonte.dt > fechaFin.dt then
    begin
      fin_dt := fechaFin.dt + durCiclo_dt + 0.5;
      if fin_dt > periodicidad.finHorizonte.dt then
        fin_dt := periodicidad.finHorizonte.dt;
    end
    else
      fin_dt := periodicidad.finHorizonte.dt;

    // ojo mirar la documentación para ver si el Offset es un adelanto o
    // un atraso. Así es un atraso, es decir la ficha se corre hacia el futuro
    // "sucediendo más tarde".
    fechaBase_dt := fecha.dt + periodicidad.ciclosOffset * durCiclo_dt;

    kIniHorizonte := Ceil((ini_dt - fechaBase_dt) / durCiclo_dt - 0.001);
    kFinHorizonte := Floor((fin_dt - fechaBase_dt) / durCiclo_dt);

    NCiclosPorPeriodoDeCadencia := periodicidad.ciclosOn + periodicidad.ciclosOff;

    for kCiclo := kIniHorizonte to kFinHorizonte do
    begin
      kCiclo_EnCadencia := moduloCiclico(kCiclo, NCiclosPorPeriodoDeCadencia);
      if (kCiclo_EnCadencia < periodicidad.ciclosOn) then
      begin
        aux := Create_Clone(CatalogoReferencias, idHilo) as TFichaLPD;
        aux.fecha.dt := fecha.dt;
        aux.incFechaPorCiclosMasOffset(kCiclo);
        aux.periodicidad.Free;
        aux.periodicidad := nil;
        aux.expandida := True;
        aux.activa := True;
        lista.add(aux);
      end;
    end;
  end
  else
    // si no tiene periodicidad usamos la ficha.
    self.activa := True;
end;

function TFichaLPD.fechaMasInfoAd: string;
begin
  Result := fecha.AsStr + ': ' + infoAd_;
end;

function TFichaLPD.InfoAd_: string;
begin
  if periodicidad = NIL then
    Result := inherited InfoAd_+fecha.AsStr+','
  else
    Result := inherited InfoAd_+fecha.AsStr+'*,';
end;

procedure TFichaLPD.Free;
begin
  fecha.Free;
  if periodicidad <> nil then
    periodicidad.Free;
  inherited Free;
end;


procedure TFichaLPD.incFechaPorCiclosMasOffset(nCiclos: integer);
var
  offsetEnUnidadesCiclo: NReal;
  nUnidadesCiclo: integer;
  fraccion: NReal;
begin
  nUnidadesCiclo := periodicidad.duracionEnUnidadesCiclos;
  offsetEnUnidadesCiclo := periodicidad.ciclosOffset * nUnidadesCiclo;
  case periodicidad.tipoPeriodicidad_ of
    TP_Anual:
    begin
      fecha.addAnios(nCiclos * nUnidadesCiclo);
      if (periodicidad.ciclosOffset <> 0) then
      begin
        fecha.addAnios(trunc(offsetEnUnidadesCiclo));
        fraccion := Frac(offsetEnUnidadesCiclo);
        if fraccion <> 0 then
          fecha.dt :=
            fecha.dt + fraccion * periodicidad.durPeriodoEnHoras * horaToDt;
      end;
    end;
    TP_Mensual:
    begin
      fecha.addMeses(nCiclos * nUnidadesCiclo);
      if (periodicidad.ciclosOffset <> 0) then
      begin
        fecha.addMeses(trunc(offsetEnUnidadesCiclo));
        fraccion := Frac(offsetEnUnidadesCiclo);
        if fraccion <> 0 then
          fecha.dt :=
            fecha.dt + fraccion * periodicidad.durPeriodoEnHoras * horaToDt;
      end;
    end;
    TP_Semanal:
    begin
      fecha.addDias(7 * nCiclos * nUnidadesCiclo);
      if (periodicidad.ciclosOffset <> 0) then
      begin
        fecha.addDias(7 * trunc(offsetEnUnidadesCiclo));
        fraccion := Frac(offsetEnUnidadesCiclo);
        if fraccion <> 0 then
          fecha.dt :=
            fecha.dt + fraccion * periodicidad.durPeriodoEnHoras * horaToDt;
      end;
    end;
    TP_Diaria:
    begin
      fecha.addDias(nCiclos * nUnidadesCiclo);
      if (periodicidad.ciclosOffset <> 0) then
      begin
        fecha.addDias(trunc(offsetEnUnidadesCiclo));
        fraccion := Frac(offsetEnUnidadesCiclo);
        if fraccion <> 0 then
          fecha.dt :=
            fecha.dt + fraccion * periodicidad.durPeriodoEnHoras * horaToDt;
      end;
    end;
  end;
end;

//-------------------------
// Métodos de TPeriodicidad
//=========================

function TPeriodicidad.Rec: TCosa_RecLnk;
begin
  Result := inherited Rec;
  Result.addCampoDef('iniHorizonte', iniHorizonte, 147);
  Result.addCampoDef('finHorizonte', finHorizonte, 147);
  Result.addCampoDef('ciclosOffset', ciclosOffset, 147);
  Result.addCampoDef('ciclosOn', ciclosOn, 147);
  Result.addCampoDef('ciclosOff', ciclosOff, 147);
  Result.addCampoDef('durPeriodoEnHoras', durPeriodoEnHoras, 147);
  Result.addCampoDef('tipo', px_tipoPeriodicidad, 147);
end;

procedure TPeriodicidad.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TPeriodicidad.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;

constructor TPeriodicidad.Create(iniHorizonte, finHorizonte: TFecha;
  durPeriodoEnHoras: NReal; cantCiclosOn, cantCiclosOff: integer;
  offset: NReal; tipo: TTipoPeriodicidad);
begin
  inherited Create;
  self.iniHorizonte := iniHorizonte;
  self.finHorizonte := finHorizonte;
  Self.durPeriodoEnHoras := durPeriodoEnHoras;
  ciclosOn := cantCiclosOn;
  ciclosOff := cantCiclosOff;
  ciclosOffset := offset;
  tipoPeriodicidad_ := tipo;
  self.devaluar;
end;

function horasToAnios(horas: NReal): NReal;
begin
  Result := horas / (diasEnUnAnio * 24);
end;

function horasToMeses(horas: NReal): NReal;
begin
  Result := horas / (diasEnUnMes * 24);
end;

function horasToSemanas(horas: NReal): NReal;
begin
  Result := horas / (7 * 24);
end;

function horasToDias(horas: NReal): NReal;
begin
  Result := horas * horaToDt;
end;

function aniosTohoras(anios: NReal): NReal;
begin
  Result := anios * diasEnUnAnio * 24;
end;

function mesesToHoras(meses: NReal): NReal;
begin
  Result := meses * diasEnUnMes * 24;
end;

function semanasToHoras(semanas: NReal): NReal;
begin
  Result := semanas * 7 * 24;
end;

function diasToHoras(dias: NReal): NReal;
begin
  Result := dias * 24;
end;

function TPeriodicidad.duracionEnUnidadesCiclos: integer;
begin
  case tipoPeriodicidad_ of
    TP_Anual: Result := round(horasToAnios(durPeriodoEnHoras));
    TP_Mensual: Result := round(horasToMeses(durPeriodoEnHoras));
    TP_Semanal: Result := round(horasToSemanas(durPeriodoEnHoras));
    TP_Diaria: Result := round(horasToDias(durPeriodoEnHoras));
    else
      raise Exception.Create(
        'TPeriodicidad.duracionEnUnidadesCiclos: tipo de periodicidad desconocido ' +
        IntToStr(Ord(tipoPeriodicidad_)));
  end;
end;

procedure TPeriodicidad.Free;
begin
  iniHorizonte.Free;
  finHorizonte.Free;
  inherited Free;
end;

function TPeriodicidad.GetTipoPeriodicidad: TTipoPeriodicidad;
begin
  Result := TTipoPeriodicidad(px_TipoPeriodicidad);
end;

procedure TPeriodicidad.SetTipoPeriodicidad(xTipo: TTipoPeriodicidad);
begin
  px_TipoPeriodicidad := Ord(xTipo);
end;

//----------------------
// Métodos de TFichasLPD
//======================

constructor TFichasLPD.Create(capa: integer; idCarpeta: string;
  Propietario: TCosaConNombre; tipo: TClaseDeFichaLPD);
begin
  inherited Create(capa, idCarpeta);
  self.Propietario := Propietario;
  self.tipo := tipo;
end;

function TFichasLPD.Rec: TCosa_RecLnk;
begin
  Result := inherited Rec;
end;

procedure TFichasLPD.WriteToText_(f: TArchiTexto);
begin
  clearExpanded;
  inherited WriteToText_(f);
end;

function TFichasLPD.getFicha(i: integer): TFichaLPD;
begin
  Result := self.lst.items[i];
end;

procedure TFichasLPD.setFicha(i: integer; ficha: TFichaLPD);
begin
  items[i] := ficha;
end;

procedure TFichasLPD.RegistrarFichasAActualizar(Propietario: TCosaConNombre;
  // es redundante, pero resuelve un problema
  Actualizador: pointer; pFichaA, pFichaB: PFichaLPD);
begin
  Self.pA := pFichaA;
  Self.pB := pFichaB;
  if Propietario <> nil then
    Self.Propietario := Propietario;
  TActualizadorFichasLPD(Actualizador).agregarListaDeFichas(self);
  self.calculosAdicionales := nil;
  self.calculosAdicionalesEsclavizador := nil;
end;

procedure TFichasLPD.RegistrarFichasAActualizar(Propietario: TCosaConNombre;
  // es redundante, pero resuelve un problema
  Actualizador: pointer; pFichaA, pFichaB: PFichaLPD;
  CalculosAdicionales: TProcCalculosAdicionales);
begin
  RegistrarFichasAActualizar(Propietario, Actualizador, pFichaA, pFichaB);
  Self.calculosAdicionales := CalculosAdicionales;
  self.calculosAdicionalesEsclavizador := nil;
end;

procedure TFichasLPD.errorDatos(s: string);
begin
  raise Exception.Create('Error preparando lista:' + tipo.ClassName +
    ' del Actor: ' + Propietario.Nombre + ' ' + s);
end;

procedure TFichasLPD.chequeo_datos(FechaInicial, FechaFinal: TFecha);
var
  ficha: TFichaLPD;
begin
  if lst.Count <= 0 then
    errorDatos('No hay ninguna ficha definida');

  if pA = nil then
    errorDatos('pA=nil');

  ficha := TFichaLPD(lst.items[0]);
  if ficha.fecha.EsMayorQue(FechaInicial) > 0 then
    errorDatos('No hay ficha de datos con fecha anterior o igual al inicio de la simulación');

  if pB = nil then
    exit;

  ficha := TFichaLPD(lst.items[lst.Count - 1]);
  if ficha.fecha.EsMayorQue(FechaFinal) < 0 then
    errorDatos('No hay una ficha posterior con fecha posterior o igual al fin de la simulación'
      );
end;

procedure TFichasLPD.Prepararse(FechaInicial: TFecha);
var
  res: integer;
  i1, i2: integer;
  f1, f2: TFichaLPD;
begin
  if (pA = nil) then
    exit;
  res := locate_dt(i1, i2, f1, f2, FechaInicial, -1);
  if (pB = nil) then
  begin
    case res of
      -1: pA^ := f1;
      0: pA^ := f1;
      1: pA^ := f2;
    end; // case
  end
  else
  begin
    case res of
      -1:
      begin
        pA^ := nil;
        pB^ := f2;
      end;
      0:
      begin
        pA^ := f1;
        pB^ := f2;
      end;
      1:
      begin
        pA^ := f1;
        pB^ := nil;
      end;
    end; // case
  end;
  if assigned(CalculosAdicionales) then
    CalculosAdicionales(self.Propietario);
  if Assigned(calculosAdicionalesEsclavizador) then
    calculosAdicionalesEsclavizador;
end;

function TFichasLPD.insertar(ficha: TFichaLPD): integer;
var
  i, pos: integer;
begin
  pos := -1;
  for i := 0 to lst.Count - 1 do
    if ficha.fecha.EsMayorQue(TFichaLPD(lst.items[i]).fecha) < 0 then
    begin
      pos := i;
      break;
    end;
  if pos <> -1 then
  begin
    lst.insert(pos, ficha);
    Result := pos;
  end
  else
    Result := add(ficha);
end;

function TFichasLPD.delta_unidades_(fecha: TFecha;
  var delta_Unidades: TDAOfNInt): integer;
var
  k, i: integer;
  difh: integer;
  aFicha, bFicha, ficha: TFichaUnidades;
  fecha_: TFecha;
  kUnid: integer;
  buscando: boolean;

  dd: TDAOfNInt;
  AltaUnidadesConIncertidumbre, InicioCronicaConIncertidumbre: TDAOfBoolean;
begin
  setlength(dd, length(delta_unidades));
  setlength(AltaUnidadesConIncertidumbre, length(delta_unidades));
  setlength(InicioCronicaConIncertidumbre, length(delta_unidades));

  for k := 0 to high(dd) do
    dd[k] := delta_unidades[k];

  i := lst.Count - 1;
  buscando := True;
  while buscando and (i >= 0) do
  begin
    aFicha := TFichaUnidades(lst.items[i]);
    difh := trunc((fecha.dt - aFicha.fecha.dt) * 24);
    if difh < 0 then
      Dec(i)
    else
      buscando := False;
  end;

  if not buscando then
  begin
    if difh > 0 then
    begin
      fecha_ := TFecha.Create_Clone(fecha);
      for kUnid := 0 to high(delta_unidades) do
        delta_unidades[kUnid] :=
          aFicha.nUnidades_Instaladas[kUnid] + delta_unidades[kUnid];
      ficha := TFichaUnidades.Create(aficha.capa, fecha_, nil,
        delta_unidades, nil, aFicha.AltaConIncertidumbre,
        aFicha.InicioCronicaConIncertidumbre);
      Inc(i);
      if i < lst.Count then
        lst.insert(i, ficha)
      else
        lst.Add(ficha);
      Result := i;
    end
    else
    begin
      // modifico la ficha existente
      for kUnid := 0 to high(delta_unidades) do
      begin
        delta_unidades[kUnid] :=
          aFicha.nUnidades_Instaladas[kUnid] + delta_unidades[kUnid];
        aFicha.nUnidades_Instaladas[kUnid] := delta_unidades[kUnid];
      end;
      Result := i;
    end;

    for k := i + 1 to lst.Count - 1 do
    begin
      aFicha := TFichaUnidades(lst.items[k]);
      for kUnid := 0 to high(delta_unidades) do
        aFicha.nUnidades_Instaladas[kUnid] :=
          aFicha.nUnidades_Instaladas[kUnid] + dd[kUnid];
    end;

  end
  else
  begin

    for k := 0 to high(dd) do
    begin
      AltaUnidadesConIncertidumbre[k] := True;
      InicioCronicaConIncertidumbre[k] := True;
    end;

    fecha_ := TFecha.Create_Clone(fecha);
    ficha := TFichaUnidades.Create(0, fecha_, nil, delta_unidades,
      nil, AltaUnidadesConIncertidumbre, InicioCronicaConIncertidumbre);
    lst.Insert(0, ficha);
    Result := 0;
  end;
  setlength(dd, 0);
  setlength(AltaUnidadesConIncertidumbre, 0);
  setlength(InicioCronicaConIncertidumbre, 0);
end;


procedure TFichasLPD.expandirFichas(CatalogoReferencias: TCatalogoReferencias;
  globs: TObject);
var
  i, oldCount_MenosUno: integer;
  fIni, fFin: TFecha;
begin
  if globs = nil then
    raise Exception.Create('Llamó expandirFichas(globs = nil )');

  case TGlobs(globs).EstadoDeLaSala of
    CES_SIN_PREPARAR: //Si estoy editando la sala
    begin
      if TGlobs(globs).fechaIniOpt.menorOIgualQue(TGlobs(globs).fechaIniSim) then
        fIni := TGlobs(globs).fechaIniOpt
      else
        fIni := TGlobs(globs).fechaIniSim;
      if TGlobs(globs).fechaFinOpt.mayorOIgualQue(TGlobs(globs).fechaFinSim) then
        fFin := TGlobs(globs).fechaFinOpt
      else
        fFin := TGlobs(globs).fechaFinSim;
    end;

    CES_OPTIMIZANDO: //Si estoy por optimizar
    begin
      fIni := TGlobs(globs).fechaIniOpt;
      fFin := TGlobs(globs).fechaFinOpt;
    end;
    CES_SIMULANDO: //Si estoy por simular
    begin
      fIni := TGlobs(globs).fechaIniSim;
      fFin := TGlobs(globs).fechaFinSim;
    end;
    else
      raise Exception.Create('TFichasLPD.expandirFichas en estado:' +
        IntToStr(Ord(CES_SIMULANDO)));

  end;

  self.clearExpanded;
  oldCount_MenosUno := lst.Count - 1;
  for i := 0 to oldCount_MenosUno do
    TFichaLPD(lst.items[i]).expandirseEn(CatalogoReferencias,
      TGlobs(globs).idHilo, self, fIni, fFin);
  SortByFecha;
end;

procedure TFichasLPD.clearExpanded;
var
  i: integer;
begin
  for i := 0 to lst.Count - 1 do
    if TFichaLPD(lst.items[i]).expandida then
    begin
      TFichaLPD(lst.items[i]).Free;
      lst.items[i] := nil;
    end
    else
      TFichaLPD(lst.items[i]).activa := False;
  lst.pack;
end;


procedure TFichasLPD.clearAll;
var
  i: integer;
begin
  for i := 0 to lst.Count - 1 do
  begin
    TFichaLPD(lst.items[i]).Free;
    lst.items[i] := nil;
  end;
  lst.pack;
end;


function TFichasLPD.locate_dt(var i1, i2: integer; var f1, f2: TFichaLPD;
  fecha_dt: TDateTime; i1_desde: integer): integer;
var
  buscando: boolean;
begin
  if (i1_desde >= lst.Count) or (i1_desde < 0) then
    i1_desde := 0;
  i1 := i1_desde;
  f1 := TFichaLPD(lst.items[i1]);
  if fecha_dt >= f1.fecha.dt then
  begin
    i2 := i1 + 1;
    if i2 >= lst.Count then
    begin
      i2 := i1;
      f2 := f1;
      Result := 1;
      exit;
    end
    else
    begin // busco en sentido creciente
      buscando := True;
      while buscando and (i2 < lst.Count) do
      begin
        f2 := TFichaLPD(lst.items[i2]);
        if (f2.fecha.dt >= fecha_dt) then
          buscando := False
        else
        begin
          i1 := i2;
          f1 := f2;
          Inc(i2);
        end;
      end;
      if buscando then
      begin
        f2 := f1;
        i2 := i1; // solo para que no quede apuntando afuera
        Result := 1;
      end
      else
        Result := 0;
    end;
  end
  else
  begin // busco en reversa dt < dt1
    buscando := True;
    Dec(i1);
    while buscando and (i1 >= 0) do
    begin
      f1 := TFichaLPD(lst.items[i1]);
      if f1.fecha.dt <= fecha_dt then
        buscando := False
      else
        Dec(i1);
    end;
    if buscando then
    begin
      i1 := 0;
      f1 := TFichaLPD(lst.items[i1]);
      i2 := 0;
      f2 := TFichaLPD(lst.items[i2]);
      Result := -1;
    end
    else
    begin
      i2 := i1 + 1; // seguro que i2 < count
      f2 := TFichaLPD(lst.items[i2]);
      Result := 0;
    end;
  end;
end;


function TFichasLPD.locate_dt(var i1, i2: integer; var f1, f2: TFichaLPD;
  xfecha: TFecha; i1_desde: integer): integer;
begin
  Result := locate_dt(i1, i2, f1, f2, xfecha.dt, i1_desde);
end;


function FichasLPD_CompareFechaYCapa(Item1, Item2: pointer): integer;
var
  res: integer;
begin
  res := TFichaLPD(Item1).fecha.EsMayorQue(TFichaLPD(Item2).fecha);
  if res = 0 then
    if TFichaLPD(item1).capa < TFichaLPD(item2).capa then
      res := -1
    else if TFichaLPD(item1).capa = TFichaLPD(item2).capa then
      res := 0
    else
      res := 1;
  Result := res;
end;

procedure TFichasLPD.SortByFecha;
begin
  lst.Sort(FichasLPD_CompareFechaYCapa);
end;



function TFichasLPD.unidades_nTipos: integer;
var
  ficha: TFichaUnidades;
begin
  if self.lst.Count = 0 then
  begin
    Result := 0;
    exit;
  end;

  ficha := TCosa(self.lst.Items[0]) as TFichaUnidades;
  Result := length(ficha.nUnidades_Instaladas);
end;

// Retorna el valor máximo de unidades instaladas
function TFichasLPD.unidades_MaximoInstaladas(kTipo: integer): integer;
var
  kFicha: integer;
  ficha: TFichaUnidades;
  res: integer;
begin
  res := 0;
  for kFicha := 0 to lst.Count - 1 do
  begin
    ficha := self.lst.items[kFicha];
    if ficha.nUnidades_Instaladas[kTipo] > res then
      res := ficha.nUnidades_Instaladas[kTipo];
  end;
  Result := res;
end;



procedure TFichasLPD.cambiarFicha(ificha: integer);
var
  xNuevaFicha: TFichaLPD;
begin
  xNuevaFicha := TFichaLPD(lst.items[ificha]);
  if pb = nil then
    pa^ := xNuevaFicha
  else
  begin
    pa^ := xNuevaFicha;
    if (ificha + 1) < lst.Count then
      pb^ := TFichaLPD(lst.items[ificha + 1])
    else
      pb^ := nil;
  end;
  if assigned(CalculosAdicionales) then
    CalculosAdicionales(self.Propietario);
  if Assigned(calculosAdicionalesEsclavizador) then
    calculosAdicionalesEsclavizador;
end;

procedure TFichasLPD.cambiarPorFichaAnteriorAFicha(ificha: integer);
begin
  if ificha > 0 then
    cambiarFicha(ificha - 1);
end;

function TFichasLPD.chequeoFechas(fechaIni, fechaFin: TFecha): boolean;
begin
  if Propietario = nil then
  begin
    raise Exception.Create('Error!! Propietario=NIL en TFichasLPD.chequeoFechas ');
    //result:= false;
  end;

  if lst.Count <> 0 then
  begin
    if (pA <> nil) then
      case fechaIni.EsMayorQue(TFichaLPD(lst.items[0]).fecha) of
        1, 0:
        begin
          if pB = nil then
            Result := True
          else
            case TFichaLPD(lst.items[lst.Count - 1]).fecha.EsMayorQue(fechaFin) of
              1, 0: Result := True;
              else
              begin
                raise Exception.Create(
                  'No hay una ficha con fecha posterior a la fecha de fin en el actor ' +
                  Propietario.nombre);
                Result := False;
              end
            end;
        end
        else
        begin
          raise Exception.Create(
            'No hay una ficha con fecha anterior a la fecha de inicio en el actor ' +
            Propietario.nombre);
          Result := False;
        end
      end
    else
    begin
      raise Exception.Create('La ficha inicial es vacia en el actor ' +
        Propietario.nombre);
      Result := False;
    end;
  end
  else
  begin
    raise Exception.Create(mesElActor + Propietario.ClaseNombre + exNoTieneFicha);
    Result := False;
  end;
end;













procedure AlInicio;
begin
  ucosa.registrarClaseDeCosa(TPeriodicidad.ClassName, TPeriodicidad);
  ucosa.registrarClaseDeCosa(TFichasLPD.ClassName, TFichasLPD);
end;

procedure AlFinal;
begin
end;

end.
