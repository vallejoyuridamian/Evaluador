unit uFuenteUniforme;

interface

uses
  Classes, uFichasLPD, xMatDefs, uFechas, fddp,
  uCosa, uCosaConNombre, uGlobs,
  uFuentesAleatorias, SysUtils;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteUniforme = 'Fuente uniforme';

type

(*+doc TFichaFuenteUniforme
Ficha de parámetros dinámicos de las fuenes aleatorias con distribución
uniforme.
Permite especificar el rango (mínimo y  máximo) de valores que genera
la fuente uniforme
-doc*)

  { TFichaFuenteUniforme }

  TFichaFuenteUniforme = class(TFichaLPD)
  public
    (**************************************************************************)
    (*               A T R I B U T O S   P E R S I S T E N T E S              *)
    (**************************************************************************)

    minimo: NReal;
    maximo: NReal;

    (**************************************************************************)

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      min, max: NReal);
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;

  end;

(*+doc TFuenteUniforme
Genera números aleatorios con distribución uniforme. Utiliza el servicio
de parámetros dinámicos para poder variar el rango en forma dinámica
-doc*)

  { TFuenteUniforme }

  TFuenteUniforme = class(TFuenteAleatoriaConFichas)
  private
    funcion: Tf_ddpUniformeRand3;
  public
    pa: TFichaFuenteUniforme;

    constructor Create(capa: integer; nombre: string;
      xdurPasoDeSorteoEnHoras: integer; ResumirPromediando: boolean;
  lpd: TFichasLPD);
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


//--------------------------------
// Métodos de TFichaFuenteUniforme
//================================

constructor TFichaFuenteUniforme.Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
  min, max: NReal);
begin
  inherited Create(capa, fecha, periodicidad);
  minimo := min;
  maximo := max;
end;

function TFichaFuenteUniforme.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('minimo', minimo);
  Result.addCampoDef('maximo', maximo);
end;

procedure TFichaFuenteUniforme.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteUniforme.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


class function TFichaFuenteUniforme.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteUniforme;
end;

function TFichaFuenteUniforme.infoAd_: string;
begin
  Result := 'Mínimo= ' + FloatToStrF(minimo, ffGeneral, 10, 2) +
    ', ' + 'Máximo= ' + FloatToStrF(maximo, ffGeneral, 10, 2);
end;











//---------------------------
// Métodos de TFuenteUniforme
//===========================

constructor TFuenteUniforme.Create(capa: integer; nombre: string; xdurPasoDeSorteoEnHoras: integer;
  ResumirPromediando: boolean; lpd: TFichasLPD);
begin
  inherited Create(capa, nombre, xdurPasoDeSorteoEnHoras, ResumirPromediando, lpd);
  funcion := nil;
end;

class function TFuenteUniforme.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteUniforme;
end;

{function TFuenteUniforme.infoAd : String;
begin
  result := 'Uniforme'
end;}

class function TFuenteUniforme.DescClase: string;
begin
  Result := rsFuenteUniforme;
end;

procedure TFuenteUniforme.PrepararMemoria(Catalogo: TCatalogoReferencias;
  globs: TGlobs);
begin
  inherited prepararMemoria( Catalogo, globs);
  funcion := Tf_ddpUniformeRand3.Create(sorteadorUniforme, 0);
end;

procedure TFuenteUniforme.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  //Se llama solo despues de preparar memoria que ya expande las fichas
  //no hace falta volver a hacerlo y es un proceso caro si hay periodicidad
  //   lpd.expandirFichas(globs);
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, cambioFichaPDFuenteAleatoria);
end;

procedure TFuenteUniforme.SortearEntradaRB(var aRB: NReal);
begin
  aRB := pa.minimo + funcion.rnd * (pa.maximo - pa.minimo);
end;

procedure TFuenteUniforme.ValorEsperadoEntradaRB(var aRB: NReal);
begin
  aRB := (pa.minimo + pa.maximo) / 2.0;
end;

procedure TFuenteUniforme.Free;
begin
  if funcion <> nil then
    funcion.Free;
  inherited Free;
end;
















procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteUniforme.ClassName, TFuenteUniforme);
  registrarClaseDeCosa(TFichaFuenteUniforme.ClassName, TFichaFuenteUniforme);
end;

procedure AlFinal;
begin
end;

end.
