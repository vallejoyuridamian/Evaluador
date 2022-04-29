unit uAltaEdicionTCronOper_filtrarCronica;


interface

uses
  {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  uBaseAltaEdicionCronOpers, uLectorSimRes3Defs, uVerDoc,
  uHistoVarsOps;

type
  TAltaEdicionTCronOper_filtrarCronica = class(TBaseAltaEdicionCronOpers)
    lResultado: TLabel;
    lIndice: TLabel;
    eNCronica: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    eKCronica: TEdit;
    procedure BAyudaClick(Sender: TObject);
    procedure CBCronVarChange(Sender: TObject);
    procedure CBIndiceChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditIntExit(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
  protected
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs;
      cronOper: TCronOper; tipoCronOper: TClaseDeCronOper); override;
  end;

implementation

uses SimSEEEditMain;
{$R *.lfm}

procedure TAltaEdicionTCronOper_filtrarCronica.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TCronOper_filtrarCronica);
end;

procedure TAltaEdicionTCronOper_filtrarCronica.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTCronOper_filtrarCronica.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if cronOper = nil then
      cronOper := TCronOper_filtrarCronica.Create(valorCBCronVar(cbRes),
        valorCBIndice(cbParam1),
        StrToInt(eKCronica.Text))
    else
    begin
      TCronOper_filtrarCronica(cronOper).res := valorCBCronVar(cbRes);
      TCronOper_filtrarCronica(cronOper).param1 := valorCBIndice(cbParam1);
      TCronOper_filtrarCronica(cronOper).kCronica := StrToInt(eKCronica.Text);
    end;
    ModalResult := mrOk;
  end;
end;

procedure TAltaEdicionTCronOper_filtrarCronica.CBCronVarChange(Sender: TObject);
begin
  inherited CBCronVarChange(Sender, True);
end;

procedure TAltaEdicionTCronOper_filtrarCronica.CBIndiceChange(Sender: TObject);
begin
  inherited CBIndiceChange(Sender, True);
end;

constructor TAltaEdicionTCronOper_filtrarCronica.Create(AOwner: TComponent;
  lector: TLectorSimRes3Defs; cronOper: TCronOper; tipoCronOper: TClaseDeCronOper);
begin
  inherited Create(AOwner, lector, cronOper, tipoCronOper);

  inicializarCBCronVars(cbRes, False);
  inicializarCBIndices(cbParam1, False);

  if cronOper <> nil then
  begin
    setCBCronVar(cbRes, TCronOper_filtrarCronica(cronOper).res);
    setCBIndice(cbParam1, TCronOper_filtrarCronica(cronOper).param1);
    eKCronica.Text := IntToStr(TCronOper_filtrarCronica(cronOper).kCronica);
  end;
end;

procedure TAltaEdicionTCronOper_filtrarCronica.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTCronOper_filtrarCronica.EditIntExit(Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, FSimSEEEdit.sala.globs.NCronicasSim);
end;

procedure TAltaEdicionTCronOper_filtrarCronica.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

function TAltaEdicionTCronOper_filtrarCronica.validarFormulario: boolean;
begin
  Result := validarCBCronVars(cbRes) and validarCBIndices(cbParam1) and
    validarEditInt(eKCronica, 1, FSimSEEEdit.sala.globs.NCronicasSim);
end;

end.
