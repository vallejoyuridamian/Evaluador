unit uEditarFichaGTer_BasicoDosTramos;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uBaseEditoresFichas,
  ugter_basicoDosTramos, uCosaConNombre, ufichasLPD, StdCtrls, Grids, utilidades, uFechas,
  ExtCtrls, uConstantesSimSEE, uBaseEditoresFichasGeneradores, xMatDefs,
  usalasdejuego, uBaseAltasEditores,
  usalasdejuegoParaEditor, uverdoc,
  uFuentesAleatorias, uOpcionesSimSEEEdit;

resourcestring
  rsPotenciaDeTransicion = 'Potencia de transición [MW]';
  rsPotenciaMaxima = 'Potencia máxima [MW]';
  rsCostoVariableTramo1 = 'Costo variable tramo 1 [USD/MWh]';
  rsCostoVariableTramo2 = 'Costo variable tramo 2 [USD/MWh]';
  rsCoeficienteDisponibilidadFortuita = 'Coeficiente de disponibildad fortuita [p.u.]';
  rsTiempoDeReparacionH = 'Tiempo de reparación [horas]';

type

{ TEditarFichaGTer_BasicoDosTramos }

TEditarFichaGTer_BasicoDosTramos = class(TBaseEditoresFichasGeneradores)
    LFIni: TLabel;
    EFIni: TEdit;
    IntFicha: TStringGrid;
    BGuardar: TButton;
    BCancelarFicha: TButton;
    CBPeriodicidad: TCheckBox;
    PPeriodicidad: TPanel;
    LFinPeriodo: TLabel;
		LIniPeriodo: TLabel;
    LLargoPeriodo: TLabel;
    EFFinPeriodo: TEdit;
    EFIniPeriodo: TEdit;
    sgPeriodicidad: TStringGrid;
    ELargoPeriodo: TEdit;
    CBLargoPeriodo: TComboBox;
    CBRestrEMax: TCheckBox;
    ERestrEMax: TEdit;
    BAyuda: TButton;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
		procedure FormCreate(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure EditEnter(Sender: TObject);
		procedure BCancelarClick(Sender: TObject);
		procedure sgGetEditText(Sender: TObject; ACol, ARow: Integer;
			var Value: String);
		procedure BGuardarClick(Sender: TObject); override;
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure CBRestrEMaxClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
	protected
    procedure validarCambioTabla(tabla : TStringGrid); override;
		function validarFormulario() : boolean; override;
  private
		Generador : TGTer_BasicoDosTramos;
	public
		Constructor Create(AOwner : TComponent; cosaConNombre : TCosaConNombre ; ficha: TFichaLPD; sala : TSalaDeJuego ); override;
	end;

implementation

uses SimSEEEditMain;

{$IFNDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

Constructor TEditarFichaGTer_BasicoDosTramos.Create(AOwner : TComponent; cosaConNombre : TCosaConNombre ; ficha : TFichaLPD; sala : TSalaDeJuego );
var
	fichaAux : TFichaGTer_BasicoDosTramos;
	i : Integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
	Generador := cosaConNombre as TGTer_BasicoDosTramos;
	inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  inherited inicializarCBFuente(CBFuenteIndicePreciosPorCombustible, CBBorneIndicePreciosCombustible, true);
  
	if (ficha <> NIL) then
	begin
	  fichaAux := ficha as TFichaGTer_BasicoDosTramos;

    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
		self.IntFicha.cells[1, 0] := FloatToStr(fichaAux.Ptr);
		self.IntFicha.cells[1, 1] := FloatToStr(fichaAux.PMax);
		self.IntFicha.cells[1, 2] := FloatToStr(fichaAux.cv1);
		self.IntFicha.cells[1, 3] := FloatToStr(fichaAux.cv2);
		self.IntFicha.cells[1, 4] := FloatToStr(fichaAux.disp);
    self.IntFicha.cells[1, 5] := FloatToStr(fichaAux.tRepHoras);

    inherited initCBRestriccion(fichaAux.HayRestriccionEmaxPasoDeTiempo, CBRestrEMax,
                                fichaAux.EmaxPasoDeTiempo, ERestrEMax);
    inherited setCBFuente(CBFuenteIndicePreciosPorCombustible, CBBorneIndicePreciosCombustible, fichaAux.indicePreciosPorCombustible, fichaAux.bornePreciosPorCombustible);
  end
	else
	begin
	  self.EFIni.Text := '';
		for i := 0 to self.IntFicha.RowCount - 1 do
		  self.IntFicha.cells[1, i] := '';
    inherited initCBRestriccion(false, CBRestrEMax, 0, ERestrEMax);
  end;
end;

procedure TEditarFichaGTer_BasicoDosTramos.validarCambioTabla(tabla : TStringGrid);
begin
  inherited validarCambioTablaNReals(tabla);
end;

function TEditarFichaGTer_BasicoDosTramos.validarFormulario() : boolean;
begin
	inherited validarFormulario;
	result := validarEditFecha(EFIni) and
            inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
            inherited validarTablaNReals_(IntFicha) and
            inherited validarRestriccion(CBRestrEMax, ERestrEMax, 1, MaxNReal) and
            inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible, CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaGTer_BasicoDosTramos.FormCreate(Sender: TObject);
begin
  utilidades.AgregarFormatoFecha(LFIni);

  self.IntFicha.cells[0, 0] := rsPotenciaDeTransicion;
  self.IntFicha.cells[0, 1] := rsPotenciaMaxima;
  self.IntFicha.cells[0, 2] := rsCostoVariableTramo1;
  self.IntFicha.cells[0, 3] := rsCostoVariableTramo2;
  self.IntFicha.cells[0, 4] := rsCoeficienteDisponibilidadFortuita;
  self.IntFicha.cells[0, 5] := rsTiempoDeReparacionH;

  utilidades.AutoSizeCol(IntFicha, 0);
  utilidades.AutosizeTable(self, IntFicha, CP_MAXANCHOTABLAENORME, CP_MAXALTURATABLAMEDIANA, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);
end;

procedure TEditarFichaGTer_BasicoDosTramos.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
	inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaGTer_BasicoDosTramos.EditEnter(Sender: TObject);
begin
	inherited EditEnter(Sender);
end;

procedure TEditarFichaGTer_BasicoDosTramos.BCancelarClick(
  Sender: TObject);
begin
	inherited BCancelarClick(Sender);
end;

procedure TEditarFichaGTer_BasicoDosTramos.sgGetEditText(Sender: TObject;
  ACol, ARow: Integer; var Value: String);
begin
	inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaGTer_BasicoDosTramos.BGuardarClick(
	Sender: TObject);
var
	periodicidad : TPeriodicidad;
  restrEMax: NReal;
begin
if validarFormulario then
	begin
	{	fAux := TFichaGenSencillo(Generador.lpd.ficha(StrToInt(self.IntAnio.text), StrToInt(self.IntSemana.text)));
	if (fAux = NIL) or (fAux = ficha2) then
		 begin          }

	if not CBPeriodicidad.Checked then
    periodicidad := NIL
	else
    periodicidad := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
  restrEMax:= inherited rest(CBRestrEMax, ERestrEMax, MaxNReal);

  ficha := TFichaGTer_BasicoDosTramos.Create( FSimSEEEdit.StringToFecha(EFIni.Text), periodicidad,
                                					StrToFloat(self.IntFicha.cells[1, 0]),
                              						StrToFloat(self.IntFicha.cells[1, 1]),
                              						StrToFloat(self.IntFicha.cells[1, 2]),
                              						StrToFloat(self.IntFicha.cells[1, 3]),
                                          valorCBFuente(CBFuenteIndicePreciosPorCombustible),
                                          valorCBString(CBBorneIndicePreciosCombustible),
                                          StrToFloat(self.IntFicha.cells[1, 4]),
                                          StrToFloat(self.IntFicha.Cells[1, 5]),
                                          CBRestrEMax.Checked, restrEMax);
  ModalResult := mrOk;
	 {		 end
	else
			 begin
			 ShowMessage(mesYaExisteFichaEnFecha);
			 end     }
	end
end;

procedure TEditarFichaGTer_BasicoDosTramos.CBPeriodicidadClick(
  Sender: TObject);
begin
	inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad)
end;

procedure TEditarFichaGTer_BasicoDosTramos.CambiosForm(
  Sender: TObject);
begin
	inherited CambiosForm(Sender);
end;

procedure TEditarFichaGTer_BasicoDosTramos.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited cbFuenteChange(CBFuenteIndicePreciosPorCombustible, CBBorneIndicePreciosCombustible);
end;

procedure TEditarFichaGTer_BasicoDosTramos.CBRestrEMaxClick(Sender: TObject);
begin
  inherited CBRestrClick(CBRestrEMax, ERestrEMax);
end;

procedure TEditarFichaGTer_BasicoDosTramos.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TGTer_BasicoDosTramos);
end;

end.
