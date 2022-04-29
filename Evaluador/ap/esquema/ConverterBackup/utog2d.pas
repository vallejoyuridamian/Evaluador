unit utog2d;

interface
uses
	Windows, Controls, classes, graphics,
  AlgebraC, xMatDefs, MatCpx,
	sysutils;



const
	BordeSel= 4; // ancho en pixeles del borde de seleccion
  px_RadioPunto = 3; // radio para destaque de puntos. Cuadrado o Circulo.


type
	TEstadoTOG2D  = ( E_Normal, E_Editando, E_Creando );

	TRectComplex= record
		m1, m2: NComplex;
	end;



	TCanalGrafico2D = class

		c0: NComplex; // coordenadas del vertice iferior izquierdo en reales
		cr: NComplex; // roto-homotecia a aplicar

		wx, hy: NReal; // ancho y alto en reales

		DistanciaTocado: integer;

		w,h: integer; // ancho y alto en pixels
		canvas: TCanvas;


		constructor Create( canvas: TCanvas );

		function rx2ix( rx:NReal): integer;
		function ry2iy( ry:NReal): integer;
		function ix2rx( ix:integer): NReal;
		function iy2ry( iy:integer): NReal;

		procedure xy2cx( x, y: integer; var cx: NComplex );
		procedure cx2xy( cx: NComplex; var x,y: integer );

    // funciones de dibujo
		procedure CirculoPunto( cx: NComplex );
		procedure CuadradoPunto( cx: NComplex );
		procedure CuadradoPuntoDestacado( cx: NComplex );

		procedure MoveTo( const cx: NComplex );
		procedure LineTo( const cx: NComplex );
    procedure FillRect ( const cx1, cx2: NComplex );
    procedure Polygon( const vertices: TVarArrayOfComplex ); // draw and fill a closed Polygon
    procedure Polyline( const vertices: TVarArrayOfComplex ); // draw an open poly-line (no fill)


    // invalidar un rectángulo para lograr que se redibuje
    // le agrega px_Radio en todos los sentidos para incluir los
    // posibles destaques.
		procedure InvalidarRectangulo(
      h: hwnd; c1,c2: NComplex; scroll_x, scroll_y: integer );

	end;


{ Los objetos nada saben de las escalas del canal gráfico. Así que
en el contexto del objeto las coordenadas son reales. Los puntos
los representamos por números complejos. }
	Tog2d = class
    esquema : pointer; // referencia al esquema.
		ct, cr: NComplex;
		estado_x: TEstadoTOG2D;
		seleccionado: boolean;

    Nombre: String;

(*
		padre: TOG2D;
		hijos: array of TOG2D;
	*)
		GrosorPen: integer;
		EstiloPen: TPenStyle;
		ColorPen: TColor;
		ColorBrush: TColor;
		EstiloBrush: TBrushStyle;
		marco: TRectComplex;

		constructor Create( cx: NComplex );
		procedure Show( cg: TCanalGrafico2D ); virtual;

    // indica si se puede considerar que el punto cx está en el objeto o su cercanía
		function Tocado( cx: NComplex; ra: NReal ): boolean; virtual;

    // retorna el índice del vértice más cercano y la distancia al mismo
    function VerticeMasCercano( cx: NComplex ; var distancia: NReal ): integer; virtual;

		procedure Free; virtual;

		procedure MoverA( cx: NComplex ); virtual;
		procedure desplazar( dcx: NComplex ); virtual;

    // cuando el aspecto gráfico es editable
    // pueden entrar en modo edit y en ese caso
    // los movimientos del  mouse tienen que se coherentes
    // con el modo. Para volver al modo normal ejecutar ExitEdit.
    // Por ejemplo Dblclick sobre un objeto podría usarse para ponerlo
    // en modo edit y otro DblClick para sacarlo.
    procedure EnterEdit; virtual;
    procedure ExitEdit; virtual;

		procedure MouseDown(Button: TMouseButton;
				Shift: TShiftState; cx: NComplex ); virtual;
		procedure MouseMove(Shift: TShiftState; cx: NComplex ); virtual;
		procedure MouseUp(Button: TMouseButton;
				Shift: TShiftState; cx: NComplex ); virtual;

		procedure WriteToFile( var f: textFile ); virtual;
		constructor ReadFromFile( var f: textFile ); virtual;
		procedure ActualizarMarco; virtual;
		function MarcoToca( var rcx: TRectComplex ): boolean;


	end;

	TDAOfog2d= array of Tog2d;



	TOG2D_Grupo   = class ( TOG2D )
		Integrantes: TDAOfOG2D;
		constructor Create( xIntegrantes: TDAOfog2d );
		procedure Show( cg: TCanalGrafico2D ); override;
		function Tocado( cx: NComplex; ra: NReal ): boolean; override;
		procedure Free; override;
		procedure desplazar( dcx: NComplex ); override;
		procedure MouseDown(Button: TMouseButton;
				Shift: TShiftState; cx: NComplex ); override;
		procedure MouseMove(Shift: TShiftState; cx: NComplex ); override;
		procedure MouseUp(Button: TMouseButton;
				Shift: TShiftState; cx: NComplex ); override;
		procedure WriteToFile( var f: textFile ); override;
		constructor ReadFromFile( var f: textFile ); override;
		procedure ActualizarMarco; override;
	end;



