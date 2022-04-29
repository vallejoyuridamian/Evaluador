unit ugraficador_mapas;

{$mode delphi}

interface

uses
  Classes, SysUtils,
  Graphics,
  ulogoSimSEE,
  xmatdefs, ugraficador;

type
  // Un Mapa es una función f(x, y) que supondremos representada por una matriz de valores
  // según una discretización de x e y dada por dos Series de valores
  // El ploteo del mapa será por curvas iso-nivel especificadas en el Eje_z
  // Hay dos tipo de Mapas - Rectangulares y Circulares. En los circulares el
  // eje x es el ángulo y el y el radio.
  TMapaGrafico = class
    nombre: string;
    orden: integer;
    tipoGrafico: TTipoGrafico; // AreaApilada, XY, linea
    valores: TMatOfNReal;
    RadioMarcador: integer;
    AnchoLineaMarcador: integer;
    nombreValores: array of string;
    serie_x, serie_y: TSerieGrafico;
    formato_str: string;

    // al crear la serie se pasa xvalores y la serie se encarga de eliminar
    constructor Create(nombre: string; xvalores: TMatOfNReal; serie_x,
      serie_y: TSerieGrafico; grafico: TGrafico=nil; formato_str: string='');
    procedure Free;
  end;

  TGraficoMapa = class( TGrafico )
    mapas: TList; // por ahora uno solo
    constructor Create(nombre: string; tipoGrafico: TTipoGrafico; k_LogoSimSEE: integer = 0);
    procedure Draw(c: TCanvas; ancho, alto: integer); override;
    procedure AddMapa( Mapa: TMapaGrafico);
    procedure Free; override;
  end;

implementation

  // al crear la serie se pasa xvalores y la serie se encarga de eliminar
constructor TMapaGrafico.Create(
    nombre: string; xvalores: TMatOfNReal;
    serie_x, serie_y: TSerieGrafico;
    grafico: TGrafico = nil; // Si <> nil lo usa para fijar colores y marcador automático
    formato_str: string = '' // Lo usa para detectar formato fecha
    );
begin
  inherited Create;
  self.nombre:= nombre;
  valores:= xvalores;
  self.serie_x:= serie_x;
  self.serie_y:= serie_y;
  self.formato_str:= formato_str;
end;

procedure TMapaGrafico.Free;
begin
  setlength( valores, 0 );
  inherited Free;
end;


constructor Create(nombre: string; tipoGrafico: TTipoGrafico; k_LogoSimSEE: integer = 0);
begin
  inherited Create( nombre, tipoGrafico, k_LogoSimSEE );
  mapas:= TList.Create;
end;

procedure TGraficoMapa.Draw(c: TCanvas; ancho, alto: integer);

procedure TGraficoMapa.AddMapa( Mapa: TMapaGrafico);
begin
  mapas.add( Mapa);
end;

procedure TGraficoMapa.Free;
end;


end.

