unit uranddispos;

interface

uses
  xMatDefs, fddp;

{
rndDispo_RotRep implementa la máquina de estados de una variable booleanda que en el
estado TRUE representa una unidad o máquina en estado Disponible y en estado FALSE
repesenta la unidad Rota.
pRot y pRep son las probabilidades de Rotura y Reparación dado que el estado es
TRUE o FALSE respectivamente.

 si Estado = TRUE retorna FALSE con prob. pRot (y TRUE con 1-pRot)
 si Estado = FALSE retorna TRUE con prob. pRep (y FALSE con prob. 1-pRep)
}
function rndDispo_RotRep(Estado: boolean; pRep, pRot: NReal;
  const sorteadorUniforme: TMadreUniforme): boolean;

{
rndDispo_fd
retorna true con probabilidad fd (Factor de Disponibilidad )
}
function rndDispo_fd(fd: NReal; const sorteadorUniforme: TMadreUniforme): boolean;


{
llama NMaquinas=NMaquinas_OK+NMaquinas_Rotas veces a rndDispo_RotRepñ y retorna
en NMaquias_OK la cantidad de TRUE y en NMaquinas_Rotas la cantidad de FALSE
obtenidos.
}
procedure rndDispoNMaquinas_RotRep(var NMaquinas_OK, NMaquinas_Rotas: integer;
  pRep, pRot: NReal; const sorteadorUniforme: TMadreUniforme);

{
llama NMaquinas=NMaquinas_OK+NMaquinas_Rotas veces a rndDispo_fd y retorna
en NMaquias_OK la cantidad de TRUE y en NMaquinas_Rotas la cantidad de FALSE
obtenidos.
}
procedure rndDispoNMaquinas_fd(fdispo: NReal; var NMaquinas_OK, NMaquinas_Rotas: integer; const sorteadorUniforme: TMadreUniforme);



procedure Calc_pRep_pRot(var UsarSorteoEstatico: boolean; var pRep, pRot: NReal;
  fDispo, TMrep_h, PasoSorteo_h: NReal);


implementation


procedure Calc_pRep_pRot(var UsarSorteoEstatico: boolean; var pRep, pRot: NReal;
  fDispo, TMrep_h, PasoSorteo_h: NReal);
begin
  if (TMRep_h > PasoSorteo_h) and (fDispo > AsumaCero) then
  begin
    UsarSorteoEstatico := False;
    pRep := PasoSorteo_h / TMRep_h;
    pRot := pRep * (1 / fDispo - 1);
    if pRot < 1 then
      exit;
  end;

  // aqui llego o por TMRep > PasoSorteo o fDispo <= AsumaCero
  // o pRot >= 1
  // en estos casos mejor usar el modelo estático de sorteos.
  UsarSorteoEstatico := True;
  pRep := fDispo;
  pRot := 1 - fDispo;
end;


function rndDispo_RotRep(Estado: boolean; pRep, pRot: NReal;
  const sorteadorUniforme: TMadreUniforme): boolean;
begin
  if Estado then
    Result := sorteadorUniforme.rnd >= pRot
  else
    Result := sorteadorUniforme.rnd < pRep;
end;



function rndDispo_fd(fd: NReal; const sorteadorUniforme: TMadreUniforme): boolean;
begin
  Result := sorteadorUniforme.rnd < fd;
end;




procedure rndDispoNMaquinas_RotRep(var NMaquinas_OK, NMaquinas_Rotas: integer;
  pRep, pRot: NReal; const sorteadorUniforme: TMadreUniforme);

var
  k: integer;
  cnt_Rot, cnt_Rep: integer;
begin
  cnt_Rot := 0;
  for k := 1 to NMaquinas_OK do
  begin
    if not rndDispo_RotRep( True, pRep, pRot, sorteadorUniforme) then
      Inc(cnt_Rot);
  end;

  cnt_Rep := 0;
  for k := 1 to NMaquinas_Rotas do
  begin
    if rndDispo_RotRep( False, pRep, pRot, sorteadorUniforme) then
      Inc(cnt_Rep);
  end;
  NMaquinas_OK := NMaquinas_OK - cnt_Rot + cnt_Rep;
  NMaquinas_Rotas := NMaquinas_Rotas - cnt_Rep + cnt_Rot;
end;


procedure rndDispoNMaquinas_fd(fdispo: NReal; var NMaquinas_OK, NMaquinas_Rotas: integer; const sorteadorUniforme: TMadreUniforme);

var
  k: integer;
  cnt: integer;
  NMaquinas: integer;
begin
  NMaquinas:= NMaquinas_OK + NMaquinas_Rotas;
  cnt := 0;
  for k := 1 to NMaquinas do
  begin
    if rndDispo_fd(fDispo, sorteadorUniforme) then
      Inc(cnt);
  end;

  NMaquinas_OK := cnt;
  NMaquinas_RotaS:= NMaquinas - cnt;
end;



end.
