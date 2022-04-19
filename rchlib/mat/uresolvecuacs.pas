(*
 febrero del 2008, rch@todo.com.uy
 =================================

 La idea es facilitar la resolución de los problemas que se describen
 por un conjnto de ecuaciones que vinculan un conjunto de variables-parámetros.

 Normalmente elegimos algunas de las variables como parámetros, les damos
 valores y queremos conocer el resultado de las variables dejadas libres.

 Vamos a suponer que las ecuaciones son funciones de RN->R y que
 deben valer 0 en la solución.

 fi( x1, ..... xn ) = 0; i= 1... m

 Esto es tenemos m ecuaciones y n variables.
 Suponemos n> m y por lo tanto de las n variables, hay n-m que se
 deben fijar para que queden m libres.

 Supondremos también conocido el gradiente de cada fi y que
 lo tenemos mediante funciones gij( x1, .... xn ) de RN->R
 en donde el i identifica la función fi y j la variable respecto de la
 que derivamos, de forma que gij= dfi/dxj


 Al crear el problema, le indicamos la cantidad de ecuaciones (mEcuaciones) y la
 cantidad de variables (nVariables). La cantidad de variables debe ser superior
 o igual a la cantidad de ecuaciones.

 Las ecuaciones fi y sus gradientes gij se suministran llamando a las funciones
 inscribirEcuacion e inscribirDerivada

 Si nVariables > mEcuaciones, se deberá elegir nVariables-mEcuaciones de las
 variables para ser consideradas como parámetros.

 Los valores inciales de cada variable, y si la misma debe ser considerada
 como "libre" o "fija" se realiza mediante llamadas a la función
 DefinirVariable.

 Para resolver el problema se debe llamar a la función
 BuscarSolucion_NewtonRapson

 Estas funciones retornan TRUE si salieron logrando converger a una solución
 de acuerdo al error especificado.

 El método de NewtonRapson considera la función vectorial definida por las fi
 e intenta anularla usando el desarrollo de Taylor de F(x)
 F(x+dx) = F(x) + J.dx + o(2)
 para que F(x+dx)= 0 tenemos que dx= - Inv(J) F(x)
 Con eso calculamos el siguiente valor de x como x= x + dx
 Si esa sucesión converge llegaremos a una solución. Si el valor inicial
 x está próximo a solución, el algoritmo converge, si estamos lejos puede
 que no converja.
 El algoritmo es un poco modificado haciendo x= x + alfa *dx donde alfa
 comienza con 1 pero si Abs(F(x+dx) ) > Abs(F(x)) reducimos alfa hasta lograr
 que se cumpla que con el nuevo x estamos más cerca de la solución.
 Observar que este método incluye la inversión de la matriz J. Si durante
 la iteración se llega a un punto donde no existe la inversa de J(x)
 el algoritmo sale retornando false.




*)
unit uresolvecuacs;

interface

uses
  SysUtils, xMatDefs, MatReal, uSparseMatReal, cronomet;

type
  TFunc_iRNenR = function(i: integer; x: TVectR): NReal;
  TFunc_ikRNenR = function(i, k: integer; x: TVectR): NReal;

  TProblema = class
    mEcuaciones, nVariables: integer;
    fi: array of TFunc_iRNenR;
    gij: array of array of TFunc_ikRNEnR;
    xfijadas: array of boolean;
    xvalores, xiniciales, xmaximos, xminimos: TVectR;
    cajaActiva: array of boolean; // indica para cada variable si las
    // restricciones de caja estan activas
    ivx: array of integer; // indices de las variables libres
    errMsg: string;


    constructor Create(mEcuaciones, nVariables: integer);
    procedure Free; virtual;
    procedure Reset;
    procedure DefinirVariable(j: integer; xmin, xmax, xinicial: NReal;
      EsFija: boolean); overload;
    procedure DefinirVariable(j: integer; xinicial: NReal;
      EsFija: boolean); overload;

    procedure InscribirEcuacion(fi: TFunc_iRNenR; i: integer);
    procedure InscribirDerivada(gij: TFunc_ikRNenR; i, j: integer);


    function BuscarSolucion_NewtonRapson(maxErr: NReal; NMaxIter: integer;
      flg_CONTROLAR_PASO: boolean; var err: NReal; var cnt_iters: integer): boolean;



    procedure IniciarResolucion; virtual;

    // copia los valores de las variables libres desde el vector xr hacia el
    // vector xvalores, dejando fijos los parámetros elegidos como fijos.
    procedure copy_xrToxvalores(xr: TVectR); virtual;

    // calcula el Jacobiano del sistema para el valor guardado en xvalores
    procedure Calc_JRed(var JRed: TMatR); virtual;
    // calcula el valor de las ecuaciones para el valor guardado en xvalores
    procedure Calc_F(var fval: TVectR); virtual;

  end;




