unit udatoshorariosdetallados;
(* La idea es usar estos objetos para leer archivos de datos detallados
donde se supone que al inicio del archivo hay dos números del tipo TDateTime
que describen el rango de datos y que luego viene el conjunto de datos
desde la hora CERO de la fecha de INicio hasta la hora 23 de la fecha def FIN.
*)
interface

uses
  SysUtils, xmatdefs, ubuscaarchivos, classes;

type
  TDatosHorariosDetallados = class
  private
    fechaProxLectura: TDateTime;
    ArchivoAbierto: boolean;
    fdatos: TFileStream;

    // Infor del caché de interpolación.
    ci_dt1, ci_dt2: TDateTime; // fechas del primer valor y del siguiente al último
    ci_v: TDAOfNReal; // valores

  public
    archiDatos: string;
    fechaPrimerDia, fechaUltimoDia: TDateTime;
    constructor Create( archiDatos: string; BuscaArchivos: TBuscaArchivos );
    constructor CreateForWrite(archiDatos: string);
    procedure Free; virtual;

    // Lee la cantidad de valores correspondiente a length( BuffNReal )
    // si no logra leer tantos valores dispara una excepción..
    procedure ReadBuff_horario(var BuffNReal: TDAOfNReal; fecha: TDateTime);
    procedure WriteBuff_horario(fechaIni, fechaFin: TDateTime; BuffNReal: TDAofNReal);
    procedure WriteToXLT(archi: string);

    // Interpola entre las horas. Usando el Cache de Interpol
    function interpol( fecha: TDateTime ): NReal;

    class procedure WriteToBin(archi: string; fechaIni, fechaFin: TDateTime;
      datos: TDAofNReal);
    function cantDatos: integer;
    function sumDatos: NReal;
  end;

implementation

procedure TDatosHorariosDetallados.WriteToXLT(archi: string);
var
  sal: textfile;
  r: array[1..1024] of NReal;
  nleidos: integer;
  leyendo: boolean;
  k, cnt_escritos, kDia: integer;
