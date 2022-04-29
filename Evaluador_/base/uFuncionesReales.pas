unit uFuncionesReales;
{xDEFINE DEBUG_SOLARPV}

interface

uses
  Math, xMatDefs, matreal, uCosa, uglobs;

type


  TFRenR = class(TCosa)
    function fval(x: NReal): NReal; virtual; abstract;
  end;

  TFR2enR = class(TCosa)
    function fval(x1, x2: NReal): NReal; virtual; abstract;
  end;

  // Esta función interpola en el vector yval definido
  // sobre un rango xmin, xmax. Se supone que el primer punto
  // del vector corresponde al valor f(xmin) y el último a f(xmax)

  { TFVectR }

  TFVectR = class(TFRenR)
  public
    xmin, xmax: NReal;

    (**************************************************************************)
    (*               A T R I B U T O S   P E R S I S T E N T E S              *)
    (**************************************************************************)

    vector: TVectR;
    dx: NReal;

    (**************************************************************************)
    constructor Create(capa: integer; yval: TDAOfNReal; xxmin, xxmax: NReal); overload;
    constructor Create(capa: integer; nPuntos: integer; xxmin, xxmax: NReal); overload;
    function fval(x: NReal): NReal; override;

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    procedure inicializar;
    function Create_Clone(Catalogo: TCatalogo; idHilo: integer): TCosa; override;
    procedure Free; override;
  end;

  // vector de funciones VP por dirección
  TArrayOfFVectR = array of TFVectR;


  // retorna f( xmult * x )
  TFf_xmult = class(TFRenR)
  public
    f: TFRenR;
    xmult: NReal;
    constructor Create(capa: integer; f: TFRenR; xxmult: NReal);
    function fval(x: NReal): NReal; override;
  end;


  // retorna f( xmult * x )
  // Carga Buff[ p_kPaso^] el resultado.
  TFf_xmult_Buffer = class(TFRenR)
  public
    f: TFRenR;
    xmult: NReal;
    pBuff: PDAOfNReal;
    p_kPaso: PWord;
    constructor Create(capa: integer; f: TFRenR; xxmult: NReal;
      pxBuff: PDAOfNReal; xp_kPaso: PWord);
    function fval(x: NReal): NReal; override;
  end;


  // si iFiltro = ipMatchFiltro^
  // retorna f( xmult[ selector^ ] * x )
  // donde xmult es el vector xxMult multiplicado por aMult
  // si iFiltro <> ipMatchFiltro^ retorna CERO.
  TFf_xmult_conselector = class(TFRenR)
  public
    f: TFRenR;
    xmult: TDAOfNreal;
    pSelector: PWord;
    iFiltro: integer;
    pMatchFiltro: PDAOfNInt;
    ipMatchFiltro: PWord;
    aMult: NReal;

    constructor Create(capa: integer; f: TFRenR; xxMult: TDAOfNreal;
      aMult: NReal; xpSelector: PWord; iFiltro: integer; pMatchFiltro: PDAOfNInt;
      ipMatchFiltro: PWord);

    function fval(x: NReal): NReal; override;
  end;


  // Retorna f( xmult[ selector^ ] * x )
  // Carga Buff[ p_kPaso^] el resultado.
  // donde xmult es el vector xxMult multiplicado por aMult
  TFf_xmult_conSelectorYBuffer = class(TFRenR)
  public
    f: TFRenR;
    xmult: TDAOfNreal;
    pSelector: PWord;
    p_kPaso: PWord;
    pBuff: pDAOfNreal;
    aMult: NReal;

    constructor Create(capa: integer; f: TFRenR; xxMult: TDAOfNreal;
      aMult: NReal; xpSelector: PWord; pxBuff: PDAOfNReal; xp_kPaso: PWord);

    function fval(x: NReal): NReal; override;
  end;




  // si iFiltro = ipMatchFiltro^
  // retorna f( xmult[ selector^ ] * x )
  // donde xmult es el vector xxMult multiplicado por aMult
  // si iFiltro <> ipMatchFiltro^ retorna CERO.
  // antes de calcular compone el vector de velocidad en base a los dos bornes
  TFf_xmult_conselector_vxy = class(TFR2enR)
  public
    f: TArrayOfFVectR;
    xfPerdidasAerodinamicas: TDAOfNReal;
    pSelector: PWord;
    iFiltro: integer;
    pMatchFiltro: PDAOfNInt;
    ipMatchFiltro: PWord;
    aMult: NReal;

    constructor Create(capa: integer; f: TArrayOfFVectR;
      xxfPerdidasAerodinamicas: TDAOfNReal; aMult: NReal; xpSelector: PWord;
      iFiltro: integer; pMatchFiltro: PDAOfNInt; ipMatchFiltro: PWord);

    // vy > 0, vx = 0 Viento desde el Norte
    // vy = vx > 0 Viento desde el Nor-Este
    // vy = 0 vx > 0 Viento desde el Este
    // vy < 0 vx > 0 Viento desde el Sur Este
    // vy < 0 vx = 0 Viento desde el Sur
    // vy = vx < 0 Viento desde Sur-Oeste
    // vy = 0, vx < 0 VIento desde el Oeste
    // vy > 0, vx < 0 Viento desde el Nor-Oeste
    function fval(vx, vy: NReal): NReal; override;
  end;




  // retorna f( xmult[ selector^ ] * x )
  // donde xmult es el vector xxMult multiplicado por aMult
  // antes de calcular compone el vector de velocidad en base a los dos bornes
  // Carga en Buff[ p_kBuff^ ] con el resultado
  TFf_xmult_ConSelectorYBuffer_vxy = class(TFR2enR)
  public
    f: TArrayOfFVectR;
    xfPerdidasAerodinamicas: TDAOfNReal;
    pSelector: PWord;
    aMult: NReal;
    pBuff: PDAOfNReal;
    p_kBuff: pWord;

    constructor Create(capa: integer; f: TArrayOfFVectR;
      xxfPerdidasAerodinamicas: TDAOfNReal; aMult: NReal; xpSelector: PWord;
      pxBuff: PDAOfNReal; xp_kBuff: PWord);

    // vy > 0, vx = 0 Viento desde el Norte
    // vy = vx > 0 Viento desde el Nor-Este
    // vy = 0 vx > 0 Viento desde el Este
    // vy < 0 vx > 0 Viento desde el Sur Este
    // vy < 0 vx = 0 Viento desde el Sur
    // vy = vx < 0 Viento desde Sur-Oeste
    // vy = 0, vx < 0 VIento desde el Oeste
    // vy > 0, vx < 0 Viento desde el Nor-Oeste
    function fval(vx, vy: NReal): NReal; override;
  end;




  TFRenR_GranjaSolar = class(TFRenR)//se implementa para el actor solar PV
  public
    globs: TGlobs;
    pFicha_pa: Pointer;
    //   pIndice_:Pointer;
    borneIndiceClaridad: string;

    //variables auxiliares para el calculo de fval

    iPoste: integer;
    valp: NReal;
    indice_kt: NReal;

    Ics: NReal; //constante solar horaria (kW/m2)
    Ih: NReal; //irradiación (kW/m2)
    Ih0: NReal; //irradiación extraterrestre sobre un plano horizontal (kW/m2)
    Fn: NReal; //factor orbital
    delta: NReal; //declinación solar
    gamma: NReal; // Fracción del año en Radianes entre 0 y 2pi.
    n: integer; //ordinal-día del año
    w: NReal;
    //angulo horario. Fracción del día en radianes de -pi a pi  con el CERO en el medio dia solar.
    E: NReal;   //constante de la ecuación del tiempo en minutos
    tUTC: NReal;   //tiempo estándar del observador UTC-3 para Uruguay
    LUTC: NReal;
    //longitud del meridiano central del huso horario relevante, -45° para Uuruguay
    latitud_rad: NReal;  //latitud en radianes
    Ii: NReal;   //radiacion plano inclinado
    Ibi: NReal;  //componente directa
    Idic: NReal;  //componente difusa del cielo
    Idir: NReal;  //componete difusa reflejada
    rb: Nreal;    //razón directa
    fd: NReal;    //fracción difusa instantánea
    Idh, Ibh: NReal;
    //componentes directas y difusas de la radiacion global sobre la superficie
    tb: NReal;  //indice de anisotropia
    cos_fi: NReal;  //coseno del ángulo de incidencia
    cos_fi_z: NReal; //coseno del ángulo cenital
    inclinacion_rad: NReal;
    azimut_rad: NReal;

    constructor Create(capa: integer; pFicha_pa: Pointer;
    //  pIndice:Pointer;
      borneIndiceClaridad: string; globs: TGlobs); overload;
    function fval(x: NReal): NReal; override;
  end;

  TFRenR_ComprasArg = class(TFRenR)
    //JFP 23/11/2015: se implementa para luego postizar compras de Argentina desde una fuente

    constructor Create(capa: integer); overload;

    function fval(x: NReal): NReal; override;

  end;



