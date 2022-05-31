unit uListaViolacionesPermitidasSimplex;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  xmatdefs, classes;

type
  TFichaViolacionPermitida = class
    public
      //El indice en ivars de la próxima variable a violarle la cota en el simplex
      iViolacionAUsar: Integer;
      usada: boolean;
      ires: Integer;
      ivars: TDAofNInt;

      Constructor Create(xires : Integer; xivars: TDAofNInt);
  end;

  TListaViolacionesPermitidasSimplex = class(TList)
    public
      Constructor Create_Clone(listaOriginal : TListaViolacionesPermitidasSimplex);
      function sePuedeViolarCotaSupParaArreglar(xires : Integer; var ficha : TFichaViolacionPermitida) : boolean;
      procedure Limpiar;
      procedure Free;
  end;

implementation

//-----------------------------------
//Métodos de TFichaViolacionPermitida
//===================================

Constructor TFichaViolacionPermitida.Create(xires : Integer; xivars: TDAofNInt);
begin
  inherited Create;
  self.iViolacionAUsar:= 0;
//  self.ivar:= xivar;
  self.ires:= xires;
  self.ivars:= xivars;
  self.usada:= false;
end;

//---------------------------------------------
//Métodos de TListaViolacionesPermitidasSimplex
//=============================================

Constructor TListaViolacionesPermitidasSimplex.Create_Clone(listaOriginal : TListaViolacionesPermitidasSimplex);
var
  i: Integer;
  fichaListaOrig: TFichaViolacionPermitida;
begin
  inherited Create;
  self.Capacity:= listaOriginal.Count;
  for i:= 0 to listaOriginal.Count -1 do
  begin
    fichaListaOrig:= listaOriginal.items[i];
    self.Add(TFichaViolacionPermitida.Create(fichaListaOrig.ires, fichaListaOrig.ivars));
  end;
end;

function TListaViolacionesPermitidasSimplex.sePuedeViolarCotaSupParaArreglar(xires : Integer; var ficha : TFichaViolacionPermitida) : boolean;
var
  i: Integer;
  res: boolean;
begin
  res:= false;
  for i:= 0 to Count -1 do
    if TFichaViolacionPermitida(items[i]).ires = xires then
    begin
      ficha:= items[i];
      res:= true;
      break;
    end;
  result:= res;
end;

procedure TListaViolacionesPermitidasSimplex.Limpiar;
var
  i: Integer;
begin
  for i:= 0 to count -1 do
    TFichaViolacionPermitida(items[i]).Free;
  self.Clear;
end;

procedure TListaViolacionesPermitidasSimplex.Free;
var
  i: Integer;
begin
  for i:= 0 to count -1 do
    TFichaViolacionPermitida(items[i]).Free;
  inherited Free;
end;

end.
