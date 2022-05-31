unit Unit1;

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
	k: integer;
begin
	CrearDiagramaXY(
		'Diagrama1', // Nombres
		512, // MaxNPuntos
		true, // ciruclar
		'x', // nombre_sx
		'y', // nombre_sy1: pchar;
		clRed, //	color_sy1: TColor;
		0, 1000, //	x1, x2,
		0, 1000 //y1, y2
	);


	xlabel('hola');
	gridx;
	gridy;
	borde;
	for k:= 1 to 50 do
	begin
		PlotNuevo_x( k*10 );
		PlotNuevo_y( 1, 100 * (1+cos( 2*pi*k/100 )));
	end;
	titulo('El PRIMER TITULO');
end;

end.
