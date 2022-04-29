unit uRobotSOAP;
interface

uses
  Classes, SysUtils, httpsend;

type

  TTipoCampo = (CampoTipoString, CampoTipoFloat, CampoTipoInteger,
    CampoTipoBoolean, CampoTipoFecha, CampoTipoCompuesto, CampoTipoXML);

  { TCampoSoap }

  TCampoSoap = class
  private
    _Next: TCampoSoap;
    function GetNext: TCampoSoap;
    procedure SetNext(AValue: TCampoSoap);

  public
    nombre: string;
    valor: string;
    tipo: TTipoCampo;
    hijos: TList;

    function AsString: string;
    function AsFloat: double;
    function AsInteger: integer;
    function AsBoolean: boolean;
    function AsDt: TDateTime;

    constructor Create(aNombre, aValor: string; aNext: TCampoSoap = nil);

    function serialize_xml(): string;
    procedure AddHijo(aHijo: TCampoSoap);

    property Next: TCampoSoap read GetNext write SetNext;

    procedure Free;
    class function def(aNombre, aValor: string; aNext: TCampoSoap = nil): TCampoSOAP;
  end;


  { TRobotSoap }

  TRobotSoap = class
    hc: THttpSend;
    soap_url: string;
    BaseDeNombres: string;

    constructor Create(aURL, aBaseDeNombres: string);
    procedure Free;


    function Call(Servicio: string; parametros: TCampoSoap = nil;
      flg_reventarParametros: boolean = true): boolean;

    // busca en hc.Document la siguiente aparición de pal a partir de la
    // posición kIni y devuelve
    // la posición de inicio de Pal (-1 si no encuentra pal).
    function seekPalInicio(pal: string; kIni: integer = 0): integer;

    // busca en hc.Document la siguiente aparición de Pal y retorna la posición
    // del caracter siguiente al fin de Pal (-1 si no encuentra pal).
    function seekPalFin(pal: string; kIni: integer = 0): integer;

    // Retorna en res el texto entre <NombrePar> y </NombrePar> buscando en
    // hc.Document.Memory desde la posición kIni.
    // El resultado es la posición del caracter siguiente al fin de </NombrePar>
    // o -1 si no se encontró el parámetro
    function getval(var res: string; NombrePar: string; kIni: integer = 0): integer;

  private
    procedure wrln(s: string);
    function LocateHeader(const AHeader: string): integer;
    procedure SetAction(const AValue: string);
  end;

implementation

function TCampoSoap.GetNext: TCampoSoap;
begin
  Result := self._Next;
end;

procedure TCampoSoap.SetNext(AValue: TCampoSoap);
begin
  self._Next := AValue;
end;

function TCampoSoap.AsString: string;
begin
  Result := valor;
end;

function TCampoSoap.AsFloat: double;
begin
  Result := StrToFloat(AsString);
end;

function TCampoSoap.AsInteger: integer;
begin
  Result := StrToInt(AsString);
end;

function TCampoSoap.AsBoolean: boolean;
var
  s: string;
begin
  s := lowercase(AsString);
  Result := (length(s) > 0) and (s[1] <> '0') and (s[1] <> 'false') and
    (s[1] <> 'falso') and (s[1] <> 'f');
end;

function TCampoSoap.AsDt: TDateTime;
begin
  Result := StrToDateTime(AsString);
end;

constructor TCampoSoap.Create(aNombre, aValor: string; aNext: TCampoSoap = nil);
begin
  inherited Create;
  Nombre := aNombre;
  Valor := aValor;
  Tipo := CampoTipoString;
  hijos := nil;
  Next := aNext;
end;

class function TCampoSoap.def(aNombre, aValor: string;
  aNext: TCampoSoap = nil): TCampoSOAP;
var
  res: TCampoSoap;
begin
  res := TCampoSOAP.Create(aNombre, aValor, aNext);
  Result := res;
end;

function TCampoSoap.serialize_xml(): string;
var
  k: integer;
begin
  Result := '<' + self.nombre + '>';
  if self.hijos <> nil then
    for k := 0 to hijos.Count - 1 do
      Result := Result + TCampoSoap(self.hijos[k]).serialize_xml();
  Result := Result + self.valor;
  Result := Result + '</' + self.nombre + '>';

  if Assigned(self.Next) then
    Result := Result + self.Next.serialize_xml();

end;

procedure TCampoSoap.AddHijo(aHijo: TCampoSoap);
begin
  if hijos = nil then
    hijos := TList.Create;
  hijos.add(aHijo);
end;

procedure TCampoSoap.Free;
var
  k: integer;
begin
  if hijos <> nil then
    for k := 0 to hijos.Count - 1 do
      TCampoSoap(hijos[k]).Free;
  inherited Free;
end;


