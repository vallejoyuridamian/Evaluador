unit ucerebro_01;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, uneuronas, fddp, udisnormcan,
  ufechas,
  Math,
  xmatdefs, matreal, matent, matbool,
  ugaussiana_multivar,
  useriestemporales;

type

  { TForm1 }

  TForm1 = class(TForm)
    btSelSeries: TButton;
    btCalcCovars: TButton;
    btLoadSeries: TButton;
    btVerosimilitud: TButton;
    btTest01: TButton;
    btCrearCerebro: TButton;
    btPerceptronSTEP: TButton;
    btDecPaso: TButton;
    btIncPaso: TButton;
    btAgregarTIpoDia: TButton;
    btWriteTiposDeDia: TButton;
    cbGuardar: TCheckBox;
    cbLeerParametros: TCheckBox;
    eArchi: TLabeledEdit;
    ePaso: TEdit;
    eVerosimilitud: TEdit;
    eNRetardos: TLabeledEdit;
    eUmbralFiltro: TLabeledEdit;
    eN1_bias: TLabeledEdit;
    eN1_ro: TLabeledEdit;
    eN2_bias: TLabeledEdit;
    eN2_ro: TLabeledEdit;
    eN3_bias: TLabeledEdit;
    eN3_ro_1: TLabeledEdit;
    eN3_ro_2: TLabeledEdit;
    OpenDialog1: TOpenDialog;
    PaintBox1: TPaintBox;
    procedure btAgregarTIpoDiaClick(Sender: TObject);
    procedure btCrearCerebroClick(Sender: TObject);
    procedure btDecPasoClick(Sender: TObject);
    procedure btIncPasoClick(Sender: TObject);
    procedure btPerceptronSTEPClick(Sender: TObject);
    procedure btSelSeriesClick(Sender: TObject);
    procedure btCalcCovarsClick(Sender: TObject);
    procedure btLoadSeriesClick(Sender: TObject);
    procedure btTest01Click(Sender: TObject);
    procedure btVerosimilitudClick(Sender: TObject);
    procedure btWriteTiposDeDiaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure CargueParametrosPrueba;
    procedure PrintParametrosPrueba;
    { private declarations }
  public
    { public declarations }

    nRetardos: integer;
    umbral_filtro: NReal;
    series: TSeriesDeDatos;
    CalcCovars: TCalculadorCovars;

    parametros_mejor: TDAOfNReal;
    cntEvaluaciones: integer;
    fMejor: NReal;
    Cerebro: TCerebro;

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btSelSeriesClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    if series <> nil then
    begin
      series.Free;
      series := nil;
      CalcCovars.Free;
      CalcCovars := nil;
    end;
    eArchi.Text := OpenDialog1.FileName;
  end;
end;

procedure TForm1.btCrearCerebroClick(Sender: TObject);
var
  CapasDef: TDAofNInt;
  k: integer;
  aCapa: TCapaNeuronas;
  aNeurona: TNeurona;

begin
  if Cerebro <> nil then
    Cerebro.Free;
  setlength(CapasDef, 2);
  CapasDef[0] := series.NSeriesX * 2;
  CapasDef[1] := series.NSeriesY;

  Cerebro := TCerebro.Create( series.NSeriesX * (1 + nRetardos), CapasDef, false );

  setlength(parametros_mejor, Cerebro.DimParametros);

  randomize;
  Cerebro.RandomInit( 1 );



  eN1_bias.text:= FloatToStr( -12.8 * 0.386 );
  eN1_ro.Text:= FloatToStr( -0.386 );

  eN2_bias.text:= FloatToStr(27.5 * 0.146 );
  eN2_ro.text:= FloatToStr( 0.146 );

  eN3_bias.text:= FloatToStr( -85.7*4 );
  eN3_ro_1.text:= FloatToStr( 54.2*4 );
  eN3_ro_2.text:= FloatToStr( 184.9*4 );

  cntEvaluaciones := 0;
  fMejor := -1E20;
