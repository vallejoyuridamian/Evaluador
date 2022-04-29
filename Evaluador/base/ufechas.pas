unit ufechas;

{$MODE Delphi}

interface

uses
  SysUtils, DateUtils, Math, uauxiliares;

const

  diasem_DOMINGO = 1;
  diasem_LUNES = 2;
  diasem_MARTES = 3;
  diasem_MIERCOLES = 4;
  diasem_JUEVES = 5;
  diasem_VIERNES = 6;
  diasem_SABADO = 7;

  HorasDelAnio = 365 * 24;

  //rch@20140708 ... bug??  un_Minuto = 1.0 / ( 24.0 / 60.0 );
  dt_un_Minuto = 1 / (24.0 * 60.0);
  dt_medio_Minuto = dt_un_Minuto / 2.0;

  dt_Diez_Minutos = dt_un_Minuto*10;

  dt_un_Segundo = dt_un_Minuto / 60.0;
  dt_medio_Segundo = dt_un_Segundo / 2.0;
  dt_100ms = dt_un_Segundo / 10.0;
  dt_10ms = dt_un_segundo / 100.0;
  dt_1ms = dt_un_segundo / 1000.0;
  dt_treintaSegundos = 30.0 * dt_un_Segundo;

  horaToDt = 1.0 / 24.0;
  dtToHora = 24.0;

  // bisiestos son los múltiplos de 4 que no son múltiplos de 100 salvo que sea múltiplo de 400
  // entonces, en 400 años hay 3 centurias con 24 bisiestos y una con 25
  // la cantidad de bisiestos en 400 años es entonces 3 * 24 + 25 = 25*4-3 = 97
  DiasDelAnioMedio = (97.0 * 366.0 + (400.0 - 97.0) * 365) / 400.0;
  //=365.2425 considerando 97 bisiestos cada 400 años.
  DiasDelMesMedio = DiasDelAnioMedio / 12.0;
  HorasSemana52 = DiasDelAnioMedio * 24.0 / 52.0;

  dt_CicloAnual = DiasDelAnioMedio;
  dt_CicloDiario = 24.0;

type
  TTipoDia = (Habil, SemiFeriado, Feriado);
  // Sabado = SemiFeriado; Domingo = Feriado;
  TSetOfTipoDia = set of TTipoDia;

type

  { TFecha }

  TFecha = class
  public
    dt: TDateTime;

    constructor Create_Dt(dt: TDateTime);
    constructor Create_Str(const fecha: string);
    constructor Create_ISOStr(const fecha: string);
    constructor Create_Any_Str(const fecha: string);
    class function Create_Clone(fecha: TFecha): TFecha;
    constructor Create_OffsetHoras(fecha: TFecha; horasDesplazamiento: double);
    constructor Create_OffsetDT(fecha: TFecha; dtDesplazamiento: TDateTime);
    constructor Create_AnioSemana53(anio, semana53: integer);
    constructor Create_AnioMesDia(anio, mes, dia: integer);

    procedure addHoras(horas: integer);
    procedure addAnios(anios: integer);
    procedure addMeses(meses: integer);
    procedure addDias(dias: integer);

    function HorasHasta(fecha: TFecha): integer;

    function diasDesdeElInicioDelAnio: TDateTime;
    function dtPrimerDiaDelAnio: TDateTime;

    function horasDesdeElInicioDelAnio: integer;
    function aniosHasta(fecha: TFecha): integer;

    // 1 si Self> fecha, 0 si Sefl=fecha y -1 si self < fecha
    // compara con presición de 1 minuto.
    function EsMayorQue(fecha: TFecha): integer;

    function EsMayorQueEnElAnio(fecha: TFecha): integer;
    function entre(fechaIni, fechaFin: TFecha): boolean;

    // esta función recibe un dos fechas que supone ordenadas fechaIni < fechaFin
    // y que la distancia entre fechas es inferior a un año.
    // compara se Self pertenece al cajón definido por [fechaIni, fechaFin)
    // desplazando Self la cantidad de años que sea necesario.
    function entreSinConsiderarAnio(fechaIni, fechaFin: TFecha): boolean;
    procedure PonerIgualA(fecha: TFecha); overload;
    procedure PonerIgualA(const fecha: string); overload;
    procedure PonerIgualAMasOffsetHoras(fecha: TFecha; offsetEnHoras: integer);
    procedure PonerIgualAMasOffsetDT(fecha: TFecha; offsetDt: TDateTime);
    function enAnioBisiesto: boolean;

    //Comparadores binarios para facilitar la lectura de las condiciones
    function igualQue_DT(dt: TDateTime): boolean;
    function mayorQue_DT(dt: TDateTime): boolean;

    function igualQue(fecha: TFecha): boolean;
    function menorQue(fecha: TFecha): boolean;
    function menorOIgualQue(fecha: TFecha): boolean;
    function mayorQue(fecha: TFecha): boolean;
    function mayorOIgualQue(fecha: TFecha): boolean;

    procedure setDt(const fecha: string);
    function getAnio: integer;
    procedure SetAnio(const anio: integer);
    function getMes: integer;
    function getSemana52: integer;
    procedure SetSemana52(const semana52: integer);

    // Retorna el día del año: (1..366).
    function getDiaDelAnio: integer;

    // Fija el día del año dia: (1..366). Suma dia-1 al inicio del año
    procedure SetDiaDelAnio(const dia: integer);

    function getHora: integer;
    procedure setHora(const hora: integer);

    function AsStr: string;
    function AsISOStr: string;
    function AsAAAAMMDDhhmmtr: string;
    function AsDt: TDateTime;

    function TipoDeDia: TTipoDia;
    // procedure free;

    property S: string read asStr;
    //Para debug, permite ver la fecha en formato string en el inspector
    property anio: integer read getAnio write setAnio;
    property mes: integer read getMes;
    property semana52: integer read getSemana52 write setSemana52;
    property diaDelAnio: integer read getDiaDelAnio write setDiaDelAnio;
    property hora: integer read getHora write setHora;
  end;

  PFecha = ^TFecha;
  TDAofFecha = array of TFecha;

