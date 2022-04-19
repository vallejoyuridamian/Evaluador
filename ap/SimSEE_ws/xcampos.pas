//(c) ZonaExterior.net
unit xcampos;

interface

uses
  SysUtils, Classes, Math, fphttpserver, HTTPDefs, funcsauxs;


(*****************
auxiliares
 * *************)

// retorna el índice de (val) en el array (arr).
// si el resultado es -1 significa que no lo encontró.
function kinarray(arr: TStrings; val: string): integer;

// agrega al final el valor si es que no existe en el array
procedure agregar(arr: TStringList; val: string);

function EUToISO(valor: string): string;
function ISOToEU(valor: string): string;

function EUToUSA(valor: string): string;



// busca en la lista x el índice de la cadena que comience
// con 'nombre='
// Si el resultado es >= 0 es que lo encontró.
// Si el resultado es -1 es que no lo encontró.
function indexOfParam(x: TStrings; nombre: string; iFrom: integer = 0): integer;


// busca nombreVar primero el POST y si no ecuentra en GET
// El resultado es el valor del campo si se encuentra o lo
// que se haya cargado en valorPorDefecto
function varval(xent: TFPHTTPConnectionRequest; nombreVar: string;
  valorPorDefecto: string = ''): string;

// lo mismo que lo anterior pero retorna un entero
function varval_int(xent: TFPHTTPConnectionRequest; nombreVar: string;
  valorPorDefecto: integer = 0): integer;

// busca todas las aparicioines del parámetro y retornna una
// lista de valores
function varval_multi(xent: TFPHTTPConnectionRequest; nombreVar: string;
  valorPorDefecto: TStrings = nil): TStrings;


function arr2lst(a: array of string): TStrings;

type

(* * ************
  TCF_Base
* ************** *)
  TCF_Base = class
    nombre: string;
    valor: string;
    valini: string;
    extras: string;

    constructor Create( nombre: string; extras: string = '');

    // si xent = nil carga valini
    procedure load( xent: TFPHTTPConnectionRequest; valini: string ); virtual;

    procedure reset; virtual;  // carga el valini

    function AsInt: integer; virtual;
    function AsStr: string; virtual;
    function AsFloat: double; virtual;

    procedure html(xsal: TFPHTTPConnectionResponse); virtual;
    function html_str: string; virtual;

    // le agrega un prefijo CFrch_ a los campos para evitar
    // que coincida con otros identificadores
    function nombre_html: string; virtual;
    procedure Free; virtual;
  end;


(* * ****
  TCF_Base_Multi   Clase de base para los que son multivalor
*** * *)
  TCF_Base_Multi = class(TCF_Base)
    lst_valor: TStrings;
    lst_valini: TStrings;
    onChange: string;

    constructor Create(nombre: string; extras: string = '');

    // vlini = item1, item2, ... , itemN     (considera ', ' como separador)
    procedure load( xent: TFPHTTPConnectionRequest; valini: string ); override;

    procedure reset; virtual;  // carga el valini
    function nsels: integer; virtual;
    function palabraSel(k: integer): string; virtual;

    function nombre_html: string; override;
    procedure Free; override;
  end;


(* * ************
  TCF_Hidden
 * ************** *)
  TCF_Hidden = class(TCF_base)
    function html_str: string; override;
  end;


(* * ************
  TCF_File
 * ************** *)
  TCF_File = class(TCF_base)
    function html_str: string; override;
  end;

(* * ************
  TCF_text
 * ************** *)
  TCF_text = class(TCF_base)
    ncols: integer;
    constructor Create(
      nombre: string; ncols: integer; extras: string = '');
    function html_str: string; override;
  end;

(* * ************
  TCF_password
 * ************** *)
  TCF_password = class(TCF_text)
    function html_str: string; override;
  end;

(* * ****************
  TCF_textarea
 * **************** *)
  TCF_textarea = class(TCF_base)
    rows: integer;
    cols: integer;
    constructor Create(
      nombre: string; nfilas, ncolumnas: integer;
      extras: string = '');
    function html_str: string; override;
  end;

(* * ***************
  TCF_checkbox
 * **************** *)
  TCF_checkbox = class(TCF_base)
    keyval: string;
    Caption: string;
    onChange: string;
    constructor Create(
      nombre: string; keyval: string = '1';
      Caption: string = ''; extras: string = '');

    function Checked: boolean;
    function checked01: integer;
    function html_str: string; override;
  end;


