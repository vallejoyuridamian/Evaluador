unit uEditarFichaDemanda01;


interface

uses
  {$IFDEF WINDOWS}
   Windows,
   {$ELSE}
   LCLType,
   {$ENDIF}
 Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, udemandas01, xmatdefs, uBaseEditoresFichas,
  utilidades, ExtCtrls, uFechas, Math,
  ComCtrls, ToolWin, ActnList, uimpvnreal, ImgList, uBaseAltasEditores, uCosaConNombre,
  ufichasLPD,
  usalasdejuego,
  usalasdejuegoParaEditor, uverdoc, uOpcionesSimSEEEdit;

resourcestring
  mesFactoresIndicadosPorFila =
    'Error. Si se aplican los factores indicados para la fila ';
  mesPotenciaEsNegativa = ' la potencia resultante es negativa.';
  mesSeleccionarDiasDatos = 'Debe seleccionar a que tipo de día corresponden los datos';

  rs_DiasHabiles = 'Días hábiles';
  rs_DiasSemiFeriados = 'Días semi feriados';
  rs_DiasFeriados = 'Días Feriados';
  rs_FactorCrecimientoEnergia = 'Factor de la energía [p.u.]';
  rs_FactorCrecimientoPico = 'Factor del pico [p.u.]';

type

  { TEditarFichaDemanda01 }

  TEditarFichaDemanda01 = class(TBaseEditoresFichas)
    BAplicarImport: TButton;
    BAyudaAplicarFactores: TButton;
    BAyudaImportar: TButton;
    BCerrarImport: TButton;
    BImportar: TButton;
    ImpPotencias: TStringGrid;
    LAplicar: TLabel;
    PImportar: TPanel;
    RBDiasFeriados: TRadioButton;
    RBDiasHabiles: TRadioButton;
    RBDiasMediosFeriados: TRadioButton;
    RBTodos: TRadioButton;
    sgPotencias: TStringGrid;
    BGuardar: TButton;
    BCancelarFicha: TButton;
    LFIni: TLabel;
    EFIni: TEdit;
    TBHerramientas: TToolBar;
    TBAplicarFcrec: TToolButton;
    TBImportarDatos: TToolButton;
    PFCrec: TPanel;
    sgFactores: TStringGrid;

    ActionList: TActionList;
    herramientaImportar: TAction;
    herramientaGrafico: TAction;
    herramientaFCrec: TAction;
    BAplicarFCrec: TButton;
    BCerrarFCrec: TButton;
    ILHerramientas: TImageList;
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
    procedure BAyudaAplicarFactoresClick(Sender: TObject);
    procedure BAyudaImportarClick(Sender: TObject);
    procedure BCerrarImportClick(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BCancelarClick(Sender: TObject);
    procedure PGraficoClick(Sender: TObject);
    procedure RBTodosChange(Sender: TObject);
    procedure sgGetEditText(Sender: TObject; ACol, ARow: integer; var Value: string);
    procedure BGuardarClick(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure EditExit(Sender: TObject);
    procedure sgFactoresClick(Sender: TObject);
    procedure sgFactoresKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure sgFactoresExit(Sender: TObject);
    procedure BImportarClick(Sender: TObject);
    procedure herramientaImportarExecute(Sender: TObject);
    procedure BCerrarHerramientaClick(Sender: TObject);
    procedure BAplicarImportClick(Sender: TObject);
    procedure herramientaGraficoExecute(Sender: TObject);
    procedure herramientaFCrecExecute(Sender: TObject);
    procedure BAplicarFCrecClick(Sender: TObject);
    procedure CBPeriodicidadClick(Sender: TObject);
    procedure sgChequearCambios(Sender: TObject);
    procedure sgChequearCambiosKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure cambiosForm(Sender: TObject);
    procedure BAyudaClick(Sender: TObject);
  protected
    procedure validarCambioTabla(tabla: TStringGrid); override;
    function validarFormulario: boolean; override;
  private
    Demanda: TDemanda01;
    PotDiasHabiles, PotDiasMediosFeriados, PotDiasFeriados: TDAofNReal;

    procedure aplicarFactoresDeCrecimiento();
    function validarTabla(Sender: TStringGrid): boolean;

    procedure habilitarPanel(Sender: TObject);
    procedure deshabilitarPanel();
  public
    constructor Create(AOwner: TComponent; cosaConNombre: TCosaConNombre;
      ficha: TFichaLPD; sala: TSalaDeJuego); override;
    procedure Free;
  end;

var
  EditarFichaDemanda01: TEditarFichaDemanda01;


// valores por defecto para los tres tipos de día.
// corresponden a la demanda de Uruguay en Febrero de 2011
const
  Default_DiaHabil: array[0..23] of NReal = (
    1021, 945, 908, 897, 915, 974, 1000, 1069,
    1140, 1189, 1233, 1253, 1283, 1287, 1285, 1278,
    1254, 1207, 1154, 1205, 1374, 1338, 1273, 1160);
  Default_DiaSemiFeriado: array[0..23] of NReal = (
    1140, 1046, 1011, 992, 992, 1019, 1017, 1041,
    1084, 1130, 1169, 1184, 1184, 1164, 1153, 1143,
    1138, 1111, 1101, 1181, 1297, 1248, 1188, 1104);
  Default_DiaFeriado: array[0..23] of NReal = (
    1015, 950, 895, 884, 874, 877, 832, 836,
    887, 925, 966, 987, 1000, 986, 978, 977,
    984, 982, 980, 1078, 1236, 1226, 1183, 1100);


implementation

uses SimSEEEditMain;

  {$R *.lfm}

constructor TEditarFichaDemanda01.Create(AOwner: TComponent;
  cosaConNombre: TCosaConNombre; ficha: TFichaLPD; sala: TSalaDeJuego);
var
  i: integer;
  valor: NReal;
  fichaAux: TFichaDemanda01;
begin
  inherited Create(AOwner, cosaConNombre, ficha, sala);
  Demanda := cosaConNombre as TDemanda01;
  guardado := True;
  inherited llenarCamposPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
    EFIniPeriodo, EFFinPeriodo, sgPeriodicidad, CBPeriodicidad, ficha, PPeriodicidad);
  if (ficha <> nil) then
  begin
    fichaAux := ficha as TFichaDemanda01;
    self.EFIni.Text := FSimSEEEdit.fechaIniToString(fichaAux.fecha);
    PotDiasHabiles := copy(fichaAux.PotDiaHabil, 0, MAXINT);
    PotDiasMediosFeriados := copy(fichaAux.PotDiaMedioFeriado, 0, MAXINT);
    PotDiasFeriados := copy(fichaAux.PotDiaFeriado, 0, MAXINT);
    for i := 0 to 23 do
    begin
      sgPotencias.Cells[i + 1, 1] := FloatToStr(PotDiasHabiles[i]);
      sgPotencias.Cells[i + 1, 2] := FloatToStr(PotDiasMediosFeriados[i]);
      sgPotencias.Cells[i + 1, 3] := FloatToStr(PotDiasFeriados[i]);
    end;
  end
  else
  begin
    self.EFIni.Text := '';
    setLength(PotDiasHabiles, 24);
    setLength(PotDiasMediosFeriados, 24);
    setLength(PotDiasFeriados, 24);
    for i := 0 to 23 do
    begin
      valor := Default_DiaHabil[i];
      sgPotencias.Cells[i + 1, 1] := FloatToStr(valor);
      PotDiasHabiles[i] := valor;

      valor := Default_DiaSemiFeriado[i];
      sgPotencias.Cells[i + 1, 2] := FloatToStr(valor);
      PotDiasMediosFeriados[i] := valor;

      valor := Default_DiaFeriado[i];
      sgPotencias.Cells[i + 1, 3] := FloatToStr(valor);
      PotDiasFeriados[i] := valor;
    end;
  end;
end;

procedure TEditarFichaDemanda01.EditEnter(Sender: TObject);
begin
  inherited EditEnter(Sender);
end;

procedure TEditarFichaDemanda01.BCerrarImportClick(Sender: TObject);
begin
  deshabilitarPanel();
end;

procedure TEditarFichaDemanda01.BAyudaAplicarFactoresClick(Sender: TObject);
begin
  verdoc(self, 'Demanda3Curvas_AplicarFactores');
end;

procedure TEditarFichaDemanda01.BAyudaImportarClick(Sender: TObject);
begin
  verdoc(self, 'Demanda3Curvas_Importar');
end;

procedure TEditarFichaDemanda01.FormCreate(Sender: TObject);
var
  i, j: integer;
begin
  utilidades.AgregarFormatoFecha(LFIni);

  for i := 0 to sgPotencias.ColCount - 2 do
    sgPotencias.Cells[i + 1, 0] := IntToStr(i);
  guardado := True;
  sgPotencias.Cells[0, 1] := rs_DiasHabiles;
  sgPotencias.Cells[0, 2] := rs_DiasSemiFeriados;
  sgPotencias.Cells[0, 3] := rs_DiasFeriados;
  AutoSizeCol(sgPotencias, 0);

  sgFactores.Cells[1, 0] := rs_FactorCrecimientoEnergia;
  sgFactores.Cells[2, 0] := rs_FactorCrecimientoPico;

  sgFactores.Cells[0, 1] := rs_DiasHabiles;
  sgFactores.Cells[0, 2] := rs_DiasSemiFeriados;
  sgFactores.Cells[0, 3] := rs_DiasFeriados;
  for i := 0 to sgFactores.ColCount - 1 do
    AutoSizeCol(sgFactores, i);

  for i := 1 to sgFactores.ColCount - 1 do
    for j := 1 to sgFactores.RowCount - 1 do
      sgFactores.Cells[i, j] := '1';

end;

procedure TEditarFichaDemanda01.BCancelarClick(Sender: TObject);
begin
  inherited BCancelarClick(Sender);
end;

procedure TEditarFichaDemanda01.PGraficoClick(Sender: TObject);
begin

end;

procedure TEditarFichaDemanda01.RBTodosChange(Sender: TObject);
begin

end;

function TEditarFichaDemanda01.validarTabla(Sender: TStringGrid): boolean;
begin
  Result := inherited validarTablaNReals_(TStringGrid(Sender));
end;

procedure TEditarFichaDemanda01.validarCambioTabla(tabla: TStringGrid);
var
  valor: NReal;
begin
  if (colValidarSG >= 0) and (filaValidarSG >= 0) then
  begin
    if (validarSg) and (tabla.cells[colValidarSG, filaValidarSG] <> loQueHabia) and
      (filaValidarSG > tabla.FixedRows - 1) and (colValidarSG > tabla.FixedCols - 1) then
    begin
      try
        begin
          valor := StrToFloat(tabla.cells[colValidarSG, filaValidarSG]);
          if (tabla = sgPotencias) then
          begin
            case filaValidarSG of
              1: PotDiasHabiles[colValidarSG - 1] := valor;
              2: PotDiasMediosFeriados[colValidarSG - 1] := valor;
              3: PotDiasFeriados[colValidarSG - 1] := valor;
              else
                Exception.Create('Fila no valida');
            end;
                                {$IFNDEF FPC-LCL}
            GPotencias.SeriesList[filaValidarSG - 1].Delete(colValidarSG - 1);
            GPotencias.SeriesList[filaValidarSG - 1].AddXY(colValidarSG -
              1, valor, '', clTeeColor);
                                {$ENDIF}
          end;
          guardado := False;
        end
      except
        on EConvertError do
        begin
          tabla.Cells[colValidarSG, filaValidarSG] := loQueHabia;
          ShowMessage(mesValoresEnTablaNumericos);
        end
      end;
      validarSg := True;
    end;
  end;
end;

function TEditarFichaDemanda01.validarFormulario: boolean;
begin
  inherited validarFormulario;
  Result := validarEditFecha(EFIni) and inherited validarPeriodicidad(
    CBPeriodicidad, CBLargoPeriodo, ELargoPeriodo, EFIniPeriodo,
    EFFinPeriodo, sgPeriodicidad) and validarTabla(sgPotencias);
end;

procedure TEditarFichaDemanda01.sgGetEditText(Sender: TObject;
  ACol, ARow: integer; var Value: string);
begin
  inherited sgGetEditText(Sender, ACol, ARow, Value);
end;

procedure TEditarFichaDemanda01.BGuardarClick(Sender: TObject);
var
  periodo: TPeriodicidad;
begin
  if validarFormulario then
  begin
    if not CBPeriodicidad.Checked then
      ficha := TFichaDemanda01.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
        nil, PotDiasHabiles, PotDiasMediosFeriados, PotDiasFeriados)
    else
    begin
      periodo := inherited darPeriodicidad(CBLargoPeriodo, ELargoPeriodo,
        EFIniPeriodo, EFFinPeriodo, sgPeriodicidad);
      ficha := TFichaDemanda01.Create(capa, FSimSEEEdit.StringToFecha(EFIni.Text),
        periodo, PotDiasHabiles, PotDiasMediosFeriados, PotDiasFeriados);
    end;
    ModalResult := mrOk;
  end;
