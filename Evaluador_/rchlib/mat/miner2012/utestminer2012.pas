unit utestMiner2012;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  xmatdefs,
  uExcelFile,
  ufxgx, uresfxgx,
  matreal,
  uSimplex, uMIPSImplex, uListaViolacionesPermitidasSimplex, uproblema;

type

  { TFormMiner2012 }

  TFormMiner2012 = class(TForm)
    btSimplex1: TButton;
    btCrearMinero: TButton;
    btResolver: TButton;
    GroupBox1: TGroupBox;
    memo_salida: TMemo;
    procedure btCrearMineroClick(Sender: TObject);
    procedure btResolverClick(Sender: TObject);
    procedure btSimplex1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }

    xf: TExcelFile;
    kfilx: integer; // fila de las x: en la planilla
    spx: TSimplex;

    minero: TProblema_m01;

    procedure LoadCasoSimplex(const archi: string);
    procedure wrln(s: string);
  end;

var
  FormMiner2012: TFormMiner2012;

implementation

{$R *.lfm}

procedure TFormMiner2012.wrln(s: string);
begin
  memo_salida.Lines.add(s);
end;

procedure TFormMiner2012.btSimplex1Click(Sender: TObject);
begin
  self.LoadCasoSimplex('C:\simsee\SimSEE_src\src\rchlib\mat\miner2012\P1_simplex_planteo.XLT'
    );

end;

procedure TFormMiner2012.FormCreate(Sender: TObject);
begin
  spx:= nil;
  minero:= nil;
end;

procedure TFormMiner2012.btCrearMineroClick(Sender: TObject);
var
  rcombilin: Tfx_lineal_x;
  kres: integer;

  ivars: TDAOfNInt;
  coefs: TDAOfNReal;

  jcol, cnt: integer;
  j: integer;

begin
  if minero <> nil then minero.Free;

  minero:= TProblema_m01.Create_init(
    spx.nf, // cantidad de ecuaciones = restricciones más función objetivo.
    spx.nc, // total de vairables nr + ne
    0, // variables enteras ne.
    spx.fGetNombreVar, spx.fGetNombreRes  ); // funciones auxiliares para debug

// cargamos las restricciones
  for kres:= 0 to spx.nf-2 do
  begin
    setlength( ivars, spx.nc );
    setlength( coefs, spx.nc );
    cnt:= 0;
    for jcol:= 1 to spx.nc -1 do
    begin
      if abs( spx.e( kres+1, jcol) ) > asumaCero then
      begin
        ivars[cnt]:= jcol;
        coefs[cnt]:= spx.e( kres+1, jcol );
        inc( cnt );
      end;
    end;
    setlength( ivars, cnt );
    setlength( coefs, cnt );

    rcombilin:= Tfx_lineal_x.Create(ivars, coefs, spx.e( kres+1, spx.nc ));
    ( minero.restricciones[ kres ].fx as Tfx_sumatoria ).fxs.add( rcombilin );
  end;

  kres:= spx.nf-1;
  setlength( ivars, spx.nc );
  setlength( coefs, spx.nc );
  cnt:= 0;
  for jcol:= 1 to spx.nc -1 do
  begin
    if abs( spx.e( kres+1, jcol) ) > asumaCero then
    begin
      ivars[cnt]:= jcol;
      coefs[cnt]:= - spx.e( kres+1, jcol );
      inc( cnt );
    end;
  end;
  setlength( ivars, cnt );
  setlength( coefs, cnt );
  rcombilin:= Tfx_lineal_x.Create(ivars, coefs, - spx.e( kres+1, spx.nc ));
  ( minero.f as Tfx_sumatoria ).fxs.add( rcombilin );

  // fijamos las retricciones de caja
  for j:= 1 to spx.nc-1 do
  begin
//    minero.cota_inf_set( j, spx.x_inf.e( j ) );
    minero.cota_inf_set( j, 0 );
    case spx.flg_x[j] of
    1: minero.cota_sup_set( j, spx.x_sup.e( j ) -  spx.x_inf.e( j ));
    2: minero.FijarVariable( j, 0 );
    end;
  end;

  // ahora fijamos el tipo de restricción
  for j:= 1 to spx.nf-1 do
  begin
    case spx.flg_y[j] of
    0:  minero.restricciones[j-1].tipo := TR_Mayor;
    -2, 2: minero.restricciones[j-1].tipo:= TR_Igualdad;
    end;
  end;


  minero.DumpToArchi( 'debug_minero.txt');
