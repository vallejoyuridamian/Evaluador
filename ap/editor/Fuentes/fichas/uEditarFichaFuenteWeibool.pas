unit uEditarFichaFuenteWeibool;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, uFuentesAleatorias, uBaseEditoresFichas,
  ucosa, uFichasLPD, uSalasdeJuego, uconstantes, utilidades, uFechas, uverdoc;

type
  TEditarFichaFuenteWeibool = class(TBaseEditoresFichas)
    LFIni: TLabel;
    sgFicha: TStringGrid;
    BGuardarFicha: TButton;
    BCancelar: TButton;
    EFIni: TEdit;
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
    BAyuda: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EditEnter(Sender: TObject);
    procedure EditFechaExit(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure EditIntExit(Sender: TObject);
    procedure CBLargoPeriodoChange(Sender: TObject);
    procedure sgPeriodicidadValidarCambio(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure sgKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure sgValidarCambio(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarFichaClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
	protected
		procedure validarCambioTabla(tabla : TStringGrid); override;

		function validarFormulario : boolean; override;
	public
		Constructor Create(AOwner : TComponent; cosa : TCosa ; ficha: TFichaLPD; sala : TSalaDeJuego ); override;
  end;

var
  EditarFichaFuenteWeibool: TEditarFichaFuenteWeibool;

implementation

uses uBaseAltasEditores;

{$R *.dfm}

Constructor TEditarFichaFuenteWeibool.Create(AOwner : TComponent; cosa : TCosa ; ficha: TFichaLPD; sala : TSalaDeJuego );
begin
	inherited Create(AOwner, cosa, ficha, sala);
	inherited	llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
	if ficha <> NIL then
	begin
		EFIni.Text := ficha.fecha.AsStr;
		sgFicha.Cells[1, 0] := FloatToStrF(TFichaFuenteWeibool(ficha).valorEsperado, ffGeneral, uconstantes.CF_PRECISION, uconstantes.CF_DECIMALES);
		sgFicha.Cells[1, 1] := FloatToStrF(TFichaFuenteWeibool(ficha).constanteK, ffGeneral, uconstantes.CF_PRECISION, uconstantes.CF_DECIMALES);
	end
end;

procedure TEditarFichaFuenteWeibool.validarCambioTabla(tabla : TStringGrid);
begin
if validarSg and (tabla.cells[1, fila] <> loQueHabia) then
  begin
	  try
  	begin
	    StrToFloat(tabla.cells[1, fila]);
			guardado := false;
    end
		except
		  on EConvertError do
			begin
				tabla.Cells[1, fila] := loQueHabia;
				ShowMessage('El Valor Introducido Debe ser Numérico');
			end
    end
  end;
validarsg := true;
end;

function TEditarFichaFuenteWeibool.validarFormulario : boolean;
begin
	result := inherited validarFormulario and
            validarEditFecha(EFIni) and
            inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
            inherited validarTablaNReals(sgFicha);
end;

procedure TEditarFichaFuenteWeibool.FormCreate(Sender: TObject);
begin
	sgFicha.Cells[0, 0] := 'Valor Esperado';
	sgFicha.Cells[0, 1] := 'Constante K';
	utilidades.AutoSizeTable(self, sgFicha, self.ClientWidth, uconstantes.maxAlturaTablaChica);
	utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaFuenteWeibool.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaFuenteWeibool.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaFuenteWeibool.EditFechaExit(Sender: TObject);
begin
  inherited EditFechaExit(Sender);
end;

procedure TEditarFichaFuenteWeibool.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaFuenteWeibool.EditIntExit(Sender: TObject);
begin
  inherited validarEditInt(TEdit(Sender), 1, MAXINT);
end;

procedure TEditarFichaFuenteWeibool.CBLargoPeriodoChange(Sender: TObject);
begin
  guardado:= false;
end;

procedure TEditarFichaFuenteWeibool.sgPeriodicidadValidarCambio(
  Sender: TObject);
begin
  inherited validarTablaPeriodicidad(sgPeriodicidad);
end;

procedure TEditarFichaFuenteWeibool.sgGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
 inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaFuenteWeibool.sgKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited sgKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaFuenteWeibool.FormResize(Sender: TObject);
begin
  inherited centrarBotones(BGuardarFicha, BCancelar);
end;

procedure TEditarFichaFuenteWeibool.sgValidarCambio(Sender: TObject);
begin
  inherited sgValidarCambio(Sender);
end;

procedure TEditarFichaFuenteWeibool.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaFuenteWeibool.BGuardarFichaClick(Sender: TObject);
var
	periodicidad : TPeriodicidad;
begin
	if validarFormulario then
  begin
		if CBPeriodicidad.Checked then
			periodicidad := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
		else
			periodicidad := NIL;
		ficha := TFichaFuenteWeibool.Create(TFecha.Create_Str(EFIni.Text), periodicidad, StrToFloat(sgFicha.Cells[1, 0]), StrToFloat(sgFicha.Cells[1, 1]));
		modalResult := mrOk;
	end
end;

procedure TEditarFichaFuenteWeibool.BAyudaClick(Sender: TObject);
begin
  verdoc(self, TFuenteWeibool);
end;

end.
