unit ufechas;

interface
uses
  SysUtils, DateUtils;

const
	HorasDelAnio= 365*24;
	DiasDeLosMeses : array [1..12] of Integer = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	DiasDeLosMesesBisiesto : array [1..12] of Integer = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  unSegundo = 1/(24*3600);
  horaToDt = 1/24;
  dtToHora = 24;

type
	TFecha= class
    public
			dt: TDateTime;
			function DiasDelAnio : Integer;
//				function DiasDelMes(fecha : TFecha) : Integer;

			constructor Create_Dt( dt: TDateTime );
			constructor Create_Str(const fecha : String);
      constructor Create_ISOStr(const fecha : String);
      constructor Create_Any_Str(const fecha : String);
			constructor Create_Clone(fecha : TFecha);
      constructor Create_Offset(fecha : TFecha ; horasDesplazamiento : Integer); overload;
      constructor Create_Offset(fecha : TFecha ; dtDesplazamiento : double); overload;
	  	constructor Create_AnioSemana( anio, semana: integer );
			constructor Create_AnioMesDia( anio, mes, dia: integer );

			procedure addHoras( horas: integer );
			procedure addAnios( anios : Integer);
			procedure addMeses( meses : Integer);
			procedure addDias( dias : Integer);
			function HorasHasta( fecha: TFecha ): integer;
      function horasDesdeElInicioDelAnio: Integer;
      function aniosHasta(fecha : TFecha): Integer;
			function EsMayorQue(fecha : TFecha) : Integer;
      function EsMayorQueEnElAnio(fecha: TFecha): Integer;
			function entre(fechaIni, fechaFin : TFecha) : boolean;
      function entreSinConsiderarAnio(fechaIni, fechaFin : TFecha) : boolean;
			procedure PonerIgualA(fecha: TFecha); overload;
      procedure PonerIgualA(const fecha: String); overload;
 			procedure PonerIgualAMasOffset(fecha : TFecha ; offsetEnHoras : Integer); overload;
      procedure PonerIgualAMasOffset(fecha : TFecha ; offsetDt : TDateTime); overload;
      function esEnAnioBisiesto : boolean;

      //Comparadores binarios para facilitar la lectura de las condiciones
      function igualQue(fecha: TFecha): boolean;
      function menorQue(fecha: TFecha): boolean;
      function menorOIgualQue(fecha: TFecha): boolean;
      function mayorQue(fecha: TFecha): boolean;
      function mayorOIgualQue(fecha: TFecha): boolean;

    	function getAnio: integer;
			procedure SetAnio( const anio: integer );
			function getMes : Integer;
			function getSemana: integer;
			procedure SetSemana( const semana: integer );
      //Retorna el primer día del anio
			function getDia: integer;
			procedure SetDia( const dia: integer );
			function getHora: integer;
			procedure setHora( const hora: integer );


			function AsStr: String;
      function AsISOStr() : String;
    	function AsDt: TDateTime;

			function TipoDeDia: integer; // 0 habil, 1 Sabado, 2 Domingo
//				procedure free;

 			property S : String read asStr;//Para debug, permite ver la fecha en formato string en el inspector
 			property anio: integer read getAnio write setAnio;
 			property mes : Integer read getMes;
 			property semana: integer read getSemana write setSemana;
 			property dia: integer read getDia write setDia;
 			property hora: integer read getHora write setHora;
 	 end;

   TDAofFecha = array of TFecha;

function AnioSemanaToDateTime( anio, semana: word ): TDateTime;
procedure DateTimeToAnioSemana( dt: TDateTime; var anio, semana: word );
function IsoStrToDateTime(const fecha: String) : TDateTime;
function DateTimeToIsoStr(const fecha: TDateTime) : String;

function minFecha(fecha1, fecha2: TFecha): TFecha;
function maxFecha(fecha1, fecha2: TFecha): TFecha;

implementation

function AnioSemanaToDateTime( anio, semana: word ): TDateTime;
var
	primerDiaDelAnio: TDateTime;
	dd: double;
begin
	primerDiaDelAnio:= EncodeDate( anio, 1, 1 );
	dd:= (semana-1)*7.0;
	result:=	dd+primerDiaDelAnio;
end;

