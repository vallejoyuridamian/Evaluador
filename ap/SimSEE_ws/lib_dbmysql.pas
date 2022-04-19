// (c) ZonaExterior 2014 , rchaer@zonaexterior.net
unit lib_dbmysql;
{$M DELPHI}

interface

uses
  SysUtils, mysql50;

type
  TDB_row = MYSQL_ROW;
  TDB_ds = class;

  TDB_con = class
    // conexión
    dbg_on: boolean;
    hcon: PMYSQL;
    qmysql: st_mysql;

    constructor Create(host, base, usuario, clave: string; flg_DEBUG: boolean = False);
    function query(sql_str: string): TDB_ds;
    function exec(sql_str: string): integer;

    function BEGIN_WORK: integer;
    function COMMIT: integer;
    function ROLLBACK: integer;

    function nextval(nombresecuencia: string; autocrear: boolean = False): integer;
    function f(sql: string): string;
    function f_rec(sql: string): TDB_row;
    function error: string;
    function now: string;

    procedure Free;
  end;


  TDB_ds = class
    hds: PMYSQL_RES;
    krow: integer;
    row: TDB_row;
    campos: PMYSQL_FIELD;

    constructor Create(con: TDB_con; sql: string);
    function ncols: integer;
    function nrows: integer;
    function go(krow: integer): TDB_row;
    function First: TDB_row;
    function Next: TDB_row;
    function locate_k(icampo: integer; valor: string): integer;

    function indexOfField(nombre: string): integer;
    function fname(kcol: integer): string;
    function ftype(kcol: integer): enum_field_types;
    function flen(kcol: integer): integer;
    function fgetval(kcol: integer): string;
    procedure Free;
  end;




implementation

(* Métodos de TDB_ds *)




constructor TDB_ds.Create(con: TDB_con; sql: string);
var
  sQuery: string;
begin
  sQuery := sql + #0;
  hds := nil;
  row := nil;
  campos := nil;

  if (mysql_query(con.hcon, @sQuery[1]) < 0) then
  begin
    FreeAndNil(self);
    exit;
  end;
  hds := mysql_store_result(con.hcon);
  if hds = nil then
    FreeAndNil( self )
  else
   krow := 0;
end;

function TDB_ds.ncols: integer;
begin
  Result := mysql_num_fields(hds);
end;

function TDB_ds.nrows: integer;
begin
  Result := mysql_num_rows(hds);
end;

function TDB_ds.go(krow: integer): TDB_row;
begin
  self.krow := krow;
  mysql_data_seek(hds, krow);
  row := mysql_fetch_row(hds);
  Result := row;
end;

function TDB_ds.First: TDB_row;
begin
  result:= go(0);
end;


function TDB_ds.Next: TDB_row;
begin
  row := mysql_fetch_row(hds);
  if row <> nil then
    Inc(krow);
  Result := row;
end;


function TDB_ds.locate_k(icampo: integer; valor: string): integer;
var
  buscando: boolean;
  obj: MYSQL_ROW;
  k, n: integer;
begin
  buscando := True;
  k := 0;
  n := nrows;
  while (buscando and (k < n)) do
  begin
    obj := go(k);
    if (obj[icampo] = valor) then
      buscando := False
    else
      Inc(k);
  end;
  if buscando then
    Result := -1
  else
    Result := k;
end;

function TDB_ds.indexOfField(nombre: string): integer;
var
//  af: PMYSQL_FIELD;
  n, k: integer;
begin
  result:= -1;
  n:= ncols;
  for k:= 0 to n-1 do
    if mysql_fetch_field_direct( hds, k).Name = nombre then
    begin
      result:= k;
      break;
    end;
end;

function TDB_ds.fname(kcol: integer): string;
var
  af: PMYSQL_FIELD;
begin
  af:= mysql_fetch_field_direct( hds, kcol);
  Result := af.Name;
end;

function TDB_ds.ftype(kcol: integer): enum_field_types;
var
  af: PMYSQL_FIELD;
begin
  af:= mysql_fetch_field_direct( hds, kcol);
  Result := af.ftype;
end;

function TDB_ds.flen(kcol: integer): integer;
var
  af: PMYSQL_FIELD;
begin
  af:= mysql_fetch_field_direct( hds, kcol);
  Result := af.max_length;
end;

function TDB_ds.fgetval(kcol: integer): string;
begin
  Result := row[kcol];
end;

