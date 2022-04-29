unit urectangle;

interface
uses
  windows,
  controls,
  classes,
  AlgebraC, xMatDefs, MatCpx, IntPoint,
  utog2d;

type
	TOG2D_Rectangle = class ( TOG2D )
		vertices: TVarArrayOfComplex; // vértice superior izquierdo e inferior derecho

    verticeBajoEdicion: integer;
    verticeDestacado: integer;

		constructor Create( xA, xB: NComplex );
		procedure Show( cg: TCanalGrafico2D ); override;

		function Tocado( cx: NComplex; ra: NReal ): boolean; override;

		procedure Free; override;
		procedure desplazar( dcx: NComplex ); override;
		procedure MouseDown(Button: TMouseButton;
				Shift: TShiftState; cx: NComplex ); override;
		procedure MouseMove(Shift: TShiftState; cx: NComplex ); override;
		procedure MouseUp(Button: TMouseButton;
				Shift: TShiftState; cx: NComplex ); override;

    procedure EnterEdit; override;
    procedure ExitEdit; override;


		procedure WriteToFile( var f: textFile ); override;
		constructor ReadFromFile( var f: textFile ); override;
		procedure ActualizarMarco; override;

    procedure calc_vertices( xA, xB: NComplex );

    // destaca el vétirice iNuevo. Y le saca el destaque
    // al anterior.
    procedure CambiarDestaqueVertice( iNuevo: integer );

    // retorna el vértice más cercano al punto
    function VerticeMasCercano( cx: NComplex ): integer;

    // arrastra el vértice hasta la nueva posición
    // en modo Edit
    procedure MoverVertice( kVertice: integer; NuevaPos: NComplex );


	end;

procedure AlInicio;


implementation
uses
  uesquema;

(*****
	métodos de TRectangle
*******)


procedure TOG2D_Rectangle.calc_vertices( xA, xB: NComplex );
var
  cx: NComplex;
begin
  cx:= xA;
  vertices[0]:= cx;
  cx.r:= xB.r;
  vertices[1]:= cx;
  cx.i:= xB.i;
  vertices[2]:= cx;
  cx.r:= xA.r;
  vertices[3]:= cx;
  ActualizarMarco;  
end;

constructor TOG2D_Rectangle.Create( xA, xB: NComplex );
begin
	inherited Create(xA);
  setlength( vertices, 4 );
  calc_vertices( xA, xB );
  self.verticeDestacado:= -1;
  self.verticeBajoEdicion:= -1;
end;

procedure TOG2D_Rectangle.Show( cg: TCanalGrafico2D );
var
  k: integer;
begin
  inherited show( cg );
  cg.Polygon( vertices );


	if seleccionado then
		for k:= 0 to length( vertices ) -1 do
				cg.CuadradoPunto( vertices[k] );

  if verticeDestacado >= 0 then
    cg.CuadradoPuntoDestacado( vertices[verticeDestacado] );
end;



procedure TOG2D_Rectangle.ActualizarMarco;
var
	k: integer;
	a: NComplex;
begin

	if length( vertices ) = 0 then
	begin
		rcx_Vaciar(marco);
		exit;
	end;

	marco.m1:= vertices[0];
	marco.m2:= vertices[2];
 
	for k:= 1 to length( vertices ) -1 do
		rcx_Expandir( marco, vertices[k] );

end;

procedure TOG2D_Rectangle.WriteToFile( var f: textFile );
var
	k: integer;
begin
	inherited WriteToFile( f );
	writeln(f, length( vertices ) );
	for k:= 0 to high( vertices ) do
		writeln(f, vertices[k].r,' ', vertices[k].i );
end;

constructor TOG2D_Rectangle.ReadFromFile( var f: textFile );
var
   k: integer;
begin
   inherited ReadFromFile( f );
	 readln(f, k );
	 setlength( vertices, k );
	 for k:= 0 to high( vertices ) do
      readln( f, vertices[k].r, vertices[k].i );
end;



function TOG2D_Rectangle.Tocado( cx: NComplex; ra: NReal ): boolean;
begin
  result:= IntPoint.InternalPoint( cx, vertices );
end;