procedure AlInicio;
procedure AlFinal;

implementation


uses
  usolarpv;

{$IFDEF DEBUG_SOLARPV}
var
  fdebug_solarpv: textfile;

 {$ENDIF}

//-------------------
// Métodos de TFVectR
//===================

procedure TFVectR.inicializar;
begin
  if vector.n > 0 then
    dx := (xmax - xmin) / (vector.n - 1);
end;

constructor TFVectR.Create(capa: integer; yval: TDAOfNReal; xxmin, xxmax: NReal);
begin
  inherited Create(capa);
  vector := TVectR.Create_FromDAofR(yval);
  xmin := xxmin;
  xmax := xxmax;
  inicializar;
end;

constructor TFVectR.Create(capa: integer; nPuntos: integer; xxmin, xxmax: NReal);
var
  yval: TDAofNReal;
begin
  setlength(yval, nPuntos);
  Create(capa, yval, xxmin, xxmax);
end;


function TFVectR.Create_Clone(Catalogo: TCatalogo; idHilo: integer): TCosa;
var
  vt: TDAOfNReal;
  k: integer;
  res: TFVectR;
begin
  setlength(vt, vector.n);
  for k := 0 to high(vt) do
    vt[k] := vector.e(k + 1);
  res := TFVectR.Create(capa, vt, xmin, xmax);
  res.capa := self.capa;
  Result := res;
