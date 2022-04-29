unit uesquema;

interface
uses
  windows,
  controls,
  classes,
  AlgebraC,
  xMatDefs,
  MatCpx,
  utog2d;

type

	TEsquema = class
		ogs, sel_ogs: TList;
		nombre: string;
    editando: TEstadoTOG2D;
		marco: TRectComplex;
    og_bajoEdicion: TOG2D;

		RadioDeAtraccion: NReal;
		r_invalido: TRectComplex;
		base_cx: NComplex; // base para cálculo de desplazamientos del mouse
		arrastrando_seleccion: boolean;

		procedure Show(cg: TCanalGrafico2D );
		constructor Create( nombre: string );
		procedure Free;
		procedure AddOG( og: TOG2D );
		procedure QuitarOg( og: TOG2D );

		procedure MouseDown(Button: TMouseButton;
				Shift: TShiftState; cx: NComplex );
		procedure MouseMove(Shift: TShiftState; cx: NComplex );
		procedure MouseUp(Button: TMouseButton;
				Shift: TShiftState; cx: NComplex );

		procedure WriteToFile( var f: textFile );
		constructor ReadFromFile( var f: textFile );
		procedure ActualizarMarco;

// busca el objeto tocado en la lsita de objetos ogs
	function og_tocado( cx: NComplex; ra: NReal ): TOG2D;


	procedure Seleccion_agregar( og: TOG2D );
	procedure Seleccion_quitar( og: TOG2D );
	procedure Seleccion_limpiar;
	procedure Seleccion_mover( cx: NComplex );
	procedure Seleccion_desplazar( dcx: NComplex );

  procedure Seleccion_Eliminar;

	procedure Seleccion_Agrupar;
	procedure Seleccion_Desagrupar;

  procedure Seleccion_HaciaAdelante;
  procedure Seleccion_HaciaAtras;



  // une el rectangulo a la region inválida.
  procedure invalidar( r: TRectComplex );

  // invalida el cuadrado de destaque con contiene al punto.
  procedure invalidarPunto( cx: NComplex );
end;







implementation


(**********************
	 métodos de TEsquema
**************************)

constructor TEsquema.Create( nombre: string );
begin
	Self.nombre:= nombre;
	ogs:= TList.Create;
	sel_ogs:= TList.Create;
	base_cx:= Complex_NULO;
	arrastrando_seleccion:=false;
	RadioDeAtraccion:= 3;
end;


procedure TEsquema.Show(cg: TCanalGrafico2D );
var
	og: TOG2D;
	k: integer;
	p: pointer;
begin
	for k:= 0 to ogs.Count-1 do
	begin
		p:= ogs.Items[k];
		og:= TOG2D(p);
		og.Show(cg);
	end;
end;


procedure TEsquema.WriteToFile( var f: textFile );
var
	k: integer;
	og: TOg2D;

begin
	writeln( f, nombre );
	writeln( f, RadioDeAtraccion );
	writeln( f, ogs.Count );
	for k:= 0 to ogs.Count-1 do
	begin
		og:= TOG2D(ogs.Items[k]);
		writeOgToFile( f, og );
	end;
end;



constructor TEsquema.ReadFromFile( var f: textFile );
var
	r: string;
	 nogs: integer;
	 og: TOg2D;
	 k: integer;
begin
	readln( f, nombre );
	readln( f, RadioDeAtraccion );
	readln( f, nogs );
	ogs:= TList.Create;
	sel_ogs:= TList.Create;

	for k:= 1 to nogs do
	begin
		og:= ReadOgFromFile( f );
		og.ActualizarMarco;
		ogs.Add( og );
	end;
	ActualizarMarco;
end;

procedure TEsquema.ActualizarMarco;
var
	k: integer;
begin
	rcx_Vaciar( marco);
	for k:= 0 to ogs.Count-1 do
	begin
		rcx_unir( Marco, TOG2D(ogs.Items[k]).Marco );
	end;
end;


procedure TEsquema.Free;
begin
	ogs.Free;
	sel_ogs.Free;
	 inherited Free;
end;


procedure TEsquema.invalidar( r: TRectComplex );
begin
  rcx_unir( r_invalido, r );
end;

procedure TEsquema.invalidarPunto( cx: NComplex );
begin
  rcx_Expandir( r_invalido, cx );
