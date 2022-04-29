unit uEditarTDemandaAnioBaseEIndices;
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
  uDemandaAnioBaseEIndices,
  udatoshorariosdetallados,
  uCrearBinDatosHorarios,
  uopencalcexportimport,
  uDemandas;

resourcestring
  rsDemandas = 'Demandas';
  rsDemandaEnElAnioBase = 'Demanda en el Año Base';
  rsEn365Dias = 'en 365 días';
  rsEn366Dias = 'en 366 días';
  rsAnio = 'Año';
  rsDemandaDelAnioGWh = 'Demanda del año[GWh]';
  mesCantidadDatosEnArchivo = 'La cantidad de datos ingresados en el archivo debe ser ';

type

  { TEditarTDemandaAnioBaseEIndices }

  TEditarTDemandaAnioBaseEIndices = class(TBaseEditoresActores)
    cbSumarParaPostizar: TCheckBox;
    LNombre: TLabel;
    LFNac: TLabel;
    LFMuerte: TLabel;
    LNodo: TLabel;
    LEscalonesdeFalla: TLabel;
    LNEscalones: TLabel;
    LNarch: TLabel;
    LFuenteDeAportes: TLabel;
    LBorne: TLabel;
    LDemandas: TLabel;
    LIndicePreciosPorCombustible: TLabel;
    LBornePreciosPorCombustible: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    BGuardar: TButton;
    BCancelar: TButton;
    EditNombre: TEdit;
    EFNac: TEdit;
    EFMuerte: TEdit;
    CBNodo: TComboBox;
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
    chkSumarFuentePotencia: TCheckBox;
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure CBNodoChange(Sender: TObject);
    procedure CBFuenteChange(Sender: TObject);
    procedure CBBorneChange(Sender: TObject);
    procedure EditTamTablaFallaExit(Sender: TObject);
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
    procedure llenarEtiquetaDemanda;
    procedure cambioTamTablaFalla;
  public
    constructor Create(AOwner: TComponent; sala: TSalaDeJuego;
      tipoCosa: TClass; cosaConNombre: TCosaConNombre); override;
    function validarFormulario: boolean; override;
  end;

implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarTDemandaAnioBaseEIndices.Create(AOwner: TComponent;
  sala: TSalaDeJuego; tipoCosa: TClass; cosaConNombre: TCosaConNombre);
var
  actor: TDemandaAnioBaseEIndices;
  i, nAnios, anioIni: integer;
begin
  inherited Create(AOwner, sala, tipoCosa, cosaConNombre);
  utilidades.AgregarFormatoFecha(LFNac);
  utilidades.AgregarFormatoFecha(LFMuerte);
  if TSimSEEEditOptions.getInstance.fechasAutomaticas then
    inherited ocultarFechas(LFNac, LFMuerte, EFNac, EFMuerte);
  inicializarCBNodos(CBNodo, False);
  inicializarCBFuente(CBFuente, CBBorne, True);
  inicializarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, True);

  if cosaConNombre <> nil then
  begin
    actor := TDemandaAnioBaseEIndices(cosaConNombre);

    EditNombre.Text := actor.nombre;
    EFNac.Text := FSimSEEEdit.fechaIniToString(actor.nacimiento);
    EFMuerte.Text := FSimSEEEdit.fechaFinToString(actor.muerte);
    setCBNodo(CBNodo, actor.Nodo);
    setCBFuente(CBFuente, CBBorne, actor.fuente, actor.nombreBorne);
    chkSumarFuentePotencia.Checked := actor.SumarEnergiaHr;
    cbSumarParaPostizar.Checked := actor.flg_SumarParaPostizado;
    setTablaFalla(sgFalla, EditTamTablaFalla, actor.falla_profundidad,
      actor.falla_costo_0, cambioTamTablaFalla);
    setCBFuente(CBFuenteIndicePreciosPorCombustible, CBBorneIndicePreciosCombustible,
      actor.icf_Fuente, actor.icf_NombreBorne);
    ENarch.Text := actor.ArchiDatos.archi;
    OpenDialog1.InitialDir := getCurrentDrive + ExtractFilePath(ENarch.Text);
    OpenDialog1.Filter := 'Archivos Binarios (*.bin)|*.bin|Todos los Archivos (*.*)|*.*';

    llenarEtiquetaDemanda;
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
    sgIndices.Cells[1, 0] := rsDemandaDelAnioGWh;
    for i := 1 to high(actor.GWh_anios) do
    begin
      sgIndices.Cells[0, i] := IntToStr(anioIni + i - 1);
      sgIndices.Cells[1, i] := FloatToStr(actor.GWh_anios[i - 1]);
    end;
    for i := Length(actor.GWh_anios) to sgIndices.RowCount - 1 do
    begin
      sgIndices.Cells[0, i] := IntToStr(anioIni + i - 1);
      sgIndices.Cells[1, i] := FloatToStr(actor.GWh_anios[high(actor.GWh_anios)]);
    end;

    for i := 0 to sgIndices.ColCount - 1 do
      utilidades.AutoSizeCol(sgIndices, i);
  end
  else
  begin
    cbSumarParaPostizar.Checked:= true;
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
    sgIndices.Cells[1, 0] := rsDemandaDelAnioGWh;
    for i := 1 to sgIndices.RowCount - 1 do
    begin
      sgIndices.Cells[0, i] := IntToStr(anioIni + i - 1);
      sgIndices.Cells[1, i] := '1';
    end;

    for i := 0 to sgIndices.ColCount - 1 do
      utilidades.AutoSizeCol(sgIndices, i);
  end;
