unit ufuncionesbasicas;

interface

uses
  Classes, SysUtils, uparseadorsupersimple;


procedure AgregarFunciones( Evaluador: TEvaluadorExpresionesSimples );

type
  TFun_F_FF_OfObject = function (x, y: double): double of object;

{ TFunc_F_FF_OfObject }
TFunc_F_FF_OfObject = class(   TOperProcDef )
 func_ptr: TFun_F_FF_OfObject;
 procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
 constructor Create( nombre_: String; func_ptr_: TFun_F_FF_OfObject );
end;


implementation
uses
  Math;

type

   { TFuncSin_F_F }
   TFuncSin_F_F = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;

   { TFuncCos_F_F }

   TFuncCos_F_F = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;

   { TFuncExp_F_F }

   TFuncExp_F_F = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;

   { TFuncPow_F_FF }
   TFuncPow_F_FF = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;

{ TFunc_F_FF_OfObject }

procedure TFunc_F_FF_OfObject.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA, parB: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  parB:= entradas[1];
  res.val.val_F:= func_ptr( parA.ValAsFloat, parB.ValAsFloat );
end;

constructor TFunc_F_FF_OfObject.Create(nombre_: String;
  func_ptr_: TFun_F_FF_OfObject);
begin
  inherited Create( nombre_, 'F', 'FF' );
  func_ptr:= func_ptr_;
end;



// sin
procedure TFuncSin_F_F.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  res.val.val_F:= sin( parA.ValAsFloat );
end;

constructor TFuncSin_F_F.Create;
begin
  inherited Create( 'sin', 'F', 'F' );
end;

// cos
procedure TFuncCos_F_F.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  res.val.val_F:= cos( parA.ValAsFloat );
end;

constructor TFuncCos_F_F.Create;
begin
  inherited Create( 'cos', 'F', 'F' );
end;

// exp
procedure TFuncExp_F_F.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  res.val.val_F:= exp( parA.ValAsFloat );
end;

constructor TFuncExp_F_F.Create;
begin
  inherited Create( 'exp', 'F', 'F' );
end;



// pow
procedure TFuncPow_F_FF.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA, parB: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  parB:= entradas[1];
  res.val.val_F:= power( parA.ValAsFloat, parB.ValAsFloat );
end;

constructor TFuncPow_F_FF.Create;
begin
  inherited Create( 'pow', 'F', 'FF' );
end;




procedure AgregarFunciones( Evaluador: TEvaluadorExpresionesSimples );
var
  aDef: TOperProcDef;
begin
  aDef:= TFuncSin_F_F.Create;
  Evaluador.CatalogoFuncionesEstandar.add( aDef );
  aDef:= TFuncCos_F_F.Create;
  Evaluador.CatalogoFuncionesEstandar.add( aDef );
  aDef:= TFuncExp_F_F.Create;
  Evaluador.CatalogoFuncionesEstandar.add( aDef );
  aDef:= TFuncPow_F_FF.Create;
  Evaluador.CatalogoFuncionesEstandar.add( aDef );
end;

end.

