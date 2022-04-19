unit ufuentetiempo;

(*
Implementa una función que retorna las horas transcurridas desde una fecha dada.

*)

interface

uses
  uFuentesAleatorias, ucosa, uCosaConNombre,
  uFichasLPD, xMatDefs, uFechas, uresourcestring,
  sysutils;

type

(*+doc TFichaFuenteTiempo
Ficha de parámetros dinámicos de las fuentes de tiempo permite especificar el tiempo base
-doc*)

  { TFichaFuenteTiempo }

  TFichaFuenteTiempo = class(TFichaLPD)
  public
    (**************************************************************************)
    (* A T R I B U T O S   P E R S I S T E N T E S                            *)
    (**************************************************************************)
    fechaInicial: TFecha;
    (**************************************************************************)

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      fechaIniDinamica: TFecha);
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;
  end;

(*+doc TFuenteTiempo
Da como resultado la diferencia (en horas) de la fecha de simulacion con la fecha del parametro dinamico
-doc*)

  { TFuenteTiempo }

  TFuenteTiempo = class(TFuenteAleatoriaConFichas)
  public
    pa: TFichaFuenteTiempo;

    constructor Create(capa: integer; nombre: string;
      xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean;
  lpd: TFichasLPD);
    class function TipoFichaFuente: TClaseDeFichaLPD; override;
    class function DescClase: string; override;
    procedure RegistrarParametrosDinamicos( Catalogo: TCatalogoReferencias ); override;
    procedure SortearEntradaRB(var aRB: NReal); override;
    procedure ValorEsperadoEntradaRB(var aRB: NReal); override;
    procedure publiVars; override;
  end;

procedure AlInicio;
procedure AlFinal;

implementation

//-----------------------------------
// Métodos de TFichaFuenteTiempo
//===================================

constructor TFichaFuenteTiempo.Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
  fechaIniDinamica: TFecha);
begin
  inherited Create( capa, fecha, periodicidad);
  self.fechaInicial := fechaIniDinamica;
end;

function TFichaFuenteTiempo.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('fechaInicial', fechaInicial);
end;

procedure TFichaFuenteTiempo.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteTiempo.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


class function TFichaFuenteTiempo.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteTiempo;
end;

function TFichaFuenteTiempo.infoAd_: string;
begin
  Result := 'fechaInicial= ' + fechaInicial.AsStr;
end;










//------------------------------
// Métodos de TFuenteTiempo
//==============================

constructor TFuenteTiempo.Create(capa: integer; nombre: string; xdurPasoDeSorteoEnHoras: integer;
  resumirPromediando: boolean; lpd: TFichasLPD);
begin
  inherited Create(capa, nombre, xdurPasoDeSorteoEnHoras, resumirPromediando, lpd);
end;

class function TFuenteTiempo.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteTiempo;
end;

class function TFuenteTiempo.DescClase: string;
begin
  Result := rsFuenteTiempo;
end;

procedure TFuenteTiempo.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa, nil);
end;

procedure TFuenteTiempo.SortearEntradaRB(var aRB: NReal);
begin
  aRB := pa.fechaInicial.HorasHasta(globs.FechaInicioDelpaso);
end;

procedure TFuenteTiempo.ValorEsperadoEntradaRB(var aRB: NReal);
begin
  SortearEntradaRB(aRB);
end;

procedure TFuenteTiempo.publiVars;
begin
  inherited;
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteTiempo.ClassName, TFuenteTiempo);
  registrarClaseDeCosa(TFichaFuenteTiempo.ClassName, TFichaFuenteTiempo);
end;

procedure AlFinal;
begin
end;

end.