end;

function TEditarTDemandaAnioBaseEIndices.validarFormulario: boolean;
begin
  Result := inherited validarFormulario and inherited  validarNombre(EditNombre) and
    inherited validarEditFecha(EFNac) and inherited validarEditFecha(EFMuerte) and
    inherited validarCBNodo(CBNodo) and inherited validarCBFuente(CBFuente,
    CBBorne, 0) and inherited validarEditInt(EditTamTablaFalla, 1, MAXINT) and
    inherited validarTablaFalla(sgFalla) and
    inherited validarCBFuente(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible, 0) and inherited validarEditNArch(ENarch) and
    inherited validarTablaNReals_(sgIndices);
end;

procedure TEditarTDemandaAnioBaseEIndices.llenarEtiquetaDemanda;
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

  LDemandas.Caption := rsDemandas+': ('+rsDemandaEnElAnioBase+' [GW] = ' +
    FloatToStrF(sum / 1000, ffFixed, CF_PRECISION, 1) + ' '+ rsEn365Dias+', = ';

  for i := 365 * 24 to 366 * 24 - 1 do
    sum := sum + buff[i];
  LDemandas.Caption := LDemandas.Caption + FloatToStrF(sum / 1000,
    ffFixed, CF_PRECISION, 1) + ' '+rsEn366Dias+')';
end;

procedure TEditarTDemandaAnioBaseEIndices.cambioTamTablaFalla;
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

procedure TEditarTDemandaAnioBaseEIndices.BAyudaClick(Sender: TObject);
begin
  uverdoc.verdoc(self, tipoCosa);
end;

procedure TEditarTDemandaAnioBaseEIndices.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarTDemandaAnioBaseEIndices.BCrearClick(Sender: TObject);
var
  form: TCrearBinDatosHorarios;
  datos: TDatosHorariosDetallados;
  dtIniAnio, dtFinAnio: TDateTime;
  anio, mes, dia: word;
  archi:string;
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
  archi := ENarch.Text;
  if not fileexists(archi) then
    form := TCrearBinDatosHorarios.Create(self, dtIniAnio, dtFinAnio)
  else
    form := TCrearBinDatosHorarios.Create(self, archi );
  if form.ShowModal = mrOk then
  begin
    datos := TDatosHorariosDetallados.Create(form.darNombreArch, nil);
    if datos.cantDatos = 366 * 24 then
    begin
      ENarch.Text := form.darNombreArch;
      llenarEtiquetaDemanda;
    end
    else
      ShowMessage(mesCantidadDatosEnArchivo + IntToStr(366 * 24));
    datos.Free;
  end;
  form.Free;
end;

procedure TEditarTDemandaAnioBaseEIndices.BEditorDeUnidadesClick(Sender: TObject);
begin
  inherited BEditorDeUnidadesClick(Sender);
end;

procedure TEditarTDemandaAnioBaseEIndices.BExaminarClick(Sender: TObject);
var
  datos: TDatosHorariosDetallados;
begin
  if OpenDialog1.Execute then
  begin
    OpenDialog1.FileName := OpenDialog1.FileName;
    datos := TDatosHorariosDetallados.Create(OpenDialog1.FileName, nil);
    if datos.cantDatos = 366 * 24 then
    begin
      ENarch.Text := OpenDialog1.FileName;
      llenarEtiquetaDemanda;
    end
    else
      ShowMessage(mesCantidadDatosEnArchivo + IntToStr(366 * 24));
    datos.Free;
  end;
end;

