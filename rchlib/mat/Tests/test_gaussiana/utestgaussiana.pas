unit utestgaussiana;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, fddp, xMatDefs;

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
	fgn: Tf_ddp_GaussianaNormal;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
	r, rmax: NReal;
	n: integer;
begin
	n:= 0;
	rmax:= 0;
	fgn:= Tf_ddp_GaussianaNormal.Create_Init( 100 );
	while true do
	begin
		inc( n );
		r:= abs(fgn.rnd);
		if r  > rmax then
		begin
			rmax:= r;
			writeln( n:12, r );
		end;
	end;

end;

end.
