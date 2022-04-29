{+doc
+NOMBRE:  TYVS2
+CREACION: 8/97
+MODIFICACION: 9/97
+AUTORES:  Mario Vignolo
+REGISTRO:
+TIPO:  Unidad Pascal
+PROPOSITO:  Variables soporte de FLUCAR
+PROYECTO:   FLUCAR

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}



unit TyVs2;

interface

uses
  Classes,
  uTCompFC,
  AlgebraC, xmatdefs, MatCPX,
  usistema,
  Links,
  Barrs2,
  Impds1,
  Cuadri1,
  horrores,
//  umatrizadmitancias,
  ucpxresolvecuacs;


type

  TSalaFlucar = class

  Barras:     TList;
  BarrasdeCarga: TList;
  BarrasdeGenyVCont: TList;
  BarrasConRegulador: TList;
  BarraFlotante: TBarra;
//  BarrasFlotantes: TList;
  BarrasOrdenadas: TList;
  actores:    TList;
  Cargas:     TList;
  Generadores: TList;
  Lineas:     TList;
  trafosadjust: TList;
  areas:      TList;
  TerminalesDC: TList;
  Shunts:     TList;
  ICTRATables: TList;
  TerminalesDCMult: TList;
  LineasSeccion: TList;
  zonas:      TList;
  trasfareas: TList;
  owners:     TList;
  facts:      TList;
  Impedancias: TList;
  Trafos: TList;
  Reguladores: TList;
  Cuadripolos: TList;
  mAdmitancias: TSistema;
  Tolerancia: NReal;
  MAXNITs: integer;
//  Y:      TMatrizDeAdmitancias;
  nNodos: integer;
  IiConj: TVectComplex;
  p:      TPRoblemaCPX;

  NBarras,
  NBarrasordenadas,
  NBarrasdecarga,
  NBarrasdegenyvcont,
  NImpedancias, NCuadripolosPi, NTrafos, NBarrasconregulador,
  NReguladores: integer;


  // hace Free de los elementos y luego Free de la lista
  procedure liberar(var Lista: TList);

// retorna el índice del nodo dentro del conjunto de barras ordenadas
// buscando por nombre. 'N' es el nombre del NEUTRO = barra 0 (Cero)
// el resto de las barras tienen índice >= 1
  function IndiceDeNodo(var r: string; var rescod: integer): integer;

// Dada una barra a trav‚s de su posici¢n en la lista, devuelve un puntero
//  a la barra
  function BarraPtr(k: integer): TBarra;

  constructor create;
  procedure Free;
end;

implementation

// hace Free de los elementos y luego Free de la lista
procedure TSalaFlucar.liberar(var Lista: TList);
var
  k: integer;
begin
  for k := 0 to lista.Count - 1 do
    if lista[k] <> nil then
      TCompFC(lista[k]).Free;

  lista.Free;
  lista := nil;
end;

function TSalaFlucar.IndiceDeNodo(var r: string; var rescod: integer): integer;
var
  k: integer;
begin
  if r = 'N' then
  begin
    IndiceDeNodo := 0;
    rescod := 0;
  end
  else
  begin
    k := 0; {los ¡ndices en la TCollection comienzan en 0}
    while (k <= NBarras - 1) and (r <> TBarra(BarrasOrdenadas[k]).Nombre) do
      Inc(k);
    if k > NBarras - 1 then
      rescod := -1 {si no encuentra el nombre dado
                          devuelve rescod=-1}
    else
    begin
      rescod := 0;
      IndiceDeNodo := k + 1; {La numeraci¢n que yo elijo es: Neutro del
                    sistema = barra 0; restantes barras numeradas
                    desde 1 en adelante}
    end;
  end;
end;

{Dada una barra a trav‚s de su posici¢n en la lista, devuelve un puntero
a la barra}
function TSalaFlucar.BarraPtr(k: integer): TBarra;
begin
  BarraPtr := Barrasordenadas[k];
end;


constructor TSalaFlucar.Create;
begin  {begin de implementation}
  (*
  Func_IndiceDeNodo := IndiceDeNodo
  Func_BarraPtr := BarraPtr;
  *)
  BarraFlotante := nil;
  Barras      := TList.Create;
  BarrasdeCarga := TList.Create;
  BarrasdeGenyVCont := TList.Create;
  BarrasOrdenadas := TList.Create;
  Impedancias := TList.Create;
  Cuadripolos := TList.Create;
  Trafos      := TList.Create;
  mAdmitancias := nil;
end;

procedure TSalaFlucar.Free;
begin
  liberar( Barras );
  BarrasdeCarga.Free;
  BarrasdeGenyVCont.Free;
  BarrasOrdenadas.Free;
  liberar( Impedancias );
  liberar( Cuadripolos );
  liberar( Trafos );
  if mAdmitancias <> nil then
    mAdmitancias.Free;
end;


end.

