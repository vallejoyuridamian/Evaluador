unit uFuenteGaussiana;

interface

uses
  uFichasLPD, xMatDefs, uFechas, fddp,
  uCosa, uCosaConNombre, uGlobs,
  uFuentesAleatorias, SysUtils;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteGaussiana = 'Fuente Gaussiana';

type
(*+doc TFichaFuenteGaussiana
Ficha de parámetros dinámicos para las fuentes Gaussianas
Permite especificar valorEsperado y varianza.
-doc*)

  { TFichaFuenteGaussiana }

  TFichaFuenteGaussiana = class(TFichaLPD)
  public
    valorEsperado: NReal;
    varianza:      NReal;

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      valorEsperado, varianza: NReal);
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;
  end;

(*+doc TFuenteGaussiana
Fuente con distribución gaussiana utilizándo parámetros dinámicos.
-doc*)

  { TFuenteGaussiana }

  TFuenteGaussiana = class(TFuenteAleatoriaConFichas)
  private
    fgn: Tf_ddp_GaussianaNormal;
  public
    pa: TFichaFuenteGaussiana;

    constructor Create(capa: integer; nombre: string;
      xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean; lpd: TFichasLPD);
    class function TipoFichaFuente: TClaseDeFichaLPD; override;
    //function InfoAd : String; override;
    class function DescClase: string; override;
    procedure PrepararMemoria( Catalogo: TCatalogoReferencias; globs: TGlobs); override;
    procedure RegistrarParametrosDinamicos( Catalogo: TCatalogoReferencias ); override;
    procedure SortearEntradaRB(var aRB: NReal); override;
    procedure ValorEsperadoEntradaRB(var aRB: NReal); override;

    procedure Free; override;
  end;


procedure AlInicio;
procedure AlFinal;


implementation



//---------------------------------
// Métodos de TFichaFuenteGaussiana
//=================================

constructor TFichaFuenteGaussiana.Create(capa: integer; fecha: TFecha;
  periodicidad: TPeriodicidad; valorEsperado, varianza: NReal);
begin
  inherited Create(capa, fecha, periodicidad);
  self.valorEsperado := valorEsperado;
  self.varianza := varianza;
end;

function TFichaFuenteGaussiana.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('valorEsperado', valorEsperado);
  Result.addCampoDef('varianza', varianza);
end;

procedure TFichaFuenteGaussiana.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteGaussiana.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;

class function TFichaFuenteGaussiana.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteGaussiana;
end;

function TFichaFuenteGaussiana.infoAd_: string;
begin
  Result := 'ValorEsperado= ' + FloatToStrF(valorEsperado, ffGeneral, 10, 2) +
    ', ' + 'Varianza= ' + FloatToStrF(varianza, ffGeneral, 10, 2);
end;













//----------------------------
// Métodos de TFuenteGaussiana
//============================

constructor TFuenteGaussiana.Create(capa: integer; nombre: string;
  xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean; lpd: TFichasLPD);

begin
  inherited Create(capa, nombre, xdurPasoDeSorteoEnHoras, resumirPromediando, lpd);
  fgn := nil;
end;

class function TFuenteGaussiana.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteGaussiana;
end;

{function TFuenteGaussiana.infoAd : String;
begin
  result := 'Gaussiana'
end;}

class function TFuenteGaussiana.DescClase: string;
begin
  Result := rsFuenteGaussiana;
end;

procedure TFuenteGaussiana.PrepararMemoria(Catalogo: TCatalogoReferencias;
  globs: TGlobs);
begin
  inherited prepararMemoria( Catalogo, globs);
  fgn := Tf_ddp_GaussianaNormal.Create(sorteadorUniforme, 0);
end;

procedure TFuenteGaussiana.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  //Se llama solo despues de preparar memoria que ya expande las fichas
  //no hace falta volver a hacerlo y es un proceso caro si hay periodicidad
  //   lpd.expandirFichas(globs);
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, cambioFichaPDFuenteAleatoria);
end;

procedure TFuenteGaussiana.SortearEntradaRB(var aRB: NReal);
begin
  aRB := (fgn.rnd * pa.varianza) + pa.valorEsperado;
end;

procedure TFuenteGaussiana.ValorEsperadoEntradaRB(var aRB: NReal);
begin
  aRB := pa.valorEsperado;
end;


procedure TFuenteGaussiana.Free;
begin
  if fgn <> nil then
    fgn.Free;
  inherited Free;
end;


procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteGaussiana.ClassName, TFuenteGaussiana);
  registrarClaseDeCosa(TFichaFuenteGaussiana.ClassName, TFichaFuenteGaussiana);
end;

procedure AlFinal;
begin
end;

end.
