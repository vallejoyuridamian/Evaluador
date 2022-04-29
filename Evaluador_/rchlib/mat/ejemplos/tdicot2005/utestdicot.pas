unit utestdicot;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  xMatDefs, math01;

type
  TForm1 = class(TForm)
	 Button1: TButton;
	 procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

function fx( x: NReal ): Nreal;
begin
	result:= x-3;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
	x0, x1, xtol, root, fatroot: NReal;
	noofits: word;
	converged: boolean;

begin
	x0:= -100;
	x1:= 100;
	xtol:= 1e-16;



	Dicot(
	fx,							{funci¢n a anular}
	x0,x1,xtol,          {extremos y tolerancia}
	1000,					{n£mero m ximo de iteraciones}
	Root,fAtRoot,    {ra¡z y f(ra¡z)}
	NoOfIts,          {n£mero de iteraciones realizadas}
	converged);		{valid‚s del resultado}



end;

end.