end;

procedure TFormMiner2012.btResolverClick(Sender: TObject);
var
  lambda, X: TVectR;
  niters: integer;
  valcosto: NReal;
  convergio: boolean;
  k: integer;
  valLagrangiana, dFrontera2: NReal;
begin
  if minero <> nil then
  begin
    lambda:= TVectR.Create_init( length( minero.restricciones ));
    X:= TVectR.Create_init( Minero.x_inf.n );
    randseed:= 31;
    for k:= 1 to X.n do x.pon_e( k, random );
    minero.EstimarMultiplicadores( X, 1 );

    for k:= 1 to 30 do
    begin
      writeln( 'MaxInBox_Dual_', k );
      minero.MaxInBox_Dual( Lambda, X, 1, 1E-14, 1000, niters, valcosto, valLagrangiana, dFrontera2, convergio, false);
      writeln( 'f: ', minero.f.f( X ): 12: 4 , ' NITers: ', niters );
      minero.PrintSatus( 'minero_status.txt', k> 1, x );
      readln;
    end;
   lambda.Free;
   X.free;
  end;
end;

procedure TFormMiner2012.LoadCasoSimplex(const archi: string);
var
  jcol: integer;
  buscando: boolean;
  r: string;
  cnt_Variables, cnt_Restricciones: integer;

  k, j: integer;
  ivae1, ivae2: string;

  lstve: TDAOfNInt;
  xlstAcoplesVEnts: TDAOfAcoplesVEnts;
  NEnteras, nViolacionesPermitidas, nViolacionesUsadas, cnt_RestrRedundantes: integer;
  ficha: TFichaViolacionPermitida;
  nIvars: integer;
  iVars: TDAofNInt;
  listaViolacionesPermitidas: TListaViolacionesPermitidasSimplex;

