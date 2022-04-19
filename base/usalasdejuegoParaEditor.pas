{xDEFINE PERTURBADO}
{xDEFINE RESTO_MINCOSTO}
unit usalasdejuegoParaEditor;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils,
  usalasdejuego,
  uActores,
  uCosaConNombre,
  xmatdefs,
  ucosa,
  uauxiliares,
  ufechas,
  uDemandas, uGeneradores,
  uArcos,
  uArcoConSalidaProgramable,
  uNodos,
  uUsoGestionable_postizado,
  uComercioInternacional,
  uFuentesAleatorias,
  unodocombustible,
  uArcoCombustible,
  ugsimple_bicombustible,
  uRegasificadora,
  uTSumComb,
  uCombustible,
  uDemandaCombustibleAnioBaseEIndices;

resourcestring
  mesElActor = 'El actor ';
  exNoPerteneceGrupoActores = ' no pertenece a ningun grupo de actores';
  exLaCosaConNombre = 'uSalasDeJuegoParaEditor.addCosaConNombre: La cosa ';
  exNoPerteneceANingunaLista = ' no pertenece a ninguna lista conocida.';

type

  { TRbtEditorSala }

  TRbtEditorSala = class
    CatalogoReferencias: TCatalogoReferencias;

    constructor Create( aSala: TSalaDeJuego );
    procedure Free;

    function getListaDeActor( actor: TCosaConNombre): TListaDeCosasConNombre;

    function addCosaConNombre( actor: TCosaConNombre): boolean;
    //Saca el actor de la sala y libera su memoria
    procedure eliminarActor( var actor: TActor);
    //Saca el actor de la sala sin liberar su memoria
    procedure quitarActor( actor: TActor);

    function nombreRepetido(  cosaConNombreEditando: TCosaConNombre;
      nombre: string): boolean;
    //tipoActor puede ser 'generador', 'demanda', 'arco' o 'nodo', sino se lanza una excepcion
    //retorna true si la lista de actores correspondiente contiene un actor con el mismo nombre
    //que no sea actorEditando. Si actorEditando es nil retorna true si la lista
    //de actores correspondiente conitene un actor con el mismo nombre
    function buscarCosaConNombre( const nombre: string): TCosaConNombre;
    //Resuelve todas las referencias A actores o cosas que se encuentren en la sala.
    //No confundir con resuelve las referencias DE actores en la sala.
    //si eliminarNoEncontradas es false Retorna la cantidad de referencias que no se resolvieron
    //si eliminarNoEncontradas es true, aquellas referencias que no se puedan resolver
    //son ELIMINADAS de la lista de referencias, asignadas a NIL, y la función retorna 0
    function buscarCosaConNombrePorReferencia( const referencia: string): TCosaConNombre;

    function resolverReferenciasContraSala( eliminarNoEncontradas: boolean ): integer;

    //Igual que resolverReferenciasContraSala pero solo resuelve las referencias de cosa
    //function resolverReferenciasDeCosaContraSala(cosa : TCosa ; sala : TSalaDeJuego; eliminarNoEncontradas : boolean) : Integer;

    function demandaFirme: NReal;
    function potenciaFirme: NReal;
    function Clonar_Y_ResolverReferencias( cosaAClonar: TCosa): TCosa;
    function existeReferenciaALaCosaConNombre( cosaConNombre: TCosaConNombre ): boolean;

    procedure SetSala( xSala: TSalaDeJuego );
  protected
      Sala: TSalaDeJuego;

  end;

implementation


function TRbtEditorSala.getListaDeActor( actor: TCosaConNombre): TListaDeCosasConNombre;
var
  lista: TListaDeCosasConNombre;
begin
  if actor is TGenerador then
    lista := sala.gens
  else if actor is TDemanda then
    lista := sala.dems
  else if actor is TNodo then
    lista := sala.nods
  else if actor is TArco then
    lista := sala.arcs
  else if actor is TArcoConSalidaProgramable then
    lista := sala.arcs
  else if (actor is TComercioInternacional) then
    lista := sala.comercioInternacional
  else if actor is TUsoGestionable_postizado then
    lista := sala.usosGestionables
  else if (actor is TNodoCombustible) or (actor is TArcoCombustible) or
    (actor is TGSimple_BiCombustible) or (actor is TSuministroCombustible) or
    (actor is TSuministroSimpleCombustible) or (actor is TRegasificadora) or
    (actor is TDemandaCombustibleAnioBaseEIndices) then
    lista := sala.Sums
  else
    raise Exception.Create(exLaCosaConNombre + actor.ClaseNombre +
      exNoPerteneceANingunaLista);
  Result := Lista;
