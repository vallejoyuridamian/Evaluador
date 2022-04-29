unit uproblema;

(*
rch@20121026
Creación de la clase TProblema
Esta será una clase genérica de los problemas de optimización.

Al crear el problema se admite especificar si es del tipo
Minimizar o maximizar.


max( f( xr, xe ) )
 @   y1 <= r_k( xr, xe ) <= y2 ; k = 1 ... nr
     xr en R^n1 y
     xe en E^n2

**)
{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, math, matreal, ufxgx, uresfxgx;

const
  { Control de Paso en X }
  CPXMult: NReal = 3;
  CPXDiv: NReal = 4.2;


type
  TFuncNombre = function(i: integer): string of object;


// intentamos mantener compatibilidad con TSimplex para facilitar
// escritura de modelos existentes en SimSEE.

{ TProblema_m01 }

type
  TProblema_m01 = class
  public
    ultimoError: string;
    restricciones: array of TResfx;

    f: Tfx;
    L: Tfx;

    NVerticesDeLaCaja: integer; // 2^N
    x_inf: TVectR;
    x_sup: TVectR;

    //Se indexan desde 1
    flg_x: array of TTipoRestriccion;


    xbox_activa: array of TRestriccionActiva;
    x_sol, x_mult: TVectR;

    g_f: TVectR;
    g_L: TVectR;

    (*Explo
    L_x, L_xs, f_x, f_xs: NReal;
    paso: NReal;
    cnt_pasos: integer;
           *)

    // Indice y distancia a la frontera de la restricción más violada
    // estas variables se actualizan al calcular f y L
    RestriccionMasViolada_i: integer;
    RestriccionMasViolada_d: NReal;


    constructor Create_init(mfilas,
    // cantidad de ecuaciones = restricciones más función objetivo.
      ncolumnas, // total de vairables (nr + ne) más 1 para los términos independientes.
      nenteras: integer; // variables enteras ne.
      xfGetNombreVar, xfGetNombreRes: TFuncNombre); // funciones auxiliares para debug


    // fijamos la variable
  (** manejo de variables enteras
  procedure set_entera(ivae, ivar: integer; CotaSup: integer);

  procedure set_EnteraConAcople(ivae, ivar: integer; CotaSup: integer;
    ivarAcoplada, iresAcoplada: integer);
    overload; override;
  procedure set_EnteraConAcoples(ivae, ivar: integer; CotaSup: integer;
    lstAcoples: TListaAcoplesVEntera);
  procedure fijarCotasSupDeVariablesAcopladas;

  ***)

    procedure limpiar;
    procedure Free;

    (* Fijamos que la restricción kfila es de igualdad *)
    procedure FijarRestriccionIgualdad(kfila: integer);


(*
  Fija el valor de una variable. Esto permite escribir las ecuaciones
  considerando la variable pero luego imponerle un valor.
  Debe ser llamado con el indice que tenía la variable cuando se cargo en el
  Simplex
*)
    procedure FijarVariable(ivar: integer; valor: NReal);

    // método para menejo de las restricciones de caja
(*
  Fija el valor de la cota inferior
*)
    procedure cota_inf_set(ivar: integer; vxinf: NReal);

(*
  Fija el valor de la cota superior
*)
    procedure cota_sup_set(ivar: integer; vxsup: NReal);


 (*
   Funciones auxiliares para leer los resultados
 *)
    function xval(ix: integer): NReal;
    function yval(iy: integer): NReal;
    function xmult(ix: integer): NReal;
    function ymult(iy: integer): NReal;

    (*Explo
    function fval: NReal;
    *)

    // guarda la variable para poder consultar la causa de la no convergencia
    // en caso de que se diera.
    procedure SetUltimoError(s: string);
    function GetUltimoError: string;


    // retorna TRUE la caja de X es no vacía o FALSE si la caja es vacía.
    function CajaFactible: boolean;


    // modifica el punto X si es necesario para entrar en la CAJA
    // además marca cuales de las restricciones de caja quedan activas y cuales no.
    procedure Encajonar(var X: TVectR);

    // retorna el módulo de las distancias a la frontera.
    function calcular_fs(var violadas: TList; var f_x, L_x: NReal; var X: TVectR): NReal;

    procedure calcular_gs(var violadas: TList; var g_f, g_L, X: TVectR);


    // resuelve el problema relajado.
    // de acuerdo con los parámetros lambda almacendos en las restricciones.
    // Retorna el módulo al cuadrado de las distancias a la frontera.
    function MinInBox_CPX(var X: TVectR; paso: NReal; errx: NReal;
      MaxNIters: longint; var NIters: longint; var ValCosto_L, ValCosto_f: NReal;
      var Convergio: boolean; flg_monitor: boolean): NReal;


    // Retorna la distancia a la frontera al cuadarado
    function MaxInBox_Dual(var Lambda, X: TVectR; paso: NReal; errx: NReal;
      MaxNIters: longint; var NIters: longint; var ValCosto, ValLagrangiana,
      dFrontera2: NReal; var Convergio: boolean; flg_monitor: boolean): NREal;


    // hace una primer estimación de los multiplicadores de las restricciones
    // el log_key = 0 => NO HAY LOG
    // log_key = 1 => CREA ARCHIVO DE LOG
    // log_key = 2 => HACE APPEND si el archivo existe y sino lo CREA.
    procedure EstimarMultiplicadores(var X: TVectR; log_key: integer);

    // monitor para MinInBox sobreescribir con el debugger que corresponda.
    function Monitor(const X, Xs: TVectR; f, fs: NReal; paso_ok: boolean): boolean;
      virtual;

    procedure DumpToArchi(archi: string);
    procedure PrintSatus(archi: string; xappend: boolean; const X: TVectR);

    // copia los valores del vétice de la caja.
    // kVertice puede ir de 0 a 2^N-1
    procedure CopyVertice( var X: TVectR; kVertice: integer );

    // retoran -1 si (kVertice+1) está fuera de rango.
    function NextkVertice( kVertice: integer ): integer;

  end;


implementation


constructor TProblema_m01.Create_init(
  mfilas, // cantidad de ecuaciones = restricciones más función objetivo.
  ncolumnas, // total de vairables nr + ne
  nenteras: integer; // variables enteras ne.
  xfGetNombreVar, xfGetNombreRes: TFuncNombre); // funciones auxiliares para debug

var
  k: integer;

begin
  UltimoError := '';

  setlength(restricciones, mfilas - 1);
  for k := 0 to high(restricciones) do
    restricciones[k] := TResfx.Create(TR_Mayor, 0, 0, Tfx_sumatoria.Create(
      0), ncolumnas - 1);

  f := Tfx_sumatoria.Create(0);
  L := Tfx_sumatoria.Create(0);

  x_inf := TVectR.Create_Init(ncolumnas - 1);
  x_sup := TVectR.Create_Init(ncolumnas - 1);

  NVerticesDeLaCaja:= 1 shl (ncolumnas-1 );

  setlength(flg_x, ncolumnas);
  setlength(xbox_activa, ncolumnas);
  x_sol := TVectR.Create_Init(ncolumnas - 1);
  x_mult := TVectR.Create_Init(ncolumnas - 1);

  g_f := TVectR.Create_Init(ncolumnas - 1);
  g_L := TVectR.Create_Init(ncolumnas - 1);

  (*explo
  L_x := 0;
  L_xs := 0;
  f_x := 0;
  f_xs := 0;
  paso := 1;
  cnt_pasos := 0;
         *)
end;



procedure TProblema_m01.limpiar;
var
  k: integer;

begin
  UltimoError := '';

  for k := 0 to high(restricciones) do
  begin
    restricciones[k].Free;
    restricciones[k] := TResfx.Create(TR_Mayor, 0, 0, Tfx_sumatoria.Create(0), x_inf.n);
  end;

  f.Free;
  f := Tfx_sumatoria.Create(0);

  L.Free;
  L := Tfx_sumatoria.Create(0);

  x_inf.ceros;
  x_sup.ceros;

  vclear(flg_x);

  for k := 1 to high(xbox_activa) do
    xbox_activa[k] := NINGUNA;
  x_sol.ceros;
  x_mult.ceros;

  g_f.ceros;
  g_L.ceros;

  (*Explo
  L_x := 0;
  L_xs := 0;
  f_x := 0;
  f_xs := 0;
  paso := 1;
  cnt_pasos := 0;
         *)
end;

procedure TProblema_m01.Free;
var
  k: integer;

begin
  for k := 0 to high(restricciones) do
    restricciones[k].Free;
  setlength(restricciones, 0);

  f.Free;
  L.Free;

  x_inf.Free;
  x_sup.Free;
  setlength(flg_x, 0);
  setlength(xbox_activa, 0);
  x_sol.Free;
  x_mult.Free;

  g_f.Free;
  g_L.Free;

  inherited Free;
end;



(* Fijamos que la restricción kfila es de igualdad *)
procedure TProblema_m01.FijarRestriccionIgualdad(kfila: integer);
begin
  restricciones[kfila - 1].tipo := TR_Igualdad;
end;


procedure TProblema_m01.cota_inf_set(ivar: integer; vxinf: NReal);
begin
  x_inf.pv[ivar] := vxinf;

  if flg_x[ivar] = TR_Libre then
    flg_x[ivar] := TR_Mayor
  else
    flg_x[ivar] := TR_Entre;

end;

procedure TProblema_m01.cota_sup_set(ivar: integer; vxsup: NReal);
begin
  x_sup.pv[ivar] := vxsup;

  if flg_x[ivar] = TR_Libre then
    flg_x[ivar] := TR_Menor
  else
    flg_x[ivar] := TR_Entre;
end;

procedure TProblema_m01.FijarVariable(ivar: integer; valor: NReal);
begin
  x_inf.pv[ivar] := valor;
  x_sup.pv[ivar] := valor;
  flg_x[ivar] := TR_Igualdad;
end;


 (*
   Funciones auxiliares para leer los resultados
 *)
function TProblema_m01.xval(ix: integer): NReal;
begin
  Result := X_sol.e(ix);
end;

function TProblema_m01.yval(iy: integer): NReal;
begin
  Result := restricciones[iy - 1].ultimo_f;
end;

function TProblema_m01.xmult(ix: integer): NReal;
begin
  Result := x_mult.e(ix);
end;

function TProblema_m01.ymult(iy: integer): NReal;
begin
  Result := restricciones[iy - 1].lambda;
end;

(*Explo
function TProblema_m01.fval: NReal;
begin
  Result := f_x;
end;
*)


procedure TProblema_m01.SetUltimoError(s: string);
begin
  UltimoError := s;
end;

function TProblema_m01.GetUltimoError: string;
begin
  Result := UltimoError;
end;



function TProblema_m01.CajaFactible: boolean;
var
  ix: integer;
begin
  Result := True;

  // primero chequeamos que no sea infactible de pique
  for ix := 1 to x_sup.n do
    if x_sup.e(ix) < x_inf.e(ix) then
    begin
      SetUltimoError('La restricción de caja de la variable Nº: ' +
        IntToStr(ix) + ' vuelve el prolema infactible. ' + ' x_inf: ' +
        FloatToStr(x_inf.e(ix)) + ' , x_sup: ' + FloatToStr(x_sup.e(ix)));
      Result := False;
      exit;
    end;

end;

procedure TProblema_m01.Encajonar(var X: TVectR);
var
  ix: integer;
begin
  for ix := 1 to X.n do
  begin
    if X.e(ix) <= x_inf.e(ix) then
    begin
      X.pon_e(ix, x_inf.e(ix));
      xbox_activa[ix] := INFERIOR;
    end
    else if X.e(ix) >= x_sup.e(ix) then
    begin
      X.pon_e(ix, x_sup.e(ix));
      xbox_activa[ix] := SUPERIOR;
    end
    else
      xbox_activa[ix] := NINGUNA;
  end;
end;



function TProblema_m01.calcular_fs(var violadas: TList; var f_x, L_x: NReal;
  var X: TVectR): NReal;
var
  ir: integer;
  aR: TResfx;
  penalidad: NReal;
  res: NReal;
begin

  // recorremos las restricciones para identificar las violadas
  // y de paso identificamos "la mas violada".
  violadas.Clear;
  RestriccionMasViolada_i := -1;
  RestriccionMasViolada_d := 0;

  f_x := f.f(X);
  (*Explo
  self.f_x := f_x;
         *)
  L_x := f_x;
  res := 0;

  for ir := 0 to high(restricciones) do
  begin
    aR := restricciones[ir];
    aR.eval_f(X);
    if aR.r_activa <> NINGUNA then
    begin
      violadas.add(restricciones[ir]);
      res := res + sqr(aR.distancia_frontera_f);
      if aR.distancia_frontera_f > RestriccionMasViolada_d then
      begin
        RestriccionMasViolada_i := ir;
        RestriccionMasViolada_d := aR.distancia_frontera_f;
      end;

      penalidad := aR.distancia_frontera_f * aR.lambda;

      if penalidad < 0 then
      begin
        //writeln('Lambda: ', aR.lambda);
        //writeln('aR.distancia_frontera_f: ', aR.distancia_frontera_f);
        //writeln('Penalidad: ', Penalidad);
        readln;
        penalidad := 0;
      end;
      L_x := L_x + penalidad;
    end;
  end;
  (*Explo
  self.L_x:= L_x;
  *)
  Result := res;
end;


procedure TProblema_m01.calcular_gs(var violadas: TList; var g_f, g_L, X: TVectR);
var
  ir: integer;
  aR: TResfx;
begin
  g_f.Ceros;
  f.acum_g(g_f, X);

  g_L.Igual(g_f);
  for ir := 0 to violadas.Count - 1 do
  begin
    aR := TResfx(violadas.Items[ir]);
    aR.eval_g(X);
    if aR.r_activa = INFERIOR then
      g_L.sumRPV(-aR.lambda, aR.ultimo_g)
    else
      g_L.sumRPV(aR.lambda, aR.ultimo_g);
  end;
end;




function TProblema_m01.MinInBox_CPX(var X: TVectR; paso: NReal;
  errx: NReal; MaxNIters: longint; var NIters: longint;
  var ValCosto_L, ValCosto_f: NReal; var Convergio: boolean;
  flg_monitor: boolean): NReal;
var
  LVal_o, LVal_s: NReal;
  LGrad, Xs: TVectR;
  OksSeguidos, FallasSeguidas, OksAct: longint;

  FVal_o, FVal_s: NReal;
  FGrad: TVectR;

  violadas: TList;
  abortar: boolean;
  norma_LGrad: NReal;
  distanciaALaFrontera2, distanciaALaFrontera2s: NReal;

label
  lbl_fin;

begin
  NIters := 0;
  Convergio := False;

  if not CajaFactible then
    exit;

  violadas := TList.Create;

  LGrad := TVectR.Create_Init(X.n);
  Xs := TVectR.Create_Init(X.n);

  FGrad := TVectR.Create_Init(X.n);

  encajonar(X);

  distanciaALaFrontera2 := calcular_fs(violadas, FVal_o, LVal_o, X);
  calcular_gs(violadas, FGrad, LGrad, X);

  norma_LGrad := LGrad.normEuclid;
  if norma_LGrad < AsumaCero then
  begin
    convergio := True;
    goto lbl_fin;
  end;
  LGrad.PorReal(1 / norma_LGrad);

  OksSeguidos := 0;
  FallasSeguidas := 0;
  OksAct := 1;
  abortar := False;

  repeat

    //  writeln( 'NIters: ', NIters );

    // proyección del paso según el gradiente y encajonado
    Xs.copy(X);
    Xs.SumRPV(-paso, LGrad);
    encajonar(Xs);

    // Calculamos el valor del objetivo en Xs
    distanciaALaFrontera2s := calcular_fs(violadas, FVal_s, LVal_s, Xs);

    Inc(NIters);

    if LVal_s < LVal_o then
    begin
      Inc(OksSeguidos);
      FallasSeguidas := 0;
      if flg_monitor then
        abortar := Monitor(X, Xs, LVal_o, LVal_s, True);
      vswap(X, Xs);
      distanciaALaFrontera2 := distanciaALaFrontera2s;
      LVal_o := LVal_s;
      FVal_o := FVal_s;

      FGrad.Ceros;
      LGrad.Ceros;
      calcular_gs(violadas, FGrad, LGrad, X);


      norma_LGrad := LGrad.normEuclid;
      if norma_LGrad < AsumaCero then
      begin
        // llegamos a un punto de derivada nula
        convergio := True;
      end
      else
      begin
        LGrad.PorReal(1 / norma_LGrad);
        if OksAct <= OksSeguidos then
        begin
          paso := paso * CPXMult;
          Dec(OksAct);
          if OksAct = 0 then
            OksAct := 1;
        end;
      end;
    end
    else
    begin
      if flg_monitor then
        abortar := Monitor(X, Xs, LVal_o, LVal_s, False);
      Inc(OksAct);
      Inc(FallasSeguidas);
      OksSeguidos := 0;
      paso := paso / CPXDiv;
      if paso < errx then
        Convergio := True;
    end;
    // writeln(Niters: 6,'  ', LVal_o: 12: 4,' ', paso, ' >',OksAct);
  until Convergio or (NIters >= MaxNIters) or abortar;

  lbl_fin:
    ValCosto_L := LVal_o;
  ValCosto_f := FVal_o;
  Result := distanciaALaFrontera2;
  LGrad.Free;
  Xs.Free;

  FGrad.Free;
  violadas.Free;
end;


function TProblema_m01.MaxInBox_Dual(var Lambda, X: TVectR; paso: NReal;
  errx: NReal; MaxNIters: longint; var NIters: longint; var ValCosto,
  ValLagrangiana, dFrontera2: NReal; var Convergio: boolean; flg_monitor: boolean
  ): NREal;
label
  lbl_fin;

var

  valL_o, valL_s: NReal;
  valF_o, valF_s: NReal;

  v, Lambda_s: TVectR;
  OksSeguidos, FallasSeguidas, OksAct: longint;

  violadas: TList;
  abortar: boolean;
  aR: TResfx;
  ir: integer;
  mb_Convergio: boolean;
  mb_Paso: NReal;

  xs: TVectR;

  NIters_MinInBox: integer;
  v_norm: NReal;

  DistanciaALaFrontera2, DistanciaALaFrontera2s: NReal;

begin
  Convergio := False;
  DistanciaALaFrontera2 := 1e50;
  if not CajaFactible then
  begin
    NIters := 0;
    exit;
  end;
  mb_Paso := paso;

  violadas := TList.Create;

  Xs := TVectR.Create_Init(X.n);
  v := TVectR.Create_Init(lambda.n);
  lambda_s := TVectR.Create_Init(lambda.n);


  // llevamos el punto inicial dentro de la caja si estaba fuera
  // y clasifcamos las restricciones de caja en ACTIVA e INACTIVAS
  encajonar(X);


  for ir := 0 to high(restricciones) do
  begin
    aR := restricciones[ir];
    if Lambda.e(ir + 1) < 0 then
      Lambda.pon_e(ir + 1, 0.0);  // no adminto multiplicadores negativos
    aR.lambda := lambda.e(ir + 1);
  end;

  DistanciaALafrontera2 := MinInBox_CPX(X, mb_paso, errx / 100.0,
    MaxNIters, NIters, valL_o, valF_o, mb_Convergio, flg_monitor);

  // El gradiente de la Lagrangiana respecto de los multiplicadores
  // es el valor de las restricciones.
  for ir := 0 to high(restricciones) do
  begin
    aR := restricciones[ir];
    v.pon_e(ir + 1, aR.distancia_frontera_f);
  end;

  OksSeguidos := 0;
  FallasSeguidas := 0;
  OksAct := 1;
  NIters := 0;
  abortar := False;

  v_norm := v.normEuclid;
  if v_norm > AsumaCero then
    v.PorReal(1 / v_norm)
  else
  begin
    Convergio := True;
    goto lbl_fin;
  end;


  repeat

    //   writeln('MaxInBox->NIters: ', NIters);

    lambda_s.copy(lambda);
    lambda_s.SumRPV(paso, v);

    for ir := 0 to high(restricciones) do
    begin
      if Lambda_s.e(ir + 1) < 0 then
        Lambda_s.pon_e(ir + 1, 0.0);  // no adminto multiplicadores negativos
      aR := restricciones[ir];
      aR.lambda := lambda_s.e(ir + 1);
    end;
    Xs.Copy(X);

    DistanciaALafrontera2s := MinInBox_CPX(Xs, mb_paso, errx /
      10.0, MaxNIters, NIters_minInBox, valL_s, valF_s, mb_Convergio, flg_monitor);

    Inc(NIters);

    if mb_convergio
       and (valL_s > valL_o)
       and
      ((DistanciaALaFrontera2s < 1e-20) or (DistanciaALaFrontera2s <=
      (DistanciaALaFrontera2 * 1.2)))
    //         and ( f_vals > f_val )
    then
    begin
      Inc(OksSeguidos);
      FallasSeguidas := 0;
(*
        if flg_monitor then
          abortar := Monitor(X, Xs, fo, fs, True);
          *)
      vswap(X, Xs);
      encajonar(X);
      vswap(Lambda, Lambda_s);
      DistanciaALaFrontera2 := DistanciaALaFrontera2s;

      for ir := 0 to high(restricciones) do
      begin
        aR := restricciones[ir];
        v.pon_e(ir + 1, aR.distancia_frontera_f);
      end;

      valL_o := valL_s;
      valF_o := valF_s;

      v_norm := v.normEuclid;
      if v_norm > AsumaCero then
        v.PorReal(1 / v_norm)
      else
      //       if EsCero( valL_o - valF_o ) then
      if DistanciaALaFrontera2 < 1e-20 then
        Convergio := True
      else
      begin
         {$IFDEF METODO_PULGA}
          v.versor_randomico;
          paso:= paso * CPXMUlt;
          {$ELSE}
          abortar := True;
          {$ENDIF}
      end;

      if OksAct <= OksSeguidos then
      begin
        if paso < 1e100 then
          paso := paso * CPXMult;
        Dec(OksAct);
        if OksAct = 0 then
          OksAct := 1;
      end;
    end
    else
    begin
      vswap(X, Xs);
      encajonar(X);
(*
        if flg_monitor then
          abortar := Monitor(X, Xs, fo, fs, False);
          *)
      Inc(OksAct);
      Inc(FallasSeguidas);
      OksSeguidos := 0;
      paso := paso / CPXDiv;
      if paso < errx then
        if DistanciaALaFrontera2 < 1e-20 then
          Convergio := True
        else
        begin
          {$IFDEF METODO_PULGA}
           v.versor_randomico;
           paso:= paso * CPXMUlt;
           {$ELSE}
           abortar := True;
           {$ENDIF}
        end;
    end;

   // writeln(Niters: 6, '  L:', valL_o: 12: 4, ' ; F', valF_o: 12: 4
     // , ', RMV_i: ', RestriccionMasViolada_i, ', RMV_d:', RestriccionMasViolada_d);
  until Convergio or (NIters >= MaxNIters) or abortar;

  lbl_fin:


    // hago un intento de poner los multiplicadores al mínimo necesario
    // para equilibrar el gradiente.
    EstimarMultiplicadores(X, 2);
  for ir := 0 to high(restricciones) do
    lambda.pon_e(ir + 1, restricciones[ir].lambda);

  ValCosto := valF_o;
  ValLagrangiana:= valL_o;
  dFrontera2:= DistanciaALaFrontera2;
  v.Free;
  Xs.Free;
  violadas.Free;
  Result := DistanciaALaFrontera2;
end;


function GetOpositora_Maximo_Remanente(Opositoras: TList; var m: NReal): TResfx;
var
  aR, aRmaxr: TResfx;
  ir: integer;
  imaxr: integer;
  mmaxr: NReal;
  ma: NReal;

begin
  // como son opositoras, buscamo la de mayor proyección NEGATIVA
  aR := Opositoras.Items[0];
  aRmaxr := aR;
  imaxr := 0;
  mmaxr := aR.gr_rem_ne;

  for ir := 1 to Opositoras.Count - 1 do
  begin
    aR := Opositoras.Items[ir];
    ma := aR.gr_rem_ne;
    if ma > mmaxr then
    begin
      imaxr := ir;
      mmaxr := ma;
      aRMaxr := aR;
    end;
  end;

  opositoras.Delete(imaxr);
  m := mmaxr;
  Result := aRMaxr;
end;




function GetOpositora_MaximaProyeccion_o_remanente(Opositoras: TList;
  const gf_remanente: TVectR; var m: NReal; var SelPorProyeccion: boolean): TResfx;
var
  aR, aRmaxp, aRmaxr: TResfx;
  ir: integer;

  imaxp: integer;
  mmaxp: NReal;

  imaxr: integer;
  mmaxr: NReal;

  ma: NReal;

begin
  // como son opositoras, buscamo la de mayor proyección NEGATIVA
  aR := Opositoras.Items[0];
  aRmaxp := aR;
  aRmaxr := aR;

  imaxp := 0;
  imaxr := 0;
  mmaxp := aR.gr_versor.pev(gf_remanente);
  mmaxr := aR.gr_rem_ne;

  for ir := 1 to Opositoras.Count - 1 do
  begin
    aR := Opositoras.Items[ir];
    ma := aR.gr_versor.pev(gf_remanente);
    if ma < mmaxp then
    begin
      imaxp := ir;
      mmaxp := ma;
      aRMaxp := aR;
    end;

    ma := aR.gr_rem_ne;
    if ma > mmaxr then
    begin
      imaxr := ir;
      mmaxr := ma;
      aRMaxr := aR;
    end;
  end;

  if mmaxp < -AsumaCero then
  begin
    opositoras.Delete(imaxp);
    m := mmaxp;
    SelPorProyeccion := True;
    Result := aRMaxp;
  end
  else
  begin
    opositoras.Delete(imaxr);
    m := mmaxr;
    SelPorProyeccion := False;
    Result := aRMaxr;
  end;
end;




(* Esta función resive la lista de restricciones violadas y el gradiente de
la función objetivo.
Primero clsifica a las restricciones en Opositoras y Colaborantes.
Las Colaborantes son las que el gradiente de la restricción va en el mismo
sentido que el gradiente de la función. Las restricciones de Igualdad NUNCA
pueden ser Colaborantes pues siempre están activas.
Luego, entre las Opositoras se busca una base orto_normal de los gradientes
y se las clasifica según que dicha base en opositoras_base y opositoras_redundantes.

Las opositoras_redundantes tendrán el lambda (CERO) para la formación de la Lagrangiana
pues no aportan a equilibrar el gradiente de objetivo.

Al llamar esta función se supone que se está en un punto factible y por lo tanto
no se utilizan las distancias a las fronteras.
El objetivo de esta función es tener una estimación de los lambdas a aplicar
en las restricciones para cumplir con las condiciones de optimalidad KKT

Retorna TRUE si la base opositora logra equilibrar gf.

*)

function CrearBaseOpositora(var opositoras_base, opositoras_redundantes,
  colaboradoras: TList; var gf_alfa: TVectR; const violadas: TList;
  const gf: TVectR): boolean;

var
  gf_versor: TVectR; // almacena el versor gf/|gf| por comodidad
  gf_remanente: TVectR;
  // almacena lo que va quedando sin reducir de gf al ir restando proyecciones
  gf_rem_ne: NReal; // norma euclidea del vector anterior.
  flg_gf_con_remanente: boolean; // lo usamos como indicador

  aR, bR: TResfx;
  opositoras: TList;

  SelPorProyeccion: boolean;

  ir: integer;

  m: NReal;
  flg_SelPorProyeccion: boolean;

begin
  gf_remanente := gf.clonar;
  gf_versor := gf.clonar;
  gf_rem_ne := gf_versor.HacerUnitario;
  gf_alfa.Ceros;

  flg_gf_con_remanente := gf_rem_ne > AsumaCero;


  // limpiamos las listas
  opositoras := TList.Create;
  opositoras_base.Clear;
  opositoras_redundantes.Clear;
  colaboradoras.Clear;

  // bien ahora preparamos las restricciones y las clasificamos
  // entre opositoras o colaborantes
  for ir := 0 to violadas.Count - 1 do
  begin
    aR := violadas.Items[ir];
    aR.gr_remanente.Igual(aR.ultimo_g);
    if aR.r_activa = INFERIOR then
      aR.gr_remanente.PorReal(-1.0);

    aR.gr_versor.Igual(aR.ultimo_g);
    aR.gr_rem_ne := aR.gr_versor.HacerUnitario;
    aR.gr_alfa.ceros;
    m := aR.gr_versor.PEV(gf_versor);

(** aquí tengo problemas ... si quedé del lado de la igualdad incorrecto
no me aparece el lambda
    if ( m > 0 ) and ( aR.tipo = TR_Igualdad ) and ( aR.distancia_frontera_f < 1e-4)  then
    begin
      m:= -m;
      aR.ultimo_g.PorReal(-1.0);
      aR.gr_remanente.PorReal( -1.0 );
      aR.gr_versor.PorReal( -1.0 );
    end;
****)
    if m <= 0 then
      opositoras.Add(aR)
    else
    begin
      aR.gr_EnBaseOpositora := False;
      colaboradoras.Add(aR);
    end;
  end;


  // 1) ahora mientras me queden opositoras busco aquella cuyo remente tenga
  // 1.1) mayor proyección sobre el remente de gf. Si El remanente gf es nulo
  // 1.2) busco la de mayor remente.
  // A la seleccionada la agregamos a la base opositora el procedimiento
  // de búsqueda la quito de la lista de opositoras.

  // 2) Actualizo el remante de gf quitando la proyección sobre la nueva opositora

  // 3) barremos las opositoras no seleccionadas.
  // 3.1) A las opositoras no seleccionadas les quito las proyecciones sobre la opositora selccionada
  // 3.2) Aquellas que queden sin remanente las quitamos de la lista de opositoras y las pasamos
  // a la de redundates pues son combianción lineal de los versores de la base opositora y coleccionados.

  // El proceso termina o bien porque vaciamos la lista de opositoras.

  // inicialmente intentamos formar la base en función de maximizar la oposición
  // cuando no queden opositores seguimos por máxima remanente de las opositoras
  flg_SelPorProyeccion := True;

  while (opositoras.Count > 0) do
  begin
    // busca la opositora en la lista por uno de los dos métodos y la quita
    // de la lista de opositoras. En m vuelve la proyección sobre gf en el
    // primer caso y el remanente de la retricción en el segundo caso.

    if flg_gf_con_remanente and flg_SelPorProyeccion then
    begin
      aR := GetOpositora_MaximaProyeccion_o_remanente(
        Opositoras, gf_remanente, m, flg_SelPorProyeccion);
      if aR <> nil then
      begin
        opositoras_base.add(aR);
        gf_remanente.sumRPV(-m, aR.gr_versor);
        gf_rem_ne := gf_versor.HacerUnitario;
        gf_alfa.pon_e(opositoras_base.Count, m);
        flg_gf_con_remanente := gf_rem_ne > AsumaCero;
      end;
    end
    else
    begin
      aR := GetOpositora_Maximo_Remanente(Opositoras, m);
      if aR <> nil then
        opositoras_base.add(aR);
    end;

    if aR <> nil then
    begin
      aR.gr_alfa.pon_e(opositoras_base.Count, aR.gr_rem_ne);
      aR.gr_rem_ne := 0;
      aR.gr_EnBaseOpositora := True;

      ir := 0;
      while ir < Opositoras.Count do
      begin
        bR := Opositoras.Items[ir];
        m := bR.gr_remanente.PEV(aR.gr_versor);
        bR.gr_remanente.sumRPV(-m, aR.gr_versor);
        bR.gr_alfa.pon_e(opositoras_base.Count, m);
        bR.gr_versor.Igual(bR.gr_remanente);
        m := bR.gr_versor.HacerUnitario;
        bR.gr_rem_ne := m;
        if (m <= AsumaCero) or (opositoras_base.Count = gf.n) then
        begin
          bR.gr_EnBaseOpositora := False;
          opositoras_redundantes.add(bR);
          opositoras.Delete(ir);
        end
        else
          Inc(ir);
      end;
    end;
  end;

  Result := not flg_gf_con_remanente;
end;

procedure TProblema_m01.EstimarMultiplicadores(var X: TVectR; log_key: integer);
var
  violadas: TList;
  aux_f, fo: NReal;
  aux_g, v: TVectR;

  ir: integer;
  aR, bR: TResfx;

  gf_ne2: NReal;

  opositoras_base, opositoras_redundantes, colaboradoras: TList;

  // coordenadas de g_f en la base opositora
  alfa_g_f: TVectR;

  logro_equilibrio_gf: boolean;
  sum_a: NReal;
  jr: integer;

  flog: textfile;
  kl: integer;

begin
  if log_key > 0 then
  begin
    assignfile(flog, 'log_EstimarMultiplicadores.xlt');
    if log_key = 1 then
      rewrite(flog)
    else
    begin
      {$I-}
      append(flog);
      {$I+}
      if ioresult <> 0 then
        rewrite(flog);
    end;
  end;


  aux_g := TVectR.Create_Init(X.n);
  violadas := TList.Create;

  encajonar(X);
  calcular_fs(violadas, aux_f, fo, X);

  for ir := 0 to high(restricciones) do
  begin
    aR := restricciones[ir];
    aR.lambda := 0.0;
  end;

  for ir := 1 to self.x_mult.n do
    x_mult.pv[ir] := 0.0;

  if log_key > 0 then
  begin
    writeln(flog, 'calcular_fs ............. ');
    Write(flog, 'x: ');
    for kl := 1 to X.n do
      Write(flog, #9, X.e(kl));
    writeln(flog);

    writeln(flog, 'f(x): ', #9, aux_f, #9, 'L(x): ', #9, fo);

    Write(flog, 'r(x): ');
    for kl := 0 to violadas.Count - 1 do
    begin
      aR := violadas.Items[kl];
      Write(flog, #9, aR.ultimo_f);
    end;
    writeln(flog);
  end;

  aux_g.Ceros;
  f.acum_g(aux_g, X);

  gf_ne2 := aux_g.ne2;

  if gf_ne2 <= AsumaCero then
  begin
    // dejo todos las lambdas = 0 y me voy
    violadas.Free;
    aux_g.Free;
    if log_key > 0 then
      closefile(flog);
    exit;
  end;

  alfa_g_f := TVectR.Create_Init(X.n);

  if log_key > 0 then
  begin
    writeln(flog, 'gradientes .... ');
    Write(flog, 'gf');
    for kl := 1 to aux_g.n do
      Write(flog, #9, aux_g.e(kl));
    writeln(flog);
  end;


  // primero calculamos los gradientes de las restricciones activas.
  for ir := 0 to violadas.Count - 1 do
  begin
    aR := TResfx(violadas.Items[ir]);
    aR.eval_g(X);

    if log_key > 0 then
    begin
      Write(flog, 'gr_' + IntToStr(ir));
      for kl := 1 to aux_g.n do
        Write(flog, #9, aR.ultimo_g.e(kl));
      writeln(flog);
    end;
  end;

  opositoras_base := TList.Create;
  opositoras_redundantes := TList.Create;
  colaboradoras := TList.Create;

  logro_equilibrio_gf := CrearBaseOpositora(opositoras_base,
    opositoras_redundantes, colaboradoras, alfa_g_f, violadas, aux_g);


  if log_key > 0 then
  begin
    writeln(flog, 'opositoras_base_versores --------');
    for ir := 0 to opositoras_base.Count - 1 do
    begin
      aR := opositoras_base.items[ir];
      Write(flog, 'ubase_' + IntToStr(ir));
      for kl := 1 to aR.gr_versor.n do
        Write(flog, #9, aR.gr_versor.e(kl));
      writeln(flog);
    end;

    writeln(flog, 'opositoras_base_alfa --------');
    for ir := 0 to opositoras_base.Count - 1 do
    begin
      aR := opositoras_base.items[ir];
      Write(flog, 'alfa_base_' + IntToStr(ir));
      for kl := 1 to aR.gr_alfa.n do
        Write(flog, #9, aR.gr_alfa.e(kl));
      writeln(flog);
    end;

    writeln(flog, 'opositoras_redundantes_alfa --------');
    for ir := 0 to opositoras_redundantes.Count - 1 do
    begin
      aR := opositoras_redundantes.items[ir];
      Write(flog, 'alfa_red_' + IntToStr(ir));
      for kl := 1 to aR.gr_alfa.n do
        Write(flog, #9, aR.gr_alfa.e(kl));
      writeln(flog);
    end;
  end;


  // Supuestamente al salir de aquí tenemos clasificadas las restricciones
  // activas, en BASE_OPOSITORA


  // al inicio puse todos los lambdas = 0.0 ahora me preocupo
  // de recalcular los de las restricciones elegidas para formar la
  // base que equilibra el gradiente.
  // Ahora recorro las opositoras que participan de la base calculando
  // los lambdas en orden inverso.
  for ir := opositoras_base.Count - 1 downto 0 do
  begin
    sum_a := 0.0;
    aR := opositoras_base.Items[ir];
    for jr := ir + 1 to opositoras_base.Count - 1 do
    begin
      bR := opositoras_base.Items[jr];
      sum_a := sum_a + bR.gr_alfa.e(jr + 1) * bR.lambda;
    end;
    if aR.gr_alfa.e(ir + 1) <> 0 then
      aR.lambda := -(alfa_g_f.e(ir + 1) + sum_a) / aR.gr_alfa.e(ir + 1)
    else
      aR.lambda := 0;
  end;



  if log_key > 0 then
  begin
    writeln(flog, 'opositoras_base_lambda --------');
    Write(flog, 'lambdas: ');
    for ir := 0 to opositoras_base.Count - 1 do
    begin
      aR := opositoras_base.items[ir];
      Write(flog, #9, aR.lambda);
    end;
    writeln(flog);
  end;

  violadas.Free;
  opositoras_base.Free;
  opositoras_redundantes.Free;
  colaboradoras.Free;

  aux_g.Free;
  alfa_g_f.Free;


  if log_key > 0 then
    closefile(flog);
end;



function TProblema_m01.Monitor(const X, Xs: TVectR; f, fs: NReal;
  paso_ok: boolean): boolean;
var
  k: integer;
begin
  Write(f: 8: 2, ', X:');
  for k := 1 to X.n do
    Write(', ', X.e(k): 3: 2);
  writeln;

  Write(fs: 8: 2, ', Xs:');
  for k := 1 to Xs.n do
    Write(', ', Xs.e(k): 8: 2);
  writeln;

  Result := False;
end;

procedure TProblema_m01.DumpToArchi(archi: string);
var
  f: textfile;
  r: string;
  k: integer;
begin
  assignfile(f, archi);
  rewrite(f);


  writeln(f, 'cnt_restricciones: ', length(restricciones));
  for k := 0 to high(restricciones) do
  begin
    r := restricciones[k].serialize;
    writeln(f, 'r_', k, ': ', r);
  end;

  writeln(f, self.f.serialize);

  Write(f, 'x_inf: ');
  for k := 1 to x_inf.n do
    Write(f, ', ', x_inf.e(k));
  writeln(f);

  Write(f, 'x_sup: ');
  for k := 1 to x_sup.n do
    Write(f, ', ', x_sup.e(k));
  writeln(f);

  closefile(f);
end;

procedure TProblema_m01.PrintSatus(archi: string; xappend: boolean; const X: TVectR);
var
  sal: textfile;
  k: integer;
  ar: TResfx;

begin
  Assign(sal, archi);

  if xappend then
  begin
    {$I-}
    append(sal);
    {$I+}
    if ioresult <> 0 then
      rewrite(sal);
  end
  else
    rewrite(sal);
  writeln(sal, '++++++++++++++++');
  Write(sal, 'X: ');
  writeln(sal, x.serialize);
  Write(sal, 'fx: ', f.f(x));
  writeln(sal, 'restricciones...');
  for k := 0 to High(restricciones) do
  begin
    ar := restricciones[k];
    Write(sal, k: 2, ': ');
    Write(sal, 'r(x): ', ar.fx.f(X));
    writeln(sal, ', lambda: ', ar.lambda);
  end;
  closefile(sal);

end;


// copia los valores del vétice de la caja.
// kVertice puede ir de 0 a 2^N-1
procedure TProblema_m01.CopyVertice( var X: TVectR; kVertice: integer );
var
  mascara: integer;
  k: integer;
begin
  mascara:= 1;
  for k:= 1 to X.n do
  begin
    if ( mascara and kVertice ) = 0 then
      X.pon_e( k, x_inf.e(k))
    else
      x.pon_e( k, x_sup.e(k));
    mascara:= mascara shl 1;
  end;
end;

// retoran -1 si (kVertice+1) está fuera de rango.
function TProblema_m01.NextkVertice( kVertice: integer ): integer;
var
  res: integer;
begin
  res:= kVertice  +1 ;
  if (res >= 0) and (res < NVerticesDeLaCaja ) then
    result:= res
  else
    result:= -1;
end;

end.