(* ojo la semana puede ser de 7 días y entonces hay hasta semana 53
o la semana puede ser calculada para que en el año haya 52 semanas
para evitar confuciones donde aparezca la semana pongamos 53 o 52 según
el rango que pueda tener la variable semana y así evitamos lios (o los atenuamos)*)
function AnioSemana53ToDateTime(anio, semana53: word): TDateTime;
procedure DateTimeToAnioSemana53(dt: TDateTime; var anio, semana53: word);

function IsoStrToDateTime(const fecha: string): TDateTime;
function DateTimeToIsoStr(const fecha: TDateTime): string;
function DateTimeToaaaammddhhmm(const fecha: TDateTime): string;
function aaaammddhhmmToDateTime(s: string): TDateTime;

function minFecha(fecha1, fecha2: TFecha): TFecha;
function maxFecha(fecha1, fecha2: TFecha): TFecha;
//Retorna true si (fecha >= fecha1) y (fecha < fecha2)
function fechaEntre(fecha, fecha1, fecha2: TDateTime): boolean;
function horasHasta(fechaDesde, fechaHasta: TDateTime): integer;


// usar esta en lugar de la de SysUtils
// la de Sysutils pierde las horas si no hay minutos  ej: '1/1/2015 06'
// lo intepreta como '1/1/2015'
function StrToDateTime(Str_DT: string): TDateTime;

function pad2d(s: string; cpad: char = '0'): string;
function padNd(s: string; N: integer; cpad: char = '0'): string;

function DiasDelAnio(anio: integer): integer;
function DiasdelMes(anio, mes: integer): integer;

// Retorna la fecha correspondiente al DomingoDePascuas
// La Semana Santa comienza el Domingo de Ramos (7 días antes)
// y dependiendo de el país es feriado toda la semana o solo Jueves y Viernes
// result = Domingo de Pascuas
// result - 1 = Sábado de Resurrección
// result - 2 = Viernes Santo
// result - 7 = Domingo de Ramos
// result - 48 = Lunes de Carnaval
// result - 47 = Martes de Carnaval
function DomingoDePascuas(year: integer): TDateTime;
function TipoDeDiaUruguay(dt: TDateTime): TTipoDia;

// 1 = Domingo   7 = Sábado
function diasem(dt: TDateTime): integer;

implementation


const
  DiasDeLosMeses: array [1..12] of integer =
    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  DiasDeLosMesesBisiesto: array [1..12] of integer =
    (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);


function diasem(dt: TDateTime): integer;
begin
  Result := DayOfWeek(dt);
end;

function TipoDeDiaUruguay(dt: TDateTime): TTipoDia;
var
  anio, mes, dia, dow: word;
  esBisiesto: boolean;
  diasParaPascuas: integer;
  flg_SabDomLun: boolean;


  // Se supone que ya se chequeó que el DiaDelMes es un Lunes y se quiere
  // verificar si DiaDelMesOriginal está en el Rango de Días que movidos
  // quedaría en ese lunes. Observar que un Jueves puede llevarse a un
  function FeriadoDesplazado(diaDelMesOriginal, diaDelMes: integer): boolean;
    //          ----+++
    //          4321012
    //          JVSDLMM
  var
    diff: integer;
  begin
    diff := DiaDelMesOriginal - DiaDelMes;
    Result := (diff = -4) or (diff = -3) or (diff = 1) or (diff = 2);
  end;

