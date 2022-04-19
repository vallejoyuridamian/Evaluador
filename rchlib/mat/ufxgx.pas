unit ufxgx;
(*
+CREACION: rch@20121026

Definición de clase genérica de fuciones de f(X): R^N->R
y de su gradiente g(X): R^N -> R^N

La idea es facilitar la creación de funciones compuestas.
*)
{$mode delphi}

interface

uses
  Classes, SysUtils, xmatdefs, matreal;

const
 CRLF = #13#10;

type
  Tfx= class
    function f( const X: TVectR ): NReal; virtual; abstract;
    // acumula en grad, el gradiente.
    procedure acum_g( var grad: TVectR; const X: TVectR ); virtual; abstract;
    procedure Free; virtual; abstract;
    function serialize: string; virtual; abstract;
  end;

  { TFx_gEstimado estima el gradiente apartir de calcular f(x+ dx ) - f(x)
   para lo cual en el constructor se debe especificar el vector dx que será
   liberado en el FREE.

   Cuando sea difícil de calcular el gradiente se pude usar esta clase a costa
   de aumentar tiempo de cómputo y precisión.
  }
  Tfx_gEstimado = class( TFx )
    dx: TVectR;
    constructor Create( dx_: TVectR );
    procedure acum_g( var grad: TVectR; const X: TVectR ); override;
    procedure Free; override;
    function serialize: string; override;
  end;

  Tfxlst = class ( TList )
    function get_fx( index: integer ): Tfx;
    procedure set_fx( index: integer; value: Tfx );
    constructor Create;
    procedure Free;
    property fx[ index: integer ]: Tfx
    read get_fx write set_fx; Default;
  end;

  Tfx_constante = class( Tfx )
    constante: NReal;
    constructor Create( constante: NReal ); reintroduce;
    function f( const X: TVectR ): NReal; override;
    procedure acum_g( var grad: TVectR; const X: TVectR ); override;
    function serialize: string; override;
  end;


  // combinación lineal de las componentes de X
  Tfx_lineal_x = class( Tfx )
    ivars: TDAOfNInt;
    coefs: TDAOfNReal;
    constante: NReal;
    constructor Create( ivars_: TDAOfNInt; coefs_: TDAOfNReal; constante_: NReal ); reintroduce;
    function f( const X: TVectR ): NReal; override;
    procedure acum_g( var grad: TVectR; const X: TVectR ); override;
    procedure Free; override;
    function serialize: string; override;
  end;

  Tfx_sumatoria = class( Tfx )
    fxs: Tfxlst;
    constante: NReal;
    constructor Create( constante_: NReal ); reintroduce;
    function f( const X: TVectR ): NReal; override;
    procedure acum_g( var grad: TVectR; const X: TVectR ); override;
    procedure Free; override;
    function serialize: string; override;
  end;

  Tfx_productoria = class( Tfx )
    fxs: Tfxlst;
    constante: NReal;
    constructor Create( constante_: NReal ); reintroduce;
    function f( const X: TVectR ): NReal; override;
    procedure acum_g( var grad: TVectR; const X: TVectR ); override;
    function serialize: string; override;
  end;


implementation

{ Tfx_gEstimado }

constructor Tfx_gEstimado.Create(dx_: TVectR);
begin
  inherited Create;
  dx:= dx_
end;

procedure Tfx_gEstimado.acum_g(var grad: TVectR; const X: TVectR);
var
  dfdx_k: NReal;
  f_x: NReal;
  f_xp: NReal;
  x_k, dx_k: NReal;
  xp: TVectR;
  k:integer;
begin
  f_x:= f( x );
  xp:= x.clonar;

  for k:= 1 to xp.n do
  begin
    x_k:= x.e(k);
    dx_k:= dx.e(k );
    // incrementamos la coordenada k según dx
    xp.pon_e( k, x_k + dx_k );
    f_xp:= f( xp );

    // estimación de la derivada direccional
    dfdx_k:= ( f_xp - f_x )/ dx_k;

    // acumulación en el resultado
    grad.acum_e( k, dfdx_k);

    // restituímos el valor original
    xp.pon_e( k, x_k );
  end;
end;

procedure Tfx_gEstimado.Free;
begin
    dx.Free;
end;

function Tfx_gEstimado.serialize: string;
begin
  result:= 'gEstimado = dx:'+dx.serialize;
end;


function Tfxlst.get_fx( index: integer ): Tfx;
begin
  result:= Tfx( items[index] );
end;

procedure Tfxlst.set_fx( index: integer; value: Tfx );
begin
  items[index]:= value;
end;

constructor Tfxlst.Create;
begin
  inherited Create;
end;


procedure Tfxlst.Free;
var
  k: integer;
begin
  for k:= 0 to count-1 do
   fx[k].free;
  inherited Free;
end;

// Métodos de Tfx_constante
constructor Tfx_constante.Create( constante: NReal );
begin
  self.constante:= constante;