function rcx_EsVacio( var rcx: TRectComplex ): boolean;
procedure rcx_Vaciar( var rcx: TRectComplex );
{ unimos los rectángulos m1, m2 con m3, m4 y el resultado queda en
m1, m2. Se supone que los rectángulos son ordenados. }
procedure rcx_Unir( var rcx1:TRectComplex; rcx2: TRectComplex );
procedure rcx_Expandir( var rcx: TRectComplex; cx: NComplex );


function ReadOgFromFile( var f: textfile ): Tog2d;
procedure WriteOgToFile( var f: textfile; og: TOg2d );

type
  TClassOfTOG = class of TOG2d;

procedure Registrar_Clase( x: TClassOfTOG );
procedure AlInicio;


implementation
uses
  upoligonal,
  uesquema;

var
  ClasesRegistradas: TList;


procedure Registrar_Clase( x: TClassOfTOG );
begin
  ClasesRegistradas.Add( x );
end;

function Locate_Class( nombre: String ): TClassOfTog;
var
  buscando: boolean;
  res: TClassOfTog;
  k: integer;
begin
  buscando:= true;
  k:= 0;
  while buscando and ( k < ClasesRegistradas.count ) do
  begin
    res:= TClassOfTog( ClasesRegistradas.items[k] );
    if res.ClassName = nombre then
      buscando:= false
    else
      inc( k );
  end;
  if buscando then
    result:= nil
  else
    result:= res;
end;



function ReadOgFromFile( var f: textfile ): TOG2D;
var
	og: Tog2d;
	tipo_og: shortstring;

  clase_og: TClassOfTog;

begin
	readln( f, tipo_og );
  clase_og:= Locate_Class( tipo_og );

  if clase_og <> nil then
    og:= clase_og.ReadFromFile( f )
	else
		raise Exception.Create( 'Tipo_og: '+tipo_og +' no es conocido.' );

(*
	if tipo_og= 'TOG2D' then
		og:= TOG2D.ReadFromFile(f)
	else if tipo_og= 'TOG2D_POLIGONAL' then
		og:= TOG2D_Poligonal.ReadFromFile(f)
	else if tipo_og= 'TESQUEMA' then
		og:= TEsquema.ReadFromFile(f)
	else if tipo_og= 'TOG2D_GRUPO' then
		og:= TOg2d_Grupo.ReadFromFile(f )
*)
	result:= og;
end;

procedure WriteOgToFile( var f: textfile; og: TOg2d );
begin
	writeln( f, og.ClassName );
	og.WriteToFile( f );
end;


function enorden( x, y, z : NReal ): boolean;
begin
	result:= (x<=y) and (y<=z);
end;

procedure swapints( var x, y: integer );
var
	z: integer;
begin
	z:= x;
	x:= y;
	y:= z;
end;