constructor TRobotSoap.Create(aURL, aBaseDeNombres: string);
begin
  inherited Create;
  soap_url := aURL;
  BaseDeNombres := aBaseDeNombres;
  hc := THTTPSend.Create;
  hc.Protocol := '1.1';
  hc.MimeType := 'text/xml';
end;


procedure TRobotSoap.Free;
begin
  hc.Free;
  inherited Free;
end;

function TRobotSoap.LocateHeader(const AHeader: string): integer;
var
  i: integer;
  locList: TStringList;
  s: string;
begin
  Result := -1;
  locList := hc.Headers;
  if (locList.Count > 0) then
  begin
    s := LowerCase(AHeader);
    for i := 0 to locList.Count - 1 do
      if (Pos(s, LowerCase(locList[i])) = 1) then
      begin
        Result := i;
        Break;
      end;
  end;
end;


procedure TRobotSoap.SetAction(const AValue: string);
var
  i: integer;
  s: string;
begin
  i := LocateHeader('soapAction:');
  s := 'soapAction:' + self.BaseDeNombres + '/' + AValue;
  if (i >= 0) then
    hc.Headers[i] := s
  else
    hc.Headers.Insert(0, s);
end;


procedure TRobotSoap.wrln(s: string);
begin
  s := s + #13#10;
  hc.Document.WriteBuffer(s[1], length(s));
end;



function TRobotSoap.Call(Servicio: string; parametros: TCampoSoap = nil; flg_reventarParametros: boolean = true ): boolean;
begin
  Result := True;
  hc.Headers.Clear;
  hc.Document.Clear;
  hc.KeepAlive:= true;
  hc.KeepAliveTimeout:= 1000 * 15;
  hc.Timeout:= 1000*60*10;
  wrln('<?xml version="1.0" encoding="utf-8"?>');
  wrln('<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">');
  wrln('  <soap:Body> ');

  if parametros <> nil then
  begin
    wrln('    <' + Servicio + ' xmlns="' + BaseDeNombres + '">');
    wrln('      ' + parametros.serialize_xml());
    wrln('    </' + Servicio + '>');
    if flg_reventarParametros then
      parametros.Free;
  end
  else
    wrln('    <' + Servicio + ' xmlns="' + BaseDeNombres + '"/>');

  wrln('  </soap:Body>');
  wrln('</soap:Envelope>');
  wrln('');

  self.SetAction(Servicio);

  if not hc.HTTPMethod('POST', soap_url) then
    Result := False;
end;

// busca en hc.Document la siguiente aparición de pal a partir de la
// posición kIni y devuelve
// la posición de inicio de Pal (-1 si no encuentra pal).
function TRobotSoap.seekPalInicio(pal: string; kIni: integer = 0): integer;
var
  k: integer;
begin
  k := seekPalFin(pal, kIni);
  if k >= 0 then
    Result := k - length(pal)
  else
    Result := -1;
end;

type
  TArrayOfChar = array[0..1024000000] of char;

// busca en hc.Document la siguiente aparición de Pal y retorna la posición
// del caracter siguiente al fin de Pal (-1 si no encuentra pal).
function TRobotSoap.seekPalFin(pal: string; kIni: integer): integer;
var
  n: integer;
  fin: boolean;
  k, j: integer;
begin
  k := kIni;
  fin := k >= hc.Document.Size;

  if fin then
  begin
    Result := -1;
    exit;
  end;

  n := Length(pal);
  j := 0;

  while (j < n) and not fin do
  begin
    if TArrayOfChar(hc.Document.Memory^)[k] = pal[j + 1] then
      Inc(j)
    else
      j := 0;
    Inc(k);
    fin := k >= hc.Document.Size;
  end;

  if j = n then
    Result := k
  else
    Result := -1;
end;

function TRobotSoap.getval(var res: string; NombrePar: string;
  kIni: integer = 0): integer;
var
  iIni, iFin: integer;
  xResult: integer;
begin
  //  hc.Document.SaveToFile( 'c:\basura\pepito.txt' );
  hc.Document.Position := 0;
  iIni := seekPalFin('<' + NombrePar + '>', kIni);
  xResult := -1;
  if iIni > 0 then
  begin
    iFin := seekPalInicio('</' + NombrePar + '>', iIni);
    if iFin > 0 then
    begin
      setlength(res, iFin - iIni);
      move(TArrayOfChar(hc.Document.Memory^)[iIni], res[1], iFin - iIni);
      xResult := iFin + length(NombrePar) + 3;
    end;
  end;
  if (xResult < 0) and ( NombrePar <> 'ValorRangoXmlResult' ) then
  begin
    setlength( res, hc.Document.Size );
    move(TArrayOfChar(hc.Document.Memory^)[0], res[1], hc.Document.Size );
    writeln('getval < 0, nombrePar: '+NombrePar+', kIni: '+IntToStr(kIni)+', res: '+res );
    res:= '';
  end;
  result:= xResult;
end;


end.