end;

procedure TEditarFichaDemanda01.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  inherited FormCloseQuery(Sender, CanClose);
end;

procedure TEditarFichaDemanda01.EditExit(Sender: TObject);
begin
  inherited EditExit(Sender);
end;

procedure TEditarFichaDemanda01.aplicarFactoresDeCrecimiento();
var
  j, fila: integer;
  Aux, pAux: array [1..3] of TDAofNReal;
  fce, fcp: NReal;
  cambiosEnFila: array [1..3] of boolean;
  sin_error: boolean;

  function tratarfila(fila: integer): boolean;
  var
    res: boolean;
  begin
    res := True;
    fce := StrToFloat(sgFactores.Cells[1, fila]);
    fcp := StrToFloat(sgFactores.Cells[2, fila]);
    cambiosEnFila[fila] := False;
    if (fce <> 1) or (fcp <> 1) then
    begin
      // si alguno de los factoes es <> 1 intentamos aplicarlos
      if udemandas01.aplicarCrecimientos_CurvaHoraria(Aux[fila], fce, fcp) then
        cambiosEnFila[fila] := True
      else
        res := False;
    end;
    Result := res;
  end;

  procedure actualizar_fila(fila: integer);
  var
    hora: integer;
  begin
    if cambiosEnFila[fila] then
      for hora := 0 to high(pAux[fila]) do
      begin
        pAux[fila][hora] := Aux[fila][hora];
        sgPotencias.cells[hora + 1, fila] := FloatToStr(Aux[fila][hora]);
      end;
  end;

