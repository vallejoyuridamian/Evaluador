unit ueditarRegasificadora;

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ComCtrls, ExtCtrls,
  uEditarActorConFichas,
  ufichasLPD,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uConstantesSimSEE,
  xMatDefs,
  uRegasificadora,
  uCrearBinDatosHorarios,
  uAgendaGNL,
  uopencalc,
  uopencalcexportimport;

type

  { TEditarRegasificadora }

  TEditarRegasificadora = class(TEditarActorConFichas)
    BExportar_ods: TButton;
    BImportar_ods: TButton;
    btEditarForzamientos: TButton;
    BVerExpandida: TButton;
    cbNodoComb: TComboBox;
    eX_SpotYDesvios: TMemo;
    EFInicioAgenda: TEdit;
    ePrecioSpot: TEdit;
    ePrecioDesvio: TEdit;
    ePrecioVertimiento: TEdit;
    ePrecioAgenda: TEdit;
    eVGNL_inicial: TEdit;
    eNroDiscret: TEdit;
    eVGNL_cargo: TEdit;
    ePASOS_X_SpotYDesvios: TLabeledEdit;
    lblAgenda: TLabel;
    lblAgendaSpot: TLabel;
    lbNodoCombA: TLabel;
    LFInicioAgenda: TLabel;
    LPrecioVertimiento: TLabel;
    LPrecioAgenda: TLabel;
    LPrecioSpot: TLabel;
    LPrecioDesvio: TLabel;
    LV_GNLini: TLabel;
    LNombre: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LFichas: TLabel;
    LNroDiscret: TLabel;
    LV_GNLcargo: TLabel;
    eAgenda: TMemo;
    OpenDialog1: TOpenDialog;
    sgFichas: TStringGrid;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    BAgregarFichaCAYA: TButton;
    BGuardar: TButton;
    BCancelar: TButton;
    BEditorDeUnidades: TButton;
    BAyuda: TButton;
    procedure BAgregarFichaCAYAClick(Sender: TObject);
    procedure BExportar_odsClick(Sender: TObject);
    procedure BImportar_odsClick(Sender: TObject);
    procedure btEditarForzamientosClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;

{$R *.lfm}

constructor TEditarRegasificadora.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TRegasificadora;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);

  inicializarCBNodosCombustible(cbNodoComb, False);


  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);

  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);

  if cosaConNombre <> nil then
  begin
    actor := TRegasificadora(cosaConNombre);
    inicializarComponentesLPD(actor.lpd,
      TFichaRegasificadora, sgFichas,
      BAgregarFichaCAYA, BVerExpandida, BGuardar, BCancelar);

    EditNombre.Text := actor.nombre;
    setCBNodoCombustible(cbNodoComb, actor.NodoComb);

    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    eVGNL_inicial.Text := FloattoStr(actor.VGNL_inicial);
    ENroDiscret.Text := FloattoStr(actor.Ndiscret);

    ePASOS_X_SpotYDesvios.text:= IntToStr( actor.PASOS_X_SpotYDevios );
    eX_SpotYDesvios.Text := actor.X_SpotYDesvios_Inicial_AsBoolStr(
      length(actor.X_SpotYDesvios));

    ePrecioVertimiento.Text := FloatToStr(actor.cvVert);
    ePrecioSpot.Text := FloatToStr(actor.precio_Spot);
    ePrecioDesvio.Text := FloatToStr(actor.precio_Desvio);
    ePrecioAgenda.Text := FloatToStr(actor.precio_Agenda);
    eVGNL_cargo.Text := FloatToStr(actor.VGNL_Cargo);

    if actor.Agenda <> nil then
      eAgenda.Text := actor.Agenda.Cargos_AsBoolStr(52);
    EFInicioAgenda.Text := FSimSEEEdit.fechaIniToString(actor.Agenda.FechaInicioAgenda);
    eVGNL_cargo.Text := FloattoStr(actor.Agenda.VGNL_m3);
    eprecioSpot.Text := FloattoStr(actor.Agenda.precioSpot);
    epreciodesvio.Text := FloattoStr(actor.Agenda.precioDesvio);
    eprecioAgenda.Text := FloattoStr(actor.Agenda.precioAgenda);
  end
  else
  begin
    inicializarComponentesLPD(nil, TFichaRegasificadora, sgFichas,
      BAgregarFichaCAYA, BVerExpandida, BGuardar, BCancelar);


    ePASOS_X_SpotYDesvios.text:= IntToStr( 6 );
    eX_SpotYDesvios.Text := ceros_str( StrToInt(ePASOS_X_SpotYDesvios.text) );

    ePrecioVertimiento.Text := FloatToStr(3.0);
    ePrecioSpot.Text := FloatToStr(18.0);
    ePrecioDesvio.Text := FloatToStr(7.0);
    ePrecioAgenda.Text := FloatToStr(13.0);
    eVGNL_cargo.Text := FloatToStr(145000.0);

  end;
end;

function TEditarRegasificadora.validarFormulario: boolean;
var
  res: boolean;
  r: string;
  nPasos, cnt, k: integer;

