unit uresfxgx;

{$mode delphi}

(*
+CREACION: rch@20121027

Definición de la clase TResfx

Usando las clases de ufxgx se agrega lo necesario para representar
restricciones de problemas de optimización


Una restricción es una función f(X): R^N->R

a la que se le agregan los límites de validéz.

f_min <= f(X) <= f_max.

Como durante la resolución de un problema de optimización resulta conveniente
tener un multiplicador de las restricciones (para formar la Lagrangiana del problema).
agregamos el multiplicador Lambda.


*)
interface

uses
  Classes, SysUtils, xmatdefs, matreal, ufxgx;


type
  TTipoRestriccion = (
    TR_Libre, // no es restricción
    TR_Igualdad, // f(x) = f_min = f_max
    TR_Mayor, // f_min <= f( x )
    TR_Menor, // f(x ) <= f_max
    TR_Entre); // f_min <= f(x) <= f_max

  TDAofTipoRestriccion = array of TTipoRestriccion;

  TRestriccionActiva = (
    INDEFINIDA, // no se calculó todavia
    NINGUNA, // no hay ninguna restricción activa
    INFERIOR, // está activa el borde inferior. f(x) = f_min
    SUPERIOR); // está activo el borede superior. f(x ) = f_max

type

  { TResfx }

  TResfx = class
    fx: Tfx;
    tipo: TTipoRestriccion;
    f_min: NReal;
    f_max: NReal;
    r_activa: TRestriccionActiva;
    ultimo_f: NReal; // ultimo valor calculado de f
    ultimo_g: TVectR; // utlimo valor del gradiente calculado.

    distancia_frontera_f: NReal;
    // es abs( ultimo_f - f_umbral )  ; el f_umbral es el límite violado
    // si no hay límite violado, el valor es - min( abs( ultimo_f - f_min), abs( ultimo_f - f_max) )
    // si la restricción es de igualdad siempre es >= 0 la distancia

    // Multiplicador de la retricción para formar la Lagrangiana.
    // Suponemos lambda positivo y aplicado sobre f(x) <= f_max
    // si está activa la otra restricción, en la formación de la Lagrangiana se debe
    // utilizar -lambda.
    lambda: NReal;


    // Soporte para la descomposición del sub-gradiente activo de restricciones
    gr_versor: TVectR; // versor de la base opositora
    gr_remanente: TVectR; // remanente
    gr_rem_ne: NReal; // norma euclidea del remanente
    gr_alfa: TVectR; // coordenadas sobre la base opositora
    gr_EnBaseOpositora: boolean; // TRUE implica activo en la base opositora


    constructor Create(tipo_: TTipoRestriccion; f_min_, f_max_: NReal;
      const fx_: Tfx; dim_x: integer);

    // calcula fx(X) y de paso actualiza r_activa, ultimo_f y distancia_frontera
    // Atención, el valor ultimo_f, es devuelto por la función y tiene la
    // evaluación de la función fx(x) tal cual está defininda.
    // Si se está en la región factible, r_activa = NINGUNA y distancia_frontera = 0
    // Si luego de la llamada, queda r_activa = INFERIOR, entonces, el tipo de restricción
    // es TR_IGUALDAD o TR_ENTRE o TR_MAYOR.
    function eval_f(const X: TVectR): NReal;

    // calcula el gradiente de fx tal cual está definido.
    // Si en la evaluación de eval_f, quedó r_activa = INFERIOR a los efectos de
    // tener un gradiente consistente con r(x) < 0 como restricción hay que considerar
    // el negativo del gradiente calculado.
    procedure eval_g(const X: TVectR);
    procedure Free;

    function serialize: string;
  end;


function TipoRestriccionToStr( tr: TTipoRestriccion): string;
function RestriccionActivaToStr( tra: TRestriccionActiva ): string;

procedure vclear( a: TDAofTipoRestriccion ); overload;

implementation


procedure vclear( a: TDAofTipoRestriccion );
var
  k: integer;
begin
  for k:= 0 to high( a ) do
    a[k]:= TR_Libre;
end;


function TipoRestriccionToStr( tr: TTipoRestriccion): string;
begin
  case tr of
  TR_Libre: result:= 'LIBRE';
  TR_Igualdad: result:= 'IGUALDAD';
  TR_Mayor: result:= 'MAYOR';
  TR_Menor: result:= 'MENOR';
  TR_Entre: result:= 'ENTRE';
  else
    result:= 'DESCONOCIDA';
  end;
end;


function RestriccionActivaToStr( tra: TRestriccionActiva ): string;
begin
  case tra of
    INDEFINIDA: result:= 'INDEFINIDA';
    NINGUNA: result:= 'NINGUNA';
    INFERIOR: result:= 'INFERIOR';
    SUPERIOR: result:= 'SUPERIOR';
    else
      result:= 'DESCONOCIDA';
  end;
end;


constructor TResfx.Create(tipo_: TTipoRestriccion; f_min_, f_max_: NReal;
  const fx_: Tfx; dim_x: integer);
begin
  tipo := tipo_;
  f_min := f_min_;
  f_max := f_max_;
  fx := fx_;

  ultimo_g := TVectR.Create_Init(dim_x);
  gr_remanente:= TVectR.Create_Init(dim_x);
  gr_versor:= TVectR.Create_Init(dim_x);
  gr_alfa:= TVectR.Create_Init(dim_x);

  if tipo <> TR_Libre then
    r_activa := INDEFINIDA // no calculado
  else
    r_activa := NINGUNA;
end;



function TResfx.eval_f(const X: TVectR): NReal;
  // calcula fx(X) y de paso actualiza r_activa, ultimo_f y distancia_frontera
begin
  ultimo_f := fx.f(X);
  r_activa := NINGUNA;
  distancia_frontera_f := 0.0;

  if tipo <> TR_LIBRE then
  begin
    case tipo of
      TR_Mayor: if ultimo_f <= f_min then
        begin
          r_activa := INFERIOR;
          distancia_frontera_f := f_min - ultimo_f;
        end;
      TR_Menor: if ultimo_f >= f_max then
        begin
          r_activa := SUPERIOR;
          distancia_frontera_f := ultimo_f - f_max;
        end;

      TR_Igualdad: if ultimo_f < f_min then
        begin
          r_activa := INFERIOR;
          distancia_frontera_f := f_min - ultimo_f;
        end
        else
        begin
          r_activa := SUPERIOR;
          distancia_frontera_f := ultimo_f - f_min;
        end;

      TR_Entre: if ultimo_f <= f_min then
        begin
          r_activa := INFERIOR;
          distancia_frontera_f := f_min - ultimo_f;
        end
        else if ultimo_f >= f_max then
        begin
          r_activa := SUPERIOR;
          distancia_frontera_f := ultimo_f - f_max;
        end;
    end;
  end;
  result:= ultimo_f;
end;


function TResfx.serialize: string;
var
  res: string;
begin
  res:= 'Tipo: '+ TipoRestriccionToStr( self.tipo )+ CRLF;
  res:= res+ 'f: '+ fx.serialize+ CRLF;
  res:= res+ CRLF;
  result:= res;
end;

procedure TResfx.eval_g(const X: TVectR);
begin
  ultimo_g.Ceros;
  fx.acum_g( ultimo_g, X);
end;

procedure TResfx.Free;
begin
  ultimo_g.Free;
  gr_remanente.Free;
  gr_versor.Free;
  gr_alfa.Free;
  inherited Free;
end;

end.