procedure TOG2D_Rectangle.EnterEdit;
begin
  cambiarDestaqueVertice( -1 ); // no destacar ninguno
  VerticeBajoEdicion:= -1;
  estado_x:= E_Editando;
end;


procedure TOG2D_Rectangle.ExitEdit;
begin
  cambiarDestaqueVertice( -1 ); // no destacar ninguno
  VerticeBajoEdicion:= -1;
  estado_x:= E_Normal;
end;


procedure TOG2D_Rectangle.Free;
begin
	 setlength( vertices, 0 );
	 inherited Free;
end;


procedure TOG2D_Rectangle.desplazar( dcx: NComplex );
var
	i: integer;
begin
	inherited desplazar( dcx );
	for i:= 0 to high( vertices ) do
		vertices[i]:= sc( vertices[i], dcx )^;
end;

procedure TOG2D_Rectangle.MouseDown(Button: TMouseButton;
					 Shift: TShiftState; cx: NComplex );
begin
   case estado_x of
       E_Creando:
         case Button of
						mbLeft:
              if verticeBajoEdicion <0 then
              begin
                calc_vertices( cx, cx );
                verticeBajoEdicion:= 2;
              end
              else if verticeBajoEdicion = 2 then                   
              begin
                calc_vertices( vertices[0], cx );
              end;
            mbRight: Self.Estado_x:= E_Normal;
         end;
       E_Editando:
         verticeBajoEdicion:= VerticeMasCercano( cx );
	else
		inherited;
   end;

end;


function TOG2D_Rectangle.VerticeMasCercano( cx: NComplex ): integer;
var
  d2min, d2: NReal;
  kmin: integer;
  k: integer;
begin
  d2min:= mod2( rc( cx, self.vertices[0] )^);
  kmin:= 0;
  for k:= 1 to high( vertices ) do
  begin
    d2:= mod2( rc( cx, self.vertices[k] )^);
    if d2 < d2min then
    begin
      d2min:= d2;
      kmin:= k;
    end;
  end;
  result:= k;
end;


procedure TOG2D_Rectangle.CambiarDestaqueVertice( iNuevo: integer );
begin
  if self.verticeDestacado >= 0 then
  begin
    TEsquema(esquema).invalidarPunto(  vertices[ verticeDestacado] );
    if iNuevo >= 0 then  
      TEsquema(esquema).invalidarPunto(  vertices[ iNuevo ] );
    verticeDestacado:= iNuevo;
  end;
end;



procedure TOG2D_Rectangle.MoverVertice( kVertice: integer; NuevaPos: NComplex );
var
  a, b: NComplex;
begin
  case kVertice of
    0: calc_vertices( NuevaPos, vertices[3]);
    1: begin
      a:= vertices[0];
      a.i:= NuevaPos.i;
      b:= vertices[3];
      b.r:= NuevaPos.r;
      calc_vertices( a, b );
    end;
    2: calc_vertices( vertices[0], NuevaPos );
    3: begin
      a:= vertices[0];
      b:= vertices[3];
      a.r:= NuevaPos.r;
      b.i:= NuevaPos.i;
      calc_vertices( a, b );
    end;
  end;


end;



procedure TOG2D_Rectangle.MouseMove(Shift: TShiftState; cx: NComplex );
var
  iv : integer;

begin
	 case estado_x of
			 E_Creando:
        if verticeBajoEdicion >= 0 then
          calc_vertices( vertices[0], cx );

       E_Editando:
        begin
          if verticeBajoEdicion < 0 then
          begin
            iv:= VerticeMasCercano( cx );
            cambiarDestaqueVertice( iv );
          end
          else
          begin
            moverVertice( verticeDestacado, cx );
          end;
        end
	else
		inherited;
	 end;
end;

procedure TOG2D_Rectangle.MouseUp(Button: TMouseButton;
            Shift: TShiftState; cx: NComplex );
begin
  case estado_x of
     E_Editando:
     begin
       verticeBajoEdicion:= -1;
     end;
  else
    inherited;
  end;
end;

procedure AlInicio;
begin
  registrar_Clase( TOG2D_Rectangle );
end;


end.
