unit uFuenteProducto;

interface

uses
  uFuentesAleatorias, ucosa, uCosaConNombre, uFichasLPD, xMatDefs, uFechas;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteProducto = 'Fuente producto';

type

(*+doc TFichaFuenteProducto
Ficha de parámetros dinámicos de las fuentes producto
Permite especificar fuentes (y bornes) de entrada
-doc*)

  { TFichaFuenteProducto }

  TFichaFuenteProducto = class(TFichaLPD)
  public
    fuenteA: TFuenteAleatoria;
    borneA:  string;
    fuenteB: TFuenteAleatoria;
    borneB:  string;

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      fuenteA, fuenteB: TFuenteAleatoria; borneA, borneB: string);
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;
  end;

(*+doc TFuenteProducto
Genera sus salidas a partir de los valores de 2 fuentes aleatorias fuenteA y
fuenteB multiplicando las salidas de sus bornes
el resultado obtenido en cada borne es
  fuenteA.valor[borneA] * fuenteB.valor[borneB]
-doc*)

  { TFuenteProducto }

  TFuenteProducto = class(TFuenteAleatoriaConFichas)
  private
    //Indices de los bornes de las fuentes de entrada. Deben ser
    //actualizados al cambiar la ficha de parametros dinámicos
    iBorneA, iBorneB: integer;
  public
    pa: TFichaFuenteProducto;

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

procedure procCambioFichaProducto(fuente: TCosa);
procedure AlInicio;
procedure AlFinal;

implementation

//-----------------------------------
// Métodos de TFichaFuenteProducto
//===================================

constructor TFichaFuenteProducto.Create(capa: integer; fecha: TFecha;
  periodicidad: TPeriodicidad; fuenteA, fuenteB: TFuenteAleatoria;
  borneA, borneB: string);
begin
  inherited Create(capa, fecha, periodicidad);
  self.fuenteA := fuenteA;
  self.fuenteB := fuenteB;
  self.borneA := borneA;
  self.borneB := borneB;
end;

function TFichaFuenteProducto.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef_ref('fuenteA', TCosa(fuenteA), self);
  Result.addCampoDef_ref('fuenteB', TCosa(fuenteB), self);
  Result.addCampoDef('borneA', borneA);
  Result.addCampoDef('borneB', borneB);
end;

procedure TFichaFuenteProducto.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteProducto.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;

class function TFichaFuenteProducto.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteProducto;
end;

function TFichaFuenteProducto.infoAd_: string;
begin
  Result := 'fuenteA= ' + fuenteA.nombre + ', ' + 'borneA= ' +
    borneA + ', ' + 'fuenteB= ' + fuenteB.nombre + ', ' + 'borneB= ' + borneB;
end;



//------------------------------
// Métodos de TFuenteProducto
//==============================

constructor TFuenteProducto.Create(capa: integer; nombre: string; lpd: TFichasLPD);
begin
  inherited Create(capa, nombre, 0, True, lpd);
end;

class function TFuenteProducto.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteProducto;
end;

{function TFuenteProducto.InfoAd : String;
begin
  result:= 'Producto';
end;}

class function TFuenteProducto.DescClase: string;
begin
  Result := rsFuenteProducto;
end;

procedure TFuenteProducto.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  //Se llama solo despues de preparar memoria que ya expande las fichas
  //no hace falta volver a hacerlo y es un proceso caro si hay periodicidad
  //   lpd.expandirFichas(globs);
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, procCambioFichaProducto);
end;

(*** ojo, si uno comenta esto queda condenado a que
el producto no se recalcule y si hay una fuente de entrada que cambia
durante la optimización no se refleja en la salida **)
procedure TFuenteProducto.PrepararPaso_ps;
begin
  Bornera[0] := pa.fuenteA.Bornera[iBorneA] * pa.fuenteB.Bornera[iBorneB];
end;

procedure TFuenteProducto.SortearEntradaRB(var aRB: NReal);
begin
  aRB := pa.fuenteA.Bornera[iBorneA] * pa.fuenteB.Bornera[iBorneB];
end;

procedure TFuenteProducto.ValorEsperadoEntradaRB(var aRB: Nreal);
begin
  aRB := pa.fuenteA.Bornera[iBorneA] * pa.fuenteB.Bornera[iBorneB];
end;

function TFuenteProducto.referenciaFuente(fuente: TFuenteAleatoria): boolean;
var
  i: integer;
  res: boolean;
begin
  res := False;
  for i := 0 to lpd.Count - 1 do
  begin
    if (fuente = TFichaFuenteProducto(lpd[i]).fuenteA) or
      (fuente = TFichaFuenteProducto(lpd[i]).fuenteB) then
    begin
      res := True;
      break;
    end;
  end;
  Result := res;
end;

procedure procCambioFichaProducto(fuente: TCosa);
begin
  cambioFichaPDFuenteAleatoria(fuente);
  TFuenteProducto(fuente).iBorneA :=
    TFuenteProducto(fuente).pa.fuenteA.IdBorne(TFuenteProducto(fuente).pa.borneA);
  TFuenteProducto(fuente).iBorneB :=
    TFuenteProducto(fuente).pa.fuenteB.IdBorne(TFuenteProducto(fuente).pa.borneB);
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteProducto.ClassName, TFuenteProducto);
  registrarClaseDeCosa(TFichaFuenteProducto.ClassName, TFichaFuenteProducto);
end;

procedure AlFinal;
begin
end;

end.