begin
  esBisiesto := decodedateFully(dt, anio, mes, dia, dow);

  if dow = 1 then
  begin
    Result := Feriado;
    exit;
  end;

  flg_SabDomLun := dow in [diasem_SABADO, diasem_DOMINGO, diasem_LUNES];

  case mes of
    1:   //  Enero
      if (dia = 1) // Año nuevo.
        or (dia = 6) // Reyes.
      then
      begin
        Result := Feriado;
        exit;
      end;

    4: //  Abril
      if (dia = 19) // UY - Desembarco de los 33 Orientales. (cambiable - Ver nota)
        and (flg_SabDomLun or (anio < 1997)) then
      begin
        Result := SemiFeriado;
        exit;
      end;

    5: //    Mayo
    begin
      if dia = 1 then//  Día de los Trabajadores [NO LABORABLE].
      begin
        Result := Feriado;
        exit;
      end;
      if (dia = 18) // UY - Batalla de Las Piedras. (cambiable - Ver nota)
        and (flg_SabDomLun or (anio < 1997)) then
      begin
        Result := SemiFeriado;
        exit;
      end;
    end;
    6: // Junio
      if (dia = 19)  // UY - Natalicio del Gral. Artigas. (no se cambia)
        and (flg_SabDomLun or (anio < 1997) or (anio > 2001)) then
      begin
        Result := SemiFeriado;
        exit;
      end;
    7: // Julio;
      if dia = 18 then // UY - Jura de la Constitución [NO LABORABLE].
      begin
        Result := Feriado;
        exit;
      end;
    8: //  Agosto;
      if dia = 25 then // UY - Declaración de la Independencia [NO LABORABLE].
      begin
        Result := Feriado;
        exit;
      end;
    10: // Octubre
      if (dia = 12) //  UY - Día de la Raza (Descubrimiento de América). (cambiable - Ver nota)
        and (flg_SabDomLun or (anio < 1997)) then
      begin
        Result := SemiFeriado;
        exit;
      end;
    11: // Noviembre;
      if (dia = 2) // UY - Día de los Difuntos. (no se cambia)
        and (flg_SabDomLun or (anio < 1997) or (anio > 2001)) then
      begin
        Result := SemiFeriado;
        exit;
      end;

    12: // Diciembre;
      if (dia = 25) then // Navidad (también llamado Día de la Familia) [NO LABORABLE].
      begin
        Result := Feriado;
        exit;
      end;
  end;



(***
  Ley Nº 16.805  (Montevideo, 24 de diciembre de 1996.)
  Artículo 1º.- Los feriados declarados por ley, sin perjuicio de la conmemoración
  de los mismos, seguirán el siguiente régimen:
  A)  Si coincidieran en sábado, domingo o lunes, se observarán en esos días.
  B)  Si ocurrieren en martes o miércoles, se observarán el lunes inmediato anterior.
  C)  Si ocurrieren en jueves o viernes, se observarán el lunes inmediato siguiente.
  Artículo 2º.- Quedan exceptuados de este régimen los feriados de Carnaval y
  Semana de Turismo y los correspondientes
  al 1º y 6 de enero, 1º de mayo, 18 de julio, 25 de agosto y 25 de diciembre,
  los que continuarán observando en el día de la semana en que ocurrieren,
  cualquiera fuere el mismo.

  Ley 17.414 (Montevideo, 8 de noviembre de 2001.)
  Artículo 1º.- Sustitúyese el artículo 2º de la Ley Nº 16.805,
  de 24 de diciembre de 1996, por el siguiente:

"ARTICULO 2º.- Quedan exceptuados de este régimen los feriados de
Carnaval y Semana de Turismo y los correspondientes
al 1º y 6 de enero, 1º de mayo, 19 de junio, 18 de  julio, 25 de agosto,
2 de noviembre y 25 de diciembre,
los que se continuarán observando en el día de la semana en que ocurrieren,
cualquiera fuere el mismo".

