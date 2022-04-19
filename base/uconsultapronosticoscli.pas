unit uconsultapronosticoscli;

{$mode delphi}

interface

uses
  Classes, SysUtils,
  xmatdefs,
  uvatespronosticos,
  uRobotHttpPost,
  uSLRW;

type

  // Manejador de consultas a una url del lado del Cliente
  TConsultaPronostico_Cliente = class
  private
    url: string;
    variables: TList_FCVarPronostico;
  public
    constructor Create(url: string);
    procedure Free;
    procedure add(nombre_var: string; dt_Presente: TDateTime;
      Ts_Segundos: NReal; NRetardos, NFuturos: integer);
    function get_pronostico: TList_FRVarPronostico;
  end;


implementation

constructor TConsultaPronostico_Cliente.Create(url: string);
begin
  self.url := url;
  variables := TList_FCVarPronostico.Create;
end;

procedure TConsultaPronostico_Cliente.add(nombre_var: string;
  dt_Presente: TDateTime; Ts_Segundos: NReal;
  NRetardos, NFuturos: integer);
var
  aFC: TFCVarPronostico;
begin
  aFC := TFCVarPronostico.Create(nombre_var, dt_Presente, Ts_Segundos,
    NRetardos, NFuturos);
  variables.add(aFC);
end;

function TConsultaPronostico_Cliente.get_pronostico: TList_FRVarPronostico;

var
  rbt: TRobotHttpPost;
  reshttp: TStringList;

  slrw: TSLRW;
  res: TList_FRVarPronostico;

begin
  //rbt := TRobotHttpPost.Create(url, '***INICIO***', '***FIN***');
  rbt := TRobotHttpPost.Create(url, '+INICIO', '+FIN');

  slrw := TSLRW.CreateForWrite;
  variables.slrw(slrw);
  rbt.AddCampo('ListaFichasConsultaPronosticos', slrw.Text);
  reshttp := TStringList.Create;
  reshttp := rbt.post('POST');
  rbt.Free;
  slrw.Free;

  res := TList_FRVarPronostico.Create;
  slrw := TSLRW.CreateForRead(reshttp);
  res.slrw(slrw);
  slrw.Free;
  Result := res;
end;


procedure TConsultaPronostico_Cliente.Free;
var
  k: integer;
begin
  variables.Free;
  inherited Free;
end;


end.

