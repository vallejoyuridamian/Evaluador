unit utest_dll;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uimptraxpdll;

type
  TForm1 = class(TForm)
	 Button3: TButton;
	 procedure Button3Click(Sender: TObject);
  private
	 { Private declarations }
  public
	 { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}




procedure TForm1.Button3Click(Sender: TObject);
var
	k, ks2: integer;
	hv: integer;
begin
	hv:= CrearDiagramaXY(
		'Diagrama1', // Nombres
		512, // MaxNPuntos
		true, // ciruclar
		'x', // nombre_sx
		'y', // nombre_sy1: pchar;
		clRed, //	color_sy1: TColor;
		0, 1000, //	x1, x2,
		0, 1000, //y1, y2
								10,8    // NDivX, NDivY
	);


	ks2:=  CrearSerieXY(
			hv,
			'S2', 512, true, clBlue );


	xlabel(hv, 'hola');
	gridx(hv) ;
	gridy(hv);
	borde(hv);
	titulo(hv, 'El PRIMER TITULO');
	etiquetas_x(hv, 0, 1000 );
	etiquetas_y(hv, 0, 1000 );
	xlabel(hv, 'ejex');
	ylabel(hv, 'ejey');

	for k:= 0 to 50 do
	begin
		PlotNuevo_x(hv,  k*10 );
		PlotNuevo_y(hv, 1, 100 * (1+cos( 2*pi*k/100 )));
		PlotNuevo_y(hv, ks2, 800 * (1+sin( 2*pi*k/100 )));
		application.ProcessMessages;
	//	sleep( 100 );
	end;

end;

end.
