unit uBaseEditoresFichasGeneradores;

{$MODE Delphi}
interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, StdCtrls, xMatDefs;

type
  TBaseEditoresFichasGeneradores = class(TBaseEditoresFichas)
    procedure CBRestrClick(Sender: TObject; Edit: TEdit);
  private
    { Private declarations }
  protected
    function validarRestriccion(CB: TCheckBox; Edit: TEdit; min, max: NReal): boolean;
    procedure initCBRestriccion(hayRest: boolean; CB: TCheckBox;
      valor: NReal; Edit: TEdit);
    function rest(CB: TCheckBox; Edit: TEdit; valSiFalso: NReal): NReal;
  public
    { Public declarations }
  end;

var
  BaseEditoresFichasGeneradores: TBaseEditoresFichasGeneradores;

implementation

  {$R *.lfm}

function TBaseEditoresFichasGeneradores.validarRestriccion(CB: TCheckBox;
  Edit: TEdit; min, max: NReal): boolean;
begin
  if CB.Checked then
    Result := validarEditFloat(Edit, min, max)
  else
    Result := True;
end;

procedure TBaseEditoresFichasGeneradores.initCBRestriccion(hayRest: boolean;
  CB: TCheckBox; valor: NReal; Edit: TEdit);
begin
  CB.Checked := hayRest;
  if hayRest then
    Edit.Text := FloatToStr(valor)
  else
    Edit.Text := '';
  Edit.Enabled := CB.Checked;
  guardado := True;
end;

function TBaseEditoresFichasGeneradores.rest(CB: TCheckBox; Edit: TEdit;
  valSiFalso: NReal): NReal;
begin
  if CB.Checked then
    Result := StrToFloat(Edit.Text)
  else
    Result := valSiFalso;
end;

procedure TBaseEditoresFichasGeneradores.CBRestrClick(Sender: TObject; Edit: TEdit);
begin
  edit.Enabled := TCheckBox(Sender).Checked;
  guardado := False;
end;

end.