begin

  xf := TExcelFile.Create('', False, True, False);
  xf.Abrir(archi);


    if (spx <> nil) then
     spx.Free( true ) ;


  try

    kfilx := 1;
    jcol := 1;

    xf.ActivoHoja_numero(1);

    kfilx := 2;
    r := xf.readStr(kfilx, 1);
    if pos('NEnteras:', r) = 1 then
    begin
      NEnteras := xf.readInt(kfilx, 2);
      setlength(lstve, NEnteras);
      for k := 0 to high(lstve) do
        lstve[k] := xf.readInt(kfilx, 3 + k);
      //paso la lista de variables enteras y el ivae VarAcoplada ResAcoplada
      kfilx := kfilx + 2;
      setLength(xlstAcoplesVEnts, NEnteras);
      for k := 0 to high(xlstAcoplesVEnts) do
      begin
        j := 1;
        ivae1 := xf.readStr(kfilx, 1);
        ivae2 := xf.readStr(kfilx + j, 1);
        while (ivae1 = ivae2) do
        begin
          Inc(j);
          ivae2 := xf.readStr(kfilx + j, 1);
        end;
        setLength(xlstAcoplesVEnts[k], j);
        for j := 0 to high(xlstAcoplesVEnts[k]) do
        begin
          xlstAcoplesVEnts[k][j].ivar := xf.readInt(kfilx + j, 2);
          xlstAcoplesVEnts[k][j].ires := xf.readInt(kfilx + j, 3);
        end;
        kfilx := kfilx + length(xlstAcoplesVEnts[k]);
      end;
    end
    else
      NEnteras := 0;

    //cnt_varfijas
    kfilx := kfilx + 1;
    cnt_RestrRedundantes := xf.ReadInt(kfilx, 2);
    kfilx := kfilx + 1;
    listaViolacionesPermitidas := TListaViolacionesPermitidasSimplex.Create;
    nViolacionesUsadas := xf.ReadInt(kfilx, 2);
    kfilx := kfilx + 2;//cnt_ViolacionesUsadas, violacionesPermitidas
    nViolacionesPermitidas := xf.ReadInt(kfilx, 2);
    listaViolacionesPermitidas.Capacity := nViolacionesPermitidas;
    kfilx := kfilx + 1;//ivar  ires  usada
    for k := 1 to nViolacionesPermitidas do
    begin
      nIvars := xf.ReadInt(kfilx + k, 4);
      SetLength(iVars, nIvars);
      for j := 0 to high(iVars) do
        iVars[j] := xf.ReadInt(kfilx + k, 5 + j);

      ficha := TFichaViolacionPermitida.Create(xf.ReadInt(kfilx + k, 1), iVars);
      ficha.usada := xf.ReadInt(kfilx + k, 2) <> 0;
      ficha.iViolacionAUsar := xf.ReadInt(kfilx + k, 3);
      listaViolacionesPermitidas.Add(ficha);
    end;

    buscando := True;
    kfilx := 1;
    jcol := 1;
    xf.ActivoHoja_numero(1);
    while buscando and (kfilx < 100) do
    begin
      r := xf.ReadStr(kfilx, 1);
      if pos('x:', r) = 1 then
        buscando := False
      else
        Inc(kfilx);
    end;

    if buscando then
      raise Exception.Create('No encontré la fila del asl x: ');

    // contamos las variables
    cnt_Variables := 0;
    jcol := 2;
    r := xf.ReadStr(kfilx, jcol);
    while r <> '' do
    begin
      Inc(cnt_Variables);
      Inc(jcol);
      r := xf.ReadStr(kfilx, jcol);
    end;

    // contamos las restricciones
    cnt_Restricciones := 0;
    jcol := 2;
    r := xf.ReadStr(kfilx + 4, jcol);
    while r <> '' do
    begin
      Inc(cnt_Restricciones);
      Inc(jcol);
      r := xf.ReadStr(kfilx + 4, jcol);
    end;

    //creamos el simplex
    spx := TMIPSimplex.Create_init(cnt_Restricciones + 1, cnt_Variables + 1,
      NEnteras, nil, nil);
    spx.cnt_RestriccionesRedundantes_ := cnt_RestrRedundantes;
    spx.violacionesPermitidas.Free;
    spx.violacionesPermitidas := listaViolacionesPermitidas;
    spx.cnt_ViolacionesUsadas := nViolacionesUsadas;

    for j := 1 to cnt_Variables do
      spx.top[j] := xf.ReadInt(kfilx + 5, j + 1);

    for j := 1 to cnt_Restricciones do
      spx.left[j] := xf.ReadInt(kfilx + 6, j + 1);

    spx.rearmarIndicesiiXiiY;

    // ahora leemos las variables y sus cotas
    spx.cnt_varfijas := 0;
    for j := 1 to cnt_Variables do
    begin
      spx.x_inf.pv[j] := xf.ReadFloat(kfilx + 1, j + 1);
      spx.x_sup.pv[j] := xf.ReadFloat(kfilx + 2, j + 1);
      spx.flg_x[j] := xf.ReadInt(kfilx + 3, j + 1);
      if abs(spx.flg_x[j]) = 2 then
        Inc(spx.cnt_varfijas);
      spx.nombreVars[j] := xf.ReadStr(kfilx, j + 1);
    end;

    //  TMIPSimplex(spx).lstAcoplesVEnts:= xlstAcoplesVEnts;
    for j := 1 to NEnteras do
    begin
      if xlstAcoplesVEnts[j - 1][0].ivar <> -1 then
        TMIPSimplex(spx).set_EnteraConAcoples(j, lstve[j - 1], trunc(
          spx.x_sup.pv[lstve[j - 1]] + 0.1),
          xlstAcoplesVEnts[j - 1])
      else
        spx.set_entera(j, lstve[j - 1], trunc(spx.x_sup.pv[lstve[j - 1]] + 0.1));
    end;

    // cargamos las flg_y
    spx.cnt_igualdades := 0;
    for j := 1 to cnt_Restricciones do
    begin
      spx.flg_y[j] := xf.ReadInt(kfilx + 4, j + 1);
      if abs(spx.flg_y[j]) = 2 then
        Inc(spx.cnt_igualdades);
      if spx.iiy[j] > 0 then
        spx.nombreRest[j] := xf.ReadStr(kfilx + 10 + spx.iiy[j], 1)
      else
        spx.nombreRest[j] := xf.ReadStr(kfilx + 10, 1 - spx.iiy[j]);
    end;

    // cargamos la matriz
    for k := 1 to cnt_Restricciones + 1 do
      for j := 1 to cnt_Variables + 1 do
      begin
        spx.pon_e(k, j, xf.ReadFloat(kfilx + 10 + k, j + 1));
      end;

    wrln('Simplex cargado. NFils: ' + IntToStr(spx.nf) + ', NCols: ' + IntToStr(spx.nc));

  finally
    xf.Free;
  end;
end;


end.
