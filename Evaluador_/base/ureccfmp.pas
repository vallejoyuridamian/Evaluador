unit uRecCFMP;

{$mode delphi}

interface

uses
  Classes, SysUtils, math;

type

  { TRec_CFMP }

  { TRecCFMP }

  TRecCFMP=class

    nivel: Integer;

    mu_x:Double;
    mu: Double;

    pi_bon: Double;
    pi_pal: Double;
    pi_sg: Double;
    pi_bay: Double;

    ct_bon: Double;
    ct_pal: Double;
    ct_sg: Double;
    ct_bay: Double;

    V_bon_0: Double;
    V_pal_0: Double;
    V_sg_0: Double;
    V_bay_0: Double;

    constructor Create (nivel: Integer);

    procedure cargar_mu (mu:Double);
    procedure cargar_pi (pi_bon: Double; pi_pal: Double; pi_sg: Double; pi_bay: Double);
    procedure cargar_ct (ct_bon: Double; ct_pal: Double; ct_sg: Double; ct_bay: Double);


    function evalCF(V_bon: Double; V_pal: Double; V_sg: Double; V_bay:Double): Double;

    function GetPi( i: integer ): Double;
    Property pi[i : integer]: Double Read GetPi;
  end;

  { TListaRecCFMP }

  TListaRecCFMP=class(TList)
  private
    function Get(Index: Integer): TRecCFMP;
  public
    function Add(RecCFMP: TRecCFMP): Integer;
    property Items[Index: Integer]: TRecCFMP read Get;
    function maxEvalRecCFMP(V_bon: Double; V_pal: Double; V_sd: Double; V_bay: Double; var rec: TRecCFMP):Double;
  end;


implementation

{ TRecCFMP }

constructor TRecCFMP.Create(nivel: Integer);
begin
  mu_x:=0;
  self.nivel:=nivel;
end;


function TRecCFMP.GetPi( i: integer ): Double;
begin
  case i of
   0: result:= self.pi_bon;
   1: result:= self.pi_pal;
   2: result:= self.pi_sg;
  end;
end;

procedure TRecCFMP.cargar_mu(mu: Double);
begin
  self.mu:=mu;
end;

procedure TRecCFMP.cargar_pi(pi_bon: Double; pi_pal: Double; pi_sg: Double;
  pi_bay: Double);
begin
  self.pi_bon:=pi_bon;
  self.pi_pal:=pi_pal;
  self.pi_sg:=pi_sg;
  self.pi_bay:=pi_bay;
end;

procedure TRecCFMP.cargar_ct(ct_bon: Double; ct_pal: Double; ct_sg: Double;
  ct_bay: Double);
begin

  self.ct_bon:=ct_bon;
  self.ct_pal:=ct_pal;
  self.ct_sg:=ct_sg;
  self.ct_bay:=ct_bay;

  //c + b*ct + a*ct^2

  V_bon_0 := 193262.2078 + (-5737.153858 + 42.90385487*ct_bon)*ct_bon;
  V_pal_0 := 6536.462961 + (-497.1878607 + 10.12952553*ct_pal)*ct_pal;
  V_bay_0 := 24503.49734 + (-994.2535255 + 10.19983653*ct_bay)*ct_bay;

  //a+(ct^b)/c

  V_sg_0:= 378.1 + power(ct_sg,4.8432)/5871.97;

end;

function TRecCFMP.evalCF(V_bon: Double; V_pal: Double; V_sg: Double;
  V_bay: Double): Double;
begin
  Result:= mu_x + mu + pi_bon*V_bon + pi_pal*V_pal + pi_sg*V_sg + pi_bay*V_bay;
end;

{ TListaRecCFMP }

function TListaRecCFMP.Get(Index: Integer): TRecCFMP;
begin
  Result := Inherited Items[Index];
end;

function TListaRecCFMP.Add(RecCFMP: TRecCFMP): Integer;
begin
  Result := inherited Add(RecCFMP);
end;

function TListaRecCFMP.maxEvalRecCFMP(V_bon: Double; V_pal: Double;
  V_sd: Double; V_bay: Double; var rec: TRecCFMP): Double;
var
  CFeval, max:Double;
  i: Integer;
begin
  rec:=Items[0];
  CFeval:=Items[0].evalCF(V_bon, V_pal, V_sd, V_bay);
  max:=CFeval;
  for i:=1 to self.Count-1 do
    begin
      CFeval:=Items[i].evalCF(V_bon, V_pal, V_sd, V_bay);
      if (max<CFeval) then
        begin
          max:=CFeval;
          rec:=Items[i];
        end;
    end;
  Result:=max;

end;

end.

