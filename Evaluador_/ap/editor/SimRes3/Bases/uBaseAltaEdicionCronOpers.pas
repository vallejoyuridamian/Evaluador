unit uBaseAltaEdicionCronOpers;
{$MODE Delphi}

interface

uses
    {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  uBaseFormulariosEditorSimRes3,
  uLectorSimRes3Defs,
  uHistoVarsOps, uBaseFormularios;

type
  TClaseAltaEdicionCronOpers = class of TBaseAltaEdicionCronOpers;
  TBaseAltaEdicionCronOpers = class(TBaseFormulariosEditorSimRes3)
  protected
    cronOper: TCronOper;
    tipoCronOper: TClaseDeCronOper;
  private
    { Private declarations }
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);   reintroduce; virtual;
    function darCronOper: TCronOper;
  end;


implementation
  {$R *.lfm}

Constructor TBaseAltaEdicionCronOpers.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector);
  self.cronOper:= cronOper;
  if cronOper = NIL then
    self.Caption:= rs_Alta_de+' ' + tipoCronOper.tipo
  else
    self.Caption:= rs_Edicion_de+' ' + tipoCronOper.tipo;
  self.tipoCronOper:= tipoCronOper;
end;

function TBaseAltaEdicionCronOpers.darCronOper: TCronOper;
begin
  result:= self.cronOper;
end;

end.
