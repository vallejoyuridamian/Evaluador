unit DllForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type

// representa una serie de numeros. Tiene asociado un nombre, un color
	TSerie= class
		nombre: string;
		kPrimero, kSiguiente: integer;
		Color: TColor;
		xup, yup: integer;
		y: array of double;
		circular: boolean;
		constructor Create(
			nombre: string;
			maxNPuntos: integer;
			MemoriaCircular: boolean;
			color: TColor );
		procedure Free;
		procedure nuevovalor( v: double );
	end;


// representa un conjunto de series en un rectángulo de un Canvas.
	TTrazoXY = class
			Nombre: string;
			x1, x2, y1, y2: double;
			sy: array of TSerie; // la cero es el eje x
			sx: TSerie;
			circular: boolean;
			c: TCanvas;
			px0, py0: integer;
			w, h: integer;
			cmx, cmy: double;
			xp: integer;

			constructor Create(
				nombre: string;
				maxNPuntos: integer;
				MemoriaCircular: boolean;
				nombre_sx, nombre_sy1: string;
				color_sy1: TColor;
				x1, x2, y1, y2: double );


			procedure PlotNuevo_x( x: double );
			procedure PlotNuevo_y( ks: integer; y: double );

			procedure RePlot;
			procedure SetCanvas( c: TCanvas; px0, py0, w, h: integer );
			function x2p( x: double ): integer;
			function y2p( y: double ): integer;
			procedure Free;
	 end;



// es la ventana donde desplegar cosas.
// tienen un objeto del tipo trazoxy.

  TfrmDllForm = class(TForm)
	 Panel1: TPanel;
	 pb: TPaintBox;
	 Splitter1: TSplitter;
	 Button1: TButton;
	 Button2: TButton;
	 Button3: TButton;
	 procedure FormClose(Sender: TObject; var Action: TCloseAction);
	 procedure Button1Click(Sender: TObject);
	 procedure Button2Click(Sender: TObject);
	 procedure FormCreate(Sender: TObject);
	 procedure pbPaint(Sender: TObject);
	 procedure Button3Click(Sender: TObject);
	 procedure FormResize(Sender: TObject);
  private
	 { Private declarations }
		ColorBorde, ColorGrilla, ColorLinea0: TColor;
		NDivX, NDivY: integer;
		borde_on, GridX_on, GridY_on: boolean;
		xlabel_str, ylabel_str, zlabel_str, titulo_str: string;
		ColorFondoExterior: TColor;
		ColorTextoExterior: TColor;
		ColorFondoInterior: TColor;
		etiquetar_x: boolean;
		x1, x2: double;
		etiquetar_y: boolean;
		y1, y2: double;
		etiquetar_z: boolean;
		z1, z2: double;
		margen_sup, margen_inf, margen_der, margen_izq: integer;
		AltoM, AnchoM: integer;
		Titulo_FontSize, Labels_FontSize, Etiquetas_FontSize: integer;

  public
	 { Public declarations }
		tr1: TTrazoXY;
		
		procedure xlabel( str: string );
		procedure ylabel( str: string );
		procedure zlabel( str: string );
		procedure titulo( str: string );
		procedure Etiquetas_x( x1, x2: double );
		procedure Etiquetas_y( y1, y2: double );
		procedure Etiquetas_z( z1, z2: double );

		procedure dbj_xlabel;
		procedure dbj_ylabel;
		procedure dbj_zlabel;
		procedure dbj_titulo;
		procedure dbj_etiquetasx;
		procedure dbj_etiquetasy;
		procedure dbj_etiquetasz;

		procedure dbj_gridX;
		procedure dbj_gridY;
		procedure dbj_borde;
//		procedure dbj_linea0;


// crea el diagrama le fija y agrega dos series, una
// que será la serie X y otra que es la serie 1 como la
// primer serie Y.
		procedure CrearDiagramaXY(
			nombre: string;
			MaxNPuntos: integer;
			Circular: boolean;
			nombre_sx, nombre_sy1: string;
			color_sy1: TColor;
			x1, x2, y1, y2: double );

