unit uEditarFichaHidroConEmbalseValorizado;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, uBaseEditoresFichas, utilidades, xMatDefs,
  uFichasLPD, uHidroConEmbalseValorizado, uFechas, uconstantesSimSEE, uCosaConNombre,
  usalasdejuego,
  uSalasDeJuegoParaEditor,
  uEditarCentralesEncadenadas, uGeneradores, uverdoc, uOpcionesSimSEEEdit;

type
  TEditarFichaHidroConEmbalseValorizado = class(TBaseEditoresFichas)
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
    LValorizacion: TLabel;
    ENDisc: TEdit;
    sgValores: TStringGrid;
    LNDisc: TLabel;
    Panel1: TPanel;
    BEditarCentralesAguasArriba: TButton;
    BAyuda: TButton;
    procedure EditEnter(Sender: TObject);
    procedure CambiosForm(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure EditFechaExit(Sender: TObject);
    procedure EditIntExit(Sender: TObject);
    procedure sgPeriodicidadValidarCambio(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure sgPeriodicidadKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure sgValidarCambio(Sender: TObject);
    procedure sgValoresKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sgFichaMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarFichaClick(Sender: TObject);
    procedure ENDiscExit(Sender: TObject);
    procedure BEditarCentralesAguasArribaClick(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  protected
		function validarFormulario : boolean; override;
    procedure validarCambioTabla(tabla : TStringGrid); override;
  private
    Generador : THidroConEmbalseValorizado;
    centralesAguasArriba : TListaCentralesAguasArriba;
    centralDescarga : TGeneradorHidraulico;
  public
    Constructor Create(AOwner : TComponent; cosaConNombre : TCosaConNombre ; ficha: TFichaLPD; sala : TSalaDeJuego); override;
  end;

var
  EditarFichaHidroConEmbalseValorizado: TEditarFichaHidroConEmbalseValorizado;

implementation

uses uBaseAltasEditores, SimSEEEditMain;

{$R *.dfm}

Constructor TEditarFichaHidroConEmbalseValorizado.Create(AOwner : TComponent; cosaConNombre : TCosaConNombre ; ficha : TFichaLPD; sala : TSalaDeJuego );
var
	fichaAux : TFichaHidroConEmbalseValorizado;
	i : Integer;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
	Generador := cosaConNombre as THidroConEmbalseValorizado;
	inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
	if (ficha <> NIL) then
  begin
		fichaAux := ficha as TFichaHidroConEmbalseValorizado;
	  self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
		self.sgFicha.cells[1, 0] := FloatToStr(fichaAux.hmin);
		self.sgFicha.cells[1, 1] := FloatToStr(fichaAux.hmax);
		self.sgFicha.cells[1, 2] := FloatToStr(fichaAux.Vmax);
		self.sgFicha.cells[1, 3] := FloatToStr(fichaAux.VHmed);
		self.sgFicha.cells[1, 4] := FloatToStr(fichaAux.hDescarga);
		self.sgFicha.cells[1, 5] := FloatToStr(fichaAux.caQE);
		self.sgFicha.cells[1, 6] := FloatToStr(fichaAux.cbQE);
    self.sgFicha.cells[1, 7] := FloatToStr(fichaAux.ren);
	  self.sgFicha.cells[1, 8] := FloatToStr(fichaAux.Pmax_Gen);
		self.sgFicha.cells[1, 9] := FloatToStr(fichaAux.QMax_Turb);
		self.sgFicha.cells[1, 10] := FloatToStr(fichaAux.fDispo);
		self.sgFicha.cells[1, 11] := FloatToStr(fichaAux.ca_filtr);
		self.sgFicha.cells[1, 12] := FloatToStr(fichaAux.cb_filtr);

    ENDisc.Text := IntToStr(Length(fichaAux.ValorDelAgua));
    ENDiscExit(ENDisc);
    centralDescarga := fichaAux.central_lagoDescarga;
    for i := 0 to High(fichaAux.ValorDelAgua) do
      sgValores.Cells[1, i] := FloatToStrF(fichaAux.ValordelAgua[i], ffGeneral, CF_PRECISION, CF_DECIMALES);
    centralesAguasArriba := Clonar_Y_ResolverReferencias(sala, fichaAux.centralesLagoArriba) as TListaCentralesAguasArriba;
  end
	else
	begin
	  self.EFIni.Text := '';
    centralDescarga := NIL;
		for i := 0 to self.sgFicha.RowCount - 1 do
		  self.sgFicha.cells[1, i] := '';
    centralesAguasArriba := TListaCentralesAguasArriba.Create;
  end;
 	guardado := true;
end;

function TEditarFichaHidroConEmbalseValorizado.validarFormulario() : boolean;
begin
	inherited validarFormulario;
	result := validarEditFecha(EFIni) and
            validarTablaNReals(sgFicha) and
            validarTablaNReals(sgValores) and
            inherited validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
end;

procedure TEditarFichaHidroConEmbalseValorizado.validarCambioTabla(tabla : TStringGrid);
begin
  inherited validarTablaNReals(tabla);
end;

procedure TEditarFichaHidroConEmbalseValorizado.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaHidroConEmbalseValorizado.CambiosForm(
  Sender: TObject);
begin
  guardado := false;
end;

procedure TEditarFichaHidroConEmbalseValorizado.FormCloseQuery(
  Sender: TObject; var CanClose: Boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaHidroConEmbalseValorizado.FormCreate(
  Sender: TObject);
var
  i : Integer;
begin
	utilidades.AgregarFormatoFecha(LFIni);

	self.sgFicha.cells[0, 0] := 'Cota Mínima[m]';
	self.sgFicha.cells[0, 1] := 'Cota Máxima[m]';
	self.sgFicha.cells[0, 2] := 'Volumen Máximo Almacenable[m^3]';
	self.sgFicha.cells[0, 3] := 'Volumen con la Altura Media[m^3]';
	self.sgFicha.cells[0, 4] := 'Cota de la Descarga para Cálculo del Salto[m]';
	self.sgFicha.cells[0, 5] := 'Coeficientes de Afectación del Salto por Caudal Erogado(caQE)';
	self.sgFicha.cells[0, 6] := 'Coeficientes de Afectación del Salto por Caudal Erogado(cbQE)';
	self.sgFicha.cells[0, 7] := 'Rendimiento[p.u.]';
	self.sgFicha.cells[0, 8] := 'Potencia Máxima Generable[MWh]';
	self.sgFicha.cells[0, 9] := 'Caudal Máximo Turbinable[m^3/s]';
	self.sgFicha.cells[0, 10] := 'Factor de Disponibilidad[p.u.]';
	self.sgFicha.cells[0, 11] := 'Ca Filtración[m^3/s]';
 	self.sgFicha.cells[0, 12] := 'Cb Filtración[m^2/s]';
 	utilidades.AutoSizeCol(sgFicha, 0);
	utilidades.AutosizeTable(self, sgFicha, maxAnchoTablaEnorme, CP_MAXALTURATABLAMUYGRANDE, TSimSEEEditOptions.getInstance.deshabilitarScrollHorizontalEnListados);

  Panel1.Left := sgFicha.Left + sgFicha.Width + 5;
  sgValores.Left := Panel1.Left + 7;
  ENDisc.Left := sgValores.Left;
  LValorizacion.Left := sgValores.Left;
  LNDisc.Left := sgValores.Left;

  for i := 0 to sgValores.RowCount -1 do
    sgValores.Cells[0, i] := 'h' + IntToStr(i);
  utilidades.AutoSizeCol(sgValores, 0);
  ENDisc.Width := sgValores.Width;
end;

procedure TEditarFichaHidroConEmbalseValorizado.EditFechaExit(
  Sender: TObject);
begin
  inherited EditFechaExit(Sender);
end;

procedure TEditarFichaHidroConEmbalseValorizado.EditIntExit(
  Sender: TObject);
begin
  inherited EditIntExit(Sender, 1, MAXINT);
end;

procedure TEditarFichaHidroConEmbalseValorizado.sgPeriodicidadValidarCambio(
  Sender: TObject);
begin
  inherited sgPeriodicidadValidarCambio(TStringGrid(Sender));
end;

procedure TEditarFichaHidroConEmbalseValorizado.sgGetEditText(
  Sender: TObject; ACol, ARow: Integer; var Value: String);
begin
  inherited sgGetEditText(Sender, Acol, ARow, Value);
end;

procedure TEditarFichaHidroConEmbalseValorizado.sgPeriodicidadKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited sgPeriodicidadKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaHidroConEmbalseValorizado.CBPeriodicidadClick(
  Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad)
end;

procedure TEditarFichaHidroConEmbalseValorizado.sgValidarCambio(
  Sender: TObject);
begin
  inherited sgValidarCambio(Sender);
end;

procedure TEditarFichaHidroConEmbalseValorizado.sgValoresKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited sgKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaHidroConEmbalseValorizado.sgFichaMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
	col, fila : Integer;
begin
	TStringGrid(Sender).MouseToCell(x, y, col, fila);
	if (fila =	5) or (fila = 6) then
  begin
    TStringGrid(Sender).Hint := 'dh(QE) = caQE* QE + cbQE* QE^2';
		TStringGrid(Sender).ShowHint := true
  end
	else if (fila = 11) or (fila = 12) then
  begin
    TStringGrid(Sender).Hint := 'Filtración(h)[m^3/s] = Ca_Filtración + Cb_Filtración * h';
		TStringGrid(Sender).ShowHint := true
  end
  else
    TStringGrid(Sender).ShowHint := false;
end;

procedure TEditarFichaHidroConEmbalseValorizado.BCancelarClick(
  Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaHidroConEmbalseValorizado.BGuardarFichaClick(
  Sender: TObject);
var
  i : Integer;
  valores : TDAofNReal;
  periodo : TPeriodicidad;
begin
if validarFormulario then
begin
  {	fAux := TFichaGenSencillo(Generador.lpd.ficha(StrToInt(self.IntAnio.text), StrToInt(self.IntSemana.text)));
  if (fAux = NIL) or (fAux = ficha2) then
	begin          }
	if not CBPeriodicidad.Checked then
    periodo := NIL
	else
    periodo := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);

  SetLength(valores, StrToInt(ENDisc.Text));
  for i := 0 to high(valores) do
    valores[i] := StrToFloat(sgValores.Cells[1, i]);

	ficha := TFichaHidroConEmbalseValorizado.Create(
           FSimSEEEdit.StringToFecha(EFIni.Text), periodo,
	         StrToFloat(self.sgFicha.cells[1, 0]),
			     StrToFloat(self.sgFicha.cells[1, 1]),
			     StrToFloat(self.sgFicha.cells[1, 2]),
			     StrToFloat(self.sgFicha.cells[1, 3]),
			     STRToFloat(self.sgFicha.cells[1, 4]), NIL, centralesAguasArriba,
			     StrToFloat(self.sgFicha.cells[1, 5]),
			     StrToFloat(self.sgFicha.cells[1, 6]),
			     StrToFloat(self.sgFicha.cells[1, 7]),
			     StrToFloat(self.sgFicha.cells[1, 8]),
			     StrToFloat(self.sgFicha.cells[1, 9]),
			     StrToFloat(self.sgFicha.cells[1, 10]),
			     StrToFloat(self.sgFicha.cells[1, 11]),
           StrToFloat(self.sgFicha.cells[1, 12]),
           valores);
	ModalResult := mrOk;
  {		 end
	else
			 begin
			 ShowMessage('Ya existe una ficha en la fecha seleccionada');
			 end     }
end
end;

procedure TEditarFichaHidroConEmbalseValorizado.ENDiscExit(
  Sender: TObject);
var
	nAnt, i : Integer;
begin
	if validarEditInt(TEdit(Sender), 1, MAXINT) then
	begin
		nAnt := sgValores.RowCount;
		sgValores.RowCount := StrToInt(TEdit(Sender).Text);
		for i := nAnt to sgValores.RowCount - 1 do
		begin
			sgValores.Cells[0, i] := 'h' + IntToStr(i);
			sgValores.Cells[1, i] := '0';
		end;
		utilidades.AutoSizeTableSinBajarControles(sgValores, maxAnchoTablaEnorme, CP_MAXALTURATABLAMEDIANA, false);
	end;
end;

procedure TEditarFichaHidroConEmbalseValorizado.BEditarCentralesAguasArribaClick(
  Sender: TObject);
var
  form : TEditarCentralesAguasArriba;
begin
  form := TEditarCentralesAguasArriba.Create(self, Generador, centralDescarga, centralesAguasArriba, sala);
  if form.ShowModal = mrOk then
  begin
    centralesAguasArriba.Free;
    self.centralDescarga := form.DarCentralDescarga;
    centralesAguasArriba := form.darCentralesAguasArriba;
  end;
  form.Free;
end;

procedure TEditarFichaHidroConEmbalseValorizado.BAyudaClick(
  Sender: TObject);
begin
  verdoc(self, THidroConEmbalseValorizado);
end;

end.