end;


procedure TEsquema.AddOG( og: TOG2D );
begin
//  ogs.Insert(0, og);
	ogs.Add( og );
	og.ActualizarMarco;
	rcx_unir(r_invalido, og.Marco );
end;

procedure TEsquema.QuitarOg( og: TOG2D );
begin
	ogs.remove( og );
	og.ActualizarMarco;
	rcx_unir(r_invalido, og.Marco );
end;


// busca el objeto tocado en la lsita de objetos ogs
function TEsquema.og_tocado( cx: NComplex; ra: NReal ): TOG2D;
var
	k: integer;
	og: TOG2D;
begin
	result:= nil;
  // los recorro al revés para que seleccione primero el de más de arriba
	for k:= ogs.Count-1 downto 0 do
	begin
		og:= ogs.items[k];
		if og.Tocado(cx, RadioDeAtraccion ) then
		begin
			result:= og;
			break;
		end;
	end;
end;


procedure TEsquema.Seleccion_Eliminar;
var
  k: integer;
  og: TOG2D;
begin
  for k:= 0  to Self.sel_ogs.Count - 1 do
  begin
    og:= sel_ogs.Items[k];
    rcx_Unir( r_invalido, og.marco );
    ogs.Extract( og );
    og.Free;
  end;
  sel_ogs.Clear;
end;

procedure TEsquema.Seleccion_agregar( og: TOG2D );
begin
	if not og.seleccionado then
	begin
		og.seleccionado:= true;
		sel_ogs.Add( og );
		rcx_Unir( r_invalido, og.Marco );
	end;
end;

procedure TEsquema.Seleccion_quitar( og: TOG2D );
var
	i: integer;
begin
	if og.seleccionado then
	begin
		rcx_Unir( r_invalido, og.Marco );
		i:= self.sel_ogs.IndexOf( og );
		if i >= 0 then
			self.sel_ogs.Delete(i);
		og.seleccionado:= false;
	end;
end;

procedure TEsquema.Seleccion_limpiar;
var
	i: integer;
begin
	for i:= 0 to sel_ogs.Count-1 do
	begin
		rcx_Unir( r_invalido, TOG2D(sel_ogs.items[i]).Marco );
		TOG2D(sel_ogs.items[i]).seleccionado:= false;
	end;
	sel_ogs.Clear;
end;

procedure TEsquema.Seleccion_mover( cx: NComplex );
var
	i: integer;
begin
	for i:= 0 to sel_ogs.Count-1 do
	begin
		rcx_Unir( r_invalido, TOG2D(sel_ogs.items[i]).Marco );
		TOG2d( sel_ogs.items[i]).moverA( cx ) ;
		rcx_Unir( r_invalido, TOG2D(sel_ogs.items[i]).Marco );
	end;
end;

procedure TEsquema.Seleccion_HaciaAtras;
var
	i: integer;
  tmp: TOG2D;
begin
  if sel_ogs.count <= 0 then exit;

  for i:= 1 to ogs.Count-1 do
  begin
    if ( TOG2D( ogs.items[i] ).seleccionado
          and not  TOG2D( ogs.items[i-1] ).seleccionado  ) then
    begin
      tmp:= ogs.items[i-1];
      ogs.items[i-1]:= ogs.items[i];
      ogs.items[i]:= tmp;
      rcx_Unir( r_invalido, TOG2D( ogs.items[i-1] ).Marco );
      rcx_Unir( r_invalido, TOG2D( ogs.items[i]).Marco );
    end;
  end;
end;

procedure TEsquema.Seleccion_HaciaAdelante;
var
	i: integer;
  tmp: TOG2D;
begin
  if sel_ogs.count <= 0 then exit;
	for i:= ogs.Count-2 downto 0 do
	begin
    if ( TOG2D( ogs.items[i] ).seleccionado
          and not  TOG2D( ogs.items[i+1] ).seleccionado  ) then
    begin
      tmp:= ogs.items[i+1];
      ogs.items[i+1]:= ogs.items[i];
      ogs.items[i]:= tmp;
      rcx_Unir( r_invalido, TOG2D( ogs.items[i+1] ).Marco );
      rcx_Unir( r_invalido, TOG2D( ogs.items[i]).Marco );
    end;
	end;
end;


