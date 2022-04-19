unit uperceptron_01;
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, uneuronas, fddp, udisnormcan,
  xmatdefs, matreal, matent,
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
    cbGuardar: TCheckBox;
    eArchi: TLabeledEdit;
    ePaso: TEdit;
    eVerosimilitud: TEdit;
    eNRetardos: TLabeledEdit;
    eUmbralFiltro: TLabeledEdit;
    OpenDialog1: TOpenDialog;
    procedure btCrearCerebroClick(Sender: TObject);
    procedure btDecPasoClick(Sender: TObject);
    procedure btIncPasoClick(Sender: TObject);
    procedure btPerceptronSTEPClick(Sender: TObject);
    procedure btSelSeriesClick(Sender: TObject);
    procedure btCalcCovarsClick(Sender: TObject);
    procedure btLoadSeriesClick(Sender: TObject);
    procedure btTest01Click(Sender: TObject);
    procedure btVerosimilitudClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
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

    // vector de entrada al Perceptron
    EntradasCapa0: TDAofNReal;

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
      series:= nil;
      CalcCovars.Free;
      CalcCovars:= nil;
    end;
    eArchi.Text:=OpenDialog1.FileName;
  end;
end;

procedure TForm1.btCrearCerebroClick(Sender: TObject);
var
  CapasDef: TDAofNInt;
  k: integer;
  aCapa: TCapaNeuronas;
  aNeurona: TNeurona;

begin
  if Cerebro <> nil then Cerebro.Free;
  setlength( CapasDef, 2 );
  CapasDef[0]:= series.NSeries*4;
  CapasDef[1]:= series.NSeries;
  setlength( EntradasCapa0, series.NSeries * (1+nRetardos) );

  Cerebro:= TCerebro.Create( EntradasCapa0, CapasDef );

  setlength( parametros_mejor, Cerebro.DimParametros );

  randomize;
  Cerebro.RandomInit;
  cntEvaluaciones:=0;
  fMejor:=-1E20;
end;

procedure TForm1.btDecPasoClick(Sender: TObject);
begin
  ePaso.Text:= FloatToStr( StrToFloat( epaso.Text ) / 3 );
end;

procedure TForm1.btIncPasoClick(Sender: TObject);
begin
    ePaso.Text:= FloatToStr( StrToFloat( epaso.Text ) *2 );
end;



procedure Cargue( var X: TDAofNReal; series: TSeriesDedatos; kPaso: integer );
var
  j: integer;
begin
  for j:= high( X ) downto series.nSeries do
   x[j]:= x[j-series.nSeries];
  for j:= 0 to series.NSeries-1 do
   x[j]:= series.series[j].pv[kPaso];
end;

function sin_huecos(const X: TDAofNReal; umbral_filtro: NReal ): boolean;
var
  k: integer;
begin
  result:= true;
  for k:= 0 to high( X ) do
   if x[k] <= umbral_filtro then
   begin
     result:= false;
     break;
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
begin
  parametros_x:= copy( parametros_mejor );

  while (cntEvaluaciones < 1000000 ) do
  begin

  (*
    for i:= 0 to high( parametros_x ) do
      parametros_x[i]:= parametros_mejor[i];
    i:= trunc( length( parametros_mejor ) * random );
    parametros_x[i]:=  parametros_mejor[i] + ( 1 - 2 * random ) *StrToFloat( ePaso.Text );
    Perceptron.SetParametros( parametros_x );
    *)
  Cerebro.RandomWalk( StrToFloat( ePaso.Text ) );

  NRetardos:= StrToInt( eNRetardos.text );
  umbral_filtro:= StrToFloat( eUmbralFiltro.text );
  Z:= TSeriesDeDatos.CreateVacia(
      series.dtPrimeraMuestra,
      series.PeriodoDeMuestreo_horas,
      series.NPuntos - nRetardos);

  for kSerie:= 0 to series.NSeries - 1 do
  begin
    nombreSerie:= series.nombresSeries[kSerie];
    Z.AddSerie( nombreSerie );
  end;

  for kPaso := 1 to NRetardos do
   Cargue( EntradasCapa0, series, kPaso );

  for kPaso:= NRetardos  + 1 to series.NPuntos do
  begin
    Cargue( EntradasCapa0, series, kPaso );
    if sin_huecos( EntradasCapa0, umbral_filtro ) then
    begin
      Cerebro.evaluar;
      for kSerie:= 0 to Z.NSeries-1 do
        Z.series[kSerie].pon_e( kPaso - NRetardos, Cerebro.salidas[ kserie ]);
    end
    else
    begin
      for kSerie:= 0 to Z.NSeries-1 do
        Z.series[kSerie].pon_e( kPaso - NRetardos, umbral_filtro);
    end;
  end;

  CalcCovars.Calc( Z.series );
  verosimilitud:= CalcCovars.Versimilitud_gaussiana( Z.series );
