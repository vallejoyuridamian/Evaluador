unit uEjemplo1;

{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, xmatdefs, matreal, Math, uproblema, ufxgx, uresfxgx,
  uoptvariadorhistogramas,
  uproblemacurvas,
  uescalacolores;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    eLambda: TEdit;
    Label1: TLabel;
    PaintBox1: TPaintBox;
    PaintBox2: TPaintBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    alfa, vm, pmax, dp: NReal;

    procedure punto(X: TVectR; color: TColor);
    procedure flecha_Pv(P, v: TVectR; color: TColor);
    procedure flecha_AB(A, B: TVectR; color: TColor);
  end;


  TProblema_ej1 = class(TProblema_m01)
    function Monitor(const X, Xs: TVectR; f, fs: NReal; paso_ok: boolean): boolean;
      override;
  end;



var
  Form1: TForm1;
  c: TCanvas;
  dx, dy: integer;
  x0, y0: integer;
  m: integer;
  X, Lambda: TVectR;
  problema: TProblema_ej1;


implementation

{$R *.lfm}

type

  T_fobjetivo = class(Tfx)
    function f(const X: TVectR): NReal; override;
    procedure acum_g(var grad: TVectR; const X: TVectR); override;
  end;

  // restricción de igualdad
  T_h = class(Tfx)
    function f(const X: TVectR): NReal; override;
    procedure acum_g(var grad: TVectR; const X: TVectR); override;
  end;

  T_r = class(Tfx)
    function f(const X: TVectR): NReal; override;
    procedure acum_g(var grad: TVectR; const X: TVectR); override;
  end;


function T_fobjetivo.f(const X: TVectR): NReal;
begin
  Result := sqr(x.e(1) - 5) + sqr(x.e(2) - 5);
end;


procedure T_fobjetivo.acum_g(var grad: TVectR; const X: TVectR);
begin
  grad.acum_e(1, 2 * (x.e(1) - 5));
  grad.acum_e(2, 2 * (x.e(2) - 5));
end;


function T_h.f(const X: TVectR): NReal;
begin
  Result := sqr(x.e(1)) + sqr(x.e(2)) - 16.0;
end;


procedure T_h.acum_g(var grad: TVectR; const X: TVectR);
begin
  grad.acum_e(1, 2 * x.e(1));
  grad.acum_e(2, 2 * x.e(2));
end;



function T_r.f(const X: TVectR): NReal;
begin
  Result := x.e(1);
end;

procedure T_r.acum_g(var grad: TVectR; const X: TVectR);
begin
  grad.acum_e(1, 1);
  grad.acum_e(2, 0);
end;



{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  k: integer;
  aR: TResfx;
begin
  X := TVectR.Create_Init(2);
  Lambda := TVectR.Create_Init(2);

  randSeed := 31;

  X.pon_e(1, (20 * random - 10) / 2);
  X.pon_e(2, (20 * random - 10) / 2);

  problema := TProblema_ej1.Create_init(3, 3, 0, nil, nil);
  problema.f := T_fobjetivo.Create;

  problema.cota_inf_set(1, -10);
  problema.cota_sup_set(1, 10);
  problema.cota_inf_set(2, -10);
  problema.cota_sup_set(2, 10);

  aR := problema.restricciones[0];
  aR.tipo := TR_Igualdad;
  aR.fx := T_h.Create;
  problema.FijarRestriccionIgualdad(1);


  aR := problema.restricciones[1];
  aR.tipo := TR_Menor;
  aR.fx := T_r.Create;



  aR := Problema.restricciones[0];
  aR.lambda := 0;

  aR := Problema.restricciones[1];
  aR.lambda := StrToFloat(eLambda.Text);

  // Esto empieza por ENCAJOR X y luego calcula las restricciones
  // violadas y en base a sus gradientes calcula los Lambdas.
  Problema.EstimarMultiplicadores(X, 2);

  dx := PaintBox1.Width;
  dy := PaintBox1.Height;
  c := PaintBox1.Canvas;
  x0 := dx div 2;
  y0 := dy div 2;
  m := 50;

  c.MoveTo(x0, dy);
  c.LineTo(x0, 0);
  c.LineTo(x0 - 5, 10);
  c.LineTo(x0 + 5, 10);
  c.LineTo(x0, 0);


  c.MoveTo(0, y0);
  c.LineTo(dx, y0);
  c.LineTo(dx - 10, y0 - 5);
  c.LineTo(dx - 10, y0 + 5);
  c.LineTo(dx, y0);

  c.Brush.Color := clActiveBorder;
  c.Brush.Style := bsFDiagonal;
  c.Rectangle(x0, 0, dx, dy);

  c.Brush.Color := clBlack;
  c.Brush.Style := bsClear;

  c.EllipseC(x0, y0, m * 4, m * 4);

  c.Pen.Color := clBlue;
  for k := 1 to 10 do
    c.EllipseC(x0 + 5 * m, y0 - 5 * m, m * k, m * k);


  punto(X, clRed);

end;


procedure TForm1.flecha_Pv(P, v: TVectR; color: TColor);
var
  x, y: integer;
  x_, y_: integer;
  dx, dy: integer;
  dx_, dy_: integer;
  a: NREal;
begin
  c.Pen.Color := color;

  x := round(x0 + m * P.e(1));
  y := round(y0 - m * P.e(2));
  c.MoveTo(x, y);

  dx := round(m * v.e(1));
  dy := round(-m * v.e(2));
  x := x + dx;
  y := y + dy;
  c.LineTo(x, y);

  a := sqrt(sqr(dx) + sqr(dy));
  if (a > 1E-12) then
  begin
    dx := round(10 * dx / a);
    dy := round(10 * dy / a);
  end
  else
  begin
    dx := 0;
    dy := 0;
  end;

  dx_ := -round(dy / 2.0);
  dy_ := round(dx / 2.0);

  x_ := x - dx;
  y_ := y - dy;
  x_ := x_ + dx_;
  y_ := y_ + dy_;
  c.LineTo(x_, y_);

  x_ := x_ - 2 * dx_;
  y_ := y_ - 2 * dy_;
  c.LineTo(x_, y_);

  c.LineTo(x, y);

end;

procedure TForm1.flecha_AB(A, B: TVectR; color: TColor);
var
  v: TVectR;
begin
  v := TVectR.Create_init(2);
  v.Igual(B);
  v.sumRPV(-1.0, A);
  flecha_Pv(A, v, color);
  v.Free;
end;



procedure TForm1.punto(X: TVectR; color: TColor);
begin
  c.Pen.Color := Color;
  c.EllipseC(round(x0 + m * x.e(1)), round(y0 - m * x.e(2)), 4, 4);
end;

function TProblema_ej1.Monitor(const X, Xs: TVectR; f, fs: NReal;
  paso_ok: boolean): boolean;
begin

  inherited Monitor(X, Xs, f, fs, paso_ok);

  if paso_ok then
    Form1.flecha_AB(X, Xs, clRed)
  else
    Form1.flecha_AB(X, Xs, clBlack);
  Result := False;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  cnt_iters: integer;
  convergio: boolean;
  aR: TResfx;
  k: integer;
  valCosto, valLagrange, dFrontera2: NReal;
begin

  Problema.MaxInBox_Dual(Lambda, X, 1, 1E-20, 1000, cnt_iters, valCosto, ValLagrange, dFrontera2, convergio, True);

  if convergio then
    writeln('CONVERGIO')
  else
    writeln('NO-CONVERGIO');

  writeln('cnt_iters: ', cnt_iters);
  Write('f: ', problema.f.f(X));

  Write('X: ');
  for k := 1 to X.n do
    Write(', ', x.e(k): 12: 3);
  writeln;

  for k := 0 to high(problema.restricciones) do
  begin
    aR := problema.restricciones[k];
    writeln('r_', k + 1, ': ', aR.eval_f(X): 12: 3);
  end;


  Write('Lambda: ');
  for k := 1 to Lambda.n do
    Write(', ', Lambda.e(k): 12: 3);
  writeln;

end;


procedure calc_mx_sx2( var mx, sx2: NReal;  x, p: TVectR );
var
  k: integer;
begin
  mx:= 0;
  for k:= 1 to x.n do
    mx:= mx + p.e(k) * x.e(k);

  sx2:= 0;
  for k:= 1 to x.n do
    sx2:= sx2 + p.e(k) * sqr( x.e(k) - mx );
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  sal: TextFile;
  x: TVectR;
  q, p: TVectR;
  N: INteger;
  k: integer;
  mx, sx2, my, sy2: NReal;
  ksol: integer;
  a, acum: NReal;

procedure ProcesarCaso( idCaso: string; my, sy2: NReal );
var
  k: integer;
  my_r, sy2_r: NReal;

begin
  writeln( 'Procesando: ', idCaso );

  p:= uoptvariadorhistogramas.VariarHistograma(x, q, my, sy2 );
  if p <> nil then
  begin
       calc_mx_sx2( my_r, sy2_r, x, p );
       write( sal, abs( my-my_r ) + abs( sy2 - sy2_r ):12:6, #9, idCaso, #9, my, #9, my_r );
       write( sal,  #9, sy2, #9, sy2_r );
       for k:= 1 to N do write( sal, #9, p.e(k) );
       p.Free;
  end
  else
  begin
      write( sal, 'INF.', #9, idCaso, #9, my, #9, sy2 );
  end;
  writeln( sal );
end;

begin
  N:= 200;
  randseed:= 31;
  x:= TVectR.Create_init( N );
  p:= TVectR.Create_init( N );
  q:= TVectR.Create_init( N );


  assignfile( sal, 'c:\basura\varhisto_series.xlt' );
  rewrite( sal );

  for k:= 1 to N do
    x.pon_e(k, random *10 );

  x.Sort(true);
  write( sal, 'x', #9 );
  x.WriteXLTSimple( sal );

  acum:= 0;
  for k:= 1 to N do
  begin
    a:= random;
    acum:= acum + a;
    q.pon_e(k, a );
  end;
  q.PorReal( 1/ acum );
  write( sal, 'q', #9 );
  q.WriteXLTSimple( sal );
  closefile( sal );

  calc_mx_sx2( mx, sx2, x, q );

  assignfile( sal, 'c:\basura\varhisto.xlt' );
  rewrite( sal );

  write( sal,'err', #9, 'k', #9, 've_p', #9, 'var_p', #9, 've_r', #9, 'var_r' );
  for k:= 1 to N do write( sal, #9, k );
  writeln( sal );

  write( sal,'err', #9, 'x', #9, mx, #9, sx2, #9, mx, #9, sx2 );
  for k:= 1 to N do write( sal, #9, x.e(k) );
  writeln( sal );

  write( sal, 'err', #9,'q', #9, 0, #9, 0, #9, 0, #9, 0 );
  for k:= 1 to N do write( sal, #9, q.e(k) );
  writeln( sal );

// Caso_1
  my:= 1.9451169111;
  sy2:= 62.1172210285;
  ProcesarCaso( 'Caso_1e1', my, sy2 );

// solo para porbar si da lo mismo
  my:= 1.9451169111;
  sy2:= 62.1172210285;
  ProcesarCaso( 'Caso_1e2', my, sy2 );


  for ksol:= 1 to 100 do
  begin
    my:= ( x.e( N ) - x.e(1) )* random + x.e(1);
    sy2:= max( sqr(x.e(N)-my), sqr( my - x.e(1))) * random;
    ProcesarCaso( 'ksol_'+IntToStr( ksol ), my, sy2 );
  end;

  closefile( sal );
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  vel, pot: TVectR;
  f: textfile;
  convergio: boolean;

  Problema: TProblema_CurvaS;
  ValCosto, ValLagrange, dFrontera2: NReal;

begin
  filemode:= 0;
  assignfile( f, 'C:\simsee\SimSEE_src\src\trunk\rchlib\mat\miner2012\c19datoscluster_13_mal2.txt' );
  reset( f );
  vel:= TVectR.CreateLoadFromFile( f );
  pot:= TVectR.CreateLoadFromFile( f );

  PMax:= 50; // PMax   50
  dP:= 13.82; // dp       13.82
  alfa:= 0.58; // alfa  0.58
  vm:= 2.29; // vm       2.29


(*  randomize;
  alfa:= alfa* (1 +(random-0.5)/10 );
  vm:= vm* (1 +(random-0.5)/10 );
  pmax:= pmax* (1 +(random-0.5)/10 );
  dp:= dp* (1 +(random-0.5)/10 );

  convergio:= resolverCurvaS(vel, pot, alfa, vm, pmax, dp, 50);
  writeln( alfa: 12:2, vm: 12:2, pmax:12:2, dp:12:2 );

  *)


  Problema:= TProblema_CurvaS.Create( PaintBox1, vel, pot, 50.0 );
  convergio:= Problema.resolverCurvaS( alfa, vm, pmax, dp, ValCosto, ValLagrange, dFrontera2 );


  writeln( 'ValCosto: ', ValCosto,', ValLagrange: ', ValLagrange,', dFrontera2: ', dFrontera2 );
  if convergio then
    writeln('Convergio, f: ', Problema.f.f( problema.x_sol ) )
  else
    writeln('NO-Convergió');
  (*
  convergio:= resolverCurvaS_Md2(vel, pot, alfa, vm, pmax, dp, 50);

  *)
  writeln( 'PMáx: ', pmax:12:2, ', dp: ', dp:12:2, ', alfa: ', alfa: 12:2,', vm: ', vm: 12:2 );

end;

procedure TForm1.Button5Click(Sender: TObject);
begin
    //randomize;
  alfa:= alfa* (1 +(random-0.5) );
  vm:= vm* (1 +(random-0.5));
  pmax:= pmax* (1 +(random-0.5) );
  dp:= dp* (1 +(random-0.5));

  Button4Click( sender );

end;


procedure  calcCoord( var ax, ay: NReal;
  PVertice, xCentro, vx, vy: TVectR );
var
  y: TVectR;
begin
  y:= TVectR.Create_Clone( PVertice );
  y.sumRPV( -1, xCentro);
  ax:= y.PEV( vx );
  ay:= y.PEV( vy );
  y.Free;
end;

procedure  calcPunto( var Punto: TVectR; ax, ay: NReal; xCentro, vx, vy: TVectR );
begin
  Punto.Igual( xCentro );
  Punto.sumRPV( ax, vx );
  Punto.sumRPV( ay, vy );
end;



procedure extremos( var amin, amax: NREal; aval : NReal );
begin
  if aval < amin then
    amin:= aval
  else if aval > amax then
    amax:= aval;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  vel, pot: TVectR;
  f: textfile;
  Problema: TProblema_CurvaS;
  Punto, xCentro, vx, vy: TVectR;

  min_x, max_x, min_y, max_y, min_f, max_f: NReal;
  k, j, kVertice: integer;
  a, ax, ay, af, aL, dFrontera: NREal;

  violadas: TList;
  EscalaColor: TEscalaColor;
  mx, my: NReal;
  color: TColor;
  flg_minf: Boolean;

begin
  violadas:= TList.Create;

  // Dado un punto y una dirección exploramos el esacio en corte del plano
  // que pasa por el punto y es normal a la dirección dada
  filemode:= 0;
  assignfile( f, 'C:\simsee\SimSEE_src\src\trunk\rchlib\mat\miner2012\c19datoscluster_13_mal.txt' );
  reset( f );
  vel:= TVectR.CreateLoadFromFile( f );
  pot:= TVectR.CreateLoadFromFile( f );
  closefile( f );

  Problema:= TProblema_CurvaS.Create( PaintBox1, vel, pot, 50.0 );

  xCentro:= TVectR.Create_Init( Problema.x_inf.n );
  for k:= 1 to xCentro.n do
    xCentro.pon_e( k, ( Problema.x_inf.e(k) + Problema.x_sup.e(k) ) / 2.0 );

  vx:= TVectR.Create_Init( xCentro.n );
  vy:= TVectR.Create_Init( xCentro.n );
  (*
  vx.versor_randomico;
  vy:= TVectR.Create_Clone(vx);
  vy.pon_e(1, 1.2 );
  a:= vy.PEV(vx );
  vy.sumRPV( -a , vx );
  vy.HacerUnitario;
  *)

  (** PLANO alfa vm
  xCentro.pon_e( 1, 50 );
  xCentro.pon_e( 2, 0 );
  xCentro.pon_e( 3, 0 );
  xCentro.pon_e( 4, 0 );

  vx.Ceros;
  vx.pon_e( 3, 1 );
  vy.Ceros;
  vy.pon_e( 4, 1 );
                    *)
  (**  Plnao Pmax, dp *)
  xCentro.pon_e( 1, 50 );
  xCentro.pon_e( 2, 0 );
  xCentro.pon_e( 3, 0.5 );
  xCentro.pon_e( 4, 5 );

  vx.Ceros;
  vx.pon_e( 1, 1 );
  vy.Ceros;
  vy.pon_e( 2, 1 );



  Punto:= TVectR.Create_Init( xCentro.n );
  kVertice:= 0;
  Problema.CopyVertice( Punto, kVertice );
  kVertice:= Problema.NextkVertice( kVertice );

  calcCoord( ax, ay, Punto, xCentro, vx, vy );
  dFrontera:= problema.calcular_fs( violadas, af, aL, Punto );
  min_x:= ax;
  max_x:= ax;
  min_y:= ay;
  max_y:= ay;
  min_f:= af;
  max_f:= af;
  while kVertice > 0 do
  begin
    Problema.CopyVertice( Punto, kVertice );
    kVertice:= Problema.NextkVertice( kVertice );
    dFrontera:= problema.calcular_fs( violadas, af, aL, Punto );
    calcCoord( ax, ay, Punto, xCentro, vx, vy );
    extremos( min_x, max_x, ax );
    extremos( min_y, max_y, ay );
    extremos( min_f, max_f, af );
  end;

  min_f:= 100;
  max_f:= 3000;

  EscalaColor:= TEscalaColor.Create( min_f, max_f );

  mx:= (max_f-min_f) / PaintBox2.width;

  for k:= 0 to PaintBox2.Width-1 do
  begin
    color := EscalaColor.Color( k * mx + min_f );
   for j:= 0 to PaintBox2.Height -1 do
     PaintBox2.Canvas.Pixels[ k, j ]:= color;
  end;


  flg_minf:= false;

  mx:= (max_x - min_x ) / PaintBox1.width;
  my:= (max_y - min_y ) / PaintBox1.Height;
  for k:= 0 to PaintBox1.Width-1 do
   for j:= 0 to PaintBox1.Height -1 do
   begin
     ax:= k * mx + min_x;
     ay:= (PaintBOx1.Height - j)* my + min_y;
     calcPunto( Punto, ax, ay, xCentro, vx, vy );
     dFrontera:= problema.calcular_fs( violadas, af, aL, Punto );
     if not flg_minf then
     begin
          min_f:= af;
          max_f:= af;
          flg_minf:= true;
     end
     else
       extremos( min_f, max_f, af );
     if ( dFrontera > 1E-20 ) and( (( k+j) mod 2 ) = 0 ) then
        PaintBox1.Canvas.Pixels[k, j]:= clBlack
     else
        PaintBox1.Canvas.Pixels[k, j]:= EscalaColor.Color( af );
   end;

  writeln( 'MinF: ', min_f, ', MaxF: ', max_f );
end;


procedure PuntoTod(var d: NReal; Punto, xCentro, vd: TVectR );
var
  y: TVectR;
begin
  y:= TVectR.Create_Clone( Punto );
  y.sumRPV( -1, xCentro );
  d:= y.PEV( vd );
  y.Free;
end;

procedure dToPunto( var Punto: TVectR; d: NReal; xCentro, vd: TVectR );
begin
  Punto.Igual( xCentro );
  Punto.sumRPV( d, vd );
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  vel, pot: TVectR;
  f: textfile;
  Problema: TProblema_CurvaS;
  Punto, xCentro, vd: TVectR;

  min_d, max_d, min_f, max_f: NReal;
  k, j, kVertice: integer;
  a, d, af, aL, dFrontera: NREal;

  violadas: TList;
  EscalaColor: TEscalaColor;
  mx, my: NReal;
  g_f, g_L: TVectR;
  sal: textfile;
  cnt: integer;

begin
  violadas:= TList.Create;

  // Dado un punto y una dirección exploramos el esacio en corte del plano
  // que pasa por el punto y es normal a la dirección dada
  filemode:= 0;
  assignfile( f, 'C:\simsee\SimSEE_src\src\trunk\rchlib\mat\miner2012\c19datoscluster_13_mal.txt' );
  reset( f );
  vel:= TVectR.CreateLoadFromFile( f );
  pot:= TVectR.CreateLoadFromFile( f );
  closefile( f );

  Problema:= TProblema_CurvaS.Create( PaintBox1, vel, pot, 50.0 );

  xCentro:= TVectR.Create_Init( Problema.x_inf.n );
  xCentro.pon_e(1, 50 ); // PMax   50
  xCentro.pon_e(2, 0 ); // dp       13.82
  xCentro.pon_e(3, 0.5 ); // alfa  0.58
  xCentro.pon_e(4, 7 ); // vm       2.29


  xCentro.pon_e(1, 50 ); // PMax   50
  xCentro.pon_e(2, 13.82 ); // dp       13.82
  xCentro.pon_e(3, 0.58 ); // alfa  0.58
  xCentro.pon_e(4, 2.29 ); // vm       2.29


  g_f:= TVectR.Create_Init( xCentro.n );
  g_L:= TVectR.Create_init( xCentro.n );

  dFrontera:= problema.calcular_fs( violadas, af, aL, xCentro );
  problema.calcular_gs( violadas,  g_f, g_L, xCentro );

  vd:= TVectR.Create_Clone( g_f );
  vd.PorReal( -1 );
  vd.HacerUnitario;

  Punto:= TVectR.Create_Init( xCentro.n );
  kVertice:= 0;
  Problema.CopyVertice( Punto, kVertice );
  kVertice:= Problema.NextkVertice( kVertice );
  PuntoTod( d, Punto, xCentro, vd );
  dFrontera:= problema.calcular_fs( violadas, af, aL, Punto );
  min_d:= d;
  max_d:= d;
  min_f:= af;
  max_f:= af;
  while kVertice > 0 do
  begin
    Problema.CopyVertice( Punto, kVertice );
    kVertice:= Problema.NextkVertice( kVertice );
    dFrontera:= problema.calcular_fs( violadas, af, aL, Punto );
    PuntoTod( d, Punto, xCentro, vd );
    extremos( min_d, max_d, d );
    extremos( min_f, max_f, af );
  end;

  EscalaColor:= TEscalaColor.Create( min_f, max_f );

  assignfile( sal, 'c:\basura\trayextoria.xlt' );
  rewrite( sal );

  cnt:= 0;
  mx:= (max_d - min_d ) / PaintBox1.width;
  my:= (max_f - min_f ) / PaintBox1.Height;

  repeat

  writeln( sal );
  writeln( sal, 'd',#9,'PMáx',#9,'dp',#9,'alfa',#9,'vm',#9,'fCosto',#9,'dFrontera' );
  for k:= 0 to PaintBox1.Width-1 do
   begin
     d:= k * mx + min_d;
     dToPunto( Punto, d, xCentro, vd );
     dFrontera:= problema.calcular_fs( violadas, af, aL, Punto );
     write( sal, d );
     for j:= 1 to Punto.n do
       write( sal, #9, Punto.e( j ) );
     writeln( sal, #9, af, #9, dFrontera );
     j:= trunc( PaintBox1.height - (af- min_f)/my + 0.5);
     if dFrontera > 1E-20 then
        PaintBox1.Canvas.Pixels[k,j]:= clBlack
     else
        PaintBox1.Canvas.Pixels[k,j]:= EscalaColor.Color( af );
   end;
  inc( cnt );
  vd.versor_randomico;
  until cnt = 10;;
  closefile( sal );
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   alfa:= 0.5;
  vm:= 7;
  pmax:= 55;
  dp:= 5;

end;

procedure TForm1.Label2Click(Sender: TObject);
begin

end;

end.

