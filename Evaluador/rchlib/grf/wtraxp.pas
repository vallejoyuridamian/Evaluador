{ 21.3.2002 intento de hacer la traxp para Windows
26.7.2003 Bien! creo que lo logré
}
unit wtraxp;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
	Dialogs,	extctrls,
	xMatDefs,
//   wRCHFONTS,
	Autoesca;


var
	quita:integer = 12;
	Estado:boolean = false;
	gridx:integer = 10;
	gridy:integer = 8;
	ERF:NReal=0;
const
	NCanalesMax= 54;

var
   AreaTexto_Lx: integer;
   ColorPapelTexto, ColorTintaTexto: TColor;

{$IFNDEF RCHFONTS}
Type
	TAlineacionTexto= ( LeftText, RightText, TopText, BottomText, CenterText );

const
   VertDir= 90*10;
   HorizDir= 0;

type
   TextSettingsType= record
      Font: TFont;
      CharSize: integer;
      Direction: integer;
      Horiz, Vert:TAlineacionTexto;
   end;

const
   Just_Derecha= RightText;
   Just_Izquierda= LeftText;
   Just_Arriba= TopText;
   Just_Abajo= BottomText;
   Just_Centro= CenterText;

var
   Fonts: array[0..3] of TFont;
{$ENDIF}


const
	 { Colores: }
	 Negro        = clBlack;
	 Azul         = clNavy;
	 Verde        = clGreen;
	 Celeste      = clAqua;
	 Rojo         = clRed;
	 Violeta      = clFuchsia;
	 Marron       = clMaroon;
	 GrisClaro    = clGray;
	 GrisOscuro   = clDkGray;
	 AzulClaro    = clBlue;
	 VerdeClaro   = clLime;
	 CeleteClaro  = clAqua;
	 RojoClaro    = clRed;
	 VioletaClaro = clFuchsia;
	 Amarillo     = clYellow;
	 Blanco       = clWhite;


const
   TablaColores: array [0..15] of TColor = (
      Negro,  Azul,  Verde,
      Celeste,  Rojo,  Violeta,
      Marron,   GrisClaro,  GrisOscuro,
      AzulClaro,   VerdeClaro,  CeleteClaro,
      RojoClaro,  VioletaClaro, Amarillo,  Blanco);

const
	ce_Solido = 0;
	ce_Punteado = 1;



type
   ViewPortType= TRect;


const
	 NormWidth= 1;


var
// a fijar sobre el TPaintBox
	trx, trz: TCanvas;
	GetMaxX, GetMaxY: integer;


	t,tinicial,tfinal:NReal;

{ Los siguientes identificadores para las mismas variables son para usar
en lugar de traxp.t o traxp.tInicial pues el prefijo variar  seg£n estemos
en WINDOWS o no }
	traxp_t:NReal absolute t;
	traxp_tInicial: NReal absolute tinicial;
	traxp_tfinal: NReal absolute tfinal;
	traxp_GridX: integer absolute GridX;
	traxp_GridY: integer absolute GridY;

	alineacionTextoHorizontal, alineacionTextoVertical: TAlineacionTexto;
   glob_AnguloTexto10: integer;

procedure SetColor( ncl: TColor );

procedure DefinaY(c:integer;y0,dy:NReal);
procedure DefinaX(c:integer;X0,dX:NReal);
procedure SubPlot(kx,ky:integer);
procedure Superponga(c1,c2:integer);
procedure ActiveCanal(k:integer);
procedure DefinaCanal(dh,ph,dv,pv:integer;x0,dx,y0,dy:NReal;tinta:TColor);
procedure Borde;
procedure Linea0;
procedure Titulo(x:string);
procedure XLabel(x:string);
procedure YLabel(x:string);
procedure DefinaColor(xcanal: integer; xcolor:TColor);
procedure DefinaColorAux(xcolor:TColor);
procedure DefinaColorDefTrazos(xcolor: TColor);
procedure DefinaColorDefFondo(xcolor: TColor);
procedure DefinaColorPapelTitulos(xcolor: TColor);

{$IFNDEF RCHFONTS}
function TextHeight( x: string ): integer;
function TextWidth( x: string ): integer;
procedure GetTextSettings(var t: TextSettingsType );
procedure SetTextJustify( horizontal, vertical: TAlineacionTexto );
procedure SetTextStyle( font: TFont; Dir, Size: integer);
procedure OutTextXY( x, y : Integer; texto: string);
procedure SetTextAngle(F:Tfont; angle: Word);
{$ENDIF}

procedure InicieGr( xcanvas, zcanvas: TCanvas; Ancho, Alto: integer; AreaTexto__lx: integer );
procedure GridHorizontal;
procedure grid;
procedure Desligue(n:integer);

procedure trazo(n:integer;y:NReal);
procedure trazoXY(n:integer;x,y:NReal);
procedure trazoXYColorEstilo(
			kanal:integer;
			x,y: NREal;
			xcolor: TColor;
			xestilo:integer);
