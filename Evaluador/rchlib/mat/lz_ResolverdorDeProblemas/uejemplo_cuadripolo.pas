unit uejemplo_cuadripolo;
{$MODE Delphi}

(****************

Un cuadripolo queda definido por cuatro parámetros complejos
A, B, C y D conocidos como constantes del cuadripolo.

estos parámetros relacionan la tensión y corriente a la
entrada con la tensión y corriente de salida de la siguiente
forma:

   I1    +-----------+   I2
-------->|           |------->
    U1   |  A,B,C,D  |  U2
---------|           |---------
         +-----------+
P1+jQ1=U1*cc(I1)        P2+jQ2=U2+cc(I2)

Ecuaciones del cuadripolo:
U1 = A U2 + B I2
I1 = C U2 + D I2

Si es pasivo, se cumple AD-BC=1
Si D=A, decimos que el cuadripolo es simétrico

Despejando de las ecuaciones del cuadripolo podemos escribir la
ecuación que permite calcular las corrientes entrante a un sistema
en función de la tensión en sus nodos:

I1 = D/B U1 + ( C-D*A/B ) U2
(-I2) = -1/B U1 + A/B U2

La matriz de admitancias es entonces:
    | D/B       (C-D*A/B) |
Y = |                     |
    | -1/B         A/B    |


U1 * cc(I1 ) = S1 = P1+jQ1
U2 * cc( -I2 ) = S2 = -( P2+jQ2)

Consideramos I1, P1 y Q1 entrantes al cuadripolo
e I2, P2, Q2 salientes del cualdripolo
S1 y S2 los consideramos entrantes por eso S2 = -(P2+jQ2)

Las variables que consideramos para la solucion del problema son
U1, U2, S1, S2

U1 y U2 con representación POLAR
S1 y S2 con representación RECTANGULAR

ECUACIONES COMPLEJAS

IiConj[i] = cc( sum( yik, Vk ); k=1..NNodos )

fi[i]= V[iNodo]* IiConj[i] - S[iNodo] = 0

DERIVADAS

d(fi[i])/d(ro_kvar) = (i= kvar).( exp(j alfa_kvar) * IiConj[i] )
                     + V[i]* d(IiConj[i])/d(ro_kvar)

d(fi[i])/d(alfa_kvar)= (i=kvar).(j ro_kvar * IiConj[i] )
                     + V[i]* d(IiConj[i])/d(alfa_kvar)

d(fi[i])/d(P_kvar) = -1
d(fi[i])/d(Q_kvar) = -j


----
d(IiConj[i])/d(ro_kvar) = cc( y[i,k_var] * exp( j alfa_kvar ) )
d(IiConj[i])/d(alfa_kvar) = cc( y[i,k_var] * ( j ro_kvar ) )

-----


El ejemplo por defecto es
   --------( 2 ohm )---+---
                       |
                       *
 220V                  * 20 ohm
                       *
                       |
                       |

 i  = U2/20
 U1= U2 + (I2+U2/20)*2 = 22/20 U1 + 2 I2
 I1= (1/20) U2 + I2

 A= 22/20
 B= 2
 C= 1/20
 D= 1

 AD -BC = 22/20 - 2/20 =1 (verificación)


***************)
interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, {OleCtnrs,} StdCtrls, xmatdefs, Algebrac, Matcpx, ExtCtrls,
  ucpxresolvecuacs;

