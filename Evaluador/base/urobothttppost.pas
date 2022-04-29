unit uRobotHttpPost;

(*
Proyecto: SimSEE
Autor: Ruben Chaer
Fecha: 2014-03-29
Descripción:  esta unidad permite crear agentes para realizar
  consultas a un sitio web mediante envio de formularios POST.
  Se implementó para la consulta de pronósticos en SimSEE.
*)
{$mode delphi}

interface

uses
  ssl_openssl,
  Classes, httpsend, SysUtils;

type
(***
   La idea es que se crea el Robot dando una url a la que se envian
   las consultas.
   Los resultados de las consultas se devuelven en un TStringList
   Para facilitar el FILTRADO de resultados, al inicializar el
   Robot además de la url se puden pasar las string InicioRes y FinRes
   si esas sring son diferentes de vacio, se elminan toas las lineas
   antes de InicioRes (inclusive) y todas las líneas posteriores a FinRes (inclusive)

   Para definir los parámetros del formulario se utilizan los métodos
   ClearCampos que elimina todos los campos que estuviesen definidos
   addCampo permite definir un nuevo campo en el formulario pasando
      nombre y valor. Esta función retorna el ordinal identificador
      del campo agregado en el formulario.
   setCampo permite fijar un nuevo valor al campo cuyo ordinal es el
      entero kPar pasado como parámetro.
***)

  { TRobotHttpPost }

  TRobotHttpPost = class
  private
    url: string; { ej: http://simsee.org/pronosticos/index.php }
    InicioRes: string; {ej: '+inicio'}
    FinRes: string; {ej: '+fin' }
    proxy_host, proxy_port, proxy_user, proxy_pass: string;
    campos_nombres: TStringList;
    campos_valores: TStringList;
    flg_EliminoLineaInicio: boolean;
    flg_EliminoLineaFin: boolean;
  public
    referrer: string;

    constructor Create(
      url, InicioRes, FinRes: string;
      flg_EliminoLineaInicio: boolean = true;
      flg_EliminoLineaFin: boolean = true );
    procedure set_proxy(host, port, user, pass: string);
    procedure ClearCampos;
    function AddCampo(const nombre: string; const valor: string): integer; overload;
    function AddCampo(const nombre: string; const valor: integer): integer; overload;
    function AddCampo(const nombre: string; const valor: double): integer; overload;
    procedure SetCampo(kPar: integer; NuevoValor: string);
    function post( Metodo: String ): TStringList;
    procedure post_storeFile( Metodo, archi: String );
    destructor destroy; override;

  private
    function ProxyHttpPostURL(
     const URL, URLData: string; const Data: TStream; Metodo: string ): boolean;
  end;

  function URLEncode(Str: string): string;

implementation
uses
  synacode;

function URLEncode(Str: string): string;
var
  i, j: integer;
  res, s2: string;
begin
  result:=  synacode.encodeURLElement( str );
  exit;

  //  result:= synacode.EncodeURL( str );
  setlength(res, length(str) * 3);
  j := 1;
  for i := 1 to Length(Str) do
    if Str[i] in ['A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.'] then
    begin
      Res[j] := Str[i];
      Inc(j);
    end
    else
    begin
      if ( Str[i] = ' ' ) then
      begin
        Res[j] := '+';
        Inc(j);
      end
      else
      begin
        Res[j] := '%';
        Inc(j);
        s2 := IntToHex(Ord(Str[i]), 2);
        Res[j] := s2[1];
        Inc(j);
        Res[j] := s2[2];
        Inc(j);
      end;
    end;
  setlength(res, j - 1);
  Result := res;
end;

destructor TRobotHttpPost.destroy;
begin
  campos_nombres.free;
  campos_valores.free;
  inherited destroy;

end;

constructor TRobotHttpPost.Create(url, InicioRes, FinRes: string;
       flg_EliminoLineaInicio: boolean = true;
      flg_EliminoLineaFin: boolean = true );
begin
  inherited Create;
  self.url := url;
  self.inicioRes := inicioRes;
  self.finRes := finRes;

  campos_nombres := TStringList.Create;
  campos_valores := TStringList.Create;
  self.proxy_host := '';
  self.proxy_port := '';
  self.proxy_user := '';
  self.proxy_pass := '';

  self.flg_EliminoLineaInicio:= flg_EliminoLineaInicio;
  self.flg_EliminoLineaFin:= flg_EliminoLineaFin;
  referrer:= '';
end;


procedure TRobotHttpPost.set_proxy(host, port, user, pass: string);
begin
  self.proxy_host := host;
  self.proxy_port := port;
  self.proxy_user := user;
  self.proxy_pass := pass;
end;

procedure TRobotHttpPost.ClearCampos;
begin
  campos_nombres.Clear;
  campos_valores.Clear;
end;

function TRobotHttpPost.AddCampo(const nombre: string; const valor: string): integer;
begin
  campos_nombres.Add(nombre);
  campos_valores.add(valor);
  Result := campos_nombres.Count - 1;
end;


function TRobotHttpPost.AddCampo(const nombre: string; const valor: integer): integer;
begin
  result:= AddCampo( nombre, IntToStr( valor ) );
end;

function TRobotHttpPost.AddCampo(const nombre: string; const valor: double): integer;
begin
  result:= AddCampo( nombre, FloatToStr( valor ) );
end;

procedure TRobotHttpPost.SetCampo(kPar: integer; NuevoValor: string);
begin
  campos_valores[kPar] := NuevoValor;
end;


function TRobotHttpPost.ProxyHttpPostURL(const URL, URLData: string;
  const Data: TStream; Metodo: string ): boolean;
var
  HTTP: THTTPSend;
  res: boolean;
begin
  HTTP := THTTPSend.Create;
  try
    HTTP.ProxyHost := self.proxy_host;
    HTTP.ProxyPort := self.proxy_port;
    HTTP.ProxyUser := self.proxy_user;
    HTTP.ProxyPass := self.proxy_pass;
    HTTP.Document.Write(Pointer(URLData)^, Length(URLData));
    HTTP.MimeType := 'application/x-www-form-urlencoded';
    HTTP.UserAgent:= 'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.137 Safari/537.36';

    if referrer <> '' then
      HTTP.Headers.Add('Referrer: '+referrer );

  //  Res := HTTP.HTTPMethod('POST', URL);
    Res := HTTP.HTTPMethod( Metodo, URL);
    Data.CopyFrom(HTTP.Document, 0);

  finally
    HTTP.Free;
  end;


  result:= res;
end;

function TRobotHttpPost.post(Metodo: String): TStringList;
var
  rb: string;
  Content_Length: cardinal;
  buff: string;
  ipStr: string;
  error: string;
  res: TStringList;
  k, j: integer;
  st: TMemoryStream;
  buscando: boolean;
  kPar: integer;
  rs: string;
  i: integer;
  ok: Boolean;

begin
  rb := '';
  for kPar := 0 to campos_nombres.Count - 1 do
  begin
    if kPar > 0 then
      rb := rb + '&';
    rb := rb + URLEncode(campos_nombres[kPar]) + '=' + URLEncode(campos_valores[kPar]);
  end;


  st := TMemoryStream.Create;
  try
    ok:= ProxyHttpPostURL(url, rb, st, Metodo);
    st.Seek(0, soFromBeginning);
    res := TStringList.Create;
    res.LoadFromStream(st);
  finally
    st.Free;
  end;

//  res.SaveToFile( 'urosx_x.xlt' );


  if InicioRes <> '' then
  begin

    // Borro las líneas anteriores al inicio
    buscando := True;
    while (res.Count > 0) and buscando do
    begin
      rs:= trim(res[0]);
//  writeln( rs );
      if pos(InicioRes, rs) > 0 then
        buscando := False
      else
        res.Delete(0);
    end;

    if buscando then
    begin
      res.Free;
      raise Exception.Create(
        'TRobotHttpPost.post: error, no se recibió INICIO ' + InicioRes);
    end
    else
    begin
      if flg_EliminoLineaInicio then
        res.Delete( 0 )
      else
      begin
        i:= pos( InicioRes, rs );
        delete( rs, 1, i-1 + length( InicioRes ) );
        if rs = '' then
          res.Delete( 0 )
        else
          res[0]:= rs;
      end;
    end;
  end;

  if FinRes <> '' then
  begin
    buscando := True;
    k:= 0;
    while buscando and ( k < res.count ) do
    begin
      rs:= res[k];
  //    writeln( rs );
      if pos(FinRes, rs) > 0 then
        buscando := False
      else
        inc( k);
    end;

    if buscando then
    begin
      res.Free;
      raise Exception.Create(
        'TRobotHttpPost.post: error, no se recibió FINAL ' + FinRes);
    end
    else
    begin
      while (res.count-1) > k do res.Delete( res.count-1);
      if flg_EliminoLineaFin then
        res.delete( k )
      else
      begin
        i:= pos( FinRes, rs );
        if i = 1 then
          res.Delete( k )
        else
        begin
          delete( rs, i, length( rs ) - i + 1 );
          res[k]:= rs;
        end;
      end;
    end;

  end;

  Result := res;
end;



procedure TRobotHttpPost.post_storeFile( Metodo, archi: String );
var
  rb: string;
  st: TFileStream;
  kPar: integer;
begin
  rb := '';
  for kPar := 0 to campos_nombres.Count - 1 do
  begin
    if kPar > 0 then
      rb := rb + '&';
    rb := rb + URLEncode(campos_nombres[kPar]) + '=' + URLEncode(campos_valores[kPar]);
  end;

  //if not DirectoryExists( 'C:\simsee\PostOper\') then CreateDir('C:\simsee\PostOper\');
  if not DirectoryExists( ExtractFileDir(archi)) then CreateDir(ExtractFileDir(archi));
  if fileExists( archi ) then deletefile( archi );
  st := TFileStream.Create( archi, fmCreate );



  try
    ProxyHTTPpostURL(url, rb, st, Metodo);
  finally
    st.Free;
  end;
end;



end.
