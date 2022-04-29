unit uInfoCosa;

{ Esta unidad centraliza el manejo de Editores de Cosas.
La idea es que al registrar una Cosa se registre el Formulario para editarlo.
}

interface

uses
  Classes, SysUtils,
  uCosa,
  uBaseFormularios;

resourcestring
  exEditorNoRegistradoClase = 'Editor no registrado para la clase ';

type
  //Guarda el editor asociado a la clase tipo

  { TInfoCosa }

  TInfoCosa = class
  private
    CosaStrId: string;
    tipo: TClass;
    descClase: string;
    editor: TClaseDeFormularios;
  public
    constructor Create(xtipo: TClass; descClase: string;
      xeditor: TClaseDeFormularios); overload;
    constructor Create(xCosaStrId: string; xDescClase: string;
      xEditor: TClaseDeFormularios); overload;
    procedure Free; virtual;
  end;

  { TListaInfoCosas }

  TListaInfoCosas = class(TList)
  public
    function Add(Item: TInfoCosa): integer;
    function getEditorCosa(ACosaStrId: string): TClaseDeFormularios; overload;
    function getTipoEditor(tipo: TClass): TClaseDeFormularios; overload;
    function getTipoEditor(descClase: string): TClaseDeFormularios; overload;
    function descsClase: TStrings;
    function tipoDeCosa(descClase: string): TClass;
    function ordinalTipoCosa(clase: TClass): integer;
    procedure Free;
  end;

var

  InfoCombustibles: TListaInfoCosas;
  InfoFichasCombustibles: TListaInfoCosas;
  InfoMonitores: TListaInfoCosas;
  InfoFuentes: TListaInfoCosas;
  InfoFichasFuentes: TListaInfoCosas;

  InfoIndicesSimRes: TListaInfoCosas;
  InfoCronVarsSimRes: TListaInfoCosas;
  InfoCronOpersSimRes: TListaInfoCosas;
  InfoPostOpersSimRes: TListaInfoCosas;
  InfoPrintCronVarsSimRes: TListaInfoCosas;

procedure AlInicio;
procedure AlFinal;

function ordinalTipoCosa(clase: TClass): integer;


implementation



//---------------------
// Métodos de TInfoCosa
//=====================

constructor TInfoCosa.Create(xtipo: TClass; descClase: string; xeditor: TClaseDeFormularios);
begin
  inherited Create;
  tipo := xtipo;
  self.descClase := descClase;
  editor := xeditor;
end;

constructor TInfoCosa.Create(xCosaStrId: string; xDescClase: string;
  xEditor: TClaseDeFormularios);
begin
  inherited Create;
  self.CosaStrId := xCosaStrId;
  self.tipo := nil;
  self.descClase := xDescClase;
  self.editor := xEditor;
end;

procedure TInfoCosa.Free;
begin
  CosaStrId := '';
  tipo := nil;
  descClase := '';
  editor := nil;
end;

//---------------------------
// Métodos de TListaInfoCosas
//===========================

function TListaInfoCosas.Add(Item: TInfoCosa): integer;
begin
  Result := inherited Add(Item);
end;

function TListaInfoCosas.getEditorCosa(ACosaStrId: string): TClaseDeFormularios;
var
  i: integer;
  a: integer;
  b: string;
begin
  a := self.Count;
  for i := 0 to self.Count - 1 do
  begin
    b := TInfoCosa(items[i]).CosaStrId;
    if TInfoCosa(items[i]).CosaStrId = ACosaStrId then
    begin
      Result := TInfoCosa(items[i]).editor;
      break;
    end;
  end;
end;

function TListaInfoCosas.getTipoEditor(tipo: TClass): TClaseDeFormularios;
var
  i: integer;
  encontre: boolean;
  resultado: TClaseDeFormularios;
begin
  encontre := False;
  resultado := nil;
  for i := 0 to Count - 1 do
    if TInfoCosa(items[i]).tipo = tipo then
    begin
      resultado := TInfoCosa(items[i]).editor;
      encontre := True;
      break;
    end;

  if not encontre then
    raise Exception.Create(exEditorNoRegistradoClase + tipo.ClassName)
  else
    Result := resultado;
end;

function TListaInfoCosas.getTipoEditor(descClase: string): TClaseDeFormularios;
var
  i: integer;
  encontre: boolean;
  resultado: TClaseDeFormularios;
