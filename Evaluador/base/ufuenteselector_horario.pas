unit ufuenteselector_horario;

interface

(*+doc
Unidad: ufuenteselector_horario
La idea es que la fuente tenga un conjunto de fuentes de entrada cada una con un filtro
de las horas del día en que será seleccionada para ser copiada a la salida.
-doc*)

uses
  Classes, SysUtils,
  uFuentesAleatorias, ucosa, uCosaConNombre,
  uFichasLPD, xMatDefs, uFechas,
  uauxiliares,
  uglobs;

resourcestring
  rsFichaDe = 'Ficha de';
  rsFuenteSelector_horario = 'Fuente selector horario';

type

  { TFuenteYHorario }

  TFuenteYHorario = class(TCosa)
  public
    (**************************************************************************)
    (* A T R I B U T O S   P E R S I S T E N T E S                            *)
    (**************************************************************************)
    fuente: TFuenteAleatoria;
    idBorne: integer;
    // suponemos un array ordenado de horas por ej {2,4,23}
    horario_FERIADO: TDAOfNInt;
    horario_SEMI_FERIADO: TDAOfNInt;
    horario_HABIL: TDAOfNInt;
    (**************************************************************************)

    constructor Create(xFuente: TFuenteAleatoria; xidBorne: integer; xhorario_HABIL, xhorario_SEMI_FERIADO, xhorario_FERIADO: TDAOfNInt);

     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    function en_horario(h: integer; tipoDeDia: TTipoDeDia): boolean;

  end;

(*+doc TFichaFuenteSelector_horario
Ficha de parámetros dinámicos de las fuentes Selector
Permite especificar fuentes (y bornes) de entrada
-doc*)

  { TFichaFuenteSelector_horario }

  TFichaFuenteSelector_horario = class(TFichaLPD)
  public
    (**************************************************************************)
    (* A T R I B U T O S   P E R S I S T E N T E S                            *)
    (**************************************************************************)
    usarTipoDeDia:                boolean;
    FuentesYHorarios:             TListaDeCosas;
    ValorPorDefecto_HABIL:        NReal;
    ValorPorDefecto_SEMI_FERIADO: NReal;
    ValorPorDefecto_FERIADO:      NReal;
    (**************************************************************************)

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      xusarTipoDeDia: boolean; fuentesYHorarios: TListaDeCosas;
  ValorPorDefecto_HABIL, ValorPorDefecto_SEMI_FERIADO,
  ValorPorDefecto_FERIADO: NReal);
     
    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    class function DescClase: string; override;
    function infoAd_: string; override;
  end;

(*+doc TFuenteSelector_horario
Según la hora de inicio del paso selecciona una de las fuentes de entrada
como salida.
-doc*)

  { TFuenteSelector_horario }

  TFuenteSelector_horario = class(TFuenteAleatoriaConFichas)
    pa: TFichaFuenteSelector_horario;

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

procedure procCambioFichaSelector_horario(fuente: TCosa);
procedure AlInicio;
procedure AlFinal;

implementation


constructor TFuenteYHorario.Create(xFuente: TFuenteAleatoria;
  xidBorne: integer; xhorario_HABIL, xhorario_SEMI_FERIADO,
  xhorario_FERIADO: TDAOfNInt);
begin
  inherited Create;
  fuente := xFuente;
  idBorne := xidBorne;
  horario_FERIADO := xhorario_FERIADO;
  horario_SEMI_FERIADO := xhorario_SEMI_FERIADO;
  horario_HABIL := xhorario_HABIL;
end;

function TFuenteYHorario.Rec: TCosa_RecLnk;
var
  res: TCosa_RecLnk;
begin
  Res:=inherited Rec;
  Res.addCampoDef_ref('fuente', TCosa(fuente), self);
  Res.addCampoDef('idBorne', idBorne);
  Res.addCampoDef('horario_HABIL', horario_HABIL);
  Res.addCampoDef('horario_SEMI_FERIADO', horario_SEMI_FERIADO);
  Res.addCampoDef('horario_FERIADO', horario_FERIADO);
  result:= res;