procedure Barra(n:integer; y:NReal);
procedure BarraXY(n:integer; x,y:NReal);

procedure BorreTitulo;
procedure BorreCanal(kanal: integer; ColorFondo: TColor);
procedure GetXPYP(kanal:integer;var x1,y1,x2,y2:integer);
procedure LabelXY(Kanal:integer;x,y:NReal;texto:string);
procedure HoldOn(kanal:integer);
procedure HoldOff(kanal:integer);
function ChanelHoldStatus(Kanal:integer):boolean;
procedure PlotRealVect(kanal, NP:integer; var y);
procedure PlotRealBar(kanal, NP,P:integer;color:TColor; valor1,valor0:NReal);
procedure PlotRealVectBar(kanal, NP:integer; var y;colorPar,colorImpar:TColor;ArmonicoInicial:integer);


{ sevicios de posicion de cursores }
type
	TipoDeAreaDeCuadro =(
		AreaDelTitulo, AreaDeXLabel, AreaDeYLabel, AreaDeTrazos );

function SiguienteAreaTocadaPorPunto(
	var kanal: integer;
	var AreaId: TipoDeAreaDeCuadro;
	x, y: integer
	): boolean;

{
	+Entradas:
		(kanal) es el canal para iniciar la busqueda.
			si es <= 0 se considera 0. El primer canal testeado ser  kanal+1.
		 (xp, yp) es el punto en pixeles absolutos.
	+Salidas:
		(kanal) retorna el primer kanal tocado a partir de la busqueda.

	+ValorFuncion:
		El valor devuelto por la funcion ser  TRUE si el resultado en kanal
		es realmente v lido. Si es false, es que el punto no toca ningun
		canal desde donde se inicio la busqueda.
	+Aplicacion: para obtener todos los canales que sean tocados se deber 
	primero llamar la funcion con kanal=0 y luego llamar sucesivamente la
	funcion pasando cada vez en kanal, el valor devuelto en esta variable
	en la llamada anterior.

	}


procedure CoordenadasEnElCanal(
	kanal: integer; { canal }
	xpxa, ypxa: integer; {punto en pixeles absolutos}
	var x, y: NReal); {coordenadas en el canal}


procedure CoordenadasAbsolutas(
	var xpxa, ypxa: integer;
	kanal: integer;
	x, y: NReal);

function PuntoDentroRectangulo(
	x,y: integer; {el punto}
	x1, y1, x2, y2: integer { vetices opuestos del rectangulo }
	): boolean;


procedure Line(x1,y1,x2,y2: integer);
procedure SetLineStyle( Estilo: TPenStyle;
                        NoSe, Grosor: integer );
procedure SetFillStyle(Estilo: TBrushStyle; Color: TColor);

procedure Arc( x, y: integer; alfa, beta: double; radio : integer );
procedure Bar( x1, y1, x2, y2: integer );
procedure PutPixel( x, y: integer; color: TColor );

procedure GetViewSettings(var OldVP: ViewPortType);
procedure SetViewPort(xp1,yp1,xp2,yp2: integer; clip: boolean);
procedure ClearViewPort;
function GetColor: TColor;

function puntox:integer;
function puntoy:integer;

implementation

type

cuadro = record
	xp1,yp1,xp2,yp2:integer; { pixeles del canal xy }
	xfp1,yfp1, xfp2,yfp2:integer; {pixeles absolutos del frame}
	x1,y1,x2,y2:NReal; { dimensiones reales }
	xp,yp:integer; { posición del trazo }
	color,fondo:TColor;
	inicializado:boolean;
	HoldStatus:boolean;
end;

var
	canal:array[0..NCanalesMax]of cuadro;
	activo:integer;
	colorAuxiliar, ColorDefFondo, ColorDefTrazo: TColor;
   colorPapelTitulos: TColor;
   viewPort: ViewPortType;
   viewPort_clip: boolean;




function ClipPoint(var x,y:integer; var R: ViewPortType):boolean;
begin
	CLipPoint:=(R.Left<x)and(x<R.Right)and(R.Top<y)and(y<R.Bottom)
end;

{ Liang-Barsky parametric line-clipping algorithm }

procedure Liang_Barsky(var x0,y0,x1,y1:integer; var x; var visible:boolean);

var
	tE,tL:NReal;
	dx,dy: integer;
   R: ViewPortType absolute x;

	function CLIPt(denom,num:NReal; var tE,tL :NReal):boolean;
	var
		t:NReal;
		accept:boolean;
	begin
		accept:=true;
		if denom > 0 then
		begin
			t := num/denom;
			if t > tL then
				accept:=false
			else if t > tE then
				tE := t
		end
		else
			if denom < 0 then
			begin
				t:= num/denom;
				if t< tE then
					accept:=false
				else if t< tL then
					tL:=t
			end
		else
			if num > 0 then
				accept:=false;
		CLIPt:=accept
	end; {CLIPt}

