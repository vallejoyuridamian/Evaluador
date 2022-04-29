unit ucurvasaeros;

{$mode delphi}

interface

uses
  Classes,
  SysUtils,
  xmatdefs,
  matreal,
  {$IFNDEF SIN_DBCON}
  {$IFDEF pq_direct}
  udbconpg,
  {$ELSE}
  urosx,
  {$ENDIF}
  {$ENDIF}
  uro_aire;

type
  {$IFNDEF SIN_DBCON}
  {$IFNDEF pq_direct}
  TDBPQCon = TDBrosxCon;
  {$ENDIF}
  {$ENDIF}

  TCurvaAerogen = class
    nid: integer;
    modelo: string;
    Diametro: NReal;
    NPuntos: integer;
    curva_v, curva_P: TVectR;

    curva_pv3: TVectR;
    pv3min, pv3max: NReal;
    PMax: NReal; // máximo de la curva
    k_Pmax: integer; // indice de la curva en el que alcanza el PMax.
    v_Pmax, pv3_Pmax: NReal;
    // velocidad y potencia de viento para el máximo de Potencia.
    k_InicioGen: integer; // indice en la curva donde comienza la generación.
    v_InicioGen, pv3_InicioGen: NReal;
    // valores a los cuales la generación es >= 1% de PMax.

    AreaRotor: NReal;

    // coeficientes de ajuste de una curva S del tipo P = Pmax / (1+ exp( -alfa * (v -vm ))
    // La curva se ajusta para valores entre pv3_min y la pv de la potencia máxima
    // o sea que la eventa
    curva_s_alfa, curva_s_vm: NReal;
    curva_s_errc2: NReal; // error cuadrático medio
    curva_s_cntMuestras: integer;

    constructor CreateLoadFromArchi(modelo, archi_curva: string);

    // Crea desde un string como el siguiente:
    // | 1| Vestas V112| 112| [ 26| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25; 26]| [ 26| 0; 0; 0.055598456; 0.12355212; 0.29034749; 0.52509653; 0.88957529; 1.3158301; 1.8965251; 2.5266409; 2.9220077; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 0]
    constructor CreateFromStr(strDef: string);

    constructor CreateLoadFromFile(var f: textfile);
    constructor Create_Clone(aCurvaAerogen: TCurvaAeroGen);

    procedure StoreInFile(var f: textfile);

    function P_MW(pv3: NReal): NReal;
    function pv3_of_P_MW(P_MW: NReal): NReal;

    function P_MW_Of_v(v: NReal): NReal;
    function v_of_P_MW(P_MW: NReal): NReal;



    procedure Free;

    {$IFNDEF SIN_DBCON}    class procedure CrearTablaDB(db: TDBPQCon);
    constructor CreateLoadFromDB(r: TSQLQuery);
    constructor CreateLoadFromDB_nid(db: TDBPQCon; nidcurva: integer);
    function InsertIntoDB(db: TDBPQCon): integer;
    procedure UpdateDB(db: TDBPQCon);
    {$ENDIF}

    // sirve para crear la curva de un parque por suma de curvas
    procedure SumarCurvas(Curvas: array of TCurvaAerogen);

    // Calcula los índices k_PMax y k_INicioGen y las variables asociadas.
    procedure Calc_Auxiliares;

    // Calcula los parámetros de la curva_s representativa de la generación
    // entre 0 y PMax.
    procedure Calc_curva_s;

  private
    // lo deven llamar los constructores para calcular le vector pv3
    procedure Prepararse;
  end;


// Retorna la lista con los aeros más conocidos.
function GetListaDeCurvasConocidas: TList;

implementation
uses
    uauxiliares;

constructor TCurvaAerogen.CreateFromStr(strDef: string);
var
  pal: string;
  k: integer;