end;

function Tfx_constante.f( const X: TVectR ): NReal;
begin
  result:= constante;
end;

procedure Tfx_constante.acum_g( var grad: TVectR; const X: TVectR );
begin

end;

function Tfx_constante.serialize: string;
begin
  result:= 'cte = '+FloatToStr( constante );
end;

// métodos de  Tfx_lineal_x

constructor Tfx_lineal_x.Create( ivars_: TDAOfNInt; coefs_: TDAOfNReal; constante_: NReal );
{$IFDEF VERBOSO}
var
  k: integer;
{$ENDIF}
begin
  ivars:= copy( ivars_ );
  coefs:= copy( coefs_ );
  constante:= constante_;
  {$IFDEF VERBOSO}
  write('Tfx_lineal_x.Create=');
  for k:= 0 to high( ivars ) do
  begin
    if coefs[k] >= 0 then
    begin
      write( ' +' );
      write( coefs[k]:12:3,'*x',ivars[k] );
    end;
  end;
  writeln( ' + ', constante:12:3 );
  {$ENDIF}
end;

function Tfx_lineal_x.f( const X: TVectR ): NReal;
var
  k: integer;
  res: NReal;
begin
  res:= constante;
  for k:= 0 to high( ivars ) do
    res:= res + coefs[k] *  X.e( ivars[k] );
  result:= res;
end;

procedure Tfx_lineal_x.acum_g( var grad: TVectR; const X: TVectR );
var
  k: integer;
begin
  for k:= 0 to high( ivars ) do
   grad.acum_e( ivars[k], coefs[k] );
end;

procedure Tfx_lineal_x.Free;
begin
  setlength( coefs, 0 );
  setlength( ivars, 0 );
end;


function Tfx_lineal_x.serialize: string;
var
  res: string;
  k: integer;
begin
  res:= 'lineal: ';
  for k:= 0 to high( ivars ) do
  begin
    if coefs[k] < 0 then
      res:= res+' '
    else
      res:= res+' +';
    res:= res + FloatToStr( coefs[k] )+'*x['+IntToStr( ivars[k])+']';
  end;
  if constante < 0 then
     res:= res + ' '+ FloatToStr( constante )
  else
     res:= res + ' +'+ FloatToStr( constante );
  result:= res;
end;

// Métodos de Tfx_sumatoria

constructor Tfx_sumatoria.Create( constante_: NReal );
begin
  fxs:= Tfxlst.Create;
  constante:= constante_;
end;

function Tfx_sumatoria.f( const X: TVectR ): NReal;
var
  k: integer;
  res: NReal;
begin
  res:= constante;
  for k:= 0 to fxs.Count-1 do
    res:= res + fxs[k].f( X );
  result:= res;
end;

procedure Tfx_sumatoria.acum_g( var grad: TVectR; const X: TVectR );
var
  k: integer;
begin
  for k:= 0 to fxs.Count-1 do
    fxs[k].acum_g( grad, X );
end;

function Tfx_sumatoria.serialize: string;
var
  res: string;
  k: integer;
  af: TFx;
begin
  res:= 'sumatoria_inicio( '+CRLF;
  for k:= 0 to fxs.Count-1 do
  begin
    af:= fxs[k];
    res:= res + af.serialize+ CRLF;
  end;
  res:= res + ')fin_sumatoria'+CRLF;
  result:= res;
end;


procedure Tfx_sumatoria.Free;
begin
  fxs.Free;
end;

// métodos de Tfx_productoria
constructor Tfx_productoria.Create( constante_: NReal );
begin
  fxs:= Tfxlst.Create;
  constante:= constante_;
end;

function Tfx_productoria.f( const X: TVectR ): NReal;
var
  res: NReal;
  k: integer;
begin
  res:= constante;
  for k:= 0 to fxs.Count-1 do
    res:= res * fxs[k].f( X );
  result:= res;
end;

procedure Tfx_productoria.acum_g( var grad: TVectR; const X: TVectR );
var
  k, j: integer;
  gtmp: TVectR;
  factor: NReal;
begin
  gtmp:= TVectR.Create_Init( grad.n );
  for k:= 0 to fxs.count -1 do
  begin
    factor:= 1;
    gtmp.ceros;
    for j:= 0 to fxs.count -1 do
    begin
      if j <> k then
        factor:= factor * fxs[j].f( X )
      else
        fxs[j].acum_g( gtmp, X );
    end;
    grad.sumRPV( factor, gtmp );
  end;
  gtmp.Free;
end;

function Tfx_productoria.serialize: string;
var
  res: string;
  k: integer;
  af: TFx;
begin
  res:= 'productoria_inicio( '+CRLF;
  for k:= 0 to fxs.Count-1 do
  begin
    af:= fxs[k];
    res:= res + af.serialize+ CRLF;
  end;
  res:= res + ')fin_productoria'+CRLF;
  result:= res;
end;


end.