begin
  pAux[1] := PotDiasHabiles;
  pAux[2] := PotDiasMediosFeriados;
  pAux[3] := PotDiasFeriados;

  Aux[1] := copy(PotDiasHabiles, 0, MAXINT);
  Aux[2] := copy(PotDiasMediosFeriados, 0, MAXINT);
  Aux[3] := copy(PotDiasFeriados, 0, MAXINT);

  sin_error := True;

  for fila := 1 to 3 do
    sin_error := sin_error and tratarfila(fila);

  if sin_error then
  begin
    for fila := 1 to 3 do
      actualizar_fila(fila);
  end
  else
  begin
    ShowMessage(mesFactoresIndicadosPorFila + IntToStr(fila) + mesPotenciaEsNegativa);
  end;
  for fila := 1 to 3 do
    setlength(Aux[fila], 0);
end;

procedure TEditarFichaDemanda01.sgFactoresClick(Sender: TObject);
begin
  inherited sgValidarCambio(Sender);
end;

procedure TEditarFichaDemanda01.sgFactoresKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaDemanda01.sgFactoresExit(Sender: TObject);
begin
  inherited sgValidarCambio(Sender);
end;

procedure TEditarFichaDemanda01.BImportarClick(Sender: TObject);
var
  a: TDAofNReal;
  i: integer;
