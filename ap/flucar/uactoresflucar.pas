unit uactoresflucar;

interface

uses
  Classes, SysUtils,
  xmatdefs,
  usistema, MatCPX, intlist,
  ucpxresolvecuacs;
//  , umatrizadmitancias;

type

  TSalaFlucar = class;

  TActorFlucar = class
  public
    sala: TSalaFlucar;

    constructor Create(sala: TSalaFlucar); virtual;
    constructor LoadFromText(sala: TSalaFlucar; var f: textfile); virtual;
    procedure resolver_referencias; virtual;

    // carga el actor en el sistema de ecuaciones
    procedure cargue; virtual;

    // retorna TRUE si el actor está conectado al sistema
    function conectada: boolean; virtual;
    function nombre: string; virtual;

    function MatrizAdmitancias: TSistema;
    function SBASE: NReal;

  end;


  TActorDato = class(TActorFlucar)
    //  información adicional -- no son componentes
  end;

  TBarra = class(TActorFlucar)
  public
    TIPO: integer;

    I: longint;   // Bus number (1 through 999997).

    IMP_CERO: boolean;
    BarraExtImpCero: longint;
    PrincipalLinImpCero: boolean;
    // variables auxiliares para la resolución del sistema.
    PL, QL: double;
    QINIT, QMIN, QMAX: double;

  private //lo pongo privado para detectar quíen lo usa
    NID_: longint;
    // Columna-1 de la tensión en la representación matricial del problema Y * V = Ig

  public
    procedure borrar_dem_gen;
    procedure cargue; override;
    function jcol: integer; // (NID_+1)

    // retorna FALSE si la barra es del tipo 4 (aislada)
    // retorna TRUE si la barra está conectada
    function conectada: boolean; override;
    function nombre: string; override;
  end;



  TActorMonoBarra = class(TActorFlucar)
    I: longint; // Bus Number or Extended bus name enclosed  in single quotes.
    Barra_I: TBarra;
    procedure resolver_referencias; override;
    function conectada: boolean; override;
    function nombre: string; override;
  end;


  TActorBiBarra = class(TActorFlucar)
    Barra_I, Barra_J: TBarra;
    I: longint;    // Id barra 1
    J: longint;    // Id barra 2
    IMP_Zero: boolean;

    procedure resolver_referencias; override;
    function conectada: boolean; override;
  end;

  TActorTriBarra = class(TActorFlucar)
    Barra_I, Barra_J, Barra_K: TBarra;
    I: longint;    // Id barra 1
    J: longint;    // Id barra 2
    K: longint;    // Id barra 3
    procedure resolver_referencias; override;
    function conectada: boolean; override;
  end;



  TSalaFlucar = class
    actores: TList; // todos los actores

    TodasLasBarras: TList; // todos las barras del sistemas estén activas o no


    Barras: TList; // barras que participan de la solución del FLujo
    Cargas: TList;
    Generadores: TList;
    Lineas: TList;
    LineasImpCero: TList;
    trafosadjust: TList;
    areas: TList;
    TerminalesDC: TList;
    ShuntsFijos: TList;
    Shunts: TList;
    ICTRATables: TList;
    TerminalesDCMult: TList;
    LineasSeccion: TList;
    zonas: TList;
    trasfareas: TList;
    owners: TList;
    facts: TList;

    //reg:taps;
    nodos_reguladores: TIntList;
    nodos_regulados: TIntList;

    Impedancias: TList;
    Trafos: TList;
    //Reguladores: TList;
    Cuadripolos: TList;
    Tolerancia: NReal;
    MAXNITs: integer;

    SBASE: NReal; // Base del sistema en MVA.
    TapsVariables: boolean;
    MY: TMatrizDeAdmitancias;

    nNodos: integer;
    IiConj: TVectComplex;
    problemaCPX: TPRoblemaCPX;

    constructor Create;
    procedure Free;

    procedure liberar_lstActores(var Lista: TList);

    procedure liberar(var Lista: TIntList);
    procedure ordenar(var Lista: TIntList);
    procedure leer_barras_raw(var f: textfile);
    procedure resolver_referencias;

    // arma el sistema de ecuaciones e inicializa variables auxiliares del cálculo
    procedure cargue;


    //    function I_to_Barra(I: longint): pointer;
    function I_to_TodasLasBarras(Sender: TActorFlucar; I: longint): pointer;
    function I_to_numeroBarra(Sender: TActorFlucar; I: longint): integer;
    function I_to_N_Barras(Sender: TActorFlucar; I: longint): integer;

    function Find_Generador(barra: longint; codigo: string): TActorMonoBarra;
    function Find_Demanda(barra: longint; codigo: string): TActorMonoBarra;
    function Find_Slack: TBarra;
  end;


