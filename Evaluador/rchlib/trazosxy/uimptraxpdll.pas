unit uimptraxpdll;

interface
uses graphics;

const traxpdll_str='trazosxy.dll';

function ShowForm: integer;stdcall;external traxpdll_str name 'ShowDllForm';
function ShowFormModal:integer;stdcall;external traxpdll_str name 'ShowDllFormModal';
procedure xlabel(hv: integer; str: pchar ); stdcall;external traxpdll_str;
procedure ylabel(hv: integer; str: pchar ); stdcall;external  traxpdll_str;
procedure zlabel(hv: integer; str: pchar ); stdcall;external traxpdll_str;
procedure titulo(hv: integer; str: pchar ); stdcall;external traxpdll_str;
procedure Etiquetas_x(hv: integer; x1, x2: double ); stdcall;external traxpdll_str;
procedure Etiquetas_y(hv: integer; y1, y2: double ); stdcall;external traxpdll_str;
procedure Etiquetas_z(hv: integer; z1, z2: double ); stdcall;external traxpdll_str;
procedure PlotNuevo_x(hv: integer; x: double ); stdcall;external traxpdll_str;
procedure PlotNuevo_y(hv: integer; ks: integer; y: double ); stdcall;external traxpdll_str;
procedure RePlot; stdcall;external traxpdll_str;
procedure gridX(hv: integer); stdcall;external traxpdll_str;
procedure gridY(hv: integer); stdcall;external traxpdll_str;
procedure borde(hv: integer); stdcall;external traxpdll_str;

(* Crea el diagrama y crea la serie (x) y la primer serie (y)
ambas con MaxNPuntos *)
function CrearDiagramaXY(
			nombre: string;
			MaxNPuntos: integer;
			Circular: boolean;
			nombre_sx, nombre_sy1: pchar;
			color_sy1: TColor;
			x1, x2, y1, y2: double;
			NDivX, NDivY: integer ): integer;stdcall;external traxpdll_str;

function CrearSerieXY(
			hv: integer;
			nombre: pchar;
			maxNPuntos: integer;
			MemoriaCircular: boolean;
			color: TColor ): integer; stdcall;external traxpdll_str;

procedure CerrarVentana(hv: integer); stdcall;external traxpdll_str;

implementation

end.
