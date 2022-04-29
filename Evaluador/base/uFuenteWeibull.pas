unit uFuenteWeibull;


interface

uses
  uFichasLPD, xMatDefs, uFechas, fddp, fddp_weibull,
  uCosa, uCosaConNombre, uGlobs,
  uFuentesAleatorias, SysUtils;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteDeWeibull = 'Fuente de Weibull';

type
(*+doc TFichaFuenteWeibull
Permite especificar parámetros dinámicos para una fuente de Weibull.
Especifica el valorEsperado y la constanteK
-doc*)

  { TFichaFuenteWeibull }

  TFichaFuenteWeibull = class(TFichaLPD)

  public
    (**************************************************************************)
    (*               A T R I B U T O S   P E R S I S T E N T E S              *)
    (**************************************************************************)

    valorEsperado: NReal;
    constanteK:    NReal;

    (**************************************************************************)

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      valorEsperado, constanteK: NReal);
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;

  end;

(*+doc TFuenteWibull
Fuente aleatoria con distribución de Weibuall. Usando el servicio de parámetros
dinámcios se puede cambiar el valor esperado y la constanteK
-doc*)

  { TFuenteWeibull }

  TFuenteWeibull = class(TFuenteAleatoriaConFichas)
  private
    funcion: Tf_ddp_Weibull;
  public
    pa: TFichaFuenteWeibull;
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
//-------------------------------
// Métodos de TFichaFuenteWeibull
//===============================

constructor TFichaFuenteWeibull.Create(capa: integer; fecha: TFecha;
  periodicidad: TPeriodicidad; valorEsperado, constanteK: NReal);
begin
  inherited Create(capa, fecha, periodicidad);
  self.valorEsperado := valorEsperado;
  self.constanteK := constanteK;
end;

function TFichaFuenteWeibull.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('valorEsperado', valorEsperado);
  Result.addCampoDef('constanteK', constanteK);
end;

procedure TFichaFuenteWeibull.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteWeibull.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


class function TFichaFuenteWeibull.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteDeWeibull;
end;

function TFichaFuenteWeibull.infoAd_: string;
begin
  Result := 'ValorEsperado= ' + FloatToStrF(valorEsperado, ffGeneral, 10, 2) +
    ', ' + 'K= ' + FloatToStrF(constanteK, ffGeneral, 10, 2);
end;










//--------------------------
// Métodos de TFuenteWeibull
//==========================

procedure TFuenteWeibull.SortearEntradaRB(var aRB: NReal);
begin
  aRB := funcion.rnd;
end;

procedure TFuenteWeibull.ValorEsperadoEntradaRB(var aRB: NReal);
begin
  aRB := pa.valorEsperado;
end;

constructor TFuenteWeibull.Create(capa: integer; nombre: string;
  xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean; lpd: TFichasLPD);

begin
  inherited Create(capa, nombre, xdurPasoDeSorteoEnHoras, resumirPromediando, lpd);
  funcion := nil;
end;

class function TFuenteWeibull.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteWeibull;
end;

{function TFuenteWeibull.infoAd : String;
begin
  result:= 'Weibull';
end;}

class function TFuenteWeibull.DescClase: string;
begin
  Result := rsFuenteDeWeibull;
end;

procedure procCambioFichaWeibull(fuente: TCosa);
begin
  cambioFichaPDFuenteAleatoria(fuente);
  TFuenteWeibull(fuente).funcion.setNuevosParams(TFuenteWeibull(fuente).pa.valorEsperado,
    TFuenteWeibull(fuente).pa.constanteK);
end;

procedure TFuenteWeibull.PrepararMemoria(Catalogo: TCatalogoReferencias;
  globs: TGlobs);
begin
  inherited prepararMemoria( Catalogo, globs);
  funcion := Tf_ddp_Weibull.Create(1, 1, sorteadorUniforme, 0);
end;

procedure TFuenteWeibull.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  //Se llama solo despues de preparar memoria que ya expande las fichas
  //no hace falta volver a hacerlo y es un proceso caro si hay periodicidad
  //   lpd.expandirFichas(globs);
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, procCambioFichaWeibull);
end;

procedure TFuenteWeibull.Free;
begin
  if funcion <> nil then
    funcion.Free;
  inherited Free;
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteWeibull.ClassName, TFuenteWeibull);
  registrarClaseDeCosa(TFichaFuenteWeibull.ClassName, TFichaFuenteWeibull);
end;

procedure AlFinal;
begin
end;

end.