end;


function TRbtEditorSala.addCosaConNombre( actor: TCosaConNombre): boolean;
var
  aux: integer;
  lista: TListaDeCosasConNombre;
begin
  if actor is TFuenteAleatoria then
  begin // si es una fuente la agregamos a la lista de fuentes
    lista := sala.listaFuentes_;
    if not lista.find(actor.nombre, aux) then
    begin
      lista.Add(actor);
      Result := True;
    end
    else
      Result := False;
  end
  else if actor is TCombustible then
  begin
    lista := sala.listaCombustibles;
    if not lista.find(actor.nombre, aux) then
    begin
      lista.Add(actor);
      Result := True;
    end
    else
      Result := False;
  end
  else
  begin

    lista := getListaDeActor(Actor);
    if not lista.find(actor.nombre, aux) then
    begin
      lista.Add(actor);
      sala.listaActores.Add(actor);
      Result := True;
    end
    else
      Result := False;
  end;
end;

procedure TRbtEditorSala.eliminarActor(var actor: TActor);
var
  lista: TListaDeCosas;
begin
  lista := getListaDeActor( actor);
  lista.Remove(actor);
  sala.listaActores.Remove(actor);
  actor.Free;
end;

procedure TRbtEditorSala.quitarActor(actor: TActor);
var
  lista: TListaDeCosas;
begin
  lista := getListaDeActor( actor);
  lista.Remove(actor);
  sala.listaActores.Remove(actor);
end;

function TRbtEditorSala.nombreRepetido( cosaConNombreEditando: TCosaConNombre; nombre: string): boolean;
var
  i, posCosa: integer;
  b: string;
  AcosaConNombreEditando: TCosaConNombre;
  c: boolean;
begin
  posCosa := -1;

  for i := 0 to sala.listaActores.Count - 1 do
    if (sala.listaActores[i] <> cosaConNombreEditando) and
      (TActor(sala.listaActores[i]).nombre = nombre) then
    begin
      posCosa := i;
      break;
    end;

  if posCosa = -1 then
  begin
    for i := 0 to sala.listaFuentes_.Count - 1 do
    begin
      b := TFuenteAleatoria(sala.listaFuentes_[i]).nombre;
      AcosaConNombreEditando := sala.listaFuentes_[i];
      c := AcosaConNombreEditando = cosaConNombreEditando;
      if (sala.listaFuentes_[i] <> cosaConNombreEditando) and
        (TFuenteAleatoria(sala.listaFuentes_[i]).nombre = nombre) then
      begin
        posCosa := i;
        break;
      end;
      //TODO faltan los monitores
    end;
  end;

  if posCosa = -1 then
    for i := 0 to sala.listaCombustibles.Count - 1 do
      if (sala.listaCombustibles[i] <> cosaConNombreEditando) and
        (TCombustible(sala.listaCombustibles[i]).nombre = nombre) then
      begin
        posCosa := i;
        break;
      end;

  Result := posCosa <> -1;
end;

function TRbtEditorSala.buscarCosaConNombre( const nombre: string): TCosaConNombre;
var
  cosa: TCosaConNombre;
begin
  if sala.globs.nombre = nombre then
    cosa := sala.globs
  else
  begin
    cosa := sala.listaActores.find(nombre);
    if cosa = nil then
      cosa := sala.listaFuentes_.find(nombre);
  end;
  Result := cosa;
end;

function TRbtEditorSala.buscarCosaConNombrePorReferencia(
  const referencia: string): TCosaConNombre;
var
  cosa: TCosaConNombre;
  clase, nombre: string;
begin
  parsearReferencia(referencia, clase, nombre);

  if (sala.globs.nombre = nombre) and (sala.globs.ClassName = clase) then
    cosa := sala.globs
  else
  begin
    cosa := sala.listaActores.find(nombre);
    if cosa = nil then
      cosa := sala.listaFuentes_.find(nombre);
  end;
  Result := cosa;
end;

function TRbtEditorSala.resolverReferenciasContraSala(
  eliminarNoEncontradas: boolean): integer;
var
  lstGlobs: TListaDeCosasConNombre;
  res: integer;