begin
	dx:= x1 - x0; dy := y1-y0;
	visible:=false;
	if (dx = 0) and (dy = 0) and ClipPoint(x0,y0,R) then
		visible := true
	else
		begin
			tE:=0;
			tL:=1;
			if CLIPt(dx,R.Left-x0,tE,tL) then
				if CLIPt(-dx,x0-R.Right,tE,tL) then
					if CLIPt(dy, R.Top-y0,tE,tL) then
						if CLIPt(-dy,y0-R.Bottom,tE,tL) then
							begin
								visible:= true;
								if tL < 1 then
									begin
										x1:=trunc(x0+tL*dx+0.5);
										y1:=trunc(y0+tL*dy+0.5)
									end;
								if tE>0 then
									begin
										x0:=trunc(x0+tE*dx+0.5);
										y0:=trunc(y0+tE*dy+0.5)
									end
							end

		end
end; { CLip2D }



{$IFNDEF RCHFONTS }

procedure OutTextXY( x, y : Integer; texto: string);
begin
   if glob_AnguloTexto10 = 0 then
   begin
      case AlineacionTextoHorizontal of
	      LeftText: x:= x;
         RightText: x:= x - TextWidth( texto );
         CenterText: x:= x - TextWidth( texto ) div 2;
      end;
      case AlineacionTextoVertical of
         TopText: y:= y;
         BottomText: y:= y - TextHeight( 'M' );
         CenterText: y:= y - TextHeight( 'M' ) div 2;
      end;
   end
   else
   begin
      case AlineacionTextoHorizontal of
	      LeftText: y:= y;
         RightText: y:= y - TextWidth( texto );
         CenterText: y:= y - TextWidth( texto ) div 2;
      end;
      case AlineacionTextoVertical of
         TopText: x:= x;
         BottomText: x:= x - TextHeight( 'M' );
         CenterText: x:= x - TextHeight( 'M' ) div 2;
      end;
   end;

	trx.Brush.Color:= colorPapelTexto;
   trx.Font.Color:= colorTintaTexto;
   SetTextAngle(trx.Font,  glob_AnguloTexto10 );
   trx.TextOut(x, y, texto );
   if trz <> nil then
   begin
   	trz.Brush.Color:= colorPapelTexto;
      trz.Font.Color:= colorTintaTexto;
      SetTextAngle(trz.Font,  glob_AnguloTexto10 );
      trz.TextOut(x,y, texto);
   end;
end;

function TextHeight( x: string ): integer;
begin
   result:= trx.TextHeight( x );
end;

function TextWidth( x: string ): integer;
begin
   result:= trx.TextWidth( x );
end;


procedure GetTextSettings(var t: TextSettingsType );
begin
   t.Font:= trx.Font;
   t.CharSize:= t.Font.Size;
   t.Direction:= glob_AnguloTexto10;
   t.Horiz:= alineacionTextoHorizontal;
   t.Vert:= alineacionTextoVertical;

end;


procedure SetTextStyle( font: TFont; Dir, Size: integer);
begin
   glob_AnguloTexto10:= Dir;
   Font.Size:= Size;
   trx.Font:= font;
   if trz <> nil then
      trz.Font:= font;
end;



{$ENDIF}





function puntox:integer;
begin
puntox:=trx.PenPos.x;
end;

function puntoy:integer;
begin
puntoy:=trx.PenPos.y;
end;


procedure Arc( x, y: integer; alfa, beta: double; radio : integer );
var
   x1, x2, x3, x4, y1, y2, y3, y4: integer;
begin
   x1:= x - radio; y1:= y - radio;
   x2:= x + radio; y2:= y + radio;
   x3:= trunc(1000* cos( alfa /180.0*pi));
   y3:= trunc(1000* sin( alfa/ 180.0*pi));
   x4:= trunc(1000* cos( beta/180.0*pi));
   y4:= trunc(1000* sin(alfa /180.0*pi));
   trx.Arc(x1, y1, x2, y2, x3, y3, x4, y4 );
   if trz <> nil then
      trz.Arc(x1, y1, x2, y2, x3, y3, x4, y4 );
end;

procedure Bar( x1, y1, x2, y2: integer );
begin
   trx.Rectangle(x1, y1, x2, y2 );
   if trz <> nil then
      trz.Rectangle(x1, y1, x2, y2 );
end;


procedure PutPixel( x, y: integer; color: TColor );
begin
   trx.Pixels[x,y]:= color;
   if trz <> nil then
      trz.Pixels[x,y]:= color;
end;

procedure SetTextJustify( horizontal, vertical: TAlineacionTexto );
begin
	AlineacionTextoHorizontal:= horizontal;
	AlineacionTextoVertical:= vertical;
end;