procedure DateTimeToAnioSemana( dt: TDateTime; var anio, semana: word );
var
	Year, Month, Day: word;
	primerDiaDelAnio: TDateTime;
	dd: integer;
begin
	DecodeDate(dt, Year, Month, Day);
	primerDiaDelAnio:= EncodeDate( Year, 1, 1 );
	dd:= trunc(dt-primerDiaDelAnio );
	Anio:= Year;
	semana:= (dd div 7 ) +1;
end;

function IsoStrToDateTime(const fecha: String) : TDateTime;
var
  anio, mes, dia: Integer;
  hora, min: Integer;
begin
  anio:= StrToInt(copy(fecha, 1, 4));
  mes:= StrToInt(copy(fecha, 6, 2));
  dia:= StrToInt(copy(fecha, 9, 2));
  if length(fecha) > 10 then
  begin
    hora:= StrToInt(copy(fecha, 12, 2));
    min:= StrToInt(copy(fecha, 15, 2));
    result:= EncodeDateTime(anio, mes, dia, hora, min, 0, 0)
  end
  else
    result:= EncodeDate(anio, mes, dia);
end;

function pad2d( s: string ): string;
var
  res: string;
begin
  res:= s;
  while length( res ) < 2 do
    res:= '0'+res;
  result:= res;
end;

function DateTimeToIsoStr(const fecha: TDateTime) : String;
var
	Year, Month, Day: Word;
  Hour, Min, Sec, MSec: Word;
  res: string;
begin
	DecodeDate(fecha, Year, Month, Day);
  DecodeTime(fecha, Hour, Min, Sec, MSec);
	res:= IntToStr(Year)+'-'+pad2d(IntToStr(Month))+'-'+pad2d( IntToStr( Day ));

  if (Hour+Min) > 0 then
    res:= res+' '+pad2d(IntToStr(Hour))+':'+pad2d(IntToStr(Min));
  result:= res;
end;

function minFecha(fecha1, fecha2: TFecha): TFecha;
begin
  if fecha1.dt <= fecha2.dt then
    result:= fecha1
  else
    result:= fecha2;
end;

function maxFecha(fecha1, fecha2: TFecha): TFecha;
begin
  if fecha1.dt >= fecha2.dt then
    result:= fecha1
  else
    result:= fecha2;
end;

constructor TFecha.Create_Dt( dt: TDateTime );
begin
	inherited Create;
	self.dt:= dt;
end;

constructor TFecha.Create_Str(const fecha : String);
var
  tdc: char;

begin


  inherited Create;
  if fecha <> '0' then
    try
   	  self.dt := StrToDateTime(fecha);
    except
      tdc := Sysutils.DateSeparator;
      case tdc of
      '/': DateSeparator:= '-';
      '-': DateSeparator:= '/';
      end;

      try
     	  self.dt := StrToDateTime(fecha);
      finally
        DateSeparator:= tdc;
      end;
    end
  else
    self.Create_Dt(0);
end;

constructor TFecha.Create_ISOStr(const fecha : String);
begin
  inherited Create;
  self.dt:= IsoStrToDateTime(fecha);
end;

constructor TFecha.Create_Any_Str(const fecha : String);
begin
  inherited Create;
  if pos('/', fecha) <> 0 then
    self.dt := StrToDateTime(fecha)
  else
    self.dt := IsoStrToDateTime(fecha)
end;

Constructor TFecha.Create_Clone(fecha : TFecha);
begin
	inherited create;
	self.dt:= fecha.dt;
end;

constructor TFecha.Create_Offset(fecha : TFecha ; horasDesplazamiento : Integer);
begin
  inherited create;
  self.dt := fecha.dt + horasDesplazamiento * horaToDt;
end;

constructor TFecha.Create_Offset(fecha : TFecha ; dtDesplazamiento : double);
begin
  inherited create;
  self.dt := fecha.dt + dtDesplazamiento;
end;

constructor TFecha.Create_AnioSemana( anio, semana: integer );
begin
	Create_Dt( AnioSemanaToDateTime( anio, semana ));
end;

constructor TFecha.Create_AnioMesDia( anio, mes, dia: integer );
begin
  inherited Create;
  Self.dt:=EncodeDate( anio, mes, dia );
end;