type

  { TForm2 }

  TForm2 = class(TForm)
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    cb_simetrico: TCheckBox;
    e_A: TEdit;
    e_Alfa: TEdit;
    e_B: TEdit;
    e_beta: TEdit;
    e_C: TEdit;
    e_gamma: TEdit;
    GroupBox2: TGroupBox;
    Label9: TLabel;
    e_U1: TEdit;
    cb_U1: TCheckBox;
    GroupBox3: TGroupBox;
    Label12: TLabel;
    e_U2: TEdit;
    cb_U2: TCheckBox;
    GroupBox4: TGroupBox;
    e_theta: TEdit;
    Label19: TLabel;
    cb_theta: TCheckBox;
    Memo1: TMemo;
    Panel_Ayuda: TPanel;
    panel_D: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    e_D: TEdit;
    e_delta: TEdit;
    Button2: TButton;
    Panel1: TPanel;
    Label14: TLabel;
    Label17: TLabel;
    e_FI1: TEdit;
    cb_FI1: TCheckBox;
    e_roS1: TEdit;
    cb_roS1: TCheckBox;
    rb_S1_roFi: TRadioButton;
    Panel2: TPanel;
    Label10: TLabel;
    Label11: TLabel;
    rb_S1_PQ: TRadioButton;
    e_P1: TEdit;
    e_Q1: TEdit;
    cb_P1: TCheckBox;
    cb_Q1: TCheckBox;
    Panel3: TPanel;
    e_P2: TEdit;
    Label13: TLabel;
    cb_P2: TCheckBox;
    e_Q2: TEdit;
    Label15: TLabel;
    cb_Q2: TCheckBox;
    rb_S2_PQ: TRadioButton;
    Panel4: TPanel;
    cb_FI2: TCheckBox;
    Label16: TLabel;
    e_FI2: TEdit;
    rb_S2_roFi: TRadioButton;
    e_roS2: TEdit;
    Label18: TLabel;
    cb_roS2: TCheckBox;
    ToggleBox1: TToggleBox;
    procedure cb_simetricoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure rb_S1_PQClick(Sender: TObject);
    procedure rb_S1_roFiClick(Sender: TObject);
    procedure rb_S2_PQClick(Sender: TObject);
    procedure rb_S2_roFiClick(Sender: TObject);
    procedure e_P1Change(Sender: TObject);
    procedure e_roS1Change(Sender: TObject);
    procedure e_P2Change(Sender: TObject);
    procedure e_roS2Change(Sender: TObject);
    procedure e_AClick(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);
  private
    { Private declarations }
    flg_Inicializando: boolean;

  public

    { Public declarations }
    procedure Actualizar_S1;
    procedure Actualizar_PQ1;
    procedure Actualizar_S2;
    procedure Actualizar_PQ2;
    procedure Actualizar_C;
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}
var
  A, B, C, D: NComplex; // constantes del cuadripolo
  Y: TMatComplex; // matriz de admitancia
  nNodos: integer;
  IiConj: TVectComplex; // Corrientes entrantes conjugadas del último cálculo

