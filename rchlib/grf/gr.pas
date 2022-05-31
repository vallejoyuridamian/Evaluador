{+doc
+NOMBRE: GR
+CREACION:1.1.90
+AUTORES:rch
+REGISTRO:
+TIPO: Unidad Pascal.
+PROPOSITO: Definicion de servicios de despliegue grafico.
+PROYECTO:

+REVISION:
+AUTOR:
+DESCRIPCION:
-doc}

{$O+,F+}
Unit GR;

interface
	uses
		PathDrvs, Graph, VPDef;


const
   NormalPut     = 0;    { MOV }
   CopyPut       = 0;    { MOV }
   XORPut        = 1;    { XOR }
   OrPut         = 2;    { OR  }
   AndPut        = 3;    { AND }
   NotPut        = 4;    { NOT }

	GetPutMode:word = NormalPut;
	GetActivePage: word = 0;
	GetVisualPage: word = 0;


	 { Colores: }
	 Negro        = 0;
	 Azul         = 1;
	 Verde        = 2;
	 Celeste      = 3;
	 Rojo         = 4;
	 Violeta      = 5;
	 Marron       = 6;
	 GrisClaro    = 7;
	 GrisOscuro   = 8;
	 AzulClaro    = 9;
	 VerdeClaro   = 10;
	 CeleteClaro  = 11;
	 RojoClaro    = 12;
	 VioletaClaro = 13;
	 Amarillo     = 14;
	 Blanco       = 15;



type

	point = record
		x,y:integer;
	end;


	Polygon = object(VectOfPoint)
		x1,y1,x2,y2:integer; (* Extent: rect ngulo que incluye al Poly. *)
		procedure ventana;   (* C lcula el Extent *)
		constructor init(nx:integer); (* Inicializa, nx = n£mero m ximo de puntos *)
		procedure PutXY(k,nx,ny:integer); (* Punto[k] := (nx,ny) *)
		procedure Put(k:integer; nP:point);  (* Punto[k]:= nP *)
		procedure Get(k:integer;var x:point);  (* x:= Punto[k] *)
		procedure Show;      (* Dibuja el Poly. *)
	end;

var
	MaxPoint:Point;

	procedure Init;
	procedure Close;
	procedure Pixel(P:point; Color: word);
	procedure FillArea(var X: Polygon);
	procedure SetOrd;
	procedure SetInv;
	procedure SetPutMode(k:integer);
	procedure SetColor(x: word);
	procedure Line(P1,P2:point);
	procedure LineXY(x1,y1,x2,y2:integer);
	procedure Rectangle(P1,P2:point);
	procedure RectangleXY(x1,y1,x2,y2:Integer);
	procedure SetVisualPage(k:integer);
	procedure SetActivePage(k:integer);
	procedure GetImage(P1,P2:point; var Imag);
	procedure GetImageXY(x1,y1,x2,y2:integer; var Imag);

	procedure PutImage(P:point;var Imag);
	procedure PutImageXY(x,y:Integer; var Imag);

	function ImageSize(P1,P2:point):word;
	function ImageSizeXY(x1,y1,x2,y2:integer):word;
	function GetBkColor:word;

	procedure MakePoint( var P: point; x,y:integer);

implementation

procedure MakePoint( var P: point; x,y:integer);
begin
	P.x:= x;
	P.y:= y;
end;


function GetBkColor:word;
begin
	GetBkColor:=Graph.GetBkColor
end;
procedure Pixel(P:point; Color: word);
begin
	PutPixel(p.x,p.y,Color);
end;


procedure Rectangle(P1,P2:point);
begin
	graph.rectangle(p1.x,p1.y,p2.x,p2.y);
end;

procedure RectangleXY(x1,y1,x2,y2:integer);
begin
	graph.rectangle(x1,y1,x2,y2);
end;

function ImageSizeXY(x1,y1,x2,y2:integer):word;
begin
	ImageSizeXY:=graph.ImageSize(x1,y1,x2,y2);
end;

