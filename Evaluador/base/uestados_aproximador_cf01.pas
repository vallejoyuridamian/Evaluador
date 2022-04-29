unit uestados_aproximador_cf01;
{
rch@201702151944

Definición de la clase TAdminEstados_Aproximador_CF01

La idea es que se van simulando CRONICAS y se agrega la información
del CF(X, k) en la medida en que se van ejecutando.


}
{$mode delphi}

interface

uses
  Classes, SysUtils, uestados, xmatdefs, matreal, utipos_xcf, ufechas, uneuronas;

type

  { TAdminEstados_Aproximador_CF01 }

  TAdminEstados_Aproximador_CF01 = class(TAdminEstados)

    ramilletes: TRamilletes;

    constructor Create(_nVarsContinuas, _nVarsDiscretas, _nPuntosT: integer);

    constructor CreateLoadFromArchi(const archi: string; Sala_dtIni,
      Sala_dtFin: TFecha; Sala_HorasDelPaso: NReal);

    constructor Create_LoadFromFile(var f: file);

    function costoEstrella(kpuntoT: integer): NReal; override;
    function costoContinuo(kPuntoT: integer): NReal; override;

    // calcula la derivadas respecto de la variabla cuyo índice es (irx) para
    // el punto de tiempo kpuntoT. La derivada dCdx_Inc es la calculada con
    // un incremento de x, la dCdx_Dec es calculada con un decremento.
    procedure devxr_estrella_20_(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal); override;

    procedure devxr_continuo_20(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal); override;

    procedure devxr_estrella_(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer); override;

    procedure devxr_continuo(irx: integer; kpuntoT: integer;
      var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer;
    // -1 me fuir por abajo , 0 en la caja , 1 me fui por arriba
      var xrpos: NReal
    // Posición del punto en la cajita de paroximación en por unidad
      ); override;

    // Calcula la variación del costo por un incremento delta_xd en la variable ird
    // en el punto de tiempo kpuntoT
    function deltaCosto_vxd_estrella_(ird: integer; kpuntoT: integer;
      delta_xd: integer): NReal; override;
    function deltaCosto_vxd_continuo(ird: integer; kpuntoT: integer;
      delta_xd: integer): NReal; override;

    function deltaCosto_vxr_continuo_DosEstados_UTE(irx, irx2, kpuntoT: integer;
      delta_xr, delta_xr2: NReal): NReal; override;
    // delta costo sobre una coordenada real
    function deltaCosto_vxr_continuo(irx: integer; kpuntoT: integer;
      delta_xr: NReal): NReal; override;

  end;


implementation


{ TAdminEstados_Aproximador_CF01 }

constructor TAdminEstados_Aproximador_CF01.CreateLoadFromArchi(
  const archi: string; Sala_dtIni, Sala_dtFin: TFecha;
  Sala_HorasDelPaso: NReal);
var
  f: TStream;
begin
  f:= TFileStream.Create( archi, fmOpenRead );


end;

constructor TAdminEstados_Aproximador_CF01.Create_LoadFromFile(var f: file);
var
  flgw: boolean;
  dtAux: TDateTime;
  v0: double; // si no es -121212 no es un archivo
  nver: integer;
  intaux: integer;

begin
  constelacion := nil;
  ControladorDeterministico := nil;
  ramilletes:= nil;

  flgw := False;
  brwf(f, v0, flgw);
  if (v0 <> -121212) then
     raise Exception.Create('Este archivo no es válido como TAdminEstados_AProximador_CF01' );


  brwf(f, nver, flgw);

  brwf(f, dtAux, flgw);
  FechaIni := TFecha.Create_Dt(dtAux);
  brwf(f, dtAux, flgw);
  fechaFin := TFecha.Create_Dt(dtAux);

  brwf(f, horasDelPaso, flgw);

  brwf(f, nVarsContinuas, flgw);
  brwf(f, nVarsContinuas, flgw);
  brwf(f, nVarsDiscretas, flgw);
  brwf(f, nPuntosT, flgw);

  inherited Create( nVarsContinuas, nVarsDiscretas, nPUntosT );

  brwf(f, xr_def, flgw);
  brwf(f, xd_def, flgw);
  brwf(f, xr, flgw);
  brwf(f, xd, flgw);


  // Existe el concepto de estrella (no hay discretización).
  // inicializo esto a algo
  setlength( estrella_kr, 0 );
  setlength( estrella_kd, 0 );
  ordinalEstrellaActual:= 0;

  ramilletes:= TRamilletes.Create_LoadFromFile( f );
end;



constructor TAdminEstados_Aproximador_CF01.Create(_nVarsContinuas,
  _nVarsDiscretas, _nPuntosT: integer);
var
  ver: integer;

begin
  Inherited Create( _nVarsContinuas, _nvarsDiscretas, _nPUntosT );

end;

function TAdminEstados_Aproximador_CF01.costoEstrella(kpuntoT: integer): NReal;
begin
  Result:=inherited costoEstrella(kpuntoT);
end;

function TAdminEstados_Aproximador_CF01.costoContinuo(kPuntoT: integer): NReal;
begin
  Result:=inherited costoContinuo(kPuntoT);
end;

procedure TAdminEstados_Aproximador_CF01.devxr_estrella_20_(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal);
begin
  inherited devxr_estrella_20_(irx, kpuntoT, dCdx_Inc, dCdx_Dec);
end;

procedure TAdminEstados_Aproximador_CF01.devxr_continuo_20(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal);
begin
  inherited devxr_continuo_20(irx, kpuntoT, dCdx_Inc, dCdx_Dec);
end;

procedure TAdminEstados_Aproximador_CF01.devxr_estrella_(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer);
begin
  inherited devxr_estrella_(irx, kpuntoT, dCdx_Inc, dCdx_Dec, resCod);
end;

procedure TAdminEstados_Aproximador_CF01.devxr_continuo(irx: integer;
  kpuntoT: integer; var dCdx_Inc, dCdx_Dec: NReal; var resCod: integer;
  var xrpos: NReal);
begin
  inherited devxr_continuo(irx, kpuntoT, dCdx_Inc, dCdx_Dec, resCod, xrpos);
end;

function TAdminEstados_Aproximador_CF01.deltaCosto_vxd_estrella_(ird: integer;
  kpuntoT: integer; delta_xd: integer): NReal;
begin
  Result:=inherited deltaCosto_vxd_estrella_(ird, kpuntoT, delta_xd);
end;

function TAdminEstados_Aproximador_CF01.deltaCosto_vxd_continuo(ird: integer;
  kpuntoT: integer; delta_xd: integer): NReal;
begin
  Result:=inherited deltaCosto_vxd_continuo(ird, kpuntoT, delta_xd);
end;

function TAdminEstados_Aproximador_CF01.deltaCosto_vxr_continuo_DosEstados_UTE(
  irx, irx2, kpuntoT: integer; delta_xr, delta_xr2: NReal): NReal;
begin
  Result:=inherited deltaCosto_vxr_continuo_DosEstados_UTE(irx, irx2, kpuntoT,
    delta_xr, delta_xr2);
end;

function TAdminEstados_Aproximador_CF01.deltaCosto_vxr_continuo(irx: integer;
  kpuntoT: integer; delta_xr: NReal): NReal;
begin
  Result:=inherited deltaCosto_vxr_continuo(irx, kpuntoT, delta_xr);
end;


end.