procedure Bar3d(x1,y1,x2,y2: integer; alto: integer; x: boolean);
begin
	 trx.FillRect( rect(x1, y1, x2-alto, y2 ));
	 trx.FillRect( rect(x1+alto, y1+alto, x2, y2 ));
    if trz <> nil then
   begin
	 trz.FillRect( rect(x1, y1, x2-alto, y2 ));
	 trz.FillRect( rect(x1+alto, y1+alto, x2, y2 ));
   end;
end;


procedure GetViewSettings(var OldVP: ViewPortType);
begin
	 OldVp:= viewPort;
end;

procedure SetViewPort(xp1,yp1,xp2,yp2: integer; clip: boolean);
begin
   viewPort.Left:= xp1;
   viewPort.Top:= yp1;
   viewPort.Right:= xp2;
   viewPort.Bottom:= yp2;
   viewPort_clip:= clip;
end;

procedure ClearViewPort;
begin
   SetViewPort(0,0, GetMaxX, GetMaxY, true );
END;

procedure SetColor( ncl: TColor );
begin
   if ncl <=15 then
      ncl:= TablaColores[ncl];

   trx.Pen.Color:= ncl;
   if trz <> nil then
      trz.Pen.Color:= ncl;
   ColorTintaTexto:= ncl;
{
   trx.Font.Color:=ncl;
   if trz <> nil then
      trz.Font.Color:= ncl;
}
end;

function GetColor: TColor;
begin
   result:= trx.Pen.Color;
end;

procedure Line(x1,y1,x2,y2: integer);
begin
   trx.MoveTo(x1, y1);
   trx.LineTo(x2, y2 );
   if trz <> nil then
   begin
      trz.MoveTo(x1, y1);
      trz.LineTo(x2, y2 );
   end;
end;


procedure SetLineStyle( Estilo: TPenStyle;
                        NoSe, Grosor: integer );
begin
   trx.Pen.Style:= Estilo;
   trx.Pen.Width:= Grosor;
   if trz <> nil then
   begin
      trz.Pen.Style:= Estilo;
      trz.Pen.Width:= Grosor;
   end;
end;


procedure SetFillStyle(Estilo: TBrushStyle; Color: TColor);
begin
   if Color <= 15 then
      Color:= TablaColores[ color ];

	 trx.Brush.Style:= Estilo;
	 trx.Brush.Color:= Color;
   if trz <> nil then
   begin
	 trz.Brush.Style:= Estilo;
	 trz.Brush.Color:= Color;
   end;
end;




procedure CoordenadasEnElCanal(
	kanal: integer; { canal }
	xpxa, ypxa: integer; {punto en pixeles absolutos}
	var x, y: NReal); {coordenadas en el canal}

begin
	try
	with canal[kanal] do
	begin
		y:= y2-(ypxa-yp1)/(yp2-yp1)*(y2-y1);
		x:= x1+(xpxa-xp1)/(xp2-xp1)*(x2-x1);
	end;
	except
		xpxa:= 0;
		ypxa:= 0;
	end;
end;

function PuntoDentroRectangulo(
	x,y: integer; {el punto}
	x1, y1, x2, y2: integer { vetices opuestos del rectangulo }
	): boolean;
begin
	PuntoDentroRectangulo:= (x1<=x)and(x<=x2)and
		(y1<=y)and(y<=y2);
end;


procedure CoordenadasAbsolutas(
		var xpxa, ypxa: integer;
		kanal: integer;
		x, y: NReal);
begin
	try
	with canal[kanal] do
	begin
		ypxa:=trunc(yp1-(y- y2)*(yp2-yp1)/(y2-y1));
		xpxa:=trunc(xp1+(x-x1)*(xp2-xp1)/(x2-x1));
	end;
	except
		xpxa:=0;
		ypxa:= 0;
	end;
end;



function SiguienteAreaTocadaPorPunto(
	var kanal: integer;
	var AreaId: TipoDeAreaDeCuadro;
	x, y: integer
	): boolean;
var
	buscando: boolean;
begin
	if kanal<-1 then kanal:=-1;
	inc(kanal);
	buscando:= true;
	with canal[kanal] do
	while buscando do
	begin
		if PuntoDentroRectangulo(x, y, xfp1, yfp1, xfp2, yfp2) then
		begin
			buscando:= false;
			SiguienteAreaTocadaPorPunto:= true;
			if PuntoDentroRectangulo(x, y, xp1, yp1, xp2, yp2) then
				AreaId:=AreaDeTrazos
			else if x<xp1 then
				AreaId:= AreaDeYlabel
			else	if y<yp1 then
				AreaId:= AreaDelTitulo
			else {if y>yp2 then}
				AreaId:= AreaDeXlabel;
		end
		else
		begin
			inc(kanal);
			if kanal > NCanalesMax then
			begin
				buscando:= false;
				SiguienteAreaTocadaPorPunto:= false;
			end;
		end;
	end;
end;






procedure DefinaColorAux(xcolor:TColor);
begin
	ColorAuxiliar:=xcolor;
end;

