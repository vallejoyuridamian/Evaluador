unit uforzamientos;

interface

uses
  Classes, SysUtils, xmatdefs, ufichasLPD, ucosa,
  ufechas;


type

{ TFichaForzamientos }

  TFichaForzamientos = class(TFichaLPD)
  public
    activar_forzamiento: boolean;
    P: TDAofNReal;

    constructor Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
      activar_forzamiento: boolean; P: TDAOfNReal);
    procedure Free; override;
    function Rec: TCosa_RecLnk; override;
    function InfoAd_: string; override;
    procedure generarLineaResumen(var archi: TextFile); override;
  end;


procedure AlInicio;
procedure AlFinal;

resourcestring
  rsForzamientoInactivo = 'Inactivo';
  rsForzamientoActivo = 'Activo';

implementation

//-------------------------
//Metodos de TFichaForzamientos
//=========================
constructor TFichaForzamientos.Create(capa: integer; fecha: TFecha; periodicidad: TPeriodicidad;
     activar_forzamiento: boolean; P: TDAOfNReal);
begin
  inherited Create(capa, fecha, periodicidad);
  self.activar_forzamiento:= activar_forzamiento;
  self.P:= P;
end;

procedure TFichaForzamientos.Free;
begin
  setlength(P, 0);
  inherited Free;
end;

function TFichaForzamientos.Rec: TCosa_RecLnk;
begin
  result:= inherited Rec;
  result.addCampoDef('activo', activar_forzamiento );
  result.addCampoDef('P', P);
end;



function TFichaForzamientos.InfoAd_: string;
begin
  if activar_forzamiento then
   Result := inherited infoAd_ +rsForzamientoActivo+', '+ DAOfNRealToStr_(self.P, 12, 2, ';')
  else
   Result := inherited infoAd_ +rsForzamientoInactivo+', '+ DAOfNRealToStr_(self.P, 12, 2, ';')
end;

procedure TFichaForzamientos.generarLineaResumen(var archi: TextFile);
begin
  Write(archi, infoAd_, #9);  //NUnidades
end;



procedure AlInicio;
begin
  registrarClaseDeCosa(TFichaForzamientos.ClassName, TFichaForzamientos);
end;

procedure AlFinal;
begin
end;


end.