implementation

uses
  urawdata;

constructor TActorFlucar.Create(sala: TSalaFlucar);
begin
  inherited Create;
  self.sala := sala;
end;

constructor TActorFlucar.LoadFromText(sala: TSalaFlucar; var f: textfile);
begin
  Create(sala);
end;


function TActorFlucar.conectada: boolean;
begin
  Result := False;
end;

function TActorFlucar.nombre: string;
begin
  Result := 'ANONIMO';
end;

procedure TActorFlucar.resolver_referencias;
begin
  // nada
end;

function TActorFlucar.MatrizAdmitancias: TSistema;
begin
  Result := sala.MY;
end;

function TActorFlucar.SBASE: NReal;
begin
  Result := sala.SBASE;
end;




procedure TActorFlucar.cargue;
begin
  // nada
end;

procedure TActorMonoBarra.resolver_referencias;
var
  j: integer;

begin
  Barra_I := sala.I_to_TodasLasBarras(self, I);

  if not Barra_I.IMP_CERO then
    Barra_I := sala.I_to_TodasLasBarras(self, I)
  else
  begin
    self.I := self.Barra_I.BarraExtImpCero;
    Barra_I := sala.I_to_TodasLasBarras(self, self.Barra_I.BarraExtImpCero);
  end;

end;


function TActorMonoBarra.conectada: boolean;
begin
  Result := Barra_I.conectada;
end;

function TActorMonoBarra.nombre: string;
begin
  result:= IntToStr( I );
end;

procedure TActorBiBarra.resolver_referencias;
begin
  Barra_I := sala.I_to_TodasLasBarras(self, I);
  Barra_J := sala.I_to_TodasLasBarras(self, J);

  if self.Barra_I.IMP_CERO then
  begin
    self.I := self.Barra_I.BarraExtImpCero;
    self.Barra_I := sala.I_to_TodasLasBarras(self, self.Barra_I.BarraExtImpCero);
  end;
  if self.Barra_J.IMP_CERO then
  begin
    self.J := self.Barra_J.BarraExtImpCero;
    self.Barra_J := sala.I_to_TodasLasBarras(self, self.Barra_J.BarraExtImpCero);
  end;

end;

function TActorBiBarra.conectada: boolean;
begin
  Result := Barra_I.conectada and Barra_J.conectada;
end;


procedure TActorTriBarra.resolver_referencias;
var
  ext: longint;
begin
  Barra_I := sala.I_to_TodasLasBarras(self, I);
  Barra_J := sala.I_to_TodasLasBarras(self, J);
  Barra_K := sala.I_to_TodasLasBarras(self, K);
  ext := Barra_I.BarraExtImpCero;
  if self.Barra_I.IMP_CERO then
  begin
    self.I := ext;
    self.Barra_I := sala.I_to_TodasLasBarras(self, self.Barra_I.BarraExtImpCero);
  end;

  ext := Barra_J.BarraExtImpCero;
  if self.Barra_J.IMP_CERO then
  begin
    self.J := ext;
    self.Barra_J := sala.I_to_TodasLasBarras(self, self.Barra_J.BarraExtImpCero);
  end;

end;


function TActorTriBarra.conectada: boolean;
begin
  if Barra_K = nil then
    Result := Barra_I.conectada and Barra_J.conectada
  else
    Result := Barra_I.conectada and Barra_J.conectada and Barra_K.conectada;
end;


