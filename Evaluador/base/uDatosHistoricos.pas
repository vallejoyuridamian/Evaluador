unit uDatosHistoricos;

interface

uses
  uFechas, Classes, xMatDefs, Math, SysUtils, uAuxiliares, DateUtils, useriestemporales;

type
  TDatosHistoricos = class(TSeriesDeDatos)
  private
    nPuntosDelAnillo: integer; // cantidad de puntos del anillo


    procedure calcNAniosDatos;


    // Calcula conjunto de constantes auxileares. Debe ser llamada
    // luego de cargar la instancia para inicializar las constantes.
    procedure CalcularConstantes;


  public
    nAniosDatos_Max: integer;  // Si este es +1 del anterior significa que
    // hay datos para cubrir parte de un año adcional
    // a los nAniosDatos_Min

    nSeries, nPuntosSeries, nPuntosPorCiclo: integer;
    NombresDeBornes_Publicados: TStringList;
    dt_EntrePuntos, inv_dt_EntrePuntos: TDateTime;
    mesIni, diaIni: word;
    flg_sincronizar_miniciclo_24h: boolean;

    fechaIni: TFecha;
    fechaFin: TFecha;
    anioIni: word;
    nAniosDatos_Min: integer;  // Estos los cubre completos

    dt_InicioDatosAnillo: double;
    dta_FinDatosAnillo, dta_Anillo: double;


    // carga los datos de un archivo previamente guardado con WriteToArchi
    constructor CreateFromArchi(nombreArchivo: string);

    procedure Free;



    (***


    // retorna el índice dentro de los datos históricos de forma tal
    // que la fecha del dato al que corresponde el índice sea <= que la fecha
    // pasada como parametro. Si kAnio es >= 0 es un "desplazamiento" dentro
    // del anillo de datos. A la fecha pasada como
    // parámetro primero se le cambia el año por el año de inicio de los datos
    // más kAnio y luego se busca, si la fecha así resultante está fuera de
    // la ventada de datos se le resta la cantidad de años de datos tantas veces
    // como sea necesario para encontrar una fecha dentro de la ventana de datos.
    // esto es equivalente a suponer que los datos históricos forman un anillo
    // y que cuando nos pasamos del final comienza por el principio, pero siempre
    // teniendo cuidado de sincronizar dentro del año.
    function locate_fecha_ignore_anio_(fecha: TFecha; kAnio: integer;
      var dt_desp: NReal): integer;



    // Busca la fecha pasada como parámetro
    // esto es usado para reproducir la cronica histórica sincronizada
    // con el tiempo de las salas de simulación. El resultado < 0 implica
    // que no se encuentra la fecha buscada en la ventana de datos.
    function locate_fecha_(fecha: TFecha; var dt_desp: NReal): integer;

    // por eficiencia se supone que kIndices y Pesos ya están creados
    // de la dimensiones que corresponde.
    // Para ello se puede usar SetLength_indices_y_pesos
    procedure calc_indices_y_pesos(const AniosDesp: integer;
      const fecha: TFecha; const dt_Paso: NReal; var kIndices: TDAOfNint;
      var pesos: TDAOfNReal); // pesos para interpolar
      **)


    // fija la dimensión de los arrays de indices y pesos de interpolación
    // para un paso de simulación de ancho dt_paso.
    procedure setLength_indices_y_pesos(var kIndices: TDAOfNInt;
      var pesos: TDAOfNreal);


    // da el valor medio de un paso de tiempo que comienza
    // en el indice dado, con un desfasaje dt_desp  de ancho dt_paso
    function get_mval_(iSerie: integer; const kIndices: TDAOfNInt;
      const pesos: TDAOfNReal): NReal;


    // por eficiencia se supone que kIndices y Pesos ya están creados
    // de la dimensiones que corresponde.
    // Para ello se puede usar SetLength_indices_y_pesos
    procedure calc_indices_y_pesos_dt(const AniosDesp: integer;
      const dt_Fecha: double; var kIndices: TDAOfNint; var pesos: TDAOfNReal);
    // pesos para interpolar


  end;

implementation


procedure TDatosHistoricos.CalcularConstantes;
var
  nCiclosPorDia: NReal;
