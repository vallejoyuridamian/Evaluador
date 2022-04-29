unit uBaseEditoresFichasCombustibles;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ufichasLPD,
  uBaseAltasEditores, utilidades;

type
  TBaseEditoresFichasCombustibles = class(TBaseAltasEditores)
  private
  protected
  public
    Constructor Create(AOwner : TControl ; ficha : TFichaLPD); reintroduce;
  end;

var
  BaseEditoresFichasCombustibles : TBaseEditoresFichasCombustibles;

implementation

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

Constructor TBaseEditoresFichasCombustibles.Create(AOwner : TControl ; ficha : TFichaLPD);
begin
  inherited Create(AOwner);
  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;
end;

end.