//  verosimilitud:= CalcCovars.Versimilitud_gaussianaNormal( Z.series );
  inc( cntEvaluaciones );
  if cntEvaluaciones = 1 then
  begin
    Cerebro.GetParametros( parametros_mejor );
    fMejor:= verosimilitud;
  end
  else
  begin
    if verosimilitud >= fMejor then
    begin
      Cerebro.GetParametros( parametros_mejor );
      fMejor:= verosimilitud;
    end
    else
      Cerebro.SetParametros( parametros_mejor );
  end;
  if cbGuardar.Checked then
  begin
    cbGuardar.Checked:= false;
    Cerebro.StoreInArchi( 'cerebro.txt' );
    Z.WriteToArchi('series_Z.xlt');
  end;
  eVerosimilitud.Text:= FloatToStr( fMejor );

  writeln( verosimilitud );
  Z.Free;

  Application.ProcessMessages;

  end;
end;



procedure TForm1.btCalcCovarsClick(Sender: TObject);
var
  k: integer;
begin
  for k:= 0 to series.nombresSeries.Count -1 do
  writeln( k, ': ', series.nombresSeries[k] );

  CalcCovars.Calc( series.series );
  CalcCovars.PrintToArchi('covars.xlt', series.nombresSeries );
end;

procedure TForm1.btLoadSeriesClick(Sender: TObject);
begin
  if series <> nil then
  begin
    series.Free;
    CalcCovars.Free;
  end;

  series:= TSeriesDeDatos.CreateFromArchi( eArchi.Text );
  nRetardos:= StrToInt( eNRetardos.text );
  umbral_filtro:= StrToFloat( eUmbralFiltro.Text );
  CalcCovars:= TCalculadorCovars.Create( series.NSeries,
     nRetardos, umbral_filtro );

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

  NPuntos:= 100000;

  fg:= Tf_ddp_GaussianaNormal.Create( nil, 31 );
 // fg:= Tf_ddpUniformeRand3.Create(nil, 31);

  series:= TSeriesDeDatos.CreateVacia( now, 1, NPuntos );
  x:= TVectR.Create_Init( NPuntos );
  y:= TVectR.Create_Init( NPuntos );
  z:= TVectR.Create_Init( NPuntos );

  for k:= 1 to series.NPuntos do
  begin
    x.pv[k]:= fg.rnd;
    y.pv[k]:= fg.rnd;
    z.pv[k]:= fg.rnd;
//    y.pv[k]:= 0.3 * x.pv[k] + fg.rnd;
//    z.pv[k]:= 0.1 * y.pv[k] + 0.5* x.pv[k] + fg.rnd;
  end;

  series.AddSerie('x', x );
  series.AddSerie('y', y );
  series.AddSerie('z', z );

  fg.Free;

  nRetardos:= StrToInt( eNRetardos.text );
  umbral_filtro:= StrToFloat( eUmbralFiltro.Text );
  CalcCovars:= TCalculadorCovars.Create( series.NSeries,
     nRetardos, umbral_filtro );
end;

procedure TForm1.btVerosimilitudClick(Sender: TObject);
var
  verosimilitud: NReal;
begin
  verosimilitud:= CalcCovars.Versimilitud_gaussiana( series.series );
  eVerosimilitud.Text:= FloatToStr( verosimilitud );
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  series:= nil;
  CalcCovars:= nil;
  Cerebro:= nil;
end;

end.

