library trazosxy;
{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  View-Project Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the DELPHIMM.DLL shared memory manager, which must be deployed along
	with your DLL. To avoid using DELPHIMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
	SysUtils,
	Classes,
	Graphics,
	utrazosxy in 'utrazosxy.pas' {frmDllForm};

var
  frmDllForm: array of TfrmDllForm;

procedure CerrarVentana( iventana: integer ); stdcall;
begin
	if frmDllForm[iventana] <> nil then
	begin
		frmDllForm[iventana].Close;
		frmdllForm[iventana]:= nil;
	end;
end;

function ShowDllForm: integer;stdcall;
var
	k: integer;
	buscando: boolean;
begin
	buscando:= true;
	k:= 0;
	while buscando and (k < high(frmdllForm) ) do
	begin
		if frmdllForm[k] = nil then
			buscando:= false
		else
			inc(k);
	end;

	if buscando then
	begin
		result:= -1;
		exit;
	end;

	frmDllForm[k] :=TfrmDllForm.Create(nil);
	frmDllForm[k].CrearDiagramaXY(
						'diagrama1',
						200,
						true,
						'x', 'y1',
						clBlack,
						0,1000, 0, 1000, 10, 8 );
	frmDllForm[k].nilOnClose:= frmDllForm[k];
	frmDllForm[k].Show;
	result:= k;
end;

function ShowDllFormModal:integer;stdcall;
var
	k: integer;
	buscando: boolean;
begin
	buscando:= true;
	k:= 0;
	while buscando and (k < high(frmdllForm) ) do
	begin
		if frmdllForm[k] = nil then
			buscando:= false
		else
			inc(k);
	end;

	if buscando then
	begin
		result:= -1;
		exit;
	end;

	frmDllForm[k]:=TfrmDllForm.Create(nil);
	frmDllForm[k].CrearDiagramaXY(
						'diagrama1',
						200,
						true,
						'x', 'y1',
						clBlack,
						0,1000, 0, 1000, 10, 8 );
	Result := frmDllForm[k].ShowModal;
	frmDllForm[k]:=nil;
end;

procedure xlabel(hv: integer; str: pchar ); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].xlabel( string (str ));
end;

procedure ylabel(hv: integer; str: pchar ); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].ylabel( string( str ));
end;

procedure zlabel(hv: integer; str: pchar ); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].zlabel( string( str ));
end;

procedure titulo(hv: integer; str: pchar ); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].titulo( string( str ));
end;

procedure Etiquetas_x(hv: integer; x1, x2: double ); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].Etiquetas_x( x1, x2);
end;

procedure Etiquetas_y(hv: integer; y1, y2: double ); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].Etiquetas_y( y1, y2);
end;

procedure Etiquetas_z(hv: integer; z1, z2: double ); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].Etiquetas_z( z1, z2);
end;


procedure PlotNuevo_x(hv: integer; x: double ); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].tr1.PlotNuevo_x( x );
end;

procedure PlotNuevo_y(hv: integer; ks: integer; y: double ); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].tr1.PlotNuevo_y( ks, y );
end;

procedure RePlot(hv: integer); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].tr1.RePlot;
end;


procedure gridX(hv: integer); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].dbj_gridX;
end;

procedure gridY(hv: integer); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].dbj_gridY;
end;

procedure borde(hv: integer); stdcall;
begin
	if 	frmDllForm[hv] <> nil then
	frmDllForm[hv].dbj_borde;
end;




function CrearDiagramaXY(
			nombre: string;
			MaxNPuntos: integer;
			Circular: boolean;
			nombre_sx, nombre_sy1: pchar;
			color_sy1: TColor;
			x1, x2, y1, y2: double;
			NDivX, NDivY: integer ): integer; stdcall;

var
	k: integer;
	buscando: boolean;
begin
	buscando:= true;
	k:= 0;
	while buscando and (k < high(frmdllForm) ) do
	begin
		if frmdllForm[k] = nil then
			buscando:= false
		else
			inc(k);
	end;

	if buscando then
	begin
		result:= -1;
		exit;
	end;


	frmDllForm[k]:=TfrmDllForm.Create(nil);
	frmDllForm[k].CrearDiagramaXY(
			string(nombre),
			MaxNPuntos,
			Circular,
			string(nombre_sx), string(nombre_sy1),
			color_sy1,
			x1, x2, y1, y2, NDivX, NDivY );
	frmDllForm[k].nilOnClose:= frmDllForm[k];
	frmDllForm[k].Show;
	result:= k;

end;


function CrearSerieXY(
			hv: integer;
			nombre: pchar;
			maxNPuntos: integer;
			MemoriaCircular: boolean;
			color: TColor ): integer; stdcall;
begin
	result:= frmDllForm[hv].CrearSerieXY(
			string(nombre), maxNPuntos,
			MemoriaCircular,	color );
end;


//procedure dbj_linea0; stdcall;


procedure AlInicio;
var
	k: integer;
begin
	setlength( frmDllForm, 100 );
	for k:= 0 to high( frmDllForm ) do
		frmDllForm[k]:= nil;
end;




exports
	ShowDllForm,
	ShowDllFormModal,
	xlabel,
	ylabel,
	zlabel,
	titulo,
	Etiquetas_x,
	Etiquetas_y,
	Etiquetas_z,
	PlotNuevo_x,
	PlotNuevo_y,
	RePlot,
	gridX,
	gridY,
	borde,
	CrearDiagramaXY,
	CrearSerieXY,
	CerrarVentana;
begin
	AlInicio;

end.