(* * ***************
  TCF_radio
  Al crear el objeto del tipo Radio, hay que pasarle un nombre,
  un array de textos que son los seleccionables, el valor del
  índice del objeto inicialmente seleccionado.
 * **************** *)
  TCF_radio = class(TCF_base)
    Valores: TStrings;
    constructor Create(
      nombre: string; arrayOfValues: TStrings; extras: string = '');
    function htmlElemento_str(kelemento: integer): string;
    function palabraSel: string;
    function html_str: string; override;
  end;

(* * *********************
  TCF_select
 * ********************* *)
  TCF_select = class(TCF_base_multi)
    Valores: TStrings;
    multisel: boolean;
    altomax: integer;
    altomin: integer;
    constructor Create(
      nombre: string;
      arrayOfValues: TStrings; multisel: boolean;
      altomin, altomax: integer; extras: string = '');

    function htmlElemento_str(kelemento: integer): string;
    function html_str: string; override;
  end;

(* * *********************
  TCF_keyedselect
 * ********************* *)
  TCF_keyedselect = class(TCF_base_Multi)
    keys: TStrings;
    Valores: TStrings;
    multisel: boolean;
    altomax: integer;
    altomin: integer;

    constructor Create(
      nombre: string;
      arrayOfKeys, arrayOfValues: TStrings; multisel: boolean;
      altomin, altomax: integer; extras: string = '');

    function htmlElemento_str(kelemento: integer): string;

    // dref devuelve el Valor correspondiente a la clave pasada como parámetro
    // esto hace que se puedan utilizar los TCF_keyedselect como tablas de lookup.
    function deref(key: string): string;
    function find(Valor: string; IgnoreCase: boolean = True): integer;
    function html_str: string; override;
  end;

(* * **********
  TCF_Fecha
 * *********** *)
  TCF_Fecha = class(TCF_base)
    form: string;
    ncols: integer;
    js_BeforeShow: string;
    js_AfterHide: string;

    constructor Create(
      form_name: string; nombre: string;
      ncols: integer; js_BeforeShow: string = '';
      js_AfterHide: string = ''; extras: string = '');
    function html_str: string; override;
  end;


(* * ***********
 TCF_Font
 * *********** *)
  TCF_Font = class(TCF_keyedselect)
    constructor Create(
      nombre: string; extras: string = '');
  end;



implementation

const
  month_name: array[1..12] of string =
    ('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC');
  CRLF = #13#10;
function kinarray(arr: TStrings; val: string): integer;
begin
  if arr <> nil then
    Result := arr.IndexOf(val)
  else
    Result := -1;
end;


// agrega al final el valor si es que no existe en el array
procedure agregar(arr: TStringList; val: string);
begin
  if (kinarray(arr, val) < 0) then
  begin
    if arr = nil then
      arr := TStringList.Create;
    arr.add(val);
  end;
end;

// convierte del formato de fecha dd/mm/aaaa (EUropeo) al ISO aaaa-mm-dd
function EUToISO(valor: string): string;
var
  v: string;
  i: integer;
  dia, mes: string;
  anio: integer;

begin
  v := valor;
  i := pos('/', v);
  if (i <= 1) then
  begin
    Result := '';
    exit;
  end;
  dia := copy(v, 1, i - 1);
  Delete(v, 1, i);
  i := pos('/', v);
  if (i <= 1) then
  begin
    Result := '';
    exit;
  end;

  mes := copy(v, 1, i - 1);
  Delete(v, 1, i);

  i := pos(' ', v);
  if i > 0 then
    anio := StrToInt(copy(v, 1, i - 1))
  else
    anio := StrToInt(v);

  if (anio < 100) then
    if (anio >= 62) then
      anio := anio + 1900
    else
      anio := anio + 2000;

  v := IntToStr(anio) + '-' + mes + '-' + dia;
  Result := v;
end;


function EUToUSA(valor: string): string;
var
  v: string;
  i, mes: integer;
  dia, anio: string;
