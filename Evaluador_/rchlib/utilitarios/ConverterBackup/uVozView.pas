{DEFINE CALCULOHFE}
unit uVozView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  WRFFTF01,WRFFTI01,wRFFTB01, xMatDefs, WavIO, AutoCo, ufiltrosf, MPlayer;

const
   msVentana= 100;
   msOverlap= 95;
   MCTamBuff= 1024*3;


type
	LVR1Ptr= ^LVR1;
	LVR1 = array[1..100000] of NReal;


type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
	 Button1: TButton;
	 PaintBox2: TPaintBox;
    Button5: TButton;
    Button6: TButton;
    e_factor_f: TEdit;
    e_f0: TEdit;
    Label2: TLabel;
    cb_factor_f: TCheckBox;
    cb_filtro_h: TCheckBox;
    e_f1: TEdit;
	 e_f2: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    e_ampMax: TEdit;
    Label4: TLabel;
    MediaPlayer1: TMediaPlayer;
    autoplay: TCheckBox;
    lblError: TLabel;
    cbPlots: TCheckBox;
    CheckBox1: TCheckBox;
    Button2: TButton;
	 procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
	 { Private declarations }
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}



procedure TForm1.Button1Click(Sender: TObject);
var
	NData:integer;
	datos:LVR1Ptr; { NData }
	ac,bc:LVR1Ptr;   { NData div 2 }
	a0, maxg:NReal;
	datosi: array[1..MCTamBuff] of smallint;
	success: boolean;
	NSamples: integer;
	Entrada: WaveFile;
	ArchiEntrada: string;
	j, k, leidos: integer;
	OverlapFFT: double;
	kInicio: integer;
	a,b: double;
	xk: integer;
	NTramos: integer;
	dt: TDateTime;
  nacums: integer;
  fhfref: TextFile;
   fMuestreo: integer;
   CTamBuff, CTamOverlap: integer;
   NParaEscribir: integer;

begin



	ArchiEntrada:= 'c:\basura\wavvox\inx2565.wav';

	entrada:= WaveFile.Init;
	entrada.OpenForRead( ArchiEntrada, success );


   fMuestreo:= entrada.SamplingRate;
   CTamBuff:= (fMuestreo * msVentana) div 1000;
	OverlapFFT:= msOverlap/ msVentana;
   CTamOverlap:= trunc((1-OverlapFFT)* CTamBuff);


	NSamples:= entrada.numSamples;
	NData:= CTamBuff;
	GetMem(ac, (NData div 2) * SizeOf(NReal));
	GetMem(bc, (NData div 2) * SIzeOf(NReal));
	wRFFTI01.Init(NData);
	GetMem(datos, NData*SizeOf(NReal));

	NParaEscribir:=trunc(CTamBuff *(1-overlapFFT));
	NTramos:= trunc((NSamples-CTamBuff*overlapFFT)/NParaEscribir);

	dt:= Now;