procedure DefinaColorDefTrazos(xcolor:TColor);
begin
	ColorDefTrazo:=xcolor;
end;

procedure DefinaColorDefFondo(xcolor: TColor);
begin
	ColorDefFondo:= xcolor;
end;

procedure DefinaColorPapelTitulos(xcolor: TColor);
begin
	ColorPapelTitulos:= xcolor;
end;


procedure GetXPYP(kanal:integer;var x1,y1,x2,y2:integer);
begin
	x1:=canal[kanal].xp1;
	x2:=canal[kanal].xp2;
	y1:=canal[kanal].yp1;
	y2:=canal[kanal].yp2;
end;



procedure LabelXY(Kanal:integer;x,y:NReal;texto:string);
var
	tempX,tempY:NReal;
	dx, dy: integer;

begin
{
	if AlineacionTextoHorizontal= RightText then
		dx:= TextWidth( texto )
	else
		if AlineacionTextoHorizontal= CenterText then
			dx:= TextWidth( texto ) div 2
		else
			dx:= 0;

	if AlineacionTextoVertical= BottomText then
		dy:= trx.TextHeight( texto )
	else
		if AlineacionTextoVertical= CenterText then
			dy:= trx.TextHeight( texto ) div 2
		else
			dy:= 0;
 }

	trx.Font.Color:=ColorAuxiliar;
   if trz <> nil then
   	trz.Font.Color:=ColorAuxiliar;
	with canal[activo] do
	begin
		tempY:=(yp2-yp1)*(y2-y)/(y2-y1)+yp1;
		tempX:=(xp2-xp1)*(x-x1)/(x2-x1)+xp1;
		OutTextXY( trunc(tempX)-dx,Trunc(TempY)-dy,texto);
	end;
end;



procedure PlotRealVect(kanal, NP:integer; var y);
type
	VR = array[1..6000] of NReal;
var
	ma,mi,m:NReal;
	k:integer;
	st:string;
begin

	if ChanelHoldStatus(kanal) = FALSE then
	begin
		ma:=VR(y)[1];
		mi:=ma;
		for k:= 2 to NP do
		begin
			m:= VR(y)[k];
			if m<mi then mi:=m;
			if m>ma then ma:=m;
		end;
		if ma = mi then exit;
		gridy:=8;
		Escala125N(mi,ma,m,gridy,1);
		DefinaX(kanal,1,(NP-1)/gridx);
		DefinaY(kanal,mi,m);
		grid;
		str(m:8:-4,st);
		st:=st+'/DIV';
		ylabel(st);
	end;


	desligue(kanal);
	for k:= 1 to  NP do
		trazoXY(kanal,k,VR(y)[k]);
end;


procedure PlotRealVectBar(
   kanal, NP:integer; var y;
   colorPar,colorImpar: TColor;
   ArmonicoInicial:integer);
{negro para a0 si esta}
type
	VR = array[1..6000] of NReal;
var
	ma,mi,m:NReal;
	k,k1:integer;
	st:string;
begin

	if ChanelHoldStatus(kanal) = FALSE then
	begin
		ma:=VR(y)[1];
		mi:=ma;
		for k:= 2 to NP do
		begin
			m:= VR(y)[k];
			if m<mi then mi:=m;
			if m>ma then ma:=m;
		end;
		if ma = mi then exit;
		gridy:=8;
		Escala125N(mi,ma,m,gridy,1);
		DefinaX(kanal,1,(NP-1)/gridx);
		DefinaY(kanal,mi,m);
		grid;
		str(m:8:-4,st);
		st:=st+'/DIV';
		ylabel(st);
	end;


	desligue(kanal);
	for k:= 1 to  NP do
	begin
		if odd(ArmonicoInicial+k-1) then definacolor(Kanal,colorImpar)
		else if (ArmonicoInicial+k-1)<>0 then definacolor(kanal,colorPar) else definacolor(kanal,negro);

		trazoXY(kanal,k,0);
		trazoXY(kanal,k-0.251+0.5,0);

		for k1:=0 to Trunc(400/Np) do
		begin
			trazoXY(kanal,0.5/(400/NP)*k1+k-0.25+0.5,VR(y)[k]);
			trazoXY(kanal,0.5/(400/NP)*k1+k-0.25+0.5,0);
		end;

		trazoXY(kanal,k+0.251+0.5,0);
		trazoXY(kanal,k+1,0);
	end;
end;

procedure PlotRealBar(kanal, NP,P:integer;
   color:TColor; valor1,valor0:NReal);
{imprime una barra de valor1 a valor 0 en el canal KANAL
 para un elemento P en un conjunto de elementos NP con
 el color color.

 OBS:
 Como ejemplo, se usa para dibujar barras de armonicos en Plotmems}
var
	k1:integer;
