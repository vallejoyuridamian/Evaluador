unit uCosaConNombre;
{$MODE Delphi}

interface

uses
  ucosa, xMatDefs, uFechas, Classes, SysUtils, uVarDefs;

type
  PCosaConNombre = ^TCosaConNombre;
  TClaseDeCosaConNombre = class of TCosaConNombre;

  { TCosaConNombre }

  TCosaConNombre = class(TCosa)
  public
    nombre: string;
    pubvarlst: TListaVarDefs; // lista de variables pinchables

    constructor Create(capa: integer; const nombre: string); virtual;

    function Rec: TCosa_RecLnk; override;

    function Create_Clone(CatalogoReferencias: TCatalogo;
      idHilo: integer): TCosa; override;
    procedure Free; override;

    // retorna el nombre.
    function Apodo: string; override;

    // Retorna un entero que codifica el Nombre de la clase
    // y el nombre del objeto. Esta función es usada en la fijación
    // del código que utiliza el sorteador uniforme del actor.
    function get_hash_nombre: integer;

    //Retorna "clase, nombre" de la cosa seleccionada
    function ClaseNombre: string;

    class function DescClase: string; override;

    function buscarVariable(const xnombreVar: string): TVarDef; overload;
    function buscarVariable(const xnombreVar: string; var varDef: TVarDef): boolean;
      overload;

    procedure PublicarVariableS(const xnombre, xunidades: string; var xvar: string);
    procedure PublicarVariableNR(const xnombre, xunidades: string;
      precision, decimales: integer; var xvar: NReal);
    procedure PublicarVariableNI(const xnombre, xunidades: string; var xvar: integer);
    procedure PublicarVariableB(const xnombre, xunidades: string; var xvar: boolean);
    procedure PublicarVariableFecha(const xnombre: string; var xvar: TFecha);

    procedure PublicarVariableVR(const xnombre, xunidades: string;
      precision, decimales: integer; var xvar: TDAOfNReal;
      usarNomenclaturaConPostes: boolean);
    procedure PublicarVariableVI(const xnombre, xunidades: string;
      var xvar: TDAOfNInt; usarNomenclaturaConPostes: boolean);
    procedure PublicarVariableVB(const xnombre, xunidades: string;
      var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean);

    procedure PublicarVariablePS(const xnombre, xunidades: string;
      var pd; var xvar: string);

    procedure PublicarVariablePNR(const xnombre, xunidades: string;
      precision, decimales: integer; var pd; var xvar: NReal); overload;
    procedure PublicarVariablePNI(const xnombre, xunidades: string;
      var pd; var xvar: integer); overload;
    procedure PublicarVariablePB(const xnombre, xunidades: string;
      var pd; var xvar: boolean); overload;

    //Publican las variables igual que arriba pero permiten especificar que son parte de un
    //arreglo y su indice en el arreglo
    procedure PublicarVariablePNR(const xnombre, xunidades: string;
      precision, decimales: integer; var pd; var xvar: NReal;
      posteVar: integer); overload;
    procedure PublicarVariablePNI(const xnombre, xunidades: string;
      var pd; var xvar: integer; posteVar: integer); overload;
    procedure PublicarVariablePB(const xnombre, xunidades: string;
      var pd; var xvar: boolean; posteVar: integer); overload;

    procedure PublicarVariablePFecha(const xnombre: string; var pd; var xvar: TFecha);

    procedure PublicarVariablePVNR(const xnombre, xunidades: string;
      precision, decimales: integer; var pd; var xvar: TDAofNReal;
      usarNomenclaturaConPostes: boolean);
    procedure PublicarVariablePVNI(const xnombre, xunidades: string;
      var pd; var xvar: TDAofNInt; usarNomenclaturaConPostes: boolean);
    procedure PublicarVariablePVB(const xnombre, xunidades: string;
      var pd; var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean);


    // retorna la lista de variables publicadas
    function getNombresPublicados: TStrings;

    procedure PubliVars; virtual;
    procedure CambioFichaPD; virtual;

    {$IFDEF opt_Dump_PubliVars}
    procedure printPubliVars(var f: TextFile);
    {$ENDIF}

    // ejecuta una sentecia y retorna el resultado en formato string.
    // La primer linea del resultado es +ERROR o +OK
    // El resto de las líneas son información.
    function EjecutarSentencia(orden: string;
      parametros: TStringList): TStringList; virtual;
    {$IFDEF BOSTA}
    procedure AfterInstantiation; override;
   {$ENDIF}
  end;


  { TListaDeCosasConNombre }

  TListaDeCosasConNombre = class(TListaDeCosas)
  protected
    function getItem(i: integer): TCosaConNombre;
    procedure setItem(i: integer; cosa: TCosaConNombre);
  public
    nombre: string;
    constructor Create(capa: integer; nombre: string);

    constructor Create_ReadFromText(f: TArchiTexto); override;
    procedure WriteToText_(f: TArchiTexto); override;

    function Add(cosa: TCosaConNombre): integer; reintroduce;
    procedure insert(indice: integer; cosa: TCosaConNombre); reintroduce;
    function Remove(cosa: TCosaConNombre): integer; reintroduce;
    function nombresCosas: TStringList;
    //      procedure Delete(indice: Integer); reintroduce;

    function getNextId(clase: TClaseDeCosaConNombre): string;
    function listaDeCosasDeClase(clases: TList): TListaDeCosasConNombre;

    function find(const nombre: string): TCosaConNombre; overload;
    function find(const clase, nombre: string): TCosaConNombre; overload;
    function find(const nombre: string; var ipos: integer): boolean; overload;
    function find(const clase, nombre: string; var ipos: integer): boolean; overload;

    property items[i: integer]: TCosaConNombre read getItem write setItem; default;

  end;

  //Es igual que TListaDeCosasConNombre pero se guarda con
  //referencias a cosas, asi cuando se carga apunta directamente
  //a ellas y no crea nuevas instancias del objeto guardado

  { TListaDeReferenciasACosas }

  TListaDeReferenciasACosas = class(TCosa)
  public
    n: integer;
    lst: TList;

    constructor Create(capa: integer); override;

    constructor Create_ReadFromText(f: TArchiTexto); override;
    procedure WriteToText_(f: TArchiTexto); override;

    function Addx(cosa: TCosaConNombre): integer; reintroduce;
    function find(const nombre: string; var ipos: integer): boolean; overload;
    function find(const clase, nombre: string; var ipos: integer): boolean; overload;

  end;


  { TCatalogoReferencias }

  TCatalogoReferencias = class(TCatalogo)
    referencias: TList;

    procedure registrar_referencia(referente: TCosa;
      claseDelreferido, nombreDelReferido: string; var referencia);

    function obtenerReferencia(claseDelreferido, nombreDelReferido: string;
      var referencia: PCosaConNombre): boolean;

    // Hace un DUMP de las referencias para debug
    procedure DumpReferencias(archi: string);

    function existeReferencia_al(referido: TCosaConNombre): boolean;

    function existeReferencia_del(referente: TCosa; referido: TCosaConNombre): boolean;

    // resuelve las referencias contra la lista CosasLst y retorna la
    // cantidad de referencias que quedan sin resolver (por si es necesario pasar otra lista)
    function resolver_referencias(CosasLst: TListaDeCosasConNombre): integer;

    // resuelve las referencias que haya contra la lista CosasLst de para el referente indicado
    // retorna la cantidad de referencias anotadas con el (referente) que no han podido resolverse
    function resolver_referenciasDeCosa(referente: TCosa;
      CosasLst: TListaDeCosasConNombre): integer;
    //Cambia todas las referencias registradas a ref_Anterior por ref_Nueva, devuelve
    //el numero de referencias cambiadas
    function cambiar_referencias_al(ref_Anterior, ref_Nueva: TCosaConNombre): integer;
    //Cambia todas las referencias registradas a ref_Anterior por ref_Nueva, que
    //sean de referente devuelve el numero de referencias cambiadas
    function cambiar_referencias_del_al(referente: TCosa;
      ref_Anterior, ref_Nueva: TCosaConNombre): integer;

    //Cambia el nombre del referido en las referencias que esten luego de la posicion k en la lista y que tengan nombre nombre_Anterior por nombre_Nuevo
    function cambiar_NombreDelReferidoEnReferenciasPosterioresAK(k: integer;
      nombre_Anterior, nombre_Nuevo, claseReferido: string): integer;

    //Elimina las referencias del referente
    function eliminar_referencias_del(referente: TCosa): integer;

    //Retorna la cantidad de referencias pendientes a ser resueltas
    function referenciasSinResolver: integer;

    // imprime a consola las referencias sin resolver.
    procedure WriteLNReferencias;

    procedure LimpiarReferencias;


    constructor Create;
    procedure Free;
  end;