Artículo 2º.- Al restablecerse la condición de feriado para el
día 19 de junio el Poder Ejecutivo y los organismos rectores de la
enseñanza pública dispondrán la realización de actos destinados no
sólo a la evocación del héroe General Don José Artigas, sino a destacar
la trascendencia de sus ideales hasta su inserción en el mundo de hoy.
*)


  if (dow = DIASEM_LUNES) and (anio >= 1997) then
  begin
    case mes of
      4: //  Abril    JVSDLMM
        if feriadoDesplazado(19, dia) then
          //UY - Desembarco de los 33 Orientales. (cambiable - Ver nota)
        begin
          Result := SemiFeriado;
          exit;
        end;
      5: //  Mayo
        if feriadoDesplazado(18, dia) then
          // UY - Batalla de Las Piedras. (cambiable - Ver nota)
        begin
          Result := SemiFeriado;
          exit;
        end;
      10: //  Octubre
        if FeriadoDesplazado(12, dia) then
          // UY - Día de la Raza (Descubrimiento de América). (cambiable - Ver nota)
        begin
          Result := SemiFeriado;
          exit;
        end
        else if anio <= 2001 then // Controlamos 19 de Junio y 2 de Nov.
        begin
          case mes of
            6: // Junio
              if FeriadoDesplazado(19, dia) then
                // UY - Natalicio del Gral. Artigas. (no se cambia)
              begin
                Result := SemiFeriado;
                exit;
              end;
            11: // Noviembre;
              // 97 Dom; 98 Lun; 99 Mar -> Lun 1/11; 2000 Jue -> Lun 6
              // Nunca cambió de Mes en el rango de años en que valió el traslado
              if FeriadoDesplazado(2, dia) then //  Día de los Difuntos. (no se cambia)
              begin
                Result := SemiFeriado;
                exit;
              end;
          end;
        end;
    end;
  end;



  diasParaPascuas := round(DomingoDePascuas(anio) - dt);
  if (diasParaPascuas >= 0) and (diasParaPascuas <= 48) then
  begin
    case diasParaPascuas of
      // 48, ( el lunes lo dejo laboral por indicación del ECornalino )
      47: //  Martes de Carnaval
      begin
        Result := Feriado;
        exit;
      end;
      0, 1: // Domingo de Pascuas y Sábado de Resurrección
      begin
        Result := Feriado;
        exit;
      end;
      3: // El jueves semi-feriado
      begin
        result:= SemiFeriado;
        exit
      end;
      2:   // Viernes Santo
      begin
        Result := Feriado;
        exit;
      end;
      4, 5, 6: // Miércoles, Martes y Lunes de Semana Santa, ... semi-feriado
      begin
        Result := SemiFeriado;
        exit;
      end;
    end;
  end;

  if dow = diasem_SABADO then
    Result := SemiFeriado
  else
    Result := Habil;
end;

function StrToDateTime(Str_dt: string): TDateTime;
var
  sDate, sTime: string;
  i: integer;
begin
  sDate := trim(Str_dt);
  i := pos(' ', sDate);
  if i > 0 then
  begin
    sTime := copy(sDate, i + 1, length(sDate) - i);
    Delete(sDate, i, length(sDate) - i + 1);
    Result := StrToDate(sDate) + StrToTime(sTime);
  end
  else
    Result := SysUtils.StrToDateTime(Str_dt);
end;

function AnioSemana53ToDateTime(anio, semana53: word): TDateTime;
var
  primerDiaDelAnio: TDateTime;
  dd: double;
begin
  primerDiaDelAnio := EncodeDate(anio, 1, 1);
  dd := (semana53 - 1) * 7.0;
  Result := dd + primerDiaDelAnio;
end;

procedure DateTimeToAnioSemana53(dt: TDateTime; var anio, semana53: word);
var
  Year, Month, Day: word;
  primerDiaDelAnio: TDateTime;
  dd: integer;
begin
  DecodeDate(dt, Year, Month, Day);
  primerDiaDelAnio := EncodeDate(Year, 1, 1);
  dd := trunc(dt - primerDiaDelAnio);
  Anio := Year;
  semana53 := (dd div 7) + 1;
end;


function NextInt(var s: string; const sep: string): integer;
var
  i: integer;
  r: string;
begin
  i := pos(sep, s);
  if i > 0 then
  begin
    r := copy(s, 1, i - 1);
    Delete(s, 1, i);
  end
  else
  begin
    r := s;
    s := '';
  end;
  if r = '' then
    Result := 0
  else
    Result := StrToInt(r);
end;


function AnyStrToDateTime(const fecha: string): TDateTime;
var
  anio, mes, dia: integer;
  hora, min: integer;
  s: string;
  sep: string;
begin
  s := fecha;
  if pos('/', s) > 0 then
  begin
    sep := '/';
    dia := nextInt(s, ' ');
    mes := nextInt(s, sep);
    anio := nextInt(s, sep);
  end
  else
  begin
    sep := '-';
    anio := nextInt(s, sep);
    mes := nextInt(s, sep);
    dia := nextInt(s, ' ');
  end;
  if pos(':', s) > 0 then
    hora := nextInt(s, ':')
  else
    hora := 0;
  if pos(':', s) > 0 then
    min := nextInt(s, ':')
  else
    min := 0;

  Result := EncodeDateTime(anio, mes, dia, hora, min, 0, 0);
end;

function IsoStrToDateTime(const fecha: string): TDateTime;
var
  anio, mes, dia: integer;
  hora, min, seg: integer;
  //   0000000001111111111
  //   1234567890123456789
  //  'aaaa-mm-dd hh:mm:ss'
