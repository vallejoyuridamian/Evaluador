unit uBaseAltaEdicionCronVars;
{$MODE Delphi}

interface

uses
    {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, stdCtrls,
  uBaseFormulariosEditorSimRes3,
  uLectorSimRes3Defs,
  uHistoVarsOps, uBaseFormularios;

resourcestring
  rsAltaDeVariabeCronica = 'Alta de variable crónica';
  rsEdicionVariableCronica = 'Edición de variable crónica';
  mesYaExisteVarCronicaConNombre = 'Ya existe una variable crónica con el nombre ';
  mesNombreNoSerVacio = 'El campo nombre no puede ser vacio';

type
  TClaseAltaEdicionCronVars = class of TBaseAltaEdicionCronVars;
  TBaseAltaEdicionCronVars = class(TBaseFormulariosEditorSimRes3)
  protected
    cronVar: TCronVar;

    function validarNombreCronVar(eNombre: TEdit): boolean;
  private
    { Private declarations }
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronVar: TCronVar); reintroduce; virtual;
    function darCronVar: TCronVar;
  end;

implementation
  {$R *.lfm}


Constructor TBaseAltaEdicionCronVars.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; cronVar: TCronVar);
begin
  inherited Create(AOwner, lector);
  self.cronVar:= cronVar;
  if cronVar = NIL then
    self.Caption:= rsAltaDeVariabeCronica
  else
    self.Caption:= rsEdicionVariableCronica;
end;

function TBaseAltaEdicionCronVars.darCronVar: TCronVar;
begin
  result:= self.cronVar;
end;

function TBaseAltaEdicionCronVars.validarNombreCronVar(eNombre: TEdit): boolean;
begin
  if eNombre.Text <> '' then
  begin
    if not lector.nombreRepetidoCronVar(cronVar, eNombre.Text) then
      result:= true
    else
    begin
      ShowMessage(mesYaExisteVarCronicaConNombre + eNombre.Text);
      result:= false;
    end;
  end
  else
  begin
    ShowMessage(mesNombreNoSerVacio);
    result:= false;
  end;
end;

end.