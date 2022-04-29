unit uFuenteSelector;

interface

uses
  uFuentesAleatorias, ucosa, uCosaConNombre, uFichasLPD, xMatDefs, uFechas;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteSelector = 'Fuente Selector';

type

(*+doc TFichaFuenteSelector
Ficha de parámetros dinámicos de las fuentes Selector
Permite especificar fuentes (y bornes) de entrada
-doc*)

  { TFichaFuenteSelector }

  TFichaFuenteSelector = class(TFichaLPD)
  public
    (**************************************************************************)
    (* A T R I B U T O S   P E R S I S T E N T E S                            *)
    (**************************************************************************)
    fuenteA: TFuenteAleatoria;
    fuenteB: TFuenteAleatoria;
    fuenteC: TFuenteAleatoria;
    fuenteD: TFuenteAleatoria;
    borneA:  string;
    borneB:  string;
    borneC:  string;
    borneD:  string;
    (**************************************************************************)

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      fuenteA, fuenteB: TFuenteAleatoria; fuenteC, fuenteD: TFuenteAleatoria;
      borneA, borneB: string; borneC, borneD: string);

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;

  end;

(*+doc TFuenteSelector
Genera sus salidas a partir de los valores de 4 fuentes aleatorias
fuenteA , fuenteB, fuenteC y fuente D.
Si ( A > B ) el resultado es C sino es D
-doc*)

  { TFuenteSelector }

  TFuenteSelector = class(TFuenteAleatoriaConFichas)
  private
    //Indices de los bornes de las fuentes de entrada. Deben ser
    //actualizados al cambiar la ficha de parametros dinámicos
    iBorneA, iBorneB: integer;
    iBorneC, iBorneD: integer;
  public
    pa: TFichaFuenteSelector;

    constructor Create(capa: integer; nombre: string; lpd: TFichasLPD);
    class function TipoFichaFuente: TClaseDeFichaLPD; override;
    //function InfoAd : String; override;
    class function DescClase: string; override;
    procedure RegistrarParametrosDinamicos( Catalogo: TCatalogoReferencias ); override;

    procedure PrepararPaso_ps; override;
    procedure SortearEntradaRB(var aRB: NReal); override;
    procedure ValorEsperadoEntradaRB(var aRB: Nreal); override;
    function referenciaFuente(fuente: TFuenteAleatoria): boolean; override;

  end;

procedure procCambioFichaSelector(fuente: TCosa);
procedure AlInicio;
procedure AlFinal;

implementation

//-----------------------------------
// Métodos de TFichaFuenteSelector
//===================================

constructor TFichaFuenteSelector.Create(capa: integer; fecha: TFecha;
  periodicidad: TPeriodicidad; fuenteA, fuenteB: TFuenteAleatoria;
  fuenteC, fuenteD: TFuenteAleatoria; borneA, borneB: string; borneC, borneD: string);
begin
  inherited Create(capa, fecha, periodicidad);
  self.fuenteA := fuenteA;
  self.fuenteB := fuenteB;
  self.fuenteC := fuenteC;
  self.fuenteD := fuenteD;
  self.borneA := borneA;
  self.borneB := borneB;
  self.borneC := borneC;
  self.borneD := borneD;
end;

function TFichaFuenteSelector.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef_ref('fuenteA', TCosa(fuenteA), self);
  Result.addCampoDef_ref('fuenteB', TCosa(fuenteB), self);
  Result.addCampoDef_ref('fuenteC', TCosa(fuenteC), self);
  Result.addCampoDef_ref('fuenteD', TCosa(fuenteD), self);
  Result.addCampoDef('borneA', borneA);
  Result.addCampoDef('borneB', borneB);
  Result.addCampoDef('borneC', borneC);
  Result.addCampoDef('borneD', borneD);
end;

procedure TFichaFuenteSelector.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteSelector.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


class function TFichaFuenteSelector.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteSelector;
end;

function TFichaFuenteSelector.infoAd_: string;
begin
  Result := 'fuenteA= ' + fuenteA.nombre + ', ' + 'borneA= ' +
    borneA + ', ' + 'fuenteB= ' + fuenteB.nombre + ', ' + 'borneB= ' + borneB;
end;
















//------------------------------
// Métodos de TFuenteSelector
//==============================

constructor TFuenteSelector.Create(capa: integer; nombre: string; lpd: TFichasLPD);
begin
  inherited Create(capa, nombre, 0, True, lpd);
end;

class function TFuenteSelector.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteSelector;
end;

{function TFuenteSelector.InfoAd : String;
begin
  result:= 'Selector';
end;}

class function TFuenteSelector.DescClase: string;
begin
  Result := rsFuenteSelector;
end;

procedure TFuenteSelector.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  //Se llama solo despues de preparar memoria que ya expande las fichas
  //no hace falta volver a hacerlo y es un proceso caro si hay periodicidad
  //   lpd.expandirFichas(globs);
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, procCambioFichaSelector);
end;

procedure TFuenteSelector.PrepararPaso_ps;
begin
  if pa.fuenteA.Bornera[iBorneA] > pa.fuenteB.Bornera[iBorneB] then
    Bornera[0] := pa.fuenteC.Bornera[iBorneC]
  else
    Bornera[0] := pa.fuenteD.Bornera[iBorneD];
end;

procedure TFuenteSelector.SortearEntradaRB(var aRB: NReal);
begin
  aRB := 0;
end;

procedure TFuenteSelector.ValorEsperadoEntradaRB(var aRB: Nreal);
begin
  aRB := 0;
end;


function TFuenteSelector.referenciaFuente(fuente: TFuenteAleatoria): boolean;
var
  i: integer;
  res: boolean;
begin
  res := False;
  for i := 0 to lpd.Count - 1 do
  begin
    if (fuente = TFichaFuenteSelector(lpd[i]).fuenteA) or
      (fuente = TFichaFuenteSelector(lpd[i]).fuenteB) or
      (fuente = TFichaFuenteSelector(lpd[i]).fuenteC) or
      (fuente = TFichaFuenteSelector(lpd[i]).fuenteD) then
    begin
      res := True;
      break;
    end;
  end;
  Result := res;
end;

procedure procCambioFichaSelector(fuente: TCosa);
begin
  cambioFichaPDFuenteAleatoria(fuente);
  TFuenteSelector(fuente).iBorneA :=
    TFuenteSelector(fuente).pa.fuenteA.IdBorne(TFuenteSelector(fuente).pa.borneA);
  TFuenteSelector(fuente).iBorneB :=
    TFuenteSelector(fuente).pa.fuenteB.IdBorne(TFuenteSelector(fuente).pa.borneB);
  TFuenteSelector(fuente).iBorneC :=
    TFuenteSelector(fuente).pa.fuenteC.IdBorne(TFuenteSelector(fuente).pa.borneC);
  TFuenteSelector(fuente).iBorneD :=
    TFuenteSelector(fuente).pa.fuenteD.IdBorne(TFuenteSelector(fuente).pa.borneD);
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteSelector.ClassName, TFuenteSelector);
  registrarClaseDeCosa(TFichaFuenteSelector.ClassName, TFichaFuenteSelector);
end;

procedure AlFinal;
begin
end;

end.