// agrega una nueva serie y retorna el id.
		function CrearSerieXY(
			nombre: string;
			maxNPuntos: integer;
			MemoriaCircular: boolean;
			color: TColor ): integer;


  end;



var
  frmDllForm: TfrmDllForm;


procedure Alert( s: string );

implementation

{$R *.DFM}

procedure Alert( s: string );
begin
	showmessage( s );
end;

procedure TfrmDllForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;

// liberar los trazos creados
	tr1.Free;

end;


function CreateAngledFont(Font: HFont; Angle: Longint;
  Quality: byte = PROOF_QUALITY): HFont;
var
  FontInfo: TLogFontA;    // Font information structure
begin
	// Get the information of the font passed as parameter
  if GetObject(Font, SizeOf(FontInfo), @FontInfo) = 0 then begin
	 Result := 0;
	 exit;
	end;
  // Set the angle
  FontInfo.lfEscapement := Angle;
	FontInfo.lfOrientation := Angle;
  // Set the quality
  FontInfo.lfQuality := Quality;
	// Create a new font with the modified information
  // The new font must be released calling DeleteObject
  Result := CreateFontIndirect(FontInfo);
end;




procedure TextOutA(Canvas: TCanvas; X, Y, Angle: Integer;
  Text: string);
var
	OriginalFont, AngledFont: HFont;
begin
  // Create an angled font from the current font
	AngledFont := CreateAngledFont(Canvas.Font.Handle, Angle);
  if AngledFont <> 0 then begin
	 // Set it temporarily as the current font
		OriginalFont := SelectObject(Canvas.Handle, AngledFont);
	 if OriginalFont <> 0 then begin
		// Write the text
		Canvas.TextOut(X, Y, Text);
		// Restore the original font
		if SelectObject(Canvas.Handle, OriginalFont) = 0 then begin
		  Canvas.Font.Handle := AngledFont;
				// raise Exception.Create('Couldn''t restore font');
		  exit;
		end;
	 end;
		// Release the angled font
	 DeleteObject(AngledFont)
  end;
end;


constructor TSerie.Create(
			nombre: string;
			maxNPuntos: integer;
			MemoriaCircular: boolean;
			color: TColor );
begin
	inherited Create;
	Self.Nombre:= nombre;
	circular:= MemoriaCircular;
	if MemoriaCircular then
		setlength( y, maxNPuntos )
	else
		setlength( y, maxNPuntos );
	kPrimero:= 0;
	kSiguiente:= 0;
	Self.Color:= Color;

	xup:= 0;
	yup:= 0;
end;

procedure TSerie.Free;
begin
	setlength( y, 0 );
	inherited Free;
end;

procedure TSerie.NuevoValor( v: double );
begin
	y[kSiguiente]:= v;
	kSiguiente:= (kSiguiente+1) mod length(y);
	if kSiguiente= kPrimero then
		if circular then
			kPrimero:= (kPrimero +1) mod length(y )
		else
			raise Exception.Create('TSerie : '+Nombre+' Sobreescritura de la memoria' );
end;


constructor TTrazoXY.Create(
			nombre: string;
			maxNPuntos: integer;
			MemoriaCircular: boolean;
			nombre_sx, nombre_sy1: string;
			color_sy1: TColor;
			x1, x2, y1, y2: double );

var
	k: integer;

begin
	Self.Nombre:= nombre;
	Self.x1:= x1;
	Self.x2:= x2;
	Self.y1:= y1;
	 Self.y2:= y2;
	circular:= MemoriaCircular;
	c:= nil;

	setlength( sy, 11 ); // iniciamos lugar para 10 y el x
	for k:= 0 to high( sy ) do
		sy[k]:= nil; // serie libre
	sy[0]:= TSerie.Create( nombre_sx, MaxNPuntos, MemoriaCircular, clblack );
	sy[1]:= TSerie.Create( nombre_sy1, MaxNPuntos, MemoriaCircular, color_sy1 );
	sx:= sy[0];
