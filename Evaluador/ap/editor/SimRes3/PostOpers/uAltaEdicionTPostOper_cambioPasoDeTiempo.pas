unit uAltaEdicionTPostOper_cambioPasoDeTiempo;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFDEF FPC-LCL}
  LResources,
{$ENDIF}

{$IFDEF WINDOWS}
Windows,
{$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xMatDefs, uHistoVarsOps,
  uBaseAltaEdicionPostOpers, uLectorSimRes3Defs, uVerDoc,
  uPostOpers, ExtCtrls;

type

  { TAltaEdicionTPostOper_cambioPasoDeTiempo }

  TAltaEdicionTPostOper_cambioPasoDeTiempo = class(TBaseAltaEdicionPostOpers)
    e_j_esima_entrada: TEdit;
    lResultado: TLabel;
    lCronVar: TLabel;
    lHorasPasoNuevo: TLabel;
    cbRes: TComboBox;
    cbParam1: TComboBox;
    BAyuda: TButton;
    eHorasPasoNuevo: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    bGuardar: TButton;
    bCancelar: TButton;
    rb_jesima: TRadioButton;
    rbSuma: TRadioButton;
    rbProm: TRadioButton;
    rbMin: TRadioButton;
    rbMax: TRadioButton;
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditFloatExit(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarResultadoChange(Sender: TObject);
    procedure CBCronVarCronVarChange(Sender: TObject);
    procedure rb_jesimaChange(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
    function GetTCPT: TTipoCPT;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper); override;
  end;

implementation
{$IFNDEF FPC-LCL}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TAltaEdicionTPostOper_cambioPasoDeTiempo.CBCronVarCronVarChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, True);
end;

procedure TAltaEdicionTPostOper_cambioPasoDeTiempo.rb_jesimaChange(
  Sender: TObject);
begin
  e_j_esima_entrada.Text:='';
  e_j_esima_entrada.Enabled:=rb_jesima.Checked;
end;

procedure TAltaEdicionTPostOper_cambioPasoDeTiempo.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbParam1, True);
end;

constructor TAltaEdicionTPostOper_cambioPasoDeTiempo.Create(AOwner: TComponent;
  lector: TLectorSimRes3Defs; postOper: TPostOper;
  tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBCronVars(cbParam1, false);

  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_cambioPasoDeTiempo(postOper).res);
    setCBCronVar(cbParam1, TPostOper_cambioPasoDeTiempo(postOper).param1);
    eHorasPasoNuevo.Text:= FloatToStrF(TPostOper_cambioPasoDeTiempo(postOper).horasPasoNuevo, ffGeneral, 16, 10);

    case TPostOper_cambioPasoDeTiempo(postOper).tipoCPT of
      TCPT_Suma:
          rbSuma.Checked:=True;
      TCPT_Promedio:
          rbProm.Checked:=True;
      TCPT_Minimo:
          rbMin.Checked:=True;
      TCPT_Maximo:
          rbMax.Checked:=True;
      TCPT_I_esimo:
        begin
          rb_jesima.Checked:=True;
          e_j_esima_entrada.Text:=IntToStr(TPostOper_cambioPasoDeTiempo(postOper).jesimaEntrada);
        end;
    end;
  end
  else
    rbSuma.Checked:=True;
end;

function TAltaEdicionTPostOper_cambioPasoDeTiempo.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes) and
           validarCBCronVars(cbParam1) and
           (not rb_jesima.Checked or validarEditFloat(eHorasPasoNuevo, 0.0, MaxNReal));
end;

function TAltaEdicionTPostOper_cambioPasoDeTiempo.GetTCPT: TTipoCPT;
begin
  if rbSuma.Checked then Result:=TCPT_Suma;
  if rbProm.Checked then Result:=TCPT_Promedio;
  if rbMin.Checked then Result:=TCPT_Minimo;
  if rbMax.Checked then Result:=TCPT_Maximo;
  if rb_jesima.Checked then Result:=TCPT_I_esimo;
end;

procedure TAltaEdicionTPostOper_cambioPasoDeTiempo.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_cambioPasoDeTiempo);
end;

procedure TAltaEdicionTPostOper_cambioPasoDeTiempo.bCancelarClick(
  Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_cambioPasoDeTiempo.BGuardarClick(Sender: TObject
  );
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      if rb_jesima.Checked then
        postOper:= TPostOper_cambioPasoDeTiempo.Create(valorCBCronVar(cbRes),
                                                       valorCBCronVar(cbParam1),
                                                       StrToFloat(eHorasPasoNuevo.Text),
                                                       TCPT_I_esimo,
                                                       StrToInt(e_j_esima_entrada.Text))
      else
        postOper:= TPostOper_cambioPasoDeTiempo.Create(valorCBCronVar(cbRes),
                                                       valorCBCronVar(cbParam1),
                                                       StrToFloat(eHorasPasoNuevo.Text),
                                                       GetTCPT);

    end
    else
    begin
      TPostOper_cambioPasoDeTiempo(postOper).res:= valorCBCronVar(cbRes);
      TPostOper_cambioPasoDeTiempo(postOper).param1:= valorCBCronVar(cbParam1);
      TPostOper_cambioPasoDeTiempo(postOper).horasPasoNuevo:= StrToFloat(eHorasPasoNuevo.Text);
      TPostOper_cambioPasoDeTiempo(postOper).tipoCPT:= GetTCPT;
      if rb_jesima.Checked then
        TPostOper_cambioPasoDeTiempo(postOper).jesimaEntrada:=StrToInt(e_j_esima_entrada.Text)
      else
        TPostOper_cambioPasoDeTiempo(postOper).jesimaEntrada:=-1;
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_cambioPasoDeTiempo.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TAltaEdicionTPostOper_cambioPasoDeTiempo.EditFloatExit(
  Sender: TObject);
begin
  inherited EditFloatExit(Sender, 0.01, MaxNReal);
end;

procedure TAltaEdicionTPostOper_cambioPasoDeTiempo.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

initialization
end.
