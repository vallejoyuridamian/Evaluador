unit pso;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, algoritmo_pso, matreal, xmatdefs, particulas;

const
  Num_particulas: integer = 100;
  Num_iteraciones: integer = 1000;
  fact_perturbacion: NReal = 0.001;
  dimensiones: integer = 2;
  valmaxX: NReal = 10;
  valminX: NReal = -10;
  valmaxV: NReal = 10;
  valminV: NReal = -10;
  uw: double = 0.729;
  uc1: double = 1.49445;
  uc2: double = 0.49445;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  i, j: integer;
  uminX, umaxX, uminV, umaxV: TDAofNReal;
  mejor, ur1, ur2: NReal;
  indice_mejor: integer;
  mejor_pos: TDAofNReal;
  cumulo: array of particula;
begin
  setlength(cumulo, Num_particulas + 1);
  setlength(uminX, 2);
  setlength(umaxX, 2);
  setlength(uminV, 2);
  setlength(umaxV, 2);
  setlength(mejor_pos, 2);

  uminX[0] := valminX;
  uminX[1] := valminX;
  umaxX[0] := valmaxX;
  umaxX[1] := valmaxX;
  uminV[0] := valminV;
  uminV[1] := valminV;
  umaxV[0] := valmaxV;
  umaxV[1] := valmaxV;
  mejor := 10000;
  for i := 1 to Num_particulas do
  begin
    cumulo[i] := particula.Create(uminX, umaxX, uminV, umaxV);
    //cumulo[i].mostrar(i,self.Memo1);
    cumulo[i].calcular_fitness();
    if cumulo[i].fitness < mejor then
    begin
      mejor := cumulo[i].fitness;
      indice_mejor := i;
      vcopy(mejor_pos, cumulo[i].posicion);
    end;
  end;
  Memo1.Append(#13);

  for j := 0 to Num_iteraciones do
  begin
    for i := 1 to Num_particulas do
    begin
      randomize;
      ur1 := fmu.rnd;
      ur2 := fmu.rnd;
      if j < Num_iteraciones * 3 / 4 then
        cumulo[i].perturbar(fact_perturbacion, uminX, umaxX);
      cumulo[i].calcular_velocidad(uw, uc1, uc2, ur1, ur2, uminV, umaxV, mejor_pos);
      cumulo[i].calcular_posicion(uminX, umaxX);
      cumulo[i].calcular_fitness();
      if cumulo[i].fitness < mejor then
      begin
        mejor := cumulo[i].fitness;
        indice_mejor := i;
        vcopy(mejor_pos, cumulo[i].posicion);
      end;

    end;
    //cumulo[indice_mejor].mostrar(i,self.Memo1);
    Edit1.Text := floattostr(mejor);
  end;

  memo1.Append(#13);
  memo1.Append(floattostr(mejor));
  cumulo[indice_mejor].mostrar(indice_mejor, memo1);
  memo1.Append('X: ' + floattostr(cumulo[indice_mejor].posicion[0]));
  memo1.Append('Y: ' + floattostr(cumulo[indice_mejor].posicion[1]));
  for i := 1 to Num_particulas do
  begin
    cumulo[i].Free;
  end;
  vclear(uminX);
  vclear(umaxX);
  vclear(uminV);
  vclear(umaxV);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  MEmo1.Clear;
end;

end.