end;


procedure TTrazoXY.Free;
var
	k: integer;
begin
	for k:= 0 to high( sy ) do
		if sy[k] <> nil then
			sy[k].Free;
	setlength( sy, 0 );
	inherited free;
end;


function TTrazoXY.x2p( x: double ): integer;
begin
	result:= trunc( (x-x1)* cmx +0.5 +px0);
end;

function TTrazoXY.y2p( y: double ): integer;
begin
	result:= trunc(h- (y -y1)* cmy +0.5 +py0);
end;

procedure TTrazoXY.PlotNuevo_x(x: double );
begin
	sy[0].nuevovalor( x );
	if assigned( c ) then
	begin
		xp:= x2p( x );
	end;
end;


procedure TTrazoXY.PlotNuevo_y(ks: integer; y: double );
var
	yp: integer;
	s: TSerie;
begin
	s:= sy[ks];
	s.NuevoValor( y );
	if assigned( c ) then
	begin
		yp:= y2p( y );
		if s.kSiguiente= s.kPrimero+1 then
			c.MoveTo(xp, yp)
		 else
		begin
			c.Pen.Color:= s.color;
			c.MoveTo(s.xup, s.yup);
			c.LineTo(xp, yp);
		end;
		s.xup:= xp;
		s.yup:= yp;
	end;
end;

procedure TTrazoXY.RePlot;
var
	k: integer;
	xp, yp: integer;
	kHasta: integer;
	s: TSerie;
	ks: integer;
begin
	if not assigned( c ) then exit;


	for ks:=1 to high( sy ) do
	begin
		s:= sy[ks];
		if s = nil then continue;

		if s.kPrimero= s.kSiguiente then continue;
		kHasta:= s.kSiguiente-1;
		if kHasta < 0 then kHasta:= high( s.y );

		xp:= x2p(sx.y[sx.kPrimero]);
		yp:= y2p(s.y[s.kPrimero]);
		c.MoveTo(xp, yp );
		if kHasta > s.kPrimero then
		begin
			c.Pen.Color:= s.color;
			for k:= s.kPrimero to s.kSiguiente-1 do
			begin
				xp:= x2p(sx.y[k]);
				yp:= y2p(s.y[k]);
				c.LineTo( xp, yp );
			end
		end
		else
		begin
			for k:= s.kPrimero to high(s.y) do
			begin
				xp:= x2p(sx.y[k]);
				yp:= y2p(s.y[k]);
				c.LineTo( xp, yp );
			end;
			for k:= 0 to kHasta do
			begin
				xp:= x2p(sx.y[k]);
				yp:= y2p(s.y[k]);
				c.LineTo( xp, yp );
			end;
		end;
	end;
end;

procedure TTrazoXY.SetCanvas( c: TCanvas; px0,py0, w, h: integer );
begin
	Self.px0:= px0;
	Self.py0:= py0;
	Self.c:= c;
	 Self.w:= w;
	 Self.h:= h;
	cmx:= w  / (x2-x1);
	cmy:= h / (y2-y1);
end;



procedure TfrmDllForm.dbj_borde;
begin
	borde_on:= true;
	pb.Canvas.Pen.Color:= ColorBorde;
	 pb.Canvas.MoveTo( margen_izq, margen_sup);
	 pb.Canvas.LineTo(pb.width-margen_der-1,margen_sup);
	 pb.Canvas.LineTo(pb.width-margen_der-1, pb.height-margen_inf-1 );
	 pb.Canvas.LineTo( margen_izq, pb.height-margen_inf-1 );
	 pb.Canvas.LineTo( margen_izq, margen_sup);
end;

procedure TfrmDllForm.dbj_GridX;
var
	k: integer;
	 dx: double;
	 xp: integer;
