unit uInfoTabs;

interface

uses
  Classes, uBaseEditoresCosasConNombre, uBaseEditoresFichas, ufichasLPD, SysUtils,
  uInfoCosa, xMatDefs;

type

  TFuncionEditar = function(fila: integer; clonar: boolean; lista: TFichasLPD;
    tipoEditor: TClaseEditoresFichas): boolean of object;
  TFuncionEliminar = function(fila: integer; lista: TFichasLPD): boolean of object;

  TInfoCosaConNombre = class
  public
    clase: TClass;
    nombreClase: string;
    ClaseEditor: TClaseEditoresCosasConNombre;
    ClaseEditorFichas: TClaseEditoresFichas;
    nombreTab: string;

    constructor Create(claseActor: TClass; const nombreClase: string;
      claseEditor: TClaseEditoresCosasConNombre;
      ClaseEditorFichas: TClaseEditoresFichas);
  end;

  TInfoTab = class
  public
    nombreTab: string;
    infoCosasConNombre: TList;  //{of TInfoActor}

    constructor Create(const nombreTab: string);
    function ordinalTipoActor(claseActor: TClass): integer;
    function perteneceClase(claseActor: TClass): boolean;
  end;

  TDAOfTClass = array of TClass;

  TInfoTabs = class
  private
    lastClaseOrdinal: TClass;
    lastOrdinal: integer;
    ordinales: TDAOfTClass;

    tabs: TList;   //{of TInfoTab}
    //Retorna todos los TInfoActor de una tab
    function getInfoActoresTab(const nombreTab: string): TList;
  public
    constructor Create();

    //Agrega la información del actor bajo la etiqueta nombreTab, si esta no
    //existe la crea. Retorna la posición en el arreglo de la tab que ocupa el
    //elemento ingresado
    function addInfoActor(infoTab: TInfoCosaConNombre; const nombreTab: string): integer;

    // agrega el TAB con cnombre "nombreTab" y retorna su ordinal.
    function addTab( const nombreTab: string ): integer;

    function getInfoActor(const nombreClase: string): TInfoCosaConNombre; overload;
    function getInfoActor(claseActor: TClass): TInfoCosaConNombre; overload;
    function getInfoActor(const nombreTab: string; claseActor: TClass): TInfoCosaConNombre;
      overload;

    function getInfoActor(const nombreTab: string; const nombreClase: string): TInfoCosaConNombre;
      overload;

    function getTipoEditor(claseActor: TClass;
      const nombreTab: string): TClaseEditoresCosasConNombre;

    function indiceTabDeTipo_(claseActor: TClass): integer;

    //Devuelve la información de actor que se encuentra en la posición i del
    //arreglo de la tab
    function InfoActor(i: integer; const nombreTab: string): TInfoCosaConNombre;

    //devuelve una TList de objetos de tipo TClass con las clases de los actores
    //asociados a la tab
    function tiposTab(const nombreTab: string): TList;

    //Retorna los nombres para desplegar de los tipos de un tab
    function nombresTiposTab(const nombreTab: string): TStringList;
    //Retorna los nombres para desplegar de los tipos de todos los objetos
    //registrados que sean instancias de clase (esto incluye sus derivadas)
    function nombresSubClases(claseBase: TClass): TStringList;

    //Retorna los nombres de todos los tabs presentes
    function tabNames(): TStringList;

    function getNombresTabs: TDAOfString;
    function getInfoTab(const nombreTab: String): TInfoTab;

    procedure crearOrdinales;
    function ordinalTipoActor(claseActor: TClass): integer;
    procedure Free;
  end;

var
  infoTabs_: TInfoTabs;

//Item1 e item2 deben ser objetos
//Devuelve según el orden en que fueron registrados en las tabs
//Si el tipo de item1 fue registrado antes que el de item2 retorna -1,
//si son el mismo tipo retorna 0, si fue registrado después retorna 1
function compareTipos(item1, item2: Pointer): integer;

implementation

function compareTipos(item1, item2: Pointer): integer;
var
  ordinal1, ordinal2: integer;