procedure TFecha.addHoras( horas: integer );
begin
	dt:= dt + horas * horaToDt;
end;

procedure TFecha.addAnios( anios : Integer);
begin
  dt:= IncYear(dt, anios)
end;

procedure TFecha.addMeses( meses : Integer);
begin
	dt:= IncMonth(dt, meses)
end;

procedure TFecha.addDias( dias : Integer);
begin
	dt:= dt + dias;
end;

function TFecha.HorasHasta( fecha: TFecha ): integer;
begin
	result:= trunc(((fecha.dt - dt) * 24) + 0.1);
end;

function TFecha.horasDesdeElInicioDelAnio: Integer;
var
  anio, mes, dia: word;
  dtPrimerDiaDelAnio: TDateTime;
begin
  DecodeDate(dt, anio, mes, dia);
  dtPrimerDiaDelAnio:= EncodeDate(anio, 1, 1);
  result:= trunc((dt - dtPrimerDiaDelAnio) * 24 + 0.1)
end;

function TFecha.aniosHasta(fecha : TFecha): Integer;
var
  anioSelf, anioFecha, mes, dia: word;
begin
  DecodeDate(dt, anioSelf, mes, dia);
  DecodeDate(fecha.dt, anioFecha, mes, dia);
  result:= anioFecha - anioSelf;
end;

function TFecha.EsMayorQue(fecha : TFecha) : Integer;
var
  minutos: integer;
begin
  minutos:= trunc( (self.dt - fecha.dt)*(24*60) );
  if minutos > 0  then
    result:= 1
  else if minutos < 0 then
    result:= -1
  else
    result:= 0;

  (*
	if self.dt < fecha.dt then result := -1
	else if self.dt = fecha.dt then result := 0
	else result := 1
  *)

end;

function TFecha.EsMayorQueEnElAnio(fecha: TFecha): Integer;
var
  anioSelf, anioFecha, mesSelf, mesFecha, diaSelf, diaFecha: word;
begin
  DecodeDate(dt, anioSelf, mesSelf, diaSelf);
  DecodeDate(fecha.dt, anioFecha, mesFecha, diaFecha);
  if mesSelf < mesFecha then
    result:= -1
  else if mesSelf = mesFecha then
  begin
    if diaSelf < diaFecha then
      result:= -1
    else if diaSelf = diaFecha then
      result:= 0
    else
      result:= 1
  end
  else
    result:= 1;
end;

function TFecha.entre(fechaIni, fechaFin : TFecha) : boolean;
begin
  result:= (self.dt >= fechaIni.dt) and (self.dt < fechaFin.dt)
//	result:= (EsMayorQue(fechaIni) >= 0) and (esMayorQue(fechaFin) <= 0);
end;

function TFecha.entreSinConsiderarAnio(fechaIni, fechaFin : TFecha) : boolean;
var
  anioSelf, mesSelf, diaSelf: word;
  anioIni, mesIni, diaIni: word;
  anioFin, mesFin, diaFin: word;
begin
  DecodeDate(self.dt, anioSelf, mesSelf, diaSelf);
  DecodeDate(fechaIni.dt, anioIni, mesIni, diaIni);
  DecodeDate(fechaFin.dt, anioFin, mesFin, diaFin);

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
end;

procedure TFecha.PonerIgualA(fecha : TFecha);
begin
	dt:= fecha.dt;
end;

procedure TFecha.PonerIgualA(const fecha: String);
var
  tdc: Char;
begin
  if (fecha <> '0') and (fecha <> 'Auto') then
    try
   	  self.dt := StrToDateTime(fecha);
    except
      tdc:= Sysutils.DateSeparator;
      case tdc of
      '/': DateSeparator:= '-';
      '-': DateSeparator:= '/';
      end;

      try
     	  self.dt := StrToDateTime(fecha);
      finally
        DateSeparator:= tdc;
      end;
    end
  else
    self.Create_Dt(0);
end;

procedure TFecha.PonerIgualAMasOffset(fecha : TFecha ; offsetEnHoras : Integer);
begin
  dt:= fecha.dt + offsetEnHoras * horaToDt;
end;

procedure TFecha.PonerIgualAMasOffset(fecha : TFecha ; offsetDt : TDateTime);
begin
  dt:= fecha.dt + offsetDt;
