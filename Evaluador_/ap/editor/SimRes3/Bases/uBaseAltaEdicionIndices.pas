unit uBaseAltaEdicionIndices;

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, stdCtrls,
  uBaseFormulariosEditorSimRes3,
  uLectorSimRes3Defs,
  uSalasDeJuego, uHistoVarsOps, uBaseFormularios;

resourcestring
  mesYaExisteUnIndice = 'Ya existe un índice con el nombre ';
  mesNombreNoSerVacio = 'El campo nombre no puede ser vacio';
  rs_Alta_de_indice = 'Alta de índice';
  rs_Edicion_de_indice = 'Edición de índice';

type
  TClaseAltaEdicionIndices = class of TBaseAltaEdicionIndices;

  TBaseAltaEdicionIndices = class(TBaseFormulariosEditorSimRes3)
  protected
    sala: TSalaDeJuego;
    indice: TVarIdxs;

    function validarNombreIndice(eNombre: TEdit): boolean;
  private
    { Private declarations }
  public
    Constructor Create(AOwner: TComponent; sala: TSalaDeJuego; lector: TLectorSimRes3Defs; indice: TVarIdxs); reintroduce; virtual;
    function darIndice: TVarIdxs;
  end;

implementation
  {$R *.lfm}

Constructor TBaseAltaEdicionIndices.Create(AOwner: TComponent; sala: TSalaDeJuego; lector: TLectorSimRes3Defs; indice: TVarIdxs);
begin
  inherited Create(AOwner, lector);
  self.sala:= sala;

  if indice = NIL then
    self.Caption:= rs_Alta_de_indice
  else
    self.Caption:= rs_Edicion_de_indice;

  self.indice:= indice;
end;

function TBaseAltaEdicionIndices.darIndice: TVarIdxs;
begin
  result:= self.indice;
end;

function TBaseAltaEdicionIndices.validarNombreIndice(eNombre: TEdit): boolean;
begin
  if eNombre.Text <> '' then
  begin
    if not lector.nombreRepetidoIndice(indice, eNombre.Text) then
      result:= true
    else
    begin
      ShowMessage(mesYaExisteUnIndice + eNombre.Text);
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