end;

procedure TForm1.btAgregarTIpoDiaClick(Sender: TObject);
var
  sTemp, sE, tipoDia: TVectR;
  dt0, dt, ddt: TDateTime;
  td: NReal;
  kPunto, kHora: integer;
  sal: textfile;
  acum_e, acum_temp: NReal;

begin
  if series <> nil then
    begin
      series.Free;
    end;
    series := TSeriesDeDatos.CreateFromArchi(eArchi.Text);
    sE:= series.series[0];
    sTemp:= series.series[1];
    tipoDia:= TVectR.Create_Init( series.NPuntos );
    dt0:= series.dtPrimeraMuestra;
    ddt:= series.dtEntreMuestras;
    for kPunto:= 1 to tipoDia.n do
    begin
      dt:= dt0 + ( kPunto - 1 ) * ddt;
      td:=  ord( TipoDeDiaUruguay( dt ) );
      tipoDia.pon_e( kPunto, td );
    end;
    series.AddSerie('TipoDia', tipoDia, ENTRADA );
    series.WriteToArchi( 'c:\basura\serie_con_tipodia.xlt' );

    assignfile( sal, 'c:\basura\dem_diaria_temp_tipodia.xlt' );
    rewrite( sal );
    for kHora:= 1 to 23 do
     write( sal, #9, kHora );

    writeln( sal, #9, 'EDia_MWh',#9,'TipoDia',  #9, 'TempDia_grC' );

    kHora:= 0;

    for kPunto:= 1 to tipoDia.n do
    begin
      dt:= dt0 + ( kPunto - 1 ) * ddt;
      if kHora = 0 then
      begin
        write( sal, DateTimeToIsoStr( dt ) );
        acum_temp:=0;
        acum_e:= 0;
        td:= tipoDia.e( kPunto );
      end;
      acum_temp:= acum_temp + sTemp.e( kPunto );
      acum_e:= acum_e + sE.e( kPunto );
      write( sal, #9, sE.e( kPunto ) );
      inc( kHora );
      if kHora = 24 then
      begin
        writeln( sal, #9, acum_e,#9, td,  #9, acum_temp/24 );
        kHora:= 0;
      end;
    end;
    closefile( sal );


    series.Free;
    series:= nil;
end;


procedure TForm1.CargueParametrosPrueba;
var
    aNeurona: TNeuronaConEntradas;

begin
  aNeurona := Cerebro.capas[0].Neuronas[0] as TNeuronaConEntradas;
  aNeurona.bias := strToFloat( eN1_bias.text );
  aNeurona.ro[0] := StrToFloat( eN1_ro.text );

  aNeurona := Cerebro.capas[0].Neuronas[1] as TNeuronaConEntradas;
  aNeurona.bias := StrToFloat( eN2_bias.text );
  aNeurona.ro[0] := StrToFloat( eN2_ro.text );

  aNeurona := Cerebro.capas[1].Neuronas[0] as TNeuronaConEntradas;
  aNeurona.bias := StrToFloat( eN3_bias.text );
  aNeurona.ro[0] := StrToFloat( eN3_ro_1.text );
  aNeurona.ro[1] := StrToFloat( eN3_ro_2.text );

end;


procedure TForm1.PrintParametrosPrueba;
var
    aNeurona: TNeuronaConEntradas;

begin
  aNeurona := Cerebro.capas[0].Neuronas[0] as TNeuronaConEntradas;
  eN1_bias.text:= FloatToStr( aNeurona.bias);
  eN1_ro.Text:= FloatToStr( aNeurona.ro[0] );

  aNeurona := Cerebro.capas[0].Neuronas[1] as TNeuronaConEntradas;
  eN2_bias.text:= FloatToStr( aNeurona.bias );
  eN2_ro.text:= FloatToStr( aNeurona.ro[0] );

  aNeurona := Cerebro.capas[1].Neuronas[0] as TNeuronaConEntradas;
  eN3_bias.text := FloatToStr( aNeurona.bias );
  eN3_ro_1.text := FloatToStr( aNeurona.ro[0] );
  eN3_ro_2.text := FloatToStr( aNeurona.ro[1] );

end;


procedure TForm1.btDecPasoClick(Sender: TObject);
begin
  ePaso.Text := FloatToStr(StrToFloat(epaso.Text) / 3);
end;

procedure TForm1.btIncPasoClick(Sender: TObject);
begin
  ePaso.Text := FloatToStr(StrToFloat(epaso.Text) * 2);
end;



procedure CargueX(var crb: TCerebro; series: TSeriesDedatos; kPaso: integer);
var
  j: integer;
begin
  for j := 0 to series.NSeriesX - 1 do
    crb.SetEntrada( j, series.seriesX[j].pv[kPaso] );
end;

function sin_huecos(const X: TDAofNReal; umbral_filtro: NReal): boolean;
var
  k: integer;
begin
  Result := True;
  for k := 0 to high(X) do
    if x[k] <= umbral_filtro then
    begin
      Result := False;
      break;
    end;
end;


procedure encajone(var xmin, xmax: NReal; x: NReal);
begin
  if x < xmin then
    xmin := x
  else if x > xmax then
    xmax := x;
end;

procedure cruz(canvas: TCanvas; x, y, h: integer);
begin
  canvas.MoveTo(x - h, y);
  canvas.lineTo(x + h, y);
  canvas.MoveTo(x, y - h);
  canvas.LineTo(x, y + h);
end;

procedure Rombo(canvas: TCanvas; x, y, h: integer);
begin
  canvas.MoveTo(x, y - h);
  canvas.LineTo(x - h, y);
  canvas.LineTo(x, y + h);
  canvas.LineTo(x + h, y);
  canvas.LineTo(x, y - h);
end;


procedure PlotXY(Canvas: TCanvas; W, H: integer; x, y, z: TVectR; huecos: TVectBool);
var
  k: integer;
  xmin, xmax, ymin, ymax, zmin, zmax: NReal;
  mx, my: NReal;
  a: NReal;
  px, py: integer;
begin
  xmin := x.e(1);
  xmax := xmin;
  ymin := y.e(1);
  ymax := ymin;
  zmin := z.e(1);
  zmax := zmin;
  for k := 1 to huecos.N do
    if not huecos.e(k) then
    begin
      encajone(xmin, xmax, x.e(k));
      encajone(ymin, ymax, y.e(k));
      encajone(zmin, zmax, z.e(k));
    end;
  ymin := min(ymin, zmin);
  ymax := max(ymax, zmax);
  mx := W / (xmax - xmin);
  my := H / (ymax - ymin);

  Canvas.Brush.Color := CLWhite;
  Canvas.Rectangle(0, 0, W - 1, H - 1);

  for k := 1 to huecos.N do
    if not huecos.e(k) then
    begin
      px := trunc((x.e(k) - xmin) * mx);

      py := trunc(H - (y.e(k) - ymin) * my);
      canvas.Pen.Color := clBlue;
      cruz(canvas, px, py, 5);

      py := trunc(H - (z.e(k) - ymin) * my);
      canvas.Pen.Color := clRed;
      rombo(canvas, px, py, 5);
    end;

end;


procedure TForm1.btPerceptronSTEPClick(Sender: TObject);
var
  Z: TSeriesDeDatos;
  kSerie, kPaso: integer;
  nombreSerie: string;
  verosimilitud: NReal;
  i: integer;
  parametros_x: TDAofNReal;
  acum: NReal;
  huecos: TVectBool;
begin
  parametros_x := copy(parametros_mejor);

  NRetardos := StrToInt(eNRetardos.Text);
  umbral_filtro := StrToFloat(eUmbralFiltro.Text);

  huecos := TVectBool.Create_Init(series.NPuntos - nRetardos);
  cntEvaluaciones := 0;



  while (cntEvaluaciones < 1000000) do
  begin

  (*
    for i:= 0 to high( parametros_x ) do
      parametros_x[i]:= parametros_mejor[i];
    i:= trunc( length( parametros_mejor ) * random );
    parametros_x[i]:=  parametros_mejor[i] + ( 1 - 2 * random ) *StrToFloat( ePaso.Text );
    Perceptron.SetParametros( parametros_x );
    *)

    if cbLeerParametros.Checked then
      CargueParametrosPrueba
    else
     if cntEvaluaciones > 0 then
       Cerebro.RandomInit(StrToFloat(ePaso.Text));


    Z := TSeriesDeDatos.CreateVacia(series.dtPrimeraMuestra,
      series.PeriodoDeMuestreo_horas, series.NPuntos - nRetardos);

    for kSerie := 0 to series.NSeriesY - 1 do
    begin
      nombreSerie := series.nombresSeries[kSerie];
      Z.AddSerie(nombreSerie);
    end;

    for kPaso := 1 to NRetardos do
      CargueX( Cerebro, series, kPaso);

    for kPaso := NRetardos + 1 to series.NPuntos do
    begin
      CargueX( Cerebro, series, kPaso);
      if sin_huecos(EntradasCapa0, umbral_filtro) then
      begin
        Cerebro.evaluar;
        for kSerie := 0 to Z.NSeries - 1 do
          Z.series[kSerie].pon_e(kPaso - NRetardos, Cerebro.salidas[kserie]);
        huecos.pon_e(kPaso - NRetardos, False);
      end
      else
      begin
        for kSerie := 0 to Z.NSeries - 1 do
          Z.series[kSerie].pon_e(kPaso - NRetardos, umbral_filtro);
        huecos.pon_e(kPaso - NRetardos, True);
      end;
    end;

    // Medimos el error de pronóstico
    acum := 0;
    for kPaso := NRetardos + 1 to series.NPuntos do
      if not huecos.e(kPaso) then
        for kSerie := 0 to Z.NSeries - 1 do
          acum := acum + sqr(Z.series[kSerie].e(kPaso) -
            series.seriesY[kSerie].e(kPaso));


    verosimilitud := -acum / (Z.NSeries * series.NPuntos);
  {
  acum:= 0;
  for kSerie:= 0 to Z.NSeries-1 do
   acum:= acum + abs( z.series[kSerie].Promedio_filtrando( umbral_filtro ) );
  verosimilitud := MaxDiff_CDF_N_I(  z.series, huecos, 31, 100 );

  writeln( 'v: ', verosimilitud, ', acum: ', acum );
  verosimilitud:= - ( verosimilitud+ acum);
   }

{
  CalcCovars.Calc( Z.series );
  verosimilitud:= CalcCovars.Versimilitud_gaussiana( Z.series );
  }
    //  verosimilitud:= CalcCovars.Versimilitud_gaussianaNormal( Z.series );


    Inc(cntEvaluaciones);
    if cntEvaluaciones = 1 then
    begin
      Cerebro.GetParametros(parametros_mejor);
      fMejor := verosimilitud;
      if (Z.NSeries = 1) and (series.NseriesX = 1) then
        plotXY(PaintBox1.Canvas, PaintBox1.Width, PaintBox1.Height,
          series.seriesX[0], series.seriesY[0], Z.series[0], huecos);
    end
    else
    begin
      if verosimilitud > fMejor then
      begin
        Cerebro.GetParametros(parametros_mejor);
        fMejor := verosimilitud;
        if (Z.NSeries = 1) and (series.NseriesX = 1) then
          plotXY(PaintBox1.Canvas, PaintBox1.Width, PaintBox1.Height,
            series.seriesX[0], series.seriesY[0], Z.series[0], huecos);
      end
      else
        Cerebro.SetParametros(parametros_mejor);
      PrintParametrosPrueba;
    end;
    if cbGuardar.Checked then
    begin
      cbGuardar.Checked := False;
      Cerebro.StoreInArchi('cerebro.txt');
      Z.WriteToArchi('series_Z.xlt');
    end;
    eVerosimilitud.Text := FloatToStr(fMejor);

    writeln(verosimilitud);
    Z.Free;

    Application.ProcessMessages;

  end;
end;



procedure TForm1.btCalcCovarsClick(Sender: TObject);
var
  k: integer;
begin
  for k := 0 to series.nombresSeries.Count - 1 do
    writeln(k, ': ', series.nombresSeries[k]);

  CalcCovars.Calc(series.series);
  CalcCovars.PrintToArchi('covars.xlt', series.nombresSeries);
end;

procedure TForm1.btLoadSeriesClick(Sender: TObject);
begin
  if series <> nil then
  begin
    series.Free;
    CalcCovars.Free;
  end;

  series := TSeriesDeDatos.CreateFromArchi(eArchi.Text);
  nRetardos := StrToInt(eNRetardos.Text);
  umbral_filtro := StrToFloat(eUmbralFiltro.Text);
  CalcCovars := TCalculadorCovars.Create(series.NSeries, nRetardos, umbral_filtro);

end;

procedure TForm1.btTest01Click(Sender: TObject);
var
  NPuntos, k: integer;
  x, y, z: TVectR;
  fg: Tf_ddp;
begin

  if series <> nil then
  begin
    series.Free;
    CalcCovars.Free;
  end;

  NPuntos := 100000;

  fg := Tf_ddp_GaussianaNormal.Create(nil, 31);
  // fg:= Tf_ddpUniformeRand3.Create(nil, 31);

  series := TSeriesDeDatos.CreateVacia(now, 1, NPuntos);
  x := TVectR.Create_Init(NPuntos);
  y := TVectR.Create_Init(NPuntos);
  z := TVectR.Create_Init(NPuntos);

  for k := 1 to series.NPuntos do
  begin
    x.pv[k] := fg.rnd;
    y.pv[k] := fg.rnd;
    z.pv[k] := fg.rnd;
    //    y.pv[k]:= 0.3 * x.pv[k] + fg.rnd;
    //    z.pv[k]:= 0.1 * y.pv[k] + 0.5* x.pv[k] + fg.rnd;
  end;

  series.AddSerie('x', x);
  series.AddSerie('y', y);
  series.AddSerie('z', z);

  fg.Free;

  nRetardos := StrToInt(eNRetardos.Text);
  umbral_filtro := StrToFloat(eUmbralFiltro.Text);
  CalcCovars := TCalculadorCovars.Create(series.NSeries, nRetardos, umbral_filtro);
end;

procedure TForm1.btVerosimilitudClick(Sender: TObject);
var
  verosimilitud: NReal;
begin
  verosimilitud := CalcCovars.Versimilitud_gaussiana(series.series);
  eVerosimilitud.Text := FloatToStr(verosimilitud);
end;

procedure TForm1.btWriteTiposDeDiaClick(Sender: TObject);
var
  f: textfile;
  dt, dtFin: TDateTime;
begin
  assignfile( f, 'c:\basura\tiposdedia_from2000.txt' );
  rewrite( f );
  dt:= IsoStrToDateTime( '2000-01-01' );
  dtFin:= now + 365* 5;
  while dt < dtFin do
  begin
    writeln( f, DateTimeToIsoStr( dt ), #9, ord( TipoDeDiaUruguay( dt )  ) );
    dt:= dt + 1.0;
  end;
  closefile( f );


end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  series := nil;
  CalcCovars := nil;
  Cerebro := nil;
end;

end.