begin
  ordinal1 := infoTabs_.ordinalTipoActor(TObject(item1).ClassType);
  ordinal2 := infoTabs_.ordinalTipoActor(TObject(item2).ClassType);

  if ordinal1 < ordinal2 then
    Result := -1
  else if ordinal1 = ordinal2 then
    Result := 0
  else
    Result := 1;
end;

{******************************
      Metodos de TInfoActor
*******************************}

constructor TInfoCosaConNombre.Create(claseActor: TClass; const nombreClase: string;
  claseEditor: TClaseEditoresCosasConNombre;
  ClaseEditorFichas: TClaseEditoresFichas);
begin
  self.clase := claseActor;
  self.nombreClase := nombreClase;
  self.ClaseEditor := claseEditor;
  self.ClaseEditorFichas := ClaseEditorFichas;
  Self.nombreTab := nombreTab;
end;

{******************************
      Metodos de TTabInfo
*******************************}

constructor TInfoTab.Create(const nombreTab: string);
begin
  self.nombreTab := nombreTab;
  self.infoCosasConNombre := TList.Create;
end;

function TInfoTab.ordinalTipoActor(claseActor: TClass): integer;
var
  i, res: integer;
begin
  res := infoCosasConNombre.Count;
  for i := 0 to infoCosasConNombre.Count - 1 do
    if TInfoCosaConNombre(infoCosasConNombre[i]).clase = claseActor then
    begin
      res := i;
      break;
    end;
  Result := res;
end;

function TInfoTab.perteneceClase(claseActor: TClass): boolean;
var
  i: integer;
  res: Boolean;
begin
  res := False;
  for i := 0 to infoCosasConNombre.Count - 1 do
    if TInfoCosaConNombre(infoCosasConNombre[i]).clase = claseActor then
    begin
      res := True;
      break;
    end;
  Result := res;
end;

{******************************
      Metodos de TInfoTabs
*******************************}

constructor TInfoTabs.Create();
begin
  inherited Create();
  tabs := TList.Create();
  lastClaseOrdinal := nil;
  ordinales := nil;
end;

function TInfoTabs.getInfoActoresTab(const nombreTab: string): TList;
var
  i, pos: integer;
begin
  pos := -1;
  for i := 0 to Tabs.Count - 1 do
    if TInfoTab(tabs[i]).nombreTab = nombreTab then
    begin
      pos := i;
      break;
    end;
  if pos <> -1 then
    Result := TInfoTab(tabs[pos]).infoCosasConNombre
  else
  begin
    Result := nil;
  end;
end;

procedure TInfoTabs.crearOrdinales;
var
  i, j, acum: integer;
begin
  acum := 0;
  for i := 0 to Tabs.Count - 1 do
    acum := acum + TInfoTab(tabs[i]).infoCosasConNombre.Count;

  SetLength(ordinales, acum);

  acum := 0;
  for i := 0 to Tabs.Count - 1 do
  begin
    for j := 0 to TInfoTab(tabs[i]).infoCosasConNombre.Count - 1 do
      ordinales[acum + j] := TInfoCosaConNombre(TInfoTab(tabs[i]).infoCosasConNombre[j]).clase;
    acum := acum + TInfoTab(tabs[i]).infoCosasConNombre.Count;
  end;
end;

function TInfoTabs.addInfoActor(infoTab: TInfoCosaConNombre; const nombreTab: string): integer;
var
  aux: TList;
  tabAux: TInfoTab;
begin
  aux := getInfoActoresTab(nombreTab);
  if aux <> nil then
    Result := aux.Add(infoTab)
  else
  begin
    tabAux := TInfoTab.Create(nombreTab);
    Tabs.Add(tabAux);
    Result := tabAux.infoCosasConNombre.Add(infoTab);
  end;
end;


function TInfoTabs.addTab( const nombreTab: string ): integer;
var
  tabAux: TInfoTab;
begin
  tabAux := TInfoTab.Create(nombreTab);
  Tabs.Add(tabAux);
  result:= tabs.count - 1;
end;

