unit uBaseAltaEdicionPostOpers;
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
  uPostOpers, uBaseFormularios;

type
  TClaseAltaEdicionPostOpers = class of TBaseAltaEdicionPostOpers;
  TBaseAltaEdicionPostOpers = class(TBaseFormulariosEditorSimRes3)
  protected
    postOper: TPostOper;
    tipoPostOper: TClaseDePostOper;
  private
    { Private declarations }
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper); reintroduce; virtual;
    function darPostOper: TPostOper;
  end;

implementation
{$R *.lfm}

Constructor TBaseAltaEdicionPostOpers.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector);
  self.postOper:= postOper;
  if postOper = NIL then
    self.Caption:= rs_Alta_de + ' ' + tipoPostOper.tipo
  else
    self.Caption:= rs_Edicion_de+ ' ' + tipoPostOper.tipo;
  self.tipoPostOper:= tipoPostOper;
end;

function TBaseAltaEdicionPostOpers.darPostOper: TPostOper;
begin
  result:= self.postOper;
end;

end.