begin
  inherited Create;
  setSeparadoresGlobales;
  pal:= '';

  getPalHastaSep(pal, strDef, '|');

  getPalHastaSep(pal, strDef, '|');
  nid := StrToInt(pal);

  getPalHastaSep(pal, strDef, '|');
  modelo := pal;

  getPalHastaSep(pal, strDef, '|');
  Diametro := StrToFloat(pal);

  getPalHastaSep(pal, strDef, '[');
  getPalHastaSep(pal, strDef, '|');
  NPuntos := StrToInt(pal);

  curva_P := TVectR.Create_Init(NPuntos);
  curva_v := TVectR.Create_Init(NPuntos);

  for k := 1 to NPuntos - 1 do
    curva_v.pon_e(k, NextFloat(strDef));
  getPalHastaSep(pal, strDef, ']');
  curva_v.pon_e(NPuntos, StrToFloat(pal));

  getPalHastaSep(pal, strDef, '|');
  getPalHastaSep(pal, strDef, '[');
  getPalHastaSep(pal, strDef, '|');

  for k := 1 to NPuntos - 1 do
    curva_p.pon_e(k, NextFloat(strDef));
  getPalHastaSep(pal, strDef, ']');
  curva_p.pon_e(NPuntos, StrToFloat(pal));

  setSeparadoresLocales;

  self.curva_P := curva_P;
  self.curva_v := curva_v;
  prepararse;
end;



function GetListaDeCurvasConocidas: TList;
var
  res: TList;
  aCurva: TCurvaAerogen;