begin
	GridX_on:= true;
	dx:= (pb.width-margen_izq-margen_der) / NDivX;
	pb.Canvas.Pen.Color:= ColorGrilla;
	for k:= 1 to NDivX-1 do
	 begin
		xp:=trunc( dx *k+0.5 +margen_izq );
		 pb.Canvas.MoveTo( xp, margen_sup );
			pb.Canvas.LineTo( xp, pb.height-margen_inf );
	end;
end;


procedure TfrmDllForm.dbj_GridY;
var
	k: integer;
	 dy: double;
	 yp: integer;
begin
	GridY_on:= true;
	dy:= (pb.height-margen_sup-margen_inf) / NDivY;
	pb.Canvas.Pen.Color:= ColorGrilla;
	for k:= 1 to NDivY-1 do
	 begin
		yp:=trunc( dy *k+0.5 + margen_sup );
		 pb.Canvas.MoveTo( margen_izq, yp );
			pb.Canvas.LineTo(  pb.width-margen_der, yp );
	end;
end;

procedure TfrmDllForm.Button1Click(Sender: TObject);
begin
	pb.Canvas.MoveTo(0,0);
	pb.Canvas.LineTo( pb.width-1, pb.height-1 );
end;

procedure TfrmDllForm.Button2Click(Sender: TObject);
var
	k: integer;
begin
	 dbj_GridX;
	 dbj_GridY;
//	 tr1.SetCanvas( pb.Canvas, pb.Width, pb.Height );
	 for k:= 0 to 100 do
	 begin
		tr1.PlotNuevo_x( k );
		tr1.PlotNuevo_y( 1, 8*sin( 2*pi *k /100 ) );
	 end;
	 dbj_borde;
end;

procedure TfrmDllForm.FormCreate(Sender: TObject);
begin
		Labels_FontSize:= 10;
		Etiquetas_FontSize:= 8;
		Titulo_FontSize:=14;
		ColorBorde:= clDkGray;
		ColorGrilla:= clLtGray;
		ColorLinea0:= clNavy;
		NDivX:= 10;
		NDivY:= 8;
		borde_on:= false;
		GridX_on:= false;
		GridY_on:= false;
		xlabel_str:= '';
		ylabel_str:= '';
		zlabel_str:= '';
		titulo_str:= '';
		ColorFondoExterior:= clWhite;
		ColorTextoExterior:= clNavy;
		ColorFondoInterior:= clWhite;
		Color:= ColorFondoInterior;
		margen_sup:= pb.Canvas.TextHeight( 'M' )*2;
		margen_izq:= pb.Canvas.TextWidth('M')*6;
		margen_der:= margen_izq;
		margen_inf:= margen_der;

		tr1:= nil;


end;

procedure TfrmDLLForm.CrearDiagramaXY(
	nombre: string;
	MaxNPuntos: integer;
	Circular: boolean;
	nombre_sx, nombre_sy1: string;
	color_sy1: TColor;

	x1, x2, y1, y2: double );
begin
	if tr1 <> nil then tr1.Free;
	tr1:= TTrazoXY.Create(
		Nombre, MaxNPuntos, Circular,
      nombre_sx, nombre_sy1, color_sy1,
		x1, x2, y1, y2 );
	tr1.SetCanvas(
		pb.canvas,
		margen_der, margen_sup,
		pb.width-margen_izq-margen_der, pb.height-margen_inf-margen_sup );

end;



function TfrmDLLForm.CrearSerieXY(
			nombre: string;
			maxNPuntos: integer;
			MemoriaCircular: boolean;
			color: TColor ): integer;

var
	buscando: boolean;
	k, n: integer;
begin
	n:= length( tr1.sy );
	buscando:= true;
	k:= 2;
	while buscando and ( k < n ) do
		if tr1.sy[k]= nil then
			buscando:= false
		else
			inc(k);
	if buscando then
		result:= -1
	else
	begin
		tr1.sy[k]:= TSerie.Create(nombre, maxNPuntos,	MemoriaCircular, color );
		result:= k;
	end;
end;



