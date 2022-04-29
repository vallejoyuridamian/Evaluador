unit uactualizadorlpd;

  {$MODE Delphi}


interface

uses
  Classes, SysUtils, ufechas, ufichasLPD;

type

  { TFichaActualizar }

  TFichaActualizar = class
    fecha: TFecha;
    capa: integer;
    ificha: integer;
    lst_fichas: TFichasLPD;
    constructor Create(fecha: TFecha; capa: integer; ificha: integer;
      lst_fichas: TFichasLPD);

    // Resumen imprimible para logs
    function AsString: string;
  end;



  { TActualizadorFichasLPD }

  TActualizadorFichasLPD = class(TList)
  private
    ipos: integer; // tiene la posición de la última ficha actualizada
    uFecha: TFecha; // ultima fecha de ficha usada para actualizar
    SentidoDirecto: boolean; // TRUE si el tiempo va avanzando, FALSE si va retrocediendo
    ListasLPD: TList; // lista de las listas LPD

    idHilo: integer;
{$IFDEF DEBUG_MH}
    flogmh: textfile;
{$ENDIF}

  public
    constructor Create( idHilo: integer );
    procedure Free;

    // cada Actor debe llamar este procedimiento pasándo com parámetro
    // la lista de parámetros dinámicos para que puedan ser actualizadas
    procedure agregarListaDeFichas(fichasLPD: TFichasLPD);

    // Luego de cargar todas las listas de parámetros dinámicos hay que llamar
    // una vez este preocedimiento para que el Actualizador ordene todas las
    // fichas registradas y pueda procesar con eficiencia los Tics
    procedure SortByFechaYCapa;

    // Esta funcion debe ser llamada una vez luego de cargado el escenario y
    // antes de llamar PrepararSim. En esta se ordena el conjunto de fichas
    // deparámetros dinámicos en orden creciente de tiempo.
    procedure Preparse(xSentidoDirecto: boolean; FechaInicial, FechaFinal: TFecha);

    // Hay que llamar esta función al inicio de cada simulación para que se
    // reinicialize el Actualizador. .
    procedure PrepararOptSim(FechaInicial, FechaFinal: TFecha);

    // actualiza sólo en sentido directo del tiempo. Es usado por
    // ActualizarFichasHasta.
    procedure ActualizarFichasHastaDirecto(fecha: TFecha);

    // En cada paso de tiempo llamamos este procedimiento para que el
    // Actualizador lleve a cabo la actualización de todos los parámetros dinámicos
    // que corresponda.
    procedure ActualizarFichasHasta(fecha: TFecha);

    function ProximaFichaDirecto: TFichaActualizar;
    //    function ProximaFicha: TFichaActualizar;


    function chequeoFechas(fechaIni, fechaFin: TFecha): boolean;
    //Devuelve true <=> todas los pA de todas las listasLPD son anteriores a la fecha
    //de inicio de la simulación y todos los pB de todas las listasLPD son posteriores
    //a la fecha de fin de la simulacion (o vacios)

    procedure Limpiar;
    //Libera la memoria de las TFichaActualizar en el actualizador y fija el count en 0

    // procedimiento para debug
    procedure DumpListaToArchi(archi: string);


    // Para debug MultiHilo
    procedure logmh( s: string );
  end;

implementation

uses
  uunidades;

constructor TFichaActualizar.Create(fecha: TFecha; capa: integer;
  ificha: integer; lst_fichas: TFichasLPD);
begin
  inherited Create;
  Self.fecha := fecha;
  self.capa := capa;
  Self.ificha := ificha;
  Self.lst_fichas := lst_fichas;
end;

function TFichaActualizar.AsString: string;
begin
  result:= 'Fecha: '+Fecha.AsISOStr+', capa: '+IntToStr( capa )+', ificha: '+IntToStr( ificha );
end;

constructor TActualizadorFichasLPD.Create(idHilo: integer);
begin
  inherited Create;
  ListasLPD := TList.Create;
  self.idHilo:= idHilo;
  {$IFDEF DEBUG_MH}
  assignfile( flogmh, 'c:\basura\actualizador_logmh_'+IntToStr(idHilo )+'.txt' );
  rewrite( flogmh )
  {$ENDIF}
end;


procedure TActualizadorFichasLPD.Free;
begin
  {$IFDEF DEBUG_MH}
  closefile( flogmh );
  {$ENDIF}
  //Las listas dentro de ListasLPD las libera cada actor, pero ListasLPD se libera acá
  ListasLPD.Free;
  inherited Free;
end;

procedure TActualizadorFichasLPD.DumpListaToArchi(archi: string);
var
  f: textfile;
  af: TFichaActualizar;
  I: integer;

  aCajonera: TFichasLPD;
  aFicha: TFichaLPD;