begin

	desligue(kanal);
	definacolor(Kanal,color);

	trazoXY(kanal,P,valor0);
	trazoXY(kanal,P-0.251+0.5,valor0);

	for k1:=0 to Trunc(400/Np) do{relleno}
	begin
			trazoXY(kanal,0.5/(400/NP)*k1+P-0.25+0.5,valor1);
			trazoXY(kanal,0.5/(400/NP)*k1+P-0.25+0.5,valor0);
	end;

	trazoXY(kanal,P+0.251+0.5,valor0);
	trazoXY(kanal,P+1,valor0);

end;



procedure HoldOn(kanal:integer);
begin
	canal[kanal].HoldStatus:=true
end;


procedure HoldOff(kanal:integer);
begin
	canal[kanal].HoldStatus:=false
end;

function ChanelHoldStatus(Kanal:integer):boolean;
begin
	ChanelHoldStatus:=canal[kanal].HoldStatus
end;


procedure InicieCanales;
var k:word;
begin
for k:=0 to NCanalesMax do
	begin
		canal[k].inicializado:=false;
		canal[k].HoldStatus:=false
	end;
end;

procedure BorreCanal;
begin
	activeCanal(kanal);
	with canal[kanal] do
	begin
		trx.Brush.Color:= ColorFondo;
		trx.FillRect(Rect(xp1,yp1,xp2,yp2));
      if trz <> nil then
      begin
   		trz.Brush.Color:= ColorFondo;
	   	trz.FillRect(Rect(xp1,yp1,xp2,yp2));
      end;
	end;
end;


procedure DefinaCanal(dh,ph,dv,pv:integer;x0,dx,y0,dy:NReal;tinta: TColor);
begin
	with canal[activo] do
	begin
		xfp1:=trunc((GetMaxX-AreaTexto_lx)/dh);

		xfp2:=ph*xfp1;
		xfp1:=xfp2-xfp1;

		xp1:= xfp1+4*quita;
		xp2:= xfp2;

		yfp1:=trunc(GetMaxY/dv);
		yfp2:=pv*yfp1;
		yfp1:=yfp2-yfp1;

		yp2:=yfp2-2*quita;
		yp1:=yfp1+4*quita;

		color:=tinta;
      fondo:= ColorDefFondo;
		x1:=x0;y1:=y0;
		x2:=x0+gridx*dx;
		y2:=y0+gridy*dy;
	 end
end;

procedure DefinaColor(xcanal: integer; xcolor:TColor);
begin
canal[xcanal].color:=xcolor;
end;

procedure ActiveCanal(k:integer);
begin
 activo:=k;
end;

procedure borde;
begin
with canal[activo] do
begin
	trx.Pen.Color:= colorAuxiliar;
	trx.Rectangle(xp1,yp1,xp2,yp2);
   if trz <> nil then
   begin
   	trz.Pen.Color:= colorAuxiliar;
	   trz.Rectangle(xp1,yp1,xp2,yp2);
   end;
end;
end;

procedure titulo(x:string);
var
	d: integer;
begin
   colorPapelTexto:= ColorPapelTitulos;
	d:= TextHeight( x );
	with canal[activo] do
   begin
		OutTextXY( xp1+2,yp1-2-d,x);
   end;
end;

procedure xlabel(x:string);
begin
   colorPapelTexto:= ColorPapelTitulos;
	with canal[activo] do
   begin
		OutTextXY( xp1+2,yp2+2,x);
   end;
end;


// Note that the angle is in 1/10 of degrees.
// Any attempt to manipulate font.size or font.color
// will reset the angle to zero degrees.
procedure SetTextAngle(F:Tfont; angle: Word);
var
  LogRec: TLOGFONT;
begin
  GetObject(f.Handle,SizeOf(LogRec),Addr(LogRec));
  LogRec.lfEscapement := angle;
  f.Handle := CreateFontIndirect(LogRec);
end;


procedure ylabel(x:string);
var
	d: integer;
	t:TextSettingsType;

begin
   colorPapelTexto:= ColorPapelTitulos;
	GetTextSettings(t);
	SetTextJustify(just_IZQUIERDA, just_ABAJO);
	d:= 0; //TextWidth(x);
	SetTextStyle(t.font,VertDir,t.CharSize);
	with canal[activo] do
   begin
		OutTextXY( xp1-2-d,yp2-2,x);
   end;
	SetTextStyle(t.font,t.Direction,t.CharSize);
	SetTextJustify(t.Horiz, t.Vert);
end;

procedure BorreTitulo;
begin
end;


function tpix:integer; forward;

(*-----------------------------------*)
procedure InicieGr( xcanvas, zcanvas: TCanvas; Ancho, Alto: integer; AreaTexto__lx: integer );
var
	Xasp, Yasp : Word;
	Gd, Gm : integer;
	gres: integer;