end;



function TFVectR.Rec: TCosa_RecLnk;
begin
  Result := inherited Rec;
  Result.addCampoDef('xmin', xmin);
  Result.addCampoDef('xmax', xmax);
  Result.addCampoDef('vector', vector);
end;

procedure TFVectR.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFVectR.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
  inicializar;
end;

function TFVectR.fval(x: NReal): NReal;
var
  kr: NReal;
begin
  kr := (x - xmin) / dx + 1;
  Result := vector.interpol(kr);
end;

procedure TFVectR.Free;
begin
  vector.Free;
  inherited Free;
end;

constructor TFf_xmult.Create(capa: integer; f: TFRenR; xxmult: NReal);
begin
  inherited Create(capa);
  self.f := f;
  xmult := xxmult;
end;

function TFf_xmult.fval(x: NReal): NReal;
begin
  Result := f.fval(x * xmult);
end;



constructor TFf_xmult_Buffer.Create(capa: integer; f: TFRenR;
  xxmult: NReal; pxBuff: PDAOfNReal; xp_kPaso: PWord);
begin
  inherited Create(capa);
  self.f := f;
  xmult := xxmult;
  pBuff := pxBuff;
  p_kPaso := xp_kPaso;
end;

function TFf_xmult_Buffer.fval(x: NReal): NReal;
var
  res: NReal;
begin
  res := f.fval(x * xmult);
  pBuff^[p_kPaso^] := res;
  Result := res;

end;



(******************************************************)

