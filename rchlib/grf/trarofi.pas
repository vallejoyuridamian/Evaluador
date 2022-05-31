{+doc
+NOMBRE:trarofi
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO:Graficador en coordenadas polares.
+PROYECTO:rchlib

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

unit TraRoFi;

interface
uses
  xMatDefs,
{$I	xGraph},
{$I	xTraXP};

const
	DefGridRo:integer=10;
	DefGridFi:integer=18;
Const
	Resolucion:integer = 40;

type
	TrazoRofi = object
		GridRo, GridFi:integer;
		DivRo,DivFi:NReal;
		Ro0,Fi0:NReal;
		ColorFondo,ColorGrid,ColorTrazo:integer;
		canal:integer;
		constructor Init;
		procedure asigneCanal(kanal:integer);
		procedure DefinaRo(xdivro:NReal);
		procedure trazo(r,f:NReal);
		procedure encuadre;
		procedure Desligue;
		procedure Grid;
		procedure LabelRF(r,f:NReal;texto:string);
		procedure DefinaColor(k:word);
		end;

implementation

function rad(x:NReal):NReal;
begin
	rad:=x/180*pi;
end;

{M‚todos de TrazoRoFi }

procedure TrazoRoFi.LabelRF(r,f:NReal;texto:string);
begin
	{$IFDEF HPGL }
	hptraxp
	{$ELSE}
	{$IFDEF WINDOWS}
	TraxpW
	{$ELSE }
	traxp
	{$ENDIF}
	{$ENDIF}.LabelXY(canal,r*sin(f),-r*cos(f),texto);
end;


procedure TrazoRoFI.DefinaColor(k:word);
begin
	ColorTrazo:=k;
	{$IFDEF HPGL }
	hptraxp
	{$ELSE}
	{$IFDEF WINDOWS}
	TraxpW
	{$ELSE }
	traxp
	{$ENDIF}
	{$ENDIF}.DefinaColor(canal,k);
end;

procedure TrazoRoFI.Desligue;
begin
	{$IFDEF HPGL }
	hptraxp
	{$ELSE}
	{$IFDEF WINDOWS}
	TraxpW
	{$ELSE }
	traxp
	{$ENDIF}
	{$ENDIF}.Desligue(canal);
end;

procedure trazoRoFi.Grid;
var
	k:integer;
	r:NReal;

procedure SemiCefa(radio:NReal);

var
	k:integer;
	df,f:NReal;

begin
	Desligue;
	df:=pi/Resolucion;
	for k:=0 to resolucion do
	begin
		f:=k*df;
		if f>pi then f:= pi;
		trazo(radio,f-pi/2);
	end;
end;
{11/8/91 +}
var
	OldStyle   : LineSettingsType;
{11/8/91 -}

begin

	{11/8/91 + tratando de hacer la grilla punteada }
	GetLineSettings(OldStyle);
	SetLineStyle(DottedLn,0,NormWidth);
	{11/8/91 - }

{ GridFi }
	r:=DivRo*GridRo*2;
	for k:=1 to GridFi-1 do
		begin
			Desligue;
			Trazo(0.5,k*DivFi-pi/2);
			Trazo(R,k*DivFi-pi/2);
		end;
{ GridRo }
	for K:=1 to GridRo+2 do
			SemiCefa(k*DivRo);
{11/8/91 +}
	with OldStyle do
  begin
		SetLineStyle(LineStyle,Pattern,Thickness);
 	end;

{11/8/91 -}
end;

procedure TrazoRoFi.asigneCanal(Kanal:integer);
begin
	canal:=kanal;
end;


procedure TrazoRoFi.Encuadre;
var
	xp1,yp1,xp2,yp2:integer;
	r1:NReal;
	x1,x2,y1,y2:NReal;
begin

	GetXPYP(canal,xp1,yp1,xp2,yp2);
	r1:=gridRo*divRo;
	x2:=r1*(xp2-xp1)/(yp2-yp1)/2*ERF;
	x1:=-x2;
	y1:=-r1;
	y2:=0;
	{$IFDEF HPGL }
	hptraxp
	{$ELSE}
	{$IFDEF WINDOWS}
	TraxpW
	{$ELSE }
	traxp
	{$ENDIF}
	{$ENDIF}.DefinaX(canal,x1,(x2-x1)/gridx);

	{$IFDEF HPGL }
	hptraxp
	{$ELSE}
	{$IFDEF WINDOWS}
	TraxpW
	{$ELSE }
	traxp
	{$ENDIF}
	{$ENDIF}.DefinaY(canal,y1,(y2-y1)/gridy);
end;

Constructor TrazoRoFi.Init;
begin
	GridFi:=DefGridFi;
	GridRo:=DefGridRo;
   Ro0:=0;
	Fi0:=0;
	DivFi:=rad(10);
	ColorFondo:=Negro;
	ColorGrid:=Amarillo;
	ColorTrazo:=Blanco;
end;

procedure TrazoRoFi.DefinaRO(XdivRo:NReal);
begin
	DivRo:=XdivRo;
end;

procedure trazoRoFi.Trazo(r,f:NReal);
begin
	trazoXY(canal,r*sin(f),-r*cos(f));
end;

end.