begin
  assignfile(f, archi);
  rewrite(f);

  for I := 0 to Count - 1 do
  begin
    af := Items[I];
    aCajonera := af.lst_fichas;
    aFicha := aCajonera[af.ificha];

    system.Write(f, af.fecha.AsStr, #9, af.ificha, #9,
      aCajonera.Propietario.Nombre);
    if aFicha is TFichaUnidades then
    begin
      system.Write(f, #9, TFichaUnidades(aFicha).GetUnidadesOperativas(0));
    end;
    system.writeln(f);
  end;
  closeFile(f);
end;

procedure TActualizadorFichasLPD.logmh(s: string);
begin
  {$IFDEF DEBUG_MH}
  writeln( flogmh, s );
  {$ENDIF}
end;


procedure TActualizadorFichasLPD.agregarListaDeFichas(fichasLPD: TFichasLPD);
var
  k: integer;
  ficha: TFichaActualizar;
  a: TFichaLPD;
begin
  for k := 0 to fichasLPD.Count - 1 do
  begin
    a := TFichaLPD(fichasLPD.items[k]);
    if a.activa then
    begin
      ficha := TFichaActualizar.Create(a.Fecha, a.Capa, k, fichasLPD);
      add(ficha);
    end;
  end;
  ListasLPD.Add(fichasLPD);
end;

procedure TActualizadorFichasLPD.Preparse(xSentidoDirecto: boolean;
  FechaInicial, FechaFinal: TFecha);
{$IFDEF DEBUG_ACTUALIZADOR}
var
  k: integer;
{$ENDIF}
begin
  SentidoDirecto := xSentidoDirecto;

  SortByFechaYCapa;

{$IFDEF DEBUG_ACTUALIZADOR}
  system.writeln('Cantidad de fichas en ACTUALIZADOR: ', Count);
  for k := 0 to Count - 1 do
    system.writeln(k, ' ', TFichaActualizar(items[k]).fecha.DateToStr);
{$ENDIF}
end;

procedure TActualizadorFichasLPD.PrepararOptSim(FechaInicial, FechaFinal: TFecha);
var
  k: integer;
begin
  if Count > 0 then
    if sentidoDirecto then
    begin
      ipos := -1;
      Self.uFecha := nil;

      // rch-090221- me queda duda de si esto era necesario pero lo agrego
      // también me queda duda de porqué en la optimización esto está puesto
      // después de ActulaizarFcihasHasta -
      // y en ambos casos para mi sobra el ActualizarFichasHasta
      for k := 0 to ListasLPD.Count - 1 do
        TFichasLPD(ListasLPD.items[k]).Prepararse(FechaFinal);

      ActualizarFichasHasta(fechaInicial);
    end
    else
    begin
      ipos := Count;
      Self.uFecha := nil;
      ActualizarFichasHasta(fechaFinal);

      for k := 0 to ListasLPD.Count - 1 do
        TFichasLPD(ListasLPD.items[k]).Prepararse(FechaFinal);
    end;
end;

procedure TActualizadorFichasLPD.ActualizarFichasHastaDirecto(fecha: TFecha);
var
  pf: TFichaActualizar;
  actualizando: boolean;
begin

logmh( 'ActualizarHasta: '+ fecha.AsISOStr );
  { En el sentido directo del tiempo, vamos activando las fichas que
  son superadas por fecha }
  if (ufecha = nil) or (fecha.EsMayorQue(ufecha) > 0) then
  begin
    actualizando := True;
    pf := ProximaFichaDirecto;
    while actualizando and (pf <> nil) do
    begin
      if pf.fecha.EsMayorQue(fecha) <= 0 then
      begin
 logmh( pf.AsString );
        ufecha := pf.fecha;
        Inc(ipos);
        TFichasLPD(pf.lst_fichas).cambiarFicha(pf.ificha);
        pf := ProximaFichaDirecto;
      end
      else
        actualizando := False;
    end;
  end;
end;

procedure TActualizadorFichasLPD.ActualizarFichasHasta(fecha: TFecha);
begin
  if Count > 0 then
  begin
    if SentidoDirecto then
    begin
      ActualizarFichasHastaDirecto(fecha);
    end
    else
    begin
      if (ufecha = nil) or (fecha.EsMayorQue(ufecha) < 0) then
      begin
        ufecha := nil;
        // rch&ps@201510011227 BUGFIX -> v124
        // Aca estaba asignado a CERO lo que hacía que la ficha en el casillero CERO
        // Nunca fuera devuelta en ProximaFichaDirecto
        ipos := -1;
        ActualizarFichasHastaDirecto(fecha);
      end;
    end;
  end;
end;

function FichasActualizar_compareFechaYCapa(ficha1, ficha2: pointer): integer;
var
  res: integer;
begin
  res := TFichaActualizar(ficha1).fecha.EsMayorQue(TFichaActualizar(ficha2).fecha);
  if res = 0 then
    if TFichaActualizar(ficha1).capa < TFichaActualizar(ficha2).capa then
      res := -1
    else if TFichaActualizar(ficha1).capa = TFichaActualizar(ficha2).capa then
      res := 0
    else
      res := 1;
  Result := res;
end;

procedure TActualizadorFichasLPD.SortByFechaYCapa;
begin
  Sort(FichasActualizar_CompareFechaYCapa);
end;

function TActualizadorFichasLPD.ProximaFichaDirecto: TFichaActualizar;
begin
  if ipos >= (Count - 1) then
    Result := nil // no hay más fichas
  else
    Result := TFichaActualizar(items[ipos + 1]);
end;

(*
function TActualizadorFichasLPD.ProximaFicha: TFichaActualizar;
begin
  if SentidoDirecto  then
      result:= ProximaFichaDirecto
  else
    if ipos <= 0  then
      result:= nil // no hay más fichas
    else
      result:= TFichaActualizar( items[ipos-1] );
end;
*)

function TActualizadorFichasLPD.chequeoFechas(fechaIni, fechaFin: TFecha): boolean;
var
  i: integer;
  res: boolean;
begin
  res := True;
  i := 0;
  while (i < ListasLPD.Count) and res do
  begin
    res := TFichasLPD(ListasLPD.items[i]).chequeoFechas(fechaIni, fechaFin);
    Inc(i);
  end;
  Result := res;
end;

procedure TActualizadorFichasLPD.Limpiar;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    TFichaActualizar(items[i]).Free;
  self.ListasLPD.Clear;
  self.Clear;
end;

end.
