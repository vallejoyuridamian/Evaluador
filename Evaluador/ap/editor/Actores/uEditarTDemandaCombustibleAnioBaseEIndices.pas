unit uEditarTDemandaCombustibleAnioBaseEIndices;
{$MODE Delphi}

interface

uses
{$IFDEF FPC-LCL}
  LResources,
{$ENDIF}
{$IFDEF WINDOWS}
Windows,
{$ENDIF}
 Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, StdCtrls, DateUtils, Math,
  uBaseEditoresActores,
  uBaseEditoresCosasConNombre,
  uSalasDeJuego,
  uCosaConNombre,
  utilidades,
  uOpcionesSimSEEEdit,
  uverdoc,
  uConstantesSimSEE,
  xMatDefs,
  uDemandaCombustibleAnioBaseEIndices,
  udatoshorariosdetallados,
  uCrearBinDatosHorarios,
  uopencalc,
  uopencalcexportimport,
  uDemandaCombustible;


resourcestring
  rsDemandaCombustible = 'Demanda de Combustible';
  rsDemandaCombustibleEnElAnioBase = 'Demanda de Combustible en el Año Base';
  rsEn365Dias = 'en 365 días';
  rsEn366Dias = 'en 366 días';
  rsAnio = 'Año';
  rsDemandaCombustibleDelAnioMm3 = 'Demanda de Combustible del año[Mm3]';
  mesCantidadDatosEnArchivo = 'La cantidad de datos ingresados en el archivo debe ser ';