begin
(*
  writeln( '*0000000001111111111*' );
  writeln( '*1234567890123456789*' );
  writeln( '*aaaa-mm-dd hh:mm:ss*' );
  writeln( '*'+fecha+'*' );
*)
  anio := StrToInt(copy(fecha, 1, 4));
  mes := StrToInt(copy(fecha, 6, 2));
  dia := StrToInt(copy(fecha, 9, 2));
  if anio = 0 then
  begin
    anio := 1900;
    if mes = 0 then
    begin
      mes := 1;
      if dia = 0 then
        dia := 1;
    end;
  end;

  hora := 0;
  min := 0;
  seg := 0;

  if length(fecha) >= 13 then
  begin
    hora := StrToInt(copy(fecha, 12, 2));
    if length(fecha) >= 16 then
    begin
      min := StrToInt(copy(fecha, 15, 2));
      if length(fecha) >= 19 then
        seg := StrToInt(copy(fecha, 18, 2))
      else
        seg := 0;
    end
    else
      min := 0;
  end
  else
    hora := 0;


  Result := EncodeDateTime(anio, mes, dia, hora, min, seg, 0);
end;


function padNd(s: string; N: integer; cpad: char = '0'): string;
var
  res: string;
begin
  res := s;
  while length(res) < N do
    res := '0' + res;
  Result := res;
end;

function DiasDelAnio(anio: integer): integer;
begin
  if not IsLeapYear(anio) then
    Result := 365
  else
    Result := 366;
end;

function DiasdelMes(anio, mes: integer): integer;
begin
  if not IsLeapYear(anio) then
    Result := DiasDeLosMeses[mes]
  else
    Result := DiasDeLosMesesBisiesto[mes];
end;


function pad2d(s: string; cpad: char = '0'): string;
begin
  Result := padNd(s, 2, cpad);
end;

function DateTimeToIsoStr(const fecha: TDateTime): string;
var
  Year, Month, Day: word;
  Hour, Min, Sec, MSec: word;
  res: string;
begin
  DecodeDate(fecha, Year, Month, Day);
  DecodeTime(fecha, Hour, Min, Sec, MSec);
  res := IntToStr(Year) + '-' + pad2d(IntToStr(Month)) + '-' + pad2d(IntToStr(Day));

  if (Hour + Min) > 0 then
    res := res + ' ' + pad2d(IntToStr(Hour)) + ':' + pad2d(IntToStr(Min));
  Result := res;
end;

function DateTimeToAAAAMMDDHHMM(const fecha: TDateTime): string;
var
  Year, Month, Day: word;
  Hour, Min, Sec, MSec: word;
  res: string;
begin
  DecodeDate(fecha, Year, Month, Day);
  DecodeTime(fecha, Hour, Min, Sec, MSec);
  res := IntToStr(Year) + pad2d(IntToStr(Month)) + pad2d(IntToStr(Day));
  if (Hour + Min) > 0 then
    res := res + pad2d(IntToStr(Hour)) + pad2d(IntToStr(Min));
  Result := res;
end;

function getIntN(var s: string; nDigitos: integer; defVal: integer): integer;
var
  pal: string;
begin
  if length(s) >= nDigitos then
  begin
    pal := copy(s, 1, nDigitos);
    Delete(s, 1, nDigitos);
    Result := StrToInt(pal);
  end
  else
    Result := defVal;
end;

function aaaammddhhmmToDateTime(s: string): TDateTime;
var
  anio, mes, dia, hora, minuto, segundos: word;
  pal: string;
  dt1, dt2: TDateTime;

begin
  anio := getIntN(s, 4, -1);
  mes := getIntN(s, 2, 1);
  dia := getIntN(s, 2, 1);
  hora := getIntN(s, 2, 0);
  minuto := getIntN(s, 2, 0);
  dt1 := encodedate(anio, mes, dia);
  dt2 := encodetime(hora, minuto, 0, 0);
  Result := ComposeDateTime(dt1, dt2);
end;

function minFecha(fecha1, fecha2: TFecha): TFecha;
begin
  if fecha1.dt <= fecha2.dt then
    Result := fecha1
  else
    Result := fecha2;
end;

function maxFecha(fecha1, fecha2: TFecha): TFecha;
begin
  if fecha1.dt >= fecha2.dt then
    Result := fecha1
  else
    Result := fecha2;
end;

//Retorna true si (fecha >= fecha1) y (fecha < fecha2)
function fechaEntre(fecha, fecha1, fecha2: TDateTime): boolean;
begin
  Result := (fecha >= fecha1) and (fecha < fecha2);
end;

function horasHasta(fechaDesde, fechaHasta: TDateTime): integer;
begin
  Result := trunc(((fechaHasta - fechaDesde) * 24) + 0.1);
end;

constructor TFecha.Create_Dt(dt: TDateTime);
begin
  inherited Create;
  self.dt := dt;
end;

constructor TFecha.Create_Str(const fecha: string);
var
  tdc: char;
begin
  inherited Create;

  if (fecha <> '') and (fecha <> '0') then
    try
      self.dt := strToDateTime(fecha);
    except
      tdc := DefaultFormatSettings.DateSeparator;
      case tdc of
        '/': DefaultFormatSettings.DateSeparator := '-';
        '-': DefaultFormatSettings.DateSeparator := '/';
      end;

      try
        self.dt := StrToDateTime(fecha);
      finally
        DefaultFormatSettings.DateSeparator := tdc;
      end;
    end
  else
    self.Create_Dt(0);