//type TListSortCompare = function (Item1, Item2: Pointer): Integer;

//Retorna -1 si item1 < item2, 0 si son iguales y 1 si item1 > item2
function ordenString(Item1, Item2: Pointer): integer;

procedure AlInicio;
procedure AlFinal;

//Extraen la clase o el nombre del string obtenido en claseNombre
function ParseNombre(const claseNombre: string): string;
function ParseClase(const claseNombre: string): string;


type

  { TFichaReferencia }

  TFichaReferencia = class
    referente: TCosa;
    referido_clase, referido_nombre: string;
    referencia: PCosaConNombre;
    constructor Create(referente: TCosa; referencia: PCosaConNombre;
      referido_clase, referido_nombre: string);
    procedure Free;
  end;


implementation

//--------------------------
// Métodos de TCosaConNombre
//==========================
function TCosaConNombre.buscarVariable(const xnombreVar: string): TVarDef;
var
  resultado: TVarDef;
  i: integer;
begin
  resultado := nil;
  for i := 0 to pubvarlst.Count - 1 do
    if TVarDef(pubvarlst[i]).nombreVar = xnombreVar then
    begin
      resultado := pubvarlst[i];
      break;
    end;
  Result := resultado;
end;

function TCosaConNombre.buscarVariable(const xnombreVar: string;
  var varDef: TVarDef): boolean;