// inicializamos registro de espectro
  nacums:= 0;

	for j:= 1 to NTramos do
	begin
		kInicio:=trunc((j-1)* CTamBuff *(1-overlapFFT));

		entrada.Seek(kInicio, success);
		entrada.ReadSampleData (CTamBuff,leidos,datosi );
		for k:= 1 to leidos do
		begin
			datos^[k]:= datosi[k]-128;
		end;
		FFTF(datos^,a0, ac^,bc^);
		a0:= sqrt(a0*a0);
		maxg:= a0;

    inc( nacums );

		for k:= 1 to (NData div 2 ) do
		begin
			a:=ac^[k];
			b:=bc^[k];
			ac^[k]:= sqrt(a*a+b*b);

			if ac^[k] > maxg then
				maxg:= ac^[k];
			if abs( a ) < 1e-6 then
				if b > 0 then
					bc^[k]:= 90
				else
					bc^[k]:= -90
			else
				bc^[k]:= arctan( b/a )/pi*180;
		end;

      if maxg< 0.1 then maxg:= 1;
		PaintBOx1.Canvas.FillRect( Rect( 0,0, PaintBox1.width, PaintBox1.Height ));
		PaintBox1.Canvas.TextOut(0, 5, 'maxg: '+FloatToStr(maxg));
		PaintBox1.Canvas.TextOut(0, 20, 'Tini: '+FloatToStr(kInicio/entrada.SamplingRate));
		PaintBox1.Canvas.MoveTo(0,trunc( PaintBox1.Height *(1- a0/maxg )));

		PaintBOx2.Canvas.FillRect( Rect( 0,0, PaintBox1.width, PaintBox1.Height ));
		PaintBox2.Canvas.MoveTo(0, PaintBox2.Height div 2);
		for k:= 1 to (NData div 2 ) do
		begin
			xk:=trunc( k/(NData div 2 )* PaintBox1.Width );
			PaintBox1.Canvas.LineTo(
				xk,
				trunc(PaintBox1.Height*(1- ac^[k]/maxg ) ));
{
			PaintBox2.Canvas.LineTo(
				xk,
				trunc( PaintBox2.Height* (0.5 -bc^[k]/360)));
 }
		end;
		sleep(16);
	end;
	dt:= (dt-Now)*24*60*60;
	PaintBox1.Canvas.TextOut(0, 35, 'dt: '+FloatToStr(dt));

	FreeMem(bc, (NData div 2) * SIzeOf(real));
	FreeMem(ac, (NData div 2) * SizeOf(real));
	FreeMem(datos, NData*SizeOf(real));

	assignFile( fhfref, 'c:\basura\wavvox\mcalo.hf');
	rewrite(fhfref);
	for k:= 1 to (NData div 2 ) do
	begin


  end;
  closeFile( fhfref );

end;



procedure TForm1.Button5Click(Sender: TObject);
var
	NData:integer;
	datos:LVR1Ptr; { NData }
	ming, maxg, deltam:NReal;
	datosi: array[1..MCTamBuff] of smallint;
	success: boolean;
	NSamples: integer;
	Entrada: WaveFile;
	ArchiEntrada: string;
	j, k, leidos: integer;
	OverlapFFT: double;
	kInicio: integer;
	a,b: double;
	xk: integer;
	NTramos: integer;
	dt: TDateTime;
   NParaEscribir: integer;

   fMuestreo: integer;
   CTamBuff, CTamOverlap: integer;

begin

	ArchiEntrada:= 'c:\basura\wavvox\inx2565.wav';

	entrada:= WaveFile.Init;
	entrada.OpenForRead( ArchiEntrada, success );
	NSamples:= entrada.numSamples;

   fMuestreo:= entrada.SamplingRate;
   CTamBuff:= (fMuestreo * msVentana) div 1000;
	OverlapFFT:= msOverlap/ msVentana;
   CTamOverlap:= trunc((1-OverlapFFT)* CTamBuff);

	NData:= CTamBuff;

	GetMem(datos, NData*SizeOf(NReal));
	NParaEscribir:=trunc(CTamBuff *(1-overlapFFT));
	NTramos:= trunc((NSamples-CTamBuff*overlapFFT)/NParaEscribir);

	dt:= Now;
	for j:= 1 to NTramos do
	begin
		kInicio:=trunc((j-1)* CTamBuff *(1-overlapFFT));

		entrada.Seek(kInicio, success);
		entrada.ReadSampleData (CTamBuff,leidos,datosi );
		for k:= 1 to leidos do
		begin
			datos^[k]:= datosi[k]-128;
		end;


		AutoCorrelacion(NData, datos^);

		maxg:= datos^[1];
		ming:= datos^[1];
		for k:= 1 to NData do
		begin
			if datos^[k] > maxg then
				maxg:= datos^[k]
			else if datos^[k] < ming then
				ming:= datos^[k];
		end;


		deltam:= maxg-ming;

		deltam:= 10e2;
		maxg:= 5e2;

		PaintBOx1.Canvas.FillRect( Rect( 0,0, PaintBox1.width, PaintBox1.Height ));
		PaintBox1.Canvas.TextOut(0,  5, 'maxg: '+FloatToStr(maxg));
		PaintBox1.Canvas.TextOut(0, 20, 'ming: '+FloatToStr(ming));

		PaintBox1.Canvas.Pen.Color:=clBlue;
		PaintBox1.Canvas.MoveTo(PaintBox1.Width,trunc( PaintBox1.Height *(maxg-0)/deltam));
		PaintBox1.Canvas.LineTo(0,trunc( PaintBox1.Height *(maxg-0)/deltam));
		PaintBox1.Canvas.Pen.Color:=clBlack;

		for k:= 1 to NData do
		begin
			xk:=trunc( k/NData * PaintBox1.Width );
			PaintBox1.Canvas.LineTo(
				xk,
				trunc(PaintBox1.Height*(0.5- datos^[k]/maxg ) ));

		end;