begin
  v := valor;
  i := pos('/', v);
  if (i <= 1) then
  begin
    Result := '';
    exit;
  end;

  dia := copy(v, 1, i - 1);
  Delete(v, 1, i);

  i := pos('/', v);
  if (i <= 1) then
  begin
    Result := '';
    exit;
  end;
  mes := StrToInt(copy(v, 1, i - 1));
  Delete(v, 1, i);

  i := pos(' ', v);
  if i > 0 then
    anio := copy(v, 1, i - 1)
  else
    anio := trim(v);

  v := month_name[mes] + ' ' + dia + ' ' + anio;
  Result := v;
end;


// Convierte del formato de fecha ISO aaaa-mm-dd al EUropeo dd/mm/aaaa
function ISOToEU(valor: string): string;
var
  v: string;
  i, j: integer;
  anio, mes, dia: string;
begin
  v := trim(valor);
  if (v = '') then
  begin
    Result := '';
    exit;
  end;

  i := strpos(v, '-');
  if (i <= 0) then
  begin
    Result := '';
    exit;
  end;

  anio := substr(v, 0, i);
  j := strpos(v, '-', i + 1);
  if (j <= 0) then
  begin
    Result := '';
    exit;
  end;

  mes := substr(v, i + 1, j - i - 1);
  dia := substr(v, j + 1);
  i := strpos(dia, ' ');
  if (i > 1) then
  begin
    dia := substr(dia, 0, i);
  end;

  v := dia + '/' + mes + '/' + anio;
  if (dia = '00') then
    v := '';

  Result := v;
end;


function indexOfParam(x: TStrings; nombre: string; iFrom: integer = 0): integer;
var
  k: integer;
  linea, sbuscada: string;
  res: integer;
begin
  res := -1;
  sbuscada := nombre + '=';
  for k := iFrom to x.Count - 1 do
  begin
    linea := x[k];
    if strpos(linea, sbuscada) = 0 then
    begin
      res := k;
      break;
    end;
  end;
  Result := res;
end;


function varval(xent: TFPHTTPConnectionRequest; nombreVar: string;
  valorPorDefecto: string = ''): string;
var
  i: integer;
  res: string;
begin
  if xent = nil then
  begin
    result := valorPorDefecto;
    exit;
  end;

  res := '';
  i := indexOfParam(xent.ContentFields, nombreVar);
  if i >= 0 then
    res := substr(xent.ContentFields[i], length(nombreVar) + 1)
  else
  begin
    i := indexOfParam(xent.QueryFields, nombreVar);
    if i >= 0 then
      res := substr(xent.QueryFields[i], length(nombreVar) + 1);
  end;
  Result := res;
end;

function varval_int(xent: TFPHTTPConnectionRequest; nombreVar: string;
  valorPorDefecto: integer = 0): integer;
var
  pal: string;
begin
  if xent = nil then
  begin
    Result := ValorPorDefecto;
    exit;
  end;

  pal := varval(xent, nombreVar);
  if pal = '' then
    Result := ValorPorDefecto
  else
    Result := StrToInt(pal);
end;

function varval_multi(xent: TFPHTTPConnectionRequest; nombreVar: string;
  valorPorDefecto: TStrings = nil): TStrings;
var
  i, k: integer;
  res: TStrings;

begin
  if xent = nil then
  begin
    Result := valorPorDefecto;
    exit;
  end;

  res := TStringList.Create;

  k := 0;

  repeat
    i := indexOfParam(xent.ContentFields, nombreVar, k);
    if i >= 0 then
    begin
      k := i+1;
      res.add(substr(xent.ContentFields[i], length(nombreVar) + 1));
    end
    else
    begin
      i := indexOfParam(xent.QueryFields, nombreVar, k);
      if i >= 0 then
      begin
        k := i+1;
        res.add(substr(xent.QueryFields[i], length(nombreVar) + 1));
      end;
    end;
  until (i < 0);

  Result := res;
end;



function arr2lst(a: array of string): TStrings;
var
  res: TStrings;
  k: integer;
  pal: string;
begin
  res := TStringList.Create;
  for k := 0 to high(a) do
  begin
    pal := a[k];
    res.add(pal);
  end;
  Result := res;
end;

(* * **************************
  clase raiz de todos los CF_.
 * *************************** *)


constructor TCF_Base.Create(
  nombre: string; extras: string = '');
begin
  self.nombre := nombre;
  self.extras := extras;
end;