procedure swapreales( var r1, r2: NReal );
var
	z: NReal;
begin
	z:= r1;
	r1:= r2;
	r2:= z;
end;

{ retorna TRUE si es de área nula  }
function rcx_EsVacio( var rcx: TRectComplex ): boolean;
begin
	result:= ( rcx.m1.r= rcx.m2.r ) or ( rcx.m1.i= rcx.m2.i );
end;

procedure rcx_Vaciar( var rcx: TRectComplex );
begin
	rcx.m1:= complex_nulo;
	rcx.m2:= complex_nulo;
end;

{ ordenamos los puntos para que m1 sea el vérice inferior izquierdo
y m2 el superior derecho }
procedure rcx_Ordenar( var rcx: TRectComplex );
begin
	with rcx do
	begin
		if m1.r > m2.r then swapreales( m1.r, m2.r );
		if m1.i > m2.i then swapreales( m1.i, m2.i );
	end;
end;


{ unimos los rectángulos m1, m2 con m3, m4 y el resultado queda en
m1, m2. Se supone que los rectángulos son ordenados. }
procedure rcx_Unir( var rcx1:TRectComplex; rcx2: TRectComplex );
begin
	if rcx1.m1.r=rcx1.m2.r then
	begin
		rcx1.m1.r:= rcx2.m1.r;
		rcx1.m2.r:= rcx2.m2.r;
	end
	else if rcx2.m1.r <> rcx2.m2.r then
	begin
		if rcx2.m1.r < rcx1.m1.r then rcx1.m1.r:= rcx2.m1.r;
		if rcx2.m2.r > rcx1.m2.r then rcx1.m2.r:= rcx2.m2.r;
	end;

	if rcx1.m1.i=rcx1.m2.i then
	begin
		rcx1.m1.i:= rcx2.m1.i;
		rcx1.m2.i:= rcx2.m2.i;
	end
	else if rcx2.m1.i <> rcx2.m2.i then
	begin
		if rcx2.m1.i < rcx1.m1.i then rcx1.m1.i:= rcx2.m1.i;
		if rcx2.m2.i > rcx1.m2.i then rcx1.m2.i:= rcx2.m2.i;
	end;
end;


procedure rcx_Expandir( var rcx: TRectComplex; cx: NComplex );
begin
	if cx.r > rcx.m2.r then
		rcx.m2.r:= cx.r
	else if cx.r < rcx.m1.r then
		rcx.m1.r:= cx.r;

	if cx.i > rcx.m2.i then
		rcx.m2.i:= cx.i
	else if cx.i < rcx.m1.i then
		rcx.m1.i:= cx.i;

end;

// métodos de TCanalGrafico2D



constructor TCanalGrafico2D.Create( canvas: TCanvas );
begin
	c0:= Complex_NULO;
	cr:= Complex_UNO;
	wx:= 1000;
	hy:= 1000;
	DistanciaTocado:= 3;
	w:= 1000;
	h:= 1000;
	Self.Canvas:= canvas;
end;




function TCanalGrafico2D.rx2ix( rx:NReal): integer;
begin
	result:=trunc( rx*w/wx+0.5 );
end;

function TCanalGrafico2D.ry2iy( ry:NReal): integer;
begin
	result:= h-trunc( ry*h/hy+0.5 );
end;

function TCanalGrafico2D.ix2rx( ix:integer): NReal;
begin
	 result:= ix*wx/w;
end;

function TCanalGrafico2D.iy2ry( iy:integer): NReal;
begin
	result:= (h-iy)*hy/h;
end;



procedure TCanalGrafico2D.xy2cx( x, y: integer; var cx: NComplex );
begin
	 cx:= sc( dc(numc( rx2ix(x), ry2iy(y) )^, cr)^, c0)^;
end;

procedure TCanalGrafico2D.cx2xy( cx: NComplex; var x,y: integer );
var
	 a: NComplex;
begin
	a:= pc( rc( cx, c0)^, cr )^;
  x:= rx2ix( a.r );
	y:= ry2iy( a.i );
end;



procedure TCanalGrafico2D.CirculoPunto( cx: NComplex );
var
	 x, y: integer;