//		sleep(5);
	end;
	dt:= (dt-Now)*24*60*60;
	PaintBox1.Canvas.TextOut(0, 35, 'dt: '+FloatToStr(dt));
	FreeMem(datos, NData*SizeOf(real));

end;

function tan( x: double ): double;
begin
	result:= sin(x)/cos(x);
end;

function ventana_t( kt, NT: integer ): double;
begin
	result:= 1- cos( 2*pi*(kt-1)/NT );
end;
function satU8( i: integer): smallint;
begin
	if i < 0 then result:= 0
	else if i> 255 then result:= 255
	else result:= i;
end;


procedure TForm1.Button6Click(Sender: TObject);
var
	NData:integer;
	datos, datosBuff:LVR1Ptr; { NData }
	ac,bc:LVR1Ptr;   { NData div 2 }
	a0, maxg:NReal;
	datosi: array[1..MCTamBuff] of smallint;
	success: boolean;
	NSamples: integer;
	Entrada, Salida: WaveFile;
	ArchiEntrada: string;
	j, k, leidos: integer;
	OverlapFFT: double;
	kInicio: integer;
	a,b: double;
	xk: integer;
	NTramos: integer;
	dt: TDateTime;
	NParaEscribir: integer;
	escritos: integer;
	desp: integer;
	fs, fbarra: double;
	factorFrecuencia: double;
	kold: integer;
	CorrimientoEnFrecuencia: boolean;
	FiltroH: boolean;
	filtro_h: TFiltroFrecuencia_CosenoAlzado01;
	pesoNuevo: double;
	nacums: integer;
  fhf: textFile;
  acumError: double;

   fMuestreo: integer;
   CTamBuff, CTamOverlap: integer;

begin



	CorrimientoEnFrecuencia:= cb_factor_f.checked;
	FiltroH:= cb_filtro_h.checked;
	if CorrimientoEnFrecuencia then
		factorFrecuencia:= strToFloat(e_factor_f.text)
	else
		factorFrecuencia:= 1;

	if filtroH then
	begin
		filtro_h:= TFiltroFrecuencia_CosenoALzado01.Create(
			strToFloat(e_f0.text), strToFloat(e_f1.text),
			strToFloat( e_f2.text ), strToFloat(e_ampMax.text) );
	end;

	ArchiEntrada:= 'c:\basura\wavvox\inx2565.wav';

	entrada:= WaveFile.Init;
	entrada.OpenForRead( ArchiEntrada, success );
	NSamples:= entrada.numSamples;

   fMuestreo:= entrada.SamplingRate;
   CTamBuff:= (fMuestreo * msVentana) div 1000;
	OverlapFFT:= msOverlap/ msVentana;
   CTamOverlap:= trunc((1-OverlapFFT)* CTamBuff);

	NData:= CTamBuff;

	fs:= entrada.SamplingRate;
	fbarra:= fs/NData;
if autoplay.checked then
begin
	MediaPlayer1.Close;
	MediaPlayer1.FileName:='c:\basura\wavvox\fttb.wav';