begin
  encontre := False;
  resultado := nil;
  for i := 0 to Count - 1 do
    if TInfoCosa(items[i]).DescClase = descClase then
    begin
      resultado := TInfoCosa(items[i]).editor;
      encontre := True;
      break;
    end;
  if not encontre then
    raise Exception.Create(exEditorNoRegistradoClase + descClase)
  else
    Result := resultado;
end;

function TListaInfoCosas.descsClase: TStrings;
var
  i: integer;
  lista: TStrings;
  s: string;
begin
  lista := TStringList.Create;
  for i := 0 to Count - 1 do
  begin
    s := TInfoCosa(items[i]).descClase;
    lista.Add(s);
  end;
  Result := lista;
end;

function TListaInfoCosas.tipoDeCosa(descClase: string): TClass;
var
  i, pos: integer;
begin
  pos := -1;
  for i := 0 to Count - 1 do
    if TInfoCosa(items[i]).descClase = descClase then
    begin
      pos := i;
      break;
    end;

  if pos <> -1 then
    Result := TInfoCosa(items[i]).tipo
  else
    raise Exception.Create('TListaInfoCosas.TipoDeCosa: Tipo de cosa no registrada: ' +
      descClase);
end;

function TListaInfoCosas.ordinalTipoCosa(clase: TClass): integer;
var
  i, res: integer;
begin
  res := -1;
  for i := 0 to Count - 1 do
    if TInfoCosa(Items[i]).tipo = clase then
    begin
      res := i;
      break;
    end;
  Result := res;
end;

procedure TListaInfoCosas.Free;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    TInfoCosa(Items[i]).Free;
  inherited Free;

end;

procedure AlInicio;
begin

  InfoMonitores := TListaInfoCosas.Create;
  InfoFuentes := TListaInfoCosas.Create;
  InfoFichasFuentes := TListaInfoCosas.Create;
  InfoCombustibles := TListaInfoCosas.Create;
  InfoFichasCombustibles := TListaInfoCosas.Create;

  InfoIndicesSimRes := TListaInfoCosas.Create;
  InfoCronVarsSimRes := TListaInfoCosas.Create;
  InfoCronOpersSimRes := TListaInfoCosas.Create;
  InfoPostOpersSimRes := TListaInfoCosas.Create;
  InfoPrintCronVarsSimRes := TListaInfoCosas.Create;

end;

procedure AlFinal;
var
  i: integer;
begin
  InfoMonitores.Free;
  InfoFuentes.Free;
  InfoFichasFuentes.Free;
  InfoCombustibles.Free;
  InfoFichasCombustibles.Free;
  InfoIndicesSimRes.Free;
  InfoCronVarsSimRes.Free;
  InfoCronOpersSimRes.Free;
  InfoPostOpersSimRes.Free;
  InfoPrintCronVarsSimRes.Free;
end;

function buscarOrdinalEnLista(clase: TClass; listaInfo: TListaInfoCosas;
  var acumCounts: integer): integer;
var
  res: integer;
begin
  res := listaInfo.ordinalTipoCosa(clase);
  if res = -1 then
    acumCounts := acumCounts + listaInfo.Count;
  Result := res;
end;

function ordinalTipoCosa(clase: TClass): integer;
var
  res, acumCounts: integer;
begin
  //El orden en que se busca en las listas determina el orden de los ordinales
  //Ord(InfoFuentes[i].tipo) < Ord(InfoMonitores[j].tipo) < Ord(InfoFichasFuentes[k].tipo) <...
  //para todo i, j, k
  acumCounts := 0;
  res := buscarOrdinalEnLista(clase, InfoFuentes, acumCounts);
  if res = -1 then
  begin
    res := buscarOrdinalEnLista(clase, InfoMonitores, acumCounts);
    if res = -1 then
    begin
      res := buscarOrdinalEnLista(clase, InfoFichasFuentes, acumCounts);
      if res = -1 then
      begin
        res := buscarOrdinalEnLista(clase, InfoIndicesSimRes, acumCounts);
        if res = -1 then
        begin
          res := buscarOrdinalEnLista(clase, InfoCronVarsSimRes, acumCounts);
          if res = -1 then
          begin
            res := buscarOrdinalEnLista(clase, InfoCronOpersSimRes, acumCounts);
            if res = -1 then
            begin
              res := buscarOrdinalEnLista(clase, InfoPostOpersSimRes, acumCounts);
              if res = -1 then
                res := buscarOrdinalEnLista(clase, InfoPrintCronVarsSimRes, acumCounts);
            end;
          end;
        end;
      end;
    end;
  end;

  if res = -1 then
    Result := -1
  else
    Result := res + acumCounts;
end;

end.