function TInfoTabs.getInfoActor(const nombreClase: string): TInfoCosaConNombre;
var
  i, j: integer;
  tab: TInfoTab;
  infoActor: TInfoCosaConNombre;
  encontre: boolean;
begin
  encontre := False;
  infoActor := nil;
  for i := 0 to Tabs.Count - 1 do
  begin
    tab := TInfoTab(tabs[i]);
    for j := 0 to tab.infoCosasConNombre.Count - 1 do
    begin
      infoActor := TInfoCosaConNombre(tab.infoCosasConNombre[j]);
      if infoActor.nombreClase = nombreClase then
      begin
        encontre := True;
        break;
      end;
    end;
    if encontre then
      break;
  end;
  if encontre then
    Result := infoActor
  else
    raise Exception.Create('No se encuentra la información para la clase ' +
      nombreClase);
end;

function TInfoTabs.getInfoActor(claseActor: TClass): TInfoCosaConNombre;
var
  i, j: integer;
  tab: TInfoTab;
  infoActor: TInfoCosaConNombre;
  encontre: boolean;
begin
  encontre := False;
  infoActor := nil;

  for i := 0 to Tabs.Count - 1 do
  begin
    tab := TInfoTab(tabs[i]);
    for j := 0 to tab.infoCosasConNombre.Count - 1 do
    begin
      infoActor := TInfoCosaConNombre(tab.infoCosasConNombre[j]);
      //writeln('iteracion: ', j, ' nombreTab: ', infoActor.nombreClase);
      if infoActor.clase = claseActor then
      begin
        encontre := True;
        break;
      end;
    end;
    if encontre then
      break;
  end;
  if encontre then
    Result := infoActor
  else
    result:= nil;
end;

function TInfoTabs.getInfoActor(const nombreTab: string; claseActor: TClass): TInfoCosaConNombre;
var
  aux: TList;
  i, pos: integer;
begin
  aux := getInfoActoresTab(nombreTab);
  if aux <> nil then
  begin
    pos := -1;
    for i := 0 to aux.Count - 1 do
      if TInfoCosaConNombre(aux[i]).clase = claseActor then
      begin
        pos := i;
        break;
      end;
    if pos <> -1 then
      Result := aux[i]
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TInfoTabs.getInfoActor(const nombreTab: string; const nombreClase: string): TInfoCosaConNombre;
var
  aux: TList;
  i, pos: integer;
begin
  aux := getInfoActoresTab(nombreTab);
  if aux <> nil then
  begin
    pos := -1;
    for i := 0 to aux.Count - 1 do
      if TInfoCosaConNombre(aux[i]).nombreClase = nombreClase then
      begin
        pos := i;
        break;
      end;
    if pos <> -1 then
      Result := aux[i]
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TInfoTabs.getNombresTabs: TDAOfString;
var
  res: TDAofString;
  i: Integer;
begin
  SetLength(res, tabs.Count);
  for i := 0 to tabs.Count - 1 do
    res[i] := TInfoTab(tabs[i]).nombreTab;
  result := res;
end;

function TInfoTabs.getInfoTab(const nombreTab: String): TInfoTab;
var
  i: Integer;
begin
  result := NIL;
  for i := 0 to tabs.Count - 1 do
    if TInfoTab(tabs[i]).nombreTab = nombreTab then
    begin
      result := TInfoTab(tabs[i]);
      break;
    end;
end;

function TInfoTabs.getTipoEditor(claseActor: TClass;
  const nombreTab: string): TClaseEditoresCosasConNombre;
var
  aux: TInfoCosaConNombre;
begin
  aux := getInfoActor(nombreTab, claseActor);
  if aux <> nil then
    Result := aux.ClaseEditor
  else
    Result := nil;
end;

function TInfoTabs.indiceTabDeTipo_(claseActor: TClass): integer;
var
  i, j: integer;
  resultado: integer;
