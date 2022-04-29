unit uBaseEditoresCosasConNombre;
{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseFormularios, uBaseEditores, uCosa, uCosaConNombre,
  uSalasDeJuego, StdCtrls,
  usalasdejuegoParaEditor, uNodos, uFuentesAleatorias;

resourcestring
  rs_YaExisteUnActorConElNombre = 'Ya existe un actor con el nombre ';
  rs_NombreNoPuedeSerVacio = 'El campo nombre no puede ser vacio';

type
  TBaseEditoresCosasConNombre = class(TBaseEditores)
  protected
    cosaConNombre: TCosaConNombre;
    //NO MODIFICAR hasta que el usuario de guardar.
    //Castear al tipo correspondiente en el formulario
    //de edición particular
    tipoCosa: TClaseDeCosaConNombre;
    function validarNombre(Sender: TObject): boolean;
    procedure ocultarFechas(LFIni, LFFin: TLabel; EFIni, EFFin: TEdit);
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); reintroduce; virtual;
    function darResultado: TCosaConNombre;
  end;

  TClaseEditoresCosasConNombre = class of TBaseEditoresCosasConNombre;

implementation
  {$R *.lfm}

constructor TBaseEditoresCosasConNombre.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
begin
  inherited Create(AOwner, cosaConNombre, sala);
  self.tipoCosa := TClaseDeCosaConNombre(tipoCosa);
  self.cosaConNombre := cosaConNombre;
  if cosaConNombre = nil then
    self.Caption := 'Alta de ' + self.tipoCosa.DescClase
  else
    self.Caption := 'Editando "' + cosaConNombre.nombre + '" ' +
      self.tipoCosa.DescClase;
  self.loQueHabia := '';
  guardado := True;
end;

function TBaseEditoresCosasConNombre.darResultado: TCosaConNombre;
begin
  Result := cosaConNombre;
end;

function TBaseEditoresCosasConNombre.validarNombre(Sender: TObject): boolean;
var
  senderAsEdit: TEdit;
  trimNombre: string;
begin
  senderAsEdit := TEdit(Sender);
  trimNombre := Trim(senderAsEdit.Text);
  if senderAsEdit.Text <> loQueHabia then
  begin
    if senderAsEdit.Text <> trimNombre then
      senderAsEdit.Text := trimNombre;
    if (senderAsEdit.Text <> '') then
    begin
      if rbtEditorSala.nombreRepetido(cosaConNombre, senderAsEdit.Text) then
      begin
        ShowMessage(rs_YaExisteUnActorConElNombre + senderAsEdit.Text);
        if loQueHabia <> #0 then
          senderAsEdit.Text := loQueHabia;
        Result := False;
      end
      else
      begin
        guardado := False;
        Result := True;
      end;
    end
    else
    begin
      ShowMessage(rs_NombreNoPuedeSerVacio);
      Result := False;
    end;
  end
  else
  begin
    if trimNombre = '' then
    begin
      ShowMessage(rs_NombreNoPuedeSerVacio);
      Result := False;
    end
    else
      Result := True;
  end;
end;

procedure TBaseEditoresCosasConNombre.ocultarFechas(LFIni, LFFin: TLabel;
  EFIni, EFFin: TEdit);
begin
  LFIni.Visible := False;
  LFFin.Visible := False;
  EFIni.Text := 'Auto';
  EFFin.Text := 'Auto';
  EFIni.Visible := False;
  EFFin.Visible := False;
  //  cambiarTopControles(EFFin.Top, -(EFIni.Height + EFFin.Height + 3));
end;

end.