type

  { TEditarTDemandaCombustibleAnioBaseEIndices }

  TEditarTDemandaCombustibleAnioBaseEIndices = class(TBaseEditoresActores)
    chkSumarFuenteCaudal: TCheckBox;
    LNombre: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LNodoCombustible: TLabel;
    LEscalonesdeFalla: TLabel;
    LNEscalones: TLabel;
    LNarch: TLabel;
    LFuenteDeAportes: TLabel;
    LBorne: TLabel;
    LDemandaCombustible: TLabel;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    CBNodoCombustible: TComboBox;
    sgFalla: TStringGrid;
    EditTamTablaFalla: TEdit;
    ENarch: TEdit;
    BExaminar: TButton;
    BEditorDeUnidades: TButton;
    BCrear: TButton;
    CBFuente: TComboBox;
    CBBorne: TComboBox;
    BAyuda: TButton;
    sgIndices: TStringGrid;
    BImportar_ods: TButton;
    BExportar_ods: TButton;
    CBFuenteIndicePreciosPorCombustible: TComboBox;
    CBBorneIndicePreciosCombustible: TComboBox;
    eAnioIni: TEdit;
    eAnioFin: TEdit;
    UDAnioIni: TUpDown;
    UDAnioFin: TUpDown;
    PBExpoImpo: TProgressBar;
    OpenDialog1: TOpenDialog;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoCombustibleChange(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
    procedure CBBorneChange(Sender: TObject);
    procedure EditTamTablaFallaExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer;
      var Value: string);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure CBFuenteIndicePreciosPorCombustibleChange(Sender: TObject);
    procedure CBBorneIndicePreciosCombustibleChange(Sender: TObject);
    procedure BExaminarClick(Sender: TObject);
    procedure BCrearClick(Sender: TObject);
    procedure UDAnioIniClick(Sender: TObject; Button: TUDBtnType);
    procedure UDAnioFinClick(Sender: TObject; Button: TUDBtnType);
    procedure BExportar_odsClick(Sender: TObject);
    procedure BImportar_odsClick(Sender: TObject);
    procedure BEditorDeUnidadesClick(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure BGuardarClick(Sender: TObject); override;
    procedure BAyudaClick(Sender: TObject);
  private

    procedure llenarEtiquetaDemandaCombustible;
    procedure cambioTamTablaFalla;
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarTDemandaCombustibleAnioBaseEIndices.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TDemandaCombustibleAnioBaseEIndices;
  i, nAnios, anioIni: integer;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);
    inicializarCBNodosCombustible (CBNodoCombustible, False);
    inicializarCBFuente(CBFuente, CBBorne, True);
    inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  if cosaConNombre <> nil then
  begin
    actor := TDemandaCombustibleAnioBaseEIndices(cosaConNombre);

    EditNombre.Text := actor.nombre;
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    setCBNodoCombustible(CBNodoCombustible, actor.nodocomb);
    setCBFuente(CBFuente, CBBorne, actor.fuente, actor.nombreBorne);
    chkSumarFuenteCaudal.Checked := actor.SumarCaudalHr;
    setTablaFalla(sgFalla, EditTamTablaFalla, actor.falla_profundidad,
      actor.falla_costo_0, cambioTamTablaFalla);
    setCBFuente(CBFuenteIndicePreciosPorCombustible, CBBorneIndicePreciosCombustible,
      actor.icf_Fuente, actor.icf_NombreBorne);
    ENarch.Text := actor.ArchiDatos.archi;
    OpenDialog1.InitialDir := getCurrentDrive + ExtractFilePath(ENarch.Text);
    OpenDialog1.Filter := 'Archivos Binarios (*.bin)|*.bin|Todos los Archivos (*.*)|*.*';

    llenarEtiquetaDemandaCombustible;
    anioIni := actor.anioIni;
    nAnios := actor.anioFin - actor.anioIni + 1;
    UDAnioIni.Position := anioIni;
    eAnioIni.Text := IntToStr(anioIni);
    UDAnioFin.Position := anioIni + nAnios - 1;
    eAnioFin.Text := IntToStr(anioIni + nAnios - 1);
    UDAnioIni.Max := UDAnioFin.Position;
    UDAnioFin.Min := UDAnioIni.Position;

    sgIndices.RowCount := nAnios + 1;
    sgIndices.Cells[0, 0] := rsAnio;
    sgIndices.Cells[1, 0] := rsDemandaCombustibleDelAnioMm3;
    for i := 1 to high(actor.Mm3_anios) do
    begin
      sgIndices.Cells[0, i] := IntToStr(anioIni + i - 1);
      sgIndices.Cells[1, i] := FloatToStr(actor.Mm3_anios[i - 1]);
    end;
    for i := Length(actor.Mm3_anios) to sgIndices.RowCount - 1 do
    begin
      sgIndices.Cells[0, i] := IntToStr(anioIni + i - 1);
      sgIndices.Cells[1, i] := FloatToStr(actor.Mm3_anios[high(actor.Mm3_anios)]);
    end;

    for i := 0 to sgIndices.ColCount - 1 do
      utilidades.AutoSizeCol(sgIndices, i);
  end
  else
  begin
    setTablaFalla(sgFalla, EditTamTablaFalla, ProfundidadEscalonesDeFallaPorDefecto,
      CostoEscalonesDeFallaPorDefecto, cambioTamTablaFalla);
    OpenDialog1.InitialDir := getDir_DatosComunes;
    OpenDialog1.Filter := 'Archivos Binarios (*.bin)|*.bin|Todos los Archivos (*.*)|*.*';

    nAnios := max(sala.globs.fechaIniSim.aniosHasta(sala.globs.fechaFinSim) +
      1, sala.globs.fechaIniOpt.aniosHasta(sala.globs.fechaFinOpt) + 1);
    anioIni := min(sala.globs.fechaIniSim.anio, sala.globs.fechaIniOpt.anio);

    UDAnioIni.Position := anioIni;
    eAnioIni.Text := IntToStr(anioIni);
    UDAnioFin.Position := anioIni + nAnios - 1;
    eAnioFin.Text := IntToStr(anioIni + nAnios - 1);
    UDAnioIni.Max := UDAnioFin.Position;
    UDAnioFin.Min := UDAnioIni.Position;

    sgIndices.RowCount := nAnios + 1;
    sgIndices.Cells[0, 0] := rsAnio;
    sgIndices.Cells[1, 0] := rsDemandaCombustibleDelAnioMm3;
    for i := 1 to sgIndices.RowCount - 1 do
    begin
      sgIndices.Cells[0, i] := IntToStr(anioIni + i - 1);
      sgIndices.Cells[1, i] := '1';
    end;

    for i := 0 to sgIndices.ColCount - 1 do
      utilidades.AutoSizeCol(sgIndices, i);
  end;
end;

function TEditarTDemandaCombustibleAnioBaseEIndices.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarEditFecha(EFNac) and inherited validarEditFecha(EFMuerte) and
    inherited validarCBNodoCombustible(CBNodoCombustible) and inherited validarCBFuente(CBFuente,
    CBBorne, 0) and inherited validarEditInt(EditTamTablaFalla, 1, MAXINT) and
    inherited validarTablaFalla(sgFalla) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0) and inherited validarEditNArch(ENarch) and
    inherited validarTablaNReals_(sgIndices);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.llenarEtiquetaDemandaCombustible;