begin
  res := TList.Create;
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 1| Vestas V112| 112| [ 26| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25; 26]| [ 26| 0; 0; 0.055598456; 0.12355212; 0.29034749; 0.52509653; 0.88957529; 1.3158301; 1.8965251; 2.5266409; 2.9220077; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 3.05; 0]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 2| Nordex N117| 117| [ 35| 3; 3.5; 4; 4.5; 5; 5.5; 6; 6.5; 7; 7.5; 8; 8.5; 9; 9.5; 10; 10.5; 11; 11.5; 12; 12.5; 13; 13.5; 14; 14.5; 15; 15.5; 16; 16.5; 17; 17.5; 18; 18.5; 19; 19.5; 20]| [ 35| 0.013; 0.06; 0.119; 0.193; 0.282; 0.389; 0.516; 0.665; 0.838; 1.029; 1.235; 1.449; 1.666; 1.864; 2.044; 2.206; 2.306; 2.367; 2.395; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4; 2.4]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 4| Nordex N100/2.5| 110| [ 34| 3.5; 4; 4.5; 5; 5.5; 6; 6.5; 7; 7.5; 8; 8.5; 9; 9.5; 10; 10.5; 11; 11.5; 12; 12.5; 13; 13.5; 14; 14.5; 15; 15.5; 16; 16.5; 17; 17.5; 18; 18.5; 19; 19.5; 20]| [ 34| 0.034; 0.088; 0.155; 0.237; 0.333; 0.448; 0.582; 0.738; 0.919; 1.123; 1.351; 1.604; 1.845; 2.043; 2.2; 2.321; 2.409; 2.467; 2.495; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5; 2.5]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 3| Bonus_150| 23| [ 23| 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 25; 0]| [ 23| 0; 0.0019; 0.0109; 0.0225; 0.0357; 0.0585; 0.0836; 0.1093; 0.131; 0.146; 0.1538; 0.1539; 0.1486; 0.1397; 0.1309; 0.1244; 0.1205; 0.1187; 0.1182; 0.1177; 0.1175; 0.1175; 0]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 5| Gamesa G90/2.0| 90| [ 25| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25]| [ 25| 0; 0; 0.021; 0.085; 0.197; 0.364; 0.595; 0.901; 1.275; 1.649; 1.899; 1.971; 1.991; 1.998; 2; 2; 2; 2; 2; 2; 2; 1.906; 1.681; 1.455; 1.23]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 6| ENERCON E92/2.35| 92| [ 25| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25]| [ 25| 0; 0.0036; 0.0299; 0.0982; 0.2083; 0.3843; 0.637; 0.9758; 1.4036; 1.8178; 2.0887; 2.237; 2.3; 2.35; 2.35; 2.35; 2.35; 2.35; 2.35; 2.35; 2.35; 2.35; 2.35; 2.35; 2.35]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 7| Gamesa G97/2.0| 97| [ 25| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25]| [ 25| 0; 0; 0; 0.057266811; 0.20520607; 0.44381779; 0.73492408; 1.0832972; 1.445987; 1.8468547; 1.9804772; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 1.9327549; 1.7609544; 1.5175705; 1.2121475]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 8| Vestas V80/2.0| 80| [ 25| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25]| [ 25| 0; 0; 0; 0.0663; 0.152; 0.28; 0.457; 0.69; 0.978; 1.296; 1.598; 1.818; 1.935; 1.98; 1.995; 1.999; 2; 2; 2; 2; 2; 2; 2; 2; 2]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 9| Vestas V100/1.8| 100| [ 20| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20]| [ 20| 0; 0; 0; 0.104; 0.2364; 0.4381; 0.6943; 0.9802; 1.2878; 1.6321; 1.7759; 1.8; 1.8; 1.8; 1.8; 1.8; 1.8; 1.8; 1.8; 1.8]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 10| Suzlon S95/2.1| 95| [ 26| 3.5; 4; 4.5; 5; 5.5; 6; 6.5; 7; 7.5; 8; 8.5; 9; 9.5; 10; 10.5; 11; 11.5; 12; 12.5; 13; 13.5; 14; 14.5; 15; 15.5; 16]| [ 26| 0; 0.05; 0.1; 0.2; 0.3; 0.4; 0.5; 0.625; 0.8; 0.95; 1.15; 1.33; 1.55; 1.75; 1.9; 2; 2.09; 2.1; 2.1; 2.1; 2.1; 2.1; 2.1; 2.1; 2.1; 2.1]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 11| Vestas V90/2.0| 90| [ 25| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25]| [ 25| 0; 0; 0; 0; 0.15673469; 0.35265306; 0.53877551; 0.75428571; 1.0040816; 1.2881633; 1.6212245; 1.9395918; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 12| Nordex N27/0.15| 27| [ 22| 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24]| [ 22| 0; 0.008; 0.019; 0.031; 0.055; 0.083; 0.11; 0.136; 0.16; 0.17; 0.176; 0.18; 0.175; 0.172; 0.164; 0.155; 0.15; 0.145; 0.145; 0.14; 0.135; 0.13]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 13| NuevoManantial_500kW| 40| [ 23| 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25]| [ 23| 0; 0.0063333333333; 0.0363333333333; 0.075; 0.119; 0.195; 0.2786666666667; 0.3643333333333; 0.4366666666667; 0.4866666666667; 0.5126666666667; 0.513; 0.4953333333333; 0.4656666666667; 0.4363333333333; 0.4146666666667; 0.4016666666667; 0.3956666666667; 0.394; 0.3923333333333; 0.3916666666667; 0.3913333333333; 0.3916666666667]');
  res.add(aCurva);
  aCurva := TCurvaAerogen.CreateFromStr(
    '| 14| NuevoManantial_1000kW| 59| [ 23| 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25]| [ 23| 0; 0.0126666666667; 0.0726666666667; 0.15; 0.238; 0.39; 0.5573333333333; 0.7286666666667; 0.8733333333333; 0.9733333333333; 1.0253333333333; 1.026; 0.9906666666667; 0.9313333333333; 0.8726666666667; 0.8293333333333; 0.8033333333333; 0.7913333333333; 0.788; 0.7846666666667; 0.7833333333333; 0.7826666666667; 0.7833333333333]');
  res.add(aCurva);
  Result := res;
end;

procedure TCurvaAerogen.Free;
begin
  curva_P.Free;
  curva_v.Free;
  curva_pv3.Free;
  inherited Free;
end;

procedure TCurvaAerogen.Prepararse;
var
  i: integer;
begin
  AreaRotor := pi * sqr(Diametro / 2);
  NPuntos := self.curva_v.n;
  curva_pv3 := TVectR.Create_Init(NPuntos);
  //bucle
  for i := 1 to NPuntos do
    curva_pv3.pon_e(i, pv3Ofv(curva_v.e(i), ro_BASE));
  curva_pv3.MinMax(i, i, pv3min, pv3max);
  calc_auxiliares;
end;

constructor TCurvaAerogen.CreateLoadFromArchi(modelo, archi_curva: string);
var
  f: textfile;
  i: integer;
  p, v: NReal;

begin
  inherited Create;
  setSeparadoresGlobales;

  nid := -1; // indicamos que todavía no tiene nid

  self.modelo := modelo;

  assignfile(f, archi_curva);
  reset(f);
  system.readln(f, Diametro);
  system.readln(f, NPuntos);

  curva_P := TVectR.Create_Init(NPuntos);
  curva_v := TVectR.Create_Init(NPuntos);
  //bucle
  for i := 1 to NPuntos do
  begin
    system.readln(f, v, p);
    curva_v.pon_e(i, v);
    curva_P.pon_e(i, p / 1000.0);
  end;
  closefile(f);
  setSeparadoresLocales;
  Prepararse;
end;


constructor TCurvaAerogen.CreateLoadFromFile(var f: textfile);
begin
  inherited Create;
  setSeparadoresGlobales;
  system.readln(f, nid);
  system.readln(f, modelo);
  system.readln(f, diametro);
  curva_v := TVectR.CreateLoadFromFile(f);
  curva_P := TVectR.CreateLoadFromFile(f);
  setSeparadoresLocales;
  Prepararse;
end;

constructor TCurvaAerogen.Create_Clone(aCurvaAerogen: TCurvaAeroGen);
begin
  inherited Create;
  nid := aCurvaAerogen.nid;
  modelo := aCurvaAerogen.modelo;
  diametro := aCurvaAerogen.Diametro;
  curva_v := TVectR.Create_Clone(aCurvaAerogen.curva_v);
  curva_P := TVectR.Create_Clone(aCurvaAerogen.curva_P);
  Prepararse;
end;

{$IFNDEF SIN_DBCON}
constructor TCurvaAerogen.CreateLoadFromDB(r: TSQLQuery);
begin
  inherited Create;
  nid := r.FieldByName('nid').AsInteger;
  modelo := r.FieldByName('modelo').AsString;
  diametro := r.FieldByName('diametro').AsFloat;
  curva_v := TVectR.Create_unserialize(r.FieldByName('curva_v').AsString);
  curva_P := TVectR.Create_unserialize(r.FieldByName('curva_P').AsString);
  prepararse;
end;

constructor TCurvaAerogen.CreateLoadFromDB_nid(db: TDBPQCon; nidcurva: integer);
var
  r: TSQLQuery;
begin
  r := DB.query('SELECT * FROM curvas_aerogen WHERE nid =' + IntToStr(nidcurva));
  CreateLoadFromDB(r);
  r.Free;
end;

function TCurvaAerogen.InsertIntoDB(db: TDBPQCon): integer;
var
  nid: integer;
  s: string;
begin
  nid := DB.nextval('curvas_aerogen');
  s := 'INSERT INTO curvas_aerogen ( nid, modelo, diametro, curva_v, curva_P ) VALUES (';
  s := s + IntToStr(nid) + ', ''' + modelo + ''', ''' + FloatToStr(
    diametro) + ''', ''' + curva_v.serialize + ''', ''' + curva_P.serialize + ''' );';
  DB.exec(s);
  Result := nid;
end;

procedure TCurvaAerogen.UpdateDB(db: TDBPQCon);
var
  s: string;
begin
  s := 'UPDATE curvas_aerogen SET modelo= ''';
  s := s + modelo + ''', diametro= ''' + FloatToStr(diametro) +
    ''', curva_v=''' + curva_v.serialize + ''', curva_P=''' +
    curva_P.serialize + ''' WHERE nid =' + IntToStr(nid) + ';';
  DB.exec(s);
end;

class procedure TCurvaAerogen.CrearTablaDB(db: TDBPQCon);
begin
  DB.exec('DROP TABLE IF EXISTS curvas_aerogen');
  DB.exec('CREATE TABLE curvas_aerogen ( nid serial PRIMARY KEY, ' +
    'modelo VARCHAR(100), diametro double precision, curva_v text, curva_P text ); ');
  DB.exec('CREATE UNIQUE INDEX modelo ON curvas_aerogen ( modelo ); ');
end;

{$ENDIF}

procedure TCurvaAerogen.StoreInFile(var f: textfile);
begin
  setSeparadoresGlobales;
  writeln(f, nid);
  writeln(f, modelo);
  writeln(f, diametro);
  curva_v.StoreInFile(f);
  curva_P.StoreInFile(f);
  setSeparadoresLocales;
end;


function TCurvaAerogen.P_MW(pv3: NReal): NReal;
var
  ind: NReal;
begin
  if (pv3 < pv3min) or (pv3 > pv3max) then
  begin
    Result := 0;
    exit;
  end;
  ind := curva_pv3.inv_interpol(pv3);
  Result := curva_P.interpol(ind);
end;

function TCurvaAerogen.pv3_of_P_MW(P_MW: NReal): NReal;
var
  ind, pv3: NReal;
begin
  if P_MW < 0 then
  begin
    Result := 0;
    exit;
  end;

  if P_MW > PMax then
  begin
    Result := pv3max;
    exit;
  end;
  ind := curva_P.inv_interpol(P_MW);
  pv3 := curva_pv3.interpol(ind);
  Result := pv3;
end;




function TCurvaAerogen.P_MW_Of_v(v: NReal): NReal;
var
  pv3: NReal;
begin
  pv3 := pv3Ofv(v, ro_base);
  Result := P_MW(pv3);
end;

function TCurvaAerogen.v_of_P_MW(P_MW: NReal): NReal;
var
  pv3: NReal;
begin
  pv3 := pv3_of_P_MW(P_MW);
  Result := vofpv3(pv3, ro_base);
end;

// sirve para crear la curva de un parque por suma de curvas
procedure TCurvaAerogen.SumarCurvas(Curvas: array of TCurvaAerogen);
var
  k, j: integer;
  aCurva: TCurvaAerogen;
begin
  for j := 0 to high(Curvas) do
  begin
    aCurva := Curvas[j];
    for k := 1 to curva_pv3.n do
      curva_P.acum_e(k, aCurva.P_MW(curva_pv3.e(k)));
  end;
  Calc_Auxiliares;
end;

procedure TCurvaAerogen.Calc_Auxiliares;
var
  ind: integer;
  PUmbral: NReal;

begin
  PMax := curva_P.maxVal;
  ind := 1;
  while abs(curva_P.e(ind) - PMax) > 1e-10 do
    Inc(ind);
  k_Pmax := ind;
  v_Pmax := curva_v.e(ind);
  pv3_Pmax := curva_pv3.e(ind);


  PUmbral := PMax * 0.01;
  ind := 1;
  while curva_P.e(ind) < PUmbral do
    Inc(ind);
  k_InicioGen := ind;
  v_InicioGen := curva_v.e(ind);
  pv3_InicioGen := curva_pv3.e(ind);

  Calc_curva_s;

end;

procedure TCurvaAerogen.Calc_curva_s;
var
  y: TVectR;
  x: NReal;
  v01, v09: NReal;
  a, b: NReal;
  k: integer;
begin
  y := TVectR.Create_INit(curva_P.n);
  v01 := v_InicioGen + 1.1;
  v09 := v_Pmax * 0.9;
  for k := k_InicioGen to k_Pmax do
  begin
    x := curva_v.e(k);
    if (v01 <= x) and (x < v09) then
      y.pon_e(k, ln(PMax / curva_P.e(k) - 1))
    else
      y.pon_e(k, 0);
  end;
  a:= 0; b:= 0; // solo para que no de warning
  curva_s_errc2 := y.AproximacionLinealFiltrada(a, b, curva_v, v01,
    v09, curva_s_cntMuestras);
  curva_s_alfa := -a;
  curva_s_vm := b / curva_s_alfa;
  y.Free;
end;

end.
