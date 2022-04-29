unit uTestSimplex;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, uExcelFile, xMatDefs, uSimplex;

type
	TForm1 = class(TForm)
		Button1: TButton;
		Button2: TButton;
    Button3: TButton;
    eFilaXs: TEdit;
    Label1: TLabel;
    lblCeldaSup: TLabel;
    eCeldaSupIzq: TEdit;
    Label2: TLabel;
    eCeldaInfDer: TEdit;
    OpenDialog1: TOpenDialog;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
		procedure Button1Click(Sender: TObject);
		procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }

		xf: TExcelFile;
		h: Variant;
	 	kfilx: integer; // fila de las x: en la planilla
		spx: TSimplex;

	end;

var
	Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);

begin
	xf:= TExcelFile.Create('x00', true);
	xf.AgregoHoja( 'x01');

	h:= xf.Hoja('x00');
	h.cells[1,1]:= 'jolgorio';
	h.cells[1,2]:= 1.2;
	h.cells[1,3]:= '=B1*2';

//	xf.VisibleOff;

//	xf.VisibleOn;
	xf.Guardar('golondrina.xls');
	xf.Free;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
	if OpenDialog1.Execute then
	begin
		xf:= TExcelFile.Create('', true);
		xf.Abrir( OpenDialog1.FileName );
	end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
	if assigned( xf ) then xf.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
	jcol: integer;
	buscando: boolean;
	r: string;
	cnt_Variables, cnt_Restricciones: integer;

	x_inf, x_sup: NReal;
	flg_x, flg_y: integer;

	k, j: integer;

	v: NReal;
begin
	buscando:= true;
	kfilx:= 1;
	jcol:= 1;
	h:= xf.Hoja(1);
	while buscando and (kfilx < 100) do
	begin
		r:=	h.cells[kfilx,1];
		if pos('x:', r ) = 1 then
			buscando:= false
		else
			inc( kfilx );
	end;

	if buscando then
		raise Exception.Create('No encontré la fila del asl x: ' );

	eFilaXs.Text:= IntToStr( kfilx );

	// contamos las variables
	buscando:= true;
	cnt_Variables:= 0;
	jcol:= 2;
	r:= h.cells[kfilx, jcol];
	while r <> '' do
	begin
		inc( cnt_Variables );
		inc( jcol );
		r:= h.cells[kfilx, jcol];
	end;

	// contamos las restricciones
	cnt_Restricciones:= 0;
	jcol:= 2;
	r:= h.cells[kfilx+4, jcol];
	while r <> '' do
	begin
		inc( cnt_Restricciones);
		inc( jcol );
		r:= h.cells[kfilx+4, jcol];
	end;


// creamos el simplex
 spx:= TSimplex.Create_init( cnt_Restricciones+1, cnt_Variables+1 );

 // ahora leemos las variables y sus cotas
 spx.cnt_varfijas:= 0;
 for j:= 1 to cnt_Variables do
 begin
	x_inf:=h.cells[kfilx+1, j + 1 ];
	x_sup:=h.cells[kfilx+2, j + 1 ];
	flg_x:=h.cells[kfilx+3, j + 1 ];
	spx.x_inf.pv[j]:= x_inf;
	spx.x_sup.pv[j]:= x_sup;
	spx.flg_x[j]:= flg_x;
	if abs( flg_x )= 2 then inc (spx.cnt_varfijas );
 end;

 // cargamos las flg_y
 spx.cnt_igualdades:= 0;
 for j:= 1 to cnt_Restricciones do
 begin
	flg_y:=h.cells[kfilx+4, j + 1 ];
	spx.flg_y[j]:= flg_y;
	if abs(flg_y) =2  then
		inc( spx.cnt_igualdades );
 end;

 // cargamos la magriz
 for k:= 1 to cnt_Restricciones+1 do
	for j:= 1 to cnt_Variables+1 do
	begin
		v:= h.cells[kfilx+8+k, j+1];
		spx.pon_e(k, j , v );
	end;



end;

procedure TForm1.Button5Click(Sender: TObject);
var
	k, j: integer;
	v: NReal;
begin
 // ahora leemos las variables y sus cotas

 for j:= 1 to spx.nc-1 do
 begin
	h.cells[kfilx+1, j + 1 ]:= spx.x_inf.pv[j];
	h.cells[kfilx+2, j + 1 ]:= spx.x_sup.pv[j]+spx.x_inf.pv[j];
	h.cells[kfilx+3, j + 1 ]:= spx.flg_x[j];
 end;

 // cargamos las flg_y
 for j:= 1 to spx.nf-1 do
 begin
	h.cells[kfilx+4, j + 1 ]:=spx.flg_y[j];
 end;

 // cargamos la magriz
 for k:= 1 to spx.nf do
	for j:= 1 to spx.nc do
	begin
		h.cells[kfilx+8+k, j+1]:= spx.e(k, j);
	end;



end;

procedure TForm1.Button6Click(Sender: TObject);
var
	res: integer;
begin
	res:=	spx.Resolver;
end;

end.