begin
  Res := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarCBNodoCombustible(cbNodoComb) and
    inherited validarEditFecha(EFNac) and inherited  validarEditFecha(EFMuerte) and
    inherited validarEditFecha(EFInicioAgenda) and validarEditFloat(
    ePrecioVertimiento) and validarEditFloat(ePrecioSpot) and
    validarEditFloat(ePrecioDesvio) and validarEditFloat(
    ePrecioAgenda) and validarEditFloat(eVGNL_cargo)
    and validarEditInt( ePASOS_X_SpotYDesvios );

  if res then
  begin
    r:= eX_SpotYDesvios.text;
    cnt:= 0;
    for k:= 1 to length( r ) do
      if (r[k] = '0') or (r[k] = '1') then inc( cnt );

    nPasos:= StrToInt( ePASOS_X_SpotYDesvios.text);
    if cnt <> npasos then
    begin
      res:= false;
      showmessage('Pasos de preaviso para compras Spot y Desvio = '+IntToStr(NPasos)+#13#10+'Cantidad de acciones especificadas: '+IntToStr(cnt)+#13#10+'Deben ser iguales');
    end;
  end;
  result:= res;
end;

procedure TEditarRegasificadora.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;


procedure TEditarRegasificadora.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;


procedure TEditarRegasificadora.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarRegasificadora.BGuardarClick(Sender: TObject);
var
  vinicial: NReal;
  actor: TRegasificadora;
  Agenda: TAgendaCargosGNL;
  k, i, MesCierre, DiaCierre, MesInicio, DiaInicio, discretizaciones: integer;
  nPasosPreAviso_CompraSpot, nPasosPreAviso_DesvioCargo: integer;
  TDACargoAgendado: TDAOfBoolean;
  caracter, caracter2: string;
  numero: integer;
  vagnlinicialauxiliar: NReal;
  fichaaux: Tficharegasificadora;
begin
  if validarFormulario then
  begin
    MesCierre := 1;
    DiaCierre := 1;
    MesInicio := 1;
    DiaInicio := 1;
    nPasosPreAviso_CompraSpot := 5;
    nPasosPreAviso_DesvioCargo := 5;

    Agenda := TAgendaCargosGNL.Create(capa, FSimSEEEdit.StringToFecha(EFInicioAgenda.Text)
      , 0, MesCierre, DiaCierre, MesInicio, DiaInicio, StrToFloat(eVGNL_cargo.Text),
      StrToFloat(ePrecioAgenda.Text), StrToFloat(ePrecioSpot.Text),
      StrToFloat(ePrecioDesvio.Text), nPasosPreAviso_CompraSpot, nPasosPreAviso_DesvioCargo);

    Agenda.SetCargos_FromBoolStr(eAgenda.Text);

    if cosaConNombre = nil then
    begin
      vinicial := strToFloat(eVGNL_inicial.Text);
      discretizaciones := StrToInt(eNroDiscret.Text);

      cosaConNombre := TRegasificadora.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades,
        lpd, valorCBNodoCombustible(CBNodoComb), Agenda, vinicial,
        //volumen inicial del tanque, antes de empezar la simulacion
        discretizaciones,   //Nro de discretizaciones del tanque
        strToFloat(ePrecioVertimiento.Text),
        //precio al que voy a vender el GNL en caso de que no entre en la regasificadora
        strToFloat(eVGNL_cargo.Text), strToFloat(ePrecioSpot.Text),
        strToFloat(ePrecioDesvio.Text), strToFloat(
        ePrecioAgenda.Text), StrToInt( ePASOS_X_SpotYDesvios.text ));
      actor := cosaConNombre as TRegasificadora;
      actor.Set_X_SpotYDesvios_inicial_FromBoolStr(eX_SpotYDesvios.Text);
    end
    else
    begin
      actor := cosaConNombre as TRegasificadora;
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.lpd.Free;
      actor.lpd := lpd;
      actor.NodoComb := valorCBNodoCombustible(cbNodoComb);
      actor.VGNL_inicial := StrToFloat(eVGNL_inicial.Text);
      actor.Ndiscret := StrToInt(eNroDiscret.Text);
      actor.cvVert := StrToInt(ePrecioVertimiento.Text);
      actor.PASOS_X_SpotYDevios:= StrToInt( ePASOS_X_SpotYDesvios.text );
      actor.Set_X_SpotYDesvios_inicial_FromBoolStr(eX_SpotYDesvios.Text);
      setlength( actor.X_SpotYDesvios_inicial, actor.PASOS_X_SpotYDevios );
      if actor.Agenda <> nil then
        actor.Agenda.Free;
      actor.Agenda := Agenda;
    end;

    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
    vagnlinicialauxiliar := actor.VGNL_inicial;
  end;
end;

procedure TEditarRegasificadora.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarRegasificadora.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarRegasificadora.btEditarForzamientosClick(Sender: TObject);
begin
  inherited BEditorDeForzamientosClick(Sender);
end;




procedure TEditarRegasificadora.BAgregarFichaCAYAClick(Sender: TObject);
begin
  inherited BAgregarFichaClick(Sender);
end;

procedure TEditarRegasificadora.BExportar_odsClick(Sender: TObject);
begin
  exportarStrBoolAODS(eAgenda.Text, BImportar_ods);
end;



procedure TEditarRegasificadora.BImportar_odsClick(Sender: TObject);
begin
  eAgenda.Text := importarStrBoolDesdeODS( BImportar_ods, 52, 200, 200);
end;



procedure TEditarRegasificadora.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarRegasificadora.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


end.