function ImageSize(P1,P2:point):word;
begin
	ImageSize:=graph.ImageSize(P1.x,P1.y,P2.x,P2.y);
end;

procedure PutImage(P:point;var Imag);
begin
	Graph.PutImage(P.x,P.y,Imag,GetPutMode)
end;

procedure PutImageXY;
begin
	graph.PutImage(x,y,Imag,GetPutMode);
end;

procedure LineXY(x1,y1,x2,y2:integer);
begin
	graph.Line(x1,y1,x2,y2);
end;

procedure GetImage(P1,P2:point; var Imag);
begin
	graph.GetImage(P1.x,P1.y,P2.x,P2.y,Imag);
end;

procedure GetImageXY(x1,y1,x2,y2:integer; var Imag);
begin
	graph.GetImage(x1,y1,x2,y2,Imag);
end;

procedure SetVisualPage(k:integer);
begin
	GetVisualPage:=k;
	graph.SetVisualPage(k);
end;

procedure SetColor(x: word);
begin
	graph.SetColor(x);
end;

procedure SetActivePage(k:integer);
begin
	GetActivePage:=k;
	graph.SetActivePage(k);
end;



{==================================}
procedure Init;
var
	grDriver : Integer;
	grMode   : Integer;
	ErrCode  : Integer;
begin
	grDriver := Detect;
	InitGraph(grDriver,grMode,PathToBgi);
	ErrCode := GraphResult;
	if ErrCode = grOk then
	begin
		graph.SetActivePage(GetActivePage);
		graph.SetVisualPage(GetActivePage);
		MaxPoint.x:=graph.GetMaxX;
		MaxPoint.y:=graph.GetMaxY;
	end
	else
		WriteLn('Graphics error:', GraphErrorMsg(ErrCode));
end;

procedure Close;
begin
	CloseGraph
end;
{================================================}




procedure FillArea(var x:Polygon);
var
	p:pointer;
	Size:integer;
begin
	SetActivePage(1);
	graph.ClearViewPort;
	x.ventana;
	graph.FillPoly(x.n, x.pv^);
	Size := graph.ImageSize(x.x1,x.y1,x.x2,x.y2);
	GetMem(P, Size); { Allocate on heap }
	graph.GetImage(x.x1,x.y1,x.x2,x.y2,P^);
	SetActivePage(0);
	graph.PutImage(x.x1,x.y1,P^,GetPutMode);
	FreeMem(P,Size);
end;

procedure SetOrd;
begin
	GetPutMode:=OrPut;
end;

procedure SetInv;
begin
	GetPutMode:=XOrPut;
end;

procedure SetPutMode(k:integer);
begin
	GetPutMode:=k
end;

procedure Line(P1,P2:point);
begin
	Graph.Line(p1.x,p1.y,p2.x,p2.y);
end;

{ Polygon methods }

procedure Polygon.ventana;
var
	k:integer;
	temp:point;
begin
	Get(1,temp);
	x1:=temp.x; x2:=x1;
	y1:=temp.y; y2:=y1;
	for k:= 2 to n do
		begin
			Get(k,temp);
			if temp.x < x1 then x1:= temp.x;
			if temp.x>x2 then x2:= temp.x;
			if temp.y < y1 then y1 := temp.y;
			if temp.y > y2 then y2 := temp.y
		end;
end;

constructor Polygon.Init(nx:integer);
begin
	VectOfPoint.Init(nx);
end;

procedure Polygon.PutXY(k,nx,ny:integer);
var
	temp:pointer;
begin
	temp:=pte(k);
	point(temp^).x:=nx;
	point(temp^).y:=ny;
end;

procedure Polygon.Put(k:integer; nP:point);
var
	pt:pointer;
begin
	pt:=pte(k);
	point(pt^):=nP;
end;

procedure Polygon.Get(k:integer;var x:point);
var
	pt:pointer;
begin
	pt:=pte(k);
	x:=point(pt^);
end;

procedure Polygon.Show;
begin
	DrawPoly(n,pv^);
	line(point(pte(n)^),point(pv^));
end;


end.