begin
   AreaTexto_lx:= AreaTexto__lx;
   viewPort.Left:= 0;
   viewPort.Top:= 0;
   viewPort.Right:= Ancho;
   viewPort.Bottom:= Alto;
   viewPort_clip:= true;

	trx:= xcanvas;
   trz:= zcanvas;
	GetMaxX:= Ancho;//paintbox.ClientRect.Right-paintbox.ClientRect.Left
	GetMaxY:= Alto; //paintbox.ClientRect.Bottom-paintbox.ClientRect.Top;
	trx.Brush.Color:= ColorDefFondo ;
	trx.Pen.Color:=ColorDefTrazo;
	trx.FillRect( Rect(0,0, Ancho, Alto ) );
//	windows.FillRect(trx.handle, Rect(0,0,Ancho,Alto),trx.brush.handle);

   if trz <> nil then
   begin
   	trz.Brush.Color:= ColorDefFondo ;
	   trz.Pen.Color:=ColorDefTrazo;
   	trz.FillRect( Rect(0,0, Ancho, Alto ) );
   end;

	Estado:=true;
end;



procedure Lin(x1,y1,x2,y2:integer;pattern: TPenStyle; grueso:word);
var
   visible: boolean;
begin
{
   Liang_Barsky( x1,y1,x2,y2, Canal[activo], visible);
   if not visible then exit;
 }
	trx.Pen.Style:= pattern;
	trx.Pen.Width:= grueso;
	trx.moveto(x1,y1);
	trx.lineto(x2,y2);
   if trz <> nil then
   begin
   	trz.Pen.Style:= pattern;
	   trz.Pen.Width:= grueso;
   	trz.moveto(x1,y1);
	   trz.lineto(x2,y2);
   end;
end;


procedure GridHorizontal;
var

k,j:integer;
dx,dy:NReal;

begin
with canal[activo] do
 begin

	dx:=(xp2-xp1)/gridx;
	dy:=(yp2-yp1)/gridy;
	setColor(COlorAuxiliar);
	for k:=1 to gridy-1 do
				  lin(xp1,yp1+trunc(dy*k),xp2,yp1+trunc(dy*k), psDot, 1);
 end;
end; (* GridHorizontal *)


procedure grid;
var

k,j:integer;
dx,dy:NReal;
oldStyle: TPenStyle;
oldGrueso: integer;

begin
	oldStyle:= trx.Pen.Style;
	oldGrueso:= trx.Pen.Width;

with canal[activo] do
 begin

	 dx:=(xp2-xp1)/gridx;
	 dy:=(yp2-yp1)/gridy;
	 trx.Pen.Color:=ColorAuxiliar;
   if trz <> nil then
	 trz.Pen.Color:=ColorAuxiliar;

	for k:=1 to gridx-1 do
				  lin(xp1+trunc(dx*k),yp1,xp1+trunc(dx*k),yp2, psDot,1);
	for k:=1 to gridy-1 do
				  lin(xp1,yp1+trunc(dy*k),xp2,yp1+trunc(dy*k), psDot,1);

 end;

	trx.Pen.Style:= oldStyle;
	trx.Pen.Width:= oldGrueso;
   if trz <> nil then
   begin
   	trz.Pen.Style:= oldStyle;
	   trz.Pen.Width:= oldGrueso;
   end;

end; (* Grid *)

(*------------------------------------------------*)



(******************************************************)

procedure Desligue(n:integer);
begin
	activo:=n;
	canal[activo].inicializado:=false;
end;


procedure trazo(n:integer;y:NReal);
begin
	trazoXY(n,t,y); { 26.07.92.rch }
end;



procedure Barra(n:integer; y:NReal);
var
	temp:NReal;
	xpt,ypt:integer;
begin
	activo:=n;
	with canal[activo] do
	begin
		if y2<>y1 then
			temp:=(yp2-yp1)*(y2-y)/(y2-y1)+yp1
		else temp:=2*yp2;
		if (temp>yp2) or (temp<yp1) then
			inicializado:=false
		else
			begin
			xpt:=tpix;
			ypt:=trunc(temp);
			if not(inicializado) then
				begin
				xp:=xpt;yp:=ypt;
				inicializado:=true
				end;
			trx.rectangle(xp,ypt,xpt,yp2);
         if trz <> nil then
   			trz.rectangle(xp,ypt,xpt,yp2);
			xp:=xpt;
			yp:=ypt;
			end;
	end;
end;

procedure DrawClipLine(xp,yp,xpt,ypt: integer; var ClipRectangle; color: TColor);
var
   visible: boolean;
begin
  Liang_Barsky( xp,yp,xpt,ypt, ClipRectangle, visible);
  if not visible then exit;
  trx.Pen.Color:=Color;
  trx.MoveTo(xp,yp);
  trx.LineTo(xpt,ypt);
  if trz <> nil then
  begin
     trz.Pen.Color:=Color;
     trz.MoveTo(xp,yp);
     trz.LineTo(xpt,ypt);
  end;
end;

(****************************************** 4/7/90 **)
procedure trazoXY(n:integer;x,y:NReal);
var
	tempX,tempY:NReal;
	xpt,ypt:integer;
   visible: boolean;