begin
  assignfile(sal, archi);
  rewrite(sal);
  writeln(sal, 'FechaPrimerDia:', #9, DateTimeToStr(FechaPrimerDia));
  writeln(sal, 'FechaUltimoDia:', #9, DateTimeToStr(FechaUltimoDia));
  Write(sal, 'Fecha\Hora');
  for k := 0 to 23 do
    Write(sal, #9, k);
  writeln(sal);
  cnt_escritos := 0;
  kDia := 0;
  leyendo := True;
  while leyendo do
  begin
    nleidos:= fdatos.Read( r[1], 1024 * SizeOf(r[1]) );
    nleidos := nleidos div SizeOf(r[1]);
    for k := 1 to nleidos do
    begin
      if cnt_escritos = 0 then
        Write(sal, DateTimeToStr(fechaPrimerDia + kDia), #9);
      Write(sal, FloatToStrF(r[k], ffGeneral, 15, 32), #9);
      Inc(cnt_escritos);
      if cnt_escritos = 24 then
      begin
        writeln(sal);
        cnt_escritos := 0;
        Inc(kDia);
      end;
    end;
    if nleidos < 1024 then
      leyendo := False;
  end;
  closefile(sal);
end;


// Interpola entre las horas. Usando el Cache de Interpol
function TDatosHorariosDetallados.interpol( fecha: TDateTime ): NReal;
var
 rh: NReal;
 ih: integer;
 alfa, res: NReal;
begin
  if ( fecha < ci_dt1 ) or ( fecha >= ci_dt2 ) then
    ReadBuff_horario( ci_v, trunc( fecha ) );

  rh:= (fecha - ci_dt1) * 24.0;
  ih:= trunc( rh );
  alfa:= frac( rh );

  if ih < high( ci_v ) then
    res:= ci_v[ih]* (1-alfa)+ ci_v[ih+1] *alfa
  else
  begin
  // estoy en la última hora del Buffer tengo que leer hacia adelante
  // salvo que esté al final del archivo
    if ci_dt2 >= fechaUltimoDia then
     res:= ci_v[ high( ci_v ) ]
    else
    begin
      res:= ci_v[ high( ci_v ) ]*(1-alfa);
      ci_dt1:= trunc( ci_dt2 );
      ci_dt2:= ci_dt1+1;
      ReadBuff_horario( ci_v, ci_dt1);
      res:= res + alfa * ci_v[0];    // supongo que el buffer es múltiplo de 24
    end;
  end;
  result:= res;
end;


class procedure TDatosHorariosDetallados.WriteToBin(archi: string;
  fechaIni, fechaFin: TDateTime; datos: TDAofNReal);
var
  f: TDatosHorariosDetallados;
begin
  f := TDatosHorariosDetallados.CreateForWrite(archi);
  f.WriteBuff_horario(fechaIni, fechaFin, datos);
  f.Free;
end;


function TDatosHorariosDetallados.cantDatos: integer;
begin
  Result := Trunc((fechaUltimoDia - fechaPrimerDia) * 24 + 0.1);
end;

function TDatosHorariosDetallados.sumDatos: NReal;
const
  buffsize = 24 * 100;
var
  i, j: integer;
  sum: NReal;
  buff: TDAofNReal;
  dt: TDateTime;
  nDatos: integer;
begin
  nDatos := cantDatos;
  dt := fechaPrimerDia;
  sum := 0;
  if ndatos > buffsize then
  begin
    SetLength(buff, buffsize);
    for i := 1 to cantDatos div buffsize do
    begin
      ReadBuff_horario(buff, dt);
      for j := 0 to high(buff) do
        sum := sum + buff[j];
      dt := dt + Length(buff) div 24;
    end;
  end;
  SetLength(buff, 0);
  SetLength(buff, cantDatos mod buffsize);
  ReadBuff_horario(buff, dt);
  for j := 0 to high(buff) do
    sum := sum + buff[j];
  SetLength(buff, 0);
  Result := sum;
end;

constructor TDatosHorariosDetallados.Create( archiDatos: string; BuscaArchivos: TBuscaArchivos );
var
  nbr: integer;

begin
  inherited Create;
  ArchivoAbierto := False;
  setlength( ci_v, 24 );
  try
    if BuscaArchivos <> nil then
      fdatos:= TFileStream.Create( BuscaArchivos.Locate( archiDatos ), fmOpenRead + fmShareDenyNone )
    else
      fdatos:= TFileStream.Create( archiDatos, fmOpenRead + fmShareDenyNone );
  except
    raise Exception.Create('No pude abrir el archivo de demanda detallada');
  end;

    ArchivoAbierto := True;
    fdatos.Read( FechaPrimerDia, SizeOf(FechaPrimerDia));
    fdatos.Read( FechaUltimoDia, SizeOf(FechaUltimoDia));
    ci_dt1:= fechaPrimerDia;
    ci_dt2:= ci_dt1 + 1.0;
    nbr:= fdatos.Read( ci_v[0], 24*SizeOf(NReal) );
    if nbr <> 24*SizeOf(NReal ) then
    begin
      fdatos.Free;
      fdatos:= nil;
      ArchivoAbierto:= false;
      raise Exception.Create('DatosHorariosDetallados.Create !!! Error. No logre leer ni un dia de datos. Archivo:' + ArchiDatos );
    end;
    fechaProxLectura := ci_dt2;

end;

constructor TDatosHorariosDetallados.CreateForWrite(archiDatos: string);
begin
  inherited Create;
  setlength( ci_v, 24 );
  ArchivoAbierto := False;
  try
    fdatos:= TFileStream.Create( archiDatos, fmOpenWrite + fmCreate );
    ArchivoAbierto := True;
  except
    raise Exception.Create('TDatosHorariosDetalladas.Create !! ERROR: el archivo: ' +
      ArchiDatos + ' no existe o se encuentra en uso.');
  end;
end;

procedure TDatosHorariosDetallados.Free;
begin
  if ArchivoAbierto and (fdatos <> nil ) then
    fdatos.Free;
  setlength( ci_v, 0 );
  inherited Free;
end;

procedure TDatosHorariosDetallados.ReadBuff_horario(var BuffNReal: TDAOfNReal;
  fecha: TDateTime);
var
  ntrd, ntrx: integer;
  npos: integer;
begin
  if fechaProxLectura <> fecha then
  begin
    if fechaProxLectura < fecha then // salto hacia adelante
    begin
      npos := fdatos.Position;
      npos := npos + trunc((fecha - fechaProxLectura) * 24 + 0.1) * SizeOf(NReal);
      fdatos.Seek(npos, 0 );
    end
    else // salto hacia atrás
    begin
      npos := fdatos.Position;
      npos := npos - trunc((fechaProxLectura - fecha) * 24 + 0.1) * SizeOf(NReal);
      fdatos.seek(npos, 0);
    end;
  end;

  ntrd := length(BuffNReal) * SizeOf(NReal);
  ntrx:= fdatos.Read(BUffNReal[0], ntrd);
  if ntrd <> ntrx then
    raise Exception.Create(
      'TDatosHorariosDetallados.ReadBuff: fallo en lectura del archivo de datos. Revise que el rango de fechas sea el deseado.');
  fechaProxLectura := fecha + ((ntrx div SizeOf(NReal)) / 24.0);
  self.ci_dt1:= fecha;
  self.ci_dt2:= fechaProxLectura;
end;

procedure TDatosHorariosDetallados.WriteBuff_horario(fechaIni, fechaFin: TDateTime;
  BuffNReal: TDAofNReal);
var
  AmtTransferred: integer;
begin
  AmtTransferred:= fdatos.Write( fechaIni, SizeOf(TDateTime));
  if AmtTransferred <> SizeOf(TDateTime) then
    raise Exception.Create(
      'No se pudo grabar los datos. Compruebe que el disco no este lleno y vuelva a intentarlo.');
  AmtTransferred:= fdatos.Write(fechaFin, SizeOf(TDateTime) );
  if AmtTransferred <> SizeOf(TDateTime) then
    raise Exception.Create(
      'No se pudo grabar los datos. Compruebe que el disco no este lleno y vuelva a intentarlo.');
  AmtTransferred:= fdatos.Write(BuffNReal[0], Length(BuffNReal)*SizeOf( NReal ));
  if AmtTransferred <> (Length(BuffNReal)* SizeOf( NReal ) ) then
    raise Exception.Create(
      'No se pudo grabar los datos. Compruebe que el disco no este lleno y vuelva a intentarlo.');
end;




end.