var
  datos: TDatosHorariosDetallados;
  buff: TDAofNReal;
  i: integer;
  sum: NReal;
begin
  datos := TDatosHorariosDetallados.Create(ENarch.Text, nil );
  SetLength(buff, 366 * 24);
  datos.ReadBuff_horario(buff, datos.fechaPrimerDia);
  datos.Free;

  sum := 0;
  for i := 0 to 365 * 24 - 1 do
    sum := sum + buff[i];

  LDemandaCombustible.Caption := rsDemandaCombustible+': ('+rsDemandaCombustibleEnElAnioBase+' [Mm3] = ' +
    FloatToStrF(sum / 1.0E6, ffFixed, CF_PRECISION, 1) + ' '+ rsEn365Dias+', = ';

  for i := 365 * 24 to 366 * 24 - 1 do
    sum := sum + buff[i];
  LDemandaCombustible.Caption := LDemandaCombustible.Caption + FloatToStrF(sum  / 1.0E6,
    ffFixed, CF_PRECISION, 1) + ' '+rsEn366Dias+')';
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.cambioTamTablaFalla;
begin
  LIndicePreciosPorCombustible.Left := sgFalla.Left + sgFalla.Width + 5;
  LBornePreciosPorCombustible.Left := LIndicePreciosPorCombustible.Left;
  CBFuenteIndicePreciosPorCombustible.Left :=
    LIndicePreciosPorCombustible.Left + LIndicePreciosPorCombustible.Width + 5;
  CBBorneIndicePreciosCombustible.Left := CBFuenteIndicePreciosPorCombustible.Left;
  if sgFalla.Width - ENarch.Left > maxAnchoTablaMediana then
  begin
    ENarch.Width := sgFalla.Width - ENarch.Left;
    BExaminar.Left := ENarch.Left + ENarch.Width + 5;
    BCrear.Left := BExaminar.Left + BCrear.Width + 5;
  end;
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.BCrearClick(Sender: TObject);
var
  form: TCrearBinDatosHorarios;
  datos: TDatosHorariosDetallados;
  dtIniAnio, dtFinAnio: TDateTime;
  anio, mes, dia: word;
begin
  DecodeDate(sala.globs.fechaIniSim.AsDt, anio, mes, dia);
  dtIniAnio := EncodeDateTime(anio, 1, 1, 0, 0, 0, 0);
  dtFinAnio := dtIniAnio + 366.0;
(*
  EncodeDateTime(anio+1, 1, 1, 0, 0, 0, 0 );
  //366 días despues
  if not IsLeapYear(anio) then
    dtFinAnio:= dtFinAnio + 1;
*)
  form := TCrearBinDatosHorarios.Create(self, dtIniAnio, dtFinAnio);
  if form.ShowModal = mrOk then
  begin
    datos := TDatosHorariosDetallados.Create(form.darNombreArch, nil );
    if datos.cantDatos = 366 * 24 then
    begin
      ENarch.Text := form.darNombreArch;
      llenarEtiquetaDemandaCombustible;
    end
    else
      ShowMessage(mesCantidadDatosEnArchivo + IntToStr(366 * 24));
    datos.Free;
  end;
  form.Free;
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.BExaminarClick(Sender: TObject);
var
  datos: TDatosHorariosDetallados;
begin
  if OpenDialog1.Execute then
  begin
    OpenDialog1.FileName := OpenDialog1.FileName;
    datos := TDatosHorariosDetallados.Create(OpenDialog1.FileName, nil );
    if datos.cantDatos = 366 * 24 then
    begin
      ENarch.Text := OpenDialog1.FileName;
      llenarEtiquetaDemandaCombustible;
    end
    else
      ShowMessage(mesCantidadDatosEnArchivo + IntToStr(366 * 24));
    datos.Free;
  end;
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.BExportar_odsClick(Sender: TObject);
begin
  exportarTablaAODS_2(sgIndices, BImportar_ods,
    PBExpoImpo);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.BGuardarClick(Sender: TObject);
var
  actor: TDemandaCombustibleAnioBaseEIndices;
  i: integer;
  indices: TDAofNReal;