begin
	 cx2xy( cx, x, y );
	 Canvas.brush.color := clRed;
	 Canvas.brush.style := bsDiagCross;
	 Canvas.Ellipse(x-px_RadioPunto, y-px_RadioPunto, x+px_RadioPunto, y+px_RadioPunto);
end;


procedure TCanalGrafico2D.CuadradoPunto( cx: NComplex );
var
   x, y: integer;
begin
	cx2xy( cx, x, y );
	Canvas.pen.color:= clBlue;
	Canvas.brush.color := clBlue;
	Canvas.brush.style := bsSolid;
  Canvas.Rectangle(x-px_RadioPunto, y-px_RadioPunto, x+px_RadioPunto, y+px_RadioPunto);
end;

procedure TCanalGrafico2D.CuadradoPuntoDestacado( cx: NComplex );
var
   x, y: integer;
begin
	cx2xy( cx, x, y );
	Canvas.pen.color:= clRed;
	Canvas.brush.color := clRed;
	 Canvas.brush.style := bsSolid;
   Canvas.Rectangle(x-px_RadioPunto, y-px_RadioPunto, x+px_RadioPunto, y+px_RadioPunto);
end;


procedure TCanalGrafico2D.MoveTo( const cx: NComplex );
var
   x, y: integer;
begin
	cx2xy( cx, x, y );
	Canvas.MoveTo(x,y);
end;

procedure TCanalGrafico2D.LineTo( const cx: NComplex );
var
	x, y: integer;
begin
	cx2xy( cx, x, y );
	Canvas.LineTo(x,y);
end;

procedure TCanalGrafico2D.FillRect( const cx1, cx2: NComplex);
var
  x1, y1, x2, y2: integer;
begin
  cx2xy( cx1, x1, y1 );
  cx2xy( cx2, x2, y2 );
  Canvas.FillRect( Rect(x1, y1, x2, y2 ))
end;

procedure TCanalGrafico2D.Polygon( const vertices: TVarArrayOfComplex ); // draw and fill a closed Polygon
var
  Ps : array of TPoint;
  k: integer;
  N: integer;
begin
  N:= length( vertices );
  setlength( Ps, N );
  for k := 0 to N-1 do
    cx2xy(  vertices[k], Ps[k].X, Ps[k].Y );
  Canvas.Polygon( Ps );
  setlength( Ps, 0 );
end;

procedure TCanalGrafico2D.Polyline( const vertices: TVarArrayOfComplex ); // draw an open poly-line (no fill)
var
  Ps : array of TPoint;
  k: integer;
  N: integer;
begin
  N:= length( vertices );
  setlength( Ps, N );
  for k := 0 to N-1 do
    cx2xy(  vertices[k], Ps[k].X, Ps[k].Y );
  Canvas.Polyline( Ps );
  setlength( Ps, 0 );
end;


procedure TCanalGrafico2D.InvalidarRectangulo(h: hwnd; c1,c2: NComplex; scroll_x, scroll_y: integer  );
var
	r: TRect;
begin
	cx2xy(c1, r.left, r.top );
	cx2xy(c2, r.right, r.bottom );

	if r.left > r.Right then swapints( r.left, r.right );
	if r.top > r.bottom then swapints( r.top, r.bottom );

	r.left:= r.left-BordeSel-scroll_x - px_radioPunto;
	r.right:= r.right+BordeSel-scroll_x + px_radioPunto;
	r.top:= r.top-BordeSel-scroll_y - px_radioPunto;
	r.bottom:= r.bottom+BordeSel-scroll_y + px_radioPunto;
	InvalidateRect( h, @r , true );
end;


constructor TOG2D.Create( cx: NComplex );
begin
	inherited Create;
	ct:= cx;
	cr:= Complex_UNO;
	estado_x:= E_Normal;
	seleccionado:= false;

	GrosorPen:=1;

	EstiloPen:= psSolid;
	ColorPen:= clBlack;
	ColorBrush:= clWhite;
	EstiloBrush:= bsSolid;
	Marco.m1:= rc(cx, numc(1,1)^)^;
	Marco.m2:= sc(cx, numc(1,1)^)^;