procedure TCF_Base.load( xent: TFPHTTPConnectionRequest; valini: string );
begin
  self.valini := valini;
  self.valor := varval(xent, nombre_html, valini);
end;

procedure TCF_base.reset;
begin
  valor := valini;
end;

function TCF_base.html_str: string;
begin
  Result := '';
end;



function TCF_base.nombre_html: string;
begin
  result:= 'CFrch_' +nombre;
end;


procedure TCF_base.Free;
begin
  inherited Free;
end;

function TCF_base.AsInt: integer;
var
  rescod: integer;
  res: integer;
begin
  val(valor, res, rescod);
  if rescod = 0 then
    Result := res
  else
    Result := 0;
end;

function TCF_base.AsStr: string;
begin
  Result := valor;
end;

function TCF_base.AsFloat: double;
var
  rescod: integer;
  res: double;
begin
  val(valor, res, rescod);
  if rescod <> 0 then
    Result := res
  else
    Result := 0;
end;

procedure TCF_base.html(xsal: TFPHTTPConnectionResponse);
begin
  xsal.Contents.add(html_str);
end;


constructor TCF_base_multi.Create(
  nombre: string;
  extras: string = '');
begin
  self.nombre := nombre;
  self.valini := '';
  self.valor := '';
  self.lst_valini := TStringList.Create;
  self.extras := extras;
  self.onChange := '';
end;

// vlini = item1, item2, ... , itemN     (considera ', ' como separador)
procedure TCF_base_multi.load( xent: TFPHTTPConnectionRequest; valini: string );
var
  i: integer;
  s, pal: string;
begin
  self.valini:= valini;
  lst_valini.Clear;
  lst_valini:= explode(',', valini );
(*
  s:= valini;
  i:= pos( ',', s );
  while i > 0 do
  begin
    pal:= trim(copy( s, 1, i-1 ));
    delete( s, 1, i+1 );
    lst_valini.add( pal )
  end;
  trim( s );
  if s <> '' then
    lst_valini.add( s );
    *)
  self.lst_valor := varval_multi(xent, nombre_html, lst_valini);
end;

procedure TCF_base_multi.reset;
begin
  lst_valor := lst_valini;
end;

procedure TCF_base_multi.Free;
begin
  lst_valini.Free;
  lst_valor.Free;
  inherited Free;
end;


function TCF_base_multi.nombre_html: string;
begin
  result:= ( inherited nombre_html )+'[]';
end;


function TCF_base_multi.nsels: integer;
begin
  if lst_valor = nil then
    Result := 0
  else
    Result := lst_valor.Count;
end;


function TCF_base_multi.palabraSel(k: integer): string;
begin
  Result := lst_valor[k];
end;



(* * ***********
  CF_hidden
 * ************ *)
function TCF_hidden.html_str: string;
begin
  Result := '<input type="hidden" name="' + nombre_html + '" value="' +
    valor + '" ' + extras + '>';
end;

(* * ***********
  CF_file
 * ************ *)
function TCF_File.html_str: string;
begin
  Result := '<input type="file" name="' + nombre_html + '" value="' + valor + ' ' + extras + '">';
end;


(* * **********
  TCF_text
 * *********** *)
constructor TCF_Text.Create(
  nombre: string; ncols: integer; extras: string = '');
begin
  inherited Create( nombre, extras);
  self.ncols := ncols;
end;

function TCF_Text.html_str: string;
var
  s: string;
begin
  s := '<input type="text" name="' + nombre_html + '" size="' + IntToStr(ncols) + '" ';
  s := s + 'value="' + valor + '" ' + extras + ' >';
  Result := s;
end;

(* * ************
  TCF_password
 * ************** *)
function TCF_password.html_str: string;
begin
  Result := '<input type="password" name="' + nombre_html + '" size="' +
    IntToStr(ncols) + '" value="' + valor + '">';
end;

(* * ****************
  TCF_textarea
 * **************** *)


constructor TCF_textarea.Create(
  nombre: string; nfilas, ncolumnas: integer;
  extras: string = '');
begin
  inherited Create( nombre, extras);
  rows := nfilas;
  cols := ncolumnas;
end;

function TCF_textarea.html_str: string;
begin
  Result := '<textarea rows="' + IntToStr(rows) + '" name="' +
    nombre_html + '" id="' + nombre_html + '" cols="' + IntToStr(
    cols) + '" ' + extras + ' >' + valor + '</textarea>';