begin
	activo:=n;

	with canal[activo] do
	begin

		tempY:=(yp2-yp1)*(y2-y)/(y2-y1)+yp1;
		tempX:=(xp2-xp1)*(x-x1)/(x2-x1)+xp1;

		xpt:=trunc(tempX);
		ypt:=trunc(tempY);

		if not(inicializado) then
		begin
			xp:=xpt;
			yp:=ypt;
			inicializado:=true;
		end;
      DrawClipLine( xp,yp,xpt,ypt, Canal[activo], Color );
		xp:=xpt;yp:=ypt;
	end;
end;


procedure trazoXYColorEstilo(
			kanal:integer;
			x,y: NREal;
			xcolor: TColor; xestilo:integer);
var
	tempX,tempY:NReal;
	xpt,ypt:integer;


begin
	activo:=kanal;

	with canal[activo] do
	begin
		tempY:=(yp2-yp1)*(y2-y)/(y2-y1);
		tempX:=(xp2-xp1)*(x-x1)/(x2-x1);
		xpt:=trunc(tempX);
		ypt:=trunc(tempY);

		if not(inicializado) then
		begin
			xp:=xpt;
			yp:=ypt;
			inicializado:=true;
		end;
		SetColor(xColor);
		Line(xp,yp,xpt,ypt);
		SetLineStyle(psSolid,0,NormWidth);
		xp:=xpt;yp:=ypt;
	end;

end;
procedure BarraXY(n:integer;x,y:NReal);
var
	tempX,tempY:NReal;
	xpt,ypt:integer;
begin
	activo:=n;
	with canal[activo] do
	begin
		SetViewPort(xp1,yp1,xp2,yp2,true);
		tempY:=(yp2-yp1)*(y2-y)/(y2-y1);
		tempX:=(xp2-xp1)*(x-x1)/(x2-x1);
		xpt:=trunc(tempX);
		ypt:=trunc(tempY);

		SetFillStyle(bsBDiagonal, Blanco);

		if not(inicializado) then
		begin
			xp:=xpt;
			yp:=ypt;
			inicializado:=true;
		end;
		SetColor(Color);
		Bar3d(xp,ypt,xpt,yp2,5,true);
		xp:=xpt;yp:=ypt;
	end;
end;



procedure Linea0;
var
temp:NReal;
dpix:NReal;
k:integer;
begin
with canal[activo] do
 begin
 dpix:=(xp2-xp1)/50;
 temp:=(yp2-yp1)*y2/(y2-y1)+yp1;
 if (temp>yp2) or (temp<yp1) then
	  else
	  for k:=1 to 49 do
		line(trunc(xp1+dpix*k),trunc(temp)+2,trunc(xp1+dpix*k),trunc(temp)-2);
 end
end;



(* determina el tiempo en pixels correspondiente al tiempo externo *)
function tpix:integer;
begin
with canal[activo] do
	if abs(x2-x1)>1e-15 then tpix:=trunc((t-x1)/(x2-x1)*(xp2-xp1)+xp1)
   else tpix:=0
end;

procedure SubPlot(kx,ky:integer);
var
 k,j,nc:integer;
begin
nc:=0;
for k:=1 to kx do
    for j:=1 to ky do
     begin
		 activo:=nc;nc:=nc+1;
		DefinaCanal(kx,k,ky,j,tinicial,(tfinal-tinicial)/gridx,0,1,ColorDefTrazo);
      borrecanal( (k-1)*ky +(j-1), ColorDefFondo );
		Borde;
		end
end;

procedure Superponga(c1,c2:integer);
begin
	canal[c1]:=canal[c2]
end;


procedure DefinaY(c:integer;y0,dy:NReal);
begin
activo:=c;
with canal[activo] do
     begin
       y1:=y0;
       y2:=y0+dy*gridy;
     end
end;

procedure DefinaX(c:integer;X0,dX:NReal);
begin
activo:=c;
with canal[activo] do
	begin
	x1:=x0;
	x2:=x0+dx*gridx;
	end
end;

var
   k: integer;
begin
Estado:= False;
ColorAuxiliar:= Azul;
ColorDefFondo:= Blanco;
ColorPapelTitulos:= Blanco;
ColorPapelTexto:= ColorDefFondo;
ColorDefTrazo:= Azul;
ColorTintaTexto:= ColorDefTrazo;
tinicial:= 0;
tfinal:= 100;

{$IFNDEF RCHFONTS}

glob_AnguloTexto10:= 0;

for k:= 0 to 3 do
begin
   Fonts[k]:= TFont.Create;
   Fonts[k].CharSet:= 1;
   Fonts[k].name:='Arial';
   Fonts[k].Size:= 8+k;
end;
{$ENDIF}
{
AlineacionTextoHorizontal:= RightText;
AlineacionTextoVertical:= BottomText;
InicieCanales;
 }
end.
