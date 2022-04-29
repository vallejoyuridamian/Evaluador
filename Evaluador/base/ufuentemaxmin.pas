unit ufuentemaxmin;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  uFuentesAleatorias, ucosa, uCosaConNombre,
  uFichasLPD, xMatDefs, uFechas, SysUtils, Math;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteMaxMin = 'Fuente maxmin';

type

(*+doc TFichaFuenteMaxMin
Ficha de parámetros dinámicos de las fuente maxmin devuelve el maximo (minimo) entre la entrada
y el parámetro dinámico
-doc*)

  { TFichaFuenteMaxMin }

  TFichaFuenteMaxMin = class(TFichaLPD)
  public
    valorBase: NReal;
    esMaximo: boolean;
    fuente: TFuenteAleatoria;
    borne: string;

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      valorBase: NReal; esMaximo: boolean; fuente: TFuenteAleatoria; borne: string);

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;

  end;

(*+doc TFuenteMaxMin
Ficha de parámetros dinámicos de las fuente maxmin devuelve el maximo (minimo) entre la entrada
y el parámetro dinámico
-doc*)

  { TFuenteMaxMin }

  TFuenteMaxMin = class(TFuenteAleatoriaConFichas)
  private
    //Indices de los bornes de las fuentes de entrada. Deben ser
    //actualizados al cambiar la ficha de parametros dinámicos
    iBorne: integer;

  public
    pa: TFichaFuenteMaxMin;

    constructor Create(capa: integer; nombre: string;
      xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean; lpd: TFichasLPD);
    class function TipoFichaFuente: TClaseDeFichaLPD; override;
    class function DescClase: string; override;
    procedure RegistrarParametrosDinamicos( Catalogo: TCatalogoReferencias ); override;
    procedure PrepararPaso_ps; override;
    procedure SortearEntradaRB(var aRB: NReal); override;
    procedure ValorEsperadoEntradaRB(var aRB: NReal); override;

    function referenciaFuente(fuente: TFuenteAleatoria): boolean; override;
  end;

procedure procCambioFichaMaxMin(fuente: TCosa);
procedure AlInicio;
procedure AlFinal;

implementation

//-----------------------------------
// Métodos de TFichaFuenteMaxMin
//===================================

constructor TFichaFuenteMaxMin.Create(capa: integer; fecha: TFecha;
  periodicidad: TPeriodicidad; valorBase: NReal; esMaximo: boolean;
  fuente: TFuenteAleatoria; borne: string);
begin
  inherited Create(capa, fecha, periodicidad);
  self.valorBase := valorBase;
  self.esMaximo := esMaximo;
  self.fuente := fuente;
  self.borne := borne;
end;

function TFichaFuenteMaxMin.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('valorBase', valorBase);
  Result.addCampoDef('esMaximo', esMaximo);
  Result.addCampoDef_ref('fuente', TCosa(fuente), self);
  Result.addCampoDef('borne', borne);
end;

procedure TFichaFuenteMaxMin.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteMaxMin.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


class function TFichaFuenteMaxMin.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteMaxMin;
end;

function TFichaFuenteMaxMin.infoAd_: string;
begin
  Result := 'valorBase= ' + FloatToStrF(valorBase, ffGeneral, 10, 1) +
    ',' + 'esMaximo= ' + BoolToStr(esMaximo) + ',' + 'fuente= ' +
    fuente.nombre + ', ' + 'borne= ' + borne;

end;












//------------------------------
// Métodos de TFuenteMaxMin
//==============================

constructor TFuenteMaxMin.Create(capa: integer; nombre: string;
  xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean; lpd: TFichasLPD);
begin
  inherited Create(capa, nombre, xdurPasoDeSorteoEnHoras, resumirPromediando, lpd);
end;

class function TFuenteMaxMin.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteMaxMin;
end;

class function TFuenteMaxMin.DescClase: string;
begin
  Result := rsFuenteMaxMin;
end;

procedure TFuenteMaxMin.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, procCambioFichaMaxMin);
end;


procedure TFuenteMaxMin.PrepararPaso_ps;
begin
  if (pa.esMaximo) then
    Bornera[0] := Max(pa.fuente.Bornera[iBorne], pa.valorBase)
  else
    Bornera[0] := Min(pa.fuente.Bornera[iBorne], pa.valorBase);
end;

procedure TFuenteMaxMin.SortearEntradaRB(var aRB: NReal);
begin
  aRB := 0;
end;

procedure TFuenteMaxMin.ValorEsperadoEntradaRB(var aRB: NReal);
begin
  aRB := 0;
end;

function TFuenteMaxMin.referenciaFuente(fuente: TFuenteAleatoria): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to lpd.Count - 1 do
  begin
    if (fuente = TFichaFuenteMaxMin(lpd[i]).fuente) then
    begin
      Result := True;
      break;
    end;
  end;
end;

procedure procCambioFichaMaxMin(fuente: TCosa);
begin
  cambioFichaPDFuenteAleatoria(fuente);
  TFuenteMaxMin(fuente).iBorne :=
    TFuenteMaxMin(fuente).pa.fuente.IdBorne(TFuenteMaxMin(fuente).pa.borne);
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteMaxMin.ClassName, TFuenteMaxMin);
  registrarClaseDeCosa(TFichaFuenteMaxMin.ClassName, TFichaFuenteMaxMin);
end;

procedure AlFinal;
begin
end;

end.
