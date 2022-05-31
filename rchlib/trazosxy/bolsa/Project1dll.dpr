library Project1dll;

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
  DllForm in 'DllForm.pas' {frmDllForm};



procedure ShowDllForm;stdcall;
begin
  frmDllForm :=TfrmDllForm.Create(nil);
  frmDllForm.CrearDiagramaXY(
						'diagrama1',
						200,
						true,
						0,1000, 0, 1000 );
  frmDllForm.Show;
end;

function ShowDllFormModal:integer;stdcall;
begin
  frmDllForm :=TfrmDllForm.Create(nil);
  frmDllForm.CrearDiagramaXY(
						'diagrama1',
						200,
						true,
						0,1000, 0, 1000 );
  Result := frmDllForm.ShowModal;
end;

procedure xlabel( str: pchar ); stdcall;
begin
	frmDllForm.xlabel( string (str ));
end;

procedure ylabel( str: pchar ); stdcall;
begin
	frmDllForm.ylabel( string( str ));
end;

procedure zlabel( str: pchar ); stdcall;
begin
	frmDllForm.zlabel( string( str ));
end;

procedure titulo( str: pchar ); stdcall;
begin
	frmDllForm.titulo( string( str ));
end;

procedure Etiquetas_x( x1, x2: double ); stdcall;
begin
	frmDllForm.Etiquetas_x( x1, x2);
end;

procedure Etiquetas_y( y1, y2: double ); stdcall;
begin
	frmDllForm.Etiquetas_y( y1, y2);
end;

procedure Etiquetas_z( z1, z2: double ); stdcall;
begin
	frmDllForm.Etiquetas_z( z1, z2);
end;


procedure PlotNuevo_x( x: double ); stdcall;
begin
	frmDllForm.tr1.PlotNuevo_x( x );
end;

procedure PlotNuevo_y( ks: integer; y: double ); stdcall;
begin
	frmDllForm.tr1.PlotNuevo_y( ks, y );
end;

procedure RePlot; stdcall;
begin
	frmDllForm.tr1.RePlot;
end;


procedure gridX; stdcall;
begin
	frmDllForm.dbj_gridX;
end;

procedure gridY; stdcall;
begin
	frmDllForm.dbj_gridY;
end;

procedure borde; stdcall;
begin
	frmDllForm.dbj_borde;
end;


//procedure dbj_linea0; stdcall;

procedure hola; stdcall;
begin
	writeln('hola');
//	alert('hola xlabel');
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
	hola;


end.