procedure TBarra.cargue;
begin
  PL := 0;
  QL := 0;
  QINIT := 0;
  QMAX := 0;
  QMIN := 0;
  IMP_CERO := False;
  BarraExtImpCero := -1;
  PrincipalLinImpCero := False;

end;

procedure TBarra.borrar_dem_gen;
begin
  PL := 0;
  QL := 0;
end;

function TBarra.jcol: integer; // (NID_+1)
begin
  Result := NID_ + 1;
end;


function TBarra.Conectada: boolean;
var
  i: integer;
begin
  Result := (TIPO <> 4) and not (IMP_CERO);
end;


function TBarra.nombre: string;
begin
  Result := IntToStr(I);
end;

// hace Free de los elementos y luego Free de la lista
procedure TSalaFlucar.liberar_lstActores(var Lista: TList);
var
  k: integer;
begin
  for k := 0 to lista.Count - 1 do
    if lista[k] <> nil then
      TActorFlucar(lista[k]).Free;
  lista.Free;
  lista := nil;
end;

procedure TSalaFlucar.liberar(var Lista: TIntList);
var
  k: integer;
begin
  Lista.Destroy;
end;


procedure TSalaFlucar.resolver_referencias;
var
  k: integer;
  a: TActorFlucar;
begin
  for k := 0 to actores.Count - 1 do
  begin
    a := actores[k];
    a.resolver_referencias;
  end;
end;


procedure TSalaFlucar.cargue;
var
  Barra: TBarra;
  k: integer;

begin
  resolver_referencias;

  barras.Clear; // limpio las lista de las barras que participan
  for k := 0 to TodasLasBarras.Count - 1 do
  begin
    barra := TodasLasBarras[k];
    if (barra.tipo <> 4) and not (barra.IMP_CERO) then
    begin
      barra.NID_ := barras.Count;
      barras.add(barra);
    end
    else
      barra.NID_ := -1;
  end;

  nNodos := barras.Count;
  if MY <> nil then
    MY.Free_destruirsistema;
  MY := TSistema.Create_crearsistema(barras.Count);

  for k := 0 to barras.Count - 1 do
  begin
    barra := barras[k];
    barra.cargue;
  end;
  if IiConj= nil then
             IiConj := TVectComplex.Create_Init(nNodos);

end;



procedure TSalaFlucar.ordenar(var Lista: TIntList);
begin

end;


procedure TSalaFlucar.leer_barras_raw(var f: textfile);
begin
  urawdata.leer_barras_raw(self, f);
end;

constructor TSalaFlucar.Create;
begin
  inherited Create;

  actores := TList.Create;

  TodasLasBarras := TList.Create;
  Barras := TList.Create;



  Impedancias := TList.Create;
  Cuadripolos := TList.Create;
  generadores := TList.Create;
  Cargas := TList.Create;
  Trafos := TList.Create;
  lineas := TList.Create;
  LineasImpCero := TList.Create;
  Shunts := TList.Create;
  ShuntsFijos := TList.Create;

  nodos_reguladores := TIntList.CreateEx();
  nodos_regulados := TIntList.CreateEx();
  MY := nil;
  ProblemaCPX := nil;
end;

procedure TSalaFlucar.Free;
begin
  if MY <> nil then
    MY.Free_destruirsistema;
  if ProblemaCPX <> nil then
    ProblemaCPX.Free;
  IiConj.Free;

  liberar_lstActores(Actores);

  TodasLasBarras.Free;
  Barras.Free;
  Impedancias.Free;
  Cuadripolos.Free;
  Trafos.Free;
  Generadores.Free;
  Cargas.Free;
  Lineas.Free;
  LineasImpCero.Free;
  Shunts.Free;
  ShuntsFijos.Free;

  liberar(nodos_reguladores);
  liberar(nodos_regulados);
  inherited Free;
end;

function TSalaFlucar.I_to_TodasLasBarras(Sender: TActorFlucar; I: longint): pointer;
var
  k: integer;
  barra: TRaw_Bus;
  buscando: boolean;
