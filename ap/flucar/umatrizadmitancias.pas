unit umatrizadmitancias;

interface

uses
  Classes, SysUtils, Algebrac, Matcpx, xMatDefs;

type
   TMatrizDeAdmitancias=class(TMatComplex)
     constructor Create_Matriz(n: integer);
     procedure Free;
     procedure Acumular( n1, n2: integer; xFactor: NComplex);
     procedure BorrarTodo;
     procedure Pon(n1, n2: integer; Y: NComplex );
     procedure PonY( n1, n2: integer; xy: NComplex);
     procedure PonT( n1, n2: integer; xy: NComplex; n: NReal);
     procedure PonCuadripolo( n1, n2: integer; Y13, Z12, Y23: NComplex);
     procedure SacarY( n1, n2: integer; xy: NComplex);
     procedure SacarT( n1, n2: integer; xy: NComplex; n: NReal);
     procedure WriteM;
   end;


implementation

constructor TMatrizDeAdmitancias.Create_Matriz(n: integer);
begin
  Create_Init(n,n);
  //self.BorrarTodo;
end;


procedure TMatrizDeAdmitancias.Free;
begin
  inherited Free;
end;

procedure TMatrizDeAdmitancias.Acumular( n1, n2: integer; xFactor: NComplex);
begin
  self.acum_e(n1,n2,xFactor);
end;

procedure TMatrizDeAdmitancias.BorrarTodo;
var
  i,j:integer;
begin
  for i:=1 to self.nc do
      for j:=1 to self.nc do
          begin
            self.pon_e(i,j,complex_NULO);
          end;
end;

procedure TMatrizDeAdmitancias.Pon(n1, n2: integer; Y: NComplex );
begin
  	if (n1<> 0)and(n2<>0) then self.Acumular(n1,n2,Y);
end;

procedure TMatrizDeAdmitancias.PonY( n1, n2: integer; xy: NComplex);
var
	menosy: NComplex;
begin
	menosy:= prc(-1,xy)^;
	self.pon(n1,n1, xy);
	self.pon(n1,n2, menosy);
	self.pon(n2,n1, menosy);
	self.pon(n2,n2, xy);
end;

procedure TMatrizDeAdmitancias.SacarY( n1, n2: integer; xy: NComplex);
var
	menosy: NComplex;
begin
	menosy:= prc(-1,xy)^;
	self.pon(n1,n1, prc(-1,xy)^);
	self.pon(n1,n2, prc(-1,menosy)^);
	self.pon(n2,n1, prc(-1,menosy)^);
	self.pon(n2,n2, prc(-1,xy)^);
end;

procedure TMatrizDeAdmitancias.PonT( n1, n2: integer; xy: NComplex; n: NReal);
var
	xyt,menosy, menosyt: NComplex;
begin
	menosy:= prc(-1,xy)^;
	xyt:= prc(sqr(n),xy)^;
	menosyt:= prc(n,menosy)^;

        self.pon(n1,n1,xyt);
	self.pon(n1,n2, menosyt);
	self.pon(n2,n1, menosyt);
	self.pon(n2,n2, xy);
end;

procedure TMatrizDeAdmitancias.SacarT( n1, n2: integer; xy: NComplex; n: NReal);

var
	xyt,menosy, menosyt: NComplex;
begin
	menosy:= prc(-1,xy)^;
	xyt:= prc(sqr(n),xy)^;
	menosyt:= prc(n,menosy)^;
	self.pon(n1,n1, prc(-1,xyt)^);
	self.pon(n1,n2, prc(-1,menosyt)^);
	self.pon(n2,n1, prc(-1,menosyt)^);
	self.pon(n2,n2, prc(-1,xy)^);
end;


procedure TMatrizDeAdmitancias.PonCuadripolo(n1, n2: integer; Y13, Z12, Y23: NComplex);
var
	Y,Z: NComplex;

begin

		y:= Y13;
		self.Pon(n1, n1, y);
		z:= Z12;
		y:= prc( 1/mod2(z), cc(z)^)^;
		self.PonY(n1, n2, y);
		y:= Y23;
		self.Pon(n2, n2, y);

end;

procedure TMatrizDeAdmitancias.WriteM;
begin
  self.writeM;
end;

end.