end;

constructor TFecha.Create_ISOStr(const fecha: string);
begin
  inherited Create;
  self.dt := IsoStrToDateTime(fecha);
end;

constructor TFecha.Create_Any_Str(const fecha: string);
begin
  inherited Create;
  self.dt := AnyStrToDateTime(fecha);
end;

class function TFecha.Create_Clone(fecha: TFecha): TFecha;
begin
  if fecha <> nil then
    Result := TFecha.Create_Dt(fecha.dt)
  else
    Result := nil;
end;

constructor TFecha.Create_OffsetHoras(fecha: TFecha; horasDesplazamiento: double);
begin
  inherited Create;
  self.dt := fecha.dt + horasDesplazamiento * horaToDt;
end;

constructor TFecha.Create_OffsetDT(fecha: TFecha; dtDesplazamiento: TDateTime);
begin
  inherited Create;
  self.dt := fecha.dt + dtDesplazamiento;
end;

constructor TFecha.Create_AnioSemana53(anio, semana53: integer);
begin
  Create_Dt(AnioSemana53ToDateTime(anio, semana53));
end;

constructor TFecha.Create_AnioMesDia(anio, mes, dia: integer);
begin
  inherited Create;
  Self.dt := EncodeDate(anio, mes, dia);
end;

procedure TFecha.addHoras(horas: integer);
begin
  dt := dt + horas * horaToDt;
end;

procedure TFecha.addAnios(anios: integer);
begin
  dt := IncYear(dt, anios);
end;

procedure TFecha.addMeses(meses: integer);
begin
  dt := IncMonth(dt, meses);
end;

procedure TFecha.addDias(dias: integer);
begin
  dt := dt + dias;
end;

function TFecha.HorasHasta(fecha: TFecha): integer;
begin
  Result := trunc(((fecha.dt - dt) * 24) + 0.1);
end;

function TFecha.diasDesdeElInicioDelAnio: TDateTime;
var
  anio, mes, dia: word;
  dtPrimerDiaDelAnio: TDateTime;
begin
  DecodeDate(dt, anio, mes, dia);
  dtPrimerDiaDelAnio := EncodeDate(anio, 1, 1);
  Result := (dt - dtPrimerDiaDelAnio);
end;


function TFecha.dtPrimerDiaDelAnio: TDateTime;
var
  anio, mes, dia: word;
begin
  DecodeDate(dt, anio, mes, dia);
  Result := EncodeDate(anio, 1, 1);
end;

function TFecha.horasDesdeElInicioDelAnio: integer;
var
  anio, mes, dia: word;
  dtPrimerDiaDelAnio: TDateTime;
begin
  DecodeDate(dt, anio, mes, dia);
  dtPrimerDiaDelAnio := EncodeDate(anio, 1, 1);
  Result := trunc((dt - dtPrimerDiaDelAnio) * 24 + 0.1);
end;

function TFecha.aniosHasta(fecha: TFecha): integer;
var
  anioSelf, anioFecha, mes, dia: word;
begin
  DecodeDate(dt, anioSelf, mes, dia);
  DecodeDate(fecha.dt, anioFecha, mes, dia);
  Result := anioFecha - anioSelf;
end;

function TFecha.EsMayorQue(fecha: TFecha): integer;
var
  minutos: integer;
begin
  minutos := trunc((self.dt - fecha.dt) * (24 * 60));
  if minutos > 0 then
    Result := 1
  else if minutos < 0 then
    Result := -1
  else
    Result := 0;

  (*
  if self.dt < fecha.dt then result := -1
  else if self.dt = fecha.dt then result := 0
  else result := 1
  *)

end;

function TFecha.EsMayorQueEnElAnio(fecha: TFecha): integer;
var
  anioSelf, anioFecha, mesSelf, mesFecha, diaSelf, diaFecha: word;
begin
  DecodeDate(dt, anioSelf, mesSelf, diaSelf);
  DecodeDate(fecha.dt, anioFecha, mesFecha, diaFecha);
  if mesSelf < mesFecha then
    Result := -1
  else if mesSelf = mesFecha then
  begin
    if diaSelf < diaFecha then
      Result := -1
    else if diaSelf = diaFecha then
      Result := 0
    else
      Result := 1;
  end
  else
    Result := 1;
end;

function TFecha.entre(fechaIni, fechaFin: TFecha): boolean;
begin
  Result := (self.dt >= fechaIni.dt) and (self.dt < fechaFin.dt);
  //  result:= (EsMayorQue(fechaIni) >= 0) and (esMayorQue(fechaFin) <= 0);
end;