implementation



function fnula_i(i: integer; x: TVectR): NReal;
begin
  Result := 0;
end;

function fnula_ik(i, k: integer; x: TVectR): NReal;
begin
  Result := 0;
end;


procedure TProblema.InscribirEcuacion(fi: TFunc_iRNenR; i: integer);
begin
  self.fi[i] := fi;
end;

procedure TProblema.InscribirDerivada(gij: TFunc_ikRNenR; i, j: integer);
begin
  self.gij[i][j] := gij;
end;

procedure TProblema.Reset;
var
  k: integer;
begin
  for k := 1 to nVariables do
    xfijadas[k] := False;
end;

procedure TProblema.DefinirVariable(j: integer; xmin, xmax, xinicial: NReal;
  EsFija: boolean);
begin
  xfijadas[j] := EsFija;
  xiniciales.pv[j] := xinicial;
  xminimos.pv[j] := xmin;
  xmaximos.pv[j] := xmax;
  cajaActiva[j] := True;
end;

procedure TProblema.DefinirVariable(j: integer; xinicial: NReal;
  EsFija: boolean);
begin
  xfijadas[j] := EsFija;
  xiniciales.pv[j] := xinicial;
  xminimos.pv[j] := 0;
  xmaximos.pv[j] := 0;
  cajaActiva[j] := False;
end;

constructor TProblema.Create(mEcuaciones, nVariables: integer);
var
  i, j: integer;
begin
  inherited Create;
  Self.mEcuaciones := mEcuaciones;
  Self.nVariables := nVariables;
  setlength(fi, mEcuaciones + 1);
  setlength(gij, mEcuaciones + 1);

  for i := 1 to mEcuaciones do
  begin
    fi[i] := fnula_i;
    setlength(gij[i], nVariables + 1);
    for j := 1 to nVariables do
      gij[i][j] := fnula_ik;
  end;
  setlength(ivx, mEcuaciones + 1);
  setlength(xfijadas, nVariables + 1);
  setlength(cajaActiva, nVariables + 1);
  for i := 1 to nVariables do
  begin
    xfijadas[i] := False;
    cajaActiva[i] := False;
  end;
  xvalores := TVectR.Create_Init(nVariables);
  xiniciales := TVectR.Create_Init(nVariables);
  xminimos := TVectR.Create_Init(nVariables);
  xmaximos := TVectR.Create_Init(nVariables);

end;

procedure TProblema.Free;
var
  i: integer;
begin
  xminimos.Free;
  xiniciales.Free;
  xvalores.Free;
  setlength(ivx, 0);
  for i := 1 to mEcuaciones do
    setlength(gij[i], 0);
  setlength(gij, 0);
  setlength(fi, 0);
  inherited Free;
end;


procedure TProblema.IniciarResolucion;
var
  k, jvarred: integer;
  cnt_Libres: integer;
begin
  jvarred := 1;
  cnt_Libres := nVariables;
  for k := 1 to high(xfijadas) do
    if not xfijadas[k] then
    begin
      ivx[jvarred] := k;
      Inc(jvarred);
    end
    else
      Dec(cnt_Libres);
  if cnt_Libres < mEcuaciones then
    raise Exception.Create('El número de variables libres es: ' + IntToStr(
      cnt_Libres) + ' < ' + IntToStr(mEcuaciones));
  for k := 1 to nVariables do
    xvalores.pv[k] := xiniciales.pv[k];
end;

procedure TProblema.copy_xrToxvalores(xr: TVectR);
var
  ivarred: integer;
begin
  for ivarred := 1 to xr.n do
    xvalores.pv[ivx[ivarred]] := xr.pv[ivarred];
end;


procedure TProblema.Calc_JRed(var JRed: TMatR);
var
  iec, ivarred, ivarnored: integer;
  m: NReal;
begin
  for iec := 1 to mEcuaciones do
    for ivarred := 1 to mEcuaciones do
    begin
      ivarnored := ivx[ivarred];
      m := self.gij[iec][ivarnored](iec, ivarnored, xvalores);
      JRed.pm[iec].pv[ivarred] := m;
    end;
end;

procedure TProblema.Calc_F(var fval: TVectR);
var
  iec: integer;
  m: NReal;
begin
  for iec := 1 to mEcuaciones do
  begin
    m := self.fi[iec](iec, xvalores);
    fval.pv[iec] := m;
  end;
end;

procedure CopiarVectToMat(var m: TMatR; v: TVectR);
var
  k: integer;
begin
  for k := 1 to v.n do
    m.pm[k].pv[1] := v.pv[k];
end;


function TProblema.BuscarSolucion_NewtonRapson(maxErr: NReal;
  NMaxIter: integer; flg_CONTROLAR_PASO: boolean; var err: NReal;
  var cnt_iters: integer): boolean;
