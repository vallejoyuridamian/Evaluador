unit uFormSelectTipo;
  {$MODE Delphi}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, utilidades, Math;

resourcestring
  mesSeleccionarTipoDeLaLista = 'Debe seleccionar un tipo de la lista';

type

  { TFormSelectTipo }

  TFormSelectTipo = class(TForm)
    BAceptar: TButton;
    BCancelar: TButton;
    lbSelectTipo: TListBox;
    Panel1: TPanel;
    procedure BCancelarClick(Sender: TObject);
    procedure BAceptarClick(Sender: TObject);
    procedure lbSelectTipoDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TForm; tipos: TStrings); reintroduce; overload;
    constructor Create(AOwner: TForm; Caption: string; tipos: TStrings);
      reintroduce; overload;
    function darTipo: string;
    function ShowModal: integer; override;
  end;

function selectTipo(AOwner: TForm; tipos: TStrings): string;

implementation

  {$R *.lfm}

constructor TFormSelectTipo.Create(AOwner: TForm; tipos: TStrings);
var
  i: integer;
begin
  inherited Create(AOwner);
  self.Top := AOwner.Top + utilidades.plusTop;
  self.Left := AOwner.Left + utilidades.plusLeft;

  for i := 0 to tipos.Count - 1 do
    lbSelectTipo.Items.Add(tipos[i]);
  lbSelectTipo.ItemIndex := 0;

  {$IFDEF FPC}
  lbSelectTipo.ItemHeight := 12;
  //Fix agregado en la migracion de proyecto porque no estaba inicializado
  {$ENDIF}

  lbSelectTipo.Height := min((lbSelectTipo.Items.Count + 1), 10) *
    lbSelectTipo.ItemHeight;
end;

constructor TFormSelectTipo.Create(AOwner: TForm; Caption: string; tipos: TStrings);
begin
  Create(AOwner, tipos);
  self.Caption := Caption;
end;

function TFormSelectTipo.darTipo: string;
begin
  Result := lbSelectTipo.Items[lbSelectTipo.ItemIndex];
end;

procedure TFormSelectTipo.FormShow(Sender: TObject);
begin
  lbSelectTipo.SetFocus;
end;

procedure TFormSelectTipo.lbSelectTipoDblClick(Sender: TObject);
begin
  BAceptarClick(Sender);
end;

function TFormSelectTipo.ShowModal: integer;
begin
  if lbSelectTipo.Items.Count = 1 then
    Result := mrOk
  else
    Result := inherited ShowModal;
end;

procedure TFormSelectTipo.BCancelarClick(Sender: TObject);
begin
  ModalResult := mrAbort;
end;

procedure TFormSelectTipo.BAceptarClick(Sender: TObject);
begin
  if (lbSelectTipo.ItemIndex > -1) and (lbSelectTipo.ItemIndex <
    lbSelectTipo.Items.Count) then
    ModalResult := mrOk
  else
    ShowMessage(mesSeleccionarTipoDeLaLista);
end;

function selectTipo(AOwner: TForm; tipos: TStrings): string;
var
  res: string;
  formSelectTipo: TFormSelectTipo;
begin
  formSelectTipo := TFormSelectTipo.Create(AOwner, tipos);
  if formSelectTipo.ShowModal = mrOk then
    res := formSelectTipo.darTipo
  else
    res := '';
  formSelectTipo.Free;
  Result := Res;
end;

end.