function TFecha.entreSinConsiderarAnio(fechaIni, fechaFin: TFecha): boolean;
var
  anioSelf, mesSelf, diaSelf: word;
  anioIni, mesIni, diaIni: word;
  anioFin, mesFin, diaFin: word;

  function ordenados(m1, d1, m2, d2: integer): boolean;
  begin
    Result := (m1 < m2) or ((m1 = m2) and (d1 <= d2));
  end;

  function ordenados_estricto(m1, d1, m2, d2: integer): boolean;
  begin
    Result := (m1 < m2) or ((m1 = m2) and (d1 <= d2));
  end;

begin
  DecodeDate(self.dt, anioSelf, mesSelf, diaSelf);
  DecodeDate(fechaIni.dt, anioIni, mesIni, diaIni);
  DecodeDate(fechaFin.dt, anioFin, mesFin, diaFin);


  if ordenados_estricto(mesIni, diaIni, mesFin, diaFin) then
  begin // todo en orden comparo sencillo
    Result := ordenados(mesIni, diaIni, mesSelf, diaSelf) and
      ordenados_estricto(mesSelf, diaSelf, mesFin, diaFin);
  end
  else
  begin  // el cajón pasa el límite del año comparo "abierto"
    Result := ordenados(mesIni, diaIni, mesSelf, diaSelf) or
      ordenados_estricto(mesSelf, diaSelf, mesFin, diaFin);
  end;

  (**** esto parece un bolazo
  if (mesIni < mesSelf) or                              //si fechaIni es menor o
     ((mesIni = mesSelf) and (diaIni <= diaSelf)) then  //igual en el anio que fecha
  begin
    if (mesFin > mesSelf) or                            //si fechaFin es mayor en
       ((mesFin = mesSelf) and (diaFin > diaSelf)) or   //el anio que fecha
       (anioIni < anioFin) then                         //o fechaFin es en un anio anterior anioIni
      result:= true
    else
      result:= false;
  end
  else if ((anioIni < anioFin) and (mesFin > mesSelf) or ((mesFin = mesSelf) and (diaFin > diaSelf))) then
  begin
    result:= true;
  end
  else
    result:= false;
    *****)
end;

procedure TFecha.PonerIgualA(fecha: TFecha);
begin
  dt := fecha.dt;
end;

procedure TFecha.PonerIgualA(const fecha: string);
var
  tdc: char;
begin
  if (fecha <> '0') and (fecha <> 'Auto') and (fecha <> 'auto') and
    (fecha <> 'AUTO') then
    try
      self.dt := StrToDateTime(fecha);
    except
      tdc := SysUtils.DefaultFormatSettings.DateSeparator;
      case tdc of
        '/': DefaultFormatSettings.DateSeparator := '-';
        '-': DefaultFormatSettings.DateSeparator := '/';
      end;

      try
        self.dt := StrToDateTime(fecha);
      finally
        DefaultFormatSettings.DateSeparator := tdc;
      end;
    end
  else
    self.Create_Dt(0);
end;

procedure TFecha.PonerIgualAMasOffsetHoras(fecha: TFecha; offsetEnHoras: integer);
begin
  dt := fecha.dt + offsetEnHoras * horaToDt;
end;

procedure TFecha.PonerIgualAMasOffsetDT(fecha: TFecha; offsetDt: TDateTime);
begin
  dt := fecha.dt + offsetDt;
end;

function TFecha.enAnioBisiesto: boolean;
var
  anio, mes, dia: word;
begin
  DecodeDate(dt, anio, mes, dia);
  Result := IsLeapYear(anio);
end;

function TFecha.igualQue_DT(dt: TDateTime): boolean;
begin
  Result := Self.dt = dt;
end;

function TFecha.mayorQue_DT(dt: TDateTime): boolean;
begin
  Result := self.dt > dt;
end;

function TFecha.igualQue(fecha: TFecha): boolean;
begin
  Result := self.dt = fecha.dt;
end;

function TFecha.menorQue(fecha: TFecha): boolean;
begin
  Result := self.dt < fecha.dt;
end;

function TFecha.menorOIgualQue(fecha: TFecha): boolean;
begin
  Result := self.dt <= fecha.dt;
end;

function TFecha.mayorQue(fecha: TFecha): boolean;
begin
  Result := self.dt > fecha.dt;
end;

function TFecha.mayorOIgualQue(fecha: TFecha): boolean;
begin
  Result := self.dt >= fecha.dt;
end;

function TFecha.getAnio: integer;
var
  Year, Month, Day: word;
begin
  DecodeDate(dt, Year, Month, Day);
  Result := Year;
end;

function TFecha.getMes: integer;
var
  Year, Month, Day: word;
begin
  DecodeDate(dt, Year, Month, Day);
  Result := month;
end;

procedure TFecha.SetAnio(const anio: integer);
var
  Year, Month, Day: word;
