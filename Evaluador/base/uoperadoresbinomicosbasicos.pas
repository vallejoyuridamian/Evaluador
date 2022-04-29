unit uoperadoresbinomicosbasicos;

interface

uses
  Classes, SysUtils, math, uparseadorsupersimple;


procedure AgregarOperadoresBinomicos( Evaluador: TEvaluadorExpresionesSimples );

implementation

type
   { TOperSuma_F_FF }
   TOperSuma_F_FF = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;

   { TOperResta_F_FF }
   TOperResta_F_FF = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;

   { TOperProducto_F_FF }
   TOperProducto_F_FF = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;

   { TOperDivision_F_FF }
   TOperDivision_F_FF = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;


   { TOperPower_F_FF }
   TOperPower_F_FF = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;


  { TOperAsignar := }
  TOperAsignar = class(   TOperProcDef )
    procedure evaluar( salida: TExpresion; entradas: TExprLst ); override;
    constructor Create;
  end;


// Suma
procedure TOperSuma_F_FF.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA, parB: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  parB:= entradas[1];

  res.val.val_F:= parA.ValAsFloat + parB.ValAsFloat;
end;

constructor TOperSuma_F_FF.Create;
begin
  inherited Create( '+', 'F', 'FF' );
end;


// Resta
procedure TOperResta_F_FF.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA, parB: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  parB:= entradas[1];
  res.val.val_F:= parA.ValAsFloat - parB.ValAsFloat;
end;

constructor TOperResta_F_FF.Create;
begin
  inherited Create( '-', 'F', 'FF' );
end;


// Producto
procedure TOperProducto_F_FF.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA, parB: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  parB:= entradas[1];

  res.val.val_F:= parA.ValAsFloat * parB.ValAsFloat;
end;

constructor TOperProducto_F_FF.Create;
begin
  inherited Create( '*', 'F', 'FF' );
end;


// Division
procedure TOperDivision_F_FF.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA, parB: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  parB:= entradas[1];

  res.val.val_F:= parA.ValAsFloat / parB.ValAsFloat;
end;

constructor TOperDivision_F_FF.Create;
begin
  inherited Create( '/', 'F', 'FF' );
end;



// Power
procedure TOperPower_F_FF.evaluar(salida: TExpresion; entradas: TExprLst);
var
  res, parA, parB: TExpresion;
begin
  res:= salida;
  parA:= entradas[0];
  parB:= entradas[1];

  res.val.val_F:= power( parA.ValAsFloat, parB.ValAsFloat );
end;

constructor TOperPower_F_FF.Create;
begin
  inherited Create( '^', 'F', 'FF' );
end;


procedure TOperAsignar.evaluar( salida: TExpresion; entradas: TExprLst );
var
  res, parA, parB: TExpresion;
begin
  res:= salida;
  entradas.evaluar;
  parA:= entradas[0];
  parB:= entradas[1];

  parA.val:= parB.val;
  res.val:= parB.val;
end;

constructor TOperAsignar.Create;
begin
  inherited Create( ':=', 'X', 'XX' );
end;


procedure AgregarOperadoresBinomicos( Evaluador: TEvaluadorExpresionesSimples );
var
  aDef: TOperProcDef;
begin
  aDef:= TOperSuma_F_FF.Create;
  Evaluador.CatalogoOperadoresBinomicos.add( aDef );
  aDef:= TOperResta_F_FF.Create;
  Evaluador.CatalogoOperadoresBinomicos.add( aDef );
  aDef:= TOperProducto_F_FF.Create;
  Evaluador.CatalogoOperadoresBinomicos.add( aDef );
  aDef:= TOperDivision_F_FF.Create;
  Evaluador.CatalogoOperadoresBinomicos.add( aDef );
  aDef:= TOperPower_F_FF.Create;
  Evaluador.CatalogoOperadoresBinomicos.add( aDef );
  aDef:= TOperAsignar.Create;
  Evaluador.CatalogoOperadoresBinomicos.add( aDef );
end;

end.