end;

function TFecha.esEnAnioBisiesto : boolean;
var
  anio, mes, dia: word;
begin
  DecodeDate(dt, anio, mes, dia);
  result:= IsLeapYear(anio);
end;

function TFecha.igualQue(fecha: TFecha): boolean;
begin
  result:= self.dt = fecha.dt;
end;

function TFecha.menorQue(fecha: TFecha): boolean;
begin
  result:= self.dt < fecha.dt;
end;

function TFecha.menorOIgualQue(fecha: TFecha): boolean;
begin
  result:= self.dt <= fecha.dt;
end;

function TFecha.mayorQue(fecha: TFecha): boolean;
begin
  result:= self.dt > fecha.dt;
end;

function TFecha.mayorOIgualQue(fecha: TFecha): boolean;
begin
  result:= self.dt >= fecha.dt;
end;

function TFecha.getAnio: integer;
var
	Year, Month, Day: Word;
begin
	DecodeDate(dt, Year, Month, Day);
	result:= Year;
end;

function TFecha.getMes : Integer;
var
	Year, Month, Day: Word;
begin
	DecodeDate(dt, Year, Month, Day);
	result:= month;
end;

procedure TFecha.setAnio( const Anio: integer );
var
	Year, Month, Day: Word;
begin
	DecodeDate(dt, Year, Month, Day);
	Year:= Anio;
	dt:= EncodeDate(Year, Month, Day );
end;

function TFecha.getSemana: integer;
var
	Year, Month, Day: Word;
	primerDiaDelAnio: TDateTime;
begin
	DecodeDate(dt, Year, Month, Day);
	primerDiaDelAnio:= EncodeDate( Year, 1, 1 );
  result:= trunc((dt-primerDiaDelAnio )/7.038461538)+1;
end;

procedure TFecha.setSemana( const semana: integer );
var
	Year, Month, Day: Word;
begin
	DecodeDate(dt, Year, Month, Day);
	dt:= ufechas.AnioSemanaToDateTime( Year, semana );
end;


function TFecha.getDia: integer;
var
	Year, Month, Day: Word;
	primerDiaDelAnio: TDateTime;
begin
	DecodeDate(dt, Year, Month, Day);
	primerDiaDelAnio:= EncodeDate( Year, 1, 1 );
  result:= trunc(dt-primerDiaDelAnio )+1;
end;

procedure TFecha.setDia( const dia: integer );
var
	Year, Month, Day: Word;
	primerDiaDelAnio: TDateTime;
begin
	DecodeDate(dt, Year, Month, Day);
	primerDiaDelAnio:= EncodeDate( Year, 1, 1 );

	dt:= primerDiaDelAnio + ( dia - 1 );
end;

function TFecha.getHora: integer;
begin
	result:= trunc(frac( dt ) * 24 + unSegundo) mod 24;
end;



procedure TFecha.setHora( const hora: integer );
begin
	dt:= trunc(dt) + hora * horaToDt;
end;

function TFecha.AsStr() : String;
begin
	result:= sysutils.DateToStr(dt);
end;

function TFecha.AsISOStr() : String;
begin
	result:= DateTimeToIsoStr(dt);
end;

function TFecha.AsDt: TDateTime;
begin
	result:= dt;
end;

function TFecha.TipoDeDia: integer; // 0 habil, 1 Sabado, 2 Domingo
var
	dow: integer;
begin
	dow:= Sysutils.DayOfWeek( dt );
	if dow = 1 then
		result:= 2
	else
		if dow = 7 then
			result:= 1
		else
			result:= 0;
end;

{procedure TFecha.free;
begin
	inherited free;
end;}

function TFecha.DiasDelAnio: Integer;
var
  anio, mes, dia: word;
begin
  DecodeDate(dt, anio, mes, dia);
  if not IsLeapYear(anio) then
    result:= 365
  else
    result:= 366
end;

{function TFecha.DiasDelMes(fecha : TFecha) : Integer;
begin
	if (fecha.anio mod 4 <> 0) or (fecha.anio mod 100 = 0) then
		result := DiasDeLosMeses[fecha.mes]
	else
		result := DiasDeLosMesesBisiesto[fecha.mes];
end;}

end.
