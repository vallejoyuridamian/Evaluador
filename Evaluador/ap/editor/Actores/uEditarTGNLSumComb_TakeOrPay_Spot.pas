unit uEditarTGNLSumComb_TakeOrPay_Spot;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids,
  uGNLSumComb_TakeOrPay_Spot,
  uEditarActorConFichas,
  uFichasLPD,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSuministrocombustible,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uConstantesSimSEE,
  xMatDefs;

type
  TEditarTGNLSumComb_TakeOrPay_Spot = class(TEditarActorConFichas)
    LNombre: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LVEstado: TLabel;
    LNDisc: TLabel;
    LHIni: TLabel;
    LFichas: TLabel;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    sgFichas: TStringGrid;
    BAgregarFicha: TButton;
    BGuardar: TButton;
    BCancelar: TButton;
    EVDispToP: TEdit;
    ENDisc: TEdit;
    Panel1: TPanel;
    BVerExpandida: TButton;
    BAyuda: TButton;
    CBCombustibles: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ECargamentos: TEdit;
    EArribos: TEdit;
    lblV_Max: TLabel;
    Label5: TLabel;
    eV_Max: TEdit;
    eT_Arribo: TEdit;
    eNDisSpot: TEdit;
    Label4: TLabel;
    Label6: TLabel;
    chkFavorecerDescarga: TCheckBox;
    Label7: TLabel;
    chkCostoVariableCero: TCheckBox;
    ECostoVariable: TEdit;
    procedure BAyudaClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure CBCombustibleChange(Sender: TObject);

  private
    { Private declarations }
  public

    combustibleSeleccionado:TCombustibleSGE;

    Constructor Create(AOwner: TComponent; sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;

    procedure inicializarCBcombustibles(CBcombustibles: TComboBox);
    procedure setCBCombustible(CBCombustibles: TComboBox;  combustible: TCombustibleSGE);
    function valorCBCombustible(CBCombustibles: TComboBox): TCombustibleSGE;
    procedure BCancelarClick(Sender: TObject);


  end;

var
  EditarTGNLSumComb_TakeOrPay_Spot: TEditarTGNLSumComb_TakeOrPay_Spot;

implementation

uses SimSEEEditMain;

{$R *.dfm}


procedure TEditarTGNLSumComb_TakeOrPay_Spot.inicializarCBcombustibles(CBcombustibles: TComboBox);
var
  i: Integer;
begin

  for i:= 0 to high(Combustibles) do
    CBCombustibles.Items.Add(Combustibles[i].Nombre);

  CBCombustibles.ItemIndex:= 0;
  CBCombustibles.Tag:= CBcombustibles.ItemIndex;
  combustibleSeleccionado:=Combustibles[0];
  LHIni.Caption :='Volumen Disponible Inicial[' + combustibleSeleccionado.Unidades + ']:';
  lblV_Max.Caption := 'Volumen máximo del tanque ['+ combustibleSeleccionado.Unidades + ']:';
end;

procedure TEditarTGNLSumComb_TakeOrPay_Spot.CBCombustibleChange(
  Sender: TObject);
begin
    combustibleSeleccionado:=Combustibles[CBCombustibles.ItemIndex];
     LHIni.Caption :='Volumen Disponible Inicial[' + combustibleSeleccionado.Unidades + ']:';
     lblV_Max.Caption := 'Volumen máximo del tanque ['+ combustibleSeleccionado.Unidades + ']:';
end;

procedure TEditarTGNLSumComb_TakeOrPay_Spot.setCBCombustible(CBCombustibles: TComboBox;  combustible: TCombustibleSGE);
var d : string;
begin
   CBCombustibles.ItemIndex:= CBCombustibles.Items.IndexOf(combustible.Nombre);
   CBCombustibles.Tag:= CBCombustibles.ItemIndex;
   combustibleSeleccionado:=combustible;
   LHIni.Caption:='Volumen Disponible Inicial[' + combustibleSeleccionado.Unidades + ']:';
   lblV_Max.Caption := 'Volumen máximo del tanque ['+ combustibleSeleccionado.Unidades + ']:';
end;


function TEditarTGNLSumComb_TakeOrPay_Spot.valorCBCombustible(CBCombustibles: TComboBox): TCombustibleSGE;
begin
    result:= TCombustibleSGE(Combustibles[CBCombustibles.ItemIndex]);
end;

procedure TEditarTGNLSumComb_TakeOrPay_Spot.BCancelarClick(Sender: TObject);
begin
     combustibleSeleccionado := valorCBCombustible(TComboBox(Sender));
end;


Constructor TEditarTGNLSumComb_TakeOrPay_Spot.Create(AOwner: TComponent; sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TGNLSumComb_TakeOrPay_Spot;
  i:integer;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  utilidades.AgregarFormatoFecha(LFNac);
	utilidades.AgregarFormatoFecha(LFMuerte);

  inicializarCBcombustibles(CBCombustibles);


  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> NIL then
  begin

    actor:= TGNLSumComb_TakeOrPay_Spot(cosaConNombre);


    inicializarComponentesLPD(actor.lpd, TGNLFichaSumComb_TakeOrPay_Spot,  sgFichas,
                              BAgregarFicha, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text:= actor.nombre;

	  EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
  	EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);


    setCBCombustible(CBCombustibles,actor.combustible);

    EVDispToP.Text := FloatToStrF(actor.VDisp_Ini , ffGeneral, CF_PRECISION, CF_DECIMALES);
    ENDisc.Text := IntToStr(actor.NDisc);
    ECargamentos.Text := DAOfNRealToStr_(actor.V_Spot, 6, 2, ';');
    if length(actor.T_Ini_Spot)<>0 then begin
      EArribos.Text := InttoStr(actor.T_Ini_Spot[0]);
      for i := 1 to high(actor.T_Ini_Spot) do
          EArribos.Text := EArribos.Text + ';' + InttoStr(actor.T_Ini_Spot[i]);
    end;

    eT_Arribo.Text := IntToStr(actor.T_Arribo);
    eNDisSpot.Text := IntToStr(actor.NDiscSpot);
    eV_Max.Text := FloatToStr(actor.V_Max);
    chkFavorecerDescarga.Checked:=actor.B_FavorecerDescarga;
    chkCostoVariableCero.Checked:=actor.B_CostoVariableCero;
    ECostoVariable.Text := FloatToStrF(actor.CV_Fijado , ffGeneral, CF_PRECISION, CF_DECIMALES);
  end
  else
    inicializarComponentesLPD(NIL, TGNLFichaSumComb_TakeOrPay_Spot, sgFichas,
                              BAgregarFicha, BVerExpandida, BGuardar, BCancelar);


end;


function TEditarTGNLSumComb_TakeOrPay_Spot.validarFormulario: boolean;
begin
	result:= inherited validarFormulario and
           inherited validarNombre(EditNombre) and
					 inherited validarEditFecha(EFNac) and
           inherited validarEditFecha(EFMuerte) and
           inherited validarEditFloat(EVDispToP, 0, MaxNReal) and
           inherited validarEditInt(eNDisSpot, 2, MaxInt) and
           inherited validarEditInt(ENDisc, 2, MaxInt);
end;


procedure TEditarTGNLSumComb_TakeOrPay_Spot.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, TGNLSumComb_TakeOrPay_Spot);
end;



procedure TEditarTGNLSumComb_TakeOrPay_Spot.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;



procedure TEditarTGNLSumComb_TakeOrPay_Spot.BGuardarClick(Sender: TObject);
var
  actor : TGNLSumComb_TakeOrPay_Spot;
begin
  if validarFormulario then
	begin
    if cosaConNombre = NIL then
      begin
      cosaConNombre:= TGNLSumComb_TakeOrPay_Spot.Create(
                               EditNombre.Text,
                               valorCBCombustible(CBCombustibles).nombre,
                               FSimSEEEdit.StringToFecha(EFNac.Text),
                               FSimSEEEdit.StringToFecha(EFMuerte.Text),
                               lpdUnidades, lpd,
                               StrToFloat(EVDispToP.Text),
                               StrToInt(ENDisc.Text),
                               strToDAOfNReal_( ECargamentos.text, ';' ),
                               strToInt(eNDisSpot.Text),
                               strtoDaofNInt(EArribos.Text,';'),
                               StrToInt(ET_Arribo.text),
                               StrToFloat(EV_Max.Text),
                               chkFavorecerDescarga.Checked,
                               chkCostoVariableCero.Checked,
                               StrtoFloat(ECostoVariable.Text));

       end
    else
    begin

      actor:= TGNLSumComb_TakeOrPay_Spot(cosaConNombre);
      actor.nombre:= EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);

      actor.lpdUnidades.Free;
      actor.lpdUnidades:= lpdUnidades;
      actor.lpd.Free;
      actor.lpd:= lpd;
      actor.combustible:=combustibleSeleccionado;

      actor.VDisp_Ini := StrToFloat(EVDispToP.Text);
      actor.NDisc:= StrToInt(ENDisc.Text);
      actor.V_Spot:=strToDAOfNReal_( ECargamentos.text, ';' );
      actor.T_Ini_Spot:=strtoDaofNInt(EArribos.Text,';');
      actor.V_Max := strToFloat(eV_Max.Text);
      actor.T_Arribo := strToInt(eT_Arribo.Text);
      actor.NDiscSpot:= StrToInt(eNDisSpot.Text);
      actor.B_FavorecerDescarga:=chkFavorecerDescarga.Checked;
      actor.B_CostoVariableCero:=chkCostoVariableCero.Checked;
      actor.CV_Fijado:=strToFloat(ECostoVariable.Text);

    end;

    ModalResult:= mrOk;
	end
end;

procedure TEditarTGNLSumComb_TakeOrPay_Spot.CambiosForm(Sender: TObject);
begin
  inherited CambiosForm(Sender);
end;



procedure TEditarTGNLSumComb_TakeOrPay_Spot.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTGNLSumComb_TakeOrPay_Spot.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTGNLSumComb_TakeOrPay_Spot.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarTGNLSumComb_TakeOrPay_Spot.FormResize(Sender: TObject);
begin
  utilidades.centrar2Botones(self, BGuardar, BCancelar);
end;
end.