end;

	salida:= WaveFile.init;
	salida.OpenForWrite('c:\basura\wavvox\fttb.wav', entrada.SamplingRate, 8,1, success);

	GetMem(ac, (NData div 2) * SizeOf(NReal));
	GetMem(bc, (NData div 2) * SIzeOf(NReal));
	wRFFTI01.Init(NData);
	GetMem(datos, NData*SizeOf(NReal));

	NParaEscribir:=trunc(CTamBuff *(1-overlapFFT));
	NTramos:= trunc((NSamples-CTamBuff*overlapFFT)/NParaEscribir);

	GetMem(datosBuff, NParaEscribir* SIzeOf(NReal) );
	for k:= 1 to NParaEscribir do
		datosBuff^[k]:= 0;

	dt:= Now;

// inicializamos registro de espectro
  nacums:= 0;

	for j:= 1 to NTramos do
	begin
		kInicio:=trunc((j-1)* NParaEscribir);
		entrada.Seek(kInicio, success);
		entrada.ReadSampleData (CTamBuff,leidos,datosi );
		for k:= 1 to leidos do
		begin
			datos^[k]:= ventana_t(k, NData )* (datosi[k]-128.0);
//			datos^[k]:= (datosi[k]-128.0);
		end;
		for k:= leidos+1 to CTamBuff do
			datos^[k]:= 0;
		FFTF(datos^,a0, ac^,bc^);

{ corrimiento en frecuencia }
if CorrimientoEnFrecuencia then
begin
		for k:= (NData div 2) downto 1 do
		begin
			kold:=	trunc( k / factorFrecuencia + 0.5 );
			if kold < 1 then
			begin
				ac^[k]:= 0;
				bc^[k]:= 0;
			end
			else
			begin
				ac^[k]:= ac^[kold];//factorFrecuencia;
				bc^[k]:= bc^[kold];//factorFrecuencia;
			end
		end;
end;


		a0:= sqrt(a0*a0);
		maxg:= a0;

		for k:= 1 to (NData div 2 ) do
		begin
			a:=ac^[k];
			b:=bc^[k];
			ac^[k]:= sqrt(a*a+b*b);

			if ac^[k] > maxg then
				maxg:= ac^[k];
			if abs( a ) < 1e-6 then
				if b > 0 then
					bc^[k]:= 90
				else
					bc^[k]:= -90
			else
				bc^[k]:= arctan( b/a )/pi*180;
		end;


{*************************
aquí realizamos modificaciones. ak tiene las amplitudes
y bk las fases
*************}
      inc(nacums);
		a0:= 0; // mato el término de continua
		for k:= 1 to (NData div 2 ) do
		begin
         if FiltroH then
         begin
 			   ac^[k]:= filtro_h.H( fbarra * k ) * ac^[k];
         end;
		end;


if cbPlots.checked then
begin
		PaintBOx1.Canvas.FillRect( Rect( 0,0, PaintBox1.width, PaintBox1.Height ));
		PaintBox1.Canvas.TextOut(0, 5, 'maxg: '+FloatToStr(maxg));
		PaintBox1.Canvas.TextOut(0, 20, 'Tini: '+FloatToStr(kInicio/entrada.SamplingRate));
		PaintBox1.Canvas.MoveTo(0,trunc( PaintBox1.Height *(1- a0/maxg )));
		PaintBOx2.Canvas.FillRect( Rect( 0,0, PaintBox1.width, PaintBox1.Height ));
		PaintBox2.Canvas.MoveTo(0, PaintBox2.Height div 2);
		for k:= 1 to (NData div 2 ) do
		begin
			xk:=trunc( k/(NData div 2 )* PaintBox1.Width );
			PaintBox1.Canvas.LineTo(
				xk,
				trunc(PaintBox1.Height*(1- ac^[k]/maxg ) ));
		end;

end;





