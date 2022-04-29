unit uFuenteConstante;

interface

uses
  Classes, uFichasLPD, xMatDefs, uFechas,
  uCosa, uCosaConNombre, uGlobs, uconstantesSimSEE,
  uFuentesAleatorias, SysUtils;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteConstante = 'Fuente constante';

type

(*+doc TFichaFuenteConstante
Ficha de parámetros dinámicos para la fuente constante.
Permite especificar el valor constante.
-doc*)

  { TFichaFuenteConstante }

  TFichaFuenteConstante = class(TFichaLPD)
  public
    valor: NReal;
    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      valor: NReal);
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;
    class function DescClase: string; override;
    function infoAd_: string; override;
  end;

(*+doc TFuenteConstante
Esta no es una fuente aleatoria propiamente dicha, pues su valor es "constante"
en el sentido que no sale de un sorteo. El valor puede ser variado con el servicio
de parámetros dinámicos.
-doc*)

  { TFuenteConstante }

  TFuenteConstante = class(TFuenteAleatoriaConFichas)
  public
    pa: TFichaFuenteConstante;

    constructor Create(capa: integer; nombre: string; xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean; lpd: TFichasLPD);

    class function TipoFichaFuente: TClaseDeFichaLPD; override;
    //function InfoAd : String; override;
    class function DescClase: string; override;
    procedure RegistrarParametrosDinamicos(CatalogoReferencias: TCatalogoReferencias); override;
    procedure SortearEntradaRB(var aRB: NReal); override;
    procedure ValorEsperadoEntradaRB(var aRB: NReal); override;

  end;

procedure AlInicio;
procedure AlFinal;


implementation

//---------------------------------
// Métodos de TFichaFuenteConstante
//=================================

constructor TFichaFuenteConstante.Create(capa: integer; fecha: TFecha;
  periodicidad: TPeriodicidad; valor: NReal);
begin
  inherited Create(capa, fecha, periodicidad);
  self.valor := valor;
end;

function TFichaFuenteConstante.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  result.addCampoDef( 'valor', valor );
end;

procedure TFichaFuenteConstante.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteConstante.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;



class function TFichaFuenteConstante.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteConstante;
end;


function TFichaFuenteConstante.infoAd_: string;
begin
  Result := inherited infoAd_+'V:' + FloatToStrF(valor, ffGeneral, 10, 2);
end;



//----------------------------
// Métodos de TFuenteConstante
//============================

constructor TFuenteConstante.Create(capa: integer; nombre: string;
  xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean; lpd: TFichasLPD);

begin
  inherited Create(
    capa,
    nombre,
    xdurPasoDeSorteoEnHoras,
    resumirPromediando,
    lpd);
  pa := nil;
end;

class function TFuenteConstante.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteConstante;
end;

{function TFuenteConstante.infoAd : String;
begin
  result := 'Constante';
end;}

class function TFuenteConstante.DescClase: string;
begin
  Result := rsFuenteConstante;
end;


procedure TFuenteConstante.RegistrarParametrosDinamicos(
  CatalogoReferencias: TCatalogoReferencias);
begin
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, cambioFichaPDFuenteAleatoria);
end;

procedure TFuenteConstante.SortearEntradaRB(var aRB: NReal);
begin
  if not entradasFijadas then
  begin
    aRB := pa.valor;
    entradasFijadas := True;
  end;
end;

procedure TFuenteConstante.ValorEsperadoEntradaRB(var aRB: NReal);
begin
  SortearEntradaRB(aRB);
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteConstante.ClassName, TFuenteConstante);
  registrarClaseDeCosa(TFichaFuenteConstante.ClassName, TFichaFuenteConstante);
end;

procedure AlFinal;
begin
end;

end.
