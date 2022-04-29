unit ufichasdeterminismos_obsoleta;

(**** 17/11/2011 rch.
La definición de TFichaDeterminismo queda obsoleta pues los determinismos se representan
ahora como parte integral de los pronósticos. (ver unidad upronostico )

Se mantiene la defnición de TFichaDeterminismo solamente para poder leer salas anteriores
a la versión de archivo VERSION = 56.
*****)

interface

uses
  uFuentesAleatorias, MatReal, uCosa,
  xMatDefs, udisnormCan, fddp, fddp_conmatr,
  uCosaConNombre, uAuxiliares, uEstados,
  uGlobs, uconstantesSimSEE,
  uFuncionesReales, Classes, umodelosintcegh, uDatosHistoricos,
  uFechas, uFichasLPD, Math;

type

  { TFichaDeterminismo }

  TFichaDeterminismo = class(TCosa)
  public
    valores: TDAofNReal;
    constructor Create(capa: integer; valores: TDAofNReal);
    constructor Create_Default;
    //Crea una TFichaDeterminismo con valores= [0] y corridaDeterminista= false

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    procedure Free; override;
  end;


  TTipoValorEsperadoCEGH = (TTVE_real, TTVE_Gaussiano);
  TDAOfTTipoValorEsperadoCEGH = array of TTipoValorEsperadoCEGH;

  { TFichaFuenteSintetizadorCEGH }

  TFichaFuenteSintetizadorCEGH = class(TFichaLPD)
  public
    modificadoresRelativosVE: boolean;
    multiplicar_vm: boolean;
    modificadoresValEsp, modificadoresDevEst: TDAofNReal;
    deformadores_cache: TMatOf_ddp_VectDeMuestras;

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      modificadoresRelativos: boolean; multiplicar_VM: boolean;
  modificadoresValEsp, modificadoresDevEst: TDAofNReal);

    function Rec: TCosa_RecLnk; override;
    procedure BeforeRead(version, id_hilo: integer); override;
    procedure AfterRead(version, id_hilo: integer); override;

    procedure Free; override;
    constructor fichaPorDefecto(nBornesSalida: integer);

    class function DescClase: string; override;
    function infoAd_: string; override;
  end;


procedure AlInicio;
procedure AlFinal;

implementation

uses
  SysUtils;

constructor TFichaFuenteSintetizadorCEGH.Create(capa: integer; fecha: TFecha;
  periodicidad: TPeriodicidad; modificadoresRelativos: boolean;
  multiplicar_VM: boolean;
  modificadoresValEsp, modificadoresDevEst: TDAofNReal);
begin
  inherited Create(capa, fecha, periodicidad);
  self.modificadoresRelativosVE := modificadoresRelativos;
  self.modificadoresValEsp := modificadoresValEsp;
  self.modificadoresDevEst := modificadoresDevEst;
  self.multiplicar_vm := multiplicar_VM;
end;

function TFichaFuenteSintetizadorCEGH.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  Result.addCampoDef('modificadoresRelativosVE', modificadoresRelativosVE, 38 );
  Result.addCampoDef('multiplicar_vm', multiplicar_vm, 31);
  Result.addCampoDef('multiplicadoresVEs', modificadoresValEsp, 0, 23 );
  Result.addCampoDef('multiplicadoresVEs', modificadoresValEsp, 23, 27 );
  Result.addCampoDef('multiplicadoresStdDev', modificadoresDevEst, 23, 27);
  Result.addCampoDef('modificadoresValEsp', modificadoresValEsp, 27 );
  Result.addCampoDef('modificadoresDevEst', modificadoresDevEst, 27 );
end;

procedure TFichaFuenteSintetizadorCEGH.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;


procedure TFichaFuenteSintetizadorCEGH.AfterRead(version, id_hilo: integer);
var
  i: integer;
begin
  inherited AfterRead(version, id_hilo);
  if version < 23 then
  begin
    SetLength(modificadoresDevEst, length(modificadoresValEsp));
    for i := 0 to high(modificadoresDevEst) do
      modificadoresDevEst[i] := 1;
  end;
end;


procedure TFichaFuenteSintetizadorCEGH.Free;
begin
  modificadoresValEsp := nil;
  modificadoresDevEst := nil;
  if deformadores_cache <> nil then
    freeTMatOf_ddp_VectDeMuestras(deformadores_cache);
  inherited Free;
end;

constructor TFichaFuenteSintetizadorCEGH.fichaPorDefecto(nBornesSalida: integer);
var
  i: integer;
begin
  inherited Create(0, TFecha.Create_Dt(0), nil);
  self.modificadoresRelativosVE := True;
  self.multiplicar_vm := False;
  SetLength(modificadoresValEsp, nBornesSalida);
  SetLength(modificadoresDevEst, nBornesSalida);
  for i := 0 to nBornesSalida - 1 do
  begin
    modificadoresValEsp[i] := 1;
    modificadoresDevEst[i] := 1;
  end;
end;


class function TFichaFuenteSintetizadorCEGH.DescClase: string;
begin
  Result := 'Ficha de sintetizador CEGH';
end;

function TFichaFuenteSintetizadorCEGH.infoAd_: string;
var
  i: integer;
  res: string;
begin
  if length(modificadoresValEsp) > 0 then
  begin
    res := res + 'modVE[' + IntToStr(1) + ']= ' +
      FloatToStrF(modificadoresValEsp[0], ffGeneral, 10, 2);
    for i := 1 to high(modificadoresValEsp) do
      res := res + ', modVE[' + IntToStr(i + 1) + ']= ' +
        FloatToStrF(modificadoresValEsp[i], ffGeneral, 10, 2);
  end
  else
    res := '';
  Result := res;
end;



{$IFDEF BOSTA}
procedure TFichaFuenteSintetizadorCEGH.AfterInstantiation;
var
  i: Integer;
begin
  inherited AfterInstantiation;
  SetLength(modificadoresDevEst, length(modificadoresValEsp));
  for i := 0 to high(modificadoresDevEst) do
    modificadoresDevEst[i] := 1;
end;
{$ENDIF}

constructor TFichaDeterminismo.Create(capa: integer; valores: TDAofNReal);
begin
  inherited Create( capa );
  self.valores := valores;
end;

constructor TFichaDeterminismo.Create_Default;
begin
  inherited Create( 0 );
  SetLength(valores, 1);
  valores[0] := 0;
end;

function TFichaDeterminismo.Rec: TCosa_RecLnk;
begin
  Result:=inherited Rec;
  result.addCampoDef('valores', valores);
end;

procedure TFichaDeterminismo.BeforeRead(version, id_hilo: integer);
begin
  inherited BeforeRead(version, id_hilo);
end;

procedure TFichaDeterminismo.AfterRead(version, id_hilo: integer);
begin
  inherited AfterRead(version, id_hilo);
end;


procedure TFichaDeterminismo.Free;
begin
  SetLength(valores, 0);
  inherited Free;
end;










procedure AlInicio;
begin
  registrarClaseDeCosa(TFichaDeterminismo.ClassName, TFichaDeterminismo);
  registrarClaseDeCosa(TFichaFuenteSintetizadorCEGH.ClassName,
    TFichaFuenteSintetizadorCEGH);
end;

procedure AlFinal;
begin
end;


end.