end;

procedure TFuenteYHorario.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFuenteYHorario.AfterRead(version, id_hilo: integer);
begin
   inherited AfterRead(version, id_hilo);
  // obligo que los horarios esté ordenados.
    QuickSort_Creciente( horario_HABIL);
    QuickSort_Creciente( horario_SEMI_FERIADO );
    QuickSort_Creciente( horario_FERIADO );
end;



function TFuenteYHorario.en_horario(h: integer; tipoDeDia: TTipoDeDia): boolean;
var
  k1, k2, k: integer;
  buscando: boolean;
  horario: TDAOfNInt;
begin

  case TipoDeDia of
    DIA_HABIL: horario := horario_HABIL;
    DIA_SEMI_FERIADO: horario := horario_SEMI_FERIADO;
    DIA_FERIADO: horario := horario_FERIADO;
  end;

  if length( horario ) = 0 then
  begin
    result:= false;
    exit;
  end;

  // busqueda rápida en array ordenado
  buscando := True;
  k1 := 0;
  k2 := high(horario);
  buscando := true;

// writeln( 'TipoD: ', Ord(TipoDeDia), ', k1: ', k1, ', k2: ', k2 );
  if ( horario[k1] <= h ) and (h  <=  horario[k2] ) then
    while buscando and ( k2 >= k1 ) do
    begin
      k := (k1 + k2) div 2;
      if horario[k] = h then
        buscando := False
      else
        if horario[k] > h then
          k2 := k-1
        else
          k1 := k+1;
    end;

  Result := not buscando;
end;


//-----------------------------------
// Métodos de TFichaFuenteSelector_horario
//===================================

constructor TFichaFuenteSelector_horario.Create(capa: integer; fecha: TFecha;
  periodicidad: TPeriodicidad; xusarTipoDeDia: boolean;
  fuentesYHorarios: TListaDeCosas;
  ValorPorDefecto_HABIL, ValorPorDefecto_SEMI_FERIADO, ValorPorDefecto_FERIADO: NReal);

begin
  inherited Create(capa, fecha, periodicidad);
  self.usarTipoDeDia := xusarTipoDeDia;
  self.FuentesYHorarios := fuentesYHorarios;
  self.ValorPorDefecto_HABIL := valorPorDefecto_HABIL;
  self.ValorPorDefecto_SEMI_FERIADO := valorPorDefecto_SEMI_FERIADO;
  self.ValorPorDefecto_FERIADO := valorPorDefecto_FERIADO;
end;

function TFichaFuenteSelector_horario.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('usarTipoDeDia', usarTipoDeDia);
  Result.addCampoDef('FuentesYHorarios', TCosa(FuentesYHorarios));
  Result.addCampoDef('ValorPorDefecto_HABIL', ValorPorDefecto_HABIL);
  Result.addCampoDef('ValorPorDefecto_SEMI_FERIADO', ValorPorDefecto_SEMI_FERIADO);
  Result.addCampoDef('ValorPorDefecto_FERIADO', ValorPorDefecto_FERIADO);
end;

procedure TFichaFuenteSelector_horario.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaFuenteSelector_horario.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


class function TFichaFuenteSelector_horario.DescClase: string;
begin
  Result := rsFichaDe + ' ' + rsFuenteSelector_horario;
end;

function TFichaFuenteSelector_horario.infoAd_: string;
begin
  Result := 'nHorarios: ' + IntToStr(FuentesYHorarios.Count);
end;













//------------------------------
// Métodos de TFuenteSelector
//==============================

constructor TFuenteSelector_horario.Create(capa: integer; nombre: string; lpd: TFichasLPD);
begin
  inherited Create(capa, nombre, 0, True, lpd);
end;

class function TFuenteSelector_horario.TipoFichaFuente: TClaseDeFichaLPD;
begin
  Result := TFichaFuenteSelector_horario;
