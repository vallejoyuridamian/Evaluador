unit ualtaediciontpostoper_acumularconpisoytecho;
interface

uses
 {$IFDEF WINDOWS}
  Windows,
 {$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
 Dialogs, StdCtrls, ExtCtrls, xMatDefs, uHistoVarsOps,
 uBaseAltaEdicionPostOpers,
 uLectorSimRes3Defs, uVerDoc,
 uPostOpers;

type

  { TAltaEdicionTPostOper_acumularConPisoYTecho }

  TAltaEdicionTPostOper_acumularConPisoYTecho = class(TBaseAltaEdicionPostOpers)
    cbTecho: TComboBox;
    cbPiso: TComboBox;
    eValIni: TLabeledEdit;
    lblTecho: TLabel;
    lblPiso: TLabel;
    lResultado: TLabel;
    lCronVar: TLabel;
    cbRes: TComboBox;
    cbIngreso: TComboBox;
    bGuardar: TButton;
    bCancelar: TButton;
    BAyuda: TButton;
    procedure BAyudaClick(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCronVarResultadoChange(Sender: TObject);
    procedure CBCronVarCronVarChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  protected
    function validarFormulario: boolean; override;
  public
    Constructor Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper); override;
  end;

implementation
  {$R *.lfm}

procedure TAltaEdicionTPostOper_acumularConPisoYTecho.CBCronVarCronVarChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbRes, true);
end;

procedure TAltaEdicionTPostOper_acumularConPisoYTecho.FormCreate(Sender: TObject
  );
begin

end;




procedure TAltaEdicionTPostOper_acumularConPisoYTecho.CBCronVarResultadoChange(
  Sender: TObject);
begin
  inherited cbCronVarComplementarioChange(Sender, cbIngreso, true);
end;

Constructor TAltaEdicionTPostOper_acumularConPisoYTecho.Create(AOwner: TComponent; lector: TLectorSimRes3Defs; postOper: TPostOper; tipoPostOper: TClaseDePostOper);
begin
  inherited Create(AOwner, lector, postOper, tipoPostOper);

  inicializarCBCronVars(cbRes, false);
  inicializarCBCronVars(cbIngreso, false);
  inicializarCBCronVars(cbPiso, false);
  inicializarCBCronVars(cbTecho, false);

  if postOper <> NIL then
  begin
    setCBCronVar(cbRes, TPostOper_acumularConPisoYTecho(postOper).res);
    setCBCronVar(cbIngreso, TPostOper_acumularConPisoYTecho(postOper).Ingreso);
    setCBCronVar(cbPiso, TPostOper_acumularConPisoYTecho(postOper).Piso);
    setCBCronVar(cbTecho, TPostOper_acumularConPisoYTecho(postOper).Techo);
    eValIni.Text:= FloatToStr( TPostOper_acumularConPisoYTecho(postOper).ValIni );
  end
  else
    eValIni.Text:= FloatToStr( 0.0 );
end;

function TAltaEdicionTPostOper_acumularConPisoYTecho.validarFormulario: boolean;
begin
  result:= validarCBCronVars(cbRes)
  and validarCBCronVars(cbIngreso)
  and validarCBCronVars(cbPiso)
  and validarCBCronVars(cbTecho);
end;

procedure TAltaEdicionTPostOper_acumularConPisoYTecho.BAyudaClick(Sender: TObject);
begin
  verdoc(Self, TPostOper_acumularConPisoYTecho);
end;

procedure TAltaEdicionTPostOper_acumularConPisoYTecho.bCancelarClick(Sender: TObject);
begin
  inherited bCancelarClick(Sender);
end;

procedure TAltaEdicionTPostOper_acumularConPisoYTecho.bGuardarClick(Sender: TObject);
begin
  if validarFormulario then
  begin
    if postOper = NIL then
    begin
      postOper:= TPostOper_acumularConPisoYTecho.Create(
        valorCBCronVar(cbRes),
        valorCBCronVar(cbIngreso),
        valorCBCronVar(cbPiso),
        valorCBCronVar(cbTecho),
        StrToFloat( eValIni.text ) );
    end
    else
    begin
      TPostOper_acumularConPisoYTecho(postOper).SetParametros(
        valorCBCronVar(cbRes),
        valorCBCronVar(cbIngreso),
        valorCBCronVar(cbPiso),
        valorCBCronVar(cbTecho),
        StrToFloat( eValIni.text ) );
    end;
    ModalResult:= mrOk;
  end;
end;

procedure TAltaEdicionTPostOper_acumularConPisoYTecho.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

end.
