unit ualtaediciontpostoper_crearconstantereal;
interface

uses
{$IFDEF WINDOWS}
  Windows,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xMatDefs, uHistoVarsOps,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers, ExtCtrls;

type

  { TAltaEdicionTPostOper_CrearConstanteReal }

  TAltaEdicionTPostOper_CrearConstanteReal = class(TBaseAltaEdicionPostOpers)
    e_aReal: TLabeledEdit;
    lResultado: TLabel;
    cbRes: TComboBox;
    BAyuda: TButton;
    Panel1: TPanel;
    bGuardar: TButton;
    bCancelar: TButton;
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs;
      postOper: TPostOper; tipoPostOper: TClaseDePostOper); override;
  end;

implementation
  {$R *.lfm}


constructor TAltaEdicionTPostOper_CrearConstanteReal.Create(AOwner: TComponent;
  lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, False);

  if postOper <> nil then
  begin
    setCBCronVar(cbRes, TPostOper_CrearConstanteReal(postOper).res);
    e_aReal.Text:= FloatToStrF(TPostOper_CrearConstanteReal(postOper).aReal, ffGeneral, 12, 6);
  end;
end;

function TAltaEdicionTPostOper_CrearConstanteReal.validarFormulario: boolean;
begin
  Result := validarCBCronVars(cbRes)  and
    validarEditFloat(e_aReal);
end;

procedure TAltaEdicionTPostOper_CrearConstanteReal.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_CrearConstanteReal);
end;

procedure TAltaEdicionTPostOper_CrearConstanteReal.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_CrearConstanteReal.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = nil then
    begin
      postOper := TPostOper_CrearConstanteReal.Create(valorCBCronVar(cbRes),
        StrToFloat(e_aReal.Text) );
    end
    else
    begin
      TPostOper_CrearConstanteReal(postOper).res := valorCBCronVar(cbRes);
      TPostOper_CrearConstanteReal(postOper).aReal := StrToFloat(e_aReal.Text);
    end;
    ModalResult := mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_CrearConstanteReal.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTPostOper_CrearConstanteReal.EditFloatExit(Sender: TObject);
begin
  inherited EditFloatExit(Sender, 0.01, MaxNReal);
end;

procedure TAltaEdicionTPostOper_CrearConstanteReal.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);

begin
  inherited FormCloseQuery(Sender, CanClose);
end;

initialization
end.