procedure TfrmDllForm.pbPaint(Sender: TObject);
begin
	 if (xlabel_str <> '') or etiquetar_x  then
	 begin
		dbj_xlabel;
		dbj_EtiquetasX;
	 end;
	 if (ylabel_str <> '') or etiquetar_y then
	 begin
		dbj_ylabel;
		dbj_EtiquetasY;
	 end;
	 if (zlabel_str <> '') or etiquetar_z then
	 begin
		dbj_zlabel;
		dbj_EtiquetasZ;
	 end;
	 if Titulo_str <> '' then
		dbj_TItulo;

	 if GridX_on then dbj_GridX;
	 if GridY_on then dbj_GridY;
	tr1.RePlot;
	 if borde_on then	dbj_borde;
end;


procedure TfrmDllForm.xlabel( str: string );
begin
	xlabel_str:= str;
	dbj_xlabel;
end;

procedure TfrmDllForm.ylabel( str: string );
begin
	ylabel_str:= str;
	dbj_ylabel;
end;

procedure TfrmDllForm.zlabel( str: string );
begin
	zlabel_str:= str;
	dbj_zlabel;
end;

procedure TfrmDllForm.titulo( str: string );
begin
	titulo_str:= str;
	dbj_titulo;
end;


procedure TfrmDllForm.Button3Click(Sender: TObject);
begin
	 titulo('Este es el título jyquin');
	 xlabel(' ... xlabel ...cc');
	ylabel(' ... ylabel ...cc');
	 zlabel(' ... zlabel ...cc');

	 self.Etiquetas_x( -100, 200 );
   self.Etiquetas_y( -100, 200 );
   self.Etiquetas_z( -100, 200 );

end;

procedure TfrmDllForm.FormResize(Sender: TObject);
begin
Self.tr1.SetCanvas(
	pb.canvas,
	margen_der, margen_sup,
	pb.width-margen_izq-margen_der, pb.height-margen_inf-margen_sup );
end;



procedure TfrmDllForm.dbj_Titulo;
var
	xp, yp: integer;
begin
	pb.Canvas.Brush.Color:= ColorFondoExterior;
	pb.Canvas.FillRect( rect(0,0, pb.Width-1, margen_sup-1) );
	if Titulo_str <> '' then
	begin
		pb.Canvas.Font.Size:= Titulo_FontSize;
		xp:= (pb.Width - pb.Canvas.TextWidth( titulo_str )) div 2;
		yp:= (margen_sup - pb.Canvas.TextHeight( titulo_str ) );
		pb.Canvas.TextOut( xp, yp, Titulo_str );
	end;
end;

procedure TfrmDllForm.dbj_EtiquetasY;
var
	s: string;
	k: integer;
	y: double;
	dy: double;
	xp, yp: integer;
	dyp: double;

begin
	if etiquetar_y then
	begin
		pb.Canvas.Font.Size:= Etiquetas_FontSize;
		dy:= (y2-y1)/ NDivY;
		xp:=  pb.Canvas.TextHeight( ylabel_str );
		dyp:= (pb.height-margen_sup-margen_inf);
		for k:= 0 to NDivY do
		begin
		y:= y1+ k* dy;
			yp:=trunc(margen_sup+dyp*(1-k/NDivY)+0.5);
			s:= Format('%8.1f', [y]);
			pb.Canvas.TextOut( xp, yp, s );
		end;
	end;
end;



procedure TfrmDllForm.dbj_ylabel;
var
	s: string;
	k: integer;
	y: double;
	dy: double;
	xp, yp: integer;
	dyp: double;

begin
	pb.Canvas.Brush.Color:= ColorFondoExterior;
	pb.Canvas.FillRect( rect(0,0, margen_izq-1, pb.height-1) );
	if ylabel_str <> '' then
	begin
			pb.Canvas.Font.Size:= Labels_FontSize;
			xp:= 0;
			yp:= (pb.Height + pb.Canvas.TextWidth( ylabel_str ) ) div 2;
			TextOutA(pb.Canvas, xp, yp, 900, ylabel_str );
	 end;