begin
  a := uimpvnreal.importarDatosTamanioN(24);
  if a <> nil then
    for i := 0 to 23 do
      ImpPotencias.Cells[i, 0] := FloatToStr(a[i]);
end;

procedure TEditarFichaDemanda01.herramientaImportarExecute(Sender: TObject);
begin
  if TToolButton(Sender).Down then
    habilitarPanel(Sender)
  else
    deshabilitarPanel;
end;

procedure TEditarFichaDemanda01.BCerrarHerramientaClick(Sender: TObject);
begin
  deshabilitarPanel();
end;

procedure TEditarFichaDemanda01.BAplicarImportClick(Sender: TObject);
var
  i, j: integer;
  Aux: TDAofNReal;
begin
  if RBDiasHabiles.Checked then
  begin
    j := 1;
    Aux := PotDiasHabiles;
  end
  else if RBDiasMediosFeriados.Checked then
  begin
    j := 2;
    Aux := PotDiasMediosFeriados;
  end
  else if RBDiasFeriados.Checked then
  begin
    j := 3;
    Aux := PotDiasFeriados;
  end
  else if RBTodos.Checked then
  begin
    j := 0;
  end
  else
  begin
    ShowMessage(mesSeleccionarDiasDatos);
    Aux := nil;
    j := -1;
  end;

  if j <> -1 then
    if j <> 0 then
    begin
      for i := 0 to 23 do
      begin
        sgPotencias.Cells[i + 1, j] := ImpPotencias.Cells[i, 0];
        Aux[i] := StrToFloat(ImpPotencias.Cells[i, 0]);
      end;
    end
    else
    begin
      for i := 0 to 23 do
      begin
        sgPotencias.Cells[i + 1, 1] := ImpPotencias.Cells[i, 0];
        sgPotencias.Cells[i + 1, 2] := ImpPotencias.Cells[i, 0];
        sgPotencias.Cells[i + 1, 3] := ImpPotencias.Cells[i, 0];

        PotDiasHabiles[i] := StrToFloat(ImpPotencias.Cells[i, 0]);
        PotDiasMediosFeriados[i] := PotDiasHabiles[i];
        PotDiasFeriados[i] := PotDiasHabiles[i];
      end;
    end;
