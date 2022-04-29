unit uEditarBorne;

  {$MODE Delphi}

interface

uses
   {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uBaseFormularios, uFuentesAleatorias, utilidades, uBaseAltasEditores;

resourcestring
  mesExisteOtroBorneIgualNombre = 'Ya existe otro Borne con el nombre ingresado';
  mesNombreNoSerVacio = 'El campo nombre no puede ser vacio';
  mesNombreBorneNoVacio = 'El nombre del borne no puede ser vacio';

type
  TEditarBorne = class(TBaseFormularios)
    LNombreBorne: TLabel;
    ENombre: TEdit;
    BGuardar: TButton;
    BCancelar: TButton;
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure ENnombreEnter(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure ENombreExit(Sender: TObject);
  private
    posNombre: integer;
    NombresDeBornes_Publicados: TStringList;

    function ValidarEditNombreBorne(Sender: TObject): boolean;
  public
    constructor Create(AOwner: TControl; NombresDeBornes_Publicados: TStringList;
      xposNombre: integer); reintroduce;
    function darBorne: string;
  end;

implementation

  {$R *.lfm}

procedure TEditarBorne.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;

constructor TEditarBorne.Create(AOwner: TControl;
  NombresDeBornes_Publicados: TStringList; xposNombre: integer);
begin
  inherited Create(AOwner);
  self.NombresDeBornes_Publicados := NombresDeBornes_Publicados;
  self.posNombre := xposNombre;
  if xposNombre < NombresDeBornes_Publicados.Count then
    ENombre.Text := NombresDeBornes_Publicados[xposNombre];
end;

function TEditarBorne.darBorne: string;
begin
  Result := ENombre.Text;
end;

procedure TEditarBorne.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarBorne.BGuardarClick(Sender: TObject);
var
  puedoGuardar: boolean;
  res: integer;
begin
  if ValidarEditNombreBorne(ENombre) then
  begin
    if posNombre < NombresDeBornes_Publicados.Count then
    begin
      res := NombresDeBornes_Publicados.IndexOf(ENombre.Text);
      if (res = posNombre) or (res = -1) then
        puedoGuardar := True
      else
      begin
        ShowMessage(mesExisteOtroBorneIgualNombre);
        puedoGuardar := False;
      end;
    end
    else
      puedoGuardar := True;
  end
  else
  begin
    ShowMessage(mesNombreNoSerVacio);
    puedoGuardar := False;
  end;
  if puedoGuardar then
    ModalResult := mrOk;
end;

procedure TEditarBorne.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarBorne.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarBorne.ENnombreEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarBorne.ENombreExit(Sender: TObject);
begin
  ValidarEditNombreBorne(Sender);
end;

function TEditarBorne.ValidarEditNombreBorne(Sender: TObject): boolean;
var
  trimNombre: string;
begin
  if TEdit(Sender).Text <> loQueHabia then
  begin
    trimNombre := Trim(ENombre.Text);
    if trimNombre <> ENombre.Text then
      ENombre.Text := Trim(ENombre.Text);

    if TEdit(Sender).Text = '' then
    begin
      ShowMessage(mesNombreBorneNoVacio);
      TEdit(Sender).Text := loQueHabia;
      Result := False;
    end
    else
    begin
      guardado := False;
      Result := True;
    end;
  end
  else
    Result := True;
end;


end.