begin

  inv_dt_EntrePuntos := 1 / dt_EntrePuntos;
  fechaFin := FechaIni.Create_Clone(fechaIni);
  fechaFin.addDias(trunc(self.nPuntosSeries * self.dt_EntrePuntos + 0.1));
  calcNAniosDatos;
  nPuntosDelAnillo := (nPuntosSeries div nPuntosPorCiclo) * NPuntosPorCiclo;


  dt_InicioDatosAnillo := fechaIni.dt;
  dta_FinDatosAnillo := fechaFin.dt - fechaIni.dt;
  dta_Anillo := ceil(dta_FinDatosAnillo / dt_CicloAnual) * dt_CicloAnual;


  nCiclosPorDia := 1.0 / dt_EntrePuntos;

  flg_sincronizar_miniciclo_24h :=
    (dt_EntrePuntos < (1.0 + dt_un_Segundo / 2.0)) // un día o menos
    and (frac(nCiclosPorDia) < dt_un_Segundo);
  // la multipicidad tiene que ser por lo menos al segundo.
end;


(*
function TDatosHistoricos.locate_fecha_ignore_anio_(fecha: TFecha;
  kAnio: integer; var dt_desp: NReal): integer;
var
  res: integer;
  ft: TFecha;
  cnt: integer;
  buscando: boolean;
begin
  kAnio := kAnio mod (self.nAniosDatos_Max - 1);
  cnt := 0;
  res := -1;
  buscando := True;
  ft := TFecha.Create_Clone(fecha);
  while (buscando and (cnt <= 3)) do
  begin
    ft.SetAnio(self.anioIni + kAnio);
    res := locate_fecha_(ft, dt_desp);
    if res >= 0 then
      buscando := False
    else
    begin
      Inc(cnt);
      if kAnio = 0 then
        Inc(kAnio)
      else
        kAnio := 0;
    end;
  end;
  Result := res;
end;



function TDatosHistoricos.locate_fecha_(fecha: TFecha; var dt_desp: NReal): integer;
var
  rdt: double;
begin
  if (fecha.dt < fechaIni.dt) or (fecha.dt >= fechaFin.dt) then
  begin
    Result := -1;
  end
  else
  begin
    rdt := (fecha.dt + dt_medio_Segundo - fechaIni.dt) * inv_dt_EntrePuntos;
    dt_desp := frac(rdt);
    Result := trunc(rdt);
  end;
end;




procedure TDatosHistoricos.calc_indices_y_pesos(const AniosDesp: integer;
  // anios de desplazamiento
  const fecha: TFecha; // fecha de inicio del paso
  const dt_Paso: NReal; // ancho del paso de simulación
  var kIndices: TDAOfNint; // indices para interpolar
  var pesos: TDAOfNReal); // pesos para interpolar

var
  k, j: integer;
  desp: NReal;
  p: NReal;
  dt_base: NReal;
  rk: NReal;
begin
  dt_base := self.fechaIni.dt + AniosDesp * DiasDelAnioMedio;
  rk := (fecha.dt - dt_base) / dt_EntrePuntos;
  desp := frac(rk);

  {
  if nPuntosPorCiclo <= 52 then   // asumo DATOs GRUESOS en tramos por año calendario Fechas Inciertas
     k:= trunc( rk ) mod nPuntosDelAnillo
  else // asumo datos con fechas ciertas
}
  k := locate_fecha_ignore_anio_(fecha, AniosDesp, desp);

  kIndices[0] := k;
  p := (dt_EntrePuntos * (1 - desp)) / dt_Paso;
  pesos[0] := p;

  for j := 1 to high(pesos) - 1 do
  begin
    Inc(k);
    if k >= self.nPuntosSeries then
      k := 0;
    kIndices[j] := k;
    pesos[j] := dt_EntrePuntos / dt_Paso;
  end;

  j := high(pesos);
  desp := dt_paso - ((high(pesos) - desp) * dt_EntrePuntos);
  if desp > 0 then
  begin
    Inc(k);
    if k >= self.nPuntosSeries then
      k := 0;
  end;
  kIndices[j] := k;
  pesos[j] := desp / dt_paso;
end;



*)



// fija la dimensión de los arrays de indices y pesos de interpolación
// para un paso de simulación den ancho dt_paso.
procedure TDatosHistoricos.setLength_indices_y_pesos(var kIndices: TDAOfNInt;
  var pesos: TDAOfNreal);
var
  n: integer;
begin
  if flg_sincronizar_miniciclo_24h then
    n := 1
  else
    n := 2;

  setlength(kIndices, n);
  setlength(pesos, n);
end;


procedure TDatosHistoricos.calc_indices_y_pesos_dt(const AniosDesp: integer;
  const dt_Fecha: double; var kIndices: TDAOfNint; var pesos: TDAOfNReal);
// pesos para interpolar
var
  k, j: integer;
  desp: NReal;
  p: NReal;
  rk: NReal;
  dta_Desfasaje_HoraDelDia: double;
  dta_dato: double; // medido desde el origen del aniloo
  sincronizando: boolean;

