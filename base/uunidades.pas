unit uunidades;

{$mode delphi}

interface

uses
  xmatdefs, usimplex, Classes, SysUtils,
  uglobs, ufichasLPD, ucosa,
  ucosaparticipedemercado,
  ufechas,
  uEstados,
  uCosaConNombre, uranddispos, uforzamientos, Math,
  uauxiliares;


type
  { TFichaUnidades }

  TFichaUnidades = class(TFichaLPD)
  public
    nUnidades_Instaladas: TDAofNInt;
    nUnidades_EnMantenimiento: TDAofNInt;
    AltaConIncertidumbre: TDAOfBoolean;
    InicioCronicaConIncertidumbre: TDAOfBoolean;

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      xnUnidades_Instaladas, xnUnidades_EnMantenimiento: TDAofNInt;
      altaConIncertidumbre_, InicioCronicaConIncertidumbre_: TDAOfBoolean);
    procedure Free; override;

    constructor Create_dummy; override;
    procedure Free_dummy; override;

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    function InfoAd_: string; override;
    procedure generarLineaResumen(var archi: TextFile); override;

    function GetUnidadesOperativas(i: integer): integer;
    property nUnidades_Operativas[i: integer]: integer read GetUnidadesOperativas;
      default;

    // retorna la cantidad de tipos de unidades diferentes
    function nTipos: integer;
  end;


  TRotRep_rec = record
    cnt_Operativas: integer; // suma de las dos siguientes en todo momento.
    cnt_OK: integer;  // cantidad de undiades fuera de mantenimiento Programado disponibles
    cnt_Rotas: integer; // cantidad de unidades fuera de mantenimiento Programado Rotas

    FDispo: NReal; // factor de disponibilidad fortuita
    TMRep_h: NReal; // tiempo medi de reparción en horas.
    pRep: NReal; // Probabilidad de reparción dado que estaba Roto
    pRot: NReal; // Porbabilidad e Rotura dado que estaba OK.

    // indica que en estas unidades aplicar sorteo estatico
    // Este parámetro se pone a TRUE si el tiempo de reparción es inferior
    // al tiempo del paso para que en ese caso no considere el modelo con estado
    UsarSorteoEstatico: boolean;

    // Indica si el alta de una unidad de este tipo se considera
    // como fecha cierta de entrada o se aplica el sorteo de REPARACION
    // para simular que es incierto el ingreso.
    AltaConIncertidumbre: boolean;

    // Indica si al inicio de cada crónica se debe considerar que las
    // unidades indicadas como disponibles están realmente disponibles
    // o se debe aplicar la probabilidad de estado estacionario para decidir
    // su estado.
    InicioCronicaConIncertidumbre: boolean;
  end;
  PRotRep_rec = ^TRotRep_rec;





procedure AlInicio;
procedure AlFinal;

implementation





//-------------------------
//Metodos de TFichaUnidades
//=========================
constructor TFichaUnidades.Create(capa: integer; fecha: TFecha;
periodicidad: TPeriodicidad;
xnUnidades_Instaladas, xnUnidades_EnMantenimiento: TDAofNInt;
altaConIncertidumbre_, InicioCronicaConIncertidumbre_: TDAOfBoolean);

begin
// Primero tengo que copiar los vectores para que estén definidos para Rec.
nUnidades_Instaladas := copy(xnUnidades_Instaladas);
if xnUnidades_EnMantenimiento <> nil then
  nUnidades_EnMantenimiento := copy(xnUnidades_EnMantenimiento)
else
begin
  setlength(nUnidades_EnMantenimiento, length(nUnidades_Instaladas));
  vclear(nUnidades_EnMantenimiento);
end;
AltaConIncertidumbre := copy(AltaConIncertidumbre_);
InicioCronicaConIncertidumbre := copy(InicioCronicaConIncertidumbre_);

// Ahora llamo el inherited Create que creará el Rec.
inherited Create(capa, fecha, periodicidad);
end;

procedure TFichaUnidades.Free;
begin
setlength(nUnidades_Instaladas, 0);
setlength(nUnidades_EnMantenimiento, 0);
inherited Free;
end;

constructor TFichaUnidades.Create_dummy;
begin
inherited Create_dummy;
SetLength(nUnidades_Instaladas, 1);
end;

procedure TFichaUnidades.Free_dummy;
begin
setlength( nUnidades_Instaladas, 0 );
inherited Free;
end;

function TFichaUnidades.Rec: TCosa_RecLnk;
begin
Result:=inherited Rec;
Result.addCampoDef('nUnidades', nUnidades_Instaladas[0], 0, 50);
Result.addCampoDef('nUnidades', nUnidades_Instaladas, 50, 124);
Result.addCampoDef('nUnidades_Instaladas', nUnidades_Instaladas, 124);
Result.addCampoDef('nUnidades_EnMantenimiento', nUnidades_EnMantenimiento, 124);
Result.addCampoDef('AltaConIncertidumbre', AltaConIncertidumbre, 100, 0);
Result.addCampoDef('InicioCronicaConIncertidumbre', InicioCronicaConIncertidumbre, 100);
end;

procedure TFichaUnidades.BeforeRead(version, id_hilo: integer);
begin
inherited BeforeRead(version, id_hilo);
SetLength(nUnidades_Instaladas, 1);
end;

procedure TFichaUnidades.AfterRead(version, id_hilo: integer);
var
k: integer;
begin
inherited AfterRead(version, id_hilo);
if Version < 100 then
begin
  setlength(AltaConIncertidumbre, length(nUnidades_Instaladas));
  setlength(InicioCronicaConIncertidumbre, length(nUnidades_Instaladas));
  for k := 0 to high(nUnidades_Instaladas) do
  begin
    AltaConIncertidumbre[k] := True;
    InicioCronicaConIncertidumbre[k] := False;
  end;
end;

if Version < 124 then
begin
  setlength(nUnidades_EnMantenimiento, length(nUnidades_Instaladas));
  vclear(nUnidades_EnMantenimiento);
end;
end;


function TFichaUnidades.InfoAd_: string;
begin
Result := inherited infoAd_ + ' I:' + DAOfNIntToStr(self.nUnidades_Instaladas, ';') +
  ' M:' + DAOfNIntToStr(self.nUnidades_EnMantenimiento, ';');
end;

function TFichaUnidades.nTipos: integer;
begin
Result := length(nUnidades_Instaladas);
end;


function TFichaUnidades.GetUnidadesOperativas(i: integer): integer;
begin
Result := nUnidades_Instaladas[i] - nUnidades_EnMantenimiento[i];
end;

procedure TFichaUnidades.generarLineaResumen(var archi: TextFile);
begin
Write(archi, IntToStr((nUnidades_Operativas[0])) + '/' +
  IntToStr(nUnidades_Instaladas[0]),
  #9);  //NUnidades
end;



procedure AlInicio;
begin
  registrarClaseDeCosa(TFichaUnidades.ClassName, TFichaUnidades);
end;

procedure AlFinal;
begin
end;


end.