begin
  resultado := -1;
  i := 0;
  while (resultado < 0) and (i < Tabs.Count ) do
  begin
    for j := 0 to TInfoTab(tabs[i]).infoCosasConNombre.Count - 1 do
      if TInfoCosaConNombre(TInfoTab(tabs[i]).infoCosasConNombre[j]).clase = claseActor then
      begin
        resultado := i;
        break;
      end;
    inc( i );
  end;

  if resultado < 0 then
   result:= Tabs.Count - 1 // el último Tab es para los Desconocidos
  else
   result:= resultado;
  (**
  if resultado <> -1 then
    Result := Resultado
  else
    raise Exception.Create('TInfoTabs.indiceTabDeTipo: La clase ' +
      claseActor.ClassName + ' no esta registrada en ningun tab');
      **)
end;

function TInfoTabs.InfoActor(i: integer; const nombreTab: string): TInfoCosaConNombre;
var
  aux: TList;
begin
  aux := getInfoActoresTab(nombreTab);
  if aux <> nil then
    Result := aux[i]
  else
    Result := nil;
end;

function TInfoTabs.tiposTab(const nombreTab: string): TList;
var
  resultado: TList;
  aux: TList;
  i: integer;
begin
  aux := getInfoActoresTab(nombreTab);
  if aux <> nil then
  begin
    resultado := TList.Create;
    for i := 0 to aux.Count - 1 do
      resultado.Add(TInfoCosaConNombre(aux[i]).clase);
    Result := resultado;
  end
  else
    Result := nil;
end;

function TInfoTabs.nombresTiposTab(const nombreTab: string): TStringList;
var
  resultado: TStringList;
  aux: TList;
  i: integer;
begin
  aux := getInfoActoresTab(nombreTab);
  if aux <> nil then
  begin
    resultado := TStringList.Create;
    for i := 0 to aux.Count - 1 do
      resultado.Add(TInfoCosaConNombre(aux[i]).nombreClase);
    Result := resultado;
  end
  else
    Result := nil;
end;

function TInfoTabs.nombresSubClases(claseBase: TClass): TStringList;
var
  iTab, jInfoClase: Integer;
  tab: TInfoTab;
  resultado: TStringList;
begin
  resultado := TStringList.Create;
  for iTab := 0 to tabs.Count - 1 do
  begin
    tab := TInfoTab(tabs[iTab]);
    for jInfoClase := 0 to tab.infoCosasConNombre.Count - 1 do
      if TInfoCosaConNombre(tab.infoCosasConNombre[jInfoClase]).clase.InheritsFrom(claseBase) then
         resultado.Add(TInfoCosaConNombre(tab.infoCosasConNombre[jInfoClase]).nombreClase);
  end;
  result := resultado;
end;

function TInfoTabs.tabNames(): TStringList;
var
  resultado: TStringList;
  i: integer;
begin
  resultado := TStringList.Create;
  for i := 0 to Tabs.Count - 1 do
    resultado.Add(TInfoTab(tabs[i]).nombreTab);
  Result := resultado;
end;

function TInfoTabs.ordinalTipoActor(claseActor: TClass): integer;
var
  i, res, aux: integer;
begin
  if claseActor = lastClaseOrdinal then
    Result := lastOrdinal
  else
  begin
    res := -1; //Si no esta en la lista es menor que todos
    for i := 0 to high(ordinales) do
      if ordinales[i] = claseActor then
      begin
        res := i;
        break;
      end;

    if res = -1 then
    begin
      aux := uInfoCosa.ordinalTipoCosa(claseActor);
      if aux <> -1 then
        res := Length(ordinales) + uInfoCosa.ordinalTipoCosa(claseActor);
    end;

    if res <> -1 then
    begin
      lastClaseOrdinal := claseActor;
      lastOrdinal := res;
    end;

    Result := res;
  end;
end;

procedure TInfoTabs.Free;
var
  i: integer;
begin
  for i := 0 to Tabs.Count - 1 do
    TInfoTab(tabs[i]).infoCosasConNombre.Free;
  Tabs.Free;
  if ordinales <> nil then
    SetLength(ordinales, 0);
  inherited Free;
end;

initialization
  infoTabs_ := TInfoTabs.Create();
end.