function fi(inodo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  knodo: integer;
begin
  res := complex_NULO;
  for knodo := 1 to nNodos do
    res := sc(res, pc(y.fila[inodo].v[knodo], z.v[knodo])^)^;
{$IFDEF DBG_fi}
  writeln('I' + IntToStr(inodo) + ': ' + FloatToStrF(
    mod1(res), ffFixed, 8, 2) + '(' + FloatToStrF(fase(res) / pi * 180, ffFixed, 6, 1));
{$ENDIF}
  res := cc(res)^;
  IiConj.v[inodo] := res; // guardamos el valor de la intencidad entrante conjungada

  // ahora multiplicamos por la tensión del nodo y
  // le restamos la potencia aparente S(inodo)
  res := sc(pc(z.v[inodo], res)^, prc(-1, z.v[nNodos + inodo])^)^;
{$IFDEF DBG_fi}
  writeln('fi' + IntToStr(inodo) + ': ' + FloatToStrF(
    res.r, ffFixed, 8, 2) + '+j' + FloatToStrF(res.i, ffFixed, 8, 2));
  readln;
{$ENDIF}
  Result := res;
end;


function dfidro_V(inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  alfa_kvar: NReal;
  caux: NComplex;
begin
  res := Complex_NULO;
  alfa_kvar := fase(z.v[kvar]);
  caux := numc(cos(alfa_kvar), sin(alfa_kvar))^;
  if kvar = inodo then
    res := pc(caux, IiConj.v[inodo])^;
  res := sc(res, pc(z.v[inodo], cc(pc(y.fila[inodo].v[kvar], caux)^)^)^)^;
  Result := res;
end;

function dfidalfa_V(inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  ro_kvar: NReal;
  caux: NComplex;
begin
  res := Complex_NULO;
  ro_kvar := mod1(z.v[kvar]);
  caux := numc(0, ro_kvar)^;
  if kvar = inodo then
    res := pc(caux, IiConj.v[inodo])^;
  res := sc(res, pc(z.v[inodo], cc(pc(y.fila[inodo].v[kvar], caux)^)^)^)^;
  Result := res;
end;

function dfidP(inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  inodo_S: integer;
begin
  res := Complex_NULO;
  inodo_S := kvar - nNodos; // nodo al que pertenece la potencia Aparente
  if inodo_S = inodo then
    res := numc(-1, 0)^;
  Result := res;
end;

function dfidQ(inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  inodo_S: integer;
begin
  res := Complex_NULO;
  inodo_S := kvar - nNodos; // nodo al que pertenece la potencia Aparente
  if inodo_S = inodo then
    res := numc(0, -1)^;
  Result := res;
end;

function dfidro_S(inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  inodo_S: integer;
  a: NReal;
begin
  res := Complex_NULO;
  inodo_S := kvar - nNodos; // nodo al que pertenece la potencia Aparente
  if inodo_S = inodo then
  begin
    a := mod1(z.v[kvar]);
    if abs(a) > AsumaCero then
      res := prc(-1 / a, z.v[kvar])^
    else
      res := complex_UNO;
  end;
  Result := res;
end;


function dfidalfa_S(inodo, kvar, hcampo: integer; z: TVectComplex): NComplex;
var
  res: NComplex;
  inodo_S: integer;
  a: NReal;
begin
  res := Complex_NULO;
  inodo_S := kvar - nNodos; // nodo al que pertenece la potencia Aparente
  if inodo_S = inodo then
  begin
    a := mod1(z.v[kvar]);
    res := numc(0, -a)^;
  end;
  Result := res;
end;

(*
function gikh( inodo, kvar, hcampo: integer; z: TVectComplex ): NComplex;
var
  res: NComplex;
  alfa_kvar, ro_kvar: NReal;
  caux: NComplex;
  inodo_S: integer;
begin
  res:= Complex_NULO;
  if kvar <= nNodos then
  begin   // es derivada respecto al ro_kvar o al alfa_kvar
    if hcampo= 1 then
    begin  // es respecto a ro_kvar
      alfa_kvar:= fase( z.v[ kvar ] );
      caux:= numc( cos(alfa_kvar), sin( alfa_kvar ) )^;
      if kvar= inodo then
        res:=  pc( caux, IiConj.v[inodo] )^;
      res:= sc( res, pc( z.v[inodo], cc(pc( y.fila[inodo].v[kvar], caux)^)^)^)^ ;
    end
    else
    begin // es erspecto de alfa_kvar
      ro_kvar:= mod1( z.v[ kvar ] );
      caux:= numc( 0, ro_kvar )^;
      if kvar= inodo then
        res:=  pc( caux, IiConj.v[inodo] )^;
      res:= sc( res, pc( z.v[inodo], cc(pc( y.fila[inodo].v[kvar], caux)^)^)^)^ ;
    end;
  end
  else
  begin // es derivada respecto de P_kvar o Q_kvar
    inodo_S:= kvar - nNodos; // nodo al que pertenece la potencia Aparente
    if  inodo_S= inodo then
    begin
      if hcampo= 1 then
        res:= numc( -1, 0 )^
      else
        res:= numc( 0, -1 )^;
    end;
  end;
  result:= res;
end;
*)


procedure TForm2.Button2Click(Sender: TObject);
var
  p: TPRoblemaCPX;

  iEcuacion, kVar, hCampo: integer;
  resOk: boolean;
  err: NReal;
  cntiters: integer;

begin

  self.Cursor := crHourGlass;

  A := numc_rofi(StrToFloat(e_A.Text), StrToFloat(e_Alfa.Text) / 180.0 * pi)^;
  B := numc_rofi(StrToFloat(e_B.Text), strToFloat(e_Beta.Text) / 180.0 * pi)^;
  if self.cb_simetrico.Checked then
    D := A
  else
    D := numc_rofi(StrToFloat(e_D.Text), strToFloat(e_delta.Text) / 180.0 * pi)^;
  C := dc(rc(pc(A, D)^, complex_UNO)^, B)^;


  Y := TMatComplex.Create_Init(2, 2);
  IiConj := TVectComplex.Create_Init(2);
  nNodos := 2;
(*
    | D/B       (C-D*A/B) |
Y = |                     |
    | -1/B         A/B    |
  *)

  y.pon_e(1, 1, dc(D, B)^);
  y.pon_e(1, 2, rc(C, pc(D, dc(A, B)^)^)^);
  y.pon_e(2, 1, prc(-1, invc(B)^)^);
  y.pon_e(2, 2, dc(A, B)^);

  p := TProblemaCPX.Create(2, 4);

  for iEcuacion := 1 to 2 do
    p.InscribirEcuacion(fi, iEcuacion);
  (*
  for iEcuacion:= 1 to 2 do
    for kVar:= 1 to 4 do
      for hCampo:= 1 to 2 do
        p.InscribirDerivada( gikh, iEcuacion, kVar, hCampo);
    *)

  p.DefinirVariable(1, CPX_POLAR, StrToFloat(e_U1.Text), cb_U1.Checked, 0, True);
  p.DefinirVariable(2, CPX_POLAR,
    StrToFloat(e_U2.Text), cb_U2.Checked,
    StrToFloat(e_Theta.Text) / 180.0 * pi, cb_Theta.Checked);

  if self.rb_S1_PQ.Checked then
    p.DefinirVariable(3, CPX_RECTANGULAR,
      StrToFloat(e_P1.Text), cb_P1.Checked,
      StrToFloat(e_Q1.Text), cb_Q1.Checked)
  else
    p.DefinirVariable(3, CPX_POLAR,
      StrToFloat(e_roS1.Text), cb_roS1.Checked,
      StrToFloat(e_Fi1.Text), cb_Fi1.Checked);

  if self.rb_S2_PQ.Checked then
    p.DefinirVariable(4, CPX_RECTANGULAR, -StrToFloat(
      e_P2.Text), cb_P2.Checked, -StrToFloat(
      e_Q2.Text), cb_Q2.Checked)
  else
    p.DefinirVariable(4, CPX_POLAR,
      StrToFloat(e_roS2.Text), cb_roS2.Checked,
      (StrToFloat(e_Fi2.Text) + 180.0) / 180.0 * pi, cb_Fi2.Checked);


  for iEcuacion := 1 to 2 do
  begin
    p.InscribirDerivada(dfidro_V, iEcuacion, 1, 1);
    p.InscribirDerivada(dfidalfa_V, iEcuacion, 1, 2);
    p.InscribirDerivada(dfidro_V, iEcuacion, 2, 1);
    p.InscribirDerivada(dfidalfa_V, iEcuacion, 2, 2);
    if self.rb_S1_PQ.Checked then
    begin
      p.InscribirDerivada(dfidP, iEcuacion, 3, 1);
      p.InscribirDerivada(dfidQ, iEcuacion, 3, 2);
    end
    else
    begin
      p.InscribirDerivada(dfidro_S, iEcuacion, 3, 1);
      p.InscribirDerivada(dfidalfa_S, iEcuacion, 3, 2);
    end;
    if self.rb_S2_PQ.Checked then
    begin
      p.InscribirDerivada(dfidP, iEcuacion, 4, 1);
      p.InscribirDerivada(dfidQ, iEcuacion, 4, 2);
    end
    else
    begin
      p.InscribirDerivada(dfidro_S, iEcuacion, 4, 1);
      p.InscribirDerivada(dfidalfa_S, iEcuacion, 4, 2);
    end;
  end;

  resOk := p.BuscarSolucion_NewtonRapson(1e-8, 100, err, cntiters);

  if not cb_U1.Checked then
    e_U1.Text := FloatToStrF(mod1(p.zvalores.v[1]), ffFixed, 8, 2);
  if not cb_U2.Checked then
    e_U2.Text := FloatToStrF(mod1(p.zvalores.v[2]), ffFixed, 8, 2);
  if not cb_Theta.Checked then
    e_Theta.Text := FloatToStrF(fase(p.zvalores.v[2]) / pi * 180.0, ffFixed, 8, 2);
  if not cb_P1.Checked then
    e_P1.Text := FloatToStrF(p.zvalores.v[3].r, ffFixed, 8, 2);
  if not cb_Q1.Checked then
    e_Q1.Text := FloatToStrF(p.zvalores.v[3].i, ffFixed, 8, 2);
  if not cb_P2.Checked then
    e_P2.Text := FloatToStrF(-p.zvalores.v[4].r, ffFixed, 8, 2);
  if not cb_Q2.Checked then
    e_Q2.Text := FloatToStrF(-p.zvalores.v[4].i, ffFixed, 8, 2);

  Actualizar_S1;
  Actualizar_S2;

  self.Cursor := crDefault;

  if resOK then
  begin
    ShowMessage( 'Resolución finalizada con éxito.' );
  end
  else
  begin
    ShowMessage( 'No CONVERGIO ' + p.errMsg);
  end;
  p.Free;
  y.Free;
  IiConj.Free;
end;

procedure TForm2.cb_simetricoClick(Sender: TObject);
begin
  if self.cb_simetrico.Checked then
    self.panel_D.Visible := False
  else
    self.panel_D.Visible := True;
  Actualizar_C;
end;

procedure TForm2.e_AClick(Sender: TObject);
begin
  Actualizar_C;
end;

procedure TForm2.ToggleBox1Change(Sender: TObject);
begin

  Panel_Ayuda.Visible := ToggleBox1.State = cbChecked;

end;

procedure TForm2.e_P1Change(Sender: TObject);
begin
  if Self.rb_S1_PQ.Checked then
    Actualizar_S1;
end;

procedure TForm2.e_P2Change(Sender: TObject);
begin
  if Self.rb_S2_PQ.Checked then
    Actualizar_S2;
end;

procedure TForm2.e_roS1Change(Sender: TObject);
begin
  if Self.rb_S1_roFi.Checked then
    Actualizar_PQ1;
end;

procedure TForm2.e_roS2Change(Sender: TObject);
begin
  if Self.rb_S2_roFi.Checked then
    Actualizar_PQ2;

end;

procedure TForm2.Actualizar_S1;
var
  S: NComplex;
begin
  try
    S := numc(StrToFloat(e_P1.Text), StrToFloat(e_Q1.Text))^;
    e_roS1.Text := FloatToStrF(mod1(S), ffNumber, 8, 2);
    e_Fi1.Text := FloatToStrF(fase(S) / pi * 180, ffNumber, 6, 1);
  except
    on Exception do
    begin
      e_roS1.Text := '?';
      e_Fi1.Text := '?';
    end;
  end;
end;

procedure TForm2.Actualizar_PQ1;
var
  S: NComplex;
  ro, alfa: NReal;
begin
  try
    ro := StrToFloat(e_roS1.Text);
    alfa := StrToFloat(e_Fi1.Text) / 180 * pi;

    S := AlgebraC.numc_rofi(ro, alfa)^;
    e_P1.Text := FloatToStrF(S.r, ffNumber, 8, 2);
    e_Q1.Text := FloatToStrF(S.i, ffNumber, 8, 2);
  except
    on Exception do
    begin
      e_P1.Text := '?';
      e_Q1.Text := '?';
    end;
  end;
end;

procedure TForm2.Actualizar_S2;
var
  S: NComplex;
begin
  try
    S := numc(StrToFloat(e_P2.Text), StrToFloat(e_Q2.Text))^;
    e_roS2.Text := FloatToStrF(mod1(S), ffNumber, 8, 2);
    e_Fi2.Text := FloatToStrF(fase(S) / pi * 180, ffNumber, 6, 1);
  except
    on Exception do
    begin
      e_roS2.Text := '?';
      e_Fi2.Text := '?';
    end;
  end;
end;

procedure TForm2.Actualizar_PQ2;
var
  S: NComplex;
  ro, alfa: NReal;
begin
  try
    ro := StrToFloat(e_roS2.Text);
    alfa := StrToFloat(e_Fi2.Text) / 180 * pi;

    S := AlgebraC.numc_rofi(ro, alfa)^;
    e_P2.Text := FloatToStrF(S.r, ffNumber, 8, 2);
    e_Q2.Text := FloatToStrF(S.i, ffNumber, 8, 2);
  except
    on Exception do
    begin
      e_P2.Text := '?';
      e_Q2.Text := '?';
    end;
  end;
end;



procedure TForm2.FormCreate(Sender: TObject);
begin
  // cargamos el cuadripolo ejemplo

  flg_Inicializando := True;
  DecimalSeparator := '.';
  ThousandSeparator := #0;

  e_A.Text := FloatToStrF(1, ffNumber, 8, 2);
  e_alfa.Text := '0';
  e_B.Text := FloatToStrF(2.0, ffNumber, 8, 2);
  e_beta.Text := '0';
  self.cb_simetrico.Checked := False;
  e_D.Text := FloatToStrF(1.0, ffNumber, 8, 2);
  e_delta.Text := '0';

  e_U1.Text := '220';
  cb_U1.Checked := True;
  e_P1.Text := '2200';
  cb_P1.Checked := True;
  e_Q1.Text := '0';
  cb_Q1.Checked := True;

  e_U2.Text := '200';
  e_P2.Text := '2000';
  e_Q2.Text := '0.1';
  flg_Inicializando := False;
  Actualizar_C;
end;

procedure TForm2.rb_S1_PQClick(Sender: TObject);
begin
  if rb_S1_PQ.Checked then
  begin
    rb_S1_roFI.Checked := False;
    self.cb_roS1.Enabled := False;
    self.cb_FI1.Enabled := False;
    self.e_roS1.Enabled := False;
    self.e_FI1.Enabled := False;
    self.cb_P1.Enabled := True;
    self.cb_Q1.Enabled := True;
    self.e_P1.Enabled := True;
    self.e_Q1.Enabled := True;
  end;
end;

procedure TForm2.rb_S1_roFiClick(Sender: TObject);
begin
  if self.rb_S1_roFi.Checked then
  begin
    rb_S1_PQ.Checked := False;
    self.cb_roS1.Enabled := True;
    self.cb_FI1.Enabled := True;
    self.e_roS1.Enabled := True;
    self.e_FI1.Enabled := True;
    self.cb_P1.Enabled := False;
    self.cb_Q1.Enabled := False;
    self.e_P1.Enabled := False;
    self.e_Q1.Enabled := False;
  end;

end;

procedure TForm2.rb_S2_PQClick(Sender: TObject);
begin
  if rb_S2_PQ.Checked then
  begin
    rb_S2_roFI.Checked := False;
    self.cb_roS2.Enabled := False;
    self.cb_FI2.Enabled := False;
    self.e_roS2.Enabled := False;
    self.e_FI2.Enabled := False;
    self.cb_P2.Enabled := True;
    self.cb_Q2.Enabled := True;
    self.e_P2.Enabled := True;
    self.e_Q2.Enabled := True;
  end;
end;

procedure TForm2.rb_S2_roFiClick(Sender: TObject);
begin
  if self.rb_S2_roFi.Checked then
  begin
    rb_S2_PQ.Checked := False;
    self.cb_roS2.Enabled := True;
    self.cb_FI2.Enabled := True;
    self.e_roS2.Enabled := True;
    self.e_FI2.Enabled := True;
    self.cb_P2.Enabled := False;
    self.cb_Q2.Enabled := False;
    self.e_P2.Enabled := False;
    self.e_Q2.Enabled := False;
  end;

end;

procedure TForm2.Actualizar_C;
begin
  if flg_Inicializando then
    exit;

  try
    A := numc_rofi(StrToFloat(e_A.Text), StrToFloat(e_Alfa.Text) / 180.0 * pi)^;
    B := numc_rofi(StrToFloat(e_B.Text), strToFloat(e_Beta.Text) / 180.0 * pi)^;
    if self.cb_simetrico.Checked then
      D := A
    else
      D := numc_rofi(StrToFloat(e_D.Text), strToFloat(e_delta.Text) / 180.0 * pi)^;
    C := dc(rc(pc(A, D)^, complex_UNO)^, B)^;
    e_C.Text := FloatToStrF(mod1(C), ffNumber, 8, 2);
    e_gamma.Text := FloatToStrF(fase(C) / pi * 180, ffFixed, 6, 1);
  except
    on Exception do
    begin
      e_C.Text := '?';
      e_gamma.Text := '?';
    end;
  end;
end;


end.
