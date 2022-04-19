unit utest_unit;

{$MODE Delphi}

interface

uses
{$IFDEF WINDOWS}
Windows, Messages,
{$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
	procedure Button1Click(Sender: TObject);
  private
	 { Private declarations }
  public
	 { Public declarations }
	 k: integer;
  end;

var
  Form1: TForm1;

implementation

uses utrazosxy;

{$R *.lfm}

var
	trx: TfrmDLLForm;



procedure TForm1.Button1Click(Sender: TObject);
var
	k, ks2: integer;
	hv: integer;
begin
	trx:=TfrmDllForm.Create(form1);

	trx.CrearDiagramaXY(
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

	trx.show;

	ks2:=  trx.CrearSerieXY(	'S2', 512, true, clBlue );


	trx.xlabel( 'hola');
	trx.dbj_gridx ;
	trx.dbj_gridy;
	trx.dbj_borde;
	trx.titulo( 'El PRIMER TITULO');
	trx.etiquetas_x( 0, 1000 );
	trx.etiquetas_y( 0, 1000 );
	trx.xlabel( 'ejex');
	trx.ylabel( 'ejey');

	for k:= 0 to 50 do
	begin
		trx.tr1.PlotNuevo_x(  k*10 );
		trx.tr1.PlotNuevo_y( 1, 100 * (1+cos( 2*pi*k/100 )));
		trx.tr1.PlotNuevo_y( ks2, 800 * (1+sin( 2*pi*k/100 )));
		application.ProcessMessages;
		sleep( 100 );
	end;

end;



end.