{***********************************************}
{ pasaje al domnio del tiempo                   }

		for k:= 1 to (NData div 2 ) do
		begin
			if abs(abs( bc^[k] ) -90 ) < 1e-6 then
			begin
				ac^[k]:= 0;
				if k> 1 then
					bc^[k]:= bc^[k-1]
				else
					bc^[k]:= 0;
			end
			else
			begin
				a:=ac^[k];
				b:=tan(bc^[k]/180.0*pi);
				ac^[k]:= a/sqrt(b*b+1);
				bc^[k]:= b* ac^[k];
			end;
		end;
		FFTB(datos^,a0, ac^,bc^); // pasaje al tiempo


if cbPlots.checked then
begin
		PaintBOx2.Canvas.FillRect( Rect( 0,0, PaintBox2.width, PaintBox2.Height ));
		PaintBox2.Canvas.MoveTo(0,trunc( PaintBox2.Height /2));
		for k:= 1 to NData do
		begin
//			datos^[k]:= datos^[k]* ventana_t(k, NData);
			xk:=trunc( k/NData* PaintBox2.Width );
			PaintBox2.Canvas.LineTo(
				xk,
				trunc(PaintBox2.Height*(0.5- datos^[k]/200 ) ));
		end;
end;


		if (j<NTramos) then
		begin
			NParaEscribir:=trunc(CTamBuff *(1-overlapFFT));
//			desp:= (NData - NParaEscribir) div 4;
			desp:= 0;
		end
		else
		begin
			NParaEscribir:= leidos;
			desp:= 0;
		end;

		if NParaEscribir >trunc(CTamBuff *(1-overlapFFT)) then
			NParaEscribir := trunc(CTamBuff *(1-overlapFFT));
		for k:= 1 to NParaEscribir do
		begin
			pesoNuevo:= k/NParaEscribir;
			if pesoNuevo> 1 then pesoNuevo:= 1;
			datosi[k]:= satU8(trunc(pesoNuevo*datos^[k+desp]+
						(1-pesoNuevo)*datosBuff^[k]+128.5));
			datosBuff^[k]:= datos^[k+desp+NParaEscribir]
		end;
		salida.WriteSampleData(NParaEscribir, escritos, datosi );

	end;
	dt:= (dt-Now)*24*60*60;
	PaintBox1.Canvas.TextOut(0, 35, 'dt: '+FloatToStr(dt));

	FreeMem(bc, (NData div 2) * SIzeOf(real));
	FreeMem(ac, (NData div 2) * SizeOf(real));
	FreeMem(datos, NData*SizeOf(real));
	entrada.Close;
	salida.Close;

	acumError:= 0;




if autoplay.checked then
begin
	MediaPlayer1.Open;
	MediaPlayer1.Play;
end;

lblError.Caption:= FloatToStr( AcumError );
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   m: integer;
   ArchiEntrada: string;
   entrada: WaveFile;
   success: boolean;
   NSamples: integer;
   fMuestreo: integer;
   CTamBuff: integer;
   NData: integer;
   fs: integer;
   fbarra: double;
   salida: WaveFile;
   k: integer;


begin
	ArchiEntrada:= 'c:\basura\wavvox\inx2565.wav';
	entrada:= WaveFile.Init;
	entrada.OpenForRead( ArchiEntrada, success );
	NSamples:= entrada.numSamples;

   fMuestreo:= entrada.SamplingRate;
   CTamBuff:= (fMuestreo * msVentana) div 1000;
	NData:= CTamBuff;

	fs:= entrada.SamplingRate;
	fbarra:= fs/NData;
if autoplay.checked then
begin
	MediaPlayer1.Close;
	MediaPlayer1.FileName:='c:\basura\wavvox\fttb.wav';
end;

	salida:= WaveFile.init;
	salida.OpenForWrite('c:\basura\wavvox\fttb.wav', entrada.SamplingRate, 8,1, success);
   for k:= 1 to NSamples do
   begin
      entrada.ReadSample(m, success );

   end;

end;

end.