begin
  DecodeDate(dt, Year, Month, Day);
  Year := Anio;
  if (month = 2) and (day = 29) and not IsLeapYear(anio) then
    dt := EncodeDate(Year, 3, 1)
  else
    dt := EncodeDate(Year, Month, Day);
end;

function TFecha.getSemana52: integer;
var
  Year, Month, Day: word;
  primerDiaDelAnio: TDateTime;
begin
  DecodeDate(dt, Year, Month, Day);
  primerDiaDelAnio := EncodeDate(Year, 1, 1);
  if self.enAnioBisiesto then
    Result := trunc((dt - primerDiaDelAnio) / (366.0 / 52.0)) + 1
  else
    Result := trunc((dt - primerDiaDelAnio) / (365.0 / 52.0)) + 1;
end;

procedure TFecha.SetSemana52(const semana52: integer);
var
  Year, Month, Day: word;
  primerDiaDelAnio: TDateTime;
  dtDias: TDateTime;
begin
  DecodeDate(dt, Year, Month, Day);
  primerDiaDelAnio := EncodeDate(Year, 1, 1);
  if self.enAnioBisiesto then
    dtDias := (366.0 / 52.0) * (semana52 - 1)
  else
    dtDias := (365.0 / 52.0) * (semana52 - 1);

  dt := primerDiaDelAnio + dtDias;
end;


function TFecha.getDiaDelAnio: integer;
var
  Year, Month, Day: word;
  primerDiaDelAnio: TDateTime;
begin
  DecodeDate(dt, Year, Month, Day);
  primerDiaDelAnio := EncodeDate(Year, 1, 1);
  Result := trunc(dt - primerDiaDelAnio) + 1;
end;

procedure TFecha.SetDiaDelAnio(const dia: integer);
var
  Year, Month, Day: word;
  primerDiaDelAnio: TDateTime;
begin
  DecodeDate(dt, Year, Month, Day);
  primerDiaDelAnio := EncodeDate(Year, 1, 1);

  dt := primerDiaDelAnio + (dia - 1);
end;

function TFecha.getHora: integer;
begin
  Result := trunc(frac(dt) * 24 + dt_medio_Segundo) mod 24;
end;

procedure TFecha.setDt(const fecha: string);
begin
  if pos('/', fecha) <> 0 then
    self.dt := StrToDateTime(fecha)
  else
    self.dt := IsoStrToDateTime(fecha);
end;


procedure TFecha.setHora(const hora: integer);
begin
  dt := trunc(dt) + hora * horaToDt;
end;

function TFecha.AsStr(): string;
begin
  Result := DateTimeToStr(dt);
end;

function TFecha.AsISOStr(): string;
begin
  Result := DateTimeToIsoStr(dt);
end;


function TFecha.AsAAAAMMDDhhmmtr: string;
begin
  Result := DateTimeToAAAAMMDDHHMM(dt);
end;

function TFecha.AsDt: TDateTime;
begin
  Result := dt;
end;


function TFecha.TipoDeDia: TTipoDia; // 0 habil, 1 Sabado, 2 Domingo
var
  dow: integer;
begin
  (*** Sin Calendario
  dow := SysUtils.DayOfWeek(dt);
  if dow = 1 then
    Result := Feriado
  else
  if dow = 7 then
    Result := SemiFeriado
  else
    Result := Habil;
    ***)
  Result := TipoDeDiaUruguay(dt);
end;


function DomingoDePascuas(year: integer): TDateTime;
var
  a, b, c, d, e, f, g, h, i, k, l, m, p: integer;
  EasterMonth, EasterDay: word;
begin
  a := year mod 19;
  b := Math.floor(year / 100);
  c := year mod 100;
  d := Math.floor(b / 4);
  e := b mod 4;
  f := Math.floor((b + 8) / 25);
  g := Math.floor((b - f + 1) / 3);
  h := (19 * a + b - d - g + 15) mod 30;
  i := Math.floor(c / 4);
  k := c mod 4;
  l := (32 + 2 * e + 2 * i - h - k) mod 7;
  m := Math.floor((a + 11 * h + 22 * l) / 451);
  p := (h + l - 7 * m + 114);
  EasterMonth := Math.floor(p / 31);
  EasterDay := (p mod 31) + 1;
  Result := encodedate(Year, EasterMonth, EasterDay);
end;


{procedure TFecha.free;
begin
  inherited free;
end;}

{
function TFecha.DiasDelAnio: integer;
var
  anio, mes, dia: word;
begin
  DecodeDate(dt, anio, mes, dia);
  if not IsLeapYear(anio) then
    Result := 365
  else
    Result := 366;
end;
 }
{function TFecha.DiasDelMes(fecha : TFecha) : Integer;
begin
  if (fecha.anio mod 4 <> 0) or (fecha.anio mod 100 = 0) then
    result := DiasDeLosMeses[fecha.mes]
  else
    result := DiasDeLosMesesBisiesto[fecha.mes];
end;}

end.