begin
  if CatalogoReferencias.referenciasSinResolver > 0 then
  begin
    lstGlobs := TListaDeCosasConNombre.Create(0, 'Aux');
    lstGlobs.Add(sala.globs);

    CatalogoReferencias.resolver_referencias(lstGlobs);

    if Assigned(sala.listaActores) then
      CatalogoReferencias.resolver_referencias(sala.listaActores);
    if Assigned(sala.listaCombustibles) then
      CatalogoReferencias.resolver_referencias(sala.listaCombustibles);

    if Assigned(sala.listaFuentes_) then
      res := CatalogoReferencias.resolver_referencias(sala.listaFuentes_);

    lstGlobs.FreeSinElemenentos;

    if eliminarNoEncontradas then
      CatalogoReferencias.LimpiarReferencias;

    Result := res;
  end
  else
    Result := 0;
end;

{function resolverReferenciasDeCosaContraSala(cosa : TCosa ; sala : TSalaDeJuego; eliminarNoEncontradas : boolean) : Integer;
var
  cosasEnLaSala : TListaDeCosasConNombre;
  i, n, refsSinResolver : Integer;
begin
  if uCosaConNombre.referenciasSinResolver > 0 then
  begin
    cosasEnLaSala:= TListaDeCosasConNombre.Create('Aux');
    n:= sala.listaActores.Count +
        sala.listaFuentes.Count +
        sala.Funcs.Count;
    cosasEnLaSala.Capacity:= n;
    for i:= 0 to sala.listaActores.Count - 1 do
      cosasEnLaSala.Add(TActor(sala.listaActores[i]));
    for i:= 0 to sala.listaFuentes.Count - 1 do
      cosasEnLaSala.Add(TFuenteAleatoria(sala.listaFuentes[i]));
    for i := 0 to sala.funcs.Count - 1 do
      cosasEnLaSala.Add(TFuncion(sala.Funcs[i]));
//    if cosa is TCosaConNombre then
//      cosasEnLaSala.Add(TCosaConNombre(cosa));
    refsSinResolver:= uCosaConNombre.resolver_referenciasDeCosa(cosa, cosasEnLaSala);
    cosasEnLaSala.FreeSinElemenentos;
    if eliminarNoEncontradas then
      uCosaConNombre.eliminar_referencias_del(cosa);

    result:= refsSinResolver;
  end
  else
    Result:= 0;
end;}

function TRbtEditorSala.demandaFirme: NReal;
var
  i: integer;
  resultado: NReal;
begin
  resultado := 0;
  if sala.dems.Count > 0 then
  begin
    for i := 0 to sala.dems.Count - 1 do
      resultado := resultado + (sala.dems[i] as TActor).potenciaFirme;
  end;
  Result := resultado;
end;

function TRbtEditorSala.potenciaFirme: NReal;
var
  i: integer;
  resultado: NReal;
begin
  resultado := 0;
  for i := 0 to sala.gens.Count - 1 do
    resultado := resultado + (sala.gens[i] as TGenerador).potenciaFirme;
  Result := resultado;
end;

function TRbtEditorSala.Clonar_Y_ResolverReferencias(
  cosaAClonar: TCosa): TCosa;
var
  aux: TCosa;
begin
  assert(CatalogoReferencias.referenciasSinResolver = 0);
  aux := cosaAClonar.Create_Clone(CatalogoReferencias, 0);
  resolverReferenciasContraSala(False);
  assert(CatalogoReferencias.referenciasSinResolver = 0);
  Result := aux;
end;

function TRbtEditorSala.existeReferenciaALaCosaConNombre(cosaConNombre: TCosaConNombre): boolean;
var
  salaAux: TSalaDeJuego;
  res: boolean;
begin
  assert(CatalogoReferencias.referenciasSinResolver = 0,
    'usalasdejuegoParaEditor.existeReferenciaALaCosaConNombre: quedan referencias sin resolver en la sala');
  salaAux := TSalaDeJuego(sala.Create_Clone(CatalogoReferencias, 0));
  res := CatalogoReferencias.existeReferencia_al(cosaConNombre);
  salaAux.Free;
  CatalogoReferencias.LimpiarReferencias;
  Result := res;
end;

procedure TRbtEditorSala.SetSala(xSala: TSalaDeJuego);
begin
  sala:= xsala;
  sala.rbtEditor:= self;
end;

constructor TRbtEditorSala.Create(aSala: TSalaDeJuego);
begin
  inherited Create;
  sala:= aSala;
  CatalogoReferencias := TCatalogoReferencias.Create;
end;

procedure TRbtEditorSala.Free;
begin
  CatalogoReferencias.Free;
  inherited Free;
end;

end.
