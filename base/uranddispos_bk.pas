unit uranddispos;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface
uses
	xMatDefs, fddp;

// retorna true con probabilidad fdispo
function rndDispo( fdispo: NReal;
  EstadoAnterior: boolean;
  pRep, pRot: NReal; SorteoEstatico: boolean;
  const sorteadorUniforme: TMadreUniforme ): boolean;

// llama NMaquinas veces a rndDispo(fdispo) y retorna la cantidad de veces
// que el resultado fue true
function rndDispoNMaquinas(
  fdispo: NReal; NMaquinas: integer;
  EstadoAnterior_NMaquinas: integer;
  pRep, pRot: NReal; SorteoEstatico: boolean;
  const sorteadorUniforme: TMadreUniforme ): integer;

//function rndUniform01: NReal;

procedure Calc_pRep_pRot(var UsarSorteoEstatico: boolean; var pRep, pRot: NReal; fDispo, TMrep_h, PasoSorteo_h: NReal );


implementation


procedure Calc_pRep_pRot(var UsarSorteoEstatico: boolean; var pRep, pRot: NReal; fDispo, TMrep_h, PasoSorteo_h: NReal );
begin
  if (TMRep_h > PasoSorteo_h) and ( fDispo > AsumaCero ) then
  begin
    UsarSorteoEstatico:= false;
    pRep:= PasoSorteo_h / TMRep_h;
    pRot:= pRep * (1 / fDispo -1 );
    if pRot < 1 then exit;
  end;

// aqui llego o por TMRep > PasoSorteo o fDispo <= AsumaCero
// o pRot >= 1
// en estos casos mejor usar el modelo estático de sorteos.
  UsarSorteoEstatico:= true;
  pRep:= fDispo;
  pRot:= 1-fDispo;
end;


//function rndUniform01: NReal;
//begin
//	result:= fddp.random;
//end;

function rndDispo(
  fdispo: NReal;
  EstadoAnterior: boolean;
  pRep, pRot: NReal;
  SorteoEstatico: boolean;
  const sorteadorUniforme: TMadreUniforme ): boolean;
begin
  if SorteoEstatico then
  	result:= sorteadorUniforme.rnd < fdispo
  else
    if EstadoAnterior then
      result:= sorteadorUniforme.rnd >= pRot
    else
      result:= sorteadorUniforme.rnd < pRep;
end;

// llama NMaquinas veces a rndDispo(fdispo) y retorna la cantidad de veces
// que el resultado fue true
function rndDispoNMaquinas(
  fdispo: NReal;
  NMaquinas: integer;
  EstadoAnterior_NMaquinas: integer;
  pRep, pRot: NReal; SorteoEstatico: boolean;
  const sorteadorUniforme: TMadreUniforme ): integer;

var
	k: integer;
	cnt: integer;
begin
	cnt:= 0;
  if NMaquinas < EstadoAnterior_NMaquinas then
    EstadoAnterior_NMaquinas:= NMaquinas;

	for k:= 1 to EstadoAnterior_NMaquinas do
	begin
		if rndDispo( fDispo, true, pRep, pRot, SorteoEstatico, sorteadorUniforme ) then
			inc( cnt );
	end;
  for k:= 1 to NMaquinas - EstadoAnterior_NMaquinas do
	begin
		if rndDispo( fDispo, false, pRep, pRot, SorteoEstatico, sorteadorUniforme ) then
			inc( cnt );
	end;
	result:= cnt;
end;



end.