end;

{function TFuenteSelector_horario.InfoAd : String;
begin
  result:= 'Selector horario';
end;}

class function TFuenteSelector_horario.DescClase: string;
begin
  Result := rsFuenteSelector_horario;
end;

procedure TFuenteSelector_horario.RegistrarParametrosDinamicos(
  Catalogo: TCatalogoReferencias);
begin
  //Se llama solo despues de preparar memoria que ya expande las fichas
  //no hace falta volver a hacerlo y es un proceso caro si hay periodicidad
  //   lpd.expandirFichas(globs);
  lpd.RegistrarFichasAActualizar(Self, globs.ActualizadorLPD, @pa,
    nil, procCambioFichaSelector_horario);
end;

procedure TFuenteSelector_horario.PrepararPaso_ps;
var
  k, n: integer;
  h: integer;
  pfh: TFuenteYHorario;
  tipoDelDia: TTipoDeDia;
  buscando: boolean;

begin
  k := 0;
  n := pa.FuentesYHorarios.Count;
  h := globs.HoraDeInicioDelPaso;

  // si está marcado usar el tipo de día, fijamos el tipo de dia de acuerdo
  // al inicio del paso. Si no, imponemos DIA_HABIL
  if pa.usarTipoDeDia then
    tipoDelDia := globs.TipoDeDiaInicioDelPaso
  else
    tipoDelDia := DIA_HABIL;

  // buscamos el primer filtro horario que contenga la hora de inicio del paso
  buscando := True;
  for k := 0 to n - 1 do
  begin
    pfh := pa.FuentesYHorarios.items[k] as TFuenteYHorario;

    if pfh.en_horario(h, tipoDelDia) then
    begin
      Bornera[0] := pfh.fuente.Bornera[pfh.idBorne];
      buscando := False;
      break;
    end;
  end;

  // si no se activó ningún filtro ponemos el valor por defecto
  if buscando then
    if tipoDelDia = DIA_HABIL then
      Bornera[0] := pa.ValorPorDefecto_HABIL
    else if tipoDelDia = DIA_SEMI_FERIADO then
      Bornera[0] := pa.ValorPorDefecto_SEMI_FERIADO
    else
      Bornera[0] := pa.ValorPorDefecto_FERIADO;
end;

procedure TFuenteSelector_horario.SortearEntradaRB(var aRB: NReal);
begin
  aRB := 0;
end;

procedure TFuenteSelector_horario.ValorEsperadoEntradaRB(var aRB: Nreal);
begin
  aRB := 0;
end;


function TFuenteSelector_horario.referenciaFuente(fuente: TFuenteAleatoria): boolean;
var
  k, n: integer;
  pfh: TFuenteYHorario;
  ficha_pd: TFichaFuenteSelector_horario;
  ificha: integer;
  buscando: Boolean;
begin
  k := 0;
  buscando:= true;
  ificha:=0;
  while ificha < lpd.Count do
  begin
    ficha_pd:= lpd[ificha] as TFichaFuenteSelector_horario;
    n := ficha_pd.FuentesYHorarios.Count;
    for k := 0 to n - 1 do
    begin
      pfh := ficha_pd.FuentesYHorarios.items[k] as TFuenteYHorario;
      if pfh.fuente = fuente then
      begin
        buscando:= false;
        break;
      end;
    end;
    inc( ificha );
  end;
  Result := not buscando;
end;


procedure procCambioFichaSelector_horario(fuente: TCosa);
begin
  cambioFichaPDFuenteAleatoria(fuente);
end;

procedure AlInicio;
begin
  registrarClaseDeCosa(TFuenteYHorario.ClassName, TFuenteYHorario);
  registrarClaseDeCosa(TFuenteSelector_horario.ClassName, TFuenteSelector_horario);
  registrarClaseDeCosa(TFichaFuenteSelector_horario.ClassName,
    TFichaFuenteSelector_horario);
end;

procedure AlFinal;
begin
end;

end.