end;

procedure TEditarFichaDemanda01.herramientaGraficoExecute(Sender: TObject);
var
  i: integer;
begin
  if TToolButton(Sender).Down then
  begin
                {$IFNDEF FPC-LCL}
    GPotencias.SeriesList[0].Clear();
    GPotencias.SeriesList[1].Clear();
    GPotencias.SeriesList[2].Clear();
                {$ENDIF}

    for i := 0 to 23 do
    begin
                        {$IFNDEF FPC-LCL}
      GPotencias.SeriesList[0].AddXY(i, StrToFloat(sgPotencias.Cells[i + 1, 1]),
        '', clteeColor);
      GPotencias.SeriesList[1].AddXY(i, StrToFloat(sgPotencias.Cells[i + 1, 2]),
        '', clteeColor);
      GPotencias.SeriesList[2].AddXY(i, StrToFloat(sgPotencias.Cells[i + 1, 3]),
        '', clteeColor);
                        {$ENDIF}
    end;

    habilitarPanel(Sender);
  end
  else
    deshabilitarPanel;
end;

procedure TEditarFichaDemanda01.herramientaFCrecExecute(Sender: TObject);
begin
  if TToolButton(Sender).Down then
    habilitarPanel(Sender)
  else
    deshabilitarPanel;
end;

procedure TEditarFichaDemanda01.habilitarPanel(Sender: TObject);
begin
  if Sender = TBImportarDatos then
  begin
    PFCrec.Visible := False;
    PImportar.Visible := True;
    BImportar.SetFocus;
    BGuardar.Visible := False;
    BCancelarFicha.Visible := False;
  end
  else if Sender = TBAplicarFcrec then
  begin
    PFCrec.Visible := True;
    PImportar.Visible := False;
    sgFactores.SetFocus;
    BGuardar.Visible := False;
    BCancelarFicha.Visible := False;
  end
  else
    raise Exception.Create('Sender desconocido');
end;

procedure TEditarFichaDemanda01.deshabilitarPanel();
var
  i: integer;
begin
  PFCrec.Visible := False;
  PImportar.Visible := False;
  BGuardar.Visible := True;
  BCancelarFicha.Visible := True;
  for i := 0 to TBHerramientas.ButtonCount - 1 do
    TBHerramientas.Buttons[i].Down := False;
end;

procedure TEditarFichaDemanda01.BAplicarFCrecClick(Sender: TObject);
begin
  if validarTabla(sgFactores) then
    aplicarFactoresDeCrecimiento();
end;

procedure TEditarFichaDemanda01.Free;
begin
  PotDiasHabiles := nil;
  PotDiasMediosFeriados := nil;
  PotDiasFeriados := nil;
  inherited Free;
end;

procedure TEditarFichaDemanda01.CBPeriodicidadClick(Sender: TObject);
begin
  inherited switchPanelPeriodicidad(CBPeriodicidad, PPeriodicidad);
end;

procedure TEditarFichaDemanda01.sgChequearCambios(Sender: TObject);
begin
  inherited sgChequearCambios(sgPeriodicidad);
end;

procedure TEditarFichaDemanda01.sgChequearCambiosKeyDown(Sender: TObject;
  var Key: word; Shift: TShiftState);
begin
  inherited sgChequearCambiosKeyDown(Sender, Key, Shift);
end;

procedure TEditarFichaDemanda01.cambiosForm(Sender: TObject);
begin
  inherited cambiosForm(Sender);
end;

procedure TEditarFichaDemanda01.BAyudaClick(Sender: TObject);
begin
  verdoc(self, 'Demanda3Curvas');
end;

end.

