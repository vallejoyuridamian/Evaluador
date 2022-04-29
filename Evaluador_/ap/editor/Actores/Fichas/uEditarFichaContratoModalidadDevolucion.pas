unit uEditarFichaContratoModalidadDevolucion;


interface

uses
   {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, xMatDefs, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseEditoresFichas, ucontratomodalidaddevolucion, uFichasLPD,
  uFechas, uCosaConNombre,
  usalasdejuego,
  uSalasDeJuegoParaEditor, uconstantesSimSEE, utilidades, uverdoc, StdCtrls,
  ExtCtrls, Grids, uOpcionesSimSEEEdit;

resourcestring
  mesVentanasNoValidas =
    'Las ventanas de importación y devolución ingresadas no son válidas. ';
  mesSeDebeCumplirRelacionVentanas =
    'Se Debe Cumplir la Siguiente Relación. FImpoIni < FImpoFin < FDevoIni < FDevoFin.';
  rsEnergiaMaximaImportacion = 'Energía máxima de importación[MWh]';
  rsPotenciaMaximaImportacion = 'Potencia máxima de importación[MW]';
  rsCostoVariableImportacion = 'Costo variable de importación[USD/MWh]';
  rsRendimientoImportacion = 'Rendimiento de importación[p.u.]';
  rsFactorDisponibilidadImportacion = 'Factor de disponibilidad de importación[p.u.]';
  rsFactorDeIncremento = 'Factor de incremento[p.u.]';
  rsPotenciaMaximaExportacion = 'Potencia máxima de exportación[MW]';
  rsCostoVariableExportacion = 'Costo variable de exportación[USD/MWh]';
  rsRendimientoDeExportacion = 'Rendimiento de exportación[p.u.]';
  rsCostoVariableDevolucion = 'Costo variable de devolución[USD/MWh]';
  rsFactorDisponibilidadExportacion = 'Factor de disponibilidad de exportación[p.u.]';

type
  TEditarFichaContratoModalidadDevolucion = class(TBaseEditoresFichas)
    LFIni: TLabel;
    sgFicha: TStringGrid;
    BGuardar: TButton;
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
    LFImpoIni: TLabel;
    LImpoFin: TLabel;
    EFImpoIni: TEdit;
    EFImpoFin: TEdit;
    LFDevoIni: TLabel;
    LFDevoFin: TLabel;
    EFDevoIni: TEdit;
    EFDevoFin: TEdit;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure BCancelarClick(Sender: TObject);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    //    procedure EditVentanasExit(Sender: TObject);
    procedure cambiosForm(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
  protected
    procedure validarCambioTabla(tabla: TStringGrid); override;
    function validarVentanas: boolean;
    function validarFormulario: boolean; override;
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
  end;

var
  EditarFichaContratoModalidadDevolucion: TEditarFichaContratoModalidadDevolucion;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

procedure TEditarFichaContratoModalidadDevolucion.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaContratoModalidadDevolucion.BGuardarClick(Sender: TObject);
var
  periodicidad: TPeriodicidad;
begin
  if validarFormulario then
  begin
    if CBPeriodicidad.Checked then
      periodicidad := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
        EFIniPeriodo, EFFinPeriodo, sgPeriodicidad)
    else
      periodicidad := nil;
    ficha := TFichaContratoModalidadDevolucion.Create(
      capa,
      FSimSEEEdit.StringToFecha(EFIni.Text),
      periodicidad,
      TFecha.Create_Str(EFImpoIni.Text),
      TFecha.Create_Str(EFImpoFin.Text),
      TFecha.Create_Str(EFDevoIni.Text),
      TFecha.Create_Str(EFDevoFin.Text),
      StrToFloat(sgFicha.Cells[1, 0]),
      StrToFloat(sgFicha.Cells[1, 1]),
      StrToFloat(sgFicha.Cells[1, 2]),
      StrToFloat(sgFicha.Cells[1, 3]),
      StrToFloat(sgFicha.Cells[1, 4]),
      StrToFloat(sgFicha.Cells[1, 5]),
      StrToFloat(sgFicha.Cells[1, 6]),
      StrToFloat(sgFicha.Cells[1, 7]),
      StrToFloat(sgFicha.Cells[1, 8]),
      StrToFloat(sgFicha.Cells[1, 9]),
      StrToFloat(sgFicha.Cells[1, 10]));
    ModalResult := mrOk;
  end;
end;


procedure TEditarFichaContratoModalidadDevolucion.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaContratoModalidadDevolucion.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

constructor TEditarFichaContratoModalidadDevolucion.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  fCasteada: TFichaContratoModalidadDevolucion;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  inherited  llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if ficha <> nil then
  begin
    fCasteada := ficha as TFichaContratoModalidadDevolucion;
    EFIni.Text := FSimSEEEdit.fechaIniToString(ficha.fecha);

    EFImpoIni.Text := fCasteada.dtImpoIni.AsStr;
    EFImpoFin.Text := fCasteada.dtImpoFin.AsStr;
    EFDevoIni.Text := fCasteada.dtDevoIni.AsStr;
    EFDevoFin.Text := fCasteada.dtDevoFin.AsStr;

    sgFicha.Cells[1, 0] := FloatToStrF(fCasteada.EMaxImp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 1] := FloatToStrF(fcasteada.PMaxImp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 2] := FloatToStrF(fcasteada.cvImp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 3] := FloatToStrF(fcasteada.renImp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 4] := FloatToStrF(fcasteada.fdImp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 5] := FloatToStrF(fcasteada.fi, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 6] := FloatToStrF(fcasteada.PMaxExp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 7] := FloatToStrF(fcasteada.cvExp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 8] := FloatToStrF(fcasteada.renExp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 9] := FloatToStrF(fcasteada.cvDevolucion, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
    sgFicha.Cells[1, 10] := FloatToStrF(fcasteada.fdExp, ffGeneral,
      CF_PRECISION, CF_DECIMALES);
  end;
end;

procedure TEditarFichaContratoModalidadDevolucion.validarCambioTabla(
  tabla: TStringGrid);
begin
  inherited validarCambioTablaNReals(tabla);
end;

function TEditarFichaContratoModalidadDevolucion.validarVentanas: boolean;
var
  FImpoIni, FImpoFin, FDevoIni, FDevoFin: TFecha;
  res: boolean;
begin
  if validarEditFecha(EFImpoIni) and validarEditFecha(EFImpoFin) and
    validarEditFecha(EFDevoIni) and validarEditFecha(EFDevoFin) then
  begin
    FImpoIni := TFecha.Create_Str(EFImpoIni.Text);
    FImpoFin := TFecha.Create_Str(EFImpoFin.Text);
    FDevoIni := TFecha.Create_Str(EFDevoIni.Text);
    FDevoFin := TFecha.Create_Str(EFDevoFin.Text);

    res := (FImpoIni.EsMayorQue(FImpoFin) = -1) and
      (FImpoFin.EsMayorQue(FDevoIni) = -1) and
      (FDevoIni.EsMayorQue(FDevoFin) = -1);
    FImpoIni.Free;
    FImpoFin.Free;
    FDevoIni.Free;
    FDevoFin.Free;

    if not res then
    begin
      ShowMessage(mesVentanasNoValidas + mesSeDebeCumplirRelacionVentanas);
    end;
    Result := res;
  end
  else
    Result := False;
end;

function TEditarFichaContratoModalidadDevolucion.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and validarEditFecha(EFIni) and
    validarPeriodicidad(CBPeriodicidad, CBLargoPeriodo,
    ELargoPeriodo, EFIniPeriodo, EFFinPeriodo, sgPeriodicidad) and
    validarVentanas and inherited validarTablaNReals_(sgFicha);
end;

procedure TEditarFichaContratoModalidadDevolucion.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaContratoModalidadDevolucion.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

{procedure TEditarFichaContratoModalidadDevolucion.EditVentanasExit(
  Sender: TObject);
var
  FImpoIni, FImpoFin, FDevoIni, FDevoFin: TFecha;

function compararFImpoIni: boolean;
begin
  if FImpoIni = NIL then
    result:= true
  else
  begin
    if FImpoFin <> NIL then
      result:= FImpoIni.EsMayorQue(FImpoFin) = -1
    else if FDevoIni <> NIL then
      result:= FImpoIni.EsMayorQue(FDevoIni) = -1
    else if FDevoFin <> NIL then
      result:= FImpoIni.EsMayorQue(FDevoFin) = -1
    else
      result:= true;
  end;
end;

function compararFImpoFin: boolean;
begin
  if FImpoFin = NIL  then
    result:= true
  else
  begin
    if FDevoIni <> NIL then
      result:= FImpoFin.EsMayorQue(FDevoIni) = -1
    else if FDevoFin <> NIL then
      result:= FImpoFin.EsMayorQue(FDevoFin) = -1
    else
      result:= true;
  end;
end;

function compararFDevoIni: boolean;
begin
  if FDevoFin = NIL  then
    result:= true
  else
  begin
    if FDevoFin <> NIL then
      result:= FDevoIni.EsMayorQue(FDevoFin) = -1
    else
      result:= true;
  end;
end;

begin
  if validarEditFecha(TEdit(Sender)) then
  begin
    if EFImpoIni.Text <> '' then FImpoIni:= TFecha.Create_Str(EFImpoIni.Text)
    else FImpoIni:= NIL;
    if EFImpoFin.Text <> '' then FImpoFin:= TFecha.Create_Str(EFImpoFin.Text)
    else FImpoFin:= NIL;
    if EFDevoIni.Text <> '' then FDevoIni:= TFecha.Create_Str(EFDevoIni.Text)
    else FDevoIni:= NIL;
    if EFDevoFin.Text <> '' then FDevoFin:= TFecha.Create_Str(EFDevoFin.Text)
    else FDevoFin:= NIL;

    if not (compararFImpoIni and compararFImpoFin and compararFDevoIni) then
    begin
      ShowMessage(mesVentanasNoValidas + mesSeDebeCumplirRelacion);
      TEdit(Sender).Text:= loQueHabia;
      TEdit(Sender).SetFocus;
    end;
    if FImpoIni <> NIL then
      FImpoIni.Free;
    if FImpoFin <> NIL then
      FImpoFin.Free;
    if FDevoIni <> NIL then
      FDevoIni.Free;
    if FDevoFin <> NIL then
      FDevoFin.Free;
  end;
end;               }

procedure TEditarFichaContratoModalidadDevolucion.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaContratoModalidadDevolucion.FormCreate(Sender: TObject);
begin
  sgFicha.Cells[0, 0] := rsEnergiaMaximaImportacion;
  sgFicha.Cells[0, 1] := rsPotenciaMaximaImportacion;
  sgFicha.Cells[0, 2] := rsCostoVariableImportacion;
  sgFicha.Cells[0, 3] := rsRendimientoImportacion;
  sgFicha.Cells[0, 4] := rsFactorDisponibilidadImportacion;
  sgFicha.Cells[0, 5] := rsFactorDeIncremento;
  sgFicha.Cells[0, 6] := rsPotenciaMaximaExportacion;
  sgFicha.Cells[0, 7] := rsCostoVariableExportacion;
  sgFicha.Cells[0, 8] := rsRendimientoDeExportacion;
  sgFicha.Cells[0, 9] := rsCostoVariableDevolucion;
  sgFicha.Cells[0, 10] := rsFactorDisponibilidadExportacion;

  utilidades.AutoSizeCol(sgFicha, 0);
  utilidades.AgregarFormatoFecha(LFIni);
end;

procedure TEditarFichaContratoModalidadDevolucion.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarFichaContratoModalidadDevolucion.sgChequearCambiosKeyDown(
  Sender: TObject; var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaContratoModalidadDevolucion.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

end.
