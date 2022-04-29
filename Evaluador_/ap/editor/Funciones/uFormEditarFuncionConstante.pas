unit uFormEditarFuncionConstante;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFunciones, StdCtrls, xMatDefs, uFunciones, uSalasDeJuego;

type
  TEditarFuncionConstante = class(TBaseEditoresFunciones)
    EValor: TEdit;
    lValor: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    ENombre: TEdit;
    lNombre: TLabel;
    procedure FormResize(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EValorExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
  protected
    funcion : TFuncion_Constante;
    
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner : TForm ; func : TFuncion ; Sala : TSalaDeJuego ; alta : boolean ; tipoFunc : TClaseDeFuncion); reintroduce; virtual;
    function darFuncion: TFuncion; override;    
  end;

var
  EditarFuncionConstante: TEditarFuncionConstante;

implementation

{$R *.dfm}

Constructor TEditarFuncionConstante.Create(AOwner : TForm ; func : TFuncion ; Sala : TSalaDeJuego; alta : boolean ; tipoFunc : TClaseDeFuncion);
begin
	inherited Create(AOwner, func, Sala, alta, tipoFunc);
	if func <> NIL then
	begin
		ENombre.Text := func.nombre;
    self.funcion := funcion.Create_Clone as TFuncion_Constante;
	end
  else
    self.funcion := TFuncion_Constante(tipoFunc).Create('Auxiliar', 0);
end;

function TEditarFuncionConstante.darFuncion: TFuncion;
begin
  result:= funcion;
end;

function TEditarFuncionConstante.validarFormulario: boolean;
begin
  result:= inherited validarFormulario and
           inherited validarEditNombre(ENombre) and
           inherited validarEditFloat(EValor, -MaxNReal, MaxNReal);
end;

procedure TEditarFuncionConstante.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFuncionConstante.BGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    funcion.nombre:= ENombre.Text;
    funcion.valor:= StrToFloat(EValor.Text);
    ModalResult:= mrOk;
  end;
end;

procedure TEditarFuncionConstante.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFuncionConstante.EValorExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, -MaxNReal, MaxNReal);
end;

procedure TEditarFuncionConstante.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFuncionConstante.FormResize(Sender: TObject);
begin
  inherited centrarBotones(BGuardar, BCancelar);
end;

end.