var
  xRed0, xRedSig: TVectR;
  fvals, fvalsSig: TVectR;
  JRed: TMatR;
  //JRed2, mfvals2: TSparseMatR;
  k, i, kmin, kmax: integer;
  m, m2, valmin, valmax: NReal;
  mfvals: TMatR;
  convergio: boolean;
  errSig: NReal;
  landa: NReal;
  reduciendoPaso: boolean;
  resb: boolean;
  e10: integer;
  //archi:textfile;
  //T1: TCrono;
begin
  fvals := TVectR.Create_Init(mEcuaciones);
  fvalsSig := TVectR.Create_init(mEcuaciones);
  xred0 := TVectR.Create_init(mEcuaciones);
  xredSig := TVectR.Create_Init(mEcuaciones);
  JRed := TMatR.Create_Init(mEcuaciones, mEcuaciones);
  mfvals := TMatR.Create_init(mEcuaciones, 1);
  Writeln('inicio solucion');

  IniciarResolucion;
  for k := 1 to xred0.n do
    xred0.pv[k] := xvalores.pv[ivx[k]];


  Self.Calc_F(fvals);

  err := fvals.normMaxAbs;
  CopiarVectToMat(mfvals, fvals);
  self.Calc_JRed(JRed);
  m := JRed.Escaler(mfvals, resb, e10);
  if e10 < -12 then
  begin
    errMsg := 'det(J)=0, en el arranque.';
    Result := False;
    exit;
  end;

  if flg_CONTROLAR_PASO then
  begin
    landa := 1;
    reduciendoPaso := True;
    repeat
      for k := 1 to xredSig.n do
        xRedSig.pv[k] := xRed0.pv[k] - landa * (mfvals.pm[k].pv[1]);

      copy_xrToxvalores(xRedSig);
      Self.Calc_F(fvalsSig);
      errSig := fvalsSig.ne2;


      if errSig > err then
      begin
        landa := landa / 1.3;
        if landa < maxErr then
          reduciendopaso := False;
      end
      else
        reduciendopaso := False;
    until not reduciendopaso;
  end
  else
  begin
    for k := 1 to xredSig.n do
      xRedSig.pv[k] := xRed0.pv[k] - landa * mfvals.pm[k].pv[1];
    copy_xrToxvalores(xRedSig);
    Self.Calc_F(fvalsSig);
    errSig := fvalsSig.ne2;
  end;
  vswap(xRedSig, xRed0);
  err := errSig;
  vswap(fvals, fvalsSig);

  cnt_Iters := 0;
  convergio := False;

  while (cnt_Iters < NMaxIter) and not Convergio do
  begin
    if (err < maxErr) then
    begin
      convergio := True;
    end
    else
    begin
      CopiarVectToMat(mfvals, fvals);
      self.Calc_JRed(JRed);
      m := JRed.Escaler(mfvals, resb, e10);
      if e10 < -12 then
      begin
        errMsg := 'J=0 cnt_iters: ' + IntToStr(cnt_iters);
        Result := False;
        exit;
      end;

      if flg_CONTROLAR_PASO then
      begin
        landa := 1;
        reduciendoPaso := True;
        while (reduciendoPaso) do
        begin

          for k := 1 to xredSig.n do
            xRedSig.pv[k] := xRed0.pv[k] - landa * (mfvals.pm[k].pv[1]);

          copy_xrToxvalores(xRedSig);
          Self.Calc_F(fvalsSig);
          errSig := fvalsSig.ne2;
          if errSig > err then
          begin
            landa := landa / 1.3;
            if landa < maxErr then
              reduciendopaso := False;
          end
          else
            reduciendopaso := False;
        end;
      end
      else
      begin
        for k := 1 to xredSig.n do
          xRedSig.pv[k] := xRed0.pv[k] - landa * mfvals.pm[k].pv[1];
        copy_xrToxvalores(xRedSig);
        Self.Calc_F(fvalsSig);
        errSig := fvalsSig.ne2;
      end;
      vswap(xRedSig, xRed0);
      err := errSig;
      vswap(fvals, fvalsSig);
      fvals.MinMax(kmin, kmax, valmin, valmax);
      writeln(cnt_iters, ' err: ', err: 5: 5, '  Min en: ', kmin, ' valmin: ',
        valmin: 5: 2, ' Max en: ', kmax, ' valmax ', valmax: 5: 2);
      Inc(cnt_Iters);

    end;
  end;

  if not convergio then
    errMsg := 'Máximo número de iteraciones alcanzados.';
  Result := convergio;
  JRed.Free;
  xredSig.Free;
  xred0.Free;
  fvals.Free;
  mfvals.Free;
  fvalsSig.Free;

end;

end.
