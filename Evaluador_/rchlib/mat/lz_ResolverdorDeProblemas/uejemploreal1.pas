unit uejemploreal1;

interface

uses
 (*
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  *)
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls,
  xmatdefs,
  matreal,
  uresolvecuacs;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    rbx1: TRadioButton;
    rbx2: TRadioButton;
    rbx3: TRadioButton;
    ex1: TEdit;
    ex2: TEdit;
    ex3: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation


(*** EJEMPLO problema 1
ec1) x1^2+ x1^2 - x3 = 0
ec2) (x1-1)^2 + (x2-1)^2 - x3 = 0

Hay que elegir una de las tres variables como parámetro y darle
valor inicial a las otras dos.

Para que el sistema tenga solución, si x3 se elige como parámetro
tiene que ser x3 > sqrt(1). Si se cumple esa condición, el sistema
tiene dos soluciones. El algorítmo encontrará solamente una de las dos.


****)

function Problema1_f1(iec: integer; x: TVectR): NReal;
var
  res: NReal;
begin
  res := sqr(x.pv[1]) + sqr(x.pv[2]) - x.pv[3];
  Result := res;
end;

function Problema1_f2(iec: integer; x: TVectR): NReal;
var
  res: NReal;
begin
  res := sqr(x.pv[1] - 1) + sqr(x.pv[2] - 1) - x.pv[3];
  Result := res;
end;

function Problema1_g11(iec, kvar: integer; x: TVectR): NReal;
begin
  Result := 2 * x.pv[1];
end;

function Problema1_g12(iec, kvar: integer; x: TVectR): NReal;
begin
  Result := 2 * x.pv[2];
end;

function Problema1_g13(iec, kvar: integer; x: TVectR): NReal;
begin
  Result := -1;
end;

function Problema1_g21(iec, kvar: integer; x: TVectR): NReal;
begin
  Result := 2 * (x.pv[1] - 1);
end;

function Problema1_g22(iec, kvar: integer; x: TVectR): NReal;
begin
  Result := 2 * (x.pv[2] - 1);
end;

function Problema1_g23(iec, kvar: integer; x: TVectR): NReal;
begin
  Result := -1;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  p: TProblema;
  convergio: boolean;
  err: NReal;
  cntIters: integer;
  k: integer;

begin
  p := TProblema.Create(2, 3);
  p.InscribirEcuacion(Problema1_f1, 1);
  p.InscribirEcuacion(Problema1_f2, 2);
  p.InscribirDerivada(Problema1_g11, 1, 1);
  p.InscribirDerivada(Problema1_g12, 1, 2);
  p.InscribirDerivada(Problema1_g13, 1, 3);
  p.InscribirDerivada(Problema1_g21, 2, 1);
  p.InscribirDerivada(Problema1_g22, 2, 2);
  p.InscribirDerivada(Problema1_g23, 2, 3);

  p.DefinirVariable(1, StrToFloat(ex1.Text), rbx1.Checked);
  p.DefinirVariable(2, StrToFloat(ex2.Text), rbx2.Checked);
  p.DefinirVariable(3, StrToFloat(ex3.Text), rbx3.Checked);

  convergio := p.BuscarSolucion_NewtonRapson(1e-8, 1000, err, cntIters);

  if Convergio then
    writeln('Convergio!!!!')
  else
  begin
    writeln('NO CONVERGIO.');
    writeln('errMsg: ' + p.errMsg);
  end;
  writeln('cntIters: ', cntIters);
  writeln('err: ', FloatToStr(err));
  for k := 1 to p.xvalores.n do
    writeln('x[' + IntToStr(k) + ']: ' + FloatToStr(p.xvalores.pv[k]));

  ex1.Text := FloatToStrF(p.xvalores.pv[1], ffFixed, 8, 2);
  ex2.Text := FloatToStrF(p.xvalores.pv[2], ffFixed, 8, 2);
  ex3.Text := FloatToStrF(p.xvalores.pv[3], ffFixed, 8, 2);

end;

initialization
  {$I uejemploreal1.lrs}

end.
