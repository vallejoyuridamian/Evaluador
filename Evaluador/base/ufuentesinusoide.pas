unit ufuentesinusoide;
(*+doc
Implementa una fuente con la función
A * Sin( W * x - FI )
o
A * Cos( W * x - FI )

siendo A, W y FI tres parámetros seleccionables en las fichas dinámicas
al igual que el tipo de función Cos, Sin.

El valor de "x" es tomado del borne de otra fuente.

-doc*)
interface

uses
  uFuentesAleatorias, ucosa, ucosaConNombre, uFichasLPD, xMatDefs, uFechas, SysUtils;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteSinusoide = 'Fuente sinusoide';

type

(*+doc TFichaFuenteSinusoide
Ficha de parámetros dinámicos de las fuente maxmin devuelve la sinusoidal a partir de los parámetros
ingresados
-doc*)

  { TFichaFuenteSinusoide }

  TFichaFuenteSinusoide = class(TFichaLPD)
  public
    (**************************************************************************)
    (* A T R I B U T O S   P E R S I S T E N T E S                            *)
    (**************************************************************************)
    parametroA:   NReal;
    parametroW:   NReal;
    parametroPhi: NReal;
    esCoseno:     boolean;
    fuente:       TFuenteAleatoria;
    borne:        string;
    (**************************************************************************)

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      a, w, phi: NReal; esCoseno: boolean; fuente: TFuenteAleatoria;
  borne: string);
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;
  end;

(*+doc TFuenteSinusoide
Da como resultado la sinusoide de los parámetros de entrada
-doc*)

  { TFuenteSinusoide }

  TFuenteSinusoide = class(TFuenteAleatoriaConFichas)
  private
    //Indices de los bornes de las fuentes de entrada. Deben ser
    //actualizados al cambiar la ficha de parametros dinámicos
    iBorne: integer;

  public
    pa: TFichaFuenteSinusoide;

    constructor Create(capa: integer; nombre: string;
      xdurPasoDeSorteoEnHoras: integer; resumirPromediando: boolean;
  lpd: TFichasLPD);
    class function TipoFichaFuente: TClaseDeFichaLPD; override;
    class function DescClase: string; override;
    procedure RegistrarParametrosDinamicos( Catalogo: TCatalogoReferencias ); override;
    procedure PrepararPaso_ps; override;
    procedure SortearEntradaRB(var aRB: NReal); override;
    procedure ValorEsperadoEntradaRB(var aRB: NReal); override;
  end;

procedure procCambioFichaSinusoide(fuente: TCosa);
procedure AlInicio;
procedure AlFinal;

implementation

//-----------------------------------
// Métodos de TFichaFuenteSinusoide
//===================================

constructor TFichaFuenteSinusoide.Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
  a, w, phi: NReal; esCoseno: boolean; fuente: TFuenteAleatoria; borne: string);

begin
  inherited Create(capa, fecha, periodicidad);
  self.parametroA := a;
  self.parametroW := w;
  self.parametroPhi := phi;
  self.esCoseno := esCoseno;
  self.fuente := fuente;
  self.borne := borne;
end;

function TFichaFuenteSinusoide.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('parametroA', parametroA);
  Result.addCampoDef('parametroW', parametroW);
  Result.addCampoDef('parametroPhi', parametroPhi);
  Result.addCampoDef('esCoseno', esCoseno);
  Result.addCampoDef_ref('fuente', TCosa(fuente), self);
  Result.addCampoDef('borne', borne);
end;

procedure TFichaFuenteSinusoide.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteSinusoide.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;



class function TFichaFuenteSinusoide.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteSinusoide;
end;

function TFichaFuenteSinusoide.infoAd_: string;
begin
  Result := 'parametroA= ' + FloatToStrF(parametroA, ffGeneral, 10, 1) +
    ',' + 'parametroW= ' + FloatToStrF(parametroW, ffGeneral, 10, 1) +
    ',' + 'parametroPhi=' + FloatToStrF(parametroPhi, ffGeneral, 10, 1) +
    ',' + 'esCoseno=' + BoolToStr(esCoseno) + ',' + 'fuente= ' +
    fuente.nombre + ', ' + 'borne= ' + borne;
  ;
end;















//------------------------------
// Métodos de TFuenteSinusoide
//==============================

constructor TFuenteSinusoide.Create(capa: integer; nombre: string; xdurPasoDeSorteoEnHoras: integer;
  resumirPromediando: boolean; lpd: TFichasLPD);
begin
  inherited Create(capa, nombre, xdurPasoDeSorteoEnHoras, resumirPromediando, lpd);
end;

class function TFuenteSinusoide.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteSinusoide;
end;

{function TFuenteTiempo.InfoAd : String;
begin
  result:= 'Tiempo';
end;}

class function TFuenteSinusoide.DescClase: string;
begin
  Result := rsFuenteSinusoide;
end;

procedure TFuenteSinusoide.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  //Se llama solo despues de preparar memoria que ya expande las fichas
  //no hace falta volver a hacerlo y es un proceso caro si hay periodicidad
  //   lpd.expandirFichas(globs);
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, procCambioFichaSinusoide);
end;

procedure TFuenteSinusoide.PrepararPaso_ps;
begin
  if (pa.esCoseno) then
    bornera[0] := pa.parametroA * cos(pa.parametroW * pa.fuente.Bornera[iBorne] -
      pa.parametroPhi)
  else
    bornera[0] := pa.parametroA * sin(pa.parametroW * pa.fuente.Bornera[iBorne] -
      pa.parametroPhi);
end;

procedure TFuenteSinusoide.SortearEntradaRB(var aRB: NReal);
begin
  aRB := 0;
end;

procedure TFuenteSinusoide.ValorEsperadoEntradaRB(var aRB: NReal);
begin
  aRB := 0;
end;


procedure procCambioFichaSinusoide(fuente: TCosa);
begin
  cambioFichaPDFuenteAleatoria(fuente);
  TFuenteSinusoide(fuente).iBorne :=
    TFuenteSinusoide(fuente).pa.fuente.IdBorne(TFuenteSinusoide(fuente).pa.borne);
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteSinusoide.ClassName, TFuenteSinusoide);
  registrarClaseDeCosa(TFichaFuenteSinusoide.ClassName, TFichaFuenteSinusoide);
end;

procedure AlFinal;
begin
end;

end.