begin

  buscando := True;
  k := 0;
  while buscando and (k < TodasLasBarras.Count) do
  begin
    barra := TodasLasBarras[k];
    if barra.I = I then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
  begin
    if I <> 0 then
    begin
      if Sender <> nil then
        raise Exception.Create('I_To_TodasLasBarras; Actor:' +
          Sender.ClassName + '; Nombre: ' + Sender.nombre + '; I:' + IntToStr(
          I) + ' (Barra no encontrada) ')
      else
        raise Exception.Create('I_To_TodasLasBarras; Actor: NIL; I:' + IntToStr(
          I) + ' (Barra no encontrada) ');
    end;
    Result := nil;
  end
  else
    Result := barra;
end;

function TSalaFlucar.I_to_numeroBarra(Sender: TActorFlucar; I: longint): integer;
var
  k: integer;
  barra: TRaw_Bus;
  buscando: boolean;
begin

  buscando := True;
  k := 0;
  while buscando and (k < TodasLasBarras.Count) do
  begin
    barra := TodasLasBarras[k];
    if barra.I = I then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
  begin
    if I <> 0 then
    begin
      if Sender <> nil then
        raise Exception.Create('I_To_TodasLasBarras; Actor:' +
          Sender.ClassName + '; Nombre: ' + Sender.nombre + '; I:' + IntToStr(
          I) + ' (Barra no encontrada) ')
      else
        raise Exception.Create('I_To_TodasLasBarras; Actor: NIL; I:' + IntToStr(
          I) + ' (Barra no encontrada) ');
    end;
    Result := -1;
  end
  else
    Result := k + 1;
end;

function TSalaFlucar.I_to_N_Barras(Sender: TActorFlucar; I: longint): integer;
var
  k: integer;
  barra: TRaw_Bus;
  buscando: boolean;
begin
  buscando := True;
  k := 0;

  while buscando and (k < Barras.Count) do
  begin
    barra := Barras[k];
    if (barra.I = I) or (barra.BarraExtImpCero = I) then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
  begin
    if I <> 0 then
    begin
      if Sender <> nil then
        raise Exception.Create('I_to_N_Barras; Actor:' + Sender.ClassName +
          '; Nombre: ' + Sender.nombre + '; I:' + IntToStr(I) + ' (Barra no encontrada) ')
      else
        raise Exception.Create('I_to_N_Barras; Actor: NIL; I:' + IntToStr(
          I) + ' (Barra no encontrada) ');
    end;
    Result := -1;
  end
  else
    Result := k + 1;
end;

function TSalaFlucar.Find_Generador(barra: longint; codigo: string): TActorMonoBarra;
var
  a: TRaw_Generator;
  buscando: boolean;
  k: integer;
  barraaux:TRaw_Bus;
begin
  buscando := True;
  k := 0;

  barraaux:= I_to_TodasLasBarras(nil, barra);
  if barraaux.IMP_CERO then
     barra:=barraaux.BarraExtImpCero;

  while (buscando and (k < self.Generadores.Count)) do
  begin
    a := generadores[k];
    if (a.I = barra) and (a.ID = codigo) then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
    Result := nil
  else
    Result := a;
end;

function TSalaFlucar.Find_Slack: TBarra;
var
  a: TRaw_Bus;
  buscando: boolean;
  k: integer;

begin
  buscando := True;
  k := 0;

  while (buscando and (k < self.TodasLasBarras.Count)) do
  begin
    a := TodasLasBarras[k];

    if (a.IDE = 3) then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
    Result := nil
  else
    Result := a;
end;

function TSalaFlucar.Find_Demanda(barra: longint; codigo: string): TActorMonoBarra;
var
  a: TRaw_Load;
  buscando: boolean;
  k: integer;
  barraaux:TRaw_Bus;
begin
  buscando := True;
  k := 0;
  barraaux:= I_to_TodasLasBarras(nil, barra);
  if barraaux.IMP_CERO then
     barra:=barraaux.BarraExtImpCero;



  while (buscando and (k < Cargas.Count)) do
  begin
    a := Cargas[k];
    if (a.I = barra) and (a.ID = codigo) then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
    Result := nil
  else
    Result := a;
end;

end.
