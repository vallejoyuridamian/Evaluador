unit uBaseEditoresVariables;

  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType, LMessages,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, uReferenciaMonitor,
  uBaseFormularios,
  uBaseAltasMonitores, uCosaConNombre, StdCtrls, uVarDefs, uBaseEditores,
  utilidades, uBaseAltasEditores;

type
  TBaseEditoresVariables = class(TBaseEditores)
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BCancelarClick(Sender: TObject);
  protected
    referencia: TReferenciaDefVar;
    ListaDeCosas: TListaDeCosasConNombre;
    guardado: boolean;

    //    function validarFormulario : boolean; virtual; abstract;

    procedure CambioCBActor(CBN_y_C, CBvar: TComboBox);
    procedure setCBActorYVariable(CBN_y_C, CBvar: TComboBox;
      variable: TReferenciaDefVar);
  public
    constructor Create(AOwner: TBaseAltasMonitores;
      ListaDeCosas: TListaDeCosasConNombre; ClasesCosas: TStrings;
      variable: TReferenciaDefVar); reintroduce;
    function darVariable: TReferenciaDefVar;
  end;

implementation

  {$R *.lfm}


constructor TBaseEditoresVariables.Create(AOwner: TBaseAltasMonitores;
  ListaDeCosas: TListaDeCosasConNombre; ClasesCosas: TStrings;
  variable: TReferenciaDefVar);
begin
  inherited Create(AOwner, variable, nil);
  Self.ListaDeCosas := ListaDeCosas;
  self.Top := AOwner.Top + plusTop;
  self.Left := AOwner.Left + plusLeft;
  referencia := nil;
  guardado := True;
end;

function TBaseEditoresVariables.darVariable: TReferenciaDefVar;
begin
  Result := referencia;
end;

procedure TBaseEditoresVariables.CambioCBActor(CBN_y_C, CBvar: TComboBox);
var
  i: integer;
  nombre, clase: string;
  aux: TCosaConNombre;
begin
  nombre := TBaseAltasMonitores(Owner).darNombre(CBN_y_C.Items[CBN_y_C.ItemIndex]);
  clase := TBaseAltasMonitores(Owner).darClase(CBN_y_C.Items[CBN_y_C.ItemIndex]);
  if ListaDeCosas.find(clase, nombre, i) then
  begin
    aux := TCosaConNombre(ListaDeCosas[i]);
    CBvar.Clear;
    CBvar.Items := TBaseAltasMonitores(
      Owner).claseReferencia.nombresVarsMonitoreables(aux);
    guardado := False;
  end
  else
  begin
    ShowMessage(mesNoSeEncuentraActor);
    CBN_y_C.ItemIndex := -1;
    CBvar.Clear;
    CBvar.ItemIndex := -1;
  end;
end;

procedure TBaseEditoresVariables.setCBActorYVariable(CBN_y_C, CBvar: TComboBox;
  variable: TReferenciaDefVar);
begin
  CBN_y_C.ItemIndex := CBN_y_C.Items.IndexOf(variable.ClaseNombre);
  CambioCBActor(CBN_y_C, CBvar);
  CBvar.ItemIndex := CBvar.Items.IndexOf(variable.nombreVar);
  if (CBN_y_C.ItemIndex <> -1) and (CBvar.ItemIndex = -1) then
    ShowMessage(mesNoSeEncuentraLaVariable);
end;

procedure TBaseEditoresVariables.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  mbResult: integer;
begin
  if ModalResult <> mrOk then
  begin
    if (not guardado) then
    begin
      mbResult := Application.MessageBox(PChar(mesNoGuardadoCambiosGuardarAhora),
        PChar(mesConfirmarSalida), MB_YESNOCANCEL or MB_ICONEXCLAMATION);

      if mbResult = idYes then
      begin
        BGuardarClick(Sender);
        CanClose := ModalResult = mrOk;
      end
      else if mbResult = idNo then
      begin
        CanClose := True;
        ModalResult := mrAbort;
      end
      else
        CanClose := False;
    end
    else
    begin
      ModalResult := mrAbort;
      CanClose := True;
    end;
  end;
end;

procedure TBaseEditoresVariables.BCancelarClick(Sender: TObject);
begin
  self.Close;
end;

end.