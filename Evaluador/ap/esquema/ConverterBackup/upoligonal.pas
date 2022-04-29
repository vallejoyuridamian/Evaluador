unit upoligonal;

interface
uses
  windows,
  controls,
  classes,
  AlgebraC, xMatDefs, MatCpx,
  IntPoint,
  utog2d;

type
	TOG2D_Poligonal = class ( TOG2D )
		vertices: TVarArrayOfComplex;
		cerrada: boolean;

    verticeBajoEdicion: integer;
    verticeDestacado: integer;

		constructor Create( cx: NComplex );
		procedure Show( cg: TCanalGrafico2D ); override;
		function Tocado( cx: NComplex; ra: NReal ): boolean; override;
    function VerticeMasCercano( cx: NComplex ; var distancia: NReal ): integer; override;

		procedure Free; override;
		procedure AgregarPunto( cx: NComplex );
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


    // destaca el vétirice iNuevo. Y le saca el destaque
    // al anterior.
    procedure CambiarDestaqueVertice( iNuevo: integer );

    // retorna el vértice más cercano al punto


    // arrastra el vértice hasta la nueva posición
    // en modo Edit
    procedure MoverVertice( kVertice: integer; NuevaPos: NComplex );


	end;

procedure AlInicio;

implementation
uses
  uesquema;

(*****
	métodos de TPoligonal
*******)

constructor TOG2D_Poligonal.Create( cx: NComplex );
begin
	inherited Create(cx);
//	setlength( hijos , 0);
	setlength( vertices, 0 );
//   vertices[0]:= complex_NULO;
	cerrada:= false;
  self.verticeDestacado:= -1;
  self.verticeBajoEdicion:= -1;
  
end;

procedure TOG2D_Poligonal.Show( cg: TCanalGrafico2D );
var
	k: integer;
	a: NComplex;
begin
  inherited Show( cg );
	if length( vertices ) = 0 then exit;

(*
	cg.MoveTo( vertices[0] );
	for k:= 1 to length( vertices ) -1 do
		cg.LineTo( vertices[k] );
	if cerrada then
		cg.LineTo( vertices[0] );
    *)

	if cerrada then
    cg.Polygon( vertices )
  else
    cg.Polyline( vertices );


	if seleccionado then
		for k:= 0 to length( vertices ) -1 do
				cg.CuadradoPunto( vertices[k] );

  if verticeDestacado >= 0 then
    cg.CuadradoPuntoDestacado( vertices[verticeDestacado] );
end;



procedure TOG2D_Poligonal.ActualizarMarco;
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
	marco.m2:= vertices[0];

	for k:= 1 to length( vertices ) -1 do
		rcx_Expandir( marco, vertices[k] );

end;

procedure TOG2D_Poligonal.WriteToFile( var f: textFile );
var
	k: integer;
begin
	inherited WriteToFile( f );
	writeln(f, length( vertices ) );
	for k:= 0 to high( vertices ) do
		writeln(f, vertices[k].r,' ', vertices[k].i );
	if cerrada then
		writeln(f, 1 )
	else
		writeln(f, 0 );
end;

constructor TOG2D_Poligonal.ReadFromFile( var f: textFile );
var
   k: integer;
begin
   inherited ReadFromFile( f );
	 readln(f, k );
	 setlength( vertices, k );
	 for k:= 0 to high( vertices ) do
      readln( f, vertices[k].r, vertices[k].i );
	readln( f, k );
	cerrada:= k <> 0;
end;



function TOG2D_Poligonal.Tocado( cx: NComplex; ra: NReal ): boolean;
begin
   result:= IntPoint.InternalPoint( cx, vertices );
end;


// retorna el índice del vértice más cercano y la distancia al mismo
function TOG2D_Poligonal.VerticeMasCercano( cx: NComplex; var distancia: NReal ): integer;
var
  d2min, d2: NReal;
  kmin: integer;
  k: integer;

begin
  if length( vertices ) = 0 then
  begin
    result:= -1;
    distancia:= 1E12;
    exit;
  end;

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
  distancia:= sqrt( d2min );
  result:= kmin;
end;




procedure TOG2D_Poligonal.AgregarPunto( cx: NComplex );
var
	 v: TVarArrayOfComplex;
	 k: integer;
begin
	 if length(vertices) = 0 then
	begin
		setlength( v, 2 );
			v[0]:= cx;
			v[1]:= cx;
	 end
	else
	 begin
			setlength( v, length( vertices )+1);
			for k:= 0 to high( vertices ) do
				 v[k]:= vertices[k];
			v[high(v)]:= cx;
	end;
	 vertices:= v;
end;



procedure TOG2D_Poligonal.EnterEdit;
begin
  cambiarDestaqueVertice( -1 ); // no destacar ninguno
  VerticeBajoEdicion:= -1;
  estado_x:= E_Editando;
end;


procedure TOG2D_Poligonal.ExitEdit;
begin
  cambiarDestaqueVertice( -1 ); // no destacar ninguno
  VerticeBajoEdicion:= -1;
  estado_x:= E_Normal;
end;


procedure TOG2D_Poligonal.Free;
begin
	 setlength( vertices, 0 );
	 inherited Free;
end;


procedure TOG2D_Poligonal.desplazar( dcx: NComplex );
var
	i: integer;
begin
	inherited desplazar( dcx );
	for i:= 0 to high( vertices ) do
		vertices[i]:= sc( vertices[i], dcx )^;
end;

procedure TOG2D_Poligonal.MouseDown(Button: TMouseButton;
					 Shift: TShiftState; cx: NComplex );
var
  d: NReal;
begin
   case estado_x of
       E_Creando:
         case Button of
						mbLeft: Self.AgregarPunto(cx );
            mbRight: Self.Estado_x:= E_Normal;
         end;

       E_Editando:
         verticeBajoEdicion:= VerticeMasCercano( cx , d );
	else
		inherited;
   end;

end;



procedure TOG2D_Poligonal.CambiarDestaqueVertice( iNuevo: integer );
begin
  if self.verticeDestacado >= 0 then
  begin
    TEsquema(esquema).invalidarPunto(  vertices[ verticeDestacado] );
    if iNuevo >= 0  then   
      TEsquema(esquema).invalidarPunto(  vertices[ iNuevo ] );
    verticeDestacado:= iNuevo;
  end;
end;

procedure TOG2D_Poligonal.MoverVertice( kVertice: integer; NuevaPos: NComplex );
begin


end;



procedure TOG2D_Poligonal.MouseMove(Shift: TShiftState; cx: NComplex );
var
  iv : integer;
  d: NReal;
begin
	 case estado_x of
			 E_Creando:
         if length( vertices ) > 0 then
            Self.vertices[high(vertices)]:= cx;
       E_Editando:
        begin
          if verticeBajoEdicion < 0 then
          begin
            iv:= VerticeMasCercano( cx, d );
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

procedure TOG2D_Poligonal.MouseUp(Button: TMouseButton;
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
  registrar_Clase( TOG2D_Poligonal );
end;
end.