end;


(* * ***************
  TCF_checkbox
 * **************** *)



constructor TCF_checkbox.Create(
  nombre: string; keyval: string = '1';
  Caption: string = ''; extras: string = '');
begin
  inherited Create( nombre, extras);
  self.keyval := keyval;
  self.Caption := Caption;
  onChange := '';
end;


function TCF_checkbox.Checked: boolean;
begin
  Result := valor = keyval;
end;

function TCF_checkbox.checked01: integer;
begin
  if Checked then
    Result := 1
  else
    Result := 0;
end;

function TCF_checkbox.html_str: string;
var
  s: string;
begin
  s := '<input type="checkbox" name="' + nombre_html + '" value="' + keyval + '" ';
  if Checked then
    s := s + 'checked ';

  if onChange <> '' then
    s := s + 'onclick="' + onChange + '" ';

  s := s + ' extras >';

  if Caption <> '' then
    s := s + Caption;
  Result := s;
end;


(* * ***************
  CF_radio
  Al crear el objeto del tipo Radio, hay que pasarle un nombre,
  un array de textos que son los seleccionables, el valor del
  índice del objeto inicialmente seleccionado.
 * **************** *)

constructor TCF_radio.Create(
  nombre: string; arrayOfValues: TStrings;
  extras: string = '');

begin
  inherited Create( nombre, extras);
  valores := arrayOfValues;
end;

function TCF_radio.htmlElemento_str(kelemento: integer): string;
var
  s: string;
begin
  s := '<input type="radio" value="' + IntToStr(kelemento) + '" ';
  if IntToStr(kelemento) = valor then
    s := s + 'checked ';

  s := s + 'name="' + nombre_html + '">';
  s := s + Valores[kelemento];
  Result := s;
end;


function TCF_radio.palabraSel: string;
begin
  Result := Valores[StrToInt(valor)];
end;

function TCF_radio.html_str: string;
var
  s: string;
  k: integer;

begin
  s := '';
  for k := 0 to Valores.Count - 1 do
    s := s + htmlElemento_str(k) + ' ';
  Result := s;
end;


(* * *********************
  CF_select
 * ********************* *)

constructor TCF_select.Create(
  nombre: string;
  arrayOfValues: TStrings; multisel: boolean;
  altomin, altomax: integer; extras: string = '');

begin
  inherited Create( nombre, extras);
  Valores := arrayOfValues;
  Self.multisel := multisel;
  Self.altomin := altomin;
  Self.altomax := altomax;
  onChange := '';
end;


function TCF_select.htmlElemento_str(kelemento: integer): string;
var
  s: string;
begin
  s := '<option ';
  if (kinarray(lst_valor, IntToStr(kelemento)) >= 0) then
    s := s + 'selected ';
  s := s + 'value="' + IntToStr(kelemento) + '">' + Valores[kelemento] + '</option>';
  Result := s;
end;

function TCF_select.html_str: string;
var
  n, k: integer;
  size: integer;
  s: string;
begin
  n := Valores.Count;
  if (n < altomin) then
    size := altomin
  else if (n > altomax) then
    size := altomax
  else
    size := n;

  s := '<select name="' + nombre_html + '" size="' + IntToStr(size) + '" ';
  if multisel then
    s := s + 'multiple ';

  if onChange <> '' then
    s := s + 'onChange="' + onChange + '" ';

  s := s + '>' + CRLF;
  for k := 0 to Valores.Count - 1 do
    s := s + htmlElemento_str(k) + CRLF;
  s := s+ '</select>' + CRLF;
  Result := s;
end;



(* * *********************
  CF_keyedselect
 * ********************* *)

constructor TCF_keyedselect.Create(
  nombre: string;
  arrayOfKeys, arrayOfValues: TStrings; multisel: boolean;
  altomin, altomax: integer; extras: string = '');

begin
  inherited Create( nombre, extras);
  keys := arrayOfKeys;
  Valores := arrayOfValues;
  self.multisel := multisel;
  self.altomax := altomax;
  self.altomin := altomin;
end;


function TCF_keyedselect.htmlElemento_str(kelemento: integer): string;
var
  s, texto, key: string;