procedure TEsquema.Seleccion_Agrupar;
var
	integrantes: TDAOfog2d;
	og: Tog2d;
	i: integer;
begin
	if sel_ogs.Count > 0 then
	begin
		setlength( integrantes, sel_ogs.Count );
		for i:= 0 to sel_ogs.Count -1 do
		begin
			og:=TOG2D(sel_ogs.items[i]);
			integrantes[i]:= og;
			QuitarOg( og );
		end;
		Self.Seleccion_limpiar;
		og:= TOG2D_Grupo.Create( integrantes );
		Self.AddOG( og );
		Self.Seleccion_agregar( og );
		rcx_Unir( r_invalido, og.Marco );
	end;
end;

procedure TEsquema.Seleccion_Desagrupar;
var
	ogg: TOg2D_Grupo;
	og: Tog2d;
	k: integer;
begin
	if sel_ogs.Count = 1 then
	begin
		ogg:= sel_ogs.items[0];
		if ogg.ClassType = TOg2D_Grupo then
		begin
			seleccion_limpiar;
			self.QuitarOg( ogg );
			for k:= 0 to high( ogg.integrantes ) do
			begin
				og:= ogg.integrantes[k];
				Self.AddOG( og );
				Self.Seleccion_agregar( og );
			end;
			setlength( ogg.Integrantes, 0 );
			ogg.Free;
		end;
	end;
end;

procedure TEsquema.Seleccion_desplazar( dcx: NComplex );
var
	i: integer;
begin
	for i:= 0 to sel_ogs.Count-1 do
	begin
		rcx_Unir( r_invalido, TOG2D(sel_ogs.items[i]).Marco );
		TOG2d( sel_ogs.items[i]).desplazar( dcx ) ;
		rcx_Unir( r_invalido, TOG2D(sel_ogs.items[i]).Marco );
	end;
end;


procedure TEsquema.MouseDown(Button: TMouseButton;
				Shift: TShiftState; cx: NComplex );
var
	k, i : integer;
	og: TOG2D;
begin
	rcx_Vaciar( r_invalido );
	og:= og_tocado( cx, RadioDeAtraccion );
	base_cx:= cx; // inicializamos la base de cálculo de desplazamientos
	arrastrando_seleccion:= false;

	if ( shift= [ ssLeft] ) then
			seleccion_limpiar;

	if og <> nil then
	begin
				(* el comportamiento tiene que ser:
						Ctrl+Left = invertir selección del objeto
						Shit+Left = agrega el objeto a la selección si es que ya no estaba
								 Left = Borra todo lo seleccionado y selecciona sólo este objeto
					*)

				if ( Shift= [ssShift, ssLeft] ) then
				begin
					Seleccion_agregar( og );
				end;

				if ( shift= [ssCtrl, ssLeft] ) then
				begin
						if og.seleccionado then
							seleccion_quitar( og )
						else
							seleccion_agregar( og);
				end;

				if ( shift= [ ssLeft] ) then
				begin
					seleccion_agregar( og );
				end;
	end;
end;


procedure TEsquema.MouseMove(Shift: TShiftState; cx: NComplex );
var
	 k: integer;
	 og: TOG2D;
	 dcx: NComplex;
begin
	rcx_Vaciar( r_invalido );


	og:= og_tocado( cx, RadioDeAtraccion );

	dcx:= rc( cx, base_cx )^;
	base_cx:= cx; // actualizamos la base

	if og <> nil then
	begin
	// si el objeto tocado está seleccionado y el botón izquierdo está
	//	apretado muevo la seleccion
		if og.seleccionado and ( Shift= [ssLeft] ) then
			arrastrando_seleccion:= true; // comienza arrastre
	end;


	if ( Shift= [ssLeft] ) and arrastrando_seleccion then
			Seleccion_desplazar( dcx );


end;

procedure TEsquema.MouseUp(Button: TMouseButton;
						Shift: TShiftState; cx: NComplex );
var
	 k: integer;
	 og: TOG2D;
begin
	arrastrando_seleccion:= false;

	 for k:= 0 to ogs.Count-1 do
	 begin
			og:= ogs.items[k];
			if og.Tocado(cx, RadioDeAtraccion ) then
				 og.MouseUp(button, shift, cx );
	 end;
end;


  
end.