var
  i: integer;
begin
  varDef := nil;
  for i := 0 to pubvarlst.Count - 1 do
    if TVarDef(pubvarlst[i]).nombreVar = xnombreVar then
    begin
      varDef := pubvarlst[i];
      break;
    end;
  Result := varDef <> nil;
end;

procedure TCosaConNombre.PublicarVariableS(const xnombre, xunidades: string;
  var xvar: string);
var
  fv: TVarDef_S;
begin
  fv := TVarDef_S.Create(self, xnombre, xunidades, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariableNR(const xnombre, xunidades: string;
  precision, decimales: integer; var xvar: NReal);
var
  fv: TVarDef_NR;
begin
  fv := TVarDef_NR.Create(self, xnombre, xunidades, precision, decimales, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariableNI(const xnombre, xunidades: string;
  var xvar: integer);
var
  fv: TVarDef_NI;
begin
  fv := TVarDef_NI.Create(self, xnombre, xunidades, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariableB(const xnombre, xunidades: string;
  var xvar: boolean);
var
  fv: TVarDef;
begin
  fv := TVarDef_B.Create(self, xnombre, xunidades, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariableFecha(const xnombre: string; var xvar: TFecha);
var
  fv: TVarDef;
begin
  fv := TVarDef_Fecha.Create(self, xnombre, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariableVR(const xnombre, xunidades: string;
  precision, decimales: integer; var xvar: TDAOfNReal;
  usarNomenclaturaConPostes: boolean);
var
  fv: TVarDef_VNR;
  i: integer;
begin
  if length(xvar) > 0 then
  begin
    fv := TVarDef_VNR.Create(self, xnombre, xunidades, precision,
      decimales, @xvar, usarNomenclaturaConPostes);
    self.pubvarlst.Add(fv);

    if usarNomenclaturaConPostes then
      for i := 0 to high(xvar) do
        self.PublicarVariablePNR(xnombre + '_P' + IntToStr(i + 1),
          xunidades, precision, decimales, xvar, xvar[i], i + 1)
    else
      for i := 0 to high(xvar) do
        self.PublicarVariablePNR(xnombre + '[' + IntToStr(i + 1) +
          ']', xunidades, precision, decimales, xvar, xvar[i]);
  end;
end;

procedure TCosaConNombre.PublicarVariableVI(const xnombre, xunidades: string;
  var xvar: TDAOfNInt; usarNomenclaturaConPostes: boolean);
var
  fv: TVarDef_VNI;
  i: integer;
begin
  if length(xvar) > 0 then
  begin
    fv := TVarDef_VNI.Create(self, xnombre, xunidades, @xvar, usarNomenclaturaConPostes);
    self.pubvarlst.Add(fv);

    if usarNomenclaturaConPostes then
      for i := 0 to high(xvar) do
        self.PublicarVariablePNI(xnombre + '_P' + IntToStr(i + 1),
          xunidades, xvar, xvar[i], i + 1)
    else
      for i := 0 to high(xvar) do
        self.PublicarVariablePNI(xnombre + '[' + IntToStr(i + 1) +
          ']', xunidades, xvar, xvar[i]);
  end;
end;

procedure TCosaConNombre.PublicarVariableVB(const xnombre, xunidades: string;
  var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean);
var
  fv: TVarDef_VB;
  i: integer;
begin
  if length(xvar) > 0 then
  begin
    fv := TVarDef_VB.Create(self, xnombre, xunidades, @xvar, usarNomenclaturaConPostes);
    self.pubvarlst.Add(fv);

    if usarNomenclaturaConPostes then
      for i := 0 to high(xvar) do
        self.PublicarVariablePB(xnombre + '_P' + IntToStr(i + 1),
          xunidades, xvar, xvar[i], i + 1)
    else
      for i := 0 to high(xvar) do
        self.PublicarVariablePB(xnombre + '[' + IntToStr(i + 1) + ']',
          xunidades, xvar, xvar[i]);
  end;
end;

procedure TCosaConNombre.PublicarVariablePS(const xnombre, xunidades: string;
  var pd; var xvar: string);
var
  fv: TVarDef_PS;
begin
  fv := TVarDef_PS.Create(self, xnombre, xunidades, @pd, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariablePNR(const xnombre, xunidades: string;
  precision, decimales: integer; var pd; var xvar: NReal);
var
  fv: TVarDef_PNR;
begin
  fv := TVarDef_PNR.Create(self, xnombre, xunidades, precision, decimales, @pd, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariablePNI(const xnombre, xunidades: string;
  var pd; var xvar: integer);
var
  fv: TVarDef_PNI;
begin
  fv := TVarDef_PNI.Create(self, xnombre, xunidades, @pd, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariablePB(const xnombre, xunidades: string;
  var pd; var xvar: boolean);
var
  fv: TVarDef_PB;
begin
  fv := TVarDef_PB.Create(self, xnombre, xunidades, @pd, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariablePNR(const xnombre, xunidades: string;
  precision, decimales: integer; var pd; var xvar: NReal; posteVar: integer);
var
  fv: TVarDef_PNR;
begin
  fv := TVarDef_PNR.Create(self, xnombre, xunidades, precision, decimales, @pd, @xvar);
  fv.setPoste(posteVar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariablePNI(const xnombre, xunidades: string;
  var pd; var xvar: integer; posteVar: integer);
var
  fv: TVarDef_PNI;
begin
  fv := TVarDef_PNI.Create(self, xnombre, xunidades, @pd, @xvar);
  fv.setPoste(posteVar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariablePB(const xnombre, xunidades: string;
  var pd; var xvar: boolean; posteVar: integer);
var
  fv: TVarDef_PB;
begin
  fv := TVarDef_PB.Create(self, xnombre, xunidades, @pd, @xvar);
  fv.setPoste(posteVar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariablePFecha(const xnombre: string;
  var pd; var xvar: TFecha);
var
  fv: TVarDef_PFecha;
begin
  fv := TVarDef_PFecha.Create(self, xnombre, @pd, @xvar);
  self.pubvarlst.Add(fv);
end;

procedure TCosaConNombre.PublicarVariablePVNR(const xnombre, xunidades: string;
  precision, decimales: integer; var pd; var xvar: TDAofNReal;
  usarNomenclaturaConPostes: boolean);
var
  fv: TVarDef_PVNR;
  i: integer;
begin
  fv := TVarDef_PVNR.Create(self, xnombre, xunidades, precision,
    decimales, @pd, @xvar, usarNomenclaturaConPostes);
  self.pubvarlst.Add(fv);

  if usarNomenclaturaConPostes then
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_NR.CreatePpdIndice(self, xnombre +
        '_P' + IntToStr(i + 1), xunidades, precision, decimales,
        @xvar[i], @xvar, @pd))
  else
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_NR.CreatePpdIndice(self, xnombre +
        '[' + IntToStr(i + 1) + ']', xunidades, precision, decimales,
        @xvar[i], @xvar, @pd));
end;

procedure TCosaConNombre.PublicarVariablePVNI(const xnombre, xunidades: string;
  var pd; var xvar: TDAofNInt; usarNomenclaturaConPostes: boolean);
var
  fv: TVarDef_PVNI;
  i: integer;
begin
  fv := TVarDef_PVNI.Create(self, xnombre, xunidades, @pd, @xvar,
    usarNomenclaturaConPostes);
  self.pubvarlst.Add(fv);

  if usarNomenclaturaConPostes then
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_NI.CreatePpdIndice(self, xnombre +
        '_P' + IntToStr(i + 1), xunidades, @xvar[i], @xvar, @pd))
  else
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_NI.CreatePpdIndice(self, xnombre +
        '[' + IntToStr(i + 1) + ']', xunidades, @xvar[i], @xvar, @pd));
end;

procedure TCosaConNombre.PublicarVariablePVB(const xnombre, xunidades: string;
  var pd; var xvar: TDAOfBoolean; usarNomenclaturaConPostes: boolean);
var
  fv: TVarDef_PVB;
  i: integer;
begin
  fv := TVarDef_PVB.Create(self, xnombre, xunidades, @pd, @xvar,
    usarNomenclaturaConPostes);
  self.pubvarlst.Add(fv);

  if usarNomenclaturaConPostes then
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_B.CreatePpdIndice(self, xnombre +
        '_P' + IntToStr(i + 1), xunidades, @xvar[i], @xvar, @pd))
  else
    for i := 0 to high(xvar) do
      self.pubvarlst.Add(TVarDef_B.CreatePpdIndice(self, xnombre +
        '[' + IntToStr(i + 1) + ']', xunidades, @xvar[i], @xvar, @pd));
end;

procedure TCosaConNombre.PubliVars;
begin
  if pubvarlst <> nil then
    pubvarlst.Free;
  self.pubvarlst := TListaVarDefs.Create;
  //  self.PublicarVariableS('Nombre', nombre );
end;

function TCosaConNombre.getNombresPublicados: TStrings;
begin
  Result := Pubvarlst.getNombres;
end;

procedure TCosaConNombre.CambioFichaPD;
begin
  //?? debiera sobreescribirse.
end;

{$IFDEF opt_Dump_PubliVars}
procedure TCosaConNombre.printPubliVars(var f: TextFile);
var
  i: integer;
  VarDef: TVarDef;
begin
  for i := 0 to pubvarlst.Count - 1 do
  begin
    VarDef := pubvarlst.Items[i];
    VarDef.Prepararse();
    Write(f, #9 + self.nombre + '.' + VarDef.nombreVar + '=' +
      VarDef.getValorAsStringPersistible);
  end;
end;

{$ENDIF}

constructor TCosaConNombre.Create(capa: integer; const nombre: string);
begin
  inherited Create(capa);
  self.nombre := nombre;
{$IFDEF CNT_COSAS}
  CantCosas.incCntCosasClase(self.ClassType);
{$ENDIF}
  pubvarlst := nil;
end;



function TCosaConNombre.Create_Clone(CatalogoReferencias: TCatalogo;
  idHilo: integer): TCosa;
var
  res: TCosaConNombre;
begin
  res := inherited Create_Clone(CatalogoReferencias, idHilo) as TCosaConNombre;
  res.pubvarlst := nil;
  Result := res;
end;

procedure TCosaConNombre.Free;
begin
{$IFDEF CNT_COSAS}
  CantCosas.decCntCosasClase(Self.ClassType);
{$ENDIF}
  //  uCosaConNombre.eliminar_referencias_de(self);
  if pubvarlst <> nil then
    pubvarlst.Free;
  inherited Free;
end;

function TCosaConNombre.Rec: TCosa_RecLnk;
var
  res: TCosa_RecLnk;
begin
  res:=inherited Rec;
  res.addCampoDef('nombre', nombre, 0, 0 );
  result:= res;
end;


function TCosaConNombre.Apodo: string;
begin
  Result := nombre;
end;

function TCosaConNombre.get_hash_nombre: integer;
var
  res: integer;
  s: string;

begin
  res := 0;
  s := ClassName;
  crc32_in_res(res, s);
  crc32_in_res(res, nombre);
  if res < 0 then
    res := -res;
  Result := res;
end;


function TCosaConNombre.ClaseNombre: string;
begin
  Result := Self.ClassName + ', ' + self.nombre;
end;



class function TCosaConNombre.DescClase: string;
begin
  Result := 'Cosa con Nombre';
end;



function TCosaConNombre.EjecutarSentencia(orden: string;
  parametros: TStringList): TStringList;

var
  res: TStringList;
begin
  res := TStringList.Create;

  if (orden <> 'SELECT') then
  begin
    res.add('+ERROR en ' + Nombre + ' EjecutarSentencia ');
    res.add('La orden ' + orden + ' no es conocida.');
    Result := res;
    exit;
  end;

  if parametros.Count <> 1 then
  begin
    res.add('+ERROR en ' + Nombre + ' EjecutarSentencia ');
    res.add('Número inválido de parámetros. Se esperaba 1 y hay ' +
      IntToStr(parametros.Count));
    Result := res;
    exit;
  end;

end;


{$IFDEF BOSTA}
procedure TCosaConNombre.AfterInstantiation;
begin
  inherited AfterInstantiation;

  {$IFDEF CNT_COSAS}
  CantCosas.incCntCosasClase(self.ClassType);
  {$ENDIF}

  pubvarlst := nil;

end;
{$ENDIF}

//---------------------------------
//Metodos de TListaDeCosasConNombre
//=================================

function TListaDeCosasConNombre.getItem(i: integer): TCosaConNombre;
begin
  Result := lst.items[i];
end;

procedure TListaDeCosasConNombre.setItem(i: integer; cosa: TCosaConNombre);
begin
  lst.items[i] := cosa;
end;

constructor TListaDeCosasConNombre.Create(capa: integer; nombre: string);
begin
  inherited Create(capa, nombre);
  self.nombre := nombre;
end;


constructor TListaDeCosasConNombre.Create_ReadFromText(f: TArchiTexto);
var
  cnt_ids_alp: integer;
begin
  // SI, OJO , va primero el NOMBRE y después llama el inherited ... con esto
  // queda diferente que el resto de las Cosas ... pero por ahora queda así.
  f.rd('Nombre', nombre);
  if f.Version < 2 then f.rd('cnt_ids', cnt_ids_alp ); // dummy ref
  f.aux_idCarpeta := nombre;
  inherited Create_ReadFromText(f);
end;

procedure TListaDeCosasConNombre.WriteToText_(f: TArchiTexto);
begin
  f.wr('Nombre', nombre);
  inherited WriteToText_(f);
end;


function TListaDeCosasConNombre.getNextId(clase: TClaseDeCosaConNombre): string;
begin
  Result := clase.ClassName + '_' + DateTimeToStr(now);
end;

function TListaDeCosasConNombre.listaDeCosasDeClase(clases: TList):
TListaDeCosasConNombre;
var
  i, j: integer;
  resultado: TListaDeCosasConNombre;
  esDeClase: boolean;
begin
  resultado := TListaDeCosasConNombre.Create( capa, 'Auxiliar');
  for i := 0 to lst.Count - 1 do
  begin
    esDeClase := False;
    for j := 0 to clases.Count - 1 do
    begin
      if TCosa(lst.items[i]).ClassType = TClass(clases[j]) then
      begin
        esDeClase := True;
        break;
      end;
    end;
    if esDeClase then
      resultado.lst.Add(lst.items[i]);
  end;
  Result := resultado;
end;

function TListaDeCosasConNombre.find(const nombre: string): TCosaConNombre;
var
  k: integer;
  res: TCosaConNombre;
begin
  res := nil;
  for k := 0 to lst.Count - 1 do
  begin
    if TCosaConNombre(lst.items[k]).nombre = nombre then
    begin
      res := lst.items[k];
      break;
    end;
  end;
  Result := res;
end;

function TListaDeCosasConNombre.find(const clase, nombre: string): TCosaConNombre;
var
  k: integer;
  res: TCosaConNombre;
begin
  res := nil;
  for k := 0 to lst.Count - 1 do
  begin
    if (TCosaConNombre(lst.items[k]).nombre = nombre) and
      (TCosaConNombre(lst.Items[k]).ClassName = clase) then
    begin
      res := lst.items[k];
      break;
    end;
  end;
  Result := res;
end;

function TListaDeCosasConNombre.find(const nombre: string; var ipos: integer): boolean;
var
  k: integer;
  buscando: boolean;
begin
  buscando := True;
  for k := 0 to lst.Count - 1 do
  begin
    if TCosaConNombre(lst.items[k]).nombre = nombre then
    begin
      buscando := False;
      ipos := k;
      break;
    end;
  end;
  Result := not buscando;
end;

function TListaDeCosasConNombre.find(const clase, nombre: string;
  var ipos: integer): boolean;
var
  k: integer;
  buscando: boolean;
  cosa: TCosaConNombre;
begin
  buscando := True;
  for k := 0 to lst.Count - 1 do
  begin
    cosa := lst.items[k];
    if (cosa.ClassName = clase) and (cosa.nombre = nombre) then
    begin
      buscando := False;
      ipos := k;
      break;
    end;
  end;
  Result := not buscando;
end;

function TListaDeCosasConNombre.Add(cosa: TCosaConNombre): integer;
var
  ipos: integer;
  cntrep: integer;
  xnombre: string;
begin
  cntrep := 0;
  xnombre := cosa.nombre;
  while find(xnombre, ipos) do
  begin
    Inc(cntrep);
    xnombre := cosa.nombre + '$' + IntToStr(cntrep);
  end;

  if (cntrep > 0) then
  begin
    (*
    showmessage( 'Atención tuve que renombrar la '
      + cosa.ClaseNombre + ' del nombre: ' + cosa.nombre+ ' a : '
      + xnombre );
      *)
    cosa.nombre := xnombre;
  end;
  Result := lst.Add(cosa);
end;

procedure TListaDeCosasConNombre.insert(indice: integer; cosa: TCosaConNombre);
var
  ipos: integer;
begin
  if not find(cosa.nombre, ipos) then
  begin
    lst.insert(indice, cosa);
  end
  else
    raise Exception.Create('La lista ' + self.nombre +
      ' ya tiene un elemento de nombre ' + cosa.nombre);
end;

function TListaDeCosasConNombre.Remove(cosa: TCosaConNombre): integer;
begin
  Result := lst.Remove(cosa);
end;

function TListaDeCosasConNombre.nombresCosas: TStringList;
var
  res: TStringList;
  i: integer;
begin
  res := TStringList.Create;
  res.Capacity := lst.Count;
  for i := 0 to lst.Count - 1 do
    res.Add(TCosaConNombre(lst.items[i]).nombre);
  Result := res;
end;


{procedure TListaDeCosasConNombre.CambioFichaPD;
begin
  raise Exception.Create('Metodo abstracto cambioFichaPD en ' + self.ClassName);
end;}


//-------------------------------------
//Metodos de TListaDeCosasReferenciadas
//=====================================

constructor TListaDeReferenciasACosas.Create(capa: integer);
begin
  inherited Create(capa);
  lst:= TList.Create;
end;



constructor TListaDeReferenciasACosas.Create_ReadFromText(f: TArchiTexto);
var
  n, k: integer;
  aCosa: TCosa;
begin
  inherited Create_ReadFromText(f);
  f.rd('n', n);
  for k := 0 to n - 1 do
  begin
    f.rdReferencia(':', aCosa, Self);

    raise Exception.Create('TListaDeReferenciasACosas !!! Create_ReadFromText ' );
    // Agrego esto ... y comento el OJO ... pero me parece
    // que no debe pasar por acá sino se rompe todo
    lst.add( aCosa );

 //OJO!!! esto estaría matando lo leido???   lst[k] := nil;
  end;
end;


procedure TListaDeReferenciasACosas.WriteToText_(f: TArchiTexto);
var
  n, k: integer;
  cosa: TCosaConNombre;
begin
  inherited WriteToText_(f);
  n := lst.count;
  f.wr('n', n);
  for k := 0 to n - 1 do
  begin
    cosa := lst[k];
    f.wrReferencia(':', cosa);
  end;
end;


function TListaDeReferenciasACosas.Addx(cosa: TCosaConNombre): integer;
begin
  Result :=lst.add( cosa );
end;

function TListaDeReferenciasACosas.find(const nombre: string;
  var ipos: integer): boolean;
var
  k: integer;
  buscando: boolean;
begin
  buscando := True;
  for k := 0 to lst.count-1 do
  begin
    if TCosaConNombre(lst[k]).nombre = nombre then
    begin
      buscando := False;
      ipos := k;
      break;
    end;
  end;
  Result := not buscando;
end;

function TListaDeReferenciasACosas.find(const clase, nombre: string;
  var ipos: integer): boolean;
var
  k: integer;
  buscando: boolean;
  cosa: TCosaConNombre;
begin
  buscando := True;
  for k := 0 to lst.count-1 do
  begin
    cosa := lst[k];
    if (cosa.ClassName = clase) and (cosa.nombre = nombre) then
    begin
      buscando := False;
      ipos := k;
      break;
    end;
  end;
  Result := not buscando;
end;


//----------------------------
// métodos de TFichaReferencia
//============================

constructor TFichaReferencia.Create(referente: TCosa; referencia: PCosaConNombre;
  referido_clase, referido_nombre: string);
begin
  inherited Create;
  Self.referente := referente;
  Self.referencia := referencia;
  Self.referido_clase := referido_clase;
  Self.referido_nombre := referido_nombre;
end;


procedure TFichaReferencia.Free;
begin
  inherited Free;
end;



constructor TCatalogoReferencias.Create;
begin
  inherited Create;
  referencias := TList.Create;
end;


procedure TCatalogoReferencias.Free;
var
  k: integer;
  afr: TFichaReferencia;
begin
  if referencias <> nil then
  begin
    for k := 0 to referencias.Count - 1 do
    begin
      afr := referencias.items[k];
      afr.Free;
    end;
    referencias.Free;
  end;
  inherited Free;
end;

procedure TCatalogoReferencias.registrar_referencia(referente: TCosa;
  claseDelreferido, nombreDelReferido: string; var referencia);
var
  fr: TFichaReferencia;
begin
  if claseDelReferido <> '?' then
  begin
    fr := TFichaReferencia.Create(referente, @referencia, claseDelReferido,
      nombreDelReferido);
    referencias.Add(fr);
  end;
end;

function TCatalogoReferencias.obtenerReferencia(claseDelreferido,
  nombreDelReferido: string; var referencia: PCosaConNombre): boolean;
var
  i: integer;
  ref: TFichaReferencia;
begin
  Result := False;
  for i := 0 to referencias.Count - 1 do
  begin
    ref := referencias[i];
    if (ref.referido_nombre = nombreDelReferido) and
      (ref.referido_clase = claseDelreferido) then
    begin
      referencia := ref.referencia;
      Result := True;
      break;
    end;
  end;
end;

procedure TCatalogoReferencias.DumpReferencias(archi: string);
var
  f: textFile;
  k: integer;
  ref: TFichaReferencia;
begin
  assignfile(f, archi);
  rewrite(f);
  for k := 0 to referencias.Count - 1 do
  begin
    ref := referencias.items[k];
    if ref.referente is TCosaConNombre then
      writeln(f, TCosaConNombre(ref.referente).claseNombre + '-> <' +
        ref.referido_clase + '.' + ref.referido_nombre + '>')
    else
      writeln(f, '?:-> <' + ref.referido_clase + '.' + ref.referido_nombre + '>');
  end;
  closefile(f);
end;

function TCatalogoReferencias.existeReferencia_al(referido: TCosaConNombre): boolean;
var
  i: integer;
  ref: TFichaReferencia;
  res: boolean;
begin
  res := False;
  for i := 0 to referencias.Count - 1 do
  begin
    ref := referencias[i];
    if (ref.referido_nombre = referido.nombre) and
      (ref.referido_clase = referido.ClassName) then
    begin
      res := True;
      break;
    end;
  end;
  Result := res;
end;

function TCatalogoReferencias.existeReferencia_del(referente: TCosa;
  referido: TCosaConNombre): boolean;
var
  i: integer;
  ref: TFichaReferencia;
  res: boolean;
begin
  res := False;
  for i := 0 to referencias.Count - 1 do
  begin
    ref := referencias[i];
    if (ref.referente = referente) and (ref.referido_nombre = referido.nombre) and
      (ref.referido_clase = referido.ClassName) then
    begin
      res := True;
      break;
    end;
  end;
  Result := res;
end;

// resuelve las referencias contra la lista de actores y retorna la
// cantidad de referencias que quedan sin resolver (por si es necesario pasar otra lista)
function TCatalogoReferencias.resolver_referencias(CosasLst:
  TListaDeCosasConNombre): integer;
var
  k: integer;
  ipos: integer;
  ref: TFichaReferencia;
begin
  k := 0;
  while k < referencias.Count do
  begin
    ref := referencias.items[k];
    if CosasLst.find(ref.referido_clase, ref.referido_nombre, ipos) then
    begin
      ref.referencia^ := CosasLst.lst.items[ipos];
      ref.Free;
      referencias.Delete(k);
    end
    else
      Inc(k);
  end;
  Result := referencias.Count;
end;

procedure TCatalogoReferencias.WriteLNReferencias;
var
  k: integer;
  ref: TFichaReferencia;
begin
  for k := 0 to referencias.Count - 1 do
  begin
    ref := referencias.items[k];
    system.writeln('<', ref.referido_clase, '.', ref.referido_nombre, '>');
  end;
end;

function TCatalogoReferencias.resolver_referenciasDeCosa(referente: TCosa;
  CosasLst: TListaDeCosasConNombre): integer;
var
  k, refsSinResolverDeReferente: integer;
  ipos: integer;
  ref: TFichaReferencia;
begin
  k := 0;
  refsSinResolverDeReferente := 0;
  while k < referencias.Count do
  begin
    ref := referencias.items[k];
    if ref.referente = referente then
    begin
      if CosasLst.find(ref.referido_clase, ref.referido_nombre, ipos) then
      begin
        ref.referencia^ := CosasLst.lst.items[ipos];
        ref.Free;
        referencias.Delete(k);
      end
      else
      begin
        Inc(k);
        Inc(refsSinResolverDeReferente);
      end;
    end
    else
      Inc(k);
  end;
  Result := refsSinResolverDeReferente;
end;

function TCatalogoReferencias.cambiar_referencias_al(ref_Anterior,
  ref_Nueva: TCosaConNombre): integer;
var
  i, resultado: integer;
  ref: TFichaReferencia;
begin
  resultado := 0;
  for i := 0 to referencias.Count - 1 do
  begin
    ref := referencias[i];
    if (ref_Anterior.nombre = ref.referido_nombre) and
      (ref_Anterior.ClassName = ref.referido_clase) then
    begin
      ref.referido_nombre := ref_Nueva.nombre;
      ref.referido_clase := ref_Nueva.ClassName;
      //      ref.referencia^ := ref_Nueva;
      resultado := resultado + 1;
    end;
  end;
  Result := resultado;
end;

function TCatalogoReferencias.cambiar_referencias_del_al(referente: TCosa;
  ref_Anterior, ref_Nueva: TCosaConNombre): integer;
var
  i, resultado: integer;
  ref: TFichaReferencia;
begin
  resultado := 0;
  for i := 0 to referencias.Count - 1 do
  begin
    ref := referencias[i];
    if (ref.referente = referente) and (ref_Anterior.nombre =
      ref.referido_nombre) and (ref_Anterior.ClassName = ref.referido_clase) then
    begin
      ref.referido_nombre := ref_Nueva.nombre;
      ref.referido_clase := ref_Nueva.ClassName;
      //      ref.referencia^ := ref_Nueva;
      resultado := resultado + 1;
    end;
  end;
  Result := resultado;
end;

function TCatalogoReferencias.cambiar_NombreDelReferidoEnReferenciasPosterioresAK(
  k: integer; nombre_Anterior, nombre_Nuevo, claseReferido: string): integer;
var
  i, resultado: integer;
  ref: TFichaReferencia;
begin
  resultado := 0;
  for i := k to referencias.Count - 1 do
  begin
    ref := referencias[i];
    if (nombre_Anterior = ref.referido_nombre) and (claseReferido =
      ref.referido_clase) then
    begin
      ref.referido_nombre := nombre_Nuevo;
      resultado := resultado + 1;
    end;
  end;
  Result := resultado;
end;

function TCatalogoReferencias.eliminar_referencias_del(referente: TCosa): integer;
var
  i, resultado: integer;
begin
  resultado := 0;
  if referencias <> nil then
  begin
    for i := 0 to referencias.Count - 1 do
      if referente = TFichaReferencia(referencias[i]).referente then
      begin
        resultado := resultado + 1;
        TFichaReferencia(referencias[i]).Free;
        referencias[i] := nil;
      end;
    if resultado > 0 then
    begin
      referencias.Pack;
      referencias.Capacity := referencias.Count;
    end;
  end;
  Result := resultado;
end;

function TCatalogoReferencias.referenciasSinResolver: integer;
begin
  Result := referencias.Count;
end;

procedure TCatalogoReferencias.LimpiarReferencias;
var
  k: integer;
begin
  for k := 0 to referencias.Count - 1 do
    TFichaReferencia(referencias.items[k]).Free;
  referencias.Clear;
end;

function ordenString(Item1, Item2: Pointer): integer;
begin
  if TCosaConNombre(Item1).nombre < TCosaConNombre(Item2).nombre then
    Result := -1
  else if TCosaConNombre(Item1).nombre = TCosaConNombre(Item2).nombre then
    Result := 0
  else
    Result := 1;
end;

function ParseNombre(const claseNombre: string): string;
var
  posSeparador: integer;
begin
  posSeparador := pos(',', claseNombre);
  Result := copy(claseNombre, posSeparador + 2, MAXINT);
end;

function ParseClase(const claseNombre: string): string;
var
  posSeparador: integer;
begin
  posSeparador := pos(',', claseNombre);
  Result := copy(claseNombre, 0, posSeparador - 1);
end;

procedure AlInicio;
begin
  ucosa.registrarClaseDeCosa(TListaDeCosasConNombre.ClassName, TListaDeCosasConNombre);
  ucosa.registrarClaseDeCosa(TListaDeReferenciasACosas.ClassName,
    TListaDeReferenciasACosas);
end;

procedure AlFinal;
begin
end;


end.