begin

  dta_dato := frac((dt_Fecha - dt_InicioDatosAnillo - AniosDesp * dt_CicloAnual) /
    dta_Anillo) * dta_Anillo;

  if dta_dato >= dta_FinDatosAnillo then
    dta_dato := dta_dato + dt_CicloAnual - dta_Anillo;


  if flg_sincronizar_miniciclo_24h then
  begin
    //  dta_HoraDelDia := frac(dt_Fecha- dt_InicioDatosAnillo); // nos quedamos con la fase diaria para sincronizar
    // la hora si corresponde
    Sincronizando := True;
    while Sincronizando do
    begin

      dta_Desfasaje_HoraDelDia := (dt_Fecha - dt_InicioDatosAnillo) - dta_dato;
      if dta_Desfasaje_HoraDelDia > 0 then
        dta_Desfasaje_HoraDelDia := frac(dta_Desfasaje_HoraDelDia)
      else
        dta_Desfasaje_HoraDelDia := -frac(-dta_Desfasaje_HoraDelDia);

      dta_dato := dta_dato + dta_Desfasaje_HoraDelDia;
      if dta_dato < 0 then
        dta_dato := dta_dato + dt_CicloAnual
      else if dta_dato >= dta_FinDatosAnillo then
        dta_dato := dta_dato + dt_CicloAnual - dta_Anillo
      else
        sincronizando := False;
    end;
  end;

  // Bien supuestamente aquí tenemos en dta_dato
  // ahora lo pasamos a ordinal dentro del anillo.

  if length(pesos) > 1 then
  begin
    rK := dta_dato / dt_EntrePuntos;

    k := trunc(rk);
    desp := frac(rk);

    kIndices[0] := k;
    p := (1 - desp);
    pesos[0] := p;

    Inc(k);
    if k >= self.nPuntosSeries then
      k := 0;
    kIndices[1] := k;
    pesos[1] := desp;
  end
  else
  begin
    rK := dta_dato / dt_EntrePuntos;
    k := trunc(rk + 0.5);
    if k >= self.nPuntosSeries then
      k := 0;
    kIndices[0] := k;
    pesos[0] := 1.0;
  end;
end;



function TDatosHistoricos.get_mval_(iSerie: integer; const kIndices: TDAOfNInt;
  const pesos: TDAOfNReal): NReal;
var
  k: integer;
  res: NReal;
  aSerie: TDAOfNReal;
begin
  aSerie := series[iSerie].pv;
  res := aSerie[kIndices[0] + 1] * pesos[0];
  for k := 1 to high(pesos) do
    res := res + aSerie[kIndices[k] + 1] * pesos[k];
  Result := res;
end;


