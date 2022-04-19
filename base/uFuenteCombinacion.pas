unit uFuenteCombinacion;

interface

uses
  uFuentesAleatorias, ucosa, uCosaConNombre,
  uFichasLPD, xMatDefs, uFechas, SysUtils;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteDeCombinacion = 'Fuente de combinación';

type

(*+doc TFichaFuenteCombinacion
Ficha de parámetros dinámicos de las fuentes de combinacion
Permite especificar fuentes (y bornes) de entrada y coeficientes para sus valores
-doc*)

  { TFichaFuenteCombinacion }

  TFichaFuenteCombinacion = class(TFichaLPD)
  public
    a, b: NReal;
    fuenteA, fuenteB: TFuenteAleatoria;
    borneA, borneB: string;

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      a, b: NReal; fuenteA, fuenteB: TFuenteAleatoria; borneA, borneB: string);
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;
  end;

(*+doc TFuenteCombinacion
Genera sus salidas a partir de los valores de 2 fuentes aleatorias fuenteA y
fuenteB multiplicandolos por coeficientes a y b
el resultado obtenido en cada borne es
a * fuenteA.valor[borneA] + b * fuenteB.valor[borneB]
-doc*)

  { TFuenteCombinacion }

  TFuenteCombinacion = class(TFuenteAleatoriaConFichas)
  private
    //Indices de los bornes de las fuentes de entrada. Deben ser
    //actualizados al cambiar la ficha de parametros dinámicos
    iBorneA, iBorneB: integer;
  public
    pa: TFichaFuenteCombinacion;

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

procedure procCambioFichaCombinacion(fuente: TCosa);
procedure AlInicio;
procedure AlFinal;

implementation

//-----------------------------------
// Métodos de TFichaFuenteCombinacion
//===================================

constructor TFichaFuenteCombinacion.Create(capa: integer; fecha: TFecha;
  periodicidad: TPeriodicidad; a, b: NReal; fuenteA, fuenteB: TFuenteAleatoria;
  borneA, borneB: string);
begin
  inherited Create(capa, fecha, periodicidad);
  self.a := a;
  self.b := b;
  self.fuenteA := fuenteA;
  self.fuenteB := fuenteB;
  self.borneA := borneA;
  self.borneB := borneB;
end;

function TFichaFuenteCombinacion.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('a', a);
  Result.addCampoDef('b', b);
  Result.addCampoDef_ref('fuenteA', TCosa(fuenteA), self);
  Result.addCampoDef_ref('fuenteB', TCosa(fuenteB), self);
  Result.addCampoDef('borneA', borneA);
  Result.addCampoDef('borneB', borneB);
end;

procedure TFichaFuenteCombinacion.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteCombinacion.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;



class function TFichaFuenteCombinacion.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteDeCombinacion;
end;

function TFichaFuenteCombinacion.infoAd_: string;
begin
  Result := 'a= ' + FloatToStrF(a, ffGeneral, 10, 2) + ', ' +
    'fuenteA= ' + fuenteA.nombre + ', ' + 'borneA= ' + borneA +
    ', ' + 'b= ' + FloatToStrF(b, ffGeneral, 10, 2) + ', ' + 'fuenteB= ' +
    fuenteB.nombre + ', ' + 'borneB= ' + borneB;
end;















//------------------------------
// Métodos de TFuenteCombinacion
//==============================

constructor TFuenteCombinacion.Create(capa: integer; nombre: string; lpd: TFichasLPD);
begin
  inherited Create(capa, nombre, 0, True, lpd);
end;

class function TFuenteCombinacion.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteCombinacion;
end;

{function TFuenteCombinacion.InfoAd : String;
begin
  result:= 'Combinación';
end;}

class function TFuenteCombinacion.DescClase: string;
begin
  Result := rsFuenteDeCombinacion;
end;

procedure TFuenteCombinacion.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  //Se llama solo despues de preparar memoria que ya expande las fichas
  //no hace falta volver a hacerlo y es un proceso caro si hay periodicidad
  //   lpd.expandirFichas(globs);
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, procCambioFichaCombinacion);
end;

procedure TFuenteCombinacion.PrepararPaso_ps;
var
  i: integer;
begin
  for i := 0 to high(bornera) do
    Bornera[i] := pa.a * pa.fuenteA.Bornera[iBorneA] + pa.b *
      pa.fuenteB.Bornera[iBorneB];
end;

procedure TFuenteCombinacion.SortearEntradaRB(var aRB: NReal);
begin
   aRB := pa.a * pa.fuenteA.Bornera[iBorneA] + pa.b * pa.fuenteB.Bornera[iBorneB];
end;

procedure TFuenteCombinacion.ValorEsperadoEntradaRB(var aRB: Nreal);
begin
  aRB := pa.a * pa.fuenteA.Bornera[iBorneA] + pa.b * pa.fuenteB.Bornera[iBorneB];
end;

function TFuenteCombinacion.referenciaFuente(fuente: TFuenteAleatoria): boolean;
var
  i: integer;
  res: boolean;
begin
  res := False;
  for i := 0 to lpd.Count - 1 do
  begin
    if (fuente = TFichaFuenteCombinacion(lpd[i]).fuenteA) or
      (fuente = TFichaFuenteCombinacion(lpd[i]).fuenteB) then
    begin
      res := True;
      break;
    end;
  end;
  Result := res;
end;

procedure procCambioFichaCombinacion(fuente: TCosa);
begin
  cambioFichaPDFuenteAleatoria(fuente);
  TFuenteCombinacion(fuente).iBorneA :=
    TFuenteCombinacion(fuente).pa.fuenteA.IdBorne(TFuenteCombinacion(fuente).pa.borneA);
  if TFuenteCombinacion(fuente).iBorneA < 0 then raise Exception.Create('Error, borne A sin definir en fuente combinación: '+ TFuenteCombinacion(fuente).Nombre );

  TFuenteCombinacion(fuente).iBorneB :=
    TFuenteCombinacion(fuente).pa.fuenteB.IdBorne(TFuenteCombinacion(fuente).pa.borneB);
  if TFuenteCombinacion(fuente).iBorneB < 0 then raise Exception.Create('Error, borne B sin definir en fuente combinación: '+ TFuenteCombinacion(fuente).Nombre );
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteCombinacion.ClassName, TFuenteCombinacion);
  registrarClaseDeCosa(TFichaFuenteCombinacion.ClassName, TFichaFuenteCombinacion);
end;

procedure AlFinal;
begin
end;

end.