begin
  if validarFormulario then
  begin
    SetLength(indices, sgIndices.RowCount - 1);
    for i := 0 to high(indices) do
      indices[i] := StrToFloat(sgIndices.Cells[1, i + 1]);

    if cosaConNombre = nil then
    begin
      cosaConNombre := TDemandaCombustibleAnioBaseEIndices.Create(
        capa,
        EditNombre.Text,
        FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text),
        lpdUnidades,
        valorCBNodoCombustible(CBNodoCombustible),
        getFallaProfundidad(sgFalla),
        getFallaCosto(sgFalla),
        ENarch.Text,
        valorCBFuente(CBFuente),
        valorCBString(CBBorne),
        chkSumarFuenteCaudal.Checked,
        StrToInt(self.eAnioIni.Text),
        StrToInt(self.eAnioFin.Text),
        indices,
        valorCBFuente(CBFuenteIndicePreciosPorCombustible),
        valorCBString(CBBorneIndicePreciosCombustible)
        );
      actor := TDemandaCombustibleAnioBaseEIndices(cosaConNombre);
    end
    else
    begin
      actor := TDemandaCombustibleAnioBaseEIndices(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.nodocomb := valorCBNodoCombustible(CBNodoCombustible);
      actor.falla_profundidad := getFallaProfundidad(sgFalla);
      actor.falla_costo_0 := getFallaCosto(sgFalla);
      actor.ArchiDatos.archi := ENarch.Text;
      actor.fuente := valorCBFuente(CBFuente);
      actor.nombreBorne := valorCBString(CBBorne);
      actor.SumarCaudalHr := chkSumarFuenteCaudal.Checked;
      actor.AnioIni := StrToInt(self.eAnioIni.Text);
      actor.AnioFin := StrToInt(self.eAnioFin.Text);
      actor.Mm3_anios := indices;
      actor.icf_Fuente := valorCBFuente(CBFuenteIndicePreciosPorCombustible);
      actor.icf_NombreBorne := valorCBString(CBBorneIndicePreciosCombustible);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.BImportar_odsClick(Sender: TObject);
begin
  importarTablaDesdeODS_2(sgIndices,
    BImportar_ods, PBExpoImpo, True, True);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.CBBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.CBBorneIndicePreciosCombustibleChange(
  Sender: TObject);
begin
  inherited CBBorneChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.CBFuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorneIndicePreciosCombustible);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.CBNodoCombustibleChange(Sender: TObject);
begin
  inherited CBNodoCombustibleChange(Sender, True);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.EditTamTablaFallaExit(Sender: TObject);
begin
  inherited EditTamTablaFallaExit(Sender, sgFalla, cambioTamTablaFalla);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.FormCreate(Sender: TObject
  );
begin
  inherited;
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TEditarTDemandaCombustibleAnioBaseEIndices.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.UDAnioFinClick(Sender: TObject;
  Button: TUDBtnType);
begin
  if UDAnioIni.Position <= UDAnioFin.Position then
  begin
    if Button = btPrev then
    begin
      //Saco un anio al final
      sgIndices.RowCount := sgIndices.RowCount - 1;
    end
    else
    begin
      //Agrego un anio al final
      sgIndices.RowCount := sgIndices.RowCount + 1;
      sgIndices.Cells[0, sgIndices.RowCount - 1] := eAnioFin.Text;
      sgIndices.Cells[1, sgIndices.RowCount - 1] := '0';
    end;
  end;
  UDAnioIni.Max := UDAnioFin.Position;
end;

procedure TEditarTDemandaCombustibleAnioBaseEIndices.UDAnioIniClick(Sender: TObject;
  Button: TUDBtnType);
var
  i: integer;
begin
  if UDAnioIni.Position <= UDAnioFin.Position then
  begin
    if Button = btPrev then
    begin
      //Agrego un anio al principio
      sgIndices.RowCount := sgIndices.RowCount + 1;
      for i := sgIndices.RowCount - 1 downto 2 do
      begin
        sgIndices.Cells[0, i] := sgIndices.Cells[0, i - 1];
        sgIndices.Cells[1, i] := sgIndices.Cells[1, i - 1];
      end;
      sgIndices.Cells[0, 1] := eAnioIni.Text;
      sgIndices.Cells[1, 1] := '0';
    end
    else
    begin
      //Saco un anio del principio
      for i := 1 to sgIndices.RowCount - 2 do
      begin
        sgIndices.Cells[0, i] := sgIndices.Cells[0, i + 1];
        sgIndices.Cells[1, i] := sgIndices.Cells[1, i + 1];
      end;
      sgIndices.RowCount := sgIndices.RowCount - 1;
    end;
  end;
  UDAnioFin.Min := UDAnioIni.Position;
end;

initialization
end.