procedure TEditarTDemandaAnioBaseEIndices.BExportar_odsClick(Sender: TObject);
begin
  exportarTablaAODS_2(sgIndices, BImportar_ods,
    PBExpoImpo);
end;

procedure TEditarTDemandaAnioBaseEIndices.BGuardarClick(Sender: TObject);
var
  actor: TDemandaAnioBaseEIndices;
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
      cosaConNombre := TDemandaAnioBaseEIndices.Create(
        capa, EditNombre.Text, FSimSEEEdit.StringToFecha(EFNac.Text),
        FSimSEEEdit.StringToFecha(EFMuerte.Text), lpdUnidades,
        valorCBNodo(CBNodo), getFallaProfundidad(sgFalla),
        getFallaCosto(sgFalla), ENarch.Text, valorCBFuente(CBFuente),
        valorCBString(CBBorne), chkSumarFuentePotencia.Checked,
        cbSumarParaPostizar.Checked,
        StrToInt(self.eAnioIni.Text), StrToInt(self.eAnioFin.Text),
        indices, valorCBFuente(CBFuenteIndicePreciosPorCombustible),
        valorCBString(CBBorneIndicePreciosCombustible));
      actor := TDemandaAnioBaseEIndices(cosaConNombre);
    end
    else
    begin
      actor := TDemandaAnioBaseEIndices(cosaConNombre);
      actor.nombre := EditNombre.Text;
      actor.nacimiento.PonerIgualA(EFNac.Text);
      actor.muerte.PonerIgualA(EFMuerte.Text);
      actor.lpdUnidades.Free;
      actor.lpdUnidades := lpdUnidades;
      actor.Nodo := valorCBNodo(CBNodo);
      actor.falla_profundidad := getFallaProfundidad(sgFalla);
      actor.falla_costo_0 := getFallaCosto(sgFalla);
      actor.ArchiDatos.archi := ENarch.Text;
      actor.fuente := valorCBFuente(CBFuente);
      actor.nombreBorne := valorCBString(CBBorne);
      actor.SumarEnergiaHr := chkSumarFuentePotencia.Checked;
      actor.flg_SumarParaPostizado:= cbSumarParaPostizar.Checked;
      actor.AnioIni := StrToInt(self.eAnioIni.Text);
      actor.AnioFin := StrToInt(self.eAnioFin.Text);
      actor.GWh_anios := indices;
      actor.icf_Fuente := valorCBFuente(CBFuenteIndicePreciosPorCombustible);
      actor.icf_NombreBorne := valorCBString(CBBorneIndicePreciosCombustible);
    end;
    actor.lpdForzamientos := lpdForzamientos_;
    ModalResult := mrOk;
  end;
end;

procedure TEditarTDemandaAnioBaseEIndices.BImportar_odsClick(Sender: TObject);
begin
  importarTablaDesdeODS_2(sgIndices,
    BImportar_ods, PBExpoImpo, True, True);
end;

procedure TEditarTDemandaAnioBaseEIndices.CBBorneChange(Sender: TObject);
begin
  inherited CBBorneChange(CBFuente, CBBorne);
end;

procedure TEditarTDemandaAnioBaseEIndices.CBBorneIndicePreciosCombustibleChange(
  Sender: TObject);
begin
  inherited CBBorneChange(CBFuenteIndicePreciosPorCombustible,
    CBBorneIndicePreciosCombustible);
end;

procedure TEditarTDemandaAnioBaseEIndices.CBFuenteChange(Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorne);
end;

procedure TEditarTDemandaAnioBaseEIndices.CBFuenteIndicePreciosPorCombustibleChange(
  Sender: TObject);
begin
  inherited CBFuenteChange(Sender, CBBorneIndicePreciosCombustible);
end;

procedure TEditarTDemandaAnioBaseEIndices.CBNodoChange(Sender: TObject);
begin
  inherited CBNodoChange(Sender, True);
end;

procedure TEditarTDemandaAnioBaseEIndices.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarTDemandaAnioBaseEIndices.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarTDemandaAnioBaseEIndices.EditTamTablaFallaExit(Sender: TObject);
begin
  inherited EditTamTablaFallaExit(Sender, sgFalla, cambioTamTablaFalla);
end;

procedure TEditarTDemandaAnioBaseEIndices.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;


procedure TEditarTDemandaAnioBaseEIndices.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(Sender);
end;

procedure TEditarTDemandaAnioBaseEIndices.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarTDemandaAnioBaseEIndices.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarTDemandaAnioBaseEIndices.UDAnioFinClick(Sender: TObject;
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

procedure TEditarTDemandaAnioBaseEIndices.UDAnioIniClick(Sender: TObject;
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