procedure TDB_ds.Free;
begin
  if hds <> nil then
    mysql_free_result(hds);
end;



(* Métodos de TDB_con *)
constructor TDB_con.Create(host, base, usuario, clave: string;
  flg_DEBUG: boolean = False);
var
  C_Host, C_base, C_usuario, C_clave: string;
begin
  C_Host := host + #0;
  C_Base := base + #0;
  C_Usuario := Usuario + #0;
  C_Clave := Clave + #0;

  dbg_on := flg_Debug;

  mysql_init(PMySQL(@qmysql));
  hcon := mysql_real_connect(PMySQL(@qmysql), @C_host[1],
    @C_Usuario[1], @C_Clave[1], nil, 3306, nil, 0);

  if hcon = nil then
  begin
    if dbg_on then
    begin
      Writeln(stderr, 'Couldn''t connect to MySQL.');
      Writeln(stderr, mysql_error(@qmysql));
    end;
    FreeAndNil(self);
  end;

  if mysql_select_db(hcon, @C_Base[1]) < 0 then
  begin
    if dbg_on then
    begin
      Writeln(stderr, 'Couldn''t select database: ', base);
      Writeln(stderr, mysql_error(hcon));
    end;
    FreeAndNil(self);
  end;

end;

function TDB_con.query(sql_str: string): TDB_ds;
var
  ds: TDB_ds;
begin
  ds := TDB_ds.Create(self, sql_str);
  if (ds = nil) and dbg_on then
    writeln('Error QUERY: ', error);
  Result := ds;
end;

function TDB_con.exec(sql_str: string): integer;
var
  ds: TDB_ds;
begin
  ds := TDB_ds.Create(self, sql_str);
  if (ds = nil) and dbg_on then
    writeln('Error EXEC: ', error);
  if ds = nil then
    Result := -1
  else
  begin
    Result := hcon.affected_rows;
    ds.Free;
  end;
end;

procedure TDB_con.Free;
begin
  mysql_close(hcon);
end;

function TDB_con.BEGIN_WORK: integer;
begin
  Result := exec('BEGIN WORK;');
end;

function TDB_con.COMMIT: integer;
begin
  Result := exec('COMMIT;');
end;

function TDB_con.ROLLBACK: integer;
begin
  Result := exec('ROLLBACK;');
end;

function TDB_con.nextval(nombresecuencia: string; autocrear: boolean = False): integer;
var
  nid: integer;
  r: TDB_row;
  ds: TDB_ds;
  sql, sql2: string;
begin
  BEGIN_WORK;
  sql := 'SELECT nextval AS nid FROM secuencias WHERE nombre = "' +
    nombresecuencia + '" LIMIT 1; ';
  ds := query(sql);
  if ds.nrows <> 1 then
  begin
    if autocrear then
    begin
      sql2 := 'INSERT INTO secuencias ( nombre, nextval, incval ) VALUES '
        + '( "' + nombresecuencia + '", 1, 1 ) ';
      exec(sql2);
      ds := query(sql);
    end
    else
    begin
      COMMIT;
      writeln('ERROR- nexval ( ' + nombresecuencia + ' ) , secuencia desconocida');
      Result := -MaxInt;
      ds.Free;
      exit;
    end;
  end;

  r := ds.Next;
  nid := StrToInt(r[0]);
  sql := 'UPDATE secuencias SET nextval=nextval+incval WHERE nombre = "' +
    nombresecuencia + '" LIMIT 1; ';
  exec(sql);
  COMMIT();
  ds.Free;
  Result := nid;
end;

// retorna un valor es como evaluar la funcion sql
function TDB_con.f(sql: string): string;
var
  ds: TDB_ds;
  r: TDB_row;
begin
  ds := query(sql);
  if ds <> nil then
  begin
    r := ds.Next;
    Result := r[0];
    ds.Free;
  end
  else
    Result := '';
end;



function TDB_con.f_rec(sql: string): TDB_row;
var
  ds: TDB_ds;
  r: TDB_row;
begin
  ds := query(sql);
  if ds <> nil then
  begin
    r := ds.Next;
    ds.Free; // mmmm me parece que esto BORRA el r????
    Result := r;
  end
  else
    Result := nil;
end;

function TDB_con.error: string;
begin
  Result := mysql_error(hcon);
end;

function TDB_con.now: string;
begin
  Result := f('SELECT DATE_FORMAT(now(), "%d/%m/%Y&nbsp;%H:%i") ');
end;

end.