end;

procedure TOG2D.ActualizarMarco;
begin
	Marco.m1:= rc(ct, numc(1,1)^)^;
	Marco.m2:= sc(ct, numc(1,1)^)^;
end;

function TOG2D.MarcoToca( var rcx: TRectComplex ): boolean;
var
	xband, yband: boolean;
begin
	xband:= enorden(marco.m1.r, rcx.m1.r, marco.m2.r) or enorden(marco.m1.r, rcx.m2.r, marco.m2.r);
	xband:= enorden(marco.m1.i, rcx.m1.i, marco.m2.i) or enorden(marco.m1.i, rcx.m2.i, marco.m2.i)
end;


procedure TOG2D.EnterEdit;
begin
  self.estado_x:= E_Editando;

end;


procedure TOG2D.ExitEdit;
begin
  self.estado_x:= E_Normal;

end;

procedure TOG2D.WriteToFile( var f: textFile );
begin
	writeln(f, ct.r,' ', ct.i );
	writeln(f, cr.r, ' ',cr.i );
	writeln(f, ord(Estado_x) );
(*
	 if seleccionado then
		 writeln( f, 1 )
	 else
		 writeln( f, 0 );
*)
	writeln( f, GrosorPen );
	writeln( f, ord(EstiloPen ) );
	writeln( f, ord(ColorPen ) );
	writeln( f, ord(ColorBrush));
	writeln( f, ord(EstiloBrush));
	writeln( f, marco.m1.r, ' ',  marco.m1.i );
	writeln( f, marco.m2.r, ' ',  marco.m2.i );

end;

constructor TOG2D.ReadFromFile( var f: textFile );
var
	 e: integer;
begin
	inherited Create;
	readln( f, ct.r, ct.i );
	readln( f, cr.r, cr.i );
	readln( f, e );
	estado_x:= TEstadoTOG2D(e);

(*
  readln( f, e );
	seleccionado:= e <>0;
*)
	seleccionado:= false;

	readln( f, GrosorPen );
	readln( f, e );
	EstiloPen:= TPenStyle( e );
	readln( f, e );
	ColorPen:= TColor( e );
	readln( f, e );
	ColorBrush:= TColor(e);
	readln( f, e );
	EstiloBrush:= TBrushStyle(e);
	readln( f, marco.m1.r,  marco.m1.i );
	readln( f, marco.m2.r,  marco.m2.i );

end;


procedure TOG2D.Show( cg: TCanalGrafico2D );
var
	a: NComplex;
	k: integer;
begin
	cg.canvas.Pen.Width:= GrosorPen;
	cg.canvas.Pen.Style:= EstiloPen;
	cg.canvas.Pen.Color:= ColorPen;
	cg.canvas.Brush.Style:= EstiloBrush;
	cg.canvas.Brush.Color:= ColorBrush;
(*
	if length( hijos ) > 0 then
		for k:= 0 to high( hijos ) do
			hijos[k].Show( cg );

	if not seleccionado then
	begin
		a:= rc( ct, cg.c0 )^; // cambio origen
		a:= pc( ct, cg.cr )^; // rotación.
		cg.CirculoPunto( a );
	end
	else
	begin
		a:= rc( ct, cg.c0 )^; // cambio origen
		a:= pc( ct, cg.cr )^; // rotación.
		cg.CuadradoPunto( a );
	end;
	*)

end;


function TOG2D.Tocado( cx: NComplex; ra: NReal ): boolean;
var
   d: NReal;
begin
	d:= mod1(rc( ct, cx )^);
	 result:= d < ra;
end;

// retorna el índice del vértice más cercano y la distancia al mismo
function TOG2D.VerticeMasCercano( cx: NComplex ; var distancia: NReal ): integer; 
begin
	distancia:= mod1(rc( ct, cx )^);
  result:= 0;
end;


procedure TOG2D.Free;
begin
	 inherited Free;
end;

procedure TOG2D.MoverA( cx: NComplex );
var
	dcx: NComplex;