begin
  s := '';
  texto := Valores[kelemento];
  key := keys[kelemento];

  if (kinarray(lst_valor, key) >= 0) then
    s := s + '<option selected value="' + key + '">' + texto + '</option>'
  else
    s := '<option value="' + key + '">' + texto + '</option>';

  Result := s;
end;

function TCF_keyedselect.html_str: string;
var
  s: string;
  n, k, size: integer;
begin
  n := Valores.Count;
  if (n < altomin) then
    size := altomin
  else if (n > altomax) then
    size := altomax
  else
    size := n;

  s := '<select name="' + nombre_html + '" size="' + IntToStr(size) + '" ';
  if multisel then
    s := s + 'multiple = "multiple" ';

  if (onChange <> '') then
    s := s + 'onChange="´' + onChange + '" ';

  if extras <> '' then
    s := s + extras;
  s := s + '>' + CRLF;

  for k := 0 to Valores.Count - 1 do
    s := s + htmlElemento_str(k) + CRLF;
  s := s + '</select>' + CRLF;
  Result := s;
end;




function TCF_keyedselect.deref(key: string): string;
var
  k: integer;
begin
  k := kinarray(keys, key);
  if k >= 0 then
    Result := Valores[k]
  else
    Result := '';
end;


function TCF_keyedselect.find(Valor: string; Ignorecase: boolean = True): integer;
var
  buscando: boolean;
  palbus, pal: string;
  k, n: integer;
begin
  buscando := True;
  k := 0;
  n := Valores.Count;

  if IgnoreCase then
    palbus := UpperCase(trim(Valor))
  else
    palbus := trim(Valor);

  while (buscando and (k < n)) do
  begin
    if IgnoreCase then
      pal := UpperCase(trim(Valores[k]))
    else
      pal := trim(Valores[k]);

    if (palbus = pal) then
      buscando := False
    else
      Inc(k);
  end;

  if buscando then
    Result := -1
  else
    Result := k;
end;

(* * **********
  TCF_fecha
 * *********** *)



constructor TCF_Fecha.Create(
  form_name: string; nombre: string;
  ncols: integer; js_BeforeShow: string = '';
  js_AfterHide: string = ''; extras: string = '');
begin
  inherited Create( nombre, extras);
  Self.form := form_name;
  Self.ncols := ncols;
  Self.extras := extras;
  Self.js_BeforeShow := js_BeforeShow;
  Self.js_AfterHide := js_AfterHide;
end;


function TCF_Fecha.html_str: string;
var
  s: string;
begin
  s := '<input type="text" name="' + nombre_html + '" size="' + IntToStr(
    ncols) + '" ' + 'value="' + valor + '" ' + extras +
    ' >' + CRLF + '<script language="JavaScript">' + CRLF + 'var tcal_' + nombre_html +
    '= new tcal ({''formname'': ''' + form + ''', ''controlname'': ''' +
    nombre_html + '''};); ' + CRLF;

  if js_BeforeShow <> '' then
    s := s + ' tcal_' + nombre_html + '.f_BeforeShow=' + js_BeforeShow + ';' + CRLF;

  if js_AfterHide <> '' then
    s := s + ' tcal_' + nombre_html + '.f_AfterHide=' + js_AfterHide + ';' + CRLF;

  s := s + '</script>' + CRLF;

  Result := s;
end;



(* * **********
  TCF_Font
 * *********** *)


constructor TCF_Font.Create(
  nombre: string; extras: string = '');

var
  arrayOfKeys: TStrings;

begin
  arrayOfKeys:= TStringList.Create;
  arrayOfKeys.add('Arial');
  arrayOfKeys.add('Arial Black');
  arrayOfKeys.add('Verdana');
  arrayOfKeys.add('Book Antiqua');
  arrayOfKeys.add('Calibri');
  arrayOfKeys.add('Century Gothic');
  arrayOfKeys.add('Comic Sans MS');
  arrayOfKeys.add('Courier New');
  arrayOfKeys.add('Matisse ITC');
  arrayOfKeys.add('Monotype Corsiva');
  arrayOfKeys.add('Tahoma');
  arrayOfKeys.add('Times New Roman');
  arrayOfKeys.add('Verdana');
  inherited Create( nombre, arrayOfKeys, arrayOfKeys, False, 1, 1, extras);
end;

end.
