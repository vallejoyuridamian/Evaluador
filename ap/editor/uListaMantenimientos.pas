unit uListaMantenimientos;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
Classes, uCosaConNombre, uInfoTabs, SysUtils, Math,
    {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  uactores, uunidades,
  uauxiliares, xmatdefs, ufechas;

type
  TNodoListaMantenimientos = class
    public
      actor: TActor;
      fichaUnidades: TFichaUnidades;
      Constructor Create(actor: TActor; fichaUnidades: TFichaUnidades);
  end;



  TListaMantenimientos = class(TList)
    public
      procedure Init(listaActores: TListaDeCosasConNombre);
      procedure addActor(actor: TActor);
      function addInOrderByActorYFecha(actor: TActor; fichaUnidades: TFichaUnidades): Integer;
      function addInOrderByFecha(actor: TActor; fichaUnidades: TFichaUnidades): Integer;
      procedure sortByActorYFecha;
      procedure sortByFecha;
      procedure writeToText;

      //Devuelve un vector con los nombres de los actores y tamaño maximo especificado
      function getActorNameVector(tamanioMaximoVector: integer): TDAofString;

      //Dado actores y una fecha, dice si esta disponible
      procedure buscarDisponibilidad(nombreActor: string; fechaBuscada: TFecha; var esta: boolean);
      procedure FreeConElementos;
  end;

function compareActorYFecha(item1, item2: Pointer): Integer;
function compareFecha(item1, item2: Pointer): Integer;
function compareNombreActorYFecha(item1, item2: Pointer): Integer;

implementation

function compareActorYFecha(item1, item2: Pointer): Integer;
var
  ordinal1, ordinal2, res: Integer;
begin
  ordinal1:= uInfoTabs.infoTabs_.ordinalTipoActor(TNodoListaMantenimientos(item1).actor.ClassType);
  ordinal2:= uInfoTabs.infoTabs_.ordinalTipoActor(TNodoListaMantenimientos(item2).actor.ClassType);

  if ordinal1 < ordinal2 then
    result:= -1
  else if ordinal1 = ordinal2 then
  begin
    res:= CompareStr(TNodoListaMantenimientos(item1).actor.nombre, TNodoListaMantenimientos(item2).actor.nombre);
    if res = 0 then
      result:= TNodoListaMantenimientos(item1).fichaUnidades.fecha.EsMayorQue(TNodoListaMantenimientos(item2).fichaUnidades.fecha)
    else
      result:= res;
  end
  else
    result:= 1;
end;

function compareFecha(item1, item2: Pointer): Integer;
begin
  result:= TNodoListaMantenimientos(item1).fichaUnidades.fecha.EsMayorQue(TNodoListaMantenimientos(item2).fichaUnidades.fecha);
end;

function compareNombreActorYFecha(item1, item2: Pointer): Integer;
var
  res: Integer;
begin
  res:= CompareStr(TNodoListaMantenimientos(item1).actor.nombre, TNodoListaMantenimientos(item2).actor.nombre);
  if res = 0 then
    result:= TNodoListaMantenimientos(item1).fichaUnidades.fecha.EsMayorQue(TNodoListaMantenimientos(item2).fichaUnidades.fecha)
  else
    result:= res;
end;

Constructor TNodoListaMantenimientos.Create(actor: TActor; fichaUnidades: TFichaUnidades);
begin
  inherited Create;
  self.actor:= actor;
  self.fichaUnidades:= fichaUnidades;
end;

procedure TListaMantenimientos.Init(listaActores: TListaDeCosasConNombre);
var
  i: Integer;
  actor: TActor;
begin
  for i := 0 to Count - 1 do
    TNodoListaMantenimientos(Items[i]).Free;

  Count := 0;
  for i := 0 to listaActores.Count - 1 do
  begin
    actor := TActor(listaActores[i]);
    addActor( actor );
  end;
end;

procedure TListaMantenimientos.addActor(actor: TActor);
var
  i: Integer;
begin
  for i:= 0 to actor.lpdUnidades.Count - 1 do
    Add(TNodoListaMantenimientos.Create(actor, TFichaUnidades(actor.lpdUnidades[i])))
end;

function TListaMantenimientos.addInOrderByActorYFecha(actor: TActor; fichaUnidades: TFichaUnidades): Integer;
var
  nodo: TNodoListaMantenimientos;
  i: Integer;
begin
  nodo:= TNodoListaMantenimientos.Create(actor, fichaUnidades);
  i:= 0;
  while (i < Count) and
        (compareNombreActorYFecha(nodo, Items[i]) = 1)  do
    i:= i + 1;
  Insert(i, nodo);
  result:= i;
end;

function TListaMantenimientos.addInOrderByFecha(actor: TActor; fichaUnidades: TFichaUnidades): Integer;
var
  nodo: TNodoListaMantenimientos;
  i: Integer;
begin
  nodo:= TNodoListaMantenimientos.Create(actor, fichaUnidades);
  i:= 0;
  while (i < Count) and
        (compareFecha(nodo, Items[i]) = 1)  do
    i:= i + 1;
  Insert(i, nodo);
  result:= i;
end;

procedure TListaMantenimientos.sortByActorYFecha;
begin
  Sort(compareNombreActorYFecha);
end;

procedure TListaMantenimientos.sortByFecha;
begin
  sort(compareFecha);
end;

procedure TListaMantenimientos.writeToText;
var
  aux: TNodoListaMantenimientos;
  i: Integer;
  archivoSalida : TextFile;
begin
  AssignFile(archivoSalida, 'Mantenimientos.xlt');
  ReWrite(archivoSalida);

  writeln(archivoSalida, 'La cantidad de mantenimientos es de :' + #9, Count);

  for i := 0 to Count - 1 do
  begin
    aux := TNodoListaMantenimientos(Items[i]);
    Writeln( archivoSalida,
             aux.actor.nombre + #9 +
             aux.actor.DescClase + #9 +
             aux.fichaUnidades.fecha.AsStr + #9 +
             IntToStr(aux.fichaUnidades.nUnidades_Instaladas[0]) + #9 +
             IntToStr(aux.fichaUnidades.nUnidades_EnMantenimiento[0]) + #9 +
             boolToSiNo(aux.fichaUnidades.periodicidad <> nil));
  end;

  CloseFile(archivoSalida);

end;

function TListaMantenimientos.getActorNameVector(tamanioMaximoVector: integer): TDAofString;
var
  aux: TNodoListaMantenimientos;
  i, cantidadMantenimientos: Integer;
  nombreAnterior: String;
  vectorNombres: TDAofString;
  noTerminar: boolean;

begin
  nombreAnterior := '';
  cantidadMantenimientos := 0;
  SetLength(vectorNombres, min(tamanioMaximoVector, Count));
  noTerminar := true;
  i := 0;


  //Cuento cuantos mantenimientos hay
  while((noTerminar) AND (i<Count) ) DO
  begin
    aux := TNodoListaMantenimientos(Items[i]);

    if (aux.actor.nombre <> nombreAnterior) then
    begin

      vectorNombres[cantidadMantenimientos] := aux.actor.nombre;
      nombreAnterior := aux.actor.nombre;
      cantidadMantenimientos := cantidadMantenimientos + 1;

      if (cantidadMantenimientos = tamanioMaximoVector) then
         noTerminar := false;

    end;

    i := i+1;

  end;

  //Debug
  //for i := 0 to Length(vectorNombres) -1 do
  //begin
  //  writeln('El nombre de la posicion ', i, ' es: ', vectorNombres[i]);
  //end;

  result := vectorNombres;

end;

procedure TListaMantenimientos.buscarDisponibilidad(nombreActor: string; fechaBuscada: TFecha; var esta: boolean);
var
  i: integer;
  aux: TNodoListaMantenimientos;
begin
  for i:= 0 to Count -1 do
  begin
    aux := TNodoListaMantenimientos(Items[i]);
    if (aux.actor.nombre = nombreActor) then
    begin
      //No me importan las fechas que vienen dsps sino las q estan antes
      //Como estan ordenadas, siempre me voy a quedar con la anterior a la fecha que busco
      if (fechaBuscada.mayorQue(aux.fichaUnidades.fecha)) then
        if (aux.fichaUnidades.nUnidades_Operativas[0] > 0) then
          esta := true
        else
          esta := false;
    end;
  end; //end busqueda
end;


procedure TListaMantenimientos.FreeConElementos;
var
  i: Integer;
begin
  for i:= 0 to Count - 1 do
    TNodoListaMantenimientos(Items[i]).Free;
  inherited Free;
end;


end.