begin
	dcx:= rc( cx, ct )^;
	desplazar( dcx );
end;

procedure TOG2D.desplazar( dcx: NComplex );
begin
	ct:= sc( ct, dcx )^;
	marco.m1:= sc( marco.m1, dcx )^;
	marco.m2:= sc( marco.m2, dcx )^;
end;


procedure TOG2D.MouseDown(Button: TMouseButton;
		Shift: TShiftState; cx: NComplex );
begin
end;



procedure TOG2D.MouseMove(Shift: TShiftState; cx: NComplex );
begin
end;


procedure TOG2D.MouseUp(Button: TMouseButton;
		Shift: TShiftState; cx: NComplex );
begin
end;

// métodos de Tog2d_Grupo


constructor TOG2D_Grupo.Create( xIntegrantes: TDAOfog2d );
begin
	inherited Create( Complex_NULO );
	integrantes:= xintegrantes;
	ActualizarMarco;
end;

procedure TOG2D_Grupo.Show( cg: TCanalGrafico2D );
var
	k: integer;
	a: NComplex;
begin

	if seleccionado then
	begin
		a:= marco.m1 ;
		cg.CuadradoPunto( a );
		a.r:= marco.m2.r;
		cg.CuadradoPunto( a );
		a.i:= marco.m2.i;
		cg.CuadradoPunto( a );
		a.r:= marco.m1.r;
		cg.CuadradoPunto( a );
	end;

	for k:= 0 to high( integrantes ) do
		integrantes[k].show(cg);
end;

function TOG2D_Grupo.Tocado( cx: NComplex; ra: NReal ): boolean;
var
	k: integer;
	res: boolean;
begin
	res:= false;
	for k:= 0 to high( integrantes ) do
		if integrantes[k].tocado( cx, ra ) then
		begin
			res:= true;
			break;
		end;
	result:= res;
end;

procedure TOG2D_Grupo.Free;
var
	k: integer;
begin
	for k:= 0 to high( integrantes ) do
		integrantes[k].Free;
	setlength( integrantes, 0 );
	inherited Free;
end;


procedure TOG2D_Grupo.desplazar( dcx: NComplex );
var
	k: integer;
begin
	inherited desplazar( dcx );
	for k:= 0 to high( integrantes ) do
		integrantes[k].desplazar( dcx );
end;

procedure TOG2D_Grupo.MouseDown(Button: TMouseButton;
		Shift: TShiftState; cx: NComplex );
var
	k: integer;
begin
	for k:= 0 to high( integrantes ) do
		integrantes[k].MouseDown( button, shift, cx );
end;

procedure TOG2D_Grupo.MouseMove(Shift: TShiftState; cx: NComplex );
var
	k: integer;
begin
	for k:= 0 to high( integrantes ) do
		integrantes[k].MouseMove( shift, cx );
end;

procedure TOG2D_Grupo.MouseUp(Button: TMouseButton;
		Shift: TShiftState; cx: NComplex );
var
	k: integer;
begin
	for k:= 0 to high( integrantes ) do
		integrantes[k].MouseUp( button, shift, cx );
end;

procedure TOG2D_Grupo.WriteToFile( var f: textFile );
var
	k: integer;
begin
	inherited WriteToFile( f );
	writeln( f, length( integrantes ) );
	for k:= 0 to high( integrantes ) do
		WriteOgToFile( f, integrantes[k] );
end;

constructor TOG2D_Grupo.ReadFromFile( var f: textFile );
var
	k, n: integer;

begin
	inherited ReadFromFile( f );
	readln( f, n );
	setlength( integrantes, n );
	for k:= 0 to high( integrantes ) do
		integrantes[k]:= ReadOgFromFile( f );
end;

procedure TOG2D_Grupo.ActualizarMarco;
var
	k: integer;
begin
	rcx_Vaciar(marco);
	for k:= 0 to high(integrantes) do
		rcx_unir( Marco, integrantes[k].Marco );
end;


procedure AlInicio;
begin
  ClasesRegistradas:= TList.Create;
  registrar_Clase( TOG2D_Grupo );
end;

end.