end;


procedure TfrmDllForm.dbj_EtiquetasX;
var
	s: string;
	 k: integer;
	 y: double;
	 dy: double;
	 xp, yp: integer;
	 dyp: double;


begin
	if etiquetar_x then
	begin
		pb.Canvas.Font.Size:= Etiquetas_FontSize;
		dy:= (x2-x1)/ NDivX;
		xp:= pb.Height - margen_inf;
		dyp:= (pb.width-margen_der-margen_izq);
		for k:= 0 to NDivX do
		begin
			y:= x1+ k* dy;
			yp:=trunc(margen_izq +dyp*k/NDivX+0.5);
			s:= Format('%8.1f', [y]);
			TextOutA(pb.Canvas, yp, xp, -900, s );
		end;
	end;
end;

procedure TfrmDllForm.dbj_xlabel;
var
	s: string;
	y: double;
	dy: double;
	xp, yp: integer;
	dyp: double;
begin
	pb.Canvas.Brush.Color:= ColorFondoExterior;
	pb.Canvas.FillRect(
		rect(0 , pb.Height- margen_inf, pb.width, pb.height-1) );
	if xlabel_str <> '' then
	begin
		pb.Canvas.Font.Size:= Labels_FontSize;
			xp:= (pb.Width - pb.Canvas.TextWidth( xlabel_str )) div 2;
			yp:= (pb.Height - pb.Canvas.TextHeight( xlabel_str ) );
			pb.Canvas.TextOut( xp, yp, xlabel_str );
	end;
end;



procedure TfrmDllForm.dbj_EtiquetasZ;
var
	s: string;
	k: integer;
	y: double;
	dy: double;
	xp, yp: integer;
	dyp: double;
begin
	if etiquetar_z then
	begin
		pb.Canvas.Font.Size:= Etiquetas_FontSize;
		dy:= (y2-y1)/ NDivY;
	 xp:= pb.Width - margen_der;
	 dyp:= (pb.height-margen_inf-margen_sup);
	 for k:= 0 to NDivY do
	 begin
		y:= y1+ k* dy;
			yp:=trunc(margen_sup+dyp*(1-k/NDivY)+0.5);
			s:= Format('%8.1f', [y]);
			pb.Canvas.TextOut( xp, yp, s );
		end;
	end;
end;


procedure TfrmDllForm.dbj_zlabel;
var
	s: string;
	 k: integer;
	 y: double;
	 dy: double;
	 xp, yp: integer;
	 dyp: double;


begin
	pb.Canvas.Brush.Color:= ColorFondoExterior;
	pb.Canvas.FillRect(
		rect( pb.Width-margen_der,0, pb.width-1, pb.height-1) );
	if zlabel_str <> '' then
	begin
			pb.Canvas.Font.Size:= Labels_FontSize;
			xp:= (pb.Width );
			yp:= (pb.Height - pb.Canvas.TextWidth( zlabel_str ) ) div 2;
			TextOutA(pb.Canvas, xp, yp, -900, zlabel_str );
	 end;
end;




procedure TfrmDllForm.Etiquetas_x( x1, x2: double );
begin
	Self.x1:=x1 ;
	 Self.x2:=x2 ;
	 Self.etiquetar_x:= true;
	 dbj_xlabel;
	 dbj_EtiquetasX;
end;

procedure TfrmDllForm.Etiquetas_y( y1, y2: double );
begin
	Self.y1:=y1 ;
	 Self.y2:=y2 ;
	 Self.etiquetar_y:= true;
	 dbj_ylabel;
	 dbj_EtiquetasY;
end;

procedure TfrmDllForm.Etiquetas_z( z1, z2: double );
begin
	Self.z1:=z1 ;
	 Self.z2:=z2 ;
	 Self.etiquetar_z:= true;
	 dbj_zlabel;
	 dbj_EtiquetasZ;
end;





begin
  frmDllForm:=nil;

end.