constructor TFf_xmult_conselector.Create(capa: integer; f: TFRenR;
  xxMult: TDAOfNreal; aMult: NReal; xpSelector: PWord; iFiltro: integer;
  pMatchFiltro: PDAOfNInt; ipMatchFiltro: PWord);

var
  i: integer;

begin
  inherited Create(capa);
  self.f := f;
  self.aMult := aMult;
  setlength(xmult, length(xxmult));
  for i := 0 to high(xxmult) do
    xmult[i] := xxmult[i];
  pSelector := xpSelector;
  Self.iFiltro := iFiltro;
  Self.pMatchFiltro := pMatchFiltro;
  Self.ipMatchFiltro := ipMatchFiltro;
end;

function TFf_xmult_conselector.fval(x: NReal): NReal;
var
  kHora: integer;
begin
  kHora := ipMatchFiltro^;
  if kHora > length(pMatchFiltro^) then
    kHora := kHora mod length(pMatchFiltro^);
  if iFiltro = pMatchFiltro^[kHora] then
    Result := aMult * f.fval(x * xmult[pSelector^ - 1])
  else
    Result := 0;
end;



constructor TFf_xmult_conSelectorYBuffer.Create(capa: integer; f: TFRenR;
  xxMult: TDAOfNreal; aMult: NReal; xpSelector: PWord; pxBuff: PDAOfNReal;
  xp_kPaso: PWord);
var
  i: integer;
begin
  inherited Create(capa);
  self.f := f;
  self.aMult := aMult;
  setlength(xmult, length(xxmult));
  for i := 0 to high(xxmult) do
    xmult[i] := xxmult[i];
  pSelector := xpSelector;
  self.pBuff := pxBuff;
  Self.p_kPaso := xp_kPaso;
end;


function TFf_xmult_conSelectorYBuffer.fval(x: NReal): NReal;
var
  res: NReal;
begin
  res := aMult * f.fval(x * xmult[pSelector^ - 1]);
  pBuff^[p_kPaso^] := res;
  Result := res;
end;

(*********************************)

constructor TFf_xmult_conselector_vxy.Create(capa: integer; f: TArrayOfFVectR;
  xxfPerdidasAerodinamicas: TDAOfNReal; aMult: NReal; xpSelector: PWord;
  iFiltro: integer; pMatchFiltro: PDAOfNInt; ipMatchFiltro: PWord);

var
  i: integer;

begin
  inherited Create(capa);
  self.f := f;
  self.aMult := aMult;

  setlength(xfPerdidasAerodinamicas, length(xxfPerdidasAerodinamicas));
  for i := 0 to high(xxfPerdidasAerodinamicas) do
    xfPerdidasAerodinamicas[i] := xxfPerdidasAerodinamicas[i];

  pSelector := xpSelector;
  Self.iFiltro := iFiltro;
  Self.pMatchFiltro := pMatchFiltro;
  Self.ipMatchFiltro := ipMatchFiltro;
end;

function TFf_xmult_conselector_vxy.fval(vx, vy: NReal): NReal;
var
  kHora: integer;
  iang: integer;
  v: NReal;
  n: integer;
  ralfa: NReal;

begin
  v := sqrt(sqr(vx) + sqr(vy)); // velocidad

  n := length(xfPerdidasAerodinamicas);

  if abs(vy) < 1e-4 then
  begin
    //rch@20140309 bugfix
    // antes simplemente ponía iang:= 0;
    // esto parecia estar mal, si la componente NoreteSur era CERO
    // imponía viento del Norte cuando lo correcto es viento del Este
    // o del Oeste según la componente vx
    if vx > 0 then
      iang := 4  // Viento del Este
    else
      iang := 12; // Viento del Oeste
  end
  else
  begin
    ralfa := arctan(vx / vy) / (2 * pi);
    if vy > 0 then
      iang := trunc(ralfa * n + 0.49)
    else
      iang := trunc((0.5 + ralfa) * n + 0.49);
  end;

  while iang < 0 do
    iang := iang + n;

  //  writeln( 'vx: ', vx: 8:2, ', vy: ', vy: 8:2, ', iang: ', iang );

  kHora := ipMatchFiltro^;
  if kHora > length(pMatchFiltro^) then
    kHora := kHora mod length(pMatchFiltro^);

  if iFiltro = pMatchFiltro^[kHora] then
    Result := aMult * f[iang].fval(v * xfPerdidasAerodinamicas[iang])
  else
    Result := 0;
