unit utestunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses DllForm;

{$R *.DFM}

var
	trx: TfrmDLLForm;


procedure TForm1.Button2Click(Sender: TObject);
var
	k: integer;
begin
	trx:=TfrmDllForm.Create(form1);

	trx.CrearDiagramaXY(
		'diagrama1',
		200,
		true,
		'x', 'y', clRed,
		0,1000, 0, 1000 );

	trx.Show;
	
	trx.xlabel('hola');
	trx.titulo( 'Mi Gráfico');

	for k:= 1 to 1000 do
	begin
		trx.tr1.PlotNuevo_x( k );
		trx.tr1.PlotNuevo_y(1,  500 * ( 1+ cos( 2*pi*k /1000 )));
	end;

end;

end.
