unit uFuncionesRealesExtra;

interface

uses
  Math,
  SysUtils, Classes, xmatdefs,
  uglobs,
  ufichasLPD,
  ufechas,
  ucosa, uranddispos,
  uconstantesSimSEE,
  uFuentesAleatorias,
  ufuncionesreales;

type
  TFId = class(TFRenR)
  public
    constructor Create;
    function fval(x: NReal): NReal; override;
  end;

  TFf_xmult_conselector_N_salto = class(TFRenR)
  public
    salto: integer;
    f: TFRenR;
    xmult: TDAOfNreal;
    pSelector: PWord;
    iFiltro: integer;
    pMatchFiltro: PDAOfNInt;
    ipMatchFiltro: PWord;
    aMult: NReal;

    constructor Create(capa: integer; salto: integer; f: TFRenR;
      xxMult: TDAOfNreal; aMult: NReal; xpSelector: PWord; iFiltro: integer;
      pMatchFiltro: PDAOfNInt; ipMatchFiltro: PWord);

    function fval(x: NReal): NReal; override;
  end;

  TFf_xmult_N_salto = class(TFRenR)
  public
    salto: integer;
    f: TFRenR;
    xmult: TDAOfNreal;
    pSelector: PWord;
    aMult: NReal;

    constructor Create(capa: integer; salto: integer; f: TFRenR;
      xxMult: TDAOfNreal; aMult: NReal; xpSelector: PWord);

    function fval(x: NReal): NReal; override;
  end;

  TFf_promedioSalto_N_poste = class(TFRenR)
  public
    f: TFf_xmult_conselector_N_salto;
    xpselector: word; //para la funcion auxiliar puesta en prepararMemoria

    constructor Create(capa: integer; fuente: TFuenteAleatoria;
      poste: integer; globs: TGlobs);

    function fval(x: NReal): NReal; override;
  end;

  TFf_promedioSalto_N = class(TFRenR)
  public
    f: TFf_xmult_N_salto;
    xpselector: word; //para la funcion auxiliar puesta en prepararMemoria

    constructor Create(capa: integer; fuente: TFuenteAleatoria; globs: TGlobs);

    function fval(x: NReal): NReal; override;
  end;

  {
  TFcompLess = class( TFRenR )
  public
    limite: NReal;
    constructor Create(lim: NReal);
    function fval(x : NReal) : NReal; override;
  end;
  }

implementation

//------------------------------
// Métodos de funciones auxiliares
//==============================

constructor TFId.Create;
begin

end;


function TFId.fval(x: NReal): NReal;
begin
  Result := x;
end;

constructor TFf_xmult_conselector_N_salto.Create(capa: integer;
  salto: integer; f: TFRenR; xxMult: TDAOfNreal; aMult: NReal;
  xpSelector: PWord; iFiltro: integer; pMatchFiltro: PDAOfNInt; ipMatchFiltro: PWord);

var
  i: integer;

begin
  inherited Create(capa);
  self.salto := salto;
  self.f := f;
  self.aMult := aMult;
  setlength(xmult, length(xxmult));
  for i := 0 to high(xxmult) do
    xmult[i] := xxmult[i];
  pSelector := xpSelector;
  Self.iFiltro := iFiltro;
  Self.pMatchFiltro := pMatchFiltro;
  Self.ipMatchFiltro := ipMatchFiltro;
end;

function TFf_xmult_conselector_N_salto.fval(x: NReal): NReal;
var
  kHora, kSubPaso: integer;
  acum: NReal;
  i: integer;
begin
  kSubPaso := ipMatchFiltro^;
  kSubPaso := kSubPaso * salto;

  if kSubPaso > length(pMatchFiltro^) then
    kSubPaso := kSubPaso mod length(pMatchFiltro^);
  kHora := kSubPaso;

  acum := 0;
  for i := 1 to salto do
  begin
    if kHora < 0 then
      kHora := kHora + length(pMatchFiltro^);
    if kHora >= length(pMatchFiltro^) then
      kHora := kHora mod length(pMatchFiltro^);

    if iFiltro = pMatchFiltro^[kHora] then
      acum := acum + aMult * f.fval(x * xmult[pSelector^ - 1]);

    kHora := kHora - 1;

  end;

  Result := acum;
end;


constructor TFf_xmult_N_salto.Create(capa: integer; salto: integer;
  f: TFRenR; xxMult: TDAOfNreal; aMult: NReal; xpSelector: PWord);

var
  i: integer;

begin
  inherited Create(capa);
  self.salto := salto;
  self.f := f;
  self.aMult := aMult;
  setlength(xmult, length(xxmult));
  for i := 0 to high(xxmult) do
    xmult[i] := xxmult[i];
  pSelector := xpSelector;
end;

function TFf_xmult_N_salto.fval(x: NReal): NReal;
var
  acum: NReal;
  i: integer;
begin

  acum := 0;
  for i := 1 to salto do
  begin
    acum := acum + aMult * f.fval(x * xmult[pSelector^ - 1]);
  end;

  Result := acum;

end;

constructor TFf_promedioSalto_N_poste.Create(capa: integer;
  fuente: TFuenteAleatoria; poste: integer; globs: TGlobs);
var
  xxMult: TDAofNReal;

begin
  inherited Create(capa);
  setlength(xxMult, 1);
  xxMult[0] := 1;
  xpselector := 1;

  f := TFf_xmult_conselector_N_salto.Create(capa, fuente.durPasoDeSorteoEnHoras,
    TFId.Create, xxMult, globs.HorasDelPaso /
    (fuente.durPasoDeSorteoEnHoras * globs.DurPos[poste]), @xpselector,
    poste, @globs.kPosteHorasDelPaso, @globs.kSubPaso_);
end;

function TFf_promedioSalto_N_poste.fval(x: NReal): NReal;
begin
  Result := f.fval(x);
end;

constructor TFf_promedioSalto_N.Create(capa: integer; fuente: TFuenteAleatoria; globs: TGlobs);
var
  xxMult: TDAofNReal;

begin
  inherited Create( capa );
  setlength(xxMult, 1);
  xxMult[0] := 1;
  xpselector := 1;

  f := TFf_xmult_N_salto.Create(capa, fuente.durPasoDeSorteoEnHoras,
    TFId.Create, xxMult, 1 / fuente.durPasoDeSorteoEnHoras, @xpselector);
end;

function TFf_promedioSalto_N.fval(x: NReal): NReal;
begin
  Result := f.fval(x);
end;

end.