end;


(*---------------------------------------------
   Métodos de TFf_xmult_ConSelectorYBuffer_vxy
===============================================*)


constructor TFf_xmult_ConSelectorYBuffer_vxy.Create(capa: integer;
  f: TArrayOfFVectR; xxfPerdidasAerodinamicas: TDAOfNReal; aMult: NReal;
  xpSelector: PWord; pxBuff: PDAOfNReal; xp_kBuff: PWord);
var
  i: integer;

begin
  inherited Create(capa);
  self.f := f;
  self.aMult := aMult;

  setlength(xfPerdidasAerodinamicas, length(xxfPerdidasAerodinamicas));
  for i := 0 to high(xxfPerdidasAerodinamicas) do
    xfPerdidasAerodinamicas[i] := xxfPerdidasAerodinamicas[i];

  pSelector := xpSelector;

  pBuff := pxBuff;
  p_kBuff := xp_kBuff;
end;

function TFf_xmult_ConSelectorYBuffer_vxy.fval(vx, vy: NReal): NReal;
var
  res: NReal;
  iang: integer;
  v: NReal;
  n: integer;
  ralfa: NReal;

begin
  v := sqrt(sqr(vx) + sqr(vy)); // velocidad

  n := length(xfPerdidasAerodinamicas);

  if abs(vy) < 1e-4 then
  begin
    if vx > 0 then
      iang := 4  // Viento del Este
    else
      iang := 12; // Viento del Oeste
  end
  else
  begin
    ralfa := arctan(vx / vy) / (2 * pi);
    if vy > 0 then
      iang := trunc(ralfa * n + 0.49)
    else
      iang := trunc((0.5 + ralfa) * n + 0.49);
  end;

  while iang < 0 do
    iang := iang + n;


  res := aMult * f[iang].fval(v * xfPerdidasAerodinamicas[iang]);

  pBuff^[p_kBuff^] := res;
  Result := res;
end;




(**** métodos de GranjaSolar ****)

constructor TFRenR_GranjaSolar.Create(capa: integer; pFicha_pa: Pointer;
  // pIndice:Pointer ;
  borneIndiceClaridad: string; globs: TGlobs);
begin
  inherited Create(capa);
  self.pFicha_pa := pFicha_pa;
  //  self.pIndice_:=pIndice;
  self.borneIndiceClaridad := borneIndiceClaridad;
  self.globs := globs;
end;



function TFRenR_GranjaSolar.fval(x: NReal): NReal;

var
  pa: TFichaSolarPV;