(**** rch@20170817 ... esto no me gusta que lea un SAS directamente
constructor TDatosHistoricos.CreateFromArchi(nombreArchivo: string);
var
  f: TextFile;
  i, j: integer;
  linea: string;
  hora, minuto, segundo: word;
  dtFechaIni: TDateTime;
  horasEntrePuntos: NReal;
  old_filemode: integer;
begin
  if FileExists(nombreArchivo) then
  begin
    AssignFile(f, nombreArchivo);

    old_FileMode := filemode;
    filemode := 0;
    Reset(f);
    filemode := old_FIlemode;
    uauxiliares.setSeparadoresGlobales;
    try
      //nSeries
      readln(f, linea);
      eliminar_BOM(linea);
      nSeries := NextInt(linea);

      //fechaIni
      Readln(f, linea);
      anioIni := NextInt(linea);
      mesIni := NextInt(linea);
      diaIni := NextInt(linea);
      hora := NextInt(linea);
      minuto := NextInt(linea);
      segundo := NextInt(linea);
      dtFechaIni := EncodeDateTime(anioIni, mesIni, diaIni, hora, minuto, segundo, 0);
      fechaIni := TFecha.Create_Dt(dtFechaIni);

      //Período de muestreo
      Readln(f, linea);

      horasEntrePuntos := NextFloat(linea);

      // Atención, si pusieron 168.5xx lo imagino que se trata de un archivo
      // con datos arreglados a 52 valores por año y pongo el valor exacto
      // de la duración para que no se desincronizen los años en simulaciones
      // muy largas.
      if abs(horasEntrePuntos - HorasSemana52) < 0.25 then
        horasEntrePuntos := HorasSemana52;

      dt_EntrePuntos := horasEntrePuntos * horaToDt;
      inv_dt_EntrePuntos := 1.0 / dt_EntrePuntos;

      //nPuntos
      readln(f, linea);
      nPuntosSeries := NextInt(linea);
      calcNAniosDatos;

      //NPuntos por Ciclo
      readln(f, linea);
      nPuntosPorCiclo := NextInt(linea);

      SetLength(series, nSeries);
      for i := 0 to nSeries - 1 do
        SetLength(series[i], nPuntosSeries);

      //Encabezados Series
      self.NombresDeBornes_Publicados := TStringList.Create;
      readln(f, linea);
      for i := 0 to nSeries - 1 do
        NombresDeBornes_Publicados.Add(NextPal(linea));

      for j := 0 to nPuntosSeries - 1 do
      begin
        readln(f, linea);
        NextPal(linea);
        for i := 0 to nSeries - 1 do
          series[i][j] := NextFloat(linea);
      end;

      CalcularConstantes;

    finally
      uauxiliares.setSeparadoresLocales;
      CloseFile(f);
    end;
  end
  else
    raise Exception.Create(
      'TDatosFuenteHistorica.CreateFromArchi: no se encuentra el archivo ' +
      nombreArchivo);

end;

procedure TDatosHistoricos.WriteToArchi(nombreArchivo: string);
var
  f: TextFile;
  i, j: integer;
  linea: string;
  anio, mes, dia, hora, minuto, segundo, ms: word;
begin
  AssignFile(f, nombreArchivo);
  try
    Rewrite(f);

    writeln(f, nSeries, #9'NSeries');
    DecodeDateTime(fechaIni.dt, anio, mes, dia, hora, minuto, segundo, ms);
    writeln(f, anio, #9, mes, #9, dia, #9, hora, #9, minuto, #9, segundo, #9'FechaIni');
    writeln(f, dt_EntrePuntos * dtToHora, #9'Período de muestreo[h]');
    writeln(f, nPuntosSeries, #9'NPuntosSeries');
    writeln(f, nPuntosPorCiclo, #9'Puntos por ciclo');

    linea := '';
    for i := 0 to NombresDeBornes_Publicados.Count - 1 do
      linea := linea + #9 + NombresDeBornes_Publicados[i];
    Writeln(f, linea);

    for j := 0 to nPuntosSeries - 1 do
    begin
      linea := IntToStr(j) + #9 + FloatToStr(series[0][j]);
      for i := 1 to nSeries - 1 do
        linea := linea + #9 + FloatToStr(series[i][j]);
      writeln(linea);
    end;
  finally
    CloseFile(f);
  end;
end;
***)

constructor TDatosHistoricos.CreateFromArchi(nombreArchivo: string);
var
  hora, minuto, segundo: word;
  dtFechaIni: TDateTime;
  horasEntrePuntos: NReal;
begin
  inherited CreateFromArchi( nombreArchivo );


  anioIni := PM_Anio;
  mesIni := PM_Mes;
  diaIni := PM_Dia;
  hora := PM_Hora;
  minuto := PM_Minuto;
  segundo := PM_segundo;
  dtFechaIni := EncodeDateTime(anioIni, mesIni, diaIni, hora, minuto, segundo, 0);
  fechaIni := TFecha.Create_Dt(dtFechaIni);
  horasEntrePuntos := PeriodoDeMuestreo_horas;

  // Atención, si pusieron 168.5xx lo imagino que se trata de un archivo
  // con datos arreglados a 52 valores por año y pongo el valor exacto
  // de la duración para que no se desincronizen los años en simulaciones
  // muy largas.
  if abs(horasEntrePuntos - HorasSemana52) < 0.25 then
    horasEntrePuntos := HorasSemana52;

  dt_EntrePuntos := horasEntrePuntos * horaToDt;
  inv_dt_EntrePuntos := 1.0 / dt_EntrePuntos;

  nPuntosSeries := nPuntos;
  calcNAniosDatos;

  nPuntosPorCiclo := round(rNPPorCiclo);
  CalcularConstantes;

end;


procedure TDatosHistoricos.Free;
begin
  fechaIni.Free;
  NombresDeBornes_Publicados.Free;
  inherited Free;
end;

procedure TDatosHistoricos.calcNAniosDatos;
begin
  // La cantidad de años está calculada para un año de 365 días.
  // Los bisiestos se supone que no molestan. La idea es determinar
  // la cantidad de "años completos" que cubre una serie de datos
  // si son 365 puntos de 1 día de tiempoEntrePuntos cubre un año!.
  nAniosDatos_Min := trunc(nPuntosSeries * dt_EntrePuntos / 365 + 0.5);
  nAniosDatos_Max := nAniosDatos_Min + 1;
end;

end.
