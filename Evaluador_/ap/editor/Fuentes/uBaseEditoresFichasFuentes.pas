unit uBaseEditoresFichasFuentes;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  // Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
  // Messages,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ufichasLPD,
  uBaseAltasEditores, utilidades;

type
  TBaseEditoresFichasFuentes = class(TBaseAltasEditores)
  private
  protected
  public
    constructor Create(AOwner: TControl; ficha: TFichaLPD); reintroduce;
  end;

var
  BaseEditoresFichasFuentes: TBaseEditoresFichasFuentes;

implementation

  {$R *.lfm}

constructor TBaseEditoresFichasFuentes.Create(AOwner: TControl; ficha: TFichaLPD);
begin
  inherited Create(AOwner, ficha, nil );
  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;
end;

end.