begin
  {$IFDEF DEBUG_SOLARPV}
  x := 1;
  {$ENDIF}

  pa := TFichaSolarPV(pFicha_pa^);
  indice_kt := x;

  Ics := 1.367;
  tUTC := globs.HoraDeInicioDelPaso + 0.5;
  // Posicionamos en la mitad de la hora a la que corresponde el sorteo.
  LUTC := 15 * globs.husoHorario_UTC;
  n := globs.DiaDelAnioInicioDelPaso;
  latitud_rad := pa.latitud * 2 * pi / 360;

  gamma := 2 * pi * (n - 1) / 365.2425;
  delta := 0.006918 - 0.399912 * cos(gamma) + 0.070257 *
    sin(gamma) - 0.006758 * cos(2 * gamma) + 0.000907 * sin(2 * gamma) - 0.002697 *
    cos(3 * gamma) + 0.00148 * sin(3 * gamma);
  Fn := 1 + 0.033 * cos(2 * pi * n / 365.2425);

  E := 229.18 * (0.0000075 + 0.001868 * cos(gamma) - 0.032077 * sin(gamma) -
    0.014615 * cos(2 * gamma) - 0.04089 * sin(2 * gamma));
  w := pi / 12 * (tUTC - 12 + (pa.longitud - LUTC) / 15 + E / 60);
  Ih0 := Ics * Fn * (cos(delta) * cos(latitud_rad) * cos(w) + sin(delta) * sin(latitud_rad));

  if Ih0 < 0 then
    Ih0 := 0;

  Ih := Ih0 * indice_kt;   //radiacion global sobre la superficie

  //calculo de la radiacion sobre plano inclinado
  //Ii=Ibi+Idic+Idir

  //calculo la fraccion difusa instantánea

  if (indice_kt <= 0.22) then
    fd := 1 - 0.09 * indice_kt
  else
  if ((0.22 < indice_kt) and (indice_kt <= 0.8)) then
    fd := 0.9511 - 0.1604 * indice_kt + 4.388 * Math.power(indice_kt, 2) -
      16.638 * Math.power(indice_kt, 3) + 12.336 * Math.power(indice_kt, 4)
  else
    fd := 0.165;

  Idh := fd * Ih;
  Ibh := Ih - Idh;

  //calculo Ibi usando la fórmula para una orientación cualquiera
  inclinacion_rad := pa.inclinacion * 2 * pi / 360;
  azimut_rad := pa.azimut * 2 * pi / 360;

  cos_fi := (sin(delta) * sin(latitud_rad) + cos(delta) * cos(latitud_rad) * cos(w)) *
    cos(inclinacion_rad) + ((sin(delta) * cos(latitud_rad) - cos(delta) * sin(latitud_rad) * cos(w)) *
    cos(azimut_rad) + cos(delta) * sin(w) * sin(azimut_rad)) * sin(inclinacion_rad);

  cos_fi_z := sin(delta) * sin(latitud_rad) + cos(delta) * cos(latitud_rad) * cos(w);

  rb := cos_fi / cos_fi_z;

  Ibi := Ibh * rb;

  //calculo de Idic con modelo Hay y Davies

  tb := (1 - fd) * indice_kt;
  Idic := rb * tb * Idh + (1 - tb) * Idh * ((1 + cos(inclinacion_rad)) / 2);

  //calculo de Idir

  Idir := Ih * pa.reflexion_suelo * ((1 - cos(inclinacion_rad)) / 2);

  //inclinacion sobre plano inclinado
  Ii := Ibi + Idic + Idir;

  if Ii < 0 then
    Ii := 0;

  //calculo la potencia recibida
  valp := Ii * pa.fIradToPot; //paso a MWh
  pa.PMaxDisponiblePorModulo := min(valp, pa.PMax_Inversor );

  {$IFDEF DEBUG_SOLARPV}
  writeln(fdebug_solarpv, x, #9, globs.HoraDeInicioDelPaso, #9,
    globs.DiaDelAnioInicioDelPaso, #9, pa.PMaxDesp);
   {$ENDIF}

  Result := pa.PMaxDisponiblePorModulo;
end;

(**** métodos de ComprasArg ****)

constructor TFRenR_ComprasArg.Create(capa: integer);
begin
  inherited Create(capa);
end;

function TFRenR_ComprasArg.fval(x: NReal): NReal;
begin
  Result := x;
end;


(*********************************)
procedure AlInicio;
begin
  registrarClaseDeCosa(TFVectR.ClassName, TFVectR);
  registrarClaseDeCosa(TFf_xmult.ClassName, TFf_xmult);

  {$IFDEF DEBUG_SOLARPV}
  assignfile(fdebug_solarpv, 'fdebug_solarpv.xlt');
  rewrite(fdebug_solarpv);
  writeln(fdebug_solarpv, 'x', #9, 'globs.HoraDeInicioDelPaso', #9,
    'globs.DiaDelAnioInicioDelPaso', #9, 'pa.PMaxDesp');
  {$ENDIF}

end;

procedure AlFinal;
begin
  {$IFDEF DEBUG_SOLARPV}
  closefile(fdebug_solarpv);
  {$ENDIF}
end;




end.
