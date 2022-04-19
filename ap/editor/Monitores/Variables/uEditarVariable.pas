unit uEditarVariable;

  {$MODE Delphi}

interface

uses
   {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  LCLType,
  {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uReferenciaMonitor, uCosaConNombre, uBaseEditoresVariables,
  uBaseAltasMonitores,
  uVarDefs, ComCtrls, uActores;

resourcestring
  mesSeleccionarActorLista = 'Debe seleccionar un actor de la lista';
  mesSeleccionarVariableLista = 'Debe seleccionar una variable de la lista';

type
  TEditarVariable = class(TBaseEditoresVariables)
    LClaseNombre: TLabel;
    CBNombre_Y_Clase: TComboBox;
    LNVar: TLabel;
    CBVariable: TComboBox;
    BAgregarVar: TButton;
    BCancelar: TButton;
    procedure CBNombre_Y_ClaseChange(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BCancelarClick(Sender: TObject);
    procedure FillTree(tree: TTreeView; cosa: TCosaConNombre);
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TBaseAltasMonitores; ListaDeCosas: TListaDeCosasConNombre;
      ClasesCosas: TStrings; variable: TReferenciaDefVar); reintroduce;
  end;

implementation

  {$R *.lfm}

constructor TEditarVariable.Create(AOwner: TBaseAltasMonitores;
  ListaDeCosas: TListaDeCosasConNombre; ClasesCosas: TStrings;
  variable: TReferenciaDefVar);
begin
  inherited Create(AOwner, ListaDeCosas, ClasesCosas, variable);
  CBNombre_Y_Clase.Items := ClasesCosas;
  if variable <> nil then
  begin
    inherited setCBActorYVariable(CBNombre_Y_Clase, CBVariable, variable);
  end;
  guardado := True;
end;

function TEditarVariable.validarFormulario: boolean;
begin
  if CBNombre_Y_Clase.ItemIndex <> -1 then
  begin
    if CBVariable.ItemIndex <> -1 then
    begin
      Result := True;
    end
    else
    begin
      ShowMessage(mesSeleccionarVariableLista);
      Result := False;
    end;
  end
  else
  begin
    ShowMessage(mesSeleccionarActorLista);
    Result := False;
  end;
end;

procedure TEditarVariable.CBNombre_Y_ClaseChange(Sender: TObject);
begin
  inherited CambioCBActor(CBNombre_Y_Clase, CBVariable);
end;

procedure TEditarVariable.CambiosForm(Sender: TObject);
begin
  guardado := False;
end;

procedure TEditarVariable.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarVariable.BGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
{$IFDEF ARBOL}
    referencia := TReferenciaDefVar.Create(capa, TBaseAltasMonitores(
      Owner).darNombre(CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]),
      TBaseAltasMonitores(Owner).darClase(
      CBNombre_Y_Clase.Items[CBNombre_Y_Clase.ItemIndex]),
      CBVariable.Items[CBVariable.ItemIndex]);
{$ENDIF}
    ModalResult := mrOk;
  end;
end;

procedure TEditarVariable.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarVariable.FillTree(tree: TTreeView; cosa: TCosaConNombre);
var
  i, j: integer;
  primerNodo, hijo: TTreeNode;
begin
  primerNodo := tree.Items.AddFirst(TTreeNode.Create(tree.items),
    cosa.ClassName + ', ' + cosa.nombre);
  for i := 0 to cosa.pubvarlst.Count - 1 do
  begin
    hijo := tree.Items.AddChild(primerNodo, TVarDef(cosa.pubvarlst[i]).nombreVar);
    if TVarDef(cosa.pubvarlst[i]).esV then
      for j := 0 to TVarDef_V(cosa.pubvarlst[i]).highVarDef do
        tree.Items.AddChild(hijo, TVarDef(cosa.pubvarlst[i]).nombreVar +
          '[' + IntToStr(i + 1) + ']');
  end;
end;

end.